module

public import Silver.ImageModelTheoryFields

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Exact matcher evolution, including dead candidates. Unlike the backward
invariant-transfer relation, this also establishes forward matching liveness. -/
def ExactEmits (tables : Native.Tables) (before after : Core.State) (normalized : List Nat) : Prop :=
  ∀ kind, after.matcher.cells kind =
    normalized.foldl (matchByte (tables.byte kind) (tables.length kind)) (before.matcher.cells kind)

theorem ExactEmits.identity (tables : Native.Tables) (state : Core.State) :
    ExactEmits tables state state [] := fun _ => rfl

theorem ExactEmits.trans {tables : Native.Tables} {before middle after : Core.State}
    {left right : List Nat} (first : ExactEmits tables before middle left)
    (second : ExactEmits tables middle after right) : ExactEmits tables before after (left ++ right) := by
  intro kind
  rw [List.foldl_append, second kind, first kind]

theorem ExactEmits.of_matcher_eq (tables : Native.Tables) (before after : Core.State)
    (equal : after.matcher = before.matcher) : ExactEmits tables before after [] := by
  intro kind
  rw [equal, List.foldl_nil]

theorem ExactEmits.of_fold (tables : Native.Tables) (before after : Core.State) (normalized : List Nat)
    (active : before.matcher.inTheory = true)
    (effect : after.matcher = normalized.foldl (Core.matcher tables) before.matcher) :
    ExactEmits tables before after normalized := by
  intro kind
  rw [effect]
  exact SourceBridge.interpreted_fold tables (Core.matcher tables) ⟨fun _ _ => rfl⟩ _ before.matcher active kind

theorem ExactEmits.emits {tables : Native.Tables} {before after : Core.State} {normalized : List Nat}
    (exact : ExactEmits tables before after normalized) : Emits tables before after normalized := by
  intro kind initial invariant
  rw [exact kind]
  exact match_fold_preserves normalized initial (before.matcher.cells kind) invariant

/-- A prefix of the selected table advances a live candidate by exactly its
length. This premise concerns bytes, not an already successful matcher run. -/
theorem match_fold_table_prefix (table : Nat → Nat) (length start : Nat) (input : List Nat)
    (room : start + input.length ≤ length)
    (items : ∀ index, (bound : index < input.length) → input[index] = table (start + index + 1)) :
    input.foldl (matchByte table length) ⟨start, true⟩ = ⟨start + input.length, true⟩ := by
  induction input generalizing start with
  | nil => simp
  | cons byte rest ih =>
      have first : table (start + 1) = byte := by
        have head := items 0 (by simp)
        change byte = table (start + 0 + 1) at head
        simpa only [Nat.add_zero] using head.symm
      have bounded : start < length := by simp only [List.length_cons] at room; omega
      have advance : matchByte table length ⟨start, true⟩ byte = ⟨start + 1, true⟩ := by
        simp only [matchByte, ↓reduceIte, bounded, first, and_self]
      rw [List.foldl_cons, advance, ih (start + 1)]
      · simp only [List.length_cons, Nat.add_comm, Nat.add_left_comm]
      · simp only [List.length_cons] at room; omega
      · intro index bound
        have tail := items (index + 1) (by simpa only [List.length_cons] using Nat.add_lt_add_right bound 1)
        change rest[index] = table (start + (index + 1) + 1) at tail
        simpa only [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using tail

theorem match_fold_complete (table : Nat → Nat) (length : Nat) (input : List Nat)
    (size : input.length = length)
    (items : ∀ index, (bound : index < input.length) → input[index] = table (index + 1)) :
    input.foldl (matchByte table length) {} = ⟨length, true⟩ := by
  simpa only [Nat.zero_add, size] using match_fold_table_prefix table length 0 input
    (by omega) (by simpa only [Nat.zero_add] using items)

theorem comma_exact (tables : Native.Tables) (state : Core.State) (active : state.matcher.inTheory = true) :
    ExactEmits tables state (afterComma tables state) [44] := by
  apply ExactEmits.of_fold tables state _ [44] active
  change Core.matcher tables (settled state).matcher 44 = Core.matcher tables state.matcher 44
  rw [settled_matcher]

theorem field_comma_exact (tables : Native.Tables) (state : Core.State)
    (active : state.matcher.inTheory = true) :
    ExactEmits tables state (fieldComma tables state) [44] := comma_exact tables state active

theorem closed_array_exact (tables : Native.Tables) (state : Core.State)
    (active : state.matcher.inTheory = true) : ExactEmits tables state (closedArray tables state) [93] := by
  apply ExactEmits.of_fold tables state _ [93] active
  change Core.matcher tables (settled state).matcher 93 = Core.matcher tables state.matcher 93
  rw [settled_matcher]

end Silver.ImageModel.ScannerNative
