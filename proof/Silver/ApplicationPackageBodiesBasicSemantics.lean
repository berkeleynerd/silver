module

public import Silver.ApplicationPackageBodiesBasicReading
public import Silver.PredicateBasicStepMeaning

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open ApplicationPackages Compose Predicate

/-- A successfully scanned inherited package statement meets the original
decidable checker with exactly the flow returned by the package reader. -/
theorem inherited_semantics {calls : BasicCalls} {s : Statement.Input}
    (tv : Expressions.ValidText s.text) (nv : Expressions.ValidNames s.text s.context.names)
    (inherited : origin (withInheritedBody calls) s = .inherited)
    (accepted : (applicationBasic (withInheritedBody calls) s.text s.context s.input s.info
      s.catalog s.procedures).scan.position ≠ 0)
    (normal : NamesNormal s.context.names)
    (base : ScalarMetadata.BaseReady s.context.scalarNames s.context.declarationCount)
    (arrays : s.context.ArraysReady s.text)
    (booleans : s.context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible s.context.scalarNames s.context.declarationCount s.input.scan.facts)
    (bounded : s.input.scan.facts.path.Bounded) (bodyMode : s.context.elaborating = false)
    (functions : FunctionBindings.ValidMetadata s.text s.catalog)
    (procedures : ProcedureBindings.ValidMetadata s.text s.procedures) :
    let result := applicationBasic (withInheritedBody calls) s.text s.context s.input s.info s.catalog s.procedures
    let bools := ArrayBindings.booleanAnalysis s.context.arrayNames (BooleanBindings.analysis s.context.booleanNames)
    ∃ item, BasicStepAt s.text s.context s.input.scan item result.scan s.catalog s.procedures ∧
      item.WellFormed s.context.hasArguments s.context.names.shape bools ∧
      item.lower.check s.context.names.shape s.context.analysis (s.context.flow s.input.scan.facts) bools
        (catalogSignatures s.catalog s.context.arrayTypes) (ProcedureBindings.catalogSignatures s.procedures s.context.arrayTypes) =
          some (s.context.flow result.scan.facts) := by
  obtain ⟨item, source, _⟩ := withInheritedBody_reading tv nv inherited accepted
  exact ⟨item, source, basicStep_meaning normal base arrays booleans compatible nv bounded bodyMode functions procedures source⟩

end Silver.ApplicationPackageBodies.Basic
