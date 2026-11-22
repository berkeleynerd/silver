module

public import Silver.ComposeContracts
public import Silver.ComposeArrayElaboration
public import Silver.ComposeStateBounds
public import Silver.PredicateNativeRanges
public import Silver.ComposeNativeValueBounds

@[expose] public section

namespace Silver.Compose.Expressions

variable {domain : StateDomain}
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] ScalarExpression.ArrayGrammar.read arrayTypeAt scalarTypeAt

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
  · intro item present stored
    have prior := allocated item present stored
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
    (names : ScalarExpression.Environment) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : ValidCursor text position) :
    ValidCursor text (ScalarExpression.ArrayGrammar.read text position names arrays 0 0 true initials elaborating).after ∧
      (ScalarExpression.ArrayGrammar.read text position names arrays 0 0 true initials elaborating).bounds.Bounded := by
  refine ⟨?_, model_scalar_index_bounds bound⟩
  by_cases zero : (ScalarExpression.ArrayGrammar.read text position names arrays 0 0 true initials elaborating).after = 0
  · rw [zero]; exact Nat.zero_le _
  · obtain ⟨expression, reading⟩ := ScalarExpression.ArrayGrammar.read_sound bound zero
    exact reading.cursorBounds.2.2

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

private theorem scalarType_nameSpan (text : Source) (state : ParserState) (position : Nat)
    (bound : ValidCursor text position) (nonzero : (scalarTypeAt text state position).after ≠ 0) :
    ValidName text position (scalarTypeAt text state position).after := by
  have after := (scalarTypeAt_after text state position).resolve_left nonzero
  have referencePositive : (QualifiedNames.read text position).after ≠ 0 := by omega
  have progress := QualifiedNames.read_success text position bound referencePositive
  have positive : position ≠ 0 := by
    intro zero
    simp [QualifiedNames.read, QualifiedNames.skip, QualifiedNames.nameAfter, zero] at referencePositive
  exact ⟨by omega, by omega, scalarTypeAt_position_valid text state position⟩



theorem model_arrayParts_valid (text : Source) (state : ParserState)
    (position : ValidCursor text state.position)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ArrayPartsBounds text (arrayDeclarationParts text state) := by
  let start := if declarationConstantAfter text state ≠ 0 then
    declarationConstantAfter text state else declarationColonAfter text state
  let namedFirst := skipAt text start
  let typeId := arrayTypeAt text state namedFirst
  have first := model_skip_valid text state.position position
  have after := model_name_valid text (declarationFirst text state)
  have colon := model_fixed_valid text (declarationAfter text state) ":" false after
  have constant := model_fixed_valid text (declarationColonAfter text state) "constant" true colon
  have startBound : ValidCursor text start := by dsimp only [start]; split <;> assumption
  have namedFirstBound := model_skip_valid text start startBound
  have namedAfterBound := model_name_valid text namedFirst
  have array := model_fixed_valid text start "array" true startBound
  have lowerStart := model_fixed_valid text (fixedAfter text start "array" true) "(" false array
  have lower := model_arrayScalar_valid text _ state.scalarNames state.arrayNames.table state.arrayNames.values true lowerStart
  have upperStart := model_fixed_valid text _ ".." false lower.1
  have upper := model_arrayScalar_valid text _ state.scalarNames state.arrayNames.table state.arrayNames.values true upperStart
  have close := model_fixed_valid text _ ")" false upper.1
  have ofAfter := model_fixed_valid text _ "of" true close
  have typeFirst := model_skip_valid text _ ofAfter
  have typeAfterBound (boolean : Bool) (cursor : Nat) :
      ValidCursor text ((if boolean then
        (⟨fixedAfter text cursor "boolean" true, Integer.Interval.full⟩ : ScalarConstraintResult)
        else scalarTypeAt text state cursor).after) := by
    split
    · exact fixedAfter_result_bound text cursor "boolean" true (by decide)
    · exact scalarTypeAt_position_valid text state cursor
  have componentBound (boolean : Bool) (cursor : Nat) :
      (if boolean then
        (⟨fixedAfter text cursor "boolean" true, Integer.Interval.full⟩ : ScalarConstraintResult)
        else scalarTypeAt text state cursor).bounds.Bounded := by
    split
    · exact Integer.Interval.full_bounded
    · exact scalarTypeAt_bounded text state cursor subtypes
  by_cases nominal : typeId ≠ 0
  · have repeated : skipAt text namedFirst = namedFirst := ScalarExpression.skip_skipped text start
    have name := arrayTypeAt_sound nominal
    rw [repeated] at name
    have positive : nameAfter text namedFirst ≠ 0 := by have bounds := name.bounds; omega
    have validType := name.valid types
    dsimp only [typeId, namedFirst, start] at nominal positive
    simp only [arrayDeclarationParts,
      nominal, ne_eq, not_false_eq_true, ↓reduceIte, positive, decide_false,
      Bool.false_and, Bool.false_eq_true]
    refine ⟨first, after, lowerStart, namedAfterBound, ?_, ?_, namedAfterBound, ?_,
      namedFirstBound, namedAfterBound, validType.2.2.1, ?_⟩
    · exact ⟨validType.1.1, validType.1.1⟩
    · exact fixedAfter_result_bound text _ ".." false (by decide)
    · exact ⟨validType.1.2, validType.1.2⟩
    · exact fixedAfter_result_bound text _ "(" false (by decide)
  · dsimp only [typeId, namedFirst, start] at nominal
    simp only [arrayDeclarationParts, nominal, ↓reduceIte]
    exact ⟨first, after, lowerStart, lower.1, lower.2, upperStart, upper.1, upper.2,
      typeFirst, typeAfterBound _ _, componentBound _ _,
      fixedAfter_result_bound text _ "(" false (by decide)⟩

theorem model_arrayParts_typeName (text : Source) (state : ParserState)
    (position : ValidCursor text state.position)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (present : (arrayDeclarationParts text state).position ≠ 0) :
    ValidName text (arrayDeclarationParts text state).typeFirst
      (arrayDeclarationParts text state).typeAfter := by
  let parts := arrayDeclarationParts text state
  have bounds := model_arrayParts_valid text state position subtypes types
  have typePositive : parts.typeAfter ≠ 0 := by
    exact model_fixed_input_nonzero text _ ":=" false
      (model_fixed_input_nonzero text _ "(" false present)
  by_cases anonymous : parts.typeId = 0
  ·
    cases kind : parts.isBoolean with
    | true =>
      have same : parts.typeAfter = fixedAfter text parts.typeFirst "boolean" true := by
        have unnamed : (arrayDeclarationParts text state).typeId = 0 := by simpa only [parts] using anonymous
        have flag : (arrayDeclarationParts text state).isBoolean = true := kind
        dsimp only [parts]
        unfold arrayDeclarationParts at unnamed flag ⊢
        dsimp only at unnamed flag ⊢
        simp only [unnamed, ne_eq, not_true_eq_false, ↓reduceIte] at flag ⊢
        simp only [flag, ↓reduceIte]
      have nonzero := same ▸ typePositive
      have firstPositive := model_fixed_input_nonzero text _ "boolean" true nonzero
      have advance := model_fixed_advances text _ "boolean" true bounds.typeFirst (by decide) nonzero
      change ValidName text parts.typeFirst parts.typeAfter
      rw [same]
      exact ⟨Nat.pos_of_ne_zero firstPositive, advance, same ▸ bounds.typeAfter⟩
    | false =>
      have same : parts.typeAfter = (scalarTypeAt text state parts.typeFirst).after := by
        have same := (arrayParts_anonymous anonymous kind).1
        exact (congrArg ScalarConstraintResult.after same).symm
      change ValidName text parts.typeFirst parts.typeAfter
      rw [same]
      exact scalarType_nameSpan text state parts.typeFirst bounds.typeFirst (same ▸ typePositive)
  · have header := (arrayParts_named anonymous).1
    cases header with
    | anonymous absent => contradiction
    | named _ reading _ _ _ =>
        cases reading with
        | named firstPositive identifier _ _ _ =>
            have skipped : skipAt text parts.typeFirst = parts.typeFirst := by
              have nonzero := anonymous
              dsimp only [parts, arrayDeclarationParts] at nonzero ⊢
              simp only [nonzero, ne_eq, not_false_eq_true, ↓reduceIte]
              exact ScalarExpression.skip_skipped text _
            have span := Named.identifier_bounds identifier
            rw [skipped] at firstPositive span
            exact ⟨Nat.pos_of_ne_zero firstPositive, span.2.2.1, span.2.2.2⟩

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
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
        (elaborating := true) = value
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
          value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte]
        exact model_invalid_state_valid text
      · simp only [bad, ↓reduceIte]
        have present : (ScalarExpression.ArrayGrammar.read text position source.scalarNames
            (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
            (elaborating := true)).after ≠ 0 := by rw [valueEq]; intro missing; exact bad (Or.inl missing)
        obtain ⟨expression, raw⟩ := ScalarExpression.ArrayGrammar.read_sound context.positionValid present
        have reading : ScalarExpression.ArrayGrammar.At text source.scalarNames position expression value
            (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
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

theorem model_booleanInitializer_bound (text : Source) (valid : ValidText text)
    (state : ParserState) (position maskFirst maskAfter : Nat)
    (names : ValidNames text state.names) (bounded : ValidCursor text position) :
    ValidCursor text (booleanInitializerAfter text state position maskFirst maskAfter) :=
  Predicate.Native.condition_bound text _ position _ valid names bounded

theorem model_booleanArrayValues_valid (text : Source) (valid : ValidText text) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    ValidState text (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter) := by
  rw [booleanArrayValuesModel]
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
    exact model_invalid_state_valid text
  · simp only [zero, ↓reduceIte]
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte]
      by_cases failed : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [failed, ↓reduceIte]
        exact model_invalid_state_valid text
      · simp only [failed, ↓reduceIte]
        have valueBound := model_booleanInitializer_bound text valid source position maskFirst maskAfter
          context.sourceValid.2.1 context.positionValid
        have nextPosition : ValidCursor text
            (if parsed + 1 < length then fixedAfter text
              (booleanInitializerAfter text source position maskFirst maskAfter) "," false
             else booleanInitializerAfter text source position maskFirst maskAfter) := by
          split
          · exact fixedAfter_result_bound text _ "," false (by decide)
          · exact valueBound
        exact model_booleanArrayValues_valid text valid source (putArrayValue result 0)
          _ length (parsed + 1) maskFirst maskAfter
          (context.next remaining (by decide +kernel) nextPosition)
    · simp only [remaining, ↓reduceDIte]
      exact ⟨context.positionValid, context.resultValid.2⟩
termination_by length - parsed
decreasing_by omega

end Silver.Compose.Expressions
