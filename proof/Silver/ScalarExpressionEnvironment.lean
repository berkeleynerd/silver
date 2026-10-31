module

public import Silver.ScalarExpression

@[expose] public section

namespace Silver.ScalarExpression

def maxBindings : Nat := 4096 / 7

/-- The fixed native representation supplies finite Integer endpoints even
when an interval is empty. Source Valid_Environment additionally checks each
live name span; it does not assert that the span spells an identifier. -/
def ValidEnvironment (text : Source) (names : Environment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ item ∈ names,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧ item.bounds.Bounded ∧ item.declaredBounds.Bounded

def ValidMask (text : Source) (first after : Nat) : Prop :=
  (first = 0 ∧ after = 0) ∨ (0 < first ∧ first < after ∧ after ≤ text.length + 1)

theorem validEnvironment_empty (text : Source) : ValidEnvironment text [] := by
  simp [ValidEnvironment, maxBindings]

theorem validEnvironment_append {text : Source} {names : Environment} {item : Binding}
    (valid : ValidEnvironment text names) (space : names.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧ item.bounds.Bounded ∧ item.declaredBounds.Bounded) :
    ValidEnvironment text (names ++ [item]) := by
  refine ⟨by simp only [List.length_append, List.length_singleton]; omega, ?_⟩
  intro other present
  simp only [List.mem_append, List.mem_singleton] at present
  rcases present with old | rfl
  · exact valid.2 other old
  · exact itemValid

theorem binding_append_old (names : Environment) (item : Binding) (index : Nat)
    (positive : 0 < index) (bound : index ≤ names.length) :
    binding (names ++ [item]) index = binding names index := by
  simp only [binding, List.getD_eq_getElem?_getD,
    List.getElem?_append_left (show index - 1 < names.length by omega)]

theorem binding_append_new (names : Environment) (item : Binding) :
    binding (names ++ [item]) (names.length + 1) = item := by
  simp [binding, List.getD_eq_getElem?_getD]

theorem ranges_append (names : Environment) (item : Binding) :
    ranges (names ++ [item]) =
      Integer.put (ranges names) (names.length + 1) (some item.bounds) := by
  funext index
  by_cases fresh : index = names.length + 1
  · subst index
    simp [ranges, Integer.put, binding_append_new]
  · by_cases old : 0 < index ∧ index ≤ names.length
    · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [ranges, extended, old, ↓reduceIte, Integer.put, fresh,
        binding_append_old names item index old.1 old.2]
    · have outside : ¬ (0 < index ∧ index ≤ (names ++ [item]).length) := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [ranges, outside, old, ↓reduceIte, Integer.put, fresh]

/-- Both endpoints of every declared subtype use the native Integer range,
independently of the exact initialization interval carried in Bounds. -/
def DeclaredBoundsValid (names : Environment) : Prop :=
  ∀ item ∈ names, item.declaredBounds.Bounded

theorem validEnvironment_declaredBoundsValid {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) : DeclaredBoundsValid names :=
  fun item present => (valid.2 item present).2.2.2.2

/-- Body admission uses the complete declared subtype for each mutable name.
Immutable snapshots and loop indexes retain their own exact/iteration bounds. -/
def BodyReady (names : Environment) : Prop :=
  ∀ item ∈ names, item.mutable = true → item.bounds = item.declaredBounds

theorem bodyReady_binding {names : Environment} {index : Nat}
    (ready : BodyReady names) (positive : 0 < index) (bounded : index ≤ names.length)
    (mutable : (binding names index).mutable = true) :
    (binding names index).bounds = (binding names index).declaredBounds := by
  apply ready _ _ mutable
  have within : index - 1 < names.length := by omega
  simp only [binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

@[simp] theorem bodyEnvironment_length (names : Environment) :
    (bodyEnvironment names).length = names.length := by simp [bodyEnvironment]

@[simp] theorem bodyBinding_mutable (item : Binding) : (bodyBinding item).mutable = item.mutable := rfl
@[simp] theorem bodyBinding_declaredBounds (item : Binding) :
    (bodyBinding item).declaredBounds = item.declaredBounds := rfl
@[simp] theorem bodyBinding_first (item : Binding) : (bodyBinding item).first = item.first := rfl
@[simp] theorem bodyBinding_after (item : Binding) : (bodyBinding item).after = item.after := rfl
@[simp] theorem bodyBinding_static (item : Binding) : (bodyBinding item).isStatic = item.isStatic := rfl

@[simp] theorem bodyEnvironment_binding (names : Environment) (index : Nat) :
    binding (bodyEnvironment names) index = bodyBinding (binding names index) := by
  simp only [bodyEnvironment, binding, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases names[index - 1]? <;> simp [bodyBinding, emptyBinding]

theorem bodyEnvironment_ready (names : Environment) : BodyReady (bodyEnvironment names) := by
  intro item present mutable
  obtain ⟨original, _, rfl⟩ := List.mem_map.mp present
  change original.mutable = true at mutable
  simp only [bodyBinding, mutable, ↓reduceIte]

theorem bodyReady_append {names : Environment} {item : Binding}
    (ready : BodyReady names) (itemReady : item.mutable = true → item.bounds = item.declaredBounds) :
    BodyReady (names ++ [item]) := by
  intro other present mutable
  rcases List.mem_append.mp present with old | fresh
  · exact ready other old mutable
  · have same : other = item := List.mem_singleton.mp fresh
    subst other
    exact itemReady mutable

theorem bodyReady_append_immutable {names : Environment} {item : Binding}
    (ready : BodyReady names) (immutable : item.mutable = false) :
    BodyReady (names ++ [item]) :=
  bodyReady_append ready (by intro mutable; simp [immutable] at mutable)

theorem declaredBoundsValid_append {names : Environment} {item : Binding}
    (valid : DeclaredBoundsValid names) (bounded : item.declaredBounds.Bounded) :
    DeclaredBoundsValid (names ++ [item]) := by
  intro other present
  rcases List.mem_append.mp present with old | fresh
  · exact valid other old
  · simpa only [List.mem_singleton.mp fresh] using bounded

theorem bodyEnvironment_declaredBoundsValid {names : Environment}
    (valid : DeclaredBoundsValid names) : DeclaredBoundsValid (bodyEnvironment names) := by
  intro item present
  obtain ⟨original, old, rfl⟩ := List.mem_map.mp present
  exact valid original old

theorem bodyEnvironment_valid {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) :
    ValidEnvironment text (bodyEnvironment names) := by
  refine ⟨by simpa using valid.1, ?_⟩
  intro item present
  obtain ⟨original, old, rfl⟩ := List.mem_map.mp present
  have oldValid := valid.2 original old
  refine ⟨oldValid.1, oldValid.2.1, oldValid.2.2.1, ?_, oldValid.2.2.2.2⟩
  change (if original.mutable then original.declaredBounds else original.bounds).Bounded
  split
  · exact oldValid.2.2.2.2
  · exact oldValid.2.2.2.1

theorem bodyEnvironment_mutability (names : Environment) :
    mutability (bodyEnvironment names) = mutability names := by
  funext index
  simp [mutability]

theorem mutability_append (names : Environment) (item : Binding) :
    mutability (names ++ [item]) =
      Integer.put (mutability names) (names.length + 1) item.mutable := by
  funext index
  by_cases fresh : index = names.length + 1
  · subst index
    simp [mutability, Integer.put, binding_append_new]
  · by_cases old : 0 < index ∧ index ≤ names.length
    · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [mutability, extended, old, ↓reduceIte, Integer.put, fresh,
        binding_append_old names item index old.1 old.2]
    · have outside : ¬ (0 < index ∧ index ≤ (names ++ [item]).length) := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [mutability, outside, old, ↓reduceIte, Integer.put, fresh, decide_false, Bool.false_and]

end Silver.ScalarExpression
