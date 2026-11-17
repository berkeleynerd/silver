module

public import Silver.FunctionDeclarationReadings
public import Silver.PredicateFunctionCallReadings

@[expose] public section

namespace Silver.Compose
open Predicate _root_.Silver.Compose.Expressions

/-- Local initialization changes only the Integer and Boolean stores; callable
metadata and all inherited type-name metadata remain the header's exact prefix. -/
structure FunctionLocalsPreserved (before after : ParserState) : Prop where
  names : after.names = before.names
  arrayNames : after.arrayNames = before.arrayNames
  subtypeNames : after.subtypeNames = before.subtypeNames
  functions : after.functions = before.functions
  procedures : after.procedures = before.procedures
  dynamicFirst : after.dynamicFirst = before.dynamicFirst
  dynamicAfter : after.dynamicAfter = before.dynamicAfter
  pure : after.pure = before.pure
  firstParameter : after.firstParameter = before.firstParameter
  firstProcedureParameter : after.firstProcedureParameter = before.firstProcedureParameter

theorem FunctionLocalsAt.preserves {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final) :
    FunctionLocalsPreserved state final := by
  induction source with
  | done => exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | integer _ _ first _ _ _ ih =>
      cases first
      exact ⟨ih.names, ih.arrayNames, ih.subtypeNames, ih.functions, ih.procedures, ih.dynamicFirst,
        ih.dynamicAfter, ih.pure, ih.firstParameter, ih.firstProcedureParameter⟩
  | boolean _ _ _ first _ _ _ ih =>
      cases first
      exact ⟨ih.names, ih.arrayNames, ih.subtypeNames, ih.functions, ih.procedures, ih.dynamicFirst,
        ih.dynamicAfter, ih.pure, ih.firstParameter, ih.firstProcedureParameter⟩

theorem FunctionLocalsAt.valid {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (valid : ValidState text state) : ValidState text final := by
  induction source with
  | done => exact valid
  | integer _ _ first _ _ _ ih => exact ih (model_scalar_reading_valid valid first)
  | boolean _ _ _ first _ _ _ ih => exact ih (model_boolean_reading_valid valid first)

theorem FunctionLocalsAt.static {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment final.scalarNames := by
  induction source with
  | done => exact static
  | integer _ _ first _ _ _ ih => exact ih (scalar_declaration_static static first)
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih static

theorem FunctionLocalsAt.headerReady {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady final.scalarNames := by
  induction source with
  | done => exact ready
  | integer _ _ first _ _ _ ih => exact ih (scalar_declaration_header_ready ready first)
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih ready

theorem FunctionLocalsAt.scalarCount {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    final.scalarNames.length ≤ ArrayBindings.scalarLimit := by
  induction source with
  | done => exact bounded
  | integer _ _ first _ _ _ ih => exact ih (scalar_declaration_count_bound bounded first)
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih bounded

theorem FunctionLocalsAt.scalars_checked {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) integers =
      some (ScalarExpression.constants final.scalarNames) := by
  induction source with
  | done => rfl
  | integer _ _ first _ _ _ ih =>
      rw [scalar_declaration_subtypes first] at ih
      simp only [Integer.checkDeclarations, scalar_declaration_checked static bounded subtypes first, Option.bind_some]
      exact ih (scalar_declaration_static static first) (scalar_declaration_count_bound bounded first) subtypes
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih static bounded subtypes

theorem FunctionLocalsAt.scalar_objects {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ScalarExpression.objectBindings final.scalarNames = ScalarExpression.objectBindings state.scalarNames ++
      Integer.elaborate (ScalarExpression.constants state.scalarNames) integers := by
  induction source with
  | done => simp [Integer.elaborate]
  | integer _ _ first _ _ _ ih =>
      rw [scalar_declaration_subtypes first] at ih
      have objects := scalar_declaration_objects elaborated bounded first
      have values := (Integer.Declaration.check_sound (scalar_declaration_checked elaborated bounded subtypes first)).1
      rw [ih (scalar_declaration_static elaborated first) (scalar_declaration_count_bound bounded first) subtypes,
        objects, values]
      simp only [Integer.elaborate, List.append_assoc, List.singleton_append]
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih elaborated bounded subtypes

theorem FunctionLocalsAt.initializer_checks {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    Integer.discharged checks = true ∧ Predicate.discharged booleanChecks = true := by
  induction source with
  | done => exact ⟨rfl, rfl⟩
  | @integer before middle final declaration integers booleans firstChecks checks booleanChecks _ _ first raw _ _ ih =>
      have nextReady := scalar_declaration_header_ready ready first
      have nextValid := model_scalar_reading_valid valid first
      have nextNormal : NamesNormal middle.names := by cases first; exact normal
      have following := ih nextNormal nextValid nextReady
      exact ⟨by rw [Integer.discharged_append, scalar_declaration_checks_discharge raw, following.1]; rfl,
        following.2⟩
  | @boolean before middle final declaration integers booleans checks firstChecks booleanChecks _ _ _ first raw _ _ ih =>
      have firstChecked := boolean_declaration_checks_discharge normal valid ready raw
      have nextValid := model_boolean_reading_valid valid first
      have nextNormal : NamesNormal middle.names := by cases first; exact normal
      have nextReady : ScalarMetadata.HeaderReady middle.scalarNames := by cases first; exact ready
      have following := ih nextNormal nextValid nextReady
      exact ⟨following.1, by rw [Predicate.discharged_append, firstChecked, following.2]; rfl⟩

theorem FunctionLocalsAt.boolean_analysis {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (valid : ValidState text state) :
    ArrayBindings.booleanAnalysis final.arrayNames.names (BooleanBindings.analysis final.booleanNames) =
      booleanDeclarationsAnalysis
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) booleans := by
  induction source with
  | done => rfl
  | integer _ _ first _ _ _ ih =>
      have following := ih (model_scalar_reading_valid valid first)
      cases first
      exact following
  | @boolean before middle final declaration integers booleans checks firstChecks booleanChecks _ _ _ first raw _ _ ih =>
      have following := ih (model_boolean_reading_valid valid first)
      rw [(boolean_declaration_analysis valid first raw).2.2] at following
      exact following

theorem FunctionLocalsAt.booleans_valid {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    BooleanDeclarationsWellFormed (decide (state.dynamicFirst ≠ 0)) state.names.shape
      (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) booleans ∧
      checkBooleanDeclarations state.names.shape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts state).path, Integer.emptyRanges⟩
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) booleans = true := by
  induction source with
  | done => exact ⟨trivial, rfl⟩
  | integer _ _ first _ _ _ ih =>
      have nextValid := model_scalar_reading_valid valid first
      have nextReady := scalar_declaration_header_ready ready first
      have nextStatic := scalar_declaration_static static first
      cases first
      exact ih normal nextValid nextReady nextStatic
  | @boolean before middle final declaration integers booleans checks firstChecks booleanChecks _ _ _ first raw _ _ ih =>
      have preserves := boolean_declaration_preserves first
      have nextNormal := preserves.1.symm ▸ normal
      have nextReady := preserves.2.1.symm ▸ ready
      have nextStatic := preserves.2.1.symm ▸ static
      have nextValid := model_boolean_reading_valid valid first
      have frozen := boolean_declaration_frozen_valid normal valid ready static
        (fun _ _ present => present) raw
      have allocation := boolean_declaration_analysis valid first raw
      have following := ih nextNormal nextValid nextReady nextStatic
      rw [allocation.2.2] at following
      simp only [preserves.1, preserves.2.2.2.2.2.2.1,
        booleanDeclarationFacts, ActiveFlow.initial] at following
      refine ⟨⟨allocation.1, allocation.2.1, frozen.1, frozen.2.1, following.1⟩, ?_⟩
      rw [checkBooleanDeclarations, frozen.2.2, Bool.true_and]
      exact following.2

theorem FunctionLocalsAt.scalar_length {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final) :
    final.scalarNames.length = state.scalarNames.length + integers.length := by
  induction source with
  | done => simp only [List.length_nil, Nat.add_zero]
  | integer _ _ first _ _ _ ih =>
      cases first
      simp only [addScalarBinding, List.length_append, List.length_cons, List.length_nil] at ih ⊢
      omega
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih

theorem FunctionLocalsAt.boolean_length {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final) :
    final.booleanNames.length = state.booleanNames.length + booleans.length := by
  induction source with
  | done => simp only [List.length_nil, Nat.add_zero]
  | integer _ _ first _ _ _ ih => cases first; exact ih
  | boolean _ _ _ first _ _ _ ih =>
      cases first
      simp only [addBooleanBinding, List.length_append, List.length_cons, List.length_nil] at ih ⊢
      omega

end Silver.Compose

namespace Silver.Predicate

/-- Every selected formal domain is supplied by an actual valid pooled record. -/
theorem formalType_valid {text : Source} {formal : FunctionBindings.Formal}
    (typed : FunctionBindings.ValidFormal text formal) : (formalType formal).Valid := by
  cases kind : formal.kind with
  | integer => simpa only [formalType, kind, ScalarFunctions.ScalarType.Valid] using typed.2
  | boolean => simp only [formalType, kind, ScalarFunctions.ScalarType.Valid]

theorem formalTypes_length (catalog : FunctionBindings.Metadata) (first count : Nat) :
    (formalTypes catalog first count).length = count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih => simp only [formalTypes, List.length_cons, ih]

theorem formalTypes_valid {text : Source} (catalog : FunctionBindings.Metadata) (first count : Nat)
    (metadata : FunctionBindings.ValidMetadata text catalog)
    (positive : 0 < first) (bounded : first + count - 1 ≤ catalog.parameters.length) :
    ∀ domain ∈ formalTypes catalog first count, domain.Valid := by
  induction count generalizing first with
  | zero => simp only [formalTypes, List.not_mem_nil, false_implies, implies_true]
  | succ count ih =>
      intro domain member
      simp only [formalTypes, List.mem_cons] at member
      rcases member with rfl | member
      · exact formalType_valid
          (metadata.2.2.1 _ (FunctionBindings.parameter_mem positive (by omega)))
      · exact ih (first + 1) (by omega) (by omega) domain member

theorem signatureModel_valid {text : Source} {catalog : FunctionBindings.Metadata}
    {entry : FunctionBindings.Signature} (metadata : FunctionBindings.ValidMetadata text catalog)
    (typed : FunctionBindings.ValidSignature text catalog entry) : (signatureModel catalog entry).Valid := by
  refine ⟨?_, ?_, ?_⟩
  · intro empty
    have length := formalTypes_length catalog entry.formalFirst entry.count
    change formalTypes catalog entry.formalFirst entry.count = [] at empty
    rw [empty] at length
    have nonzero := typed.2.1
    simp only [List.length_nil] at length
    omega
  · apply formalTypes_valid catalog entry.formalFirst entry.count metadata typed.2.2.1
    have first := typed.2.2.2.1
    have count := typed.2.2.2.2.1
    omega
  · change (resultType entry).Valid
    cases kind : entry.resultKind with
    | integer => simpa only [resultType, kind, ScalarFunctions.ScalarType.Valid]
        using typed.2.2.2.2.2
    | boolean => simp only [resultType, kind, ScalarFunctions.ScalarType.Valid]

end Silver.Predicate
