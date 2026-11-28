module

public import Silver.ApplicationPackageCompletionPrefix

@[expose] public section

/-! Exact end-of-completion command equations. Routine/effect metadata is
committed only after the original body and named footer both succeed. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies ApplicationPackages

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def dispatchInput (locals : Locals) : ApplicationScan :=
  {locals .appScan "input" with
    allowProcedureCalls := decide ((locals .routine "item").kind = .procedure)
    reads := locals .stateSet "reads"}

def dispatched (calls : CompletionCalls) (locals : Locals) : ApplicationScan :=
  calls.applicationTail (locals .source "text") (locals .parseContext "context") (dispatchInput locals)
    (locals .metadata "info") (if (locals .routine "item").kind = .function then .returnOnly else .endOnly)
    (decide ((locals .routine "item").kind = .procedure) && !(locals .truth "initialized")) {} {}

def dispatchStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let result := dispatched calls locals
  let updated := (locals.set .appScan "input" (dispatchInput locals)).set .appScan "result" result
  if result.scan.position = 0 then failed updated else ⟨updated, false⟩

def returnedAfter (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.functionReturnAfter (locals .source "text") (locals .parseContext "context") (locals .appScan "result").scan
    ⟨0, (locals .routine "item").resultKind, (locals .routine "item").resultBounds, 0⟩

def returnedScan (calls : CompletionCalls) (locals : Locals) : ApplicationScan :=
  let result := locals .appScan "result"
  let text := locals .source "text"
  let first := calls.takeToken text result.scan.position (.word "return")
  let after := returnedAfter calls locals
  {result with
    reads := PackageBindings.stateUnion result.reads
      (calls.stateReads text (locals .parseContext "context") (locals .metadata "info") first after)
    scan := {result.scan with position := calls.takeToken text after (.symbol ";")}}

def returnStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  if (locals .routine "item").kind = .function then
    let first := calls.takeToken (locals .source "text") (locals .appScan "result").scan.position (.word "return")
    let result := returnedScan calls locals
    let updated := ((locals.set .number "value_first" first).set .number "value_after"
      (returnedAfter calls locals)).set .appScan "result" result
    if result.scan.position = 0 ∨ result.writes ≠ PackageBindings.emptyStateSet then failed updated
    else ⟨updated, false⟩
  else ⟨locals, false⟩

def footerFirst (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.skipAt (locals .source "text")
    (calls.takeToken (locals .source "text") (locals .appScan "result").scan.position (.word "end"))

def footerLast (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.nameAfter (locals .source "text") (footerFirst calls locals)

def footerFollowing (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.takeToken (locals .source "text") (footerLast calls locals) (.symbol ";")

def footerStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let first := footerFirst calls locals
  let last := footerLast calls locals
  let following := footerFollowing calls locals
  let updated := ((locals.set .number "first" first).set .number "last" last).set .number "following" following
  if following ≤ locals .number "original" ∨
      calls.sameName (locals .source "text") ⟨first, last⟩ (locals .routine "item").bodyName ≠ true then failed updated
  else
    let result := locals .appScan "result"
    let item := {locals .routine "item" with
      bodyAfter := following, mayRead := result.reads, mayWrite := result.writes, assigned := result.scan.assigned}
    let info := locals .metadata "info"
    let index := locals .number "index"
    let info := {info with
      routines := info.routines.set (index - 1) item, completed := index, assigned := info.assigned || item.assigned}
    ⟨((updated.set .routine "item" item).set .metadata "info" info).set
      .state "globals" {locals .state "globals" with position := following}, false⟩

local macro "reduce_completion_body" : tactic => `(tactic|
  (dsimp only [dispatchCommands, returnCommands, footerCommands, dispatchStep, dispatchInput, dispatched,
    returnStep, returnedScan, returnedAfter, footerStep, footerFirst, footerLast, footerFollowing,
    fail, failed, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get, Index.set,
    modelFunctions, Locals.set, text, globals, info, item, frame, position, result, input, context,
    functionRoutine, procedureRoutine, token, skip, after, same, union, reads]
   simp_all [-Nat.not_le, -Nat.not_lt, -not_and, -not_or,
     dispatched, dispatchInput, returnedAfter, returnedScan, footerFirst, footerLast, footerFollowing]))

theorem dispatchCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    dispatchCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (dispatchStep calls locals) := by
  cases kind : (locals .routine "item").kind
  all_goals
    by_cases missing : (dispatched calls locals).scan.position = 0
    · reduce_completion_body
    · reduce_completion_body

theorem returnCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    returnCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (returnStep calls locals) := by
  cases kind : (locals .routine "item").kind
  · by_cases rejected : (returnedScan calls locals).scan.position = 0 ∨
        (returnedScan calls locals).writes ≠ PackageBindings.emptyStateSet
    · reduce_completion_body
    · reduce_completion_body
  · reduce_completion_body

theorem footerCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    footerCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (footerStep calls locals) := by
  by_cases rejected : footerFollowing calls locals ≤ locals .number "original" ∨
      calls.sameName (locals .source "text") ⟨footerFirst calls locals, footerLast calls locals⟩
        (locals .routine "item").bodyName ≠ true
  · reduce_completion_body
  · reduce_completion_body

end Silver.ApplicationPackageCompletion.Native
