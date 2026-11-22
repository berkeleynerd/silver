module

public import Silver.FunctionDeclarationsTrace
public import Silver.SequenceSubtypeReady

@[expose] public section

namespace Silver.ScalarFunctions

theorem DefinitionsChecked.append {earlier first rest}
    (checked : DefinitionsChecked earlier first)
    (following : DefinitionsChecked (earlier ++ first.map Definition.signature) rest) :
    DefinitionsChecked earlier (first ++ rest) := by
  induction first generalizing earlier with
  | nil => simpa only [List.nil_append, List.map_nil, List.append_nil] using following
  | cons definition definitions ih =>
    refine ⟨checked.1, ih checked.2 ?_⟩
    simpa only [List.map_cons, List.append_assoc, List.singleton_append] using following

end Silver.ScalarFunctions

namespace Silver.Sequence
open Compose ScalarFunctions Silver.Compose.Expressions Predicate

inductive FunctionStepAt (text : Source) (form : Compose.Form) :
    ShellToken → ParserState → List Definition → ParserState → Prop
  | declarations {state next definitions} : FunctionDeclarationsAt text form.hasArguments state definitions next →
      FunctionStepAt text form .declarations state definitions next
  | other {token state next} : token ≠ ShellToken.declarations → next.functions = state.functions →
      next.procedures = state.procedures → next.arrayNames.types = state.arrayNames.types →
      FunctionStepAt text form token state [] next

theorem step_function_trace {text form token state next event}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : StepAt text form token state next event) :
    ∃ definitions, FunctionStepAt text form token state definitions next := by
  by_cases declaration : token = .declarations
  · subst token
    have equation : declarationsAt text state form.hasArguments = next := by
      simpa only [step, parsed.positive, ↓reduceIte] using parsed.scanned
    obtain ⟨definitions, source⟩ := functionDeclarations_source textValid valid
      (by rw [equation]; exact parsed.following)
    rw [equation] at source
    exact ⟨definitions, .declarations source⟩
  · exact ⟨[], .other declaration (step_functions_preserved declaration parsed)
      (step_procedures_preserved declaration parsed)
      (by rw [step_arrayNames_preserved declaration parsed])⟩

theorem FunctionStepAt.callableTypesKnown {text form token state definitions next}
    (source : FunctionStepAt text form token state definitions next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    CallableTypesKnown next := by
  cases source with
  | declarations source => exact source.callableTypesKnown textValid valid known
  | other _ functions procedures types =>
      constructor
      · simpa only [functions, types] using known.functions
      · simpa only [procedures, types] using known.procedures

theorem FunctionStepAt.checked {text form token state definitions next}
    (source : FunctionStepAt text form token state definitions next)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) definitions ∧
      catalogSignatures next.functions next.arrayNames.types = catalogSignatures state.functions state.arrayNames.types ++ definitions.map Definition.signature := by
  cases source with
  | declarations source => exact source.checked textValid valid known
  | other _ same _ types => exact ⟨trivial, by simp only [same, types, List.map_nil, List.append_nil]⟩

theorem FunctionStepAt.unique {text form token state left right next}
    (a : FunctionStepAt text form token state left next)
    (b : FunctionStepAt text form token state right next) : left = right := by
  cases a with
  | declarations source =>
    cases b with
    | declarations other => exact source.unique other
    | other impossible => exact False.elim (impossible rfl)
  | other ordinary =>
    cases b with
    | declarations => exact False.elim (ordinary rfl)
    | other => rfl

inductive FunctionTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List Definition → ParserState → Prop
  | done {state} : FunctionTokensAt text form [] state [] state
  | next {token tokens state middle final event first rest} :
      StepAt text form token state middle event → FunctionStepAt text form token state first middle →
      FunctionTokensAt text form tokens middle rest final →
      FunctionTokensAt text form (token :: tokens) state (first ++ rest) final

theorem tokens_function_trace {text form tokens state events final}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : TokensAt text form tokens state events final) :
    ∃ definitions, FunctionTokensAt text form tokens state definitions final := by
  induction parsed with
  | done => exact ⟨[], .done⟩
  | @next token tokens state next final event events head _ ih =>
    obtain ⟨first, source⟩ := step_function_trace textValid valid head
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    obtain ⟨rest, following⟩ := ih nextValid
    exact ⟨first ++ rest, .next head source following⟩

theorem FunctionTokensAt.callableTypesKnown {text form tokens state definitions final}
    (source : FunctionTokensAt text form tokens state definitions final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    CallableTypesKnown final := by
  induction source with
  | done => exact known
  | @next token tokens state middle final event firstDefinitions restDefinitions head first _ ih =>
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    exact ih nextValid (first.callableTypesKnown textValid valid known)

theorem FunctionTokensAt.checked {text form tokens state definitions final}
    (source : FunctionTokensAt text form tokens state definitions final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) definitions ∧
      catalogSignatures final.functions final.arrayNames.types = catalogSignatures state.functions state.arrayNames.types ++ definitions.map Definition.signature := by
  induction source with
  | done => exact ⟨trivial, (List.append_nil _).symm⟩
  | @next token tokens state middle final event firstDefinitions restDefinitions head first _ ih =>
    have checked := first.checked textValid valid known
    have nextValid := model_step_valid text textValid form token state valid
    rw [head.scanned] at nextValid
    have following := ih nextValid (first.callableTypesKnown textValid valid known)
    rw [checked.2] at following
    exact ⟨checked.1.append following.1,
      by simpa only [List.map_append, List.append_assoc] using following.2⟩

theorem FunctionTokensAt.unique {text form tokens state left right leftState rightState}
    (a : FunctionTokensAt text form tokens state left leftState)
    (b : FunctionTokensAt text form tokens state right rightState) : left = right ∧ leftState = rightState := by
  induction a generalizing right rightState with
  | done => cases b; exact ⟨rfl, rfl⟩
  | next head source _ ih =>
    cases b with
    | next other otherSource otherRest =>
      have same := head.scanned.symm.trans other.scanned
      cases same
      have first := source.unique otherSource
      obtain ⟨rfl, rfl⟩ := ih otherRest
      exact ⟨by rw [first], rfl⟩

end Silver.Sequence
