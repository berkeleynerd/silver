module

public import Silver.PredicateBodyReadings
public import Silver.PredicateConditionValidity
public import Silver.PredicateBodyBounds
public import Silver.PredicateBodyFlow
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

attribute [local irreducible] ScalarExpression.read

/-- Appending a lexical index changes precisely its fresh scalar identity.
The declaration prefix is retained, so the new readonly name is refinable. -/
theorem analysis_append_index (names : ScalarExpression.Environment) (declarations : Nat)
    (item : ScalarExpression.Binding) (declarationsBound : declarations ≤ names.length)
    (immutable : item.mutable = false) (nonstatic : item.isStatic = false) :
    ScalarMetadata.analysis (names ++ [item]) declarations =
      (ScalarMetadata.analysis names declarations).withIndex (names.length + 1) item.bounds := by
  unfold ScalarMetadata.analysis Integer.Analysis.withIndex
  simp only [ScalarExpression.ranges_append, ScalarExpression.mutability_append, immutable]
  congr 1
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.staticness, Integer.put, ScalarExpression.binding_append_new, nonstatic]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.refinable, Integer.put, ScalarExpression.binding_append_new,
        immutable, show declarations < names.length + 1 by omega]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]

theorem loopInner_analysis {context : ParseContext} (header : LoopHeader)
    (declarationsBound : context.declarationCount ≤ context.scalarNames.length) :
    (loopInner context header).analysis = context.analysis.withIndex (context.scalarNames.length + 1)
      (Integer.loopBounds header.lower.bounds header.upper.bounds) :=
  analysis_append_index _ _ _ declarationsBound rfl rfl

theorem loopInner_baseReady {context : ParseContext} (header : LoopHeader)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount) :
    ScalarMetadata.BaseReady (loopInner context header).scalarNames (loopInner context header).declarationCount := by
  refine ⟨ScalarExpression.bodyReady_append base.body (by simp), ?_, ?_, ?_⟩
  · simp only [loopInner, List.length_append, List.length_singleton]
    exact Nat.le_trans base.count (Nat.le_succ _)
  · intro index positive declared
    have old : index ≤ context.scalarNames.length := Nat.le_trans declared base.count
    simpa only [loopInner, ScalarExpression.binding_append_old _ _ _ positive old] using
      base.declarationsNonempty index positive declared
  · intro index positive bounded mutable
    have bound : index ≤ context.scalarNames.length + 1 := by
      simpa only [loopInner, List.length_append, List.length_singleton] using bounded
    dsimp only [loopInner] at mutable ⊢
    by_cases old : index ≤ context.scalarNames.length
    · rw [ScalarExpression.binding_append_old _ _ index positive old] at mutable ⊢
      exact base.mutableNonempty index positive old mutable
    · have fresh : index = context.scalarNames.length + 1 := by omega
      subst index
      simp only [ScalarExpression.binding_append_new, Bool.false_eq_true] at mutable

theorem loopHeader_model {text : Source} {context : ParseContext} {scan : BodyScan}
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : scan.count = context.scalarNames.length) :
    (loopHeader text context scan).entry.facts.model =
      loopEntry context.analysis scan.facts.model (context.scalarNames.length + 1)
        (Integer.loopBounds (loopHeader text context scan).lower.bounds
          (loopHeader text context scan).upper.bounds) := by
  let bounds := Integer.loopBounds (loopHeader text context scan).lower.bounds
    (loopHeader text context scan).upper.bounds
  change scan.facts.count = context.scalarNames.length at count
  change (⟨loopContext scan.facts.path bounds,
    ((ActiveFlow.widen context.scalarNames scan.facts).append bounds).model.scalars⟩ : Flow) = _
  rw [ActiveFlow.append_model,
    ActiveFlow.widen_model context.scalarNames context.declarationCount scan.facts count ready,
    ActiveFlow.widen_count context.scalarNames scan.facts count, count]
  rfl

theorem loopHeader_compatible {text : Source} {context : ParseContext} {scan : BodyScan}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts) :
    ScalarMetadata.OverlayCompatible (loopInner context (loopHeader text context scan)).scalarNames
      (loopInner context (loopHeader text context scan)).declarationCount
      (loopHeader text context scan).entry.facts := by
  refine ⟨?_, ?_⟩
  · simpa only [loopInner, List.length_append, List.length_singleton, BodyScan.count] using
      loopHeader_count text context scan compatible.count
  · intro index positive bounded mutable declared
    have old : index ≤ context.scalarNames.length := Nat.le_trans declared base.count
    have bindingEq : ScalarExpression.binding
        (loopInner context (loopHeader text context scan)).scalarNames index =
        ScalarExpression.binding context.scalarNames index :=
      ScalarExpression.binding_append_old _ _ _ positive old
    rw [bindingEq] at mutable ⊢
    have readonly : context.analysis.mutable index = false := by
      simp only [ParseContext.analysis, ScalarMetadata.analysis, ScalarExpression.mutability,
        show 0 < index ∧ index ≤ context.scalarNames.length from ⟨positive, old⟩,
        and_self, decide_true, Bool.true_and, mutable]
    have cell := compatible.fixed_cell index positive old mutable declared
    have entryCell : (loopHeader text context scan).entry.facts.model.scalars index =
        some (ScalarExpression.binding context.scalarNames index).bounds := by
      rw [loopHeader_model base.body compatible.count]
      simpa only [loopEntry, Integer.put, show index ≠ context.scalarNames.length + 1 by omega,
        ↓reduceIte, Integer.Analysis.widen, readonly, Bool.false_eq_true] using cell
    change ActiveFlow.ranges (loopHeader text context scan).entry.facts.values index = _ at entryCell
    simp only [ActiveFlow.ranges, show index ≠ 0 by omega, ↓reduceIte] at entryCell
    simp only [List.getD_eq_getElem?_getD, entryCell, Option.getD_some]

theorem loopAfterFlow_model {context : ParseContext} {before after : ActiveFlow}
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : before.count = context.scalarNames.length) (lower upper : Integer.Interval) :
    (loopAfterFlow context before after lower upper).model =
      loopExit context.analysis before.model after.model lower upper := by
  have widened := congrArg Flow.scalars
    (ActiveFlow.widen_model context.scalarNames context.declarationCount before count ready)
  cases empty : (Integer.loopBounds lower upper).isEmpty with
  | true => simp only [loopAfterFlow, loopExit, empty, ↓reduceIte, ActiveFlow.model]
  | false =>
      simp only [loopAfterFlow, loopExit, empty, Bool.false_eq_true, ↓reduceIte]
      exact congrArg (fun ranges => Flow.mk (loopAfter before.path after.path lower upper) ranges) widened

private theorem checked_statement_compatible {context : ParseContext} {before after : ActiveFlow}
    {item : Statement} (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount before)
    (checked : item.check context.names.shape context.analysis before.model = some after.model)
    (count : after.count = context.scalarNames.length) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount after := by
  apply ScalarMetadata.overlayCompatible_of_preserved compatible count
  intro index positive bounded mutable declared
  have readonly : context.analysis.mutable index = false := by
    simp only [ParseContext.analysis, ScalarMetadata.analysis, ScalarExpression.mutability,
      show 0 < index ∧ index ≤ context.scalarNames.length from ⟨positive, bounded⟩,
      and_self, decide_true, Bool.true_and, mutable]
  have fixed : context.analysis.refinable index = false := by
    simp only [ParseContext.analysis, ScalarMetadata.analysis, ScalarMetadata.refinable,
      mutable, Bool.false_or, show ¬context.declarationCount < index by omega,
      decide_false, Bool.and_false]
  have cell := compatible.fixed_cell index positive bounded mutable declared
  exact (statement_preserves_fixed checked readonly fixed cell
    (base.declarationsNonempty index positive declared)).trans cell.symm

private theorem basic_bounded {text context scan item result}
    (bounded : scan.facts.path.Bounded) (parsed : BasicAt text context scan item result) :
    result.facts.path.Bounded := by
  have resultBound := basicBody_factsBounded text context scan bounded
  rw [parsed.equation] at resultBound
  exact resultBound

private theorem branch_meaning {text context scan keyword condition}
    (normal : NamesNormal context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (nv : Compose.Expressions.ValidNames text context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (bounded : scan.facts.path.Bounded) (parsed : BranchAt text context scan keyword condition) :
    condition.Grammatical ∧ condition.Readable context.hasArguments context.names.shape ∧
    condition.checkBounds context.names.shape context.analysis scan.facts.model = true ∧
    (branchStart text context scan keyword).1.facts.model =
      condition.refine context.names.shape context.analysis scan.facts.model true ∧
    (branchStart text context scan keyword).2.model =
      condition.refine context.names.shape context.analysis scan.facts.model false := by
  have meaning := condition_valid normal nv base compatible bounded parsed
  exact ⟨meaning.grammatical, meaning.readable, meaning.checked, meaning.whenTrue, meaning.whenFalse⟩

private theorem branch_compatible {text context scan keyword condition}
    (normal : NamesNormal context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (nv : Compose.Expressions.ValidNames text context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (bounded : scan.facts.path.Bounded) (parsed : BranchAt text context scan keyword condition) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
      (branchStart text context scan keyword).1.facts ∧
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
      (branchStart text context scan keyword).2 := by
  have meaning := condition_valid normal nv base compatible bounded parsed
  have counts := condition_counts text context (bodyToken text scan (.word keyword)).position scan.facts
  exact meaning.compatible base compatible
    (counts.1.trans compatible.count) (counts.2.trans compatible.count)

mutual
  theorem statement_meaning {text context scan item result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : StatementAt text context scan item result) :
      item.WellFormed context.hasArguments context.names.shape ∧
      item.lower.check context.names.shape context.analysis scan.facts.model = some result.facts.model ∧
      result.facts.path.Bounded := by
    cases parsed with
    | basic _ _ _ reading _ =>
        have meaning := basic_meaning normal base.body compatible reading
        exact ⟨meaning.1, meaning.2, basic_bounded bounded reading⟩
    | choice _ _ reading _ => exact choice_meaning normal base nv compatible bounded reading
    | loop _ _ _ reading _ => exact loop_meaning normal base nv compatible bounded reading
  termination_by (bodyRemaining text scan, 2)

  theorem loop_meaning {text context scan lower upper body result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : LoopAt text context scan lower upper body result) :
      (SourceStatement.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        lower upper body).WellFormed context.hasArguments context.names.shape ∧
      (SourceStatement.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        lower upper body).lower.check context.names.shape context.analysis scan.facts.model =
          some result.facts.model ∧ result.facts.path.Bounded := by
    cases parsed with
    | loop _ lowerRead upperRead _ bodyRead resultEq _ _ =>
        have bodyGood := body_meaning (context := loopInner context (loopHeader text context scan))
          (scan := (loopHeader text context scan).entry) normal
          (loopInner_baseReady _ base) nv (loopHeader_compatible base compatible)
          (loopContext_bounded bounded _) bodyRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        have ranges : ScalarExpression.ranges (context.readingNames scan.facts) = scan.facts.model.scalars :=
          ScalarMetadata.readingNames_ranges compatible
        have lowerInferred := lowerRead.inferred
        have upperInferred := upperRead.inferred
        rw [ranges] at lowerInferred upperInferred
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨by omega, body_nonempty bodyRead, bodyGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, lowerInferred, upperInferred, Option.bind_some]
          have checked := bodyGood.2.1
          rw [loopInner_analysis _ base.count, loopHeader_model base.body compatible.count] at checked
          simp only [loopInner] at checked
          rw [checked]
          simp only [Option.map_some, factsEq, loopAfterFlow_model base.body compatible.count]
        · rw [factsEq]
          exact loopAfter_bounded bounded bodyGood.2.2 _ _
  termination_by (bodyRemaining text scan, 1)

  theorem choice_meaning {text context scan condition yes tail result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : ChoiceAt text context scan condition yes tail result) :
      (SourceStatement.choice condition yes tail).WellFormed context.hasArguments context.names.shape ∧
      (SourceStatement.choice condition yes tail).lower.check context.names.shape context.analysis scan.facts.model =
        some result.facts.model ∧ result.facts.path.Bounded := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning normal base nv compatible bounded conditionRead
        have branches := branch_compatible normal base nv compatible bounded conditionRead
        have yesBound : (branchStart text context scan "if").1.facts.path.Bounded := by
          change (branchStart text context scan "if").1.facts.model.path.Bounded
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _ _
        have noBound : (branchStart text context scan "if").2.path.Bounded := by
          change (branchStart text context scan "if").2.model.path.Bounded
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _ _
        have yesGood := body_meaning normal base nv branches.1 yesBound yesRead
        have noGood := alternative_meaning normal base nv branches.2 noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, factsEq, ActiveFlow.join_model]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_meaning {text context scan tail result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : AlternativeAt text context scan tail result) :
      tail.WellFormed context.hasArguments context.names.shape ∧
      checkStatements context.names.shape context.analysis scan.facts.model tail.lower = some result.facts.model ∧
      result.facts.path.Bounded := by
    cases parsed with
    | absent =>
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | otherwise _ _ _ _ body _ =>
        have good := body_meaning (scan := bodyToken text scan (.word "else")) normal base nv compatible bounded body
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower]
        exact ⟨⟨body_nonempty body, good.1⟩, good.2⟩
    | elsif _ _ conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning normal base nv compatible bounded conditionRead
        have branches := branch_compatible normal base nv compatible bounded conditionRead
        have yesBound : (branchStart text context scan "elsif").1.facts.path.Bounded := by
          change (branchStart text context scan "elsif").1.facts.model.path.Bounded
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _ _
        have noBound : (branchStart text context scan "elsif").2.path.Bounded := by
          change (branchStart text context scan "elsif").2.model.path.Bounded
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _ _
        have yesGood := body_meaning normal base nv branches.1 yesBound yesRead
        have noGood := alternative_meaning normal base nv branches.2 noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceAlternative.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceAlternative.lower, checkStatements, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, Option.bind_some, factsEq, ActiveFlow.join_model]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_meaning {text context stop scan items result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : BodyTailAt text context stop scan items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items ∧
      checkStatements context.names.shape context.analysis scan.facts.model (lowerStatements items) =
        some result.facts.model ∧ result.facts.path.Bounded := by
    cases parsed with
    | done =>
        simp only [SourceStatementsWellFormed, lowerStatements, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | next _ _ item _ rest _ =>
        have first := statement_meaning normal base nv compatible bounded item
        have count := statementBody_count text context scan compatible.count
        rw [statement_complete item] at count
        have nextCompatible := checked_statement_compatible base compatible first.2.1 count
        have following := bodyTail_meaning normal base nv nextCompatible first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)

  theorem body_meaning {text context stop scan items result}
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : BodyAt text context scan stop items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items ∧
      checkStatements context.names.shape context.analysis scan.facts.model (lowerStatements items) =
        some result.facts.model ∧ result.facts.path.Bounded := by
    cases parsed with
    | cons item _ rest _ =>
        have first := statement_meaning normal base nv compatible bounded item
        have count := statementBody_count text context scan compatible.count
        rw [statement_complete item] at count
        have nextCompatible := checked_statement_compatible base compatible first.2.1 count
        have following := bodyTail_meaning normal base nv nextCompatible first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
