module

public import Silver.ComposeDeclarationAdmission
public import Silver.PredicateBodyScanner

@[expose] public section

/-! Ordered nonrecursive scalar function declaration admission. Function frames
retain earlier subtype names and completed signatures, with fresh initialized
locals followed by immutable formals. Pure body admission shares the ordinary
statement reader and ends at one typed terminal return. -/
namespace Silver.Compose
open Named Bindings

def hiddenWord (text : Source) (state : ParserState) (word : String) : Bool :=
  let bytes := word.toList.map Char.toNat
  functionHides text state.functions word ||
    state.procedures.items.any (fun item => nameIs text item.first item.after bytes) ||
    state.names.any (fun item => nameIs text item.first item.after bytes) ||
    state.scalarNames.any (fun item => nameIs text item.first item.after bytes) ||
    state.booleanNames.any (fun item => nameIs text item.first item.after bytes) ||
    state.arrayNames.names.any (fun item => nameIs text item.first item.after bytes) ||
    state.arrayNames.types.any (fun item => nameIs text item.first item.after bytes) ||
    state.subtypeNames.items.any (fun item => nameIs text item.first item.after bytes)

def hiddenOuter (text : Source) (state : ParserState) : HiddenMarks :=
  ⟨state.hiding.integerHidden || hiddenWord text state "integer",
   state.hiding.booleanHidden || hiddenWord text state "boolean",
   state.hiding.characterHidden || hiddenWord text state "character",
   state.hiding.trueHidden || hiddenWord text state "true",
   state.hiding.falseHidden || hiddenWord text state "false"⟩

def hideName (text : Source) (flags : HiddenMarks) (first after : Nat) : HiddenMarks :=
  ⟨flags.integerHidden || nameIs text first after ("integer".toList.map Char.toNat),
   flags.booleanHidden || nameIs text first after ("boolean".toList.map Char.toNat),
   flags.characterHidden || nameIs text first after ("character".toList.map Char.toNat),
   flags.trueHidden || nameIs text first after ("true".toList.map Char.toNat),
   flags.falseHidden || nameIs text first after ("false".toList.map Char.toNat)⟩

structure FunctionTypeResult where
  after : Nat
  kind : FunctionBindings.ScalarKind
  bounds : Integer.Interval
  typeId : Nat := 0
  deriving DecidableEq, Repr

def functionTypeAt (text : Source) (state : ParserState) (position : Nat) : FunctionTypeResult :=
  let integerType := scalarTypeAt text state position
  let first := skipAt text position
  let after := fixedAfter text first "boolean" true
  if integerType.after ≠ 0 then ⟨integerType.after, .integer, integerType.bounds, 0⟩
  else if after = 0 ∨ state.hiding.booleanHidden ∨
      lookupName text state.names first after ≠ 0 ∨
      ScalarExpression.lookup text state.scalarNames first after ≠ 0 ∨
      BooleanBindings.lookup text state.booleanNames first after ≠ 0 ∨
      IntegerSubtypes.lookup text state.subtypeNames first after ≠ 0 ∨
      ArrayBindings.lookup text state.arrayNames.names first after ≠ 0 ∨
      ArrayBindings.lookupType text state.arrayNames.types first after ≠ 0 ∨
      FunctionBindings.lookup text state.functions first after ≠ 0 ∨
      ProcedureBindings.lookup text state.procedures first after ≠ 0 ∨ formalHides text state first after
    then ⟨0, .integer, .empty, 0⟩ else ⟨after, .boolean, .full, 0⟩

def formalTypeAt (text : Source) (state : ParserState) (position : Nat) : FunctionTypeResult :=
  let typeId := arrayTypeAt text state position
  if typeId = 0 then functionTypeAt text state position
  else ⟨nameAfter text (skipAt text position), .integer,
    (ArrayBindings.arrayType state.arrayNames.types typeId).componentBounds, typeId⟩

structure ParameterStepResult where
  state : ParserState
  closed : Bool
  deriving DecidableEq, Repr

def parameterStep (text : Source) (state : ParserState) (arguments : Bool) : ParameterStepResult :=
  let first := skipAt text state.position
  let after := nameAfter text first
  let start := fixedAfter text (fixedAfter text after ":" false) "in" true
  let value := formalTypeAt text state start
  if !newNameAllowed text state first after arguments ∨ start = 0 ∨ value.after ≤ state.position ∨
      state.functions.parameters.length = FunctionBindings.maxFormals ∨
      equalName text first after (skipAt text start) value.after
    then ⟨invalidState, false⟩ else
  let next := {state with
    position := value.after,
    functions := FunctionBindings.appendFormal state.functions ⟨first, after, value.kind, value.bounds, value.typeId⟩,
    «hiding» := hideName text state.hiding first after}
  let separator := fixedAfter text value.after ";" false
  let close := fixedAfter text value.after ")" false
  if close ≠ 0 then ⟨{next with position := close}, true⟩
  else if separator > state.position then ⟨{next with position := separator}, false⟩
  else ⟨invalidState, false⟩

def parametersModel (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let next := parameterStep text state arguments
  if next.state.position = 0 then invalidState
  else if next.closed then next.state
  else if _advanced : Predicate.remainingAt text next.state.position < Predicate.remainingAt text state.position
    then parametersModel text next.state arguments
  else invalidState
termination_by Predicate.remainingAt text state.position
decreasing_by exact _advanced

def parametersAt := parametersModel

def functionLocalAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let scalar := scalarDeclarationAt text state arguments
  let flag := booleanDeclarationAt text state arguments
  if scalar.position ≠ 0 then scalar else flag

def functionLocalsModel (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  if state.position = 0 then invalidState
  else if fixedAfter text state.position "begin" true ≠ 0 then state
  else let next := functionLocalAt text state arguments
    if next.position = 0 then invalidState
    else if _advanced : Predicate.remainingAt text next.position < Predicate.remainingAt text state.position
      then functionLocalsModel text next arguments
    else invalidState
termination_by Predicate.remainingAt text state.position
decreasing_by exact _advanced

def functionLocals := functionLocalsModel

def appendArrayParameter (frame : ParserState) (first after typeId : Nat) : ParserState :=
  if typeId = 0 ∨ typeId > frame.arrayNames.types.length ∨
      frame.arrayNames.names.length = ArrayBindings.maxBindings ∨
      ¬ArrayBindings.ValidType (ArrayBindings.arrayType frame.arrayNames.types typeId) ∨
      (frame.arrayNames.names.length > 0 ∧
        (ArrayBindings.binding frame.arrayNames.names frame.arrayNames.names.length).viewSlot = 0)
  then invalidState
  else
    let item := ArrayBindings.arrayType frame.arrayNames.types typeId
    let slot := frame.arrayNames.names.length + 1
    let length := (item.bounds.upper - item.bounds.lower + 1).toNat
    {frame with arrayNames := {frame.arrayNames with names := frame.arrayNames.names ++
      [⟨first, after, item.bounds, 0, length, false, item.componentBounds, false, typeId, slot⟩]}}

def appendParameter (frame : ParserState) (parameter : FunctionBindings.Formal) : ParserState :=
  if parameter.typeId ≠ 0 then appendArrayParameter frame parameter.first parameter.after parameter.typeId
  else if parameter.kind = .integer then
    if frame.scalarNames.length = ScalarExpression.maxBindings then invalidState
    else {frame with scalarNames := frame.scalarNames ++
      [⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds, false⟩]}
  else if frame.booleanNames.length = BooleanBindings.maxBindings then invalidState
  else {frame with booleanNames := frame.booleanNames ++ [⟨parameter.first, parameter.after, false⟩]}

def parameterFrameModel (frame : ParserState) (index : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if index > frame.functions.parameters.length then frame
  else let next := appendParameter frame (FunctionBindings.parameter frame.functions index)
    if next.position = 0 then invalidState
    else if _advanced : next.functions.parameters.length + 1 - (index + 1) < frame.functions.parameters.length + 1 - index
      then parameterFrameModel next (index + 1)
    else invalidState
termination_by frame.functions.parameters.length + 1 - index
decreasing_by simpa only [Nat.add_sub_add_right] using _advanced

def parameterFrame (_text : Source) (frame : ParserState) : ParserState :=
  parameterFrameModel frame frame.firstParameter

def functionReturnAfter (text : Source) (context : Predicate.ParseContext) (scan : Predicate.BodyScan)
    (resultType : FunctionTypeResult) : Nat :=
  Predicate.actualAfter text context (fixedAfter text scan.position "return" true) scan.facts
    ⟨0, 0, resultType.kind, resultType.bounds, 0⟩

def functionBodyAt (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) : ParserState :=
  let locals := functionLocals text frame arguments
  if locals.position = 0 then invalidState else
  let bound := parameterFrame text locals
  if bound.position = 0 then invalidState else
  let start := {bound with position := fixedAfter text bound.position "begin" true}
  let context := {Predicate.contextOf ⟨start, false, false⟩ with declarationCount := locals.scalarNames.length}
  let bodyResult := Predicate.bodyTail text context (Predicate.bodyOf ⟨start, false, false⟩) .returnOnly frame.functions
  let returnEnd := functionReturnAfter text context bodyResult resultType
  let endFirst := skipAt text (fixedAfter text (fixedAfter text returnEnd ";" false) "end" true)
  let endAfter := nameAfter text endFirst
  let following := fixedAfter text endAfter ";" false
  if bodyResult.position = 0 ∨ returnEnd = 0 ∨ endFirst = 0 ∨ endAfter ≤ endFirst ∨
      !equalName text first after endFirst endAfter ∨ following ≤ outer.position then invalidState else
  {outer with
    position := following,
    functions := FunctionBindings.append frame.functions ⟨first, after, frame.firstParameter,
      frame.functions.parameters.length - frame.firstParameter + 1, resultType.kind, resultType.bounds⟩,
    «hiding» := hideName text outer.hiding first after,
    assignedInFunctions := outer.assignedInFunctions || bodyResult.assigned,
    subtypeNames := {outer.subtypeNames with hiddenCalls := outer.subtypeNames.hiddenCalls.add text first after}}

def functionDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let start := fixedAfter text state.position "function" true
  let first := skipAt text start
  let after := nameAfter text first
  let opening := fixedAfter text after "(" false
  if start = 0 ∨ opening = 0 ∨ state.pure ∨ !newNameAllowed text state first after arguments ∨
      state.functions.items.length = FunctionBindings.maxFunctions ∨
      state.functions.parameters.length = FunctionBindings.maxFormals then invalidState else
  let initial := {initialState with
    position := opening, pure := true,
    subtypeNames := state.subtypeNames, functions := state.functions, procedures := state.procedures,
    arrayNames := {types := state.arrayNames.types},
    «hiding» := hideName text (hiddenOuter text state) first after,
    firstParameter := state.functions.parameters.length + 1}
  let header := parametersAt text initial arguments
  if header.position = 0 then invalidState else
  let resultType := functionTypeAt text header (fixedAfter text header.position "return" true)
  let bodyStart := fixedAfter text resultType.after "is" true
  if resultType.after = 0 ∨ bodyStart = 0 then invalidState else
  functionBodyAt text state {header with position := bodyStart} first after resultType arguments

end Silver.Compose
