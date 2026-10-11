import Silver.ComposeExpressions

/-! Close the new recognizer's checked expression equations by recursion
uniqueness on its verified machine domains. Shared lexical operations have
already established meanings; new recursive callees remain arbitrary here. -/

namespace Silver.Compose.Expressions
open Named

def modelPrimitives : Primitives where
  trivia := Cursor.triviaPosition
  literal := Output.literalEnd
  length := Guarded.literalLength
  identifier := identifierEnd
  forbidden := forbiddenName
  forbiddenArgument := Arguments.forbiddenName
  equal := equalName
  decimal := Guarded.decimalAt
  token := fixedAt
  normalize := id
  allowed := fun text => text.all allowedCharacter

def lexical (calls : Calls) : Calls := {calls with primitive := modelPrimitives}

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength

def ValidCursor (text : Source) (position : Nat) : Prop := 1 ≤ position ∧ position ≤ text.length + 1

def ValidNames (text : Source) (context : NameContext) : Prop :=
  (⟨context.staticFirst,context.staticAfter⟩ : NameState).Valid text ∧
  (⟨context.dynamicFirst,context.dynamicAfter⟩ : NameState).Valid text ∧
  context.staticLength ≤ maxSourceLength

def ValidState (text : Source) (state : ParserState) : Prop :=
  state.position ≤ text.length + 1 ∧ ValidNames text state.context ∧ state.capacity ≤ maxSourceLength

/-- Only tokens reached through the actual finite shell tables are interpreted.
Arbitrary strings in the mathematical token type are outside Ada's enum. -/
def ValidToken (token : ShellToken) : Prop := ∃ (form : Form), token ∈ form.tokens

theorem tokenAtIndex_valid (form : Form) (index : Nat)
    (first : 1 ≤ index) (last : index ≤ form.tokens.length) :
    ValidToken (tokenAtIndex form index) := by
  have present : index - 1 < form.tokens.length := by omega
  refine ⟨form, ?_⟩
  simp only [tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
  exact List.getElem_mem present

def suffixAtIndex (text : Source) (form : Form) (index : Nat) (state : ParserState) : Bool :=
  suffixMatches text form (form.tokens.drop (index - 1)) state

/-- These are equations of the rendered Ada bodies, never premises asserting
admission equivalence. The explicit evaluator can be the actual calls; the
default uses their lexical normalization. ComposeEvaluation derives that
normalization from retained helper meanings and checked caller preconditions. -/
structure DefinitionEquations (calls : Calls) (evaluator : Calls := lexical calls) : Prop where
  operand : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    calls.operand text position names = operandBody.eval evaluator {text,position,names}
  tail : ∀ text, ValidText text → ∀ names remaining position length dynamicSeen staticSeen,
    ValidCursor text position → ValidNames text names → remaining ≤ maxExpressionOperands → length ≤ maxSourceLength →
    calls.tail text names remaining position length dynamicSeen staticSeen =
      tailBody.eval evaluator {text,position,names,remaining,length,dynamicSeen,staticSeen}
  expression : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    calls.expression text position names = expressionBody.eval evaluator {text,position,names}
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state → 0 < state.position →
    calls.step text form token state = stepBody.eval evaluator {text,form,token,state}
  stepRange : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state → 0 < state.position →
    ValidState text (calls.step text form token state)
  suffix : ∀ text, ValidText text → ∀ form index state,
    ValidState text state → 1 ≤ index → index ≤ form.tokens.length + 1 →
    calls.suffix text form index state = suffixBody.eval evaluator {text,form,nextToken := index,state}
  formMember : ∀ text form, calls.formMember text form = formBody.eval evaluator {text,form}
  member : ∀ text, calls.member text = memberBody.eval evaluator {text}
  arguments : ∀ text, calls.arguments text = argumentsBody.eval evaluator {text}
  assignment : ∀ text, calls.assignment text = assignmentBody.eval evaluator {text}

private theorem quote_no_identifier (text : Source) (position : Nat)
    (quote : Cursor.byteAt text position = 34) : identifierEnd text position = 0 := by
  simp +instances [identifierEnd, quote, letter]

theorem operand_denotation (calls : Calls) (text : Source) (position : Nat) (names : NameContext) :
    operandBody.eval (lexical calls) {text,position,names} = operandCore text position names := by
  dsimp +instances only [operandBody, Result.eval, Condition.eval, Number.eval, lexical, modelPrimitives,
    both, quoteAt, plusOne]
  simp only [Bool.and_eq_true, decide_eq_true_eq]
  by_cases quote : position ≤ text.length ∧ Cursor.byteAt text position = 34
  · have noName := quote_no_identifier text position quote.2
    by_cases literal : Output.literalEnd text (position + 1) = 0 <;>
      simp +instances [operandCore, quote, literal, noName]
  · by_cases identifier : identifierEnd text position = 0
    · simp +instances [operandCore, quote, identifier]
    · by_cases static : 0 < names.staticFirst <;>
        by_cases hs : equalName text names.staticFirst names.staticAfter position (identifierEnd text position) = true <;>
        by_cases dynamic : 0 < names.dynamicFirst <;>
        by_cases hd : equalName text names.dynamicFirst names.dynamicAfter position (identifierEnd text position) = true <;>
        simp +instances [operandCore, quote, identifier, matchesStatic, matchesDynamic,
          static, dynamic, hs, hd]

theorem interpreted_operand (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : NameContext)
    (cursor : ValidCursor text position) (context : ValidNames text names) :
    calls.operand text position names = operandCore text position names := by
  rw [source.operand text valid position names cursor context, operand_denotation]

private theorem trivia_valid (text : Source) (position : Nat) (cursor : ValidCursor text position) :
    ValidCursor text (Cursor.triviaPosition text position) := by
  have bounded := Cursor.triviaPosition_bounds text position cursor.1 cursor.2
  have first := cursor.1
  constructor <;> omega

private theorem operand_result_bounds (text : Source) (position : Nat) (names : NameContext)
    (cursor : ValidCursor text position) (nonzero : (operandAt text position names).after ≠ 0) :
    position < (operandAt text position names).after ∧
      (operandAt text position names).after ≤ text.length + 1 := by
  obtain ⟨atom, parsed, _⟩ := operand_sound text position names nonzero
  exact operand_bounds parsed cursor.1 cursor.2

private theorem tail_denotation (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (names : NameContext)
    (remaining position length : Nat) (dynamicSeen staticSeen : Bool)
    (cursor : ValidCursor text position) (context : ValidNames text names) :
    tailBody.eval (lexical calls) {text,position,names,remaining,length,dynamicSeen,staticSeen} =
      if remaining = 0 then invalidExpression else
        let atom := operandAt text position names
        if atom.after = 0 ∨ fitsAccumulator atom length dynamicSeen = false then invalidExpression
        else if hasAmpersand text atom.after then
          calls.tail text names (remaining - 1) (Cursor.triviaPosition text atom.after + 1)
            (length + atom.staticLength) (dynamicSeen || atom.dynamicSeen) (staticSeen || atom.staticSeen)
        else accumulated atom length dynamicSeen staticSeen := by
  dsimp +instances only [tailBody, Result.eval, Condition.eval, Number.eval, lexical, modelPrimitives,
    either, both, plusOne]
  have operand := interpreted_operand calls source text valid
    (Cursor.triviaPosition text position) names (trivia_valid text position cursor) context
  simp +instances only [operand]
  dsimp +instances only [operandAt, fitsAccumulator, hasAmpersand, accumulated] at *
  cases dynamicSeen <;>
    by_cases dynamic : (operandCore text (Cursor.triviaPosition text position) names).dynamicSeen = true <;>
    by_cases size : (operandCore text (Cursor.triviaPosition text position) names).staticLength ≤ maxSourceLength - length <;>
    simp_all [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, Nat.not_le]
  all_goals simp [Nat.not_lt_of_ge size]

theorem interpreted_tail (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (names : NameContext)
    (remaining position length : Nat) (dynamicSeen staticSeen : Bool)
    (cursor : ValidCursor text position) (context : ValidNames text names)
    (fuel : remaining ≤ maxExpressionOperands) (size : length ≤ maxSourceLength) :
    calls.tail text names remaining position length dynamicSeen staticSeen =
      expressionTail text names remaining position length dynamicSeen staticSeen := by
  induction remaining generalizing position length dynamicSeen staticSeen with
  | zero =>
      rw [source.tail text valid names 0 position length dynamicSeen staticSeen cursor context fuel size,
        tail_denotation calls source text valid names 0 position length dynamicSeen staticSeen cursor context]
      rfl
  | succ remaining ih =>
      rw [source.tail text valid names (remaining + 1) position length dynamicSeen staticSeen cursor context fuel size,
        tail_denotation calls source text valid names (remaining + 1) position length dynamicSeen staticSeen cursor context]
      simp +instances only [Nat.succ_ne_zero, ↓reduceIte, Nat.add_sub_cancel, expressionTail]
      split
      · rfl
      · rename_i safe
        have nonzero : (operandAt text position names).after ≠ 0 := by simp_all
        have fits : fitsAccumulator (operandAt text position names) length dynamicSeen = true := by simp_all
        have bounds := operand_result_bounds text position names cursor nonzero
        split
        · rename_i ampersand
          have next : ValidCursor text (Cursor.triviaPosition text (operandAt text position names).after + 1) := by
            have start := trivia_valid text (operandAt text position names).after ⟨by omega,bounds.2⟩
            simp +instances only [hasAmpersand, decide_eq_true_eq] at ampersand
            constructor <;> omega
          have newSize : length + (operandAt text position names).staticLength ≤ maxSourceLength := by
            simp +instances only [fitsAccumulator, Bool.and_eq_true, decide_eq_true_eq] at fits
            omega
          exact ih _ _ _ _ next (by omega) newSize
        · rfl

theorem interpreted_expression (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : NameContext)
    (cursor : ValidCursor text position) (context : ValidNames text names) :
    calls.expression text position names = expressionAt text position names := by
  rw [source.expression text valid position names cursor context]
  exact interpreted_tail calls source text valid names maxExpressionOperands position 0 false false
    cursor context (Nat.le_refl _) (Nat.zero_le _)


theorem interpreted_step (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (form : Form) (token : ShellToken) (state : ParserState)
    (tokenValid : ValidToken token) (context : ValidState text state) (positive : 0 < state.position) :
    calls.step text form token state = step text form token state := by
  rw [source.step text valid form token state tokenValid context positive]
  have expression := interpreted_expression calls source text valid state.position state.context
    ⟨positive,context.1⟩ context.2.1
  dsimp +instances only [stepBody, State.eval, Condition.eval, Number.eval, Result.eval, lexical, modelPrimitives,
    both, either, quoteAt, plusOne]
  simp +instances only [expression]
  cases token with
  | literal role =>
      cases role <;>
        dsimp +instances only [step]
        <;> simp [Bool.and_eq_true, decide_eq_true_eq, and_assoc]
  | fixed spelling word =>
      dsimp +instances only [step, Expressions.spelling, isWord]
      rfl
  | _ => simp +instances [step, staticNameAllowed, outputAllowed, matchesStatic, matchesDynamic,
      Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq, and_assoc]

def suffixEquation (recurse : Nat → ParserState → Bool) (text : Source)
    (form : Form) (index : Nat) (state : ParserState) : Bool :=
  if state.position = 0 then false
  else if index > form.tokens.length then decide (Cursor.triviaPosition text state.position = text.length + 1)
  else recurse (index + 1) (step text form (tokenAtIndex form index) state)

theorem suffix_denotation (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (form : Form) (index : Nat) (state : ParserState)
    (context : ValidState text state) (first : 1 ≤ index) :
    suffixBody.eval (lexical calls) {text,form,nextToken := index,state} =
      suffixEquation (calls.suffix text form) text form index state := by
  dsimp +instances only [suffixBody, Condition.eval, Number.eval, State.eval, plusOne, lexical, modelPrimitives,
    suffixEquation]
  by_cases zero : state.position = 0
  · simp +instances [zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · simp [finished]
    · rw [interpreted_step calls source text valid form (tokenAtIndex form index) state
        (tokenAtIndex_valid form index first (by omega)) context (by omega)]
      simp

theorem suffixAtIndex_equation (text : Source) (form : Form) (index : Nat) (state : ParserState)
    (first : 1 ≤ index) :
    suffixAtIndex text form index state = suffixEquation (suffixAtIndex text form) text form index state := by
  unfold suffixAtIndex suffixEquation
  by_cases zero : state.position = 0
  · cases form.tokens.drop (index - 1) <;> simp +instances [suffixMatches, zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · have enough : form.tokens.length ≤ index - 1 := by omega
      simp +instances [finished, List.drop_eq_nil_of_le enough, suffixMatches, zero]
    · have present : index - 1 < form.tokens.length := by omega
      have drop := List.drop_eq_getElem_cons present
      have next : index - 1 + 1 = index := by omega
      simp +instances only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, suffixMatches, next,
        tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
      simp +instances [zero]

theorem interpreted_suffix (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (form : Form) (index : Nat) (state : ParserState)
    (context : ValidState text state) (first : 1 ≤ index) (last : index ≤ form.tokens.length + 1) :
    calls.suffix text form index state = suffixAtIndex text form index state := by
  rw [source.suffix text valid form index state context first last,
    suffix_denotation calls source text valid form index state context first,
    suffixAtIndex_equation text form index state first]
  unfold suffixEquation
  by_cases zero : state.position = 0
  · simp +instances [zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · simp +instances [finished]
    · simp +instances only [finished, ↓reduceIte]
      have tokenValid := tokenAtIndex_valid form index first (by omega)
      have next := source.stepRange text valid form (tokenAtIndex form index) state tokenValid context (by omega)
      rw [interpreted_step calls source text valid form (tokenAtIndex form index) state tokenValid context (by omega)] at next
      exact interpreted_suffix calls source text valid form (index + 1)
        (step text form (tokenAtIndex form index) state) next (by omega) (by omega)
termination_by form.tokens.length + 1 - index
decreasing_by omega

private theorem initial_valid (text : Source) : ValidState text initialState := by
  simp +instances [ValidState, ValidNames, initialState, NameState.Valid]

theorem interpreted_form (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (form : Form) : calls.formMember text form = formAccepts text form := by
  rw [source.formMember]
  dsimp +instances only [formBody, Condition.eval, Number.eval, lexical, modelPrimitives, both]
  by_cases valid : ValidText text
  · have suffix := interpreted_suffix calls source text valid form 1 initialState (initial_valid text)
      (by omega) (by omega)
    have positive : 1 ≤ text.length := valid.1
    simp +instances [formAccepts, suffix, suffixAtIndex, positive, valid.1, valid.2]
  · have invalid : ¬(1 ≤ text.length ∧ text.length ≤ maxSourceLength) := valid
    simp +instances [formAccepts, invalid, Nat.lt_iff_add_one_le]

theorem interpreted_member (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.member text = accepts text := by
  rw [source.member]
  dsimp +instances only [memberBody, Condition.eval, lexical]
  have pointwise : calls.formMember text = formAccepts text := funext (interpreted_form calls source text)
  rw [pointwise]
  simp +instances [accepts, selectedForm, List.isSome_find?, allForms]

theorem interpreted_arguments (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.arguments text = hasArguments text := by
  rw [source.arguments]
  dsimp +instances only [argumentsBody, Condition.eval, lexical]
  have pointwise : calls.formMember text = formAccepts text := funext (interpreted_form calls source text)
  rw [pointwise]
  simp +instances [hasArguments, allForms, Form.hasArguments]

theorem interpreted_assignment (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.assignment text = hasAssignment text := by
  rw [source.assignment]
  dsimp +instances only [assignmentBody, Condition.eval, lexical, either]
  simp +instances only [interpreted_form calls source]
  simp +instances [hasAssignment, allForms, Form.hasAssignment, Bool.or_assoc]

end Silver.Compose.Expressions
