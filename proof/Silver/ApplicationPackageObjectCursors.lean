module

public import Silver.ApplicationPackageObjectRows
public import Silver.ComposeSubtypeDeclarations
public import Silver.PredicateNativeRanges

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageDeclarations

/-- A nonempty successfully consumed fixed token also bounds its incoming
position. Beyond EOF, skipping trivia leaves the final empty suffix. -/
theorem fixed_window {text : Source} {position : Nat} {spelling : String} {word : Bool}
    (nonempty : 0 < spelling.toList.length) (accepted : fixedAfter text position spelling word ≠ 0) :
    position < fixedAfter text position spelling word ∧ fixedAfter text position spelling word ≤ text.length + 1 := by
  have bounded : position ≤ text.length + 1 := by
    by_cases before : position ≤ text.length + 1
    · exact before
    · have positive : position ≠ 0 := by omega
      have exhausted : Cursor.remaining text position = [] := List.drop_eq_nil_of_le (by omega)
      have final : Cursor.triviaPosition text position = text.length + 1 := by
        simp [Cursor.triviaPosition, exhausted, Cursor.endPosition, triviaEnd]
      have absent : fixedAt text (text.length + 1) spelling word = false := by
        simp [fixedAt, Nat.ne_of_gt nonempty]
      simp [fixedAfter, positive, final, absent] at accepted
  exact ⟨model_fixed_advances text position spelling word bounded nonempty accepted,
    fixedAfter_result_bound text position spelling word nonempty⟩

private theorem type_after (text : Source) (frame : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    (packageTypeAt text frame info position).after = 0 ∨
      (packageTypeAt text frame info position).after = nameAfter text (skipAt text position) := by
  dsimp only [packageTypeAt]
  split
  · exact Or.inl rfl
  · split
    · exact Or.inr rfl
    · split
      · exact Or.inr rfl
      · split <;> first | exact Or.inr rfl | exact Or.inl rfl

theorem type_window {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {position : Nat}
    (bounded : position ≤ text.length + 1) (accepted : (packageTypeAt text frame info position).after ≠ 0) :
    position < (packageTypeAt text frame info position).after ∧
      (packageTypeAt text frame info position).after ≤ text.length + 1 := by
  have after := (type_after text frame info position).resolve_left accepted
  rw [after] at accepted ⊢
  have named := model_name_advances text _ accepted
  exact ⟨Nat.lt_of_le_of_lt (skipAt_advances text position bounded (Nat.ne_of_gt named.1)) named.2,
    model_name_valid text _⟩

theorem constraint_window {text : Source} {position : Nat} {names : ScalarExpression.Environment}
    {base : Integer.Interval} (bounded : position ≤ text.length + 1)
    (accepted : (scalarConstraintAt text position names base).after ≠ 0) :
    position ≤ (scalarConstraintAt text position names base).after ∧
      (scalarConstraintAt text position names base).after ≤ text.length + 1 := by
  have reading := scalarConstraintAt_sound text position names bounded accepted
  generalize scalarConstraintAt text position names base = result at reading ⊢
  cases reading with
  | absent => exact ⟨Nat.le_refl _, bounded⟩
  | present range low delimiter high _ _ _ _ _ _ _ =>
    have first := (fixed_window (by decide) range).1
    have last := (fixed_window (by decide) delimiter).1
    have lowEnds := low.cursorBounds
    have highEnds := high.cursorBounds
    exact ⟨Nat.le_of_lt (Nat.lt_trans first (Nat.lt_trans lowEnds.2.1 (Nat.lt_trans last highEnds.2.1))),
      highEnds.2.2⟩

theorem initializer_start {text : Source} {position minimum : Nat}
    (prior : position ≠ 0 → minimum ≤ position)
    (present : skipAt text (fixedAfter text position ":=" false) ≠ 0) :
    minimum < skipAt text (fixedAfter text position ":=" false) ∧
      skipAt text (fixedAfter text position ":=" false) ≤ text.length + 1 := by
  have token : fixedAfter text position ":=" false ≠ 0 := by
    intro missing
    simp [missing, skipAt] at present
  have inside := fixed_window (by decide) token
  have start := skipAt_advances text _ inside.2 present
  exact ⟨by have := prior (fixedAfter_nonzero token); omega, model_skip_valid text _ inside.2⟩

end Silver.ApplicationPackageObjectRows
