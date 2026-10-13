module

public import Silver.ComposeModelRanges
public import Silver.SequenceAdmission

@[expose] public section

/-! Concrete sequence scanners preserve the existing machine-state domain.
These proofs use the concrete helper model and do not assume source equations. -/

namespace Silver.Sequence
open Compose

def ValidScan (text : Source) (scan : ScanResult) : Prop :=
  Expressions.ValidState text scan.state

theorem model_invalid_scan_valid (text : Source) : ValidScan text invalidScan :=
  Expressions.model_invalid_state_valid text

theorem model_scanToken_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (token : ShellToken) (scanValid : ValidScan text scan) :
    ValidScan text (scanToken text scan token) :=
  Expressions.model_step_valid text valid .direct token scan.state scanValid

theorem model_scanTokens_valid (text : Source) (valid : Expressions.ValidText text)
    (form : Compose.Form) (tokens : List ShellToken) (scan : ScanResult)
    (scanValid : ValidScan text scan) : ValidScan text (scanTokens text form tokens scan) := by
  induction tokens generalizing scan with
  | nil => exact scanValid
  | cons token tokens ih =>
      change ValidScan text (scanTokens text form tokens
        {scan with state := step text form token scan.state})
      exact ih _ (Expressions.model_step_valid text valid form token scan.state scanValid)

theorem model_basicRaw_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (basicRaw text scan) :=
  model_scanTokens_valid text valid .direct (basicKind text scan).tokens scan scanValid

theorem model_basicStatementAt_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (basicStatementAt text scan) := by
  unfold basicStatementAt
  split
  · exact model_invalid_scan_valid text
  · split
    · exact model_invalid_scan_valid text
    · exact model_basicRaw_valid text valid scan scanValid

theorem model_tail_valid (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (preserves : ∀ scan, ValidScan text scan → ValidScan text (read scan))
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (tail text read stop scan) := by
  rw [tail]
  split
  · exact model_invalid_scan_valid text
  · split
    · exact scanValid
    · split
      · exact model_invalid_scan_valid text
      · split
        · exact model_tail_valid text read stop preserves (read scan) (preserves scan scanValid)
        · exact model_invalid_scan_valid text
termination_by text.length + 1 - scan.state.position

theorem model_basicTail_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : ShellToken) (scanValid : ValidScan text scan) :
    ValidScan text (basicTail text scan stop) :=
  model_tail_valid text (basicStatementAt text) stop
    (model_basicStatementAt_valid text valid) scan scanValid

theorem model_readBasicStatements_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : ShellToken) (scanValid : ValidScan text scan) :
    ValidScan text (readBasicStatements text scan stop) :=
  model_basicTail_valid text valid (basicStatementAt text scan) stop
    (model_basicStatementAt_valid text valid scan scanValid)

theorem model_conditionalRaw_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (conditionalRaw text scan) := by
  unfold conditionalRaw
  apply model_scanTokens_valid text valid
  apply model_readBasicStatements_valid text valid
  apply model_scanToken_valid text valid
  apply model_readBasicStatements_valid text valid
  exact model_scanTokens_valid text valid .direct equalityTokens scan scanValid

theorem model_conditionalAt_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (conditionalAt text scan) := by
  unfold conditionalAt
  split
  · exact model_invalid_scan_valid text
  · exact model_conditionalRaw_valid text valid scan scanValid

theorem model_statementAt_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (statementAt text scan) := by
  unfold statementAt
  split
  · exact model_conditionalAt_valid text valid scan scanValid
  · exact model_basicStatementAt_valid text valid scan scanValid

theorem model_statementsTail_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : ShellToken) (scanValid : ValidScan text scan) :
    ValidScan text (statementsTail text scan stop) :=
  model_tail_valid text (statementAt text) stop
    (model_statementAt_valid text valid) scan scanValid

theorem model_readStatements_valid (text : Source) (valid : Expressions.ValidText text)
    (scan : ScanResult) (stop : ShellToken) (scanValid : ValidScan text scan) :
    ValidScan text (readStatements text scan stop) :=
  model_statementsTail_valid text valid (statementAt text scan) stop
    (model_statementAt_valid text valid scan scanValid)

theorem model_scanStep_valid (text : Source) (valid : Expressions.ValidText text)
    (form : Form) (token : Token) (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (scanStep text form token scan) := by
  cases token with
  | helper token =>
      exact Expressions.model_step_valid text valid form.helper token scan.state scanValid
  | statements => exact model_readStatements_valid text valid scan form.stop scanValid

theorem model_scanSuffix_valid (text : Source) (valid : Expressions.ValidText text)
    (form : Form) (tokens : List Token) (scan : ScanResult) (scanValid : ValidScan text scan) :
    ValidScan text (scanSuffix text form tokens scan) := by
  induction tokens generalizing scan with
  | nil =>
      unfold scanSuffix
      split
      · exact scanValid
      · exact model_invalid_scan_valid text
  | cons token tokens ih =>
      unfold scanSuffix
      split
      · exact model_invalid_scan_valid text
      · exact ih _ (model_scanStep_valid text valid form token scan scanValid)

end Silver.Sequence
