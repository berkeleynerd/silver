module

public import Silver.ApplicationPackageDeclarationsSignatureMode

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def afterSlot (calls : SignatureCalls) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (store : Locals) : α :=
  observeAt next returned exited store (readFormalName calls (store .source "text") (store .truth "completing")
    (store .number "before") (projectState store) (store .number "first") (store .number "last") (store .number "slot"))

theorem duplicate_meaning (calls : Calls) (store : Locals) :
    duplicate.eval calls.get store = (decide (store .number "formal_count" > 0) &&
      duplicateFormal calls.base (store .source "text") (store .truth "completing") (store .metadata "info")
        ⟨store .number "first", store .number "last"⟩ (store .number "formal_start") (store .number "formal_count")) := by
  unfold duplicate duplicateFormal
  signature_values
  signature_lookups
  by_cases nonempty : store .number "formal_count" > 0
  · have count_range (start count : Nat) (positive : 0 < count) : start + count - 1 + 1 - start = count := by omega
    rw [count_range _ _ nonempty]
  · simp only [nonempty, decide_false, Bool.false_and]

theorem hideFormal_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (fresh : ParameterSlot store) (next : Continuation α) (returned : SignatureResult → α)
    (exited : Continuation α) (tail : Locals → α)
    (agrees : ∀ out, ParameterSlot out → tail out = afterHide (rawCalls calls procedures) next returned exited out) :
    (Statement.list hideFormalCommands).eval calls.get procedures backing store tail
      (fun out => returned (projectResult out)) (onState exited) =
    afterSlot (rawCalls calls procedures) next returned exited store := by
  have duplicateEq := duplicate_meaning calls store
  have sameDuplicate (source completing info name first count) :
      duplicateFormal (rawCalls calls procedures) source completing info name first count =
        duplicateFormal calls.base source completing info name first count := rfl
  unfold hideFormalCommands environmentAssertions afterSlot observeAt readFormalName
  simp only [sameDuplicate]
  generalize duplicate = test at duplicateEq ⊢
  signature_values
  rw [duplicateEq]
  simp (disch := apply ParameterSlot.of_fields fresh <;> signature_lookups) only [agrees]
  dsimp only [afterHide, observeAt, projectState, rawCalls]
  signature_lookups
  simp only [decide_eq_true_eq]
  split <;> first | rfl | (split <;> rfl)

end Silver.ApplicationPackageDeclarations.SignatureNative
