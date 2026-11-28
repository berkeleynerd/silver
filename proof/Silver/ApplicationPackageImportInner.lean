module

public import Silver.ApplicationPackageImportStorage

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def innerFinish (locals : Locals) (next leave : Control.Continuation) : Option Source :=
  if locals .number "semicolon_after" ≠ 0 then
    leave (locals.set .number "position" (locals .number "semicolon_after"))
  else next (locals.set .number "position" (locals .number "comma_after"))

def innerSelect (calls : Calls) (locals : Locals) : Bool :=
  locals .truth "with_clause" &&
    !calls.nameIs (locals .source "text") (locals .number "name_first") (locals .number "name_after") "silver_io" &&
    !calls.nameIs (locals .source "text") (locals .number "name_first") (locals .number "name_after") "silver_arguments"

def innerAction (calls : Calls) (locals : Locals) (next leave : Control.Continuation) : Option Source :=
  if !calls.validName (locals .source "text") (locals .nameSpan "name") ||
      (locals .number "comma_after" = 0 && locals .number "semicolon_after" = 0) then some []
  else if innerSelect calls locals then
    if (locals .nameSpan "candidate").first ≠ 0 &&
        !calls.sameName (locals .source "text") (locals .nameSpan "candidate") (locals .nameSpan "name") then some []
    else innerFinish (locals.set .nameSpan "candidate" (locals .nameSpan "name")) next leave
  else innerFinish locals next leave

/-- One iteration's executable commands, before lexical block restoration. -/
theorem innerCommands_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    innerCommands.eval calls.get fuel locals next leave = innerAction calls locals next leave := by
  dsimp +instances only [innerCommands, Control.Command.list, List.foldr, Control.Command.eval,
    rejectIf, Expr.eval, name, nameFirst, nameAfter, commaAfter, semicolonAfter, withClause,
    candidateFirst, candidate, text, call2, call3, call4, empty, present,
    Calls.get, Field.get, Place.set, Place.expression]
  simp [innerAction, innerSelect, innerFinish, Locals.set]

def innerLocals (calls : Calls) (locals : Locals) : Locals :=
  let first := calls.skip (locals .source "text") (locals .number "position")
  let after := calls.nameAfter (locals .source "text") first
  let comma := calls.take (locals .source "text") after (.symbol ",")
  let semicolon := calls.take (locals .source "text") after (.symbol ";")
  let named := ((locals.set .number "name_first" first).set .number "name_after" after).set .nameSpan "name" ⟨first,after⟩
  (named.set .number "comma_after" comma).set .number "semicolon_after" semicolon

theorem inner_declarations (calls : Calls) (locals : Locals) :
    innerDeclarations.foldl (Declaration.eval calls.get) locals = innerLocals calls locals := by
  dsimp +instances only [innerDeclarations, constant, List.foldl, Declaration.eval, Declaration.names,
    Expr.eval, text, position, nameFirst, nameAfter, call2, call3, Calls.get]
  simp [innerLocals, Locals.set]

theorem restore_inner_locals (calls : Calls) (locals : Locals) :
    Declarations.restore innerDeclarations locals (innerLocals calls locals) = locals := by
  rw [← inner_declarations, restore_declarations]

private theorem restore_inner_position (locals updated : Locals) (position : Nat) :
    Declarations.restore innerDeclarations locals (updated.set .number "position" position) =
      (Declarations.restore innerDeclarations locals updated).set .number "position" position :=
  restore_update _ _ _ _ _ _ (by decide +kernel)

private theorem restore_inner_candidate (locals updated : Locals) (name : PackageBindings.NameSpan) :
    Declarations.restore innerDeclarations locals (updated.set .nameSpan "candidate" name) =
      (Declarations.restore innerDeclarations locals updated).set .nameSpan "candidate" name :=
  restore_update _ _ _ _ _ _ (by decide +kernel)

def dispatch (locals : Locals) (next leave : Control.Continuation) : Model.Step → Option Source
  | .reject => some []
  | .next value => next (withCursor locals value)
  | .done value => leave (withCursor locals value)

/-- Complete iteration with the temporary declarations restored on both
continuing and exiting paths. All callees and incoming stores are arbitrary. -/
theorem innerBody_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    innerBody.eval calls.get fuel locals next leave =
      dispatch locals next leave (Model.innerStep calls (locals .source "text")
        (locals .truth "with_clause") (cursor locals)) := by
  dsimp only [innerBody, Control.Command.list, List.foldr, Control.Command.eval]
  rw [innerCommands_meaning, inner_declarations]
  simp only [innerAction, innerSelect, innerFinish]
  simp only [restore_inner_position, restore_inner_candidate, restore_inner_locals]
  dsimp +instances only [Model.innerStep, cursor, dispatch, withCursor]
  simp [innerLocals]
  repeat' first | simp_all | split
  all_goals split at * <;> simp_all
  all_goals subst_vars
  all_goals simp_all

end Silver.ApplicationPackageImport.Native
