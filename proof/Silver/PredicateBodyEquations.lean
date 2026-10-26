module

public import Silver.PredicateBodyExpressions

@[expose] public section
namespace Silver.Predicate.BodyNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def conditionalEquation (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  let start := branchStart text context.model scan "if"
  if start.1.position ≤ scan.position then invalidBody scan else
  let yes := calls.read text context start.1 .arm
  if yes.position ≤ scan.position then invalidBody scan else
  let no := calls.alternative text context {yes with facts := start.2}
  let joined := {no with facts := yes.facts.join no.facts}
  let result := bodyTokens text joined [.word "end", .word "if", .symbol ";"]
  if result.position ≤ scan.position then invalidBody scan else result

def alternativeEquation (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  if scan.position = 0 then invalidBody scan
  else if fixedAfter text scan.position "elsif" true ≠ 0 then
    let start := branchStart text context.model scan "elsif"
    if start.1.position ≤ scan.position then invalidBody scan else
    let yes := calls.read text context start.1 .arm
    if yes.position ≤ scan.position then invalidBody scan else
    let no := calls.alternative text context {yes with facts := start.2}
    {no with facts := yes.facts.join no.facts}
  else if fixedAfter text scan.position "else" true ≠ 0 then
    let start := bodyToken text scan (.word "else")
    if start.position ≤ scan.position then invalidBody scan else calls.read text context start .endOnly
  else if fixedAfter text scan.position "end" true ≠ 0 then scan else invalidBody scan

def tailEquation (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
  if scan.position = 0 then invalidBody scan
  else if atBodyStop text scan.position stop then scan
  else
    let next := calls.statement text context scan
    if next.position ≤ scan.position then invalidBody next else calls.tailModel text context next stop

def readEquation (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
  let next := calls.statement text context scan
  if next.position = 0 then invalidBody next else calls.tailModel text context next stop

theorem conditional_eval (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) :
    conditionalFunction.eval modelPrimitives calls {text, context, scan} = conditionalEquation calls text context scan := by
  by_cases first : (branchStart text context.model scan "if").1.position ≤ scan.position
  all_goals by_cases second : (calls.read text context (branchStart text context.model scan "if").1 .arm).position ≤ scan.position
  all_goals by_cases third :
    (let start := branchStart text context.model scan "if"
     let yes := calls.read text context start.1 .arm
     let no := calls.alternative text context {yes with facts := start.2}
     bodyTokens text {no with facts := yes.facts.join no.facts}
       [.word "end", .word "if", .symbol ";"]).position ≤ scan.position
  all_goals simp only [branchStart, bodyToken] at first second
  all_goals simp only [branchStart, bodyToken, bodyTokens, List.foldl_cons, List.foldl_nil] at third
  all_goals simp +instances [Function.eval, conditionalFunction, Command.eval, Command.list, guard, finish,
    ScanExpr.eval, FactsExpr.eval, Test.eval, StopRef.eval, modelPrimitives,
    conditionalEquation, branchStart, bodyToken, bodyTokens, ActiveFlow.join_comm, first, second, third]

theorem alternative_eval (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) :
    alternativeFunction.eval modelPrimitives calls {text, context, scan} = alternativeEquation calls text context scan := by
  by_cases zero : scan.position = 0
  all_goals by_cases found : fixedAfter text scan.position "elsif" true ≠ 0
  all_goals by_cases first : (branchStart text context.model scan "elsif").1.position ≤ scan.position
  all_goals by_cases second : (calls.read text context (branchStart text context.model scan "elsif").1 .arm).position ≤ scan.position
  all_goals by_cases foundElse : fixedAfter text scan.position "else" true ≠ 0
  all_goals by_cases next : (bodyToken text scan (.word "else")).position ≤ scan.position
  all_goals by_cases foundEnd : fixedAfter text scan.position "end" true ≠ 0
  all_goals simp only [branchStart, bodyToken, tokenAfter, ShellToken.word] at first second next
  all_goals simp +instances [Function.eval, alternativeFunction, Command.eval, Command.list, guard,
    ScanExpr.eval, FactsExpr.eval, Test.eval, StopRef.eval, modelPrimitives,
    alternativeEquation, branchStart, bodyToken, tokenAfter, ShellToken.word,
    zero, found, first, second, foundElse, next, foundEnd, ActiveFlow.join_comm]

theorem tail_eval (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop) :
    tailModelBody.eval modelPrimitives calls {text, context, scan, stop} = tailEquation calls text context scan stop := by
  by_cases zero : scan.position = 0
  all_goals by_cases stopped : atBodyStop text scan.position stop = true
  all_goals by_cases failed : (calls.statement text context scan).position ≤ scan.position
  all_goals simp +instances [ModelExpr.eval, tailModelBody, modelPrimitives,
    ScanExpr.eval, Test.eval, StopRef.eval, tailEquation, zero, stopped, failed]

theorem read_eval (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop) :
    readContractBody.eval modelPrimitives calls {text, context, scan, stop} = readEquation calls text context scan stop := by
  by_cases zero : (calls.statement text context scan).position = 0
  all_goals simp +instances [ModelExpr.eval, readContractBody, modelPrimitives,
    ScanExpr.eval, Test.eval, StopRef.eval, readEquation, zero]

theorem remaining_lt {text : Source} {left right : BodyScan}
    (bounded : right.position ≤ text.length + 1) (advanced : left.position < right.position) :
    bodyRemaining text right < bodyRemaining text left := by
  unfold bodyRemaining remainingAt
  omega

theorem model_conditional_equation (text : Source) (context : Native.Context) (scan : BodyScan)
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (sv : scan.position ≤ text.length + 1) :
    conditionalBody text context.model scan = conditionalEquation modelCalls text context scan := by
  rw [conditionalBody]
  unfold conditionalEquation
  dsimp only [modelCalls]
  by_cases failed : (branchStart text context.model scan "if").1.position ≤ scan.position
  · simp only [failed, ↓reduceIte]
  · have advanced := remaining_lt (branchStart_bound text context.model scan "if" tv nv sv) (Nat.lt_of_not_ge failed)
    simp only [failed, advanced, ↓reduceIte, ↓reduceDIte]
    by_cases yesFailed : (readBody text context.model (branchStart text context.model scan "if").1 .arm).position ≤ scan.position
    · simp only [yesFailed, ↓reduceIte]
    · have yesAdvanced := remaining_lt
        (readBody_bound text context.model _ .arm tv nv (branchStart_bound text context.model scan "if" tv nv sv))
        (Nat.lt_of_not_ge yesFailed)
      simp only [yesFailed, yesAdvanced, ↓reduceIte, ↓reduceDIte]

theorem model_alternative_equation (text : Source) (context : Native.Context) (scan : BodyScan)
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (sv : scan.position ≤ text.length + 1) :
    alternativeBody text context.model scan = alternativeEquation modelCalls text context scan := by
  rw [alternativeBody]
  unfold alternativeEquation
  dsimp only [modelCalls]
  by_cases zero : scan.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases found : fixedAfter text scan.position "elsif" true ≠ 0
    · rw [ite_eq_left found, ite_eq_left found]
      try dsimp only
      by_cases failed : (branchStart text context.model scan "elsif").1.position ≤ scan.position
      · simp only [failed, ↓reduceIte]
      · have advanced := remaining_lt (branchStart_bound text context.model scan "elsif" tv nv sv) (Nat.lt_of_not_ge failed)
        simp only [failed, advanced, ↓reduceIte, ↓reduceDIte]
        by_cases yesFailed : (readBody text context.model (branchStart text context.model scan "elsif").1 .arm).position ≤ scan.position
        · simp only [yesFailed, ↓reduceIte]
        · have yesAdvanced := remaining_lt
            (readBody_bound text context.model _ .arm tv nv (branchStart_bound text context.model scan "elsif" tv nv sv))
            (Nat.lt_of_not_ge yesFailed)
          simp only [yesFailed, yesAdvanced, ↓reduceIte, ↓reduceDIte]
    · rw [ite_eq_right found, ite_eq_right found]
      by_cases foundElse : fixedAfter text scan.position "else" true ≠ 0
      · rw [ite_eq_left foundElse, ite_eq_left foundElse]
        try dsimp only
        by_cases failed : (bodyToken text scan (.word "else")).position ≤ scan.position
        · simp only [failed, ↓reduceIte]
        · have advanced := remaining_lt (bodyToken_bound text scan (.word "else") sv) (Nat.lt_of_not_ge failed)
          simp only [failed, advanced, ↓reduceIte, ↓reduceDIte]
      · simp only [foundElse, ↓reduceIte]

theorem model_tail_equation (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop)
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (sv : scan.position ≤ text.length + 1) :
    bodyTail text context.model scan stop = tailEquation modelCalls text context scan stop := by
  rw [bodyTail]
  unfold tailEquation
  dsimp only [modelCalls]
  by_cases zero : scan.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases stopped : atBodyStop text scan.position stop
    · rw [ite_eq_left stopped, ite_eq_left stopped]
    · rw [ite_eq_right stopped, ite_eq_right stopped]
      try dsimp only
      by_cases failed : (statementBody text context.model scan).position ≤ scan.position
      · simp only [failed, ↓reduceIte]
      · have advanced := remaining_lt (statementBody_bound text context.model scan tv nv sv) (Nat.lt_of_not_ge failed)
        simp only [failed, advanced, ↓reduceIte, ↓reduceDIte]

theorem model_read_equation (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop)
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (sv : scan.position ≤ text.length + 1) :
    readBody text context.model scan stop = readEquation modelCalls text context scan stop := by
  rw [readBody]
  unfold readEquation
  dsimp only [modelCalls]
  by_cases zero : (statementBody text context.model scan).position = 0
  · simp only [zero, ↓reduceIte]
  · have advanced := remaining_lt (statementBody_bound text context.model scan tv nv sv)
      (statementBody_progress text context.model scan zero)
    simp only [zero, advanced, ↓reduceIte, ↓reduceDIte]

theorem model_loop_equation (text : Source) (context : Native.Context) (scan : BodyScan) :
    loopBody text context.model scan = LoopNative.equation modelCalls.read text context scan := by
  rw [loopBody]
  unfold LoopNative.equation
  dsimp only [modelCalls]
  by_cases allowed : loopNameAllowed text context.model (loopHeader text context.model scan) = true
  · simp only [allowed, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    by_cases failed : (loopHeader text context.model scan).entry.position ≤ scan.position
    · simp only [failed, ↓reduceIte]
    · have advanced := remaining_lt (loopHeader_bound text context.model scan) (Nat.lt_of_not_ge failed)
      simp only [failed, advanced, ↓reduceIte, ↓reduceDIte, LoopNative.inner_model]
      rfl
  · have disallowed := Bool.eq_false_iff.mpr allowed
    simp only [disallowed, Bool.not_false, ↓reduceIte]

end Silver.Predicate.BodyNative
