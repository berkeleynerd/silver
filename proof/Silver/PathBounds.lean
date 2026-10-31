module

public import Silver.PredicateChecking

@[expose] public section

namespace Silver.PathFacts
open Bindings

def Region.Bounded : Region → Prop
  | none => True
  | some interval => interval.upper ≤ maxSourceLength

def Context.Bounded (context : Context) : Prop := context.validLengths.Bounded

theorem Region.intersect_bounded {region : Region} (bounded : region.Bounded) (interval : Interval) :
    (region.intersect interval).Bounded := by
  cases region with
  | none => trivial
  | some before =>
      simp only [intersect, Option.bind_some, Interval.intersect]
      split
      · exact Nat.le_trans (Nat.min_le_left _ _) bounded
      · trivial

theorem Region.join_bounded {left right : Region} (a : left.Bounded) (b : right.Bounded) :
    (left.join right).Bounded := by
  cases left <;> cases right <;> simp_all [join, Bounded, Interval.hull] <;> omega

theorem Context.initial_bounded {capacity : Nat} (bound : capacity ≤ maxSourceLength) :
    (Context.initial capacity).Bounded := bound

theorem Context.empty_bounded : Context.empty.Bounded := trivial

theorem Context.intersect_bounded {context : Context} (bounded : context.Bounded) (interval : Interval) :
    (context.intersect interval).Bounded := Region.intersect_bounded bounded interval

theorem Context.join_bounded {left right : Context} (a : left.Bounded) (b : right.Bounded) :
    (left.join right).Bounded := Region.join_bounded a b

theorem Context.reject_bounded {context : Context} (bounded : context.Bounded) :
    context.reject.Bounded := bounded

theorem Context.assumeValid_bounded {context : Context} (bounded : context.Bounded) :
    context.assumeValid.Bounded := bounded

theorem Context.assumeInvalid_bounded (context : Context) : context.assumeInvalid.Bounded := trivial

theorem Context.input_bound {context : Context} {valid rejected : Bool} {length : Nat}
    (bounded : context.Bounded) (allowed : context.Allows valid length rejected) :
    length ≤ maxSourceLength := by
  cases valid with
  | false => rw [allowed.1]; exact Nat.zero_le _
  | true =>
      cases found : context.validLengths with
      | none => simp [Allows, found, Region.Contains] at allowed
      | some interval =>
          have high : interval.upper ≤ maxSourceLength := by simpa [Bounded, found, Region.Bounded] using bounded
          have within : interval.Contains length := by simpa [Allows, found, Region.Contains] using allowed
          exact Nat.le_trans within.2 high

end Silver.PathFacts

namespace Silver.Predicate
open Bindings Compose PathFacts

theorem keepIf_bounded {context : Context} (bounded : context.Bounded) (condition : Bool) :
    (keepIf context condition).Bounded := by
  cases condition
  · exact Context.empty_bounded
  · exact bounded

theorem below_bounded {context : Context} (bounded : context.Bounded) (threshold : Nat) :
    (below context threshold).Bounded := by
  unfold below
  split
  · exact Context.empty_bounded
  · exact Context.intersect_bounded bounded _

theorem above_bounded {context : Context} (bounded : context.Bounded) (threshold : Nat) :
    (above context threshold).Bounded := Context.intersect_bounded bounded _

theorem refineInputTrue_bounded {context : Context} (bounded : context.Bounded)
    (operator : Comparison) (threshold : Nat) : (refineInputTrue context operator threshold).Bounded := by
  cases operator with
  | eq | le | ge => exact Context.intersect_bounded bounded _
  | ne => exact Context.join_bounded (below_bounded bounded _) (above_bounded bounded _)
  | lt => exact below_bounded bounded _
  | gt => exact above_bounded bounded _

theorem refineInput_bounded {context : Context} (bounded : context.Bounded)
    (operator : Comparison) (threshold : Nat) (truth : Bool) :
    (refineInput context operator threshold truth).Bounded := refineInputTrue_bounded bounded _ _

theorem refineBounds_bounded {context : Context} (bounded : context.Bounded)
    (operator : Comparison) (left right : Bound) (truth : Bool) :
    (refineBounds context operator left right truth).Bounded := by
  cases left <;> cases right
  · exact keepIf_bounded bounded _
  · exact refineInput_bounded bounded _ _ _
  · exact refineInput_bounded bounded _ _ _
  · exact keepIf_bounded bounded _

theorem equalIncreasing_bounded {context : Context} (bounded : context.Bounded) (left right : Summary) :
    (equalIncreasing context left right).Bounded := keepIf_bounded (Context.intersect_bounded bounded _) _

theorem refineAffineEqual_bounded {context : Context} (bounded : context.Bounded) (left right : Summary) :
    (refineAffineEqual context left right).Bounded := by
  unfold refineAffineEqual
  split
  · exact keepIf_bounded bounded _
  · split <;> exact equalIncreasing_bounded bounded _ _

theorem refineLength_bounded {context : Context} (bounded : context.Bounded)
    (shape : Shape) (operator : Comparison) (left : Nat) (right : LengthOperand) (truth : Bool) :
    (refineLength shape context operator left right truth).Bounded := by
  unfold refineLength
  split
  · exact refineBounds_bounded bounded _ _ _ _
  · exact bounded

theorem increasingLengthOverlap_bounded {context : Context} (bounded : context.Bounded)
    (left right : LengthSummary) : (increasingLengthOverlap context left right).Bounded := by
  unfold increasingLengthOverlap
  split
  · exact Context.empty_bounded
  · exact Context.intersect_bounded bounded _

theorem refineLengthOverlap_bounded {context : Context} (bounded : context.Bounded)
    (left right : LengthSummary) : (refineLengthOverlap context left right).Bounded := by
  unfold refineLengthOverlap
  split
  · exact Context.empty_bounded
  · split
    · exact increasingLengthOverlap_bounded bounded _ _
    · split
      · exact increasingLengthOverlap_bounded bounded _ _
      · split
        · exact bounded
        · exact Context.empty_bounded

theorem refineString_bounded {context : Context} (bounded : context.Bounded)
    (shape : Shape) (unequal : Bool) (left right : Expression) (truth : Bool)
    (ranges : Integer.Ranges := Integer.emptyRanges) :
    (refineString shape context unequal left right truth ranges).Bounded := by
  unfold refineString
  split
  · split
    · exact refineLengthOverlap_bounded bounded _ _
    · exact bounded
  · exact bounded

theorem Condition.refine_bounded {flow : Flow} (bounded : flow.path.Bounded)
    (shape : Shape) (analysis : Integer.Analysis) (condition : Condition) (truth : Bool) :
    (condition.refine shape analysis flow truth).path.Bounded := by
  induction condition generalizing flow truth with
  | stringCompare unequal left right => exact refineString_bounded bounded _ _ _ _ _ flow.scalars
  | lengthCompare operator left right => exact refineLength_bounded bounded _ _ _ _ _
  | scalarCompare | characterCompare | booleanLiteral | booleanName | eager | booleanCompare => exact bounded
  | inputValid =>
      cases truth
      · exact Context.assumeInvalid_bounded _
      · exact Context.assumeValid_bounded bounded
  | parenthesized inner ih => exact ih bounded truth
  | negated inner ih => exact ih bounded (!truth)
  | andThen left right ihl ihr =>
      cases truth
      · exact Context.join_bounded (ihl bounded false) (ihr (ihl bounded true) false)
      · exact ihr (ihl bounded true) true
  | orElse left right ihl ihr =>
      cases truth
      · exact ihr (ihl bounded false) false
      · exact Context.join_bounded (ihl bounded true) (ihr (ihl bounded false) true)

theorem fitsSummary_fixed {context : Context} {length : Nat} (bound : length ≤ maxSourceLength) :
    fitsSummary context (Bound.fixed length).summary = true := by
  cases found : context.validLengths <;> simp [fitsSummary, found, Bound.summary, Summary.length, bound]

theorem fitsSummary_argument {context : Context} (bounded : context.Bounded) :
    fitsSummary context Bound.argument.summary = true := by
  cases found : context.validLengths with
  | none => simp [fitsSummary, found, Bound.summary, Summary.length]
  | some interval =>
      have high : interval.upper ≤ maxSourceLength := by
        simpa [Context.Bounded, found, Region.Bounded] using bounded
      simp [fitsSummary, found, Bound.summary, Summary.length, high]

end Silver.Predicate
