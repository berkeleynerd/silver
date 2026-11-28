module

public import Silver.ApplicationPackageDeclarationsSignatureFinish

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def observeAt (next : Continuation α) (returned : SignatureResult → α) (exited : Continuation α)
    (store : Locals) (step : SignatureStep) : α :=
  observeStep (store .source "text") (store .state "outer") (store .truth "completing") next returned exited step

def afterStore (calls : SignatureCalls) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (store : Locals) : α :=
  observeAt next returned exited store
    (finishFormal calls (store .source "text") (store .number "before") (projectState store))

def afterType (calls : SignatureCalls) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (store : Locals) : α :=
  observeAt next returned exited store (storeFormal calls (store .source "text") (store .truth "completing")
    (store .number "before") (projectState store) (store .number "first") (store .number "last")
    (store .number "slot") (store .mode "mode") (store .packageType "mark"))

def ParameterSlot (store : Locals) : Prop :=
  store .truth "completing" = false → store .number "slot" = (store .metadata "info").parameters.length + 1

/-- Completing a formal updates its existing cell. A new formal grows the
native table by one and overwrites the newly exposed cell of the backing array. -/
theorem storeParameter_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (fresh : ParameterSlot store) (next : Continuation α)
    (returned : SignatureResult → α) (exited : Continuation α) :
    storeParameter.eval calls.get procedures backing store (afterStore (rawCalls calls procedures) next returned exited)
      (fun out => returned (projectResult out)) (onState exited) =
    afterType (rawCalls calls procedures) next returned exited store := by
  unfold storeParameter completeParameter newParameter environmentAssertions afterType afterStore observeAt storeFormal rawCalls
  signature_values
  signature_lookups
  cases completing : store .truth "completing" with
  | false =>
      have following := fresh completing
      simp [following, Storage.write_after_resize]
      split <;> rfl
  | true =>
      simp [or_assoc]
      split <;> first | rfl | (split <;> rfl)

end Silver.ApplicationPackageDeclarations.SignatureNative
