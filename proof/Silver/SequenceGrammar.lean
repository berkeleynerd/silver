module

public import Silver.SequenceHeader
public import Silver.SequenceShell
public import Silver.SequenceConditionValidity

@[expose] public section

/-! Source membership, unique source meaning and initialized fixed-shape
program validity for the complete statement grammar. All payloads come from the
existing lexical/expression reading relations and the new statement readings. -/

namespace Silver.Sequence
open Compose Bindings

structure FormReading (source : Source) (form : Form) (events : List Event)
    (items : List Statement) : Prop where
  header : TokensAt source form.helper form.prefix initialState events (prefixScan source form).state
  statements : StatementsAt source (prefixScan source form) form.stop items (bodyScan source form)
  footer : ∃ footerEvents, TokensAt source form.helper form.footer (bodyScan source form).state
    footerEvents (finalScan source form).state
  finished : Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1

def FormMember (source : Source) (form : Form) : Prop :=
  SourceDomain source ∧ ∃ events items, FormReading source form events items

def Member (source : Source) : Prop := ∃ form, FormMember source form

theorem form_reading_sound {source : Source} {form : Form}
    (accepted : (formResult source form).state.position ≠ 0) : FormMember source form := by
  obtain ⟨domain, prefixPositive, finalPositive, finished, _⟩ := formResult_success accepted
  have bodyPositive : (bodyScan source form).state.position ≠ 0 := fun zero =>
    finalPositive (scanTokens_zero source form.helper form.footer _ zero)
  obtain ⟨events, headRead⟩ := tokens_sound source form.helper form.prefix initialScan prefixPositive
  obtain ⟨items, statements⟩ := statements_sound source (prefixScan source form) form.stop bodyPositive
  obtain ⟨footerEvents, footer⟩ := tokens_sound source form.helper form.footer (bodyScan source form) finalPositive
  exact ⟨domain, events, items, headRead, statements, ⟨footerEvents, footer⟩, finished⟩

theorem form_reading_complete {source : Source} {form : Form}
    (member : FormMember source form) : (formResult source form).state.position ≠ 0 := by
  obtain ⟨domain, events, items, parsed⟩ := member
  obtain ⟨_, footer⟩ := parsed.footer
  have finalPositive := (tokens_positive footer).2
  rw [formResult_complete domain (tokens_positive parsed.header).2 finalPositive parsed.finished]
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

theorem form_reading_valid {source : Source} {form : Form} {events : List Event} {items : List Statement}
    (domain : SourceDomain source) (parsed : FormReading source form events items) :
    ∃ program, decodePrefix form events items = some program ∧ program.Valid := by
  obtain ⟨valid, stream⟩ := tokens_valid domain.2.1 parsed.header Compose.initial_valid
  have bodyValid := statements_valid domain.2.1 valid parsed.statements
  have context := tokens_context parsed.header
  simp only [initialState, empty_names_shape] at context
  apply prefix_decoded_valid form events items (tokens_kinds parsed.header)
  · simpa only [initialState, empty_names_shape, List.append_nil] using stream [] trivial
  · exact body_items parsed.statements
  · rw [context]
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
  have eventsSame := (tokens_unique parsed.header other.header).1
  have itemsSame := (statements_unique parsed.statements other.statements).1
  subst otherEvents
  subst otherItems
  exact Option.some.inj (decoded.symm.trans otherDecoded)

theorem meaning_valid {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : program.Valid := by
  obtain ⟨_, _, _, domain, _, parsed, decoded⟩ := meaning
  obtain ⟨other, same, valid⟩ := form_reading_valid domain parsed
  have equal := Option.some.inj (same.symm.trans decoded)
  simpa only [equal] using valid

theorem null_sequence_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, form, _, events, items, parsed⟩
  have headRead := parsed.header
  obtain ⟨tokens, spelling⟩ : ∃ tokens, form.prefix = .fixed "with" true :: tokens := by
    cases form <;> exact ⟨_, rfl⟩
  rw [spelling] at headRead
  cases headRead with
  | next first _ =>
      have accepted := first.following
      rw [← first.scanned] at accepted
      have matched : fixedAt source (Cursor.triviaPosition source 1) "with" true = true := by
        by_cases found : fixedAt source (Cursor.triviaPosition source 1) "with" true = true
        · exact found
        · simp [step, initialState, fixedAfter, found] at accepted
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

end Silver.Sequence
