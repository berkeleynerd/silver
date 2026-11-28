module

public import Silver.ApplicationPackageCallsImports
public import Silver.ApplicationNativeLoopFacts
public import Silver.SourceDeclarations

@[expose] public section

/-! Exact finite source expressions for Included, Valid_Flow and Valid_Body.
The flow quantifier covers every allocated value cell; neither context metadata
validity nor reachable-state assumptions are inserted into these equations. -/
namespace Silver.ApplicationPackageCalls.ValidityNative
open ApplicationNative

set_option backward.dsimp.instances true

inductive Function : Ty → Type
  | empty : Function (.arrow .interval .truth)
  | included : Function (.arrow .interval (.arrow .interval .truth))
  | validFlow : Function (.arrow .parseContext (.arrow .activeFlow .truth))

def names : FunctionNames Function
  | _, .empty => ["scalars", ".", "is_empty"]
  | _, .included => ["included"]
  | _, .validFlow => ["valid_flow"]

def imports : ApplicationNative.Calls Function
  | _, .empty => Integer.Interval.isEmpty
  | _, .included => includedCheck
  | _, .validFlow => flowValidCheck

abbrev E := Expr Function

def text : E .source := .variable "text"
def context : E .parseContext := .variable "context"
def facts : E .activeFlow := .variable "facts"
def scan : E .bodyScan := .variable "scan"
def value : E .interval := .variable "value"
def bounds : E .interval := .variable "bounds"
def index : E .number := .variable "index"
def binding : E .scalarBinding := .index .scalar (.field .contextScalarNames context) index
def cell : E .interval := .index .flowValue facts index

def call1 (fn : Function (.arrow a b)) (argument : E a) : E b := .app (.function fn) argument
def call2 (fn : Function (.arrow a (.arrow b c))) (left : E a) (right : E b) : E c :=
  .app (call1 fn left) right

def includedExpression : E .truth := .orElse (call1 .empty value)
  (.group (.andThen
    (.andThen (.not (call1 .empty bounds)) (.intGe (.field .lower value) (.field .lower bounds)))
    (.intLe (.field .upper value) (.field .upper bounds))))

def flowCellExpression : E .truth := .group (.ite (.field .scalarMutable binding)
  (.andThen (.not (call1 .empty cell)) (call2 .included cell (.field .scalarDeclaredBounds binding)))
  (.elsif (.gt index (.field .contextDeclarationCount context))
    (call2 .included cell (.field .scalarBounds binding))
    (.intervalEq cell (.field .scalarBounds binding))))

def flowExpression : E .truth := .andThen
  (.eq (.property .flowCount facts) (.field .scalarCount (.field .contextScalarNames context)))
  (.group (.forAllFlowValues "index" facts flowCellExpression))

def bodyExpression : E .truth := .andThen
  (.andThen (.le (.field .scanPosition scan) (.add (.sourceLast text) (.number 1)))
    (.le (.field .scanTarget scan) (.field .nameCount (.field .contextNames context))))
  (call2 .validFlow context (.field .scanFacts scan))

theorem complete_expressions_wellFormed :
    includedExpression.wellFormedRoot names = true ∧ flowExpression.wellFormedRoot names = true ∧
    bodyExpression.wellFormedRoot names = true := by decide +kernel

theorem complete_expressions_scoped :
    includedExpression.scoped [(.interval, "value"), (.interval, "bounds")] = true ∧
    flowExpression.scoped [(.parseContext, "context"), (.activeFlow, "facts")] = true ∧
    bodyExpression.scoped [(.source, "text"), (.parseContext, "context"), (.bodyScan, "scan")] = true := by decide +kernel

theorem included_meaning (locals : Locals) :
    includedExpression.eval imports locals = includedCheck (locals .interval "value") (locals .interval "bounds") := rfl

private theorem cell_meaning (locals : Locals) (offset : Nat) :
    flowCellExpression.eval imports (locals.set .number "index" (offset + 1)) =
      flowCellCheck (locals .parseContext "context") (locals .activeFlow "facts") (offset + 1) := by
  dsimp only [flowCellExpression, binding, cell, call2, call1, context, facts, index,
    Expr.eval, Field.get, Index.get, imports, flowCellCheck]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, decide_eq_true_eq]

theorem flow_meaning (locals : Locals) :
    flowExpression.eval imports locals = flowValidCheck (locals .parseContext "context") (locals .activeFlow "facts") := by
  exact congrArg (fun test : Nat → Bool =>
    decide ((locals .activeFlow "facts").count = (locals .parseContext "context").scalarNames.length) &&
      (List.range (locals .activeFlow "facts").count).all test) (funext (cell_meaning locals))

theorem body_meaning (locals : Locals) :
    bodyExpression.eval imports locals =
      bodyValidCheck (locals .source "text") (locals .parseContext "context") (locals .bodyScan "scan") := rfl

open SourceBridge
structure Checked (tokens : List String) : Prop where
  includedHeader : functionHeader "included" "is" tokens = some
    (expectedTokens "(Value, Bounds : Scalars.Interval) return Boolean")
  includedBody : expressionDeclaration "included" tokens = some (includedExpression.render names, [])
  flowHeader : functionHeader "valid_flow" "is" tokens = some
    (expectedTokens "(Context : Body_Context; Facts : Scalar_Flow) return Boolean")
  flowBody : expressionDeclaration "valid_flow" tokens = some (flowExpression.render names, [])
  bodySpecification : functionHeader "valid_body" ";" tokens = some
    (expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length")
  bodyHeader : functionHeader "valid_body" "is" tokens = some
    (expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean")
  bodyBody : expressionDeclaration "valid_body" tokens = some (bodyExpression.render names, [])

end Silver.ApplicationPackageCalls.ValidityNative
