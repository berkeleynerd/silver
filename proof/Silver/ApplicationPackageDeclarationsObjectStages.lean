module

public import Silver.ApplicationPackageDeclarationsObjectNative

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ObjectNative
open Compose ApplicationNative

set_option maxRecDepth 20000
set_option maxHeartbeats 2000000

def finishCommands : C := .list [
  set (.field .statePosition resultFrame) (app3 .take text (.field .objectInitAfter result.expression) (.token (.symbol ";"))),
  check (.le (.field .statePosition resultFrame.expression) (.field .statePosition frame)),
  .native (.returned result.expression) ]

def valueCommands : C := .sequence (.choose isInteger scalarBody booleanBody) finishCommands

def initializePrefix : C := .list [
  set (.field .markBounds mark) (.field .constraintBounds constraint.expression),
  set (.field .objectInitFirst result) (app2 .skip text
    (app3 .take text (.field .constraintAfter constraint.expression) (.token (.symbol ":=")))),
  check (.eq (.field .objectInitFirst result.expression) (.number 0)) ]

def initializeCommands : C := .sequence initializePrefix valueCommands

def typePrefix : C := .list [
  check (.eq (.field .statePosition resultFrame.expression) (.number 0)),
  set (.field .objectConstantObject result) (.ne constantEnd (.number 0)),
  set mark (app4 .typeAt text resultFrame.expression info (.group (.ite (.eq constantEnd (.number 0)) colonEnd constantEnd))),
  check (.eq (.field .markAfter mark.expression) (.number 0)),
  set constraint (.scalarConstraintValue (.field .markAfter mark.expression) (.field .markBounds mark.expression)) ]

def constraintCommand : C :=
  .choose isInteger (set constraint (app4 .constraint text (.field .markAfter mark.expression) scalars
    (.field .markBounds mark.expression))) (.native .nothing)

def typeCommands : C := .sequence typePrefix (.sequence constraintCommand initializeCommands)

def namePrefix : C := .list [
  check (.orElse (.not (app2 .validName text name)) (.eq colonEnd (.number 0))),
  set (.field .objectName result) name,
  .choose localObject (set resultFrame (app4 .hideOuter text frame info (.field .objectName result.expression)))
    (.choose (.andThen (app3 .fresh text info (.field .objectName result.expression))
      (app5 .newName text frame first last (.truth false)))
      (set resultFrame (.update frame (.one .stateHiding (app4 .hide text (.field .stateHiding frame) first last)))) reject) ]

/-- The unchanged final source commands observe only these three locals. -/
def finishModel (calls : Calls) (locals : Locals) : ObjectResult :=
  finishObject calls.raw (locals .source "text") (locals .state "frame") (locals .objectResult "result")

theorem finishCommands_meaning (calls : Calls) (locals : Locals) :
    finishCommands.eval calls.get locals (fun _ => invalidObject) = finishModel calls locals := by
  dsimp only [finishCommands, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, Locals.set, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  rfl

theorem scalarBody_meaning (calls : Calls) (locals : Locals) :
    scalarBody.eval calls.get locals (finishModel calls) =
      objectScalar calls.raw (locals .source "text") (locals .state "frame")
        (locals .number "first") (locals .number "last") (locals .number "constant_end")
        (locals .truth "local") (locals .objectResult "result") (locals .scalarConstraint "constraint") := by
  dsimp only [scalarBody, objectScalar, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, Locals.set, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  rfl

theorem booleanBody_meaning (calls : Calls) (locals : Locals) :
    booleanBody.eval calls.get locals (finishModel calls) =
      objectBoolean calls.raw (locals .source "text") (locals .state "frame")
        (locals .number "first") (locals .number "last") (locals .number "constant_end")
        (locals .truth "local") (locals .objectResult "result") := by
  dsimp only [booleanBody, objectBoolean, objectBooleanFinish, ObjectControl.Command.eval, ObjectControl.Command.list, ObjectControl.appendBoolean,
    Command.eval, Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set,
    Calls.get, Calls.raw, Locals.set, List.foldr, set, check, reject, app2, app3, app4, app5,
    isInteger, scalars, ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
    first, last, colonEnd, constantEnd, result, resultFrame, mark, constraint, value, flag, after, name,
    finishModel, finishObject, invalidObject]
  rfl

end Silver.ApplicationPackageDeclarations.ObjectNative
