module

public import Silver.ComposeArrayDeclarations

@[expose] public section

/-! Storage facts derived from ordered source aggregate readings. The native
validity invariant permits a full zero-extended table; source elaboration also
maintains an exact prefix and ordered, disjoint allocation. -/
namespace Silver.Compose
open Expressions

theorem arrayValues_fields {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    final = {result with position := final.position, arrayNames := {result.arrayNames with
      used := final.arrayNames.used, values := final.arrayNames.values}} := by
  induction reading with
  | done => rfl
  | next _ _ _ _ _ _ ih => exact ih

theorem arrayValues_used {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final) :
    final.arrayNames.used = result.arrayNames.used + (length - parsed) := by
  induction reading with
  | done _ finished => dsimp only; omega
  | next _ remaining _ _ _ _ ih => dsimp only at ih; omega

theorem arrayValues_canonical {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final)
    (canonical : result.arrayNames.values.length = result.arrayNames.used) :
    ∃ items, Integer.arrayInitialValues (declarationRanges source) expressions = some items ∧
      final.arrayNames.values = result.arrayNames.values ++ items ∧
      final.arrayNames.values.length = final.arrayNames.used := by
  induction reading with
  | done => exact ⟨[], rfl, by simp, canonical⟩
  | @next result final position length parsed expression value rest _ _ reading _ singleton tail ih =>
      have append : ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1)
          value.bounds.lower = result.arrayNames.values ++ [value.bounds.lower] := by
        rw [← canonical, ArrayBindings.putInitial_append]
      have nextCanonical : (ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1)
          value.bounds.lower).length = result.arrayNames.used + 1 := by
        rw [append, List.length_append, List.length_singleton, canonical]
      obtain ⟨items, checked, table, finalCanonical⟩ := ih nextCanonical
      refine ⟨value.bounds.lower :: items, ?_, ?_, finalCanonical⟩
      · rw [Integer.arrayInitialValues, show expression.infer (declarationRanges source) = some value.bounds from reading.inferred]
        simp only [Option.bind_some, singleton, ↓reduceIte, checked, Option.map_some]
      · dsimp only at table
        rw [table, append, List.append_assoc]
        rfl

private theorem putInitial_valid {values : ArrayBindings.Initials} {slot : Nat} {value : Int}
    (valid : ArrayBindings.ValidInitials values) (bound : slot ≤ ArrayBindings.maxElements)
    (safe : Integer.InRange value) : ArrayBindings.ValidInitials (ArrayBindings.putInitial values slot value) := by
  refine ⟨by rw [ArrayBindings.putInitial_length]; exact Nat.max_le.mpr ⟨valid.1, bound⟩, ?_⟩
  intro observed member
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp member
  split
  · exact safe
  · have prior := ArrayBindings.initialValue_inRange valid (offset + 1)
    simpa only [ArrayBindings.initialValue, Nat.add_sub_cancel] using prior

theorem arrayValues_initials_valid {text source result position length parsed expressions final}
    (reading : ArrayValuesAt text source result position length parsed expressions final)
    (valid : ArrayBindings.ValidInitials result.arrayNames.values)
    (capacity : result.arrayNames.used + (length - parsed) ≤ ArrayBindings.maxElements) :
    ArrayBindings.ValidInitials final.arrayNames.values := by
  induction reading with
  | done => exact valid
  | next _ remaining reading _ _ _ ih =>
      apply ih
      · exact putInitial_valid valid (by omega) (Integer.Expr.infer_bounded reading.inferred).1
      · dsimp only; omega

theorem array_declaration_binding_valid {text arguments state parts lower upper}
    (ready : ArrayDeclarationReady text state arguments parts)
    (low : ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true))
    (high : ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)) :
    ArrayBindings.ValidBinding (parts.binding state) := by
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, ordered, capacity, _, _, _⟩
  have lowSafe := (Integer.Expr.infer_bounded low.inferred).1
  have highSafe := (Integer.Expr.infer_bounded high.inferred).1
  simp only [ArrayBindings.ValidBinding, ArrayDeclarationParts.binding, ArrayDeclarationParts.length]
  exact ⟨⟨lowSafe, highSafe⟩, ordered, by omega, by omega, by omega⟩

theorem array_declaration_checked {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    ∃ items, declaration.check (declarationRanges state) = some items := by
  cases reading with
  | declaration _ ready low high _ values _ _ =>
      have bindingValid := array_declaration_binding_valid ready low high
      have descriptorValid := ArrayBindings.binding_descriptor_valid bindingValid
      have count := arrayValues_length values
      obtain ⟨items, checked⟩ := arrayValues_initialValues values
      refine ⟨items, ?_⟩
      simp only [Integer.ArrayDeclaration.check]
      rw [ite_eq_left ⟨descriptorValid, by simpa only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.length,
        ArrayDeclarationParts.binding, ArrayDeclarationParts.length, Nat.sub_zero] using count⟩]
      exact checked

theorem array_declaration_array_valid {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (valid : ArrayBindings.ValidEnvironment text state.arrayNames) :
    ArrayBindings.ValidEnvironment text final.arrayNames := by
  cases reading with
  | @declaration values parts lower upper position following expressions partsEq ready low high _ valuesRead _ _ =>
      have bindingValid := array_declaration_binding_valid ready low high
      have fields := arrayValues_fields valuesRead
      have metadata : values.arrayNames.names = state.arrayNames.names := congrArg (fun s => s.arrayNames.names) fields
      have used : values.arrayNames.used = state.arrayNames.used + parts.length := by
        simpa only [Nat.sub_zero] using arrayValues_used valuesRead
      have capacity : state.arrayNames.used + parts.length ≤ ArrayBindings.maxElements := bindingValid.2.2.2.1
      have initials := arrayValues_initials_valid valuesRead valid.2.2.1 (by simpa only [Nat.sub_zero] using capacity)
      have nameBound : parts.after ≤ text.length + 1 := by
        rw [← partsEq]
        exact model_name_valid text _
      have allowed := ready.1
      simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
      have room : state.arrayNames.names.length < ArrayBindings.maxBindings := by
        have available := ready.2.2.2.2.1
        have bounded := valid.1.1
        omega
      refine ⟨⟨?_, ?_⟩, ?_, initials, ?_⟩
      · dsimp only
        rw [metadata, List.length_append, List.length_singleton]
        omega
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with member | rfl
        · exact valid.1.2 item (metadata ▸ member)
        · exact ⟨by change 0 < parts.first; omega, allowed.1.1.1.2, nameBound, bindingValid⟩
      · dsimp only; rw [used]; exact capacity
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with member | rfl
        · have before := valid.2.2.2 item (metadata ▸ member)
          dsimp only; omega
        · dsimp only [ArrayDeclarationParts.binding]
          omega

theorem array_declaration_source_ready {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  have valid := array_declaration_array_valid reading ready.1
  cases reading with
  | @declaration values parts lower upper position following expressions _ _ _ _ _ valuesRead _ _ =>
      obtain ⟨items, _, _, canonical⟩ := arrayValues_canonical valuesRead ready.2.1
      have metadata : values.arrayNames.names = state.arrayNames.names :=
        congrArg (fun s => s.arrayNames.names) (arrayValues_fields valuesRead)
      refine ⟨valid, canonical, ?_⟩
      dsimp only
      rw [metadata, List.pairwise_append]
      refine ⟨ready.2.2, by simp, ?_⟩
      intro left member right last
      simp only [List.mem_singleton] at last
      subst right
      exact ready.1.2.2.2 left member

end Silver.Compose
