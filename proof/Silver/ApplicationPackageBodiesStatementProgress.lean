module

public import Silver.ApplicationPackageBodiesStatementModel
public import Silver.ComposeAtomReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open ApplicationPackages Compose

theorem readArm_start (calls : Calls) (s : Input) (state : Arms) (read : ReadArm)
    (ok : readArm calls s state = some read) : read.start = state.value.scan.position := by
  dsimp only [readArm] at ok
  split at ok
  · contradiction
  · split at ok
    · contradiction
    · split at ok <;> cases ok
      rfl

theorem armStep_advance (calls : Calls) (s : Input) (state next : Arms)
    (step : armStep calls s state = .continued next) :
    state.value.scan.position < next.value.scan.position ∧
      ∃ pos, next.value.scan.position = calls.takeToken s.text pos (.word "elsif") := by
  unfold armStep at step
  cases parsed : readArm calls s state with
  | none => simp only [parsed, reduceCtorEq] at step
  | some result =>
    simp only [parsed] at step
    have original := readArm_start calls s state result parsed
    unfold finishArm at step
    dsimp only at step
    split at step
    · contradiction
    · split at step
      · contradiction
      · rename_i advanced
        cases step
        constructor
        · dsimp only [atPosition]
          omega
        · exact ⟨_, rfl⟩

theorem armsFuel_total {step : Arms → ArmStep} {limit : Nat}
    (advances : ∀ state next, step state = .continued next →
      state.value.scan.position < next.value.scan.position ∧ next.value.scan.position ≤ limit)
    (state : Arms) (fuel : Nat) (enough : limit - state.value.scan.position + 1 ≤ fuel) :
    ∃ result, armsFuel step fuel state = some result := by
  induction fuel generalizing state with
  | zero => omega
  | succ fuel ih =>
    rw [armsFuel]
    cases move : step state with
    | failed => exact ⟨_, rfl⟩
    | finished out => exact ⟨_, rfl⟩
    | continued next =>
      obtain ⟨progress, bounded⟩ := advances state next move
      exact ih next (by omega)

theorem armsFuel_persistent {step : Arms → ArmStep} {state : Arms} {fuel : Nat} {result : Option Arms}
    (finished : armsFuel step fuel state = some result) (extra : Nat) :
    armsFuel step (fuel + extra) state = some result := by
  induction fuel generalizing state with
  | zero => simp [armsFuel] at finished
  | succ fuel ih =>
    rw [Nat.succ_add, armsFuel]
    rw [armsFuel] at finished
    cases move : step state with
    | failed | finished _ => simpa only [move] using finished
    | continued next => apply ih; simpa only [move] using finished

/-- The native lexical boundary bounds every accepted elsif continuation,
including a condition or nested-tail import returning an arbitrary cursor. -/
theorem statementFuel_total (calls : Calls) (s : Input) (fuel : Nat) (enough : s.text.length + 2 ≤ fuel) :
    ∃ result, statementFuel {calls with takeToken := tokenAfter} fuel s = some result := by
  let actual := {calls with takeToken := tokenAfter}
  have advances (state next : Arms) (moved : armStep actual s state = .continued next) :
      state.value.scan.position < next.value.scan.position ∧ next.value.scan.position ≤ s.text.length + 1 := by
    obtain ⟨greater, pos, eqn⟩ := armStep_advance actual s state next moved
    exact ⟨greater, eqn ▸ fixedAfter_result_bound s.text pos "elsif" true (by decide)⟩
  change ∃ result, statementFuel actual fuel s = some result
  unfold statementFuel
  split
  · exact ⟨_, rfl⟩
  · dsimp only
    split
    · obtain ⟨value, eqn⟩ := armsFuel_total advances
          ⟨atPosition s.input (actual.takeToken s.text s.input.scan.position (.word "if")), s.input.scan.facts, false⟩
          fuel (by omega)
      rw [eqn]
      exact ⟨_, rfl⟩
    · split <;> exact ⟨_, rfl⟩

end Silver.ApplicationPackageBodies.Statement
