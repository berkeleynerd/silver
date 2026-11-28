module

public import Silver.ApplicationPackageDeclarationsExecution
public import Silver.ApplicationPackageObjectCursors

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings

/-- Body-name spans in a one-based segment of the original parameter table.
The upper bound is the cursor just after the part of the signature read so far. -/
structure BodyFormalOrder (info : Metadata) (first count lower upper : Nat) : Prop where
  span : ∀ i, i < count →
    let name := (info.parameterAt (first + i)).bodyName
    0 < name.first ∧ lower ≤ name.first ∧ name.first < name.after ∧ name.after < upper
  before : ∀ i j, i < j → j < count →
    (info.parameterAt (first + i)).bodyName.after < (info.parameterAt (first + j)).bodyName.first

namespace BodyFormalOrder

theorem empty (info : Metadata) (first lower upper : Nat) : BodyFormalOrder info first 0 lower upper :=
  ⟨fun _ h => (Nat.not_lt_zero _ h).elim, fun _ _ _ h => (Nat.not_lt_zero _ h).elim⟩

theorem widen {info : Metadata} {first count lower upper next : Nat}
    (order : BodyFormalOrder info first count lower upper) (moves : upper ≤ next) :
    BodyFormalOrder info first count lower next := by
  refine ⟨?_, order.before⟩
  intro i contained
  obtain ⟨positive, begins, valid, ends⟩ := order.span i contained
  exact ⟨positive, begins, valid, Nat.lt_of_lt_of_le ends moves⟩

/-- Writing the next one-based completion slot retains every earlier body
name. The consumed type and separator put the next cursor past the new name. -/
theorem write {info : Metadata} {first count lower upper next : Nat}
    (order : BodyFormalOrder info first count lower upper)
    (slotPositive : 0 < first) (inside : first + count ≤ info.parameters.length)
    (parameter : Formal) (positive : 0 < parameter.bodyName.first)
    (starts : upper ≤ parameter.bodyName.first) (valid : parameter.bodyName.first < parameter.bodyName.after)
    (ends : parameter.bodyName.after < next) (entered : lower ≤ upper) :
    BodyFormalOrder {info with parameters := info.parameters.set (first + count - 1) parameter}
      first (count + 1) lower next := by
  let updated := {info with parameters := info.parameters.set (first + count - 1) parameter}
  have earlier (i : Nat) (previous : i < count) :
      updated.parameterAt (first + i) = info.parameterAt (first + i) := by
    have distinct : first + count - 1 ≠ first + i - 1 := by omega
    simp only [updated, Metadata.parameterAt, List.getD_eq_getElem?_getD, List.getElem?_set_ne distinct]
  have last : updated.parameterAt (first + count) = parameter := by
    have inTable : first + count - 1 < info.parameters.length := by omega
    simp only [updated, Metadata.parameterAt, List.getD_eq_getElem?_getD,
      List.getElem?_set_self inTable, Option.getD_some]
  change BodyFormalOrder updated first (count + 1) lower next
  constructor
  · intro i contained
    dsimp only
    by_cases previous : i < count
    · rw [earlier i previous]
      exact (order.widen (Nat.le_of_lt (Nat.lt_of_le_of_lt starts (Nat.lt_trans valid ends)))).span i previous
    · have equal : i = count := by omega
      rw [equal, last]
      exact ⟨positive, Nat.le_trans entered starts, valid, ends⟩
  · intro i j ordered contained
    have prior : i < count := by omega
    rw [earlier i prior]
    by_cases previous : j < count
    · rw [earlier j previous]
      exact order.before i j ordered previous
    · have equal : j = count := by omega
      rw [equal, last]
      exact Nat.lt_of_lt_of_le (order.span i prior).2.2.2 starts

end BodyFormalOrder

namespace FormalSpanRead
open ApplicationPackageObjectRows

/-- The mode words have passed the colon. This covers all three successful
choices of the original reader, including its separate second word in "in out". -/
def mode (text : Source) (last : Nat) : Nat × ProcedureBindings.Mode :=
  let colon := fixedAfter text last ":" false
  let inputEnd := fixedAfter text colon "in" true
  if inputEnd ≠ 0 then
    let outputEnd := fixedAfter text inputEnd "out" true
    ⟨if outputEnd ≠ 0 then outputEnd else inputEnd, if outputEnd ≠ 0 then .inputOutput else .input⟩
  else ⟨fixedAfter text colon "out" true, .output⟩

theorem mode_window {text : Source} {last : Nat} (present : (mode text last).1 ≠ 0) :
    last < (mode text last).1 ∧ (mode text last).1 ≤ text.length + 1 := by
  let colonEnd := fixedAfter text last ":" false
  let inputEnd := fixedAfter text colonEnd "in" true
  by_cases input : inputEnd ≠ 0
  · let outputEnd := fixedAfter text inputEnd "out" true
    have colon := fixed_window (by decide) (fixedAfter_nonzero input)
    have parsed := fixed_window (by decide) input
    dsimp only [inputEnd, colonEnd] at input
    by_cases output : outputEnd ≠ 0
    · dsimp only [outputEnd, inputEnd, colonEnd] at output
      simp only [mode, ite_eq_left input, ite_eq_left output]
      have finish := fixed_window (by decide) output
      exact ⟨Nat.lt_trans colon.1 (Nat.lt_trans parsed.1 finish.1), finish.2⟩
    · dsimp only [outputEnd, inputEnd, colonEnd] at output
      simp only [mode, ite_eq_left input, ite_eq_right output]
      exact ⟨Nat.lt_trans colon.1 parsed.1, parsed.2⟩
  · dsimp only [inputEnd, colonEnd] at input
    simp only [mode, ite_eq_right input] at present ⊢
    have colon := fixed_window (by decide) (fixedAfter_nonzero present)
    have parsed := fixed_window (by decide) present
    exact ⟨Nat.lt_trans colon.1 parsed.1, parsed.2⟩

theorem append_position (frame : ParserState) (name : NameSpan) (mark : ApplicationPackageNames.PackageTypeResult)
    (direction : ProcedureBindings.Mode) (present : (appendFormal frame name mark direction).position ≠ 0) :
    (appendFormal frame name mark direction).position = frame.position := by
  unfold appendFormal at present ⊢
  split
  · rfl
  · split
    · rfl
    · rename_i unavailable
      simp_all

end FormalSpanRead
end Silver.ApplicationPackageDeclarations
