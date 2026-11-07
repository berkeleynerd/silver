module

public import Silver.PredicateFunctionFlags

@[expose] public section

namespace Silver.Predicate
open Compose

/-- The context's imported packages fix the shell independently of clause order
and grouping: exactly the argument shell requires Silver_Arguments. -/
private theorem header_arguments {source : Source} {form : Form}
    {events : List Event} {final : ParserState}
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events final) :
    (Names.readContext source).argumentsWith = form.hasArguments := by
  obtain ⟨tokens, spelling⟩ : ∃ tokens, form.prefix = .contextClauses :: tokens := by
    cases form <;> exact ⟨_, rfl⟩
  rw [spelling] at parsed
  cases parsed with
  | next first _ =>
      have accepted := first.following
      rw [← first.scanned] at accepted
      have contextAccepted : Names.contextAfter source form.helper.hasArguments ≠ 0 := by
        simpa [step, initialState] using accepted
      dsimp only [Names.contextAfter] at contextAccepted
      split at contextAccepted
      · rename_i matched
        simp only [Bool.and_eq_true, beq_iff_eq] at matched
        have required := matched.2
        cases form <;> exact required
      · exact False.elim (contextAccepted rfl)

theorem form_reading_unique {source : Source} {first second : Form}
    {firstEvents secondEvents : List Event} {firstItems secondItems : List SourceStatement}
    (a : FormReading source first firstEvents firstItems)
    (b : FormReading source second secondEvents secondItems) : first = second := by
  have same := (header_arguments a.header).symm.trans (header_arguments b.header)
  cases first <;> cases second <;> simp_all [Form.hasArguments]

theorem accepted_form_unique {source : Source} {first second : Form}
    (a : (formResult source first).state.position ≠ 0)
    (b : (formResult source second).state.position ≠ 0) : first = second := by
  obtain ⟨_, _, _, firstRead⟩ := form_reading_sound a
  obtain ⟨_, _, _, secondRead⟩ := form_reading_sound b
  exact form_reading_unique firstRead secondRead


theorem decoded_body {form events items scalars constants checks arrays booleans booleanChecks functions program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions = some program) :
    program.statements = lowerStatements items ∧ program.hasArguments = form.hasArguments := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded
  all_goals exact ⟨rfl, rfl⟩

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
    hasArguments source = program.hasArguments ∧
      hasAssignment source = program.assignmentFlag ∧
      hasOutput source = Flag.output.statements program.statements := by
  obtain ⟨form, events, items, _, _, _, _, domain, _, parsed, _, _, _, functions, functionTrace, decoded⟩ := meaning
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  have body := decoded_body decoded
  have functionsEq := decoded_functions decoded
  have flags := prefix_function_flags functionTrace
  have absorbs : ((prefixScan source form).assigned || (prefixScan source form).state.assignedInFunctions) =
      (prefixScan source form).assigned := by rw [flags.1, flags.2]; exact Bool.or_self _
  refine ⟨(any_form_flag accepted Form.hasArguments).trans body.2.symm, ?_, ?_⟩
  · rw [hasAssignment, any_form_flag accepted, Program.assignmentFlag, body.1, functionsEq, statements_lower_flags]
    have observed := form_flags domain parsed absorbs .assignment
    simpa only [Flag.scanObserve, flags.1, Bool.or_comm] using observed
  · rw [hasOutput, any_form_flag accepted, body.1, statements_lower_flags]
    have observed := form_flags domain parsed absorbs .output
    simpa only [Flag.scanObserve, prefix_output, Bool.false_or] using observed

end Silver.Predicate
