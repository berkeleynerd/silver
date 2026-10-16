module

public import Silver.ImageModelInsertion

@[expose] public section
namespace Silver.ImageModel

structure MatchState where
  position : Nat := 0
  live : Bool := true
  deriving DecidableEq

/-- Native table positions are one-based; the matched count is zero-based. -/
def matchByte (table : Nat → Nat) (length : Nat) (state : MatchState) (byte : Nat) : MatchState :=
  if state.live then
    if state.position < length ∧ table (state.position + 1) = byte
    then ⟨state.position + 1, true⟩ else {state with live := false}
  else state

def MatchInvariant (table : Nat → Nat) (length : Nat) (input : List Nat) (state : MatchState) : Prop :=
  state.live = true → state.position = input.length ∧ input.length ≤ length ∧
    ∀ i, (h : i < input.length) → input[i] = table (i + 1)

theorem initial_match_invariant (table : Nat → Nat) (length : Nat) :
    MatchInvariant table length [] {} := by
  intro _
  exact ⟨rfl, Nat.zero_le _, fun _ h => by simp at h⟩

theorem matchByte_preserves {table : Nat → Nat} {length : Nat} {input : List Nat} {state : MatchState}
    (invariant : MatchInvariant table length input state) (byte : Nat) :
    MatchInvariant table length (input ++ [byte]) (matchByte table length state byte) := by
  unfold MatchInvariant matchByte
  by_cases live : state.live = true
  · simp only [live, ↓reduceIte]
    by_cases matched : state.position < length ∧ table (state.position + 1) = byte
    · simp [matched]
      obtain ⟨position, bounded, items⟩ := invariant live
      refine ⟨by omega, by omega, ?_⟩
      intro i bound
      by_cases old : i < input.length
      · rw [List.getElem_append_left old]
        exact items i old
      · have last : i = input.length := by omega
        subst i
        simp only [List.getElem_append_right (Nat.le_refl _), Nat.sub_self, List.getElem_cons_zero]
        simpa only [position] using matched.2.symm
    · simp only [matched, ↓reduceIte, Bool.false_eq_true, false_implies]
  · have dead : state.live = false := Bool.eq_false_iff.mpr live
    simp only [dead, Bool.false_eq_true, ↓reduceIte, false_implies]

theorem match_fold_preserves {table : Nat → Nat} {length : Nat}
    (suffix : List Nat) (before : List Nat) (state : MatchState)
    (invariant : MatchInvariant table length before state) :
    MatchInvariant table length (before ++ suffix) (suffix.foldl (matchByte table length) state) := by
  induction suffix generalizing before state with
  | nil => simpa only [List.append_nil, List.foldl_nil] using invariant
  | cons byte tail ih =>
      have next := ih (before ++ [byte]) (matchByte table length state byte)
        (matchByte_preserves invariant byte)
      simpa only [List.foldl_cons, List.append_assoc, List.cons_append, List.nil_append] using next

/-- Successful matching is equality with the entire selected table. This rules
out any extra declaration, changed origin, or changed scoped name in a target. -/
theorem match_accepts_exact (table : Nat → Nat) (length : Nat) (input : List Nat)
    (live : (input.foldl (matchByte table length) {}).live = true)
    (finished : (input.foldl (matchByte table length) {}).position = length) :
    input.length = length ∧ ∀ i, (h : i < input.length) → input[i] = table (i + 1) := by
  have invariant := match_fold_preserves input [] {} (initial_match_invariant table length)
  simp only [List.nil_append] at invariant
  obtain ⟨position, _, bytes⟩ := invariant live
  exact ⟨position.symm.trans finished, bytes⟩

theorem match_accepts_unique (table : Nat → Nat) (length : Nat) (left right : List Nat)
    (leftLive : (left.foldl (matchByte table length) {}).live = true)
    (leftDone : (left.foldl (matchByte table length) {}).position = length)
    (rightLive : (right.foldl (matchByte table length) {}).live = true)
    (rightDone : (right.foldl (matchByte table length) {}).position = length) : left = right := by
  obtain ⟨leftLength, leftItems⟩ := match_accepts_exact table length left leftLive leftDone
  obtain ⟨rightLength, rightItems⟩ := match_accepts_exact table length right rightLive rightDone
  apply List.ext_getElem (leftLength.trans rightLength.symm)
  intro i li ri
  exact (leftItems i li).trans (rightItems i ri).symm

end Silver.ImageModel
