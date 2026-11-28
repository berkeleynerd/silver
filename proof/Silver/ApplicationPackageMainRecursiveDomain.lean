module

public import Silver.ApplicationPackageMainBasicReading
public import Silver.ApplicationPackageRecursiveSyntaxProperties

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageCalls ApplicationPackageDeclarations

set_option backward.dsimp.instances true

/-- Complete primitive interpretations used by the semantic source decoder.
The original recursive Basic/Statement/Tail invocations remain explicit. -/
def sourceReaders (readers : Readers) : Readers :=
  {nativeReaders readers with basic := basicReaders readers.basic}

theorem sourceReaders_native (readers : Readers) :
    nativeReaders (sourceReaders readers) = sourceReaders readers := rfl

/-- Representation and original declaration-origin invariants at a Main body
call. This is a local induction invariant, derived from original declaration
histories at entry; it is not a field of the source-meaning representation. -/
structure MainScope (environment : Applications.Environment) (cutoff : Nat)
    (source : Statement.Input) : Prop where
  normal : NamesNormal source.context.names
  body : source.context.elaborating = false
  typed : source.info.Typed
  declared : DeclaredFormalModes source.info
  writes : CompletedFunctionWrites source.info
  origins : ApplicationPackageMain.ScalarsFrom cutoff source.context.scalarNames
  states : ∀ state ∈ source.info.states, state.name.first < cutoff
  position : cutoff ≤ source.input.scan.position
  packages : environment.packages.signatures = (completedEnvironment source.info).map Packages.RoutineEffects.signature
  functions : catalogSignatures source.catalog source.context.arrayTypes = environment.localFunctions.signatures
  procedures : ProcedureBindings.catalogSignatures source.procedures source.context.arrayTypes =
    environment.localProcedures.signatures

theorem MainScope.atInput {environment cutoff source} (scope : MainScope environment cutoff source)
    (input : ApplicationScan) (later : source.input.scan.position ≤ input.scan.position) :
    MainScope environment cutoff (atInput source input) :=
  {scope with position := Nat.le_trans scope.position later}

theorem MainScope.loop {environment cutoff source readers iteration result}
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (reading : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for"))
      iteration result) :
    MainScope environment cutoff (loopChild (sourceReaders readers).statement source iteration) := by
  have binder := Statement.forHeader_binder_after legal.scan.position reading.header
  exact ⟨scope.normal, scope.body, scope.typed, scope.declared, scope.writes,
    scope.origins.append (Nat.le_trans scope.position (Nat.le_of_lt binder)), scope.states,
    Nat.le_trans scope.position (Nat.le_of_lt reading.advances),
    scope.packages, scope.functions, scope.procedures⟩

/-- Leaf source/check construction on the actual recursive decoder domain.
The normalized native guard is proved from that domain; it is not added as a
successful-check hypothesis at the source endpoint. -/
theorem MainScope.basic_reading {environment cutoff source readers}
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (accepted : (applicationBasic (sourceReaders readers).basic source.text source.context source.input
      source.info source.catalog source.procedures).scan.position ≠ 0) :
    let result := applicationBasic (sourceReaders readers).basic source.text source.context source.input
      source.info source.catalog source.procedures
    let bools := ArrayBindings.booleanAnalysis source.context.arrayNames
      (BooleanBindings.analysis source.context.booleanNames)
    ∃ item, BasicCodeAt (sourceReaders readers).basic (mainNames environment) source result item ∧
      item.WellFormed source.context.hasArguments source.context.names.shape bools ∧
      item.check source.context.names.shape source.context.analysis (source.context.flow source.input.scan.facts)
        bools environment.functionSignatures environment.procedureSignatures =
          some (source.context.flow result.scan.facts) := by
  obtain ⟨native, same, valid⟩ := legal.context
  rcases source with ⟨text, context, input, info, catalog, procedures⟩
  dsimp only at same
  subst context
  obtain ⟨item, read, form, checked, _⟩ := main_basic_reading legal.text valid scope.normal scope.body
    legal.scan legal.functions legal.procedures scope.typed scope.declared scope.writes scope.origins scope.states
    environment scope.packages scope.functions scope.procedures accepted
  exact ⟨item, read, form, checked⟩

end Silver.ApplicationPackageBodies.SourceSyntax
