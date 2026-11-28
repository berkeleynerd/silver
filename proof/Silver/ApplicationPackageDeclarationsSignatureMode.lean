module

public import Silver.ApplicationPackageDeclarationsSignatureStorage

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def afterHide (calls : SignatureCalls) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (store : Locals) : α :=
  observeAt next returned exited store (readFormalType calls (store .source "text") (store .truth "completing")
    (store .number "before") (projectState store) (store .number "first") (store .number "last") (store .number "slot"))

theorem ParameterSlot.of_fields {prior updated : Locals} (fresh : ParameterSlot prior)
    (completing : updated .truth "completing" = prior .truth "completing")
    (slot : updated .number "slot" = prior .number "slot")
    (info : updated .metadata "info" = prior .metadata "info") : ParameterSlot updated := by
  unfold ParameterSlot at *
  rwa [completing, slot, info]

/-- Every mode branch retains the selected slot. The `in` spelling may or may
not be followed by `out`, and functions accept only the resulting input mode. -/
theorem readMode_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (fresh : ParameterSlot store) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (tail : Locals → α)
    (agrees : ∀ out, ParameterSlot out → tail out = afterType (rawCalls calls procedures) next returned exited out) :
    readMode.eval calls.get procedures backing store tail (fun out => returned (projectResult out)) (onState exited) =
    afterHide (rawCalls calls procedures) next returned exited store := by
  unfold readMode afterHide observeAt readFormalType
  signature_values
  simp (disch := apply ParameterSlot.of_fields fresh <;> signature_lookups) only [agrees]
  dsimp only [afterType, observeAt, projectState, rawCalls]
  signature_lookups
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
  repeat' first | rfl | contradiction | split

end Silver.ApplicationPackageDeclarations.SignatureNative
