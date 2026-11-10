module

public import Silver.ProcedureDeclarationReadings
public import Silver.ProcedureHeaderValidity
public import Silver.ProcedurePrefixMeaning
public import Silver.FunctionLocalAnalysis
public import Silver.ScalarProcedureDefinition

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

end Silver.Compose
