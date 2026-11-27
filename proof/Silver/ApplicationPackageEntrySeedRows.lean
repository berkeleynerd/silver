module

public import Silver.ApplicationPackageGlobalSeedRows
public import Silver.ApplicationPackageFormalEntry

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Predicate Packages ApplicationPackageDeclarations ApplicationPackageBodies
open ApplicationPackageObjectRows ApplicationPackageFrameLayout ApplicationPackageFormalStorage

theorem SpecificationSyntax.seed_bound {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before after : SpecificationState} {inventory : SpecificationSyntax} {seed : ConstantSeed}
    (source : inventory.SourceAt reader text before after) (selected : inventory.seed = some seed) :
    seed.identity ≤ text.length := by
  cases inventory with
  | routine | subtype => cases selected
  | object out objectSyntax =>
    cases Option.some.inj selected
    have present := (specification_object_present source.2.1 source.1).1
    have bounds := source.2.1 ▸ objectStep_positions reader text before.exports before.info false
      (source.2.1 ▸ present)
    cases kind : out.mark.kind <;> simp only [objectConstantSeed, kind, ConstantSeed.identity] <;> omega

theorem SpecificationInventories.seed_bounds {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before : SpecificationState} {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories reader text before rows exit) :
    ∀ seed ∈ specificationSeeds rows, seed.identity ≤ text.length := by
  induction history with
  | returned | ready => simp [specificationSeeds]
  | @next row rest exit step source history ih =>
    intro seed member
    simp only [specificationSeeds, List.filterMap_cons] at member
    cases selected : row.inventory.seed with
    | none =>
      simp only [selected] at member
      exact ih seed member
    | some first =>
      simp only [selected, List.mem_cons] at member
      rcases member with rfl | later
      · exact SpecificationSyntax.seed_bound source selected
      · exact ih seed later

theorem seedRanges_globals (ranges : SharedRanges) (seeds : List ConstantSeed) :
    (seedRanges ranges seeds).globals = ranges.globals := by
  induction seeds generalizing ranges with
  | nil => rfl
  | cons seed rest ih => exact ih (seed.initializer.declare ranges)

theorem seedRanges_other {ranges : SharedRanges} {seeds : List ConstantSeed} {identity : Nat}
    (apart : ∀ seed ∈ seeds, seed.identity ≠ identity) :
    (seedRanges ranges seeds).locals identity = ranges.locals identity := by
  induction seeds generalizing ranges with
  | nil => rfl
  | cons seed rest ih =>
    rw [seedRanges_cons, ih (fun next member => apart next (List.mem_cons_of_mem _ member))]
    have separate := apart seed List.mem_cons_self
    cases seed with
    | integer index value =>
      change Integer.put ranges.locals index (some (.singleton value)) identity = _
      exact ite_eq_right (Ne.symm separate)
    | boolean index value => rfl

theorem seeded_routine_input {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {start stop : Nat} {seeds : List ConstantSeed}
    (window : HeaderWindow start stop ((formalIndices item).map info.parameterAt))
    (earlier : ∀ seed ∈ seeds, seed.identity < start) {formal : PackageBindings.Formal}
    (selected : formal ∈ chosen false info (formalIndices item)) (kind : formal.kind = .integer) :
    (seedRanges ⟨info.stateSchema.integerRanges, inputRangesFrom Integer.emptyRanges (routineInputs info item)⟩
      seeds).locals formal.bodyName.first = some formal.bounds := by
  rw [seedRanges_other]
  · exact routineInputs_range window selected kind _
  · intro seed member
    have lower := (window.entries formal ((chosen_sublist false info _).subset selected)).1
    exact Nat.ne_of_lt (Nat.lt_of_lt_of_le (earlier seed member) lower)

theorem formal_row_local {info : PackageBindings.Metadata} {formal : PackageBindings.Formal}
    (apart : ∀ state ∈ info.states, formal.bodyName.first ≠ state.name.first) :
    rowAddress info .integer (reference formal.bodyName) = .local formal.bodyName.first := by
  unfold rowAddress
  cases found : stateIndex info .integer (reference formal.bodyName) with
  | none => rfl
  | some identity =>
    have selected := stateIndex_some found
    exact False.elim (apart _ (info.stateAt_mem identity selected.1 selected.2.1) selected.2.2.2.2.1.symm)

/-- Routine_Frame widens the original globals, removes shadowed rows, and
appends exactly the input-bearing header formals. All three phases retain the
same semantic declaration identities. -/
theorem routine_frame_seed_rows {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    {ranges : SharedRanges}
    (prior : StateFrame info.states globals)
    (window : HeaderWindow globals.position position ((formalIndices (info.routineAt routine)).map info.parameterAt))
    (parsed : ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position = after)
    (present : after.position ≠ 0)
    (globalRows : ScalarRangeRows info ranges (ScalarExpression.bodyEnvironment globals.scalarNames))
    (inputRows : ∀ formal ∈ chosen false info (formalIndices (info.routineAt routine)), formal.kind = .integer →
      ranges.locals formal.bodyName.first = some formal.bounds) :
    ScalarRangeRows info ranges after.scalarNames := by
  obtain ⟨hidden, retained, added⟩ := routineFrame_tables hide append parsed present
  intro row member
  rw [added.integers] at member
  rcases List.mem_append.mp member with kept | installed
  · have original := retained.integers.subset kept
    change row ∈ calls.bodyEnvironment globals.scalarNames at original
    rw [body] at original
    exact globalRows row original
  · obtain ⟨formal, selected, scalar⟩ := List.mem_filterMap.mp installed
    unfold ApplicationPackageFormalStorage.scalar at scalar
    split at scalar
    · rename_i integer
      cases scalar
      have localCell := formal_row_local (info := info) (formal := formal) (by
        intro state declared
        exact Nat.ne_of_gt (Nat.lt_of_lt_of_le (prior.statesBefore state declared)
          (window.entries formal ((chosen_sublist false info _).subset selected)).1))
      change integerRangeAt ranges (rowAddress info .integer (reference formal.bodyName)) = _
      rw [localCell]
      exact inputRows formal selected integer
    · contradiction

/-- The actual original specification history seeds a complete routine entry.
The caller supplies declaration history and the native header window; the
semantic row map and its inactive suffix are conclusions. -/
theorem source_routine_seed_rows {staticReader : BooleanElaboration.Native.Reader}
    {specText : Source} {specStart specEnd : SpecificationState} {specRows : List SpecificationItem}
    (specified : SpecificationInventories staticReader specText specStart specRows (.ready specEnd))
    (specOrder : FrameOrder specStart.exports) (empty : specStart.exports.scalarNames = [])
    {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position bound : Nat}
    (prior : StateFrame info.states globals)
    (origin : GlobalScalarOrigins specEnd.exports.scalarNames info.states globals.scalarNames)
    (window : HeaderWindow globals.position position ((formalIndices (info.routineAt routine)).map info.parameterAt))
    (separated : specText.length < globals.position) (within : position ≤ bound + 1)
    (parsed : ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position = after)
    (present : after.position ≠ 0) :
    let entry : SharedRanges := ⟨info.stateSchema.integerRanges,
      inputRangesFrom Integer.emptyRanges (routineInputs info (info.routineAt routine))⟩
    let seeded := seedRanges entry (specificationSeeds specRows)
    ScalarRangeRows info seeded after.scalarNames ∧ LocalRangesBound bound seeded := by
  let entry : SharedRanges := ⟨info.stateSchema.integerRanges,
    inputRangesFrom Integer.emptyRanges (routineInputs info (info.routineAt routine))⟩
  have initial : ConstantRangeRows entry specStart.exports.scalarNames := by
    simp only [empty, ConstantRangeRows, List.not_mem_nil, false_implies, implies_true]
  have loaded := (specified.seed_rows specOrder initial).2
  have earlier : ∀ seed ∈ specificationSeeds specRows, seed.identity < globals.position :=
    fun seed member => Nat.lt_of_le_of_lt (specified.seed_bounds seed member) separated
  constructor
  · exact routine_frame_seed_rows body hide append prior window parsed present
      (global_seed_rows origin prior.scalarFields loaded (seedRanges_globals _ _))
      (fun formal selected kind => seeded_routine_input window earlier selected kind)
  · apply constant_seeds_bound
    · exact routineInputs_bound window within Integer.emptyRanges (fun _ _ => rfl)
    · intro seed member
      have := earlier seed member
      have := window.progress
      omega

end Silver.ApplicationPackageInitializers
