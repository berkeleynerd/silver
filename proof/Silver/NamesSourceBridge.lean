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
        calls.operationAfter text position operation hidden 1 0 0 = operationAfter text position operation hidden) ∧
      (∀ position default, position ≤ text.length + 1 →
        calls.associationAfter text position default = associationAfter text position default) := by
  refine ⟨checked_source, ?_⟩
  intro calls source text valid
  exact ⟨interpreted_context calls source text valid,
    fun position operation hidden bound => interpreted_operation calls source text valid
      position operation hidden 1 0 0 bound (validContext_default text),
    interpreted_association calls source text valid⟩

/-- Raw context reading is available even when Main imports only its selected
application package and therefore has no runtime IO import. -/
theorem actual_contextual_source_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, ValidText text →
      ∀ contextFirst packageFirst packageAfter,
        ValidContext text contextFirst packageFirst packageAfter →
        calls.readContext text contextFirst packageFirst packageAfter =
          readContext text contextFirst packageFirst packageAfter ∧
        (∀ position operation hidden, position ≤ text.length + 1 →
          calls.operationAfter text position operation hidden contextFirst packageFirst packageAfter =
            operationAfter text position operation hidden contextFirst packageFirst packageAfter) := by
  refine ⟨checked_source, ?_⟩
  intro calls source text valid contextFirst packageFirst packageAfter contextValid
  exact ⟨interpreted_read calls source text valid contextFirst packageFirst packageAfter contextValid,
    fun position operation hidden bound => interpreted_operation calls source text valid
      position operation hidden contextFirst packageFirst packageAfter bound contextValid⟩

theorem actual_package_match_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, ValidText text →
      ∀ position packageFirst packageAfter,
        position ≤ text.length + 1 → ValidNameState text packageFirst packageAfter →
        calls.packageNameAfter text position packageFirst packageAfter =
          packageNameAfter text position packageFirst packageAfter :=
  ⟨checked_source, interpreted_package⟩

theorem model_interpreted : InterpretedSource modelCalls := Names.model_interpreted

end Silver.Names.SourceBridge
