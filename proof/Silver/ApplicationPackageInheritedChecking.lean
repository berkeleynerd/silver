module

public import Silver.ApplicationPackageMainBasicReading
public import Silver.ApplicationPackageProcedureSourceFlow

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate

/-- The original pure, argument-free package frame excludes external effects,
String/array assignment and local callable declarations. Its inherited leaf is
therefore null or a scalar assignment. Package calls use their separate original
dispatch branches. These exclusions follow from the existing reader guards. -/
theorem inherited_package_check {text context scan item result}
    (original : BasicStepAt text context scan item result {} {})
    (pure : context.pure = true) (arguments : context.hasArguments = false)
    (shape : context.names.shape = Bindings.emptyShape)
    (earlier : Packages.EffectEnvironment) (layout : Packages.FrameLayout)
    (checked : item.lower.check context.names.shape context.analysis (context.flow scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      [] [] = some (context.flow result.facts)) :
    Packages.checkPackageStatement earlier layout context.analysis (context.flow scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      item.lower = some (context.flow result.facts) := by
  have source := original.empty_primitive
  have kind : basicKind text context scan = .null ∨ basicKind text context scan = .scalarAssignment ∨
      basicKind text context scan = .booleanAssignment ∨ basicKind text context scan = .assignment := by
    simp only [basicKind, pure, arguments, Bool.not_true, Bool.false_and, Bool.false_eq_true, ite_false]
    split
    · exact Or.inl rfl
    · split
      · exact Or.inr (Or.inl rfl)
      · split
        · exact Or.inr (Or.inr (Or.inl rfl))
        · exact Or.inr (Or.inr (Or.inr rfl))
  cases source.payload with
  | null => simpa only [SourceStatement.lower, Statement.check, checkSimple, Packages.checkPackageStatement, ite_true] using checked
  | scalarAssignment => simpa only [SourceStatement.lower, Statement.check, checkSimple, Packages.checkPackageStatement, ite_true] using checked
  | booleanAssignment =>
    rw [shape] at checked
    simpa only [SourceStatement.lower, Statement.check, checkSimple, Packages.checkPackageStatement, ite_true] using checked
  | output selected _ | put selected _ | reject selected | arrayAssignment selected _ _
  | booleanArrayAssignment selected _ _ =>
    simp only [selected, reduceCtorEq, or_self] at kind
  | scalarCallAssignment _ _ | booleanCallAssignment _ _ =>
    simp only [SourceStatement.lower, Statement.check, ScalarFunctions.Assignment.check,
      ScalarFunctions.Call.check, ScalarFunctions.lookup_empty, Option.bind_none,
      Bool.false_eq_true, ite_false, reduceCtorEq] at checked
  | assignment selected _ =>
    have accepted := source.equation.symm ▸ source.positive
    have positive := basic_raw_positive accepted
    simp only [basicRaw, selected, procedureCalleeAt_empty, ne_eq, not_true_eq_false,
      ite_false, pure, ite_true, invalidBody] at positive

end Silver.ApplicationPackageBodies.SourceSyntax
