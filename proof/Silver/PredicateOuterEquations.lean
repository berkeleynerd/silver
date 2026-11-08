module

public import Silver.PredicateOuterExpressions
public import Silver.ComposeEquations
public import Silver.ComposeLexical
public import Silver.PredicateOuterReadiness

@[expose] public section
namespace Silver.Predicate.Outer
open Compose
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

abbrev ValidScan (text : Source) (scan : ScanResult) : Prop :=
  OuterReadiness.ValidState text scan.state
abbrev ValidText := Compose.Expressions.ValidText
abbrev ValidHelperToken := Compose.Expressions.ValidToken

def ValidToken : Token → Prop
  | .helper token => ValidHelperToken token
  | .statements => True

structure RangeContracts (calls : Calls) : Prop where
  step : ∀ text, ValidText text → ∀ form token scan, ValidToken token → ValidScan text scan →
    ValidScan text (calls.scanStep text form token scan)
structure HelperMeaning (calls : Calls) : Prop where
  equations : Compose.Expressions.HelperEquations calls.helpers (domain := OuterReadiness.domain)
  step : ∀ text, ValidText text → ∀ (form : Form) token state,
    ValidHelperToken token → OuterReadiness.ValidState text state →
    calls.helpers.function .step text form.helper token state = Compose.step text form.helper token state
  trivia : ∀ text, ValidText text → ∀ position, 0 < position → position ≤ text.length + 1 →
    calls.helpers.primitive.trivia text position = Cursor.triviaPosition text position


/-- Supplied by the separately rendered body adapter and recursive-body uniqueness. -/
structure BodyMeaning (calls : Calls) : Prop where
  statements : ∀ text, ValidText text → ∀ scan, ValidScan text scan →
    calls.readStatements text scan (.word "end") = Predicate.readStatements text scan

structure DefinitionEquations (calls : Calls) : Prop where
  ranges : RangeContracts calls
  step : ∀ text, ValidText text → ∀ form token scan, ValidToken token → ValidScan text scan →
    calls.scanStep text form token scan = scanStepBody.eval calls {text,scan,form,token}
  suffix : ∀ text, ValidText text → ∀ form index scan, ValidScan text scan →
    1 ≤ index → index ≤ form.tokens.length + 1 →
    calls.suffix text form index scan = suffixBody.eval calls {text,scan,form,nextToken := index}
  formResult : ∀ text form, calls.formResult text form = formBody.eval calls {text,form}
  member : ∀ text, calls.member text = memberBody.eval calls text
  arguments : ∀ text, calls.arguments text = argumentsBody.eval calls text
  assignment : ∀ text, calls.assignment text = assignmentBody.eval calls text
  output : ∀ text, calls.output text = outputBody.eval calls text
theorem interpreted_scanStep (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (form : Form) (token : Token) (scan : ScanResult) (tokenValid : ValidToken token)
    (context : ValidScan text scan) :
    calls.scanStep text form token scan = Predicate.scanStep text form token scan := by
  rw [equations.step text valid form token scan tokenValid context]
  cases token with
  | helper token =>
      dsimp +instances only [scanStepBody, Expr.eval, Condition.eval, HelperRef.eval]
      change (let next := calls.helpers.function .step text form.helper token scan.state
              {scan with state := next, assigned := scan.assigned || next.assignedInFunctions}) = _
      rw [helpers.step text valid form token scan.state tokenValid context]
      rfl
  | statements =>
      change calls.readStatements text scan (.word "end") = _
      exact body.statements text valid scan context

def tokenAtIndex (form : Form) (index : Nat) : Token :=
  form.tokens.getD (index - 1) (.helper (.symbol ";"))

def suffixAtIndex (text : Source) (form : Form) (index : Nat) (scan : ScanResult) : ScanResult :=
  scanSuffix text form (form.tokens.drop (index - 1)) scan

def suffixEquation (recurse : Nat → ScanResult → ScanResult) (text : Source)
    (form : Form) (index : Nat) (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if index > form.tokens.length then
    if Cursor.triviaPosition text scan.state.position = text.length + 1 then scan else invalidScan
  else recurse (index + 1) (Predicate.scanStep text form (tokenAtIndex form index) scan)

theorem form_tokens_valid (form : Form) : ∀ token ∈ form.tokens, ValidToken token := by
  cases form <;> simp [Form.tokens, Form.prefix, Form.footer, Form.hasArguments, currentHeader, ValidToken, ValidHelperToken, Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem tokenAtIndex_valid (form : Form) (index : Nat) (first : 1 ≤ index)
    (last : index ≤ form.tokens.length) : ValidToken (tokenAtIndex form index) := by
  have present : index - 1 < form.tokens.length := by omega
  simp only [tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
  exact form_tokens_valid form _ (List.getElem_mem present)

theorem suffix_denotation (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (form : Form) (index : Nat) (scan : ScanResult) (context : ValidScan text scan)
    (first : 1 ≤ index) :
    suffixBody.eval calls {text,form,nextToken := index,scan} =
      suffixEquation (calls.suffix text form) text form index scan := by
  dsimp +instances only [suffixBody, Expr.eval, Condition.eval, IndexRef.eval, suffixEquation]
  simp only [decide_eq_true_eq]
  by_cases zero : scan.state.position = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases done : index > form.tokens.length
    · rw [helpers.trivia text valid scan.state.position (by omega) context.1.1]
      simp [done]
    · simp only [done, ↓reduceIte]
      exact congrArg (calls.suffix text form (index + 1))
        (interpreted_scanStep calls helpers body equations text valid form (tokenAtIndex form index) scan
          (tokenAtIndex_valid form index first (by omega)) context)

theorem suffixAtIndex_equation (text : Source) (form : Form) (index : Nat) (scan : ScanResult)
    (first : 1 ≤ index) :
    suffixAtIndex text form index scan = suffixEquation (suffixAtIndex text form) text form index scan := by
  unfold suffixAtIndex suffixEquation
  by_cases zero : scan.state.position = 0
  · cases form.tokens.drop (index - 1) <;> simp [scanSuffix, zero]
  · simp only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · have enough : form.tokens.length ≤ index - 1 := by omega
      simp [finished, List.drop_eq_nil_of_le enough, scanSuffix, zero]
    · have present : index - 1 < form.tokens.length := by omega
      have drop := List.drop_eq_getElem_cons present
      have next : index - 1 + 1 = index := by omega
      simp only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, scanSuffix, next,
        tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
      simp [zero]

theorem interpreted_suffix (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (form : Form) (index : Nat) (scan : ScanResult) (context : ValidScan text scan)
    (first : 1 ≤ index) (last : index ≤ form.tokens.length + 1) :
    calls.suffix text form index scan = suffixAtIndex text form index scan := by
  rw [equations.suffix text valid form index scan context first last,
    suffix_denotation calls helpers body equations text valid form index scan context first,
    suffixAtIndex_equation text form index scan first]
  unfold suffixEquation
  by_cases zero : scan.state.position = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · simp [finished]
    · simp only [finished, ↓reduceIte]
      have tokenValid := tokenAtIndex_valid form index first (by omega)
      have next := equations.ranges.step text valid form (tokenAtIndex form index) scan tokenValid context
      rw [interpreted_scanStep calls helpers body equations text valid form (tokenAtIndex form index) scan tokenValid context] at next
      exact interpreted_suffix calls helpers body equations text valid form (index + 1)
        (Predicate.scanStep text form (tokenAtIndex form index) scan) next (by omega) (by omega)
termination_by form.tokens.length + 1 - index
decreasing_by omega

private theorem initial_valid (text : Source) : ValidScan text initialScan :=
  OuterReadiness.initial_valid text

theorem interpreted_form (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (form : Form) :
    calls.formResult text form = Predicate.formResult text form := by
  rw [equations.formResult]
  dsimp +instances only [formBody, Expr.eval, Condition.eval]
  by_cases valid : ValidText text
  · have suffix := interpreted_suffix calls helpers body equations text valid form 1 initialScan (initial_valid text)
      (by omega) (by omega)
    have budget := Compose.Expressions.interpreted_workBudget calls.helpers helpers.equations.toRawHelperEquations text valid
    simp [Predicate.formResult, budget, suffix, suffixAtIndex, valid.1, valid.2]
  · have invalid : ¬(1 ≤ text.length ∧ text.length ≤ maxSourceLength) := valid
    simp [Predicate.formResult, invalid, Nat.lt_iff_add_one_le]

theorem interpreted_member (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.member text = accepts text := by
  rw [equations.member]
  have forms := funext (interpreted_form calls helpers body equations text)
  simp only [memberBody, MembershipBody.eval, forms, Bool.and_true]
  simp [accepts, selectedForm, formAccepts, List.isSome_find?]

theorem interpreted_arguments (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.arguments text = hasArguments text := by
  rw [equations.arguments]
  have forms := funext (interpreted_form calls helpers body equations text)
  simp only [argumentsBody, MembershipBody.eval, Flag.eval, forms]
  rfl

theorem interpreted_assignment (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.assignment text = hasAssignment text := by
  rw [equations.assignment]
  have forms := funext (interpreted_form calls helpers body equations text)
  simp only [assignmentBody, MembershipBody.eval, Flag.eval, forms]
  rfl

theorem interpreted_output (calls : Calls) (helpers : HelperMeaning calls) (body : BodyMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.output text = hasOutput text := by
  rw [equations.output]
  have forms := funext (interpreted_form calls helpers body equations text)
  simp only [outputBody, MembershipBody.eval, Flag.eval, forms]
  rfl

end Silver.Predicate.Outer
