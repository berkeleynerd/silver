module

public import Silver.StaticBooleanConditionAgreement

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

/-- Executions of the four original typed bodies with the lexical and scalar
imports interpreted. Recursive calls use the same reader family throughout. -/
structure BodyReads (readers : ReaderStage → Reader) : Prop where
  primary (text frame position) : SourceChecks.Domain text frame position →
    readers .primary text frame position =
      primaryBody.eval modelImports ⟨readers .condition, readers .primary⟩ text frame position
  factor (text frame position) : SourceChecks.Domain text frame position →
    readers .factor text frame position =
      factorBody.eval modelImports ⟨readers .condition, readers .primary⟩ text frame position
  relation (initial : Relation.Frame) : SourceChecks.Domain initial.text initial.state initial.position →
    readers .relation initial.text initial.state initial.position = Relation.eval modelImports (readers .factor) initial
  condition (initial : Condition.Frame) : SourceChecks.Domain initial.text initial.state initial.position →
    Condition.BodyExec modelImports (readers .relation) initial
      (readers .condition initial.text initial.state initial.position)

theorem closed_body_reads (tokens : List String) (source : SourceChecks.Checked tokens) : BodyReads closedReader where
  primary text frame position domain :=
    (closed_stage_equation text frame .primary position domain.cursor).trans
      ((source.primary_meaning modelImports ⟨closedReader .condition, closedReader .primary⟩ text frame position).2.symm)
  factor text frame position domain :=
    (closed_stage_equation text frame .factor position domain.cursor).trans
      ((source.factor_meaning modelImports ⟨closedReader .condition, closedReader .primary⟩ text frame position).2.symm)
  relation initial domain :=
    (closed_stage_equation initial.text initial.state .relation initial.position domain.cursor).trans
      ((source.relation_meaning modelImports (closedReader .factor) initial).2.symm)
  condition initial domain := by
    apply (source.condition_meaning modelImports (closedReader .relation) initial _).2.mpr
    rw [closed_stage_equation initial.text initial.state .condition initial.position domain.cursor]
    exact runCondition_execution _ _ _ _ domain.cursor
      (fun start limit => BoundedResult.limit (closedReader_bounds initial.text initial.state .relation start limit))

/-- The native source variant uniquely determines each complete result. The
original reader family has no assumed equality with the closed model. -/
theorem BodyReads.determined {readers : ReaderStage → Reader} (bodies : BodyReads readers)
    {tokens : List String} (source : SourceChecks.Checked tokens) (text : Source) (frame : ParserState)
    (stage : ReaderStage) (position : Nat) (domain : SourceChecks.Domain text frame position) :
    readers stage text frame position = closedReader stage text frame position := by
  have same : SmallerAgreement text frame stage position readers closedReader := by
    intro child start within decreases
    exact bodies.determined source text frame child start {domain with cursor := within}
  have target := closed_stage_equation text frame stage position domain.cursor
  cases stage with
  | primary =>
    exact (bodies.primary _ _ _ domain).trans
      (((source.primary_meaning modelImports ⟨readers .condition, readers .primary⟩ _ _ _).2).trans
        ((primary_congr domain.cursor same).trans target.symm))
  | factor =>
    exact (bodies.factor _ _ _ domain).trans
      (((source.factor_meaning modelImports ⟨readers .condition, readers .primary⟩ _ _ _).2).trans
        ((factor_congr domain.cursor same).trans target.symm))
  | relation =>
    let initial : Relation.Frame :=
      ⟨text, frame, position, fun _ => ScalarExpression.invalid, fun _ => invalid, fun _ => ⟨0, .eq⟩⟩
    exact (bodies.relation initial domain).trans
      (((source.relation_meaning modelImports (readers .factor) initial).2).trans
        ((relation_congr domain.cursor same (closedReader_bounds text frame .factor)).trans target.symm))
  | condition =>
    let initial : Condition.Frame := ⟨text, frame, position, invalid, invalid, none, none⟩
    have executed := (source.condition_meaning modelImports (readers .relation) initial _).2.mp
      (bodies.condition initial domain)
    have native := (source.condition_meaning modelImports (closedReader .relation) initial _).2.mp
      ((closed_body_reads tokens source).condition initial domain)
    exact condition_execution_unique domain.cursor same (closedReader_bounds text frame .relation) executed native
termination_by stage.measure text position
decreasing_by assumption

end Silver.BooleanElaboration.Native
