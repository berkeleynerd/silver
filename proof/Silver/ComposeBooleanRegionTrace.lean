module

public import Silver.ComposeBooleanTrace
public import Silver.PredicateOuterReadiness

@[expose] public section

namespace Silver.Compose
open Bindings Predicate PathFacts _root_.Silver.Compose.Expressions

inductive BooleanDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List BooleanDeclaration → List Predicate.Obligation → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → BooleanDeclarationsAt text arguments state [] [] state
  | string {state middle final : ParserState} {declaration : Bindings.Declaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final

  | subtype {state middle final : ParserState} {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      SubtypeDeclarationAt text arguments state middle →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final

  | boolean {state middle final : ParserState} {declaration : BooleanDeclaration}
      {rest : List BooleanDeclaration} {firstChecks checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state (declaration :: rest) (firstChecks ++ checks) final

theorem declarations_boolean_trace {text arguments state final strings}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : DeclarationsAt text arguments state strings final) :
    ∃ declarations checks, BooleanDeclarationsAt text arguments state declarations checks final := by
  induction parsed with
  | done positive stop => exact ⟨[], [], .done positive stop⟩
  | next positive more noSubtype noScalar noArray noBoolean first rest ih =>
      have nextValid := model_string_declaration_valid _ textValid _ arguments valid
      rw [declaration_complete first] at nextValid
      obtain ⟨declarations, checks, trace⟩ := ih nextValid
      exact ⟨declarations, checks, .string positive more noSubtype noScalar noArray noBoolean first trace⟩
  | scalar positive more noSubtype first rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_scalar_reading_valid valid first)
      exact ⟨declarations, checks, .scalar positive more noSubtype first trace⟩
  | array positive more noSubtype noScalar first rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_array_reading_valid valid first)
      exact ⟨declarations, checks, .array positive more noSubtype noScalar first trace⟩
  | subtype positive more first rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_subtype_reading_valid valid first)
      exact ⟨declarations, checks, .subtype positive more first trace⟩
  | boolean positive more noSubtype noScalar noArray first rest ih =>
      obtain ⟨declaration, firstChecks, firstTrace⟩ := boolean_declaration_trace textValid valid.2.1 first
      obtain ⟨declarations, checks, trace⟩ := ih (model_boolean_reading_valid valid first)
      exact ⟨declaration :: declarations, firstChecks ++ checks,
        .boolean positive more noSubtype noScalar noArray first firstTrace trace⟩

theorem boolean_declarations_reading {text arguments state final declarations checks}
    (trace : BooleanDeclarationsAt text arguments state declarations checks final) :
    ∃ strings, DeclarationsAt text arguments state strings final := by
  induction trace with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | string positive more noSubtype noScalar noArray noBoolean first rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨_ :: strings, .next positive more noSubtype noScalar noArray noBoolean first reading⟩
  | scalar positive more noSubtype first rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .scalar positive more noSubtype first reading⟩
  | array positive more noSubtype noScalar first rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .array positive more noSubtype noScalar first reading⟩
  | subtype positive more first rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .subtype positive more first reading⟩
  | boolean positive more noSubtype noScalar noArray first raw rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .boolean positive more noSubtype noScalar noArray first reading⟩

theorem array_declaration_booleanNames {text arguments state next declaration}
    (parsed : ArrayDeclarationAt text arguments state declaration next) : next.booleanNames = state.booleanNames := by
  have preserved := arrayDeclarationAt_booleanNames
    ((array_declaration_complete parsed).symm ▸ array_declaration_positive parsed)
  rwa [array_declaration_complete parsed] at preserved

theorem boolean_declarations_mutabilities {text arguments state final declarations checks}
    (trace : BooleanDeclarationsAt text arguments state declarations checks final) :
    final.booleanNames.map BooleanBindings.Binding.mutable =
      state.booleanNames.map BooleanBindings.Binding.mutable ++ declarations.map BooleanDeclaration.mutable := by
  induction trace with
  | done => simp
  | string _ _ _ _ _ _ first _ ih | scalar _ _ _ first _ ih | subtype _ _ first _ ih =>
      cases first
      exact ih
  | array _ _ _ _ first _ ih =>
      rw [array_declaration_booleanNames first] at ih
      exact ih
  | boolean _ _ _ _ _ first raw _ ih =>
      obtain ⟨_, _, rfl, _⟩ := raw
      cases first
      simpa only [addBooleanBinding, List.map_append, List.map_cons, List.map_nil,
        List.append_assoc, List.singleton_append] using ih

theorem boolean_declarations_count {text arguments state final declarations checks}
    (trace : BooleanDeclarationsAt text arguments state declarations checks final) :
    final.booleanNames.length = state.booleanNames.length + declarations.length := by
  have lengths := congrArg List.length (boolean_declarations_mutabilities trace)
  simpa only [List.length_map, List.length_append] using lengths

theorem boolean_analysis_of_mutabilities {names : BooleanBindings.Environment} {declarations : List BooleanDeclaration}
    (same : names.map BooleanBindings.Binding.mutable = declarations.map BooleanDeclaration.mutable) :
    BooleanBindings.analysis names = booleanBodyAnalysis declarations := by
  have lengths : names.length = declarations.length := by
    simpa only [List.length_map] using congrArg List.length same
  unfold BooleanBindings.analysis booleanBodyAnalysis booleanInitialAnalysis
  congr 1
  · funext index
    rw [lengths]
  · funext index
    have values := congrArg (fun items => items[index - 1]?) same
    simp only [List.getElem?_map] at values
    simp only [lengths, BooleanBindings.binding, List.getD_eq_getElem?_getD]
    rw [← values]
    cases names[index - 1]? <;> rfl

theorem scalar_declaration_header_ready {text arguments state next declaration}
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarMetadata.HeaderReady next.scalarNames := by
  cases parsed with
  | declaration _ checked _ _ =>
      rcases checked with ⟨_, _, _, _, _, nonempty, _, lower, upper, _⟩
      exact ready.append nonempty (fun _ => ⟨lower, upper⟩)

theorem boolean_declarations_valid {text arguments state final declarations checks}
    (textValid : ValidText text)
    (trace : BooleanDeclarationsAt text arguments state declarations checks final)
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    BooleanDeclarationsWellFormed (decide (state.dynamicFirst ≠ 0)) final.names.shape
      state.booleanNames.length declarations ∧
      checkBooleanDeclarations final.names.shape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts state).path, Integer.emptyRanges⟩
        state.booleanNames.length declarations = true ∧ Predicate.discharged checks = true := by
  induction trace with
  | done => exact ⟨trivial, rfl, rfl⟩
  | string _ _ _ _ _ _ first _ ih =>
      have nextNormal := declaration_normal normal first
      have nextValid := model_string_declaration_valid _ textValid _ arguments valid
      rw [declaration_complete first] at nextValid
      cases first
      exact ih nextNormal nextValid ready static
  | scalar _ _ _ first _ ih =>
      have nextStatic := scalar_declaration_static static first
      have nextReady := scalar_declaration_header_ready ready first
      have nextValid := model_scalar_reading_valid valid first
      cases first
      exact ih normal nextValid nextReady nextStatic
  | array _ _ _ _ first _ ih =>
      have names := (array_declaration_preserves first).1
      have scalars := (array_declaration_preserves first).2
      have fields := array_declaration_fields first
      have booleans := array_declaration_booleanNames first
      have following := ih (names.symm ▸ normal) (model_array_reading_valid valid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static)
      simpa only [booleans, fields.2.2.1, booleanDeclarationFacts, ActiveFlow.initial] using following
  | subtype _ _ first _ ih =>
      have nextValid := model_subtype_reading_valid valid first
      cases first
      exact ih normal nextValid ready static
  | @boolean before middle final declaration rest firstChecks checks _ _ _ _ _ first raw restTrace ih =>
      have preserves := boolean_declaration_preserves first
      have nextNormal : NamesNormal middle.names := preserves.1.symm ▸ normal
      have nextStatic : ScalarExpression.StaticEnvironment middle.scalarNames := preserves.2.1.symm ▸ static
      obtain ⟨strings, source⟩ := boolean_declarations_reading restTrace
      have shapes := declarations_shape nextNormal nextStatic source
      have extension : ShapeExtends before.names.shape final.names.shape := by
        intro index info present
        apply declarations_extend shapes
        simpa only [preserves.1] using present
      have frozen := boolean_declaration_frozen_valid normal valid ready static extension raw
      have rawChecked := boolean_declaration_checks_discharge normal valid ready raw
      have nextValid := model_boolean_reading_valid valid first
      have following := ih nextNormal nextValid (preserves.2.1.symm ▸ ready) nextStatic
      cases first
      simp only [addBooleanBinding, List.length_append, List.length_singleton] at following
      refine ⟨⟨frozen.1, frozen.2.1, following.1⟩, ?_, ?_⟩
      · rw [checkBooleanDeclarations, frozen.2.2, Bool.true_and]
        exact following.2.1
      · rw [Predicate.discharged_append, rawChecked, following.2.2]
        rfl

end Silver.Compose
