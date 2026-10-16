module

public import Init.Data.List.Lemmas
public import Init.Data.List.Range
public import Init.Omega

@[expose] public section
namespace Silver.ImageModel

/-- The producer's signed32 Why_Node_Id occupies the lower half of Why_Node_Set.
The trusted pinned consumer represents IDs as OCaml int on the supported64 hosts. -/
def originalIdMaximum : Nat := 1073741823
def insertedIdFirst : Nat := 1073741824
def insertedNodeCount : Nat := 23

theorem inserted_band_bounded :
    originalIdMaximum < insertedIdFirst ∧
    insertedIdFirst + insertedNodeCount - 1 ≤ 2147483647 := by decide +kernel

theorem inserted_id_fresh {original index : Nat}
    (bounded : original ≤ originalIdMaximum) (member : index < insertedNodeCount) :
    original < insertedIdFirst + index ∧ insertedIdFirst + index ≤ 2147483647 := by
  unfold originalIdMaximum insertedIdFirst insertedNodeCount at *
  omega

/-- The adapter emits its two fragments at validated original-byte offsets.
This definition retains every original byte, including whitespace and labels. -/
def splice (original first second : List α) (a b : Nat) : List α :=
  original.take a ++ first ++ (original.drop a).take (b - a) ++ second ++ original.drop b

/-- Removing exactly the two added spans reconstructs the input. -/
def eraseInsertions (refined : List α) (a b firstLength secondLength : Nat) : List α :=
  refined.take a ++ (refined.drop (a + firstLength)).take (b - a) ++
    refined.drop (b + firstLength + secondLength)

theorem input_segments (original : List α) (a b : Nat) (ordered : a ≤ b) :
    original.take a ++ (original.drop a).take (b - a) ++ original.drop b = original := by
  have dropped : original.drop b = (original.drop a).drop (b-a) := by
    rw [List.drop_drop]
    congr 1
    omega
  rw [dropped, List.append_assoc, List.take_append_drop, List.take_append_drop]

theorem splice_preserves (original first second : List α) (a b : Nat)
    (ordered : a ≤ b) : original.Sublist (splice original first second a b) := by
  have included := ((List.sublist_append_left (original.take a) first).append
    (List.sublist_append_left ((original.drop a).take (b-a)) second)).append
      (List.Sublist.refl (original.drop b))
  simpa only [splice, List.append_assoc, input_segments original a b ordered] using included

theorem erase_splice (original first second : List α) (a b : Nat)
    (ordered : a ≤ b) (bounded : b ≤ original.length) :
    eraseInsertions (splice original first second a b) a b first.length second.length = original := by
  have aBound : a ≤ original.length := Nat.le_trans ordered bounded
  have prefixLength : (original.take a).length = a := by simp [List.length_take, Nat.min_eq_left aBound]
  have middleLength : ((original.drop a).take (b-a)).length = b-a := by
    simp [List.length_take, List.length_drop, Nat.min_eq_left (by omega : b-a ≤ original.length-a)]
  have allEq : splice original first second a b =
      original.take a ++ (first ++ ((original.drop a).take (b-a) ++ (second ++ original.drop b))) := by
    simp only [splice, List.append_assoc]
  have takePrefix : (splice original first second a b).take a = original.take a := by
    rw [allEq]
    exact List.take_left' prefixLength
  have dropPrefix : (splice original first second a b).drop (a + first.length) =
      (original.drop a).take (b-a) ++ (second ++ original.drop b) := by
    have len : (original.take a ++ first).length = a + first.length := by simp only [List.length_append, prefixLength]
    have shape : splice original first second a b =
        (original.take a ++ first) ++ ((original.drop a).take (b-a) ++ (second ++ original.drop b)) := by
      simp only [splice, List.append_assoc]
    rw [shape]
    exact List.drop_left' len
  have dropAll : (splice original first second a b).drop (b + first.length + second.length) = original.drop b := by
    have len : (original.take a ++ first ++ (original.drop a).take (b-a) ++ second).length =
        b + first.length + second.length := by
      simp only [List.length_append, prefixLength, middleLength]
      omega
    unfold splice
    exact List.drop_left' len
  unfold eraseInsertions
  rw [takePrefix, dropPrefix, dropAll, List.take_left' middleLength]
  exact input_segments original a b ordered

end Silver.ImageModel
