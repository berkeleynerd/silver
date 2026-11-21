module

public import Silver.ScalarExpressionNativeTableAtoms

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option linter.unusedSimpArgs false

theorem tableAtomStep_dispatch (recurse : TableReader) (text : Source) (position : Nat)
    (names : Environment) (maskFirst maskAfter : Nat) (allowSign : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (arrayReads : ArrayReadMode) :
    tableAtomStep (@recurse) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      if (atom text position names maskFirst maskAfter allowSign).isSome then
        atomResult text position names maskFirst maskAfter allowSign
      else
        let first := skip text position
        let after := nameAfter text first
        let target := ArrayBindings.lookup text arrays.items first after
        if first = 0 ∨ first > text.length ∨ after = 0 ∨
            lookup text names first after ≠ 0 ∨
            Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 ∨
            (ScalarLiteral.read text first).after ≠ 0 ∨
            (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true) then invalid
        else if symbol text after 39 ≠ 0 then
          ArrayAttributes.read text position names arrays maskFirst maskAfter false
        else if target = 0 ∨ arrayReads = .noElements ∨
            (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) ∨
            (ArrayBindings.binding arrays.items target).isBoolean = true then invalid
        else tableArrayAtomStep (@recurse) text after names maskFirst maskAfter target arrays initials elaborating := by
  unfold tableAtomStep atom atomResult
  dsimp only
  by_cases bad : skip text position = 0 ∨ text.length < skip text position
  · simp only [bad, ↓reduceIte, Option.isSome_none, Bool.false_eq_true]
    split <;> (try rfl)
    omega
  · simp only [bad, ↓reduceIte]
    by_cases sign : Cursor.byteAt text (skip text position) = 43 ∨ Cursor.byteAt text (skip text position) = 45
    · simp only [sign, ↓reduceIte]
      cases allowSign <;> simp only [Bool.not_false, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
      · simp only [Option.isSome_none, Bool.false_eq_true, ↓reduceIte]
        split <;> (try rfl)
        omega
      · by_cases absent : (ScalarLiteral.read text (skip text (skip text position + 1))).after = 0
        · rcases sign with sign | sign <;> simp [literal, literalResult, absent, sign]
        · simp only [literal, absent, ↓reduceIte, Option.isSome_some]
    · simp only [sign, ↓reduceIte]
      by_cases number : (ScalarLiteral.read text (skip text position)).after ≠ 0
      · simp [number, literal]
      · simp only [number, ↓reduceIte]
        by_cases noName : nameAfter text (skip text position) = 0
        · simp [noName, lookup_after_zero]
        · simp only [noName, ↓reduceIte]
          by_cases masked : maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter
              (skip text position) (nameAfter text (skip text position)) = true
          · simp [masked]
          · simp only [masked, ↓reduceIte, or_false]
            by_cases noScalar : lookup text names (skip text position) (nameAfter text (skip text position)) = 0
            · simp only [noScalar, true_or, ↓reduceIte, Option.isSome_none, Bool.false_eq_true,
                ne_eq, not_true_eq_false, or_false]
              have a : skip text position ≠ 0 := by omega
              have b : ¬ text.length < skip text position := by omega
              have c : Cursor.byteAt text (skip text position) ≠ 43 := by omega
              have d : Cursor.byteAt text (skip text position) ≠ 45 := by omega
              simp only [a, b, c, d, noName, number, masked, false_or, ↓reduceIte]
              split
              · rfl
              · by_cases boolean : (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items
                    (skip text position) (nameAfter text (skip text position)))).isBoolean = true
                · simp [boolean, tableArrayAtomStep]
                · simp [boolean, or_assoc]
            · simp [noScalar]

/-- The atom branch factored from `ArrayGrammar.parseFuel`. This definition is
used only to state correspondence, not as an additional admission predicate. -/
def tableAtomSyntax (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (allowSign : Bool)
    (arrayReads : ArrayReadMode) : Option Parsed :=
  let ordinary := atom text position names maskFirst maskAfter allowSign
  if ordinary.isSome then ordinary else
    let after := nameAfter text position
    if symbol text after 39 ≠ 0 then
      ArrayGrammar.attributeAtom text position names arrays maskFirst maskAfter
    else
      let target := ArrayBindings.lookup text arrays.items position after
      if arrayReads = .noElements ∨
          (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) ∨
          after = 0 ∨ target = 0 ∨
          (ArrayBindings.binding arrays.items target).isBoolean = true ∨
          lookup text names position after ≠ 0 ∨
          Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
          (ScalarLiteral.read text position).after ≠ 0 ∨
          (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter position after = true) then none
      else
        let opened := symbol text after 40
        if opened = 0 then none else do
          let index ← ArrayGrammar.parseFuel fuel text opened names arrays maskFirst maskAfter true .noElements
          let closed := symbol text index.after 41
          if closed ≤ position then none
          else some ⟨closed, .indexed (ArrayBindings.binding arrays.items target).viewDescriptor index.expression⟩

theorem tableAtomStep_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    (metadata : ArrayBindings.ValidTable text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials)
    (fuel position maskFirst maskAfter : Nat) (allowSign elaborating : Bool) (arrayReads : ArrayReadMode)
    (positive : 0 < position) (within : position ≤ text.length) (fixed : skip text position = position)
    (recurse : TableReader)
    (child : ∀ next, position < next → next ≤ text.length + 1 →
      recurse text next names maskFirst maskAfter true arrays [] false .noElements =
        ArrayGrammar.summarize names arrays [] false
          (ArrayGrammar.parseFuel fuel text next names arrays maskFirst maskAfter true .noElements)) :
    tableAtomStep (@recurse) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.summarize names arrays initials elaborating
        (tableAtomSyntax fuel text position names arrays maskFirst maskAfter allowSign arrayReads) := by
  rw [tableAtomStep_dispatch]
  unfold tableAtomSyntax
  dsimp only
  split
  · rename_i ordinary
    rw [atom_correspondence valid]
    cases parsed : atom text position names maskFirst maskAfter allowSign with
    | none => simp only [parsed, Option.isSome_none, Bool.false_eq_true] at ordinary
    | some value =>
        exact (summarizeTable_readsOnly arrays initials elaborating valid.1
          (atom_readsOnly (atom_sound (by omega) parsed))).symm
  · rw [fixed]
    have nonzero : position ≠ 0 := by omega
    have notPast : ¬ position > text.length := by omega
    simp only [nonzero, notPast, false_or]
    by_cases queryPresent : symbol text (nameAfter text position) 39 ≠ 0
    · have named : nameAfter text position ≠ 0 := by
        intro absent
        simp [absent, symbol, skip] at queryPresent
      have notSign : ¬ (Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45) := by
        intro sign
        exact named (table_nameAfter_sign_zero sign)
      have notNumber : (ScalarLiteral.read text position).after = 0 := by
        by_cases number : (ScalarLiteral.read text position).after = 0
        · exact number
        · exact False.elim (named (table_nameAfter_integer_zero (by omega) number))
      have noPlus : Cursor.byteAt text position ≠ 43 := fun same => notSign (Or.inl same)
      have noMinus : Cursor.byteAt text position ≠ 45 := fun same => notSign (Or.inr same)
      simp only [named, noPlus, noMinus, notNumber, ne_eq, not_true_eq_false, false_or, or_false,
        queryPresent, ↓reduceIte]
      by_cases rejected : lookup text names position (nameAfter text position) ≠ 0 ∨
          (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter position (nameAfter text position) = true)
      · simp only [rejected, ↓reduceIte]
        simp [ArrayGrammar.attributeAtom, ArrayAttributes.parse, fixed, rejected, ArrayGrammar.summarize]
      · simp only [rejected, ↓reduceIte]
        exact attribute_table_correspondence metadata initials elaborating position maskFirst maskAfter (by omega)
    · simp only [queryPresent, ↓reduceIte]
      by_cases rejected : nameAfter text position = 0 ∨
          lookup text names position (nameAfter text position) ≠ 0 ∨
          Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
          (ScalarLiteral.read text position).after ≠ 0 ∨
          (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter position (nameAfter text position) = true)
      · simp only [rejected, ↓reduceIte]
        have blocked : arrayReads = .noElements ∨
            (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items
              (ArrayBindings.lookup text arrays.items position (nameAfter text position))).mutable = false) ∨
            nameAfter text position = 0 ∨ ArrayBindings.lookup text arrays.items position (nameAfter text position) = 0 ∨
            (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items position (nameAfter text position))).isBoolean = true ∨
            lookup text names position (nameAfter text position) ≠ 0 ∨
            Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
            (ScalarLiteral.read text position).after ≠ 0 ∨
            (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter position (nameAfter text position) = true) := by
          rcases rejected with h | h | h | h | h | h <;> simp [h]
        simp only [blocked, ↓reduceIte, ArrayGrammar.summarize]
      · simp only [rejected, ↓reduceIte]
        have guardEq : (arrayReads = .noElements ∨
            (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items
              (ArrayBindings.lookup text arrays.items position (nameAfter text position))).mutable = false) ∨
            nameAfter text position = 0 ∨ ArrayBindings.lookup text arrays.items position (nameAfter text position) = 0 ∨
            (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items position (nameAfter text position))).isBoolean = true ∨
            lookup text names position (nameAfter text position) ≠ 0 ∨
            Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
            (ScalarLiteral.read text position).after ≠ 0 ∨
            (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter position (nameAfter text position) = true)) =
          (ArrayBindings.lookup text arrays.items position (nameAfter text position) = 0 ∨ arrayReads = .noElements ∨
            (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items
              (ArrayBindings.lookup text arrays.items position (nameAfter text position))).mutable = false) ∨
            (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items position (nameAfter text position))).isBoolean = true) := by
          apply propext
          constructor
          · intro blocked
            rcases blocked with h | h | h | h | h | h | h | h | h | h
            all_goals first | exact Or.inl h | exact Or.inr (Or.inl h) | exact Or.inr (Or.inr (Or.inl h)) | exact Or.inr (Or.inr (Or.inr h)) | exact False.elim (rejected (by simp [h]))
          · intro blocked
            rcases blocked with h | h | h | h <;> simp [h]
        simp only [guardEq]
        split
        · rfl
        · rename_i allowed
          have targetPositive : 0 < ArrayBindings.lookup text arrays.items position (nameAfter text position) := by omega
          have targetBound := ArrayBindings.lookup_bound text arrays.items position (nameAfter text position)
          have namedBounds := ArrayAttributes.nameAfter_bounds (show nameAfter text position ≠ 0 by omega)
          have member := ArrayBindings.binding_mem targetPositive targetBound
          have integerKind : (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items position
              (nameAfter text position))).isBoolean = false := by
            cases boolean : (ArrayBindings.binding arrays.items (ArrayBindings.lookup text arrays.items position
              (nameAfter text position))).isBoolean <;> simp_all
          apply tableArrayAtomStep_correspondence valid metadata initialsValid member integerKind
            fuel position (nameAfter text position) maskFirst maskAfter elaborating
            (by omega) namedBounds.2 (@recurse)
          intro next advanced nextBound
          exact child next (by omega) nextBound

end Silver.ScalarExpression.Native
