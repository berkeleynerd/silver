module

public import Silver.PredicateNativeHelpers
public import Silver.ComposeModelCalls
public import Silver.ComposeEquations
public import Silver.IntegerLiteralEquations
public import Silver.LengthIntervalExpressions

@[expose] public section
namespace Silver.Predicate.Native
open Compose Compose.Expressions
namespace Libraries

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

abbrev Paths := PathFacts.Native.Context
abbrev Bound := PathFacts.Native.Bound

def reify (facts : PathFacts.Context) : Paths :=
  match facts.validLengths with
  | none => ⟨0, 0, false, facts.invalidReachable, facts.invalidRejected⟩
  | some interval => ⟨interval.lower, interval.upper, true, facts.invalidReachable, facts.invalidRejected⟩

def reifyBound : Bindings.Bound → Bound
  | .fixed length => ⟨length, false⟩
  | .argument => ⟨0, true⟩

@[simp] theorem reify_model (facts : PathFacts.Context) : (reify facts).model = facts := by
  cases facts with
  | mk valid invalid rejected => cases valid <;> rfl

@[simp] theorem reifyBound_model (bound : Bindings.Bound) : (reifyBound bound).model = bound := by
  cases bound <;> rfl

/-- Typed native path parameters. Source field values retain their native
representation until each library result is projected. -/
structure PathInputs where
  facts : Paths := PathFacts.Native.empty
  leftFacts : Paths := PathFacts.Native.empty
  rightFacts : Paths := PathFacts.Native.empty
  leftBound : Bound := ⟨0, false⟩
  rightBound : Bound := ⟨0, false⟩
  value : Bindings.Summary := ⟨0, 0⟩
  leftSummary : Bindings.Summary := ⟨0, 0⟩
  rightSummary : Bindings.Summary := ⟨0, 0⟩
  operator : Comparison := .eq
  truth : Bool := false

def PathInputs.locals (inputs : PathInputs) : PathFacts.Native.Locals
  | .context, "facts" => inputs.facts
  | .context, "left" => inputs.leftFacts
  | .context, "right" => inputs.rightFacts
  | .bound, "left" => inputs.leftBound
  | .bound, "right" => inputs.rightBound
  | .summary, "value" => inputs.value
  | .summary, "left" => inputs.leftSummary
  | .summary, "right" => inputs.rightSummary
  | .comparison, "operator" => inputs.operator
  | .truth, "truth" => inputs.truth
  | ty, _ => ty.default

/-- Callee wiring only: lexical/expression calls use their inherited native
functions; Read_Integer uses its runtime wrapper; path calls use the exact typed
library bodies. No independent predicate meaning occurs in these links. -/
structure Links (calls : Native.Calls) (composed : Compose.Expressions.Calls)
    (integer : Source → Nat → IntegerLiteral.Result) : Prop where
  callAfter : calls.callAfter = composed.function .callAfter
  take : ∀ text, ValidText text → ∀ position token, position ≤ text.length + 1 →
    calls.take text position token = composed.function .takeToken text position token.shell
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.skip text position = composed.function .skip text position
  name : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = composed.function .nameAfter text position
  lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = composed.function .lookupName text names first after
  scalarLookup : calls.scalarLookup = composed.function .scalarLookup
  scalarRead : calls.scalarRead = composed.function .scalarRead
  integer : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integer text position = integer text position
  expression : ∀ text, ValidText text → ∀ position names scalarNames, position ≤ text.length + 1 → ValidNames text names →
    ScalarExpression.ValidEnvironment text scalarNames →
    calls.expression text position names scalarNames = composed.function .expression text position names scalarNames false
  assumeValid : ∀ facts : Paths,
    calls.assumeValid facts.model =
      (PathFacts.Native.assumeValidBody.eval ({facts} : PathInputs).locals).model
  assumeInvalid : ∀ facts : Paths,
    calls.assumeInvalid facts.model =
      (PathFacts.Native.assumeInvalidBody.eval ({facts} : PathInputs).locals).model
  refineBounds : ∀ (facts : Paths) operator (left right : Bound) truth,
    calls.refineBounds facts.model operator left.model right.model truth =
      (PathFacts.Native.refineBoundsBody.eval ({facts, operator, leftBound := left, rightBound := right, truth} : PathInputs).locals).model
  fits : ∀ (facts : Paths) value,
    calls.fits facts.model value = LengthIntervals.Native.fitsBody.eval ({facts, value} : LengthIntervals.Native.Inputs).locals
  refineEqual : ∀ (facts : Paths) left right,
    calls.refineEqual facts.model left right =
      (LengthIntervals.Native.refineEqualBody.eval ({facts, left, right} : LengthIntervals.Native.Inputs).locals).model
  join : ∀ left right : Paths,
    calls.join left.model right.model =
      (PathFacts.Native.joinBody.eval ({leftFacts := left, rightFacts := right} : PathInputs).locals).model

theorem token_valid (token : Token) : Compose.Expressions.ValidToken token.shell := by
  unfold Compose.Expressions.ValidToken
  cases token <;> decide +kernel

theorem helper_meaning (calls : Native.Calls) (composed : Compose.Expressions.Calls)
    (composedEquations : Compose.Expressions.HelperEquations composed)
    (literals : IntegerLiteral.Native.Calls) (literalEquations : IntegerLiteral.Native.Equations literals)
    (integer : Source → Nat → IntegerLiteral.Result)
    (refinement : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
      integer text position = literals.model text position)
    (links : Links calls composed integer) : HelperMeaning calls where
  callAfter text tv names position operation scalarNames nv sv pv := by
    rw [links.callAfter]
    exact Compose.Expressions.interpreted_callAfter composed composedEquations text tv names position operation nv pv sv
  take text tv position token bounded := by
    rw [links.take text tv position token bounded,
      Compose.Expressions.interpreted_take composed composedEquations text tv position token.shell bounded (token_valid token)]
    cases token <;> rfl
  skip text tv position bounded := by
    rw [links.skip text tv position bounded, Compose.Expressions.interpreted_skip composed composedEquations text tv position bounded]
  name text tv position bounded := by
    rw [links.name text tv position bounded, Compose.Expressions.interpreted_name composed composedEquations text tv position bounded]
  lookup text tv names first after nv fv av := by
    rw [links.lookup text tv names first after nv fv av,
      Compose.Expressions.interpreted_lookup composed composedEquations text tv names first after nv fv av]
  scalarLookup text tv names first after nv fv av := by
    rw [links.scalarLookup]
    exact composedEquations.scalarLookup text tv names first after nv fv av
  scalarRead text tv position names pv nv := by
    rw [links.scalarRead]
    exact composedEquations.scalarRead text tv position names pv nv
  integer text tv position bounded := by
    rw [links.integer text tv position bounded]
    exact IntegerLiteral.Native.executable_refinement literals literalEquations integer refinement text tv position bounded
  expression text tv position names scalarNames bounded nv sv := by
    rw [links.expression text tv position names scalarNames bounded nv sv,
      Compose.Expressions.interpreted_expression composed composedEquations text tv position names bounded nv sv]
  assumeValid facts := by
    have equation := links.assumeValid (reify facts)
    simpa only [PathFacts.Native.assumeValidBody_eval, PathInputs.locals, PathFacts.Native.assumeValid_model, reify_model] using equation
  assumeInvalid facts := by
    have equation := links.assumeInvalid (reify facts)
    simpa only [PathFacts.Native.assumeInvalidBody_eval, PathInputs.locals, PathFacts.Native.assumeInvalid_model, reify_model] using equation
  refineBounds facts operator left right truth := by
    have equation := links.refineBounds (reify facts) operator (reifyBound left) (reifyBound right) truth
    simpa only [PathFacts.Native.refineBoundsBody_eval, PathInputs.locals, PathFacts.Native.refineBounds_model, reify_model, reifyBound_model] using equation
  fits facts value := by
    have equation := links.fits (reify facts) value
    simpa only [LengthIntervals.Native.fitsBody_eval, LengthIntervals.Native.fits_model, reify_model] using equation
  refineEqual facts left right := by
    have equation := links.refineEqual (reify facts) left right
    simpa only [LengthIntervals.Native.refineEqualBody_eval, LengthIntervals.Native.refineEqual_model, reify_model] using equation
  join left right := by
    have equation := links.join (reify left) (reify right)
    simpa only [PathFacts.Native.joinBody_eval, PathInputs.locals, PathFacts.Native.join_model, reify_model] using equation

/-- The callee wiring itself has a concrete inhabitant. -/
theorem model_links : Links Native.modelCalls Compose.Expressions.modelCalls IntegerLiteral.read where
  callAfter := rfl
  take text _ position token _ := by cases token <;> rfl
  skip _ _ _ _ := rfl
  name _ _ _ _ := rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  scalarLookup := rfl
  scalarRead := rfl
  integer _ _ _ _ := rfl
  expression _ _ _ _ _ _ _ _ := rfl
  assumeValid facts := by
    rw [PathFacts.Native.assumeValidBody_eval]
    exact (PathFacts.Native.assumeValid_model facts).symm
  assumeInvalid facts := by
    rw [PathFacts.Native.assumeInvalidBody_eval]
    exact (PathFacts.Native.assumeInvalid_model facts).symm
  refineBounds facts operator left right truth := by
    rw [PathFacts.Native.refineBoundsBody_eval]
    exact (PathFacts.Native.refineBounds_model facts operator left right truth).symm
  fits facts value := by
    rw [LengthIntervals.Native.fitsBody_eval]
    exact (LengthIntervals.Native.fits_model facts value).symm
  refineEqual facts left right := by
    rw [LengthIntervals.Native.refineEqualBody_eval]
    exact (LengthIntervals.Native.refineEqual_model facts left right).symm
  join left right := by
    rw [PathFacts.Native.joinBody_eval]
    exact (PathFacts.Native.join_model left right).symm

end Libraries
end Silver.Predicate.Native
