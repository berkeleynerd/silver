module

public import Silver.PredicateHeader
public import Silver.ComposeBooleanRegionTrace

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

/-- The header segment before its single mixed declaration region. -/
def booleanHeaderLead (form : Form) : List ShellToken :=
  [.contextClauses, .word "procedure", .word "main", .word "is", .word "pragma",
    .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";"] ++
    (if form.hasArguments then [.argumentDeclaration] else [])

theorem boolean_header_split (form : Form) :
    form.prefix = booleanHeaderLead form ++ [.declarations, .word "begin"] := by
  cases form <;> rfl

private theorem tokens_split {text form first rest state events final}
    (parsed : Sequence.TokensAt text form (first ++ rest) state events final) :
    ∃ middle leading following,
      Sequence.TokensAt text form first state leading middle ∧
      Sequence.TokensAt text form rest middle following final := by
  induction first generalizing state events with
  | nil => exact ⟨state, [], events, .done (Sequence.tokens_positive parsed).1, parsed⟩
  | cons token tokens ih =>
      cases parsed with
      | next head tail =>
          obtain ⟨middle, leading, following, before, after⟩ := ih tail
          exact ⟨middle, _, following, .next head before, after⟩

private theorem step_boolean_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.booleanNames = state.booleanNames ∧ next.arrayNames = state.arrayNames := by
  have following := parsed.following
  cases token with
  | declarations => exact False.elim (ordinary rfl)
  | argumentDeclaration =>
      obtain ⟨fallback, reading, _⟩ := parsed.payload
      cases reading
      exact ⟨rfl, rfl⟩
  | contextClauses | fixed | literal =>
      rw [← parsed.scanned]
      simp only [step, parsed.positive, ↓reduceIte, and_self]
  | capacity | dynamicReference | assignmentTarget | targetReference | assignmentValue |
      outputExpression | comparisonExpression =>
      rw [← parsed.scanned] at following ⊢
      simp only [step, parsed.positive, ↓reduceIte, capacityAt, dynamicAt, targetAt,
        assignmentAt, outputAt, Compose.comparisonAt] at following ⊢
      split <;> (try split) <;> simp_all [invalidState]

private theorem tokens_boolean_preserved {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, token ≠ ShellToken.declarations)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    final.booleanNames = state.booleanNames ∧ final.arrayNames = state.arrayNames := by
  induction parsed with
  | done => exact ⟨rfl, rfl⟩
  | next head tail ih =>
      have following := ih (fun token member => ordinary token (by simp [member]))
      have first := step_boolean_preserved (ordinary _ (by simp)) head
      exact ⟨following.1.trans first.1, following.2.trans first.2⟩

private theorem tokens_header_ready {text form tokens state events final}
    (tv : Compose.Expressions.ValidText text)
    (parsed : Sequence.TokensAt text form tokens state events final)
    (valid : OuterReadiness.ValidState text state) : OuterReadiness.ValidState text final := by
  induction parsed with
  | done => exact valid
  | next head _ ih =>
      apply ih
      rw [← head.scanned]
      exact OuterReadiness.step_valid text tv form _ _ valid

/-- Exact source-order Boolean declarations and raw checks from the accepted
mixed declaration region, before the final `begin` token. -/
def BooleanHeaderAt (source : Source) (form : Form)
    (declarations : List BooleanDeclaration) (checks : List Obligation) : Prop :=
  ∃ before after leading event,
    Sequence.TokensAt source form.helper (booleanHeaderLead form) initialState leading before ∧
    BooleanDeclarationsAt source form.helper.hasArguments before declarations checks after ∧
    StepAt source form.helper (.word "begin") after (prefixScan source form).state event

theorem prefix_boolean_trace {source form events}
    (tv : Compose.Expressions.ValidText source)
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state) :
    ∃ declarations checks, BooleanHeaderAt source form declarations checks := by
  rw [boolean_header_split] at parsed
  obtain ⟨before, leading, following, leadingRead, suffix⟩ := tokens_split parsed
  cases suffix with
  | next declaration tail =>
      cases tail with
      | next begin tail =>
          cases tail
          obtain ⟨strings, reading, _⟩ := declaration.payload
          have valid := tokens_header_ready tv leadingRead (OuterReadiness.initial_valid source)
          obtain ⟨values, checks, trace⟩ := declarations_boolean_trace tv valid.1 reading
          exact ⟨values, checks, _, _, _, _, leadingRead, trace, begin⟩

theorem boolean_header_unique {source form first second left right}
    (a : BooleanHeaderAt source form first left) (b : BooleanHeaderAt source form second right) :
    first = second ∧ left = right := by
  obtain ⟨before, after, leading, event, leadingRead, trace, ending⟩ := a
  obtain ⟨otherBefore, otherAfter, otherLeading, otherEvent, otherPrefix, otherTrace, otherEnding⟩ := b
  have same := (Sequence.tokens_unique leadingRead otherPrefix).2
  subst otherBefore
  exact ⟨(boolean_declarations_unique trace otherTrace).1,
    (boolean_declarations_unique trace otherTrace).2.1⟩

private theorem empty_boolean_analysis :
    ArrayBindings.booleanAnalysis [] (BooleanBindings.analysis []) = ({} : Boolean.Analysis) := by
  unfold ArrayBindings.booleanAnalysis ArrayBindings.booleanNames BooleanBindings.analysis
  congr 1 <;> funext index <;> simp <;> omega

theorem prefix_boolean_analysis {source form declarations checks}
    (tv : Compose.Expressions.ValidText source)
    (trace : BooleanHeaderAt source form declarations checks) :
    ArrayBindings.booleanAnalysis (contextOf (prefixScan source form)).arrayNames
      (BooleanBindings.analysis (contextOf (prefixScan source form)).booleanNames) =
        booleanBodyAnalysis declarations := by
  obtain ⟨before, after, leading, event, leadingRead, reading, ending⟩ := trace
  have empty := tokens_boolean_preserved
    (by cases form <;> simp [booleanHeaderLead, Form.hasArguments, ShellToken.word, ShellToken.symbol]) leadingRead
  have valid := tokens_header_ready tv leadingRead (OuterReadiness.initial_valid source)
  have analyzed := boolean_declarations_analysis tv valid.1 reading
  have initial : ArrayBindings.booleanAnalysis before.arrayNames.names
      (BooleanBindings.analysis before.booleanNames) = {} := by
    rw [empty.1, empty.2]
    exact empty_boolean_analysis
  rw [initial] at analyzed
  dsimp only [contextOf]
  rw [← ending.scanned]
  simpa only [step, ending.positive, ↓reduceIte, ShellToken.word, booleanBodyAnalysis] using analyzed

theorem prefix_boolean_valid {source form events declarations checks}
    (tv : Compose.Expressions.ValidText source)
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state)
    (trace : BooleanHeaderAt source form declarations checks) :
    BooleanDeclarationsWellFormed form.hasArguments (prefixScan source form).state.names.shape {} declarations ∧
      checkBooleanDeclarations (prefixScan source form).state.names.shape Integer.Analysis.empty
        ⟨initialFacts form.hasArguments, Integer.emptyRanges⟩ {} declarations = true ∧
      discharged checks = true := by
  obtain ⟨before, after, leading, event, leadingRead, reading, ending⟩ := trace
  have empty := tokens_boolean_preserved (by cases form <;> simp [booleanHeaderLead, Form.hasArguments, ShellToken.word, ShellToken.symbol]) leadingRead
  have valid := (Sequence.tokens_valid tv.2 leadingRead Compose.initial_valid).1
  have ready := tokens_header_ready tv leadingRead (OuterReadiness.initial_valid source)
  have checked := boolean_declarations_valid tv reading valid.1 ready.1 ready.2 valid.2.2.2.1 valid.2.2.2.2
  obtain ⟨strings, declarations⟩ := boolean_declarations_reading reading
  have dynamic := (declarations_fields declarations).2.2.1
  have arguments := prefix_arguments parsed
  have names : (prefixScan source form).state.names = after.names := by
    rw [← ending.scanned]; simp [step, ending.positive, ShellToken.word]
  have finalDynamic : (prefixScan source form).state.dynamicFirst = before.dynamicFirst := by
    rw [← ending.scanned]; simpa [step, ending.positive, ShellToken.word] using dynamic
  change decide ((prefixScan source form).state.dynamicFirst ≠ 0) = form.hasArguments at arguments
  rw [finalDynamic] at arguments
  have path : (booleanDeclarationFacts before).path = initialFacts form.hasArguments := by
    rw [← arguments]
    simp only [booleanDeclarationFacts, ActiveFlow.initial, initialFacts, decide_eq_true_eq]
  have initial : ArrayBindings.booleanAnalysis before.arrayNames.names
      (BooleanBindings.analysis before.booleanNames) = {} := by
    rw [empty.1, empty.2]
    exact empty_boolean_analysis
  simpa only [names, initial, path, arguments] using checked

end Silver.Predicate
