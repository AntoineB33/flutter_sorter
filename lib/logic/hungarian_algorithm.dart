import 'dart:math';


class HungarianAlgorithm {
  final List<List<int>> costMatrix;
  late int dim;
  late List<int> labelX;
  late List<int> labelY;
  late List<int> matchY; // matchY[j] = i means j is matched with i
  late List<int> matchX; // matchX[i] = j means i is matched with j
  late List<int> slack;
  late List<bool> visX;
  late List<bool> visY;

  HungarianAlgorithm(this.costMatrix);

  /// Solves the assignment problem and returns the Result object
  AssignmentResult compute() {
    int n = costMatrix.length;
    int m = costMatrix[0].length;
    
    // The algorithm requires a square matrix. 
    // If A and B have different sizes, we pad with 0s.
    dim = max(n, m);
    
    // Initialize mapping arrays
    labelX = List.filled(dim, 0);
    labelY = List.filled(dim, 0);
    matchY = List.filled(dim, -1);
    matchX = List.filled(dim, -1);
    slack = List.filled(dim, 0);
    visX = List.filled(dim, false);
    visY = List.filled(dim, false);

    // Initialize labels for X with max weight in each row
    for (int i = 0; i < n; i++) {
      int maxVal = -1 >>> 1; // Very small number
      for (int j = 0; j < m; j++) {
         if (costMatrix[i][j] > maxVal) maxVal = costMatrix[i][j];
      }
      // Handle case where row might be empty or all negative
      labelX[i] = maxVal == (-1 >>> 1) ? 0 : maxVal;
    }

    // Main algorithm loop
    for (int i = 0; i < dim; i++) {
      // Reset slack
      slack.fillRange(0, dim, 999999999); // Infinity
      
      while (true) {
        visX.fillRange(0, dim, false);
        visY.fillRange(0, dim, false);
        
        if (dfs(i, n, m)) break; // Found a path

        // If no path, update labels (re-weighting)
        int d = 999999999;
        for (int j = 0; j < dim; j++) {
          if (!visY[j]) d = min(d, slack[j]);
        }

        if (d == 999999999) break; // Should not happen if solvable

        for (int k = 0; k < dim; k++) {
          if (visX[k]) labelX[k] -= d;
          if (visY[k]) labelY[k] += d;
          else slack[k] -= d;
        }
      }
    }

    // Compile results
    int totalWeight = 0;
    List<int> assignment = [];
    
    for (int i = 0; i < n; i++) {
      int matchedJ = matchX[i];
      // Only count valid matches within original bounds
      if (matchedJ != -1 && matchedJ < m) {
        totalWeight += costMatrix[i][matchedJ];
        assignment.add(matchedJ);
      } else {
        // Should not happen if n <= m, but handles edge cases
        assignment.add(-1); 
      }
    }

    return AssignmentResult(totalWeight, assignment);
  }

  bool dfs(int x, int n, int m) {
    visX[x] = true;
    for (int y = 0; y < dim; y++) {
      if (visY[y]) continue;
      
      int weight = (x < n && y < m) ? costMatrix[x][y] : 0;
      int gap = labelX[x] + labelY[y] - weight;

      if (gap == 0) {
        visY[y] = true;
        if (matchY[y] == -1 || dfs(matchY[y], n, m)) {
          matchY[y] = x;
          matchX[x] = y;
          return true;
        }
      } else {
        slack[y] = min(slack[y], gap);
      }
    }
    return false;
  }
}

class AssignmentResult {
  final int maxWeight;
  /// assign[i] = j means row i is assigned to column j
  final List<int> assignments; 

  AssignmentResult(this.maxWeight, this.assignments);
}
