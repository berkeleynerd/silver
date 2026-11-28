module

public import Silver.ComposeScalarTrace
public import Silver.ComposeInitializerTrace
public import Silver.ComposeBooleanRegionTrace
public import Silver.ComposeDeclarationBounds
public import Silver.ProcedureDeclarationTrace
public import Silver.PredicateStringActualInitializers

@[expose] public section

/-! Main declaration aggregation begins at the original imported entry frame.
The scalar seed is its actual constant prefix. Source histories contain no
added program-validity or successful-check certificate. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Bindings

structure MainInventory where
  strings : List Bindings.Declaration
  integers : List Integer.Declaration
  booleans : List BooleanDeclaration
  initializerChecks : List Integer.Obligation
  booleanChecks : List Predicate.Obligation
  functions : List ScalarFunctions.Definition
  procedures : List ScalarProcedures.Definition

structure MainInventory.SourceAt (text : Source) (arguments : Bool)
    (entry final : ParserState) (inventory : MainInventory) : Prop where
  strings : DeclarationsAt text arguments entry inventory.strings final
  integers : ScalarDeclarationsAt text arguments entry inventory.integers final
  initializerChecks : InitializerChecksAt text arguments entry inventory.initializerChecks final
  booleans : BooleanDeclarationsAt text arguments entry inventory.booleans inventory.booleanChecks final
  callables : MixedDeclarationsAt text arguments entry inventory.functions inventory.procedures final

def MainInventory.obligations (entry final : ParserState) (inventory : MainInventory) :
    List Predicate.Obligation :=
  (inventory.initializerChecks ++ Integer.declarationObligations
    (ScalarExpression.constants entry.scalarNames) inventory.integers).map .scalar ++
      inventory.booleanChecks ++
      ScalarFunctions.definitionsObligations (catalogSignatures entry.functions entry.arrayNames.types) inventory.functions ++
      ScalarProcedures.definitionsObligations (catalogSignatures final.functions final.arrayNames.types)
        (ProcedureBindings.catalogSignatures entry.procedures entry.arrayNames.types) inventory.procedures

/-- Every declaration family is recovered from the original successful pass,
including subtype/array headers, raw Boolean checks, and both local libraries. -/
theorem main_inventory (text : Source) (arguments : Bool) (entry : ParserState)
    (textValid : ValidText text) (valid : ValidState text entry)
    (accepted : (declarationsAt text entry arguments).position ≠ 0) :
    ∃ inventory : MainInventory, inventory.SourceAt text arguments entry (declarationsAt text entry arguments) := by
  obtain ⟨strings, stringSource⟩ := declarations_sound text entry arguments accepted
  obtain ⟨integers, integerSource⟩ := declarations_scalar_trace stringSource
  obtain ⟨checks, checkSource⟩ := declarations_image_trace stringSource
  obtain ⟨booleans, booleanChecks, booleanSource⟩ := declarations_boolean_trace textValid valid stringSource
  obtain ⟨functions, procedures, callableSource⟩ := mixedDeclarations_source textValid valid accepted
  exact ⟨⟨strings, integers, booleans, checks, booleanChecks, functions, procedures⟩,
    ⟨stringSource, integerSource, checkSource, booleanSource, callableSource⟩⟩

/-- Checks are derived from the retained histories and original entry domains.
In particular scalar elaboration starts with imported constants, not `[]`. -/
theorem MainInventory.checked {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (valid : ValidState text entry)
    (normal : NamesNormal entry.names) (ready : ScalarMetadata.HeaderReady entry.scalarNames)
    (static : ScalarExpression.StaticEnvironment entry.scalarNames)
    (capacity : entry.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (stored : entry.StoredArrays) (subtypes : IntegerSubtypes.ValidEnvironment text entry.subtypeNames)
    (types : ArrayBindings.ValidTypes text entry.arrayNames.types) (known : CallableTypesKnown entry) :
    Bindings.DeclarationsValid entry.names.shape inventory.strings final.names.shape ∧
      Integer.checkDeclarations (ScalarExpression.constants entry.scalarNames) inventory.integers =
        some (ScalarExpression.constants final.scalarNames) ∧
      BooleanDeclarationsWellFormed (decide (entry.dynamicFirst ≠ 0)) final.names.shape
        (ArrayBindings.booleanAnalysis entry.arrayNames.names (BooleanBindings.analysis entry.booleanNames)) inventory.booleans ∧
      checkBooleanDeclarations final.names.shape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts entry).path, Integer.emptyRanges⟩
        (ArrayBindings.booleanAnalysis entry.arrayNames.names (BooleanBindings.analysis entry.booleanNames)) inventory.booleans = true ∧
      ScalarFunctions.DefinitionsChecked (catalogSignatures entry.functions entry.arrayNames.types) inventory.functions ∧
      ScalarProcedures.DefinitionsChecked (catalogSignatures final.functions final.arrayNames.types)
        (ProcedureBindings.catalogSignatures entry.procedures entry.arrayNames.types) inventory.procedures ∧
      Integer.discharged inventory.initializerChecks = true ∧
      Predicate.discharged inventory.booleanChecks = true := by
  have scalar := scalar_declarations_checked source.integers static capacity subtypes stored
  have boolean := boolean_declarations_valid textValid source.booleans normal valid ready static stored
  have callables := source.callables.checked textValid valid known
  exact ⟨declarations_shape normal static stored source.strings, scalar, boolean.1, boolean.2.1,
    callables.1, callables.2.1, initializer_checks_discharge normal source.initializerChecks subtypes types,
    boolean.2.2⟩

theorem MainInventory.discharged {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (valid : ValidState text entry)
    (normal : NamesNormal entry.names) (ready : ScalarMetadata.HeaderReady entry.scalarNames)
    (static : ScalarExpression.StaticEnvironment entry.scalarNames)
    (capacity : entry.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (stored : entry.StoredArrays) (subtypes : IntegerSubtypes.ValidEnvironment text entry.subtypeNames)
    (types : ArrayBindings.ValidTypes text entry.arrayNames.types) (known : CallableTypesKnown entry) :
    Predicate.discharged (inventory.obligations entry final) = true := by
  obtain ⟨_, scalar, _, _, functions, procedures, rawScalar, rawBoolean⟩ :=
    MainInventory.checked source textValid valid normal ready static capacity stored subtypes types known
  simp only [obligations, Predicate.discharged_append, Predicate.scalar_discharged,
    Integer.discharged_append, rawScalar, Integer.declaration_obligations_discharge scalar,
    rawBoolean, ScalarFunctions.definitions_obligations_discharge functions,
    ScalarProcedures.definitions_obligations_discharge procedures, Bool.and_self]

/-- Actual String metadata and execution fit are retained for any permitted
runtime input and any original imported String store. Full raw/actual bounds
refinement is supplied by the region composition below, not replaced by fit. -/
theorem MainInventory.string_fit {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    {input : Source} {values : Values} (textBound : text.length ≤ maxSourceLength)
    (inputBound : input.length ≤ maxSourceLength) (printable : Bindings.Printable input)
    (count : entry.names.length ≤ maxBindings) (metadata : NamesBoundsValid entry.names)
    (fit : Fits entry.names.shape input values)
    (static : ScalarExpression.StaticEnvironment entry.scalarNames) (stored : entry.StoredArrays) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Fits final.names.shape input (executeDeclarations input inventory.strings values) :=
  declarations_bounds textBound inputBound printable count metadata fit static stored source.strings

/-- Imported Main needs no standalone source certificate or body-validity
premise to reconstruct its actual String initialization. Each raw intermediate
bound certificate is derived from the source declaration inventory, and the
actual bound store advances through that same source-order trace. -/
theorem MainInventory.string_bounds {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    {program : Predicate.Program} (programStrings : program.declarations = inventory.strings)
    (programNames : program.names = final.names)
    (programBooleans : program.booleanInitializerChecks = inventory.booleanChecks)
    (noStrings : entry.names = [])
    (textValid : ValidText text) (stateValid : ValidState text entry)
    (ready : ScalarMetadata.HeaderReady entry.scalarNames)
    (static : ScalarExpression.StaticEnvironment entry.scalarNames) (stored : entry.StoredArrays)
    {input : Source} {inputValid : Bool} {values : Values} {bounds : BoundsStore}
    (inputBound : input.length ≤ maxSourceLength) (printable : Bindings.Printable input)
    (metadata : NamesBoundsValid entry.names) (count : entry.names.length ≤ maxBindings)
    (stringsFit : Fits entry.names.shape input values)
    (allowed : (booleanDeclarationFacts entry).path.Allows inputValid input.length false)
    (compatible : bounds.Compatible entry.names input) :
    RawHeaderBoundsTrace text arguments program input inputValid entry values
      inventory.strings inventory.booleans inventory.booleanChecks final ∧
      (executeDeclarationsBounds input inventory.strings bounds).Compatible final.names input ∧
      ActualHeaderBoundsTrace text arguments input inputValid entry values bounds
        inventory.strings inventory.booleans inventory.booleanChecks final := by
  have declared := declarations_shape metadata.normal static stored source.strings
  have booleans := (boolean_declarations_valid textValid source.booleans metadata.normal
    stateValid ready static stored).2.2
  have fragments : InitializerBoundsFragments program := by
    apply InitializerBoundsFragments.of_initializers
    · simpa only [programStrings, programNames, noStrings, empty_names_shape] using declared
    · simpa only [programBooleans] using booleans
  have rangeInventory : ∀ declarations, DeclarationsAt text arguments entry declarations final →
      ∀ schema ∈ declarationRangeObligations entry.names.shape final.names.shape declarations,
        Check.declaration (.range schema) ∈ program.checks := by
    intro declarations reading schema member
    have same := (declarations_unique source.strings reading).1
    apply declaration_range_check_present
    simpa only [programStrings, programNames, noStrings, empty_names_shape, same] using member
  obtain ⟨strings, reading, raw⟩ := boolean_region_bounds_trace_of_fragments textValid
    inputBound printable fragments metadata count stringsFit stateValid ready static stored allowed
    source.booleans rangeInventory (by intro check member; simpa only [programBooleans] using member)
  have same := (declarations_unique source.strings reading).1
  rw [← same] at raw
  have actual := raw.actual_bounds textValid.2 inputBound printable count metadata stringsFit
    static stored compatible
  exact ⟨raw, actual⟩

/-- The original argument declaration creates its sole dynamic String cell.
Its actual bounds are compatible for every bounded runtime input, including
empty input, and do not depend on the previous bound store. -/
theorem argument_actual_bounds_compatible {text fallback input : Source}
    {before entry : ParserState} (argument : ArgumentAt text before fallback entry)
    (inputBound : input.length ≤ maxSourceLength) (bounds : BoundsStore) :
    (argumentDeclaration.executeBounds bounds input).Compatible entry.names input := by
  intro index info selected
  have cell : entry.names.shape index = some info.cell := by
    simp only [BindingEnvironment.shape, selected, Option.map_some]
  rw [(argument_shape argument).2.1] at cell
  by_cases same : index = 1
  · subst index
    have infoCell : info.cell = ⟨.argument, false⟩ := by
      simpa [argumentShape, Bindings.put] using cell.symm
    have dynamic : info.dynamic = true := by
      have bound := congrArg CellInfo.bound infoCell
      cases flag : info.dynamic with
      | true => rfl
      | false => simp [BindingInfo.cell, BindingInfo.bound, flag] at bound
    simpa [Declaration.executeBounds, argumentDeclaration, Expression.actualBounds,
      Operand.actualBounds, Operand.objectBounds, Bindings.put, StringObjectBounds.Bounds.concatenate,
      StringObjectBounds.Bounds.isNull, StringObjectBounds.Bounds.canonical, namedModelBounds, dynamic] using
      StringObjectBounds.Bounds.NullEquivalent.refl (canonical_bounds_valid inputBound)
  · simp [argumentShape, Bindings.put, same, emptyShape] at cell

/-- Main with an original optional argument retains that declaration in the
complete String program. The following source region derives every raw range
certificate and actual bound-store step from the same original history. -/
theorem MainInventory.string_bounds_after_argument {text fallback : Source}
    {before entry final : ParserState} {inventory : MainInventory}
    (argument : ArgumentAt text before fallback entry)
    (source : inventory.SourceAt text true entry final)
    {program : Predicate.Program}
    (programStrings : program.declarations = argumentDeclaration :: inventory.strings)
    (programNames : program.names = final.names)
    (programBooleans : program.booleanInitializerChecks = inventory.booleanChecks)
    (textValid : ValidText text) (stateValid : ValidState text entry)
    (ready : ScalarMetadata.HeaderReady entry.scalarNames)
    (static : ScalarExpression.StaticEnvironment entry.scalarNames) (stored : entry.StoredArrays)
    {input : Source} {inputValid : Bool} (bounds : BoundsStore)
    (inputBound : input.length ≤ maxSourceLength) (printable : Bindings.Printable input)
    (allowed : (booleanDeclarationFacts entry).path.Allows inputValid input.length false) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Fits final.names.shape input
        (executeDeclarations input inventory.strings (argumentDeclaration.execute emptyValues input)) ∧
      RawHeaderBoundsTrace text true program input inputValid entry
        (argumentDeclaration.execute emptyValues input)
        inventory.strings inventory.booleans inventory.booleanChecks final ∧
      (executeDeclarationsBounds input inventory.strings
        (argumentDeclaration.executeBounds bounds input)).Compatible final.names input ∧
      ActualHeaderBoundsTrace text true input inputValid entry
        (argumentDeclaration.execute emptyValues input) (argumentDeclaration.executeBounds bounds input)
        inventory.strings inventory.booleans inventory.booleanChecks final := by
  have entryBounds := argument_bounds argument
  have entryShape := (argument_shape argument).2.1
  have stringsFit : Fits entry.names.shape input (argumentDeclaration.execute emptyValues input) := by
    rw [entryShape]
    exact Bindings.declaration_preserves (empty_fits input) printable (argument_shape argument).2.2
  have declared := declarations_shape entryBounds.1.normal static stored source.strings
  have booleans := (boolean_declarations_valid textValid source.booleans entryBounds.1.normal
    stateValid ready static stored).2.2
  have fragments : InitializerBoundsFragments program := by
    apply InitializerBoundsFragments.of_initializers
    · rw [programStrings, programNames]
      exact prepend_argument (entryShape ▸ declared)
    · simpa only [programBooleans] using booleans
  have rangeInventory : ∀ declarations, DeclarationsAt text true entry declarations final →
      ∀ schema ∈ declarationRangeObligations entry.names.shape final.names.shape declarations,
        Check.declaration (.range schema) ∈ program.checks := by
    intro declarations reading schema member
    have same := (declarations_unique source.strings reading).1
    have target : final.names.shape 1 = some ⟨.argument, false⟩ := by
      apply declarations_extend declared
      rw [entryShape]
      exact put_same _ _ _
    apply declaration_range_check_present
    rw [programStrings, programNames]
    simp only [declarationRangeObligations, declarationBound, argumentDeclaration, target,
      Option.map_some, Option.getD_some, Declaration.extend]
    exact List.mem_cons_of_mem _ (by simpa only [entryShape, argumentShape, same] using member)
  obtain ⟨strings, reading, raw⟩ := boolean_region_bounds_trace_of_fragments textValid
    inputBound printable fragments entryBounds.1 entryBounds.2 stringsFit stateValid ready static stored allowed
    source.booleans rangeInventory (by intro check member; simpa only [programBooleans] using member)
  have same := (declarations_unique source.strings reading).1
  rw [← same] at raw
  have actual := raw.actual_bounds textValid.2 inputBound printable entryBounds.2 entryBounds.1 stringsFit
    static stored (argument_actual_bounds_compatible argument inputBound bounds)
  have finalBounds := declarations_bounds_after_argument textValid.2 inputBound printable static stored
    argument source.strings
  exact ⟨finalBounds.1, finalBounds.2.1, finalBounds.2.2, raw, actual⟩

end Silver.ApplicationPackageInitializers
