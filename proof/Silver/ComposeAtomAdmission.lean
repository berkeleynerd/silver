module

public import Silver.ComposeExpression
public import Silver.Names
public import Silver.ScalarExpressionAdmission
public import Silver.StringLengths
public import Silver.ArrayBindings
public import Silver.IntegerSubtypeBindings
public import Silver.BooleanBindings
public import Silver.ScalarExpressionEnvironment
public import Silver.FunctionBindings

@[expose] public section

/-! Ordered declaration/name admission and the retained body-shell grammar.
Source names resolve to initialized bindings. The recognizer retains fixed
bounds; the independent value semantics retain declaration and assignment reads. -/

namespace Silver.Compose

open Named Bindings

abbrev BindingInfo := Bindings.BindingInfo
abbrev BindingEnvironment := Bindings.BindingEnvironment

def maxBindings : Nat := maxSourceLength / 12

structure ValueResult where
  after : Nat := 0
  valueFirst : Nat := 0
  minimumLength : Nat := 0
  staticLength : Nat := 0
  dynamicSeen : Bool := false
  nonliteralSeen : Bool := false
  emptyValue : Bool := false
  reference : Nat := 0
  operands : Nat := 0
  firstIndex : Integer.Interval := .singleton 1
  lastIndex : Integer.Interval := .singleton 0
  deriving DecidableEq, Repr

structure ExpressionResult where
  after : Nat := 0
  minimumLength : Nat := 0
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  namedSeen : Bool := false
  emptyValue : Bool := false
  firstIndex : Integer.Interval := .singleton 1
  lastIndex : Integer.Interval := .singleton 0
  deriving DecidableEq, Repr

structure ExpressionState where
  position : Nat := 0
  minimumLength : Nat := 0
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  operands : Nat := 0
  depth : Nat := 0
  namedSeen : Bool := false
  needOperand : Bool := true
  complete : Bool := false
  emptyValue : Bool := false
  firstIndex : Integer.Interval := .singleton 1
  lastIndex : Integer.Interval := .singleton 0
  deriving DecidableEq, Repr

structure HiddenMarks where
  integerHidden : Bool := false
  booleanHidden : Bool := false
  characterHidden : Bool := false
  trueHidden : Bool := false
  falseHidden : Bool := false
  deriving DecidableEq, Repr

structure ParserState where
  position : Nat := 1
  names : BindingEnvironment := []
  dynamicFirst : Nat := 0
  dynamicAfter : Nat := 0
  target : Nat := 0
  capacity : Nat := maxSourceLength
  scalarNames : ScalarExpression.Environment := []
  arrayNames : ArrayBindings.Env := {}
  subtypeNames : IntegerSubtypes.Environment := {}
  booleanNames : BooleanBindings.Environment := []
  functions : FunctionBindings.Metadata := {}
  pure : Bool := false
  assignedInFunctions : Bool := false
  «hiding» : HiddenMarks := {}
  firstParameter : Nat := 0
  deriving DecidableEq, Repr

def initialState : ParserState := {}
def invalidState : ParserState := {position := 0, capacity := 0}
def invalidValue : ValueResult := {}
def invalidExpression : ExpressionResult := {}
def invalidExpressionState : ExpressionState := {}

def functionHides (text : Source) (catalog : FunctionBindings.Metadata) (word : String) : Bool :=
  catalog.items.any fun item => Named.nameIs text item.first item.after (word.toList.map Char.toNat)

def formalHides (text : Source) (state : ParserState) (first after : Nat) : Bool :=
  decide (0 < first ∧ first < after ∧ state.firstParameter ≠ 0) &&
    (state.functions.parameters.drop (state.firstParameter - 1)).any
      (fun item => Named.equalName text item.first item.after first after)

inductive Form
  | direct | assignment | argument | guardedArgument | branching | guardedBranching | result | guardedResult
  deriving DecidableEq, Repr

def allForms : List Form :=
  [.direct, .assignment, .argument, .guardedArgument, .branching, .guardedBranching, .result, .guardedResult]

def Form.hasArguments : Form → Bool
  | .direct | .assignment => false
  | _ => true

def Form.hasAssignment : Form → Bool
  | .assignment | .result | .guardedResult => true
  | _ => false

inductive ShellToken
  | fixed (spelling : String) (word : Bool)
  | contextClauses | declarations | argumentDeclaration | assignmentTarget | targetReference | dynamicReference
  | assignmentValue | outputExpression | comparisonExpression | literal | capacity
  deriving DecidableEq, Repr

def ShellToken.word (spelling : String) : ShellToken := .fixed spelling true
def ShellToken.symbol (spelling : String) : ShellToken := .fixed spelling false

def fixedAt (text : Source) (position : Nat) (spelling : String) (word : Bool) : Bool :=
  let bytes := spelling.toList.map Char.toNat
  decide (bytes.length ≤ text.length + 1 - position) &&
    decide (∀ index : Fin bytes.length,
      lowercase (Cursor.byteAt text (position + index.val)) = bytes[index.val]) &&
    (!word || decide (position + bytes.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + bytes.length)))

def skipAt (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else Cursor.triviaPosition text position

def nameAfter (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else identifierEnd text position

def fixedAfter (text : Source) (position : Nat) (spelling : String) (word : Bool) : Nat :=
  if position = 0 then 0
  else if fixedAt text (Cursor.triviaPosition text position) spelling word then
    Cursor.triviaPosition text position + spelling.toList.length else 0

def tokenAfter (text : Source) (position : Nat) : ShellToken → Nat
  | .fixed spelling word => fixedAfter text position spelling word
  | _ => 0

def lookupList (text : Source) (first after index : Nat) : BindingEnvironment → Nat
  | [] => 0
  | info :: rest =>
      if equalName text info.first info.after first after then index
      else lookupList text first after (index + 1) rest

def lookupFrom (text : Source) (names : BindingEnvironment) (first after index : Nat) : Nat :=
  lookupList text first after index (names.drop (index - 1))

def lookupName (text : Source) (names : BindingEnvironment) (first after : Nat) : Nat :=
  if first = 0 ∨ after ≤ first then 0 else lookupFrom text names first after 1

def callAfter (text : Source) (names : BindingEnvironment) (position : Nat)
    (operation : Names.Operation) (scalarNames : ScalarExpression.Environment := [])
    (arrays : ArrayBindings.Metadata := []) (subtypeHidden : Bool := false)
    (booleans : BooleanBindings.Environment := []) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  Names.operationAfter text position operation (decide (lookupName text names first after ≠ 0 ∨ ScalarExpression.lookup text scalarNames first after ≠ 0 ∨
    ArrayBindings.lookup text arrays first after ≠ 0 ∨
    BooleanBindings.lookup text booleans first after ≠ 0) || subtypeHidden)


def literalAt (text : Source) (position : Nat) : ValueResult :=
  if position ≠ 0 ∧ position ≤ text.length ∧ Cursor.byteAt text position = 34 ∧
      Output.literalEnd text (position + 1) ≠ 0 then
    ⟨Output.literalEnd text (position + 1), position + 1,
      Guarded.literalLength text (position + 1), Guarded.literalLength text (position + 1),
      false, false, false, 0, 1, .singleton 1,
      .singleton (Guarded.literalLength text (position + 1))⟩
  else invalidValue

def characterLiteralAfter (text : Source) (position : Nat) : Nat :=
  if position ≠ 0 ∧ position + 2 ≤ text.length ∧ Cursor.byteAt text position = 39 ∧
      32 ≤ Cursor.byteAt text (position + 1) ∧ Cursor.byteAt text (position + 1) ≤ 126 ∧
      Cursor.byteAt text (position + 2) = 39
  then position + 3 else 0

theorem characterLiteralAfter_bounds {text : Source} {position : Nat}
    (accepted : characterLiteralAfter text position ≠ 0) :
    position < characterLiteralAfter text position ∧ characterLiteralAfter text position ≤ text.length + 1 := by
  unfold characterLiteralAfter at accepted ⊢
  split at accepted
  · rename_i allowed
    rw [ite_eq_left allowed]
    omega
  · contradiction

theorem characterLiteralAfter_printable {text : Source} {position : Nat}
    (accepted : characterLiteralAfter text position ≠ 0) :
    Output.printable (Cursor.byteAt text (position + 1)) = true := by
  unfold characterLiteralAfter at accepted
  split at accepted
  · rename_i allowed
    simp only [Output.printable, decide_eq_true_eq]
    exact ⟨allowed.2.2.2.1, allowed.2.2.2.2.1⟩
  · contradiction

def ValueResult.lengthSummary (result : ValueResult) : LengthSummary :=
  ⟨result.minimumLength, result.staticLength, if result.dynamicSeen then 1 else 0, result.emptyValue⟩

def ExpressionResult.lengthSummary (result : ExpressionResult) : LengthSummary :=
  ⟨result.minimumLength, result.staticLength, result.dynamicCount, result.emptyValue⟩

def ExpressionState.lengthSummary (state : ExpressionState) : LengthSummary :=
  ⟨state.minimumLength, state.staticLength, state.dynamicCount, state.emptyValue⟩

structure ImageParts where
  first : Nat
  typeAfter : Nat
  attributeFirst : Nat
  attributeAfter : Nat
  scalarPosition : Nat
  scalar : ScalarExpression.Result
  following : Nat
  deriving DecidableEq, Repr

def imageParts (text : Source) (position : Nat) (scalarNames : ScalarExpression.Environment)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ImageParts :=
  let first := skipAt text position
  let typeAfter := fixedAfter text first "integer" true
  let attributeFirst := skipAt text (fixedAfter text typeAfter "'" false)
  let attributeAfter := nameAfter text attributeFirst
  let scalarPosition := fixedAfter text attributeAfter "(" false
  let scalar := ScalarExpression.read text scalarPosition scalarNames (arrays := arrays)
    (initials := initials) (elaborating := elaborating)
  ⟨first, typeAfter, attributeFirst, attributeAfter, scalarPosition, scalar,
    fixedAfter text scalar.after ")" false⟩

def imageValue (parts : ImageParts) : ValueResult :=
  let lengths := LengthSummary.ofImage parts.scalar.bounds
  ⟨parts.following, 0, lengths.minimumLength, lengths.staticLength, false, true, lengths.empty, 0,
    1, .singleton 1, ⟨lengths.minimumLength, lengths.staticLength⟩⟩

def imageAt (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ValueResult :=
  let parts := imageParts text position scalarNames arrays initials elaborating
  if integerHidden || decide (parts.typeAfter = 0 ∨
      lookupName text names parts.first parts.typeAfter ≠ 0 ∨
      ScalarExpression.lookup text scalarNames parts.first parts.typeAfter ≠ 0 ∨
      ArrayBindings.lookup text arrays parts.first parts.typeAfter ≠ 0 ∨
      parts.attributeFirst = 0 ∨ parts.attributeAfter ≤ parts.attributeFirst) ||
      !Named.nameIs text parts.attributeFirst parts.attributeAfter ("image".toList.map Char.toNat) ||
      decide (parts.following ≤ position)
  then invalidValue else imageValue parts

structure IndexedParts where
  first : Nat
  after : Nat
  target : Nat
  lower : ScalarExpression.Result
  upper : ScalarExpression.Result
  following : Nat
  deriving DecidableEq, Repr

/-- Pinned-native context restriction for slice endpoints. Whole tokens are
scanned; Boolean-chain suffixes conservatively last until the next semicolon.
The initial domain check only totalizes calls outside the native precondition. -/
def guardedAt (text : Source) (position limit depth : Nat) (chained ending : Bool) : Bool :=
  if position = 0 ∨ position > text.length + 1 ∨ limit > text.length + 1 then false else
  let first := skipAt text position
  let after := nameAfter text first
  let characterAfter := characterLiteralAfter text first
  let quotedAfter := (literalAt text first).after
  let named (word : String) := Named.nameIs text first after (word.toList.map Char.toNat)
  let nextChained := chained || (decide (after > first) && (named "and" || named "or" || named "xor"))
  let nextEnding := decide (after > first) && named "end"
  let afterPunctuation := chained && (decide (first > text.length) || decide (Cursor.byteAt text first ≠ 59))
  if first ≥ limit then decide (depth ≠ 0) || chained
  else if characterAfter > first then guardedAt text characterAfter limit depth chained false
  else if quotedAfter > first then guardedAt text quotedAfter limit depth chained false
  else if after > first then
    if named "if" then
      if ending && decide (depth ≠ 0) then guardedAt text after limit (depth - 1) chained false
      else if ending then guardedAt text after limit 0 chained false
      else if depth = maxSourceLength then true
      else guardedAt text after limit (depth + 1) chained false
    else guardedAt text after limit depth nextChained nextEnding
  else guardedAt text (first + 1) limit depth afterPunctuation false
termination_by text.length + 1 - position
decreasing_by
  all_goals
    have positive : position ≠ 0 := by omega
    have skipped := Cursor.triviaPosition_bounds text position (by omega) (by omega)
    simp +zetaDelta only [skipAt, positive, ↓reduceIte] at *
    omega

def indexedParts (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) : IndexedParts :=
  let first := skipAt text position
  let after := nameAfter text first
  let target := lookupName text names first after
  let lower := ScalarExpression.read text (fixedAfter text after "(" false) scalarNames
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  let upper := ScalarExpression.read text (fixedAfter text lower.after ".." false) scalarNames
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  ⟨first, after, target, lower, upper,
    fixedAfter text (if element then lower.after else upper.after) ")" false⟩

def indexedAt (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) : ValueResult :=
  let parts := indexedParts text position names scalarNames arrays initials elaborating element
  let info := (names.get parts.target).getD {}
  if parts.target = 0 ∨ info.isCharacter = true ∨ info.dynamic = true ∨
      ScalarExpression.lookup text scalarNames parts.first parts.after ≠ 0 ∨
      parts.lower.after = 0 ∨ parts.lower.bounds.isEmpty = true then invalidValue
  else if element then
    if parts.following ≤ position ∨ parts.lower.operands = maxExpressionOperands ∨
        parts.lower.bounds.lower < info.firstIndex ∨ info.lastIndex < parts.lower.bounds.upper
    then invalidValue
    else ⟨parts.following, 0, 1, 1, false, true, false, parts.target,
      parts.lower.operands + 1, .singleton 1, .singleton 1⟩
  else if parts.following ≤ position ∨ parts.upper.bounds.isEmpty = true ∨
      parts.lower.operands + parts.upper.operands ≥ maxExpressionOperands ∨
      parts.lower.bounds.upper - parts.upper.bounds.lower > Integer.maxValue ∨
      ((!parts.lower.isStatic || !parts.upper.isStatic) && guardedAt text 1 position 0 false false) = true ∨
      (parts.lower.bounds.lower ≤ parts.upper.bounds.upper ∧
        (parts.lower.bounds.lower < info.firstIndex ∨ info.lastIndex < parts.upper.bounds.upper))
    then invalidValue
  else
    let minimum := StringIndexing.sliceMinimum parts.lower.bounds parts.upper.bounds
    let maximum := StringIndexing.sliceMaximum parts.lower.bounds parts.upper.bounds
    if maximum > maxSourceLength then invalidValue else
      ⟨parts.following, 0, minimum, maximum, false, true, false, parts.target,
        parts.lower.operands + parts.upper.operands + 1, parts.lower.bounds, parts.upper.bounds⟩

def characterAt (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : ValueResult :=
  let first := skipAt text position
  let quoted := characterLiteralAfter text first
  let after := nameAfter text first
  let target := lookupName text names first after
  let openAfter := fixedAfter text first "(" false
  if openAfter ≠ 0 then
    if _advancing : text.length + 1 - openAfter < text.length + 1 - position then
      let inner := characterAt text openAfter names scalarNames arrays initials elaborating
      {inner with after := fixedAfter text inner.after ")" false}
    else invalidValue
  else if quoted ≠ 0 then
    ⟨quoted, 0, 1, 1, false, false, false, 0, 1, .singleton 1, .singleton 1⟩
  else if target ≠ 0 ∧ ((names.get target).getD {}).isCharacter = true ∧
      ScalarExpression.lookup text scalarNames first after = 0 then
    ⟨after, 0, 1, 1, false, true, false, target, 1, .singleton 1, .singleton 1⟩
  else indexedAt text position names scalarNames arrays initials elaborating true
termination_by text.length + 1 - position

def valueAt (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ValueResult :=
  let first := skipAt text position
  let quoted := literalAt text first
  let after := nameAfter text first
  let index := lookupName text names first after
  let info := (names.get index).getD {}
  if quoted.after ≠ 0 then quoted
  else if index ≠ 0 ∧ info.isCharacter = false ∧ fixedAfter text after "(" false ≠ 0 then
    indexedAt text position names scalarNames arrays initials elaborating false
  else if index ≠ 0 ∧ info.isCharacter = false ∧ ScalarExpression.lookup text scalarNames first after = 0 then
    ⟨after, info.valueFirst, info.staticLength, info.staticLength, info.dynamic, true, false, index,
      1, .singleton info.firstIndex,
      if info.dynamic then ⟨0, maxSourceLength⟩ else .singleton info.lastIndex⟩
  else imageAt text position names scalarNames integerHidden arrays initials elaborating

/-- Share one 64-leaf expression's operator allowance across all source
positions. Integer arithmetic and String concatenation use one proof-work budget. -/
def maxConcatenations : Nat := 63

/-- Count only operator tokens: trivia skips comments and a quoted literal is
consumed whole, including doubled quotes. Identifiers are consumed whole before
numerals, so a suffix such as `1E` cannot hide the `+` following `N1E`.
The extra decreasing test only makes
this source scanner total outside the native routine's verified domains. -/
def workTail (text : Source) (position remaining : Nat) : Bool :=
  let first := skipAt text position
  let quoted := literalAt text first
  let afterName := nameAfter text first
  let number := ScalarLiteral.read text first
  if first = 0 then false
  else if first > text.length then true
  else if characterLiteralAfter text first ≠ 0 then
    if _advancing : text.length + 1 - characterLiteralAfter text first < text.length + 1 - position then
      workTail text (characterLiteralAfter text first) remaining
    else false
  else if Cursor.byteAt text first = 34 then
    if quoted.after = 0 then false
    else if _advancing : text.length + 1 - quoted.after < text.length + 1 - position then
      workTail text quoted.after remaining
    else false
  else if afterName ≠ 0 then
    if Named.nameIs text first afterName ("mod".toList.map Char.toNat) || Named.nameIs text first afterName ("rem".toList.map Char.toNat) then
      if remaining = 0 then false
      else if _advancing : text.length + 1 - afterName < text.length + 1 - position then
        workTail text afterName (remaining - 1)
      else false
    else if _advancing : text.length + 1 - afterName < text.length + 1 - position then
      workTail text afterName remaining
    else false
  else if number.after ≠ 0 then
    if _advancing : text.length + 1 - number.after < text.length + 1 - position then
      workTail text number.after remaining
    else false
  else if Cursor.byteAt text first = 47 ∧ first < text.length ∧ Cursor.byteAt text (first + 1) = 61 then
    if _advancing : text.length + 1 - (first + 2) < text.length + 1 - position then
      workTail text (first + 2) remaining
    else false
  else if Cursor.byteAt text first = 38 ∨ Cursor.byteAt text first = 43 ∨
      Cursor.byteAt text first = 45 ∨ Cursor.byteAt text first = 42 ∨ Cursor.byteAt text first = 47 then
    if remaining = 0 then false
    else if _advancing : text.length + 1 - (first + 1) < text.length + 1 - position then
      workTail text (first + 1) (remaining - 1)
    else false
  else if _advancing : text.length + 1 - (first + 1) < text.length + 1 - position then
    workTail text (first + 1) remaining
  else false
termination_by text.length + 1 - position

def withinWorkBudget (text : Source) : Bool := workTail text 1 maxConcatenations

theorem skipAt_advances (text : Source) (position : Nat)
    (bound : position ≤ text.length + 1) (nonzero : skipAt text position ≠ 0) :
    position ≤ skipAt text position := by
  have positive : position ≠ 0 := by intro zero; simp [skipAt, zero] at nonzero
  simp only [skipAt, positive, ↓reduceIte]
  exact (Cursor.triviaPosition_bounds text position (by omega) bound).1

theorem literalAt_advances (text : Source) (position : Nat)
    (nonzero : (literalAt text position).after ≠ 0) :
    position < (literalAt text position).after := by
  unfold literalAt at nonzero ⊢
  split
  · rename_i conditions
    have bounds := Output.literalEnd_bounds text (position + 1) conditions.2.2.2
    simp only
    omega
  · rename_i missing
    simp [missing, invalidValue] at nonzero

def ValidExpressionState (text : Source) (state : ExpressionState) : Prop :=
  state.position ≤ text.length + 1 ∧ state.dynamicCount ≤ state.operands ∧
    (state.position = 0 ∨ state.depth < state.position)

def concatenatedFirst (left : ExpressionState) (right : ValueResult) : Integer.Interval :=
  if left.operands = 0 ∨ (left.staticLength = 0 ∧ left.dynamicCount = 0) then right.firstIndex
  else if left.minimumLength > 0 then left.firstIndex
  else left.firstIndex.join right.firstIndex

def concatenatedLast (left : ExpressionState) (right : ValueResult) : Integer.Interval :=
  let first := concatenatedFirst left right
  let minimum : Int := (left.minimumLength : Int) + right.minimumLength
  let maximum : Int := (left.staticLength : Int) + right.staticLength +
    ((left.dynamicCount : Int) + (if right.dynamicSeen then 1 else 0)) * maxSourceLength
  let low := first.lower + minimum - 1
  let high := first.upper + maximum - 1
  if left.operands = 0 ∨ (left.staticLength = 0 ∧ left.dynamicCount = 0) then right.lastIndex
  else if first.isEmpty = true ∨ low < Integer.minValue ∨ low > Integer.maxValue ∨
      high < Integer.minValue ∨ high > Integer.maxValue then .empty
  else if minimum = 0 then (Integer.Interval.mk low high).join right.lastIndex
  else ⟨low, high⟩

def expressionStep (text : Source) (names : BindingEnvironment) (state : ExpressionState)
    (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ExpressionState :=
  let openAfter := fixedAfter text state.position "(" false
  let atom := valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names
  let joinAfter := fixedAfter text state.position "&" false
  let closeAfter := fixedAfter text state.position ")" false
  if state.position = 0 then invalidExpressionState
  else if state.complete then state
  else if state.needOperand then
    if openAfter ≠ 0 then {state with position := openAfter, depth := state.depth + 1}
    else if atom.after = 0 ∨ atom.operands > maxExpressionOperands - state.operands ∨
        (elaborating = true ∧ state.dynamicCount = 0 ∧ atom.dynamicSeen = false ∧
          ((concatenatedFirst state atom).isEmpty = true ∨ (concatenatedLast state atom).isEmpty = true)) ∨
        atom.staticLength > maxSourceLength - state.staticLength ∨
        atom.minimumLength > maxSourceLength - state.minimumLength then invalidExpressionState
    else {state with
      position := atom.after
      minimumLength := state.minimumLength + atom.minimumLength
      staticLength := state.staticLength + atom.staticLength
      dynamicCount := state.dynamicCount + (if atom.dynamicSeen then 1 else 0)
      operands := state.operands + atom.operands
      firstIndex := if elaborating && decide (state.dynamicCount = 0) && !atom.dynamicSeen
        then concatenatedFirst state atom else .singleton 1
      lastIndex := if elaborating && decide (state.dynamicCount = 0) && !atom.dynamicSeen
        then concatenatedLast state atom else .singleton 0
      namedSeen := state.namedSeen || atom.nonliteralSeen
      emptyValue := state.emptyValue || atom.emptyValue
      needOperand := false}
  else if joinAfter ≠ 0 then {state with position := joinAfter, needOperand := true}
  else if closeAfter ≠ 0 ∧ state.depth ≠ 0 then {state with position := closeAfter, depth := state.depth - 1}
  else if state.depth = 0 then {state with complete := true}
  else invalidExpressionState

def ExpressionState.result (state : ExpressionState) : ExpressionResult :=
  ⟨state.position, state.minimumLength, state.staticLength, state.dynamicCount, state.namedSeen,
    state.emptyValue, state.firstIndex, state.lastIndex⟩

def expressionTail (text : Source) (names : BindingEnvironment) (state : ExpressionState)
    (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ExpressionResult :=
  if state.position = 0 then invalidExpression
  else if state.complete then state.result
  else
    let next := expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state
    if next.position = 0 then invalidExpression
    else if next.complete then next.result
    else if _advancing : text.length + 1 - next.position < text.length + 1 - state.position then
      expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names next
    else invalidExpression
termination_by text.length + 1 - state.position
decreasing_by exact _advancing

def expressionAt (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : ExpressionResult :=
  expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names {position := position}

def fits (result : ExpressionResult) (capacity : Nat) : Bool :=
  decide (result.after ≠ 0 ∧ (result.emptyValue = true ∨ result.staticLength + result.dynamicCount * capacity ≤ maxSourceLength))

def ExpressionResult.value (result : ExpressionResult) : ValueResult :=
  ⟨result.after, 0, result.minimumLength, result.staticLength, decide (result.dynamicCount = 1),
    result.namedSeen, result.emptyValue, 0, 1, result.firstIndex, result.lastIndex⟩


end Silver.Compose
