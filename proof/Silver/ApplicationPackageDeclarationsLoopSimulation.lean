module

public import Silver.ApplicationPackageDeclarationsTransfers

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.Control
open ApplicationNative

/-- Observable state at the three possible control transfers. A return exposes
the procedure outputs. Both loop continuations retain the parser state. -/
inductive Observation (State Result : Type) where
  | next (state : State)
  | returned (result : Result)
  | exited (state : State)

def Transfer.project (state : Locals → σ) (result : Locals → ρ) : Transfer → Observation σ ρ
  | .next store => .next (state store)
  | .returned store => .returned (result store)
  | .exited store => .exited (state store)

inductive Observation.Run (step : σ → Observation σ ρ) : σ → Observation σ ρ → Prop where
  | returned {before after} (last : step before = .returned after) : Run step before (.returned after)
  | exited {before after} (last : step before = .exited after) : Run step before (.exited after)
  | next {before following final} (first : step before = .next following)
      (rest : Run step following final) : Run step before final

theorem LoopExec.project_run {native : Locals → Transfer} {step : σ → Observation σ ρ}
    (state : Locals → σ) (result : Locals → ρ)
    (agrees : ∀ store, (native store).project state result = step (state store))
    {start finish} (run : LoopExec native start finish) :
    Observation.Run step (state start) (finish.project state result) := by
  induction run with
  | returned last =>
      apply Observation.Run.returned
      rw [← agrees, last]
      rfl
  | exited last =>
      apply Observation.Run.exited
      rw [← agrees, last]
      rfl
  | next first _ tail =>
      apply Observation.Run.next _ tail
      rw [← agrees, first]
      rfl

private theorem project_returned {state : Locals → σ} {result : Locals → ρ}
    {transfer : Transfer} {value : ρ} :
    transfer.project state result = .returned value ↔
    ∃ store, transfer = .returned store ∧ result store = value := by
  cases transfer <;> simp [Transfer.project]

private theorem project_exited {state : Locals → σ} {result : Locals → ρ}
    {transfer : Transfer} {value : σ} :
    transfer.project state result = .exited value ↔
    ∃ store, transfer = .exited store ∧ state store = value := by
  cases transfer <;> simp [Transfer.project]

private theorem project_next {state : Locals → σ} {result : Locals → ρ}
    {transfer : Transfer} {value : σ} :
    transfer.project state result = .next value ↔
    ∃ store, transfer = .next store ∧ state store = value := by
  cases transfer <;> simp [Transfer.project]

/-- Lift a finite run at the observable level from any full incoming local
store with the specified state. The witness records the actual native updates. -/
theorem Observation.Run.lift {native : Locals → Transfer} {step : σ → Observation σ ρ}
    (state : Locals → σ) (result : Locals → ρ)
    (agrees : ∀ store, (native store).project state result = step (state store))
    {start finish} (run : Observation.Run step start finish) :
    ∀ store, state store = start → ∃ terminal,
      LoopExec native store terminal ∧ terminal.project state result = finish := by
  induction run with
  | returned last =>
      intro store atStart
      have projected := (agrees store).trans ((congrArg step atStart).trans last)
      obtain ⟨after, actual, output⟩ := project_returned.mp projected
      exact ⟨.returned after, .returned actual, congrArg Observation.returned output⟩
  | exited last =>
      intro store atStart
      have projected := (agrees store).trans ((congrArg step atStart).trans last)
      obtain ⟨after, actual, atEnd⟩ := project_exited.mp projected
      exact ⟨.exited after, .exited actual, congrArg Observation.exited atEnd⟩
  | next first _ tail =>
      intro store atStart
      have projected := (agrees store).trans ((congrArg step atStart).trans first)
      obtain ⟨following, actual, advanced⟩ := project_next.mp projected
      obtain ⟨terminal, rest, atEnd⟩ := tail following advanced
      exact ⟨terminal, .next actual rest, atEnd⟩

theorem LoopExec.observe_iff {native : Locals → Transfer} {step : σ → Observation σ ρ}
    (state : Locals → σ) (result : Locals → ρ)
    (agrees : ∀ store, (native store).project state result = step (state store))
    (store : Locals) (accept : Observation σ ρ → Prop) :
    (∃ terminal, LoopExec native store terminal ∧ accept (terminal.project state result)) ↔
    ∃ terminal, Observation.Run step (state store) terminal ∧ accept terminal := by
  constructor
  · rintro ⟨terminal, run, accepted⟩
    exact ⟨_, run.project_run state result agrees, accepted⟩
  · rintro ⟨terminal, run, accepted⟩
    obtain ⟨actual, nativeRun, same⟩ := run.lift state result agrees store rfl
    exact ⟨actual, nativeRun, same.symm ▸ accepted⟩

end Silver.ApplicationPackageDeclarations.Control
