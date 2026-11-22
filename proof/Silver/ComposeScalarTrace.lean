module

public import Silver.ComposeDeclarations
public import Silver.ComposeDeclarationContext

@[expose] public section

/-! The scalar projection of the ordered declaration region retains every
Integer initializer. String declarations leave this store unchanged. Both
projections read the same mixed source region and have unique results. -/
namespace Silver.Compose

set_option maxHeartbeats 2000000

inductive ScalarDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Declaration → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → ScalarDeclarationsAt text arguments state [] state
  | callable {state final : ParserState} {rest : List Integer.Declaration}  :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      ScalarDeclarationsAt text arguments (callableDeclarationAt text state arguments) rest final →
      ScalarDeclarationsAt text arguments state rest final
  | arrayType {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      ArrayTypeDeclarationAt text arguments state middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final
  | string {state middle final : ParserState} {declaration : Bindings.Declaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state (declaration :: rest) final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

  | booleanArray {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

  | subtype {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

  | boolean {state middle final : ParserState} {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final

theorem declarations_scalar_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Bindings.Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ values, ScalarDeclarationsAt text arguments state values final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | arrayType positive more noCallable first _ ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .arrayType positive more noCallable first reading⟩
  | next positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .string positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType reading⟩
  | scalar positive more noCallable noSubtype first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨_ :: values, .scalar positive more noCallable noSubtype first noArrayType reading⟩
  | array positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .array positive more noCallable noSubtype noScalar first noArrayType reading⟩
  | booleanArray positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .booleanArray positive more noCallable noSubtype noScalar first noArrayType reading⟩
  | subtype positive more noCallable first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .subtype positive more noCallable first noArrayType reading⟩

  | boolean positive more noCallable noSubtype noScalar noArray first noArrayType rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .boolean positive more noCallable noSubtype noScalar noArray first noArrayType reading⟩

  | callable positive more accepted _ ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .callable positive more accepted reading⟩

theorem scalar_declarations_static {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment final.scalarNames := by
  induction parsed with
  | done => exact static
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first] at ih
      exact ih static
  | boolean _ _ _ _ _ _ first _ _ ih =>
      cases first
      exact ih static
  | scalar _ _ _ _ first _ _ ih => exact ih (scalar_declaration_static static first)
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih static

  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1] at ih
      exact ih static

  | subtype _ _ _ first _ _ ih => cases first; exact ih static
  | arrayType _ _ _ first _ ih => cases first; exact ih static

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
      exact ih static

theorem scalar_declarations_source_bounds {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    ∀ declaration ∈ values, ScalarDeclarationSourceBounds text declaration := by
  induction parsed with
  | done => simp
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first] at ih
      exact ih elaborated bounded
  | boolean _ _ _ _ _ _ first _ _ ih =>
      cases first
      exact ih elaborated bounded
  | scalar _ _ _ _ first _ _ ih =>
      intro declaration member
      rcases List.mem_cons.mp member with rfl | member
      · exact scalar_declaration_source_bounds elaborated bounded first
      · exact ih (scalar_declaration_static elaborated first) (scalar_declaration_count_bound bounded first) declaration member
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih elaborated bounded

  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1] at ih
      exact ih elaborated bounded

  | subtype _ _ _ first _ _ ih => cases first; exact ih elaborated bounded
  | arrayType _ _ _ first _ ih => cases first; exact ih elaborated bounded

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
      exact ih elaborated bounded

theorem scalar_declarations_count_bound {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    final.scalarNames.length ≤ ArrayBindings.scalarLimit := by
  induction parsed with
  | done => exact bounded
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first] at ih
      exact ih bounded
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih bounded
  | scalar _ _ _ _ first _ _ ih => exact ih (scalar_declaration_count_bound bounded first)
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih bounded

  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1] at ih
      exact ih bounded

  | subtype _ _ _ first _ _ ih => cases first; exact ih bounded
  | arrayType _ _ _ first _ ih => cases first; exact ih bounded

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
      exact ih bounded

theorem scalar_declarations_subtypes_valid {text arguments state final values}
    (parsed : ScalarDeclarationsAt text arguments state values final)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text final.subtypeNames := by
  induction parsed with
  | done => exact valid
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_subtypeNames first] at ih
      exact ih valid
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih valid
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih valid
  | subtype _ _ _ first _ _ ih => exact ih (subtype_declaration_valid first valid)
  | arrayType _ _ _ first _ ih => cases first; exact ih valid
  | array _ _ _ _ _ first _ _ ih =>
      rw [array_declaration_subtypes first] at ih
      exact ih valid

  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih valid

  | callable _ _ accepted _ ih =>
      apply ih
      simpa only [IntegerSubtypes.ValidEnvironment,
        (callableDeclarationAt_preserves_outer _ _ _ accepted).subtypeItems] using valid

theorem scalar_declarations_checked {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (stored : state.StoredArrays) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) values =
      some (ScalarExpression.constants final.scalarNames) := by
  induction parsed with
  | done => rfl
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first, declaration_subtypeNames first] at ih
      exact ih static bounded subtypes (declaration_stored stored first)
  | boolean _ _ _ _ _ _ first _ _ ih =>
      cases first
      exact ih static bounded subtypes stored
  | scalar _ _ _ _ first _ _ ih =>
      have sameSubtypes := scalar_declaration_subtypes first
      rw [sameSubtypes] at ih
      simp only [Integer.checkDeclarations, scalar_declaration_checked static bounded subtypes stored first, Option.bind_some]
      exact ih (scalar_declaration_static static first) (scalar_declaration_count_bound bounded first) subtypes (scalar_declaration_stored stored first)
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih static bounded subtypes (array_declaration_stored stored first)
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1, (boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih static bounded subtypes (boolean_array_declaration_stored stored first)
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih static bounded nextSubtypes stored

  | arrayType _ _ _ first _ ih => cases first; exact ih static bounded subtypes stored

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.scalarNames] at ih
      apply ih static bounded _ (by simpa only [ParserState.StoredArrays, kept.arrayNames] using stored)
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

theorem scalar_declarations_objects {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (exact : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (stored : state.StoredArrays) :
    ScalarExpression.objectBindings final.scalarNames = ScalarExpression.objectBindings state.scalarNames ++
      Integer.elaborate (ScalarExpression.constants state.scalarNames) values := by
  induction parsed with
  | done => simp [Integer.elaborate]
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first, declaration_subtypeNames first] at ih
      exact ih exact bounded subtypes (declaration_stored stored first)
  | boolean _ _ _ _ _ _ first _ _ ih =>
      cases first
      exact ih exact bounded subtypes stored
  | scalar _ _ _ _ first _ _ ih =>
      have sameSubtypes := scalar_declaration_subtypes first
      rw [sameSubtypes] at ih
      have objects := scalar_declaration_objects exact bounded stored first
      have values := (Integer.Declaration.check_sound (scalar_declaration_checked exact bounded subtypes stored first)).1
      rw [ih (scalar_declaration_static exact first) (scalar_declaration_count_bound bounded first) subtypes (scalar_declaration_stored stored first), objects, values]
      simp only [Integer.elaborate, List.append_assoc, List.singleton_append]
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih exact bounded subtypes (array_declaration_stored stored first)
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1, (boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih exact bounded subtypes (boolean_array_declaration_stored stored first)
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih exact bounded nextSubtypes stored

  | arrayType _ _ _ first _ ih => cases first; exact ih exact bounded subtypes stored

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.scalarNames] at ih
      apply ih exact bounded _ (by simpa only [ParserState.StoredArrays, kept.arrayNames] using stored)
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

theorem scalar_declarations_declared_bounds {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (valid : ScalarExpression.DeclaredBoundsValid state.scalarNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ScalarExpression.DeclaredBoundsValid final.scalarNames := by
  induction parsed with
  | done => exact valid
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first, declaration_subtypeNames first] at ih
      exact ih valid subtypes
  | boolean _ _ _ _ _ _ first _ _ ih =>
      cases first
      exact ih valid subtypes
  | scalar _ _ _ _ first _ _ ih =>
      rw [scalar_declaration_subtypes first] at ih
      exact ih (scalar_declaration_declared_bounds valid subtypes first) subtypes
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2, array_declaration_subtypes first] at ih
      exact ih valid subtypes
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1, (boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih valid subtypes
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih valid nextSubtypes

  | arrayType _ _ _ first _ ih => cases first; exact ih valid subtypes

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.scalarNames] at ih
      apply ih valid
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

theorem scalar_declarations_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Integer.Declaration} (first : ScalarDeclarationsAt text arguments state left leftState)
    (second : ScalarDeclarationsAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done _ _ =>
          exact ⟨rfl, rfl⟩
      | callable _ more _ _ =>
          exact False.elim (stop more)
      | arrayType _ more _ _ _ =>
          exact False.elim (stop more)
      | subtype _ more _ _ _ _ =>
          exact False.elim (stop more)
      | scalar _ more _ _ _ _ _ =>
          exact False.elim (stop more)
      | array _ more _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | booleanArray _ more _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | boolean _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | string _ more _ _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
  | callable positive more accepted rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ _ remaining =>
          exact ih remaining
      | arrayType _ _ noCallable _ _ =>
          exact False.elim (accepted noCallable)
      | subtype _ _ noCallable _ _ _ =>
          exact False.elim (accepted noCallable)
      | scalar _ _ noCallable _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | array _ _ noCallable _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | booleanArray _ _ noCallable _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | boolean _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | string _ _ noCallable _ _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
  | arrayType positive more noCallable parsed rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other remaining =>
          have same := (array_type_declaration_complete parsed).symm.trans (array_type_declaration_complete other)
          cases same
          exact ih remaining
      | subtype _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | scalar _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | array _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | booleanArray _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | boolean _ _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | string _ _ _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
  | subtype positive more noCallable parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ remaining =>
          have same := (subtype_declaration_complete parsed).symm.trans (subtype_declaration_complete other)
          cases same
          exact ih remaining
      | scalar _ _ _ noSubtype _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | array _ _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | booleanArray _ _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | boolean _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | string _ _ _ noSubtype _ _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
  | scalar positive more noCallable noSubtype parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl⟩
      | array _ _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | booleanArray _ _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | boolean _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | string _ _ _ _ noScalar _ _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
  | array positive more noCallable noSubtype noScalar parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ remaining =>
          have same := (array_declaration_complete parsed).symm.trans (array_declaration_complete other)
          cases same
          exact ih remaining
      | booleanArray _ _ _ _ _ other _ _ =>
          exact False.elim (array_declaration_kinds_disjoint parsed other)
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
  | booleanArray positive more noCallable noSubtype noScalar parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          exact False.elim (array_declaration_kinds_disjoint other parsed)
      | booleanArray _ _ _ _ _ other _ remaining =>
          have same := (boolean_array_declaration_complete parsed).symm.trans (boolean_array_declaration_complete other)
          cases same
          exact ih remaining
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
  | boolean positive more noCallable noSubtype noScalar noArray parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ remaining =>
          have same := (boolean_declaration_complete parsed).symm.trans (boolean_declaration_complete other)
          cases same
          exact ih remaining
      | string _ _ _ _ _ _ noBoolean _ _ _ =>
          have accepted := boolean_declaration_positive parsed
          rw [← boolean_declaration_complete parsed, noBoolean] at accepted
          contradiction
  | string positive more noCallable noSubtype noScalar noArray noBoolean parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | string _ _ _ _ _ _ _ other _ remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          exact ih remaining

end Silver.Compose
