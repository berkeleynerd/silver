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
  identifier : Named.IdentifierEquations calls.identifier
  trivia : ∀ text, ValidText text → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    calls.trivia text position = Cursor.triviaPosition text position
  skipTrivia : ∀ text, ValidText text → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    calls.skipTrivia text position = calls.trivia text position
  identifierMatch : ∀ text, ValidText text → ∀ position,
    1 ≤ position → position ≤ text.length + 1 →
    let result := calls.matchIdentifier text position
    (1 ≤ result.1 ∧ result.1 ≤ text.length + 1) ∧
      result.2 = decide (calls.identifier.finish text position ≠ 0) ∧
      (result.2 = true → result.1 = calls.identifier.finish text position)
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
  packageName : ∀ text, ValidText text → ∀ position packageFirst packageAfter,
    position ≤ text.length + 1 → ValidNameState text packageFirst packageAfter →
    calls.packageNameAfter text position packageFirst packageAfter =
      packageBody.eval calls ({text, position, packageFirst, packageAfter} : Native.Context).locals
  step : ∀ text, ValidText text → ∀ state packageFirst packageAfter,
    state.context.after ≤ text.length + 1 → ValidNameState text packageFirst packageAfter →
    calls.contextStep text state packageFirst packageAfter =
      stepBody.eval calls ({text, state, packageFirst, packageAfter} : Native.Context).locals
  tail : ∀ text, ValidText text → ∀ state packageFirst packageAfter,
    state.context.after ≤ text.length + 1 → ValidNameState text packageFirst packageAfter →
    calls.contextTail text state packageFirst packageAfter =
      tailBody.eval calls ({text, state, packageFirst, packageAfter} : Native.Context).locals
  model : ∀ text, ValidText text → ∀ contextFirst packageFirst packageAfter,
    ValidContext text contextFirst packageFirst packageAfter →
    calls.contextModel text contextFirst packageFirst packageAfter =
      modelBody.eval calls ({text, contextFirst, packageFirst, packageAfter} : Native.Context).locals
  read : ∀ text, ValidText text → ∀ contextFirst packageFirst packageAfter,
    ValidContext text contextFirst packageFirst packageAfter →
    calls.readContext text contextFirst packageFirst packageAfter =
      calls.contextModel text contextFirst packageFirst packageAfter
  context : ∀ text, ValidText text → ∀ arguments, calls.contextAfter text arguments =
    contextBody.eval calls ({text,arguments} : Native.Context).locals
  name : ∀ operation, calls.operationName operation =
    nameBody.eval calls ({operation} : Native.Context).locals
  operation : ∀ text, ValidText text → ∀ position operation hidden contextFirst packageFirst packageAfter,
    position ≤ text.length + 1 → ValidContext text contextFirst packageFirst packageAfter →
    calls.operationAfter text position operation hidden contextFirst packageFirst packageAfter =
      operationBody.eval calls ({text, position, operation, hidden, contextFirst, packageFirst, packageAfter} : Native.Context).locals
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

theorem interpreted_package (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1) (nameValid : ValidNameState text packageFirst packageAfter) :
    calls.packageNameAfter text position packageFirst packageAfter =
      packageNameAfter text position packageFirst packageAfter := by
  rw [source.packageName text valid position packageFirst packageAfter bound nameValid]
  simp +instances only [packageBody, Statement.eval, Expr.eval, Native.Context.locals,
    Calls.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  by_cases absent : position = 0 ∨ packageFirst = 0
  · simp [packageNameAfter, absent]
  · have positive : 1 ≤ position := by omega
    have firstBounds := Cursor.triviaPosition_bounds text position positive bound
    rw [source.skipTrivia text valid position positive bound,
      source.trivia text valid position positive bound]
    have matchFacts := source.identifierMatch text valid (Cursor.triviaPosition text position)
      (by omega) firstBounds.2
    have finish := Named.identifier_implementation calls.identifier source.identifier
      text valid.1 valid.2 (Cursor.triviaPosition text position) (by omega) firstBounds.2
    rw [finish] at matchFacts
    by_cases failed : Named.identifierEnd text (Cursor.triviaPosition text position) = 0
    · have notMatched : (calls.matchIdentifier text (Cursor.triviaPosition text position)).2 = false := by
        simpa [failed] using matchFacts.2.1
      simp [packageNameAfter, absent, failed, notMatched]
    · have matched : (calls.matchIdentifier text (Cursor.triviaPosition text position)).2 = true := by
        simpa [failed] using matchFacts.2.1
      have after := matchFacts.2.2 matched
      have identifierBounds := Named.identifierEnd_bounds text (Cursor.triviaPosition text position) failed
      have selected : 0 < packageFirst ∧ packageFirst < packageAfter ∧ packageAfter ≤ text.length + 1 := by
        rcases nameValid with empty | selected
        · omega
        · exact selected
      rw [matched, after]
      rw [source.identifier.equal text valid.1 valid.2
        (Cursor.triviaPosition text position) (Named.identifierEnd text (Cursor.triviaPosition text position))
        packageFirst packageAfter (by omega) identifierBounds.1 identifierBounds.2
        selected.1 selected.2.1 selected.2.2]
      simp [packageNameAfter, absent, failed]

theorem interpreted_step (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (state : State) (packageFirst packageAfter : Nat)
    (bound : state.context.after ≤ text.length + 1)
    (nameValid : ValidNameState text packageFirst packageAfter) :
    calls.contextStep text state packageFirst packageAfter = contextStep text state packageFirst packageAfter := by
  rw [source.step text valid state packageFirst packageAfter bound nameValid]
  have w := interpreted_take calls source text valid state.context.after "with" true bound (by decide)
  have u := interpreted_take calls source text valid state.context.after "use" true bound (by decide)
  have i := interpreted_take calls source text valid state.context.after "silver_io" true bound (by decide)
  have a := interpreted_take calls source text valid state.context.after "silver_arguments" true bound (by decide)
  have s := interpreted_take calls source text valid state.context.after ";" false bound (by decide)
  have c := interpreted_take calls source text valid state.context.after "," false bound (by decide)
  have p := interpreted_package calls source text valid state.context.after packageFirst packageAfter bound nameValid
  simp +instances only [stepBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [w, u, i, a, s, c, p, decide_eq_true_eq, Bool.and_eq_true, Bool.or_eq_true]
  simp only [contextStep, bne_eq, Bool.beq_eq_decide_eq, decide_not, and_assoc]

theorem interpreted_tail (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (state : State) (packageFirst packageAfter : Nat)
    (bound : state.context.after ≤ text.length + 1)
    (nameValid : ValidNameState text packageFirst packageAfter) :
    calls.contextTail text state packageFirst packageAfter = contextTail text state packageFirst packageAfter := by
  rw [source.tail text valid state packageFirst packageAfter bound nameValid]
  simp +instances only [tailBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [decide_eq_true_eq]
  rw [interpreted_step calls source text valid state packageFirst packageAfter bound nameValid, contextTail]
  simp only [bound, ↓reduceDIte]
  by_cases zero : state.context.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases complete : state.complete = true
    · simp [complete]
    · simp only [complete]
      by_cases failed : (contextStep text state packageFirst packageAfter).context.after = 0
      · simp [failed]
      · simp only [failed, ↓reduceIte]
        exact interpreted_tail calls source text valid (contextStep text state packageFirst packageAfter)
          packageFirst packageAfter (contextStep_progress text state packageFirst packageAfter bound).1 nameValid
termination_by (text.length + 1 - state.context.after, if state.complete then 0 else 1)
decreasing_by
  have progress := contextStep_progress text state packageFirst packageAfter bound
  rcases progress.2 with zero | ⟨monotone, finished | advancing⟩
  · contradiction
  · by_cases advances : state.context.after < (contextStep text state packageFirst packageAfter).context.after
    · apply Prod.Lex.left; omega
    · have same : (contextStep text state packageFirst packageAfter).context.after = state.context.after := by omega
      simp_all
      exact Prod.Lex.right _ (by decide)
  · apply Prod.Lex.left; omega

theorem interpreted_read (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (contextFirst packageFirst packageAfter : Nat)
    (contextValid : ValidContext text contextFirst packageFirst packageAfter) :
    calls.readContext text contextFirst packageFirst packageAfter =
      readContext text contextFirst packageFirst packageAfter := by
  rw [source.read text valid contextFirst packageFirst packageAfter contextValid,
    source.model text valid contextFirst packageFirst packageAfter contextValid]
  simp +instances only [modelBody, Expr.eval, Native.Context.locals, Calls.get]
  exact interpreted_tail calls source text valid _ packageFirst packageAfter
    contextValid.2.1 contextValid.2.2

theorem interpreted_context (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (arguments : Bool) :
    calls.contextAfter text arguments = contextAfter text arguments := by
  rw [source.context text valid arguments]
  simp +instances only [contextBody, Expr.eval, Native.Context.locals, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  rw [interpreted_read calls source text valid 1 0 0 (validContext_default text)]
  simp [contextAfter, Bool.and_eq_true]

theorem interpreted_name (calls : Calls) (source : InterpretedSource calls) (operation : Operation) :
    calls.operationName operation = operation.name := by
  rw [source.name operation]
  cases operation <;> rfl

theorem interpreted_operation (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position : Nat) (operation : Operation) (hidden : Bool)
    (contextFirst packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1)
    (contextValid : ValidContext text contextFirst packageFirst packageAfter) :
    calls.operationAfter text position operation hidden contextFirst packageFirst packageAfter = operationAfter text position operation hidden contextFirst packageFirst packageAfter := by
  rw [source.operation text valid position operation hidden contextFirst packageFirst packageAfter bound contextValid]
  simp +instances only [operationBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  rw [interpreted_read calls source text valid contextFirst packageFirst packageAfter contextValid, interpreted_name calls source operation]
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

def modelMatchIdentifier (text : Source) (position : Nat) : Nat × Bool :=
  let after := Named.identifierEnd text position
  (if after = 0 then position else after, decide (after ≠ 0))

def modelCalls : Calls where
  identifier := Named.modelIdentifierCalls
  skipTrivia := Cursor.triviaPosition
  matchIdentifier := modelMatchIdentifier
  packageNameAfter := packageNameAfter
  fixedAfter := Names.take
  take := Names.take
  token := fixedAt
  trivia := Cursor.triviaPosition
  contextStep := contextStep
  contextTail := contextTail
  contextModel := fun text contextFirst packageFirst packageAfter =>
    readContext text contextFirst packageFirst packageAfter
  readContext := fun text contextFirst packageFirst packageAfter =>
    readContext text contextFirst packageFirst packageAfter
  contextAfter := contextAfter
  operationName := Operation.name
  operationAfter := fun text position operation hidden contextFirst packageFirst packageAfter =>
    operationAfter text position operation hidden contextFirst packageFirst packageAfter
  associationAfter := associationAfter

theorem model_interpreted : InterpretedSource modelCalls where
  identifier := Named.model_identifier_equations
  trivia _ _ _ _ _ := rfl
  skipTrivia _ _ _ _ _ := rfl
  identifierMatch := by
    intro text _ position positive bound
    change (1 ≤ (modelMatchIdentifier text position).1 ∧
      (modelMatchIdentifier text position).1 ≤ text.length + 1) ∧
      (modelMatchIdentifier text position).2 = decide (Named.identifierEnd text position ≠ 0) ∧
      ((modelMatchIdentifier text position).2 = true →
        (modelMatchIdentifier text position).1 = Named.identifierEnd text position)
    by_cases failed : Named.identifierEnd text position = 0
    · simp [modelMatchIdentifier, failed, positive, bound]
    · have bounds := Named.identifierEnd_bounds text position failed
      simp [modelMatchIdentifier, failed]
      omega
  token _ _ _ _ _ _ _ _ := rfl
  take _ _ _ _ _ _ _ := rfl
  fixed := by
    intro text _ position word isWord _ _
    simp +instances only [fixedBody, Expr.eval, Native.Context.locals, Calls.get, modelCalls]
    simp [Names.take]
  packageName := by
    intro text _ position packageFirst packageAfter _ _
    simp +instances only [packageBody, Statement.eval, Expr.eval, Native.Context.locals,
      Calls.get, Locals.set, modelCalls, Named.modelIdentifierCalls,
      reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    by_cases absent : position = 0 ∨ packageFirst = 0
    · simp [packageNameAfter, absent]
    · by_cases failed : Named.identifierEnd text (Cursor.triviaPosition text position) = 0 <;>
        simp [packageNameAfter, modelMatchIdentifier, absent, failed]
  step := by
    intro text _ state packageFirst packageAfter _ _
    simp +instances only [stepBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp only [decide_eq_true_eq, Bool.and_eq_true, Bool.or_eq_true]
    simp only [contextStep, bne_eq, Bool.beq_eq_decide_eq, decide_not, and_assoc]
  tail := by
    intro text _ state packageFirst packageAfter bound _
    simp +instances only [tailBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
    rw [contextTail]
    simp [bound]
  model _ _ _ _ _ _ := rfl
  read _ _ _ _ _ _ := rfl
  context := by
    intro text _ arguments
    simp +instances only [contextBody, Expr.eval, Native.Context.locals, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
    simp [contextAfter, Bool.and_eq_true]
  name operation := by cases operation <;> rfl
  operation := by
    intro text _ position operation hidden contextFirst packageFirst packageAfter _ _
    simp +instances only [operationBody, Expr.eval, Native.Context.locals, Calls.get, Field.get, Locals.set, modelCalls, reduceCtorEq, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp [operationAfter, Bool.and_eq_true]
  association := by
    intro text _ position default _
    simp +instances only [associationBody, Expr.eval, Native.Context.locals, Calls.get, Locals.set, modelCalls, ↓reduceDIte, ↓reduceIte, String.reduceEq]
    simp [associationAfter]

end Silver.Names
