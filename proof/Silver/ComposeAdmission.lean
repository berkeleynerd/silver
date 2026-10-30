module

public import Silver.ComposeAtomAdmission

@[expose] public section

namespace Silver.Compose
open Named Bindings

def newNameAllowed (text : Source) (state : ParserState) (first after : Nat) (arguments : Bool) : Bool :=
  decide (first ≠ 0 ∧ after > first) && !forbiddenName text first after &&
    (!arguments || !Arguments.forbiddenName text first after) &&
    decide (lookupName text state.names first after = 0 ∧
      ScalarExpression.lookup text state.scalarNames first after = 0 ∧
      ArrayBindings.lookup text state.arrayNames.names first after = 0 ∧
      IntegerSubtypes.lookup text state.subtypeNames first after = 0)

def addBinding (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) : ParserState :=
  {state with position := following, names := state.names ++
    [⟨first, after, value.valueFirst, value.staticLength, value.dynamicSeen, mutable⟩]}

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
    fixedAfter text (declarationFirst text state) "integer" true = declarationAfter text state)

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
      decide (parts.value.minimumLength ≠ parts.value.staticLength) then invalidState
  else addBinding state parts.first parts.after parts.value.value (decide (parts.constantAfter = 0)) parts.following

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
      ArrayBindings.lookup text state.arrayNames.names first after ≠ 0
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
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0)
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

def declarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let subtype := subtypeDeclarationAt text state arguments
  let scalar := scalarDeclarationAt text state arguments
  let array := arrayDeclarationAt text state arguments
  if subtype.position ≠ 0 then subtype
  else if scalar.position ≠ 0 then scalar
  else if array.position ≠ 0 then array else stringDeclarationAt text state arguments

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
  else {addBinding state parts.first parts.after ⟨parts.following, 0, 0, 0, true, true, false, 0⟩ false parts.following with
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
    (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings + 1 -
      (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length)) state

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


theorem lookupList_found (text : Source) (first after : Nat) (names : BindingEnvironment)
    (start : Nat) (found : lookupList text first after start names ≠ 0) :
    ∃ offset info, names[offset]? = some info ∧
      lookupList text first after start names = start + offset ∧
      equalName text info.first info.after first after = true := by
  induction names generalizing start with
  | nil => simp [lookupList] at found
  | cons info rest ih =>
      by_cases same : equalName text info.first info.after first after = true
      · exact ⟨0, info, by simp, by simp [lookupList, same], same⟩
      · have remaining : lookupList text first after (start + 1) rest ≠ 0 := by
          simpa [lookupList, same] using found
        obtain ⟨offset, next, present, value, equal⟩ := ih (start + 1) remaining
        refine ⟨offset + 1, next, by simpa using present, ?_, equal⟩
        simpa [lookupList, same, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using value

theorem lookupName_found {text : Source} {names : BindingEnvironment} {first after : Nat}
    (found : lookupName text names first after ≠ 0) :
    first ≠ 0 ∧ first < after ∧ ∃ info,
      names.get (lookupName text names first after) = some info ∧
      equalName text info.first info.after first after = true := by
  by_cases invalid : first = 0 ∨ after ≤ first
  · simp [lookupName, invalid] at found
  · have valid : first ≠ 0 ∧ first < after := by omega
    have same : lookupName text names first after = lookupList text first after 1 names := by
      simp [lookupName, invalid, lookupFrom]
    rw [same] at found
    obtain ⟨offset, info, present, value, equal⟩ := lookupList_found text first after names 1 found
    refine ⟨valid.1, valid.2, info, ?_, equal⟩
    simp [BindingEnvironment.get, same, value, present, Nat.add_comm]

theorem identifier_not_quote {text bytes : Source} {position after : Nat}
    (parsed : IdentifierAt text position bytes after) : Cursor.byteAt text position ≠ 34 := by
  cases parsed with
  | identifier _ first _ =>
      simp only [letter, decide_eq_true_eq] at first
      omega

/-- The literal alternative is specified by the independent literal grammar. -/
def QuotedValueAt (text : Source) (position : Nat) : Prop :=
  ∃ bytes after, skipAt text position ≠ 0 ∧ skipAt text position ≤ text.length ∧
    Cursor.byteAt text (skipAt text position) = 34 ∧
    Output.LiteralAt text (skipAt text position + 1) bytes after

theorem quotedValue_iff (text : Source) (position : Nat) :
    QuotedValueAt text position ↔ (literalAt text (skipAt text position)).after ≠ 0 := by
  constructor
  · rintro ⟨bytes, after, positive, bound, quote, parsed⟩
    have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
    simp [literalAt, positive, bound, quote, Output.literalAt_complete parsed,
      Guarded.literalLength_decodes parsed, nonzero]
  · intro accepted
    unfold literalAt at accepted
    split at accepted
    · rename_i conditions
      obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ conditions.2.2.2
      exact ⟨bytes, _, conditions.1, conditions.2.1, conditions.2.2.1, parsed⟩
    · simp [invalidValue] at accepted

theorem fixedAfter_result_bound (text : Source) (position : Nat) (word : String)
    (wordFlag : Bool) (nonempty : 0 < word.toList.length) :
    fixedAfter text position word wordFlag ≤ text.length + 1 := by
  unfold fixedAfter
  split
  · omega
  · split
    · rename_i accepted
      have fits : word.toList.length ≤ text.length + 1 - Cursor.triviaPosition text position := by
        simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, List.length_map] at accepted
        exact accepted.1.1
      omega
    · omega

structure ImageReading (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (position : Nat) (expression : Integer.Expr)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : Prop where
  visible : integerHidden = false
  typePresent : (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0
  stringClear : lookupName text names (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  scalarClear : ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  arrayClear : ArrayBindings.lookup text arrays (imageParts text position scalarNames arrays initials elaborating).first
    (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0
  attributePositive : (imageParts text position scalarNames arrays initials elaborating).attributeFirst ≠ 0
  attributeOrdered : (imageParts text position scalarNames arrays initials elaborating).attributeFirst <
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter
  attributeName : Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true
  scalar : ScalarExpression.At text scalarNames (imageParts text position scalarNames arrays initials elaborating).scalarPosition
    expression (imageParts text position scalarNames arrays initials elaborating).scalar
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  following : position < (imageParts text position scalarNames arrays initials elaborating).following

theorem image_complete {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Integer.Expr} (parsed : ImageReading text names scalarNames integerHidden position expression arrays initials elaborating) :
    imageAt text position names scalarNames integerHidden arrays initials elaborating = imageValue (imageParts text position scalarNames arrays initials elaborating) := by
  have attr := parsed.attributeName
  change Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
    (imageParts text position scalarNames arrays initials elaborating).attributeAfter [105, 109, 97, 103, 101] = true at attr
  simp [imageAt, parsed.visible, parsed.typePresent, parsed.stringClear, parsed.scalarClear, parsed.arrayClear,
    parsed.attributePositive, Nat.not_le.mpr parsed.attributeOrdered, attr,
    Nat.not_le.mpr parsed.following]

theorem image_sound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    (accepted : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0) :
    ∃ expression, ImageReading text names scalarNames integerHidden position expression arrays initials elaborating := by
  have good : integerHidden = false ∧ (imageParts text position scalarNames arrays initials elaborating).typeAfter ≠ 0 ∧
      lookupName text names (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ScalarExpression.lookup text scalarNames (imageParts text position scalarNames arrays initials elaborating).first (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      ArrayBindings.lookup text arrays (imageParts text position scalarNames arrays initials elaborating).first
        (imageParts text position scalarNames arrays initials elaborating).typeAfter = 0 ∧
      (imageParts text position scalarNames arrays initials elaborating).attributeFirst ≠ 0 ∧
      (imageParts text position scalarNames arrays initials elaborating).attributeFirst < (imageParts text position scalarNames arrays initials elaborating).attributeAfter ∧
      Named.nameIs text (imageParts text position scalarNames arrays initials elaborating).attributeFirst
        (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true ∧
      position < (imageParts text position scalarNames arrays initials elaborating).following := by
    dsimp only [imageAt] at accepted
    split at accepted
    · simp [invalidValue] at accepted
    · rename_i good
      simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', not_or, Bool.not_eq_true,
        Bool.not_eq_true', Nat.not_le] at good
      rcases good with ⟨⟨⟨hidden, typeGood⟩, attributeName⟩, following⟩
      rcases typeGood with ⟨typePresent, stringClear, scalarClear, arrayClear, attributePositive, attributeOrdered⟩
      have attributeTrue : Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat) = true := by
        rcases Bool.eq_false_or_eq_true (Named.nameIs text
          (imageParts text position scalarNames arrays initials elaborating).attributeFirst
          (imageParts text position scalarNames arrays initials elaborating).attributeAfter ("image".toList.map Char.toNat)) with found | absent
        · exact found
        · exact False.elim (attributeName absent)
      exact ⟨hidden, typePresent, by omega, by omega, by omega,
        attributePositive, attributeOrdered, attributeTrue, following⟩
  have scalarPositive : (imageParts text position scalarNames arrays initials elaborating).scalar.after ≠ 0 := by
    intro zero
    have following := good.2.2.2.2.2.2.2.2
    change position < fixedAfter text (imageParts text position scalarNames arrays initials elaborating).scalar.after ")" false at following
    simp [zero, fixedAfter] at following
  have bound : (imageParts text position scalarNames arrays initials elaborating).scalarPosition ≤ text.length + 1 :=
    fixedAfter_result_bound text _ "(" false (by decide)
  obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound bound scalarPositive
  exact ⟨expression, good.1, good.2.1, good.2.2.1, good.2.2.2.1, good.2.2.2.2.1,
    good.2.2.2.2.2.1, good.2.2.2.2.2.2.1, good.2.2.2.2.2.2.2.1, parsed, good.2.2.2.2.2.2.2.2⟩

inductive ValueAtCore (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    Nat → Operand → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      skipAt text position ≠ 0 → skipAt text position ≤ text.length →
      Cursor.byteAt text (skipAt text position) = 34 →
      Output.LiteralAt text (skipAt text position + 1) bytes after →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.literal bytes)
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0⟩
  | reference {position after index : Nat} {name : Source} {info : BindingInfo} :
      skipAt text position ≠ 0 →
      IdentifierAt text (skipAt text position) name after →
      lookupName text names (skipAt text position) after = index → index ≠ 0 →
      ScalarExpression.lookup text scalarNames (skipAt text position) after = 0 →
      names.get index = some info →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.reference index)
        ⟨after, info.valueFirst, info.staticLength, info.staticLength, info.dynamic, true, false, index⟩
  | image {position : Nat} {expression : Integer.Expr} :
      ¬ QuotedValueAt text position →
      ¬ (lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
        ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0) →
      ImageReading text names scalarNames integerHidden position expression arrays initials elaborating →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.image expression)
        (imageValue (imageParts text position scalarNames arrays initials elaborating))

abbrev ValueAt (text : Source) (names : BindingEnvironment) (position : Nat)
    (value : Operand) (result : ValueResult) (scalarNames : ScalarExpression.Environment := [])
    (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  ValueAtCore text names scalarNames integerHidden arrays initials elaborating position value result

theorem value_complete {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat} {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names = result := by
  cases parsed with
  | literal positive bound quote parsed =>
      rename_i after bytes
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
  | reference positive parsed selected nonzero unmasked present =>
      simp [valueAt, literalAt, identifier_not_quote parsed, nameAfter, positive,
        identifierEnd_complete parsed, selected, nonzero, unmasked, present, invalidValue]
  | image noLiteral noReference parsed =>
      have quoted : (literalAt text (skipAt text position)).after = 0 := by
        by_cases nonzero : (literalAt text (skipAt text position)).after ≠ 0
        · exact False.elim (noLiteral ((quotedValue_iff text position).mpr nonzero))
        · exact Nat.eq_zero_of_not_pos (by omega)
      simp only [valueAt, quoted, ne_eq, not_true_eq_false, ↓reduceIte, noReference]
      exact image_complete parsed

theorem value_sound (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (accepted : (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) :
    ∃ value, ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value
      (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) := by
  by_cases quoted : (literalAt text (skipAt text position)).after ≠ 0
  · obtain ⟨bytes, after, positive, bound, quote, parsed⟩ := (quotedValue_iff text position).mpr quoted
    have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
    refine ⟨.literal bytes, ?_⟩
    have observed : valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names =
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0⟩ := by
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
    rw [observed]
    exact .literal positive bound quote parsed
  · by_cases referenced : lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
        ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0
    · obtain ⟨positive, advanced, info, present, _⟩ := lookupName_found referenced.1
      have afterPositive : nameAfter text (skipAt text position) ≠ 0 := by omega
      have nameAccepted : identifierEnd text (skipAt text position) ≠ 0 := by
        simpa [nameAfter, positive] using afterPositive
      obtain ⟨name, parsed⟩ := identifierEnd_sound text _ nameAccepted
      have afterSame : nameAfter text (skipAt text position) = identifierEnd text (skipAt text position) := by
        simp [nameAfter, positive]
      refine ⟨.reference (lookupName text names (skipAt text position) (nameAfter text (skipAt text position))), ?_⟩
      have observed : valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names =
          ⟨nameAfter text (skipAt text position), info.valueFirst, info.staticLength, info.staticLength,
            info.dynamic, true, false, lookupName text names (skipAt text position) (nameAfter text (skipAt text position))⟩ := by
        simp [valueAt, quoted, referenced, present]
      rw [observed]
      apply ValueAtCore.reference positive
      · simpa [afterSame] using parsed
      · rfl
      · exact referenced.1
      · exact referenced.2
      · exact present
    · have imageAccepted : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0 := by
        simpa only [valueAt, quoted, ↓reduceIte, referenced] using accepted
      obtain ⟨expression, parsed⟩ := image_sound imageAccepted
      refine ⟨.image expression, ?_⟩
      have observed := image_complete parsed
      simp only [valueAt, quoted, ↓reduceIte, referenced, observed]
      exact .image (fun present => quoted ((quotedValue_iff text position).mp present)) referenced parsed

def ValueResult.bound (result : ValueResult) : Bindings.Bound :=
  if result.dynamicSeen then .argument else .fixed result.staticLength

def NamesNormal (names : BindingEnvironment) : Prop :=
  ∀ index info, names.get index = some info → info.dynamic = true → info.staticLength = 0

theorem value_inferLength {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult} (normal : NamesNormal names)
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.inferLength names.shape (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some result.lengthSummary := by
  cases parsed with
  | literal => rfl
  | reference positive identifier selected nonzero unmasked present =>
      rename_i after index name info
      have zero := normal _ _ present
      cases dynamic : info.dynamic
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, BindingInfo.bound, dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary]
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, BindingInfo.bound, dynamic, zero dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary]
  | image _ _ parsed =>
      simp only [Operand.inferLength, parsed.scalar.inferred, Option.map_some,
        ValueResult.lengthSummary, imageValue, LengthSummary.ofImage]
      split <;> rfl

theorem value_literals {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.PrintableLiterals := by
  cases parsed with
  | literal _ _ _ parsed => exact (Output.literalAt_bounds parsed).2.2
  | reference | image => trivial


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

theorem declarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).names.length +
      (declarationAt text state arguments).scalarNames.length +
      (declarationAt text state arguments).arrayNames.names.length +
      (declarationAt text state arguments).subtypeNames.items.length =
      state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length + 1 := by
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
        rw [count.1, count.2.1, count.2.2.1, count.2.2.2]
        omega
      · have selected : declarationAt text state arguments = stringDeclarationAt text state arguments := by
          simp only [declarationAt, subtype, ↓reduceIte]; split <;> simp_all
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
    (bounded : state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length ≤ (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings)) :
    declarationsAt text state arguments =
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsAt text (declarationAt text state arguments) arguments := by
  have fuel : (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings) + 1 - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length) =
      ((maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings) - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length)) + 1 := by omega
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
