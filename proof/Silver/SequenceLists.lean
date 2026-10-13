module

public import Silver.SequenceAdmission

@[expose] public section

/-! Shared finite-list parsing. The stop token is observed but not consumed.
The decreasing premise is precisely the total scanner's recursion guard. -/

namespace Silver.Sequence
open Compose

inductive TailAt (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (Reading : ScanResult → α → ScanResult → Prop) :
    ScanResult → List α → ScanResult → Prop
  | done {scan} : scan.state.position ≠ 0 → tokenAfter text scan.state.position stop ≠ 0 →
      TailAt text read stop Reading scan [] scan
  | next {scan item following rest final} :
      scan.state.position ≠ 0 → tokenAfter text scan.state.position stop = 0 →
      Reading scan item following → read scan = following →
      text.length + 1 - following.state.position < text.length + 1 - scan.state.position →
      TailAt text read stop Reading following rest final →
      TailAt text read stop Reading scan (item :: rest) final

theorem tailAt_positive {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {scan final : ScanResult} {items : List α}
    (parsed : TailAt text read stop Reading scan items final) :
    scan.state.position ≠ 0 ∧ final.state.position ≠ 0 := by
  induction parsed with
  | done positive _ => exact ⟨positive, positive⟩
  | next positive _ _ _ _ _ ih => exact ⟨positive, ih.2⟩

theorem tail_zero (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (scan : ScanResult) (zero : scan.state.position = 0) :
    (tail text read stop scan).state.position = 0 := by
  rw [tail]
  simp [zero, invalidScan, invalidState]

theorem tail_positive {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {scan : ScanResult} (accepted : (tail text read stop scan).state.position ≠ 0) :
    scan.state.position ≠ 0 :=
  fun zero => accepted (tail_zero text read stop scan zero)

theorem tail_complete {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {scan final : ScanResult} {items : List α}
    (parsed : TailAt text read stop Reading scan items final) : tail text read stop scan = final := by
  induction parsed with
  | done positive stopped => rw [tail]; simp [positive, stopped]
  | next positive notStopped _ readSame advancing following ih =>
      have nextPositive := (tailAt_positive following).1
      rw [tail]
      simp only [positive, notStopped, ne_eq, not_true_eq_false, ↓reduceIte, readSame,
        nextPositive, advancing, ↓reduceDIte, ih]

theorem tail_sound (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (Reading : ScanResult → α → ScanResult → Prop)
    (readSound : ∀ scan, (read scan).state.position ≠ 0 → ∃ item, Reading scan item (read scan))
    (scan : ScanResult) (accepted : (tail text read stop scan).state.position ≠ 0) :
    ∃ items, TailAt text read stop Reading scan items (tail text read stop scan) := by
  have positive : scan.state.position ≠ 0 := fun zero => accepted (tail_zero text read stop scan zero)
  by_cases stopped : tokenAfter text scan.state.position stop ≠ 0
  · refine ⟨[], ?_⟩
    rw [tail, ite_eq_right positive, ite_eq_left stopped]
    exact TailAt.done positive stopped
  · have notStopped : tokenAfter text scan.state.position stop = 0 := by simpa using stopped
    have nextPositive : (read scan).state.position ≠ 0 := by
      intro zero
      rw [tail] at accepted
      simp [positive, notStopped, zero, invalidScan, invalidState] at accepted
    have advancing : text.length + 1 - (read scan).state.position <
        text.length + 1 - scan.state.position := by
      by_cases advances : text.length + 1 - (read scan).state.position <
          text.length + 1 - scan.state.position
      · exact advances
      · rw [tail] at accepted
        simp [positive, notStopped, nextPositive, advances, invalidScan, invalidState] at accepted
    have reduced : tail text read stop scan = tail text read stop (read scan) := by
      rw [tail]
      simp [positive, notStopped, nextPositive, advancing]
    obtain ⟨item, first⟩ := readSound scan nextPositive
    obtain ⟨rest, following⟩ := tail_sound text read stop Reading readSound (read scan) (reduced ▸ accepted)
    refine ⟨item :: rest, ?_⟩
    rw [reduced]
    exact .next positive notStopped first rfl advancing following
termination_by text.length + 1 - scan.state.position

theorem tail_unique {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop}
    (readUnique : ∀ {scan left right first second}, Reading scan left first →
      Reading scan right second → left = right ∧ first = second)
    {scan : ScanResult} {left right : List α} {first second : ScanResult}
    (a : TailAt text read stop Reading scan left first)
    (b : TailAt text read stop Reading scan right second) : left = right ∧ first = second := by
  induction a generalizing right second with
  | done _ stopped =>
      cases b with
      | done => exact ⟨rfl, rfl⟩
      | next _ notStopped => exact False.elim (stopped notStopped)
  | next _ notStopped first _ _ _ ih =>
      cases b with
      | done _ stopped => exact False.elim (stopped notStopped)
      | next _ _ second _ _ following =>
          obtain ⟨rfl, rfl⟩ := readUnique first second
          obtain ⟨rfl, rfl⟩ := ih following
          exact ⟨rfl, rfl⟩

inductive NonemptyAt (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (Reading : ScanResult → α → ScanResult → Prop) :
    ScanResult → List α → ScanResult → Prop
  | cons {scan item following rest final} :
      Reading scan item following → read scan = following →
      TailAt text read stop Reading following rest final →
      NonemptyAt text read stop Reading scan (item :: rest) final

theorem nonempty_items {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {scan final : ScanResult} {items : List α}
    (parsed : NonemptyAt text read stop Reading scan items final) : items ≠ [] := by
  cases parsed
  simp

theorem nonempty_sound (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (Reading : ScanResult → α → ScanResult → Prop)
    (readSound : ∀ scan, (read scan).state.position ≠ 0 → ∃ item, Reading scan item (read scan))
    (scan : ScanResult) (accepted : (tail text read stop (read scan)).state.position ≠ 0) :
    ∃ items, NonemptyAt text read stop Reading scan items (tail text read stop (read scan)) := by
  obtain ⟨rest, following⟩ := tail_sound text read stop Reading readSound (read scan) accepted
  obtain ⟨item, first⟩ := readSound scan (tailAt_positive following).1
  exact ⟨item :: rest, .cons first rfl following⟩

theorem nonempty_complete {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {scan final : ScanResult} {items : List α}
    (parsed : NonemptyAt text read stop Reading scan items final) :
    tail text read stop (read scan) = final := by
  cases parsed with
  | cons _ readSame following => rw [readSame]; exact tail_complete following

theorem nonempty_unique {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop}
    (readUnique : ∀ {scan left right first second}, Reading scan left first →
      Reading scan right second → left = right ∧ first = second)
    {scan : ScanResult} {left right : List α} {first second : ScanResult}
    (a : NonemptyAt text read stop Reading scan left first)
    (b : NonemptyAt text read stop Reading scan right second) : left = right ∧ first = second := by
  cases a with
  | cons a _ first =>
      cases b with
      | cons b _ second =>
          obtain ⟨rfl, rfl⟩ := readUnique a b
          obtain ⟨rfl, rfl⟩ := tail_unique (Reading := Reading) readUnique first second
          exact ⟨rfl, rfl⟩

theorem tail_preserves {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {Invariant : ScanResult → Prop} {Valid : α → Prop}
    (preserves : ∀ {scan item following}, Reading scan item following → Invariant scan →
      Invariant following ∧ Valid item)
    {scan final : ScanResult} {items : List α}
    (parsed : TailAt text read stop Reading scan items final) (initial : Invariant scan) :
    Invariant final ∧ ∀ item ∈ items, Valid item := by
  induction parsed with
  | done => exact ⟨initial, by simp⟩
  | next _ _ first _ _ _ ih =>
      have head := preserves first initial
      have rest := ih head.1
      refine ⟨rest.1, ?_⟩
      intro item member
      rcases List.mem_cons.mp member with rfl | member
      · exact head.2
      · exact rest.2 item member

theorem nonempty_preserves {text : Source} {read : ScanResult → ScanResult} {stop : ShellToken}
    {Reading : ScanResult → α → ScanResult → Prop} {Invariant : ScanResult → Prop} {Valid : α → Prop}
    (preserves : ∀ {scan item following}, Reading scan item following → Invariant scan →
      Invariant following ∧ Valid item)
    {scan final : ScanResult} {items : List α}
    (parsed : NonemptyAt text read stop Reading scan items final) (initial : Invariant scan) :
    Invariant final ∧ ∀ item ∈ items, Valid item := by
  cases parsed with
  | cons first _ following =>
      have head := preserves first initial
      have rest := tail_preserves (Reading := Reading) (Invariant := Invariant) (Valid := Valid)
        preserves following head.1
      refine ⟨rest.1, ?_⟩
      intro item member
      rcases List.mem_cons.mp member with rfl | member
      · exact head.2
      · exact rest.2 item member

end Silver.Sequence
