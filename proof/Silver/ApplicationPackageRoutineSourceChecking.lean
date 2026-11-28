module

public import Silver.ApplicationPackageRoutineBodySource
public import Silver.ApplicationPackageRoutineResults
public import Silver.PackagePhasedLibrarySafety

@[expose] public section

namespace Silver.ApplicationPackageRoutineSources
open Compose Compose.Expressions Predicate Packages ApplicationPackages ApplicationPackageDeclarations
open ApplicationPackageBodies ApplicationPackageInitializers ApplicationPackageRoutineClosedFrames
open ApplicationPackageFrameLayout ApplicationPackageObjectRows
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open ApplicationPackageRoutineResults

/-- Only original result syntax and formal-row storage, with no checker or
safety field. The implicit procedure results retain source formal order. -/
inductive ResultValuesAt (text : Source) (context : ParseContext) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (scan : BodyScan) : List ScalarFunctions.Actual → Prop
  | function {value : ScalarFunctions.Actual} (kind : item.kind = .function)
      (source : ActualAt text context (fixedAfter text scan.position "return" true) scan.facts
        (resultFormal item) value (functionReturnAfter text context scan ⟨0, item.resultKind, item.resultBounds, 0⟩)) :
      ResultValuesAt text context info item scan [value]
  | procedure {values : List ScalarFunctions.Actual} (kind : item.kind = .procedure)
      (source : ProcedureResultsAt context (item.formals info) values) :
      ResultValuesAt text context info item scan values

theorem original_results {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0)
    (returned : calls.functionReturnAfter = functionReturnAfter)
    (legal : NativeDomain (atInput frames.bodySource frames.dispatched))
    (tables : Tables globals)
    (notOuter : ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      ApplicationPackageNames.outerDeclaration frames.signature.info formal.bodyName = false) :
    ∃ values,
      ResultValuesAt text frames.bodySource.context frames.signature.info
        (frames.signature.info.routineAt (info.completed + 1)) frames.dispatched.scan values ∧
      (∀ value ∈ values, value.Readable false Bindings.emptyShape
        (ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
          (BooleanBindings.analysis frames.bodySource.context.booleanNames))) ∧
      (∀ value ∈ values, ScalarFunctions.scalarActual value = true) ∧
      ScalarFunctions.checkActuals Bindings.emptyShape frames.bodySource.context.analysis
        (frames.bodySource.context.flow frames.dispatched.scan.facts)
        (ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
          (BooleanBindings.analysis frames.bodySource.context.booleanNames))
        ((frames.signature.info.routineAt (info.completed + 1)).signature frames.signature.info).outputTypes values = true := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  cases kind : (frames.signature.info.routineAt (info.completed + 1)).kind with
  | function =>
    obtain ⟨value, source, readable, scalar, checked, _, _⟩ :=
      function_results read rfl returned legal (frames.closed_context tables) kind
    refine ⟨[value], .function kind source, ?_, ?_, checked⟩
    · intro seen member
      have same := List.mem_singleton.mp member
      subst seen
      exact readable
    · intro seen member
      have same := List.mem_singleton.mp member
      subst seen
      exact scalar
  | procedure =>
    obtain ⟨values, source, readable, scalar, checked⟩ :=
      completion_procedure_results frames notOuter legal.scan.flow tables kind
    exact ⟨values, .procedure kind source, readable, scalar, checked⟩

/-- The routine's exact source trees. Original native header/frame history is
the index; every executable component is selected by a source relation. -/
structure RoutineCode {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) (readers : Readers) where
  locals : List LocalInitializer
  outputRows : List OutputObject
  outputs : List LocalInitializer
  body : List Predicate.Statement
  results : List ScalarFunctions.Actual
  localSource : LocalValuesAt text.length frames.signature.info text frames.objects locals
  outputHistory : OutputObjects (declarationReaders reader calls) text frames.signature.info
    (formalIndices (frames.signature.info.routineAt (info.completed + 1)))
    (beginOutputs (declarationReaders reader calls) text frames.locals) outputRows frames.outputs.initialized
  outputSource : OutputValuesAt text.length (declarationReaders reader calls) frames.signature.info text outputRows outputs
  bodySource : TailCodeAt (sourceReaders readers) packageNames frames.bodySource frames.stop frames.required false
    frames.dispatched body
  resultSource : ResultValuesAt text frames.bodySource.context frames.signature.info
    (frames.signature.info.routineAt (info.completed + 1)) frames.dispatched.scan results

def RoutineCode.definition {reader calls text globals info result readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List SpecificationItem) : RoutineDefinition where
  signature := (frames.signature.info.routineAt (info.completed + 1)).signature frames.signature.info
  inputs := routineInputs frames.signature.info (frames.signature.info.routineAt (info.completed + 1))
  initializers := ((specificationSeeds specRows).map ConstantSeed.initializer ++ source.locals) ++ source.outputs
  layout := layout text.length frames.signature.info frames.bodySource.context
  body := source.body
  results := source.results

def RoutineCode.phases {reader calls text globals info result readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List SpecificationItem) : InitializerPhases :=
  ⟨(specificationSeeds specRows).map ConstantSeed.initializer ++ source.locals, source.outputs,
    mutableLocalCells frames.objects⟩

def RoutineCode.context {reader calls text globals info result readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (_source : RoutineCode frames readers) : RoutineContext :=
  ⟨frames.bodySource.context.analysis, ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
    (BooleanBindings.analysis frames.bodySource.context.booleanNames)⟩

def RoutineCode.entry {reader calls text globals info result readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List SpecificationItem) : PhasedRoutineEntry :=
  ⟨source.definition specRows, source.context, source.phases specRows⟩

/-- Complete source-to-checker composition for one original routine. All
semantic checker/form facts are conclusions; native domains and source table
invariants are derived independently by the original completion history. -/
theorem original_routine {reader : BooleanElaboration.Native.Reader}
    {specText : Source} {specStart specEnd : SpecificationState} {specRows : List SpecificationItem}
    (specified : SpecificationInventories reader specText specStart specRows (.ready specEnd))
    (specValid : ValidText specText) (specFrame : ReaderFrame specText specStart.exports)
    (specOrder : FrameOrder specStart.exports) (specEmpty : specStart.exports.scalarNames = [])
    {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (textValid : ValidText text) (globalsFramed : ReaderFrame text globals) (typed : info.Typed)
    (tables : Tables globals) (initial : StateFrame info.states globals)
    (origin : GlobalScalarOrigins specEnd.exports.scalarNames info.states globals.scalarNames)
    (separated : specText.length < globals.position)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (integerRows globals))
    (bounds : ∀ state ∈ info.states, state.declaredBounds.isEmpty = false)
    (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (interfaces : InterfaceDomains info)
    (notOuter : ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      ApplicationPackageNames.outerDeclaration frames.signature.info formal.bodyName = false)
    (pending : info.completed < info.routines.length) (present : result.globals.position ≠ 0)
    {readers : Readers} (equations : Equations (sourceReaders readers) NativeDomain)
    (tail : calls.applicationTail = (sourceReaders readers).statement.applicationTail)
    (actual : calls.actualAfter = Predicate.actualAfter)
    (flow : calls.initialFlow = fun context => ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments))
    (returned : calls.functionReturnAfter = functionReturnAfter) :
    ∃ source : RoutineCode frames readers, (source.entry specRows).Form frames.signature.info.stateSchema ∧
      ∃ initialized after,
        (source.definition specRows).checkPhased frames.signature.info.stateSchema
          (ApplicationPackageCalls.completedEnvironment info) source.context (source.phases specRows) =
            some (initialized, after) := by
  have capacity := globalsFramed.typed.scalarCount
  have signatureTyped := frames.signature_typed textValid globalsFramed typed
  have scope := frames.body_scope initial tables declarations clear capacity signatureTyped bounds declared writes
  have legal := frames.body_domain textValid globalsFramed typed present
  obtain ⟨locals, outputRows, outputs, initialized, localSource, outputHistory, outputSource,
      readable, initializedCheck, domainEq, declaredEq⟩ :=
    Silver.ApplicationPackageInitializers.CompletionFrames.source_initialization
      specified specValid specFrame specOrder specEmpty frames textValid
      (frames.entry_reader textValid globalsFramed typed) tables initial origin separated actual flow
  obtain ⟨body, bodySource, bodyChecked, bodyDomain⟩ := frames.original_body equations tail legal scope present
  obtain ⟨results, resultSource, resultReadable, _, resultChecked⟩ :=
    original_results frames present returned bodyDomain tables notOuter
  let source : RoutineCode frames readers :=
    ⟨locals, outputRows, outputs, body, results, localSource, outputHistory, outputSource, bodySource, resultSource⟩
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have signatureTables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  have within : info.completed < frames.signature.info.routines.length := by rw [signatureTables.lengths.2]; exact pending
  have member : frames.signature.info.routineAt (info.completed + 1) ∈ frames.signature.info.routines := by
    simp only [PackageBindings.Metadata.routineAt, Nat.add_one_sub_one, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some]
    exact List.getElem_mem within
  have bodyInterfaces := frames.body_interfaces interfaces
  have modes := frames.body_formal_modes declared
  have closed := frames.closed_context tables
  have shape : frames.bodySource.context.names.shape = Bindings.emptyShape := by
    rw [closed.noNames]
    exact empty_names_shape
  have formed : (source.definition specRows).Form frames.signature.info.stateSchema source.context := by
    refine ⟨bodyInterfaces.routines _ member, bodyInterfaces.routine_inputs modes member,
      routineInputs_interface modes member, readable, frames.source_layout present initial capacity,
      ?_, bodyChecked.binders, ?_, resultReadable⟩
    · exact declaredEq.trans (congrArg (fun ranges : SharedRanges => ranges.view
        (layout text.length frames.signature.info frames.bodySource.context)) domainEq)
    · change StatementsWellFormed false Bindings.emptyShape body
        (ArrayBindings.booleanAnalysis frames.bodySource.context.arrayNames
          (BooleanBindings.analysis frames.bodySource.context.booleanNames))
      simpa only [closed.noArguments, shape] using bodyChecked.form
  have entered : (source.definition specRows).bodyEntry initialized.body =
      frames.bodySource.context.flow frames.bodySource.input.scan.facts := by
    rw [frames.initial_flow tables]
    exact congrArg (fun ranges => Flow.mk ScalarFunctions.entryContext ranges) declaredEq.symm
  have bodyCheck := bodyChecked.check
  change checkPackageStatements (ApplicationPackageCalls.completedEnvironment frames.signature.info)
    (source.definition specRows).layout source.context.analysis
    (frames.bodySource.context.flow frames.bodySource.input.scan.facts) source.context.booleans
    (source.definition specRows).body = some (frames.bodySource.context.flow frames.dispatched.scan.facts) at bodyCheck
  rw [frames.body_environment, ← entered] at bodyCheck
  have phaseCheck : (source.phases specRows).check
      ((source.definition specRows).entryRanges frames.signature.info.stateSchema) = some initialized := initializedCheck
  have outputCheck : ScalarFunctions.checkActuals Bindings.emptyShape source.context.analysis
      (frames.bodySource.context.flow frames.dispatched.scan.facts) source.context.booleans
      (source.definition specRows).signature.outputTypes (source.definition specRows).results = true := resultChecked
  refine ⟨source, ⟨formed, rfl⟩, initialized,
    frames.bodySource.context.flow frames.dispatched.scan.facts, ?_⟩
  simp only [RoutineDefinition.checkPhased, phaseCheck, Option.bind_some, bodyCheck, outputCheck, ite_true]

end Silver.ApplicationPackageRoutineSources
