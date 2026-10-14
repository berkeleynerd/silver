module

public import Silver.ComposeSourceChecks
public import Silver.ComposeEvaluation

@[expose] public section

/-! Exact-source interpretation for the shared declaration and expression
helpers. The current statement recognizer composes these helpers in its own
source bridge. No former fixed-shell membership is attributed to current Ada. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge
open Silver.Compose.Expressions

structure CheckedSource : Prop where
  inherited : Lexical.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  catalogue : HelperCatalogueTranslation
  declarations : Declarations
  refinement : Refinement
  adapters : AdapterTranslation
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
  arrayLength := Expressions.ArrayNames.active_length
  arrayLookup := Expressions.ArrayNames.active_get
  arrayExtension := Expressions.ArrayNames.extend_active

def NativeForm (form : Form) : Prop := form ∈ helperForms

/-- Helper definitions and executed lexical-call domains, with Step restricted
to the two shell tags actually declared by the native implementation. -/
structure InterpretedSource (calls : Expressions.Calls) : Prop where
  lexical : ∃ (helpers : Guarded.Expressions.Calls)
      (token : Source → Nat → String → Bool → Bool),
    calls.primitive = Lexical.primitives helpers token ∧
      Lexical.InterpretedSource helpers token
  definitions : Expressions.HelperEquations calls calls
  legal : Expressions.LegalHelpers calls
  step : ∀ text, Expressions.ValidText text → ∀ form token state,
    NativeForm form → Expressions.ValidToken token → Expressions.ValidState text state →
    calls.function .step text form token state =
      Expressions.stepBody.eval calls (Expressions.Context.locals {text,form,token,state})
  stepLegal : ∀ text, Expressions.ValidText text → ∀ form token state,
    NativeForm form → Expressions.ValidToken token → Expressions.ValidState text state →
    Expressions.stepBody.Legal calls (Expressions.Context.locals {text,form,token,state})

theorem interpreted_primitives (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Lexical.Meaning calls.primitive := by
  obtain ⟨helpers, token, same, interpreted⟩ := source.lexical
  rw [same]
  exact Lexical.interpreted_primitives helpers token interpreted

theorem interpreted_equations (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Expressions.HelperEquations calls :=
  Expressions.normalized_helpers calls (interpreted_primitives calls source)
    source.definitions source.legal

theorem interpreted_step (calls : Expressions.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Expressions.ValidText text) (form : Form) (token : ShellToken)
    (state : ParserState) (native : NativeForm form)
    (tokenValid : Expressions.ValidToken token) (context : Expressions.ValidState text state) :
    calls.function .step text form token state = step text form token state := by
  let equations := interpreted_equations calls source
  have normalized := Expressions.Expr.eval_lexical calls (interpreted_primitives calls source)
    (Expressions.Context.locals {text,form,token,state}) Expressions.stepBody
    (source.stepLegal text valid form token state native tokenValid context)
  rw [source.step text valid form token state native tokenValid context, normalized]
  have argument := interpreted_argument calls equations text valid state context
  have declarations := interpreted_declarations calls equations text valid state form.hasArguments context
  have read := (equations.readDeclarations text valid state form.hasArguments context).trans declarations
  have target := interpreted_target calls equations text valid state false context
  have targetSame := interpreted_target calls equations text valid state true context
  have dynamic := interpreted_dynamic calls equations text valid state context
  have assignment := interpreted_assignmentValue calls equations text valid state context
  have output := interpreted_output calls equations text valid state context
  have comparison := interpreted_comparison calls equations text valid state context
  have capacity := interpreted_capacity calls equations text valid state context
  have skipped := interpreted_skip calls equations text valid state.position context.1
  have skipDomain := equations.ranges.skip text valid state.position context.1
  rw [skipped] at skipDomain
  have literal := interpreted_literal calls equations text valid (skipAt text state.position) skipDomain
  have taken := interpreted_take calls equations text valid state.position token context.1 tokenValid
  dsimp +instances only [stepBody, Expr.eval, Calls.get, Field.get, Context.locals, lexical, modelPrimitives]
  rw [skipped, literal, argument, read, target, targetSame, dynamic, assignment, output, comparison, capacity, taken]
  cases token <;> simp +instances [step, spelling, isWord, BEq.beq]

end Silver.Compose.SourceBridge
