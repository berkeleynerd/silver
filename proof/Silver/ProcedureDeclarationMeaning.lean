module

public import Silver.ProcedureDeclarationReadings
public import Silver.ProcedureHeaderValidity
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

/-- Header parsing changes only the source cursor, current formal pool and
name-hiding flags. The closed object frame and earlier functions are retained. -/
def ProcedureParameterFields (before after : ParserState) : Prop :=
  after = {before with position := after.position, procedures := after.procedures, «hiding» := after.hiding}

theorem procedureParameterStep_fields_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureParameterStep text state arguments).state.position = 0 ∨
      ProcedureParameterFields state (procedureParameterStep text state arguments).state := by
  dsimp only [procedureParameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize colonEq : fixedAfter text after ":" false = colonEnd
  generalize inEq : fixedAfter text colonEnd "in" true = inEnd
  generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd
  generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start
  generalize valueEq : functionTypeAt text state start = value
  split
  · exact .inl rfl
  · split
    · exact .inr rfl
    · split
      · exact .inr rfl
      · exact .inl rfl

theorem procedureParametersModel_fields_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureParametersModel text state arguments).position = 0 ∨
      ProcedureParameterFields state (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have step := (procedureParameterStep_fields_or_rejected text state arguments).resolve_left nonzero
    split
    · exact .inr step
    · split
      · rcases procedureParametersModel_fields_or_rejected text (procedureParameterStep text state arguments).state arguments
          with rejected | rest
        · exact .inl rejected
        · right
          unfold ProcedureParameterFields at step rest ⊢
          calc
            _ = {(procedureParameterStep text state arguments).state with
                position := (procedureParametersModel text (procedureParameterStep text state arguments).state arguments).position,
                procedures := (procedureParametersModel text (procedureParameterStep text state arguments).state arguments).procedures,
                «hiding» := (procedureParametersModel text (procedureParameterStep text state arguments).state arguments).hiding} := rest
            _ = _ := by rw [step]
      · exact .inl rfl
termination_by remainingAt text state.position
decreasing_by assumption

theorem procedureParametersAt_fields {text state arguments}
    (accepted : (procedureParametersAt text state arguments).position ≠ 0) :
    ProcedureParameterFields state (procedureParametersAt text state arguments) :=
  (procedureParametersModel_fields_or_rejected text state arguments).resolve_left accepted

theorem procedureParameterStep_cursor (text : Source) (state : ParserState) (arguments : Bool) :
    ValidCursor text (procedureParameterStep text state arguments).state.position := by
  dsimp only [procedureParameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize colonEq : fixedAfter text after ":" false = colonEnd
  generalize inEq : fixedAfter text colonEnd "in" true = inEnd
  generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd
  generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start
  generalize valueEq : functionTypeAt text state start = value
  split
  · exact Nat.zero_le _
  · split
    · exact fixedAfter_result_bound text _ ")" false (by decide)
    · split
      · exact fixedAfter_result_bound text _ ";" false (by decide)
      · exact Nat.zero_le _

theorem procedureParameterStep_state_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (procedureParameterStep text state arguments).state := by
  by_cases rejected : (procedureParameterStep text state arguments).state.position = 0
  · dsimp only [procedureParameterStep] at rejected ⊢
    generalize firstEq : skipAt text state.position = first at rejected ⊢
    generalize afterEq : nameAfter text first = after at rejected ⊢
    generalize colonEq : fixedAfter text after ":" false = colonEnd at rejected ⊢
    generalize inEq : fixedAfter text colonEnd "in" true = inEnd at rejected ⊢
    generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd at rejected ⊢
    generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start at rejected ⊢
    generalize valueEq : functionTypeAt text state start = value at rejected ⊢
    split at rejected
    · rename_i bad
      simpa only [bad, ↓reduceIte] using model_invalid_state_valid text
    · rename_i good
      simp only [good, ↓reduceIte]
      split at rejected
      · rename_i closed
        exact False.elim (closed rejected)
      · rename_i noClose
        simp only [noClose, ↓reduceIte]
        split at rejected
        · rename_i advanced
          exact False.elim ((Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)) rejected)
        · rename_i noAdvance
          simpa only [noAdvance, ↓reduceIte] using model_invalid_state_valid text
  · have extension := (procedureParameterStep_valid text state arguments valid.procedures
        valid.2.2.2.2.2.2.2.1).resolve_left rejected
    have fields := (procedureParameterStep_fields_or_rejected text state arguments).resolve_left rejected
    have cursor := procedureParameterStep_cursor text state arguments
    have growth := extension.grows
    rcases valid with ⟨position, names, dynamic, target, capacity, scalars, arrays,
      subtypes, booleans, functions, parameterBound, parameterCapacity, procedures, procedureBound, procedureCapacity⟩
    rw [fields]
    exact ⟨cursor, names, dynamic, target, capacity, scalars, arrays, subtypes,
      booleans, functions, parameterBound, parameterCapacity, extension.valid, by dsimp; omega, procedureCapacity⟩

theorem procedureParametersModel_state_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact model_invalid_state_valid text
  · split
    · exact procedureParameterStep_state_valid valid
    · split
      · exact procedureParametersModel_state_valid (procedureParameterStep_state_valid valid)
      · exact model_invalid_state_valid text
termination_by remainingAt text state.position
decreasing_by assumption

structure ProcedureHeaderReady (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  valid : ValidState text (procedureHeaderFrame text state arguments)
  closed : ClosedFunctionState (procedureHeaderFrame text state arguments)
  emptyIntegers : (procedureHeaderFrame text state arguments).scalarNames = []
  emptyBooleans : (procedureHeaderFrame text state arguments).booleanNames = []
  firstPositive : 0 < (procedureHeaderFrame text state arguments).firstProcedureParameter
  signature : ProcedureBindings.ValidSignature text (procedureHeaderFrame text state arguments).procedures
    (procedureSourceEntry (procedureHeaderFrame text state arguments)
      (procedureNameFirst text state) (procedureNameAfter text state))
  functions : (procedureHeaderFrame text state arguments).functions = state.functions
  catalogPrefix : ProcedureBindings.catalogSignatures (procedureHeaderFrame text state arguments).procedures =
    ProcedureBindings.catalogSignatures state.procedures

theorem procedureHeader_ready {text state arguments}
    (valid : ValidState text state) (stages : ProcedureHeaderStages text state arguments) :
    ProcedureHeaderReady text state arguments := by
  let initial := procedureHeaderInitial text state
  let header := procedureHeaderParameters text state arguments
  let frame := procedureHeaderFrame text state arguments
  have admitted := stages.allowed
  simp only [procedureHeaderRejected, not_or, Bool.not_eq_true'] at admitted
  have allowed : newNameAllowed text state (procedureNameFirst text state) (procedureNameAfter text state) arguments = true :=
    Bool.eq_true_of_ne_false admitted.2.2.2.1
  have cap : state.procedures.parameters.length + 1 ≤ ProcedureBindings.maxFormals := by
    have bounded := valid.procedures.2.1
    omega
  have empty := model_invalid_state_valid text
  have initialValid : ValidState text initial := by
    refine ⟨fixedAfter_result_bound text _ "(" false (by decide), empty.2.1, empty.2.2.1,
      empty.2.2.2.1, Nat.le_refl _, empty.2.2.2.2.2.1, empty.2.2.2.2.2.2.1,
      valid.2.2.2.2.2.2.2.1, empty.booleans, valid.functions, Nat.zero_le _, Nat.zero_le _,
      valid.procedures, Nat.le_refl _, cap⟩
  have headerValid : ValidState text header := procedureParametersModel_state_valid initialValid
  have frameValid : ValidState text frame := model_state_position_valid text header headerValid _
    (fixedAfter_result_bound text _ "is" true (by decide))
  have fields : ProcedureParameterFields initial header := procedureParametersAt_fields stages.parameters
  have headerInfo : ProcedureParameterExtension text initial header :=
    (procedureParametersAt_valid text initial arguments initialValid.procedures initialValid.2.2.2.2.2.2.2.1).resolve_left
      stages.parameters
  have closed : ClosedFunctionState frame := by
    change ClosedFunctionState {header with position := frame.position}
    rw [fields]
    exact ⟨rfl, rfl, rfl, rfl⟩
  have emptyIntegers : frame.scalarNames = [] := by
    change header.scalarNames = []
    rw [fields]
    rfl
  have emptyBooleans : frame.booleanNames = [] := by
    change header.booleanNames = []
    rw [fields]
    rfl
  have first : frame.firstProcedureParameter = state.procedures.parameters.length + 1 := headerInfo.firstParameter
  have firstPositive : 0 < frame.firstProcedureParameter := by rw [first]; omega
  have firstBound : frame.firstProcedureParameter ≤ frame.procedures.parameters.length := by
    have grows := headerInfo.grows
    change state.procedures.parameters.length < header.procedures.parameters.length at grows
    change frame.firstProcedureParameter ≤ header.procedures.parameters.length
    rw [first]
    omega
  have nameSpan := newNameAllowed_span text state _ _ arguments allowed
  have span : ProcedureBindings.NameSpan text (procedureNameFirst text state) (procedureNameAfter text state) :=
    ⟨nameSpan.1, nameSpan.2, function_nameAfter_bound text _⟩
  have signature : ProcedureBindings.ValidSignature text frame.procedures
      (procedureSourceEntry frame (procedureNameFirst text state) (procedureNameAfter text state)) :=
    ⟨span, by dsimp [procedureSourceEntry]; omega, firstPositive, firstBound, Nat.le_refl _⟩
  have catalogPrefix : ProcedureBindings.catalogSignatures frame.procedures =
      ProcedureBindings.catalogSignatures state.procedures := by
    obtain ⟨more, extended⟩ := headerInfo.parameterPrefix
    have catalog : header.procedures = {state.procedures with parameters := state.procedures.parameters ++ more} := by
      calc
        header.procedures = ⟨header.procedures.items, header.procedures.parameters⟩ := rfl
        _ = _ := by rw [headerInfo.items, extended]; rfl
    change ProcedureBindings.catalogSignatures header.procedures = _
    rw [catalog]
    exact ProcedureBindings.catalogSignatures_append_parameters state.procedures more valid.procedures
  exact ⟨frameValid, closed, emptyIntegers, emptyBooleans, firstPositive, signature, headerInfo.functions, catalogPrefix⟩

private theorem procedure_formalModels_parameter_mem (catalog : ProcedureBindings.Metadata)
    (first count index : Nat) (lower : first ≤ index) (upper : index < first + count) :
    ProcedureBindings.formalModel (ProcedureBindings.parameter catalog index) ∈
      ProcedureBindings.formalModels catalog first count := by
  induction count generalizing first with
  | zero => omega
  | succ count ih =>
      by_cases same : index = first
      · simp [ProcedureBindings.formalModels, same]
      · exact List.mem_cons_of_mem _ (ih (first + 1) (by omega) (by omega))

private theorem procedure_outputTypes_empty (formals : List ScalarProcedures.Formal) :
    ScalarProcedures.outputTypes formals = [] ↔ ∀ formal ∈ formals, formal.mode = .input := by
  induction formals with
  | nil => simp [ScalarProcedures.outputTypes]
  | cons formal formals ih =>
      rcases formal with ⟨mode, domain⟩
      cases mode <;> simp [ScalarProcedures.outputTypes, ih]

/-- Writable existence is derived from the exact admitted pooled suffix. It
does not become an extra precondition on the generic metadata helpers. -/
theorem procedure_formalModels_writable (catalog : ProcedureBindings.Metadata) (first : Nat)
    (positive : 0 < first) (within : first ≤ catalog.parameters.length)
    (writable : (catalog.parameters.drop (first - 1)).any (fun formal => formal.mode != .input) = true) :
    ScalarProcedures.outputTypes
      (ProcedureBindings.formalModels catalog first (catalog.parameters.length - first + 1)) ≠ [] := by
  obtain ⟨formal, member, selected⟩ := List.any_eq_true.mp writable
  obtain ⟨offset, bounded, slot⟩ := List.mem_drop_iff_getElem.mp member
  have formalAt : ProcedureBindings.parameter catalog (first + offset) = formal := by
    have index : first + offset - 1 = first - 1 + offset := by omega
    simpa only [ProcedureBindings.parameter, List.getD_eq_getElem?_getD, index,
      List.getElem?_eq_getElem (show first - 1 + offset < catalog.parameters.length by omega), Option.getD_some] using slot
  have present := procedure_formalModels_parameter_mem catalog first (catalog.parameters.length - first + 1)
    (first + offset) (by omega) (by omega)
  rw [formalAt] at present
  have noninput : (ProcedureBindings.formalModel formal).mode ≠ .input := by
    cases mode : formal.mode <;>
      simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel]
  intro empty
  exact noninput ((procedure_outputTypes_empty _).mp empty _ present)

theorem procedureHeader_signature_valid {text state arguments}
    (valid : ValidState text state) (stages : ProcedureHeaderStages text state arguments) :
    (ProcedureBindings.signatureModel (procedureHeaderFrame text state arguments).procedures
      (procedureSourceEntry (procedureHeaderFrame text state arguments)
        (procedureNameFirst text state) (procedureNameAfter text state))).Valid := by
  have ready := procedureHeader_ready valid stages
  apply ProcedureBindings.signatureModel_valid ready.valid.procedures ready.signature
  exact procedure_formalModels_writable (procedureHeaderFrame text state arguments).procedures
    (procedureHeaderFrame text state arguments).firstProcedureParameter ready.firstPositive
    ready.signature.2.2.2.1 stages.writable

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
    source.locals.local_analysis valid emptyIntegers,
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
