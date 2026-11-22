module

public import Silver.ComposeStateBounds
public import Silver.PredicateScalarHeaderReady

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions Named Bindings

/-- Parameter headers change only the cursor, pooled formals and inherited
name-hiding flags. All local stores remain the fresh function frame. -/
def ParameterFieldsPreserved (before after : ParserState) : Prop :=
  after = {before with position := after.position, functions := after.functions, «hiding» := after.hiding}

theorem parameterStep_fields_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (parameterStep text state arguments).state.position = 0 ∨
      ParameterFieldsPreserved state (parameterStep text state arguments).state := by
  dsimp only [parameterStep]
  split
  · exact .inl rfl
  · split
    · exact .inr rfl
    · split
      · exact .inr rfl
      · exact .inl rfl

theorem parametersModel_fields_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (parametersModel text state arguments).position = 0 ∨
      ParameterFieldsPreserved state (parametersModel text state arguments) := by
  rw [parametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have step := (parameterStep_fields_or_rejected text state arguments).resolve_left nonzero
    split
    · exact .inr step
    · split
      · rcases parametersModel_fields_or_rejected text (parameterStep text state arguments).state arguments
          with rejected | rest
        · exact .inl rejected
        · right
          unfold ParameterFieldsPreserved at step rest ⊢
          calc
            _ = { (parameterStep text state arguments).state with
                position := (parametersModel text (parameterStep text state arguments).state arguments).position,
                functions := (parametersModel text (parameterStep text state arguments).state arguments).functions,
                «hiding» := (parametersModel text (parameterStep text state arguments).state arguments).hiding } := rest
            _ = _ := by rw [step]
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parametersAt_fields {text state arguments}
    (accepted : (parametersAt text state arguments).position ≠ 0) :
    ParameterFieldsPreserved state (parametersAt text state arguments) :=
  (parametersModel_fields_or_rejected text state arguments).resolve_left accepted

theorem parameterStep_cursor (text : Source) (state : ParserState) (arguments : Bool) :
    ValidCursor text (parameterStep text state arguments).state.position := by
  dsimp only [parameterStep]
  split
  · exact Nat.zero_le _
  · split
    · exact fixedAfter_result_bound text _ ")" false (by decide)
    · split
      · exact fixedAfter_result_bound text _ ";" false (by decide)
      · exact Nat.zero_le _

theorem parameterStep_state_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (parameterStep text state arguments).state := by
  by_cases rejected : (parameterStep text state arguments).state.position = 0
  · dsimp only [parameterStep] at rejected ⊢
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
  · have extension := (parameterStep_valid text state arguments valid.functions
        valid.2.2.2.2.2.2.2.1 valid.arrayTypes).resolve_left rejected
    have fields := (parameterStep_fields_or_rejected text state arguments).resolve_left rejected
    have cursor := parameterStep_cursor text state arguments
    have growth := extension.grows
    rcases valid with ⟨position, names, dynamic, target, capacity, scalars, arrays,
      subtypes, booleans, metadata, parameterBound, parameterCapacity⟩
    rw [fields]
    exact ⟨cursor, names, dynamic, target, capacity, scalars, arrays, subtypes,
      booleans, extension.valid, by dsimp; omega, parameterCapacity⟩

/-- The immutable view record installed by the native frame helper. Its
component domain is the named declaration, never the caller's initialized cells. -/
def arrayParameterBinding (frame : ParserState) (first after typeId : Nat) : ArrayBindings.Binding :=
  let item := ArrayBindings.arrayType frame.arrayNames.types typeId
  ⟨first, after, item.bounds, 0, (item.bounds.upper - item.bounds.lower + 1).toNat,
    false, item.componentBounds, false, typeId, frame.arrayNames.names.length + 1⟩

theorem appendParameter_array {frame parameter}
    (named : parameter.typeId ≠ 0)
    (accepted : (appendParameter frame parameter).position ≠ 0) :
    appendParameter frame parameter =
      {frame with arrayNames := {frame.arrayNames with names := frame.arrayNames.names ++
        [arrayParameterBinding frame parameter.first parameter.after parameter.typeId]}} := by
  rw [appendParameter, ite_eq_left named] at accepted ⊢
  unfold appendArrayParameter at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i allowed
    rw [ite_eq_right allowed]
    rfl

theorem appendParameter_type_known {frame parameter}
    (accepted : (appendParameter frame parameter).position ≠ 0) :
    parameter.typeId ≤ frame.arrayNames.types.length := by
  by_cases named : parameter.typeId ≠ 0
  · rw [appendParameter, ite_eq_left named] at accepted
    unfold appendArrayParameter at accepted
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i allowed
      simp only [not_or] at allowed
      omega
  · omega

theorem appendArrayParameter_valid {text frame first after typeId}
    (valid : ValidState text frame) (span : FunctionBindings.NameSpan text first after) :
    ValidState text (appendArrayParameter frame first after typeId) := by
  unfold appendArrayParameter
  split
  · exact model_invalid_state_valid text
  · rename_i allowed
    simp only [not_or, Classical.not_not] at allowed
    have known : typeId ≤ frame.arrayNames.types.length := by omega
    have room : frame.arrayNames.names.length < ArrayBindings.maxBindings := by
      have capacity : frame.arrayNames.names.length ≤ ArrayBindings.maxBindings := valid.arrays.1.2.1
      omega
    have shape := allowed.2.2.2.1
    have nonempty := shape.2.1
    have lengthBound := shape.length_bound
    have typed : ArrayBindings.ValidNativeBinding (arrayParameterBinding frame first after typeId) := by
      refine ⟨⟨shape.1, nonempty, ?_, ?_, ?_, shape.2.2.1, shape.2.2.2.1⟩,
        ?_, ?_, ?_, ?_⟩
      · dsimp only [arrayParameterBinding]
        omega
      · simpa only [arrayParameterBinding, Nat.zero_add] using lengthBound
      · dsimp only [arrayParameterBinding]
        omega
      · change typeId ≤ ArrayBindings.maxTypes
        exact Nat.le_trans known valid.arrayTypes.1
      · change frame.arrayNames.names.length + 1 ≤ ArrayBindings.maxBindings
        omega
      · intro _
        rfl
      · intro _
        exact ⟨allowed.1, rfl, rfl, rfl⟩
    have table := valid.arrays.1.append (item := arrayParameterBinding frame first after typeId) room span typed
      (show ArrayBindings.TypeCoherent frame.arrayNames.types (arrayParameterBinding frame first after typeId) from
        ⟨known, fun _ => ⟨rfl, rfl⟩⟩)
      (fun _ => rfl) (by
        intro positive
        have prior : (ArrayBindings.binding frame.arrayNames.names frame.arrayNames.names.length).viewSlot ≠ 0 :=
          fun zero => allowed.2.2.2.2 ⟨positive, zero⟩
        simpa only [ArrayBindings.Env.table, ArrayBindings.Adjacent, arrayParameterBinding,
          Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, false_iff, false_implies, and_true] using prior)
    have arrays : ArrayBindings.ValidNativeEnvironment text
        {frame.arrayNames with names := frame.arrayNames.names ++ [arrayParameterBinding frame first after typeId]} := by
      refine ⟨table, valid.arrays.2.1, valid.arrays.2.2.1, ?_⟩
      intro item member stored
      rcases List.mem_append.mp member with old | fresh
      · exact valid.arrays.2.2.2 item old stored
      · have same := List.mem_singleton.mp fresh
        subst item
        simp [arrayParameterBinding] at stored
    exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
      valid.2.2.2.2.1, valid.2.2.2.2.2.1, arrays, valid.2.2.2.2.2.2.2⟩

theorem appendParameter_valid {text frame parameter}
    (valid : ValidState text frame) (typed : FunctionBindings.ValidFormal text parameter) :
    ValidState text (appendParameter frame parameter) := by
  unfold appendParameter
  split
  · exact appendArrayParameter_valid valid typed.1
  · split
    · split
      · exact model_invalid_state_valid text
      · rename_i room
        have space : frame.scalarNames.length < ScalarExpression.maxBindings := by
          have bounded := valid.2.2.2.2.2.1.1
          omega
        have scalars := ScalarExpression.validEnvironment_append valid.2.2.2.2.2.1 space
          (item := {first := parameter.first, after := parameter.after, bounds := parameter.bounds, isStatic := false, declaredBounds := parameter.bounds, mutable := false})
          ⟨typed.1.1, typed.1.2.1, typed.1.2.2, typed.2.1, typed.2.1⟩
        exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
          valid.2.2.2.2.1, scalars, valid.2.2.2.2.2.2⟩
    · split
      · exact model_invalid_state_valid text
      · rename_i room
        have space : frame.booleanNames.length < BooleanBindings.maxBindings := by
          have bounded := valid.booleans.1
          omega
        have booleans := BooleanBindings.valid_append valid.booleans space
          (item := {first := parameter.first, after := parameter.after, mutable := false}) typed.1
        exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
          valid.2.2.2.2.1, valid.2.2.2.2.2.1, valid.2.2.2.2.2.2.1,
          valid.2.2.2.2.2.2.2.1, booleans, valid.2.2.2.2.2.2.2.2.2⟩


theorem parametersModel_state_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (parametersModel text state arguments) := by
  rw [parametersModel]
  split
  · exact model_invalid_state_valid text
  · split
    · exact parameterStep_state_valid valid
    · split
      · exact parametersModel_state_valid (parameterStep_state_valid valid)
      · exact model_invalid_state_valid text
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem functionLocalAt_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (functionLocalAt text state arguments) := by
  dsimp only [functionLocalAt]
  split
  · exact model_scalar_declaration_valid text state arguments valid
  · exact model_boolean_declaration_valid text state arguments valid

theorem functionLocalsModel_valid {text state arguments}
    (valid : ValidState text state) : ValidState text (functionLocalsModel text state arguments) := by
  rw [functionLocalsModel]
  split
  · exact model_invalid_state_valid text
  · split
    · exact valid
    · dsimp only
      split
      · exact model_invalid_state_valid text
      · split
        · exact functionLocalsModel_valid (functionLocalAt_valid valid)
        · exact model_invalid_state_valid text
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parameterFrameModel_valid {text frame} (index : Nat)
    (valid : ValidState text frame) (positive : 0 < index) :
    ValidState text (parameterFrameModel frame index) := by
  rw [parameterFrameModel]
  split
  · exact model_invalid_state_valid text
  · split
    · exact valid
    · rename_i inside
      have typed := valid.functions.2.2.1 _ (FunctionBindings.parameter_mem positive (by omega))
      have nextValid := appendParameter_valid valid typed
      dsimp only
      split
      · exact model_invalid_state_valid text
      · split
        · exact parameterFrameModel_valid (index + 1) nextValid (by omega)
        · exact model_invalid_state_valid text
termination_by frame.functions.parameters.length + 1 - index
decreasing_by all_goals omega


theorem appendParameter_headerReady {frame parameter}
    (ready : Predicate.ScalarMetadata.HeaderReady frame.scalarNames)
    (nonempty : parameter.bounds.lower ≤ parameter.bounds.upper) :
    Predicate.ScalarMetadata.HeaderReady (appendParameter frame parameter).scalarNames := by
  unfold appendParameter
  split
  · unfold appendArrayParameter
    split
    · exact Predicate.ScalarMetadata.headerReady_empty
    · exact ready
  · split
    · split
      · exact Predicate.ScalarMetadata.headerReady_empty
      · exact ready.append (by simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not]; omega)
          (by simp)
    · split
      · exact Predicate.ScalarMetadata.headerReady_empty
      · exact ready

theorem parameterFrameModel_headerReady {text frame} (index : Nat)
    (valid : ValidState text frame) (positive : 0 < index)
    (ready : Predicate.ScalarMetadata.HeaderReady frame.scalarNames) :
    Predicate.ScalarMetadata.HeaderReady (parameterFrameModel frame index).scalarNames := by
  rw [parameterFrameModel]
  split
  · exact Predicate.ScalarMetadata.headerReady_empty
  · split
    · exact ready
    · rename_i inside
      have typed := valid.functions.2.2.1 _ (FunctionBindings.parameter_mem positive (by omega))
      have nextValid := appendParameter_valid valid typed
      have nextReady := appendParameter_headerReady ready typed.2.2.1
      dsimp only
      split
      · exact Predicate.ScalarMetadata.headerReady_empty
      · split
        · exact parameterFrameModel_headerReady (index + 1) nextValid (by omega) nextReady
        · exact Predicate.ScalarMetadata.headerReady_empty
termination_by frame.functions.parameters.length + 1 - index
decreasing_by all_goals omega

private theorem localScalar_headerReady {text arguments state next declaration}
    (ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    Predicate.ScalarMetadata.HeaderReady next.scalarNames := by
  cases parsed with
  | declaration _ checked _ _ =>
      rcases checked with ⟨_, _, _, _, _, nonempty, _, lower, upper, _⟩
      exact ready.append nonempty (fun _ => ⟨lower, upper⟩)

theorem functionLocalAt_headerReady {text state arguments}
    (ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames) :
    Predicate.ScalarMetadata.HeaderReady (functionLocalAt text state arguments).scalarNames := by
  dsimp only [functionLocalAt]
  split
  · rename_i accepted
    obtain ⟨declaration, source⟩ := scalar_declaration_sound text state arguments accepted
    exact localScalar_headerReady ready source
  · dsimp only [booleanDeclarationAt]
    split
    · exact Predicate.ScalarMetadata.headerReady_empty
    · split
      · exact Predicate.ScalarMetadata.headerReady_empty
      · exact ready

theorem functionLocalsModel_headerReady {text state arguments}
    (ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames) :
    Predicate.ScalarMetadata.HeaderReady (functionLocalsModel text state arguments).scalarNames := by
  rw [functionLocalsModel]
  split
  · exact Predicate.ScalarMetadata.headerReady_empty
  · split
    · exact ready
    · dsimp only
      split
      · exact Predicate.ScalarMetadata.headerReady_empty
      · split
        · exact functionLocalsModel_headerReady (functionLocalAt_headerReady ready)
        · exact Predicate.ScalarMetadata.headerReady_empty
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

private theorem frame_empty_nameBounds : NamesBoundsValid [] := by
  intro slot info found
  simp [BindingEnvironment.get] at found

theorem functionLocalAt_nameBounds {text state arguments}
    (bounds : NamesBoundsValid state.names) : NamesBoundsValid (functionLocalAt text state arguments).names := by
  dsimp only [functionLocalAt]
  split
  · rename_i accepted
    obtain ⟨declaration, source⟩ := scalar_declaration_sound text state arguments accepted
    have names : (scalarDeclarationAt text state arguments).names = state.names := by
      generalize finalEq : scalarDeclarationAt text state arguments = final at source ⊢
      cases source
      rfl
    rw [names]
    exact bounds
  · dsimp only [booleanDeclarationAt]
    split
    · exact frame_empty_nameBounds
    · split
      · exact frame_empty_nameBounds
      · exact bounds

theorem functionLocalsModel_nameBounds {text state arguments}
    (bounds : NamesBoundsValid state.names) : NamesBoundsValid (functionLocalsModel text state arguments).names := by
  rw [functionLocalsModel]
  split
  · exact frame_empty_nameBounds
  · split
    · exact bounds
    · dsimp only
      split
      · exact frame_empty_nameBounds
      · split
        · exact functionLocalsModel_nameBounds (functionLocalAt_nameBounds bounds)
        · exact frame_empty_nameBounds
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem appendParameter_nameBounds {frame : ParserState} {parameter : FunctionBindings.Formal}
    (bounds : NamesBoundsValid frame.names) : NamesBoundsValid (appendParameter frame parameter).names := by
  unfold appendParameter
  split
  · unfold appendArrayParameter
    split
    · exact frame_empty_nameBounds
    · exact bounds
  · split <;> split
    · exact frame_empty_nameBounds
    · exact bounds
    · exact frame_empty_nameBounds
    · exact bounds

theorem parameterFrameModel_nameBounds {frame : ParserState} (index : Nat)
    (bounds : NamesBoundsValid frame.names) : NamesBoundsValid (parameterFrameModel frame index).names := by
  rw [parameterFrameModel]
  split
  · exact frame_empty_nameBounds
  · split
    · exact bounds
    · dsimp only
      split
      · exact frame_empty_nameBounds
      · split
        · exact parameterFrameModel_nameBounds (index + 1) (appendParameter_nameBounds bounds)
        · exact frame_empty_nameBounds
termination_by frame.functions.parameters.length + 1 - index
decreasing_by all_goals omega

theorem parameterStep_headerReady {text state arguments}
    (ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames) :
    Predicate.ScalarMetadata.HeaderReady (parameterStep text state arguments).state.scalarNames := by
  dsimp only [parameterStep]
  split
  · exact Predicate.ScalarMetadata.headerReady_empty
  · split
    · exact ready
    · split
      · exact ready
      · exact Predicate.ScalarMetadata.headerReady_empty

theorem parametersModel_headerReady {text state arguments}
    (ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames) :
    Predicate.ScalarMetadata.HeaderReady (parametersModel text state arguments).scalarNames := by
  rw [parametersModel]
  split
  · exact Predicate.ScalarMetadata.headerReady_empty
  · split
    · exact parameterStep_headerReady ready
    · split
      · exact parametersModel_headerReady (parameterStep_headerReady ready)
      · exact Predicate.ScalarMetadata.headerReady_empty
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parameterStep_nameBounds {text state arguments}
    (bounds : NamesBoundsValid state.names) : NamesBoundsValid (parameterStep text state arguments).state.names := by
  dsimp only [parameterStep]
  split
  · exact frame_empty_nameBounds
  · split
    · exact bounds
    · split
      · exact bounds
      · exact frame_empty_nameBounds

theorem parametersModel_nameBounds {text state arguments}
    (bounds : NamesBoundsValid state.names) : NamesBoundsValid (parametersModel text state arguments).names := by
  rw [parametersModel]
  split
  · exact frame_empty_nameBounds
  · split
    · exact parameterStep_nameBounds bounds
    · split
      · exact parametersModel_nameBounds (parameterStep_nameBounds bounds)
      · exact frame_empty_nameBounds
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

end Silver.Compose
