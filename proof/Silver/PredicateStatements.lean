module

public import Silver.PredicateChecking
public import Silver.SequenceSyntax
public import Silver.IntegerIteration
public import Silver.IntegerMutable

@[expose] public section

/-! A small predicate-control core reuses initialized String assignments and
output effects. Source `elsif` lowers to a choice in the false arm; an omitted
`else` lowers to an empty false arm. Rejection returns to its continuation. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

inductive Statement
  | simple (item : Sequence.SimpleStatement)
  | scalarAssign (update : Integer.Assignment)
  | reject
  | choice (condition : Condition) (yes no : List Statement)
  | forLoop (index : Nat) (reverse : Bool) (lower upper : Integer.Expr) (body : List Statement)
  deriving Repr

def ExpressionReady (shape : Shape) (expression : Expression) : Prop :=
  expression.StringReadable shape ∧ expression.LiteralsPrintable ∧
    expression ≠ [] ∧ expression.length ≤ maxExpressionOperands

def SimpleWellFormed (shape : Shape) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => ExpressionReady shape update.value ∧
      ∃ bound, shape update.target = some ⟨bound, true⟩
  | .output expression | .put expression => ExpressionReady shape expression

mutual
  def Statement.WellFormed (hasArguments : Bool) (shape : Shape) : Statement → Prop
    | .simple item => SimpleWellFormed shape item
    | .scalarAssign update => update.target ≠ 0
    | .reject => hasArguments = true
    | .choice condition yes no =>
        condition.Grammatical ∧ condition.Readable hasArguments shape ∧ yes ≠ [] ∧
          StatementsWellFormed hasArguments shape yes ∧ StatementsWellFormed hasArguments shape no
    | .forLoop index _ _ _ body => index ≠ 0 ∧ body ≠ [] ∧ StatementsWellFormed hasArguments shape body
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

def equalLengthSummary (context : Context) (left : LengthSummary) (right : Summary) : Bool :=
  if left.empty then
    decide (right.dynamicCount ≠ 0 ∨ left.minimumLength ≤ right.staticLength)
  else equalSummary context left.lower right && equalSummary context left.upper right

theorem equalLengthSummary_sound {context : Context} {left : LengthSummary} {right : Summary}
    {inputLength actualLength : Nat} {valid rejected : Bool}
    (allowed : context.Allows valid inputLength rejected)
    (within : left.Contains inputLength actualLength)
    (checked : equalLengthSummary context left right = true) :
    actualLength = right.length inputLength := by
  simp only [equalLengthSummary, within.1, Bool.false_eq_true, ↓reduceIte, Bool.and_eq_true] at checked
  have lower := equalSummary_sound allowed checked.1
  have upper := equalSummary_sound allowed checked.2
  have low := within.2.1
  have high := within.2.2
  omega

def checkAssignment (shape : Shape) (context : Context) (update : Assignment)
    (ranges : Integer.Ranges := Integer.emptyRanges) : Bool :=
  match shape update.target, update.value.inferLength shape ranges with
  | some ⟨bound, true⟩, some summary => fitsLengthSummary context summary &&
      equalLengthSummary context summary bound.summary
  | _, _ => false

def checkSimple (shape : Shape) (context : Context) (item : Sequence.SimpleStatement)
    (ranges : Integer.Ranges := Integer.emptyRanges) : Bool :=
  match item with
  | .null => true
  | .assign update => checkAssignment shape context update ranges
  | .output expression | .put expression =>
      match expression.inferLength shape ranges with
      | some summary => fitsLengthSummary context summary && !context.invalidReachable
      | none => false

def loopContext (context : Context) (bounds : Integer.Interval) : Context :=
  if bounds.isEmpty then Context.empty else context

def loopAfter (before after : Context) (lower upper : Integer.Interval) : Context :=
  if (Integer.loopBounds lower upper).isEmpty then before
  else if Integer.loopDefinite lower upper then after else before.join after

def loopEntry (analysis : Integer.Analysis) (flow : Flow) (index : Nat)
    (bounds : Integer.Interval) : Flow :=
  ⟨loopContext flow.path bounds, Integer.put (analysis.widen flow.scalars) index (some bounds)⟩

def loopExit (analysis : Integer.Analysis) (before after : Flow)
    (lower upper : Integer.Interval) : Flow :=
  ⟨loopAfter before.path after.path lower upper,
    if (Integer.loopBounds lower upper).isEmpty then before.scalars
    else analysis.widen before.scalars⟩

mutual
  def Statement.check (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (item : Statement) : Option Flow :=
    match item with
    | .simple item => if checkSimple shape flow.path item flow.scalars then some flow else none
    | .scalarAssign update =>
        if update.check flow.scalars analysis.mutable analysis.declared
        then some {flow with scalars := update.after flow.scalars} else none
    | .reject => some {flow with path := flow.path.reject}
    | .choice condition yes no =>
        if condition.checkBounds shape analysis flow then
          (checkStatements shape analysis (condition.refine shape analysis flow true) yes).bind fun afterYes =>
            (checkStatements shape analysis (condition.refine shape analysis flow false) no).map fun afterNo =>
              afterYes.join afterNo
        else none
    | .forLoop index _ lower upper body =>
        (lower.infer flow.scalars).bind fun a => (upper.infer flow.scalars).bind fun b =>
          let bounds := Integer.loopBounds a b
          (checkStatements shape (analysis.withIndex index bounds)
            (loopEntry analysis flow index bounds) body).map fun after => loopExit analysis flow after a b
  termination_by sizeOf item
  def checkStatements (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (items : List Statement) : Option Flow :=
    match items with
    | [] => some flow
    | item :: rest => (item.check shape analysis flow).bind fun next => checkStatements shape analysis next rest
  termination_by sizeOf items
end

/- Admission preserves abstract containment in immutable declaration ranges,
including through precise assignments, branch hulls and conservative loop exits. -/
mutual
  theorem statement_ranges_invariant {shape : Shape} {analysis : Integer.Analysis}
      {before after : Flow} {item : Statement}
      (checked : item.check shape analysis before = some after)
      (refined : before.scalars.Refines analysis.declared)
      (bounded : before.scalars.Bounded) (declared : analysis.declared.Bounded) :
      after.scalars.Refines analysis.declared ∧ after.scalars.Bounded := by
    cases item with
    | simple item =>
        simp only [Statement.check] at checked
        split at checked
        · cases checked; exact ⟨refined, bounded⟩
        · contradiction
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          exact ⟨update.after_refines good refined, update.after_bounded bounded⟩
        · contradiction
    | reject =>
        simp only [Statement.check, Option.some.injEq] at checked
        subst after
        exact ⟨refined, bounded⟩
    | choice condition yes no =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          have a := statements_ranges_invariant yesChecked (condition.refine_refines refined)
            (condition.refine_bounded bounded) declared
          have b := statements_ranges_invariant noChecked (condition.refine_refines refined)
            (condition.refine_bounded bounded) declared
          exact ⟨Integer.Ranges.join_refines a.1 b.1, Integer.Ranges.join_bounded a.2 b.2⟩
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, _, rfl⟩ := checked
        simp only [loopExit]
        split
        · exact ⟨refined, bounded⟩
        · exact ⟨analysis.widen_refines refined, analysis.widen_bounded bounded declared⟩
  termination_by sizeOf item

  theorem statements_ranges_invariant {shape : Shape} {analysis : Integer.Analysis}
      {before after : Flow} {items : List Statement}
      (checked : checkStatements shape analysis before items = some after)
      (refined : before.scalars.Refines analysis.declared)
      (bounded : before.scalars.Bounded) (declared : analysis.declared.Bounded) :
      after.scalars.Refines analysis.declared ∧ after.scalars.Bounded := by
    cases items with
    | nil =>
        simp only [checkStatements, Option.some.injEq] at checked
        subst after
        exact ⟨refined, bounded⟩
    | cons item rest =>
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_ranges_invariant firstChecked refined bounded declared
        exact statements_ranges_invariant restChecked first.1 first.2 declared
  termination_by sizeOf items
end

/-- Successful completion must reject every reachable invalid-input path. -/
def completed (context : Context) : Bool := !context.invalidReachable || context.invalidRejected

theorem expression_safe_on_path {shape : Shape} {context : Context} {expression : Expression}
    {ranges : Integer.Ranges} {integers : Integer.Store} {summary : LengthSummary}
    {values : Values} {input : Source} {valid rejected : Bool}
    (known : expression.inferLength shape ranges = some summary)
    (state : Fits shape input values) (scalarState : Integer.Fits ranges integers)
    (allowed : context.Allows valid input.length rejected)
    (checked : fitsLengthSummary context summary = true) :
    expression.RuntimeSafe values input integers :=
  Expression.inferLength_runtimeSafe known state scalarState
    (fitsLengthSummary_sound allowed (Expression.inferLength_sound known state scalarState).1 checked) (Nat.le_refl _)

def executeAssignment (update : Assignment) (values : Values) (input : Source)
    (integers : Integer.Store) : Values :=
  put values update.target (update.value.evaluate values input integers)

theorem assignment_checked_length {shape : Shape} {context : Context} {update : Assignment}
    {ranges : Integer.Ranges} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    (state : Fits shape input values) (scalarState : Integer.Fits ranges integers)
    (allowed : context.Allows valid input.length rejected)
    (checked : checkAssignment shape context update ranges = true) :
    (update.value.evaluate values input integers).length = (values update.target).length := by
  unfold checkAssignment at checked
  split at checked
  · rename_i bound summary target known
    simp only [Bool.and_eq_true] at checked
    have within := (Expression.inferLength_sound known state scalarState).1
    have equal := equalLengthSummary_sound allowed within checked.2
    rw [(state update.target _ target).1]
    simpa only [Bound.summary_length] using equal
  · contradiction

theorem assignment_checked_safe {shape : Shape} {context : Context} {update : Assignment}
    {ranges : Integer.Ranges} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    (state : Fits shape input values) (scalarState : Integer.Fits ranges integers)
    (allowed : context.Allows valid input.length rejected)
    (checked : checkAssignment shape context update ranges = true) :
    update.value.RuntimeSafe values input integers := by
  unfold checkAssignment at checked
  split at checked
  · rename_i bound summary target known
    simp only [Bool.and_eq_true] at checked
    exact expression_safe_on_path known state scalarState allowed checked.1
  · contradiction

theorem assignment_preserves_on_path {shape : Shape} {context : Context} {update : Assignment}
    {ranges : Integer.Ranges} {integers : Integer.Store}
    {values : Values} {input : Source} {valid rejected : Bool}
    (ready : ExpressionReady shape update.value) (state : Fits shape input values)
    (scalarState : Integer.Fits ranges integers)
    (printable : Bindings.Printable input) (allowed : context.Allows valid input.length rejected)
    (checked : checkAssignment shape context update ranges = true) :
    Fits shape input (executeAssignment update values input integers) := by
  have equal := assignment_checked_length state scalarState allowed checked
  unfold checkAssignment at checked
  split at checked
  · rename_i bound summary target known
    intro index info found
    by_cases same : index = update.target
    · subst index
      simp only [executeAssignment, put_same]
      exact ⟨equal.trans (state update.target info found).1,
        Expression.inferLength_printable known state printable ready.2.1⟩
    · simpa only [executeAssignment, put, same, ↓reduceIte] using state index info found
  · contradiction

end Silver.Predicate
