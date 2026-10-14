module

public import Silver.SequenceModelRanges

@[expose] public section

/-! On the native cursor domain, byte-measure guards are exactly position
progress tests. These equations expose the full scanner without totalizing
guards, for the scalar representation proof. -/

namespace Silver.Sequence
open Compose

set_option backward.dsimp.instances true

theorem remaining_less_iff {text : Source} {before after : ScanResult}
    (bound : after.state.position ≤ text.length + 1) :
    remaining text after < remaining text before ↔ before.state.position < after.state.position := by
  unfold remaining
  omega

def conditionalPositionEquation (text : Source) (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan else
  let comparison := scanTokens text .direct equalityTokens scan
  if comparison.state.position ≤ scan.state.position then invalidScan else
  let yes := readBody text comparison .arm
  if yes.state.position ≤ scan.state.position then invalidScan else
  let final := scanTokens text .direct endIfTokens (alternativeAt text yes)
  if final.state.position ≤ scan.state.position then invalidScan else final

def alternativePositionEquation (text : Source) (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if fixedAfter text scan.state.position "elsif" true ≠ 0 then
    let comparison := scanTokens text .direct elsifTokens scan
    if comparison.state.position ≤ scan.state.position then invalidScan else
    let yes := readBody text comparison .arm
    if yes.state.position ≤ scan.state.position then invalidScan else alternativeAt text yes
  else if fixedAfter text scan.state.position "else" true ≠ 0 then
    let next := scanToken text scan (.word "else")
    if next.state.position ≤ scan.state.position then invalidScan else readBody text next (.token (.word "end"))
  else if fixedAfter text scan.state.position "end" true ≠ 0 then scan else invalidScan

def bodyTailPositionEquation (text : Source) (scan : ScanResult) (stop : BodyStop) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if stopAfter text scan.state.position stop ≠ 0 then scan
  else if (statementAt text scan).state.position ≤ scan.state.position then invalidScan
  else bodyTail text (statementAt text scan) stop

def readBodyPositionEquation (text : Source) (scan : ScanResult) (stop : BodyStop) : ScanResult :=
  if (statementAt text scan).state.position = 0 then invalidScan
  else bodyTail text (statementAt text scan) stop

theorem conditional_position_equation (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    conditionalAt text scan = conditionalPositionEquation text scan := by
  have comparisonValid := model_scanTokens_valid text valid .direct equalityTokens scan scanValid
  have yesValid := model_readBody_valid text valid (scanTokens text .direct equalityTokens scan) .arm comparisonValid
  have first := remaining_less_iff (before := scan) comparisonValid.1
  have second := remaining_less_iff (before := scan) yesValid.1
  rw [conditionalAt]
  dsimp only
  unfold conditionalPositionEquation
  dsimp only
  by_cases zero : scan.state.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte, first, second]
    by_cases stopped : (scanTokens text .direct equalityTokens scan).state.position ≤ scan.state.position
    · simp only [stopped, Nat.not_lt.mpr stopped, ↓reduceIte, ↓reduceDIte]
    · simp only [stopped, Nat.lt_of_not_ge stopped, ↓reduceIte, ↓reduceDIte]
      by_cases stoppedYes : (readBody text (scanTokens text .direct equalityTokens scan) .arm).state.position ≤ scan.state.position
      · simp only [stoppedYes, Nat.not_lt.mpr stoppedYes, ↓reduceIte, ↓reduceDIte]
      · simp only [stoppedYes, Nat.lt_of_not_ge stoppedYes, ↓reduceIte, ↓reduceDIte]

theorem alternative_position_equation (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    alternativeAt text scan = alternativePositionEquation text scan := by
  have comparisonValid := model_scanTokens_valid text valid .direct elsifTokens scan scanValid
  have yesValid := model_readBody_valid text valid (scanTokens text .direct elsifTokens scan) .arm comparisonValid
  have nextValid := model_scanToken_valid text valid scan (.word "else") scanValid
  have first := remaining_less_iff (before := scan) comparisonValid.1
  have second := remaining_less_iff (before := scan) yesValid.1
  have third := remaining_less_iff (before := scan) nextValid.1
  rw [alternativeAt]
  unfold alternativePositionEquation
  dsimp only
  simp only [first, second, third]
  by_cases zero : scan.state.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    split
    · by_cases stopped : (scanTokens text .direct elsifTokens scan).state.position ≤ scan.state.position
      · simp only [stopped, Nat.not_lt.mpr stopped, ↓reduceIte, ↓reduceDIte]
      · simp only [stopped, Nat.lt_of_not_ge stopped, ↓reduceIte, ↓reduceDIte]
        by_cases stoppedYes : (readBody text (scanTokens text .direct elsifTokens scan) .arm).state.position ≤ scan.state.position
        · simp only [stoppedYes, Nat.not_lt.mpr stoppedYes, ↓reduceIte, ↓reduceDIte]
        · simp only [stoppedYes, Nat.lt_of_not_ge stoppedYes, ↓reduceIte, ↓reduceDIte]
    · split
      · by_cases stopped : (scanToken text scan (.word "else")).state.position ≤ scan.state.position
        · simp only [stopped, Nat.not_lt.mpr stopped, ↓reduceIte, ↓reduceDIte]
        · simp only [stopped, Nat.lt_of_not_ge stopped, ↓reduceIte, ↓reduceDIte]
      · rfl

theorem bodyTail_position_equation (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : BodyStop) (scanValid : ValidScan text scan) :
    bodyTail text scan stop = bodyTailPositionEquation text scan stop := by
  have nextValid := model_statementAt_valid text valid scan scanValid
  have advance := remaining_less_iff (before := scan) nextValid.1
  rw [bodyTail]
  unfold bodyTailPositionEquation
  dsimp only
  simp only [advance]
  by_cases zero : scan.state.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    split
    · rfl
    · by_cases failed : (statementAt text scan).state.position = 0
      · simp [failed]
      · have forward := statement_progress failed
        simp only [failed, forward, Nat.not_le.mpr forward, ↓reduceIte, ↓reduceDIte]

theorem readBody_position_equation (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : BodyStop) (scanValid : ValidScan text scan) :
    readBody text scan stop = readBodyPositionEquation text scan stop := by
  have nextValid := model_statementAt_valid text valid scan scanValid
  have advance := remaining_less_iff (before := scan) nextValid.1
  rw [readBody]
  unfold readBodyPositionEquation
  simp only [advance]
  by_cases failed : (statementAt text scan).state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, statement_progress failed, ↓reduceIte, ↓reduceDIte]

theorem bodyTail_progress (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : BodyStop) (scanValid : ValidScan text scan)
    (accepted : (bodyTail text scan stop).state.position ≠ 0) :
    scan.state.position ≤ (bodyTail text scan stop).state.position := by
  rw [bodyTail_position_equation text valid scan stop scanValid] at accepted ⊢
  unfold bodyTailPositionEquation at accepted ⊢
  by_cases zero : scan.state.position = 0
  · simp [zero, invalidScan, invalidState] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases done : stopAfter text scan.state.position stop ≠ 0
    · rw [ite_eq_left done]
      exact Nat.le_refl _
    · rw [ite_eq_right done] at accepted ⊢
      by_cases stopped : (statementAt text scan).state.position ≤ scan.state.position
      · simp [stopped, invalidScan, invalidState] at accepted
      · simp only [stopped, ↓reduceIte] at accepted ⊢
        have nextValid := model_statementAt_valid text valid scan scanValid
        have following := bodyTail_progress text valid (statementAt text scan) stop nextValid accepted
        exact Nat.le_trans (Nat.le_of_lt (Nat.lt_of_not_ge stopped)) following
termination_by remaining text scan
decreasing_by
  apply (remaining_less_iff nextValid.1).mpr
  exact Nat.lt_of_not_ge stopped

theorem readBody_progress (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : BodyStop) (scanValid : ValidScan text scan)
    (accepted : (readBody text scan stop).state.position ≠ 0) :
    scan.state.position < (readBody text scan stop).state.position := by
  rw [readBody_position_equation text valid scan stop scanValid] at accepted ⊢
  unfold readBodyPositionEquation at accepted ⊢
  by_cases failed : (statementAt text scan).state.position = 0
  · simp [failed, invalidScan, invalidState] at accepted
  · simp only [failed, ↓reduceIte] at accepted ⊢
    exact Nat.lt_of_lt_of_le (statement_progress failed)
      (bodyTail_progress text valid (statementAt text scan) stop
        (model_statementAt_valid text valid scan scanValid) accepted)

theorem alternative_progress (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan)
    (accepted : (alternativeAt text scan).state.position ≠ 0) :
    scan.state.position ≤ (alternativeAt text scan).state.position := by
  rw [alternative_position_equation text valid scan scanValid] at accepted ⊢
  unfold alternativePositionEquation at accepted ⊢
  by_cases zero : scan.state.position = 0
  · simp [zero, invalidScan, invalidState] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases hasElsif : fixedAfter text scan.state.position "elsif" true ≠ 0
    · rw [ite_eq_left hasElsif] at accepted ⊢
      by_cases stopped : (scanTokens text .direct elsifTokens scan).state.position ≤ scan.state.position
      · simp [stopped, invalidScan, invalidState] at accepted
      · simp only [stopped, ↓reduceIte] at accepted ⊢
        by_cases stoppedYes : (readBody text (scanTokens text .direct elsifTokens scan) .arm).state.position ≤ scan.state.position
        · simp [stoppedYes, invalidScan, invalidState] at accepted
        · simp only [stoppedYes, ↓reduceIte] at accepted ⊢
          have comparisonValid := model_scanTokens_valid text valid .direct elsifTokens scan scanValid
          have yesValid := model_readBody_valid text valid _ .arm comparisonValid
          have following := alternative_progress text valid _ yesValid accepted
          exact Nat.le_trans (Nat.le_of_lt (Nat.lt_of_not_ge stoppedYes)) following
    · rw [ite_eq_right hasElsif] at accepted ⊢
      by_cases hasElse : fixedAfter text scan.state.position "else" true ≠ 0
      · rw [ite_eq_left hasElse] at accepted ⊢
        by_cases stopped : (scanToken text scan (.word "else")).state.position ≤ scan.state.position
        · simp [stopped, invalidScan, invalidState] at accepted
        · simp only [stopped, ↓reduceIte] at accepted ⊢
          have nextValid := model_scanToken_valid text valid scan (.word "else") scanValid
          have following := readBody_progress text valid _ (.token (.word "end")) nextValid accepted
          exact Nat.le_trans (Nat.le_of_lt (Nat.lt_of_not_ge stopped)) (Nat.le_of_lt following)
      · rw [ite_eq_right hasElse] at accepted ⊢
        by_cases hasEnd : fixedAfter text scan.state.position "end" true ≠ 0
        · rw [ite_eq_left hasEnd]
          exact Nat.le_refl _
        · simp [hasEnd, invalidScan, invalidState] at accepted
termination_by remaining text scan
decreasing_by
  apply (remaining_less_iff yesValid.1).mpr
  exact Nat.lt_of_not_ge stoppedYes

end Silver.Sequence
