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

end Silver.ApplicationPackageInitializers
