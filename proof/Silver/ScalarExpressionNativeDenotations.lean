module

public import Silver.ScalarExpressionNativeExpressions

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem decide_nat_eq (a b : Nat) : decide (a = b) = (a == b) := by
  by_cases same : a = b <;> simp [same]

def lookupEquation (calls : Calls) (text : Source) (names : Environment) (first after index : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (binding names index).first (binding names index).after first after &&
      (if qualifierFirst = 0 then (binding names index).qualifierFirst == 0
       else decide (0 < (binding names index).qualifierFirst) &&
         calls.equalName text (binding names index).qualifierFirst (binding names index).qualifierAfter
           qualifierFirst qualifierAfter)
  then index else calls.lookupModel text names first after (index - 1) qualifierFirst qualifierAfter

def referenceEquation (calls : Calls) (text : Source) (position : Nat) : NameReference :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  let dot := calls.skip text after
  if first = 0 ∨ after ≤ first then {}
  else if 0 < dot ∧ dot ≤ text.length ∧ Cursor.byteAt text dot = 46 ∧
      (dot = text.length ∨ Cursor.byteAt text (dot + 1) ≠ 46) then
    let memberFirst := calls.skip text (dot + 1)
    let memberAfter := calls.nameAfter text memberFirst
    if memberFirst = 0 ∨ memberAfter ≤ memberFirst then {}
    else ⟨memberFirst, memberAfter, first, after⟩
  else ⟨first, after, 0, 0⟩

def symbolEquation (calls : Calls) (text : Source) (position item : Nat) : Nat :=
  let first := calls.skip text position
  if first = 0 ∨ first > text.length ∨ Cursor.byteAt text first ≠ item then 0 else first + 1

def literalEquation (calls : Calls) (number : ScalarLiteral.Result) (negative : Bool) : Result :=
  let checked := calls.scalars.checked (signedValue number.value negative) (signedValue number.value negative)
  if number.after = 0 ∨ checked.safe = false then invalid
  else ⟨number.after, checked.bounds, 1, true⟩

def unaryEquation (calls : Calls) (operand : Result) (negative : Bool) : Result :=
  let checked := if negative then calls.scalars.negate operand.bounds else ⟨true, operand.bounds⟩
  if operand.after = 0 ∨ checked.safe = false then invalid
  else {operand with bounds := checked.bounds}

def binaryEquation (calls : Calls) (left right : Result) (operator : Nat) : Result :=
  let checked := if operator = 43 then calls.scalars.add left.bounds right.bounds
    else if operator = 45 then calls.scalars.subtract left.bounds right.bounds
    else if operator = 42 then calls.scalars.multiply left.bounds right.bounds
    else if operator = 47 then calls.scalars.divide left.bounds right.bounds
    else if operator = 109 then calls.scalars.modulo left.bounds right.bounds
    else if operator = 114 then calls.scalars.remainder left.bounds right.bounds
    else ⟨false, Integer.Interval.empty⟩
  if left.after = 0 ∨ right.after = 0 ∨ checked.safe = false ∨ left.operands > maxOperands - right.operands
  then invalid else ⟨right.after, checked.bounds, left.operands + right.operands, left.isStatic && right.isStatic⟩

def closeEquation (calls : Calls) (text : Source) (value : Result) : Result :=
  let after := calls.symbol text value.after 41
  if after = 0 then invalid else {value with after := after}

def arrayAtomEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter target : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : Result :=
  let opened := calls.symbol text position 40
  if opened = 0 ∨ (ArrayBindings.binding arrays.items target).isBoolean = true then invalid else
    let subscript := calls.readExpression text opened names maskFirst maskAfter true arrays [] false .noElements
    let closed := calls.symbol text subscript.after 41
    if closed ≤ position ∨ subscript.operands = maxOperands ∨
        calls.arrays.contains (ArrayBindings.binding arrays.items target) subscript.bounds = false then invalid
    else ⟨closed, calls.arrays.readBounds arrays initials elaborating target subscript.bounds,
      subscript.operands + 1, false⟩

def atomEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := calls.skip text position
  let reference := calls.readReference text first
  let after := reference.after
  let index := calls.lookup text names reference.first after reference.qualifierFirst reference.qualifierAfter
  let target := if reference.qualifierFirst = 0 then calls.arrays.lookup text arrays reference.first after else 0
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      calls.literalResult (calls.integerLiteral text (calls.skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := calls.integerLiteral text first
    if number.after ≠ 0 then calls.literalResult number false
    else if after = 0 then invalid
    else if maskFirst ≠ 0 ∧
        (if reference.qualifierFirst = 0 then calls.equalName text maskFirst maskAfter reference.first after
         else calls.equalName text maskFirst maskAfter reference.qualifierFirst reference.qualifierAfter) = true then invalid
    else if index ≠ 0 then ⟨after, calls.scalars.normalize (binding names index).bounds, 1, (binding names index).isStatic⟩
    else if reference.qualifierFirst ≠ 0 then invalid
    else if calls.symbol text after 39 ≠ 0 then
      calls.readArrayAttribute text position names arrays maskFirst maskAfter false
    else if target = 0 ∨ arrayReads = .noElements ∨
        (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) then invalid
    else calls.readArrayAtom text after names maskFirst maskAfter target arrays initials elaborating

def unaryReadEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let next := calls.skip text (position + 1)
  let number := calls.integerLiteral text next
  calls.closeResult text (if number.after ≠ 0 then calls.literalResult number (Cursor.byteAt text position == 45)
    else calls.unaryResult (calls.readExpression text next names maskFirst maskAfter false arrays initials elaborating arrayReads) (Cursor.byteAt text position == 45))

def binaryAfterEquation (calls : Calls) (text : Source) (position : Nat) : Nat :=
  let after := calls.nameAfter text position
  if position = 0 ∨ position > text.length then 0
  else if Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
      Cursor.byteAt text position = 42 then position + 1
  else if Cursor.byteAt text position = 47 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 61 then 0 else position + 1
  else if after ≠ 0 ∧ (calls.nameIs text position after ("mod".toList.map Char.toNat) = true ∨
      calls.nameIs text position after ("rem".toList.map Char.toNat) = true) then after else 0

def compoundEquation (calls : Calls) (text : Source) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let next := calls.skip text left.after
  let after := calls.binaryAfter text next
  if next = 0 ∨ next > text.length then invalid
  else if Cursor.byteAt text next = 41 then {left with after := next + 1}
  else if after = 0 then invalid
  else calls.closeResult text (calls.binaryResult left (calls.readExpression text after names maskFirst maskAfter false arrays initials elaborating arrayReads)
    (calls.lowercase (Cursor.byteAt text next)))

def groupEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := calls.skip text (position + 1)
  if first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45
  then calls.readUnary text first names maskFirst maskAfter arrays initials elaborating arrayReads
  else calls.readCompound text position names (calls.readExpression text first names maskFirst maskAfter true arrays initials elaborating arrayReads) maskFirst maskAfter arrays initials elaborating arrayReads

def expressionEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) : Result :=
  let first := calls.skip text position
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 40 then calls.readGroup text first names maskFirst maskAfter arrays initials elaborating arrayReads
  else calls.readAtom text first names maskFirst maskAfter allowSign arrays initials elaborating arrayReads

theorem binaryAfter_denotation (calls : Calls) (text : Source) (position : Nat) :
    binaryAfterBody.eval calls ({text,position} : Context).locals = binaryAfterEquation calls text position := by
  dsimp +instances only [binaryAfterBody, Expr.eval, Context.locals, Calls.get, apply4, apply3, apply2, Locals.set]
  simp [binaryAfterEquation, Bool.or_eq_true, Bool.and_eq_true]

theorem lookup_denotation (calls : Calls) (text : Source) (names : Environment) (first after index : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) :
    lookupBody.eval calls ({text,names,first,after,index,qualifierFirst,qualifierAfter} : Context).locals =
      lookupEquation calls text names first after index qualifierFirst qualifierAfter := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

theorem reference_denotation (calls : Calls) (text : Source) (position : Nat) :
    referenceBody.eval calls ({text,position} : Context).locals = referenceEquation calls text position := by
  dsimp +instances only [referenceBody, Expr.eval, Context.locals, Calls.get, Field.get,
    apply2, Locals.set]
  simp [referenceEquation, Bool.and_eq_true, Bool.or_eq_true, and_assoc]

theorem symbol_denotation (calls : Calls) (text : Source) (position item : Nat) :
    symbolBody.eval calls ({text,position,item} : Context).locals = symbolEquation calls text position item := by
  dsimp +instances only [symbolBody, Expr.eval, Context.locals, Calls.get, Field.get, apply2, Locals.set]
  simp [symbolEquation, or_assoc]

theorem literal_denotation (calls : Calls) (number : ScalarLiteral.Result) (negative : Bool) :
    literalBody.eval calls ({number,negative} : Context).locals = literalEquation calls number negative := by
  dsimp +instances only [literalBody, Expr.eval, Context.locals, Calls.get, Field.get, apply2, Locals.set]
  simp [literalEquation, signedValue]

theorem unary_denotation (calls : Calls) (operand : Result) (negative : Bool) :
    unaryBody.eval calls ({operand,negative} : Context).locals = unaryEquation calls operand negative := by
  dsimp +instances only [unaryBody, Expr.eval, Context.locals, Calls.get, Field.get, Locals.set]
  simp [unaryEquation]

theorem binary_denotation (calls : Calls) (left right : Result) (operator : Nat) :
    binaryBody.eval calls ({left,right,operator} : Context).locals = binaryEquation calls left right operator := by
  dsimp +instances only [binaryBody, Expr.eval, Context.locals, Calls.get, Field.get, apply2, Locals.set]
  simp [binaryEquation, or_assoc]

theorem close_denotation (calls : Calls) (text : Source) (value : Result) :
    closeBody.eval calls ({text,value} : Context).locals = closeEquation calls text value := by
  dsimp +instances only [closeBody, Expr.eval, Context.locals, Calls.get, Field.get, apply3, apply2, Locals.set]
  simp [closeEquation]

theorem arrayAtom_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter target : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arrayAtomBody.eval calls ({text,position,names,maskFirst,maskAfter,target,arrays,initials,elaborating} : Context).locals =
      arrayAtomEquation calls text position names maskFirst maskAfter target arrays initials elaborating := by
  dsimp +instances only [arrayAtomBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply4, apply3, apply2, Locals.set]
  simp [arrayAtomEquation, or_assoc]

theorem atom_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) :
    atomBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating,arrayReads} : Context).locals =
      atomEquation calls text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
  dsimp +instances only [atomBody, readArrayArgs, arrayArgs, Expr.eval, Context.locals, Calls.get, Field.get, apply6, apply5, apply4, apply3, apply2, Locals.set]
  by_cases qualified : (calls.readReference text (calls.skip text position)).qualifierFirst = 0 <;>
    simp [atomEquation, qualified, decide_nat_eq, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

theorem unary_read_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) :
    readUnaryBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals =
      unaryReadEquation calls text position names maskFirst maskAfter arrays initials elaborating arrayReads := by
  dsimp +instances only [readUnaryBody, readCall, readArrayArgs, arrayArgs, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [unaryReadEquation, decide_nat_eq]

theorem compound_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) :
    compoundBody.eval calls ({text,position,names,left,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals =
      compoundEquation calls text names left maskFirst maskAfter arrays initials elaborating arrayReads := by
  dsimp +instances only [compoundBody, readCall, readArrayArgs, arrayArgs, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [compoundEquation]

theorem group_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) :
    groupBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals =
      groupEquation calls text position names maskFirst maskAfter arrays initials elaborating arrayReads := by
  dsimp +instances only [groupBody, readDefaultCall, namedArrayArgs, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [groupEquation]

theorem expression_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) :
    expressionBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating,arrayReads} : Context).locals =
      expressionEquation calls text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
  dsimp +instances only [expressionBody, readArrayArgs, arrayArgs, namedArrayArgs, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [expressionEquation]

end Silver.ScalarExpression.Native
