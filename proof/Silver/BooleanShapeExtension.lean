module

public import Silver.PredicateChecking

@[expose] public section

/-! Later String declarations append fresh cells. Boolean initializers retain
their original name identities, summaries and path refinements in that larger
shape; later declarations do not supply missing reads or new guard facts. -/
namespace Silver.Predicate
open Bindings Compose

def ShapeExtends (before after : Shape) : Prop :=
  ∀ index info, before index = some info → after index = some info

theorem operand_readable_extends {before after : Shape} {atom : Operand}
    (extension : ShapeExtends before after) (readable : atom.StringReadable before) :
    atom.StringReadable after := by
  cases atom with
  | literal | argument | image => trivial
  | reference index =>
      obtain ⟨info, present⟩ := readable
      exact ⟨info, extension index info present⟩

theorem expression_readable_extends {before after : Shape} {expression : Expression}
    (extension : ShapeExtends before after) (readable : expression.StringReadable before) :
    expression.StringReadable after :=
  fun atom member => operand_readable_extends extension (readable atom member)

theorem operand_inferLength_extends {before after : Shape} {atom : Operand}
    (extension : ShapeExtends before after) (readable : atom.StringReadable before)
    (ranges : Integer.Ranges) : atom.inferLength after ranges = atom.inferLength before ranges := by
  cases atom with
  | literal | argument | image => rfl
  | reference index =>
      obtain ⟨info, present⟩ := readable
      simp only [Operand.inferLength, Value.infer, present, extension index info present]

theorem expression_inferLength_extends {before after : Shape} {expression : Expression}
    (extension : ShapeExtends before after) (readable : expression.StringReadable before)
    (ranges : Integer.Ranges) :
    expression.inferLength after ranges = expression.inferLength before ranges := by
  induction expression with
  | nil => rfl
  | cons atom rest ih =>
      have first := readable atom (List.mem_cons_self ..)
      have remaining : Expression.StringReadable rest before := fun item member => readable item (List.mem_cons_of_mem _ member)
      simp only [Expression.inferLength, operand_inferLength_extends extension first ranges, ih remaining]

theorem lengthOperand_readable_extends {before after : Shape} {operand : LengthOperand}
    (extension : ShapeExtends before after) (readable : operand.Readable before) :
    operand.Readable after := by
  cases operand with
  | literal => exact readable
  | binding index =>
      obtain ⟨info, present⟩ := readable
      exact ⟨info, extension index info present⟩

theorem lengthOperand_bound_extends {before after : Shape} {operand : LengthOperand}
    (extension : ShapeExtends before after) (readable : operand.Readable before) :
    operand.bound after = operand.bound before := by
  cases operand with
  | literal => rfl
  | binding index =>
      obtain ⟨info, present⟩ := readable
      simp only [LengthOperand.bound, present, extension index info present]

theorem Condition.readable_extends {condition : Condition} {before after : Shape}
    {hasArguments : Bool} {booleans : Boolean.Analysis}
    (extension : ShapeExtends before after) (readable : condition.Readable hasArguments before booleans) :
    condition.Readable hasArguments after booleans := by
  induction condition with
  | stringCompare =>
      exact ⟨expression_readable_extends extension readable.1,
        expression_readable_extends extension readable.2.1, readable.2.2⟩
  | lengthCompare =>
      obtain ⟨⟨info, present⟩, right⟩ := readable
      exact ⟨⟨info, extension _ info present⟩, lengthOperand_readable_extends extension right⟩
  | scalarCompare | inputValid | booleanLiteral | booleanName => exact readable
  | parenthesized _ ih | negated _ ih => exact ih readable
  | andThen _ _ left right | orElse _ _ left right | eager _ _ _ left right | booleanCompare _ _ _ left right => exact ⟨left readable.1, right readable.2⟩

theorem Condition.refine_extends {condition : Condition} {before after : Shape}
    {hasArguments : Bool} {booleans : Boolean.Analysis}
    (extension : ShapeExtends before after) (readable : condition.Readable hasArguments before booleans)
    (analysis : Integer.Analysis) (flow : Flow) (truth : Bool) :
    condition.refine after analysis flow truth = condition.refine before analysis flow truth := by
  induction condition generalizing flow truth with
  | stringCompare unequal left right =>
      simp only [Condition.refine, refineString,
        expression_inferLength_extends extension readable.1,
        expression_inferLength_extends extension readable.2.1]
  | lengthCompare operator left right =>
      obtain ⟨⟨info, present⟩, rightReadable⟩ := readable
      simp only [Condition.refine, refineLength, present, extension left info present,
        lengthOperand_bound_extends extension rightReadable]
  | scalarCompare | inputValid | booleanLiteral | booleanName | eager | booleanCompare => rfl
  | parenthesized _ ih => exact ih readable flow truth
  | negated _ ih => exact ih readable flow (!truth)
  | andThen left right leftIH rightIH | orElse left right leftIH rightIH =>
      simp only [Condition.refine, leftIH readable.1, rightIH readable.2]

theorem Condition.checkBounds_extends {condition : Condition} {before after : Shape}
    {hasArguments : Bool} {booleans : Boolean.Analysis}
    (extension : ShapeExtends before after) (readable : condition.Readable hasArguments before booleans)
    (analysis : Integer.Analysis) (flow : Flow) :
    condition.checkBounds after analysis flow booleans = condition.checkBounds before analysis flow booleans := by
  induction condition generalizing flow with
  | stringCompare =>
      simp only [Condition.checkBounds, expression_inferLength_extends extension readable.1,
        expression_inferLength_extends extension readable.2.1]
  | lengthCompare operator left right =>
      obtain ⟨⟨info, present⟩, rightReadable⟩ := readable
      simp only [Condition.checkBounds, present, extension left info present,
        lengthOperand_bound_extends extension rightReadable]
  | scalarCompare | inputValid | booleanLiteral | booleanName => rfl
  | parenthesized _ ih | negated _ ih => exact ih readable flow
  | andThen left right leftIH rightIH | orElse left right leftIH rightIH =>
      simp only [Condition.checkBounds, leftIH readable.1, left.refine_extends extension readable.1,
        rightIH readable.2]
  | eager _ _ _ leftIH rightIH | booleanCompare _ _ _ leftIH rightIH =>
      simp only [Condition.checkBounds, leftIH readable.1, rightIH readable.2]

end Silver.Predicate
