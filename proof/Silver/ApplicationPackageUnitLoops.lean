module

public import Silver.ApplicationPackageUnitEquations

@[expose] public section

/-! Exact full-loop equations use the checked complete loop bodies, rather than
unfolding a fresh copy of their state substitutions at every iteration. -/
namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def objectTest (calls : UnitCalls) (locals : Locals) : Bool :=
  decide (calls.takeToken (locals .source "text") (locals .state "globals").position (.word "function") = 0) &&
    decide (calls.takeToken (locals .source "text") (locals .state "globals").position (.word "procedure") = 0) &&
    decide (calls.takeToken (locals .source "text") (locals .state "globals").position (.word "end") = 0)

def routineTest (locals : Locals) : Bool :=
  decide ((locals .metadata "info").completed < (locals .metadata "info").routines.length)

def objectLoop (calls : UnitCalls) (fuel : Nat) (locals : Locals) : Option Outcome :=
  whileLocals (objectTest calls) (fun current => some (objectStep calls current)) fuel locals

def routineLoop (calls : UnitCalls) (fuel : Nat) (locals : Locals) : Option Outcome :=
  whileLocals routineTest (fun current => some (routineStep calls current)) fuel locals

theorem objectLoop_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    (ApplicationPackageProcedure.Command.whileLoop objectLoopTest objectLoopBody).eval
      (modelFunctions calls) (modelProcedures calls) fuel locals = objectLoop calls fuel locals := by
  change whileLocals (objectLoopTest.eval (modelFunctions calls))
    (objectLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel) fuel locals = _
  have test : objectLoopTest.eval (modelFunctions calls) = objectTest calls := rfl
  have body : objectLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel =
      (fun current => some (objectStep calls current)) := funext (objectLoopBody_meaning calls fuel)
  rw [test, body]
  rfl

theorem routineLoop_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    (ApplicationPackageProcedure.Command.whileLoop
      (.lt (.field .infoCompleted info) (.field .routineCount info)) routineLoopBody).eval
      (modelFunctions calls) (modelProcedures calls) fuel locals = routineLoop calls fuel locals := by
  change whileLocals ((Expr.lt (.field .infoCompleted info) (.field .routineCount info)).eval (modelFunctions calls))
    (routineLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel) fuel locals = _
  have test : (Expr.lt (.field .infoCompleted info) (.field .routineCount info)).eval (modelFunctions calls) =
      routineTest := rfl
  have body : routineLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel =
      (fun current => some (routineStep calls current)) := funext (routineLoopBody_meaning calls fuel)
  rw [test, body]
  rfl

theorem objectStep_preserves_text (calls : UnitCalls) (locals : Locals) :
    (objectStep calls locals).locals .source "text" = locals .source "text" := by
  dsimp only [objectStep]
  split
  · rfl
  · split <;> simp [Locals.set]

theorem objectStep_preserves_accepted (calls : UnitCalls) (locals : Locals) :
    (objectStep calls locals).locals .truth "accepted" = locals .truth "accepted" := by
  dsimp only [objectStep]
  split
  · rfl
  · split <;> simp [Locals.set]

theorem routineStep_preserves_text (calls : UnitCalls) (locals : Locals) :
    (routineStep calls locals).locals .source "text" = locals .source "text" := by
  simp [routineStep, Locals.set]

theorem routineStep_preserves_accepted (calls : UnitCalls) (locals : Locals) :
    (routineStep calls locals).locals .truth "accepted" = locals .truth "accepted" := by
  simp [routineStep, Locals.set]

theorem objectStep_progress (calls : UnitCalls) (locals : Locals)
    (continued : (objectStep calls locals).returned = false) :
    (locals .state "globals").position < ((objectStep calls locals).locals .state "globals").position := by
  dsimp only [objectStep] at continued ⊢
  split at continued
  · contradiction
  · rename_i room
    split at continued
    · contradiction
    · rename_i accepted
      simp only [room, ↓reduceIte, accepted]
      simp only [Locals.set_get_same]
      omega

theorem routineStep_progress (calls : UnitCalls) (locals : Locals)
    (continued : (routineStep calls locals).returned = false) :
    (locals .state "globals").position < ((routineStep calls locals).locals .state "globals").position := by
  have progress : ¬ (calls.completionAt (locals .source "text") (locals .state "globals")
      (locals .metadata "info")).globals.position ≤ (locals .state "globals").position := by
    simpa only [routineStep, decide_eq_false_iff_not] using continued
  simp only [routineStep, Locals.set_get_other_type _ .metadata .state "info" "globals" _ (by decide),
    Locals.set_get_same]
  omega

end Silver.ApplicationPackageUnit.Native
