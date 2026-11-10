module

public import Silver.PredicateHeaderFlow
public import Silver.PredicateBooleanHeader
public import Silver.ComposeArrayStore
public import Silver.SequenceMixedTrace

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

abbrev rawBody (source : Source) (form : Form) : BodyScan :=
  readBody source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly
    (prefixScan source form).state.functions (prefixScan source form).state.procedures

structure FormReading (source : Source) (form : Form) (events : List Event)
    (items : List SourceStatement) : Prop where
  header : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state
  statements : BodyAt (catalog := (prefixScan source form).state.functions) (procedures := (prefixScan source form).state.procedures) source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly items (rawBody source form)
  completed : completed (rawBody source form).facts.path = true
  footer : ∃ footerEvents, Sequence.TokensAt source form.helper form.footer (bodyScan source form).state
    footerEvents (finalScan source form).state
  finished : Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1

def FormMember (source : Source) (form : Form) : Prop :=
  SourceDomain source ∧ ∃ events items, FormReading source form events items

def Member (source : Source) : Prop := ∃ form, FormMember source form

private theorem initial_ranges (source : Source) : Compose.Expressions.ValidState source initialState := by
  simp [Compose.Expressions.ValidState, Compose.Expressions.ValidCursor, Compose.Expressions.ValidNames,
    Named.NameState.Valid, initialState, maxSourceLength, maxBindings,
    ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings, ArrayBindings.ValidEnvironment,
    ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials, ArrayBindings.maxBindings, ArrayBindings.maxElements,
    IntegerSubtypes.ValidEnvironment, BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFormals, FunctionBindings.maxFunctions,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxFormals, ProcedureBindings.maxProcedures]

private theorem initialFacts_bounded (arguments : Bool) : (initialFacts arguments).Bounded := by
  cases arguments
  · simp [initialFacts, Context.Bounded, Region.Bounded, maxSourceLength]
  · exact Context.initial_bounded (Nat.le_refl _)

theorem form_reading_sound {source : Source} {form : Form}
    (accepted : (formResult source form).state.position ≠ 0) : FormMember source form := by
  obtain ⟨domain, prefixPositive, finalPositive, finished, _⟩ := formResult_success accepted
  have bodyPositive : (bodyScan source form).state.position ≠ 0 := fun zero =>
    finalPositive (scanTokens_zero source form.helper form.footer _ zero)
  have rawPositive : (rawBody source form).position ≠ 0 := by
    intro zero
    simp [bodyScan, readStatements, zero, invalidScan, invalidState] at bodyPositive
  have complete : completed (rawBody source form).facts.path = true := by
    by_cases good : completed (rawBody source form).facts.path = true
    · exact good
    · simp only [bodyScan, readStatements] at bodyPositive
      have bad : (!completed (rawBody source form).facts.path) = true := by
        cases h : completed (rawBody source form).facts.path <;> simp_all
      simp only [rawBody] at bad
      rw [ite_eq_left (Or.inr bad)] at bodyPositive
      exact False.elim (bodyPositive rfl)
  obtain ⟨events, headRead⟩ := tokens_sound source form.helper form.prefix initialScan prefixPositive
  have ranges := scanTokens_ranges source form.helper form.prefix initialScan ⟨domain.1, domain.2.1⟩ (initial_ranges source)
  obtain ⟨items, statements⟩ := body_sound (catalog := (prefixScan source form).state.functions)
    (procedures := (prefixScan source form).state.procedures) source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly
    ⟨domain.1, domain.2.1⟩ ranges.2.1 ranges.1 rawPositive
  obtain ⟨footerEvents, footer⟩ := tokens_sound source form.helper form.footer (bodyScan source form) finalPositive
  exact ⟨domain, events, items, headRead, statements, complete, ⟨footerEvents, footer⟩, finished⟩

theorem form_reading_complete {source : Source} {form : Form}
    (member : FormMember source form) : (formResult source form).state.position ≠ 0 := by
  obtain ⟨domain, events, items, parsed⟩ := member
  obtain ⟨_, footer⟩ := parsed.footer
  have finalPositive := (Sequence.tokens_positive footer).2
  rw [formResult_complete domain (Sequence.tokens_positive parsed.header).2 finalPositive parsed.finished]
  exact finalPositive

theorem all_forms (form : Form) : form ∈ allForms := by cases form <;> simp [allForms]

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp only [accepts, selectedForm, List.find?_isSome]
  constructor
  · rintro ⟨form, _, accepted⟩
    exact ⟨form, form_reading_sound (of_decide_eq_true accepted)⟩
  · rintro ⟨form, member⟩
    exact ⟨form, all_forms form, decide_eq_true (form_reading_complete member)⟩

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

theorem form_reading_valid {source : Source} {form : Form} {events : List Event} {items : List SourceStatement}
    (domain : SourceDomain source) (parsed : FormReading source form events items) :
    ∃ scalars checks booleans booleanChecks program functions procedures,
      Sequence.ScalarTokensAt source form.helper form.prefix initialState scalars (prefixScan source form).state ∧
      Sequence.InitializerTokensAt source form.helper form.prefix initialState checks (prefixScan source form).state ∧
      BooleanHeaderAt source form booleans booleanChecks ∧
      Sequence.MixedTokensAt source form.helper form.prefix initialState functions procedures (prefixScan source form).state ∧
      decodePrefix form events items scalars
        (ScalarExpression.constants (prefixScan source form).state.scalarNames) checks
        (prefixScan source form).state.arrayNames booleans booleanChecks functions procedures = some program ∧ program.Valid := by
  obtain ⟨scalars, scalarTrace⟩ := Sequence.tokens_scalar_trace parsed.header
  obtain ⟨checks, initializerTrace⟩ := Sequence.tokens_initializer_trace parsed.header
  obtain ⟨booleans, booleanChecks, booleanTrace⟩ := prefix_boolean_trace ⟨domain.1, domain.2.1⟩ parsed.header
  obtain ⟨functions, procedures, callableTrace⟩ := Sequence.tokens_mixed_trace
    ⟨domain.1, domain.2.1⟩ (initial_ranges source) parsed.header
  have callableValid := callableTrace.checked ⟨domain.1, domain.2.1⟩ (initial_ranges source)
  simp only [initialState, catalogSignatures, ProcedureBindings.catalogSignatures,
    List.map_nil, List.nil_append] at callableValid
  have functionsValid := And.intro callableValid.1 callableValid.2.2.1
  have proceduresValid := And.intro callableValid.2.1 callableValid.2.2.2
  have booleansValid := prefix_boolean_valid ⟨domain.1, domain.2.1⟩ parsed.header booleanTrace
  have scalarChecked := prefix_scalar_checked scalarTrace
  obtain ⟨valid, stream⟩ := Sequence.tokens_valid domain.2.1 parsed.header Compose.initial_valid
  have ranges := scanTokens_ranges source form.helper form.prefix initialScan ⟨domain.1, domain.2.1⟩ (initial_ranges source)
  have bodyValid := body_meaning ranges.functions ranges.procedures rfl valid.1 (prefix_baseReady scalarTrace) (prefix_arraysReady parsed.header) ranges.booleans.1 ranges.2.1
    (bodyOf_compatible _) (initialFacts_bounded _) parsed.statements
  have context := Sequence.tokens_context parsed.header
  simp only [initialState, empty_names_shape] at context
  have arguments := prefix_arguments parsed.header
  obtain ⟨program, decoded, programValid⟩ := prefix_decoded_valid form events items scalars
    (ScalarExpression.constants (prefixScan source form).state.scalarNames) checks
    (prefixScan source form).state.arrayNames booleans booleanChecks functions functionsValid.1 procedures
    (by rw [functionsValid.2] at proceduresValid; exact proceduresValid.1)
    (by rw [context]; exact booleansValid.1)
    (by rw [context]; exact booleansValid.2.1) booleansValid.2.2
    (prefix_array_ready parsed.header).1.2.2.1 (prefix_array_ready parsed.header).2.2.2
    (Sequence.tokens_kinds parsed.header)
    (by simpa only [initialState, empty_names_shape, List.append_nil] using stream [] trivial)
    (body_nonempty parsed.statements)
    (by rw [context, ← arguments, ← prefix_boolean_analysis ⟨domain.1, domain.2.1⟩ booleanTrace]; exact bodyValid.1)
    (by
      refine ⟨(contextOf (prefixScan source form)).flow (rawBody source form).facts, ?_, parsed.completed⟩
      rw [context, ← arguments, ← prefix_analysis scalarTrace, ← bodyOf_model, ← prefix_boolean_analysis ⟨domain.1, domain.2.1⟩ booleanTrace]
      rw [← functionsValid.2, ← proceduresValid.2]
      exact bodyValid.2.1)
    scalarChecked.1 (prefix_initializer_checked domain.2.1 initializerTrace)
  exact ⟨scalars, checks, booleans, booleanChecks, program, functions, procedures, scalarTrace, initializerTrace, booleanTrace, callableTrace, decoded, programValid⟩

def SourceMeaning (source : Source) (program : Program) : Prop :=
  ∃ form events items scalars checks booleans booleanChecks, SourceDomain source ∧ selectedForm source = some form ∧
    FormReading source form events items ∧
    Sequence.ScalarTokensAt source form.helper form.prefix initialState scalars (prefixScan source form).state ∧
    Sequence.InitializerTokensAt source form.helper form.prefix initialState checks (prefixScan source form).state ∧
    BooleanHeaderAt source form booleans booleanChecks ∧
    ∃ functions procedures, Sequence.MixedTokensAt source form.helper form.prefix initialState functions procedures (prefixScan source form).state ∧
    decodePrefix form events items scalars
      (ScalarExpression.constants (prefixScan source form).state.scalarNames) checks
        (prefixScan source form).state.arrayNames booleans booleanChecks functions procedures = some program

theorem meaning_member {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : Member source := by
  obtain ⟨form, events, items, _, _, _, _, domain, _, parsed, _, _, _, _⟩ := meaning
  exact ⟨form, domain, events, items, parsed⟩

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  have accepted := (accepts_iff_member source).mpr member
  obtain ⟨form, selected⟩ := Option.isSome_iff_exists.mp accepted
  have success := List.find?_some selected
  have formMember := form_reading_sound (of_decide_eq_true success)
  obtain ⟨domain, events, items, parsed⟩ := formMember
  obtain ⟨scalars, checks, booleans, booleanChecks, program, functions, procedures, scalarTrace, initializerTrace, booleanTrace, callableTrace, decoded, _⟩ := form_reading_valid domain parsed
  exact ⟨program, form, events, items, scalars, checks, booleans, booleanChecks, domain, selected, parsed, scalarTrace, initializerTrace, booleanTrace, functions, procedures, callableTrace, decoded⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  obtain ⟨form, events, items, scalars, checks, booleans, booleanChecks, _, selected, parsed, scalarTrace, initializerTrace, booleanTrace, functions, procedures, callableTrace, decoded⟩ := first
  obtain ⟨otherForm, otherEvents, otherItems, otherScalars, otherChecks, otherBooleans, otherBooleanChecks, _, otherSelected, other, otherTrace, otherInitializerTrace, otherBooleanTrace, otherFunctions, otherProcedures, otherCallableTrace, otherDecoded⟩ := second
  have formSame : form = otherForm := Option.some.inj (selected.symm.trans otherSelected)
  subst otherForm
  have eventsSame := (Sequence.tokens_unique parsed.header other.header).1
  have itemsSame := body_unique parsed.statements other.statements
  have scalarsSame := (Sequence.scalar_tokens_unique scalarTrace otherTrace).1
  obtain ⟨functionsSame, proceduresSame, _⟩ := callableTrace.unique otherCallableTrace
  subst otherFunctions
  subst otherProcedures
  have checksSame := Sequence.initializer_tokens_unique initializerTrace otherInitializerTrace
  obtain ⟨rfl, rfl⟩ := boolean_header_unique booleanTrace otherBooleanTrace
  subst otherChecks
  subst otherEvents
  subst otherItems
  subst otherScalars
  exact Option.some.inj (decoded.symm.trans otherDecoded)

theorem meaning_valid {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : program.Valid := by
  obtain ⟨_, _, _, scalars, checks, booleans, booleanChecks, domain, _, parsed, scalarTrace, initializerTrace, booleanTrace, functions, procedures, callableTrace, decoded⟩ := meaning
  obtain ⟨otherScalars, otherChecks, otherBooleans, otherBooleanChecks, other, otherFunctions, otherProcedures, otherTrace, otherInitializerTrace, otherBooleanTrace, otherCallableTrace, same, valid⟩ := form_reading_valid domain parsed
  have scalarsSame := (Sequence.scalar_tokens_unique scalarTrace otherTrace).1
  obtain ⟨functionsSame, proceduresSame, _⟩ := callableTrace.unique otherCallableTrace
  subst otherFunctions
  subst otherProcedures
  have checksSame := Sequence.initializer_tokens_unique initializerTrace otherInitializerTrace
  obtain ⟨rfl, rfl⟩ := boolean_header_unique booleanTrace otherBooleanTrace
  subst otherChecks
  subst otherScalars
  have equal := Option.some.inj (same.symm.trans decoded)
  simpa only [equal] using valid

/-- Array shape, disjoint allocation and the canonical initialization table
come from the actual mixed declaration trace, including empty headers. -/
theorem meaning_arrays_source_ready {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : ArrayBindings.SourceReady source program.arrays := by
  obtain ⟨form, events, items, scalars, checks, _, _, _, _, parsed, _, _, _, functions, procedures, _, decoded⟩ := meaning
  rw [(decoded_integer_state decoded).2]
  exact prefix_array_ready parsed.header

/-- The executable initial Integer store is exactly the source header's
frozen store. Scalar and String initializer projections freeze in their own
incoming store; raw array aggregates have the transition proved by
`Compose.array_declaration_execute`, and all raw checks remain in the trace. -/
theorem meaning_initial_integer_store {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∃ form, selectedForm source = some form ∧
      program.initialIntegers = frozenIntegers (prefixScan source form).state.scalarNames
        (prefixScan source form).state.arrayNames.names (prefixScan source form).state.arrayNames.values := by
  have initial := (Program.initial_integers (meaning_valid meaning)).1
  obtain ⟨form, events, items, scalars, checks, _, _, _, selected, _, _, _, _, functions, procedures, _, decoded⟩ := meaning
  have fields := decoded_integer_state decoded
  rw [fields.1, fields.2] at initial
  exact ⟨form, selected, initial⟩

/-- Source meaning preserves the exact declared Integer subtype: explicit
ranges evaluate their independently read static endpoints, and an absent range
has the predefined Integer bounds. This covers every decoded declaration. -/
theorem meaning_scalar_source_bounds {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∀ declaration ∈ program.integerDeclarations, Compose.ScalarDeclarationSourceBounds source declaration := by
  obtain ⟨_, _, _, scalars, _, _, _, _, _, _, scalarTrace, _, _, functions, procedures, _, decoded⟩ := meaning
  have bounds := Sequence.scalar_tokens_source_bounds scalarTrace ScalarExpression.static_empty
  have same : program.integerDeclarations = scalars := by
    unfold decodePrefix at decoded
    split at decoded <;> cases decoded <;> rfl
  simpa only [same] using bounds

/-- The canonical inventory retains the raw initializer Image schemas, array
bounds, singleton association choices and every aggregate component from the
accepted header, before immutable specialization. -/
theorem meaning_initializer_trace {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∃ form, selectedForm source = some form ∧
      Sequence.InitializerTokensAt source form.helper form.prefix initialState program.initializerChecks
        (prefixScan source form).state := by
  obtain ⟨form, _, _, _, checks, _, _, _, selected, _, _, trace, _, functions, procedures, _, decoded⟩ := meaning
  exact ⟨form, selected, (decoded_initializer_checks decoded).symm ▸ trace⟩

/-- The program retains the source-order Boolean declarations, mutability and
all checks on the original initializers, including before Integer freezing. -/
theorem meaning_boolean_header {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∃ form, selectedForm source = some form ∧
      BooleanHeaderAt source form program.booleanDeclarations program.booleanInitializerChecks := by
  obtain ⟨form, _, _, _, _, _, _, _, selected, _, _, _, trace, functions, procedures, _, decoded⟩ := meaning
  have fields := decoded_boolean_state decoded
  exact ⟨form, selected, by rw [fields.1, fields.2]; exact trace⟩

/-- Every accepted function, including unused definitions, is retained in the
same source-order trace consumed by the whole-program safety theorem. -/
theorem meaning_function_header {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∃ form, selectedForm source = some form ∧
      Sequence.FunctionTokensAt source form.helper form.prefix initialState program.functions
        (prefixScan source form).state := by
  obtain ⟨form, _, _, _, _, _, _, _, selected, _, _, _, _, functions, procedures, trace, decoded⟩ := meaning
  exact ⟨form, selected, (decoded_functions decoded).symm ▸ trace.functionProjection⟩

/-- Every procedure is retained with the exact function/procedure declaration
trace used to establish both complete callable environments. -/
theorem meaning_callable_header {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∃ form, selectedForm source = some form ∧
      Sequence.MixedTokensAt source form.helper form.prefix initialState program.functions program.procedures
        (prefixScan source form).state := by
  obtain ⟨form, _, _, _, _, _, _, _, selected, _, _, _, _, functions, procedures, trace, decoded⟩ := meaning
  exact ⟨form, selected, by rw [decoded_functions decoded, decoded_procedures decoded]; exact trace⟩

theorem source_execution_sound {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (arguments : Arguments.Runtime.Arguments) :
    program.checkedExecute arguments = some (program.execute arguments) :=
  (Program.execution_sound (meaning_valid meaning) arguments).2.2

theorem source_obligations_discharge {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : Semantics.discharge program.obligations = true :=
  Program.all_obligations_discharge (meaning_valid meaning)

theorem null_predicate_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, form, _, events, items, parsed⟩
  have headRead := parsed.header
  obtain ⟨tokens, spelling⟩ : ∃ tokens, form.prefix = .contextClauses :: tokens := by
    cases form <;> exact ⟨_, rfl⟩
  rw [spelling] at headRead
  cases headRead with
  | next first _ =>
      have accepted := first.following
      rw [← first.scanned] at accepted
      have contextAccepted : Names.contextAfter source form.helper.hasArguments ≠ 0 := by
        simpa [step, initialState] using accepted
      have firstWith := Names.contextAfter_firstWith source form.helper.hasArguments contextAccepted
      have matched : fixedAt source (Cursor.triviaPosition source 1) "with" true = true := by
        by_cases found : fixedAt source (Cursor.triviaPosition source 1) "with" true = true
        · exact found
        · have absent : Names.fixedAt source (Cursor.triviaPosition source 1) "with" true ≠ true := found
          simp [Names.take, absent] at firstWith
      have nullParsed := (Cursor.isMember_iff source).mpr nullMember
      change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
        .procedureKeyword && _)) = true at nullParsed
      simp only [Bool.and_eq_true] at nullParsed
      have nullToken := nullParsed.2.1
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstOutput := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling] at firstNull firstOutput
      omega


end Silver.Predicate
