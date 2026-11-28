module

public import Silver.ApplicationPackageMainConditionalReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

theorem main_loop_decoded {readers environment cutoff source iteration result}
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (decode : MainTailInduction readers environment cutoff source)
    (present : source.input.scan.position ≠ 0)
    (noIf : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") = 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for") ≠ 0)
    (reading : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for")) iteration result) :
    ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source result code ∧
      MainChecked environment source result code := by
  have childLegal := legal.loopInput reading.header reading.advances
  have childScope := scope.loop legal reading
  obtain ⟨body, original, child⟩ := decode (Statement.innerContext source iteration)
    (Statement.innerInput source iteration (Statement.widened (sourceReaders readers).statement source iteration))
    childLegal childScope reading.advances .endOnly true reading.bodyPresent
  have nonempty := original.nonempty
  have base := legal.base
  rw [scope.body] at base
  have header := Statement.forHeader_original legal.arrays reading.header
  have space := loopNameAllowed_space base.size (Statement.forHeader_name_allowed reading.header header)
  let childSource : Statement.LoopChildReading := fun context input stop code result =>
    TailCodeAt (sourceReaders readers) (mainNames environment) (atContext source context input) stop true false result code
  cases iterable : loopIsArray source.text source.input.scan with
  | false =>
    obtain ⟨lower, upper, sourceLoop, formed, checked⟩ :=
      Statement.counted_source_checked
        (child := childSource)
        (Statement.mainCountedChecker source.context.names.shape
          (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
          environment.functionSignatures environment.procedureSignatures)
        reading iterable scope.body base.toBaseReady legal.arrays legal.scan.flow.compatible
        original nonempty child.form child.check
    refine ⟨_, .counted present noIf keyword reading iterable sourceLoop.1 sourceLoop.2,
      formed, checked, ?_⟩
    intro array apart
    have outside := apart (source.context.scalarNames.length + 1) space
    simp only [statementsBindersApart, Predicate.Statement.bindersApart, outside, not_false_eq_true,
      decide_true, child.binders array apart, Bool.and_self]
  | true =>
    obtain ⟨sourceLoop, formed, checked⟩ := Statement.array_source_checked
      (child := childSource) reading iterable scope.body base.toBaseReady legal.arrays legal.scan.flow.compatible
      original nonempty child.form child.binders child.check
    refine ⟨_, .array present noIf keyword reading iterable sourceLoop.2.2, formed, checked, ?_⟩
    intro array apart
    have outside := apart (source.context.scalarNames.length + 1) space
    simp only [statementsBindersApart, Predicate.Statement.bindersApart, outside, not_false_eq_true,
      decide_true, child.binders array apart, Bool.and_self]

end Silver.ApplicationPackageBodies.SourceSyntax
