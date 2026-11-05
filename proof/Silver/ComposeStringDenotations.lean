module

public import Silver.ComposeModelCalls
public import Silver.ComposeStringEquations

@[expose] public section

namespace Silver.Compose.Expressions
open StringNative
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read

theorem model_guarded_denotation (text : Source) (position limit depth : Nat) (chained ending : Bool)
    (positive : 0 < position) (bounded : position ≤ text.length + 1) (limitBound : limit ≤ text.length + 1) :
    guardedBody.eval modelCalls (Context.locals {text,position,limit,depth,chained,ending}) =
      guardedAt text position limit depth chained ending := by
  rw [guarded_denotation]
  simp only [guardedEquation, decide_eq_true_eq]
  dsimp +instances only [modelCalls]
  conv => rhs; rw [guardedAt]
  simp only [show ¬ (position = 0 ∨ position > text.length + 1 ∨ limit > text.length + 1) from by omega,
    ↓reduceIte]

/-- Interpret every assignment and early return in the complete native index reader. -/
theorem model_indexed_denotation (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) :
    indexedBody.eval modelCalls
      (Context.locals {text,position,names,scalarNames,arrays,initials,elaborating,characterElement := element}) =
      indexedAt text position names scalarNames arrays initials elaborating element := by
  have max_toNat (value : Int) : (max 0 value).toNat = value.toNat := by omega
  have max_capacity (value : Int) : (max 0 value > (maxSourceLength : Int)) ↔
      value.toNat > maxSourceLength := by omega
  rw [indexed_denotation]
  cases element <;>
    dsimp only [indexedEquation, indexedAt, indexedParts, modelCalls, spelling, isWord, ShellToken.symbol]
  all_goals simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, ↓reduceIte, or_assoc, Bool.false_eq_true,
    StringIndexing.sliceMinimum, StringIndexing.sliceMaximum, StringIndexing.sliceLength, max_toNat, max_capacity]

/-- The recursive call retains the same source table and native fixed initial values. -/
theorem model_character_denotation (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (bound : ValidCursor text position) :
    characterBody.eval modelCalls
      (Context.locals {text,position,names,scalarNames,arrays,initials,elaborating}) =
      characterAt text position names scalarNames arrays initials elaborating := by
  rw [character_denotation, characterAt]
  dsimp only [characterEquation, modelCalls, spelling, isWord, ShellToken.symbol]
  simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc]
  by_cases opened : fixedAfter text (skipAt text position) "(" false = 0
  · simp [opened]
  · have advance := model_fixed_advances text (skipAt text position) "(" false
      (model_skip_valid text position bound) (by decide) opened
    have skipped := skipAt_advances text position bound (by
      intro zero
      simp [zero, fixedAfter] at opened)
    have decrease : text.length + 1 - fixedAfter text (skipAt text position) "(" false <
        text.length + 1 - position := by
      have upper := model_fixed_valid text (skipAt text position) "(" false (model_skip_valid text position bound)
      unfold ValidCursor at upper
      omega
    simp [opened, decrease]

/-- Concatenation preserves Ada's exact null-array upper bound. -/
theorem model_concatenatedLast_denotation (left : ExpressionState) (right : ValueResult) :
    concatenatedLastBody.eval modelCalls (Context.locals {scan := left,value := right}) =
      concatenatedLast left right := by
  rw [concatenatedLast_denotation]
  dsimp only [concatenatedLastEquation, modelCalls, concatenatedLast]
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, or_assoc]

theorem model_characterDeclaration_denotation (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    characterDeclarationBody.eval modelCalls (Context.locals {text,state,arguments}) =
      characterDeclarationAt text state arguments := by
  rw [characterDeclaration_denotation]
  dsimp only [characterDeclarationEquation, modelCalls, spelling, isWord, ShellToken.word, ShellToken.symbol]
  simp only [decide_eq_true_eq]
  have guard := characterDeclaration_progress_guard text state arguments stateValid
  dsimp only [characterDeclarationParts, declarationFirst, declarationAfter,
    declarationColonAfter, declarationConstantAfter] at guard
  rw [guard]
  rfl

end Silver.Compose.Expressions
