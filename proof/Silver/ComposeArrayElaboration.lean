module

public import Silver.ComposeArrayDeclarations

@[expose] public section

/-! Storage facts derived from ordered source aggregate readings. The native
validity invariant permits a full zero-extended table; source elaboration also
maintains an exact prefix and ordered, disjoint allocation. -/
namespace Silver.Compose
open Expressions

set_option maxHeartbeats 4000000
set_option maxRecDepth 10000

theorem arrayValues_fields {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    final = {result with position := final.position, arrayNames := {result.arrayNames with
      used := final.arrayNames.used, values := final.arrayNames.values}} := by
  induction reading with
  | done => rfl
  | next _ _ _ _ _ _ _ ih => exact ih

theorem arrayValues_used {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    final.arrayNames.used = result.arrayNames.used + (length - parsed) := by
  induction reading with
  | done _ finished => dsimp only; omega
  | next _ remaining _ _ _ _ _ ih => dsimp only at ih; omega

theorem arrayValues_canonical {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final)
    (canonical : result.arrayNames.values.length = result.arrayNames.used) :
    ∃ items, Integer.arrayInitialValues (declarationRanges source) expressions = some items ∧
      final.arrayNames.values = result.arrayNames.values ++ items ∧
      final.arrayNames.values.length = final.arrayNames.used := by
  induction reading with
  | done => exact ⟨[], rfl, by simp, canonical⟩
  | @next result final position length parsed expression value rest _ _ reading _ singleton _ tail ih =>
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

theorem putInitial_valid {values : ArrayBindings.Initials} {slot : Nat} {value : Int}
    (valid : ArrayBindings.ValidInitials values) (bound : slot ≤ ArrayBindings.maxElements)
    (safe : Integer.InRange value) : ArrayBindings.ValidInitials (ArrayBindings.putInitial values slot value) := by
  refine ⟨by rw [ArrayBindings.putInitial_length]; exact Nat.max_le.mpr ⟨valid.1, bound⟩, ?_⟩
  intro observed member
  obtain ⟨offset, _, rfl⟩ := List.mem_map.mp member
  split
  · exact safe
  · have prior := ArrayBindings.initialValue_inRange valid (offset + 1)
    simpa only [ArrayBindings.initialValue, Nat.add_sub_cancel] using prior

theorem arrayValues_initials_valid {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final)
    (valid : ArrayBindings.ValidInitials result.arrayNames.values)
    (capacity : result.arrayNames.used + (length - parsed) ≤ ArrayBindings.maxElements) :
    ArrayBindings.ValidInitials final.arrayNames.values := by
  induction reading with
  | done => exact valid
  | next _ remaining reading _ _ _ _ ih =>
      apply ih
      · exact putInitial_valid valid (by omega) (Integer.Expr.infer_bounded reading.inferred).1
      · dsimp only; omega

theorem array_declaration_binding_valid {text arguments state parts}
    (ready : ArrayDeclarationReady text state arguments parts)
    (header : IntegerArrayHeaderAt text state parts)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidBinding (parts.binding state) := by
  have bounded := header.bounded types subtypes
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, ordered, capacity, _, _, _⟩
  simp only [ArrayBindings.ValidBinding, ArrayDeclarationParts.binding, ArrayDeclarationParts.length]
  exact ⟨⟨bounded.1.1, bounded.2.1.1⟩, ordered, by omega, by omega, by omega,
    bounded.2.2.1, bounded.2.2.2⟩

theorem arrayValues_componentFit {text source componentBounds result position length parsed expressions final}
    (reading : ArrayValuesAt text source componentBounds result position length parsed expressions final) :
    Integer.arrayComponentsFit (declarationRanges source) componentBounds expressions = true := by
  induction reading with
  | done => rfl
  | @next result final position length parsed expression value rest _ _ reading nonempty _ contained _ ih =>
      have included : value.bounds.included componentBounds = true := by
        simp only [Integer.Interval.included, nonempty, Bool.false_or, decide_eq_true_eq]
        exact contained
      have inferred : expression.infer (declarationRanges source) = some value.bounds := reading.inferred
      simp only [Integer.arrayComponentsFit, List.all_cons, inferred, included, Bool.true_and]
      exact ih

theorem array_declaration_checked {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ∃ items, declaration.check (declarationRanges state) = some items := by
  cases reading with
  | declaration _ ready header _ values _ _ =>
      have bindingValid := array_declaration_binding_valid ready header types subtypes
      have descriptorValid := ArrayBindings.binding_descriptor_valid bindingValid
      have count := arrayValues_length values
      obtain ⟨items, checked⟩ := arrayValues_initialValues values
      refine ⟨items, ?_⟩
      simp only [Integer.ArrayDeclaration.check]
      rw [ite_eq_left ⟨descriptorValid, ArrayBindings.binding_component_valid bindingValid,
        by simpa only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.length,
          ArrayDeclarationParts.binding, ArrayDeclarationParts.length, Nat.sub_zero] using count,
        arrayValues_componentFit values⟩]
      exact checked

theorem array_declaration_array_valid {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (valid : ArrayBindings.ValidEnvironment text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidEnvironment text final.arrayNames := by
  cases reading with
  | @declaration values parts position following expressions partsEq ready header _ valuesRead _ _ =>
      have bindingValid := array_declaration_binding_valid ready header types subtypes
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
      refine ⟨⟨?_, ?_, ?_⟩, ?_, initials, ?_⟩
      · dsimp only
        rw [metadata, List.length_append, List.length_singleton]
        omega
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with member | rfl
        · exact valid.1.2.1 item (metadata ▸ member)
        · exact ⟨by change 0 < parts.first; omega, by change parts.first < parts.after; omega, nameBound, bindingValid⟩
      · dsimp only
        rw [metadata, List.pairwise_append]
        refine ⟨valid.1.2.2, by simp, ?_⟩
        intro left member right last
        have same := List.mem_singleton.mp last
        subst right
        exact valid.2.2.2 left member
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
    (ready : ArrayBindings.SourceReady text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  have valid := array_declaration_array_valid reading ready.1 types subtypes
  cases reading with
  | @declaration values parts position following expressions _ allowed header _ valuesRead _ _ =>
      obtain ⟨items, checked, table, canonical⟩ := arrayValues_canonical valuesRead ready.2.1
      have metadata : values.arrayNames.names = state.arrayNames.names :=
        congrArg (fun s => s.arrayNames.names) (arrayValues_fields valuesRead)
      have count : items.length = parts.length := by
        have used := arrayValues_used valuesRead
        rw [table, List.length_append, ready.2.1] at canonical
        simp only [Nat.sub_zero] at used
        omega
      have bindingValid := array_declaration_binding_valid allowed header types subtypes
      refine ⟨valid, ?_, valid.1.2.2, ?_⟩
      · exact (arrayValues_canonical valuesRead ready.2.1).choose_spec.2.2
      · change ArrayBindings.InitialsFit (values.arrayNames.names ++ [parts.binding state]) values.arrayNames.values
        rw [metadata, table]
        apply ArrayBindings.initialsFit_append ready.2.2.2
        · intro entry member
          rw [ArrayBindings.binding_descriptor_length ((ready.1.1.2.1 entry member).2.2.2), ready.2.1]
          exact ready.1.2.2.2 entry member
        · exact ready.2.1.symm
        · rw [ArrayBindings.binding_descriptor_length bindingValid]
          exact count
        · exact bindingValid.2.2.2.2.2.1
        · exact Integer.arrayInitialValues_components checked (arrayValues_componentFit valuesRead)

theorem array_declaration_advances {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    state.position < final.position := by
  cases reading with
  | declaration _ _ _ _ _ _ advances => exact advances

theorem array_declaration_fields {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.capacity = state.capacity ∧ final.target = state.target ∧
      final.dynamicFirst = state.dynamicFirst ∧ final.dynamicAfter = state.dynamicAfter := by
  cases reading with
  | declaration _ _ _ _ values _ _ =>
      have fields := arrayValues_fields values
      exact ⟨congrArg (fun s => s.capacity) fields, congrArg (fun s => s.target) fields,
        congrArg (fun s => s.dynamicFirst) fields, congrArg (fun s => s.dynamicAfter) fields⟩

theorem array_declaration_subtypes {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.subtypeNames = state.subtypeNames := by
  cases reading with
  | declaration _ _ _ _ values _ _ =>
      exact congrArg (fun s => s.subtypeNames) (arrayValues_fields values)

theorem arrayValues_unique {text source componentBounds result position length parsed left right firstFinal secondFinal}
    (first : ArrayValuesAt text source componentBounds result position length parsed left firstFinal)
    (second : ArrayValuesAt text source componentBounds result position length parsed right secondFinal) :
    left = right ∧ firstFinal = secondFinal := by
  have states := (arrayValues_complete first).symm.trans (arrayValues_complete second)
  refine ⟨?_, states⟩
  induction first generalizing right secondFinal with
  | done _ finished =>
      cases second with
      | done => rfl
      | next _ remaining _ _ _ _ _ => omega
  | next _ remaining reading _ _ _ _ ih =>
      cases second with
      | done _ finished => omega
      | next _ _ other _ _ _ tail =>
          obtain ⟨rfl, rfl⟩ := ScalarExpression.ArrayGrammar.at_unique reading other
          rw [ih tail states]

theorem array_declaration_unique {text arguments state left right firstFinal secondFinal}
    (first : ArrayDeclarationAt text arguments state left firstFinal)
    (second : ArrayDeclarationAt text arguments state right secondFinal) :
    left = right ∧ firstFinal = secondFinal := by
  have states := (array_declaration_complete first).symm.trans (array_declaration_complete second)
  refine ⟨?_, states⟩
  cases first with
  | declaration parts _ _ aggregate values _ _ =>
      cases second with
      | declaration otherParts _ _ otherAggregate otherValues _ _ =>
          have sameParts := parts.symm.trans otherParts
          cases sameParts
          have samePosition := (arrayAggregate_complete aggregate).symm.trans (arrayAggregate_complete otherAggregate)
          cases samePosition
          have sameValues := (arrayValues_unique values otherValues).1
          cases sameValues
          rfl

end Silver.Compose
