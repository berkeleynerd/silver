module

public import Silver.IntegerMutable
public import Silver.IntegerComparisons
public import Silver.PathFacts

@[expose] public section

/-! Scalar analysis metadata never changes during a statement sequence. Flow
contains only the current read intervals and the independent input path facts. -/
namespace Silver.Integer

def Ranges.join (left right : Ranges) : Ranges := fun index =>
  match left index, right index with
  | some a, some b => some (a.join b)
  | _, _ => none

theorem Ranges.join_left {left right : Ranges} {values : Store}
    (fits : Fits left values) : Fits (left.join right) values := by
  intro index bounds found
  unfold join at found
  split at found
  · rename_i a b leftFound rightFound
    cases found
    exact Interval.join_left (fits index a leftFound)
  · contradiction

theorem Ranges.join_right {left right : Ranges} {values : Store}
    (fits : Fits right values) : Fits (left.join right) values := by
  intro index bounds found
  unfold join at found
  split at found
  · rename_i a b leftFound rightFound
    cases found
    exact Interval.join_right (fits index b rightFound)
  · contradiction

def Analysis.widen (analysis : Analysis) (ranges : Ranges) : Ranges := fun index =>
  if analysis.mutable index then analysis.declared index else ranges index

theorem Analysis.widen_fits {analysis : Analysis} {ranges : Ranges} {values : Store}
    (current : Fits ranges values) (declared : Fits analysis.declared values) :
    Fits (analysis.widen ranges) values := by
  intro index bounds found
  unfold widen at found
  split at found
  · exact declared index bounds found
  · exact current index bounds found

/-- Closing a body iteration uses declared containment for mutable cells and
exact preservation for every read-only cell, including outer loop indexes. -/
theorem Analysis.widen_closed {analysis : Analysis} {ranges : Ranges} {before after : Store}
    (initial : Fits (analysis.widen ranges) before)
    (declared : Fits analysis.declared after)
    (readonly : ∀ index, analysis.mutable index = false → after index = before index) :
    Fits (analysis.widen ranges) after := by
  intro index bounds found
  cases mutable : analysis.mutable index with
  | true =>
      have target : analysis.declared index = some bounds := by
        simpa only [widen, mutable, ↓reduceIte] using found
      exact declared index bounds target
  | false =>
      rw [readonly index mutable]
      exact initial index bounds found

def Ranges.refineName (ranges : Ranges) (index : Nat) (operator : Comparison)
    (threshold : Int) (truth : Bool) : Ranges :=
  match ranges index with
  | none => ranges
  | some bounds => put ranges index (some (bounds.refineOrKeep operator threshold truth))

theorem Ranges.refineName_sound {ranges : Ranges} {values : Store} {index : Nat}
    {operator : Comparison} {threshold : Int} {truth : Bool}
    (fits : Fits ranges values) (range : InRange (values index))
    (known : operator.evaluate (values index) threshold = truth) :
    Fits (ranges.refineName index operator threshold truth) values := by
  cases present : ranges index with
  | none => simpa only [refineName, present] using fits
  | some incoming =>
    intro other bounds found
    simp only [refineName, present] at found
    by_cases same : other = index
    · subst other
      simp only [put, ↓reduceIte, Option.some.injEq] at found
      subst bounds
      exact Interval.refineOrKeep_sound (fits index incoming present) range known
    · exact fits other bounds (by simpa only [put, same, ↓reduceIte] using found)

/-- A bare target and independently static singleton threshold. Parenthesized
names and immutable nonstatic snapshots deliberately fail this selection. -/
def guardCandidate (analysis : Analysis) (target threshold : Expr) (bounds : Interval) :
    Option (Nat × Int) :=
  match target with
  | .name index =>
      if analysis.refinable index && threshold.isStatic analysis.static &&
          decide (bounds.lower = bounds.upper)
      then some (index, bounds.lower) else none
  | _ => none

theorem guardCandidate_sound {analysis : Analysis} {target threshold : Expr}
    {bounds : Interval} {ranges : Ranges} {values : Store} {index : Nat} {value : Int}
    (candidate : guardCandidate analysis target threshold bounds = some (index, value))
    (inferred : threshold.infer ranges = some bounds) (fits : Fits ranges values) :
    target.evaluate values = values index ∧ threshold.evaluate values = value := by
  cases target <;> simp only [guardCandidate] at candidate <;> try contradiction
  rename_i named
  split at candidate
  · rename_i selected
    simp only [Option.some.injEq, Prod.mk.injEq] at candidate
    rcases candidate with ⟨rfl, rfl⟩
    simp only [Bool.and_eq_true, decide_eq_true_eq] at selected
    have singleton : bounds.lower = bounds.upper := selected.2
    have within := (Expr.infer_sound inferred fits).1
    exact ⟨rfl, by simp only [Interval.Contains] at within; omega⟩
  · contradiction

def refineComparison (analysis : Analysis) (ranges : Ranges) (operator : Comparison)
    (left right : Expr) (truth : Bool) : Ranges :=
  match left.infer ranges, right.infer ranges with
  | some a, some b =>
      match guardCandidate analysis left right b with
      | some (index, threshold) => ranges.refineName index operator threshold truth
      | none =>
          match guardCandidate analysis right left a with
          | some (index, threshold) => ranges.refineName index operator.swap threshold truth
          | none => ranges
  | _, _ => ranges

theorem refineComparison_sound {analysis : Analysis} {ranges : Ranges} {values : Store}
    {operator : Comparison} {left right : Expr} {truth : Bool}
    (fits : Fits ranges values)
    (known : operator.evaluate (left.evaluate values) (right.evaluate values) = truth) :
    Fits (refineComparison analysis ranges operator left right truth) values := by
  unfold refineComparison
  split
  · rename_i a b leftFound rightFound
    split
    · rename_i index threshold selected
      have candidate := guardCandidate_sound selected rightFound fits
      apply Ranges.refineName_sound fits
      · rw [← candidate.1]
        exact Expr.safe_value (Expr.infer_sound leftFound fits).2
      · simpa only [candidate.1, candidate.2] using known
    · split
      · rename_i index threshold selected
        have candidate := guardCandidate_sound selected leftFound fits
        apply Ranges.refineName_sound fits
        · rw [← candidate.1]
          exact Expr.safe_value (Expr.infer_sound rightFound fits).2
        · rw [← candidate.1, ← candidate.2, Comparison.swap_evaluate]
          exact known
      · exact fits
  · exact fits

theorem guardCandidate_refinable {analysis : Analysis} {target threshold : Expr}
    {bounds : Interval} {index : Nat} {value : Int}
    (candidate : guardCandidate analysis target threshold bounds = some (index, value)) :
    analysis.refinable index = true := by
  cases target <;> simp only [guardCandidate] at candidate <;> try contradiction
  rename_i named
  split at candidate
  · rename_i selected
    simp only [Option.some.injEq, Prod.mk.injEq] at candidate
    rcases candidate with ⟨rfl, rfl⟩
    simp only [Bool.and_eq_true, decide_eq_true_eq] at selected
    exact selected.1.1
  · contradiction

theorem Ranges.refineName_other {ranges : Ranges} {target index : Nat}
    {operator : Comparison} {threshold : Int} {truth : Bool} (different : index ≠ target) :
    ranges.refineName target operator threshold truth index = ranges index := by
  cases found : ranges target with
  | none => simp only [refineName, found]
  | some bounds => simp only [refineName, found, put, different, ↓reduceIte]

theorem Ranges.refineName_none {ranges : Ranges} {target index : Nat}
    {operator : Comparison} {threshold : Int} {truth : Bool} (absent : ranges index = none) :
    ranges.refineName target operator threshold truth index = none := by
  by_cases same : index = target
  · subst target
    simp only [refineName, absent]
  · rw [refineName_other same, absent]

/-- Scalar guards cannot alter immutable declaration cells, regardless of
whether their exact initial value was an Ada-static expression. -/
theorem refineComparison_preserves_fixed {analysis : Analysis} {ranges : Ranges}
    {operator : Comparison} {left right : Expr} {truth : Bool} {index : Nat}
    (readonly : analysis.refinable index = false) :
    refineComparison analysis ranges operator left right truth index = ranges index := by
  have unchanged : ∀ target bounds value,
      guardCandidate analysis left right bounds = some (target, value) →
      ranges.refineName target operator value truth index = ranges index := by
    intro target bounds value selected
    apply Ranges.refineName_other
    intro same
    have refinable := guardCandidate_refinable selected
    rw [← same, readonly] at refinable
    contradiction
  cases leftFound : left.infer ranges with
  | none => simp only [refineComparison, leftFound]
  | some a =>
    cases rightFound : right.infer ranges with
    | none => simp only [refineComparison, leftFound, rightFound]
    | some b =>
      cases selected : guardCandidate analysis left right b with
      | some pair =>
        obtain ⟨target, threshold⟩ := pair
        simpa only [refineComparison, leftFound, rightFound, selected] using
          unchanged target b threshold selected
      | none =>
        cases reversed : guardCandidate analysis right left a with
        | none => simp only [refineComparison, leftFound, rightFound, selected, reversed]
        | some pair =>
          obtain ⟨target, threshold⟩ := pair
          simp only [refineComparison, leftFound, rightFound, selected, reversed]
          apply Ranges.refineName_other
          intro same
          have refinable := guardCandidate_refinable reversed
          rw [← same, readonly] at refinable
          contradiction

theorem refineComparison_preserves_none {analysis : Analysis} {ranges : Ranges}
    {operator : Comparison} {left right : Expr} {truth : Bool} {index : Nat}
    (absent : ranges index = none) :
    refineComparison analysis ranges operator left right truth index = none := by
  cases leftFound : left.infer ranges with
  | none => simpa only [refineComparison, leftFound] using absent
  | some a =>
    cases rightFound : right.infer ranges with
    | none => simpa only [refineComparison, leftFound, rightFound] using absent
    | some b =>
      cases selected : guardCandidate analysis left right b with
      | some pair =>
        obtain ⟨target, threshold⟩ := pair
        simpa only [refineComparison, leftFound, rightFound, selected] using
          (Ranges.refineName_none (target := target) (operator := operator)
            (threshold := threshold) (truth := truth) absent)
      | none =>
        cases reversed : guardCandidate analysis right left a with
        | none => simpa only [refineComparison, leftFound, rightFound, selected, reversed] using absent
        | some pair =>
          obtain ⟨target, threshold⟩ := pair
          simpa only [refineComparison, leftFound, rightFound, selected, reversed] using
            (Ranges.refineName_none (target := target) (operator := operator.swap)
              (threshold := threshold) (truth := truth) absent)

theorem Ranges.join_fixed {left right : Ranges} {index : Nat} {bounds : Interval}
    (a : left index = some bounds) (b : right index = some bounds)
    (nonempty : bounds.isEmpty = false) : (left.join right) index = some bounds := by
  simp only [join, a, b, Interval.join, nonempty, Bool.false_eq_true, ↓reduceIte,
    Int.min_self, Int.max_self]

theorem Ranges.join_none_left {left right : Ranges} {index : Nat}
    (absent : left index = none) : (left.join right) index = none := by
  simp only [join, absent]

/-- Every declared identity has a current interval contained in its immutable
base interval. This is an abstract invariant, independent of execution samples. -/
def Ranges.Refines (current declared : Ranges) : Prop :=
  ∀ index target, declared index = some target →
    ∃ bounds, current index = some bounds ∧
      ∀ value, bounds.Contains value → target.Contains value

theorem Ranges.refines_refl (ranges : Ranges) : ranges.Refines ranges :=
  fun _ target found => ⟨target, found, fun _ within => within⟩

theorem Ranges.Refines.fits {current declared : Ranges} {values : Store}
    (refined : current.Refines declared) (fits : Fits current values) : Fits declared values := by
  intro index target found
  obtain ⟨bounds, present, included⟩ := refined index target found
  exact included _ (fits index bounds present)

theorem Ranges.refineName_refines {current declared : Ranges} {index : Nat}
    {operator : Comparison} {threshold : Int} {truth : Bool}
    (refined : current.Refines declared) :
    (current.refineName index operator threshold truth).Refines declared := by
  cases targetFound : current index with
  | none => simpa only [refineName, targetFound] using refined
  | some incoming =>
    intro other target found
    obtain ⟨bounds, present, included⟩ := refined other target found
    simp only [refineName, targetFound]
    by_cases same : other = index
    · subst other
      rw [targetFound] at present
      cases present
      exact ⟨incoming.refineOrKeep operator threshold truth,
        by simp only [put, ↓reduceIte], fun value within =>
          included value (Interval.refineOrKeep_subset incoming operator threshold truth value within)⟩
    · exact ⟨bounds, by simpa only [put, same, ↓reduceIte] using present, included⟩

theorem refineComparison_refines {analysis : Analysis} {current declared : Ranges}
    {operator : Comparison} {left right : Expr} {truth : Bool}
    (refined : current.Refines declared) :
    (refineComparison analysis current operator left right truth).Refines declared := by
  unfold refineComparison
  split
  · split
    · exact Ranges.refineName_refines refined
    · split
      · exact Ranges.refineName_refines refined
      · exact refined
  · exact refined

theorem Ranges.join_refines {left right declared : Ranges}
    (a : left.Refines declared) (b : right.Refines declared) :
    (left.join right).Refines declared := by
  intro index target found
  obtain ⟨l, leftFound, leftIncluded⟩ := a index target found
  obtain ⟨r, rightFound, rightIncluded⟩ := b index target found
  exact ⟨l.join r, by simp only [join, leftFound, rightFound],
    Interval.join_subset leftIncluded rightIncluded⟩

theorem Analysis.widen_refines {analysis : Analysis} {current : Ranges}
    (refined : current.Refines analysis.declared) :
    (analysis.widen current).Refines analysis.declared := by
  intro index target found
  unfold widen
  split
  · exact ⟨target, found, fun _ within => within⟩
  · exact refined index target found

theorem Ranges.put_refines {current declared : Ranges} {index : Nat} {bounds : Interval}
    (refined : current.Refines declared) :
    Ranges.Refines (put current index (some bounds)) (put declared index (some bounds)) := by
  intro other target found
  by_cases same : other = index
  · subst other
    simp only [put, ↓reduceIte, Option.some.injEq] at found
    subst target
    exact ⟨bounds, by simp only [put, ↓reduceIte], fun _ within => within⟩
  · simp only [put, same, ↓reduceIte] at found
    obtain ⟨currentBounds, present, included⟩ := refined other target found
    exact ⟨currentBounds, by simpa only [put, same, ↓reduceIte] using present, included⟩

theorem Assignment.after_refines {assignment : Assignment} {current declared : Ranges}
    {mutable : Mutability} (checked : assignment.check current mutable declared = true)
    (refined : current.Refines declared) : (assignment.after current).Refines declared := by
  simp only [Assignment.check, Bool.and_eq_true] at checked
  cases target : declared assignment.target with
  | none => simp [target] at checked
  | some targetBounds =>
    cases value : assignment.value.infer current with
    | none => simp [value, target] at checked
    | some valueBounds =>
      have included : valueBounds.included targetBounds = true := by
        have compatible : assignment.bounds = targetBounds ∧
            valueBounds.isEmpty = false ∧ valueBounds.included targetBounds = true := by
          simpa only [target, value, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] using checked.2
        exact compatible.2.2
      intro index bounds found
      by_cases same : index = assignment.target
      · subst index
        rw [target] at found
        cases found
        exact ⟨valueBounds, by simp only [after, put, ↓reduceIte, value],
          fun _ within => Interval.included_sound included within⟩
      · obtain ⟨original, present, fits⟩ := refined index bounds found
        exact ⟨original, by simpa only [after, put, same, ↓reduceIte] using present, fits⟩

def Ranges.Bounded (ranges : Ranges) : Prop :=
  ∀ index bounds, ranges index = some bounds → bounds.Bounded

theorem Ranges.join_bounded {left right : Ranges} (a : left.Bounded) (b : right.Bounded) :
    (left.join right).Bounded := by
  intro index bounds found
  unfold join at found
  split at found
  · rename_i l r leftFound rightFound
    cases found
    exact Interval.join_bounded (a index l leftFound) (b index r rightFound)
  · contradiction

theorem Ranges.refineName_bounded {ranges : Ranges} {index : Nat} {operator : Comparison}
    {threshold : Int} {truth : Bool} (bounded : ranges.Bounded) :
    (ranges.refineName index operator threshold truth).Bounded := by
  cases present : ranges index with
  | none => simpa only [refineName, present] using bounded
  | some incoming =>
    intro other bounds found
    simp only [refineName, present] at found
    by_cases same : other = index
    · subst other
      simp only [put, ↓reduceIte, Option.some.injEq] at found
      subst bounds
      exact Interval.refineOrKeep_bounded (bounded index incoming present) _ _ _
    · exact bounded other bounds (by simpa only [put, same, ↓reduceIte] using found)

theorem refineComparison_bounded {analysis : Analysis} {ranges : Ranges}
    {operator : Comparison} {left right : Expr} {truth : Bool} (bounded : ranges.Bounded) :
    (refineComparison analysis ranges operator left right truth).Bounded := by
  unfold refineComparison
  split
  · split
    · exact Ranges.refineName_bounded bounded
    · split
      · exact Ranges.refineName_bounded bounded
      · exact bounded
  · exact bounded

theorem Analysis.widen_bounded {analysis : Analysis} {ranges : Ranges}
    (current : ranges.Bounded) (declared : analysis.declared.Bounded) :
    (analysis.widen ranges).Bounded := by
  intro index bounds found
  unfold widen at found
  split at found
  · exact declared index bounds found
  · exact current index bounds found

theorem Ranges.put_bounded {ranges : Ranges} {index : Nat} {bounds : Interval}
    (current : ranges.Bounded) (bounded : bounds.Bounded) :
    Ranges.Bounded (put ranges index (some bounds)) := by
  intro other interval found
  by_cases same : other = index
  · subst other
    simp only [put, ↓reduceIte, Option.some.injEq] at found
    subst interval
    exact bounded
  · exact current other interval (by simpa only [put, same, ↓reduceIte] using found)

theorem Assignment.after_bounded {assignment : Assignment} {ranges : Ranges}
    (bounded : ranges.Bounded) : (assignment.after ranges).Bounded := by
  intro index bounds found
  by_cases same : index = assignment.target
  · subst index
    simp only [after, put, ↓reduceIte] at found
    exact Expr.infer_bounded found
  · exact bounded index bounds (by simpa only [after, put, same, ↓reduceIte] using found)

theorem ObjectBindings.ranges_bounded {bindings : ObjectBindings} (valid : bindings.Valid) :
    bindings.ranges.Bounded := by
  intro index bounds found
  simp only [ObjectBindings.ranges] at found
  split at found
  · contradiction
  · simp only [Option.map_eq_some_iff] at found
    obtain ⟨binding, present, rfl⟩ := found
    exact (valid binding (List.mem_of_getElem? present)).1

end Silver.Integer

namespace Silver.Predicate

structure Flow where
  path : PathFacts.Context
  scalars : Integer.Ranges

def Flow.initial (analysis : Integer.Analysis) (path : PathFacts.Context) : Flow :=
  ⟨path, analysis.declared⟩

def Flow.join (left right : Flow) : Flow :=
  ⟨left.path.join right.path, left.scalars.join right.scalars⟩

def Flow.Allows (flow : Flow) (valid : Bool) (length : Nat) (rejected : Bool)
    (integers : Integer.Store) : Prop :=
  flow.path.Allows valid length rejected ∧ Integer.Fits flow.scalars integers

theorem Flow.join_left {left right : Flow} {valid rejected : Bool} {length : Nat}
    {integers : Integer.Store} (allowed : left.Allows valid length rejected integers) :
    (left.join right).Allows valid length rejected integers :=
  ⟨PathFacts.Context.join_left allowed.1, Integer.Ranges.join_left allowed.2⟩

theorem Flow.join_right {left right : Flow} {valid rejected : Bool} {length : Nat}
    {integers : Integer.Store} (allowed : right.Allows valid length rejected integers) :
    (left.join right).Allows valid length rejected integers :=
  ⟨PathFacts.Context.join_right allowed.1, Integer.Ranges.join_right allowed.2⟩

end Silver.Predicate
