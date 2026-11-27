module

public import Silver.ApplicationPackageInheritedChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate ApplicationPackageDeclarations ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageObjectRows

set_option backward.dsimp.instances true

/-- The original package entry frame supplies only declaration/representation
facts. Every original Basic branch constructs its syntax and derives its complete
package checker, exact output flow and obligations. Recursive loop-shadow
composition separately generalizes the visible-row reset invariant. -/
theorem package_basic_reading {calls : BasicCalls} {text : Source}
    {context : Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Native.ValidContext text context)
    (normal : NamesNormal context.names) (body : context.elaborating = false)
    (scan : Recursive.ScanDomain text context.model input.scan)
    (typed : info.Typed) (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (pure : context.pure = true) (arguments : context.model.hasArguments = false)
    (shape : context.names.shape = Bindings.emptyShape)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context.model))
    (fields : ScalarStateFields info.states context.scalarNames) (bound : Nat)
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
        context.model.analysis (context.model.flow input.scan.facts) bools item) = true := by
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
    exact ⟨item.lower, .inherited selected rfl reading, SourceStatement.lower_wellFormed wellFormed,
      packageChecked, Packages.package_statement_obligations_discharge packageChecked⟩
  | packageFunction =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_function calls] at selected' accepted'
    obtain ⟨call, reading, package, _⟩ := Basic.function_statement_reading
      textValid valid body scan.storage scan.body_checked typed declared writes selected' accepted'
    simp only [basicReaders_function] at reading package
    obtain ⟨wellFormed, checked, discharged⟩ := package shape (layout bound info context.model)
    rw [← shape] at wellFormed
    exact ⟨_, .functionCall rfl selected rfl reading, wellFormed, checked, discharged⟩
  | packageProcedure =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_procedure calls] at selected' accepted'
    obtain ⟨call, reading, wellFormed, checked, discharged⟩ := Basic.procedure_source_statement
      textValid valid body scan.storage scan.body_checked typed declarations clear fields shape bound
      selected' accepted'
    simp only [basicReaders_procedure] at checked discharged
    rw [← shape] at wellFormed
    exact ⟨_, .procedureCall rfl selected rfl reading, wellFormed, checked, discharged⟩

end Silver.ApplicationPackageBodies.SourceSyntax
