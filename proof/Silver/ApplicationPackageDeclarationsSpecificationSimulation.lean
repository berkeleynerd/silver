module

public import Silver.ApplicationPackageDeclarationsSpecificationIteration
public import Silver.ApplicationPackageDeclarationsLoopSimulation

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SpecificationNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option maxHeartbeats 2000000
set_option maxRecDepth 20000
attribute [local irreducible] Statement.eval

private abbrev Context := Source × SpecificationState

private def context (store : Locals) : Context := (store .source "text", projectState store)

private def rawObservation (calls : SpecificationCalls) (current : Context) :
    Observation Context SpecificationResult :=
  observeStep current.1 (fun source state => .next (source, state)) .returned
    (fun source state => .exited (source, state)) (specificationStep calls current.1 current.2)

private def rawExit (source : Source) : SpecificationExit → Observation Context SpecificationResult
  | .returned result => .returned result
  | .ready state => .exited (source, state)

private theorem iteration_agrees (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) :
    (iteration.step (functions calls) procedures backing store).project context projectResult =
      rawObservation (rawCalls calls procedures) (context store) := by
  have mapped (transfer : Transfer) :
      transfer.project context projectResult = transfer.resume (fun s => .next (context s))
        (fun s => .returned (projectResult s)) (fun s => .exited (context s)) := by cases transfer <;> rfl
  rw [mapped, Statement.resume_step]
  dsimp only [context, rawObservation]
  exact iteration_observation (α := Observation Context SpecificationResult) calls procedures backing store (fun source state => .next (source, state))
    .returned (fun source state => .exited (source, state))

private theorem observe_loop {calls source state exit} (run : SpecificationLoop calls source state exit) :
    Observation.Run (rawObservation calls) (source, state) (rawExit source exit) := by
  induction run with
  | returned last => exact .returned (by simp [rawObservation, last, observeStep])
  | ready last => exact .exited (by simp [rawObservation, last, observeStep])
  | next first _ rest => exact .next (by simp [rawObservation, first, observeStep]) rest

private theorem raw_returned {calls current result}
    (step : rawObservation calls current = .returned result) :
    specificationStep calls current.1 current.2 = .returned result := by
  unfold rawObservation at step
  generalize h : specificationStep calls current.1 current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem raw_exited {calls current final}
    (step : rawObservation calls current = .exited final) :
    ∃ state, specificationStep calls current.1 current.2 = .ready state ∧ final = (current.1, state) := by
  unfold rawObservation at step
  generalize h : specificationStep calls current.1 current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem raw_next {calls current following}
    (step : rawObservation calls current = .next following) :
    ∃ state, specificationStep calls current.1 current.2 = .next state ∧ following = (current.1, state) := by
  unfold rawObservation at step
  generalize h : specificationStep calls current.1 current.2 = action at step ⊢
  cases action <;> simp_all [observeStep]

private theorem recover_loop {calls current terminal}
    (run : Observation.Run (rawObservation calls) current terminal) :
    ∃ exit, SpecificationLoop calls current.1 current.2 exit ∧ terminal = rawExit current.1 exit := by
  induction run with
  | returned last => exact ⟨_, .returned (raw_returned last), rfl⟩
  | exited last =>
      obtain ⟨final, step, rfl⟩ := raw_exited last
      exact ⟨_, .ready step, rfl⟩
  | next first _ rest =>
      obtain ⟨following, step, rfl⟩ := raw_next first
      obtain ⟨exit, tail, atEnd⟩ := rest
      exact ⟨exit, .next step tail, atEnd⟩

private def accept (calls : SpecificationCalls) (result : SpecificationResult) :
    Observation Context SpecificationResult → Prop
  | .next _ => False
  | .returned value => result = value
  | .exited (source, state) => result = finishSpecification calls source state

private def rawLoop (calls : SpecificationCalls) (result : SpecificationResult) (source : Source)
    (state : SpecificationState) : Prop :=
  ∃ exit, SpecificationLoop calls source state exit ∧ result = match exit with
    | .returned value => value
    | .ready final => finishSpecification calls source final

private def nativeLoop (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (result : SpecificationResult) (store : Locals) : Prop :=
  ∃ terminal, LoopExec (iteration.step (functions calls) procedures backing) store terminal ∧
    match terminal with
    | .returned final => result = projectResult final
    | .exited final => finish.eval (functions calls) procedures backing final
        (fun out => result = projectResult out) (fun out => result = projectResult out) (fun _ => False)
    | .next _ => False

private theorem loop_iff (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (result : SpecificationResult) (store : Locals) :
    nativeLoop calls procedures backing result store ↔
      rawLoop (rawCalls calls procedures) result (store .source "text") (projectState store) := by
  let actual := rawCalls calls procedures
  have terminal (t : Transfer) :
      (match t with
      | .returned final => result = projectResult final
      | .exited final => finish.eval (functions calls) procedures backing final
          (fun out => result = projectResult out) (fun out => result = projectResult out) (fun _ => False)
      | .next _ => False) =
      accept actual result (t.project context projectResult) := by
    cases t with
    | next | returned => rfl
    | exited final => exact finish_meaning calls procedures backing final (fun value => result = value) _ _
  unfold nativeLoop
  simp only [terminal]
  rw [LoopExec.observe_iff context projectResult (iteration_agrees calls procedures backing) store]
  have accepts (exit : SpecificationExit) :
      accept actual result (rawExit (store .source "text") exit) =
      (result = match exit with
        | .returned value => value
        | .ready final => finishSpecification actual (store .source "text") final) := by
    cases exit <;> rfl
  constructor
  · rintro ⟨_, run, accepted⟩
    obtain ⟨exit, raw, same⟩ := recover_loop run
    exact ⟨exit, raw, (accepts exit) ▸ (same ▸ accepted)⟩
  · rintro ⟨exit, run, resultEq⟩
    exact ⟨_, observe_loop run, (accepts exit).symm ▸ resultEq⟩

/-- Equivalence holds for every incoming local store, backing array and in-out
parameter value. A rejected declaration retains its partial metadata updates.
An Ada exit runs the finish statements. -/
theorem exec_iff (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (prior : Locals) (source : Source) (info : PackageBindings.Metadata) (result : SpecificationResult) :
    body.Exec (functions calls) procedures backing (inputLocals prior source info)
      (fun store => result = projectResult store) ↔
    SpecificationExec (rawCalls calls procedures) source info result := by
  simp only [Body.Exec, show body.entry = entry from rfl, show body.guarded = none from rfl,
    show body.finish = finish from rfl, show body.iteration = iteration from rfl]
  change entry.eval (functions calls) procedures backing
    (body.declarations.foldl (Declaration.eval (functions calls)) (inputLocals prior source info))
    (nativeLoop calls procedures backing result) (fun store => result = projectResult store) (fun _ => False) ↔ _
  have loopEq : nativeLoop calls procedures backing result = fun store =>
      rawLoop (rawCalls calls procedures) result (store .source "text") (projectState store) :=
    funext (fun store => propext (loop_iff calls procedures backing result store))
  rw [loopEq, entry_meaning calls procedures backing prior source info
    (rawLoop (rawCalls calls procedures) result) (fun value => result = value) (fun _ => False)]
  unfold SpecificationExec
  have sameStart : specificationStart (rawCalls calls procedures) source info = specificationStart calls source info := rfl
  rw [sameStart]
  cases specificationStart calls source info <;> rfl

end Silver.ApplicationPackageDeclarations.SpecificationNative
