module

public import Silver.ArgumentsSemantics
public import Silver.NamedDisjoint

@[expose] public section

namespace Silver.Arguments

open Named

theorem common_output_prefix {text : Source} (common : List Output.Token)
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

theorem common_named_prefix {text : Source} (common : List Output.Token)
    (simple : ∀ token ∈ common, token ≠ .stringLiteral)
    {oldTail : List Named.Token} {newTail : List Token} {position : Nat} {state : NameState}
    {oldEvents events : List Event}
    (old : Named.Parsed text (common.map Named.Token.base ++ oldTail) position state oldEvents)
    (new : Parsed text (common.map Token.base ++ newTail) position state events) :
    ∃ cursor, Named.Parsed text oldTail cursor state oldEvents ∧ Parsed text newTail cursor state events := by
  induction common generalizing position with
  | nil => exact ⟨position, old, new⟩
  | cons token common ih =>
      have different := simple token (by simp)
      cases old with
      | literal => contradiction
      | fixed _ _ _ _ oldRest =>
        cases new with
        | literal => contradiction
        | fixed _ _ _ _ newRest =>
          exact ih (fun token member => simple token (by simp [member])) oldRest newRest

def contextPrefix : List Output.Token := [.withKeyword, .ioName, .semicolon]

private theorem procedure_with_conflict {text : Source} {position : Nat}
    (old : Output.tokenAt text position .procedureKeyword = true)
    (new : tokenAt text position (.base .withKeyword) = true) : False := by
  simp only [Output.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at old
  simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at new
  have firstOld := old.1.2 ⟨0, by decide⟩
  have firstNew := new.1.2 ⟨0, by decide⟩
  simp [Output.Token.spelling, Output.Token.spellingText,
    Token.spelling, Token.spellingText] at firstOld firstNew
  omega

theorem literal_argument_disjoint (source : Source) : ¬ (Output.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, old, new⟩ := common_output_prefix contextPrefix (by decide) oldParsed newParsed
  cases old with
  | token _ oldMatch oldRest =>
      cases new with
      | fixed _ _ _ newMatch newRest => exact procedure_with_conflict oldMatch newMatch

theorem named_argument_disjoint (source : Source) : ¬ (Named.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, old, new⟩ := common_named_prefix contextPrefix (by decide) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
      cases new with
      | fixed _ _ _ newMatch newRest => exact procedure_with_conflict oldMatch newMatch

theorem null_argument_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, argumentMember⟩
  have nullParsed := (Cursor.isMember_iff source).mpr nullMember
  change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
    .procedureKeyword && _)) = true at nullParsed
  simp only [Bool.and_eq_true] at nullParsed
  have nullToken := nullParsed.2.1
  obtain ⟨events, parsed⟩ := argumentMember.2.2.2
  cases parsed with
  | fixed _ _ _ matched rest =>
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstArguments := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Token.spelling, Token.spellingText,
        Output.Token.spellingText] at firstNull firstArguments
      omega

end Silver.Arguments
