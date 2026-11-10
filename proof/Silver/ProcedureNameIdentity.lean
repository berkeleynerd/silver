module

public import Silver.ProcedureNameScanner

@[expose] public section

namespace Silver.Predicate
open Compose

/-- Equality of the native spelling comparison is symmetric on its entire
declared domain, including empty and out-of-range spans. -/
theorem equalName_symm {text : Source} {a b c d : Nat}
    (same : Named.equalName text a b c d = true) :
    Named.equalName text c d a b = true := by
  simp only [Named.equalName, Bool.and_eq_true, decide_eq_true_eq] at same ⊢
  refine ⟨same.1.symm, ?_⟩
  intro index
  exact (same.2 ⟨index.val, by omega⟩).symm

theorem equalName_trans {text : Source} {a b c d e f : Nat}
    (first : Named.equalName text a b c d = true)
    (second : Named.equalName text c d e f = true) :
    Named.equalName text a b e f = true := by
  simp only [Named.equalName, Bool.and_eq_true, decide_eq_true_eq] at first second ⊢
  refine ⟨first.1.trans second.1, ?_⟩
  intro index
  exact (first.2 index).trans (second.2 ⟨index.val, by omega⟩)

theorem scalarLookupFrom_spelling {text : Source} {names : ScalarExpression.Environment}
    {first after count index : Nat}
    (found : ScalarExpression.lookupFrom text names first after count = index)
    (positive : index ≠ 0) :
    Named.equalName text (ScalarExpression.binding names index).first
      (ScalarExpression.binding names index).after first after = true := by
  induction count with
  | zero => exact False.elim (positive found.symm)
  | succ count ih =>
      rw [ScalarExpression.lookupFrom] at found
      split at found
      · exact False.elim (positive found.symm)
      · split at found
        · rename_i matching
          cases found
          exact matching
        · exact ih found

theorem booleanLookupFrom_spelling {text : Source} {names : BooleanBindings.Environment}
    {first after count index : Nat}
    (found : BooleanBindings.lookupFrom text names first after count = index)
    (positive : index ≠ 0) :
    Named.equalName text (BooleanBindings.binding names index).first
      (BooleanBindings.binding names index).after first after = true := by
  induction count with
  | zero => exact False.elim (positive found.symm)
  | succ count ih =>
      rw [BooleanBindings.lookupFrom] at found
      split at found
      · exact False.elim (positive found.symm)
      · split at found
        · rename_i matching
          cases found
          exact matching
        · exact ih found

/-- Two spellings resolving to one scalar binding must compare equal even
when the environment has shadowed or duplicate entries. -/
theorem scalarLookup_same_spelling {text : Source} {names : ScalarExpression.Environment}
    {leftFirst leftAfter rightFirst rightAfter index : Nat}
    (left : ScalarExpression.lookup text names leftFirst leftAfter = index)
    (right : ScalarExpression.lookup text names rightFirst rightAfter = index)
    (positive : index ≠ 0) :
    Named.equalName text leftFirst leftAfter rightFirst rightAfter = true :=
  equalName_trans (equalName_symm (scalarLookupFrom_spelling left positive))
    (scalarLookupFrom_spelling right positive)

theorem booleanLookup_same_spelling {text : Source} {names : BooleanBindings.Environment}
    {leftFirst leftAfter rightFirst rightAfter index : Nat}
    (left : BooleanBindings.lookup text names leftFirst leftAfter = index)
    (right : BooleanBindings.lookup text names rightFirst rightAfter = index)
    (positive : index ≠ 0) :
    Named.equalName text leftFirst leftAfter rightFirst rightAfter = true :=
  equalName_trans (equalName_symm (booleanLookupFrom_spelling left positive))
    (booleanLookupFrom_spelling right positive)

end Silver.Predicate
