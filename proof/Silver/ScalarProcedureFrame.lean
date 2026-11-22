module

public import Silver.ScalarProcedureExecution
public import Silver.ScalarFunctionFrame

@[expose] public section

namespace Silver.ScalarProcedures
open ScalarFunctions (ScalarType Target Frame)

def inputFormals : List Formal → List Formal
  | [] => []
  | ⟨.output, _⟩ :: rest => inputFormals rest
  | formal :: rest => formal :: inputFormals rest

def outFormals : List Formal → List Formal
  | [] => []
  | ⟨.output, domain⟩ :: rest => ⟨.output, domain⟩ :: outFormals rest
  | _ :: rest => outFormals rest

@[simp] theorem inputFormals_domains (formals : List Formal) :
    (inputFormals formals).map Formal.domain = inputTypes formals := by
  induction formals with
  | nil => rfl
  | cons formal rest ih => rcases formal with ⟨mode, domain⟩; cases mode <;> simp [inputFormals, inputTypes, ih]

@[simp] theorem outFormals_domains (formals : List Formal) :
    (outFormals formals).map Formal.domain = outTypes formals := by
  induction formals with
  | nil => rfl
  | cons formal rest ih => rcases formal with ⟨mode, domain⟩; cases mode <;> simp [outFormals, outTypes, ih]

def integerCount : List ScalarType → Nat
  | [] => 0
  | .integer _ :: rest => integerCount rest + 1
  | .boolean :: rest | .array _ :: rest => integerCount rest

def booleanCount : List ScalarType → Nat
  | [] => 0
  | .integer _ :: rest | .array _ :: rest => booleanCount rest
  | .boolean :: rest => booleanCount rest + 1

def parameterAnalysis : Nat → List Formal → Integer.Analysis → Integer.Analysis
  | count, ⟨mode, .integer bounds⟩ :: rest, analysis =>
      parameterAnalysis (count + 1) rest
        ⟨Integer.put analysis.declared (count + 1) (some bounds),
          Integer.put analysis.mutable (count + 1) (mode != .input),
          Integer.put analysis.static (count + 1) false,
          Integer.put analysis.refinable (count + 1) true⟩
  | count, ⟨_, .boolean⟩ :: rest, analysis
  | count, ⟨_, .array _⟩ :: rest, analysis => parameterAnalysis count rest analysis
  | _, [], analysis => analysis

def parameterBooleans : Nat → List Formal → Boolean.Analysis → Boolean.Analysis
  | count, ⟨_, .integer _⟩ :: rest, analysis
  | count, ⟨_, .array _⟩ :: rest, analysis => parameterBooleans count rest analysis
  | count, ⟨mode, .boolean⟩ :: rest, analysis =>
      parameterBooleans (count + 1) rest (analysis.initialize (count + 1) (mode != .input))
  | _, [], analysis => analysis

theorem parameterAnalysis_declared (count : Nat) (formals : List Formal) (analysis : Integer.Analysis) :
    (parameterAnalysis count formals analysis).declared =
      ScalarFunctions.parameterRanges count (formals.map Formal.domain) analysis.declared := by
  induction formals generalizing count analysis with
  | nil => rfl
  | cons formal rest ih =>
      rcases formal with ⟨mode, domain⟩
      cases domain <;> simp [parameterAnalysis, ScalarFunctions.parameterRanges, ih]

/-- Storage groups inputs before outputs, while the exported tuple retains the
original formal order. Each scalar kind has its own independent identity space. -/
def outputTargets : Nat → Nat → Nat → Nat → List Formal → List Target
  | _, _, _, _, [] => []
  | i, b, oi, ob, ⟨.input, .integer _⟩ :: rest => outputTargets (i + 1) b oi ob rest
  | i, b, oi, ob, ⟨.input, .boolean⟩ :: rest => outputTargets i (b + 1) oi ob rest
  | i, b, oi, ob, ⟨.inputOutput, .integer bounds⟩ :: rest =>
      .integer (i + 1) bounds :: outputTargets (i + 1) b oi ob rest
  | i, b, oi, ob, ⟨.inputOutput, .boolean⟩ :: rest =>
      .boolean (b + 1) :: outputTargets i (b + 1) oi ob rest
  | i, b, oi, ob, ⟨.output, .integer bounds⟩ :: rest =>
      .integer (oi + 1) bounds :: outputTargets i b (oi + 1) ob rest
  | i, b, oi, ob, ⟨.output, .boolean⟩ :: rest =>
      .boolean (ob + 1) :: outputTargets i b oi (ob + 1) rest
  | i, b, oi, ob, ⟨_, .array _⟩ :: rest => outputTargets i b oi ob rest

def targetType : Target → ScalarType
  | .integer _ bounds => .integer bounds
  | .boolean _ => .boolean

theorem outputTargets_types (i b oi ob : Nat) (formals : List Formal)
    (modes : ∀ formal ∈ formals, formal.mode = .input ∨ formal.domain.IsScalar) :
    (outputTargets i b oi ob formals).map targetType = outputTypes formals := by
  induction formals generalizing i b oi ob with
  | nil => rfl
  | cons formal rest ih =>
      have first := modes formal (by simp)
      have later : ∀ formal ∈ rest, formal.mode = .input ∨ formal.domain.IsScalar :=
        fun formal present => modes formal (by simp [present])
      rcases formal with ⟨mode, domain⟩
      cases mode <;> cases domain <;>
        simp_all [outputTargets, outputTypes, targetType, ScalarType.IsScalar]

/-- Only the selected earlier function prefix is visible. Its evaluator is the
already constructed function table; later declarations do not enlarge admission. -/
def functionPrefix (functions : ScalarFunctions.Environment) (count : Nat) : ScalarFunctions.Environment :=
  ⟨functions.signatures.take count, functions.values⟩

theorem functionPrefix_valid {functions : ScalarFunctions.Environment}
    (valid : functions.Valid) (count : Nat) : (functionPrefix functions count).Valid := by
  intro identity signature found inputs fits
  have positive := ScalarFunctions.lookup_nonzero found
  have within : identity - 1 < (functions.signatures.take count).length := by
    simp only [functionPrefix, ScalarFunctions.lookup, positive, ↓reduceIte] at found
    exact (List.getElem?_eq_some_iff.mp found).1
  have original : ScalarFunctions.lookup functions.signatures identity = some signature := by
    simp only [functionPrefix, ScalarFunctions.lookup, positive, ↓reduceIte] at found ⊢
    have bound : identity - 1 < count := by
      rw [List.length_take] at within
      omega
    simpa only [List.getElem?_take_of_lt bound] using found
  exact valid identity signature original inputs fits

end Silver.ScalarProcedures
