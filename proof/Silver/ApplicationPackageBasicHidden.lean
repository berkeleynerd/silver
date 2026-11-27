module

public import Silver.ApplicationPackageInheritedHidden
public import Silver.ApplicationPackageHiddenProcedure

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate ApplicationPackageDeclarations ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageObjectRows ApplicationPackageEffects

set_option backward.dsimp.instances true

/-- Every original package Basic statement checks and preserves declared
hidden-state ranges. Explicit assignment/copy-back targets cannot resolve hidden
rows; implicit callee writes use the full semantic global reset. -/
theorem package_basic_hidden_reading {calls : BasicCalls} {text : Source}
    {context : Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Native.ValidContext text context)
    (normal : NamesNormal context.names) (body : context.elaborating = false)
    (scan : Recursive.ScanDomain text context.model input.scan)
    (typed : info.Typed) (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (pure : context.pure = true) (arguments : context.model.hasArguments = false)
    (shape : context.names.shape = Bindings.emptyShape)
    (declarations : StateDeclarations text info.states)
    (fields : ScalarStateFields info.states context.scalarNames) (bound : Nat)
    (hiddenRanges : ∀ slot identity, (layout bound info context.model).integers slot = .global identity →
      ¬OriginalLookup text context.model (.integer slot) →
      (context.model.flow input.scan.facts).scalars slot = context.model.analysis.declared slot)
    (accepted : (applicationBasic (basicReaders calls) text context.model input info {} {}).scan.position ≠ 0) :
    let result := applicationBasic (basicReaders calls) text context.model input info {} {}
    let bools := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ item, BasicCodeAt (basicReaders calls) packageNames
        ⟨text, context.model, input, info, {}, {}⟩ result item ∧
      item.WellFormed context.model.hasArguments context.names.shape bools ∧
      Packages.checkPackageStatement (completedEnvironment info) (layout bound info context.model)
        context.model.analysis (context.model.flow input.scan.facts) bools item =
          some (context.model.flow result.scan.facts) ∧
      discharged (Packages.packageStatementObligations (completedEnvironment info) (layout bound info context.model)
        context.model.analysis (context.model.flow input.scan.facts) bools item) = true ∧
      (∀ slot identity, (layout bound info context.model).integers slot = .global identity →
        ¬OriginalLookup text context.model (.integer slot) →
        (context.model.flow result.scan.facts).scalars slot = (context.model.flow input.scan.facts).scalars slot) := by
  have base := valid.base
  rw [body] at base
  cases selected : Basic.origin (basicReaders calls)
      ⟨text, context.model, input, info, {}, {}⟩ with
  | inherited =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_inherited calls] at selected' accepted'
    obtain ⟨item, reading, wellFormed, checked⟩ := Basic.inherited_semantics
      textValid valid.1 selected' accepted' normal base.toBaseReady valid.arrays valid.booleans.1
      scan.flow.compatible scan.path body (by simp [FunctionBindings.ValidMetadata])
        (by simp [ProcedureBindings.ValidMetadata])
    simp only [basicReaders_inherited] at reading checked
    have packageChecked := inherited_package_check reading pure arguments shape
      (completedEnvironment info) (layout bound info context.model) checked
    refine ⟨item.lower, .inherited selected rfl reading, SourceStatement.lower_wellFormed wellFormed,
      packageChecked, Packages.package_statement_obligations_discharge packageChecked, ?_⟩
    intro slot identity global hidden
    exact inherited_hidden_range reading (global_integer_original declarations global) hidden checked
  | packageFunction =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_function calls] at selected' accepted'
    obtain ⟨call, reading, package, _⟩ := Basic.function_statement_reading
      textValid valid body scan.storage scan.body_checked typed declared writes selected' accepted'
    simp only [basicReaders_function] at reading package
    obtain ⟨wellFormed, checked, discharged⟩ := package shape (layout bound info context.model)
    rw [← shape] at wellFormed
    refine ⟨_, .functionCall rfl selected rfl reading, wellFormed, checked, discharged, ?_⟩
    intro slot identity global hidden
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, updated, _⟩ := Basic.function_assignment_reading
      textValid valid body scan.storage scan.body_checked typed declared writes selected' accepted'
    simp only [basicReaders_function] at updated
    rw [← updated]
    exact ScalarFunctions.Target.after_other_integer
      (function_target_hidden (global_integer_original declarations global) hidden) _ _
  | packageProcedure =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_procedure calls] at selected' accepted'
    obtain ⟨call, reading, wellFormed, checked, discharged, preserved⟩ := Basic.procedure_hidden_source_statement
      textValid valid body scan.storage scan.body_checked typed declarations fields shape bound hiddenRanges
      selected' accepted'
    simp only [basicReaders_procedure] at checked discharged preserved
    rw [← shape] at wellFormed
    exact ⟨_, .procedureCall rfl selected rfl reading, wellFormed, checked, discharged, preserved⟩

end Silver.ApplicationPackageBodies.SourceSyntax
