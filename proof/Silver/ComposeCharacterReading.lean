module

public import Silver.ComposeIndexedReading

@[expose] public section

namespace Silver.Compose
open Named Bindings

structure CharacterLiteralAt (text : Source) (position byte after : Nat) : Prop where
  positive : position ≠ 0
  bounded : position + 2 ≤ text.length
  opening : Cursor.byteAt text position = 39
  value : Cursor.byteAt text (position + 1) = byte
  printable : Output.printable byte = true
  closing : Cursor.byteAt text (position + 2) = 39
  following : after = position + 3

theorem characterLiteral_complete {text : Source} {position byte after : Nat}
    (parsed : CharacterLiteralAt text position byte after) :
    characterLiteralAfter text position = after := by
  have printable := parsed.printable
  simp only [Output.printable, decide_eq_true_eq] at printable
  simp [characterLiteralAfter, parsed.positive, parsed.bounded, parsed.opening,
    parsed.value, printable.1, printable.2, parsed.closing, parsed.following]

theorem characterLiteral_sound {text : Source} {position : Nat}
    (accepted : characterLiteralAfter text position ≠ 0) :
    CharacterLiteralAt text position (Cursor.byteAt text (position + 1))
      (characterLiteralAfter text position) := by
  unfold characterLiteralAfter at accepted ⊢
  split at accepted
  · rename_i allowed
    rw [ite_eq_left allowed]
    exact ⟨allowed.1, allowed.2.1, allowed.2.2.1, rfl,
      by simp [Output.printable, allowed.2.2.2.1, allowed.2.2.2.2.1], allowed.2.2.2.2.2, rfl⟩
  · contradiction

def characterValue (after : Nat) (named : Bool) (target : Nat := 0) : ValueResult :=
  ⟨after, 0, 1, 1, false, named, false, target, 1, .singleton 1, .singleton 1⟩

def characterReference (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) : Prop :=
  lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
  ((names.get (lookupName text names (skipAt text position) (nameAfter text (skipAt text position)))).getD {}).isCharacter = true ∧
  ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0

inductive CharacterAt (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    Nat → Character.Expr → ValueResult → Prop
  | literal {position byte after : Nat} :
      fixedAfter text (skipAt text position) "(" false = 0 →
      CharacterLiteralAt text (skipAt text position) byte after →
      CharacterAt text names scalarNames arrays initials elaborating position (.literal byte)
        (characterValue after false)
  | reference {position index : Nat} {info : BindingInfo} :
      fixedAfter text (skipAt text position) "(" false = 0 →
      characterLiteralAfter text (skipAt text position) = 0 →
      lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) = index →
      index ≠ 0 → names.get index = some info → info.isCharacter = true →
      ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0 →
      CharacterAt text names scalarNames arrays initials elaborating position (.reference index)
        (characterValue (nameAfter text (skipAt text position)) true index)
  | indexed {position : Nat} {info : BindingInfo} {lower upper : Integer.Expr} :
      fixedAfter text (skipAt text position) "(" false = 0 →
      characterLiteralAfter text (skipAt text position) = 0 →
      ¬ characterReference text position names scalarNames →
      IndexedReading text names scalarNames arrays initials elaborating true position info lower upper →
      CharacterAt text names scalarNames arrays initials elaborating position
        (.indexed (indexedParts text position names scalarNames arrays initials elaborating true).target info.firstIndex lower)
        (indexedValue (indexedParts text position names scalarNames arrays initials elaborating true) true)
  | parenthesized {position : Nat} {inner : Character.Expr} {result : ValueResult} :
      fixedAfter text (skipAt text position) "(" false ≠ 0 →
      text.length + 1 - fixedAfter text (skipAt text position) "(" false < text.length + 1 - position →
      CharacterAt text names scalarNames arrays initials elaborating
        (fixedAfter text (skipAt text position) "(" false) inner result →
      fixedAfter text result.after ")" false ≠ 0 →
      CharacterAt text names scalarNames arrays initials elaborating position (.parenthesized inner)
        {result with after := fixedAfter text result.after ")" false}

theorem character_complete {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    characterAt text position names scalarNames arrays initials elaborating = result := by
  induction parsed with
  | literal noParen source =>
      rename_i pos byte after
      have nonzero : after ≠ 0 := by rw [source.following]; omega
      rw [characterAt]
      simp [noParen, characterLiteral_complete source, nonzero, characterValue]
  | reference noParen noLiteral selected nonzero present typed unmasked =>
      rw [characterAt]
      simp [noParen, noLiteral, selected, nonzero, present, typed, unmasked, characterValue]
  | indexed noParen noLiteral noReference source =>
      rw [characterAt]
      unfold characterReference at noReference
      simp [noParen, noLiteral, noReference, indexed_complete source]
  | parenthesized openPresent advancing source closePresent ih =>
      rw [characterAt]
      simp [openPresent, advancing, ih]

theorem character_sound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} (position : Nat)
    (accepted : (characterAt text position names scalarNames arrays initials elaborating).after ≠ 0) :
    ∃ expression, CharacterAt text names scalarNames arrays initials elaborating position expression
      (characterAt text position names scalarNames arrays initials elaborating) := by
  rw [characterAt] at accepted ⊢
  dsimp only at accepted ⊢
  by_cases openPresent : fixedAfter text (skipAt text position) "(" false ≠ 0
  · rw [ite_eq_left openPresent] at accepted ⊢
    by_cases advancing : text.length + 1 - fixedAfter text (skipAt text position) "(" false < text.length + 1 - position
    · rw [dite_eq_left advancing] at accepted ⊢
      have innerAccepted : (characterAt text (fixedAfter text (skipAt text position) "(" false)
          names scalarNames arrays initials elaborating).after ≠ 0 := by
        intro zero
        change fixedAfter text (characterAt text (fixedAfter text (skipAt text position) "(" false)
          names scalarNames arrays initials elaborating).after ")" false ≠ 0 at accepted
        rw [zero] at accepted
        simp [fixedAfter] at accepted
      obtain ⟨inner, source⟩ := character_sound _ innerAccepted
      exact ⟨.parenthesized inner, .parenthesized openPresent advancing source accepted⟩
    · rw [dite_eq_right advancing] at accepted
      simp [invalidValue] at accepted
  · rw [ite_eq_right openPresent] at accepted ⊢
    by_cases quoted : characterLiteralAfter text (skipAt text position) ≠ 0
    · rw [ite_eq_left quoted]
      exact ⟨.literal (Cursor.byteAt text (skipAt text position + 1)),
        .literal (by omega) (characterLiteral_sound quoted)⟩
    · rw [ite_eq_right quoted] at accepted ⊢
      by_cases named : characterReference text position names scalarNames
      · change _ ∧ _ ∧ _ at named
        rw [ite_eq_left named]
        obtain ⟨_, _, info, present, _⟩ := lookupName_found named.1
        have typed : info.isCharacter = true := by simpa [present] using named.2.1
        exact ⟨.reference _, .reference (by omega) (by omega) rfl named.1 present typed named.2.2⟩
      · unfold characterReference at named
        rw [ite_eq_right named] at accepted ⊢
        obtain ⟨info, lower, upper, source⟩ := indexed_sound accepted
        rw [indexed_complete source]
        exact ⟨_, .indexed (by omega) (by omega) named source⟩
termination_by text.length + 1 - position

theorem character_check {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult} (normal : NamesNormal names)
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    expression.check names.shape.fixedLengths
      (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) = true := by
  induction parsed with
  | literal _ source => exact source.printable
  | reference noParen noLiteral selected nonzero present typed unmasked =>
      have metadata := (normal.typed _ _ present).1 typed
      simp [Character.Expr.check, fixedLengths_of_info present metadata.1, metadata.2]
  | indexed _ _ _ source => exact indexed_check normal source
  | parenthesized _ _ _ _ ih => exact ih

theorem character_readable {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult} (normal : NamesNormal names)
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    expression.Readable names.shape.fixedLengths := Character.Expr.check_readable (character_check normal parsed)

theorem character_literals {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    expression.PrintableLiterals := by
  induction parsed with
  | literal _ source => exact source.printable
  | reference | indexed => trivial
  | parenthesized _ _ _ _ ih => exact ih

def _root_.Silver.Character.Expr.sourceOperands : Character.Expr → Nat
  | .literal _ | .reference _ => 1
  | .indexed _ _ scalar => ScalarExpression.leaves scalar + 1
  | .parenthesized inner => inner.sourceOperands

theorem character_operands {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.operands = expression.sourceOperands ∧ 0 < result.operands ∧ result.operands ≤ maxExpressionOperands := by
  induction parsed with
  | literal | reference => exact ⟨rfl, Nat.zero_lt_succ _, by change 1 ≤ 64; omega⟩
  | indexed _ _ _ source =>
      have count := source.lowerSource.operands
      have bounded := source.lowerSource.operandBound
      have nonmax := (source.elementBounds rfl).1
      simp only [indexedValue, ↓reduceIte, Character.Expr.sourceOperands]
      refine ⟨by omega, by omega, ?_⟩
      change ScalarExpression.leaves _ ≤ maxExpressionOperands at bounded
      omega
  | parenthesized _ _ _ _ ih => exact ih

theorem character_lengthSummary {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.lengthSummary = ⟨1, 1, 0, false⟩ := by
  induction parsed with
  | literal | reference | indexed => rfl
  | parenthesized _ _ _ _ ih => exact ih

theorem character_metadata {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.dynamicSeen = false ∧ result.minimumLength = 1 ∧ result.staticLength = 1 ∧
      result.emptyValue = false ∧ result.firstIndex = .singleton 1 ∧ result.lastIndex = .singleton 1 := by
  induction parsed with
  | literal | reference | indexed => exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩
  | parenthesized _ _ _ _ ih => exact ih

theorem character_unique {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {left right : Character.Expr} {leftResult rightResult : ValueResult}
    (leftAt : CharacterAt text names scalarNames arrays initials elaborating position left leftResult)
    (rightAt : CharacterAt text names scalarNames arrays initials elaborating position right rightResult) :
    left = right ∧ leftResult = rightResult := by
  refine ⟨?_, (character_complete leftAt).symm.trans (character_complete rightAt)⟩
  induction leftAt generalizing right rightResult with
  | literal noParen source =>
      rename_i pos byte after
      have nonzero : characterLiteralAfter text (skipAt text pos) ≠ 0 := by
        rw [characterLiteral_complete source, source.following]
        omega
      cases rightAt with
      | literal _ other => rw [← source.value, ← other.value]
      | reference _ noLiteral | indexed _ noLiteral => exact False.elim (nonzero noLiteral)
      | parenthesized openPresent => exact False.elim (openPresent noParen)
  | reference noParen noLiteral selected nonzero present typed unmasked =>
      rename_i pos index info
      have named : characterReference text pos names scalarNames := by
        unfold characterReference
        simp [selected, nonzero, present, typed, unmasked]
      cases rightAt with
      | literal _ source =>
          have same := (characterLiteral_complete source).symm.trans noLiteral
          rw [source.following] at same
          omega
      | reference _ _ otherSelected =>
          have same := selected.symm.trans otherSelected
          cases same
          rfl
      | indexed _ _ noReference => exact False.elim (noReference named)
      | parenthesized openPresent => exact False.elim (openPresent noParen)
  | indexed noParen noLiteral noReference source =>
      cases rightAt with
      | literal _ other =>
          have same := (characterLiteral_complete other).symm.trans noLiteral
          rw [other.following] at same
          omega
      | reference _ _ selected nonzero present typed unmasked =>
          apply False.elim
          apply noReference
          unfold characterReference
          simp [selected, nonzero, present, typed, unmasked]
      | indexed _ _ _ other =>
          obtain ⟨sameInfo, sameLower, _⟩ := indexed_unique source other
          cases sameInfo
          cases sameLower
          rfl
      | parenthesized openPresent => exact False.elim (openPresent noParen)
  | parenthesized openPresent advancing source closePresent ih =>
      cases rightAt with
      | literal noParen | reference noParen | indexed noParen => exact False.elim (openPresent noParen)
      | parenthesized _ _ other => exact congrArg Character.Expr.parenthesized (ih other)

end Silver.Compose
