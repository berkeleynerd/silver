module

public import Silver.FunctionBindings

@[expose] public section

/-! Typed interpretations of every metadata expression body. Recursive calls
remain arbitrary until their exact-domain equations are supplied. Explicit
precedence classes reject ambiguous ungrouped renderings. -/
namespace Silver.FunctionBindings.Native

inductive Ty | number | truth | source | interval | formal | signature | metadata
  | arrow (domain codomain : Ty)
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .source => Source | .interval => Integer.Interval
  | .formal => Formal | .signature => Signature | .metadata => Metadata
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .source => [] | .interval => .empty
  | .formal => emptyFormal | .signature => emptySignature | .metadata => {}
  | .arrow _ b => fun _ => b.default

structure Calls where
  lookupModel : Source → Metadata → Nat → Nat → Nat → Nat
  lookup : Source → Metadata → Nat → Nat → Nat
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  validNameState : Source → Nat → Nat → Bool
  isEmpty : Integer.Interval → Bool
  validMetadata : Source → Metadata → Bool
  appendFormal : Metadata → Formal → Metadata
  append : Metadata → Signature → Metadata

inductive Function | lookupModel | equalName | validNameState | isEmpty
  deriving DecidableEq

def Function.name : Function → List String
  | .lookupModel => ["lookup_model"] | .equalName => ["equal_name"]
  | .validNameState => ["valid_name_state"] | .isEmpty => ["silver_scalars", ".", "is_empty"]
def Function.type : Function → Ty
  | .lookupModel => .arrow .source (.arrow .metadata (.arrow .number (.arrow .number (.arrow .number .number))))
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .validNameState => .arrow .source (.arrow .number (.arrow .number .truth))
  | .isEmpty => .arrow .interval .truth

def Calls.get (calls : Calls) : (fn : Function) → fn.type.meaning
  | .lookupModel => calls.lookupModel | .equalName => calls.equalName
  | .validNameState => calls.validNameState | .isEmpty => calls.isEmpty

inductive Field : Ty → Ty → Type
  | first : Field .signature .number | after : Field .signature .number
  | formalFirst : Field .signature .number | formalCount : Field .signature .number
  | resultBounds : Field .signature .interval
  | parameterFirst : Field .formal .number | parameterAfter : Field .formal .number
  | parameterBounds : Field .formal .interval
  | count : Field .metadata .number | parameterCount : Field .metadata .number

def Field.name : Field a b → String
  | .first | .parameterFirst => "first" | .after | .parameterAfter => "after"
  | .formalFirst => "formal_first" | .formalCount | .count => "count"
  | .resultBounds => "result_bounds" | .parameterBounds => "bounds" | .parameterCount => "parameter_count"
def Field.get : Field a b → a.meaning → b.meaning
  | .first, value => value.first | .after, value => value.after
  | .formalFirst, value => value.formalFirst | .formalCount, value => value.count
  | .resultBounds, value => value.resultBounds
  | .parameterFirst, value => value.first | .parameterAfter, value => value.after
  | .parameterBounds, value => value.bounds
  | .count, value => value.items.length | .parameterCount, value => value.parameters.length

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | signature : Expr .metadata → Expr .number → Expr .signature
  | parameter : Expr .metadata → Expr .number → Expr .formal
  | natSub : Expr .number → Expr .number → Expr .number
  | natAdd : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | forAllSignatures (name : String) : Expr .metadata → Expr .truth → Expr .truth
  | forAllParameters (name : String) : Expr .metadata → Expr .truth → Expr .truth
  | extendFormal : Expr .metadata → Expr .formal → Expr .metadata
  | extendSignature : Expr .metadata → Expr .signature → Expr .metadata

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.withIndex (locals : Locals) (name : String) (index : Nat) : Locals
  | .number, other => if other = name then index else locals .number other
  | ty, other => locals ty other

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .variable name => locals _ name | .function fn => calls.get fn
  | .app fn arg => fn.eval calls locals (arg.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .signature functions index => FunctionBindings.signature (functions.eval calls locals) (index.eval calls locals)
  | .parameter functions index => FunctionBindings.parameter (functions.eval calls locals) (index.eval calls locals)
  | .natSub a b => a.eval calls locals - b.eval calls locals
  | .natAdd a b => a.eval calls locals + b.eval calls locals
  | .eq a b => decide (a.eval calls locals = b.eval calls locals)
  | .le a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .gt a b => decide (a.eval calls locals > b.eval calls locals)
  | .andThen a b => a.eval calls locals && b.eval calls locals
  | .orElse a b => a.eval calls locals || b.eval calls locals
  | .not a => !a.eval calls locals | .group a => a.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .forAllSignatures name functions body =>
      (List.range (functions.eval calls locals).items.length).all fun index =>
        body.eval calls (locals.withIndex name (index + 1))
  | .forAllParameters name functions body =>
      (List.range (functions.eval calls locals).parameters.length).all fun index =>
        body.eval calls (locals.withIndex name (index + 1))
  | .extendFormal functions item => FunctionBindings.appendFormal (functions.eval calls locals) (item.eval calls locals)
  | .extendSignature functions item => FunctionBindings.append (functions.eval calls locals) (item.eval calls locals)

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .variable name => [name] | .function fn => fn.name
  | .app fn arg => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ arg.render ++ [")"]
    | _ => fn.render ++ ["("] ++ arg.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .signature functions index => functions.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .parameter functions index => functions.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .natSub a b => a.render ++ ["-"] ++ b.render | .natAdd a b => a.render ++ ["+"] ++ b.render
  | .eq a b => a.render ++ ["="] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .forAllSignatures name functions body => ["for", "all", name, "in", "1", ".."] ++
      functions.render ++ [".", "count", "=>"] ++ body.render
  | .forAllParameters name functions body => ["for", "all", name, "in", "1", ".."] ++
      functions.render ++ [".", "parameter_count", "=>"] ++ body.render
  | .extendFormal functions item => functions.render ++ ["with", "delta", "parameter_count", "=>"] ++
      functions.render ++ [".", "parameter_count", "+", "1", ",", "parameters", "=>", "("] ++
      functions.render ++ [".", "parameters", "with", "delta"] ++ functions.render ++
      [".", "parameter_count", "+", "1", "=>"] ++ item.render ++ [")"]
  | .extendSignature functions item => functions.render ++ ["with", "delta", "count", "=>"] ++
      functions.render ++ [".", "count", "+", "1", ",", "items", "=>", "("] ++
      functions.render ++ [".", "items", "with", "delta"] ++ functions.render ++
      [".", "count", "+", "1", "=>"] ++ item.render ++ [")"]

def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (x : Expr a) (y : Expr b) (z : Expr c) : Expr d :=
  .app (.app (.app fn x) y) z
def apply5 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (x : Expr a) (y : Expr b) (z : Expr c) (u : Expr d) (v : Expr e) : Expr f :=
  .app (.app (apply3 fn x y z) u) v

def lookupBody : Expr .number :=
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let text : Expr .source := .variable "text"
  let functions : Expr .metadata := .variable "functions"
  .ite (.orElse (.orElse (.eq first (.number 0)) (.le after first)) (.eq index (.number 0))) (.number 0)
    (.elsif (apply5 (.function .equalName) text (.field .first (.signature functions index))
      (.field .after (.signature functions index)) first after) index
      (apply5 (.function .lookupModel) text functions first after (.natSub index (.number 1))))

def validMetadataBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let functions : Expr .metadata := .variable "functions"
  let index : Expr .number := .variable "i"
  let parameter := Expr.parameter functions index
  let item := Expr.signature functions index
  .andThen (.group <| .forAllParameters "i" functions <|
    .andThen (.andThen (.gt (.field .parameterFirst parameter) (.number 0))
      (apply3 (.function .validNameState) text (.field .parameterFirst parameter) (.field .parameterAfter parameter)))
      (.not (.app (.function .isEmpty) (.field .parameterBounds parameter))))
    (.group <| .forAllSignatures "i" functions <|
      .andThen (.andThen (.andThen (.andThen (.andThen (.andThen
        (.gt (.field .first item) (.number 0))
        (apply3 (.function .validNameState) text (.field .first item) (.field .after item)))
        (.gt (.field .formalCount item) (.number 0)))
        (.gt (.field .formalFirst item) (.number 0)))
        (.le (.field .formalFirst item) (.field .parameterCount functions)))
        (.le (.field .formalCount item)
          (.natAdd (.natSub (.field .parameterCount functions) (.field .formalFirst item)) (.number 1))))
        (.not (.app (.function .isEmpty) (.field .resultBounds item))))

def appendFormalBody : Expr .metadata := .extendFormal (.variable "functions") (.variable "item")
def appendBody : Expr .metadata := .extendSignature (.variable "functions") (.variable "item")

structure Context where
  text : Source := []
  functions : Metadata := {}
  item : Signature := emptySignature
  parameter : Formal := emptyFormal
  first : Nat := 0
  after : Nat := 0
  index : Nat := 0

def Context.locals (context : Context) : Locals
  | .source, "text" => context.text | .metadata, "functions" => context.functions
  | .signature, "item" => context.item | .formal, "item" => context.parameter
  | .number, "first" => context.first | .number, "after" => context.after
  | .number, "index" => context.index
  | ty, _ => ty.default

def Expr.scoped (locals : List (String × Ty)) : Expr ty → Bool
  | .variable name => locals.lookup name == some ty
  | .number _ | .function _ => true
  | .app fn arg => fn.scoped locals && arg.scoped locals
  | .field _ value | .not value | .group value => value.scoped locals
  | .signature a b | .parameter a b | .natSub a b | .natAdd a b
  | .eq a b | .le a b | .gt a b | .andThen a b | .orElse a b
  | .extendFormal a b | .extendSignature a b => a.scoped locals && b.scoped locals
  | .ite c a b | .elsif c a b => c.scoped locals && a.scoped locals && b.scoped locals
  | .forAllSignatures name functions body | .forAllParameters name functions body =>
      functions.scoped locals && body.scoped ((name, .number) :: locals)

/-- Selection and indexing require a name; grouping an expression does not
turn it into a name. The aggregate constructors also select their base fields. -/
def Expr.prefix : Expr ty → Bool
  | .variable _ | .function _ | .app _ _ | .field _ _ | .signature _ _ | .parameter _ _ => true
  | .number _ | .natSub _ _ | .natAdd _ _ | .eq _ _ | .le _ _ | .gt _ _ |
    .andThen _ _ | .orElse _ _ | .not _ | .group _ | .ite _ _ _ | .elsif _ _ _ |
    .forAllSignatures _ _ _ | .forAllParameters _ _ _ | .extendFormal _ _ | .extendSignature _ _ => false

def Expr.primary : Expr ty → Bool
  | .number _ | .variable _ | .function _ | .app _ _ | .field _ _
  | .signature _ _ | .parameter _ _ | .group _ => true
  | _ => false

def Expr.simple : Expr ty → Bool
  | .natSub _ _ | .natAdd _ _ | .not _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .le _ _ | .gt _ _ => true
  | value => value.simple

def Expr.expression : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ => true
  | value => value.relation

def Expr.andLeft : Expr .truth → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.orLeft : Expr .truth → Bool
  | .orElse _ _ => true | value => value.relation

def Expr.isConditional : Expr ty → Bool | .ite _ _ _ => true | _ => false

def Expr.isQuantified : Expr ty → Bool
  | .forAllSignatures _ _ _ | .forAllParameters _ _ _ => true | _ => false

def Expr.isAggregate : Expr ty → Bool
  | .extendFormal _ _ | .extendSignature _ _ => true | _ => false

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.functionSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .variable _ | .function _ => true
  | .app fn arg => fn.functionSpine && fn.wellFormed && arg.expression && arg.wellFormed
  | .field _ value => value.prefix && value.wellFormed
  | .signature functions index | .parameter functions index =>
      functions.prefix && functions.wellFormed && index.expression && index.wellFormed
  | .natSub a b | .natAdd a b => a.simple && b.primary && a.wellFormed && b.wellFormed
  | .eq a b | .le a b | .gt a b => a.simple && b.simple && a.wellFormed && b.wellFormed
  | .not value => value.primary && value.wellFormed
  | .andThen a b => a.andLeft && b.relation && a.wellFormed && b.wellFormed
  | .orElse a b => a.orLeft && b.relation && a.wellFormed && b.wellFormed
  | .group value => (value.expression || value.isConditional || value.isQuantified || value.isAggregate) && value.wellFormed
  | .ite c a b | .elsif c a b => c.expression && a.expression && (b.expression || b.isElsif) &&
      c.wellFormed && a.wellFormed && b.wellFormed
  | .forAllSignatures _ functions body | .forAllParameters _ functions body =>
      functions.prefix && functions.wellFormed && body.expression && body.wellFormed
  | .extendFormal functions item | .extendSignature functions item =>
      functions.prefix && functions.wellFormed && item.expression && item.wellFormed

def WellFormedTrees : Prop :=
  (lookupBody.wellFormed && lookupBody.scoped [("text", .source), ("functions", .metadata),
    ("first", .number), ("after", .number), ("index", .number)]) = true ∧
  (validMetadataBody.wellFormed && validMetadataBody.scoped [("text", .source), ("functions", .metadata)]) = true ∧
  (appendFormalBody.wellFormed && appendFormalBody.scoped [("functions", .metadata), ("item", .formal)]) = true ∧
  (appendBody.wellFormed && appendBody.scoped [("functions", .metadata), ("item", .signature)]) = true

instance : Decidable WellFormedTrees := inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _))
theorem trees_wellFormed : WellFormedTrees := by decide +kernel

namespace PrecedenceChecks
private def condition : Expr .truth := .eq (.number 0) (.number 0)
private theorem categories :
    (Expr.natSub (.number 10) (.natSub (.number 3) (.number 1))).wellFormed = false ∧
    (Expr.natSub (.natSub (.number 10) (.number 3)) (.number 1)).wellFormed = true ∧
    (Expr.andThen (.orElse condition condition) condition).wellFormed = false ∧
    (Expr.andThen (.group (.orElse condition condition)) condition).wellFormed = true ∧
    (Expr.not condition).wellFormed = false ∧
    (Expr.group (.elsif condition (.number 0) (.number 1))).wellFormed = false ∧
    (Expr.variable (ty := .number) "i").scoped [] = false := by decide +kernel
end PrecedenceChecks

namespace StructuralControls

private def functions : Expr .metadata := .variable "functions"
private def item : Expr .formal := .variable "item"
private def condition : Expr .truth := .eq (.number 0) (.number 0)

theorem selected_and_indexed_prefixes :
    (Expr.field .count (.group functions)).wellFormed = false ∧
    (Expr.field .count (.group (.ite condition functions functions))).wellFormed = false ∧
    (Expr.field .count (.group (.extendFormal functions item))).wellFormed = false ∧
    (Expr.signature (.group functions) (.number 1)).wellFormed = false ∧
    (Expr.parameter (.group functions) (.number 1)).wellFormed = false ∧
    (Expr.field .count functions).wellFormed = true ∧
    (Expr.field .first (.signature functions (.number 1))).wellFormed = true ∧
    (Expr.field .parameterFirst (.parameter functions (.number 1))).wellFormed = true := by decide +kernel

theorem embedded_prefixes :
    (Expr.forAllSignatures "i" (.group functions) condition).wellFormed = false ∧
    (Expr.forAllParameters "i" (.group functions) condition).wellFormed = false ∧
    (Expr.extendFormal (.group functions) item).wellFormed = false ∧
    (Expr.extendSignature (.group functions) (.variable "signature")).wellFormed = false ∧
    (Expr.forAllSignatures "i" functions condition).wellFormed = true ∧
    (Expr.forAllParameters "i" functions condition).wellFormed = true ∧
    (Expr.extendFormal functions item).wellFormed = true ∧
    (Expr.extendSignature functions (.variable "signature")).wellFormed = true := by decide +kernel

private def atom : Expr .truth := .app (.function .isEmpty) (.variable "bounds")

theorem not_collision :
    (Expr.not (.orElse atom atom)).render = (Expr.orElse (.not atom) atom).render ∧
    (Expr.not (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.not atom) atom).wellFormed = true := by decide +kernel

theorem subtraction_collision :
    (Expr.natSub (.number 10) (.natSub (.number 3) (.number 1))).render =
      (Expr.natSub (.natSub (.number 10) (.number 3)) (.number 1)).render ∧
    (Expr.natSub (.number 10) (.natSub (.number 3) (.number 1))).wellFormed = false ∧
    (Expr.natSub (.natSub (.number 10) (.number 3)) (.number 1)).wellFormed = true := by decide +kernel

end StructuralControls

end Silver.FunctionBindings.Native
