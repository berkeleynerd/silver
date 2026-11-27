module

public import Silver.ProcedureDeclarationReadings
public import Silver.CallableTypeHistory
public import Silver.ProcedureMetadataSemantics
public import Silver.FunctionInitializerShape

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

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
  generalize valueEq : formalTypeAt text state start = value
  generalize modeEq : (if inEnd = 0 then ProcedureBindings.Mode.output else
    if outEnd = 0 then .input else .inputOutput) = mode
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
  generalize valueEq : formalTypeAt text state start = value
  generalize modeEq : (if inEnd = 0 then ProcedureBindings.Mode.output else
    if outEnd = 0 then .input else .inputOutput) = mode
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
    generalize valueEq : formalTypeAt text state start = value at rejected ⊢
    generalize modeEq : (if inEnd = 0 then ProcedureBindings.Mode.output else
      if outEnd = 0 then .input else .inputOutput) = mode at rejected ⊢
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
        valid.2.2.2.2.2.2.2.1 valid.arrayTypes).resolve_left rejected
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
  arrayTypes : (procedureHeaderFrame text state arguments).arrayNames.types = state.arrayNames.types
  firstPositive : 0 < (procedureHeaderFrame text state arguments).firstProcedureParameter
  signature : ProcedureBindings.ValidSignature text (procedureHeaderFrame text state arguments).procedures
    (procedureSourceEntry (procedureHeaderFrame text state arguments)
      (procedureNameFirst text state) (procedureNameAfter text state))
  functions : (procedureHeaderFrame text state arguments).functions = state.functions
  known : ∀ formal ∈ (procedureHeaderFrame text state arguments).procedures.parameters.drop
      ((procedureHeaderFrame text state arguments).firstProcedureParameter - 1),
    formal.typeId ≤ (procedureHeaderFrame text state arguments).arrayNames.types.length
  catalogPrefix : ProcedureBindings.catalogSignatures (procedureHeaderFrame text state arguments).procedures
      (procedureHeaderFrame text state arguments).arrayNames.types =
    ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types

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
      empty.2.2.2.1, Nat.le_refl _, empty.2.2.2.2.2.1, ArrayBindings.ValidNativeEnvironment.emptyItems valid.arrayTypes,
      valid.2.2.2.2.2.2.2.1, empty.booleans, valid.functions, Nat.zero_le _, Nat.zero_le _,
      valid.procedures, Nat.le_refl _, cap, Names.validContext_default text⟩
  have headerValid : ValidState text header := procedureParametersModel_state_valid initialValid
  have frameValid : ValidState text frame := model_state_position_valid text header headerValid _
    (fixedAfter_result_bound text _ "is" true (by decide))
  have fields : ProcedureParameterFields initial header := procedureParametersAt_fields stages.parameters
  have headerInfo : ProcedureParameterExtension text initial header :=
    (procedureParametersAt_valid text initial arguments initialValid.procedures initialValid.2.2.2.2.2.2.2.1 initialValid.arrayTypes).resolve_left
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
  obtain ⟨more, extended, known⟩ := headerInfo.parameterPrefix
  change header.procedures.parameters = state.procedures.parameters ++ more at extended
  have suffix : ∀ formal ∈ frame.procedures.parameters.drop (frame.firstProcedureParameter - 1),
      formal.typeId ≤ frame.arrayNames.types.length := by
    intro formal member
    rw [first, Nat.add_sub_cancel] at member
    change formal ∈ header.procedures.parameters.drop state.procedures.parameters.length at member
    rw [extended, List.drop_left] at member
    change formal.typeId ≤ header.arrayNames.types.length
    rw [headerInfo.arrayTypes]
    exact known _ member
  have catalogPrefix : ProcedureBindings.catalogSignatures frame.procedures frame.arrayNames.types =
      ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types := by
    have catalog : header.procedures = {state.procedures with parameters := state.procedures.parameters ++ more} := by
      calc
        header.procedures = ⟨header.procedures.items, header.procedures.parameters⟩ := rfl
        _ = _ := by rw [headerInfo.items, extended]; rfl
    change ProcedureBindings.catalogSignatures header.procedures header.arrayNames.types = _
    rw [catalog, headerInfo.arrayTypes]
    exact ProcedureBindings.catalogSignatures_append_parameters state.procedures more valid.procedures
  exact ⟨frameValid, closed, emptyIntegers, emptyBooleans, headerInfo.arrayTypes, firstPositive, signature, headerInfo.functions, suffix, catalogPrefix⟩

private theorem procedure_formalModels_parameter_mem (catalog : ProcedureBindings.Metadata)
    (first count index : Nat) (types : ArrayBindings.TypeEnvironment) (lower : first ≤ index) (upper : index < first + count) :
    ProcedureBindings.formalModel (ProcedureBindings.parameter catalog index) types ∈
      ProcedureBindings.formalModels catalog first count types := by
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
theorem procedure_formalModels_writable (catalog : ProcedureBindings.Metadata) (first : Nat) (types : ArrayBindings.TypeEnvironment)
    (positive : 0 < first) (within : first ≤ catalog.parameters.length)
    (writable : (catalog.parameters.drop (first - 1)).any (fun formal => formal.mode != .input) = true) :
    ScalarProcedures.outputTypes
      (ProcedureBindings.formalModels catalog first (catalog.parameters.length - first + 1) types) ≠ [] := by
  obtain ⟨formal, member, selected⟩ := List.any_eq_true.mp writable
  obtain ⟨offset, bounded, slot⟩ := List.mem_drop_iff_getElem.mp member
  have formalAt : ProcedureBindings.parameter catalog (first + offset) = formal := by
    have index : first + offset - 1 = first - 1 + offset := by omega
    simpa only [ProcedureBindings.parameter, List.getD_eq_getElem?_getD, index,
      List.getElem?_eq_getElem (show first - 1 + offset < catalog.parameters.length by omega), Option.getD_some] using slot
  have present := procedure_formalModels_parameter_mem catalog first (catalog.parameters.length - first + 1)
    (first + offset) types (by omega) (by omega)
  rw [formalAt] at present
  have noninput : (ProcedureBindings.formalModel formal types).mode ≠ .input := by
    cases mode : formal.mode <;>
      simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel]
  intro empty
  exact noninput ((procedure_outputTypes_empty _).mp empty _ present)

theorem procedureHeader_signature_valid {text state arguments}
    (valid : ValidState text state) (stages : ProcedureHeaderStages text state arguments) :
    (ProcedureBindings.signatureModel (procedureHeaderFrame text state arguments).procedures
      (procedureSourceEntry (procedureHeaderFrame text state arguments)
        (procedureNameFirst text state) (procedureNameAfter text state))
      (procedureHeaderFrame text state arguments).arrayNames.types).Valid := by
  have ready := procedureHeader_ready valid stages
  let frame := procedureHeaderFrame text state arguments
  apply ProcedureBindings.signatureModel_valid ready.valid.procedures ready.signature ready.valid.arrayTypes
  · intro i lower upper
    have positive := ready.firstPositive
    have start := ready.signature.2.2.2.1
    change frame.firstProcedureParameter ≤ i at lower
    change i < frame.firstProcedureParameter + (frame.procedures.parameters.length - frame.firstProcedureParameter + 1) at upper
    change 0 < frame.firstProcedureParameter at positive
    change frame.firstProcedureParameter ≤ frame.procedures.parameters.length at start
    have inside : i - 1 < frame.procedures.parameters.length := by omega
    apply ready.known
    change ProcedureBindings.parameter frame.procedures i ∈ frame.procedures.parameters.drop (frame.firstProcedureParameter - 1)
    apply List.mem_drop_iff_getElem.mpr
    refine ⟨i - frame.firstProcedureParameter, by omega, ?_⟩
    change frame.procedures.parameters[frame.firstProcedureParameter - 1 + (i - frame.firstProcedureParameter)] =
      ProcedureBindings.parameter frame.procedures i
    have same : frame.firstProcedureParameter - 1 + (i - frame.firstProcedureParameter) = i - 1 := by omega
    simp only [ProcedureBindings.parameter, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside,
      Option.getD_some]
    exact getElem_congr_idx same
  · exact procedure_formalModels_writable frame.procedures frame.firstProcedureParameter frame.arrayNames.types
      ready.firstPositive ready.signature.2.2.2.1 stages.writable

/-- The accepted body restores the outer type table and retains the complete
formal pool supplied by the parsed header. -/
theorem procedureDeclarationAt_callable_types_known {text state arguments}
    (valid : ValidState text state) (known : CallableTypesKnown state)
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    CallableTypesKnown (procedureDeclarationAt text state arguments) := by
  have stages := procedureDeclarationAt_stages accepted
  have ready := procedureHeader_ready valid stages
  have initial : CallableTypesKnown (procedureHeaderInitial text state) := ⟨known.functions, known.procedures⟩
  have header := procedureParametersModel_callable_types_known text _ arguments initial
  have frame : CallableTypesKnown (procedureHeaderFrame text state arguments) := ⟨header.functions, header.procedures⟩
  rw [stages.equation, procedureBodyAt_installed stages.body]
  refine ⟨known.functions, ?_⟩
  intro formal member
  have bounded := frame.procedures formal member
  change formal.typeId ≤ state.arrayNames.types.length
  simpa only [ready.arrayTypes] using bounded

end Silver.Compose
