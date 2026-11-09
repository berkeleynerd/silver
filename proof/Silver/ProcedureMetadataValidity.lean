module

public import Silver.ProcedureBindings

@[expose] public section

namespace Silver.ProcedureBindings

theorem valid_empty (text : Source) : ValidMetadata text {} := by
  simp [ValidMetadata, maxProcedures, maxFormals]

theorem ValidSignature.moreParameters {text : Source} {before after : Metadata} {item : Signature}
    (valid : ValidSignature text before item)
    (growth : before.parameters.length ≤ after.parameters.length) : ValidSignature text after item := by
  rcases valid with ⟨span, count, first, firstBound, countBound⟩
  exact ⟨span, count, first, by omega, by omega⟩

theorem appendFormal_valid {text : Source} {procedures : Metadata} {item : Formal}
    (valid : ValidMetadata text procedures) (space : procedures.parameters.length < maxFormals)
    (itemValid : ValidFormal text item) : ValidMetadata text (appendFormal procedures item) := by
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

theorem append_valid {text : Source} {procedures : Metadata} {item : Signature}
    (valid : ValidMetadata text procedures) (space : procedures.items.length < maxProcedures)
    (itemValid : ValidSignature text procedures item) : ValidMetadata text (append procedures item) := by
  refine ⟨?_, valid.2.1, valid.2.2.1, ?_⟩
  · simp only [append_count]
    omega
  · intro other member
    simp only [append, List.mem_append, List.mem_singleton] at member
    rcases member with old | rfl
    · exact valid.2.2.2 other old
    · exact itemValid

end Silver.ProcedureBindings
