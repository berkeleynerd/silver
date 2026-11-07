module

public import Silver.ComposeModelRecursion
public import Silver.ComposeStateBounds
public import Silver.ComposeNameBridge
public import Silver.ComposeSubtypeModelEquations
public import Silver.ComposeArrayModel
public import Silver.ComposeStringDenotations

@[expose] public section

/-! Concrete model helper witnesses, independent of source recognition. The range
contracts are supplied separately, without assuming any definition equations. -/

namespace Silver.Compose.Expressions
open Named
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read

private theorem model_argument_definition (text : Source) (state : ParserState) :
    modelCalls.function .argument text state = argumentBody.eval modelCalls (Context.locals {text,state}) := by
  dsimp +instances only [modelCalls, Names.modelCalls, argumentBody, Expr.eval, Context.locals,
    Locals.set, Calls.get, Field.get, spelling, isWord]
  dsimp +instances only [argumentAt, argumentParts, argumentFirst, argumentAfter,
    argumentDefaultPosition, tokenAfter, ShellToken.symbol, ShellToken.word]
  simp [or_assoc]

private theorem model_definition_ranges (ranges : RangeContracts modelCalls) : HelperRanges modelCalls := ranges.toHelperRanges

private theorem model_definition_names : Names.InterpretedSource modelCalls.names := Names.model_interpreted

private theorem model_definition_fixedBounds : ∀ length dynamic isCharacter firstIndex lastIndex slot,
    length ≤ maxSourceLength → Integer.InRange firstIndex → Integer.InRange lastIndex →
    1 ≤ slot → slot ≤ maxBindings →
    modelCalls.function .fixedBoundsValid length dynamic isCharacter firstIndex lastIndex slot =
      StringNative.fixedBoundsBody.eval modelCalls
        (Context.locals {length,dynamicSeen := dynamic,isCharacter,firstIndex,lastIndex,slot}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, StringNative.fixedBoundsBody,
    fixedBoundsValid]
  simp only [Bool.decide_and, Bool.and_assoc, decide_eq_true_eq]
  all_goals rfl

private theorem model_definition_characterLiteral : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    modelCalls.function .characterLiteral text position =
      StringNative.characterLiteralBody.eval modelCalls (Context.locals {text,position}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, StringNative.characterLiteralBody,
    characterLiteralAfter]
  simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc]

private theorem model_definition_concatenatedFirst : ∀ text left right,
    NativeScan text left → NativeValue text right →
    modelCalls.function .concatenatedFirst left right =
      StringNative.concatenatedFirstBody.eval modelCalls (Context.locals {scan := left,value := right}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, Field.get,
    StringNative.concatenatedFirstBody, concatenatedFirst]
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]

private theorem model_definition_addBindingWithCharacter : ∀ text, ValidText text →
    ∀ state first after value mutable following characterObject,
    NativeState .basic text state → ValidCursor text first → ValidCursor text after →
    NativeValue text value → ValidCursor text following → state.names.length < maxBindings →
    fixedBoundsValid value.staticLength value.dynamicSeen characterObject value.firstIndex.lower value.lastIndex.lower
      (state.names.length + 1) = true →
    modelCalls.function .addBindingWithCharacter state first after value mutable following characterObject =
      addBindingBody.eval modelCalls (Context.locals {text,state,first,after,value,mutable,following,characterObject}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, Field.get, addBindingBody, addBinding] <;> simp +instances

private theorem model_definition_scalarLookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → ValidCursor text first → ValidCursor text after →
    modelCalls.function .scalarLookup text names first after = ScalarExpression.lookup text names first after := by intros; rfl

private theorem model_definition_scalarRead : ∀ text, ValidText text → ∀ position names arrays initials elaborating,
    ValidCursor text position → ScalarExpression.ValidEnvironment text names →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    modelCalls.function .scalarRead text position names arrays initials elaborating =
      ScalarExpression.read text position names 0 0 true arrays initials elaborating := by intros; rfl

private theorem model_definition_arrayLookup : ∀ text, ValidText text → ∀ arrays first after,
    ArrayBindings.ValidMetadata text arrays → ValidCursor text first → ValidCursor text after →
    modelCalls.function .arrayLookup text arrays first after = ArrayBindings.lookup text arrays first after := by intros; rfl

private theorem model_definition_arrayPut : ∀ state value,
    state.arrayNames.used < ArrayBindings.maxElements → Integer.InRange value →
    modelCalls.function .arrayPut state value = arrayPutBody.eval modelCalls (arrayPutLocals state value) := by
  intros
  rw [arrayPut_denotation]
  rfl

private theorem model_definition_arrayAdd : ∀ text, ValidText text →
    ∀ state first after bounds offset length mutable following componentBounds isBoolean,
    NativeState .basic text state → ValidName text first after →
    ArrayBindings.ValidBinding ⟨first, after, bounds, offset, length, mutable, componentBounds, isBoolean⟩ →
    state.arrayNames.names.length < ArrayBindings.maxBindings →
    offset + length ≤ state.arrayNames.used → ArrayAddDomain state.arrayNames.names offset →
    ValidCursor text following →
    modelCalls.function .arrayAdd text state first after bounds offset length mutable following componentBounds isBoolean =
      arrayAddBody.eval modelCalls (arrayAddLocals text state first after bounds offset length mutable following componentBounds isBoolean) := by
  intros
  rw [arrayAdd_denotation]
  rfl

private theorem model_definition_arrayValuesModel : ∀ text, ValidText text →
    ∀ source result position length parsed componentBounds,
    componentBounds.Bounded → ArrayValuesDomain text source result position length parsed →
    modelCalls.function .arrayValuesModel text source result position length parsed componentBounds =
      arrayValuesModelBody.eval modelCalls (arrayValuesLocals text source result position length parsed componentBounds) := by
  intro text _ source result position length parsed componentBounds _ domain
  rw [arrayValues_denotation, model_arrayValues_equation text source result position length parsed componentBounds domain.parsedBound]
  rfl

private theorem model_definition_arrayValues : ∀ text, ValidText text →
    ∀ source result position length parsed componentBounds,
    componentBounds.Bounded → ArrayValuesDomain text source result position length parsed →
    modelCalls.function .arrayValues text source result position length parsed componentBounds =
      modelCalls.function .arrayValuesModel text source result position length parsed componentBounds := by
  intros
  rfl

private theorem model_definition_arrayDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState .basic text state →
    modelCalls.function .arrayDeclaration text state arguments =
      (arrayDeclarationBody true).eval modelCalls (Context.locals {text,state,arguments}) := by
  intro text _ state arguments _
  rw [arrayDeclaration_denotation, model_arrayDeclaration_equation]
  rfl

private theorem model_definition_scalarLiteral : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    modelCalls.function .scalarLiteral text position = ScalarLiteral.read text position := by intros; rfl

private theorem model_definition_scalarAppend : ∀ names item, names.length < ScalarExpression.maxBindings →
    modelCalls.function .scalarAppend names item = names ++ [item] := by intros; rfl

private theorem model_definition_scalarEmpty : ∀ value, value.Bounded →
    modelCalls.function .scalarEmpty value = value.isEmpty := by intros; rfl

private theorem model_definition_imageMinimum : ∀ value, value.Bounded →
    modelCalls.function .imageMinimum value = (LengthSummary.ofImage value).minimumLength := by intros; rfl

private theorem model_definition_imageMaximum : ∀ value, value.Bounded →
    modelCalls.function .imageMaximum value = (LengthSummary.ofImage value).staticLength := by intros; rfl

private theorem model_definition_image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    modelCalls.function .image text position names scalarNames integerHidden arrays initials elaborating =
      imageBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get,
    imageBody, imageAt, imageParts, imageValue, ShellToken.word, ShellToken.symbol, spelling, isWord]
  simp +instances only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  have empty : ∀ bounds, (LengthSummary.ofImage bounds).empty = bounds.isEmpty := by
    intro bounds
    unfold LengthSummary.ofImage
    split <;> simp_all
  simp only [empty, Bool.decide_or, Bool.or_assoc]
  all_goals rfl

private theorem model_definition_nameIs : ∀ text, ValidText text → ∀ first after word,
    ValidName text first after → 0 < word.toList.length → word.toList.length ≤ 16 →
    modelCalls.function .nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat) := by intros; rfl


private theorem model_definition_skip : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    modelCalls.function .skip text position =
      skipBody.eval modelCalls (Context.locals {text,position}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, skipBody, spelling, isWord, skipAt] <;> simp +instances

private theorem model_definition_name : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    modelCalls.function .nameAfter text position =
      nameBody.eval modelCalls (Context.locals {text,position}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, nameBody, spelling, isWord, nameAfter] <;> simp +instances

private theorem model_definition_fixed : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    modelCalls.function .fixedAfter text position token =
      fixedBody.eval modelCalls (Context.locals {text,position,token}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, fixedBody, spelling, isWord, fixedAfter] <;> simp +instances <;> rfl

private theorem model_definition_take : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    modelCalls.function .takeToken text position token =
      fixedBody.eval modelCalls (Context.locals {text,position,token}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, fixedBody, spelling, isWord, fixedAfter] <;> simp +instances <;> rfl

private theorem model_definition_lookupFrom : ∀ text, ValidText text → ∀ names first after index,
    NativeNames text names → ValidName text first after → 1 ≤ index → index ≤ names.length + 1 →
    modelCalls.function .lookupFrom text names first after index =
      lookupFromBody.eval modelCalls (Context.locals {text,names,first,after,index}) := by
  intro text valid names first after index namesValid nameValid positive bounded
  rw [show modelCalls.function .lookupFrom text names first after index = lookupFrom text names first after index from rfl,
    lookupFrom_equation text names first after index positive]
  dsimp +instances only [lookupFromBody, Expr.eval, Context.locals, modelCalls, modelPrimitives, Calls.get, Field.get] <;> simp +instances [decide_eq_true_eq]

private theorem model_definition_lookup : ∀ text, ValidText text → ∀ names first after,
    NativeNames text names → ValidCursor text first → ValidCursor text after →
    modelCalls.function .lookupName text names first after =
      lookupBody.eval modelCalls (Context.locals {text,names,first,after}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, lookupBody, spelling, isWord, lookupName] <;> simp +instances [Bool.or_eq_true]

private theorem model_definition_literal : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    modelCalls.function .literal text position =
      literalBody.eval modelCalls (Context.locals {text,position}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, literalBody, spelling, isWord, literalAt] <;> simp +instances [Bool.and_eq_true, and_assoc]

private theorem model_definition_workTail : ∀ text, ValidText text → ∀ position remaining,
    ValidCursor text position → remaining ≤ maxConcatenations →
    modelCalls.function .workTail text position remaining =
      workTailBody.eval modelCalls (Context.locals {text,position,remaining}) := model_workTail_equation

private theorem model_definition_workBudget : ∀ text, ValidText text →
    modelCalls.function .workBudget text = workBudgetBody.eval modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, workBudgetBody, spelling, isWord, withinWorkBudget] <;> simp +instances

private theorem model_definition_value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    modelCalls.function .value text position names scalarNames integerHidden arrays initials elaborating =
      valueBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, valueBody, spelling, isWord, ShellToken.symbol, valueAt] <;> simp +instances [and_assoc]

private theorem model_definition_newName : ∀ text, ValidText text → ∀ state first after arguments,
    NativeState .basic text state → ValidCursor text first → ValidCursor text after →
    modelCalls.function .newName text state first after arguments =
      newNameBody.eval modelCalls (Context.locals {text,state,first,after,arguments}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Field.get,
    newNameBody, spelling, isWord, newNameAllowed]
  simp only [Bool.decide_and, Bool.and_assoc]

private theorem model_definition_addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    NativeState .basic text state → ValidCursor text first → ValidCursor text after → NativeValue text value → ValidCursor text following → state.names.length < maxBindings →
    fixedBoundsValid value.staticLength value.dynamicSeen false value.firstIndex.lower
      value.lastIndex.lower (state.names.length + 1) = true →
    modelCalls.function .addBinding state first after value mutable following =
      addBindingBody.eval modelCalls (Context.locals {text,state,first,after,value,mutable,following}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Field.get, addBindingBody, spelling, isWord, addBinding] <;> simp +instances

private theorem model_definition_stringDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState .basic text state → modelCalls.function .stringDeclaration text state arguments =
      stringDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) := by
  intro text valid state arguments stateValid
  let first := declarationFirst text state
  let after := declarationAfter text state
  let constant := declarationConstantAfter text state
  let value := expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
    state.arrayNames.names state.arrayNames.values true
  let following := fixedAfter text value.after ";" false
  change
    (if !newNameAllowed text state first after arguments ||
        decide (following = 0 ∨ state.names.length = maxBindings) ||
        !fits value maxSourceLength || value.emptyValue ||
        decide (value.minimumLength ≠ value.staticLength) ||
        !fixedDeclarationBounds value (state.names.length + 1) then invalidState
      else addBinding state first after value.value (decide (constant = 0)) following) = _
  have body : stringDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) =
      (if ((!newNameAllowed text state first after arguments || decide (following = 0)) ||
          decide (state.names.length = maxBindings)) || !fits value maxSourceLength ||
          value.emptyValue || decide (value.minimumLength ≠ value.staticLength) ||
          !fixedDeclarationBounds value (state.names.length + 1)
        then invalidState
        else addBinding state first after value.value (decide (constant = 0)) following) := by
    dsimp +instances only [stringDeclarationBody, Expr.eval, Context.locals, Locals.set,
      modelCalls, Calls.get, Field.get, spelling, isWord, ShellToken.symbol, ShellToken.word]
    dsimp +instances only [first, after, constant, value, following, declarationFirst, declarationAfter,
      declarationConstantAfter, declarationColonAfter, declarationValuePosition, declarationIntegerHidden,
      ExpressionResult.value, fixedDeclarationBounds]
    simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, Bool.or_eq_true,
      Bool.not_eq_true', Bool.not_and, Bool.or_eq_false_iff, Bool.not_eq_false', Bool.and_eq_true, Bool.decide_or, Bool.or_assoc, Bool.decide_and, Bool.and_assoc, decide_eq_true_eq, ne_eq, ite_not]
  rw [body]
  simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]



private theorem model_definition_argument : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .argument text state =
      argumentBody.eval modelCalls (Context.locals {text,state}) := fun text _ state _ => model_argument_definition text state


private theorem model_definition_expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → NativeScan text scan →
    modelCalls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating =
      expressionStepBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, expressionStepBody, spelling, isWord, expressionStep, ShellToken.symbol] <;> simp +instances [Bool.and_eq_true, Bool.or_eq_true, or_assoc, and_assoc]

private theorem model_definition_fits : ∀ text, ValidText text → ∀ result capacity,
    NativeResult text result → capacity ≤ maxSourceLength →
    modelCalls.function .fits result capacity =
      fitsBody.eval modelCalls (Context.locals {text,result,capacity}) := by
  intro text valid result capacity resultValid bounded
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Field.get, fitsBody, spelling, isWord, fits] <;> simp +instances

private theorem model_definition_comparison : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .comparison text state =
      comparisonBody.eval modelCalls (Context.locals {text,state}) := by
  intro text valid state stateValid
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, comparisonBody, spelling, isWord, comparisonAt, ShellToken.symbol] <;> simp +instances [Bool.and_eq_true, Bool.or_eq_true, and_assoc, or_assoc]
  generalize fits (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity = a
  generalize fits (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).after "=" false) state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity = b
  generalize (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).namedSeen = c
  generalize (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).after "=" false) state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).namedSeen = d
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

private theorem model_definition_tail (ranges : RangeContracts modelCalls) : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → NativeScan text scan →
    modelCalls.function .tail text names scan scalarNames integerHidden arrays initials elaborating =
      tailBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan}) := model_tail_equation ranges

private theorem model_definition_expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    modelCalls.function .expression text position names scalarNames integerHidden arrays initials elaborating =
      expressionBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, expressionBody, spelling, isWord, expressionAt] <;> simp +instances

private theorem model_definition_target : ∀ text, ValidText text → ∀ state sameTarget,
    NativeState .basic text state →
    modelCalls.function .target text state sameTarget =
      targetBody.eval modelCalls (Context.locals {text,state,sameTarget}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, targetBody, spelling, isWord, targetAt] <;> simp +instances [Bool.and_eq_true, Bool.or_eq_true, or_assoc]

private theorem model_definition_dynamic : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .dynamic text state =
      dynamicBody.eval modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, dynamicBody, spelling, isWord, dynamicAt] <;> simp +instances [Bool.or_eq_true, or_assoc]

private theorem model_definition_assignmentValue : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .assignmentValue text state =
      assignmentBody.eval modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, assignmentBody, spelling, isWord, assignmentAt]
  simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]
  have reorder (a b c d e f g : Prop) :
      (a ∨ b ∨ c ∨ d ∨ e ∨ f ∨ g) ↔ (a ∨ d ∨ g ∨ b ∨ c ∨ e ∨ f) := by
    simp only [or_left_comm, or_comm]
  congr 1
  exact propext (reorder _ _ _ _ _ _ _)

private theorem model_definition_output : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .output text state =
      outputBody.eval modelCalls (Context.locals {text,state}) := by
  intro text valid state stateValid
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, outputBody, spelling, isWord, outputAt] <;> simp +instances
  cases fits (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity <;> rfl

private theorem model_definition_capacity : ∀ text, ValidText text → ∀ state,
    NativeState .basic text state →
    modelCalls.function .capacity text state =
      capacityBody.eval modelCalls (Context.locals {text,state}) := by
  intro text valid state stateValid
  exact model_capacity_equation text valid state stateValid.valid

private theorem model_definition_readDeclarations : ∀ text, ValidText text → ∀ state arguments, NativeState .basic text state →
    modelCalls.function .readDeclarations text state arguments = modelCalls.function .declarations text state arguments := by
  intros
  rfl

theorem model_helpers (ranges : RangeContracts modelCalls) :
    HelperEquations modelCalls modelCalls where
  ranges := model_definition_ranges ranges
  names := model_definition_names
  fixedBounds := model_definition_fixedBounds
  characterLiteral := model_definition_characterLiteral
  guardedAt := by
    intro text _ position limit depth chained ending positive bounded limitBound _
    exact (model_guarded_denotation text position limit depth chained ending positive bounded limitBound).symm
  indexed := by
    intro text _ position names scalarNames arrays initials elaborating element _ _ _ _ _
    exact (model_indexed_denotation text position names scalarNames arrays initials elaborating element).symm
  characterValue := by
    intro text _ position names scalarNames arrays initials elaborating bound _ _ _ _
    exact (model_character_denotation text position names scalarNames arrays initials elaborating bound).symm
  concatenatedLast := by
    intro text left right _ _
    exact (model_concatenatedLast_denotation left right).symm
  characterDeclaration := by
    intro text _ state arguments context
    exact (model_characterDeclaration_denotation text state arguments context.valid).symm
  concatenatedFirst := model_definition_concatenatedFirst
  addBindingWithCharacter := model_definition_addBindingWithCharacter
  scalarLookup := model_definition_scalarLookup
  scalarRead := model_definition_scalarRead
  arrayLookup := model_definition_arrayLookup
  booleanLookup := by intros; rfl
  booleanHidesInteger := by intros; rfl
  booleanDeclaration := by intros; rfl
  booleanInitializer := by intros; rfl
  arrayPut := model_definition_arrayPut
  arrayAdd := model_definition_arrayAdd
  arrayValuesModel := model_definition_arrayValuesModel
  arrayValues := model_definition_arrayValues
  booleanArrayValuesModel := by
    intro text _ source result position length parsed maskFirst maskAfter _ context
    rw [booleanArrayValues_denotation,
      model_booleanArrayValues_equation text source result position length parsed maskFirst maskAfter context.parsedBound]
    rfl
  booleanArrayValues := by intros; rfl
  arrayDeclaration := model_definition_arrayDeclaration
  scalarLiteral := model_definition_scalarLiteral
  scalarAppend := model_definition_scalarAppend
  scalarEmpty := model_definition_scalarEmpty
  imageMinimum := model_definition_imageMinimum
  imageMaximum := model_definition_imageMaximum
  image := model_definition_image
  nameIs := model_definition_nameIs
  callAfter := by
    intro text valid names position operation scalarNames arrays subtypeHidden booleans namesValid scalarValid arraysValid booleansValid positionValid
    exact model_definition_callAfter text valid names position operation scalarNames arrays subtypeHidden booleans
      namesValid.base scalarValid arraysValid booleansValid positionValid
  skip := model_definition_skip
  name := model_definition_name
  fixed := model_definition_fixed
  take := model_definition_take
  lookupFrom := model_definition_lookupFrom
  lookup := model_definition_lookup
  literal := model_definition_literal
  workTail := model_definition_workTail
  workBudget := model_definition_workBudget
  value := model_definition_value
  newName := model_definition_newName
  addBinding := model_definition_addBinding
  stringDeclaration := model_definition_stringDeclaration
  scalarConstraint := model_definition_scalarConstraint
  subtypeLookupModel := model_definition_subtypeLookupModel
  subtypeLookup := model_definition_subtypeLookup
  scalarType := by
    intro text valid state position stateValid positionValid
    exact model_definition_scalarType text valid state position stateValid.valid positionValid
  subtypeDeclaration := by
    intro text valid state arguments stateValid
    exact model_definition_subtypeDeclaration text valid state arguments stateValid.valid
  scalarDeclaration := by
    intro text valid state arguments stateValid
    exact model_definition_scalarDeclaration text valid state arguments stateValid.valid
  declaration := by
    intro text valid state arguments stateValid
    exact model_definition_declaration text valid state arguments stateValid.valid
  argument := model_definition_argument
  declarations := by
    intro text valid state arguments stateValid
    exact model_definition_declarations text valid state arguments stateValid.valid
  expressionStep := model_definition_expressionStep
  fits := model_definition_fits
  comparison := model_definition_comparison
  tail := model_definition_tail ranges
  expression := model_definition_expression
  target := model_definition_target
  dynamic := model_definition_dynamic
  assignmentValue := model_definition_assignmentValue
  output := model_definition_output
  capacity := model_definition_capacity
  readDeclarations := model_definition_readDeclarations

end Silver.Compose.Expressions
