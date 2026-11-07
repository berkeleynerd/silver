module

public import Silver.PredicateChecking

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

structure BooleanArrayAssignment where
  array : Boolean.ArrayDescriptor
  index : Integer.Expr
  value : Condition
  deriving Repr

def BooleanArrayAssignment.check (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
    (booleans : Boolean.Analysis) (update : BooleanArrayAssignment) : Bool :=
  update.array.writable booleans &&
    (update.array.checkIndex flow.scalars update.index && update.value.checkBounds shape analysis flow booleans)

/-- Identity outside the checked index domain is only the mathematical
totalization. Admitted executions always take the single-component update. -/
def BooleanArrayAssignment.execute (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) (booleans : Boolean.Store) (update : BooleanArrayAssignment) : Boolean.Store :=
  if update.array.bounds.Contains (update.index.evaluate integers) then
    update.array.write booleans (update.index.evaluate integers)
      (update.value.evaluate values input valid integers booleans)
  else booleans

def BooleanArrayAssignment.checkedExecute (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) (booleans : Boolean.Store)
    (update : BooleanArrayAssignment) : Option Boolean.Store :=
  (update.index.checkedEvaluate integers).bind fun index =>
    if update.array.bounds.Contains index then
      (update.value.checkedEvaluate values input valid integers booleans).map fun value =>
        update.array.write booleans index value
    else none

theorem BooleanArrayAssignment.check_sound {shape : Shape} {analysis : Integer.Analysis}
    {flow : Flow} {booleanAnalysis : Boolean.Analysis} {update : BooleanArrayAssignment}
    {hasArguments : Bool} {values : Values} {input : Source} {valid rejected : Bool}
    {integers : Integer.Store} {booleans : Boolean.Store}
    (checked : update.check shape analysis flow booleanAnalysis = true)
    (readable : update.value.Readable hasArguments shape booleanAnalysis)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    update.index.Safe integers ∧ update.array.bounds.Contains (update.index.evaluate integers) ∧
      update.value.Safe shape values input valid integers booleans ∧
      update.checkedExecute values input valid integers booleans =
        some (update.execute values input valid integers booleans) := by
  simp only [check, Bool.and_eq_true] at checked
  have indexSound := update.array.checkIndex_sound checked.2.1 allowed.2
  have valueSound := update.value.checkBounds_sound (booleans := booleans)
    state readable allowed checked.2.2
  refine ⟨indexSound.1, indexSound.2, valueSound, ?_⟩
  simp only [checkedExecute, Integer.Expr.checkedEvaluate_agrees indexSound.1,
    Option.bind_some, indexSound.2, ↓reduceIte,
    Condition.checkedEvaluate_refines valueSound state, Option.map_some, execute]

theorem BooleanArrayAssignment.unchanged {shape : Shape} {analysis : Integer.Analysis}
    {flow : Flow} {booleanAnalysis : Boolean.Analysis} {update : BooleanArrayAssignment}
    {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store}
    {booleans : Boolean.Store} {cell : Nat}
    (checked : update.check shape analysis flow booleanAnalysis = true)
    (readonly : booleanAnalysis.mutable cell = false) :
    update.execute values input valid integers booleans cell = booleans cell := by
  have writable := (Bool.and_eq_true_iff.mp checked).1
  unfold execute
  split
  · rename_i inside
    apply Boolean.put_other
    intro same
    have changed := Boolean.canWrite_mutable (update.array.writable_address writable inside)
    rw [← same, readonly] at changed
    contradiction
  · rfl

end Silver.Predicate
