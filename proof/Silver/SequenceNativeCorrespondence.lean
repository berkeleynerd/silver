module

public import Silver.SequenceNativeProjected

@[expose] public section

/-! Representation correspondence between the native shared-context scanner
and the full admission scanner. The projected full scanner satisfies the same
source equations as the concrete scalar witness. Uniqueness then identifies
their results without assuming any recursive scanner equality. -/

namespace Silver.Sequence.Native
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 300000

private theorem expand_compact_of_context {text : Source} {context : Context} {result : ScanResult}
    (valid : Silver.Sequence.ValidScan text result)
    (same : contextOf result = context) (positive : result.state.position ≠ 0) :
    expand context (compact context result) = result := by
  apply expand_compact_success same _ positive
  have namesSame := congrArg (fun c : Context => c.names.length) same
  exact namesSame ▸ valid.2.2.2.1

private theorem expand_position (context : Context) (scan : Scan) :
    (expand context scan).state.position = scan.position := rfl

private theorem projected_tokens (text : Source) (context : Context) (scan : Scan) (values : List ShellToken) :
    tokens projectedCalls text context scan values = modelTokens text context scan values := rfl

private theorem compact_choice (context : Context) (condition : Prop) [Decidable condition]
    (yes no : ScanResult) :
    compact context (if condition then yes else no) =
      if condition then compact context yes else compact context no := by
  by_cases selected : condition <;> simp [selected]

private theorem same_contextOf {before after : ScanResult}
    (same : SameContext after.state before.state) : contextOf after = contextOf before := by
  apply context_same (scan := bodyOf before)
  simpa only [expand_parts] using same

private theorem compact_call {text : Source} {context : Context} {scan : ScanResult}
    (f : ScanResult → ScanResult)
    (zeros : ∀ input, input.state.position = 0 → f input = invalidScan)
    (valid : Silver.Sequence.ValidScan text scan)
    (same : scan.state.position ≠ 0 → contextOf scan = context) :
    compact context (f (expand context (compact context scan))) = compact context (f scan) := by
  by_cases zero : scan.state.position = 0
  · have leftZero : (expand context (compact context scan)).state.position = 0 := by
      simp [compact, zero, expand, invalid]
    rw [zeros _ leftZero, zeros _ zero]
  · rw [expand_compact_of_context valid (same zero) zero]

private theorem read_zero (text : Source) (stop : BodyStop) (scan : ScanResult)
    (zero : scan.state.position = 0) : Silver.Sequence.readBody text scan stop = invalidScan := by
  rw [Silver.Sequence.readBody, statement_zero zero]
  rfl

private theorem modelTokens_after (text : Source) (valid : ValidText text) (context : Context)
    (scan : ScanResult) (values : List ShellToken) (cv : ValidContext text context)
    (sv : Silver.Sequence.ValidScan text scan)
    (same : scan.state.position ≠ 0 → contextOf scan = context)
    (ordinary : ∀ token ∈ values, BodyToken token) :
    modelTokens text context (compact context scan) values = compact context (scanTokens text .direct values scan) := by
  by_cases zero : scan.state.position = 0
  · have scalarZero : compact context scan = invalid := by simp [compact, zero]
    rw [scalarZero, modelTokens_invalid]
    simp [compact, scanTokens_zero text .direct values scan zero]
  · have position := compact_position_of_context sv same
    have scalarPositive : (compact context scan).position ≠ 0 := by rw [position]; exact zero
    have projected := modelTokens_compact text valid context (compact context scan) values cv
      (compact_valid text context scan sv) scalarPositive ordinary
    simpa only [expand_compact_of_context sv (same zero) zero] using projected

private theorem modelToken_zero (text : Source) (context : Context) (scan : Scan)
    (token : ShellToken) (zero : scan.position = 0) : modelToken text context scan token = invalid := by
  simp [modelToken, tokenEquation, modelPrimitives, scanToken, step, expand, zero, compact, invalidState, invalid]

private theorem comparison_tokens_zero (text : Source) (context : Context) (scan : Scan)
    (zero : scan.position = 0) : modelTokens text context scan equalityTokens = invalid := by
  simp only [modelTokens, equalityTokens, List.foldl_cons, List.foldl_nil]
  rw [modelToken_zero text context scan (.word "if") zero]
  simp only [modelToken_invalid]

private theorem projected_statement_equation (text : Source) (_valid : ValidText text)
    (context : Context) (scan : Scan) (_cv : ValidContext text context) (_sv : ValidScan text context scan) :
    projectedCalls.statement text context scan =
      statementBody.eval modelPrimitives projectedCalls {text, context, scan} := by
  change compact context (statementAt text (expand context scan)) = _
  dsimp +instances only [statementBody, Expr.eval, Condition.eval, TokenRef.eval, modelPrimitives,
    projectedCalls, ShellToken.word, Compose.Expressions.spelling, Compose.Expressions.isWord]
  simp +instances only [decide_eq_true_eq]
  by_cases zero : scan.position = 0
  · rw [statement_zero (show (expand context scan).state.position = 0 from zero)]
    simp [zero]
  · rw [statementAt]
    by_cases found : fixedAfter text scan.position "if" true ≠ 0 <;>
      simp +instances [expand_position, zero, found, modelBasic]

private theorem projected_read_equation (text : Source) (valid : ValidText text)
    (context : Context) (scan : Scan) (stop : Stop)
    (cv : ValidContext text context) (sv : ValidScan text context scan) :
    projectedCalls.read text context scan stop =
      readImplementation.eval modelPrimitives projectedCalls {text, context, scan, stop} := by
  have fullValid := expand_valid text context scan cv sv
  have nextValid := model_statementAt_valid text valid (expand context scan) fullValid
  have same := fun positive => context_same (statement_context (text := text) (scan := expand context scan) positive)
  have position := compact_position_of_context nextValid same
  rw [readImplementation_eval]
  change compact context (Silver.Sequence.readBody text (expand context scan) stop.model) = _
  rw [readBody_position_equation text valid _ stop.model fullValid]
  dsimp +instances only [readBodyPositionEquation, readBody, Expr.eval, Condition.eval, StopRef.eval, projectedCalls]
  simp +instances only [position, decide_eq_true_eq]
  by_cases zero : (statementAt text (expand context scan)).state.position = 0
  · simp +instances only [zero, ↓reduceIte, compact_invalidScan]
  · rw [ite_eq_right zero, ite_eq_right zero]
    rw [expand_compact_of_context nextValid (same zero) zero]

private theorem projected_tail_equation (text : Source) (valid : ValidText text)
    (context : Context) (scan : Scan) (stop : Stop)
    (cv : ValidContext text context) (sv : ValidScan text context scan) :
    projectedCalls.tail text context scan stop =
      tailImplementation.eval modelPrimitives projectedCalls {text, context, scan, stop} := by
  have fullValid := expand_valid text context scan cv sv
  have nextValid := model_statementAt_valid text valid (expand context scan) fullValid
  have same := fun positive => context_same (statement_context (text := text) (scan := expand context scan) positive)
  have position := compact_position_of_context nextValid same
  rw [tailImplementation_eval]
  change compact context (bodyTail text (expand context scan) stop.model) = _
  rw [bodyTail_position_equation text valid _ stop.model fullValid]
  dsimp +instances only [bodyTailPositionEquation, tailBody, Expr.eval, Condition.eval, StopRef.eval, projectedCalls]
  simp +instances only [modelStop_model, position, decide_eq_true_eq]
  by_cases zero : scan.position = 0
  · simp +instances only [expand_position, zero, ↓reduceIte, compact_invalidScan]
  · simp +instances only [expand_position, zero, ↓reduceIte]
    by_cases stopped : stopAfter text scan.position stop.model ≠ 0
    · simp +instances [stopped, ↓reduceIte]
      exact compact_expand context scan sv.2.1 |>.trans (ite_eq_right zero)
    · simp +instances [stopped, ↓reduceIte]
      by_cases failed : (statementAt text (expand context scan)).state.position ≤ scan.position
      · simp +instances only [failed, ↓reduceIte, compact_invalidScan]
      · have positive : (statementAt text (expand context scan)).state.position ≠ 0 := by omega
        simp +instances only [failed, ↓reduceIte]
        rw [expand_compact_of_context nextValid (same positive) positive]

private theorem projected_conditional_equation (text : Source) (valid : ValidText text)
    (context : Context) (scan : Scan) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    projectedCalls.conditional text context scan =
      conditionalBody.eval modelPrimitives projectedCalls {text, context, scan} := by
  have fullValid := expand_valid text context scan cv sv
  rw [conditional_eval]
  change compact context (conditionalAt text (expand context scan)) = _
  unfold conditionalEquation
  simp +instances only [projected_tokens]
  dsimp +instances only [projectedCalls, Stop.model]
  by_cases zero : scan.position = 0
  · simp only [conditional_zero (show (expand context scan).state.position = 0 from zero),
      comparison_tokens_zero text context scan zero, compact_invalidScan, invalid, Nat.zero_le, ↓reduceIte]
  · have comparisonValid := model_scanTokens_valid text valid .direct equalityTokens (expand context scan) fullValid
    have comparisonSame := fun positive => context_same
      (scanTokens_context (text := text) (scan := expand context scan) (form := .direct) (tokens := equalityTokens)
        (by simp [equalityTokens, ShapeToken, ShellToken.word]) positive)
    have yesValid := model_readBody_valid text valid _ .arm comparisonValid
    have yesSame := fun positive =>
      (same_contextOf (body_context (text := text) (stop := .arm) positive)).trans (comparisonSame (readBody_input_positive positive))
    have altValid := model_alternativeAt_valid text valid _ yesValid
    have altSame := fun positive =>
      (same_contextOf (alternative_context (text := text) positive)).trans (yesSame (alternative_input_positive positive))
    have finalValid := model_scanTokens_valid text valid .direct endIfTokens _ altValid
    have finalSame := fun positive =>
      (same_contextOf (scanTokens_context (text := text) (form := .direct) (tokens := endIfTokens)
        (by simp [endIfTokens, ShapeToken, ShellToken.word, ShellToken.symbol]) positive)).trans
        (altSame (fun failed => positive (scanTokens_zero text .direct endIfTokens _ failed)))
    simp only [modelTokens_compact text valid context scan equalityTokens cv sv zero
      (by simp [equalityTokens, BodyToken, ShellToken.word])]
    simp only [compact_call (fun input => Silver.Sequence.readBody text input .arm) (read_zero text .arm)
      comparisonValid comparisonSame]
    simp only [compact_call (alternativeAt text) (fun _ failed => alternative_zero failed) yesValid yesSame]
    simp only [modelTokens_after text valid context _ endIfTokens cv altValid altSame
      (by simp [endIfTokens, BodyToken, ShellToken.word, ShellToken.symbol])]
    simp only [compact_position_of_context comparisonValid comparisonSame,
      compact_position_of_context yesValid yesSame, compact_position_of_context finalValid finalSame]
    rw [conditional_position_equation text valid _ fullValid]
    unfold conditionalPositionEquation
    simp +instances only [expand_position, zero, ↓reduceIte]
    dsimp +instances only [expand]
    simp only [compact_choice, compact_invalidScan]

private theorem projected_alternative_equation (text : Source) (valid : ValidText text)
    (context : Context) (scan : Scan) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    projectedCalls.alternative text context scan =
      alternativeBody.eval modelPrimitives projectedCalls {text, context, scan} := by
  have fullValid := expand_valid text context scan cv sv
  rw [alternative_eval]
  change compact context (alternativeAt text (expand context scan)) = _
  rw [alternative_position_equation text valid _ fullValid]
  unfold alternativePositionEquation alternativeEquation
  simp +instances only [projected_tokens]
  dsimp +instances only [projectedCalls, modelPrimitives, Stop.model, ShellToken.word,
    Compose.Expressions.spelling, Compose.Expressions.isWord]
  by_cases zero : scan.position = 0
  · simp +instances only [expand_position, zero, ↓reduceIte, compact_invalidScan]
  · simp +instances only [expand_position, zero, ↓reduceIte]
    by_cases found : fixedAfter text scan.position "elsif" true ≠ 0
    · simp +instances [found, ↓reduceIte]
      have comparisonValid := model_scanTokens_valid text valid .direct elsifTokens (expand context scan) fullValid
      have comparisonSame := fun positive => context_same
        (scanTokens_context (text := text) (scan := expand context scan) (form := .direct) (tokens := elsifTokens)
          (by simp [elsifTokens, ShapeToken, ShellToken.word]) positive)
      have yesValid := model_readBody_valid text valid _ .arm comparisonValid
      have yesSame := fun positive =>
        (same_contextOf (body_context (text := text) (stop := .arm) positive)).trans (comparisonSame (readBody_input_positive positive))
      simp only [modelTokens_compact text valid context scan elsifTokens cv sv zero
        (by simp [elsifTokens, BodyToken, ShellToken.word])]
      simp only [compact_call (fun input => Silver.Sequence.readBody text input .arm) (read_zero text .arm)
        comparisonValid comparisonSame]
      simp only [compact_call (alternativeAt text) (fun _ failed => alternative_zero failed) yesValid yesSame]
      simp only [compact_position_of_context comparisonValid comparisonSame,
        compact_position_of_context yesValid yesSame]
      dsimp +instances only [expand]
      simp only [compact_choice, compact_invalidScan]
    · have foundZero : fixedAfter text scan.position "elsif" true = 0 := by omega
      simp +instances [foundZero, ↓reduceIte]
      by_cases elseFound : fixedAfter text scan.position "else" true ≠ 0
      · simp +instances [elseFound, ↓reduceIte]
        have nextValid := model_scanToken_valid text valid (expand context scan) (.fixed "else" true) fullValid
        have nextSame : (scanToken text (expand context scan) (.fixed "else" true)).state.position ≠ 0 →
            contextOf (scanToken text (expand context scan) (.fixed "else" true)) = context :=
          fun positive => context_same (step_body_context (by trivial : ShapeToken (.fixed "else" true)) positive)
        simp only [modelToken_compact text valid context scan (.fixed "else" true) cv sv
          (by simp [BodyToken])]
        simp only [compact_call (fun input => Silver.Sequence.readBody text input (.token (.fixed "end" true)))
          (read_zero text (.token (.fixed "end" true))) nextValid nextSame]
        simp only [compact_position_of_context nextValid nextSame]
        dsimp +instances only [expand]
        simp only [compact_choice, compact_invalidScan]
      · have elseZero : fixedAfter text scan.position "else" true = 0 := by omega
        simp +instances [elseZero, ↓reduceIte]
        by_cases endFound : fixedAfter text scan.position "end" true ≠ 0
        · simp [endFound]
          exact compact_expand context scan sv.2.1 |>.trans (ite_eq_right zero)
        · have endZero : fixedAfter text scan.position "end" true = 0 := by omega
          simp [endZero]

theorem projected_equations : Equations modelPrimitives projectedCalls where
  ranges := projected_ranges
  token text _ context scan token _ _ _ := by rw [token_eval]; rfl
  basic _ _ _ _ _ _ := rfl
  stop _ _ _ _ _ := rfl
  statement := projected_statement_equation
  conditional := projected_conditional_equation
  alternative := projected_alternative_equation
  tail := projected_tail_equation
  read := projected_read_equation

private theorem model_agreement : PrimitiveAgreement modelPrimitives modelPrimitives where
  take _ _ _ _ _ _ := rfl
  token _ _ _ _ _ _ := rfl
  basic _ _ _ _ := rfl

theorem model_read_projected (text : Source) (valid : ValidText text)
    (context : Context) (scan : Scan) (stop : Stop)
    (cv : ValidContext text context) (sv : ValidScan text context scan) :
    modelRead text context scan stop = compact context (Silver.Sequence.readBody text (expand context scan) stop.model) :=
  read_unique model_agreement model_equations projected_equations text valid context cv scan sv stop

theorem model_adapter (text : Source) (valid : ValidText text) (scan : ScanResult) (stop : ShellToken)
    (scanValid : Compose.Expressions.ValidState text scan.state)
    (stopValid : stop = .word "else" ∨ stop = .word "end") :
    lift (contextOf scan)
      (modelCalls.read text (contextOf scan) (bodyOf scan)
        (if stop = .word "else" then .elseOnly else .endOnly)) =
      Silver.Sequence.readStatements text scan stop := by
  let nativeStop : Stop := if stop = .word "else" then .elseOnly else .endOnly
  have stopSame : nativeStop.model = BodyStop.token stop := by
    rcases stopValid with rfl | rfl <;> decide
  have parts := parts_valid text scan scanValid
  rw [show modelCalls.read = modelRead from rfl,
    model_read_projected text valid _ _ nativeStop parts.1 parts.2,
    expand_parts, stopSame]
  change lift (contextOf scan) (compact (contextOf scan) (Silver.Sequence.readBody text scan (.token stop))) =
    Silver.Sequence.readBody text scan (.token stop)
  by_cases failed : (Silver.Sequence.readBody text scan (.token stop)).state.position = 0
  · rw [readBody_failure failed]
    rfl
  · have resultValid := model_readBody_valid text valid scan (.token stop) scanValid
    have same := same_contextOf (body_context failed)
    have expanded := expand_compact_of_context resultValid same failed
    have position := compact_position_of_context resultValid (fun _ => same)
    simpa only [lift, position, failed, ↓reduceIte] using expanded

end Silver.Sequence.Native
