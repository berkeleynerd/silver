module

public import Silver.ComposeSubtypeDeclarations
public import Silver.IntegerArraySnapshots

@[expose] public section

/-! Ordered source readings for explicit fixed-array aggregates. Every component
retains its raw arithmetic and indexed expression, and all components read the
same incoming environment before the new array name is introduced. -/
namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.read

def declarationRanges (state : ParserState) : Integer.Ranges :=
  ArrayBindings.integerRanges state.arrayNames.names state.arrayNames.values true
    (ScalarExpression.ranges state.scalarNames)

def ArrayDeclarationParts.length (parts : ArrayDeclarationParts) : Nat :=
  (parts.upper.bounds.lower - parts.lower.bounds.lower + 1).toNat

def ArrayDeclarationParts.binding (parts : ArrayDeclarationParts) (state : ParserState) :
    ArrayBindings.Binding :=
  ⟨parts.first, parts.after, ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩,
    state.arrayNames.used, parts.length, decide (parts.constantAfter = 0), parts.componentBounds, parts.isBoolean⟩

def ArrayDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ArrayDeclarationParts) : Prop :=
  newNameAllowed text state parts.first parts.after arguments = true ∧
    Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) = false ∧
    parts.arrayAfter ≠ 0 ∧ parts.position ≠ 0 ∧
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
    parts.isBoolean = false

theorem ArrayDeclarationReady.integer {text state arguments parts}
    (ready : ArrayDeclarationReady text state arguments parts) : parts.isBoolean = false := by
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, kind⟩
  exact kind

theorem arrayParts_integer_type {text state}
    (kind : (arrayDeclarationParts text state).isBoolean = false) :
    scalarTypeAt text state (arrayDeclarationParts text state).typeFirst =
      ⟨(arrayDeclarationParts text state).typeAfter, (arrayDeclarationParts text state).componentBounds⟩ := by
  unfold arrayDeclarationParts at kind ⊢
  dsimp only at kind ⊢
  simp only [kind, Bool.false_eq_true, ↓reduceIte]

/-- This grammar records the singleton aggregate's required named association;
its choice is Ada-static and denotes the declared sole index. -/
inductive ArrayAggregateAt (text : Source) (state : ParserState) (parts : ArrayDeclarationParts) : Nat → Prop
  | positional : parts.length ≠ 1 → ArrayAggregateAt text state parts parts.position
  | singleton {expression : Integer.Expr} {result : ScalarExpression.Result} :
      parts.length = 1 →
      ScalarExpression.At text state.scalarNames parts.position expression result
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) →
      result.isStatic = true → result.bounds.isEmpty = false →
      result.bounds.lower = parts.lower.bounds.lower → result.bounds.upper = parts.lower.bounds.lower →
      fixedAfter text result.after "=>" false ≠ 0 →
      ArrayAggregateAt text state parts (fixedAfter text result.after "=>" false)

inductive ArrayValuesAt (text : Source) (source : ParserState) (componentBounds : Integer.Interval) :
    ParserState → Nat → Nat → Nat → List Integer.Expr → ParserState → Prop
  | done {result : ParserState} {position length parsed : Nat} :
      position ≠ 0 → length ≤ parsed →
      ArrayValuesAt text source componentBounds result position length parsed [] {result with position := position}
  | next {result final : ParserState} {position length parsed : Nat}
      {expression : Integer.Expr} {value : ScalarExpression.Result} {rest : List Integer.Expr} :
      position ≠ 0 → parsed < length →
      ScalarExpression.At text source.scalarNames position expression value
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values) (elaborating := true) →
      value.bounds.isEmpty = false → value.bounds.lower = value.bounds.upper →
      (componentBounds.lower ≤ value.bounds.lower ∧ value.bounds.upper ≤ componentBounds.upper) →
      ArrayValuesAt text source componentBounds
        {result with arrayNames := {result.arrayNames with
          used := result.arrayNames.used + 1
          values := ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) value.bounds.lower}}
        (if parsed + 1 < length then fixedAfter text value.after "," false else value.after)
        length (parsed + 1) rest final →
      ArrayValuesAt text source componentBounds result position length parsed (expression :: rest) final

theorem arrayValues_complete {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    arrayValuesModel text source result position length parsed componentBounds = final := by
  induction reading with
  | @done result position length parsed positive finished =>
      rw [arrayValuesModel]
      simp only [positive, ↓reduceIte, Nat.not_lt.mpr finished, ↓reduceDIte]
  | @next result final position length parsed expression value rest positive remaining reading nonempty singleton within restRead ih =>
      have progress := reading.cursorBounds
      have present : value.after ≠ 0 := by omega
      rw [arrayValuesModel]
      have good : ¬(value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
          value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper) := by
        simp only [present, nonempty, singleton, Bool.false_eq_true, ne_eq, not_true_eq_false, false_or]
        omega
      simp only [positive, ↓reduceIte, remaining, ↓reduceDIte, ScalarExpression.read_complete reading, good]
      exact ih

theorem arrayValues_sound (text : Source) (source result : ParserState)
    (position length parsed : Nat) {componentBounds : Integer.Interval} (bound : position ≤ text.length + 1)
    (accepted : (arrayValuesModel text source result position length parsed componentBounds).position ≠ 0) :
    ∃ expressions, ArrayValuesAt text source componentBounds result position length parsed expressions
      (arrayValuesModel text source result position length parsed componentBounds) := by
  rw [arrayValuesModel] at accepted ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
  · simp only [zero, ↓reduceIte] at accepted ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at accepted ⊢
      generalize valueEq : ScalarExpression.read text position source.scalarNames
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
        (elaborating := true) = value at accepted ⊢
      by_cases bad : value.after = 0 ∨ value.bounds.isEmpty = true ∨ value.bounds.lower ≠ value.bounds.upper ∨
        value.bounds.lower < componentBounds.lower ∨ componentBounds.upper < value.bounds.upper
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at accepted
      · simp only [bad, ↓reduceIte] at accepted ⊢
        have checked := bad
        simp only [not_or, Bool.not_eq_true, Decidable.not_not, Int.not_lt] at checked
        have present : (ScalarExpression.read text position source.scalarNames
            (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
            (elaborating := true)).after ≠ 0 := by rw [valueEq]; exact checked.1
        obtain ⟨expression, raw⟩ := ScalarExpression.read_sound bound present
        have reading : ScalarExpression.At text source.scalarNames position expression value
            (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
            (elaborating := true) := by rw [← valueEq]; exact raw
        have ending : value.after ≤ text.length + 1 := by
          exact reading.cursorBounds.2.2
        have nextBound : (if parsed + 1 < length then fixedAfter text value.after "," false
            else value.after) ≤ text.length + 1 := by
          split
          · exact model_fixed_valid text _ "," false ending
          · exact ending
        obtain ⟨rest, restRead⟩ := arrayValues_sound text source _ _ length (parsed + 1) nextBound accepted
        exact ⟨expression :: rest, .next zero remaining reading checked.2.1 checked.2.2.1 checked.2.2.2 restRead⟩
    · simp only [remaining, ↓reduceDIte]
      exact ⟨[], .done zero (by omega)⟩
termination_by length - parsed
decreasing_by omega

theorem arrayValues_length {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    expressions.length = length - parsed := by
  induction reading with
  | done _ finished => simp; omega
  | next _ remaining _ _ _ _ _ ih => simp only [List.length_cons]; omega

theorem arrayValues_initialValues {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    ∃ values, Integer.arrayInitialValues (declarationRanges source) expressions = some values := by
  induction reading with
  | done => exact ⟨[], rfl⟩
  | @next result final position length parsed expression value rest _ _ reading _ singleton _ _ ih =>
      obtain ⟨values, checked⟩ := ih
      refine ⟨value.bounds.lower :: values, ?_⟩
      change expression.infer (declarationRanges source) >>= _ = _
      rw [show expression.infer (declarationRanges source) = some value.bounds from reading.inferred]
      change (if value.bounds.lower = value.bounds.upper then
        (Integer.arrayInitialValues (declarationRanges source) rest).map
          (fun values => value.bounds.lower :: values) else none) = some (value.bounds.lower :: values)
      simp only [singleton, ↓reduceIte, checked, Option.map_some]

theorem arrayValues_obligations {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    Integer.discharged (expressions.flatMap fun expression =>
      expression.obligations (declarationRanges source)) = true := by
  induction reading with
  | done => rfl
  | next _ _ reading _ _ _ _ ih =>
      rw [List.flatMap_cons, Integer.discharged_append, ih]
      have discharged : Integer.discharged (Integer.Expr.obligations (declarationRanges source) _) = true :=
        Integer.Expr.obligations_discharge reading.inferred
      rw [discharged]
      rfl


theorem arrayAggregate_complete {text state parts position}
    (reading : ArrayAggregateAt text state parts position) :
    arrayAggregatePosition text state parts parts.length = position := by
  cases reading with
  | positional multiple => simp only [arrayAggregatePosition, multiple, ↓reduceIte]
  | singleton single value static nonempty lower upper following =>
      simp only [arrayAggregatePosition, single, ↓reduceIte, ScalarExpression.read_complete value,
        static, nonempty, lower, upper, following, Bool.true_eq_false, Bool.false_eq_true,
        ne_eq, not_true_eq_false, false_or]

theorem arrayAggregate_sound {text state parts}
    (bound : parts.position ≤ text.length + 1)
    (accepted : arrayAggregatePosition text state parts parts.length ≠ 0) :
    ArrayAggregateAt text state parts (arrayAggregatePosition text state parts parts.length) := by
  unfold arrayAggregatePosition at accepted ⊢
  split at accepted
  · rename_i single
    simp only [single, ↓reduceIte]
    dsimp only at accepted
    split at accepted
    · contradiction
    · rename_i good
      simp only [good, ↓reduceIte]
      have checked := good
      simp only [not_or, Bool.not_eq_false, Bool.not_eq_true, Decidable.not_not] at checked
      have present : (ScalarExpression.read text parts.position state.scalarNames
          (arrays := state.arrayNames.names) (initials := state.arrayNames.values)
          (elaborating := true)).after ≠ 0 := by
        intro absent
        apply checked.1
        simp only [absent, fixedAfter, ↓reduceIte]
      obtain ⟨expression, value⟩ := ScalarExpression.read_sound bound present
      exact .singleton single value checked.2.1 checked.2.2.1 checked.2.2.2.1 checked.2.2.2.2 checked.1
  · rename_i multiple
    simp only [multiple, ↓reduceIte]
    exact .positional multiple

/-- Both static bounds, the aggregate association, and every raw initializer
remain in the source derivation. The program projection uses this same complete
list of initializer expressions; no frozen value erases their obligations. -/
inductive ArrayDeclarationAt (text : Source) (arguments : Bool) :
    ParserState → Integer.ArrayDeclaration → ParserState → Prop
  | declaration {state values : ParserState} {parts : ArrayDeclarationParts}
      {lower upper : Integer.Expr} {position following : Nat} {expressions : List Integer.Expr} :
      arrayDeclarationParts text state = parts → ArrayDeclarationReady text state arguments parts →
      ScalarTypeAt text state parts.typeFirst ⟨parts.typeAfter, parts.componentBounds⟩ →
      ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) →
      ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) →
      ArrayAggregateAt text state parts position →
      ArrayValuesAt text state parts.componentBounds state position parts.length 0 expressions values →
      following = fixedAfter text (fixedAfter text values.position ")" false) ";" false →
      state.position < following →
      ArrayDeclarationAt text arguments state ⟨(parts.binding state).descriptor, expressions⟩
        {values with position := following, arrayNames := {values.arrayNames with
          names := values.arrayNames.names ++ [parts.binding state]}}

theorem arrayValues_positive {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) : final.position ≠ 0 := by
  induction reading with
  | done positive _ => exact positive
  | next _ _ _ _ _ _ _ ih => exact ih

theorem arrayValues_start_positive {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) : position ≠ 0 := by
  cases reading with
  | done positive _ => exact positive
  | next positive _ _ _ _ _ _ => exact positive

theorem array_declaration_positive {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) : final.position ≠ 0 := by
  cases reading with
  | declaration _ _ _ _ _ _ _ _ following => dsimp only; omega

theorem array_declaration_preserves {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.names = state.names ∧ final.scalarNames = state.scalarNames := by
  cases reading with
  | declaration _ _ _ _ _ _ values _ _ =>
      have preserved := arrayValuesModel_preserves _ _ _ _ _ _
        ((arrayValues_complete values).symm ▸ arrayValues_positive values)
      rw [arrayValues_complete values] at preserved
      exact ⟨preserved.1, preserved.2.1⟩


theorem array_declaration_complete {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    arrayDeclarationAt text state arguments = final := by
  cases reading with
  | @declaration values parts lower upper position following expressions partsEq ready _ _ _ aggregate valuesRead followingEq advances =>
      have start := arrayValues_start_positive valuesRead
      have positive := arrayValues_positive valuesRead
      have aggregateEq := arrayAggregate_complete aggregate
      have valuesEq := arrayValues_complete valuesRead
      have kind := ready.integer
      simp only [ArrayDeclarationParts.length] at aggregateEq valuesEq
      simp only [arrayDeclarationAt, partsEq, ArrayDeclarationParts.typeWord, kind,
        Bool.false_eq_true, ↓reduceIte, false_and, or_false, arrayDeclarationValues]
      split
      · rename_i bad
        exfalso
        simp_all [ArrayDeclarationReady, Bool.or_eq_true]
        rcases bad with numeric | hidden | hidden | hidden <;> (try simp_all) <;> omega
      · simp only [aggregateEq, start, valuesEq, positive, ↓reduceIte]
        rw [← followingEq, ite_eq_right (Nat.not_le.mpr advances)]
        simp only [ArrayDeclarationParts.binding, ArrayDeclarationParts.length, kind]

theorem array_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (integerKind : (arrayDeclarationParts text state).isBoolean = false)
    (accepted : (arrayDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, ArrayDeclarationAt text arguments state declaration (arrayDeclarationAt text state arguments) := by
  unfold arrayDeclarationAt at accepted ⊢
  generalize partsEq : arrayDeclarationParts text state = parts at accepted ⊢
  have kind : parts.isBoolean = false := by rw [← partsEq]; exact integerKind
  dsimp only at accepted ⊢
  simp only [arrayDeclarationValues, ArrayDeclarationParts.typeWord, kind,
    Bool.false_eq_true, ↓reduceIte, false_and, or_false] at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i good
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    have ready : ArrayDeclarationReady text state arguments parts := by
      simpa [ArrayDeclarationReady, kind, Bool.or_eq_true, not_or, Nat.not_le, Int.not_lt,
        Int.not_le, and_assoc] using good
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
          have lowerEq : parts.lower = ScalarExpression.read text
              (fixedAfter text parts.arrayAfter "(" false) state.scalarNames
              (arrays := state.arrayNames.names) (initials := state.arrayNames.values)
              (elaborating := true) := by rw [← partsEq]; rfl
          have upperEq : parts.upper = ScalarExpression.read text
              (fixedAfter text parts.lower.after ".." false) state.scalarNames
              (arrays := state.arrayNames.names) (initials := state.arrayNames.values)
              (elaborating := true) := by rw [← partsEq]; rfl
          have lowPositive : parts.lower.after ≠ 0 := ready.2.2.2.2.2.1
          have highPositive : parts.upper.after ≠ 0 := ready.2.2.2.2.2.2.1
          obtain ⟨lower, lowerRead⟩ := ScalarExpression.read_sound
            (fixedAfter_result_bound text _ "(" false (by decide)) (lowerEq ▸ lowPositive)
          obtain ⟨upper, upperRead⟩ := ScalarExpression.read_sound
            (fixedAfter_result_bound text _ ".." false (by decide)) (upperEq ▸ highPositive)
          have positionBound : parts.position ≤ text.length + 1 := by
            rw [← partsEq]
            exact fixedAfter_result_bound text _ "(" false (by decide)
          have aggregate := arrayAggregate_sound positionBound start
          have aggregateBound : arrayAggregatePosition text state parts parts.length ≤ text.length + 1 := by
            unfold arrayAggregatePosition
            split
            · dsimp only
              split
              · omega
              · exact fixedAfter_result_bound text _ "=>" false (by decide)
            · exact positionBound
          obtain ⟨expressions, valuesRead⟩ := arrayValues_sound text state state _ parts.length 0
            aggregateBound positive
          refine ⟨⟨(parts.binding state).descriptor, expressions⟩, ?_⟩
          have typeEq : scalarTypeAt text state parts.typeFirst = ⟨parts.typeAfter, parts.componentBounds⟩ := by
            rw [← partsEq]
            exact arrayParts_integer_type integerKind
          have typePositive : (scalarTypeAt text state parts.typeFirst).after ≠ 0 := by
            have pos := ready.2.2.2.1
            rw [typeEq]
            have positionEq : parts.position = fixedAfter text
                (fixedAfter text parts.typeAfter ":=" false) "(" false := by rw [← partsEq]; rfl
            rw [positionEq] at pos
            exact model_fixed_input_nonzero text _ ":=" false
              (model_fixed_input_nonzero text _ "(" false pos)
          have reading := ArrayDeclarationAt.declaration (state := state) (parts := parts)
            partsEq ready (typeEq ▸ scalarTypeAt_sound text state _ typePositive)
            (lowerEq.symm ▸ lowerRead) (upperEq.symm ▸ upperRead)
            aggregate valuesRead rfl (Nat.lt_of_not_ge advances)
          simpa only [ArrayDeclarationParts.binding, ArrayDeclarationParts.length, kind] using reading

end Silver.Compose
