module

public import Silver.SequenceSourceBridge
public import Silver.SequenceMain
public import Silver.Current

@[expose] public section

/-! The native scanner's source interpretation and proved wrapper contracts
compose with grammar, execution and obligation theorems. The external tool
contract remains explicit; no observed solver run defines language membership. -/

namespace Silver.Sequence.SourceBridge
open Silver.Sequence.Expressions

theorem executable_membership (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    admit text = true ↔ Member text := by
  rw [(executable_correspondence calls source admit arguments assignment output refinement text).1]
  exact accepts_iff_member text

theorem executable_selectors (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} {program : Program} (meaning : SourceMeaning text program) :
    arguments text = program.body.shell.hasArguments ∧
      assignment text = program.body.hasAssignment ∧ output text = program.body.hasOutput := by
  have selectors := (executable_correspondence calls source admit arguments assignment output refinement text).2
  have decoded := meaning_selectors meaning
  exact ⟨selectors.1.trans decoded.1, selectors.2.1.trans decoded.2.1,
    selectors.2.2.trans decoded.2.2⟩

/-- An admitted native source has the same ordered token reading, initialized
store, checked execution, report selectors and complete returning-call outcomes.
The arithmetic obligations are discharged for that same decoded program. -/
theorem executable_main_correct (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} (accepted : admit text = true) :
    ∃ program, SourceMeaning text program ∧ MainReading text program ∧ program.Valid ∧
      (∀ argv, program.checkedExecute argv = some (program.execute argv)) ∧
      arguments text = program.body.shell.hasArguments ∧
      assignment text = program.body.hasAssignment ∧ output text = program.body.hasOutput ∧
      Semantics.discharge (Current.obligations (.sequence program)) = true ∧
      ∀ environment, SpecifiedOutcome environment program (execute environment program) ∧
        (execute environment program).accepted.length ≤
          outputCount (program.effects environment.arguments) * (maxSourceLength + 1) := by
  have member := (executable_membership calls source admit arguments assignment output refinement text).mp accepted
  obtain ⟨program, meaning⟩ := member_has_meaning member
  have main := authoritative_main_correct meaning
  have selectors := executable_selectors calls source admit arguments assignment output refinement meaning
  have checks := Current.all_obligations_discharge (Current.SourceMeaning.sequence meaning)
  exact ⟨program, meaning, main.1, main.2.1, main.2.2.1, selectors.1, selectors.2.1,
    selectors.2.2, checks.1, source_execution_specified meaning⟩

theorem current_executable_membership (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    (Silver.accepts text || admit text) = true ↔ Current.Member text := by
  rw [Bool.or_eq_true, executable_membership calls source admit arguments assignment output refinement text,
    Silver.accepts_iff_member]
  rfl

/-- Complete external-tool discharge and compilation retain their documented
contract; admission is connected to the actual recognizer's source equations. -/
theorem executable_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools) (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} (accepted : (Silver.accepts text || admit text) = true) :
    ∃ artifact steps, Current.Pipeline tools text artifact steps :=
  Current.automatic_pipeline contract
    ((current_executable_membership calls source admit arguments assignment output refinement text).mp accepted)

end Silver.Sequence.SourceBridge
