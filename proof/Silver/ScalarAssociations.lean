module

public import Silver.FunctionBindings
public import Init.Data.List.Nat.Range
public import Init.Data.List.Perm

@[expose] public section

/-! A finite, source-derived set records which formal positions have already
been supplied. The trace retains written order; canonicalization changes only
the order of semantic payloads, never the author's source or expression flow. -/
namespace Silver.ScalarAssociations

abbrev FormalSet := Nat → Bool

def noFormals : FormalSet := fun _ => false

def markFormal (seen : FormalSet) (formal : Nat) : FormalSet :=
  fun index => if index = formal then true else seen index

/-- Each selected formal is new at the point where its payload is checked. -/
inductive FreshSelections : FormalSet → List Nat → Prop
  | nil {seen} : FreshSelections seen []
  | cons {seen formal rest} : seen formal = false →
      FreshSelections (markFormal seen formal) rest →
      FreshSelections seen (formal :: rest)

theorem FreshSelections.unseen {seen selected} (source : FreshSelections seen selected)
    {formal} (present : formal ∈ selected) : seen formal = false := by
  induction source with
  | nil => simp at present
  | @cons seen chosen rest fresh following ih =>
      rcases List.mem_cons.mp present with same | later
      · simpa only [same] using fresh
      · have unmarked := ih later
        by_cases same : formal = chosen
        · simp [markFormal, same] at unmarked
        · simpa only [markFormal, same, ↓reduceIte] using unmarked

theorem FreshSelections.nodup {seen selected} (source : FreshSelections seen selected) :
    selected.Nodup := by
  induction source with
  | nil => exact List.nodup_nil
  | @cons seen formal rest fresh following ih =>
      apply List.nodup_cons.mpr
      refine ⟨?_, ih⟩
      intro present
      have impossible := following.unseen present
      simp [markFormal] at impossible

/-- Exactly as many distinct selections as formals, all in the called slice,
is complete coverage. This includes arbitrary order and does not assume formal
name uniqueness in metadata. -/
theorem selections_complete {first count : Nat} {selected : List Nat}
    (unique : selected.Nodup) (size : selected.length = count)
    (inside : ∀ formal ∈ selected, first ≤ formal ∧ formal < first + count) :
    selected.Perm (List.range' first count) := by
  have subset : selected ⊆ List.range' first count := by
    intro formal present
    have bound := inside formal present
    exact List.mem_range'.mpr ⟨formal - first, by omega, by omega⟩
  apply (List.perm_ext_iff_of_nodup unique (List.nodup_range' 1)).mpr
  intro formal
  refine ⟨fun present => subset present, ?_⟩
  intro present
  by_cases selectedAlready : formal ∈ selected
  · exact selectedAlready
  · have larger : (formal :: selected).Nodup := List.nodup_cons.mpr ⟨selectedAlready, unique⟩
    have included : formal :: selected ⊆ List.range' first count := by
      intro value member
      rcases List.mem_cons.mp member with same | old
      · simpa only [same] using present
      · exact subset old
    have impossible := larger.length_le_of_subset included
    simp only [List.length_cons, List.length_range', size] at impossible
    omega

abbrev Entry (α : Type) := Nat × α

def lookup (fallback : α) (entries : List (Entry α)) (formal : Nat) : Entry α :=
  match entries with
  | [] => (formal, fallback)
  | entry :: rest => if entry.1 = formal then entry else lookup fallback rest formal

@[simp] theorem lookup_formal (fallback : α) (entries : List (Entry α)) (formal : Nat) :
    (lookup fallback entries formal).1 = formal := by
  induction entries with
  | nil => rfl
  | cons entry rest ih =>
      simp only [lookup]
      split
      · assumption
      · exact ih

theorem lookup_member (fallback : α) {entries : List (Entry α)}
    (unique : (entries.map Prod.fst).Nodup) {entry : Entry α} (present : entry ∈ entries) :
    lookup fallback entries entry.1 = entry := by
  induction entries with
  | nil => simp at present
  | cons head rest ih =>
      have distinct := List.nodup_cons.mp unique
      rcases List.mem_cons.mp present with same | later
      · cases same
        simp [lookup]
      · have different : head.1 ≠ entry.1 := by
          intro same
          exact distinct.1 (same ▸ List.mem_map.mpr ⟨entry, later, rfl⟩)
        simp only [lookup, different, ↓reduceIte]
        exact ih distinct.2 later

/-- Semantic payloads in formal order. The fallback is unreachable on a
complete source trace and gives a total definition on malformed helper inputs. -/
def arrange (fallback : α) (entries : List (Entry α)) (first count : Nat) : List (Entry α) :=
  (List.range' first count).map (lookup fallback entries)

@[simp] theorem arrange_keys (fallback : α) (entries : List (Entry α)) (first count : Nat) :
    (arrange fallback entries first count).map Prod.fst = List.range' first count := by
  simp only [arrange, List.map_map]
  calc (List.range' first count).map (fun formal => (lookup fallback entries formal).1) =
      (List.range' first count).map (fun formal => formal) := by
        apply List.map_congr_left
        intro formal _
        exact lookup_formal fallback entries formal
    _ = List.range' first count := List.map_id' _

@[simp] theorem arrange_length (fallback : α) (entries : List (Entry α)) (first count : Nat) :
    (arrange fallback entries first count).length = count := by
  simp [arrange]

theorem arrange_permutation (fallback : α) {entries : List (Entry α)} {first count : Nat}
    (unique : (entries.map Prod.fst).Nodup)
    (complete : (entries.map Prod.fst).Perm (List.range' first count)) :
    entries.Perm (arrange fallback entries first count) := by
  have lookup_original : (entries.map Prod.fst).map (lookup fallback entries) = entries := by
    rw [List.map_map]
    calc entries.map (fun entry => lookup fallback entries entry.1) =
        entries.map (fun entry => entry) := by
          apply List.map_congr_left
          intro entry present
          exact lookup_member fallback unique present
      _ = entries := List.map_id' entries
  have reordered := complete.map (lookup fallback entries)
  simpa only [lookup_original, arrange] using reordered

theorem arrange_member (fallback : α) {entries : List (Entry α)} {first count : Nat}
    (unique : (entries.map Prod.fst).Nodup)
    (complete : (entries.map Prod.fst).Perm (List.range' first count))
    {entry : Entry α} (present : entry ∈ arrange fallback entries first count) : entry ∈ entries :=
  (arrange_permutation fallback unique complete).mem_iff.mpr present

/-- Canonicalization preserves any independently established payload property. -/
theorem arrange_all (fallback : α) {entries : List (Entry α)} {first count : Nat}
    (unique : (entries.map Prod.fst).Nodup)
    (complete : (entries.map Prod.fst).Perm (List.range' first count))
    {property : Entry α → Prop} (holds : ∀ entry ∈ entries, property entry) :
    ∀ entry ∈ arrange fallback entries first count, property entry := by
  intro entry present
  exact holds entry (arrange_member fallback unique complete present)

end Silver.ScalarAssociations
