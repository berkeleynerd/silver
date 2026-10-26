module

public import Silver.PredicateBodyEquations
public import Silver.PredicateBodyBounds
public import Silver.PredicateBodyFlowPreservation

@[expose] public section
namespace Silver.Predicate.BodyNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

attribute [local irreducible] ScalarExpression.read

abbrev ValidText := Compose.Expressions.ValidText

def ValidScan (text : Source) (context : Native.Context) (scan : BodyScan) : Prop :=
  scan.position ≤ text.length + 1 ∧ Controls context.model scan ∧ Native.ValidFlow context scan.facts

theorem model_statement_valid (text : Source) (tv : ValidText text) (context : Native.Context)
    (cv : Native.ValidContext text context) (scan : BodyScan) (sv : ValidScan text context scan) :
    ValidScan text context (statementBody text context.model scan) :=
  ⟨statementBody_bound text context.model scan tv cv.1 sv.1, statementBody_controls text context.model scan sv.2.1, ⟨statementBody_factsBounded text context.model scan sv.2.2.1,
    statementBody_flowReady text context.model scan cv.2.2.2 sv.2.2.2 cv.2.2.1⟩⟩

theorem model_read_valid (text : Source) (tv : ValidText text) (context : Native.Context)
    (cv : Native.ValidContext text context) (scan : BodyScan) (stop : BodyStop) (sv : ValidScan text context scan) :
    ValidScan text context (readBody text context.model scan stop) :=
  ⟨readBody_bound text context.model scan stop tv cv.1 sv.1, readBody_controls text context.model scan stop sv.2.1, ⟨readBody_factsBounded text context.model scan stop sv.2.2.1,
    readBody_flowReady text context.model scan stop cv.2.2.2 sv.2.2.2 cv.2.2.1⟩⟩

theorem start_valid (text : Source) (tv : ValidText text) (context : Native.Context)
    (cv : Native.ValidContext text context) (scan : BodyScan) (keyword : String) (sv : ValidScan text context scan) :
    ValidScan text context (branchStart text context.model scan keyword).1 :=
  ⟨branchStart_bound text context.model scan keyword tv cv.1 sv.1, branchStart_controls text context.model scan keyword sv.2.1,
    ⟨(branchStart_factsBounded text context.model scan keyword sv.2.2.1).1,
      (branchStart_flowReady text context.model scan keyword cv.2.2.2 sv.2.2.2).1⟩⟩

/-- Helper callees have their separately established source meanings. These are
only the remaining recursive body equations; none assumes admission or recursive
scanner equivalence. Native range types and preconditions select the domain. -/
structure Equations (calls : Calls) : Prop where
  statement : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.statement text context scan = statementEval modelPrimitives calls {text,context,scan}
  loop : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.loop text context scan = LoopNative.eval calls.read text context scan
  conditional : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.conditional text context scan = conditionalFunction.eval modelPrimitives calls {text,context,scan}
  alternative : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.alternative text context scan = alternativeFunction.eval modelPrimitives calls {text,context,scan}
  tailModel : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → calls.tailModel text context scan stop = tailModelBody.eval modelPrimitives calls {text,context,scan,stop}
  tail : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → calls.tail text context scan stop = calls.tailModel text context scan stop
  read : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → calls.read text context scan stop = readContractBody.eval modelPrimitives calls {text,context,scan,stop}

theorem model_equations : Equations modelCalls where
  statement text _ context _ scan _ := by
    by_cases zero : scan.position = 0
    all_goals by_cases found : fixedAfter text scan.position "if" true ≠ 0
    all_goals by_cases loopFound : fixedAfter text scan.position "for" true ≠ 0
    all_goals simp +instances [modelCalls, statementBody, statementEval, Test.eval, ScanExpr.eval,
      modelPrimitives, tokenAfter, ShellToken.word, zero, found, loopFound] <;> simp_all
  loop text _ context _ scan sv := by
    rw [LoopNative.eval_equation _ text context scan sv.2.2.2.compatible.count]
    exact model_loop_equation text context scan
  conditional text tv context cv scan sv := by
    rw [conditional_eval]
    exact model_conditional_equation text context scan tv cv.1 sv.1
  alternative text tv context cv scan sv := by
    rw [alternative_eval]
    exact model_alternative_equation text context scan tv cv.1 sv.1
  tailModel text tv context cv scan stop sv := by
    rw [tail_eval]
    exact model_tail_equation text context scan stop tv cv.1 sv.1
  tail _ _ _ _ _ _ _ := rfl
  read text tv context cv scan stop sv := by
    rw [read_eval]
    exact model_read_equation text context scan stop tv cv.1 sv.1

mutual
  theorem statement_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (sv : ValidScan text context scan) :
      calls.statement text context scan = statementBody text context.model scan := by
    rw [equations.statement text tv context cv scan sv, statementBody]
    unfold statementEval
    dsimp only [Test.eval, ScanExpr.eval, modelPrimitives, tokenAfter, ShellToken.word]
    simp only [decide_eq_true_eq]
    by_cases zero : scan.position = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      by_cases found : fixedAfter text scan.position "if" true ≠ 0
      · rw [ite_eq_left found, ite_eq_left found]
        exact conditional_unique calls equations text tv context cv scan sv
      · rw [ite_eq_right found, ite_eq_right found]
        by_cases loopFound : fixedAfter text scan.position "for" true ≠ 0
        · rw [ite_eq_left loopFound, ite_eq_left loopFound]
          exact loop_unique calls equations text tv context cv scan sv
        · rw [ite_eq_right loopFound, ite_eq_right loopFound]
  termination_by (bodyRemaining text scan, 2)

  theorem loop_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (sv : ValidScan text context scan) :
      calls.loop text context scan = loopBody text context.model scan := by
    rw [equations.loop text tv context cv scan sv,
      LoopNative.eval_equation calls.read text context scan sv.2.2.2.compatible.count,
      model_loop_equation text context scan]
    unfold LoopNative.equation
    dsimp only [modelCalls]
    by_cases allowed : loopNameAllowed text context.model (loopHeader text context.model scan) = true
    · simp only [allowed, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
      by_cases failed : (loopHeader text context.model scan).entry.position ≤ scan.position
      · simp only [failed, ↓reduceIte]
      · rw [ite_eq_right failed, ite_eq_right failed]
        have positive : (loopHeader text context.model scan).entry.position ≠ 0 := by omega
        have innerValid : Native.ValidContext text (LoopNative.inner context (loopHeader text context.model scan)) :=
          ⟨cv.1, cv.2.1,
            loopInner_valid_environment (text := text) (context := context.model) (scan := scan) cv.2.2.1 allowed positive,
            loopInner_baseReady cv.2.2.2 (loopHeader text context.model scan)⟩
        have entryValid : ValidScan text (LoopNative.inner context (loopHeader text context.model scan))
            (loopHeader text context.model scan).entry :=
          by
          refine ⟨loopHeader_bound text context.model scan, ?_, ?_⟩
          · exact sv.2.1
          · exact ⟨loopContext_bounded sv.2.2.1
              (Integer.loopBounds (loopHeader text context.model scan).lower.bounds
                (loopHeader text context.model scan).upper.bounds),
              loopHeader_flowReady cv.2.2.2 sv.2.2.2 cv.2.2.1 positive⟩
        have advanced := remaining_lt entryValid.1 (Nat.lt_of_not_ge failed)
        rw [read_unique calls equations text tv _ innerValid _ .endOnly entryValid]
    · have disallowed := Bool.eq_false_iff.mpr allowed
      simp only [disallowed, Bool.not_false, ↓reduceIte]
  termination_by (bodyRemaining text scan, 1)

  theorem conditional_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (sv : ValidScan text context scan) :
      calls.conditional text context scan = conditionalBody text context.model scan := by
    rw [equations.conditional text tv context cv scan sv, conditional_eval,
      model_conditional_equation text context scan tv cv.1 sv.1]
    unfold conditionalEquation
    dsimp only [modelCalls]
    by_cases failed : (branchStart text context.model scan "if").1.position ≤ scan.position
    · simp only [failed, ↓reduceIte]
    · rw [ite_eq_right failed, ite_eq_right failed]
      have startValid := start_valid text tv context cv scan "if" sv
      have advanced := remaining_lt startValid.1 (Nat.lt_of_not_ge failed)
      rw [read_unique calls equations text tv context cv _ .arm startValid]
      by_cases yesFailed : (readBody text context.model (branchStart text context.model scan "if").1 .arm).position ≤ scan.position
      · simp only [yesFailed, ↓reduceIte]
      · rw [ite_eq_right yesFailed, ite_eq_right yesFailed]
        have yesValid := model_read_valid text tv context cv _ .arm startValid
        have yesAdvanced := remaining_lt yesValid.1 (Nat.lt_of_not_ge yesFailed)
        have noValid : ValidScan text context
            {readBody text context.model (branchStart text context.model scan "if").1 .arm with
              facts := (branchStart text context.model scan "if").2} :=
          ⟨yesValid.1, yesValid.2.1, ⟨(branchStart_factsBounded text context.model scan "if" sv.2.2.1).2,
                (branchStart_flowReady text context.model scan "if" cv.2.2.2 sv.2.2.2).2⟩⟩
        rw [alternative_unique calls equations text tv context cv _ noValid]
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (sv : ValidScan text context scan) :
      calls.alternative text context scan = alternativeBody text context.model scan := by
    rw [equations.alternative text tv context cv scan sv, alternative_eval,
      model_alternative_equation text context scan tv cv.1 sv.1]
    unfold alternativeEquation
    dsimp only [modelCalls]
    by_cases zero : scan.position = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      by_cases found : fixedAfter text scan.position "elsif" true ≠ 0
      · rw [ite_eq_left found, ite_eq_left found]
        by_cases failed : (branchStart text context.model scan "elsif").1.position ≤ scan.position
        · simp only [failed, ↓reduceIte]
        · rw [ite_eq_right failed, ite_eq_right failed]
          have startValid := start_valid text tv context cv scan "elsif" sv
          have advanced := remaining_lt startValid.1 (Nat.lt_of_not_ge failed)
          rw [read_unique calls equations text tv context cv _ .arm startValid]
          by_cases yesFailed : (readBody text context.model (branchStart text context.model scan "elsif").1 .arm).position ≤ scan.position
          · simp only [yesFailed, ↓reduceIte]
          · rw [ite_eq_right yesFailed, ite_eq_right yesFailed]
            have yesValid := model_read_valid text tv context cv _ .arm startValid
            have yesAdvanced := remaining_lt yesValid.1 (Nat.lt_of_not_ge yesFailed)
            have noValid : ValidScan text context
                {readBody text context.model (branchStart text context.model scan "elsif").1 .arm with
                  facts := (branchStart text context.model scan "elsif").2} :=
              ⟨yesValid.1, yesValid.2.1, ⟨(branchStart_factsBounded text context.model scan "elsif" sv.2.2.1).2,
                (branchStart_flowReady text context.model scan "elsif" cv.2.2.2 sv.2.2.2).2⟩⟩
            rw [alternative_unique calls equations text tv context cv _ noValid]
      · rw [ite_eq_right found, ite_eq_right found]
        by_cases foundElse : fixedAfter text scan.position "else" true ≠ 0
        · rw [ite_eq_left foundElse, ite_eq_left foundElse]
          by_cases failed : (bodyToken text scan (.word "else")).position ≤ scan.position
          · simp only [failed, ↓reduceIte]
          · rw [ite_eq_right failed, ite_eq_right failed]
            have nextValid : ValidScan text context (bodyToken text scan (.word "else")) :=
              ⟨bodyToken_bound text scan _ sv.1, sv.2⟩
            have advanced := remaining_lt nextValid.1 (Nat.lt_of_not_ge failed)
            exact read_unique calls equations text tv context cv _ .endOnly nextValid
        · rw [ite_eq_right foundElse, ite_eq_right foundElse]
  termination_by (bodyRemaining text scan, 1)

  theorem tail_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (stop : BodyStop) (sv : ValidScan text context scan) :
      calls.tailModel text context scan stop = bodyTail text context.model scan stop := by
    rw [equations.tailModel text tv context cv scan stop sv, tail_eval,
      model_tail_equation text context scan stop tv cv.1 sv.1]
    unfold tailEquation
    dsimp only [modelCalls]
    by_cases zero : scan.position = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      by_cases stopped : atBodyStop text scan.position stop
      · rw [ite_eq_left stopped, ite_eq_left stopped]
      · rw [ite_eq_right stopped, ite_eq_right stopped]
        rw [statement_unique calls equations text tv context cv scan sv]
        by_cases failed : (statementBody text context.model scan).position ≤ scan.position
        · simp only [failed, ↓reduceIte]
        · rw [ite_eq_right failed, ite_eq_right failed]
          have nextValid := model_statement_valid text tv context cv scan sv
          have advanced := remaining_lt nextValid.1 (Nat.lt_of_not_ge failed)
          exact tail_unique calls equations text tv context cv _ stop nextValid
  termination_by (bodyRemaining text scan, 3)

  theorem read_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
      (scan : BodyScan) (stop : BodyStop) (sv : ValidScan text context scan) :
      calls.read text context scan stop = readBody text context.model scan stop := by
    rw [equations.read text tv context cv scan stop sv, read_eval,
      model_read_equation text context scan stop tv cv.1 sv.1]
    unfold readEquation
    dsimp only [modelCalls]
    rw [statement_unique calls equations text tv context cv scan sv]
    by_cases zero : (statementBody text context.model scan).position = 0
    · simp only [zero, ↓reduceIte]
    · rw [ite_eq_right zero, ite_eq_right zero]
      have nextValid := model_statement_valid text tv context cv scan sv
      have advanced := remaining_lt nextValid.1 (statementBody_progress text context.model scan zero)
      exact tail_unique calls equations text tv context cv _ stop nextValid
  termination_by (bodyRemaining text scan, 3)
end

theorem tail_executable_unique (calls : Calls) (equations : Equations calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : Native.ValidContext text context)
    (scan : BodyScan) (stop : BodyStop) (sv : ValidScan text context scan) :
    calls.tail text context scan stop = bodyTail text context.model scan stop :=
  (equations.tail text tv context cv scan stop sv).trans
    (tail_unique calls equations text tv context cv scan stop sv)

end Silver.Predicate.BodyNative
