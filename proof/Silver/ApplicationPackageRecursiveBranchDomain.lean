module

public import Silver.ApplicationPackageBasicContract
public import Silver.ApplicationPackageConditionalChecking
public import Silver.ApplicationPackageRecursiveFailure

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

/-- The canonical interpretations of the already-bound primitive readers.
The three mutually recursive native calls remain the original dictionaries. -/
def nativeStatementReaders (calls : Statement.Calls) : Statement.Calls :=
  Statement.loopHeaderReaders {calls with
    readCondition := fun text context position facts => Predicate.readCondition text context position facts
    joinInto := ActiveFlow.join}

def nativeReaders (readers : Readers) : Readers :=
  {readers with
    basic := nativeBasicReaders readers.basic
    statement := nativeStatementReaders readers.statement}

structure ArmsDomain (source : Statement.Input) (state : Statement.Arms) : Prop where
  value : NativeDomain (atInput source state.value)
  yesPath : state.yes.path.Bounded
  yesFlow : ScalarMetadata.FlowReady source.context.scalarNames source.context.declarationCount state.yes

theorem ScanDomain.joinFacts {text : Source} {context : ParseContext} {value : ApplicationScan}
    (valid : ScanDomain text context value.scan)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    {other : ActiveFlow} (path : other.path.Bounded)
    (flow : ScalarMetadata.FlowReady context.scalarNames context.declarationCount other) :
    ScanDomain text context (Statement.withFacts value (value.scan.facts.join other)).scan :=
  valid.withFacts (PathFacts.Context.join_bounded valid.path path)
    (ScalarMetadata.FlowReady.join_context base valid.flow flow)

theorem ScanDomain.closeTokens {calls : Statement.Calls} {source : Statement.Input} {value : ApplicationScan}
    (valid : ScanDomain source.text source.context value.scan) (middle : ShellToken) :
    ScanDomain source.text source.context
      (Statement.closeTokens (nativeStatementReaders calls) source value middle).scan :=
  ((valid.token (.word "end")).token middle).token (.symbol ";")

theorem ArmsDomain.initial {calls : Statement.Calls} {source : Statement.Input}
    (legal : NativeDomain source) :
    ArmsDomain source ⟨Statement.atPosition source.input
      ((nativeStatementReaders calls).takeToken source.text source.input.scan.position (.word "if")),
      source.input.scan.facts, false⟩ :=
  ⟨legal.atPosition (fixedAfter_result_bound _ _ "if" true (by decide)), legal.scan.path, legal.scan.flow⟩

theorem ArmsDomain.finish {calls : Statement.Calls} {source : Statement.Input}
    {before after : Statement.Arms} {read : Statement.ReadArm}
    (legal : ArmsDomain source before)
    (parsed : Statement.readArm (nativeStatementReaders calls) source before = some read)
    (branch : ScanDomain source.text source.context read.branch.scan)
    (finished : Statement.armState (Statement.finishArm (nativeStatementReaders calls) source read) = some after) :
    ArmsDomain source after := by
  have observed := Statement.readArm_evaluation parsed
  have condition := legal.value.condition before.value.scan.position
  have noPath : read.whenFalse.path.Bounded := by
    rw [observed.falseFlow]
    exact condition.1.2
  have noFlow : ScalarMetadata.FlowReady source.context.scalarNames source.context.declarationCount read.whenFalse := by
    rw [observed.falseFlow]
    exact condition.2.2
  have noScan := branch.withFacts noPath noFlow
  have yesPath : (if read.haveYes then (nativeStatementReaders calls).joinInto read.yes read.branch.scan.facts
      else read.branch.scan.facts).path.Bounded := by
    rw [observed.previousFlow]
    split
    · exact PathFacts.Context.join_bounded legal.yesPath branch.path
    · exact branch.path
  have yesFlow : ScalarMetadata.FlowReady source.context.scalarNames source.context.declarationCount
      (if read.haveYes then (nativeStatementReaders calls).joinInto read.yes read.branch.scan.facts
        else read.branch.scan.facts) := by
    rw [observed.previousFlow]
    split
    · exact ScalarMetadata.FlowReady.join_context legal.value.base legal.yesFlow branch.flow
    · exact branch.flow
  unfold Statement.finishArm at finished
  dsimp only at finished
  split at finished
  · simp only [Statement.armState, Option.some.injEq] at finished
    cases finished
    exact ⟨legal.value.replaceInput noScan, yesPath, yesFlow⟩
  · split at finished
    · contradiction
    · simp only [Statement.armState, Option.some.injEq] at finished
      cases finished
      exact ⟨legal.value.replaceInput (noScan.atPosition
        (fixedAfter_result_bound _ _ "elsif" true (by decide))), yesPath, yesFlow⟩

theorem finishArm_permission {calls : Statement.Calls} {source : Statement.Input}
    {read : Statement.ReadArm} {after : Statement.Arms}
    (finished : Statement.armState (Statement.finishArm calls source read) = some after) :
    after.value.allowProcedureCalls = read.branch.allowProcedureCalls := by
  unfold Statement.finishArm at finished
  dsimp only at finished
  split at finished
  · simp only [Statement.armState, Option.some.injEq] at finished
    cases finished
    rfl
  · split at finished
    · contradiction
    · simp only [Statement.armState, Option.some.injEq] at finished
      cases finished
      rfl

theorem closing_scan_domain {calls : Statement.Calls} {source : Statement.Input}
    {state : Statement.Arms} {result : ApplicationScan}
    (legal : ArmsDomain source state)
    (branch : ScanDomain source.text source.context (Statement.elseResult (nativeStatementReaders calls) source state).scan)
    (closing : Statement.ClosingReading (nativeStatementReaders calls) source state result) :
    ScanDomain source.text source.context result.scan := by
  rw [closing.resultEq]
  exact (branch.joinFacts legal.value.base legal.yesPath legal.yesFlow).closeTokens (.word "if")

theorem loop_scan_domain {calls : Statement.Calls} {source : Statement.Input}
    {iteration : Statement.Iteration} {result : ApplicationScan}
    (legal : NativeDomain source)
    (reading : Statement.IterationReading (nativeStatementReaders calls) source
      ((nativeStatementReaders calls).takeToken source.text source.input.scan.position (.word "for")) iteration result)
    (child : ScanDomain source.text (Statement.innerContext source iteration)
      (Statement.loopResult (nativeStatementReaders calls) source iteration).scan) :
    ScanDomain source.text source.context result.scan := by
  have original := Statement.forHeader_original legal.arrays reading.header
  have facts := original.afterFacts (calls := {calls with
      readCondition := fun text context position flow => readCondition text context position flow,
      joinInto := ActiveFlow.join}) (Statement.loopResult (nativeStatementReaders calls) source iteration) legal.arrays
  change (Statement.afterIteration (nativeStatementReaders calls) source iteration
      (Statement.widened (nativeStatementReaders calls) source iteration)
      (Statement.loopResult (nativeStatementReaders calls) source iteration)).scan.facts = _ at facts
  have after : ScanDomain source.text source.context
      (Statement.afterIteration (nativeStatementReaders calls) source iteration
        (Statement.widened (nativeStatementReaders calls) source iteration)
        (Statement.loopResult (nativeStatementReaders calls) source iteration)).scan := by
    refine ⟨child.position, child.controls, ?_, ?_⟩
    · rw [facts]
      exact loopAfterHeader_bounded legal.scan.path child.path _
    · rw [facts]
      exact loopAfterHeader_flowReady legal.base legal.scan.flow legal.scalarNames _ _
  rw [reading.resultEq]
  exact after.closeTokens (.word "loop")

theorem forHeader_permission {calls : Statement.Calls} {source : Statement.Input}
    {afterFor : Nat} {iteration : Statement.Iteration}
    (parsed : Statement.forHeader calls source afterFor = some iteration) :
    iteration.value.allowProcedureCalls = source.input.allowProcedureCalls := by
  unfold Statement.forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · split at parsed
    · unfold Statement.arrayHeader at parsed
      dsimp only at parsed
      split at parsed
      · contradiction
      · split at parsed
        · contradiction
        · cases parsed; rfl
    · cases parsed
      dsimp only [Statement.countedHeader]
      split <;> rfl

end Silver.ApplicationPackageBodies.Recursive
