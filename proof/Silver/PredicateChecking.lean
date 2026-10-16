module

public import Silver.PathFacts
public import Silver.PredicateSemantics
public import Silver.StringLengthRefinement

@[expose] public section

/-! Executable path refinement. Parsing, unconditional name resolution and
Boolean grammar checking remain separate admission obligations. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

def Comparison.complement : Comparison → Comparison
  | .eq => .ne | .ne => .eq | .lt => .ge | .le => .gt | .gt => .le | .ge => .lt

def Comparison.swap : Comparison → Comparison
  | .eq => .eq | .ne => .ne | .lt => .gt | .le => .ge | .gt => .lt | .ge => .le

theorem Comparison.complement_evaluate (operator : Comparison) (left right : Nat) :
    operator.complement.evaluate left right = !(operator.evaluate left right) := by
  cases operator <;> simp only [complement, evaluate, ← decide_not] <;>
    apply Bool.eq_iff_iff.mpr <;> simp only [decide_eq_true_eq] <;> omega

theorem Comparison.swap_evaluate (operator : Comparison) (left right : Nat) :
    operator.swap.evaluate left right = operator.evaluate right left := by
  cases operator <;> simp [swap, evaluate, eq_comm]

def ceiling (context : Context) : Nat :=
  match context.validLengths with | none => 0 | some interval => interval.upper

theorem allows_ceiling {context : Context} {valid : Bool} {length : Nat} {rejected : Bool}
    (allowed : context.Allows valid length rejected) : length ≤ ceiling context := by
  cases valid with
  | false => have zero := allowed.1; simp [zero]
  | true =>
      cases found : context.validLengths with
      | none => simp [Context.Allows, found, Region.Contains] at allowed
      | some interval =>
          simp only [Context.Allows, ↓reduceIte, found, Region.Contains] at allowed
          simpa only [ceiling, found] using allowed.2

def keepIf (context : Context) (condition : Bool) : Context :=
  if condition then context else Context.empty

theorem keepIf_sound {context : Context} {valid : Bool} {length : Nat} {rejected : Bool}
    {condition : Bool} (allowed : context.Allows valid length rejected)
    (known : condition = true) : (keepIf context condition).Allows valid length rejected := by
  simpa only [keepIf, known, ↓reduceIte] using allowed

def below (context : Context) (threshold : Nat) : Context :=
  if threshold = 0 then Context.empty else context.intersect ⟨0, threshold - 1⟩

def above (context : Context) (threshold : Nat) : Context :=
  context.intersect ⟨threshold + 1, ceiling context⟩

theorem below_sound {context : Context} {valid : Bool} {length threshold : Nat}
    {rejected : Bool} (allowed : context.Allows valid length rejected) (less : length < threshold) :
    (below context threshold).Allows valid length rejected := by
  have positive : threshold ≠ 0 := by omega
  simp only [below, positive, ↓reduceIte]
  apply (Context.intersect_iff _ _ _ _ _).mpr
  exact ⟨allowed, Nat.zero_le _, by change length ≤ threshold - 1; omega⟩

theorem above_sound {context : Context} {valid : Bool} {length threshold : Nat}
    {rejected : Bool} (allowed : context.Allows valid length rejected) (greater : threshold < length) :
    (above context threshold).Allows valid length rejected := by
  apply (Context.intersect_iff _ _ _ _ _).mpr
  exact ⟨allowed, greater, allows_ceiling allowed⟩

/-- The non-equality result uses the interval hull of the two remaining sides.
An interior hole may be forgotten, while excluded endpoints are retained. -/
def refineInputTrue (context : Context) (operator : Comparison) (threshold : Nat) : Context :=
  match operator with
  | .eq => context.intersect ⟨threshold, threshold⟩
  | .ne => (below context threshold).join (above context threshold)
  | .lt => below context threshold
  | .le => context.intersect ⟨0, threshold⟩
  | .gt => above context threshold
  | .ge => context.intersect ⟨threshold, ceiling context⟩

theorem refineInputTrue_sound {context : Context} {operator : Comparison} {threshold length : Nat}
    {valid rejected : Bool} (allowed : context.Allows valid length rejected)
    (known : operator.evaluate length threshold = true) :
    (refineInputTrue context operator threshold).Allows valid length rejected := by
  cases operator with
  | eq =>
      simp only [Comparison.evaluate, decide_eq_true_eq] at known
      exact (Context.intersect_iff _ _ _ _ _).mpr ⟨allowed, by simp [Interval.Contains, known]⟩
  | ne =>
      simp only [Comparison.evaluate, decide_eq_true_eq] at known
      by_cases less : length < threshold
      · exact Context.join_left (below_sound allowed less)
      · exact Context.join_right (above_sound allowed (by omega))
  | lt => exact below_sound allowed (of_decide_eq_true known)
  | le =>
      exact (Context.intersect_iff _ _ _ _ _).mpr
        ⟨allowed, Nat.zero_le _, of_decide_eq_true known⟩
  | gt => exact above_sound allowed (of_decide_eq_true known)
  | ge =>
      exact (Context.intersect_iff _ _ _ _ _).mpr
        ⟨allowed, of_decide_eq_true known, allows_ceiling allowed⟩

def refineInput (context : Context) (operator : Comparison) (threshold : Nat) (truth : Bool) : Context :=
  refineInputTrue context (if truth then operator else operator.complement) threshold

theorem refineInput_sound {context : Context} {operator : Comparison} {threshold length : Nat}
    {valid rejected truth : Bool} (allowed : context.Allows valid length rejected)
    (known : operator.evaluate length threshold = truth) :
    (refineInput context operator threshold truth).Allows valid length rejected := by
  apply refineInputTrue_sound allowed
  cases truth with
  | true => exact known
  | false => simp only [Bool.false_eq_true, ↓reduceIte, Comparison.complement_evaluate, known, Bool.not_false]

def refineBounds (context : Context) (operator : Comparison) (left right : Bound)
    (truth : Bool) : Context :=
  match left, right with
  | .fixed a, .fixed b => keepIf context (operator.evaluate a b == truth)
  | .argument, .fixed b => refineInput context operator b truth
  | .fixed a, .argument => refineInput context operator.swap a truth
  | .argument, .argument => keepIf context (operator.evaluate 0 0 == truth)

theorem refineBounds_sound {context : Context} {operator : Comparison} {left right : Bound}
    {length : Nat} {valid rejected truth : Bool} (allowed : context.Allows valid length rejected)
    (known : operator.evaluate (left.length length) (right.length length) = truth) :
    (refineBounds context operator left right truth).Allows valid length rejected := by
  cases left with
  | fixed a =>
      cases right with
      | fixed b => exact keepIf_sound allowed (by simpa [Bound.length, known] using known)
      | argument =>
          apply refineInput_sound allowed
          simpa only [Comparison.swap_evaluate, Bound.length] using known
  | argument =>
      cases right with
      | fixed b => exact refineInput_sound allowed known
      | argument =>
          apply keepIf_sound allowed
          cases operator <;> simp_all [Comparison.evaluate, Bound.length]

def equalIncreasing (context : Context) (left right : Summary) : Context :=
  let candidate := (right.staticLength - left.staticLength) / (left.dynamicCount - right.dynamicCount)
  keepIf (context.intersect ⟨candidate, candidate⟩)
    (decide (left.length candidate = right.length candidate))

theorem increasing_equal_point {left right : Summary} {length : Nat}
    (slope : right.dynamicCount < left.dynamicCount)
    (equal : left.length length = right.length length) :
    length = (right.staticLength - left.staticLength) / (left.dynamicCount - right.dynamicCount) := by
  have products : right.dynamicCount * length ≤ left.dynamicCount * length :=
    Nat.mul_le_mul_right length (Nat.le_of_lt slope)
  have difference : right.staticLength - left.staticLength =
      (left.dynamicCount - right.dynamicCount) * length := by
    rw [Nat.sub_mul]
    dsimp [Summary.length] at equal
    omega
  rw [difference, Nat.mul_div_cancel_left _ (by omega)]

theorem equalIncreasing_sound {context : Context} {left right : Summary} {length : Nat}
    {valid rejected : Bool} (allowed : context.Allows valid length rejected)
    (slope : right.dynamicCount < left.dynamicCount)
    (equal : left.length length = right.length length) :
    (equalIncreasing context left right).Allows valid length rejected := by
  have point := increasing_equal_point slope equal
  unfold equalIncreasing
  apply keepIf_sound
  · apply (Context.intersect_iff _ _ _ _ _).mpr
    exact ⟨allowed, by simp [Interval.Contains, ← point]⟩
  · simpa only [← point, decide_eq_true_eq] using equal

def refineAffineEqual (context : Context) (left right : Summary) : Context :=
  if left.dynamicCount = right.dynamicCount then
    keepIf context (decide (left.staticLength = right.staticLength))
  else if right.dynamicCount < left.dynamicCount then equalIncreasing context left right
  else equalIncreasing context right left

theorem refineAffineEqual_sound {context : Context} {left right : Summary} {length : Nat}
    {valid rejected : Bool} (allowed : context.Allows valid length rejected)
    (equal : left.length length = right.length length) :
    (refineAffineEqual context left right).Allows valid length rejected := by
  unfold refineAffineEqual
  split
  · rename_i same
    apply keepIf_sound allowed
    simp only [decide_eq_true_eq]
    dsimp [Summary.length] at equal
    rw [same] at equal
    exact Nat.add_right_cancel equal
  · rename_i different
    split
    · exact equalIncreasing_sound allowed (by assumption) equal
    · exact equalIncreasing_sound allowed (by omega) equal.symm

def LengthOperand.bound (shape : Shape) : LengthOperand → Option Bound
  | .literal value => some (.fixed value)
  | .binding index => (shape index).map CellInfo.bound

theorem LengthOperand.evaluate_bound {operand : LengthOperand} {shape : Shape}
    {values : Values} {input : Source} {bound : Bound}
    (state : Fits shape input values) (found : operand.bound shape = some bound) :
    operand.evaluate values = bound.length input.length := by
  cases operand with
  | literal value => cases found; rfl
  | binding index =>
      simp only [LengthOperand.bound, Option.map_eq_some_iff] at found
      obtain ⟨info, found, rfl⟩ := found
      exact (state index info found).1

def refineLength (shape : Shape) (context : Context) (operator : Comparison)
    (left : Nat) (right : LengthOperand) (truth : Bool) : Context :=
  match shape left, right.bound shape with
  | some info, some bound => refineBounds context operator info.bound bound truth
  | _, _ => context

theorem refineLength_sound {shape : Shape} {context : Context} {operator : Comparison}
    {left : Nat} {right : LengthOperand} {truth valid rejected : Bool}
    {values : Values} {input : Source} (state : Fits shape input values)
    (allowed : context.Allows valid input.length rejected)
    (known : operator.evaluate (values left).length (right.evaluate values) = truth) :
    (refineLength shape context operator left right truth).Allows valid input.length rejected := by
  unfold refineLength
  split
  · rename_i info bound foundLeft foundRight
    apply refineBounds_sound allowed
    rwa [← (state left info foundLeft).1, ← LengthOperand.evaluate_bound state foundRight]
  · exact allowed

def refineString (shape : Shape) (context : Context) (unequal : Bool)
    (left right : Expression) (truth : Bool) (ranges : Integer.Ranges := Integer.emptyRanges) : Context :=
  if unequal != truth then
    match left.inferLength shape ranges, right.inferLength shape ranges with
    | some a, some b => refineLengthOverlap context a b
    | _, _ => context
  else context

theorem refineString_sound {shape : Shape} {context : Context} {unequal truth valid rejected : Bool}
    {left right : Expression} {values : Values} {input : Source}
    {ranges : Integer.Ranges} {integers : Integer.Store}
    (state : Fits shape input values) (allowed : context.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers)
    (known : (Condition.stringCompare unequal left right).evaluate values input valid integers = truth) :
    (refineString shape context unequal left right truth ranges).Allows valid input.length rejected := by
  unfold refineString
  split
  · rename_i equalBranch
    have equal : left.evaluate values input integers = right.evaluate values input integers := by
      cases unequal <;> cases truth <;> simp_all [Condition.evaluate]
    split
    · rename_i a b leftFound rightFound
      exact string_image_equality_overlap leftFound rightFound state scalarState allowed equal
    · exact allowed
  · exact allowed

def Condition.refine (shape : Shape) (condition : Condition) (context : Context) (truth : Bool)
    (ranges : Integer.Ranges := Integer.emptyRanges) : Context :=
  match condition with
  | .stringCompare unequal left right => refineString shape context unequal left right truth ranges
  | .lengthCompare operator left right => refineLength shape context operator left right truth
  | .scalarCompare _ _ _ => context
  | .inputValid => if truth then context.assumeValid else context.assumeInvalid
  | .parenthesized inner => inner.refine shape context truth ranges
  | .negated inner => inner.refine shape context (!truth) ranges
  | .andThen left right =>
      let reached := left.refine shape context true ranges
      if truth then right.refine shape reached true ranges
      else (left.refine shape context false ranges).join (right.refine shape reached false ranges)
  | .orElse left right =>
      let reached := left.refine shape context false ranges
      if truth then (left.refine shape context true ranges).join (right.refine shape reached true ranges)
      else right.refine shape reached false ranges

/-- Every actual outcome is represented in its refined context. Right-hand
short-circuit operands receive only the facts from the reached left outcome. -/
theorem Condition.refine_sound {condition : Condition} {shape : Shape} {hasArguments : Bool}
    {context : Context} {ranges : Integer.Ranges} {integers : Integer.Store} {values : Values} {input : Source} {valid rejected : Bool}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape)
    (allowed : context.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers) :
    (condition.refine shape context (condition.evaluate values input valid integers) ranges).Allows valid input.length rejected := by
  induction condition generalizing context with
  | stringCompare unequal left right =>
      exact refineString_sound state allowed scalarState rfl
  | lengthCompare operator left right => exact refineLength_sound state allowed rfl
  | scalarCompare => exact allowed
  | inputValid =>
      cases valid with
      | true => exact (Context.assumeValid_iff _ _ _ _).mpr ⟨allowed, rfl⟩
      | false => exact (Context.assumeInvalid_iff _ _ _ _).mpr ⟨allowed, rfl⟩
  | parenthesized inner ih => exact ih readable allowed
  | negated inner ih => simpa only [refine, evaluate, Bool.not_not] using ih readable allowed
  | andThen left right ihl ihr =>
      have leftAllowed := ihl readable.1 allowed
      cases outcome : left.evaluate values input valid integers with
      | false =>
          simp only [outcome] at leftAllowed
          simpa only [refine, evaluate, outcome, Bool.false_eq_true, ↓reduceIte] using
            (Context.join_left (right := right.refine shape (left.refine shape context true ranges) false ranges) leftAllowed)
      | true =>
          simp only [outcome] at leftAllowed
          have rightAllowed := ihr readable.2 leftAllowed
          cases rightOutcome : right.evaluate values input valid integers with
          | false =>
              simp only [rightOutcome] at rightAllowed
              simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using
                (Context.join_right (left := left.refine shape context false ranges) rightAllowed)
          | true => simpa only [refine, evaluate, outcome, rightOutcome, ↓reduceIte] using rightAllowed
  | orElse left right ihl ihr =>
      have leftAllowed := ihl readable.1 allowed
      cases outcome : left.evaluate values input valid integers with
      | true =>
          simp only [outcome] at leftAllowed
          simpa only [refine, evaluate, outcome, ↓reduceIte] using
            (Context.join_left (right := right.refine shape (left.refine shape context false ranges) true ranges) leftAllowed)
      | false =>
          simp only [outcome] at leftAllowed
          have rightAllowed := ihr readable.2 leftAllowed
          cases rightOutcome : right.evaluate values input valid integers with
          | true =>
              simp only [rightOutcome] at rightAllowed
              simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using
                (Context.join_right (left := left.refine shape context true ranges) rightAllowed)
          | false => simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using rightAllowed

def fitsSummary (context : Context) (summary : Summary) : Bool :=
  (match context.validLengths with
    | none => true
    | some interval => decide (summary.length interval.upper ≤ maxSourceLength)) &&
    (!context.invalidReachable || decide (summary.length 0 ≤ maxSourceLength))

theorem fitsSummary_sound {context : Context} {summary : Summary} {length : Nat}
    {valid rejected : Bool} (allowed : context.Allows valid length rejected)
    (checked : fitsSummary context summary = true) : summary.length length ≤ maxSourceLength := by
  simp only [fitsSummary, Bool.and_eq_true] at checked
  cases valid with
  | false =>
      rcases allowed with ⟨rfl, reachable, _⟩
      simpa only [reachable, Bool.not_true, Bool.false_or, decide_eq_true_eq] using checked.2
  | true =>
      cases found : context.validLengths with
      | none => simp [Context.Allows, found, Region.Contains] at allowed
      | some interval =>
          simp only [Context.Allows, ↓reduceIte, found, Region.Contains] at allowed
          have fits : interval.Fits summary maxSourceLength := by
            change summary.length interval.upper ≤ maxSourceLength
            simpa only [found, decide_eq_true_eq] using checked.1
          exact Interval.fits_sound fits allowed

def fitsLengthSummary (context : Context) (summary : LengthSummary) : Bool :=
  decide (summary.staticLength ≤ maxSourceLength) &&
    (summary.empty || fitsSummary context summary.upper)

theorem fitsLengthSummary_static {context : Context} {summary : LengthSummary}
    (checked : fitsLengthSummary context summary = true) : summary.staticLength ≤ maxSourceLength := by
  simp only [fitsLengthSummary, Bool.and_eq_true] at checked
  exact of_decide_eq_true checked.1

theorem fitsLengthSummary_sound {context : Context} {summary : LengthSummary}
    {length actualLength : Nat} {valid rejected : Bool}
    (allowed : context.Allows valid length rejected) (within : summary.Contains length actualLength)
    (checked : fitsLengthSummary context summary = true) :
    summary.upper.length length ≤ maxSourceLength := by
  simp only [fitsLengthSummary, Bool.and_eq_true] at checked
  have bound := checked.2
  simp only [within.1, Bool.false_or] at bound
  exact fitsSummary_sound allowed bound

def Condition.checkBounds (shape : Shape) (condition : Condition) (context : Context)
    (ranges : Integer.Ranges := Integer.emptyRanges) : Bool :=
  match condition with
  | .stringCompare _ left right =>
      match left.inferLength shape ranges, right.inferLength shape ranges with
      | some a, some b => fitsLengthSummary context a && fitsLengthSummary context b
      | _, _ => false
  | .lengthCompare _ left right =>
      match shape left, right.bound shape with
      | some info, some bound => fitsSummary context info.bound.summary && fitsSummary context bound.summary
      | _, _ => false
  | .scalarCompare _ left right => (left.infer ranges).isSome && (right.infer ranges).isSome
  | .inputValid => true
  | .parenthesized inner | .negated inner => inner.checkBounds shape context ranges
  | .andThen left right =>
      left.checkBounds shape context ranges && right.checkBounds shape (left.refine shape context true ranges) ranges
  | .orElse left right =>
      left.checkBounds shape context ranges && right.checkBounds shape (left.refine shape context false ranges) ranges

/-- Operand bounds use incoming facts, including only the earlier operand's
selected outcome when the right-hand side is reached. -/
theorem Condition.checkBounds_sound {condition : Condition} {shape : Shape} {hasArguments : Bool}
    {context : Context} {ranges : Integer.Ranges} {integers : Integer.Store} {values : Values} {input : Source} {valid rejected : Bool}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape)
    (allowed : context.Allows valid input.length rejected)
    (checked : condition.checkBounds shape context ranges = true)
    (scalarState : Integer.Fits ranges integers) :
    condition.Safe shape values input valid integers := by
  induction condition generalizing context with
  | stringCompare unequal left right =>
      simp only [checkBounds] at checked
      split at checked
      · rename_i a b leftFound rightFound
        simp only [Bool.and_eq_true] at checked
        exact ⟨Expression.inferLength_runtimeSafe leftFound state scalarState
            (fitsLengthSummary_sound allowed (Expression.inferLength_sound leftFound state scalarState).1 checked.1) (Nat.le_refl _),
          Expression.inferLength_runtimeSafe rightFound state scalarState
            (fitsLengthSummary_sound allowed (Expression.inferLength_sound rightFound state scalarState).1 checked.2) (Nat.le_refl _)⟩
      · contradiction
  | lengthCompare operator left right =>
      simp only [checkBounds] at checked
      split at checked
      · rename_i info bound leftFound rightFound
        simp only [Bool.and_eq_true] at checked
        have leftBound := fitsSummary_sound allowed checked.1
        have rightBound := fitsSummary_sound allowed checked.2
        change (values left).length ≤ maxSourceLength ∧ right.evaluate values ≤ maxSourceLength
        rw [(state left info leftFound).1, LengthOperand.evaluate_bound state rightFound]
        exact ⟨by simpa only [Bound.summary_length] using leftBound,
          by simpa only [Bound.summary_length] using rightBound⟩
      · contradiction
  | scalarCompare operator left right =>
      simp only [checkBounds, Bool.and_eq_true, Option.isSome_iff_exists] at checked
      obtain ⟨⟨leftBounds, leftFound⟩, ⟨rightBounds, rightFound⟩⟩ := checked
      exact ⟨(Integer.Expr.infer_sound leftFound scalarState).2,
        (Integer.Expr.infer_sound rightFound scalarState).2⟩
  | inputValid => trivial
  | parenthesized inner ih => exact ih readable allowed checked
  | negated inner ih => exact ih readable allowed checked
  | andThen left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      refine ⟨ihl readable.1 allowed checked.1, ?_⟩
      intro reached
      apply ihr readable.2 _ checked.2
      have next := left.refine_sound (integers := integers) state readable.1 allowed scalarState
      simpa only [reached] using next
  | orElse left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      refine ⟨ihl readable.1 allowed checked.1, ?_⟩
      intro reached
      apply ihr readable.2 _ checked.2
      have next := left.refine_sound (integers := integers) state readable.1 allowed scalarState
      simpa only [reached] using next

theorem Condition.checkedEvaluate_of_checkBounds {condition : Condition} {shape : Shape}
    {hasArguments : Bool} {context : Context} {ranges : Integer.Ranges} {integers : Integer.Store} {values : Values} {input : Source} {valid rejected : Bool}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape)
    (allowed : context.Allows valid input.length rejected)
    (checked : condition.checkBounds shape context ranges = true)
    (scalarState : Integer.Fits ranges integers) :
    condition.checkedEvaluate values input valid integers = some (condition.evaluate values input valid integers) :=
  Condition.checkedEvaluate_refines (condition.checkBounds_sound state readable allowed checked scalarState) state

end Silver.Predicate
