module

public import Silver.NamedSemantics
public import Silver.GuardedDecimal

@[expose] public section

namespace Silver.Assignment

open Named
abbrev Token := Named.Token
abbrev Event := Named.Event

def requiredTokens : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .stringName, .assignment,
   .base .stringLiteral, .base .semicolon, .base .beginKeyword,
   .referenceName, .assignment, .base .stringLiteral, .base .semicolon,
   .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis,
   .referenceName, .base .rightParenthesis, .base .semicolon,
   .base .endKeyword, .base .mainName, .base .semicolon]

def suffixMatches (text : Source) : List Token → Nat → Nat → NameState → Nat → Bool
  | [], _, position, _, _ => decide (Cursor.triviaPosition text position = text.length + 1)
  | token :: tokens, index, position, state, initialLength =>
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        suffixMatches text tokens (index + 1) (identifierEnd text start) ⟨start, identifierEnd text start⟩ initialLength
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        suffixMatches text tokens (index + 1) (identifierEnd text start) state initialLength
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        (if index > 17 then decide (Guarded.literalLength text (start + 1) = initialLength) else true) &&
        suffixMatches text tokens (index + 1) (Output.literalEnd text (start + 1)) state
          (if index = 17 then Guarded.literalLength text (start + 1) else initialLength)
    else Named.tokenAt text start token && suffixMatches text tokens (index + 1) (start + token.spelling.length) state initialLength

/-- Independent grammar: name/literal derivations record their values. The
separately proved name predicates enforce declaration policy and binding. -/
inductive Parsed (text : Source) : List Token → Nat → Nat → NameState → Nat → List Event → Prop
  | done {index position initialLength : Nat} {state : NameState} :
      Cursor.triviaPosition text position = text.length + 1 → Parsed text [] index position state initialLength []
  | fixed {index position initialLength : Nat} {state : NameState} {token : Token} {tokens : List Token} {events : List Event} :
      token ≠ .declarationName → token ≠ .referenceName → token ≠ .base .stringLiteral →
      Named.tokenAt text (Cursor.triviaPosition text position) token = true →
      Parsed text tokens (index + 1) (Cursor.triviaPosition text position + token.spelling.length) state initialLength events →
      Parsed text (token :: tokens) index position state initialLength events
  | declaration {index position finish initialLength : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      IdentifierAt text (Cursor.triviaPosition text position) name finish →
      forbiddenName text (Cursor.triviaPosition text position) finish = false →
      Parsed text tokens (index + 1) finish ⟨Cursor.triviaPosition text position, finish⟩ initialLength events →
      Parsed text (.declarationName :: tokens) index position state initialLength (.declaration (name.map lowercase) :: events)
  | reference {index position finish initialLength : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      0 < state.first → IdentifierAt text (Cursor.triviaPosition text position) name finish →
      equalName text state.first state.after (Cursor.triviaPosition text position) finish = true →
      Parsed text tokens (index + 1) finish state initialLength events →
      Parsed text (.referenceName :: tokens) index position state initialLength (.reference (name.map lowercase) :: events)
  | literal {index position finish initialLength : Nat} {state : NameState} {value : Source}
      {tokens : List Token} {events : List Event} :
      Cursor.triviaPosition text position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text position + 1) value finish →
      (index > 17 → value.length = initialLength) →
      Parsed text tokens (index + 1) finish state (if index = 17 then value.length else initialLength) events →
      Parsed text (.base .stringLiteral :: tokens) index position state initialLength (.literal value :: events)

theorem parsed_complete {text : Source} {tokens : List Token} {index position initialLength : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state initialLength events) :
    suffixMatches text tokens index position state initialLength = true := by
  induction parsed with
  | done ending => simp [suffixMatches, ending]
  | fixed declaration reference literal matched previous ih =>
      simp [suffixMatches, declaration, reference, literal, matched, ih]
  | declaration name allowed previous ih =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [suffixMatches, identifierEnd_complete name, nonzero, allowed, ih]
  | reference present name same previous ih =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [suffixMatches, identifierEnd_complete name, nonzero, present, same, ih]
  | literal bound opening value equal previous ih =>
      have finish := Output.literalAt_bounds value
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) finish.1)
      simp [suffixMatches, bound, opening, Output.literalAt_complete value, nonzero, Guarded.literalLength_decodes value, ih]
      omega

theorem parsed_sound (text : Source) (tokens : List Token) (index position : Nat) (state : NameState) (initialLength : Nat)
    (accepted : suffixMatches text tokens index position state initialLength = true) :
    ∃ events, Parsed text tokens index position state initialLength events := by
  induction tokens generalizing index position state initialLength with
  | nil => exact ⟨[], .done (by simpa [suffixMatches] using accepted)⟩
  | cons token tokens ih =>
    by_cases declaration : token = .declarationName
    · subst token
      simp only [suffixMatches, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq,
        Bool.not_eq_true'] at accepted
      obtain ⟨⟨nonzero, allowed⟩, remaining⟩ := accepted
      obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
      obtain ⟨events, rest⟩ := ih _ _ _ _ remaining
      exact ⟨_, .declaration nameParsed allowed rest⟩
    · by_cases reference : token = .referenceName
      · subst token
        simp only [suffixMatches, declaration, ↓reduceIte, Bool.and_eq_true,
          decide_eq_true_eq] at accepted
        obtain ⟨⟨⟨present, nonzero⟩, same⟩, remaining⟩ := accepted
        obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
        obtain ⟨events, rest⟩ := ih _ _ _ _ remaining
        exact ⟨_, .reference present nameParsed same rest⟩
      · by_cases literal : token = .base .stringLiteral
        · subst token
          simp only [suffixMatches, declaration, reference, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq,
            beq_iff_eq] at accepted
          obtain ⟨⟨⟨⟨bound, opening⟩, nonzero⟩, equal⟩, remaining⟩ := accepted
          obtain ⟨value, valueParsed⟩ := Output.literalAt_sound text _ nonzero
          rw [Guarded.literalLength_decodes valueParsed] at equal remaining
          obtain ⟨events, rest⟩ := ih _ _ _ _ remaining
          refine ⟨_, .literal bound opening valueParsed ?_ rest⟩
          intro later
          simpa [later] using equal
        · simp only [suffixMatches, declaration, reference, literal, ↓reduceIte, Bool.and_eq_true] at accepted
          obtain ⟨events, rest⟩ := ih _ _ _ _ accepted.2
          exact ⟨events, .fixed declaration reference literal accepted.1 rest⟩

theorem parsed_iff (text : Source) (tokens : List Token) (index position : Nat) (state : NameState) (initialLength : Nat) :
    suffixMatches text tokens index position state initialLength = true ↔ ∃ events, Parsed text tokens index position state initialLength events :=
  ⟨parsed_sound text tokens index position state initialLength, fun ⟨_, parsed⟩ => parsed_complete parsed⟩


theorem parsed_erases {text : Source} {tokens : List Token} {index position initialLength : Nat}
    {state : NameState} {events : List Event}
    (parsed : Parsed text tokens index position state initialLength events) :
    Named.Parsed text tokens position state events := by
  induction parsed with
  | done ending => exact .done ending
  | fixed a b c matched _ ih => exact .fixed a b c matched ih
  | declaration name allowed _ ih => exact .declaration name allowed ih
  | reference present name same _ ih => exact .reference present name same ih
  | literal bound opening value _ _ ih => exact .literal bound opening value ih

def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ events, Parsed source requiredTokens 1 1 {} 0 events

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches source requiredTokens 1 1 {} 0

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, parsed_iff, and_assoc]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

end Silver.Assignment
