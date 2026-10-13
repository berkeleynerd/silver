module

public import Silver.ComposeExpression

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
  staticLength : Nat := 0
  dynamicSeen : Bool := false
  reference : Nat := 0
  deriving DecidableEq, Repr

structure ExpressionResult where
  after : Nat := 0
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  namedSeen : Bool := false
  deriving DecidableEq, Repr

structure ExpressionState where
  position : Nat := 0
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  operands : Nat := 0
  depth : Nat := 0
  namedSeen : Bool := false
  needOperand : Bool := true
  complete : Bool := false
  deriving DecidableEq, Repr

structure ParserState where
  position : Nat := 1
  names : BindingEnvironment := []
  dynamicFirst : Nat := 0
  dynamicAfter : Nat := 0
  target : Nat := 0
  capacity : Nat := maxSourceLength
  deriving DecidableEq, Repr

def initialState : ParserState := {}
def invalidState : ParserState := {position := 0, capacity := 0}
def invalidValue : ValueResult := {}
def invalidExpression : ExpressionResult := {}
def invalidExpressionState : ExpressionState := {}

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
  | declarations | argumentDeclaration | assignmentTarget | targetReference | dynamicReference
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

def literalAt (text : Source) (position : Nat) : ValueResult :=
  if position ≠ 0 ∧ position ≤ text.length ∧ Cursor.byteAt text position = 34 ∧
      Output.literalEnd text (position + 1) ≠ 0 then
    ⟨Output.literalEnd text (position + 1), position + 1,
      Guarded.literalLength text (position + 1), false, 0⟩
  else invalidValue

def valueAt (text : Source) (position : Nat) (names : BindingEnvironment) : ValueResult :=
  let first := skipAt text position
  let quoted := literalAt text first
  let after := nameAfter text first
  let index := lookupName text names first after
  if quoted.after ≠ 0 then quoted
  else if index ≠ 0 then
    let info := (names.get index).getD {}
    ⟨after, info.valueFirst, info.staticLength, info.dynamic, index⟩
  else invalidValue

/-- Preserve the former two-output shell's total `2 * (16 - 1)`
concatenation allowance while sharing it across expression positions. -/
def maxConcatenations : Nat := 30

/-- Count only operator tokens: trivia skips comments and a quoted literal is
consumed whole, including doubled quotes. The extra decreasing test only makes
this source scanner total outside the native routine's verified domains. -/
def workTail (text : Source) (position remaining : Nat) : Bool :=
  let first := skipAt text position
  let quoted := literalAt text first
  if first = 0 then false
  else if first > text.length then true
  else if Cursor.byteAt text first = 34 then
    if quoted.after = 0 then false
    else if _advancing : text.length + 1 - quoted.after < text.length + 1 - position then
      workTail text quoted.after remaining
    else false
  else if Cursor.byteAt text first = 38 then
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

def expressionStep (text : Source) (names : BindingEnvironment) (state : ExpressionState) : ExpressionState :=
  let openAfter := fixedAfter text state.position "(" false
  let atom := valueAt text state.position names
  let joinAfter := fixedAfter text state.position "&" false
  let closeAfter := fixedAfter text state.position ")" false
  if state.position = 0 then invalidExpressionState
  else if state.complete then state
  else if state.needOperand then
    if openAfter ≠ 0 then {state with position := openAfter, depth := state.depth + 1}
    else if state.operands = maxExpressionOperands ∨ atom.after = 0 ∨
        atom.staticLength > maxSourceLength - state.staticLength then invalidExpressionState
    else {state with
      position := atom.after
      staticLength := state.staticLength + atom.staticLength
      dynamicCount := state.dynamicCount + (if atom.dynamicSeen then 1 else 0)
      operands := state.operands + 1
      namedSeen := state.namedSeen || decide (atom.reference ≠ 0)
      needOperand := false}
  else if joinAfter ≠ 0 then {state with position := joinAfter, needOperand := true}
  else if closeAfter ≠ 0 ∧ state.depth ≠ 0 then {state with position := closeAfter, depth := state.depth - 1}
  else if state.depth = 0 then {state with complete := true}
  else invalidExpressionState

def ExpressionState.result (state : ExpressionState) : ExpressionResult :=
  ⟨state.position, state.staticLength, state.dynamicCount, state.namedSeen⟩

def expressionTail (text : Source) (names : BindingEnvironment) (state : ExpressionState) : ExpressionResult :=
  if state.position = 0 then invalidExpression
  else if state.complete then state.result
  else
    let next := expressionStep text names state
    if next.position = 0 then invalidExpression
    else if next.complete then next.result
    else if _advancing : text.length + 1 - next.position < text.length + 1 - state.position then
      expressionTail text names next
    else invalidExpression
termination_by text.length + 1 - state.position
decreasing_by exact _advancing

def expressionAt (text : Source) (position : Nat) (names : BindingEnvironment) : ExpressionResult :=
  expressionTail text names {position := position}

def fits (result : ExpressionResult) (capacity : Nat) : Bool :=
  decide (result.after ≠ 0 ∧ result.staticLength + result.dynamicCount * capacity ≤ maxSourceLength)

def ExpressionResult.value (result : ExpressionResult) : ValueResult :=
  ⟨result.after, 0, result.staticLength, decide (result.dynamicCount = 1), 0⟩

def newNameAllowed (text : Source) (state : ParserState) (first after : Nat) (arguments : Bool) : Bool :=
  decide (first ≠ 0 ∧ after > first) && !forbiddenName text first after &&
    (!arguments || !Arguments.forbiddenName text first after) &&
    decide (lookupName text state.names first after = 0)

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

def declarationParts (text : Source) (state : ParserState) : DeclarationParts :=
  ⟨declarationFirst text state, declarationAfter text state, declarationConstantAfter text state,
    expressionAt text (declarationValuePosition text state) state.names,
    fixedAfter text (expressionAt text (declarationValuePosition text state) state.names).after ";" false⟩

def declarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := declarationParts text state
  if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.following = 0 ∨ state.names.length = maxBindings) ||
      !fits parts.value maxSourceLength then invalidState
  else addBinding state parts.first parts.after parts.value.value (decide (parts.constantAfter = 0)) parts.following

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
  skipAt text ([ShellToken.symbol ":", .word "constant", .word "string", .symbol ":=",
    .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "("].foldl
    (fun position token => tokenAfter text position token) (argumentAfter text state))

def argumentParts (text : Source) (state : ParserState) : ArgumentParts :=
  ⟨argumentFirst text state, argumentAfter text state, argumentDefaultPosition text state,
    literalAt text (argumentDefaultPosition text state),
    fixedAfter text (fixedAfter text (literalAt text (argumentDefaultPosition text state)).after ")" false) ";" false⟩

def argumentAt (text : Source) (state : ParserState) : ParserState :=
  let parts := argumentParts text state
  if !newNameAllowed text state parts.first parts.after true ||
      decide (parts.following = 0 ∨ state.names.length ≠ 0) then invalidState
  else {addBinding state parts.first parts.after ⟨parts.following, 0, 0, true, 0⟩ false parts.following with
    dynamicFirst := parts.first, dynamicAfter := parts.after}

def declarationsLoop (text : Source) (arguments : Bool) : Nat → ParserState → ParserState
  | 0, _ => invalidState
  | fuel + 1, state =>
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsLoop text arguments fuel (declarationAt text state arguments)

def declarationsAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  declarationsLoop text arguments (maxBindings + 1 - state.names.length) state

-- The shell tables retain current control flow. Only declaration slots become
-- a finite list, and assignment names resolve against its shared environment.
def header (arguments : Bool) : List ShellToken :=
  [.word "with", .word "silver_io", .symbol ";"] ++
    (if arguments then [.word "with", .word "silver_arguments", .symbol ";"] else []) ++
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
  if index = 0 ∨ info.mutable = false ∨ (sameTarget = true ∧ index ≠ state.target) then invalidState
  else {state with position := after, target := index}

def dynamicAt (text : Source) (state : ParserState) : ParserState :=
  let first := skipAt text state.position
  let after := nameAfter text first
  if first = 0 ∨ after = 0 ∨ state.dynamicFirst = 0 ∨
      equalName text state.dynamicFirst state.dynamicAfter first after = false then invalidState
  else {state with position := after}

def assignmentAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names
  let target := (state.names.get state.target).getD {}
  if !fits value state.capacity || decide (state.target = 0 ∨ value.staticLength ≠ target.staticLength ∨
      value.dynamicCount ≠ (if target.dynamic then 1 else 0)) then invalidState
  else {state with position := value.after}

def outputAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names
  if fits value state.capacity then {state with position := value.after} else invalidState

def comparisonAt (text : Source) (state : ParserState) : ParserState :=
  let left := expressionAt text state.position state.names
  let right := expressionAt text (fixedAfter text left.after "=" false) state.names
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

inductive ValueAt (text : Source) (names : BindingEnvironment) : Nat → Operand → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      skipAt text position ≠ 0 → skipAt text position ≤ text.length →
      Cursor.byteAt text (skipAt text position) = 34 →
      Output.LiteralAt text (skipAt text position + 1) bytes after →
      ValueAt text names position (.literal bytes)
        ⟨after, skipAt text position + 1, bytes.length, false, 0⟩
  | reference {position after index : Nat} {name : Source} {info : BindingInfo} :
      skipAt text position ≠ 0 →
      IdentifierAt text (skipAt text position) name after →
      lookupName text names (skipAt text position) after = index → index ≠ 0 →
      names.get index = some info →
      ValueAt text names position (.reference index)
        ⟨after, info.valueFirst, info.staticLength, info.dynamic, index⟩

theorem value_complete {text : Source} {names : BindingEnvironment} {position : Nat}
    {value : Operand} {result : ValueResult} (parsed : ValueAt text names position value result) :
    valueAt text position names = result := by
  cases parsed with
  | literal positive bound quote parsed =>
      rename_i after bytes
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
  | reference positive parsed selected nonzero present =>
      simp [valueAt, literalAt, identifier_not_quote parsed, nameAfter, positive,
        identifierEnd_complete parsed, selected, nonzero, present, invalidValue]

theorem value_sound (text : Source) (position : Nat) (names : BindingEnvironment)
    (accepted : (valueAt text position names).after ≠ 0) :
    ∃ value, ValueAt text names position value (valueAt text position names) := by
  by_cases quoted : (literalAt text (skipAt text position)).after ≠ 0
  · have conditions : skipAt text position ≠ 0 ∧ skipAt text position ≤ text.length ∧
        Cursor.byteAt text (skipAt text position) = 34 ∧
        Output.literalEnd text (skipAt text position + 1) ≠ 0 := by
      by_cases present : skipAt text position ≠ 0 ∧ skipAt text position ≤ text.length ∧
          Cursor.byteAt text (skipAt text position) = 34 ∧
          Output.literalEnd text (skipAt text position + 1) ≠ 0
      · exact present
      · simp [literalAt, present, invalidValue] at quoted
    obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ conditions.2.2.2
    refine ⟨.literal bytes, ?_⟩
    have observed : valueAt text position names =
        ⟨Output.literalEnd text (skipAt text position + 1), skipAt text position + 1,
          bytes.length, false, 0⟩ := by
      simp [valueAt, literalAt, conditions, Guarded.literalLength_decodes parsed]
    rw [observed]
    exact .literal conditions.1 conditions.2.1 conditions.2.2.1 parsed
  · have index : lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 := by
      by_cases absent : lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) = 0
      · simp [valueAt, quoted, absent, invalidValue] at accepted
      · exact absent
    obtain ⟨positive, advanced, info, present, _⟩ := lookupName_found index
    have afterPositive : nameAfter text (skipAt text position) ≠ 0 := by omega
    have nameAccepted : identifierEnd text (skipAt text position) ≠ 0 := by
      simpa [nameAfter, positive] using afterPositive
    obtain ⟨name, parsed⟩ := identifierEnd_sound text _ nameAccepted
    have afterSame : nameAfter text (skipAt text position) = identifierEnd text (skipAt text position) := by
      simp [nameAfter, positive]
    refine ⟨.reference (lookupName text names (skipAt text position) (nameAfter text (skipAt text position))), ?_⟩
    have observed : valueAt text position names =
        ⟨nameAfter text (skipAt text position), info.valueFirst, info.staticLength, info.dynamic,
          lookupName text names (skipAt text position) (nameAfter text (skipAt text position))⟩ := by
      simp [valueAt, quoted, index, present]
    rw [observed]
    apply ValueAt.reference positive
    · simpa [afterSame] using parsed
    · rfl
    · exact index
    · exact present

def ValueResult.bound (result : ValueResult) : Bindings.Bound :=
  if result.dynamicSeen then .argument else .fixed result.staticLength

theorem value_infer {text : Source} {names : BindingEnvironment} {position : Nat}
    {value : Operand} {result : ValueResult} (parsed : ValueAt text names position value result) :
    value.infer names.shape = some result.bound := by
  cases parsed with
  | literal => rfl
  | reference _ _ _ _ present =>
      simp [Bindings.Value.infer, Bindings.BindingEnvironment.shape, present,
        BindingInfo.cell, BindingInfo.bound, ValueResult.bound]

theorem value_literals {text : Source} {names : BindingEnvironment} {position : Nat}
    {value : Operand} {result : ValueResult} (parsed : ValueAt text names position value result) :
    value.PrintableLiterals := by
  cases parsed with
  | literal _ _ _ parsed => exact (Output.literalAt_bounds parsed).2.2
  | reference => trivial


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

theorem declarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).names.length = state.names.length + 1 := by
  simp only [declarationAt]
  split
  · rename_i rejected
    simp only [declarationAt, rejected, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp [addBinding]

theorem declarationsAt_equation (text : Source) (state : ParserState) (arguments : Bool)
    (bounded : state.names.length ≤ maxBindings) :
    declarationsAt text state arguments =
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsAt text (declarationAt text state arguments) arguments := by
  have fuel : maxBindings + 1 - state.names.length = (maxBindings - state.names.length) + 1 := by omega
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
