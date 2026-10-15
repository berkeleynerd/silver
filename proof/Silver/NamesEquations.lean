module

public import Silver.NamesExpressions

@[expose] public section

namespace Silver.Names
open Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength
abbrev ValidWord (word : String) : Prop := 0 < word.toList.length ∧ word.toList.length ≤ 16

/-- The unchanged lexical callees have their established meanings. The new
functions are interpreted by their checked typed body trees and the executable
Take/Read_Context refinement contracts. No context grammar or call-resolution
conclusion is assumed. -/
structure InterpretedSource (calls : Calls) : Prop where
  trivia : ∀ text, ValidText text → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    calls.trivia text position = Cursor.triviaPosition text position
  token : ∀ text, ValidText text → ∀ position word isWord,
    1 ≤ position → position ≤ text.length + 1 → ValidWord word →
    calls.token text position word isWord = fixedAt text position word isWord
  fixed : ∀ text, ValidText text → ∀ position word isWord,
    position ≤ text.length + 1 → ValidWord word →
    calls.fixedAfter text position word isWord =
      fixedBody.eval calls ({text, position, word, isWord} : Native.Context).locals
  take : ∀ text, ValidText text → ∀ position word isWord,
    position ≤ text.length + 1 → ValidWord word →
    calls.take text position word isWord = calls.fixedAfter text position word isWord
  step : ∀ text, ValidText text → ∀ state, state.context.after ≤ text.length + 1 →
    calls.contextStep text state = stepBody.eval calls ({text,state} : Native.Context).locals
  tail : ∀ text, ValidText text → ∀ state, state.context.after ≤ text.length + 1 →
    calls.contextTail text state = tailBody.eval calls ({text,state} : Native.Context).locals
  model : ∀ text, ValidText text → calls.contextModel text =
    modelBody.eval calls ({text} : Native.Context).locals
  read : ∀ text, ValidText text → calls.readContext text = calls.contextModel text
  context : ∀ text, ValidText text → ∀ arguments, calls.contextAfter text arguments =
    contextBody.eval calls ({text,arguments} : Native.Context).locals
  name : ∀ operation, calls.operationName operation =
    nameBody.eval calls ({operation} : Native.Context).locals
  operation : ∀ text, ValidText text → ∀ position operation hidden, position ≤ text.length + 1 →
    calls.operationAfter text position operation hidden =
      operationBody.eval calls ({text,position,operation,hidden} : Native.Context).locals
  association : ∀ text, ValidText text → ∀ position default, position ≤ text.length + 1 →
    calls.associationAfter text position default =
      associationBody.eval calls ({text,position,default} : Native.Context).locals

theorem interpreted_take (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position : Nat) (word : String) (isWord : Bool)
    (bound : position ≤ text.length + 1) (wordValid : ValidWord word) :
    calls.take text position word isWord = Names.take text position word isWord := by
  rw [source.take text valid position word isWord bound wordValid,
    source.fixed text valid position word isWord bound wordValid]
  simp +instances only [fixedBody, Expr.eval, Native.Context.locals, Calls.get]
  simp only [decide_eq_true_eq]
  by_cases zero : position = 0
  · simp [zero, Names.take]
  · have trivia := Cursor.triviaPosition_bounds text position (by omega) bound
    rw [source.trivia text valid position (by omega) bound,
      source.token text valid _ word isWord (by omega) trivia.2 wordValid]
    simp [Names.take, zero]

theorem interpreted_step (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (state : State)
    (bound : state.context.after ≤ text.length + 1) :
    calls.contextStep text state = contextStep text state := by
  rw [source.step text valid state bound]
  have w := interpreted_take calls source text valid state.context.after "with" true bound (by decide)
  have u := interpreted_take calls source text valid state.context.after "use" true bound (by decide)
  have i := interpreted_take calls source text valid state.context.after "silver_io" true bound (by decide)
  have a := interpreted_take calls source text valid state.context.after "silver_arguments" true bound (by decide)
  have s := interpreted_take calls source text valid state.context.after ";" false bound (by decide)
  have c := interpreted_take calls source text valid state.context.after "," false bound (by decide)
  simp +instances only [stepBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [w, u, i, a, s, c, decide_eq_true_eq, Bool.and_eq_true, Bool.or_eq_true]
  simp only [contextStep, bne_eq, Bool.beq_eq_decide_eq, decide_not]

theorem interpreted_tail (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (state : State)
    (bound : state.context.after ≤ text.length + 1) :
    calls.contextTail text state = contextTail text state := by
  rw [source.tail text valid state bound]
  simp +instances only [tailBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [decide_eq_true_eq]
  rw [interpreted_step calls source text valid state bound, contextTail]
  simp only [bound, ↓reduceDIte]
  by_cases zero : state.context.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases complete : state.complete = true
    · simp [complete]
    · simp only [complete]
      by_cases failed : (contextStep text state).context.after = 0
      · simp [failed]
      · simp only [failed, ↓reduceIte]
        exact interpreted_tail calls source text valid (contextStep text state)
          (contextStep_progress text state bound).1
termination_by (text.length + 1 - state.context.after, if state.complete then 0 else 1)
decreasing_by
  have progress := contextStep_progress text state bound
  rcases progress.2 with zero | ⟨monotone, finished | advancing⟩
  · contradiction
  · by_cases advances : state.context.after < (contextStep text state).context.after
    · apply Prod.Lex.left; omega
    · have same : (contextStep text state).context.after = state.context.after := by omega
      simp_all
      exact Prod.Lex.right _ (by decide)
  · apply Prod.Lex.left; omega

theorem interpreted_read (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) : calls.readContext text = readContext text := by
  rw [source.read text valid, source.model text valid]
  simp +instances only [modelBody, Expr.eval, Native.Context.locals, Calls.get]
  exact interpreted_tail calls source text valid initialState (by simp [initialState])

theorem interpreted_context (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (arguments : Bool) :
    calls.contextAfter text arguments = contextAfter text arguments := by
  rw [source.context text valid arguments]
  simp +instances only [contextBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  rw [interpreted_read calls source text valid]
  simp [contextAfter, Bool.and_eq_true]

theorem interpreted_name (calls : Calls) (source : InterpretedSource calls) (operation : Operation) :
    calls.operationName operation = operation.name := by
  rw [source.name operation]
  cases operation <;> rfl

theorem interpreted_operation (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position : Nat) (operation : Operation) (hidden : Bool)
    (bound : position ≤ text.length + 1) :
    calls.operationAfter text position operation hidden = operationAfter text position operation hidden := by
  rw [source.operation text valid position operation hidden bound]
  simp +instances only [operationBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  rw [interpreted_read calls source text valid, interpreted_name calls source operation]
  have packageValid : ValidWord (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") := by cases operation <;> decide
  have nameValid : ValidWord operation.name := by cases operation <;> decide
  rw [interpreted_take calls source text valid position _ true bound packageValid]
  have packageBound := take_bound text position _ true bound packageValid.1
  rw [interpreted_take calls source text valid _ "." false packageBound (by decide)]
  have dotBound := take_bound text _ "." false packageBound (by decide)
  rw [interpreted_take calls source text valid _ operation.name true dotBound nameValid,
    interpreted_take calls source text valid position operation.name true bound nameValid]
  simp [operationAfter, Bool.and_eq_true]

theorem interpreted_association (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position : Nat) (default : Bool)
    (bound : position ≤ text.length + 1) :
    calls.associationAfter text position default = associationAfter text position default := by
  rw [source.association text valid position default bound]
  simp +instances only [associationBody, Expr.eval, Native.Context.locals, Calls.get, Locals.set, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [decide_eq_true_eq]
  have wordValid : ValidWord (if default then "default" else "item") := by cases default <;> decide
  rw [interpreted_take calls source text valid position _ true bound wordValid]
  have firstBound := take_bound text position _ true bound wordValid.1
  rw [interpreted_take calls source text valid _ "=>" false firstBound (by decide)]
  rfl

def modelCalls : Calls where
  fixedAfter := Names.take
  take := Names.take
  token := fixedAt
  trivia := Cursor.triviaPosition
  contextStep := contextStep
  contextTail := contextTail
  contextModel := readContext
  readContext := readContext
  contextAfter := contextAfter
  operationName := Operation.name
  operationAfter := operationAfter
  associationAfter := associationAfter

theorem model_interpreted : InterpretedSource modelCalls where
  trivia _ _ _ _ _ := rfl
  token _ _ _ _ _ _ _ _ := rfl
  take _ _ _ _ _ _ _ := rfl
  fixed := by
    intro text _ position word isWord _ _
    simp +instances only [fixedBody, Expr.eval, Native.Context.locals, Calls.get, modelCalls]
    simp [Names.take]
  step := by
    intro text _ state _
    simp +instances only [stepBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp only [decide_eq_true_eq, Bool.and_eq_true, Bool.or_eq_true]
    simp only [contextStep, bne_eq, Bool.beq_eq_decide_eq, decide_not]
  tail := by
    intro text _ state bound
    simp +instances only [tailBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
    rw [contextTail]
    simp [bound]
  model _ _ := rfl
  read _ _ := rfl
  context := by
    intro text _ arguments
    simp +instances only [contextBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
    simp [contextAfter, Bool.and_eq_true]
  name operation := by cases operation <;> rfl
  operation := by
    intro text _ position operation hidden _
    simp +instances only [operationBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp [operationAfter, Bool.and_eq_true]
  association := by
    intro text _ position default _
    simp +instances only [associationBody, Expr.eval, Native.Context.locals, Calls.get, Locals.set, modelCalls, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp [associationAfter]

end Silver.Names
