module

public import Silver.ApplicationPackageDeclarationsSignatureName
public import Silver.ApplicationPackageDeclarationsTransfers

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

theorem selectFormal_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (tail : Locals → α)
    (agrees : ∀ out, ParameterSlot out → tail out = afterSlot (rawCalls calls procedures) next returned exited out) :
    (Statement.list selectFormalCommands).eval calls.get procedures backing store tail
      (fun out => returned (projectResult out)) (onState exited) =
    observeAt next returned exited store
      (signatureStep (rawCalls calls procedures) (store .source "text") (store .truth "completing") (projectState store)) := by
  unfold selectFormalCommands invariants selectSlot signatureStep observeAt
  signature_values
  signature_lookups
  cases completing : store .truth "completing" <;>
    simp only [rawCalls, Bool.false_eq_true, Bool.false_and, Bool.true_and,
      Bool.false_or, Bool.or_false, Bool.not_true, Bool.not_false, Bool.not_eq_true',
      decide_eq_true_eq, ↓reduceIte] <;>
    repeat' first | rfl | contradiction | split
  all_goals
    rw [agrees _ (by simp_all [ParameterSlot, Locals.set])]
    dsimp only [afterSlot, observeAt, projectState, rawCalls]
    simp_all [Locals.set]

private theorem eval_list_append {Fn : Ty → Type} (functions : ApplicationNative.Calls Fn) (procedures : ProcedureCalls)
    (backing : Backing) (left right : List (Statement Fn)) (store : Locals) (next returned exited : Locals → α) :
    (Statement.list (left ++ right)).eval functions procedures backing store next returned exited =
      (Statement.list left).eval functions procedures backing store
        (fun current => (Statement.list right).eval functions procedures backing current next returned exited)
        returned exited := by
  induction left generalizing store with
  | nil => rfl
  | cons item rest ih =>
      exact congrArg (fun cont => item.eval functions procedures backing store cont returned exited)
        (funext (fun current => ih current))

theorem iteration_observation (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (next : Continuation α) (returned : SignatureResult → α) (exited : Continuation α) :
    iteration.eval calls.get procedures backing store (onState next)
      (fun out => returned (projectResult out)) (onState exited) =
    observeAt next returned exited store
      (signatureStep (rawCalls calls procedures) (store .source "text") (store .truth "completing") (projectState store)) := by
  let ret := fun out => returned (projectResult out)
  let outside := onState exited
  let ending := afterStore (rawCalls calls procedures) next returned exited
  let storeParam := fun s => storeParameter.eval calls.get procedures backing s ending ret outside
  let mode := fun s => readMode.eval calls.get procedures backing s storeParam ret outside
  have storage (s : Locals) (fresh : ParameterSlot s) :
      storeParam s = afterType (rawCalls calls procedures) next returned exited s :=
    storeParameter_meaning calls procedures backing s fresh next returned exited
  have modeStep (s : Locals) (fresh : ParameterSlot s) :
      mode s = afterHide (rawCalls calls procedures) next returned exited s :=
    readMode_meaning calls procedures backing s fresh next returned exited storeParam storage
  have last : (fun s => endParameter.eval calls.get procedures backing s (onState next) ret outside) = ending :=
    funext (fun s => endParameter_meaning calls procedures backing s next returned exited)
  unfold iteration
  rw [List.append_assoc, eval_list_append]
  simp only [eval_list_append (left := hideFormalCommands)]
  change (Statement.list selectFormalCommands).eval calls.get procedures backing store
    (fun s => (Statement.list hideFormalCommands).eval calls.get procedures backing s
      (fun h => readMode.eval calls.get procedures backing h
        (fun m => storeParameter.eval calls.get procedures backing m
          (fun e => endParameter.eval calls.get procedures backing e (onState next) ret outside)
          ret outside) ret outside) ret outside) ret outside = _
  rw [last]
  apply selectFormal_meaning
  intro s fresh
  exact hideFormal_meaning calls procedures backing s fresh next returned exited mode modeStep

end Silver.ApplicationPackageDeclarations.SignatureNative
