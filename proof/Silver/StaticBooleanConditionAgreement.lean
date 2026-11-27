module

public import Silver.StaticBooleanOperandEquations

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

private theorem chain_taken {text : Source} {position : Nat} {operator : Predicate.ChainKind}
    (read : Predicate.chainOperator text position = some operator) :
    Predicate.chainAfter text position operator ≠ 0 := by
  unfold Predicate.chainOperator at read
  split at read
  · split at read <;> cases read <;> assumption
  · split at read
    · split at read <;> cases read <;> assumption
    · split at read
      · cases read; assumption
      · cases read

private theorem step_agreement {text : Source} {frame : ParserState} {position : Nat}
    {left right : ReaderStage → Reader} (same : SmallerAgreement text frame .condition position left right)
    (selected : Chain) (input : Result) (origin : position ≤ input.after) (bounded : input.after ≤ text.length + 1) :
    tailStep modelImports (left .relation) text frame selected input =
      tailStep modelImports (right .relation) text frame selected input := by
  cases read : modelImports.chain text input.after with
  | none => simp only [tailStep, ite_eq_left read]
  | some operator =>
    have afterBound := Predicate.chainAfter_bound text input.after operator bounded
    have afterProgress := Predicate.Native.chainAfter_progress text input.after operator bounded (chain_taken read)
    have agrees := same .relation _ afterBound
      (stage_lower (by decide) (Nat.le_trans origin (Nat.le_of_lt afterProgress)))
    have start : modelImports.chainAfter text input.after (modelImports.chain text input.after) =
        Predicate.chainAfter text input.after operator := by rw [read]; rfl
    have operand : left .relation text frame (modelImports.chainAfter text input.after
        (modelImports.chain text input.after)) = right .relation text frame
        (modelImports.chainAfter text input.after (modelImports.chain text input.after)) := by
      rw [start]; exact agrees
    dsimp only [tailStep]
    rw [operand]

private theorem TailExec.transfer {text : Source} {frame : ParserState} {position : Nat}
    {left right : ReaderStage → Reader} (same : SmallerAgreement text frame .condition position left right)
    (bounds : BoundedReader (right .relation) text frame) {selected input output}
    (run : TailExec modelImports (right .relation) text frame selected input output)
    (origin : position ≤ input.after) (bounded : input.after ≤ text.length + 1) :
    TailExec modelImports (left .relation) text frame selected input output := by
  induction run with
  | finished step => exact .finished ((step_agreement same _ _ origin bounded).trans step)
  | @next input middle output step _ ih =>
    obtain ⟨operator, _, _, _, update⟩ := tail_next_source step
    have nextBound : middle.after ≤ text.length + 1 := by
      rw [update]
      exact BoundedResult.limit (bounds _ (Predicate.chainAfter_bound text input.after operator bounded))
    exact .next ((step_agreement same _ _ origin bounded).trans step)
      (ih (Nat.le_trans origin (Nat.le_of_lt (tailStep_next_progress step))) nextBound)

/-- A native finite execution and the closed relation chain agree when
their original recursive operand calls agree at the smaller source ranks.
Only the closed reader supplies the bounds used to transfer the chain. -/
theorem condition_execution_unique {text : Source} {frame : ParserState} {position : Nat} {a b : Result}
    {left right : ReaderStage → Reader} (bounded : position ≤ text.length + 1)
    (same : SmallerAgreement text frame .condition position left right)
    (bounds : BoundedReader (right .relation) text frame)
    (actual : ConditionExec modelImports (left .relation) text frame position a)
    (model : ConditionExec modelImports (right .relation) text frame position b) : a = b := by
  have first := same .relation position bounded (stage_lower (by decide) (Nat.le_refl position))
  dsimp only [ConditionExec] at actual model
  rw [first] at actual
  by_cases missing : (right .relation text frame position).after = 0
  · rw [ite_eq_left missing] at actual model
    exact actual.trans model.symm
  · rw [ite_eq_right missing] at actual model
    have source := bounds position bounded missing
    exact actual.unique (TailExec.transfer same bounds model (Nat.le_of_lt source.1) source.2)

theorem closed_stage_equation (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat)
    (bounded : position ≤ text.length + 1) :
    closedReader stage text frame position = stageStep stage closedReader text frame position := by
  change stageResult text frame stage position = _
  rw [stage_equation]
  have agrees := child_agreement text frame stage position
  cases stage with
  | primary => exact primary_congr bounded agrees
  | factor => exact factor_congr bounded agrees
  | relation => exact relation_congr bounded agrees (closedReader_bounds text frame .factor)
  | condition =>
    have model := closedReader_bounds text frame .relation
    have localBounds := child_bounded text frame .condition .relation position
    exact condition_execution_unique bounded agrees model
      (runCondition_execution _ text frame position bounded
        (fun start limit => BoundedResult.limit (localBounds start limit)))
      (runCondition_execution _ text frame position bounded
        (fun start limit => BoundedResult.limit (model start limit)))

end Silver.BooleanElaboration.Native
