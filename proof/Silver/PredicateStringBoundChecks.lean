module

public import Silver.PredicateObligations
public import Silver.ComposeStringRuntimeBounds

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts StringObjectBounds

/-- Endpoint checks reuse the actual source length certificate. Declaration
and path certificates have different conservative length limits. -/
inductive StringLengthSchema
  | declaration (check : Guarded.RangeObligation)
  | path (context : Context) (summary : LengthSummary)
  deriving DecidableEq, Repr

def StringLengthSchema.discharge : StringLengthSchema → Bool
  | .declaration check => check.discharge
  | .path context summary => (Obligation.stringRange context summary).discharge

def StringLengthSchema.Valid : StringLengthSchema → Prop
  | .declaration check => check.Valid
  | .path context summary => (Obligation.stringRange context summary).Valid

/-- Coverage is downward closed. In particular, the lower endpoint of an
exact whole-expression length summary does not exclude its shorter children. -/
def StringLengthSchema.Covers (schema : StringLengthSchema) (valid : Bool)
    (inputLength : Nat) (rejected : Bool) (actualLength : Nat) : Prop :=
  match schema with
  | .declaration check => ∃ variableLength, variableLength ≤ check.variableBound ∧
      actualLength ≤ check.fixedLength + variableLength
  | .path context summary => context.Allows valid inputLength rejected ∧
      ∃ total, summary.Contains inputLength total ∧ actualLength ≤ total

theorem StringLengthSchema.covers_mono {schema : StringLengthSchema} {valid rejected : Bool}
    {inputLength small large : Nat} (covered : schema.Covers valid inputLength rejected large)
    (within : small ≤ large) : schema.Covers valid inputLength rejected small := by
  cases schema with
  | declaration check =>
      obtain ⟨variableLength, bounded, total⟩ := covered
      exact ⟨variableLength, bounded, Nat.le_trans within total⟩
  | path context summary =>
      obtain ⟨allowed, total, contains, bounded⟩ := covered
      exact ⟨allowed, total, contains, Nat.le_trans within bounded⟩

theorem StringLengthSchema.discharge_sound {schema : StringLengthSchema}
    (checked : schema.discharge = true) : schema.Valid := by
  cases schema with
  | declaration check => exact (Guarded.RangeObligation.discharge_iff check).mp checked
  | path context summary => exact Obligation.discharge_sound (check := .stringRange context summary) checked

theorem StringLengthSchema.covered_bound {schema : StringLengthSchema} {valid rejected : Bool}
    {inputLength actualLength : Nat} (sound : schema.Valid)
    (covered : schema.Covers valid inputLength rejected actualLength) :
    actualLength ≤ Guarded.guaranteedIntegerLast := by
  cases schema with
  | declaration check =>
      obtain ⟨variableLength, bounded, total⟩ := covered
      exact Nat.le_trans total (sound variableLength bounded)
  | path context summary =>
      obtain ⟨allowed, total, contains, bounded⟩ := covered
      have upper := sound.2 valid inputLength rejected total allowed contains
      have totalBound := contains.2.2
      simp only [maxSourceLength, Guarded.guaranteedIntegerLast] at *
      omega

def stringBoundsCeiling (count : Nat) : Int := max 1 ((count : Int) * maxSourceLength)

structure StringBoundsObligation where
  bindingCount : Nat
  length : StringLengthSchema
  deriving DecidableEq, Repr

def StringBoundsObligation.discharge (check : StringBoundsObligation) : Bool :=
  decide (check.bindingCount ≤ maxBindings) && check.length.discharge

def StringBoundsObligation.Valid (check : StringBoundsObligation) : Prop :=
  check.length.Valid ∧ ∀ valid inputLength rejected actualLength,
    check.length.Covers valid inputLength rejected actualLength →
      EndpointBound (stringBoundsCeiling check.bindingCount) actualLength

theorem StringBoundsObligation.discharge_sound {check : StringBoundsObligation}
    (checked : check.discharge = true) : check.Valid := by
  obtain ⟨count, length⟩ := Bool.and_eq_true_iff.mp checked
  have bounded := of_decide_eq_true count
  have sound := StringLengthSchema.discharge_sound length
  refine ⟨sound, ?_⟩
  intro valid inputLength rejected actualLength covered first positive firstBound
  have lengthBound := StringLengthSchema.covered_bound sound covered
  simp only [stringBoundsCeiling, maxBindings, maxSourceLength, Integer.maxValue,
    Guarded.guaranteedIntegerLast] at *
  omega

theorem StringBoundsObligation.expression_safe {check : StringBoundsObligation}
    {expression : Expression} {names : Compose.BindingEnvironment} {values : Values}
    {input : Source} {integers : Integer.Store} {valid rejected : Bool}
    (certificate : check.Valid) (count : names.length ≤ check.bindingCount)
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origins : expression.BoundsOrigin names) (safe : expression.RuntimeSafe values input integers)
    (covered : check.length.Covers valid input.length rejected
      (expression.evaluate values input integers).length) :
    expression.ObjectBoundsSafe names values input integers := by
  apply Expression.objectBoundsSafe_of_endpoint metadata strings origins safe
    (ceiling := stringBoundsCeiling check.bindingCount)
  · simp only [namesBoundCeiling, stringBoundsCeiling, maxSourceLength]
    omega
  · exact certificate.2 valid input.length rejected _ covered

theorem path_stringBounds_discharge {count : Nat} {context : Context} {summary : LengthSummary}
    (bounded : count ≤ maxBindings) (checked : fitsLengthSummary context summary = true) :
    (StringBoundsObligation.mk count (.path context summary)).discharge = true := by
  simp only [StringBoundsObligation.discharge, StringLengthSchema.discharge,
    Obligation.discharge, decide_eq_true bounded, checked, Bool.and_self]

/-- Instantiate the endpoint certificate at the exact path and scalar flow of
an expression occurrence. This is uniform in the current store. -/
theorem path_expression_objectBounds {names : Compose.BindingEnvironment} {expression : Expression}
    {ranges : Integer.Ranges} {context : Context} {summary : LengthSummary}
    {values : Values} {input : Source} {integers : Integer.Store} {valid rejected : Bool}
    (count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (origin : expression.BoundsOrigin names)
    (known : expression.inferLength names.shape ranges = some summary)
    (checked : fitsLengthSummary context summary = true)
    (strings : Fits names.shape input values) (scalars : Integer.Fits ranges integers)
    (allowed : context.Allows valid input.length rejected) :
    expression.ObjectBoundsSafe names values input integers := by
  apply StringBoundsObligation.expression_safe
    (check := ⟨names.length, .path context summary⟩)
    (StringBoundsObligation.discharge_sound (path_stringBounds_discharge count checked))
    (Nat.le_refl _) metadata strings origin
    (expression_safe_on_path known strings scalars allowed checked)
  exact ⟨allowed, _, (Expression.inferLength_sound known strings scalars).1, Nat.le_refl _⟩

end Silver.Predicate
