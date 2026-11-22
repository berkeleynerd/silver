module

public import Silver.ComposeModelCalls
public import Silver.ScalarExpressionSourceBridge

@[expose] public section

namespace Silver.Compose.Expressions

/-- The array-aware imported laws used by the existing helper equations.
Their domains include every valid table, both elaboration modes and zero
lookup cursors; no source-allocation history is required. -/
structure ArrayImportMeaning (calls : Calls) : Prop where
  scalarRead : ∀ text, ValidText text → ∀ position names arrays initials elaborating,
    ValidCursor text position → ScalarExpression.ValidEnvironment text names →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    calls.function .scalarRead text position names arrays initials elaborating =
      ScalarExpression.ArrayGrammar.read text position names arrays 0 0 true initials elaborating
  arrayLookup : ∀ text, ValidText text → ∀ arrays first after,
    ArrayBindings.ValidTable text arrays → ValidCursor text first → ValidCursor text after →
    calls.function .arrayLookup text arrays first after = ArrayBindings.lookup text arrays.items first after
  arrayTypeLookup : ∀ text, ValidText text → ∀ types first after,
    ArrayBindings.ValidTypes text types → ValidCursor text first → ValidCursor text after →
    calls.function .arrayTypeLookup text types first after = ArrayBindings.lookupType text types first after

/-- Direct identities select the actual native libraries. The scalar call
retains the native defaults for masks, signs and element-read mode, while its
complete array table, initializer values and elaboration flag remain arbitrary. -/
structure ArrayImportSource (calls : Calls) : Prop where
  arrays : ∃ native : ArrayBindings.Native.Calls,
    ArrayBindings.SourceBridge.InterpretedSource native ∧
      calls.function .arrayLookup = native.lookup ∧
      calls.function .arrayTypeLookup = native.lookupType
  scalars : ∃ native : ScalarExpression.Native.Calls,
    ScalarExpression.SourceBridge.InterpretedSource native ∧
      calls.function .scalarRead = fun text position names arrays initials elaborating =>
        native.readExpression text position names 0 0 true arrays initials elaborating .allElements

/-- Imported model laws follow from checked native source interpretations and
the caller's direct identities, rather than independent normalized premises. -/
theorem ArrayImportSource.meaning {calls : Calls} (source : ArrayImportSource calls) :
    ArrayImportMeaning calls where
  scalarRead text tv position names arrays initials elaborating bounded environment metadata values := by
    obtain ⟨native, interpreted, linked⟩ := source.scalars
    rw [linked]
    exact ScalarExpression.SourceBridge.interpreted_readExpression_table native interpreted
      text tv position names 0 0 true arrays initials elaborating .allElements
      bounded environment (.inl ⟨rfl, rfl⟩) metadata values
  arrayLookup text tv arrays first after metadata firstBound afterBound := by
    obtain ⟨native, interpreted, linked, _⟩ := source.arrays
    rw [linked]
    exact ArrayBindings.SourceBridge.interpreted_lookup native interpreted
      text tv arrays metadata first after firstBound afterBound
  arrayTypeLookup text tv types first after metadata firstBound afterBound := by
    obtain ⟨native, interpreted, _, linked⟩ := source.arrays
    rw [linked]
    exact ArrayBindings.SourceBridge.interpreted_lookupType native interpreted
      text tv types metadata first after firstBound afterBound

/-- Supply the derived imports to any existing raw definition bundle without
altering its state domain or the source equations for its other helpers. -/
theorem ArrayImportMeaning.raw {calls evaluator : Calls} {domain : StateDomain}
    (imports : ArrayImportMeaning calls) (definitions : RawHelperEquations calls evaluator domain) :
    RawHelperEquations calls evaluator domain :=
  {definitions with
    scalarRead := imports.scalarRead
    arrayLookup := imports.arrayLookup
    arrayTypeLookup := imports.arrayTypeLookup}

theorem model_array_import_source : ArrayImportSource modelCalls where
  arrays := ⟨ArrayBindings.Native.modelCalls, ArrayBindings.SourceBridge.model_interpreted, rfl, rfl⟩
  scalars := ⟨ScalarExpression.Native.modelCalls, ScalarExpression.SourceBridge.model_interpreted, rfl⟩

end Silver.Compose.Expressions
