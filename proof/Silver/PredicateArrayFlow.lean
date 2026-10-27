module

public import Silver.ArrayBindings
public import Silver.PredicateFlowWidening

@[expose] public section

/-! Array cells carry Full Integer body ranges independently of the finite
scalar flow vector. Scalar updates and lexical indexes remain in the reserved
low identity range. -/
namespace Silver.Predicate.ArrayFlow

abbrev ranges (arrays : ArrayBindings.Metadata) (scalars : Integer.Ranges) : Integer.Ranges :=
  ArrayBindings.ranges arrays [] false scalars

def analysis (arrays : ArrayBindings.Metadata) (scalars : Integer.Analysis) : Integer.Analysis :=
  ⟨ranges arrays scalars.declared, ArrayBindings.mutability arrays scalars.mutable,
    scalars.static, ArrayBindings.refinability arrays scalars.refinable⟩

def flow (arrays : ArrayBindings.Metadata) (facts : ActiveFlow) : Flow :=
  ⟨facts.path, ranges arrays facts.model.scalars⟩

@[simp] theorem flow_path (arrays : ArrayBindings.Metadata) (facts : ActiveFlow) :
    (flow arrays facts).path = facts.path := rfl

theorem ranges_scalar (arrays : ArrayBindings.Metadata) (scalars : Integer.Ranges)
    {index : Nat} (low : index ≤ ArrayBindings.scalarLimit) : ranges arrays scalars index = scalars index :=
  ArrayBindings.ranges_scalar arrays [] false scalars low

theorem ranges_put (arrays : ArrayBindings.Metadata) (scalars : Integer.Ranges)
    {index : Nat} (low : index ≤ ArrayBindings.scalarLimit) (bounds : Option Integer.Interval) :
    ranges arrays (Integer.put scalars index bounds) = Integer.put (ranges arrays scalars) index bounds :=
  ArrayBindings.ranges_put arrays [] false scalars low bounds

theorem ranges_join (arrays : ArrayBindings.Metadata) (left right : Integer.Ranges) :
    ranges arrays (left.join right) = (ranges arrays left).join (ranges arrays right) := by
  funext cell
  unfold ranges ArrayBindings.ranges Integer.Ranges.join
  cases covered : ArrayBindings.covers arrays cell with
  | true => simp only [covered, ↓reduceIte, Bool.false_eq_true]; rfl
  | false => simp only [covered, Bool.false_eq_true, ↓reduceIte]

theorem ranges_refine (arrays : ArrayBindings.Metadata) (scalars : Integer.Ranges)
    (index : Nat) (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (low : index ≤ ArrayBindings.scalarLimit) :
    ranges arrays (scalars.refineName index operator threshold truth) =
      (ranges arrays scalars).refineName index operator threshold truth := by
  unfold Integer.Ranges.refineName
  rw [ranges_scalar arrays scalars low]
  cases present : scalars index with
  | none => rfl
  | some bounds => exact ranges_put arrays scalars low _

theorem analysis_widen (arrays : ArrayBindings.Metadata) (base : Integer.Analysis)
    (scalars : Integer.Ranges) :
    (analysis arrays base).widen (ranges arrays scalars) = ranges arrays (base.widen scalars) := by
  funext cell
  by_cases covered : ArrayBindings.covers arrays cell = true
  · simp only [Integer.Analysis.widen, analysis, ranges, ArrayBindings.ranges, covered, ↓reduceIte,
      Bool.false_eq_true]
    split <;> rfl
  · have absent : ArrayBindings.covers arrays cell = false := by simpa using covered
    simp only [Integer.Analysis.widen, analysis, ranges, ArrayBindings.ranges, absent,
      Bool.false_eq_true, ↓reduceIte, ArrayBindings.mutability_of_not_covered absent]

theorem analysis_withIndex (arrays : ArrayBindings.Metadata) (base : Integer.Analysis)
    (index : Nat) (bounds : Integer.Interval) (low : index ≤ ArrayBindings.scalarLimit) :
    analysis arrays (base.withIndex index bounds) = (analysis arrays base).withIndex index bounds := by
  simp only [analysis, Integer.Analysis.withIndex]
  rw [ranges_put arrays base.declared low,
    ArrayBindings.mutability_put arrays base.mutable low,
    ArrayBindings.refinability_put arrays base.refinable low]

theorem flow_join (arrays : ArrayBindings.Metadata) (left right : ActiveFlow) :
    flow arrays (left.join right) = (flow arrays left).join (flow arrays right) := by
  unfold flow
  have same := ActiveFlow.join_model left right
  have scalars := congrArg Flow.scalars same
  simp only [Flow.join] at scalars
  rw [scalars, ranges_join]
  rfl

theorem flow_replace (arrays : ArrayBindings.Metadata) (facts : ActiveFlow)
    (index : Nat) (bounds : Integer.Interval) (positive : 0 < index)
    (within : index ≤ facts.count) (low : index ≤ ArrayBindings.scalarLimit) :
    flow arrays (facts.replace index bounds) =
      ⟨facts.path, Integer.put (flow arrays facts).scalars index (some bounds)⟩ := by
  have same := ActiveFlow.replace_model facts index bounds positive within
  have scalars := congrArg Flow.scalars same
  simp only at scalars
  simp only [flow, ActiveFlow.replace_path]
  rw [scalars, ranges_put arrays _ low]

theorem flow_refine (arrays : ArrayBindings.Metadata) (facts : ActiveFlow)
    (index : Nat) (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (low : index ≤ ArrayBindings.scalarLimit) :
    flow arrays (facts.refine index operator threshold truth) =
      ⟨facts.path, (flow arrays facts).scalars.refineName index operator threshold truth⟩ := by
  have same := ActiveFlow.refine_model facts index operator threshold truth
  have scalars := congrArg Flow.scalars same
  simp only at scalars
  simp only [flow, ActiveFlow.refine_path]
  rw [scalars, ranges_refine arrays _ index operator threshold truth low]

theorem flow_append (arrays : ArrayBindings.Metadata) (facts : ActiveFlow)
    (bounds : Integer.Interval) (low : facts.count + 1 ≤ ArrayBindings.scalarLimit) :
    flow arrays (facts.append bounds) =
      ⟨facts.path, Integer.put (flow arrays facts).scalars (facts.count + 1) (some bounds)⟩ := by
  have same := ActiveFlow.append_model facts bounds
  have scalars := congrArg Flow.scalars same
  simp only at scalars
  simp only [flow]
  rw [scalars, ranges_put arrays _ low]
  rfl

theorem flow_widen (arrays : ArrayBindings.Metadata) (names : ScalarExpression.Environment)
    (declarations : Nat) (facts : ActiveFlow) (same : facts.count = names.length)
    (ready : ScalarExpression.BodyReady names) :
    flow arrays (facts.widen names) =
      ⟨facts.path, (analysis arrays (ScalarMetadata.analysis names declarations)).widen (flow arrays facts).scalars⟩ := by
  have model := ActiveFlow.widen_model names declarations facts same ready
  have scalars := congrArg Flow.scalars model
  simp only at scalars
  simp only [flow, ActiveFlow.widen_path]
  rw [scalars, analysis_widen]

end Silver.Predicate.ArrayFlow
