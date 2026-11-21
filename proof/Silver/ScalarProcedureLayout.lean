module

public import Silver.ScalarProcedureDefinition

@[expose] public section

/-! The generated return reads follow solely from the grouped parameter
layout. Their admission requires no statement result or semantic output oracle. -/
namespace Silver.ScalarProcedures
open ScalarFunctions (Target ScalarType)

def parameterTargets : Nat → Nat → List Formal → List Target
  | _, _, [] => []
  | i, b, ⟨_, .integer bounds⟩ :: rest =>
      .integer (i + 1) bounds :: parameterTargets (i + 1) b rest
  | i, b, ⟨_, .array _⟩ :: rest => parameterTargets i b rest
  | i, b, ⟨_, .boolean⟩ :: rest => .boolean (b + 1) :: parameterTargets i (b + 1) rest

theorem parameterAnalysis_preserves {identity count : Nat} (inside : identity ≤ count)
    (formals : List Formal) (analysis : Integer.Analysis) :
    (parameterAnalysis count formals analysis).declared identity = analysis.declared identity := by
  induction formals generalizing count analysis with
  | nil => rfl
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      cases domain with
      | integer bounds =>
          have kept := ih (count := count + 1) (by omega)
            ⟨Integer.put analysis.declared (count + 1) (some bounds),
              Integer.put analysis.mutable (count + 1) (mode != .input),
              Integer.put analysis.static (count + 1) false,
              Integer.put analysis.refinable (count + 1) true⟩
          simpa only [parameterAnalysis, Integer.put, show identity ≠ count + 1 by omega, ↓reduceIte] using kept
      | boolean | array _ => exact ih inside analysis

theorem parameterBooleans_preserves {identity count : Nat} (inside : identity ≤ count)
    (formals : List Formal) (analysis : Boolean.Analysis) :
    (parameterBooleans count formals analysis).initialized identity = analysis.initialized identity := by
  induction formals generalizing count analysis with
  | nil => rfl
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      cases domain with
      | integer _ | array _ => exact ih inside analysis
      | boolean =>
          have kept := ih (count := count + 1) (by omega) (analysis.initialize (count + 1) (mode != .input))
          simpa only [parameterBooleans, Boolean.Analysis.initialize,
            show identity ≠ count + 1 by omega, ↓reduceIte] using kept

def TargetKnown (analysis : Integer.Analysis) (booleans : Boolean.Analysis) : Target → Prop
  | .integer identity bounds => analysis.declared identity = some bounds ∧
      bounds.Bounded ∧ bounds.lower ≤ bounds.upper
  | .boolean identity => booleans.initialized identity = true

def TargetWithin (i b : Nat) : Target → Prop
  | .integer identity _ => identity ≤ i
  | .boolean identity => identity ≤ b

theorem parameterTargets_known (i b : Nat) (formals : List Formal)
    (analysis : Integer.Analysis) (booleans : Boolean.Analysis)
    (valid : ∀ formal ∈ formals, formal.domain.Valid) :
    ∀ target ∈ parameterTargets i b formals,
      TargetKnown (parameterAnalysis i formals analysis) (parameterBooleans b formals booleans) target := by
  induction formals generalizing i b analysis booleans with
  | nil => simp [parameterTargets]
  | cons formal rest ih =>
      have first := valid formal (by simp)
      have remaining : ∀ other ∈ rest, other.domain.Valid := fun other present => valid other (by simp [present])
      rcases formal with ⟨mode, domain⟩
      cases domain with
      | integer bounds =>
          intro target present
          rcases List.mem_cons.mp present with rfl | present
          · refine ⟨?_, first⟩
            simpa only [parameterAnalysis, Integer.put, ↓reduceIte] using
              parameterAnalysis_preserves (Nat.le_refl (i + 1)) rest
                ⟨Integer.put analysis.declared (i + 1) (some bounds),
                  Integer.put analysis.mutable (i + 1) (mode != .input),
                  Integer.put analysis.static (i + 1) false,
                  Integer.put analysis.refinable (i + 1) true⟩
          · exact ih (i + 1) b _ booleans remaining target present
      | boolean =>
          intro target present
          rcases List.mem_cons.mp present with rfl | present
          · simpa only [TargetKnown, parameterBooleans, Boolean.Analysis.initialize, ↓reduceIte] using
              parameterBooleans_preserves (Nat.le_refl (b + 1)) rest
                (booleans.initialize (b + 1) (mode != .input))
          · exact ih i (b + 1) analysis _ remaining target present
      | array _ => exact ih i b analysis booleans remaining

theorem parameterTargets_within (i b : Nat) (formals : List Formal) :
    ∀ target ∈ parameterTargets i b formals,
      TargetWithin (i + integerCount (formals.map Formal.domain))
        (b + booleanCount (formals.map Formal.domain)) target := by
  induction formals generalizing i b with
  | nil => simp [parameterTargets]
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      cases domain with
      | integer bounds =>
          intro target present
          rcases List.mem_cons.mp present with rfl | present
          · simp only [TargetWithin, List.map_cons, integerCount]
            omega
          · have within := ih (i + 1) b target present
            cases target <;> simp_all [TargetWithin, integerCount, booleanCount, Nat.add_assoc, Nat.add_comm]
      | boolean =>
          intro target present
          rcases List.mem_cons.mp present with rfl | present
          · simp only [TargetWithin, List.map_cons, booleanCount]
            omega
          · have within := ih i (b + 1) target present
            cases target <;> simp_all [TargetWithin, integerCount, booleanCount, Nat.add_assoc, Nat.add_comm]
      | array _ => exact ih i b

theorem targetKnown_preserved {i b : Nat} {target : Target} (within : TargetWithin i b target)
    (formals : List Formal) {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    (known : TargetKnown analysis booleans target) :
    TargetKnown (parameterAnalysis i formals analysis) (parameterBooleans b formals booleans) target := by
  cases target with
  | integer identity bounds => exact ⟨(parameterAnalysis_preserves within formals analysis).trans known.1, known.2⟩
  | boolean identity => exact (parameterBooleans_preserves within formals booleans).trans known

theorem inputFormals_valid {formals : List Formal}
    (valid : ∀ formal ∈ formals, formal.domain.Valid) :
    ∀ formal ∈ inputFormals formals, formal.domain.Valid := by
  induction formals with
  | nil => simp [inputFormals]
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      have remaining := ih (fun other present => valid other (by simp [present]))
      cases mode <;> simp_all [inputFormals]

theorem outFormals_valid {formals : List Formal}
    (valid : ∀ formal ∈ formals, formal.domain.Valid) :
    ∀ formal ∈ outFormals formals, formal.domain.Valid := by
  induction formals with
  | nil => simp [outFormals]
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      have remaining := ih (fun other present => valid other (by simp [present]))
      cases mode <;> simp_all [outFormals]

theorem outputTargets_members (i b oi ob : Nat) (formals : List Formal) :
    ∀ target ∈ outputTargets i b oi ob formals,
      target ∈ parameterTargets i b (inputFormals formals) ∨
      target ∈ parameterTargets oi ob (outFormals formals) := by
  induction formals generalizing i b oi ob with
  | nil => simp [outputTargets]
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      cases mode <;> cases domain
      all_goals
        simp only [outputTargets, inputFormals, outFormals, parameterTargets, List.mem_cons]
        intro target present
        first
        | exact ih i b oi ob target present
        | rcases present with rfl | present
          · simp
          · first
            | exact (ih _ _ _ _ target present).imp (fun member => Or.inr member) id
            | exact (ih _ _ _ _ target present).imp id (fun member => Or.inr member)
        | exact (ih _ _ _ _ target present).imp (fun member => Or.inr member) id

theorem Definition.outputTargets_known (definition : Definition)
    (valid : ∀ formal ∈ definition.signature.formals, formal.domain.Valid) :
    ∀ target ∈ definition.outputTargets, TargetKnown definition.analysis definition.booleanAnalysis target := by
  intro target present
  rcases outputTargets_members _ _ _ _ _ target present with input | output
  · have within : TargetWithin definition.inputIntegerCount definition.inputBooleanCount target := by
      simpa only [inputFormals_domains, inputIntegerCount, inputBooleanCount] using
        parameterTargets_within definition.integers.length definition.booleans.length
          (inputFormals definition.signature.formals) target input
    have known : TargetKnown definition.inputAnalysis definition.inputBooleanAnalysis target :=
      parameterTargets_known _ _ _ _ _ (inputFormals_valid valid) target input
    exact targetKnown_preserved within (outFormals definition.signature.formals) known
  · exact parameterTargets_known _ _ _ _ _ (outFormals_valid valid) target output

theorem targetRead_checked {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {target : Target} (known : TargetKnown analysis booleans target) :
    (targetRead target).check Bindings.emptyShape analysis
      ⟨ScalarFunctions.entryContext, analysis.declared⟩ booleans (targetType target) = true := by
  cases target with
  | integer identity bounds =>
      have nonempty := Integer.Interval.contains_nonempty (show bounds.Contains bounds.lower from ⟨Int.le_refl _, known.2.2⟩)
      simp [targetRead, targetType, ScalarFunctions.Actual.check, Integer.Expr.infer, known.1,
        Integer.checked, Integer.accepted, nonempty, known.2.1, Integer.Interval.included]
  | boolean identity => exact known

theorem targetRead_readable {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {target : Target} (known : TargetKnown analysis booleans target) :
    (targetRead target).Readable false Bindings.emptyShape booleans := by
  cases target with
  | integer => trivial
  | boolean => exact ⟨trivial, known⟩

theorem targetsRead_checked {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {targets : List Target} (known : ∀ target ∈ targets, TargetKnown analysis booleans target) :
    ScalarFunctions.checkActuals Bindings.emptyShape analysis
      ⟨ScalarFunctions.entryContext, analysis.declared⟩ booleans
      (targets.map targetType) (targets.map targetRead) = true := by
  induction targets with
  | nil => rfl
  | cons target targets ih =>
      have first := targetRead_checked (known target (by simp))
      have rest := ih (fun other present => known other (by simp [present]))
      simp only [List.map_cons, ScalarFunctions.checkActuals, first, rest, Bool.and_self]

theorem Definition.outputCheck_of_layout (definition : Definition)
    (valid : ∀ formal ∈ definition.signature.formals, formal.domain.Valid ∧
      (formal.mode = .input ∨ formal.domain.IsScalar)) :
    definition.outputCheck = true := by
  have checked := targetsRead_checked (definition.outputTargets_known (fun f h => (valid f h).1))
  have domains := outputTargets_types definition.integers.length definition.booleans.length
    definition.inputIntegerCount definition.inputBooleanCount definition.signature.formals
    (fun f h => (valid f h).2)
  simpa only [Definition.outputCheck, Definition.outputReads, Definition.outputTargets,
    domains, Definition.initialFlow] using checked

theorem Definition.outputReads_readable (definition : Definition)
    (valid : ∀ formal ∈ definition.signature.formals, formal.domain.Valid) :
    ∀ actual ∈ definition.outputReads, actual.Readable false Bindings.emptyShape definition.booleanAnalysis := by
  intro actual present
  obtain ⟨target, member, rfl⟩ := List.mem_map.mp present
  exact targetRead_readable (definition.outputTargets_known valid target member)

end Silver.ScalarProcedures
