module

public import Silver.PredicateHeader

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

abbrev rawBody (source : Source) (form : Form) : BodyScan :=
  readBody source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly

structure FormReading (source : Source) (form : Form) (events : List Event)
    (items : List SourceStatement) : Prop where
  header : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state
  statements : BodyAt source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly items (rawBody source form)
  completed : completed (rawBody source form).facts = true
  footer : ∃ footerEvents, Sequence.TokensAt source form.helper form.footer (bodyScan source form).state
    footerEvents (finalScan source form).state
  finished : Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1

def FormMember (source : Source) (form : Form) : Prop :=
  SourceDomain source ∧ ∃ events items, FormReading source form events items

def Member (source : Source) : Prop := ∃ form, FormMember source form

private theorem initial_ranges (source : Source) : Compose.Expressions.ValidState source initialState := by
  simp [Compose.Expressions.ValidState, Compose.Expressions.ValidCursor, Compose.Expressions.ValidNames,
    Named.NameState.Valid, initialState, maxSourceLength, maxBindings]

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
  have complete : completed (rawBody source form).facts = true := by
    by_cases good : completed (rawBody source form).facts = true
    · exact good
    · simp only [bodyScan, readStatements] at bodyPositive
      have bad : (!completed (rawBody source form).facts) = true := by
        cases h : completed (rawBody source form).facts <;> simp_all
      simp only [rawBody] at bad
      rw [ite_eq_left (Or.inr bad)] at bodyPositive
      exact False.elim (bodyPositive rfl)
  obtain ⟨events, headRead⟩ := tokens_sound source form.helper form.prefix initialScan prefixPositive
  have ranges := scanTokens_ranges source form.helper form.prefix initialScan ⟨domain.1, domain.2.1⟩ (initial_ranges source)
  obtain ⟨items, statements⟩ := body_sound source (contextOf (prefixScan source form)) (bodyOf (prefixScan source form)) .endOnly
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
    ∃ program, decodePrefix form events items = some program ∧ program.Valid := by
  obtain ⟨valid, stream⟩ := Sequence.tokens_valid domain.2.1 parsed.header Compose.initial_valid
  have ranges := scanTokens_ranges source form.helper form.prefix initialScan ⟨domain.1, domain.2.1⟩ (initial_ranges source)
  have bodyValid := body_meaning valid.1 ranges.2.1 (initialFacts_bounded _) parsed.statements
  have context := Sequence.tokens_context parsed.header
  simp only [initialState, empty_names_shape] at context
  have arguments := prefix_arguments parsed.header
  apply prefix_decoded_valid form events items (Sequence.tokens_kinds parsed.header)
  · simpa only [initialState, empty_names_shape, List.append_nil] using stream [] trivial
  · exact body_nonempty parsed.statements
  · rw [context, ← arguments]
    exact bodyValid.1
  · refine ⟨(rawBody source form).facts, ?_, parsed.completed⟩
    rw [context, ← arguments]
    exact bodyValid.2.1

def SourceMeaning (source : Source) (program : Program) : Prop :=
  ∃ form events items, SourceDomain source ∧ selectedForm source = some form ∧
    FormReading source form events items ∧ decodePrefix form events items = some program

theorem meaning_member {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : Member source := by
  obtain ⟨form, events, items, domain, _, parsed, _⟩ := meaning
  exact ⟨form, domain, events, items, parsed⟩

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  have accepted := (accepts_iff_member source).mpr member
  obtain ⟨form, selected⟩ := Option.isSome_iff_exists.mp accepted
  have success := List.find?_some selected
  have formMember := form_reading_sound (of_decide_eq_true success)
  obtain ⟨domain, events, items, parsed⟩ := formMember
  obtain ⟨program, decoded, _⟩ := form_reading_valid domain parsed
  exact ⟨program, form, events, items, domain, selected, parsed, decoded⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  obtain ⟨form, events, items, _, selected, parsed, decoded⟩ := first
  obtain ⟨otherForm, otherEvents, otherItems, _, otherSelected, other, otherDecoded⟩ := second
  have formSame : form = otherForm := Option.some.inj (selected.symm.trans otherSelected)
  subst otherForm
  have eventsSame := (Sequence.tokens_unique parsed.header other.header).1
  have itemsSame := body_unique parsed.statements other.statements
  subst otherEvents
  subst otherItems
  exact Option.some.inj (decoded.symm.trans otherDecoded)

theorem meaning_valid {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : program.Valid := by
  obtain ⟨_, _, _, domain, _, parsed, decoded⟩ := meaning
  obtain ⟨other, same, valid⟩ := form_reading_valid domain parsed
  have equal := Option.some.inj (same.symm.trans decoded)
  simpa only [equal] using valid

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
