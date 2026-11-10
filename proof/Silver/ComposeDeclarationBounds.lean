module

public import Silver.ComposeDeclarations
public import Silver.ComposeDeclarationContext
public import Silver.ComposeStringBoundSafety

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

theorem namesBoundsValid_empty : NamesBoundsValid [] := by
  intro slot info present
  simp [BindingEnvironment.get] at present

theorem namesBoundsValid_append {names : BindingEnvironment} {info : BindingInfo}
    (before : NamesBoundsValid names) (next : info.BoundsValid (names.length + 1)) :
    NamesBoundsValid (names ++ [info]) := by
  intro slot found present
  rcases get_append_new present with old | ⟨rfl, rfl⟩
  · exact before slot found old
  · exact next

/-- Dynamic expressions use canonical placeholder metadata; their actual bounds
are deliberately not exposed by fixed-object indexing or slicing. -/
def ExpressionState.DynamicBounds (state : ExpressionState) : Prop :=
  state.dynamicCount ≠ 0 → state.firstIndex = .singleton 1 ∧ state.lastIndex = .singleton 0

theorem expressionStep_dynamicBounds {text names state scalarNames integerHidden arrays initials elaborating}
    (before : state.DynamicBounds) :
    (expressionStep text names state scalarNames integerHidden arrays initials elaborating).DynamicBounds := by
  dsimp only [expressionStep]
  split
  · simp [ExpressionState.DynamicBounds, invalidExpressionState]
  · split
    · exact before
    · split
      · split
        · exact before
        · split
          · simp [ExpressionState.DynamicBounds, invalidExpressionState]
          · intro dynamic
            dsimp only at dynamic ⊢
            have notFixed : ¬((elaborating = true ∧ state.dynamicCount = 0) ∧
                (valueAt text state.position names scalarNames integerHidden arrays initials elaborating).dynamicSeen = false) := by
              intro ⟨⟨_, zero⟩, fixed⟩
              simp [zero, fixed] at dynamic
            simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true']
            simp only [ite_eq_right notFixed, and_self]
      · split
        · exact before
        · split
          · exact before
          · split
            · exact before
            · simp [ExpressionState.DynamicBounds, invalidExpressionState]

theorem expressionTail_dynamicBounds {text names scalarNames integerHidden arrays initials elaborating}
    {state expression result}
    (parsed : ExpressionTailAt text names state expression result scalarNames integerHidden arrays initials elaborating)
    (before : state.DynamicBounds) :
    result.dynamicCount ≠ 0 → result.firstIndex = .singleton 1 ∧ result.lastIndex = .singleton 0 := by
  induction parsed with
  | done => exact before
  | last => exact expressionStep_dynamicBounds before
  | next _ _ _ _ _ _ _ ih => exact ih (expressionStep_dynamicBounds before)

theorem expressionAt_dynamicBounds {text names scalarNames integerHidden arrays initials elaborating}
    {position expression result}
    (parsed : ExpressionAt text names position expression result scalarNames integerHidden arrays initials elaborating)
    (dynamic : result.dynamicCount ≠ 0) :
    result.firstIndex = .singleton 1 ∧ result.lastIndex = .singleton 0 :=
  expressionTail_dynamicBounds parsed (by simp [ExpressionState.DynamicBounds]) dynamic

theorem expression_grouping {expression : Expression} (nonempty : expression ≠ []) :
    ∃ grouped : GroupedExpression, grouped.flatten = expression := by
  induction expression with
  | nil => contradiction
  | cons atom rest ih =>
      cases rest with
      | nil => exact ⟨.atom atom, rfl⟩
      | cons next tail =>
          obtain ⟨grouped, same⟩ := ih (by simp)
          exact ⟨.concatenate (.atom atom) grouped, by simp [GroupedExpression.flatten, same]⟩

theorem fixedDeclarationBounds_singletons {result : ExpressionResult} {slot : Nat}
    (checked : fixedDeclarationBounds result slot = true) (fixed : result.dynamicCount = 0) :
    result.firstIndex.lower = result.firstIndex.upper ∧
      result.lastIndex.lower = result.lastIndex.upper := by
  simp [fixedDeclarationBounds, fixed] at checked
  exact checked.1.2

/-- The singleton endpoints recorded by a fixed String declaration are the
actual Ada initializer bounds, including arbitrary inverted null bounds. -/
theorem string_initializer_bounds {text names scalarNames integerHidden arrays initials}
    {position expression result slot} {integers : Integer.Store}
    (input : Source) (normal : NamesNormal names)
    (scalars : Integer.Fits (ArrayBindings.integerRanges arrays initials true (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ExpressionAt text names position expression result scalarNames integerHidden arrays initials true)
    (checked : fixedDeclarationBounds result slot = true) (fixed : result.dynamicCount = 0) :
    expression.objectBounds names input integers = ⟨result.firstIndex.lower, result.lastIndex.lower⟩ := by
  have endpoints := fixedDeclarationBounds_singletons checked fixed
  exact (expressionAt_objectBounds input normal scalars parsed fixed).singleton endpoints.1 endpoints.2

theorem string_declaration_bounds {text arguments state next declaration input values}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (count : state.names.length ≤ maxBindings) (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : StringDeclarationAt text arguments state declaration next) : NamesBoundsValid next.names := by
  cases parsed with
  | @declaration parts expression _ _ _ _ bounded _ _ checked source =>
      apply namesBoundsValid_append metadata
      have checks := checked
      simp only [fixedDeclarationBounds, Bool.and_eq_true] at checks
      have slotCheck := checks.2
      refine ⟨?_, ?_, slotCheck⟩
      all_goals
        by_cases fixed : parts.value.dynamicCount = 0
        · have scalars := frozenIntegers_fits (arrays := state.arrayNames.names) (initials := state.arrayNames.values) static
          have nonempty := expressionTail_nonempty metadata.normal (by simp) (by rfl) (by rfl) source
          obtain ⟨grouped, ordered⟩ := expression_grouping nonempty
          have actual := expressionAt_grouped_objectBounds textBound inputBound count metadata source bounded
            strings scalars inputBound ordered
          have exactBounds := string_initializer_bounds input metadata.normal scalars source checked fixed
          rw [exactBounds] at actual
          first | exact actual.2.1.1 | exact actual.2.1.2.1
        · have endpoints := expressionAt_dynamicBounds source fixed
          simp only [ExpressionResult.value, endpoints.1, endpoints.2, Integer.Interval.singleton]
          decide

theorem character_declaration_bounds {text arguments state next declaration}
    (metadata : NamesBoundsValid state.names)
    (parsed : CharacterDeclarationAt text arguments state declaration next) : NamesBoundsValid next.names := by
  cases parsed with
  | declaration _ _ _ source =>
      apply namesBoundsValid_append metadata
      have fields := character_metadata source
      simp [BindingInfo.BoundsValid, fixedBoundsValid, fields.1, fields.2.2.1,
        fields.2.2.2.2.1, fields.2.2.2.2.2, Integer.Interval.singleton, Integer.InRange,
        Integer.minValue, Integer.maxValue]

theorem declaration_bounds {text arguments state next declaration input values}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (count : state.names.length ≤ maxBindings) (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationAt text arguments state declaration next) : NamesBoundsValid next.names := by
  cases parsed with
  | string _ source => exact string_declaration_bounds textBound inputBound count metadata strings static source
  | character source => exact character_declaration_bounds metadata source

theorem declaration_count_bound {text arguments state next declaration}
    (before : state.names.length ≤ maxBindings)
    (parsed : DeclarationAt text arguments state declaration next) : next.names.length ≤ maxBindings := by
  rw [declaration_count parsed]
  cases parsed with
  | string _ source => cases source; omega
  | character source =>
      cases source with
      | declaration _ checked _ _ =>
          simp only [characterDeclarationRejected, Bool.or_eq_false_iff, decide_eq_false_iff_not] at checked
          have notFull := checked.1.1.2
          omega

/-- The raw source tree and the frozen semantic initializer describe the same
bytes. Fixed String slots retain precisely that source initializer's bounds. -/
theorem string_declaration_capture {text arguments state next declaration}
    (input : Source) (values : Values) (normal : NamesNormal state.names)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : StringDeclarationAt text arguments state declaration next) :
    ∃ expression result info,
      ExpressionAt text state.names (declarationValuePosition text state) expression result
        state.scalarNames (declarationIntegerHidden text state) state.arrayNames.names state.arrayNames.values true ∧
      next.names.get declaration.index = some info ∧ info.isCharacter = false ∧
      declaration.initializer.evaluate values input = expression.evaluate values input
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
      (info.dynamic = false → BindingInfo.objectBounds info = expression.objectBounds state.names input
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)) := by
  cases parsed with
  | @declaration parts expression _ _ _ _ bounded nonempty _ checked source =>
      refine ⟨expression, parts.value,
        {first := parts.first, after := parts.after, valueFirst := 0,
          staticLength := parts.value.staticLength, dynamic := decide (parts.value.dynamicCount = 1),
          mutable := decide (parts.constantAfter = 0), isCharacter := false,
          firstIndex := parts.value.firstIndex.lower, lastIndex := parts.value.lastIndex.lower},
        source, ?_, rfl, ?_, ?_⟩
      · simp [addBinding, BindingEnvironment.get, ExpressionResult.value]
      · exact Expression.freezeImages_evaluate _ _ _ _
      · intro fixed
        have coefficients := expressionResult_coefficients bounded nonempty
        have notOne : parts.value.dynamicCount ≠ 1 := by
          simpa only [ExpressionResult.value, decide_eq_false_iff_not] using fixed
        have zero : parts.value.dynamicCount = 0 := by omega
        exact (string_initializer_bounds input normal (frozenIntegers_fits static) source checked zero).symm

/-- Character initialization stores exactly one source-evaluated character and
retains the distinct Character object kind with singleton representation bounds. -/
theorem character_declaration_capture {text arguments state next declaration}
    (input : Source) (values : Values)
    (parsed : CharacterDeclarationAt text arguments state declaration next) :
    ∃ position expression result info,
      CharacterAt text state.names state.scalarNames state.arrayNames.names state.arrayNames.values true
        position expression result ∧
      next.names.get declaration.index = some info ∧ info.isCharacter = true ∧
      BindingInfo.objectBounds info = Bounds.canonical 1 ∧
      declaration.initializer.evaluate values input =
        [expression.evaluate values (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)] := by
  cases parsed with
  | @declaration parts expression _ _ _ source =>
      refine ⟨_, expression, parts.value,
        {first := parts.first, after := parts.after, valueFirst := parts.value.valueFirst,
          staticLength := parts.value.staticLength, dynamic := parts.value.dynamicSeen,
          mutable := decide (parts.constantAfter = 0), isCharacter := true,
          firstIndex := parts.value.firstIndex.lower, lastIndex := parts.value.lastIndex.lower},
        source, ?_, rfl, ?_, ?_⟩
      · simp [addBinding, BindingEnvironment.get]
      · have fields := character_metadata source
        simp [BindingInfo.objectBounds, fields.2.2.2.2.1, fields.2.2.2.2.2,
          Integer.Interval.singleton, Bounds.canonical]
      · rw [Expression.freezeImages_evaluate]
        rfl

/-- Initialization is evaluated in declaration order. Each new slot's bound
invariant is derived from its source initializer and the actual prior store. -/
theorem declarations_bounds {text arguments state final declarations input values}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Printable input) (count : state.names.length ≤ maxBindings)
    (metadata : NamesBoundsValid state.names) (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationsAt text arguments state declarations final) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Fits final.names.shape input (executeDeclarations input declarations values) := by
  induction parsed generalizing values with
  | done => exact ⟨metadata, count, strings⟩
  | next _ _ _ _ _ _ _ first _ ih =>
      have nextBounds := declaration_bounds textBound inputBound count metadata strings static first
      obtain ⟨bound, valid, same⟩ := declaration_shape metadata.normal static first
      have nextStrings := Bindings.declaration_preserves strings printable valid
      rw [← same] at nextStrings
      exact ih (declaration_count_bound count first) nextBounds nextStrings
        ((declaration_scalarNames first).symm ▸ static)
  | scalar _ _ _ _ first _ ih =>
      have nextStatic := scalar_declaration_static static first
      cases first
      exact ih count metadata strings nextStatic
  | array _ _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).1, (array_declaration_preserves first).2] at ih
      exact ih count metadata strings static
  | booleanArray _ _ _ _ _ first _ ih =>
      rw [(boolean_array_declaration_preserves first).1, (boolean_array_declaration_preserves first).2.1] at ih
      exact ih count metadata strings static
  | subtype _ _ _ first _ ih => cases first; exact ih count metadata strings static
  | boolean _ _ _ _ _ _ first _ ih => cases first; exact ih count metadata strings static

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.names, kept.scalarNames] at ih
      exact ih count metadata strings static

theorem declarations_bounds_from_empty {text arguments state final declarations input}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Printable input) (empty : state.names = [])
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationsAt text arguments state declarations final) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Fits final.names.shape input (executeDeclarations input declarations emptyValues) := by
  apply declarations_bounds textBound inputBound printable _ _ _ static parsed
  · simp [empty]
  · rw [empty]; exact namesBoundsValid_empty
  · rw [empty, empty_names_shape]; exact empty_fits input

theorem argument_bounds {text state next fallback} (parsed : ArgumentAt text state fallback next) :
    NamesBoundsValid next.names ∧ next.names.length ≤ maxBindings := by
  cases parsed with
  | argument _ _ _ empty _ =>
      constructor
      · apply namesBoundsValid_append
        · rw [empty]; exact namesBoundsValid_empty
        · simp [BindingInfo.BoundsValid, fixedBoundsValid, Integer.Interval.singleton,
            Integer.InRange, Integer.minValue, Integer.maxValue]
      · simp [addBinding, empty, maxBindings, maxSourceLength]

theorem declarations_bounds_after_argument {text state middle final fallback declarations input}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Printable input) (static : ScalarExpression.StaticEnvironment middle.scalarNames)
    (argument : ArgumentAt text state fallback middle)
    (parsed : DeclarationsAt text true middle declarations final) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Fits final.names.shape input
        (executeDeclarations input declarations (argumentDeclaration.execute emptyValues input)) := by
  have metadata := argument_bounds argument
  have shape := argument_shape argument
  have strings := Bindings.declaration_preserves (empty_fits input) printable shape.2.2
  change Fits argumentShape input (argumentDeclaration.execute emptyValues input) at strings
  rw [← shape.2.1] at strings
  exact declarations_bounds textBound inputBound printable metadata.2 metadata.1 strings static parsed

end Silver.Compose
