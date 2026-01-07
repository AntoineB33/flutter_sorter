import 'dart:math';
// Assumes 'package:google_or_tools/google_or_tools.dart' or similar wrapper is available.
// Since specific wrapper APIs vary, this uses standard CP-SAT naming conventions.
import 'package:google_or_tools/google_or_tools.dart'; 

/// Represents a constraint for a value's position.
class Rule {
  final int minVal;
  final int maxVal;
  final int? relativeTo;

  Rule(this.minVal, this.maxVal, {this.relativeTo});

  @override
  String toString() {
    if (relativeTo == null) {
      return "Fixed($minVal, $maxVal)";
    }
    return "Rel(val:$relativeTo, offset:[$minVal, $maxVal])";
  }
}

class ConstrainedSortSolver {
  
  /// Sorts integers 0..n based on Rule objects using CP-SAT.
  static List<int>? solve(int n, Map<int, List<Rule>> rules) {
    final model = CpModel();

    // 1. Create Variables
    // indexOf[v] = position of value v
    final Map<int, IntVar> indexOf = {};
    for (int val = 0; val <= n; val++) {
      indexOf[val] = model.newIntVar(0, n, 'pos_of_$val');
    }

    // 2. Constraint: All positions must be unique
    model.addAllDifferent(indexOf.values.toList());

    // 3. Apply Rules
    rules.forEach((val, valRules) {
      if (valRules.isEmpty) return;

      // We collect boolean literals representing the satisfaction of each rule.
      // At least one literal must be true (logic: Rule A OR Rule B OR ...).
      List<BoolVar> satisfiedLiterals = [];

      // Optimization: Group all FIXED rules into a single Domain object
      List<Interval> fixedIntervals = [];

      // Helper to process fixed intervals
      void applyFixedGroup(List<Interval> intervals, List<BoolVar> literalsList) {
        if (intervals.isNotEmpty) {
          // Create a boolean that implies the value is in one of these intervals
          final isFixedValid = model.newBoolVar('${val}_is_fixed_valid');
          final domain = Domain.fromIntervals(intervals);

          // Constraint: is_fixed_valid => index_of[val] in domain
          // Note: Syntax depends on wrapper. Usually addLinearExpressionInDomain or addEquality
          model.addLinearExpressionInDomain(indexOf[val]!, domain)
               .onlyEnforceIf(isFixedValid);

          literalsList.add(isFixedValid);
        }
      }

      for (var rule in valRules) {
        if (rule.relativeTo == null) {
          // Accumulate fixed intervals
          fixedIntervals.add(Interval(rule.minVal, rule.maxVal));
        } else {
          // Handle Relative Rule
          // Logic: pos[val] - pos[target] must be between [min, max]
          final isRelValid = model.newBoolVar('${val}_rel_to_${rule.relativeTo}');
          
          final targetVar = indexOf[rule.relativeTo]!;
          
          // Constraint: is_rel_valid => min <= (val - target) <= max
          // Dart wrappers usually support operator overloading for LinearExpr
          final expr = indexOf[val]! - targetVar;
          
          model.addLinearConstraint(expr, rule.minVal, rule.maxVal)
               .onlyEnforceIf(isRelValid);

          satisfiedLiterals.add(isRelValid);
        }
      }

      // Apply the accumulated fixed intervals as one option
      applyFixedGroup(fixedIntervals, satisfiedLiterals);

      // 4. Enforce that AT LEAST ONE rule is satisfied
      if (satisfiedLiterals.isNotEmpty) {
        model.addBoolOr(satisfiedLiterals);
      }
    });

    // 5. Solve
    final solver = CpSolver();
    // solver.parameters.logSearchProgress = true;
    final status = solver.solve(model);

    if (status == CpSolverStatus.optimal || status == CpSolverStatus.feasible) {
      final resultList = List<int>.filled(n + 1, 0);
      indexOf.forEach((val, variable) {
        final pos = solver.value(variable);
        resultList[pos] = val;
      });
      return resultList;
    } else {
      return null;
    }
  }
}

class TestGenerator {
  static final Random _rng = Random();

  /// Generates a ground truth and a set of Mixed (Fixed/Relative) rules.
  static Map<String, dynamic> generateTestCaseRelative(int n,
      {double probRelative = 0.3, int strictness = 5}) {
    
    final List<int> groundTruth = List.generate(n + 1, (i) => i);
    groundTruth.shuffle(_rng);

    // Invert mapping to look up index by value easily
    final Map<int, int> posMap = {
      for (var i = 0; i < groundTruth.length; i++) groundTruth[i]: i
    };

    final Map<int, List<Rule>> rules = {};

    for (final val in groundTruth) {
      final valRules = <Rule>[];
      final actualPos = posMap[val]!;

      // --- Generate 1 VALID Rule (Fixed or Relative) ---
      final isRelative = _rng.nextDouble() < probRelative;

      if (isRelative) {
        // Pick a random target distinct from self
        final candidates = List.generate(n + 1, (i) => i)..remove(val);
        
        if (candidates.isEmpty) continue;

        final target = candidates[_rng.nextInt(candidates.length)];
        final targetPos = posMap[target]!;

        // True distance
        final diff = actualPos - targetPos;

        // Create a window around the true distance
        final start = diff - _rng.nextInt(strictness + 1);
        final end = diff + _rng.nextInt(strictness + 1);

        valRules.add(Rule(start, end, relativeTo: target));
      } else {
        // Fixed Rule
        final start = max(0, actualPos - _rng.nextInt(strictness + 1));
        final end = min(n, actualPos + _rng.nextInt(strictness + 1));
        valRules.add(Rule(start, end));
      }

      // --- Generate DECOY Rules (Optional) ---
      if (_rng.nextDouble() < 0.5) {
        if (_rng.nextDouble() < 0.5) {
          // Decoy Fixed
          final dStart = _rng.nextInt(n + 1);
          final dEnd = min(n, dStart + 5);
          valRules.add(Rule(dStart, dEnd));
        } else {
          // Decoy Relative
          final candidates = List.generate(n + 1, (i) => i)..remove(val);
          final dTarget = candidates[_rng.nextInt(candidates.length)];
          final dOff = _rng.nextInt(2 * n + 1) - n; // range -n to n
          valRules.add(Rule(dOff, dOff + 5, relativeTo: dTarget));
        }
      }

      valRules.shuffle(_rng);
      rules[val] = valRules;
    }

    return {'groundTruth': groundTruth, 'rules': rules};
  }
}

void main() {
  const int nVal = 200;

  // Generate test case (Uncomment to use generator)
  // final testData = TestGenerator.generateTestCaseRelative(nVal);
  // final Map<int, List<Rule>> myRules = testData['rules'];

  // Manual Override Example
  final Map<int, List<Rule>> myRules = {};

  // "0 must be at index 0-1 OR 2 spots behind 5"
  myRules[0] = [
    Rule(0, 1),
    Rule(-2, -2, relativeTo: 5)
  ];
  myRules[1] = [
    Rule(0, 1),
    Rule(-2, -2, relativeTo: 5)
  ];
  myRules[2] = [
    Rule(0, 1),
    Rule(-2, -2, relativeTo: 5)
  ];
  myRules[3] = [
    Rule(0, 2),
    Rule(-2, -2, relativeTo: 5)
  ];

  print("Solving for N=$nVal with ${myRules.length} constrained values...");
  
  final result = ConstrainedSortSolver.solve(nVal, myRules);

  if (result != null) {
    print("Valid result found.");
    final preview = result.length > 10 ? result.sublist(0, 10) : result;
    print("First 10 items: $preview");
  } else {
    print("No valid sorting exists.");
  }
}