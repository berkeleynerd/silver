module

public import Silver.ComposeContracts
public import Silver.ComposeArrayElaboration
public import Silver.ComposeStateBounds

@[expose] public section

namespace Silver.Compose.Expressions

variable {domain : StateDomain}

/-- A single initialized-value update preserves the native parser invariant.
The native ordered metadata invariant is retained; source compactness is unnecessary. -/
theorem model_putArray_valid {text : Source} {state : ParserState} {value : Int}
    (valid : ValidState text state) (room : state.arrayNames.used < ArrayBindings.maxElements)
    (safe : Integer.InRange value) : ValidState text (putArrayValue state value) := by
  rcases valid with ⟨position, names, dynamic, target, capacity, scalarNames,
    ⟨metadata, used, initials, allocated⟩, subtypes⟩
  refine ⟨position, names, dynamic, target, capacity, scalarNames, ⟨metadata,
    by dsimp only [putArrayValue]; omega, ?_, ?_⟩, subtypes⟩
  · exact putInitial_valid initials (by omega) safe
  · intro item present
    have prior := allocated item present
    dsimp only [putArrayValue]
    omega

theorem ArrayValuesDomain.room {text source result position length parsed}
    (valid : ArrayValuesDomain text source result position length parsed domain)
    (remaining : parsed < length) : result.arrayNames.used < ArrayBindings.maxElements := by
  have used := valid.used
  have capacity := valid.capacity
  have sourceBound := valid.sourceValid.2.2.2.2.2.2.1.2.1
  omega

theorem ArrayValuesDomain.next {text source result position length parsed value following}
    (valid : ArrayValuesDomain text source result position length parsed domain)
    (remaining : parsed < length) (safe : Integer.InRange value)
    (positionValid : ValidCursor text following) :
    ArrayValuesDomain text source (putArrayValue result value) following length (parsed + 1) domain where
  sourceContext := valid.sourceContext
  resultContext := NativeState.transportScalar valid.resultContext
    (model_putArray_valid valid.resultValid (valid.room remaining) safe) rfl rfl
  positionValid := positionValid
  parsedBound := by omega
  capacity := valid.capacity
  used := by dsimp only [putArrayValue]; have same := valid.used; omega

theorem model_arrayScalar_valid (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : ValidCursor text position) :
    ValidCursor text (ScalarExpression.read text position names 0 0 true arrays initials elaborating).after ∧
      (ScalarExpression.read text position names 0 0 true arrays initials elaborating).bounds.Bounded := by
  by_cases zero : (ScalarExpression.read text position names 0 0 true arrays initials elaborating).after = 0
  · rw [ScalarExpression.read_arrays_zero zero]
    exact ⟨Nat.zero_le _, Integer.Interval.empty_bounded⟩
  · obtain ⟨expression, reading⟩ := ScalarExpression.read_sound bound zero
    exact ⟨reading.cursorBounds.2.2, Integer.Expr.infer_bounded reading.inferred⟩

structure ArrayPartsBounds (text : Source) (parts : ArrayDeclarationParts) : Prop where
  first : ValidCursor text parts.first
  after : ValidCursor text parts.after
  lowerStart : ValidCursor text (fixedAfter text parts.arrayAfter "(" false)
  lowerAfter : ValidCursor text parts.lower.after
  lowerBounds : parts.lower.bounds.Bounded
  upperStart : ValidCursor text (fixedAfter text parts.lower.after ".." false)
  upperAfter : ValidCursor text parts.upper.after
  upperBounds : parts.upper.bounds.Bounded
  typeFirst : ValidCursor text parts.typeFirst
  typeAfter : ValidCursor text parts.typeAfter
  componentBounds : parts.componentBounds.Bounded
  position : ValidCursor text parts.position

theorem model_arrayParts_valid (text : Source) (state : ParserState)
    (position : ValidCursor text state.position)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayPartsBounds text (arrayDeclarationParts text state) := by
  have first := model_skip_valid text state.position position
  have after := model_name_valid text (declarationFirst text state)
  have colon : ValidCursor text (declarationColonAfter text state) := model_fixed_valid text _ ":" false after
  have constant : ValidCursor text (declarationConstantAfter text state) := model_fixed_valid text _ "constant" true colon
  have selected : ValidCursor text (if declarationConstantAfter text state ≠ 0 then
      declarationConstantAfter text state else declarationColonAfter text state) := by split <;> assumption
  have array := model_fixed_valid text _ "array" true selected
  have lowerStart := model_fixed_valid text _ "(" false array
  have lower := model_arrayScalar_valid text _ state.scalarNames state.arrayNames.names state.arrayNames.values true lowerStart
  have upperStart := model_fixed_valid text _ ".." false lower.1
  have upper := model_arrayScalar_valid text _ state.scalarNames state.arrayNames.names state.arrayNames.values true upperStart
  have close := model_fixed_valid text _ ")" false upper.1
  have ofAfter := model_fixed_valid text _ "of" true close
  have typeFirst := model_skip_valid text _ ofAfter
  have typeAfter := scalarTypeAt_position_valid text state (arrayDeclarationParts text state).typeFirst
  have components := scalarTypeAt_bounded text state (arrayDeclarationParts text state).typeFirst subtypes
  have assignment := model_fixed_valid text _ ":=" false typeAfter
  have position := model_fixed_valid text _ "(" false assignment
  exact ⟨first, after, lowerStart, lower.1, lower.2, upperStart, upper.1, upper.2,
    typeFirst, typeAfter, components, position⟩

/-- Native validity is preserved by every recursive aggregate step, including
rejected readings. This does not assume source-level compact allocation. -/
theorem model_arrayValues_valid (text : Source) (source result : ParserState)
    (position length parsed : Nat) (componentBounds : Integer.Interval)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    ValidState text (arrayValuesModel text source result position length parsed componentBounds) := by
  rw [arrayValuesModel]
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
    exact model_invalid_state_valid text
  · simp only [zero, ↓reduceIte]
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte]
      generalize valueEq : ScalarExpression.read text position source.scalarNames
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
        (elaborating := true) = value
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
          value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte]
        exact model_invalid_state_valid text
      · simp only [bad, ↓reduceIte]
        have present : (ScalarExpression.read text position source.scalarNames
            (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
            (elaborating := true)).after ≠ 0 := by rw [valueEq]; intro missing; exact bad (Or.inl missing)
        obtain ⟨expression, raw⟩ := ScalarExpression.read_sound context.positionValid present
        have reading : ScalarExpression.At text source.scalarNames position expression value
            (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
            (elaborating := true) := by rw [← valueEq]; exact raw
        have bounds := Integer.Expr.infer_bounded reading.inferred
        have nextPosition : ValidCursor text
            (if parsed + 1 < length then fixedAfter text value.after "," false else value.after) := by
          split
          · exact model_fixed_valid text value.after "," false reading.cursorBounds.2.2
          · exact reading.cursorBounds.2.2
        exact model_arrayValues_valid text source (putArrayValue result value.bounds.lower)
          _ length (parsed + 1) componentBounds (context.next remaining bounds.1 nextPosition)
    · simp only [remaining, ↓reduceDIte]
      exact ⟨context.positionValid, context.resultValid.2⟩
termination_by length - parsed
decreasing_by omega

end Silver.Compose.Expressions
