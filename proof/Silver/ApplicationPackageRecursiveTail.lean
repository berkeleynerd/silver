module

public import Silver.ApplicationPackageRecursiveBranchDomain

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

structure StatementOutcome (readers : Readers) (source : Statement.Input) : Prop where
  scan : ScanDomain source.text source.context (readers.statementResult source).scan
  permission : (readers.statementResult source).allowProcedureCalls = source.input.allowProcedureCalls
  tree : (readers.statementResult source).scan.position ≠ 0 →
    StatementTree readers source (readers.statementResult source)

structure TailOutcome (readers : Readers) (source : Statement.Input) (stop : BodyStop) (required : Bool) : Prop where
  scan : ScanDomain source.text source.context (readers.tailResult source stop required).scan
  permission : (readers.tailResult source stop required).allowProcedureCalls = source.input.allowProcedureCalls
  tree : (readers.tailResult source stop required).scan.position ≠ 0 →
    TailTree readers source stop required false (readers.tailResult source stop required)

private theorem continued_tests {readers : Readers} {source : Statement.Input} {stop : BodyStop}
    {required : Bool} {state next : TailState}
    (step : Tail.reader readers.tail (tailContext source stop required) state = .continued next) :
    state.value.scan.position ≠ 0 ∧ readers.tail.atBodyStop source.text state.value.scan.position stop = false := by
  unfold Tail.reader tailStep at step
  split at step
  · rename_i guard
    exact ⟨guard.1, by simpa only [Bool.not_eq_true', tailContext] using guard.2⟩
  · split at step <;> contradiction

/-- The original tail loop composes native domains and source trees. The
statement premise is the sole local induction hypothesis; it is instantiated
by the mutually recursive original-cursor proof, not retained in SourceMeaning. -/
theorem tailExecution_outcome {readers : Readers} {source : Statement.Input} {stop : BodyStop}
    {required : Bool} {state : TailState} {result : ApplicationScan}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position ≤ value.scan.position → StatementOutcome readers (atInput source value))
    (execution : TailExecution (Tail.reader readers.tail (tailContext source stop required)) state result) :
    NativeDomain (atInput source state.value) → source.input.scan.position ≤ state.value.scan.position →
    ScanDomain source.text source.context result.scan ∧
      result.allowProcedureCalls = state.value.allowProcedureCalls ∧
      (result.scan.position ≠ 0 → TailTree readers (atInput source state.value) stop required state.seen result) := by
  induction execution with
  | @returned state result step =>
    intro legal lower
    by_cases present : result.scan.position ≠ 0
    · obtain ⟨rfl, stopped, needed⟩ := tailStep_accepted step present
      exact ⟨legal.scan, rfl, fun _ => .done present stopped needed⟩
    · unfold Tail.reader tailStep at step
      split at step
      · have first := decode state.value legal lower
        dsimp only at step
        split at step
        · cases step
          exact ⟨first.scan.invalid, first.permission, fun impossible => False.elim (impossible rfl)⟩
        · contradiction
      · split at step
        · cases step
          exact ⟨legal.scan.invalid, rfl, fun impossible => False.elim (impossible rfl)⟩
        · cases step
          exact ⟨legal.scan, rfl, fun impossible => False.elim (present impossible)⟩
  | @continued state next result step _ ih =>
    intro legal lower
    have tests := continued_tests step
    obtain ⟨advanced, seen, nextEq⟩ := tailStep_progress step
    change next.value = readers.statementResult (atInput source state.value) at nextEq
    have first := decode state.value legal lower
    have nextScan : ScanDomain source.text source.context next.value.scan := by
      rw [nextEq]
      exact first.scan
    have nextLegal : NativeDomain (atInput source next.value) := legal.replaceInput nextScan
    have nextPermission : next.value.allowProcedureCalls = state.value.allowProcedureCalls := by
      rw [nextEq]
      exact first.permission
    obtain ⟨valid, permission, following⟩ := ih nextLegal (Nat.le_trans lower (Nat.le_of_lt advanced))
    refine ⟨valid, permission.trans nextPermission, ?_⟩
    intro present
    have rest := following present
    rw [seen] at rest
    have firstPresent : (readers.statementResult (atInput source state.value)).scan.position ≠ 0 := by
      rw [← nextEq]
      omega
    exact .next tests.1 tests.2 nextEq.symm (nextEq.symm ▸ first.tree firstPresent) advanced rest

theorem Equations.tail_outcome {readers : Readers} (equations : Equations readers NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (stop : BodyStop) (required : Bool)
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position ≤ value.scan.position → StatementOutcome readers (atInput source value)) :
    TailOutcome readers source stop required := by
  obtain ⟨_, evaluated⟩ := equations.tail_model legal stop required
  obtain ⟨valid, permission, tree⟩ := tailExecution_outcome decode (tailFuel_sound evaluated) legal (Nat.le_refl _)
  exact ⟨valid, permission, tree⟩

end Silver.ApplicationPackageBodies.Recursive
