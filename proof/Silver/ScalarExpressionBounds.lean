module

public import Silver.ScalarExpression

@[expose] public section

namespace Silver.ScalarExpression

theorem skip_bounds (text : Source) (position : Nat) (bound : position ≤ text.length + 1) :
    position ≤ skip text position ∧ skip text position ≤ text.length + 1 := by
  by_cases zero : position = 0
  · simp [skip, zero]
  · simpa only [skip, zero, ↓reduceIte] using
      Cursor.triviaPosition_bounds text position (by omega) bound

theorem symbol_bounds {text : Source} {position byte : Nat}
    (bound : position ≤ text.length + 1) (success : symbol text position byte ≠ 0) :
    position < symbol text position byte ∧ symbol text position byte ≤ text.length + 1 := by
  have skipped := skip_bounds text position bound
  unfold symbol at success ⊢
  dsimp only at success ⊢
  split at success
  · contradiction
  · rename_i good
    simp only [good, ↓reduceIte]
    omega

theorem literal_result {number : ScalarLiteral.Result} {negative : Bool} {value : Parsed}
    (found : literal number negative = some value) :
    number.after ≠ 0 ∧ value = ⟨number.after, .literal (signedValue number.value negative)⟩ := by
  simp only [literal] at found
  split at found
  · cases found
  · exact ⟨by assumption, (Option.some.inj found).symm⟩

theorem close_result {text : Source} {parsed : Option Parsed} {value : Parsed}
    (found : close text parsed = some value) :
    ∃ original, parsed = some original ∧ symbol text original.after 41 ≠ 0 ∧
      value = {original with after := symbol text original.after 41} := by
  cases parsed with
  | none => cases found
  | some original =>
      change (if symbol text original.after 41 = 0 then none
        else some {original with after := symbol text original.after 41}) = some value at found
      split at found
      · cases found
      · exact ⟨original, rfl, by assumption, (Option.some.inj found).symm⟩

theorem binary_result {left right value : Parsed} {operator : Nat}
    (found : binary left right operator = some value) : value.after = right.after := by
  unfold binary at found
  repeat' first | split at found | (cases found <;> rfl)

/-- A successful complete operator token strictly advances the source cursor. -/
theorem binaryAfter_bounds {text : Source} {position : Nat}
    (success : binaryAfter text position ≠ 0) :
    position < binaryAfter text position ∧ binaryAfter text position ≤ text.length + 1 := by
  unfold binaryAfter at success ⊢
  dsimp only at success ⊢
  split
  · simp_all
  · split
    · omega
    · split
      · split <;> simp_all <;> omega
      · split
        · rename_i named
          have nonzero : nameAfter text position ≠ 0 := named.1
          have pos : position ≠ 0 := by omega
          simpa only [nameAfter, pos, ↓reduceIte] using
            Named.identifierEnd_bounds text position (by simpa [nameAfter, pos] using nonzero)
        · simp_all

theorem binaryAfter_byte_bound {text : Source} {position : Nat}
    (success : binaryAfter text position ≠ 0) : Cursor.byteAt text position ≤ 255 := by
  unfold binaryAfter at success
  dsimp only at success
  split at success
  · contradiction
  · split at success
    · omega
    · split at success
      · omega
      · split at success
        · rename_i named
          rcases named.2 with mod | rem
          · simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at mod
            have first := mod.2 ⟨0, by decide⟩
            change lowercase (Cursor.byteAt text (position + 0)) = 109 at first
            simp only [Nat.add_zero, lowercase] at first
            split at first <;> omega
          · simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at rem
            have first := rem.2 ⟨0, by decide⟩
            change lowercase (Cursor.byteAt text (position + 0)) = 114 at first
            simp only [Nat.add_zero, lowercase] at first
            split at first <;> omega
        · contradiction

theorem lowercase_byte_bound {byte : Nat} (bound : byte ≤ 255) : lowercase byte ≤ 255 := by
  unfold lowercase
  split <;> omega

theorem atom_bounds {text : Source} {position maskFirst maskAfter : Nat} {names : Environment}
    {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (found : atom text position names maskFirst maskAfter allowSign = some value) :
    position < value.after ∧ value.after ≤ text.length + 1 := by
  have first := skip_bounds text position bound
  unfold atom at found
  dsimp only at found
  split at found
  · cases found
  · rename_i valid
    split at found
    · split at found
      · cases found
      · obtain ⟨numberGood, rfl⟩ := literal_result found
        have next := skip_bounds text (skip text position + 1) (by omega)
        have number := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound next.2 numberGood)
        dsimp only
        exact ⟨by omega, number.2.1⟩
    · split at found
      · obtain ⟨numberGood, rfl⟩ := literal_result found
        have number := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound first.2 numberGood)
        dsimp only
        exact ⟨by omega, number.2.1⟩
      · split at found
        · cases found
        · cases found
          have nonzero : (readReference text (skip text position)).after ≠ 0 := by
            intro zero
            rename_i lookupGood
            have invalid := lookup_invalid text names
              (readReference text (skip text position)).first
              (readReference text (skip text position)).after
              (readReference text (skip text position)).qualifierFirst
              (readReference text (skip text position)).qualifierAfter (by omega)
            exact lookupGood (Or.inl invalid)
          have after := QualifiedNames.read_success text (skip text position) first.2 nonzero
          exact ⟨Nat.lt_of_le_of_lt first.1 after.2.2.1, after.2.2.2⟩

theorem parseFuel_bounds {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names maskFirst maskAfter allowSign = some value) :
    position < value.after ∧ value.after ≤ text.length + 1 := by
  induction fuel generalizing position allowSign value with
  | zero => cases found
  | succ fuel ih =>
      have first := skip_bounds text position bound
      rw [parseFuel] at found
      dsimp only at found
      split at found
      · cases found
      · rename_i valid
        split at found
        · have atom := atom_bounds first.2 found
          exact ⟨by omega, atom.2⟩
        · have inner := skip_bounds text (skip text position + 1) (by omega)
          split at found
          · cases found
          · rename_i innerValid
            split at found
            · have next := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
              have originalBounds : position < original.after ∧ original.after ≤ text.length + 1 := by
                split at originalFound
                · obtain ⟨numberGood, rfl⟩ := literal_result originalFound
                  have number := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound next.2 numberGood)
                  dsimp only
                  exact ⟨by omega, number.2.1⟩
                · simp only [Option.map_eq_some_iff] at originalFound
                  obtain ⟨child, childFound, rfl⟩ := originalFound
                  have childBounds := ih next.2 childFound
                  exact ⟨by simpa only [unary] using Nat.lt_of_le_of_lt (by omega) childBounds.1,
                    childBounds.2⟩
              have closing := symbol_bounds originalBounds.2 closeGood
              dsimp only
              exact ⟨by omega, closing.2⟩
            · change (Option.bind _ _) = some value at found
              simp only [Option.bind_eq_some_iff] at found
              obtain ⟨left, leftFound, found⟩ := found
              have leftBounds := ih inner.2 leftFound
              have next := skip_bounds text left.after leftBounds.2
              split at found
              · cases found
              · rename_i nextValid
                split at found
                · cases found
                  dsimp only
                  exact ⟨by omega, by omega⟩
                · split at found
                  · cases found
                  · rename_i operator
                    have operatorBounds := binaryAfter_bounds operator
                    change (Option.bind _ _) = some value at found
                    simp only [Option.bind_eq_some_iff] at found
                    obtain ⟨right, rightFound, found⟩ := found
                    have rightBounds := ih operatorBounds.2 rightFound
                    obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
                    have same := binary_result originalFound
                    have closing := symbol_bounds (by omega : original.after ≤ text.length + 1) closeGood
                    dsimp only
                    exact ⟨by omega, closing.2⟩

theorem read_bounds {text : Source} {position maskFirst maskAfter : Nat} {names : Environment}
    {allowSign : Bool} (bound : position ≤ text.length + 1)
    (success : (read text position names maskFirst maskAfter allowSign).after ≠ 0) :
    position < (read text position names maskFirst maskAfter allowSign).after ∧
      (read text position names maskFirst maskAfter allowSign).after ≤ text.length + 1 ∧
      0 < (read text position names maskFirst maskAfter allowSign).operands ∧
      (read text position names maskFirst maskAfter allowSign).operands ≤ maxOperands := by
  obtain ⟨value, bounds, found, _, leafBound, _, result⟩ := summarize_success success
  have positions := parseFuel_bounds bound found
  simpa only [read, result] using
    And.intro positions.1 (And.intro positions.2 (And.intro (leaves_positive value.expression) leafBound))

end Silver.ScalarExpression
