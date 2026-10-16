module

public import Silver.SequenceNativeModel
public import Silver.SequenceBodyContext

@[expose] public section

/-! Scalar body tokens project to the full admission state. Failed scans are
canonicalized; successful scans retain their immutable declaration context. -/

namespace Silver.Sequence.Native
open Compose

set_option backward.dsimp.instances true

theorem modelStop_model (text : Source) (position : Nat) (stop : Stop) :
    modelStop text position stop = decide (stopAfter text position stop.model ≠ 0) := by
  cases stop with
  | endOnly => rfl
  | elseOnly => rfl
  | arm =>
    simp only [modelStop, stopBody, modelPrimitives, Stop.model, stopAfter,
      Compose.Expressions.spelling, Compose.Expressions.isWord, ShellToken.word]
    by_cases first : fixedAfter text position "elsif" true = 0
    · by_cases second : fixedAfter text position "else" true = 0 <;> simp [first, second]
      by_cases last : fixedAfter text position "end" true = 0 <;> simp_all
    · simp [first]

/-- Tokens used directly by recursive conditional frames. Basic statements
already have their own complete scanner correspondence. -/
def BodyToken : ShellToken → Prop
  | .fixed spelling _ => 0 < spelling.toList.length
  | .comparisonExpression => True
  | _ => False

theorem full_expression_nondecreasing (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    (accepted : (expressionAt text position names scalarNames integerHidden).after ≠ 0) :
    position ≤ (expressionAt text position names scalarNames integerHidden).after := by
  have progress := Compose.Expressions.model_tail_nondecreasing
    (scalarNames := scalarNames) (integerHidden := integerHidden) text names
    ⟨position, 0, 0, 0, 0, false, true, false⟩
  exact progress.resolve_left accepted

theorem full_comparison_progress {text : Source} {state : ParserState}
    (valid : ValidText text) (stateValid : Compose.Expressions.ValidState text state)
    (accepted : (comparisonAt text state).position ≠ 0) :
    state.position < (comparisonAt text state).position := by
  unfold comparisonAt at accepted ⊢
  dsimp only at accepted ⊢
  split <;> rename_i fitsBoth
  · simp only [Bool.and_eq_true] at fitsBoth
    have leftPositive : (expressionAt text state.position state.names state.scalarNames).after ≠ 0 := by
      have fitting := fitsBoth.1.1
      simp only [fits, decide_eq_true_eq] at fitting
      exact fitting.1
    have rightPositive : (expressionAt text
        (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false)
        state.names state.scalarNames).after ≠ 0 := by
      have fitting := fitsBoth.1.2
      simp only [fits, decide_eq_true_eq] at fitting
      exact fitting.1
    have first := full_expression_nondecreasing text state.position state.names leftPositive
    have leftValid := Compose.Expressions.model_expression_valid
      (scalarNames := state.scalarNames) (integerHidden := false) text valid state.position state.names
      stateValid.1 stateValid.2.1
    have middlePositive := Compose.Expressions.model_expression_input_nonzero text _ state.names rightPositive
    have middle := Compose.Expressions.model_fixed_advances text _ "=" false leftValid.1 (by decide) middlePositive
    have last := full_expression_nondecreasing text _ state.names rightPositive
    dsimp only
    omega
  · simp_all [invalidState]

theorem full_token_progress {text : Source} {scan : ScanResult} {token : ShellToken}
    (valid : ValidText text) (scanValid : Silver.Sequence.ValidScan text scan)
    (ordinary : BodyToken token) (accepted : (scanToken text scan token).state.position ≠ 0) :
    scan.state.position < (scanToken text scan token).state.position := by
  have positive : scan.state.position ≠ 0 := fun zero =>
    accepted (step_zero text .direct token scan.state zero)
  cases token <;> simp only [BodyToken] at ordinary
  all_goals try contradiction
  case fixed spelling word =>
    simp only [scanToken, step, positive, ↓reduceIte] at accepted ⊢
    exact Compose.Expressions.model_fixed_advances text scan.state.position spelling word scanValid.1 ordinary accepted
  case comparisonExpression =>
    simp only [scanToken, step, positive, ↓reduceIte] at accepted ⊢
    exact full_comparison_progress valid scanValid accepted

theorem bodyToken_shape {token : ShellToken} (ordinary : BodyToken token) : ShapeToken token := by
  cases token <;> simp_all [BodyToken, ShapeToken]

theorem context_same {context : Context} {scan : Scan} {result : ScanResult}
    (same : SameContext result.state (expand context scan).state) : contextOf result = context := by
  cases context
  simp only [SameContext, expand] at same
  simp only [contextOf]
  simp only [same.1, same.2.1, same.2.2.1, same.2.2.2.2]

theorem compact_position {context : Context} {result : ScanResult}
    (target : result.state.target ≤ context.names.length) :
    (compact context result).position = result.state.position := by
  by_cases zero : result.state.position = 0 <;>
    simp [compact, zero, Nat.not_lt.mpr target, invalid, bodyOf]

theorem modelToken_compact (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (token : ShellToken) (contextValid : ValidContext text context)
    (scanValid : ValidScan text context scan) (ordinary : BodyToken token) :
    modelToken text context scan token = compact context (scanToken text (expand context scan) token) := by
  unfold modelToken tokenEquation modelPrimitives
  dsimp only
  split <;> rename_i failed
  · by_cases zero : (scanToken text (expand context scan) token).state.position = 0
    · simp [compact, zero]
    · have fullValid := model_scanToken_valid text valid _ token (expand_valid text context scan contextValid scanValid)
      have contextSame := context_same (result := scanToken text (expand context scan) token)
        (step_body_context (bodyToken_shape ordinary) zero)
      have target : (scanToken text (expand context scan) token).state.target ≤ context.names.length := by
        have namesSame := congrArg (fun c : Context => c.names.length) contextSame
        exact namesSame ▸ fullValid.2.2.2.1
      have position := compact_position target
      have progress := full_token_progress valid (expand_valid text context scan contextValid scanValid) ordinary zero
      change scan.position < (scanToken text (expand context scan) token).state.position at progress
      omega
  · rfl

theorem modelToken_invalid (text : Source) (context : Context) (token : ShellToken) :
    modelToken text context invalid token = invalid := by
  simp [modelToken, tokenEquation, modelPrimitives, scanToken, step, expand, invalid, compact, invalidState]

theorem modelTokens_invalid (text : Source) (context : Context) (tokens : List ShellToken) :
    modelTokens text context invalid tokens = invalid := by
  induction tokens with
  | nil => rfl
  | cons token tokens ih =>
      change modelTokens text context (modelToken text context invalid token) tokens = invalid
      rw [modelToken_invalid, ih]


theorem expand_compact_success {context : Context} {result : ScanResult}
    (same : contextOf result = context) (target : result.state.target ≤ context.names.length)
    (positive : result.state.position ≠ 0) : expand context (compact context result) = result := by
  have identity := lift_compact context result same target
  have position := compact_position target
  simpa only [lift, position, positive, ↓reduceIte] using identity

theorem modelTokens_compact (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (tokens : List ShellToken) (contextValid : ValidContext text context)
    (scanValid : ValidScan text context scan) (positive : scan.position ≠ 0)
    (ordinary : ∀ token ∈ tokens, BodyToken token) :
    modelTokens text context scan tokens = compact context (scanTokens text .direct tokens (expand context scan)) := by
  induction tokens generalizing scan with
  | nil => simp only [modelTokens, scanTokens, List.foldl_nil, compact_expand context scan scanValid.2.1,
      positive, ↓reduceIte]
  | cons token tokens ih =>
      change modelTokens text context (modelToken text context scan token) tokens =
        compact context (scanTokens text .direct tokens (scanToken text (expand context scan) token))
      rw [modelToken_compact text valid context scan token contextValid scanValid (ordinary _ (by simp))]
      let next := scanToken text (expand context scan) token
      have nextValid : Silver.Sequence.ValidScan text next := model_scanToken_valid text valid _ token
        (expand_valid text context scan contextValid scanValid)
      by_cases zero : next.state.position = 0
      · have compactZero : compact context next = invalid := by simp [compact, zero]
        rw [compactZero, modelTokens_invalid]
        have finalZero := scanTokens_zero text .direct tokens next zero
        change invalid = compact context (scanTokens text .direct tokens next)
        simp [compact, finalZero]
      · have same : contextOf next = context := context_same
          (step_body_context (bodyToken_shape (ordinary _ (by simp))) zero)
        have target : next.state.target ≤ context.names.length := by
          have namesSame := congrArg (fun c : Context => c.names.length) same
          exact namesSame ▸ nextValid.2.2.2.1
        have compactValid := compact_valid text context next nextValid
        have compactPositive : (compact context next).position ≠ 0 := by rw [compact_position target]; exact zero
        have expanded := expand_compact_success same target zero
        have remaining := ih (compact context next) compactValid compactPositive
          (fun t member => ordinary t (by simp [member]))
        simpa only [expanded] using remaining

theorem modelBasic_lift (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
    lift context (modelBasic text context scan) =
      if (basicStatementAt text (expand context scan)).state.position = 0 then invalidScan
      else basicStatementAt text (expand context scan) := by
  unfold modelBasic
  by_cases zero : (basicStatementAt text (expand context scan)).state.position = 0
  · simp [compact, zero, lift, invalid]
  · have same := context_same (basic_context zero)
    have resultValid := model_basicStatementAt_valid text valid _
      (expand_valid text context scan contextValid scanValid)
    have target : (basicStatementAt text (expand context scan)).state.target ≤ context.names.length := by
      have namesSame := congrArg (fun c : Context => c.names.length) same
      exact namesSame ▸ resultValid.2.2.2.1
    exact lift_compact context _ same target

theorem compact_position_of_context {text : Source} {context : Context} {result : ScanResult}
    (valid : Silver.Sequence.ValidScan text result)
    (same : result.state.position ≠ 0 → contextOf result = context) :
    (compact context result).position = result.state.position := by
  by_cases zero : result.state.position = 0
  · simp [compact, zero, invalid]
  · apply compact_position
    have namesSame := congrArg (fun c : Context => c.names.length) (same zero)
    exact namesSame ▸ valid.2.2.2.1

@[simp] theorem compact_invalidScan (context : Context) : compact context invalidScan = invalid := rfl

end Silver.Sequence.Native
