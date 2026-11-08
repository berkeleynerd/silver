module

public import Silver.FunctionBindings

@[expose] public section

namespace Silver.FunctionBindings

theorem valid_empty (text : Source) : ValidMetadata text {} := by
  simp [ValidMetadata, maxFunctions, maxFormals]

theorem ValidSignature.moreParameters {text : Source} {before after : Metadata} {item : Signature}
    (valid : ValidSignature text before item)
    (growth : before.parameters.length ≤ after.parameters.length) : ValidSignature text after item := by
  rcases valid with ⟨span, count, first, firstBound, countBound, bounded, nonempty⟩
  exact ⟨span, count, first, by omega, by omega, bounded, nonempty⟩

theorem appendFormal_valid {text : Source} {functions : Metadata} {item : Formal}
    (valid : ValidMetadata text functions) (space : functions.parameters.length < maxFormals)
    (itemValid : ValidFormal text item) : ValidMetadata text (appendFormal functions item) := by
  refine ⟨valid.1, ?_, ?_, ?_⟩
  · simp only [appendFormal_count]
    omega
  · intro other member
    simp only [appendFormal, List.mem_append, List.mem_singleton] at member
    rcases member with old | rfl
    · exact valid.2.2.1 other old
    · exact itemValid
  · intro other member
    exact (valid.2.2.2 other member).moreParameters (by simp only [appendFormal_count]; omega)

theorem append_valid {text : Source} {functions : Metadata} {item : Signature}
    (valid : ValidMetadata text functions) (space : functions.items.length < maxFunctions)
    (itemValid : ValidSignature text functions item) : ValidMetadata text (append functions item) := by
  refine ⟨?_, valid.2.1, valid.2.2.1, ?_⟩
  · simp only [append_count]
    omega
  · intro other member
    simp only [append, List.mem_append, List.mem_singleton] at member
    rcases member with old | rfl
    · exact valid.2.2.2 other old
    · exact itemValid

end Silver.FunctionBindings
