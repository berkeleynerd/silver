module

public import Silver.ComposeArrayElaboration
public import Silver.ComposeBooleanArrayElaboration
public import Silver.ComposeFrozenSemantics
public import Silver.ComposeStoredArrays

@[expose] public section

/-! The canonical native table has the same store effect as evaluating every
raw component in the incoming environment and initializing the declared array. -/
namespace Silver.Compose

private theorem integer_source_ready {text : Source} {environment : ArrayBindings.Env}
    (ready : ArrayBindings.SourceReady text environment) :
    ArrayBindings.SourceReady text {environment with names := ArrayBindings.integerNames environment.names} := by
  refine ⟨⟨ArrayBindings.integerNames_validMetadata ready.1.1, ready.1.2.1, ready.1.2.2.1, ?_⟩,
    ready.2.1, ArrayBindings.integerNames_ordered ready.2.2.1, ArrayBindings.integerNames_initialsFit ready.2.2.2⟩
  intro item member
  exact ready.1.2.2.2 item (ArrayBindings.mem_integerNames.mp member).1

private theorem array_store_extend_values {text : Source} {environment : ArrayBindings.Env}
    (ready : ArrayBindings.SourceReady text environment) (items : List Int) (scalars : Integer.Store) :
    ArrayBindings.store environment.names (environment.values ++ items) scalars =
      ArrayBindings.store environment.names environment.values scalars := by
  funext cell
  unfold ArrayBindings.store
  split
  · rename_i covered
    obtain ⟨old, member, inside⟩ := (ArrayBindings.covers_iff _ _).mp covered
    have valid := (ready.1.1.2.1 old member).2.2.2
    have length := ArrayBindings.binding_descriptor_length valid
    have last := ready.1.2.2.2 old member
    have before : cell - ArrayBindings.scalarLimit - 1 < environment.values.length := by
      simp only [Integer.ArrayDescriptor.ContainsCell] at inside
      rw [length] at inside
      simp only [ArrayBindings.Binding.descriptor] at inside
      have canonical := ready.2.1
      omega
    simp only [ArrayBindings.initialValue, List.getD_eq_getElem?_getD, List.getElem?_append_left before]
  · rfl

private theorem array_store_append {text : Source} {environment : ArrayBindings.Env}
    {item : ArrayBindings.Binding} (items : List Int) (scalars : Integer.Store)
    (ready : ArrayBindings.SourceReady text environment)
    (valid : ArrayBindings.ValidBinding item) (offset : item.offset = environment.used)
    (count : items.length = item.length) :
    ArrayBindings.store (environment.names ++ [item]) (environment.values ++ items) scalars =
      item.descriptor.initializeValues (ArrayBindings.store environment.names environment.values scalars) items := by
  have length := ArrayBindings.binding_descriptor_length valid
  have canonicalPrefix : environment.values.length = item.offset := ready.2.1.trans offset.symm
  funext cell
  by_cases inside : item.descriptor.ContainsCell cell
  · have initialized : item.descriptor.base ≤ cell ∧ cell - item.descriptor.base < items.length := by
      simp only [Integer.ArrayDescriptor.ContainsCell, length, ← count] at inside
      omega
    have covered : ArrayBindings.covers (environment.names ++ [item]) cell = true :=
      (ArrayBindings.covers_iff _ _).mpr ⟨item, by simp, inside⟩
    simp only [ArrayBindings.store, covered, ↓reduceIte, Integer.ArrayDescriptor.initializeValues, initialized]
    unfold ArrayBindings.initialValue
    have afterPrefix : environment.values.length ≤ cell - ArrayBindings.scalarLimit - 1 := by
      simp only [ArrayBindings.Binding.descriptor] at initialized
      omega
    have relative : cell - ArrayBindings.scalarLimit - 1 - environment.values.length = cell - item.descriptor.base := by
      simp only [ArrayBindings.Binding.descriptor]
      omega
    rw [List.getD_eq_getElem?_getD, List.getElem?_append_right afterPrefix, relative,
      List.getElem?_eq_getElem initialized.2, Option.getD_some, getElem!_pos items _ initialized.2]
    simp only [and_self, ↓reduceIte]
  · have notInitialized : ¬(item.descriptor.base ≤ cell ∧ cell - item.descriptor.base < items.length) := by
      simp only [Integer.ArrayDescriptor.ContainsCell, length, ← count] at inside
      omega
    have coverage : ArrayBindings.covers (environment.names ++ [item]) cell =
        ArrayBindings.covers environment.names cell := by
      simp only [ArrayBindings.covers, List.any_append, List.any_cons, List.any_nil,
        inside, decide_false, Bool.or_false]
    simp only [ArrayBindings.store, coverage, Integer.ArrayDescriptor.initializeValues,
      notInitialized, ↓reduceIte]
    split
    · rename_i covered
      obtain ⟨old, member, oldInside⟩ := (ArrayBindings.covers_iff _ _).mp covered
      have oldValid := (ready.1.1.2.1 old member).2.2.2
      have oldLength := ArrayBindings.binding_descriptor_length oldValid
      have oldEnd := ready.1.2.2.2 old member
      have inPrefix : cell - ArrayBindings.scalarLimit - 1 < environment.values.length := by
        simp only [Integer.ArrayDescriptor.ContainsCell] at oldInside
        rw [oldLength] at oldInside
        simp only [ArrayBindings.Binding.descriptor] at oldInside
        omega
      simp only [ArrayBindings.initialValue, List.getD_eq_getElem?_getD,
        List.getElem?_append_left inPrefix]
    · rfl

theorem array_declaration_execute {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (stored : state.StoredArrays)
    (ready : ArrayBindings.SourceReady text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    declaration.execute (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) =
      frozenIntegers final.scalarNames final.arrayNames.names final.arrayNames.values := by
  cases reading with
  | @declaration values parts position following expressions _ allowed header _ valuesRead _ _ =>
      obtain ⟨items, checked, table, _⟩ := arrayValues_canonical valuesRead ready.2.1
      have evaluated := (Integer.arrayInitialValues_sound checked (frozenIntegers_view_fits (arrays := state.arrayNames.table) static stored)).1
      change items = expressions.map (Integer.Expr.evaluate
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)) at evaluated
      have count : items.length = parts.length := by
        rw [evaluated, List.length_map]
        simpa only [Nat.sub_zero] using arrayValues_length valuesRead
      have fields := arrayValues_fields valuesRead
      have names : values.arrayNames.names = state.arrayNames.names := congrArg (fun s => s.arrayNames.names) fields
      have scalars : values.scalarNames = state.scalarNames := congrArg (fun s => s.scalarNames) fields
      change (parts.binding state).descriptor.initializeValues
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)
        (expressions.map (Integer.Expr.evaluate (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values))) = _
      rw [← evaluated]
      dsimp only [frozenIntegers]
      rw [scalars, names, table]
      unfold ArrayBindings.integerStore
      rw [ArrayBindings.integerNames_append_integer _ (show (parts.binding state).isBoolean = false from allowed.integer)]
      exact (array_store_append items _ (integer_source_ready ready)
        (array_declaration_binding_valid allowed header types subtypes) rfl count).symm

theorem boolean_array_declaration_integer_store {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    frozenIntegers final.scalarNames final.arrayNames.names final.arrayNames.values =
      frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values := by
  cases reading with
  | @declaration values parts lower upper position following _ allowed _ _ _ valuesEq positive _ _ =>
      have fields := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after
        (valuesEq.symm ▸ positive)
      rw [valuesEq] at fields
      have names : values.arrayNames.names = state.arrayNames.names := congrArg (fun s => s.arrayNames.names) fields
      have scalars : values.scalarNames = state.scalarNames := congrArg (fun s => s.scalarNames) fields
      have table : values.arrayNames.values = state.arrayNames.values ++ List.replicate parts.length 0 := by
        simpa only [valuesEq, Nat.sub_zero] using booleanArrayValuesModel_canonical text state state position parts.length 0
          parts.first parts.after (valuesEq.symm ▸ positive) ready.2.1
      dsimp only [frozenIntegers]
      unfold ArrayBindings.integerStore
      rw [names, scalars, table, ArrayBindings.integerNames_append_boolean _
        (show (parts.binding state).isBoolean = true from allowed.kind)]
      exact array_store_extend_values (integer_source_ready ready) _ _

end Silver.Compose
