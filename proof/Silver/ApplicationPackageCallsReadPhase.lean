module

public import Silver.ApplicationPackageCallsAfterActuals
public import Silver.ApplicationPackageCallsActualOrder

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

/-- The enclosing branch in Package_Call_At includes the opening delimiter,
its failure return and every actual command. -/
def readCommands (body : C) : C := .choose (.gt count (.number 0))
  (.list [.assign (.variable "cursor_at") (call3 .take text cursor (.token (.symbol "("))),
    .choose (.eq cursor (.number 0)) returnFailure .nothing, body]) .nothing

private theorem eval_read_commands (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (body : C) (next : Locals → ApplicationPackages.ApplicationCall) :
    (readCommands body).eval (resultType := .appCall) (imported calls) locals next =
      if 0 < (locals .routine "item").count then
        let opened := calls.take (locals .source "text") (locals .number "cursor_at") (.symbol "(")
        if opened = 0 then locals .appCall "failure"
        else body.eval (resultType := .appCall) (imported calls) (locals.set .number "cursor_at" opened) next
      else next locals := by
  dsimp only [readCommands, Command.eval, Command.list, List.foldr, Expr.eval, Place.set, Field.get,
    call1, call2, call3, imported, text, cursor, count, item, returnFailure, failure]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, decide_eq_true_eq]
  apply ite_cond_congr
  apply propext
  exact ⟨fun h => of_decide_eq_true h, fun h => decide_eq_true h⟩

private theorem inputs_cursor (locals : Locals) (value : Nat) :
    aliasInputs (locals.set .number "cursor_at" value) = {aliasInputs locals with cursor := value} := by
  simp [aliasInputs, Locals.set]

private theorem frame_cursor (locals : Locals) (value : Nat) :
    frameOf (locals.set .number "cursor_at" value) = {frameOf locals with cursor := value} := by
  simp [frameOf, Locals.set]

def gatheredActuals (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (initial : ActualFrame) : Option ActualFrame :=
  if inputs.item.count = 0 then some initial else
    let opened := calls.take inputs.text initial.cursor (.symbol "(")
    if opened = 0 then none else
      (List.range inputs.item.count).foldlM
        (fun frame index => stepFromInputs calls inputs frame (index + 1)) {initial with cursor := opened}

theorem gathered_from_initial (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs) (afterName : Nat) :
    gatheredActuals calls inputs (initialActualFrame inputs.input inputs.item afterName) =
      readActuals calls inputs.text inputs.context inputs.input inputs.info inputs.item afterName := rfl

theorem read_commands_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ActualFrame → ApplicationPackages.ApplicationCall)
    (window : 0 < (aliasInputs locals).item.count → ActualWindow (aliasInputs locals).item (frameOf locals).actuals.length) :
    (readCommands actualScan).eval (resultType := .appCall) (imported calls) locals
        (fun current => next (aliasInputs current) (frameOf current)) =
      match gatheredActuals calls (aliasInputs locals) (frameOf locals) with
      | none => (aliasInputs locals).failure
      | some parsed => next (withActualFrame (aliasInputs locals) parsed) parsed := by
  let opened := calls.take (locals .source "text") (locals .number "cursor_at") (.symbol "(")
  let updated := locals.set .number "cursor_at" opened
  have changedInputs := inputs_cursor locals opened
  have changedFrame := frame_cursor locals opened
  have cursorEq : (frameOf locals).cursor = locals .number "cursor_at" := rfl
  have textEq : (aliasInputs locals).text = locals .source "text" := rfl
  have countEq : (aliasInputs locals).item.count = (locals .routine "item").count := rfl
  rw [eval_read_commands]
  by_cases empty : (locals .routine "item").count = 0
  · unfold gatheredActuals
    simp only [countEq, empty, Nat.lt_irrefl, ↓reduceIte]
    rfl
  · have positive := Nat.pos_of_ne_zero empty
    have positiveUpdated : 0 < (aliasInputs updated).item.count := by rw [changedInputs]; exact positive
    have windowUpdated : ActualWindow (aliasInputs updated).item (frameOf updated).actuals.length := by
      rw [changedInputs, changedFrame]
      exact window positive
    have scan := actual_scan_model calls updated next positiveUpdated windowUpdated
    simp only [positive, ↓reduceIte]
    by_cases missing : opened = 0
    · unfold gatheredActuals
      simp only [countEq, empty, ↓reduceIte, cursorEq, textEq, show calls.take (locals .source "text")
        (locals .number "cursor_at") (.symbol "(") = opened from rfl, missing, ↓reduceIte]
      rfl
    · change (if opened = 0 then _ else (actualScan.eval (resultType := .appCall) (imported calls) updated
        (fun current => next (aliasInputs current) (frameOf current)))) = _
      rw [ite_eq_right missing, scan]
      unfold gatheredActuals
      change (match ((List.range (aliasInputs updated).item.count).map (1 + ·)).foldlM
          (stepFromInputs calls (aliasInputs updated)) (frameOf updated) with
        | none => (aliasInputs updated).failure | some parsed => next (withActualFrame (aliasInputs updated) parsed) parsed) =
        (match (if (locals .routine "item").count = 0 then _ else if opened = 0 then _ else _) with
        | none => (aliasInputs locals).failure | some parsed => next (withActualFrame (aliasInputs locals) parsed) parsed)
      rw [ite_eq_right empty, ite_eq_right missing, changedInputs, changedFrame, List.foldlM_map]
      simp only [Nat.add_comm 1]
      rfl

end Silver.ApplicationPackageCalls.Native.Call
