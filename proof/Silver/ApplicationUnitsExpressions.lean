module

public import Silver.ApplicationUnits
public import Silver.Expressions

@[expose] public section

/-! Typed trees for every executable storage operation. Source values retain
Ada string bounds separately from bytes; slice assignment slides its right-hand
bytes without consulting those bounds. No lexer, admission or package semantics
is assumed by these storage trees. -/
namespace Silver.ApplicationUnits.Native

instance (sources : Bundle) : Decidable sources.Layout :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

structure SourceValue where
  first : Int
  bytes : Source
  deriving DecidableEq, Repr

def SourceValue.last (value : SourceValue) : Int := value.first + value.bytes.length - 1

def SourceValue.slice (value : SourceValue) (first last : Nat) : SourceValue :=
  ⟨first, (value.bytes.drop ((first : Int) - value.first).toNat).take (last + 1 - first)⟩

inductive Ty
  | number | truth | source | kind | span | bundle
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .source => SourceValue
  | .kind => UnitKind | .span => Span | .bundle => Bundle

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .source => ⟨1, []⟩
  | .kind => .packageSpecification | .span => ⟨1, 1⟩
  | .bundle => ⟨[], 0, fun _ => ⟨1, 1⟩⟩

inductive Field : Ty → Ty → Type
  | first : Field .span .number | after : Field .span .number
  | pool : Field .bundle .source | used : Field .bundle .number

def Field.name : Field a b → String
  | .first => "first" | .after => "after" | .pool => "pool" | .used => "used"

def Field.get : Field a b → a.meaning → b.meaning
  | .first, span => span.first | .after, span => span.after
  | .pool, sources => ⟨1, sources.pool⟩ | .used, sources => sources.used

def kindName : UnitKind → String
  | .packageSpecification => "package_specification"
  | .packageBody => "package_body" | .mainBody => "main_body"

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | variable (name : String) : Expr ty
  | kind (value : UnitKind) : Expr .kind
  | maxLength : Expr .number
  | field : Field a b → Expr a → Expr b
  | length : Expr .source → Expr .number
  | unit : Expr .bundle → Expr .kind → Expr .span
  | slice : Expr .source → Expr .number → Expr .number → Expr .source
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | zeroPool : Expr .source
  | span : Expr .number → Expr .number → Expr .span
  | bundle : Expr .source → Expr .number → Expr .span → Expr .span → Expr .span → Expr .bundle

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def aggregate (fields : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (fields.map fun (name, value) => [name, "=>"] ++ value)) ++ [")"]

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .variable name => [name]
  | .kind value => [kindName value] | .maxLength => ["max_source_length"]
  | .field projection value => value.render ++ [".", projection.name]
  | .length value => value.render ++ ["'", "length"]
  | .unit sources which => sources.render ++ [".", "units", "("] ++ which.render ++ [")"]
  | .slice source first last => source.render ++ ["("] ++ first.render ++ [".."] ++ last.render ++ [")"]
  | .add a b => a.render ++ ["+"] ++ b.render | .sub a b => a.render ++ ["-"] ++ b.render
  | .eq a b => a.render ++ ["="] ++ b.render | .lt a b => a.render ++ ["<"] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .zeroPool => ["(", "others", "=>", "character", "'", "val", "(", "0", ")", ")"]
  | .span first after => aggregate [("first", first.render), ("after", after.render)]
  | .bundle pool used specification body main => aggregate [("pool", pool.render), ("used", used.render),
      ("units", aggregate [("package_specification", specification.render),
        ("package_body", body.render), ("main_body", main.render)])]

def Expr.eval (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .variable name => locals _ name | .kind value => value
  | .maxLength => maxSourceLength | .field projection value => projection.get (value.eval locals)
  | .length value => (value.eval locals).bytes.length
  | .unit sources which => (sources.eval locals).units (which.eval locals)
  | .slice source first last => (source.eval locals).slice (first.eval locals) (last.eval locals)
  | .add a b => a.eval locals + b.eval locals | .sub a b => a.eval locals - b.eval locals
  | .eq a b => decide (a.eval locals = b.eval locals) | .lt a b => decide (a.eval locals < b.eval locals)
  | .gt a b => decide (a.eval locals > b.eval locals) | .le a b => decide (a.eval locals ≤ b.eval locals)
  | .andThen a b => a.eval locals && b.eval locals | .group value => value.eval locals
  | .zeroPool => ⟨1, List.replicate maxSourceLength 0⟩
  | .span first after => ⟨first.eval locals, after.eval locals⟩
  | .bundle pool used specification body main =>
      ⟨(pool.eval locals).bytes, used.eval locals, fun kind => match kind with
        | .packageSpecification => specification.eval locals
        | .packageBody => body.eval locals | .mainBody => main.eval locals⟩

/-- Ordinary slice replacement; validity of both slice bounds and equal lengths
is a native proof obligation, and is established below for every fitting input. -/
def writeSlice (sources : Bundle) (first last : Nat) (value : SourceValue) : Bundle :=
  { sources with pool := sources.pool.take (first - 1) ++ value.bytes ++ sources.pool.drop last }

inductive Command : Ty → Type
  | bind (name typeName : String) (constant : Bool) : Expr a → Command b → Command b
  | beginBody : Command ty → Command ty
  | writePool (name : String) : Expr .number → Expr .number → Expr .source → Command ty → Command ty
  | returned : Expr ty → Command ty

def Command.eval (locals : Locals) : Command ty → ty.meaning
  | .bind name _ _ value rest => rest.eval (locals.set _ name (value.eval locals))
  | .beginBody rest => rest.eval locals
  | .writePool name first last value rest => rest.eval (locals.set .bundle name
      (writeSlice (locals .bundle name) (first.eval locals) (last.eval locals) (value.eval locals)))
  | .returned value => value.eval locals

def Command.render : Command ty → List String
  | .bind name typeName constant value rest => [name, ":"] ++
      (if constant then ["constant"] else []) ++ [typeName, ":="] ++ value.render ++ [";"] ++ rest.render
  | .beginBody rest => ["begin"] ++ rest.render
  | .writePool name first last value rest => [name, ".", "pool", "("] ++ first.render ++ [".."] ++
      last.render ++ [")", ":="] ++ value.render ++ [";"] ++ rest.render
  | .returned value => ["return"] ++ value.render ++ [";"]

structure Context where
  specification : SourceValue := ⟨1, []⟩
  body : SourceValue := ⟨1, []⟩
  main : SourceValue := ⟨1, []⟩
  sources : Bundle := ⟨[], 0, fun _ => ⟨1, 1⟩⟩
  kind : UnitKind := .packageSpecification

def Context.locals (context : Context) : Locals
  | .source, "specification_source" => context.specification
  | .source, "body_source" => context.body | .source, "main_source" => context.main
  | .bundle, "sources" => context.sources | .kind, "kind" => context.kind
  | ty, _ => ty.default

def fitsBody : Expr .truth :=
  let spec := Expr.length (.variable "specification_source")
  let body := Expr.length (.variable "body_source")
  let main := Expr.length (.variable "main_source")
  .andThen (.andThen (.andThen (.andThen (.andThen
    (.gt spec (.number 0)) (.gt body (.number 0))) (.gt main (.number 0)))
    (.le spec .maxLength)) (.le body (.sub .maxLength spec)))
    (.le main (.sub (.group (.sub .maxLength spec)) body))

def validBody : Expr .truth :=
  let unit kind := Expr.unit (.variable "sources") (.kind kind)
  let first kind := Expr.field .first (unit kind)
  let after kind := Expr.field .after (unit kind)
  .andThen (.andThen (.andThen (.andThen (.andThen (.andThen
    (.eq (first .packageSpecification) (.number 1))
    (.lt (first .packageSpecification) (after .packageSpecification)))
    (.eq (first .packageBody) (after .packageSpecification)))
    (.lt (first .packageBody) (after .packageBody)))
    (.eq (first .mainBody) (after .packageBody)))
    (.lt (first .mainBody) (after .mainBody)))
    (.eq (after .mainBody) (.add (.field .used (.variable "sources")) (.number 1)))

def unitSpanBody : Expr .span := .unit (.variable "sources") (.variable "kind")

def unitSourceBody : Expr .source := .slice (.field .pool (.variable "sources"))
  (.field .first unitSpanBody) (.sub (.field .after unitSpanBody) (.number 1))

def prefixBody : Expr .source := .slice (.field .pool (.variable "sources"))
  (.number 1) (.sub (.field .after unitSpanBody) (.number 1))

def packBody : Command .bundle :=
  let spec : Expr .source := .variable "specification_source"
  let body : Expr .source := .variable "body_source"
  let main : Expr .source := .variable "main_source"
  let specAfter : Expr .number := .variable "specification_after"
  let bodyAfter : Expr .number := .variable "body_after"
  let used : Expr .number := .variable "used"
  .bind "specification_after" "unit_position" true (.add (.length spec) (.number 1)) <|
    .bind "body_after" "unit_position" true (.add (.add (.length spec) (.length body)) (.number 1)) <|
    .bind "used" "source_length" true (.add (.add (.length spec) (.length body)) (.length main)) <|
    .bind "result" "bundle" false
      (.bundle .zeroPool used (.span (.number 1) specAfter) (.span specAfter bodyAfter)
        (.span bodyAfter (.add used (.number 1)))) <|
    .beginBody <|
    .writePool "result" (.number 1) (.sub specAfter (.number 1)) spec <|
    .writePool "result" specAfter (.sub bodyAfter (.number 1)) body <|
    .writePool "result" bodyAfter used main <|
    .returned (.variable "result")

/-! Precedence and scopes use the existing typed-tree checks: arithmetic is
left-associated, right subtraction operands must be primary, and declarations
must match their native types and mutability. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .variable _ | .kind _ | .maxLength | .field _ _ | .length _
  | .unit _ _ | .slice _ _ _ | .group _ | .zeroPool | .span _ _ | .bundle _ _ _ _ _ => true
  | _ => false

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ => true | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .lt _ _ | .gt _ _ | .le _ _ => true | value => value.simple

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.wellFormed : Expr ty → Bool
  | .field _ value | .length value => value.wellFormed && value.primary
  | .unit sources which => sources.wellFormed && sources.primary && which.wellFormed && which.simple
  | .slice source first last => source.wellFormed && source.primary && first.wellFormed &&
      first.simple && last.wellFormed && last.simple
  | .add a b | .sub a b => a.wellFormed && b.wellFormed && a.simple && b.primary
  | .eq a b | .lt a b | .gt a b | .le a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .andThen a b => a.wellFormed && b.wellFormed && a.andHead && b.relation
  | .group value => value.wellFormed
  | .span first after => first.wellFormed && first.simple && after.wellFormed && after.simple
  | .bundle pool used spec body main => pool.wellFormed && pool.simple && used.wellFormed && used.simple &&
      spec.wellFormed && spec.simple && body.wellFormed && body.simple && main.wellFormed && main.simple
  | _ => true

abbrev Scope := List (String × Ty × Bool)

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  ((scope.find? (fun entry => entry.1 == name)).map fun entry => entry.2.1) == some ty

def Scope.mutable (scope : Scope) (name : String) : Bool :=
  ((scope.find? (fun entry => entry.1 == name)).map Prod.snd) == some (.bundle, false)

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .variable name => scope.contains name ty
  | .field _ value | .length value | .group value => value.scoped scope
  | .unit a b | .add a b | .sub a b | .eq a b | .lt a b | .gt a b | .le a b | .andThen a b
  | .span a b => a.scoped scope && b.scoped scope
  | .slice source first last => source.scoped scope && first.scoped scope && last.scoped scope
  | .bundle pool used spec body main => pool.scoped scope && used.scoped scope && spec.scoped scope &&
      body.scoped scope && main.scoped scope
  | _ => true

def localType (ty : Ty) (name : String) : Bool :=
  match ty with
  | .number => name == "unit_position" || name == "source_length"
  | .bundle => name == "bundle" | _ => false

def Command.wellFormed : Command ty → Bool
  | .bind (a := ty) _ name _ value rest => localType ty name && value.wellFormed && value.simple && rest.wellFormed
  | .beginBody rest => rest.wellFormed
  | .writePool _ first last value rest => first.wellFormed && first.simple && last.wellFormed && last.simple &&
      value.wellFormed && value.simple && rest.wellFormed
  | .returned value => value.wellFormed && value.simple

def Command.scoped (scope : Scope) : Command ty → Bool
  | .bind (a := ty) name _ constant value rest => value.scoped scope && rest.scoped ((name, ty, constant) :: scope)
  | .beginBody rest => rest.scoped scope
  | .writePool name first last value rest => scope.mutable name && first.scoped scope && last.scoped scope &&
      value.scoped scope && rest.scoped scope
  | .returned value => value.scoped scope

abbrev sourceScope : Scope := [("specification_source", .source, true), ("body_source", .source, true),
  ("main_source", .source, true)]
abbrev bundleScope : Scope := [("sources", .bundle, true), ("kind", .kind, true)]

abbrev CheckedTrees : Prop :=
  fitsBody.wellFormed = true ∧ fitsBody.scoped sourceScope = true ∧
  validBody.wellFormed = true ∧ validBody.scoped bundleScope = true ∧
  unitSpanBody.wellFormed = true ∧ unitSpanBody.scoped bundleScope = true ∧
  unitSourceBody.wellFormed = true ∧ unitSourceBody.scoped bundleScope = true ∧
  prefixBody.wellFormed = true ∧ prefixBody.scoped bundleScope = true ∧
  packBody.wellFormed = true ∧ packBody.scoped sourceScope = true

theorem checked_trees : CheckedTrees := by decide +kernel

structure Calls where
  fits : SourceValue → SourceValue → SourceValue → Bool
  valid : Bundle → Bool
  unitSpan : Bundle → UnitKind → Span
  unitSource : Bundle → UnitKind → SourceValue
  unitPrefix : Bundle → UnitKind → SourceValue
  pack : SourceValue → SourceValue → SourceValue → Bundle

end Silver.ApplicationUnits.Native
