module

public import Silver.ProcedureMetadataNative
public import Silver.PredicateSelectors
public import Silver.PredicateOuterReadiness

@[expose] public section

namespace Silver.Predicate.ProcedureMetadataNative
open Compose

/-- Resolve nominal formal type identities using the same accepted scan that
selects the raw procedure metadata. This is an interpretation of the existing
scan result; it adds no native selector or independent type-table input. -/
def selectTypes (reader : Source → Form → ScanResult) (text : Source) :
    ArrayBindings.TypeEnvironment :=
  if (reader text .direct).state.position ≠ 0 then (reader text .direct).state.arrayNames.types
  else if (reader text .argument).state.position ≠ 0 then (reader text .argument).state.arrayNames.types
  else []

theorem interpreted_types (calls : Calls) (imports : FormImports calls) (text : Source) :
    selectTypes (calls.form .executable) text = selectTypes formResult text := by
  unfold selectTypes
  simp only [imports.executable, imports.model]

theorem footer_procedures {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, token ≠ ShellToken.declarations)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    final.procedures = state.procedures := by
  induction parsed with
  | done => rfl
  | next head _ ih =>
      exact (ih (fun token member => ordinary token (by simp [member]))).trans
        (Sequence.step_procedures_preserved (ordinary _ (by simp)) head)

theorem footer_arrayTypes {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, token ≠ ShellToken.declarations)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    final.arrayNames.types = state.arrayNames.types := by
  induction parsed with
  | done => rfl
  | next head _ ih =>
      have preserved := congrArg ArrayBindings.Env.types
        (Sequence.step_arrayNames_preserved (ordinary _ (by simp)) head)
      exact (ih (fun token member => ordinary token (by simp [member]))).trans preserved

/-- The body and fixed footer retain the catalog installed by the declaration
prefix. Rejection never supplies a catalog to this theorem. -/
theorem form_procedures {text : Source} {form : Form} {events : List Event}
    {items : List SourceStatement} (domain : SourceDomain text)
    (parsed : FormReading text form events items) :
    (formResult text form).state.procedures = (prefixScan text form).state.procedures := by
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  rw [(formResult_success accepted).2.2.2.2]
  obtain ⟨footerEvents, footer⟩ := parsed.footer
  have footerSame := footer_procedures
    (by cases form <;> simp [Form.footer, ShellToken.word, ShellToken.symbol]) footer
  rw [footerSame]
  have positive := (Sequence.tokens_positive footer).1
  unfold bodyScan readStatements at positive ⊢
  dsimp only at positive ⊢
  split at positive
  · exact False.elim (positive rfl)
  · rename_i acceptedBody
    rw [ite_eq_right acceptedBody]
    rfl

/-- The type environment used to interpret nominal procedure formals is the
exact table produced by the source declaration prefix. -/
theorem form_arrayTypes {text : Source} {form : Form} {events : List Event}
    {items : List SourceStatement} (domain : SourceDomain text)
    (parsed : FormReading text form events items) :
    (formResult text form).state.arrayNames.types = (prefixScan text form).state.arrayNames.types := by
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  rw [(formResult_success accepted).2.2.2.2]
  obtain ⟨footerEvents, footer⟩ := parsed.footer
  have footerSame := footer_arrayTypes
    (by cases form <;> simp [Form.footer, ShellToken.word, ShellToken.symbol]) footer
  rw [footerSame]
  have positive := (Sequence.tokens_positive footer).1
  unfold bodyScan readStatements at positive ⊢
  dsimp only at positive ⊢
  split at positive
  · exact False.elim (positive rfl)
  · rename_i acceptedBody
    rw [ite_eq_right acceptedBody]
    rfl

theorem selected_catalog {text : Source} {form : Form}
    (accepted : (formResult text form).state.position ≠ 0) :
    procedureModel text = (formResult text form).state.procedures := by
  cases form with
  | direct =>
      unfold procedureModel select
      rw [ite_eq_left accepted]
  | argument =>
      have noDirect : (formResult text .direct).state.position = 0 := by
        by_cases direct : (formResult text .direct).state.position = 0
        · exact direct
        · have impossible := accepted_form_unique direct accepted
          cases impossible
      unfold procedureModel select
      rw [ite_eq_right (not_not_intro noDirect), ite_eq_left accepted]

theorem selected_types {text : Source} {form : Form}
    (accepted : (formResult text form).state.position ≠ 0) :
    selectTypes formResult text = (formResult text form).state.arrayNames.types := by
  cases form with
  | direct =>
      unfold selectTypes
      rw [ite_eq_left accepted]
  | argument =>
      have noDirect : (formResult text .direct).state.position = 0 := by
        by_cases direct : (formResult text .direct).state.position = 0
        · exact direct
        · have impossible := accepted_form_unique direct accepted
          cases impossible
      unfold selectTypes
      rw [ite_eq_right (not_not_intro noDirect), ite_eq_left accepted]

/-- The native metadata selector describes precisely the procedures retained in
the canonical program, including unused declarations, with nominal formals resolved through the same
accepted scan's type environment. -/
theorem meaning_catalog {text : Source} {program : Program}
    (meaning : SourceMeaning text program) :
    ProcedureBindings.catalogSignatures (procedureModel text) (selectTypes formResult text) =
      program.procedures.map ScalarProcedures.Definition.signature := by
  obtain ⟨form, events, items, _, _, _, _, domain, _, parsed, _, _, _,
    functions, procedures, callableTrace, decoded⟩ := meaning
  have accepted := form_reading_complete ⟨domain, events, items, parsed⟩
  rw [selected_catalog accepted, selected_types accepted,
    form_procedures domain parsed, form_arrayTypes domain parsed, decoded_procedures decoded]
  have catalog := callableTrace.procedure_catalog ⟨domain.1, domain.2.1⟩
    (OuterReadiness.initial_valid text).base initial_callable_types_known
  simpa only [initialState, ProcedureBindings.catalogSignatures,
    List.map_nil, List.nil_append] using catalog

theorem executable_catalog (calls : Calls) (equations : Equations calls)
    (imports : FormImports calls) {text : Source} {program : Program}
    (meaning : SourceMeaning text program) :
    ProcedureBindings.catalogSignatures (calls.executable text)
      (selectTypes (calls.form .executable) text) =
      program.procedures.map ScalarProcedures.Definition.signature := by
  rw [interpreted_executable calls equations imports, interpreted_types calls imports]
  exact meaning_catalog meaning

/-- The native Count test used by the report inventory and no-inlining recipe
counts the same procedure declarations as the canonical program. -/
theorem executable_count (calls : Calls) (equations : Equations calls)
    (imports : FormImports calls) {text : Source} {program : Program}
    (meaning : SourceMeaning text program) :
    (calls.executable text).items.length = program.procedures.length := by
  have count := congrArg List.length (executable_catalog calls equations imports meaning)
  simpa only [ProcedureBindings.catalogSignatures, List.length_map] using count

end Silver.Predicate.ProcedureMetadataNative
