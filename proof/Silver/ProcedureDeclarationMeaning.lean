module

public import Silver.ProcedureDeclarationReadings
public import Silver.ProcedureDeclarationHeaderMeaning
public import Silver.ProcedurePrefixMeaning
public import Silver.FunctionLocalAnalysis
public import Silver.ScalarProcedureDefinition
public import Silver.PredicateBodySound
public import Silver.PredicateBodyMeaning
public import Silver.PredicateBodyUnique
public import Silver.PredicateProcedureBodyShape
public import Silver.ScalarProcedureLayout
public import Silver.ProcedureDeclarationPreservation

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

def sourceProcedureDefinition (signature : ScalarProcedures.Signature) (functionCount : Nat)
    (integers : List Integer.Declaration) (booleans : List BooleanDeclaration)
    (checks : List Integer.Obligation) (booleanChecks : List Predicate.Obligation)
    (initializers : List ScalarFunctions.Actual) (body : List Predicate.Statement) : ScalarProcedures.Definition :=
  ⟨signature, functionCount, integers, booleans, checks, booleanChecks, initializers, body⟩

/-- The ordinary body starts from the frame constructed by actual local
declarations, input-formal installation and source-written out assignments. -/
structure ProcedureInitializationReady (text : Source) (frame : ParserState) (arguments : Bool)
    (integers : List Integer.Declaration) (booleans : List BooleanDeclaration)
    (checks : List Integer.Obligation) (booleanChecks : List Predicate.Obligation) : Prop where
  inputValid : ValidState text (procedureSourceStart text frame arguments)
  inputClosed : ClosedFunctionState (procedureSourceStart text frame arguments)
  inputReady : ScalarMetadata.HeaderReady (procedureSourceStart text frame arguments).scalarNames
  inputCount : (functionLocals text frame arguments).scalarNames.length ≤
    (procedureSourceStart text frame arguments).scalarNames.length
  valid : ValidState text (procedureSourceReady text frame arguments)
  closed : ClosedFunctionState (procedureSourceReady text frame arguments)
  headerReady : ScalarMetadata.HeaderReady (procedureSourceReady text frame arguments).scalarNames
  count : (functionLocals text frame arguments).scalarNames.length ≤
    (procedureSourceReady text frame arguments).scalarNames.length
  contextClosed : ClosedFunctionContext (procedureSourceContext text frame arguments)
  contextReady : ScalarMetadata.ContextReady (procedureSourceContext text frame arguments).scalarNames
    (procedureSourceContext text frame arguments).declarationCount
    (procedureSourceContext text frame arguments).elaborating
  flowReady : ScalarMetadata.FlowReady (procedureSourceContext text frame arguments).scalarNames
    (procedureSourceContext text frame arguments).declarationCount (procedureSourceScan text frame arguments).facts
  initializersChecked : FunctionInitializersChecked integers booleans checks booleanChecks

theorem ProcedureInitializationSource.valid {text frame arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (valid : ValidState text frame) (positive : 0 < frame.firstProcedureParameter) :
    ValidState text (procedureSourceReady text frame arguments) := by
  have firstPositive : 0 < (functionLocals text frame arguments).firstProcedureParameter := by
    rw [source.locals.preserves.firstProcedureParameter]
    exact positive
  have inputValid := source.inputs.valid (source.locals.valid valid) firstPositive
  have startValid : ValidState text (procedureSourceStart text frame arguments) :=
    model_state_position_valid text _ inputValid _ (fixedAfter_result_bound text _ "begin" true (by decide))
  have inputFields := source.inputs.fields
  have startPositive : 0 < (procedureSourceStart text frame arguments).firstProcedureParameter := by
    change 0 < (procedureInputFrame text (functionLocals text frame arguments)).firstProcedureParameter
    rw [inputFields]
    exact firstPositive
  exact source.prefixRead.valid startValid startPositive

theorem ProcedureInitializationSource.framesReady {text frame arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (positive : 0 < frame.firstProcedureParameter) :
    ProcedureInitializationReady text frame arguments integers booleans checks booleanChecks := by
  let localFrame := functionLocals text frame arguments
  let bound := procedureInputFrame text localFrame
  let start := procedureSourceStart text frame arguments
  let final := procedureSourceReady text frame arguments
  have localValid : ValidState text localFrame := source.locals.valid valid
  have localClosed : ClosedFunctionState localFrame := source.locals.closed closed
  have localReady : ScalarMetadata.HeaderReady localFrame.scalarNames := source.locals.headerReady (by
    rw [emptyIntegers]
    exact ScalarMetadata.headerReady_empty)
  have firstPositive : 0 < localFrame.firstProcedureParameter := by
    rw [source.locals.preserves.firstProcedureParameter]
    exact positive
  have boundValid : ValidState text bound := source.inputs.valid localValid firstPositive
  have boundReady : ScalarMetadata.HeaderReady bound.scalarNames :=
    source.inputs.headerReady localValid firstPositive localReady
  have boundFields : ProcedureFrameFields localFrame bound := source.inputs.fields
  have boundClosed : ClosedFunctionState bound := by
    rw [boundFields]
    exact ⟨localClosed.pure, localClosed.noArguments, localClosed.noNames, localClosed.noArrays⟩
  have startValid : ValidState text start := model_state_position_valid text bound boundValid _
    (fixedAfter_result_bound text _ "begin" true (by decide))
  have startClosed : ClosedFunctionState start :=
    ⟨boundClosed.pure, boundClosed.noArguments, boundClosed.noNames, boundClosed.noArrays⟩
  have startPositive : 0 < start.firstProcedureParameter := by
    change 0 < bound.firstProcedureParameter
    rw [boundFields]
    exact firstPositive
  have finalValid : ValidState text final := source.prefixRead.valid startValid startPositive
  have finalReady : ScalarMetadata.HeaderReady final.scalarNames :=
    source.prefixRead.headerReady startValid startPositive boundReady
  have finalFields : ProcedurePrefixFields start final := source.prefixRead.fields
  have finalClosed : ClosedFunctionState final := by
    rw [finalFields]
    exact ⟨startClosed.pure, startClosed.noArguments, startClosed.noNames, startClosed.noArrays⟩
  have count : localFrame.scalarNames.length ≤ final.scalarNames.length :=
    Nat.le_trans source.inputs.grows.1 source.prefixRead.grows.1
  have contextClosed : ClosedFunctionContext (procedureSourceContext text frame arguments) := by
    refine ⟨finalClosed.pure, ?_, finalClosed.noNames, finalClosed.noArrays⟩
    change decide (final.dynamicFirst ≠ 0) = false
    simp only [finalClosed.noArguments, ne_eq, not_true_eq_false, decide_false]
  exact ⟨startValid, startClosed, boundReady, source.inputs.grows.1,
    finalValid, finalClosed, finalReady, count, contextClosed,
    functionFrame_contextReady localFrame.scalarNames.length finalValid finalReady count,
    functionFrame_flowReady localFrame.scalarNames.length finalValid finalReady _,
    source.locals.initializers_checked valid closed emptyIntegers emptyBooleans⟩

theorem ProcedureInitializationSource.start_fields
    {text frame arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals) :
    ProcedurePrefixFields (functionLocals text frame arguments) (procedureSourceStart text frame arguments) := by
  have preserved := source.inputs.fields
  unfold ProcedureFrameFields at preserved
  unfold ProcedurePrefixFields procedureSourceStart
  rw [preserved]

theorem ProcedureInitializationSource.formals
    {text frame first after arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after)) :
    ProcedureBindings.formalModels (procedureSourceStart text frame arguments).procedures
      (procedureSourceStart text frame arguments).firstProcedureParameter
      ((procedureSourceStart text frame arguments).procedures.parameters.length + 1 -
        (procedureSourceStart text frame arguments).firstProcedureParameter) =
      (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after)).formals := by
  have metadata := congrArg ParserState.procedures source.start_fields
  change (procedureSourceStart text frame arguments).procedures =
    (functionLocals text frame arguments).procedures at metadata
  have parameterStart := congrArg ParserState.firstProcedureParameter source.start_fields
  change (procedureSourceStart text frame arguments).firstProcedureParameter =
    (functionLocals text frame arguments).firstProcedureParameter at parameterStart
  rw [metadata, parameterStart, source.locals.preserves.procedures,
    source.locals.preserves.firstProcedureParameter]
  have formalCount : frame.procedures.parameters.length + 1 - frame.firstProcedureParameter =
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1 := by
    have firstBound : frame.firstProcedureParameter ≤ frame.procedures.parameters.length := signatureValid.2.2.2.1
    omega
  change ProcedureBindings.formalModels frame.procedures frame.firstProcedureParameter
      (frame.procedures.parameters.length + 1 - frame.firstProcedureParameter) =
    ProcedureBindings.formalModels frame.procedures frame.firstProcedureParameter
      (frame.procedures.parameters.length - frame.firstProcedureParameter + 1)
  rw [formalCount]

/-- The fixed prefix-reading frame has exactly the local declarations followed
by input-capable formals, with separate scalar-store indexes. -/
theorem ProcedureInitializationSource.input_analyses
    {text frame first after arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after)) :
    let formals := (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after)).formals
    functionScalarAnalysis (procedureSourceStart text frame arguments)
      (functionLocals text frame arguments).scalarNames.length =
        ScalarProcedures.parameterAnalysis integers.length (ScalarProcedures.inputFormals formals)
          (Integer.Analysis.ofDeclarations integers) ∧
    BooleanBindings.analysis (procedureSourceStart text frame arguments).booleanNames =
      ScalarProcedures.parameterBooleans booleans.length (ScalarProcedures.inputFormals formals)
        (booleanBodyAnalysis booleans) ∧
    (procedureSourceStart text frame arguments).scalarNames.length =
      integers.length + ScalarProcedures.integerCount (ScalarProcedures.inputTypes formals) ∧
    (procedureSourceStart text frame arguments).booleanNames.length =
      booleans.length + ScalarProcedures.booleanCount (ScalarProcedures.inputTypes formals) := by
  let localFrame := functionLocals text frame arguments
  have scalarCount : localFrame.scalarNames.length = integers.length := by
    simpa only [emptyIntegers, List.length_nil, Nat.zero_add] using source.locals.scalar_length
  have booleanCount : localFrame.booleanNames.length = booleans.length := by
    simpa only [emptyBooleans, List.length_nil, Nat.zero_add] using source.locals.boolean_length
  have analyses := source.inputs.analyses localFrame.scalarNames.length (Nat.le_refl _)
  have lengths := source.inputs.lengths
  have formalCount : localFrame.procedures.parameters.length + 1 - localFrame.firstProcedureParameter =
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1 := by
    rw [source.locals.preserves.procedures, source.locals.preserves.firstProcedureParameter]
    have firstBound : frame.firstProcedureParameter ≤ frame.procedures.parameters.length := signatureValid.2.2.2.1
    omega
  rw [formalCount, source.locals.preserves.procedures, source.locals.preserves.firstProcedureParameter,
    source.locals.local_analysis valid emptyIntegers (by simp [ParserState.StoredArrays, closed.noArrays]),
    source.locals.local_boolean_analysis valid emptyBooleans closed.noArrays,
    scalarCount, booleanCount] at analyses
  rw [formalCount, source.locals.preserves.procedures, source.locals.preserves.firstProcedureParameter,
    scalarCount, booleanCount] at lengths
  dsimp only
  rw [scalarCount]
  exact ⟨analyses.1, analyses.2, lengths.1, lengths.2⟩

/-- The ordinary body uses the declared domains of the actual appended out
bindings. Prefix expression refinements are not exported to this body frame. -/
theorem ProcedureInitializationSource.output_analyses
    {text frame first after arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after)) :
    let formals := (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after)).formals
    functionScalarAnalysis (procedureSourceReady text frame arguments)
      (functionLocals text frame arguments).scalarNames.length =
        ScalarProcedures.parameterAnalysis
          (integers.length + ScalarProcedures.integerCount (ScalarProcedures.inputTypes formals))
          (ScalarProcedures.outFormals formals)
          (ScalarProcedures.parameterAnalysis integers.length (ScalarProcedures.inputFormals formals)
            (Integer.Analysis.ofDeclarations integers)) ∧
    BooleanBindings.analysis (procedureSourceReady text frame arguments).booleanNames =
      ScalarProcedures.parameterBooleans
        (booleans.length + ScalarProcedures.booleanCount (ScalarProcedures.inputTypes formals))
        (ScalarProcedures.outFormals formals)
        (ScalarProcedures.parameterBooleans booleans.length (ScalarProcedures.inputFormals formals)
          (booleanBodyAnalysis booleans)) := by
  have input := source.input_analyses valid closed emptyIntegers emptyBooleans signatureValid
  have result := source.prefixRead.analyses (functionLocals text frame arguments).scalarNames.length
    source.inputs.grows.1
  rw [source.formals signatureValid, input.1, input.2.1, input.2.2.1, input.2.2.2] at result
  exact result

theorem ProcedureInitializationSource.prefix_checked
    {text frame first after arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after))
    (functionCount : Nat) (body : List Predicate.Statement) :
    let definition := sourceProcedureDefinition
      (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after))
      functionCount integers booleans checks booleanChecks actuals body
    (∀ actual ∈ actuals, actual.Readable false Bindings.emptyShape definition.inputBooleanAnalysis) ∧
      definition.prefixCheck = true ∧ actuals.all ScalarFunctions.scalarActual = true := by
  let definition := sourceProcedureDefinition
    (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after))
    functionCount integers booleans checks booleanChecks actuals body
  let start := procedureSourceStart text frame arguments
  let declarations := (functionLocals text frame arguments).scalarNames.length
  let context := procedurePrefixContext start declarations
  let facts := procedurePrefixFacts start declarations
  have frames := source.framesReady valid closed emptyIntegers emptyBooleans signatureValid.2.2.1
  have input := source.input_analyses valid closed emptyIntegers emptyBooleans signatureValid
  have contextClosed : ClosedFunctionContext context := by
    refine ⟨frames.inputClosed.pure, ?_, frames.inputClosed.noNames, frames.inputClosed.noArrays⟩
    change decide ((procedureSourceStart text frame arguments).dynamicFirst ≠ 0) = false
    simp only [frames.inputClosed.noArguments, ne_eq, not_true_eq_false, decide_false]
  have normal : NamesNormal context.names := by
    rw [contextClosed.noNames]
    constructor <;> simp [NamesWellTyped, Bindings.BindingEnvironment.get]
  have names : ValidNames text context.names := frames.inputValid.2.1
  have ready : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating :=
    functionFrame_contextReady declarations frames.inputValid frames.inputReady frames.inputCount
  have arrays : context.ArraysReady text := by
    simp [ParseContext.ArraysReady, contextClosed.noArrays, ArrayBindings.ValidMetadata]
  have compatible : ScalarMetadata.OverlayCompatible context.scalarNames declarations facts :=
    ScalarMetadata.initial_compatible ..
  have path : facts.path = ScalarFunctions.entryContext := by
    change initialFacts context.hasArguments = ScalarFunctions.entryContext
    simp only [contextClosed.noArguments, initialFacts, Bool.false_eq_true, ↓reduceIte]
    rfl
  have bounded : facts.path.Bounded := by
    rw [path]
    simp [ScalarFunctions.entryContext, PathFacts.Context.Bounded, PathFacts.Region.Bounded]
  have checked := source.prefixRead.meaning normal names ready arrays compatible bounded
  rw [source.formals signatureValid] at checked
  have analysis : context.analysis = definition.inputAnalysis := by
    change ArrayFlow.analysis start.arrayNames.names (functionScalarAnalysis start declarations) = _
    rw [frames.inputClosed.noArrays]
    exact input.1
  have booleansAnalysis : ArrayBindings.booleanAnalysis context.arrayNames
      (BooleanBindings.analysis context.booleanNames) = definition.inputBooleanAnalysis := by
    rw [contextClosed.noArrays]
    exact input.2.1
  have shape : context.names.shape = Bindings.emptyShape := by
    rw [contextClosed.noNames, empty_names_shape]
  have entry : context.flow facts = definition.prefixFlow := by
    have declared : context.flow facts = ⟨ScalarFunctions.entryContext, context.analysis.declared⟩ := by
      simp only [ParseContext.flow, ParseContext.analysis, contextClosed.noArrays,
        ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil,
        ArrayBindings.ranges_nil, ArrayFlow.analysis, ArrayFlow.ranges, ScalarMetadata.analysis]
      change (⟨facts.path, facts.model.scalars⟩ : Flow) = _
      rw [path]
      change (⟨ScalarFunctions.entryContext, (ActiveFlow.initial context.scalarNames _).model.scalars⟩ : Flow) = _
      rw [ActiveFlow.initial_model]
    rw [declared, analysis]
    rfl
  refine ⟨?_, ?_, source.prefixRead.scalarOnly contextClosed⟩
  · have readable := checked.1
    change ∀ actual ∈ actuals, actual.Readable context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) at readable
    rw [contextClosed.noArguments, shape, booleansAnalysis] at readable
    exact readable
  · have checkedActuals := checked.2
    change ScalarFunctions.checkActuals context.names.shape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (ScalarProcedures.outTypes definition.signature.formals) actuals = true at checkedActuals
    rw [shape, analysis, entry, booleansAnalysis] at checkedActuals
    exact checkedActuals

/-- The native prefix-assignment bit records exactly whether source initializers
were read; later procedure-body assignments are accounted for separately. -/
theorem ProcedureInitializationSource.initialized_flag
    {text frame arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals) :
    procedureSourceInitialized text frame arguments = !actuals.isEmpty := by
  apply Bool.eq_iff_iff.mpr
  simpa only [procedureSourceInitialized, decide_eq_true_eq, Bool.not_eq_true',
    List.isEmpty_eq_false_iff] using source.prefixRead.progress.2

theorem ProcedureInitializationSource.initialized_out
    {text frame first after arguments integers booleans checks booleanChecks actuals}
    (source : ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals)
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after))
    (initialized : procedureSourceInitialized text frame arguments = true) :
    ScalarProcedures.outTypes
      (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after)).formals ≠ [] := by
  have advanced : (procedureSourceStart text frame arguments).position <
      (procedureSourceReady text frame arguments).position := of_decide_eq_true initialized
  have nonempty := source.prefixRead.progress.2.mp advanced
  have length := source.prefixRead.length
  rw [source.formals signatureValid] at length
  intro empty
  rw [empty, List.length_nil] at length
  exact nonempty (List.length_eq_zero_iff.mp length)


inductive ProcedureOrdinarySource (text : Source) (frame : ParserState) (arguments : Bool) :
    List SourceStatement → Prop
  | initialized {items} : procedureSourceInitialized text frame arguments = true →
      BodyTailAt (catalog := frame.functions) (procedures := frame.procedures)
        text (procedureSourceContext text frame arguments) .endOnly
        (procedureSourceScan text frame arguments) items (procedureSourceFinal text frame arguments) →
      ProcedureOrdinarySource text frame arguments items
  | uninitialized {items} : procedureSourceInitialized text frame arguments = false →
      BodyAt (catalog := frame.functions) (procedures := frame.procedures)
        text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
        .endOnly items (procedureSourceFinal text frame arguments) →
      ProcedureOrdinarySource text frame arguments items

theorem ProcedureOrdinarySource.unique {text frame arguments left right}
    (first : ProcedureOrdinarySource text frame arguments left)
    (second : ProcedureOrdinarySource text frame arguments right) : left = right := by
  cases first with
  | initialized yes body =>
      cases second with
      | initialized _ other => exact bodyTail_unique body other
      | uninitialized no => simp only [yes, Bool.true_eq_false] at no
  | uninitialized no body =>
      cases second with
      | initialized yes => simp only [no, Bool.false_eq_true] at yes
      | uninitialized _ other => exact body_unique body other

theorem ProcedureOrdinarySource.scalarOnly {text frame arguments items}
    (source : ProcedureOrdinarySource text frame arguments items)
    (closed : ClosedFunctionContext (procedureSourceContext text frame arguments)) :
    ScalarProcedures.scalarStatements (lowerStatements items) = true := by
  cases source with
  | initialized _ body => exact bodyTail_source_procedureScalar closed body
  | uninitialized _ body => exact body_source_procedureScalar closed body

theorem ProcedureOrdinarySource.nonempty {text frame arguments items}
    (source : ProcedureOrdinarySource text frame arguments items) :
    procedureSourceInitialized text frame arguments = true ∨ lowerStatements items ≠ [] := by
  cases source with
  | initialized yes _ => exact .inl yes
  | uninitialized _ body => exact .inr (lowerStatements_nonempty (body_nonempty body))

inductive ProcedureBodySource (text : Source) (frame : ParserState) (first after : Nat)
    (arguments : Bool) : ScalarProcedures.Definition → Prop
  | parsed {integers booleans checks booleanChecks actuals items} :
      ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals →
      ProcedureOrdinarySource text frame arguments items →
      ProcedureBodySource text frame first after arguments
        (sourceProcedureDefinition
          (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after))
          (catalogSignatures frame.functions).length integers booleans checks booleanChecks actuals
          (lowerStatements items))

theorem ProcedureBodySource.signature {text frame first after arguments definition}
    (source : ProcedureBodySource text frame first after arguments definition) :
    definition.signature = ProcedureBindings.signatureModel frame.procedures
      (procedureSourceEntry frame first after) := by
  cases source
  rfl

theorem ProcedureBodySource.functionCount {text frame first after arguments definition}
    (source : ProcedureBodySource text frame first after arguments definition) :
    definition.functionCount = (catalogSignatures frame.functions).length := by
  cases source
  rfl

theorem procedureBodyAt_source {text outer frame first after arguments}
    (textValid : ValidText text) (valid : ValidState text frame)
    (positive : 0 < frame.firstProcedureParameter)
    (accepted : (procedureBodyAt text outer frame first after arguments).position ≠ 0) :
    ∃ definition, ProcedureBodySource text frame first after arguments definition := by
  have stages := procedureBodyAt_stages accepted
  obtain ⟨integers, booleans, checks, booleanChecks, actuals, initialization⟩ :=
    procedureBodyAt_initialization textValid valid positive accepted
  have ready := initialization.valid valid positive
  have names : ValidNames text (procedureSourceContext text frame arguments).names := ready.2.1
  have cursor : (procedureSourceScan text frame arguments).position ≤ text.length + 1 := ready.1
  cases initialized : procedureSourceInitialized text frame arguments with
  | false =>
      have acceptedBody : (readBody (catalog := frame.functions) (procedures := frame.procedures)
          text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
          .endOnly).position ≠ 0 := by
        simpa only [procedureSourceFinal, initialized, Bool.false_eq_true, ↓reduceIte] using stages.body
      obtain ⟨items, body⟩ := body_sound (catalog := frame.functions) (procedures := frame.procedures)
        text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
        .endOnly textValid names cursor acceptedBody
      refine ⟨_, .parsed (items := items) initialization (.uninitialized initialized ?_)⟩
      simpa only [procedureSourceFinal, initialized, Bool.false_eq_true, ↓reduceIte] using body
  | true =>
      have acceptedBody : (bodyTail (catalog := frame.functions) (procedures := frame.procedures)
          text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
          .endOnly).position ≠ 0 := by
        simpa only [procedureSourceFinal, initialized, ↓reduceIte] using stages.body
      obtain ⟨items, body⟩ := bodyTail_sound (catalog := frame.functions) (procedures := frame.procedures)
        text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
        .endOnly textValid names cursor acceptedBody
      refine ⟨_, .parsed (items := items) initialization (.initialized initialized ?_)⟩
      simpa only [procedureSourceFinal, initialized, ↓reduceIte] using body


inductive ProcedureDeclarationSource (text : Source) (state : ParserState) (arguments : Bool) :
    ScalarProcedures.Definition → Prop
  | parsed {definition} :
      (procedureDeclarationAt text state arguments).position ≠ 0 →
      ProcedureBodySource text (procedureHeaderFrame text state arguments)
        (procedureNameFirst text state) (procedureNameAfter text state) arguments definition →
      ProcedureDeclarationSource text state arguments definition

theorem ProcedureDeclarationSource.accepted {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) :
    (procedureDeclarationAt text state arguments).position ≠ 0 := by
  cases source
  assumption

theorem procedureDeclarationAt_source {text state arguments}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    ∃ definition, ProcedureDeclarationSource text state arguments definition := by
  have stages := procedureDeclarationAt_stages accepted
  have ready := procedureHeader_ready valid stages
  obtain ⟨definition, source⟩ := procedureBodyAt_source textValid ready.valid ready.firstPositive stages.body
  exact ⟨definition, .parsed accepted source⟩

theorem ProcedureDeclarationSource.catalog {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) (valid : ValidState text state) :
    ProcedureBindings.catalogSignatures (procedureDeclarationAt text state arguments).procedures =
      ProcedureBindings.catalogSignatures state.procedures ++ [definition.signature] := by
  cases source with
  | parsed accepted body =>
    have stages := procedureDeclarationAt_stages accepted
    have ready := procedureHeader_ready valid stages
    rw [stages.equation, (procedureBodyAt_stages stages.body).procedures,
      ProcedureBindings.catalogSignatures_append, ready.catalogPrefix, body.signature]

theorem ProcedureDeclarationSource.functionCount {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) (valid : ValidState text state) :
    definition.functionCount = (catalogSignatures state.functions).length := by
  cases source with
  | parsed accepted body =>
    have ready := procedureHeader_ready valid (procedureDeclarationAt_stages accepted)
    rw [body.functionCount, ready.functions]

/-- Local and mandatory-prefix checks, scalar source shape and the visible
function prefix establish readiness independently of the ordinary-body check. -/
theorem ProcedureBodySource.ready {text frame first after arguments definition}
    (source : ProcedureBodySource text frame first after arguments definition)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after))
    (semanticSignature : (ProcedureBindings.signatureModel frame.procedures
      (procedureSourceEntry frame first after)).Valid) :
    definition.ready (catalogSignatures frame.functions) = true := by
  cases source with
  | @parsed integers booleans checks booleanChecks actuals items initialization ordinary =>
    let definition := sourceProcedureDefinition
      (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after))
      (catalogSignatures frame.functions).length integers booleans checks booleanChecks actuals (lowerStatements items)
    have frames := initialization.framesReady valid closed emptyIntegers emptyBooleans signatureValid.2.2.1
    have prefixChecked := initialization.prefix_checked valid closed emptyIntegers emptyBooleans signatureValid
      (catalogSignatures frame.functions).length (lowerStatements items)
    have localCheck : definition.localCheck = true :=
      (definition.localCheck_iff).mpr ⟨frames.initializersChecked.integerDeclarations,
        frames.initializersChecked.integerChecks, frames.initializersChecked.booleanChecks,
        frames.initializersChecked.booleanCheck⟩
    have scalar : definition.scalarOnly = true := by
      change (integers.all (fun item => ScalarFunctions.scalarExpression item.value) &&
        booleans.all (fun item => ScalarFunctions.scalarCondition item.value) &&
        actuals.all ScalarFunctions.scalarActual && ScalarProcedures.scalarStatements (lowerStatements items)) = true
      rw [frames.initializersChecked.scalarIntegers, frames.initializersChecked.scalarBooleans,
        prefixChecked.2.2, ordinary.scalarOnly frames.contextClosed]
      rfl
    have nonempty : ScalarProcedures.outTypes definition.signature.formals ≠ [] ∨ definition.body ≠ [] := by
      rcases ordinary.nonempty with initialized | body
      · exact .inl (initialization.initialized_out signatureValid initialized)
      · exact .inr body
    exact (definition.ready_iff _).mpr ⟨localCheck, prefixChecked.2.1,
      definition.outputCheck_of_layout semanticSignature.2.1, scalar, nonempty, Nat.le_refl _⟩

theorem ProcedureDeclarationSource.ready {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) (valid : ValidState text state) :
    definition.ready (catalogSignatures state.functions) = true := by
  cases source with
  | parsed accepted body =>
    have stages := procedureDeclarationAt_stages accepted
    have header := procedureHeader_ready valid stages
    have prepared := body.ready header.valid header.closed header.emptyIntegers header.emptyBooleans
      header.signature (procedureHeader_signature_valid valid stages)
    rw [header.functions] at prepared
    exact prepared

/-- Source frame validity and the actual body reading establish the semantic
procedure check, including its local declarations and fixed output prefix. -/
theorem ProcedureBodySource.checked {text frame first after arguments definition}
    (source : ProcedureBodySource text frame first after arguments definition)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (signatureValid : ProcedureBindings.ValidSignature text frame.procedures (procedureSourceEntry frame first after))
    (semanticSignature : (ProcedureBindings.signatureModel frame.procedures
      (procedureSourceEntry frame first after)).Valid) :
    definition.Checked (catalogSignatures frame.functions) (ProcedureBindings.catalogSignatures frame.procedures) := by
  have sourceReady := source.ready valid closed emptyIntegers emptyBooleans signatureValid semanticSignature
  cases source with
  | @parsed integers booleans checks booleanChecks actuals items initialization ordinary =>
    let definition := sourceProcedureDefinition
      (ProcedureBindings.signatureModel frame.procedures (procedureSourceEntry frame first after))
      (catalogSignatures frame.functions).length integers booleans checks booleanChecks actuals (lowerStatements items)
    let context := procedureSourceContext text frame arguments
    let scan := procedureSourceScan text frame arguments
    let final := procedureSourceFinal text frame arguments
    have frames := initialization.framesReady valid closed emptyIntegers emptyBooleans signatureValid.2.2.1
    have contextClosed : ClosedFunctionContext context := frames.contextClosed
    have analyses := initialization.output_analyses valid closed emptyIntegers emptyBooleans signatureValid
    have prefixChecked := initialization.prefix_checked valid closed emptyIntegers emptyBooleans signatureValid
      (catalogSignatures frame.functions).length (lowerStatements items)
    have normal : NamesNormal context.names := by
      rw [contextClosed.noNames]
      constructor <;> simp [NamesWellTyped, Bindings.BindingEnvironment.get]
    have names : ValidNames text context.names := frames.valid.2.1
    have arrays : context.ArraysReady text := by
      simp [ParseContext.ArraysReady, contextClosed.noArrays, ArrayBindings.ValidMetadata]
    have base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount :=
      frames.contextReady.toBaseReady
    have path : scan.facts.path = ScalarFunctions.entryContext := by
      change initialFacts context.hasArguments = ScalarFunctions.entryContext
      simp only [contextClosed.noArguments, initialFacts, Bool.false_eq_true, ↓reduceIte]
      rfl
    have bounded : scan.facts.path.Bounded := by
      rw [path]
      simp [ScalarFunctions.entryContext, PathFacts.Context.Bounded, PathFacts.Region.Bounded]
    have meaning : SourceStatementsWellFormed context.hasArguments context.names.shape items
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
        checkStatements (signatures := catalogSignatures frame.functions)
          (procedures := ProcedureBindings.catalogSignatures frame.procedures)
          context.names.shape context.analysis (context.flow scan.facts) (lowerStatements items)
          (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
            some (context.flow final.facts) ∧ final.facts.path.Bounded := by
      cases ordinary with
      | initialized _ body =>
          exact bodyTail_meaning valid.functions valid.procedures rfl normal base arrays frames.valid.booleans.1
            names frames.flowReady.compatible bounded body
      | uninitialized _ body =>
          exact body_meaning valid.functions valid.procedures rfl normal base arrays frames.valid.booleans.1
            names frames.flowReady.compatible bounded body
    have analysis : context.analysis = definition.analysis := by
      change ArrayFlow.analysis (procedureSourceReady text frame arguments).arrayNames.names
        (functionScalarAnalysis (procedureSourceReady text frame arguments)
          (functionLocals text frame arguments).scalarNames.length) = _
      rw [frames.closed.noArrays]
      exact analyses.1
    have booleansAnalysis : ArrayBindings.booleanAnalysis context.arrayNames
        (BooleanBindings.analysis context.booleanNames) = definition.booleanAnalysis := by
      rw [contextClosed.noArrays]
      exact analyses.2
    have shape : context.names.shape = Bindings.emptyShape := by
      rw [contextClosed.noNames, empty_names_shape]
    have entry : context.flow scan.facts = definition.initialFlow := by
      have declared : context.flow scan.facts = ⟨ScalarFunctions.entryContext, context.analysis.declared⟩ := by
        simp only [ParseContext.flow, ParseContext.analysis, contextClosed.noArrays,
          ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil,
          ArrayBindings.ranges_nil, ArrayFlow.analysis, ArrayFlow.ranges, ScalarMetadata.analysis]
        change (⟨scan.facts.path, scan.facts.model.scalars⟩ : Flow) = _
        rw [path]
        change (⟨ScalarFunctions.entryContext, (ActiveFlow.initial context.scalarNames _).model.scalars⟩ : Flow) = _
        rw [ActiveFlow.initial_model]
      rw [declared, analysis]
      rfl
    have formed : definition.WellFormed := by
      refine ⟨semanticSignature, frames.initializersChecked.booleanDeclarations, prefixChecked.1,
        definition.outputReads_readable semanticSignature.2.1, ?_⟩
      simpa only [contextClosed.noArguments, shape, booleansAnalysis, definition, sourceProcedureDefinition] using
        lowerStatements_wellFormed meaning.1
    refine ⟨formed, context.flow final.facts, (definition.check_iff _ _ _).mpr ⟨sourceReady, ?_⟩⟩
    simpa only [shape, analysis, entry, booleansAnalysis, definition,
      sourceProcedureDefinition, List.take_length] using meaning.2.1

theorem ProcedureDeclarationSource.checked {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) (valid : ValidState text state) :
    definition.Checked (catalogSignatures state.functions) (ProcedureBindings.catalogSignatures state.procedures) := by
  cases source with
  | parsed accepted body =>
    have stages := procedureDeclarationAt_stages accepted
    have ready := procedureHeader_ready valid stages
    have checked := body.checked ready.valid ready.closed ready.emptyIntegers ready.emptyBooleans
      ready.signature (procedureHeader_signature_valid valid stages)
    rw [ready.functions, ready.catalogPrefix] at checked
    exact checked

end Silver.Compose
