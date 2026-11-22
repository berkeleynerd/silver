module

public import Silver.PackageStatementSafety

@[expose] public section

/-! A finite iteration fold threads hidden persistent state and local values
through each body. The invariant is the declared state product plus the
widened visible integer ranges. A lexical binder is restored after each body. -/
namespace Silver.Packages
open Predicate (Flow)

theorem shared_iterations_sound {schema : StateSchema} {layout : FrameLayout}
    {analysis : Integer.Analysis} {ranges : Integer.Ranges} {before after : PathFacts.Context}
    {state : SharedState} {indices : List Int}
    {step : SharedState → Int → SharedState} {checkedStep : SharedState → Int → Option SharedState}
    (bodies : ∀ value ∈ indices, ∀ current,
      schema.Fits current.globals → Integer.Fits analysis.declared (current.view layout).integers →
      Integer.Fits ranges (current.view layout).integers →
      SharedStepSound schema layout analysis ⟨after, ranges⟩ current (step current value) (checkedStep current value))
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (fitting : Integer.Fits ranges (state.view layout).integers)
    (allowed : before.Allows true 0 false) :
    SharedStepSound schema layout analysis ⟨if indices = [] then before else after, ranges⟩ state
      (indices.foldl step state) (checkedSharedIterations checkedStep state indices) := by
  induction indices generalizing state with
  | nil => exact ⟨globalsFit, declared, ⟨allowed, fitting⟩, rfl, fun _ _ => rfl⟩
  | cons value rest ih =>
      have first := bodies value (by simp) state globalsFit declared fitting
      have restBodies : ∀ next ∈ rest, ∀ current,
          schema.Fits current.globals → Integer.Fits analysis.declared (current.view layout).integers →
          Integer.Fits ranges (current.view layout).integers →
          SharedStepSound schema layout analysis ⟨after, ranges⟩ current (step current next) (checkedStep current next) :=
        fun next member => bodies next (List.mem_cons_of_mem value member)
      have following := ih restBodies first.globals first.declared first.allowed.2
      refine ⟨following.globals, following.declared, ⟨?_, following.allowed.2⟩, ?_, ?_⟩
      · simpa only [List.cons_ne_nil, ↓reduceIte] using first.allowed.1
      · simp only [checkedSharedIterations, first.agreement, Option.bind_some, following.agreement,
          List.foldl_cons]
      · intro index readonly
        exact (following.readonly index readonly).trans (first.readonly index readonly)

theorem restored_iteration_readonly {layout : FrameLayout} {analysis : Integer.Analysis}
    {before after : SharedState} {index : Nat} {value : Int} {bounds : Integer.Interval}
    (unique : layout.Injective)
    (readonly : ∀ other, (analysis.withIndex index bounds).mutable other = false →
      (after.view layout).integers other =
        ((before.write (layout.place (.integer index)) (.integer value)).view layout).integers other) :
    ∀ other, analysis.mutable other = false →
      ((after.write (layout.place (.integer index)) (before.read (layout.place (.integer index)))).view layout).integers other =
        (before.view layout).integers other := by
  intro other fixed
  rw [before.restore_integer_view unique after index]
  by_cases same : other = index
  · subst other
    simp only [Integer.restore, Integer.put, ↓reduceIte]
  · have bodyFixed : (analysis.withIndex index bounds).mutable other = false := by
      simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using fixed
    have preserved := readonly other bodyFixed
    rw [before.write_integer_view unique index value] at preserved
    simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using preserved

theorem shared_loop_iteration {schema : StateSchema} {layout : FrameLayout}
    {analysis : Integer.Analysis} {before after : Flow} {index localIdentity : Nat}
    {bounds : Integer.Interval} {value : Int} {state : SharedState}
    {body : SharedState → SharedState} {checkedBody : SharedState → Option SharedState}
    (context : layout.Context schema analysis)
    (localIndex : layout.integers index = .local localIdentity)
    (bodySound : ∀ current, schema.Fits current.globals →
      Integer.Fits (analysis.withIndex index bounds).declared (current.view layout).integers →
      (Predicate.loopEntry analysis before index bounds).Allows true 0 false (current.view layout).integers →
      SharedStepSound schema layout (analysis.withIndex index bounds) after current
        (body current) (checkedBody current))
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (fitting : Integer.Fits (analysis.widen before.scalars) (state.view layout).integers)
    (allowed : before.path.Allows true 0 false) (within : bounds.Contains value) :
    let place := layout.place (.integer index)
    let entered := state.write place (.integer value)
    SharedStepSound schema layout analysis ⟨after.path, analysis.widen before.scalars⟩ state
      ((body entered).write place (state.read place))
      ((checkedBody entered).map fun result => result.write place (state.read place)) := by
  let entered := state.write (layout.place (.integer index)) (.integer value)
  have enteredGlobals : schema.Fits entered.globals := by
    simpa only [entered, state.local_integer_globals localIndex] using globalsFit
  have enteredDeclared : Integer.Fits (analysis.withIndex index bounds).declared
      (entered.view layout).integers := by
    rw [show (entered.view layout).integers = Integer.put (state.view layout).integers index value from
      state.write_integer_view context.unique index value]
    exact Integer.put_fits declared within
  have enteredAllowed : (Predicate.loopEntry analysis before index bounds).Allows true 0 false
      (entered.view layout).integers := by
    refine ⟨?_, ?_⟩
    · simpa only [Predicate.loopEntry, Predicate.loopContext,
        Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte] using allowed
    · rw [show (entered.view layout).integers = Integer.put (state.view layout).integers index value from
        state.write_integer_view context.unique index value]
      exact Integer.put_fits fitting within
  have finished := bodySound entered enteredGlobals enteredDeclared enteredAllowed
  let result := (body entered).write (layout.place (.integer index)) (state.read (layout.place (.integer index)))
  have globals : schema.Fits result.globals := by
    simpa only [result, SharedState.local_integer_globals _ localIndex] using finished.globals
  have restored : Integer.Fits analysis.declared (result.view layout).integers := by
    rw [show (result.view layout).integers =
      Integer.restore (state.view layout).integers ((body entered).view layout).integers index from
        state.restore_integer_view context.unique (body entered) index]
    exact Integer.restore_fits declared finished.declared
  have readonly : ∀ other, analysis.mutable other = false →
      (result.view layout).integers other = (state.view layout).integers other :=
    restored_iteration_readonly context.unique finished.readonly
  refine ⟨globals, restored, ⟨finished.allowed.1, analysis.widen_closed fitting restored readonly⟩, ?_, readonly⟩
  exact congrArg (Option.map fun final : SharedState =>
    final.write (layout.place (.integer index)) (state.read (layout.place (.integer index)))) finished.agreement

end Silver.Packages
