module

public import Silver.ApplicationPackageCallsEntryPhase
public import Silver.ApplicationPackageCallsSource

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

private def commandList : C → List C
  | .nothing => []
  | .sequence first rest => commandList first ++ commandList rest
  | command => [command]

private theorem list_append_eval (calls : ApplicationPackageCalls.Calls) (first rest : List C)
    (locals : Locals) (next : Locals → ApplicationPackages.ApplicationCall) :
    (Command.list (first ++ rest)).eval (resultType := .appCall) (imported calls) locals next =
      (Command.list first).eval (resultType := .appCall) (imported calls) locals
        (fun current => (Command.list rest).eval (resultType := .appCall) (imported calls) current next) := by
  induction first generalizing locals with
  | nil => rfl
  | cons command tail ih =>
    change command.eval (resultType := .appCall) (imported calls) locals (fun current =>
      (Command.list (tail ++ rest)).eval (resultType := .appCall) (imported calls) current next) = _
    exact congrArg (fun cont : Locals → ApplicationPackages.ApplicationCall =>
      command.eval (resultType := .appCall) (imported calls) locals cont) (funext fun current => ih current)

private theorem command_list_eval (calls : ApplicationPackageCalls.Calls) (command : C) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    (Command.list (commandList command)).eval (resultType := .appCall) (imported calls) locals next =
      command.eval (resultType := .appCall) (imported calls) locals next := by
  induction command generalizing locals next with
  | sequence first rest ihFirst ihRest =>
    simp only [commandList, list_append_eval, ihFirst, ihRest, Command.eval]
  | _ => rfl

/-- Regroup the concrete source command list along the checked phase boundaries.
The command list retains each conditional and loop as a single command. -/
private theorem command_phases (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    callCommands.eval (resultType := .appCall) (imported calls) locals next =
      entryCommands.eval (resultType := .appCall) (imported calls) locals (fun start =>
        (readCommands actualScan).eval (resultType := .appCall) (imported calls) start (fun parsed =>
          afterActualCommands.eval (resultType := .appCall) (imported calls) parsed next)) := by
  let grouped : C := .list [entryCommands, readCommands actualScan, afterActualCommands]
  have same : commandList callCommands = commandList grouped := rfl
  have phases (first second third : C) :
      (Command.list [first, second, third]).eval (resultType := .appCall) (imported calls) locals next =
        first.eval (resultType := .appCall) (imported calls) locals (fun start => second.eval (resultType := .appCall) (imported calls) start
          (fun parsed => third.eval (resultType := .appCall) (imported calls) parsed next)) := rfl
  calc
    _ = (Command.list (commandList callCommands)).eval (resultType := .appCall) (imported calls) locals next :=
      (command_list_eval calls callCommands locals next).symm
    _ = (Command.list (commandList grouped)).eval (resultType := .appCall) (imported calls) locals next :=
      congrArg (fun parts : List C => (Command.list parts).eval (resultType := .appCall) (imported calls) locals next) same
    _ = grouped.eval (resultType := .appCall) (imported calls) locals next := command_list_eval calls grouped locals next
    _ = _ := phases _ _ _

private def fromActuals (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs) :
    Option ActualFrame → ApplicationPackages.ApplicationCall
  | none => inputs.failure
  | some frame => afterActuals calls (withActualFrame inputs frame) frame

private theorem read_and_finish (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall)
    (window : 0 < (aliasInputs locals).item.count →
      ActualWindow (aliasInputs locals).item (frameOf locals).actuals.length) :
    (readCommands actualScan).eval (resultType := .appCall) (imported calls) locals
      (fun parsed => afterActualCommands.eval (resultType := .appCall) (imported calls) parsed next) =
      fromActuals calls (aliasInputs locals) (gatheredActuals calls (aliasInputs locals) (frameOf locals)) := by
  simp only [after_actual_commands]
  exact read_commands_denotation calls locals (afterActuals calls) window

private theorem read_from_declarations (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (item : PackageBindings.Routine) (next : Locals → ApplicationPackages.ApplicationCall)
    (capacity : (locals .metadata "info").parameters.length ≤ PackageBindings.maxFormals)
    (safe : ¬ InvalidWindow (locals .metadata "info") item) :
    (readCommands actualScan).eval (resultType := .appCall) (imported calls) (entered (declared calls locals) item)
      (fun parsed => afterActualCommands.eval (resultType := .appCall) (imported calls) parsed next) =
      fromActuals calls (initialInputs calls locals item)
        (readActuals calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
          (locals .metadata "info") item (calls.reference (locals .source "text") (locals .number "position")).after) := by
  obtain ⟨inputs, frame⟩ := entered_projections calls locals item
  have window : 0 < (aliasInputs (entered (declared calls locals) item)).item.count →
      ActualWindow (aliasInputs (entered (declared calls locals) item)).item
        (frameOf (entered (declared calls locals) item)).actuals.length := by
    rw [inputs, frame]
    intro positive
    change ActualWindow item (List.replicate PackageBindings.maxFormals ({} : ApplicationPackages.PackageActual)).length
    rw [List.length_replicate]
    exact actualWindow_of_guard positive capacity safe
  rw [read_and_finish calls _ next window, inputs, frame]
  exact congrArg (fromActuals calls (initialInputs calls locals item))
    (gathered_from_initial calls (initialInputs calls locals item) _)

private theorem parsed_result (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (callee : Nat) (parsed : Option ActualFrame) :
    (match (do
      let frame ← parsed
      let checked ← checkAliases calls inputs.text inputs.info inputs.item frame
      let result := finishCall calls inputs.text inputs.context inputs.info inputs.kind inputs.item frame checked
      if frame.cursor ≤ inputs.position ∨ calls.validBody inputs.text inputs.context result.result.scan = false
      then none else some (callee, inputs.item, frame, result)) with
    | none => inputs.failure | some (_, _, _, result) => result) = fromActuals calls inputs parsed := by
  cases parsed with
  | none => rfl
  | some frame =>
    change (match ((checkAliases calls inputs.text inputs.info inputs.item frame).bind _ :
        Option (Nat × PackageBindings.Routine × ActualFrame × ApplicationPackages.ApplicationCall)) with
      | none => inputs.failure | some (_, _, _, value) => value) =
      (match checkAliases calls inputs.text inputs.info inputs.item frame with
      | none => inputs.failure | some checked => finishValue calls (withActualFrame inputs frame) checked)
    cases aliases : checkAliases calls inputs.text inputs.info inputs.item frame with
    | none => rfl
    | some checked =>
      dsimp only [Option.bind_some]
      rw [finishValue_model]
      by_cases rejected : frame.cursor ≤ inputs.position ∨
          calls.validBody inputs.text inputs.context
            (finishCall calls inputs.text inputs.context inputs.info inputs.kind inputs.item frame checked).result.scan = false
      · simp only [ite_eq_left rejected]
      · simp only [ite_eq_right rejected]

private theorem model_phases (calls : ApplicationPackageCalls.Calls) (locals : Locals) :
    let text := locals .source "text"
    let context := locals .parseContext "context"
    let input := locals .appScan "input"
    let info := locals .metadata "info"
    let position := locals .number "position"
    let kind := locals .routineKind "kind"
    let callee := packageCallee calls text context info position kind
    let item := info.routineAt callee
    packageCallAt calls text context input info position kind =
      if callee = 0 then ApplicationPackageCalls.failure input else
      if InvalidWindow info item then ApplicationPackageCalls.failure input else
        fromActuals calls (initialInputs calls locals item)
          (readActuals calls text context input info item (calls.reference text position).after) := by
  dsimp only
  unfold packageCallAt callStages
  generalize packageCallee calls (locals .source "text") (locals .parseContext "context")
    (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") = callee
  by_cases absent : callee = 0
  · simp only [absent, ↓reduceIte]
  · simp only [absent, ↓reduceIte]
    generalize (locals .metadata "info").routineAt callee = item
    by_cases invalid : InvalidWindow (locals .metadata "info") item
    · simp only [InvalidWindow] at invalid
      simp only [InvalidWindow, invalid, and_self, ↓reduceIte]
    · have guard := invalid
      unfold InvalidWindow at guard
      simp only [InvalidWindow, guard, ↓reduceIte]
      exact parsed_result calls (initialInputs calls locals item) callee _

/-- The whole typed Package_Call_At body implements the call model for every
scratch store and every physically representable parameter count. -/
theorem call_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (capacity : (locals .metadata "info").parameters.length ≤ PackageBindings.maxFormals) :
    callBody.eval (resultType := .appCall) (imported calls) locals =
      packageCallAt calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
        (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") := by
  obtain ⟨callee, failed, _, _, _, _, _⟩ := declared_values calls locals
  obtain ⟨_, _, _, info, _, _⟩ := declared_inputs calls locals
  change callCommands.eval (resultType := .appCall) (imported calls) (declared calls locals) (fun _ => Ty.appCall.default) = _
  rw [command_phases, entry_commands_denotation, callee, failed, info, model_phases]
  by_cases absent : packageCallee calls (locals .source "text") (locals .parseContext "context")
      (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") = 0
  · simp only [absent, ↓reduceIte]
  · simp only [absent, ↓reduceIte]
    split
    · rfl
    · exact read_from_declarations calls locals _ _ capacity (by assumption)

theorem SourceChecks.Checked.meaning {tokens : List String} (checked : SourceChecks.Checked tokens)
    (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (capacity : (locals .metadata "info").parameters.length ≤ PackageBindings.maxFormals) :
    SourceBridge.functionHeader "package_call_at" "is" tokens = some SourceChecks.header ∧
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "package_call_at" tokens =
      some (callBody.render functionNames) ∧
    callBody.eval (resultType := .appCall) (imported calls) locals =
      packageCallAt calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
        (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") :=
  ⟨checked.completeHeader, checked.completeBody, call_denotation calls locals capacity⟩

end Silver.ApplicationPackageCalls.Native.Call
