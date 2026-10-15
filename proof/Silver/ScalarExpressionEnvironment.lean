module

public import Silver.ScalarExpression

@[expose] public section

namespace Silver.ScalarExpression

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
