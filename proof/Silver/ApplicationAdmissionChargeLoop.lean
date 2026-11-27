module

public import Silver.ApplicationAdmissionChargeProgress

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions Control
variable {domain : StateDomain}

/-- Constructive termination follows the original cursor variant. Remaining is
threaded through the native store; it is never reset by a recursive loop step. -/
theorem loop_total (calls : Expressions.Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position remaining : Nat) (locals : Locals)
    (bounded : ValidCursor text position) (ready : Ready text position remaining locals) :
    ∃ after, LoopExec (iteration.step calls) locals after ∧ output after = chargeTail text position remaining := by
  have interpreted := iteration_represents calls locals ready.2.2.2
  rw [ready.1, ready.2.1, ready.2.2.1, scanStep_imports calls equations text valid position remaining bounded] at interpreted
  have contract := scanStep_contract text valid position remaining bounded
  cases selected : scanStep modelCalls text position remaining with
  | returned result =>
    rw [selected] at interpreted contract
    cases native : iteration.step calls locals with
    | next following => rw [native] at interpreted; contradiction
    | returned after =>
      rw [native] at interpreted
      exact ⟨after, .returned native, interpreted.trans contract.symm⟩
  | next following allowance =>
    rw [selected] at interpreted contract
    cases native : iteration.step calls locals with
    | returned after => rw [native] at interpreted; contradiction
    | next store =>
      rw [native] at interpreted
      have progress := contract.2.2.1
      obtain ⟨after, rest, result⟩ := loop_total calls equations text valid following allowance store contract.1 interpreted
      exact ⟨after, .next native rest, result.trans contract.2.2.2.symm⟩
termination_by text.length + 1 - position
decreasing_by assumption

theorem initial_ready (prior : Locals) (text : Source) (remaining : Nat) :
    Ready text 1 remaining (initial (inputLocals prior text remaining)) := by
  simp [Ready, initial, inputLocals, Locals.set]

theorem body_total (calls : Expressions.Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (remaining : Nat) (prior : Locals) :
    body.Exec calls (inputLocals prior text remaining) (fun after => output after = chargeUnit text remaining) := by
  rw [body_exec]
  exact loop_total calls equations text valid 1 remaining _ (by unfold ValidCursor; omega)
    (initial_ready prior text remaining)

/-- Exact complete output, on every return path and for every incoming scratch
and out-parameter value. The cursor itself is local and is not an output. -/
theorem imported_reader_exec (calls : Expressions.Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (remaining : Nat) (prior : Locals) (result : ChargeResult) :
    body.Exec calls (inputLocals prior text remaining) (fun after => result = output after) ↔
      result = chargeUnit text remaining := by
  obtain ⟨finalStore, execution, actual⟩ := (body_exec calls _ _).mp
    (body_total calls equations text valid remaining prior)
  constructor
  · intro found
    obtain ⟨after, run, observed⟩ := (body_exec calls _ _).mp found
    have same := run.unique execution
    exact observed.trans (same ▸ actual)
  · intro equal
    apply (body_exec calls _ _).mpr
    exact ⟨finalStore, execution, equal.trans actual.symm⟩

def RemainingBound (remaining : Nat) : Progress → Prop
  | .returned result => result.remaining ≤ remaining
  | .next _ allowance => allowance ≤ remaining

theorem charged_remaining (position remaining : Nat) (charge : Bool) :
    RemainingBound remaining (charged position remaining charge) := by
  unfold charged
  split
  · split <;> simp [RemainingBound]
  · exact Nat.le_refl _

theorem scanStep_remaining (calls : Expressions.Calls) (text : Source) (position remaining : Nat) :
    RemainingBound remaining (scanStep calls text position remaining) := by
  unfold scanStep
  dsimp only
  split
  · exact Nat.le_refl _
  · split
    · exact Nat.le_refl _
    · unfold selected
      split
      · exact Nat.le_refl _
      · split
        · dsimp only
          split <;> exact Nat.le_refl _
        · split
          · exact charged_remaining _ _ _
          · split
            · exact Nat.le_refl _
            · split
              · exact Nat.le_refl _
              · exact charged_remaining _ _ _

theorem chargeTail_remaining (text : Source) (valid : ValidText text) (position remaining : Nat)
    (bounded : ValidCursor text position) : (chargeTail text position remaining).remaining ≤ remaining := by
  have contract := scanStep_contract text valid position remaining bounded
  have decreases := scanStep_remaining modelCalls text position remaining
  cases step : scanStep modelCalls text position remaining with
  | returned result =>
    rw [step] at contract decreases
    rw [contract]
    exact decreases
  | next following allowance =>
    rw [step] at contract decreases
    rw [contract.2.2.2]
    have progress := contract.2.2.1
    exact Nat.le_trans (chargeTail_remaining text valid following allowance contract.1) decreases
termination_by text.length + 1 - position
decreasing_by assumption

theorem output_domain (text : Source) (valid : ValidText text) (remaining : Nat)
    (bounded : remaining ≤ maxConcatenations) : (chargeUnit text remaining).remaining ≤ maxConcatenations :=
  Nat.le_trans (chargeTail_remaining text valid 1 remaining (by unfold ValidCursor; omega)) bounded

end Silver.ApplicationAdmission.Charge
