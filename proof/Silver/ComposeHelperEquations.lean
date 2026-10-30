module

public import Silver.ComposeContracts
public import Silver.ComposeScalarDenotations
public import Silver.ComposeArrayDenotations
public import Silver.ComposeArrayNativeBounds
public import Silver.ComposeArrayModel
public import Silver.ComposeStateBounds
public import Silver.ComposeNameBridge
public import Silver.ScalarExpressionNativeTypes

@[expose] public section

/-! Interpret the recognizer's checked equations on its verified machine
 domains. Executable loop refinements supply equations for the same terminating
 traversals; no premise identifies the recognizer with language membership. -/

namespace Silver.Compose.Expressions
open Named

variable {domain : StateDomain}

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read scalarConstraintAt

private theorem state_array_metadata {text : Source} {state : ParserState}
    (valid : ValidState text state) : ArrayBindings.ValidMetadata text state.arrayNames.names :=
  valid.2.2.2.2.2.2.1.1

private theorem state_array_initials {text : Source} {state : ParserState}
    (valid : ValidState text state) : ArrayBindings.ValidInitials state.arrayNames.values :=
  valid.2.2.2.2.2.2.1.2.2.1

@[simp] theorem interpreted_skip (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .skip text position = skipAt text position := by
  rw [equations.skip text valid position bound]
  dsimp +instances only [skipBody, Expr.eval, Context.locals, lexical, modelPrimitives, skipAt]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_name (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .nameAfter text position = nameAfter text position := by
  rw [equations.name text valid position bound]
  dsimp +instances only [nameBody, Expr.eval, Context.locals, lexical, modelPrimitives, nameAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_fixed (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .fixedAfter text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.fixed text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_take (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .takeToken text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.take text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_literal (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .literal text position = literalAt text position := by
  rw [equations.literal text valid position bound]
  dsimp +instances only [literalBody, Expr.eval, Context.locals, lexical, modelPrimitives, literalAt]
  simp only [Bool.and_eq_true, and_assoc, decide_eq_true_eq]

@[simp] theorem interpreted_lookupFrom (calls : Calls) (equations : HelperEquations calls (domain := domain))
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

@[simp] theorem interpreted_lookup (calls : Calls) (equations : HelperEquations calls (domain := domain))
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

@[simp] theorem interpreted_subtypeLookupModel (calls : Calls)
    (equations : HelperEquations calls (domain := domain)) (text : Source) (valid : ValidText text)
    (subtypeNames : IntegerSubtypes.Environment) (first after index : Nat)
    (namesValid : IntegerSubtypes.ValidEnvironment text subtypeNames)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after)
    (indexBound : index ≤ subtypeNames.items.length) :
    calls.function .subtypeLookupModel text subtypeNames first after index =
      IntegerSubtypes.lookupFrom text subtypeNames first after index := by
  rw [equations.subtypeLookupModel text valid subtypeNames first after index namesValid firstValid afterValid indexBound]
  dsimp +instances only [subtypeLookupModelBody, Expr.eval, Context.locals, Calls.get, Field.get,
    lexical, modelPrimitives]
  cases index with
  | zero => simp [IntegerSubtypes.lookupFrom]
  | succ index =>
    rw [IntegerSubtypes.lookupFrom]
    by_cases absent : first = 0 ∨ after ≤ first
    · simp only [Bool.or_eq_true, decide_eq_true_eq, absent, true_or, ↓reduceIte]
    · simp only [Bool.or_eq_true, decide_eq_true_eq, absent, false_or,
        show index + 1 ≠ 0 by omega, ↓reduceIte]
      split
      · rfl
      · simpa only [Nat.add_sub_cancel] using
          interpreted_subtypeLookupModel calls equations text valid subtypeNames first after index
            namesValid firstValid afterValid (by omega)
termination_by index

@[simp] theorem interpreted_subtypeLookup (calls : Calls)
    (equations : HelperEquations calls (domain := domain)) (text : Source) (valid : ValidText text)
    (subtypeNames : IntegerSubtypes.Environment) (first after : Nat)
    (namesValid : IntegerSubtypes.ValidEnvironment text subtypeNames)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .subtypeLookup text subtypeNames first after =
      IntegerSubtypes.lookup text subtypeNames first after := by
  rw [equations.subtypeLookup text valid subtypeNames first after namesValid firstValid afterValid]
  exact interpreted_subtypeLookupModel calls equations text valid subtypeNames first after
    subtypeNames.items.length namesValid firstValid afterValid (Nat.le_refl _)

@[simp] theorem interpreted_callAfter (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (position : Nat)
    (operation : Names.Operation) {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata} (namesValid : ValidNames text names) (bound : ValidCursor text position) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (subtypeHidden : Bool)
    (booleans : BooleanBindings.Environment) (booleansValid : BooleanBindings.ValidEnvironment text booleans) :
    calls.function .callAfter text names position operation scalarNames arrays subtypeHidden booleans = callAfter text names position operation scalarNames arrays subtypeHidden booleans := by
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  have firstBound := equations.ranges.skip text valid position bound
  have afterBound := equations.ranges.name text valid first firstBound
  have firstEq : first = skipAt text position := interpreted_skip calls equations text valid position bound
  have afterEq : after = nameAfter text first := interpreted_name calls equations text valid first firstBound
  have lookupEq := interpreted_lookup calls equations text valid names first after namesValid firstBound afterBound
  rw [equations.callAfter text valid names position operation scalarNames arrays subtypeHidden booleans namesValid scalarValid arraysValid booleansValid bound]
  dsimp +instances only [callAfterBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [Names.interpreted_operation calls.names equations.names text valid position operation _ bound]
  change Names.operationAfter text position operation
    (decide (calls.function .lookupName text names first after ≠ 0) ||
      decide (calls.function .scalarLookup text scalarNames first after ≠ 0) ||
      decide (calls.function .arrayLookup text arrays first after ≠ 0) ||
      decide (calls.function .booleanLookup text booleans first after ≠ 0) || subtypeHidden) = _
  rw [lookupEq, equations.scalarLookup text valid scalarNames first after scalarValid firstBound afterBound,
    equations.arrayLookup text valid arrays first after arraysValid firstBound afterBound,
    equations.booleanLookup text valid booleans first after booleansValid firstBound afterBound, afterEq, firstEq]
  simp only [callAfter, Bool.decide_or, Bool.or_assoc]

@[simp] theorem interpreted_workTail (calls : Calls) (equations : HelperEquations calls (domain := domain))
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
          have validName : ValidName text (skipAt text position) (nameAfter text (skipAt text position)) := by
            exact ⟨nameAdvance.1, nameAdvance.2, nameBound⟩
          rw [equations.nameIs text valid _ _ "mod" validName (by decide) (by decide),
            equations.nameIs text valid _ _ "rem" validName (by decide) (by decide)]
          change (if Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position)) ("mod".toList.map Char.toNat) ||
              Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position)) ("rem".toList.map Char.toNat) then _ else _) = _
          split
          · by_cases empty : remaining = 0
            · simp only [empty, not_true_eq_false, decide_false, Bool.false_and, ↓reduceIte]
            · simp only [empty, not_false_eq_true, decide_true, Bool.true_and, ↓reduceIte]
              exact interpreted_workTail calls equations text valid _ (remaining - 1) nameBound (by omega)
          · exact interpreted_workTail calls equations text valid _ remaining nameBound remainingBound
        · by_cases numberNonzero : (ScalarLiteral.read text (skipAt text position)).after ≠ 0
          · have numberBounds := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound firstBound numberNonzero)
            have numberDecrease : text.length + 1 - (ScalarLiteral.read text (skipAt text position)).after <
                text.length + 1 - position := by omega
            simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, numberDecrease, ↓reduceIte,
              ↓reduceDIte, ne_eq, not_false_eq_true]
            exact interpreted_workTail calls equations text valid _ remaining numberBounds.2.1 remainingBound
          · by_cases isComparison : Cursor.byteAt text (skipAt text position) = 47 ∧
                skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61
            · have pairBound : ValidCursor text (skipAt text position + 2) := by unfold ValidCursor; omega
              have pairDecrease : text.length + 1 - (skipAt text position + 2) < text.length + 1 - position := by omega
              simp only [firstZero, finished, nameNonzero, numberNonzero, isComparison,
                pairDecrease, ↓reduceIte, ↓reduceDIte, ne_eq, decide_true, Bool.true_and]
              exact interpreted_workTail calls equations text valid _ remaining pairBound remainingBound
            · have comparisonFalse : ¬ (Cursor.byteAt text (skipAt text position) = 47 ∧
                  skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61) := isComparison
              simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc, comparisonFalse, ↓reduceIte]
              by_cases isOperator : Cursor.byteAt text (skipAt text position) = 38 ∨
                  Cursor.byteAt text (skipAt text position) = 43 ∨ Cursor.byteAt text (skipAt text position) = 45 ∨
                  Cursor.byteAt text (skipAt text position) = 42 ∨ Cursor.byteAt text (skipAt text position) = 47
              · by_cases empty : remaining = 0
                · simp [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty]
                · simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty, plainDecrease,
                    ↓reduceIte, ↓reduceDIte, ne_eq, not_false_eq_true, decide_true, Bool.true_and]
                  exact interpreted_workTail calls equations text valid _ (remaining - 1) plainBound (by omega)
              · simp only [firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, plainDecrease, ↓reduceIte, ↓reduceDIte]
                exact interpreted_workTail calls equations text valid _ remaining plainBound remainingBound
termination_by text.length + 1 - position
 decreasing_by all_goals assumption

@[simp] theorem interpreted_workBudget (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) :
    calls.function .workBudget text = withinWorkBudget text := by
  rw [equations.workBudget text valid]
  exact interpreted_workTail calls equations text valid 1 maxConcatenations (by unfold ValidCursor; omega) (Nat.le_refl _)

@[simp] theorem interpreted_image (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (integerHidden : Bool) {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {scalarNames : ScalarExpression.Environment}
    (bound : ValidCursor text position) (namesValid : ValidNames text names)
    (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .image text position names scalarNames integerHidden arrays initials elaborating =
      imageAt text position names scalarNames integerHidden arrays initials elaborating := by
  let parts := imageParts text position scalarNames arrays initials elaborating
  have bfirst : ValidCursor text parts.first := model_skip_valid text position bound
  have btype : ValidCursor text parts.typeAfter := model_fixed_valid text _ "integer" true bfirst
  have bapostrophe : ValidCursor text (fixedAfter text parts.typeAfter "'" false) :=
    model_fixed_valid text _ "'" false btype
  have battribute : ValidCursor text parts.attributeFirst := model_skip_valid text _ bapostrophe
  have bafter : ValidCursor text parts.attributeAfter := model_name_valid text _
  have bposition : ValidCursor text parts.scalarPosition := model_fixed_valid text _ "(" false bafter
  have bscalar : ValidCursor text parts.scalar.after ∧ parts.scalar.bounds.Bounded := by
    have typed := ScalarExpression.Native.read_type valid bposition
      (names := scalarNames) (maskFirst := 0) (maskAfter := 0) (allowSign := true) (arrays := arrays) (initials := initials) (elaborating := elaborating)
    refine ⟨?_, typed.2.1⟩
    by_cases zero : parts.scalar.after = 0
    · simp [ValidCursor, zero]
    · exact (ScalarExpression.read_arrays_bounds bposition zero).2.1
  have efirst : calls.function .skip text position = parts.first := interpreted_skip calls equations text valid position bound
  have etype : calls.function .takeToken text parts.first (.word "integer") = parts.typeAfter := interpreted_take calls equations text valid parts.first (.word "integer") bfirst (by unfold ValidToken; decide)
  have eapostrophe := interpreted_take calls equations text valid parts.typeAfter (.symbol "'") btype (by unfold ValidToken; decide)
  have eattribute : calls.function .skip text (fixedAfter text parts.typeAfter "'" false) = parts.attributeFirst := interpreted_skip calls equations text valid _ bapostrophe
  have eafter : calls.function .nameAfter text parts.attributeFirst = parts.attributeAfter := interpreted_name calls equations text valid parts.attributeFirst battribute
  have eposition : calls.function .takeToken text parts.attributeAfter (.symbol "(") = parts.scalarPosition := interpreted_take calls equations text valid parts.attributeAfter (.symbol "(") bafter (by unfold ValidToken; decide)
  have escalar : calls.function .scalarRead text parts.scalarPosition scalarNames arrays initials elaborating = parts.scalar := equations.scalarRead text valid parts.scalarPosition scalarNames arrays initials elaborating bposition scalarValid arraysValid initialsValid
  have efollowing : calls.function .takeToken text parts.scalar.after (.symbol ")") = parts.following := interpreted_take calls equations text valid parts.scalar.after (.symbol ")") bscalar.1 (by unfold ValidToken; decide)
  have elookup := interpreted_lookup calls equations text valid names parts.first parts.typeAfter namesValid bfirst btype
  have eslookup := equations.scalarLookup text valid scalarNames parts.first parts.typeAfter scalarValid bfirst btype
  have ealookup := equations.arrayLookup text valid arrays parts.first parts.typeAfter arraysValid bfirst btype
  simp only [ShellToken.word, ShellToken.symbol, spelling, isWord] at etype eapostrophe eposition efollowing
  rw [equations.image text valid position names scalarNames integerHidden arrays initials elaborating bound namesValid scalarValid arraysValid initialsValid]
  dsimp +instances only [imageBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  simp +instances only [ShellToken.word, ShellToken.symbol, efirst, etype, eapostrophe,
    eattribute, eafter, eposition, escalar, efollowing, elookup, eslookup, ealookup]
  rw [equations.imageMinimum _ bscalar.2, equations.imageMaximum _ bscalar.2,
    equations.scalarEmpty _ bscalar.2]
  change _ = if integerHidden || decide (parts.typeAfter = 0 ∨
      lookupName text names parts.first parts.typeAfter ≠ 0 ∨
      ScalarExpression.lookup text scalarNames parts.first parts.typeAfter ≠ 0 ∨
      ArrayBindings.lookup text arrays parts.first parts.typeAfter ≠ 0 ∨
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

@[simp] theorem interpreted_value (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .value text position names scalarNames integerHidden arrays initials elaborating = valueAt text position names scalarNames integerHidden arrays initials elaborating := by
  have skipBound := equations.ranges.skip text valid position bound
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid position bound
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have literalEq := interpreted_literal calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid names _ _ namesValid skipBound nameBound
  rw [equations.value text valid position names scalarNames integerHidden arrays initials elaborating bound namesValid scalarValid arraysValid initialsValid]
  dsimp +instances only [valueBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [literalEq, lookupEq, equations.scalarLookup text valid scalarNames _ _ scalarValid skipBound nameBound, nameEq, skipEq]
  rw [interpreted_image calls equations text valid position names integerHidden
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
    bound namesValid scalarValid arraysValid initialsValid]
  simp only [valueAt, Bool.and_eq_true, decide_eq_true_eq]

@[simp] theorem interpreted_newName (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (arguments : Bool)
    (stateValid : domain.holds text state) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .newName text state first after arguments = newNameAllowed text state first after arguments := by
  rw [equations.newName text valid state first after arguments stateValid firstValid afterValid]
  dsimp +instances only [newNameBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get, newNameAllowed]
  simp only [interpreted_lookup calls equations text valid state.names first after (domain.valid text state stateValid).2.1 firstValid afterValid, equations.scalarLookup text valid state.scalarNames first after (domain.valid text state stateValid).2.2.2.2.2.1 firstValid afterValid, equations.arrayLookup text valid state.arrayNames.names first after (state_array_metadata (domain.valid text state stateValid)) firstValid afterValid, interpreted_subtypeLookup calls equations text valid state.subtypeNames first after (domain.valid text state stateValid).2.2.2.2.2.2.2.1 firstValid afterValid, equations.booleanLookup text valid state.booleanNames first after (domain.valid text state stateValid).2.2.2.2.2.2.2.2 firstValid afterValid, Bool.and_assoc, Bool.decide_and]

@[simp] theorem interpreted_addBinding (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) (stateValid : domain.holds text state)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after)
    (valueValid : ValidValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings) :
    calls.function .addBinding state first after value mutable following = addBinding state first after value mutable following := by
  rw [equations.addBinding text valid state first after value mutable following stateValid firstValid afterValid valueValid followingValid room]
  rfl

@[simp] theorem interpreted_expressionStep (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) (scanValid : ValidScan text scan) :
    calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating = expressionStep text names scan scalarNames integerHidden arrays initials elaborating := by
  have eopen := interpreted_take calls equations text valid scan.position (.symbol "(") scanValid.1
    (by unfold ValidToken; decide)
  have ejoin := interpreted_take calls equations text valid scan.position (.symbol "&") scanValid.1
    (by unfold ValidToken; decide)
  have eclose := interpreted_take calls equations text valid scan.position (.symbol ")") scanValid.1
    (by unfold ValidToken; decide)
  have atom := interpreted_value (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) calls equations text valid scan.position names scanValid.1 namesValid scalarValid arraysValid initialsValid
  rw [equations.expressionStep text valid names scan scalarNames integerHidden arrays initials elaborating namesValid scalarValid arraysValid initialsValid scanValid]
  dsimp +instances only [expressionStepBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  simp only [ShellToken.symbol, spelling, isWord] at eopen ejoin eclose
  simp only [ShellToken.symbol]
  simp only [eopen, ejoin, eclose, atom]
  simp [expressionStep, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

@[simp] theorem interpreted_tail (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) (scanValid : ValidScan text scan) :
    calls.function .tail text names scan scalarNames integerHidden arrays initials elaborating = expressionTail text names scan scalarNames integerHidden arrays initials elaborating := by
  have stepEq := interpreted_expressionStep (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) calls equations text valid names scan namesValid scalarValid arraysValid initialsValid scanValid
  have nextRange := equations.ranges.expressionStep text valid names scan scalarNames integerHidden arrays initials elaborating namesValid scalarValid arraysValid initialsValid scanValid
  rw [stepEq] at nextRange
  rw [equations.tail text valid names scan scalarNames integerHidden arrays initials elaborating namesValid scalarValid arraysValid initialsValid scanValid]
  dsimp +instances only [tailBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte, stepEq, decide_eq_true_eq]
  rw [expressionTail]
  by_cases zero : scan.position = 0
  · simp [zero]
  · by_cases complete : scan.complete = true
    · simp [zero, complete, ExpressionState.result]
    · by_cases nextZero : (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position = 0
      · simp [zero, complete, nextZero]
      · by_cases nextComplete : (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).complete = true
        · simp [zero, complete, nextZero, nextComplete, ExpressionState.result]
        · have advances : scan.position < (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position := by
            rcases nextRange.2 with bad | done | progress
            · exact False.elim (nextZero bad)
            · exact False.elim (nextComplete done)
            · exact progress
          have bounded := nextRange.1.1
          have smaller : text.length + 1 - (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position <
              text.length + 1 - scan.position := by
            unfold ValidCursor at bounded
            omega
          simp only [zero, complete, nextZero, nextComplete, smaller, ↓reduceIte, ↓reduceDIte]
          exact interpreted_tail (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) calls equations text valid names (expressionStep text names scan scalarNames integerHidden arrays initials elaborating)
            namesValid scalarValid arraysValid initialsValid nextRange.1
termination_by text.length + 1 - scan.position
 decreasing_by
  have nextBound := nextRange.1.1
  unfold ValidCursor at nextBound
  omega

@[simp] theorem interpreted_expression (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (namesValid : ValidNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .expression text position names scalarNames integerHidden arrays initials elaborating = expressionAt text position names scalarNames integerHidden arrays initials elaborating := by
  rw [equations.expression text valid position names scalarNames integerHidden arrays initials elaborating bound namesValid scalarValid arraysValid initialsValid]
  change calls.function .tail text names {position := position} scalarNames integerHidden arrays initials elaborating = expressionAt text position names scalarNames integerHidden arrays initials elaborating
  apply interpreted_tail calls equations text valid names _ namesValid scalarValid arraysValid initialsValid
  refine ⟨bound, Nat.zero_le _, Nat.le_refl _, Nat.zero_le _, Nat.zero_le _, ?_, Nat.zero_le _⟩
  change position = 0 ∨ 0 < position
  omega

@[simp] theorem interpreted_fits (calls : Calls) (equations : HelperEquations calls (domain := domain))
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

@[simp] theorem interpreted_stringDeclaration (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : domain.holds text state) :
    calls.function .stringDeclaration text state arguments = stringDeclarationAt text state arguments := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := calls.function .takeToken text after (.symbol ":")
  let constant := calls.function .takeToken text colon (.word "constant")
  let typeAfter := calls.function .takeToken text (if constant ≠ 0 then constant else colon) (.word "string")
  let valuePosition := calls.function .takeToken text typeAfter (.symbol ":=")
  let integerHidden := (decide (first ≠ 0) && decide (after > first) &&
    decide (calls.function .takeToken text first (.word "integer") = after)) ||
    calls.function .booleanHidesInteger text state.booleanNames
  let value := calls.function .expression text valuePosition state.names state.scalarNames integerHidden state.arrayNames.names state.arrayNames.values true
  let following := calls.function .takeToken text value.after (.symbol ";")
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ (domain.valid text state stateValid).1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have bcolon : ValidCursor text colon := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have bconstant : ValidCursor text constant := equations.ranges.token text valid _ _ bcolon (by unfold ValidToken; decide)
  have btype : ValidCursor text typeAfter := equations.ranges.token text valid _ _
    (by split <;> assumption) (by unfold ValidToken; decide)
  have bposition : ValidCursor text valuePosition := equations.ranges.token text valid _ _ btype (by unfold ValidToken; decide)
  have bvalue : ValidResult text value := equations.ranges.expression text valid _ _ state.scalarNames integerHidden state.arrayNames.names state.arrayNames.values true bposition (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bvalue.1 (by unfold ValidToken; decide)
  have efirst : first = declarationFirst text state := interpreted_skip calls equations text valid _ (domain.valid text state stateValid).1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  have ecolon : colon = fixedAfter text after ":" false := interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  have econstant : constant = fixedAfter text colon "constant" true := interpreted_take calls equations text valid _ _ bcolon (by unfold ValidToken; decide)
  have etype : typeAfter = fixedAfter text (if constant ≠ 0 then constant else colon) "string" true :=
    interpreted_take calls equations text valid _ _ (by split <;> assumption) (by unfold ValidToken; decide)
  have eposition : valuePosition = fixedAfter text typeAfter ":=" false :=
    interpreted_take calls equations text valid _ _ btype (by unfold ValidToken; decide)
  have evalue : value = expressionAt text valuePosition state.names state.scalarNames integerHidden state.arrayNames.names state.arrayNames.values true := interpreted_expression (integerHidden := integerHidden) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) calls equations text valid _ _ bposition (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
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
  · have room : state.names.length < maxBindings := by have := (domain.valid text state stateValid).2.1.1; omega
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
      have booleans := equations.booleanHidesInteger text valid state.booleanNames
        (domain.valid text state stateValid).2.2.2.2.2.2.2.2
      simp only [declarationIntegerHidden, integerHidden, booleans, modelFirst, modelAfter, ShellToken.word, taken,
        Bool.decide_and, Bool.and_assoc]
    have parts : declarationParts text state = ⟨first, after, constant, value, following⟩ := by
      simp only [declarationParts, modelFirst, modelAfter, modelConstant, modelPosition, hidden, ← evalue, ← efollowing]
    rw [stringDeclarationAt, parts]
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]

@[simp] theorem interpreted_scalarConstraint (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat)
    (names : ScalarExpression.Environment) (bound : ValidCursor text position)
    (environment : ScalarExpression.ValidEnvironment text names) (baseBounds : Integer.Interval)
    (baseValid : baseBounds.Bounded) :
    calls.function .scalarConstraint text position names baseBounds = scalarConstraintAt text position names baseBounds := by
  let rangeAfter := fixedAfter text position "range" true
  let low := ScalarExpression.read text rangeAfter names
  let highPosition := fixedAfter text low.after ".." false
  let high := ScalarExpression.read text highPosition names
  have brange : ValidCursor text rangeAfter := model_fixed_valid text position "range" true bound
  have blow := scalarRead_position_valid text rangeAfter names brange
  have bhighPosition : ValidCursor text highPosition := model_fixed_valid text low.after ".." false blow
  have elow := equations.scalarRead text valid rangeAfter names [] [] false brange environment (by simp [ArrayBindings.ValidMetadata]) (by simp [ArrayBindings.ValidInitials])
  have ehigh := equations.scalarRead text valid highPosition names [] [] false bhighPosition environment (by simp [ArrayBindings.ValidMetadata]) (by simp [ArrayBindings.ValidInitials])
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
  rw [equations.scalarConstraint text valid position names baseBounds bound environment baseValid, scalarConstraint_denotation]
  change scalarConstraintEquation calls text position names baseBounds = _
  dsimp +zetaHave only [scalarConstraintEquation]
  rw [erange, elow, ehighPosition, ehigh, emptyLow, emptyHigh]
  simp only [scalarConstraintAt, rangeAfter, low, highPosition, high, Bool.or_eq_true, Bool.not_eq_true',
    decide_eq_true_eq, or_assoc]

@[simp] theorem interpreted_scalarType (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (position : Nat)
    (stateValid : domain.holds text state) (bound : ValidCursor text position) :
    calls.function .scalarType text state position = scalarTypeAt text state position := by
  let first := skipAt text position
  let after := nameAfter text first
  have firstBound : ValidCursor text first := model_skip_valid text position bound
  have afterBound : ValidCursor text after := model_name_valid text first
  have es : calls.function .skip text position = first :=
    interpreted_skip calls equations text valid position bound
  have en : calls.function .nameAfter text first = after :=
    interpreted_name calls equations text valid first firstBound
  have el := interpreted_lookup calls equations text valid state.names first after
    (domain.valid text state stateValid).2.1 firstBound afterBound
  have ec := equations.scalarLookup text valid state.scalarNames first after
    (domain.valid text state stateValid).2.2.2.2.2.1 firstBound afterBound
  have ea := equations.arrayLookup text valid state.arrayNames.names first after
    (state_array_metadata (domain.valid text state stateValid)) firstBound afterBound
  have et := interpreted_subtypeLookup calls equations text valid state.subtypeNames first after
    (domain.valid text state stateValid).2.2.2.2.2.2.2.1 firstBound afterBound
  have eb := equations.booleanLookup text valid state.booleanNames first after
    (domain.valid text state stateValid).2.2.2.2.2.2.2.2 firstBound afterBound
  rw [equations.scalarType text valid state position stateValid bound]
  dsimp +instances only [scalarTypeBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, es, en, el, ec, ea, et, eb]
  change (if decide (first = 0) || decide (after ≤ first) ||
      decide (lookupName text state.names first after ≠ 0) ||
      decide (ScalarExpression.lookup text state.scalarNames first after ≠ 0) ||
      decide (ArrayBindings.lookup text state.arrayNames.names first after ≠ 0) ||
      decide (BooleanBindings.lookup text state.booleanNames first after ≠ 0)
    then _ else _) = _
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]
  split
  · rename_i rejected
    dsimp only [after, first] at rejected
    simp only [scalarTypeAt, rejected, ↓reduceIte]
  · rename_i admitted
    have nameValid : ValidName text first after := ⟨by omega, by omega, afterBound⟩
    rw [equations.nameIs text valid first after "integer" nameValid (by decide) (by decide)]
    dsimp only [after, first] at admitted
    simp only [scalarTypeAt, admitted, ↓reduceIte, after, first]

@[simp] theorem interpreted_subtypeDeclaration (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : domain.holds text state) :
    calls.function .subtypeDeclaration text state arguments = subtypeDeclarationAt text state arguments := by
  let subtypeAfter := fixedAfter text state.position "subtype" true
  let first := skipAt text subtypeAfter
  let after := nameAfter text first
  let marker := fixedAfter text after "is" true
  let typeFirst := skipAt text marker
  let typeAfter := fixedAfter text typeFirst "integer" true
  let constraint := scalarConstraintAt text typeAfter state.scalarNames
  let following := fixedAfter text constraint.after ";" false
  have bp : ValidCursor text subtypeAfter := model_fixed_valid text state.position "subtype" true (domain.valid text state stateValid).1
  have bf : ValidCursor text first := model_skip_valid text subtypeAfter bp
  have ba : ValidCursor text after := model_name_valid text first
  have bm : ValidCursor text marker := model_fixed_valid text after "is" true ba
  have btf : ValidCursor text typeFirst := model_skip_valid text marker bm
  have bta : ValidCursor text typeAfter := model_fixed_valid text typeFirst "integer" true btf
  have bc : ValidCursor text constraint.after := scalarConstraintAt_position_valid text typeAfter state.scalarNames bta
  have cp : constraint.bounds.Bounded := scalarConstraintAt_bounded_all text typeAfter state.scalarNames bta Integer.Interval.full_bounded
  have ep : calls.function .takeToken text state.position (.word "subtype") = subtypeAfter :=
    interpreted_take calls equations text valid state.position (.word "subtype") (domain.valid text state stateValid).1 (by unfold ValidToken; decide)
  have ef : calls.function .skip text subtypeAfter = first := interpreted_skip calls equations text valid subtypeAfter bp
  have ea : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bf
  have em : calls.function .takeToken text after (.word "is") = marker :=
    interpreted_take calls equations text valid after (.word "is") ba (by unfold ValidToken; decide)
  have etf : calls.function .skip text marker = typeFirst := interpreted_skip calls equations text valid marker bm
  have eta : calls.function .takeToken text typeFirst (.word "integer") = typeAfter :=
    interpreted_take calls equations text valid typeFirst (.word "integer") btf (by unfold ValidToken; decide)
  have ec : calls.function .scalarConstraint text typeAfter state.scalarNames .full = constraint :=
    interpreted_scalarConstraint calls equations text valid typeAfter state.scalarNames bta
      (domain.valid text state stateValid).2.2.2.2.2.1 .full Integer.Interval.full_bounded
  have ee : calls.function .takeToken text constraint.after (.symbol ";") = following :=
    interpreted_take calls equations text valid constraint.after (.symbol ";") bc (by unfold ValidToken; decide)
  have er := interpreted_take calls equations text valid typeAfter (.word "range") bta (by unfold ValidToken; decide)
  have en := interpreted_newName calls equations text valid state first after arguments stateValid bf ba
  have es := interpreted_lookup calls equations text valid state.names typeFirst typeAfter (domain.valid text state stateValid).2.1 btf bta
  have ei := equations.scalarLookup text valid state.scalarNames typeFirst typeAfter (domain.valid text state stateValid).2.2.2.2.2.1 btf bta
  have ear := equations.arrayLookup text valid state.arrayNames.names typeFirst typeAfter
    (state_array_metadata (domain.valid text state stateValid)) btf bta
  have ebool := equations.booleanLookup text valid state.booleanNames typeFirst typeAfter
    (domain.valid text state stateValid).2.2.2.2.2.2.2.2 btf bta
  have eb := equations.scalarEmpty constraint.bounds cp
  rw [equations.subtypeDeclaration text valid state arguments stateValid, subtypeDeclaration_denotation]
  change subtypeDeclarationEquation calls text state arguments = _
  dsimp only [subtypeDeclarationEquation]
  rw [ep, ef, ea, em, etf, eta, ec, ee, en, er, es, ei, ear, ebool, eb]
  by_cases allowed : newNameAllowed text state first after arguments = true
  · have nameValid := model_new_name_valid text state first after arguments ba allowed
    have own := equations.nameIs text valid first after "integer" nameValid (by decide) (by decide)
    have operations : ∀ op : Names.Operation, calls.function .nameIs text first after op.name =
        Named.nameIs text first after (op.name.toList.map Char.toNat) := by
      intro op
      apply equations.nameIs text valid first after op.name nameValid <;> cases op <;> decide
    have trueName := equations.nameIs text valid first after "true" nameValid (by decide) (by decide)
    have falseName := equations.nameIs text valid first after "false" nameValid (by decide) (by decide)
    rw [own]
    simp only [operations, trueName, falseName]
    dsimp only [subtypeDeclarationAt, subtypeDeclarationParts, addSubtypeBinding,
      IntegerSubtypes.append, IntegerSubtypes.CallHiding.add, IntegerSubtypes.CallHiding.get,
      spelling, isWord, ShellToken.word,
      subtypeAfter, first, after, marker, typeFirst, typeAfter, constraint, following]
    simp only [Bool.decide_or, Bool.or_assoc]
  · have rejected : newNameAllowed text state first after arguments = false := Bool.eq_false_iff.mpr allowed
    simp only [rejected, Bool.not_false, Bool.true_or, ↓reduceIte]
    dsimp only [after, first, subtypeAfter] at rejected
    simp only [subtypeDeclarationAt, subtypeDeclarationParts,
      rejected, Bool.not_false, Bool.true_or, ↓reduceIte]

@[simp] theorem interpreted_scalarDeclaration (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : domain.holds text state) :
    calls.function .scalarDeclaration text state arguments = scalarDeclarationAt text state arguments := by
  let first := declarationFirst text state
  let after := declarationAfter text state
  let colon := declarationColonAfter text state
  let constant := declarationConstantAfter text state
  let typeFirst := scalarDeclarationTypeFirst text state
  let typeMark := scalarTypeAt text state typeFirst
  let typeAfter := scalarDeclarationTypeAfter text state
  let constraint := scalarConstraintAt text typeAfter state.scalarNames typeMark.bounds
  let position := scalarDeclarationValuePosition text state
  let value := ScalarExpression.read text position state.scalarNames 0 0 true state.arrayNames.names state.arrayNames.values true
  let following := fixedAfter text value.after ";" false
  have bfirst : ValidCursor text first := model_skip_valid text state.position (domain.valid text state stateValid).1
  have bafter : ValidCursor text after := model_name_valid text first
  have bcolon : ValidCursor text colon := model_fixed_valid text after ":" false bafter
  have bconstant : ValidCursor text constant := model_fixed_valid text colon "constant" true bcolon
  have bchoice : ValidCursor text (if constant ≠ 0 then constant else colon) := by
    split <;> assumption
  have btypeFirst : ValidCursor text typeFirst := model_skip_valid text _ bchoice
  have btypeAfter : ValidCursor text typeAfter := scalarTypeAt_position_valid text state typeFirst
  have baseValid : typeMark.bounds.Bounded := scalarTypeAt_bounded text state typeFirst (domain.valid text state stateValid).2.2.2.2.2.2.2
  have bconstraint : ValidCursor text constraint.after := scalarConstraintAt_position_valid text typeAfter state.scalarNames btypeAfter
  have bposition : ValidCursor text position := model_fixed_valid text constraint.after ":=" false bconstraint
  have bvalue : ValidCursor text value.after ∧ value.bounds.Bounded := by
    by_cases zero : value.after = 0
    · have bounded := (ScalarExpression.Native.read_type valid bposition (names := state.scalarNames) (maskFirst := 0) (maskAfter := 0) (allowSign := true) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)).2.1
      exact ⟨by rw [zero]; exact Nat.zero_le _, bounded⟩
    · have positions := ScalarExpression.read_arrays_bounds bposition zero
      obtain ⟨expression, inferred, _, _⟩ := ScalarExpression.read_arrays_has_expression bposition zero
      exact ⟨positions.2.1, Integer.Expr.infer_bounded inferred⟩
  have efirst : calls.function .skip text state.position = first := interpreted_skip calls equations text valid state.position (domain.valid text state stateValid).1
  have eafter : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bfirst
  have ecolon : calls.function .takeToken text after (.symbol ":") = colon := interpreted_take calls equations text valid after (.symbol ":") bafter (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = constant := interpreted_take calls equations text valid colon (.word "constant") bcolon (by unfold ValidToken; decide)
  have etypeFirst : calls.function .skip text (if constant ≠ 0 then constant else colon) = typeFirst := interpreted_skip calls equations text valid _ bchoice
  have etypeMark : calls.function .scalarType text state typeFirst = typeMark :=
    interpreted_scalarType calls equations text valid state typeFirst stateValid btypeFirst
  have typeAfter_eq : typeMark.after = typeAfter := rfl
  have econstraint : calls.function .scalarConstraint text typeAfter state.scalarNames typeMark.bounds = constraint := interpreted_scalarConstraint calls equations text valid typeAfter state.scalarNames btypeAfter (domain.valid text state stateValid).2.2.2.2.2.1 typeMark.bounds baseValid
  have eposition : calls.function .takeToken text constraint.after (.symbol ":=") = position := interpreted_take calls equations text valid constraint.after (.symbol ":=") bconstraint (by unfold ValidToken; decide)
  have evalue : calls.function .scalarRead text position state.scalarNames state.arrayNames.names state.arrayNames.values true = value := equations.scalarRead text valid position state.scalarNames state.arrayNames.names state.arrayNames.values true bposition (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have efollowing : calls.function .takeToken text value.after (.symbol ";") = following := interpreted_take calls equations text valid value.after (.symbol ";") bvalue.1 (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  have estring := interpreted_lookup calls equations text valid state.names typeFirst typeAfter (domain.valid text state stateValid).2.1 btypeFirst btypeAfter
  have escalar := equations.scalarLookup text valid state.scalarNames typeFirst typeAfter (domain.valid text state stateValid).2.2.2.2.2.1 btypeFirst btypeAfter
  have earray := equations.arrayLookup text valid state.arrayNames.names typeFirst typeAfter (state_array_metadata (domain.valid text state stateValid)) btypeFirst btypeAfter
  have eempty := equations.scalarEmpty value.bounds bvalue.2
  rw [equations.scalarDeclaration text valid state arguments stateValid, scalarDeclaration_denotation]
  change scalarDeclarationEquation calls text state arguments = _
  simp only [scalarDeclarationEquation, decideIf, efirst, eafter, ecolon, econstant, etypeFirst, etypeMark, typeAfter_eq, econstraint, eposition, evalue,
    efollowing, ename, estring, escalar, earray, eempty]
  by_cases allowed : newNameAllowed text state first after arguments = true
  · have nameValid := model_new_name_valid text state first after arguments bafter allowed
    rw [equations.nameIs text valid first after "integer" nameValid (by decide) (by decide)]
    rw [declaration_nameIs_integer text state arguments first after rfl rfl allowed]
    by_cases full : state.scalarNames.length = ScalarExpression.maxBindings
    · simp [full, scalarDeclarationAt, scalarDeclarationParts, first, after, typeFirst, typeAfter, typeMark,
        constraint, position, value, following, ScalarExpression.maxBindings]
    · have room : state.scalarNames.length < ScalarExpression.maxBindings := by
        have bound := (domain.valid text state stateValid).2.2.2.2.2.1.1
        omega
      rw [equations.scalarAppend state.scalarNames _ room]
      dsimp +instances only [scalarDeclarationAt, scalarDeclarationParts, addScalarBinding,
        first, after, constant, typeFirst, typeAfter, typeMark, constraint, position, value, following,
        maxBindings, ScalarExpression.maxBindings, maxSourceLength]
      simp only [Bool.decide_or, Bool.or_assoc]
  · have rejected : newNameAllowed text state first after arguments = false := Bool.eq_false_iff.mpr allowed
    simp [rejected, scalarDeclarationAt, scalarDeclarationParts, first, after]

end Silver.Compose.Expressions
