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
  simp +instances [fixedBody, Expr.Legal, Expr.eval, Context.locals]
  intro nonzero
  exact ⟨⟨lexical_cursor valid bound nonzero, lexical_trivia valid bound nonzero,
    token_spelling token tokenValid⟩, fun _ => lexical_cursor valid bound nonzero⟩

theorem model_legal : LegalBodies modelCalls where
  skip := by
    intro text valid position bound
    simp +instances [skipBody, Expr.Legal, Expr.eval, Context.locals]
    exact lexical_cursor valid bound
  name := by
    intro text valid position bound
    simp +instances [nameBody, Expr.Legal, Expr.eval, Context.locals]
    exact lexical_cursor valid bound
  fixed := by
    exact fixed_legal
  take := by
    exact fixed_legal
  lookupFrom := by
    intro text valid names first after index namesValid nameValid positive _
    simp +instances [lookupFromBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals,
      Field.get]
    intro bound
    have member : ((names.get index).getD {}) ∈ names := by
      have nonzero : index ≠ 0 := by omega
      have below : index - 1 < names.length := by omega
      simp +instances [Bindings.BindingEnvironment.get, nonzero, List.getElem?_eq_getElem below]
    exact ⟨lexical_name valid (namesValid.2 _ member).1, lexical_name valid nameValid⟩
  lookup := by
    intros
    simp +instances [lookupBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals]
  literal := by
    intro text valid position _
    simp +instances [literalBody, Expr.Legal, Expr.eval, Context.locals]
    constructor
    · intro _ inside _
      exact ⟨valid.1, valid.2, Nat.succ_pos _, Nat.add_le_add_right inside 1⟩
    · intro _ inside _ _
      exact ⟨valid.1, valid.2, Nat.succ_pos _, Nat.add_le_add_right inside 1⟩
  value := by
    intros
    simp +instances [valueBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  newName := by
    intro text valid state first after arguments _ _ afterBound
    simp +instances [newNameBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals]
    constructor
    · intro nonzero ordered
      exact ⟨valid.1, valid.2, Nat.pos_of_ne_zero nonzero, ordered, afterBound⟩
    · intro nonzero ordered _ _
      exact ⟨valid.1, valid.2, Nat.pos_of_ne_zero nonzero, ordered, afterBound⟩
  addBinding := by
    intros
    simp +instances [addBindingBody, Expr.Legal]
  declaration := by
    intros
    simp +instances [declarationBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  argument := by
    intros
    simp +instances [argumentBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  declarations := by
    intros
    simp +instances [declarationsBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get]
  expressionStep := by
    intros
    simp +instances [expressionStepBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  tail := by
    intros
    simp +instances [tailBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  fits := by
    intros
    simp +instances [fitsBody, Expr.Legal, Expr.eval, Context.locals, Field.get]
  comparison := by
    intros
    simp +instances [comparisonBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  expression := by
    intros
    simp +instances [expressionBody, Expr.Legal, Function.isLexical]
  target := by
    intros
    simp +instances [targetBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  dynamic := by
    intro text valid state stateValid
    simp +instances [dynamicBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get,
      Calls.get, modelCalls, modelPrimitives]
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
  assignmentValue := by
    intros
    simp +instances [assignmentBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  output := by
    intros
    simp +instances [outputBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  capacity := by
    intro text valid state stateValid
    simp +instances [capacityBody, Expr.Legal, Expr.eval, Context.locals, Field.get]
    intro nonzero
    have domains := And.intro (lexical_cursor valid stateValid.1 (of_decide_eq_false nonzero))
      (lexical_trivia valid stateValid.1 (of_decide_eq_false nonzero))
    exact ⟨domains, fun _ => domains⟩
  step := by
    intros
    simp +instances [stepBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get]
  suffix := by
    intro text valid form nextToken state stateValid _ _
    simp +instances [suffixBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Field.get]
    intro nonzero _
    exact lexical_cursor valid stateValid.1 (of_decide_eq_false nonzero)
  workTail := by
    intros
    simp +instances [workTailBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals, Locals.set, Field.get]
  workBudget := by
    intros
    simp +instances [workBudgetBody, Expr.Legal, Function.isLexical]
  formMember := by
    intro text form
    simp +instances [formBody, Expr.Legal, Expr.eval, Function.isLexical, Context.locals]
    refine ⟨⟨?_, ?_⟩, ?_⟩
    · intro bound
      exact (of_decide_eq_true bound).2
    · intro bound _
      exact (of_decide_eq_true bound).2
    · intro bound _ _
      exact (of_decide_eq_true bound).2
  member := by
    intros
    simp +instances [memberBody, Expr.Legal]
  arguments := by
    intros
    simp +instances [argumentsBody, Expr.Legal]
  assignment := by
    intros
    simp +instances [assignmentSelectorBody, Expr.Legal]

end Silver.Compose.Expressions
