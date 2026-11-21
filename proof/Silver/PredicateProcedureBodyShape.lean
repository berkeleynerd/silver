module

public import Silver.PredicateBodyReadings
public import Silver.PredicateFunctionCallMeaning
public import Silver.ScalarProcedureDefinition

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
open Compose Bindings PathFacts

theorem procedureActual_source_scalar {text context position facts parameter actual after}
    (closed : ClosedFunctionContext context frame)
    (parsed : ProcedureActualAt text context position facts parameter actual after) :
    ScalarProcedures.frameActual frame actual = true := by
  cases parsed with
  | input _ reading => exact actual_source_scalar closed reading
  | target => rfl

theorem procedureActuals_source_scalar {text context facts procedures position first last actuals after}
    (closed : ClosedFunctionContext context frame)
    (parsed : ProcedureActualsAt text context facts procedures position first last actuals after) :
    actuals.all (ScalarProcedures.frameActual frame) = true := by
  apply List.all_eq_true.mpr
  exact parsed.forall_payloads (fun _ _ _ _ payload => procedureActual_source_scalar closed payload)

private theorem closed_basicKinds {text context scan} (closed : ClosedFunctionContext context frame) :
    basicKind text context scan = .null ∨ basicKind text context scan = .scalarAssignment ∨
      basicKind text context scan = .booleanAssignment ∨ basicKind text context scan = .assignment := by
  unfold basicKind
  simp only [closed.pure, closed.noArguments, Bool.not_true, Bool.false_and,
    Bool.false_eq_true, ↓reduceIte]
  repeat' split <;> simp_all

theorem basic_source_procedureScalar {text context scan item result}
    (closed : ClosedFunctionContext context frame)
    (parsed : BasicStepAt text context scan item result catalog procedures) :
    ScalarProcedures.frameStatement frame item.lower = true := by
  cases parsed.payload with
  | procedure _ reading =>
      simpa only [SourceStatement.lower, ScalarProcedures.frameStatement] using
        procedureActuals_source_scalar closed reading.updates.actuals
  | primitive ordinary payload =>
      have basic := parsed.primitive ordinary
      have kinds := closed_basicKinds (text := text) (scan := scan) closed
      cases payload with
      | null => simp only [SourceStatement.lower, ScalarProcedures.frameStatement]
      | output kind | put kind | reject kind | arrayAssignment kind | booleanArrayAssignment kind =>
          rcases kinds with allowed | allowed | allowed | allowed <;> simp_all
      | scalarCallAssignment _ reading | booleanCallAssignment _ reading =>
          simpa only [SourceStatement.lower, ScalarProcedures.frameStatement] using
            actuals_source_scalar closed reading.call.actuals
      | scalarAssignment _ _ reading =>
          simpa only [SourceStatement.lower, ScalarProcedures.frameStatement] using
            closed.scalarExpression reading
      | booleanAssignment _ _ reading =>
          simpa only [SourceStatement.lower, ScalarProcedures.frameStatement] using
            condition_source_scalar closed reading
      | assignment kind _ =>
          have raw := basic_raw_positive (catalog := catalog) (basic.equation ▸ basic.positive)
          simp [basicRaw, kind, procedureCalleeAt_empty, closed.pure, invalidBody] at raw

private theorem closed_loopInner {context : ParseContext}
    (closed : ClosedFunctionContext context frame) (header : LoopHeader) :
    ClosedFunctionContext (loopInner context header) frame :=
  ⟨closed.pure, closed.noArguments, closed.noNames, closed.arrayViews⟩

mutual
  theorem statement_source_procedureScalar {text context scan item result}
      (closed : ClosedFunctionContext context frame)
      (parsed : StatementAt (catalog := catalog) (procedures := procedures) text context scan item result) :
      ScalarProcedures.frameStatement frame item.lower = true := by
    cases parsed with
    | basic _ _ _ reading _ => exact basic_source_procedureScalar closed reading
    | choice _ _ reading _ => exact choice_source_procedureScalar closed reading
    | loop _ _ _ reading _ => exact loop_source_procedureScalar closed reading
    | arrayLoop _ _ _ reading _ =>
        cases reading with
        | loop _ _ allowed _ _ _ _ _ =>
            simp [loopArrayAllowed, closed.pure] at allowed
  termination_by (bodyRemaining text scan, 2)

  theorem loop_source_procedureScalar {text context scan lower upper body result}
      (closed : ClosedFunctionContext context frame)
      (parsed : LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result) :
      ScalarProcedures.frameStatement frame (SourceStatement.forLoop (context.scalarNames.length + 1)
        (loopHeader text context scan).reverse lower upper body).lower = true := by
    cases parsed with
    | loop _ _ boundsRead _ bodyRead _ _ _ =>
        have good := body_source_procedureScalar (closed_loopInner closed _) bodyRead
        have boundsGood : ScalarFunctions.frameExpression frame lower = true ∧
            ScalarFunctions.frameExpression frame upper = true := by
          cases boundsRead with
          | counted _ low high => exact ⟨closed.scalarExpression low, closed.scalarExpression high⟩
          | range => exact ⟨rfl, rfl⟩
        simp only [SourceStatement.lower, ScalarProcedures.frameStatement,
          boundsGood.1, boundsGood.2,
          good, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem choice_source_procedureScalar {text context scan condition yes tail result}
      (closed : ClosedFunctionContext context frame)
      (parsed : ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result) :
      ScalarProcedures.frameStatement frame (SourceStatement.choice condition yes tail).lower = true := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_procedureScalar closed yesRead
        have noGood := alternative_source_procedureScalar closed noRead
        simp only [SourceStatement.lower, ScalarProcedures.frameStatement,
          condition_source_scalar closed conditionRead, yesGood, noGood, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_source_procedureScalar {text context scan tail result}
      (closed : ClosedFunctionContext context frame)
      (parsed : AlternativeAt (catalog := catalog) (procedures := procedures) text context scan tail result) :
      ScalarProcedures.frameStatements frame tail.lower = true := by
    cases parsed with
    | absent => simp only [SourceAlternative.lower, ScalarProcedures.frameStatements]
    | otherwise _ _ _ _ bodyRead _ =>
        simpa only [SourceAlternative.lower] using body_source_procedureScalar closed bodyRead
    | elsif _ _ conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_procedureScalar closed yesRead
        have noGood := alternative_source_procedureScalar closed noRead
        simp only [SourceAlternative.lower, ScalarProcedures.frameStatements,
          ScalarProcedures.frameStatement, condition_source_scalar closed conditionRead,
          yesGood, noGood, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_source_procedureScalar {text context stop scan items result}
      (closed : ClosedFunctionContext context frame)
      (parsed : BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan items result) :
      ScalarProcedures.frameStatements frame (lowerStatements items) = true := by
    cases parsed with
    | done => simp only [lowerStatements, ScalarProcedures.frameStatements]
    | next _ _ itemRead _ restRead _ =>
        have first := statement_source_procedureScalar closed itemRead
        have rest := bodyTail_source_procedureScalar closed restRead
        simp only [lowerStatements, ScalarProcedures.frameStatements, first, rest, Bool.and_self]
  termination_by (bodyRemaining text scan, 3)

  theorem body_source_procedureScalar {text context scan stop items result}
      (closed : ClosedFunctionContext context frame)
      (parsed : BodyAt (catalog := catalog) (procedures := procedures) text context scan stop items result) :
      ScalarProcedures.frameStatements frame (lowerStatements items) = true := by
    cases parsed with
    | cons itemRead _ restRead _ =>
        have first := statement_source_procedureScalar closed itemRead
        have rest := bodyTail_source_procedureScalar closed restRead
        simp only [lowerStatements, ScalarProcedures.frameStatements, first, rest, Bool.and_self]
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
