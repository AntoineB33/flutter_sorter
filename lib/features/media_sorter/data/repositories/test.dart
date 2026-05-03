// ---------------------------------------------------------
// 1. Define Numbers as Types (Peano Arithmetic)
// ---------------------------------------------------------
sealed class Nat {}
class Z extends Nat {}           // Represents 0
class S<N extends Nat> extends Nat {} // Represents N + 1 (Successor)

// ---------------------------------------------------------
// 2. Phase 1: Counting Up
// ---------------------------------------------------------
class Phase1<N extends Nat> {
  // Every time we call 'doA', we wrap the current type N in an S<N>.
  // This increments our compile-time counter.
  Phase1<S<N>> doA() {
    print('Executing A...');
    return Phase1<S<N>>();
  }

  // Lock in the count and move to the second phase.
  Phase2<N> transition() {
    print('--- Transitioning to Phase 2 ---');
    return Phase2<N>();
  }
}

// ---------------------------------------------------------
// 3. Phase 2: Base Class
// ---------------------------------------------------------
class Phase2<N extends Nat> {}

// ---------------------------------------------------------
// 4. Phase 2: Counting Down (The Magic)
// ---------------------------------------------------------
// This extension ONLY applies if N is greater than 0 (i.e., S<Prev>).
// It "unwraps" one layer of S, effectively decrementing the counter.
extension Phase2Decrement<Prev extends Nat> on Phase2<S<Prev>> {
  Phase2<Prev> doB() {
    print('Executing B...');
    return Phase2<Prev>();
  }
}

// ---------------------------------------------------------
// 5. Enforcing the End State
// ---------------------------------------------------------
// The 'finish' method ONLY exists if the counter has reached exactly 0.
extension Phase2End on Phase2<Z> {
  void finish() {
    print('Finished successfully! Both counts matched.');
  }
}

void main() {
  // 1. Start the process
  final step0 = Phase1<Z>();
  
  // 2. Do some other logic here...
  print('Doing unrelated work...');

  // 3. Capture the new type in a new variable
  final step1 = step0.doA(); // step1 is strictly Phase1<S<Z>>
  final step2 = step1.doA(); // step2 is strictly Phase1<S<S<Z>>>

  // ❌ THIS WILL FAIL TO COMPILE:
  // var myState = Phase1<Z>();
  // myState = myState.doA(); 
  // Error: A value of type 'Phase1<S<Z>>' can't be assigned to a variable of type 'Phase1<Z>'.

  // 4. Transition when ready
  final p2 = step2.transition();

  // 5. Unwind later
  final unwind1 = p2.doB();
  final unwind2 = unwind1.doB();
  
  unwind2.finish();
}