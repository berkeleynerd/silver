module

public import Silver.PredicateBodyProperties
public import Silver.PredicateConditionUnique

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

abbrev outputStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  {scan with
    position := Names.associationAfter text
      (fixedAfter text (callAfter text context.names scan.position .output context.scalarNames) "(" false) false}
abbrev putStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  {scan with
    position := Names.associationAfter text
      (fixedAfter text (callAfter text context.names scan.position .partialOutput context.scalarNames) "(" false) false}
abbrev assignmentTarget (text : Source) (context : ParseContext) (scan : BodyScan) : ParserState :=
  targetAt text (parserState context scan) false
abbrev assignmentStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  bodyToken text {scan with position := (assignmentTarget text context scan).position, target := (assignmentTarget text context scan).target} (.symbol ":=")

/-- Source operands and mutable target names are retained independently of the
cursor scanner. The successful trace supplies only concrete admission guards. -/
inductive BasicPayload (text : Source) (context : ParseContext) (scan : BodyScan) : SourceStatement → Prop
  | null : basicKind text context scan = .null → BasicPayload text context scan (.simple .null)
  | output {expression} : basicKind text context scan = .output →
      ExpressionAt (scalarNames := context.readingNames scan.facts) text context.names (outputStart text context scan).position expression
        (expressionAt text (outputStart text context scan).position context.names (context.readingNames scan.facts)) →
      BasicPayload text context scan (.simple (.output expression))
  | put {expression} : basicKind text context scan = .put →
      ExpressionAt (scalarNames := context.readingNames scan.facts) text context.names (putStart text context scan).position expression
        (expressionAt text (putStart text context scan).position context.names (context.readingNames scan.facts)) →
      BasicPayload text context scan (.simple (.put expression))
  | reject : basicKind text context scan = .reject → BasicPayload text context scan .reject
  | scalarAssignment {expression} : basicKind text context scan = .scalarAssignment →
      ScalarExpression.At text (context.readingNames scan.facts) (scalarAssignmentStart text scan) expression
        (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)) →
      BasicPayload text context scan (.scalarAssign
        ⟨scalarTarget text context scan.position, expression,
          (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds⟩)
  | assignment {expression} : basicKind text context scan = .assignment →
      TargetReading text (parserState context scan) (assignmentTarget text context scan) false →
      ExpressionAt (scalarNames := context.readingNames scan.facts) text context.names (assignmentStart text context scan).position expression
        (expressionAt text (assignmentStart text context scan).position context.names (context.readingNames scan.facts)) →
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
        have positive : (expressionAt text (outputStart text context scan).position context.names (context.readingNames scan.facts)).after ≠ 0 :=
          fun zero => good (Or.inl zero)
        obtain ⟨expression, parsed⟩ := expressionAt_sound (scalarNames := context.readingNames scan.facts) text context.names _ positive
        exact ⟨_, ⟨accepted, rfl, .output kind parsed⟩⟩
  | put =>
      simp only [basicRaw, kind] at raw
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        have positive : (expressionAt text (putStart text context scan).position context.names (context.readingNames scan.facts)).after ≠ 0 :=
          fun zero => good (Or.inl zero)
        obtain ⟨expression, parsed⟩ := expressionAt_sound (scalarNames := context.readingNames scan.facts) text context.names _ positive
        exact ⟨_, ⟨accepted, rfl, .put kind parsed⟩⟩
  | scalarAssignment =>
      simp only [basicRaw, kind, scalarAssignmentBody] at raw
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        have positive : (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).after ≠ 0 := by
          intro zero
          exact good (Or.inr (Or.inr (Or.inl (by omega))))
        obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound
          (Compose.Expressions.model_fixed_valid text _ ":=" false (Compose.Expressions.model_name_valid text _)) positive
        exact ⟨_, ⟨accepted, rfl, .scalarAssignment kind parsed⟩⟩
  | assignment =>
      simp only [basicRaw, kind] at raw
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        have positive : (expressionAt text (assignmentStart text context scan).position context.names (context.readingNames scan.facts)).after ≠ 0 :=
          fun zero => good (Or.inl zero)
        have startPositive := Compose.Expressions.model_expression_input_nonzero (scalarNames := context.readingNames scan.facts) text _ context.names positive
        have targetPositive : (assignmentTarget text context scan).position ≠ 0 := fixedAfter_nonzero startPositive
        obtain ⟨expression, parsed⟩ := expressionAt_sound (scalarNames := context.readingNames scan.facts) text context.names _ positive
        exact ⟨_, ⟨accepted, rfl, .assignment kind (target_reading text _ false targetPositive) parsed⟩⟩

private theorem true_of_not_neg {b : Bool} (h : ¬(!b) = true) : b = true := by
  cases b <;> simp_all

theorem basic_meaning {text context scan item result}
    (normal : NamesNormal context.names) (bodyReady : ScalarExpression.BodyReady context.scalarNames)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (parsed : BasicAt text context scan item result) :
    item.WellFormed context.hasArguments context.names.shape ∧
      item.lower.check context.names.shape context.analysis scan.facts.model = some result.facts.model := by
  have rangesEq : ScalarExpression.ranges (context.readingNames scan.facts) = scan.facts.model.scalars :=
    ScalarMetadata.readingNames_ranges compatible
  have success : (basicBody text context scan).position ≠ 0 := parsed.equation ▸ parsed.positive
  have raw := basic_raw_positive success
  have resultEq := (basic_after_raw success).symm.trans parsed.equation
  cases parsed.payload with
  | null kind =>
      simp only [basicRaw, kind] at resultEq
      simp only [SourceStatement.WellFormed, SimpleWellFormed]
      refine ⟨trivial, ?_⟩
      simp only [SourceStatement.lower, Statement.check, checkSimple, ↓reduceIte]
      have factsEq := congrArg (fun value : BodyScan => some value.facts.model) resultEq
      simpa only [bodyToken_facts] using factsEq
  | reject kind =>
      have arguments : context.hasArguments = true := by
        unfold basicKind at kind
        split at kind <;> try contradiction
        split at kind <;> try contradiction
        split at kind <;> try contradiction
        split at kind
        · rename_i h
          simp only [Bool.and_eq_true] at h
          exact h.1
        · split at kind <;> contradiction
      simp only [SourceStatement.WellFormed]
      refine ⟨arguments, ?_⟩
      simp only [basicRaw, kind] at resultEq
      simp only [SourceStatement.lower, Statement.check]
      have factsEq := congrArg BodyScan.facts resultEq
      simpa only [bodyToken_facts, bodyTokens_facts, ActiveFlow.model] using
        congrArg (fun facts : ActiveFlow => some facts.model) factsEq
  | output kind expression =>
      have ready := expression_reading_ready normal expression
      rw [rangesEq] at ready
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        have fits : fitsLengthSummary scan.facts.path (summaryOf (expressionAt text (outputStart text context scan).position context.names (context.readingNames scan.facts))) = true := by
          apply true_of_not_neg
          simpa only [bodyTokens_facts] using (show ¬(!fitsLengthSummary (outputStart text context scan).facts.path
              (summaryOf (expressionAt text (outputStart text context scan).position context.names (context.readingNames scan.facts)))) = true from
            fun bad => good (Or.inr (Or.inr bad)))
        simp only [summaryOf] at fits
        have valid : scan.facts.path.invalidReachable = false := by
          cases h : scan.facts.path.invalidReachable with
          | false => rfl
          | true => exact False.elim (good (Or.inr (Or.inl (by simpa only [bodyTokens_facts] using h))))
        simp only [SourceStatement.WellFormed, SimpleWellFormed]
        refine ⟨ready.1, ?_⟩
        have factsEq : scan.facts = result.facts := by
          simpa only [bodyToken_facts, bodyTokens_facts] using congrArg BodyScan.facts resultEq
        rw [← factsEq]
        simp only [SourceStatement.lower, Statement.check, checkSimple, ready.2, ActiveFlow.model_path, fits, valid,
          Bool.not_false, Bool.true_and, ↓reduceIte]
  | put kind expression =>
      have ready := expression_reading_ready normal expression
      rw [rangesEq] at ready
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        have fits : fitsLengthSummary scan.facts.path (summaryOf (expressionAt text (putStart text context scan).position context.names (context.readingNames scan.facts))) = true := by
          apply true_of_not_neg
          simpa only [bodyTokens_facts] using (show ¬(!fitsLengthSummary (putStart text context scan).facts.path
              (summaryOf (expressionAt text (putStart text context scan).position context.names (context.readingNames scan.facts)))) = true from
            fun bad => good (Or.inr (Or.inr bad)))
        simp only [summaryOf] at fits
        have valid : scan.facts.path.invalidReachable = false := by
          cases h : scan.facts.path.invalidReachable with
          | false => rfl
          | true => exact False.elim (good (Or.inr (Or.inl (by simpa only [bodyTokens_facts] using h))))
        simp only [SourceStatement.WellFormed, SimpleWellFormed]
        refine ⟨ready.1, ?_⟩
        have factsEq : scan.facts = result.facts := by
          simpa only [bodyToken_facts, bodyTokens_facts] using congrArg BodyScan.facts resultEq
        rw [← factsEq]
        simp only [SourceStatement.lower, Statement.check, checkSimple, ready.2, ActiveFlow.model_path, fits, valid,
          Bool.not_false, Bool.true_and, ↓reduceIte]
  | scalarAssignment kind expression =>
      simp only [basicRaw, kind, scalarAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        have nonzero : scalarTarget text context scan.position ≠ 0 := fun bad => good (Or.inl bad)
        have targetBound : scalarTarget text context scan.position ≤ context.scalarNames.length :=
          ScalarExpression.lookup_bound ..
        have mutable : (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).mutable = true :=
          true_of_not_neg (fun bad => good (Or.inr (Or.inl bad)))
        have same := ScalarExpression.bodyReady_binding bodyReady (Nat.pos_of_ne_zero nonzero) targetBound mutable
        have notEmpty : (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.isEmpty = false :=
          Bool.eq_false_iff.mpr (fun bad => good (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
        have included : (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.included
            (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds = true := by
          have low : ¬ (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.lower <
              (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.lower :=
            fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
          have high : ¬ (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.upper >
              (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.upper :=
            fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr bad)))))
          simp only [Integer.Interval.included, notEmpty, Bool.false_or, decide_eq_true_eq]
          constructor <;> omega
        have factsEq : scan.facts.replace (scalarTarget text context scan.position)
            (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds = result.facts := by
          simpa only [bodyToken_facts] using congrArg BodyScan.facts resultEq
        have inferred := expression.inferred
        rw [rangesEq] at inferred
        refine ⟨by simpa only [SourceStatement.WellFormed] using nonzero, ?_⟩
        rw [← factsEq, ActiveFlow.replace_model _ _ _ (Nat.pos_of_ne_zero nonzero)
          (by rw [compatible.count]; exact targetBound)]
        simp only [SourceStatement.lower, Statement.check, Integer.Assignment.check,
          Integer.Assignment.after, ParseContext.analysis, ScalarMetadata.analysis,
          ScalarExpression.mutability, ScalarExpression.ranges,
          Nat.pos_of_ne_zero nonzero, targetBound, and_self, decide_true,
          Bool.true_and, mutable, ↓reduceIte, inferred, same,
          included, notEmpty, Bool.not_false, ActiveFlow.model_path]
  | assignment kind target expression =>
      have ready := expression_reading_ready normal expression
      rw [rangesEq] at ready
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
        have fits : fitsLengthSummary scan.facts.path (summaryOf (expressionAt text (assignmentStart text context scan).position context.names (context.readingNames scan.facts))) = true := by
          apply true_of_not_neg
          exact fun bad => good (Or.inr (Or.inr (Or.inl bad)))
        have equal : equalLengthSummary scan.facts.path
            (summaryOf (expressionAt text (assignmentStart text context scan).position context.names (context.readingNames scan.facts))) info.bound.summary = true := by
          apply true_of_not_neg
          intro bad
          apply good
          right; right; right
          change (!equalLengthSummary scan.facts.path (summaryOf (expressionAt text (assignmentStart text context scan).position context.names (context.readingNames scan.facts)))
            ((context.names.get (assignmentTarget text context scan).target).getD {}).bound.summary) = true
          simpa only [found, Option.getD_some] using bad
        simp only [SourceStatement.WellFormed, SimpleWellFormed]
        refine ⟨⟨ready.1, info.bound, targetShape⟩, ?_⟩
        simp only [summaryOf] at fits equal
        have factsEq : scan.facts = result.facts := by
          simpa only [bodyToken_facts] using congrArg BodyScan.facts resultEq
        rw [← factsEq]
        simp only [SourceStatement.lower, Statement.check, checkSimple, checkAssignment,
          targetShape, ready.2, ActiveFlow.model_path, fits, equal, Bool.true_and, ↓reduceIte]

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
      | null other | reject other | assignment other | scalarAssignment other | put other => simp_all
      | output _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique reading other
          rfl
  | put kind reading =>
      cases b.payload with
      | null other | reject other | assignment other | scalarAssignment other | output other => simp_all
      | put _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique reading other
          rfl
  | scalarAssignment kind reading =>
      cases b.payload with
      | null other | reject other | output other | put other | assignment other => simp_all
      | scalarAssignment _ other =>
          obtain ⟨rfl, _⟩ := ScalarExpression.at_unique reading other
          rfl
  | assignment kind target reading =>
      cases b.payload with
      | null other | reject other | output other | scalarAssignment other | put other => simp_all
      | assignment _ _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique reading other
          rfl

end Silver.Predicate
