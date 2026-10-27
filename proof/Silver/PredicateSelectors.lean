module

public import Silver.PredicateFlags

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

mutual
  def Flag.statement (flag : Flag) : Statement → Bool
    | .simple item => flag.simple item
    | .scalarAssign _ | .arrayAssign _ => flag == .assignment
    | .reject => false
    | .choice _ yes no => flag.statements yes || flag.statements no
    | .forLoop _ _ _ _ body => flag.statements body
  termination_by item => sizeOf item
  def Flag.statements (flag : Flag) : List Statement → Bool
    | [] => false
    | item :: rest => flag.statement item || flag.statements rest
  termination_by items => sizeOf items
end

mutual
  theorem source_lower_flags (flag : Flag) (item : SourceStatement) :
      flag.statement item.lower = flag.source item := by
    cases item with
    | simple item => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | scalarAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | arrayAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | reject => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | choice condition yes tail =>
        simp only [SourceStatement.lower, Flag.statement, Flag.source,
          statements_lower_flags flag yes, alternative_lower_flags flag tail]
    | forLoop index reverse lower upper body =>
        simp only [SourceStatement.lower, Flag.statement, Flag.source, statements_lower_flags flag body]
  termination_by sizeOf item
  theorem alternative_lower_flags (flag : Flag) (tail : SourceAlternative) :
      flag.statements tail.lower = flag.alternative tail := by
    cases tail with
    | absent => simp only [SourceAlternative.lower, Flag.statements, Flag.alternative]
    | otherwise items => simpa only [SourceAlternative.lower, Flag.alternative] using statements_lower_flags flag items
    | elsif condition yes tail =>
        simp only [SourceAlternative.lower, Flag.statements, Flag.statement, Flag.alternative,
          statements_lower_flags flag yes, alternative_lower_flags flag tail, Bool.or_false]
  termination_by sizeOf tail
  theorem statements_lower_flags (flag : Flag) (items : List SourceStatement) :
      flag.statements (lowerStatements items) = flag.sources items := by
    cases items with
    | nil => simp only [lowerStatements, Flag.statements, Flag.sources]
    | cons item rest =>
        simp only [lowerStatements, Flag.statements, Flag.sources,
          source_lower_flags flag item, statements_lower_flags flag rest]
  termination_by sizeOf items
end

theorem decoded_body {form events items scalars constants checks arrays program}
    (decoded : decodePrefix form events items scalars constants checks arrays = some program) :
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
      hasAssignment source = Flag.assignment.statements program.statements ∧
      hasOutput source = Flag.output.statements program.statements := by
  obtain ⟨form, events, items, _, _, domain, _, parsed, _, _, decoded⟩ := meaning
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  have body := decoded_body decoded
  refine ⟨(any_form_flag accepted Form.hasArguments).trans body.2.symm, ?_, ?_⟩
  · rw [hasAssignment, any_form_flag accepted, body.1, statements_lower_flags]
    exact form_flags domain parsed .assignment
  · rw [hasOutput, any_form_flag accepted, body.1, statements_lower_flags]
    exact form_flags domain parsed .output

end Silver.Predicate
