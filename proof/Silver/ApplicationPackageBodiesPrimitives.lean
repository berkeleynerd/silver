module

public import Silver.ApplicationPackageBodiesStatementValues
public import Silver.ApplicationPackageProcedureControl

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statements
open ApplicationNative ApplicationPackages

structure Procedures where
  readCondition : Source → Predicate.ParseContext → Nat → Predicate.ActiveFlow → Predicate.ConditionResult
  joinInto : Predicate.ActiveFlow → Predicate.ActiveFlow → Predicate.ActiveFlow
  widenInto : Predicate.ParseContext → Predicate.ActiveFlow → Predicate.ActiveFlow

inductive Primitive (Fn : Ty → Type)
  | readCondition : Expr Fn .source → Expr Fn .parseContext → Expr Fn .number → Expr Fn .activeFlow →
      Place Fn .conditionResult → Primitive Fn
  | joinInto : Place Fn .activeFlow → Expr Fn .activeFlow → Primitive Fn
  | joinedLemma : Expr Fn .parseContext → Expr Fn .activeFlow → Expr Fn .activeFlow → Primitive Fn
  | widenInto : Expr Fn .parseContext → Place Fn .activeFlow → Primitive Fn
  | appendScalar : Place Fn .scalars → Expr Fn .scalarBinding → Primitive Fn
  | clearValues : Place Fn .activeFlow → Primitive Fn

variable {Fn : Ty → Type}

def Primitive.eval (calls : Calls Fn) (procedures : Procedures) (locals : Locals) : Primitive Fn → Locals
  | .readCondition text context start facts target =>
    target.set calls locals (procedures.readCondition (text.eval calls locals) (context.eval calls locals)
      (start.eval calls locals) (facts.eval calls locals))
  | .joinInto target other =>
    target.set calls locals (procedures.joinInto (target.expression.eval calls locals) (other.eval calls locals))
  | .joinedLemma _ _ _ => locals
  | .widenInto context target =>
    target.set calls locals (procedures.widenInto (context.eval calls locals) (target.expression.eval calls locals))
  | .appendScalar names value =>
    names.set calls locals ((names.expression.eval calls locals) ++ [value.eval calls locals])
  | .clearValues target =>
    let flow := target.expression.eval calls locals
    target.set calls locals {flow with values := List.replicate flow.count .empty}

def invocation (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ List.intercalate [","] arguments ++ [")", ";"]

def Primitive.render (names : FunctionNames Fn) : Primitive Fn → List String
  | .readCondition text context start facts target =>
    invocation "read_condition_into" [text.render names, context.render names, start.render names,
      facts.render names, target.expression.render names]
  | .joinInto target other => invocation "join_into" [target.expression.render names, other.render names]
  | .joinedLemma context left right => invocation "lemma_joined_flow" [context.render names, left.render names, right.render names]
  | .widenInto context target => invocation "widen_into" [context.render names, target.expression.render names]
  | .appendScalar target value =>
    let count : Expr Fn .number := .field .scalarCount target.expression
    let slot : Expr Fn .scalarBinding := .index .scalar target.expression count
    count.render names ++ [":="] ++ (Expr.add count (.number 1)).render names ++ [";"] ++
      slot.render names ++ [":="] ++ value.render names ++ [";"]
  | .clearValues target =>
    target.expression.render names ++ [".", "values", ":=", "(", "others", "=>", "scalars", ".", "empty", ")", ";"]

def Primitive.expressions (checks : {ty : Ty} → Expr Fn ty → Bool) : Primitive Fn → Bool
  | .readCondition text context start facts target =>
    checks text && checks context && checks start && checks facts && checks target.expression
  | .joinInto target other => checks target.expression && checks other
  | .joinedLemma context left right => checks context && checks left && checks right
  | .widenInto context target => checks context && checks target.expression
  | .appendScalar target value => checks target.expression && checks value
  | .clearValues target => checks target.expression

def Primitive.written : Primitive Fn → Option String
  | .readCondition _ _ _ _ target | .joinInto target _ | .widenInto _ target | .appendScalar target _ | .clearValues target =>
    some target.root
  | .joinedLemma _ _ _ => none

def Primitive.scoped (scope : Scope) (writable : List String) (primitive : Primitive Fn) : Bool :=
  primitive.expressions (fun value => value.scoped scope) && primitive.written.all (fun name => name ∈ writable) &&
    match primitive with
    | .appendScalar target value => value.scoped (scope.filter (fun binding => binding.2 != target.root))
    | _ => true

end Silver.ApplicationPackageBodies.Statements
