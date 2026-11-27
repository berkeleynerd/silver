module

public import Silver.ApplicationPackageSemanticConditionalReading
public import Silver.ApplicationPackageRecursiveLoop

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

theorem package_statement_decoded {readers bound source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (decode : PackageTailInduction readers bound source)
    (accepted : ((sourceReaders readers).statementResult source).scan.position ≠ 0) :
    ∃ code, StatementCodeAt (sourceReaders readers) packageNames source
        ((sourceReaders readers).statementResult source) code ∧
      PackageChecked bound source ((sourceReaders readers).statementResult source) code := by
  have reading := equations.statement_reading legal accepted
  generalize resultEq : (sourceReaders readers).statementResult source = result at reading accepted ⊢
  cases reading with
  | basic present noIf noFor => exact package_basic_decoded equations scope legal hidden present noIf noFor accepted
  | conditional present keyword arms closing =>
    exact package_conditional_decoded equations scope legal hidden decode present keyword arms closing
  | iteration present noIf keyword loop => exact package_loop_decoded scope legal hidden decode present noIf keyword loop

/-- Accepted original recursive package readers construct source-only syntax and
derive the complete package routine checker on every arm and loop body. Strong
induction uses original cursor progress; no successful semantic decoder, child
checker or safety result remains as an external premise. -/
theorem package_recursive_meaning {readers bound source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts)) :
    (((sourceReaders readers).statementResult source).scan.position ≠ 0 →
      ∃ code, StatementCodeAt (sourceReaders readers) packageNames source
          ((sourceReaders readers).statementResult source) code ∧
        PackageChecked bound source ((sourceReaders readers).statementResult source) code) ∧
    (∀ stop required, ((sourceReaders readers).tailResult source stop required).scan.position ≠ 0 →
      ∃ code, TailCodeAt (sourceReaders readers) packageNames source stop required false
          ((sourceReaders readers).tailResult source stop required) code ∧
        PackageChecked bound source ((sourceReaders readers).tailResult source stop required) code) := by
  have all : ∀ remaining, ∀ input : Statement.Input, NativeDomain input →
      PackageScope input → HiddenRanges bound input (input.context.flow input.input.scan.facts) →
      input.text.length + 1 - input.input.scan.position = remaining →
      (((sourceReaders readers).statementResult input).scan.position ≠ 0 →
        ∃ code, StatementCodeAt (sourceReaders readers) packageNames input
            ((sourceReaders readers).statementResult input) code ∧
          PackageChecked bound input ((sourceReaders readers).statementResult input) code) ∧
      (∀ stop required, ((sourceReaders readers).tailResult input stop required).scan.position ≠ 0 →
        ∃ code, TailCodeAt (sourceReaders readers) packageNames input stop required false
            ((sourceReaders readers).tailResult input stop required) code ∧
          PackageChecked bound input ((sourceReaders readers).tailResult input stop required) code) := by
    intro remaining
    induction remaining using Nat.strongRecOn with
    | ind remaining ih =>
      have statement : ∀ input : Statement.Input, NativeDomain input → PackageScope input →
          HiddenRanges bound input (input.context.flow input.input.scan.facts) →
          input.text.length + 1 - input.input.scan.position = remaining →
          ((sourceReaders readers).statementResult input).scan.position ≠ 0 →
          ∃ code, StatementCodeAt (sourceReaders readers) packageNames input
              ((sourceReaders readers).statementResult input) code ∧
            PackageChecked bound input ((sourceReaders readers).statementResult input) code := by
        intro input inputLegal inputScope inputHidden size accepted
        apply package_statement_decoded equations inputScope inputLegal inputHidden ?_ accepted
        intro context value childLegal childScope childHidden advanced stop required present
        have bound : value.scan.position ≤ input.text.length + 1 := childLegal.scan.position
        have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atContext input context value) childLegal childScope childHidden rfl).2 stop required present
      intro input inputLegal inputScope inputHidden size
      refine ⟨statement input inputLegal inputScope inputHidden size, ?_⟩
      intro stop required accepted
      apply package_tail_decoded equations inputLegal inputScope inputHidden ?_ accepted
      intro value nextLegal nextScope nextHidden advanced present
      have nextBound : value.scan.position ≤ input.text.length + 1 := nextLegal.scan.position
      have inputBound := inputLegal.scan.position
      have smallerOrSame : input.text.length + 1 - value.scan.position ≤ remaining := by omega
      by_cases same : input.text.length + 1 - value.scan.position = remaining
      · exact statement (atInput input value) nextLegal nextScope nextHidden same present
      · have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atInput input value) nextLegal nextScope nextHidden rfl).1 present
  exact all _ source legal scope hidden rfl

end Silver.ApplicationPackageBodies.SourceSyntax
