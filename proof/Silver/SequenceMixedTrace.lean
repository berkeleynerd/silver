module

public import Silver.SequenceFunctionTrace

@[expose] public section

namespace Silver.ScalarProcedures

theorem DefinitionsChecked.append {functions earlier first rest}
    (checked : DefinitionsChecked functions earlier first)
    (following : DefinitionsChecked functions (earlier ++ first.map Definition.signature) rest) :
    DefinitionsChecked functions earlier (first ++ rest) := by
  induction first generalizing earlier with
  | nil => simpa only [List.nil_append, List.map_nil, List.append_nil] using following
  | cons definition definitions ih =>
    refine ⟨checked.1, ih checked.2 ?_⟩
    simpa only [List.map_cons, List.append_assoc, List.singleton_append] using following

end Silver.ScalarProcedures

namespace Silver.Sequence
open Compose Silver.Compose.Expressions Predicate

/-- A shell step retains both callable inventories in their actual source order. -/
inductive MixedStepAt (text : Source) (form : Compose.Form) :
    ShellToken → ParserState → List ScalarFunctions.Definition →
      List ScalarProcedures.Definition → ParserState → Prop
  | declarations {state next functions procedures} :
      MixedDeclarationsAt text form.hasArguments state functions procedures next →
      MixedStepAt text form .declarations state functions procedures next
  | other {token state next} : token ≠ ShellToken.declarations →
      next.functions = state.functions → next.procedures = state.procedures →
      next.arrayNames.types = state.arrayNames.types →
      MixedStepAt text form token state [] [] next

theorem step_mixed_trace {text form token state next event}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : StepAt text form token state next event) :
    ∃ functions procedures, MixedStepAt text form token state functions procedures next := by
  by_cases declaration : token = .declarations
  · subst token
    have equation : declarationsAt text state form.hasArguments = next := by
      simpa only [step, parsed.positive, ↓reduceIte] using parsed.scanned
    obtain ⟨functions, procedures, source⟩ := mixedDeclarations_source textValid valid
      (by rw [equation]; exact parsed.following)
    rw [equation] at source
    exact ⟨functions, procedures, .declarations source⟩
  · exact ⟨[], [], .other declaration (step_functions_preserved declaration parsed)
      (step_procedures_preserved declaration parsed)
      (by rw [step_arrayNames_preserved declaration parsed])⟩

theorem MixedStepAt.callableTypesKnown {text form token state functions procedures next}
    (source : MixedStepAt text form token state functions procedures next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    CallableTypesKnown next := by
  cases source with
  | declarations source => exact source.callableTypesKnown textValid valid known
  | other _ functions procedures types =>
      constructor
      · simpa only [functions, types] using known.functions
      · simpa only [procedures, types] using known.procedures

/-- Callable type identity is a consequence of the actual accepted shell step. -/
theorem step_callable_types_known {text form token state next event}
    (textValid : ValidText text) (valid : ValidState text state)
    (known : CallableTypesKnown state) (parsed : StepAt text form token state next event) :
    CallableTypesKnown next := by
  obtain ⟨functions, procedures, source⟩ := step_mixed_trace textValid valid parsed
  exact source.callableTypesKnown textValid valid known

theorem MixedStepAt.functions_checked {text form token state functions procedures next}
    (source : MixedStepAt text form token state functions procedures next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ScalarFunctions.DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) functions ∧
      catalogSignatures next.functions next.arrayNames.types =
        catalogSignatures state.functions state.arrayNames.types ++ functions.map ScalarFunctions.Definition.signature := by
  cases source with
  | declarations source => exact source.functions_checked textValid valid known
  | other _ same _ types => exact ⟨trivial, by simp only [same, types, List.map_nil, List.append_nil]⟩

theorem MixedStepAt.procedure_catalog {text form token state functions procedures next}
    (source : MixedStepAt text form token state functions procedures next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ProcedureBindings.catalogSignatures next.procedures next.arrayNames.types =
      ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types ++
        procedures.map ScalarProcedures.Definition.signature := by
  cases source with
  | declarations source => exact source.procedure_catalog textValid valid known
  | other _ _ same types => simp only [same, types, List.map_nil, List.append_nil]

theorem MixedStepAt.unique {text form token state leftFunctions leftProcedures rightFunctions rightProcedures next}
    (a : MixedStepAt text form token state leftFunctions leftProcedures next)
    (b : MixedStepAt text form token state rightFunctions rightProcedures next) :
    leftFunctions = rightFunctions ∧ leftProcedures = rightProcedures := by
  cases a with
  | declarations source =>
    cases b with
    | declarations other => exact source.unique other
    | other impossible => exact False.elim (impossible rfl)
  | other ordinary =>
    cases b with
    | declarations => exact False.elim (ordinary rfl)
    | other => exact ⟨rfl, rfl⟩

theorem MixedStepAt.functionProjection {text form token state functions procedures next}
    (source : MixedStepAt text form token state functions procedures next) :
    FunctionStepAt text form token state functions next := by
  cases source with
  | declarations source => exact .declarations ⟨_, source⟩
  | other ordinary sameFunctions sameProcedures types => exact .other ordinary sameFunctions sameProcedures types

inductive MixedTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List ScalarFunctions.Definition →
      List ScalarProcedures.Definition → ParserState → Prop
  | done {state} : MixedTokensAt text form [] state [] [] state
  | next {token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures} :
      StepAt text form token state middle event →
      MixedStepAt text form token state firstFunctions firstProcedures middle →
      MixedTokensAt text form tokens middle restFunctions restProcedures final →
      MixedTokensAt text form (token :: tokens) state
        (firstFunctions ++ restFunctions) (firstProcedures ++ restProcedures) final

theorem tokens_mixed_trace {text form tokens state events final}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : TokensAt text form tokens state events final) :
    ∃ functions procedures, MixedTokensAt text form tokens state functions procedures final := by
  induction parsed with
  | done => exact ⟨[], [], .done⟩
  | @next token tokens state next final event events head _ ih =>
    obtain ⟨firstFunctions, firstProcedures, source⟩ := step_mixed_trace textValid valid head
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    obtain ⟨restFunctions, restProcedures, following⟩ := ih nextValid
    exact ⟨firstFunctions ++ restFunctions, firstProcedures ++ restProcedures, .next head source following⟩

theorem MixedTokensAt.callableTypesKnown {text form tokens state functions procedures final}
    (source : MixedTokensAt text form tokens state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    CallableTypesKnown final := by
  induction source with
  | done => exact known
  | @next token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures head first _ ih =>
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    exact ih nextValid (first.callableTypesKnown textValid valid known)

/-- The history fact is threaded through source tokens from its derived initial fact. -/
theorem tokens_callable_types_known {text form tokens state events final}
    (textValid : ValidText text) (valid : ValidState text state)
    (known : CallableTypesKnown state) (parsed : TokensAt text form tokens state events final) :
    CallableTypesKnown final := by
  obtain ⟨functions, procedures, source⟩ := tokens_mixed_trace textValid valid parsed
  exact source.callableTypesKnown textValid valid known

theorem MixedTokensAt.functions_checked {text form tokens state functions procedures final}
    (source : MixedTokensAt text form tokens state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ScalarFunctions.DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) functions ∧
      catalogSignatures final.functions final.arrayNames.types =
        catalogSignatures state.functions state.arrayNames.types ++ functions.map ScalarFunctions.Definition.signature := by
  induction source with
  | done => exact ⟨trivial, (List.append_nil _).symm⟩
  | @next token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures head first _ ih =>
    have checked := first.functions_checked textValid valid known
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    have following := ih nextValid (first.callableTypesKnown textValid valid known)
    rw [checked.2] at following
    exact ⟨checked.1.append following.1,
      by simpa only [List.map_append, List.append_assoc] using following.2⟩

theorem MixedTokensAt.procedure_catalog {text form tokens state functions procedures final}
    (source : MixedTokensAt text form tokens state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ProcedureBindings.catalogSignatures final.procedures final.arrayNames.types =
      ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types ++
        procedures.map ScalarProcedures.Definition.signature := by
  induction source with
  | done => exact (List.append_nil _).symm
  | @next token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures head first _ ih =>
    have checked := first.procedure_catalog textValid valid known
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    have following := ih nextValid (first.callableTypesKnown textValid valid known)
    rw [checked] at following
    simpa only [List.map_append, List.append_assoc] using following

theorem MixedTokensAt.unique
    {text form tokens state leftFunctions leftProcedures rightFunctions rightProcedures leftState rightState}
    (a : MixedTokensAt text form tokens state leftFunctions leftProcedures leftState)
    (b : MixedTokensAt text form tokens state rightFunctions rightProcedures rightState) :
    leftFunctions = rightFunctions ∧ leftProcedures = rightProcedures ∧ leftState = rightState := by
  induction a generalizing rightFunctions rightProcedures rightState with
  | done => cases b; exact ⟨rfl, rfl, rfl⟩
  | next head source _ ih =>
    cases b with
    | next other otherSource otherRest =>
      have same := head.scanned.symm.trans other.scanned
      cases same
      obtain ⟨firstFunctions, firstProcedures⟩ := source.unique otherSource
      obtain ⟨rfl, rfl, rfl⟩ := ih otherRest
      exact ⟨by rw [firstFunctions], by rw [firstProcedures], rfl⟩

theorem MixedTokensAt.functionProjection {text form tokens state functions procedures final}
    (source : MixedTokensAt text form tokens state functions procedures final) :
    FunctionTokensAt text form tokens state functions final := by
  induction source with
  | done => exact .done
  | next head first _ ih => exact .next head first.functionProjection ih

/-- Mixed declaration steps retain both checked callable catalogues. -/
theorem MixedStepAt.checked {text form token state functions procedures next}
    (source : MixedStepAt text form token state functions procedures next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ScalarFunctions.DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) functions ∧
      ScalarProcedures.DefinitionsChecked (catalogSignatures next.functions next.arrayNames.types)
        (ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types) procedures ∧
      catalogSignatures next.functions next.arrayNames.types =
        catalogSignatures state.functions state.arrayNames.types ++ functions.map ScalarFunctions.Definition.signature ∧
      ProcedureBindings.catalogSignatures next.procedures next.arrayNames.types =
        ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types ++ procedures.map ScalarProcedures.Definition.signature := by
  cases source with
  | declarations source => exact source.checked textValid valid known
  | other _ sameFunctions sameProcedures types =>
      exact ⟨trivial, trivial,
        by simp only [sameFunctions, types, List.map_nil, List.append_nil],
        by simp only [sameProcedures, types, List.map_nil, List.append_nil]⟩

theorem MixedTokensAt.checked {text form tokens state functions procedures final}
    (source : MixedTokensAt text form tokens state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    ScalarFunctions.DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) functions ∧
      ScalarProcedures.DefinitionsChecked (catalogSignatures final.functions final.arrayNames.types)
        (ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types) procedures ∧
      catalogSignatures final.functions final.arrayNames.types =
        catalogSignatures state.functions state.arrayNames.types ++ functions.map ScalarFunctions.Definition.signature ∧
      ProcedureBindings.catalogSignatures final.procedures final.arrayNames.types =
        ProcedureBindings.catalogSignatures state.procedures state.arrayNames.types ++ procedures.map ScalarProcedures.Definition.signature := by
  induction source with
  | done => exact ⟨trivial, trivial, (List.append_nil _).symm, (List.append_nil _).symm⟩
  | @next token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures head first _ ih =>
    have checked := first.checked textValid valid known
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    have following := ih nextValid (first.callableTypesKnown textValid valid known)
    have firstProceduresChecked := ScalarProcedures.definitionsChecked_functions_append
      checked.2.1 (restFunctions.map ScalarFunctions.Definition.signature)
    rw [← following.2.2.1] at firstProceduresChecked
    have restFunctionsChecked := following.1
    rw [checked.2.2.1] at restFunctionsChecked
    have restProceduresChecked := following.2.1
    rw [checked.2.2.2] at restProceduresChecked
    refine ⟨checked.1.append restFunctionsChecked,
      firstProceduresChecked.append restProceduresChecked, ?_, ?_⟩
    · rw [following.2.2.1, checked.2.2.1]
      simp only [List.map_append, List.append_assoc]
    · rw [following.2.2.2, checked.2.2.2]
      simp only [List.map_append, List.append_assoc]

end Silver.Sequence
