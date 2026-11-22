module

public import Silver.BooleanElaboration
public import Silver.ComposeBooleanDeclarationNative
public import Silver.PredicateConditionReadings

@[expose] public section

/-! The executable equations of the package elaboration Boolean reader.
The four native helpers are kept separate, including the ordered scalar and
Boolean alternatives. Imported leaf calls and recursive calls are parameters;
the source bridge must identify them on their complete native domains. -/
namespace Silver.BooleanElaboration.Native

structure Result where
  after : Nat := 0
  value : Bool := false
  deriving DecidableEq, Repr

def invalid : Result := {}

inductive Token | leftParenthesis | rightParenthesis | notKeyword
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .leftParenthesis => "left_parenthesis"
  | .rightParenthesis => "right_parenthesis"
  | .notKeyword => "not_keyword"

def Token.shell : Token → Compose.ShellToken
  | .leftParenthesis => .symbol "("
  | .rightParenthesis => .symbol ")"
  | .notKeyword => .word "not"

abbrev Chain := Option Predicate.ChainKind
abbrev Reader := Source → Compose.ParserState → Nat → Result

structure Imports where
  take : Source → Nat → Token → Nat
  reference : Source → Nat → QualifiedNames.Reference
  lookup : Source → BooleanBindings.Environment → Nat → Nat → Nat → Nat → Nat
  nameIs : Source → Nat → Nat → String → Bool
  booleanAtom : Source → Compose.ParserState → Nat → Nat
  scalar : Source → Nat → ScalarExpression.Environment → ScalarExpression.Result
  comparison : Source → Nat → Predicate.ComparisonResult
  chain : Source → Nat → Chain
  chainAfter : Source → Nat → Chain → Nat

def modelImports : Imports where
  take text position token := match token with
    | .leftParenthesis => Compose.fixedAfter text position "(" false
    | .rightParenthesis => Compose.fixedAfter text position ")" false
    | .notKeyword => Compose.fixedAfter text position "not" true
  reference := QualifiedNames.read
  lookup text names first after qualifierFirst qualifierAfter :=
    BooleanBindings.lookup text names first after qualifierFirst qualifierAfter
  nameIs text first after spelling := Named.nameIs text first after (spelling.toList.map Char.toNat)
  booleanAtom text frame position := Predicate.booleanAtomAfter text
    (Compose.BooleanDeclarationNative.contextOf ⟨frame, false, false⟩).model position
  scalar text position names := ScalarExpression.read text position names (elaborating := true)
  comparison := Predicate.comparisonAt
  chain := Predicate.chainOperator
  chainAfter text position operator := match operator with
    | none => 0
    | some op => Predicate.chainAfter text position op

def primaryStep (imports : Imports) (condition : Reader)
    (text : Source) (frame : Compose.ParserState) (position : Nat) : Result :=
  let opened := imports.take text position .leftParenthesis
  let reference := imports.reference text position
  let found := imports.lookup text frame.booleanNames reference.first reference.after
    reference.qualifierFirst reference.qualifierAfter
  if position = 0 then invalid
  else if opened ≠ 0 then
    let result := condition text frame opened
    {result with after := imports.take text result.after .rightParenthesis}
  else if found ≠ 0 ∧ (BooleanBindings.binding frame.booleanNames found).known = true then
    ⟨reference.after, (BooleanBindings.binding frame.booleanNames found).value⟩
  else if found = 0 ∧ reference.qualifierFirst = 0 ∧ reference.first ≠ 0 ∧
      reference.after > reference.first ∧ imports.booleanAtom text frame position ≠ 0 then
    if imports.nameIs text reference.first reference.after "true" then ⟨reference.after, true⟩
    else if imports.nameIs text reference.first reference.after "false" then ⟨reference.after, false⟩
    else invalid
  else invalid

def factorStep (imports : Imports) (primary : Reader)
    (text : Source) (frame : Compose.ParserState) (position : Nat) : Result :=
  let negated := imports.take text position .notKeyword
  let result := primary text frame (if negated = 0 then position else negated)
  if negated ≠ 0 then {result with value := !result.value} else result

def compareValues (operator : Predicate.Comparison) (left right : Int) : Bool :=
  match operator with
  | .eq => decide (left = right)
  | .ne => decide (left ≠ right)
  | .lt => decide (left < right)
  | .le => decide (left ≤ right)
  | .gt => decide (left > right)
  | .ge => decide (left ≥ right)

theorem compareValues_evaluate (operator : Predicate.Comparison) (left right : Int) :
    compareValues operator left right = operator.toInteger.evaluate left right := by
  cases operator <;> rfl

def relationStep (imports : Imports) (factor : Reader)
    (text : Source) (frame : Compose.ParserState) (position : Nat) : Result :=
  let left := imports.scalar text position frame.scalarNames
  let compare := imports.comparison text left.after
  if left.after ≠ 0 ∧ compare.after ≠ 0 then
    let right := imports.scalar text compare.after frame.scalarNames
    if right.after = 0 ∨ left.bounds.isEmpty = true ∨ right.bounds.isEmpty = true ∨
        left.bounds.lower ≠ left.bounds.upper ∨ right.bounds.lower ≠ right.bounds.upper then invalid
    else ⟨right.after, compareValues compare.operator left.bounds.lower right.bounds.lower⟩
  else
    let flagLeft := factor text frame position
    if flagLeft.after = 0 then invalid else
    let booleanCompare := imports.comparison text flagLeft.after
    if booleanCompare.after = 0 then flagLeft
    else if booleanCompare.operator ≠ .eq ∧ booleanCompare.operator ≠ .ne then invalid
    else
      let flagRight := factor text frame booleanCompare.after
      if flagRight.after = 0 then invalid
      else ⟨flagRight.after, (flagLeft.value == flagRight.value) == (booleanCompare.operator == .eq)⟩

def combine (operator : Chain) (left right : Bool) : Bool :=
  match operator with
  | some .eagerAnd | some .shortAnd => left && right
  | some .eagerOr | some .shortOr => left || right
  | some .eagerXor => Bool.xor left right
  | none => left

/-- One iteration has three distinguishable outcomes: ordinary exit, rejected
input and a progressing accumulator. Loop execution, below, never equates a
fuel cutoff with the native invalid result. -/
inductive LoopStep
  | finished (result : Result)
  | next (result : Result)
  deriving DecidableEq, Repr

def tailStep (imports : Imports) (relation : Reader) (text : Source)
    (frame : Compose.ParserState) (selected : Chain) (result : Result) : LoopStep :=
  if selected = none then .finished result else
  let operator := imports.chain text result.after
  if operator = none then .finished result
  else if operator ≠ selected then .finished invalid
  else
    let right := relation text frame (imports.chainAfter text result.after operator)
    if right.after ≤ result.after then .finished invalid
    else .next ⟨right.after, combine operator result.value right.value⟩

/-- Finite execution of the actual loop. Its source variant proves existence;
this relation records the exact result without a bounded-execution fallback. -/
inductive TailExec (imports : Imports) (relation : Reader) (text : Source)
    (frame : Compose.ParserState) (selected : Chain) : Result → Result → Prop
  | finished {input output} : tailStep imports relation text frame selected input = .finished output →
      TailExec imports relation text frame selected input output
  | next {input middle output} : tailStep imports relation text frame selected input = .next middle →
      TailExec imports relation text frame selected middle output →
      TailExec imports relation text frame selected input output

theorem TailExec.unique {imports relation text frame selected input left right}
    (a : TailExec imports relation text frame selected input left)
    (b : TailExec imports relation text frame selected input right) : left = right := by
  induction a with
  | finished step =>
      cases b with
      | finished other => exact LoopStep.finished.inj (step.symm.trans other)
      | next other _ => cases step.symm.trans other
  | next step _ ih =>
      cases b with
      | finished other => cases step.symm.trans other
      | next other rest =>
          have same := LoopStep.next.inj (step.symm.trans other)
          cases same
          exact ih rest

theorem tailStep_next_progress {imports relation text frame selected input next}
    (step : tailStep imports relation text frame selected input = .next next) :
    input.after < next.after := by
  unfold tailStep at step
  split at step
  · cases step
  · dsimp only at step
    split at step
    · cases step
    · split at step
      · cases step
      · split at step
        · cases step
        · rename_i progress
          cases step
          exact Nat.lt_of_not_ge progress

/-- Bounded progressing executions terminate. The bound is precisely the
recursive reader's native postcondition, not an artificial fuel cutoff. -/
theorem TailExec.exists {imports relation text frame selected} (ceiling : Nat)
    (preserved : ∀ input, input.after ≤ ceiling → ∀ next,
      tailStep imports relation text frame selected input = .next next → next.after ≤ ceiling)
    (input : Result) (bounded : input.after ≤ ceiling) :
    ∃ output, TailExec imports relation text frame selected input output := by
  have total : ∀ remaining, ∀ input : Result, ceiling - input.after = remaining →
      input.after ≤ ceiling → ∃ output, TailExec imports relation text frame selected input output := by
    intro remaining
    induction remaining using Nat.strongRecOn with
    | ind remaining ih =>
      intro input measure bounded
      cases step : tailStep imports relation text frame selected input with
      | finished output => exact ⟨output, .finished step⟩
      | next next =>
        have progress := tailStep_next_progress step
        have nextBounded := preserved input bounded next step
        have decreases : ceiling - next.after < remaining := by omega
        obtain ⟨output, rest⟩ := ih (ceiling - next.after) decreases next rfl nextBounded
        exact ⟨output, .next step rest⟩
  exact total (ceiling - input.after) input rfl bounded

def ConditionExec (imports : Imports) (relation : Reader) (text : Source)
    (frame : Compose.ParserState) (position : Nat) (output : Result) : Prop :=
  let result := relation text frame position
  if result.after = 0 then output = invalid else
    TailExec imports relation text frame (imports.chain text result.after) result output

theorem ConditionExec.unique {imports relation text frame position left right}
    (a : ConditionExec imports relation text frame position left)
    (b : ConditionExec imports relation text frame position right) : left = right := by
  unfold ConditionExec at a b
  dsimp only at a b
  split at a
  · rename_i failed
    simp only [failed, ↓reduceIte] at b
    exact a.trans b.symm
  · rename_i present
    simp only [present, ↓reduceIte] at b
    exact a.unique b

end Silver.BooleanElaboration.Native
