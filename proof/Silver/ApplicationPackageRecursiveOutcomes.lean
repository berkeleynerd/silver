module

public import Silver.ApplicationPackageRecursiveStatement

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

/-- Simultaneous native return contracts and original recursive source trees.
Strong induction uses the remaining original source cursor. At each cursor,
Statement is established first from strictly later child tails, then Tail
folds its original execution using those Statement results. No semantic
validity certificate or recursive contract is assumed. -/
theorem Equations.outcomes {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed) :
    StatementOutcome (nativeReaders readers) source ∧
      ∀ stop required, TailOutcome (nativeReaders readers) source stop required := by
  have all : ∀ remaining, ∀ input : Statement.Input, NativeDomain input → input.info.Typed →
      input.text.length + 1 - input.input.scan.position = remaining →
      StatementOutcome (nativeReaders readers) input ∧
        ∀ stop required, TailOutcome (nativeReaders readers) input stop required := by
    intro remaining
    induction remaining using Nat.strongRecOn with
    | ind remaining ih =>
      have statement : ∀ input : Statement.Input, NativeDomain input → input.info.Typed →
          input.text.length + 1 - input.input.scan.position = remaining →
          StatementOutcome (nativeReaders readers) input := by
        intro input inputLegal inputTyped size
        apply equations.statement_outcome inputLegal inputTyped
        intro context value childLegal advanced stop required
        have childBound : value.scan.position ≤ input.text.length + 1 := childLegal.scan.position
        have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atContext input context value) childLegal inputTyped rfl).2 stop required
      intro input inputLegal inputTyped size
      refine ⟨statement input inputLegal inputTyped size, ?_⟩
      intro stop required
      apply equations.tail_outcome inputLegal stop required
      intro value nextLegal advanced
      have nextBound : value.scan.position ≤ input.text.length + 1 := nextLegal.scan.position
      have inputBound := inputLegal.scan.position
      have smallerOrSame : input.text.length + 1 - value.scan.position ≤ remaining := by omega
      by_cases same : input.text.length + 1 - value.scan.position = remaining
      · exact statement (atInput input value) nextLegal inputTyped same
      · have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atInput input value) nextLegal inputTyped rfl).1
  exact all _ source legal typed rfl

theorem Equations.statement_count {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed) :
    ((nativeReaders readers).statementResult source).count = source.input.count :=
  (equations.outcomes legal typed).1.scan.flow.compatible.count.trans legal.scan.flow.compatible.count.symm

theorem Equations.tail_count {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed)
    (stop : BodyStop) (required : Bool) :
    ((nativeReaders readers).tailResult source stop required).count = source.input.count :=
  ((equations.outcomes legal typed).2 stop required).scan.flow.compatible.count.trans legal.scan.flow.compatible.count.symm

end Silver.ApplicationPackageBodies.Recursive
