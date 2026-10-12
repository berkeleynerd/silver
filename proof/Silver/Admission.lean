module

public import Silver.Lexical

@[expose] public section

namespace Silver

/-- Same order as `Silver_Profile.Token_Kind`. -/
inductive Token
  | procedureKeyword | mainName | isKeyword | pragmaKeyword | sparkModeName
  | onName | beginKeyword | nullKeyword | endKeyword
  | leftParenthesis | rightParenthesis | semicolon
  deriving DecidableEq, Repr

def Token.spelling : Token → Source
  | .procedureKeyword => "procedure".toList.map Char.toNat
  | .mainName => "main".toList.map Char.toNat
  | .isKeyword => "is".toList.map Char.toNat
  | .pragmaKeyword => "pragma".toList.map Char.toNat
  | .sparkModeName => "spark_mode".toList.map Char.toNat
  | .onName => "on".toList.map Char.toNat
  | .beginKeyword => "begin".toList.map Char.toNat
  | .nullKeyword => "null".toList.map Char.toNat
  | .endKeyword => "end".toList.map Char.toNat
  | .leftParenthesis => [40]
  | .rightParenthesis => [41]
  | .semicolon => [59]

def Token.isWord : Token → Bool
  | .leftParenthesis | .rightParenthesis | .semicolon => false
  | _ => true

def requiredTokens : List Token :=
  [.procedureKeyword, .mainName, .isKeyword, .pragmaKeyword, .sparkModeName,
   .leftParenthesis, .onName, .rightParenthesis, .semicolon, .beginKeyword,
   .nullKeyword, .semicolon, .endKeyword, .mainName, .semicolon]

def boundary (token : Token) : Source → Bool
  | [] => true
  | c :: _ => !token.isWord || !identifierCharacter c

/-- A token is an exact case-insensitive source span with its word boundary. -/
def TokenSpan (token : Token) (text rest : Source) : Prop :=
  Spells token.spelling text rest ∧ boundary token rest = true

/-- Independent lexical derivation: trivia spans alternate with catalogue tokens. -/
inductive Parsed : List Token → Source → Prop
  | done (text : Source) : Trivia text [] → Parsed [] text
  | next (token : Token) (tokens : List Token) (text start rest : Source) :
      Trivia text start → TokenSpan token start rest → Parsed tokens rest →
      Parsed (token :: tokens) text

/-- Boolean form of the SPARK `Token_At` ghost predicate on a source suffix. -/
def tokenAt (token : Token) (text : Source) : Bool :=
  decide (token.spelling.length ≤ text.length) &&
    (text.take token.spelling.length).map lowercase == token.spelling &&
    boundary token (text.drop token.spelling.length)

theorem tokenAt_iff (token : Token) (text : Source) : tokenAt token text = true ↔
    TokenSpan token text (text.drop token.spelling.length) := by
  simp [tokenAt, TokenSpan, spells_iff_take_drop, and_assoc]

/-- Functional reading of `Suffix_Matches`, using suffixes instead of cursors. -/
def suffixMatches : List Token → Source → Bool
  | [], text => (triviaEnd text).isEmpty
  | token :: tokens, text =>
    let start := triviaEnd text
    tokenAt token start && suffixMatches tokens (start.drop token.spelling.length)

theorem parsed_iff (tokens : List Token) (text : Source) :
    Parsed tokens text ↔ suffixMatches tokens text = true := by
  induction tokens generalizing text with
  | nil =>
    constructor
    · intro h
      cases h with
      | done _ ht => simp [suffixMatches, trivia_sound ht]
    · intro h
      apply Parsed.done text
      apply (trivia_iff text []).mpr
      simpa [suffixMatches] using h
  | cons token tokens ih =>
    constructor
    · intro h
      cases h with
      | next _ _ _ start rest ht hspan hp =>
        have ht' := trivia_sound ht
        have hsp := (spells_iff_take_drop token.spelling start rest).mp hspan.1
        have ha : tokenAt token start = true := by
          apply (tokenAt_iff token start).mpr
          simpa [hsp.2.2] using hspan
        simpa [suffixMatches, ht', hsp.2.2, ha] using (ih rest).mp hp
    · intro h
      have hs : tokenAt token (triviaEnd text) = true ∧
          suffixMatches tokens ((triviaEnd text).drop token.spelling.length) = true := by
        simpa [suffixMatches] using h
      exact Parsed.next token tokens text (triviaEnd text)
        ((triviaEnd text).drop token.spelling.length) (trivia_complete text)
        ((tokenAt_iff token (triviaEnd text)).mp hs.1)
        ((ih _).mpr hs.2)

def maxSourceLength : Nat := 4096

/-- Declarative membership has no reference to a prover or its outcome. -/
def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ c ∈ source, allowedCharacter c = true) ∧ Parsed requiredTokens source

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches requiredTokens source

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, ← parsed_iff, and_assoc]

/-- Membership is decidable by the independently proved recognizer. -/
instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

theorem accepts_sound (source : Source) (h : accepts source = true) : Member source :=
  (accepts_iff_member source).mp h

theorem accepts_complete (source : Source) (h : Member source) : accepts source = true :=
  (accepts_iff_member source).mpr h

/-- Bounds follow from the same declarative rule, including ignored comments. -/
theorem admitted_bounds (source : Source) (h : Member source) :
    0 < source.length ∧ source.length ≤ 4096 := ⟨h.1, h.2.1⟩

end Silver
