module

public import Silver.ApplicationPackageDeclarationsObjectControl
public import Silver.ApplicationPackageDeclarationsModel

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ObjectNative
open Compose ApplicationNative

inductive Function : Ty → Type
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | take : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | validName : Function (.arrow .source (.arrow .nameSpan .truth))
  | hideOuter : Function (.arrow .source (.arrow .state (.arrow .metadata (.arrow .nameSpan .state))))
  | fresh : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .truth)))
  | newName : Function (.arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .truth .truth)))))
  | hide : Function (.arrow .source (.arrow .hiding (.arrow .number (.arrow .number .hiding))))
  | typeAt : Function (.arrow .source (.arrow .state (.arrow .metadata (.arrow .number .packageType))))
  | constraint : Function (.arrow .source (.arrow .number (.arrow .scalars (.arrow .interval .scalarConstraint))))
  | scalar : Function (.arrow .source (.arrow .number (.arrow .scalars (.arrow .number (.arrow .number (.arrow .truth .scalarResult))))))
  | empty : Function (.arrow .interval .truth)
  | included : Function (.arrow .interval (.arrow .interval .truth))
  | appendScalar : Function (.arrow .scalars (.arrow .scalarBinding .scalars))
  | booleanInitializer : Function (.arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .number .number)))))
  | staticBoolean : Function (.arrow .source (.arrow .state (.arrow .number .staticBooleanResult)))
  | singleton : Function (.arrow .integer .interval)
  | maxScalars : Function .number
  | maxBooleans : Function .number

/-- The scalar symbol specializes omitted Allow_Sign, Arrays, Initials and
Array_Reads to their actual native defaults. Its final argument is the supplied
Elaborating association; source requirements must check those defaults explicitly. -/
structure Calls where
  base : ObjectCalls
  scalar : Source → Nat → ScalarExpression.Environment → Nat → Nat → Bool → ScalarExpression.Result

def Calls.raw (calls : Calls) : ObjectCalls :=
  {calls.base with scalar := fun text position names first last => calls.scalar text position names first last true}

def functionNames : FunctionNames Function
  | _, .skip => ["skip_at"] | _, .nameAfter => ["name_after"] | _, .take => ["take_token"]
  | _, .validName => ["packages", ".", "valid_name"] | _, .hideOuter => ["hide_outer"]
  | _, .fresh => ["package_name_fresh"] | _, .newName => ["new_name_allowed"] | _, .hide => ["hide_name"]
  | _, .typeAt => ["package_type_at"] | _, .constraint => ["scalar_constraint_at"]
  | _, .scalar => ["scalar_expressions", ".", "read_expression"]
  | _, .empty => ["scalars", ".", "is_empty"] | _, .included => ["included"]
  | _, .appendScalar => ["scalar_expressions", ".", "append"]
  | _, .booleanInitializer => ["boolean_initializer_after"] | _, .staticBoolean => ["static_boolean_at"]
  | _, .singleton => ["scalars", ".", "singleton"]
  | _, .maxScalars => ["scalar_expressions", ".", "max_bindings"] | _, .maxBooleans => ["max_boolean_bindings"]

/-- Supplied native formal names for this specialized call, not a claim that the
omitted defaulted native formals are absent from Read_Expression's declaration. -/
def functionParameters : FunctionParameters Function
  | _, .scalar => ["text", "position", "names", "mask_first", "mask_after", "elaborating"]
  | _, _ => []

def Calls.get (calls : Calls) : ApplicationNative.Calls Function
  | _, .skip => calls.base.skip | _, .nameAfter => calls.base.nameAfter | _, .take => calls.base.take
  | _, .validName => calls.base.validName | _, .hideOuter => calls.base.hideOuter
  | _, .fresh => calls.base.fresh | _, .newName => calls.base.newName | _, .hide => calls.base.hide
  | _, .typeAt => calls.base.typeAt | _, .constraint => calls.base.constraint | _, .scalar => calls.scalar
  | _, .empty => calls.base.empty | _, .included => calls.base.included | _, .appendScalar => calls.base.appendScalar
  | _, .booleanInitializer => calls.base.booleanInitializer | _, .staticBoolean => calls.base.staticBoolean
  | _, .singleton => calls.base.singleton | _, .maxScalars => ScalarExpression.maxBindings
  | _, .maxBooleans => BooleanBindings.maxBindings

abbrev E := Expr Function
abbrev P := Place Function
abbrev C := ObjectControl.Command Function

def app2 (fn : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function fn) x) y

def app3 (fn : Function (.arrow a (.arrow b (.arrow c d)))) (x : E a) (y : E b) (z : E c) : E d :=
  .app (app2 fn x y) z

def app4 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : E a) (x : E b) (y : E c) (z : E d) : E e := .app (app3 fn w x y) z

def app5 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (v : E a) (w : E b) (x : E c) (y : E d) (z : E e) : E f := .app (app4 fn v w x y) z

def text : E .source := .variable "text"
def frame : E .state := .variable "frame"
def info : E .metadata := .variable "info"
def localObject : E .truth := .variable "local"
def first : E .number := .variable "first"
def last : E .number := .variable "last"
def colonEnd : E .number := .variable "colon_end"
def constantEnd : E .number := .variable "constant_end"
def result : P .objectResult := .variable "result"
def resultFrame : P .state := .field .objectFrame result

def mark : P .packageType := .field .objectMark result
def constraint : P .scalarConstraint := .variable "constraint"
def value : P .scalarResult := .variable "value"
def flag : P .staticBooleanResult := .variable "flag"
def after : P .number := .variable "after"
def name : E .nameSpan := .nameSpan first last

def set (place : P ty) (item : E ty) : C := .native (.assign place item)
def reject : C := .native (.returned .invalidObject)
def check (test : E .truth) : C := .choose test reject (.native .nothing)
def isInteger : E .truth := .kindEq (.field .markKind mark.expression) (.scalarKind .integer)
def scalars : E .scalars := .field .stateScalarNames resultFrame.expression

def scalarBody : C := .list [
  set value (.namedApp "elaborating"
    (app5 .scalar text (.field .objectInitFirst result.expression) scalars first last) (.truth true)),
  check (.orElse
    (.orElse
      (.orElse
        (.orElse (.eq (.field .scalarValueAfter value.expression) (.number 0))
          (.app (.function .empty) (.field .scalarValueBounds value.expression)))
        (.not (app2 .included (.field .scalarValueBounds value.expression) (.field .constraintBounds constraint.expression))))
      (.group (.andThen (.not localObject)
        (.intNe (.field .lower (.field .scalarValueBounds value.expression))
          (.field .upper (.field .scalarValueBounds value.expression))))))
    (.eq (.field .scalarCount scalars) (.function .maxScalars))),
  set (.field .objectInitAfter result) (.field .scalarValueAfter value.expression),
  set (.field .objectInitialBounds result) (.field .scalarValueBounds value.expression),
  set (.field .stateScalarNames resultFrame)
    (app2 .appendScalar scalars (.scalarBindingValue first last (.field .scalarValueBounds value.expression)
      (.andThen (.ne constantEnd (.number 0)) (.field .scalarValueStatic value.expression))
      (.field .constraintBounds constraint.expression) (.eq constantEnd (.number 0)) (.number 0) (.number 0))) ]

def booleanBody : C := .list [
  set after (app5 .booleanInitializer text resultFrame.expression (.field .objectInitFirst result.expression) first last),
  check (.orElse (.eq after.expression (.number 0))
    (.eq (.field .booleanCount (.field .stateBooleanNames resultFrame.expression)) (.function .maxBooleans))),
  .choose (.not localObject) (.list [
    set flag (app3 .staticBoolean text resultFrame.expression (.field .objectInitFirst result.expression)),
    check (.ne (.field .staticAfter flag.expression) after.expression),
    set (.field .objectBooleanValue result) (.field .staticValue flag.expression)]) (.native .nothing),
  set (.field .objectInitAfter result) after.expression,
  set (.field .objectInitialBounds result) (.soleApp .singleton
    (.ite (.field .objectBooleanValue result.expression) (.integer 1) (.integer 0))),
  .appendBoolean result first last (.eq constantEnd (.number 0)) (.not localObject) ]

def constant (ty : Ty) (name : String) (spelling : List String) (initial : E ty) : Declaration Function :=
  ⟨ty, name, spelling, true, some initial, [], none⟩

def localDeclaration (ty : Ty) (name : String) (spelling : List String) : Declaration Function :=
  ⟨ty, name, spelling, false, none, [], none⟩

def body : ObjectControl.Body Function where
  name := "package_object_at"
  declarations := [
    constant .number "first" ["literal_position"] (app2 .skip text (.field .statePosition frame)),
    constant .number "last" ["literal_position"] (app2 .nameAfter text first),
    constant .number "colon_end" ["literal_position"] (app3 .take text last (.token (.symbol ":"))),
    constant .number "constant_end" ["literal_position"] (app3 .take text colonEnd (.token (.word "constant"))),
    localDeclaration .objectResult "result" ["package_object_result"],
    localDeclaration .scalarConstraint "constraint" ["scalar_constraint_result"],
    localDeclaration .scalarResult "value" ["scalar_expressions", ".", "expression_result"],
    localDeclaration .staticBooleanResult "flag" ["static_boolean_result"],
    localDeclaration .number "after" ["literal_position"] ]
  commands := .list [
    check (.orElse (.not (app2 .validName text name)) (.eq colonEnd (.number 0))),
    set (.field .objectName result) name,
    .choose localObject (set resultFrame (app4 .hideOuter text frame info (.field .objectName result.expression)))
      (.choose (.andThen (app3 .fresh text info (.field .objectName result.expression))
        (app5 .newName text frame first last (.truth false)))
        (set resultFrame (.update frame (.one .stateHiding (app4 .hide text (.field .stateHiding frame) first last)))) reject),
    check (.eq (.field .statePosition resultFrame.expression) (.number 0)),
    set (.field .objectConstantObject result) (.ne constantEnd (.number 0)),
    set mark (app4 .typeAt text resultFrame.expression info (.group (.ite (.eq constantEnd (.number 0)) colonEnd constantEnd))),
    check (.eq (.field .markAfter mark.expression) (.number 0)),
    set constraint (.scalarConstraintValue (.field .markAfter mark.expression) (.field .markBounds mark.expression)),
    .choose isInteger (set constraint (app4 .constraint text (.field .markAfter mark.expression) scalars
      (.field .markBounds mark.expression))) (.native .nothing),
    set (.field .markBounds mark) (.field .constraintBounds constraint.expression),
    set (.field .objectInitFirst result) (app2 .skip text
      (app3 .take text (.field .constraintAfter constraint.expression) (.token (.symbol ":=")))),
    check (.eq (.field .objectInitFirst result.expression) (.number 0)),
    .choose isInteger scalarBody booleanBody,
    set (.field .statePosition resultFrame) (app3 .take text (.field .objectInitAfter result.expression) (.token (.symbol ";"))),
    check (.le (.field .statePosition resultFrame.expression) (.field .statePosition frame)),
    .native (.returned result.expression) ]

def scope : Scope := [(.source,"text"), (.state,"frame"), (.metadata,"info"), (.truth,"local")]

theorem body_wellFormed : body.wellFormed functionNames = true := by decide +kernel

theorem body_scoped : body.scoped scope = true := by decide +kernel

theorem body_namedCorrect : body.namedCorrect functionParameters = true := by decide +kernel

end Silver.ApplicationPackageDeclarations.ObjectNative
