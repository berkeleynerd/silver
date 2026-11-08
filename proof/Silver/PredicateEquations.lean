module

public import Silver.PredicateBodyLibraries
public import Silver.PredicateOuterModel

@[expose] public section
namespace Silver.Predicate.Implementation
open Compose
set_option backward.dsimp.instances true

/-! The outer scanner reuses the raw-helper body derivation. Completed helper
and outer-model witnesses enter only at this downstream composition layer. -/

structure Calls where
  outer : Outer.Calls
  predicate : Native.Calls
  literals : IntegerLiteral.Native.Calls
  integer : Source → Nat → IntegerLiteral.Result
  basicPrimitives : BasicNative.Primitives
  loopImports : LoopNative.Imports
  loopScalars : ScalarExpression.Native.Calls
  basic : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  flowLibraries : FlowSourceBridge.Calls
  initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage
  bodyWrapperModels : Adapter.Wrappers.Calls
  bodyWrappers : Adapter.Wrappers.Calls
  invalidBodies : BodyWrappers.Calls
  joinInto : ActiveFlow → ActiveFlow → ActiveFlow

def Calls.bodyCalls (calls : Calls) : BodyLibraries.Calls calls.outer.helpers where
  body := calls.outer.body
  predicate := calls.predicate
  literals := calls.literals
  integer := calls.integer
  basicPrimitives := calls.basicPrimitives
  loopImports := calls.loopImports
  loopScalars := calls.loopScalars
  basic := calls.basic
  flowLibraries := calls.flowLibraries
  initial := calls.initial
  bodyWrapperModels := calls.bodyWrapperModels
  bodyWrappers := calls.bodyWrappers
  invalidBodies := calls.invalidBodies
  joinInto := calls.joinInto

def bodyPrimitives (calls : Calls) : BodyNative.Primitives :=
  BodyLibraries.bodyPrimitives calls.bodyCalls

theorem bodyToken_fixed (token : ShellToken) (valid : token ∈ BodyNative.bodyTokens) :
    Adapter.FixedToken token := BodyLibraries.bodyToken_fixed token valid

theorem body_token_calls_fixed :
    ∀ token ∈ [ShellToken.word "if", ShellToken.word "for"] ++
      BodyNative.conditionalFunction.tokenCalls ++ BodyNative.alternativeFunction.tokenCalls ++
      BodyNative.tailModelBody.tokenCalls ++ BodyNative.readFunction.tokenCalls,
      Adapter.FixedToken token := BodyLibraries.body_token_calls_fixed

structure Definitions (calls : Calls) : Prop extends BodyLibraries.Definitions calls.bodyCalls where
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
  BodyLibraries.wrapper_models calls.bodyCalls helpers.toRawHelperEquations definitions.toDefinitions

theorem predicate_helpers : Native.HelperMeaning calls.predicate :=
  BodyLibraries.predicate_helpers calls.bodyCalls helpers.toRawHelperEquations definitions.toDefinitions

theorem basic_helpers : BasicNative.HelperMeaning calls.basicPrimitives :=
  BodyLibraries.basic_helpers calls.bodyCalls helpers.toRawHelperEquations definitions.toDefinitions

theorem body_helpers (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    BodyNative.HelperMeaning (bodyPrimitives calls) :=
  BodyLibraries.body_helpers calls.bodyCalls helpers.toRawHelperEquations definitions.toDefinitions lexical

theorem body_equations (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    BodyNative.Equations calls.outer.body :=
  BodyLibraries.body_equations calls.bodyCalls helpers.toRawHelperEquations definitions.toDefinitions lexical

theorem body_meaning (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    Outer.BodyMeaning calls.outer where
  statements text tv scan sv := by
    rw [definitions.adapter text tv scan sv (.word "end") (Or.inr rfl),
      Adapter.Wrappers.adapter_interpreted (wrapper_models calls helpers definitions)
        (show Adapter.Wrappers.Refinement calls.bodyWrapperModels calls.bodyWrappers from definitions.wrappers)
        {text,scan,token := .word "end"} sv.1.2.2.2.2.2.1.1,
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
  basic text context scan catalog := basicBody text context.model scan catalog
  flowLibraries := FlowSourceBridge.modelCalls
  initial := FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls
  bodyWrapperModels := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  bodyWrappers := Adapter.Wrappers.modelCalls BodyNative.modelCalls
  invalidBodies := BodyWrappers.modelCalls
  joinInto := ActiveFlow.join

theorem model_basic_links : BasicNative.Links modelCalls.basicPrimitives modelCalls.outer.helpers modelCalls.predicate :=
  BodyLibraries.model_basic_links Outer.model_helpers.equations.toRawHelperEquations

theorem model_body_helpers : BodyNative.HelperMeaning (bodyPrimitives modelCalls) :=
  BodyLibraries.model_body_helpers Outer.model_helpers.equations.toRawHelperEquations
    (Compose.SourceBridge.interpreted_primitives Compose.Expressions.modelCalls InheritedReady.model_interpreted)

theorem model_definitions : Definitions modelCalls where
  toDefinitions := BodyLibraries.model_definitions Outer.model_helpers.equations.toRawHelperEquations
    (Compose.SourceBridge.interpreted_primitives Compose.Expressions.modelCalls InheritedReady.model_interpreted)
  adapter text _ scan sv stop _ := by
    change Adapter.adapterEval BodyNative.modelCalls text scan stop =
      Adapter.adapterFunction.eval BodyNative.modelCalls {text,scan,token := stop}
        (bodyOfCall := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).bodyOf)
    rw [Adapter.Wrappers.adapter_interpreted (Adapter.Wrappers.model_equations BodyNative.modelCalls)
      (Adapter.Wrappers.model_refinement _) {text,scan,token := stop} sv.1.2.2.2.2.2.1.1]
    exact (Adapter.adapter_eval BodyNative.modelCalls {text,scan,token := stop}).symm
  outer := Outer.model_definitions

end Silver.Predicate.Implementation
