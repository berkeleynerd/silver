module

public import Silver.ApplicationPackageRoutineInitialization
public import Silver.PackageInitializerPhases

@[expose] public section

/-! Loading already elaborated immutable constants into an invocation frame.
Every value is connected separately to its original initializer syntax and
evaluation. Snapshot loads do not replace the raw initializer obligations. -/
namespace Silver.ApplicationPackageInitializers
open Compose Predicate Packages ApplicationPackageDeclarations ApplicationPackageFrameLayout

inductive ConstantSeed where
  | integer (identity : Nat) (value : Int)
  | boolean (identity : Nat) (value : Bool)
  deriving DecidableEq, Repr

def ConstantSeed.identity : ConstantSeed → Nat
  | .integer identity _ | .boolean identity _ => identity

def ConstantSeed.value : ConstantSeed → ScalarFunctions.Value
  | .integer _ value => .integer value
  | .boolean _ value => .boolean value

def ConstantSeed.Valid : ConstantSeed → Prop
  | .integer _ value => Integer.InRange value
  | .boolean _ _ => True

def constantLayout : FrameLayout := ⟨Address.local, Address.local⟩

def ConstantSeed.initializer : ConstantSeed → LocalInitializer
  | .integer identity value =>
      ⟨.integer identity, .integer (.singleton value), .integer (.snapshot value), constantLayout, .empty, {}⟩
  | .boolean identity value =>
      ⟨.boolean identity, .boolean, .boolean (.booleanLiteral value), constantLayout, .empty, {}⟩

theorem ConstantSeed.readable (seed : ConstantSeed) : seed.initializer.Readable := by
  cases seed <;> constructor <;> trivial

theorem ConstantSeed.evaluate (seed : ConstantSeed) (state : SharedState) :
    seed.initializer.value.evaluate (scalarState (state.view constantLayout)) = seed.value := by
  cases seed <;> rfl

theorem ConstantSeed.check {seed : ConstantSeed} (valid : seed.Valid) (ranges : SharedRanges) :
    seed.initializer.check ranges = some (seed.initializer.declare ranges) := by
  cases seed with
  | integer identity value =>
    have bounded : (Integer.Interval.singleton value).Bounded := ⟨valid, valid⟩
    have inferred : (Integer.Expr.snapshot value).infer (ranges.view constantLayout) =
        some (Integer.Interval.singleton value) := by
      have nonempty : (Integer.Interval.singleton value).isEmpty = false := by
        simp only [Integer.Interval.singleton, Integer.Interval.isEmpty, Int.lt_irrefl, decide_false]
      simp only [Integer.Expr.infer, Integer.accepted, Integer.checked, nonempty,
        Bool.false_eq_true, ite_false, bounded, ite_true]
    change ((Integer.Expr.snapshot value).infer (ranges.view constantLayout)).bind
      (fun bounds => if !bounds.isEmpty && bounds.included (.singleton value) then
        some {ranges with locals := Integer.put ranges.locals identity (some bounds)} else none) =
      some {ranges with locals := Integer.put ranges.locals identity (some (.singleton value))}
    rw [inferred]
    simp [Integer.Interval.included, Integer.Interval.isEmpty, Integer.Interval.singleton]
  | boolean identity value => rfl

theorem constant_seeds_check (seeds : List ConstantSeed) (ranges : SharedRanges)
    (valid : ∀ seed ∈ seeds, seed.Valid) :
    checkInitializers ranges (seeds.map ConstantSeed.initializer) =
      some (initializerDomains ranges (seeds.map ConstantSeed.initializer)) := by
  induction seeds generalizing ranges with
  | nil => rfl
  | cons seed rest ih =>
    simp only [List.map_cons, checkInitializers, initializerDomains,
      seed.check (valid seed List.mem_cons_self), Option.bind_some]
    exact ih _ (fun next member => valid next (List.mem_cons_of_mem _ member))

theorem constant_seeds_readable (seeds : List ConstantSeed) :
    ∀ item ∈ seeds.map ConstantSeed.initializer, item.Readable := by
  intro item member
  obtain ⟨seed, _, rfl⟩ := List.mem_map.mp member
  exact seed.readable

theorem constant_seeds_bound {bound : Nat} {ranges : SharedRanges} {seeds : List ConstantSeed}
    (prior : LocalRangesBound bound ranges)
    (inside : ∀ seed ∈ seeds, seed.identity ≤ bound) :
    LocalRangesBound bound (initializerDomains ranges (seeds.map ConstantSeed.initializer)) := by
  induction seeds generalizing ranges with
  | nil => exact prior
  | cons seed rest ih =>
    apply ih (inside := fun next member => inside next (List.mem_cons_of_mem _ member))
    cases seed with
    | integer identity value =>
      exact LocalRangesBound.put_local (.singleton value) prior (inside _ List.mem_cons_self)
    | boolean identity value => exact prior

/-- The loaded scalar is the value of the original initializer on every
elaboration store in its full source domain. Its syntax and intermediate
obligations remain explicit, independent of the constant load's own check. -/
theorem ValueCalls.scalar_constant_seed {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (kind : out.mark.kind = .integer) (singleton : out.initialBounds.lower = out.initialBounds.upper) :
    ∃ expression,
      ScalarExpression.sourceSyntaxAt text base.scalarNames [] first last true out.initFirst
        ⟨out.initAfter, expression⟩ ∧
      Integer.discharged (expression.obligations (ScalarExpression.ranges base.scalarNames)) = true ∧
      (ConstantSeed.integer out.name.first out.initialBounds.lower).Valid ∧
      (∀ integers, Integer.Fits (ScalarExpression.ranges base.scalarNames) integers →
        ScalarFunctions.Value.integer (expression.evaluate integers) =
          (ConstantSeed.integer out.name.first out.initialBounds.lower).value) ∧
      Integer.Interval.singleton out.initialBounds.lower = out.initialBounds := by
  obtain ⟨expression, reading, inferred, discharged, _, _⟩ := calls.scalar_inventory kind
  refine ⟨expression, ?_, discharged, (Integer.Expr.infer_bounded inferred).1, ?_, ?_⟩
  · simpa only [(calls.scalar kind).1] using reading.grammar
  · intro integers fitting
    exact congrArg ScalarFunctions.Value.integer
      (BooleanElaboration.singleton_infer_value inferred fitting singleton)
  · exact congrArg (Integer.Interval.mk out.initialBounds.lower) singleton

end Silver.ApplicationPackageInitializers
