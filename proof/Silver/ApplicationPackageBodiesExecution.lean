module

public import Silver.ApplicationPackageBodiesUnit

@[expose] public section

/-! Finite control execution for package local declarations and body units.
Fuel is a proof evaluator bound, not a new accepted-source limit. Complete
callee contracts supply bounded cursors and preservation; progress is derived
from the actual returning guards. -/
namespace Silver.ApplicationPackageBodies
open Compose

inductive LocalExecution (step : InitializationFrame → LocalStep) :
    InitializationFrame → Option InitializationFrame → Prop
  | failed {state} : step state = .failed → LocalExecution step state none
  | finished {state result} : step state = .finished result → LocalExecution step state (some result)
  | continued {state next result} : step state = .continued next → LocalExecution step next result →
      LocalExecution step state result

theorem localsFuel_sound {step : InitializationFrame → LocalStep} {fuel : Nat}
    {state : InitializationFrame} {result : Option InitializationFrame}
    (found : localsFuel step fuel state = some result) : LocalExecution step state result := by
  induction fuel generalizing state with
  | zero => simp only [localsFuel, reduceCtorEq] at found
  | succ fuel induction =>
      simp only [localsFuel] at found
      split at found
      · rename_i failed
        cases found
        exact .failed failed
      · rename_i result selected
        cases found
        exact .finished selected
      · rename_i next selected
        exact .continued selected (induction found)

theorem LocalExecution.unique {step : InitializationFrame → LocalStep} {state : InitializationFrame}
    {first second : Option InitializationFrame}
    (left : LocalExecution step state first) (right : LocalExecution step state second) : first = second := by
  induction left with
  | failed selected =>
      cases right with
      | failed => rfl
      | finished other => simp only [selected, reduceCtorEq] at other
      | continued other _ => simp only [selected, reduceCtorEq] at other
  | finished selected =>
      cases right with
      | failed other => simp only [selected, reduceCtorEq] at other
      | finished other =>
          exact congrArg some (LocalStep.finished.inj (selected.symm.trans other))
      | continued other _ => simp only [selected, reduceCtorEq] at other
  | continued selected _ induction =>
      cases right with
      | failed other => simp only [selected, reduceCtorEq] at other
      | finished other => simp only [selected, reduceCtorEq] at other
      | continued other rest =>
          have same := LocalStep.continued.inj (selected.symm.trans other)
          subst same
          exact induction rest

theorem localStep_progress {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {before after : InitializationFrame}
    (continued : localStep calls text info item before = .continued after) :
    before.frame.position < after.frame.position := by
  unfold localStep at continued
  split at continued
  · contradiction
  · dsimp only at continued
    split at continued
    · contradiction
    · split at continued
      · contradiction
      · cases continued
        dsimp only
        omega

theorem localsFuel_total {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {valid : InitializationFrame → Prop} {limit : Nat}
    (bounded : ∀ state, valid state → state.frame.position ≤ limit)
    (preserved : ∀ state next, valid state → localStep calls text info item state = .continued next → valid next)
    {state : InitializationFrame} (legal : valid state) {fuel : Nat}
    (enough : limit - state.frame.position + 1 ≤ fuel) :
    ∃ result, localsFuel (localStep calls text info item) fuel state = some result := by
  induction fuel generalizing state with
  | zero => omega
  | succ fuel induction =>
      simp only [localsFuel]
      split
      · exact ⟨none, rfl⟩
      · exact ⟨some _, rfl⟩
      · rename_i next continued
        have nextValid := preserved state next legal continued
        apply induction nextValid
        have advancement := localStep_progress continued
        have before := bounded state legal
        have after := bounded next nextValid
        omega

inductive UnitExecution (step : UnitState → UnitStep) : UnitState → ApplicationAdmission.BodyResult → Prop
  | returned {state result} : step state = .returned result → UnitExecution step state result
  | continued {state next result} : step state = .continued next → UnitExecution step next result →
      UnitExecution step state result

theorem unitFuel_sound {step : UnitState → UnitStep} {fuel : Nat} {state : UnitState}
    {result : ApplicationAdmission.BodyResult} (found : unitFuel step fuel state = some result) :
    UnitExecution step state result := by
  induction fuel generalizing state with
  | zero => simp only [unitFuel, reduceCtorEq] at found
  | succ fuel induction =>
      simp only [unitFuel] at found
      split at found
      · rename_i result selected
        cases found
        exact .returned selected
      · rename_i next selected
        exact .continued selected (induction found)

theorem UnitExecution.unique {step : UnitState → UnitStep} {state : UnitState}
    {first second : ApplicationAdmission.BodyResult}
    (left : UnitExecution step state first) (right : UnitExecution step state second) : first = second := by
  induction left with
  | returned selected =>
      cases right with
      | returned other => exact UnitStep.returned.inj (selected.symm.trans other)
      | continued other _ => simp only [selected, reduceCtorEq] at other
  | continued selected _ induction =>
      cases right with
      | returned other => simp only [selected, reduceCtorEq] at other
      | continued other rest =>
          have same := UnitStep.continued.inj (selected.symm.trans other)
          subst same
          exact induction rest

end Silver.ApplicationPackageBodies
