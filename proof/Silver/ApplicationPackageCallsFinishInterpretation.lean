module

public import Silver.ApplicationPackageCallsResetInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

def completedResult (inputs : AliasInputs) (value : ApplicationPackages.ApplicationCall) :
    ApplicationPackages.ApplicationCall :=
  let scan := {value.result.scan with position := inputs.cursor}
  let scan := if inputs.kind = .procedure then {scan with assigned := true} else scan
  {value with
    value := ⟨inputs.cursor, inputs.item.resultKind, inputs.item.resultBounds⟩
    result := {value.result with scan := scan}}

def returnedCall (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (value : ApplicationPackages.ApplicationCall) : ApplicationPackages.ApplicationCall :=
  let result := completedResult inputs value
  if inputs.cursor ≤ inputs.position ∨
      calls.validBody inputs.text inputs.context result.result.scan = false
  then inputs.failure else result

def callReturnCommands : C := .list [
  .assign (.field .scanPosition scan) cursor,
  .choose (.routineEq kind (.routineKind .procedure))
    (.assign (.field .scanAssigned scan) (.truth true)) .nothing,
  .assign (.field .callValue result) (.callValueAggregate cursor
    (.field .routineResultKind item) (.field .routineResultBounds item)),
  .choose (.orElse (.le cursor position) (.not (call3 .validBody text context scan.expression)))
    returnFailure .nothing,
  .returned result.expression]

theorem call_return_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    callReturnCommands.eval (resultType := .appCall) (imported calls) locals next =
      returnedCall calls (aliasInputs locals) (locals .appCall "result") := by
  dsimp only [callReturnCommands, Command.list, List.foldr, Command.eval, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, call1, call2, call3, imported, text, context, kind, item, position,
    result, output, scan, cursor, returnFailure, failure, returnedCall, completedResult, aliasInputs]
  by_cases proc : locals .routineKind "kind" = .procedure <;>
    simp (disch := decide) [proc, Locals.set_get_same]

def unionCallEffects (inputs : AliasInputs) (value : ApplicationPackages.ApplicationCall) :
    ApplicationPackages.ApplicationCall :=
  {value with result := {value.result with
    reads := PackageBindings.stateUnion value.result.reads inputs.item.mayRead,
    writes := PackageBindings.stateUnion value.result.writes inputs.callWrites}}

def callEffectCommands : C := .list [
  .assign (.field .applicationReads output) (call2 .union
    (.field .applicationReads output.expression) (.field .routineMayRead item)),
  .assign (.field .applicationWrites output) (call2 .union
    (.field .applicationWrites output.expression) callWrites.expression)]

theorem call_effects_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall) :
    callEffectCommands.eval (resultType := .appCall) (imported calls) locals
        (fun current => next (aliasInputs current) (current .appCall "result")) =
      next (aliasInputs locals) (unionCallEffects (aliasInputs locals) (locals .appCall "result")) := by
  dsimp only [callEffectCommands, Command.list, List.foldr, Command.eval, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, call1, call2, imported, item, result, output, callWrites,
    unionCallEffects, aliasInputs]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other]

def finishCommands : C := .list [callEffectCommands, resetScan, callReturnCommands]

private theorem eval_finish_sequence (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) (effects resets finish : C) :
    (Command.list [effects, resets, finish]).eval (resultType := .appCall) (imported calls) locals next =
      effects.eval (resultType := .appCall) (imported calls) locals
        (fun current => resets.eval (resultType := .appCall) (imported calls) current
          (fun updated => finish.eval (resultType := .appCall) (imported calls) updated next)) := rfl

theorem finish_commands_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    finishCommands.eval (resultType := .appCall) (imported calls) locals next =
      let inputs := aliasInputs locals
      returnedCall calls inputs ((List.range inputs.info.states.length).foldl
        (fun result offset => resetStepInputs calls inputs result (offset + 1))
        (unionCallEffects inputs (locals .appCall "result"))) := by
  let afterEffects (inputs : AliasInputs) (value : ApplicationPackages.ApplicationCall) :=
    returnedCall calls inputs ((List.range inputs.info.states.length).foldl
      (fun result offset => resetStepInputs calls inputs result (offset + 1)) value)
  have resets (current : Locals) :
      resetScan.eval (resultType := .appCall) (imported calls) current
        (fun updated => returnedCall calls (aliasInputs updated) (updated .appCall "result")) =
        afterEffects (aliasInputs current) (current .appCall "result") :=
    reset_scan_denotation calls current (returnedCall calls)
  rw [finishCommands, eval_finish_sequence]
  simp only [call_return_denotation, resets]
  exact call_effects_denotation calls locals afterEffects

end Silver.ApplicationPackageCalls.Native.Call
