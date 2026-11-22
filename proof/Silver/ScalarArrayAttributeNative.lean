module

public import Silver.ScalarExpressionNativeExpressions

@[expose] public section

/-! A typed executable translation of `Read_Array_Attribute`. Assignments and
early returns have continuation semantics; rendering retains every declaration
and the named function terminator. Primitive source calls remain arbitrary. -/
namespace Silver.ScalarExpression.Native

namespace Imperative

abbrev Scope := List (String × Ty)

def Scope.lookup (scope : Scope) (name : String) : Option Ty :=
  match scope with
  | [] => none
  | (key, ty) :: rest => if key == name then some ty else rest.lookup name

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  scope.lookup name == some ty

def validTypeName : Ty → List String → Bool
  | .number, name => decide (name ∈ [["literal_position"], ["binding_count"],
      ["array_bindings", ".", "binding_count"], ["array_bindings", ".", "type_count"]])
  | .interval, name => name == ["scalars", ".", "interval"]
  | .check, name => name == ["scalars", ".", "check_result"]
  | .literal, name => name == ["silver_scalar_literals", ".", "literal_result"]
  | .result, name => name == ["expression_result"]
  | .reference, name => name == ["name_reference"]
  | _, _ => false

end Imperative

def Expr.scoped (scope : Imperative.Scope) : Expr ty → Bool
  | .variable (ty := ty) name => scope.contains name ty
  | .app fn argument => fn.scoped scope && argument.scoped scope
  | .arrayArguments fn arrays initials elaborating mode => fn.scoped scope &&
      arrays.scoped scope && initials.scoped scope && elaborating.scoped scope && mode.scoped scope
  | .indexArguments fn arrays mode => fn.scoped scope && arrays.scoped scope && mode.scoped scope
  | .modeEq a b | .intSub a b | .intAdd a b | .add a b | .sub a b | .eq a b | .ne a b
  | .lt a b | .le a b | .gt a b | .andThen a b | .orElse a b => a.scoped scope && b.scoped scope
  | .wide value | .scalarValue value | .field _ value | .neg value | .last value
  | .operators value | .not value | .group value | .locals value => value.scoped scope
  | .binding names index | .arrayBinding names index | .arrayType names index | .byteAt names index =>
      names.scoped scope && index.scoped scope
  | .choices a b c | .ite a b c | .elsif a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .local (a := ty) name typeName value rest => Imperative.validTypeName ty typeName &&
      value.scoped scope && rest.scoped ((name, ty) :: scope)
  | .result after bounds operands static =>
      after.scoped scope && bounds.scoped scope && operands.scoped scope && static.scoped scope
  | .reference first after qualifierFirst qualifierAfter =>
      first.scoped scope && after.scoped scope && qualifierFirst.scoped scope && qualifierAfter.scoped scope
  | .check safe bounds => safe.scoped scope && bounds.scoped scope
  | .deltaAfter value after => value.scoped scope && after.scoped scope
  | .deltaBounds value bounds => value.scoped scope && bounds.scoped scope
  | .operatorCase operator adding subtracting multiplying dividing modulo remainder otherwise =>
      operator.scoped scope && adding.scoped scope && subtracting.scoped scope &&
      multiplying.scoped scope && dividing.scoped scope && modulo.scoped scope &&
      remainder.scoped scope && otherwise.scoped scope
  | .readMode _ | .intOne | .number _ | .word _ | .character _ | .characterVal _ | .truth _
  | .function _ | .maxOperands | .invalid | .invalidCheck | .invalidReference => true

namespace Imperative

structure Declaration where
  type : Ty
  name : String
  typeName : List String
  initial : Option (Expr type)
  constant : Bool

def Declaration.render (declaration : Declaration) : List String :=
  [declaration.name, ":"] ++ (if declaration.constant then ["constant"] else []) ++
    declaration.typeName ++
    (match declaration.initial with | some value => [":="] ++ value.render | none => []) ++ [";"]

def Declaration.eval (calls : Calls) (locals : Locals) (declaration : Declaration) : Locals :=
  locals.set declaration.type declaration.name
    (match declaration.initial with | some value => value.eval calls locals | none => declaration.type.default)

def Declaration.wellFormed (declaration : Declaration) : Bool :=
  validTypeName declaration.type declaration.typeName &&
    (match declaration.initial with
    | some value => value.wellFormed && value.condition
    | none => !declaration.constant)

def Declaration.scoped (scope : Scope) (declaration : Declaration) : Bool :=
  match declaration.initial with | some value => value.scoped scope | none => true

inductive Command (resultType : Ty)
  | nothing
  | assign (name : String) : Expr type → Command resultType
  | sequence : Command resultType → Command resultType → Command resultType
  | choose : Expr .truth → Command resultType → Command resultType → Command resultType
  | returned : Expr resultType → Command resultType

def Command.eval (calls : Calls) (locals : Locals) (next : Locals → resultType.meaning) :
    Command resultType → resultType.meaning
  | .nothing => next locals
  | .assign name value => next (locals.set _ name (value.eval calls locals))
  | .sequence first rest => first.eval calls locals (fun updated => rest.eval calls updated next)
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next else no.eval calls locals next
  | .returned value => value.eval calls locals

mutual
  def Command.render : Command resultType → List String
    | .nothing => []
    | .assign name value => [name, ":="] ++ value.render ++ [";"]
    | .sequence first rest => first.render ++ rest.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .returned value => ["return"] ++ value.render ++ [";"]

  def Command.renderElse : Command resultType → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List (Command resultType)) : Command resultType := commands.foldr .sequence .nothing

def Command.wellFormed : Command resultType → Bool
  | .nothing => true
  | .assign _ value | .returned value => value.wellFormed && value.condition
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.wellFormed && test.condition && yes.wellFormed && no.wellFormed

def Command.scoped (scope writable : Scope) : Command resultType → Bool
  | .nothing => true
  | .assign (type := type) name value => scope.contains name type && writable.contains name type && value.scoped scope
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .returned value => value.scoped scope

structure Body (resultType : Ty) where
  name : String
  declarations : List Declaration
  commands : Command resultType

def Body.render (body : Body resultType) : List String :=
  body.declarations.flatMap Declaration.render ++ ["begin"] ++ body.commands.render ++ ["end", body.name, ";"]

def Body.eval (body : Body resultType) (calls : Calls) (locals : Locals) : resultType.meaning :=
  body.commands.eval calls (body.declarations.foldl (Declaration.eval calls) locals) (fun _ => resultType.default)

def Body.wellFormed (body : Body resultType) : Bool :=
  body.declarations.all Declaration.wellFormed && body.commands.wellFormed

def Body.scoped (scope : Scope) (body : Body resultType) : Bool :=
  let scanned := body.declarations.foldl (fun (state : Bool × Scope) declaration =>
    (state.1 && declaration.scoped state.2 && (state.2.lookup declaration.name).isNone,
      (declaration.name, declaration.type) :: state.2)) (true, scope)
  let writable := body.declarations.filterMap (fun declaration =>
    if declaration.constant then none else some (declaration.name, declaration.type))
  scanned.1 && body.commands.scoped scanned.2 writable

def constant (ty : Ty) (name : String) (typeName : List String) (value : Expr ty) : Declaration :=
  ⟨ty, name, typeName, some value, true⟩

def uninitialized (ty : Ty) (name : String) (typeName : List String) : Declaration :=
  ⟨ty, name, typeName, none, false⟩

def guard (test : Expr .truth) : Command .result := .choose test (.returned .invalid) .nothing

end Imperative

open Imperative in
def arrayAttributeBody : Body .result :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let attributeFirst : Expr .number := .variable "attribute_first"
  let attributeAfter : Expr .number := .variable "attribute_after"
  let target : Expr .number := .variable "target"
  let typeId : Expr .number := .variable "type_id"
  let arrays : Expr .arrays := .variable "arrays"
  let bounds : Expr .interval := .variable "bounds"
  let item := Expr.arrayBinding arrays target
  let named (word : String) := apply4 (.function .nameIs) text attributeFirst attributeAfter (.word word)
  ⟨"read_array_attribute", [
    constant .number "first" ["literal_position"] (apply2 (.function .skip) text (.variable "position")),
    constant .number "after" ["literal_position"] (apply2 (.function .nameAfter) text first),
    constant .number "attribute_first" ["literal_position"]
      (apply2 (.function .skip) text (apply3 (.function .symbol) text after (.characterVal 39))),
    constant .number "attribute_after" ["literal_position"] (apply2 (.function .nameAfter) text attributeFirst),
    constant .number "target" ["array_bindings", ".", "binding_count"]
      (apply4 (.function .arrayLookup) text arrays first after),
    constant .number "type_id" ["array_bindings", ".", "type_count"]
      (apply4 (.function .arrayTypeLookup) text (.field .arrayTypes arrays) first after),
    uninitialized .interval "bounds" ["scalars", ".", "interval"]],
    .list [
      guard (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq first (.number 0)) (.le after first)) (.eq attributeFirst (.number 0)))
        (.le attributeAfter attributeFirst))
        (.ne (apply4 (.function .lookupDefault) text (.variable "names") first after) (.number 0)))
        (.group <| .andThen (.ne (.variable "mask_first") (.number 0))
          (apply5 (.function .equalName) text (.variable "mask_first") (.variable "mask_after") first after))),
      .choose (.ne target (.number 0))
        (.list [guard (.field .arrayBooleanElements item), .assign "bounds" (.field .arrayBounds item)])
        (.choose (.ne typeId (.number 0))
          (.assign "bounds" (.field .typeBounds (.arrayType (.field .arrayTypes arrays) typeId)))
          (.returned .invalid)),
      .choose (.variable "range_query")
        (guard (.not (named "range")))
        (.choose (named "first")
          (.assign "bounds" (.app (.function .scalarSingleton) (.field .lower bounds)))
          (.choose (named "last")
            (.assign "bounds" (.app (.function .scalarSingleton) (.field .upper bounds)))
            (.choose (named "length")
              (.assign "bounds" (.app (.function .scalarSingleton)
                (.scalarValue (.intAdd (.group (.intSub (.wide (.field .upper bounds))
                  (.wide (.field .lower bounds)))) .intOne))))
              (.returned .invalid)))),
      .returned (.result attributeAfter bounds (.number 1) (.truth true))]⟩

def arrayAttributeScope : Imperative.Scope :=
  [("text", .source), ("position", .number), ("names", .environment), ("arrays", .arrays),
   ("mask_first", .number), ("mask_after", .number), ("range_query", .truth)]

theorem arrayAttribute_wellFormed : arrayAttributeBody.wellFormed = true := by decide +kernel
theorem arrayAttribute_scoped : arrayAttributeBody.scoped arrayAttributeScope = true := by decide +kernel

def arrayAttributeResultEquation (calls : Calls) (text : Source) (first after : Nat)
    (bounds : Integer.Interval) (rangeQuery : Bool) : Result :=
  if rangeQuery then
    if calls.nameIs text first after ("range".toList.map Char.toNat) then ⟨after, bounds, 1, true⟩ else invalid
  else if calls.nameIs text first after ("first".toList.map Char.toNat) then
    ⟨after, calls.arrays.singleton bounds.lower, 1, true⟩
  else if calls.nameIs text first after ("last".toList.map Char.toNat) then
    ⟨after, calls.arrays.singleton bounds.upper, 1, true⟩
  else if calls.nameIs text first after ("length".toList.map Char.toNat) then
    ⟨after, calls.arrays.singleton (bounds.upper - bounds.lower + 1), 1, true⟩
  else invalid

def arrayAttributeEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (rangeQuery : Bool) : Result :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  let attributeFirst := calls.skip text (calls.symbol text after 39)
  let attributeAfter := calls.nameAfter text attributeFirst
  let target := calls.arrays.lookup text arrays first after
  let typeId := calls.arrays.lookupType text arrays.types first after
  if first = 0 ∨ after ≤ first ∨ attributeFirst = 0 ∨ attributeAfter ≤ attributeFirst ∨
      calls.lookup text names first after ≠ 0 ∨
      (maskFirst ≠ 0 ∧ calls.equalName text maskFirst maskAfter first after = true) then invalid
  else if target ≠ 0 then
    if (ArrayBindings.binding arrays.items target).isBoolean then invalid
    else arrayAttributeResultEquation calls text attributeFirst attributeAfter
      (ArrayBindings.binding arrays.items target).bounds rangeQuery
  else if typeId ≠ 0 then
    arrayAttributeResultEquation calls text attributeFirst attributeAfter
      (ArrayBindings.arrayType arrays.types typeId).bounds rangeQuery
  else invalid

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem bool_false_guard (test : Bool) (yes no : α) :
    (if test = false then no else yes) = (if test then yes else no) := by
  cases test <;> rfl

theorem arrayAttribute_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (rangeQuery : Bool) :
    arrayAttributeBody.eval calls ({text, position, names, arrays, maskFirst, maskAfter, rangeQuery} : Context).locals =
      arrayAttributeEquation calls text position names arrays maskFirst maskAfter rangeQuery := by
  dsimp +instances only [arrayAttributeBody, Imperative.Body.eval, Imperative.Command.list,
    Imperative.constant, Imperative.uninitialized, Imperative.guard, List.foldl, List.foldr,
    Imperative.Declaration.eval, Imperative.Command.eval, Expr.eval, Context.locals, Calls.get,
    Field.get, apply5, apply4, apply3, apply2, Locals.set]
  simp [arrayAttributeEquation, arrayAttributeResultEquation, Bool.or_eq_true, Bool.and_eq_true,
    or_assoc, bool_false_guard]

end Silver.ScalarExpression.Native
