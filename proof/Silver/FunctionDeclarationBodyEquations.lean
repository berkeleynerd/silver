module

public import Silver.FunctionDeclarationNative

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true


structure BodyParts where
  start : ParserState
  context : Predicate.Native.Context
  scan : Predicate.BodyScan
  returnEnd : Nat
  endFirst : Nat
  endAfter : Nat
  following : Nat

def bodyParts (calls : Calls) (text : Source) (frame locals bound : ParserState)
    (resultType : FunctionTypeResult) : BodyParts :=
  let start := {bound with position := calls .take text bound.position (.fixed "begin" true)}
  let context := {calls .contextOf ⟨start, false, false⟩ with declarationCount := locals.scalarNames.length}
  let scan := calls .bodyTail text context (calls .bodyOf ⟨start, false, false⟩) .returnOnly frame.functions {}
  let returnEnd := calls .returnAfter text context scan resultType
  let endFirst := calls .skip text (calls .take text (calls .take text returnEnd (.fixed ";" false)) (.fixed "end" true))
  let endAfter := calls .nameAfter text endFirst
  let following := calls .take text endAfter (.fixed ";" false)
  ⟨start, context, scan, returnEnd, endFirst, endAfter, following⟩

def bodyPrefix (parts : BodyParts) : Bool :=
  decide (parts.scan.position = 0) || decide (parts.returnEnd = 0) ||
    decide (parts.endFirst = 0) || decide (parts.endAfter ≤ parts.endFirst)

def bodyRejected (calls : Calls) (text : Source) (outer : ParserState) (first after : Nat)
    (parts : BodyParts) : Bool :=
  bodyPrefix parts || !calls .equal text first after parts.endFirst parts.endAfter ||
    decide (parts.following ≤ outer.position)

def bodyFinish (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (parts : BodyParts) : ParserState :=
  if bodyRejected calls text outer first after parts then invalidState else
  {outer with
    position := parts.following,
    functions := calls .append frame.functions ⟨first, after, frame.firstParameter,
      frame.functions.parameters.length - frame.firstParameter + 1, resultType.kind, resultType.bounds⟩,
    «hiding» := calls .hideName text outer.hiding first after,
    assignedInFunctions := outer.assignedInFunctions || parts.scan.assigned,
    subtypeNames := {outer.subtypeNames with hiddenCalls := {
      output := outer.subtypeNames.hiddenCalls.output || calls .nameIs text first after "put_line",
      partialOutput := outer.subtypeNames.hiddenCalls.partialOutput || calls .nameIs text first after "put",
      argument := outer.subtypeNames.hiddenCalls.argument || calls .nameIs text first after "first_or_default",
      validity := outer.subtypeNames.hiddenCalls.validity || calls .nameIs text first after "input_is_valid",
      reject := outer.subtypeNames.hiddenCalls.reject || calls .nameIs text first after "reject"}}}

def bodyEquation (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) : ParserState :=
  let locals := calls .functionLocals text frame arguments
  if decide (locals.position = 0) then invalidState else
  let bound := calls .parameterFrame text locals
  if decide (bound.position = 0) then invalidState else
    bodyFinish calls text outer frame first after resultType (bodyParts calls text frame locals bound resultType)

private theorem local_set_here (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by
  simp only [Locals.set, ↓reduceDIte, ↓reduceIte]

private theorem local_set_name (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : actual ≠ name) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceIte]
  split <;> rfl

private theorem local_set_type (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : other ≠ ty) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceDIte]

theorem body_denotation (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) :
    functionBodyBody.eval calls ({text, outer, frame, first, after, resultType, arguments} : Frame).locals =
      bodyEquation calls text outer frame first after resultType arguments := by
  simp +instances only [functionBodyBody, bodyEquation, bodyParts, bodyFinish, bodyRejected, bodyPrefix,
    ↓Command.eval, ↓Expr.eval, apply2, apply3, apply4, apply5, apply6,
    ↓local_set_here, ↓local_set_name, Frame.locals,
    Field.get, StateField.set, Token.shell, ShellToken.word, ShellToken.symbol,
    Names.Operation.name, String.reduceEq, ne_eq, not_false_eq_true, ↓reduceIte]
  rfl

end Silver.Compose.FunctionDeclarationNative
