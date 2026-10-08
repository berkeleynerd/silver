import Silver.Admission

/-!
The SPARK ghost specification uses 1-based positions into an immutable string;
the independent lexical grammar uses remaining byte lists. This module proves
the change of representation, including every cursor equation used in the
SPARK contracts. The connection to the actual SPARK program is its GNATprove-
checked `Accepts'Result = Is_Member (Source)` postcondition, together with review
of these equations against the source definitions. It does not assume that
postcondition as a new Lean axiom.
-/

namespace Silver
namespace Cursor

def byteAt (text : Source) (position : Nat) : Nat := text.getD (position - 1) 0
def remaining (text : Source) (position : Nat) : Source := text.drop (position - 1)
def endPosition (text rest : Source) : Nat := text.length + 1 - rest.length
def commentPosition (text : Source) (position : Nat) : Nat :=
  endPosition text (commentEnd (remaining text position))
def triviaPosition (text : Source) (position : Nat) : Nat :=
  endPosition text (triviaEnd (remaining text position))

theorem remaining_cons (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length) :
    remaining text position = byteAt text position :: remaining text (position + 1) := by
  have hidx : position - 1 < text.length := by omega
  have h := List.drop_eq_getElem_cons hidx
  have hnext : position - 1 + 1 = position := by omega
  simpa [remaining, byteAt, hnext, List.getD_getElem?, hidx] using h

theorem remaining_length (text : Source) (position : Nat) :
    (remaining text position).length = text.length - (position - 1) := by
  simp [remaining]

theorem endPosition_remaining (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    endPosition text (remaining text position) = position := by
  simp only [endPosition, remaining_length]
  omega

theorem partition_full {text rest : Source} (position : Nat)
    (h : ∃ span, remaining text position = span ++ rest) :
    ∃ span, text = span ++ rest := by
  obtain ⟨span, hs⟩ := h
  refine ⟨text.take (position - 1) ++ span, ?_⟩
  rw [List.append_assoc, ← hs]
  exact (List.take_append_drop (position - 1) text).symm

theorem remaining_endPosition {text rest : Source} (h : ∃ span, text = span ++ rest) :
    remaining text (endPosition text rest) = rest := by
  obtain ⟨span, rfl⟩ := h
  have he : span.length + rest.length + 1 - rest.length - 1 = span.length := by omega
  simp only [remaining, endPosition, List.length_append]
  rw [he]
  simp

theorem remaining_commentPosition (text : Source) (position : Nat) :
    remaining text (commentPosition text position) = commentEnd (remaining text position) := by
  exact remaining_endPosition (partition_full position (comment_partition (comment_complete _)))

theorem remaining_triviaPosition (text : Source) (position : Nat) :
    remaining text (triviaPosition text position) = triviaEnd (remaining text position) := by
  exact remaining_endPosition (partition_full position (trivia_partition (trivia_complete _)))

theorem commentPosition_bounds (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    position ≤ commentPosition text position ∧ commentPosition text position ≤ text.length + 1 := by
  have hc := commentEnd_length (remaining text position)
  simp only [remaining_length] at hc
  simp only [commentPosition, endPosition]
  omega

theorem triviaPosition_bounds (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    position ≤ triviaPosition text position ∧ triviaPosition text position ≤ text.length + 1 := by
  have hc := triviaEnd_length (remaining text position)
  simp only [remaining_length] at hc
  simp only [triviaPosition, endPosition]
  omega

/-- Exact `Comment_End` recursive equation from the SPARK ghost specification. -/
theorem commentPosition_equation (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    commentPosition text position =
      if position > text.length ∨ lineEnd (byteAt text position) = true then position
      else commentPosition text (position + 1) := by
  by_cases hend : position > text.length
  · have heq : position = text.length + 1 := by omega
    subst position
    simp [commentPosition, endPosition, remaining, commentEnd]
  · have hcons := remaining_cons text position hp (by omega)
    by_cases hline : lineEnd (byteAt text position) = true
    · rw [ite_eq_left (Or.inr hline)]
      unfold commentPosition
      rw [hcons, commentEnd, ite_eq_left hline, ← hcons]
      exact endPosition_remaining text position hp hl
    · rw [ite_eq_right (by simp [hend, hline])]
      unfold commentPosition
      rw [hcons, commentEnd, ite_eq_right hline]

/-- Reading an incremented SPARK cursor is taking a suffix of the same bytes. -/
theorem remaining_add (text : Source) (position count : Nat) (hp : 1 ≤ position) :
    remaining text (position + count) = (remaining text position).drop count := by
  simp only [remaining, List.drop_drop]
  congr 1
  omega

theorem startsComment_remaining (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length) :
    startsComment (remaining text position) = true ↔
      byteAt text position = 45 ∧ position < text.length ∧ byteAt text (position + 1) = 45 := by
  rw [remaining_cons text position hp hl]
  by_cases hmore : position < text.length
  · rw [remaining_cons text (position + 1) (by omega) (by omega)]
    simp [startsComment, hmore]
  · have heq : position = text.length := by omega
    subst position
    simp [remaining, startsComment]

/-- Exact `Trivia_End` recursive equation from the SPARK ghost specification. -/
theorem triviaPosition_equation (text : Source) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    triviaPosition text position =
      if position > text.length then position
      else if whitespace (byteAt text position) then triviaPosition text (position + 1)
      else if byteAt text position = 45 ∧ position < text.length ∧ byteAt text (position + 1) = 45
      then triviaPosition text (commentPosition text (position + 2))
      else position := by
  by_cases hend : position > text.length
  · have heq : position = text.length + 1 := by omega
    subst position
    simp [triviaPosition, endPosition, remaining, triviaEnd]
  · rw [ite_eq_right hend]
    have hcons := remaining_cons text position hp (by omega)
    by_cases hw : whitespace (byteAt text position) = true
    · rw [ite_eq_left hw]
      unfold triviaPosition
      rw [hcons, triviaEnd, ite_eq_left hw]
    · rw [ite_eq_right hw]
      have he := startsComment_remaining text position hp (by omega)
      by_cases hc : startsComment (remaining text position) = true
      · rw [ite_eq_left (he.mp hc)]
        unfold triviaPosition
        rw [hcons, triviaEnd, ite_eq_right hw, ← hcons, ite_eq_left hc]
        rw [← remaining_add text position 2 hp, remaining_commentPosition]
      · rw [ite_eq_right (by intro h; exact hc (he.mpr h))]
        unfold triviaPosition
        rw [hcons, triviaEnd, ite_eq_right hw, ← hcons, ite_eq_right hc]
        exact endPosition_remaining text position hp hl

theorem boundary_position (text : Source) (position : Nat) (token : Token)
    (hp : 1 ≤ position) :
    boundary token (remaining text position) =
      (!token.isWord || decide (position > text.length) ||
        !identifierCharacter (byteAt text position)) := by
  by_cases he : position > text.length
  · have hempty : remaining text position = [] := by
      simp only [remaining, List.drop_eq_nil_iff]
      omega
    simp [hempty, boundary, he]
  · rw [remaining_cons text position hp (by omega)]
    simp [boundary, he]

theorem word_at_position (text word : Source) (position : Nat)
    (hp : 1 ≤ position) (hw : word.length ≤ (remaining text position).length) :
    (remaining text position |>.take word.length |>.map lowercase) = word ↔
      ∀ i : Fin word.length, lowercase (byteAt text (position + i.val)) = word[i.val] := by
  have hlen : ((remaining text position).take word.length |>.map lowercase).length = word.length := by
    simp [Nat.min_eq_left hw]
  have hget : ∀ i : Fin word.length,
      ((remaining text position).take word.length |>.map lowercase)[i.val]'(by rw [hlen]; exact i.isLt) =
        lowercase (byteAt text (position + i.val)) := by
    intro i
    have idx : position - 1 + i.val < text.length := by
      have hi := i.isLt
      simp only [remaining_length] at hw
      omega
    have heq : position + i.val - 1 = position - 1 + i.val := by omega
    simp [remaining, byteAt, heq, idx]
  constructor
  · intro heq i
    have he : ((remaining text position).take word.length |>.map lowercase)[i.val]'(by rw [hlen]; exact i.isLt) =
        word[i.val] := (List.ext_getElem_iff.mp heq).2 i.val _ i.isLt
    rw [hget] at he
    exact he
  · intro heq
    apply List.ext_getElem hlen
    intro i _ hi
    rw [hget ⟨i, hi⟩]
    exact heq ⟨i, hi⟩

/-- The quantified, indexed expression in the actual SPARK `Token_At` body. -/
def tokenAt (text : Source) (position : Nat) (token : Token) : Bool :=
  decide (token.spelling.length ≤ text.length + 1 - position) &&
    decide (∀ i : Fin token.spelling.length,
      lowercase (byteAt text (position + i.val)) = token.spelling[i.val]) &&
    (!token.isWord || decide (position + token.spelling.length > text.length) ||
      !identifierCharacter (byteAt text (position + token.spelling.length)))

theorem tokenAt_correspondence (text : Source) (position : Nat) (token : Token)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    tokenAt text position token = Silver.tokenAt token (remaining text position) := by
  have hlen : text.length + 1 - position = (remaining text position).length := by
    simp only [remaining_length]
    omega
  by_cases hw : token.spelling.length ≤ (remaining text position).length
  · have he := word_at_position text token.spelling position hp hw
    have hb := boundary_position text (position + token.spelling.length) token (by omega)
    rw [remaining_add text position token.spelling.length hp] at hb
    simp only [tokenAt, Silver.tokenAt, hlen, hw, decide_true, Bool.true_and]
    rw [← hb]
    congr 1
    apply Bool.eq_iff_iff.mpr
    simpa using he.symm
  · simp [tokenAt, Silver.tokenAt, hlen, hw]

/-- SPARK's recursive grammar equation, retaining its immutable text and cursor. -/
def suffixMatches (text : Source) (position : Nat) : List Token → Bool
  | [] => decide (triviaPosition text position = text.length + 1)
  | token :: tokens =>
    let start := triviaPosition text position
    tokenAt text start token && suffixMatches text (start + token.spelling.length) tokens

theorem suffixMatches_correspondence (text : Source) (position : Nat) (tokens : List Token)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    suffixMatches text position tokens = Silver.suffixMatches tokens (remaining text position) := by
  induction tokens generalizing position with
  | nil =>
    apply Bool.eq_iff_iff.mpr
    simp only [suffixMatches, Silver.suffixMatches]
    rw [decide_eq_true_iff, List.isEmpty_iff_length_eq_zero]
    unfold triviaPosition endPosition
    omega
  | cons token tokens ih =>
    have hs := triviaPosition_bounds text position hp hl
    have hsp : 1 ≤ triviaPosition text position := by omega
    have ha := tokenAt_correspondence text (triviaPosition text position) token hsp hs.2
    rw [remaining_triviaPosition] at ha
    simp only [suffixMatches, Silver.suffixMatches]
    rw [ha]
    by_cases ht : Silver.tokenAt token (triviaEnd (remaining text position)) = true
    · have hlength := ((tokenAt_iff token _).mp ht).1
      have hword := ((spells_iff_take_drop _ _ _).mp hlength).1
      have hr := remaining_length text (triviaPosition text position)
      rw [remaining_triviaPosition] at hr
      have hnext : triviaPosition text position + token.spelling.length ≤ text.length + 1 := by
        omega
      have hi := ih (triviaPosition text position + token.spelling.length) (by omega) hnext
      rw [remaining_add text (triviaPosition text position) token.spelling.length hsp,
        remaining_triviaPosition] at hi
      simp [ht, hi]
    · have hf : Silver.tokenAt token (triviaEnd (remaining text position)) = false :=
        Bool.eq_false_iff.mpr ht
      simp [hf]

def suffixAtIndex (text : Source) (position nextToken : Nat) : Bool :=
  suffixMatches text position (requiredTokens.drop (nextToken - 1))

/-- Exact token-index control equation of the SPARK `Suffix_Matches` definition. -/
theorem suffixAtIndex_equation (text : Source) (position nextToken : Nat)
    (hn : 1 ≤ nextToken) :
    suffixAtIndex text position nextToken =
      if nextToken > requiredTokens.length then
        decide (triviaPosition text position = text.length + 1)
      else
        let token := requiredTokens.getD (nextToken - 1) .semicolon
        tokenAt text (triviaPosition text position) token &&
          suffixAtIndex text (triviaPosition text position + token.spelling.length) (nextToken + 1) := by
  unfold suffixAtIndex
  by_cases hend : nextToken > requiredTokens.length
  · have he : requiredTokens.length ≤ nextToken - 1 := by omega
    simp [hend, List.drop_eq_nil_of_le he, suffixMatches]
  · have hi : nextToken - 1 < requiredTokens.length := by omega
    have hdrop := List.drop_eq_getElem_cons hi
    have hnext : nextToken - 1 + 1 = nextToken := by omega
    simp only [hend, ↓reduceIte, Nat.add_sub_cancel, hdrop, suffixMatches, hnext]
    simp only [List.getD, List.getElem?_eq_getElem hi, Option.getD_some]

/-- The exact structure of the SPARK `Is_Member` definition after normalization. -/
def isMember (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixAtIndex source 1 1

theorem isMember_correspondence (source : Source) : isMember source = accepts source := by
  have hs := suffixMatches_correspondence source 1 requiredTokens (by omega) (by omega)
  simpa [isMember, accepts, suffixAtIndex, remaining] using
    congrArg (fun result => decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
      source.all allowedCharacter && result) hs

/-- Indexed SPARK ghost equations and the independent byte grammar are equivalent. -/
theorem isMember_iff (source : Source) : isMember source = true ↔ Member source := by
  rw [isMember_correspondence]
  exact accepts_iff_member source

end Cursor
end Silver
