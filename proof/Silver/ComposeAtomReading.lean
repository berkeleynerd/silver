module

public import Silver.ComposeAtomAdmission

@[expose] public section

/-! Independent source judgments for String atoms and Character expressions. -/
namespace Silver.Compose

open Named Bindings

theorem lookupList_found (text : Source) (first after : Nat) (names : BindingEnvironment)
    (start : Nat) (found : lookupList text first after start names ≠ 0) :
    ∃ offset info, names[offset]? = some info ∧
      lookupList text first after start names = start + offset ∧
      equalName text info.first info.after first after = true := by
  induction names generalizing start with
  | nil => simp [lookupList] at found
  | cons info rest ih =>
      by_cases same : equalName text info.first info.after first after = true
      · exact ⟨0, info, by simp, by simp [lookupList, same], same⟩
      · have remaining : lookupList text first after (start + 1) rest ≠ 0 := by
          simpa [lookupList, same] using found
        obtain ⟨offset, next, present, value, equal⟩ := ih (start + 1) remaining
        refine ⟨offset + 1, next, by simpa using present, ?_, equal⟩
        simpa [lookupList, same, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using value

theorem lookupName_found {text : Source} {names : BindingEnvironment} {first after : Nat}
    (found : lookupName text names first after ≠ 0) :
    first ≠ 0 ∧ first < after ∧ ∃ info,
      names.get (lookupName text names first after) = some info ∧
      equalName text info.first info.after first after = true := by
  by_cases invalid : first = 0 ∨ after ≤ first
  · simp [lookupName, invalid] at found
  · have valid : first ≠ 0 ∧ first < after := by omega
    have same : lookupName text names first after = lookupList text first after 1 names := by
      simp [lookupName, invalid, lookupFrom]
    rw [same] at found
    obtain ⟨offset, info, present, value, equal⟩ := lookupList_found text first after names 1 found
    refine ⟨valid.1, valid.2, info, ?_, equal⟩
    simp [BindingEnvironment.get, same, value, present, Nat.add_comm]

theorem identifier_not_quote {text bytes : Source} {position after : Nat}
    (parsed : IdentifierAt text position bytes after) : Cursor.byteAt text position ≠ 34 := by
  cases parsed with
  | identifier _ first _ =>
      simp only [letter, decide_eq_true_eq] at first
      omega

/-- The literal alternative is specified by the independent literal grammar. -/
def QuotedValueAt (text : Source) (position : Nat) : Prop :=
  ∃ bytes after, skipAt text position ≠ 0 ∧ skipAt text position ≤ text.length ∧
    Cursor.byteAt text (skipAt text position) = 34 ∧
    Output.LiteralAt text (skipAt text position + 1) bytes after

theorem quotedValue_iff (text : Source) (position : Nat) :
    QuotedValueAt text position ↔ (literalAt text (skipAt text position)).after ≠ 0 := by
  constructor
  · rintro ⟨bytes, after, positive, bound, quote, parsed⟩
    have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
    simp [literalAt, positive, bound, quote, Output.literalAt_complete parsed,
      Guarded.literalLength_decodes parsed, nonzero]
  · intro accepted
    unfold literalAt at accepted
    split at accepted
    · rename_i conditions
      obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ conditions.2.2.2
      exact ⟨bytes, _, conditions.1, conditions.2.1, conditions.2.2.1, parsed⟩
    · simp [invalidValue] at accepted

theorem fixedAfter_result_bound (text : Source) (position : Nat) (word : String)
    (wordFlag : Bool) (nonempty : 0 < word.toList.length) :
    fixedAfter text position word wordFlag ≤ text.length + 1 := by
  unfold fixedAfter
  split
  · omega
  · split
    · rename_i accepted
      have fits : word.toList.length ≤ text.length + 1 - Cursor.triviaPosition text position := by
        simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, List.length_map] at accepted
        exact accepted.1.1
      omega
    · omega

structure ImageReading (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (position : Nat) (expression : Integer.Expr)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : Prop where
  visible : integerHidden = false
  typePresent : (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0
  stringClear : lookupName text names (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  scalarClear : ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  arrayClear : ArrayBindings.lookup text arrays (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  attributePositive : (imageParts text position scalarNames arrays initials elaborating).attributeFirst ≠ 0
  attributeOrdered : (imageParts text position scalarNames arrays initials elaborating).attributeFirst <
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter
  attributeName : Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true
  scalar : ScalarExpression.At text scalarNames (imageParts text position scalarNames arrays initials elaborating).scalarPosition
    expression (imageParts text position scalarNames arrays initials elaborating).scalar
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  following : position < (imageParts text position scalarNames arrays initials elaborating).following

theorem image_complete {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Integer.Expr} (parsed : ImageReading text names scalarNames integerHidden position expression arrays initials elaborating) :
    imageAt text position names scalarNames integerHidden arrays initials elaborating = imageValue (imageParts text position scalarNames arrays initials elaborating) := by
  have attr := parsed.attributeName
  change Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter [105, 109, 97, 103, 101] = true at attr
  simp [imageAt, parsed.visible, parsed.typePresent, parsed.stringClear, parsed.scalarClear, parsed.arrayClear,
    parsed.attributePositive, Nat.not_le.mpr parsed.attributeOrdered, attr,
    Nat.not_le.mpr parsed.following]

theorem image_sound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    (accepted : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0) :
    ∃ expression, ImageReading text names scalarNames integerHidden position expression arrays initials elaborating := by
  have good : integerHidden = false ∧ (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0 ∧
      lookupName text names (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ArrayBindings.lookup text arrays (imageParts text position scalarNames arrays initials elaborating).first
        (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      (imageParts text position scalarNames arrays initials elaborating).attributeFirst ≠ 0 ∧
      (imageParts text position scalarNames arrays initials elaborating).attributeFirst < (imageParts text position scalarNames arrays initials elaborating).attributeAfter ∧
      Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
        (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true ∧
      position < (imageParts text position scalarNames arrays initials elaborating).following := by
    dsimp only [imageAt] at accepted
    split at accepted
    · simp [invalidValue] at accepted
    · rename_i good
      simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', not_or, Bool.not_eq_true,
        Bool.not_eq_true', Nat.not_le] at good
      rcases good with ⟨⟨⟨hidden, typeGood⟩, attributeName⟩, following⟩
      rcases typeGood with ⟨typePresent, stringClear, scalarClear, arrayClear, attributePositive, attributeOrdered⟩
      have attributeTrue : Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true := by
        rcases Bool.eq_false_or_eq_true (Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat)) with found | absent
        · exact found
        · exact False.elim (attributeName absent)
      exact ⟨hidden, typePresent, by omega, by omega, by omega,
        attributePositive, attributeOrdered, attributeTrue, following⟩
  have scalarPositive : (imageParts text position scalarNames arrays initials elaborating).scalar.after ≠ 0 := by
    intro zero
    have following := good.2.2.2.2.2.2.2.2
    change position < fixedAfter text (imageParts text position scalarNames arrays initials elaborating).scalar.after ")" false at following
    simp [zero, fixedAfter] at following
  have bound : (imageParts text position scalarNames arrays initials elaborating).scalarPosition ≤ text.length + 1 :=
    fixedAfter_result_bound text _ "(" false (by decide)
  obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound bound scalarPositive
  exact ⟨expression, good.1, good.2.1, good.2.2.1, good.2.2.2.1, good.2.2.2.2.1,
    good.2.2.2.2.2.1, good.2.2.2.2.2.2.1, good.2.2.2.2.2.2.2.1, parsed, good.2.2.2.2.2.2.2.2⟩

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

def NamesNormal (names : BindingEnvironment) : Prop :=
  ∀ index info, names.get index = some info → info.dynamic = true → info.staticLength = 0

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
