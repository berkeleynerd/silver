module

public import Silver.ApplicationPackageCompletionInterpretation

@[expose] public section

/-! Observe the original in-out parameters at every early return. Between
phases, the projection retains all inputs used by the remainder of Completion. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure CompletionContext where
  text : Source
  globals : ParserState
  original : Nat
  info : PackageBindings.Metadata
  index : Nat
  item : PackageBindings.Routine

def completionContext (locals : Locals) : CompletionContext :=
  ⟨locals .source "text", locals .state "globals", locals .number "original",
    locals .metadata "info", locals .number "index", locals .routine "item"⟩

def initialization (locals : Locals) : InitializationFrame :=
  ⟨locals .state "frame", locals .stateSet "reads", locals .truth "initialized"⟩

def observed (locals : Locals) : CompletionResult := ⟨locals .state "globals", locals .metadata "info"⟩

def project (outcome : Outcome) (next : CompletionContext → InitializationFrame → CompletionResult) :
    CompletionResult :=
  if outcome.returned then observed outcome.locals else next (completionContext outcome.locals) (initialization outcome.locals)

def resolve (scope : CompletionContext) (value : Option InitializationFrame)
    (next : CompletionContext → InitializationFrame → CompletionResult) : CompletionResult :=
  match value with
  | none => completionFailed scope.info
  | some state => next scope state

local macro "reduce_read_projection" : tactic => `(tactic|
  (dsimp only [readStep, outputInitializer, initialization, readContextStep, readValueAfter, readContext,
     project, resolve, failed, observed, completionFailed, completionContext, Locals.set]
   simp_all [initializerFollowing, initializerAfter, initializerFirst, readContext]))

theorem project_read (calls : CompletionCalls) (locals : Locals)
    (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (readStep calls locals) next =
      resolve (completionContext locals)
        (outputInitializer calls (locals .source "text") (locals .metadata "info")
          ((locals .metadata "info").parameterAt (locals .number "i")) (initialization locals)) next := by
  by_cases outputMode : ((locals .metadata "info").parameterAt (locals .number "i")).mode = .output
  · cases valid : calls.validName (locals .source "text")
      ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
    · reduce_read_projection
    · cases named : calls.sameName (locals .source "text")
        ⟨calls.skipAt (locals .source "text") (locals .state "frame").position,
          calls.nameAfter (locals .source "text")
            (calls.skipAt (locals .source "text") (locals .state "frame").position)⟩
        ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
      · reduce_read_projection
      · by_cases stalled : initializerFollowing calls locals ≤ (locals .state "frame").position
        · reduce_read_projection
        · reduce_read_projection
          have advances : ¬ initializerFollowing calls locals ≤ (locals .state "frame").position := by
            simp only [initializerFollowing, initializerAfter, initializerFirst, readContext]
            omega
          simp only [initializerFollowing, initializerAfter, initializerFirst, readContext] at advances
          simp [advances]
  · reduce_read_projection

def appendInitialization (calls : CompletionCalls) (scope : CompletionContext) (index : Nat)
    (state : InitializationFrame) : Option InitializationFrame :=
  (appendOutput calls scope.text (scope.info.parameterAt index) state.frame).map
    (fun frame => {state with frame})

theorem project_append (calls : CompletionCalls) (locals : Locals)
    (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (appendStep calls locals) next =
      resolve (completionContext locals)
        (appendInitialization calls (completionContext locals) (locals .number "i") (initialization locals)) next := by
  simp only [appendStep, appendInitialization, appendOutput, completionContext, initialization]
  split <;> simp_all [project, resolve, failed, observed, completionFailed, completionContext, initialization, Locals.set]
  all_goals repeat' first | split <;> simp_all

def readInitialization (calls : CompletionCalls) (scope : CompletionContext) (index : Nat)
    (state : InitializationFrame) : Option InitializationFrame :=
  outputInitializer calls scope.text scope.info (scope.info.parameterAt index) state

def foldInitializations (step : CompletionContext → Nat → InitializationFrame → Option InitializationFrame)
    (scope : CompletionContext) : List Nat → InitializationFrame → Option InitializationFrame
  | [], state => some state
  | index :: rest, state => (step scope index state).bind (foldInitializations step scope rest)

def foldOutcomes (step : Locals → Outcome) : List Nat → Locals → Outcome
  | [], locals => ⟨locals, false⟩
  | index :: rest, locals =>
    let result := step (locals.set .number "i" index)
    if result.returned then result else foldOutcomes step rest result.locals

theorem forLocals_outcomes (step : Locals → Outcome) (indices : List Nat) (locals : Locals) :
    forLocals (fun current => some (step current)) "i" indices locals = some (foldOutcomes step indices locals) := by
  induction indices generalizing locals with
  | nil => rfl
  | cons index rest ih =>
    simp only [forLocals, foldOutcomes, Option.bind_some, Outcome.bind]
    split <;> simp_all

theorem project_fold (step : Locals → Outcome)
    (raw : CompletionContext → Nat → InitializationFrame → Option InitializationFrame)
    (one : ∀ locals next, project (step locals) next = resolve (completionContext locals)
      (raw (completionContext locals) (locals .number "i") (initialization locals)) next)
    (indices : List Nat) (locals : Locals) (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (foldOutcomes step indices locals) next =
      resolve (completionContext locals) (foldInitializations raw (completionContext locals) indices (initialization locals)) next := by
  induction indices generalizing locals with
  | nil => rfl
  | cons index rest ih =>
    let first := step (locals.set .number "i" index)
    let remaining := fun scope state => resolve scope (foldInitializations raw scope rest state) next
    have bind : project (foldOutcomes step (index :: rest) locals) next = project first remaining := by
      change project (if first.returned then first else foldOutcomes step rest first.locals) next = project first remaining
      by_cases returned : first.returned = true
      · simp [project, returned]
      · rw [ite_eq_right returned, ih]
        simp [project, remaining, returned]
    rw [bind, one]
    have sameContext : completionContext (locals.set .number "i" index) = completionContext locals := by
      simp [completionContext, Locals.set]
    have sameState : initialization (locals.set .number "i" index) = initialization locals := by
      simp [initialization, Locals.set]
    rw [sameContext, sameState, Locals.set_get_same]
    simp only [foldInitializations]
    cases raw (completionContext locals) index (initialization locals) <;> rfl

theorem folded_reads (calls : CompletionCalls) (scope : CompletionContext) (indices : List Nat) (state : InitializationFrame) :
    foldInitializations (readInitialization calls) scope indices state =
      outputInitializers calls scope.text scope.info indices state := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih => simp only [foldInitializations, readInitialization, outputInitializers, funext ih]

theorem folded_appends (calls : CompletionCalls) (scope : CompletionContext) (indices : List Nat) (state : InitializationFrame) :
    foldInitializations (appendInitialization calls) scope indices state =
      (appendOutputs calls scope.text scope.info indices state.frame).map (fun frame => {state with frame}) := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih =>
    simp only [foldInitializations, appendInitialization, appendOutputs]
    cases appendOutput calls scope.text (scope.info.parameterAt index) state.frame <;> simp [ih]

end Silver.ApplicationPackageCompletion.Native
