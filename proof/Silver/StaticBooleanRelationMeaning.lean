module

public import Silver.StaticBooleanPrimaryMeaning
public import Silver.ScalarExpressionAdmission
public import Silver.PredicateConditionSound

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

inductive RelationAt (text : Source) (frame : ParserState) (factor : Nat → Predicate.Condition → Nat → Prop)
    (position : Nat) : Predicate.Condition → Nat → Prop
  | integer {left right leftResult rightResult} :
      ScalarExpression.At text frame.scalarNames position left leftResult (elaborating := true) →
      (Predicate.comparisonAt text leftResult.after).after ≠ 0 →
      ScalarExpression.At text frame.scalarNames (Predicate.comparisonAt text leftResult.after).after
        right rightResult (elaborating := true) →
      RelationAt text frame factor position
        (.scalarCompare (Predicate.comparisonAt text leftResult.after).operator.toInteger left right) rightResult.after
  | plain {expression after} : factor position expression after →
      (Predicate.comparisonAt text after).after = 0 → RelationAt text frame factor position expression after
  | boolean {left right middle after} : factor position left middle →
      (Predicate.comparisonAt text middle).after ≠ 0 →
      ((Predicate.comparisonAt text middle).operator = .eq ∨ (Predicate.comparisonAt text middle).operator = .ne) →
      factor (Predicate.comparisonAt text middle).after right after →
      RelationAt text frame factor position
        (.booleanCompare ((Predicate.comparisonAt text middle).operator != .eq) left right) after

private theorem boolean_comparison_value (operator : Predicate.Comparison) (left right : Bool)
    (allowed : operator = .eq ∨ operator = .ne) :
    (if operator != .eq then left != right else left == right) = ((left == right) == (operator == .eq)) := by
  rcases allowed with rfl | rfl <;> cases left <;> cases right <;> rfl

theorem relation_exact {reader : Reader} {text : Source} {frame : ParserState} {position : Nat}
    (bound : position ≤ text.length + 1) (factor : Nat → Predicate.Condition → Nat → Prop)
    (operand : ∀ start, (reader text frame start).after ≠ 0 → ExactAt factor frame start (reader text frame start))
    (accepted : (relationStep modelImports reader text frame position).after ≠ 0) :
    ExactAt (RelationAt text frame factor) frame position (relationStep modelImports reader text frame position) := by
  let scalar := ScalarExpression.read text position frame.scalarNames (elaborating := true)
  let compare := Predicate.comparisonAt text scalar.after
  let other := ScalarExpression.read text compare.after frame.scalarNames (elaborating := true)
  let flagLeft := reader text frame position
  let flagOp := Predicate.comparisonAt text flagLeft.after
  let flagRight := reader text frame flagOp.after
  revert accepted
  dsimp only [relationStep, modelImports]
  split
  · rename_i selected
    split
    · intro accepted; exact False.elim (accepted rfl)
    · rename_i valid
      intro present
      obtain ⟨left, leftRead⟩ := ScalarExpression.read_sound bound selected.1
      have leftBound := (ScalarExpression.sourceSyntax_bounds bound leftRead.grammar).2.2
      obtain ⟨right, rightRead⟩ := ScalarExpression.read_sound
        (Predicate.comparison_bound text scalar.after leftBound) present
      have singletonLeft : scalar.bounds.lower = scalar.bounds.upper :=
        Classical.byContradiction fun apart => valid (.inr (.inr (.inr (.inl apart))))
      have singletonRight : other.bounds.lower = other.bounds.upper :=
        Classical.byContradiction fun apart => valid (.inr (.inr (.inr (.inr apart))))
      have leftBounds : left.infer (ScalarExpression.ranges frame.scalarNames) = some scalar.bounds := by
        simpa only [ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil, ArrayBindings.ranges_nil]
          using leftRead.inferred
      have rightBounds : right.infer (ScalarExpression.ranges frame.scalarNames) = some other.bounds := by
        simpa only [ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil, ArrayBindings.ranges_nil]
          using rightRead.inferred
      refine ⟨_, .integer leftRead selected.2 rightRead, ?_⟩
      change evaluate _ _ (.scalarCompare compare.operator.toInteger left right) =
        some (compareValues compare.operator scalar.bounds.lower other.bounds.lower)
      simp only [evaluate, leftBounds, rightBounds, ite_eq_left (And.intro singletonLeft singletonRight),
        compareValues_evaluate]
  · split
    · intro accepted; exact False.elim (accepted rfl)
    · rename_i leftPresent
      obtain ⟨left, leftRead, leftValue⟩ := operand position leftPresent
      split
      · rename_i noComparison
        intro _
        exact ⟨left, .plain leftRead noComparison, leftValue⟩
      · rename_i hasComparison
        split
        · intro accepted; exact False.elim (accepted rfl)
        · rename_i admissible
          have allowed : flagOp.operator = .eq ∨ flagOp.operator = .ne := by
            by_cases equal : flagOp.operator = .eq
            · exact .inl equal
            · exact .inr (Classical.byContradiction fun different => admissible ⟨equal, different⟩)
          split
          · intro accepted; exact False.elim (accepted rfl)
          · rename_i rightPresent
            intro _
            obtain ⟨right, rightRead, rightValue⟩ := operand flagOp.after rightPresent
            refine ⟨_, .boolean leftRead hasComparison allowed rightRead, ?_⟩
            change evaluate _ _ (.booleanCompare (flagOp.operator != .eq) left right) =
              some ((flagLeft.value == flagRight.value) == (flagOp.operator == .eq))
            simp only [evaluate, binary, leftValue, rightValue]
            exact congrArg some (boolean_comparison_value _ _ _ allowed)

end Silver.BooleanElaboration.Native
