import Silver.Current
open Silver

/-! T2 probe: (1) the conservative uniform String range schema is truth-dependent on the
bound; the exact schema is not. (2) A resource-indexed tool contract in which solver
completion is "given sufficient resources", with resource exhaustion as the only
non-completion outcome, is expressible over the existing `Current` definitions and
jointly inhabited. Nothing here changes the project. -/

namespace T2

-- (1a) Current uniform schema ⟨L, L⟩ is valid exactly when 2L ≤ 32767.
theorem uniform_iff (L : Nat) :
    (Guarded.RangeObligation.mk L L).Valid ↔ 2 * L ≤ Guarded.guaranteedIntegerLast := by
  constructor
  · intro h; have := h L (Nat.le_refl _); simp only [Guarded.guaranteedIntegerLast] at *; omega
  · intro h v hv; simp only [Guarded.guaranteedIntegerLast] at *; omega

example : ¬ (Guarded.RangeObligation.mk 16384 16384).Valid := by
  rw [uniform_iff]; decide

-- (1b) Exact schema: admission's own bound S + K*C ≤ V, with V at most the target's
-- Integer'Last, discharges every concatenation range check (including intermediates,
-- since every prefix has smaller coefficients) for every V up to Integer'Last.
def pinnedIntegerLast : Nat := 2147483647

theorem exact_schema (V S K C : Nat) (fits : S + K * C ≤ V) (target : V ≤ pinnedIntegerLast) :
    ∀ S' K' d, S' ≤ S → K' ≤ K → d ≤ C → S' + K' * d ≤ pinnedIntegerLast := by
  intro S' K' d hS hK hd
  have : K' * d ≤ K * C := Nat.mul_le_mul hK hd
  omega

-- (2) Resource-indexed external contract.
inductive ProofOutcome | proved | exhausted
  deriving DecidableEq

structure ResourceTools (Artifact : Type) where
  base : Current.Tools Artifact
  /-- `prove checks r` is the solver run with resource allowance `r` (steps, memory,
  time folded into one monotone index). -/
  prove : List Predicate.Check → Nat → ProofOutcome

theorem check_discharge_valid (c : Predicate.Check) (h : c.discharge = true) : c.Valid := by
  cases c with
  | declaration d => exact (Compose.Check.discharge_iff d).mp h
  | scalarDeclaration o => exact Integer.Obligation.discharge_sound h
  | path o => exact Predicate.Obligation.discharge_sound h

structure ResourceContract {Artifact : Type} (tools : ResourceTools Artifact) : Prop where
  /-- Every other external premise is unchanged. -/
  base : Current.ToolContract tools.base
  /-- Soundness: `proved` is reported only for valid obligations. -/
  sound : ∀ checks r, tools.prove checks r = .proved → ∀ c ∈ checks, c.Valid
  /-- Completion given sufficient resources, monotone in the allowance. No fixed
  allowance appears; exhaustion is the only other outcome. -/
  eventually : ∀ checks, Current.BoundedFragment checks →
    ∃ r₀, ∀ r, r₀ ≤ r → tools.prove checks r = .proved

theorem resource_pipeline {Artifact : Type} {tools : ResourceTools Artifact}
    (contract : ResourceContract tools) {source : Source} (member : Current.Member source) :
    ∃ program checks steps, Current.SourceMeaning source program ∧
      tools.base.generate program checks steps ∧
      ∃ r₀, ∀ r, r₀ ≤ r → tools.prove checks r = .proved := by
  obtain ⟨program, meaning⟩ := Current.member_has_meaning member
  obtain ⟨checks, steps, generated⟩ := contract.base.generationCompletes program
  exact ⟨program, checks, steps, meaning, generated,
    contract.eventually checks (Current.generated_fragment contract.base meaning generated)⟩

/-- At any allowance the proof stage either proves or reports exhaustion;
nonmembership is never an outcome of the proof stage. -/
theorem outcome_dichotomy {Artifact : Type} (tools : ResourceTools Artifact)
    (checks : List Predicate.Check) (r : Nat) :
    tools.prove checks r = .proved ∨ tools.prove checks r = .exhausted := by
  cases tools.prove checks r <;> simp

def modelResourceTools : ResourceTools Current.Program where
  base := Current.modelTools
  prove := fun checks r =>
    if checks.length + 1 ≤ r ∧ checks.all Predicate.Check.discharge = true then .proved else .exhausted

theorem model_resource_contract : ResourceContract modelResourceTools where
  base := Current.model_tool_contract
  sound := by
    intro checks r h c mem
    simp only [modelResourceTools] at h
    split at h
    · rename_i hc
      exact check_discharge_valid c (List.all_eq_true.mp hc.2 c mem)
    · cases h
  eventually := by
    intro checks fragment
    refine ⟨checks.length + 1, fun r hr => ?_⟩
    simp only [modelResourceTools]
    rw [if_pos]
    exact ⟨hr, List.all_eq_true.mpr fun c mem => Predicate.Check.fragment_discharge (fragment c mem)⟩

#print axioms resource_pipeline
#print axioms model_resource_contract
#print axioms exact_schema
#print axioms uniform_iff

end T2
