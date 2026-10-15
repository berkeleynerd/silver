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
  split at found
  · cases found; rfl
  · split at found
    · cases found; rfl
    · split at found
      · cases found; rfl
      · cases found

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
          have nonzero : nameAfter text (skip text position) ≠ 0 := by
            intro zero
            rename_i lookupGood
            have zeroLookup : lookup text names (skip text position) 0 = 0 := by
              unfold lookup
              cases names.length <;> simp [lookupFrom]
            simp only [zero, zeroLookup, true_or, not_true_eq_false] at lookupGood
          have identifier : Named.identifierEnd text (skip text position) ≠ 0 := by
            simpa only [nameAfter, show skip text position ≠ 0 by omega, ↓reduceIte] using nonzero
          have after := Named.identifierEnd_bounds text (skip text position) identifier
          simp only [nameAfter, show skip text position ≠ 0 by omega, ↓reduceIte]
          exact ⟨by omega, after.2⟩

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
                  · change (Option.bind _ _) = some value at found
                    simp only [Option.bind_eq_some_iff] at found
                    obtain ⟨right, rightFound, found⟩ := found
                    have rightBounds := ih (show skip text left.after + 1 ≤ text.length + 1 by omega) rightFound
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
