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
      (scalarDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state rest final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List Integer.Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      ScalarDeclarationsAt text arguments middle rest final →
      ScalarDeclarationsAt text arguments state (declaration :: rest) final

theorem declarations_scalar_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Bindings.Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ values, ScalarDeclarationsAt text arguments state values final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | next positive more noScalar first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨values, .string positive more noScalar first reading⟩
  | scalar positive more first rest ih =>
      obtain ⟨values, reading⟩ := ih
      exact ⟨_ :: values, .scalar positive more first reading⟩

theorem scalar_declarations_static {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment final.scalarNames := by
  induction parsed with
  | done => exact static
  | string _ _ _ first _ ih =>
      cases first
      exact ih static
  | scalar _ _ first _ ih => exact ih (scalar_declaration_static static first)

theorem scalar_declarations_checked {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) values =
      some (ScalarExpression.constants final.scalarNames) := by
  induction parsed with
  | done => rfl
  | string _ _ _ first _ ih =>
      cases first
      exact ih static
  | scalar _ _ first _ ih =>
      simp only [Integer.checkDeclarations, scalar_declaration_checked static first, Option.bind_some]
      exact ih (scalar_declaration_static static first)

theorem scalar_declarations_objects {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (exact : ScalarExpression.ElaboratedEnvironment state.scalarNames) :
    ScalarExpression.objectBindings final.scalarNames = ScalarExpression.objectBindings state.scalarNames ++
      Integer.elaborate (ScalarExpression.constants state.scalarNames) values := by
  induction parsed with
  | done => simp [Integer.elaborate]
  | string _ _ _ first _ ih =>
      cases first
      exact ih exact
  | scalar _ _ first _ ih =>
      have objects := scalar_declaration_objects exact first
      have values := (Integer.Declaration.check_sound (scalar_declaration_checked exact first)).1
      rw [ih (scalar_declaration_static exact first), objects, values]
      simp only [Integer.elaborate, List.append_assoc, List.singleton_append]

theorem scalar_declarations_declared_bounds {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Integer.Declaration} (parsed : ScalarDeclarationsAt text arguments state values final)
    (valid : ScalarExpression.DeclaredBoundsValid state.scalarNames) :
    ScalarExpression.DeclaredBoundsValid final.scalarNames := by
  induction parsed with
  | done => exact valid
  | string _ _ _ first _ ih =>
      cases first
      exact ih valid
  | scalar _ _ first _ ih => exact ih (scalar_declaration_declared_bounds valid first)

theorem scalar_declarations_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Integer.Declaration} (first : ScalarDeclarationsAt text arguments state left leftState)
    (second : ScalarDeclarationsAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done => exact ⟨rfl, rfl⟩
      | string _ more _ _ _ | scalar _ more _ _ => exact False.elim (stop more)
  | string positive more noScalar parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ other remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          exact ih remaining
      | scalar _ _ other _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
  | scalar positive more parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ noScalar _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | scalar _ _ other remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl⟩

end Silver.Compose
