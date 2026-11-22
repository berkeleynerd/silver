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
  | .scalarConstraint, name => name == ["scalar_constraint_result"]
  | .value, name => name == ["value_result"]
  | .truth, name => name == ["boolean"]
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

def fixedBoundsBody : Expr .truth :=
  let length : Expr .number := .variable "length"
  let dynamic : Expr .truth := .variable "dynamic"
  let first : Expr .integer := .variable "first_index"
  let last : Expr .integer := .variable "last_index"
  .ite (.variable "is_character")
    (.andThen (.andThen (.andThen (.not dynamic) (.eq length (.number 1)))
      (.integerEq first (.integerNumber 1))) (.integerEq last (.integerNumber 1))) <|
  .elsif dynamic (.eq length (.number 0)) <|
  .elsif (.eq length (.number 0)) (.integerGt first last) <|
    .andThen (.andThen (.andThen (.integerGe first (.integerNumber 1)) (.integerGe last first))
      (.integerEq (.integerAdd (.group <| .integerSub (.wideInteger last) (.wideInteger first)) (.integerNumber 1)) (.wideNumber length)))
      (.integerLe (.wideInteger last) (.integerMul (.wideNumber (.variable "slot")) (.wideNumber .maxLength)))

def characterLiteralBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  .ite (.andThen (.andThen (.andThen (.andThen (.ne position (.number 0))
    (.le (.add position (.number 2)) (.sourceLast text)))
    (.eq (.byteAt text position) (.characterVal (.number 39))))
    (.range (.byteAt text (.add position (.number 1))) (.character 32) (.character 126)))
    (.eq (.byteAt text (.add position (.number 2))) (.characterVal (.number 39))))
    (.add position (.number 3)) (.number 0)

def concatenatedFirstBody : Expr .interval :=
  let left : Expr .scan := .variable "left"
  let right : Expr .value := .variable "right"
  .ite (.orElse (.eq (.field .scanOperands left) (.number 0))
    (.group <| .andThen (.eq (.field .scanLength left) (.number 0)) (.eq (.field .scanDynamic left) (.number 0))))
    (.field .valueFirstIndex right) <|
  .elsif (.gt (.field .scanMinimum left) (.number 0)) (.field .scanFirstIndex left)
    (.joinInterval (.field .scanFirstIndex left) (.field .valueFirstIndex right))

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
      (.integerAdd (.group <| .integerAdd (.wideNumber (.field .scanLength left)) (.wideNumber (.field .valueLength right)))
        (.integerMul (.group <| .integerAdd (.wideNumber (.field .scanDynamic left))
          (.group <| .ite (.field .valueDynamic right) (.integerNumber 1) (.integerNumber 0)))
          (.wideNumber .maxLength))),
    constant .integer "low" ["scalars", ".", "wide"]
      (.integerSub (.group <| .integerAdd (.wideInteger (.field .intervalLower first)) minimum) (.integerNumber 1)),
    constant .integer "high" ["scalars", ".", "wide"]
      (.integerSub (.group <| .integerAdd (.wideInteger (.field .intervalUpper first)) maximum) (.integerNumber 1)),
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

def guardedBody : Body .truth :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let limit : Expr .number := .variable "limit"
  let depth : Expr .number := .variable "depth"
  let chained : Expr .truth := .variable "chained"
  let ending : Expr .truth := .variable "ending"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let characterAfter : Expr .number := .variable "character_after"
  let quotedAfter : Expr .number := .variable "quoted_after"
  let named (word : String) := .app (.app (.app (.app (.function .nameIs) text) first) after) (.word word)
  let recur (p d : Expr .number) (c e : Expr .truth) :=
    .app (.app (.app (.app (.app (.app (.function .guardedAt) text) p) limit) d) c) e
  ⟨"guarded_at", [
    constant .number "first" ["literal_position"] (.app (.app (.function .skip) text) position),
    constant .number "after" ["literal_position"] (.app (.app (.function .nameAfter) text) first),
    constant .number "character_after" ["literal_position"] (.app (.app (.function .characterLiteral) text) first),
    constant .number "quoted_after" ["literal_position"] (.field .valueAfter (.app (.app (.function .literal) text) first)),
    constant .truth "next_chained" ["boolean"]
      (.orElse chained (.group <| .andThen (.gt after first)
        (.group <| .orElse (.orElse (named "and") (named "or")) (named "xor")))),
    constant .truth "next_ending" ["boolean"] (.andThen (.gt after first) (named "end")),
    constant .truth "after_punctuation" ["boolean"]
      (.andThen chained (.group <| .orElse (.gt first (.sourceLast text)) (.ne (.byteAt text first) (.character 59))))],
    .returned (.group <| .ite (.ge first limit) (.orElse (.ne depth (.number 0)) chained) <|
      .elsif (.gt characterAfter first) (recur characterAfter depth chained (.truth false)) <|
      .elsif (.gt quotedAfter first) (recur quotedAfter depth chained (.truth false)) <|
      .elsif (.gt after first)
        (.group <| .ite (named "if")
          (.group <| .ite (.andThen ending (.ne depth (.number 0)))
            (recur after (.sub depth (.number 1)) chained (.truth false)) <|
            .elsif ending (recur after (.number 0) chained (.truth false)) <|
            .elsif (.eq depth .maxLength) (.truth true)
              (recur after (.add depth (.number 1)) chained (.truth false)))
          (recur after depth (.variable "next_chained") (.variable "next_ending")))
        (recur (.add first (.number 1)) depth (.variable "after_punctuation") (.truth false)))⟩

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
        .integerGt (.integerSub (.wideInteger (upper low)) (.wideInteger (lower high))) .maximumInteger,
        .group <| .andThen (.group <| .orElse (.not (.field .scalarStatic low)) (.not (.field .scalarStatic high)))
          (.app (.app (.app (.app (.app (.app (.function .guardedAt) text) (.number 1)) position)
            (.number 0)) (.truth false)) (.truth false)),
        .group <| .andThen (.integerLe (lower low) (upper high))
          (.group <| .orElse (.integerLt (lower low) (.field .bindingFirstIndex info))
            (.integerGt (upper high) (.field .bindingLastIndex info)))]) .invalidValue,
      .assign "minimum" (.wideMaximum (.integerNumber 0)
        (.integerAdd (.group <| .integerSub (.wideInteger (lower high)) (.wideInteger (upper low))) (.integerNumber 1))),
      .assign "maximum" (.wideMaximum (.integerNumber 0)
        (.integerAdd (.group <| .integerSub (.wideInteger (upper high)) (.wideInteger (lower low))) (.integerNumber 1))),
      guard (.integerGt maximum (.wideNumber .maxLength)) .invalidValue,
      .returned (.nativeValue following (.number 0) (.capacityInteger minimum) (.capacityInteger maximum)
        (.truth false) (.truth true) (.truth false) target (.add (.group operands) (.number 1)) (bounds low) (bounds high))]⟩

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
    .list [guard (withFunctionTypeHiding (anyOf [
      .not (.app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments")),
      .eq typeAfter (.number 0), .le following (.field .statePosition state), .eq (.count (.field .stateNames state)) .maxBindings,
      .app (.app (.app (.app (.function .nameIs) text) first) after) (.word "character"),
      lookup (.app (.app (.function .lookupName) text) (.field .stateNames state)),
      lookup (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)),
      lookup (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))),
      .ne (lookupArrayType text (.field .arrayNames (.field .stateArrayNames state)) typeFirst typeAfter) (.number 0),
      lookup (.app (.app (.function .subtypeLookup) text) (.field .stateSubtypeNames state)),
      lookup (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state))])
      text state typeFirst typeAfter) .invalid,
      .returnNamedBoolean add "character_object" (.truth true)]⟩

abbrev WellFormedTrees : Prop := indexedBody.wellFormed = true ∧ characterBody.wellFormed = true ∧
  concatenatedLastBody.wellFormed = true ∧ characterDeclarationBody.wellFormed = true ∧
  fixedBoundsBody.wellFormed = true ∧ characterLiteralBody.wellFormed = true ∧
  concatenatedFirstBody.wellFormed = true
  ∧ guardedBody.wellFormed = true

abbrev WellScopedTrees : Prop :=
  indexedBody.scoped [("text", .source), ("position", .number), ("names", .names),
    ("scalar_names", .scalarNames), ("arrays", .arrayMetadata), ("initials", .arrayInitials),
    ("elaborating", .truth), ("character_element", .truth)] = true ∧
  characterBody.scoped [("text", .source), ("position", .number), ("names", .names),
    ("scalar_names", .scalarNames), ("arrays", .arrayMetadata), ("initials", .arrayInitials),
    ("elaborating", .truth)] = true ∧
  concatenatedLastBody.scoped [("left", .scan), ("right", .value)] = true ∧
  characterDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  fixedBoundsBody.scoped [("length", .number), ("dynamic", .truth), ("is_character", .truth),
    ("first_index", .integer), ("last_index", .integer), ("slot", .number)] = true ∧
  characterLiteralBody.scoped [("text", .source), ("position", .number)] = true ∧
  concatenatedFirstBody.scoped [("left", .scan), ("right", .value)] = true
  ∧ guardedBody.scoped [("text", .source), ("position", .number), ("limit", .number),
    ("depth", .number), ("chained", .truth), ("ending", .truth)] = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem checked_scopes : WellScopedTrees := by decide +kernel

namespace StructuralControls

/-- ComposeExpressions already checks the arithmetic collision. These controls
ensure ordinary declarations and command branches enforce the child guards. -/
private def rightSub : Expr .integer :=
  .integerSub (.integerNumber 10) (.integerSub (.integerNumber 3) (.integerNumber 1))
private def leftSub : Expr .integer :=
  .integerSub (.integerSub (.integerNumber 10) (.integerNumber 3)) (.integerNumber 1)
private def badDeclaration := constant .integer "value" ["scalars", ".", "wide"] rightSub
private def goodDeclaration := constant .integer "value" ["scalars", ".", "wide"] leftSub

private theorem initializer_collision :
    badDeclaration.render = goodDeclaration.render ∧
    badDeclaration.wellFormed = false ∧ goodDeclaration.wellFormed = true := by
  refine ⟨rfl, ?_⟩
  decide +kernel

private def badCondition : Expr .truth := .not (.orElse (.truth true) (.truth true))
private def goodCondition : Expr .truth := .orElse (.not (.truth true)) (.truth true)
private def branch (test : Expr .truth) : Command .number :=
  .choose test (.returned (.number 0)) (.returned (.number 1))

private theorem command_collision_and_nested_children :
    (branch badCondition).render = (branch goodCondition).render ∧
    (branch badCondition).wellFormed = false ∧ (branch goodCondition).wellFormed = true ∧
    (Command.sequence .nothing (branch badCondition)).wellFormed = false ∧
    (Command.sequence .nothing (branch goodCondition)).wellFormed = true ∧
    (Command.choose (.truth true) (.returned rightSub) (.returned leftSub)).wellFormed = false ∧
    (Command.choose (.truth true) (.returned leftSub) (.returned leftSub)).wellFormed = true := by
  constructor
  · have sameCondition : badCondition.render = goodCondition.render := rfl
    simp only [branch, Command.render, Command.renderElse, sameCondition]
  · decide +kernel

end StructuralControls

namespace SourceChecks

def guardedHeader : List String := ((Source.lexLine
  "(Text : String; Position : Cursor; Limit : Literal_Position; Depth : Natural; Chained, Ending : Boolean) return Boolean").getD [])

def guardedContract : List String := guardedHeader ++ ((Source.lexLine
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Limit <= Text'Last + 1 and then Depth <= Max_Source_Length, Subprogram_Variant => (Decreases => (Text'Last + 1) - Position)").getD [])

abbrev Checked (tokens : List String) : Prop :=
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "indexed_at" tokens = some indexedBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_at" tokens = some characterBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "concatenated_last" tokens = some concatenatedLastBody.render ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_declaration_at" tokens = some characterDeclarationBody.render
  ∧ BooleanDeclarationNative.SourceChecks.ordinaryFunction "guarded_at" tokens = some guardedBody.render
  ∧ Silver.SourceBridge.functionHeader "guarded_at" "is" tokens = some guardedHeader
  ∧ Silver.SourceBridge.functionHeader "guarded_at" ";" tokens = some guardedContract

end SourceChecks

end Silver.Compose.StringNative
