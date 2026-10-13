module

public import Silver.SequenceSemantics

@[expose] public section

/-! Each library call returns. Completed external replies are indexed by call
ordinal, so later calls may succeed after an earlier failure. Accepted bytes
concatenate in call order, while exit failure is sticky. A failing sequence's
bytes need not be a prefix of its entire intended output. -/

namespace Silver.Sequence

abbrev OutputEnvironments := Nat → Output.Runtime.Environment

def combineResults (first second : Output.Runtime.ProcessResult) : Output.Runtime.ProcessResult :=
  ⟨max first.status second.status, first.accepted ++ second.accepted⟩

theorem combineResults_assoc (first second third : Output.Runtime.ProcessResult) :
    combineResults (combineResults first second) third =
      combineResults first (combineResults second third) := by
  simp [combineResults, Nat.max_assoc, List.append_assoc]

def Effect.execute (environment : Output.Runtime.Environment) : Effect → Output.Runtime.ProcessResult
  | .output bytes => Output.Runtime.completeMain
      (Output.Runtime.execute environment bytes Output.Runtime.program [])
  | .reject => ⟨1, []⟩

def executeEffects (environments : OutputEnvironments) (ordinal : Nat) :
    List Effect → Output.Runtime.ProcessResult
  | [] => ⟨0, []⟩
  | effect :: rest => combineResults (effect.execute (environments ordinal))
      (executeEffects environments (ordinal + 1) rest)

def Effect.intendedBytes : Effect → Source
  | .output bytes => bytes ++ [10]
  | .reject => []

def Effect.expectedStatus : Effect → Nat
  | .output _ => 0
  | .reject => 1

def intendedEffectBytes (effects : List Effect) : Source := effects.flatMap Effect.intendedBytes

def expectedEffectStatus : List Effect → Nat
  | [] => 0
  | effect :: rest => max effect.expectedStatus (expectedEffectStatus rest)

def Effect.Outcome (environment : Output.Runtime.Environment) :
    Effect → Output.Runtime.ProcessResult → Prop
  | .reject, result => result = ⟨1, []⟩
  | .output bytes, result =>
      (result.status = 0 ∧ result.accepted = bytes ++ [10] ∧ environment.flushStatus = 0) ∨
      (result.status = 1 ∧ ∃ suffix, result.accepted ++ suffix = bytes ++ [10])

/-- A complete per-call outcome, including all calls after returning failures. -/
inductive TraceOutcome (environments : OutputEnvironments) :
    Nat → List Effect → Output.Runtime.ProcessResult → Prop
  | nil (ordinal) : TraceOutcome environments ordinal [] ⟨0, []⟩
  | cons {ordinal effect rest first following} :
      effect.Outcome (environments ordinal) first →
      TraceOutcome environments (ordinal + 1) rest following →
      TraceOutcome environments ordinal (effect :: rest) (combineResults first following)

theorem effect_execution_specified (environment : Output.Runtime.Environment) (effect : Effect) :
    effect.Outcome environment (effect.execute environment) := by
  cases effect with
  | reject => rfl
  | output bytes =>
      cases result : Output.Runtime.execute environment bytes Output.Runtime.program [] with
      | returned accepted =>
          have facts := Output.Runtime.successful_output environment bytes accepted result
          simp only [Effect.Outcome, Effect.execute, result, Output.Runtime.completeMain]
          exact Or.inl ⟨True.intro, facts.2⟩
      | failedReturn status accepted =>
          have facts := Output.Runtime.failed_output environment bytes accepted status result
          simp only [Effect.Outcome, Effect.execute, result, Output.Runtime.completeMain]
          exact Or.inr facts

theorem effects_execution_specified (environments : OutputEnvironments) (ordinal : Nat)
    (effects : List Effect) : TraceOutcome environments ordinal effects
      (executeEffects environments ordinal effects) := by
  induction effects generalizing ordinal with
  | nil => exact .nil ordinal
  | cons effect rest ih => exact .cons (effect_execution_specified _ _) (ih _)

theorem effect_outcome_bound {environment : Output.Runtime.Environment} {effect : Effect}
    {result : Output.Runtime.ProcessResult} (outcome : effect.Outcome environment result) :
    result.status ≤ 1 ∧ result.accepted.length ≤ effect.intendedBytes.length := by
  cases effect with
  | reject => cases outcome; simp [Effect.intendedBytes]
  | output bytes =>
      rcases outcome with ⟨status, accepted, _⟩ | ⟨status, rest, accepted⟩
      · simp [status, accepted, Effect.intendedBytes]
      · have lengths := congrArg List.length accepted
        simp only [List.length_append] at lengths
        simp only [Effect.intendedBytes, status, List.length_append]
        exact ⟨by decide, by omega⟩

theorem trace_outcome_bound {environments : OutputEnvironments} {ordinal : Nat}
    {effects : List Effect} {result : Output.Runtime.ProcessResult}
    (outcome : TraceOutcome environments ordinal effects result) :
    result.status ≤ 1 ∧ result.accepted.length ≤ (intendedEffectBytes effects).length := by
  induction outcome with
  | nil => simp [intendedEffectBytes]
  | @cons ordinal effect rest first following head tail ih =>
      have firstBound := effect_outcome_bound head
      simp only [combineResults, intendedEffectBytes, List.flatMap_cons, List.length_append]
      exact ⟨Nat.max_le.mpr ⟨firstBound.1, ih.1⟩, Nat.add_le_add firstBound.2 ih.2⟩

theorem healthy_effect (environment : Output.Runtime.Environment)
    (healthy : Output.Runtime.Healthy environment) {effect : Effect} (valid : effect.Valid) :
    effect.execute environment = ⟨effect.expectedStatus, effect.intendedBytes⟩ := by
  cases effect with
  | reject => rfl
  | output bytes =>
      have byteBound : ∀ byte ∈ bytes, byte ≤ 255 := by
        intro byte member
        have printable := valid.2 byte member
        simp only [Output.printable, decide_eq_true_eq] at printable
        omega
      simp only [Effect.execute, Effect.expectedStatus, Effect.intendedBytes,
        Output.Runtime.healthy_output environment healthy bytes valid.1 byteBound,
        Output.Runtime.completeMain]

theorem healthy_effects (environments : OutputEnvironments)
    (healthy : ∀ ordinal, Output.Runtime.Healthy (environments ordinal)) (ordinal : Nat)
    {effects : List Effect} (valid : EffectsValid effects) :
    executeEffects environments ordinal effects =
      ⟨expectedEffectStatus effects, intendedEffectBytes effects⟩ := by
  induction effects generalizing ordinal with
  | nil => rfl
  | cons effect rest ih =>
      rw [executeEffects, healthy_effect _ (healthy ordinal) (valid effect (by simp)),
        ih (ordinal + 1) (fun effect member => valid effect (by simp [member]))]
      rfl

theorem execute_effects_append (environments : OutputEnvironments) (ordinal : Nat)
    (first rest : List Effect) :
    executeEffects environments ordinal (first ++ rest) =
      combineResults (executeEffects environments ordinal first)
        (executeEffects environments (ordinal + first.length) rest) := by
  induction first generalizing ordinal with
  | nil => simp [executeEffects, combineResults]
  | cons effect effects ih =>
      simp [executeEffects, ih, combineResults_assoc, Nat.add_comm, Nat.add_left_comm]

def outputCount : List Effect → Nat
  | [] => 0
  | .output _ :: rest => 1 + outputCount rest
  | .reject :: rest => outputCount rest

/-- The cumulative size bound follows the actual number of output calls. -/
theorem intended_effects_bound {effects : List Effect} (valid : EffectsValid effects) :
    (intendedEffectBytes effects).length ≤ outputCount effects * (maxSourceLength + 1) := by
  induction effects with
  | nil => simp [intendedEffectBytes, outputCount]
  | cons effect rest ih =>
      have first := valid effect (by simp)
      have following := ih (fun effect member => valid effect (by simp [member]))
      cases effect with
      | reject => simpa [intendedEffectBytes, Effect.intendedBytes, outputCount] using following
      | output bytes =>
          simp only [Effect.Valid] at first
          simp only [intendedEffectBytes, List.flatMap_cons, Effect.intendedBytes,
            List.length_append, List.length_singleton, outputCount, Nat.add_mul, Nat.one_mul]
          exact Nat.add_le_add (Nat.add_le_add_right first.1 1) following

theorem accepted_effects_bound (environments : OutputEnvironments) (ordinal : Nat)
    {effects : List Effect} (valid : EffectsValid effects) :
    (executeEffects environments ordinal effects).accepted.length ≤
      outputCount effects * (maxSourceLength + 1) :=
  Nat.le_trans (trace_outcome_bound (effects_execution_specified environments ordinal effects)).2
    (intended_effects_bound valid)

/-- Earlier failure cannot be cleared by any later returning call. -/
theorem failure_sticky (environments : OutputEnvironments) (ordinal : Nat)
    (first rest : List Effect)
    (failed : (executeEffects environments ordinal first).status = 1) :
    (executeEffects environments ordinal (first ++ rest)).status = 1 := by
  rw [execute_effects_append]
  simp only [combineResults, failed]
  have bound := (trace_outcome_bound (effects_execution_specified environments
    (ordinal + first.length) rest)).1
  exact Nat.max_eq_left bound

structure Environment where
  output : OutputEnvironments
  arguments : Arguments.Runtime.Arguments

def Environment.Healthy (environment : Environment) : Prop :=
  ∀ ordinal, Output.Runtime.Healthy (environment.output ordinal)

def execute (environment : Environment) (program : Program) : Output.Runtime.ProcessResult :=
  executeEffects environment.output 0 (program.effects environment.arguments)

def intendedBytes (environment : Environment) (program : Program) : Source :=
  intendedEffectBytes (program.effects environment.arguments)

def expectedStatus (environment : Environment) (program : Program) : Nat :=
  expectedEffectStatus (program.effects environment.arguments)

def SpecifiedOutcome (environment : Environment) (program : Program)
    (result : Output.Runtime.ProcessResult) : Prop :=
  TraceOutcome environment.output 0 (program.effects environment.arguments) result

theorem execution_specified (environment : Environment) (program : Program) :
    SpecifiedOutcome environment program (execute environment program) :=
  effects_execution_specified _ _ _

theorem healthy_execution {program : Program} (valid : program.Valid)
    (environment : Environment) (healthy : environment.Healthy) :
    execute environment program = ⟨expectedStatus environment program, intendedBytes environment program⟩ :=
  healthy_effects _ healthy _ (program_execution_valid valid environment.arguments).2

end Silver.Sequence
