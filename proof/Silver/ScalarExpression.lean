module

public import Silver.ScalarLiteral
public import Silver.IntegerExpressions
public import Silver.ArrayBindings
public import Silver.NamedIdentifier

@[expose] public section

/-! Scalar source syntax is parsed independently of interval admission. The
syntax tree retains every typed operation; `summarize` checks all intermediate
values through `Integer.Expr.infer` and counts leaves separately. -/
namespace Silver.ScalarExpression

structure Binding where
  first : Nat
  after : Nat
  bounds : Integer.Interval
  isStatic : Bool
  declaredBounds : Integer.Interval := .full
  mutable : Bool := false
  deriving DecidableEq, Repr

abbrev Environment := List Binding

def emptyBinding : Binding := ⟨0, 0, Integer.Interval.empty, false, Integer.Interval.empty, false⟩
def binding (names : Environment) (index : Nat) : Binding := names.getD (index - 1) emptyBinding

def ranges (names : Environment) : Integer.Ranges := fun index =>
  if 0 < index ∧ index ≤ names.length then some (binding names index).bounds else none

def constants (names : Environment) : List Int :=
  names.map fun item => item.bounds.lower

/-- Declaration environments carry exact initial values, independently of Ada
staticness. Body environments expose every mutable object's declared range. -/
def bodyBinding (item : Binding) : Binding :=
  {item with bounds := if item.mutable then item.declaredBounds else item.bounds}

def bodyEnvironment (names : Environment) : Environment := names.map bodyBinding

def mutability (names : Environment) : Nat → Bool := fun index =>
  decide (0 < index ∧ index ≤ names.length) && (binding names index).mutable

def lookupFrom (text : Source) (names : Environment) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding names (index + 1)).first
          (binding names (index + 1)).after first after then index + 1
      else lookupFrom text names first after index

def lookup (text : Source) (names : Environment) (first after : Nat) : Nat :=
  lookupFrom text names first after names.length

theorem lookupFrom_bound (text : Source) (names : Environment) (first after index : Nat) :
    lookupFrom text names first after index ≤ index := by
  induction index with
  | zero => simp [lookupFrom]
  | succ index ih =>
      simp only [lookupFrom]
      split <;> (try omega)
      split <;> omega

theorem lookup_bound (text : Source) (names : Environment) (first after : Nat) :
    lookup text names first after ≤ names.length := lookupFrom_bound ..

def leaves : Integer.Expr → Nat
  | .literal _ | .snapshot _ | .name _ => 1
  | .indexed _ index => 1 + leaves index
  | .positive value | .negative value | .parenthesized value => leaves value
  | .add left right | .subtract left right | .multiply left right
  | .divide left right | .modulo left right | .remainder left right => leaves left + leaves right

def isStatic (names : Environment) : Integer.Expr → Bool
  | .literal _ => true
  | .snapshot _ => false
  | .name index => (binding names index).isStatic
  | .indexed _ _ => false
  | .positive value | .negative value | .parenthesized value => isStatic names value
  | .add left right | .subtract left right | .multiply left right
  | .divide left right | .modulo left right | .remainder left right =>
      isStatic names left && isStatic names right

theorem leaves_positive (expression : Integer.Expr) : 0 < leaves expression := by
  induction expression <;> simp_all [leaves] <;> omega

structure Result where
  after : Nat
  bounds : Integer.Interval
  operands : Nat
  isStatic : Bool
  deriving DecidableEq, Repr

def invalid : Result := ⟨0, Integer.Interval.empty, 0, false⟩
def maxOperands : Nat := 64

structure Parsed where
  after : Nat
  expression : Integer.Expr
  deriving DecidableEq, Repr

def summarize (names : Environment) (parsed : Option Parsed) : Result :=
  match parsed with
  | none => invalid
  | some value =>
      if value.after = 0 ∨ maxOperands < leaves value.expression then invalid
      else match value.expression.infer (ranges names) with
      | none => invalid
      | some bounds => ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩

def skip (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else Cursor.triviaPosition text position

def symbol (text : Source) (position byte : Nat) : Nat :=
  let first := skip text position
  if first = 0 ∨ first > text.length ∨ Cursor.byteAt text first ≠ byte then 0 else first + 1

def nameAfter (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else Named.identifierEnd text position

/-- End of one complete scalar operator token; `/=` remains a comparison. -/
def binaryAfter (text : Source) (position : Nat) : Nat :=
  let after := nameAfter text position
  if position = 0 ∨ position > text.length then 0
  else if Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
      Cursor.byteAt text position = 42 then position + 1
  else if Cursor.byteAt text position = 47 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 61 then 0 else position + 1
  else if after ≠ 0 ∧ (Named.nameIs text position after ("mod".toList.map Char.toNat) = true ∨
      Named.nameIs text position after ("rem".toList.map Char.toNat) = true) then after else 0

def signedValue (value : Nat) (negative : Bool) : Int :=
  if negative then -(Int.ofNat value) else Int.ofNat value

def literal (number : ScalarLiteral.Result) (negative : Bool) : Option Parsed :=
  if number.after = 0 then none else some ⟨number.after, .literal (signedValue number.value negative)⟩

def unary (value : Parsed) (negative : Bool) : Parsed :=
  ⟨value.after, if negative then .negative value.expression else .positive value.expression⟩

def binary (left right : Parsed) (operator : Nat) : Option Parsed :=
  if operator = 43 then some ⟨right.after, .add left.expression right.expression⟩
  else if operator = 45 then some ⟨right.after, .subtract left.expression right.expression⟩
  else if operator = 42 then some ⟨right.after, .multiply left.expression right.expression⟩
  else if operator = 47 then some ⟨right.after, .divide left.expression right.expression⟩
  else if operator = 109 then some ⟨right.after, .modulo left.expression right.expression⟩
  else if operator = 114 then some ⟨right.after, .remainder left.expression right.expression⟩
  else none

def close (text : Source) (parsed : Option Parsed) : Option Parsed := do
  let value ← parsed
  let finish := symbol text value.after 41
  if finish = 0 then none else some {value with after := finish}

def atom (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Option Parsed :=
  let first := skip text position
  let after := nameAfter text first
  let index := lookup text names first after
  if first = 0 ∨ first > text.length then none
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then none else
      literal (ScalarLiteral.read text (skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := ScalarLiteral.read text first
    if number.after ≠ 0 then literal number false
    else if index = 0 ∨ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true)
    then none
    else some ⟨after, .name index⟩

/-- Fuel counts recursive expression reads, not tokens. Every recursive call
starts strictly after its caller; the public reader supplies a source-length
bound. Parentheses, including redundant grouping, consume source bytes. -/
def parseFuel : Nat → Source → Nat → Environment → Nat → Nat → Bool → Option Parsed
  | 0, _, _, _, _, _, _ => none
  | fuel + 1, text, position, names, maskFirst, maskAfter, allowSign =>
      let first := skip text position
      if first = 0 ∨ first > text.length then none
      else if Cursor.byteAt text first ≠ 40 then atom text first names maskFirst maskAfter allowSign
      else
        let inner := skip text (first + 1)
        if inner > text.length then none
        else if Cursor.byteAt text inner = 43 ∨ Cursor.byteAt text inner = 45 then
          let next := skip text (inner + 1)
          let number := ScalarLiteral.read text next
          close text (if number.after ≠ 0 then literal number (Cursor.byteAt text inner == 45)
            else (parseFuel fuel text next names maskFirst maskAfter false).map
              fun value => unary value (Cursor.byteAt text inner == 45))
        else do
          let left ← parseFuel fuel text inner names maskFirst maskAfter true
          let next := skip text left.after
          if next = 0 ∨ next > text.length then none
          else if Cursor.byteAt text next = 41 then
            some ⟨next + 1, .parenthesized left.expression⟩
          else if binaryAfter text next = 0 then none
          else
            let right ← parseFuel fuel text (binaryAfter text next) names maskFirst maskAfter false
            close text (binary left right (lowercase (Cursor.byteAt text next)))

/-- Array subscripts use the scalar-only grammar above. Ordinary scalar
bindings take precedence, including a scoped index hiding an outer array. -/
def arrayAtom (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Metadata) (maskFirst maskAfter : Nat) (allowSign : Bool) : Option Parsed :=
  let ordinary := atom text position names maskFirst maskAfter allowSign
  if ordinary.isSome then ordinary else
    let first := skip text position
    let after := nameAfter text first
    let target := ArrayBindings.lookup text arrays first after
    if first = 0 ∨ first > text.length ∨ after = 0 ∨ target = 0 ∨
        lookup text names first after ≠ 0 ∨
        Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 ∨
        (ScalarLiteral.read text first).after ≠ 0 ∨
        (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true) then none
    else
      let opened := symbol text after 40
      if opened = 0 then none else do
        let index ← parseFuel fuel text opened names maskFirst maskAfter true
        let closed := symbol text index.after 41
        if closed ≤ position then none
        else some ⟨closed, .indexed (ArrayBindings.binding arrays target).descriptor index.expression⟩

def parseArraysFuel : Nat → Source → Nat → Environment → ArrayBindings.Metadata → Nat → Nat → Bool → Option Parsed
  | 0, _, _, _, _, _, _, _ => none
  | fuel + 1, text, position, names, arrays, maskFirst, maskAfter, allowSign =>
      let first := skip text position
      if first = 0 ∨ first > text.length then none
      else if Cursor.byteAt text first ≠ 40 then
        arrayAtom fuel text first names arrays maskFirst maskAfter allowSign
      else
        let inner := skip text (first + 1)
        if inner > text.length then none
        else if Cursor.byteAt text inner = 43 ∨ Cursor.byteAt text inner = 45 then
          let next := skip text (inner + 1)
          let number := ScalarLiteral.read text next
          close text (if number.after ≠ 0 then literal number (Cursor.byteAt text inner == 45)
            else (parseArraysFuel fuel text next names arrays maskFirst maskAfter false).map
              fun value => unary value (Cursor.byteAt text inner == 45))
        else do
          let left ← parseArraysFuel fuel text inner names arrays maskFirst maskAfter true
          let next := skip text left.after
          if next = 0 ∨ next > text.length then none
          else if Cursor.byteAt text next = 41 then
            some ⟨next + 1, .parenthesized left.expression⟩
          else if binaryAfter text next = 0 then none
          else
            let right ← parseArraysFuel fuel text (binaryAfter text next) names arrays maskFirst maskAfter false
            close text (binary left right (lowercase (Cursor.byteAt text next)))

def summarizeArrays (names : Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (parsed : Option Parsed) : Result :=
  match parsed with
  | none => invalid
  | some value =>
      if value.after = 0 ∨ maxOperands < leaves value.expression then invalid
      else match value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
      | none => invalid
      | some bounds => ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩

def read (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat := 0) (allowSign : Bool := true)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : Result :=
  match arrays with
  | [] => summarize names (parseFuel (text.length + 1) text position names maskFirst maskAfter allowSign)
  | _ :: _ => summarizeArrays names arrays initials elaborating
      (parseArraysFuel (text.length + 1) text position names arrays maskFirst maskAfter allowSign)

theorem summarize_success {names : Environment} {parsed : Option Parsed}
    (success : (summarize names parsed).after ≠ 0) :
    ∃ value bounds, parsed = some value ∧ value.after ≠ 0 ∧
      leaves value.expression ≤ maxOperands ∧
      value.expression.infer (ranges names) = some bounds ∧
      summarize names parsed = ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩ := by
  cases parsed with
  | none => simp [summarize, invalid] at success
  | some value =>
      simp only [summarize] at success ⊢
      split at success
      · simp [invalid] at success
      · rename_i good
        cases found : value.expression.infer (ranges names) with
        | none => simp [found, invalid] at success
        | some bounds =>
            refine ⟨value, bounds, rfl, ?_, ?_, found, ?_⟩
            · simp only [found] at success; exact success
            · omega
            · simp only [good, ↓reduceIte]

theorem read_has_expression {text : Source} {position : Nat} {names : Environment}
    {maskFirst maskAfter : Nat} {allowSign : Bool}
    (success : (read text position names maskFirst maskAfter allowSign).after ≠ 0) :
    ∃ expression, expression.infer (ranges names) =
        some (read text position names maskFirst maskAfter allowSign).bounds ∧
      leaves expression = (read text position names maskFirst maskAfter allowSign).operands ∧
      isStatic names expression = (read text position names maskFirst maskAfter allowSign).isStatic := by
  obtain ⟨value, bounds, _, _, _, found, result⟩ := summarize_success success
  exact ⟨value.expression, by simpa only [read, result] using found,
    by simp only [read, result], by simp only [read, result]⟩

theorem read_safe {text : Source} {position : Nat} {names : Environment}
    {maskFirst maskAfter : Nat} {allowSign : Bool} {values : Integer.Store}
    (success : (read text position names maskFirst maskAfter allowSign).after ≠ 0)
    (fits : Integer.Fits (ranges names) values) :
    ∃ expression : Integer.Expr, expression.Safe values ∧
      (read text position names maskFirst maskAfter allowSign).bounds.Contains
        (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  obtain ⟨expression, found, _, _⟩ := read_has_expression success
  have safe := expression.infer_sound found fits
  exact ⟨expression, safe.2, safe.1, expression.inferred_execution found fits⟩

end Silver.ScalarExpression
