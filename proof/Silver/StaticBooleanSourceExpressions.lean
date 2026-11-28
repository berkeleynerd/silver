module

public import Silver.StaticBooleanReaderDefinitions
public import Silver.StaticBooleanPrimaryMeaning
public import Silver.StaticBooleanRelationMeaning

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

def ConditionAt (text : Source) (operand : Nat → Predicate.Condition → Nat → Prop)
    (position : Nat) (expression : Predicate.Condition) (after : Nat) : Prop :=
  ∃ first middle, operand position first middle ∧
    ChainAt text operand (Predicate.chainOperator text middle) first middle expression after

/-- A finite derivation of the source grammar. Chains retain their actual operator
and every operand span. The public reading admits any finite derivation height. -/
def atDepth (text : Source) (frame : ParserState) : Nat → ReaderStage →
    Nat → Predicate.Condition → Nat → Prop
  | 0, _ => fun _ _ _ => False
  | depth + 1, .primary => PrimaryAt text frame (atDepth text frame depth .condition)
  | depth + 1, .factor => FactorAt text (atDepth text frame depth .primary)
  | depth + 1, .relation => RelationAt text frame (atDepth text frame depth .factor)
  | depth + 1, .condition => ConditionAt text (atDepth text frame depth .relation)

def ExpressionAt (text : Source) (frame : ParserState) (stage : ReaderStage)
    (position : Nat) (expression : Predicate.Condition) (after : Nat) : Prop :=
  ∃ depth, atDepth text frame depth stage position expression after

private theorem condition_exact {relation : Reader} {text : Source} {frame : ParserState}
    {position : Nat} {output : Result} (operandAt : Nat → Predicate.Condition → Nat → Prop)
    (operand : ∀ start, (relation text frame start).after ≠ 0 →
      ExactAt operandAt frame start (relation text frame start))
    (run : ConditionExec modelImports relation text frame position output) (accepted : output.after ≠ 0) :
    ExactAt (ConditionAt text operandAt) frame position output := by
  dsimp only [ConditionExec] at run
  split at run
  · exact False.elim (accepted (congrArg Result.after run))
  · rename_i firstPresent
    obtain ⟨head, read, value⟩ := operand position firstPresent
    obtain ⟨final, chain, finalValue⟩ := run.exact_source operandAt operand head value accepted
    exact ⟨final, ⟨head, _, read, chain⟩, finalValue⟩

private def syntaxChild (text : Source) (frame : ParserState) (parent : ReaderStage) (origin : Nat)
    (child : ReaderStage) : Reader := fun _ _ start =>
  if start ≤ text.length + 1 ∧ child.measure text start < parent.measure text origin then
    closedReader child text frame start
  else invalid

private theorem syntaxChild_bounds (text : Source) (frame : ParserState) (parent child : ReaderStage)
    (origin : Nat) : BoundedReader (syntaxChild text frame parent origin child) text frame := by
  intro start within
  dsimp only [syntaxChild]
  split
  · exact closedReader_bounds text frame child start within
  · exact fun present => False.elim (present rfl)

private theorem syntax_equation (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat)
    (bounded : position ≤ text.length + 1) :
    stageStep stage (syntaxChild text frame stage position) text frame position = closedReader stage text frame position := by
  rw [closed_stage_equation text frame stage position bounded]
  have same : SmallerAgreement text frame stage position (syntaxChild text frame stage position) closedReader :=
    fun _ _ within decreases => ite_eq_left ⟨within, decreases⟩
  cases stage with
  | primary => exact primary_congr bounded same
  | factor => exact factor_congr bounded same
  | relation => exact relation_congr bounded same (closedReader_bounds text frame .factor)
  | condition =>
    have model := closedReader_bounds text frame .relation
    have localBounds := syntaxChild_bounds text frame .condition .relation position
    exact condition_execution_unique bounded same model
      (runCondition_execution _ text frame position bounded (fun start within => (localBounds start within).limit))
      (runCondition_execution _ text frame position bounded (fun start within => (model start within).limit))

private theorem expression_depth (text : Source) (frame : ParserState) (depth : Nat)
    (stage : ReaderStage) (position : Nat) (within : position ≤ text.length + 1)
    (enough : stage.measure text position < depth) (accepted : (closedReader stage text frame position).after ≠ 0) :
    ExactAt (atDepth text frame depth stage) frame position (closedReader stage text frame position) := by
  cases depth with
  | zero => omega
  | succ depth =>
    have smaller (child : ReaderStage) (start : Nat)
        (present : (syntaxChild text frame stage position child text frame start).after ≠ 0) :
        ExactAt (atDepth text frame depth child) frame start (syntaxChild text frame stage position child text frame start) := by
      dsimp only [syntaxChild] at present ⊢
      split at present
      · rename_i guard
        rw [ite_eq_left guard]
        exact expression_depth text frame depth child start guard.1
          (Nat.lt_of_lt_of_le guard.2 (Nat.le_of_lt_succ enough)) present
      · exact False.elim (present rfl)
    rw [← syntax_equation text frame stage position within] at accepted ⊢
    cases stage with
    | primary => exact primary_exact within _ (smaller .condition) accepted
    | factor => exact factor_exact _ (smaller .primary) accepted
    | relation => exact relation_exact within _ (smaller .factor) accepted
    | condition =>
      have bounds := syntaxChild_bounds text frame .condition .relation position
      exact condition_exact _ (smaller .relation)
        (runCondition_execution _ text frame position within (fun start limit => (bounds start limit).limit)) accepted
termination_by depth

theorem closedReader_source (text : Source) (frame : ParserState) (stage : ReaderStage) (position : Nat)
    (within : position ≤ text.length + 1) (present : (closedReader stage text frame position).after ≠ 0) :
    ExactAt (ExpressionAt text frame stage) frame position (closedReader stage text frame position) := by
  obtain ⟨expression, source, value⟩ := expression_depth text frame (stage.measure text position + 1)
    stage position within (Nat.lt_succ_self _) present
  exact ⟨expression, ⟨_, source⟩, value⟩

theorem BodyReads.source_expression {readers : ReaderStage → Reader} (bodies : BodyReads readers)
    {tokens : List String} (source : SourceChecks.Checked tokens) (text : Source) (frame : ParserState)
    (stage : ReaderStage) (position : Nat) (domain : SourceChecks.Domain text frame position)
    (present : (readers stage text frame position).after ≠ 0) :
    ExactAt (ExpressionAt text frame stage) frame position (readers stage text frame position) := by
  rw [bodies.determined source text frame stage position domain] at present ⊢
  exact closedReader_source text frame stage position domain.cursor present

end Silver.BooleanElaboration.Native
