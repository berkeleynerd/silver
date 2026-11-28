module

public import Silver.ApplicationPackageImportOuter

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

theorem outer_loop (calls : Calls) (fuel budget : Nat) (locals : Locals)
    (next : Control.Continuation) :
    Control.loop (fun current cont leave => outerBody.eval calls.get fuel current cont leave) next budget locals =
      loopResult locals next (Model.outerLoop calls (locals .source "text") fuel budget (cursor locals)) := by
  induction budget generalizing locals with
  | zero => rfl
  | succ budget ih =>
      rw [Control.loop, outerBody_meaning, Model.outerLoop]
      cases step : Model.outerStep calls (locals .source "text") fuel (cursor locals) with
      | none => simp only [outerDispatch, loopResult]
      | some result =>
          cases result with
          | reject => simp only [outerDispatch, dispatch, loopResult]
          | done value => simp only [outerDispatch, dispatch, loopResult]
          | next value =>
              simp only [outerDispatch, dispatch, ih, withCursor_text, cursor_withCursor]
              cases Model.outerLoop calls (locals .source "text") fuel budget value with
              | none => rfl
              | some result => cases result <;> simp [loopResult]

def tailCommands : C := .list [rejectIf (empty candidateFirst),
  .block resultDeclarations (.returned (.variable "result"))]

def finishSource (locals : Locals) : Option Source :=
  let name := locals .nameSpan "candidate"
  if name.first = 0 then some []
  else some (((locals .source "text").drop (name.first - 1)).take (name.after - name.first))

theorem tail_meaning (calls : Calls) (fuel : Nat) (locals : Locals)
    (next leave : Control.Continuation) :
    tailCommands.eval calls.get fuel locals next leave = finishSource locals := by
  dsimp +instances only [tailCommands, Control.Command.list, List.foldr, Control.Command.eval,
    rejectIf, Expr.eval, candidateFirst, candidateAfter, candidate, empty,
    resultDeclarations, constant, List.foldl, Declaration.eval, Declaration.names,
    Field.get, text, Locals.set, finishSource]
  by_cases absent : (locals .nameSpan "candidate").first = 0
  · simp [absent]
  · have lengthEq : (locals .nameSpan "candidate").after - 1 + 1 - (locals .nameSpan "candidate").first =
        (locals .nameSpan "candidate").after - (locals .nameSpan "candidate").first := by omega
    simp [absent, lengthEq]

end Silver.ApplicationPackageImport.Native
