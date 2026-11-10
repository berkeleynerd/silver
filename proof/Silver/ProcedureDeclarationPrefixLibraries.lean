module

public import Silver.ProcedureDeclarationParameterLibraries
public import Silver.ProcedureDeclarationPrefixEquations
public import Silver.FunctionDeclarationInitialDomain
public import Silver.PredicateAdapterEnvironment
public import Silver.PredicateFunctionCallHelpers
public import Silver.PredicateNativeRanges

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 7000
set_option maxHeartbeats 2000000

/-- The context expression, finite-storage Initial_Flow and Actual_After
remain connected to their existing raw source interpretations. -/
structure PrefixLinks (calls : Calls) (reader : Predicate.BodyNative.Calls)
    (initial : Predicate.FlowSourceBridge.Context → Predicate.FlowSourceBridge.FlowStorage)
    (actualCalls : Predicate.FunctionCallNative.Calls) : Prop where
  context : ∀ scan, StateRecord scan.state →
    calls .contextOf scan = Predicate.Adapter.contextExpr.eval reader {scan}
  initial : ∀ context, context.scalarNames.length ≤ ScalarExpression.maxBindings →
    calls .initialFlow context = Predicate.Adapter.Environment.initialCall initial context
  actual : calls .actualAfter = actualCalls.actual

theorem prefix_initial_valid (text : Source) (readFrame : ParserState) (declarationCount : Nat)
    (valid : FunctionDeclarationNative.NativeValidState text readFrame) :
    Predicate.Native.ValidFlow (prefixContext readFrame declarationCount)
      (Predicate.ActiveFlow.initial (prefixContext readFrame declarationCount).scalarNames
        (Predicate.initialFacts (prefixContext readFrame declarationCount).model.hasArguments)) := by
  exact (FunctionDeclarationNative.body_initial_valid text readFrame declarationCount valid).2.2

theorem actual_after_bound (text : Source) (context : Predicate.Native.Context) (position : Nat)
    (facts : Predicate.ActiveFlow) (formal : FunctionBindings.Formal)
    (tv : FunctionBindings.Native.ValidText text) (cv : Predicate.Native.ValidContext text context)
    (bounded : position ≤ text.length + 1) :
    Predicate.actualAfter text context.model position facts formal ≤ text.length + 1 := by
  unfold Predicate.actualAfter
  split
  · exact Predicate.Native.condition_bound text context.model position facts tv cv.1 bounded
  · dsimp only
    split
    · exact Nat.zero_le _
    · rename_i accepted
      have nonzero : (Predicate.readScalarInFlow text context.model position facts).after ≠ 0 :=
        fun zero => accepted (.inl zero)
      obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound bounded nonzero
      exact parsed.cursorBounds.2.2

theorem prefix_step_imports {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : ParameterLinks calls inherited ordinary metadata visibility)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (equations : HelperEquations calls)
    (reader : Predicate.BodyNative.Calls)
    (flow : Predicate.FlowSourceBridge.Calls)
    (flowMeaning : Predicate.FlowSourceBridge.CallsMeaning flow)
    (initial : Predicate.FlowSourceBridge.Context → Predicate.FlowSourceBridge.FlowStorage)
    (initialEquations : Predicate.FlowSourceBridge.InterpretedInitial flow initial)
    (actualImports : Predicate.FunctionCallNative.Imports)
    (actualCalls : Predicate.FunctionCallNative.Calls)
    (assignment : Source → Predicate.Native.Context → Predicate.BodyScan → FunctionBindings.Metadata → Predicate.BodyScan)
    (actualMeaning : Predicate.FunctionCallNative.ImportsMeaning actualImports)
    (actualEquations : Predicate.FunctionCallNative.DefinitionEquations actualImports actualCalls assignment)
    (prefixLinks : PrefixLinks calls reader initial actualCalls)
    (text : Source) (readFrame frame : ParserState) (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (valid : PrefixStepDomain text readFrame frame parameter declarationCount) :
    PrefixImports calls text readFrame frame parameter declarationCount := by
  classical
  have lexical := header_lexical source links
  have firstBound := Expressions.model_skip_valid text frame.position valid.2.2.1.2.base.1
  have afterBound := function_nameAfter_bound text (skipAt text frame.position)
  have assignmentBound := fixedAfter_result_bound text (Compose.nameAfter text (skipAt text frame.position)) ":=" false (by decide)
  have contextValid := FunctionDeclarationNative.body_context_valid text readFrame declarationCount valid.2.1.2 valid.2.2.2.1
  have initialValid := prefix_initial_valid text readFrame declarationCount valid.2.1.2
  have contextBound : (prefixContext readFrame declarationCount).scalarNames.length ≤ ScalarExpression.maxBindings := by
    simpa only [prefixContext, FunctionDeclarationNative.bodyContext, FunctionDeclarationNative.nativeContextOf,
      ScalarExpression.bodyEnvironment_length] using valid.2.1.1.scalars.1
  have valueBound := actual_after_bound text (prefixContext readFrame declarationCount)
    (fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false)
    (Predicate.ActiveFlow.initial (prefixContext readFrame declarationCount).scalarNames
      (Predicate.initialFacts (prefixContext readFrame declarationCount).model.hasArguments))
    ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds⟩ valid.1 contextValid assignmentBound
  refine {
    skip := lexical.skip text valid.1 _ valid.2.2.1.2.base.1,
    nameAfter := lexical.nameAfter text valid.1 _ firstBound,
    context := ?_,
    assignment := lexical.take text valid.1 _ _ _ afterBound (native_token_valid .assignment),
    initial := ?_, actual := ?_,
    following := lexical.take text valid.1 _ _ _ valueBound (native_token_valid .semicolon),
    equal := ?_, append := ?_}
  · rw [prefixLinks.context _ valid.2.1.1, Predicate.Adapter.context_eval]
    rfl
  · dsimp only
    rw (transparency := .default) [prefixLinks.initial _ contextBound,
      Predicate.Adapter.Environment.initialCall_interpreted flow flowMeaning initial initialEquations _ contextBound]
    rfl
  · dsimp only
    rw [prefixLinks.actual]
    have actualDomain : Predicate.FunctionCallNative.ActualDomain text (prefixContext readFrame declarationCount)
        (fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false)
        (Predicate.ActiveFlow.initial (prefixContext readFrame declarationCount).scalarNames
          (Predicate.initialFacts (prefixContext readFrame declarationCount).model.hasArguments))
        ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds⟩ :=
      ⟨⟨⟨valid.1, contextValid, assignmentBound⟩, initialValid⟩, valid.2.2.2.2.1⟩
    have interpreted := congrArg (fun fn => fn text (prefixContext readFrame declarationCount)
        (fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false)
        (Predicate.ActiveFlow.initial (prefixContext readFrame declarationCount).scalarNames
          (Predicate.initialFacts (prefixContext readFrame declarationCount).model.hasArguments))
        ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds⟩)
      (Predicate.FunctionCallNative.normalized_actual actualMeaning actualEquations)
    simpa only [Predicate.FunctionCallNative.totalizeCalls, Predicate.FunctionCallNative.modelCalls,
      actualDomain, ↓reduceIte] using interpreted
  · dsimp only
    intro positive ordered
    rw [links.equal]
    exact visibilityPrimitives.equalName text valid.1 _ _ _ _
      ⟨by omega, ordered, afterBound⟩ valid.2.2.2.2.2.2.1
  · dsimp only
    intro _
    apply interpreted_appendParameter calls equations.toFrameEquations (scalar_append_meaning source links)
    refine ⟨?_, valid.2.2.2.2.1⟩
    exact (FunctionDeclarationNative.StateInput.withPosition valid.1 valid.2.2.1 _
      (fixedAfter_result_bound text _ ";" false (by decide))).1

theorem prefix_imports {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : ParameterLinks calls inherited ordinary metadata visibility)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (equations : HelperEquations calls)
    (reader : Predicate.BodyNative.Calls)
    (flow : Predicate.FlowSourceBridge.Calls)
    (flowMeaning : Predicate.FlowSourceBridge.CallsMeaning flow)
    (initial : Predicate.FlowSourceBridge.Context → Predicate.FlowSourceBridge.FlowStorage)
    (initialEquations : Predicate.FlowSourceBridge.InterpretedInitial flow initial)
    (actualImports : Predicate.FunctionCallNative.Imports)
    (actualCalls : Predicate.FunctionCallNative.Calls)
    (assignment : Source → Predicate.Native.Context → Predicate.BodyScan → FunctionBindings.Metadata → Predicate.BodyScan)
    (actualMeaning : Predicate.FunctionCallNative.ImportsMeaning actualImports)
    (actualEquations : Predicate.FunctionCallNative.DefinitionEquations actualImports actualCalls assignment)
    (prefixLinks : PrefixLinks calls reader initial actualCalls) : PrefixMeaning calls where
  step := prefix_step_imports source links visibilityPrimitives equations reader flow flowMeaning
    initial initialEquations actualImports actualCalls assignment actualMeaning actualEquations prefixLinks

end Silver.Compose.ProcedureDeclarationNative
