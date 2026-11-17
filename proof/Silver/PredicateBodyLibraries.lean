module

public import Silver.PredicateBodyHelpers
public import Silver.PredicateBasicLibraries
public import Silver.PredicateNativeLibraries
public import Silver.PredicateLoopHelpers
public import Silver.PredicateLoopSizing

@[expose] public section
namespace Silver.Predicate.BodyLibraries
open Compose
set_option backward.dsimp.instances true

/-! Source-derived body libraries below the completed outer helper bundle.
Only raw inherited helper equations are needed here; in particular constructing
function declarations cannot depend on an already completed declaration law. -/

variable {inherited : Compose.Expressions.Calls} {domain : Compose.Expressions.StateDomain}

structure Calls (_inherited : Compose.Expressions.Calls) where
  body : BodyNative.Calls
  predicate : Native.Calls
  literals : IntegerLiteral.Native.Calls
  integer : Source → Nat → IntegerLiteral.Result
  basicPrimitives : BasicNative.Primitives
  loopImports : LoopNative.Imports
  loopScalars : ScalarExpression.Native.Calls
  basic : Source → Native.Context → BodyScan → FunctionBindings.Metadata → ProcedureBindings.Metadata → BodyScan
  flowLibraries : FlowSourceBridge.Calls
  initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage
  bodyWrapperModels : Adapter.Wrappers.Calls
  bodyWrappers : Adapter.Wrappers.Calls
  invalidBodies : BodyWrappers.Calls
  joinInto : ActiveFlow → ActiveFlow → ActiveFlow

def bodyPrimitives (calls : Calls inherited) : BodyNative.Primitives where
  loop := calls.loopImports
  token := inherited.function .takeToken
  basic := calls.basic
  predicate text context position facts := calls.predicate.condition text context position facts []
  bodyToken := calls.bodyWrappers.token
  invalidModel := calls.invalidBodies.invalidModel
  invalid := calls.invalidBodies.invalid
  joinInto := calls.joinInto

theorem bodyToken_fixed (token : ShellToken) (valid : token ∈ BodyNative.bodyTokens) :
    Adapter.FixedToken token := by
  simp only [BodyNative.bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Adapter.FixedToken, ShellToken.word, ShellToken.symbol]

theorem body_token_calls_fixed :
    ∀ token ∈ [ShellToken.word "if", ShellToken.word "for"] ++
      BodyNative.conditionalFunction.tokenCalls ++ BodyNative.alternativeFunction.tokenCalls ++
      BodyNative.tailModelBody.tokenCalls ++ BodyNative.readFunction.tokenCalls,
      Adapter.FixedToken token :=
  fun token present => bodyToken_fixed token (BodyNative.body_tokens_complete token present)

structure Definitions (calls : Calls inherited) : Prop where
  literals : IntegerLiteral.Native.Equations calls.literals
  literalRefinement : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position,
    position ≤ text.length + 1 → calls.integer text position = calls.literals.model text position
  libraries : Native.Libraries.Links calls.predicate inherited calls.integer
  predicates : Native.DefinitionEquations calls.predicate
  predicateContracts : Native.Contracts calls.predicate
  basicLinks : BasicNative.Links calls.basicPrimitives inherited calls.predicate
  flowLibraries : FlowSourceBridge.CallsMeaning calls.flowLibraries
  initial : FlowSourceBridge.InterpretedInitial calls.flowLibraries calls.initial
  wrapperModels : Adapter.Wrappers.ModelEquations calls.bodyWrapperModels calls.body
    (Adapter.Environment.initialCall calls.initial) (inherited.function .takeToken)
  wrappers : Adapter.Wrappers.Refinement calls.bodyWrapperModels calls.bodyWrappers
  invalidBodies : BodyWrappers.DefinitionEquations calls.invalidBodies
  joinInto : ∃ flowCalls joined joinedInto,
    FlowSourceBridge.CallsMeaning flowCalls ∧ FlowSourceBridge.InterpretedJoined flowCalls joined ∧
    FlowSourceBridge.InterpretedJoinInto joined joinedInto ∧
    ∀ left right, left.count ≤ ScalarExpression.maxBindings → left.count = right.count →
      calls.joinInto left right = (joinedInto (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right)).active
  loopScalarPrimitives : ScalarExpression.Native.Primitives calls.loopScalars
  loopScalarEquations : ScalarExpression.Native.Equations calls.loopScalars
  loopLinks : LoopNative.Links calls.loopImports inherited calls.loopScalars
  basicSized : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures →
      BasicNative.SizedBasic (BasicNative.totalize calls.basicPrimitives) text context scan catalog procedures
  loopSized : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures →
      LoopNative.SizedLoop (LoopNative.totalizeImports calls.loopImports) calls.body.read text context scan catalog procedures
  basic : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.basic text context scan catalog procedures =
      BasicNative.basicEval (BasicNative.totalize calls.basicPrimitives) text context scan catalog procedures
  body : BodyNative.DefinitionEquations (bodyPrimitives calls) calls.body

section
variable (calls : Calls inherited) (helpers : Compose.Expressions.RawHelperEquations inherited (domain := domain))
  (definitions : Definitions calls)
include helpers definitions

theorem wrapper_models : Adapter.Wrappers.ModelEquations calls.bodyWrapperModels calls.body :=
  Adapter.Wrappers.normalize_models calls.flowLibraries definitions.flowLibraries calls.initial
    definitions.initial (Adapter.Wrappers.normalize_tokens helpers definitions.wrapperModels)

theorem predicate_helpers : Native.HelperMeaning calls.predicate :=
  Native.Libraries.helper_meaning calls.predicate inherited helpers calls.literals
    definitions.literals calls.integer definitions.literalRefinement definitions.libraries

theorem basic_helpers : BasicNative.HelperMeaning calls.basicPrimitives :=
  BasicNative.HelperMeaning.of_inherited helpers
    (predicate_helpers calls helpers definitions) definitions.predicates definitions.predicateContracts
    definitions.basicLinks

theorem body_helpers (lexical : Compose.Lexical.Meaning inherited.primitive) :
    BodyNative.HelperMeaning (bodyPrimitives calls) where
  loop := LoopNative.ImportsMeaning.of_inherited helpers lexical
    definitions.loopScalarPrimitives definitions.loopScalarEquations definitions.loopLinks
  token text tv position pv token valid := by
    dsimp only [bodyPrimitives]
    rw [Compose.Expressions.interpreted_take inherited helpers text tv position token pv
      (BodyNative.bodyToken_valid token valid)]
    exact BodyNative.bodyToken_model text position token valid
  bodyToken text tv context cv scan sv token valid :=
    Adapter.Wrappers.token_interpreted (wrapper_models calls helpers definitions) definitions.wrappers
      text context scan token ⟨tv,cv,sv,BodyNative.bodyToken_valid token valid⟩ (bodyToken_fixed token valid)
  basic text tv context cv scan sv catalog procedures fv pv := by
    dsimp only [bodyPrimitives]
    rw [definitions.basic text tv context cv scan sv catalog procedures fv pv]
    exact BasicNative.basicEval_normalized (basic_helpers calls helpers definitions) text context scan catalog procedures
  predicate text tv context cv position pv facts fv :=
    Native.condition_of_source_equations (predicate_helpers calls helpers definitions)
      definitions.predicates definitions.predicateContracts text tv context cv position pv facts fv
      [] (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
  invalidModel scan capacity := BodyWrappers.invalidModel_meaning definitions.invalidBodies scan capacity
  invalid scan capacity := BodyWrappers.invalid_meaning definitions.invalidBodies scan capacity
  joinInto left right capacity same := by
    obtain ⟨flowCalls, joined, joinedInto, meaning, joinedSource, source, observed⟩ := definitions.joinInto
    rw [show (bodyPrimitives calls).joinInto = calls.joinInto from rfl, observed left right capacity same]
    simpa only [FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_joinInto flowCalls meaning joined joinedSource joinedInto source
        (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same

theorem body_equations (lexical : Compose.Lexical.Meaning inherited.primitive) :
    BodyNative.Equations calls.body :=
  BodyNative.equations_of_definitions (bodyPrimitives calls) calls.body
    (body_helpers calls helpers definitions lexical) definitions.body

end

/-- Explicit simultaneous witness for every raw component and its wiring. -/
def modelCalls : Calls Compose.Expressions.modelCalls where
  body := BodyNative.modelCalls
  predicate := Native.modelCalls
  literals := IntegerLiteral.Native.modelCalls
  integer := IntegerLiteral.read
  basicPrimitives := {BasicNative.modelPrimitives with
    token := Compose.Expressions.modelCalls.function .takeToken
    bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token}
  loopImports := {LoopNative.modelImports with bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token}
  loopScalars := ScalarExpression.Native.modelCalls
  basic text context scan catalog procedures := basicBody text context.model scan catalog procedures
  flowLibraries := FlowSourceBridge.modelCalls
  initial := FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls
  bodyWrapperModels := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  bodyWrappers := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  invalidBodies := BodyWrappers.modelCalls
  joinInto := ActiveFlow.join

theorem model_basic_links
    (helpers : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) : BasicNative.Links modelCalls.basicPrimitives Compose.Expressions.modelCalls modelCalls.predicate :=
  BasicNative.model_links helpers

theorem model_body_helpers
    (helpers : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain))
    (lexical : Compose.Lexical.Meaning Compose.Expressions.modelCalls.primitive) : BodyNative.HelperMeaning (bodyPrimitives modelCalls) where
  loop := LoopNative.ImportsMeaning.of_inherited helpers
    lexical
    ScalarExpression.Native.model_primitives ScalarExpression.Native.model_equations
    (LoopNative.model_links helpers)
  token text _ position _ token valid := BodyNative.bodyToken_model text position token valid
  bodyToken text tv context cv scan sv token valid :=
    Adapter.Wrappers.token_interpreted (Adapter.Wrappers.model_equations BodyNative.modelCalls)
      (Adapter.Wrappers.model_refinement _) text context scan token
      ⟨tv,cv,sv,BodyNative.bodyToken_valid token valid⟩ (bodyToken_fixed token valid)
  basic _ _ _ _ _ _ _ _ _ _ := rfl
  predicate _ _ _ _ _ _ _ _ := rfl
  invalidModel _ _ := rfl
  invalid _ _ := rfl
  joinInto _ _ _ _ := rfl

theorem model_definitions
    (helpers : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain))
    (lexical : Compose.Lexical.Meaning Compose.Expressions.modelCalls.primitive) : Definitions modelCalls where
  literals := IntegerLiteral.Native.model_equations
  literalRefinement _ _ _ _ := rfl
  libraries := Native.Libraries.model_links
  predicates := Native.model_definition_equations
  predicateContracts := Native.model_contracts
  basicLinks := model_basic_links helpers
  flowLibraries := FlowSourceBridge.model_calls_meaning
  initial := FlowSourceBridge.model_initial_interpreted FlowSourceBridge.modelCalls
  wrapperModels := {
    bodyOf := fun scan legal => (Adapter.Environment.body_expression_projection
      FlowSourceBridge.modelCalls FlowSourceBridge.model_calls_meaning
      (FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls)
      (FlowSourceBridge.model_initial_interpreted FlowSourceBridge.modelCalls)
      BodyNative.modelCalls {scan} legal).symm
    token := fun text context scan token legal =>
      (Adapter.Wrappers.token_expression_projection helpers
        BodyNative.modelCalls text context scan token legal).symm }
  wrappers := Adapter.Wrappers.model_refinement _
  invalidBodies := BodyWrappers.model_definitions
  joinInto := by
    let joined := FlowSourceBridge.joinedStorage FlowSourceBridge.modelCalls
    refine ⟨FlowSourceBridge.modelCalls, joined, joined,
      FlowSourceBridge.model_calls_meaning, FlowSourceBridge.model_joined_interpreted FlowSourceBridge.modelCalls,
      FlowSourceBridge.model_joinInto_interpreted joined, ?_⟩
    intro left right capacity same
    symm
    simpa only [modelCalls, FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_joined FlowSourceBridge.modelCalls FlowSourceBridge.model_calls_meaning
        joined (FlowSourceBridge.model_joined_interpreted FlowSourceBridge.modelCalls)
        (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same
  loopScalarPrimitives := ScalarExpression.Native.model_primitives
  loopScalarEquations := ScalarExpression.Native.model_equations
  loopLinks := LoopNative.model_links helpers
  basicSized text _ context cv scan sv catalog procedures _ _ := by
    rw [BasicNative.totalize_eq_model (BasicNative.HelperMeaning.of_inherited helpers
      Native.model_helper_meaning Native.model_definition_equations Native.model_contracts (model_basic_links helpers))]
    exact BasicNative.model_sizedBasic text context scan (sv.2.2.count_le cv) catalog procedures
  loopSized text _ context cv scan sv catalog procedures _ _ := by
    have importsMeaning : LoopNative.ImportsMeaning modelCalls.loopImports := (model_body_helpers helpers lexical).loop
    rw [LoopNative.totalizeImports_eq_model importsMeaning]
    exact LoopNative.model_sizedLoop text context scan catalog procedures sv.2.2.2.compatible.count cv.2.2.1.1
  basic text _ context _ scan _ catalog procedures _ _ :=
    (BasicNative.basicEval_normalized
      (BasicNative.HelperMeaning.of_inherited helpers
      Native.model_helper_meaning Native.model_definition_equations Native.model_contracts (model_basic_links helpers)) text context scan catalog procedures).symm
  body := by
    have normalized := BodyNative.totalize_eq_model (bodyPrimitives modelCalls) (model_body_helpers helpers lexical)
    have bodySame : modelCalls.body = BodyNative.modelCalls := rfl
    exact {
      sized := by simpa only [normalized, bodySame] using BodyNative.model_sizedBodies
      statement := by simpa only [normalized, bodySame] using BodyNative.model_equations.statement
      loop := by
        simpa only [LoopNative.evalWith_of_meaning (model_body_helpers helpers lexical).loop, bodySame] using BodyNative.model_equations.loop
      conditional := by simpa only [normalized, bodySame] using BodyNative.model_equations.conditional
      alternative := by simpa only [normalized, bodySame] using BodyNative.model_equations.alternative
      tailModel := by simpa only [normalized, bodySame] using BodyNative.model_equations.tailModel
      tail := by
        simpa only [bodySame, BodyNative.ScanExpr.eval, BodyNative.StopRef.eval]
          using BodyNative.model_equations.tail
      read := by simpa only [normalized, bodySame] using BodyNative.model_equations.read }

end Silver.Predicate.BodyLibraries
