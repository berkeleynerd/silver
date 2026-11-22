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
    (arrays : ArrayBindings.Table := {}) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : Prop where
  visible : integerHidden = false
  typePresent : (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0
  stringClear : lookupName text names (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  scalarClear : ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  arrayClear : ArrayBindings.lookup text arrays.items (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  arrayTypeClear : ArrayBindings.lookupType text arrays.types
    (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  attributePositive : (imageParts text position scalarNames arrays initials elaborating).attributeFirst ≠ 0
  attributeOrdered : (imageParts text position scalarNames arrays initials elaborating).attributeFirst <
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter
  attributeName : Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true
  scalar : ScalarExpression.ArrayGrammar.At text scalarNames (imageParts text position scalarNames arrays initials elaborating).scalarPosition
    expression (imageParts text position scalarNames arrays initials elaborating).scalar
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  following : position < (imageParts text position scalarNames arrays initials elaborating).following

theorem image_complete {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Integer.Expr} (parsed : ImageReading text names scalarNames integerHidden position expression arrays initials elaborating) :
    imageAt text position names scalarNames integerHidden arrays initials elaborating = imageValue (imageParts text position scalarNames arrays initials elaborating) := by
  have attr := parsed.attributeName
  change Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter [105, 109, 97, 103, 101] = true at attr
  simp [imageAt, parsed.visible, parsed.typePresent, parsed.stringClear, parsed.scalarClear, parsed.arrayClear, parsed.arrayTypeClear,
    parsed.attributePositive, Nat.not_le.mpr parsed.attributeOrdered, attr,
    Nat.not_le.mpr parsed.following]

theorem image_sound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    (accepted : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0) :
    ∃ expression, ImageReading text names scalarNames integerHidden position expression arrays initials elaborating := by
  have good : integerHidden = false ∧ (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0 ∧
      lookupName text names (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ArrayBindings.lookup text arrays.items (imageParts text position scalarNames arrays initials elaborating).first
        (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ArrayBindings.lookupType text arrays.types (imageParts text position scalarNames arrays initials elaborating).first
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
      rcases typeGood with ⟨typePresent, stringClear, scalarClear, arrayClear, arrayTypeClear, attributePositive, attributeOrdered⟩
      have attributeTrue : Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true := by
        rcases Bool.eq_false_or_eq_true (Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat)) with found | absent
        · exact found
        · exact False.elim (attributeName absent)
      exact ⟨hidden, typePresent, by omega, by omega, by omega, by omega,
        attributePositive, attributeOrdered, attributeTrue, following⟩
  have scalarPositive : (imageParts text position scalarNames arrays initials elaborating).scalar.after ≠ 0 := by
    intro zero
    have following := good.2.2.2.2.2.2.2.2.2
    change position < fixedAfter text (imageParts text position scalarNames arrays initials elaborating).scalar.after ")" false at following
    simp [zero, fixedAfter] at following
  have bound : (imageParts text position scalarNames arrays initials elaborating).scalarPosition ≤ text.length + 1 :=
    fixedAfter_result_bound text _ "(" false (by decide)
  obtain ⟨expression, parsed⟩ := ScalarExpression.ArrayGrammar.read_sound bound scalarPositive
  exact ⟨expression, good.1, good.2.1, good.2.2.1, good.2.2.2.1, good.2.2.2.2.1,
    good.2.2.2.2.2.1, good.2.2.2.2.2.2.1, good.2.2.2.2.2.2.2.1, good.2.2.2.2.2.2.2.2.1, parsed, good.2.2.2.2.2.2.2.2.2⟩

/-- Typed source metadata links actual Ada bounds to the byte-store shape. -/
def BindingInfo.WellTyped (info : BindingInfo) : Prop :=
  (info.isCharacter = true → info.dynamic = false ∧ info.staticLength = 1) ∧
  (info.dynamic = false → info.staticLength = (info.lastIndex - info.firstIndex + 1).toNat)

def NamesWellTyped (names : BindingEnvironment) : Prop :=
  ∀ index info, names.get index = some info → BindingInfo.WellTyped info

structure NamesNormal (names : BindingEnvironment) : Prop where
  dynamicLength : ∀ index info, names.get index = some info →
    info.dynamic = true → info.staticLength = 0
  typed : NamesWellTyped names

instance {names : BindingEnvironment} : CoeFun (NamesNormal names)
    (fun _ => ∀ index info, names.get index = some info → info.dynamic = true → info.staticLength = 0) :=
  ⟨NamesNormal.dynamicLength⟩

theorem fixedLengths_of_info {names : BindingEnvironment} {index : Nat} {info : BindingInfo}
    (present : names.get index = some info) (fixed : info.dynamic = false) :
    names.shape.fixedLengths index = some info.staticLength := by
  simp [Shape.fixedLengths, BindingEnvironment.shape, present, BindingInfo.cell,
    Bindings.BindingInfo.bound, fixed]

end Silver.Compose
