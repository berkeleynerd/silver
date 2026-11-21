module

public import Silver.ComposeArrayDeclarations

@[expose] public section

/-! Boolean array declarations share the fixed-array bounds and allocation
grammar. This source relation retains the complete initializer cursor traversal;
raw Boolean conditions are recovered under the actual text/name domain in the
separate initializer trace, just as for scalar Boolean declarations. -/
namespace Silver.Compose
open Expressions

set_option maxHeartbeats 4000000
set_option maxRecDepth 10000

attribute [local irreducible] arrayDeclarationParts ScalarExpression.ArrayGrammar.read

def BooleanArrayDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ArrayDeclarationParts) : Prop :=
  newNameAllowed text state parts.first parts.after arguments = true ∧
    Named.nameIs text parts.first parts.after ("boolean".toList.map Char.toNat) = false ∧
    ¬ (parts.arrayAfter = 0 ∧ parts.typeId = 0) ∧ parts.position ≠ 0 ∧
    state.arrayNames.names.length ≠ ArrayBindings.maxBindings ∧
    parts.lower.after ≠ 0 ∧ parts.upper.after ≠ 0 ∧
    parts.lower.isStatic = true ∧ parts.upper.isStatic = true ∧
    parts.lower.bounds.isEmpty = false ∧ parts.upper.bounds.isEmpty = false ∧
    parts.lower.bounds.lower = parts.lower.bounds.upper ∧
    parts.upper.bounds.lower = parts.upper.bounds.upper ∧
    parts.lower.bounds.lower ≤ parts.upper.bounds.lower ∧
    parts.upper.bounds.lower - parts.lower.bounds.lower <
      (ArrayBindings.maxElements - state.arrayNames.used : Nat) ∧
    lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
    ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0 ∧
    ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter = 0 ∧
    BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter = 0 ∧
    FunctionBindings.lookup text state.functions parts.typeFirst parts.typeAfter = 0 ∧
    ProcedureBindings.lookup text state.procedures parts.typeFirst parts.typeAfter = 0 ∧
    formalHides text state parts.typeFirst parts.typeAfter = false ∧
    (state.hiding.integerHidden = true → Named.nameIs text parts.typeFirst parts.typeAfter ("integer".toList.map Char.toNat) = false) ∧
    (state.hiding.booleanHidden = true → Named.nameIs text parts.typeFirst parts.typeAfter ("boolean".toList.map Char.toNat) = false) ∧
    (state.hiding.characterHidden = true → Named.nameIs text parts.typeFirst parts.typeAfter ("character".toList.map Char.toNat) = false) ∧
    IntegerSubtypes.lookup text state.subtypeNames parts.typeFirst parts.typeAfter = 0 ∧
    (parts.typeId = 0 → ArrayBindings.lookupType text state.arrayNames.types parts.typeFirst parts.typeAfter = 0) ∧
    (0 < state.arrayNames.names.length →
      (ArrayBindings.binding state.arrayNames.names state.arrayNames.names.length).viewSlot = 0) ∧
    parts.isBoolean = true

theorem BooleanArrayDeclarationReady.kind {text state arguments parts}
    (ready : BooleanArrayDeclarationReady text state arguments parts) : parts.isBoolean = true := by
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, kind⟩
  exact kind

theorem arrayParts_boolean_components {text state}
    (kind : (arrayDeclarationParts text state).isBoolean = true) :
    (arrayDeclarationParts text state).componentBounds = Integer.Interval.full := by
  have anonymous := arrayParts_boolean_anonymous kind
  unfold arrayDeclarationParts at anonymous kind ⊢
  dsimp only at anonymous kind ⊢
  simp only [anonymous, ne_eq, not_true_eq_false, ↓reduceIte] at kind ⊢
  simp only [kind, ↓reduceIte]

inductive BooleanArrayDeclarationAt (text : Source) (arguments : Bool) :
    ParserState → ParserState → Prop
  | declaration {state values : ParserState} {parts : ArrayDeclarationParts}
      {lower upper : Integer.Expr} {position following : Nat} :
      arrayDeclarationParts text state = parts → BooleanArrayDeclarationReady text state arguments parts →
      ScalarExpression.ArrayGrammar.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
        (arrays := state.arrayNames.table) (initials := state.arrayNames.values) (elaborating := true) →
      ScalarExpression.ArrayGrammar.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
        (arrays := state.arrayNames.table) (initials := state.arrayNames.values) (elaborating := true) →
      ArrayAggregateAt text state parts position →
      booleanArrayValuesModel text state state position parts.length 0 parts.first parts.after = values →
      values.position ≠ 0 →
      following = fixedAfter text (fixedAfter text values.position ")" false) ";" false →
      state.position < following →
      BooleanArrayDeclarationAt text arguments state
        {values with position := following, arrayNames := {values.arrayNames with
          names := values.arrayNames.names ++ [parts.binding state]}}

theorem booleanArrayValuesModel_zero (text : Source) (source result : ParserState)
    (length parsed maskFirst maskAfter : Nat) :
    booleanArrayValuesModel text source result 0 length parsed maskFirst maskAfter = invalidState := by
  rw [booleanArrayValuesModel]
  simp only [↓reduceIte]

theorem booleanArrayValuesModel_start_positive {text source result position length parsed maskFirst maskAfter}
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    position ≠ 0 := by
  intro zero
  rw [zero, booleanArrayValuesModel_zero] at positive
  exact positive rfl

theorem booleanArrayValuesModel_fields (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    let final := booleanArrayValuesModel text source result position length parsed maskFirst maskAfter
    final = {result with position := final.position, arrayNames := {result.arrayNames with
      used := final.arrayNames.used, values := final.arrayNames.values}} := by
  dsimp only
  rw [booleanArrayValuesModel] at positive ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
  · simp only [zero, ↓reduceIte] at positive ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at positive ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
      · simp only [bad, ↓reduceIte] at positive ⊢
        exact booleanArrayValuesModel_fields text source _ _ length (parsed + 1) maskFirst maskAfter positive
    · simp only [remaining, ↓reduceDIte]
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_used (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).arrayNames.used =
      result.arrayNames.used + (length - parsed) := by
  rw [booleanArrayValuesModel] at positive ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
  · simp only [zero, ↓reduceIte] at positive ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at positive ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
      · simp only [bad, ↓reduceIte] at positive ⊢
        have next := booleanArrayValuesModel_used text source _ _ length (parsed + 1) maskFirst maskAfter positive
        dsimp only at next
        omega
    · simp only [remaining, ↓reduceDIte]
      omega
termination_by length - parsed
decreasing_by omega

theorem boolean_array_declaration_positive {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) : final.position ≠ 0 := by
  cases reading with
  | declaration _ _ _ _ _ _ _ _ following => dsimp only; omega

theorem boolean_array_declaration_complete {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    arrayDeclarationAt text state arguments = final := by
  cases reading with
  | @declaration values parts lower upper position following partsEq ready _ _ aggregate valuesEq positive followingEq advances =>
      have kind := ready.kind
      have start := booleanArrayValuesModel_start_positive (valuesEq.symm ▸ positive)
      have aggregateEq := arrayAggregate_complete aggregate
      simp only [ArrayDeclarationParts.length] at aggregateEq valuesEq start
      simp only [arrayDeclarationAt, partsEq, ArrayDeclarationParts.typeWord, kind,
        ↓reduceIte, true_and, arrayDeclarationValues]
      split
      · rename_i bad
        exfalso
        rcases ready with ⟨fresh, reserved, available, position, capacity,
          low, high, lowStatic, highStatic, lowNonempty, highNonempty, lowExact, highExact,
          ordered, room, strings, scalars, arrays, booleans, functions, procedures,
          formals, integerHidden, booleanHidden, characterHidden, subtypeName, typeName, stored, _⟩
        simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, or_assoc] at bad
        rcases bad with h | h | h | h | h | h | h | h | h | h | h | h | h | h | h | h |
          h | h | h | h | h | h | h | h | h | h | h | h
        · simp only [fresh, Bool.not_true, Bool.false_eq_true] at h
        · exact Bool.false_ne_true (reserved.symm.trans h)
        · exact available h
        · exact position h
        · exact capacity h
        · exact h.2 (stored h.1)
        · exact low h
        · exact high h
        · simp only [lowStatic, Bool.not_true, Bool.false_eq_true] at h
        · simp only [highStatic, Bool.not_true, Bool.false_eq_true] at h
        · exact Bool.false_ne_true (lowNonempty.symm.trans h)
        · exact Bool.false_ne_true (highNonempty.symm.trans h)
        · exact h lowExact
        · exact h highExact
        · exact (Int.not_lt.mpr ordered) h
        · exact (Int.not_le.mpr room) h
        · exact h strings
        · exact h scalars
        · exact h arrays
        · exact h.2 (typeName h.1)
        · exact h booleans
        · exact h functions
        · exact h procedures
        · exact Bool.false_ne_true (formals.symm.trans h)
        · exact Bool.false_ne_true ((integerHidden h.1).symm.trans h.2)
        · exact Bool.false_ne_true ((booleanHidden h.1).symm.trans h.2)
        · exact Bool.false_ne_true ((characterHidden h.1).symm.trans h.2)
        · exact h subtypeName
      · simp only [aggregateEq, start, valuesEq, positive, ↓reduceIte]
        rw [← followingEq, ite_eq_right (Nat.not_le.mpr advances)]
        simp only [ArrayDeclarationParts.binding, ArrayDeclarationParts.length, kind]

theorem boolean_array_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (booleanKind : (arrayDeclarationParts text state).isBoolean = true)
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    BooleanArrayDeclarationAt text arguments state (arrayDeclarationAt text state arguments) := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
  have kind : parts.isBoolean = true := by rw [← partsEq]; exact booleanKind
  dsimp only at accepted ⊢
  simp only [arrayDeclarationValues, ArrayDeclarationParts.typeWord, kind,
    ↓reduceIte, true_and] at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i good
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    have ready : BooleanArrayDeclarationReady text state arguments parts := by
      have checked := good
      simp [Bool.or_eq_true, Bool.and_eq_true, not_or, not_and,
        Int.not_lt, Int.not_le, and_assoc] at checked
      rcases checked with ⟨fresh, reserved, available, position, capacity, stored,
        low, high, lowStatic, highStatic, lowNonempty, highNonempty, lowExact, highExact,
        ordered, room, strings, scalars, arrays, typeName, booleans, functions, procedures,
        formals, integerHidden, booleanHidden, characterHidden, subtypeName⟩
      exact ⟨fresh, reserved, by simpa only [not_and] using available, position, capacity,
        low, high, lowStatic, highStatic, lowNonempty, highNonempty, lowExact, highExact,
        ordered, room, strings, scalars, arrays, booleans, functions, procedures, formals,
        integerHidden, booleanHidden, characterHidden, subtypeName, typeName, stored, kind⟩
    split at accepted
    · simp only [invalidState] at accepted
      contradiction
    · rename_i start
      simp only [start, ↓reduceIte]
      split at accepted
      · simp only [invalidState] at accepted
        contradiction
      · rename_i positive
        simp only [positive, ↓reduceIte]
        split at accepted
        · simp only [invalidState] at accepted
          contradiction
        · rename_i advances
          simp only [advances, ↓reduceIte]
          have anonymous := arrayParts_boolean_anonymous booleanKind
          have lowerEq : parts.lower = ScalarExpression.ArrayGrammar.read text
              (fixedAfter text parts.arrayAfter "(" false) state.scalarNames
              (arrays := state.arrayNames.table) (initials := state.arrayNames.values)
              (elaborating := true) := by
                rw [← partsEq]
                unfold arrayDeclarationParts at anonymous ⊢
                dsimp only at anonymous ⊢
                simp only [anonymous, ne_eq, not_true_eq_false, ↓reduceIte]
          have upperEq : parts.upper = ScalarExpression.ArrayGrammar.read text
              (fixedAfter text parts.lower.after ".." false) state.scalarNames
              (arrays := state.arrayNames.table) (initials := state.arrayNames.values)
              (elaborating := true) := by
                rw [← partsEq]
                unfold arrayDeclarationParts at anonymous ⊢
                dsimp only at anonymous ⊢
                simp only [anonymous, ne_eq, not_true_eq_false, ↓reduceIte]
          have lowPositive : parts.lower.after ≠ 0 := ready.2.2.2.2.2.1
          have highPositive : parts.upper.after ≠ 0 := ready.2.2.2.2.2.2.1
          obtain ⟨lower, lowerRead⟩ := ScalarExpression.ArrayGrammar.read_sound
            (fixedAfter_result_bound text _ "(" false (by decide)) (lowerEq ▸ lowPositive)
          obtain ⟨upper, upperRead⟩ := ScalarExpression.ArrayGrammar.read_sound
            (fixedAfter_result_bound text _ ".." false (by decide)) (upperEq ▸ highPositive)
          have positionBound : parts.position ≤ text.length + 1 := by
            have positionEq : parts.position =
                fixedAfter text (fixedAfter text parts.typeAfter ":=" false) "(" false := by
              rw [← partsEq]
              unfold arrayDeclarationParts
              rfl
            rw [positionEq]
            exact fixedAfter_result_bound text _ "(" false (by decide)
          have aggregate := arrayAggregate_sound positionBound start
          simpa only [ArrayDeclarationParts.binding, ArrayDeclarationParts.length, kind] using
            (BooleanArrayDeclarationAt.declaration partsEq ready (lowerEq.symm ▸ lowerRead)
              (upperEq.symm ▸ upperRead) aggregate rfl positive rfl (Nat.lt_of_not_ge advances))

theorem boolean_array_declaration_kind {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    (arrayDeclarationParts text state).isBoolean = true := by
  cases reading with
  | declaration parts ready _ _ _ _ _ _ _ => rw [parts]; exact ready.kind

theorem boolean_array_declaration_fields {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    final = {state with position := final.position, arrayNames := final.arrayNames} := by
  cases reading with
  | @declaration values parts lower upper position following _ _ _ _ _ valuesEq positive _ _ =>
      have same := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after
        (valuesEq.symm ▸ positive)
      rw [valuesEq] at same
      exact congrArg (fun s : ParserState =>
        {s with
          position := following
          arrayNames := {values.arrayNames with names := values.arrayNames.names ++ [parts.binding state]}}) same

theorem boolean_array_declaration_preserves {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    final.names = state.names ∧ final.scalarNames = state.scalarNames ∧
      final.booleanNames = state.booleanNames ∧ final.subtypeNames = state.subtypeNames := by
  rw [boolean_array_declaration_fields reading]
  exact ⟨rfl, rfl, rfl, rfl⟩

end Silver.Compose
