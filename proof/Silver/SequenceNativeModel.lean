module

public import Silver.SequenceNativeEquations
public import Silver.SequenceModelRanges

@[expose] public section

/-! A concrete scalar scanner inhabits the native source equations and range
contracts independently of correspondence. Extra measure guards totalize the
definitions outside the legal cursor domain; the equations below remove them
on that domain. The witness assumes no full-scanner semantic equality. -/

namespace Silver.Sequence.Native
open Compose

set_option maxHeartbeats 2000000
set_option maxRecDepth 10000
set_option backward.dsimp.instances true

def modelPrimitives : Primitives where
  take := fun text position token => fixedAfter text position
    (Compose.Expressions.spelling token) (Compose.Expressions.isWord token)
  token := scanToken
  basic := basicStatementAt

def modelToken (text : Source) (context : Context) (scan : Scan) (token : ShellToken) : Scan :=
  tokenEquation modelPrimitives text context scan token

def modelBasic (text : Source) (context : Context) (scan : Scan) : Scan :=
  compact context (basicStatementAt text (expand context scan))

def modelTokens (text : Source) (context : Context) (scan : Scan) (values : List ShellToken) : Scan :=
  values.foldl (fun current token => modelToken text context current token) scan

def modelStop (text : Source) (position : Nat) (stop : Stop) : Bool :=
  stopBody modelPrimitives text position stop

def remaining (text : Source) (scan : Scan) : Nat := text.length + 1 - scan.position

mutual
  def modelStatement (text : Source) (context : Context) (scan : Scan) : Scan :=
    if scan.position = 0 then invalid
    else if tokenAfter text scan.position (.word "if") ≠ 0 then modelConditional text context scan
    else modelBasic text context scan
  termination_by (remaining text scan, 2)
  decreasing_by
    all_goals first
      | exact Prod.Lex.left _ _ _yesAdvance
      | exact Prod.Lex.left _ _ _advance
      | exact Prod.Lex.right _ (by decide)

  def modelConditional (text : Source) (context : Context) (scan : Scan) : Scan :=
    let comparison := modelTokens text context scan equalityTokens
    if comparison.position ≤ scan.position then invalid else
    if _advance : remaining text comparison < remaining text scan then
      let yes := modelRead text context comparison .arm
      if yes.position ≤ scan.position then invalid else
      if _yesAdvance : remaining text yes < remaining text scan then
        let final := modelTokens text context (modelAlternative text context yes) endIfTokens
        if final.position ≤ scan.position then invalid else final
      else invalid
    else invalid
  termination_by (remaining text scan, 1)
  decreasing_by
    all_goals first
      | exact Prod.Lex.left _ _ _yesAdvance
      | exact Prod.Lex.left _ _ _advance
      | exact Prod.Lex.right _ (by decide)

  def modelAlternative (text : Source) (context : Context) (scan : Scan) : Scan :=
    if scan.position = 0 then invalid
    else if tokenAfter text scan.position (.word "elsif") ≠ 0 then
      let comparison := modelTokens text context scan elsifTokens
      if comparison.position ≤ scan.position then invalid else
      if _advance : remaining text comparison < remaining text scan then
        let yes := modelRead text context comparison .arm
        if yes.position ≤ scan.position then invalid else
        if _yesAdvance : remaining text yes < remaining text scan then modelAlternative text context yes
        else invalid
      else invalid
    else if tokenAfter text scan.position (.word "else") ≠ 0 then
      let next := modelToken text context scan (.word "else")
      if next.position ≤ scan.position then invalid else
      if _advance : remaining text next < remaining text scan then modelRead text context next .endOnly
      else invalid
    else if tokenAfter text scan.position (.word "end") ≠ 0 then scan else invalid
  termination_by (remaining text scan, 1)
  decreasing_by
    all_goals first
      | exact Prod.Lex.left _ _ _yesAdvance
      | exact Prod.Lex.left _ _ _advance
      | exact Prod.Lex.right _ (by decide)

  def modelTail (text : Source) (context : Context) (scan : Scan) (stop : Stop) : Scan :=
    if scan.position = 0 then invalid else
    if modelStop text scan.position stop then scan else
    let next := modelStatement text context scan
    if next.position ≤ scan.position then invalid else
    if _advance : remaining text next < remaining text scan then modelTail text context next stop
    else invalid
  termination_by (remaining text scan, 3)
  decreasing_by
    all_goals first
      | exact Prod.Lex.left _ _ _yesAdvance
      | exact Prod.Lex.left _ _ _advance
      | exact Prod.Lex.right _ (by decide)

  def modelRead (text : Source) (context : Context) (scan : Scan) (stop : Stop) : Scan :=
    let next := modelStatement text context scan
    if next.position ≤ scan.position then invalid else
    if _advance : remaining text next < remaining text scan then modelTail text context next stop
    else invalid
  termination_by (remaining text scan, 3)
  decreasing_by
    all_goals first
      | exact Prod.Lex.left _ _ _yesAdvance
      | exact Prod.Lex.left _ _ _advance
      | exact Prod.Lex.right _ (by decide)
end

def modelCalls : Calls where
  token := modelToken
  basic := modelBasic
  atStop := modelStop
  statement := modelStatement
  conditional := modelConditional
  alternative := modelAlternative
  tail := modelTail
  read := modelRead

theorem model_tokens (text : Source) (context : Context) (scan : Scan) (values : List ShellToken) :
    tokens modelCalls text context scan values = modelTokens text context scan values := rfl

theorem model_token_ranges (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (token : ShellToken) (contextValid : ValidContext text context)
    (scanValid : ValidScan text context scan) :
    ValidScan text context (modelToken text context scan token) ∧
      ((modelToken text context scan token).position = 0 ∨ scan.position < (modelToken text context scan token).position) := by
  have bounded := compact_valid text context _
    (model_scanToken_valid text valid _ token (expand_valid text context scan contextValid scanValid))
  unfold modelToken tokenEquation
  try dsimp +instances only
  split
  · exact ⟨invalid_valid text context, Or.inl rfl⟩
  · exact ⟨bounded, Or.inr (by omega)⟩

theorem model_basic_ranges (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
    ValidScan text context (modelBasic text context scan) ∧
      ((modelBasic text context scan).position = 0 ∨ scan.position < (modelBasic text context scan).position) := by
  refine ⟨compact_valid text context _
    (model_basicStatementAt_valid text valid _ (expand_valid text context scan contextValid scanValid)), ?_⟩
  unfold modelBasic compact
  split
  · exact Or.inl rfl
  · rename_i accepted
    have positive : (basicStatementAt text (expand context scan)).state.position ≠ 0 :=
      fun zero => accepted (Or.inl zero)
    exact Or.inr (basic_progress positive)

theorem model_tokens_valid (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (values : List ShellToken) (contextValid : ValidContext text context)
    (scanValid : ValidScan text context scan) :
    ValidScan text context (modelTokens text context scan values) := by
  induction values generalizing scan with
  | nil => exact scanValid
  | cons token values ih =>
      exact ih (modelToken text context scan token) (model_token_ranges text valid context scan token contextValid scanValid).1

mutual
  theorem model_statement_ranges (text : Source) (valid : ValidText text) (context : Context)
      (scan : Scan) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
      ValidScan text context (modelStatement text context scan) ∧
        ((modelStatement text context scan).position = 0 ∨ scan.position < (modelStatement text context scan).position) := by
    rw [modelStatement]
    split
    · exact ⟨invalid_valid text context, Or.inl rfl⟩
    · split
      · exact model_conditional_ranges text valid context scan contextValid scanValid
      · exact model_basic_ranges text valid context scan contextValid scanValid
  termination_by (remaining text scan, 2)
  decreasing_by exact Prod.Lex.right _ (by decide)

  theorem model_conditional_ranges (text : Source) (valid : ValidText text) (context : Context)
      (scan : Scan) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
      ValidScan text context (modelConditional text context scan) ∧
        ((modelConditional text context scan).position = 0 ∨ scan.position < (modelConditional text context scan).position) := by
    rw [modelConditional]
    try dsimp +instances only
    split
    · exact ⟨invalid_valid text context, Or.inl rfl⟩
    · split
      · rename_i comparisonAdvance
        have comparisonValid := model_tokens_valid text valid context scan equalityTokens contextValid scanValid
        have yesValid := (model_read_ranges text valid context _ .arm contextValid comparisonValid).1
        split
        · exact ⟨invalid_valid text context, Or.inl rfl⟩
        · split
          · rename_i yesAdvance
            have tailValid := (model_alternative_ranges text valid context _ contextValid yesValid).1
            have finalValid := model_tokens_valid text valid context _ endIfTokens contextValid tailValid
            split
            · exact ⟨invalid_valid text context, Or.inl rfl⟩
            · exact ⟨finalValid, Or.inr (by omega)⟩
          · exact ⟨invalid_valid text context, Or.inl rfl⟩
      · exact ⟨invalid_valid text context, Or.inl rfl⟩
  termination_by (remaining text scan, 1)
  decreasing_by
    · exact Prod.Lex.left _ _ (by assumption)
    · exact Prod.Lex.left _ _ (by assumption)

  theorem model_alternative_ranges (text : Source) (valid : ValidText text) (context : Context)
      (scan : Scan) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
      ValidScan text context (modelAlternative text context scan) ∧
        ((modelAlternative text context scan).position = 0 ∨ scan.position ≤ (modelAlternative text context scan).position) := by
    rw [modelAlternative]
    try dsimp +instances only
    split
    · exact ⟨invalid_valid text context, Or.inl rfl⟩
    · split
      · split
        · exact ⟨invalid_valid text context, Or.inl rfl⟩
        · split
          · rename_i comparisonAdvance
            have comparisonValid := model_tokens_valid text valid context scan elsifTokens contextValid scanValid
            have yesValid := (model_read_ranges text valid context _ .arm contextValid comparisonValid).1
            split
            · exact ⟨invalid_valid text context, Or.inl rfl⟩
            · split
              · rename_i yesAdvance
                have result := model_alternative_ranges text valid context _ contextValid yesValid
                refine ⟨result.1, ?_⟩
                rcases result.2 with zero | after
                · exact Or.inl zero
                · exact Or.inr (by omega)
              · exact ⟨invalid_valid text context, Or.inl rfl⟩
          · exact ⟨invalid_valid text context, Or.inl rfl⟩
      · split
        · split
          · exact ⟨invalid_valid text context, Or.inl rfl⟩
          · split
            · rename_i nextAdvance
              have nextValid := (model_token_ranges text valid context scan (.word "else") contextValid scanValid).1
              have result := model_read_ranges text valid context _ .endOnly contextValid nextValid
              refine ⟨result.1, ?_⟩
              rcases result.2 with zero | after
              · exact Or.inl zero
              · exact Or.inr (by omega)
            · exact ⟨invalid_valid text context, Or.inl rfl⟩
        · split
          · exact ⟨scanValid, Or.inr (Nat.le_refl _)⟩
          · exact ⟨invalid_valid text context, Or.inl rfl⟩
  termination_by (remaining text scan, 1)
  decreasing_by
    · exact Prod.Lex.left _ _ (by assumption)
    · exact Prod.Lex.left _ _ (by assumption)
    · exact Prod.Lex.left _ _ (by assumption)

  theorem model_tail_ranges (text : Source) (valid : ValidText text) (context : Context)
      (scan : Scan) (stop : Stop) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
      ValidScan text context (modelTail text context scan stop) ∧
        ((modelTail text context scan stop).position = 0 ∨ scan.position ≤ (modelTail text context scan stop).position) := by
    rw [modelTail]
    split
    · exact ⟨invalid_valid text context, Or.inl rfl⟩
    · split
      · exact ⟨scanValid, Or.inr (Nat.le_refl _)⟩
      · try dsimp +instances only
        split
        · exact ⟨invalid_valid text context, Or.inl rfl⟩
        · split
          · rename_i nextAdvance
            have nextValid := (model_statement_ranges text valid context scan contextValid scanValid).1
            have result := model_tail_ranges text valid context _ stop contextValid nextValid
            refine ⟨result.1, ?_⟩
            rcases result.2 with zero | after
            · exact Or.inl zero
            · exact Or.inr (by omega)
          · exact ⟨invalid_valid text context, Or.inl rfl⟩
  termination_by (remaining text scan, 3)
  decreasing_by
    · exact Prod.Lex.right _ (by decide)
    · exact Prod.Lex.left _ _ (by assumption)

  theorem model_read_ranges (text : Source) (valid : ValidText text) (context : Context)
      (scan : Scan) (stop : Stop) (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
      ValidScan text context (modelRead text context scan stop) ∧
        ((modelRead text context scan stop).position = 0 ∨ scan.position < (modelRead text context scan stop).position) := by
    rw [modelRead]
    try dsimp +instances only
    split
    · exact ⟨invalid_valid text context, Or.inl rfl⟩
    · split
      · rename_i nextAdvance
        have nextValid := (model_statement_ranges text valid context scan contextValid scanValid).1
        have result := model_tail_ranges text valid context _ stop contextValid nextValid
        refine ⟨result.1, ?_⟩
        rcases result.2 with zero | after
        · exact Or.inl zero
        · exact Or.inr (by omega)
      · exact ⟨invalid_valid text context, Or.inl rfl⟩
  termination_by (remaining text scan, 3)
  decreasing_by
    · exact Prod.Lex.right _ (by decide)
    · exact Prod.Lex.left _ _ (by assumption)
end

theorem model_ranges : Ranges modelCalls where
  token text valid context scan token cv sv _ := model_token_ranges text valid context scan token cv sv
  basic := model_basic_ranges
  statement := model_statement_ranges
  conditional := model_conditional_ranges
  alternative := model_alternative_ranges
  tail := model_tail_ranges
  read := model_read_ranges

theorem remaining_decreases {text : Source} {before after : Scan}
    (bounded : after.position ≤ text.length + 1) (advance : before.position < after.position) :
    remaining text after < remaining text before := by
  simp +instances only [remaining]
  omega

theorem model_conditional_equation (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    modelConditional text context scan = conditionalEquation modelCalls text context scan := by
  have comparisonValid := model_tokens_valid text valid context scan equalityTokens cv sv
  have yesValid := (model_read_ranges text valid context _ .arm cv comparisonValid).1
  rw [modelConditional]
  unfold conditionalEquation
  simp only [model_tokens]
  dsimp only [modelCalls]
  by_cases first : (modelTokens text context scan equalityTokens).position ≤ scan.position
  · simp +instances [first, ↓reduceIte]
  · have advance := remaining_decreases comparisonValid.1 (Nat.lt_of_not_ge first)
    simp +instances [first, advance, ↓reduceIte]
    by_cases second : (modelRead text context (modelTokens text context scan equalityTokens) .arm).position ≤ scan.position
    · simp +instances [second, ↓reduceIte]
    · have yesAdvance := remaining_decreases yesValid.1 (Nat.lt_of_not_ge second)
      simp +instances [second, yesAdvance, ↓reduceIte]
      rfl

theorem model_alternative_equation (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    modelAlternative text context scan = alternativeEquation modelPrimitives modelCalls text context scan := by
  have comparisonValid := model_tokens_valid text valid context scan elsifTokens cv sv
  have yesValid := (model_read_ranges text valid context _ .arm cv comparisonValid).1
  have tokenValid := (model_token_ranges text valid context scan (.word "else") cv sv).1
  rw [modelAlternative]
  unfold alternativeEquation
  simp only [model_tokens]
  dsimp only [modelCalls, modelPrimitives, ShellToken.word, tokenAfter,
    Compose.Expressions.spelling, Compose.Expressions.isWord]
  by_cases zero : scan.position = 0
  · simp +instances [zero, ↓reduceIte]
  · simp +instances [zero, ↓reduceIte]
    by_cases elsifFound : fixedAfter text scan.position "elsif" true ≠ 0
    · simp +instances [elsifFound, ↓reduceIte]
      by_cases first : (modelTokens text context scan elsifTokens).position ≤ scan.position
      · simp +instances [first, ↓reduceIte]
      · have advance := remaining_decreases comparisonValid.1 (Nat.lt_of_not_ge first)
        simp +instances [first, advance, ↓reduceIte]
        by_cases second : (modelRead text context (modelTokens text context scan elsifTokens) .arm).position ≤ scan.position
        · simp +instances [second, ↓reduceIte]
        · have yesAdvance := remaining_decreases yesValid.1 (Nat.lt_of_not_ge second)
          simp +instances [second, yesAdvance, ↓reduceIte]
    · have elsifZero : fixedAfter text scan.position "elsif" true = 0 := by omega
      simp +instances [elsifZero, ↓reduceIte]
      by_cases elseFound : fixedAfter text scan.position "else" true ≠ 0
      · simp +instances [elseFound, ↓reduceIte]
        by_cases first : (modelToken text context scan (.word "else")).position ≤ scan.position
        · dsimp only [ShellToken.word] at first
          simp +instances [first, ↓reduceIte]
        · have advance := remaining_decreases tokenValid.1 (Nat.lt_of_not_ge first)
          dsimp only [ShellToken.word] at first advance
          simp +instances [first, advance, ↓reduceIte]
      · have elseZero : fixedAfter text scan.position "else" true = 0 := by omega
        simp +instances [elseZero, ↓reduceIte]

theorem model_tail_equation (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (stop : Stop) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    modelTail text context scan stop = tailBody.eval modelPrimitives modelCalls {text, context, scan, stop} := by
  have nextValid := (model_statement_ranges text valid context scan cv sv).1
  rw [modelTail]
  dsimp +instances [tailBody, Expr.eval, Condition.eval, StopRef.eval, modelCalls]
  by_cases zero : scan.position = 0
  · simp +instances [zero, ↓reduceIte]
  · simp +instances [zero, ↓reduceIte]
    by_cases stopped : modelStop text scan.position stop = true
    · simp +instances [stopped, ↓reduceIte]
    · simp +instances [stopped, ↓reduceIte]
      by_cases first : (modelStatement text context scan).position ≤ scan.position
      · simp +instances [first, ↓reduceIte]
      · have advance := remaining_decreases nextValid.1 (Nat.lt_of_not_ge first)
        simp +instances [first, advance, ↓reduceIte]

theorem model_read_equation (text : Source) (valid : ValidText text) (context : Context)
    (scan : Scan) (stop : Stop) (cv : ValidContext text context) (sv : ValidScan text context scan) :
    modelRead text context scan stop = readBody.eval modelPrimitives modelCalls {text, context, scan, stop} := by
  have next := model_statement_ranges text valid context scan cv sv
  rw [modelRead]
  dsimp +instances [readBody, Expr.eval, Condition.eval, StopRef.eval, modelCalls]
  by_cases zero : (modelStatement text context scan).position = 0
  · have first : (modelStatement text context scan).position ≤ scan.position := by omega
    simp +instances [zero, ↓reduceIte]
  · have forward : scan.position < (modelStatement text context scan).position := next.2.resolve_left zero
    have first : ¬(modelStatement text context scan).position ≤ scan.position := by omega
    have advance := remaining_decreases next.1.1 forward
    simp +instances [first, zero, advance, ↓reduceIte]

theorem model_equations : Equations modelPrimitives modelCalls where
  ranges := model_ranges
  token text _ context scan token _ _ _ := by rw [token_eval]; rfl
  basic _ _ _ _ _ _ := rfl
  stop _ _ _ _ _ := rfl
  statement text _ context scan _ _ := by
    simp +instances [modelCalls, modelStatement, statementBody, Expr.eval, Condition.eval,
      TokenRef.eval, modelPrimitives, ShellToken.word, tokenAfter,
      Compose.Expressions.spelling, Compose.Expressions.isWord]
    by_cases zero : scan.position = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte, decide_false, Bool.false_eq_true]
      by_cases found : fixedAfter text scan.position "if" true = 0 <;> simp [found]
  conditional text valid context scan cv sv := by
    rw [conditional_eval]
    exact model_conditional_equation text valid context scan cv sv
  alternative text valid context scan cv sv := by
    rw [alternative_eval]
    exact model_alternative_equation text valid context scan cv sv
  tail text valid context scan stop cv sv := by
    rw [tailImplementation_eval]
    exact model_tail_equation text valid context scan stop cv sv
  read text valid context scan stop cv sv := by
    rw [readImplementation_eval]
    exact model_read_equation text valid context scan stop cv sv

end Silver.Sequence.Native
