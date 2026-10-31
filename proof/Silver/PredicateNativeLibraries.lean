module

public import Silver.PredicateNativeHelpers
public import Silver.PredicateFlowReaderLibraries
public import Silver.PredicateNativeScalarHelpers
public import Silver.ComposeModelCalls
public import Silver.ComposeEquations
public import Silver.IntegerLiteralEquations
public import Silver.LengthIntervalExpressions

@[expose] public section
namespace Silver.Predicate.Native
open Compose Compose.Expressions
namespace Libraries

variable {domain : Compose.Expressions.StateDomain}

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

/-- Scalar helper definitions inherit their primitive lexical and interval
operations from already interpreted source libraries. -/
structure ScalarLinks (calls : Native.Calls) (composed : Compose.Expressions.Calls) : Prop where
  source : ∃ helpers : ScalarHelpers.Calls,
    Integer.NativeSourceBridge.InterpretedSource helpers.scalars ∧
    helpers.skip = composed.function .skip ∧
    helpers.nameAfter = composed.function .nameAfter ∧
    helpers.lookup = composed.function .scalarLookup ∧
    ScalarHelpers.DefinitionEquations helpers ∧
    calls.scalarCondition = helpers.scalarCondition ∧ calls.invalidCondition = helpers.invalid

theorem scalar_primitives {helperCalls : ScalarHelpers.Calls} {composed : Compose.Expressions.Calls}
    (equations : HelperEquations composed (domain := domain))
    (scalars : Integer.NativeSourceBridge.InterpretedSource helperCalls.scalars)
    (skip : helperCalls.skip = composed.function .skip)
    (name : helperCalls.nameAfter = composed.function .nameAfter)
    (lookup : helperCalls.lookup = composed.function .scalarLookup) :
    ScalarHelpers.PrimitiveMeaning helperCalls where
  scalars := scalars
  skip text tv position pv := by
    rw [skip]
    exact interpreted_skip composed equations text tv position pv
  nameAfter text tv position pv := by
    rw [name]
    exact interpreted_name composed equations text tv position pv
  lookup text tv names first after nv fv av := by
    rw [lookup]
    exact equations.scalarLookup text tv names first after nv fv av

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
  scalarRead : calls.scalarRead = fun text position names => composed.function .scalarRead text position names [] [] false
  readers : FlowReaders.Links composed calls.scalarInFlow calls.stringInFlow
  scalarHelpers : ScalarLinks calls composed
  integer : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integer text position = integer text position
  expression : ∀ text, ValidText text → ∀ position names scalarNames, position ≤ text.length + 1 → ValidNames text names →
    ScalarExpression.ValidEnvironment text scalarNames →
    calls.expression text position names scalarNames = composed.function .expression text position names scalarNames false [] [] false
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
  join : ∃ flowCalls joined,
    FlowSourceBridge.CallsMeaning flowCalls ∧ FlowSourceBridge.InterpretedJoined flowCalls joined ∧
    ∀ left right, left.count ≤ ScalarExpression.maxBindings → left.count = right.count →
      calls.join left right = (joined (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right)).active

theorem token_valid (token : Token) : Compose.Expressions.ValidToken token.shell := by
  unfold Compose.Expressions.ValidToken
  cases token <;> decide +kernel

theorem helper_meaning (calls : Native.Calls) (composed : Compose.Expressions.Calls)
    (composedEquations : Compose.Expressions.HelperEquations composed (domain := domain))
    (literals : IntegerLiteral.Native.Calls) (literalEquations : IntegerLiteral.Native.Equations literals)
    (integer : Source → Nat → IntegerLiteral.Result)
    (refinement : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
      integer text position = literals.model text position)
    (links : Links calls composed integer) : HelperMeaning calls where
  callAfter text tv names position operation scalarNames arrays hidden nv sv av pv := by
    rw [links.callAfter]
    exact Compose.Expressions.interpreted_callAfter composed composedEquations text tv names position operation nv pv sv av hidden
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
    exact composedEquations.scalarRead text tv position names [] [] false pv nv
      (by simp [ArrayBindings.ValidMetadata, ArrayBindings.maxBindings])
      (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
  scalarInFlow text tv context cv position facts pv fv :=
    FlowReaders.linked_scalar composedEquations links.readers {text, context, position, facts}
      ⟨tv, cv, fv, pv⟩
  stringInFlow text tv context cv position facts pv fv :=
    FlowReaders.linked_string composedEquations links.readers {text, context, position, facts}
      ⟨tv, cv, fv, pv⟩
  scalarCondition text tv context cv position rightPosition pv rpv facts fv left right la ra operator lb rb := by
    obtain ⟨helpers, scalars, skip, name, lookup, definitions, condition, _⟩ := links.scalarHelpers.source
    rw [condition]
    exact ScalarHelpers.scalarCondition_meaning
      (scalar_primitives composedEquations scalars skip name lookup) definitions
      text tv context cv position rightPosition pv rpv facts fv left right la ra operator lb rb
  invalidCondition facts capacity := by
    obtain ⟨helpers, _, _, _, _, definitions, _, invalid⟩ := links.scalarHelpers.source
    rw [invalid]
    exact ScalarHelpers.invalid_meaning definitions facts capacity
  integer text tv position bounded := by
    rw [links.integer text tv position bounded]
    exact IntegerLiteral.Native.executable_refinement literals literalEquations integer refinement text tv position bounded
  expression text tv position names scalarNames bounded nv sv := by
    rw [links.expression text tv position names scalarNames bounded nv sv,
      Compose.Expressions.interpreted_expression composed composedEquations text tv position names bounded nv sv
        (by simp [ArrayBindings.ValidMetadata, ArrayBindings.maxBindings])
        (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])]
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
  join left right capacity same := by
    obtain ⟨flowCalls, joined, meaning, source, observed⟩ := links.join
    rw [observed left right capacity same]
    simpa only [FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_joined flowCalls meaning joined source
        (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same

/-- The callee wiring itself has a concrete inhabitant. -/
theorem model_links : Links Native.modelCalls Compose.Expressions.modelCalls IntegerLiteral.read where
  callAfter := rfl
  take text _ position token _ := by cases token <;> rfl
  skip _ _ _ _ := rfl
  name _ _ _ _ := rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  scalarLookup := rfl
  scalarRead := rfl
  readers := by
    let inherited := FlowReaders.inheritedCalls FlowSourceBridge.readingStorage
      Compose.Expressions.modelCalls ScalarExpression.Native.modelCalls
    refine ⟨FlowSourceBridge.readingStorage, ScalarExpression.Native.modelCalls,
      FlowReaders.modelScalar inherited, FlowSourceBridge.model_reading_interpreted,
      ScalarExpression.Native.model_primitives, ScalarExpression.Native.model_equations,
      FlowReaders.model_scalar_refinement inherited, ?_, ?_⟩
    · constructor
      intro inputs legal
      dsimp only [FlowReaders.stringRhs, FlowReaders.Expr.eval, inherited, FlowReaders.inheritedCalls]
      rw [FlowReaders.overlay_meaning FlowSourceBridge.model_reading_interpreted legal.2.1 legal.2.2.1]
      rfl
    · intro text context position facts legal
      exact (FlowReaders.scalar_meaning FlowReaders.model_meaning
        (FlowReaders.model_scalar_refinement FlowReaders.modelCalls)
        {text, context, position, facts} legal (Or.inl ⟨rfl, rfl⟩)).symm
  scalarHelpers := ⟨ScalarHelpers.modelCalls, Integer.NativeSourceBridge.model_interpreted,
    rfl, rfl, rfl, ScalarHelpers.model_equations, rfl, rfl⟩
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
  join := by
    refine ⟨FlowSourceBridge.modelCalls, FlowSourceBridge.joinedStorage FlowSourceBridge.modelCalls,
      FlowSourceBridge.model_calls_meaning, FlowSourceBridge.model_joined_interpreted _, ?_⟩
    intro left right capacity same
    symm
    simpa only [FlowSourceBridge.ofFlow_active, Native.modelCalls] using
      FlowSourceBridge.interpreted_joined FlowSourceBridge.modelCalls
        FlowSourceBridge.model_calls_meaning _ (FlowSourceBridge.model_joined_interpreted _)
        (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same

end Libraries
end Silver.Predicate.Native
