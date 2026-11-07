module

public import Silver.BooleanFreezing
public import Silver.ScalarExpressionConstants

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

def ExactScalarRanges (ranges : Integer.Ranges) : Prop :=
  ∀ index bounds, ranges index = some bounds → bounds.lower = bounds.upper

theorem Condition.refine_exactScalars {condition : Condition} {shape : Shape}
    {analysis : Integer.Analysis} {flow : Flow} {truth : Bool}
    (exact : ExactScalarRanges flow.scalars) :
    (condition.refine shape analysis flow truth).scalars = flow.scalars := by
  funext index
  cases found : flow.scalars index with
  | none => exact condition.refine_preserves_none found
  | some bounds =>
      have single := exact index bounds found
      have nonempty : bounds.isEmpty = false := by simp [Integer.Interval.isEmpty, single]
      obtain ⟨current, present, subset⟩ :=
        condition.refine_refines (Integer.Ranges.refines_refl flow.scalars) index bounds found
      obtain ⟨inhabited, same, still⟩ := condition.refine_nonempty (shape := shape)
        (analysis := analysis) (truth := truth) ⟨bounds, found, nonempty⟩
      rw [present] at same
      cases same
      have order : current.lower ≤ current.upper := by
        simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at still
        omega
      have low := subset current.lower ⟨Int.le_refl _, order⟩
      have high := subset current.upper ⟨order, Int.le_refl _⟩
      have equal : current = bounds := by
        cases current
        cases bounds
        simp only [Integer.Interval.Contains] at low high
        simp only [] at single order
        congr <;> omega
      simpa only [equal] using present

theorem frozen_image_summary (value : Int) :
    LengthSummary.ofImage (.singleton value) =
      LengthSummary.ofExact ⟨(Integer.Image.bytes value).length, 0⟩ := by
  have magnitude : Integer.Image.minimumMagnitude (.singleton value) = value.natAbs := by
    simp only [Integer.Image.minimumMagnitude, Integer.Interval.singleton, Nat.min_self]
    split
    · have zero : value = 0 := by omega
      subst value
      rfl
    · rfl
  have nonempty : (Integer.Interval.singleton value).isEmpty = false := by
    simp [Integer.Interval.isEmpty, Integer.Interval.singleton]
  simp only [LengthSummary.ofImage, nonempty, Bool.false_eq_true, ↓reduceIte,
    Integer.Image.lengthBounds, magnitude]
  simp [Integer.Image.maximumMagnitude, Integer.Interval.singleton,
    Integer.Image.length_exact, LengthSummary.ofExact]

theorem frozen_operand_inferLength {atom : Operand} {shape : Shape} {ranges : Integer.Ranges}
    {snapshot : Integer.Store} {summary : LengthSummary}
    (exact : ExactScalarRanges ranges) (fits : Integer.Fits ranges snapshot)
    (known : atom.inferLength shape ranges = some summary) (after : Integer.Ranges) :
    (atom.freezeImages snapshot).inferLength shape after = some summary := by
  cases atom with
  | literal | reference | argument => exact known
  | image expression =>
      simp only [Operand.inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, inferred, rfl⟩ := known
      have single := ScalarExpression.inference_singleton exact inferred
      have within := (Integer.Expr.infer_sound inferred fits).1
      have same : bounds = .singleton (expression.evaluate snapshot) := by
        cases bounds
        simp only [Integer.Interval.Contains] at within
        simp only [] at single
        simp only [Integer.Interval.singleton]
        congr <;> omega
      simp only [Operand.freezeImages, Operand.inferLength, Value.infer, Option.map_some,
        Function.comp_def, Bound.summary, same, frozen_image_summary]
  | character expression =>
      simp only [Operand.inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, rfl⟩ := known
      simp only [Value.extraRange] at found
      split at found
      · rename_i checked
        cases found
        simp only [Operand.freezeImages, Operand.inferLength, Value.extraRange,
          Character.Expr.freeze_check checked fits after, ↓reduceIte, Option.map_some]
      · cases found
  | replace target base index replacement =>
      simp only [Operand.inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, rfl⟩ := known
      simp only [Value.extraRange, Option.bind_eq_some_iff] at found
      obtain ⟨length, targetFound, indices, indexFound, result⟩ := found
      split at result
      · rename_i checked
        simp only [Bool.and_eq_true] at checked
        cases result
        have inferred := Integer.Expr.infer_sound indexFound fits
        have safe := StringIndexing.indexCheck_singleton (StringIndexing.indexCheck_sound checked.1 inferred.1)
        simp only [Operand.freezeImages, Operand.inferLength, Value.extraRange, targetFound,
          Character.snapshot_infer (Integer.Expr.safe_value inferred.2), Option.bind_some,
          Character.Expr.freeze_check checked.2 fits after, safe, Bool.and_self, ↓reduceIte, Option.map_some]
      · cases result
  | slice target base lower upper =>
      simp only [Operand.inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, rfl⟩ := known
      simp only [Value.extraRange, Option.bind_eq_some_iff] at found
      obtain ⟨length, targetFound, a, lowerFound, b, upperFound, result⟩ := found
      split at result
      · rename_i checked
        cases result
        have left := Integer.Expr.infer_sound lowerFound fits
        have right := Integer.Expr.infer_sound upperFound fits
        have leftSingle := ScalarExpression.inference_singleton exact lowerFound
        have rightSingle := ScalarExpression.inference_singleton exact upperFound
        have leftSame : a = .singleton (lower.evaluate snapshot) := by
          cases a
          simp only [Integer.Interval.Contains] at left
          simp only [] at leftSingle
          simp only [Integer.Interval.singleton]
          congr <;> omega
        have rightSame : b = .singleton (upper.evaluate snapshot) := by
          cases b
          simp only [Integer.Interval.Contains] at right
          simp only [] at rightSingle
          simp only [Integer.Interval.singleton]
          congr <;> omega
        rw [leftSame, rightSame] at checked ⊢
        simp only [Operand.freezeImages, Operand.inferLength, Value.extraRange, targetFound,
          Character.snapshot_infer (Integer.Expr.safe_value left.2),
          Character.snapshot_infer (Integer.Expr.safe_value right.2), Option.bind_some, checked,
          ↓reduceIte, Option.map_some]
      · cases result

theorem frozen_expression_inferLength {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {snapshot : Integer.Store} {summary : LengthSummary}
    (exact : ExactScalarRanges ranges) (fits : Integer.Fits ranges snapshot)
    (known : expression.inferLength shape ranges = some summary) (after : Integer.Ranges) :
    (expression.freezeImages snapshot).inferLength shape after = some summary := by
  induction expression generalizing summary with
  | nil => exact known
  | cons atom rest ih =>
      simp only [Expression.inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨a, first, b, remaining, rfl⟩ := known
      change ((atom.freezeImages snapshot).inferLength shape after).bind
        (fun a => ((Expression.freezeImages rest snapshot).inferLength shape after).map a.add) = _
      rw [frozen_operand_inferLength exact fits first after, ih remaining]
      rfl

def withoutScalars (flow : Flow) : Flow := ⟨flow.path, Integer.emptyRanges⟩

@[simp] theorem withoutScalars_join (left right : Flow) :
    withoutScalars (left.join right) = (withoutScalars left).join (withoutScalars right) := rfl

theorem withoutScalars_injective_path {left right : Flow} (same : left.path = right.path) :
    withoutScalars left = withoutScalars right := by simp only [withoutScalars, same]

/-- Specialization preserves every path refinement and passes the frozen
checker whenever the original initializer passes. The original scalar checks
remain in the independently retained obligation trace. -/
theorem Condition.freezeIntegers_checked {condition : Condition} {shape : Shape}
    {analysis : Integer.Analysis} {flow : Flow} {snapshot : Integer.Store}
    {booleans : Boolean.Analysis} (exact : ExactScalarRanges flow.scalars)
    (fits : Integer.Fits flow.scalars snapshot)
    (checked : condition.checkBounds shape analysis flow booleans = true) :
    (condition.freezeIntegers snapshot).checkBounds shape Integer.Analysis.empty
      (withoutScalars flow) booleans = true ∧
    ∀ truth, (condition.freezeIntegers snapshot).refine shape Integer.Analysis.empty
      (withoutScalars flow) truth = withoutScalars (condition.refine shape analysis flow truth) := by
  induction condition generalizing flow with
  | stringCompare unequal left right =>
      simp only [checkBounds] at checked
      split at checked
      · rename_i a b leftKnown rightKnown
        have leftFrozen := frozen_expression_inferLength exact fits leftKnown Integer.emptyRanges
        have rightFrozen := frozen_expression_inferLength exact fits rightKnown Integer.emptyRanges
        constructor
        · simpa only [freezeIntegers, checkBounds, withoutScalars, leftFrozen, rightFrozen] using checked
        · intro truth
          simp only [freezeIntegers, refine, withoutScalars, refineString,
            leftKnown, rightKnown, leftFrozen, rightFrozen]
      · contradiction
  | lengthCompare operator left right => exact ⟨checked, fun _ => rfl⟩
  | scalarCompare operator left right => exact ⟨rfl, fun _ => rfl⟩
  | characterCompare operator left right =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      exact ⟨by simp only [freezeIntegers, checkBounds, withoutScalars,
        Character.Expr.freeze_check checked.1 fits Integer.emptyRanges,
        Character.Expr.freeze_check checked.2 fits Integer.emptyRanges, Bool.and_self], fun _ => rfl⟩
  | inputValid | booleanLiteral _ | booleanName _ => exact ⟨checked, fun _ => rfl⟩
  | booleanArrayRead array index =>
      have both : array.initialized booleans = true ∧ array.checkIndex flow.scalars index = true :=
        Bool.and_eq_true_iff.mp checked
      have sound := array.checkIndex_sound both.2 fits
      have indexCheck := array.indexCheck_singleton (array.checkIndex_valid both.2) sound.2
      refine ⟨?_, fun _ => rfl⟩
      simpa only [freezeIntegers, checkBounds, withoutScalars, both.1, Bool.true_and,
        Boolean.ArrayDescriptor.checkIndex, Character.snapshot_infer (Integer.Expr.safe_value sound.1)] using indexCheck
  | parenthesized inner ih => exact ih exact fits checked
  | negated inner ih =>
      have frozen := ih exact fits checked
      exact ⟨frozen.1, fun truth => frozen.2 (!truth)⟩
  | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      have leftFrozen := ihl exact fits checked.1
      have rightFrozen := ihr exact fits checked.2
      exact ⟨by simp only [freezeIntegers, checkBounds, leftFrozen.1, rightFrozen.1, Bool.and_self], fun _ => rfl⟩
  | andThen left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      have leftFrozen := ihl exact fits checked.1
      have same := left.refine_exactScalars (shape := shape) (analysis := analysis) (truth := true) exact
      have nextExact : ExactScalarRanges (left.refine shape analysis flow true).scalars := by rw [same]; exact exact
      have nextFits : Integer.Fits (left.refine shape analysis flow true).scalars snapshot := by rw [same]; exact fits
      have rightFrozen := ihr nextExact nextFits checked.2
      constructor
      · simp only [freezeIntegers, checkBounds, leftFrozen.1, leftFrozen.2 true, rightFrozen.1, Bool.and_true]
      · intro truth
        cases truth <;> simp only [freezeIntegers, refine, Bool.false_eq_true, ↓reduceIte,
          leftFrozen.2 true, leftFrozen.2 false, rightFrozen.2 true, rightFrozen.2 false,
          withoutScalars_join]
  | orElse left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked
      have leftFrozen := ihl exact fits checked.1
      have same := left.refine_exactScalars (shape := shape) (analysis := analysis) (truth := false) exact
      have nextExact : ExactScalarRanges (left.refine shape analysis flow false).scalars := by rw [same]; exact exact
      have nextFits : Integer.Fits (left.refine shape analysis flow false).scalars snapshot := by rw [same]; exact fits
      have rightFrozen := ihr nextExact nextFits checked.2
      constructor
      · simp only [freezeIntegers, checkBounds, leftFrozen.1, leftFrozen.2 false, rightFrozen.1, Bool.and_true]
      · intro truth
        cases truth <;> simp only [freezeIntegers, refine, Bool.false_eq_true, ↓reduceIte,
          leftFrozen.2 true, leftFrozen.2 false, rightFrozen.2 true, rightFrozen.2 false,
          withoutScalars_join]

end Silver.Predicate
