module

public import Silver.ApplicationPackageLoopFlow
public import Silver.PackageChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

/-- A local composition interface, instantiated by the fixed package or Main
checker. Its recursive premise is discharged by the original child-tail proof. -/
structure CountedChecker where
  check : Integer.Analysis → Flow → List Predicate.Statement → Option Flow
  counted : ∀ (analysis : Integer.Analysis) (before : Flow) (index : Nat) (reverse : Bool)
    (lower upper : Integer.Expr) (body : List Predicate.Statement) (a b : Integer.Interval) (inside : Flow),
    lower.infer before.scalars = some a → upper.infer before.scalars = some b →
    check (analysis.withIndex index (Integer.loopBounds a b))
      (loopEntry analysis before index (Integer.loopBounds a b)) body = some inside →
    check analysis before [.forLoop index reverse lower upper body] = some (loopExit analysis before inside a b)

def packageCountedChecker (earlier : Packages.EffectEnvironment) (layout : Packages.FrameLayout)
    (booleans : Boolean.Analysis) : CountedChecker where
  check := fun analysis before body => Packages.checkPackageStatements earlier layout analysis before booleans body
  counted := by
    intro analysis before index reverse lower upper body a b inside low high child
    simp only [Packages.checkPackageStatements, Packages.checkPackageStatement,
      low, high, Option.bind_some, child, Option.map_some]

def mainCountedChecker (shape : Bindings.Shape) (booleans : Boolean.Analysis)
    (functions : ScalarFunctions.Signatures) (procedures : ScalarProcedures.Signatures) : CountedChecker where
  check := fun analysis before body => checkStatements shape analysis before body booleans functions procedures
  counted := by
    intro analysis before index reverse lower upper body a b inside low high child
    simp only [checkStatements, Predicate.Statement.check, low, high, Option.bind_some, child, Option.map_some]

abbrev LoopChildReading := ParseContext → ApplicationScan → BodyStop →
  List Predicate.Statement → ApplicationScan → Prop

def CountedCodeAt (calls : Calls) (source : Input) (child : LoopChildReading)
    (iteration : Iteration) (lower upper : Integer.Expr) (body : List Predicate.Statement) : Prop :=
  LoopBoundsAt source.text source.context source.input.scan lower upper ∧
    child (innerContext source iteration)
      (innerInput source iteration (widened calls source iteration)) .endOnly body
      (loopResult calls source iteration)

/-- Compose an accepted original counted loop with its original recursive body.
The bounds and all of their arithmetic intermediates come from LoopBoundsAt;
empty and unreachable loops still require the complete child check. -/
theorem counted_source_checked {calls : Calls} {source : Input} {iteration : Iteration}
    {result : ApplicationScan} {body : List Predicate.Statement} {child : LoopChildReading}
    (checker : CountedChecker)
    (read : IterationReading (loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) iteration result)
    (counted : loopIsArray source.text source.input.scan = false)
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
    (checked : checker.check (innerContext source iteration).analysis
      ((innerContext source iteration).flow
        (innerInput source iteration (widened (loopHeaderReaders calls) source iteration)).scan.facts) body =
      some ((innerContext source iteration).flow (loopResult (loopHeaderReaders calls) source iteration).scan.facts)) :
    ∃ lower upper, CountedCodeAt (loopHeaderReaders calls) source child iteration lower upper body ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape
        [.forLoop (source.context.scalarNames.length + 1)
          (loopHeader source.text source.context source.input.scan).reverse lower upper body]
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checker.check source.context.analysis (source.context.flow source.input.scan.facts)
        [.forLoop (source.context.scalarNames.length + 1)
          (loopHeader source.text source.context source.input.scan).reverse lower upper body] =
        some (source.context.flow result.scan.facts) := by
  have original := forHeader_original arrays read.header
  have space := loopNameAllowed_space base.size (forHeader_name_allowed read.header original)
  obtain ⟨lower, upper, boundsRead, low, high, bounds, _⟩ :=
    countedHeader_original_bounds counted arrays read.header (by have := read.advances; omega) compatible
  have bodyChecked := checked
  rw [original.innerAnalysis base.count space, original.innerFlow bodyMode base.body compatible.count space] at bodyChecked
  rw [bounds] at bodyChecked
  have loopChecked := checker.counted source.context.analysis (source.context.flow source.input.scan.facts)
    (source.context.scalarNames.length + 1) (loopHeader source.text source.context source.input.scan).reverse
    lower upper body _ _ _ low high bodyChecked
  have selected : (loopHeader source.text source.context source.input.scan).isArray = false := counted
  have resultFlow : source.context.flow result.scan.facts =
      loopExit source.context.analysis (source.context.flow source.input.scan.facts)
        (source.context.flow (loopResult (loopHeaderReaders calls) source iteration).scan.facts)
        (loopHeader source.text source.context source.input.scan).lower.bounds
        (loopHeader source.text source.context source.input.scan).upper.bounds := by
    rw [read.original_result_facts arrays, loopAfterHeader_model bodyMode base.body compatible.count]
    simp only [selected, Bool.false_eq_true, ite_false]
  refine ⟨lower, upper, ⟨boundsRead, sourceBody⟩, ?_, ?_⟩
  · simp only [StatementsWellFormed, Predicate.Statement.WellFormed]
    exact ⟨⟨by omega, nonempty, wellFormed⟩, trivial⟩
  · rw [resultFlow]
    exact loopChecked

end Silver.ApplicationPackageBodies.Statement
