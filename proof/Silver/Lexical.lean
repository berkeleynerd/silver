import Std

/-!
Byte-level semantics of the initial profile. Naturals represent byte values;
the global character restriction excludes every value outside admitted ASCII.
The `Comment`, `Trivia`, and `Spells` relations describe lexical spans rather
than invoking the recognition function. No native evaluation proof tactic is
used: every theorem is checked by Lean's kernel.
-/

namespace Silver

abbrev Source := List Nat

def whitespace (c : Nat) : Bool := c == 32 || c == 9 || c == 10 || c == 13
def lineEnd (c : Nat) : Bool := c == 10 || c == 13
def identifierCharacter (c : Nat) : Bool :=
  decide ((65 ≤ c ∧ c ≤ 90) ∨ (97 ≤ c ∧ c ≤ 122) ∨
    (48 ≤ c ∧ c ≤ 57) ∨ c = 95)
def lowercase (c : Nat) : Nat := if 65 ≤ c ∧ c ≤ 90 then c + 32 else c
def allowedCharacter (c : Nat) : Bool := decide (32 ≤ c ∧ c ≤ 126) || whitespace c

def commentEnd : Source → Source
  | [] => []
  | c :: text => if lineEnd c then c :: text else commentEnd text

theorem commentEnd_length (text : Source) : (commentEnd text).length ≤ text.length := by
  induction text with
  | nil => simp [commentEnd]
  | cons c text ih =>
    simp only [commentEnd]
    split
    · exact Nat.le_refl _
    · simp only [List.length_cons]
      omega

inductive Comment : Source → Source → Prop
  | eof : Comment [] []
  | stop (c : Nat) (text : Source) : lineEnd c = true → Comment (c :: text) (c :: text)
  | character (c : Nat) (text rest : Source) : lineEnd c = false →
      Comment text rest → Comment (c :: text) rest

theorem comment_sound {text rest : Source} (h : Comment text rest) : commentEnd text = rest := by
  induction h with
  | eof => rfl
  | stop c text h => simp [commentEnd, h]
  | character c text rest h _ ih => simp [commentEnd, h, ih]

theorem comment_complete (text : Source) : Comment text (commentEnd text) := by
  induction text with
  | nil => exact .eof
  | cons c text ih =>
    by_cases h : lineEnd c = true
    · simpa [commentEnd, h] using Comment.stop c text h
    · have hf : lineEnd c = false := Bool.eq_false_iff.mpr h
      simpa [commentEnd, hf] using Comment.character c text (commentEnd text) hf ih

theorem comment_iff (text rest : Source) : Comment text rest ↔ commentEnd text = rest := by
  constructor
  · exact comment_sound
  · intro h
    rw [← h]
    exact comment_complete text

def startsComment : Source → Bool
  | a :: b :: _ => a == 45 && b == 45
  | _ => false

def triviaEnd (text : Source) : Source :=
  match text with
  | [] => []
  | c :: tail =>
    if whitespace c then triviaEnd tail
    else if startsComment (c :: tail) then triviaEnd (commentEnd ((c :: tail).drop 2))
    else c :: tail
termination_by text.length
decreasing_by
  · simp_wf
  · have hc := commentEnd_length ((c :: tail).drop 2)
    simp_all only [List.length_drop, List.length_cons]
    omega

inductive Trivia : Source → Source → Prop
  | eof : Trivia [] []
  | stop (c : Nat) (text : Source) : whitespace c = false →
      startsComment (c :: text) = false → Trivia (c :: text) (c :: text)
  | space (c : Nat) (text rest : Source) : whitespace c = true →
      Trivia text rest → Trivia (c :: text) rest
  | comment (text tail rest : Source) : Comment text tail →
      Trivia tail rest → Trivia (45 :: 45 :: text) rest

theorem trivia_sound {text rest : Source} (h : Trivia text rest) : triviaEnd text = rest := by
  induction h with
  | eof => simp [triviaEnd]
  | stop c text hw hc => simp [triviaEnd, hw, hc]
  | space c text rest hw _ ih => simp [triviaEnd, hw, ih]
  | comment text tail rest hc _ ih =>
    have he := comment_sound hc
    simpa [triviaEnd, whitespace, startsComment, he] using ih

theorem trivia_complete (text : Source) : Trivia text (triviaEnd text) := by
  induction text using triviaEnd.induct with
  | case1 => simpa [triviaEnd] using Trivia.eof
  | case2 c tail hw ih =>
    simpa [triviaEnd, hw] using Trivia.space c tail (triviaEnd tail) hw ih
  | case3 c tail hw hc ih =>
    cases tail with
    | nil => simp [startsComment] at hc
    | cons d tail =>
      have hcd : c = 45 ∧ d = 45 := by
        simpa [startsComment] using hc
      rcases hcd with ⟨rfl, rfl⟩
      have result := Trivia.comment tail (commentEnd tail)
        (triviaEnd (commentEnd tail)) (comment_complete tail) ih
      simpa [triviaEnd, whitespace, startsComment] using result
  | case4 c tail hw hc =>
    have hwb : whitespace c = false := Bool.eq_false_iff.mpr hw
    have hcb : startsComment (c :: tail) = false := Bool.eq_false_iff.mpr hc
    simpa [triviaEnd, hwb, hcb] using Trivia.stop c tail hwb hcb

theorem trivia_iff (text rest : Source) : Trivia text rest ↔ triviaEnd text = rest := by
  constructor
  · exact trivia_sound
  · intro h
    rw [← h]
    exact trivia_complete text

theorem comment_partition {text rest : Source} (h : Comment text rest) :
    ∃ span, text = span ++ rest := by
  induction h with
  | eof => exact ⟨[], rfl⟩
  | stop c text _ => exact ⟨[], rfl⟩
  | character c text rest _ _ ih =>
    obtain ⟨span, hs⟩ := ih
    exact ⟨c :: span, by simp [hs]⟩

theorem trivia_partition {text rest : Source} (h : Trivia text rest) :
    ∃ span, text = span ++ rest := by
  induction h with
  | eof => exact ⟨[], rfl⟩
  | stop c text _ _ => exact ⟨[], rfl⟩
  | space c text rest _ _ ih =>
    obtain ⟨span, hs⟩ := ih
    exact ⟨c :: span, by simp [hs]⟩
  | comment text tail rest hc _ ih =>
    obtain ⟨first, hfirst⟩ := comment_partition hc
    obtain ⟨second, hsecond⟩ := ih
    exact ⟨45 :: 45 :: (first ++ second), by simp [hfirst, hsecond, List.append_assoc]⟩

theorem triviaEnd_length (text : Source) : (triviaEnd text).length ≤ text.length := by
  obtain ⟨span, hs⟩ := trivia_partition (trivia_complete text)
  have hlen := congrArg List.length hs
  simp only [List.length_append] at hlen
  omega

/-- A case-insensitive spelling occupies an exact source span. -/
inductive Spells : Source → Source → Source → Prop
  | nil (text : Source) : Spells [] text text
  | cons (expected actual : Nat) (word text rest : Source) : lowercase actual = expected →
      Spells word text rest → Spells (expected :: word) (actual :: text) rest

def consume : Source → Source → Option Source
  | [], text => some text
  | _ :: _, [] => none
  | expected :: word, actual :: text =>
    if lowercase actual = expected then consume word text else none

theorem consume_iff (word text rest : Source) : consume word text = some rest ↔ Spells word text rest := by
  induction word generalizing text with
  | nil =>
    constructor
    · intro h
      simp only [consume, Option.some.injEq] at h
      subst rest
      exact .nil text
    · intro h
      cases h
      rfl
  | cons expected word ih =>
    cases text with
    | nil =>
      constructor
      · simp [consume]
      · intro h
        cases h
    | cons actual text =>
      by_cases he : lowercase actual = expected
      · simp only [consume, he, ↓reduceIte]
        constructor
        · intro h
          exact .cons expected actual word text rest he ((ih text).mp h)
        · intro h
          cases h with
          | cons _ _ _ _ _ _ hs => exact (ih text).mpr hs
      · constructor
        · simp [consume, he]
        · intro h
          cases h with
          | cons _ _ _ _ _ h _ => exact False.elim (he h)

/-- The relational spelling has the expected literal span decomposition. -/
theorem spells_partition {word text rest : Source} (h : Spells word text rest) :
    ∃ span, text = span ++ rest ∧ span.map lowercase = word := by
  induction h with
  | nil text => exact ⟨[], rfl, rfl⟩
  | cons expected actual word text rest he _ ih =>
    obtain ⟨span, hp, hw⟩ := ih
    exact ⟨actual :: span, by simp [hp], by simp [he, hw]⟩

theorem partition_spells (span rest : Source) : Spells (span.map lowercase) (span ++ rest) rest := by
  induction span with
  | nil => exact .nil rest
  | cons c span ih => exact .cons (lowercase c) c (span.map lowercase) (span ++ rest) rest rfl ih

theorem spells_iff_span (word text rest : Source) : Spells word text rest ↔
    ∃ span, text = span ++ rest ∧ span.map lowercase = word := by
  constructor
  · exact spells_partition
  · rintro ⟨span, rfl, rfl⟩
    exact partition_spells span rest

theorem spells_iff_take_drop (word text rest : Source) : Spells word text rest ↔
    word.length ≤ text.length ∧ (text.take word.length).map lowercase = word ∧
      text.drop word.length = rest := by
  constructor
  · intro h
    obtain ⟨span, rfl, rfl⟩ := spells_partition h
    simp
  · rintro ⟨_, hm, hd⟩
    apply (spells_iff_span word text rest).mpr
    exact ⟨text.take word.length, by rw [← hd, List.take_append_drop], hm⟩

end Silver
