import Silver.GuardedMain
import Silver.GuardedObligations
import Silver.ConcatDisjoint

namespace Silver.Guarded

open Named

theorem common_output_prefix {text : Source} (common : List Output.Token)
    (simple : ∀ token ∈ common, token ≠ .stringLiteral)
    {oldTail : List Output.Token} {newTail : List Token} {index position capacity decorations : Nat} {state : NameState}
    {values : List Source} {events : List Event}
    (old : Output.Parsed text (common ++ oldTail) position values)
    (new : Parsed text (common.map Token.base ++ newTail) index position state capacity decorations events) :
    ∃ cursor nextIndex, Output.Parsed text oldTail cursor values ∧
      Parsed text newTail nextIndex cursor state capacity decorations events := by
  induction common generalizing index position with
  | nil => exact ⟨position, index, old, new⟩
  | cons token common ih =>
      have different := simple token (by simp)
      cases old with
      | literal => contradiction
      | token _ _ oldRest =>
        cases new with
        | literal => contradiction
        | fixed _ _ _ _ _ newRest =>
          exact ih (fun token member => simple token (by simp [member])) oldRest newRest

theorem common_named_prefix {text : Source} (common : List Output.Token)
    (simple : ∀ token ∈ common, token ≠ .stringLiteral)
    {oldTail : List Named.Token} {newTail : List Token} {index position capacity decorations : Nat} {state : NameState}
    {oldEvents : List Named.Event} {events : List Event}
    (old : Named.Parsed text (common.map Named.Token.base ++ oldTail) position state oldEvents)
    (new : Parsed text (common.map Token.base ++ newTail) index position state capacity decorations events) :
    ∃ cursor nextIndex, Named.Parsed text oldTail cursor state oldEvents ∧
      Parsed text newTail nextIndex cursor state capacity decorations events := by
  induction common generalizing index position with
  | nil => exact ⟨position, index, old, new⟩
  | cons token common ih =>
      have different := simple token (by simp)
      cases old with
      | literal => contradiction
      | fixed _ _ _ _ oldRest =>
        cases new with
        | literal => contradiction
        | fixed _ _ _ _ _ newRest =>
          exact ih (fun token member => simple token (by simp [member])) oldRest newRest

def contextPrefix : List Output.Token := [.withKeyword, .ioName, .semicolon]

private theorem procedure_with_conflict {text : Source} {position : Nat}
    (old : Output.tokenAt text position .procedureKeyword = true)
    (new : tokenAt text position (.base .withKeyword) = true) : False := by
  simp only [Output.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at old
  simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at new
  have firstOld := old.1.2 ⟨0, by decide⟩
  have firstNew := new.1.2 ⟨0, by decide⟩
  simp [Output.Token.spelling, Output.Token.spellingText, Token.spelling, Token.spellingText] at firstOld firstNew
  omega

theorem literal_guarded_disjoint (source : Source) : ¬ (Output.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, index, old, new⟩ := common_output_prefix contextPrefix (by decide) oldParsed newParsed
  cases old with
  | token _ oldMatch oldRest =>
      cases new with
      | fixed _ _ _ _ newMatch newRest => exact procedure_with_conflict oldMatch newMatch

theorem named_guarded_disjoint (source : Source) : ¬ (Named.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, index, old, new⟩ := common_named_prefix contextPrefix (by decide) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
      cases new with
      | fixed _ _ _ _ newMatch newRest => exact procedure_with_conflict oldMatch newMatch

theorem concat_guarded_disjoint (source : Source) : ¬ (Concat.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, index, old, new⟩ := common_named_prefix contextPrefix (by decide) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
      cases new with
      | fixed _ _ _ _ newMatch newRest => exact procedure_with_conflict oldMatch newMatch

theorem null_guarded_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, newMember⟩
  have nullParsed := (Cursor.isMember_iff source).mpr nullMember
  change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
    .procedureKeyword && _)) = true at nullParsed
  simp only [Bool.and_eq_true] at nullParsed
  have nullToken := nullParsed.2.1
  obtain ⟨events, parsed⟩ := newMember.2.2.2
  cases parsed with
  | fixed _ _ _ _ matched rest =>
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstGuarded := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Token.spelling, Token.spellingText, Output.Token.spellingText] at firstNull firstGuarded
      omega

def ofArgument : Arguments.Token → Token
  | .base token => .base token
  | .colon => .colon | .constantKeyword => .constantKeyword | .stringName => .stringName
  | .assignment => .assignment | .declarationName => .declarationName | .referenceName => .referenceName
  | .ampersand => .ampersand | .argumentsName => .argumentsName | .firstOrDefaultName => .firstOrDefaultName
  | .ifKeyword => .ifKeyword | .inputIsValidName => .inputIsValidName | .thenKeyword => .thenKeyword
  | .elseKeyword => .elseKeyword | .rejectName => .rejectName

theorem ofArgument_spelling (token : Arguments.Token) : (ofArgument token).spelling = token.spelling := by
  cases token <;> rfl

/-- Equal variable spans fix the same cursor through the entire shared
initializer. The first differing word is then versus and, after both parsers
have consumed the same declaration and default literal. -/
theorem common_argument_prefix {text : Source} (common : List Arguments.Token)
    {oldTail : List Arguments.Token} {newTail : List Token}
    {index position capacity decorations : Nat} {state : NameState}
    {oldEvents : List Named.Event} {events : List Event}
    (old : Arguments.Parsed text (common ++ oldTail) position state oldEvents)
    (new : Parsed text (common.map ofArgument ++ newTail) index position state capacity decorations events) :
    ∃ cursor nextState nextIndex nextCapacity nextDecorations left right,
      Arguments.Parsed text oldTail cursor nextState left ∧
      Parsed text newTail nextIndex cursor nextState nextCapacity nextDecorations right := by
  induction common generalizing index position state capacity decorations oldEvents events with
  | nil => exact ⟨position, state, index, capacity, decorations, oldEvents, events, old, new⟩
  | cons token common ih =>
    cases token with
    | base token =>
      simp only [List.map_cons, List.cons_append, ofArgument] at new old
      cases old with
      | fixed declaration reference literal matched oldRest =>
        cases new with
        | fixed _ _ _ _ _ newRest => exact ih oldRest newRest
        | literal => contradiction
      | literal bound opening value oldRest =>
        cases new with
        | fixed _ _ _ different => contradiction
        | literal _ _ other _ newRest =>
            obtain ⟨rfl, rfl⟩ := Output.literalAt_unique value other
            exact ih oldRest newRest
    | declarationName =>
      simp only [List.map_cons, List.cons_append, ofArgument] at new old
      cases old with
      | fixed different => contradiction
      | declaration name allowed oldRest =>
        cases new with
        | fixed different => contradiction
        | declaration other _ newRest =>
            obtain ⟨rfl, rfl⟩ := identifier_unique name other
            exact ih oldRest newRest
    | referenceName =>
      simp only [List.map_cons, List.cons_append, ofArgument] at new old
      cases old with
      | fixed _ different => contradiction
      | reference present name same oldRest =>
        cases new with
        | fixed _ different => contradiction
        | reference _ other _ newRest =>
            obtain ⟨rfl, rfl⟩ := identifier_unique name other
            exact ih oldRest newRest
    | colon | constantKeyword | stringName | assignment | ampersand | argumentsName
    | firstOrDefaultName | ifKeyword | inputIsValidName | thenKeyword | elseKeyword | rejectName =>
      simp only [List.map_cons, List.cons_append, ofArgument] at new old
      cases old with
      | fixed _ _ _ _ oldRest =>
        cases new with
        | fixed _ _ _ _ _ newRest => exact ih oldRest newRest

def argumentCommon : List Arguments.Token := Arguments.requiredTokens.take 32

theorem argument_guarded_disjoint (source : Source) : ¬ (Arguments.Member source ∧ Member source) := by
  rintro ⟨oldMember, newMember⟩
  obtain ⟨values, oldParsed⟩ := oldMember.2.2.2
  obtain ⟨events, newParsed⟩ := newMember.2.2.2
  obtain ⟨cursor, state, index, capacity, decorations, left, right, old, new⟩ :=
    common_argument_prefix argumentCommon (oldTail := Arguments.requiredTokens.drop 32)
      (newTail := requiredTokens.drop 32) oldParsed newParsed
  cases old with
  | fixed _ _ _ oldMatch oldRest =>
    cases new with
    | fixed _ _ _ _ newMatch newRest =>
      simp only [Arguments.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at oldMatch
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at newMatch
      have firstOld := oldMatch.1.2 ⟨0, by decide⟩
      have firstNew := newMatch.1.2 ⟨0, by decide⟩
      simp [Arguments.Token.spelling, Arguments.Token.spellingText, Token.spelling, Token.spellingText] at firstOld firstNew
      omega

end Silver.Guarded
