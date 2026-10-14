module

public import Silver.SequenceNativeExpressions

@[expose] public section

namespace Silver.Sequence.Native
open Compose

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000

abbrev ValidText := Compose.Expressions.ValidText
abbrev ValidToken := Compose.Expressions.ValidToken

structure Ranges (calls : Calls) : Prop where
  token : ∀ text, ValidText text → ∀ context scan token,
    ValidContext text context → ValidScan text context scan → ValidToken token →
    ValidScan text context (calls.token text context scan token) ∧
      ((calls.token text context scan token).position = 0 ∨ scan.position < (calls.token text context scan token).position)
  basic : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.basic text context scan) ∧
      ((calls.basic text context scan).position = 0 ∨ scan.position < (calls.basic text context scan).position)
  statement : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.statement text context scan) ∧
      ((calls.statement text context scan).position = 0 ∨ scan.position < (calls.statement text context scan).position)
  conditional : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.conditional text context scan) ∧
      ((calls.conditional text context scan).position = 0 ∨ scan.position < (calls.conditional text context scan).position)
  alternative : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.alternative text context scan) ∧
      ((calls.alternative text context scan).position = 0 ∨ scan.position ≤ (calls.alternative text context scan).position)
  tail : ∀ text, ValidText text → ∀ context scan stop,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.tail text context scan stop) ∧
      ((calls.tail text context scan stop).position = 0 ∨ scan.position ≤ (calls.tail text context scan stop).position)
  read : ∀ text, ValidText text → ∀ context scan stop,
    ValidContext text context → ValidScan text context scan →
    ValidScan text context (calls.read text context scan stop) ∧
      ((calls.read text context scan stop).position = 0 ∨ scan.position < (calls.read text context scan stop).position)

structure Equations (primitive : Primitives) (calls : Calls) : Prop where
  ranges : Ranges calls
  token : ∀ text, ValidText text → ∀ context scan token,
    ValidContext text context → ValidScan text context scan → ValidToken token →
    calls.token text context scan token = tokenBody.eval primitive calls {text,context,scan,token}
  basic : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    calls.basic text context scan = basicBody.eval primitive calls {text,context,scan}
  stop : ∀ text, ValidText text → ∀ position stop, position ≤ text.length + 1 →
    calls.atStop text position stop = stopBody primitive text position stop
  statement : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    calls.statement text context scan = statementBody.eval primitive calls {text,context,scan}
  conditional : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    calls.conditional text context scan = conditionalBody.eval primitive calls {text,context,scan}
  alternative : ∀ text, ValidText text → ∀ context scan,
    ValidContext text context → ValidScan text context scan →
    calls.alternative text context scan = alternativeBody.eval primitive calls {text,context,scan}
  tail : ∀ text, ValidText text → ∀ context scan stop,
    ValidContext text context → ValidScan text context scan →
    calls.tail text context scan stop = tailImplementation.eval primitive calls {text,context,scan,stop}
  read : ∀ text, ValidText text → ∀ context scan stop,
    ValidContext text context → ValidScan text context scan →
    calls.read text context scan stop = readImplementation.eval primitive calls {text,context,scan,stop}

def tokens (calls : Calls) (text : Source) (context : Context) (scan : Scan)
    (values : List ShellToken) : Scan :=
  values.foldl (fun current token => calls.token text context current token) scan

theorem steps_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) (values : List ShellToken) :
    (Command.steps values).eval primitive calls ctx = (none, tokens calls ctx.text ctx.context ctx.result values) := by
  induction values generalizing ctx with
  | nil => rfl
  | cons token values ih =>
      simpa only [Command.steps, Command.list, List.map_cons, List.foldr_cons,
        Command.eval, Expr.eval, TokenRef.eval, tokens, List.foldl_cons]
        using ih {ctx with result := calls.token ctx.text ctx.context ctx.result token}

def tokenEquation (primitive : Primitives) (text : Source) (context : Context) (scan : Scan) (token : ShellToken) : Scan :=
  let result := compact context (primitive.token text (expand context scan) token)
  if result.position ≤ scan.position then invalid else result

def conditionalEquation (calls : Calls) (text : Source) (context : Context) (scan : Scan) : Scan :=
  let comparison := tokens calls text context scan equalityTokens
  if comparison.position ≤ scan.position then invalid else
  let yes := calls.read text context comparison .arm
  if yes.position ≤ scan.position then invalid else
  let final := tokens calls text context (calls.alternative text context yes) endIfTokens
  if final.position ≤ scan.position then invalid else final

def alternativeEquation (primitive : Primitives) (calls : Calls) (text : Source) (context : Context) (scan : Scan) : Scan :=
  if scan.position = 0 then invalid
  else if primitive.take text scan.position (.word "elsif") ≠ 0 then
    let comparison := tokens calls text context scan elsifTokens
    if comparison.position ≤ scan.position then invalid else
    let yes := calls.read text context comparison .arm
    if yes.position ≤ scan.position then invalid else calls.alternative text context yes
  else if primitive.take text scan.position (.word "else") ≠ 0 then
    let next := calls.token text context scan (.word "else")
    if next.position ≤ scan.position then invalid else calls.read text context next .endOnly
  else if primitive.take text scan.position (.word "end") ≠ 0 then scan else invalid

theorem token_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) :
    tokenBody.eval primitive calls ctx = tokenEquation primitive ctx.text ctx.context ctx.scan ctx.token := by
  by_cases failed : (compact ctx.context (primitive.token ctx.text (expand ctx.context ctx.scan) ctx.token)).position ≤ ctx.scan.position <;>
    simp [tokenBody, Function.eval, finish, guard, Command.eval, Expr.eval, Condition.eval, tokenEquation, failed]

theorem conditional_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) :
    conditionalBody.eval primitive calls ctx = conditionalEquation calls ctx.text ctx.context ctx.scan := by
  by_cases first : (tokens calls ctx.text ctx.context ctx.scan equalityTokens).position ≤ ctx.scan.position
  all_goals by_cases second : (calls.read ctx.text ctx.context (tokens calls ctx.text ctx.context ctx.scan equalityTokens) .arm).position ≤ ctx.scan.position
  all_goals by_cases third : (tokens calls ctx.text ctx.context (calls.alternative ctx.text ctx.context (calls.read ctx.text ctx.context (tokens calls ctx.text ctx.context ctx.scan equalityTokens) .arm)) endIfTokens).position ≤ ctx.scan.position
  all_goals simp only [tokens, equalityTokens, List.foldl_cons, List.foldl_nil] at first second third
  all_goals simp [conditionalBody, Function.eval, Command.list, Command.eval, Expr.eval,
    TokenRef.eval, StopRef.eval, steps_eval, guard, finish, Condition.eval,
    conditionalEquation, tokens, equalityTokens, first, second, third]

theorem alternative_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) :
    alternativeBody.eval primitive calls ctx = alternativeEquation primitive calls ctx.text ctx.context ctx.scan := by
  by_cases zero : ctx.scan.position = 0
  · simp [alternativeBody, Function.eval, guard, Command.eval, Condition.eval, Expr.eval, alternativeEquation, zero]
  · by_cases hasElsif : primitive.take ctx.text ctx.scan.position (.word "elsif") ≠ 0
    · by_cases first : (tokens calls ctx.text ctx.context ctx.scan elsifTokens).position ≤ ctx.scan.position
      all_goals by_cases second : (calls.read ctx.text ctx.context (tokens calls ctx.text ctx.context ctx.scan elsifTokens) .arm).position ≤ ctx.scan.position
      all_goals simp [alternativeBody, Function.eval, guard, Command.list, Command.eval, Condition.eval,
        Expr.eval, TokenRef.eval, StopRef.eval, steps_eval, alternativeEquation, zero, hasElsif, first, second]
    · by_cases hasElse : primitive.take ctx.text ctx.scan.position (.word "else") ≠ 0
      · by_cases first : (calls.token ctx.text ctx.context ctx.scan (.word "else")).position ≤ ctx.scan.position <;>
          simp [alternativeBody, Function.eval, guard, Command.list, Command.eval, Condition.eval,
            Expr.eval, TokenRef.eval, StopRef.eval, alternativeEquation, zero, hasElsif, hasElse, first]
      · by_cases hasEnd : primitive.take ctx.text ctx.scan.position (.word "end") ≠ 0 <;>
          simp [alternativeBody, Function.eval, guard, Command.eval, Condition.eval,
            Expr.eval, TokenRef.eval, alternativeEquation, zero, hasElsif, hasElse, hasEnd]

end Silver.Sequence.Native
