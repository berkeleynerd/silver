module

public import Silver.ComposeModelCalls
public import Silver.ComposeScalarDenotations
public import Silver.ComposeNameBridge

@[expose] public section

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read

/-! Concrete equation witnesses for optional scalar constraints and named
Integer subtype helpers, independent of the recognizer's refinement proof. -/

theorem model_definition_scalarConstraint : ∀ text, ValidText text → ∀ position scalarNames baseBounds,
    ValidCursor text position → ScalarExpression.ValidEnvironment text scalarNames →
    baseBounds.Bounded →
    modelCalls.function .scalarConstraint text position scalarNames baseBounds =
      scalarConstraintBody.eval modelCalls (Context.locals {text,position,scalarNames,baseBounds}) := by
  intros
  rw [scalarConstraint_denotation]
  dsimp +zetaHave only [scalarConstraintEquation]
  dsimp +instances only [modelCalls, spelling, isWord, ShellToken.symbol, ShellToken.word, scalarConstraintAt]
  simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]

theorem model_definition_subtypeLookupModel : ∀ text, ValidText text → ∀ subtypeNames first after index,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    index ≤ subtypeNames.items.length →
    modelCalls.function .subtypeLookupModel text subtypeNames first after index =
      subtypeLookupModelBody.eval modelCalls (Context.locals {text,subtypeNames,first,after,index}) := by
  intro text _ subtypeNames first after index _ _ _ _
  dsimp +instances only [subtypeLookupModelBody, Expr.eval, modelCalls, Context.locals, Field.get, Calls.get, modelPrimitives]
  cases index with
  | zero => simp [IntegerSubtypes.lookupFrom]
  | succ index => simp [IntegerSubtypes.lookupFrom, Bool.or_eq_true]

theorem model_definition_subtypeLookup : ∀ text, ValidText text → ∀ subtypeNames first after,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    modelCalls.function .subtypeLookup text subtypeNames first after =
      modelCalls.function .subtypeLookupModel text subtypeNames first after subtypeNames.items.length := by
  intros; rfl

theorem model_definition_scalarType : ∀ text, ValidText text → ∀ state position,
    ValidState text state → ValidCursor text position →
    modelCalls.function .scalarType text state position =
      scalarTypeBody.eval modelCalls (Context.locals {text,state,position}) := by
  intros
  rw [scalarType_denotation]
  dsimp +instances only [scalarTypeEquation, modelCalls, scalarTypeAt]
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

theorem model_definition_subtypeDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state → modelCalls.function .subtypeDeclaration text state arguments =
      subtypeDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) := by
  intros
  rw [subtypeDeclaration_denotation]
  dsimp +instances only [subtypeDeclarationEquation, modelCalls, subtypeDeclarationAt, subtypeDeclarationParts,
    addSubtypeBinding, IntegerSubtypes.append, IntegerSubtypes.CallHiding.add,
    IntegerSubtypes.CallHiding.get, spelling, isWord, ShellToken.word, ShellToken.symbol]
  simp only [Bool.decide_coe, Bool.decide_or, Bool.or_assoc]

theorem model_definition_callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames arrays subtypeHidden booleans,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ArrayBindings.ValidMetadata text arrays → BooleanBindings.ValidEnvironment text booleans → ValidCursor text position →
    modelCalls.function .callAfter text names position operation scalarNames arrays subtypeHidden booleans =
      callAfterBody.eval modelCalls (Context.locals {text,scalarNames,arrays,names,position,operation,subtypeHidden,booleans}) := by
  intros
  dsimp +instances only [modelCalls, Names.modelCalls, Context.locals, Expr.eval, Calls.get, Locals.set, callAfterBody, callAfter] <;> simp +instances [Bool.or_assoc]


theorem model_definition_scalarDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state → modelCalls.function .scalarDeclaration text state arguments =
      scalarDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) := by
  intro text valid state arguments stateValid
  let parts := scalarDeclarationParts text state
  have body : scalarDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) =
      (if !newNameAllowed text state parts.first parts.after arguments ||
          decide (parts.typeAfter = 0) || decide (parts.constraint.after = 0) ||
          decide (parts.following ≤ state.position) ||
          decide (state.scalarNames.length = ScalarExpression.maxBindings) ||
          parts.value.bounds.isEmpty ||
          decide (parts.value.bounds.lower ≠ parts.value.bounds.upper) ||
          decide (parts.value.bounds.lower < parts.constraint.bounds.lower) ||
          decide (parts.constraint.bounds.upper < parts.value.bounds.upper) ||
          Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) ||
          decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0) ||
          decide (ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0) ||
          decide (ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0)
        then invalidState else addScalarBinding state parts) := by
    rw [scalarDeclaration_denotation]
    dsimp +zetaHave only [scalarDeclarationEquation]
    dsimp +instances only [modelCalls, spelling, isWord, ShellToken.symbol, ShellToken.word,
      parts, scalarDeclarationParts, scalarDeclarationTypeFirst,
      scalarDeclarationTypeAfter, scalarDeclarationValuePosition, declarationFirst, declarationAfter,
      declarationConstantAfter, declarationColonAfter, addScalarBinding]
    simp only [decide_eq_true_eq]
  change scalarDeclarationAt text state arguments = _
  rw [body]
  change (if !newNameAllowed text state parts.first parts.after arguments ||
      decide (parts.typeAfter = 0 ∨ parts.constraint.after = 0 ∨
        parts.following ≤ state.position ∨ state.scalarNames.length = ScalarExpression.maxBindings) ||
      parts.value.bounds.isEmpty ||
      decide (parts.value.bounds.lower ≠ parts.value.bounds.upper ∨
        parts.value.bounds.lower < parts.constraint.bounds.lower ∨
        parts.constraint.bounds.upper < parts.value.bounds.upper) ||
      decide (fixedAfter text parts.first "integer" true = parts.after) ||
      decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
        ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
        ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0)
    then invalidState else addScalarBinding state parts) = _
  by_cases allowed : newNameAllowed text state parts.first parts.after arguments = true
  · have own := declaration_nameIs_integer text state arguments parts.first parts.after rfl rfl allowed
    rw [own]
    dsimp +instances only [ScalarExpression.maxBindings, maxBindings, maxSourceLength]
    simp only [Bool.decide_or, Bool.or_assoc]
  · simp [allowed]


theorem model_definition_declaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    modelCalls.function .declaration text state arguments =
      declarationBody.eval modelCalls (Context.locals {text,state,arguments}) := by
  intros
  dsimp +instances only [modelCalls, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, declarationBody, declarationAt] <;> simp +instances


theorem model_definition_declarations : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    modelCalls.function .declarations text state arguments =
      declarationsBody.eval modelCalls (Context.locals {text,state,arguments}) := by
  intro text valid state arguments stateValid
  rw [show modelCalls.function .declarations text state arguments = declarationsAt text state arguments from rfl,
    declarationsAt_equation text state arguments (by
      have strings := stateValid.2.1.1
      have scalars := stateValid.2.2.2.2.2.1.1
      have arrays := stateValid.2.2.2.2.2.2.1.1.1
      have subtypes := stateValid.2.2.2.2.2.2.2.1.1
      have booleans := stateValid.booleans.1
      have functions := stateValid.functions.1
      have procedures := stateValid.procedures.1
      omega)]
  dsimp +instances only [declarationsBody, Expr.eval, Context.locals, modelCalls, Calls.get, Field.get, spelling, isWord]
  simp only [decide_eq_true_eq, ite_not]


end Silver.Compose.Expressions
