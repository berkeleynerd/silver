module

public import Silver.ApplicationPackageCallsAliasInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

set_option backward.dsimp.instances true

private theorem reset_inputs (calls : ApplicationPackageCalls.Calls) (locals : Locals) :
    aliasInputs (resetLocals calls locals) = aliasInputs locals := by
  unfold resetLocals
  dsimp only
  split
  · split <;> simp [aliasInputs, Locals.set]
  · rfl

private theorem state_index_inputs (locals : Locals) (index : Nat) :
    aliasInputs (locals.set .number "s" index) = aliasInputs locals := by
  simp [aliasInputs, Locals.set]

def resetStepInputs (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (result : ApplicationPackages.ApplicationCall) (index : Nat) : ApplicationPackages.ApplicationCall :=
  resetState calls inputs.text inputs.context inputs.info inputs.callWrites result index

theorem reset_values (calls : ApplicationPackageCalls.Calls) (indices : List Nat) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall) :
    forValues (resultType := .appCall)
      (fun current continuation => resetCommands.eval (resultType := .appCall) (imported calls) current continuation)
      "s" indices locals (fun updated => next (aliasInputs updated) (updated .appCall "result")) =
      next (aliasInputs locals) (indices.foldl (resetStepInputs calls (aliasInputs locals))
        (locals .appCall "result")) := by
  induction indices generalizing locals with
  | nil => rfl
  | cons index rest ih =>
      rw [forValues, reset_body_denotation, ih, reset_inputs, state_index_inputs, List.foldl_cons]
      have result := resetLocals_result calls (locals.set .number "s" index)
      have projected : resetLocals calls (locals.set .number "s" index) .appCall "result" =
          resetStepInputs calls (aliasInputs locals) (locals .appCall "result") index := by
        simpa (disch := decide) only [resetStepInputs, aliasInputs, Locals.set_get_same,
          Locals.set_get_other] using result
      rw [projected]

/-- The native loop uses one-based state identities and restores the index on
normal exit. Every allocated effect bit and every metadata prefix is retained. -/
def resetScan : C := .forRange "s" (.number 1) (.field .stateCount info) resetCommands

theorem reset_scan_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall) :
    resetScan.eval (resultType := .appCall) (imported calls) locals
        (fun updated => next (aliasInputs updated) (updated .appCall "result")) =
      next (aliasInputs locals) ((List.range (locals .metadata "info").states.length).foldl
        (fun result offset => resetStepInputs calls (aliasInputs locals) result (offset + 1))
        (locals .appCall "result")) := by
  change forValues (resultType := .appCall)
    (fun current continuation => resetCommands.eval (resultType := .appCall) (imported calls) current continuation)
    "s" ((List.range ((locals .metadata "info").states.length + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (aliasInputs (updated.set .number "s" (locals .number "s")))
      ((updated.set .number "s" (locals .number "s")) .appCall "result")) = _
  simp only [Nat.add_sub_cancel, state_index_inputs,
    Locals.set_get_other_type _ .number .appCall _ _ _ (by decide)]
  rw [reset_values, List.foldl_map]
  simp only [Nat.add_comm 1]

end Silver.ApplicationPackageCalls.Native.Call
