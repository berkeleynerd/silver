module

public import Silver.ProcedureHeaderAdmission
public import Silver.FunctionHeaderValidity
public import Silver.ProcedureMetadataValidity

@[expose] public section

namespace Silver.Compose

structure ProcedureParameterExtension (text : Source) (before after : ParserState) : Prop where
  valid : ProcedureBindings.ValidMetadata text after.procedures
  subtypes : after.subtypeNames = before.subtypeNames
  functions : after.functions = before.functions
  firstParameter : after.firstProcedureParameter = before.firstProcedureParameter
  items : after.procedures.items = before.procedures.items
  grows : before.procedures.parameters.length < after.procedures.parameters.length
  parameterPrefix : ∃ more, after.procedures.parameters = before.procedures.parameters ++ more ∧
    ∀ formal ∈ more, formal.typeId ≤ before.arrayNames.types.length
  arrayTypes : after.arrayNames.types = before.arrayNames.types

def ProcedureParameterResultValid (text : Source) (before after : ParserState) : Prop :=
  after.position = 0 ∨ ProcedureParameterExtension text before after

theorem procedureParameterStep_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ProcedureParameterResultValid text state (procedureParameterStep text state arguments).state := by
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
  · rename_i admitted
    simp only [not_or, Bool.not_eq_true'] at admitted
    have allowed : newNameAllowed text state first after arguments = true :=
      Bool.eq_true_of_ne_false admitted.1
    have span := newNameAllowed_span text state first after arguments allowed
    have bound : after ≤ text.length + 1 := by
      rw [← afterEq]
      exact function_nameAfter_bound text first
    have typeGood : value.bounds.Bounded ∧ value.bounds.lower ≤ value.bounds.upper := by
      have typed := formalTypeAt_good text state start subtypes arrays
      rw [valueEq] at typed
      exact typed.resolve_left (by omega)
    have space : state.procedures.parameters.length < ProcedureBindings.maxFormals := by
      have capped := metadata.2.1
      omega
    have nominal := formalTypeAt_nominal text state start
    rw [valueEq] at nominal
    have itemValid : ProcedureBindings.ValidFormal text
        ⟨first, after, value.kind, value.bounds, mode, value.typeId⟩ :=
      ⟨⟨span.1, span.2, bound⟩, typeGood.1, typeGood.2,
        fun positive => ⟨by
          by_cases same : mode = .input
          · exact same
          · exact False.elim (admitted.2.2.2.2.2 ⟨positive, same⟩), nominal positive⟩⟩
    have known := formalTypeAt_typeId_bound text state start
    rw [valueEq] at known
    have extended := ProcedureBindings.appendFormal_valid metadata space itemValid
    split
    · right
      exact ⟨extended, rfl, rfl, rfl, rfl, by simp [ProcedureBindings.appendFormal], ⟨_, rfl, by simpa only [List.mem_singleton, forall_eq] using known⟩, rfl⟩
    · split
      · right
        exact ⟨extended, rfl, rfl, rfl, rfl, by simp [ProcedureBindings.appendFormal], ⟨_, rfl, by simpa only [List.mem_singleton, forall_eq] using known⟩, rfl⟩
      · exact .inl rfl

theorem procedureParametersModel_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ProcedureParameterResultValid text state (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have stepValid := (procedureParameterStep_valid text state arguments metadata subtypes arrays).resolve_left nonzero
    split
    · exact .inr stepValid
    · split
      · have nextSubtypes : IntegerSubtypes.ValidEnvironment text
            (procedureParameterStep text state arguments).state.subtypeNames :=
          stepValid.subtypes.symm ▸ subtypes
        have nextArrays : ArrayBindings.ValidTypes text (procedureParameterStep text state arguments).state.arrayNames.types :=
          stepValid.arrayTypes.symm ▸ arrays
        rcases procedureParametersModel_valid text (procedureParameterStep text state arguments).state
          arguments stepValid.valid nextSubtypes nextArrays with rejected | rest
        · exact .inl rejected
        · right
          refine ⟨rest.valid, rest.subtypes.trans stepValid.subtypes, rest.functions.trans stepValid.functions,
            rest.firstParameter.trans stepValid.firstParameter, rest.items.trans stepValid.items,
            Nat.lt_trans stepValid.grows rest.grows, ?_, rest.arrayTypes.trans stepValid.arrayTypes⟩
          obtain ⟨first, firstEq, firstKnown⟩ := stepValid.parameterPrefix
          obtain ⟨more, moreEq, moreKnown⟩ := rest.parameterPrefix
          refine ⟨first ++ more, by rw [moreEq, firstEq, List.append_assoc], ?_⟩
          intro formal member
          rcases List.mem_append.mp member with early | later
          · exact firstKnown _ early
          · simpa only [stepValid.arrayTypes] using moreKnown _ later
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem procedureParametersAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ProcedureParameterResultValid text state (procedureParametersAt text state arguments) :=
  procedureParametersModel_valid text state arguments metadata subtypes arrays

end Silver.Compose
