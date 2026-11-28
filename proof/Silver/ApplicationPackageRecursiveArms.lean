module

public import Silver.ApplicationPackageRecursiveTail

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

theorem readArm_outcome {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} {before : Statement.Arms} {read : Statement.ReadArm}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      TailOutcome (nativeReaders readers) (atInput source value) stop required)
    (legal : ArmsDomain source before)
    (lower : source.input.scan.position ≤ before.value.scan.position)
    (parsed : Statement.readArm (nativeStatementReaders readers.statement) source before = some read) :
    ScanDomain source.text source.context read.branch.scan ∧
      read.branch.allowProcedureCalls = before.value.allowProcedureCalls ∧
      before.value.scan.position < read.branch.scan.position ∧
      TailTree (nativeReaders readers)
        (atInput source (Statement.thenInput (nativeStatementReaders readers.statement) source before
          (Statement.conditionFor (nativeStatementReaders readers.statement) source before)))
        .arm true false read.branch := by
  have observed := Statement.readArm_evaluation parsed
  have entryLegal := legal.value.thenInput (calls := nativeStatementReaders readers.statement) rfl rfl
  have child := decode _ entryLegal (Nat.lt_of_le_of_lt lower observed.thenAdvanced) .arm true
  have branchEq : (nativeReaders readers).tailResult
      (atInput source (Statement.thenInput (nativeStatementReaders readers.statement) source before
        (Statement.conditionFor (nativeStatementReaders readers.statement) source before))) .arm true =
      read.branch := observed.branchRead
  have present : ((nativeReaders readers).tailResult
      (atInput source (Statement.thenInput (nativeStatementReaders readers.statement) source before
        (Statement.conditionFor (nativeStatementReaders readers.statement) source before))) .arm true).scan.position ≠ 0 :=
    branchEq.symm ▸ observed.branchPresent
  have progress := equations.tail_progress entryLegal .arm true present
  rw [branchEq] at progress
  refine ⟨branchEq ▸ child.scan, branchEq ▸ child.permission,
    Nat.lt_of_lt_of_le observed.thenAdvanced progress.1, branchEq ▸ child.tree present⟩

theorem finishArm_position {calls : Statement.Calls} {source : Statement.Input}
    {before : Statement.Arms} {read : Statement.ReadArm} {after : Statement.Arms}
    (parsed : Statement.readArm calls source before = some read)
    (branch : before.value.scan.position < read.branch.scan.position)
    (finished : Statement.armState (Statement.finishArm calls source read) = some after) :
    before.value.scan.position < after.value.scan.position := by
  have observed := Statement.readArm_evaluation parsed
  unfold Statement.finishArm at finished
  dsimp only at finished
  split at finished
  · simp only [Statement.armState, Option.some.injEq] at finished
    cases finished
    exact branch
  · split at finished
    · contradiction
    · rename_i advanced
      simp only [Statement.armState, Option.some.injEq] at finished
      cases finished
      change before.value.scan.position < _
      rw [← observed.first]
      exact Nat.lt_of_not_ge advanced

/-- Fold the original ordered ELSIF history. Every child domain is derived
from the preceding false refinement, and every child is decoded at a strictly
later original cursor. The callback is the local mutual induction hypothesis. -/
theorem armsReading_outcome {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} {before after : Statement.Arms} {entries}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      TailOutcome (nativeReaders readers) (atInput source value) stop required)
    (reading : Statement.ArmsReading (nativeStatementReaders readers.statement) source before entries after) :
    ArmsDomain source before → source.input.scan.position ≤ before.value.scan.position →
    ArmsDomain source after ∧ after.value.allowProcedureCalls = before.value.allowProcedureCalls ∧
      source.input.scan.position < after.value.scan.position ∧
      ArmsTree (nativeReaders readers) source before after := by
  induction reading with
  | @last before read after parsed finished =>
    intro legal lower
    obtain ⟨scan, permission, advanced, tree⟩ := readArm_outcome equations decode legal lower parsed
    have state : Statement.armState
        (Statement.finishArm (nativeStatementReaders readers.statement) source read) = some after := by
      rw [finished]
      rfl
    exact ⟨legal.finish parsed scan state, (finishArm_permission state).trans permission,
      Nat.lt_of_le_of_lt lower (finishArm_position parsed advanced state), .last parsed tree finished⟩
  | @next before read after entries final parsed finished _ ih =>
    intro legal lower
    obtain ⟨scan, permission, advanced, tree⟩ := readArm_outcome equations decode legal lower parsed
    have state : Statement.armState
        (Statement.finishArm (nativeStatementReaders readers.statement) source read) = some after := by
      rw [finished]
      rfl
    have afterLegal := legal.finish parsed scan state
    have afterLower := Nat.lt_of_le_of_lt lower (finishArm_position parsed advanced state)
    obtain ⟨finalLegal, finalPermission, finalLower, following⟩ := ih afterLegal (Nat.le_of_lt afterLower)
    exact ⟨finalLegal, finalPermission.trans ((finishArm_permission state).trans permission), finalLower,
      .next parsed tree finished following⟩

theorem else_outcome {readers : Readers} {source : Statement.Input} {state : Statement.Arms}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      TailOutcome (nativeReaders readers) (atInput source value) stop required)
    (legal : ArmsDomain source state)
    (lower : source.input.scan.position < state.value.scan.position)
    (present : (Statement.elseResult (nativeStatementReaders readers.statement) source state).scan.position ≠ 0) :
    ScanDomain source.text source.context
        (Statement.elseResult (nativeStatementReaders readers.statement) source state).scan ∧
      (Statement.elseResult (nativeStatementReaders readers.statement) source state).allowProcedureCalls =
        state.value.allowProcedureCalls ∧ ElseTree (nativeReaders readers) source state := by
  by_cases missing : Statement.elsePosition (nativeStatementReaders readers.statement) source state = 0
  · have same : Statement.elseResult (nativeStatementReaders readers.statement) source state = state.value := by
      simp only [Statement.elseResult, missing, ne_self_iff_false, ite_false]
    exact ⟨same.symm ▸ legal.value.scan, same.symm ▸ rfl, .absent missing⟩
  · have advance := Expressions.model_fixed_advances source.text state.value.scan.position "else" true
      legal.value.scan.position (by decide) missing
    have childLegal := legal.value.atPosition
      (fixedAfter_result_bound source.text state.value.scan.position "else" true (by decide))
    have child := decode _ childLegal (Nat.lt_trans lower advance) .endOnly true
    have same : Statement.elseResult (nativeStatementReaders readers.statement) source state =
        (nativeReaders readers).tailResult
          (atInput source (Statement.atPosition state.value
            (Statement.elsePosition (nativeStatementReaders readers.statement) source state))) .endOnly true := by
      rw [Statement.elseResult, ite_eq_left missing]
      rfl
    have childPresent := same ▸ present
    exact ⟨same.symm ▸ child.scan, same.symm ▸ child.permission,
      .present missing (same.symm ▸ child.tree childPresent)⟩

end Silver.ApplicationPackageBodies.Recursive
