module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeStringNative

@[expose] public section

/-! Exact typed bodies of named-type lookup and declaration. Record updates
retain the native field layout; all lookup and scalar-reader calls stay explicit. -/
namespace Silver.Compose.Expressions
open StringNative

def arrayTypeAtBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let lookup (function : Expr (.arrow .number (.arrow .number .number))) :=
    Expr.ne (.app (.app function first) after) (.number 0)
  .locals <| .local "first" "literal_position"
    (.app (.app (.function .skip) text) (.variable "position")) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .group <| .ite (anyOf [
      .eq first (.number 0), .le after first,
      lookup (.app (.app (.function .lookupName) text) (.field .stateNames state)),
      lookup (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)),
      lookup (.app (.app (.function .arrayLookup) text) (arrayStateNames state)),
      lookup (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state)),
      lookup (.app (.app (.function .functionLookup) text) (.field .stateFunctions state)),
      lookup (.app (.app (.function .procedureLookup) text) (.field .stateProcedures state)),
      .app (.app (.app (.app (.function .formalHides) text) state) first) after])
      (.number 0) (lookupArrayType text (arrayStateNames state) first after)

def arrayTypeDeclarationBody : Body .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let start : Expr .number := .variable "start"
  let low : Expr .scalarResult := .variable "low"
  let high : Expr .scalarResult := .variable "high"
  let component : Expr .scalarConstraint := .variable "component"
  let following : Expr .number := .variable "following"
  let take := arrayTake text
  let skip (p : Expr .number) := Expr.app (.app (.function .skip) text) p
  let named (word : String) := Expr.app (.app (.app (.app (.function .nameIs) text) first) after) (.word word)
  let bounds (value : Expr .scalarResult) := Expr.field .scalarBounds value
  let lower (value : Expr .scalarResult) := Expr.field .intervalLower (bounds value)
  let upper (value : Expr .scalarResult) := Expr.field .intervalUpper (bounds value)
  let subtypes := Expr.field .stateSubtypeNames state
  let flags := Expr.field .subtypeHiding subtypes
  let operation : Expr .operation := .variable "operation"
  ⟨"array_type_declaration_at", [
    constant .number "first" ["literal_position"] (skip (take (.field .statePosition state) (.word "type"))),
    constant .number "after" ["literal_position"] (.app (.app (.function .nameAfter) text) first),
    constant .number "start" ["literal_position"] (take (take (take after (.word "is")) (.word "array")) (.symbol "(")),
    constant .scalarResult "low" ["scalar_expressions", ".", "expression_result"]
      (.scalarReadTable text start (.field .stateScalarNames state) (arrayStateNames state)),
    constant .scalarResult "high" ["scalar_expressions", ".", "expression_result"]
      (.scalarReadTable text (take (.field .scalarAfter low) (.symbol ".."))
        (.field .stateScalarNames state) (arrayStateNames state)),
    constant .scalarConstraint "component" ["scalar_constraint_result"]
      (.app (.app (.app (.function .scalarType) text) state)
        (take (take (.field .scalarAfter high) (.symbol ")")) (.word "of"))),
    constant .number "following" ["literal_position"] (take (.field .constraintAfter component) (.symbol ";"))],
    .list [guard (anyOf [
      .eq start (.number 0), .le following (.field .statePosition state), .field .statePure state,
      .not (.app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments")),
      named "integer", .eq (.arrayTypeCount (.field .arrayTypes (arrayStateNames state))) .maxArrayTypes,
      .eq (.field .scalarAfter low) (.number 0), .eq (.field .scalarAfter high) (.number 0),
      .eq (.field .constraintAfter component) (.number 0),
      .not (.field .scalarStatic low), .not (.field .scalarStatic high),
      .app (.function .scalarEmpty) (bounds low), .app (.function .scalarEmpty) (bounds high),
      .integerNe (lower low) (upper low), .integerNe (lower high) (upper high),
      .integerGt (lower low) (lower high),
      .integerGe (.integerSub (.wideInteger (lower high)) (.wideInteger (lower low)))
        (.wideNumber .maxArrayElements)]) .invalid,
      .returned (.stateArrayType state first after (.interval (lower low) (lower high))
        (.field .constraintBounds component) following
        (.orElse (.field .subtypeTrueHidden subtypes) (named "true"))
        (.orElse (.field .subtypeFalseHidden subtypes) (named "false"))
        (.forOperations "operation" (.orElse (.hiddenFlag flags operation)
          (.app (.app (.app (.app (.function .nameIs) text) first) after) (.operationName operation)))))]⟩

theorem checked_array_type_precedence :
    arrayTypeAtBody.wellFormed = true ∧ arrayTypeDeclarationBody.wellFormed = true := by
  decide +kernel

theorem checked_array_type_scope :
    arrayTypeAtBody.scoped [("text", .source), ("state", .state), ("position", .number)] = true ∧
      arrayTypeDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true := by
  decide +kernel

end Silver.Compose.Expressions
