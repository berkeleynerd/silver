module

public import Silver.ApplicationPackageArrayLoopReading
public import Silver.ApplicationPackageBodiesIterationFlow

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true

theorem OriginalHeader.innerContext_eq {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration) :
    innerContext source iteration = loopInner source.context (loopHeader source.text source.context source.input.scan) :=
  innerContext_header source iteration _ original.first original.last original.bounds

theorem OriginalHeader.widened_eq {calls : Calls} {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration) :
    widened (loopHeaderReaders calls) source iteration =
      source.input.scan.facts.widen source.context.scalarNames := by
  change iteration.value.scan.facts.widen source.context.scalarNames = _
  rw [original.facts]

theorem OriginalHeader.innerFacts {calls : Calls} {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration)
    (count : source.input.scan.facts.count = source.context.scalarNames.length) :
    (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)).scan.facts =
      (loopHeader source.text source.context source.input.scan).entry.facts := by
  rw [original.widened_eq]
  have extent : source.input.count = (source.input.scan.facts.widen source.context.scalarNames).count := by
    rw [ActiveFlow.widen_count _ _ count]
    rfl
  rw [innerInput_flow source iteration _ extent, original.bounds]
  rfl

theorem OriginalHeader.innerPosition {calls : Calls} {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration) :
    (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)).scan.position =
      (loopHeader source.text source.context source.input.scan).entry.position := original.position

theorem OriginalHeader.innerAnalysis {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration)
    (declarations : source.context.declarationCount ≤ source.context.scalarNames.length)
    (space : source.context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    (innerContext source iteration).analysis =
      source.context.analysis.withIndex (source.context.scalarNames.length + 1) iteration.bounds := by
  rw [original.innerContext_eq, loopInner_analysis _ declarations space, original.bounds]

theorem OriginalHeader.innerFlow {calls : Calls} {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration)
    (bodyMode : source.context.elaborating = false)
    (ready : ScalarExpression.BodyReady source.context.scalarNames)
    (count : source.input.scan.facts.count = source.context.scalarNames.length)
    (space : source.context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    (innerContext source iteration).flow
      (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)).scan.facts =
      loopEntry source.context.analysis (source.context.flow source.input.scan.facts)
        (source.context.scalarNames.length + 1) iteration.bounds := by
  rw [original.innerContext_eq, loopInner_flow, original.innerFacts count,
    loopHeader_model bodyMode ready count space, original.bounds]

theorem forHeader_name_allowed {calls : Calls} {source : Input} {iteration : Iteration}
    (parsed : forHeader (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration)
    (original : OriginalHeader source iteration) :
    loopNameAllowed source.text source.context (loopHeader source.text source.context source.input.scan) = true := by
  have guard := forHeader_name_guard parsed
  simp only [rejectedBinder, loopHeaderReaders, Bool.or_eq_false_iff, decide_eq_false_iff_not] at guard
  obtain ⟨⟨⟨⟨⟨first, last⟩, reserved⟩, argument⟩, _⟩, space⟩ := guard
  have keyword : (!Named.forbiddenName source.text iteration.first iteration.last ||
      Named.nameIs source.text iteration.first iteration.last ("string".toList.map Char.toNat)) = true := by
    cases forbidden : Named.forbiddenName source.text iteration.first iteration.last <;>
      cases string : Named.nameIs source.text iteration.first iteration.last ("string".toList.map Char.toNat) <;>
      simp_all
  have argumentName : (!source.context.hasArguments ||
      !Named.nameIs source.text iteration.first iteration.last ("silver_arguments".toList.map Char.toNat)) = true := by
    cases arguments : source.context.hasArguments <;>
      cases named : Named.nameIs source.text iteration.first iteration.last ("silver_arguments".toList.map Char.toNat) <;>
      simp_all
  simp only [loopNameAllowed, ← original.first, ← original.last, Bool.and_eq_true, decide_eq_true_eq]
  exact ⟨⟨⟨⟨first, Nat.lt_of_not_ge last⟩, keyword⟩, argumentName⟩, space⟩

theorem original_array_nonempty {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration)
    (iterable : loopIsArray source.text source.input.scan = true)
    (arrays : source.context.ArraysReady source.text) : iteration.bounds.isEmpty = false := by
  have valid := ArrayBindings.binding_components_valid
    (fun item member => (arrays.member_valid member).2.1.1)
    (loopArrayTarget source.text source.context source.input.scan)
  rw [original.bounds]
  simp only [LoopHeader.bounds, loopHeader, iterable, ite_true,
    Integer.Interval.isEmpty, decide_eq_false_iff_not, Int.not_lt]
  simpa only [ArrayBindings.Binding.descriptor, ParseContext.arrayTable] using valid.2

/-- The original native loop body returns exactly the inherited exit flow,
including empty counted ranges, maybe-empty counted ranges and nonempty array
iteration. Closing tokens preserve this complete flow. -/
theorem OriginalHeader.afterFacts {calls : Calls} {source : Input} {iteration : Iteration}
    (original : OriginalHeader source iteration) (inside : ApplicationScan)
    (arrays : source.context.ArraysReady source.text) :
    (afterIteration (loopHeaderReaders calls) source iteration
      (widened (loopHeaderReaders calls) source iteration) inside).scan.facts =
      loopAfterHeader source.context source.input.scan.facts inside.scan.facts
        (loopHeader source.text source.context source.input.scan) := by
  rw [original.widened_eq]
  cases iterable : loopIsArray source.text source.input.scan with
  | false =>
    have selected : (loopHeader source.text source.context source.input.scan).isArray = false := iterable
    have bounds : iteration.bounds = Integer.loopBounds
        (loopHeader source.text source.context source.input.scan).lower.bounds
        (loopHeader source.text source.context source.input.scan).upper.bounds := by
      simpa only [LoopHeader.bounds, selected, Bool.false_eq_true, ite_false] using original.bounds
    have definite : iteration.definite = Integer.loopDefinite
        (loopHeader source.text source.context source.input.scan).lower.bounds
        (loopHeader source.text source.context source.input.scan).upper.bounds := by
      simpa only [selected, Bool.false_eq_true, ite_false] using original.definite
    rw [afterIteration_counted _ _ _ _ _ _ bounds definite rfl]
    simp only [loopAfterHeader, selected, Bool.false_eq_true, ite_false]
  | true =>
    have selected : (loopHeader source.text source.context source.input.scan).isArray = true := iterable
    have definite : iteration.definite = true := by
      simpa only [selected, ite_true] using original.definite
    rw [afterIteration_array _ _ _ _ (original_array_nonempty original iterable arrays) definite]
    simp only [loopAfterHeader, selected, ite_true]

theorem IterationReading.original_result_facts {calls : Calls} {source : Input}
    {iteration : Iteration} {result : ApplicationScan}
    (read : IterationReading (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) iteration result)
    (arrays : source.context.ArraysReady source.text) :
    result.scan.facts = loopAfterHeader source.context source.input.scan.facts
      (loopResult (loopHeaderReaders calls) source iteration).scan.facts
      (loopHeader source.text source.context source.input.scan) := by
  have original := forHeader_original arrays read.header
  rw [read.resultEq]
  simp only [closeTokens, loopHeaderReaders, bodyToken_facts]
  exact original.afterFacts _ arrays

end Silver.ApplicationPackageBodies.Statement
