module

public import Silver.ScalarExpressionAdmission

@[expose] public section

/-! Result-level equations for the executable scalar helper. These definitions
retain rejection and every intermediate interval check. Their relation to the
independent AST reader, and to actual source bodies, are separate proofs. -/
namespace Silver.ScalarExpression.Native

def literalResult (number : ScalarLiteral.Result) (negative : Bool) : Result :=
  let checked := Integer.checked (Integer.Interval.singleton (signedValue number.value negative))
  if number.after = 0 ∨ checked.safe = false then invalid
  else ⟨number.after, checked.bounds, 1, true⟩

def unaryResult (operand : Result) (negative : Bool) : Result :=
  let checked := if negative then Integer.checkedNegate operand.bounds else ⟨true, operand.bounds⟩
  if operand.after = 0 ∨ checked.safe = false then invalid
  else {operand with bounds := checked.bounds}

def binaryResult (left right : Result) (operator : Nat) : Result :=
  let checked := if operator = 43 then Integer.checkedAdd left.bounds right.bounds
    else if operator = 45 then Integer.checkedSubtract left.bounds right.bounds
    else if operator = 42 then Integer.checkedMultiply left.bounds right.bounds
    else ⟨false, Integer.Interval.empty⟩
  if left.after = 0 ∨ right.after = 0 ∨ checked.safe = false ∨ left.operands > maxOperands - right.operands
  then invalid else ⟨right.after, checked.bounds, left.operands + right.operands, left.isStatic && right.isStatic⟩

def closeResult (text : Source) (value : Result) : Result :=
  let after := symbol text value.after 41
  if after = 0 then invalid else {value with after := after}

def atomResult (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Result :=
  let first := skip text position
  let after := nameAfter text first
  let index := lookup text names first after
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      literalResult (ScalarLiteral.read text (skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := ScalarLiteral.read text first
    if number.after ≠ 0 then literalResult number false
    else if index = 0 ∨ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true)
    then invalid
    else ⟨after, (binding names index).bounds.normalize, 1, (binding names index).isStatic⟩

abbrev Reader := Source → Nat → Environment → Nat → Nat → Bool → Result

def unaryStep (recurse : Reader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) : Result :=
  let next := skip text (position + 1)
  let number := ScalarLiteral.read text next
  closeResult text (if number.after ≠ 0 then literalResult number (Cursor.byteAt text position == 45)
    else unaryResult (recurse text next names maskFirst maskAfter false) (Cursor.byteAt text position == 45))

def compoundStep (recurse : Reader) (text : Source) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) : Result :=
  let next := skip text left.after
  if next = 0 ∨ next > text.length then invalid
  else if Cursor.byteAt text next = 41 then {left with after := next + 1}
  else if Cursor.byteAt text next ≠ 43 ∧ Cursor.byteAt text next ≠ 45 ∧ Cursor.byteAt text next ≠ 42
  then invalid
  else closeResult text (binaryResult left (recurse text (next + 1) names maskFirst maskAfter false)
    (Cursor.byteAt text next))

def groupStep (recurse : Reader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) : Result :=
  let first := skip text (position + 1)
  if first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45
  then unaryStep recurse text first names maskFirst maskAfter
  else compoundStep recurse text names (recurse text first names maskFirst maskAfter true) maskFirst maskAfter

def readStep (recurse : Reader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Result :=
  let first := skip text position
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 40 then groupStep recurse text first names maskFirst maskAfter
  else atomResult text first names maskFirst maskAfter allowSign

def readFuel : Nat → Reader
  | 0 => fun _ _ _ _ _ _ => invalid
  | fuel + 1 => readStep (readFuel fuel)

structure ScalarCalls where
  checked : Int → Int → Integer.CheckResult
  negate : Integer.Interval → Integer.CheckResult
  add : Integer.Interval → Integer.Interval → Integer.CheckResult
  subtract : Integer.Interval → Integer.Interval → Integer.CheckResult
  multiply : Integer.Interval → Integer.Interval → Integer.CheckResult
  normalize : Integer.Interval → Integer.Interval

def scalarModel : ScalarCalls where
  checked a b := Integer.checked ⟨a, b⟩
  negate := Integer.checkedNegate
  add := Integer.checkedAdd
  subtract := Integer.checkedSubtract
  multiply := Integer.checkedMultiply
  normalize := Integer.Interval.normalize

structure Calls where
  lookupModel : Source → Environment → Nat → Nat → Nat → Nat
  lookup : Source → Environment → Nat → Nat → Nat
  skip : Source → Nat → Nat
  symbol : Source → Nat → Nat → Nat
  nameAfter : Source → Nat → Nat
  literalResult : ScalarLiteral.Result → Bool → Result
  unaryResult : Result → Bool → Result
  binaryResult : Result → Result → Nat → Result
  closeResult : Source → Result → Result
  readAtom : Reader
  readUnary : Source → Nat → Environment → Nat → Nat → Result
  readCompound : Source → Nat → Environment → Result → Nat → Nat → Result
  readGroup : Source → Nat → Environment → Nat → Nat → Result
  readExpression : Reader
  scalars : ScalarCalls
  integerLiteral : Source → Nat → ScalarLiteral.Result
  trivia : Source → Nat → Nat
  identifier : Source → Nat → Nat
  equalName : Source → Nat → Nat → Nat → Nat → Bool

def modelCalls : Calls where
  lookupModel := lookupFrom
  lookup := ScalarExpression.lookup
  skip := ScalarExpression.skip
  symbol := ScalarExpression.symbol
  nameAfter := ScalarExpression.nameAfter
  literalResult := Native.literalResult
  unaryResult := Native.unaryResult
  binaryResult := Native.binaryResult
  closeResult := Native.closeResult
  readAtom := atomResult
  readUnary := unaryStep (@read)
  readCompound text _ names left maskFirst maskAfter := compoundStep (@read) text names left maskFirst maskAfter
  readGroup := groupStep (@read)
  readExpression := @read
  scalars := scalarModel
  integerLiteral := ScalarLiteral.read
  trivia := Cursor.triviaPosition
  identifier := Named.identifierEnd
  equalName := Named.equalName

theorem literal_correspondence (names : Environment) (number : ScalarLiteral.Result) (negative : Bool) :
    literalResult number negative = summarize names (literal number negative) := by
  unfold literalResult literal
  dsimp only
  by_cases zero : number.after = 0
  · simp [zero, summarize]
  · simp only [zero, false_or, ↓reduceIte, summarize, leaves, maxOperands,
      show ¬ 64 < 1 by decide, or_self, Integer.Expr.infer, Integer.accepted, isStatic]
    cases checked : (Integer.checked (Integer.Interval.singleton (signedValue number.value negative))).safe <;>
      simp

end Silver.ScalarExpression.Native
