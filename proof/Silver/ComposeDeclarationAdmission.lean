module

public import Silver.ComposeAtoms
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
      ArrayBindings.lookupType text state.arrayNames.types first after = 0 ∧
      BooleanBindings.lookup text state.booleanNames first after = 0 ∧
      IntegerSubtypes.lookup text state.subtypeNames first after = 0) &&
    !formalHides text state first after &&
    (state.pure || decide (FunctionBindings.lookup text state.functions first after = 0 ∧
      ProcedureBindings.lookup text state.procedures first after = 0))

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
    BooleanBindings.hidesInteger text state.booleanNames || state.hiding.integerHidden

def declarationParts (text : Source) (state : ParserState) : DeclarationParts :=
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true,
    fixedAfter text (expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true).after ";" false⟩

def fixedDeclarationBounds (value : ExpressionResult) (slot : Nat) : Bool :=
  !(decide (value.dynamicCount = 0) &&
    (value.firstIndex.isEmpty || value.lastIndex.isEmpty ||
      decide (value.firstIndex.lower ≠ value.firstIndex.upper ∨
        value.lastIndex.lower ≠ value.lastIndex.upper))) &&
  fixedBoundsValid value.staticLength (decide (value.dynamicCount = 1)) false
    value.firstIndex.lower value.lastIndex.lower slot

def stringDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := declarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.following = 0 ∨ state.names.length = maxBindings) ||
      !fits parts.value maxSourceLength || parts.value.emptyValue ||
      decide (parts.value.minimumLength ≠ parts.value.staticLength) ||
      !fixedDeclarationBounds parts.value (state.names.length + 1)
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

def characterDeclarationRejected (text : Source) (state : ParserState) (arguments : Bool)
    (parts : CharacterDeclarationParts) : Bool :=
  !newNameAllowed text state parts.first parts.after arguments ||
    decide (parts.typeAfter = 0 ∨ parts.following = 0 ∨ state.names.length = maxBindings) ||
    Named.nameIs text parts.first parts.after ("character".toList.map Char.toNat) ||
    decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
      ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
      ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0 ∨
      IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter ≠ 0 ∨
      BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter ≠ 0 ∨
        ProcedureBindings.lookup text state.procedures parts.typeFirst parts.typeAfter ≠ 0 ∨
        formalHides text state parts.typeFirst parts.typeAfter ∨
        (state.hiding.integerHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat)) ∨
        (state.hiding.booleanHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat)) ∨
        (state.hiding.characterHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat)))

def characterDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := characterDeclarationParts text state
  if characterDeclarationRejected text state arguments parts then invalidState
  else addBinding state parts.first parts.after parts.value (decide (parts.constantAfter = 0)) parts.following true

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
      BooleanBindings.lookup text state.booleanNames first after ≠ 0 ∨
      FunctionBindings.lookup text state.functions first after ≠ 0 ∨
      ProcedureBindings.lookup text state.procedures first after ≠ 0 ∨
      formalHides text state first after ∨
      (state.hiding.integerHidden && Named.nameIs text first after ("integer".toList.map Char.toNat))
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

def arrayTypeAt (text : Source) (state : ParserState) (position : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first = 0 ∨ after ≤ first ∨ lookupName text state.names first after ≠ 0 ∨
      ScalarExpression.lookup text state.scalarNames first after ≠ 0 ∨
      ArrayBindings.lookup text state.arrayNames.names first after ≠ 0 ∨
      BooleanBindings.lookup text state.booleanNames first after ≠ 0 ∨
      FunctionBindings.lookup text state.functions first after ≠ 0 ∨
      ProcedureBindings.lookup text state.procedures first after ≠ 0 ∨ formalHides text state first after
  then 0 else ArrayBindings.lookupType text state.arrayNames.types first after

def arrayTypeDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let first := skipAt text (fixedAfter text state.position "type" true)
  let after := nameAfter text first
  let start := fixedAfter text (fixedAfter text (fixedAfter text after "is" true) "array" true) "(" false
  let low := ScalarExpression.ArrayGrammar.read text start state.scalarNames state.arrayNames.table
  let high := ScalarExpression.ArrayGrammar.read text (fixedAfter text low.after ".." false)
    state.scalarNames state.arrayNames.table
  let component := scalarTypeAt text state
    (fixedAfter text (fixedAfter text high.after ")" false) "of" true)
  let following := fixedAfter text component.after ";" false
  if start = 0 ∨ following ≤ state.position ∨ state.pure ∨
      !newNameAllowed text state first after arguments ∨
      Named.nameIs text first after ("integer".toList.map Char.toNat) ∨
      state.arrayNames.types.length = ArrayBindings.maxTypes ∨
      low.after = 0 ∨ high.after = 0 ∨ component.after = 0 ∨ !low.isStatic ∨ !high.isStatic ∨
      low.bounds.isEmpty ∨ high.bounds.isEmpty ∨
      low.bounds.lower ≠ low.bounds.upper ∨ high.bounds.lower ≠ high.bounds.upper ∨
      low.bounds.lower > high.bounds.lower ∨
      high.bounds.lower - low.bounds.lower ≥ (ArrayBindings.maxElements : Int)
  then invalidState
  else {state with
    position := following,
    arrayNames := {state.arrayNames with types := state.arrayNames.types ++
      [⟨first, after, ⟨low.bounds.lower, high.bounds.lower⟩, component.bounds⟩]},
    subtypeNames := {state.subtypeNames with
      trueHidden := state.subtypeNames.trueHidden || Named.nameIs text first after ("true".toList.map Char.toNat),
      falseHidden := state.subtypeNames.falseHidden || Named.nameIs text first after ("false".toList.map Char.toNat),
      hiddenCalls := state.subtypeNames.hiddenCalls.add text first after}}

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
        BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter ≠ 0 ∨
        ProcedureBindings.lookup text state.procedures parts.typeFirst parts.typeAfter ≠ 0 ∨
        formalHides text state parts.typeFirst parts.typeAfter ∨
        (state.hiding.integerHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat)) ∨
        (state.hiding.booleanHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat)) ∨
        (state.hiding.characterHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat)))
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
  isBoolean : Bool := false
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
  let integerType := scalarTypeAt text state typeFirst
  let isBoolean := decide (integerType.after = 0) && decide (fixedAfter text typeFirst "boolean" true ≠ 0)
  let typeMark := if isBoolean then
      ScalarConstraintResult.mk (fixedAfter text typeFirst "boolean" true) .full
    else integerType
  let typeAfter := typeMark.after
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    arrayAfter, lower, upper, typeFirst, typeAfter, typeMark.bounds,
    fixedAfter text (fixedAfter text typeAfter ":=" false) "(" false, isBoolean⟩

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

/-- Every Boolean aggregate component is read before the new array is visible.
The parser retains only a cursor and reserves cells; the raw source reading and
semantic declaration retain the Boolean expressions and their values. -/
def booleanInitializerContext (state : ParserState) (maskFirst maskAfter : Nat) : Predicate.ParseContext :=
  { names := state.names
    hasArguments := decide (state.dynamicFirst ≠ 0)
    scalarNames := state.scalarNames
    declarationCount := state.scalarNames.length
    arrayNames := state.arrayNames.names
    arrayTypes := state.arrayNames.types
    subtypeHiding := state.subtypeNames.hiddenCalls
    booleanNames := state.booleanNames
    trueHidden := state.subtypeNames.trueHidden || state.hiding.trueHidden
    falseHidden := state.subtypeNames.falseHidden || state.hiding.falseHidden
    pure := state.pure
    outerIntegerHidden := state.hiding.integerHidden
    elaborating := true
    maskFirst := maskFirst
    maskAfter := maskAfter }

def booleanInitializerFacts (state : ParserState) : Predicate.ActiveFlow :=
  Predicate.ActiveFlow.initial state.scalarNames
    (if state.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
      else ⟨some ⟨0, 0⟩, false, false⟩)

def booleanInitializerAfter (text : Source) (state : ParserState)
    (position maskFirst maskAfter : Nat) : Nat :=
  (Predicate.readCondition text (booleanInitializerContext state maskFirst maskAfter)
    position (booleanInitializerFacts state) state.arrayNames.values).after

def booleanArrayValuesModel (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat) : ParserState :=
  if position = 0 then invalidState else
  if _remaining : parsed < length then
    let valueAfter := booleanInitializerAfter text source position maskFirst maskAfter
    if valueAfter = 0 then invalidState else
      let next := {result with arrayNames := {result.arrayNames with
        used := result.arrayNames.used + 1,
        values := ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) 0}}
      let following := if parsed + 1 < length then fixedAfter text valueAfter "," false else valueAfter
      booleanArrayValuesModel text source next following length (parsed + 1) maskFirst maskAfter
  else {result with position := position}
termination_by length - parsed
decreasing_by omega

def arrayDeclarationValues (text : Source) (state : ParserState)
    (parts : ArrayDeclarationParts) (position length : Nat) : ParserState :=
  if parts.isBoolean then
    booleanArrayValuesModel text state state position length 0 parts.first parts.after
  else arrayValuesModel text state state position length 0 parts.componentBounds

def ArrayDeclarationParts.typeWord (parts : ArrayDeclarationParts) : Source :=
  (if parts.isBoolean then "boolean" else "integer").toList.map Char.toNat

def arrayDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := arrayDeclarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      Named.nameIs text parts.first parts.after parts.typeWord ||
      decide (parts.arrayAfter = 0 ∨ parts.position = 0 ∨
        state.arrayNames.names.length = ArrayBindings.maxBindings ∨
        parts.lower.after = 0 ∨ parts.upper.after = 0) ||
      !parts.lower.isStatic || !parts.upper.isStatic || parts.lower.bounds.isEmpty || parts.upper.bounds.isEmpty ||
      decide (parts.lower.bounds.lower ≠ parts.lower.bounds.upper ∨
        parts.upper.bounds.lower ≠ parts.upper.bounds.upper ∨ parts.lower.bounds.lower > parts.upper.bounds.lower ∨
        parts.upper.bounds.lower - parts.lower.bounds.lower ≥ (ArrayBindings.maxElements - state.arrayNames.used : Nat)) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter ≠ 0 ∨
        ProcedureBindings.lookup text state.procedures parts.typeFirst parts.typeAfter ≠ 0 ∨
        formalHides text state parts.typeFirst parts.typeAfter ∨
        (state.hiding.integerHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat)) ∨
        (state.hiding.booleanHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat)) ∨
        (state.hiding.characterHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat)) ∨
        (parts.isBoolean = true ∧ IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter ≠ 0))
  then invalidState else
    let length := (parts.upper.bounds.lower - parts.lower.bounds.lower + 1).toNat
    let position := arrayAggregatePosition text state parts length
    if position = 0 then invalidState else
      let result := arrayDeclarationValues text state parts position length
      if result.position = 0 then invalidState else
        let following := fixedAfter text (fixedAfter text result.position ")" false) ";" false
        if following ≤ state.position then invalidState else
          {result with position := following, arrayNames := {result.arrayNames with
            names := result.arrayNames.names ++ [⟨parts.first, parts.after,
              ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩,
              state.arrayNames.used, length, decide (parts.constantAfter = 0), parts.componentBounds,
              parts.isBoolean, 0, 0⟩]}}

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
      BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter = 0 ∧
      FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter = 0 ∧
      ProcedureBindings.lookup text state.procedures parts.typeFirst parts.typeAfter = 0) &&
    !formalHides text state parts.typeFirst parts.typeAfter &&
    !(state.hiding.integerHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat)) &&
    !(state.hiding.booleanHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat)) &&
    !(state.hiding.characterHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat))

def booleanDeclarationContext (state : ParserState) (parts : BooleanDeclarationParts) : Predicate.ParseContext :=
  { names := state.names
    hasArguments := decide (state.dynamicFirst ≠ 0)
    scalarNames := state.scalarNames
    declarationCount := state.scalarNames.length
    arrayNames := state.arrayNames.names
    arrayTypes := state.arrayNames.types
    subtypeHiding := state.subtypeNames.hiddenCalls
    booleanNames := state.booleanNames
    trueHidden := state.subtypeNames.trueHidden || state.hiding.trueHidden
    falseHidden := state.subtypeNames.falseHidden || state.hiding.falseHidden
    pure := state.pure
    outerIntegerHidden := state.hiding.integerHidden
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

def targetAt (text : Source) (state : ParserState) (sameTarget : Bool) : ParserState :=
  let first := skipAt text state.position
  let after := nameAfter text first
  let index := lookupName text state.names first after
  let info := (state.names.get index).getD {}
  if index = 0 ∨ ScalarExpression.lookup text state.scalarNames first after ≠ 0 ∨
      info.mutable = false ∨ (sameTarget = true ∧ index ≠ state.target) then invalidState
  else {state with position := after, target := index}


end Silver.Compose
