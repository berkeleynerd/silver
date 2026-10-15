module

public import Silver.ScalarExpressionNativeExpressions

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem decide_nat_eq (a b : Nat) : decide (a = b) = (a == b) := by
  by_cases same : a = b <;> simp [same]

def lookupEquation (calls : Calls) (text : Source) (names : Environment) (first after index : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (binding names index).first (binding names index).after first after
  then index else calls.lookupModel text names first after (index - 1)

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
    else ⟨false, Integer.Interval.empty⟩
  if left.after = 0 ∨ right.after = 0 ∨ checked.safe = false ∨ left.operands > maxOperands - right.operands
  then invalid else ⟨right.after, checked.bounds, left.operands + right.operands, left.isStatic && right.isStatic⟩

def closeEquation (calls : Calls) (text : Source) (value : Result) : Result :=
  let after := calls.symbol text value.after 41
  if after = 0 then invalid else {value with after := after}

def atomEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Result :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  let index := calls.lookup text names first after
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 then
    if !allowSign then invalid else
      calls.literalResult (calls.integerLiteral text (calls.skip text (first + 1))) (Cursor.byteAt text first == 45)
  else
    let number := calls.integerLiteral text first
    if number.after ≠ 0 then calls.literalResult number false
    else if index = 0 ∨ (maskFirst ≠ 0 ∧ calls.equalName text maskFirst maskAfter first after = true)
    then invalid
    else ⟨after, calls.scalars.normalize (binding names index).bounds, 1, (binding names index).isStatic⟩

def unaryReadEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) : Result :=
  let next := calls.skip text (position + 1)
  let number := calls.integerLiteral text next
  calls.closeResult text (if number.after ≠ 0 then calls.literalResult number (Cursor.byteAt text position == 45)
    else calls.unaryResult (calls.readExpression text next names maskFirst maskAfter false) (Cursor.byteAt text position == 45))

def compoundEquation (calls : Calls) (text : Source) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) : Result :=
  let next := calls.skip text left.after
  if next = 0 ∨ next > text.length then invalid
  else if Cursor.byteAt text next = 41 then {left with after := next + 1}
  else if Cursor.byteAt text next ≠ 43 ∧ Cursor.byteAt text next ≠ 45 ∧ Cursor.byteAt text next ≠ 42
  then invalid
  else calls.closeResult text (calls.binaryResult left (calls.readExpression text (next + 1) names maskFirst maskAfter false)
    (Cursor.byteAt text next))

def groupEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) : Result :=
  let first := calls.skip text (position + 1)
  if first > text.length then invalid
  else if Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45
  then calls.readUnary text first names maskFirst maskAfter
  else calls.readCompound text position names (calls.readExpression text first names maskFirst maskAfter true) maskFirst maskAfter

def expressionEquation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) : Result :=
  let first := calls.skip text position
  if first = 0 ∨ first > text.length then invalid
  else if Cursor.byteAt text first = 40 then calls.readGroup text first names maskFirst maskAfter
  else calls.readAtom text first names maskFirst maskAfter allowSign

theorem lookup_denotation (calls : Calls) (text : Source) (names : Environment) (first after index : Nat) :
    lookupBody.eval calls ({text,names,first,after,index} : Context).locals = lookupEquation calls text names first after index := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply4, apply3, apply2]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

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

theorem atom_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) :
    atomBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign} : Context).locals =
      atomEquation calls text position names maskFirst maskAfter allowSign := by
  dsimp +instances only [atomBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply4, apply3, apply2, Locals.set]
  simp [atomEquation, decide_nat_eq]

theorem unary_read_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) :
    readUnaryBody.eval calls ({text,position,names,maskFirst,maskAfter} : Context).locals =
      unaryReadEquation calls text position names maskFirst maskAfter := by
  dsimp +instances only [readUnaryBody, readCall, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [unaryReadEquation, decide_nat_eq]

theorem compound_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (left : Result) (maskFirst maskAfter : Nat) :
    compoundBody.eval calls ({text,position,names,left,maskFirst,maskAfter} : Context).locals =
      compoundEquation calls text names left maskFirst maskAfter := by
  dsimp +instances only [compoundBody, readCall, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [compoundEquation]

theorem group_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) :
    groupBody.eval calls ({text,position,names,maskFirst,maskAfter} : Context).locals =
      groupEquation calls text position names maskFirst maskAfter := by
  dsimp +instances only [groupBody, readDefaultCall, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [groupEquation]

theorem expression_denotation (calls : Calls) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) :
    expressionBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign} : Context).locals =
      expressionEquation calls text position names maskFirst maskAfter allowSign := by
  dsimp +instances only [expressionBody, Expr.eval, Context.locals, Calls.get, Field.get,
    apply6, apply5, apply4, apply3, apply2, Locals.set]
  simp [expressionEquation]

end Silver.ScalarExpression.Native
