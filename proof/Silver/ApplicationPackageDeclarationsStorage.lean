module

public import Silver.ApplicationPackageDeclarationsTypes

@[expose] public section

/-! The native table retains all cells, while the language model exposes its
active prefix. Adjacent count growth and the immediate write into that new slot
are interpreted together; no inactive value is read or assumed initialized by
the model. This lemma does not change the shared count-reduction semantics. -/
namespace Silver.ApplicationPackageDeclarations.Storage

structure Table (α : Type) where
  count : Nat
  cells : List α

def Table.active (table : Table α) : List α := table.cells.take table.count

/-- Native zero-based rendition of Count := Count + 1; Items (Count) := value. -/
def Table.growAndWrite (table : Table α) (value : α) : Table α :=
  ⟨table.count + 1, table.cells.set table.count value⟩

theorem growAndWrite_active {α : Type} (table : Table α) (value : α)
    (spare : table.count < table.cells.length) :
    (table.growAndWrite value).active = table.active ++ [value] := by
  unfold Table.growAndWrite Table.active
  rw [List.take_succ_eq_append_getElem (by simpa using spare)]
  rw [List.take_set_of_le (Nat.le_refl table.count), List.getElem_set_self]

theorem growAndWrite_count {α : Type} (table : Table α) (value : α) :
    (table.growAndWrite value).count = table.count + 1 := rfl

theorem growAndWrite_capacity {α : Type} (table : Table α) (value : α) :
    (table.growAndWrite value).cells.length = table.cells.length := List.length_set ..

end Silver.ApplicationPackageDeclarations.Storage
