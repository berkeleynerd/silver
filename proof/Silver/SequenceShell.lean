module

public import Silver.SequenceLists
public import Silver.SequenceTokens

@[expose] public section

namespace Silver.Sequence
open Compose

def prefixScan (source : Source) (form : Form) : ScanResult :=
  scanTokens source form.helper form.prefix initialScan

def bodyScan (source : Source) (form : Form) : ScanResult :=
  readStatements source (prefixScan source form) form.stop

def finalScan (source : Source) (form : Form) : ScanResult :=
  scanTokens source form.helper form.footer (bodyScan source form)

def SourceDomain (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧ source.all allowedCharacter = true ∧
    withinWorkBudget source = true

theorem scanSuffix_zero (text : Source) (form : Form) (tokens : List Token)
    (scan : ScanResult) (zero : scan.state.position = 0) :
    scanSuffix text form tokens scan = invalidScan := by
  cases tokens <;> simp [scanSuffix, zero]

theorem scanSuffix_helpers (text : Source) (form : Form) (tokens : List ShellToken)
    (rest : List Token) (scan : ScanResult) :
    scanSuffix text form (tokens.map Token.helper ++ rest) scan =
      scanSuffix text form rest (scanTokens text form.helper tokens scan) := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih =>
      by_cases zero : scan.state.position = 0
      · rw [scanSuffix_zero text form _ scan zero,
          scanSuffix_zero text form rest _ (scanTokens_zero text form.helper _ scan zero)]
      · simp only [List.map_cons, List.cons_append, scanSuffix, zero, ↓reduceIte, scanStep]
        exact ih _

theorem formResult_success {source : Source} {form : Form}
    (accepted : (formResult source form).state.position ≠ 0) :
    SourceDomain source ∧
      (prefixScan source form).state.position ≠ 0 ∧
      (finalScan source form).state.position ≠ 0 ∧
      Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1 ∧
      formResult source form = finalScan source form := by
  have domain : SourceDomain source := by
    have guard : (decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
        source.all allowedCharacter && withinWorkBudget source) = true := by
      by_cases good : (decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
          source.all allowedCharacter && withinWorkBudget source) = true
      · exact good
      · rw [formResult, ite_eq_right good] at accepted
        exact False.elim (accepted rfl)
    simp only [Bool.and_eq_true, decide_eq_true_eq] at guard
    exact ⟨guard.1.1.1, guard.1.1.2, guard.1.2, guard.2⟩
  have stage : formResult source form =
      scanSuffix source form (.statements :: form.footer.map Token.helper) (prefixScan source form) := by
    simp only [formResult, domain.1, domain.2.1, domain.2.2.1, domain.2.2.2,
      and_self, decide_true, Bool.and_self, ↓reduceIte, Form.tokens, List.append_assoc,
      List.singleton_append, scanSuffix_helpers, prefixScan]
  have prefixPositive : (prefixScan source form).state.position ≠ 0 := by
    intro zero
    rw [stage, scanSuffix_zero _ _ _ _ zero] at accepted
    exact accepted rfl
  have final : formResult source form =
      if (finalScan source form).state.position ≠ 0 ∧
          Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1
      then finalScan source form else invalidScan := by
    rw [stage, scanSuffix, ite_eq_right prefixPositive]
    change scanSuffix source form (form.footer.map Token.helper) (bodyScan source form) = _
    rw [← List.append_nil (form.footer.map Token.helper), scanSuffix_helpers, scanSuffix]
    rfl
  have good : (finalScan source form).state.position ≠ 0 ∧
      Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1 := by
    by_cases good : (finalScan source form).state.position ≠ 0 ∧
        Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1
    · exact good
    · rw [final, ite_eq_right good] at accepted
      exact False.elim (accepted rfl)
  exact ⟨domain, prefixPositive, good.1, good.2, by rw [final, ite_eq_left good]⟩

theorem formResult_complete {source : Source} {form : Form}
    (domain : SourceDomain source)
    (prefixPositive : (prefixScan source form).state.position ≠ 0)
    (finalPositive : (finalScan source form).state.position ≠ 0)
    (finished : Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1) :
    formResult source form = finalScan source form := by
  unfold formResult
  simp only [domain.1, domain.2.1, domain.2.2.1, domain.2.2.2,
    and_self, decide_true, Bool.and_self, ↓reduceIte, Form.tokens, List.append_assoc,
    List.singleton_append, scanSuffix_helpers]
  change scanSuffix source form (.statements :: form.footer.map Token.helper) (prefixScan source form) = _
  rw [scanSuffix, ite_eq_right prefixPositive]
  change scanSuffix source form (form.footer.map Token.helper) (bodyScan source form) = _
  rw [← List.append_nil (form.footer.map Token.helper), scanSuffix_helpers, scanSuffix]
  exact ite_eq_left ⟨finalPositive, finished⟩

end Silver.Sequence
