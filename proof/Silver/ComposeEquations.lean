module

public import Silver.ComposeContracts
public import Silver.ComposeScalarDenotations
public import Silver.ComposeStateBounds
public import Silver.ComposeNameBridge
public import Silver.ScalarExpressionNativeTypes

@[expose] public section

/-! Interpret the recognizer's checked equations on its verified machine
 domains. Executable loop refinements supply equations for the same terminating
 traversals; no premise identifies the recognizer with language membership. -/

namespace Silver.Compose.Expressions
open Named

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read scalarConstraintAt

@[simp] theorem interpreted_skip (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .skip text position = skipAt text position := by
  rw [equations.skip text valid position bound]
  dsimp +instances only [skipBody, Expr.eval, Context.locals, lexical, modelPrimitives, skipAt]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_name (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .nameAfter text position = nameAfter text position := by
  rw [equations.name text valid position bound]
  dsimp +instances only [nameBody, Expr.eval, Context.locals, lexical, modelPrimitives, nameAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_fixed (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .fixedAfter text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.fixed text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_take (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .takeToken text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.take text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_literal (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .literal text position = literalAt text position := by
  rw [equations.literal text valid position bound]
  dsimp +instances only [literalBody, Expr.eval, Context.locals, lexical, modelPrimitives, literalAt]
  simp only [Bool.and_eq_true, and_assoc, decide_eq_true_eq]

@[simp] theorem interpreted_lookupFrom (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after index : Nat)
    (namesValid : ValidNames text names) (nameValid : ValidName text first after)
    (positive : 1 ≤ index) (bounded : index ≤ names.length + 1) :
    calls.function .lookupFrom text names first after index = lookupFrom text names first after index := by
  rw [equations.lookupFrom text valid names first after index namesValid nameValid positive bounded,
    lookupFrom_equation text names first after index (by omega)]
  dsimp +instances only [lookupFromBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get]
  simp only [decide_eq_true_eq]
  split
  · rfl
  · rename_i within
    have nextBound : index + 1 ≤ names.length + 1 := Nat.add_le_add_right (Nat.le_of_not_gt within) 1
    split
    · rfl
    · exact interpreted_lookupFrom calls equations text valid names first after (index + 1)
        namesValid nameValid (by omega) nextBound
termination_by names.length + 1 - index
decreasing_by omega

@[simp] theorem interpreted_lookup (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after : Nat)
    (namesValid : ValidNames text names) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .lookupName text names first after = lookupName text names first after := by
  rw [equations.lookup text valid names first after namesValid firstValid afterValid]
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, lexical, Calls.get, lookupName]
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  split
  · rfl
  · rename_i outside
    have firstPositive : 0 < first := Nat.pos_of_ne_zero (fun zero => outside (Or.inl zero))
    have afterGreater : first < after := Nat.lt_of_not_ge (fun low => outside (Or.inr low))
    apply interpreted_lookupFrom calls equations text valid names first after 1 namesValid
        (by exact ⟨firstPositive, afterGreater, afterValid⟩) (by omega) (by omega)

@[simp] theorem interpreted_callAfter (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (position : Nat)
    (operation : Names.Operation) {scalarNames : ScalarExpression.Environment} (namesValid : ValidNames text names) (bound : ValidCursor text position) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) :
    calls.function .callAfter text names position operation scalarNames = callAfter text names position operation scalarNames := by
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  have firstBound := equations.ranges.skip text valid position bound
  have afterBound := equations.ranges.name text valid first firstBound
  have firstEq : first = skipAt text position := interpreted_skip calls equations text valid position bound
  have afterEq : after = nameAfter text first := interpreted_name calls equations text valid first firstBound
  have lookupEq := interpreted_lookup calls equations text valid names first after namesValid firstBound afterBound
  rw [equations.callAfter text valid names position operation scalarNames namesValid scalarValid bound]
  dsimp +instances only [callAfterBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [Names.interpreted_operation calls.names equations.names text valid position operation _ bound]
  change Names.operationAfter text position operation
    (decide (calls.function .lookupName text names first after ≠ 0) ||
      decide (calls.function .scalarLookup text scalarNames first after ≠ 0)) = _
  rw [lookupEq, equations.scalarLookup text valid scalarNames first after scalarValid firstBound afterBound, afterEq, firstEq]
  simp only [callAfter, Bool.decide_or]

@[simp] theorem interpreted_workTail (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position remaining : Nat)
    (bound : ValidCursor text position) (remainingBound : remaining ≤ maxConcatenations) :
    calls.function .workTail text position remaining = workTail text position remaining := by
  have firstEq := interpreted_skip calls equations text valid position bound
  have firstBound := equations.ranges.skip text valid position bound
  rw [firstEq] at firstBound
  have quotedEq := interpreted_literal calls equations text valid (skipAt text position) firstBound
  have quotedBound := equations.ranges.literal text valid (skipAt text position) firstBound
  rw [quotedEq] at quotedBound
  have nameEq := interpreted_name calls equations text valid (skipAt text position) firstBound
  have nameBound := equations.ranges.name text valid (skipAt text position) firstBound
  rw [nameEq] at nameBound
  have numberEq := equations.scalarLiteral text valid (skipAt text position) firstBound
  rw [equations.workTail text valid position remaining bound remainingBound]
  dsimp +instances only [workTailBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, firstEq, quotedEq, nameEq, numberEq, decide_eq_true_eq]
  simp only [List.mem_cons, List.not_mem_nil, or_false]
  rw [workTail]
  by_cases firstZero : skipAt text position = 0
  · simp [firstZero]
  · by_cases finished : skipAt text position > text.length
    · simp [firstZero, finished]
    · have firstAdvance := skipAt_advances text position bound firstZero
      have plainBound : ValidCursor text (skipAt text position + 1) := by unfold ValidCursor; omega
      have plainDecrease : text.length + 1 - (skipAt text position + 1) <
          text.length + 1 - position := by omega
      by_cases isQuote : Cursor.byteAt text (skipAt text position) = 34
      · by_cases absent : (literalAt text (skipAt text position)).after = 0
        · simp [firstZero, finished, isQuote, absent]
        · have quotedAdvance := literalAt_advances text (skipAt text position) absent
          have quotedDecrease : text.length + 1 - (literalAt text (skipAt text position)).after <
              text.length + 1 - position := by omega
          simp only [firstZero, finished, isQuote, absent, quotedDecrease, ↓reduceIte, ↓reduceDIte,
            ne_eq, not_false_eq_true, decide_true, Bool.true_and]
          exact interpreted_workTail calls equations text valid _ remaining quotedBound.1 remainingBound
      · by_cases nameNonzero : nameAfter text (skipAt text position) ≠ 0
        · have nameAdvance := model_name_advances text (skipAt text position) nameNonzero
          have nameDecrease : text.length + 1 - nameAfter text (skipAt text position) <
              text.length + 1 - position := by omega
          simp only [firstZero, finished, isQuote, nameNonzero, nameDecrease, ↓reduceIte,
            ↓reduceDIte, ne_eq, not_false_eq_true]
          exact interpreted_workTail calls equations text valid _ remaining nameBound remainingBound
        · by_cases numberNonzero : (ScalarLiteral.read text (skipAt text position)).after ≠ 0
          · have numberBounds := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound firstBound numberNonzero)
            have numberDecrease : text.length + 1 - (ScalarLiteral.read text (skipAt text position)).after <
                text.length + 1 - position := by omega
            simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, numberDecrease, ↓reduceIte,
              ↓reduceDIte, ne_eq, not_false_eq_true]
            exact interpreted_workTail calls equations text valid _ remaining numberBounds.2.1 remainingBound
          · by_cases isOperator : Cursor.byteAt text (skipAt text position) = 38 ∨
                Cursor.byteAt text (skipAt text position) = 43 ∨ Cursor.byteAt text (skipAt text position) = 45 ∨
                Cursor.byteAt text (skipAt text position) = 42
            · by_cases empty : remaining = 0
              · simp [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty]
              · simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty, plainDecrease,
                  ↓reduceIte, ↓reduceDIte, ne_eq, not_false_eq_true, decide_true, Bool.true_and]
                exact interpreted_workTail calls equations text valid _ (remaining - 1) plainBound (by omega)
            · simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, plainDecrease, ↓reduceIte, ↓reduceDIte]
              exact interpreted_workTail calls equations text valid _ remaining plainBound remainingBound

termination_by text.length + 1 - position
 decreasing_by all_goals assumption

@[simp] theorem interpreted_workBudget (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) :
    calls.function .workBudget text = withinWorkBudget text := by
  rw [equations.workBudget text valid]
  exact interpreted_workTail calls equations text valid 1 maxConcatenations (by unfold ValidCursor; omega) (Nat.le_refl _)

@[simp] theorem interpreted_image (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (integerHidden : Bool) {scalarNames : ScalarExpression.Environment}
    (bound : ValidCursor text position) (namesValid : ValidNames text names)
    (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) :
    calls.function .image text position names scalarNames integerHidden =
      imageAt text position names scalarNames integerHidden := by
  let parts := imageParts text position scalarNames
  have bfirst : ValidCursor text parts.first := model_skip_valid text position bound
  have btype : ValidCursor text parts.typeAfter := model_fixed_valid text _ "integer" true bfirst
  have bapostrophe : ValidCursor text (fixedAfter text parts.typeAfter "'" false) :=
    model_fixed_valid text _ "'" false btype
  have battribute : ValidCursor text parts.attributeFirst := model_skip_valid text _ bapostrophe
  have bafter : ValidCursor text parts.attributeAfter := model_name_valid text _
  have bposition : ValidCursor text parts.scalarPosition := model_fixed_valid text _ "(" false bafter
  have bscalar : ValidCursor text parts.scalar.after ∧ parts.scalar.bounds.Bounded := by
    have typed := ScalarExpression.Native.read_type valid bposition
      (names := scalarNames) (maskFirst := 0) (maskAfter := 0) (allowSign := true)
    refine ⟨?_, typed.2.1⟩
    by_cases zero : parts.scalar.after = 0
    · simp [ValidCursor, zero]
    · exact (ScalarExpression.read_bounds bposition zero).2.1
  have efirst : calls.function .skip text position = parts.first := interpreted_skip calls equations text valid position bound
  have etype : calls.function .takeToken text parts.first (.word "integer") = parts.typeAfter := interpreted_take calls equations text valid parts.first (.word "integer") bfirst (by unfold ValidToken; decide)
  have eapostrophe := interpreted_take calls equations text valid parts.typeAfter (.symbol "'") btype (by unfold ValidToken; decide)
  have eattribute : calls.function .skip text (fixedAfter text parts.typeAfter "'" false) = parts.attributeFirst := interpreted_skip calls equations text valid _ bapostrophe
  have eafter : calls.function .nameAfter text parts.attributeFirst = parts.attributeAfter := interpreted_name calls equations text valid parts.attributeFirst battribute
  have eposition : calls.function .takeToken text parts.attributeAfter (.symbol "(") = parts.scalarPosition := interpreted_take calls equations text valid parts.attributeAfter (.symbol "(") bafter (by unfold ValidToken; decide)
  have escalar : calls.function .scalarRead text parts.scalarPosition scalarNames = parts.scalar := equations.scalarRead text valid parts.scalarPosition scalarNames bposition scalarValid
  have efollowing : calls.function .takeToken text parts.scalar.after (.symbol ")") = parts.following := interpreted_take calls equations text valid parts.scalar.after (.symbol ")") bscalar.1 (by unfold ValidToken; decide)
  have elookup := interpreted_lookup calls equations text valid names parts.first parts.typeAfter namesValid bfirst btype
  have eslookup := equations.scalarLookup text valid scalarNames parts.first parts.typeAfter scalarValid bfirst btype
  simp only [ShellToken.word, ShellToken.symbol, spelling, isWord] at etype eapostrophe eposition efollowing
  rw [equations.image text valid position names scalarNames integerHidden bound namesValid scalarValid]
  dsimp +instances only [imageBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  simp +instances only [ShellToken.word, ShellToken.symbol, efirst, etype, eapostrophe,
    eattribute, eafter, eposition, escalar, efollowing, elookup, eslookup]
  rw [equations.imageMinimum _ bscalar.2, equations.imageMaximum _ bscalar.2,
    equations.scalarEmpty _ bscalar.2]
  change _ = if integerHidden || decide (parts.typeAfter = 0 ∨
      lookupName text names parts.first parts.typeAfter ≠ 0 ∨
      ScalarExpression.lookup text scalarNames parts.first parts.typeAfter ≠ 0 ∨
      parts.attributeFirst = 0 ∨ parts.attributeAfter ≤ parts.attributeFirst) ||
      !Named.nameIs text parts.attributeFirst parts.attributeAfter ("image".toList.map Char.toNat) ||
      decide (parts.following ≤ position) then invalidValue else imageValue parts
  have empty : (LengthSummary.ofImage parts.scalar.bounds).empty = parts.scalar.bounds.isEmpty := by
    unfold LengthSummary.ofImage
    split <;> simp_all
  by_cases nameValid : parts.attributeFirst ≠ 0 ∧ parts.attributeFirst < parts.attributeAfter
  · rw [equations.nameIs text valid parts.attributeFirst parts.attributeAfter "image"
      ⟨by omega, nameValid.2, bafter⟩ (by decide) (by decide)]
    dsimp only [imageValue]
    rw [empty]
    simp only [Bool.decide_or, Bool.or_assoc]
  · have absent : parts.attributeFirst = 0 ∨ parts.attributeAfter ≤ parts.attributeFirst := by omega
    rcases absent with zero | reversed
    · simp [zero]
    · simp [reversed]

@[simp] theorem interpreted_value (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    (bound : ValidCursor text position) (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) :
    calls.function .value text position names scalarNames integerHidden = valueAt text position names scalarNames integerHidden := by
  have skipBound := equations.ranges.skip text valid position bound
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid position bound
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have literalEq := interpreted_literal calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid names _ _ namesValid skipBound nameBound
  rw [equations.value text valid position names scalarNames integerHidden bound namesValid scalarValid]
  dsimp +instances only [valueBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [literalEq, lookupEq, equations.scalarLookup text valid scalarNames _ _ scalarValid skipBound nameBound, nameEq, skipEq]
  rw [interpreted_image calls equations text valid position names integerHidden bound namesValid scalarValid]
  simp only [valueAt, Bool.and_eq_true, decide_eq_true_eq]

@[simp] theorem interpreted_newName (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (arguments : Bool)
    (stateValid : ValidState text state) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .newName text state first after arguments = newNameAllowed text state first after arguments := by
  rw [equations.newName text valid state first after arguments stateValid firstValid afterValid]
  dsimp +instances only [newNameBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get, newNameAllowed]
  simp only [interpreted_lookup calls equations text valid state.names first after stateValid.2.1 firstValid afterValid, equations.scalarLookup text valid state.scalarNames first after stateValid.2.2.2.2.2 firstValid afterValid, Bool.and_assoc, Bool.decide_and]

@[simp] theorem interpreted_addBinding (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) (stateValid : ValidState text state)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after)
    (valueValid : ValidValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings) :
    calls.function .addBinding state first after value mutable following = addBinding state first after value mutable following := by
  rw [equations.addBinding text valid state first after value mutable following stateValid firstValid afterValid valueValid followingValid room]
  rfl

@[simp] theorem interpreted_expressionStep (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) (scanValid : ValidScan text scan) :
    calls.function .expressionStep text names scan scalarNames integerHidden = expressionStep text names scan scalarNames integerHidden := by
  have eopen := interpreted_take calls equations text valid scan.position (.symbol "(") scanValid.1
    (by unfold ValidToken; decide)
  have ejoin := interpreted_take calls equations text valid scan.position (.symbol "&") scanValid.1
    (by unfold ValidToken; decide)
  have eclose := interpreted_take calls equations text valid scan.position (.symbol ")") scanValid.1
    (by unfold ValidToken; decide)
  have atom := interpreted_value (integerHidden := integerHidden) calls equations text valid scan.position names scanValid.1 namesValid scalarValid
  rw [equations.expressionStep text valid names scan scalarNames integerHidden namesValid scalarValid scanValid]
  dsimp +instances only [expressionStepBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  simp only [ShellToken.symbol, spelling, isWord] at eopen ejoin eclose
  simp only [ShellToken.symbol]
  simp only [eopen, ejoin, eclose, atom]
  simp [expressionStep, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

@[simp] theorem interpreted_tail (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) (scanValid : ValidScan text scan) :
    calls.function .tail text names scan scalarNames integerHidden = expressionTail text names scan scalarNames integerHidden := by
  have stepEq := interpreted_expressionStep (integerHidden := integerHidden) calls equations text valid names scan namesValid scalarValid scanValid
  have nextRange := equations.ranges.expressionStep text valid names scan scalarNames integerHidden namesValid scalarValid scanValid
  rw [stepEq] at nextRange
  rw [equations.tail text valid names scan scalarNames integerHidden namesValid scalarValid scanValid]
  dsimp +instances only [tailBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte, stepEq, decide_eq_true_eq]
  rw [expressionTail]
  by_cases zero : scan.position = 0
  · simp [zero]
  · by_cases complete : scan.complete = true
    · simp [zero, complete, ExpressionState.result]
    · by_cases nextZero : (expressionStep text names scan scalarNames integerHidden).position = 0
      · simp [zero, complete, nextZero]
      · by_cases nextComplete : (expressionStep text names scan scalarNames integerHidden).complete = true
        · simp [zero, complete, nextZero, nextComplete, ExpressionState.result]
        · have advances : scan.position < (expressionStep text names scan scalarNames integerHidden).position := by
            rcases nextRange.2 with bad | done | progress
            · exact False.elim (nextZero bad)
            · exact False.elim (nextComplete done)
            · exact progress
          have bounded := nextRange.1.1
          have smaller : text.length + 1 - (expressionStep text names scan scalarNames integerHidden).position <
              text.length + 1 - scan.position := by
            unfold ValidCursor at bounded
            omega
          simp only [zero, complete, nextZero, nextComplete, smaller, ↓reduceIte, ↓reduceDIte]
          exact interpreted_tail (integerHidden := integerHidden) calls equations text valid names (expressionStep text names scan scalarNames integerHidden)
            namesValid scalarValid nextRange.1
termination_by text.length + 1 - scan.position
 decreasing_by
  have nextBound := nextRange.1.1
  unfold ValidCursor at nextBound
  omega

@[simp] theorem interpreted_expression (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    (bound : ValidCursor text position) (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames) :
    calls.function .expression text position names scalarNames integerHidden = expressionAt text position names scalarNames integerHidden := by
  rw [equations.expression text valid position names scalarNames integerHidden bound namesValid scalarValid]
  change calls.function .tail text names {position := position} scalarNames integerHidden = expressionAt text position names scalarNames integerHidden
  apply interpreted_tail calls equations text valid names _ namesValid scalarValid
  refine ⟨bound, Nat.zero_le _, Nat.le_refl _, Nat.zero_le _, Nat.zero_le _, ?_, Nat.zero_le _⟩
  change position = 0 ∨ 0 < position
  omega

@[simp] theorem interpreted_fits (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (result : ExpressionResult) (capacity : Nat)
    (resultValid : ValidResult text result) (capacityBound : capacity ≤ maxSourceLength) :
    calls.function .fits result capacity = fits result capacity := by
  rw [equations.fits text valid result capacity resultValid capacityBound]
  dsimp +instances only [fitsBody, Expr.eval, Context.locals, Field.get]
  by_cases zero : result.after = 0 <;> simp [fits, zero]

private theorem decideIf {α : Type} (p : Prop) [Decidable p] (yes no : α) :
    (if decide p then yes else no) = (if p then yes else no) := by simp

private theorem declarationGate {α : Type} (a : Bool) (b c : Prop) [Decidable b] [Decidable c]
    (yes no : α) :
    (if (a = false ∨ b) ∨ c then yes else no) =
      (if !a || decide (b ∨ c) then yes else no) := by
  cases a <;> simp

@[simp] theorem interpreted_stringDeclaration (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .stringDeclaration text state arguments = stringDeclarationAt text state arguments := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := calls.function .takeToken text after (.symbol ":")
  let constant := calls.function .takeToken text colon (.word "constant")
  let typeAfter := calls.function .takeToken text (if constant ≠ 0 then constant else colon) (.word "string")
  let valuePosition := calls.function .takeToken text typeAfter (.symbol ":=")
  let integerHidden := decide (first ≠ 0) && decide (after > first) &&
    decide (calls.function .takeToken text first (.word "integer") = after)
  let value := calls.function .expression text valuePosition state.names state.scalarNames integerHidden
  let following := calls.function .takeToken text value.after (.symbol ";")
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ stateValid.1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have bcolon : ValidCursor text colon := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have bconstant : ValidCursor text constant := equations.ranges.token text valid _ _ bcolon (by unfold ValidToken; decide)
  have btype : ValidCursor text typeAfter := equations.ranges.token text valid _ _
    (by split <;> assumption) (by unfold ValidToken; decide)
  have bposition : ValidCursor text valuePosition := equations.ranges.token text valid _ _ btype (by unfold ValidToken; decide)
  have bvalue : ValidResult text value := equations.ranges.expression text valid _ _ state.scalarNames integerHidden bposition stateValid.2.1 stateValid.2.2.2.2.2
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bvalue.1 (by unfold ValidToken; decide)
  have efirst : first = declarationFirst text state := interpreted_skip calls equations text valid _ stateValid.1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  have ecolon : colon = fixedAfter text after ":" false := interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  have econstant : constant = fixedAfter text colon "constant" true := interpreted_take calls equations text valid _ _ bcolon (by unfold ValidToken; decide)
  have etype : typeAfter = fixedAfter text (if constant ≠ 0 then constant else colon) "string" true :=
    interpreted_take calls equations text valid _ _ (by split <;> assumption) (by unfold ValidToken; decide)
  have eposition : valuePosition = fixedAfter text typeAfter ":=" false :=
    interpreted_take calls equations text valid _ _ btype (by unfold ValidToken; decide)
  have evalue : value = expressionAt text valuePosition state.names state.scalarNames integerHidden := interpreted_expression (integerHidden := integerHidden) calls equations text valid _ _ bposition stateValid.2.1 stateValid.2.2.2.2.2
  have efollowing : following = fixedAfter text value.after ";" false :=
    interpreted_take calls equations text valid _ _ bvalue.1 (by unfold ValidToken; decide)
  have efits := interpreted_fits calls equations text valid value maxSourceLength bvalue (Nat.le_refl _)
  have convertedValid : ValidValue text value.value :=
    ⟨bvalue.1, Nat.zero_le _, bvalue.2.1, Nat.zero_le _, bvalue.2.2.2⟩
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  rw [equations.stringDeclaration text valid state arguments stateValid]
  dsimp +instances only [stringDeclarationBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true']
  change (if ((((calls.function .newName text state first after arguments = false ∨ following = 0) ∨
    state.names.length = maxBindings) ∨ calls.function .fits value maxSourceLength = false) ∨
    value.emptyValue = true) ∨ value.minimumLength ≠ value.staticLength then invalidState
    else calls.function .addBinding state first after value.value (decide (constant = 0)) following) = _
  by_cases full : state.names.length = maxBindings
  · simp [full, stringDeclarationAt]
  · have room : state.names.length < maxBindings := by have := stateValid.2.1.1; omega
    rw [interpreted_addBinding calls equations text valid state first after value.value _ following
      stateValid bfirst bafter convertedValid bfollowing room, ename, efits]
    have modelFirst : declarationFirst text state = first := efirst.symm
    have modelAfter : declarationAfter text state = after := by
      unfold declarationAfter
      rw [modelFirst]
      exact eafter.symm
    have modelColon : declarationColonAfter text state = colon := by
      unfold declarationColonAfter
      rw [modelAfter]
      exact ecolon.symm
    have modelConstant : declarationConstantAfter text state = constant := by
      unfold declarationConstantAfter
      rw [modelColon]
      exact econstant.symm
    have modelPosition : declarationValuePosition text state = valuePosition := by
      unfold declarationValuePosition
      rw [modelConstant, modelColon, ← etype]
      exact eposition.symm
    have hidden : declarationIntegerHidden text state = integerHidden := by
      have taken := interpreted_take calls equations text valid first (.word "integer") bfirst
        (by unfold ValidToken; decide)
      simp only [ShellToken.word, spelling, isWord] at taken
      simp only [declarationIntegerHidden, integerHidden, modelFirst, modelAfter, ShellToken.word, taken,
        Bool.decide_and, Bool.and_assoc]
    have parts : declarationParts text state = ⟨first, after, constant, value, following⟩ := by
      simp only [declarationParts, modelFirst, modelAfter, modelConstant, modelPosition, hidden, ← evalue, ← efollowing]
    rw [stringDeclarationAt, parts]
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]

@[simp] theorem interpreted_scalarConstraint (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat)
    (names : ScalarExpression.Environment) (bound : ValidCursor text position)
    (environment : ScalarExpression.ValidEnvironment text names) :
    calls.function .scalarConstraint text position names = scalarConstraintAt text position names := by
  let rangeAfter := fixedAfter text position "range" true
  let low := ScalarExpression.read text rangeAfter names
  let highPosition := fixedAfter text low.after ".." false
  let high := ScalarExpression.read text highPosition names
  have brange : ValidCursor text rangeAfter := model_fixed_valid text position "range" true bound
  have blow := scalarRead_position_valid text rangeAfter names brange
  have bhighPosition : ValidCursor text highPosition := model_fixed_valid text low.after ".." false blow
  have elow := equations.scalarRead text valid rangeAfter names brange environment
  have ehigh := equations.scalarRead text valid highPosition names bhighPosition environment
  have emptyLow := equations.scalarEmpty low.bounds
    (ScalarExpression.Native.read_type valid brange (names := names) (maskFirst := 0) (maskAfter := 0) (allowSign := true)).2.1
  have emptyHigh := equations.scalarEmpty high.bounds
    (ScalarExpression.Native.read_type valid bhighPosition (names := names) (maskFirst := 0) (maskAfter := 0) (allowSign := true)).2.1
  have erange := interpreted_take calls equations text valid position (.word "range") bound
    (by unfold ValidToken; decide)
  have ehighPosition := interpreted_take calls equations text valid low.after (.symbol "..") blow
    (by unfold ValidToken; decide)
  change calls.function .takeToken text position (.word "range") = rangeAfter at erange
  change calls.function .takeToken text low.after (.symbol "..") = highPosition at ehighPosition
  rw [equations.scalarConstraint text valid position names bound environment, scalarConstraint_denotation]
  change scalarConstraintEquation calls text position names = _
  dsimp +zetaHave only [scalarConstraintEquation]
  rw [erange, elow, ehighPosition, ehigh, emptyLow, emptyHigh]
  simp only [scalarConstraintAt, rangeAfter, low, highPosition, high, Bool.or_eq_true, Bool.not_eq_true',
    decide_eq_true_eq, or_assoc]

@[simp] theorem interpreted_scalarDeclaration (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .scalarDeclaration text state arguments = scalarDeclarationAt text state arguments := by
  let first := declarationFirst text state
  let after := declarationAfter text state
  let colon := declarationColonAfter text state
  let constant := declarationConstantAfter text state
  let typeFirst := scalarDeclarationTypeFirst text state
  let typeAfter := scalarDeclarationTypeAfter text state
  let constraint := scalarConstraintAt text typeAfter state.scalarNames
  let position := scalarDeclarationValuePosition text state
  let value := ScalarExpression.read text position state.scalarNames
  let following := fixedAfter text value.after ";" false
  have bfirst : ValidCursor text first := model_skip_valid text state.position stateValid.1
  have bafter : ValidCursor text after := model_name_valid text first
  have bcolon : ValidCursor text colon := model_fixed_valid text after ":" false bafter
  have bconstant : ValidCursor text constant := model_fixed_valid text colon "constant" true bcolon
  have bchoice : ValidCursor text (if constant ≠ 0 then constant else colon) := by
    split <;> assumption
  have btypeFirst : ValidCursor text typeFirst := model_skip_valid text _ bchoice
  have btypeAfter : ValidCursor text typeAfter := model_fixed_valid text typeFirst "integer" true btypeFirst
  have bconstraint : ValidCursor text constraint.after := scalarConstraintAt_position_valid text typeAfter state.scalarNames btypeAfter
  have bposition : ValidCursor text position := model_fixed_valid text constraint.after ":=" false bconstraint
  have bvalue : ValidCursor text value.after ∧ value.bounds.Bounded := by
    by_cases zero : value.after = 0
    · have bounded := (ScalarExpression.Native.read_type valid bposition (names := state.scalarNames) (maskFirst := 0) (maskAfter := 0) (allowSign := true)).2.1
      exact ⟨by rw [zero]; exact Nat.zero_le _, bounded⟩
    · have positions := ScalarExpression.read_bounds bposition zero
      obtain ⟨expression, inferred, _, _⟩ := ScalarExpression.read_has_expression zero
      exact ⟨positions.2.1, Integer.Expr.infer_bounded inferred⟩
  have efirst : calls.function .skip text state.position = first := interpreted_skip calls equations text valid state.position stateValid.1
  have eafter : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bfirst
  have ecolon : calls.function .takeToken text after (.symbol ":") = colon := interpreted_take calls equations text valid after (.symbol ":") bafter (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = constant := interpreted_take calls equations text valid colon (.word "constant") bcolon (by unfold ValidToken; decide)
  have etypeFirst : calls.function .skip text (if constant ≠ 0 then constant else colon) = typeFirst := interpreted_skip calls equations text valid _ bchoice
  have etypeAfter : calls.function .takeToken text typeFirst (.word "integer") = typeAfter := interpreted_take calls equations text valid typeFirst (.word "integer") btypeFirst (by unfold ValidToken; decide)
  have econstraint : calls.function .scalarConstraint text typeAfter state.scalarNames = constraint := interpreted_scalarConstraint calls equations text valid typeAfter state.scalarNames btypeAfter stateValid.2.2.2.2.2
  have eposition : calls.function .takeToken text constraint.after (.symbol ":=") = position := interpreted_take calls equations text valid constraint.after (.symbol ":=") bconstraint (by unfold ValidToken; decide)
  have evalue : calls.function .scalarRead text position state.scalarNames = value := equations.scalarRead text valid position state.scalarNames bposition stateValid.2.2.2.2.2
  have efollowing : calls.function .takeToken text value.after (.symbol ";") = following := interpreted_take calls equations text valid value.after (.symbol ";") bvalue.1 (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  have estring := interpreted_lookup calls equations text valid state.names typeFirst typeAfter stateValid.2.1 btypeFirst btypeAfter
  have escalar := equations.scalarLookup text valid state.scalarNames typeFirst typeAfter stateValid.2.2.2.2.2 btypeFirst btypeAfter
  have eempty := equations.scalarEmpty value.bounds bvalue.2
  rw [equations.scalarDeclaration text valid state arguments stateValid, scalarDeclaration_denotation]
  change scalarDeclarationEquation calls text state arguments = _
  simp only [scalarDeclarationEquation, decideIf, efirst, eafter, ecolon, econstant, etypeFirst, etypeAfter, econstraint, eposition, evalue,
    efollowing, ename, estring, escalar, eempty]
  by_cases allowed : newNameAllowed text state first after arguments = true
  · have nameValid := model_new_name_valid text state first after arguments bafter allowed
    rw [equations.nameIs text valid first after "integer" nameValid (by decide) (by decide)]
    rw [declaration_nameIs_integer text state arguments first after rfl rfl allowed]
    by_cases full : state.scalarNames.length = ScalarExpression.maxBindings
    · simp [full, scalarDeclarationAt, scalarDeclarationParts, first, after, typeFirst, typeAfter,
        constraint, position, value, following, maxBindings, ScalarExpression.maxBindings, maxSourceLength]
    · have room : state.scalarNames.length < ScalarExpression.maxBindings := by
        have bound := stateValid.2.2.2.2.2.1
        omega
      rw [equations.scalarAppend state.scalarNames _ room]
      dsimp +instances only [scalarDeclarationAt, scalarDeclarationParts, addScalarBinding,
        first, after, constant, typeFirst, typeAfter, constraint, position, value, following,
        maxBindings, ScalarExpression.maxBindings, maxSourceLength]
      simp only [Bool.decide_or, Bool.or_assoc]
  · have rejected : newNameAllowed text state first after arguments = false := Bool.eq_false_iff.mpr allowed
    simp [rejected, scalarDeclarationAt, scalarDeclarationParts, first, after]

@[simp] theorem interpreted_declaration (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .declaration text state arguments = declarationAt text state arguments := by
  rw [equations.declaration text valid state arguments stateValid]
  dsimp +instances only [declarationBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, interpreted_scalarDeclaration calls equations text valid state arguments stateValid, interpreted_stringDeclaration calls equations text valid state arguments stateValid, decide_eq_true_eq]
  rfl

set_option backward.dsimp.instances true in
@[simp] theorem interpreted_argument (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .argument text state = argumentAt text state := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ stateValid.1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have efirst : first = skipAt text state.position := interpreted_skip calls equations text valid _ stateValid.1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  let p0 := calls.function .takeToken text after (.symbol ":")
  have bp0 : ValidCursor text p0 := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have ep0 : p0 = fixedAfter text after ":" false :=
    interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  let p1 := calls.function .takeToken text p0 (.word "constant")
  have bp1 : ValidCursor text p1 := equations.ranges.token text valid _ _ bp0 (by unfold ValidToken; decide)
  have ep1 : p1 = fixedAfter text p0 "constant" true :=
    interpreted_take calls equations text valid _ _ bp0 (by unfold ValidToken; decide)
  let p2 := calls.function .takeToken text p1 (.word "string")
  have bp2 : ValidCursor text p2 := equations.ranges.token text valid _ _ bp1 (by unfold ValidToken; decide)
  have ep2 : p2 = fixedAfter text p1 "string" true :=
    interpreted_take calls equations text valid _ _ bp1 (by unfold ValidToken; decide)
  let p3 := calls.function .takeToken text p2 (.symbol ":=")
  have bp3 : ValidCursor text p3 := equations.ranges.token text valid _ _ bp2 (by unfold ValidToken; decide)
  have ep3 : p3 = fixedAfter text p2 ":=" false :=
    interpreted_take calls equations text valid _ _ bp2 (by unfold ValidToken; decide)
  let nameCheck := calls.function .takeToken text first (.word "first_or_default")
  have echeck : nameCheck = fixedAfter text first "first_or_default" true :=
    interpreted_take calls equations text valid _ _ bfirst (by unfold ValidToken; decide)
  let hidden := (decide (first ≠ 0) && decide (after > first)) && decide (nameCheck = after)
  let p4 := calls.names.operationAfter text p3 .argument hidden
  have ep4 : p4 = Names.operationAfter text p3 .argument hidden :=
    Names.interpreted_operation calls.names equations.names text valid p3 .argument hidden bp3
  have bp4 : ValidCursor text p4 := by
    rw [ep4]
    exact Names.operationAfter_bound text p3 .argument hidden bp3
  let p5 := calls.function .takeToken text p4 (.symbol "(")
  have bp5 : ValidCursor text p5 := equations.ranges.token text valid _ _ bp4 (by unfold ValidToken; decide)
  have ep5 : p5 = fixedAfter text p4 "(" false :=
    interpreted_take calls equations text valid _ _ bp4 (by unfold ValidToken; decide)
  let p6 := calls.names.associationAfter text p5 true
  have ep6 : p6 = Names.associationAfter text p5 true :=
    Names.interpreted_association calls.names equations.names text valid p5 true bp5
  have bp6 : ValidCursor text p6 := by
    rw [ep6]
    exact Names.associationAfter_bound text p5 true bp5
  let defaultPosition := calls.function .skip text p6
  let fallback := calls.function .literal text defaultPosition
  let close := calls.function .takeToken text fallback.after (.symbol ")")
  let following := calls.function .takeToken text close (.symbol ";")
  have bdefault : ValidCursor text defaultPosition := equations.ranges.skip text valid _ bp6
  have bfallback : ValidValue text fallback := equations.ranges.literal text valid _ bdefault
  have bclose : ValidCursor text close := equations.ranges.token text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bclose (by unfold ValidToken; decide)
  have edefault : defaultPosition = skipAt text p6 := interpreted_skip calls equations text valid _ bp6
  have efallback : fallback = literalAt text defaultPosition := interpreted_literal calls equations text valid _ bdefault
  have eclose : close = fixedAfter text fallback.after ")" false := interpreted_take calls equations text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have efollowing : following = fixedAfter text close ";" false := interpreted_take calls equations text valid _ _ bclose (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after true stateValid bfirst bafter
  rw [equations.argument text valid state stateValid]
  dsimp +instances only [argumentBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  change (if !calls.function .newName text state first after true || decide (following = 0) ||
    decide (state.names.length ≠ 0) then invalidState
    else {calls.function .addBinding state first after ⟨following, 0, 0, 0, true, true, false, 0⟩ false following with
      dynamicFirst := first, dynamicAfter := after}) = _
  by_cases empty : state.names.length = 0
  · have room : state.names.length < maxBindings := by simp [empty, maxBindings, maxSourceLength]
    have bvalue : ValidValue text ⟨following, 0, 0, 0, true, true, false, 0⟩ := ⟨bfollowing, Nat.zero_le _, Nat.zero_le _, Nat.zero_le _, Nat.zero_le _⟩
    rw [interpreted_addBinding calls equations text valid state first after _ false following
      stateValid bfirst bafter bvalue bfollowing room, ename]
    simp only [efollowing, eclose, efallback, edefault, ep6, ep5, ep4, ep3, ep2, ep1, ep0, hidden, echeck, eafter, efirst]
    dsimp +instances only [argumentAt, argumentParts, argumentFirst, argumentAfter, argumentDefaultPosition,
      tokenAfter, ShellToken.word, ShellToken.symbol]
    simp [empty]
  · simp [empty, argumentAt]

@[simp] theorem interpreted_declarations (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .declarations text state arguments = declarationsAt text state arguments := by
  have etoken := interpreted_take calls equations text valid state.position (.word "begin") stateValid.1
    (by unfold ValidToken; decide)
  simp only [ShellToken.word, spelling, isWord] at etoken
  have edeclaration := interpreted_declaration calls equations text valid state arguments stateValid
  have nextValid : ValidState text (declarationAt text state arguments) := by
    rw [← edeclaration]
    exact (equations.ranges.declaration text valid state arguments stateValid).1
  rw [equations.declarations text valid state arguments stateValid]
  dsimp +instances only [declarationsBody, Expr.eval, Context.locals, lexical, Calls.get, Field.get]
  simp only [decide_eq_true_eq]
  simp only [etoken, edeclaration]
  rw [declarationsAt_equation text state arguments (by
    have strings := stateValid.2.1.1
    have scalars := stateValid.2.2.2.2.2.1
    change state.scalarNames.length ≤ maxBindings at scalars
    omega)]
  split
  · rfl
  · split
    · rfl
    · split
      · rfl
      · exact interpreted_declarations calls equations text valid (declarationAt text state arguments)
          arguments nextValid
termination_by 2 * maxBindings + 1 - (state.names.length + state.scalarNames.length)
decreasing_by
  have count := declarationAt_count (text := text) (state := state) (arguments := arguments) (by assumption)
  have _bounded := stateValid.2.1.1
  have nextBound := nextValid.2.1.1
  have nextScalarBound := nextValid.2.2.2.2.2.1
  change (declarationAt text state arguments).scalarNames.length ≤ maxBindings at nextScalarBound
  omega

@[simp] theorem interpreted_output (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .output text state = outputAt text state := by
  have resultValid := equations.ranges.expression text valid state.position state.names state.scalarNames false stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have evalue := interpreted_expression (integerHidden := false) calls equations text valid state.position state.names stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have efits := interpreted_fits calls equations text valid _ state.capacity resultValid stateValid.2.2.2.2.1
  rw [equations.output text valid state stateValid]
  dsimp +instances only [outputBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  rw [efits, evalue]
  cases h : fits (expressionAt text state.position state.names state.scalarNames) state.capacity <;> simp [outputAt, h]

@[simp] theorem interpreted_comparison (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .comparison text state = comparisonAt text state := by
  let lhs := calls.function .expression text state.position state.names state.scalarNames false
  let after := calls.function .takeToken text lhs.after (.symbol "=")
  let rhs := calls.function .expression text after state.names state.scalarNames false
  have blhs : ValidResult text lhs := equations.ranges.expression text valid _ _ state.scalarNames false stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have bafter : ValidCursor text after := equations.ranges.token text valid _ _ blhs.1 (by unfold ValidToken; decide)
  have brhs : ValidResult text rhs := equations.ranges.expression text valid _ _ state.scalarNames false bafter stateValid.2.1 stateValid.2.2.2.2.2
  have elhs : lhs = expressionAt text state.position state.names state.scalarNames :=
    interpreted_expression (integerHidden := false) calls equations text valid _ _ stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have eafter : after = fixedAfter text lhs.after "=" false :=
    interpreted_take calls equations text valid _ _ blhs.1 (by unfold ValidToken; decide)
  have erhs : rhs = expressionAt text after state.names state.scalarNames :=
    interpreted_expression (integerHidden := false) calls equations text valid _ _ bafter stateValid.2.1 stateValid.2.2.2.2.2
  have flhs := interpreted_fits calls equations text valid lhs state.capacity blhs stateValid.2.2.2.2.1
  have frhs := interpreted_fits calls equations text valid rhs state.capacity brhs stateValid.2.2.2.2.1
  rw [equations.comparison text valid state stateValid]
  dsimp +instances only [comparisonBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  change (if (!calls.function .fits lhs state.capacity || !calls.function .fits rhs state.capacity) ||
    !(lhs.namedSeen || rhs.namedSeen) then invalidState else {state with position := rhs.after}) = _
  rw [flhs, frhs, erhs, eafter, elhs]
  dsimp only [comparisonAt]
  generalize fits (expressionAt text state.position state.names state.scalarNames) state.capacity = a
  generalize fits (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames) state.capacity = b
  generalize (expressionAt text state.position state.names state.scalarNames).namedSeen = c
  generalize (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames).namedSeen = d
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

@[simp] theorem interpreted_target (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (sameTarget : Bool)
    (stateValid : ValidState text state) :
    calls.function .target text state sameTarget = targetAt text state sameTarget := by
  have skipBound := equations.ranges.skip text valid state.position stateValid.1
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid state.position stateValid.1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid state.names _ _ stateValid.2.1 skipBound nameBound
  rw [equations.target text valid state sameTarget stateValid]
  dsimp +instances only [targetBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [lookupEq, equations.scalarLookup text valid state.scalarNames _ _ stateValid.2.2.2.2.2 skipBound nameBound, nameEq, skipEq]
  simp [targetAt, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

@[simp] theorem interpreted_dynamic (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .dynamic text state = dynamicAt text state := by
  have skipBound := equations.ranges.skip text valid state.position stateValid.1
  have skipEq := interpreted_skip calls equations text valid state.position stateValid.1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  rw [equations.dynamic text valid state stateValid]
  dsimp +instances only [dynamicBody, Expr.eval, Context.locals, Locals.set, lexical, modelPrimitives, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [nameEq, skipEq]
  simp [dynamicAt, Bool.or_eq_true, or_assoc]

@[simp] theorem interpreted_assignmentValue (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .assignmentValue text state = assignmentAt text state := by
  have resultValid := equations.ranges.expression text valid state.position state.names state.scalarNames false stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have evalue := interpreted_expression (integerHidden := false) calls equations text valid state.position state.names stateValid.1 stateValid.2.1 stateValid.2.2.2.2.2
  have efits := interpreted_fits calls equations text valid _ state.capacity resultValid stateValid.2.2.2.2.1
  rw [equations.assignmentValue text valid state stateValid]
  dsimp +instances only [assignmentBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  rw [efits, evalue]
  simp only [assignmentAt, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]
  have reorder (a b c d e f : Prop) :
      (a ∨ b ∨ c ∨ d ∨ e ∨ f) ↔ (a ∨ c ∨ d ∨ b ∨ e ∨ f) := by
    simp only [or_left_comm]
  congr 1
  exact propext (reorder _ _ _ _ _ _)

@[simp] theorem interpreted_capacity (calls : Calls) (equations : HelperEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .capacity text state = capacityAt text state := by
  rw [equations.capacity text valid state stateValid]
  dsimp +instances only [capacityBody, Expr.eval, Context.locals, lexical, modelPrimitives, Field.get, capacityAt, skipAt]
  simp only [decide_eq_true_eq]
  by_cases zero : state.position = 0
  · simp [zero]
  · have positive : Cursor.triviaPosition text state.position ≠ 0 := by
      have lower := (Cursor.triviaPosition_bounds text state.position (by omega) stateValid.1).1
      omega
    simp [zero, positive]

end Silver.Compose.Expressions
