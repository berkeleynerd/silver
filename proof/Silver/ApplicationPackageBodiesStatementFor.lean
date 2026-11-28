module

public import Silver.ApplicationPackageBodiesStatementHeader
public import Silver.ApplicationPackageBodiesStatementInner
public import Silver.ApplicationPackageBodiesStatementConditional

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

theorem eval_two (first second : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [first, second]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    first.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => second.eval (functions calls valid) (procedures calls) fuel l next leave) leave := rfl

theorem nothing_eval (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next leave : Continuation) :
    (Statements.Command.nothing : C).eval (functions calls valid) (procedures calls) fuel locals next leave = next locals := rfl

theorem eval_choose (test : E .truth) (yes no : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.choose test yes no).eval (functions calls valid) (procedures calls) fuel locals next leave =
    if test.eval (functions calls valid) locals then yes.eval (functions calls valid) (procedures calls) fuel locals next leave
    else no.eval (functions calls valid) (procedures calls) fuel locals next leave := rfl

def selectedHeader (calls : Statement.Calls) (s : Input) (base : ApplicationScan) (first last : Nat) : Option Iteration :=
  if rejectedBinder calls s first last then none
  else if calls.takeToken s.text last (.word "of") ≠ 0 then arrayHeader calls s base first last
  else some (countedHeader calls s base first last)

theorem forSelect_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : HeaderContinuation) (leave : Continuation) :
    forSelect.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => next (source l) (iteration l)) leave =
    afterHeader (source locals) (selectedHeader calls (source locals) (locals .appScan "result")
      (locals .number "first") (locals .number "last")) next := by
  rw [forSelect, eval_two, eval_choose, binder_meaning, selectedHeader]
  by_cases reject : rejectedBinder calls (source locals) (locals .number "first") (locals .number "last") = true
  · simp only [reject, ↓reduceIte]
    rfl
  · simp only [ite_eq_right reject]
    rw [nothing_eval, eval_choose]
    have test : (nonzero (keyword last "of")).eval (functions calls valid) locals =
      decide (calls.takeToken (source locals).text (locals .number "last") (.word "of") ≠ 0) := rfl
    rw [test]
    by_cases missing : calls.takeToken (source locals).text (locals .number "last") (.word "of") = 0
    · simpa [missing, afterHeader] using countedCommands_meaning calls valid fuel locals next leave
    · simpa [missing] using arrayCommands_meaning calls valid fuel locals next leave

def startFor (calls : Statement.Calls) (s : Input) : Nat := calls.takeToken s.text s.input.scan.position (.word "for")

def binderLocals (calls : Statement.Calls) (locals : Locals) : Locals :=
  let s := source locals
  let pos := startFor calls s
  let first := calls.skipAt s.text pos
  let last := calls.nameAfter s.text first
  ((locals.set .appScan "result" (atPosition (locals .appScan "result") pos)).set .number "first" first).set .number "last" last

theorem forBinder_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next leave : Continuation) :
    forBinder.eval (functions calls valid) (procedures calls) fuel locals next leave =
      next (binderLocals calls locals) := rfl

theorem selectedHeader_position (calls : Statement.Calls) (s : Input) (base : ApplicationScan) (pos first last : Nat) :
    selectedHeader calls s (atPosition base pos) first last = selectedHeader calls s base first last := by
  unfold selectedHeader
  split
  · rfl
  · split
    · unfold arrayHeader
      split <;> first | rfl | split <;> rfl
    · unfold countedHeader
      dsimp only
      split <;> rfl

theorem closing_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (word : String) (leave : Continuation) :
    (close word).eval (functions calls valid) (procedures calls) fuel locals (checkedResult calls) leave =
      some (validate calls (source locals) (closeTokens calls (source locals) (locals .appScan "result") (.word word))) := by
  dsimp only [close, closeToken, Statements.Command.list, List.foldr, Statements.Command.eval, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, text, context, scan, result, functions, checkedResult, source, closeTokens, Locals.set]
  rfl

def finishFor (calls : Statement.Calls) (s : Input) (it : Iteration) : ApplicationScan :=
  if it.value.scan.position ≤ s.input.scan.position then invalidApplication s.input
  else
    let widened := calls.widenInto s.context it.value.scan.facts
    let body := tail calls s (innerContext s it) (innerInput s it widened) .endOnly
    if body.scan.position = 0 then invalidApplication s.input
    else validate calls s (closeTokens calls s (afterIteration calls s it widened body) (.word "loop"))

def widenedLocals (calls : Statement.Calls) (locals : Locals) : Locals :=
  let v := locals .appScan "result"
  locals.set .appScan "result" (withFacts v (calls.widenInto (locals .parseContext "context") v.scan.facts))

def widenedIteration (calls : Statement.Calls) (s : Input) (it : Iteration) : Iteration :=
  {it with value := withFacts it.value (calls.widenInto s.context it.value.scan.facts)}

private theorem widened_scope (calls : Statement.Calls) (locals : Locals) :
    source (widenedLocals calls locals) = source locals := rfl

private theorem widened_iteration (calls : Statement.Calls) (locals : Locals) :
    iteration (widenedLocals calls locals) = widenedIteration calls (source locals) (iteration locals) := rfl

private theorem widened_result (calls : Statement.Calls) (s : Input) (it : Iteration)
    (advanced : ¬it.value.scan.position ≤ s.input.scan.position) :
    let grown := widenedIteration calls s it
    readLoop calls ⟨s, grown, innerContext s grown, innerInput s grown grown.value.scan.facts⟩
      (fun scope value => some (validate calls scope (closeTokens calls scope value (.word "loop")))) =
      some (finishFor calls s it) := by
  let wide := calls.widenInto s.context it.value.scan.facts
  let body := tail calls s (innerContext s it) (innerInput s it wide) .endOnly
  let result := validate calls s (closeTokens calls s (afterIteration calls s it wide body) (.word "loop"))
  change (if body.scan.position = 0 then some (invalidApplication s.input) else some result) = some (finishFor calls s it)
  rw [finishFor, ite_eq_right advanced]
  change (if body.scan.position = 0 then some (invalidApplication s.input) else some result) =
    some (if body.scan.position = 0 then invalidApplication s.input else result)
  by_cases failed : body.scan.position = 0 <;> simp only [failed, ↓reduceIte]

private theorem widen_eval (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next leave : Continuation) :
    (Statements.Command.procedure (.widenInto context facts)).eval (functions calls valid) (procedures calls)
      fuel locals next leave = next (widenedLocals calls locals) := rfl

private theorem static_eval (test : E .truth) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.staticAssert test).eval (functions calls valid) (procedures calls)
      fuel locals next leave = next locals := rfl

private theorem eval_bounds (check widen annotation block ending : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [check, widen, annotation, block, ending]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    check.eval (functions calls valid) (procedures calls) fuel locals (fun l =>
      widen.eval (functions calls valid) (procedures calls) fuel l (fun w =>
        annotation.eval (functions calls valid) (procedures calls) fuel w (fun a =>
          block.eval (functions calls valid) (procedures calls) fuel a
            (fun b => ending.eval (functions calls valid) (procedures calls) fuel b next leave) leave) leave) leave) leave := rfl

theorem forBounds_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (leave : Continuation) :
    forBounds.eval (functions calls valid) (procedures calls) fuel locals (checkedResult calls) leave =
      some (finishFor calls (source locals) (iteration locals)) := by
  rw [forBounds, eval_bounds, funext (fun current => closing_meaning calls valid fuel current "loop" leave)]
  have innerEq := funext (fun current => innerBlock_meaning calls valid fuel current
    (fun s v => some (validate calls s (closeTokens calls s v (.word "loop")))) leave)
  rw [innerEq, eval_choose]
  have test : (Expr.le position.expression inputPos).eval (functions calls valid) locals =
      decide ((iteration locals).value.scan.position ≤ (source locals).input.scan.position) := rfl
  rw [test]
  by_cases stalled : (iteration locals).value.scan.position ≤ (source locals).input.scan.position
  · simp only [stalled, decide_true, ↓reduceIte, finishFor]
    rfl
  · simp only [stalled, decide_false, Bool.false_eq_true, ↓reduceIte]
    rw [nothing_eval, widen_eval, static_eval]
    simp only [widened_scope, widened_iteration]
    exact widened_result calls (source locals) (iteration locals) stalled

theorem forCommands_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (entry : locals .appScan "result" = (source locals).input) (leave : Continuation) :
    forCommands.eval (functions calls valid) (procedures calls) fuel locals (checkedResult calls) leave =
      some (forStatement calls (source locals) (startFor calls (source locals))) := by
  rw [forCommands, eval_three, funext (fun current => forBounds_meaning calls valid fuel current leave)]
  have selectEq := funext (fun current => forSelect_meaning calls valid fuel current
    (fun s it => some (finishFor calls s it)) leave)
  rw [selectEq, forBinder_meaning]
  dsimp only [binderLocals, Locals.set, source]
  simp only
  rw [entry]
  let s := source locals
  change afterHeader s (forHeader calls s (startFor calls s)) (fun scope it => some (finishFor calls scope it)) =
    some (forStatement calls s (startFor calls s))
  unfold forStatement
  cases forHeader calls s (startFor calls s) <;> rfl

end Silver.ApplicationPackageBodies.Statement.Native
