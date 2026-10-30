module

public import Silver.PredicateChecking
public import Silver.StringFreezing

@[expose] public section

/-! Declaration-time scalar specialization preserves Boolean meaning. The
source trace separately retains every original scalar and String obligation;
these equalities do not justify dropping a source check. -/
namespace Silver.Predicate
open Bindings Compose

def Condition.freezeIntegers (integers : Integer.Store) : Condition → Condition
  | .stringCompare unequal left right =>
      .stringCompare unequal (left.freezeImages integers) (right.freezeImages integers)
  | .lengthCompare operator left right => .lengthCompare operator left right
  | .scalarCompare operator left right =>
      .booleanLiteral (operator.evaluate (left.evaluate integers) (right.evaluate integers))
  | .inputValid => .inputValid
  | .booleanLiteral value => .booleanLiteral value
  | .booleanName index => .booleanName index
  | .parenthesized inner => .parenthesized (inner.freezeIntegers integers)
  | .negated inner => .negated (inner.freezeIntegers integers)
  | .andThen left right => .andThen (left.freezeIntegers integers) (right.freezeIntegers integers)
  | .orElse left right => .orElse (left.freezeIntegers integers) (right.freezeIntegers integers)
  | .eager operator left right => .eager operator (left.freezeIntegers integers) (right.freezeIntegers integers)
  | .booleanCompare unequal left right =>
      .booleanCompare unequal (left.freezeIntegers integers) (right.freezeIntegers integers)

theorem frozen_expression_evaluate (expression : Expression) (snapshot after : Integer.Store)
    (values : Values) (input : Source) :
    (expression.freezeImages snapshot).evaluate values input after =
      expression.evaluate values input snapshot := by
  induction expression with
  | nil => rfl
  | cons atom rest ih =>
      simp only [Expression.freezeImages] at ih
      cases atom <;> simp only [Expression.freezeImages, List.map_cons, Operand.freezeImages,
        Expression.evaluate, Value.evaluate, ih]

theorem Condition.freezeIntegers_evaluate (condition : Condition) (snapshot after : Integer.Store)
    (values : Values) (input : Source) (valid : Bool) (booleans : Boolean.Store) :
    (condition.freezeIntegers snapshot).evaluate values input valid after booleans =
      condition.evaluate values input valid snapshot booleans := by
  induction condition <;> simp only [freezeIntegers, evaluate, frozen_expression_evaluate, *]

theorem frozen_expression_safe {expression : Expression} {snapshot after : Integer.Store}
    {values : Values} {input : Source} (safe : expression.RuntimeSafe values input snapshot) :
    (expression.freezeImages snapshot).RuntimeSafe values input after := by
  refine ⟨?_, ?_⟩
  · intro atom present
    obtain ⟨original, _, rfl⟩ := List.mem_map.mp present
    cases original <;> trivial
  · simpa only [frozen_expression_evaluate] using safe.2

theorem Condition.freezeIntegers_safe {condition : Condition} {shape : Shape}
    {snapshot after : Integer.Store} {values : Values} {input : Source} {valid : Bool}
    {booleans : Boolean.Store} (safe : condition.Safe shape values input valid snapshot booleans) :
    (condition.freezeIntegers snapshot).Safe shape values input valid after booleans := by
  induction condition with
  | stringCompare unequal left right => exact ⟨frozen_expression_safe safe.1, frozen_expression_safe safe.2⟩
  | lengthCompare | inputValid | booleanLiteral | booleanName => exact safe
  | scalarCompare => trivial
  | parenthesized inner ih | negated inner ih => exact ih safe
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      refine ⟨ihl safe.1, ?_⟩
      intro reached
      rw [freezeIntegers_evaluate] at reached
      exact ihr (safe.2 reached)
  | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      exact ⟨ihl safe.1, ihr safe.2⟩

end Silver.Predicate
