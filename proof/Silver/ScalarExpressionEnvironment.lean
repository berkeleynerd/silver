module

public import Silver.ScalarExpression

@[expose] public section

namespace Silver.ScalarExpression

def maxBindings : Nat := 4096 / 12

/-- The fixed native representation supplies finite Integer endpoints even
when an interval is empty. Source Valid_Environment additionally checks each
live name span; it does not assert that the span spells an identifier. -/
def ValidEnvironment (text : Source) (names : Environment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ item ∈ names,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧ item.bounds.Bounded

def ValidMask (text : Source) (first after : Nat) : Prop :=
  (first = 0 ∧ after = 0) ∨ (0 < first ∧ first < after ∧ after ≤ text.length + 1)

theorem validEnvironment_empty (text : Source) : ValidEnvironment text [] := by
  simp [ValidEnvironment, maxBindings]

theorem validEnvironment_append {text : Source} {names : Environment} {item : Binding}
    (valid : ValidEnvironment text names) (space : names.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧ item.bounds.Bounded) :
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

end Silver.ScalarExpression
