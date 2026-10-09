import Silver.GuardedDecimal

namespace Silver.Guarded

open Named

inductive Token
  | base (token : Output.Token)
  | colon | constantKeyword | stringName | assignment | declarationName | referenceName | ampersand
  | argumentsName | firstOrDefaultName | ifKeyword | inputIsValidName | thenKeyword | elseKeyword | rejectName
  | andKeyword | apostrophe | lengthName | lessEqual | capacityLiteral
  deriving DecidableEq, Repr

def Token.spellingText : Token → String
  | .base token => token.spellingText
  | .colon => ":" | .constantKeyword => "constant" | .stringName => "string"
  | .assignment => ":=" | .declarationName | .referenceName => "_" | .ampersand => "&"
  | .argumentsName => "silver_arguments" | .firstOrDefaultName => "first_or_default"
  | .ifKeyword => "if" | .inputIsValidName => "input_is_valid" | .thenKeyword => "then"
  | .elseKeyword => "else" | .rejectName => "reject" | .andKeyword => "and"
  | .apostrophe => "'" | .lengthName => "length" | .lessEqual => "<=" | .capacityLiteral => "0"

def Token.spelling (token : Token) : Source := token.spellingText.toList.map Char.toNat

def Token.isWord : Token → Bool
  | .base token => token.isWord
  | .constantKeyword | .stringName | .argumentsName | .firstOrDefaultName
  | .ifKeyword | .inputIsValidName | .thenKeyword | .elseKeyword | .rejectName
  | .andKeyword | .lengthName => true
  | _ => false

def requiredTokens : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .withKeyword, .argumentsName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment,
   .argumentsName, .base .dot, .firstOrDefaultName, .base .leftParenthesis,
   .base .stringLiteral, .base .rightParenthesis, .base .semicolon,
   .base .beginKeyword, .ifKeyword, .argumentsName, .base .dot,
   .inputIsValidName, .andKeyword, .thenKeyword, .referenceName,
   .apostrophe, .lengthName, .lessEqual, .capacityLiteral, .thenKeyword,
   .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis,
   .base .stringLiteral, .ampersand, .referenceName, .ampersand,
   .base .stringLiteral, .base .rightParenthesis, .base .semicolon, .elseKeyword,
   .argumentsName, .base .dot, .rejectName, .base .semicolon,
   .base .endKeyword, .ifKeyword, .base .semicolon, .base .endKeyword,
   .base .mainName, .base .semicolon]

def tokenAt (text : Source) (position : Nat) (token : Token) : Bool :=
  decide (token.spelling.length ≤ text.length + 1 - position) &&
    decide (∀ index : Fin token.spelling.length,
      lowercase (Cursor.byteAt text (position + index.val)) = token.spelling[index.val]) &&
    (!token.isWord || decide (position + token.spelling.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + token.spelling.length)))

abbrev forbiddenName := Arguments.forbiddenName

/-- The marker distinguishes the initializer from the two decorations by the
checked token position, while every value still comes from a literal derivation. -/
inductive Event
  | declaration (canonical : Source)
  | literal (bytes : Source) (decoration : Bool)
  | reference (canonical : Source)
  | capacity (value : Nat)
  deriving DecidableEq, Repr

inductive EventKind | declaration | initial | decoration | reference | capacity
  deriving DecidableEq, Repr

def Event.kind : Event → EventKind
  | .declaration _ => .declaration | .literal _ false => .initial
  | .literal _ true => .decoration | .reference _ => .reference | .capacity _ => .capacity

def Token.eventKind (index : Nat) : Token → Option EventKind
  | .declarationName => some .declaration
  | .referenceName => some .reference
  | .capacityLiteral => some .capacity
  | .base .stringLiteral => some (if index > 39 then .decoration else .initial)
  | _ => none

def eventKinds : List Token → Nat → List EventKind
  | [], _ => []
  | token :: tokens, index =>
      (token.eventKind index).toList ++ eventKinds tokens (index + 1)

def suffixMatches (text : Source) : List Token → Nat → Nat → NameState → Nat → Nat → Bool
  | [], _, position, _, capacity, decorations =>
      decide (Cursor.triviaPosition text position = text.length + 1) &&
        decide (capacity + decorations = maxSourceLength)
  | token :: tokens, index, position, state, capacity, decorations =>
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        suffixMatches text tokens (index + 1) (identifierEnd text start) ⟨start, identifierEnd text start⟩ capacity decorations
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        suffixMatches text tokens (index + 1) (identifierEnd text start) state capacity decorations
    else if token = .capacityLiteral then
      decide ((decimalAt text start).after ≠ 0) &&
        suffixMatches text tokens (index + 1) (decimalAt text start).after state (decimalAt text start).value decorations
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        (if index > 39 then decide (decorations + literalLength text (start + 1) ≤ maxSourceLength) else true) &&
        suffixMatches text tokens (index + 1) (Output.literalEnd text (start + 1)) state capacity
          (if index > 39 then decorations + literalLength text (start + 1) else decorations)
    else tokenAt text start token &&
      suffixMatches text tokens (index + 1) (start + token.spelling.length) state capacity decorations

/-- Independent grammar uses decoded literal values and decimal derivations;
scanner results do not supply its semantic payloads. -/
inductive Parsed (text : Source) : List Token → Nat → Nat → NameState → Nat → Nat → List Event → Prop
  | done {index position capacity decorations : Nat} {state : NameState} :
      Cursor.triviaPosition text position = text.length + 1 → capacity + decorations = maxSourceLength →
      Parsed text [] index position state capacity decorations []
  | fixed {index position capacity decorations : Nat} {state : NameState}
      {token : Token} {tokens : List Token} {events : List Event} :
      token ≠ .declarationName → token ≠ .referenceName → token ≠ .capacityLiteral → token ≠ .base .stringLiteral →
      tokenAt text (Cursor.triviaPosition text position) token = true →
      Parsed text tokens (index + 1) (Cursor.triviaPosition text position + token.spelling.length) state capacity decorations events →
      Parsed text (token :: tokens) index position state capacity decorations events
  | declaration {index position finish capacity decorations : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      IdentifierAt text (Cursor.triviaPosition text position) name finish →
      forbiddenName text (Cursor.triviaPosition text position) finish = false →
      Parsed text tokens (index + 1) finish ⟨Cursor.triviaPosition text position, finish⟩ capacity decorations events →
      Parsed text (.declarationName :: tokens) index position state capacity decorations (.declaration (name.map lowercase) :: events)
  | reference {index position finish capacity decorations : Nat} {state : NameState} {name : Source}
      {tokens : List Token} {events : List Event} :
      0 < state.first → IdentifierAt text (Cursor.triviaPosition text position) name finish →
      equalName text state.first state.after (Cursor.triviaPosition text position) finish = true →
      Parsed text tokens (index + 1) finish state capacity decorations events →
      Parsed text (.referenceName :: tokens) index position state capacity decorations (.reference (name.map lowercase) :: events)
  | capacity {index position finish capacity decorations value : Nat} {state : NameState}
      {tokens : List Token} {events : List Event} :
      DecimalAt text (Cursor.triviaPosition text position) value finish →
      Parsed text tokens (index + 1) finish state value decorations events →
      Parsed text (.capacityLiteral :: tokens) index position state capacity decorations (.capacity value :: events)
  | literal {index position finish capacity decorations : Nat} {state : NameState} {value : Source}
      {tokens : List Token} {events : List Event} :
      Cursor.triviaPosition text position ≤ text.length → Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text position + 1) value finish →
      (index > 39 → decorations + value.length ≤ maxSourceLength) →
      Parsed text tokens (index + 1) finish state capacity (if index > 39 then decorations + value.length else decorations) events →
      Parsed text (.base .stringLiteral :: tokens) index position state capacity decorations
        (.literal value (decide (index > 39)) :: events)

theorem parsed_complete {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events) :
    suffixMatches text tokens index position state capacity decorations = true := by
  induction parsed with
  | done ending total => simp [suffixMatches, ending, total]
  | fixed declaration reference capacity literal matched previous ih =>
      simp [suffixMatches, declaration, reference, capacity, literal, matched, ih]
  | declaration name allowed previous ih =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [suffixMatches, identifierEnd_complete name, nonzero, allowed, ih]
  | reference present name same previous ih =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [suffixMatches, identifierEnd_complete name, nonzero, present, same, ih]
  | capacity value previous ih =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (decimalAt_bounds value).1)
      simp [suffixMatches, decimalAt_complete value, nonzero, ih]
  | @literal index position finish capacity decorations state value tokens events bound opening literal enough previous ih =>
      have bounds := Output.literalAt_bounds literal
      have nonzero : finish ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) bounds.1)
      simp [suffixMatches, bound, opening, Output.literalAt_complete literal, nonzero,
        literalLength_decodes literal, ih]
      omega

theorem parsed_sound (text : Source) (tokens : List Token) (index position : Nat) (state : NameState)
    (capacity decorations : Nat) (accepted : suffixMatches text tokens index position state capacity decorations = true) :
    ∃ events, Parsed text tokens index position state capacity decorations events := by
  induction tokens generalizing index position state capacity decorations with
  | nil =>
      simp only [suffixMatches, Bool.and_eq_true, decide_eq_true_eq] at accepted
      exact ⟨[], .done accepted.1 accepted.2⟩
  | cons token tokens ih =>
    by_cases declaration : token = .declarationName
    · subst token
      simp only [suffixMatches, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true'] at accepted
      obtain ⟨⟨nonzero, allowed⟩, remaining⟩ := accepted
      obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
      obtain ⟨events, rest⟩ := ih _ _ _ _ _ remaining
      exact ⟨_, .declaration nameParsed allowed rest⟩
    · by_cases reference : token = .referenceName
      · subst token
        simp only [suffixMatches, declaration, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq] at accepted
        obtain ⟨⟨⟨present, nonzero⟩, same⟩, remaining⟩ := accepted
        obtain ⟨name, nameParsed⟩ := identifierEnd_sound text _ nonzero
        obtain ⟨events, rest⟩ := ih _ _ _ _ _ remaining
        exact ⟨_, .reference present nameParsed same rest⟩
      · by_cases cap : token = .capacityLiteral
        · subst token
          simp only [suffixMatches, declaration, reference, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq] at accepted
          obtain ⟨nonzero, remaining⟩ := accepted
          obtain ⟨events, rest⟩ := ih _ _ _ _ _ remaining
          exact ⟨_, .capacity (decimalAt_sound text _ nonzero) rest⟩
        · by_cases literal : token = .base .stringLiteral
          · subst token
            simp only [suffixMatches, declaration, reference, cap, ↓reduceIte, Bool.and_eq_true,
              decide_eq_true_eq, beq_iff_eq] at accepted
            obtain ⟨⟨⟨⟨bound, opening⟩, nonzero⟩, enough⟩, remaining⟩ := accepted
            obtain ⟨value, valueParsed⟩ := Output.literalAt_sound text _ nonzero
            rw [literalLength_decodes valueParsed] at enough remaining
            obtain ⟨events, rest⟩ := ih _ _ _ _ _ remaining
            refine ⟨_, .literal bound opening valueParsed ?_ rest⟩
            intro decorated
            simpa [decorated] using enough
          · simp only [suffixMatches, declaration, reference, cap, literal, ↓reduceIte, Bool.and_eq_true] at accepted
            obtain ⟨events, rest⟩ := ih _ _ _ _ _ accepted.2
            exact ⟨events, .fixed declaration reference cap literal accepted.1 rest⟩

theorem parsed_iff (text : Source) (tokens : List Token) (index position : Nat) (state : NameState)
    (capacity decorations : Nat) : suffixMatches text tokens index position state capacity decorations = true ↔
      ∃ events, Parsed text tokens index position state capacity decorations events :=
  ⟨parsed_sound text tokens index position state capacity decorations, fun ⟨_, parsed⟩ => parsed_complete parsed⟩

theorem parsed_unique {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {left right : List Event}
    (first : Parsed text tokens index position state capacity decorations left)
    (second : Parsed text tokens index position state capacity decorations right) : left = right := by
  induction first generalizing right with
  | done => cases second; rfl
  | fixed declaration reference capacity literal matched previous ih =>
      cases second with
      | fixed _ _ _ _ _ other => exact ih other
      | declaration => contradiction
      | reference => contradiction
      | capacity => contradiction
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
  | capacity value previous ih =>
      cases second with
      | fixed _ _ different => contradiction
      | capacity otherValue other =>
          obtain ⟨rfl, rfl⟩ := decimalAt_unique value otherValue
          exact congrArg (List.cons _) (ih other)
  | literal bound opening value enough previous ih =>
      cases second with
      | fixed _ _ _ different => contradiction
      | literal _ _ otherValue _ other =>
          obtain ⟨rfl, rfl⟩ := Output.literalAt_unique value otherValue
          exact congrArg (List.cons _) (ih other)

theorem parsed_eventKinds {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events) :
    events.map Event.kind = eventKinds tokens index := by
  induction parsed with
  | done => rfl
  | @fixed index position capacity decorations state token tokens events declaration reference cap literal matched previous ih =>
      have kind : token.eventKind index = none := by
        cases token <;> simp_all [Token.eventKind]
      simpa [eventKinds, kind] using ih
  | declaration _ _ _ ih => simpa [Event.kind, Token.eventKind, eventKinds] using ih
  | reference _ _ _ _ ih => simpa [Event.kind, Token.eventKind, eventKinds] using ih
  | capacity _ _ ih => simpa [Event.kind, Token.eventKind, eventKinds] using ih
  | @literal index position finish capacity decorations state value tokens events bound opening parsed enough previous ih =>
      by_cases decorated : index > 39 <;> simpa [Event.kind, Token.eventKind, eventKinds, decorated] using ih

def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ events, Parsed source requiredTokens 1 1 {} 0 0 events

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches source requiredTokens 1 1 {} 0 0

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, parsed_iff, and_assoc]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

end Silver.Guarded
