module

public import Silver.FunctionDeclarationPreservation
public import Silver.FunctionMetadataValidity

@[expose] public section

namespace Silver.Compose

private theorem subtype_mem {environment : IntegerSubtypes.Environment} {index : Nat}
    (positive : 0 < index) (bound : index ≤ environment.items.length) :
    IntegerSubtypes.binding environment index ∈ environment.items := by
  have within : index - 1 < environment.items.length := by omega
  simp only [IntegerSubtypes.binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within,
    Option.getD_some]
  exact List.getElem_mem within

def ScalarTypeGood (value : ScalarConstraintResult) : Prop :=
  value.after = 0 ∨ value.bounds.Bounded ∧ value.bounds.lower ≤ value.bounds.upper

private theorem scalar_type_good (text : Source) (state : ParserState) (position : Nat)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ScalarTypeGood (scalarTypeAt text state position) := by
  have bound := IntegerSubtypes.lookup_bound text state.subtypeNames (skipAt text position)
    (nameAfter text (skipAt text position))
  dsimp only [scalarTypeAt]
  split
  · exact .inl rfl
  · split
    · exact .inr ⟨Integer.Interval.full_bounded, (show Integer.Interval.full.lower ≤ Integer.Interval.full.upper by decide)⟩
    · split
      · rename_i present
        exact .inr (valid.2 _ (subtype_mem (by omega) bound)).2.2.2
      · exact .inl rfl

def FunctionTypeGood (value : FunctionTypeResult) : Prop :=
  value.after = 0 ∨ value.bounds.Bounded ∧ value.bounds.lower ≤ value.bounds.upper

theorem functionTypeAt_good (text : Source) (state : ParserState) (position : Nat)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    FunctionTypeGood (functionTypeAt text state position) := by
  dsimp only [functionTypeAt]
  split
  · rename_i present
    exact .inr ((scalar_type_good text state position valid).resolve_left present)
  · split
    · exact .inl rfl
    · exact .inr ⟨Integer.Interval.full_bounded, (show Integer.Interval.full.lower ≤ Integer.Interval.full.upper by decide)⟩

theorem function_nameAfter_bound (text : Source) (position : Nat) :
    nameAfter text position ≤ text.length + 1 := by
  unfold nameAfter
  split
  · exact Nat.zero_le _
  · by_cases zero : Named.identifierEnd text position = 0
    · simp only [zero]; omega
    · exact (Named.identifierEnd_bounds text position zero).2

theorem arrayTypeAt_bound (text : Source) (state : ParserState) (position : Nat) :
    arrayTypeAt text state position ≤ state.arrayNames.types.length := by
  dsimp only [arrayTypeAt]
  split
  · exact Nat.zero_le _
  · exact ArrayBindings.lookupType_bound ..

theorem formalTypeAt_good (text : Source) (state : ParserState) (position : Nat)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    FunctionTypeGood (formalTypeAt text state position) := by
  dsimp only [formalTypeAt]
  split
  · exact functionTypeAt_good text state position subtypes
  · rename_i nominal
    have item := arrays.type_valid (by omega : 0 < arrayTypeAt text state position)
      (arrayTypeAt_bound text state position)
    exact .inr ⟨item.2.2.2.1, item.2.2.2.2.1⟩

theorem formalTypeAt_nominal (text : Source) (state : ParserState) (position : Nat) :
    (formalTypeAt text state position).typeId ≠ 0 →
      (formalTypeAt text state position).kind = .integer := by
  dsimp only [formalTypeAt]
  split
  · dsimp only [functionTypeAt]
    split
    · intro _; rfl
    · split <;> simp
  · intro _; rfl

/-- Every nominal formal comes from an actual visible type lookup. The scalar
fallback returns identity zero and therefore needs no catalogue assumption. -/
theorem formalTypeAt_typeId_bound (text : Source) (state : ParserState) (position : Nat) :
    (formalTypeAt text state position).typeId ≤ state.arrayNames.types.length := by
  dsimp only [formalTypeAt]
  split
  · dsimp only [functionTypeAt]
    split
    · exact Nat.zero_le _
    · split <;> exact Nat.zero_le _
  · exact arrayTypeAt_bound text state position

theorem newNameAllowed_span (text : Source) (state : ParserState) (first after : Nat) (arguments : Bool)
    (allowed : newNameAllowed text state first after arguments = true) : 0 < first ∧ first < after := by
  simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
  omega


structure ParameterExtension (text : Source) (before after : ParserState) : Prop where
  valid : FunctionBindings.ValidMetadata text after.functions
  subtypes : after.subtypeNames = before.subtypeNames
  firstParameter : after.firstParameter = before.firstParameter
  items : after.functions.items = before.functions.items
  grows : before.functions.parameters.length < after.functions.parameters.length
  parameterPrefix : ∃ more, after.functions.parameters = before.functions.parameters ++ more
  arrayTypes : after.arrayNames.types = before.arrayNames.types

def ParameterResultValid (text : Source) (before after : ParserState) : Prop :=
  after.position = 0 ∨ ParameterExtension text before after

theorem parameterStep_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : FunctionBindings.ValidMetadata text state.functions)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ParameterResultValid text state (parameterStep text state arguments).state := by
  dsimp only [parameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize startEq : fixedAfter text (fixedAfter text after ":" false) "in" true = start
  generalize valueEq : formalTypeAt text state start = value
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
    have space : state.functions.parameters.length < FunctionBindings.maxFormals := by
      have capped := metadata.2.1
      omega
    have nominal := formalTypeAt_nominal text state start
    rw [valueEq] at nominal
    have known := formalTypeAt_typeId_bound text state start
    rw [valueEq] at known
    have itemValid : FunctionBindings.ValidFormal text ⟨first, after, value.kind, value.bounds, value.typeId⟩ :=
      ⟨⟨span.1, span.2, bound⟩, typeGood.1, typeGood.2, nominal, Nat.le_trans known arrays.1⟩
    have extended := FunctionBindings.appendFormal_valid metadata space itemValid
    split
    · right
      exact ⟨extended, rfl, rfl, rfl, by simp [FunctionBindings.appendFormal], ⟨_, rfl⟩, rfl⟩
    · split
      · right
        exact ⟨extended, rfl, rfl, rfl, by simp [FunctionBindings.appendFormal], ⟨_, rfl⟩, rfl⟩
      · exact .inl rfl

theorem parametersModel_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : FunctionBindings.ValidMetadata text state.functions)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ParameterResultValid text state (parametersModel text state arguments) := by
  rw [parametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have stepValid := (parameterStep_valid text state arguments metadata subtypes arrays).resolve_left nonzero
    split
    · exact .inr stepValid
    · split
      · have nextSubtypes : IntegerSubtypes.ValidEnvironment text (parameterStep text state arguments).state.subtypeNames :=
          stepValid.subtypes.symm ▸ subtypes
        have nextArrays : ArrayBindings.ValidTypes text (parameterStep text state arguments).state.arrayNames.types :=
          stepValid.arrayTypes.symm ▸ arrays
        rcases parametersModel_valid text (parameterStep text state arguments).state arguments stepValid.valid nextSubtypes nextArrays
          with rejected | rest
        · exact .inl rejected
        · right
          refine ⟨rest.valid, rest.subtypes.trans stepValid.subtypes,
            rest.firstParameter.trans stepValid.firstParameter, rest.items.trans stepValid.items,
            Nat.lt_trans stepValid.grows rest.grows, ?_, rest.arrayTypes.trans stepValid.arrayTypes⟩
          obtain ⟨first, firstEq⟩ := stepValid.parameterPrefix
          obtain ⟨more, moreEq⟩ := rest.parameterPrefix
          exact ⟨first ++ more, by rw [moreEq, firstEq, List.append_assoc]⟩
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parametersAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (metadata : FunctionBindings.ValidMetadata text state.functions)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ParameterResultValid text state (parametersAt text state arguments) :=
  parametersModel_valid text state arguments metadata subtypes arrays

end Silver.Compose
