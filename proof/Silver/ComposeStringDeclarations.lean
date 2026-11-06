module

public import Silver.ComposeFrozenSemantics

@[expose] public section

namespace Silver.Compose
open Named Bindings

theorem declarationParts_value (text : Source) (state : ParserState) :
    (declarationParts text state).value = expressionAt text (declarationValuePosition text state) state.names state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true := by
  simp only [declarationParts]

theorem fixedAfter_nonzero {text : Source} {position : Nat} {spelling : String} {word : Bool}
    (accepted : fixedAfter text position spelling word ≠ 0) : position ≠ 0 := by
  intro zero
  simp [fixedAfter, zero] at accepted

theorem declarationParts_following (text : Source) (state : ParserState) :
    (declarationParts text state).following = fixedAfter text (declarationParts text state).value.after ";" false := by
  simp only [declarationParts]

inductive StringDeclarationAt (text : Source) (arguments : Bool) : ParserState → Declaration → ParserState → Prop
  | declaration {state : ParserState} {parts : DeclarationParts} {value : Expression} :
      declarationParts text state = parts →
      newNameAllowed text state parts.first parts.after arguments = true →
      parts.following ≠ 0 → state.names.length ≠ maxBindings →
      fits parts.value maxSourceLength = true →
      parts.value.emptyValue = false → parts.value.minimumLength = parts.value.staticLength →
      fixedDeclarationBounds parts.value (state.names.length + 1) = true →
      ExpressionAt text state.names (declarationValuePosition text state) value parts.value state.scalarNames
        (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true →
      StringDeclarationAt text arguments state
        ⟨state.names.length + 1, decide (parts.constantAfter = 0), value.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩
        (addBinding state parts.first parts.after parts.value.value (decide (parts.constantAfter = 0)) parts.following)

theorem string_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : StringDeclarationAt text arguments state declaration next) :
    stringDeclarationAt text state arguments = next := by
  cases parsed with
  | declaration parts allowed following count bounded nonempty exact bounds _ =>
      simp [stringDeclarationAt, parts, allowed, following, count, bounded, nonempty, exact, bounds]

theorem string_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (stringDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, StringDeclarationAt text arguments state declaration (stringDeclarationAt text state arguments) := by
  generalize partsEq : declarationParts text state = parts
  have observed : stringDeclarationAt text state arguments =
      if !newNameAllowed text state parts.first parts.after arguments ||
          decide (parts.following = 0 ∨ state.names.length = maxBindings) || !fits parts.value maxSourceLength ||
          parts.value.emptyValue || decide (parts.value.minimumLength ≠ parts.value.staticLength) ||
          !fixedDeclarationBounds parts.value (state.names.length + 1)
      then invalidState
      else addBinding state parts.first parts.after parts.value.value (decide (parts.constantAfter = 0)) parts.following := by
    simp only [stringDeclarationAt, partsEq]
  have allowed : newNameAllowed text state parts.first parts.after arguments = true := by
    by_cases good : newNameAllowed text state parts.first parts.after arguments = true
    · exact good
    · simp [observed, good, invalidState] at accepted
  have following : parts.following ≠ 0 := by
    intro zero
    simp [observed, zero, invalidState] at accepted
  have count : state.names.length ≠ maxBindings := by
    intro full
    simp [observed, full, invalidState] at accepted
  have bounded : fits parts.value maxSourceLength = true := by
    by_cases good : fits parts.value maxSourceLength = true
    · exact good
    · simp [observed, good, invalidState] at accepted
  have nonempty : parts.value.emptyValue = false := by
    cases empty : parts.value.emptyValue with
    | false => rfl
    | true => simp [observed, empty, invalidState] at accepted
  have exact : parts.value.minimumLength = parts.value.staticLength := by
    by_cases same : parts.value.minimumLength = parts.value.staticLength
    · exact same
    · simp [observed, same, invalidState] at accepted
  have bounds : fixedDeclarationBounds parts.value (state.names.length + 1) = true := by
    by_cases good : fixedDeclarationBounds parts.value (state.names.length + 1) = true
    · exact good
    · simp [observed, good, invalidState] at accepted
  have valueEq := declarationParts_value text state
  rw [partsEq] at valueEq
  have valueNonzero : parts.value.after ≠ 0 := (decide_eq_true_eq.mp bounded).1
  rw [valueEq] at valueNonzero
  obtain ⟨value, parsed⟩ := expressionAt_sound (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := declarationIntegerHidden text state) text state.names (declarationValuePosition text state) valueNonzero
  refine ⟨⟨state.names.length + 1, decide (parts.constantAfter = 0), value.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩, ?_⟩
  rw [observed]
  simp only [allowed, Bool.not_true, following, count, or_self,
    decide_false, bounded, nonempty, exact, bounds, Bool.not_true, ne_eq, not_true_eq_false, Bool.false_eq_true, Bool.or_self, ↓reduceIte]
  exact .declaration partsEq allowed following count bounded nonempty exact bounds (valueEq.symm ▸ parsed)

theorem string_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : StringDeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ _ following _ _ _ _ _ _ => simpa only [addBinding] using following

theorem expressionResult_coefficients {result : ExpressionResult}
    (bounded : fits result maxSourceLength = true) (nonempty : result.emptyValue = false) :
    result.dynamicCount ≤ 1 ∧ (result.dynamicCount = 1 → result.staticLength = 0) := by
  have bound : result.staticLength + result.dynamicCount * maxSourceLength ≤ maxSourceLength := by
    simpa [nonempty] using (decide_eq_true_eq.mp bounded).2
  simp only [maxSourceLength] at bound
  omega

def ExpressionResult.bound (result : ExpressionResult) : Bindings.Bound := result.value.bound

theorem expressionResult_summary {result : ExpressionResult}
    (bounded : fits result maxSourceLength = true) (nonempty : result.emptyValue = false) :
    result.bound.summary = ⟨result.staticLength, result.dynamicCount⟩ ∧
      result.bound.length maxSourceLength ≤ maxSourceLength := by
  have coefficients := expressionResult_coefficients bounded nonempty
  have bound : result.staticLength + result.dynamicCount * maxSourceLength ≤ maxSourceLength := by
    simpa [nonempty] using (decide_eq_true_eq.mp bounded).2
  by_cases dynamic : result.dynamicCount = 1
  · simp [ExpressionResult.bound, ExpressionResult.value, ValueResult.bound,
      Bindings.Bound.summary, Bindings.Bound.length, dynamic, coefficients.2 dynamic]
  · have zero : result.dynamicCount = 0 := by omega
    simpa [ExpressionResult.bound, ExpressionResult.value, ValueResult.bound,
      Bindings.Bound.summary, Bindings.Bound.length, zero] using bound

theorem string_declaration_shape {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (normal : NamesNormal state.names)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : StringDeclarationAt text arguments state declaration next) :
    ∃ bound, declaration.Valid state.names.shape bound ∧
      next.names.shape = declaration.extend state.names.shape bound := by
  cases parsed with
  | declaration parts allowed following count bounded nonempty exact _ value =>
      have coefficients := expressionResult_summary bounded nonempty
      have safe := expressionAt_safe normal static value bounded
      have summary := expressionAt_frozen_summary normal static value exact
      refine ⟨_, ⟨environment_fresh _, ?_, safe.2.1, safe.2.2.1, safe.2.2.2.1, coefficients.2⟩, ?_⟩
      · exact Expression.infer_iff.mpr ⟨safe.1, summary.trans coefficients.1.symm⟩
      · simp only [addBinding, environment_append, Declaration.extend, BindingInfo.cell,
          BindingInfo.bound, ExpressionResult.bound, ExpressionResult.value, ValueResult.bound]
        rfl

theorem string_declaration_scalarNames {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : StringDeclarationAt text arguments state declaration next) :
    next.scalarNames = state.scalarNames := by
  cases parsed
  rfl

theorem get_append_new {names : BindingEnvironment} {info : BindingInfo} {index : Nat}
    {found : BindingInfo} (present : (names ++ [info]).get index = some found) :
    names.get index = some found ∨ (index = names.length + 1 ∧ found = info) := by
  by_cases zero : index = 0
  · simp [BindingEnvironment.get, zero] at present
  · by_cases before : index - 1 < names.length
    · left
      simpa [BindingEnvironment.get, zero, List.getElem?_append_left before] using present
    · right
      have after : names.length ≤ index - 1 := by omega
      simp only [BindingEnvironment.get, zero, ↓reduceIte, List.getElem?_append_right after] at present
      have within := (List.getElem?_eq_some_iff.mp present).1
      have same : index = names.length + 1 := by simp only [List.length_singleton] at within; omega
      subst index
      have reversed : info = found := by simpa using present
      exact ⟨rfl, reversed.symm⟩

theorem string_declaration_normal {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (normal : NamesNormal state.names)
    (parsed : StringDeclarationAt text arguments state declaration next) : NamesNormal next.names := by
  cases parsed with
  | declaration _ _ _ _ _ _ _ bounds _ =>
      simp only [fixedDeclarationBounds, Bool.and_eq_true] at bounds
      apply namesNormal_append (slot := state.names.length + 1) normal
      exact bounds.2

theorem string_declaration_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : Declaration} (first : StringDeclarationAt text arguments state left leftState)
    (second : StringDeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  have states := (string_declaration_complete first).symm.trans (string_declaration_complete second)
  refine ⟨?_, states⟩
  cases first with
  | declaration partsEq _ _ _ _ _ _ _ value =>
      cases second with
      | declaration otherEq _ _ _ _ _ _ _ other =>
          have same := partsEq.symm.trans otherEq
          cases same
          obtain ⟨rfl, _⟩ := expressionTail_unique value other
          rfl

end Silver.Compose
