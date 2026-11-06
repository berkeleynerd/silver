module

public import Silver.PathFacts
public import Silver.PredicateSemantics
public import Silver.StringLengthRefinement
public import Silver.ScalarFlow

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

def Condition.refine (shape : Shape) (analysis : Integer.Analysis) (condition : Condition)
    (flow : Flow) (truth : Bool) : Flow :=
  match condition with
  | .stringCompare unequal left right =>
      {flow with path := refineString shape flow.path unequal left right truth flow.scalars}
  | .lengthCompare operator left right =>
      {flow with path := refineLength shape flow.path operator left right truth}
  | .scalarCompare operator left right =>
      {flow with scalars := Integer.refineComparison analysis flow.scalars operator left right truth}
  | .inputValid => {flow with path := if truth then flow.path.assumeValid else flow.path.assumeInvalid}
  | .characterCompare _ _ _ | .booleanLiteral _ | .booleanName _ | .eager _ _ _ | .booleanCompare _ _ _ => flow
  | .parenthesized inner => inner.refine shape analysis flow truth
  | .negated inner => inner.refine shape analysis flow (!truth)
  | .andThen left right =>
      let reached := left.refine shape analysis flow true
      if truth then right.refine shape analysis reached true
      else (left.refine shape analysis flow false).join (right.refine shape analysis reached false)
  | .orElse left right =>
      let reached := left.refine shape analysis flow false
      if truth then (left.refine shape analysis flow true).join (right.refine shape analysis reached true)
      else right.refine shape analysis reached false

/-- Both path facts and scalar intervals describe the same actual outcome.
Every reached short-circuit operand receives that complete intermediate flow. -/
theorem Condition.refine_sound {condition : Condition} {shape : Shape} {hasArguments : Bool}
    {analysis : Integer.Analysis} {flow : Flow} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    {booleanAnalysis : Boolean.Analysis} {booleans : Boolean.Store}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape booleanAnalysis)
    (allowed : flow.Allows valid input.length rejected integers) :
    (condition.refine shape analysis flow (condition.evaluate values input valid integers booleans)).Allows
      valid input.length rejected integers := by
  induction condition generalizing flow with
  | stringCompare unequal left right =>
      exact ⟨refineString_sound state allowed.1 allowed.2 rfl, allowed.2⟩
  | lengthCompare operator left right =>
      exact ⟨refineLength_sound state allowed.1 rfl, allowed.2⟩
  | scalarCompare operator left right =>
      exact ⟨allowed.1, Integer.refineComparison_sound allowed.2 rfl⟩
  | inputValid =>
      refine ⟨?_, allowed.2⟩
      cases valid with
      | true => exact (Context.assumeValid_iff _ _ _ _).mpr ⟨allowed.1, rfl⟩
      | false => exact (Context.assumeInvalid_iff _ _ _ _).mpr ⟨allowed.1, rfl⟩
  | characterCompare | booleanLiteral | booleanName | eager | booleanCompare => exact allowed
  | parenthesized inner ih => exact ih readable allowed
  | negated inner ih => simpa only [refine, evaluate, Bool.not_not] using ih readable allowed
  | andThen left right ihl ihr =>
      have leftAllowed := ihl readable.1 allowed
      cases outcome : left.evaluate values input valid integers booleans with
      | false =>
          simp only [outcome] at leftAllowed
          simpa only [refine, evaluate, outcome, Bool.false_eq_true, ↓reduceIte] using
            (Flow.join_left (right := right.refine shape analysis
              (left.refine shape analysis flow true) false) leftAllowed)
      | true =>
          simp only [outcome] at leftAllowed
          have rightAllowed := ihr readable.2 leftAllowed
          cases rightOutcome : right.evaluate values input valid integers booleans with
          | false =>
              simp only [rightOutcome] at rightAllowed
              simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using
                (Flow.join_right (left := left.refine shape analysis flow false) rightAllowed)
          | true => simpa only [refine, evaluate, outcome, rightOutcome, ↓reduceIte] using rightAllowed
  | orElse left right ihl ihr =>
      have leftAllowed := ihl readable.1 allowed
      cases outcome : left.evaluate values input valid integers booleans with
      | true =>
          simp only [outcome] at leftAllowed
          simpa only [refine, evaluate, outcome, ↓reduceIte] using
            (Flow.join_left (right := right.refine shape analysis
              (left.refine shape analysis flow false) true) leftAllowed)
      | false =>
          simp only [outcome] at leftAllowed
          have rightAllowed := ihr readable.2 leftAllowed
          cases rightOutcome : right.evaluate values input valid integers booleans with
          | true =>
              simp only [rightOutcome] at rightAllowed
              simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using
                (Flow.join_right (left := left.refine shape analysis flow true) rightAllowed)
          | false => simpa only [refine, evaluate, outcome, rightOutcome, Bool.false_eq_true, ↓reduceIte] using rightAllowed

theorem Condition.refine_refines {shape : Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool} {declared : Integer.Ranges}
    (refined : flow.scalars.Refines declared) :
    (condition.refine shape analysis flow truth).scalars.Refines declared := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => exact refined
  | scalarCompare => exact Integer.refineComparison_refines refined
  | parenthesized _ ih | negated _ ih => exact ih refined
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      simp only [refine]
      split
      · first | exact ihr (ihl refined) | exact Integer.Ranges.join_refines (ihl refined) (ihr (ihl refined))
      · first | exact ihr (ihl refined) | exact Integer.Ranges.join_refines (ihl refined) (ihr (ihl refined))

theorem Condition.refine_scalars_bounded {shape : Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool}
    (bounded : flow.scalars.Bounded) :
    (condition.refine shape analysis flow truth).scalars.Bounded := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => exact bounded
  | scalarCompare => exact Integer.refineComparison_bounded bounded
  | parenthesized _ ih | negated _ ih => exact ih bounded
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      simp only [refine]
      split
      · first | exact ihr (ihl bounded) | exact Integer.Ranges.join_bounded (ihl bounded) (ihr (ihl bounded))
      · first | exact ihr (ihl bounded) | exact Integer.Ranges.join_bounded (ihl bounded) (ihr (ihl bounded))

/-- Refinement preserves nonempty scalar cells across both sequentially
reached guards and joins of short-circuit outcomes. -/
theorem Condition.refine_nonempty {shape : Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool} {index : Nat}
    (nonempty : ∃ bounds, flow.scalars index = some bounds ∧ bounds.isEmpty = false) :
    ∃ bounds, (condition.refine shape analysis flow truth).scalars index = some bounds ∧
      bounds.isEmpty = false := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => exact nonempty
  | scalarCompare => exact Integer.refineComparison_nonempty nonempty
  | parenthesized _ ih | negated _ ih => exact ih nonempty
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      cases truth <;>
      simp only [refine]
      all_goals first | exact ihr (ihl nonempty) | exact Integer.Ranges.join_nonempty (ihl nonempty) (ihr (ihl nonempty))

/-- Immutable declaration intervals are nonempty exact snapshots. This
premise matters: joins normalize noncanonical empty intervals, which are not
immutable declarations. Empty loop indexes remain eligible for refinement. -/
theorem Condition.refine_preserves_fixed {shape : Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool} {index : Nat} {bounds : Integer.Interval}
    (readonly : analysis.refinable index = false)
    (incoming : flow.scalars index = some bounds) (nonempty : bounds.isEmpty = false) :
    (condition.refine shape analysis flow truth).scalars index = some bounds := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => exact incoming
  | scalarCompare => exact (Integer.refineComparison_preserves_fixed readonly).trans incoming
  | parenthesized _ ih | negated _ ih => exact ih incoming
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      simp only [refine]
      split
      · first | exact ihr (ihl incoming) | exact Integer.Ranges.join_fixed (ihl incoming) (ihr (ihl incoming)) nonempty
      · first | exact ihr (ihl incoming) | exact Integer.Ranges.join_fixed (ihl incoming) (ihr (ihl incoming)) nonempty

/-- Refinement cannot introduce a scalar identity outside the active domain. -/
theorem Condition.refine_preserves_none {shape : Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool} {index : Nat}
    (absent : flow.scalars index = none) :
    (condition.refine shape analysis flow truth).scalars index = none := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => exact absent
  | scalarCompare => exact Integer.refineComparison_preserves_none absent
  | parenthesized _ ih | negated _ ih => exact ih absent
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      simp only [refine]
      split
      · first | exact ihr (ihl absent) | exact Integer.Ranges.join_none_left (ihl absent)
      · first | exact ihr (ihl absent) | exact Integer.Ranges.join_none_left (ihl absent)

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

def Condition.checkBounds (shape : Shape) (analysis : Integer.Analysis) (condition : Condition)
    (flow : Flow) (booleans : Boolean.Analysis := {}) : Bool :=
  match condition with
  | .stringCompare _ left right =>
      match left.inferLength shape flow.scalars, right.inferLength shape flow.scalars with
      | some a, some b => fitsLengthSummary flow.path a && fitsLengthSummary flow.path b
      | _, _ => false
  | .lengthCompare _ left right =>
      match shape left, right.bound shape with
      | some info, some bound => fitsSummary flow.path info.bound.summary && fitsSummary flow.path bound.summary
      | _, _ => false
  | .scalarCompare _ left right => (left.infer flow.scalars).isSome && (right.infer flow.scalars).isSome
  | .characterCompare _ left right =>
      left.check shape.fixedLengths flow.scalars && right.check shape.fixedLengths flow.scalars
  | .inputValid | .booleanLiteral _ => true
  | .booleanName index => booleans.initialized index
  | .parenthesized inner | .negated inner => inner.checkBounds shape analysis flow booleans
  | .andThen left right =>
      left.checkBounds shape analysis flow booleans &&
        right.checkBounds shape analysis (left.refine shape analysis flow true) booleans
  | .orElse left right =>
      left.checkBounds shape analysis flow booleans &&
        right.checkBounds shape analysis (left.refine shape analysis flow false) booleans

  | .eager _ left right | .booleanCompare _ left right =>
      left.checkBounds shape analysis flow booleans && right.checkBounds shape analysis flow booleans

/-- Operand checks use the incoming flow, before any refinement by that
comparison. Static illegal subtrees therefore cannot be hidden by its result. -/
theorem Condition.checkBounds_sound {condition : Condition} {shape : Shape} {hasArguments : Bool}
    {analysis : Integer.Analysis} {flow : Flow} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    {booleanAnalysis : Boolean.Analysis} {booleans : Boolean.Store}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape booleanAnalysis)
    (allowed : flow.Allows valid input.length rejected integers)
    (checked : condition.checkBounds shape analysis flow booleanAnalysis = true) :
    condition.Safe shape values input valid integers booleans := by
  induction condition generalizing flow with
  | stringCompare unequal left right =>
      simp only [checkBounds] at checked
      split at checked
      · rename_i a b leftFound rightFound
        simp only [Bool.and_eq_true] at checked
        exact ⟨Expression.inferLength_runtimeSafe leftFound state allowed.2
            (fitsLengthSummary_sound allowed.1 (Expression.inferLength_sound leftFound state allowed.2).1 checked.1) (Nat.le_refl _),
          Expression.inferLength_runtimeSafe rightFound state allowed.2
            (fitsLengthSummary_sound allowed.1 (Expression.inferLength_sound rightFound state allowed.2).1 checked.2) (Nat.le_refl _)⟩
      · contradiction
  | lengthCompare operator left right =>
      simp only [checkBounds] at checked
      split at checked
      · rename_i info bound leftFound rightFound
        simp only [Bool.and_eq_true] at checked
        have leftBound := fitsSummary_sound allowed.1 checked.1
        have rightBound := fitsSummary_sound allowed.1 checked.2
        change (values left).length ≤ maxSourceLength ∧ right.evaluate values ≤ maxSourceLength
        rw [(state left info leftFound).1, LengthOperand.evaluate_bound state rightFound]
        exact ⟨by simpa only [Bound.summary_length] using leftBound,
          by simpa only [Bound.summary_length] using rightBound⟩
      · contradiction
  | scalarCompare operator left right =>
      simp only [checkBounds, Bool.and_eq_true, Option.isSome_iff_exists] at checked
      obtain ⟨⟨leftBounds, leftFound⟩, ⟨rightBounds, rightFound⟩⟩ := checked
      exact ⟨(Integer.Expr.infer_sound leftFound allowed.2).2,
        (Integer.Expr.infer_sound rightFound allowed.2).2⟩
  | characterCompare operator left right =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      exact ⟨Character.Expr.check_safe checked.1 (fits_fixedLengths state) allowed.2,
        Character.Expr.check_safe checked.2 (fits_fixedLengths state) allowed.2⟩
  | inputValid | booleanLiteral _ | booleanName _ => trivial
  | parenthesized inner ih => exact ih readable allowed checked
  | negated inner ih => exact ih readable allowed checked
  | andThen left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      refine ⟨ihl readable.1 allowed checked.1, ?_⟩
      intro reached
      apply ihr readable.2 _ checked.2
      have next := left.refine_sound (analysis := analysis) (booleans := booleans) state readable.1 allowed
      simpa only [reached] using next
  | orElse left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      refine ⟨ihl readable.1 allowed checked.1, ?_⟩
      intro reached
      apply ihr readable.2 _ checked.2
      have next := left.refine_sound (analysis := analysis) (booleans := booleans) state readable.1 allowed
      simpa only [reached] using next

  | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      exact ⟨ihl readable.1 allowed checked.1, ihr readable.2 allowed checked.2⟩

theorem Condition.checkedEvaluate_of_checkBounds {condition : Condition} {shape : Shape}
    {hasArguments : Bool} {analysis : Integer.Analysis} {flow : Flow} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    {booleanAnalysis : Boolean.Analysis} {booleans : Boolean.Store}
    (state : Fits shape input values) (readable : condition.Readable hasArguments shape booleanAnalysis)
    (allowed : flow.Allows valid input.length rejected integers)
    (checked : condition.checkBounds shape analysis flow booleanAnalysis = true) :
    condition.checkedEvaluate values input valid integers booleans = some (condition.evaluate values input valid integers booleans) :=
  Condition.checkedEvaluate_refines (condition.checkBounds_sound state readable allowed checked) state

end Silver.Predicate
