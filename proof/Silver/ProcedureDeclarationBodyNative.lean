module

public import Silver.ProcedureDeclarationSyntax

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

/-- The ordinary native block retains the actual locals, input frame and
source-written output prefix before choosing Body_Tail or Read_Body. -/
def procedureBodyBody : Command .state :=
  let text : Expr .source := .variable "text"
  let outer : Expr .state := .variable "outer"
  let frame : Expr .state := .variable "frame"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let arguments : Expr .truth := .variable "arguments"
  let locals : Expr .state := .variable "locals"
  let bound : Expr .state := .variable "bound"
  let start : Expr .state := .variable "start"
  let ready : Expr .state := .variable "ready"
  let context : Expr .context := .variable "context"
  let initialized : Expr .truth := .variable "initialized"
  let scan : Expr .bodyScan := .variable "scan"
  let bodyResult : Expr .bodyScan := .variable "body_result"
  let endFirst : Expr .number := .variable "end_first"
  let endAfter : Expr .number := .variable "end_after"
  let following : Expr .number := .variable "following"
  .letValue "locals" (apply3 (.function .functionLocals) text frame arguments) <|
    .beginBody <| .guard (.eq (.field .position locals) (.number 0)) .invalid <|
    .block <| .letValue "bound" (apply2 (.function .procedureInputFrame) text locals) <|
    .beginBody <| .guard (.eq (.field .position bound) (.number 0)) .invalid <|
    .block <| .letValue "start" (.update .position bound
      (apply3 (.function .take) text (.field .position bound) (.token .beginKeyword))) <|
    .letValue "ready" (apply3 (.function .procedurePrefix) text start
      (.field .scalarCount (.field .scalarNames locals))) <|
    .beginBody <| .guard (.eq (.field .position ready) (.number 0)) .invalid <|
    .block <| .letValue "context"
      (.updateDeclarationCount (.app (.function .contextOf) (.scan ready (.truth false) (.truth false)))
        (.field .scalarCount (.field .scalarNames locals))) <|
    .letValue "initialized" (.gt (.field .position ready) (.field .position start)) <|
    .letValue "scan" (.app (.function .bodyOf) (.scan ready initialized (.truth false))) <|
    .letValue "body_result" (.group (.ite initialized
      (apply6 (.function .bodyTail) text context scan .endStop (.field .functions frame) (.field .procedures frame))
      (apply6 (.function .readBody) text context scan .endStop (.field .functions frame) (.field .procedures frame)))) <|
    .letValue "end_first" (apply2 (.function .skip) text
      (apply3 (.function .take) text (.field .bodyPosition bodyResult) (.token .endKeyword))) <|
    .letValue "end_after" (apply2 (.function .nameAfter) text endFirst) <|
    .letValue "following" (apply3 (.function .take) text endAfter (.token .semicolon)) <|
    .beginBody <| .guard
      (.orElse (.orElse (.orElse (.orElse
        (.eq (.field .bodyPosition bodyResult) (.number 0)) (.eq endFirst (.number 0)))
        (.le endAfter endFirst)) (.not (apply5 (.function .equal) text first after endFirst endAfter)))
        (.le following (.field .position outer))) .invalid <|
    .returned <| .update .subtypes
      (.update .assignedInFunctions
        (.update .hiding
          (.update .procedures (.update .position outer following)
            (apply2 (.function .appendProcedure) (.field .procedures frame)
              (.procedureSignature first after (.field .firstProcedureParameter frame)
                (.add (.sub (.field .procedureParameterCount (.field .procedures frame))
                  (.field .firstProcedureParameter frame)) (.number 1)))))
          (apply4 (.function .hideName) text (.field .hiding outer) first after))
        (.or (.field .assignedInFunctions outer) (.field .bodyAssigned bodyResult)))
      (.addHiddenCalls (.field .subtypes outer) text first after)

structure BodyInput where
  text : Source
  outer : ParserState
  frame : ParserState
  first : Nat
  after : Nat
  arguments : Bool

def BodyInput.locals (input : BodyInput) : Locals
  | .source, "text" => input.text
  | .state, "outer" => input.outer
  | .state, "frame" => input.frame
  | .number, "first" => input.first
  | .number, "after" => input.after
  | .truth, "arguments" => input.arguments
  | ty, _ => ty.default

structure BodyParts where
  context : Predicate.Native.Context
  initialized : Bool
  scan : Predicate.BodyScan
  result : Predicate.BodyScan
  endFirst : Nat
  endAfter : Nat
  following : Nat

def bodyParts (calls : Calls) (text : Source) (frame locals start ready : ParserState) : BodyParts :=
  let context := {calls .contextOf ⟨ready, false, false⟩ with declarationCount := locals.scalarNames.length}
  let initialized := decide (ready.position > start.position)
  let scan := calls .bodyOf ⟨ready, initialized, false⟩
  let result := if initialized then calls .bodyTail text context scan .endOnly frame.functions frame.procedures
    else calls .readBody text context scan .endOnly frame.functions frame.procedures
  let endFirst := calls .skip text (calls .take text result.position (.fixed "end" true))
  let endAfter := calls .nameAfter text endFirst
  ⟨context, initialized, scan, result, endFirst, endAfter, calls .take text endAfter (.fixed ";" false)⟩

def bodyPrefix (parts : BodyParts) : Bool :=
  decide (parts.result.position = 0) || decide (parts.endFirst = 0) ||
    decide (parts.endAfter ≤ parts.endFirst)

def bodyRejected (calls : Calls) (text : Source) (outer : ParserState) (first after : Nat)
    (parts : BodyParts) : Bool :=
  bodyPrefix parts ||
    !calls .equal text first after parts.endFirst parts.endAfter || decide (parts.following ≤ outer.position)

def bodyFinish (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (parts : BodyParts) : ParserState :=
  if bodyRejected calls text outer first after parts then invalidState else
  {outer with
    position := parts.following,
    procedures := calls .appendProcedure frame.procedures ⟨first, after, frame.firstProcedureParameter,
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩,
    «hiding» := calls .hideName text outer.hiding first after,
    assignedInFunctions := outer.assignedInFunctions || parts.result.assigned,
    subtypeNames := {outer.subtypeNames with hiddenCalls := {
      output := outer.subtypeNames.hiddenCalls.output || calls .nameIs text first after "put_line",
      partialOutput := outer.subtypeNames.hiddenCalls.partialOutput || calls .nameIs text first after "put",
      argument := outer.subtypeNames.hiddenCalls.argument || calls .nameIs text first after "first_or_default",
      validity := outer.subtypeNames.hiddenCalls.validity || calls .nameIs text first after "input_is_valid",
      reject := outer.subtypeNames.hiddenCalls.reject || calls .nameIs text first after "reject"}}}

def bodyEquation (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : ParserState :=
  let locals := calls .functionLocals text frame arguments
  if decide (locals.position = 0) then invalidState else
  let bound := calls .procedureInputFrame text locals
  if decide (bound.position = 0) then invalidState else
  let start := {bound with position := calls .take text bound.position (.fixed "begin" true)}
  let ready := calls .procedurePrefix text start locals.scalarNames.length
  if decide (ready.position = 0) then invalidState else
    bodyFinish calls text outer frame first after (bodyParts calls text frame locals start ready)

private theorem local_set_here (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by
  simp only [Locals.set, ↓reduceDIte, ↓reduceIte]

private theorem local_set_name (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : actual ≠ name) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceIte]
  split <;> rfl

/-- This equality interprets arbitrary linked callees. Their complete native
domains and raw equations are separate premises of the library interpretation. -/
theorem body_denotation (calls : Calls) (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) :
    procedureBodyBody.eval calls (BodyInput.locals ⟨text, outer, frame, first, after, arguments⟩) =
      bodyEquation calls text outer frame first after arguments := by
  simp +instances only [procedureBodyBody, bodyEquation, bodyParts, bodyFinish, bodyRejected, bodyPrefix,
    ↓Command.eval, ↓Expr.eval, apply2, apply3, apply4, apply5, apply6,
    ↓local_set_here, ↓local_set_name, BodyInput.locals,
    Field.get, StateField.set, Token.shell, ShellToken.word, ShellToken.symbol,
    Names.Operation.name, String.reduceEq, ne_eq, not_false_eq_true]

theorem body_model_equation (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) :
    bodyEquation modelCalls text outer frame first after arguments =
      procedureBodyAt text outer frame first after arguments := by
  dsimp +instances only [bodyEquation, procedureBodyAt, modelCalls, tokenAfter]
  simp only [decide_eq_true_eq]
  generalize functionLocals text frame arguments = locals
  generalize procedureInputFrame text locals = bound
  generalize procedurePrefix text
    {bound with position := fixedAfter text bound.position "begin" true}
    locals.scalarNames.length = ready
  dsimp +instances only [bodyParts, bodyFinish, bodyRejected, bodyPrefix, modelCalls,
    nativeContextOf, Predicate.Native.Context.model, Predicate.contextOf,
    tokenAfter, IntegerSubtypes.CallHiding.add]
  simp only [decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true', or_assoc]
  rfl

end Silver.Compose.ProcedureDeclarationNative
