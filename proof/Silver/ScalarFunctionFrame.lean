module

public import Silver.ScalarFunctionTypes
public import Silver.PredicateLoopFlowValidity

@[expose] public section

/-! A function starts from its own initialized locals, then receives scalar
arguments in fresh suffix identities. Integer and Boolean identities belong to
separate stores; mixed formal order is retained by the paired recursion. -/
namespace Silver.ScalarFunctions

structure Frame where
  integers : Integer.Store
  booleans : Boolean.Store

def bindArguments : Nat → Nat → List ScalarType → List Value → Frame → Frame
  | integerCount, booleanCount, .integer _ :: formals, .integer value :: values, frame =>
      bindArguments (integerCount + 1) booleanCount formals values
        {frame with integers := Integer.put frame.integers (integerCount + 1) value}
  | integerCount, booleanCount, .boolean :: formals, .boolean value :: values, frame =>
      bindArguments integerCount (booleanCount + 1) formals values
        {frame with booleans := Boolean.put frame.booleans (booleanCount + 1) value}
  | _, _, _, _, frame => frame

def parameterRanges : Nat → List ScalarType → Integer.Ranges → Integer.Ranges
  | count, .integer bounds :: formals, ranges =>
      parameterRanges (count + 1) formals (Integer.put ranges (count + 1) (some bounds))
  | count, .boolean :: formals, ranges => parameterRanges count formals ranges
  | _, [], ranges => ranges

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
          · exact ih arguments.2 _ _ _ _ (Integer.put_fits fits arguments.1)
          · simp [ArgumentsFit, ScalarType.Contains] at arguments
          · simp [ArgumentsFit, ScalarType.Contains] at arguments
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
          · rename_i bounds value
            have rest := ih arguments.2 (integerCount + 1) booleanCount
              {frame with integers := Integer.put frame.integers (integerCount + 1) value}
            constructor
            · intro inside
              have same := rest.1 (by omega)
              simpa only [bindArguments, Integer.put, show identity ≠ integerCount + 1 by omega,
                ↓reduceIte] using same
            · exact rest.2
          · simp [ArgumentsFit, ScalarType.Contains] at arguments
          · simp [ArgumentsFit, ScalarType.Contains] at arguments
          · rename_i value
            have rest := ih arguments.2 integerCount (booleanCount + 1)
              {frame with booleans := Boolean.put frame.booleans (booleanCount + 1) value}
            constructor
            · exact rest.1
            · intro inside
              have same := rest.2 (by omega)
              simpa only [bindArguments, Boolean.put, show identity ≠ booleanCount + 1 by omega,
                ↓reduceIte] using same

def parameterBinding (first after : Nat) (bounds : Integer.Interval) : ScalarExpression.Binding :=
  {first, after, bounds, isStatic := false, declaredBounds := bounds, mutable := false}

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

/-- Formal bindings use the existing immutable refinable suffix convention.
The local declaration count stays fixed while each formal is appended. -/
theorem parameterBinding_refinable (names : ScalarExpression.Environment) (declarations : Nat)
    (count : declarations ≤ names.length) (first after : Nat) (bounds : Integer.Interval) :
    Predicate.ScalarMetadata.refinable (names ++ [parameterBinding first after bounds])
      declarations (names.length + 1) = true := by
  simp only [Predicate.ScalarMetadata.refinable, List.length_append, List.length_singleton,
    ScalarExpression.binding_append_new, parameterBinding, Bool.false_or]
  simp [show declarations < names.length + 1 by omega]

theorem parameterBinding_immutable (names : ScalarExpression.Environment)
    (first after : Nat) (bounds : Integer.Interval) :
    ScalarExpression.mutability (names ++ [parameterBinding first after bounds])
      (names.length + 1) = false := by
  simp [ScalarExpression.mutability, ScalarExpression.binding_append_new, parameterBinding]

theorem parameterBinding_nonstatic (names : ScalarExpression.Environment)
    (first after : Nat) (bounds : Integer.Interval) :
    Predicate.ScalarMetadata.staticness (names ++ [parameterBinding first after bounds])
      (names.length + 1) = false := by
  simp [Predicate.ScalarMetadata.staticness, ScalarExpression.binding_append_new, parameterBinding]

theorem parameterBinding_contextReady {names : ScalarExpression.Environment} {declarations : Nat}
    (ready : Predicate.ScalarMetadata.ContextReady names declarations false)
    (first after : Nat) (bounds : Integer.Interval)
    (space : names.length + 1 ≤ ArrayBindings.scalarLimit) :
    Predicate.ScalarMetadata.ContextReady
      (names ++ [parameterBinding first after bounds]) declarations false :=
  ready.append_immutable _ rfl space

theorem parameterBinding_flowReady {names : ScalarExpression.Environment} {declarations : Nat}
    {flow : Predicate.ActiveFlow}
    (context : Predicate.ScalarMetadata.ContextReady names declarations false)
    (ready : Predicate.ScalarMetadata.FlowReady names declarations flow)
    (first after : Nat) (bounds : Integer.Interval) (typed : bounds.Bounded) :
    Predicate.ScalarMetadata.FlowReady
      (names ++ [parameterBinding first after bounds]) declarations (flow.append bounds) :=
  ready.append_immutable context _ rfl typed

end Silver.ScalarFunctions
