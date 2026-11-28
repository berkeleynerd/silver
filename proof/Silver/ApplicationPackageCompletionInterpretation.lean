module

public import Silver.ApplicationPackageCompletionBody

@[expose] public section

/-! Whole Completion execution composes the independently checked phase
equations, retaining the local while bound, exact ranges, all early returns and
scope restoration. The original callee contracts eliminate while exhaustion. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def localTest (calls : CompletionCalls) (locals : Locals) : Bool :=
  decide (calls.takeToken (locals .source "text") (locals .state "frame").position (.word "begin") = 0)

def localWhile (calls : CompletionCalls) (fuel : Nat) (locals : Locals) : Option Outcome :=
  whileLocals (localTest calls) (fun current => some (localStep calls current)) fuel locals

theorem localWhile_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    (ApplicationPackageProcedure.Command.whileLoop (.eq (token position (.word "begin")) (.number 0)) localLoop).eval
      (modelFunctions calls) (modelProcedures calls) fuel locals = localWhile calls fuel locals := by
  change whileLocals (fun current => localTest calls current)
    (localLoop.eval (modelFunctions calls) (modelProcedures calls) fuel) fuel locals = _
  rw [funext (localLoop_meaning calls fuel)]
  rfl

def rangeValues (locals : Locals) : List Nat :=
  let item := locals .routine "item"
  (List.range (item.formalFirst + item.count - 1 + 1 - item.formalFirst)).map (item.formalFirst + ·)

theorem rangeValues_eq (locals : Locals) (positive : 0 < (locals .routine "item").count) :
    rangeValues locals = formalIndices (locals .routine "item") := by
  simp only [rangeValues, formalIndices, formalRange _ _ positive]

def rangeStep (step : Locals → Outcome) (locals : Locals) : Option Outcome :=
  (forLocals (fun current => some (step current)) "i" (rangeValues locals) locals).map fun outcome =>
    outcome.restore (fun updated => updated.set .number "i" (locals .number "i"))

theorem outputReadRange_meaning (calls : CompletionCalls) (fuel : Nat) :
    (ApplicationPackageProcedure.Command.forRange "i" formalFirst formalLast outputRead).eval
      (modelFunctions calls) (modelProcedures calls) fuel = rangeStep (readStep calls) := by
  funext locals
  change (forLocals (outputRead.eval (modelFunctions calls) (modelProcedures calls) fuel)
    "i" (rangeValues locals) locals).map _ = _
  rw [funext (outputRead_meaning calls fuel)]
  rfl

theorem outputAppendRange_meaning (calls : CompletionCalls) (fuel : Nat) :
    (ApplicationPackageProcedure.Command.forRange "i" formalFirst formalLast outputAppend).eval
      (modelFunctions calls) (modelProcedures calls) fuel = rangeStep (appendStep calls) := by
  funext locals
  change (forLocals (outputAppend.eval (modelFunctions calls) (modelProcedures calls) fuel)
    "i" (rangeValues locals) locals).map _ = _
  rw [funext (outputAppend_meaning calls fuel)]
  rfl

def afterBegin (calls : CompletionCalls) (locals : Locals) : Locals :=
  locals.set .state "frame" {locals .state "frame" with
    position := calls.takeToken (locals .source "text") (locals .state "frame").position (.word "begin")}

def outputsStep (calls : CompletionCalls) (locals : Locals) : Option Outcome :=
  let updated := afterBegin calls locals
  if (locals .routine "item").count > 0 then
    (rangeStep (readStep calls) updated).bind fun result => result.bind (rangeStep (appendStep calls))
  else some ⟨updated, false⟩

theorem outputsCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    outputsCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals = outputsStep calls locals := by
  simp only [outputsCommands, ApplicationPackageProcedure.Command.list, List.foldr,
    eval_sequence, eval_assign, eval_choose, eval_nothing, outputReadRange_meaning, outputAppendRange_meaning,
    Outcome.bind_done, Option.bind_fun_some]
  dsimp only [Place.set, Place.expression, Expr.eval, Field.get, Field.set, modelFunctions,
    Locals.set, token, text, position, frame, formalCount, item]
  simp [outputsStep, afterBegin, Locals.set, Outcome.bind]

def bodyStep (calls : CompletionCalls) (locals : Locals) : Option Outcome :=
  (dispatchStep calls locals).bind fun started =>
    (returnStep calls started).bind fun returned => some (footerStep calls returned)

theorem bodyCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    bodyCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals = bodyStep calls locals := by
  have dispatch := funext (dispatchCommands_meaning calls fuel)
  have returns := funext (returnCommands_meaning calls fuel)
  have footer := funext (footerCommands_meaning calls fuel)
  simp only [bodyCommands, eval_sequence, dispatch, returns, footer, Option.bind_some, bodyStep]

def bodyBlockStep (calls : CompletionCalls) (locals : Locals) : Option Outcome :=
  (bodyStep calls (bodyDeclarations.foldl (Declaration.eval (modelFunctions calls)) locals)).map fun result =>
    result.restore (Declarations.restore bodyDeclarations locals)

theorem bodyBlock_meaning (calls : CompletionCalls) (fuel : Nat) :
    (ApplicationPackageProcedure.Command.block bodyDeclarations bodyCommands).eval
      (modelFunctions calls) (modelProcedures calls) fuel = bodyBlockStep calls := by
  funext locals
  change (bodyCommands.eval _ _ _ _).map _ = _
  rw [bodyCommands_meaning]
  rfl

def checkedBodyBlockStep (calls : CompletionCalls) (locals : Locals) : Option Outcome :=
  if calls.validState (locals .source "text") (locals .state "frame") then bodyBlockStep calls locals
  else some (failed locals)

theorem checkedBodyBlock_meaning (calls : CompletionCalls) (fuel : Nat) :
    checkedBodyBlock.eval (modelFunctions calls) (modelProcedures calls) fuel = checkedBodyBlockStep calls := by
  have rejected : fail.eval (modelFunctions calls) (modelProcedures calls) fuel = fun current => some (failed current) := rfl
  funext locals
  simp only [checkedBodyBlock, eval_sequence, eval_choose, eval_nothing, rejected, bodyBlock_meaning]
  dsimp only [validFrame, Expr.eval, text, frame, modelFunctions]
  cases accepted : calls.validState (locals .source "text") (locals .state "frame") <;>
    simp only [checkedBodyBlockStep, accepted, Bool.not_true, Bool.not_false, Bool.false_eq_true,
      ↓reduceIte, Option.bind_some, Outcome.bind, failed]

def executeCommands (calls : CompletionCalls) (fuel : Nat) (locals : Locals) : Option Outcome :=
  (prefixStep calls locals).bind fun started =>
    (localWhile calls fuel started).bind fun declared => declared.bind fun completedLocals =>
      (outputsStep calls completedLocals).bind fun outputs => outputs.bind (checkedBodyBlockStep calls)

theorem commands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    commands.eval (modelFunctions calls) (modelProcedures calls) fuel locals = executeCommands calls fuel locals := by
  have prefixEquation := funext (prefixCommands_meaning calls fuel)
  have localEquation := funext (localWhile_meaning calls fuel)
  have outputs := funext (outputsCommands_meaning calls fuel)
  simp only [commands, eval_sequence, prefixEquation, localEquation, outputs, checkedBodyBlock_meaning,
    Option.bind_some, executeCommands]

def initializedLocals (calls : CompletionCalls) (locals : Locals) : Locals :=
  declarations.foldl (Declaration.eval (modelFunctions calls)) locals

def execute (calls : CompletionCalls) (fuel : Nat) (locals : Locals) : Option Locals :=
  (executeCommands calls fuel (initializedLocals calls locals)).map Outcome.locals

theorem body_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    body.eval (modelFunctions calls) (modelProcedures calls) fuel locals = execute calls fuel locals := by
  change (commands.eval _ _ _ (initializedLocals calls locals)).map Outcome.locals = _
  rw [commands_meaning]
  rfl

end Silver.ApplicationPackageCompletion.Native
