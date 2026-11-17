module

public import Silver.PredicateGrammar
public import Silver.PredicateStatementFlags

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

def Flag.scanObserve (flag : Flag) (scan : ScanResult) : Bool :=
  match flag with | .assignment => scan.assigned | .output => scan.output

theorem scanTokens_output (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) : (scanTokens text form tokens scan).output = scan.output := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih => rw [scanTokens]; exact ih _

theorem scanTokens_flags {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, token ≠ ShellToken.declarations)
    (parsed : Sequence.TokensAt text form tokens state events final)
    (assigned output : Bool) (absorbs : (assigned || state.assignedInFunctions) = assigned) (flag : Flag) :
    flag.scanObserve (scanTokens text form tokens ⟨state, assigned, output⟩) =
      flag.scanObserve ⟨state, assigned, output⟩ := by
  induction parsed generalizing assigned with
  | done => rfl
  | @next token tokens state middle final event events head _ ih =>
      have kept := step_functionAssignments_preserved (ordinary token (by simp)) head
      have next := ih (fun token member => ordinary token (by simp [member]))
        assigned (by simpa only [kept] using absorbs)
      cases flag <;> simpa only [scanTokens, head.scanned, kept, absorbs, Flag.scanObserve] using next

theorem prefix_output (text : Source) (form : Form) : (prefixScan text form).output = false :=
  scanTokens_output text form.helper form.prefix initialScan

/-- Native routing flags summarize the written statements, including untaken
arms. They therefore never depend on which runtime path happens to execute. -/
theorem form_flags {text : Source} {form : Form} {events : List Event} {items : List SourceStatement}
    (domain : SourceDomain text) (parsed : FormReading text form events items)
    (absorbs : ((prefixScan text form).assigned || (prefixScan text form).state.assignedInFunctions) =
      (prefixScan text form).assigned) (flag : Flag) :
    flag.scanObserve (formResult text form) = (flag.scanObserve (prefixScan text form) || flag.sources items) := by
  have member : FormMember text form := ⟨domain, events, items, parsed⟩
  have accepted := form_reading_complete member
  rw [(formResult_success accepted).2.2.2.2, finalScan]
  have bodyPositive : (bodyScan text form).state.position ≠ 0 := by
    obtain ⟨_, footer⟩ := parsed.footer
    exact (Sequence.tokens_positive footer).1
  have bodyEq : bodyScan text form = expandBody (prefixScan text form).state (rawBody text form) := by
    unfold bodyScan readStatements at bodyPositive ⊢
    dsimp only at bodyPositive ⊢
    split at bodyPositive
    · exact False.elim (bodyPositive rfl)
    · rename_i good
      exact ite_eq_right good
  obtain ⟨footerEvents, footer⟩ := parsed.footer
  have bodyAssigned := body_flags parsed.statements .assignment
  have bodyAbsorbs : ((bodyScan text form).assigned || (bodyScan text form).state.assignedInFunctions) =
      (bodyScan text form).assigned := by
    rw [bodyEq]
    change ((rawBody text form).assigned || (prefixScan text form).state.assignedInFunctions) =
      (rawBody text form).assigned
    change (rawBody text form).assigned = ((prefixScan text form).assigned || Flag.assignment.sources items) at bodyAssigned
    rw [bodyAssigned]
    rw [Bool.or_right_comm, absorbs]
  have finalFlags := scanTokens_flags (by cases form <;> simp [Form.footer, ShellToken.word, ShellToken.symbol])
    footer (bodyScan text form).assigned (bodyScan text form).output bodyAbsorbs flag
  rw [finalFlags, bodyEq]
  have observed := body_flags parsed.statements flag
  cases flag <;> simpa only [Flag.scanObserve, Flag.observe, bodyOf, expandBody] using observed

end Silver.Predicate
