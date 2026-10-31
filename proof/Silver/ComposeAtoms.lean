module

public import Silver.ComposeAtomReading

@[expose] public section

namespace Silver.Compose
open Named Bindings

inductive ValueAtCore (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    Nat → Operand → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      skipAt text position ≠ 0 → skipAt text position ≤ text.length →
      Cursor.byteAt text (skipAt text position) = 34 →
      Output.LiteralAt text (skipAt text position + 1) bytes after →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.literal bytes)
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0⟩
  | reference {position after index : Nat} {name : Source} {info : BindingInfo} :
      skipAt text position ≠ 0 →
      IdentifierAt text (skipAt text position) name after →
      lookupName text names (skipAt text position) after = index → index ≠ 0 →
      ScalarExpression.lookup text scalarNames (skipAt text position) after = 0 →
      names.get index = some info →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.reference index)
        ⟨after, info.valueFirst, info.staticLength, info.staticLength, info.dynamic, true, false, index⟩
  | image {position : Nat} {expression : Integer.Expr} :
      ¬ QuotedValueAt text position →
      ¬ (lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
        ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0) →
      ImageReading text names scalarNames integerHidden position expression arrays initials elaborating →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.image expression)
        (imageValue (imageParts text position scalarNames arrays initials elaborating))

abbrev ValueAt (text : Source) (names : BindingEnvironment) (position : Nat)
    (value : Operand) (result : ValueResult) (scalarNames : ScalarExpression.Environment := [])
    (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  ValueAtCore text names scalarNames integerHidden arrays initials elaborating position value result

theorem value_complete {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat} {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names = result := by
  cases parsed with
  | literal positive bound quote parsed =>
      rename_i after bytes
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
  | reference positive parsed selected nonzero unmasked present =>
      simp [valueAt, literalAt, identifier_not_quote parsed, nameAfter, positive,
        identifierEnd_complete parsed, selected, nonzero, unmasked, present, invalidValue]
  | image noLiteral noReference parsed =>
      have quoted : (literalAt text (skipAt text position)).after = 0 := by
        by_cases nonzero : (literalAt text (skipAt text position)).after ≠ 0
        · exact False.elim (noLiteral ((quotedValue_iff text position).mpr nonzero))
        · exact Nat.eq_zero_of_not_pos (by omega)
      simp only [valueAt, quoted, ne_eq, not_true_eq_false, ↓reduceIte, noReference]
      exact image_complete parsed

theorem value_sound (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (accepted : (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) :
    ∃ value, ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value
      (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) := by
  by_cases quoted : (literalAt text (skipAt text position)).after ≠ 0
  · obtain ⟨bytes, after, positive, bound, quote, parsed⟩ := (quotedValue_iff text position).mpr quoted
    have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
    refine ⟨.literal bytes, ?_⟩
    have observed : valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names =
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0⟩ := by
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
    rw [observed]
    exact .literal positive bound quote parsed
  · by_cases referenced : lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
        ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0
    · obtain ⟨positive, advanced, info, present, _⟩ := lookupName_found referenced.1
      have afterPositive : nameAfter text (skipAt text position) ≠ 0 := by omega
      have nameAccepted : identifierEnd text (skipAt text position) ≠ 0 := by
        simpa [nameAfter, positive] using afterPositive
      obtain ⟨name, parsed⟩ := identifierEnd_sound text _ nameAccepted
      have afterSame : nameAfter text (skipAt text position) = identifierEnd text (skipAt text position) := by
        simp [nameAfter, positive]
      refine ⟨.reference (lookupName text names (skipAt text position) (nameAfter text (skipAt text position))), ?_⟩
      have observed : valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names =
          ⟨nameAfter text (skipAt text position), info.valueFirst, info.staticLength, info.staticLength,
            info.dynamic, true, false, lookupName text names (skipAt text position) (nameAfter text (skipAt text position))⟩ := by
        simp [valueAt, quoted, referenced, present]
      rw [observed]
      apply ValueAtCore.reference positive
      · simpa [afterSame] using parsed
      · rfl
      · exact referenced.1
      · exact referenced.2
      · exact present
    · have imageAccepted : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0 := by
        simpa only [valueAt, quoted, ↓reduceIte, referenced] using accepted
      obtain ⟨expression, parsed⟩ := image_sound imageAccepted
      refine ⟨.image expression, ?_⟩
      have observed := image_complete parsed
      simp only [valueAt, quoted, ↓reduceIte, referenced, observed]
      exact .image (fun present => quoted ((quotedValue_iff text position).mp present)) referenced parsed

def ValueResult.bound (result : ValueResult) : Bindings.Bound :=
  if result.dynamicSeen then .argument else .fixed result.staticLength

theorem value_inferLength {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult} (normal : NamesNormal names)
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.inferLength names.shape (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some result.lengthSummary := by
  cases parsed with
  | literal => rfl
  | reference positive identifier selected nonzero unmasked present =>
      rename_i after index name info
      have zero := normal _ _ present
      cases dynamic : info.dynamic
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, BindingInfo.bound, dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary]
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, BindingInfo.bound, dynamic, zero dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary]
  | image _ _ parsed =>
      simp only [Operand.inferLength, parsed.scalar.inferred, Option.map_some,
        ValueResult.lengthSummary, imageValue, LengthSummary.ofImage]
      split <;> rfl

theorem value_literals {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.PrintableLiterals := by
  cases parsed with
  | literal _ _ _ parsed => exact (Output.literalAt_bounds parsed).2.2
  | reference | image => trivial


end Silver.Compose
