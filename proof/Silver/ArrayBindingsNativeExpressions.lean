module

public import Silver.ArrayBindingsRead

@[expose] public section

/-! Typed interpretations of the native array helper expression bodies.
Every recursive/helper call remains arbitrary until its domain-restricted
source equation is used. -/
namespace Silver.ArrayBindings.Native

inductive Ty | number | integer | truth | source | binding | metadata | initials | interval
  | arrow (domain codomain : Ty)
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Source
  | .binding => Binding | .metadata => Metadata | .initials => Initials | .interval => Integer.Interval
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .integer => 0 | .truth => false | .source => [] | .binding => emptyBinding
  | .metadata => [] | .initials => [] | .interval => Integer.Interval.empty
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

inductive Function | lookupModel | hullModel | equalName | isEmpty | singleton | join
  deriving DecidableEq

def Function.name : Function → List String
  | .lookupModel => ["lookup_model"] | .hullModel => ["hull_model"] | .equalName => ["equal_name"]
  | .isEmpty => ["scalars", ".", "is_empty"] | .singleton => ["scalars", ".", "singleton"]
  | .join => ["scalars", ".", "join"]
def Function.type : Function → Ty
  | .lookupModel => .arrow .source (.arrow .metadata (.arrow .number (.arrow .number (.arrow .number .number))))
  | .hullModel => .arrow .initials (.arrow .number (.arrow .number .interval))
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .isEmpty => .arrow .interval .truth | .singleton => .arrow .integer .interval
  | .join => .arrow .interval (.arrow .interval .interval)
def Calls.get (calls : Calls) : (fn : Function) → fn.type.meaning
  | .lookupModel => calls.lookupModel | .hullModel => calls.hullModel | .equalName => calls.equalName
  | .isEmpty => calls.isEmpty | .singleton => calls.singleton | .join => calls.join

inductive Field : Ty → Ty → Type
  | first : Field .binding .number | after : Field .binding .number
  | offset : Field .binding .number | length : Field .binding .number
  | bounds : Field .binding .interval | count : Field .metadata .number
  | lower : Field .interval .integer | upper : Field .interval .integer

def Field.name : Field a b → String
  | .first => "first" | .after => "after" | .offset => "offset" | .length => "length"
  | .bounds => "bounds" | .count => "count" | .lower => "lower" | .upper => "upper"
def Field.get : Field a b → a.meaning → b.meaning
  | .first, item => item.first | .after, item => item.after | .offset, item => item.offset
  | .length, item => item.length | .bounds, item => item.bounds | .count, names => names.length
  | .lower, interval => interval.lower | .upper, interval => interval.upper

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
  | intAdd : Expr .integer → Expr .integer → Expr .integer
  | intSub : Expr .integer → Expr .integer → Expr .integer
  | intOne : Expr .integer
  | maxElements : Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
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

abbrev Locals := (ty : Ty) → String → ty.meaning

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .variable name => locals _ name | .function fn => calls.get fn
  | .app fn arg => fn.eval calls locals (arg.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .binding names index => ArrayBindings.binding (names.eval calls locals) (index.eval calls locals)
  | .initial values index => initialValue (values.eval calls locals) (index.eval calls locals)
  | .wideNat value => Int.ofNat (value.eval calls locals) | .wideInt value => value.eval calls locals
  | .elementIndex value => (value.eval calls locals).toNat
  | .natSub a b => a.eval calls locals - b.eval calls locals
  | .intAdd a b => a.eval calls locals + b.eval calls locals
  | .intSub a b => a.eval calls locals - b.eval calls locals
  | .intOne => 1 | .maxElements => ArrayBindings.maxElements
  | .eq a b => decide (a.eval calls locals = b.eval calls locals)
  | .le a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .gt a b => decide (a.eval calls locals > b.eval calls locals)
  | .intEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .intLe a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .intGe a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .andThen a b => a.eval calls locals && b.eval calls locals
  | .orElse a b => a.eval calls locals || b.eval calls locals
  | .not a => !a.eval calls locals | .group a => a.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals

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
  | .intAdd a b => a.render ++ ["+"] ++ b.render
  | .intOne => ["1"] | .maxElements => ["max_elements"]
  | .eq a b | .intEq a b => a.render ++ ["="] ++ b.render
  | .le a b | .intLe a b => a.render ++ ["<="] ++ b.render
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
  .andThen (.andThen (.andThen (.not (.app (.function .isEmpty) (.field .bounds item)))
    (.gt (.field .length item) (.number 0)))
    (.le (.field .offset item) (.natSub .maxElements (.field .length item))))
    (.intEq (.intSub (.wideInt (.field .upper (.field .bounds item))) (.wideInt (.field .lower (.field .bounds item))))
      (.intSub (.wideNat (.field .length item)) .intOne))

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

def Context.locals (context : Context) : Locals
  | .source, "text" => context.text
  | .metadata, "names" => context.names
  | .initials, "values" => context.values
  | .binding, "item" => context.item
  | .interval, "index" => context.indices
  | .number, "first" => context.first | .number, "after" => context.after
  | .number, "index" => context.index | .number, "last" => context.last
  | .integer, "index" => context.indexValue
  | ty, _ => ty.default

def Expr.wellFormed (locals : List (String × Ty)) : Expr ty → Bool
  | .variable name => locals.lookup name == some ty
  | .number _ | .function _ | .intOne | .maxElements => true
  | .app fn arg => fn.wellFormed locals && arg.wellFormed locals
  | .field _ value | .wideNat value | .wideInt value | .elementIndex value
  | .not value | .group value => value.wellFormed locals
  | .binding a b | .initial a b | .natSub a b | .intSub a b | .intAdd a b
  | .eq a b | .le a b | .gt a b | .intEq a b | .intLe a b | .intGe a b
  | .andThen a b | .orElse a b => a.wellFormed locals && b.wellFormed locals
  | .ite c a b | .elsif c a b => c.wellFormed locals && a.wellFormed locals && b.wellFormed locals

def WellFormedTrees : Prop :=
  lookupBody.wellFormed [("text", .source), ("names", .metadata), ("first", .number),
    ("after", .number), ("index", .number)] = true ∧
  hullBody.wellFormed [("values", .initials), ("first", .number), ("last", .number)] = true ∧
  containsBody.wellFormed [("item", .binding), ("index", .interval)] = true ∧
  elementSlotBody.wellFormed [("item", .binding), ("index", .integer)] = true ∧
  validBindingBody.wellFormed [("item", .binding)] = true

instance : Decidable WellFormedTrees := inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _))

theorem trees_wellFormed : WellFormedTrees := by decide +kernel

end Silver.ArrayBindings.Native
