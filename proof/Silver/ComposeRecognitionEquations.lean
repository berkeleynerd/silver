module

public import Silver.ComposeEquations

@[expose] public section

/-! Assemble the shared binding helpers into complete source recognition and
report routing. Recursive traversal uses the native state-preservation contracts.
No whole-recognizer equality occurs among the interpretation premises. -/

namespace Silver.Compose.Expressions
open Named

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
set_option backward.dsimp.instances true

theorem tokenAtIndex_valid (form : Form) (index : Nat)
    (first : 1 ≤ index) (last : index ≤ form.tokens.length) :
    ValidToken (tokenAtIndex form index) := by
  have present : index - 1 < form.tokens.length := by omega
  have all : ∀ form ∈ allForms, ∀ token ∈ form.tokens, token ∈ allTokens := by decide +kernel
  have member : form ∈ allForms := by cases form <;> decide
  apply all form member
  simp only [tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
  exact List.getElem_mem present

theorem interpreted_step (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (form : Form) (token : ShellToken)
    (state : ParserState) (tokenValid : ValidToken token) (context : ValidState text state) :
    calls.function .step text form token state = step text form token state := by
  rw [source.step text valid form token state tokenValid context]
  have contextAfter := Names.interpreted_context calls.names source.toHelperEquations.names text valid form.hasArguments
  have argument := interpreted_argument calls source.toHelperEquations text valid state context
  have declarations := interpreted_declarations calls source.toHelperEquations text valid state form.hasArguments context
  have read := (source.readDeclarations text valid state form.hasArguments context).trans declarations
  have target := interpreted_target calls source.toHelperEquations text valid state false context
  have targetSame := interpreted_target calls source.toHelperEquations text valid state true context
  have dynamic := interpreted_dynamic calls source.toHelperEquations text valid state context
  have assignment := interpreted_assignmentValue calls source.toHelperEquations text valid state context
  have output := interpreted_output calls source.toHelperEquations text valid state context
  have comparison := interpreted_comparison calls source.toHelperEquations text valid state context
  have capacity := interpreted_capacity calls source.toHelperEquations text valid state context
  have skipped := interpreted_skip calls source.toHelperEquations.toRawHelperEquations text valid state.position context.1
  have skipDomain := source.ranges.skip text valid state.position context.1
  rw [skipped] at skipDomain
  have literal := interpreted_literal calls source.toHelperEquations.toRawHelperEquations text valid (skipAt text state.position) skipDomain
  have taken := interpreted_take calls source.toHelperEquations.toRawHelperEquations text valid state.position token context.1 tokenValid
  dsimp +instances only [stepBody, Expr.eval, Calls.get, Field.get, Context.locals, lexical, modelPrimitives]
  rw [skipped, literal, argument, read, target, targetSame, dynamic, assignment, output, comparison, capacity, taken, contextAfter]
  cases token <;> simp +instances [step, spelling, isWord, BEq.beq]

def suffixEquation (recurse : Nat → ParserState → Bool) (text : Source)
    (form : Form) (index : Nat) (state : ParserState) : Bool :=
  if state.position = 0 then false
  else if index > form.tokens.length then decide (Cursor.triviaPosition text state.position = text.length + 1)
  else recurse (index + 1) (step text form (tokenAtIndex form index) state)

theorem suffix_denotation (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (form : Form) (index : Nat) (state : ParserState)
    (context : ValidState text state) (first : 1 ≤ index) :
    suffixBody.eval (lexical calls) (Context.locals {text,form,nextToken := index,state}) =
      suffixEquation (calls.function .suffix text form) text form index state := by
  dsimp +instances only [suffixBody, Expr.eval, Calls.get, Context.locals, Field.get, lexical, modelPrimitives,
    suffixEquation]
  by_cases zero : state.position = 0
  · simp +instances [zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · simp [finished]
    · have meaning := interpreted_step calls source text valid form (tokenAtIndex form index) state
        (tokenAtIndex_valid form index first (by omega)) context
      simp only [tokenAtIndex] at meaning
      simpa +instances [zero, finished, tokenAtIndex] using
        congrArg (calls.function .suffix text form (index + 1)) meaning

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
    calls.function .suffix text form index state = suffixAtIndex text form index state := by
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
      have next := source.stepRange text valid form (tokenAtIndex form index) state tokenValid context
      rw [interpreted_step calls source text valid form (tokenAtIndex form index) state tokenValid context] at next
      exact interpreted_suffix calls source text valid form (index + 1)
        (step text form (tokenAtIndex form index) state) next (by omega) (by omega)
termination_by form.tokens.length + 1 - index
decreasing_by omega

private theorem initial_valid (text : Source) : ValidState text initialState := by
  simp +instances [ValidState, ValidCursor, ValidNames, initialState, NameState.Valid, maxBindings, maxSourceLength, ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings,
    ArrayBindings.ValidEnvironment, ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials,
    ArrayBindings.maxBindings, ArrayBindings.maxElements, IntegerSubtypes.valid_empty, BooleanBindings.valid_empty]

theorem interpreted_form (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) (form : Form) : calls.function .formMember text form = formAccepts text form := by
  rw [source.formMember]
  dsimp +instances only [formBody, Expr.eval, Calls.get, Context.locals, lexical, modelPrimitives]
  by_cases valid : ValidText text
  · have suffix := interpreted_suffix calls source text valid form 1 initialState (initial_valid text)
      (by omega) (by omega)
    have budget := interpreted_workBudget calls source.toHelperEquations.toRawHelperEquations text valid
    have positive : 1 ≤ text.length := valid.1
    simp +instances [formAccepts, budget, suffix, suffixAtIndex, positive, valid.1, valid.2]
  · have invalid : ¬(1 ≤ text.length ∧ text.length ≤ maxSourceLength) := valid
    simp +instances [formAccepts, invalid, Nat.lt_iff_add_one_le]

theorem interpreted_member (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.function .member text = accepts text := by
  rw [source.member]
  dsimp +instances only [memberBody, Expr.eval, Context.locals, lexical]
  have pointwise : calls.function .formMember text = formAccepts text := funext (interpreted_form calls source text)
  rw [pointwise]
  simp +instances [accepts, selectedForm, List.isSome_find?, allForms]

def firstFlagList {α : Type} [BEq α] (xs : List α) (p flag : α → Bool) : Bool :=
  xs.any fun x => p x && flag x && (xs.takeWhile (fun y => y != x)).all (fun y => !p y)

theorem firstFlag_find {α : Type} [DecidableEq α] (xs : List α) (p flag : α → Bool)
    (unique : xs.Nodup) : firstFlagList xs p flag = ((xs.find? p).map flag).getD false := by
  induction xs with
  | nil => simp [firstFlagList]
  | cons head tail ih =>
      have notMem : head ∉ tail := (List.nodup_cons.mp unique).1
      have tailUnique := (List.nodup_cons.mp unique).2
      have rest : (tail.any fun x => p x && flag x &&
          ((head :: tail).takeWhile (fun y => y != x)).all (fun y => !p y)) =
          (!p head && firstFlagList tail p flag) := by
        apply Bool.eq_iff_iff.mpr
        simp only [List.any_eq_true, Bool.and_eq_true, firstFlagList, and_assoc]
        constructor
        · rintro ⟨x, member, selected, yes, before⟩
          have different : head ≠ x := by intro eq; subst x; exact notMem member
          simp [different, List.all_cons] at before
          refine ⟨by simpa using before.1, x, member, selected, yes, ?_⟩
          simpa using before.2
        · rintro ⟨no, x, member, selected, yes, before⟩
          have different : head ≠ x := by intro eq; subst x; exact notMem member
          refine ⟨x, member, selected, yes, ?_⟩
          simp [different, List.all_cons, no, before]
      change (p head && flag head && ((head :: tail).takeWhile (fun y => y != head)).all (fun y => !p y) || _) = _
      rw [rest, ih tailUnique]
      cases selected : p head <;> simp [selected]

theorem interpreted_arguments (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.function .arguments text = hasArguments text := by
  rw [source.arguments]
  dsimp +instances only [argumentsBody, Expr.eval, Context.locals, lexical]
  simp only [firstFlag, ite_true]
  have pointwise : calls.function .formMember text = formAccepts text := funext (interpreted_form calls source text)
  rw [pointwise]
  change firstFlagList allForms _ _ = _
  exact firstFlag_find allForms (formAccepts text) Form.hasArguments (by decide)

theorem interpreted_assignment (calls : Calls) (source : DefinitionEquations calls)
    (text : Source) : calls.function .assignment text = hasAssignment text := by
  rw [source.assignment]
  dsimp +instances only [assignmentSelectorBody, Expr.eval, Context.locals, lexical]
  simp only [firstFlag, Bool.false_eq_true, ite_false]
  have pointwise : calls.function .formMember text = formAccepts text := funext (interpreted_form calls source text)
  rw [pointwise]
  change firstFlagList allForms _ _ = _
  exact firstFlag_find allForms (formAccepts text) Form.hasAssignment (by decide)

end Silver.Compose.Expressions
