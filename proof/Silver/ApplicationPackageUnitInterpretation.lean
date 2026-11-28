module

public import Silver.ApplicationPackageUnitLoops

@[expose] public section

/-! Complete typed procedure execution, with independently checked finite
prefix/footer and loop equations. Intermediate stores remain opaque so the
composition does not expand every native table into a nested substitution. -/
namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def prefixStep (calls : UnitCalls) (locals : Locals) : Outcome :=
  let original := locals .metadata "info"
  let first := locals .number "first"
  let last := locals .number "last"
  let locals := locals.set .truth "accepted" false
  if !calls.sameName (locals .source "text") ⟨first, last⟩ ⟨original.nameFirst, original.nameAfter⟩ then
    ⟨locals, true⟩
  else
    let info := {original with bodyNameFirst := first, bodyNameAfter := last}
    let globals := {locals .state "globals" with
      position := calls.sparkPragmaAfter (locals .source "text")
        (calls.takeToken (locals .source "text") last (.word "is"))}
    let updated := (locals.set .metadata "info" info).set .state "globals" globals
    ⟨updated, decide (globals.position = 0)⟩

def footerStep (calls : UnitCalls) (locals : Locals) : Outcome :=
  let text := locals .source "text"
  let info := locals .metadata "info"
  let first := calls.skipAt text (calls.takeToken text (locals .state "globals").position (.word "end"))
  let last := calls.nameAfter text first
  let following := calls.takeToken text last (.symbol ";")
  let accepted := calls.sameName text ⟨first, last⟩ ⟨info.nameFirst, info.nameAfter⟩ &&
    decide (following ≠ 0) && decide (calls.skipAt text following = text.length + 1)
  ⟨(((locals.set .number "end_first" first).set .number "end_last" last).set
    .number "following" following).set .truth "accepted" accepted, false⟩

local macro "reduce_unit_prefix" : tactic => `(tactic|
  (dsimp only [prefixCommands, prefixStep, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Place.set, Place.expression,
    Expr.eval, modelFunctions, Field.get, Field.set, Locals.set, text, info, globals,
    same, position, token]
   simp_all))

theorem prefixCommands_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    prefixCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (prefixStep calls locals) := by
  cases named : calls.sameName (locals .source "text")
      ⟨locals .number "first", locals .number "last"⟩
      ⟨(locals .metadata "info").nameFirst, (locals .metadata "info").nameAfter⟩
  · reduce_unit_prefix
  · by_cases missing : calls.sparkPragmaAfter (locals .source "text")
        (calls.takeToken (locals .source "text") (locals .number "last") (.word "is")) = 0
    · reduce_unit_prefix
    · reduce_unit_prefix

theorem footerCommands_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    footerCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (footerStep calls locals) := by
  dsimp only [footerCommands, footerStep, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Place.set, Place.expression,
    Expr.eval, modelFunctions, Field.get, Field.set, Locals.set, text, info, globals,
    same, position, token, skip, after]
  rfl

def executeCommands (calls : UnitCalls) (fuel : Nat) (locals : Locals) : Option Outcome :=
  (prefixStep calls locals).bind fun started =>
    (objectLoop calls fuel started).bind fun objects => objects.bind fun completedObjects =>
      (routineLoop calls fuel completedObjects).bind fun routines => routines.bind fun completedRoutines =>
        some (footerStep calls completedRoutines)

theorem commands_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    commands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      executeCommands calls fuel locals := by
  change (prefixCommands.eval _ _ _ locals).bind (fun result => result.bind (fun started =>
    ((ApplicationPackageProcedure.Command.whileLoop objectLoopTest objectLoopBody).eval _ _ _ started).bind
      (fun result => result.bind (fun objects =>
        ((ApplicationPackageProcedure.Command.whileLoop
          (.lt (.field .infoCompleted info) (.field .routineCount info)) routineLoopBody).eval _ _ _ objects).bind
          (fun result => result.bind (footerCommands.eval _ _ _)))))) = _
  have footer : footerCommands.eval (modelFunctions calls) (modelProcedures calls) fuel =
      (fun locals => some (footerStep calls locals)) := funext (footerCommands_meaning calls fuel)
  rw [footer]
  simp only [prefixCommands_meaning, objectLoop_meaning, routineLoop_meaning,
    Option.bind_some, executeCommands]

def initializedLocals (calls : UnitCalls) (locals : Locals) : Locals :=
  declarations.foldl (Declaration.eval (modelFunctions calls)) locals

def execute (calls : UnitCalls) (fuel : Nat) (locals : Locals) : Option Locals :=
  (executeCommands calls fuel (initializedLocals calls locals)).map Outcome.locals

theorem body_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    body.eval (modelFunctions calls) (modelProcedures calls) fuel locals = execute calls fuel locals := by
  change (commands.eval _ _ _ (initializedLocals calls locals)).map Outcome.locals = _
  rw [commands_meaning]
  rfl

end Silver.ApplicationPackageUnit.Native
