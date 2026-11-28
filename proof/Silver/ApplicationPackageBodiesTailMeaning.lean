module

public import Silver.ApplicationPackageBodiesTailNative

@[expose] public section

namespace Silver.ApplicationPackageBodies.Tail
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true

structure Context where
  text : Source
  parser : Predicate.ParseContext
  info : PackageBindings.Metadata
  stop : Predicate.BodyStop
  requireOne : Bool
  catalog : FunctionBindings.Metadata
  procedures : ProcedureBindings.Metadata

def invocation (locals : Locals) : Context := ⟨locals .source "text", locals .parseContext "context", locals .metadata "info",
  locals .bodyStop "stop", locals .truth "require_one", locals .functions "catalog", locals .procedures "procedure_catalog"⟩

def observed (locals : Locals) : TailState := ⟨locals .appScan "result", locals .truth "seen"⟩

def reader (calls : TailCalls) (current : Context) : TailState → TailStep :=
  tailStep calls current.text current.parser current.info current.stop current.requireOne current.catalog current.procedures

def scanning (calls : TailCalls) (current : Context) (state : TailState) : Bool :=
  decide (state.value.scan.position ≠ 0) && !calls.atBodyStop current.text state.value.scan.position current.stop

def statement (calls : TailCalls) (current : Context) (state : TailState) : ApplicationScan :=
  calls.applicationStatement current.text current.parser state.value current.info current.catalog current.procedures

def advance (locals : Locals) (result : ApplicationScan) : Locals :=
  ((locals.set .number "before" (locals .appScan "result").scan.position).set .appScan "result" result).set .truth "seen" true

def finish (current : Context) (state : TailState) : ApplicationScan :=
  if state.value.scan.position = 0 ∨ (current.requireOne = true ∧ state.seen = false)
  then invalidApplication state.value else state.value

theorem test_meaning (calls : TailCalls) (valid : ValidBody) (locals : Locals) :
    test.eval (functions calls valid) locals = scanning calls (invocation locals) (observed locals) := rfl

theorem iteration_meaning (calls : TailCalls) (valid : ValidBody) (procedures : Statements.Procedures)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    iteration.eval (functions calls valid) procedures fuel locals next leave =
      let value := statement calls (invocation locals) (observed locals)
      if value.scan.position ≤ (observed locals).value.scan.position then some (invalidApplication value)
      else next (advance locals value) := by
  dsimp only [iteration, Statements.Command.list, List.foldr, Statements.Command.eval, Place.set, Expr.eval,
    Field.get, position, scan, result, step, invalid, text, context, functions]
  by_cases stalled : (statement calls (invocation locals) (observed locals)).scan.position ≤ (locals .appScan "result").scan.position
  all_goals dsimp only [statement, invocation, observed] at stalled
  all_goals simp [advance, statement, invocation, observed, Locals.set, stalled]

theorem ending_meaning (calls : TailCalls) (valid : ValidBody) (procedures : Statements.Procedures)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    ending.eval (functions calls valid) procedures fuel locals next leave =
      some (finish (invocation locals) (observed locals)) := by
  dsimp only [ending, Statements.Command.eval, Expr.eval, Field.get, position, scan, result, invalid, functions]
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true', finish, observed, invocation]
  split <;> simp_all

theorem advance_context (locals : Locals) (value : ApplicationScan) :
    invocation (advance locals value) = invocation locals := by simp [invocation, advance, Locals.set]

theorem advance_observed (locals : Locals) (value : ApplicationScan) :
    observed (advance locals value) = ⟨value, true⟩ := by simp [observed, advance, Locals.set]

theorem reader_scanning (calls : TailCalls) (current : Context) (state : TailState) :
    reader calls current state = if scanning calls current state then
      let value := statement calls current state
      if value.scan.position ≤ state.value.scan.position then .returned (invalidApplication value)
      else .continued ⟨value, true⟩
    else .returned (finish current state) := by
  unfold reader tailStep scanning statement finish
  simp only [Bool.and_eq_true, decide_eq_true_eq]
  split <;> simp_all
  split <;> rfl

def nativeLoop (calls : TailCalls) (valid : ValidBody) (procedures : Statements.Procedures) (inner outer : Nat)
    (locals : Locals) : Option ApplicationScan :=
  Statements.loop (fun current => test.eval (functions calls valid) current)
    (fun current next leave => iteration.eval (functions calls valid) procedures inner current next leave)
    (fun current => some (finish (invocation current) (observed current))) outer locals

theorem loop_meaning (calls : TailCalls) (valid : ValidBody) (procedures : Statements.Procedures)
    (inner outer : Nat) (locals : Locals) :
    nativeLoop calls valid procedures inner outer locals =
      tailFuel (reader calls (invocation locals)) outer (observed locals) := by
  induction outer generalizing locals with
  | zero => rfl
  | succ fuel ih =>
    change (if test.eval (functions calls valid) locals then
      iteration.eval (functions calls valid) procedures inner locals (nativeLoop calls valid procedures inner fuel)
        (fun current => some (finish (invocation current) (observed current)))
      else some (finish (invocation locals) (observed locals))) = _
    rw [test_meaning, tailFuel, reader_scanning]
    by_cases active : scanning calls (invocation locals) (observed locals) = true
    · rw [ite_eq_left active, ite_eq_left active, iteration_meaning]
      dsimp only
      by_cases stalled : (statement calls (invocation locals) (observed locals)).scan.position ≤
          (observed locals).value.scan.position
      · simp [stalled]
      · simp only [ite_eq_right stalled, ih, advance_context, advance_observed]
    · simp [active]

theorem body_meaning (calls : TailCalls) (valid : ValidBody) (procedures : Statements.Procedures)
    (fuel : Nat) (locals : Locals) :
    body.eval (functions calls valid) procedures fuel locals =
      tailFuel (reader calls (invocation locals)) fuel ⟨locals .appScan "input", false⟩ := by
  let initial := declarations.foldl (enter (functions calls valid)) locals
  have endingEquation := funext (fun current => ending_meaning calls valid procedures fuel current (fun _ => none) (fun _ => none))
  change Statements.loop _ _ (fun current => ending.eval (functions calls valid) procedures fuel current
    (fun _ => none) (fun _ => none)) fuel initial = _
  rw [endingEquation]
  rw [show Statements.loop _ _ _ fuel initial = nativeLoop calls valid procedures fuel fuel initial by rfl, loop_meaning]
  dsimp only [initial, declarations, List.foldl, enter, Declaration.eval, Declaration.names, Expr.eval, input]
  simp [invocation, observed, Locals.set]

end Silver.ApplicationPackageBodies.Tail
