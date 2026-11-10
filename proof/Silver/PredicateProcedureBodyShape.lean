module

public import Silver.PredicateBodyReadings
public import Silver.PredicateFunctionCallMeaning
public import Silver.ScalarProcedureDefinition

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
open Compose Bindings PathFacts

theorem procedureActual_source_scalar {text context position facts parameter actual after}
    (closed : ClosedFunctionContext context)
    (parsed : ProcedureActualAt text context position facts parameter actual after) :
    ScalarProcedures.scalarActual actual = true := by
  cases parsed with
  | input _ reading => exact actual_source_scalar closed reading
  | target => rfl

theorem procedureActuals_source_scalar {text context facts procedures position first last actuals after}
    (closed : ClosedFunctionContext context)
    (parsed : ProcedureActualsAt text context facts procedures position first last actuals after) :
    actuals.all ScalarProcedures.scalarActual = true := by
  induction parsed with
  | last reading _ =>
      simpa only [List.all_cons, List.all_nil, Bool.and_true] using procedureActual_source_scalar closed reading
  | next _ reading _ _ ih => exact Bool.and_eq_true_iff.mpr ⟨procedureActual_source_scalar closed reading, ih⟩

private theorem closed_basicKinds {text context scan} (closed : ClosedFunctionContext context) :
    basicKind text context scan = .null ∨ basicKind text context scan = .scalarAssignment ∨
      basicKind text context scan = .booleanAssignment ∨ basicKind text context scan = .assignment := by
  unfold basicKind
  simp only [closed.pure, closed.noArguments, Bool.not_true, Bool.false_and,
    Bool.false_eq_true, ↓reduceIte]
  repeat' split <;> simp_all

theorem basic_source_procedureScalar {text context scan item result}
    (closed : ClosedFunctionContext context)
    (parsed : BasicStepAt text context scan item result catalog procedures) :
    ScalarProcedures.scalarStatement item.lower = true := by
  cases parsed.payload with
  | procedure _ reading =>
      simpa only [SourceStatement.lower, ScalarProcedures.scalarStatement] using
        procedureActuals_source_scalar closed reading.updates.actuals
  | primitive ordinary payload =>
      have basic := parsed.primitive ordinary
      have kinds := closed_basicKinds (text := text) (scan := scan) closed
      cases payload with
      | null => simp only [SourceStatement.lower, ScalarProcedures.scalarStatement]
      | output kind | put kind | reject kind | arrayAssignment kind | booleanArrayAssignment kind =>
          rcases kinds with allowed | allowed | allowed | allowed <;> simp_all
      | scalarCallAssignment _ reading | booleanCallAssignment _ reading =>
          simpa only [SourceStatement.lower, ScalarProcedures.scalarStatement] using
            actuals_source_scalar closed reading.call.actuals
      | scalarAssignment _ _ reading =>
          rw [closed.noArrays] at reading
          simpa only [SourceStatement.lower, ScalarProcedures.scalarStatement] using
            scalarExpression_source_scalar reading
      | booleanAssignment _ _ reading =>
          simpa only [SourceStatement.lower, ScalarProcedures.scalarStatement] using
            condition_source_scalar closed reading
      | assignment kind _ =>
          have raw := basic_raw_positive (catalog := catalog) (basic.equation ▸ basic.positive)
          simp [basicRaw, kind, procedureCalleeAt_empty, closed.pure, invalidBody] at raw

private theorem closed_loopInner {context : ParseContext}
    (closed : ClosedFunctionContext context) (header : LoopHeader) :
    ClosedFunctionContext (loopInner context header) :=
  ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩

mutual
  theorem statement_source_procedureScalar {text context scan item result}
      (closed : ClosedFunctionContext context)
      (parsed : StatementAt (catalog := catalog) (procedures := procedures) text context scan item result) :
      ScalarProcedures.scalarStatement item.lower = true := by
    cases parsed with
    | basic _ _ _ reading _ => exact basic_source_procedureScalar closed reading
    | choice _ _ reading _ => exact choice_source_procedureScalar closed reading
    | loop _ _ _ reading _ => exact loop_source_procedureScalar closed reading
    | arrayLoop _ _ _ reading _ =>
        cases reading with
        | loop _ _ allowed _ _ _ _ _ =>
            have emptyTarget : loopArrayTarget text context scan = 0 := by
              simp only [loopArrayTarget, arrayTarget, closed.noArrays, ArrayBindings.lookup,
                List.length_nil, ArrayBindings.lookupFrom]
              split <;> rfl
            simp [loopArrayAllowed, emptyTarget] at allowed
  termination_by (bodyRemaining text scan, 2)

  theorem loop_source_procedureScalar {text context scan lower upper body result}
      (closed : ClosedFunctionContext context)
      (parsed : LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result) :
      ScalarProcedures.scalarStatement (SourceStatement.forLoop (context.scalarNames.length + 1)
        (loopHeader text context scan).reverse lower upper body).lower = true := by
    cases parsed with
    | loop _ _ lowerRead upperRead _ bodyRead _ _ _ =>
        have good := body_source_procedureScalar (closed_loopInner closed _) bodyRead
        rw [closed.noArrays] at lowerRead upperRead
        simp only [SourceStatement.lower, ScalarProcedures.scalarStatement,
          scalarExpression_source_scalar lowerRead, scalarExpression_source_scalar upperRead,
          good, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem choice_source_procedureScalar {text context scan condition yes tail result}
      (closed : ClosedFunctionContext context)
      (parsed : ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result) :
      ScalarProcedures.scalarStatement (SourceStatement.choice condition yes tail).lower = true := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_procedureScalar closed yesRead
        have noGood := alternative_source_procedureScalar closed noRead
        simp only [SourceStatement.lower, ScalarProcedures.scalarStatement,
          condition_source_scalar closed conditionRead, yesGood, noGood, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_source_procedureScalar {text context scan tail result}
      (closed : ClosedFunctionContext context)
      (parsed : AlternativeAt (catalog := catalog) (procedures := procedures) text context scan tail result) :
      ScalarProcedures.scalarStatements tail.lower = true := by
    cases parsed with
    | absent => simp only [SourceAlternative.lower, ScalarProcedures.scalarStatements]
    | otherwise _ _ _ _ bodyRead _ =>
        simpa only [SourceAlternative.lower] using body_source_procedureScalar closed bodyRead
    | elsif _ _ conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_procedureScalar closed yesRead
        have noGood := alternative_source_procedureScalar closed noRead
        simp only [SourceAlternative.lower, ScalarProcedures.scalarStatements,
          ScalarProcedures.scalarStatement, condition_source_scalar closed conditionRead,
          yesGood, noGood, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_source_procedureScalar {text context stop scan items result}
      (closed : ClosedFunctionContext context)
      (parsed : BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan items result) :
      ScalarProcedures.scalarStatements (lowerStatements items) = true := by
    cases parsed with
    | done => simp only [lowerStatements, ScalarProcedures.scalarStatements]
    | next _ _ itemRead _ restRead _ =>
        have first := statement_source_procedureScalar closed itemRead
        have rest := bodyTail_source_procedureScalar closed restRead
        simp only [lowerStatements, ScalarProcedures.scalarStatements, first, rest, Bool.and_self]
  termination_by (bodyRemaining text scan, 3)

  theorem body_source_procedureScalar {text context scan stop items result}
      (closed : ClosedFunctionContext context)
      (parsed : BodyAt (catalog := catalog) (procedures := procedures) text context scan stop items result) :
      ScalarProcedures.scalarStatements (lowerStatements items) = true := by
    cases parsed with
    | cons itemRead _ restRead _ =>
        have first := statement_source_procedureScalar closed itemRead
        have rest := bodyTail_source_procedureScalar closed restRead
        simp only [lowerStatements, ScalarProcedures.scalarStatements, first, rest, Bool.and_self]
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
