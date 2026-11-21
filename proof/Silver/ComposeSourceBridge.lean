module

public import Silver.ComposeSourceChecks
public import Silver.ComposeEquations
public import Silver.ComposeArrayImportMeaning
public import Silver.LexicalSourceBridge
public import Silver.NamesSourceBridge
public import Silver.ScalarExpressionSourceBridge
public import Silver.ComposeEvaluation
public import Silver.IntegerImageNativeSource
public import Silver.ComposeBooleanImportMeaning
public import Silver.FunctionDeclarationSourceBridge
public import Silver.ProcedureLookupMeaning
public import Silver.ProcedureDeclarationSourceBridge
public import Silver.ProcedureDeclarationHighSourceChecks
public import Silver.ProcedureDeclarationHelperSourceChecks

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
  arrayMetadata : ArrayBindings.SourceChecks.CheckedSource
  procedureMetadata : ProcedureBindings.SourceChecks.CheckedSource
  procedureDeclarations : ProcedureDeclarationNative.HighSourceChecks.Checked Source.outputBodyTokens
  procedureDeclarationHelpers : ProcedureDeclarationNative.HelperSourceChecks.Checked Source.outputBodyTokens
  imageLengths : Integer.Image.NativeSource.CheckedSource
  scalarExpressions : ScalarExpression.SourceChecks.CheckedSource
  names : Names.SourceBridge.CheckedSource
  namesLexical : Names.fixedAt = Compose.fixedAt ∧ Names.take = Compose.fixedAfter
  inherited : Lexical.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  stringHelpers : StringHelperTranslation
  arrayHelpers : ArrayHelperTranslation
  arrayTypeHelpers : ArrayTypeHelperTranslation
  booleanDeclaration : BooleanDeclarationNative.SourceChecks.Checked Source.outputBodyTokens
  booleanArrayHelpers : BooleanArraySource.Checked Source.outputBodyTokens
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
  arrayMetadata := ArrayBindings.SourceChecks.checked_source
  procedureMetadata := ProcedureBindings.SourceChecks.checked_source
  procedureDeclarations := Silver.ProcedureDeclarationHighSourceChecks.checked_source
  procedureDeclarationHelpers := Silver.ProcedureDeclarationHelperSourceChecks.checked_source
  imageLengths := Integer.Image.NativeSource.checked_source
  scalarExpressions := ScalarExpression.SourceChecks.checked_source
  names := Names.SourceBridge.checked_source
  namesLexical := ⟨rfl, rfl⟩
  inherited := Lexical.SourceBridge.checked_source
  expressions := actual_expressions
  stringHelpers := actual_string_helpers
  arrayHelpers := actual_array_helpers
  arrayTypeHelpers := actual_array_type_helpers
  booleanDeclaration := actual_boolean_declaration
  booleanArrayHelpers := actual_boolean_array_helpers
  catalogue := actual_catalogue
  tokens := finite_mapping
  declarations := actual_declarations
  refinement := actual_refinement
  adapters := actual_adapters
  arrayLength := Expressions.ArrayNames.active_length
  arrayLookup := Expressions.ArrayNames.active_get
  arrayExtension := Expressions.ArrayNames.extend_active

def NativeForm (form : Form) : Prop := form ∈ helperForms

/-- The ordinary function declaration reader is connected to its checked
native equations and directly linked callees. Its full scanner meaning is a
conclusion of that interpretation, not an assumed helper equation. -/
structure FunctionDeclarationInterpretation (calls : Expressions.Calls) : Prop where
  source : ∃ (native : FunctionDeclarationNative.Calls)
      (interpreted : FunctionDeclarationNative.InterpretedSource native),
    interpreted.inherited = calls ∧
      calls.function .functionDeclaration = native .functionDeclaration ∧
      calls.function .functionLookup = interpreted.metadata.lookup ∧
      calls.function .formalHides = interpreted.visibility.formalHides

/-- Procedure admission is interpreted from its native declaration tree and
the low helpers; the resulting whole-scanner equality is not an input. -/
structure ProcedureDeclarationInterpretation (calls : Expressions.Calls) : Prop where
  source : ∃ (native : ProcedureDeclarationNative.Calls)
      (interpreted : ProcedureDeclarationNative.InterpretedSource native),
    interpreted.helpers.ordinarySource.inherited = calls ∧
      calls.function .procedureDeclaration = native .procedureDeclaration

/-- Imported subprogram-library meanings are supplied only after
interpreting the directly linked metadata and visibility implementations. -/
structure FunctionImportMeaning (calls : Expressions.Calls) : Prop where
  lookup : ∀ text, Expressions.ValidText text → ∀ catalog first after,
    FunctionBindings.ValidMetadata text catalog → Expressions.ValidCursor text first →
    Expressions.ValidCursor text after →
    calls.function .functionLookup text catalog first after =
      FunctionBindings.lookup text catalog first after
  procedureLookup : ∀ text, Expressions.ValidText text → ∀ catalog first after,
    ProcedureBindings.ValidMetadata text catalog → Expressions.ValidCursor text first →
    Expressions.ValidCursor text after →
    calls.function .procedureLookup text catalog first after =
      ProcedureBindings.lookup text catalog first after
  hides : ∀ text, Expressions.ValidText text → ∀ state first after,
    Expressions.NativeState Predicate.OuterReadiness.domain text state →
    Expressions.ValidCursor text first → Expressions.ValidCursor text after →
    calls.function .formalHides text state first after = Compose.formalHides text state first after

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
  arrayImports : ArrayImportSource calls
  definitions : FunctionImportMeaning calls → ArrayImportMeaning calls →
    Expressions.RawHelperEquations calls calls Predicate.OuterReadiness.domain
  booleanDeclaration : BooleanDeclarationInterpretation calls
  booleanInitializer : BooleanInitializerInterpretation calls
  functionDeclaration : ArrayImportMeaning calls →
    (RawHelperEquations calls (domain := Predicate.OuterReadiness.domain) → BooleanDeclarationMeaning calls) →
    FunctionDeclarationInterpretation calls
  procedureDeclaration : ArrayImportMeaning calls →
    (RawHelperEquations calls (domain := Predicate.OuterReadiness.domain) → BooleanDeclarationMeaning calls) →
    ProcedureDeclarationInterpretation calls
  procedureMetadata : ∃ metadata : ProcedureBindings.Native.Calls,
    ProcedureBindings.SourceBridge.InterpretedSource metadata ∧
      calls.function .procedureLookup = metadata.lookup
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

/-- Nested callable readers consume the same derived imports as their outer
Compose caller. Only proof fields change; native calls, direct identities and
the exact inherited state domain are retained. -/
private def inherited_import_source {native : FunctionDeclarationNative.Calls}
    (source : FunctionDeclarationNative.InterpretedSource native)
    (imports : ArrayImportMeaning source.inherited)
    (booleans : BooleanDeclarationMeaning source.inherited) :
    FunctionDeclarationNative.InterpretedSource native :=
  {source with inheritedSource :=
    {source.inheritedSource with
      toRawHelperEquations := imports.raw source.inheritedSource.toRawHelperEquations
      booleanDeclaration := by
        intro text tv state arguments ready
        let native := (source.exactDomain.state text state).mp ready.base
        exact booleans text tv state arguments ⟨native.base, native.ready, native.bounds⟩}}

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
  have arrayImports := source.arrayImports.meaning
  let booleanDeclaration : RawHelperEquations calls (domain := Predicate.OuterReadiness.domain) →
      BooleanDeclarationMeaning calls := source.booleanDeclaration.meaning
  obtain ⟨native, originalFunctionSource, inheritedLink, declarationLink, lookupLink, hidesLink⟩ :=
    (source.functionDeclaration arrayImports booleanDeclaration).source
  have inheritedImports : ArrayImportMeaning originalFunctionSource.inherited := by
    rw [inheritedLink]
    exact arrayImports
  have procedureLookup : ∀ text, Expressions.ValidText text → ∀ catalog first after,
      ProcedureBindings.ValidMetadata text catalog → Expressions.ValidCursor text first →
      Expressions.ValidCursor text after →
      calls.function .procedureLookup text catalog first after =
        ProcedureBindings.lookup text catalog first after := by
    obtain ⟨metadata, interpreted, linked⟩ := source.procedureMetadata
    exact Expressions.procedure_lookup_meaning calls metadata interpreted linked
  have lookup : ∀ text, Expressions.ValidText text → ∀ catalog first after,
      FunctionBindings.ValidMetadata text catalog → Expressions.ValidCursor text first →
      Expressions.ValidCursor text after →
      calls.function .functionLookup text catalog first after =
        FunctionBindings.lookup text catalog first after := by
    intro text valid catalog first after metadata firstBound afterBound
    rw [lookupLink]
    exact (FunctionBindings.SourceBridge.interpreted_complete originalFunctionSource.metadata
      originalFunctionSource.metadataSource).lookup text valid catalog metadata first after firstBound afterBound
  have hides : ∀ text, Expressions.ValidText text → ∀ state first after,
      Expressions.NativeState Predicate.OuterReadiness.domain text state →
      Expressions.ValidCursor text first → Expressions.ValidCursor text after →
      calls.function .formalHides text state first after = Compose.formalHides text state first after := by
    intro text valid state first after ready firstBound afterBound
    rw [hidesLink]
    exact FunctionVisibilityNative.formalHides_meaning originalFunctionSource.visibility
      originalFunctionSource.visibilityPrimitives originalFunctionSource.visibilityEquations text valid state
      ⟨ready.valid, ready.base.ready, ready.bounds⟩ first after firstBound afterBound
  let raw := Expressions.normalized_rawHelpers calls (interpreted_primitives calls source)
    {arrayImports.raw (source.definitions ⟨lookup, procedureLookup, hides⟩ arrayImports) with
      imageMinimum := minimum
      imageMaximum := maximum
      functionLookup := lookup
      procedureLookup := procedureLookup
      formalHides := hides} source.legal
  have booleanMeaning := booleanDeclaration raw
  have inheritedBooleans : BooleanDeclarationMeaning originalFunctionSource.inherited := by
    rw [inheritedLink]
    exact booleanMeaning
  let functionSource := inherited_import_source originalFunctionSource inheritedImports inheritedBooleans
  exact {
    toRawHelperEquations := raw
    booleanDeclaration text tv state arguments ready :=
      booleanMeaning text tv state arguments ready.base
    functionDeclaration := by
      intro text valid state arguments ready
      rw [declarationLink]
      exact FunctionDeclarationNative.interpreted_native_declaration functionSource text valid
        state arguments ⟨ready.valid, ready.base.ready, ready.bounds⟩
    procedureDeclaration := by
      obtain ⟨native, originalProcedureSource, inheritedLink, declarationLink⟩ :=
        (source.procedureDeclaration arrayImports booleanDeclaration).source
      have inheritedImports : ArrayImportMeaning originalProcedureSource.helpers.ordinarySource.inherited := by
        rw [inheritedLink]
        exact arrayImports
      have inheritedBooleans : BooleanDeclarationMeaning originalProcedureSource.helpers.ordinarySource.inherited := by
        rw [inheritedLink]
        exact booleanMeaning
      let procedureSource : ProcedureDeclarationNative.InterpretedSource native :=
        {originalProcedureSource with
          helpers :=
            {originalProcedureSource.helpers with
              ordinarySource := inherited_import_source originalProcedureSource.helpers.ordinarySource
                inheritedImports inheritedBooleans}}
      intro text valid state arguments ready
      rw [declarationLink]
      exact ProcedureDeclarationNative.interpreted_native_declaration procedureSource text valid
        state arguments ⟨ready.valid, ready.base.ready, ready.bounds⟩
    booleanInitializer text tv state position first after ready bounded mask :=
      source.booleanInitializer.meaning raw text tv state position first after ready.base bounded mask }

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
  have nativeContext := context.nativeState
  have contextAfter := Names.interpreted_context calls.names equations.names text valid form.hasArguments
  have argument := interpreted_argument calls equations text valid state nativeContext
  have declarations := interpreted_declarations calls equations text valid state form.hasArguments nativeContext
  have read := (equations.readDeclarations text valid state form.hasArguments nativeContext).trans declarations
  have target := interpreted_target calls equations text valid state false nativeContext
  have targetSame := interpreted_target calls equations text valid state true nativeContext
  have dynamic := interpreted_dynamic calls equations text valid state nativeContext
  have assignment := interpreted_assignmentValue calls equations text valid state nativeContext
  have output := interpreted_output calls equations text valid state nativeContext
  have comparison := interpreted_comparison calls equations text valid state nativeContext
  have capacity := interpreted_capacity calls equations text valid state nativeContext
  have skipped := interpreted_skip calls equations.toRawHelperEquations text valid state.position context.1.1
  have skipDomain := equations.ranges.skip text valid state.position context.1.1
  rw [skipped] at skipDomain
  have literal := interpreted_literal calls equations.toRawHelperEquations text valid (skipAt text state.position) skipDomain
  have taken := interpreted_take calls equations.toRawHelperEquations text valid state.position token context.1.1 tokenValid
  dsimp +instances only [stepBody, Expr.eval, Calls.get, Field.get, Context.locals, lexical, modelPrimitives]
  rw [skipped, literal, argument, read, target, targetSame, dynamic, assignment, output, comparison, capacity, taken, contextAfter]
  cases token <;> simp +instances [step, spelling, isWord, BEq.beq]

end Silver.Compose.SourceBridge
