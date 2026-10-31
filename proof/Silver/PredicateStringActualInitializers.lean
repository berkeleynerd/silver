module

public import Silver.PredicateStringActualExecution

@[expose] public section

/-! Exact source initialization stores actual bounds, allowing a dynamic null
String to retain different valid endpoints from its canonical metadata model. -/

namespace Silver.Compose
open Bindings StringObjectBounds

theorem Expression.foldBounds_freezeImages (expression : Expression)
    (snapshot after : Integer.Store) (names : BindingEnvironment) (input : Source)
    (initial : Bounds) :
    (expression.freezeImages snapshot).foldBounds names input after initial =
      expression.foldBounds names input snapshot initial := by
  induction expression generalizing initial with
  | nil => rfl
  | cons atom rest ih =>
      simp only [Expression.freezeImages, List.map_cons, Expression.foldBounds,
        List.foldl_cons, Operand.freezeImages_objectBounds]
      exact ih _

theorem Expression.freezeImages_objectBounds (expression : Expression)
    (snapshot after : Integer.Store) (names : BindingEnvironment) (input : Source) :
    (expression.freezeImages snapshot).objectBounds names input after =
      expression.objectBounds names input snapshot :=
  Expression.foldBounds_freezeImages expression snapshot after names input (.canonical 0)

theorem Expression.objectBounds_valid_of_safe {expression : Expression}
    {names : BindingEnvironment} {values : Values} {input : Source} {integers : Integer.Store}
    (safe : expression.ObjectBoundsSafe names values input integers) :
    (expression.objectBounds names input integers).Valid := by
  by_cases empty : expression = []
  · subst expression
    exact (show (Bounds.canonical 0).Valid from by decide)
  · obtain ⟨grouped, ordered⟩ := Expression.exists_grouped empty
    have valid := (safe grouped ordered).2.1
    simpa only [← GroupedExpression.flatten_objectBounds, ordered] using valid

theorem declaration_initializer_boundsOrigin {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) :
    declaration.initializer.BoundsOrigin state.names := by
  cases parsed with
  | string _ source =>
      cases source with
      | declaration _ _ _ _ _ _ _ _ expression =>
          exact Expression.boundsOrigin_freeze _ (expression_boundsOrigin expression)
  | character source =>
      cases source with
      | declaration _ _ _ character =>
          apply Expression.boundsOrigin_freeze
          intro atom member
          have same := List.mem_singleton.mp member
          subst atom
          exact character_boundsOrigin character

end Silver.Compose

namespace Silver.Predicate
open Bindings Compose StringObjectBounds

theorem raw_initializer_frozen_bounds {text program state next declaration input values}
    (raw : RawStringInitializerBounds text program state next declaration input values ∨
      RawCharacterInitializerBounds text program state next declaration input values) :
    ∀ after, declaration.initializer.ObjectBoundsSafe state.names values input after := by
  rcases raw with string | character
  · obtain ⟨_, _, _, _, _, _, _, _, _, _, _, frozen, _, _⟩ := string
    exact frozen
  · obtain ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, frozen, _⟩ := character
    exact frozen

/-- Exact allocation and the source-selected initializer bounds are derived
together. Dynamic empty values may retain any valid null endpoints. -/
theorem declaration_target_bounds_equivalent
    {text arguments state next declaration input values program}
    (inputBound : input.length ≤ maxSourceLength)
    (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationAt text arguments state declaration next)
    (raw : RawStringInitializerBounds text program state next declaration input values ∨
      RawCharacterInitializerBounds text program state next declaration input values) :
    ∃ info, next.names = state.names ++ [info] ∧
      declaration.index = state.names.length + 1 ∧
      next.names.get declaration.index = some info ∧
      (declaration.initializer.objectBounds state.names input Integer.emptyStore).NullEquivalent
        (namedModelBounds info input) := by
  have frozenBounds := raw_initializer_frozen_bounds raw Integer.emptyStore
  cases parsed with
  | string _ source =>
      have capture := string_declaration_capture input values metadata.normal static source
      cases source with
      | @declaration parts expression partsEq allowed following notFull bounded nonempty exactLength fixedBounds source =>
          let info : Bindings.BindingInfo :=
            {first := parts.first, after := parts.after, valueFirst := 0,
              staticLength := parts.value.staticLength, dynamic := decide (parts.value.dynamicCount = 1),
              mutable := decide (parts.constantAfter = 0), isCharacter := false,
              firstIndex := parts.value.firstIndex.lower, lastIndex := parts.value.lastIndex.lower}
          have selected :
              (addBinding state parts.first parts.after parts.value.value
                (decide (parts.constantAfter = 0)) parts.following).names.get
                  (state.names.length + 1) = some info := by
            simp [addBinding, BindingEnvironment.get, ExpressionResult.value, info]
          obtain ⟨captured, result, capturedInfo, reading, capturedSelected, typed, bytes, exactBounds⟩ := capture
          have sameExpression := (expressionTail_unique source reading).1
          cases sameExpression
          have sameInfo : capturedInfo = info := Option.some.inj (capturedSelected.symm.trans selected)
          subst capturedInfo
          refine ⟨info, rfl, rfl, selected, ?_⟩
          cases dynamic : info.dynamic with
          | false =>
              have sameBounds := exactBounds dynamic
              rw [namedModelBounds, dynamic]
              simp only [Bool.false_eq_true, ↓reduceIte]
              rw [Expression.freezeImages_objectBounds, ← sameBounds]
              apply Bounds.NullEquivalent.refl
              rw [sameBounds, ← Expression.freezeImages_objectBounds expression
                (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)
                Integer.emptyStore state.names input]
              exact Expression.objectBounds_valid_of_safe frozenBounds
          | true =>
              have one : parts.value.dynamicCount = 1 := by
                simpa only [info, decide_eq_true_eq] using dynamic
              have zero := (expressionResult_coefficients bounded nonempty).2 one
              have summary := expressionAt_frozen_summary metadata.normal static source exactLength
              have safe := expressionAt_safe metadata.normal static source bounded
              have scalars := frozenIntegers_fits (arrays := state.arrayNames.names)
                (initials := state.arrayNames.values) static
              have rawRuntime : expression.RuntimeSafe values input
                  (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) := by
                refine ⟨(Expression.inferLength_sound
                  (expressionAt_inferLength metadata.normal source) strings scalars).2, ?_⟩
                rw [← Expression.freezeImages_evaluate]
                exact Expression.output_bound safe strings inputBound
              have staticZero :
                  (expression.freezeImages
                    (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).staticLength
                      state.names.shape = 0 := by
                have first := congrArg Summary.staticLength summary
                simpa only [Expression.summary, zero] using first
              have length :
                  ((expression.freezeImages
                    (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).evaluate
                      values input).length = input.length := by
                have evaluated := Expression.evaluate_length strings safe.1
                change _ = ((expression.freezeImages
                  (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).summary
                    state.names.shape).length input.length at evaluated
                simpa only [summary, Summary.length, zero, one, Nat.one_mul, Nat.zero_add] using evaluated
              rw [namedModelBounds, dynamic]
              simp only [↓reduceIte]
              exact Expression.zero_static_bounds_equivalent metadata strings
                (Expression.boundsOrigin_freeze _ (expression_boundsOrigin source)) safe.1
                (frozen_expression_safe rawRuntime) staticZero length frozenBounds
  | character source =>
      cases source with
      | @declaration parts expression partsEq checked following source =>
          let info : Bindings.BindingInfo :=
            {first := parts.first, after := parts.after, valueFirst := parts.value.valueFirst,
              staticLength := parts.value.staticLength, dynamic := parts.value.dynamicSeen,
              mutable := decide (parts.constantAfter = 0), isCharacter := true,
              firstIndex := parts.value.firstIndex.lower, lastIndex := parts.value.lastIndex.lower}
          refine ⟨info, rfl, rfl, ?_, ?_⟩
          · simp [addBinding, BindingEnvironment.get, info]
          · have fields := character_metadata source
            have initializer :
                (Expression.freezeImages [.character expression]
                  (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).objectBounds
                    state.names input Integer.emptyStore = Bounds.canonical 1 := by
              rw [Expression.freezeImages_objectBounds]
              simp [Expression.objectBounds, Expression.foldBounds, Operand.objectBounds,
                Bounds.concatenate, Bounds.isNull, Bounds.canonical]
            rw [initializer]
            have modeled : namedModelBounds info input = Bounds.canonical 1 := by
              simp [namedModelBounds, info, fields.1, BindingInfo.objectBounds,
                fields.2.2.2.2.1, fields.2.2.2.2.2, Integer.Interval.singleton, Bounds.canonical]
            rw [modeled]
            exact Bounds.NullEquivalent.refl (by decide)

theorem declaration_executeBounds_compatible
    {text arguments state next declaration input values program bounds}
    (inputBound : input.length ≤ maxSourceLength)
    (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationAt text arguments state declaration next)
    (raw : RawStringInitializerBounds text program state next declaration input values ∨
      RawCharacterInitializerBounds text program state next declaration input values)
    (compatible : bounds.Compatible state.names input) :
    (declaration.executeBounds bounds input).Compatible next.names input := by
  obtain ⟨info, appended, fresh, selected, modeled⟩ :=
    declaration_target_bounds_equivalent inputBound metadata strings static parsed raw
  have actual := Expression.actualBounds_equivalent compatible
    (declaration_initializer_boundsOrigin parsed) (raw_initializer_frozen_bounds raw Integer.emptyStore)
  intro index found present
  rw [appended] at present
  rcases get_append_new present with old | ⟨rfl, rfl⟩
  · have different : index ≠ declaration.index := by
      intro same
      rw [same, fresh] at old
      simp [BindingEnvironment.get] at old
    simpa only [Declaration.executeBounds, Bindings.put_other _ _ _ _ different] using
      compatible index found old
  · simpa only [Declaration.executeBounds, fresh, Bindings.put_same] using actual.trans modeled

def RawStringInitializerActualBounds (text : Source) (state : ParserState)
    (declaration : Declaration) (input : Source) (values : Values) (bounds : BoundsStore) : Prop :=
  ∃ raw result,
    ExpressionAt text state.names (declarationValuePosition text state) raw result
      state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true ∧
    declaration.initializer = raw.freezeImages
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    raw.ActualBoundsSafe bounds state.names values input
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    (∀ after, declaration.initializer.ActualBoundsSafe bounds state.names values input after)

def RawCharacterInitializerActualBounds (text : Source) (state : ParserState)
    (declaration : Declaration) (input : Source) (values : Values) (bounds : BoundsStore) : Prop :=
  ∃ position raw result,
    CharacterAt text state.names state.scalarNames state.arrayNames.names state.arrayNames.values true
      position raw result ∧
    declaration.initializer = Expression.freezeImages [.character raw]
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    Expression.ActualBoundsSafe [.character raw] bounds state.names values input
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    (∀ after, declaration.initializer.ActualBoundsSafe bounds state.names values input after)

def RawBooleanInitializerActualBounds (text : Source) (state : ParserState)
    (declaration : BooleanDeclaration) (input : Source) (inputValid : Bool)
    (values : Values) (bounds : BoundsStore) : Prop :=
  ∃ raw,
    ConditionAt text (booleanDeclarationContext state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      raw (booleanDeclarationValue text state) state.arrayNames.values ∧
    declaration = ⟨decide ((booleanDeclarationParts text state).constantAfter = 0),
      raw.freezeIntegers (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩ ∧
    (∀ booleans, raw.ActualBoundsSafe bounds state.names values input inputValid
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) booleans) ∧
    (∀ after booleans,
      declaration.value.ActualBoundsSafe bounds state.names values input inputValid after booleans)

theorem raw_string_initializer_actualBounds {text program state next declaration input values bounds}
    (compatible : bounds.Compatible state.names input)
    (witness : RawStringInitializerBounds text program state next declaration input values) :
    RawStringInitializerActualBounds text state declaration input values bounds := by
  obtain ⟨raw, result, _, source, frozen, _, _, _, _, _, rawSafe, frozenSafe, _, _⟩ := witness
  have origin := expression_boundsOrigin source
  refine ⟨raw, result, source, frozen, Expression.actualBoundsSafe compatible origin rawSafe, ?_⟩
  intro after
  apply Expression.actualBoundsSafe compatible _ (frozenSafe after)
  rw [frozen]
  exact Expression.boundsOrigin_freeze _ origin

theorem raw_character_initializer_actualBounds {text program state next declaration input values bounds}
    (compatible : bounds.Compatible state.names input)
    (witness : RawCharacterInitializerBounds text program state next declaration input values) :
    RawCharacterInitializerActualBounds text state declaration input values bounds := by
  obtain ⟨position, raw, result, _, source, frozen, _, _, _, _, _, _, rawSafe, frozenSafe, _⟩ := witness
  have origin : Expression.BoundsOrigin [.character raw] state.names := by
    intro atom member
    have same := List.mem_singleton.mp member
    subst atom
    exact character_boundsOrigin source
  refine ⟨position, raw, result, source, frozen, Expression.actualBoundsSafe compatible origin rawSafe, ?_⟩
  intro after
  apply Expression.actualBoundsSafe compatible _ (frozenSafe after)
  rw [frozen]
  exact Expression.boundsOrigin_freeze _ origin

theorem raw_boolean_initializer_actualBounds
    {text program state declaration checks input inputValid values bounds}
    (compatible : bounds.Compatible state.names input)
    (witness : RawBooleanInitializerBounds text program state declaration checks input inputValid values) :
    RawBooleanInitializerActualBounds text state declaration input inputValid values bounds := by
  obtain ⟨raw, source, frozen, _, _, rawSafe, frozenSafe⟩ := witness
  have origin : raw.BoundsOrigin state.names := condition_boundsOrigin source
  refine ⟨raw, source, frozen, ?_, ?_⟩
  · intro booleans
    exact Condition.actualBoundsSafe compatible origin (rawSafe booleans)
  · intro after booleans
    apply Condition.actualBoundsSafe compatible _ (frozenSafe after booleans)
    rw [frozen]
    exact Condition.boundsOrigin_freeze _ origin

/-- Actual initializer checks follow the same mixed source order. Every String
or Character step stores the initializer fold; every other declaration keeps
the bounds store. The paired raw trace retains token and certificate evidence. -/
inductive ActualHeaderBoundsTrace (text : Source) (arguments : Bool)
    (input : Source) (inputValid : Bool) :
    ParserState → Values → BoundsStore → List Declaration → List BooleanDeclaration →
      List Obligation → ParserState → Prop
  | done {state values bounds} :
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds [] [] [] state
  | string {state middle final values bounds declaration strings booleans checks} :
      DeclarationAt text arguments state declaration middle →
      (RawStringInitializerActualBounds text state declaration input values bounds ∨
        RawCharacterInitializerActualBounds text state declaration input values bounds) →
      ActualHeaderBoundsTrace text arguments input inputValid middle
        (declaration.execute values input) (declaration.executeBounds bounds input) strings booleans checks final →
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds
        (declaration :: strings) booleans checks final
  | scalar {state middle final values bounds declaration strings booleans checks} :
      ScalarDeclarationAt text arguments state declaration middle →
      ActualHeaderBoundsTrace text arguments input inputValid middle values bounds strings booleans checks final →
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds strings booleans checks final
  | array {state middle final values bounds declaration strings booleans checks} :
      ArrayDeclarationAt text arguments state declaration middle →
      ActualHeaderBoundsTrace text arguments input inputValid middle values bounds strings booleans checks final →
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds strings booleans checks final
  | subtype {state middle final values bounds strings booleans checks} :
      SubtypeDeclarationAt text arguments state middle →
      ActualHeaderBoundsTrace text arguments input inputValid middle values bounds strings booleans checks final →
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds strings booleans checks final
  | boolean {state middle final values bounds declaration strings booleans firstChecks checks} :
      BooleanDeclarationAt text arguments state middle →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      RawBooleanInitializerActualBounds text state declaration input inputValid values bounds →
      ActualHeaderBoundsTrace text arguments input inputValid middle values bounds strings booleans checks final →
      ActualHeaderBoundsTrace text arguments input inputValid state values bounds strings
        (declaration :: booleans) (firstChecks ++ checks) final

theorem RawHeaderBoundsTrace.actual_bounds
    {text arguments program input inputValid state values strings booleans checks final bounds}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Bindings.Printable input)
    (count : state.names.length ≤ maxBindings) (metadata : NamesBoundsValid state.names)
    (stringsFit : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (compatible : bounds.Compatible state.names input)
    (trace : RawHeaderBoundsTrace text arguments program input inputValid
      state values strings booleans checks final) :
    (executeDeclarationsBounds input strings bounds).Compatible final.names input ∧
      ActualHeaderBoundsTrace text arguments input inputValid
        state values bounds strings booleans checks final := by
  induction trace generalizing bounds with
  | done positive stop => exact ⟨compatible, .done⟩
  | string positive more noSubtype noScalar noArray noBoolean first raw tail ih =>
      have nextMetadata := declaration_bounds textBound inputBound count metadata stringsFit static first
      have nextCount := declaration_count_bound count first
      obtain ⟨bound, declarationValid, shape⟩ := declaration_shape metadata.normal static first
      have nextStrings := Bindings.declaration_preserves stringsFit printable declarationValid
      rw [← shape] at nextStrings
      have nextStatic := (declaration_scalarNames first).symm ▸ static
      have nextCompatible := declaration_executeBounds_compatible inputBound metadata stringsFit static first raw compatible
      obtain ⟨finalCompatible, actualTail⟩ := ih nextCount nextMetadata nextStrings nextStatic nextCompatible
      refine ⟨finalCompatible, .string first ?_ actualTail⟩
      rcases raw with string | character
      · exact Or.inl (raw_string_initializer_actualBounds compatible string)
      · exact Or.inr (raw_character_initializer_actualBounds compatible character)
  | @scalar state middle final values declaration strings booleans checks positive more noSubtype first tail ih =>
      have nextStatic := scalar_declaration_static static first
      have names : middle.names = state.names := by cases first; rfl
      obtain ⟨finalCompatible, actualTail⟩ := ih
        (names.symm ▸ count) (names.symm ▸ metadata) (names.symm ▸ stringsFit)
        nextStatic (names.symm ▸ compatible)
      exact ⟨finalCompatible, .scalar first actualTail⟩
  | array positive more noSubtype noScalar first tail ih =>
      have names := (array_declaration_preserves first).1
      have scalars := (array_declaration_preserves first).2
      obtain ⟨finalCompatible, actualTail⟩ := ih
        (names.symm ▸ count) (names.symm ▸ metadata) (names.symm ▸ stringsFit)
        (scalars.symm ▸ static) (names.symm ▸ compatible)
      exact ⟨finalCompatible, .array first actualTail⟩
  | @subtype state middle final values strings booleans checks positive more first tail ih =>
      have names : middle.names = state.names := by cases first; rfl
      have scalars : middle.scalarNames = state.scalarNames := by cases first; rfl
      obtain ⟨finalCompatible, actualTail⟩ := ih
        (names.symm ▸ count) (names.symm ▸ metadata) (names.symm ▸ stringsFit)
        (scalars.symm ▸ static) (names.symm ▸ compatible)
      exact ⟨finalCompatible, .subtype first actualTail⟩
  | boolean positive more noSubtype noScalar noArray first source raw tail ih =>
      have names := (boolean_declaration_preserves first).1
      have scalars := (boolean_declaration_preserves first).2.1
      obtain ⟨finalCompatible, actualTail⟩ := ih
        (names.symm ▸ count) (names.symm ▸ metadata) (names.symm ▸ stringsFit)
        (scalars.symm ▸ static) (names.symm ▸ compatible)
      exact ⟨finalCompatible, .boolean first source
        (raw_boolean_initializer_actualBounds compatible raw) actualTail⟩

end Silver.Predicate
