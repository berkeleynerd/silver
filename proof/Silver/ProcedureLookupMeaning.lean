module

public import Silver.ComposeContracts
public import Silver.ProcedureBindingsSourceBridge

@[expose] public section

namespace Silver.Compose.Expressions

/-- Derive the imported lookup law from the actual metadata implementation's
raw equations and direct callee identity, over the complete native domain.
This small boundary can be checked before rebuilding the composed source bridge. -/
theorem procedure_lookup_meaning (calls : Calls) (metadata : ProcedureBindings.Native.Calls)
    (source : ProcedureBindings.SourceBridge.InterpretedSource metadata)
    (linked : calls.function .procedureLookup = metadata.lookup) :
    ∀ text, ValidText text → ∀ catalog first after,
      ProcedureBindings.ValidMetadata text catalog → ValidCursor text first →
      ValidCursor text after →
      calls.function .procedureLookup text catalog first after =
        ProcedureBindings.lookup text catalog first after := by
  intro text valid catalog first after metadataValid firstBound afterBound
  rw [linked]
  exact (ProcedureBindings.SourceBridge.interpreted_complete metadata source).lookup
    text valid catalog metadataValid first after firstBound afterBound

end Silver.Compose.Expressions
