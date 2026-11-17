module

public import Silver.PredicateProcedureCallAdmission
public import Silver.PredicateNativeState

@[expose] public section

/-! Typed syntax for the procedure actual and copy-back scanner. Every helper
call retains its native identity. Input names, local binders, record projections,
and Ada operator precedence are checked independently of the interpretation. -/
namespace Silver.Predicate.ProcedureCallNative
open Compose

set_option backward.dsimp.instances true

inductive Ty
  | number | truth | source | token | kind | mode | interval | context | flow | scan | metadata | formal | signature | actual | functionFormal | names | scalars | booleans | arrays
  | association | formalSet
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat
  | .truth => Bool
  | .source => Source
  | .token => ShellToken
  | .kind => FunctionBindings.ScalarKind
  | .mode => ProcedureBindings.Mode
  | .interval => Integer.Interval
  | .context => Native.Context
  | .flow => ActiveFlow
  | .scan => BodyScan
  | .metadata => ProcedureBindings.Metadata
  | .formal => ProcedureBindings.Formal
  | .signature => ProcedureBindings.Signature
  | .actual => ProcedureActualResult
  | .functionFormal => FunctionBindings.Formal
  | .names => BindingEnvironment
  | .scalars => ScalarExpression.Environment
  | .booleans => BooleanBindings.Environment
  | .arrays => ArrayBindings.Metadata
  | .association => ActualAssociation
  | .formalSet => FormalSet
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0
  | .truth => false
  | .source => []
  | .token => .symbol ";"
  | .kind => .integer
  | .mode => .input
  | .interval => .empty
  | .context => {names := [], dynamicFirst := 0, dynamicAfter := 0}
  | .flow => ⟨PathFacts.Context.empty, []⟩
  | .scan => ⟨0,0,0,⟨PathFacts.Context.empty, []⟩,false,false⟩
  | .metadata => {}
  | .formal => ProcedureBindings.emptyFormal
  | .signature => ProcedureBindings.emptySignature
  | .actual => invalidProcedureActual
  | .functionFormal => FunctionBindings.emptyFormal
  | .names => []
  | .scalars => []
  | .booleans => []
  | .arrays => []
  | .association => invalidAssociation
  | .formalSet => noFormals
  | .arrow _ b => fun _ => b.default

def Ty.name : Ty → List String
  | .number => ["literal_position"]
  | .truth => ["boolean"]
  | .source => ["string"]
  | .token => ["token_kind"]
  | .kind => ["functions", ".", "scalar_kind"]
  | .mode => ["procedures", ".", "parameter_mode"]
  | .interval => ["scalars", ".", "interval"]
  | .context => ["body_context"]
  | .flow => ["scalar_flow"]
  | .scan => ["body_scan"]
  | .metadata => ["procedures", ".", "metadata"]
  | .formal => ["procedures", ".", "formal"]
  | .signature => ["procedures", ".", "signature"]
  | .actual => ["procedure_actual_result"]
  | .functionFormal => ["functions", ".", "formal"]
  | .names => ["binding_environment"]
  | .scalars => ["scalar_expressions", ".", "environment"]
  | .booleans => ["boolean_environment"]
  | .arrays => ["array_bindings", ".", "metadata"]
  | .association => ["actual_association"]
  | .formalSet => ["formal_set"]
  | .arrow _ _ => []

def arrows (args : List Ty) (result : Ty) : Ty := args.foldr Ty.arrow result

inductive Function
  | skip | nameAfter | namesLookup | scalarLookup | booleanLookup | arrayLookup | procedureLookup | token | isEmpty | included | scalarTarget | booleanTarget | functionActual | nameFree | invalid | invalidModel | bodyToken | target | actual | actualsModel | actuals | update | updatesModel | updates | callee | call
  | association | actualsTail | payloadsFreeModel | payloadsFree | updatesTail | markFormal | nameFreeModel
  deriving DecidableEq, Repr

def Function.type : Function → Ty
  | .markFormal => arrows [.formalSet, .number] .formalSet
  | .skip => arrows [.source, .number] .number
  | .nameAfter => arrows [.source, .number] .number
  | .namesLookup => arrows [.source, .names, .number, .number] .number
  | .scalarLookup => arrows [.source, .scalars, .number, .number] .number
  | .booleanLookup => arrows [.source, .booleans, .number, .number] .number
  | .arrayLookup => arrows [.source, .arrays, .number, .number] .number
  | .procedureLookup => arrows [.source, .metadata, .number, .number] .number
  | .token => arrows [.source, .number, .token] .number
  | .isEmpty => arrows [.interval] .truth
  | .included => arrows [.interval, .interval] .truth
  | .scalarTarget => arrows [.source, .context, .number] .number
  | .booleanTarget => arrows [.source, .context, .number] .number
  | .functionActual => arrows [.source, .context, .number, .flow, .functionFormal] .number
  | .nameFree | .nameFreeModel => arrows [.source, .number, .number, .number, .number] .truth
  | .invalid => arrows [.scan] .scan
  | .invalidModel => arrows [.scan] .scan
  | .bodyToken => arrows [.source, .context, .scan, .token] .scan
  | .target => arrows [.source, .context, .number, .flow, .formal] .actual
  | .actual => arrows [.source, .context, .number, .flow, .formal] .number
  | .actualsModel => arrows [.source, .context, .number, .flow, .metadata, .number, .number] .number
  | .actuals => arrows [.source, .context, .number, .flow, .metadata, .number, .number] .number
  | .update => arrows [.source, .context, .flow, .scan, .formal, .metadata, .number, .number, .number, .number] .scan
  | .updatesModel => arrows [.source, .context, .flow, .scan, .metadata, .number, .number, .number, .number] .scan
  | .updates => arrows [.source, .context, .scan, .metadata, .number, .number, .number, .number] .scan
  | .callee => arrows [.source, .context, .number, .metadata] .number
  | .call => arrows [.source, .context, .scan, .metadata] .scan
  | .association => arrows [.source, .number, .metadata, .number, .number, .number, .truth] .association
  | .actualsTail => arrows [.source, .context, .number, .flow, .metadata, .number, .number, .number, .truth, .formalSet] .number
  | .payloadsFreeModel => arrows [.source, .context, .number, .flow, .metadata, .number, .number, .number, .truth, .number, .number, .number] .truth
  | .payloadsFree => arrows [.source, .context, .number, .flow, .metadata, .number, .number, .number, .number, .number] .truth
  | .updatesTail => arrows [.source, .context, .flow, .scan, .metadata, .number, .number, .number, .truth, .formalSet, .number, .number] .scan

def Function.name : Function → List String
  | .markFormal => ["mark_formal"]
  | .skip => ["skip_at"]
  | .nameAfter => ["name_after"]
  | .namesLookup => ["lookup_name"]
  | .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | .booleanLookup => ["lookup_boolean"]
  | .arrayLookup => ["array_bindings", ".", "lookup"]
  | .procedureLookup => ["procedures", ".", "lookup"]
  | .token => ["take_token"]
  | .isEmpty => ["scalars", ".", "is_empty"]
  | .included => ["included"]
  | .scalarTarget => ["scalar_target"]
  | .booleanTarget => ["boolean_target"]
  | .functionActual => ["actual_after"]
  | .nameFree => ["actual_name_free"]
  | .nameFreeModel => ["actual_name_free_model"]
  | .invalid => ["invalid_body"]
  | .invalidModel => ["invalid_body_model"]
  | .bodyToken => ["body_token"]
  | .target => ["procedure_target_actual"]
  | .actual => ["procedure_actual_after"]
  | .actualsModel => ["procedure_actuals_model"]
  | .actuals => ["procedure_actuals_after"]
  | .update => ["procedure_update_step"]
  | .updatesModel => ["procedure_updates_model"]
  | .updates => ["procedure_updates"]
  | .callee => ["procedure_callee_at"]
  | .call => ["procedure_call_body"]
  | .association => ["procedure_association"]
  | .actualsTail => ["procedure_actuals_tail_model"]
  | .payloadsFreeModel => ["procedure_payloads_free_model"]
  | .payloadsFree => ["procedure_payloads_free"]
  | .updatesTail => ["procedure_updates_tail_model"]

abbrev Calls := (fn : Function) → fn.type.meaning

inductive Field : Ty → Ty → Type
  | contextNames : Field .context .names
  | contextScalars : Field .context .scalars
  | contextBooleans : Field .context .booleans
  | contextArrays : Field .context .arrays
  | scanPosition : Field .scan .number
  | scanFacts : Field .scan .flow
  | formalFirst : Field .formal .number
  | formalAfter : Field .formal .number
  | formalKind : Field .formal .kind
  | formalBounds : Field .formal .interval
  | formalMode : Field .formal .mode
  | signatureFirst : Field .signature .number
  | signatureCount : Field .signature .number
  | actualFirst : Field .actual .number
  | actualAfter : Field .actual .number
  | actualScalar : Field .actual .number
  | actualFlag : Field .actual .number
  | associationFormal : Field .association .number
  | associationPayload : Field .association .number
  | associationNamed : Field .association .truth

def Field.name : Field a b → List String
  | .contextNames => ["names"]
  | .contextScalars => ["scalar_names"]
  | .contextBooleans => ["boolean_names"]
  | .contextArrays => ["array_names"]
  | .scanPosition => ["position"]
  | .scanFacts => ["facts"]
  | .formalFirst => ["first"]
  | .formalAfter => ["after"]
  | .formalKind => ["kind"]
  | .formalBounds => ["bounds"]
  | .formalMode => ["mode"]
  | .signatureFirst => ["formal_first"]
  | .signatureCount => ["count"]
  | .actualFirst => ["first"]
  | .actualAfter => ["after"]
  | .actualScalar => ["scalar"]
  | .actualFlag => ["flag"]
  | .associationFormal => ["formal"]
  | .associationPayload => ["payload_first"]
  | .associationNamed => ["named"]

def Field.get : Field a b → a.meaning → b.meaning
  | .contextNames, value => value.names
  | .contextScalars, value => value.scalarNames
  | .contextBooleans, value => value.booleanNames
  | .contextArrays, value => value.arrayNames
  | .scanPosition, value => value.position
  | .scanFacts, value => value.facts
  | .formalFirst, value => value.first
  | .formalAfter, value => value.after
  | .formalKind, value => value.kind
  | .formalBounds, value => value.bounds
  | .formalMode, value => value.mode
  | .signatureFirst, value => value.formalFirst
  | .signatureCount, value => value.count
  | .actualFirst, value => value.first
  | .actualAfter, value => value.after
  | .actualScalar, value => value.scalar
  | .actualFlag, value => value.flag
  | .associationFormal, value => value.formal
  | .associationPayload, value => value.payloadFirst
  | .associationNamed, value => value.named

inductive ScanField : Ty → Type
  | position : ScanField .number
  | assigned : ScanField .truth
  | facts : ScanField .flow

def ScanField.name : ScanField ty → String
  | .position => "position" | .assigned => "assigned" | .facts => "facts"

def ScanField.set : ScanField ty → BodyScan → ty.meaning → BodyScan
  | .position, scan, value => {scan with position := value}
  | .assigned, scan, value => {scan with assigned := value}
  | .facts, scan, value => {scan with facts := value}

inductive Token | leftParenthesis | rightParenthesis | comma
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .leftParenthesis => "left_parenthesis" | .rightParenthesis => "right_parenthesis" | .comma => "comma"
def Token.shell : Token → ShellToken
  | .leftParenthesis => .symbol "(" | .rightParenthesis => .symbol ")" | .comma => .symbol ","

theorem Token.name_eq_tokenName_shell : ∀ t : Token, t.name = Expressions.tokenName t.shell := by
  intro t; cases t <;> rfl

inductive Expr : Ty → Type
  | number : Nat → Expr .number | truth : Bool → Expr .truth
  | token : Token → Expr .token
  | kind : FunctionBindings.ScalarKind → Expr .kind
  | mode : ProcedureBindings.Mode → Expr .mode
  | invalidActual : Expr .actual
  | noFormals : Expr .formalSet
  | seenAt : Expr .formalSet → Expr .number → Expr .truth
  | markSeen : Expr .formalSet → Expr .number → Expr .formalSet
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | formalAt : Expr .metadata → Expr .number → Expr .formal
  | signatureAt : Expr .metadata → Expr .number → Expr .signature
  | scalarMutable : Expr .scalars → Expr .number → Expr .truth
  | declaredBounds : Expr .scalars → Expr .number → Expr .interval
  | booleanMutable : Expr .booleans → Expr .number → Expr .truth
  | valueAt : Expr .flow → Expr .number → Expr .interval
  | replace : Expr .flow → Expr .number → Expr .interval → Expr .flow
  | update : ScanField ty → Expr .scan → Expr ty → Expr .scan
  | actualResult : Expr .number → Expr .number → Expr .number → Expr .number → Expr .actual
  | functionFormal : Expr .number → Expr .number → Expr .kind → Expr .interval → Expr .functionFormal
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | eqKind : Expr .kind → Expr .kind → Expr .truth
  | eqMode : Expr .mode → Expr .mode → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr ty → Expr ty
  | ite : Expr .truth → Expr ty → Expr ty → Expr ty
  | elsif : Expr .truth → Expr ty → Expr ty → Expr ty
  | declare : Expr ty → Expr ty
  | letValue (name : String) : Expr a → Expr b → Expr b
  | beginValue : Expr ty → Expr ty

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun other actual => if same : other = ty then
    if actual = name then same.symm ▸ value else locals other actual
  else locals other actual

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .truth value => value | .token value => value.shell
  | .kind value => value | .mode value => value | .invalidActual => invalidProcedureActual
  | .noFormals => Predicate.noFormals
  | .seenAt seen formal => seen.eval calls locals (formal.eval calls locals)
  | .markSeen seen formal => calls .markFormal (seen.eval calls locals) (formal.eval calls locals)
  | .variable name => locals _ name | .function fn => calls fn
  | .app fn value => fn.eval calls locals (value.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .formalAt catalog index => ProcedureBindings.parameter (catalog.eval calls locals) (index.eval calls locals)
  | .signatureAt catalog index => ProcedureBindings.signature (catalog.eval calls locals) (index.eval calls locals)
  | .scalarMutable names index => (ScalarExpression.binding (names.eval calls locals) (index.eval calls locals)).mutable
  | .declaredBounds names index => (ScalarExpression.binding (names.eval calls locals) (index.eval calls locals)).declaredBounds
  | .booleanMutable names index => (BooleanBindings.binding (names.eval calls locals) (index.eval calls locals)).mutable
  | .valueAt facts index => (facts.eval calls locals).values.getD (index.eval calls locals - 1) Integer.Interval.empty
  | .replace facts index bounds => (facts.eval calls locals).replace (index.eval calls locals) (bounds.eval calls locals)
  | .update projection scan value => projection.set (scan.eval calls locals) (value.eval calls locals)
  | .actualResult first after scalar flag => ⟨first.eval calls locals, after.eval calls locals, scalar.eval calls locals, flag.eval calls locals⟩
  | .functionFormal first after scalarKind bounds => ⟨first.eval calls locals, after.eval calls locals, scalarKind.eval calls locals, bounds.eval calls locals⟩
  | .add left right => left.eval calls locals + right.eval calls locals
  | .sub left right => left.eval calls locals - right.eval calls locals
  | .eq left right | .eqKind left right | .eqMode left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .lt left right => decide (left.eval calls locals < right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !value.eval calls locals
  | .group value | .declare value | .beginValue value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .letValue name value body => body.eval calls (locals.set _ name (value.eval calls locals))

def separated (items : List (List String)) : List String := (items.intersperse [","]).flatten

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .token value => [value.name]
  | .kind .integer => ["functions", ".", "integer_kind"] | .kind .boolean => ["functions", ".", "boolean_kind"]
  | .mode .input => ["procedures", ".", "input"] | .mode .output => ["procedures", ".", "output"]
  | .mode .inputOutput => ["procedures", ".", "input_output"]
  | .invalidActual => ["invalid_procedure_actual"]
  | .noFormals => ["no_formals"]
  | .seenAt seen formal => seen.render ++ ["("] ++ formal.render ++ [")"]
  | .markSeen seen formal => ["mark_formal", "("] ++ seen.render ++ [","] ++ formal.render ++ [")"]
  | .variable name => [name] | .function fn => fn.name
  | .app fn value => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ value.render ++ [")"]
    | _ => fn.render ++ ["("] ++ value.render ++ [")"]
  | .field projection value => value.render ++ ["."] ++ projection.name
  | .formalAt catalog index => catalog.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .signatureAt catalog index => catalog.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .scalarMutable names index | .booleanMutable names index =>
      names.render ++ [".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .declaredBounds names index =>
      names.render ++ [".", "items", "("] ++ index.render ++ [")", ".", "declared_bounds"]
  | .valueAt facts index => facts.render ++ [".", "values", "("] ++ index.render ++ [")"]
  | .replace facts index bounds => ["("] ++ facts.render ++ ["with", "delta", "values", "=>", "("] ++
      facts.render ++ [".", "values", "with", "delta"] ++ index.render ++ ["=>"] ++ bounds.render ++ [")", ")"]
  | .update projection scan value => match scan with
    | .update _ _ _ => scan.render.dropLast ++ [",", projection.name, "=>"] ++ value.render ++ [")"]
    | _ => ["("] ++ scan.render ++ ["with", "delta", projection.name, "=>"] ++ value.render ++ [")"]
  | .actualResult first after scalar flag => ["("] ++ separated [first.render, after.render, scalar.render, flag.render] ++ [")"]
  | .functionFormal first after scalarKind bounds => ["("] ++ separated [first.render, after.render, scalarKind.render, bounds.render] ++ [")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .eq left right | .eqKind left right | .eqMode left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .lt left right => left.render ++ ["<"] ++ right.render
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
  | @Expr.letValue a _ name value body => [name, ":", "constant"] ++ a.name ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

def apply2 (fn : Expr (.arrow a (.arrow b c))) (v0 : Expr a) (v1 : Expr b) : Expr c :=
  (.app (.app fn v0) v1)
def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) : Expr d :=
  (.app (.app (.app fn v0) v1) v2)
def apply4 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d e))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) : Expr e :=
  (.app (.app (.app (.app fn v0) v1) v2) v3)
def apply5 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f)))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) : Expr f :=
  (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4)
def apply6 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f g))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) : Expr g :=
  (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5)
def apply7 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g h)))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) (v6 : Expr g) : Expr h :=
  (.app (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5) v6)
def apply8 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g (.arrow h i))))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) (v6 : Expr g) (v7 : Expr h) : Expr i :=
  (.app (.app (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5) v6) v7)
def apply9 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g (.arrow h (.arrow i j)))))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) (v6 : Expr g) (v7 : Expr h) (v8 : Expr i) : Expr j :=
  (.app (.app (.app (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5) v6) v7) v8)

def apply10 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g (.arrow h (.arrow i (.arrow j k))))))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) (v6 : Expr g) (v7 : Expr h) (v8 : Expr i) (v9 : Expr j) : Expr k :=
  (.app (.app (.app (.app (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5) v6) v7) v8) v9)
def apply12 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f (.arrow g (.arrow h (.arrow i (.arrow j (.arrow k (.arrow l m))))))))))))) (v0 : Expr a) (v1 : Expr b) (v2 : Expr c) (v3 : Expr d) (v4 : Expr e) (v5 : Expr f) (v6 : Expr g) (v7 : Expr h) (v8 : Expr i) (v9 : Expr j) (v10 : Expr k) (v11 : Expr l) : Expr m :=
  (.app (.app (.app (.app (.app (.app (.app (.app (.app (.app (.app (.app fn v0) v1) v2) v3) v4) v5) v6) v7) v8) v9) v10) v11)

inductive Command : Ty → Type
  | letValue (name : String) (typeName : List String) : Expr a → Command b → Command b
  | beginBody : Command ty → Command ty
  | guard : Expr .truth → Expr ty → Command ty → Command ty
  | branch : Expr .truth → Command ty → Command ty → Command ty
  | block : Command ty → Command ty
  | returned : Expr ty → Command ty

def Command.eval (calls : Calls) (locals : Locals) : Command ty → ty.meaning
  | .letValue name _ value body => body.eval calls (locals.set _ name (value.eval calls locals))
  | .beginBody body | .block body => body.eval calls locals
  | .guard condition rejected body =>
      if condition.eval calls locals then rejected.eval calls locals else body.eval calls locals
  | .branch condition yes no => if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .returned value => value.eval calls locals

def Command.render : Command ty → List String
  | .letValue name typeName value body =>
      [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .beginBody body => ["begin"] ++ body.render
  | .guard condition rejected body => ["if"] ++ condition.render ++ ["then", "return"] ++ rejected.render ++
      [";", "end", "if", ";"] ++ body.render
  | .branch condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render ++ ["end", "if", ";"]
  | .block body => ["declare"] ++ body.render ++ ["end", ";"]
  | .returned value => ["return"] ++ value.render ++ [";"]

abbrev Scope := List (Ty × String)

def localType (ty : Ty) (name : List String) : Bool := name == ty.name || match ty with
  | .number => name == ["scalar_expressions", ".", "binding_count"] || name == ["boolean_count"] ||
      name == ["procedures", ".", "procedure_count"]
  | _ => false

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .kind _ | .mode _ | .invalidActual | .noFormals | .function _ => true
  | .variable name => scope.contains (ty, name)
  | .app fn value => fn.scoped scope && value.scoped scope
  | .field _ value => value.scoped scope
  | .formalAt catalog index | .signatureAt catalog index | .seenAt catalog index | .markSeen catalog index => catalog.scoped scope && index.scoped scope
  | .scalarMutable names index | .declaredBounds names index | .booleanMutable names index => names.scoped scope && index.scoped scope
  | .valueAt facts index => facts.scoped scope && index.scoped scope
  | .replace facts index bounds => facts.scoped scope && index.scoped scope && bounds.scoped scope
  | .update _ scan value => scan.scoped scope && value.scoped scope
  | .actualResult first after scalar flag => first.scoped scope && after.scoped scope && scalar.scoped scope && flag.scoped scope
  | .functionFormal first after scalarKind bounds => first.scoped scope && after.scoped scope && scalarKind.scoped scope && bounds.scoped scope
  | .add left right | .sub left right | .eq left right | .ne left right | .le left right | .lt left right | .gt left right |
    .eqKind left right | .eqMode left right | .andThen left right | .orElse left right => left.scoped scope && right.scoped scope
  | .not value | .group value | .declare value | .beginValue value => value.scoped scope
  | .ite condition yes no | .elsif condition yes no => condition.scoped scope && yes.scoped scope && no.scoped scope
  | @Expr.letValue a _ name value body => value.scoped scope && !(scope.any (·.2 == name)) && body.scoped ((a, name) :: scope)

def Command.scoped (scope : Scope) : Command ty → Bool
  | @Command.letValue a _ name typeName value body => localType a typeName && !(scope.any (·.2 == name)) &&
      value.scoped scope && body.scoped ((a, name) :: scope)
  | .beginBody body | .block body => body.scoped scope
  | .guard condition rejected body => condition.scoped scope && rejected.scoped scope && body.scoped scope
  | .branch condition yes no => condition.scoped scope && yes.scoped scope && no.scoped scope
  | .returned value => value.scoped scope

def Expr.prefix : Expr ty → Bool
  | .noFormals | .seenAt _ _ | .token _ | .kind _ | .mode _ | .invalidActual | .variable _ | .function _ | .app _ _ | .field _ _ |
    .formalAt _ _ | .signatureAt _ _ | .scalarMutable _ _ | .declaredBounds _ _ | .booleanMutable _ _ | .valueAt _ _ => true
  | _ => false

def Expr.primary : Expr ty → Bool
  | .markSeen _ _ | .number _ | .truth _ | .replace _ _ _ | .update _ _ _ | .actualResult _ _ _ _ | .functionFormal _ _ _ _ | .group _ => true
  | value => value.prefix

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .le _ _ | .lt _ _ | .gt _ _ | .eqKind _ _ | .eqMode _ _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr .truth → Bool | .andThen _ _ => true | value => value.relation
def Expr.orHead : Expr .truth → Bool | .orElse _ _ => true | value => value.relation
def Expr.callHead : Expr ty → Bool | .function _ | .app _ _ => true | _ => false

def Expr.value : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ => true
  | value => value.relation

def Expr.branch : Expr ty → Bool | .elsif _ _ _ => true | value => value.value
def Expr.declarations : Expr ty → Bool | .letValue _ _ _ | .beginValue _ => true | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .kind _ | .mode _ | .invalidActual | .noFormals | .variable _ | .function _ => true
  | .app fn value => fn.callHead && value.value && fn.wellFormed && value.wellFormed
  | .field _ value => value.prefix && value.wellFormed
  | .formalAt catalog index | .signatureAt catalog index | .seenAt catalog index => catalog.prefix && index.value && catalog.wellFormed && index.wellFormed
  | .markSeen seenExpr formalExpr => seenExpr.value && formalExpr.value && seenExpr.wellFormed && formalExpr.wellFormed
  | .scalarMutable names index | .declaredBounds names index | .booleanMutable names index => names.prefix && index.value && names.wellFormed && index.wellFormed
  | .valueAt facts index => facts.prefix && index.value && facts.wellFormed && index.wellFormed
  | .replace facts index bounds => facts.prefix && index.value && bounds.value && facts.wellFormed && index.wellFormed && bounds.wellFormed
  | .update _ scan value => scan.primary && value.value && scan.wellFormed && value.wellFormed
  | .actualResult first after scalar flag => first.value && after.value && scalar.value && flag.value &&
      first.wellFormed && after.wellFormed && scalar.wellFormed && flag.wellFormed
  | .functionFormal first after scalarKind bounds => first.value && after.value && scalarKind.value && bounds.value &&
      first.wellFormed && after.wellFormed && scalarKind.wellFormed && bounds.wellFormed
  | .add left right | .sub left right => left.simple && right.primary && left.wellFormed && right.wellFormed
  | .eq left right | .ne left right | .le left right | .lt left right | .gt left right | .eqKind left right | .eqMode left right =>
      left.simple && right.simple && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .not value => value.primary && value.wellFormed
  | .group value => (value.value || (match value with | .declare _ | .ite _ _ _ => true | _ => false)) && value.wellFormed
  | .ite condition yes no | .elsif condition yes no => condition.value && yes.value && no.branch &&
      condition.wellFormed && yes.wellFormed && no.wellFormed
  | .declare value => value.declarations && value.wellFormed
  | .letValue _ value body => value.value && body.declarations && value.wellFormed && body.wellFormed
  | .beginValue value => value.value && value.wellFormed

def Command.wellFormed : Command ty → Bool
  | .letValue _ _ value body => value.value && value.wellFormed && body.wellFormed
  | .beginBody body | .block body => body.wellFormed
  | .guard condition rejected body => condition.value && rejected.value && condition.wellFormed && rejected.wellFormed && body.wellFormed
  | .branch condition yes no => condition.value && condition.wellFormed && yes.wellFormed && no.wellFormed
  | .returned value => value.value && value.wellFormed

end Silver.Predicate.ProcedureCallNative
