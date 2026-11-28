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

/-- Reconstruct a new active prefix when the native program assigns its count.
A newly exposed cell has its actual backing value. The caller supplies that
value for each zero-based storage index. -/
def resize (active : List α) (dormant : Nat → α) (count : Nat) : List α :=
  (List.range count).map fun index => active[index]?.getD (dormant index)

theorem resize_length (active : List α) (dormant : Nat → α) (count : Nat) :
    (resize active dormant count).length = count := by simp [resize]

theorem resize_current (active : List α) (dormant : Nat → α) :
    resize active dormant active.length = active := by
  apply List.ext_getElem (by simp [resize])
  intro index _ present
  simp [resize, List.getElem?_eq_getElem present]

theorem resize_next (active : List α) (dormant : Nat → α) :
    resize active dormant (active.length + 1) = active ++ [dormant active.length] := by
  unfold resize
  rw [List.range_succ, List.map_append]
  change resize active dormant active.length ++ _ = _
  rw [resize_current]
  simp

/-- Exposing a previously inactive native cell and then overwriting it leaves
the newly committed value regardless of the incoming contents. -/
theorem write_after_resize (active : List α) (dormant : Nat → α) (value : α) :
    (resize active dormant (active.length + 1)).set active.length value = active ++ [value] := by
  rw [resize_next, List.set_append_right _ _ (Nat.le_refl _)]
  simp

/-- Exact projection of an ordinary count assignment on fixed native backing
storage. Both the old and new active counts range over the storage capacity. -/
theorem resize_native (table : Table α) (requested : Nat) (fallback : α)
    (oldBound : table.count ≤ table.cells.length) (newBound : requested ≤ table.cells.length) :
    resize table.active (fun index => table.cells.getD index fallback) requested =
      ({table with count := requested} : Table α).active := by
  apply List.ext_getElem (by simp [resize, Table.active, Nat.min_eq_left newBound])
  intro index present _
  have beforeEnd : index < requested := by simpa [resize] using present
  have within : index < table.cells.length := Nat.lt_of_lt_of_le beforeEnd newBound
  simp only [resize, List.getElem_map, List.getElem_range]
  by_cases before : index < table.count
  · have activeBound : index < table.active.length := by
      simpa [Table.active, Nat.min_eq_left oldBound] using before
    rw [List.getElem?_eq_getElem activeBound]
    simp only [Option.getD_some, Table.active, List.getElem_take]
  · have inactive : table.active[index]? = none := List.getElem?_eq_none_iff.mpr (by
      simp [Table.active, Nat.min_eq_left oldBound]; omega)
    rw [inactive]
    simp only [Option.getD_none, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within,
      Option.getD_some, Table.active, List.getElem_take]

end Silver.ApplicationPackageDeclarations.Storage
