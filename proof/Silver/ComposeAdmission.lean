module

public import Silver.ComposeAtomReading
public import Silver.ComposeBindingBounds
public import Silver.PredicateConditionAdmission

@[expose] public section

namespace Silver.Compose
open Named Bindings

def newNameAllowed (text : Source) (state : ParserState) (first after : Nat) (arguments : Bool) : Bool :=
  decide (first ≠ 0 ∧ after > first) && !forbiddenName text first after &&
    (!arguments || !Arguments.forbiddenName text first after) &&
    decide (lookupName text state.names first after = 0 ∧
      ScalarExpression.lookup text state.scalarNames first after = 0 ∧
      ArrayBindings.lookup text state.arrayNames.names first after = 0 ∧
      BooleanBindings.lookup text state.booleanNames first after = 0 ∧
      IntegerSubtypes.lookup text state.subtypeNames first after = 0)

def addBinding (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) (characterObject : Bool := false) : ParserState :=
  {state with position := following, names := state.names ++
    [{first := first, after := after, valueFirst := value.valueFirst,
      staticLength := value.staticLength, dynamic := value.dynamicSeen, mutable := mutable,
      isCharacter := characterObject, firstIndex := value.firstIndex.lower,
      lastIndex := value.lastIndex.lower}]}

structure DeclarationParts where
  first : Nat
  after : Nat
  constantAfter : Nat
  value : ExpressionResult
  following : Nat
  deriving DecidableEq, Repr

def declarationFirst (text : Source) (state : ParserState) : Nat := skipAt text state.position

def declarationAfter (text : Source) (state : ParserState) : Nat := nameAfter text (declarationFirst text state)

def declarationColonAfter (text : Source) (state : ParserState) : Nat := fixedAfter text (declarationAfter text state) ":" false

def declarationConstantAfter (text : Source) (state : ParserState) : Nat :=
  fixedAfter text (declarationColonAfter text state) "constant" true

def declarationValuePosition (text : Source) (state : ParserState) : Nat :=
  fixedAfter text
    (fixedAfter text (if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
      else declarationColonAfter text state) "string" true) ":=" false

def declarationIntegerHidden (text : Source) (state : ParserState) : Bool :=
  decide (declarationFirst text state ≠ 0 ∧ declarationAfter text state > declarationFirst text state ∧
    fixedAfter text (declarationFirst text state) "integer" true = declarationAfter text state) ||
    BooleanBindings.hidesInteger text state.booleanNames

def declarationParts (text : Source) (state : ParserState) : DeclarationParts :=
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true,
    fixedAfter text (expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true).after ";" false⟩

def stringDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := declarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.following = 0 ∨ state.names.length = maxBindings) ||
      !fits parts.value maxSourceLength || parts.value.emptyValue ||
      decide (parts.value.minimumLength ≠ parts.value.staticLength) ||
      (decide (parts.value.dynamicCount = 0) &&
        (parts.value.firstIndex.isEmpty || parts.value.lastIndex.isEmpty ||
          decide (parts.value.firstIndex.lower ≠ parts.value.firstIndex.upper ∨
            parts.value.lastIndex.lower ≠ parts.value.lastIndex.upper))) ||
      !fixedBoundsValid parts.value.staticLength (decide (parts.value.dynamicCount = 1)) false
        parts.value.firstIndex.lower parts.value.lastIndex.lower (state.names.length + 1)
  then invalidState
  else addBinding state parts.first parts.after parts.value.value (decide (parts.constantAfter = 0)) parts.following

structure CharacterDeclarationParts where
  first : Nat
  after : Nat
  constantAfter : Nat
  typeFirst : Nat
  typeAfter : Nat
  value : ValueResult
  following : Nat
  deriving DecidableEq, Repr

def characterDeclarationParts (text : Source) (state : ParserState) : CharacterDeclarationParts :=
  let first := declarationFirst text state
  let after := declarationAfter text state
  let constantAfter := declarationConstantAfter text state
  let typeFirst := skipAt text (if constantAfter ≠ 0 then constantAfter else declarationColonAfter text state)
  let typeAfter := fixedAfter text typeFirst "character" true
  let value := characterAt text (fixedAfter text typeAfter ":=" false) state.names state.scalarNames
    state.arrayNames.names state.arrayNames.values true
  ⟨first, after, constantAfter, typeFirst, typeAfter, value, fixedAfter text value.after ";" false⟩

def characterDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := characterDeclarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.typeAfter = 0 ∨ parts.following = 0 ∨ state.names.length = maxBindings) ||
      Named.nameIs text parts.first parts.after ("character".toList.map Char.toNat) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0)
  then invalidState else addBinding state parts.first parts.after parts.value
    (decide (parts.constantAfter = 0)) parts.following true

structure ScalarConstraintResult where
  after : Nat
  bounds : Integer.Interval
  deriving DecidableEq, Repr

def scalarConstraintAt (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (baseBounds : Integer.Interval := .full) : ScalarConstraintResult :=
  let rangeAfter := fixedAfter text position "range" true
  if rangeAfter = 0 then ⟨position, baseBounds⟩ else
    let lower := ScalarExpression.read text rangeAfter names
    let delimiter := fixedAfter text lower.after ".." false
    let upper := ScalarExpression.read text delimiter names
    if lower.after = 0 ∨ delimiter = 0 ∨ upper.after = 0 ∨ lower.isStatic = false ∨ upper.isStatic = false ∨
        lower.bounds.isEmpty = true ∨ upper.bounds.isEmpty = true ∨
        lower.bounds.lower ≠ lower.bounds.upper ∨ upper.bounds.lower ≠ upper.bounds.upper ∨
        upper.bounds.lower < lower.bounds.lower ∨ lower.bounds.lower < baseBounds.lower ∨
        baseBounds.upper < upper.bounds.lower
    then ⟨0, .empty⟩ else ⟨upper.after, ⟨lower.bounds.lower, upper.bounds.lower⟩⟩

def scalarTypeAt (text : Source) (state : ParserState) (position : Nat) : ScalarConstraintResult :=
  let first := skipAt text position
  let after := nameAfter text first
  let target := IntegerSubtypes.lookup text state.subtypeNames first after
  if first = 0 ∨ after ≤ first ∨ lookupName text state.names first after ≠ 0 ∨
      ScalarExpression.lookup text state.scalarNames first after ≠ 0 ∨
      ArrayBindings.lookup text state.arrayNames.names first after ≠ 0 ∨
      BooleanBindings.lookup text state.booleanNames first after ≠ 0
  then ⟨0, .empty⟩
  else if Named.nameIs text first after ("integer".toList.map Char.toNat) then ⟨after, .full⟩
  else if target ≠ 0 then ⟨after, (IntegerSubtypes.binding state.subtypeNames target).bounds⟩
  else ⟨0, .empty⟩

structure SubtypeDeclarationParts where
  first : Nat
  after : Nat
  typeFirst : Nat
  typeAfter : Nat
  constraint : ScalarConstraintResult
  following : Nat
  deriving DecidableEq, Repr

def subtypeDeclarationParts (text : Source) (state : ParserState) : SubtypeDeclarationParts :=
  let first := skipAt text (fixedAfter text state.position "subtype" true)
  let after := nameAfter text first
  let typeFirst := skipAt text (fixedAfter text after "is" true)
  let typeAfter := fixedAfter text typeFirst "integer" true
  let constraint := scalarConstraintAt text typeAfter state.scalarNames
  ⟨first, after, typeFirst, typeAfter, constraint, fixedAfter text constraint.after ";" false⟩

def addSubtypeBinding (text : Source) (state : ParserState) (parts : SubtypeDeclarationParts) : ParserState :=
  {state with position := parts.following, subtypeNames := IntegerSubtypes.append text state.subtypeNames ⟨parts.first, parts.after, parts.constraint.bounds⟩}

def subtypeDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := subtypeDeclarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) ||
      decide (state.subtypeNames.items.length = IntegerSubtypes.maxBindings ∨
        parts.typeAfter = 0 ∨ fixedAfter text parts.typeAfter "range" true = 0 ∨
        parts.constraint.after = 0 ∨ parts.following ≤ state.position) ||
      parts.constraint.bounds.isEmpty ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0)
  then invalidState else addSubtypeBinding text state parts

structure ScalarDeclarationParts where
  first : Nat
  after : Nat
  constantAfter : Nat
  typeFirst : Nat
  typeAfter : Nat
  constraint : ScalarConstraintResult
  value : ScalarExpression.Result
  following : Nat
  deriving DecidableEq, Repr

def scalarDeclarationTypeFirst (text : Source) (state : ParserState) : Nat :=
  skipAt text (if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
    else declarationColonAfter text state)

def scalarDeclarationTypeAfter (text : Source) (state : ParserState) : Nat :=
  (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).after

def scalarDeclarationValuePosition (text : Source) (state : ParserState) : Nat :=
  fixedAfter text (scalarConstraintAt text (scalarDeclarationTypeAfter text state) state.scalarNames
    (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).bounds).after ":=" false

def scalarDeclarationParts (text : Source) (state : ParserState) : ScalarDeclarationParts :=
  let value := ScalarExpression.read text (scalarDeclarationValuePosition text state) state.scalarNames
    (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    scalarDeclarationTypeFirst text state, scalarDeclarationTypeAfter text state,
    scalarConstraintAt text (scalarDeclarationTypeAfter text state) state.scalarNames
    (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).bounds, value,
    fixedAfter text value.after ";" false⟩

def addScalarBinding (state : ParserState) (parts : ScalarDeclarationParts) : ParserState :=
  {state with position := parts.following, scalarNames := state.scalarNames ++
    [⟨parts.first, parts.after, parts.value.bounds,
      decide (parts.constantAfter ≠ 0) && parts.value.isStatic,
      parts.constraint.bounds, decide (parts.constantAfter = 0)⟩]}

def scalarDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := scalarDeclarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.typeAfter = 0 ∨ parts.constraint.after = 0 ∨
        parts.following ≤ state.position ∨ state.scalarNames.length = ScalarExpression.maxBindings) ||
      parts.value.bounds.isEmpty ||
      decide (parts.value.bounds.lower ≠ parts.value.bounds.upper ∨
        parts.value.bounds.lower < parts.constraint.bounds.lower ∨
        parts.constraint.bounds.upper < parts.value.bounds.upper) ||
      decide (fixedAfter text parts.first "integer" true = parts.after) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0)
  then invalidState else addScalarBinding state parts

structure ArrayDeclarationParts where
  first : Nat
  after : Nat
  constantAfter : Nat
  arrayAfter : Nat
  lower : ScalarExpression.Result
  upper : ScalarExpression.Result
  typeFirst : Nat
  typeAfter : Nat
  componentBounds : Integer.Interval
  position : Nat
  deriving DecidableEq, Repr

def arrayDeclarationParts (text : Source) (state : ParserState) : ArrayDeclarationParts :=
  let arrayAfter := fixedAfter text
    (if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
      else declarationColonAfter text state) "array" true
  let lower := ScalarExpression.read text (fixedAfter text arrayAfter "(" false) state.scalarNames
    (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)
  let upper := ScalarExpression.read text (fixedAfter text lower.after ".." false) state.scalarNames
    (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)
  let typeFirst := skipAt text (fixedAfter text (fixedAfter text upper.after ")" false) "of" true)
  let typeMark := scalarTypeAt text state typeFirst
  let typeAfter := typeMark.after
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    arrayAfter, lower, upper, typeFirst, typeAfter, typeMark.bounds,
    fixedAfter text (fixedAfter text typeAfter ":=" false) "(" false⟩

def arrayAggregatePosition (text : Source) (state : ParserState)
    (parts : ArrayDeclarationParts) (length : Nat) : Nat :=
  if length = 1 then
    let index := ScalarExpression.read text parts.position state.scalarNames
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)
    let following := fixedAfter text index.after "=>" false
    if following = 0 ∨ index.isStatic = false ∨ index.bounds.isEmpty = true ∨
        index.bounds.lower ≠ parts.lower.bounds.lower ∨ index.bounds.upper ≠ parts.lower.bounds.lower
    then 0 else following
  else parts.position

/-- The native aggregate loop's exact recursive meaning. Every component reads
from the incoming declaration state; the accumulator receives only flat values.
The source readiness proof separately establishes `values.length = used`. -/
def arrayValuesModel (text : Source) (source result : ParserState)
    (position length parsed : Nat) (componentBounds : Integer.Interval := .full) : ParserState :=
  if position = 0 then invalidState else
  if _remaining : parsed < length then
    let value := ScalarExpression.read text position source.scalarNames
      (arrays := source.arrayNames.names) (initials := source.arrayNames.values) (elaborating := true)
    if value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper then invalidState
    else
      let next := {result with arrayNames := {result.arrayNames with
        used := result.arrayNames.used + 1,
        values := ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) value.bounds.lower}}
      let following := if parsed + 1 < length then fixedAfter text value.after "," false else value.after
      arrayValuesModel text source next following length (parsed + 1) componentBounds
  else {result with position := position}
termination_by length - parsed
decreasing_by omega

def arrayDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := arrayDeclarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) ||
      decide (parts.arrayAfter = 0 ∨ parts.position = 0 ∨
        state.arrayNames.names.length = ArrayBindings.maxBindings ∨
        parts.lower.after = 0 ∨ parts.upper.after = 0) ||
      !parts.lower.isStatic || !parts.upper.isStatic || parts.lower.bounds.isEmpty || parts.upper.bounds.isEmpty ||
      decide (parts.lower.bounds.lower ≠ parts.lower.bounds.upper ∨
        parts.upper.bounds.lower ≠ parts.upper.bounds.upper ∨ parts.lower.bounds.lower > parts.upper.bounds.lower ∨
        parts.upper.bounds.lower - parts.lower.bounds.lower ≥ (ArrayBindings.maxElements - state.arrayNames.used : Nat)) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0)
  then invalidState else
    let length := (parts.upper.bounds.lower - parts.lower.bounds.lower + 1).toNat
    let position := arrayAggregatePosition text state parts length
    if position = 0 then invalidState else
      let result := arrayValuesModel text state state position length 0 parts.componentBounds
      if result.position = 0 then invalidState else
        let following := fixedAfter text (fixedAfter text result.position ")" false) ";" false
        if following ≤ state.position then invalidState else
          {result with position := following, arrayNames := {result.arrayNames with
            names := result.arrayNames.names ++ [⟨parts.first, parts.after,
              ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩,
              state.arrayNames.used, length, decide (parts.constantAfter = 0), parts.componentBounds⟩]}}

structure BooleanDeclarationParts where
  first : Nat
  after : Nat
  constantAfter : Nat
  typeFirst : Nat
  typeAfter : Nat
  valueFirst : Nat
  deriving DecidableEq, Repr

def booleanDeclarationParts (text : Source) (state : ParserState) : BooleanDeclarationParts :=
  let first := skipAt text state.position
  let after := nameAfter text first
  let colonAfter := fixedAfter text after ":" false
  let constantAfter := fixedAfter text colonAfter "constant" true
  let typeFirst := skipAt text (if constantAfter ≠ 0 then constantAfter else colonAfter)
  let typeAfter := fixedAfter text typeFirst "boolean" true
  ⟨first, after, constantAfter, typeFirst, typeAfter, fixedAfter text typeAfter ":=" false⟩

def booleanDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : BooleanDeclarationParts) : Bool :=
  newNameAllowed text state parts.first parts.after arguments &&
    decide (parts.typeAfter ≠ 0 ∧ parts.valueFirst ≠ 0 ∧ state.booleanNames.length ≠ BooleanBindings.maxBindings) &&
    !Named.nameIs text parts.first parts.after ("boolean".toList.map Char.toNat) &&
    decide (lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
      ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0 ∧
      ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter = 0 ∧
      IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter = 0 ∧
      BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter = 0)

def booleanDeclarationContext (state : ParserState) (parts : BooleanDeclarationParts) : Predicate.ParseContext :=
  { names := state.names
    hasArguments := decide (state.dynamicFirst ≠ 0)
    scalarNames := state.scalarNames
    declarationCount := state.scalarNames.length
    arrayNames := state.arrayNames.names
    subtypeHiding := state.subtypeNames.hiddenCalls
    booleanNames := state.booleanNames
    trueHidden := state.subtypeNames.trueHidden
    falseHidden := state.subtypeNames.falseHidden
    elaborating := true
    maskFirst := parts.first
    maskAfter := parts.after }

def booleanDeclarationFacts (state : ParserState) : Predicate.ActiveFlow :=
  Predicate.ActiveFlow.initial state.scalarNames
    (if state.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
      else ⟨some ⟨0, 0⟩, false, false⟩)

def booleanDeclarationValue (text : Source) (state : ParserState) : Predicate.ConditionResult :=
  let parts := booleanDeclarationParts text state
  Predicate.readCondition text (booleanDeclarationContext state parts) parts.valueFirst
    (booleanDeclarationFacts state) state.arrayNames.values

def booleanDeclarationFollowing (text : Source) (state : ParserState) : Nat :=
  fixedAfter text (booleanDeclarationValue text state).after ";" false

def addBooleanBinding (state : ParserState) (parts : BooleanDeclarationParts) (following : Nat) : ParserState :=
  {state with position := following, booleanNames := state.booleanNames ++
    [⟨parts.first, parts.after, decide (parts.constantAfter = 0)⟩]}

def booleanDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := booleanDeclarationParts text state
  if !booleanDeclarationReady text state arguments parts then invalidState else
    let following := booleanDeclarationFollowing text state
    if following ≤ state.position then invalidState else addBooleanBinding state parts following

def declarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let subtype := subtypeDeclarationAt text state arguments
  let scalar := scalarDeclarationAt text state arguments
  let array := arrayDeclarationAt text state arguments
  let boolean := booleanDeclarationAt text state arguments
  let character := characterDeclarationAt text state arguments
  if subtype.position ≠ 0 then subtype
  else if scalar.position ≠ 0 then scalar
  else if array.position ≠ 0 then array
  else if boolean.position ≠ 0 then boolean
  else if character.position ≠ 0 then character else stringDeclarationAt text state arguments

structure ArgumentParts where
  first : Nat
  after : Nat
  defaultPosition : Nat
  fallback : ValueResult
  following : Nat
  deriving DecidableEq, Repr

def argumentFirst (text : Source) (state : ParserState) : Nat := skipAt text state.position

def argumentAfter (text : Source) (state : ParserState) : Nat := nameAfter text (argumentFirst text state)

def argumentDefaultPosition (text : Source) (state : ParserState) : Nat :=
  let start := [ShellToken.symbol ":", .word "constant", .word "string", .symbol ":="].foldl
    (fun position token => tokenAfter text position token) (argumentAfter text state)
  let first := argumentFirst text state
  let after := argumentAfter text state
  let hidden := (decide (first ≠ 0) && decide (after > first)) &&
    decide (fixedAfter text first "first_or_default" true = after)
  let operation := Names.operationAfter text start .argument hidden
  let opening := fixedAfter text operation "(" false
  skipAt text (Names.associationAfter text opening true)

def argumentParts (text : Source) (state : ParserState) : ArgumentParts :=
  ⟨argumentFirst text state, argumentAfter text state, argumentDefaultPosition text state,
    literalAt text (argumentDefaultPosition text state),
    fixedAfter text (fixedAfter text (literalAt text (argumentDefaultPosition text state)).after ")" false) ";" false⟩

def argumentAt (text : Source) (state : ParserState) : ParserState :=
  let parts := argumentParts text state
  if !newNameAllowed text state parts.first parts.after true ||
      decide (parts.following = 0 ∨ state.names.length ≠ 0) then invalidState
  else {addBinding state parts.first parts.after ⟨parts.following, 0, 0, 0, true, true, false, 0, 1, .singleton 1, ⟨0, maxSourceLength⟩⟩ false parts.following with
    dynamicFirst := parts.first, dynamicAfter := parts.after}

def declarationsLoop (text : Source) (arguments : Bool) : Nat → ParserState → ParserState
  | 0, _ => invalidState
  | fuel + 1, state =>
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsLoop text arguments fuel (declarationAt text state arguments)

def declarationsAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  declarationsLoop text arguments
    (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings + 1 -
      (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + state.booleanNames.length)) state

-- The shell tables retain current control flow. Only declaration slots become
-- a finite list, and assignment names resolve against its shared environment.
def header (arguments : Bool) : List ShellToken :=
  [.word "with", .word "silver_io", .symbol ";"] ++
    (if arguments then [.word "with", .word "silver_arguments", .symbol ";"] else []) ++
    [.word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode",
      .symbol "(", .word "on", .symbol ")", .symbol ";"] ++
    (if arguments then [.argumentDeclaration] else []) ++ [.declarations, .word "begin"]

/-- Current native contexts replace the retained fixed-shell context prefix. -/
def currentHeader (arguments : Bool) : List ShellToken :=
  [.contextClauses] ++
    [.word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode",
      .symbol "(", .word "on", .symbol ")", .symbol ";"] ++
    (if arguments then [.argumentDeclaration] else []) ++ [.declarations, .word "begin"]

def outputTokens : List ShellToken :=
  [.word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";"]

def assignmentTokens (target : ShellToken) : List ShellToken :=
  [target, .symbol ":=", .assignmentValue, .symbol ";"]

def guardTokens (capacity : Bool) : List ShellToken :=
  [.word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid"] ++
    (if capacity then [.word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity] else []) ++
    [.word "then"]

def equalityTokens : List ShellToken := [.word "if", .comparisonExpression, .word "then"]
def endIfTokens : List ShellToken := [.word "end", .word "if", .symbol ";"]
def rejectTokens : List ShellToken := [.word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";"] ++ endIfTokens

def Form.tokens (form : Form) : List ShellToken :=
  header form.hasArguments ++
    (match form with
    | .direct => outputTokens
    | .assignment => assignmentTokens .assignmentTarget ++ outputTokens
    | .argument => guardTokens false ++ outputTokens ++ rejectTokens
    | .guardedArgument => guardTokens true ++ outputTokens ++ rejectTokens
    | .branching | .guardedBranching => guardTokens (form == .guardedBranching) ++
        equalityTokens ++ outputTokens ++ [.word "else"] ++ outputTokens ++ endIfTokens ++ rejectTokens
    | .result | .guardedResult => guardTokens (form == .guardedResult) ++ equalityTokens ++
        assignmentTokens .assignmentTarget ++ [.word "else"] ++ assignmentTokens .targetReference ++
        endIfTokens ++ outputTokens ++ rejectTokens) ++
    [.word "end", .word "main", .symbol ";"]

def targetAt (text : Source) (state : ParserState) (sameTarget : Bool) : ParserState :=
  let first := skipAt text state.position
  let after := nameAfter text first
  let index := lookupName text state.names first after
  let info := (state.names.get index).getD {}
  if index = 0 ∨ ScalarExpression.lookup text state.scalarNames first after ≠ 0 ∨
      info.mutable = false ∨ (sameTarget = true ∧ index ≠ state.target) then invalidState
  else {state with position := after, target := index}

def dynamicAt (text : Source) (state : ParserState) : ParserState :=
  let first := skipAt text state.position
  let after := nameAfter text first
  if first = 0 ∨ after = 0 ∨ state.dynamicFirst = 0 ∨
      equalName text state.dynamicFirst state.dynamicAfter first after = false then invalidState
  else {state with position := after}

def assignmentAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.names state.arrayNames.values true
  let target := (state.names.get state.target).getD {}
  if !fits value state.capacity || value.emptyValue || decide (value.minimumLength ≠ value.staticLength ∨ state.target = 0 ∨ value.staticLength ≠ target.staticLength ∨
      value.dynamicCount ≠ (if target.dynamic then 1 else 0)) then invalidState
  else {state with position := value.after}

def outputAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.names state.arrayNames.values true
  if fits value state.capacity then {state with position := value.after} else invalidState

def comparisonAt (text : Source) (state : ParserState) : ParserState :=
  let left := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.names state.arrayNames.values true
  let right := expressionAt text (fixedAfter text left.after "=" false) state.names state.scalarNames false
    state.arrayNames.names state.arrayNames.values true
  if fits left state.capacity && fits right state.capacity && (left.namedSeen || right.namedSeen)
  then {state with position := right.after} else invalidState

def capacityAt (text : Source) (state : ParserState) : ParserState :=
  let position := skipAt text state.position
  let value := Guarded.decimalAt text position
  if position = 0 ∨ value.after = 0 then invalidState
  else {state with position := value.after, capacity := value.value}

def step (text : Source) (form : Form) (token : ShellToken) (state : ParserState) : ParserState :=
  if state.position = 0 then invalidState else
  match token with
  | .contextClauses => {state with position := Names.contextAfter text form.hasArguments}
  | .fixed spelling word => {state with position := fixedAfter text state.position spelling word}
  | .declarations => declarationsAt text state form.hasArguments
  | .argumentDeclaration => argumentAt text state
  | .literal => {state with position := (literalAt text (skipAt text state.position)).after}
  | .capacity => capacityAt text state
  | .dynamicReference => dynamicAt text state
  | .assignmentTarget => targetAt text state false
  | .targetReference => targetAt text state true
  | .assignmentValue => assignmentAt text state
  | .outputExpression => outputAt text state
  | .comparisonExpression => comparisonAt text state

def suffixMatches (text : Source) (form : Form) : List ShellToken → ParserState → Bool
  | [], state => decide (state.position ≠ 0 ∧ Cursor.triviaPosition text state.position = text.length + 1)
  | token :: rest, state =>
      if state.position = 0 then false else suffixMatches text form rest (step text form token state)

def formAccepts (source : Source) (form : Form) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) && source.all allowedCharacter &&
    withinWorkBudget source && suffixMatches source form form.tokens initialState

def selectedForm (source : Source) : Option Form := allForms.find? (formAccepts source)
def accepts (source : Source) : Bool := (selectedForm source).isSome

def hasArguments (source : Source) : Bool :=
  ((selectedForm source).map Form.hasArguments).getD false

def hasAssignment (source : Source) : Bool :=
  ((selectedForm source).map Form.hasAssignment).getD false


theorem lookupFrom_equation (text : Source) (names : BindingEnvironment) (first after index : Nat)
    (positive : 0 < index) :
    lookupFrom text names first after index =
      if index > names.length then 0
      else if equalName text ((names.get index).getD {}).first ((names.get index).getD {}).after first after
      then index else lookupFrom text names first after (index + 1) := by
  by_cases beyond : names.length < index
  · have drop : names.drop (index - 1) = [] := List.drop_eq_nil_of_le (by omega)
    simp [lookupFrom, beyond, drop, lookupList]
  · have inside : index - 1 < names.length := by omega
    have nonzero : index ≠ 0 := by omega
    have successor : index - 1 + 1 = index := by omega
    rw [lookupFrom, List.drop_eq_getElem_cons inside]
    simp [lookupList, beyond, BindingEnvironment.get, nonzero, List.getElem?_eq_getElem inside,
      lookupFrom, successor]

theorem stringDeclarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (stringDeclarationAt text state arguments).position ≠ 0) :
    (stringDeclarationAt text state arguments).names.length = state.names.length + 1 := by
  simp only [stringDeclarationAt]
  split
  · rename_i rejected
    simp only [stringDeclarationAt, rejected, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp [addBinding]

theorem arrayValuesModel_preserves (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval}
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    (arrayValuesModel text source result position length parsed componentBounds).names = result.names ∧
      (arrayValuesModel text source result position length parsed componentBounds).scalarNames = result.scalarNames ∧
      (arrayValuesModel text source result position length parsed componentBounds).arrayNames.names = result.arrayNames.names ∧
      (arrayValuesModel text source result position length parsed componentBounds).subtypeNames = result.subtypeNames := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.read text position source.scalarNames
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_preserves text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
      trivial
termination_by length - parsed
decreasing_by omega

theorem arrayValuesModel_booleanNames (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval}
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    (arrayValuesModel text source result position length parsed componentBounds).booleanNames = result.booleanNames := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.read text position source.scalarNames
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_booleanNames text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem arrayDeclarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).names = state.names ∧
      (arrayDeclarationAt text state arguments).scalarNames = state.scalarNames ∧
      (arrayDeclarationAt text state arguments).arrayNames.names.length = state.arrayNames.names.length + 1 ∧
      (arrayDeclarationAt text state arguments).subtypeNames = state.subtypeNames := by
  unfold arrayDeclarationAt at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i ready
    simp only [ready, Bool.false_eq_true, ↓reduceIte]
    split at accepted
    · simp only [invalidState] at accepted
      contradiction
    · rename_i start
      simp only [start, ↓reduceIte]
      split at accepted
      · simp only [invalidState] at accepted
        contradiction
      · rename_i values
        simp only [values, ↓reduceIte]
        split at accepted
        · simp only [invalidState] at accepted
          contradiction
        · rename_i following
          simp only [following, ↓reduceIte, List.length_append, List.length_singleton]
          have preserved := arrayValuesModel_preserves text state state _ _ 0 values
          exact ⟨preserved.1, preserved.2.1, by rw [preserved.2.2.1], preserved.2.2.2⟩

theorem arrayDeclarationAt_booleanNames {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).booleanNames = state.booleanNames := by
  unfold arrayDeclarationAt at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i ready
    simp only [ready, Bool.false_eq_true, ↓reduceIte]
    split at accepted
    · simp only [invalidState] at accepted
      contradiction
    · rename_i start
      simp only [start, ↓reduceIte]
      split at accepted
      · simp only [invalidState] at accepted
        contradiction
      · rename_i values
        simp only [values, ↓reduceIte]
        split at accepted
        · simp only [invalidState] at accepted
          contradiction
        · rename_i following
          simp only [following, ↓reduceIte]
          exact arrayValuesModel_booleanNames text state state _ _ 0 values

theorem declarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).names.length +
      (declarationAt text state arguments).scalarNames.length +
      (declarationAt text state arguments).arrayNames.names.length +
      (declarationAt text state arguments).subtypeNames.items.length +
      (declarationAt text state arguments).booleanNames.length =
      state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + state.booleanNames.length + 1 := by
  by_cases subtype : (subtypeDeclarationAt text state arguments).position ≠ 0
  · have selected : declarationAt text state arguments = subtypeDeclarationAt text state arguments := by
      simp only [declarationAt]; split <;> simp_all
    rw [selected]
    unfold subtypeDeclarationAt at subtype ⊢
    dsimp only at subtype ⊢
    split at subtype
    · simp [invalidState] at subtype
    · rename_i good
      simp only [good, Bool.false_eq_true, ↓reduceIte, addSubtypeBinding, IntegerSubtypes.append,
        List.length_append, List.length_singleton]
      omega
  · by_cases scalar : (scalarDeclarationAt text state arguments).position ≠ 0
    · have selected : declarationAt text state arguments = scalarDeclarationAt text state arguments := by
        simp only [declarationAt, subtype, ↓reduceIte]; split <;> simp_all
      rw [selected]
      unfold scalarDeclarationAt at scalar ⊢
      dsimp only at scalar ⊢
      split at scalar
      · simp [invalidState] at scalar
      · rename_i good
        simp only [good, Bool.false_eq_true, ↓reduceIte, addScalarBinding,
          List.length_append, List.length_singleton]
        omega
    · by_cases array : (arrayDeclarationAt text state arguments).position ≠ 0
      · have selected : declarationAt text state arguments = arrayDeclarationAt text state arguments := by
          simp only [declarationAt, subtype, ↓reduceIte]; split <;> simp_all
        rw [selected]
        have count := arrayDeclarationAt_count array
        rw [count.1, count.2.1, count.2.2.1, count.2.2.2, arrayDeclarationAt_booleanNames array]
        omega
      · by_cases boolean : (booleanDeclarationAt text state arguments).position ≠ 0
        · have selected : declarationAt text state arguments = booleanDeclarationAt text state arguments := by
            simp only [declarationAt]; split <;> simp_all
          rw [selected]
          unfold booleanDeclarationAt at boolean ⊢
          dsimp only at boolean ⊢
          split at boolean
          · simp [invalidState] at boolean
          · rename_i ready
            simp only [ready, Bool.false_eq_true, ↓reduceIte]
            split at boolean
            · simp [invalidState] at boolean
            · rename_i advance
              simp only [advance, ↓reduceIte, addBooleanBinding, List.length_append, List.length_singleton]
              omega
        · by_cases character : (characterDeclarationAt text state arguments).position ≠ 0
          · have selected : declarationAt text state arguments = characterDeclarationAt text state arguments := by
              simp only [declarationAt]; split <;> simp_all
            rw [selected]
            unfold characterDeclarationAt at character ⊢
            dsimp only at character ⊢
            split at character
            · simp [invalidState] at character
            · rename_i good
              simp only [good, Bool.false_eq_true, ↓reduceIte, addBinding,
                List.length_append, List.length_singleton]
              omega
          · have selected : declarationAt text state arguments = stringDeclarationAt text state arguments := by
              simp only [declarationAt]; split <;> simp_all
            rw [selected] at accepted ⊢
            unfold stringDeclarationAt at accepted ⊢
            dsimp only at accepted ⊢
            split at accepted
            · simp [invalidState] at accepted
            · rename_i good
              simp only [good, Bool.false_eq_true, ↓reduceIte, addBinding,
                List.length_append, List.length_singleton]
              omega


theorem declarationsAt_equation (text : Source) (state : ParserState) (arguments : Bool)
    (bounded : state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + state.booleanNames.length ≤ (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings)) :
    declarationsAt text state arguments =
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsAt text (declarationAt text state arguments) arguments := by
  have fuel : (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings) + 1 - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + state.booleanNames.length) =
      ((maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings) - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + state.booleanNames.length)) + 1 := by omega
  unfold declarationsAt
  rw [fuel, declarationsLoop]
  by_cases empty : state.position = 0
  · simp [empty]
  · simp only [empty, ↓reduceIte]
    by_cases stop : fixedAfter text state.position "begin" true ≠ 0
    · simp [stop]
    · simp only [stop, ↓reduceIte]
      by_cases failed : (declarationAt text state arguments).position = 0
      · simp [failed]
      · simp only [failed, ↓reduceIte]
        rw [declarationAt_count failed]
        congr 1
        omega


end Silver.Compose
