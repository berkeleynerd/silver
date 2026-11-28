module

public import Silver.ApplicationPackageCompletionRead

@[expose] public section

/-! Signature updates survive every subsequent returning failure. Prefix
execution reads no caller-supplied semantic certificate. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def prefixStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let text := locals .source "text"
  let globals := locals .state "globals"
  let before := locals .metadata "info"
  if before.completed ≥ before.routines.length then failed locals
  else
    let index := before.completed + 1
    let signature := calls.signatureAt text globals before true
    let info := signature.info
    let updated := ((locals.set .number "index" index).set .metadata "info" info).set .state "header" signature.header
    if signature.header.position = 0 then failed updated
    else
      let item := info.routineAt index
      let updated := updated.set .routine "item" item
      if formalRangeRejected info item then failed updated
      else
        let frame := calls.routineFrame text globals info index signature.header.position
        let updated := updated.set .state "frame" frame
        if frame.position = 0 then failed updated else ⟨updated, false⟩

local macro "reduce_completion_prefix" : tactic => `(tactic|
  (dsimp only [prefixCommands, prefixStep, fail, failed, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Primitive.eval,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get,
    modelFunctions, modelProcedures, Locals.set, text, globals, info, item, frame, position,
    formalFirst, formalCount, formalRangeRejected]
   simp_all [-Nat.not_le, -Nat.not_lt, -not_and, -not_or, formalRangeRejected, or_assoc]))

theorem prefixCommands_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    prefixCommands.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some (prefixStep calls locals) := by
  by_cases completed : (locals .metadata "info").completed ≥ (locals .metadata "info").routines.length
  · reduce_completion_prefix
  · let signature := calls.signatureAt (locals .source "text") (locals .state "globals") (locals .metadata "info") true
    by_cases missing : signature.header.position = 0
    · dsimp only [signature] at *
      reduce_completion_prefix
    · let item := signature.info.routineAt ((locals .metadata "info").completed + 1)
      by_cases formalRange : formalRangeRejected signature.info item = true
      · dsimp only [signature, item] at *
        reduce_completion_prefix
      · by_cases frameMissing : (calls.routineFrame (locals .source "text") (locals .state "globals") signature.info
          ((locals .metadata "info").completed + 1) signature.header.position).position = 0
        · dsimp only [signature, item] at *
          reduce_completion_prefix
        · dsimp only [signature, item] at *
          reduce_completion_prefix

end Silver.ApplicationPackageCompletion.Native
