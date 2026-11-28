module

public import Silver.PredicateFlowOperations

@[expose] public section

/-! The native package conditional accumulates branch flows from left to
right; the recursive semantic statement joins nested alternatives from right
to left. These equalities cover the full raw flow domain, including empty
intervals, missing scalar slots and unreachable invalid-input paths. -/
namespace Silver.Integer.Interval

theorem normalize_isEmpty (bounds : Interval) : bounds.normalize.isEmpty = bounds.isEmpty := by
  unfold normalize
  split
  · rename_i empty
    change true = bounds.isEmpty
    exact empty.symm
  · rfl

theorem join_isEmpty (left right : Interval) :
    (left.join right).isEmpty = (left.isEmpty && right.isEmpty) := by
  cases l : left.isEmpty with
  | true => simp only [join, l, ite_true, Bool.true_and, normalize_isEmpty]
  | false =>
    cases r : right.isEmpty with
    | true => simp only [join, l, r, Bool.false_eq_true, ite_false, ite_true, Bool.false_and]
    | false =>
      simp only [join, l, r, Bool.false_eq_true, ite_false, Bool.false_and]
      simp only [isEmpty, decide_eq_false_iff_not] at l r ⊢
      omega

theorem normalize_join (left right : Interval) : (left.join right).normalize = left.join right := by
  unfold normalize
  by_cases both : (left.join right).isEmpty = true
  · rw [ite_eq_left both]
    rw [join_isEmpty, Bool.and_eq_true] at both
    simp only [join, both.1, ite_true, normalize, both.2]
  · rw [ite_eq_right both]

theorem join_normalize_left (left right : Interval) : left.normalize.join right = left.join right := by
  cases empty : left.isEmpty with
  | false => simp only [normalize, empty, Bool.false_eq_true, ite_false]
  | true =>
    rw [normalize, ite_eq_left empty]
    change right.normalize = left.join right
    rw [join, ite_eq_left empty]

theorem join_normalize_right (left right : Interval) : left.join right.normalize = left.join right := by
  rw [join_comm, join_normalize_left, join_comm right left]

private theorem join_nonempty {left right : Interval}
    (l : left.isEmpty = false) (r : right.isEmpty = false) :
    left.join right = ⟨min left.lower right.lower, max left.upper right.upper⟩ := by
  simp only [join, l, r, Bool.false_eq_true, ite_false]

theorem join_assoc (left middle right : Interval) :
    (left.join middle).join right = left.join (middle.join right) := by
  cases l : left.isEmpty with
  | true =>
    have initial : left.join middle = middle.normalize := by rw [join, ite_eq_left l]
    rw [initial, join_normalize_left]
    conv => rhs; rw [join, ite_eq_left l, normalize_join]
  | false =>
    cases m : middle.isEmpty with
    | true =>
      have initial : left.join middle = left := by
        simp only [join, l, m, Bool.false_eq_true, ite_false, ite_true]
      have following : middle.join right = right.normalize := by rw [join, ite_eq_left m]
      rw [initial, following, join_normalize_right]
    | false =>
      cases r : right.isEmpty with
      | true =>
        have lm : (left.join middle).isEmpty = false := by rw [join_isEmpty, l, m]; rfl
        have following : middle.join right = middle := by
          simp only [join, m, r, Bool.false_eq_true, ite_false, ite_true]
        rw [following]
        conv => lhs; rw [join, lm]; simp only [Bool.false_eq_true, ite_false, r, ite_true]
      | false =>
        have lm : (left.join middle).isEmpty = false := by rw [join_isEmpty, l, m]; rfl
        have mr : (middle.join right).isEmpty = false := by rw [join_isEmpty, m, r]; rfl
        rw [join_nonempty lm r, join_nonempty l mr, join_nonempty l m, join_nonempty m r]
        simp only [Int.min_assoc, Int.max_assoc]

end Silver.Integer.Interval

namespace Silver.Integer.Ranges

theorem join_comm (left right : Ranges) : left.join right = right.join left := by
  funext index
  cases l : left index <;> cases r : right index <;>
    simp only [join, l, r, Interval.join_comm]

theorem join_assoc (left middle right : Ranges) :
    (left.join middle).join right = left.join (middle.join right) := by
  funext index
  cases l : left index <;> cases m : middle index <;> cases r : right index <;>
    simp only [join, l, m, r, Interval.join_assoc]

end Silver.Integer.Ranges

namespace Silver.PathFacts

theorem Region.join_assoc (left middle right : Region) :
    (left.join middle).join right = left.join (middle.join right) := by
  cases left <;> cases middle <;> cases right <;>
    simp only [Region.join, Interval.hull, Nat.min_assoc, Nat.max_assoc]

theorem Context.join_assoc (left middle right : Context) :
    (left.join middle).join right = left.join (middle.join right) := by
  simp only [Context.join, Region.join_assoc, Bool.or_assoc]
  congr 1
  cases left.invalidReachable <;> cases middle.invalidReachable <;> cases right.invalidReachable <;>
    simp only [Bool.not_false, Bool.not_true, Bool.false_or, Bool.true_or, Bool.or_false,
      Bool.or_true, Bool.true_and, Bool.and_true, Bool.and_assoc]

end Silver.PathFacts

namespace Silver.Predicate

theorem Flow.join_comm (left right : Flow) : left.join right = right.join left := by
  simp only [Flow.join, PathFacts.Context.join_comm, Integer.Ranges.join_comm]

theorem Flow.join_assoc (left middle right : Flow) :
    (left.join middle).join right = left.join (middle.join right) := by
  simp only [Flow.join, PathFacts.Context.join_assoc, Integer.Ranges.join_assoc]

theorem ActiveFlow.join_assoc (left middle right : ActiveFlow) :
    (left.join middle).join right = left.join (middle.join right) := by
  have values : List.zipWith Integer.Interval.join
      (List.zipWith Integer.Interval.join left.values middle.values) right.values =
      List.zipWith Integer.Interval.join left.values
        (List.zipWith Integer.Interval.join middle.values right.values) := by
    generalize left.values = a, middle.values = b, right.values = c
    induction a generalizing b c with
    | nil => cases b <;> cases c <;> rfl
    | cons first rest ih =>
      cases b <;> cases c <;>
        simp only [List.zipWith_nil_left, List.zipWith_nil_right, List.zipWith_cons_cons,
          Integer.Interval.join_assoc, ih]
  simp only [ActiveFlow.join, PathFacts.Context.join_assoc, values]

end Silver.Predicate
