module

public import Silver.ScalarExpressionRecognition

@[expose] public section

/-! Independent source grammar for array-bearing scalar expressions. The
subscript production uses the existing scalar-only SyntaxAt grammar; the
outer grammar permits indexed atoms in all ordinary expression positions. -/
namespace Silver.ScalarExpression

inductive ArrayAtomAt (text : Source) (names : Environment) (arrays : ArrayBindings.Metadata)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (position : Nat) : Parsed → Prop
  | ordinary {value : Parsed} : AtomAt text names maskFirst maskAfter allowSign position value →
      ArrayAtomAt text names arrays maskFirst maskAfter allowSign position value
  | indexed {bytes : Source} {after target opened closed : Nat} {index : Parsed} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      ¬ Sign (Cursor.byteAt text (skip text position)) → NoIntegerAt text (skip text position) →
      Named.IdentifierAt text (skip text position) bytes after →
      lookup text names (skip text position) after = 0 →
      ArrayBindings.lookup text arrays (skip text position) after = target → target ≠ 0 →
      (ArrayBindings.binding arrays target).isBoolean = false →
      ¬ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter (skip text position) after = true) →
      SymbolAt text after 40 opened → SyntaxAt text names maskFirst maskAfter true opened index →
      SymbolAt text index.after 41 closed → position < closed →
      ArrayAtomAt text names arrays maskFirst maskAfter allowSign position
        ⟨closed, .indexed (ArrayBindings.binding arrays target).descriptor index.expression⟩

theorem arrayAtom_sound {fuel : Nat} {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : arrayAtom fuel text position names arrays maskFirst maskAfter allowSign = some value) :
    ArrayAtomAt text names arrays maskFirst maskAfter allowSign position value := by
  have first := skip_bounds text position bound
  unfold arrayAtom at found
  dsimp only at found
  split at found
  · exact .ordinary (atom_sound bound found)
  · split at found
    · cases found
    · rename_i good
      split at found
      · cases found
      · rename_i openGood
        change (Option.bind _ _) = some value at found
        simp only [Option.bind_eq_some_iff] at found
        obtain ⟨index, indexFound, found⟩ := found
        split at found
        · cases found
        · rename_i closeGood
          cases found
          have nonzero : skip text position ≠ 0 := by omega
          have nameEquation : nameAfter text (skip text position) =
              Named.identifierEnd text (skip text position) := by simp [nameAfter, nonzero]
          have nameGood : Named.identifierEnd text (skip text position) ≠ 0 := by
            rw [← nameEquation]
            omega
          obtain ⟨bytes, named⟩ := Named.identifierEnd_sound text (skip text position) nameGood
          have nameBounds := Named.identifierEnd_bounds text (skip text position) nameGood
          have openBounds := symbol_bounds nameBounds.2
            (show symbol text (Named.identifierEnd text (skip text position)) 40 ≠ 0 by
              rw [← nameEquation]; exact openGood)
          have subscript := parseFuel_sound (by simpa only [← nameEquation] using openBounds.2) indexFound
          have unmasked : ¬ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter
              (skip text position) (nameAfter text (skip text position)) = true) := by
            intro masked
            apply good
            exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr masked))))))))
          have integerKind : (ArrayBindings.binding arrays
              (ArrayBindings.lookup text arrays (skip text position) (nameAfter text (skip text position)))).isBoolean = false := by
            apply Bool.eq_false_iff.mpr
            intro kind
            apply good
            simp only [kind, true_or, or_true]
          refine ArrayAtomAt.indexed (bytes := bytes) nonzero (by omega) (by unfold Sign; omega)
            ((noInteger_iff text _ first.2).mpr (by omega)) ?_ (by omega) rfl (by omega) integerKind unmasked
            (symbolAt_iff.mpr ⟨rfl, openGood⟩) subscript
            (symbolAt_iff.mpr ⟨rfl, by omega⟩) (by omega)
          simpa only [← nameEquation] using named

theorem arrayAtom_syntax_bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (parsed : ArrayAtomAt text names arrays maskFirst maskAfter allowSign position value) :
    position < value.after ∧ value.after ≤ text.length + 1 := by
  cases parsed with
  | ordinary atom => exact atom_bounds bound (atom_complete bound atom)
  | indexed nonzero within notSign noNumber named noScalar target targetGood integerKind unmasked opening index closing later =>
      have nameBounds := Named.identifier_bounds named
      have openEquation := symbolAt_iff.mp opening
      have openBounds := symbol_bounds nameBounds.2.2.2
        (show _ ≠ 0 by rw [openEquation.1]; exact openEquation.2)
      have indexBounds := syntax_bounds (by rw [← openEquation.1]; exact openBounds.2) index
      have closeEquation := symbolAt_iff.mp closing
      have closeBounds := symbol_bounds indexBounds.2.2
        (show _ ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      exact ⟨later, by simpa only [closeEquation.1] using closeBounds.2⟩

theorem arrayAtom_bounds {fuel : Nat} {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : arrayAtom fuel text position names arrays maskFirst maskAfter allowSign = some value) :
    position < value.after ∧ value.after ≤ text.length + 1 :=
  arrayAtom_syntax_bounds bound (arrayAtom_sound bound found)

theorem arrayAtom_complete {fuel : Nat} {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel + 1)
    (parsed : ArrayAtomAt text names arrays maskFirst maskAfter allowSign position value) :
    arrayAtom fuel text position names arrays maskFirst maskAfter allowSign = some value := by
  cases parsed with
  | ordinary parsed => simp only [arrayAtom, atom_complete bound parsed, Option.isSome_some, ↓reduceIte]
  | @indexed bytes after target opened closed index nonzero within notSign noNumber named noScalar targetEq targetGood integerKind unmasked opening subscript closing later =>
      have first := skip_bounds text position bound
      have numberEquation := (noInteger_iff text _ first.2).mp noNumber
      have nameEquation := Named.identifierEnd_complete named
      have nameBounds := Named.identifier_bounds named
      have openEquation := symbolAt_iff.mp opening
      have openBounds := symbol_bounds nameBounds.2.2.2
        (show _ ≠ 0 by rw [openEquation.1]; exact openEquation.2)
      rw [openEquation.1] at openBounds
      have indexEquation := parseFuel_complete subscript fuel openBounds.2 (by omega)
      have closeEquation := symbolAt_iff.mp closing
      unfold Sign at notSign
      have ordinary : atom text position names maskFirst maskAfter allowSign = none := by
        have reference := reference_before_symbol nonzero named opening (by decide : (40 : Nat) ≠ 46)
        simp [atom, nonzero, Nat.not_lt.mpr within, notSign, numberEquation, reference, noScalar]
      simp [arrayAtom, ordinary, nonzero, Nat.not_lt.mpr within, nameAfter, nameEquation,
        show after ≠ 0 by omega, targetEq, targetGood, integerKind, noScalar, notSign, numberEquation, unmasked,
        openEquation.1, openEquation.2, indexEquation, closeEquation.1, Nat.not_le.mpr later]

inductive ArraysSyntaxAt (text : Source) (names : Environment) (arrays : ArrayBindings.Metadata) (maskFirst maskAfter : Nat) :
    Bool → Nat → Parsed → Prop
  | atom {position : Nat} {allowSign : Bool} {value : Parsed} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      Cursor.byteAt text (skip text position) ≠ 40 →
      ArrayAtomAt text names arrays maskFirst maskAfter allowSign (skip text position) value →
      ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value
  | signed {position value finish closed : Nat} {allowSign : Bool} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      ScalarLiteral.IntegerAt text (skip text (inner text position + 1)) value finish →
      SymbolAt text finish 41 closed →
      ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position
        ⟨closed, .literal (signedValue value (Cursor.byteAt text (inner text position) == 45))⟩
  | unary {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      NoIntegerAt text (skip text (inner text position + 1)) →
      ArraysSyntaxAt text names arrays maskFirst maskAfter false (skip text (inner text position + 1)) value →
      SymbolAt text value.after 41 closed →
      ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position
        ⟨closed, (unary value (Cursor.byteAt text (inner text position) == 45)).expression⟩
  | grouped {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      ArraysSyntaxAt text names arrays maskFirst maskAfter true (inner text position) value →
      SymbolAt text value.after 41 closed →
      ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position ⟨closed, .parenthesized value.expression⟩
  | binary {position closed operatorEnd : Nat} {allowSign : Bool} {left right combined : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      ArraysSyntaxAt text names arrays maskFirst maskAfter true (inner text position) left →
      skip text left.after ≠ 0 → skip text left.after ≤ text.length →
      BinaryTokenAt text (skip text left.after) operatorEnd →
      ArraysSyntaxAt text names arrays maskFirst maskAfter false operatorEnd right →
      binary left right (lowercase (Cursor.byteAt text (skip text left.after))) = some combined →
      SymbolAt text combined.after 41 closed →
      ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position {combined with after := closed}

end Silver.ScalarExpression
