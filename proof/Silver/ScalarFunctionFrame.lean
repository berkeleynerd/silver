module

public import Silver.ScalarFunctionTypes

@[expose] public section

/-! The two passes bind scalar formals at fresh suffix identities and array
formals at separate high addresses. Both traverse the same formal-order tuple. -/
namespace Silver.ScalarFunctions

structure Frame where
  integers : Integer.Store
  booleans : Boolean.Store

def arrayAnalysis : Nat → List ScalarType → Integer.Analysis → Integer.Analysis
  | _, [], analysis => analysis
  | slot, .array domain :: rest, analysis =>
      let view := domain.formal slot
      let outside (property : Nat → Bool) := fun cell => !decide (view.ContainsCell cell) && property cell
      arrayAnalysis (slot + 1) rest
        ⟨view.bodyRanges analysis.declared, outside analysis.mutable,
          outside analysis.static, outside analysis.refinable⟩
  | slot, _ :: rest, analysis => arrayAnalysis slot rest analysis

def bindArrayArguments : Nat → List ScalarType → List Value → Integer.Store → Integer.Store
  | slot, .array domain :: formals, .array argument :: values, locals =>
      bindArrayArguments (slot + 1) formals values (NamedArrayParameters.bind domain slot argument locals)
  | slot, _ :: formals, _ :: values, locals => bindArrayArguments slot formals values locals
  | _, _, _, locals => locals

theorem bindArrayArguments_fits {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (slot : Nat)
    (analysis : Integer.Analysis) (locals : Integer.Store) (fits : Integer.Fits analysis.declared locals) :
    Integer.Fits (arrayAnalysis slot formals analysis).declared (bindArrayArguments slot formals values locals) := by
  induction formals generalizing values slot analysis locals with
  | nil => cases values <;> simp_all [ArgumentsFit, arrayAnalysis, bindArrayArguments]
  | cons formal formals ih =>
    cases values with
    | nil => contradiction
    | cons value values =>
      cases formal <;> cases value
      all_goals try exact False.elim arguments.1
      · exact ih arguments.2 _ _ _ fits
      · exact ih arguments.2 _ _ _ fits
      · apply ih arguments.2
        exact NamedArrayParameters.bind_declared_fits arguments.1 _ fits

/-- Later array formals retain every cell of previously bound inputs, including
when several formal slots carry the same actual object. -/
theorem bindArrayArguments_preserves_before {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (earlier : NamedArrayParameters.Domain)
    (bounded : earlier.length ≤ NamedArrayParameters.maxLength) {previous slot cell : Nat}
    (before : previous < slot) (inside : (earlier.formal previous).ContainsCell cell) (locals : Integer.Store) :
    bindArrayArguments slot formals values locals cell = locals cell := by
  induction formals generalizing values slot locals with
  | nil => cases values <;> simp_all [ArgumentsFit, bindArrayArguments]
  | cons formal formals ih =>
    cases values with
    | nil => contradiction
    | cons value values =>
      cases formal <;> cases value
      all_goals try exact False.elim arguments.1
      · exact ih arguments.2 before locals
      · exact ih arguments.2 before locals
      · rename_i domain argument
        have apart := NamedArrayParameters.formal_disjoint (right := domain) before bounded
        have outside : ¬ (domain.formal slot).ContainsCell cell := by
          simp only [Integer.ArrayDescriptor.Disjoint, Integer.ArrayDescriptor.ContainsCell] at apart inside ⊢
          omega
        exact (ih arguments.2 (show previous < slot + 1 by omega) _).trans
          (NamedArrayParameters.bind_preserves_outside arguments.1 slot locals outside)

theorem capture_bound_parameter {formals : List ScalarType} {values : List Value}
    {domain : NamedArrayParameters.Domain} {argument : NamedArrayParameters.Argument}
    (bounded : domain.length ≤ NamedArrayParameters.maxLength) (fits : domain.Contains argument)
    (remaining : ArgumentsFit formals values) (slot : Nat) (locals : Integer.Store) :
    NamedArrayParameters.capture domain.identity (domain.formal slot)
      (bindArrayArguments slot (.array domain :: formals) (.array argument :: values) locals) = argument := by
  refine (NamedArrayParameters.capture_congr domain.identity (domain.formal slot) ?_).trans
    (NamedArrayParameters.capture_bind fits slot locals)
  intro cell inside
  exact bindArrayArguments_preserves_before remaining domain bounded (Nat.lt_succ_self _) inside _

def bindArguments : Nat → Nat → List ScalarType → List Value → Frame → Frame
  | integerCount, booleanCount, .integer _ :: formals, .integer value :: values, frame =>
      bindArguments (integerCount + 1) booleanCount formals values
        {frame with integers := Integer.put frame.integers (integerCount + 1) value}
  | integerCount, booleanCount, .boolean :: formals, .boolean value :: values, frame =>
      bindArguments integerCount (booleanCount + 1) formals values
        {frame with booleans := Boolean.put frame.booleans (booleanCount + 1) value}
  | integerCount, booleanCount, .array _ :: formals, .array _ :: values, frame =>
      bindArguments integerCount booleanCount formals values frame
  | _, _, _, _, frame => frame

def parameterRanges : Nat → List ScalarType → Integer.Ranges → Integer.Ranges
  | count, .integer bounds :: formals, ranges =>
      parameterRanges (count + 1) formals (Integer.put ranges (count + 1) (some bounds))
  | count, .boolean :: formals, ranges
  | count, .array _ :: formals, ranges => parameterRanges count formals ranges
  | _, [], ranges => ranges

theorem bindArguments_preserves_above {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) {cell : Nat} (above : integerCount + formals.length < cell) :
    (bindArguments integerCount booleanCount formals values frame).integers cell = frame.integers cell := by
  induction formals generalizing values integerCount booleanCount frame with
  | nil => cases values <;> simp_all [ArgumentsFit, bindArguments]
  | cons formal formals ih =>
    cases values with
    | nil => contradiction
    | cons value values =>
      simp only [List.length_cons] at above
      cases formal <;> cases value
      all_goals try exact False.elim arguments.1
      · rename_i bounds value
        have kept := ih arguments.2 (integerCount + 1) booleanCount
          {frame with integers := Integer.put frame.integers (integerCount + 1) value} (by omega)
        simpa only [bindArguments, Integer.put, show cell ≠ integerCount + 1 by omega, ↓reduceIte] using kept
      · exact ih arguments.2 integerCount (booleanCount + 1) _ (by omega)
      · exact ih arguments.2 integerCount booleanCount frame (by omega)

theorem capture_after_scalar_arguments {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) (typeId : Nat) (source : Integer.ArrayDescriptor)
    (separate : integerCount + formals.length < source.base) :
    NamedArrayParameters.capture typeId source (bindArguments integerCount booleanCount formals values frame).integers =
      NamedArrayParameters.capture typeId source frame.integers := by
  apply NamedArrayParameters.capture_congr
  intro cell inside
  exact bindArguments_preserves_above arguments integerCount booleanCount frame (by
    simp only [Integer.ArrayDescriptor.ContainsCell] at inside
    omega)

theorem bindArguments_fits {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) (ranges : Integer.Ranges) (fits : Integer.Fits ranges frame.integers) :
    Integer.Fits (parameterRanges integerCount formals ranges)
      (bindArguments integerCount booleanCount formals values frame).integers := by
  induction formals generalizing values integerCount booleanCount frame ranges with
  | nil => cases values <;> simp_all [ArgumentsFit, bindArguments, parameterRanges]
  | cons formal formals ih =>
      cases values with
      | nil => contradiction
      | cons value values =>
          cases formal <;> cases value
          all_goals try exact False.elim arguments.1
          · exact ih arguments.2 _ _ _ _ (Integer.put_fits fits arguments.1)
          · exact ih arguments.2 _ _ _ _ fits
          · exact ih arguments.2 _ _ _ _ fits

theorem bindArguments_preserves_locals {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) (identity : Nat) :
    (identity ≤ integerCount →
      (bindArguments integerCount booleanCount formals values frame).integers identity =
        frame.integers identity) ∧
    (identity ≤ booleanCount →
      (bindArguments integerCount booleanCount formals values frame).booleans identity =
        frame.booleans identity) := by
  induction formals generalizing values integerCount booleanCount frame with
  | nil => cases values <;> simp_all [ArgumentsFit, bindArguments]
  | cons formal formals ih =>
      cases values with
      | nil => contradiction
      | cons value values =>
          cases formal <;> cases value
          all_goals try exact False.elim arguments.1
          · rename_i bounds value
            have rest := ih arguments.2 (integerCount + 1) booleanCount
              {frame with integers := Integer.put frame.integers (integerCount + 1) value}
            constructor
            · intro inside
              have same := rest.1 (by omega)
              simpa only [bindArguments, Integer.put, show identity ≠ integerCount + 1 by omega,
                ↓reduceIte] using same
            · exact rest.2
          · rename_i value
            have rest := ih arguments.2 integerCount (booleanCount + 1)
              {frame with booleans := Boolean.put frame.booleans (booleanCount + 1) value}
            constructor
            · exact rest.1
            · intro inside
              have same := rest.2 (by omega)
              simpa only [bindArguments, Boolean.put, show identity ≠ booleanCount + 1 by omega,
                ↓reduceIte] using same
          · exact ih arguments.2 _ _ _

theorem bindArguments_first_integer {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) (bounds : Integer.Interval) (value : Int) :
    (bindArguments integerCount booleanCount (.integer bounds :: formals)
      (.integer value :: values) frame).integers (integerCount + 1) = value := by
  have preserved := (bindArguments_preserves_locals arguments (integerCount + 1) booleanCount
    {frame with integers := Integer.put frame.integers (integerCount + 1) value}
    (integerCount + 1)).1 (Nat.le_refl _)
  simpa only [bindArguments, Integer.put, ↓reduceIte] using preserved

theorem bindArguments_first_boolean {formals : List ScalarType} {values : List Value}
    (arguments : ArgumentsFit formals values) (integerCount booleanCount : Nat)
    (frame : Frame) (value : Bool) :
    (bindArguments integerCount booleanCount (.boolean :: formals)
      (.boolean value :: values) frame).booleans (booleanCount + 1) = value := by
  have preserved := (bindArguments_preserves_locals arguments integerCount (booleanCount + 1)
    {frame with booleans := Boolean.put frame.booleans (booleanCount + 1) value}
    (booleanCount + 1)).2 (Nat.le_refl _)
  simpa only [bindArguments, Boolean.put, ↓reduceIte] using preserved

end Silver.ScalarFunctions
