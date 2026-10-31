module

public import Silver.ComposeExpressions
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Typed ordinary Ada blocks for the String and Character helpers. Assignment,
branching, early return and named final Boolean arguments have explicit meanings;
the checked whole-body rendering retains declarations and function terminators. -/
namespace Silver.Compose.StringNative
open Silver.Compose.Expressions

structure Declaration where
  type : Ty
  names : List String
  typeName : List String
  initial : Option (Expr type) := none

def Declaration.render (declaration : Declaration) : List String :=
  List.flatten (declaration.names.map (fun name => [name]) |>.intersperse [","]) ++
  [":"] ++ (if declaration.initial.isSome then ["constant"] else []) ++ declaration.typeName ++
  (match declaration.initial with | some value => [":="] ++ value.render | none => []) ++ [";"]

def Declaration.eval (calls : Calls) (locals : Locals) (declaration : Declaration) : Locals :=
  let value := match declaration.initial with
    | some expression => expression.eval calls locals
    | none => declaration.type.default
  declaration.names.foldl (fun result name => result.set declaration.type name value) locals

inductive Command (resultType : Ty)
  | nothing
  | assign (name : String) : Expr type → Command resultType
  | assignAfter (name : String) : Expr .number → Command resultType
  | sequence : Command resultType → Command resultType → Command resultType
  | choose : Expr .truth → Command resultType → Command resultType → Command resultType
  | returned : Expr resultType → Command resultType
  | returnNamedBoolean : Expr (.arrow .truth resultType) → String → Expr .truth → Command resultType

def Command.eval (calls : Calls) (locals : Locals) (next : Locals → resultType.meaning) :
    Command resultType → resultType.meaning
  | .nothing => next locals
  | .assign name value => next (locals.set _ name (value.eval calls locals))
  | .assignAfter name after =>
      next (locals.set .value name {(locals .value name) with after := after.eval calls locals})
  | .sequence first rest => first.eval calls locals (fun updated => rest.eval calls updated next)
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next else no.eval calls locals next
  | .returned value => value.eval calls locals
  | .returnNamedBoolean function _ argument => function.eval calls locals (argument.eval calls locals)

mutual
  def Command.render : Command resultType → List String
    | .nothing => []
    | .assign name value => [name, ":="] ++ value.render ++ [";"]
    | .assignAfter name after => [name, ".", "after", ":="] ++ after.render ++ [";"]
    | .sequence first rest => first.render ++ rest.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .returned value => ["return"] ++ value.render ++ [";"]
    | .returnNamedBoolean function name argument =>
        ["return"] ++ function.render.dropLast ++ [",", name, "=>"] ++ argument.render ++ [")", ";"]

  def Command.renderElse : Command resultType → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List (Command resultType)) : Command resultType := commands.foldr .sequence .nothing

def guard (test : Expr .truth) (failure : Expr resultType) : Command resultType :=
  .choose test (.returned failure) .nothing

structure Body (resultType : Ty) where
  name : String
  declarations : List Declaration
  commands : Command resultType

def Body.render (body : Body resultType) : List String :=
  body.declarations.flatMap Declaration.render ++ ["begin"] ++ body.commands.render ++ ["end", body.name, ";"]

def Body.eval (body : Body resultType) (calls : Calls) (locals : Locals) : resultType.meaning :=
  body.commands.eval calls (body.declarations.foldl (Declaration.eval calls) locals) (fun _ => resultType.default)

def Declaration.validType : Ty → List String → Bool
  | .number, name => decide (name ∈ [["literal_position"], ["binding_count"], ["capacity_value"]])
  | .integer, name => name == ["scalars", ".", "wide"]
  | .interval, name => name == ["scalars", ".", "interval"]
  | .scalarResult, name => name == ["scalar_expressions", ".", "expression_result"]
  | .value, name => name == ["value_result"]
  | _, _ => false

def Declaration.wellFormed (declaration : Declaration) : Bool :=
  !declaration.names.isEmpty && Declaration.validType declaration.type declaration.typeName &&
    (match declaration.initial with
      | some value => value.wellFormed && value.expression
      | none => true)

def Declaration.scoped (scope : Scope) (declaration : Declaration) : Bool :=
  match declaration.initial with | some value => value.scoped scope | none => true

def Declaration.scope (scope : Scope) (declaration : Declaration) : Scope :=
  declaration.names.map (fun name => (name, declaration.type)) ++ scope

def Command.wellFormed : Command resultType → Bool
  | .nothing => true
  | .assign _ value => value.wellFormed && value.expression
  | .assignAfter _ after => after.wellFormed && after.expression
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.wellFormed && test.logical && yes.wellFormed && no.wellFormed
  | .returned value => value.wellFormed && value.expression
  | .returnNamedBoolean function name argument =>
      function.wellFormed && function.functionSpine && argument.wellFormed && argument.expression &&
        decide (name ∈ ["character_element", "character_object"])

def Command.scoped (scope : Scope) : Command resultType → Bool
  | .nothing => true
  | .assign (type := type) name value => scope.contains name type && value.scoped scope
  | .assignAfter name after => scope.contains name .value && after.scoped scope
  | .sequence first rest => first.scoped scope && rest.scoped scope
  | .choose test yes no => test.scoped scope && yes.scoped scope && no.scoped scope
  | .returned value => value.scoped scope
  | .returnNamedBoolean function _ argument => function.scoped scope && argument.scoped scope

def Body.wellFormed (body : Body resultType) : Bool :=
  body.declarations.all Declaration.wellFormed && body.commands.wellFormed

def Body.scoped (scope : Scope) (body : Body resultType) : Bool :=
  let scanned := body.declarations.foldl (fun (result : Bool × Scope) declaration =>
    (result.1 && declaration.scoped result.2, declaration.scope result.2)) (true, scope)
  scanned.1 && body.commands.scoped scanned.2

def constant (type : Ty) (name : String) (typeName : List String) (value : Expr type) : Declaration :=
  ⟨type, [name], typeName, some value⟩

def uninitialized (type : Ty) (names : List String) (typeName : List String) : Declaration :=
  ⟨type, names, typeName, none⟩

def concatenatedLastBody : Body .interval :=
  let left : Expr .scan := .variable "left"
  let right : Expr .value := .variable "right"
  let first : Expr .interval := .variable "first"
  let minimum : Expr .integer := .variable "minimum"
  let maximum : Expr .integer := .variable "maximum"
  let low : Expr .integer := .variable "low"
  let high : Expr .integer := .variable "high"
  let result : Expr .interval := .variable "result"
  ⟨"concatenated_last", [
    constant .interval "first" ["scalars", ".", "interval"]
      (.app (.app (.function .concatenatedFirst) left) right),
    constant .integer "minimum" ["scalars", ".", "wide"]
      (.integerAdd (.wideNumber (.field .scanMinimum left)) (.wideNumber (.field .valueMinimum right))),
    constant .integer "maximum" ["scalars", ".", "wide"]
      (.integerAdd (.integerAdd (.wideNumber (.field .scanLength left)) (.wideNumber (.field .valueLength right)))
        (.integerMul (.group <| .integerAdd (.wideNumber (.field .scanDynamic left))
          (.group <| .ite (.field .valueDynamic right) (.integerNumber 1) (.integerNumber 0)))
          (.wideNumber .maxLength))),
    constant .integer "low" ["scalars", ".", "wide"]
      (.integerSub (.integerAdd (.wideInteger (.field .intervalLower first)) minimum) (.integerNumber 1)),
    constant .integer "high" ["scalars", ".", "wide"]
      (.integerSub (.integerAdd (.wideInteger (.field .intervalUpper first)) maximum) (.integerNumber 1)),
    uninitialized .interval ["result"] ["scalars", ".", "interval"]],
    .list [
      guard (.orElse (.eq (.field .scanOperands left) (.number 0))
        (.group <| .andThen (.eq (.field .scanLength left) (.number 0)) (.eq (.field .scanDynamic left) (.number 0))))
        (.field .valueLastIndex right),
      guard (.orElse (.orElse (.orElse (.orElse
        (.app (.function .scalarEmpty) first) (.integerLt low .minimumInteger))
        (.integerGt low .maximumInteger)) (.integerLt high .minimumInteger)) (.integerGt high .maximumInteger))
        .emptyInterval,
      .assign "result" (.interval (.valueInteger low) (.valueInteger high)),
      .choose (.integerEq minimum (.integerNumber 0))
        (.assign "result" (.joinInterval result (.field .valueLastIndex right))) .nothing,
      .returned result]⟩

def anyOf : List (Expr .truth) → Expr .truth
  | [] => .truth false
  | first :: rest => rest.foldl .orElse first

def allOf : List (Expr .truth) → Expr .truth
  | [] => .truth true
  | first :: rest => rest.foldl .andThen first

def indexedBody : Body .value :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let names : Expr .names := .variable "names"
  let scalarNames : Expr .scalarNames := .variable "scalar_names"
  let arrays : Expr .arrayMetadata := .variable "arrays"
  let initials : Expr .arrayInitials := .variable "initials"
  let elaborating : Expr .truth := .variable "elaborating"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let target : Expr .number := .variable "target"
  let low : Expr .scalarResult := .variable "low"
  let high : Expr .scalarResult := .variable "high"
  let following : Expr .number := .variable "following"
  let minimum : Expr .integer := .variable "minimum"
  let maximum : Expr .integer := .variable "maximum"
  let info := Expr.item names target
  let bounds (value : Expr .scalarResult) := Expr.field .scalarBounds value
  let lower (value : Expr .scalarResult) := Expr.field .intervalLower (bounds value)
  let upper (value : Expr .scalarResult) := Expr.field .intervalUpper (bounds value)
  let operands := Expr.add (.field .scalarOperands low) (.field .scalarOperands high)
  let take (p : Expr .number) (token : ShellToken) :=
    Expr.app (.app (.app (.function .takeToken) text) p) (.token token)
  ⟨"indexed_at", [
    constant .number "first" ["literal_position"] (.app (.app (.function .skip) text) position),
    constant .number "after" ["literal_position"] (.app (.app (.function .nameAfter) text) first),
    constant .number "target" ["binding_count"] (.app (.app (.app (.app (.function .lookupName) text) names) first) after),
    constant .scalarResult "low" ["scalar_expressions", ".", "expression_result"]
      (.scalarReadArrays text (take after (.symbol "(")) scalarNames arrays initials elaborating),
    uninitialized .scalarResult ["high"] ["scalar_expressions", ".", "expression_result"],
    uninitialized .number ["following"] ["literal_position"],
    uninitialized .integer ["minimum", "maximum"] ["scalars", ".", "wide"]],
    .list [
      guard (anyOf [
        .eq target (.number 0), .field .bindingCharacter info, .field .bindingDynamic info,
        .ne (.app (.app (.app (.app (.function .scalarLookup) text) scalarNames) first) after) (.number 0),
        .eq (.field .scalarAfter low) (.number 0), .app (.function .scalarEmpty) (bounds low)]) .invalidValue,
      .choose (.variable "character_element") (.list [
        .assign "following" (take (.field .scalarAfter low) (.symbol ")")),
        guard (anyOf [
          .le following position, .eq (.field .scalarOperands low) .maxOperands,
          .integerLt (lower low) (.field .bindingFirstIndex info),
          .integerGt (upper low) (.field .bindingLastIndex info)]) .invalidValue,
        .returned (.nativeValue following (.number 0) (.number 1) (.number 1)
          (.truth false) (.truth true) (.truth false) target
          (.add (.field .scalarOperands low) (.number 1))
          (.singleton (.integerNumber 1)) (.singleton (.integerNumber 1)))]) .nothing,
      .assign "high" (.scalarReadArrays text (take (.field .scalarAfter low) (.symbol ".."))
        scalarNames arrays initials elaborating),
      .assign "following" (take (.field .scalarAfter high) (.symbol ")")),
      guard (anyOf [
        .le following position, .app (.function .scalarEmpty) (bounds high), .ge operands .maxOperands,
        .group <| .andThen (.integerLe (lower low) (upper high))
          (.group <| .orElse (.integerLt (lower low) (.field .bindingFirstIndex info))
            (.integerGt (upper high) (.field .bindingLastIndex info)))]) .invalidValue,
      .assign "minimum" (.wideMaximum (.integerNumber 0)
        (.integerAdd (.integerSub (.wideInteger (lower high)) (.wideInteger (upper low))) (.integerNumber 1))),
      .assign "maximum" (.wideMaximum (.integerNumber 0)
        (.integerAdd (.integerSub (.wideInteger (upper high)) (.wideInteger (lower low))) (.integerNumber 1))),
      guard (.integerGt maximum (.wideNumber .maxLength)) .invalidValue,
      .returned (.nativeValue following (.number 0) (.capacityInteger minimum) (.capacityInteger maximum)
        (.truth false) (.truth true) (.truth false) target (.add operands (.number 1)) (bounds low) (bounds high))]⟩

def characterBody : Body .value :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let names : Expr .names := .variable "names"
  let scalarNames : Expr .scalarNames := .variable "scalar_names"
  let arrays : Expr .arrayMetadata := .variable "arrays"
  let initials : Expr .arrayInitials := .variable "initials"
  let elaborating : Expr .truth := .variable "elaborating"
  let first : Expr .number := .variable "first"
  let quoted : Expr .number := .variable "quoted"
  let after : Expr .number := .variable "after"
  let target : Expr .number := .variable "target"
  let openAfter : Expr .number := .variable "open_after"
  let value : Expr .value := .variable "value"
  let take (p : Expr .number) (token : ShellToken) :=
    Expr.app (.app (.app (.function .takeToken) text) p) (.token token)
  let indexed := Expr.app (.app (.app (.app (.app (.app (.app (.function .indexed) text)
    position) names) scalarNames) arrays) initials) elaborating
  ⟨"character_at", [
    constant .number "first" ["literal_position"] (.app (.app (.function .skip) text) position),
    constant .number "quoted" ["literal_position"] (.app (.app (.function .characterLiteral) text) first),
    constant .number "after" ["literal_position"] (.app (.app (.function .nameAfter) text) first),
    constant .number "target" ["binding_count"] (.app (.app (.app (.app (.function .lookupName) text) names) first) after),
    constant .number "open_after" ["literal_position"] (take first (.symbol "(")),
    uninitialized .value ["value"] ["value_result"]],
    .choose (.ne openAfter (.number 0)) (.list [
      .assign "value" (.app (.app (.app (.app (.app (.app (.app (.function .characterValue) text)
        openAfter) names) scalarNames) arrays) initials) elaborating),
      .assignAfter "value" (take (.field .valueAfter value) (.symbol ")")),
      .returned value]) <|
    .choose (.ne quoted (.number 0))
      (.returned (.nativeValue quoted (.number 0) (.number 1) (.number 1)
        (.truth false) (.truth false) (.truth false) (.number 0) (.number 1)
        (.singleton (.integerNumber 1)) (.singleton (.integerNumber 1)))) <|
    .choose (allOf [.ne target (.number 0), .field .bindingCharacter (.item names target),
      .eq (.app (.app (.app (.app (.function .scalarLookup) text) scalarNames) first) after) (.number 0)])
      (.returned (.nativeValue after (.number 0) (.number 1) (.number 1)
        (.truth false) (.truth true) (.truth false) target (.number 1)
        (.singleton (.integerNumber 1)) (.singleton (.integerNumber 1))))
      (.returnNamedBoolean indexed "character_element" (.truth true))⟩

def characterDeclarationBody : Body .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let colonAfter : Expr .number := .variable "colon_after"
  let constantAfter : Expr .number := .variable "constant_after"
  let typeFirst : Expr .number := .variable "type_first"
  let typeAfter : Expr .number := .variable "type_after"
  let value : Expr .value := .variable "value"
  let following : Expr .number := .variable "following"
  let take (p : Expr .number) (token : ShellToken) :=
    Expr.app (.app (.app (.function .takeToken) text) p) (.token token)
  let skip (p : Expr .number) := Expr.app (.app (.function .skip) text) p
  let lookup (function : Expr (.arrow .number (.arrow .number .number))) :=
    Expr.ne (.app (.app function typeFirst) typeAfter) (.number 0)
  let add := Expr.app (.app (.app (.app (.app (.app (.function .addBindingWithCharacter) state)
    first) after) value) (.eq constantAfter (.number 0))) following
  ⟨"character_declaration_at", [
    constant .number "first" ["literal_position"] (skip (.field .statePosition state)),
    constant .number "after" ["literal_position"] (.app (.app (.function .nameAfter) text) first),
    constant .number "colon_after" ["literal_position"] (take after (.symbol ":")),
    constant .number "constant_after" ["literal_position"] (take colonAfter (.word "constant")),
    constant .number "type_first" ["literal_position"]
      (skip (.group <| .ite (.ne constantAfter (.number 0)) constantAfter colonAfter)),
    constant .number "type_after" ["literal_position"] (take typeFirst (.word "character")),
    constant .value "value" ["value_result"]
      (.app (.app (.app (.app (.app (.app (.app (.function .characterValue) text)
        (take typeAfter (.symbol ":="))) (.field .stateNames state)) (.field .stateScalarNames state))
        (.field .arrayNames (.field .stateArrayNames state)))
        (.field .arrayValues (.field .stateArrayNames state))) (.truth true)),
    constant .number "following" ["literal_position"] (take (.field .valueAfter value) (.symbol ";"))],
    .list [guard (anyOf [
      .not (.app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments")),
      .eq typeAfter (.number 0), .eq following (.number 0), .eq (.count (.field .stateNames state)) .maxBindings,
      .app (.app (.app (.app (.function .nameIs) text) first) after) (.word "character"),
      lookup (.app (.app (.function .lookupName) text) (.field .stateNames state)),
      lookup (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)),
      lookup (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))),
      lookup (.app (.app (.function .subtypeLookup) text) (.field .stateSubtypeNames state)),
      lookup (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state))]) .invalid,
      .returnNamedBoolean add "character_object" (.truth true)]⟩

abbrev WellFormedTrees : Prop := indexedBody.wellFormed = true ∧ characterBody.wellFormed = true ∧
  concatenatedLastBody.wellFormed = true ∧ characterDeclarationBody.wellFormed = true

abbrev WellScopedTrees : Prop :=
  indexedBody.scoped [("text", .source), ("position", .number), ("names", .names),
    ("scalar_names", .scalarNames), ("arrays", .arrayMetadata), ("initials", .arrayInitials),
    ("elaborating", .truth), ("character_element", .truth)] = true ∧
  characterBody.scoped [("text", .source), ("position", .number), ("names", .names),
    ("scalar_names", .scalarNames), ("arrays", .arrayMetadata), ("initials", .arrayInitials),
    ("elaborating", .truth)] = true ∧
  concatenatedLastBody.scoped [("left", .scan), ("right", .value)] = true ∧
  characterDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem checked_scopes : WellScopedTrees := by decide +kernel

namespace SourceChecks

abbrev Checked (tokens : List String) : Prop :=
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "indexed_at" tokens = some indexedBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_at" tokens = some characterBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "concatenated_last" tokens = some concatenatedLastBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_declaration_at" tokens = some characterDeclarationBody.render

end SourceChecks

end Silver.Compose.StringNative
