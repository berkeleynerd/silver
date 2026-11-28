module

public import Silver.ApplicationPackageMainRecursiveTail
public import Silver.ApplicationPackageMainLoopReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

theorem main_statement_decoded {readers environment cutoff source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (decode : MainTailInduction readers environment cutoff source)
    (accepted : ((sourceReaders readers).statementResult source).scan.position ≠ 0) :
    ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source
        ((sourceReaders readers).statementResult source) code ∧
      MainChecked environment source ((sourceReaders readers).statementResult source) code := by
  have reading := equations.statement_reading legal accepted
  generalize resultEq : (sourceReaders readers).statementResult source = result at reading accepted ⊢
  cases reading with
  | basic present noIf noFor => exact main_basic_decoded equations scope legal present noIf noFor accepted
  | conditional present keyword arms closing =>
    exact main_conditional_decoded equations scope legal decode present keyword arms closing
  | iteration present noIf keyword loop => exact main_loop_decoded scope legal decode present noIf keyword loop

/-- Accepted original recursive Main readers construct source-only syntax and
derive the complete combined-table checker on every arm and loop body. Strong
induction uses original cursor progress; no successful semantic decoder, child
checker or safety result remains as an external premise. -/
theorem main_recursive_meaning {readers environment cutoff source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : MainScope environment cutoff source) (legal : NativeDomain source) :
    (((sourceReaders readers).statementResult source).scan.position ≠ 0 →
      ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source
          ((sourceReaders readers).statementResult source) code ∧
        MainChecked environment source ((sourceReaders readers).statementResult source) code) ∧
    (∀ stop required, ((sourceReaders readers).tailResult source stop required).scan.position ≠ 0 →
      ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment) source stop required false
          ((sourceReaders readers).tailResult source stop required) code ∧
        MainChecked environment source ((sourceReaders readers).tailResult source stop required) code) := by
  have all : ∀ remaining, ∀ input : Statement.Input, NativeDomain input →
      MainScope environment cutoff input → input.text.length + 1 - input.input.scan.position = remaining →
      (((sourceReaders readers).statementResult input).scan.position ≠ 0 →
        ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) input
            ((sourceReaders readers).statementResult input) code ∧
          MainChecked environment input ((sourceReaders readers).statementResult input) code) ∧
      (∀ stop required, ((sourceReaders readers).tailResult input stop required).scan.position ≠ 0 →
        ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment) input stop required false
            ((sourceReaders readers).tailResult input stop required) code ∧
          MainChecked environment input ((sourceReaders readers).tailResult input stop required) code) := by
    intro remaining
    induction remaining using Nat.strongRecOn with
    | ind remaining ih =>
      have statement : ∀ input : Statement.Input, NativeDomain input → MainScope environment cutoff input →
          input.text.length + 1 - input.input.scan.position = remaining →
          ((sourceReaders readers).statementResult input).scan.position ≠ 0 →
          ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) input
              ((sourceReaders readers).statementResult input) code ∧
            MainChecked environment input ((sourceReaders readers).statementResult input) code := by
        intro input inputLegal inputScope size accepted
        apply main_statement_decoded equations inputScope inputLegal ?_ accepted
        intro context value childLegal childScope advanced stop required present
        have bound : value.scan.position ≤ input.text.length + 1 := childLegal.scan.position
        have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atContext input context value) childLegal childScope rfl).2 stop required present
      intro input inputLegal inputScope size
      refine ⟨statement input inputLegal inputScope size, ?_⟩
      intro stop required accepted
      apply main_tail_decoded equations inputLegal inputScope ?_ accepted
      intro value nextLegal nextScope advanced present
      have nextBound : value.scan.position ≤ input.text.length + 1 := nextLegal.scan.position
      have inputBound := inputLegal.scan.position
      have smallerOrSame : input.text.length + 1 - value.scan.position ≤ remaining := by omega
      by_cases same : input.text.length + 1 - value.scan.position = remaining
      · exact statement (atInput input value) nextLegal nextScope same present
      · have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atInput input value) nextLegal nextScope rfl).1 present
  exact all _ source legal scope rfl

end Silver.ApplicationPackageBodies.SourceSyntax
