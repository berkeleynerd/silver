module

public import Silver.NamedIdentifier

@[expose] public section

/-! A scalar name is either one identifier or one package-qualified identifier.
The second dot of a range is never consumed as qualification. Source positions
retain their original unit offsets. -/
namespace Silver.QualifiedNames

structure Reference where
  first : Nat := 0
  after : Nat := 0
  qualifierFirst : Nat := 0
  qualifierAfter : Nat := 0
  deriving DecidableEq, Repr

def ValidSpan (text : Source) (first after : Nat) : Prop :=
  (first = 0 ∧ after = 0) ∨
    (0 < first ∧ first < after ∧ after ≤ text.length + 1)

def skip (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else Cursor.triviaPosition text position

def nameAfter (text : Source) (position : Nat) : Nat :=
  if position = 0 then 0 else Named.identifierEnd text position

theorem nameAfter_eq_identifier (text : Source) (position : Nat) (nonzero : position ≠ 0) :
    nameAfter text position = Named.identifierEnd text position := ite_eq_right nonzero

def singleDot (text : Source) (position : Nat) : Prop :=
  0 < position ∧ position ≤ text.length ∧ Cursor.byteAt text position = 46 ∧
    (position = text.length ∨ Cursor.byteAt text (position + 1) ≠ 46)

instance (text : Source) (position : Nat) : Decidable (singleDot text position) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _))

def read (text : Source) (position : Nat) : Reference :=
  let first := skip text position
  let after := nameAfter text first
  let dot := skip text after
  if first = 0 ∨ after ≤ first then {}
  else if singleDot text dot then
    let memberFirst := skip text (dot + 1)
    let memberAfter := nameAfter text memberFirst
    if memberFirst = 0 ∨ memberAfter ≤ memberFirst then {}
    else ⟨memberFirst, memberAfter, first, after⟩
  else ⟨first, after, 0, 0⟩

private theorem trivia_terminal {text rest : Source} (parsed : Trivia text rest) :
    triviaEnd rest = rest := by
  induction parsed with
  | eof => simp [triviaEnd]
  | stop _ _ space comment => simp [triviaEnd, space, comment]
  | space _ _ _ _ _ ih | comment _ _ _ _ _ ih => exact ih

theorem skip_idempotent (text : Source) (position : Nat) :
    skip text (skip text position) = skip text position := by
  by_cases zero : skip text position = 0
  · rw [zero]; rfl
  · have positionNonzero : position ≠ 0 := by
      intro equal
      simp [skip, equal] at zero
    have equation : skip text position = Cursor.triviaPosition text position := ite_eq_right positionNonzero
    calc
      skip text (skip text position) = Cursor.triviaPosition text (skip text position) := ite_eq_right zero
      _ = Cursor.triviaPosition text (Cursor.triviaPosition text position) := congrArg _ equation
      _ = Cursor.triviaPosition text position := by
        change Cursor.endPosition text (triviaEnd (Cursor.remaining text (Cursor.triviaPosition text position))) = _
        rw [Cursor.remaining_triviaPosition, trivia_terminal (trivia_complete _)]
        rfl
      _ = skip text position := equation.symm

theorem read_skipped (text : Source) (position : Nat) :
    read text (skip text position) = read text position := by
  simp only [read, skip_idempotent]

/-- The two source productions use identifier derivations and a single dot;
neither production assumes the result of the reference reader. -/
inductive At (text : Source) (position : Nat) : Reference → Prop
  | bare {bytes : Source} {after : Nat} :
      0 < skip text position →
      Named.IdentifierAt text (skip text position) bytes after →
      ¬ singleDot text (skip text after) →
      At text position ⟨skip text position, after, 0, 0⟩
  | qualified {packageBytes memberBytes : Source} {packageAfter memberAfter : Nat} :
      0 < skip text position →
      Named.IdentifierAt text (skip text position) packageBytes packageAfter →
      singleDot text (skip text packageAfter) →
      0 < skip text (skip text packageAfter + 1) →
      Named.IdentifierAt text (skip text (skip text packageAfter + 1)) memberBytes memberAfter →
      At text position
        ⟨skip text (skip text packageAfter + 1), memberAfter, skip text position, packageAfter⟩

/-- Qualification is part of identity. An imported P.X cannot hide or alias a
bare X, even if both member spans have the same case-insensitive spelling. -/
def qualifierMatches (text : Source) (itemFirst itemAfter first after : Nat) : Bool :=
  if first = 0 then itemFirst == 0
  else decide (0 < itemFirst) && Named.equalName text itemFirst itemAfter first after

def sameReference (text : Source) (item reference : Reference) : Bool :=
  Named.equalName text item.first item.after reference.first reference.after &&
    qualifierMatches text item.qualifierFirst item.qualifierAfter
      reference.qualifierFirst reference.qualifierAfter

def masked (text : Source) (reference : Reference) (first after : Nat) : Bool :=
  decide (first ≠ 0) &&
    if reference.qualifierFirst = 0 then Named.equalName text first after reference.first reference.after
    else Named.equalName text first after reference.qualifierFirst reference.qualifierAfter

theorem skip_bounds (text : Source) (position : Nat) (bound : position ≤ text.length + 1) :
    position ≤ skip text position ∧ skip text position ≤ text.length + 1 := by
  by_cases zero : position = 0
  · simp [skip, zero]
  · simpa only [skip, zero, ↓reduceIte] using
      Cursor.triviaPosition_bounds text position (by omega) bound

theorem nameAfter_bounds (text : Source) (position : Nat) :
    nameAfter text position ≤ text.length + 1 := by
  by_cases zero : position = 0
  · simp [nameAfter, zero]
  · by_cases failed : Named.identifierEnd text position = 0
    · simp [nameAfter, zero, failed]
    · simpa only [nameAfter, zero, ↓reduceIte] using
        (Named.identifierEnd_bounds text position failed).2

theorem nameAfter_valid (text : Source) (position : Nat) :
    nameAfter text position = 0 ∨
      (0 < position ∧ position < nameAfter text position ∧
        nameAfter text position ≤ text.length + 1) := by
  by_cases zero : position = 0
  · simp [nameAfter, zero]
  · by_cases failed : Named.identifierEnd text position = 0
    · simp [nameAfter, zero, failed]
    · exact Or.inr ⟨by omega, by
        simpa only [nameAfter, zero, ↓reduceIte] using
          Named.identifierEnd_bounds text position failed⟩

theorem read_bounds (text : Source) (position : Nat) (bound : position ≤ text.length + 1) :
    ValidSpan text (read text position).first (read text position).after ∧
      ValidSpan text (read text position).qualifierFirst (read text position).qualifierAfter ∧
      ((read text position).after = 0 ∨
        (position < (read text position).after ∧ (read text position).after ≤ text.length + 1)) := by
  have first := skip_bounds text position bound
  have after := nameAfter_bounds text (skip text position)
  have dot := skip_bounds text (nameAfter text (skip text position)) after
  unfold read
  dsimp only
  split
  · simp [ValidSpan]
  · rename_i valid
    split
    · rename_i qualified
      have member := skip_bounds text
        (skip text (nameAfter text (skip text position)) + 1) (by
          have inside := qualified.2.1
          omega)
      have memberAfter := nameAfter_bounds text
        (skip text (skip text (nameAfter text (skip text position)) + 1))
      split
      · simp [ValidSpan]
      · rename_i good
        dsimp only
        refine ⟨Or.inr ⟨by omega, by omega, memberAfter⟩,
          Or.inr ⟨by omega, by omega, after⟩, Or.inr ⟨by omega, memberAfter⟩⟩
    · dsimp only
      exact ⟨Or.inr ⟨by omega, by omega, after⟩,
        Or.inl ⟨rfl, rfl⟩, Or.inr ⟨by omega, after⟩⟩

theorem read_after_bound (text : Source) (position : Nat) (bound : position ≤ text.length + 1) :
    (read text position).after ≤ text.length + 1 := by
  rcases (read_bounds text position bound).2.2 with zero | good
  · omega
  · exact good.2

theorem read_absent (text : Source) (position : Nat)
    (absent : nameAfter text (skip text position) = 0) : read text position = {} := by
  simp [read, absent]

theorem read_bare_of_no_dot (text : Source) (position : Nat)
    (named : nameAfter text (skip text position) ≠ 0)
    (bare : ¬ singleDot text (skip text (nameAfter text (skip text position)))) :
    read text position = ⟨skip text position, nameAfter text (skip text position), 0, 0⟩ := by
  rcases nameAfter_valid text (skip text position) with absent | valid
  · exact False.elim (named absent)
  · simp [read, Nat.ne_of_gt valid.1, Nat.not_le.mpr valid.2.1, bare]

theorem read_dot_cases (text : Source) (position : Nat)
    (dotted : singleDot text (skip text (nameAfter text (skip text position)))) :
    read text position = {} ∨ (read text position).qualifierFirst = skip text position := by
  simp only [read, dotted, ↓reduceIte]
  split
  · exact Or.inl rfl
  · split
    · exact Or.inl rfl
    · exact Or.inr rfl

theorem read_sound (text : Source) (position : Nat)
    (success : (read text position).after ≠ 0) : At text position (read text position) := by
  unfold read at success ⊢
  dsimp only at success ⊢
  split at success
  · exact False.elim (success rfl)
  · rename_i valid
    have firstPositive : 0 < skip text position := by omega
    have firstNonzero : skip text position ≠ 0 := by omega
    have nameNonzero : Named.identifierEnd text (skip text position) ≠ 0 := by
      intro absent
      rw [nameAfter_eq_identifier text _ firstNonzero, absent] at valid
      omega
    obtain ⟨bytes, parsed⟩ := Named.identifierEnd_sound text (skip text position) nameNonzero
    have parsed' : Named.IdentifierAt text (skip text position) bytes
        (nameAfter text (skip text position)) := by
      rwa [nameAfter_eq_identifier text _ firstNonzero]
    simp only [valid, ↓reduceIte]
    split at success
    · rename_i qualified
      simp only [qualified, ↓reduceIte]
      split at success
      · exact False.elim (success rfl)
      · rename_i memberValid
        have memberPositive : 0 < skip text (skip text (nameAfter text (skip text position)) + 1) := by omega
        have memberNonzero : skip text (skip text (nameAfter text (skip text position)) + 1) ≠ 0 := by omega
        have memberNameNonzero : Named.identifierEnd text
            (skip text (skip text (nameAfter text (skip text position)) + 1)) ≠ 0 := by
          intro absent
          rw [nameAfter_eq_identifier text _ memberNonzero, absent] at memberValid
          omega
        obtain ⟨memberBytes, memberParsed⟩ := Named.identifierEnd_sound text _ memberNameNonzero
        simp only [memberValid, ↓reduceIte]
        apply At.qualified firstPositive parsed' qualified memberPositive
        rw [nameAfter_eq_identifier text _ memberNonzero]
        exact memberParsed
    · rename_i bare
      simp only [bare, ↓reduceIte]
      exact At.bare firstPositive parsed' bare

theorem read_complete {text : Source} {position : Nat} {reference : Reference}
    (parsed : At text position reference) : read text position = reference := by
  cases parsed with
  | bare positive identifier bare =>
      have after := Named.identifierEnd_complete identifier
      have bounds := Named.identifier_bounds identifier
      simp [read, nameAfter, Nat.ne_of_gt positive, after, Nat.not_le.mpr bounds.2.2.1, bare]
  | qualified positive packageName qualified memberPositive memberName =>
      have after := Named.identifierEnd_complete packageName
      have bounds := Named.identifier_bounds packageName
      have memberAfter := Named.identifierEnd_complete memberName
      have memberBounds := Named.identifier_bounds memberName
      simp [read, nameAfter, Nat.ne_of_gt positive, after, Nat.not_le.mpr bounds.2.2.1,
        qualified, Nat.ne_of_gt memberPositive, memberAfter, Nat.not_le.mpr memberBounds.2.2.1]

theorem at_unique {text : Source} {position : Nat} {left right : Reference}
    (a : At text position left) (b : At text position right) : left = right :=
  (read_complete a).symm.trans (read_complete b)

theorem read_success (text : Source) (position : Nat) (bound : position ≤ text.length + 1)
    (success : (read text position).after ≠ 0) :
    0 < (read text position).first ∧
      (read text position).first < (read text position).after ∧
      position < (read text position).after ∧ (read text position).after ≤ text.length + 1 := by
  obtain ⟨span, _, progress⟩ := read_bounds text position bound
  rcases span with absent | span
  · exact False.elim (success absent.2)
  · rcases progress with absent | progress
    · exact False.elim (success absent)
    · exact ⟨span.1, span.2.1, progress⟩

theorem bare_qualified_distinct (text : Source) (item reference : Reference)
    (bare : reference.qualifierFirst = 0) (qualified : item.qualifierFirst ≠ 0) :
    sameReference text item reference = false := by
  simp [sameReference, qualifierMatches, bare, qualified]

theorem qualified_bare_distinct (text : Source) (item reference : Reference)
    (bare : item.qualifierFirst = 0) (qualified : reference.qualifierFirst ≠ 0) :
    sameReference text item reference = false := by
  simp [sameReference, qualifierMatches, bare, qualified]

end Silver.QualifiedNames
