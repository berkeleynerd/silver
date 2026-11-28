module

public import Silver.PackageBindings

@[expose] public section

/-! Typed expressions for the native package metadata helper. Every source
operation, field, bound, quantifier, call and grouping has an explicit denotation.
Calls remain arbitrary until their separately checked definition equations. -/
namespace Silver.PackageBindings.Native

inductive Ty
  | number | integer | truth | source | name | unitKind | unitSpan | scalarKind | interval
  | exportKind | exportItem | state | set | mode | formal | routineKind | routine | metadata
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Text | .name => NameSpan
  | .unitKind => UnitKind | .unitSpan => UnitSpan | .scalarKind => ScalarKind | .interval => Integer.Interval
  | .exportKind => ExportKind | .exportItem => ExportDeclaration | .state => StateDeclaration | .set => StateSet
  | .mode => Mode | .formal => Formal | .routineKind => RoutineKind | .routine => Routine | .metadata => Metadata
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .integer => 0 | .truth => false | .source => ⟨1, []⟩ | .name => {}
  | .unitKind => .packageSpecification | .unitSpan => ⟨1,1⟩ | .scalarKind => .integer | .interval => .empty
  | .exportKind => .integerSubtype | .exportItem => {} | .state => {} | .set => emptyStateSet
  | .mode => .input | .formal => {} | .routineKind => .procedure | .routine => {} | .metadata => {}
  | .arrow _ b => fun _ => b.default

structure Calls where
  letter : Nat → Bool
  identifierCharacter : Nat → Bool
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  isEmpty : Integer.Interval → Bool
  isIdentifier : Text → Bool
  validName : Text → NameSpan → Bool
  inUnit : NameSpan → UnitSpan → Bool
  sameName : Text → NameSpan → NameSpan → Bool
  union : StateSet → StateSet → StateSet
  within : StateSet → Nat → Bool
  validMetadata : Text → Metadata → Bool
  completeMetadata : Text → Metadata → Bool
  exportLookupModel : Text → Metadata → NameSpan → Nat → Nat
  stateLookupModel : Text → Metadata → NameSpan → Nat → Nat
  routineLookupModel : Text → Metadata → NameSpan → Nat → Nat
  lookupExport : Text → Metadata → NameSpan → Nat
  lookupState : Text → Metadata → NameSpan → Nat
  lookupRoutine : Text → Metadata → NameSpan → Bool → Nat

inductive Function
  | letter | identifierCharacter | equalName | isEmpty | isIdentifier | validName | inUnit | sameName
  | within | validMetadata | exportLookup | stateLookup | routineLookup
  deriving DecidableEq, Repr

def Function.name : Function → List String
  | .letter => ["is_letter"] | .identifierCharacter => ["silver_profile", ".", "is_identifier_character"]
  | .equalName => ["equal_name"] | .isEmpty => ["scalars", ".", "is_empty"]
  | .isIdentifier => ["is_identifier"] | .validName => ["valid_name"] | .inUnit => ["in_unit"]
  | .sameName => ["same_name"] | .within => ["within"] | .validMetadata => ["valid_metadata"]
  | .exportLookup => ["export_lookup_model"] | .stateLookup => ["state_lookup_model"]
  | .routineLookup => ["routine_lookup_model"]

def Function.type : Function → Ty
  | .letter | .identifierCharacter => .arrow .number .truth
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .isEmpty => .arrow .interval .truth | .isIdentifier => .arrow .source .truth
  | .validName => .arrow .source (.arrow .name .truth)
  | .inUnit => .arrow .name (.arrow .unitSpan .truth)
  | .sameName => .arrow .source (.arrow .name (.arrow .name .truth))
  | .within => .arrow .set (.arrow .number .truth)
  | .validMetadata => .arrow .source (.arrow .metadata .truth)
  | .exportLookup | .stateLookup | .routineLookup => .arrow .source (.arrow .metadata (.arrow .name (.arrow .number .number)))

def Calls.get (calls : Calls) : (fn : Function) → fn.type.meaning
  | .letter => calls.letter | .identifierCharacter => calls.identifierCharacter
  | .equalName => fun text => calls.equalName text.bytes | .isEmpty => calls.isEmpty
  | .isIdentifier => calls.isIdentifier | .validName => calls.validName | .inUnit => calls.inUnit
  | .sameName => calls.sameName | .within => calls.within | .validMetadata => calls.validMetadata
  | .exportLookup => calls.exportLookupModel | .stateLookup => calls.stateLookupModel | .routineLookup => calls.routineLookupModel

inductive Field : Ty → Ty → Type
  | nameFirst : Field .name .number
  | nameAfter : Field .name .number
  | unitFirst : Field .unitSpan .number
  | unitAfter : Field .unitSpan .number
  | exportName : Field .exportItem .name
  | exportKind : Field .exportItem .exportKind
  | exportTypeName : Field .exportItem .name
  | exportTypeIdentity : Field .exportItem .number
  | exportInitializerFirst : Field .exportItem .number
  | exportInitializerAfter : Field .exportItem .number
  | stateName : Field .state .name
  | stateKind : Field .state .scalarKind
  | stateTypeName : Field .state .name
  | stateTypeIdentity : Field .state .number
  | stateInitializerFirst : Field .state .number
  | stateInitializerAfter : Field .state .number
  | exportBounds : Field .exportItem .interval
  | exportBooleanValue : Field .exportItem .truth
  | stateDeclaredBounds : Field .state .interval
  | stateInitialBounds : Field .state .interval
  | stateBooleanInitial : Field .state .truth
  | lower : Field .interval .integer
  | upper : Field .interval .integer
  | formalSpecName : Field .formal .name
  | formalBodyName : Field .formal .name
  | formalSpecTypeName : Field .formal .name
  | formalBodyTypeName : Field .formal .name
  | formalKind : Field .formal .scalarKind
  | formalBounds : Field .formal .interval
  | formalTypeIdentity : Field .formal .number
  | formalMode : Field .formal .mode
  | routineKind : Field .routine .routineKind
  | routineSpecName : Field .routine .name
  | routineBodyName : Field .routine .name
  | routineSpecFirst : Field .routine .number
  | routineSpecAfter : Field .routine .number
  | routineBodyFirst : Field .routine .number
  | routineBodyAfter : Field .routine .number
  | routineFormalFirst : Field .routine .number
  | routineFormalCount : Field .routine .number
  | routineResultKind : Field .routine .scalarKind
  | routineResultBounds : Field .routine .interval
  | routineResultTypeIdentity : Field .routine .number
  | routineSpecResultName : Field .routine .name
  | routineBodyResultName : Field .routine .name
  | routineMayRead : Field .routine .set
  | routineMayWrite : Field .routine .set
  | routineAssigned : Field .routine .truth
  | packageNameFirst : Field .metadata .number
  | packageNameAfter : Field .metadata .number
  | bodyNameFirst : Field .metadata .number
  | bodyNameAfter : Field .metadata .number
  | exportCount : Field .metadata .number
  | stateCount : Field .metadata .number
  | routineCount : Field .metadata .number
  | completed : Field .metadata .number
  | parameterCount : Field .metadata .number
  | assigned : Field .metadata .truth

def Field.name : Field a b → String
  | .nameFirst => "first"
  | .nameAfter => "after"
  | .unitFirst => "first"
  | .unitAfter => "after"
  | .exportName => "name"
  | .exportKind => "kind"
  | .exportTypeName => "type_name"
  | .exportTypeIdentity => "type_identity"
  | .exportInitializerFirst => "initializer_first"
  | .exportInitializerAfter => "initializer_after"
  | .stateName => "name"
  | .stateKind => "kind"
  | .stateTypeName => "type_name"
  | .stateTypeIdentity => "type_identity"
  | .stateInitializerFirst => "initializer_first"
  | .stateInitializerAfter => "initializer_after"
  | .exportBounds => "bounds"
  | .exportBooleanValue => "boolean_value"
  | .stateDeclaredBounds => "declared_bounds"
  | .stateInitialBounds => "initial_bounds"
  | .stateBooleanInitial => "boolean_initial"
  | .lower => "lower"
  | .upper => "upper"
  | .formalSpecName => "spec_name"
  | .formalBodyName => "body_name"
  | .formalSpecTypeName => "spec_type_name"
  | .formalBodyTypeName => "body_type_name"
  | .formalKind => "kind"
  | .formalBounds => "bounds"
  | .formalTypeIdentity => "type_identity"
  | .formalMode => "mode"
  | .routineKind => "kind"
  | .routineSpecName => "spec_name"
  | .routineBodyName => "body_name"
  | .routineSpecFirst => "spec_first"
  | .routineSpecAfter => "spec_after"
  | .routineBodyFirst => "body_first"
  | .routineBodyAfter => "body_after"
  | .routineFormalFirst => "formal_first"
  | .routineFormalCount => "count"
  | .routineResultKind => "result_kind"
  | .routineResultBounds => "result_bounds"
  | .routineResultTypeIdentity => "result_type_identity"
  | .routineSpecResultName => "spec_result_name"
  | .routineBodyResultName => "body_result_name"
  | .routineMayRead => "may_read"
  | .routineMayWrite => "may_write"
  | .routineAssigned => "assigned"
  | .packageNameFirst => "name_first"
  | .packageNameAfter => "name_after"
  | .bodyNameFirst => "body_name_first"
  | .bodyNameAfter => "body_name_after"
  | .exportCount => "export_count"
  | .stateCount => "state_count"
  | .routineCount => "routine_count"
  | .completed => "completed"
  | .parameterCount => "parameter_count"
  | .assigned => "assigned"

def Field.get : Field a b → a.meaning → b.meaning
  | .nameFirst, value => value.first
  | .nameAfter, value => value.after
  | .unitFirst, value => value.first
  | .unitAfter, value => value.after
  | .exportName, value => value.name
  | .exportKind, value => value.kind
  | .exportTypeName, value => value.typeName
  | .exportTypeIdentity, value => value.typeIdentity
  | .exportInitializerFirst, value => value.initializerFirst
  | .exportInitializerAfter, value => value.initializerAfter
  | .stateName, value => value.name
  | .stateKind, value => value.kind
  | .stateTypeName, value => value.typeName
  | .stateTypeIdentity, value => value.typeIdentity
  | .stateInitializerFirst, value => value.initializerFirst
  | .stateInitializerAfter, value => value.initializerAfter
  | .exportBounds, value => value.bounds
  | .exportBooleanValue, value => value.booleanValue
  | .stateDeclaredBounds, value => value.declaredBounds
  | .stateInitialBounds, value => value.initialBounds
  | .stateBooleanInitial, value => value.booleanInitial
  | .lower, value => value.lower
  | .upper, value => value.upper
  | .formalSpecName, value => value.specName
  | .formalBodyName, value => value.bodyName
  | .formalSpecTypeName, value => value.specTypeName
  | .formalBodyTypeName, value => value.bodyTypeName
  | .formalKind, value => value.kind
  | .formalBounds, value => value.bounds
  | .formalTypeIdentity, value => value.typeIdentity
  | .formalMode, value => value.mode
  | .routineKind, value => value.kind
  | .routineSpecName, value => value.specName
  | .routineBodyName, value => value.bodyName
  | .routineSpecFirst, value => value.specFirst
  | .routineSpecAfter, value => value.specAfter
  | .routineBodyFirst, value => value.bodyFirst
  | .routineBodyAfter, value => value.bodyAfter
  | .routineFormalFirst, value => value.formalFirst
  | .routineFormalCount, value => value.count
  | .routineResultKind, value => value.resultKind
  | .routineResultBounds, value => value.resultBounds
  | .routineResultTypeIdentity, value => value.resultTypeIdentity
  | .routineSpecResultName, value => value.specResultName
  | .routineBodyResultName, value => value.bodyResultName
  | .routineMayRead, value => value.mayRead
  | .routineMayWrite, value => value.mayWrite
  | .routineAssigned, value => value.assigned
  | .packageNameFirst, value => value.nameFirst
  | .packageNameAfter, value => value.nameAfter
  | .bodyNameFirst, value => value.bodyNameFirst
  | .bodyNameAfter, value => value.bodyNameAfter
  | .exportCount, value => value.exports.length
  | .stateCount, value => value.states.length
  | .routineCount, value => value.routines.length
  | .completed, value => value.completed
  | .parameterCount, value => value.parameters.length
  | .assigned, value => value.assigned

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | unitKind (kind : UnitKind) : Expr .unitKind
  | unit : Expr .metadata → Expr .unitKind → Expr .unitSpan
  | exportAt : Expr .metadata → Expr .number → Expr .exportItem
  | state : Expr .metadata → Expr .number → Expr .state
  | routine : Expr .metadata → Expr .number → Expr .routine
  | formal : Expr .metadata → Expr .number → Expr .formal
  | bit : Expr .set → Expr .number → Expr .truth
  | sourceFirst : Expr .source → Expr .integer
  | sourceLast : Expr .source → Expr .integer
  | sourceLength : Expr .source → Expr .number
  | byte : Expr .source → Expr .integer → Expr .number
  | slice : Expr .source → Expr .number → Expr .number → Expr .source
  | toInteger : Expr .number → Expr .integer
  | name : Expr .number → Expr .number → Expr .name
  | character (value : String) (code : Nat) : Expr .number
  | maxLength : Expr .number
  | integerSubtype : Expr .exportKind
  | functionRoutine : Expr .routineKind
  | emptySet : Expr .set
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | intAdd : Expr .integer → Expr .integer → Expr .integer
  | intSub : Expr .integer → Expr .integer → Expr .integer
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | ge : Expr .number → Expr .number → Expr .truth
  | intEq : Expr .integer → Expr .integer → Expr .truth
  | intGt : Expr .integer → Expr .integer → Expr .truth
  | intLe : Expr .integer → Expr .integer → Expr .truth
  | intGe : Expr .integer → Expr .integer → Expr .truth
  | exportKindEq : Expr .exportKind → Expr .exportKind → Expr .truth
  | routineKindEq : Expr .routineKind → Expr .routineKind → Expr .truth
  | setEq : Expr .set → Expr .set → Expr .truth
  | inRange : Expr .number → Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | or : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | guarded : Expr .truth → Expr .truth → Expr .truth
  | all (name : String) : Expr .number → Expr .number → Expr .truth → Expr .truth
  | allSource (name : String) : Expr .source → Expr .truth → Expr .truth
  | allStates (name : String) : Expr .truth → Expr .truth
  | setAggregate (name : String) : Expr .truth → Expr .set

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .variable key => [key] | .function fn => fn.name
  | .app fn arg => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ arg.render ++ [")"]
    | _ => fn.render ++ ["("] ++ arg.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .unitKind kind => ["units", ".", ApplicationUnits.Native.kindName kind]
  | .unit info kind => info.render ++ [".", "units", "("] ++ kind.render ++ [")"]
  | .exportAt info index => info.render ++ [".", "exports", "("] ++ index.render ++ [")"]
  | .state info index => info.render ++ [".", "states", "("] ++ index.render ++ [")"]
  | .routine info index => info.render ++ [".", "routines", "("] ++ index.render ++ [")"]
  | .formal info index => info.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .bit set index => set.render ++ ["("] ++ index.render ++ [")"]
  | .sourceFirst value => value.render ++ ["'", "first"]
  | .sourceLast value => value.render ++ ["'", "last"]
  | .sourceLength value => value.render ++ ["'", "length"]
  | .byte value index => value.render ++ ["("] ++ index.render ++ [")"]
  | .slice value first last => value.render ++ ["("] ++ first.render ++ [".."] ++ last.render ++ [")"]
  | .toInteger value => value.render
  | .name first after => ["("] ++ first.render ++ [","] ++ after.render ++ [")"]
  | .character value _ => ["'" ++ value ++ "'"]
  | .maxLength => ["max_source_length"] | .integerSubtype => ["integer_subtype"]
  | .functionRoutine => ["function_routine"] | .emptySet => ["empty_state_set"]
  | .add a b | .intAdd a b => a.render ++ ["+"] ++ b.render
  | .sub a b | .intSub a b => a.render ++ ["-"] ++ b.render
  | .eq a b | .intEq a b | .exportKindEq a b | .routineKindEq a b | .setEq a b => a.render ++ ["="] ++ b.render
  | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .gt a b | .intGt a b => a.render ++ [">"] ++ b.render
  | .le a b | .intLe a b => a.render ++ ["<="] ++ b.render
  | .ge a b | .intGe a b => a.render ++ [">="] ++ b.render
  | .inRange a b c => a.render ++ ["in"] ++ b.render ++ [".."] ++ c.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render | .or a b => a.render ++ ["or"] ++ b.render
  | .not value => ["not"] ++ value.render | .group value => ["("] ++ value.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .guarded c a => ["if"] ++ c.render ++ ["then"] ++ a.render
  | .all binder first last body => ["for", "all", binder, "in"] ++ first.render ++ [".."] ++ last.render ++ ["=>"] ++ body.render
  | .allSource binder source body => ["for", "all", binder, "in"] ++ source.render ++ ["'", "range", "=>"] ++ body.render
  | .allStates binder body => ["for", "all", binder, "in", "state_index", "=>"] ++ body.render
  | .setAggregate binder body => ["for", binder, "in", "state_index", "=>"] ++ body.render

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .variable key => locals _ key | .function fn => calls.get fn
  | .app fn arg => fn.eval calls locals (arg.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .unitKind kind => kind | .unit info kind => (info.eval calls locals).units (kind.eval calls locals)
  | .exportAt info index => (info.eval calls locals).exportAt (index.eval calls locals)
  | .state info index => (info.eval calls locals).stateAt (index.eval calls locals)
  | .routine info index => (info.eval calls locals).routineAt (index.eval calls locals)
  | .formal info index => (info.eval calls locals).parameterAt (index.eval calls locals)
  | .bit set index => StateSet.get (set.eval calls locals) (index.eval calls locals)
  | .sourceFirst source => (source.eval calls locals).first
  | .sourceLast source => (source.eval calls locals).last
  | .sourceLength source => (source.eval calls locals).bytes.length
  | .byte source index => let value := source.eval calls locals
      value.bytes.getD ((index.eval calls locals) - value.first).toNat 0
  | .slice source first last => (source.eval calls locals).slice (first.eval calls locals) (last.eval calls locals)
  | .toInteger value => Int.ofNat (value.eval calls locals)
  | .name first after => ⟨first.eval calls locals, after.eval calls locals⟩
  | .character _ code => code | .maxLength => maxSourceLength | .integerSubtype => .integerSubtype
  | .functionRoutine => .function | .emptySet => emptyStateSet
  | .add a b => a.eval calls locals + b.eval calls locals | .sub a b => a.eval calls locals - b.eval calls locals
  | .intAdd a b => a.eval calls locals + b.eval calls locals | .intSub a b => a.eval calls locals - b.eval calls locals
  | .eq a b => decide (a.eval calls locals = b.eval calls locals) | .ne a b => decide (a.eval calls locals ≠ b.eval calls locals)
  | .lt a b => decide (a.eval calls locals < b.eval calls locals) | .gt a b => decide (a.eval calls locals > b.eval calls locals)
  | .le a b => decide (a.eval calls locals ≤ b.eval calls locals) | .ge a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .intEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .intGt a b => decide (a.eval calls locals > b.eval calls locals)
  | .intLe a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .intGe a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .exportKindEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .routineKindEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .setEq a b => decide (a.eval calls locals = b.eval calls locals)
  | .inRange a b c => decide (b.eval calls locals ≤ a.eval calls locals ∧ a.eval calls locals ≤ c.eval calls locals)
  | .andThen a b => a.eval calls locals && b.eval calls locals | .or a b => a.eval calls locals || b.eval calls locals
  | .not value => !(value.eval calls locals) | .group value => value.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .guarded c a => if c.eval calls locals then a.eval calls locals else true
  | .all binder first last body =>
      (List.range (last.eval calls locals + 1 - first.eval calls locals)).all fun index =>
        body.eval calls (locals.set .number binder (first.eval calls locals + index))
  | .allSource binder source body => let value := source.eval calls locals
      (List.range value.bytes.length).all fun index => body.eval calls (locals.set .integer binder (value.first + index))
  | .allStates binder body => (List.range maxStates).all fun index => body.eval calls (locals.set .number binder (index + 1))
  | .setAggregate binder body => (List.range maxStates).map fun index => body.eval calls (locals.set .number binder (index + 1))

structure Context where
  text : Text := ⟨1, []⟩
  sourceName : Text := ⟨1, []⟩
  name : NameSpan := {}
  left : NameSpan := {}
  right : NameSpan := {}
  unit : UnitSpan := ⟨1,1⟩
  leftSet : StateSet := emptyStateSet
  rightSet : StateSet := emptyStateSet
  effect : StateSet := emptyStateSet
  count : Nat := 0
  info : Metadata := {}
  limit : Nat := 0

def Context.locals (context : Context) : Locals
  | .source, "text" => context.text | .source, "name" => context.sourceName
  | .name, "name" => context.name | .name, "left" => context.left | .name, "right" => context.right
  | .unitSpan, "unit" => context.unit
  | .set, "left" => context.leftSet | .set, "right" => context.rightSet | .set, "effect" => context.effect
  | .number, "count" => context.count | .number, "limit" => context.limit
  | .metadata, "info" => context.info | ty, _ => ty.default

def apply2 (fn : Expr (.arrow a (.arrow b c))) (x : Expr a) (y : Expr b) : Expr c := .app (.app fn x) y
def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (x : Expr a) (y : Expr b) (z : Expr c) : Expr d :=
  .app (apply2 fn x y) z
def apply4 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : Expr a) (x : Expr b) (y : Expr c) (z : Expr d) : Expr e := .app (apply3 fn w x y) z

def conjunction (first : Expr .truth) (rest : List (Expr .truth)) : Expr .truth := rest.foldl .andThen first

def isIdentifierBody : Expr .truth :=
  let name : Expr .source := .variable "name"
  let i : Expr .integer := .variable "i"
  let underscore := Expr.character "_" 95
  conjunction (.inRange (.sourceLength name) (.number 1) .maxLength)
    [.app (.function .letter) (.byte name (.sourceFirst name)),
     .ne (.byte name (.sourceLast name)) underscore,
     .group <| .allSource "i" name <| .andThen
       (.app (.function .identifierCharacter) (.byte name i))
       (.group <| .guarded (.eq (.byte name i) underscore)
         (.andThen (.intGt i (.sourceFirst name))
           (.ne (.byte name (.intSub i (.toInteger (.number 1)))) underscore)))]

def validNameBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let name : Expr .name := .variable "name"
  conjunction (.intEq (.sourceFirst text) (.toInteger (.number 1)))
    [.inRange (.sourceLength text) (.number 1) .maxLength,
     .gt (.field .nameFirst name) (.number 0), .lt (.field .nameFirst name) (.field .nameAfter name),
     .intLe (.toInteger (.field .nameAfter name)) (.intAdd (.sourceLast text) (.toInteger (.number 1))),
     .app (.function .isIdentifier) (.slice text (.field .nameFirst name) (.sub (.field .nameAfter name) (.number 1)))]

def inUnitBody : Expr .truth :=
  let name : Expr .name := .variable "name"
  let unit : Expr .unitSpan := .variable "unit"
  conjunction (.ge (.field .nameFirst name) (.field .unitFirst unit))
    [.lt (.field .nameFirst name) (.field .nameAfter name), .le (.field .nameAfter name) (.field .unitAfter unit)]

def sameNameBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let left : Expr .name := .variable "left"
  let right : Expr .name := .variable "right"
  conjunction (apply2 (.function .validName) text left)
    [apply2 (.function .validName) text right,
     .app (apply4 (.function .equalName) text (.field .nameFirst left) (.field .nameAfter left)
       (.field .nameFirst right)) (.field .nameAfter right)]

def unionBody : Expr .set := .setAggregate "i" <| .or
  (.bit (.variable "left") (.variable "i")) (.bit (.variable "right") (.variable "i"))

def withinBody : Expr .truth := .allStates "i" <| .group <| .guarded
  (.gt (.variable "i") (.variable "count")) (.not (.bit (.variable "effect") (.variable "i")))

def completeMetadataBody : Expr .truth :=
  conjunction (apply2 (.function .validMetadata) (.variable "text") (.variable "info"))
    [.gt (.field .bodyNameFirst (.variable "info")) (.number 0),
     .eq (.field .completed (.variable "info")) (.field .routineCount (.variable "info"))]

def lookupBody (itemName : Expr .metadata → Expr .number → Expr .name)
    (fn : Expr (.arrow .source (.arrow .metadata (.arrow .name (.arrow .number .number))))) : Expr .number :=
  let text : Expr .source := .variable "text"
  let info : Expr .metadata := .variable "info"
  let name : Expr .name := .variable "name"
  let limit : Expr .number := .variable "limit"
  .ite (.eq limit (.number 0)) (.number 0)
    (.elsif (apply3 (.function .sameName) text (itemName info limit) name) limit
      (apply4 fn text info name (.sub limit (.number 1))))

def exportLookupBody : Expr .number := lookupBody
  (fun info index => .field .exportName (.exportAt info index)) (.function .exportLookup)
def stateLookupBody : Expr .number := lookupBody
  (fun info index => .field .stateName (.state info index)) (.function .stateLookup)
def routineLookupBody : Expr .number := lookupBody
  (fun info index => .field .routineSpecName (.routine info index)) (.function .routineLookup)

def validMetadataBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let info : Expr .metadata := .variable "info"
  let i : Expr .number := .variable "i"
  let j : Expr .number := .variable "j"
  let spec := Expr.unit info (.unitKind .packageSpecification)
  let body := Expr.unit info (.unitKind .packageBody)
  let main := Expr.unit info (.unitKind .mainBody)
  let packageName := Expr.name (.field .packageNameFirst info) (.field .packageNameAfter info)
  let bodyName := Expr.name (.field .bodyNameFirst info) (.field .bodyNameAfter info)
  let exportItem := Expr.exportAt info i
  let state := Expr.state info i
  let parameter := Expr.formal info i
  let routine := Expr.routine info i
  let formal := Expr.formal info j
  let nonempty bounds := Expr.not (.app (.function .isEmpty) bounds)
  let valid name := apply2 (.function .validName) text name
  let inside name unit := apply2 (.function .inUnit) name unit
  let same left right := apply3 (.function .sameName) text left right
  let every count first rest := Expr.group (.all "i" (.number 1) count (conjunction first rest))
  conjunction (.intEq (.sourceFirst text) (.toInteger (.number 1)))
    [.inRange (.sourceLength text) (.number 1) .maxLength,
     .eq (.field .unitFirst spec) (.number 1),
     .lt (.field .unitFirst spec) (.field .unitAfter spec),
     .eq (.field .unitFirst body) (.field .unitAfter spec),
     .lt (.field .unitFirst body) (.field .unitAfter body),
     .eq (.field .unitFirst main) (.field .unitAfter body),
     .lt (.field .unitFirst main) (.field .unitAfter main),
     .intEq (.toInteger (.field .unitAfter main)) (.intAdd (.sourceLast text) (.toInteger (.number 1))),
     valid packageName, inside packageName spec,
     .group <| .ite (.eq (.field .bodyNameFirst info) (.number 0))
       (conjunction (.eq (.field .bodyNameAfter info) (.number 0))
         [.eq (.field .stateCount info) (.number 0), .eq (.field .completed info) (.number 0)])
       (.andThen (inside bodyName body) (same packageName bodyName)),
     .le (.field .completed info) (.field .routineCount info),
     every (.field .exportCount info) (valid (.field .exportName exportItem))
       [inside (.field .exportName exportItem) spec, nonempty (.field .exportBounds exportItem),
        .group <| .guarded (.exportKindEq (.field .exportKind exportItem) .integerSubtype)
          (.eq (.field .exportTypeIdentity exportItem) (.add i (.number 1)))],
     every (.field .stateCount info) (valid (.field .stateName state))
       [inside (.field .stateName state) body,
        nonempty (.field .stateDeclaredBounds state), nonempty (.field .stateInitialBounds state),
        .intEq (.field .lower (.field .stateInitialBounds state)) (.field .upper (.field .stateInitialBounds state)),
        .intGe (.field .lower (.field .stateInitialBounds state)) (.field .lower (.field .stateDeclaredBounds state)),
        .intLe (.field .upper (.field .stateInitialBounds state)) (.field .upper (.field .stateDeclaredBounds state)),
        .ge (.field .stateInitializerFirst state) (.field .unitFirst body),
        .lt (.field .stateInitializerFirst state) (.field .stateInitializerAfter state),
        .le (.field .stateInitializerAfter state) (.field .unitAfter body)],
     every (.field .parameterCount info) (valid (.field .formalSpecName parameter))
       [inside (.field .formalSpecName parameter) spec, nonempty (.field .formalBounds parameter)],
     every (.field .routineCount info) (valid (.field .routineSpecName routine))
       [inside (.field .routineSpecName routine) spec,
        .ge (.field .routineSpecFirst routine) (.field .unitFirst spec),
        .le (.field .routineSpecFirst routine) (.field .nameFirst (.field .routineSpecName routine)),
        .lt (.field .nameAfter (.field .routineSpecName routine)) (.field .routineSpecAfter routine),
        .le (.field .routineSpecAfter routine) (.field .unitAfter spec),
        .group <| .ite (.eq (.field .routineFormalCount routine) (.number 0))
          (.eq (.field .routineFormalFirst routine) (.number 0))
          (conjunction (.gt (.field .routineFormalFirst routine) (.number 0))
            [.le (.field .routineFormalFirst routine) (.field .parameterCount info),
             .le (.field .routineFormalCount routine)
               (.add (.sub (.field .parameterCount info) (.field .routineFormalFirst routine)) (.number 1))]),
        apply2 (.function .within) (.field .routineMayRead routine) (.field .stateCount info),
        apply2 (.function .within) (.field .routineMayWrite routine) (.field .stateCount info),
        .group <| .guarded (.routineKindEq (.field .routineKind routine) .functionRoutine)
          (.andThen (nonempty (.field .routineResultBounds routine)) (.setEq (.field .routineMayWrite routine) .emptySet)),
        .group <| .guarded (.le i (.field .completed info))
          (conjunction (inside (.field .routineBodyName routine) body)
            [same (.field .routineSpecName routine) (.field .routineBodyName routine),
             .ge (.field .routineBodyFirst routine) (.field .unitFirst body),
             .le (.field .routineBodyFirst routine) (.field .nameFirst (.field .routineBodyName routine)),
             .lt (.field .nameAfter (.field .routineBodyName routine)) (.field .routineBodyAfter routine),
             .le (.field .routineBodyAfter routine) (.field .unitAfter body),
             .group <| .guarded (.gt (.field .routineFormalCount routine) (.number 0))
               (.group <| .all "j" (.field .routineFormalFirst routine)
                 (.sub (.add (.field .routineFormalFirst routine) (.field .routineFormalCount routine)) (.number 1))
                 (.andThen (inside (.field .formalBodyName formal) body)
                   (same (.field .formalSpecName formal) (.field .formalBodyName formal))))])]]

/-! Precedence checks retain native operator association. Quantifier bodies are
Boolean expressions, and every use in a surrounding expression is grouped. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .variable _ | .function _ | .app _ _ | .field _ _ | .unitKind _
  | .unit _ _ | .exportAt _ _ | .state _ _ | .routine _ _ | .formal _ _ | .bit _ _
  | .sourceFirst _ | .sourceLast _ | .sourceLength _ | .byte _ _ | .slice _ _ _
  | .name _ _ | .character _ _ | .maxLength | .integerSubtype | .functionRoutine
  | .emptySet | .group _ => true
  | .toInteger value => value.primary
  | _ => false

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ | .intAdd _ _ | .intSub _ _ => true
  | .toInteger value => value.simple
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .gt _ _ | .le _ _ | .ge _ _
  | .intEq _ _ | .intGt _ _ | .intLe _ _ | .intGe _ _ | .exportKindEq _ _
  | .routineKindEq _ _ | .setEq _ _ | .inRange _ _ _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr ty → Bool | .andThen _ _ => true | value => value.relation
def Expr.orHead : Expr ty → Bool | .or _ _ => true | value => value.relation
def Expr.condition (value : Expr ty) : Bool := value.andHead || value.orHead
def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.functionSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .app fn arg => fn.wellFormed && fn.functionSpine && arg.wellFormed && arg.simple
  | .field _ value | .sourceFirst value | .sourceLast value | .sourceLength value => value.wellFormed && value.primary
  | .unit a b | .exportAt a b | .state a b | .routine a b | .formal a b | .bit a b | .byte a b =>
      a.wellFormed && a.primary && b.wellFormed && b.simple
  | .slice a b c => a.wellFormed && a.primary && b.wellFormed && b.simple && c.wellFormed && c.simple
  | .toInteger value => value.wellFormed
  | .name a b => a.wellFormed && a.simple && b.wellFormed && b.simple
  | .character value code => value.toList.length == 1 && (value.toList.headD ' ').toNat == code
  | .add a b | .sub a b | .intAdd a b | .intSub a b => a.wellFormed && b.wellFormed && a.simple && b.primary
  | .eq a b | .ne a b | .lt a b | .gt a b | .le a b | .ge a b | .intEq a b | .intGt a b
  | .intLe a b | .intGe a b | .exportKindEq a b | .routineKindEq a b | .setEq a b =>
      a.wellFormed && b.wellFormed && a.simple && b.simple
  | .inRange a b c => a.wellFormed && a.simple && b.wellFormed && b.simple && c.wellFormed && c.simple
  | .andThen a b => a.wellFormed && a.andHead && b.wellFormed && b.relation
  | .or a b => a.wellFormed && a.orHead && b.wellFormed && b.relation
  | .not value => value.wellFormed && value.primary
  | .group value => value.wellFormed && !value.isElsif
  | .ite c a b | .elsif c a b => c.wellFormed && c.condition && a.wellFormed &&
      (a.simple || a.condition) && b.wellFormed && (b.simple || b.condition || b.isElsif)
  | .guarded c a => c.wellFormed && c.condition && a.wellFormed && a.condition
  | .all _ first last body => first.wellFormed && first.simple && last.wellFormed && last.simple &&
      body.wellFormed && body.condition
  | .allSource _ source body => source.wellFormed && source.primary && body.wellFormed && body.condition
  | .allStates _ body | .setAggregate _ body => body.wellFormed && body.condition
  | _ => true

abbrev Scope := List (String × Ty)

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  ((scope.find? (fun entry => entry.1 == name)).map Prod.snd) == some ty

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .variable key => scope.contains key ty
  | .app a b | .unit a b | .exportAt a b | .state a b | .routine a b | .formal a b | .bit a b | .byte a b
  | .name a b | .add a b | .sub a b | .intAdd a b | .intSub a b | .eq a b | .ne a b | .lt a b | .gt a b
  | .le a b | .ge a b | .intEq a b | .intGt a b | .intLe a b | .intGe a b | .exportKindEq a b
  | .routineKindEq a b | .setEq a b | .andThen a b | .or a b | .guarded a b => a.scoped scope && b.scoped scope
  | .field _ a | .sourceFirst a | .sourceLast a | .sourceLength a | .toInteger a | .not a | .group a => a.scoped scope
  | .slice a b c | .inRange a b c | .ite a b c | .elsif a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .all binder first last body => first.scoped scope && last.scoped scope && body.scoped ((binder, .number) :: scope)
  | .allSource binder source body => source.scoped scope && body.scoped ((binder, .integer) :: scope)
  | .allStates binder body | .setAggregate binder body => body.scoped ((binder, .number) :: scope)
  | _ => true

abbrev CheckedTrees : Prop :=
  isIdentifierBody.wellFormed = true ∧ isIdentifierBody.scoped [("name", .source)] = true ∧
  validNameBody.wellFormed = true ∧ validNameBody.scoped [("text", .source), ("name", .name)] = true ∧
  inUnitBody.wellFormed = true ∧ inUnitBody.scoped [("name", .name), ("unit", .unitSpan)] = true ∧
  sameNameBody.wellFormed = true ∧ sameNameBody.scoped [("text", .source), ("left", .name), ("right", .name)] = true ∧
  unionBody.wellFormed = true ∧ unionBody.scoped [("left", .set), ("right", .set)] = true ∧
  withinBody.wellFormed = true ∧ withinBody.scoped [("effect", .set), ("count", .number)] = true ∧
  completeMetadataBody.wellFormed = true ∧ completeMetadataBody.scoped [("text", .source), ("info", .metadata)] = true ∧
  validMetadataBody.wellFormed = true ∧ validMetadataBody.scoped [("text", .source), ("info", .metadata)] = true ∧
  exportLookupBody.wellFormed = true ∧ exportLookupBody.scoped [("text", .source), ("info", .metadata), ("name", .name), ("limit", .number)] = true ∧
  stateLookupBody.wellFormed = true ∧ stateLookupBody.scoped [("text", .source), ("info", .metadata), ("name", .name), ("limit", .number)] = true ∧
  routineLookupBody.wellFormed = true ∧ routineLookupBody.scoped [("text", .source), ("info", .metadata), ("name", .name), ("limit", .number)] = true

theorem checked_trees : CheckedTrees := by decide +kernel

end Silver.PackageBindings.Native
