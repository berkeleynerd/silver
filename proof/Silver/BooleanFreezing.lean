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
  | .characterCompare operator left right =>
      .characterCompare operator (left.freeze integers) (right.freeze integers)
  | .lengthCompare operator left right => .lengthCompare operator left right
  | .scalarCompare operator left right =>
      .booleanLiteral (operator.evaluate (left.evaluate integers) (right.evaluate integers))
  | .inputValid => .inputValid
  | .booleanLiteral value => .booleanLiteral value
  | .booleanName index => .booleanName index
  | .booleanArrayRead array index => .booleanArrayRead array (.snapshot (index.evaluate integers))
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
      simp only [Expression.freezeImages, List.map_cons, Expression.evaluate,
        Operand.freezeImages_evaluate_at]
      exact congrArg (List.append (atom.evaluate values input snapshot)) ih

theorem Condition.freezeIntegers_evaluate (condition : Condition) (snapshot after : Integer.Store)
    (values : Values) (input : Source) (valid : Bool) (booleans : Boolean.Store) :
    (condition.freezeIntegers snapshot).evaluate values input valid after booleans =
      condition.evaluate values input valid snapshot booleans := by
  induction condition <;> simp only [freezeIntegers, evaluate, frozen_expression_evaluate,
    Character.Expr.freeze_evaluate, Integer.Expr.evaluate, *]

theorem frozen_expression_safe {expression : Expression} {snapshot after : Integer.Store}
    {values : Values} {input : Source} (safe : expression.RuntimeSafe values input snapshot) :
    (expression.freezeImages snapshot).RuntimeSafe values input after := by
  refine ⟨?_, ?_⟩
  · intro atom present
    obtain ⟨original, member, rfl⟩ := List.mem_map.mp present
    have prior := safe.1 original member
    cases original with
    | literal | reference | argument | image => trivial
    | slice target base lower upper =>
        exact ⟨Integer.Expr.safe_value prior.1, Integer.Expr.safe_value prior.2.1, prior.2.2⟩
    | character expression => exact Character.Expr.freeze_safe prior after
    | replace target base index replacement =>
        exact ⟨Integer.Expr.safe_value prior.1, prior.2.1, Character.Expr.freeze_safe prior.2.2 after⟩
  · simpa only [frozen_expression_evaluate] using safe.2

theorem Condition.freezeIntegers_safe {condition : Condition} {shape : Shape}
    {snapshot after : Integer.Store} {values : Values} {input : Source} {valid : Bool}
    {booleans : Boolean.Store} (safe : condition.Safe shape values input valid snapshot booleans) :
    (condition.freezeIntegers snapshot).Safe shape values input valid after booleans := by
  induction condition with
  | stringCompare unequal left right => exact ⟨frozen_expression_safe safe.1, frozen_expression_safe safe.2⟩
  | lengthCompare | inputValid | booleanLiteral | booleanName => exact safe
  | scalarCompare => trivial
  | characterCompare => exact ⟨Character.Expr.freeze_safe safe.1 after, Character.Expr.freeze_safe safe.2 after⟩
  | booleanArrayRead => exact ⟨Integer.Expr.safe_value safe.1, safe.2⟩
  | parenthesized inner ih | negated inner ih => exact ih safe
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      refine ⟨ihl safe.1, ?_⟩
      intro reached
      rw [freezeIntegers_evaluate] at reached
      exact ihr (safe.2 reached)
  | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      exact ⟨ihl safe.1, ihr safe.2⟩

theorem Condition.freezeIntegers_primary {condition : Condition} {snapshot : Integer.Store}
    (primary : condition.isPrimary = true) : (condition.freezeIntegers snapshot).isPrimary = true := by
  cases condition <;> simp_all [isPrimary, freezeIntegers]

theorem Condition.freezeIntegers_factor {condition : Condition} {snapshot : Integer.Store}
    (factor : condition.isFactor = true) : (condition.freezeIntegers snapshot).isFactor = true := by
  cases condition <;> simp only [isFactor, freezeIntegers] at *
  all_goals first | exact freezeIntegers_primary factor | trivial | contradiction

theorem Condition.freezeIntegers_relation (condition : Condition) (snapshot : Integer.Store) :
    (condition.freezeIntegers snapshot).isRelation = condition.isRelation := by cases condition <;> rfl

theorem Condition.freezeIntegers_andHead (condition : Condition) (snapshot : Integer.Store) :
    (condition.freezeIntegers snapshot).isAndHead = condition.isAndHead := by cases condition <;> rfl

theorem Condition.freezeIntegers_orHead (condition : Condition) (snapshot : Integer.Store) :
    (condition.freezeIntegers snapshot).isOrHead = condition.isOrHead := by cases condition <;> rfl

theorem Condition.freezeIntegers_eagerHead (condition : Condition) (snapshot : Integer.Store)
    (operator : Boolean.Operator) :
    (condition.freezeIntegers snapshot).isEagerHead operator = condition.isEagerHead operator := by
  cases condition <;> rfl

theorem Condition.freezeIntegers_grammatical {condition : Condition} (snapshot : Integer.Store)
    (grammatical : condition.Grammatical) : (condition.freezeIntegers snapshot).Grammatical := by
  induction condition with
  | stringCompare | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial
  | parenthesized inner ih => exact ih grammatical
  | negated inner ih => exact ⟨freezeIntegers_primary grammatical.1, ih grammatical.2⟩
  | andThen left right ihl ihr =>
      exact ⟨(freezeIntegers_andHead left snapshot).trans grammatical.1,
        (freezeIntegers_relation right snapshot).trans grammatical.2.1,
        ihl grammatical.2.2.1, ihr grammatical.2.2.2⟩
  | orElse left right ihl ihr =>
      exact ⟨(freezeIntegers_orHead left snapshot).trans grammatical.1,
        (freezeIntegers_relation right snapshot).trans grammatical.2.1,
        ihl grammatical.2.2.1, ihr grammatical.2.2.2⟩
  | eager operator left right ihl ihr =>
      exact ⟨(freezeIntegers_eagerHead left snapshot operator).trans grammatical.1,
        (freezeIntegers_relation right snapshot).trans grammatical.2.1,
        ihl grammatical.2.2.1, ihr grammatical.2.2.2⟩
  | booleanCompare unequal left right ihl ihr =>
      exact ⟨freezeIntegers_factor grammatical.1, freezeIntegers_factor grammatical.2.1,
        ihl grammatical.2.2.1, ihr grammatical.2.2.2⟩

theorem frozen_expression_readable {expression : Expression} {shape : Shape}
    (readable : expression.StringReadable shape) (snapshot : Integer.Store) :
    (expression.freezeImages snapshot).StringReadable shape := by
  intro atom present
  obtain ⟨original, member, rfl⟩ := List.mem_map.mp present
  have known := readable original member
  cases original with
  | literal | reference | argument | image | slice => exact known
  | character expression => exact Character.Expr.freeze_readable known snapshot
  | replace target base index replacement => exact ⟨known.1, Character.Expr.freeze_readable known.2 snapshot⟩

theorem Condition.freezeIntegers_readable {condition : Condition} {hasArguments : Bool}
    {shape : Shape} {booleans : Boolean.Analysis} (snapshot : Integer.Store)
    (readable : condition.Readable hasArguments shape booleans) :
    (condition.freezeIntegers snapshot).Readable hasArguments shape booleans := by
  induction condition with
  | stringCompare unequal left right =>
      rcases readable with ⟨leftNames, rightNames, leftPrintable, rightPrintable, leftNonempty,
        leftBound, rightNonempty, rightBound⟩
      refine ⟨frozen_expression_readable leftNames snapshot, frozen_expression_readable rightNames snapshot,
        Expression.freezeImages_printable leftPrintable snapshot,
        Expression.freezeImages_printable rightPrintable snapshot, ?_, ?_, ?_, ?_⟩
      · intro empty
        apply leftNonempty
        exact List.length_eq_zero_iff.mp (by simpa only [Expression.freezeImages_length, List.length_nil] using congrArg List.length empty)
      · simpa only [Expression.freezeImages_length] using leftBound
      · intro empty
        apply rightNonempty
        exact List.length_eq_zero_iff.mp (by simpa only [Expression.freezeImages_length, List.length_nil] using congrArg List.length empty)
      · simpa only [Expression.freezeImages_length] using rightBound
  | characterCompare =>
      exact ⟨Character.Expr.freeze_readable readable.1 snapshot,
        Character.Expr.freeze_readable readable.2.1 snapshot,
        Character.Expr.freeze_literals readable.2.2.1 snapshot,
        Character.Expr.freeze_literals readable.2.2.2 snapshot⟩
  | lengthCompare | scalarCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => exact readable
  | parenthesized inner ih | negated inner ih => exact ih readable
  | andThen left right ihl ihr | orElse left right ihl ihr | eager _ left right ihl ihr | booleanCompare _ left right ihl ihr =>
      exact ⟨ihl readable.1, ihr readable.2⟩

end Silver.Predicate
