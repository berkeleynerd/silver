import Silver.AssignmentSemantics
import Silver.GuardedDisjoint

namespace Silver.Assignment

open Named

private theorem begin_letters : ∀ index : Fin Output.Token.beginKeyword.spelling.length,
    identifierCharacter Output.Token.beginKeyword.spelling[index.val] = true := by decide

theorem literal_assignment_disjoint (source : Source) : ¬ (Output.Member source ∧ Member source) := by
  rintro ⟨literalMember, namedMember⟩
  obtain ⟨value, literalParsed⟩ := literalMember.2.2.2
  obtain ⟨events, original⟩ := namedMember.2.2.2
  have namedParsed := parsed_erases original
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

theorem null_assignment_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, namedMember⟩
  have nullParsed := (Cursor.isMember_iff source).mpr nullMember
  change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
    .procedureKeyword && _)) = true at nullParsed
  simp only [Bool.and_eq_true] at nullParsed
  have nullToken := nullParsed.2.1
  obtain ⟨events, original⟩ := namedMember.2.2.2
  have parsed := parsed_erases original
  cases parsed with
  | fixed _ _ _ matched rest =>
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstNamed := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Named.Token.spelling, Named.Token.spellingText,
        Output.Token.spellingText] at firstNull firstNamed
      omega


private theorem constant_string_conflict {text : Source} {position : Nat}
    (old : Named.tokenAt text position .constantKeyword = true)
    (new : Named.tokenAt text position .stringName = true) : False := by
  simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at old new
  have firstOld := old.1.2 ⟨0, by decide⟩
  have firstNew := new.1.2 ⟨0, by decide⟩
  simp [Named.Token.spelling, Named.Token.spellingText] at firstOld firstNew
  omega

theorem named_assignment_disjoint (source : Source) : ¬ (Named.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨a, first⟩ := oldMember.2.2.2
  obtain ⟨b, original⟩ := newMember.2.2.2
  have second := parsed_erases original
  obtain ⟨cursor, state, a, b, first, second⟩ := Concat.common_prefix (requiredTokens.take 14)
    (left := Named.requiredTokens.drop 14) (right := requiredTokens.drop 14) first second
  cases first with
  | fixed _ _ _ first _ =>
    cases second with
    | fixed _ _ _ second _ => exact constant_string_conflict first second

theorem concat_assignment_disjoint (source : Source) : ¬ (Concat.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨a, first⟩ := oldMember.2.2.2
  obtain ⟨b, original⟩ := newMember.2.2.2
  have second := parsed_erases original
  obtain ⟨cursor, state, a, b, first, second⟩ := Concat.common_prefix (requiredTokens.take 14)
    (left := Concat.requiredTokens.drop 14) (right := requiredTokens.drop 14) first second
  cases first with
  | fixed _ _ _ first _ =>
    cases second with
    | fixed _ _ _ second _ => exact constant_string_conflict first second

theorem assignment_argument_disjoint (source : Source) : ¬ (Member source ∧ Arguments.Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, original⟩ := oldMember.2.2.2
  have oldParsed := parsed_erases original
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

theorem assignment_guarded_disjoint (source : Source) : ¬ (Member source ∧ Guarded.Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, original⟩ := oldMember.2.2.2
  have oldParsed := parsed_erases original
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, index, old, new⟩ := Guarded.common_named_prefix Guarded.contextPrefix (by decide) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
    cases new with
    | fixed _ _ _ _ newMatch newRest =>
      simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at oldMatch
      simp only [Guarded.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at newMatch
      have oldFirst := oldMatch.1.2 ⟨0, by decide⟩
      have newFirst := newMatch.1.2 ⟨0, by decide⟩
      simp [Named.Token.spelling, Named.Token.spellingText, Guarded.Token.spelling,
        Guarded.Token.spellingText, Output.Token.spellingText] at oldFirst newFirst
      omega

end Silver.Assignment
