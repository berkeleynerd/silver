module

public import Silver.ComposeAdmission

@[expose] public section

/-! Shared scanner domains and cursor/value bounds, independent of the native
source-expression interpretation. Scalar masking changes visibility without
changing the original String slots or their length facts. -/
namespace Silver.Compose.Expressions
open Named

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength

def ValidCursor (text : Source) (position : Nat) : Prop := position ≤ text.length + 1

def ValidName (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

def ValidInfo (text : Source) (info : BindingInfo) : Prop :=
  ValidName text info.first info.after ∧ info.valueFirst ≤ text.length + 1 ∧
    info.staticLength ≤ maxSourceLength

def ValidNames (text : Source) (names : BindingEnvironment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ info ∈ names, ValidInfo text info

def ValidValue (text : Source) (value : ValueResult) : Prop :=
  value.after ≤ text.length + 1 ∧ value.valueFirst ≤ text.length + 1 ∧
    value.staticLength ≤ maxSourceLength ∧ value.reference ≤ maxBindings ∧
    value.minimumLength ≤ maxSourceLength

def ValidResult (text : Source) (result : ExpressionResult) : Prop :=
  result.after ≤ text.length + 1 ∧ result.staticLength ≤ maxSourceLength ∧
    result.dynamicCount ≤ maxExpressionOperands ∧ result.minimumLength ≤ maxSourceLength

def ValidScan (text : Source) (scan : ExpressionState) : Prop :=
  ValidCursor text scan.position ∧ scan.staticLength ≤ maxSourceLength ∧
    scan.dynamicCount ≤ scan.operands ∧ scan.operands ≤ maxExpressionOperands ∧
    scan.depth ≤ maxSourceLength + 1 ∧ (scan.position = 0 ∨ scan.depth < scan.position) ∧
    scan.minimumLength ≤ maxSourceLength

theorem model_skip_valid (text : Source) (position : Nat)
    (bound : ValidCursor text position) : ValidCursor text (skipAt text position) := by
  by_cases zero : position = 0
  · simp [skipAt, zero, ValidCursor]
  · simpa [skipAt, zero, ValidCursor] using
      (Cursor.triviaPosition_bounds text position (by omega) bound).2

theorem model_name_valid (text : Source) (position : Nat) :
    ValidCursor text (nameAfter text position) := by
  unfold nameAfter
  split
  · simp [ValidCursor]
  · by_cases zero : identifierEnd text position = 0
    · simp [zero, ValidCursor]
    · exact (identifierEnd_bounds text position zero).2

theorem model_name_advances (text : Source) (position : Nat)
    (nonzero : nameAfter text position ≠ 0) :
    0 < position ∧ position < nameAfter text position := by
  unfold nameAfter at nonzero ⊢
  split at nonzero
  · contradiction
  · rename_i positive
    simp only [positive, ↓reduceIte]
    exact ⟨by omega, (identifierEnd_bounds text position nonzero).1⟩

theorem model_fixed_valid (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (bound : ValidCursor text position) :
    ValidCursor text (fixedAfter text position spelling word) := by
  unfold fixedAfter
  split
  · simp [ValidCursor]
  · rename_i positive
    split
    · rename_i accepted
      have start := Cursor.triviaPosition_bounds text position (by omega) bound
      have fits : spelling.toList.length ≤ text.length + 1 - Cursor.triviaPosition text position := by
        simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, List.length_map] at accepted
        exact accepted.1.1
      unfold ValidCursor
      omega
    · simp [ValidCursor]

theorem model_fixed_advances (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (bound : ValidCursor text position) (nonempty : 0 < spelling.toList.length)
    (nonzero : fixedAfter text position spelling word ≠ 0) :
    position < fixedAfter text position spelling word := by
  unfold fixedAfter at nonzero ⊢
  split at nonzero
  · contradiction
  · rename_i positive
    simp only [positive, ↓reduceIte]
    split at nonzero
    · rename_i accepted
      simp only [accepted, ↓reduceIte]
      have start := Cursor.triviaPosition_bounds text position (by omega) bound
      omega
    · contradiction

theorem model_callAfter_valid (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table} (position : Nat)
    (operation : Names.Operation) (bound : ValidCursor text position) (subtypeHidden : Bool := false) (booleans : BooleanBindings.Environment := []) :
    ValidCursor text (callAfter (scalarNames := scalarNames) (arrays := arrays) (subtypeHidden := subtypeHidden) (booleans := booleans) text names position operation) :=
  Names.operationAfter_bound text position operation _ bound

theorem model_callAfter_advances (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table} (position : Nat)
    (operation : Names.Operation) {subtypeHidden : Bool} {booleans : BooleanBindings.Environment} (bound : ValidCursor text position)
    (nonzero : callAfter (scalarNames := scalarNames) (arrays := arrays) (subtypeHidden := subtypeHidden) (booleans := booleans) text names position operation ≠ 0) :
    position < callAfter (scalarNames := scalarNames) (arrays := arrays) (subtypeHidden := subtypeHidden) (booleans := booleans) text names position operation :=
  Names.operationAfter_progress text position operation _ bound nonzero

theorem model_lookup_valid (text : Source) (names : BindingEnvironment) (first after : Nat) :
    lookupName text names first after ≤ names.length := by
  by_cases zero : lookupName text names first after = 0
  · simp [zero]
  · obtain ⟨_, _, info, present, _⟩ := lookupName_found zero
    simp only [Bindings.BindingEnvironment.get, zero, ↓reduceIte] at present
    obtain ⟨bounded, _⟩ := List.getElem?_eq_some_iff.mp present
    omega

theorem model_literal_valid (text : Source) (valid : ValidText text) (position : Nat) :
    ValidValue text (literalAt text position) := by
  unfold literalAt
  split
  · rename_i accepted
    have finish := Output.literalEnd_bounds text (position + 1) accepted.2.2.2
    have length := Guarded.literalLength_bound text (position + 1)
    simp only [ValidValue]
    exact ⟨finish.2, by omega, by obtain ⟨_, bounded⟩ := valid; omega, by simp, by obtain ⟨_, bounded⟩ := valid; omega⟩
  · simp [invalidValue, ValidValue]

theorem image_lengthBounds_bounded (bounds : Integer.Interval) (bounded : bounds.Bounded) :
    (Integer.Image.lengthBounds bounds).1 ≤ 11 ∧
      (Integer.Image.lengthBounds bounds).2 ≤ 11 := by
  have lower := Integer.Image.magnitude_bounded bounds.lower bounded.1
  have upper := Integer.Image.magnitude_bounded bounds.upper bounded.2
  have lo : Integer.Image.minimumMagnitude bounds ≤ 2147483648 := by
    simp only [Integer.Image.minimumMagnitude]
    split <;> omega
  have hi : Integer.Image.maximumMagnitude bounds ≤ 2147483648 := by
    simp only [Integer.Image.maximumMagnitude]
    omega
  have loDigits := (Integer.Image.decimalDigits_le_iff (Integer.Image.minimumMagnitude bounds) 10 (by decide)).mpr
    (show Integer.Image.minimumMagnitude bounds < 10000000000 by omega)
  have hiDigits := (Integer.Image.decimalDigits_le_iff (Integer.Image.maximumMagnitude bounds) 10 (by decide)).mpr
    (show Integer.Image.maximumMagnitude bounds < 10000000000 by omega)
  simp only [Integer.Image.lengthBounds]
  omega

theorem model_image_valid (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Table := {}) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) :
    ValidValue text (imageAt text position names scalarNames integerHidden arrays initials elaborating) := by
  by_cases rejected : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after = 0
  · dsimp only [imageAt] at rejected ⊢
    split
    · simp [ValidValue, invalidValue]
    · rename_i accepted
      simp only [accepted, Bool.false_eq_true, ↓reduceIte, imageValue] at rejected
      have progress : position < (imageParts text position scalarNames arrays initials elaborating).following := by
        simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at accepted
        omega
      omega
  · obtain ⟨expression, parsed⟩ := image_sound rejected
    rw [image_complete parsed]
    have bounded := Integer.Expr.infer_bounded parsed.scalar.inferred
    have lengths := image_lengthBounds_bounded _ bounded
    have following : (imageParts text position scalarNames arrays initials elaborating).following ≤ text.length + 1 :=
      fixedAfter_result_bound text _ ")" false (by decide)
    dsimp only [imageValue, ValidValue]
    unfold LengthSummary.ofImage
    split <;> simp only <;> unfold maxSourceLength maxBindings <;> omega

variable {contextFirst : Nat}

theorem model_indexed_valid (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating element : Bool} (namesValid : ValidNames text names) :
    ValidValue text (indexedAt (contextFirst := contextFirst) text position names scalarNames arrays initials elaborating element) := by
  have following : (indexedParts text position names scalarNames arrays initials elaborating element).following ≤ text.length + 1 :=
    fixedAfter_result_bound text _ ")" false (by decide)
  have target : (indexedParts text position names scalarNames arrays initials elaborating element).target ≤ maxBindings :=
    Nat.le_trans (model_lookup_valid text names _ _) namesValid.1
  unfold indexedAt
  dsimp only
  split
  · simp [invalidValue, ValidValue]
  · rename_i ready
    split
    · split
      · simp [invalidValue, ValidValue]
      · dsimp only [ValidValue]
        exact ⟨following, by omega, by decide, target, by decide⟩
    · split
      · simp [invalidValue, ValidValue]
      · rename_i allowed
        split
        · simp [invalidValue, ValidValue]
        · rename_i maximum
          have lowerNonempty : (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.isEmpty = false := by
            simp only [not_or, Bool.not_eq_true] at ready
            exact ready.2.2.2.2.2
          have upperNonempty : (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.isEmpty = false := by
            simp only [not_or, Bool.not_eq_true] at allowed
            exact allowed.2.1
          have lengths : StringIndexing.sliceMinimum
              (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds
              (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds ≤
              StringIndexing.sliceMaximum
              (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds
              (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds := by
            simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at lowerNonempty upperNonempty
            simp only [StringIndexing.sliceMinimum, StringIndexing.sliceMaximum, StringIndexing.sliceLength]
            omega
          dsimp only [ValidValue]
          exact ⟨following, by omega, by omega, target, by omega⟩

theorem model_value_valid (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} (namesValid : ValidNames text names) :
    ValidValue text (valueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) := by
  unfold valueAt
  dsimp only
  split
  · exact model_literal_valid text valid _
  · split
    · exact model_indexed_valid text position names namesValid
    · split
      · rename_i found
        obtain ⟨_, _, info, present, _⟩ := lookupName_found found.1
        have member : info ∈ names := by
          exact List.mem_of_getElem? (by simpa [Bindings.BindingEnvironment.get, found.1] using present)
        have infoValid := namesValid.2 info member
        have indexBound := model_lookup_valid text names (skipAt text position) (nameAfter text (skipAt text position))
        simp only [present, Option.getD_some, ValidValue]
        exact ⟨model_name_valid text _, infoValid.2.1, infoValid.2.2,
          Nat.le_trans indexBound namesValid.1, infoValid.2.2⟩
      · exact model_image_valid text position names scalarNames integerHidden arrays initials elaborating

theorem value_source_advances {text : Source} {position : Nat} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {value : Operand} {result : ValueResult} (bound : ValidCursor text position)
    (parsed : ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    position < result.after := by
  cases parsed with
  | literal positive literalBound quote source =>
      rename_i after bytes
      change position < after
      have skipped := skipAt_advances text position bound positive
      have advance := Output.literalAt_bounds source
      omega
  | reference positive source _ _ _ _ _ _ =>
      have skipped := skipAt_advances text position bound positive
      have complete := identifierEnd_complete source
      have accepted : identifierEnd text (skipAt text position) ≠ 0 := by
        rw [complete]
        have advance := identifier_bounds source
        omega
      have advance := identifierEnd_bounds text _ accepted
      simp only [stringReferenceValue]
      omega
  | slice _ _ source => exact source.following
  | image _ _ _ source => exact source.following

theorem model_value_advances (text : Source) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (nonzero : (valueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) :
    position < (valueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after := by
  obtain ⟨value, parsed⟩ := value_sound text position names nonzero
  exact value_source_advances bound parsed

theorem model_invalid_scan_valid (text : Source) : ValidScan text invalidExpressionState := by
  simp [ValidScan, ValidCursor, invalidExpressionState]

theorem model_scan_valid (text : Source) (valid : ValidText text)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} (scan : ExpressionState)
    (namesValid : ValidNames text names) (scanValid : ValidScan text scan) :
    ValidScan text (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan) ∧
      ((expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).position = 0 ∨
       (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).complete = true ∨
       scan.position < (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).position) := by
  have atomValid := model_value_valid (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text valid scan.position names namesValid
  have textBound := valid.2
  have openBound := model_fixed_valid text scan.position "(" false scanValid.1
  have joinBound := model_fixed_valid text scan.position "&" false scanValid.1
  have closeBound := model_fixed_valid text scan.position ")" false scanValid.1
  have openAdvance := model_fixed_advances text scan.position "(" false scanValid.1 (by decide)
  have joinAdvance := model_fixed_advances text scan.position "&" false scanValid.1 (by decide)
  have closeAdvance := model_fixed_advances text scan.position ")" false scanValid.1 (by decide)
  have atomAdvance := model_value_advances (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text scan.position names scanValid.1
  unfold expressionStep
  dsimp only
  split
  · exact ⟨model_invalid_scan_valid text, Or.inl rfl⟩
  · rename_i nonzero
    split
    · exact ⟨scanValid, Or.inr (Or.inl ‹scan.complete = true›)⟩
    · split
      · split
        · rename_i opened
          have advance := openAdvance opened
          simp only [ValidScan, ValidCursor] at scanValid openBound ⊢
          exact ⟨by omega, Or.inr (Or.inr advance)⟩
        · split
          · exact ⟨model_invalid_scan_valid text, Or.inl rfl⟩
          · rename_i admitted
            have nonempty : (valueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text scan.position names).after ≠ 0 := by omega
            have advance := atomAdvance nonempty
            obtain ⟨atom, parsed⟩ := value_sound text scan.position names nonempty
            have positiveOperands := (value_operands parsed).2.1
            simp only [ValidScan, ValidCursor, ValidValue] at scanValid atomValid ⊢
            split <;> exact ⟨by omega, Or.inr (Or.inr advance)⟩
      · split
        · rename_i joined
          have advance := joinAdvance joined
          simp only [ValidScan, ValidCursor] at scanValid joinBound ⊢
          exact ⟨by omega, Or.inr (Or.inr advance)⟩
        · split
          · rename_i closed
            have advance := closeAdvance closed.1
            simp only [ValidScan, ValidCursor] at scanValid closeBound ⊢
            exact ⟨by omega, Or.inr (Or.inr advance)⟩
          · split
            · exact ⟨scanValid, Or.inr (Or.inl rfl)⟩
            · exact ⟨model_invalid_scan_valid text, Or.inl rfl⟩

theorem model_result_valid (text : Source) (scan : ExpressionState)
    (valid : ValidScan text scan) : ValidResult text scan.result := by
  unfold ValidScan ValidCursor at valid
  simp only [ValidResult, ExpressionState.result]
  omega

theorem model_tail_valid (text : Source) (valid : ValidText text)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} (scan : ExpressionState)
    (namesValid : ValidNames text names) (scanValid : ValidScan text scan) :
    ValidResult text (expressionTail (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan) := by
  rw [expressionTail]
  split
  · simp [ValidResult, invalidExpression]
  · split
    · exact model_result_valid text scan scanValid
    · dsimp only
      split
      · simp [ValidResult, invalidExpression]
      · split
        · exact model_result_valid text _ (model_scan_valid (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text valid names scan namesValid scanValid).1
        · split
          · exact model_tail_valid (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text valid names _ namesValid
              (model_scan_valid (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text valid names scan namesValid scanValid).1
          · simp [ValidResult, invalidExpression]
termination_by text.length + 1 - scan.position

theorem model_expression_valid (text : Source) (valid : ValidText text) (position : Nat)
    (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} (bound : ValidCursor text position)
    (namesValid : ValidNames text names) : ValidResult text (expressionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) := by
  apply model_tail_valid (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text valid names _ namesValid
  exact ⟨bound, by simp, by simp, by simp, by simp,
    by change position = 0 ∨ 0 < position; omega, by simp⟩

theorem model_scan_completed_position (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (scan : ExpressionState) (finished : (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).complete = true) :
    (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).position = scan.position := by
  unfold expressionStep at finished ⊢
  dsimp only at finished ⊢
  repeat' split at finished
  all_goals simp_all [invalidExpressionState]

/-- Even outside the verified machine domain, successful recursion cannot move
backwards: completed steps retain the cursor and recursive calls strictly advance. -/
theorem model_tail_nondecreasing (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} (scan : ExpressionState) :
    (expressionTail (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).after = 0 ∨
      scan.position ≤ (expressionTail (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan).after := by
  rw [expressionTail]
  split
  · exact Or.inl rfl
  · split
    · exact Or.inr (Nat.le_refl _)
    · dsimp only
      split
      · exact Or.inl rfl
      · split
        · rename_i finished
          exact Or.inr (Nat.le_of_eq (model_scan_completed_position (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan finished).symm)
        · split
          · rename_i advancing
            rcases model_tail_nondecreasing (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan) with zero | forward
            · exact Or.inl zero
            · exact Or.inr (Nat.le_trans (by omega) forward)
          · exact Or.inl rfl
termination_by text.length + 1 - scan.position

theorem model_fixed_input_nonzero (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (nonzero : fixedAfter text position spelling word ≠ 0) : position ≠ 0 := by
  intro zero
  simp [fixedAfter, zero] at nonzero

theorem model_expression_input_nonzero (text : Source) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (nonzero : (expressionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) : position ≠ 0 := by
  intro zero
  subst position
  simp [expressionAt, expressionTail, invalidExpression] at nonzero


end Silver.Compose.Expressions
