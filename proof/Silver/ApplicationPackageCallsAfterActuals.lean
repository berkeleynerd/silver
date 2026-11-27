module

public import Silver.ApplicationPackageCallsActualScan
public import Silver.ApplicationPackageCallsFinishInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

def guardAliases : C := .choose (.gt count (.number 0)) aliasScan .nothing

def finishValue (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (value : ApplicationPackages.ApplicationCall) : ApplicationPackages.ApplicationCall :=
  returnedCall calls inputs ((List.range inputs.info.states.length).foldl
    (fun result offset => resetStepInputs calls inputs result (offset + 1)) (unionCallEffects inputs value))

def afterActuals (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (frame : ActualFrame) : ApplicationPackages.ApplicationCall :=
  match checkAliases calls inputs.text inputs.info inputs.item frame with
  | none => inputs.failure
  | some checked => finishValue calls (withActualFrame inputs frame) checked

theorem finishValue_model (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (frame : ActualFrame) (checked : ApplicationPackages.ApplicationCall) :
    finishValue calls (withActualFrame inputs frame) checked =
      let result := finishCall calls inputs.text inputs.context inputs.info inputs.kind inputs.item frame checked
      if frame.cursor ≤ inputs.position ∨ calls.validBody inputs.text inputs.context result.result.scan = false
      then inputs.failure else result := rfl

theorem guard_aliases_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall) :
    guardAliases.eval (imported calls) locals (fun current => next (aliasInputs current) (current .appCall "result")) =
      match (formalSlots (locals .routine "item")).foldlM (aliasStepInputs calls (aliasInputs locals))
          (locals .appCall "result") with
      | none => (aliasInputs locals).failure
      | some value => next (aliasInputs locals) value := by
  change (if decide (0 < (locals .routine "item").count) then
    aliasScan.eval (imported calls) locals (fun current => next (aliasInputs current) (current .appCall "result"))
    else next (aliasInputs locals) (locals .appCall "result")) = _
  by_cases positive : 0 < (locals .routine "item").count
  · simp only [positive, decide_true, ↓reduceIte]
    exact alias_scan_denotation calls locals next positive
  · have zero := Nat.eq_zero_of_not_pos positive
    simp [formalSlots, zero]

def afterActualCommands : C := .list [guardAliases, finishCommands]

private theorem eval_two_commands (calls : ApplicationPackageCalls.Calls) (locals : Locals) (first second : C)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    (Command.list [first, second]).eval (resultType := .appCall) (imported calls) locals next =
      first.eval (resultType := .appCall) (imported calls) locals
        (fun current => second.eval (resultType := .appCall) (imported calls) current next) := rfl

private theorem withActualFrame_locals (locals : Locals) :
    withActualFrame (aliasInputs locals) (frameOf locals) = aliasInputs locals := rfl

theorem after_actual_commands (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    afterActualCommands.eval (resultType := .appCall) (imported calls) locals next = afterActuals calls (aliasInputs locals) (frameOf locals) := by
  have finish (current : Locals) : finishCommands.eval (resultType := .appCall) (imported calls) current next =
      finishValue calls (aliasInputs current) (current .appCall "result") := finish_commands_denotation calls current next
  rw [afterActualCommands, eval_two_commands]
  simp only [finish, afterActuals, withActualFrame_locals]
  exact guard_aliases_denotation calls locals (finishValue calls)

end Silver.ApplicationPackageCalls.Native.Call
