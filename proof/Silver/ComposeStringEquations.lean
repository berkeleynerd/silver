module

public import Silver.ComposeContracts
public import Silver.ComposeStateBounds

@[expose] public section

namespace Silver.Compose.Expressions
open StringNative
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

def guardedEquation (calls : Calls) (text : Source) (position limit depth : Nat)
    (chained ending : Bool) : Bool :=
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  let characterAfter := calls.function .characterLiteral text first
  let quotedAfter := (calls.function .literal text first).after
  let named (word : String) := calls.function .nameIs text first after word
  let nextChained := chained || (decide (after > first) && (named "and" || named "or" || named "xor"))
  let nextEnding := decide (after > first) && named "end"
  let afterPunctuation := chained && (decide (first > text.length) || decide (Cursor.byteAt text first ≠ 59))
  if decide (first ≥ limit) then decide (depth ≠ 0) || chained
  else if decide (characterAfter > first) then calls.function .guardedAt text characterAfter limit depth chained false
  else if decide (quotedAfter > first) then calls.function .guardedAt text quotedAfter limit depth chained false
  else if decide (after > first) then
    if named "if" then
      if ending && decide (depth ≠ 0) then calls.function .guardedAt text after limit (depth - 1) chained false
      else if ending then calls.function .guardedAt text after limit 0 chained false
      else if decide (depth = maxSourceLength) then true
      else calls.function .guardedAt text after limit (depth + 1) chained false
    else calls.function .guardedAt text after limit depth nextChained nextEnding
  else calls.function .guardedAt text (first + 1) limit depth afterPunctuation false

theorem guarded_denotation (calls : Calls) (text : Source) (position limit depth : Nat)
    (chained ending : Bool) :
    guardedBody.eval calls (Context.locals {text,position,limit,depth,chained,ending}) =
      guardedEquation calls text position limit depth chained ending := by
  rfl

/-- Staged interpretation of the declarations and returns of the native index reader. -/
def indexedEquation (calls : Calls) (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) : ValueResult :=
  let take := calls.function .takeToken text
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  let target := calls.function .lookupName text names first after
  let low := calls.function .scalarRead text (take after (.symbol "(")) scalarNames arrays initials elaborating
  let info := (names.get target).getD {}
  if decide (target = 0) || info.isCharacter || info.dynamic ||
      decide (calls.function .scalarLookup text scalarNames first after ≠ 0) ||
      decide (low.after = 0) || calls.function .scalarEmpty low.bounds then invalidValue
  else if element then
    let following := take low.after (.symbol ")")
    if decide (following ≤ position) || decide (low.operands = maxExpressionOperands) ||
        decide (low.bounds.lower < info.firstIndex) || decide (low.bounds.upper > info.lastIndex)
    then invalidValue
    else ⟨following, 0, 1, 1, false, true, false, target, low.operands + 1, .singleton 1, .singleton 1⟩
  else
    let high := calls.function .scalarRead text (take low.after (.symbol "..")) scalarNames arrays initials elaborating
    let following := take high.after (.symbol ")")
    let operands := low.operands + high.operands
    if decide (following ≤ position) || calls.function .scalarEmpty high.bounds ||
        decide (operands ≥ maxExpressionOperands) ||
        decide (low.bounds.upper - high.bounds.lower > Integer.maxValue) ||
        ((!low.isStatic || !high.isStatic) && calls.function .guardedAt text 1 position 0 false false) ||
        (decide (low.bounds.lower ≤ high.bounds.upper) &&
          (decide (low.bounds.lower < info.firstIndex) || decide (high.bounds.upper > info.lastIndex)))
    then invalidValue
    else
      let minimum := max 0 (high.bounds.lower - low.bounds.upper + 1)
      let maximum := max 0 (high.bounds.upper - low.bounds.lower + 1)
      if decide (maximum > (maxSourceLength : Int)) then invalidValue
      else ⟨following, 0, minimum.toNat, maximum.toNat, false, true, false, target,
        operands + 1, low.bounds, high.bounds⟩

theorem indexed_denotation (calls : Calls) (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) :
    indexedBody.eval calls
      (Context.locals {text,position,names,scalarNames,arrays,initials,elaborating,characterElement := element}) =
      indexedEquation calls text position names scalarNames arrays initials elaborating element := by
  rfl

/-- The recursive call is an explicit callee, with its returned cursor updated in place. -/
def characterEquation (calls : Calls) (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) : ValueResult :=
  let first := calls.function .skip text position
  let quoted := calls.function .characterLiteral text first
  let after := calls.function .nameAfter text first
  let target := calls.function .lookupName text names first after
  let openAfter := calls.function .takeToken text first (.symbol "(")
  if decide (openAfter ≠ 0) then
    let value := calls.function .characterValue text openAfter names scalarNames arrays initials elaborating
    {value with after := calls.function .takeToken text value.after (.symbol ")")}
  else if decide (quoted ≠ 0) then
    ⟨quoted, 0, 1, 1, false, false, false, 0, 1, .singleton 1, .singleton 1⟩
  else if decide (target ≠ 0) && ((names.get target).getD {}).isCharacter &&
      decide (calls.function .scalarLookup text scalarNames first after = 0) then
    ⟨after, 0, 1, 1, false, true, false, target, 1, .singleton 1, .singleton 1⟩
  else calls.function .indexed text position names scalarNames arrays initials elaborating true

theorem character_denotation (calls : Calls) (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    characterBody.eval calls (Context.locals {text,position,names,scalarNames,arrays,initials,elaborating}) =
      characterEquation calls text position names scalarNames arrays initials elaborating := by
  rfl

def concatenatedLastEquation (calls : Calls) (left : ExpressionState) (right : ValueResult) : Integer.Interval :=
  let first := calls.function .concatenatedFirst left right
  let minimum : Int := (left.minimumLength : Int) + right.minimumLength
  let maximum : Int := (left.staticLength : Int) + right.staticLength +
    ((left.dynamicCount : Int) + (if right.dynamicSeen then 1 else 0)) * maxSourceLength
  let low := first.lower + minimum - 1
  let high := first.upper + maximum - 1
  if decide (left.operands = 0) || (decide (left.staticLength = 0) && decide (left.dynamicCount = 0))
  then right.lastIndex
  else if calls.function .scalarEmpty first || decide (low < Integer.minValue) ||
      decide (low > Integer.maxValue) || decide (high < Integer.minValue) || decide (high > Integer.maxValue)
  then .empty
  else if decide (minimum = 0) then (Integer.Interval.mk low high).join right.lastIndex
  else ⟨low, high⟩

theorem concatenatedLast_denotation (calls : Calls) (left : ExpressionState) (right : ValueResult) :
    concatenatedLastBody.eval calls (Context.locals {scan := left,value := right}) =
      concatenatedLastEquation calls left right := by
  rfl

def characterDeclarationEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let take := calls.function .takeToken text
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colonAfter := take after (.symbol ":")
  let constantAfter := take colonAfter (.word "constant")
  let typeFirst := calls.function .skip text (if decide (constantAfter ≠ 0) then constantAfter else colonAfter)
  let typeAfter := take typeFirst (.word "character")
  let value := calls.function .characterValue text (take typeAfter (.symbol ":=")) state.names state.scalarNames
    state.arrayNames.names state.arrayNames.values true
  let following := take value.after (.symbol ";")
  if !calls.function .newName text state first after arguments ||
      decide (typeAfter = 0) || decide (following ≤ state.position) || decide (state.names.length = maxBindings) ||
      calls.function .nameIs text first after "character" ||
      decide (calls.function .lookupName text state.names typeFirst typeAfter ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.names typeFirst typeAfter ≠ 0) ||
      decide (calls.function .subtypeLookup text state.subtypeNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .booleanLookup text state.booleanNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .functionLookup text state.functions typeFirst typeAfter ≠ 0) ||
      calls.function .formalHides text state typeFirst typeAfter ||
      (state.hiding.integerHidden && calls.function .nameIs text typeFirst typeAfter "integer") ||
      (state.hiding.booleanHidden && calls.function .nameIs text typeFirst typeAfter "boolean") ||
      (state.hiding.characterHidden && calls.function .nameIs text typeFirst typeAfter "character")
  then invalidState
  else calls.function .addBindingWithCharacter state first after value (decide (constantAfter = 0)) following true

theorem characterDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    characterDeclarationBody.eval calls (Context.locals {text,state,arguments}) =
      characterDeclarationEquation calls text state arguments := by
  rfl

/-- The executable progress guard preserves the existing admission rule on the
native Valid_State domain. Successful model declarations already advance. -/
theorem characterDeclaration_progress_guard (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    let parts := characterDeclarationParts text state
    (!newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.typeAfter = 0) || decide (parts.following ≤ state.position) ||
      decide (state.names.length = maxBindings) ||
      Named.nameIs text parts.first parts.after ("character".toList.map Char.toNat) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0) ||
      decide (ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0) ||
      decide (ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0) ||
      decide (IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter ≠ 0) ||
      decide (BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter ≠ 0) ||
      decide (FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter ≠ 0) ||
      formalHides text state parts.typeFirst parts.typeAfter ||
      (state.hiding.integerHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat)) ||
      (state.hiding.booleanHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat)) ||
      (state.hiding.characterHidden && Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat))) =
      characterDeclarationRejected text state arguments parts := by
  generalize partsEq : characterDeclarationParts text state = parts
  dsimp only
  by_cases nonprogress : parts.following ≤ state.position
  · have rejected : characterDeclarationRejected text state arguments parts = true := by
      apply Bool.ne_false_iff.mp
      intro notRejected
      have following : parts.following ≠ 0 := by
        intro zero
        simp [characterDeclarationRejected, zero] at notRejected
      have resultPosition : (characterDeclarationAt text state arguments).position = parts.following := by
        simp only [characterDeclarationAt, partsEq, notRejected, Bool.false_eq_true, ↓reduceIte, addBinding]
      have positive : (characterDeclarationAt text state arguments).position ≠ 0 := by
        rw [resultPosition]
        exact following
      have advances := model_character_declaration_advances text state arguments stateValid positive
      rw [resultPosition] at advances
      omega
    simp only [decide_eq_true nonprogress, Bool.or_true, Bool.true_or, rejected]
  · have following : parts.following ≠ 0 := by omega
    simp only [characterDeclarationRejected, Bool.decide_coe, Bool.decide_or, Bool.or_assoc,
      decide_eq_false_iff_not.mpr nonprogress, decide_eq_false_iff_not.mpr following]

end Silver.Compose.Expressions
