module

public import Silver.ApplicationPackageOriginalScalarHeaders
public import Silver.PredicateGrammar

@[expose] public section

/-! The standalone source shell retains raw inline Integer constraints as well
as normalized declarations. Each inventory follows the complete original token
history, including unused local callables and each declaration's array scope.
Its source relation has no added checker or discharge premise. -/
namespace Silver.Predicate.ScalarHeaders
open Compose ApplicationPackageScalarHeaders

inductive TopTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List Integer.Declaration → ParserState → List Header → Prop
  | done {state} : TopTokensAt text form [] state [] state []
  | declarations {tokens state middle final event first rest front headers} :
      StepAt text form .declarations state middle event →
      TopHeadersAt text form.hasArguments state first middle front →
      TopTokensAt text form tokens middle rest final headers →
      TopTokensAt text form (.declarations :: tokens) state (first ++ rest) final (front ++ headers)
  | other {token tokens state middle final event rest headers} :
      StepAt text form token state middle event →
      token ≠ .declarations → middle.scalarNames = state.scalarNames →
      TopTokensAt text form tokens middle rest final headers →
      TopTokensAt text form (token :: tokens) state rest final headers

theorem top_tokens {text form tokens state declarations final}
    (source : Sequence.ScalarTokensAt text form tokens state declarations final) :
    ∃ headers, TopTokensAt text form tokens state declarations final headers ∧
      Integer.discharged (obligations headers) = true := by
  induction source with
  | done => exact ⟨[], .done, rfl⟩
  | next head first _ ih =>
    obtain ⟨headers, sourceAt, checked⟩ := ih
    cases first with
    | declarations reading =>
      obtain ⟨front, firstSource, firstChecked⟩ := top_headers reading
      refine ⟨front ++ headers, .declarations head firstSource sourceAt, ?_⟩
      simp only [obligations_append, Integer.discharged_append, firstChecked, checked, Bool.and_self]
    | other ordinary same =>
      exact ⟨headers, .other head ordinary same sourceAt, checked⟩

inductive CallableTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List ScalarFunctions.Definition →
      List ScalarProcedures.Definition → ParserState → List Header → Prop
  | done {state} : CallableTokensAt text form [] state [] [] state []
  | declarations {tokens state middle final event firstFunctions firstProcedures
      restFunctions restProcedures front headers} :
      StepAt text form .declarations state middle event →
      CallableHeadersAt text form.hasArguments state firstFunctions firstProcedures middle front →
      CallableTokensAt text form tokens middle restFunctions restProcedures final headers →
      CallableTokensAt text form (.declarations :: tokens) state
        (firstFunctions ++ restFunctions) (firstProcedures ++ restProcedures) final (front ++ headers)
  | other {token tokens state middle final event functions procedures headers} :
      StepAt text form token state middle event → token ≠ .declarations →
      middle.functions = state.functions → middle.procedures = state.procedures →
      middle.arrayNames.types = state.arrayNames.types →
      CallableTokensAt text form tokens middle functions procedures final headers →
      CallableTokensAt text form (token :: tokens) state functions procedures final headers

theorem callable_tokens {text form tokens state functions procedures final}
    (source : Sequence.MixedTokensAt text form tokens state functions procedures final) :
    ∃ headers, CallableTokensAt text form tokens state functions procedures final headers ∧
      Integer.discharged (obligations headers) = true := by
  induction source with
  | done => exact ⟨[], .done, rfl⟩
  | next head first _ ih =>
    obtain ⟨headers, sourceAt, checked⟩ := ih
    cases first with
    | declarations reading =>
      obtain ⟨front, firstSource, firstChecked⟩ := callable_headers reading
      refine ⟨front ++ headers, .declarations head firstSource sourceAt, ?_⟩
      simp only [obligations_append, Integer.discharged_append, firstChecked, checked, Bool.and_self]
    | other ordinary functions procedures types =>
      exact ⟨headers, .other head ordinary functions procedures types sourceAt, checked⟩

structure Inventory where
  top : List Header
  callables : List Header

/-- The two complete projections share the selected original shell and its
initial/final parser states. Neither projection assumes obligation success. -/
def Inventory.SourceAt (inventory : Inventory) (text : Source) (program : Program) : Prop :=
  ∃ form, selectedForm text = some form ∧
    TopTokensAt text form.helper form.prefix initialState program.integerDeclarations
      (prefixScan text form).state inventory.top ∧
    CallableTokensAt text form.helper form.prefix initialState program.functions program.procedures
      (prefixScan text form).state inventory.callables

def Inventory.obligations (inventory : Inventory) : List Integer.Obligation :=
  ApplicationPackageScalarHeaders.obligations inventory.top ++
    ApplicationPackageScalarHeaders.obligations inventory.callables

theorem source_inventory {text : Source} {program : Program}
    (meaning : SourceMeaning text program) :
    ∃ inventory : Inventory, inventory.SourceAt text program ∧
      Integer.discharged inventory.obligations = true := by
  obtain ⟨form, events, items, scalars, checks, booleans, booleanChecks, _, selected,
    _, scalarTrace, _, _, functions, procedures, callableTrace, decoded⟩ := meaning
  obtain ⟨top, topSource, topChecks⟩ := top_tokens scalarTrace
  obtain ⟨callables, callableSource, callableChecks⟩ := callable_tokens callableTrace
  have integers : program.integerDeclarations = scalars := by
    unfold decodePrefix at decoded
    split at decoded <;> cases decoded <;> rfl
  refine ⟨⟨top, callables⟩, ⟨form, selected, ?_, ?_⟩, ?_⟩
  · simpa only [integers] using topSource
  · simpa only [decoded_functions decoded, decoded_procedures decoded] using callableSource
  · simp only [Inventory.obligations, Integer.discharged_append, topChecks, callableChecks, Bool.and_self]

/-- A proof-level finite source inventory, selected from the universally proved
existence above. This is not a compiler operation or an admission condition;
the source relation and the derived checker fact are exposed separately below. -/
noncomputable def inventory (text : Source) (program : Program) : Inventory := by
  classical
  exact if meaning : SourceMeaning text program then Classical.choose (source_inventory meaning)
    else ⟨[], []⟩

theorem inventory_source {text : Source} {program : Program}
    (meaning : SourceMeaning text program) : (inventory text program).SourceAt text program := by
  classical
  simpa only [inventory, dite_eq_left meaning] using (Classical.choose_spec (source_inventory meaning)).1

theorem inventory_discharge {text : Source} {program : Program}
    (meaning : SourceMeaning text program) :
    Integer.discharged (inventory text program).obligations = true := by
  classical
  simpa only [inventory, dite_eq_left meaning] using (Classical.choose_spec (source_inventory meaning)).2

noncomputable def checks (text : Source) (program : Program) : List Check :=
  (inventory text program).obligations.map .scalarDeclaration

theorem checks_fragment {text : Source} {program : Program}
    (meaning : SourceMeaning text program) : ∀ check ∈ checks text program, check.InFragment := by
  intro check member
  obtain ⟨obligation, present, rfl⟩ := List.mem_map.mp member
  exact List.all_eq_true.mp (inventory_discharge meaning) obligation present

end Silver.Predicate.ScalarHeaders
