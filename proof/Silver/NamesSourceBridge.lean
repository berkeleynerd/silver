module

public import Silver.NamesEquations
public import Silver.NamesSourceChecks

@[expose] public section

/-! Exact-source context/name resolution combines the checked native trees,
the existing lexical meanings, and GNATprove's executable refinements. The
simultaneous concrete interpretation inhabits every new definition equation. -/
namespace Silver.Names.SourceBridge

theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, ValidText text →
      (∀ arguments, calls.contextAfter text arguments = contextAfter text arguments) ∧
      (∀ position operation hidden, position ≤ text.length + 1 →
        calls.operationAfter text position operation hidden = operationAfter text position operation hidden) ∧
      (∀ position default, position ≤ text.length + 1 →
        calls.associationAfter text position default = associationAfter text position default) := by
  refine ⟨checked_source, ?_⟩
  intro calls source text valid
  exact ⟨interpreted_context calls source text valid,
    interpreted_operation calls source text valid,
    interpreted_association calls source text valid⟩

theorem model_interpreted : InterpretedSource modelCalls := Names.model_interpreted

end Silver.Names.SourceBridge
