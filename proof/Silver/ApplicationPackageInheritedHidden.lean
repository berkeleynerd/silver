module

public import Silver.ApplicationPackageHiddenTargets
public import Silver.ApplicationPackageInheritedChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate ApplicationPackageEffects

theorem inherited_hidden_range {text context scan item result slot}
    (original : BasicStepAt text context scan item result {} {})
    (row : OriginalRow context (.integer slot)) (hidden : ¬OriginalLookup text context (.integer slot))
    (checked : item.lower.check context.names.shape context.analysis (context.flow scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      [] [] = some (context.flow result.facts)) :
    (context.flow result.facts).scalars slot = (context.flow scan.facts).scalars slot := by
  have source := original.empty_primitive
  cases source.payload with
  | scalarAssignment =>
    have different : slot ≠ scalarTarget text context scan.position :=
      Ne.symm (hidden_scalar_target row hidden)
    simp only [SourceStatement.lower, Statement.check] at checked
    split at checked
    · simpa only [Integer.Assignment.after, Integer.put, different, ite_false] using
        congrArg (fun flow : Flow => flow.scalars slot) (Option.some.inj checked).symm
    · contradiction
  | scalarCallAssignment | booleanCallAssignment =>
    simp only [SourceStatement.lower, Statement.check, ScalarFunctions.Assignment.check,
      ScalarFunctions.Call.check, ScalarFunctions.lookup_empty, Option.bind_none,
      Bool.false_eq_true, ite_false, reduceCtorEq] at checked
  | reject =>
    simp only [SourceStatement.lower, Statement.check] at checked
    simpa only using congrArg (fun flow : Flow => flow.scalars slot) (Option.some.inj checked).symm
  | null | output | put | arrayAssignment | booleanArrayAssignment | booleanAssignment | assignment =>
    simp only [SourceStatement.lower, Statement.check] at checked
    split at checked
    · exact congrArg (fun flow : Flow => flow.scalars slot) (Option.some.inj checked).symm
    · contradiction

theorem function_target_hidden {text context scan slot}
    (row : OriginalRow context (.integer slot)) (hidden : ¬OriginalLookup text context (.integer slot)) :
    ScalarProcedures.targetCell (functionAssignmentTarget text context scan) ≠ .integer slot := by
  unfold functionAssignmentTarget
  split
  · change ScalarProcedures.Cell.integer (scalarTarget text context scan.position) ≠ .integer slot
    intro equal
    exact hidden_scalar_target row hidden (ScalarProcedures.Cell.integer.inj equal)
  · intro equal
    cases equal

end Silver.ApplicationPackageBodies.SourceSyntax
