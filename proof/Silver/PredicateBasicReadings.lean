module

public import Silver.PredicateBodyProperties
public import Silver.PredicateConditionUnique

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

abbrev outputStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  {scan with
    position := Names.associationAfter text
      (fixedAfter text (callAfter text context.names scan.position .output) "(" false) false}
abbrev assignmentTarget (text : Source) (context : ParseContext) (scan : BodyScan) : ParserState :=
  targetAt text (parserState context scan) false
abbrev assignmentStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  bodyToken text {scan with position := (assignmentTarget text context scan).position, target := (assignmentTarget text context scan).target} (.symbol ":=")

/-- Source operands and mutable target names are retained independently of the
cursor scanner. The successful trace supplies only concrete admission guards. -/
inductive BasicPayload (text : Source) (context : ParseContext) (scan : BodyScan) : SourceStatement → Prop
  | null : basicKind text context scan = .null → BasicPayload text context scan (.simple .null)
  | output {expression} : basicKind text context scan = .output →
      ExpressionAt text context.names (outputStart text context scan).position expression
        (expressionAt text (outputStart text context scan).position context.names) →
      BasicPayload text context scan (.simple (.output expression))
  | reject : basicKind text context scan = .reject → BasicPayload text context scan .reject
  | assignment {expression} : basicKind text context scan = .assignment →
      TargetReading text (parserState context scan) (assignmentTarget text context scan) false →
      ExpressionAt text context.names (assignmentStart text context scan).position expression
        (expressionAt text (assignmentStart text context scan).position context.names) →
      BasicPayload text context scan (.simple (.assign ⟨(assignmentTarget text context scan).target, expression⟩))

structure BasicAt (text : Source) (context : ParseContext) (scan : BodyScan)
    (item : SourceStatement) (result : BodyScan) : Prop where
  positive : result.position ≠ 0
  equation : basicBody text context scan = result
  payload : BasicPayload text context scan item

theorem basic_after_raw {text context scan}
    (accepted : (basicBody text context scan).position ≠ 0) :
    basicBody text context scan = bodyToken text (basicRaw text context scan) (.symbol ";") := by
  unfold basicBody at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i nonzero
    rw [ite_eq_right nonzero]
    dsimp only at accepted ⊢
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i advanced
      exact ite_eq_right advanced

theorem basic_raw_positive {text context scan}
    (accepted : (basicBody text context scan).position ≠ 0) :
    (basicRaw text context scan).position ≠ 0 := by
  rw [basic_after_raw accepted] at accepted
  exact fixedAfter_nonzero accepted

theorem basic_sound {text context scan}
    (accepted : (basicBody text context scan).position ≠ 0) :
    ∃ item, BasicAt text context scan item (basicBody text context scan) := by
  have raw := basic_raw_positive accepted
  cases kind : basicKind text context scan with
  | null => exact ⟨_, ⟨accepted, rfl, .null kind⟩⟩
  | reject => exact ⟨_, ⟨accepted, rfl, .reject kind⟩⟩
  | output =>
      simp only [basicRaw, kind] at raw
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        have positive : (expressionAt text (outputStart text context scan).position context.names).after ≠ 0 :=
          fun zero => good (Or.inl zero)
        obtain ⟨expression, parsed⟩ := expressionAt_sound text context.names _ positive
        exact ⟨_, ⟨accepted, rfl, .output kind parsed⟩⟩
  | assignment =>
      simp only [basicRaw, kind] at raw
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        have positive : (expressionAt text (assignmentStart text context scan).position context.names).after ≠ 0 :=
          fun zero => good (Or.inl zero)
        have startPositive := Compose.Expressions.model_expression_input_nonzero text _ context.names positive
        have targetPositive : (assignmentTarget text context scan).position ≠ 0 := fixedAfter_nonzero startPositive
        obtain ⟨expression, parsed⟩ := expressionAt_sound text context.names _ positive
        exact ⟨_, ⟨accepted, rfl, .assignment kind (target_reading text _ false targetPositive) parsed⟩⟩

private theorem true_of_not_neg {b : Bool} (h : ¬(!b) = true) : b = true := by
  cases b <;> simp_all

theorem basic_meaning {text context scan item result}
    (normal : NamesNormal context.names) (parsed : BasicAt text context scan item result) :
    item.WellFormed context.hasArguments context.names.shape ∧
      item.lower.check context.names.shape scan.facts = some result.facts := by
  have success : (basicBody text context scan).position ≠ 0 := parsed.equation ▸ parsed.positive
  have raw := basic_raw_positive success
  have resultEq := (basic_after_raw success).symm.trans parsed.equation
  cases parsed.payload with
  | null kind =>
      simp only [basicRaw, kind] at resultEq
      simp only [SourceStatement.WellFormed, SimpleWellFormed]
      refine ⟨trivial, ?_⟩
      simp only [SourceStatement.lower, Statement.check, checkSimple, ↓reduceIte]
      have factsEq := congrArg (fun value : BodyScan => some value.facts) resultEq
      simpa only [bodyToken_facts] using factsEq
  | reject kind =>
      have arguments : context.hasArguments = true := by
        unfold basicKind at kind
        split at kind <;> try contradiction
        split at kind <;> try contradiction
        split at kind
        · rename_i h
          simp only [Bool.and_eq_true] at h
          exact h.1
        · contradiction
      simp only [SourceStatement.WellFormed]
      refine ⟨arguments, ?_⟩
      simp only [basicRaw, kind] at resultEq
      simp only [SourceStatement.lower, Statement.check]
      have factsEq := congrArg BodyScan.facts resultEq
      simpa only [bodyToken_facts, bodyTokens_facts] using congrArg some factsEq
  | output kind expression =>
      have ready := expression_reading_ready normal expression
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        have fits : fitsSummary scan.facts (summaryOf (expressionAt text (outputStart text context scan).position context.names)) = true := by
          apply true_of_not_neg
          simpa only [bodyTokens_facts] using (show ¬(!fitsSummary (outputStart text context scan).facts
              (summaryOf (expressionAt text (outputStart text context scan).position context.names))) = true from
            fun bad => good (Or.inr (Or.inr bad)))
        have valid : scan.facts.invalidReachable = false := by
          cases h : scan.facts.invalidReachable with
          | false => rfl
          | true => exact False.elim (good (Or.inr (Or.inl (by simpa only [bodyTokens_facts] using h))))
        simp only [SourceStatement.WellFormed, SimpleWellFormed]
        refine ⟨ready.1, ?_⟩
        have factsEq : scan.facts = result.facts := by
          simpa only [bodyToken_facts, bodyTokens_facts] using congrArg BodyScan.facts resultEq
        rw [← factsEq]
        simp only [SourceStatement.lower, Statement.check, checkSimple, ready.2, fits, valid,
          Bool.not_false, Bool.true_and, ↓reduceIte]
  | assignment kind target expression =>
      have ready := expression_reading_ready normal expression
      obtain ⟨name, info, _, found, _, mutable, _⟩ := target
      change context.names.get (assignmentTarget text context scan).target = some info at found
      have targetShape : context.names.shape (assignmentTarget text context scan).target = some ⟨info.bound, true⟩ := by
        simp only [BindingEnvironment.shape] at found ⊢
        simp only [found, Option.map_some, BindingInfo.cell, mutable]
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        have fits : fitsSummary scan.facts (summaryOf (expressionAt text (assignmentStart text context scan).position context.names)) = true := by
          apply true_of_not_neg
          exact fun bad => good (Or.inr (Or.inr (Or.inl bad)))
        have equal : equalSummary scan.facts
            (summaryOf (expressionAt text (assignmentStart text context scan).position context.names)) info.bound.summary = true := by
          apply true_of_not_neg
          intro bad
          apply good
          right; right; right
          change (!equalSummary scan.facts (summaryOf (expressionAt text (assignmentStart text context scan).position context.names))
            ((context.names.get (assignmentTarget text context scan).target).getD {}).bound.summary) = true
          simpa only [found, Option.getD_some] using bad
        simp only [SourceStatement.WellFormed, SimpleWellFormed]
        refine ⟨⟨ready.1, info.bound, targetShape⟩, ?_⟩
        have factsEq : scan.facts = result.facts := by
          simpa only [bodyToken_facts] using congrArg BodyScan.facts resultEq
        rw [← factsEq]
        simp only [SourceStatement.lower, Statement.check, checkSimple, checkAssignment,
          targetShape, ready.2, fits, equal, Bool.true_and, ↓reduceIte]

theorem basic_unique {text context scan left right first second}
    (a : BasicAt text context scan left first) (b : BasicAt text context scan right second) :
    left = right ∧ first = second := by
  refine ⟨?_, a.equation.symm.trans b.equation⟩
  cases a.payload with
  | null kind =>
      cases b.payload <;> simp_all
  | reject kind =>
      cases b.payload <;> simp_all
  | output kind reading =>
      cases b.payload with
      | null other | reject other | assignment other => simp_all
      | output _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique reading other
          rfl
  | assignment kind target reading =>
      cases b.payload with
      | null other | reject other | output other => simp_all
      | assignment _ _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique reading other
          rfl

end Silver.Predicate
