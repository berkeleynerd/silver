module

public import Silver.ScalarExpressionAdmission
public import Silver.ScalarArrayGrammar
public import Silver.ArrayBindingsNativeEquations

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
    else if operator = 47 then Integer.checkedDivide left.bounds right.bounds
    else if operator = 109 then Integer.checkedModulo left.bounds right.bounds
    else if operator = 114 then Integer.checkedRemainder left.bounds right.bounds
    else ⟨false, Integer.Interval.empty⟩
  if left.after = 0 ∨ right.after = 0 ∨ checked.safe = false ∨ left.operands > maxOperands - right.operands
  then invalid else ⟨right.after, checked.bounds, left.operands + right.operands, left.isStatic && right.isStatic⟩

def closeResult (text : Source) (value : Result) : Result :=
  let after := symbol text value.after 41
  if after = 0 then invalid else {value with after := after}

def atomResult (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Result :=
  let first := skip text position
  let reference := readReference text first
  let after := reference.after
  let index := lookup text names reference.first after reference.qualifierFirst reference.qualifierAfter
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      literalResult (ScalarLiteral.read text (skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := ScalarLiteral.read text first
    if number.after ≠ 0 then literalResult number false
    else if index = 0 ∨ QualifiedNames.masked text reference maskFirst maskAfter = true
    then invalid
    else ⟨after, (binding names index).bounds.normalize, 1, (binding names index).isStatic⟩

abbrev Reader := Source → Nat → Environment → Nat → Nat → Bool → Result

def scalarReader : Reader := fun text position names maskFirst maskAfter allowSign =>
  read text position names maskFirst maskAfter allowSign

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
  else if binaryAfter text next = 0 then invalid
  else closeResult text (binaryResult left (recurse text (binaryAfter text next) names maskFirst maskAfter false)
    (Silver.lowercase (Cursor.byteAt text next)))

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
  divide : Integer.Interval → Integer.Interval → Integer.CheckResult
  modulo : Integer.Interval → Integer.Interval → Integer.CheckResult
  remainder : Integer.Interval → Integer.Interval → Integer.CheckResult
  normalize : Integer.Interval → Integer.Interval

def scalarModel : ScalarCalls where
  checked a b := Integer.checked ⟨a, b⟩
  negate := Integer.checkedNegate
  add := Integer.checkedAdd
  subtract := Integer.checkedSubtract
  multiply := Integer.checkedMultiply
  divide := Integer.checkedDivide
  modulo := Integer.checkedModulo
  remainder := Integer.checkedRemainder
  normalize := Integer.Interval.normalize

abbrev ArraysReader := Source → Nat → Environment → Nat → Nat → Bool →
  optParam ArrayBindings.Metadata [] → optParam ArrayBindings.Initials [] → optParam Bool false → Result

def arrayAtomStep (recurse : Reader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter target : Nat) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let opened := symbol text position 40
  if opened = 0 ∨ (ArrayBindings.binding arrays target).isBoolean = true then invalid else
    let subscript := recurse text opened names maskFirst maskAfter true
    let closed := symbol text subscript.after 41
    if closed ≤ position ∨ subscript.operands = maxOperands ∨
        ArrayBindings.contains (ArrayBindings.binding arrays target) subscript.bounds = false then invalid
    else ⟨closed, ArrayBindings.readBounds arrays initials elaborating target subscript.bounds,
      subscript.operands + 1, false⟩

def arraysAtomStep (recurse : Reader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let first := skip text position
  let reference := readReference text first
  let after := reference.after
  let index := lookup text names reference.first after reference.qualifierFirst reference.qualifierAfter
  let target := if reference.qualifierFirst = 0 then ArrayBindings.lookup text arrays reference.first after else 0
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      literalResult (ScalarLiteral.read text (skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := ScalarLiteral.read text first
    if number.after ≠ 0 then literalResult number false
    else if after = 0 then invalid
    else if QualifiedNames.masked text reference maskFirst maskAfter = true then invalid
    else if index ≠ 0 then ⟨after, (binding names index).bounds.normalize, 1, (binding names index).isStatic⟩
    else if reference.qualifierFirst ≠ 0 ∨ target = 0 then invalid
    else arrayAtomStep recurse text after names maskFirst maskAfter target arrays initials elaborating

def arraysUnaryStep (recurse : ArraysReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  unaryStep (fun text position names maskFirst maskAfter allowSign =>
    recurse text position names maskFirst maskAfter allowSign arrays initials elaborating)
    text position names maskFirst maskAfter

def arraysCompoundStep (recurse : ArraysReader) (text : Source) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  compoundStep (fun text position names maskFirst maskAfter allowSign =>
    recurse text position names maskFirst maskAfter allowSign arrays initials elaborating)
    text names left maskFirst maskAfter

def arraysGroupStep (recurse : ArraysReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let first := skip text (position + 1)
  if first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45
  then arraysUnaryStep (@recurse) text first names maskFirst maskAfter arrays initials elaborating
  else arraysCompoundStep (@recurse) text names
    (recurse text first names maskFirst maskAfter true arrays initials elaborating) maskFirst maskAfter arrays initials elaborating

def arraysReadStep (recurse : ArraysReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let first := skip text position
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 40 then
    arraysGroupStep (@recurse) text first names maskFirst maskAfter arrays initials elaborating
  else arraysAtomStep (fun text position names maskFirst maskAfter allowSign =>
    recurse text position names maskFirst maskAfter allowSign)
    text first names maskFirst maskAfter allowSign arrays initials elaborating

def arraysReadFuel : Nat → ArraysReader
  | 0 => fun _ _ _ _ _ _ _ _ _ => invalid
  | fuel + 1 => fun text position names maskFirst maskAfter allowSign arrays initials elaborating =>
      match arrays with
      | [] => readFuel (fuel + 1) text position names maskFirst maskAfter allowSign
      | _ :: _ => arraysReadStep (@arraysReadFuel fuel) text position names maskFirst maskAfter allowSign arrays initials elaborating

/-- Full named-array reader, including the native three-way component policy. -/
abbrev TableReader := Source → Nat → Environment → Nat → Nat → Bool →
  optParam ArrayBindings.Table {} → optParam ArrayBindings.Initials [] →
  optParam Bool false → optParam ArrayReadMode .allElements → Result

def tableReader : TableReader := fun text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =>
  ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads

def tableArrayAtomStep (recurse : TableReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter target : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let opened := symbol text position 40
  if opened = 0 ∨ (ArrayBindings.binding arrays.items target).isBoolean = true then invalid else
    let subscript := recurse text opened names maskFirst maskAfter true arrays [] false .noElements
    let closed := symbol text subscript.after 41
    if closed ≤ position ∨ subscript.operands = maxOperands ∨
        ArrayBindings.contains (ArrayBindings.binding arrays.items target) subscript.bounds = false then invalid
    else ⟨closed, ArrayBindings.readViewBounds arrays.items initials elaborating target subscript.bounds,
      subscript.operands + 1, false⟩

def tableAtomStep (recurse : TableReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := skip text position
  let reference := readReference text first
  let after := reference.after
  let index := lookup text names reference.first after reference.qualifierFirst reference.qualifierAfter
  let target := if reference.qualifierFirst = 0 then ArrayBindings.lookup text arrays.items reference.first after else 0
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      literalResult (ScalarLiteral.read text (skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := ScalarLiteral.read text first
    if number.after ≠ 0 then literalResult number false
    else if after = 0 then invalid
    else if QualifiedNames.masked text reference maskFirst maskAfter = true then invalid
    else if index ≠ 0 then ⟨after, (binding names index).bounds.normalize, 1, (binding names index).isStatic⟩
    else if reference.qualifierFirst ≠ 0 then invalid
    else if symbol text after 39 ≠ 0 then ArrayAttributes.read text position names arrays maskFirst maskAfter
    else if target = 0 ∨ arrayReads = .noElements ∨
        (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) then invalid
    else tableArrayAtomStep (@recurse) text after names maskFirst maskAfter target arrays initials elaborating

def tableUnaryStep (recurse : TableReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  unaryStep (fun text position names maskFirst maskAfter allowSign =>
    recurse text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    text position names maskFirst maskAfter

def tableCompoundStep (recurse : TableReader) (text : Source) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  compoundStep (fun text position names maskFirst maskAfter allowSign =>
    recurse text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    text names left maskFirst maskAfter

def tableGroupStep (recurse : TableReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := skip text (position + 1)
  if first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45
  then tableUnaryStep (@recurse) text first names maskFirst maskAfter arrays initials elaborating arrayReads
  else tableCompoundStep (@recurse) text names
    (recurse text first names maskFirst maskAfter true arrays initials elaborating arrayReads)
    maskFirst maskAfter arrays initials elaborating arrayReads

def tableReadStep (recurse : TableReader) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := skip text position
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 40 then
    tableGroupStep (@recurse) text first names maskFirst maskAfter arrays initials elaborating arrayReads
  else tableAtomStep (@recurse) text first names maskFirst maskAfter allowSign arrays initials elaborating arrayReads

structure Calls where
  lookupModel : Source → Environment → Nat → Nat → Nat → optParam Nat 0 → optParam Nat 0 → Nat
  lookup : Source → Environment → Nat → Nat → optParam Nat 0 → optParam Nat 0 → Nat
  readReference : Source → Nat → NameReference
  skip : Source → Nat → Nat
  symbol : Source → Nat → Nat → Nat
  nameAfter : Source → Nat → Nat
  binaryAfter : Source → Nat → Nat
  literalResult : ScalarLiteral.Result → Bool → Result
  unaryResult : Result → Bool → Result
  binaryResult : Result → Result → Nat → Result
  closeResult : Source → Result → Result
  readArrayAttribute : Source → Nat → Environment → ArrayBindings.Table → Nat → Nat → Bool → Result
  readArrayAtom : Source → Nat → Environment → Nat → Nat → Nat → ArrayBindings.Table → ArrayBindings.Initials → Bool → Result
  readAtom : TableReader
  readUnary : Source → Nat → Environment → Nat → Nat → optParam ArrayBindings.Table {} → optParam ArrayBindings.Initials [] → optParam Bool false → optParam ArrayReadMode .allElements → Result
  readCompound : Source → Nat → Environment → Result → Nat → Nat → optParam ArrayBindings.Table {} → optParam ArrayBindings.Initials [] → optParam Bool false → optParam ArrayReadMode .allElements → Result
  readGroup : Source → Nat → Environment → Nat → Nat → optParam ArrayBindings.Table {} → optParam ArrayBindings.Initials [] → optParam Bool false → optParam ArrayReadMode .allElements → Result
  readExpression : TableReader
  arrays : ArrayBindings.Native.Calls
  scalars : ScalarCalls
  integerLiteral : Source → Nat → ScalarLiteral.Result
  trivia : Source → Nat → Nat
  identifier : Source → Nat → Nat
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → Source → Bool
  lowercase : Nat → Nat

def modelCalls : Calls where
  lookupModel := @lookupFrom
  lookup := @ScalarExpression.lookup
  readReference := ScalarExpression.readReference
  skip := ScalarExpression.skip
  symbol := ScalarExpression.symbol
  nameAfter := ScalarExpression.nameAfter
  binaryAfter := ScalarExpression.binaryAfter
  literalResult := Native.literalResult
  unaryResult := Native.unaryResult
  binaryResult := Native.binaryResult
  closeResult := Native.closeResult
  readArrayAttribute := fun text position names arrays maskFirst maskAfter rangeQuery =>
    ArrayAttributes.read text position names arrays maskFirst maskAfter rangeQuery
  readArrayAtom := tableArrayAtomStep (@tableReader)
  readAtom := tableAtomStep (@tableReader)
  readUnary := tableUnaryStep (@tableReader)
  readCompound text _ names left maskFirst maskAfter := tableCompoundStep (@tableReader) text names left maskFirst maskAfter
  readGroup := tableGroupStep (@tableReader)
  readExpression := @tableReader
  arrays := ArrayBindings.Native.modelCalls
  scalars := scalarModel
  integerLiteral := ScalarLiteral.read
  trivia := Cursor.triviaPosition
  identifier := Named.identifierEnd
  equalName := Named.equalName
  nameIs := Named.nameIs
  lowercase := Silver.lowercase

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
