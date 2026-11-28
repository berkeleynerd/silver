module

public import Silver.ApplicationPackageImportLoop

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def outerCommands : C := .list [
  .exitWhen (.andThen (.not withClause) (.not useClause)),
  .assign (.variable "position") after,
  .loopBody innerBody]

def outerLocals (calls : Calls) (locals : Locals) : Locals :=
  let first := calls.skip (locals .source "text") (locals .number "position")
  let after := calls.nameAfter (locals .source "text") first
  let withClause := first > 0 && after > first && calls.nameIs (locals .source "text") first after "with"
  let useClause := first > 0 && after > first && calls.nameIs (locals .source "text") first after "use"
  let named := (locals.set .number "first" first).set .number "after" after
  (named.set .truth "with_clause" withClause).set .truth "use_clause" useClause

theorem outer_declarations (calls : Calls) (locals : Locals) :
    outerDeclarations.foldl (Declaration.eval calls.get) locals = outerLocals calls locals := by
  dsimp +instances only [outerDeclarations, constant, List.foldl, Declaration.eval, Declaration.names,
    clause, Expr.eval, text, position, first, after, call2, call3, call4, Calls.get]
  simp [outerLocals, Locals.set]

def outerAction (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) : Option Source :=
  if !locals .truth "with_clause" && !locals .truth "use_clause" then leave locals
  else let updated := locals.set .number "position" (locals .number "after")
    loopResult updated next (Model.innerLoop calls (locals .source "text")
      (locals .truth "with_clause") fuel (cursor updated))

theorem outerCommands_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    outerCommands.eval calls.get fuel locals next leave = outerAction calls fuel locals next leave := by
  dsimp +instances only [outerCommands, Control.Command.list, List.foldr, Control.Command.eval,
    Expr.eval, withClause, useClause, after, Place.set, Place.expression]
  rw [inner_loop]
  simp [outerAction, Locals.set]

theorem outerBody_entry (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    outerBody.eval calls.get fuel locals next leave =
      outerCommands.eval calls.get fuel (outerDeclarations.foldl (Declaration.eval calls.get) locals)
        (fun updated => next (Declarations.restore outerDeclarations locals updated))
        (fun updated => leave (Declarations.restore outerDeclarations locals updated)) := rfl

theorem restore_outer_locals (calls : Calls) (locals : Locals) :
    Declarations.restore outerDeclarations locals (outerLocals calls locals) = locals := by
  rw [← outer_declarations, restore_declarations]

theorem restore_outer_cursor (calls : Calls) (locals : Locals) (value : Model.Cursor) :
    Declarations.restore outerDeclarations locals (withCursor (outerLocals calls locals) value) =
      withCursor locals value := by
  unfold withCursor
  rw [restore_update _ _ _ _ _ _ (by decide +kernel),
    restore_update _ _ _ _ _ _ (by decide +kernel), restore_outer_locals]

private theorem withCursor_position (locals : Locals) (position : Nat) (value : Model.Cursor) :
    withCursor (locals.set .number "position" position) value = withCursor locals value := by
  unfold withCursor
  rw [Locals.set_commute_types _ .number .nameSpan _ _ _ _ (by decide)]
  simp only [Locals.set_shadow]

private theorem outer_reads (calls : Calls) (locals : Locals) :
    let entered := outerLocals calls locals
    let first := calls.skip (locals .source "text") (locals .number "position")
    let after := calls.nameAfter (locals .source "text") first
    entered .source "text" = locals .source "text" ∧
    entered .number "after" = after ∧
    entered .truth "with_clause" = (first > 0 && after > first && calls.nameIs (locals .source "text") first after "with") ∧
    entered .truth "use_clause" = (first > 0 && after > first && calls.nameIs (locals .source "text") first after "use") ∧
    entered .nameSpan "candidate" = locals .nameSpan "candidate" := by
  simp [outerLocals, Locals.set]

def outerDispatch (locals : Locals) (next leave : Control.Continuation) : Option Model.Step → Option Source
  | none => none
  | some step => dispatch locals next leave step

theorem outerBody_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    outerBody.eval calls.get fuel locals next leave =
      outerDispatch locals next leave (Model.outerStep calls (locals .source "text") fuel (cursor locals)) := by
  obtain ⟨source, afterRead, withRead, useRead, candidateRead⟩ := outer_reads calls locals
  rw [outerBody_entry, outer_declarations, outerCommands_meaning]
  dsimp +instances only [outerAction, Model.outerStep, cursor, loopResult, outerDispatch, dispatch]
  simp only [source, afterRead, withRead, useRead, restore_outer_locals]
  simp only [Locals.set_get_same,
    Locals.set_get_other_name _ _ _ _ _ _ (by decide : "candidate" ≠ "position"), candidateRead]
  split
  · simp [withCursor]
  · cases inner : Model.innerLoop calls (locals .source "text")
        ((outerLocals calls locals) .truth "with_clause") fuel
        ⟨(outerLocals calls locals) .number "after", locals .nameSpan "candidate"⟩ with
    | none => simp_all
    | some result =>
        cases result <;> simp_all [withCursor_position, restore_outer_cursor]

end Silver.ApplicationPackageImport.Native
