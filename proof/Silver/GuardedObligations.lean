import Silver.GuardedSemantics
import Silver.Semantics

/-! Arithmetic schemas for the actual dynamic concatenation range checks.
`Valid` quantifies over every possible selected argument length; the finite
checker eliminates that quantifier by its maximum. This is a mathematical
decision procedure, not an implementation of CVC5/Z3/Alt-Ergo. Correspondence
to actual generated verification conditions and the pinned tools' completion
on this fragment remain explicit external-tool premises in `Current`.

Two mathematical schemas describe Ada's two left-associated concatenations.
GNAT can merge or remove checks, so their number is not a report-record count.
The stronger runtime capacity guard proves the 4096-byte output effect domain;
it is unnecessary for the conservative 12288-byte arithmetic bound itself. -/

namespace Silver.Guarded

/-- Ada guarantees at least this positive Integer bound. Every supported GNAT
target has a larger bound, so no stronger target-width assumption is needed. -/
def guaranteedIntegerLast : Nat := 32767

structure RangeObligation where
  fixedLength : Nat
  variableBound : Nat
  deriving DecidableEq, Repr

def RangeObligation.Valid (check : RangeObligation) : Prop :=
  ∀ variableLength, variableLength ≤ check.variableBound →
    check.fixedLength + variableLength ≤ guaranteedIntegerLast

def RangeObligation.discharge (check : RangeObligation) : Bool :=
  decide (check.fixedLength + check.variableBound ≤ guaranteedIntegerLast)

theorem RangeObligation.discharge_iff (check : RangeObligation) :
    check.discharge = true ↔ check.Valid := by
  simp only [discharge, decide_eq_true_eq, Valid]
  constructor
  · intro bounded variableLength domain
    omega
  · intro valid
    exact valid check.variableBound (Nat.le_refl _)

/-- The owned initializer returns a String with First=1. Admitted literals have
First=1 as well. A null result is the legal range 1..0; nonempty result indices
and intermediate length sums fit Integer whenever this schema is valid. -/
theorem RangeObligation.bounds {check : RangeObligation} (valid : check.Valid)
    (variableLength : Nat) (domain : variableLength ≤ check.variableBound) :
    check.fixedLength + variableLength ≤ guaranteedIntegerLast ∧
    (if check.fixedLength + variableLength = 0 then 0
      else 1 + (check.fixedLength + variableLength - 1)) ≤ guaranteedIntegerLast := by
  have bounded := valid variableLength domain
  constructor
  · exact bounded
  · split <;> omega

def rangeObligations (program : Program) : List RangeObligation :=
  [⟨program.leading.length, maxSourceLength⟩,
   ⟨program.leading.length + program.trailing.length, maxSourceLength⟩]

def uniformRangeObligations : List RangeObligation :=
  [⟨maxSourceLength, maxSourceLength⟩, ⟨maxSourceLength + maxSourceLength, maxSourceLength⟩]

/-- Coefficient domination is independent of solver success. It establishes
that each program-specific range schema lies within the uniformly checked one. -/
def RangeObligation.Refines (check upper : RangeObligation) : Prop :=
  check.fixedLength ≤ upper.fixedLength ∧ check.variableBound ≤ upper.variableBound

theorem RangeObligation.valid_of_refines {check upper : RangeObligation}
    (bounded : check.Refines upper) (valid : upper.Valid) : check.Valid := by
  intro variableLength domain
  have parent := valid variableLength (by unfold Refines at bounded; omega)
  unfold Refines at bounded
  omega

theorem uniform_range_valid : ∀ check ∈ uniformRangeObligations, check.Valid := by
  intro check member
  simp only [uniformRangeObligations, List.mem_cons, List.not_mem_nil, or_false] at member
  rcases member with rfl | rfl <;>
    exact (RangeObligation.discharge_iff _).mp (by decide +kernel)

theorem obligations_refine_uniform {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    ∀ check ∈ rangeObligations program,
      ∃ upper ∈ uniformRangeObligations, check.Refines upper := by
  have combined := literal_bounds meaning
  have sourceBound := meaning.1.2.1
  intro check member
  simp only [rangeObligations, List.mem_cons, List.not_mem_nil, or_false] at member
  rcases member with rfl | rfl
  · refine ⟨⟨maxSourceLength, maxSourceLength⟩, by simp [uniformRangeObligations], ?_⟩
    simp only [RangeObligation.Refines]
    constructor <;> omega
  · refine ⟨⟨maxSourceLength + maxSourceLength, maxSourceLength⟩, by simp [uniformRangeObligations], ?_⟩
    simp only [RangeObligation.Refines]
    constructor <;> omega

theorem range_obligations_valid {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : ∀ check ∈ rangeObligations program, check.Valid := by
  intro check member
  obtain ⟨upper, present, bounded⟩ := obligations_refine_uniform meaning check member
  exact RangeObligation.valid_of_refines bounded (uniform_range_valid upper present)

def RangeObligation.toObligation (check : RangeObligation) : Semantics.Obligation :=
  ⟨.runTimeSafety, check.discharge⟩

def obligations (program : Program) : List Semantics.Obligation :=
  (rangeObligations program).map RangeObligation.toObligation

def uniformObligations : List Semantics.Obligation :=
  uniformRangeObligations.map RangeObligation.toObligation

theorem uniform_discharge : Semantics.discharge uniformObligations = true := by decide +kernel

theorem all_obligations_discharge {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : Semantics.discharge (obligations program) = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check member
  obtain ⟨range, present, rfl⟩ := List.mem_map.mp member
  exact (RangeObligation.discharge_iff _).mpr (range_obligations_valid meaning range present)

theorem selected_range_bounds {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (arguments : Arguments.Runtime.Arguments) :
    program.leading.length + (selected arguments program).length ≤ guaranteedIntegerLast ∧
    program.leading.length + (selected arguments program).length + program.trailing.length ≤ guaranteedIntegerLast := by
  have domain := (Arguments.Runtime.message_iff _).mp
    (Arguments.Runtime.initializer_domain arguments program.defaultValue)
  have first := range_obligations_valid meaning ⟨program.leading.length, maxSourceLength⟩
    (by simp [rangeObligations]) (selected arguments program).length domain.1
  have last := range_obligations_valid meaning ⟨program.leading.length + program.trailing.length, maxSourceLength⟩
    (by simp [rangeObligations]) (selected arguments program).length domain.1
  change program.leading.length + (selected arguments program).length ≤ guaranteedIntegerLast at first
  change program.leading.length + program.trailing.length + (selected arguments program).length ≤ guaranteedIntegerLast at last
  exact ⟨first, by omega⟩

end Silver.Guarded
