module

public import Silver.ComposeDeclarationAdmission
public import Silver.FunctionDeclarationPreservation
public import Silver.ProcedureDeclarationPreservation

@[expose] public section

namespace Silver.Compose
open Named Bindings

def declarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let function := functionDeclarationAt text state arguments
  let procedure := procedureDeclarationAt text state arguments
  let arrayType := arrayTypeDeclarationAt text state arguments
  let subtype := subtypeDeclarationAt text state arguments
  let scalar := scalarDeclarationAt text state arguments
  let array := arrayDeclarationAt text state arguments
  let boolean := booleanDeclarationAt text state arguments
  let character := characterDeclarationAt text state arguments
  if function.position ≠ 0 then function
  else if procedure.position ≠ 0 then procedure
  else if arrayType.position ≠ 0 then arrayType
  else if subtype.position ≠ 0 then subtype
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
  let operation := Names.operationAfter text start .argument hidden state.contextFirst state.packageFirst state.packageAfter
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
    (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + ArrayBindings.maxTypes + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings + FunctionBindings.maxFunctions + ProcedureBindings.maxProcedures + 1 -
      (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.arrayNames.types.length + state.subtypeNames.items.length + state.booleanNames.length + state.functions.items.length + state.procedures.items.length)) state

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

def dynamicAt (text : Source) (state : ParserState) : ParserState :=
  let first := skipAt text state.position
  let after := nameAfter text first
  if first = 0 ∨ after = 0 ∨ state.dynamicFirst = 0 ∨
      equalName text state.dynamicFirst state.dynamicAfter first after = false then invalidState
  else {state with position := after}

def assignmentAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.table state.arrayNames.values true state.contextFirst
  let target := (state.names.get state.target).getD {}
  if !fits value state.capacity || value.emptyValue || decide (value.minimumLength ≠ value.staticLength ∨ state.target = 0 ∨ value.staticLength ≠ target.staticLength ∨
      value.dynamicCount ≠ (if target.dynamic then 1 else 0) ∨ target.isCharacter = true) then invalidState
  else {state with position := value.after}

def outputAt (text : Source) (state : ParserState) : ParserState :=
  let value := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.table state.arrayNames.values true state.contextFirst
  if fits value state.capacity then {state with position := value.after} else invalidState

def comparisonAt (text : Source) (state : ParserState) : ParserState :=
  let left := expressionAt text state.position state.names state.scalarNames false
    state.arrayNames.table state.arrayNames.values true state.contextFirst
  let right := expressionAt text (fixedAfter text left.after "=" false) state.names state.scalarNames false
    state.arrayNames.table state.arrayNames.values true state.contextFirst
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
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
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
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_booleanNames text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem arrayValuesModel_functions (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval}
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    (arrayValuesModel text source result position length parsed componentBounds).functions = result.functions := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_functions text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_preserves (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (accepted : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).names = result.names ∧
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).scalarNames = result.scalarNames ∧
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).arrayNames.names = result.arrayNames.names ∧
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).subtypeNames = result.subtypeNames ∧
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).booleanNames = result.booleanNames := by
  rw [booleanArrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact booleanArrayValuesModel_preserves text source _ _ length (parsed + 1) maskFirst maskAfter accepted
    · simp only [remaining, ↓reduceDIte]
      trivial
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_functions (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (accepted : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).functions = result.functions := by
  rw [booleanArrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact booleanArrayValuesModel_functions text source _ _ length (parsed + 1) maskFirst maskAfter accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem arrayDeclarationValues_preserves {text state parts position length}
    (accepted : (arrayDeclarationValues text state parts position length).position ≠ 0) :
    (arrayDeclarationValues text state parts position length).names = state.names ∧
      (arrayDeclarationValues text state parts position length).scalarNames = state.scalarNames ∧
      (arrayDeclarationValues text state parts position length).arrayNames.names = state.arrayNames.names ∧
      (arrayDeclarationValues text state parts position length).subtypeNames = state.subtypeNames ∧
      (arrayDeclarationValues text state parts position length).booleanNames = state.booleanNames := by
  unfold arrayDeclarationValues at accepted ⊢
  split at accepted
  · rename_i kind
    simp only [kind, ↓reduceIte]
    exact booleanArrayValuesModel_preserves _ _ _ _ _ _ _ _ accepted
  · rename_i kind
    simp only [kind]
    have same := arrayValuesModel_preserves _ _ _ _ _ _ accepted
    exact ⟨same.1, same.2.1, same.2.2.1, same.2.2.2,
      arrayValuesModel_booleanNames _ _ _ _ _ _ accepted⟩

theorem arrayDeclarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).names = state.names ∧
      (arrayDeclarationAt text state arguments).scalarNames = state.scalarNames ∧
      (arrayDeclarationAt text state arguments).arrayNames.names.length = state.arrayNames.names.length + 1 ∧
      (arrayDeclarationAt text state arguments).subtypeNames = state.subtypeNames := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
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
          have preserved := arrayDeclarationValues_preserves values
          exact ⟨preserved.1, preserved.2.1, by rw [preserved.2.2.1], preserved.2.2.2.1⟩

theorem arrayDeclarationAt_booleanNames {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).booleanNames = state.booleanNames := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
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
          exact (arrayDeclarationValues_preserves values).2.2.2.2

theorem arrayDeclarationValues_functions {text state parts position length}
    (accepted : (arrayDeclarationValues text state parts position length).position ≠ 0) :
    (arrayDeclarationValues text state parts position length).functions = state.functions := by
  unfold arrayDeclarationValues at accepted ⊢
  split at accepted
  · rename_i kind
    simp only [kind, ↓reduceIte]
    exact booleanArrayValuesModel_functions _ _ _ _ _ _ _ _ accepted
  · rename_i kind
    simp only [kind]
    exact arrayValuesModel_functions _ _ _ _ _ _ accepted

theorem arrayDeclarationAt_functions {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).functions = state.functions := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
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
          exact arrayDeclarationValues_functions values

theorem arrayValuesModel_procedures (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval}
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    (arrayValuesModel text source result position length parsed componentBounds).procedures = result.procedures := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_procedures text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_procedures (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (accepted : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).procedures = result.procedures := by
  rw [booleanArrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact booleanArrayValuesModel_procedures text source _ _ length (parsed + 1) maskFirst maskAfter accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem arrayDeclarationValues_procedures {text state parts position length}
    (accepted : (arrayDeclarationValues text state parts position length).position ≠ 0) :
    (arrayDeclarationValues text state parts position length).procedures = state.procedures := by
  unfold arrayDeclarationValues at accepted ⊢
  split at accepted
  · rename_i kind
    simp only [kind, ↓reduceIte]
    exact booleanArrayValuesModel_procedures _ _ _ _ _ _ _ _ accepted
  · rename_i kind
    simp only [kind]
    exact arrayValuesModel_procedures _ _ _ _ _ _ accepted

theorem arrayDeclarationAt_procedures {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).procedures = state.procedures := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
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
          exact arrayDeclarationValues_procedures values

theorem arrayValuesModel_types (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval}
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    (arrayValuesModel text source result position length parsed componentBounds).arrayNames.types = result.arrayNames.types := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.ArrayGrammar.read text position source.scalarNames
        (arrays := source.arrayNames.table) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact arrayValuesModel_types text source _ _ length (parsed + 1) accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_types (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (accepted : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).arrayNames.types = result.arrayNames.types := by
  rw [booleanArrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        exact booleanArrayValuesModel_types text source _ _ length (parsed + 1) maskFirst maskAfter accepted
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem arrayDeclarationValues_types {text state parts position length}
    (accepted : (arrayDeclarationValues text state parts position length).position ≠ 0) :
    (arrayDeclarationValues text state parts position length).arrayNames.types = state.arrayNames.types := by
  unfold arrayDeclarationValues at accepted ⊢
  split at accepted
  · rename_i kind
    simp only [kind, ↓reduceIte]
    exact booleanArrayValuesModel_types _ _ _ _ _ _ _ _ accepted
  · rename_i kind
    simp only [kind]
    exact arrayValuesModel_types _ _ _ _ _ _ accepted

theorem arrayDeclarationAt_types {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    (arrayDeclarationAt text state arguments).arrayNames.types = state.arrayNames.types := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
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
          exact arrayDeclarationValues_types values

theorem declarationAt_count {text : Source} {state : ParserState} {arguments : Bool}
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).names.length +
      (declarationAt text state arguments).scalarNames.length +
      (declarationAt text state arguments).arrayNames.names.length +
      (declarationAt text state arguments).arrayNames.types.length +
      (declarationAt text state arguments).subtypeNames.items.length +
      (declarationAt text state arguments).booleanNames.length +
      (declarationAt text state arguments).functions.items.length +
      (declarationAt text state arguments).procedures.items.length =
      state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.arrayNames.types.length + state.subtypeNames.items.length + state.booleanNames.length + state.functions.items.length + state.procedures.items.length + 1 := by
  by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
  · have selected : declarationAt text state arguments = functionDeclarationAt text state arguments := by
      dsimp only [declarationAt]
      rw [ite_eq_left function]
    rw [selected]
    have kept := functionDeclarationAt_preserves_outer text state arguments function
    rw [kept.names, kept.scalarNames, kept.arrayNames, kept.subtypeItems, kept.booleanNames,
      functionDeclarationAt_count text state arguments function, kept.procedures]
    omega
  · by_cases procedure : (procedureDeclarationAt text state arguments).position ≠ 0
    · have selected : declarationAt text state arguments = procedureDeclarationAt text state arguments := by
        dsimp only [declarationAt]
        rw [ite_eq_right function, ite_eq_left procedure]
      rw [selected]
      have kept := procedureDeclarationAt_preserves_outer text state arguments procedure
      rw [kept.names, kept.scalarNames, kept.arrayNames, kept.subtypeItems, kept.booleanNames,
        kept.functions, procedureDeclarationAt_count text state arguments procedure]
      omega
    · by_cases arrayType : (arrayTypeDeclarationAt text state arguments).position ≠ 0
      · have selected : declarationAt text state arguments = arrayTypeDeclarationAt text state arguments := by
          dsimp only [declarationAt]
          rw [ite_eq_right function, ite_eq_right procedure, ite_eq_left arrayType]
        rw [selected]
        unfold arrayTypeDeclarationAt at arrayType ⊢
        dsimp only at arrayType ⊢
        split at arrayType
        · simp [invalidState] at arrayType
        · rename_i good
          simp only [good, ↓reduceIte, List.length_append, List.length_singleton]
          omega
      · by_cases subtype : (subtypeDeclarationAt text state arguments).position ≠ 0
        · have selected : declarationAt text state arguments = subtypeDeclarationAt text state arguments := by
            simp only [declarationAt, procedure, function, arrayType, ↓reduceIte]; split <;> simp_all
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
              simp only [declarationAt, procedure, function, arrayType, subtype, ↓reduceIte]; split <;> simp_all
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
                simp only [declarationAt, procedure, function, arrayType, subtype, ↓reduceIte]; split <;> simp_all
              rw [selected]
              have count := arrayDeclarationAt_count array
              rw [count.1, count.2.1, count.2.2.1, count.2.2.2, arrayDeclarationAt_booleanNames array, arrayDeclarationAt_functions array, arrayDeclarationAt_procedures array, arrayDeclarationAt_types array]
              omega
            · by_cases boolean : (booleanDeclarationAt text state arguments).position ≠ 0
              · have selected : declarationAt text state arguments = booleanDeclarationAt text state arguments := by
                  simp only [declarationAt, procedure, function, arrayType, ↓reduceIte]; split <;> simp_all
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
                    simp only [declarationAt, procedure, function, arrayType, ↓reduceIte]; split <;> simp_all
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
                    simp only [declarationAt, procedure, function, arrayType, ↓reduceIte]; split <;> simp_all
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
    (bounded : state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.arrayNames.types.length + state.subtypeNames.items.length + state.booleanNames.length + state.functions.items.length + state.procedures.items.length ≤ (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + ArrayBindings.maxTypes + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings + FunctionBindings.maxFunctions + ProcedureBindings.maxProcedures)) :
    declarationsAt text state arguments =
      if state.position = 0 then invalidState
      else if fixedAfter text state.position "begin" true ≠ 0 then state
      else if (declarationAt text state arguments).position = 0 then invalidState
      else declarationsAt text (declarationAt text state arguments) arguments := by
  have fuel : (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + ArrayBindings.maxTypes + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings + FunctionBindings.maxFunctions + ProcedureBindings.maxProcedures) + 1 - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.arrayNames.types.length + state.subtypeNames.items.length + state.booleanNames.length + state.functions.items.length + state.procedures.items.length) =
      ((maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + ArrayBindings.maxTypes + IntegerSubtypes.maxBindings + BooleanBindings.maxBindings + FunctionBindings.maxFunctions + ProcedureBindings.maxProcedures) - (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.arrayNames.types.length + state.subtypeNames.items.length + state.booleanNames.length + state.functions.items.length + state.procedures.items.length)) + 1 := by omega
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
