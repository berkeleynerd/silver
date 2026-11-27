module

public import Silver.ApplicationPackageDeclarationsSignatureEquations

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

/-- A declaration takes the following unused routine slot at entry. The loop
can add formals while retaining both the routine table and its saved slot. -/
def RoutineSlot (completing : Bool) (state : SignatureState) : Prop :=
  completing = false → state.routineId = state.info.routines.length + 1

theorem finish_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (fresh : RoutineSlot (store .truth "completing") (projectState store))
    (done : SignatureResult → α) (exited : Locals → α) :
    finish.eval calls.get procedures backing store (fun s => done (projectResult s))
      (fun s => done (projectResult s)) exited =
    done (finishSignature (rawCalls calls procedures) (store .source "text") (store .state "outer")
      (store .truth "completing") (projectState store)) := by
  unfold finish resultType finishSignature rawCalls
  signature_values
  signature_lookups
  cases completing : store .truth "completing" with
  | false =>
      have following : store .number "routine_id" = (store .metadata "info").routines.length + 1 := fresh completing
      cases kind : (store .routine "item").kind <;>
        simp [following, Storage.write_after_resize] <;>
        repeat' first | rfl | split
  | true =>
      cases kind : (store .routine "item").kind <;>
        simp [kind, or_assoc] <;>
        repeat' first | rfl | split

end Silver.ApplicationPackageDeclarations.SignatureNative
