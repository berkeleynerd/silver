import Silver.ConcatSemantics
import Silver.ArgumentsDisjoint

namespace Silver.Concat

open Named

private theorem begin_letters : ∀ index : Fin Output.Token.beginKeyword.spelling.length,
    identifierCharacter Output.Token.beginKeyword.spelling[index.val] = true := by decide

theorem literal_concat_disjoint (source : Source) : ¬ (Output.Member source ∧ Member source) := by
  rintro ⟨literalMember, namedMember⟩
  obtain ⟨value, literalParsed⟩ := literalMember.2.2.2
  obtain ⟨events, namedParsed⟩ := namedMember.2.2.2
  obtain ⟨cursor, old, new⟩ := Named.common_prefix Named.commonPrefix (by decide) literalParsed namedParsed
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

theorem null_concat_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
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
      simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstNamed := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Named.Token.spelling, Named.Token.spellingText,
        Output.Token.spellingText] at firstNull firstNamed
      omega


/-- Parsing a common token prefix fixes one cursor and name state, including
its variable identifier and literal spans. No sample-based disjointness is used. -/
theorem common_prefix {text : Source} (common : List Named.Token)
    {left right : List Named.Token} {position : Nat} {state : NameState}
    {leftEvents rightEvents : List Event}
    (first : Parsed text (common ++ left) position state leftEvents)
    (second : Parsed text (common ++ right) position state rightEvents) :
    ∃ cursor nextState a b, Parsed text left cursor nextState a ∧ Parsed text right cursor nextState b := by
  induction common generalizing position state leftEvents rightEvents with
  | nil => exact ⟨position, state, leftEvents, rightEvents, first, second⟩
  | cons token common ih =>
    cases first with
    | fixed declaration reference literal _ first =>
      cases second with
      | fixed _ _ _ _ second => exact ih first second
      | declaration => contradiction
      | reference => contradiction
      | literal => contradiction
    | declaration name _ first =>
      cases second with
      | fixed different => contradiction
      | declaration other _ second =>
        obtain ⟨rfl, rfl⟩ := identifier_unique name other
        exact ih first second
    | reference _ name _ first =>
      cases second with
      | fixed _ different => contradiction
      | reference _ other _ second =>
        obtain ⟨rfl, rfl⟩ := identifier_unique name other
        exact ih first second
    | literal _ _ value first =>
      cases second with
      | fixed _ _ different => contradiction
      | literal _ _ other second =>
        obtain ⟨rfl, rfl⟩ := Output.literalAt_unique value other
        exact ih first second

def namedCommon : List Named.Token := Named.requiredTokens.take 24

theorem named_concat_disjoint (source : Source) : ¬ (Named.Member source ∧ Member source) := by
  rintro ⟨namedMember, concatMember⟩
  obtain ⟨a, first⟩ := namedMember.2.2.2
  obtain ⟨b, second⟩ := concatMember.2.2.2
  obtain ⟨cursor, state, a, b, first, second⟩ := common_prefix namedCommon
    (left := Named.requiredTokens.drop 24) (right := requiredTokens.drop 24) first second
  cases first with
  | fixed _ different => contradiction
  | reference _ identifier _ _ =>
    cases second with
    | fixed _ _ different => contradiction
    | literal _ opening _ _ =>
      cases identifier with
      | identifier _ isLetter _ =>
        rw [opening] at isLetter
        contradiction

theorem concat_argument_disjoint (source : Source) : ¬ (Member source ∧ Arguments.Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, old, new⟩ := Arguments.common_named_prefix Arguments.contextPrefix (by decide) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
    cases new with
    | fixed _ _ _ newMatch newRest =>
      simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at oldMatch
      simp only [Arguments.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at newMatch
      have oldFirst := oldMatch.1.2 ⟨0, by decide⟩
      have newFirst := newMatch.1.2 ⟨0, by decide⟩
      simp [Named.Token.spelling, Named.Token.spellingText, Arguments.Token.spelling,
        Arguments.Token.spellingText, Output.Token.spellingText] at oldFirst newFirst
      omega

end Silver.Concat
