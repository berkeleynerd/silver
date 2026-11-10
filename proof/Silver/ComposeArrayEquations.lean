module

public import Silver.ComposeHelperEquations

@[expose] public section

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

private theorem decideIf {α : Type} (p : Prop) [Decidable p] (yes no : α) :
    (if decide p then yes else no) = (if p then yes else no) := by simp

theorem interpreted_arrayValuesModel (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (source result : ParserState)
    (position length parsed : Nat) (componentBounds : Integer.Interval)
    (componentsBounded : componentBounds.Bounded)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    calls.function .arrayValuesModel text source result position length parsed componentBounds =
      arrayValuesModel text source result position length parsed componentBounds := by
  rw [equations.arrayValuesModel text valid source result position length parsed componentBounds componentsBounded context,
    arrayValues_denotation]
  conv => rhs; rw [arrayValuesModel]
  unfold arrayValuesEquation
  dsimp only [lexical]
  simp only [decide_eq_true_eq]
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases done : parsed = length
    · subst parsed
      simp only [Nat.lt_irrefl, ↓reduceDIte, ↓reduceIte]
    · have remaining : parsed < length := by have bound := context.parsedBound; omega
      simp only [done, remaining, ↓reduceIte, ↓reduceDIte]
      let value := ScalarExpression.read text position source.scalarNames
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values) (elaborating := true)
      have same : calls.function .scalarRead text position source.scalarNames
          source.arrayNames.names source.arrayNames.values true = value :=
        equations.scalarRead text valid position source.scalarNames source.arrayNames.names
          source.arrayNames.values true context.positionValid context.sourceValid.2.2.2.2.2.1
          (state_array_metadata context.sourceValid) (state_array_initials context.sourceValid)
      rw [same]
      change (if decide (value.after = 0) || calls.function .scalarEmpty value.bounds ||
          decide (value.bounds.lower ≠ value.bounds.upper) ||
          decide (value.bounds.lower < componentBounds.lower) ||
          decide (value.bounds.upper > componentBounds.upper) then invalidState else _) =
        (if value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
          value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
          then invalidState else _)
      by_cases absent : value.after = 0
      · simp only [absent, decide_true, Bool.true_or, ↓reduceIte, true_or]
      · obtain ⟨expression, reading⟩ := ScalarExpression.read_sound context.positionValid absent
        have bounded : value.bounds.Bounded := Integer.Expr.infer_bounded reading.inferred
        rw [equations.scalarEmpty value.bounds bounded]
        simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]
        by_cases rejected : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
          value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
        · simp only [rejected, ↓reduceIte]
        · simp only [rejected, ↓reduceIte]
          have written := equations.arrayPut result value.bounds.lower (context.room remaining) bounded.1
          rw [arrayPut_denotation] at written
          rw [written]
          have comma := interpreted_take calls equations text valid value.after (.symbol ",")
            reading.cursorBounds.2.2 (by unfold ValidToken; decide)
          rw [comma]
          let following := if parsed + 1 < length then fixedAfter text value.after "," false else value.after
          have nextPosition : ValidCursor text following := by
            dsimp only [following]
            split
            · exact model_fixed_valid text value.after "," false reading.cursorBounds.2.2
            · exact reading.cursorBounds.2.2
          exact interpreted_arrayValuesModel calls equations text valid source
            (putArrayValue result value.bounds.lower) following length (parsed + 1) componentBounds componentsBounded
            (context.next remaining bounded.1 nextPosition)
termination_by length - parsed
decreasing_by omega

theorem interpreted_arrayValues (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (source result : ParserState)
    (position length parsed : Nat) (componentBounds : Integer.Interval)
    (componentsBounded : componentBounds.Bounded)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    calls.function .arrayValues text source result position length parsed componentBounds =
      arrayValuesModel text source result position length parsed componentBounds :=
  (equations.arrayValues text valid source result position length parsed componentBounds componentsBounded context).trans
    (interpreted_arrayValuesModel calls equations text valid source result position length parsed componentBounds componentsBounded context)

theorem interpreted_booleanArrayValuesModel (calls : Calls)
    (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (mask : (⟨maskFirst, maskAfter⟩ : NameState).Valid text)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    calls.function .booleanArrayValuesModel text source result position length parsed maskFirst maskAfter =
      booleanArrayValuesModel text source result position length parsed maskFirst maskAfter := by
  rw [equations.booleanArrayValuesModel text valid source result position length parsed maskFirst maskAfter mask context,
    booleanArrayValues_denotation]
  conv => rhs; rw [booleanArrayValuesModel]
  unfold booleanArrayValuesEquation
  dsimp only [lexical]
  simp only [decide_eq_true_eq]
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases done : parsed = length
    · subst parsed
      simp only [Nat.lt_irrefl, ↓reduceDIte, ↓reduceIte]
    · have remaining : parsed < length := by have bound := context.parsedBound; omega
      simp only [done, remaining, ↓reduceIte, ↓reduceDIte]
      rw [equations.booleanInitializer text valid source position maskFirst maskAfter
        context.sourceContext context.positionValid mask]
      by_cases failed : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [failed, ↓reduceIte]
      · simp only [failed, ↓reduceIte]
        have written := equations.arrayPut result 0 (context.room remaining) (by decide +kernel)
        rw [arrayPut_denotation] at written
        rw [written]
        have bound := model_booleanInitializer_bound text valid source position maskFirst maskAfter
          context.sourceValid.2.1 context.positionValid
        have comma := interpreted_take calls equations.toRawHelperEquations text valid _ (.symbol ",")
          bound (by unfold ValidToken; decide)
        rw [comma]
        let following := if parsed + 1 < length then fixedAfter text
          (booleanInitializerAfter text source position maskFirst maskAfter) "," false
          else booleanInitializerAfter text source position maskFirst maskAfter
        have nextPosition : ValidCursor text following := by
          dsimp only [following]
          split
          · exact model_fixed_valid text _ "," false bound
          · exact bound
        exact interpreted_booleanArrayValuesModel calls equations text valid source (putArrayValue result 0)
          following length (parsed + 1) maskFirst maskAfter mask
          (context.next remaining (by decide +kernel) nextPosition)
termination_by length - parsed
decreasing_by omega

theorem interpreted_booleanArrayValues (calls : Calls)
    (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (mask : (⟨maskFirst, maskAfter⟩ : NameState).Valid text)
    (context : ArrayValuesDomain text source result position length parsed domain) :
    calls.function .booleanArrayValues text source result position length parsed maskFirst maskAfter =
      booleanArrayValuesModel text source result position length parsed maskFirst maskAfter :=
  (equations.booleanArrayValues text valid source result position length parsed maskFirst maskAfter mask context).trans
    (interpreted_booleanArrayValuesModel calls equations text valid source result position length parsed maskFirst maskAfter mask context)

theorem interpreted_arrayParts (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : NativeState domain text state) :
    arrayPartsEquation calls text state = arrayDeclarationParts text state := by
  let first := declarationFirst text state
  let after := declarationAfter text state
  let colon := declarationColonAfter text state
  let constant := declarationConstantAfter text state
  let arrayAfter := fixedAfter text (if constant ≠ 0 then constant else colon) "array" true
  let lowStart := fixedAfter text arrayAfter "(" false
  let low := ScalarExpression.read text lowStart state.scalarNames 0 0 true
    state.arrayNames.names state.arrayNames.values true
  let highStart := fixedAfter text low.after ".." false
  let high := ScalarExpression.read text highStart state.scalarNames 0 0 true
    state.arrayNames.names state.arrayNames.values true
  let close := fixedAfter text high.after ")" false
  let ofAfter := fixedAfter text close "of" true
  let typeFirst := skipAt text ofAfter
  let integerType := scalarTypeAt text state typeFirst
  let isBoolean := decide (integerType.after = 0) && decide (fixedAfter text typeFirst "boolean" true ≠ 0)
  let typeMark := if isBoolean then (⟨fixedAfter text typeFirst "boolean" true, Integer.Interval.full⟩ : ScalarConstraintResult) else integerType
  let typeAfter := typeMark.after
  let assigned := fixedAfter text typeAfter ":=" false
  let position := fixedAfter text assigned "(" false
  have bfirst : ValidCursor text first := model_skip_valid text state.position stateValid.valid.1
  have bafter : ValidCursor text after := model_name_valid text first
  have bcolon : ValidCursor text colon := model_fixed_valid text after ":" false bafter
  have bconstant : ValidCursor text constant := model_fixed_valid text colon "constant" true bcolon
  have bselected : ValidCursor text (if constant ≠ 0 then constant else colon) := by split <;> assumption
  have barray : ValidCursor text arrayAfter := model_fixed_valid text _ "array" true bselected
  have blowStart : ValidCursor text lowStart := model_fixed_valid text arrayAfter "(" false barray
  have blow := model_arrayScalar_valid text lowStart state.scalarNames state.arrayNames.names state.arrayNames.values true blowStart
  have bhighStart : ValidCursor text highStart := model_fixed_valid text low.after ".." false blow.1
  have bhigh := model_arrayScalar_valid text highStart state.scalarNames state.arrayNames.names state.arrayNames.values true bhighStart
  have bclose : ValidCursor text close := model_fixed_valid text high.after ")" false bhigh.1
  have bof : ValidCursor text ofAfter := model_fixed_valid text close "of" true bclose
  have btypeFirst : ValidCursor text typeFirst := model_skip_valid text ofAfter bof
  have btypeAfter : ValidCursor text typeAfter := by
    dsimp only [typeAfter, typeMark]
    split
    · exact model_fixed_valid text typeFirst "boolean" true btypeFirst
    · exact scalarTypeAt_position_valid text state typeFirst
  have bassigned : ValidCursor text assigned := model_fixed_valid text typeAfter ":=" false btypeAfter
  have efirst : calls.function .skip text state.position = first := interpreted_skip calls equations text valid state.position stateValid.valid.1
  have eafter : calls.function .nameAfter text first = after := interpreted_name calls equations text valid first bfirst
  have ecolon : calls.function .takeToken text after (.symbol ":") = colon := interpreted_take calls equations text valid after (.symbol ":") bafter (by unfold ValidToken; decide)
  have econstant : calls.function .takeToken text colon (.word "constant") = constant := interpreted_take calls equations text valid colon (.word "constant") bcolon (by unfold ValidToken; decide)
  have earray : calls.function .takeToken text (if constant ≠ 0 then constant else colon) (.word "array") = arrayAfter := interpreted_take calls equations text valid _ (.word "array") bselected (by unfold ValidToken; decide)
  have elowStart : calls.function .takeToken text arrayAfter (.symbol "(") = lowStart := interpreted_take calls equations text valid arrayAfter (.symbol "(") barray (by unfold ValidToken; decide)
  have elow : calls.function .scalarRead text lowStart state.scalarNames state.arrayNames.names state.arrayNames.values true = low := equations.scalarRead text valid lowStart state.scalarNames state.arrayNames.names state.arrayNames.values true blowStart stateValid.valid.2.2.2.2.2.1 (state_array_metadata stateValid.valid) (state_array_initials stateValid.valid)
  have ehighStart : calls.function .takeToken text low.after (.symbol "..") = highStart := interpreted_take calls equations text valid low.after (.symbol "..") blow.1 (by unfold ValidToken; decide)
  have ehigh : calls.function .scalarRead text highStart state.scalarNames state.arrayNames.names state.arrayNames.values true = high := equations.scalarRead text valid highStart state.scalarNames state.arrayNames.names state.arrayNames.values true bhighStart stateValid.valid.2.2.2.2.2.1 (state_array_metadata stateValid.valid) (state_array_initials stateValid.valid)
  have eclose : calls.function .takeToken text high.after (.symbol ")") = close := interpreted_take calls equations text valid high.after (.symbol ")") bhigh.1 (by unfold ValidToken; decide)
  have eof : calls.function .takeToken text close (.word "of") = ofAfter := interpreted_take calls equations text valid close (.word "of") bclose (by unfold ValidToken; decide)
  have etypeFirst : calls.function .skip text ofAfter = typeFirst := interpreted_skip calls equations text valid ofAfter bof
  have etypeMark : calls.function .scalarType text state typeFirst = integerType :=
    interpreted_scalarType calls equations text valid state typeFirst stateValid btypeFirst
  have eboolean : calls.function .takeToken text typeFirst (.word "boolean") = fixedAfter text typeFirst "boolean" true :=
    interpreted_take calls equations text valid typeFirst (.word "boolean") btypeFirst (by unfold ValidToken; decide)
  have eassigned : calls.function .takeToken text typeMark.after (.symbol ":=") = assigned := interpreted_take calls equations text valid typeAfter (.symbol ":=") btypeAfter (by unfold ValidToken; decide)
  have eposition : calls.function .takeToken text assigned (.symbol "(") = position := interpreted_take calls equations text valid assigned (.symbol "(") bassigned (by unfold ValidToken; decide)
  simp only [arrayPartsEquation, decideIf, efirst, eafter, ecolon, econstant, earray,
    elowStart, elow, ehighStart, ehigh, eclose, eof, etypeFirst, etypeMark, eboolean]
  rw [eassigned, eposition]
  rfl


theorem interpreted_arrayDeclaration (calls : Calls) (laws : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : NativeState domain text state) :
    calls.function .arrayDeclaration text state arguments = arrayDeclarationAt text state arguments := by
  let equations := laws.toRawHelperEquations
  have vstate := stateValid.valid
  rw [equations.arrayDeclaration text valid state arguments stateValid, arrayDeclaration_denotation,
    ← model_arrayDeclaration_equation text state arguments true]
  change arrayDeclarationEquation calls true text state arguments =
    arrayDeclarationEquation modelCalls true text state arguments
  simp only [arrayDeclarationEquation, interpreted_arrayParts calls equations text valid state stateValid,
    model_arrayParts_equation]
  dsimp +instances only [modelCalls, spelling, isWord, ShellToken.symbol, ShellToken.word]
  simp only [decideIf, ↓reduceIte]
  generalize partsEq : arrayDeclarationParts text state = parts
  have positions : ArrayPartsBounds text parts := by
    rw [← partsEq]
    exact model_arrayParts_valid text state vstate.1 vstate.2.2.2.2.2.2.2.1
  by_cases positionZero : parts.position = 0
  · simp only [positionZero, decide_true, Bool.or_true, Bool.true_or, ↓reduceIte]
  have typeNameValid : ValidName text parts.typeFirst parts.typeAfter := by
    rw [← partsEq] at positionZero ⊢
    exact model_arrayParts_typeName text state vstate.1 vstate.2.2.2.2.2.2.2.1 positionZero
  have efunction := equations.functionLookup text valid state.functions parts.typeFirst parts.typeAfter
    vstate.functions positions.typeFirst positions.typeAfter
  have eprocedure := equations.procedureLookup text valid state.procedures parts.typeFirst parts.typeAfter
    vstate.procedures positions.typeFirst positions.typeAfter
  have eformal := equations.formalHides text valid state parts.typeFirst parts.typeAfter
    stateValid positions.typeFirst positions.typeAfter
  have ename := interpreted_newName calls equations text valid state parts.first parts.after arguments
    stateValid positions.first positions.after
  have estring := interpreted_lookup calls equations text valid state.names parts.typeFirst parts.typeAfter
    stateValid.nativeNames positions.typeFirst positions.typeAfter
  have escalar := equations.scalarLookup text valid state.scalarNames parts.typeFirst parts.typeAfter
    vstate.2.2.2.2.2.1 positions.typeFirst positions.typeAfter
  have earray := equations.arrayLookup text valid state.arrayNames.names parts.typeFirst parts.typeAfter
    (state_array_metadata vstate) positions.typeFirst positions.typeAfter
  have eboolean := equations.booleanLookup text valid state.booleanNames parts.typeFirst parts.typeAfter
    vstate.booleans positions.typeFirst positions.typeAfter
  have esubtype := interpreted_subtypeLookup calls equations text valid state.subtypeNames parts.typeFirst parts.typeAfter
    vstate.2.2.2.2.2.2.2.1 positions.typeFirst positions.typeAfter
  rw [ename]
  by_cases allowed : newNameAllowed text state parts.first parts.after arguments = true
  · have nameValid := model_new_name_valid text state parts.first parts.after arguments positions.after allowed
    rw [equations.nameIs text valid parts.first parts.after "integer" nameValid (by decide) (by decide),
      equations.nameIs text valid parts.first parts.after "boolean" nameValid (by decide) (by decide),
      equations.scalarEmpty parts.lower.bounds positions.lowerBounds,
      equations.scalarEmpty parts.upper.bounds positions.upperBounds,
      estring, escalar, earray, eboolean, esubtype, efunction, eprocedure, eformal,
      equations.nameIs text valid parts.typeFirst parts.typeAfter "integer" typeNameValid (by decide) (by decide),
      equations.nameIs text valid parts.typeFirst parts.typeAfter "boolean" typeNameValid (by decide) (by decide),
      equations.nameIs text valid parts.typeFirst parts.typeAfter "character" typeNameValid (by decide) (by decide)]
    have typeName : (if parts.isBoolean then
        Named.nameIs text parts.first parts.after ("boolean".toList.map Char.toNat)
        else Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat)) =
        Named.nameIs text parts.first parts.after parts.typeWord := by
      unfold ArrayDeclarationParts.typeWord
      split <;> rfl
    simp only [allowed, Bool.not_true, Bool.false_or, typeName]
    split
    · rfl
    · rename_i good
      have common : parts.lower.bounds.lower ≤ parts.upper.bounds.lower ∧
          parts.upper.bounds.lower - parts.lower.bounds.lower < (ArrayBindings.maxElements - state.arrayNames.used : Nat) ∧
          state.arrayNames.names.length ≠ ArrayBindings.maxBindings ∧ parts.position ≠ 0 := by
        simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at good
        omega
      have componentsNonempty : parts.componentBounds.lower ≤ parts.componentBounds.upper := by
        cases kind : parts.isBoolean with
        | true =>
          have originalKind : (arrayDeclarationParts text state).isBoolean = true := by rw [partsEq]; exact kind
          have same := arrayParts_boolean_components originalKind
          rw [partsEq] at same
          rw [same]
          decide +kernel
        | false =>
          have typeEq : scalarTypeAt text state parts.typeFirst = ⟨parts.typeAfter, parts.componentBounds⟩ := by
            rw [← partsEq]
            exact arrayParts_integer_type (partsEq.symm ▸ kind)
          have typePositive : (scalarTypeAt text state parts.typeFirst).after ≠ 0 := by
            have pos := common.2.2.2
            rw [typeEq]
            have positionEq : parts.position = fixedAfter text
                (fixedAfter text parts.typeAfter ":=" false) "(" false := by rw [← partsEq]; rfl
            rw [positionEq] at pos
            exact model_fixed_input_nonzero text _ ":=" false
              (model_fixed_input_nonzero text _ "(" false pos)
          have typeReading : ScalarTypeAt text state parts.typeFirst ⟨parts.typeAfter, parts.componentBounds⟩ :=
            typeEq ▸ scalarTypeAt_sound text state _ typePositive
          exact typeReading.nonempty vstate.2.2.2.2.2.2.2.1
      have bindingValid : ArrayBindings.ValidBinding (parts.binding state) := by
        have lowSafe := positions.lowerBounds.1
        have highSafe := positions.upperBounds.1
        have ordered := common.1
        have capacity := common.2.1
        simp only [ArrayBindings.ValidBinding, ArrayDeclarationParts.binding, ArrayDeclarationParts.length]
        exact ⟨⟨lowSafe, highSafe⟩, ordered, by omega, by omega, by omega,
          positions.componentBounds, componentsNonempty⟩
      have capacity : state.arrayNames.used + parts.length ≤ ArrayBindings.maxElements := bindingValid.2.2.2.1
      have initialContext (position : Nat) (bounded : ValidCursor text position) :
          ArrayValuesDomain text state state position parts.length 0 domain :=
        ⟨stateValid, stateValid, bounded, Nat.zero_le _, by omega, by omega⟩
      let choice := if parts.length = 1 then ScalarExpression.read text parts.position state.scalarNames
        0 0 true state.arrayNames.names state.arrayNames.values true else ScalarExpression.invalid
      have rawChoice := model_arrayScalar_valid text parts.position state.scalarNames state.arrayNames.names
        state.arrayNames.values true positions.position
      have choiceValid : ValidCursor text choice.after ∧ choice.bounds.Bounded := by
        dsimp only [choice]
        split
        · exact rawChoice
        · exact ⟨Nat.zero_le _, Integer.Interval.empty_bounded⟩
      have echoice := equations.scalarRead text valid parts.position state.scalarNames state.arrayNames.names
        state.arrayNames.values true positions.position vstate.2.2.2.2.2.1
        (state_array_metadata vstate) (state_array_initials vstate)
      rw [echoice]
      have earrow := interpreted_take calls equations text valid choice.after (.symbol "=>")
        choiceValid.1 (by unfold ValidToken; decide)
      have eempty := equations.scalarEmpty choice.bounds choiceValid.2
      dsimp only [ShellToken.symbol, choice, ArrayDeclarationParts.length] at earrow eempty
      rw [earrow, eempty]
      dsimp only [spelling, isWord]
      let position := if parts.length = 1 then fixedAfter text choice.after "=>" false else parts.position
      have positionValid : ValidCursor text position := by
        dsimp only [position]
        split
        · exact model_fixed_valid text choice.after "=>" false choiceValid.1
        · exact positions.position
      have context := initialContext position positionValid
      let values := if parts.isBoolean then
        booleanArrayValuesModel text state state position parts.length 0 parts.first parts.after
        else arrayValuesModel text state state position parts.length 0 parts.componentBounds
      have mask : (⟨parts.first, parts.after⟩ : NameState).Valid text := Or.inr nameValid
      have evalues : (if parts.isBoolean then
          calls.function .booleanArrayValues text state state position parts.length 0 parts.first parts.after
          else calls.function .arrayValues text state state position parts.length 0 parts.componentBounds) = values := by
        dsimp only [values]
        split
        · exact interpreted_booleanArrayValues calls laws text valid state state position parts.length 0 parts.first parts.after mask context
        · exact interpreted_arrayValues calls equations text valid state state position parts.length 0 parts.componentBounds positions.componentBounds context
      dsimp only [position, choice, ArrayDeclarationParts.length] at evalues
      rw [evalues]
      dsimp only [values, position, choice, ArrayDeclarationParts.length]
      have valuesValid : ValidState text values := by
        dsimp only [values]
        split
        · exact model_booleanArrayValues_valid text valid state state position parts.length 0 parts.first parts.after context
        · exact model_arrayValues_valid text state state position parts.length 0 parts.componentBounds context
      have closeValid := model_fixed_valid text values.position ")" false valuesValid.1
      have eclose := interpreted_take calls equations text valid values.position (.symbol ")") valuesValid.1
        (by unfold ValidToken; decide)
      have efollowing := interpreted_take calls equations text valid (fixedAfter text values.position ")" false)
        (.symbol ";") closeValid (by unfold ValidToken; decide)
      dsimp only [ShellToken.symbol, spelling, isWord, values, position, choice, ArrayDeclarationParts.length] at eclose efollowing
      rw [eclose, efollowing]
      by_cases absent : values.position = 0
      · dsimp only [values, position, choice, ArrayDeclarationParts.length] at absent
        simp only [absent, decide_true, Bool.true_or, ↓reduceIte, ite_self]
      · have fields : values.names = state.names ∧ values.scalarNames = state.scalarNames ∧
            values.arrayNames.names = state.arrayNames.names ∧
            values.arrayNames.used = state.arrayNames.used + parts.length := by
          dsimp only [values] at absent ⊢
          by_cases kind : parts.isBoolean = true
          · simp only [kind, ↓reduceIte] at absent ⊢
            have preserved := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after absent
            have used := booleanArrayValuesModel_used text state state position parts.length 0 parts.first parts.after absent
            refine ⟨?_, ?_, ?_, by simpa only [Nat.sub_zero] using used⟩ <;> rw [preserved]
          · have kindFalse := Bool.eq_false_iff.mpr kind
            simp only [kindFalse, Bool.false_eq_true, ↓reduceIte] at absent ⊢
            have preserved := arrayValuesModel_preserves text state state position parts.length 0 absent
            obtain ⟨expressions, reading⟩ := arrayValues_sound text state state position parts.length 0 positionValid absent
            exact ⟨preserved.1, preserved.2.1, preserved.2.2.1, by simpa only [Nat.sub_zero] using arrayValues_used reading⟩
        have valuesContext := NativeState.transportScalar stateValid valuesValid fields.2.1 fields.1
        have used := fields.2.2.2
        have room : values.arrayNames.names.length < ArrayBindings.maxBindings := by
          have oldBound := (state_array_metadata vstate).1
          have available := common.2.2.1
          rw [fields.2.2.1]
          omega
        have appendOrder : ArrayAddDomain values.arrayNames.names state.arrayNames.used := by
          intro last isLast
          rw [fields.2.2.1] at isLast
          exact vstate.2.2.2.2.2.2.1.2.2.2 last (List.mem_of_getLast? isLast)
        have ending := model_fixed_valid text (fixedAfter text values.position ")" false) ";" false closeValid
        have added := equations.arrayAdd text valid values parts.first parts.after
          ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩ state.arrayNames.used parts.length
          (decide (parts.constantAfter = 0)) _ parts.componentBounds parts.isBoolean
          valuesContext nameValid bindingValid room (by omega) appendOrder ending
        rw [arrayAdd_denotation] at added
        dsimp only [values, position, choice, ArrayDeclarationParts.length] at added
        rw [added]
  · have rejected : newNameAllowed text state parts.first parts.after arguments = false := Bool.eq_false_iff.mpr allowed
    simp only [rejected, Bool.not_false, Bool.true_or, ↓reduceIte]

end Silver.Compose.Expressions
