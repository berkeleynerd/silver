module

public import Silver.FunctionDeclarationHeaderEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

private theorem cursor_type (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (position : Nat) (bound : position ≤ text.length + 1) : CursorType position := by
  have size := tv.2
  unfold CursorType
  omega

private theorem span_types (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (first after : Nat) (span : FunctionBindings.NameSpan text first after) : CursorType first ∧ CursorType after :=
  ⟨cursor_type text tv first (by have a := span.2.1; have b := span.2.2; omega), cursor_type text tv after span.2.2⟩

/-- The native Valid_State representation already contains every active
record bound. This removes an otherwise redundant record premise for callers
that enter through the existing complete native state domain. -/
theorem native_state_record (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (state : ParserState) (valid : NativeValidState text state) : StateRecord state := by
  rcases valid.base with ⟨position, names, dynamic, target, capacity, scalars, arrays,
    subtypes, booleans, metadata, firstParameter, parameterCapacity, procedureMetadata, procedureFirst, procedureCapacity⟩
  refine ⟨cursor_type text tv _ position, ?_, parameterCapacity, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, capacity, ?_, procedureCapacity⟩
  · refine ⟨metadata.1, metadata.2.1, ?_, ?_⟩
    · intro item member
      have itemValid := metadata.2.2.1 item member
      have name := span_types text tv item.first item.after itemValid.1
      exact ⟨name.1, name.2, itemValid.2.1⟩
    · intro item member
      rcases metadata.2.2.2 item member with ⟨span, countPositive, firstPositive, firstBound, countBound, resultBounds, _⟩
      have name := span_types text tv item.first item.after span
      have count := metadata.2.1
      exact ⟨name.1, name.2, by omega, by omega, resultBounds⟩
  · refine ⟨names.1, ?_⟩
    intro item member
    have info := names.2 item member
    have name := span_types text tv item.first item.after info.1
    obtain ⟨index, within, atIndex⟩ := List.mem_iff_getElem.mp member
    have found : Bindings.BindingEnvironment.get state.names (index + 1) = some item := by
      simp only [Bindings.BindingEnvironment.get, Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, ↓reduceIte,
        Nat.add_sub_cancel, List.getElem?_eq_getElem within, atIndex]
    have indices := valid.bounds (index + 1) item found
    exact ⟨name.1, name.2, cursor_type text tv _ info.2.1, info.2.2, indices.1, indices.2.1⟩
  · refine ⟨scalars.1, ?_⟩
    intro item member
    rcases scalars.2 item member with ⟨positive, ordered, bound, valueBounds, declaredBounds⟩
    have name := span_types text tv item.first item.after ⟨positive, ordered, bound⟩
    exact ⟨name.1, name.2, valueBounds, declaredBounds⟩
  · refine ⟨arrays.1.1, ?_, arrays.2.1, arrays.2.2.1.1, arrays.2.2.1.2⟩
    intro item member
    rcases arrays.1.2.1 item member with ⟨positive, ordered, bound, data⟩
    rcases data with ⟨bounds, _, _, extent, _, component, _⟩
    have name := span_types text tv item.first item.after ⟨positive, ordered, bound⟩
    exact ⟨name.1, name.2, bounds, by omega, by omega, component⟩
  · refine ⟨subtypes.1, ?_⟩
    intro item member
    rcases subtypes.2 item member with ⟨positive, ordered, bound, bounds, _⟩
    have name := span_types text tv item.first item.after ⟨positive, ordered, bound⟩
    exact ⟨name.1, name.2, bounds⟩
  · refine ⟨booleans.1, ?_⟩
    intro item member
    exact span_types text tv item.first item.after (booleans.2 item member)
  · rcases dynamic with empty | span
    · change state.dynamicFirst = 0 ∧ state.dynamicAfter = 0 at empty
      rw [empty.1]
      exact Nat.zero_le _
    · exact (span_types text tv _ _ span).1
  · rcases dynamic with empty | span
    · change state.dynamicFirst = 0 ∧ state.dynamicAfter = 0 at empty
      rw [empty.2]
      exact Nat.zero_le _
    · exact (span_types text tv _ _ span).2
  · exact Nat.le_trans target names.1
  · refine ⟨procedureMetadata.1, procedureMetadata.2.1, ?_, ?_⟩
    · intro item member
      have itemValid := procedureMetadata.2.2.1 item member
      have name := span_types text tv item.first item.after itemValid.1
      exact ⟨name.1, name.2, itemValid.2.1⟩
    · intro item member
      rcases procedureMetadata.2.2.2 item member with ⟨span, countPositive, firstPositive, firstBound, countBound⟩
      have name := span_types text tv item.first item.after span
      have count := procedureMetadata.2.1
      exact ⟨name.1, name.2, by omega, by omega⟩

theorem StateInput.ofNative {text state} (tv : FunctionBindings.Native.ValidText text)
    (valid : NativeValidState text state) : StateInput text state :=
  ⟨native_state_record text tv state valid, valid⟩

end Silver.Compose.FunctionDeclarationNative
