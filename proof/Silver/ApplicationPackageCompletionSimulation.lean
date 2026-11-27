module

public import Silver.ApplicationPackageCompletionLocalSimulation
public import Silver.ApplicationPackageCompletionRanges
public import Silver.ApplicationPackageCompletionFooterSimulation

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def remainingOutputs (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) : CompletionResult :=
  completionOutputs calls scope.text (atOriginal scope) scope.info scope.index scope.item state

theorem prepared_result (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) :
    resolve scope (prepareOutputs calls scope state) (finishBody calls) = remainingOutputs calls scope state := by
  dsimp only [prepareOutputs, remainingOutputs, completionOutputs, beginInitialization]
  cases outputInitializers calls scope.text scope.info (formalIndices scope.item)
    {state with frame := {state.frame with position := calls.takeToken scope.text state.frame.position (.word "begin")}} with
  | none => rfl
  | some value =>
    change resolve scope ((appendOutputs calls scope.text scope.info (formalIndices scope.item) value.frame).bind
      (fun frame => some {value with frame})) (finishBody calls) =
        match appendOutputs calls scope.text scope.info (formalIndices scope.item) value.frame with
        | none => completionFailed scope.info
        | some frame => finishBody calls scope {value with frame}
    cases appendOutputs calls scope.text scope.info (formalIndices scope.item) value.frame <;> rfl

theorem bind_observed (result : Outcome) (continuation : Locals → Option Outcome)
    (raw : CompletionContext → InitializationFrame → CompletionResult)
    (equation : ∀ locals, (continuation locals).map (fun value => observed value.locals) =
      some (raw (completionContext locals) (initialization locals))) :
    (result.bind continuation).map (fun value => observed value.locals) = some (project result raw) := by
  by_cases stop : result.returned = true <;> simp [Outcome.bind, project, stop, equation]

def outputsAndBody (calls : CompletionCalls) (locals : Locals) : Option Outcome :=
  (outputsStep calls locals).bind (fun outputs => outputs.bind (checkedBodyBlockStep calls))

theorem outputsAndBody_observed (calls : CompletionCalls) (locals : Locals) :
    (outputsAndBody calls locals).map (fun value => observed value.locals) =
      some (remainingOutputs calls (completionContext locals) (initialization locals)) := by
  rw [outputsAndBody, outputsStep_pure, Option.bind_some,
    bind_observed _ _ (finishBody calls) (bodyBlock_observed calls), project_runOutputs, prepared_result]

def remainingLocals (calls : CompletionCalls) (fuel : Nat) (scope : CompletionContext)
    (state : InitializationFrame) : Option CompletionResult :=
  completionLocals calls fuel scope.text (atOriginal scope) scope.info scope.index scope.item state

theorem localsAndBody_observed (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    ((localWhile calls fuel locals).bind fun declared => declared.bind (outputsAndBody calls)).map
      (fun value => observed value.locals) = remainingLocals calls fuel (completionContext locals) (initialization locals) := by
  have step : ((localWhile calls fuel locals).bind fun declared => declared.bind (outputsAndBody calls)).map
      (fun value => observed value.locals) = (localWhile calls fuel locals).map (fun value => project value (remainingOutputs calls)) := by
    cases localWhile calls fuel locals with
    | none => rfl
    | some value => exact bind_observed value _ _ (outputsAndBody_observed calls)
  rw [step, localWhile_project]
  unfold remainingLocals completionLocals
  congr 1

def observePrefix (outcome : Outcome) (next : CompletionContext → InitializationFrame → Option CompletionResult) :
    Option CompletionResult :=
  if outcome.returned then some (observed outcome.locals) else next (completionContext outcome.locals) (initialization outcome.locals)

theorem executeCommands_observed (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    (executeCommands calls fuel locals).map (fun value => observed value.locals) =
      observePrefix (prefixStep calls locals) (remainingLocals calls fuel) := by
  change ((prefixStep calls locals).bind (fun started => (localWhile calls fuel started).bind
    (fun declared => declared.bind (outputsAndBody calls)))).map _ = _
  by_cases stop : (prefixStep calls locals).returned = true
  · simp [Outcome.bind, observePrefix, stop]
  · simp only [Outcome.bind, observePrefix, ite_eq_right stop]
    exact localsAndBody_observed calls fuel _

def originalLocals (locals : Locals) : Prop :=
  locals .number "original" = (locals .state "globals").position ∧
  locals .stateSet "reads" = PackageBindings.emptyStateSet ∧ locals .truth "initialized" = false

theorem initialized_inputs (calls : CompletionCalls) (locals : Locals) :
    originalLocals (initializedLocals calls locals) ∧
    initializedLocals calls locals .source "text" = locals .source "text" ∧
    initializedLocals calls locals .state "globals" = locals .state "globals" ∧
    initializedLocals calls locals .metadata "info" = locals .metadata "info" := by
  dsimp only [originalLocals, initializedLocals, declarations, List.foldl, Declaration.eval,
    Declaration.names, Expr.eval, Field.get, globals]
  simp [Locals.set]

local macro "reduce_prefix_result" : tactic => `(tactic|
  (dsimp only [prefixStep, packageCompletionFuel, observePrefix, observed, initialization,
    completionContext, atOriginal, failed, completionFailed, remainingLocals, Locals.set]
   simp_all [-Nat.not_le, -Nat.not_lt, -not_and, -not_or]))

theorem prefix_result (calls : CompletionCalls) (fuel : Nat) (locals : Locals) (entry : originalLocals locals) :
    observePrefix (prefixStep calls locals) (remainingLocals calls fuel) =
      packageCompletionFuel calls fuel (locals .source "text") (locals .state "globals") (locals .metadata "info") := by
  obtain ⟨original, reads, initialized⟩ := entry
  by_cases full : (locals .metadata "info").completed ≥ (locals .metadata "info").routines.length
  · reduce_prefix_result
  · let before := locals .metadata "info"
    let signature := calls.signatureAt (locals .source "text") (locals .state "globals") before true
    let index := before.completed + 1
    let item := signature.info.routineAt index
    by_cases badHeader : signature.header.position = 0
    · dsimp [signature, before] at badHeader
      reduce_prefix_result
    · by_cases badRange : formalRangeRejected signature.info item = true
      · dsimp [signature, item, index, before] at badHeader badRange
        reduce_prefix_result
      · by_cases badFrame : (calls.routineFrame (locals .source "text") (locals .state "globals")
            signature.info index signature.header.position).position = 0
        all_goals dsimp [signature, item, before, index] at badHeader badRange badFrame
        all_goals reduce_prefix_result

theorem body_simulation (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    (body.eval (modelFunctions calls) (modelProcedures calls) fuel locals).map observed =
      packageCompletionFuel calls fuel (locals .source "text") (locals .state "globals") (locals .metadata "info") := by
  obtain ⟨entry, textEq, globalsEq, infoEq⟩ := initialized_inputs calls locals
  rw [body_meaning]
  simp only [execute, Option.map_map, Function.comp_def, executeCommands_observed, prefix_result _ _ _ entry,
    textEq, globalsEq, infoEq]

end Silver.ApplicationPackageCompletion.Native
