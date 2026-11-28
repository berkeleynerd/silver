module

public import Silver.ApplicationPackageMainInheritedStatement

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate ApplicationPackageDeclarations ApplicationPackageCalls

set_option backward.dsimp.instances true

/-- Construct Main's source leaf and its combined-table checker result from
the original native reader. Public/local declaration histories supply the name
and table representation facts; all executable checks and obligations follow
from acceptance. No semantic certificate occurs in `BasicCodeAt`. -/
theorem main_basic_reading {calls : BasicCalls} {text : Source}
    {context : Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata} {first : Nat}
    (textValid : Expressions.ValidText text) (valid : Native.ValidContext text context)
    (normal : NamesNormal context.names) (body : context.elaborating = false)
    (scan : Recursive.ScanDomain text context.model input.scan)
    (functionsValid : FunctionBindings.ValidMetadata text catalog)
    (proceduresValid : ProcedureBindings.ValidMetadata text procedures)
    (typed : info.Typed) (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (sourceNames : ApplicationPackageMain.ScalarsFrom first context.model.scalarNames)
    (earlier : ∀ state ∈ info.states, state.name.first < first)
    (environment : Applications.Environment)
    (packageSignatures : environment.packages.signatures =
      (completedEnvironment info).map Packages.RoutineEffects.signature)
    (localFunctions : catalogSignatures catalog context.model.arrayTypes = environment.localFunctions.signatures)
    (localProcedures : ProcedureBindings.catalogSignatures procedures context.model.arrayTypes =
      environment.localProcedures.signatures)
    (accepted : (applicationBasic (basicReaders calls) text context.model input info catalog procedures).scan.position ≠ 0) :
    let result := applicationBasic (basicReaders calls) text context.model input info catalog procedures
    let bools := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ item, BasicCodeAt (basicReaders calls) (mainNames environment)
        ⟨text, context.model, input, info, catalog, procedures⟩ result item ∧
      item.WellFormed context.model.hasArguments context.names.shape bools ∧
      item.check context.names.shape context.model.analysis (context.model.flow input.scan.facts) bools
        environment.functionSignatures environment.procedureSignatures = some (context.model.flow result.scan.facts) ∧
      discharged (item.obligations context.names.shape context.model.analysis (context.model.flow input.scan.facts)
        bools environment.functionSignatures environment.procedureSignatures) = true := by
  have base := valid.base
  rw [body] at base
  cases selected : Basic.origin (basicReaders calls)
      ⟨text, context.model, input, info, catalog, procedures⟩ with
  | inherited =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_inherited calls] at selected' accepted'
    obtain ⟨item, reading, wellFormed, checked⟩ := Basic.inherited_semantics
      textValid valid.1 selected' accepted' normal base.toBaseReady valid.arrays valid.booleans.1
      scan.flow.compatible scan.path body functionsValid proceduresValid
    simp only [basicReaders_inherited] at reading checked
    have extended := Applications.inherited_statement_extend reading
      (Packages.functionSignatures environment.packages.signatures)
      (Packages.procedureSignatures environment.packages.signatures) checked
    rw [localFunctions, localProcedures] at extended
    exact ⟨item.lower, .inherited selected rfl reading, SourceStatement.lower_wellFormed wellFormed,
      extended, statement_obligations_discharge extended⟩
  | packageFunction =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_function calls] at selected' accepted'
    obtain ⟨call, reading, _, main⟩ := Basic.function_statement_reading
      textValid valid body scan.storage scan.body_checked typed declared writes selected' accepted'
    simp only [basicReaders_function] at reading main
    obtain ⟨wellFormed, checked, discharged⟩ := main environment packageSignatures
    exact ⟨_, .functionCall rfl selected rfl reading, wellFormed, checked, discharged⟩
  | packageProcedure =>
    have selected' := selected
    have accepted' := accepted
    rw [← basicReaders_procedure calls] at selected' accepted'
    obtain ⟨call, reading, wellFormed, checked, discharged⟩ := Basic.main_procedure_source_statement
      textValid valid body scan.storage scan.body_checked typed sourceNames earlier selected' accepted'
      environment packageSignatures
    simp only [basicReaders_procedure] at checked discharged
    exact ⟨_, .procedureCall rfl selected rfl reading, wellFormed, checked, discharged⟩

end Silver.ApplicationPackageBodies.SourceSyntax
