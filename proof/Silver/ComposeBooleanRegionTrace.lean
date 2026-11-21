module

public import Silver.ComposeBooleanArrayTrace
public import Silver.ComposeDeclarationContext
public import Silver.PredicateOuterReadiness

@[expose] public section

namespace Silver.Compose
open Bindings Predicate PathFacts _root_.Silver.Compose.Expressions

inductive BooleanDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List BooleanDeclaration → List Predicate.Obligation → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → BooleanDeclarationsAt text arguments state [] [] state
  | callable {state final : ParserState} {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      BooleanDeclarationsAt text arguments (callableDeclarationAt text state arguments) rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | arrayType {state middle final : ParserState} {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      ArrayTypeDeclarationAt text arguments state middle →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | string {state middle final : ParserState} {declaration : Bindings.Declaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final

  | booleanArray {state middle final : ParserState} {declaration : BooleanArrayDeclaration}
      {rest : List BooleanDeclaration} {firstChecks checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationChecksAt text state declaration firstChecks →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state (declaration.initializations ++ rest) (firstChecks ++ checks) final

  | subtype {state middle final : ParserState} {rest : List BooleanDeclaration} {checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state rest checks final

  | boolean {state middle final : ParserState} {declaration : BooleanDeclaration}
      {rest : List BooleanDeclaration} {firstChecks checks : List Predicate.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      BooleanDeclarationsAt text arguments middle rest checks final →
      BooleanDeclarationsAt text arguments state (declaration :: rest) (firstChecks ++ checks) final

theorem declarations_boolean_trace {text arguments state final strings}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : DeclarationsAt text arguments state strings final) :
    ∃ declarations checks, BooleanDeclarationsAt text arguments state declarations checks final := by
  induction parsed with
  | done positive stop => exact ⟨[], [], .done positive stop⟩
  | arrayType positive more noCallable first _ ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_array_type_reading_valid valid first)
      exact ⟨declarations, checks, .arrayType positive more noCallable first trace⟩
  | next positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType rest ih =>
      have nextValid := model_object_reading_valid textValid valid first
      obtain ⟨declarations, checks, trace⟩ := ih nextValid
      exact ⟨declarations, checks, .string positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType trace⟩
  | scalar positive more noCallable noSubtype first noArrayType rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_scalar_reading_valid valid first)
      exact ⟨declarations, checks, .scalar positive more noCallable noSubtype first noArrayType trace⟩
  | array positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_array_reading_valid valid first)
      exact ⟨declarations, checks, .array positive more noCallable noSubtype noScalar first noArrayType trace⟩
  | booleanArray positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨declaration, firstChecks, firstTrace⟩ := boolean_array_declaration_trace textValid valid.2.1 first
      obtain ⟨declarations, checks, trace⟩ := ih (model_boolean_array_reading_valid valid first)
      exact ⟨declaration.initializations ++ declarations, firstChecks ++ checks,
        .booleanArray positive more noCallable noSubtype noScalar first noArrayType firstTrace trace⟩
  | subtype positive more noCallable first noArrayType rest ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_subtype_reading_valid valid first)
      exact ⟨declarations, checks, .subtype positive more noCallable first noArrayType trace⟩
  | boolean positive more noCallable noSubtype noScalar noArray first noArrayType rest ih =>
      obtain ⟨declaration, firstChecks, firstTrace⟩ := boolean_declaration_trace textValid valid.2.1 first
      obtain ⟨declarations, checks, trace⟩ := ih (model_boolean_reading_valid valid first)
      exact ⟨declaration :: declarations, firstChecks ++ checks,
        .boolean positive more noCallable noSubtype noScalar noArray first noArrayType firstTrace trace⟩

  | callable positive more accepted _ ih =>
      obtain ⟨declarations, checks, trace⟩ := ih (model_callable_declaration_valid textValid valid)
      exact ⟨declarations, checks, .callable positive more accepted trace⟩

theorem boolean_declarations_reading {text arguments state final declarations checks}
    (trace : BooleanDeclarationsAt text arguments state declarations checks final) :
    ∃ strings, DeclarationsAt text arguments state strings final := by
  induction trace with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | arrayType positive more noCallable first _ ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .arrayType positive more noCallable first reading⟩
  | string positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨_ :: strings, .next positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType reading⟩
  | scalar positive more noCallable noSubtype first noArrayType rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .scalar positive more noCallable noSubtype first noArrayType reading⟩
  | array positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .array positive more noCallable noSubtype noScalar first noArrayType reading⟩
  | booleanArray positive more noCallable noSubtype noScalar first noArrayType raw rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .booleanArray positive more noCallable noSubtype noScalar first noArrayType reading⟩
  | subtype positive more noCallable first noArrayType rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .subtype positive more noCallable first noArrayType reading⟩
  | boolean positive more noCallable noSubtype noScalar noArray first noArrayType raw rest ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .boolean positive more noCallable noSubtype noScalar noArray first noArrayType reading⟩

  | callable positive more accepted _ ih =>
      obtain ⟨strings, reading⟩ := ih
      exact ⟨strings, .callable positive more accepted reading⟩

theorem array_declaration_booleanNames {text arguments state next declaration}
    (parsed : ArrayDeclarationAt text arguments state declaration next) : next.booleanNames = state.booleanNames := by
  have preserved := arrayDeclarationAt_booleanNames
    ((array_declaration_complete parsed).symm ▸ array_declaration_positive parsed)
  rwa [array_declaration_complete parsed] at preserved

theorem boolean_declarations_analysis {text arguments state final declarations checks}
    (textValid : ValidText text) (valid : ValidState text state)
    (trace : BooleanDeclarationsAt text arguments state declarations checks final) :
    ArrayBindings.booleanAnalysis final.arrayNames.names (BooleanBindings.analysis final.booleanNames) =
      booleanDeclarationsAnalysis
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames))
        declarations := by
  induction trace with
  | done => rfl
  | arrayType _ _ _ first _ ih =>
      have following := ih (model_array_type_reading_valid valid first)
      cases first
      exact following
  | string _ _ _ _ _ _ _ first _ _ ih =>
      have following := ih (model_object_reading_valid textValid valid first)
      rw [declaration_arrayNames first, declaration_booleanNames first] at following
      exact following
  | scalar _ _ _ _ first _ _ ih =>
      have following := ih (model_scalar_reading_valid valid first)
      cases first
      exact following
  | array _ _ _ _ _ first _ _ ih =>
      have following := ih (model_array_reading_valid valid first)
      rw [array_declaration_boolean_analysis first] at following
      exact following
  | subtype _ _ _ first _ _ ih =>
      have following := ih (model_subtype_reading_valid valid first)
      cases first
      exact following
  | boolean _ _ _ _ _ _ first _ raw _ ih =>
      have following := ih (model_boolean_reading_valid valid first)
      rw [(boolean_declaration_analysis valid first raw).2.2] at following
      exact following
  | booleanArray _ _ _ _ _ first _ raw _ ih =>
      have following := ih (model_boolean_array_reading_valid valid first)
      rw [(boolean_array_declaration_analysis valid first raw).2.2] at following
      rw [booleanDeclarationsAnalysis_append]
      exact following

  | callable _ _ accepted _ ih =>
      have following := ih (model_callable_declaration_valid textValid valid)
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.arrayNames, kept.booleanNames] at following
      exact following

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
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (stored : state.StoredArrays) :
    BooleanDeclarationsWellFormed (decide (state.dynamicFirst ≠ 0)) final.names.shape
      (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) declarations ∧
      checkBooleanDeclarations final.names.shape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts state).path, Integer.emptyRanges⟩
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) declarations = true ∧ Predicate.discharged checks = true := by
  induction trace with
  | done => exact ⟨trivial, rfl, rfl⟩
  | arrayType _ _ _ first _ ih =>
      have nextValid := model_array_type_reading_valid valid first
      cases first
      exact ih normal nextValid ready static stored
  | string _ _ _ _ _ _ _ first _ _ ih =>
      have nextNormal := declaration_normal normal first
      have nextValid := model_object_reading_valid textValid valid first
      have scalars := declaration_scalarNames first
      have fields := declaration_context_fields first
      have following := ih nextNormal nextValid (scalars.symm ▸ ready) (scalars.symm ▸ static) (declaration_stored stored first)
      simpa only [fields.2.1, fields.2.2.2.1, fields.2.2.2.2.2.2.1, booleanDeclarationFacts,
        ActiveFlow.initial] using following
  | scalar _ _ _ _ first _ _ ih =>
      have nextStatic := scalar_declaration_static static first
      have nextReady := scalar_declaration_header_ready ready first
      have nextValid := model_scalar_reading_valid valid first
      have nextStored := scalar_declaration_stored stored first
      cases first
      exact ih normal nextValid nextReady nextStatic nextStored
  | array _ _ _ _ _ first _ _ ih =>
      have names := (array_declaration_preserves first).1
      have scalars := (array_declaration_preserves first).2
      have fields := array_declaration_fields first
      have sameAnalysis := array_declaration_boolean_analysis first
      have following := ih (names.symm ▸ normal) (model_array_reading_valid valid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static) (array_declaration_stored stored first)
      simpa only [sameAnalysis, fields.2.2.1, booleanDeclarationFacts, ActiveFlow.initial] using following
  | subtype _ _ _ first _ _ ih =>
      have nextValid := model_subtype_reading_valid valid first
      cases first
      exact ih normal nextValid ready static stored
  | @boolean before middle final declaration rest firstChecks checks _ _ _ _ _ _ first _ raw restTrace ih =>
      have preserves := boolean_declaration_preserves first
      have nextNormal : NamesNormal middle.names := preserves.1.symm ▸ normal
      have nextStatic : ScalarExpression.StaticEnvironment middle.scalarNames := preserves.2.1.symm ▸ static
      have nextStored : middle.StoredArrays := by cases first; exact stored
      obtain ⟨strings, source⟩ := boolean_declarations_reading restTrace
      have shapes := declarations_shape nextNormal nextStatic nextStored source
      have extension : ShapeExtends before.names.shape final.names.shape := by
        intro index info present
        apply declarations_extend shapes
        simpa only [preserves.1] using present
      have frozen := boolean_declaration_frozen_valid normal valid ready static stored extension raw
      have rawChecked := boolean_declaration_checks_discharge normal valid ready raw
      have nextValid := model_boolean_reading_valid valid first
      have following := ih nextNormal nextValid (preserves.2.1.symm ▸ ready) nextStatic nextStored
      have allocation := boolean_declaration_analysis valid first raw
      rw [allocation.2.2] at following
      have dynamic := preserves.2.2.2.2.2.2.1
      simp only [dynamic, booleanDeclarationFacts, ActiveFlow.initial] at following
      refine ⟨⟨allocation.1, allocation.2.1, frozen.1, frozen.2.1, following.1⟩, ?_, ?_⟩
      · rw [checkBooleanDeclarations, frozen.2.2, Bool.true_and]
        exact following.2.1
      · rw [Predicate.discharged_append, rawChecked, following.2.2]
        rfl
  | @booleanArray before middle final declaration rest firstChecks checks _ _ _ _ _ first _ raw restTrace ih =>
      have preserves := boolean_array_declaration_preserves first
      have nextNormal : NamesNormal middle.names := preserves.1.symm ▸ normal
      have nextStatic : ScalarExpression.StaticEnvironment middle.scalarNames := preserves.2.1.symm ▸ static
      have nextStored := boolean_array_declaration_stored stored first
      obtain ⟨strings, source⟩ := boolean_declarations_reading restTrace
      have shapes := declarations_shape nextNormal nextStatic nextStored source
      have extension : ShapeExtends before.names.shape final.names.shape := by
        intro index info present
        apply declarations_extend shapes
        simpa only [preserves.1] using present
      have frozen := boolean_array_declaration_frozen_valid normal valid ready static stored extension raw
      have rawChecked := boolean_array_declaration_checks_discharge normal valid ready raw
      have nextValid := model_boolean_array_reading_valid valid first
      have following := ih nextNormal nextValid (preserves.2.1.symm ▸ ready) nextStatic nextStored
      have allocation := boolean_array_declaration_analysis valid first raw
      rw [allocation.2.2] at following
      have dynamic := congrArg ParserState.dynamicFirst (boolean_array_declaration_fields first)
      simp only [dynamic, booleanDeclarationFacts, ActiveFlow.initial] at following
      refine ⟨(booleanDeclarationsWellFormed_append _ _ _ _ _).mpr ⟨?_, following.1⟩, ?_, ?_⟩
      · exact declaration.initializations_wellFormed allocation.1 allocation.2.1
          (fun value member => (frozen value member).1) (fun value member => (frozen value member).2.1)
      · rw [checkBooleanDeclarations_append,
          declaration.initializations_checked (fun value member => (frozen value member).2.2),
          Bool.true_and]
        exact following.2.1
      · rw [Predicate.discharged_append, rawChecked, following.2.2]
        rfl

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      have following := ih (kept.names.symm ▸ normal) (model_callable_declaration_valid textValid valid)
        (kept.scalarNames.symm ▸ ready) (kept.scalarNames.symm ▸ static)
        (by simpa only [ParserState.StoredArrays, kept.arrayNames] using stored)
      simpa only [kept.dynamicFirst, kept.arrayNames, kept.booleanNames,
        booleanDeclarationFacts, ActiveFlow.initial] using following

attribute [local irreducible] scalarDeclarationAt subtypeDeclarationAt arrayTypeDeclarationAt
  arrayDeclarationAt booleanDeclarationAt callableDeclarationAt stringDeclarationAt characterDeclarationAt

theorem boolean_declarations_unique {text arguments state leftState rightState left right leftChecks rightChecks}
    (first : BooleanDeclarationsAt text arguments state left leftChecks leftState)
    (second : BooleanDeclarationsAt text arguments state right rightChecks rightState) :
    left = right ∧ leftChecks = rightChecks ∧ leftState = rightState := by
  induction first generalizing right rightChecks rightState with
  | done positive stop =>
      cases second with
      | done _ _ =>
          exact ⟨rfl, rfl, rfl⟩
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
      | booleanArray _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | boolean _ more _ _ _ _ _ _ _ _ =>
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
      | booleanArray _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | boolean _ _ noCallable _ _ _ _ _ _ _ =>
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
      | booleanArray _ _ _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | boolean _ _ _ _ _ _ _ noArrayType _ _ =>
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
      | booleanArray _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | boolean _ _ _ noSubtype _ _ _ _ _ _ =>
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
          exact ih remaining
      | array _ _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | booleanArray _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | boolean _ _ _ _ noScalar _ _ _ _ _ =>
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
          obtain ⟨rfl, rfl⟩ := array_declaration_unique parsed other
          exact ih remaining
      | booleanArray _ _ _ _ _ other _ _ _ =>
          exact False.elim (array_declaration_kinds_disjoint parsed other)
      | boolean _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
  | booleanArray positive more noCallable noSubtype noScalar parsed noArrayType checks rest ih =>
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
      | booleanArray _ _ _ _ _ other _ otherChecks remaining =>
          have same := (boolean_array_declaration_complete parsed).symm.trans (boolean_array_declaration_complete other)
          cases same
          obtain ⟨rfl, rfl⟩ := boolean_array_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl, rfl⟩
      | boolean _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
  | boolean positive more noCallable noSubtype noScalar noArray parsed noArrayType checks rest ih =>
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
      | booleanArray _ _ _ _ _ other _ _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ otherChecks remaining =>
          have same := (boolean_declaration_complete parsed).symm.trans (boolean_declaration_complete other)
          cases same
          obtain ⟨rfl, rfl⟩ := boolean_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl, rfl⟩
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
      | booleanArray _ _ _ _ _ other _ _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ _ _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | string _ _ _ _ _ _ _ other _ remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          exact ih remaining

end Silver.Compose
