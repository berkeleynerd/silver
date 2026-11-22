module

public import Silver.StaticBooleanNative

@[expose] public section

/-! A typed interpretation of the complete `Static_Boolean_At` body. The loop
uses finite execution derivations; exhausting an arbitrary fuel is never an
invalid parse. Every branch, update, declaration and annotation is rendered. -/
namespace Silver.BooleanElaboration.Native.Condition

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Frame where
  text : Source
  state : Compose.ParserState
  position : Nat
  result : Result
  right : Result
  operator : Chain
  selected : Chain

inductive Expr : Type → Type 1
  | number : Nat → Expr Nat
  | position : Expr Nat
  | result : Expr Result
  | rightResult : Expr Result
  | chainOperator : Expr Chain
  | selected : Expr Chain
  | noChain : Expr Chain
  | invalid : Expr Result
  | after : Expr Result → Expr Nat
  | resultValue : Expr Result → Expr Bool
  | chain : Expr Nat → Expr Chain
  | chainAfter : Expr Nat → Expr Chain → Expr Nat
  | relation : Expr Nat → Expr Result
  | equal : Expr Nat → Expr Nat → Expr Bool
  | lessEqual : Expr Nat → Expr Nat → Expr Bool
  | equalChain : Expr Chain → Expr Chain → Expr Bool
  | unequalChain : Expr Chain → Expr Chain → Expr Bool
  | and : Expr Bool → Expr Bool → Expr Bool
  | or : Expr Bool → Expr Bool → Expr Bool
  | xor : Expr Bool → Expr Bool → Expr Bool
  | group : Expr α → Expr α
  | chainCase : Expr Chain → Expr Bool → Expr Bool → Expr Bool → Expr Bool → Expr Bool

def Expr.eval (imports : Imports) (relation : Reader) (frame : Frame) : Expr α → α
  | .number value => value
  | .position => frame.position
  | .result => frame.result
  | .rightResult => frame.right
  | .chainOperator => frame.operator
  | .selected => frame.selected
  | .noChain => none
  | .invalid => Silver.BooleanElaboration.Native.invalid
  | .after value => (value.eval imports relation frame).after
  | .resultValue value => (value.eval imports relation frame).value
  | .chain cursor => imports.chain frame.text (cursor.eval imports relation frame)
  | .chainAfter cursor operator => imports.chainAfter frame.text
      (cursor.eval imports relation frame) (operator.eval imports relation frame)
  | .relation cursor => relation frame.text frame.state (cursor.eval imports relation frame)
  | .equal left right => left.eval imports relation frame == right.eval imports relation frame
  | .lessEqual left right => decide (left.eval imports relation frame ≤ right.eval imports relation frame)
  | .equalChain left right => decide (left.eval imports relation frame = right.eval imports relation frame)
  | .unequalChain left right => decide (left.eval imports relation frame ≠ right.eval imports relation frame)
  | .and left right => left.eval imports relation frame && right.eval imports relation frame
  | .or left right => left.eval imports relation frame || right.eval imports relation frame
  | .xor left right => Bool.xor (left.eval imports relation frame) (right.eval imports relation frame)
  | .group value => value.eval imports relation frame
  | .chainCase operator conjunction disjunction exclusive unchanged =>
      match operator.eval imports relation frame with
      | some .eagerAnd | some .shortAnd => conjunction.eval imports relation frame
      | some .eagerOr | some .shortOr => disjunction.eval imports relation frame
      | some .eagerXor => exclusive.eval imports relation frame
      | none => unchanged.eval imports relation frame

def Expr.render : Expr α → List String
  | .number value => [toString value]
  | .position => ["position"]
  | .result => ["result"] | .rightResult => ["right"]
  | .chainOperator => ["operator"] | .selected => ["selected"]
  | .noChain => ["no_chain"] | .invalid => ["invalid_static_boolean"]
  | .after value => value.render ++ [".", "after"]
  | .resultValue value => value.render ++ [".", "value"]
  | .chain cursor => call ["chain_token"] [["text"], cursor.render]
  | .chainAfter cursor operator => call ["chain_after"] [["text"], cursor.render, operator.render]
  | .relation cursor => call ["static_boolean_relation"] [["text"], ["frame"], cursor.render]
  | .equal left right | .equalChain left right => left.render ++ ["="] ++ right.render
  | .lessEqual left right => left.render ++ ["<="] ++ right.render
  | .unequalChain left right => left.render ++ ["/="] ++ right.render
  | .and left right => left.render ++ ["and"] ++ right.render
  | .or left right => left.render ++ ["or"] ++ right.render
  | .xor left right => left.render ++ ["xor"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .chainCase operator conjunction disjunction exclusive unchanged =>
      ["case"] ++ operator.render ++ ["is", "when", "eager_and", "|", "short_and", "=>"] ++ conjunction.render ++
      [",", "when", "eager_or", "|", "short_or", "=>"] ++ disjunction.render ++
      [",", "when", "eager_xor", "=>"] ++ exclusive.render ++
      [",", "when", "no_chain", "=>"] ++ unchanged.render

def Expr.primaryOperand : Expr α → Bool
  | .equal _ _ | .lessEqual _ _ | .equalChain _ _ | .unequalChain _ _ |
      .and _ _ | .or _ _ | .xor _ _ | .chainCase _ _ _ _ _ => false
  | _ => true
def Expr.wellFormed : Expr α → Bool
  | .number _ | .position | .result | .rightResult | .chainOperator | .selected | .noChain | .invalid => true
  | .after value | .resultValue value => match value with | .result | .rightResult => true | _ => false
  | .chain cursor | .relation cursor => cursor.primaryOperand && cursor.wellFormed
  | .chainAfter cursor operator => cursor.primaryOperand && cursor.wellFormed && operator.primaryOperand && operator.wellFormed
  | .equal left right | .lessEqual left right | .equalChain left right | .unequalChain left right |
      .and left right | .or left right | .xor left right =>
      left.primaryOperand && left.wellFormed && right.primaryOperand && right.wellFormed
  | .group value => value.wellFormed
  | .chainCase operator conjunction disjunction exclusive unchanged =>
      operator.primaryOperand && operator.wellFormed && conjunction.wellFormed && disjunction.wellFormed &&
      exclusive.wellFormed && unchanged.wellFormed

inductive Annotation | resultRange | increasingAfter
def Annotation.render : Annotation → List String
  | .resultRange => ["pragma", "loop_invariant", "(", "result", ".", "after", "in", "position", "+", "1",
      "..", "text", "'", "last", "+", "1", ")", ";"]
  | .increasingAfter => ["pragma", "loop_variant", "(", "increases", "=>", "result", ".", "after", ")", ";"]

inductive Outcome
  | continued : Frame → Outcome
  | returned : Result → Outcome

def Outcome.project : Outcome → LoopStep
  | .continued frame => .next frame.result
  | .returned result => .finished result

inductive Command
  | nothing
  | annotation : Annotation → Command
  | setResult : Expr Result → Command
  | setRight : Expr Result → Command
  | setValue : Expr Bool → Command
  | setAfter : Expr Nat → Command
  | setOperator : Expr Chain → Command
  | setSelected : Expr Chain → Command
  | sequence : Command → Command → Command
  | choose : Expr Bool → Command → Command → Command
  | returned : Expr Result → Command

def Command.eval (imports : Imports) (relation : Reader) (frame : Frame) : Command → Outcome
  | .nothing | .annotation _ => .continued frame
  | .setResult value => .continued {frame with result := value.eval imports relation frame}
  | .setRight value => .continued {frame with right := value.eval imports relation frame}
  | .setValue value => .continued {frame with result := {frame.result with value := value.eval imports relation frame}}
  | .setAfter value => .continued {frame with result := {frame.result with after := value.eval imports relation frame}}
  | .setOperator value => .continued {frame with operator := value.eval imports relation frame}
  | .setSelected value => .continued {frame with selected := value.eval imports relation frame}
  | .sequence first rest => match first.eval imports relation frame with
      | .returned result => .returned result | .continued updated => rest.eval imports relation updated
  | .choose test yes no => if test.eval imports relation frame then yes.eval imports relation frame
      else no.eval imports relation frame
  | .returned value => .returned (value.eval imports relation frame)

mutual
  def Command.render : Command → List String
    | .nothing => [] | .annotation value => value.render
    | .setResult value => ["result", ":="] ++ value.render ++ [";"]
    | .setRight value => ["right", ":="] ++ value.render ++ [";"]
    | .setValue value => ["result", ".", "value", ":="] ++ value.render ++ [";"]
    | .setAfter value => ["result", ".", "after", ":="] ++ value.render ++ [";"]
    | .setOperator value => ["operator", ":="] ++ value.render ++ [";"]
    | .setSelected value => ["selected", ":="] ++ value.render ++ [";"]
    | .sequence first rest => first.render ++ rest.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .returned value => ["return"] ++ value.render ++ [";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def Command.wellFormed : Command → Bool
  | .nothing | .annotation _ => true
  | .setResult value | .setRight value | .setValue value | .setAfter value |
      .setOperator value | .setSelected value | .returned value => value.wellFormed
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.wellFormed && yes.wellFormed && no.wellFormed

def combinedValue : Expr Bool := .group (.chainCase .chainOperator
  (.and (.resultValue .result) (.resultValue .rightResult)) (.or (.resultValue .result) (.resultValue .rightResult))
  (.xor (.resultValue .result) (.resultValue .rightResult)) (.resultValue .result))
def prelude : Command := .list [
  .choose (.equal (.after .result) (.number 0)) (.returned .invalid) .nothing,
  .setSelected (.chain (.after .result))]
def test : Expr Bool := .unequalChain .selected .noChain
def commands : Command := .list [
  .annotation .resultRange, .annotation .increasingAfter,
  .setOperator (.chain (.after .result)),
  .choose (.equalChain .chainOperator .noChain) (.returned .result) .nothing,
  .choose (.unequalChain .chainOperator .selected) (.returned .invalid) .nothing,
  .setRight (.relation (.chainAfter (.after .result) .chainOperator)),
  .choose (.lessEqual (.after .rightResult) (.after .result)) (.returned .invalid) .nothing,
  .setValue combinedValue, .setAfter (.after .rightResult)]
def finish : Command := .returned .result

/-- The false while-test reaches the trailing native return. -/
def step (imports : Imports) (relation : Reader) (frame : Frame) : Outcome :=
  if test.eval imports relation frame then commands.eval imports relation frame else finish.eval imports relation frame

def expectedStep (imports : Imports) (relation : Reader) (frame : Frame) : Outcome :=
  if frame.selected = none then .returned frame.result else
  let operator := imports.chain frame.text frame.result.after
  if operator = none then .returned frame.result
  else if operator ≠ frame.selected then .returned invalid
  else
    let right := relation frame.text frame.state (imports.chainAfter frame.text frame.result.after operator)
    if right.after ≤ frame.result.after then .returned invalid
    else .continued {frame with operator := operator, right := right, result := ⟨right.after, combine operator frame.result.value right.value⟩}

theorem combinedValue_eval (imports : Imports) (relation : Reader) (frame : Frame) :
    combinedValue.eval imports relation frame = combine frame.operator frame.result.value frame.right.value := by
  cases h : frame.operator with
  | none => simp only [combinedValue, Expr.eval, h, combine]
  | some operator => cases operator <;> simp only [combinedValue, Expr.eval, h, combine]

theorem step_equation (imports : Imports) (relation : Reader) (frame : Frame) :
    step imports relation frame = expectedStep imports relation frame := by
  dsimp +instances only [step, test, commands, Command.list, List.foldr, Command.eval, finish, Expr.eval]
  simp only [combinedValue_eval, decide_eq_true_eq, expectedStep]
  by_cases stopped : frame.selected = none
  · simp [stopped]
  · by_cases absent : imports.chain frame.text frame.result.after = none
    · simp [stopped, absent]
    · by_cases mixed : imports.chain frame.text frame.result.after ≠ frame.selected
      · simp [stopped, absent, mixed]
      · by_cases rejected : (relation frame.text frame.state
          (imports.chainAfter frame.text frame.result.after (imports.chain frame.text frame.result.after))).after ≤ frame.result.after
        · simp [stopped, absent, mixed, rejected]
        · simp [stopped, absent, mixed, rejected]

theorem step_projection (imports : Imports) (relation : Reader) (frame : Frame) :
    (step imports relation frame).project =
      tailStep imports relation frame.text frame.state frame.selected frame.result := by
  rw [step_equation]
  unfold expectedStep tailStep
  by_cases stopped : frame.selected = none
  · simp [stopped, Outcome.project]
  · by_cases absent : imports.chain frame.text frame.result.after = none
    · simp [stopped, absent, Outcome.project]
    · by_cases mixed : imports.chain frame.text frame.result.after ≠ frame.selected
      · simp [stopped, absent, mixed, Outcome.project]
      · by_cases rejected : (relation frame.text frame.state
          (imports.chainAfter frame.text frame.result.after (imports.chain frame.text frame.result.after))).after ≤ frame.result.after
        · simp [stopped, absent, mixed, rejected, Outcome.project]
        · simp [stopped, absent, mixed, rejected, Outcome.project]

theorem step_preserves {imports relation frame next}
    (progress : step imports relation frame = .continued next) :
    next.text = frame.text ∧ next.state = frame.state ∧ next.position = frame.position ∧
      next.selected = frame.selected := by
  rw [step_equation] at progress
  unfold expectedStep at progress
  split at progress
  · cases progress
  · dsimp only at progress
    split at progress
    · cases progress
    · split at progress
      · cases progress
      · split at progress
        · cases progress
        · cases progress
          exact ⟨rfl, rfl, rfl, rfl⟩

inductive Execution (imports : Imports) (relation : Reader) : Frame → Result → Prop
  | returned {frame output} : step imports relation frame = .returned output → Execution imports relation frame output
  | continued {frame next output} : step imports relation frame = .continued next →
      Execution imports relation next output → Execution imports relation frame output

theorem Execution.model {imports relation frame output} (run : Execution imports relation frame output) :
    TailExec imports relation frame.text frame.state frame.selected frame.result output := by
  induction run with
  | returned step =>
      apply TailExec.finished
      rw [← step_projection, step]
      rfl
  | continued step _ ih =>
      have preserved := step_preserves step
      apply TailExec.next (middle := _)
      · rw [← step_projection, step]
        rfl
      · simpa only [preserved.1, preserved.2.1, preserved.2.2.2] using ih

theorem Execution.of_model {imports relation text state selected input output}
    (run : TailExec imports relation text state selected input output) :
    ∀ frame : Frame, frame.text = text → frame.state = state → frame.selected = selected →
      frame.result = input → Execution imports relation frame output := by
  induction run with
  | finished finished =>
      intro frame textSame stateSame selectedSame inputSame
      have observed := step_projection imports relation frame
      rw [textSame, stateSame, selectedSame, inputSame, finished] at observed
      cases step : Condition.step imports relation frame with
      | returned result =>
          rw [step] at observed
          have resultSame := LoopStep.finished.inj observed
          cases resultSame
          exact .returned step
      | continued next => rw [step] at observed; cases observed
  | next advance _ ih =>
      intro frame textSame stateSame selectedSame inputSame
      have observed := step_projection imports relation frame
      rw [textSame, stateSame, selectedSame, inputSame, advance] at observed
      cases step : Condition.step imports relation frame with
      | returned result => rw [step] at observed; cases observed
      | continued next =>
          rw [step] at observed
          have resultSame := LoopStep.next.inj observed
          have preserved := step_preserves step
          exact .continued step (ih next (preserved.1.trans textSame)
            (preserved.2.1.trans stateSame) (preserved.2.2.2.trans selectedSame) resultSame)

inductive Declaration
  | result : Expr Result → Declaration
  | chains
  | right
def Declaration.eval (imports : Imports) (relation : Reader) (frame : Frame) : Declaration → Frame
  | .result value => {frame with result := value.eval imports relation frame}
  | .chains => frame
  | .right => {frame with right := invalid}
def Declaration.render : Declaration → List String
  | .result value => ["result", ":", "static_boolean_result", ":="] ++ value.render ++ [";"]
  | .chains => ["operator", ",", "selected", ":", "chain_kind", ";"]
  | .right => ["right", ":", "static_boolean_result", ";"]
def declarations : List Declaration := [.result (.relation .position), .chains, .right]

def BodyExec (imports : Imports) (relation : Reader) (initial : Frame) (output : Result) : Prop :=
  let declared := declarations.foldl (Declaration.eval imports relation) initial
  match prelude.eval imports relation declared with
  | .returned result => output = result
  | .continued frame => Execution imports relation frame output

def render : List String := declarations.flatMap Declaration.render ++ ["begin"] ++ prelude.render ++
  ["while"] ++ test.render ++ ["loop"] ++ commands.render ++ ["end", "loop", ";"] ++
  finish.render ++ ["end", "static_boolean_at", ";"]

theorem wellFormed : prelude.wellFormed && test.wellFormed && commands.wellFormed && finish.wellFormed = true := rfl

theorem body_denotation (imports : Imports) (relation : Reader) (initial : Frame) (output : Result) :
    BodyExec imports relation initial output ↔
      ConditionExec imports relation initial.text initial.state initial.position output := by
  dsimp +instances only [BodyExec, ConditionExec, declarations, List.foldl, Declaration.eval,
    prelude, Command.list, List.foldr, Command.eval, Expr.eval]
  simp only [beq_iff_eq]
  by_cases failed : (relation initial.text initial.state initial.position).after = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte]
    constructor
    · exact Execution.model
    · intro run
      exact Execution.of_model run _ rfl rfl rfl rfl

end Silver.BooleanElaboration.Native.Condition
