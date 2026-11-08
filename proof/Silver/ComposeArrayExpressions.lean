module

public import Silver.ComposeExpressions

@[expose] public section

/-! Typed source trees for the array initializer models. The executable loop
has an exact native postcondition to the recursive model. These trees retain
all parsing, staticness, capacity and type-hiding tests from that model. -/

namespace Silver.Compose.Expressions

def putArrayValue (state : ParserState) (value : Int) : ParserState :=
  {state with arrayNames := {state.arrayNames with
    used := state.arrayNames.used + 1,
    values := ArrayBindings.putInitial state.arrayNames.values (state.arrayNames.used + 1) value}}

def arrayStateNames (state : Expr .state) : Expr .arrayMetadata :=
  .field .arrayNames (.field .stateArrayNames state)

def arrayStateValues (state : Expr .state) : Expr .arrayInitials :=
  .field .arrayValues (.field .stateArrayNames state)

def arrayStateUsed (state : Expr .state) : Expr .number :=
  .field .arrayUsed (.field .stateArrayNames state)

def arrayPutBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let next := Expr.add (arrayStateUsed state) (.number 1)
  .stateArray state (.arrayUsedValues (.field .stateArrayNames state) next
    (.arrayPut (arrayStateValues state) next (.variable "value")))

def addArrayBinding (state : ParserState) (first after : Nat) (bounds : Integer.Interval)
    (offset length : Nat) (mutable : Bool) (following : Nat)
    (componentBounds : Integer.Interval) (isBoolean : Bool := false) : ParserState :=
  {state with position := following, arrayNames := {state.arrayNames with
    names := state.arrayNames.names ++ [⟨first, after, bounds, offset, length, mutable, componentBounds, isBoolean⟩]}}

def arrayAddBody : Expr .state :=
  let state : Expr .state := .variable "state"
  .statePositionArray state (.variable "following")
    (.arrayNamesOnly (.field .stateArrayNames state)
      (.arrayAppend (arrayStateNames state) (.variable "first") (.variable "after")
        (.variable "bounds") (.variable "offset") (.variable "length") (.variable "mutable")
        (.variable "component_bounds") (.variable "boolean_elements")))

def arrayAddCall (text : Expr .source) (state : Expr .state) (first after : Expr .number)
    (bounds : Expr .interval) (offset length : Expr .number) (mutable : Expr .truth)
    (following : Expr .number) (componentBounds : Expr .interval) (isBoolean : Expr .truth) : Expr .state :=
  .app (.app (.app (.app (.app (.app (.app (.app (.app (.app (.app
    (.function .arrayAdd) text) state) first) after) bounds) offset) length) mutable) following) componentBounds) isBoolean

def arrayRead (text : Expr .source) (position : Expr .number)
    (state : Expr .state) : Expr .scalarResult :=
  .scalarReadArrays text position (.field .stateScalarNames state)
    (arrayStateNames state) (arrayStateValues state) (.truth true)

def arrayTake (text : Expr .source) (position : Expr .number)
    (token : ShellToken) : Expr .number :=
  .app (.app (.app (.function .takeToken) text) position) (.token token)

def arrayValuesCall (executable : Bool) (text : Expr .source)
    (source result : Expr .state) (position length parsed : Expr .number)
    (componentBounds : Expr .interval) : Expr .state :=
  let callee : Expr (.arrow .source (.arrow .state (.arrow .state
      (.arrow .number (.arrow .number (.arrow .number (.arrow .interval .state))))))) :=
    if executable then .function .arrayValues else .function .arrayValuesModel
  .app (.app (.app (.app (.app (.app (.app callee text) source) result) position) length) parsed) componentBounds

def arrayValuesModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let source : Expr .state := .variable "source_state"
  let result : Expr .state := .variable "result_state"
  let position : Expr .number := .variable "position"
  let length : Expr .number := .variable "length"
  let parsed : Expr .number := .variable "parsed"
  let value : Expr .scalarResult := .variable "value"
  let bounds := Expr.field .scalarBounds value
  let components : Expr .interval := .variable "component_bounds"
  .ite (.eq position (.number 0)) .invalid <|
  .elsif (.eq parsed length) (.statePosition result position) <|
  .group <| .locals <|
    .local "value" "scalar_expressions.expression_result" (arrayRead text position source) <|
    .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.eq (.field .scalarAfter value) (.number 0))
        (.app (.function .scalarEmpty) bounds))
        (.integerNe (.field .intervalLower bounds) (.field .intervalUpper bounds)))
        (.integerLt (.field .intervalLower bounds) (.field .intervalLower components)))
        (.integerGt (.field .intervalUpper bounds) (.field .intervalUpper components)))
      .invalid <|
    .group <| .locals <|
      .local "next_state" "parser_state"
        (.app (.app (.function .arrayPut) result) (.field .intervalLower bounds)) <|
      .local "next_position" "literal_position"
        (.group <| .ite (.lt (.add parsed (.number 1)) length)
          (arrayTake text (.field .scalarAfter value) (.symbol ",")) (.field .scalarAfter value)) <|
      arrayValuesCall false text source (.variable "next_state") (.variable "next_position")
        length (.add parsed (.number 1)) components

def booleanArrayValuesCall (executable : Bool) (text : Expr .source)
    (source result : Expr .state) (position length parsed maskFirst maskAfter : Expr .number) : Expr .state :=
  let callee : Expr (.arrow .source (.arrow .state (.arrow .state
      (.arrow .number (.arrow .number (.arrow .number (.arrow .number (.arrow .number .state)))))))) :=
    if executable then .function .booleanArrayValues else .function .booleanArrayValuesModel
  .app (.app (.app (.app (.app (.app (.app (.app callee text) source) result) position)
    length) parsed) maskFirst) maskAfter

def booleanArrayValuesModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let source : Expr .state := .variable "source_state"
  let result : Expr .state := .variable "result_state"
  let position : Expr .number := .variable "position"
  let length : Expr .number := .variable "length"
  let parsed : Expr .number := .variable "parsed"
  let maskFirst : Expr .number := .variable "mask_first"
  let maskAfter : Expr .number := .variable "mask_after"
  let valueAfter : Expr .number := .variable "value_after"
  .ite (.eq position (.number 0)) .invalid <|
  .elsif (.eq parsed length) (.statePosition result position) <|
  .group <| .locals <|
    .local "value_after" "literal_position"
      (.app (.app (.app (.app (.app (.function .booleanInitializer) text) source) position) maskFirst) maskAfter) <|
    .group <| .ite (.eq valueAfter (.number 0)) .invalid <|
    .group <| .locals <|
      .local "next_state" "parser_state"
        (.app (.app (.function .arrayPut) result) (.integerNumber 0)) <|
      .local "next_position" "literal_position"
        (.group <| .ite (.lt (.add parsed (.number 1)) length)
          (arrayTake text valueAfter (.symbol ",")) valueAfter) <|
      booleanArrayValuesCall false text source (.variable "next_state") (.variable "next_position")
        length (.add parsed (.number 1)) maskFirst maskAfter

/-- The runtime wrapper has the same expression tree, calling the native
aggregate helper instead of its ghost recursive model. -/
def arrayDeclarationBody (executable : Bool) : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let constant : Expr .number := .variable "constant_after"
  let position : Expr .number := .variable "position"
  let lower : Expr .scalarResult := .variable "low"
  let upper : Expr .scalarResult := .variable "high"
  let low := Expr.field .intervalLower (.field .scalarBounds lower)
  let high := Expr.field .intervalLower (.field .scalarBounds upper)
  let length : Expr .number := .variable "length"
  let choice : Expr .scalarResult := .variable "choice"
  let values : Expr .state := .variable "values"
  let following : Expr .number := .variable "following"
  let isBoolean : Expr .truth := .variable "boolean_elements"
  let take := arrayTake text
  let skip (p : Expr .number) := Expr.app (.app (.function .skip) text) p
  let hiddenString := Expr.app (.app (.app (.app (.function .lookupName) text)
    (.field .stateNames state)) (.variable "type_first")) (.variable "type_after")
  let hiddenScalar := Expr.app (.app (.app (.app (.function .scalarLookup) text)
    (.field .stateScalarNames state)) (.variable "type_first")) (.variable "type_after")
  let hiddenArray := Expr.app (.app (.app (.app (.function .arrayLookup) text)
    (arrayStateNames state)) (.variable "type_first")) (.variable "type_after")
  let hiddenBoolean := Expr.app (.app (.app (.app (.function .booleanLookup) text)
    (.field .stateBooleanNames state)) (.variable "type_first")) (.variable "type_after")
  let hiddenSubtype := Expr.app (.app (.app (.app (.function .subtypeLookup) text)
    (.field .stateSubtypeNames state)) (.variable "type_first")) (.variable "type_after")
  let conditions : List (Expr .truth) :=
    [.not (.app (.app (.app (.app (.app (.function .newName) text) state) first) after) arguments),
     .group <| .ite isBoolean
       (.app (.app (.app (.app (.function .nameIs) text) first) after) .booleanTypeWord)
       (.app (.app (.app (.app (.function .nameIs) text) first) after) .integerTypeWord),
     .eq (.variable "array_after") (.number 0), .eq position (.number 0),
     .eq (.arrayCount (arrayStateNames state)) .maxArrayBindings,
     .eq (.field .scalarAfter lower) (.number 0), .eq (.field .scalarAfter upper) (.number 0),
     .not (.field .scalarStatic lower), .not (.field .scalarStatic upper),
     .app (.function .scalarEmpty) (.field .scalarBounds lower),
     .app (.function .scalarEmpty) (.field .scalarBounds upper),
     .integerNe low (.field .intervalUpper (.field .scalarBounds lower)),
     .integerNe high (.field .intervalUpper (.field .scalarBounds upper)),
     .integerGt low high,
     .integerGe (.integerSub (.wideInteger high) (.wideInteger low))
       (.wideNumber (.sub .maxArrayElements (arrayStateUsed state))),
     .ne hiddenString (.number 0), .ne hiddenScalar (.number 0), .ne hiddenArray (.number 0),
     .ne hiddenBoolean (.number 0),
     .ne (.app (.app (.app (.app (.function .functionLookup) text)
       (.field .stateFunctions state)) (.variable "type_first")) (.variable "type_after")) (.number 0),
     .app (.app (.app (.app (.function .formalHides) text) state)
       (.variable "type_first")) (.variable "type_after"),
     .group (.andThen (.field .hiddenInteger (.field .stateHiding state))
       (.app (.app (.app (.app (.function .nameIs) text) (.variable "type_first")) (.variable "type_after")) .integerTypeWord)),
     .group (.andThen (.field .hiddenBoolean (.field .stateHiding state))
       (.app (.app (.app (.app (.function .nameIs) text) (.variable "type_first")) (.variable "type_after")) .booleanTypeWord)),
     .group (.andThen (.field .hiddenCharacter (.field .stateHiding state))
       (.app (.app (.app (.app (.function .nameIs) text) (.variable "type_first")) (.variable "type_after")) .characterTypeWord)),
     .group (.andThen isBoolean (.ne hiddenSubtype (.number 0)))]
  let rejected := conditions.tail.foldl Expr.orElse (conditions.headD (.truth false))
  .locals <|
    .local "first" "literal_position" (skip (.field .statePosition state)) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "colon_after" "literal_position" (take after (.symbol ":")) <|
    .local "constant_after" "literal_position" (take (.variable "colon_after") (.word "constant")) <|
    .local "array_after" "literal_position"
      (take (.group <| .ite (.ne constant (.number 0)) constant (.variable "colon_after")) (.word "array")) <|
    .local "low" "scalar_expressions.expression_result"
      (arrayRead text (take (.variable "array_after") (.symbol "(")) state) <|
    .local "high" "scalar_expressions.expression_result"
      (arrayRead text (take (.field .scalarAfter lower) (.symbol "..")) state) <|
    .local "type_first" "literal_position"
      (skip (take (take (.field .scalarAfter upper) (.symbol ")")) (.word "of"))) <|
    .local "integer_type" "scalar_constraint_result"
      (.app (.app (.app (.function .scalarType) text) state) (.variable "type_first")) <|
    .local "boolean_elements" "boolean"
      (.andThen (.eq (.field .constraintAfter (.variable "integer_type")) (.number 0))
        (.ne (take (.variable "type_first") (.word "boolean")) (.number 0))) <|
    .local "type_mark" "scalar_constraint_result"
      (.group <| .ite isBoolean
        (.constraint (take (.variable "type_first") (.word "boolean")) .fullInterval)
        (.variable "integer_type")) <|
    .local "type_after" "literal_position" (.field .constraintAfter (.variable "type_mark")) <|
    .local "position" "literal_position"
      (take (take (.variable "type_after") (.symbol ":=")) (.symbol "(")) <|
    .group <| .ite rejected .invalid <|
    .group <| .locals <|
      .local "length" "array_bindings.element_count"
        (.elementCount (.integerAdd (.group (.integerSub (.wideInteger high) (.wideInteger low)))
          (.integerNumber 1))) <|
      .local "choice" "scalar_expressions.expression_result"
        (.group <| .ite (.eq length (.number 1)) (arrayRead text position state) .invalidScalar) <|
      .local "values_first" "literal_position"
        (.group <| .ite (.eq length (.number 1))
          (take (.field .scalarAfter choice) (.symbol "=>")) position) <|
      .group <| .ite
        (.andThen (.eq length (.number 1)) (.group <|
          .orElse (.orElse (.orElse (.orElse
            (.eq (.variable "values_first") (.number 0)) (.not (.field .scalarStatic choice)))
            (.app (.function .scalarEmpty) (.field .scalarBounds choice)))
            (.integerNe (.field .intervalLower (.field .scalarBounds choice)) low))
            (.integerNe (.field .intervalUpper (.field .scalarBounds choice)) low))) .invalid <|
      .group <| .locals <|
        .local "values" "parser_state"
          (.group <| .ite isBoolean
            (booleanArrayValuesCall executable text state state (.variable "values_first")
              length (.number 0) first after)
            (arrayValuesCall executable text state state (.variable "values_first") length (.number 0)
              (.field .constraintBounds (.variable "type_mark")))) <|
        .local "following" "literal_position"
          (take (take (.field .statePosition values) (.symbol ")")) (.symbol ";")) <|
        .group <| .ite (.orElse (.eq (.field .statePosition values) (.number 0))
            (.le following (.field .statePosition state))) .invalid <|
          arrayAddCall text values first after (.interval low high)
            (arrayStateUsed state) length (.eq constant (.number 0)) following
            (.field .constraintBounds (.variable "type_mark")) isBoolean

theorem arrayValues_precedence : arrayValuesModelBody.wellFormed = true := by decide +kernel

theorem arrayDeclaration_precedence :
    (arrayDeclarationBody false).wellFormed = true ∧
      (arrayDeclarationBody true).wellFormed = true := by decide +kernel

theorem arrayValues_scope : arrayValuesModelBody.scoped
    [("text", .source), ("source_state", .state), ("result_state", .state),
     ("position", .number), ("length", .number), ("parsed", .number), ("component_bounds", .interval)] = true := by decide +kernel

theorem arrayDeclaration_scope :
    (arrayDeclarationBody false).scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
    (arrayDeclarationBody true).scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true := by
  decide +kernel

/-- Complete typed-source coverage for the array helper family. This remains
separate from the base expression catalogue to preserve its dependency order. -/
abbrev ArrayWellFormedTrees : Prop :=
  arrayPutBody.wellFormed = true ∧ arrayAddBody.wellFormed = true ∧
  arrayValuesModelBody.wellFormed = true ∧
  booleanArrayValuesModelBody.wellFormed = true ∧
  (arrayDeclarationBody false).wellFormed = true ∧
  (arrayDeclarationBody true).wellFormed = true

theorem checked_array_precedence : ArrayWellFormedTrees := by decide +kernel

abbrev ArrayWellScopedTrees : Prop :=
  arrayPutBody.scoped [("state", .state), ("value", .integer)] = true ∧
  arrayAddBody.scoped [("text", .source), ("state", .state), ("first", .number),
    ("after", .number), ("bounds", .interval), ("offset", .number), ("length", .number),
    ("mutable", .truth), ("following", .number), ("component_bounds", .interval), ("boolean_elements", .truth)] = true ∧
  arrayValuesModelBody.scoped [("text", .source), ("source_state", .state),
    ("result_state", .state), ("position", .number), ("length", .number), ("parsed", .number), ("component_bounds", .interval)] = true ∧
  booleanArrayValuesModelBody.scoped [("text", .source), ("source_state", .state),
    ("result_state", .state), ("position", .number), ("length", .number), ("parsed", .number),
    ("mask_first", .number), ("mask_after", .number)] = true ∧
  (arrayDeclarationBody false).scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  (arrayDeclarationBody true).scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true

theorem checked_array_scopes : ArrayWellScopedTrees := by decide +kernel

end Silver.Compose.Expressions
