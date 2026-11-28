module

public import Silver.ApplicationPackageReturnReading
public import Silver.ApplicationPackageRoutineEntryScope

@[expose] public section

/-! Routine results retain the original terminal expression or the original
writable formal rows. The result checker is derived from the native reader
domain and final flow, never supplied as an admission premise. -/
namespace Silver.ApplicationPackageRoutineResults
open Compose Predicate Packages ApplicationPackages ApplicationPackageBodies
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open PackageBindings (Metadata Routine)

set_option backward.dsimp.instances true

/-- The original function return is checked in the completed body's incoming
flow. Its original expression and all intermediate obligations remain visible. -/
theorem function_results {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : Metadata} {index : Nat} {item : Routine} {state : InitializationFrame}
    {result : CompletionResult}
    (read : CompletionBodyRead calls text globals info index item state result)
    (take : calls.takeToken = tokenAfter)
    (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (legal : NativeDomain
      ⟨text, completionContextOf calls state, completionDispatch calls text info item state, info, {}, {}⟩)
    (closed : ClosedFunctionContext (completionContextOf calls state))
    (kind : item.kind = .function) :
    ∃ value,
      ActualAt text (completionContextOf calls state)
        (fixedAfter text (completionDispatch calls text info item state).scan.position "return" true)
        (completionDispatch calls text info item state).scan.facts (resultFormal item) value
        (functionReturnAfter text (completionContextOf calls state)
          (completionDispatch calls text info item state).scan ⟨0, item.resultKind, item.resultBounds, 0⟩) ∧
      value.Readable false Bindings.emptyShape
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) ∧
      ScalarFunctions.scalarActual value = true ∧
      ScalarFunctions.checkActuals Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames))
        (item.signature info).outputTypes [value] = true ∧
      discharged (actualObligations Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) item.resultDomain value) = true ∧
      read.returned.writes = PackageBindings.emptyStateSet := by
  obtain ⟨native, same, valid⟩ := legal.context
  change native.model = completionContextOf calls state at same
  have names : Expressions.ValidNames text (completionContextOf calls state).names := by
    rw [← same]
    exact valid.1
  have normal : NamesNormal (completionContextOf calls state).names := by
    rw [closed.noNames]
    exact namesBoundsValid_empty.normal
  obtain ⟨value, original, _, unwritten⟩ := read.function_source take returnAfter legal.text names kind
  have checked := result_reading_checks normal names legal.base legal.arrays
    legal.scan.flow.1 legal.scan.path original
  have shape : (completionContextOf calls state).names.shape = Bindings.emptyShape := by
    rw [closed.noNames]
    exact empty_names_shape
  rw [closed.noArguments, shape] at checked
  refine ⟨value, original, checked.1, actual_source_scalar closed original, ?_, checked.2.2, unwritten⟩
  simpa only [PackageBindings.Routine.signature, kind, RoutineSignature.outputTypes,
    ScalarFunctions.checkActuals, Bool.and_true] using checked.2.1


open ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFormalStorage
open ApplicationPackageFrameLayout ApplicationPackageFrames

/-- The native hiding pass may delete outer declarations only. A returning
pass retains every field of each same-scope row. -/
theorem hideEntries_nonouter {α : Type} {selected outer : α → Bool}
    {before after : List α} (run : hideEntries selected outer before = some after)
    {row : α} (member : row ∈ before) (localRow : outer row = false) : row ∈ after := by
  induction before generalizing after with
  | nil => contradiction
  | cons head tail ih =>
      simp only [hideEntries] at run
      split at run
      · split at run
        · rename_i isOuter
          rcases List.mem_cons.mp member with rfl | later
          · simp only [localRow, Bool.false_eq_true] at isOuter
          · exact ih run later
        · contradiction
      · obtain ⟨rest, remaining, same⟩ := Option.map_eq_some_iff.mp run
        subst after
        rcases List.mem_cons.mp member with rfl | later
        · exact List.mem_cons_self ..
        · exact List.mem_cons_of_mem _ (ih remaining later)

theorem hideOuter_nonouter {text : Source} {frame : ParserState}
    {info : Metadata} {name : PackageBindings.NameSpan}
    (present : (hideOuter text frame info name).position ≠ 0) :
    (∀ row ∈ frame.scalarNames,
      ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩ = false →
      row ∈ (hideOuter text frame info name).scalarNames) ∧
    (∀ row ∈ frame.booleanNames,
      ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩ = false →
      row ∈ (hideOuter text frame info name).booleanNames) := by
  unfold hideOuter at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i allowed
    rw [ite_eq_right allowed]
    cases ints : hideEntries (scalarMatches text name)
      (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.scalarNames with
    | none => simp only [ints] at present; exact False.elim (present rfl)
    | some integers =>
      cases flags : hideEntries (booleanMatches text name)
        (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.booleanNames with
      | none => simp only [ints, flags] at present; exact False.elim (present rfl)
      | some booleans =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.subtypeNames.items with
        | none => simp only [ints, flags, subtypes] at present; exact False.elim (present rfl)
        | some types =>
          simp only [ints, flags, subtypes, Option.bind_some, pure, bind] at present ⊢
          split at present
          · rename_i valid
            rw [ite_eq_left valid]
            exact ⟨fun _ member localRow => hideEntries_nonouter ints member localRow,
              fun _ member localRow => hideEntries_nonouter flags member localRow⟩
          · exact False.elim (present rfl)

private theorem typed_live {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {seed : ObjectResult}
    (accepted : (objectTyped calls text original info first last colonEnd constantEnd localObject seed).frame.position ≠ 0) :
    seed.frame.position ≠ 0 := by
  intro missing
  apply accepted
  unfold objectTyped
  rw [ite_eq_left (by simp only [missing, decide_true])]
  rfl

private theorem object_base_present {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : Metadata}
    (accepted : (objectStep (modelObjectCalls reader) text frame info true).frame.position ≠ 0) :
    (hideOuter text frame info (objectName text frame)).position ≠ 0 := by
  dsimp only [objectStep, objectNameStep] at accepted
  split at accepted
  · exact False.elim (accepted rfl)
  · exact typed_live accepted

/-- Original formal rows, including their complete scalar domains. This
relation records table storage only; it contains no result-checking premise. -/
def FormalPresent (frame : ParserState) (formal : PackageBindings.Formal) : Prop :=
  (∀ row, scalar formal = some row → row ∈ frame.scalarNames) ∧
    (∀ row, flag formal = some row → row ∈ frame.booleanNames)

theorem stored_formal_present {before after : ParserState} {formals : List PackageBindings.Formal}
    (stored : Stored before after formals) {formal : PackageBindings.Formal}
    (member : formal ∈ formals) : FormalPresent after formal := by
  constructor
  · intro row selected
    rw [stored.integers]
    exact List.mem_append_right _ (List.mem_filterMap.mpr ⟨formal, member, selected⟩)
  · intro row selected
    rw [stored.flags]
    exact List.mem_append_right _ (List.mem_filterMap.mpr ⟨formal, member, selected⟩)

theorem FormalPresent.stored {before after : ParserState} {formals : List PackageBindings.Formal}
    {formal : PackageBindings.Formal} (prior : FormalPresent before formal)
    (stored : Stored before after formals) : FormalPresent after formal := by
  constructor
  · intro row selected
    rw [stored.integers]
    exact List.mem_append_left _ (prior.1 row selected)
  · intro row selected
    rw [stored.flags]
    exact List.mem_append_left _ (prior.2 row selected)

theorem FormalPresent.after_object {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : Metadata} {out : ObjectResult}
    {formal : PackageBindings.Formal} (prior : FormalPresent frame formal)
    (localFormal : ApplicationPackageNames.outerDeclaration info formal.bodyName = false)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : FormalPresent out.frame formal := by
  have live := parsed ▸ present
  have retained := hideOuter_nonouter (object_base_present live)
  obtain ⟨_, storage⟩ := objectStep_rows reader text frame info true live
  rw [parsed] at storage
  have kept : FormalPresent (initializerBase text frame info (objectName text frame) true) formal := by
    constructor
    · intro row selected
      have original := prior.1 row selected
      unfold scalar at selected
      split at selected
      · cases selected
        exact retained.1 _ original localFormal
      · contradiction
    · intro row selected
      have original := prior.2 row selected
      unfold flag at selected
      split at selected
      · cases selected
        exact retained.2 _ original localFormal
      · contradiction
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨_, installed, same⟩ := storage.integerStorage kind
    exact ⟨fun row selected => installed ▸ List.mem_append_left _ (kept.1 row selected),
      fun row selected => same ▸ kept.2 row selected⟩
  | boolean =>
    obtain ⟨_, installed, same⟩ := storage.booleanStorage kind
    exact ⟨fun row selected => same ▸ kept.1 row selected,
      fun row selected => installed ▸ List.mem_append_left _ (kept.2 row selected)⟩

theorem FormalPresent.local_history {reader : BooleanElaboration.Native.Reader}
    {calls : CompletionCalls} {text : Source} {info : Metadata} {item : Routine}
    {before after : InitializationFrame} {rows : List LocalObject} {formal : PackageBindings.Formal}
    (prior : FormalPresent before.frame formal)
    (localFormal : ApplicationPackageNames.outerDeclaration info formal.bodyName = false)
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true) :
    FormalPresent after.frame formal := by
  induction history with
  | finished => exact prior
  | @added row final following atBegin apart parsed advanced rest ih =>
      exact ih (prior.after_object localFormal ((original row List.mem_cons_self).symm.trans parsed)
        (by omega)) (fun seen member => original seen (List.mem_cons_of_mem _ member))

theorem FormalPresent.outputs {calls : CompletionCalls} {text : Source} {info : Metadata}
    {indices : List Nat} {before after : InitializationFrame} {formal : PackageBindings.Formal}
    (prior : FormalPresent before.frame formal)
    (read : outputInitializers calls text info indices before = some after) :
    FormalPresent after.frame formal := by
  obtain ⟨position, same⟩ := outputInitializers_sameDeclarations read
  rw [same]
  exact prior

/-- All formal rows are present at the final body frame. Input/in-out rows
survive each successful local hide; out rows come from the original append pass. -/
theorem completion_formals_present {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (notOuter : ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      ApplicationPackageNames.outerDeclaration frames.signature.info formal.bodyName = false) :
    ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      FormalPresent frames.outputs.completed formal := by
  intro formal member
  have indices : formal ∈ (formalIndices (frames.signature.info.routineAt (info.completed + 1))).map
      frames.signature.info.parameterAt := by
    simpa only [Routine.formals, formalIndices, List.map_map, Function.comp_def] using member
  have chosenMember (output : Bool) (selectedMode : decide (formal.mode = .output) = output) :
      formal ∈ chosen output frames.signature.info (formalIndices (frames.signature.info.routineAt (info.completed + 1))) := by
    obtain ⟨index, active, same⟩ := List.mem_map.mp indices
    exact List.mem_flatMap.mpr ⟨index, active, by simp only [ApplicationPackageFormalStorage.selected, same, selectedMode, ↓reduceIte, List.mem_singleton]⟩
  have outputs := outputs_stored (calls := declarationReaders reader calls) rfl text frames.signature.info _
    frames.outputs.installed
  by_cases output : formal.mode = .output
  · exact stored_formal_present outputs (chosenMember true (by simp only [output, decide_true]))
  · have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
        (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
    obtain ⟨hidden, _, stored⟩ := routineFrame_tables (calls := routineFrameReaders) rfl rfl entered frames.entryPresent
    have initial := stored_formal_present stored (chosenMember false (by simp only [output, decide_false]))
    have localRows := initial.local_history (notOuter formal member) frames.declarations (fun _ _ => rfl)
    have begun : FormalPresent (beginOutputs (declarationReaders reader calls) text frames.locals).frame formal := localRows
    exact (begun.outputs frames.outputs.read).stored outputs


/-- A result is read from the exact original formal row in the final native
frame, with its declared bounds and mutability retained. -/
inductive FormalResultAt (context : ParseContext) (formal : PackageBindings.Formal) :
    ScalarFunctions.Actual → Prop
  | integer {slot : Nat} (kind : formal.kind = .integer) (positive : 0 < slot)
      (active : slot ≤ context.scalarNames.length)
      (row : ScalarExpression.binding context.scalarNames slot =
        ⟨formal.bodyName.first, formal.bodyName.after, formal.bounds, false, formal.bounds,
          decide (formal.mode ≠ .input), 0, 0⟩) :
      FormalResultAt context formal (.integer (.name slot))
  | boolean {slot : Nat} (kind : formal.kind = .boolean) (positive : 0 < slot)
      (active : slot ≤ context.booleanNames.length)
      (row : BooleanBindings.binding context.booleanNames slot =
        ⟨formal.bodyName.first, formal.bodyName.after, decide (formal.mode ≠ .input), 0, 0, false, false⟩) :
      FormalResultAt context formal (.boolean (.booleanName slot))

theorem FormalPresent.result {frame : ParserState} {formal : PackageBindings.Formal}
    (present : FormalPresent frame formal) (scan : ScanResult) (same : scan.state = frame)
    (count : Nat) : ∃ actual, FormalResultAt {Predicate.contextOf scan with declarationCount := count} formal actual := by
  subst frame
  cases kind : formal.kind with
  | integer =>
      let row : ScalarExpression.Binding :=
        ⟨formal.bodyName.first, formal.bodyName.after, formal.bounds, false, formal.bounds,
          decide (formal.mode ≠ .input), 0, 0⟩
      have member : row ∈ scan.state.scalarNames := present.1 row (by simp only [scalar, kind, ↓reduceIte, row])
      have widened : row ∈ ScalarExpression.bodyEnvironment scan.state.scalarNames := by
        have fixed : ScalarExpression.bodyBinding row = row := by
          dsimp only [ScalarExpression.bodyBinding, row]
          split <;> rfl
        exact List.mem_map.mpr ⟨row, member, fixed⟩
      obtain ⟨index, inside, atRow⟩ := List.mem_iff_getElem.mp widened
      refine ⟨.integer (.name (index + 1)), .integer kind (by omega) (by simpa only [Predicate.contextOf] using Nat.succ_le_of_lt inside) ?_⟩
      simpa only [Predicate.contextOf, ScalarExpression.binding, Nat.add_one_sub_one,
        List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some] using atRow
  | boolean =>
      let row : BooleanBindings.Binding :=
        ⟨formal.bodyName.first, formal.bodyName.after, decide (formal.mode ≠ .input), 0, 0, false, false⟩
      have member : row ∈ scan.state.booleanNames := present.2 row (by simp only [flag, kind, ↓reduceIte, row])
      obtain ⟨index, inside, atRow⟩ := List.mem_iff_getElem.mp member
      refine ⟨.boolean (.booleanName (index + 1)), .boolean kind (by omega) (by simpa only [Predicate.contextOf] using Nat.succ_le_of_lt inside) ?_⟩
      simpa only [Predicate.contextOf, BooleanBindings.binding, Nat.add_one_sub_one,
        List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some] using atRow

theorem FormalResultAt.checked {context : ParseContext} {formal : PackageBindings.Formal}
    {actual : ScalarFunctions.Actual} {facts : ActiveFlow}
    (source : FormalResultAt context formal actual) (writable : formal.mode ≠ .input)
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts)
    (noArrays : context.arrayNames = []) :
    actual.Readable false Bindings.emptyShape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      ScalarFunctions.scalarActual actual = true ∧
      actual.check Bindings.emptyShape context.analysis (context.flow facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) formal.domain = true := by
  cases source with
  | @integer slot kind positive active row =>
      have mutable : ScalarExpression.mutability context.scalarNames slot = true := by
        simp only [ScalarExpression.mutability, positive, active, and_self, decide_true,
          Bool.true_and, row, writable, ne_eq, not_false_eq_true, decide_true]
      have domain : ScalarMetadata.flowBounds context.scalarNames slot = some formal.bounds := by
        rw [ScalarMetadata.flowBounds_active _ _ positive active, row]
        simp only [writable, ne_eq, not_false_eq_true, decide_true, ↓reduceIte]
      obtain ⟨bounds, found, included⟩ := ready.contained slot formal.bounds domain
      have bounded := ready.bounded slot bounds found
      have nonempty := ready.mutableNonempty slot bounds mutable found
      have contained : bounds.included formal.bounds = true := by
        simpa only [ApplicationPackageCalls.includedCheck_model] using ApplicationPackageCalls.includedCheck_of_contains included
      have viewed : (context.flow facts).scalars = facts.model.scalars := by
        simp only [ParseContext.flow, noArrays, ArrayBindings.viewRanges, ArrayBindings.viewNames,
          List.map_nil, ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil,
          ArrayBindings.ranges_nil]
      refine ⟨trivial, rfl, ?_⟩
      simp only [PackageBindings.Formal.domain, kind, ScalarFunctions.Actual.check,
        Integer.Expr.infer, viewed, found, Option.bind_some, Integer.accepted, Integer.checked,
        nonempty, Bool.false_eq_true, ↓reduceIte, bounded, Bool.not_false, contained, Bool.and_self]
  | @boolean slot kind positive active row =>
      have initialized : (ArrayBindings.booleanAnalysis context.arrayNames
          (BooleanBindings.analysis context.booleanNames)).initialized slot = true := by
        simp only [noArrays, ArrayBindings.booleanAnalysis, ArrayBindings.booleanNames, List.filter_nil,
          List.any_nil, Bool.false_or, BooleanBindings.analysis, positive, active, and_self, decide_true]
      exact ⟨⟨trivial, initialized⟩, rfl, by
        simpa only [PackageBindings.Formal.domain, kind, ScalarFunctions.Actual.check,
          Condition.checkBounds] using initialized⟩

/-- Copy-back results follow formal order and include precisely the writable
modes. No expression or flow checker is embedded in this source relation. -/
inductive ProcedureResultsAt (context : ParseContext) : List PackageBindings.Formal → List ScalarFunctions.Actual → Prop
  | nil : ProcedureResultsAt context [] []
  | input {formal formals actuals} (mode : formal.mode = .input)
      (rest : ProcedureResultsAt context formals actuals) :
      ProcedureResultsAt context (formal :: formals) actuals
  | output {formal formals actual actuals} (mode : formal.mode ≠ .input)
      (head : FormalResultAt context formal actual) (rest : ProcedureResultsAt context formals actuals) :
      ProcedureResultsAt context (formal :: formals) (actual :: actuals)

theorem procedure_results_at {context : ParseContext} {formals : List PackageBindings.Formal}
    (present : ∀ formal ∈ formals, ∃ actual, FormalResultAt context formal actual) :
    ∃ actuals, ProcedureResultsAt context formals actuals := by
  induction formals with
  | nil => exact ⟨[], .nil⟩
  | cons formal formals ih =>
      obtain ⟨actuals, rest⟩ := ih (fun formal member => present formal (List.mem_cons_of_mem _ member))
      by_cases input : formal.mode = .input
      · exact ⟨actuals, .input input rest⟩
      · obtain ⟨actual, original⟩ := present formal (List.mem_cons_self ..)
        exact ⟨actual :: actuals, .output input original rest⟩

theorem ProcedureResultsAt.checked {context : ParseContext} {formals : List PackageBindings.Formal}
    {actuals : List ScalarFunctions.Actual} {facts : ActiveFlow}
    (source : ProcedureResultsAt context formals actuals)
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts)
    (noArrays : context.arrayNames = []) :
    (∀ actual ∈ actuals, actual.Readable false Bindings.emptyShape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))) ∧
    (∀ actual ∈ actuals, ScalarFunctions.scalarActual actual = true) ∧
    ScalarFunctions.checkActuals Bindings.emptyShape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (ScalarProcedures.outputTypes (formals.map PackageBindings.Formal.semantic)) actuals = true := by
  induction source with
  | nil => exact ⟨by simp, by simp, rfl⟩
  | @input formal formals actuals mode rest ih =>
      refine ⟨ih.1, ih.2.1, ?_⟩
      simpa only [List.map_cons, PackageBindings.Formal.semantic, mode, ScalarProcedures.outputTypes] using ih.2.2
  | @output formal formals actual actuals mode head rest ih =>
      have checked := head.checked mode ready noArrays
      refine ⟨fun seen member => ?_, fun seen member => ?_, ?_⟩
      · rcases List.mem_cons.mp member with rfl | later
        · exact checked.1
        · exact ih.1 seen later
      · rcases List.mem_cons.mp member with rfl | later
        · exact checked.2.1
        · exact ih.2.1 seen later
      · cases selectedMode : formal.mode with
        | input => exact False.elim (mode selectedMode)
        | output | inputOutput =>
            simpa only [List.map_cons, PackageBindings.Formal.semantic, selectedMode,
              ScalarProcedures.outputTypes, ScalarFunctions.checkActuals, checked.2.2,
              Bool.true_and] using ih.2.2

theorem completion_procedure_results {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (notOuter : ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      ApplicationPackageNames.outerDeclaration frames.signature.info formal.bodyName = false)
    (ready : ScalarMetadata.FlowReady frames.bodySource.context.scalarNames
      frames.bodySource.context.declarationCount
      (completionDispatch (declarationReaders reader calls) text frames.signature.info
        (frames.signature.info.routineAt (info.completed + 1)) frames.outputs.body).scan.facts)
    (tables : ApplicationPackageRoutineClosedFrames.Tables globals)
    (kind : (frames.signature.info.routineAt (info.completed + 1)).kind = .procedure) :
    ∃ actuals,
      ProcedureResultsAt frames.bodySource.context
        ((frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info) actuals ∧
      (∀ actual ∈ actuals, actual.Readable false Bindings.emptyShape
        (ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
          (BooleanBindings.analysis frames.bodySource.context.booleanNames))) ∧
      (∀ actual ∈ actuals, ScalarFunctions.scalarActual actual = true) ∧
      ScalarFunctions.checkActuals Bindings.emptyShape frames.bodySource.context.analysis
        (frames.bodySource.context.flow
          (completionDispatch (declarationReaders reader calls) text frames.signature.info
            (frames.signature.info.routineAt (info.completed + 1)) frames.outputs.body).scan.facts)
        (ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
          (BooleanBindings.analysis frames.bodySource.context.booleanNames))
        ((frames.signature.info.routineAt (info.completed + 1)).signature frames.signature.info).outputTypes actuals = true := by
  have present := completion_formals_present frames notOuter
  obtain ⟨actuals, original⟩ := procedure_results_at (context := frames.bodySource.context)
    (fun formal member => (present formal member).result
      ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩ rfl 0)
  have checked := original.checked ready (frames.body_closed tables).arrayNames
  refine ⟨actuals, original, checked.1, checked.2.1, ?_⟩
  simpa only [PackageBindings.Routine.signature, kind, RoutineSignature.outputTypes] using checked.2.2

end Silver.ApplicationPackageRoutineResults
