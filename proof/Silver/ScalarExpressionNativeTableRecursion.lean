module

public import Silver.ScalarExpressionNativeTableDispatch
public import Silver.ScalarExpressionNativeTypes
public import Silver.ScalarArrayGrammarSyntax

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000
set_option linter.unusedSimpArgs false

def tableReadFuel : Nat → TableReader
  | 0 => fun _ _ _ _ _ _ _ _ _ _ => invalid
  | fuel + 1 => fun text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =>
      tableReadStep (@tableReadFuel fuel) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads

theorem tableReadFuel_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    (metadata : ArrayBindings.ValidTable text arrays)
    {initials : ArrayBindings.Initials} (initialsValid : ArrayBindings.ValidInitials initials)
    (elaborating : Bool) (fuel position maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrayReads : ArrayReadMode) (bound : position ≤ text.length + 1) :
    tableReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.summarize names arrays initials elaborating (ArrayGrammar.parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads) := by
  induction fuel generalizing position allowSign arrayReads initials elaborating with
  | zero => rfl
  | succ fuel ih =>
      have firstBounds := skip_bounds text position bound
      rw [tableReadFuel]
      simp only [tableReadStep, ArrayGrammar.parseFuel]
      split
      · rfl
      · rename_i validFirst
        by_cases group : Cursor.byteAt text (skip text position) = 40
        · simp only [group, ne_eq, not_true_eq_false, ↓reduceIte, tableGroupStep]
          have innerBounds := skip_bounds text (skip text position + 1) (by omega)
          split
          · rfl
          · rename_i validInner
            split
            · simp only [tableUnaryStep, unaryStep]
              have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              split
              · rw [literal_table_correspondence arrays initials elaborating, close_table_correspondence arrays initials elaborating]
              · rw [ih initialsValid elaborating _ _ arrayReads nextBounds.2, unary_table_correspondence arrays initials elaborating, close_table_correspondence arrays initials elaborating]
            · simp only [tableCompoundStep, compoundStep, ih initialsValid elaborating _ _ arrayReads innerBounds.2]
              cases leftFound : ArrayGrammar.parseFuel fuel text (skip text (skip text position + 1)) names arrays
                  maskFirst maskAfter true arrayReads with
              | none => simp [ArrayGrammar.summarize, invalid, skip]
              | some left =>
                  have leftBounds := ArrayGrammar.parseFuel_bounds innerBounds.2 leftFound
                  have nextBounds := skip_bounds text left.after leftBounds.2
                  by_cases rejected : (ArrayGrammar.summarize names arrays initials elaborating (some left)).after = 0
                  · rw [summarizeTable_zero arrays initials elaborating rejected]
                    simp only [show skip text invalid.after = 0 from by simp [skip, invalid],
                      ↓reduceIte, true_or]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_table_correspondence arrays initials elaborating names left _ (by omega) (by omega), rejected]
                        rfl
                      · split
                        · rfl
                        · rename_i supported
                          have operatorBounds := binaryAfter_bounds supported
                          cases rightFound : ArrayGrammar.parseFuel fuel text (binaryAfter text (skip text left.after)) names arrays
                              maskFirst maskAfter false arrayReads with
                          | none => rfl
                          | some right =>
                              have rightBounds := ArrayGrammar.parseFuel_bounds (by omega) rightFound
                              change invalid = ArrayGrammar.summarize names arrays initials elaborating (close text (binary left right _))
                              rw [← close_table_correspondence arrays initials elaborating, ← binary_table_correspondence arrays initials elaborating names left right _
                                (by omega) (by omega), summarizeTable_zero arrays initials elaborating rejected,
                                binary_invalid_left, close_invalid]
                  · obtain ⟨original, bounds, same, originalPositive, leavesBound, inferred, summarized⟩ :=
                      ArrayGrammar.summarize_success rejected
                    have originalEq : original = left := by simpa using same.symm
                    subst original
                    have summarizedAfter : (ArrayGrammar.summarize names arrays initials elaborating (some left)).after = left.after := by rw [summarized]
                    rw [summarizedAfter]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_table_correspondence arrays initials elaborating names left _ (by omega) (by omega)]
                        simp only [rejected, ↓reduceIte]
                      · split
                        · rfl
                        · rename_i supported
                          have operatorBounds := binaryAfter_bounds supported
                          rw [ih initialsValid elaborating _ _ arrayReads operatorBounds.2]
                          cases rightFound : ArrayGrammar.parseFuel fuel text (binaryAfter text (skip text left.after)) names arrays
                              maskFirst maskAfter false arrayReads with
                          | none => simp [ArrayGrammar.summarize, binary_invalid_right, close_invalid]
                          | some right =>
                              have rightBounds := ArrayGrammar.parseFuel_bounds (by omega) rightFound
                              change closeResult text (binaryResult (ArrayGrammar.summarize names arrays initials elaborating (some left))
                                (ArrayGrammar.summarize names arrays initials elaborating (some right)) _) = _
                              rw [binary_table_correspondence arrays initials elaborating names left right _ (by omega) (by omega),
                                close_table_correspondence arrays initials elaborating]
        · simp only [group, ne_eq, not_false_eq_true, ↓reduceIte]
          change tableAtomStep (@tableReadFuel fuel) text (skip text position) names maskFirst maskAfter
              allowSign arrays initials elaborating arrayReads =
            ArrayGrammar.summarize names arrays initials elaborating
              (tableAtomSyntax fuel text (skip text position) names arrays maskFirst maskAfter allowSign arrayReads)
          apply tableAtomStep_correspondence valid metadata initialsValid fuel (skip text position)
            maskFirst maskAfter allowSign elaborating arrayReads (by omega) (by omega)
            (table_skip_idempotent text position) (@tableReadFuel fuel)
          intro next advanced nextBound
          exact ih (by simp [ArrayBindings.ValidInitials]) false next true .noElements nextBound

theorem tableReadFuel_eq_read {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    (metadata : ArrayBindings.ValidTable text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (fuel position maskFirst maskAfter : Nat) (allowSign : Bool) (arrayReads : ArrayReadMode)
    (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    tableReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads := by
  rw [tableReadFuel_correspondence valid metadata initialsValid elaborating fuel position maskFirst maskAfter allowSign arrayReads bound]
  unfold ArrayGrammar.read
  by_cases zero : position = 0
  · subst position
    simp [ArrayGrammar.parseFuel_zero, ArrayGrammar.summarize]
  · congr 1
    cases found : ArrayGrammar.parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads with
    | none =>
        cases other : ArrayGrammar.parseFuel (text.length + 1) text position names arrays maskFirst maskAfter allowSign arrayReads with
        | none => rfl
        | some value =>
            have complete := ArrayGrammar.SourceAt.parse (ArrayGrammar.parseFuel_source bound other) fuel bound enough
            rw [found] at complete
            cases complete
    | some value =>
        exact (ArrayGrammar.SourceAt.parse (ArrayGrammar.parseFuel_source bound found)
          (text.length + 1) bound (by omega)).symm

theorem tableReadFuel_large {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    (metadata : ArrayBindings.ValidTable text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (fuel position maskFirst maskAfter : Nat) (allowSign : Bool) (arrayReads : ArrayReadMode)
    (bound : position ≤ text.length + 1) (large : text.length < fuel) :
    tableReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads := by
  by_cases zero : position = 0
  · subst position
    rw [tableReadFuel_correspondence valid metadata initialsValid elaborating fuel 0 maskFirst maskAfter allowSign arrayReads (by omega)]
    simp [ArrayGrammar.read, ArrayGrammar.parseFuel_zero, ArrayGrammar.summarize]
  · exact tableReadFuel_eq_read valid metadata initialsValid elaborating fuel position maskFirst maskAfter allowSign arrayReads bound (by omega)

theorem table_read_zero_result {text : Source} {names : Environment} {arrays : ArrayBindings.Table}
    {position maskFirst maskAfter : Nat} {allowSign elaborating : Bool} {initials : ArrayBindings.Initials}
    {arrayReads : ArrayReadMode}
    (zero : (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after = 0) :
    ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads = invalid :=
  summarizeTable_zero arrays initials elaborating zero

theorem table_read_bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Table}
    {position maskFirst maskAfter : Nat} {allowSign elaborating : Bool} {initials : ArrayBindings.Initials}
    {arrayReads : ArrayReadMode} (bound : position ≤ text.length + 1)
    (success : (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≠ 0) :
    position < (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ∧
      (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≤ text.length + 1 ∧
      0 < (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).operands ∧
      (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).operands ≤ maxOperands := by
  obtain ⟨value, bounds, found, _, limit, _, result⟩ := ArrayGrammar.summarize_success success
  have cursor := ArrayGrammar.parseFuel_bounds bound found
  rw [ArrayGrammar.read, result]
  exact ⟨cursor.1, cursor.2, leaves_positive value.expression, limit⟩

theorem table_read_type {text : Source} (valid : ValidText text) {position maskFirst maskAfter : Nat}
    {names : Environment} {allowSign : Bool} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {arrayReads : ArrayReadMode}
    (bound : position ≤ text.length + 1) :
    ResultType (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads) := by
  by_cases zero : (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after = 0
  · rw [table_read_zero_result zero]
    exact invalid_type
  · have limits := table_read_bounds bound zero
    obtain ⟨expression, inferred, operands, _⟩ := ArrayGrammar.read_has_expression zero
    exact ⟨by have length := valid.2; omega, Integer.Expr.infer_bounded inferred, limits.2.2.2⟩

end Silver.ScalarExpression.Native
