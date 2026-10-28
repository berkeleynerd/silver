module

public import Silver.ComposeArrayElaboration
public import Silver.ComposeFrozenSemantics

@[expose] public section

/-! The canonical native table has the same store effect as evaluating every
raw component in the incoming environment and initializing the declared array. -/
namespace Silver.Compose

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
      have oldValid := (ready.1.1.2 old member).2.2.2
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
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    declaration.execute (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) =
      frozenIntegers final.scalarNames final.arrayNames.names final.arrayNames.values := by
  cases reading with
  | @declaration values parts lower upper position following expressions _ allowed low high _ valuesRead _ _ =>
      obtain ⟨items, checked, table, _⟩ := arrayValues_canonical valuesRead ready.2.1
      have evaluated := (Integer.arrayInitialValues_sound checked (frozenIntegers_fits static)).1
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
      exact (array_store_append items _ ready (array_declaration_binding_valid allowed low high) rfl count).symm

end Silver.Compose
