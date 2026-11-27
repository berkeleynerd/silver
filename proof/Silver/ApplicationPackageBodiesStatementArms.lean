module

public import Silver.ApplicationPackageBodiesStatementNative

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 12000
set_option maxHeartbeats 1600000

def source (locals : Locals) : Input := ⟨locals .source "text", locals .parseContext "context", locals .appScan "input",
  locals .metadata "info", locals .functions "catalog", locals .procedures "procedure_catalog"⟩

def arms (locals : Locals) : Arms := ⟨locals .appScan "result", locals .activeFlow "yes", locals .truth "have_yes"⟩

def read (locals : Locals) : ReadArm :=
  ⟨locals .appScan "result", locals .activeFlow "yes", locals .truth "have_yes",
    (locals .conditionResult "condition").whenFalse, locals .number "start"⟩

abbrev ArmContinuation := Input → Arms → Option ApplicationScan

def armOutcome (scope : Input) (action : ArmStep) (next leave : ArmContinuation) : Option ApplicationScan :=
  match action with
  | .failed => some (invalidApplication scope.input)
  | .finished state => leave scope state
  | .continued state => next scope state

def readOutcome (scope : Input) (action : Option ReadArm)
    (next : Input → ReadArm → Option ApplicationScan) : Option ApplicationScan :=
  match action with
  | none => some (invalidApplication scope.input)
  | some out => next scope out

local macro "reduce_arm_read" : tactic => `(tactic|
  (dsimp only [armRead, Statements.Command.list, List.foldr, Statements.Command.eval, Statements.Primitive.eval,
     Place.set, Place.expression, Expr.eval, Field.get, Field.set, Property.get,
     text, context, input, info, result, scan, position, facts, reads, start, condition, invalid,
     zero, token, keyword, addReads, readEffects, callTail, functions, procedures, Locals.set,
     readOutcome, readArm, conditionFor, thenInput, tail, withFacts, atPosition, source, arms, read]
   simp_all [-Nat.not_le, -Nat.not_lt, -ne_eq,
     conditionFor, thenInput, tail, withFacts, atPosition, source, arms]))

theorem armRead_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : Input → ReadArm → Option ApplicationScan) (leave : Continuation) :
    armRead.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (source current) (read current)) leave =
      readOutcome (source locals) (readArm calls (source locals) (arms locals)) next := by
  let parsed := conditionFor calls (source locals) (arms locals)
  let thenValue := thenInput calls (source locals) (arms locals) parsed
  let branch := tail calls (source locals) (source locals).context thenValue .arm
  by_cases failedCondition : parsed.after = 0
  · dsimp [parsed] at failedCondition
    reduce_arm_read
  · by_cases stalled : thenValue.scan.position ≤ (arms locals).value.scan.position
    · dsimp [parsed, thenValue] at failedCondition stalled
      reduce_arm_read
    · by_cases failedBranch : branch.scan.position = 0
      all_goals dsimp [branch, parsed, thenValue] at failedCondition stalled failedBranch
      all_goals reduce_arm_read

local macro "reduce_arm_exit" : tactic => `(tactic|
  (dsimp only [armExit, Statements.Command.list, List.foldr, Statements.Command.eval, Statements.Primitive.eval,
     Place.set, Place.expression, Expr.eval, Field.get, Field.set, Property.get, text, context,
     result, scan, position, facts, yes, condition, start, keyword, token, zero, invalid, input,
     functions, procedures, Locals.set, finishArm, withFacts, atPosition, arms, read, source, armOutcome]
   simp_all [-Nat.not_le, -Nat.not_lt]))

theorem armExit_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next leave : ArmContinuation) :
    armExit.eval (functions calls valid) (procedures calls) fuel locals
      (fun current => next (source current) (arms current)) (fun current => leave (source current) (arms current)) =
      armOutcome (source locals) (finishArm calls (source locals) (read locals)) next leave := by
  let following := calls.takeToken (locals .source "text") (locals .appScan "result").scan.position (.word "elsif")
  by_cases taken : locals .truth "have_yes" = true
  all_goals by_cases last : following = 0
  all_goals by_cases stuck : following ≤ locals .number "start"
  all_goals dsimp [following] at last stuck
  all_goals reduce_arm_exit

theorem sequence_eval (front back : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.sequence front back).eval (functions calls valid) (procedures calls) fuel locals next leave =
      front.eval (functions calls valid) (procedures calls) fuel locals
        (fun current => back.eval (functions calls valid) (procedures calls) fuel current next leave) leave := rfl

theorem armCommands_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next leave : ArmContinuation) :
    armCommands.eval (functions calls valid) (procedures calls) fuel locals
      (fun current => next (source current) (arms current)) (fun current => leave (source current) (arms current)) =
      armOutcome (source locals) (armStep calls (source locals) (arms locals)) next leave := by
  rw [armCommands, sequence_eval]
  have exitMeaning := funext (fun current => armExit_meaning calls valid fuel current next leave)
  rw [exitMeaning, armRead_meaning calls valid fuel locals
    (fun scope value => armOutcome scope (finishArm calls scope value) next leave)]
  unfold readOutcome armStep
  cases readArm calls (source locals) (arms locals) <;> rfl

def finishArms (scope : Input) (result : Option Arms) (leave : ArmContinuation) : Option ApplicationScan :=
  match result with
  | none => some (invalidApplication scope.input)
  | some state => leave scope state

theorem armLoop_meaning (calls : Statement.Calls) (valid : ValidFlow) (inner outer : Nat) (locals : Locals)
    (leave : ArmContinuation) :
    Statements.loop (fun _ => true) (fun current next exitLoop =>
      armCommands.eval (functions calls valid) (procedures calls) inner current next exitLoop)
      (fun current => leave (source current) (arms current)) outer locals =
      (armsFuel (armStep calls (source locals)) outer (arms locals)).bind (fun result => finishArms (source locals) result leave) := by
  induction outer generalizing locals with
  | zero => rfl
  | succ fuel ih =>
    simp only [Statements.loop, ↓reduceIte]
    have nextMeaning := funext ih
    rw [nextMeaning, armCommands_meaning calls valid inner locals
      (fun scope state => (armsFuel (armStep calls scope) fuel state).bind (fun result => finishArms scope result leave)) leave]
    rw [armsFuel]
    cases armStep calls (source locals) (arms locals) <;> rfl

end Silver.ApplicationPackageBodies.Statement.Native
