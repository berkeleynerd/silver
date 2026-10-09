import Silver.NamedIdentifier

namespace Silver.Named

inductive Token
  | base (token : Output.Token)
  | colon | constantKeyword | stringName | assignment | declarationName | referenceName
  deriving DecidableEq, Repr

def Token.spellingText : Token → String
  | .base token => token.spellingText
  | .colon => ":" | .constantKeyword => "constant" | .stringName => "string"
  | .assignment => ":=" | .declarationName | .referenceName => "_"

def Token.spelling (token : Token) : Source := token.spellingText.toList.map Char.toNat

def Token.isWord : Token → Bool
  | .base token => token.isWord
  | .constantKeyword | .stringName => true
  | _ => false

def requiredTokens : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment,
   .base .stringLiteral, .base .semicolon, .base .beginKeyword,
   .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis,
   .referenceName, .base .rightParenthesis, .base .semicolon,
   .base .endKeyword, .base .mainName, .base .semicolon]

def tokenAt (text : Source) (position : Nat) (token : Token) : Bool :=
  decide (token.spelling.length ≤ text.length + 1 - position) &&
    decide (∀ index : Fin token.spelling.length,
      lowercase (Cursor.byteAt text (position + index.val)) = token.spelling[index.val]) &&
    (!token.isWord || decide (position + token.spelling.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + token.spelling.length)))

structure NameState where
  first : Nat := 0
  after : Nat := 0
  deriving DecidableEq, Repr

def NameState.Valid (text : Source) (state : NameState) : Prop :=
  (state.first = 0 ∧ state.after = 0) ∨
    (0 < state.first ∧ state.first < state.after ∧ state.after ≤ text.length + 1)

inductive Event
  | declaration (canonical : Source)
  | literal (bytes : Source)
  | reference (canonical : Source)
  deriving DecidableEq, Repr

inductive EventKind | declaration | literal | reference deriving DecidableEq, Repr

def Event.kind : Event → EventKind
  | .declaration _ => .declaration | .literal _ => .literal | .reference _ => .reference

def Token.eventKind : Token → Option EventKind
  | .declarationName => some .declaration
  | .referenceName => some .reference
  | .base .stringLiteral => some .literal
  | _ => none

def suffixMatches (text : Source) : List Token → Nat → NameState → Bool
  | [], position, _ => decide (Cursor.triviaPosition text position = text.length + 1)
  | token :: tokens, position, state =>
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        suffixMatches text tokens (identifierEnd text start) ⟨start, identifierEnd text start⟩
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        suffixMatches text tokens (identifierEnd text start) state
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        suffixMatches text tokens (Output.literalEnd text (start + 1)) state
    else tokenAt text start token && suffixMatches text tokens (start + token.spelling.length) state

/-- Independent grammar: name/literal derivations record their values. The
separately proved name predicates enforce declaration policy and binding. -/
inductive Parsed (text : Source) : List Token → Nat → NameState → List Event → Prop
  | done {position : Nat} {state : NameState} :
      Cursor.triviaPosition text position = text.length + 1 → Parsed text [] position state []
  | fixed {position : Nat} {state : NameState} {token : Token} {tokens : List Token} {events : List Event} :
      token ≠ .declarationName → token ≠ .referenceName → token ≠ .base .stringLiteral →
      tokenAt text (Cursor.triviaPosition text position) token = true →
      Parsed text tokens (Cursor.triviaPosition text position + token.spelling.length) state events →
      Parsed text (token :: tokens) position state events
  | declaration {position finish : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      IdentifierAt text (Cursor.triviaPosition text position) name finish →
      forbiddenName text (Cursor.triviaPosition text position) finish = false →
      Parsed text tokens finish ⟨Cursor.triviaPosition text position, finish⟩ events →
      Parsed text (.declarationName :: tokens) position state (.declaration (name.map lowercase) :: events)
  | reference {position finish : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      0 < state.first → IdentifierAt text (Cursor.triviaPosition text position) name finish →
      equalName text state.first state.after (Cursor.triviaPosition text position) finish = true →
      Parsed text tokens finish state events →
      Parsed text (.referenceName :: tokens) position state (.reference (name.map lowercase) :: events)
  | literal {position finish : Nat} {state : NameState} {value : Source}
      {tokens : List Token} {events : List Event} :
      Cursor.triviaPosition text position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text position + 1) value finish →
      Parsed text tokens finish state events →
      Parsed text (.base .stringLiteral :: tokens) position state (.literal value :: events)

theorem parsed_complete {text : Source} {tokens : List Token} {position : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens position state events) :
    suffixMatches text tokens position state = true := by
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
  | literal bound opening value previous ih =>
      have finish := Output.literalAt_bounds value
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) finish.1)
      simp [suffixMatches, bound, opening, Output.literalAt_complete value, nonzero, ih]

theorem parsed_sound (text : Source) (tokens : List Token) (position : Nat) (state : NameState)
    (accepted : suffixMatches text tokens position state = true) :
    ∃ events, Parsed text tokens position state events := by
  induction tokens generalizing position state with
  | nil => exact ⟨[], .done (by simpa [suffixMatches] using accepted)⟩
  | cons token tokens ih =>
    by_cases declaration : token = .declarationName
    · subst token
      simp only [suffixMatches, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq,
        Bool.not_eq_true'] at accepted
      obtain ⟨⟨nonzero, allowed⟩, remaining⟩ := accepted
      obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
      obtain ⟨events, rest⟩ := ih _ _ remaining
      exact ⟨_, .declaration nameParsed allowed rest⟩
    · by_cases reference : token = .referenceName
      · subst token
        simp only [suffixMatches, declaration, ↓reduceIte, Bool.and_eq_true,
          decide_eq_true_eq] at accepted
        obtain ⟨⟨⟨present, nonzero⟩, same⟩, remaining⟩ := accepted
        obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
        obtain ⟨events, rest⟩ := ih _ _ remaining
        exact ⟨_, .reference present nameParsed same rest⟩
      · by_cases literal : token = .base .stringLiteral
        · subst token
          simp only [suffixMatches, declaration, reference, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq,
            beq_iff_eq] at accepted
          obtain ⟨⟨⟨bound, opening⟩, nonzero⟩, remaining⟩ := accepted
          obtain ⟨value, valueParsed⟩ := Output.literalAt_sound text _ nonzero
          obtain ⟨events, rest⟩ := ih _ _ remaining
          exact ⟨_, .literal bound opening valueParsed rest⟩
        · simp only [suffixMatches, declaration, reference, literal, ↓reduceIte, Bool.and_eq_true] at accepted
          obtain ⟨events, rest⟩ := ih _ _ accepted.2
          exact ⟨events, .fixed declaration reference literal accepted.1 rest⟩

theorem parsed_iff (text : Source) (tokens : List Token) (position : Nat) (state : NameState) :
    suffixMatches text tokens position state = true ↔ ∃ events, Parsed text tokens position state events :=
  ⟨parsed_sound text tokens position state, fun ⟨_, parsed⟩ => parsed_complete parsed⟩

theorem parsed_unique {text : Source} {tokens : List Token} {position : Nat} {state : NameState}
    {left right : List Event} (first : Parsed text tokens position state left)
    (second : Parsed text tokens position state right) : left = right := by
  induction first generalizing right with
  | done => cases second; rfl
  | fixed declaration reference literal matched previous ih =>
      cases second with
      | fixed _ _ _ _ other => exact ih other
      | declaration => contradiction
      | reference => contradiction
      | literal => contradiction
  | declaration name allowed previous ih =>
      cases second with
      | fixed different => contradiction
      | declaration otherName _ other =>
          obtain ⟨rfl, rfl⟩ := identifier_unique name otherName
          exact congrArg (List.cons _) (ih other)
  | reference present name same previous ih =>
      cases second with
      | fixed _ different => contradiction
      | reference _ otherName _ other =>
          obtain ⟨rfl, rfl⟩ := identifier_unique name otherName
          exact congrArg (List.cons _) (ih other)
  | literal bound opening value previous ih =>
      cases second with
      | fixed _ _ different => contradiction
      | literal _ _ otherValue other =>
          obtain ⟨rfl, rfl⟩ := Output.literalAt_unique value otherValue
          exact congrArg (List.cons _) (ih other)

theorem parsed_eventKinds {text : Source} {tokens : List Token} {position : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens position state events) :
    events.map Event.kind = tokens.filterMap Token.eventKind := by
  induction parsed with
  | done => rfl
  | @fixed position state token tokens events declaration reference literal matched previous ih =>
      have kind : token.eventKind = none := by
        cases token <;> simp_all [Token.eventKind]
      simpa [kind] using ih
  | declaration _ _ _ ih => simpa [Event.kind, Token.eventKind] using ih
  | reference _ _ _ _ ih => simpa [Event.kind, Token.eventKind] using ih
  | literal _ _ _ _ ih => simpa [Event.kind, Token.eventKind] using ih

def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ events, Parsed source requiredTokens 1 {} events

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches source requiredTokens 1 {}

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, parsed_iff, and_assoc]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

end Silver.Named
