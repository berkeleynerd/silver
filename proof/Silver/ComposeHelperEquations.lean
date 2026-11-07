module

public import Silver.ComposeContracts
public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeStringHelperEquations
public import Silver.ComposeStringDeclarationEquation
public import Silver.ComposeNativeRecordBounds
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

@[simp] theorem interpreted_subtypeLookupModel (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain)) (text : Source) (valid : ValidText text)
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
    (equations : RawHelperEquations calls (domain := domain)) (text : Source) (valid : ValidText text)
    (subtypeNames : IntegerSubtypes.Environment) (first after : Nat)
    (namesValid : IntegerSubtypes.ValidEnvironment text subtypeNames)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .subtypeLookup text subtypeNames first after =
      IntegerSubtypes.lookup text subtypeNames first after := by
  rw [equations.subtypeLookup text valid subtypeNames first after namesValid firstValid afterValid]
  exact interpreted_subtypeLookupModel calls equations text valid subtypeNames first after
    subtypeNames.items.length namesValid firstValid afterValid (Nat.le_refl _)

@[simp] theorem interpreted_callAfter (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (position : Nat)
    (operation : Names.Operation) {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata} (namesValid : NativeNames text names) (bound : ValidCursor text position) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
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

@[simp] theorem interpreted_workTail (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
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
  have characterEq := interpreted_characterLiteral calls equations text valid (skipAt text position) firstBound
  rw [equations.workTail text valid position remaining bound remainingBound]
  dsimp +instances only [workTailBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, firstEq, quotedEq, nameEq, numberEq, characterEq, decide_eq_true_eq]
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
      by_cases characterAbsent : characterLiteralAfter text (skipAt text position) = 0
      · by_cases isQuote : Cursor.byteAt text (skipAt text position) = 34
        · by_cases absent : (literalAt text (skipAt text position)).after = 0
          · simp [characterAbsent, firstZero, finished, isQuote, absent]
          · have quotedAdvance := literalAt_advances text (skipAt text position) absent
            have quotedDecrease : text.length + 1 - (literalAt text (skipAt text position)).after <
                text.length + 1 - position := by omega
            simp only [characterAbsent, firstZero, finished, isQuote, absent, quotedDecrease, ↓reduceIte, ↓reduceDIte,
              ne_eq, not_false_eq_true, decide_true, Bool.true_and]
            exact interpreted_workTail calls equations text valid _ remaining quotedBound.base.1 remainingBound
        · by_cases nameNonzero : nameAfter text (skipAt text position) ≠ 0
          · have nameAdvance := model_name_advances text (skipAt text position) nameNonzero
            have nameDecrease : text.length + 1 - nameAfter text (skipAt text position) <
                text.length + 1 - position := by omega
            simp only [characterAbsent, firstZero, finished, isQuote, nameNonzero, nameDecrease, ↓reduceIte,
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
              simp only [characterAbsent, firstZero, finished, isQuote, nameNonzero, numberNonzero, numberDecrease, ↓reduceIte,
                ↓reduceDIte, ne_eq, not_false_eq_true]
              exact interpreted_workTail calls equations text valid _ remaining numberBounds.2.1 remainingBound
            · by_cases isComparison : Cursor.byteAt text (skipAt text position) = 47 ∧
                  skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61
              · have pairBound : ValidCursor text (skipAt text position + 2) := by unfold ValidCursor; omega
                have pairDecrease : text.length + 1 - (skipAt text position + 2) < text.length + 1 - position := by omega
                simp only [characterAbsent, firstZero, finished, nameNonzero, numberNonzero, isComparison,
                  pairDecrease, ↓reduceIte, ↓reduceDIte, ne_eq, decide_true, Bool.true_and]
                exact interpreted_workTail calls equations text valid _ remaining pairBound remainingBound
              · have comparisonFalse : ¬ (Cursor.byteAt text (skipAt text position) = 47 ∧
                    skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61) := isComparison
                simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc, comparisonFalse, ↓reduceIte]
                by_cases isOperator : Cursor.byteAt text (skipAt text position) = 38 ∨
                    Cursor.byteAt text (skipAt text position) = 43 ∨ Cursor.byteAt text (skipAt text position) = 45 ∨
                    Cursor.byteAt text (skipAt text position) = 42 ∨ Cursor.byteAt text (skipAt text position) = 47
                · by_cases empty : remaining = 0
                  · simp [characterAbsent, firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty]
                  · simp only [characterAbsent, firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, empty, plainDecrease,
                      ↓reduceIte, ↓reduceDIte, ne_eq, not_false_eq_true, decide_true, Bool.true_and]
                    exact interpreted_workTail calls equations text valid _ (remaining - 1) plainBound (by omega)
                · simp only [characterAbsent, firstZero, finished, isQuote, nameNonzero, numberNonzero, isOperator, plainDecrease, ↓reduceIte, ↓reduceDIte]
                  exact interpreted_workTail calls equations text valid _ remaining plainBound remainingBound
      · have advance := characterLiteralAfter_bounds characterAbsent
        have decrease : text.length + 1 - characterLiteralAfter text (skipAt text position) <
            text.length + 1 - position := by omega
        simp only [firstZero, finished, characterAbsent, decrease, ↓reduceIte, ↓reduceDIte,
          ne_eq, not_false_eq_true]
        exact interpreted_workTail calls equations text valid _ remaining advance.2 remainingBound

termination_by text.length + 1 - position
 decreasing_by all_goals assumption

@[simp] theorem interpreted_workBudget (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) :
    calls.function .workBudget text = withinWorkBudget text := by
  rw [equations.workBudget text valid]
  exact interpreted_workTail calls equations text valid 1 maxConcatenations (by unfold ValidCursor; omega) (Nat.le_refl _)

@[simp] theorem interpreted_image (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (integerHidden : Bool) {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {scalarNames : ScalarExpression.Environment}
    (bound : ValidCursor text position) (namesValid : NativeNames text names)
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
    rfl
  · have absent : parts.attributeFirst = 0 ∨ parts.attributeAfter ≤ parts.attributeFirst := by omega
    rcases absent with zero | reversed
    · simp [zero]
    · simp [reversed]

@[simp] theorem interpreted_value (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (namesValid : NativeNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
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
  rw [interpreted_take calls equations text valid (nameAfter text (skipAt text position)) (.symbol "(")
    (model_name_valid text _) (by unfold ValidToken; decide),
    interpreted_indexed calls equations text valid position names scalarNames arrays initials elaborating false
      bound namesValid scalarValid arraysValid initialsValid]
  rw [interpreted_image calls equations text valid position names integerHidden
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
    bound namesValid scalarValid arraysValid initialsValid]
  dsimp +instances only [spelling, isWord, ShellToken.symbol]
  simp only [valueAt, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, and_assoc]
  all_goals rfl

@[simp] theorem interpreted_newName (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (arguments : Bool)
    (stateValid : NativeState domain text state) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .newName text state first after arguments = newNameAllowed text state first after arguments := by
  rw [equations.newName text valid state first after arguments stateValid firstValid afterValid]
  dsimp +instances only [newNameBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get, newNameAllowed]
  simp only [interpreted_lookup calls equations text valid state.names first after stateValid.nativeNames firstValid afterValid, equations.scalarLookup text valid state.scalarNames first after stateValid.valid.2.2.2.2.2.1 firstValid afterValid, equations.arrayLookup text valid state.arrayNames.names first after (state_array_metadata stateValid.valid) firstValid afterValid, interpreted_subtypeLookup calls equations text valid state.subtypeNames first after stateValid.valid.2.2.2.2.2.2.2.1 firstValid afterValid, equations.booleanLookup text valid state.booleanNames first after stateValid.valid.booleans firstValid afterValid, equations.functionLookup text valid state.functions first after stateValid.valid.functions firstValid afterValid, equations.formalHides text valid state first after stateValid firstValid afterValid, Bool.and_assoc, Bool.decide_and]

@[simp] theorem interpreted_addBinding (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) (stateValid : NativeState domain text state)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after)
    (valueValid : NativeValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings)
    (bounds : fixedBoundsValid value.staticLength value.dynamicSeen false value.firstIndex.lower value.lastIndex.lower
      (state.names.length + 1) = true) :
    calls.function .addBinding state first after value mutable following = addBinding state first after value mutable following := by
  rw [equations.addBinding text valid state first after value mutable following stateValid firstValid afterValid valueValid followingValid room bounds]
  rfl

@[simp] theorem interpreted_characterDeclaration (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (context : NativeState domain text state) :
    calls.function .characterDeclaration text state arguments = characterDeclarationAt text state arguments := by
  let parts := characterDeclarationParts text state
  let colon := declarationColonAfter text state
  let start := fixedAfter text parts.typeAfter ":=" false
  have bf : ValidCursor text parts.first := model_skip_valid text state.position context.valid.1
  have ba : ValidCursor text parts.after := model_name_valid text parts.first
  have bc : ValidCursor text colon := model_fixed_valid text parts.after ":" false ba
  have bconstant : ValidCursor text parts.constantAfter := model_fixed_valid text colon "constant" true bc
  have bselected : ValidCursor text (if parts.constantAfter ≠ 0 then parts.constantAfter else colon) := by
    split <;> assumption
  have btypeFirst : ValidCursor text parts.typeFirst := model_skip_valid text _ bselected
  have btype : ValidCursor text parts.typeAfter := model_fixed_valid text parts.typeFirst "character" true btypeFirst
  have bstart : ValidCursor text start := model_fixed_valid text parts.typeAfter ":=" false btype
  have bv : ValidCursor text parts.value.after := model_character_after_valid text start state.names
    state.scalarNames state.arrayNames.names state.arrayNames.values true
  have bfollowing : ValidCursor text parts.following := model_fixed_valid text parts.value.after ";" false bv
  have efirst : calls.function .skip text state.position = parts.first :=
    interpreted_skip calls equations text valid state.position context.valid.1
  have eafter : calls.function .nameAfter text parts.first = parts.after :=
    interpreted_name calls equations text valid parts.first bf
  have ecolon : calls.function .takeToken text parts.after (.symbol ":") = colon :=
    interpreted_take calls equations text valid parts.after (.symbol ":") ba (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = parts.constantAfter :=
    interpreted_take calls equations text valid colon (.word "constant") bc (by unfold ValidToken; decide)
  have etypeFirst : calls.function .skip text
      (if parts.constantAfter ≠ 0 then parts.constantAfter else colon) = parts.typeFirst :=
    interpreted_skip calls equations text valid _ bselected
  have etype : calls.function .takeToken text parts.typeFirst (.word "character") = parts.typeAfter :=
    interpreted_take calls equations text valid parts.typeFirst (.word "character") btypeFirst (by unfold ValidToken; decide)
  have estart : calls.function .takeToken text parts.typeAfter (.symbol ":=") = start :=
    interpreted_take calls equations text valid parts.typeAfter (.symbol ":=") btype (by unfold ValidToken; decide)
  have evalue : calls.function .characterValue text start state.names state.scalarNames state.arrayNames.names
      state.arrayNames.values true = parts.value :=
    interpreted_characterValue calls equations text valid start state.names state.scalarNames state.arrayNames.names
      state.arrayNames.values true bstart context.nativeNames context.valid.2.2.2.2.2.1
      (state_array_metadata context.valid) (state_array_initials context.valid)
  have efollowing : calls.function .takeToken text parts.value.after (.symbol ";") = parts.following :=
    interpreted_take calls equations text valid parts.value.after (.symbol ";") bv (by unfold ValidToken; decide)
  rw [equations.characterDeclaration text valid state arguments context, characterDeclaration_denotation]
  change characterDeclarationEquation calls text state arguments = _
  dsimp only [characterDeclarationEquation]
  rw [efirst, eafter, ecolon, econstant]
  simp only [decide_eq_true_eq]
  rw [etypeFirst, etype, estart, evalue, efollowing,
    interpreted_newName calls equations text valid state parts.first parts.after arguments context bf ba,
    interpreted_lookup calls equations text valid state.names parts.typeFirst parts.typeAfter context.nativeNames btypeFirst btype,
    equations.scalarLookup text valid state.scalarNames parts.typeFirst parts.typeAfter
      context.valid.2.2.2.2.2.1 btypeFirst btype,
    equations.arrayLookup text valid state.arrayNames.names parts.typeFirst parts.typeAfter
      (state_array_metadata context.valid) btypeFirst btype,
    interpreted_subtypeLookup calls equations text valid state.subtypeNames parts.typeFirst parts.typeAfter
      context.valid.2.2.2.2.2.2.2.1 btypeFirst btype,
    equations.booleanLookup text valid state.booleanNames parts.typeFirst parts.typeAfter
      context.valid.booleans btypeFirst btype,
    equations.functionLookup text valid state.functions parts.typeFirst parts.typeAfter
      context.valid.functions btypeFirst btype,
    equations.formalHides text valid state parts.typeFirst parts.typeAfter context btypeFirst btype]
  by_cases typeAbsent : parts.typeAfter = 0
  · simp [typeAbsent, characterDeclarationAt, characterDeclarationRejected, parts]
  have typeName : ValidName text parts.typeFirst parts.typeAfter := by
    have present : fixedAfter text parts.typeFirst "character" true ≠ 0 := typeAbsent
    have positive := model_fixed_input_nonzero text _ "character" true present
    have advances := model_fixed_advances text _ "character" true btypeFirst (by decide) present
    exact ⟨by omega, advances, btype⟩
  rw [equations.nameIs text valid parts.typeFirst parts.typeAfter "integer" typeName (by decide) (by decide),
    equations.nameIs text valid parts.typeFirst parts.typeAfter "boolean" typeName (by decide) (by decide),
    equations.nameIs text valid parts.typeFirst parts.typeAfter "character" typeName (by decide) (by decide)]
  by_cases allowed : newNameAllowed text state parts.first parts.after arguments = true
  · have nameValid : ValidName text parts.first parts.after := by
      have parsed := allowed
      simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at parsed
      exact ⟨by omega, by omega, ba⟩
    rw [equations.nameIs text valid parts.first parts.after "character" nameValid (by decide) (by decide)]
    have nativeGuard := characterDeclaration_progress_guard text state arguments context.valid
    simp only [Bool.or_assoc] at nativeGuard
    simp only [Bool.or_assoc]
    rw [nativeGuard]
    change (if characterDeclarationRejected text state arguments parts then invalidState
      else calls.function .addBindingWithCharacter state parts.first parts.after parts.value
        (decide (parts.constantAfter = 0)) parts.following true) =
      (if characterDeclarationRejected text state arguments parts then invalidState
      else addBinding state parts.first parts.after parts.value
        (decide (parts.constantAfter = 0)) parts.following true)
    by_cases rejected : characterDeclarationRejected text state arguments parts = true
    · simp only [rejected, ↓reduceIte]
    · simp only [rejected, Bool.false_eq_true, ↓reduceIte]
      have conditions := rejected
      simp only [characterDeclarationRejected, Bool.or_eq_true, Bool.not_eq_true',
        decide_eq_true_eq, not_or] at conditions
      have following : parts.following ≠ 0 := by omega
      have present : parts.value.after ≠ 0 := by
        intro zero
        have same : parts.following = 0 := by change fixedAfter text parts.value.after ";" false = 0; simp [zero, fixedAfter]
        exact following same
      obtain ⟨expression, reading⟩ := character_sound start present
      have base := character_value_valid reading context.valid.2.1.1
      have endpoints := model_character_index_bounds text start state.names
        (scalarNames := state.scalarNames) (arrays := state.arrayNames.names)
        (initials := state.arrayNames.values) (elaborating := true)
      have native : NativeValue text parts.value :=
        ⟨base, (character_operands reading).2.2, endpoints.1, endpoints.2⟩
      have metadata : parts.value.dynamicSeen = false ∧ parts.value.minimumLength = 1 ∧
          parts.value.staticLength = 1 ∧ parts.value.emptyValue = false ∧
          parts.value.firstIndex = .singleton 1 ∧ parts.value.lastIndex = .singleton 1 :=
        character_metadata reading
      have room : state.names.length < maxBindings := by
        have count := context.valid.2.1.1
        have different : state.names.length ≠ maxBindings := by omega
        omega
      have bounds : fixedBoundsValid parts.value.staticLength parts.value.dynamicSeen true
          parts.value.firstIndex.lower parts.value.lastIndex.lower (state.names.length + 1) = true := by
        rw [metadata.1, metadata.2.2.1, metadata.2.2.2.2.1, metadata.2.2.2.2.2]
        simp [fixedBoundsValid, Integer.Interval.singleton]
      rw [equations.addBindingWithCharacter text valid state parts.first parts.after parts.value
        (decide (parts.constantAfter = 0)) parts.following true context bf ba native bfollowing room bounds]
      rfl
  · have rejected : newNameAllowed text state parts.first parts.after arguments = false := Bool.eq_false_iff.mpr allowed
    simp [rejected, characterDeclarationAt, characterDeclarationRejected, parts]

attribute [local irreducible] valueAt

@[simp] theorem interpreted_expressionStep (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : NativeNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) (scanValid : NativeScan text scan) :
    calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating = expressionStep text names scan scalarNames integerHidden arrays initials elaborating := by
  have eopen := interpreted_take calls equations text valid scan.position (.symbol "(") scanValid.base.1
    (by unfold ValidToken; decide)
  have ejoin := interpreted_take calls equations text valid scan.position (.symbol "&") scanValid.base.1
    (by unfold ValidToken; decide)
  have eclose := interpreted_take calls equations text valid scan.position (.symbol ")") scanValid.base.1
    (by unfold ValidToken; decide)
  have atom := interpreted_value (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) calls equations text valid scan.position names scanValid.base.1 namesValid scalarValid arraysValid initialsValid
  rw [equations.expressionStep text valid names scan scalarNames integerHidden arrays initials elaborating namesValid scalarValid arraysValid initialsValid scanValid]
  dsimp +instances only [expressionStepBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  simp only [ShellToken.symbol, spelling, isWord] at eopen ejoin eclose
  simp only [ShellToken.symbol]
  simp only [eopen, ejoin, eclose, atom]
  have atomValid := model_value_native text valid scan.position names
    (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
    (initials := initials) (elaborating := elaborating) namesValid
  rw [interpreted_concatenatedFirst calls equations text scan _ scanValid atomValid,
    interpreted_concatenatedLast calls equations text scan _ scanValid atomValid,
    equations.scalarEmpty _ (model_concatenated_first_bounded scan _ scanValid.firstIndex atomValid.firstIndex),
    equations.scalarEmpty _ (model_concatenated_last_bounded scan _ atomValid.lastIndex)]
  simp [expressionStep, Bool.or_eq_true, Bool.and_eq_true, or_assoc, and_assoc]

@[simp] theorem interpreted_tail (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (scan : ExpressionState) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (namesValid : NativeNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) (scanValid : NativeScan text scan) :
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
          have bounded := nextRange.1.base.1
          have smaller : text.length + 1 - (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position <
              text.length + 1 - scan.position := by
            unfold ValidCursor at bounded
            omega
          simp only [zero, complete, nextZero, nextComplete, smaller, ↓reduceIte, ↓reduceDIte]
          exact interpreted_tail (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) calls equations text valid names (expressionStep text names scan scalarNames integerHidden arrays initials elaborating)
            namesValid scalarValid arraysValid initialsValid nextRange.1
termination_by text.length + 1 - scan.position
 decreasing_by
  have nextBound := nextRange.1.base.1
  unfold ValidCursor at nextBound
  omega

@[simp] theorem interpreted_expression (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (bound : ValidCursor text position) (namesValid : NativeNames text names) (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .expression text position names scalarNames integerHidden arrays initials elaborating = expressionAt text position names scalarNames integerHidden arrays initials elaborating := by
  rw [equations.expression text valid position names scalarNames integerHidden arrays initials elaborating bound namesValid scalarValid arraysValid initialsValid]
  change calls.function .tail text names {position := position} scalarNames integerHidden arrays initials elaborating = expressionAt text position names scalarNames integerHidden arrays initials elaborating
  apply interpreted_tail calls equations text valid names _ namesValid scalarValid arraysValid initialsValid
  refine ⟨⟨bound, Nat.zero_le _, Nat.le_refl _, Nat.zero_le _, Nat.zero_le _, ?_, Nat.zero_le _⟩,
    by change (Integer.Interval.singleton 1).Bounded; decide,
    by change (Integer.Interval.singleton 0).Bounded; decide⟩
  change position = 0 ∨ 0 < position
  omega

@[simp] theorem interpreted_fits (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (result : ExpressionResult) (capacity : Nat)
    (resultValid : NativeResult text result) (capacityBound : capacity ≤ maxSourceLength) :
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

attribute [local irreducible] expressionAt

@[simp] theorem interpreted_stringDeclaration (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : NativeState domain text state) :
    calls.function .stringDeclaration text state arguments = stringDeclarationAt text state arguments := by
  let first := declarationFirst text state
  let after := declarationAfter text state
  let colon := declarationColonAfter text state
  let constant := declarationConstantAfter text state
  let typeAfter := fixedAfter text (if constant ≠ 0 then constant else colon) "string" true
  let valuePosition := declarationValuePosition text state
  let integerHidden := declarationIntegerHidden text state
  let value := expressionAt text valuePosition state.names state.scalarNames integerHidden
    state.arrayNames.names state.arrayNames.values true
  let following := fixedAfter text value.after ";" false
  have bfirst : ValidCursor text first := model_skip_valid text state.position stateValid.valid.1
  have bafter : ValidCursor text after := model_name_valid text first
  have bcolon : ValidCursor text colon := model_fixed_valid text after ":" false bafter
  have bconstant : ValidCursor text constant := model_fixed_valid text colon "constant" true bcolon
  have bselected : ValidCursor text (if constant ≠ 0 then constant else colon) := by split <;> assumption
  have btype : ValidCursor text typeAfter := model_fixed_valid text _ "string" true bselected
  have bposition : ValidCursor text valuePosition := model_fixed_valid text typeAfter ":=" false btype
  have efirst : calls.function .skip text state.position = first :=
    interpreted_skip calls equations text valid _ stateValid.valid.1
  have eafter : calls.function .nameAfter text first = after := interpreted_name calls equations text valid _ bfirst
  have ecolon : calls.function .takeToken text after (.symbol ":") = colon :=
    interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = constant :=
    interpreted_take calls equations text valid _ _ bcolon (by unfold ValidToken; decide)
  have etype : calls.function .takeToken text (if constant ≠ 0 then constant else colon) (.word "string") = typeAfter :=
    interpreted_take calls equations text valid _ _ bselected (by unfold ValidToken; decide)
  have eposition : calls.function .takeToken text typeAfter (.symbol ":=") = valuePosition :=
    interpreted_take calls equations text valid _ _ btype (by unfold ValidToken; decide)
  have evalue : calls.function .expression text valuePosition state.names state.scalarNames integerHidden
      state.arrayNames.names state.arrayNames.values true = value :=
    interpreted_expression (integerHidden := integerHidden) (arrays := state.arrayNames.names)
      (initials := state.arrayNames.values) (elaborating := true) calls equations text valid _ _ bposition
      stateValid.nativeNames stateValid.valid.2.2.2.2.2.1
      (state_array_metadata stateValid.valid) (state_array_initials stateValid.valid)
  have bvalue : NativeResult text value := by
    rw [← evalue]
    exact equations.ranges.expression text valid _ _ state.scalarNames integerHidden
      state.arrayNames.names state.arrayNames.values true bposition stateValid.nativeNames
      stateValid.valid.2.2.2.2.2.1 (state_array_metadata stateValid.valid) (state_array_initials stateValid.valid)
  have bfollowing : ValidCursor text following := model_fixed_valid text value.after ";" false bvalue.base.1
  have efollowing : calls.function .takeToken text value.after (.symbol ";") = following :=
    interpreted_take calls equations text valid _ _ bvalue.base.1 (by unfold ValidToken; decide)
  have efits := interpreted_fits calls equations text valid value maxSourceLength bvalue (Nat.le_refl _)
  have convertedValid : NativeValue text value.value :=
    ⟨⟨bvalue.base.1, Nat.zero_le _, bvalue.base.2.1, Nat.zero_le _, bvalue.base.2.2.2⟩,
      by change 1 ≤ maxExpressionOperands; decide, bvalue.firstIndex, bvalue.lastIndex⟩
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  have einteger := interpreted_take calls equations text valid first (.word "integer") bfirst
    (by unfold ValidToken; decide)
  have ebooleans := equations.booleanHidesInteger text valid state.booleanNames
    stateValid.valid.booleans
  have hidden : ((decide (first ≠ 0) && decide (after > first) &&
      decide (calls.function .takeToken text first (.word "integer") = after)) ||
      calls.function .booleanHidesInteger text state.booleanNames || state.hiding.integerHidden) = integerHidden := by
    rw [einteger, ebooleans]
    simp only [integerHidden, declarationIntegerHidden, Bool.decide_and, Bool.and_assoc,
      spelling, isWord, ShellToken.word, first, after]
    all_goals rfl
  have parts : declarationParts text state = ⟨first, after, constant, value, following⟩ := rfl
  rw [equations.stringDeclaration text valid state arguments stateValid,
    stringDeclaration_denotation]
  change stringDeclarationEquation calls text state arguments = _
  dsimp only [stringDeclarationEquation]
  rw [efirst, eafter, ecolon, econstant]
  simp only [decide_eq_true_eq]
  rw [etype, eposition, hidden, evalue, efollowing]
  change (if !calls.function .newName text state first after arguments || decide (following = 0) ||
      decide (state.names.length = maxBindings) || !calls.function .fits value maxSourceLength ||
      value.emptyValue || decide (value.minimumLength ≠ value.staticLength) ||
      (decide (value.dynamicCount = 0) &&
        (calls.function .scalarEmpty value.firstIndex || calls.function .scalarEmpty value.lastIndex ||
          decide (value.firstIndex.lower ≠ value.firstIndex.upper) ||
          decide (value.lastIndex.lower ≠ value.lastIndex.upper))) ||
      !calls.function .fixedBoundsValid value.staticLength (decide (value.dynamicCount = 1)) false
        value.firstIndex.lower value.lastIndex.lower (state.names.length + 1)
    then invalidState else calls.function .addBinding state first after value.value
      (decide (constant = 0)) following) = _
  rw [ename, efits, equations.scalarEmpty value.firstIndex bvalue.firstIndex,
    equations.scalarEmpty value.lastIndex bvalue.lastIndex, stringDeclarationAt, parts]
  by_cases full : state.names.length = maxBindings
  · simp [full]
  · have room : state.names.length < maxBindings := by have := stateValid.valid.2.1.1; omega
    rw [interpreted_fixedBounds calls equations value.staticLength (decide (value.dynamicCount = 1)) false
      value.firstIndex.lower value.lastIndex.lower (state.names.length + 1)
      bvalue.base.2.1 bvalue.firstIndex.1 bvalue.lastIndex.1 (by omega) (by omega)]
    by_cases safeBounds : fixedBoundsValid value.staticLength (decide (value.dynamicCount = 1)) false
        value.firstIndex.lower value.lastIndex.lower (state.names.length + 1) = true
    · rw [interpreted_addBinding calls equations text valid state first after value.value _ following
        stateValid bfirst bafter convertedValid bfollowing room safeBounds]
      simp only [fixedDeclarationBounds, safeBounds, Bool.not_true, Bool.and_true,
        Bool.not_not, Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]
      simp only [Bool.false_eq_true, or_false]
    · have noBounds := Bool.eq_false_iff.mpr safeBounds
      simp [fixedDeclarationBounds, noBounds]

@[simp] theorem interpreted_scalarConstraint (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
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

@[simp] theorem interpreted_scalarType (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (position : Nat)
    (stateValid : NativeState domain text state) (bound : ValidCursor text position) :
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
    stateValid.nativeNames firstBound afterBound
  have ec := equations.scalarLookup text valid state.scalarNames first after
    stateValid.valid.2.2.2.2.2.1 firstBound afterBound
  have ea := equations.arrayLookup text valid state.arrayNames.names first after
    (state_array_metadata stateValid.valid) firstBound afterBound
  have et := interpreted_subtypeLookup calls equations text valid state.subtypeNames first after
    stateValid.valid.2.2.2.2.2.2.2.1 firstBound afterBound
  have eb := equations.booleanLookup text valid state.booleanNames first after
    stateValid.valid.booleans firstBound afterBound
  have ef := equations.functionLookup text valid state.functions first after
    stateValid.valid.functions firstBound afterBound
  have eh := equations.formalHides text valid state first after stateValid firstBound afterBound
  rw [equations.scalarType text valid state position stateValid bound, scalarType_denotation]
  dsimp +instances only [scalarTypeEquation, lexical]
  rw [es, en, el, ec, ea, et, eb, ef, eh]
  by_cases invalid : first = 0 ∨ after ≤ first
  · rcases invalid with zero | backwards
    · have actualZero : skipAt text position = 0 := zero
      simp [scalarTypeAt, first, after, actualZero]
    · have actualBackwards : nameAfter text (skipAt text position) ≤ skipAt text position := backwards
      simp [scalarTypeAt, first, after, actualBackwards]
  · have nameValid : ValidName text first after := ⟨by omega, by omega, afterBound⟩
    rw [equations.nameIs text valid first after "integer" nameValid (by decide) (by decide)]
    dsimp +instances only [scalarTypeAt, after, first]
    simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

@[simp] theorem interpreted_subtypeDeclaration (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : NativeState domain text state) :
    calls.function .subtypeDeclaration text state arguments = subtypeDeclarationAt text state arguments := by
  let subtypeAfter := fixedAfter text state.position "subtype" true
  let first := skipAt text subtypeAfter
  let after := nameAfter text first
  let marker := fixedAfter text after "is" true
  let typeFirst := skipAt text marker
  let typeAfter := fixedAfter text typeFirst "integer" true
  let constraint := scalarConstraintAt text typeAfter state.scalarNames
  let following := fixedAfter text constraint.after ";" false
  have bp : ValidCursor text subtypeAfter := model_fixed_valid text state.position "subtype" true stateValid.valid.1
  have bf : ValidCursor text first := model_skip_valid text subtypeAfter bp
  have ba : ValidCursor text after := model_name_valid text first
  have bm : ValidCursor text marker := model_fixed_valid text after "is" true ba
  have btf : ValidCursor text typeFirst := model_skip_valid text marker bm
  have bta : ValidCursor text typeAfter := model_fixed_valid text typeFirst "integer" true btf
  have bc : ValidCursor text constraint.after := scalarConstraintAt_position_valid text typeAfter state.scalarNames bta
  have cp : constraint.bounds.Bounded := scalarConstraintAt_bounded_all text typeAfter state.scalarNames bta Integer.Interval.full_bounded
  have ep : calls.function .takeToken text state.position (.word "subtype") = subtypeAfter :=
    interpreted_take calls equations text valid state.position (.word "subtype") stateValid.valid.1 (by unfold ValidToken; decide)
  have ef : calls.function .skip text subtypeAfter = first := interpreted_skip calls equations text valid subtypeAfter bp
  have ea : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bf
  have em : calls.function .takeToken text after (.word "is") = marker :=
    interpreted_take calls equations text valid after (.word "is") ba (by unfold ValidToken; decide)
  have etf : calls.function .skip text marker = typeFirst := interpreted_skip calls equations text valid marker bm
  have eta : calls.function .takeToken text typeFirst (.word "integer") = typeAfter :=
    interpreted_take calls equations text valid typeFirst (.word "integer") btf (by unfold ValidToken; decide)
  have ec : calls.function .scalarConstraint text typeAfter state.scalarNames .full = constraint :=
    interpreted_scalarConstraint calls equations text valid typeAfter state.scalarNames bta
      stateValid.valid.2.2.2.2.2.1 .full Integer.Interval.full_bounded
  have ee : calls.function .takeToken text constraint.after (.symbol ";") = following :=
    interpreted_take calls equations text valid constraint.after (.symbol ";") bc (by unfold ValidToken; decide)
  have er := interpreted_take calls equations text valid typeAfter (.word "range") bta (by unfold ValidToken; decide)
  have en := interpreted_newName calls equations text valid state first after arguments stateValid bf ba
  have es := interpreted_lookup calls equations text valid state.names typeFirst typeAfter stateValid.nativeNames btf bta
  have ei := equations.scalarLookup text valid state.scalarNames typeFirst typeAfter stateValid.valid.2.2.2.2.2.1 btf bta
  have ear := equations.arrayLookup text valid state.arrayNames.names typeFirst typeAfter
    (state_array_metadata stateValid.valid) btf bta
  have ebool := equations.booleanLookup text valid state.booleanNames typeFirst typeAfter
    stateValid.valid.booleans btf bta
  have efunction := equations.functionLookup text valid state.functions typeFirst typeAfter
    stateValid.valid.functions btf bta
  have eformal := equations.formalHides text valid state typeFirst typeAfter stateValid btf bta
  have eb := equations.scalarEmpty constraint.bounds cp
  rw [equations.subtypeDeclaration text valid state arguments stateValid, subtypeDeclaration_denotation]
  change subtypeDeclarationEquation calls text state arguments = _
  dsimp only [subtypeDeclarationEquation]
  rw [ep, ef, ea, em, etf, eta, ec, ee, en, er, es, ei, ear, ebool, efunction, eformal, eb]
  by_cases typeAbsent : typeAfter = 0
  · have actualZero := typeAbsent
    dsimp only [subtypeAfter, first, after, marker, typeFirst, typeAfter] at actualZero
    simp only [typeAbsent, decide_true, Bool.or_true, Bool.true_or, ↓reduceIte]
    simp [subtypeDeclarationAt, subtypeDeclarationParts, actualZero]
  have typeName : ValidName text typeFirst typeAfter := by
    have positive := model_fixed_input_nonzero text typeFirst "integer" true typeAbsent
    have advance := model_fixed_advances text typeFirst "integer" true btf (by decide) typeAbsent
    exact ⟨by omega, advance, bta⟩
  rw [equations.nameIs text valid typeFirst typeAfter "integer" typeName (by decide) (by decide),
    equations.nameIs text valid typeFirst typeAfter "boolean" typeName (by decide) (by decide),
    equations.nameIs text valid typeFirst typeAfter "character" typeName (by decide) (by decide)]
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
    simp only [Bool.decide_coe, Bool.decide_or, Bool.or_assoc]
  · have rejected : newNameAllowed text state first after arguments = false := Bool.eq_false_iff.mpr allowed
    simp only [rejected, Bool.not_false, Bool.true_or, ↓reduceIte]
    dsimp only [after, first, subtypeAfter] at rejected
    simp only [subtypeDeclarationAt, subtypeDeclarationParts,
      rejected, Bool.not_false, Bool.true_or, ↓reduceIte]

@[simp] theorem interpreted_scalarDeclaration (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : NativeState domain text state) :
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
  have bfirst : ValidCursor text first := model_skip_valid text state.position stateValid.valid.1
  have bafter : ValidCursor text after := model_name_valid text first
  have bcolon : ValidCursor text colon := model_fixed_valid text after ":" false bafter
  have bconstant : ValidCursor text constant := model_fixed_valid text colon "constant" true bcolon
  have bchoice : ValidCursor text (if constant ≠ 0 then constant else colon) := by
    split <;> assumption
  have btypeFirst : ValidCursor text typeFirst := model_skip_valid text _ bchoice
  have btypeAfter : ValidCursor text typeAfter := scalarTypeAt_position_valid text state typeFirst
  have baseValid : typeMark.bounds.Bounded := scalarTypeAt_bounded text state typeFirst stateValid.valid.2.2.2.2.2.2.2.1
  have bconstraint : ValidCursor text constraint.after := scalarConstraintAt_position_valid text typeAfter state.scalarNames btypeAfter
  have bposition : ValidCursor text position := model_fixed_valid text constraint.after ":=" false bconstraint
  have bvalue : ValidCursor text value.after ∧ value.bounds.Bounded := by
    by_cases zero : value.after = 0
    · have bounded := (ScalarExpression.Native.read_type valid bposition (names := state.scalarNames) (maskFirst := 0) (maskAfter := 0) (allowSign := true) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)).2.1
      exact ⟨by rw [zero]; exact Nat.zero_le _, bounded⟩
    · have positions := ScalarExpression.read_arrays_bounds bposition zero
      obtain ⟨expression, inferred, _, _⟩ := ScalarExpression.read_arrays_has_expression bposition zero
      exact ⟨positions.2.1, Integer.Expr.infer_bounded inferred⟩
  have efirst : calls.function .skip text state.position = first := interpreted_skip calls equations text valid state.position stateValid.valid.1
  have eafter : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bfirst
  have ecolon : calls.function .takeToken text after (.symbol ":") = colon := interpreted_take calls equations text valid after (.symbol ":") bafter (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = constant := interpreted_take calls equations text valid colon (.word "constant") bcolon (by unfold ValidToken; decide)
  have etypeFirst : calls.function .skip text (if constant ≠ 0 then constant else colon) = typeFirst := interpreted_skip calls equations text valid _ bchoice
  have etypeMark : calls.function .scalarType text state typeFirst = typeMark :=
    interpreted_scalarType calls equations text valid state typeFirst stateValid btypeFirst
  have typeAfter_eq : typeMark.after = typeAfter := rfl
  have econstraint : calls.function .scalarConstraint text typeAfter state.scalarNames typeMark.bounds = constraint := interpreted_scalarConstraint calls equations text valid typeAfter state.scalarNames btypeAfter stateValid.valid.2.2.2.2.2.1 typeMark.bounds baseValid
  have eposition : calls.function .takeToken text constraint.after (.symbol ":=") = position := interpreted_take calls equations text valid constraint.after (.symbol ":=") bconstraint (by unfold ValidToken; decide)
  have evalue : calls.function .scalarRead text position state.scalarNames state.arrayNames.names state.arrayNames.values true = value := equations.scalarRead text valid position state.scalarNames state.arrayNames.names state.arrayNames.values true bposition stateValid.valid.2.2.2.2.2.1 (state_array_metadata stateValid.valid) (state_array_initials stateValid.valid)
  have efollowing : calls.function .takeToken text value.after (.symbol ";") = following := interpreted_take calls equations text valid value.after (.symbol ";") bvalue.1 (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  have estring := interpreted_lookup calls equations text valid state.names typeFirst typeAfter stateValid.nativeNames btypeFirst btypeAfter
  have escalar := equations.scalarLookup text valid state.scalarNames typeFirst typeAfter stateValid.valid.2.2.2.2.2.1 btypeFirst btypeAfter
  have earray := equations.arrayLookup text valid state.arrayNames.names typeFirst typeAfter (state_array_metadata stateValid.valid) btypeFirst btypeAfter
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
        have bound := stateValid.valid.2.2.2.2.2.1.1
        omega
      rw [equations.scalarAppend state.scalarNames _ room]
      dsimp +instances only [scalarDeclarationAt, scalarDeclarationParts, addScalarBinding,
        first, after, constant, typeFirst, typeAfter, typeMark, constraint, position, value, following,
        maxBindings, ScalarExpression.maxBindings, maxSourceLength]
      simp only [Bool.decide_or, Bool.or_assoc]
  · have rejected : newNameAllowed text state first after arguments = false := Bool.eq_false_iff.mpr allowed
    simp [rejected, scalarDeclarationAt, scalarDeclarationParts, first, after]

end Silver.Compose.Expressions
