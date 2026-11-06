module

public import Silver.ComposeContracts

@[expose] public section

/-! Bounds supplied by native record subtypes, proved for the raw recognizer
on arbitrary native String tables. No declaration history or byte store occurs
in these domains. -/
namespace Silver.Compose.Expressions
open Named Bindings

private theorem small_singleton_bounded {value : Nat} (bound : value ≤ maxSourceLength) :
    (Integer.Interval.singleton value).Bounded := by
  simp only [Integer.Interval.Bounded, Integer.Interval.singleton, Integer.InRange,
    Integer.minValue, Integer.maxValue, maxSourceLength] at *
  omega

private theorem invalid_value_index_bounds :
    invalidValue.firstIndex.Bounded ∧ invalidValue.lastIndex.Bounded := by decide

private theorem invalid_scan_index_bounds :
    invalidExpressionState.firstIndex.Bounded ∧ invalidExpressionState.lastIndex.Bounded := by decide

private theorem invalid_result_index_bounds :
    invalidExpression.firstIndex.Bounded ∧ invalidExpression.lastIndex.Bounded := by decide

/-- Inference checks its endpoints even on arbitrary scalar/array metadata. -/
theorem model_scalar_index_bounds {text : Source} {position : Nat}
    {names : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : position ≤ text.length + 1) :
    (ScalarExpression.read text position names (arrays := arrays) (initials := initials)
      (elaborating := elaborating)).bounds.Bounded := by
  by_cases zero : (ScalarExpression.read text position names (arrays := arrays)
      (initials := initials) (elaborating := elaborating)).after = 0
  · rw [ScalarExpression.read_arrays_zero zero]
    exact Integer.Interval.empty_bounded
  · obtain ⟨expression, inferred, _, _⟩ := ScalarExpression.read_arrays_has_expression bound zero
    exact Integer.Expr.infer_bounded inferred

theorem model_literal_index_bounds (text : Source) (valid : ValidText text) (position : Nat) :
    (literalAt text position).firstIndex.Bounded ∧ (literalAt text position).lastIndex.Bounded := by
  unfold literalAt
  split
  · exact ⟨small_singleton_bounded (value := 1) (by decide), small_singleton_bounded (by
      have length := Guarded.literalLength_bound text (position + 1)
      have textBound := valid.2
      omega)⟩
  · exact invalid_value_index_bounds

theorem model_indexed_index_bounds (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating element : Bool} :
    (indexedAt text position names scalarNames arrays initials elaborating element).firstIndex.Bounded ∧
      (indexedAt text position names scalarNames arrays initials elaborating element).lastIndex.Bounded := by
  have lower : (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.Bounded :=
    model_scalar_index_bounds (fixedAfter_result_bound text _ "(" false (by decide))
  have upper : (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.Bounded :=
    model_scalar_index_bounds (fixedAfter_result_bound text _ ".." false (by decide))
  unfold indexedAt
  dsimp only
  split
  · exact invalid_value_index_bounds
  · split
    · split
      · exact invalid_value_index_bounds
      · exact ⟨small_singleton_bounded (value := 1) (by decide), small_singleton_bounded (value := 1) (by decide)⟩
    · split
      · exact invalid_value_index_bounds
      · split
        · exact invalid_value_index_bounds
        · exact ⟨lower, upper⟩

theorem model_character_index_bounds (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} :
    (characterAt text position names scalarNames arrays initials elaborating).firstIndex.Bounded ∧
      (characterAt text position names scalarNames arrays initials elaborating).lastIndex.Bounded := by
  rw [characterAt]
  dsimp only
  split
  · split
    · exact model_character_index_bounds text _ names
    · exact invalid_value_index_bounds
  · split
    · exact ⟨small_singleton_bounded (value := 1) (by decide), small_singleton_bounded (value := 1) (by decide)⟩
    · split
      · exact ⟨small_singleton_bounded (value := 1) (by decide), small_singleton_bounded (value := 1) (by decide)⟩
      · exact model_indexed_index_bounds text position names
termination_by text.length + 1 - position

theorem model_image_index_bounds (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} :
    (imageAt text position names scalarNames integerHidden arrays initials elaborating).firstIndex.Bounded ∧
      (imageAt text position names scalarNames integerHidden arrays initials elaborating).lastIndex.Bounded := by
  have scalar : (imageParts text position scalarNames arrays initials elaborating).scalar.bounds.Bounded :=
    model_scalar_index_bounds (fixedAfter_result_bound text _ "(" false (by decide))
  have lengths := image_lengthBounds_bounded _ scalar
  unfold imageAt
  dsimp only
  split
  · exact invalid_value_index_bounds
  · dsimp only [imageValue]
    refine ⟨small_singleton_bounded (value := 1) (by decide), ?_⟩
    unfold LengthSummary.ofImage
    split
    · decide
    · simp only [Integer.Interval.Bounded, Integer.InRange, Integer.minValue, Integer.maxValue]
      omega

theorem model_value_index_bounds (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesBounded : NamesBoundsValid names) :
    (valueAt text position names scalarNames integerHidden arrays initials elaborating).firstIndex.Bounded ∧
      (valueAt text position names scalarNames integerHidden arrays initials elaborating).lastIndex.Bounded := by
  unfold valueAt
  dsimp only
  split
  · exact model_literal_index_bounds text valid _
  · split
    · exact model_indexed_index_bounds text position names
    · split
      · rename_i found
        obtain ⟨_, _, info, present, _⟩ := lookupName_found found.1
        have bounded := namesBounded _ _ present
        simp only [present, Option.getD_some]
        refine ⟨⟨bounded.1, bounded.1⟩, ?_⟩
        split
        · change (Integer.Interval.mk 0 maxSourceLength).Bounded
          decide
        · exact ⟨bounded.2.1, bounded.2.1⟩
      · exact model_image_index_bounds text position names

theorem model_concatenated_first_bounded (left : ExpressionState) (right : ValueResult)
    (leftBounded : left.firstIndex.Bounded) (rightBounded : right.firstIndex.Bounded) :
    (concatenatedFirst left right).Bounded := by
  unfold concatenatedFirst
  split
  · exact rightBounded
  · split
    · exact leftBounded
    · exact Integer.Interval.join_bounded leftBounded rightBounded

/-- The explicit arithmetic guards suffice even for arbitrary accumulator fields. -/
theorem model_concatenated_last_bounded (left : ExpressionState) (right : ValueResult)
    (rightBounded : right.lastIndex.Bounded) : (concatenatedLast left right).Bounded := by
  let first := concatenatedFirst left right
  let minimum : Int := (left.minimumLength : Int) + right.minimumLength
  let maximum : Int := (left.staticLength : Int) + right.staticLength +
    ((left.dynamicCount : Int) + (if right.dynamicSeen then 1 else 0)) * maxSourceLength
  let low := first.lower + minimum - 1
  let high := first.upper + maximum - 1
  change (if left.operands = 0 ∨ (left.staticLength = 0 ∧ left.dynamicCount = 0)
    then right.lastIndex
    else if first.isEmpty = true ∨ low < Integer.minValue ∨ low > Integer.maxValue ∨
        high < Integer.minValue ∨ high > Integer.maxValue then Integer.Interval.empty
    else if minimum = 0 then (Integer.Interval.mk low high).join right.lastIndex
    else ⟨low, high⟩).Bounded
  by_cases initial : left.operands = 0 ∨ (left.staticLength = 0 ∧ left.dynamicCount = 0)
  · simpa only [initial, ↓reduceIte] using rightBounded
  · simp only [initial, ↓reduceIte]
    by_cases checked : first.isEmpty = true ∨ low < Integer.minValue ∨ low > Integer.maxValue ∨
        high < Integer.minValue ∨ high > Integer.maxValue
    · simpa only [checked, ↓reduceIte] using Integer.Interval.empty_bounded
    · simp only [checked, ↓reduceIte]
      have bounded : (Integer.Interval.mk low high).Bounded := by
        simp only [Integer.Interval.Bounded, Integer.InRange]
        simp only [not_or] at checked
        omega
      by_cases zero : minimum = 0
      · simpa only [zero, ↓reduceIte] using Integer.Interval.join_bounded bounded rightBounded
      · simpa only [zero, ↓reduceIte] using bounded

theorem model_scan_index_bounds (text : Source) (valid : ValidText text) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (scan : ExpressionState) (namesBounded : NamesBoundsValid names)
    (scanBounded : scan.firstIndex.Bounded ∧ scan.lastIndex.Bounded) :
    (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).firstIndex.Bounded ∧
      (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).lastIndex.Bounded := by
  have atom := model_value_index_bounds text valid scan.position names
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating) namesBounded
  have first := model_concatenated_first_bounded scan _ scanBounded.1 atom.1
  have last := model_concatenated_last_bounded scan _ atom.2
  unfold expressionStep
  dsimp only
  split
  · exact invalid_scan_index_bounds
  · split
    · exact scanBounded
    · split
      · split
        · exact scanBounded
        · split
          · exact invalid_scan_index_bounds
          · dsimp only
            split
            · exact ⟨first, last⟩
            · exact ⟨small_singleton_bounded (value := 1) (by decide),
                small_singleton_bounded (value := 0) (by decide)⟩
      · split
        · exact scanBounded
        · split
          · exact scanBounded
          · split
            · exact scanBounded
            · exact invalid_scan_index_bounds

theorem model_tail_index_bounds (text : Source) (valid : ValidText text) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (scan : ExpressionState) (namesBounded : NamesBoundsValid names)
    (scanBounded : scan.firstIndex.Bounded ∧ scan.lastIndex.Bounded) :
    (expressionTail text names scan scalarNames integerHidden arrays initials elaborating).firstIndex.Bounded ∧
      (expressionTail text names scan scalarNames integerHidden arrays initials elaborating).lastIndex.Bounded := by
  rw [expressionTail]
  split
  · exact invalid_result_index_bounds
  · split
    · exact scanBounded
    · dsimp only
      have next := model_scan_index_bounds text valid names scan namesBounded scanBounded
        (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
        (initials := initials) (elaborating := elaborating)
      split
      · exact invalid_result_index_bounds
      · split
        · exact next
        · split
          · exact model_tail_index_bounds text valid names _ namesBounded next
          · exact invalid_result_index_bounds
termination_by text.length + 1 - scan.position

theorem model_expression_index_bounds (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesBounded : NamesBoundsValid names) :
    (expressionAt text position names scalarNames integerHidden arrays initials elaborating).firstIndex.Bounded ∧
      (expressionAt text position names scalarNames integerHidden arrays initials elaborating).lastIndex.Bounded :=
  model_tail_index_bounds text valid names {position} namesBounded
    ⟨small_singleton_bounded (value := 1) (by decide), small_singleton_bounded (value := 0) (by decide)⟩

theorem model_expression_native (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (namesValid : NativeNames text names) :
    NativeResult text (expressionAt text position names scalarNames integerHidden arrays initials elaborating) := by
  have endpoints := model_expression_index_bounds text valid position names
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating) namesValid.bounds
  exact ⟨model_expression_valid text valid position names bound namesValid.base, endpoints.1, endpoints.2⟩

end Silver.Compose.Expressions
