module

public import Silver.ApplicationPackageMainRecursiveChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

private theorem continued_tests {readers : Readers} {source : Statement.Input} {stop : BodyStop}
    {required : Bool} {state next : TailState}
    (step : Tail.reader readers.tail (tailContext source stop required) state = .continued next) :
    state.value.scan.position ≠ 0 ∧ readers.tail.atBodyStop source.text state.value.scan.position stop = false := by
  unfold Tail.reader tailStep at step
  split at step
  · rename_i guard
    exact ⟨guard.1, by simpa only [Bool.not_eq_true', tailContext] using guard.2⟩
  · split at step <;> contradiction

/-- Fold the original native tail execution into source syntax and checking.
The statement callback is the local cursor-induction hypothesis; every next
native domain is obtained from the already established native return contract.
It is not retained as a source-meaning or compiler-admission premise. -/
theorem tailExecution_decoded {readers environment cutoff source stop required state result}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (decode : ∀ value, NativeDomain (atInput source value) →
      MainScope environment cutoff (atInput source value) → source.input.scan.position ≤ value.scan.position →
      ((sourceReaders readers).statementResult (atInput source value)).scan.position ≠ 0 →
      ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) (atInput source value)
          ((sourceReaders readers).statementResult (atInput source value)) code ∧
        MainChecked environment (atInput source value) ((sourceReaders readers).statementResult (atInput source value)) code)
    (execution : TailExecution (Tail.reader (sourceReaders readers).tail (tailContext source stop required)) state result)
    (legal : NativeDomain (atInput source state.value))
    (scope : MainScope environment cutoff (atInput source state.value))
    (lower : source.input.scan.position ≤ state.value.scan.position)
    (accepted : result.scan.position ≠ 0) :
    ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment) (atInput source state.value)
        stop required state.seen result code ∧
      MainChecked environment (atInput source state.value) result code := by
  induction execution with
  | @returned state result step =>
    obtain ⟨rfl, stopped, needed⟩ := tailStep_accepted step accepted
    exact ⟨[], .done accepted stopped needed, MainChecked.empty environment (atInput source state.value)⟩
  | @continued state next result step execution ih =>
    have tests := continued_tests step
    obtain ⟨advanced, seen, nextEq⟩ := tailStep_progress step
    change next.value = (sourceReaders readers).statementResult (atInput source state.value) at nextEq
    have firstPresent : ((sourceReaders readers).statementResult (atInput source state.value)).scan.position ≠ 0 := by
      rw [← nextEq]
      omega
    obtain ⟨head, original, checked⟩ := decode state.value legal scope lower firstPresent
    have native := (Equations.outcomes (readers := sourceReaders readers) equations legal scope.typed).1
    have nextScan : ScanDomain source.text source.context next.value.scan := by
      rw [nextEq]
      exact native.scan
    have nextLegal : NativeDomain (atInput source next.value) := legal.replaceInput nextScan
    have nextScope : MainScope environment cutoff (atInput source next.value) :=
      scope.atInput next.value (Nat.le_of_lt advanced)
    obtain ⟨rest, following, final⟩ := ih nextLegal nextScope (Nat.le_trans lower (Nat.le_of_lt advanced)) accepted
    rw [seen] at following
    rw [← nextEq] at original checked
    exact ⟨head ++ rest, .next tests.1 tests.2 nextEq.symm original advanced following,
      checked.append final⟩

theorem main_tail_decoded {readers environment cutoff source stop required}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (legal : NativeDomain source) (scope : MainScope environment cutoff source)
    (decode : ∀ value, NativeDomain (atInput source value) →
      MainScope environment cutoff (atInput source value) → source.input.scan.position ≤ value.scan.position →
      ((sourceReaders readers).statementResult (atInput source value)).scan.position ≠ 0 →
      ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) (atInput source value)
          ((sourceReaders readers).statementResult (atInput source value)) code ∧
        MainChecked environment (atInput source value) ((sourceReaders readers).statementResult (atInput source value)) code)
    (accepted : ((sourceReaders readers).tailResult source stop required).scan.position ≠ 0) :
    ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment) source stop required false
        ((sourceReaders readers).tailResult source stop required) code ∧
      MainChecked environment source ((sourceReaders readers).tailResult source stop required) code := by
  obtain ⟨_, evaluated⟩ := equations.tail_model legal stop required
  exact tailExecution_decoded equations decode (tailFuel_sound evaluated) legal scope (Nat.le_refl _) accepted

end Silver.ApplicationPackageBodies.SourceSyntax
