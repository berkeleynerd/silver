module

public import Silver.ApplicationPackageCountedChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

def ArrayCodeAt (calls : Calls) (source : Input) (child : LoopChildReading)
    (iteration : Iteration) (body : List Predicate.Statement) : Prop :=
  loopIsArray source.text source.input.scan = true ∧
    loopArrayAllowed source.text source.context source.input.scan = true ∧
    child (innerContext source iteration)
      (innerInput source iteration (widened calls source iteration)) .endOnly body
      (loopResult calls source iteration)

/-- The full Main array-loop checker consumes the original captured array
identity and recursive child result. Separation of nested lexical binders is a
syntactic induction invariant, ultimately obtained from their native capacity
guards; it is not an external program-safety assumption. -/
theorem array_source_checked {calls : Calls} {source : Input} {iteration : Iteration}
    {result : ApplicationScan} {body : List Predicate.Statement} {child : LoopChildReading}
    {functions : ScalarFunctions.Signatures} {procedures : ScalarProcedures.Signatures}
    (read : IterationReading (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) iteration result)
    (iterable : loopIsArray source.text source.input.scan = true)
    (bodyMode : source.context.elaborating = false)
    (base : ScalarMetadata.BaseReady source.context.scalarNames source.context.declarationCount)
    (arrays : source.context.ArraysReady source.text)
    (compatible : ScalarMetadata.OverlayCompatible source.context.scalarNames
      source.context.declarationCount source.input.scan.facts)
    (sourceBody : child (innerContext source iteration)
      (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)) .endOnly body
      (loopResult (loopHeaderReaders calls) source iteration))
    (nonempty : body ≠ [])
    (wellFormed : StatementsWellFormed source.context.hasArguments source.context.names.shape body
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (binders : ∀ array : Integer.ArrayDescriptor,
      (∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index) →
      statementsBindersApart array body = true)
    (checked : checkStatements source.context.names.shape (innerContext source iteration).analysis
      ((innerContext source iteration).flow
        (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)).scan.facts) body
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
      functions procedures =
      some ((innerContext source iteration).flow (loopResult (loopHeaderReaders calls) source iteration).scan.facts)) :
    let array := (ArrayBindings.binding source.context.arrayNames
      (loopArrayTarget source.text source.context source.input.scan)).viewDescriptor
    let item : Predicate.Statement := .arrayLoop (source.context.scalarNames.length + 1)
      (loopHeader source.text source.context source.input.scan).reverse array body
    ArrayCodeAt (loopHeaderReaders calls) source child iteration body ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape [item]
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checkStatements source.context.names.shape source.context.analysis (source.context.flow source.input.scan.facts)
        [item] (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
        functions procedures = some (source.context.flow result.scan.facts) := by
  let array := (ArrayBindings.binding source.context.arrayNames
    (loopArrayTarget source.text source.context source.input.scan)).viewDescriptor
  have original := forHeader_original arrays read.header
  have space := loopNameAllowed_space base.size (forHeader_name_allowed read.header original)
  have allowed := (arrayHeader_original iterable read.header).1
  have ready := loopArrayReady bodyMode arrays space allowed
  change arrayLoopReady source.context.analysis (source.context.flow source.input.scan.facts)
    (source.context.scalarNames.length + 1) array = true at ready
  have apart := binders array (arrayBinding_scalar_apart _)
  have components : iteration.bounds = array.componentBounds := by
    rw [original.bounds]
    simp only [LoopHeader.bounds, loopHeader, iterable, ite_true, array,
      ArrayBindings.Binding.viewDescriptor_components]
  have nonemptyBounds := original_array_nonempty original iterable arrays
  rw [components] at nonemptyBounds
  have entry : loopEntry source.context.analysis (source.context.flow source.input.scan.facts)
      (source.context.scalarNames.length + 1) array.componentBounds =
      arrayLoopEntry source.context.analysis (source.context.flow source.input.scan.facts)
        (source.context.scalarNames.length + 1) array.componentBounds := by
    simp only [loopEntry, arrayLoopEntry, loopContext, nonemptyBounds, Bool.false_eq_true, ite_false]
  have bodyChecked := checked
  rw [original.innerAnalysis base.count space, original.innerFlow bodyMode base.body compatible.count space,
    components, entry] at bodyChecked
  have resultContext : (innerContext source iteration).flow
      (loopResult (loopHeaderReaders calls) source iteration).scan.facts =
      source.context.flow (loopResult (loopHeaderReaders calls) source iteration).scan.facts := rfl
  rw [resultContext] at bodyChecked
  have selected : (loopHeader source.text source.context source.input.scan).isArray = true := iterable
  have resultFlow : source.context.flow result.scan.facts =
      arrayLoopExit source.context.analysis (source.context.flow source.input.scan.facts)
        (source.context.flow (loopResult (loopHeaderReaders calls) source iteration).scan.facts) := by
    rw [read.original_result_facts arrays, loopAfterHeader_model bodyMode base.body compatible.count,
      selected, ite_eq_left rfl]
  refine ⟨⟨iterable, allowed, sourceBody⟩, ?_, ?_⟩
  · simp only [StatementsWellFormed, Predicate.Statement.WellFormed]
    exact ⟨⟨by omega, nonempty, wellFormed⟩, trivial⟩
  · change checkStatements source.context.names.shape source.context.analysis
      (source.context.flow source.input.scan.facts)
      [.arrayLoop (source.context.scalarNames.length + 1)
        (loopHeader source.text source.context source.input.scan).reverse array body]
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
      functions procedures = _
    rw [resultFlow]
    simp only [checkStatements, Predicate.Statement.check, ready, apart, Bool.and_self, ite_true,
      bodyChecked, Option.map_some, Option.bind_some]

end Silver.ApplicationPackageBodies.Statement
