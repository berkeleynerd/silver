module

public import Silver.SequenceConditions
public import Silver.SequenceFormDisjoint

@[expose] public section

/-! Report routing observes every syntactic branch, including unreachable arms.
The scanner's two flags exactly record assignment/output occurrence in the
decoded statement tree, accumulated from its incoming flags. -/

namespace Silver.Sequence
open Compose

theorem scanTokens_flags (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) :
    (scanTokens text form tokens scan).assigned = scan.assigned ∧
      (scanTokens text form tokens scan).output = scan.output := by
  induction tokens generalizing scan with
  | nil => exact ⟨rfl, rfl⟩
  | cons token tokens ih => exact ih {scan with state := step text form token scan.state}

theorem basic_events_flags {kind events item} (decoded : BasicEvents kind events item) :
    (kind == .assignment) = item.hasAssignment ∧ (kind == .output) = item.hasOutput := by
  cases decoded <;> exact ⟨rfl, rfl⟩

theorem basic_flags {text scan item next} (parsed : BasicAt text scan item next) :
    next.assigned = (scan.assigned || item.hasAssignment) ∧
      next.output = (scan.output || item.hasOutput) := by
  have accepted : (basicStatementAt text scan).state.position ≠ 0 := by
    rw [parsed.scanned]
    exact (basic_positive parsed).2
  have same : next = basicRaw text scan := parsed.scanned.symm.trans (basic_reduction accepted)
  obtain ⟨_, _, decoded⟩ := parsed.reading
  have kinds := basic_events_flags decoded
  have tokens := scanTokens_flags text .direct (basicKind text scan).tokens scan
  rw [same]
  simp only [basicRaw, tokens.1, tokens.2, kinds.1, kinds.2, and_self]

theorem tail_flag {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} (project : ScanResult → Bool) (select : α → Bool)
    (readingFlags : ∀ {scan item next}, Reading scan item next →
      project next = (project scan || select item))
    {scan final : ScanResult} {items : List α}
    (parsed : TailAt text read stop Reading scan items final) :
    project final = (project scan || items.any select) := by
  induction parsed with
  | done => simp
  | next _ _ first _ _ _ ih =>
      rw [ih, readingFlags first]
      simp only [List.any_cons, Bool.or_assoc]

theorem nonempty_flag {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} (project : ScanResult → Bool) (select : α → Bool)
    (readingFlags : ∀ {scan item next}, Reading scan item next →
      project next = (project scan || select item))
    {scan final : ScanResult} {items : List α}
    (parsed : NonemptyAt text read stop Reading scan items final) :
    project final = (project scan || items.any select) := by
  cases parsed with
  | cons first _ following =>
      rw [tail_flag (Reading := Reading) project select readingFlags following, readingFlags first]
      simp only [List.any_cons, Bool.or_assoc]

theorem basicList_flags {text scan stop items final}
    (parsed : BasicListAt text scan stop items final) :
    final.assigned = (scan.assigned || items.any SimpleStatement.hasAssignment) ∧
      final.output = (scan.output || items.any SimpleStatement.hasOutput) :=
  ⟨nonempty_flag (Reading := BasicAt text) ScanResult.assigned SimpleStatement.hasAssignment
    (fun parsed => (basic_flags parsed).1) parsed,
   nonempty_flag (Reading := BasicAt text) ScanResult.output SimpleStatement.hasOutput
    (fun parsed => (basic_flags parsed).2) parsed⟩

theorem conditional_flags {text scan item next} (parsed : ConditionalAt text scan item next) :
    next.assigned = (scan.assigned || item.hasAssignment) ∧
      next.output = (scan.output || item.hasOutput) := by
  cases parsed with
  | choice scanned comparison yes middle no ending =>
      have compFlags := scanTokens_flags text .direct equalityTokens scan
      have yesFlags := basicList_flags yes
      have noFlags := basicList_flags no
      have accepted : (conditionalAt text scan).state.position ≠ 0 := by
        rw [scanned]
        exact (tokens_positive ending).2
      have same : next = scanTokens text .direct endIfTokens (conditionalNo text scan) :=
        scanned.symm.trans (conditional_reduction accepted)
      have endFlags := scanTokens_flags text .direct endIfTokens (conditionalNo text scan)
      rw [same]
      simp only [endFlags.1, endFlags.2, noFlags.1, noFlags.2,
        conditionalNoStart, scanToken, yesFlags.1, yesFlags.2,
        conditionalComparison, compFlags.1, compFlags.2, Statement.hasAssignment,
        Statement.hasOutput, Bool.or_assoc, and_self]

theorem statement_flags {text scan item next} (parsed : StatementAt text scan item next) :
    next.assigned = (scan.assigned || item.hasAssignment) ∧
      next.output = (scan.output || item.hasOutput) := by
  cases parsed with
  | simple _ basic => exact basic_flags basic
  | conditional _ choice => exact conditional_flags choice

theorem statements_flags {text scan stop items final}
    (parsed : StatementsAt text scan stop items final) :
    final.assigned = (scan.assigned || items.any Statement.hasAssignment) ∧
      final.output = (scan.output || items.any Statement.hasOutput) :=
  ⟨nonempty_flag (Reading := StatementAt text) ScanResult.assigned Statement.hasAssignment
    (fun parsed => (statement_flags parsed).1) parsed,
   nonempty_flag (Reading := StatementAt text) ScanResult.output Statement.hasOutput
    (fun parsed => (statement_flags parsed).2) parsed⟩

theorem decoded_body {form : Form} {events : List Event} {items : List Statement} {program : Program}
    (decoded : decodePrefix form events items = some program) :
    program.body.statements = items ∧ program.body.shell.hasArguments = form.hasArguments := by
  unfold decodePrefix at decoded
  split at decoded <;> simp_all only [Option.some.injEq, reduceCtorEq]
  all_goals subst program
  all_goals exact ⟨rfl, rfl⟩

theorem form_reading_flags {source : Source} {form : Form} {events : List Event}
    {items : List Statement} {program : Program} (domain : SourceDomain source)
    (parsed : FormReading source form events items)
    (decoded : decodePrefix form events items = some program) :
    (formResult source form).assigned = program.body.hasAssignment ∧
      (formResult source form).output = program.body.hasOutput := by
  obtain ⟨_, footer⟩ := parsed.footer
  have complete := formResult_complete domain (tokens_positive parsed.header).2
    (tokens_positive footer).2 parsed.finished
  have first := scanTokens_flags source form.helper form.prefix initialScan
  have prefixAssigned : (prefixScan source form).assigned = false := first.1
  have prefixOutput : (prefixScan source form).output = false := first.2
  have body := statements_flags parsed.statements
  have last := scanTokens_flags source form.helper form.footer (bodyScan source form)
  have itemsSame := (decoded_body decoded).1
  rw [complete]
  simp only [Body.hasAssignment, Body.hasOutput, itemsSame, finalScan, last.1, last.2,
    body.1, body.2, prefixAssigned, prefixOutput, Bool.false_or, and_self]

theorem any_form_flag {source : Source} {form : Form}
    (accepted : (formResult source form).state.position ≠ 0) (flag : Form → Bool) :
    (allForms.any fun candidate => formAccepts source candidate && flag candidate) = flag form := by
  apply Bool.eq_iff_iff.mpr
  simp only [List.any_eq_true, Bool.and_eq_true]
  constructor
  · rintro ⟨candidate, _, success, flagged⟩
    have same := accepted_form_unique (of_decide_eq_true success) accepted
    subst candidate
    exact flagged
  · intro flagged
    exact ⟨form, all_forms form, decide_eq_true accepted, flagged⟩

theorem meaning_selectors {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    hasArguments source = program.body.shell.hasArguments ∧
      hasAssignment source = program.body.hasAssignment ∧ hasOutput source = program.body.hasOutput := by
  obtain ⟨form, events, items, domain, _, parsed, decoded⟩ := meaning
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  have flags := form_reading_flags domain parsed decoded
  exact ⟨(any_form_flag accepted Form.hasArguments).trans (decoded_body decoded).2.symm,
    (any_form_flag accepted (fun candidate => (formResult source candidate).assigned)).trans flags.1,
    (any_form_flag accepted (fun candidate => (formResult source candidate).output)).trans flags.2⟩

end Silver.Sequence
