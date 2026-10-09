import Silver.NamedSemantics

namespace Silver.Named

theorem letter_identifier (byte : Nat) (isLetter : letter byte = true) :
    identifierCharacter byte = true := by
  simp only [letter, decide_eq_true_eq] at isLetter
  simp only [identifierCharacter, decide_eq_true_eq]
  omega

theorem lowercase_identifier (byte : Nat) :
    identifierCharacter (lowercase byte) = identifierCharacter byte := by
  unfold lowercase
  split
  · rename_i upper
    apply Bool.eq_iff_iff.mpr
    simp only [identifierCharacter, decide_eq_true_eq]
    omega
  · rfl

theorem identifierTail_characters {text bytes : Source} {position finish : Nat} {previous : Bool}
    (parsed : IdentifierTail text position previous bytes finish) :
    ∀ cursor, position ≤ cursor → cursor < finish → identifierCharacter (Cursor.byteAt text cursor) = true := by
  induction parsed with
  | stop => intro cursor first last; omega
  | @character position finish previous bytes bound character allowed rest ih =>
      intro cursor first last
      by_cases current : cursor = position
      · simpa [current] using character
      · exact ih cursor (by omega) last

theorem identifier_characters {text bytes : Source} {position finish : Nat}
    (parsed : IdentifierAt text position bytes finish) :
    ∀ cursor, position ≤ cursor → cursor < finish → identifierCharacter (Cursor.byteAt text cursor) = true := by
  cases parsed with
  | identifier bound first rest =>
      intro cursor start last
      by_cases current : cursor = position
      · simpa [current] using letter_identifier _ first
      · exact identifierTail_characters rest cursor (by omega) last

theorem identifierTail_maximal {text bytes : Source} {position finish : Nat} {previous : Bool}
    (parsed : IdentifierTail text position previous bytes finish) :
    finish > text.length ∨ identifierCharacter (Cursor.byteAt text finish) = false := by
  induction parsed with
  | stop ending => exact ending
  | character _ _ _ _ ih => exact ih

theorem identifier_maximal {text bytes : Source} {position finish : Nat}
    (parsed : IdentifierAt text position bytes finish) :
    finish > text.length ∨ identifierCharacter (Cursor.byteAt text finish) = false := by
  cases parsed with
  | identifier _ _ rest => exact identifierTail_maximal rest

/-- A fixed word token and a maximal identifier at the same cursor have the
same span and canonical spelling. This rules out prefix-based ambiguity. -/
theorem identifier_token {text name : Source} {position finish : Nat} {token : Output.Token}
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (parsed : IdentifierAt text position name finish)
    (matched : Output.tokenAt text position token = true)
    (word : token.isWord = true)
    (characters : ∀ index : Fin token.spelling.length, identifierCharacter token.spelling[index.val] = true) :
    finish = position + token.spelling.length ∧ name.map lowercase = token.spelling := by
  have bounds := identifier_bounds parsed
  simp only [Output.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
  have ending : position + token.spelling.length > text.length ∨
      identifierCharacter (Cursor.byteAt text (position + token.spelling.length)) = false := by
    simpa [word] using matched.2
  have inside : ∀ cursor, position ≤ cursor → cursor < position + token.spelling.length →
      identifierCharacter (Cursor.byteAt text cursor) = true := by
    intro cursor first last
    let index : Fin token.spelling.length := ⟨cursor - position, by omega⟩
    have same := matched.1.2 index
    have indexed := characters index
    have addition : position + index.val = cursor := by dsimp [index]; omega
    rw [addition] at same
    rw [← same, lowercase_identifier] at indexed
    exact indexed
  have endBound : position + token.spelling.length ≤ text.length + 1 := by omega
  have equal : finish = position + token.spelling.length := by
    by_cases before : finish < position + token.spelling.length
    · have character := inside finish (by omega) before
      have maximal := identifier_maximal parsed
      rcases maximal with outside | stop
      · omega
      · simp_all
    · by_cases after : position + token.spelling.length < finish
      · have character := identifier_characters parsed (position + token.spelling.length) (by omega) after
        rcases ending with outside | stop
        · omega
        · simp_all
      · omega
  refine ⟨equal, ?_⟩
  have matchesName : nameIs text position finish token.spelling = true := by
    simp [nameIs, equal, matched.1.2]
  have value := (nameIs_iff text position finish token.spelling positive (by omega) bounds.2.2.2).mp matchesName
  rw [identifier_span parsed positive]
  exact value

theorem common_prefix {text : Source} (common : List Output.Token)
    (simple : ∀ token ∈ common, token ≠ .stringLiteral)
    {oldTail : List Output.Token} {newTail : List Token} {position : Nat} {state : NameState}
    {values : List Source} {events : List Event}
    (old : Output.Parsed text (common ++ oldTail) position values)
    (new : Parsed text (common.map Token.base ++ newTail) position state events) :
    ∃ cursor, Output.Parsed text oldTail cursor values ∧ Parsed text newTail cursor state events := by
  induction common generalizing position with
  | nil => exact ⟨position, old, new⟩
  | cons token common ih =>
      have different := simple token (by simp)
      cases old with
      | literal => contradiction
      | token _ _ oldRest =>
        cases new with
        | literal => contradiction
        | fixed _ _ _ _ newRest =>
          exact ih (fun token member => simple token (by simp [member])) oldRest newRest

def commonPrefix : List Output.Token :=
  [.withKeyword, .ioName, .semicolon, .procedureKeyword, .mainName, .isKeyword,
   .pragmaKeyword, .sparkModeName, .leftParenthesis, .onName, .rightParenthesis, .semicolon]

private theorem begin_letters : ∀ index : Fin Output.Token.beginKeyword.spelling.length,
    identifierCharacter Output.Token.beginKeyword.spelling[index.val] = true := by decide

theorem literal_named_disjoint (source : Source) : ¬ (Output.Member source ∧ Member source) := by
  rintro ⟨literalMember, namedMember⟩
  obtain ⟨value, literalParsed⟩ := literalMember.2.2.2
  obtain ⟨events, namedParsed⟩ := namedMember.2.2.2
  obtain ⟨cursor, old, new⟩ := common_prefix commonPrefix (by decide) literalParsed namedParsed
  cases old with
  | token _ matched remaining =>
    cases new with
    | fixed different => contradiction
    | @declaration _ finish _ rawName _ _ name forbidden rest =>
      -- The common cursor is positive: its trivia position must have room for begin.
      have nameBounds := identifier_bounds name
      have startPositive : 1 ≤ Cursor.triviaPosition source cursor := by
        have all := Cursor.triviaPosition_bounds source 1 (by omega) (by omega)
        unfold Cursor.triviaPosition Cursor.endPosition
        have size := triviaEnd_length (Cursor.remaining source cursor)
        have remainingLength := Cursor.remaining_length source cursor
        omega
      have startBound : Cursor.triviaPosition source cursor ≤ source.length + 1 := by
        unfold Cursor.triviaPosition Cursor.endPosition
        omega
      obtain ⟨endEqual, value⟩ := identifier_token startPositive startBound name matched rfl begin_letters
      have canonical : canonicalName source (Cursor.triviaPosition source cursor) finish =
          Output.Token.beginKeyword.spelling := by
        unfold canonicalName
        rw [← identifier_span name startPositive]
        exact value
      have isForbidden := (forbiddenName_iff source _ _ startPositive
        (Nat.le_of_lt nameBounds.2.2.1) nameBounds.2.2.2).mpr
        (by rw [canonical]; decide)
      rw [forbidden] at isForbidden
      contradiction

theorem null_named_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, namedMember⟩
  have nullParsed := (Cursor.isMember_iff source).mpr nullMember
  change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
    .procedureKeyword && _)) = true at nullParsed
  simp only [Bool.and_eq_true] at nullParsed
  have nullToken := nullParsed.2.1
  obtain ⟨events, parsed⟩ := namedMember.2.2.2
  cases parsed with
  | fixed _ _ _ matched rest =>
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstNamed := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Token.spelling, Token.spellingText,
        Output.Token.spellingText] at firstNull firstNamed
      omega

end Silver.Named
