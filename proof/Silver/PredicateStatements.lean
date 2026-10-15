module

public import Silver.PredicateChecking
public import Silver.SequenceSyntax

@[expose] public section

/-! A small predicate-control core reuses initialized String assignments and
output effects. Source `elsif` lowers to a choice in the false arm; an omitted
`else` lowers to an empty false arm. Rejection returns to its continuation. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

inductive Statement
  | simple (item : Sequence.SimpleStatement)
  | reject
  | choice (condition : Condition) (yes no : List Statement)
  deriving Repr

def ExpressionReady (shape : Shape) (expression : Expression) : Prop :=
  expression.Readable shape ∧ expression.LiteralsPrintable ∧
    expression ≠ [] ∧ expression.length ≤ maxExpressionOperands

def SimpleWellFormed (shape : Shape) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => ExpressionReady shape update.value ∧
      ∃ bound, shape update.target = some ⟨bound, true⟩
  | .output expression => ExpressionReady shape expression

mutual
  def Statement.WellFormed (hasArguments : Bool) (shape : Shape) : Statement → Prop
    | .simple item => SimpleWellFormed shape item
    | .reject => hasArguments = true
    | .choice condition yes no =>
        condition.Grammatical ∧ condition.Readable hasArguments shape ∧ yes ≠ [] ∧
          StatementsWellFormed hasArguments shape yes ∧ StatementsWellFormed hasArguments shape no
  termination_by item => sizeOf item
  def StatementsWellFormed (hasArguments : Bool) (shape : Shape) : List Statement → Prop
    | [] => True
    | item :: rest => item.WellFormed hasArguments shape ∧ StatementsWellFormed hasArguments shape rest
  termination_by items => sizeOf items
end

/-- Check an assignment's affine equality at both endpoints of each reachable
valid interval and at zero on reachable invalid inputs. For a static target
(the right summary), the value's static contribution must fit the target even
on empty paths, and must equal it when the value is wholly static. The pinned
Ada compiler can diagnose these assignments before eliminating a dead arm. -/
def equalSummary (context : Context) (left right : Summary) : Bool :=
  ((decide (right.dynamicCount ≠ 0) ||
      (decide (left.staticLength ≤ right.staticLength) &&
        (decide (left.dynamicCount ≠ 0) || decide (left.staticLength = right.staticLength)))) &&
    (match context.validLengths with
    | none => true
    | some interval => decide (left.length interval.lower = right.length interval.lower ∧
        left.length interval.upper = right.length interval.upper))) &&
    (!context.invalidReachable || decide (left.length 0 = right.length 0))

theorem equalSummary_static_target {context : Context} {left right : Summary}
    (fixed : right.dynamicCount = 0) (checked : equalSummary context left right = true) :
    left.staticLength ≤ right.staticLength ∧
      (left.dynamicCount = 0 → left.staticLength = right.staticLength) := by
  simp only [equalSummary, Bool.and_eq_true] at checked
  have compatible := checked.1.1
  simp [fixed] at compatible
  refine ⟨compatible.1, ?_⟩
  intro staticValue
  simpa [staticValue] using compatible.2

theorem equalSummary_sound {context : Context} {left right : Summary} {length : Nat}
    {valid rejected : Bool} (allowed : context.Allows valid length rejected)
    (checked : equalSummary context left right = true) : left.length length = right.length length := by
  simp only [equalSummary, Bool.and_eq_true] at checked
  cases valid with
  | false =>
      rcases allowed with ⟨rfl, reachable, _⟩
      simpa only [reachable, Bool.not_true, Bool.false_or, decide_eq_true_eq] using checked.2
  | true =>
      cases found : context.validLengths with
      | none => simp [Context.Allows, found, Region.Contains] at allowed
      | some interval =>
          have within : interval.Contains length := by
            simpa only [Context.Allows, found, Region.Contains, ↓reduceIte] using allowed
          apply Interval.equal_sound (length := length) _ within
          simpa only [found, decide_eq_true_eq, Interval.Equal] using checked.1.2

def checkAssignment (shape : Shape) (context : Context) (update : Assignment) : Bool :=
  match shape update.target with
  | some ⟨bound, true⟩ => fitsSummary context (update.value.summary shape) &&
      equalSummary context (update.value.summary shape) bound.summary
  | _ => false

def checkSimple (shape : Shape) (context : Context) : Sequence.SimpleStatement → Bool
  | .null => true
  | .assign update => checkAssignment shape context update
  | .output expression => fitsSummary context (expression.summary shape) && !context.invalidReachable

mutual
  def Statement.check (shape : Shape) (context : Context) : Statement → Option Context
    | .simple item => if checkSimple shape context item then some context else none
    | .reject => some context.reject
    | .choice condition yes no =>
        if condition.checkBounds shape context then
          (checkStatements shape (condition.refine shape context true) yes).bind fun afterYes =>
            (checkStatements shape (condition.refine shape context false) no).map fun afterNo =>
              afterYes.join afterNo
        else none
  termination_by item => sizeOf item
  def checkStatements (shape : Shape) (context : Context) : List Statement → Option Context
    | [] => some context
    | item :: rest => (item.check shape context).bind fun next => checkStatements shape next rest
  termination_by items => sizeOf items
end

/-- Successful completion must reject every reachable invalid-input path. -/
def completed (context : Context) : Bool := !context.invalidReachable || context.invalidRejected

theorem expression_safe_on_path {shape : Shape} {context : Context} {expression : Expression}
    {input : Source} {valid rejected : Bool} (ready : ExpressionReady shape expression)
    (allowed : context.Allows valid input.length rejected)
    (checked : fitsSummary context (expression.summary shape) = true) :
    SafeExpression expression shape input.length :=
  ⟨ready.1, ready.2.1, ready.2.2.1, ready.2.2.2, fitsSummary_sound allowed checked⟩

theorem assignment_checked_length {shape : Shape} {context : Context} {update : Assignment}
    {values : Values} {input : Source} {valid rejected : Bool}
    (ready : ExpressionReady shape update.value) (state : Fits shape input values)
    (allowed : context.Allows valid input.length rejected)
    (checked : checkAssignment shape context update = true) :
    (update.value.evaluate values input).length = (values update.target).length := by
  unfold checkAssignment at checked
  split at checked
  · rename_i bound target
    simp only [Bool.and_eq_true] at checked
    have length := equalSummary_sound allowed checked.2
    rw [Expression.evaluate_length state ready.1, (state update.target _ target).1]
    rw [Bound.summary_length] at length
    exact length
  · contradiction

theorem assignment_preserves_on_path {shape : Shape} {context : Context} {update : Assignment}
    {values : Values} {input : Source} {valid rejected : Bool}
    (ready : ExpressionReady shape update.value) (state : Fits shape input values)
    (printable : Bindings.Printable input) (allowed : context.Allows valid input.length rejected)
    (checked : checkAssignment shape context update = true) :
    Fits shape input (update.execute values input) := by
  have equal := assignment_checked_length ready state allowed checked
  intro index info found
  by_cases same : index = update.target
  · subst index
    simp only [Assignment.execute, put_same]
    exact ⟨equal.trans (state update.target info found).1,
      Expression.evaluate_printable ready.1 ready.2.1 state printable⟩
  · simpa only [Assignment.execute, put, same, ↓reduceIte] using state index info found

end Silver.Predicate
