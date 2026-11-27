module

public import Silver.ApplicationPackageCompletionProjection

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

def localReader (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) : LocalStep :=
  ApplicationPackageBodies.localStep calls scope.text scope.info scope.item state

def LocalMatches (scope : CompletionContext) (native : Outcome) (raw : LocalStep) : Prop :=
  if native.returned then raw = .failed ∧ observed native.locals = completionFailed scope.info
  else raw = .continued (initialization native.locals) ∧ completionContext native.locals = scope

local macro "reduce_local_match" : tactic => `(tactic|
  (dsimp only [LocalMatches, localReader, localStep, ApplicationPackageBodies.localStep,
      initialization, completionContext, observed, completionFailed, failed, Locals.set]
   simp_all [-Nat.not_le, -Nat.not_lt, -List.any_eq_true, -List.any_eq_false, localTest]))

theorem localStep_matches (calls : CompletionCalls) (locals : Locals) (active : localTest calls locals = true) :
    LocalMatches (completionContext locals) (localStep calls locals)
      (localReader calls (completionContext locals) (initialization locals)) := by
  by_cases collision : (formalIndices (locals .routine "item")).any (fun index =>
    calls.sameName (locals .source "text")
      ⟨calls.skipAt (locals .source "text") (locals .state "frame").position,
        calls.nameAfter (locals .source "text") (calls.skipAt (locals .source "text") (locals .state "frame").position)⟩
      ((locals .metadata "info").parameterAt index).bodyName) = true
  · reduce_local_match
  · by_cases stalled : (calls.objectAt (locals .source "text") (locals .state "frame")
      (locals .metadata "info") true).frame.position ≤ (locals .state "frame").position
    · reduce_local_match
    · reduce_local_match

theorem localWhile_project (calls : CompletionCalls) (fuel : Nat) (locals : Locals)
    (next : CompletionContext → InitializationFrame → CompletionResult) :
    (localWhile calls fuel locals).map (fun value => project value next) =
      (localsFuel (localReader calls (completionContext locals)) fuel (initialization locals)).map
        (fun value => resolve (completionContext locals) value next) := by
  induction fuel generalizing locals with
  | zero => rfl
  | succ fuel ih =>
    change ((if localTest calls locals then
      (localStep calls locals).bind (localWhile calls fuel)
      else some ⟨locals, false⟩).map _) = _
    by_cases active : localTest calls locals = true
    · rw [ite_eq_left active]
      have matchStep := localStep_matches calls locals active
      by_cases returned : (localStep calls locals).returned = true
      · simp only [LocalMatches, returned, ↓reduceIte] at matchStep
        rw [localsFuel, matchStep.1]
        simp [Outcome.bind, project, returned, matchStep.2, resolve]
      · simp only [LocalMatches, ite_eq_right returned] at matchStep
        rw [localsFuel, matchStep.1]
        simp only [Outcome.bind, ite_eq_right returned, ih, matchStep.2]
    · have beginToken : calls.takeToken (locals .source "text") (locals .state "frame").position (.word "begin") ≠ 0 := by
        simpa [localTest] using active
      have completed : localReader calls (completionContext locals) (initialization locals) =
          .finished (initialization locals) := by
        simp [localReader, ApplicationPackageBodies.localStep, completionContext, initialization, beginToken]
      rw [ite_eq_right active, localsFuel, completed]
      rfl

end Silver.ApplicationPackageCompletion.Native
