module

public import Silver.ApplicationPackageLoopLayout
public import Silver.ApplicationPackageMainRecursiveMeaning

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageCalls ApplicationPackageDeclarations
open ApplicationPackageFrameLayout ApplicationPackageObjectRows ApplicationPackageEffects

set_option backward.dsimp.instances true

/-- A local induction invariant, derived at routine entry from original
metadata, declarations and native lookup. It is not a source certificate. -/
structure PackageScope (source : Statement.Input) : Prop where
  normal : NamesNormal source.context.names
  body : source.context.elaborating = false
  typed : source.info.Typed
  metadata : PackageBindings.validMetadata (ApplicationPackageNames.metadataText source.text) source.info = true
  declared : DeclaredFormalModes source.info
  writes : CompletedFunctionWrites source.info
  pure : source.context.pure = true
  arguments : source.context.hasArguments = false
  shape : source.context.names.shape = Bindings.emptyShape
  arrays : source.context.arrayNames = []
  functions : source.catalog = {}
  procedures : source.procedures = {}
  declarations : StateDeclarations source.text source.info.states
  fields : ScalarStateFields source.info.states source.context.scalarNames
  statesBefore : ∀ state ∈ source.info.states, state.name.first < source.input.scan.position

def HiddenRanges (bound : Nat) (source : Statement.Input) (flow : Flow) : Prop :=
  ∀ slot identity, (layout bound source.info source.context).integers slot = .global identity →
    ¬OriginalLookup source.text source.context (.integer slot) →
    flow.scalars slot = source.context.analysis.declared slot

theorem PackageScope.atInput {source : Statement.Input} (scope : PackageScope source)
    (input : ApplicationScan) (later : source.input.scan.position ≤ input.scan.position) :
    PackageScope (atInput source input) :=
  {scope with statesBefore := fun state member => Nat.lt_of_lt_of_le (scope.statesBefore state member) later}

theorem PackageScope.global_bounds {bound source slot identity}
    (scope : PackageScope source) (legal : NativeDomain source)
    (selected : (layout bound source.info source.context).integers slot = .global identity) :
    ∃ bounds, source.context.analysis.declared slot = some bounds ∧ bounds.isEmpty = false := by
  have base := legal.base
  rw [scope.body] at base
  have fields := scalar_global_analysis base.size (base.body rfl) scope.fields.globalRows selected
  have active := stateIndex_some (slotAddress_global selected).2.2
  have state := PackageBindings.validMetadata_state scope.metadata identity active.1 active.2.1
  simp only [PackageBindings.stateValid, Bool.and_eq_true] at state
  exact ⟨_, fields.1, by simpa only [Bool.not_eq_true'] using state.1.1.2⟩

theorem HiddenRanges.join {bound source before after}
    (scope : PackageScope source) (legal : NativeDomain source)
    (left : HiddenRanges bound source before) (right : HiddenRanges bound source after) :
    HiddenRanges bound source (before.join after) := by
  intro slot identity global hidden
  obtain ⟨bounds, declared, nonempty⟩ := scope.global_bounds legal global
  have a := (left slot identity global hidden).trans declared
  have b := (right slot identity global hidden).trans declared
  exact (Integer.Ranges.join_fixed a b nonempty).trans declared.symm

theorem HiddenRanges.condition {bound source condition result}
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (reading : ConditionAt source.text source.context source.input.scan.position source.input.scan.facts condition result)
    (meaning : ConditionMeaning source.context source.input.scan.facts condition result) :
    HiddenRanges bound source (source.context.flow result.whenTrue) ∧
      HiddenRanges bound source (source.context.flow result.whenFalse) := by
  have both (slot identity : Nat)
      (global : (layout bound source.info source.context).integers slot = .global identity)
      (absent : ¬OriginalLookup source.text source.context (.integer slot)) :
      (source.context.flow result.whenTrue).scalars slot = source.context.analysis.declared slot ∧
      (source.context.flow result.whenFalse).scalars slot = source.context.analysis.declared slot := by
    obtain ⟨bounds, declared, nonempty⟩ := scope.global_bounds legal global
    have preserved := hidden_global_condition_range scope.declarations global absent reading meaning
      ((hidden slot identity global absent).trans declared) nonempty
    exact ⟨preserved.1.trans declared.symm, preserved.2.trans declared.symm⟩
  exact ⟨fun slot identity global absent => (both slot identity global absent).1,
    fun slot identity global absent => (both slot identity global absent).2⟩

theorem PackageScope.loop {source readers iteration result}
    (scope : PackageScope source) (legal : NativeDomain source)
    (reading : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for"))
      iteration result) : PackageScope (loopChild (sourceReaders readers).statement source iteration) := by
  have binder := Statement.forHeader_binder_after legal.scan.position reading.header
  have fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first := by
    intro state member
    exact Nat.ne_of_gt (Nat.lt_trans (scope.statesBefore state member) binder)
  exact ⟨scope.normal, scope.body, scope.typed, scope.metadata, scope.declared, scope.writes,
    scope.pure, scope.arguments, scope.shape, scope.arrays, scope.functions, scope.procedures,
    scope.declarations, inner_scalar_fields scope.fields fresh,
    fun state member => Nat.lt_trans (scope.statesBefore state member) reading.advances⟩

theorem PackageScope.loop_hidden {bound source readers iteration result}
    (scope : PackageScope source) (legal : NativeDomain source)
    (reading : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for"))
      iteration result) :
    HiddenRanges bound (loopChild (sourceReaders readers).statement source iteration)
      ((Statement.innerContext source iteration).flow
        (Statement.innerInput source iteration (Statement.widened (sourceReaders readers).statement source iteration)).scan.facts) := by
  have binder := Statement.forHeader_binder_after legal.scan.position reading.header
  have fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first := by
    intro state member
    exact Nat.ne_of_gt (Nat.lt_trans (scope.statesBefore state member) binder)
  have original := Statement.forHeader_original legal.arrays reading.header
  have base := legal.base
  rw [scope.body] at base
  have space := loopNameAllowed_space base.size (Statement.forHeader_name_allowed reading.header original)
  intro slot identity selected _
  exact inner_global_range bound original fresh scope.fields scope.body base.toBaseReady
    legal.scan.flow.compatible.count space selected

theorem PackageScope.basic_reading {bound source readers}
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (accepted : (applicationBasic (sourceReaders readers).basic source.text source.context source.input
      source.info source.catalog source.procedures).scan.position ≠ 0) :
    let result := applicationBasic (sourceReaders readers).basic source.text source.context source.input
      source.info source.catalog source.procedures
    let bools := ArrayBindings.booleanAnalysis source.context.arrayNames
      (BooleanBindings.analysis source.context.booleanNames)
    ∃ item, BasicCodeAt (sourceReaders readers).basic packageNames source result item ∧
      item.WellFormed source.context.hasArguments source.context.names.shape bools ∧
      Packages.checkPackageStatement (completedEnvironment source.info) (layout bound source.info source.context)
        source.context.analysis (source.context.flow source.input.scan.facts) bools item =
          some (source.context.flow result.scan.facts) ∧
      HiddenRanges bound source (source.context.flow result.scan.facts) := by
  obtain ⟨native, same, valid⟩ := legal.context
  rcases source with ⟨text, context, input, info, catalog, procedures⟩
  dsimp only at same
  subst context
  have emptyFunctions : catalog = {} := scope.functions
  have emptyProcedures : procedures = {} := scope.procedures
  subst catalog procedures
  obtain ⟨item, original, form, checked, _, preserved⟩ := package_basic_hidden_reading legal.text valid
    scope.normal scope.body legal.scan scope.typed scope.declared scope.writes scope.pure scope.arguments
    scope.shape scope.declarations scope.fields bound hidden accepted
  exact ⟨item, original, form, checked,
    fun slot identity global absent => (preserved slot identity global absent).trans (hidden slot identity global absent)⟩

end Silver.ApplicationPackageBodies.SourceSyntax
