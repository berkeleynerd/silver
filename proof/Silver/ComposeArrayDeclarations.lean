module

public import Silver.ComposeBounds
public import Silver.IntegerArraySnapshots

@[expose] public section

/-! Ordered source readings for explicit fixed-array aggregates. Every component
retains its raw arithmetic and indexed expression, and all components read the
same incoming environment before the new array name is introduced. -/
namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.read

def declarationRanges (state : ParserState) : Integer.Ranges :=
  ArrayBindings.ranges state.arrayNames.names state.arrayNames.values true
    (ScalarExpression.ranges state.scalarNames)

def ArrayDeclarationParts.length (parts : ArrayDeclarationParts) : Nat :=
  (parts.upper.bounds.lower - parts.lower.bounds.lower + 1).toNat

def ArrayDeclarationParts.binding (parts : ArrayDeclarationParts) (state : ParserState) :
    ArrayBindings.Binding :=
  ⟨parts.first, parts.after, ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩,
    state.arrayNames.used, parts.length, decide (parts.constantAfter = 0)⟩

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
    ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter = 0

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

inductive ArrayValuesAt (text : Source) (source : ParserState) :
    ParserState → Nat → Nat → Nat → List Integer.Expr → ParserState → Prop
  | done {result : ParserState} {position length parsed : Nat} :
      position ≠ 0 → length ≤ parsed →
      ArrayValuesAt text source result position length parsed [] {result with position := position}
  | next {result final : ParserState} {position length parsed : Nat}
      {expression : Integer.Expr} {value : ScalarExpression.Result} {rest : List Integer.Expr} :
      position ≠ 0 → parsed < length →
      ScalarExpression.At text source.scalarNames position expression value
        (arrays := source.arrayNames.names) (initials := source.arrayNames.values) (elaborating := true) →
      value.bounds.isEmpty = false → value.bounds.lower = value.bounds.upper →
      ArrayValuesAt text source
        {result with arrayNames := {result.arrayNames with used := result.arrayNames.used + 1,
          values := ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) value.bounds.lower}}
        (if parsed + 1 < length then fixedAfter text value.after "," false else value.after)
        length (parsed + 1) rest final →
      ArrayValuesAt text source result position length parsed (expression :: rest) final

theorem arrayValues_complete {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    arrayValuesModel text source result position length parsed = final := by
  induction reading with
  | done positive finished =>
      rw [arrayValuesModel]
      simp only [positive, ↓reduceIte, show ¬ parsed < length by omega, ↓reduceDIte]
  | @next result final position length parsed expression value rest positive remaining reading nonempty singleton restRead ih =>
      have progress := ScalarExpression.syntax_bounds reading.positionBound reading.grammar
      have present : value.after ≠ 0 := by omega
      rw [arrayValuesModel]
      simp only [positive, ↓reduceIte, remaining, ↓reduceDIte, ScalarExpression.read_complete reading,
        present, nonempty, singleton, not_true_eq_false, false_or]
      exact ih

theorem arrayValues_sound (text : Source) (source result : ParserState)
    (position length parsed : Nat) (bound : position ≤ text.length + 1)
    (accepted : (arrayValuesModel text source result position length parsed).position ≠ 0) :
    ∃ expressions, ArrayValuesAt text source result position length parsed expressions
      (arrayValuesModel text source result position length parsed) := by
  rw [arrayValuesModel] at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i positive
    simp only [positive, ↓reduceIte]
    split at accepted
    · rename_i remaining
      simp only [remaining, ↓reduceDIte]
      split at accepted
      · simp only [invalidState] at accepted
        contradiction
      · rename_i good
        simp only [good, ↓reduceIte]
        have checked := good
        simp only [not_or, Bool.not_eq_true] at checked
        obtain ⟨expression, value⟩ := ScalarExpression.read_sound bound checked.1
        have ending := ScalarExpression.read_bounds bound checked.1
        have nextBound :
            (if parsed + 1 < length then fixedAfter text
              (ScalarExpression.read text position source.scalarNames
                (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
                (elaborating := true)).after "," false
             else (ScalarExpression.read text position source.scalarNames
                (arrays := source.arrayNames.names) (initials := source.arrayNames.values)
                (elaborating := true)).after) ≤ text.length + 1 := by
          split
          · exact model_fixed_valid text _ "," false ending.2.1
          · exact ending.2.1
        obtain ⟨rest, restRead⟩ := arrayValues_sound text source _ _ length (parsed + 1) nextBound accepted
        exact ⟨expression :: rest, .next positive remaining value checked.2.1
          (Classical.not_not.mp checked.2.2) restRead⟩
    · rename_i finished
      simp only [finished, ↓reduceDIte]
      exact ⟨[], .done positive (by omega)⟩
termination_by length - parsed
decreasing_by omega

theorem arrayValues_length {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    expressions.length = length - parsed := by
  induction reading with
  | done _ finished => simp; omega
  | next _ remaining _ _ _ _ ih => simp only [List.length_cons]; omega

theorem arrayValues_initialValues {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    ∃ values, Integer.arrayInitialValues (declarationRanges source) expressions = some values := by
  induction reading with
  | done => exact ⟨[], rfl⟩
  | @next result final position length parsed expression value rest _ _ reading _ singleton _ ih =>
      obtain ⟨values, checked⟩ := ih
      refine ⟨value.bounds.lower :: values, ?_⟩
      simp only [Integer.arrayInitialValues, declarationRanges, reading.inferred, Option.bind_some,
        singleton, ↓reduceIte, checked, Option.map_some]

theorem arrayValues_obligations {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    Integer.discharged (expressions.flatMap fun expression =>
      expression.obligations (declarationRanges source)) = true := by
  induction reading with
  | done => rfl
  | next _ _ reading _ _ _ ih =>
      simp only [List.flatMap_cons, Integer.discharged_append,
        Integer.Expr.obligations_discharge reading.inferred, ih, Bool.and_self]


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
        simpa only [absent, fixedAfter, ↓reduceIte] using checked.1
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
      ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) →
      ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) →
      ArrayAggregateAt text state parts position →
      ArrayValuesAt text state state position parts.length 0 expressions values →
      following = fixedAfter text (fixedAfter text values.position ")" false) ";" false →
      state.position < following →
      ArrayDeclarationAt text arguments state ⟨(parts.binding state).descriptor, expressions⟩
        {values with position := following, arrayNames := {values.arrayNames with
          names := values.arrayNames.names ++ [parts.binding state]}}

theorem arrayValues_positive {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) : final.position ≠ 0 := by
  induction reading with
  | done positive _ => exact positive
  | next _ _ _ _ _ _ ih => exact ih

theorem arrayValues_start_positive {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) : position ≠ 0 := by
  cases reading with
  | done positive _ => exact positive
  | next positive _ _ _ _ _ => exact positive

theorem array_declaration_positive {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) : final.position ≠ 0 := by
  cases reading with
  | declaration _ _ _ _ _ _ _ following => dsimp only; omega

theorem array_declaration_preserves {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.names = state.names ∧ final.scalarNames = state.scalarNames := by
  cases reading with
  | declaration _ _ _ _ _ values _ _ =>
      have preserved := arrayValuesModel_preserves _ _ _ _ _ _
        ((arrayValues_complete values).symm ▸ arrayValues_positive values)
      rw [arrayValues_complete values] at preserved
      exact ⟨preserved.1, preserved.2.1⟩

end Silver.Compose
