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
  parameterPrefix : ∃ more, after.procedures.parameters = before.procedures.parameters ++ more

def ProcedureParameterResultValid (text : Source) (before after : ParserState) : Prop :=
  after.position = 0 ∨ ProcedureParameterExtension text before after

theorem procedureParameterStep_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ProcedureParameterResultValid text state (procedureParameterStep text state arguments).state := by
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
  · rename_i admitted
    simp only [not_or, Bool.not_eq_true'] at admitted
    have allowed : newNameAllowed text state first after arguments = true :=
      Bool.eq_true_of_ne_false admitted.1
    have span := newNameAllowed_span text state first after arguments allowed
    have bound : after ≤ text.length + 1 := by
      rw [← afterEq]
      exact function_nameAfter_bound text first
    have typeGood : value.bounds.Bounded ∧ value.bounds.lower ≤ value.bounds.upper := by
      have typed := functionTypeAt_good text state start subtypes
      rw [valueEq] at typed
      exact typed.resolve_left (by omega)
    have space : state.procedures.parameters.length < ProcedureBindings.maxFormals := by
      have capped := metadata.2.1
      omega
    have itemValid : ProcedureBindings.ValidFormal text
        ⟨first, after, value.kind, value.bounds,
          if inEnd = 0 then .output else if outEnd = 0 then .input else .inputOutput⟩ :=
      ⟨⟨span.1, span.2, bound⟩, typeGood⟩
    have extended := ProcedureBindings.appendFormal_valid metadata space itemValid
    split
    · right
      exact ⟨extended, rfl, rfl, rfl, rfl, by simp [ProcedureBindings.appendFormal], ⟨_, rfl⟩⟩
    · split
      · right
        exact ⟨extended, rfl, rfl, rfl, rfl, by simp [ProcedureBindings.appendFormal], ⟨_, rfl⟩⟩
      · exact .inl rfl

theorem procedureParametersModel_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ProcedureParameterResultValid text state (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have stepValid := (procedureParameterStep_valid text state arguments metadata subtypes).resolve_left nonzero
    split
    · exact .inr stepValid
    · split
      · have nextSubtypes : IntegerSubtypes.ValidEnvironment text
            (procedureParameterStep text state arguments).state.subtypeNames :=
          stepValid.subtypes.symm ▸ subtypes
        rcases procedureParametersModel_valid text (procedureParameterStep text state arguments).state
          arguments stepValid.valid nextSubtypes with rejected | rest
        · exact .inl rejected
        · right
          refine ⟨rest.valid, rest.subtypes.trans stepValid.subtypes, rest.functions.trans stepValid.functions,
            rest.firstParameter.trans stepValid.firstParameter, rest.items.trans stepValid.items,
            Nat.lt_trans stepValid.grows rest.grows, ?_⟩
          obtain ⟨first, firstEq⟩ := stepValid.parameterPrefix
          obtain ⟨more, moreEq⟩ := rest.parameterPrefix
          exact ⟨first ++ more, by rw [moreEq, firstEq, List.append_assoc]⟩
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem procedureParametersAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : ProcedureBindings.ValidMetadata text state.procedures)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ProcedureParameterResultValid text state (procedureParametersAt text state arguments) :=
  procedureParametersModel_valid text state arguments metadata subtypes

end Silver.Compose
