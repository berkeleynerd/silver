module

public import Silver.ScalarFunctionTypes
public import Silver.PredicateSyntax

@[expose] public section

/-! Calls occupy an entire assignment RHS. Their actuals use the existing
expression trees, so a function call cannot occur inside another actual. -/
namespace Silver.ScalarFunctions

inductive Actual
  | integer (expression : Integer.Expr)
  | boolean (condition : Predicate.Condition)
  | array (typeId : Nat) (source : Integer.ArrayDescriptor)
  deriving DecidableEq, Repr

structure Call where
  callee : Nat
  actuals : List Actual
  deriving DecidableEq, Repr

inductive Target
  | integer (identity : Nat) (declared : Integer.Interval)
  | boolean (identity : Nat)
  deriving DecidableEq, Repr

structure Assignment where
  target : Target
  call : Call
  deriving DecidableEq, Repr

def Target.identity : Target → Nat
  | .integer identity _ | .boolean identity => identity

/-- Source resolution and Boolean grammar remain unconditional, including in
unreached branches. Integer inference separately requires each name's range. -/
def Actual.Readable (hasArguments : Bool) (shape : Bindings.Shape)
    (booleans : Boolean.Analysis) : Actual → Prop
  | .integer _ => True
  | .boolean condition => condition.Grammatical ∧ condition.Readable hasArguments shape booleans
  | .array _ _ => True

def Call.Readable (hasArguments : Bool) (shape : Bindings.Shape)
    (booleans : Boolean.Analysis) (call : Call) : Prop :=
  ∀ actual ∈ call.actuals, actual.Readable hasArguments shape booleans

end Silver.ScalarFunctions
