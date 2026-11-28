module

public import Silver.StaticBooleanOperandBounds

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

inductive ReaderStage | primary | factor | relation | condition
  deriving DecidableEq

def ReaderStage.rank : ReaderStage → Nat
  | .primary => 1
  | .factor => 2
  | .relation => 3
  | .condition => 4

def ReaderStage.measure (stage : ReaderStage) (text : Source) (position : Nat) : Nat :=
  Predicate.remainingAt text position * 4 + stage.rank

def stageStep (stage : ReaderStage) (children : ReaderStage → Reader) : Reader :=
  match stage with
  | .primary => primaryStep modelImports (children .condition)
  | .factor => factorStep modelImports (children .primary)
  | .relation => relationStep modelImports (children .factor)
  | .condition => runCondition (children .relation)

/-- The shared recursion measure is the native remaining source span followed
by the four source ranks. Closed equations discharge the decrease guard at
every position where the typed bodies invoke a child. -/
def stageResult (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat) : Result :=
  stageStep stage (fun child _ _ start =>
    if _smaller : child.measure text start < stage.measure text position then
      stageResult text frame child start else invalid) text frame position
termination_by stage.measure text position

def closedReader (stage : ReaderStage) : Reader := fun text frame position => stageResult text frame stage position

private theorem stage_bounds (stage : ReaderStage) (children : ReaderStage → Reader) {text : Source}
    {frame : ParserState} {position} (limit : position ≤ text.length + 1)
    (bounded : ∀ child, BoundedReader (children child) text frame) :
    BoundedResult text position (stageStep stage children text frame position) := by
  cases stage with
  | primary => exact primary_bounds limit (bounded _)
  | factor => exact factor_bounds limit (bounded _)
  | relation => exact relation_bounds limit (bounded _)
  | condition => exact condition_bounds limit (bounded _)

theorem closedReader_bounds (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat)
    (limit : position ≤ text.length + 1) : BoundedResult text position (stageResult text frame stage position) := by
  rw [stageResult]
  apply stage_bounds _ _ limit
  intro child start bound
  dsimp only
  split
  · exact closedReader_bounds text frame child start bound
  · exact fun present => False.elim (present rfl)
termination_by stage.measure text position
decreasing_by assumption

theorem stage_rank_bounds (stage : ReaderStage) : 0 < stage.rank ∧ stage.rank ≤ 4 := by
  cases stage <;> decide

theorem stage_forward {text : Source} {position start : Nat} (parent child : ReaderStage)
    (advanced : position < start) (bounded : start ≤ text.length + 1) :
    child.measure text start < parent.measure text position := by
  have childRank := stage_rank_bounds child
  have parentRank := stage_rank_bounds parent
  unfold ReaderStage.measure Predicate.remainingAt
  omega

theorem stage_lower {text : Source} {position start : Nat} {parent child : ReaderStage}
    (order : child.rank < parent.rank) (forward : position ≤ start) :
    child.measure text start < parent.measure text position := by
  unfold ReaderStage.measure Predicate.remainingAt
  omega

end Silver.BooleanElaboration.Native
