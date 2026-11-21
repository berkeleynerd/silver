module

public import Silver.ScalarExpressionNativeTableRecursion
public import Silver.ScalarExpressionNativeArrayRecursion

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option linter.unusedSimpArgs false

theorem tableReadStep_congr {text : Source} {names : Environment}
    (left right : TableReader) (position maskFirst maskAfter : Nat) (allowSign : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (arrayReads : ArrayReadMode) (bound : position ≤ text.length + 1)
    (same : ∀ next sign, next ≤ text.length + 1 →
      left text next names maskFirst maskAfter sign arrays initials elaborating arrayReads =
        right text next names maskFirst maskAfter sign arrays initials elaborating arrayReads)
    (indexSame : ∀ next, next ≤ text.length + 1 →
      left text next names maskFirst maskAfter true arrays [] false .noElements =
        right text next names maskFirst maskAfter true arrays [] false .noElements) :
    tableReadStep (@left) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      tableReadStep (@right) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
  have firstBounds := skip_bounds text position bound
  simp only [tableReadStep]
  split
  · rfl
  · rename_i validFirst
    split
    · simp only [tableGroupStep]
      have innerBounds := skip_bounds text (skip text position + 1) (by omega)
      split
      · rfl
      · rename_i validInner
        split
        · simp only [tableUnaryStep, unaryStep]
          have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
          rw [same _ false nextBounds.2]
        · rw [same _ true innerBounds.2]
          simp only [tableCompoundStep, compoundStep]
          split
          · rfl
          · split
            · rfl
            · split
              · rfl
              · rename_i supported
                rw [same _ false (binaryAfter_bounds supported).2]
    · simp only [tableAtomStep]
      repeat' first | rfl | split
      simp only [tableArrayAtomStep]
      split
      · rfl
      · rename_i opening
        rw [indexSame _ (symbol_bounds (nameAfter_cursor_bound text _) (not_or.mp opening).1).2]

theorem table_read_step {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    (metadata : ArrayBindings.ValidTable text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (position maskFirst maskAfter : Nat) (allowSign : Bool) (arrayReads : ArrayReadMode)
    (bound : position ≤ text.length + 1) :
    tableReadStep (@tableReader) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads := by
  have equation := tableReadFuel_large valid metadata initialsValid elaborating
    (text.length + 2) position maskFirst maskAfter allowSign arrayReads bound (by omega)
  rw [show text.length + 2 = (text.length + 1) + 1 from rfl, tableReadFuel] at equation
  have same := tableReadStep_congr (text := text) (names := names) (@tableReadFuel (text.length + 1))
    (@tableReader) position maskFirst maskAfter allowSign arrays initials elaborating arrayReads bound
    (by
      intro next sign nextBound
      exact tableReadFuel_large valid metadata initialsValid elaborating
        _ next maskFirst maskAfter sign arrayReads nextBound (by omega))
    (by
      intro next nextBound
      exact tableReadFuel_large valid metadata (by simp [ArrayBindings.ValidInitials]) false
        _ next maskFirst maskAfter true .noElements nextBound (by omega))
  exact same.symm.trans equation

theorem table_parse_empty (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrayReads : ArrayReadMode) :
    ArrayGrammar.parseFuel fuel text position names {} maskFirst maskAfter allowSign arrayReads =
      parseFuel fuel text position names maskFirst maskAfter allowSign := by
  induction fuel generalizing position allowSign with
  | zero => rfl
  | succ fuel ih =>
      rw [ArrayGrammar.parseFuel, parseFuel]
      dsimp only
      split
      · rfl
      · split
        · cases ordinary : atom text (skip text position) names maskFirst maskAfter allowSign with
          | none =>
              simp [ordinary, ArrayGrammar.attributeAtom, ArrayAttributes.parse, ArrayAttributes.selectedShape,
                ArrayBindings.lookup, ArrayBindings.lookupFrom, ArrayBindings.lookupType, ArrayBindings.lookupTypeFrom]
          | some value => simp [ordinary]
        · simp only [ih]

theorem table_read_empty (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (initials : ArrayBindings.Initials)
    (elaborating : Bool) (arrayReads : ArrayReadMode) :
    ArrayGrammar.read text position names {} maskFirst maskAfter allowSign initials elaborating arrayReads =
      read text position names maskFirst maskAfter allowSign := by
  unfold ArrayGrammar.read read
  rw [table_parse_empty]
  cases parseFuel (text.length + 1) text position names maskFirst maskAfter allowSign <;>
    rfl

end Silver.ScalarExpression.Native
