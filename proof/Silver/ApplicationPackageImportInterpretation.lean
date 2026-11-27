module

public import Silver.ApplicationPackageImportExecution

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def scanCommands : C := .sequence (.loopBody outerBody) tailCommands

theorem scan_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    scanCommands.eval calls.get fuel locals next leave =
      loopResult locals finishSource (Model.outerLoop calls (locals .source "text") fuel fuel (cursor locals)) := by
  change Control.loop (fun current cont exitLoop => outerBody.eval calls.get fuel current cont exitLoop)
    (fun current => tailCommands.eval calls.get fuel current next leave) fuel locals = _
  simp only [tail_meaning]
  exact outer_loop calls fuel fuel locals finishSource

def entryLocals (calls : Calls) (prior : Locals) (source : Source) : Locals :=
  let started := ((input prior source).set .source "text" (calls.normalize source)).set .number "position" 1
  started.set .nameSpan "candidate" {}

theorem entry_declarations (calls : Calls) (prior : Locals) (source : Source) :
    entry.foldl (Declaration.eval calls.get) (input prior source) = entryLocals calls prior source := by
  dsimp +instances only [entry, constant, localDeclaration, List.foldl, Declaration.eval, Declaration.names,
    Expr.eval, mainSource, Calls.get]
  simp [entryLocals, input, Locals.set]

theorem body_entry (calls : Calls) (fuel : Nat) (prior : Locals) (source : Source) :
    execute calls fuel prior source =
      if source.length = 0 ∨ Silver.maxSourceLength < source.length then some [] else
      scanCommands.eval calls.get fuel (entryLocals calls prior source)
        (fun _ => some []) (fun _ => none) := by
  change (if (decide (source.length = 0) || decide (source.length > Silver.maxSourceLength)) then some [] else
    scanCommands.eval calls.get fuel (entry.foldl (Declaration.eval calls.get) (input prior source))
      (fun _ => some []) (fun _ => none)) = _
  rw [entry_declarations]
  simp

/-- Complete typed-tree execution agrees with the direct scanner for every
fuel, input source and incoming store. Real-callee domains and sufficient fuel
are separate source-derived obligations, not assumptions hidden in this equality. -/
theorem execute_model (calls : Calls) (fuel : Nat) (prior : Locals) (source : Source) :
    execute calls fuel prior source = Model.imported calls fuel source := by
  rw [body_entry]
  by_cases invalid : source.length = 0 ∨ Silver.maxSourceLength < source.length
  · simp only [invalid, ↓reduceIte, Model.imported]
  · rw [ite_eq_right invalid, scan_meaning]
    simp only [Model.imported, invalid, ↓reduceIte]
    have sourceEq : entryLocals calls prior source .source "text" = calls.normalize source := by
      simp [entryLocals, Locals.set]
    have cursorEq : cursor (entryLocals calls prior source) = ⟨1, {}⟩ := by
      simp [cursor, entryLocals, Locals.set]
    rw [sourceEq, cursorEq]
    cases Model.outerLoop calls (calls.normalize source) fuel fuel ⟨1, {}⟩ with
    | none => rfl
    | some result =>
        cases result <;> simp [loopResult, finishSource, withCursor, entryLocals, Locals.set]

end Silver.ApplicationPackageImport.Native
