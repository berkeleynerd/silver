module

public import Silver.ArrayBindings
public import Silver.NamedArrayParameters

@[expose] public section

/-! Full native array metadata, including declarations with no object and
symbolic input views. Stored-pool semantic invariants remain separate. -/
namespace Silver.ArrayBindings

def NameSpan (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

def ValidType (item : ArrayType) : Prop :=
  item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper ∧
  item.componentBounds.Bounded ∧ item.componentBounds.lower ≤ item.componentBounds.upper ∧
  item.bounds.upper - item.bounds.lower < (maxElements : Int)

def ValidTypes (text : Source) (types : TypeEnvironment) : Prop :=
  types.length ≤ maxTypes ∧
    ∀ item ∈ types, NameSpan text item.first item.after ∧ ValidType item

/-- Ada field subtype constraints, independent of the validation predicate. -/
def BindingType (item : Binding) : Prop :=
  item.bounds.Bounded ∧ item.offset ≤ maxElements ∧ item.length ≤ maxElements ∧
  item.componentBounds.Bounded ∧ item.typeId ≤ maxTypes ∧ item.viewSlot ≤ maxBindings

def ValidNativeBinding (item : Binding) : Prop :=
  ValidBinding item ∧ item.typeId ≤ maxTypes ∧ item.viewSlot ≤ maxBindings ∧
  (item.typeId ≠ 0 → item.isBoolean = false) ∧
  (item.viewSlot ≠ 0 → item.typeId ≠ 0 ∧ item.offset = 0 ∧
    item.mutable = false ∧ item.isBoolean = false)

def TypeCoherent (types : TypeEnvironment) (item : Binding) : Prop :=
  item.typeId ≤ types.length ∧ (item.typeId ≠ 0 →
    item.bounds = (arrayType types item.typeId).bounds ∧
    item.componentBounds = (arrayType types item.typeId).componentBounds)

def Adjacent (left right : Binding) : Prop :=
  (right.viewSlot = 0 ↔ left.viewSlot = 0) ∧
    (right.viewSlot = 0 → left.offset + left.length ≤ right.offset)

/-- The quantified native predicate uses the complete ordered active prefix.
No pool-cell separation is imposed on symbolic views. -/
def ValidTable (text : Source) (names : Table) : Prop :=
  ValidTypes text names.types ∧ names.items.length ≤ maxBindings ∧
    ∀ index ∈ List.range names.items.length,
      let item := binding names.items (index + 1)
      NameSpan text item.first item.after ∧ ValidNativeBinding item ∧
      TypeCoherent names.types item ∧
      (item.viewSlot ≠ 0 → item.viewSlot = index + 1) ∧
      (0 < index → Adjacent (binding names.items index) item)

def ValidNativeEnvironment (text : Source) (environment : Env) : Prop :=
  ValidTable text environment.table ∧ environment.used ≤ maxElements ∧
    ValidInitials environment.values ∧
    ∀ item ∈ environment.names, item.viewSlot = 0 →
      item.offset + item.length ≤ environment.used

instance (text : Source) (first after : Nat) : Decidable (NameSpan text first after) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))
instance (item : ArrayType) : Decidable (ValidType item) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _))
instance (text : Source) (types : TypeEnvironment) : Decidable (ValidTypes text types) :=
  inferInstanceAs (Decidable (_ ∧ ∀ item ∈ types, _ ∧ _))
instance (item : Binding) : Decidable (BindingType item) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))
instance (item : Binding) : Decidable (ValidNativeBinding item) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ (_ → _) ∧ (_ → _ ∧ _ ∧ _ ∧ _)))
instance (types : TypeEnvironment) (item : Binding) : Decidable (TypeCoherent types item) :=
  inferInstanceAs (Decidable (_ ∧ (_ → _ ∧ _)))
instance (left right : Binding) : Decidable (Adjacent left right) :=
  inferInstanceAs (Decidable ((_ ↔ _) ∧ (_ → _)))
instance (text : Source) (names : Table) : Decidable (ValidTable text names) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ ∀ index ∈ List.range names.items.length,
    NameSpan text (binding names.items (index + 1)).first (binding names.items (index + 1)).after ∧
    ValidNativeBinding (binding names.items (index + 1)) ∧
    TypeCoherent names.types (binding names.items (index + 1)) ∧
    (_ → _) ∧ (_ → _)))

instance (text : Source) (environment : Env) : Decidable (ValidNativeEnvironment text environment) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ (_ ∧ ∀ value ∈ environment.values, _) ∧
    ∀ item ∈ environment.names, _ → _))

def lookupTypeFrom (text : Source) (types : TypeEnvironment) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (arrayType types (index + 1)).first
          (arrayType types (index + 1)).after first after then index + 1
      else lookupTypeFrom text types first after index

def lookupType (text : Source) (types : TypeEnvironment) (first after : Nat) : Nat :=
  lookupTypeFrom text types first after types.length

def ArrayType.domain (item : ArrayType) (identity : Nat) : NamedArrayParameters.Domain :=
  ⟨identity, item.bounds, item.componentBounds⟩

theorem binding_mem {names : Metadata} {index : Nat}
    (positive : 0 < index) (bound : index ≤ names.length) : binding names index ∈ names := by
  have within : index - 1 < names.length := by omega
  simp only [binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem arrayType_mem {types : TypeEnvironment} {index : Nat}
    (positive : 0 < index) (bound : index ≤ types.length) : arrayType types index ∈ types := by
  have within : index - 1 < types.length := by omega
  simp only [arrayType, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem arrayType_prefix (types more : TypeEnvironment) (index : Nat)
    (positive : 0 < index) (bound : index ≤ types.length) :
    arrayType (types ++ more) index = arrayType types index := by
  have within : index - 1 < types.length := by omega
  simp only [arrayType, List.getD_eq_getElem?_getD, List.getElem?_append_left within]

@[simp] theorem arrayType_append_old (types : TypeEnvironment) (item : ArrayType) (index : Nat)
    (positive : 0 < index) (bound : index ≤ types.length) :
    arrayType (types ++ [item]) index = arrayType types index := arrayType_prefix types [item] index positive bound

theorem ValidTable.binding_valid {text : Source} {names : Table} (valid : ValidTable text names)
    {index : Nat} (positive : 0 < index) (bound : index ≤ names.items.length) :
    NameSpan text (binding names.items index).first (binding names.items index).after ∧
      ValidNativeBinding (binding names.items index) ∧ TypeCoherent names.types (binding names.items index) := by
  have checked := valid.2.2 (index - 1) (List.mem_range.mpr (by omega))
  have same : index - 1 + 1 = index := by omega
  rw [same] at checked
  exact ⟨checked.1, checked.2.1, checked.2.2.1⟩

theorem ValidTable.member_valid {text : Source} {names : Table} (valid : ValidTable text names)
    {item : Binding} (member : item ∈ names.items) :
    NameSpan text item.first item.after ∧ ValidNativeBinding item ∧ TypeCoherent names.types item := by
  obtain ⟨index, bound, equal⟩ := List.mem_iff_getElem.mp member
  have checked := valid.binding_valid (index := index + 1) (by omega) (by omega)
  simpa only [binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem bound, Option.getD_some, equal] using checked

theorem ValidTypes.type_valid {text : Source} {types : TypeEnvironment} (valid : ValidTypes text types)
    {index : Nat} (positive : 0 < index) (bound : index ≤ types.length) :
    NameSpan text (arrayType types index).first (arrayType types index).after ∧
      ValidType (arrayType types index) := valid.2 _ (arrayType_mem positive bound)

theorem ValidType.length_bound {item : ArrayType} (valid : ValidType item) :
    (item.bounds.upper - item.bounds.lower + 1).toNat ≤ maxElements := by
  have nonempty := valid.2.1
  have capacity := valid.2.2.2.2
  omega

theorem ValidNativeBinding.length_bound {item : Binding} (valid : ValidNativeBinding item) :
    (item.bounds.upper - item.bounds.lower + 1).toNat ≤ maxElements := by
  have exactLength := valid.1.2.2.2.2.1
  have capacity := valid.1.2.2.2.1
  omega

theorem lookupFrom_bound (text : Source) (names : Metadata) (first after index : Nat) :
    lookupFrom text names first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih => simp only [lookupFrom]; split <;> (first | omega | split <;> omega)

theorem lookup_bound (text : Source) (names : Metadata) (first after : Nat) :
    lookup text names first after ≤ names.length := lookupFrom_bound text names first after names.length

theorem validNativeBinding_type {item : Binding} (valid : ValidNativeBinding item) : BindingType item := by
  rcases valid with ⟨shape, typeBound, viewBound, _⟩
  refine ⟨shape.1, ?_, ?_, shape.2.2.2.2.2.1, typeBound, viewBound⟩ <;>
    have capacity := shape.2.2.2.1 <;> omega

theorem validType_domain {item : ArrayType} (valid : ValidType item) {identity : Nat}
    (positive : 0 < identity) : (item.domain identity).Valid := by
  rcases valid with ⟨bounds, nonempty, components, componentNonempty, capacity⟩
  refine ⟨positive, bounds, nonempty, ?_, components, componentNonempty⟩
  simp only [ArrayType.domain, NamedArrayParameters.Domain.length,
    NamedArrayParameters.maxLength, maxElements] at *
  omega

theorem viewDescriptor_nominal {types : TypeEnvironment} {item : Binding}
    (coherent : TypeCoherent types item) (formal : item.viewSlot ≠ 0)
    (nominal : item.typeId ≠ 0) :
    item.viewDescriptor = ((arrayType types item.typeId).domain item.typeId).formal item.viewSlot := by
  rcases coherent.2 nominal with ⟨bounds, components⟩
  simp [Binding.viewDescriptor, formal, ArrayType.domain, NamedArrayParameters.Domain.formal,
    NamedArrayParameters.Domain.atBase, bounds, components, scalarLimit, maxElements,
    NamedArrayParameters.scalarLimit, NamedArrayParameters.maxLength]

theorem lookupTypeFrom_bound (text : Source) (types : TypeEnvironment) (first after index : Nat) :
    lookupTypeFrom text types first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih => simp only [lookupTypeFrom]; split <;> (first | omega | split <;> omega)

theorem lookupType_bound (text : Source) (types : TypeEnvironment) (first after : Nat) :
    lookupType text types first after ≤ types.length :=
  lookupTypeFrom_bound text types first after types.length

end Silver.ArrayBindings
