module

public import Silver.PredicateBodyHelpers
public import Silver.PredicateBasicLibraries
public import Silver.PredicateNativeLibraries
public import Silver.PredicateLoopHelpers
public import Silver.PredicateLoopSizing
public import Silver.PredicateOuterModel

@[expose] public section
namespace Silver.Predicate.Implementation
open Compose
set_option backward.dsimp.instances true

/-! Compose the independently checked helper interfaces before interpreting the
recursive scanner. Equations keep arbitrary native callees; all semantic scanner
equalities are conclusions. Native partial functions are represented by the
explicit domain-preserving totalizations in BasicNative and BodyNative. -/

structure Calls where
  outer : Outer.Calls
  predicate : Native.Calls
  literals : IntegerLiteral.Native.Calls
  integer : Source → Nat → IntegerLiteral.Result
  basicPrimitives : BasicNative.Primitives
  loopImports : LoopNative.Imports
  loopScalars : ScalarExpression.Native.Calls
  basic : Source → Native.Context → BodyScan → BodyScan
  flowLibraries : FlowSourceBridge.Calls
  initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage
  bodyWrapperModels : Adapter.Wrappers.Calls
  bodyWrappers : Adapter.Wrappers.Calls
  invalidBodies : BodyWrappers.Calls
  joinInto : ActiveFlow → ActiveFlow → ActiveFlow

def bodyPrimitives (calls : Calls) : BodyNative.Primitives where
  loop := calls.loopImports
  token := calls.outer.helpers.function .takeToken
  basic := calls.basic
  predicate := calls.predicate.condition
  bodyToken := calls.bodyWrappers.token
  invalidModel := calls.invalidBodies.invalidModel
  invalid := calls.invalidBodies.invalid
  joinInto := calls.joinInto

theorem bodyToken_fixed (token : ShellToken) (valid : token ∈ BodyNative.bodyTokens) :
    Adapter.FixedToken token := by
  simp only [BodyNative.bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Adapter.FixedToken, ShellToken.word, ShellToken.symbol]

theorem body_token_calls_fixed :
    ∀ token ∈ [ShellToken.word "if", ShellToken.word "for"] ++
      BodyNative.conditionalFunction.tokenCalls ++ BodyNative.alternativeFunction.tokenCalls ++
      BodyNative.tailModelBody.tokenCalls ++ BodyNative.readFunction.tokenCalls,
      Adapter.FixedToken token :=
  fun token present => bodyToken_fixed token (BodyNative.body_tokens_complete token present)

structure Definitions (calls : Calls) : Prop where
  literals : IntegerLiteral.Native.Equations calls.literals
  literalRefinement : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position,
    position ≤ text.length + 1 → calls.integer text position = calls.literals.model text position
  libraries : Native.Libraries.Links calls.predicate calls.outer.helpers calls.integer
  predicates : Native.DefinitionEquations calls.predicate
  predicateContracts : Native.Contracts calls.predicate
  basicLinks : BasicNative.Links calls.basicPrimitives calls.outer.helpers
  flowLibraries : FlowSourceBridge.CallsMeaning calls.flowLibraries
  initial : FlowSourceBridge.InterpretedInitial calls.flowLibraries calls.initial
  wrapperModels : Adapter.Wrappers.ModelEquations calls.bodyWrapperModels calls.outer.body
    (Adapter.Environment.initialCall calls.initial) (calls.outer.helpers.function .takeToken)
  wrappers : Adapter.Wrappers.Refinement calls.bodyWrapperModels calls.bodyWrappers
  invalidBodies : BodyWrappers.DefinitionEquations calls.invalidBodies
  joinInto : ∃ flowCalls joined joinedInto,
    FlowSourceBridge.CallsMeaning flowCalls ∧ FlowSourceBridge.InterpretedJoined flowCalls joined ∧
    FlowSourceBridge.InterpretedJoinInto joined joinedInto ∧
    ∀ left right, left.count ≤ ScalarExpression.maxBindings → left.count = right.count →
      calls.joinInto left right = (joinedInto (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right)).active
  loopScalarPrimitives : ScalarExpression.Native.Primitives calls.loopScalars
  loopScalarEquations : ScalarExpression.Native.Equations calls.loopScalars
  loopLinks : LoopNative.Links calls.loopImports calls.outer.helpers calls.loopScalars
  basicSized : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan →
      BasicNative.SizedBasic (BasicNative.totalize calls.basicPrimitives) text context scan
  loopSized : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan →
      LoopNative.SizedLoop (LoopNative.totalizeImports calls.loopImports) calls.outer.body.read text context scan
  basic : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan → calls.basic text context scan =
      BasicNative.basicEval (BasicNative.totalize calls.basicPrimitives) text context scan
  body : BodyNative.DefinitionEquations (bodyPrimitives calls) calls.outer.body
  adapter : ∀ text, Outer.ValidText text → ∀ scan, Outer.ValidScan text scan → ∀ stop,
    (stop = .word "else" ∨ stop = .word "end") →
    calls.outer.readStatements text scan stop =
      Adapter.adapterFunction.eval calls.outer.body {text,scan,token := stop}
        (bodyOfCall := calls.bodyWrappers.bodyOf)
  outer : Outer.DefinitionEquations calls.outer

section
variable (calls : Calls) (helpers : Compose.Expressions.HelperEquations calls.outer.helpers (domain := OuterReadiness.domain))
  (definitions : Definitions calls)
include helpers definitions

theorem wrapper_models : Adapter.Wrappers.ModelEquations calls.bodyWrapperModels calls.outer.body :=
  Adapter.Wrappers.normalize_models calls.flowLibraries definitions.flowLibraries calls.initial
    definitions.initial (Adapter.Wrappers.normalize_tokens helpers definitions.wrapperModels)

theorem predicate_helpers : Native.HelperMeaning calls.predicate :=
  Native.Libraries.helper_meaning calls.predicate calls.outer.helpers helpers calls.literals
    definitions.literals calls.integer definitions.literalRefinement definitions.libraries

theorem basic_helpers : BasicNative.HelperMeaning calls.basicPrimitives :=
  BasicNative.HelperMeaning.of_inherited helpers definitions.basicLinks

theorem body_helpers (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    BodyNative.HelperMeaning (bodyPrimitives calls) where
  loop := LoopNative.ImportsMeaning.of_inherited helpers lexical
    definitions.loopScalarPrimitives definitions.loopScalarEquations definitions.loopLinks
  token text tv position pv token valid := by
    dsimp only [bodyPrimitives]
    rw [Compose.Expressions.interpreted_take calls.outer.helpers helpers text tv position token pv
      (BodyNative.bodyToken_valid token valid)]
    exact BodyNative.bodyToken_model text position token valid
  bodyToken text tv context cv scan sv token valid :=
    Adapter.Wrappers.token_interpreted (wrapper_models calls helpers definitions) definitions.wrappers
      text context scan token ⟨tv,cv,sv,BodyNative.bodyToken_valid token valid⟩ (bodyToken_fixed token valid)
  basic text tv context cv scan sv := by
    dsimp only [bodyPrimitives]
    rw [definitions.basic text tv context cv scan sv]
    exact BasicNative.basicEval_normalized (basic_helpers calls helpers definitions) text context scan
  predicate text tv context cv position pv facts fv :=
    Native.condition_of_source_equations (predicate_helpers calls helpers definitions)
      definitions.predicates definitions.predicateContracts text tv context cv position pv facts fv
  invalidModel scan capacity := BodyWrappers.invalidModel_meaning definitions.invalidBodies scan capacity
  invalid scan capacity := BodyWrappers.invalid_meaning definitions.invalidBodies scan capacity
  joinInto left right capacity same := by
    obtain ⟨flowCalls, joined, joinedInto, meaning, joinedSource, source, observed⟩ := definitions.joinInto
    rw [show (bodyPrimitives calls).joinInto = calls.joinInto from rfl, observed left right capacity same]
    simpa only [FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_joinInto flowCalls meaning joined joinedSource joinedInto source
        (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same

theorem body_equations (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    BodyNative.Equations calls.outer.body :=
  BodyNative.equations_of_definitions (bodyPrimitives calls) calls.outer.body
    (body_helpers calls helpers definitions lexical) definitions.body

theorem body_meaning (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    Outer.BodyMeaning calls.outer where
  statements text tv scan sv := by
    rw [definitions.adapter text tv scan sv (.word "end") (Or.inr rfl),
      Adapter.Wrappers.adapter_interpreted (wrapper_models calls helpers definitions) definitions.wrappers
        {text,scan,token := .word "end"} sv.1.2.2.2.2.2.1,
      Adapter.adapter_eval,
      Adapter.adapter_unique calls.outer.body (body_equations calls helpers definitions lexical) text tv scan sv]
    exact Adapter.model_adapter text scan

theorem correspondence (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive)
    (outerHelpers : Outer.HelperMeaning calls.outer) (text : Source) :
    calls.outer.member text = accepts text ∧ calls.outer.arguments text = hasArguments text ∧
      calls.outer.assignment text = hasAssignment text ∧ calls.outer.output text = hasOutput text :=
  ⟨Outer.interpreted_member calls.outer outerHelpers (body_meaning calls helpers definitions lexical) definitions.outer text,
   Outer.interpreted_arguments calls.outer outerHelpers (body_meaning calls helpers definitions lexical) definitions.outer text,
   Outer.interpreted_assignment calls.outer outerHelpers (body_meaning calls helpers definitions lexical) definitions.outer text,
   Outer.interpreted_output calls.outer outerHelpers (body_meaning calls helpers definitions lexical) definitions.outer text⟩

end

/-- Explicit simultaneous witness for every raw component and its wiring. -/
def modelCalls : Calls where
  outer := Outer.modelCalls
  predicate := Native.modelCalls
  literals := IntegerLiteral.Native.modelCalls
  integer := IntegerLiteral.read
  basicPrimitives := {BasicNative.modelPrimitives with
    token := Compose.Expressions.modelCalls.function .takeToken
    bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token}
  loopImports := {LoopNative.modelImports with bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token}
  loopScalars := ScalarExpression.Native.modelCalls
  basic text context scan := basicBody text context.model scan
  flowLibraries := FlowSourceBridge.modelCalls
  initial := FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls
  bodyWrapperModels := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  bodyWrappers := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  invalidBodies := BodyWrappers.modelCalls
  joinInto := ActiveFlow.join

theorem model_basic_links : BasicNative.Links modelCalls.basicPrimitives modelCalls.outer.helpers :=
  BasicNative.model_links Outer.model_helpers.equations

theorem model_body_helpers : BodyNative.HelperMeaning (bodyPrimitives modelCalls) where
  loop := LoopNative.ImportsMeaning.of_inherited Outer.model_helpers.equations
    (Compose.SourceBridge.interpreted_primitives Compose.Expressions.modelCalls InheritedReady.model_interpreted)
    ScalarExpression.Native.model_primitives ScalarExpression.Native.model_equations
    (LoopNative.model_links Outer.model_helpers.equations)
  token text _ position _ token valid := BodyNative.bodyToken_model text position token valid
  bodyToken text tv context cv scan sv token valid :=
    Adapter.Wrappers.token_interpreted (Adapter.Wrappers.model_equations BodyNative.modelCalls)
      (Adapter.Wrappers.model_refinement _) text context scan token
      ⟨tv,cv,sv,BodyNative.bodyToken_valid token valid⟩ (bodyToken_fixed token valid)
  basic _ _ _ _ _ _ := rfl
  predicate _ _ _ _ _ _ _ _ := rfl
  invalidModel _ _ := rfl
  invalid _ _ := rfl
  joinInto _ _ _ _ := rfl

theorem model_definitions : Definitions modelCalls where
  literals := IntegerLiteral.Native.model_equations
  literalRefinement _ _ _ _ := rfl
  libraries := Native.Libraries.model_links
  predicates := Native.model_definition_equations
  predicateContracts := Native.model_contracts
  basicLinks := model_basic_links
  flowLibraries := FlowSourceBridge.model_calls_meaning
  initial := FlowSourceBridge.model_initial_interpreted FlowSourceBridge.modelCalls
  wrapperModels := {
    bodyOf := fun scan legal => (Adapter.Environment.body_expression_projection
      FlowSourceBridge.modelCalls FlowSourceBridge.model_calls_meaning
      (FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls)
      (FlowSourceBridge.model_initial_interpreted FlowSourceBridge.modelCalls)
      BodyNative.modelCalls {scan} legal).symm
    token := fun text context scan token legal =>
      (Adapter.Wrappers.token_expression_projection Outer.model_helpers.equations
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
  loopLinks := LoopNative.model_links Outer.model_helpers.equations
  basicSized text _ context cv scan sv := by
    rw [BasicNative.totalize_eq_model (BasicNative.HelperMeaning.of_inherited Outer.model_helpers.equations model_basic_links)]
    exact BasicNative.model_sizedBasic text context scan (sv.2.2.count_le cv)
  loopSized text _ context cv scan sv := by
    have importsMeaning : LoopNative.ImportsMeaning modelCalls.loopImports := model_body_helpers.loop
    rw [LoopNative.totalizeImports_eq_model importsMeaning]
    exact LoopNative.model_sizedLoop text context scan sv.2.2.2.compatible.count cv.2.2.1.1
  basic text _ context _ scan _ :=
    (BasicNative.basicEval_normalized
      (BasicNative.HelperMeaning.of_inherited Outer.model_helpers.equations model_basic_links) text context scan).symm
  body := by
    have normalized := BodyNative.totalize_eq_model (bodyPrimitives modelCalls) model_body_helpers
    have bodySame : modelCalls.outer.body = BodyNative.modelCalls := rfl
    exact {
      sized := by simpa only [normalized, bodySame] using BodyNative.model_sizedBodies
      statement := by simpa only [normalized, bodySame] using BodyNative.model_equations.statement
      loop := by
        simpa only [LoopNative.evalWith_of_meaning model_body_helpers.loop, bodySame] using BodyNative.model_equations.loop
      conditional := by simpa only [normalized, bodySame] using BodyNative.model_equations.conditional
      alternative := by simpa only [normalized, bodySame] using BodyNative.model_equations.alternative
      tailModel := by simpa only [normalized, bodySame] using BodyNative.model_equations.tailModel
      tail := by
        simpa only [bodySame, BodyNative.ScanExpr.eval, BodyNative.StopRef.eval]
          using BodyNative.model_equations.tail
      read := by simpa only [normalized, bodySame] using BodyNative.model_equations.read }
  adapter text _ scan sv stop _ := by
    change Adapter.adapterEval BodyNative.modelCalls text scan stop =
      Adapter.adapterFunction.eval BodyNative.modelCalls {text,scan,token := stop}
        (bodyOfCall := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).bodyOf)
    rw [Adapter.Wrappers.adapter_interpreted (Adapter.Wrappers.model_equations BodyNative.modelCalls)
      (Adapter.Wrappers.model_refinement _) {text,scan,token := stop} sv.1.2.2.2.2.2.1]
    exact (Adapter.adapter_eval BodyNative.modelCalls {text,scan,token := stop}).symm
  outer := Outer.model_definitions

end Silver.Predicate.Implementation
