module

public import Silver.ApplicationPackageCallsProcedureChecking

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings

set_option backward.dsimp.instances true

/-- Actual expression/target scanning uses the incoming flow and changes
neither that flow nor caller permission and write bits. -/
private def argumentFrame (value : ApplicationCall) : BodyScan × Bool × StateSet :=
  (value.result.scan, value.result.allowProcedureCalls, value.result.writes)

private theorem actual_step_frame {calls text context input info item ordinal before after}
    (read : actualStep calls text context input info item ordinal before = some after) :
    argumentFrame after.result = argumentFrame before.result := by
  unfold actualStep at read
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at read
  obtain ⟨⟨slot, named, cursor⟩, _, read⟩ := read
  dsimp only at read
  split at read
  · contradiction
  · cases payload : actualPayload calls text context input (info.parameterAt slot) info cursor
        {before.actual slot with first := cursor} with
    | mk following actual =>
      rw [payload] at read
      dsimp only at read
      split at read
      · contradiction
      · by_cases absent : calls.take text following (if ordinal = item.count then .symbol ")" else .symbol ",") = 0
        · simp only [absent, ↓reduceIte, reduceCtorEq] at read
        · simp only [absent, ↓reduceIte, Option.some.injEq] at read
          subst after
          dsimp only [argumentFrame]

private theorem actual_fold_frame {calls text context input info item} (indices : List Nat) {before after}
    (read : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) : argumentFrame after.result = argumentFrame before.result := by
  induction indices generalizing before with
  | nil => cases Option.some.inj read; rfl
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    exact (ih remaining).trans (actual_step_frame first)

theorem readActuals_frame {calls text context input info item position frame}
    (read : readActuals calls text context input info item position = some frame) :
    frame.result.result.scan = input.scan ∧ frame.result.result.allowProcedureCalls = input.allowProcedureCalls ∧
      frame.result.result.writes = input.writes := by
  unfold readActuals at read
  split at read
  · cases Option.some.inj read
    exact ⟨rfl, rfl, rfl⟩
  · dsimp only at read
    split at read
    · contradiction
    · have same := actual_fold_frame (List.range item.count) read
      exact ⟨congrArg Prod.fst same, congrArg (fun state => state.2.1) same,
        congrArg (fun state => state.2.2) same⟩

def argumentFlow (parameter : Formal) (argument : ScalarProcedures.Actual) (flow : Flow) : Flow :=
  match argument with
  | .value _ => flow
  | .target object => object.after parameter.domain flow

private theorem writable_update_facts (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (target : ProcedureActualResult) :
    (procedureWritableUpdate scan parameter target).facts = scan.facts.replace target.scalar parameter.bounds := by
  unfold procedureWritableUpdate
  split
  · rename_i zero
    simp only [zero, ActiveFlow.replace, ↓reduceIte]
  · rfl

theorem ArgumentAt.alias_step_flow {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {actuals : List PackageActual}
    {before after : ApplicationCall} {slot : Nat} {argument : ScalarProcedures.Actual}
    (source : ArgumentAt text context input (info.parameterAt slot) (actuals.getD (slot - 1) {}) argument)
    (count : before.result.scan.count = context.scalarNames.length)
    (read : aliasStep modelCalls text info item actuals before slot = some after) :
    after.result.scan.count = before.result.scan.count ∧
      context.model.flow after.result.scan.facts =
        argumentFlow (info.parameterAt slot) argument (context.model.flow before.result.scan.facts) := by
  cases source with
  | value mode _ _ _ =>
    simp only [aliasStep, mode, ↓reduceIte] at read
    split at read
    · contradiction
    · cases Option.some.inj read
      exact ⟨rfl, rfl⟩
  | target writable _ _ meaning =>
    simp only [aliasStep, writable, ↓reduceIte] at read
    split at read
    · contradiction
    · split at read
      · contradiction
      · split at read
        · contradiction
        · split at read
          · contradiction
          · cases Option.some.inj read
            refine ⟨ActiveFlow.replace_count .., ?_⟩
            have updated := meaning.changed before.result.scan count
            rw [writable_update_facts] at updated
            have domain : (ProcedureBindings.formalModel (outputFormal (info.parameterAt slot))
                context.model.arrayTypes).domain = (info.parameterAt slot).domain := by
              cases kind : (info.parameterAt slot).kind <;>
                simp only [outputFormal, ProcedureBindings.formalModel, formalType, procedureInputFormal,
                  ne_eq, not_true_eq_false, ↓reduceIte, Formal.domain, kind]
            rw [domain] at updated
            exact updated

/-- The native second pass applies output ranges in the same formal order as
the procedure checker. All input expressions retain their original incoming
flow, even while earlier output targets receive their declared ranges. -/
theorem FormalArgumentsAt.alias_fold_meaning {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {frame : ActualFrame}
    {slots : List Nat} {arguments : List ScalarProcedures.Actual}
    (source : FormalArgumentsAt text context input info frame slots arguments)
    {before after : ApplicationCall}
    (count : before.result.scan.count = context.scalarNames.length)
    (read : slots.foldlM (aliasStep modelCalls text info item frame.actuals) before = some after) :
    after.result.scan.count = before.result.scan.count ∧
      ProcedureActualsMeaning context.model (context.model.flow input.scan.facts)
        (slots.map fun slot => (info.parameterAt slot).semantic) arguments
        (context.model.flow before.result.scan.facts) (context.model.flow after.result.scan.facts) := by
  induction source generalizing before with
  | nil =>
    cases Option.some.inj read
    exact ⟨rfl, .nil⟩
  | @cons slot slots argument arguments head tail ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    have step := head.alias_step_flow count first
    obtain ⟨finalCount, later⟩ := ih (step.1.trans count) remaining
    rw [step.2] at later
    refine ⟨finalCount.trans step.1, ?_⟩
    change ProcedureActualsMeaning _ _ ((info.parameterAt slot).semantic :: _) (argument :: _) _ _
    cases head with
    | value mode _ readable fits =>
      have formal : (info.parameterAt slot).semantic = ⟨.input, (info.parameterAt slot).domain⟩ := by
        simp only [Formal.semantic, mode]
      rw [formal]
      exact .input readable fits later
    | target writable _ _ meaning =>
      cases mode : (info.parameterAt slot).mode with
      | input => exact False.elim (writable mode)
      | output =>
        have formal : (info.parameterAt slot).semantic = ⟨.output, (info.parameterAt slot).domain⟩ := by
          simp only [Formal.semantic, mode]
        rw [formal]
        exact .output meaning.readable meaning.checked later
      | inputOutput =>
        have formal : (info.parameterAt slot).semantic = ⟨.inputOutput, (info.parameterAt slot).domain⟩ := by
          simp only [Formal.semantic, mode]
        rw [formal]
        exact .inputOutput meaning.readable (meaning.copyIn mode) meaning.checked later

/-- The output of the real alias pass is the checker's output-target fold.
This theorem deliberately stops before the later visible-global reset. -/
theorem checkAliases_output_flow {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {frame : ActualFrame}
    {arguments : List ScalarProcedures.Actual} {position : Nat} {after : ApplicationCall}
    (source : FormalArgumentsAt text context input info frame (formalSlots item) arguments)
    (count : input.scan.count = context.scalarNames.length)
    (read : readActuals modelCalls text context.model input info item position = some frame)
    (aliases : checkAliases modelCalls text info item frame = some after) :
    ∃ bound,
      ScalarProcedures.bindActuals ((item.formals info).map Formal.semantic) arguments = some bound ∧
      ScalarProcedures.afterTargets (ScalarProcedures.outputTypes ((item.formals info).map Formal.semantic))
        bound.outputs (context.model.flow input.scan.facts) = context.model.flow after.result.scan.facts ∧
      after.result.scan.count = input.scan.count := by
  have same := (readActuals_frame read).1
  have beforeCount : frame.result.result.scan.count = context.scalarNames.length := same ▸ count
  obtain ⟨afterCount, meaning⟩ := source.alias_fold_meaning beforeCount aliases
  rw [same] at meaning afterCount
  have semantic : ProcedureActualsMeaning context.model (context.model.flow input.scan.facts)
      ((item.formals info).map Formal.semantic) arguments
      (context.model.flow input.scan.facts) (context.model.flow after.result.scan.facts) := by
    simpa only [Routine.formals, formalSlots, List.map_map, Function.comp_def] using meaning
  obtain ⟨bound, binding, _, _, _, updated⟩ := semantic.binding
  exact ⟨bound, binding, updated, afterCount⟩

end Silver.ApplicationPackageCalls
