module

public import Silver.ApplicationPackageNames
public import Silver.NamedDisjoint

@[expose] public section

namespace Silver.ApplicationPackageNames

private theorem identifier_tail_bytes {text bytes : Source} {first after : Nat} {previous : Bool}
    (source : Named.IdentifierTail text first previous bytes after) :
    (bytes = [] → previous = false) ∧
    (bytes ≠ [] → bytes.getD (bytes.length - 1) 0 ≠ 95) ∧
    (∀ index, index < bytes.length →
      identifierCharacter (bytes.getD index 0) = true ∧
      (bytes.getD index 0 = 95 →
        if index = 0 then previous = false else bytes.getD (index - 1) 0 ≠ 95)) := by
  induction source with
  | stop => simp
  | @character first after previous bytes bound character allowed rest ih =>
    refine ⟨by simp, ?_, ?_⟩
    · intro _
      cases bytes with
      | nil =>
        have last := ih.1 rfl
        simpa only [List.length_cons, List.length_nil, Nat.add_sub_cancel,
          List.getD_cons_zero, beq_eq_false_iff_ne] using last
      | cons head tail =>
        simpa only [List.length_cons, Nat.add_sub_cancel, List.getD_cons_succ] using
          ih.2.1 (by simp)
    · intro index inside
      cases index with
      | zero =>
        simp only [List.getD_cons_zero, ↓reduceIte]
        refine ⟨character, ?_⟩
        intro underscore
        cases previous with
        | false => rfl
        | true => exact False.elim (allowed ⟨underscore, rfl⟩)
      | succ index =>
        have row := ih.2.2 index (by simpa only [List.length_cons, Nat.succ_lt_succ_iff] using inside)
        simp only [List.getD_cons_succ, Nat.succ_ne_zero, ↓reduceIte, Nat.add_sub_cancel]
        refine ⟨row.1, ?_⟩
        intro underscore
        have prior := row.2 underscore
        cases index with
        | zero =>
          simpa only [↓reduceIte, List.getD_cons_zero, beq_eq_false_iff_ne] using prior
        | succ index =>
          simpa only [Nat.succ_ne_zero, ↓reduceIte, Nat.add_sub_cancel, List.getD_cons_succ] using prior

private theorem identifier_bytes {text bytes : Source} {first after : Nat}
    (source : Named.IdentifierAt text first bytes after)
    (bounded : bytes.length ≤ maxSourceLength) :
    PackageBindings.isIdentifier ⟨first, bytes⟩ = true := by
  cases source with
  | @identifier after bytes position letter rest =>
    have tail := identifier_tail_bytes rest
    have headNot : Cursor.byteAt text first ≠ 95 := by
      simp only [Named.letter, decide_eq_true_eq] at letter
      omega
    have final : (Cursor.byteAt text first :: bytes).getD bytes.length 0 ≠ 95 := by
      cases bytes with
      | nil => simpa only [List.length_nil, List.getD_cons_zero] using headNot
      | cons head tailBytes =>
        simpa only [List.length_cons, Nat.add_sub_cancel, List.getD_cons_succ] using
          tail.2.1 (by simp)
    simp only [PackageBindings.isIdentifier, List.length_cons, Nat.add_sub_cancel,
      List.getD_cons_zero, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true,
      List.mem_range]
    refine ⟨⟨⟨⟨by omega, bounded⟩, letter⟩, final⟩, ?_⟩
    intro index inside
    cases index with
    | zero => simp only [List.getD_cons_zero, headNot, ↓reduceIte, and_true]; exact Named.letter_identifier _ letter
    | succ index =>
      have row := tail.2.2 index (by omega)
      simp only [List.getD_cons_succ, row.1, true_and, Nat.add_sub_cancel]
      split
      · rename_i underscore
        simp only [Bool.and_eq_true, decide_eq_true_eq]
        refine ⟨by omega, ?_⟩
        cases index with
        | zero => simpa only [List.getD_cons_zero] using headNot
        | succ index =>
          simpa only [Nat.succ_ne_zero, ↓reduceIte, Nat.add_sub_cancel, List.getD_cons_succ] using row.2 underscore
      · trivial

/-- The original maximal identifier derivation supplies the metadata reader's
complete spelling check, including the no-adjacent/trailing-underscore rules.
Only the source bound and the identifier's own original span are required. -/
theorem identifier_validName {text bytes : Source} {first after : Nat}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (positive : 0 < first) (source : Named.IdentifierAt text first bytes after) :
    PackageBindings.validName (metadataText text) ⟨first, after⟩ = true := by
  have bounds := Named.identifier_bounds source
  have span := Named.identifier_span source positive
  have count : bytes.length ≤ maxSourceLength := by omega
  have spelling := identifier_bytes source count
  have slice : ((metadataText text).slice first (after - 1)).bytes = bytes := by
    rw [span]
    have offset : ((first : Int) - 1).toNat = first - 1 := by omega
    have length : after - 1 + 1 - first = after - first := by omega
    simp only [metadataText, ApplicationUnits.Native.SourceValue.slice, Named.span,
      Cursor.remaining, offset, length]
  unfold PackageBindings.validName
  apply Bool.and_eq_true_iff.mpr
  refine ⟨?_, ?_⟩
  · apply decide_eq_true_eq.mpr
    exact ⟨rfl, validText.1, validText.2, positive, bounds.2.2.1, bounds.2.2.2⟩
  · simpa only [PackageBindings.isIdentifier, slice] using spelling

end Silver.ApplicationPackageNames
