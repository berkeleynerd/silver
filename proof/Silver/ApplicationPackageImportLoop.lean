module

public import Silver.ApplicationPackageImportInner

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

def loopResult (locals : Locals) (next : Control.Continuation) : Option (Except Unit Model.Cursor) → Option Source
  | none => none
  | some (.error _) => some []
  | some (.ok value) => next (withCursor locals value)

theorem inner_loop (calls : Calls) (fuel budget : Nat) (locals : Locals)
    (next : Control.Continuation) :
    Control.loop (fun current cont leave => innerBody.eval calls.get fuel current cont leave) next budget locals =
      loopResult locals next (Model.innerLoop calls (locals .source "text")
        (locals .truth "with_clause") budget (cursor locals)) := by
  induction budget generalizing locals with
  | zero => rfl
  | succ budget ih =>
      rw [Control.loop, innerBody_meaning, Model.innerLoop]
      cases step : Model.innerStep calls (locals .source "text") (locals .truth "with_clause") (cursor locals) with
      | reject => simp only [dispatch, loopResult]
      | done value => simp only [dispatch, loopResult]
      | next value =>
          simp only [dispatch, ih, withCursor_text, withCursor_clause, cursor_withCursor]
          cases Model.innerLoop calls (locals .source "text") (locals .truth "with_clause") budget value with
          | none => rfl
          | some result => cases result <;> simp [loopResult]

theorem inner_loop_command (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    (Control.Command.loopBody innerBody).eval calls.get fuel locals next leave =
      loopResult locals next (Model.innerLoop calls (locals .source "text")
        (locals .truth "with_clause") fuel (cursor locals)) := inner_loop calls fuel fuel locals next

end Silver.ApplicationPackageImport.Native
