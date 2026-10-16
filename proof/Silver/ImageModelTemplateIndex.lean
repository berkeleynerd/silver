module

public import Silver.ImageModelTemplateData

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Templates

theorem chunk_width (kind : Kind) :
    ∀ chunk ∈ chunkBytes kind, chunk.length = 128 := by
  cases kind <;> decide +kernel

theorem chunk_ascii (kind : Kind) :
    ∀ chunk ∈ chunkBytes kind, ∀ byte ∈ chunk, byte < 128 := by
  cases kind <;> decide +kernel

theorem content_lengths : kinds.map length = [5039, 5618, 8343, 1002, 92] := rfl

theorem uniform_chunk_length (rows : List (List Nat))
    (width : ∀ row ∈ rows, row.length = 128) :
    rows.flatten.length = rows.length * 128 := by
  induction rows with
  | nil => simp
  | cons row rest ih =>
      have rowWidth : row.length = 128 := width row (by simp)
      have restWidth : ∀ item ∈ rest, item.length = 128 := by
        intro item member
        exact width item (by simp [member])
      simp only [List.flatten_cons, List.length_append, List.length_cons,
        rowWidth, ih restWidth]
      omega

theorem content_length (kind : Kind) : (bytes kind).length = length kind := by
  unfold bytes
  rw [List.length_take, uniform_chunk_length (chunkBytes kind) (chunk_width kind)]
  apply Nat.min_eq_left
  cases kind <;> decide +kernel

theorem chunk_counts : kinds.map (fun kind => (chunkBytes kind).length) = [40, 44, 66, 8, 1] := rfl

/-- Uniform chunking is ordinary linear indexing; this argument is independent
of the concrete template bytes and avoids enumerating all content positions. -/
theorem uniform_chunk_lookup (rows : List (List Nat))
    (width : ∀ row ∈ rows, row.length = 128) (index : Nat) :
    (rows.flatten[index]?.getD 0) =
      ((rows[index / 128]?.getD [])[index % 128]?.getD 0) := by
  induction rows generalizing index with
  | nil => simp
  | cons row rest ih =>
      have rowWidth : row.length = 128 := width row (by simp)
      have restWidth : ∀ item ∈ rest, item.length = 128 := by
        intro item member
        exact width item (by simp [member])
      simp only [List.flatten_cons]
      by_cases small : index < 128
      · rw [List.getElem?_append_left (by omega)]
        simp only [Nat.div_eq_of_lt small, Nat.mod_eq_of_lt small,
          List.getElem?_cons_zero, Option.getD_some]
      · have large : 128 ≤ index := by omega
        have quotient : index / 128 = (index - 128) / 128 + 1 := by omega
        have remainder : index % 128 = (index - 128) % 128 := by omega
        rw [List.getElem?_append_right (by omega)]
        simpa only [rowWidth, quotient, remainder, List.getElem?_cons_succ] using
          ih restWidth (index - 128)

/-- Every exposed native byte is the corresponding unpadded content byte. -/
theorem byteAt_eq (kind : Kind) (position : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ length kind) :
    byteAt kind position = (bytes kind)[position - 1]?.getD 0 := by
  have indexBound : position - 1 < length kind := by omega
  unfold byteAt bytes
  rw [List.getElem?_take_of_lt indexBound]
  exact (uniform_chunk_lookup (chunkBytes kind) (chunk_width kind) (position - 1)).symm

theorem byteAt_bounds (kind : Kind) (position : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ length kind) :
    (position - 1) / 128 < (chunkBytes kind).length ∧ (position - 1) % 128 < 128 := by
  cases kind <;> simp only [length, chunkBytes, List.length_cons,
    List.length_nil] at * <;> omega

end Silver.ImageModel.Templates
