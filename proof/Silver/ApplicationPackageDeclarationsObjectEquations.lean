module

public import Silver.ApplicationPackageDeclarationsObjectStages

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ObjectNative
open Compose ApplicationNative

set_option maxRecDepth 20000
set_option maxHeartbeats 2000000

def valueModel (calls : Calls) (locals : Locals) : ObjectResult :=
  if decide ((locals .objectResult "result").mark.kind = .integer) then
    objectScalar calls.raw (locals .source "text") (locals .state "frame")
      (locals .number "first") (locals .number "last") (locals .number "constant_end")
      (locals .truth "local") (locals .objectResult "result") (locals .scalarConstraint "constraint")
  else
    objectBoolean calls.raw (locals .source "text") (locals .state "frame")
      (locals .number "first") (locals .number "last") (locals .number "constant_end")
      (locals .truth "local") (locals .objectResult "result")

theorem valueCommands_meaning (calls : Calls) (locals : Locals) :
    valueCommands.eval calls.get locals (fun _ => invalidObject) = valueModel calls locals := by
  change (if isInteger.eval calls.get locals then
    scalarBody.eval calls.get locals (fun updated => finishCommands.eval calls.get updated (fun _ => invalidObject))
    else booleanBody.eval calls.get locals (fun updated => finishCommands.eval calls.get updated (fun _ => invalidObject))) = _
  have tail : (fun updated => finishCommands.eval calls.get updated (fun _ => invalidObject)) =
      finishModel calls := funext (finishCommands_meaning calls)
  rw [tail, scalarBody_meaning, booleanBody_meaning]
  rfl

def initializeModel (calls : Calls) (locals : Locals) : ObjectResult :=
  objectInitialized calls.raw (locals .source "text") (locals .state "frame")
    (locals .number "first") (locals .number "last") (locals .number "constant_end")
    (locals .truth "local") (locals .objectResult "result") (locals .scalarConstraint "constraint")

theorem initializeCommands_meaning (calls : Calls) (locals : Locals) :
    initializeCommands.eval calls.get locals (fun _ => invalidObject) = initializeModel calls locals := by
  change initializePrefix.eval calls.get locals
    (fun updated => valueCommands.eval calls.get updated (fun _ => invalidObject)) = _
  rw [show (fun updated => valueCommands.eval calls.get updated (fun _ => invalidObject)) =
    valueModel calls from funext (valueCommands_meaning calls)]
  dsimp only [initializePrefix, initializeModel, valueModel, objectInitialized, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, Locals.set, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  rfl

theorem sequence_step (calls : Calls) (locals : Locals) (next : Locals → ObjectResult)
    (first rest : C) :
    (ObjectControl.Command.sequence first rest).eval calls.get locals next =
      first.eval calls.get locals (fun updated => rest.eval calls.get updated next) := rfl

def typeModel (calls : Calls) (locals : Locals) : ObjectResult :=
  objectTyped calls.raw (locals .source "text") (locals .state "frame") (locals .metadata "info")
    (locals .number "first") (locals .number "last") (locals .number "colon_end")
    (locals .number "constant_end") (locals .truth "local") (locals .objectResult "result")

theorem typeCommands_meaning (calls : Calls) (locals : Locals) :
    typeCommands.eval calls.get locals (fun _ => invalidObject) = typeModel calls locals := by
  unfold typeCommands
  rw [sequence_step (first := typePrefix) (rest := .sequence constraintCommand initializeCommands) calls]
  simp only [sequence_step (first := constraintCommand) (rest := initializeCommands) calls]
  rw [show (fun following => initializeCommands.eval calls.get following (fun _ => invalidObject)) =
    initializeModel calls from funext (initializeCommands_meaning calls)]
  dsimp only [typePrefix, constraintCommand, typeModel, initializeModel, objectTyped, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, Locals.set, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  generalize objectInitialized = continuation
  rfl

def inputLocals (prior : Locals) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) : Locals :=
  (((prior.set .source "text" text).set .state "frame" frame).set .metadata "info" info).set .truth "local" localObject

def continueWith (next : ObjectContinuation) (locals : Locals) : ObjectResult :=
  next (locals .source "text") (locals .state "frame") (locals .metadata "info")
    (locals .number "first") (locals .number "last") (locals .number "colon_end")
    (locals .number "constant_end") (locals .truth "local") (locals .objectResult "result")

/-- The source entry logic is independent of the entire following typed suffix. -/
theorem namePrefix_meaning (calls : Calls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) (prior : Locals)
    (next : ObjectContinuation) :
    namePrefix.eval calls.get
      (body.declarations.foldl (Declaration.eval calls.get) (inputLocals prior text frame info localObject))
      (continueWith next) = objectNameStep calls.raw text frame info localObject next := by
  dsimp only [body, constant, localDeclaration, Declaration.eval, Declaration.names,
    Initialization.value, List.foldl, inputLocals, namePrefix, continueWith, objectNameStep, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  simp [Locals.set]

/-- Complete original typed Object execution, on arbitrary calls and locals. -/
theorem denotation (calls : Calls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) (prior : Locals) :
    body.eval calls.get (inputLocals prior text frame info localObject) =
      objectStep calls.raw text frame info localObject := by
  change namePrefix.eval calls.get
    (body.declarations.foldl (Declaration.eval calls.get) (inputLocals prior text frame info localObject))
    (fun updated => typeCommands.eval calls.get updated (fun _ => invalidObject)) = _
  rw [show (fun updated => typeCommands.eval calls.get updated (fun _ => invalidObject)) =
    typeModel calls from funext (typeCommands_meaning calls)]
  exact namePrefix_meaning calls text frame info localObject prior (objectTyped calls.raw)

end Silver.ApplicationPackageDeclarations.ObjectNative
