module

public import Silver.ArrayBindingsRead

@[expose] public section

/-! Typed interpretations of the native array helper expression bodies.
Every recursive/helper call remains arbitrary until its domain-restricted
source equation is used. -/
namespace Silver.ArrayBindings.Native

inductive Ty | number | integer | truth | source | binding | metadata | initials | interval | environment
  | arrow (domain codomain : Ty)
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Source
  | .binding => Binding | .metadata => Metadata | .initials => Initials | .interval => Integer.Interval
  | .environment => Env
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .integer => 0 | .truth => false | .source => [] | .binding => emptyBinding
  | .metadata => [] | .initials => [] | .interval => Integer.Interval.empty
  | .environment => {}
  | .arrow _ b => fun _ => b.default

structure Calls where
  lookupModel : Source → Metadata → Nat → Nat → Nat → Nat
  lookup : Source → Metadata → Nat → Nat → Nat
  hullModel : Initials → Nat → Nat → Integer.Interval
  readBounds : Metadata → Initials → Bool → Nat → Integer.Interval → Integer.Interval
  contains : Binding → Integer.Interval → Bool
  elementSlot : Binding → Int → Nat
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  isEmpty : Integer.Interval → Bool
  singleton : Int → Integer.Interval
  join : Integer.Interval → Integer.Interval → Integer.Interval
  validNameState : Source → Nat → Nat → Bool
  validBinding : Binding → Bool
  validMetadata : Source → Metadata → Bool

inductive Function | lookupModel | hullModel | equalName | isEmpty | singleton | join
  | validNameState | validBinding | validMetadata
  deriving DecidableEq

def Function.name : Function → List String
  | .lookupModel => ["lookup_model"] | .hullModel => ["hull_model"] | .equalName => ["equal_name"]
  | .isEmpty => ["scalars", ".", "is_empty"] | .singleton => ["scalars", ".", "singleton"]
  | .join => ["scalars", ".", "join"]
  | .validNameState => ["valid_name_state"] | .validBinding => ["valid_binding"]
  | .validMetadata => ["valid_metadata"]
def Function.type : Function → Ty
  | .lookupModel => .arrow .source (.arrow .metadata (.arrow .number (.arrow .number (.arrow .number .number))))
  | .hullModel => .arrow .initials (.arrow .number (.arrow .number .interval))
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .isEmpty => .arrow .interval .truth | .singleton => .arrow .integer .interval
  | .join => .arrow .interval (.arrow .interval .interval)
  | .validNameState => .arrow .source (.arrow .number (.arrow .number .truth))
  | .validBinding => .arrow .binding .truth
  | .validMetadata => .arrow .source (.arrow .metadata .truth)
def Calls.get (calls : Calls) : (fn : Function) → fn.type.meaning
  | .lookupModel => calls.lookupModel | .hullModel => calls.hullModel | .equalName => calls.equalName
  | .isEmpty => calls.isEmpty | .singleton => calls.singleton | .join => calls.join
  | .validNameState => calls.validNameState | .validBinding => calls.validBinding
  | .validMetadata => calls.validMetadata

inductive Field : Ty → Ty → Type
  | first : Field .binding .number | after : Field .binding .number
  | offset : Field .binding .number | length : Field .binding .number
  | bounds : Field .binding .interval | count : Field .metadata .number
  | componentBounds : Field .binding .interval
  | environmentNames : Field .environment .metadata | used : Field .environment .number
  | lower : Field .interval .integer | upper : Field .interval .integer

def Field.name : Field a b → String
  | .first => "first" | .after => "after" | .offset => "offset" | .length => "length"
  | .bounds => "bounds" | .count => "count" | .lower => "lower" | .upper => "upper"
  | .componentBounds => "component_bounds"
  | .environmentNames => "names" | .used => "used"
def Field.get : Field a b → a.meaning → b.meaning
  | .first, item => item.first | .after, item => item.after | .offset, item => item.offset
  | .length, item => item.length | .bounds, item => item.bounds | .count, names => names.length
  | .lower, interval => interval.lower | .upper, interval => interval.upper
  | .componentBounds, item => item.componentBounds
  | .environmentNames, environment => environment.names | .used, environment => environment.used

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | binding : Expr .metadata → Expr .number → Expr .binding
  | initial : Expr .initials → Expr .number → Expr .integer
  | wideNat : Expr .number → Expr .integer
  | wideInt : Expr .integer → Expr .integer
  | elementIndex : Expr .integer → Expr .number
  | natSub : Expr .number → Expr .number → Expr .number
  | natAdd : Expr .number → Expr .number → Expr .number
  | intAdd : Expr .integer → Expr .integer → Expr .integer
  | intSub : Expr .integer → Expr .integer → Expr .integer
  | intOne : Expr .integer
  | maxElements : Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | ge : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | intEq : Expr .integer → Expr .integer → Expr .truth
  | intLe : Expr .integer → Expr .integer → Expr .truth
  | intGe : Expr .integer → Expr .integer → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | guarded : Expr .truth → Expr .truth → Expr .truth
  | forAllItems (name : String) : Expr .metadata → Expr .truth → Expr .truth

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.withIndex (locals : Locals) (name : String) (index : Nat) : Locals
  | .number, other => if other = name then index else locals .number other
  | ty, other => locals ty other

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .variable name => locals _ name | .function fn => calls.get fn
  | .app fn arg => fn.eval calls locals (arg.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .binding names index => ArrayBindings.binding (names.eval calls locals) (index.eval calls locals)
  | .initial values index => initialValue (values.eval calls locals) (index.eval calls locals)
  | .wideNat value => Int.ofNat (value.eval calls locals) | .wideInt value => value.eval calls locals
  | .elementIndex value => (value.eval calls locals).toNat
  | .natSub a b => a.eval calls locals - b.eval calls locals
  | .natAdd a b => a.eval calls locals + b.eval calls locals
  | .intAdd a b => a.eval calls locals + b.eval calls locals
  | .intSub a b => a.eval calls locals - b.eval calls locals
  | .intOne => 1 | .maxElements => ArrayBindings.maxElements
  | .eq a b => decide (a.eval calls locals = b.eval calls locals)
  | .le a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .ge a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .gt a b => decide (a.eval calls locals > b.eval calls locals)
  | .intEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .intLe a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .intGe a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .andThen a b => a.eval calls locals && b.eval calls locals
  | .orElse a b => a.eval calls locals || b.eval calls locals
  | .not a => !a.eval calls locals | .group a => a.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .guarded c a => !c.eval calls locals || a.eval calls locals
  | .forAllItems name names body =>
      (List.range (names.eval calls locals).length).all fun index =>
        body.eval calls (locals.withIndex name (index + 1))

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .variable name => [name] | .function fn => fn.name
  | .app fn arg => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ arg.render ++ [")"]
    | _ => fn.render ++ ["("] ++ arg.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .binding names index => names.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .initial values index => values.render ++ ["("] ++ index.render ++ [")"]
  | .wideNat value | .wideInt value => ["scalars", ".", "wide", "("] ++ value.render ++ [")"]
  | .elementIndex value => ["element_index", "("] ++ value.render ++ [")"]
  | .natSub a b | .intSub a b => a.render ++ ["-"] ++ b.render
  | .intAdd a b | .natAdd a b => a.render ++ ["+"] ++ b.render
  | .intOne => ["1"] | .maxElements => ["max_elements"]
  | .eq a b | .intEq a b => a.render ++ ["="] ++ b.render
  | .le a b | .intLe a b => a.render ++ ["<="] ++ b.render
  | .ge a b => a.render ++ [">="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .intGe a b => a.render ++ [">="] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render
  | .not a => ["not"] ++ a.render
  | .group a => ["("] ++ a.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .guarded c a => ["if"] ++ c.render ++ ["then"] ++ a.render
  | .forAllItems name names body => ["for", "all", name, "in", "1", ".."] ++
      names.render ++ [".", "count", "=>"] ++ body.render

def apply2 (fn : Expr (.arrow a (.arrow b c))) (x : Expr a) (y : Expr b) : Expr c := .app (.app fn x) y
def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (x : Expr a) (y : Expr b) (z : Expr c) : Expr d :=
  .app (apply2 fn x y) z
def apply5 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (x : Expr a) (y : Expr b) (z : Expr c) (u : Expr d) (v : Expr e) : Expr f :=
  .app (.app (apply3 fn x y z) u) v

def lookupBody : Expr .number :=
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let text : Expr .source := .variable "text"
  let names : Expr .metadata := .variable "names"
  .ite (.orElse (.orElse (.eq first (.number 0)) (.le after first)) (.eq index (.number 0))) (.number 0)
    (.elsif (apply5 (.function .equalName) text (.field .first (.binding names index))
      (.field .after (.binding names index)) first after) index
      (apply5 (.function .lookupModel) text names first after (.natSub index (.number 1))))

def hullBody : Expr .interval :=
  let values : Expr .initials := .variable "values"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  .ite (.eq first last) (.app (.function .singleton) (.initial values first))
    (apply2 (.function .join)
      (apply3 (.function .hullModel) values first (.natSub last (.number 1)))
      (.app (.function .singleton) (.initial values last)))

def containsBody : Expr .truth :=
  let item : Expr .binding := .variable "item"
  let index : Expr .interval := .variable "index"
  .andThen (.andThen (.not (.app (.function .isEmpty) index))
    (.intGe (.field .lower index) (.field .lower (.field .bounds item))))
    (.intLe (.field .upper index) (.field .upper (.field .bounds item)))

def elementSlotBody : Expr .number :=
  let item : Expr .binding := .variable "item"
  .elementIndex (.intAdd (.group (.intAdd (.wideNat (.field .offset item)) .intOne))
    (.group (.intSub (.wideInt (.variable "index")) (.wideInt (.field .lower (.field .bounds item))))))

def validBindingBody : Expr .truth :=
  let item : Expr .binding := .variable "item"
  .andThen (.andThen (.andThen (.andThen (.not (.app (.function .isEmpty) (.field .bounds item)))
    (.gt (.field .length item) (.number 0)))
    (.le (.field .offset item) (.natSub .maxElements (.field .length item))))
    (.intEq (.intSub (.wideInt (.field .upper (.field .bounds item))) (.wideInt (.field .lower (.field .bounds item))))
      (.intSub (.wideNat (.field .length item)) .intOne)))
    (.not (.app (.function .isEmpty) (.field .componentBounds item)))

def validMetadataBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let names : Expr .metadata := .variable "names"
  let index : Expr .number := .variable "index"
  let item := Expr.binding names index
  let previous := Expr.binding names (.natSub index (.number 1))
  .forAllItems "index" names <|
    .andThen (.andThen (.andThen (.gt (.field .first item) (.number 0))
      (apply3 (.function .validNameState) text (.field .first item) (.field .after item)))
      (.app (.function .validBinding) item))
      (.group <| .guarded (.gt index (.number 1))
        (.ge (.field .offset item) (.natAdd (.field .offset previous) (.field .length previous))))

def validEnvironmentBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let environment : Expr .environment := .variable "names"
  let names := Expr.field .environmentNames environment
  let item := Expr.binding names (.variable "index")
  .andThen (apply2 (.function .validMetadata) text names)
    (.group <| .forAllItems "index" names <|
      .le (.natAdd (.field .offset item) (.field .length item)) (.field .used environment))

structure Context where
  text : Source := []
  names : Metadata := []
  values : Initials := []
  item : Binding := emptyBinding
  indices : Integer.Interval := Integer.Interval.empty
  first : Nat := 0
  after : Nat := 0
  index : Nat := 0
  indexValue : Int := 0
  last : Nat := 0
  environment : Env := {}

def Context.locals (context : Context) : Locals
  | .source, "text" => context.text
  | .metadata, "names" => context.names
  | .initials, "values" => context.values
  | .binding, "item" => context.item
  | .interval, "index" => context.indices
  | .number, "first" => context.first | .number, "after" => context.after
  | .number, "index" => context.index | .number, "last" => context.last
  | .integer, "index" => context.indexValue
  | .environment, "names" => context.environment
  | ty, _ => ty.default

def Expr.scoped (locals : List (String × Ty)) : Expr ty → Bool
  | .variable name => locals.lookup name == some ty
  | .number _ | .function _ | .intOne | .maxElements => true
  | .app fn arg => fn.scoped locals && arg.scoped locals
  | .field _ value | .wideNat value | .wideInt value | .elementIndex value
  | .not value | .group value => value.scoped locals
  | .binding a b | .initial a b | .natSub a b | .natAdd a b | .intSub a b | .intAdd a b
  | .eq a b | .le a b | .ge a b | .gt a b | .intEq a b | .intLe a b | .intGe a b
  | .andThen a b | .orElse a b | .guarded a b => a.scoped locals && b.scoped locals
  | .ite c a b | .elsif c a b => c.scoped locals && a.scoped locals && b.scoped locals
  | .forAllItems name names body => names.scoped locals && body.scoped ((name, .number) :: locals)

/-- Explicit categories keep new constructors out of primary positions until
reviewed. Function arguments admit full expressions; arithmetic and logical
operators retain the association of the rendered source. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .variable _ | .function _ | .app _ _ | .field _ _
  | .binding _ _ | .initial _ _ | .wideNat _ | .wideInt _ | .elementIndex _
  | .intOne | .maxElements | .group _ => true
  | _ => false

def Expr.simple : Expr ty → Bool
  | .natSub _ _ | .natAdd _ _ | .intSub _ _ | .intAdd _ _ | .not _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .le _ _ | .ge _ _ | .gt _ _ | .intEq _ _ | .intLe _ _ | .intGe _ _ => true
  | value => value.simple

def Expr.expression : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ => true
  | value => value.relation

def Expr.andLeft : Expr .truth → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orLeft : Expr .truth → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.isConditional : Expr ty → Bool | .ite _ _ _ | .guarded _ _ => true | _ => false

def Expr.isQuantified : Expr ty → Bool | .forAllItems _ _ _ => true | _ => false

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.functionSpine : Expr ty → Bool
  | .function _ => true
  | .app fn _ => fn.functionSpine
  | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .variable _ | .function _ | .intOne | .maxElements => true
  | .app fn arg => fn.functionSpine && fn.wellFormed && arg.expression && arg.wellFormed
  | .field _ value => value.primary && value.wellFormed
  | .binding names index | .initial names index =>
      names.primary && names.wellFormed && index.expression && index.wellFormed
  | .wideNat value | .wideInt value | .elementIndex value => value.expression && value.wellFormed
  | .natSub a b | .natAdd a b | .intSub a b | .intAdd a b => a.simple && b.primary && a.wellFormed && b.wellFormed
  | .eq a b | .le a b | .ge a b | .gt a b | .intEq a b | .intLe a b | .intGe a b =>
      a.simple && b.simple && a.wellFormed && b.wellFormed
  | .not value => value.primary && value.wellFormed
  | .andThen a b => a.andLeft && b.relation && a.wellFormed && b.wellFormed
  | .orElse a b => a.orLeft && b.relation && a.wellFormed && b.wellFormed
  | .group value => (value.expression || value.isConditional || value.isQuantified) && value.wellFormed
  | .ite c a b | .elsif c a b => c.expression && a.expression && (b.expression || b.isElsif) &&
      c.wellFormed && a.wellFormed && b.wellFormed
  | .guarded c a => c.expression && a.expression && c.wellFormed && a.wellFormed
  | .forAllItems _ names body => names.primary && names.wellFormed && body.expression && body.wellFormed

def WellFormedTrees : Prop :=
  (lookupBody.wellFormed && lookupBody.scoped [("text", .source), ("names", .metadata), ("first", .number),
    ("after", .number), ("index", .number)]) = true ∧
  (hullBody.wellFormed && hullBody.scoped [("values", .initials), ("first", .number), ("last", .number)]) = true ∧
  (containsBody.wellFormed && containsBody.scoped [("item", .binding), ("index", .interval)]) = true ∧
  (elementSlotBody.wellFormed && elementSlotBody.scoped [("item", .binding), ("index", .integer)]) = true ∧
  (validBindingBody.wellFormed && validBindingBody.scoped [("item", .binding)]) = true ∧
  (validMetadataBody.wellFormed && validMetadataBody.scoped [("text", .source), ("names", .metadata)]) = true ∧
  (validEnvironmentBody.wellFormed && validEnvironmentBody.scoped [("text", .source), ("names", .environment)]) = true

instance : Decidable WellFormedTrees := inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

theorem trees_wellFormed : WellFormedTrees := by decide +kernel

namespace PrecedenceChecks

private def rightSub : Expr .integer := .intSub (.wideNat (.number 10))
  (.intSub (.wideNat (.number 3)) .intOne)
private def leftSub : Expr .integer := .intSub
  (.intSub (.wideNat (.number 10)) (.wideNat (.number 3))) .intOne
private def condition : Expr .truth := .eq (.number 0) (.number 0)
private def choice : Expr .integer := .ite condition .intOne (.wideNat (.number 0))

private theorem subtraction_collision (calls : Calls) (locals : Locals) :
    rightSub.render = leftSub.render ∧ rightSub.eval calls locals = 8 ∧ leftSub.eval calls locals = 6 := by
  exact ⟨rfl, rfl, rfl⟩

private theorem arithmetic_categories :
    rightSub.wellFormed = false ∧ leftSub.wellFormed = true ∧
    (Expr.intSub (.wideNat (.number 10)) (.group (.intSub (.wideNat (.number 3)) .intOne))).wellFormed = true ∧
    (Expr.intAdd .intOne (.intAdd .intOne .intOne)).wellFormed = false ∧
    (Expr.intAdd .intOne (.group (.intAdd .intOne .intOne))).wellFormed = true ∧
    (Expr.natSub (.number 3) (.natSub (.number 2) (.number 1))).wellFormed = false ∧
    (Expr.intGe choice .intOne).wellFormed = false ∧
    (Expr.intGe (.group choice) .intOne).wellFormed = true ∧
    (apply3 (.function .hullModel) (.variable "values") (.number 1)
      (.natSub (.number 3) (.number 1))).wellFormed = true := by decide +kernel

private theorem logical_categories :
    (Expr.not condition).wellFormed = false ∧
    (Expr.not (.group condition)).wellFormed = true ∧
    (Expr.andThen (.orElse condition condition) condition).wellFormed = false ∧
    (Expr.andThen (.group (.orElse condition condition)) condition).wellFormed = true ∧
    (Expr.ite condition choice .intOne).wellFormed = false ∧
    (Expr.ite condition (.group choice) .intOne).wellFormed = true ∧
    (Expr.group (.elsif condition .intOne .intOne)).wellFormed = false ∧
    (Expr.ite condition .intOne (.elsif condition .intOne .intOne)).wellFormed = true ∧
    (Expr.variable (ty := .integer) "index").scoped [] = false ∧
    (Expr.variable (ty := .integer) "index").scoped [("index", .integer)] = true := by decide +kernel

end PrecedenceChecks

end Silver.ArrayBindings.Native
