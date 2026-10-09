import Silver.OutputLiteral
import Silver.Cursor

namespace Silver.Output

inductive Token
  | withKeyword | ioName | procedureKeyword | mainName | isKeyword | pragmaKeyword
  | sparkModeName | onName | beginKeyword | putLineName | endKeyword
  | leftParenthesis | rightParenthesis | semicolon | dot | stringLiteral
  deriving DecidableEq, Repr

def Token.spellingText : Token → String
  | .withKeyword => "with" | .ioName => "silver_io" | .procedureKeyword => "procedure"
  | .mainName => "main" | .isKeyword => "is" | .pragmaKeyword => "pragma"
  | .sparkModeName => "spark_mode" | .onName => "on" | .beginKeyword => "begin"
  | .putLineName => "put_line" | .endKeyword => "end" | .leftParenthesis => "("
  | .rightParenthesis => ")" | .semicolon => ";" | .dot => "." | .stringLiteral => "\""

def Token.spelling (token : Token) : Source := token.spellingText.toList.map Char.toNat

def Token.isWord : Token → Bool
  | .leftParenthesis | .rightParenthesis | .semicolon | .dot | .stringLiteral => false
  | _ => true

def requiredTokens : List Token :=
  [.withKeyword, .ioName, .semicolon, .procedureKeyword, .mainName, .isKeyword,
   .pragmaKeyword, .sparkModeName, .leftParenthesis, .onName, .rightParenthesis,
   .semicolon, .beginKeyword, .ioName, .dot, .putLineName, .leftParenthesis,
   .stringLiteral, .rightParenthesis, .semicolon, .endKeyword, .mainName, .semicolon]

def tokenAt (text : Source) (position : Nat) (token : Token) : Bool :=
  decide (token.spelling.length ≤ text.length + 1 - position) &&
    decide (∀ i : Fin token.spelling.length,
      lowercase (Cursor.byteAt text (position + i.val)) = token.spelling[i.val]) &&
    (!token.isWord || decide (position + token.spelling.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + token.spelling.length)))

/-- The numeric recognizer has the exact cursor meaning of Literal_End. -/
def literalEnd (text : Source) (position : Nat) : Nat :=
  if position > text.length then 0
  else if Cursor.byteAt text position = 34 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 34 then
      literalEnd text (position + 2)
    else position + 1
  else if printable (Cursor.byteAt text position) then literalEnd text (position + 1)
  else 0
termination_by text.length + 1 - position
decreasing_by all_goals omega

/-- An independent derivation identifies each decoded character and its source
span. The closing delimiter cannot begin a doubled-quote pair. -/
inductive LiteralAt (text : Source) : Nat → Source → Nat → Prop
  | close {position : Nat} : position ≤ text.length →
      Cursor.byteAt text position = 34 →
      ¬(position < text.length ∧ Cursor.byteAt text (position + 1) = 34) →
      LiteralAt text position [] (position + 1)
  | quote {position finish : Nat} {value : Source} : position < text.length →
      Cursor.byteAt text position = 34 → Cursor.byteAt text (position + 1) = 34 →
      LiteralAt text (position + 2) value finish →
      LiteralAt text position (34 :: value) finish
  | character {position finish : Nat} {value : Source} : position ≤ text.length →
      Cursor.byteAt text position ≠ 34 → printable (Cursor.byteAt text position) = true →
      LiteralAt text (position + 1) value finish →
      LiteralAt text position (Cursor.byteAt text position :: value) finish

theorem literalAt_complete {text value : Source} {position finish : Nat}
    (h : LiteralAt text position value finish) : literalEnd text position = finish := by
  induction h with
  | close bound quote ending => rw [literalEnd]; simp [bound, quote, ending]
  | quote bound quote next previous ih => rw [literalEnd]; simp [Nat.not_lt.mpr (Nat.le_of_lt bound), quote, bound, next, ih]
  | character bound different character previous ih => rw [literalEnd]; simp [Nat.not_lt.mpr bound, different, character, ih]

theorem literalAt_sound (text : Source) (position : Nat)
    (nonzero : literalEnd text position ≠ 0) :
    ∃ value, LiteralAt text position value (literalEnd text position) := by
  by_cases bound : position > text.length
  · rw [literalEnd] at nonzero
    simp [bound] at nonzero
  · by_cases quote : Cursor.byteAt text position = 34
    · by_cases next : position < text.length ∧ Cursor.byteAt text (position + 1) = 34
      · have equation : literalEnd text position = literalEnd text (position + 2) := by
          rw [literalEnd]; simp [bound, quote, next]
        rw [equation] at nonzero ⊢
        obtain ⟨value, previous⟩ := literalAt_sound text (position + 2) nonzero
        exact ⟨34 :: value, .quote next.1 quote next.2 previous⟩
      · rw [literalEnd]
        simp only [bound, quote, next, ↓reduceIte]
        exact ⟨[], .close (by omega) quote next⟩
    · by_cases character : printable (Cursor.byteAt text position) = true
      · have equation : literalEnd text position = literalEnd text (position + 1) := by
          rw [literalEnd]; simp [bound, quote, character]
        rw [equation] at nonzero ⊢
        obtain ⟨value, previous⟩ := literalAt_sound text (position + 1) nonzero
        exact ⟨_, .character (by omega) quote character previous⟩
      · rw [literalEnd] at nonzero
        simp [bound, quote, character] at nonzero

termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem literalAt_unique {text left right : Source} {position leftEnd rightEnd : Nat}
    (first : LiteralAt text position left leftEnd)
    (second : LiteralAt text position right rightEnd) : left = right ∧ leftEnd = rightEnd := by
  induction first generalizing right rightEnd with
  | close bound quote ending =>
      cases second <;> simp_all
  | quote bound quote next previous ih =>
      cases second with
      | close bound quote ending => exact False.elim (ending ⟨by assumption, by assumption⟩)
      | quote bound quote next other =>
          obtain ⟨rfl, rfl⟩ := ih other
          exact ⟨rfl, rfl⟩
      | character bound different character other => contradiction
  | character bound different character previous ih =>
      cases second with
      | close bound quote ending => contradiction
      | quote bound quote next other => contradiction
      | character bound different character other =>
          obtain ⟨rfl, rfl⟩ := ih other
          exact ⟨rfl, rfl⟩

theorem literalAt_bounds {text value : Source} {position finish : Nat}
    (h : LiteralAt text position value finish) :
    position + value.length < finish ∧ finish ≤ text.length + 1 ∧
      ∀ byte ∈ value, printable byte = true := by
  induction h with
  | close bound quote ending => simp; omega
  | quote bound quote next previous ih =>
    refine ⟨by simp only [List.length_cons]; omega, ih.2.1, ?_⟩
    simpa [printable] using ih.2.2
  | character bound different character previous ih =>
    refine ⟨by simp only [List.length_cons]; omega, ih.2.1, ?_⟩
    intro byte member
    simp only [List.mem_cons] at member
    rcases member with rfl | member
    · exact character
    · exact ih.2.2 _ member

theorem literalEnd_bounds (text : Source) (position : Nat)
    (nonzero : literalEnd text position ≠ 0) :
    position < literalEnd text position ∧ literalEnd text position ≤ text.length + 1 := by
  obtain ⟨value, h⟩ := literalAt_sound text position nonzero
  have bounds := literalAt_bounds h
  exact ⟨by omega, bounds.2.1⟩

def suffixMatches (text : Source) : List Token → Nat → Bool
  | [], position => decide (Cursor.triviaPosition text position = text.length + 1)
  | token :: tokens, position =>
    let start := Cursor.triviaPosition text position
    if token = .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (literalEnd text (start + 1) ≠ 0) &&
        suffixMatches text tokens (literalEnd text (start + 1))
    else tokenAt text start token && suffixMatches text tokens (start + token.spelling.length)

inductive Parsed (text : Source) : List Token → Nat → List Source → Prop
  | done {position : Nat} : Cursor.triviaPosition text position = text.length + 1 →
      Parsed text [] position []
  | token {position : Nat} {token : Token} {tokens : List Token} {values : List Source} :
      token ≠ .stringLiteral → tokenAt text (Cursor.triviaPosition text position) token = true →
      Parsed text tokens (Cursor.triviaPosition text position + token.spelling.length) values →
      Parsed text (token :: tokens) position values
  | literal {position finish : Nat} {tokens : List Token} {value : Source} {values : List Source} :
      Cursor.triviaPosition text position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      LiteralAt text (Cursor.triviaPosition text position + 1) value finish →
      Parsed text tokens finish values →
      Parsed text (.stringLiteral :: tokens) position (value :: values)

theorem parsed_unique {text : Source} {tokens : List Token} {position : Nat}
    {left right : List Source} (first : Parsed text tokens position left)
    (second : Parsed text tokens position right) : left = right := by
  induction first generalizing right with
  | done ending => cases second; rfl
  | token different matched previous ih =>
      cases second with
      | token _ _ other => exact ih other
      | literal => contradiction
  | literal bound opening value previous ih =>
      cases second with
      | token different => contradiction
      | literal bound opening otherLiteral other =>
          obtain ⟨rfl, rfl⟩ := literalAt_unique value otherLiteral
          exact congrArg (List.cons _) (ih other)

theorem parsed_complete {text : Source} {tokens : List Token} {position : Nat}
    {values : List Source} (h : Parsed text tokens position values) :
    suffixMatches text tokens position = true := by
  induction h with
  | done endTrivia => simp [suffixMatches, endTrivia]
  | token different matched previous ih => simp [suffixMatches, different, matched, ih]
  | literal bound opening value previous ih =>
    have finish := literalAt_bounds value
    have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) finish.1)
    simp [suffixMatches, bound, opening, literalAt_complete value, ih, nonzero]

theorem parsed_sound (text : Source) (tokens : List Token) (position : Nat)
    (h : suffixMatches text tokens position = true) : ∃ values, Parsed text tokens position values := by
  induction tokens generalizing position with
  | nil => exact ⟨[], .done (by simpa [suffixMatches] using h)⟩
  | cons token tokens ih =>
    by_cases literal : token = .stringLiteral
    · subst token
      simp only [suffixMatches, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq,
        beq_iff_eq] at h
      obtain ⟨⟨⟨bound, opening⟩, nonzero⟩, remaining⟩ := h
      obtain ⟨value, valueParsed⟩ := literalAt_sound text _ nonzero
      obtain ⟨values, restParsed⟩ := ih _ remaining
      exact ⟨value :: values, .literal bound opening valueParsed restParsed⟩
    · simp only [suffixMatches, literal, ↓reduceIte, Bool.and_eq_true] at h
      obtain ⟨values, restParsed⟩ := ih _ h.2
      exact ⟨values, .token literal h.1 restParsed⟩

theorem parsed_iff (text : Source) (tokens : List Token) (position : Nat) :
    suffixMatches text tokens position = true ↔ ∃ values, Parsed text tokens position values :=
  ⟨parsed_sound text tokens position, fun ⟨_, h⟩ => parsed_complete h⟩

def literalCount (tokens : List Token) : Nat :=
  (tokens.filter (· == .stringLiteral)).length

theorem parsed_literals {text : Source} {tokens : List Token} {position : Nat}
    {values : List Source} (h : Parsed text tokens position values) :
    values.length = literalCount tokens ∧
    ∀ value ∈ values, value.length ≤ text.length ∧ ∀ byte ∈ value, printable byte = true := by
  induction h with
  | done => simp [literalCount]
  | token different matched previous ih => simpa [literalCount, different] using ih
  | literal bound opening value previous ih =>
    have bounds := literalAt_bounds value
    refine ⟨by simpa [literalCount] using congrArg Nat.succ ih.1, ?_⟩
    intro literal member
    simp only [List.mem_cons] at member
    rcases member with rfl | member
    · exact ⟨by omega, bounds.2.2⟩
    · exact ih.2 _ member

def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ value, Parsed source requiredTokens 1 [value]

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches source requiredTokens 1

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  have grammar : suffixMatches source requiredTokens 1 = true ↔
      ∃ value, Parsed source requiredTokens 1 [value] := by
    rw [parsed_iff]
    constructor
    · rintro ⟨values, parsed⟩
      have length := (parsed_literals parsed).1
      have one : values.length = 1 := by simpa [literalCount, requiredTokens] using length
      cases values with
      | nil => simp at one
      | cons value rest =>
        have empty : rest = [] := by simpa using one
        subst rest
        exact ⟨value, parsed⟩
    · rintro ⟨value, parsed⟩; exact ⟨[value], parsed⟩
  simp [accepts, Member, grammar, and_assoc]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

theorem member_literal {source : Source} (h : Member source) :
    ∃ value, Parsed source requiredTokens 1 [value] ∧ value.length ≤ 4096 ∧
      ∀ byte ∈ value, printable byte = true := by
  obtain ⟨value, parsed⟩ := h.2.2.2
  have bounds := (parsed_literals parsed).2 value (by simp)
  exact ⟨value, parsed, Nat.le_trans bounds.1 h.2.1, bounds.2⟩

end Silver.Output
