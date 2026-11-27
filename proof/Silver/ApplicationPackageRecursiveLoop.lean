module

public import Silver.ApplicationPackageRoutineRecursiveTail

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageFrameLayout

set_option backward.dsimp.instances true

theorem package_loop_decoded {readers bound source iteration result}
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (decode : PackageTailInduction readers bound source)
    (present : source.input.scan.position ≠ 0)
    (noIf : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") = 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for") ≠ 0)
    (reading : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for")) iteration result) :
    ∃ code, StatementCodeAt (sourceReaders readers) packageNames source result code ∧
      PackageChecked bound source result code := by
  have childLegal := legal.loopInput reading.header reading.advances
  have childScope := scope.loop legal reading
  obtain ⟨body, original, child⟩ := decode (Statement.innerContext source iteration)
    (Statement.innerInput source iteration (Statement.widened (sourceReaders readers).statement source iteration))
    childLegal childScope (scope.loop_hidden legal reading) reading.advances .endOnly true reading.bodyPresent
  have base := legal.base
  rw [scope.body] at base
  have header := Statement.forHeader_original legal.arrays reading.header
  have binder := Statement.forHeader_binder_after legal.scan.position reading.header
  have fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first := by
    intro state member
    exact Nat.ne_of_gt (Nat.lt_trans (scope.statesBefore state member) binder)
  have agreement := inner_global_agreement bound fresh
  have childChecked := child.check
  dsimp only [atContext] at childChecked
  rw [agreement.statements] at childChecked
  have childBinders := (agreement.localsBinders body).mp child.binders
  have counted : loopIsArray source.text source.input.scan = false := by
    cases iterable : loopIsArray source.text source.input.scan with
    | false => rfl
    | true =>
      have impure := (Statement.arrayHeader_accepted (Statement.forHeader_array iterable reading.header)).1
      rw [scope.pure] at impure
      contradiction
  let childSource : Statement.LoopChildReading := fun context input stop code result =>
    TailCodeAt (sourceReaders readers) packageNames (atContext source context input) stop true false result code
  obtain ⟨lower, upper, sourceLoop, formed, checked⟩ := Statement.counted_source_checked
    (child := childSource)
    (Statement.packageCountedChecker (ApplicationPackageCalls.completedEnvironment source.info)
      (layout bound source.info source.context)
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    reading counted scope.body base.toBaseReady legal.arrays legal.scan.flow.compatible
    original original.nonempty child.form childChecked
  refine ⟨_, .counted present noIf keyword reading counted sourceLoop.1 sourceLoop.2, formed, checked, ?_, ?_⟩
  · have binderLocal : ∃ identity,
        (layout bound source.info source.context).integers (source.context.scalarNames.length + 1) = .local identity := by
      have outside : ¬(0 < source.context.scalarNames.length + 1 ∧
          source.context.scalarNames.length + 1 ≤ (scalarRows source.context).length) := by
        simp only [scalarRows, List.length_map]; omega
      exact ⟨bound + 1 + (source.context.scalarNames.length + 1), by simp only [layout, slotAddress, outside, ite_false]⟩
    simp only [Packages.StatementsLocalBinders, Packages.statementLocalBinders]
    exact ⟨⟨binderLocal, childBinders⟩, trivial⟩
  · intro slot identity global absent
    have mutable := (scalar_global_analysis base.size (base.body rfl) scope.fields.globalRows global).2
    rw [reading.original_result_facts legal.arrays,
      loopAfterHeader_model scope.body (base.body rfl) legal.scan.flow.compatible.count]
    have selected : (loopHeader source.text source.context source.input.scan).isArray = false := counted
    simp only [selected, Bool.false_eq_true, ite_false]
    exact Packages.loopExit_declared _ _ mutable (hidden slot identity global absent)

end Silver.ApplicationPackageBodies.SourceSyntax
