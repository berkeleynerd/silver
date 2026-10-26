module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateBodyFlow
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.BodyWrappers

/-- An independent typed interpretation of the complete invalid-body model,
including both native discriminants and the preserved scalar values. -/
inductive Ty | number | truth | path | values | flow | scan

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .path => PathFacts.Context
  | .values => List Integer.Interval | .flow => ActiveFlow | .scan => BodyScan

structure Calls where
  invalidModel : BodyScan → BodyScan
  invalid : BodyScan → BodyScan

inductive Expr : Ty → Type
  | input : Expr .scan
  | count : Expr .scan → Expr .number
  | values : Expr .scan → Expr .values
  | zero : Expr .number
  | falseValue : Expr .truth
  | emptyPath : Expr .path
  | flow : Expr .number → Expr .path → Expr .values → Expr .flow
  | body : Expr .number → Expr .flow → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .scan
  | invalidModel : Expr .scan → Expr .scan

def Expr.eval (calls : Calls) (scan : BodyScan) : Expr ty → ty.meaning
  | .input => scan
  | .count scanExpr => (scanExpr.eval calls scan).count
  | .values scanExpr => (scanExpr.eval calls scan).facts.values
  | .zero => 0 | .falseValue => false | .emptyPath => PathFacts.Context.empty
  | .flow _ pathExpr valuesExpr => ⟨pathExpr.eval calls scan, valuesExpr.eval calls scan⟩
  | .body _ flowExpr positionExpr targetExpr capacityExpr assignedExpr outputExpr =>
      ⟨positionExpr.eval calls scan, targetExpr.eval calls scan, capacityExpr.eval calls scan,
        flowExpr.eval calls scan, assignedExpr.eval calls scan, outputExpr.eval calls scan⟩
  | .invalidModel scanExpr => calls.invalidModel (scanExpr.eval calls scan)

def Expr.render : Expr ty → List String
  | .input => ["scan"]
  | .count scanExpr => scanExpr.render ++ [".", "count"]
  | .values scanExpr => scanExpr.render ++ [".", "facts", ".", "values"]
  | .zero => ["0"] | .falseValue => ["false"] | .emptyPath => ["paths", ".", "empty_context"]
  | .flow countExpr pathExpr valuesExpr =>
      ["(", "count", "=>"] ++ countExpr.render ++ [",", "path", "=>"] ++ pathExpr.render ++
        [",", "values", "=>"] ++ valuesExpr.render ++ [")"]
  | .body countExpr flowExpr positionExpr targetExpr capacityExpr assignedExpr outputExpr =>
      ["(", "count", "=>"] ++ countExpr.render ++ [",", "facts", "=>"] ++ flowExpr.render ++
        [",", "position", "=>"] ++ positionExpr.render ++ [",", "target", "=>"] ++ targetExpr.render ++
        [",", "capacity", "=>"] ++ capacityExpr.render ++ [",", "assigned", "=>"] ++ assignedExpr.render ++
        [",", "output", "=>"] ++ outputExpr.render ++ [")"]
  | .invalidModel scanExpr => ["invalid_body_model", "("] ++ scanExpr.render ++ [")"]

def Expr.Sized (calls : Calls) (scan : BodyScan) : Expr ty → Prop
  | .input | .zero | .falseValue | .emptyPath => True
  | .count scanExpr | .values scanExpr | .invalidModel scanExpr => scanExpr.Sized calls scan
  | .flow countExpr pathExpr valuesExpr =>
      countExpr.Sized calls scan ∧ pathExpr.Sized calls scan ∧ valuesExpr.Sized calls scan ∧
        countExpr.eval calls scan ≤ ScalarExpression.maxBindings ∧
        (valuesExpr.eval calls scan).length = countExpr.eval calls scan
  | .body countExpr flowExpr positionExpr targetExpr capacityExpr assignedExpr outputExpr =>
      countExpr.Sized calls scan ∧ flowExpr.Sized calls scan ∧ positionExpr.Sized calls scan ∧
        targetExpr.Sized calls scan ∧ capacityExpr.Sized calls scan ∧ assignedExpr.Sized calls scan ∧
        outputExpr.Sized calls scan ∧ (flowExpr.eval calls scan).count = countExpr.eval calls scan

def invalidBodyExpr : Expr .scan :=
  .body (.count .input) (.flow (.count .input) .emptyPath (.values .input))
    .zero .zero .zero .falseValue .falseValue

def invalidRhs : Expr .scan := .invalidModel .input

theorem invalidBody_denotation (calls : Calls) (scan : BodyScan) :
    invalidBodyExpr.eval calls scan = invalidBody scan := rfl

theorem invalidBody_sized (calls : Calls) (scan : BodyScan) (capacity : scan.count ≤ ScalarExpression.maxBindings) :
    invalidBodyExpr.Sized calls scan := by
  simpa [invalidBodyExpr, Expr.Sized, Expr.eval, BodyScan.count, ActiveFlow.count] using capacity

structure DefinitionEquations (calls : Calls) : Prop where
  sized : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → invalidBodyExpr.Sized calls scan
  invalidModel : ∀ scan, scan.count ≤ ScalarExpression.maxBindings →
    calls.invalidModel scan = invalidBodyExpr.eval calls scan
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → calls.invalid scan = invalidRhs.eval calls scan

theorem invalidModel_meaning {calls} (definitions : DefinitionEquations calls)
    (scan : BodyScan) (capacity : scan.count ≤ ScalarExpression.maxBindings) :
    calls.invalidModel scan = invalidBody scan :=
  (definitions.invalidModel scan capacity).trans (invalidBody_denotation calls scan)

theorem invalid_meaning {calls} (definitions : DefinitionEquations calls)
    (scan : BodyScan) (capacity : scan.count ≤ ScalarExpression.maxBindings) :
    calls.invalid scan = invalidBody scan :=
  (definitions.invalid scan capacity).trans (invalidModel_meaning definitions scan capacity)

def modelCalls : Calls := ⟨invalidBody, invalidBody⟩

theorem model_definitions : DefinitionEquations modelCalls :=
  ⟨invalidBody_sized modelCalls, fun _ _ => rfl, fun _ _ => rfl⟩

def expectedTokens (text : String) : List String := (Source.lexLine text).getD []
def invalidHeader : List String := expectedTokens "(Scan : Body_Scan) return Body_Scan"
def invalidSpec : List String := invalidHeader ++ expectedTokens
  "with Global => null, Post => (Static => Invalid_Body'Result =" ++ invalidRhs.render ++ [")"]

structure Checked (tokens : List String) : Prop where
  invalidModelHeader : Silver.SourceBridge.functionHeader "invalid_body_model" "is" tokens = some invalidHeader
  invalidModelBody : Silver.SourceBridge.expressionDeclaration "invalid_body_model" tokens =
    some ((invalidBodyExpr.render.drop 1).dropLast, expectedTokens "with Ghost => Static")
  invalidSpec : Silver.SourceBridge.functionHeader "invalid_body" ";" tokens = some invalidSpec
  invalidBody : Silver.SourceBridge.functionHeader "invalid_body" "is" tokens = some invalidHeader

end Silver.Predicate.BodyWrappers
