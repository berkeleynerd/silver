import Silver.Current

open Silver

-- Truth dependence of the conservative concatenation range schema.
#eval Silver.maxSourceLength
#eval Silver.Compose.uniformRangeObligations
#eval Silver.Guarded.guaranteedIntegerLast
#eval (Silver.Guarded.RangeObligation.mk 8192 8192).discharge
#eval (Silver.Guarded.RangeObligation.mk 16383 16383).discharge
#eval (Silver.Guarded.RangeObligation.mk 16384 16384).discharge
#eval Silver.Current.uniformObligations.length

example : (Silver.Guarded.RangeObligation.mk 16384 16384).discharge = false := by decide
example : ¬ (Silver.Guarded.RangeObligation.mk 16384 16384).Valid := by
  rw [← Silver.Guarded.RangeObligation.discharge_iff]; decide

-- Generalized (symbolic) uniform schema: valid iff 2L ≤ Integer'Last bound.
theorem uniform_valid_symbolic (L : Nat) (h : 2 * L ≤ Silver.Guarded.guaranteedIntegerLast) :
    (Silver.Guarded.RangeObligation.mk L L).Valid := by
  intro v hv; simp only [Silver.Guarded.guaranteedIntegerLast] at *; omega

-- Exact schema with the String value domain V ≤ Integer'Last of the pinned target.
def targetIntegerLast : Nat := 2147483647
theorem exact_schema_symbolic (V S K C : Nat) (fits : S + K * C ≤ V) (dom : V ≤ targetIntegerLast) :
    ∀ d, d ≤ K * C → S + d ≤ targetIntegerLast := by
  intro d hd; omega

#print axioms Silver.Current.admitted_assurance
#print axioms Silver.Current.automatic_pipeline
#print axioms Silver.Current.uniform_discharge
