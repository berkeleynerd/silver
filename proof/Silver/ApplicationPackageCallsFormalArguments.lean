module

public import Silver.ApplicationPackageCallsArguments
public import Silver.PredicateProcedureUpdatesMeaning

@[expose] public section

namespace Silver.ApplicationPackageCalls

open Compose Predicate ApplicationPackages

/-- The semantic arguments in formal order refer to the actual rows left by
the call's source-order scan, including their original source spans. -/
inductive FormalArgumentsAt (text : Source) (context : Predicate.Native.Context) (input : ApplicationScan)
    (info : PackageBindings.Metadata) (frame : ActualFrame) : List Nat → List ScalarProcedures.Actual → Prop
  | nil : FormalArgumentsAt text context input info frame [] []
  | cons {slot slots argument arguments} :
      ArgumentAt text context input (info.parameterAt slot) (frame.actual slot) argument →
      FormalArgumentsAt text context input info frame slots arguments →
      FormalArgumentsAt text context input info frame (slot :: slots) (argument :: arguments)

private theorem collect_arguments {text context input} {info : PackageBindings.Metadata} {frame : ActualFrame}
    (slots : List Nat)
    (each : ∀ slot ∈ slots, ∃ argument, ArgumentAt text context input (info.parameterAt slot) (frame.actual slot) argument) :
    ∃ arguments, FormalArgumentsAt text context input info frame slots arguments := by
  induction slots with
  | nil => exact ⟨[], .nil⟩
  | cons slot slots ih =>
    obtain ⟨argument, head⟩ := each slot (List.mem_cons_self ..)
    obtain ⟨arguments, tail⟩ := ih (fun i h => each i (List.mem_cons_of_mem _ h))
    exact ⟨argument :: arguments, .cons head tail⟩

theorem ActualListAt.formal_arguments {text : Source} {context : Predicate.Native.Context}
    {input info item afterName parsed entries}
    (source : ActualListAt modelCalls text context.model input info item afterName parsed entries)
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ info.parameters.length) :
    ∃ arguments, FormalArgumentsAt text context input info parsed (formalSlots item) arguments := by
  have tableBound : info.parameters.length ≤ PackageBindings.maxFormals := by
    rcases typed with ⟨_, _, _, _, _, _, _, bound, _⟩
    exact bound
  have physical := fun positive => Nat.le_trans (capacity positive) tableBound
  have covered := source.complete physical
  have stored := source.rows physical
  have meanings : ∀ row ∈ entries, ∃ arg, ArgumentAt text context input (info.parameterAt row.1) row.2 arg := by
    cases source with
    | empty => simp
    | supplied positive _ trace =>
      apply trace.arguments textValid valid body storage checked typed _ (capacity positive)
        (fun _ h => List.mem_range.mp h)
      exact fixedAfter_result_bound text _ "(" false (by decide)
  apply collect_arguments
  intro slot member
  have inRange : slot ∈ List.range' item.formalFirst item.count := by
    simpa only [List.range'_eq_map_range, formalSlots] using member
  obtain ⟨row, present, same⟩ := List.mem_map.mp (covered.mem_iff.mpr inRange)
  rw [← same, stored _ present]
  exact meanings row present

theorem ArgumentAt.unique {text context input parameter row left right}
    (one : ArgumentAt text context input parameter row left)
    (two : ArgumentAt text context input parameter row right) : left = right := by
  cases one with
  | value mode parsed _ _ =>
    cases two with
    | value _ other _ _ => exact congrArg ScalarProcedures.Actual.value (actual_unique parsed other).1
    | target different _ _ _ => contradiction
  | target different _ _ _ =>
    cases two with
    | value mode _ _ _ => contradiction
    | target => rfl

theorem FormalArgumentsAt.unique {text context input info frame slots left right}
    (one : FormalArgumentsAt text context input info frame slots left)
    (two : FormalArgumentsAt text context input info frame slots right) : left = right := by
  induction one generalizing right with
  | nil => cases two; rfl
  | cons head _ ih =>
    cases two with
    | cons other rest => rw [head.unique other, ih rest]

/-- All inputs are checked in the incoming flow. Writable copy-outs update
the abstract flow in formal order as prescribed by the procedure checker. -/
theorem FormalArgumentsAt.procedure_meaning {text context input info frame slots arguments}
    (source : FormalArgumentsAt text context input info frame slots arguments) (before : Flow) :
    ∃ after, ProcedureActualsMeaning context.model (context.model.flow input.scan.facts)
      (slots.map fun slot => (info.parameterAt slot).semantic) arguments before after := by
  induction source generalizing before with
  | nil => exact ⟨before, .nil⟩
  | @cons slot slots argument arguments head _ ih =>
    let parameter := info.parameterAt slot
    change ∃ after, ProcedureActualsMeaning _ _ (parameter.semantic :: _) (argument :: _) before after
    cases head with
    | value mode _ readable fits =>
      obtain ⟨after, tail⟩ := ih before
      have inputMode : parameter.mode = .input := mode
      have kind : parameter.semantic = ⟨.input, parameter.domain⟩ := by simp [PackageBindings.Formal.semantic, inputMode]
      rw [kind]
      exact ⟨after, .input readable fits tail⟩
    | target writable _ _ meaning =>
      let object := procedureTargetIdentity context.model (frame.actual slot).target
      obtain ⟨after, tail⟩ := ih (object.after parameter.domain before)
      cases mode : parameter.mode with
      | input => exact False.elim (writable mode)
      | output =>
        have kind : parameter.semantic = ⟨.output, parameter.domain⟩ := by simp [PackageBindings.Formal.semantic, mode]
        rw [kind]
        exact ⟨after, .output meaning.readable meaning.checked tail⟩
      | inputOutput =>
        have kind : parameter.semantic = ⟨.inputOutput, parameter.domain⟩ := by simp [PackageBindings.Formal.semantic, mode]
        rw [kind]
        exact ⟨after, .inputOutput meaning.readable (meaning.copyIn mode) meaning.checked tail⟩


/-- An accepted raw native call supplies the formal window and preserves its
own completion-prefix metadata. The actual argument witnesses come from this
call's source trace, even for named or zero-argument calls. -/
theorem accepted_formal_arguments {text : Source} {context : Predicate.Native.Context}
    {input info position kind} (textValid : Expressions.ValidText text)
    (valid : Predicate.Native.ValidContext text context) (body : context.elaborating = false)
    (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (accepted : (packageCallAt modelCalls text context.model input info position kind).value.after ≠ 0) :
    ∃ callee frame aliasResult entries arguments,
      callee = packageCallee modelCalls text context.model info position kind ∧ callee ≠ 0 ∧
      let item := info.routineAt callee
      ActualListAt modelCalls text context.model input info item (modelCalls.reference text position).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) arguments ∧
      checkAliases modelCalls text info item frame = some aliasResult ∧
      packageCallAt modelCalls text context.model input info position kind =
        finishCall modelCalls text context.model info kind item frame aliasResult ∧
      ∀ before, ∃ after, ProcedureActualsMeaning context.model (context.model.flow input.scan.facts)
        ((item.formals info).map PackageBindings.Formal.semantic) arguments before after := by
  obtain ⟨callee, item, frame, aliasResult, selected, positive, itemEq, window, read, aliases, returned, _, _⟩ :=
    accepted_call accepted
  have capacity (nonempty : 0 < item.count) : item.formalFirst + item.count - 1 ≤ info.parameters.length := by
    have bounds : ¬(item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
        item.count > info.parameters.length - item.formalFirst + 1) := fun failed => window ⟨nonempty, failed⟩
    omega
  obtain ⟨entries, source⟩ := readActuals_source read
  obtain ⟨arguments, semantic⟩ := source.formal_arguments textValid valid body storage checked typed capacity
  subst item
  refine ⟨callee, frame, aliasResult, entries, arguments, selected, positive, source, semantic, aliases, returned, ?_⟩
  intro before
  simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def] using
    semantic.procedure_meaning before

end Silver.ApplicationPackageCalls
