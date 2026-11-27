module

public import Silver.ProcedureNameSelectors
public import Silver.ProcedureNameIdentity

@[expose] public section

namespace Silver.Predicate
open Compose

/-- A successful lexical exclusion traverses a complete qualified reference.
The existing Input_Is_Valid selector fast path ends at that same identifier;
it cannot skip a later token in the expression. -/
theorem ActualNameFreeTrace.reference {text : Source}
    {position limit targetFirst targetAfter : Nat} {reference : QualifiedNames.Reference}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : QualifiedNames.At text position reference)
    (positionBound : position ≤ text.length + 1) (finishBound : reference.after ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter reference.after := by
  have start := QualifiedNames.skip_bounds text position positionBound
  cases source with
  | bare positive identifier _ =>
      dsimp only at finishBound ⊢
      simp only [show QualifiedNames.skip = skipAt from rfl] at *
      have bounds := Named.identifier_bounds identifier
      exact (trace.identifier (by change position ≤ skipAt text position ∧ _ at start; omega)
        rfl (Nat.ne_of_gt positive) identifier finishBound).2
  | @qualified packageBytes memberBytes packageAfter memberAfter positive packageName dotted memberPositive memberName =>
      dsimp only at finishBound ⊢
      dsimp only [QualifiedNames.singleDot] at dotted
      simp only [show QualifiedNames.skip = skipAt from rfl] at *
      have packageBounds := Named.identifier_bounds packageName
      have dotBounds := QualifiedNames.skip_bounds text packageAfter packageBounds.2.2.2
      change packageAfter ≤ skipAt text packageAfter ∧ _ at dotBounds
      have memberBounds := Named.identifier_bounds memberName
      have memberStart := QualifiedNames.skip_bounds text
        (skipAt text packageAfter + 1) (by omega)
      change skipAt text packageAfter + 1 ≤ skipAt text (skipAt text packageAfter + 1) ∧ _ at memberStart
      have afterPackage := (trace.identifier
        (by change position ≤ skipAt text position ∧ _ at start; omega) rfl
        (Nat.ne_of_gt positive) packageName (by omega)).2
      cases afterPackage with
      | done => omega
      | step packagePositive packageBefore _ _ rest =>
          rw [actualNameStep_dot rfl packagePositive packageBefore (by omega) dotted.2.2.1] at rest
          dsimp only at rest
          have finishFromDot (next : ActualNameFreeTrace text limit targetFirst targetAfter
              (skipAt text packageAfter + 1)) : ActualNameFreeTrace text limit targetFirst targetAfter memberAfter :=
            (next.identifier (by omega) rfl (Nat.ne_of_gt memberPositive) memberName finishBound).2
          by_cases enabled : skipAt text packageAfter > 1 ∧ Cursor.byteAt text (skipAt text packageAfter - 1) ≠ 46
          · rw [ite_eq_left enabled] at rest
            by_cases consumed :
                fixedAfter text (fixedAfter text (skipAt text packageAfter) "." false) "input_is_valid" true > skipAt text packageAfter ∧
                fixedAfter text (fixedAfter text (skipAt text packageAfter) "." false) "input_is_valid" true ≤ limit
            · rw [ite_eq_left consumed] at rest
              have dotFixed : fixedAfter text (skipAt text packageAfter) "." false =
                  skipAt text packageAfter + 1 :=
                fixedDot_after (by omega) dotted.2.1 (skipAt_idempotent _ _) dotted.2.2.1
              rw [dotFixed] at consumed rest
              obtain ⟨bytes, selected⟩ := fixedIdentifier_source
                (show skipAt text packageAfter + 1 ≤ text.length + 1 by omega)
                (word := "input_is_valid") (by decide) (by omega :
                  fixedAfter text (skipAt text packageAfter + 1) "input_is_valid" true ≠ 0)
              have same := (Named.identifier_unique selected memberName).2
              simpa only [same] using rest
            · rw [ite_eq_right consumed] at rest
              exact finishFromDot rest
          · rw [ite_eq_right enabled] at rest
            simp only [Nat.not_lt_zero, false_and, ite_false] at rest
            exact finishFromDot rest

theorem scalarLookupFrom_qualifier {text : Source} {names : ScalarExpression.Environment}
    {first after count index qualifierFirst qualifierAfter : Nat}
    (found : ScalarExpression.lookupFrom text names first after count qualifierFirst qualifierAfter = index)
    (positive : index ≠ 0) :
    QualifiedNames.qualifierMatches text (ScalarExpression.binding names index).qualifierFirst
      (ScalarExpression.binding names index).qualifierAfter qualifierFirst qualifierAfter = true := by
  induction count with
  | zero => exact False.elim (positive found.symm)
  | succ count ih =>
      rw [ScalarExpression.lookupFrom] at found
      split at found
      · exact False.elim (positive found.symm)
      · split at found
        · rename_i matching
          cases found
          simp only [Bool.and_eq_true] at matching
          exact matching.2
        · exact ih found

theorem scalarLookup_qualified_ne_bare {text : Source} {names : ScalarExpression.Environment}
    {first after qualifierFirst qualifierAfter targetFirst targetAfter index target : Nat}
    (qualified : qualifierFirst ≠ 0)
    (found : ScalarExpression.lookup text names first after qualifierFirst qualifierAfter = index)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetPositive : target ≠ 0) : index ≠ target := by
  intro same
  rw [same] at found
  have left := scalarLookupFrom_qualifier found targetPositive
  have right := scalarLookupFrom_qualifier targetFound targetPositive
  simp only [QualifiedNames.qualifierMatches, qualified, ite_false, Bool.and_eq_true,
    decide_eq_true_eq] at left
  simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at right
  omega

end Silver.Predicate
