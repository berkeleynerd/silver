module

public import Silver.ApplicationPackageBodiesStatementArms

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true

def checkedResult (calls : Statement.Calls) (locals : Locals) : Option ApplicationScan :=
  some (validate calls (source locals) (locals .appScan "result"))

local macro "reduce_if_ending" : tactic => `(tactic|
  (dsimp only [ifEnding, Statements.Command.list, List.foldr, Statements.Command.eval, Statements.Primitive.eval,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, text, context, result, scan,
    position, facts, yes, input, nonzero, keyword, token, callTail, zero, invalid, close, closeToken,
    functions, procedures, Locals.set, checkedResult, source, arms, closeIf, closeTokens, tail, atPosition, withFacts]
   simp_all))

theorem ifEnding_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (leave : Continuation) :
    ifEnding.eval (functions calls valid) (procedures calls) fuel locals (checkedResult calls) leave =
      some (closeIf calls (source locals) (arms locals)) := by
  let result := locals .appScan "result"
  let afterElse := calls.takeToken (locals .source "text") result.scan.position (.word "else")
  let alternate := tail calls (source locals) (source locals).context (atPosition result afterElse) .endOnly
  by_cases absent : afterElse = 0
  · by_cases rejected : result.scan.position = 0
    all_goals dsimp [afterElse, result] at absent rejected
    all_goals reduce_if_ending
  · by_cases rejected : alternate.scan.position = 0
    all_goals dsimp [alternate, afterElse, result, source, tail, atPosition] at absent rejected
    all_goals reduce_if_ending

private theorem eval_loop_sequence (setup iteration ending : C) (calls : Statement.Calls)
    (valid : ValidFlow) (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [setup, .loopBody iteration, ending]).eval
      (functions calls valid) (procedures calls) fuel locals next leave =
    setup.eval (functions calls valid) (procedures calls) fuel locals
      (fun current => Statements.loop (fun _ => true) (fun c k e =>
        iteration.eval (functions calls valid) (procedures calls) fuel c k e)
        (fun c => ending.eval (functions calls valid) (procedures calls) fuel c next leave) fuel current) leave := rfl

def ifEntry (calls : Statement.Calls) (locals : Locals) : Locals :=
  let value := locals .appScan "result"
  locals.set .appScan "result" (atPosition value (calls.takeToken (locals .source "text") value.scan.position (.word "if")))

theorem ifCommands_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (leave : Continuation) :
    ifCommands.eval (functions calls valid) (procedures calls) fuel locals (checkedResult calls) leave =
    (armsFuel (armStep calls (source locals)) fuel (arms (ifEntry calls locals))).map
      (fun outcome => match outcome with
        | none => invalidApplication (source locals).input
        | some state => closeIf calls (source locals) state) := by
  rw [ifCommands, eval_loop_sequence]
  have ending := funext (fun current => ifEnding_meaning calls valid fuel current leave)
  rw [ending]
  have start (next : Continuation) :
      (Statements.Command.assign position (keyword position.expression "if")).eval
        (functions calls valid) (procedures calls) fuel locals next leave = next (ifEntry calls locals) := rfl
  rw [start, armLoop_meaning calls valid fuel fuel (ifEntry calls locals)
    (fun s state => some (closeIf calls s state))]
  have unchanged : source (ifEntry calls locals) = source locals := by simp [source, ifEntry, Locals.set]
  rw [unchanged]
  cases armsFuel (armStep calls (source locals)) fuel (arms (ifEntry calls locals)) with
  | none => rfl
  | some result => cases result <;> rfl

end Silver.ApplicationPackageBodies.Statement.Native
