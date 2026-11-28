module

public import Silver.ApplicationPackageProcedureActualTargets
public import Silver.ApplicationPackageVisibleStateLayout
public import Silver.ApplicationPackageIdentifierValidity
public import Silver.ApplicationPackageCallsArgumentAliases
public import Silver.ScalarProcedureAliasing

@[expose] public section

namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages

private theorem integer_place_iff {info : PackageBindings.Metadata} {context : ParseContext}
    {bound slot identity : Nat} :
    (layout bound info context).place (.integer slot) = .global ((info.stateAt identity).cell identity) ↔
      (layout bound info context).integers slot = .global identity := by
  constructor
  · intro placed
    cases located : (layout bound info context).integers slot with
    | «local» index => simp only [FrameLayout.place, located] at placed; contradiction
    | global index =>
      have indices := congrArg (fun place => cellIndex place.cell) placed
      simp only [FrameLayout.place, located, Place.cell,
        PackageBindings.StateDeclaration.cell_identity] at indices
      exact congrArg Address.global indices
  · intro located
    have kind := (stateIndex_some (slotAddress_global located).2.2).2.2.2.1
    simp only [FrameLayout.place, located, PackageBindings.StateDeclaration.cell, kind]

private theorem boolean_place_iff {info : PackageBindings.Metadata} {context : ParseContext}
    {bound slot identity : Nat} :
    (layout bound info context).place (.boolean slot) = .global ((info.stateAt identity).cell identity) ↔
      (layout bound info context).booleans slot = .global identity := by
  constructor
  · intro placed
    cases located : (layout bound info context).booleans slot with
    | «local» index => simp only [FrameLayout.place, located] at placed; contradiction
    | global index =>
      have indices := congrArg (fun place => cellIndex place.cell) placed
      simp only [FrameLayout.place, located, Place.cell,
        PackageBindings.StateDeclaration.cell_identity] at indices
      exact congrArg Address.global indices
  · intro located
    have kind := (stateIndex_some (slotAddress_global located).2.2).2.2.2.1
    simp only [FrameLayout.place, located, PackageBindings.StateDeclaration.cell, kind]

/-- Writable source names use exactly the original state declaration's kind
and ordinal, even after native frame compaction or same-spelled local shadowing. -/
theorem writableName_stateTarget_iff {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {position after : Nat} {cell : ScalarProcedures.Cell}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (source : WritableNameAt text context position after cell)
    (identity : Nat) (positive : 0 < identity) (bound : Nat) :
    ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls text context info position = identity ↔
      (layout bound info context).place cell = .global ((info.stateAt identity).cell identity) := by
  cases source with
  | @name first bytes skipped nonzero identifier spelling =>
    have valid := ApplicationPackageNames.identifier_validName validText (Nat.pos_of_ne_zero nonzero) identifier
    have ended : nameAfter text first = after := by
      simp only [nameAfter, nonzero, ↓reduceIte, Named.identifierEnd_complete identifier]
    cases spelling with
    | integer found live =>
      exact (stateTarget_integer_iff declarations positive live skipped ended valid found).trans integer_place_iff.symm
    | boolean absent found live =>
      exact (stateTarget_boolean_iff declarations positive live skipped ended valid absent found).trans boolean_place_iff.symm

theorem layout_global_state {info : PackageBindings.Metadata} {context : ParseContext}
    {bound : Nat} {cell global : Cell}
    (placed : (layout bound info context).place cell = .global global) :
    ∃ identity, 0 < identity ∧ identity ≤ info.states.length ∧ global = (info.stateAt identity).cell identity := by
  cases cell with
  | integer slot =>
    cases located : (layout bound info context).integers slot with
    | «local» index => simp only [FrameLayout.place, located] at placed; contradiction
    | global identity =>
      have state := stateIndex_some (slotAddress_global located).2.2
      have same : ScalarProcedures.Cell.integer identity = global :=
        Place.global.inj (by simpa only [FrameLayout.place, located] using placed)
      exact ⟨identity, state.1, state.2.1, by
        rw [← same]; simp only [PackageBindings.StateDeclaration.cell, state.2.2.2.1]⟩
  | boolean slot =>
    cases located : (layout bound info context).booleans slot with
    | «local» index => simp only [FrameLayout.place, located] at placed; contradiction
    | global identity =>
      have state := stateIndex_some (slotAddress_global located).2.2
      have same : ScalarProcedures.Cell.boolean identity = global :=
        Place.global.inj (by simpa only [FrameLayout.place, located] using placed)
      exact ⟨identity, state.1, state.2.1, by
        rw [← same]; simp only [PackageBindings.StateDeclaration.cell, state.2.2.2.1]⟩

end Silver.ApplicationPackageFrameLayout

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings Packages
open ApplicationPackageFrameLayout

theorem ArgumentAt.target_state {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {parameter : Formal} {row : PackageActual}
    {object : ScalarFunctions.Target}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (source : ArgumentAt text context input parameter row (.target object))
    (accepted : row.after ≠ 0) (identity : Nat) (positive : 0 < identity) (bound : Nat) :
    modelCalls.stateTarget text context.model info row.first = identity ↔
      (layout bound info context.model).place (ScalarProcedures.targetCell object) =
        .global ((info.stateAt identity).cell identity) := by
  cases source with
  | target writable parsed ends meaning =>
    have present : (procedureTargetActual text context.model row.first input.scan.facts
        (outputFormal parameter)).after ≠ 0 := by rw [parsed, ← ends]; exact accepted
    have named := procedureTargetActual_name present
    rw [parsed] at named
    exact writableName_stateTarget_iff validText declarations named identity positive bound

/-- The semantic output list is obtained from the exact source rows in formal
order. Input arguments never add a target, and named association reordering
does not change any target's own source identity. -/
theorem FormalArgumentsAt.writable_state_cells {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {frame : ActualFrame}
    {slots : List Nat} {arguments : List ScalarProcedures.Actual}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (source : FormalArgumentsAt text context input info frame slots arguments)
    (accepted : ∀ slot ∈ slots, (frame.actual slot).after ≠ 0)
    (identity : Nat) (positive : 0 < identity) (bound : Nat) :
    (∃ slot ∈ slots, (info.parameterAt slot).mode ≠ .input ∧
      modelCalls.stateTarget text context.model info (frame.actual slot).first = identity) ↔
    (info.stateAt identity).cell identity ∈ globalCells (layout bound info context.model)
      ((ScalarProcedures.writableTargets arguments).map ScalarProcedures.targetCell) := by
  induction source with
  | nil => simp only [List.not_mem_nil, false_and, exists_false, ScalarProcedures.writableTargets,
      List.map_nil, globalCells, List.filterMap_nil]
  | @cons slot slots argument arguments head tail ih =>
    have later := ih (fun index member => accepted index (List.mem_cons_of_mem _ member))
    simp only [List.mem_cons, or_and_right, exists_or, exists_eq_left]
    cases head with
    | value mode source readable fits =>
      simp only [mode, ne_eq, not_true_eq_false, false_and, false_or, ScalarProcedures.writableTargets]
      exact later
    | target writable parsed ends meaning =>
      have headSource : ArgumentAt text context input (info.parameterAt slot) (frame.actual slot)
          (.target (procedureTargetIdentity context.model (frame.actual slot).target)) :=
        .target writable parsed ends meaning
      have target := headSource.target_state validText declarations (accepted slot List.mem_cons_self)
        identity positive bound
      rw [and_iff_right writable, target, later]
      simp only [ScalarProcedures.writableTargets, List.map_cons, globalCells_mem, List.mem_cons,
        or_and_right, exists_or, exists_eq_left]

/-- A procedure's raw write mask denotes exactly the callee write effect plus
the original explicit writable targets. The global-cell set uses the concrete
source-derived frame layout, not a caller-provided effect correspondence. -/
theorem readActuals_write_cells {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {position : Nat}
    {frame : ActualFrame} {entries : List (Nat × PackageActual)} {arguments : List ScalarProcedures.Actual}
    {actuals : ScalarProcedures.ActualBindings}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (read : readActuals modelCalls text context.model input info item position = some frame)
    (source : ActualListAt modelCalls text context.model input info item position frame entries)
    (semantic : FormalArgumentsAt text context input info frame (formalSlots item) arguments)
    (binding : ScalarProcedures.bindActuals ((item.formals info).map Formal.semantic) arguments = some actuals)
    (first : 0 < item.count → 0 < item.formalFirst)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ maxFormals)
    (identity : Nat) (positive : 0 < identity) (active : identity ≤ info.states.length)
    (inside : identity ≤ item.mayWrite.length) (bound : Nat) :
    (info.stateAt identity).cell identity ∈ info.effectCells frame.callWrites ↔
      (info.stateAt identity).cell identity ∈ (item.effects info).writes ++
        globalCells (layout bound info context.model) (actuals.outputs.map ScalarProcedures.targetCell) := by
  rw [info.effectCells_index positive active,
    readActuals_writable_bits (stateTarget_zero text context.model info) read first capacity identity positive inside,
    semantic.writable_state_cells validText declarations
      (fun slot member => (source.slot_positions capacity slot member).2) identity positive bound,
    List.mem_append, ScalarProcedures.bindActuals_outputs binding]
  change _ ↔ (info.stateAt identity).cell identity ∈ info.effectCells item.mayWrite ∨ _
  rw [info.effectCells_index positive active]

/-- Exact membership for every semantic cell, including cells not in the state
schema. The concrete layout ensures that no explicit global output escapes the
original state table. -/
theorem readActuals_effect_cells {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {position : Nat}
    {frame : ActualFrame} {entries : List (Nat × PackageActual)} {arguments : List ScalarProcedures.Actual}
    {actuals : ScalarProcedures.ActualBindings}
    (validText : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (read : readActuals modelCalls text context.model input info item position = some frame)
    (source : ActualListAt modelCalls text context.model input info item position frame entries)
    (semantic : FormalArgumentsAt text context input info frame (formalSlots item) arguments)
    (binding : ScalarProcedures.bindActuals ((item.formals info).map Formal.semantic) arguments = some actuals)
    (first : 0 < item.count → 0 < item.formalFirst)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ maxFormals)
    (maskCapacity : info.states.length ≤ item.mayWrite.length) (bound : Nat) (cell : Cell) :
    cell ∈ info.effectCells frame.callWrites ↔
      cell ∈ (item.effects info).writes ++
        globalCells (layout bound info context.model) (actuals.outputs.map ScalarProcedures.targetCell) := by
  have exactCell (identity : Nat) (positive : 0 < identity) (active : identity ≤ info.states.length) :=
    readActuals_write_cells validText declarations read source semantic binding first capacity
      identity positive active (Nat.le_trans active maskCapacity) bound
  constructor
  · intro written
    obtain ⟨offset, active, _, same⟩ := (info.mem_effectCells _ _).mp written
    rw [same] at written ⊢
    exact (exactCell (offset + 1) (by omega) (by omega)).mp written
  · intro written
    have original : ∃ identity, 0 < identity ∧ identity ≤ info.states.length ∧
        cell = (info.stateAt identity).cell identity := by
      rcases List.mem_append.mp written with implicit | explicit
      · obtain ⟨offset, active, _, same⟩ := (info.mem_effectCells _ _).mp implicit
        exact ⟨offset + 1, by omega, by omega, same⟩
      · obtain ⟨target, _, placed⟩ := globalCells_mem.mp explicit
        exact layout_global_state placed
    obtain ⟨identity, positive, active, same⟩ := original
    rw [same] at written ⊢
    exact (exactCell identity positive active).mpr written

end Silver.ApplicationPackageCalls
