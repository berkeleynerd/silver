module

public import Silver.ApplicationPackageCompletionProjection

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies Compose

set_option backward.dsimp.instances true

def sourceIndices (scope : CompletionContext) : List Nat :=
  (List.range (scope.item.formalFirst + scope.item.count - 1 + 1 - scope.item.formalFirst)).map (scope.item.formalFirst + ·)

def rangeOutcome (step : Locals → Outcome) (locals : Locals) : Outcome :=
  (foldOutcomes step (rangeValues locals) locals).restore (fun updated => updated.set .number "i" (locals .number "i"))

theorem rangeStep_pure (step : Locals → Outcome) (locals : Locals) :
    rangeStep step locals = some (rangeOutcome step locals) := by
  simp only [rangeStep, rangeOutcome, forLocals_outcomes, Option.map_some]

theorem project_restoreIndex (outcome : Outcome) (index : Nat)
    (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (outcome.restore (fun updated => updated.set .number "i" index)) next = project outcome next := by
  simp [project, Outcome.restore, completionContext, initialization, observed, Locals.set]

theorem project_range (step : Locals → Outcome)
    (raw : CompletionContext → Nat → InitializationFrame → Option InitializationFrame)
    (one : ∀ locals next, project (step locals) next = resolve (completionContext locals)
      (raw (completionContext locals) (locals .number "i") (initialization locals)) next)
    (locals : Locals) (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (rangeOutcome step locals) next = resolve (completionContext locals)
      (foldInitializations raw (completionContext locals) (sourceIndices (completionContext locals)) (initialization locals)) next := by
  rw [rangeOutcome, project_restoreIndex, project_fold step raw one]
  rfl

def runOutputs (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let updated := afterBegin calls locals
  if (locals .routine "item").count > 0 then
    let read := rangeOutcome (readStep calls) updated
    if read.returned then read else rangeOutcome (appendStep calls) read.locals
  else ⟨updated, false⟩

theorem outputsStep_pure (calls : CompletionCalls) (locals : Locals) :
    outputsStep calls locals = some (runOutputs calls locals) := by
  simp only [outputsStep, runOutputs, rangeStep_pure, Option.bind_some, Outcome.bind]
  split <;> simp_all
  split <;> rfl

def beginInitialization (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) : InitializationFrame :=
  {state with frame := {state.frame with position := calls.takeToken scope.text state.frame.position (.word "begin")}}

def prepareOutputs (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) : Option InitializationFrame := do
  let indices := formalIndices scope.item
  let read ← outputInitializers calls scope.text scope.info indices (beginInitialization calls scope state)
  let frame ← appendOutputs calls scope.text scope.info indices read.frame
  pure {read with frame}

theorem project_runOutputs (calls : CompletionCalls) (locals : Locals)
    (next : CompletionContext → InitializationFrame → CompletionResult) :
    project (runOutputs calls locals) next =
      resolve (completionContext locals) (prepareOutputs calls (completionContext locals) (initialization locals)) next := by
  let scope := completionContext locals
  let updated := afterBegin calls locals
  let read := rangeOutcome (readStep calls) updated
  let append := fun scope state => resolve scope
    (foldInitializations (appendInitialization calls) scope (sourceIndices scope) state) next
  have updateScope : completionContext updated = scope := by simp [updated, scope, afterBegin, completionContext]
  have updateState : initialization updated = beginInitialization calls scope (initialization locals) := by
    simp [updated, scope, afterBegin, beginInitialization, completionContext, initialization]
  by_cases positive : (locals .routine "item").count > 0
  · have indices : sourceIndices scope = formalIndices scope.item := by
      exact rangeValues_eq locals positive
    have composition : project (runOutputs calls locals) next = project read append := by
      change project (if (locals .routine "item").count > 0 then
        (if read.returned then read else rangeOutcome (appendStep calls) read.locals) else ⟨updated, false⟩) next = _
      rw [ite_eq_left positive]
      by_cases stop : read.returned = true
      · simp [project, stop]
      · rw [ite_eq_right stop, project_range (appendStep calls) (appendInitialization calls) (project_append calls)]
        simp [project, stop, append]
    rw [composition, project_range (readStep calls) (readInitialization calls) (project_read calls) updated]
    rw [updateScope, updateState, indices, folded_reads]
    change resolve scope _ append = resolve scope (prepareOutputs calls scope (initialization locals)) next
    dsimp only [prepareOutputs]
    cases outputInitializers calls scope.text scope.info (formalIndices scope.item)
      (beginInitialization calls scope (initialization locals)) with
    | none => rfl
    | some value =>
      change resolve scope (foldInitializations _ scope (sourceIndices scope) value) next = _
      rw [indices, folded_appends]
      change resolve scope _ next = resolve scope ((appendOutputs calls scope.text scope.info
        (formalIndices scope.item) value.frame).bind (fun frame => some {value with frame})) next
      cases appendOutputs calls scope.text scope.info (formalIndices scope.item) value.frame <;> rfl
  · have empty : scope.item.count = 0 := by change (locals .routine "item").count = 0; omega
    change project (if (locals .routine "item").count > 0 then _ else ⟨updated, false⟩) next =
      resolve scope (prepareOutputs calls scope (initialization locals)) next
    rw [ite_eq_right positive]
    change next (completionContext updated) (initialization updated) = _
    rw [updateScope, updateState]
    simp [prepareOutputs, formalIndices, empty, outputInitializers, appendOutputs, resolve]

end Silver.ApplicationPackageCompletion.Native
