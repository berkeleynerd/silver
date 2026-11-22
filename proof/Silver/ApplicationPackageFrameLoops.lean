module

public import Silver.ApplicationPackageFrames

@[expose] public section

/-! The in-place active-prefix compaction used by Hide_Outer. The available
storage invariant proves every write is in the original prefix; only the final
Count reduction discards the unused suffix. -/
namespace Silver.ApplicationPackageFrames

def compactRows {α : Type} (selected outer : α → Bool)
    (kept : Nat) (storage : List α) : List α → Option (Nat × List α)
  | [] => some (kept, storage)
  | item :: rest =>
      if selected item then
        if outer item then compactRows selected outer kept storage rest else none
      else compactRows selected outer (kept + 1) (storage.set kept item) rest

theorem take_set_next {α : Type} (storage : List α) (kept : Nat) (item : α)
    (inside : kept < storage.length) :
    (storage.set kept item).take (kept + 1) = storage.take kept ++ [item] := by
  induction kept generalizing storage with
  | zero => cases storage <;> simp_all
  | succ kept ih =>
      cases storage with
      | nil => simp at inside
      | cons head tail =>
          simp only [List.length_cons, Nat.succ_lt_succ_iff] at inside
          change head :: (tail.set kept item).take (kept + 1) =
            head :: (tail.take kept ++ [item])
          exact congrArg (head :: ·) (ih tail inside)

theorem compactRows_meaning {α : Type} (selected outer : α → Bool)
    (pending storage : List α) (kept : Nat)
    (space : kept + pending.length ≤ storage.length) :
    (compactRows selected outer kept storage pending).map (fun result => result.2.take result.1) =
      (hideEntries selected outer pending).map (storage.take kept ++ ·) := by
  induction pending generalizing storage kept with
  | nil => simp [compactRows, hideEntries]
  | cons item rest ih =>
      by_cases matched : selected item = true
      · by_cases removable : outer item = true
        · simp only [compactRows, hideEntries, matched, removable, ↓reduceIte]
          apply ih
          simp only [List.length_cons] at space
          omega
        · simp [compactRows, hideEntries, matched, removable]
      · simp only [compactRows, hideEntries, matched, Bool.false_eq_true, ↓reduceIte]
        have room : kept < storage.length := by simp only [List.length_cons] at space; omega
        have remaining : kept + 1 + rest.length ≤ (storage.set kept item).length := by
          simp only [List.length_set, List.length_cons] at space ⊢
          omega
        rw [ih _ _ remaining, take_set_next storage kept item room, Option.map_map]
        congr 1
        funext suffix
        simp only [Function.comp_def, List.append_assoc, List.singleton_append]

theorem compactRows_full {α : Type} (selected outer : α → Bool) (items : List α) :
    (compactRows selected outer 0 items items).map (fun result => result.2.take result.1) =
      hideEntries selected outer items := by
  simpa only [List.take_zero, List.nil_append, Option.map_id'] using
    compactRows_meaning selected outer items items 0 (by omega)

end Silver.ApplicationPackageFrames
