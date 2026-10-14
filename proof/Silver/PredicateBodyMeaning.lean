module

public import Silver.PredicateBodyReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

private theorem basic_bounded {text context scan item result}
    (normal : NamesNormal context.names) (bounded : scan.facts.Bounded)
    (parsed : BasicAt text context scan item result) : result.facts.Bounded := by
  have checked := (basic_meaning normal parsed).2
  cases parsed.payload with
  | null _ | output _ _ | assignment _ _ _ =>
      simp only [SourceStatement.lower, Statement.check] at checked
      split at checked
      · have same := Option.some.inj checked
        rw [← same]
        exact bounded
      · contradiction
  | reject _ =>
      simp only [SourceStatement.lower, Statement.check] at checked
      have same := Option.some.inj checked
      rw [← same]
      exact Context.reject_bounded bounded

private theorem branch_meaning {text context scan keyword condition}
    (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.facts.Bounded) (parsed : BranchAt text context scan keyword condition) :
    condition.Grammatical ∧ condition.Readable context.hasArguments context.names.shape ∧
    condition.checkBounds context.names.shape scan.facts = true ∧
    (branchStart text context scan keyword).1.facts = condition.refine context.names.shape scan.facts true ∧
    (branchStart text context scan keyword).2 = condition.refine context.names.shape scan.facts false := by
  have meaning := condition_valid normal nv bounded parsed
  exact ⟨meaning.grammatical, meaning.readable, meaning.checked, meaning.whenTrue, meaning.whenFalse⟩

mutual
  theorem statement_meaning {text context scan item result}
      (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
      (bounded : scan.facts.Bounded) (parsed : StatementAt text context scan item result) :
      item.WellFormed context.hasArguments context.names.shape ∧
      item.lower.check context.names.shape scan.facts = some result.facts ∧ result.facts.Bounded := by
    cases parsed with
    | basic _ _ reading _ =>
        have meaning := basic_meaning normal reading
        exact ⟨meaning.1, meaning.2, basic_bounded normal bounded reading⟩
    | choice _ _ reading _ => exact choice_meaning normal nv bounded reading
  termination_by (bodyRemaining text scan, 2)

  theorem choice_meaning {text context scan condition yes tail result}
      (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
      (bounded : scan.facts.Bounded) (parsed : ChoiceAt text context scan condition yes tail result) :
      (SourceStatement.choice condition yes tail).WellFormed context.hasArguments context.names.shape ∧
      (SourceStatement.choice condition yes tail).lower.check context.names.shape scan.facts = some result.facts ∧ result.facts.Bounded := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning normal nv bounded conditionRead
        have yesBound : (branchStart text context scan "if").1.facts.Bounded := by
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _
        have noBound : (branchStart text context scan "if").2.Bounded := by
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _
        have yesGood := body_meaning normal nv yesBound yesRead
        have noGood := alternative_meaning normal nv noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, factsEq]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_meaning {text context scan tail result}
      (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
      (bounded : scan.facts.Bounded) (parsed : AlternativeAt text context scan tail result) :
      tail.WellFormed context.hasArguments context.names.shape ∧
      checkStatements context.names.shape scan.facts tail.lower = some result.facts ∧ result.facts.Bounded := by
    cases parsed with
    | absent =>
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | otherwise _ _ _ _ body _ =>
        have good := body_meaning (scan := bodyToken text scan (.word "else")) normal nv bounded body
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower]
        exact ⟨⟨body_nonempty body, good.1⟩, good.2⟩
    | elsif _ _ conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning normal nv bounded conditionRead
        have yesBound : (branchStart text context scan "elsif").1.facts.Bounded := by
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _
        have noBound : (branchStart text context scan "elsif").2.Bounded := by
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _
        have yesGood := body_meaning normal nv yesBound yesRead
        have noGood := alternative_meaning normal nv noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceAlternative.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceAlternative.lower, checkStatements, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, Option.bind_some, factsEq]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_meaning {text context stop scan items result}
      (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
      (bounded : scan.facts.Bounded) (parsed : BodyTailAt text context stop scan items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items ∧
      checkStatements context.names.shape scan.facts (lowerStatements items) = some result.facts ∧ result.facts.Bounded := by
    cases parsed with
    | done =>
        simp only [SourceStatementsWellFormed, lowerStatements, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | next _ _ item _ rest _ =>
        have first := statement_meaning normal nv bounded item
        have following := bodyTail_meaning normal nv first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)

  theorem body_meaning {text context stop scan items result}
      (normal : NamesNormal context.names) (nv : Compose.Expressions.ValidNames text context.names)
      (bounded : scan.facts.Bounded) (parsed : BodyAt text context scan stop items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items ∧
      checkStatements context.names.shape scan.facts (lowerStatements items) = some result.facts ∧ result.facts.Bounded := by
    cases parsed with
    | cons item _ rest _ =>
        have first := statement_meaning normal nv bounded item
        have following := bodyTail_meaning normal nv first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
