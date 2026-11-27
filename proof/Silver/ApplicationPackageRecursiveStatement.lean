module

public import Silver.ApplicationPackageRecursiveArms

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

/-- Accepted control statements decode every original child tail. The local
callback ranges over the derived branch and iterator contexts, always at a
strictly later source cursor. -/
theorem statementReading_outcome {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} {result : ApplicationScan}
    (legal : NativeDomain source) (typed : source.info.Typed)
    (decode : ∀ context value, NativeDomain (atContext source context value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      TailOutcome (nativeReaders readers) (atContext source context value) stop required)
    (reading : Statement.Reading (nativeStatementReaders readers.statement) source result)
    (present : result.scan.position ≠ 0) :
    ScanDomain source.text source.context result.scan ∧
      result.allowProcedureCalls = source.input.allowProcedureCalls ∧
      StatementTree (nativeReaders readers) source result := by
  cases reading with
  | basic inputPresent noIf noFor =>
    have basic := native_basic_contract (calls := readers.basic) legal typed
    have linked := equations.basic_model legal
    dsimp only [nativeReaders] at linked
    refine ⟨?_, ?_, .basic inputPresent noIf noFor present⟩
    · rw [linked]
      exact basic.1
    · rw [linked]
      exact basic.2.2.1
  | @conditional entries state result inputPresent keyword arms closing =>
    have first := Expressions.model_fixed_advances source.text source.input.scan.position "if" true
      legal.scan.position (by decide) keyword
    obtain ⟨stateLegal, statePermission, stateLower, armsTree⟩ :=
      armsReading_outcome equations (decode source.context) arms
        (ArmsDomain.initial legal) (Nat.le_of_lt first)
    obtain ⟨branchScan, branchPermission, elseTree⟩ :=
      else_outcome (decode source.context) stateLegal stateLower closing.branchPresent
    refine ⟨closing_scan_domain stateLegal branchScan closing, ?_,
      .conditional inputPresent keyword armsTree elseTree closing⟩
    rw [closing.resultEq]
    exact branchPermission.trans statePermission
  | @iteration iteration result inputPresent noIf keyword loop =>
    have childLegal := legal.loopInput loop.header loop.advances
    have child := decode _ _ childLegal loop.advances .endOnly true
    have childPresent : ((nativeReaders readers).tailResult
        (atContext source (Statement.innerContext source iteration)
          (Statement.innerInput source iteration (Statement.widened (nativeStatementReaders readers.statement) source iteration)))
        .endOnly true).scan.position ≠ 0 := loop.bodyPresent
    refine ⟨loop_scan_domain legal loop child.scan, ?_,
      .iteration inputPresent noIf keyword loop (child.tree childPresent)⟩
    rw [loop.resultEq]
    exact forHeader_permission loop.header

/-- Complete native statement output and accepted-source tree from its typed
body equation. Rejections return either the original invalidated scan or the
already established complete Basic return contract. -/
theorem Equations.statement_outcome {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed)
    (decode : ∀ context value, NativeDomain (atContext source context value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      TailOutcome (nativeReaders readers) (atContext source context value) stop required) :
    StatementOutcome (nativeReaders readers) source := by
  by_cases present : ((nativeReaders readers).statementResult source).scan.position ≠ 0
  · obtain ⟨scan, permission, tree⟩ := statementReading_outcome equations legal typed decode
      (equations.statement_reading legal present) present
    exact ⟨scan, permission, fun _ => tree⟩
  · have rejected : ((nativeReaders readers).statementResult source).scan.position = 0 := by simpa using present
    obtain ⟨_, evaluated⟩ := equations.statement_model legal
    rcases Statement.statementFuel_rejected evaluated rejected with invalid | basic
    · refine ⟨?_, ?_, fun impossible => False.elim (impossible rejected)⟩
      · rw [invalid]
        exact legal.scan.invalid
      · rw [invalid]
        rfl
    · have contract := native_basic_contract (calls := readers.basic) legal typed
      rw [equations.basic_model legal] at basic
      refine ⟨?_, ?_, fun impossible => False.elim (impossible rejected)⟩
      · rw [basic]
        exact contract.1
      · rw [basic]
        exact contract.2.2.1

end Silver.ApplicationPackageBodies.Recursive
