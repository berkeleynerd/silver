module

public import Silver.ArrayBindingsMetadata

@[expose] public section

/-! Preservation for the exact native table, including named types without
objects and symbolic read-only input views. -/
namespace Silver.ArrayBindings

theorem valid_empty_types (text : Source) : ValidTypes text [] := by
  simp [ValidTypes, maxTypes]

theorem ValidTable.emptyItems {text : Source} {types : TypeEnvironment}
    (valid : ValidTypes text types) : ValidTable text ⟨[], types⟩ := by
  exact ⟨valid, Nat.zero_le _, by simp⟩

theorem ValidNativeEnvironment.emptyItems {text : Source} {types : TypeEnvironment}
    (valid : ValidTypes text types) :
    ValidNativeEnvironment text {types := types} := by
  refine ⟨ValidTable.emptyItems valid, Nat.zero_le _, ?_, ?_⟩
  · simp [ValidInitials, maxElements]
  · simp

theorem binding_append_old (names : Metadata) (item : Binding) {index : Nat}
    (positive : 0 < index) (bound : index ≤ names.length) :
    binding (names ++ [item]) index = binding names index := by
  simp only [binding, List.getD_eq_getElem?_getD,
    List.getElem?_append_left (show index - 1 < names.length by omega)]

theorem binding_append_last (names : Metadata) (item : Binding) :
    binding (names ++ [item]) (names.length + 1) = item := by
  simp [binding, List.getD_eq_getElem?_getD]

theorem ValidTable.append {text : Source} {names : Table} {item : Binding}
    (valid : ValidTable text names) (room : names.items.length < maxBindings)
    (span : NameSpan text item.first item.after) (shape : ValidNativeBinding item)
    (coherent : TypeCoherent names.types item)
    (slot : item.viewSlot ≠ 0 → item.viewSlot = names.items.length + 1)
    (adjacent : 0 < names.items.length → Adjacent (binding names.items names.items.length) item) :
    ValidTable text {names with items := names.items ++ [item]} := by
  refine ⟨valid.1, by simp only [List.length_append, List.length_singleton]; omega, ?_⟩
  intro index member
  have bound := List.mem_range.mp member
  simp only [List.length_append, List.length_singleton] at bound
  by_cases old : index < names.items.length
  · have prior := valid.2.2 index (List.mem_range.mpr old)
    dsimp only
    rw [binding_append_old names.items item (by omega) (by omega)]
    refine ⟨prior.1, prior.2.1, prior.2.2.1, prior.2.2.2.1, ?_⟩
    intro positive
    rw [binding_append_old names.items item positive (by omega)]
    exact prior.2.2.2.2 positive
  · have last : index = names.items.length := by omega
    subst index
    dsimp only
    rw [binding_append_last]
    refine ⟨span, shape, coherent, slot, ?_⟩
    intro positive
    rw [binding_append_old names.items item positive (Nat.le_refl _)]
    exact adjacent positive

theorem ValidTable.appendType {text : Source} {names : Table} {item : ArrayType}
    (valid : ValidTable text names) (room : names.types.length < maxTypes)
    (span : NameSpan text item.first item.after) (shape : ValidType item) :
    ValidTable text {names with types := names.types ++ [item]} := by
  refine ⟨⟨by simp only [List.length_append, List.length_singleton]; omega, ?_⟩, valid.2.1, ?_⟩
  · intro other member
    rcases List.mem_append.mp member with old | added
    · exact valid.1.2 other old
    · have same := List.mem_singleton.mp added
      simpa only [same] using And.intro span shape
  · intro index member
    have prior := valid.2.2 index member
    refine ⟨prior.1, prior.2.1, ?_, prior.2.2.2⟩
    refine ⟨by have bound := prior.2.2.1.1; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
    intro nominal
    dsimp only at nominal ⊢
    rw [arrayType_append_old names.types item _ (by omega) prior.2.2.1.1]
    exact prior.2.2.1.2 nominal

end Silver.ArrayBindings
