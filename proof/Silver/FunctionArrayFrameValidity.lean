module

public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions Named

private theorem invalid_valid (text : Source) : ValidState text invalidState := by
  simp [ValidState, ValidCursor, ValidNames, NameState.Valid, invalidState,
    ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings,
    ArrayBindings.ValidNativeEnvironment, ArrayBindings.ValidTable, ArrayBindings.ValidTypes,
    ArrayBindings.Env.table, ArrayBindings.ValidInitials, ArrayBindings.maxTypes, ArrayBindings.maxBindings,
    IntegerSubtypes.ValidEnvironment, IntegerSubtypes.maxBindings,
    BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFunctions, FunctionBindings.maxFormals,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxProcedures, ProcedureBindings.maxFormals]

/-- The complete helper domain includes empty/rejected frames. Symbolic input
views extend only an empty or symbolic table; they consume no initializer cells. -/
theorem appendArrayParameter_valid {text : Source} {frame : ParserState} {first after typeId : Nat}
    (valid : ValidState text frame) (span : ArrayBindings.NameSpan text first after) :
    ValidState text (appendArrayParameter frame first after typeId) := by
  dsimp only [appendArrayParameter]
  split
  · exact invalid_valid text
  · rename_i allowed
    simp only [not_or] at allowed
    let item := ArrayBindings.arrayType frame.arrayNames.types typeId
    let length := (item.bounds.upper - item.bounds.lower + 1).toNat
    let slot := frame.arrayNames.names.length + 1
    let entry : ArrayBindings.Binding :=
      ⟨first, after, item.bounds, 0, length, false, item.componentBounds, false, typeId, slot⟩
    have native := valid.arrays
    have selected : ArrayBindings.ValidType item :=
      (valid.arrayTypes.type_valid (by omega : 0 < typeId) (by omega)).2
    have nonempty := selected.2.1
    have lengthEq : (length : Int) = item.bounds.upper - item.bounds.lower + 1 := by
      dsimp only [length]
      rw [Int.toNat_of_nonneg (by omega)]
    have lengthBound := selected.length_bound
    have room : frame.arrayNames.names.length < ArrayBindings.maxBindings := by
      have bound := native.1.2.1
      change frame.arrayNames.names.length ≤ ArrayBindings.maxBindings at bound
      omega
    have typeBound : typeId ≤ ArrayBindings.maxTypes := by
      have bound := native.1.1.1
      change frame.arrayNames.types.length ≤ ArrayBindings.maxTypes at bound
      omega
    have shape : ArrayBindings.ValidNativeBinding entry := by
      refine ⟨⟨selected.1, nonempty, ?_, ?_, ?_, selected.2.2.1, selected.2.2.2.1⟩,
        typeBound, ?_, fun _ => rfl, fun _ => ⟨?_, rfl, rfl, rfl⟩⟩
      · change 0 < length; omega
      · change 0 + length ≤ ArrayBindings.maxElements
        simpa only [Nat.zero_add, length] using lengthBound
      · change item.bounds.upper - item.bounds.lower = (length : Int) - 1; omega
      · change slot ≤ ArrayBindings.maxBindings; dsimp only [slot]; omega
      · exact allowed.1
    have coherent : ArrayBindings.TypeCoherent frame.arrayNames.types entry :=
      ⟨by change typeId ≤ frame.arrayNames.types.length; omega, fun _ => ⟨rfl, rfl⟩⟩
    have adjacent : 0 < frame.arrayNames.names.length →
        ArrayBindings.Adjacent (ArrayBindings.binding frame.arrayNames.names frame.arrayNames.names.length) entry := by
      intro positive
      have prior : (ArrayBindings.binding frame.arrayNames.names frame.arrayNames.names.length).viewSlot ≠ 0 :=
        fun zero => allowed.2.2.2.2 ⟨positive, zero⟩
      have fresh : entry.viewSlot ≠ 0 := by change slot ≠ 0; dsimp only [slot]; omega
      exact ⟨⟨fun zero => False.elim (fresh zero), fun zero => False.elim (prior zero)⟩,
        fun zero => False.elim (fresh zero)⟩
    have table := native.1.append room span shape coherent (fun _ => rfl) adjacent
    have arrays : ArrayBindings.ValidNativeEnvironment text
        {frame.arrayNames with names := frame.arrayNames.names ++ [entry]} := by
      refine ⟨table, native.2.1, native.2.2.1, ?_⟩
      intro other member stored
      rcases List.mem_append.mp member with old | added
      · exact native.2.2.2 other old stored
      · have same := List.mem_singleton.mp added
        subst other
        change slot = 0 at stored
        dsimp only [slot] at stored
        omega
    exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
      valid.2.2.2.2.1, valid.2.2.2.2.2.1, arrays, valid.2.2.2.2.2.2.2⟩

end Silver.Compose
