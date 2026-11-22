module

public import Silver.ComposeNativeValueBounds

@[expose] public section

namespace Silver.Compose.Expressions

variable {contextFirst : Nat}

theorem model_literal_operands (text : Source) (position : Nat) :
    (literalAt text position).operands ≤ maxExpressionOperands := by
  unfold literalAt
  split <;> simp [invalidValue, maxExpressionOperands]

theorem model_image_operands (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    (imageAt text position names scalarNames integerHidden arrays initials elaborating).operands ≤ maxExpressionOperands := by
  unfold imageAt
  dsimp only
  split <;> simp [invalidValue, imageValue, maxExpressionOperands]

theorem model_slice_operands (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    (indexedAt (contextFirst := contextFirst) text position names scalarNames arrays initials elaborating false).operands ≤ maxExpressionOperands := by
  unfold indexedAt
  dsimp only
  simp only [Bool.false_eq_true, ↓reduceIte]
  split
  · simp [invalidValue, maxExpressionOperands]
  · split
    · simp [invalidValue, maxExpressionOperands]
    · rename_i allowed
      split
      · simp [invalidValue, maxExpressionOperands]
      · change (indexedParts text position names scalarNames arrays initials elaborating false).lower.operands +
          (indexedParts text position names scalarNames arrays initials elaborating false).upper.operands + 1 ≤ maxExpressionOperands
        simp only [not_or] at allowed
        omega

theorem model_value_operands (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    (valueAt (contextFirst := contextFirst) text position names scalarNames integerHidden arrays initials elaborating).operands ≤ maxExpressionOperands := by
  unfold valueAt
  dsimp only
  split
  · exact model_literal_operands text _
  · split
    · exact model_slice_operands (contextFirst := contextFirst) text position names scalarNames arrays initials elaborating
    · split
      · change 1 ≤ maxExpressionOperands
        decide
      · exact model_image_operands text position names scalarNames integerHidden arrays initials elaborating

theorem model_literal_native (text : Source) (valid : ValidText text) (position : Nat) :
    NativeValue text (literalAt text position) := by
  have indices := model_literal_index_bounds text valid position
  exact ⟨model_literal_valid text valid position, model_literal_operands text position, indices.1, indices.2⟩

theorem model_image_native (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    NativeValue text (imageAt text position names scalarNames integerHidden arrays initials elaborating) := by
  have indices := model_image_index_bounds text position names
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating)
  exact ⟨model_image_valid text position names scalarNames integerHidden arrays initials elaborating,
    model_image_operands text position names scalarNames integerHidden arrays initials elaborating, indices.1, indices.2⟩

theorem model_value_native (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : NativeNames text names) :
    NativeValue text (valueAt (contextFirst := contextFirst) text position names scalarNames integerHidden arrays initials elaborating) := by
  have indices := model_value_index_bounds (contextFirst := contextFirst) text valid position names
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating) namesValid.bounds
  exact ⟨model_value_valid text valid position names namesValid.base,
    model_value_operands (contextFirst := contextFirst) text position names scalarNames integerHidden arrays initials elaborating, indices.1, indices.2⟩

theorem model_scan_native (text : Source) (valid : ValidText text) (names : BindingEnvironment)
    (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : NativeNames text names) (scanValid : NativeScan text scan) :
    NativeScan text (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating) ∧
      ((expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).position = 0 ∨
       (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).complete = true ∨
       scan.position < (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).position) := by
  have base := model_scan_valid (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
    text valid names scan namesValid.base scanValid.base
  have indices := model_scan_index_bounds (contextFirst := contextFirst) text valid names scan
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating) namesValid.bounds ⟨scanValid.firstIndex, scanValid.lastIndex⟩
  exact ⟨⟨base.1, indices.1, indices.2⟩, base.2⟩

end Silver.Compose.Expressions
