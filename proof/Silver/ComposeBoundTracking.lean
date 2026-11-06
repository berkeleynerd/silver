module

public import Silver.ComposeBindingBounds

@[expose] public section

namespace Silver.Compose
open StringObjectBounds

/-- Source intervals enclose actual Ada endpoints; lengths remain separate so
arbitrary inverted null-slice endpoints are never normalized. -/
structure ValueResult.ContainsBounds (result : ValueResult) (bounds : Bounds) : Prop where
  first : result.firstIndex.Contains bounds.first
  last : result.lastIndex.Contains bounds.last
  minimum : result.minimumLength ≤ bounds.length
  maximum : bounds.length ≤ result.staticLength

structure ExpressionState.ContainsBounds (state : ExpressionState) (bounds : Bounds) : Prop where
  first : state.firstIndex.Contains bounds.first
  last : state.lastIndex.Contains bounds.last
  minimum : state.minimumLength ≤ bounds.length
  maximum : bounds.length ≤ state.staticLength
  initialEmpty : state.operands = 0 → bounds.isNull = true

theorem ExpressionState.emptyBounds (position : Nat) :
    ({position := position} : ExpressionState).ContainsBounds (Bounds.canonical 0) := by
  constructor <;> simp [Integer.Interval.Contains, Integer.Interval.singleton,
    Bounds.canonical, Bounds.length, Bounds.isNull]

theorem concatenatedFirst_contains {state : ExpressionState} {atom : ValueResult}
    {left right : Bounds} (before : state.ContainsBounds left) (next : atom.ContainsBounds right) :
    (concatenatedFirst state atom).Contains (left.concatenate right).first := by
  unfold concatenatedFirst
  split
  · rename_i empty
    have null : left.isNull = true := by
      rcases empty with initial | zero
      · exact before.initialEmpty initial
      · exact (Bounds.null_iff_length_zero left).mpr (by have := before.maximum; omega)
    simpa [Bounds.concatenate, null] using next.first
  · split
    · rename_i nonempty
      have null : left.isNull = false := by
        have positive := before.minimum
        simp only [Bounds.isNull, decide_eq_false_iff_not, Bounds.length] at *
        omega
      simpa [Bounds.concatenate, null] using before.first
    · by_cases null : left.isNull = true
      · simpa [Bounds.concatenate, null] using Integer.Interval.join_right (left := state.firstIndex) next.first
      · simpa [Bounds.concatenate, null] using Integer.Interval.join_left (right := atom.firstIndex) before.first

theorem concatenatedLast_contains {state : ExpressionState} {atom : ValueResult}
    {left right : Bounds} (before : state.ContainsBounds left) (next : atom.ContainsBounds right)
    (fixedLeft : state.dynamicCount = 0) (fixedRight : atom.dynamicSeen = false)
    (accepted : (concatenatedLast state atom).isEmpty = false) :
    (concatenatedLast state atom).Contains (left.concatenate right).last := by
  have first := concatenatedFirst_contains before next
  have lengths := Bounds.concatenate_length left right
  have minimum := Nat.add_le_add before.minimum next.minimum
  have maximum := Nat.add_le_add before.maximum next.maximum
  rw [← lengths] at minimum maximum
  have interval : (left.concatenate right).isNull = false →
      (Integer.Interval.mk
        ((concatenatedFirst state atom).lower + ((state.minimumLength : Int) + atom.minimumLength) - 1)
        ((concatenatedFirst state atom).upper + ((state.staticLength : Int) + atom.staticLength) - 1)).Contains
        (left.concatenate right).last := by
    intro nonnull
    have exact := Bounds.nonnull_length (left.concatenate right) nonnull
    simp only [Integer.Interval.Contains] at first ⊢
    omega
  unfold concatenatedLast at accepted ⊢
  dsimp only at accepted ⊢
  simp only [fixedLeft, fixedRight, Bool.false_eq_true, ↓reduceIte,
    Int.ofNat_zero, Int.add_zero, Int.zero_mul] at accepted ⊢
  split at accepted
  · rename_i empty
    rw [ite_eq_left empty]
    have null : left.isNull = true := by
      rcases empty with initial | zero
      · exact before.initialEmpty initial
      · exact (Bounds.null_iff_length_zero left).mpr (by have := before.maximum; omega)
    simpa [Bounds.concatenate, null] using next.last
  · rename_i present
    rw [ite_eq_right present]
    split at accepted
    · simp [Integer.Interval.empty, Integer.Interval.isEmpty] at accepted
    · rename_i safe
      rw [ite_eq_right safe]
      split
      · by_cases null : (left.concatenate right).isNull = true
        · have leftNull : left.isNull = true := by
            have zero := (Bounds.null_iff_length_zero _).mp null
            exact (Bounds.null_iff_length_zero _).mpr (by omega)
          rw [Bounds.concatenate_null_left left right leftNull]
          exact Integer.Interval.join_right next.last
        · exact Integer.Interval.join_left (interval (Bool.eq_false_iff.mpr null))
      · rename_i positive
        apply interval
        apply Bool.eq_false_iff.mpr
        intro null
        have zero := (Bounds.null_iff_length_zero _).mp null
        omega

theorem concatenated_bounds {state : ExpressionState} {atom : ValueResult}
    {left right : Bounds} (before : state.ContainsBounds left) (next : atom.ContainsBounds right)
    (fixedLeft : state.dynamicCount = 0) (fixedRight : atom.dynamicSeen = false)
    (accepted : (concatenatedLast state atom).isEmpty = false)
    (positive : 0 < atom.operands) :
    ({state with
      minimumLength := state.minimumLength + atom.minimumLength,
      staticLength := state.staticLength + atom.staticLength,
      operands := state.operands + atom.operands,
      firstIndex := concatenatedFirst state atom,
      lastIndex := concatenatedLast state atom} : ExpressionState).ContainsBounds (left.concatenate right) := by
  exact ⟨concatenatedFirst_contains before next,
    concatenatedLast_contains before next fixedLeft fixedRight accepted,
    by simpa [Bounds.concatenate_length] using Nat.add_le_add before.minimum next.minimum,
    by simpa [Bounds.concatenate_length] using Nat.add_le_add before.maximum next.maximum,
    fun zero => by change state.operands + atom.operands = 0 at zero; omega⟩

end Silver.Compose
