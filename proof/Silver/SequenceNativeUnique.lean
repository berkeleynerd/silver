module

public import Silver.SequenceNativeEquations

@[expose] public section

namespace Silver.Sequence.Native
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Only the already interpreted lexical and basic-statement calls are related.
No recursive body scanner or language-membership equality occurs here. -/
structure PrimitiveAgreement (left right : Primitives) : Prop where
  take : ∀ text, ValidText text → ∀ position token,
    position ≤ text.length + 1 → ValidToken token →
    left.take text position token = right.take text position token
  token : ∀ text, ValidText text → ∀ scan token,
    Compose.Expressions.ValidState text scan.state → ValidToken token →
    left.token text scan token = right.token text scan token
  basic : ∀ text, ValidText text → ∀ scan,
    Compose.Expressions.ValidState text scan.state → left.basic text scan = right.basic text scan

section
variable {p q : Primitives} {left right : Calls}
variable (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
variable (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
include agree le re valid contextValid

theorem token_unique (scan : Scan) (scanValid : ValidScan text context scan) (token : ShellToken) (tokenValid : ValidToken token) :
    left.token text context scan token = right.token text context scan token := by
  rw [le.token text valid context scan token contextValid scanValid tokenValid,
    re.token text valid context scan token contextValid scanValid tokenValid, token_eval, token_eval]
  unfold tokenEquation
  rw [agree.token text valid (expand context scan) token (expand_valid text context scan contextValid scanValid) tokenValid]

theorem basic_unique (scan : Scan) (scanValid : ValidScan text context scan) :
    left.basic text context scan = right.basic text context scan := by
  rw [le.basic text valid context scan contextValid scanValid,
    re.basic text valid context scan contextValid scanValid]
  simp +instances only [basicBody, Expr.eval]
  rw [agree.basic text valid (expand context scan) (expand_valid text context scan contextValid scanValid)]

omit contextValid in
theorem stop_unique (position : Nat) (bound : position ≤ text.length + 1) (stop : Stop) :
    left.atStop text position stop = right.atStop text position stop := by
  rw [le.stop text valid position stop bound, re.stop text valid position stop bound]
  have take := fun token good => agree.take text valid position token bound good
  cases stop <;> simp +instances only [stopBody]
  all_goals try rw [take (.word "end") (by unfold ValidToken Compose.Expressions.ValidToken; decide)]
  all_goals try rw [take (.word "else") (by unfold ValidToken Compose.Expressions.ValidToken; decide)]
  all_goals try rw [take (.word "elsif") (by unfold ValidToken Compose.Expressions.ValidToken; decide)]

omit agree le re in
theorem tokens_valid (calls : Calls) (ranges : Ranges calls) (scan : Scan)
    (scanValid : ValidScan text context scan) (values : List ShellToken)
    (tokensValid : ∀ token ∈ values, ValidToken token) :
    ValidScan text context (tokens calls text context scan values) := by
  induction values generalizing scan with
  | nil => exact scanValid
  | cons token values ih =>
      exact ih (calls.token text context scan token)
        (ranges.token text valid context scan token contextValid scanValid (tokensValid _ (by simp))).1
        (fun token member => tokensValid token (by simp [member]))

theorem tokens_unique (scan : Scan) (scanValid : ValidScan text context scan)
    (values : List ShellToken) (tokensValid : ∀ token ∈ values, ValidToken token) :
    tokens left text context scan values = tokens right text context scan values := by
  induction values generalizing scan with
  | nil => rfl
  | cons token values ih =>
      have one := token_unique agree le re text valid context contextValid scan scanValid token (tokensValid _ (by simp))
      simp +instances only [tokens, List.foldl_cons, one]
      exact ih (right.token text context scan token)
        (re.ranges.token text valid context scan token contextValid scanValid (tokensValid _ (by simp))).1
        (fun token member => tokensValid token (by simp [member]))

omit agree le re valid contextValid in
private theorem equality_valid : ∀ token ∈ equalityTokens, ValidToken token := by
  simp [equalityTokens, ValidToken, Compose.Expressions.ValidToken, Compose.Expressions.allTokens]
omit agree le re valid contextValid in
private theorem elsif_valid : ∀ token ∈ elsifTokens, ValidToken token := by
  simp [elsifTokens, ValidToken, Compose.Expressions.ValidToken, Compose.Expressions.allTokens]
omit agree le re valid contextValid in
private theorem ending_valid : ∀ token ∈ endIfTokens, ValidToken token := by
  simp [endIfTokens, ValidToken, Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

omit agree le re valid contextValid
mutual
  theorem statement_unique (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
      (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
      (scan : Scan) (scanValid : ValidScan text context scan) :
      left.statement text context scan = right.statement text context scan := by
    rw [le.statement text valid context scan contextValid scanValid,
      re.statement text valid context scan contextValid scanValid]
    dsimp +instances only [statementBody, Expr.eval, Condition.eval, TokenRef.eval]
    simp +instances only [decide_eq_true_eq]
    rw [agree.take text valid scan.position (.word "if") scanValid.1 (by unfold ValidToken Compose.Expressions.ValidToken; decide)]
    by_cases zero : scan.position = 0
    · simp [zero]
    · simp +instances only [zero, ↓reduceIte]
      split
      · exact conditional_unique agree le re text valid context contextValid scan scanValid
      · exact basic_unique agree le re text valid context contextValid scan scanValid
  termination_by (text.length + 1 - scan.position, 2)

  theorem conditional_unique (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
      (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
      (scan : Scan) (scanValid : ValidScan text context scan) :
      left.conditional text context scan = right.conditional text context scan := by
    rw [le.conditional text valid context scan contextValid scanValid,
      re.conditional text valid context scan contextValid scanValid, conditional_eval, conditional_eval]
    unfold conditionalEquation
    have comparisonEq := tokens_unique agree le re text valid context contextValid scan scanValid equalityTokens equality_valid
    have comparisonValid := tokens_valid text valid context contextValid right re.ranges scan scanValid equalityTokens equality_valid
    rw [comparisonEq]
    by_cases stopped : (tokens right text context scan equalityTokens).position ≤ scan.position
    · simp [stopped]
    · simp +instances only [stopped, ↓reduceIte]
      rw [read_unique agree le re text valid context contextValid _ comparisonValid .arm]
      have yesValid := (re.ranges.read text valid context _ .arm contextValid comparisonValid).1
      by_cases stoppedYes : (right.read text context (tokens right text context scan equalityTokens) .arm).position ≤ scan.position
      · simp [stoppedYes]
      · simp +instances only [stoppedYes, ↓reduceIte]
        rw [alternative_unique agree le re text valid context contextValid _ yesValid]
        have lastValid := (re.ranges.alternative text valid context _ contextValid yesValid).1
        rw [tokens_unique agree le re text valid context contextValid _ lastValid endIfTokens ending_valid]
  termination_by (text.length + 1 - scan.position, 1)
  decreasing_by all_goals simp_wf; unfold ValidScan at *; omega

  theorem alternative_unique (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
      (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
      (scan : Scan) (scanValid : ValidScan text context scan) :
      left.alternative text context scan = right.alternative text context scan := by
    rw [le.alternative text valid context scan contextValid scanValid,
      re.alternative text valid context scan contextValid scanValid, alternative_eval, alternative_eval]
    unfold alternativeEquation
    rw [agree.take text valid scan.position (.word "elsif") scanValid.1 (by unfold ValidToken Compose.Expressions.ValidToken; decide),
      agree.take text valid scan.position (.word "else") scanValid.1 (by unfold ValidToken Compose.Expressions.ValidToken; decide),
      agree.take text valid scan.position (.word "end") scanValid.1 (by unfold ValidToken Compose.Expressions.ValidToken; decide)]
    by_cases zero : scan.position = 0
    · simp [zero]
    · simp +instances only [zero, ↓reduceIte]
      by_cases hasElsif : q.take text scan.position (.word "elsif") ≠ 0
      · rw [ite_eq_left hasElsif, ite_eq_left hasElsif]
        rw [tokens_unique agree le re text valid context contextValid scan scanValid elsifTokens elsif_valid]
        have comparisonValid := tokens_valid text valid context contextValid right re.ranges scan scanValid elsifTokens elsif_valid
        by_cases stopped : (tokens right text context scan elsifTokens).position ≤ scan.position
        · simp [stopped]
        · simp +instances only [stopped, ↓reduceIte]
          rw [read_unique agree le re text valid context contextValid _ comparisonValid .arm]
          have yesValid := (re.ranges.read text valid context _ .arm contextValid comparisonValid).1
          by_cases stoppedYes : (right.read text context (tokens right text context scan elsifTokens) .arm).position ≤ scan.position
          · simp [stoppedYes]
          · simp +instances only [stoppedYes, ↓reduceIte]
            exact alternative_unique agree le re text valid context contextValid _ yesValid
      · rw [ite_eq_right hasElsif, ite_eq_right hasElsif]
        by_cases hasElse : q.take text scan.position (.word "else") ≠ 0
        · rw [ite_eq_left hasElse, ite_eq_left hasElse]
          rw [token_unique agree le re text valid context contextValid scan scanValid (.word "else") (by unfold ValidToken Compose.Expressions.ValidToken; decide)]
          have nextValid := (re.ranges.token text valid context scan (.word "else") contextValid scanValid (by unfold ValidToken Compose.Expressions.ValidToken; decide)).1
          by_cases stopped : (right.token text context scan (.word "else")).position ≤ scan.position
          · simp [stopped]
          · simp +instances only [stopped, ↓reduceIte]
            exact read_unique agree le re text valid context contextValid _ nextValid .endOnly
        · simp [hasElse]
  termination_by (text.length + 1 - scan.position, 1)
  decreasing_by all_goals simp_wf; unfold ValidScan at *; omega

  theorem tail_unique (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
      (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
      (scan : Scan) (scanValid : ValidScan text context scan) (stop : Stop) :
      left.tail text context scan stop = right.tail text context scan stop := by
    rw [le.tail text valid context scan stop contextValid scanValid,
      re.tail text valid context scan stop contextValid scanValid,
      tailImplementation_eval, tailImplementation_eval]
    dsimp +instances only [tailBody, Expr.eval, Condition.eval, StopRef.eval]
    simp +instances only [decide_eq_true_eq]
    rw [stop_unique agree le re text valid scan.position scanValid.1 stop]
    by_cases zero : scan.position = 0
    · simp [zero]
    · simp +instances only [zero, ↓reduceIte]
      split
      · rfl
      · rw [statement_unique agree le re text valid context contextValid scan scanValid]
        have nextValid := (re.ranges.statement text valid context scan contextValid scanValid).1
        by_cases stopped : (right.statement text context scan).position ≤ scan.position
        · simp [stopped]
        · simp +instances only [stopped, ↓reduceIte]
          exact tail_unique agree le re text valid context contextValid _ nextValid stop
  termination_by (text.length + 1 - scan.position, 3)
  decreasing_by all_goals simp_wf; unfold ValidScan at *; omega

  theorem read_unique (agree : PrimitiveAgreement p q) (le : Equations p left) (re : Equations q right)
      (text : Source) (valid : ValidText text) (context : Context) (contextValid : ValidContext text context)
      (scan : Scan) (scanValid : ValidScan text context scan) (stop : Stop) :
      left.read text context scan stop = right.read text context scan stop := by
    rw [le.read text valid context scan stop contextValid scanValid,
      re.read text valid context scan stop contextValid scanValid,
      readImplementation_eval, readImplementation_eval]
    dsimp +instances only [readBody, Expr.eval, Condition.eval, StopRef.eval]
    simp +instances only [decide_eq_true_eq]
    rw [statement_unique agree le re text valid context contextValid scan scanValid]
    have next := re.ranges.statement text valid context scan contextValid scanValid
    by_cases failed : (right.statement text context scan).position = 0
    · simp [failed]
    · simp +instances only [failed, ↓reduceIte]
      exact tail_unique agree le re text valid context contextValid _ next.1 stop
  termination_by (text.length + 1 - scan.position, 3)
  decreasing_by
    all_goals simp_wf
    all_goals try omega
    all_goals unfold ValidScan at *
    all_goals omega
end

end
end Silver.Sequence.Native
