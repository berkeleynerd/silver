module

public import Silver.ArrayBindingsNativeEquations

@[expose] public section

/-! Source allocation order establishes unique component mutability. This is
stronger than the native metadata shape invariant and is derived from the
actual declaration trace. -/
namespace Silver.ArrayBindings

theorem ordered_mutability {names : Metadata} {item : Binding} {cell : Nat}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (inside : item.descriptor.ContainsCell cell)
    (scalars : Integer.Mutability) : mutability names scalars cell = item.mutable := by
  induction names with
  | nil => simp at member
  | cons head tail ih =>
      have order := List.pairwise_cons.mp ordered
      rcases List.mem_cons.mp member with same | member
      · subst item
        simp only [mutability, List.find?_cons, inside, decide_true]
      · have separate := order.1 item member
        have headLength := binding_descriptor_length (valid head (by simp))
        have absent : ¬head.descriptor.ContainsCell cell := by
          intro contained
          simp only [Integer.ArrayDescriptor.ContainsCell] at contained inside
          rw [headLength] at contained
          dsimp only [Binding.descriptor] at contained inside
          omega
        have rest := ih (fun entry found => valid entry (by simp [found])) order.2 member
        simpa only [mutability, List.find?_cons, absent, decide_false, Bool.false_eq_true, ↓reduceIte] using rest

theorem ordered_allCells {names : Metadata} {item : Binding}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (writable : item.mutable = true) (scalars : Integer.Mutability) :
    item.descriptor.allCells (mutability names scalars) = true := by
  apply (Integer.ArrayDescriptor.allCells_iff _ _).mpr
  intro cell inside
  exact (ordered_mutability valid ordered member inside scalars).trans writable

end Silver.ArrayBindings
