module

public import Silver.ComposeDeclarations

@[expose] public section

/-! The scalar projection of the ordered declaration region retains every
Integer initializer. String declarations leave this store unchanged. Both
projections read the same mixed source region and have unique results. -/
namespace Silver.Compose

inductive ScalarDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Declaration → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → ScalarDeclarationsAt text arguments state [] state
  | string {state middle final : ParserState} {declaration : Bindings.Declaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state (declaration :: rest) final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

  | subtype {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      SubtypeDeclarationAt text arguments state middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

  | boolean {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

theorem declarations_scalar_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Bindings.Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ values, ScalarDeclarationsAt text arguments state values final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | next positive more noSubtype noScalar noArray noBoolean first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .string positive more noSubtype noScalar noArray noBoolean first reading⟩
  | scalar positive more noSubtype first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨_ :: values, .scalar positive more noSubtype first reading⟩
  | array positive more noSubtype noScalar first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .array positive more noSubtype noScalar first reading⟩
  | subtype positive more first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .subtype positive more first reading⟩

  | boolean positive more noSubtype noScalar noArray first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .boolean positive more noSubtype noScalar noArray first reading⟩

theorem scalar_declarations_static {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment final.scalarNames := by
  induction parsed with
  | done => exact static
  | string _ _ _ _ _ _ first _ ih =>
      cases first
      exact ih static
  | boolean _ _ _ _ _ first _ ih =>
      cases first
      exact ih static
  | scalar _ _ _ first _ ih => exact ih (scalar_declaration_static static first)
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih static

  | subtype _ _ first _ ih => cases first; exact ih static

theorem scalar_declarations_source_bounds {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames) :
    ∀ declaration ∈ values, ScalarDeclarationSourceBounds text declaration := by
  induction parsed with
  | done => simp
  | string _ _ _ _ _ _ first _ ih =>
      cases first
      exact ih elaborated
  | boolean _ _ _ _ _ first _ ih =>
      cases first
      exact ih elaborated
  | scalar _ _ _ first _ ih =>
      intro declaration member
      rcases List.mem_cons.mp member with rfl | member
      · exact scalar_declaration_source_bounds elaborated first
      · exact ih (scalar_declaration_static elaborated first) declaration member
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih elaborated

  | subtype _ _ first _ ih => cases first; exact ih elaborated

theorem scalar_declarations_count_bound {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    final.scalarNames.length ≤ ArrayBindings.scalarLimit := by
  induction parsed with
  | done => exact bounded
  | string _ _ _ _ _ _ first _ ih => cases first; exact ih bounded
  | boolean _ _ _ _ _ first _ ih => cases first; exact ih bounded
  | scalar _ _ _ first _ ih => exact ih (scalar_declaration_count_bound bounded first)
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih bounded

  | subtype _ _ first _ ih => cases first; exact ih bounded

theorem scalar_declarations_subtypes_valid {text arguments state final values}
    (parsed : ScalarDeclarationsAt text arguments state values final)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text final.subtypeNames := by
  induction parsed with
  | done => exact valid
  | string _ _ _ _ _ _ first _ ih => cases first; exact ih valid
  | boolean _ _ _ _ _ first _ ih => cases first; exact ih valid
  | scalar _ _ _ first _ ih => cases first; exact ih valid
  | subtype _ _ first _ ih => exact ih (subtype_declaration_valid first valid)
  | array _ _ _ _ first _ ih =>
      rw [array_declaration_subtypes first] at ih
      exact ih valid

theorem scalar_declarations_checked {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) values =
      some (ScalarExpression.constants final.scalarNames) := by
  induction parsed with
  | done => rfl
  | string _ _ _ _ _ _ first _ ih =>
      cases first
      exact ih static bounded subtypes
  | boolean _ _ _ _ _ first _ ih =>
      cases first
      exact ih static bounded subtypes
  | scalar _ _ _ first _ ih =>
      have sameSubtypes := scalar_declaration_subtypes first
      rw [sameSubtypes] at ih
      simp only [Integer.checkDeclarations, scalar_declaration_checked static bounded subtypes first, Option.bind_some]
      exact ih (scalar_declaration_static static first) (scalar_declaration_count_bound bounded first) subtypes
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih static bounded subtypes
  | subtype _ _ first _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih static bounded nextSubtypes

theorem scalar_declarations_objects {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (exact : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ScalarExpression.objectBindings final.scalarNames = ScalarExpression.objectBindings state.scalarNames ++
      Integer.elaborate (ScalarExpression.constants state.scalarNames) values := by
  induction parsed with
  | done => simp [Integer.elaborate]
  | string _ _ _ _ _ _ first _ ih =>
      cases first
      exact ih exact bounded subtypes
  | boolean _ _ _ _ _ first _ ih =>
      cases first
      exact ih exact bounded subtypes
  | scalar _ _ _ first _ ih =>
      have sameSubtypes := scalar_declaration_subtypes first
      rw [sameSubtypes] at ih
      have objects := scalar_declaration_objects exact bounded first
      have values := (Integer.Declaration.check_sound (scalar_declaration_checked exact bounded subtypes first)).1
      rw [ih (scalar_declaration_static exact first) (scalar_declaration_count_bound bounded first) subtypes, objects, values]
      simp only [Integer.elaborate, List.append_assoc, List.singleton_append]
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih exact bounded subtypes
  | subtype _ _ first _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih exact bounded nextSubtypes

theorem scalar_declarations_declared_bounds {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (valid : ScalarExpression.DeclaredBoundsValid state.scalarNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ScalarExpression.DeclaredBoundsValid final.scalarNames := by
  induction parsed with
  | done => exact valid
  | string _ _ _ _ _ _ first _ ih =>
      cases first
      exact ih valid subtypes
  | boolean _ _ _ _ _ first _ ih =>
      cases first
      exact ih valid subtypes
  | scalar _ _ _ first _ ih =>
      rw [scalar_declaration_subtypes first] at ih
      exact ih (scalar_declaration_declared_bounds valid subtypes first) subtypes
  | array _ _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih valid subtypes
  | subtype _ _ first _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih valid nextSubtypes

theorem scalar_declarations_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Integer.Declaration} (first : ScalarDeclarationsAt text arguments state left leftState)
    (second : ScalarDeclarationsAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done => exact ⟨rfl, rfl⟩
      | string _ more _ _ _ _ _ _ | scalar _ more _ _ _ | array _ more _ _ _ _ | subtype _ more _ _ | boolean _ more _ _ _ _ _ => exact False.elim (stop more)
  | string positive more noSubtype noScalar noArray noBoolean parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ _ _ other remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          exact ih remaining
      | scalar _ _ _ other _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ other _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | subtype _ _ other _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | scalar positive more noSubtype parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ noScalar _ _ _ _ | array _ _ _ noScalar _ _ | boolean _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | scalar _ _ _ other remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl⟩
      | subtype _ _ other _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | array positive more noSubtype noScalar parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ noArray _ _ _ | boolean _ _ _ _ noArray _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | scalar _ _ _ other _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other remaining =>
          have same := (array_declaration_complete parsed).symm.trans (array_declaration_complete other)
          cases same
          exact ih remaining

      | subtype _ _ other _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | subtype positive more parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ noSubtype _ _ _ _ _ | scalar _ _ noSubtype _ _ | array _ _ noSubtype _ _ _ | boolean _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | subtype _ _ other remaining =>
          have same := subtype_declaration_unique parsed other
          cases same
          exact ih remaining

  | boolean positive more noSubtype noScalar noArray parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ _ noBoolean _ _ =>
          have accepted := boolean_declaration_positive parsed
          rw [← boolean_declaration_complete parsed, noBoolean] at accepted
          contradiction
      | scalar _ _ _ other _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | subtype _ _ other _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | boolean _ _ _ _ _ other remaining =>
          have same := boolean_declaration_unique parsed other
          cases same
          exact ih remaining

end Silver.Compose
