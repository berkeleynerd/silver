module

public import Silver.StaticBooleanTailMeaning
public import Silver.StaticBooleanSourceChecks
public import Silver.PredicateConditionSound

@[expose] public section

namespace Silver.BooleanElaboration.Native

/-- The loop's recursive call decreases the remaining source span. The
source step already checks strict cursor progress. Its upper bound comes
from the called relation's result contract. -/
def runTail (relation : Reader) (text : Source) (frame : Compose.ParserState) (selected : Chain)
    (input : Result) : Result :=
  match tailStep modelImports relation text frame selected input with
  | .finished answer => answer
  | .next updated =>
    if _decrease : Predicate.remainingAt text updated.after < Predicate.remainingAt text input.after then
      runTail relation text frame selected updated
    else invalid
termination_by Predicate.remainingAt text input.after

private theorem step_bound {relation : Reader} {text frame selected input updated}
    (bound : ∀ start, start ≤ text.length + 1 → (relation text frame start).after ≤ text.length + 1)
    (inputBound : input.after ≤ text.length + 1)
    (step : tailStep modelImports relation text frame selected input = .next updated) :
    updated.after ≤ text.length + 1 := by
  obtain ⟨operator, _, _, _, update⟩ := tail_next_source step
  rw [update]
  exact bound _ (Predicate.chainAfter_bound text input.after operator inputBound)

theorem runTail_execution (relation : Reader) (text : Source) (frame : Compose.ParserState) (selected : Chain)
    (bound : ∀ start, start ≤ text.length + 1 → (relation text frame start).after ≤ text.length + 1)
    (input : Result) (inputBound : input.after ≤ text.length + 1) :
    TailExec modelImports relation text frame selected input (runTail relation text frame selected input) := by
  rw [runTail]
  split
  · rename_i stopped step; exact .finished step
  · rename_i updated step
    have nextBound := step_bound bound inputBound step
    have progress := tailStep_next_progress step
    have decreases : Predicate.remainingAt text updated.after < Predicate.remainingAt text input.after := by
      unfold Predicate.remainingAt
      omega
    rw [dite_eq_left decreases]
    exact .next step (runTail_execution relation text frame selected bound updated nextBound)
termination_by Predicate.remainingAt text input.after
decreasing_by assumption

def runCondition (relation : Reader) (text : Source) (frame : Compose.ParserState) (position : Nat) : Result :=
  let first := relation text frame position
  if first.after = 0 then invalid
  else runTail relation text frame (modelImports.chain text first.after) first

theorem runCondition_execution (relation : Reader) (text : Source) (frame : Compose.ParserState) (position : Nat)
    (positionBound : position ≤ text.length + 1)
    (bound : ∀ start, start ≤ text.length + 1 → (relation text frame start).after ≤ text.length + 1) :
    ConditionExec modelImports relation text frame position (runCondition relation text frame position) := by
  dsimp only [runCondition, ConditionExec]
  split
  · rfl
  · exact runTail_execution relation text frame _ bound _ (bound position positionBound)

theorem runCondition_native_result (tokens : List String) (source : SourceChecks.Checked tokens)
    (relation : Reader) (initial : Condition.Frame) (output : Result)
    (positionBound : initial.position ≤ initial.text.length + 1)
    (bound : ∀ start, start ≤ initial.text.length + 1 →
      (relation initial.text initial.state start).after ≤ initial.text.length + 1)
    (executed : Condition.BodyExec modelImports relation initial output) :
    output = runCondition relation initial.text initial.state initial.position :=
  ((source.condition_meaning modelImports relation initial output).2.mp executed).unique
    (runCondition_execution relation _ _ _ positionBound bound)

end Silver.BooleanElaboration.Native
