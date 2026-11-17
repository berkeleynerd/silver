module

public import Silver.PredicateAssociationAdmission
public import Silver.ComposeExpressions

@[expose] public section

/-! Typed syntax for resolving a written actual association. Formal lookup
keeps the selected signature's bounds explicit. No caller-variable lookup is
available to selector resolution, and every imported call retains its native
name. -/
namespace Silver.Predicate.AssociationNative
open Compose

inductive Ty
  | number | truth | source | token | functions | procedures | functionFormal | procedureFormal | association | formalSet
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat
  | .truth => Bool
  | .source => Source
  | .token => ShellToken
  | .functions => FunctionBindings.Metadata
  | .procedures => ProcedureBindings.Metadata
  | .functionFormal => FunctionBindings.Formal
  | .procedureFormal => ProcedureBindings.Formal
  | .association => ActualAssociation
  | .formalSet => FormalSet
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0
  | .truth => false
  | .source => []
  | .token => .symbol "=>"
  | .functions => {}
  | .procedures => {}
  | .functionFormal => FunctionBindings.emptyFormal
  | .procedureFormal => ProcedureBindings.emptyFormal
  | .association => invalidAssociation
  | .formalSet => noFormals
  | .arrow _ b => fun _ => b.default

def Ty.name : Ty → List String
  | .number => ["literal_position"]
  | .truth => ["boolean"]
  | .source => ["string"]
  | .token => ["token_kind"]
  | .functions => ["functions", ".", "metadata"]
  | .procedures => ["procedures", ".", "metadata"]
  | .functionFormal => ["functions", ".", "formal"]
  | .procedureFormal => ["procedures", ".", "formal"]
  | .association => ["actual_association"]
  | .formalSet => ["formal_set"]
  | .arrow _ _ => []

def arrows (args : List Ty) (result : Ty) : Ty := args.foldr Ty.arrow result

inductive Function
  | skip | nameAfter | equalName | token
  | functionFormalModel | functionFormalAt | procedureFormalModel | procedureFormalAt
  | functionAssociation | procedureAssociation | markFormal
  deriving DecidableEq, Repr

def Function.type : Function → Ty
  | .markFormal => arrows [.formalSet, .number] .formalSet
  | .skip | .nameAfter => arrows [.source, .number] .number
  | .equalName => arrows [.source, .number, .number, .number, .number] .truth
  | .token => arrows [.source, .number, .token] .number
  | .functionFormalModel | .functionFormalAt => arrows [.source, .functions, .number, .number, .number, .number] .number
  | .procedureFormalModel | .procedureFormalAt => arrows [.source, .procedures, .number, .number, .number, .number] .number
  | .functionAssociation => arrows [.source, .number, .functions, .number, .number, .number, .truth] .association
  | .procedureAssociation => arrows [.source, .number, .procedures, .number, .number, .number, .truth] .association

def Function.name : Function → List String
  | .markFormal => ["mark_formal"]
  | .skip => ["skip_at"]
  | .nameAfter => ["name_after"]
  | .equalName => ["equal_name"]
  | .token => ["take_token"]
  | .functionFormalModel => ["function_formal_model"]
  | .functionFormalAt => ["function_formal_at"]
  | .procedureFormalModel => ["procedure_formal_model"]
  | .procedureFormalAt => ["procedure_formal_at"]
  | .functionAssociation => ["function_association"]
  | .procedureAssociation => ["procedure_association"]

abbrev Calls := (fn : Function) → fn.type.meaning

inductive Field : Ty → Ty → Type
  | functionFirst : Field .functionFormal .number
  | functionAfter : Field .functionFormal .number
  | procedureFirst : Field .procedureFormal .number
  | procedureAfter : Field .procedureFormal .number
  | formal : Field .association .number
  | payloadFirst : Field .association .number
  | named : Field .association .truth

def Field.name : Field a b → String
  | .functionFirst | .procedureFirst => "first"
  | .functionAfter | .procedureAfter => "after"
  | .formal => "formal"
  | .payloadFirst => "payload_first"
  | .named => "named"

def Field.get : Field a b → a.meaning → b.meaning
  | .functionFirst, value => value.first
  | .functionAfter, value => value.after
  | .procedureFirst, value => value.first
  | .procedureAfter, value => value.after
  | .formal, value => value.formal
  | .payloadFirst, value => value.payloadFirst
  | .named, value => value.named

inductive Token | arrow
  deriving DecidableEq, Repr

def Token.name : Token → String | .arrow => "arrow"
def Token.shell : Token → ShellToken | .arrow => .symbol "=>"

theorem Token.name_eq_tokenName_shell : ∀ token : Token,
    token.name = Expressions.tokenName token.shell := by intro token; cases token; rfl

inductive Expr : Ty → Type
  | number : Nat → Expr .number
  | truth : Bool → Expr .truth
  | token : Token → Expr .token
  | invalidAssociation : Expr .association
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | functionParameter : Expr .functions → Expr .number → Expr .functionFormal
  | procedureParameter : Expr .procedures → Expr .number → Expr .procedureFormal
  | association : Expr .number → Expr .number → Expr .truth → Expr .association
  | deltaSeen : Expr .formalSet → Expr .number → Expr .formalSet
  | add : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr ty → Expr ty
  | ite : Expr .truth → Expr ty → Expr ty → Expr ty
  | elsif : Expr .truth → Expr ty → Expr ty → Expr ty
  | declare : Expr ty → Expr ty
  | letValue (name : String) (typeName : List String) : Expr a → Expr b → Expr b
  | beginValue : Expr ty → Expr ty

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun other actual => if same : other = ty then
    if actual = name then same.symm ▸ value else locals other actual
  else locals other actual

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .truth value => value | .token value => value.shell
  | .invalidAssociation => Predicate.invalidAssociation
  | .variable name => locals _ name | .function fn => calls fn
  | .app fn value => fn.eval calls locals (value.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .functionParameter catalog index => FunctionBindings.parameter (catalog.eval calls locals) (index.eval calls locals)
  | .procedureParameter catalog index => ProcedureBindings.parameter (catalog.eval calls locals) (index.eval calls locals)
  | .association formal payload named => ⟨formal.eval calls locals, payload.eval calls locals, named.eval calls locals⟩
  | .deltaSeen seenExpr formalExpr => Predicate.markFormal (seenExpr.eval calls locals) (formalExpr.eval calls locals)
  | .add left right => left.eval calls locals + right.eval calls locals
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !value.eval calls locals
  | .group value | .declare value | .beginValue value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .letValue name _ value body => body.eval calls (locals.set _ name (value.eval calls locals))

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .token value => [value.name]
  | .invalidAssociation => ["invalid_association"]
  | .variable name => [name] | .function fn => fn.name
  | .app fn value => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ value.render ++ [")"]
    | _ => fn.render ++ ["("] ++ value.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .functionParameter catalog index | .procedureParameter catalog index =>
      catalog.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .association formal payload named =>
      ["("] ++ formal.render ++ [","] ++ payload.render ++ [","] ++ named.render ++ [")"]
  | .deltaSeen seenExpr formalExpr => ["("] ++ seenExpr.render ++ ["with", "delta"] ++ formalExpr.render ++ ["=>", "true", ")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .declare value => ["declare"] ++ value.render
  | .letValue name typeName value body =>
      [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

def apply2 (fn : Expr (.arrow a (.arrow b c))) (a0 : Expr a) (a1 : Expr b) : Expr c :=
  .app (.app fn a0) a1
def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (a0 : Expr a) (a1 : Expr b) (a2 : Expr c) : Expr d :=
  .app (apply2 fn a0 a1) a2
def apply5 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (a0 : Expr a) (a1 : Expr b) (a2 : Expr c) (a3 : Expr d) (a4 : Expr e) : Expr f :=
  .app (.app (apply3 fn a0 a1 a2) a3) a4
def apply6 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f g)))))))
    (a0 : Expr a) (a1 : Expr b) (a2 : Expr c) (a3 : Expr d) (a4 : Expr e) (a5 : Expr f) : Expr g :=
  .app (apply5 fn a0 a1 a2 a3 a4) a5
def apply7 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g h))))))))
    (a0 : Expr a) (a1 : Expr b) (a2 : Expr c) (a3 : Expr d) (a4 : Expr e) (a5 : Expr f) (a6 : Expr g) : Expr h :=
  .app (apply6 fn a0 a1 a2 a3 a4 a5) a6

abbrev Scope := List (Ty × String)

def localType (ty : Ty) (name : List String) : Bool := name == ty.name || match ty with
  | .number => name == ["functions", ".", "formal_count"] ||
      name == ["procedures", ".", "formal_count"]
  | _ => false

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .invalidAssociation | .function _ => true
  | .variable name => scope.contains (ty, name)
  | .app fn value => fn.scoped scope && value.scoped scope
  | .field _ value => value.scoped scope
  | .functionParameter catalog index | .procedureParameter catalog index => catalog.scoped scope && index.scoped scope
  | .association formal payload named => formal.scoped scope && payload.scoped scope && named.scoped scope
  | .deltaSeen seenExpr formalExpr => seenExpr.scoped scope && formalExpr.scoped scope
  | .add left right | .eq left right | .ne left right | .le left right | .gt left right |
    .andThen left right | .orElse left right => left.scoped scope && right.scoped scope
  | .not value | .group value | .declare value | .beginValue value => value.scoped scope
  | .ite condition yes no | .elsif condition yes no => condition.scoped scope && yes.scoped scope && no.scoped scope
  | @Expr.letValue a _ name typeName value body => localType a typeName &&
      !(scope.any (·.2 == name)) && value.scoped scope && body.scoped ((a, name) :: scope)

def Expr.prefix : Expr ty → Bool
  | .token _ | .invalidAssociation | .variable _ | .function _ | .app _ _ | .field _ _ |
    .functionParameter _ _ | .procedureParameter _ _ => true
  | _ => false

def Expr.primary : Expr ty → Bool
  | .number _ | .truth _ | .association _ _ _ | .deltaSeen _ _ | .group _ => true
  | value => value.prefix

def Expr.simple : Expr ty → Bool
  | .add _ _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .le _ _ | .gt _ _ | .not _ => true
  | value => value.simple

def Expr.expression : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ | .not _ => true
  | value => value.relation

def Expr.andLeft : Expr ty → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orLeft : Expr ty → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.callHead : Expr ty → Bool | .function _ | .app _ _ => true | _ => false
def Expr.declarations : Expr ty → Bool
  | .letValue _ _ _ _ | .beginValue _ => true | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .invalidAssociation | .variable _ | .function _ => true
  | .app fn value => fn.wellFormed && fn.callHead && value.wellFormed && value.expression
  | .field _ value => value.wellFormed && value.prefix
  | .functionParameter catalog index | .procedureParameter catalog index =>
      catalog.wellFormed && catalog.prefix && index.wellFormed && index.expression
  | .deltaSeen seenExpr formalExpr => seenExpr.prefix && formalExpr.expression && seenExpr.wellFormed && formalExpr.wellFormed
  | .association formal payload named => formal.wellFormed && formal.expression &&
      payload.wellFormed && payload.expression && named.wellFormed && named.expression
  | .add left right => left.wellFormed && left.simple && right.wellFormed && right.primary
  | .eq left right | .ne left right | .le left right | .gt left right =>
      left.wellFormed && left.simple && right.wellFormed && right.simple
  | .andThen left right => left.wellFormed && left.andLeft && right.wellFormed && right.relation
  | .orElse left right => left.wellFormed && left.orLeft && right.wellFormed && right.relation
  | .not value => value.wellFormed && value.primary
  | .group value => (value.expression || (match value with | .declare _ | .ite _ _ _ => true | _ => false)) && value.wellFormed
  | .ite condition yes no | .elsif condition yes no => condition.wellFormed && condition.expression &&
      yes.wellFormed && yes.expression && no.wellFormed && (no.isElsif || no.expression)
  | .declare value => value.declarations && value.wellFormed
  | .letValue _ _ value body => value.expression && value.wellFormed && body.declarations && body.wellFormed
  | .beginValue value => value.expression && value.wellFormed

end Silver.Predicate.AssociationNative
