module

public import Silver.PredicateBodyHelpers
public import Silver.PredicateBasicHelpers
public import Silver.PredicateNativeLibraries
public import Silver.PredicateLoopHelpers
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

def bodyPrimitives (calls : Calls) : BodyNative.Primitives where
  loop := calls.loopImports
  token := calls.outer.helpers.function .takeToken
  basic := calls.basic
  predicate := calls.predicate.condition

structure Definitions (calls : Calls) : Prop where
  literals : IntegerLiteral.Native.Equations calls.literals
  literalRefinement : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position,
    position ≤ text.length + 1 → calls.integer text position = calls.literals.model text position
  libraries : Native.Libraries.Links calls.predicate calls.outer.helpers calls.integer
  predicates : Native.DefinitionEquations calls.predicate
  predicateContracts : Native.Contracts calls.predicate
  basicLinks : BasicNative.Links calls.basicPrimitives calls.outer.helpers
  loopScalarPrimitives : ScalarExpression.Native.Primitives calls.loopScalars
  loopScalarEquations : ScalarExpression.Native.Equations calls.loopScalars
  loopLinks : LoopNative.Links calls.loopImports calls.outer.helpers calls.loopScalars
  basic : ∀ text, BodyNative.ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, BodyNative.ValidScan text context scan → calls.basic text context scan =
      BasicNative.basicEval (BasicNative.totalize calls.basicPrimitives) text context scan
  body : BodyNative.DefinitionEquations (bodyPrimitives calls) calls.outer.body
  adapter : ∀ text, Outer.ValidText text → ∀ scan, Outer.ValidScan text scan → ∀ stop,
    (stop = .word "else" ∨ stop = .word "end") →
    calls.outer.readStatements text scan stop =
      Adapter.adapterFunction.eval calls.outer.body {text,scan,token := stop}
  outer : Outer.DefinitionEquations calls.outer

section
variable (calls : Calls) (helpers : Compose.Expressions.HelperEquations calls.outer.helpers)
  (definitions : Definitions calls)
include helpers definitions

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
  basic text tv context cv scan sv := by
    dsimp only [bodyPrimitives]
    rw [definitions.basic text tv context cv scan sv]
    exact BasicNative.basicEval_normalized (basic_helpers calls helpers definitions) text context scan
  predicate text tv context cv position pv facts fv :=
    Native.condition_of_source_equations (predicate_helpers calls helpers definitions)
      definitions.predicates definitions.predicateContracts text tv context cv position pv facts fv

theorem body_equations (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    BodyNative.Equations calls.outer.body :=
  BodyNative.equations_of_definitions (bodyPrimitives calls) calls.outer.body
    (body_helpers calls helpers definitions lexical) definitions.body

theorem body_meaning (lexical : Compose.Lexical.Meaning calls.outer.helpers.primitive) :
    Outer.BodyMeaning calls.outer where
  statements text tv scan sv := by
    rw [definitions.adapter text tv scan sv (.word "end") (Or.inr rfl), Adapter.adapter_eval,
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
  basicPrimitives := {BasicNative.modelPrimitives with token := Compose.Expressions.modelCalls.function .takeToken}
  loopImports := LoopNative.modelImports
  loopScalars := ScalarExpression.Native.modelCalls
  basic text context scan := basicBody text context.model scan

theorem model_basic_links : BasicNative.Links modelCalls.basicPrimitives modelCalls.outer.helpers where
  callAfter := rfl
  associationAfter := rfl
  token := by funext text position token; rfl
  expression := rfl
  target := rfl
  scalarTarget text context position _ :=
    (ScalarBodyNative.targetEval_inherited Outer.model_helpers.equations text context position).symm
  scalarAssignment text context scan _ :=
    (ScalarBodyNative.assignmentEval_inherited Outer.model_helpers.equations text context scan).symm
  fits facts summary := by
    rw [LengthIntervals.Native.fitsBody_eval, LengthIntervals.Native.fits_model]
    rfl
  sameLength facts left right := by
    rw [LengthIntervals.Native.sameLengthBody_eval, LengthIntervals.Native.sameLength_model]
    rfl
  reject facts := by
    rw [PathFacts.Native.rejectedBody_eval]
    exact (PathFacts.Native.rejected_model facts).symm

theorem model_body_helpers : BodyNative.HelperMeaning (bodyPrimitives modelCalls) where
  loop := LoopNative.model_imports_meaning
  token text _ position _ token valid := BodyNative.bodyToken_model text position token valid
  basic _ _ _ _ _ _ := rfl
  predicate _ _ _ _ _ _ _ _ := rfl

theorem model_definitions : Definitions modelCalls where
  literals := IntegerLiteral.Native.model_equations
  literalRefinement _ _ _ _ := rfl
  libraries := Native.Libraries.model_links
  predicates := Native.model_definition_equations
  predicateContracts := Native.model_contracts
  basicLinks := model_basic_links
  loopScalarPrimitives := ScalarExpression.Native.model_primitives
  loopScalarEquations := ScalarExpression.Native.model_equations
  loopLinks := LoopNative.model_links
  basic text _ context _ scan _ :=
    (BasicNative.basicEval_normalized
      (BasicNative.HelperMeaning.of_inherited Outer.model_helpers.equations model_basic_links) text context scan).symm
  body := by
    have normalized := BodyNative.totalize_eq_model (bodyPrimitives modelCalls) model_body_helpers
    have bodySame : modelCalls.outer.body = BodyNative.modelCalls := rfl
    exact {
      statement := by simpa only [normalized, bodySame] using BodyNative.model_equations.statement
      loop := by
        simpa only [LoopNative.evalWith_of_meaning model_body_helpers.loop, bodySame] using BodyNative.model_equations.loop
      conditional := by simpa only [normalized, bodySame] using BodyNative.model_equations.conditional
      alternative := by simpa only [normalized, bodySame] using BodyNative.model_equations.alternative
      tail := by simpa only [normalized, bodySame] using BodyNative.model_equations.tail
      read := by simpa only [normalized, bodySame] using BodyNative.model_equations.read }
  adapter text _ scan _ stop _ := (Adapter.adapter_eval BodyNative.modelCalls {text,scan,token := stop}).symm
  outer := Outer.model_definitions

end Silver.Predicate.Implementation
