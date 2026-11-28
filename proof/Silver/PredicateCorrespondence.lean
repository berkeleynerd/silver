module

public import Silver.PredicateSourceBridge
public import Silver.PredicateSelectors
public import Silver.Current

@[expose] public section
namespace Silver.Predicate.SourceBridge

/-! The actual recognizer's equations and wrapper contracts compose with unique
source meaning, checked execution, report routing and every modeled obligation.
Complete external generation and pinned-solver completion remain explicit in the
existing ToolContract; proof success does not define membership. -/

theorem executable_membership (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    admit text = true ↔ Member text := by
  rw [(executable_correspondence calls source admit arguments assignment output refinement text).1]
  exact accepts_iff_member text

theorem executable_selectors (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} {program : Program} (meaning : SourceMeaning text program) :
    arguments text = program.hasArguments ∧
      assignment text = program.assignmentFlag ∧
      output text = Flag.output.statements program.statements := by
  have selectors := (executable_correspondence calls source admit arguments assignment output refinement text).2
  have decoded := meaning_selectors meaning
  exact ⟨selectors.1.trans decoded.1, selectors.2.1.trans decoded.2.1,
    selectors.2.2.trans decoded.2.2⟩

theorem executable_main_correct (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} (accepted : admit text = true) :
    ∃ program, SourceMeaning text program ∧ program.Valid ∧
      (∀ other, SourceMeaning text other → other = program) ∧
      (∀ argv, program.checkedExecute argv = some (program.execute argv)) ∧
      arguments text = program.hasArguments ∧
      assignment text = program.assignmentFlag ∧
      output text = Flag.output.statements program.statements ∧
      Current.ScalarHeaderSource text (.sequence program) ∧
      Semantics.discharge (Current.obligations text (.sequence program)) = true ∧
      (∀ environment, program.inputValid environment.arguments = false → program.run environment = ⟨1, []⟩) ∧
      (∀ environment, environment.Healthy → program.run environment =
        ⟨Sequence.expectedEffectStatus (program.execute environment.arguments).effects,
         Sequence.intendedEffectBytes (program.execute environment.arguments).effects⟩) ∧
      ∀ environment, (program.run environment).accepted.length ≤
        Sequence.outputCount (program.execute environment.arguments).effects * (maxSourceLength + 1) := by
  have member := (executable_membership calls source admit arguments assignment output refinement text).mp accepted
  obtain ⟨program, meaning⟩ := member_has_meaning member
  have valid := meaning_valid meaning
  have selectors := executable_selectors calls source admit arguments assignment output refinement meaning
  have checks := Current.all_obligations_discharge (Current.SourceMeaning.sequence meaning)
  exact ⟨program, meaning, valid, fun other otherMeaning => meaning_unique otherMeaning meaning,
    source_execution_sound meaning, selectors.1, selectors.2.1, selectors.2.2,
    Current.source_scalar_headers (Current.SourceMeaning.sequence meaning), checks.1,
    program.invalid_run valid, program.healthy_run valid, program.output_bound valid⟩

theorem current_executable_membership (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    (Silver.accepts text || admit text) = true ↔ Current.Member text := by
  rw [Bool.or_eq_true, executable_membership calls source admit arguments assignment output refinement text,
    Silver.accepts_iff_member]
  rfl

theorem executable_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools) (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output)
    {text : Source} (accepted : (Silver.accepts text || admit text) = true) :
    ∃ artifact steps, Current.Pipeline tools text artifact steps :=
  Current.automatic_pipeline contract
    ((current_executable_membership calls source admit arguments assignment output refinement text).mp accepted)

end Silver.Predicate.SourceBridge
