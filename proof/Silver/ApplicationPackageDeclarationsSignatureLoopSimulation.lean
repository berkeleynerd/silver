module

public import Silver.ApplicationPackageDeclarationsSignatureIteration
public import Silver.ApplicationPackageDeclarationsSignatureSlots
public import Silver.ApplicationPackageDeclarationsLoopSimulation

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option maxHeartbeats 2000000
set_option maxRecDepth 20000
attribute [local irreducible] Statement.eval

structure Configuration where
  source : Source
  outer : ParserState
  completing : Bool

def configuration (store : Locals) : Configuration :=
  ⟨store .source "text", store .state "outer", store .truth "completing"⟩

abbrev Context := Configuration × SignatureState

def context (store : Locals) : Context := (configuration store, projectState store)

private def rawObservation (calls : SignatureCalls) (current : Context) : Observation Context SignatureResult :=
  observeStep current.1.source current.1.outer current.1.completing
    (fun source outer completing state => .next (⟨source, outer, completing⟩, state)) .returned
    (fun source outer completing state => .exited (⟨source, outer, completing⟩, state))
    (signatureStep calls current.1.source current.1.completing current.2)

private def rawExit (cfg : Configuration) : SignatureExit → Observation Context SignatureResult
  | .returned result => .returned result
  | .ready state => .exited (cfg, state)

private theorem iteration_agrees (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (store : Locals) :
    (iteration.step calls.get procedures backing store).project context projectResult =
      rawObservation (rawCalls calls procedures) (context store) := by
  have mapped (transfer : Transfer) :
      transfer.project context projectResult = transfer.resume (fun s => .next (context s))
        (fun s => .returned (projectResult s)) (fun s => .exited (context s)) := by cases transfer <;> rfl
  rw [mapped, Statement.resume_step]
  dsimp only [context, configuration, rawObservation]
  exact iteration_observation (α := Observation Context SignatureResult) calls procedures backing store
    (fun source outer completing state => .next (⟨source, outer, completing⟩, state)) .returned
    (fun source outer completing state => .exited (⟨source, outer, completing⟩, state))

private theorem observe_loop {calls} (cfg : Configuration) {state exit}
    (run : SignatureLoop calls cfg.source cfg.completing state exit) :
    Observation.Run (rawObservation calls) (cfg, state) (rawExit cfg exit) := by
  induction run with
  | returned last => exact .returned (by simp [rawObservation, last, observeStep])
  | ready last => exact .exited (by simp [rawObservation, last, observeStep])
  | next first _ rest => exact .next (by simp [rawObservation, first, observeStep]) rest

private theorem raw_returned {calls current result} (step : rawObservation calls current = .returned result) :
    signatureStep calls current.1.source current.1.completing current.2 = .returned result := by
  unfold rawObservation at step
  generalize h : signatureStep calls current.1.source current.1.completing current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem raw_exited {calls current final} (step : rawObservation calls current = .exited final) :
    ∃ state, signatureStep calls current.1.source current.1.completing current.2 = .ready state ∧
      final = (current.1, state) := by
  unfold rawObservation at step
  generalize h : signatureStep calls current.1.source current.1.completing current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem raw_next {calls current following} (step : rawObservation calls current = .next following) :
    ∃ state, signatureStep calls current.1.source current.1.completing current.2 = .next state ∧
      following = (current.1, state) := by
  unfold rawObservation at step
  generalize h : signatureStep calls current.1.source current.1.completing current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem recover_loop {calls current terminal} (run : Observation.Run (rawObservation calls) current terminal) :
    ∃ exit, SignatureLoop calls current.1.source current.1.completing current.2 exit ∧ terminal = rawExit current.1 exit := by
  induction run with
  | returned last => exact ⟨_, .returned (raw_returned last), rfl⟩
  | exited last =>
      obtain ⟨final, step, rfl⟩ := raw_exited last
      exact ⟨_, .ready step, rfl⟩
  | next first _ rest =>
      obtain ⟨following, step, rfl⟩ := raw_next first
      obtain ⟨exit, tail, atEnd⟩ := rest
      exact ⟨exit, .next step tail, atEnd⟩

private def exitSlot (completing : Bool) : SignatureExit → Prop
  | .returned _ => True
  | .ready state => RoutineSlot completing state

private theorem loop_slot {calls source completing state exit} (run : SignatureLoop calls source completing state exit)
    (fresh : RoutineSlot completing state) : exitSlot completing exit := by
  induction run with
  | returned _ => trivial
  | ready step =>
      have checked := iteration_slot calls source completing _ fresh
      rwa [step] at checked
  | next step _ tail =>
      have checked := iteration_slot calls source completing _ fresh
      rw [step] at checked
      exact tail checked

private def finalSlot : Observation Context SignatureResult → Prop
  | .exited (cfg, state) => RoutineSlot cfg.completing state
  | _ => True

private def accept (calls : SignatureCalls) (result : SignatureResult) : Observation Context SignatureResult → Prop
  | .next _ => False
  | .returned value => result = value
  | .exited (cfg, state) => result = finishSignature calls cfg.source cfg.outer cfg.completing state

def rawLoop (calls : SignatureCalls) (result : SignatureResult) (cfg : Configuration) (state : SignatureState) : Prop :=
  ∃ exit, SignatureLoop calls cfg.source cfg.completing state exit ∧ result = match exit with
    | .returned value => value
    | .ready final => finishSignature calls cfg.source cfg.outer cfg.completing final

def nativeFinish (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult) (store : Locals) : Prop :=
  finish.eval calls.get procedures backing store
    (fun out => result = projectResult out) (fun out => result = projectResult out) (fun _ => False)

def nativeAccept (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult) :
    Transfer → Prop
  | .returned final => result = projectResult final
  | .exited final => nativeFinish calls procedures backing result final
  | .next _ => False

def nativeLoop (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult) (store : Locals) : Prop :=
  ∃ terminal, LoopExec (iteration.step calls.get procedures backing) store terminal ∧ nativeAccept calls procedures backing result terminal

private theorem final_agrees (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult)
    (t : Transfer) (fresh : finalSlot (t.project context projectResult)) :
    nativeAccept calls procedures backing result t = accept (rawCalls calls procedures) result (t.project context projectResult) := by
  cases t with
  | next | returned => rfl
  | exited store => exact finish_meaning calls procedures backing store fresh (fun value => result = value) _

theorem loop_iff (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult)
    (store : Locals) (slot : RoutineSlot (configuration store).completing (projectState store)) :
    nativeLoop calls procedures backing result store ↔ rawLoop (rawCalls calls procedures) result (configuration store) (projectState store) := by
  let actual := rawCalls calls procedures
  have terminalSlot (exit : SignatureExit) : exitSlot (configuration store).completing exit =
      finalSlot (rawExit (configuration store) exit) := by cases exit <;> rfl
  have accepts (exit : SignatureExit) :
      accept actual result (rawExit (configuration store) exit) =
      (result = match exit with
        | .returned value => value
        | .ready final => finishSignature actual (configuration store).source (configuration store).outer (configuration store).completing final) := by
    cases exit <;> rfl
  constructor
  · rintro ⟨terminal, run, accepted⟩
    have observed := run.project_run context projectResult (iteration_agrees calls procedures backing)
    obtain ⟨exit, raw, same⟩ := recover_loop observed
    have fresh := (terminalSlot exit) ▸ loop_slot raw slot
    have acceptedRaw := Eq.mp (final_agrees calls procedures backing result terminal (same.symm ▸ fresh)) accepted
    exact ⟨exit, raw, (accepts exit) ▸ (same ▸ acceptedRaw)⟩
  · rintro ⟨exit, raw, resultEq⟩
    have observed := observe_loop (configuration store) raw
    obtain ⟨terminal, run, same⟩ := observed.lift context projectResult (iteration_agrees calls procedures backing) store rfl
    have fresh := (terminalSlot exit) ▸ loop_slot raw slot
    have accepted := Eq.mpr (accepts exit) resultEq
    exact ⟨terminal, run, (final_agrees calls procedures backing result terminal (same.symm ▸ fresh)).symm ▸ (same.symm ▸ accepted)⟩

end Silver.ApplicationPackageDeclarations.SignatureNative
