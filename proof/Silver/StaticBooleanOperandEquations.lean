module

public import Silver.StaticBooleanRecursion

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose Compose.Expressions

def childReader (text : Source) (frame : ParserState) (parent : ReaderStage) (position : Nat)
    (child : ReaderStage) : Reader := fun _ _ start =>
  if child.measure text start < parent.measure text position then stageResult text frame child start else invalid

theorem stage_equation (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat) :
    stageResult text frame stage position = stageStep stage (childReader text frame stage position) text frame position := by
  rw [stageResult]
  rfl

theorem child_bounded (text : Source) (frame : ParserState) (parent child : ReaderStage) (origin : Nat) :
    BoundedReader (childReader text frame parent origin child) text frame := by
  intro position bounded
  unfold childReader
  split
  · exact closedReader_bounds text frame child position bounded
  · exact fun present => False.elim (present rfl)

theorem child_eq (text : Source) (frame : ParserState) (parent child : ReaderStage) (position start : Nat)
    (decreases : child.measure text start < parent.measure text position) :
    childReader text frame parent position child text frame start = closedReader child text frame start :=
  ite_eq_left decreases

/-- Only recursive calls reachable at a smaller original source variant may be
used to identify two sets of readers. The frame and source stay fixed. -/
abbrev SmallerAgreement (text : Source) (frame : ParserState) (parent : ReaderStage) (position : Nat)
    (left right : ReaderStage → Reader) : Prop :=
  ∀ child start, start ≤ text.length + 1 → child.measure text start < parent.measure text position →
    left child text frame start = right child text frame start

theorem child_agreement (text : Source) (frame : ParserState) (parent : ReaderStage) (position : Nat) :
    SmallerAgreement text frame parent position (childReader text frame parent position) closedReader :=
  fun child start _ decreases => child_eq text frame parent child position start decreases

theorem primary_congr {text : Source} {frame : ParserState} {position : Nat} {left right : ReaderStage → Reader}
    (bounded : position ≤ text.length + 1) (same : SmallerAgreement text frame .primary position left right) :
    stageStep .primary left text frame position = stageStep .primary right text frame position := by
  dsimp only [stageStep, primaryStep]
  by_cases opened : modelImports.take text position .leftParenthesis ≠ 0
  · have afterBound := model_fixed_valid text position "(" false bounded
    have operand := same .condition _ afterBound
      (stage_forward _ _ (model_fixed_advances text position "(" false bounded (by decide) opened) afterBound)
    change left .condition text frame (modelImports.take text position .leftParenthesis) =
      right .condition text frame (modelImports.take text position .leftParenthesis) at operand
    rw [operand]
  · simp only [ite_eq_right opened]

theorem factor_congr {text : Source} {frame : ParserState} {position : Nat} {left right : ReaderStage → Reader}
    (bounded : position ≤ text.length + 1) (same : SmallerAgreement text frame .factor position left right) :
    stageStep .factor left text frame position = stageStep .factor right text frame position := by
  let negated := fixedAfter text position "not" true
  let start := if negated = 0 then position else negated
  have window : position ≤ start ∧ start ≤ text.length + 1 := by
    dsimp only [start]; split
    · exact ⟨Nat.le_refl _, bounded⟩
    · rename_i present
      exact ⟨Nat.le_of_lt (model_fixed_advances text position "not" true bounded (by decide) present),
        model_fixed_valid text position "not" true bounded⟩
  have operand := same .primary start window.2 (stage_lower (by decide) window.1)
  exact congrArg (fun result : Result => if negated ≠ 0 then {result with value := !result.value} else result) operand

theorem relation_congr {text : Source} {frame : ParserState} {position : Nat} {left right : ReaderStage → Reader}
    (bounded : position ≤ text.length + 1) (same : SmallerAgreement text frame .relation position left right)
    (factorBound : BoundedReader (right .factor) text frame) :
    stageStep .relation left text frame position = stageStep .relation right text frame position := by
  have first := same .factor position bounded (stage_lower (by decide) (Nat.le_refl position))
  dsimp only [stageStep, relationStep, modelImports]
  rw [first]
  by_cases missing : (right .factor text frame position).after = 0
  · rw [missing] <;> rfl
  · have window := factorBound position bounded missing
    by_cases absent : (Predicate.comparisonAt text (right .factor text frame position).after).after = 0
    · rw [absent] <;> rfl
    · have progress := Predicate.Native.comparison_progress text _ window.2 absent
      have rightBound := Predicate.comparison_bound text _ window.2
      have second := same .factor _ rightBound (stage_forward _ _ (Nat.lt_trans window.1 progress) rightBound)
      rw [second]

end Silver.BooleanElaboration.Native
