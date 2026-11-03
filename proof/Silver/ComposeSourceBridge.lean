module

public import Silver.ComposeSourceChecks
public import Silver.ComposeEquations
public import Silver.LexicalSourceBridge
public import Silver.NamesSourceBridge
public import Silver.ScalarExpressionSourceBridge
public import Silver.ComposeEvaluation
public import Silver.IntegerImageNativeSource
public import Silver.ComposeBooleanDeclarationLibraries

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
  imageLengths : Integer.Image.NativeSource.CheckedSource
  scalarExpressions : ScalarExpression.SourceChecks.CheckedSource
  names : Names.SourceBridge.CheckedSource
  namesLexical : Names.fixedAt = Compose.fixedAt ∧ Names.take = Compose.fixedAfter
  inherited : Lexical.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  stringHelpers : StringHelperTranslation
  arrayHelpers : ArrayHelperTranslation
  booleanDeclaration : BooleanDeclarationNative.SourceChecks.Checked Source.outputBodyTokens
  catalogue : HelperCatalogueTranslation
  tokens : TokenMapping
  declarations : Declarations
  refinement : Refinement
  adapters : AdapterTranslation
  arrayLength : ∀ names : Expressions.ArrayNames, names.active.length = names.count
  arrayLookup : ∀ (names : Expressions.ArrayNames) index, 0 < index → index ≤ names.count →
    names.active.get index = some (names.items index)
  arrayExtension : ∀ (names : Expressions.ArrayNames) info,
    (names.extend info).active = names.active ++ [info]

theorem checked_source : CheckedSource where
  imageLengths := Integer.Image.NativeSource.checked_source
  scalarExpressions := ScalarExpression.SourceChecks.checked_source
  names := Names.SourceBridge.checked_source
  namesLexical := ⟨rfl, rfl⟩
  inherited := Lexical.SourceBridge.checked_source
  expressions := actual_expressions
  stringHelpers := actual_string_helpers
  arrayHelpers := actual_array_helpers
  booleanDeclaration := actual_boolean_declaration
  catalogue := actual_catalogue
  tokens := finite_mapping
  declarations := actual_declarations
  refinement := actual_refinement
  adapters := actual_adapters
  arrayLength := Expressions.ArrayNames.active_length
  arrayLookup := Expressions.ArrayNames.active_get
  arrayExtension := Expressions.ArrayNames.extend_active

def NativeForm (form : Form) : Prop := form ∈ helperForms

/-- Interpretation of the ordinary Boolean declaration function and its
native callees. Predicate meaning is derived from typed equations and verified
contracts; no field assumes either scanner's equivalence to admission. -/
structure BooleanDeclarationInterpretation (calls : Expressions.Calls) : Prop where
  source : ∃ (imports : BooleanDeclarationNative.Imports) (predicate : Predicate.Native.Calls),
    Predicate.Native.HelperMeaning predicate ∧
    Predicate.Native.DefinitionEquations predicate ∧ Predicate.Native.Contracts predicate ∧
    BooleanDeclarationNative.Libraries.Links imports calls predicate ∧
    ∀ text, Expressions.ValidText text → ∀ state arguments,
      Predicate.OuterReadiness.ValidState text state →
      calls.function .booleanDeclaration text state arguments =
        BooleanDeclarationNative.body.eval imports {text, state, arguments}

/-- Helper definitions and executed lexical-call domains, with Step restricted
to the two shell tags actually declared by the native implementation. -/
structure InterpretedSource (calls : Expressions.Calls) : Prop where
  imageLengths : ∃ (imageCalls : Integer.Image.Native.Calls) (scalarCalls : Integer.Native.Calls),
    Integer.Image.NativeSource.InterpretedSource imageCalls scalarCalls ∧
      ∀ bounds, bounds.Bounded →
        calls.function .imageMinimum bounds = imageCalls.minimumLength bounds ∧
        calls.function .imageMaximum bounds = imageCalls.maximumLength bounds
  lexical : ∃ (helpers : Guarded.Expressions.Calls)
      (token : Source → Nat → String → Bool → Bool),
    calls.primitive = Lexical.primitives helpers token ∧
      Lexical.InterpretedSource helpers token
  definitions : Expressions.RawHelperEquations calls calls Predicate.OuterReadiness.domain
  booleanDeclaration : BooleanDeclarationInterpretation calls
  legal : Expressions.LegalHelpers calls Predicate.OuterReadiness.domain
  step : ∀ text, Expressions.ValidText text → ∀ form token state,
    NativeForm form → Expressions.ValidToken token → Predicate.OuterReadiness.ValidState text state →
    calls.function .step text form token state =
      Expressions.stepBody.eval calls (Expressions.Context.locals {text,form,token,state})
  stepLegal : ∀ text, Expressions.ValidText text → ∀ form token state,
    NativeForm form → Expressions.ValidToken token → Predicate.OuterReadiness.ValidState text state →
    Expressions.stepBody.Legal calls (Expressions.Context.locals {text,form,token,state})

theorem interpreted_primitives (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Lexical.Meaning calls.primitive := by
  obtain ⟨helpers, token, same, interpreted⟩ := source.lexical
  rw [same]
  exact Lexical.interpreted_primitives helpers token interpreted

theorem interpreted_equations (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Expressions.HelperEquations calls (domain := Predicate.OuterReadiness.domain) := by
  obtain ⟨imageCalls, scalarCalls, imageSource, linked⟩ := source.imageLengths
  have minimum : ∀ bounds, bounds.Bounded →
      calls.function .imageMinimum bounds = (LengthSummary.ofImage bounds).minimumLength := by
    intro bounds bounded
    rw [(linked bounds bounded).1,
      Integer.Image.NativeSource.minimumLength_eq imageCalls scalarCalls imageSource bounds bounded]
    unfold LengthSummary.ofImage
    split <;> rfl
  have maximum : ∀ bounds, bounds.Bounded →
      calls.function .imageMaximum bounds = (LengthSummary.ofImage bounds).staticLength := by
    intro bounds bounded
    rw [(linked bounds bounded).2,
      Integer.Image.NativeSource.maximumLength_eq imageCalls scalarCalls imageSource bounds bounded]
    unfold LengthSummary.ofImage
    split <;> rfl
  let raw := Expressions.normalized_rawHelpers calls (interpreted_primitives calls source)
    {source.definitions with imageMinimum := minimum, imageMaximum := maximum} source.legal
  refine { toRawHelperEquations := raw, booleanDeclaration := ?_ }
  obtain ⟨imports, predicate, helpers, definitions, contracts, links, equation⟩ :=
    source.booleanDeclaration.source
  intro text valid state arguments ready
  exact (equation text valid state arguments ready).trans
    (BooleanDeclarationNative.imports_meaning imports text state arguments
      (BooleanDeclarationNative.Libraries.imports_meaning raw helpers definitions contracts links
        text valid state arguments ready))

theorem interpreted_step (calls : Expressions.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Expressions.ValidText text) (form : Form) (token : ShellToken)
    (state : ParserState) (native : NativeForm form)
    (tokenValid : Expressions.ValidToken token) (context : Predicate.OuterReadiness.ValidState text state) :
    calls.function .step text form token state = step text form token state := by
  let equations := interpreted_equations calls source
  have normalized := Expressions.Expr.eval_lexical calls (interpreted_primitives calls source)
    (Expressions.Context.locals {text,form,token,state}) Expressions.stepBody
    (source.stepLegal text valid form token state native tokenValid context)
  rw [source.step text valid form token state native tokenValid context, normalized]
  have contextAfter := Names.interpreted_context calls.names equations.names text valid form.hasArguments
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
  have skipped := interpreted_skip calls equations.toRawHelperEquations text valid state.position context.1.1
  have skipDomain := equations.ranges.skip text valid state.position context.1.1
  rw [skipped] at skipDomain
  have literal := interpreted_literal calls equations.toRawHelperEquations text valid (skipAt text state.position) skipDomain
  have taken := interpreted_take calls equations.toRawHelperEquations text valid state.position token context.1.1 tokenValid
  dsimp +instances only [stepBody, Expr.eval, Calls.get, Field.get, Context.locals, lexical, modelPrimitives]
  rw [skipped, literal, argument, read, target, targetSame, dynamic, assignment, output, comparison, capacity, taken, contextAfter]
  cases token <;> simp +instances [step, spelling, isWord, BEq.beq]

end Silver.Compose.SourceBridge
