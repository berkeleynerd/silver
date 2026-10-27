module

public import Silver.ComposeModelCalls
public import Silver.ComposeEvaluation

@[expose] public section

/-! The concrete composed recognizer executes lexical calls only in the domains
already justified for those primitives. This supplies the legality component of
the model interpretation witness without changing its domains. -/

namespace Silver.Compose.Expressions

set_option maxRecDepth 20000
set_option maxHeartbeats 1000000
attribute [local irreducible] ScalarExpression.read scalarConstraintAt

private theorem lexical_cursor {text : Source} (valid : ValidText text)
    {position : Nat} (bound : ValidCursor text position) (nonzero : position ≠ 0) :
    LexicalCursor text position :=
  ⟨valid.1, valid.2, by omega, bound⟩

private theorem lexical_trivia {text : Source} (valid : ValidText text)
    {position : Nat} (bound : ValidCursor text position) (nonzero : position ≠ 0) :
    LexicalCursor text (modelCalls.primitive.trivia text position) := by
  have bounds := Cursor.triviaPosition_bounds text position (by omega) bound
  exact ⟨valid.1, valid.2, by dsimp +instances [modelCalls, modelPrimitives]; omega,
    bounds.2⟩

private theorem lexical_name {text : Source} (valid : ValidText text)
    {first after : Nat} (name : ValidName text first after) : LexicalName text first after :=
  ⟨valid.1, valid.2, name.1, name.2⟩

private theorem token_spelling (token : ShellToken) (valid : ValidToken token) :
    0 < (spelling token).toList.length ∧ (spelling token).toList.length ≤ 16 := by
  have checked : ∀ token ∈ allTokens,
      0 < (spelling token).toList.length ∧ (spelling token).toList.length ≤ 16 := by
    decide +kernel
  exact checked token valid

private theorem fixed_legal (text : Source) (valid : ValidText text)
    (position : Nat) (token : ShellToken) (bound : ValidCursor text position)
    (tokenValid : ValidToken token) :
    fixedBody.Legal modelCalls (Context.locals {text,position,token}) := by
  dsimp +instances only [fixedBody, Expr.Legal, Expr.eval, Context.locals] <;> simp +instances
  intro nonzero
  exact ⟨⟨lexical_cursor valid bound nonzero, lexical_trivia valid bound nonzero,
    token_spelling token tokenValid⟩, fun _ => lexical_cursor valid bound nonzero⟩

private theorem model_legal_callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ValidCursor text position →
    callAfterBody.Legal modelCalls (Context.locals {text,scalarNames,names,position,operation}) := by
  intros
  dsimp +instances only [callAfterBody, Expr.Legal, Function.isLexical] <;> simp +instances

private theorem model_legal_skip : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    skipBody.Legal modelCalls (Context.locals {text,position}) := by
  intro text valid position bound
  dsimp +instances only [skipBody, Expr.Legal, Expr.eval, Context.locals] <;> simp +instances
  exact lexical_cursor valid bound

private theorem model_legal_name : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    nameBody.Legal modelCalls (Context.locals {text,position}) := by
  intro text valid position bound
  dsimp +instances only [nameBody, Expr.Legal, Expr.eval, Context.locals] <;> simp +instances
  exact lexical_cursor valid bound

private theorem model_legal_fixed : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    fixedBody.Legal modelCalls (Context.locals {text,position,token}) := by
  exact fixed_legal

private theorem model_legal_take : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    fixedBody.Legal modelCalls (Context.locals {text,position,token}) := by
  exact fixed_legal

private theorem model_legal_lookupFrom : ∀ text, ValidText text → ∀ names first after index,
    ValidNames text names → ValidName text first after → 1 ≤ index → index ≤ names.length + 1 →
    lookupFromBody.Legal modelCalls (Context.locals {text,names,first,after,index}) := by
  intro text valid names first after index namesValid nameValid positive _
  dsimp +instances only [lookupFromBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get] <;> simp +instances
  intro bound
  have member : ((names.get index).getD {}) ∈ names := by
    have nonzero : index ≠ 0 := by omega
    have below : index - 1 < names.length := by omega
    simp +instances [Bindings.BindingEnvironment.get, nonzero, List.getElem?_eq_getElem below]
  exact ⟨lexical_name valid (namesValid.2 _ member).1, lexical_name valid nameValid⟩

private theorem model_legal_lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → ValidCursor text first → ValidCursor text after →
    lookupBody.Legal modelCalls (Context.locals {text,names,first,after}) := by
  intros
  dsimp +instances only [lookupBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals] <;> simp +instances

private theorem model_legal_literal : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    literalBody.Legal modelCalls (Context.locals {text,position}) := by
  intro text valid position _
  dsimp +instances only [literalBody, Expr.Legal, Expr.eval, Context.locals] <;> simp +instances
  constructor
  · intro _ inside _
    exact ⟨valid.1, valid.2, Nat.succ_pos _, Nat.add_le_add_right inside 1⟩
  · intro _ inside _ _
    exact ⟨valid.1, valid.2, Nat.succ_pos _, Nat.add_le_add_right inside 1⟩

private theorem model_legal_image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    imageBody.Legal modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [imageBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    valueBody.Legal modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [valueBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_newName : ∀ text, ValidText text → ∀ state first after arguments,
    ValidState text state → ValidCursor text first → ValidCursor text after →
    newNameBody.Legal modelCalls (Context.locals {text,state,first,after,arguments}) := by
  intro text valid state first after arguments _ _ afterBound
  dsimp +instances only [newNameBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals] <;> simp +instances
  constructor
  · intro nonzero ordered
    exact ⟨valid.1, valid.2, Nat.pos_of_ne_zero nonzero, ordered, afterBound⟩
  · intro nonzero ordered _ _
    exact ⟨valid.1, valid.2, Nat.pos_of_ne_zero nonzero, ordered, afterBound⟩

private theorem model_legal_addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    ValidState text state → ValidCursor text first → ValidCursor text after → ValidValue text value → ValidCursor text following → state.names.length < maxBindings →
    addBindingBody.Legal modelCalls (Context.locals {text,state,first,after,value,mutable,following}) := by
  intros
  dsimp +instances only [addBindingBody, Expr.Legal] <;> simp +instances

private theorem model_legal_stringDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    stringDeclarationBody.Legal modelCalls (Context.locals {text,state,arguments}) := by
  intros
  dsimp +instances only [stringDeclarationBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_scalarConstraint : ∀ text, ValidText text → ∀ position scalarNames,
    ValidCursor text position → ScalarExpression.ValidEnvironment text scalarNames →
    scalarConstraintBody.Legal modelCalls (Context.locals {text,position,scalarNames}) := by
  intros
  simp only [scalarConstraintBody, Expr.Legal, Function.isLexical, and_self, implies_true, ite_self]

private theorem model_legal_scalarDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    scalarDeclarationBody.Legal modelCalls (Context.locals {text,state,arguments}) := by
  intros
  simp only [scalarDeclarationBody, Expr.Legal, Function.isLexical, and_self, implies_true, ite_self]

private theorem model_legal_declaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    declarationBody.Legal modelCalls (Context.locals {text,state,arguments}) := by
  intros
  dsimp +instances only [declarationBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_argument : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    argumentBody.Legal modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [argumentBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_declarations : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    declarationsBody.Legal modelCalls (Context.locals {text,state,arguments}) := by
  intros
  dsimp +instances only [declarationsBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get] <;> simp +instances

private theorem model_legal_expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → ValidScan text scan →
    expressionStepBody.Legal modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan}) := by
  intros
  dsimp +instances only [expressionStepBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_tail : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → ValidScan text scan →
    tailBody.Legal modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan}) := by
  intros
  dsimp +instances only [tailBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_fits : ∀ text, ValidText text → ∀ result capacity,
    ValidResult text result → capacity ≤ maxSourceLength →
    fitsBody.Legal modelCalls (Context.locals {text,result,capacity}) := by
  intros
  dsimp +instances only [fitsBody, Expr.Legal, Expr.eval, Context.locals, Field.get] <;> simp +instances

private theorem model_legal_comparison : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    comparisonBody.Legal modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [comparisonBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    expressionBody.Legal modelCalls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names}) := by
  intros
  dsimp +instances only [expressionBody, Expr.Legal, Function.isLexical] <;> simp +instances

private theorem model_legal_target : ∀ text, ValidText text → ∀ state sameTarget,
    ValidState text state →
    targetBody.Legal modelCalls (Context.locals {text,state,sameTarget}) := by
  intros
  dsimp +instances only [targetBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_dynamic : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    dynamicBody.Legal modelCalls (Context.locals {text,state}) := by
  intro text valid state stateValid
  dsimp +instances only [dynamicBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get, Calls.get, modelCalls, modelPrimitives] <;> simp +instances
  intro firstNonzero afterNonzero dynamicNonzero
  have firstPositive : 0 < skipAt text state.position := Nat.pos_of_ne_zero firstNonzero
  have afterBounds := Named.identifierEnd_bounds text (skipAt text state.position)
    (by simpa [nameAfter, firstNonzero] using afterNonzero)
  have dynamicValid := stateValid.2.2.1
  rcases dynamicValid with absent | present
  · exact False.elim (dynamicNonzero absent.1)
  · exact ⟨lexical_name valid present,
      ⟨valid.1, valid.2, firstPositive,
        by simpa [nameAfter, firstNonzero] using afterBounds⟩⟩

private theorem model_legal_assignmentValue : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    assignmentBody.Legal modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [assignmentBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_output : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    outputBody.Legal modelCalls (Context.locals {text,state}) := by
  intros
  dsimp +instances only [outputBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_capacity : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    capacityBody.Legal modelCalls (Context.locals {text,state}) := by
  intro text valid state stateValid
  dsimp +instances only [capacityBody, Expr.Legal, Expr.eval, Context.locals, Field.get] <;> simp +instances
  intro nonzero
  have domains := And.intro (lexical_cursor valid stateValid.1 nonzero)
    (lexical_trivia valid stateValid.1 nonzero)
  exact ⟨domains, fun _ => domains⟩

private theorem model_legal_step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    stepBody.Legal modelCalls (Context.locals {text,form,token,state}) := by
  intros
  dsimp +instances only [stepBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get] <;> simp +instances

private theorem model_legal_suffix : ∀ text, ValidText text → ∀ form nextToken state,
    ValidState text state → 1 ≤ nextToken → nextToken ≤ form.tokens.length + 1 →
    suffixBody.Legal modelCalls (Context.locals {text,form,nextToken,state}) := by
  intro text valid form nextToken state stateValid _ _
  dsimp +instances only [suffixBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get] <;> simp +instances
  intro nonzero _
  exact lexical_cursor valid stateValid.1 nonzero

private theorem model_legal_workTail : ∀ text, ValidText text → ∀ position remaining,
    ValidCursor text position → remaining ≤ maxConcatenations →
    workTailBody.Legal modelCalls (Context.locals {text,position,remaining}) := by
  intros
  dsimp +instances only [workTailBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get] <;> simp +instances

private theorem model_legal_workBudget : ∀ text, ValidText text →
    workBudgetBody.Legal modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [workBudgetBody, Expr.Legal, Function.isLexical] <;> simp +instances

private theorem model_legal_formMember : ∀ text form, formBody.Legal modelCalls (Context.locals {text,form}) := by
  intro text form
  dsimp +instances only [formBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals] <;> simp +instances
  constructor <;> intro _ bounded <;> intros <;> exact bounded

private theorem model_legal_member : ∀ text, memberBody.Legal modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [memberBody, Expr.Legal] <;> simp +instances

private theorem model_legal_arguments : ∀ text, argumentsBody.Legal modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [argumentsBody, Expr.Legal] <;> simp +instances

private theorem model_legal_assignment : ∀ text, assignmentSelectorBody.Legal modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [assignmentSelectorBody, Expr.Legal] <;> simp +instances

theorem model_legal : LegalBodies modelCalls where
  callAfter := model_legal_callAfter
  skip := model_legal_skip
  name := model_legal_name
  fixed := model_legal_fixed
  take := model_legal_take
  lookupFrom := model_legal_lookupFrom
  lookup := model_legal_lookup
  literal := model_legal_literal
  image := model_legal_image
  value := model_legal_value
  newName := model_legal_newName
  addBinding := model_legal_addBinding
  stringDeclaration := model_legal_stringDeclaration
  scalarConstraint := model_legal_scalarConstraint
  scalarDeclaration := model_legal_scalarDeclaration
  declaration := model_legal_declaration
  argument := model_legal_argument
  declarations := model_legal_declarations
  expressionStep := model_legal_expressionStep
  tail := model_legal_tail
  fits := model_legal_fits
  comparison := model_legal_comparison
  expression := model_legal_expression
  target := model_legal_target
  dynamic := model_legal_dynamic
  assignmentValue := model_legal_assignmentValue
  output := model_legal_output
  capacity := model_legal_capacity
  step := model_legal_step
  suffix := model_legal_suffix
  workTail := model_legal_workTail
  workBudget := model_legal_workBudget
  formMember := model_legal_formMember
  member := model_legal_member
  arguments := model_legal_arguments
  assignment := model_legal_assignment

end Silver.Compose.Expressions
