module

public import Silver.ScalarArrayAttributeSyntax
public import Silver.ScalarArrayGrammarRecognition
public import Silver.ScalarExpressionRecognition

@[expose] public section

/-! Source productions for the full-table expression reader. The subscript
keeps the same visible type names and disables component reads. Attribute
prefixes and designators retain their source spans and declaration identity. -/
namespace Silver.ScalarExpression.ArrayGrammar

def OrdinaryAbsent (text : Source) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (position : Nat) : Prop :=
  ¬ ∃ value, AtomAt text names maskFirst maskAfter allowSign position value

private theorem ordinaryAbsent_iff {text names maskFirst maskAfter allowSign position}
    (bounded : position ≤ text.length + 1) : OrdinaryAbsent text names maskFirst maskAfter allowSign position ↔
      atom text position names maskFirst maskAfter allowSign = none := by
  constructor
  · intro absent
    cases parsed : atom text position names maskFirst maskAfter allowSign with
    | none => rfl
    | some value => exact False.elim (absent ⟨value, atom_sound bounded parsed⟩)
  · intro absent ⟨value, reading⟩
    rw [atom_complete bounded reading] at absent
    cases absent

inductive SourceAt (text : Source) (names : Environment) (arrays : ArrayBindings.Table)
    (maskFirst maskAfter : Nat) : ArrayReadMode → Bool → Nat → Parsed → Prop
  | ordinary {mode position allowSign value} :
      skip text position ≠ 0 → skip text position ≤ text.length → Cursor.byteAt text (skip text position) ≠ 40 →
      AtomAt text names maskFirst maskAfter allowSign (skip text position) value →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position value
  | shape {mode position allowSign} {query : ArrayAttributes.ParsedQuery} :
      skip text position ≠ 0 → skip text position ≤ text.length → Cursor.byteAt text (skip text position) ≠ 40 →
      OrdinaryAbsent text names maskFirst maskAfter allowSign (skip text position) →
      ArrayAttributes.At text names arrays position maskFirst maskAfter false query →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position
        ⟨query.after, .literal (query.query.bounds query.shape).lower⟩
  | indexed {mode position allowSign bytes after target opened closed index} :
      skip text position ≠ 0 → skip text position ≤ text.length → Cursor.byteAt text (skip text position) ≠ 40 →
      OrdinaryAbsent text names maskFirst maskAfter allowSign (skip text position) →
      ¬ Sign (Cursor.byteAt text (skip text position)) → NoIntegerAt text (skip text position) →
      Named.IdentifierAt text (skip text position) bytes after →
      lookup text names (skip text position) after = 0 →
      ¬ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter (skip text position) after = true) →
      ArrayBindings.lookup text arrays.items (skip text position) after = target → target ≠ 0 →
      (ArrayBindings.binding arrays.items target).isBoolean = false → mode ≠ .noElements →
      (mode = .mutableElements → (ArrayBindings.binding arrays.items target).mutable = true) →
      SymbolAt text after 40 opened → SourceAt text names arrays maskFirst maskAfter .noElements true opened index →
      SymbolAt text index.after 41 closed → skip text position < closed →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position
        ⟨closed, .indexed (ArrayBindings.binding arrays.items target).viewDescriptor index.expression⟩
  | signed {mode : ArrayReadMode} {position value finish closed : Nat} {allowSign : Bool} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      ScalarLiteral.IntegerAt text (skip text (inner text position + 1)) value finish →
      SymbolAt text finish 41 closed →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position
        ⟨closed, .literal (signedValue value (Cursor.byteAt text (inner text position) == 45))⟩
  | unary {mode : ArrayReadMode} {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      NoIntegerAt text (skip text (inner text position + 1)) →
      SourceAt text names arrays maskFirst maskAfter mode false (skip text (inner text position + 1)) value →
      SymbolAt text value.after 41 closed →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position
        ⟨closed, (unary value (Cursor.byteAt text (inner text position) == 45)).expression⟩
  | grouped {mode : ArrayReadMode} {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      SourceAt text names arrays maskFirst maskAfter mode true (inner text position) value →
      SymbolAt text value.after 41 closed →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position ⟨closed, .parenthesized value.expression⟩
  | binary {mode : ArrayReadMode} {position closed operatorEnd : Nat} {allowSign : Bool} {left right combined : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      SourceAt text names arrays maskFirst maskAfter mode true (inner text position) left →
      skip text left.after ≠ 0 → skip text left.after ≤ text.length →
      BinaryTokenAt text (skip text left.after) operatorEnd →
      SourceAt text names arrays maskFirst maskAfter mode false operatorEnd right →
      binary left right (lowercase (Cursor.byteAt text (skip text left.after))) = some combined →
      SymbolAt text combined.after 41 closed →
      SourceAt text names arrays maskFirst maskAfter mode allowSign position {combined with after := closed}

theorem parseFuel_source {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {mode : ArrayReadMode} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign mode = some value) :
    SourceAt text names arrays maskFirst maskAfter mode allowSign position value := by
  induction fuel generalizing position mode allowSign value with
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
          split at found
          · exact .ordinary (by omega) (by omega) notGroup (atom_sound first.2 found)
          · rename_i absent
            have ordinary := (ordinaryAbsent_iff first.2).mpr (Option.not_isSome_iff_eq_none.mp absent)
            split at found
            · unfold attributeAtom at found
              obtain ⟨query, queryRead, same⟩ := Option.bind_eq_some_iff.mp found
              cases same
              rw [ArrayAttributes.parse_skipped] at queryRead
              exact .shape (by omega) (by omega) notGroup ordinary (ArrayAttributes.at_iff.mpr queryRead)
            · split at found
              · cases found
              · rename_i allowed
                simp only [not_or] at allowed
                obtain ⟨modeGood, mutableGood, nameGood, targetGood, integerKind, scalar, plus, minus, number, unmasked⟩ := allowed
                split at found
                · cases found
                · rename_i opening
                  obtain ⟨index, indexRead, found⟩ := Option.bind_eq_some_iff.mp found
                  split at found
                  · cases found
                  · rename_i closed
                    cases found
                    have nonzero : skip text position ≠ 0 := by omega
                    have identifier : ∃ bytes, Named.IdentifierAt text (skip text position) bytes
                        (nameAfter text (skip text position)) := by
                      simp only [nameAfter, nonzero, ↓reduceIte] at nameGood ⊢
                      exact Named.identifierEnd_sound _ _ nameGood
                    obtain ⟨bytes, spelling⟩ := identifier
                    have namedBounds := Named.identifier_bounds spelling
                    have openBounds := symbol_bounds namedBounds.2.2.2 opening
                    exact .indexed nonzero (by omega) notGroup ordinary (fun sign => sign.elim plus minus)
                      ((noInteger_iff _ _ first.2).mpr (Classical.not_not.mp number)) spelling
                      (Classical.not_not.mp scalar) unmasked rfl targetGood (Bool.eq_false_iff.mpr integerKind)
                      modeGood (fun limited => Bool.of_not_eq_false (fun immutable => mutableGood ⟨limited, immutable⟩))
                      (symbolAt_iff.mpr ⟨rfl, opening⟩) (ih openBounds.2 indexRead)
                      (symbolAt_iff.mpr ⟨rfl, by omega⟩) (by omega)
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

theorem SourceAt.bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Table} {position maskFirst maskAfter : Nat}
    {mode : ArrayReadMode} {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (parsed : SourceAt text names arrays maskFirst maskAfter mode allowSign position value) :
    0 < position ∧ position < value.after ∧ value.after ≤ text.length + 1 := by
  induction parsed with
  | @ordinary mode position allowSign value nonzero within notGroup atom =>
      have first := skip_bounds text position bound
      have after := atom_bounds first.2 (atom_complete first.2 atom)
      have positive : position ≠ 0 := by
        intro zero
        simp [skip, zero] at nonzero
      exact ⟨by omega, by omega, after.2⟩
  | @shape mode position allowSign value nonzero _ _ _ query =>
      have after := ArrayAttributes.parse_bounds bound (ArrayAttributes.at_iff.mp query)
      have positive : position ≠ 0 := by intro zero; simp [skip, zero] at nonzero
      exact ⟨by omega, after⟩
  | @indexed mode position allowSign bytes after target opened closed index nonzero _ _ _ _ _ spelling _ _ _ _ _ _ _ opening child closing later ih =>
      have first := skip_bounds text position bound
      have namedBounds := Named.identifier_bounds spelling
      have openEq := symbolAt_iff.mp opening
      have opens := symbol_bounds namedBounds.2.2.2 (openEq.1.symm ▸ openEq.2)
      rw [openEq.1] at opens
      have subscript := ih opens.2
      have closeEq := symbolAt_iff.mp closing
      have closes := symbol_bounds subscript.2.2 (closeEq.1.symm ▸ closeEq.2)
      rw [closeEq.1] at closes
      have positive : position ≠ 0 := by intro zero; simp [skip, zero] at nonzero
      exact ⟨by omega, by dsimp only; omega, closes.2⟩
  | @signed mode position value finish closed allowSign opened _ number closing =>
      have start := opens_bounds bound opened
      have numberBounds := ScalarLiteral.integer_bounds number
      have next := skip_bounds text (inner text position + 1) (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds numberBounds.2.1 (show symbol text finish 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @unary mode position closed allowSign value opened _ _ _ closing ih =>
      have start := opens_bounds bound opened
      have next := skip_bounds text (inner text position + 1) (by omega)
      have child := ih next.2
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @grouped mode position closed allowSign value opened _ _ closing ih =>
      have start := opens_bounds bound opened
      have child := ih (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @binary mode position closed operatorEnd allowSign leftValue rightValue combinedValue opened _ _ _ within operator _ combined closing ihl ihr =>
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

theorem SourceAt.parse {text : Source} {names : Environment} {arrays : ArrayBindings.Table} {position maskFirst maskAfter : Nat}
    {mode : ArrayReadMode} {allowSign : Bool} {value : Parsed} (parsed : SourceAt text names arrays maskFirst maskAfter mode allowSign position value)
    (fuel : Nat) (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    parseFuel fuel text position names arrays maskFirst maskAfter allowSign mode = some value := by
  induction parsed generalizing fuel with
  | @ordinary mode position allowSign value nonzero within notGroup atom =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have first := skip_bounds text position bound
          rw [parseFuel]
          dsimp only
          simp only [nonzero, Nat.not_lt.mpr within, false_or, ↓reduceIte]
          rw [ite_eq_left notGroup]
          simp only [atom_complete first.2 atom, Option.isSome_some, ↓reduceIte]
  | @shape mode position allowSign query nonzero within notGroup absent reading =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have ordinary := (ordinaryAbsent_iff (skip_bounds text position bound).2).mp absent
          have parsed := ArrayAttributes.at_iff.mp reading
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, notGroup, ordinary, reading.apostrophe,
            attributeAtom, ArrayAttributes.parse_skipped, parsed]
  | @indexed mode position allowSign bytes after target opened closed index nonzero within notGroup absent notSign noNumber spelling scalar unmasked lookupTarget present integerKind enabled mutableGood opening child closing later ih =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have first := skip_bounds text position bound
          have ordinary := (ordinaryAbsent_iff first.2).mp absent
          have nameEq : nameAfter text (skip text position) = after := by
            simp only [nameAfter, nonzero, ↓reduceIte, Named.identifierEnd_complete spelling]
          have nameBounds := Named.identifier_bounds spelling
          have openEq := symbolAt_iff.mp opening
          have opens := symbol_bounds nameBounds.2.2.2 (openEq.1.symm ▸ openEq.2)
          rw [openEq.1] at opens
          have indexEq := ih fuel opens.2 (by omega)
          have closeEq := symbolAt_iff.mp closing
          have noTick : symbol text after 39 = 0 := by
            simp [symbol, opening.1, Nat.not_lt.mpr opening.2.1, opening.2.2.1]
          have permitted : ¬ (mode = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) := by
            rintro ⟨limited, immutable⟩
            rw [mutableGood limited] at immutable
            cases immutable
          have numberEq := (noInteger_iff _ _ first.2).mp noNumber
          unfold Sign at notSign
          simp [parseFuel, nonzero, Nat.not_lt.mpr within, notGroup, ordinary, nameEq, noTick,
            enabled, lookupTarget, permitted, present, integerKind, scalar, notSign, numberEq,
            unmasked, show after ≠ 0 by omega, openEq.1, openEq.2, indexEq, closeEq.1, Nat.not_le.mpr later]
  | @signed mode position value finish closed allowSign opened sign number closing =>
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
  | @unary mode position closed allowSign value opened sign noNumber child closing ih =>
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
            close, ScalarExpression.unary, closeEquation.1, closeEquation.2, inner]
  | @grouped mode position closed allowSign value opened notSign child closing ih =>
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
  | @binary mode position closed operatorEnd allowSign leftValue rightValue combinedValue opened notSign left nextNonzero nextWithin operator right combined closing ihl ihr =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have leftBounds := SourceAt.bounds (by omega) left
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

theorem At.source {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode}
    (reading : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode) :
    SourceAt text names arrays maskFirst maskAfter mode allowSign position ⟨result.after, expression⟩ :=
  parseFuel_source reading.positionBound reading.grammar

theorem SourceAt.canonical {text names arrays maskFirst maskAfter mode allowSign position value}
    (reading : SourceAt text names arrays maskFirst maskAfter mode allowSign position value)
    (bounded : position ≤ text.length + 1) :
    parseFuel (text.length + 1) text position names arrays maskFirst maskAfter allowSign mode = some value :=
  reading.parse _ bounded (by have positive := reading.bounds bounded; omega)

end Silver.ScalarExpression.ArrayGrammar
