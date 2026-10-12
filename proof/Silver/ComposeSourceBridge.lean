module

public import Silver.ComposeSourceChecks
public import Silver.ComposeEvaluation
public import Silver.ComposeRecognitionEquations
public import Silver.Current

@[expose] public section

/-! Exact-source interpretation for the ordered binding recognizer. Typed
expression trees interpret locals, record/array updates, calls and recursion.
Native SPARK contracts refine imperative adapters to those checked equations.
Complete source-shape pins accompany these proofs; they do not replace them. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

structure CheckedSource : Prop where
  inherited : Lexical.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  catalogue : CatalogueTranslation
  declarations : Declarations
  refinement : Refinement
  adapters : AdapterTranslation
  mainTranslation : ∀ form, (Main.composition form).render = form.tokens
  arrayLength : ∀ names : Expressions.ArrayNames, names.active.length = names.count
  arrayLookup : ∀ (names : Expressions.ArrayNames) index, 0 < index → index ≤ names.count →
    names.active.get index = some (names.items index)
  arrayExtension : ∀ (names : Expressions.ArrayNames) info,
    (names.extend info).active = names.active ++ [info]

theorem checked_source : CheckedSource where
  inherited := Lexical.SourceBridge.checked_source
  expressions := actual_expressions
  catalogue := actual_catalogue
  declarations := actual_declarations
  refinement := actual_refinement
  adapters := actual_adapters
  mainTranslation := Main.rendered_tokens
  arrayLength := Expressions.ArrayNames.active_length
  arrayLookup := Expressions.ArrayNames.active_get
  arrayExtension := Expressions.ArrayNames.extend_active

theorem authoritative_main_correct {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) (arguments : Arguments.Runtime.Arguments) :
    CheckedSource ∧ ∃ program, decode form events = some program ∧
      Parsed source form (Main.composition form).render initialState events ∧
      Bindings.DeclarationsValid Bindings.emptyShape program.declarations program.names.shape ∧
      Bindings.Fits program.names.shape (selected program.fallback arguments)
        (program.initialValues arguments) ∧
      (Main.composition form).execute events arguments = some (program.action arguments) := by
  obtain ⟨program, decoded, valid⟩ := decoded_valid meaning
  exact ⟨checked_source, program, decoded, by simpa [Main.rendered_tokens] using meaning.2.2,
    valid.1, initial_values_fit valid arguments, Main.execution_refines decoded valid arguments⟩

/-- Source equations name actual helper calls and checked imperative
refinements. LegalBodies contains only executed lexical-call domains. -/
structure InterpretedSource (calls : Expressions.Calls) : Prop where
  lexical : ∃ (helpers : Guarded.Expressions.Calls)
      (token : Source → Nat → String → Bool → Bool),
    calls.primitive = Lexical.primitives helpers token ∧
      Lexical.InterpretedSource helpers token
  definitions : Expressions.DefinitionEquations calls calls
  legal : Expressions.LegalBodies calls

theorem interpreted_equations (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Expressions.DefinitionEquations calls := by
  obtain ⟨helpers, token, same, interpreted⟩ := source.lexical
  have meaning : Lexical.Meaning calls.primitive := by
    rw [same]
    exact Lexical.interpreted_primitives helpers token interpreted
  exact Expressions.normalized_definitions calls meaning source.definitions source.legal

structure ExecutableRefinement (calls : Expressions.Calls)
    (accepts usesArguments usesAssignment : Source → Bool) : Prop where
  admission : ∀ source, accepts source = calls.function .member source
  arguments : ∀ source, usesArguments source = calls.function .arguments source
  assignment : ∀ source, usesAssignment source = calls.function .assignment source

theorem authoritative_source_member_iff (calls : Expressions.Calls)
    (sourceEquations : InterpretedSource calls)
    (accepts usesArguments usesAssignment : Source → Bool)
    (proved : ExecutableRefinement calls accepts usesArguments usesAssignment)
    (source : Source) :
    CheckedSource ∧ (accepts source = true ↔ Member source) := by
  refine ⟨checked_source, ?_⟩
  rw [proved.admission, Expressions.interpreted_member calls (interpreted_equations calls sourceEquations)]
  exact accepts_iff_member source

/-- Both report-routing bits select exactly the first accepted form. Together
these distinguish static, argument, assigned and selected-result policies. -/
theorem authoritative_selectors (calls : Expressions.Calls)
    (sourceEquations : InterpretedSource calls)
    (accepts usesArguments usesAssignment : Source → Bool)
    (proved : ExecutableRefinement calls accepts usesArguments usesAssignment)
    {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    CheckedSource ∧ usesArguments source = form.hasArguments ∧
      usesAssignment source = form.hasAssignment := by
  refine ⟨checked_source, ?_, ?_⟩
  · rw [proved.arguments, Expressions.interpreted_arguments calls (interpreted_equations calls sourceEquations)]
    exact meaning_argument_selector meaning
  · rw [proved.assignment, Expressions.interpreted_assignment calls (interpreted_equations calls sourceEquations)]
    exact meaning_assignment_selector meaning

/-- Union the independently interpreted null and output recognizers. No
sample enumeration participates in whole-language membership. -/
theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : InterpretedSource calls)
    (source : Source) : CheckedSource ∧
      ((nullCalls.member source || calls.function .member source) = true ↔ Current.Member source) := by
  refine ⟨checked_source, ?_⟩
  simp only [Bool.or_eq_true, Current.Member]
  rw [Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    Expressions.interpreted_member calls (interpreted_equations calls sourceEquations), accepts_iff_member]

/-- The actual-source recognizers entail pipeline completion under the explicit
external tool contract, which includes complete generation, pinned-fragment
solver completion and faithful build/runtime semantics. -/
theorem checked_membership_supported_pipeline {Artifact : Type}
    {tools : Current.Tools Artifact} (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : InterpretedSource calls)
    (source : Source) (accepted : (nullCalls.member source || calls.function .member source) = true) :
    CheckedSource ∧ ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  exact ⟨checked_source, Current.automatic_pipeline contract
    ((authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source).2.mp accepted)⟩

end Silver.Compose.SourceBridge
