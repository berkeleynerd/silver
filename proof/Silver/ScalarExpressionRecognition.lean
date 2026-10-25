module

public import Silver.ScalarExpressionGrammar

@[expose] public section

namespace Silver.ScalarExpression

theorem parseFuel_sound {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names maskFirst maskAfter allowSign = some value) :
    SyntaxAt text names maskFirst maskAfter allowSign position value := by
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
        · rename_i notGroup
          exact .atom (by omega) (by omega) notGroup (atom_sound first.2 found)
        · rename_i group
          have inside := skip_bounds text (skip text position + 1) (by omega)
          split at found
          · cases found
          · rename_i innerValid
            have opened : Opens text position := ⟨by omega, by omega, by omega, by unfold inner; omega⟩
            split at found
            · rename_i signed
              have next := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
              split at originalFound
              · obtain ⟨numberGood, rfl⟩ := literal_result originalFound
                exact .signed opened signed (ScalarLiteral.read_sound next.2 numberGood)
                  (symbolAt_iff.mpr ⟨rfl, closeGood⟩)
              · rename_i noNumber
                simp only [Option.map_eq_some_iff] at originalFound
                obtain ⟨child, childFound, rfl⟩ := originalFound
                exact .unary opened signed
                  ((noInteger_iff text _ next.2).mpr (by simpa using noNumber))
                  (ih next.2 childFound) (symbolAt_iff.mpr ⟨rfl, closeGood⟩)
            · rename_i notSign
              change (Option.bind _ _) = some value at found
              simp only [Option.bind_eq_some_iff] at found
              obtain ⟨left, leftFound, found⟩ := found
              have leftBounds := parseFuel_bounds inside.2 leftFound
              split at found
              · cases found
              · rename_i nextValid
                split at found
                · rename_i closing
                  cases found
                  exact .grouped opened notSign (ih inside.2 leftFound)
                    ⟨by omega, by omega, closing, rfl⟩
                · split at found
                  · cases found
                  · rename_i operator
                    have operatorBounds := binaryAfter_bounds operator
                    change (Option.bind _ _) = some value at found
                    simp only [Option.bind_eq_some_iff] at found
                    obtain ⟨right, rightFound, found⟩ := found
                    obtain ⟨combined, combinedFound, closeGood, rfl⟩ := close_result found
                    exact .binary opened notSign (ih inside.2 leftFound) (by omega) (by omega)
                      (binaryAfter_sound operator) (ih operatorBounds.2 rightFound) combinedFound
                      (symbolAt_iff.mpr ⟨rfl, closeGood⟩)

theorem opens_bounds {text : Source} {position : Nat}
    (bound : position ≤ text.length + 1) (opened : Opens text position) :
    0 < position ∧ position < inner text position ∧ inner text position ≤ text.length := by
  have first := skip_bounds text position bound
  have second := skip_bounds text (skip text position + 1) (by have h := opened.2.1; omega)
  have positive : position ≠ 0 := by
    intro zero
    have nozero := opened.1
    simp [skip, zero] at nozero
  exact ⟨by omega, by unfold inner; omega, opened.2.2.2⟩

theorem syntax_bounds {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (parsed : SyntaxAt text names maskFirst maskAfter allowSign position value) :
    0 < position ∧ position < value.after ∧ value.after ≤ text.length + 1 := by
  induction parsed with
  | @atom position allowSign value nonzero within notGroup atom =>
      have first := skip_bounds text position bound
      have after := atom_bounds first.2 (atom_complete first.2 atom)
      have positive : position ≠ 0 := by
        intro zero
        simp [skip, zero] at nonzero
      exact ⟨by omega, by omega, after.2⟩
  | @signed position value finish closed allowSign opened _ number closing =>
      have start := opens_bounds bound opened
      have numberBounds := ScalarLiteral.integer_bounds number
      have next := skip_bounds text (inner text position + 1) (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds numberBounds.2.1 (show symbol text finish 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @unary position closed allowSign value opened _ _ _ closing ih =>
      have start := opens_bounds bound opened
      have next := skip_bounds text (inner text position + 1) (by omega)
      have child := ih next.2
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @grouped position closed allowSign value opened _ _ closing ih =>
      have start := opens_bounds bound opened
      have child := ih (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @binary position closed operatorEnd allowSign leftValue rightValue combinedValue opened _ _ _ within operator _ combined closing ihl ihr =>
      have start := opens_bounds bound opened
      have left := ihl (by omega)
      have next := skip_bounds text leftValue.after left.2.2
      have operatorBounds := binaryToken_bounds operator
      have right := ihr (by omega)
      have same := binary_result combined
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds (by omega : combinedValue.after ≤ text.length + 1)
        (show symbol text combinedValue.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩

theorem parseFuel_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (parsed : SyntaxAt text names maskFirst maskAfter allowSign position value)
    (fuel : Nat) (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    parseFuel fuel text position names maskFirst maskAfter allowSign = some value := by
  induction parsed generalizing fuel with
  | @atom position allowSign value nonzero within notGroup atom =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have first := skip_bounds text position bound
          rw [parseFuel]
          dsimp only
          simp only [nonzero, Nat.not_lt.mpr within, false_or, ↓reduceIte]
          rw [ite_eq_left notGroup]
          exact atom_complete first.2 atom
  | @signed position value finish closed allowSign opened sign number closing =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have numberEquation := ScalarLiteral.read_complete number
          have numberPositive : _ ≠ 0 := Nat.ne_of_gt
            (Nat.lt_of_le_of_lt (Nat.zero_le _) (ScalarLiteral.integer_bounds number).1)
          have closeEquation := symbolAt_iff.mp closing
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at sign numberEquation innerWithin
          unfold Sign at sign
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, sign, numberEquation, numberPositive,
            literal, close, closeEquation.1, closeEquation.2, inner]
  | @unary position closed allowSign value opened sign noNumber child closing ih =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have next := skip_bounds text (inner text position + 1) (by omega)
          have childEquation := ih fuel next.2 (by omega)
          have noNumberEquation := (noInteger_iff text _ next.2).mp noNumber
          have closeEquation := symbolAt_iff.mp closing
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at sign childEquation noNumberEquation innerWithin
          unfold Sign at sign
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, sign, noNumberEquation, childEquation,
            close, unary, closeEquation.1, closeEquation.2, inner]
  | @grouped position closed allowSign value opened notSign child closing ih =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have childEquation := ih fuel (by omega) (by omega)
          rcases closing with ⟨closeNonzero, closeWithin, closeByte, rfl⟩
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at notSign childEquation innerWithin
          unfold Sign at notSign
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, notSign, childEquation,
            closeNonzero, Nat.not_lt.mpr closeWithin, closeByte]
  | @binary position closed operatorEnd allowSign leftValue rightValue combinedValue opened notSign left nextNonzero nextWithin operator right combined closing ihl ihr =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have leftBounds := syntax_bounds (by omega) left
          have next := skip_bounds text leftValue.after leftBounds.2.2
          have operatorBounds := binaryToken_bounds operator
          have operatorEquation := binaryAfter_complete operator
          have leftEquation := ihl fuel (by omega) (by omega)
          have rightEquation := ihr fuel (by omega) (by omega)
          have closeEquation := symbolAt_iff.mp closing
          have notClose := binaryToken_not_close operator
          have notInvalid : operatorEnd ≠ 0 := by omega
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at notSign leftEquation innerWithin
          unfold Sign at notSign
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, notSign, leftEquation, nextNonzero,
            Nat.not_lt.mpr nextWithin, notClose, notInvalid, operatorEquation, rightEquation,
            combined, close, closeEquation.1, closeEquation.2]

end Silver.ScalarExpression
