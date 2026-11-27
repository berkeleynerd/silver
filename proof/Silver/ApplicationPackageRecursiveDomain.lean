module

public import Silver.ApplicationPackageRecursiveTree
public import Silver.ApplicationPackageLoopFlow
public import Silver.PredicateNativeState
public import Silver.PredicateBodyControls
public import Silver.PredicateLoopFlowValidity

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true

/-- The projected native `Valid_Body` precondition. Native Boolean and scalar
types supply the field domains; no semantic statement check occurs here. -/
structure ScanDomain (text : Source) (context : ParseContext) (scan : BodyScan) : Prop where
  position : scan.position ≤ text.length + 1
  controls : Controls context scan
  path : scan.facts.path.Bounded
  flow : ScalarMetadata.FlowReady context.scalarNames context.declarationCount scan.facts

/-- Exactly the common native Basic/Statement/Tail invocation preconditions.
The witness preserves the original argument-name positions projected from
`Body_Context`; all later scopes retain this same witness except the iterator
extension of the scalar table. -/
structure NativeDomain (source : Statement.Input) : Prop where
  text : Expressions.ValidText source.text
  context : ∃ native : Native.Context,
    native.model = source.context ∧ Native.ValidContext source.text native
  scan : ScanDomain source.text source.context source.input.scan
  functions : FunctionBindings.ValidMetadata source.text source.catalog
  procedures : ProcedureBindings.ValidMetadata source.text source.procedures

theorem NativeDomain.base {source : Statement.Input} (legal : NativeDomain source) :
    ScalarMetadata.ContextReady source.context.scalarNames source.context.declarationCount
      source.context.elaborating := by
  obtain ⟨native, same, valid⟩ := legal.context
  exact same ▸ valid.base

theorem NativeDomain.arrays {source : Statement.Input} (legal : NativeDomain source) :
    source.context.ArraysReady source.text := by
  obtain ⟨native, same, valid⟩ := legal.context
  exact same ▸ valid.arrays

theorem NativeDomain.scalarNames {source : Statement.Input} (legal : NativeDomain source) :
    ScalarExpression.ValidEnvironment source.text source.context.scalarNames := by
  obtain ⟨native, same, valid⟩ := legal.context
  exact same ▸ valid.2.2.1

theorem NativeDomain.replaceInput {source : Statement.Input} (legal : NativeDomain source)
    {value : ApplicationScan} (scan : ScanDomain source.text source.context value.scan) :
    NativeDomain (atInput source value) :=
  ⟨legal.text, legal.context, scan, legal.functions, legal.procedures⟩

theorem ScanDomain.atPosition {text : Source} {context : ParseContext} {value : ApplicationScan}
    (valid : ScanDomain text context value.scan) {position : Nat} (bound : position ≤ text.length + 1) :
    ScanDomain text context (Statement.atPosition value position).scan :=
  ⟨bound, valid.controls, valid.path, valid.flow⟩

theorem ScanDomain.withFacts {text : Source} {context : ParseContext} {value : ApplicationScan}
    (valid : ScanDomain text context value.scan) {facts : ActiveFlow}
    (path : facts.path.Bounded)
    (flow : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
    ScanDomain text context (Statement.withFacts value facts).scan :=
  ⟨valid.position, valid.controls, path, flow⟩

theorem NativeDomain.atPosition {source : Statement.Input} (legal : NativeDomain source)
    {position : Nat} (bound : position ≤ source.text.length + 1) :
    NativeDomain (atInput source (Statement.atPosition source.input position)) :=
  legal.replaceInput (legal.scan.atPosition bound)

/-- Both condition refinements retain the complete native flow domain. -/
theorem NativeDomain.condition {source : Statement.Input} (legal : NativeDomain source)
    (position : Nat) :
    let result := readCondition source.text source.context position source.input.scan.facts
    result.Bounded ∧ result.FlowReady source.context :=
  ⟨readCondition_bounded _ _ _ _ legal.scan.path,
    condition_flowReady _ _ _ _ legal.base legal.scan.flow⟩

theorem NativeDomain.thenInput {calls : Statement.Calls} {source : Statement.Input}
    {prior : Statement.Arms} (legal : NativeDomain (atInput source prior.value))
    (token : calls.takeToken = tokenAfter)
    (condition : Statement.conditionFor calls source prior =
      readCondition source.text source.context prior.value.scan.position prior.value.scan.facts) :
    NativeDomain (atInput source
      (Statement.thenInput calls source prior (Statement.conditionFor calls source prior))) := by
  have facts := legal.condition prior.value.scan.position
  refine ⟨legal.text, legal.context, ?_, legal.functions, legal.procedures⟩
  refine ⟨?_, legal.scan.controls, ?_, ?_⟩
  · change calls.takeToken source.text (Statement.conditionFor calls source prior).after (.word "then") ≤ _
    rw [token]
    exact fixedAfter_result_bound _ _ "then" true (by decide)
  · change (Statement.conditionFor calls source prior).whenTrue.path.Bounded
    rw [condition]
    exact facts.1.1
  · change ScalarMetadata.FlowReady source.context.scalarNames source.context.declarationCount
      (Statement.conditionFor calls source prior).whenTrue
    rw [condition]
    exact facts.2.1

theorem forHeader_controls {calls : Statement.Calls} {source : Statement.Input}
    {afterFor : Nat} {iteration : Statement.Iteration}
    (input : Controls source.context source.input.scan)
    (parsed : Statement.forHeader calls source afterFor = some iteration) :
    Controls source.context iteration.value.scan := by
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
        · cases parsed
          exact input
    · cases parsed
      dsimp only [Statement.countedHeader]
      split <;> exact input

/-- The full loop child domain follows from the original accepted header,
including widened mutable ranges and the readonly captured iterator. -/
theorem NativeDomain.loopInput {calls : Statement.Calls} {source : Statement.Input}
    {iteration : Statement.Iteration} (legal : NativeDomain source)
    (parsed : Statement.forHeader (Statement.loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration)
    (advanced : source.input.scan.position < iteration.value.scan.position) :
    NativeDomain (atContext source (Statement.innerContext source iteration)
      (Statement.innerInput source iteration (Statement.widened (Statement.loopHeaderReaders calls) source iteration))) := by
  have original := Statement.forHeader_original legal.arrays parsed
  have allowed := Statement.forHeader_name_allowed parsed original
  have count := legal.scan.flow.compatible.count
  have positive : (loopHeader source.text source.context source.input.scan).entry.position ≠ 0 := by
    rw [← original.position]
    omega
  have innerContext : ∃ native : Native.Context,
      native.model = Statement.innerContext source iteration ∧ Native.ValidContext source.text native := by
    obtain ⟨native, same, valid⟩ := legal.context
    let inner := {native with scalarNames :=
      (loopInner source.context (loopHeader source.text source.context source.input.scan)).scalarNames}
    refine ⟨inner, ?_, ?_⟩
    · rw [original.innerContext_eq]
      change {native.model with scalarNames :=
        (loopInner source.context (loopHeader source.text source.context source.input.scan)).scalarNames} = _
      rw [same]
      rfl
    · exact ⟨valid.1, valid.2.1,
        loopInner_valid_environment legal.arrays legal.scalarNames allowed positive,
        (by
          change ScalarMetadata.ContextReady _ native.declarationCount native.elaborating
          rw [show native.declarationCount = source.context.declarationCount from
            congrArg ParseContext.declarationCount same,
            show native.elaborating = source.context.elaborating from congrArg ParseContext.elaborating same]
          exact nativeLoopInner_baseReady legal.base
            (loopHeader source.text source.context source.input.scan)
            (loopNameAllowed_space legal.base.size allowed)),
        valid.arrays, valid.booleans, valid.mask, valid.bounds, valid.unit⟩
  refine ⟨legal.text, innerContext, ?_, legal.functions, legal.procedures⟩
  change ScanDomain source.text (Statement.innerContext source iteration)
    (Statement.innerInput source iteration
      (Statement.widened (Statement.loopHeaderReaders calls) source iteration)).scan
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [original.innerPosition]
    exact loopHeader_bound source.text source.context source.input.scan
  · exact (forHeader_controls (source := source) legal.scan.controls parsed)
  · rw [original.innerFacts count]
    exact loopContext_bounded legal.scan.path _
  · rw [original.innerContext_eq, original.innerFacts count]
    exact loopHeader_flowReady legal.arrays legal.base legal.scan.flow legal.scalarNames positive

end Silver.ApplicationPackageBodies.Recursive
