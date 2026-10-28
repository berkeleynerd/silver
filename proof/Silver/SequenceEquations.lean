module

public import Silver.SequenceExpressions
public import Silver.ComposeEquations
public import Silver.ComposeLexical
public import Silver.SequenceNativeUnique
public import Silver.SequenceNativeCorrespondence

@[expose] public section

namespace Silver.Sequence.Expressions
open Compose

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

abbrev ValidScan (text : Source) (scan : ScanResult) : Prop :=
  Compose.Expressions.ValidState text scan.state
abbrev ValidText := Compose.Expressions.ValidText
abbrev ValidHelperToken := Compose.Expressions.ValidToken

def ValidStop (stop : ShellToken) : Prop := stop = .word "else" ∨ stop = .word "end"
def ValidToken : Token → Prop
  | .helper token => ValidHelperToken token
  | .statements => True

/-- Facts established by native contracts, excluding any semantic correctness
or equality to the scanner. Progress is measured in source-byte positions. -/
structure RangeContracts (calls : Calls) : Prop where
  token : ∀ text, ValidText text → ∀ scan token,
    ValidScan text scan → ValidHelperToken token → ValidScan text (calls.scanToken text scan token)
  basic : ∀ text, ValidText text → ∀ scan, ValidScan text scan →
    ValidScan text (calls.basic text scan) ∧
      ((calls.basic text scan).state.position = 0 ∨ scan.state.position < (calls.basic text scan).state.position)
  basicTail : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    ValidScan text (calls.basicTail text scan stop)
  readBasic : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    ValidScan text (calls.readBasic text scan stop)
  readStatements : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    ValidScan text (calls.readStatements text scan stop)
  step : ∀ text, ValidText text → ∀ form token scan, ValidToken token → ValidScan text scan →
    ValidScan text (calls.scanStep text form token scan)

/-- Inherited helper denotations. The actual-source bridge obtains these from
its checked helper equations and lexical domains. -/
structure HelperMeaning (calls : Calls) : Prop where
  equations : Compose.Expressions.HelperEquations calls.helpers
  step : ∀ text, ValidText text → ∀ (form : Form) token state,
    ValidHelperToken token → Compose.Expressions.ValidState text state →
    calls.helpers.function .step text form.helper token state = Compose.step text form.helper token state
  trivia : ∀ text, ValidText text → ∀ position, 0 < position → position ≤ text.length + 1 →
    calls.helpers.primitive.trivia text position = Cursor.triviaPosition text position

/-- Every field interprets a rendered native body or the exact result equation
in a proved imperative adapter contract. Recursive callees remain arbitrary. -/
structure DefinitionEquations (calls : Calls) : Prop where
  ranges : RangeContracts calls
  token : ∀ text, ValidText text → ∀ scan token,
    ValidScan text scan → ValidHelperToken token →
    calls.scanToken text scan token = scanTokenBody.eval calls {text,scan,token := .helper token}
  basic : ∀ text, ValidText text → ∀ scan, ValidScan text scan →
    calls.basic text scan = basicBody.run calls {text,scan}
  basicTail : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    calls.basicTail text scan stop = basicTailBody.eval calls {text,scan,stop}
  readBasic : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    calls.readBasic text scan stop = readBasicBody.eval calls {text,scan,stop}
  native : Native.Equations calls.bodyPrimitives calls.native
  readStatements : ∀ text, ValidText text → ∀ scan stop, ValidScan text scan → ValidStop stop →
    calls.readStatements text scan stop = Native.Adapter.statements.eval calls.native text scan stop
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

theorem interpreted_scanToken (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (scan : ScanResult) (token : ShellToken) (context : ValidScan text scan)
    (tokenValid : ValidHelperToken token) :
    calls.scanToken text scan token = Sequence.scanToken text scan token := by
  rw [equations.token text valid scan token context tokenValid]
  change {scan with state := calls.helpers.function .step text .direct token scan.state} = _
  have h := helpers.step text valid .direct token scan.state tokenValid context
  simpa only [Form.helper, Sequence.scanToken] using congrArg (fun state => {scan with state}) h

def callTokens (calls : Calls) (text : Source) (tokens : List ShellToken) (scan : ScanResult) : ScanResult :=
  tokens.foldl (fun current token => calls.scanToken text current token) scan

theorem interpreted_tokens (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (tokens : List ShellToken) (scan : ScanResult) (context : ValidScan text scan)
    (tokenValid : ∀ token ∈ tokens, ValidHelperToken token) :
    callTokens calls text tokens scan = scanTokens text .direct tokens scan ∧
      ValidScan text (callTokens calls text tokens scan) := by
  induction tokens generalizing scan with
  | nil => exact ⟨rfl, context⟩
  | cons token tokens ih =>
      have one := interpreted_scanToken calls helpers equations text valid scan token context (tokenValid _ (by simp))
      have next := equations.ranges.token text valid scan token context (tokenValid _ (by simp))
      have rest := ih (calls.scanToken text scan token) next (fun token member => tokenValid token (by simp [member]))
      refine ⟨?_, rest.2⟩
      simpa only [callTokens, scanTokens, List.foldl_cons, one, Sequence.scanToken] using rest.1

theorem steps_eval (calls : Calls) (ctx : Context) (tokens : List ShellToken) :
    (Command.steps tokens).eval calls ctx = (none, callTokens calls ctx.text tokens ctx.result) := by
  induction tokens generalizing ctx with
  | nil => rfl
  | cons token tokens ih =>
      simpa only [Command.steps, List.foldr_cons, Command.eval, Expr.eval, HelperRef.eval,
        callTokens, List.foldl_cons] using ih {ctx with result := calls.scanToken ctx.text ctx.result token}

def basicRawCalls (calls : Calls) (text : Source) (scan : ScanResult) : ScanResult :=
  if calls.helpers.function .takeToken text scan.state.position (.word "null") ≠ 0 then
    callTokens calls text BasicKind.null.tokens scan
  else if calls.helpers.function .takeToken text scan.state.position (.word "silver_io") ≠ 0 then
    {callTokens calls text BasicKind.output.tokens scan with output := true}
  else {callTokens calls text BasicKind.assignment.tokens scan with assigned := true}

theorem basic_eval (calls : Calls) (text : Source) (scan : ScanResult) :
    basicBody.run calls {text,scan} =
      if scan.state.position = 0 then invalidScan
      else if (basicRawCalls calls text scan).state.position ≤ scan.state.position then invalidScan
      else basicRawCalls calls text scan := by
  by_cases zero : scan.state.position = 0
  · simp [basicBody, Command.run, Command.eval, guardReturn, finish, Condition.eval,
      Expr.eval, zero]
  · by_cases hasNull : calls.helpers.function .takeToken text scan.state.position (.word "null") ≠ 0
    · by_cases advancing : (callTokens calls text BasicKind.null.tokens scan).state.position ≤ scan.state.position <;>
        simp [basicBody, Command.run, Command.eval, guardReturn, finish, Condition.eval,
          Expr.eval, HelperRef.eval, steps_eval, basicRawCalls, zero, hasNull, advancing]
    · by_cases hasOutput : calls.helpers.function .takeToken text scan.state.position (.word "silver_io") ≠ 0
      · by_cases advancing : (callTokens calls text BasicKind.output.tokens scan).state.position ≤ scan.state.position <;>
          simp [basicBody, Command.run, Command.eval, guardReturn, finish, Condition.eval,
            Expr.eval, HelperRef.eval, steps_eval, basicRawCalls, zero, hasNull, hasOutput, advancing]
      · by_cases advancing : (callTokens calls text BasicKind.assignment.tokens scan).state.position ≤ scan.state.position <;>
          simp [basicBody, Command.run, Command.eval, guardReturn, finish, Condition.eval,
            Expr.eval, HelperRef.eval, steps_eval, basicRawCalls, zero, hasNull, hasOutput, advancing]

theorem basic_tokens_valid (kind : BasicKind) :
    ∀ token ∈ kind.tokens, ValidHelperToken token := by
  cases kind <;> simp [BasicKind.tokens, outputTokens, assignmentTokens, ValidHelperToken,
    Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem interpreted_basic (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (scan : ScanResult) (context : ValidScan text scan) :
    calls.basic text scan = basicStatementAt text scan := by
  rw [equations.basic text valid scan context, basic_eval]
  have nullToken := Compose.Expressions.interpreted_take calls.helpers helpers.equations
    text valid scan.state.position (.word "null") context.1 (by simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens])
  have ioToken := Compose.Expressions.interpreted_take calls.helpers helpers.equations
    text valid scan.state.position (.word "silver_io") context.1 (by simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens])
  have scanned := fun kind => (interpreted_tokens calls helpers equations text valid kind.tokens scan context
    (basic_tokens_valid kind)).1
  have raw : basicRawCalls calls text scan = basicRaw text scan := by
    unfold basicRawCalls
    rw [nullToken, ioToken]
    simp only [Compose.Expressions.spelling, Compose.Expressions.isWord, ShellToken.word]
    by_cases hasNull : fixedAfter text scan.state.position "null" true ≠ 0
    · simp [basicRaw, basicKind, scanned .null, hasNull, BEq.beq]
    · by_cases hasOutput : fixedAfter text scan.state.position "silver_io" true ≠ 0
      · simp [basicRaw, basicKind, scanned .output, hasNull, hasOutput]
      · simp [basicRaw, basicKind, scanned .assignment, hasNull, hasOutput]
  rw [raw]
  rfl

theorem interpreted_stop (calls : Calls) (helpers : HelperMeaning calls)
    (text : Source) (valid : ValidText text) (scan : ScanResult) (context : ValidScan text scan)
    (stop : ShellToken) (stopValid : ValidStop stop) :
    calls.helpers.function .takeToken text scan.state.position stop = tokenAfter text scan.state.position stop := by
  rcases stopValid with rfl | rfl <;>
    exact Compose.Expressions.interpreted_take calls.helpers helpers.equations text valid scan.state.position _ context.1 (by unfold Compose.Expressions.ValidToken; decide)

/-- Uniqueness for the cursor-decreasing list equation. The native contract
supplies progress, so the model's totalizing measure guard is always satisfied. -/
theorem tail_unique (text : Source) (read recurse : ScanResult → ScanResult) (stop : ShellToken)
    (readValid : ∀ scan, ValidScan text scan → ValidScan text (read scan))
    (progress : ∀ scan, (read scan).state.position ≠ 0 → scan.state.position < (read scan).state.position)
    (equation : ∀ scan, ValidScan text scan → recurse scan =
      if scan.state.position = 0 then invalidScan
      else if tokenAfter text scan.state.position stop ≠ 0 then scan
      else if (read scan).state.position = 0 then invalidScan else recurse (read scan))
    (scan : ScanResult) (context : ValidScan text scan) :
    recurse scan = tail text read (.token stop) scan := by
  rw [equation scan context, tail]
  simp only [stopAfter]
  by_cases zero : scan.state.position = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases done : tokenAfter text scan.state.position stop ≠ 0
    · simp [done]
    · simp only [done, ↓reduceIte]
      by_cases failed : (read scan).state.position = 0
      · simp [failed]
      · have next := readValid scan context
        have advance := progress scan failed
        have decrease : text.length + 1 - (read scan).state.position < text.length + 1 - scan.state.position := by
          have bound := next.1
          change (read scan).state.position ≤ text.length + 1 at bound
          omega
        simp only [failed, ↓reduceIte, decrease]
        exact tail_unique text read recurse stop readValid progress equation (read scan) next
termination_by text.length + 1 - scan.state.position

theorem interpreted_basicTail (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (scan : ScanResult) (stop : ShellToken) (context : ValidScan text scan) (stopValid : ValidStop stop) :
    calls.basicTail text scan stop = basicTail text scan stop := by
  apply tail_unique text (basicStatementAt text) (fun value => calls.basicTail text value stop) stop
  · intro value range
    rw [← interpreted_basic calls helpers equations text valid value range]
    exact (equations.ranges.basic text valid value range).1
  · intro value accepted
    exact basic_progress accepted
  · intro value range
    rw [equations.basicTail text valid value stop range stopValid]
    dsimp +instances only [basicTailBody, Expr.eval, Condition.eval, HelperRef.eval]
    simp only [decide_eq_true_eq]
    rw [interpreted_stop calls helpers text valid value range stop stopValid,
      interpreted_basic calls helpers equations text valid value range]
  · exact context

theorem interpreted_readBasic (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (scan : ScanResult) (stop : ShellToken) (context : ValidScan text scan) (stopValid : ValidStop stop) :
    calls.readBasic text scan stop = readBasicStatements text scan stop := by
  rw [equations.readBasic text valid scan stop context stopValid]
  change calls.basicTail text (calls.basic text scan) stop = _
  rw [interpreted_basicTail calls helpers equations text valid _ stop
    (equations.ranges.basic text valid scan context).1 stopValid,
    interpreted_basic calls helpers equations text valid scan context]
  rfl

theorem body_primitives (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) :
    Native.PrimitiveAgreement calls.bodyPrimitives Native.modelPrimitives where
  take text valid position token bound tokenValid :=
    Compose.Expressions.interpreted_take calls.helpers helpers.equations text valid position token bound tokenValid
  token text valid scan token scanValid tokenValid :=
    interpreted_scanToken calls helpers equations text valid scan token scanValid tokenValid
  basic text valid scan scanValid :=
    interpreted_basic calls helpers equations text valid scan scanValid

theorem interpreted_readStatements (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (scan : ScanResult) (stop : ShellToken) (context : ValidScan text scan) (stopValid : ValidStop stop) :
    calls.readStatements text scan stop = readStatements text scan stop := by
  rw [equations.readStatements text valid scan stop context stopValid]
  dsimp only [Native.Adapter.eval]
  have parts := Native.parts_valid text scan context
  rw [Native.read_unique (body_primitives calls helpers equations) equations.native Native.model_equations
    text valid (Native.contextOf scan) parts.1 (Native.bodyOf scan) parts.2]
  exact Native.model_adapter text valid scan stop context stopValid

theorem interpreted_scanStep (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (form : Form) (token : Token) (scan : ScanResult) (tokenValid : ValidToken token)
    (context : ValidScan text scan) :
    calls.scanStep text form token scan = Sequence.scanStep text form token scan := by
  rw [equations.step text valid form token scan tokenValid context]
  cases token with
  | helper token =>
      dsimp +instances only [scanStepBody, Expr.eval, Condition.eval, HelperRef.eval]
      change {scan with state := calls.helpers.function .step text form.helper token scan.state} = _
      rw [helpers.step text valid form token scan.state tokenValid context]
      rfl
  | statements =>
      change calls.readStatements text scan form.stop = _
      exact interpreted_readStatements calls helpers equations text valid scan form.stop context (by cases form <;> simp [Form.stop, Form.hasArguments, ValidStop])

def tokenAtIndex (form : Form) (index : Nat) : Token :=
  form.tokens.getD (index - 1) (.helper (.symbol ";"))

def suffixAtIndex (text : Source) (form : Form) (index : Nat) (scan : ScanResult) : ScanResult :=
  scanSuffix text form (form.tokens.drop (index - 1)) scan

def suffixEquation (recurse : Nat → ScanResult → ScanResult) (text : Source)
    (form : Form) (index : Nat) (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if index > form.tokens.length then
    if Cursor.triviaPosition text scan.state.position = text.length + 1 then scan else invalidScan
  else recurse (index + 1) (Sequence.scanStep text form (tokenAtIndex form index) scan)

theorem form_tokens_valid (form : Form) : ∀ token ∈ form.tokens, ValidToken token := by
  cases form <;> simp [Form.tokens, Form.prefix, Form.footer, Form.hasArguments, header, guardTokens,
    rejectTokens, endIfTokens, ValidToken, ValidHelperToken, Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem tokenAtIndex_valid (form : Form) (index : Nat) (first : 1 ≤ index)
    (last : index ≤ form.tokens.length) : ValidToken (tokenAtIndex form index) := by
  have present : index - 1 < form.tokens.length := by omega
  simp only [tokenAtIndex, List.getD, List.getElem?_eq_getElem present, Option.getD_some]
  exact form_tokens_valid form _ (List.getElem_mem present)

theorem suffix_denotation (calls : Calls) (helpers : HelperMeaning calls)
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
    · rw [helpers.trivia text valid scan.state.position (by omega) context.1]
      simp [done]
    · simp only [done, ↓reduceIte]
      exact congrArg (calls.suffix text form (index + 1))
        (interpreted_scanStep calls helpers equations text valid form (tokenAtIndex form index) scan
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

theorem interpreted_suffix (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (valid : ValidText text)
    (form : Form) (index : Nat) (scan : ScanResult) (context : ValidScan text scan)
    (first : 1 ≤ index) (last : index ≤ form.tokens.length + 1) :
    calls.suffix text form index scan = suffixAtIndex text form index scan := by
  rw [equations.suffix text valid form index scan context first last,
    suffix_denotation calls helpers equations text valid form index scan context first,
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
      rw [interpreted_scanStep calls helpers equations text valid form (tokenAtIndex form index) scan tokenValid context] at next
      exact interpreted_suffix calls helpers equations text valid form (index + 1)
        (Sequence.scanStep text form (tokenAtIndex form index) scan) next (by omega) (by omega)
termination_by form.tokens.length + 1 - index
decreasing_by omega

private theorem initial_valid (text : Source) : ValidScan text initialScan := by
  simp [ValidScan, Compose.Expressions.ValidState, Compose.Expressions.ValidCursor,
    Compose.Expressions.ValidNames, initialScan, initialState, Named.NameState.Valid, maxBindings, maxSourceLength,
    ScalarExpression.validEnvironment_empty, ArrayBindings.ValidEnvironment,
    ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials]

theorem interpreted_form (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) (form : Form) :
    calls.formResult text form = Sequence.formResult text form := by
  rw [equations.formResult]
  dsimp +instances only [formBody, Expr.eval, Condition.eval]
  by_cases valid : ValidText text
  · have suffix := interpreted_suffix calls helpers equations text valid form 1 initialScan (initial_valid text)
      (by omega) (by omega)
    have budget := Compose.Expressions.interpreted_workBudget calls.helpers helpers.equations text valid
    simp [Sequence.formResult, budget, suffix, suffixAtIndex, valid.1, valid.2]
  · have invalid : ¬(1 ≤ text.length ∧ text.length ≤ maxSourceLength) := valid
    simp [Sequence.formResult, invalid, Nat.lt_iff_add_one_le]

theorem interpreted_member (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.member text = accepts text := by
  rw [equations.member]
  have forms := funext (interpreted_form calls helpers equations text)
  simp only [memberBody, MembershipBody.eval, forms, Bool.and_true]
  simp [accepts, selectedForm, formAccepts, List.isSome_find?]

theorem interpreted_arguments (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.arguments text = hasArguments text := by
  rw [equations.arguments]
  have forms := funext (interpreted_form calls helpers equations text)
  simp only [argumentsBody, MembershipBody.eval, Flag.eval, forms]
  rfl

theorem interpreted_assignment (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.assignment text = hasAssignment text := by
  rw [equations.assignment]
  have forms := funext (interpreted_form calls helpers equations text)
  simp only [assignmentBody, MembershipBody.eval, Flag.eval, forms]
  rfl

theorem interpreted_output (calls : Calls) (helpers : HelperMeaning calls)
    (equations : DefinitionEquations calls) (text : Source) : calls.output text = hasOutput text := by
  rw [equations.output]
  have forms := funext (interpreted_form calls helpers equations text)
  simp only [outputBody, MembershipBody.eval, Flag.eval, forms]
  rfl

end Silver.Sequence.Expressions
