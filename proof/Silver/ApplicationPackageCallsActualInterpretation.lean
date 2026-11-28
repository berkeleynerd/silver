module

public import Silver.ApplicationPackageCallsAliasInterpretation

@[expose] public section

/-! Source-ordered actual association and payload execution. Every equation
retains arbitrary incoming scratch storage and early-return behavior. -/
namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def associationLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Option Locals :=
  let text := locals .source "text"
  let first := calls.skip text (locals .number "cursor_at")
  let last := calls.nameAfter text first
  let arrow := calls.take text last (.symbol "=>")
  let updated := (((locals.set .number "first" first).set .number "last" last).set
    .number "arrow_end" arrow).set .number "slot" 0
  if arrow ≠ 0 then
    let selected := (namedRange (locals .routine "item")).foldl
      (fun previous index => namedStep calls (text, locals .metadata "info", first, last) index previous) 0
    some (((updated.set .truth "named" true).set .number "slot" selected).set .number "cursor_at" arrow)
  else if locals .truth "named" then none
  else some (updated.set .number "slot"
    ((locals .routine "item").formalFirst + locals .number "ordinal" - 1))

theorem association_body_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    associationCommands.eval (resultType := .appCall) (imported calls) locals next =
      match associationLocals calls locals with
      | none => locals .appCall "failure" | some updated => next updated := by
  unfold associationCommands
  generalize namedEq : namedScan = namedCommand
  have namedRule (current : Locals) (continuation : Locals → ApplicationPackages.ApplicationCall) :
      namedCommand.eval (resultType := .appCall) (imported calls) current continuation =
        continuation (current.set .number "slot"
          ((namedRange (current .routine "item")).foldl
            (fun previous index => namedStep calls (namedParameters current) index previous)
            (current .number "slot"))) := by
    rw [← namedEq]
    exact named_scan_denotation calls current continuation
  dsimp only [Command.list, List.foldr, Command.eval, Place.set, Expr.eval,
    imported, call3, call2, call1, text, cursor, first, last, arrow, named,
    returnFailure, failure, formalFirst, item, ordinal, Field.get]
  simp only [namedRule]
  dsimp only [associationLocals]
  simp (disch := decide) only [namedParameters, Locals.set_get_same, Locals.set_get_other,
    decide_eq_true_eq]
  split
  · rfl
  · split <;> rfl


def writeActual (locals : Locals) (slot : Nat)
    (update : ApplicationPackages.PackageActual → ApplicationPackages.PackageActual) : Locals :=
  let actuals := locals .packageActuals "actuals"
  locals.set .packageActuals "actuals" (actuals.set (slot - 1) (update (actuals.getD (slot - 1) {})))

def payloadLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Option Locals :=
  let slot := locals .number "slot"
  if slot = 0 ∨ (locals .packageSeen "seen").getD (slot - 1) false = true then none
  else
    let parameter := (locals .metadata "info").parameterAt slot
    let cursor := locals .number "cursor_at"
    let text := locals .source "text"
    let context := locals .parseContext "context"
    let input := locals .appScan "input"
    let updated := (locals.set .packageSeen "seen"
      ((locals .packageSeen "seen").set (slot - 1) true)).set .formal "parameter" parameter
    let updated := writeActual updated slot (fun actual => {actual with first := cursor})
    let updated := if parameter.mode = .input then
        updated.set .number "following"
          (calls.actualAfter text context cursor input.scan.facts (inputFormal parameter))
      else
        let legacy := outputFormal parameter
        let updated := updated.set .procedureFormal "legacy_parameter" legacy
        let target := calls.targetActual text context cursor input.scan.facts legacy
        let updated := writeActual updated slot (fun actual => {actual with target := target})
        let updated := updated.set .number "following"
          ((updated .packageActuals "actuals").getD (slot - 1) {}).target.after
        writeActual updated slot (fun actual => {actual with
          writtenState := calls.stateTarget text context (locals .metadata "info") cursor})
    if updated .number "following" ≤ cursor then none else some updated

theorem payload_body_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    payloadCommands.eval (resultType := .appCall) (imported calls) locals next =
      match payloadLocals calls locals with
      | none => locals .appCall "failure" | some updated => next updated := by
  dsimp only [payloadCommands, payloadLocals, writeActual, Command.list, List.foldr,
    Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get, Index.set,
    imported, call5, call4, call3, call2, call1, info, context, input, text, cursor,
    slot, actuals, actual, seen, parameter, legacy, formalInput, formalOutput, following,
    returnFailure, failure, inputFormal, outputFormal]
  simp (disch := decide) [*]
  repeat' (split <;> try simp (disch := decide) [*])
  all_goals rfl

def finishActualLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Option Locals :=
  let slot := locals .number "slot"
  let text := locals .source "text"
  let context := locals .parseContext "context"
  let info := locals .metadata "info"
  let cursor := locals .number "cursor_at"
  let following := locals .number "following"
  let updated := writeActual locals slot (fun actual => {actual with after := following})
  let updated := if (locals .formal "parameter").mode ≠ .output then
      writeActual updated slot (fun actual => {actual with
        reads := calls.stateReads text context info cursor following})
    else updated
  let actual := (updated .packageActuals "actuals").getD (slot - 1) {}
  let result := locals .appCall "result"
  let updated := updated.set .appCall "result"
    {result with result := {result.result with
      reads := PackageBindings.stateUnion result.result.reads actual.reads}}
  let updated := if actual.writtenState ≠ 0 then
      updated.set .stateSet "call_writes"
        ((locals .stateSet "call_writes").set (actual.writtenState - 1) true)
    else updated
  let finish := calls.take text following
    (if locals .number "ordinal" = (locals .routine "item").count then .symbol ")" else .symbol ",")
  let updated := updated.set .number "cursor_at" finish
  if finish = 0 then none else some updated

theorem finish_actual_body_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    finishActualCommands.eval (resultType := .appCall) (imported calls) locals next =
      match finishActualLocals calls locals with
      | none => locals .appCall "failure" | some updated => next updated := by
  dsimp only [finishActualCommands, finishActualLocals, writeActual, Command.list, List.foldr,
    Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get, Index.set,
    imported, call5, call4, call3, call2, call1, info, context, input, text, cursor,
    slot, actuals, actual, parameter, following, returnFailure, failure, result, output,
    callWrites, ordinal, count, item]
  simp (disch := decide) [*]
  repeat' (split <;> try simp (disch := decide) [*])
  all_goals rfl

theorem association_failure_preserved {calls : ApplicationPackageCalls.Calls} {locals updated : Locals}
    (accepted : associationLocals calls locals = some updated) :
    updated .appCall "failure" = locals .appCall "failure" := by
  dsimp only [associationLocals] at accepted
  split at accepted
  · cases accepted
    simp [Locals.set]
  · split at accepted
    · contradiction
    · cases accepted
      simp [Locals.set]

theorem payload_failure_preserved {calls : ApplicationPackageCalls.Calls} {locals updated : Locals}
    (accepted : payloadLocals calls locals = some updated) :
    updated .appCall "failure" = locals .appCall "failure" := by
  dsimp only [payloadLocals] at accepted
  split at accepted
  · contradiction
  · split at accepted
    · split at accepted
      · contradiction
      · cases accepted
        simp [writeActual, Locals.set]
    · split at accepted
      · contradiction
      · cases accepted
        simp [writeActual, Locals.set]

def actualLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Option Locals := do
  let associated ← associationLocals calls locals
  let payload ← payloadLocals calls associated
  finishActualLocals calls payload

private theorem eval_actual_sequence (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) (cursorBound storageBound : E .truth)
    (associate parse finish : C) :
    (Command.list [.invariant cursorBound, .invariant storageBound, associate, parse, finish]).eval
      (resultType := .appCall) (imported calls) locals next =
      associate.eval (resultType := .appCall) (imported calls) locals (fun selected =>
        parse.eval (resultType := .appCall) (imported calls) selected (fun loaded =>
          finish.eval (resultType := .appCall) (imported calls) loaded next)) := rfl

theorem actual_body_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    actualCommands.eval (resultType := .appCall) (imported calls) locals next =
      match actualLocals calls locals with
      | none => locals .appCall "failure" | some updated => next updated := by
  rw [actualCommands, eval_actual_sequence, association_body_denotation]
  cases association : associationLocals calls locals with
  | none => simp only [actualLocals, association, Option.bind_eq_bind, Option.bind_none]
  | some associated =>
      simp only
      rw [payload_body_denotation]
      cases payload : payloadLocals calls associated with
      | none =>
          simp only [actualLocals, association, payload, Option.bind_eq_bind, Option.bind_some,
            Option.bind_none, association_failure_preserved association]
      | some loaded =>
          simp only
          rw [finish_actual_body_denotation]
          cases finished : finishActualLocals calls loaded with
          | none =>
              simp only [actualLocals, association, payload, finished, Option.bind_eq_bind, Option.bind_some,
                payload_failure_preserved payload, association_failure_preserved association]
          | some complete =>
              simp only [actualLocals, association, payload, finished, Option.bind_eq_bind, Option.bind_some]

end Silver.ApplicationPackageCalls.Native.Call
