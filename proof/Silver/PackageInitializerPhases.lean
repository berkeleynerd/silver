module

public import Silver.PackageInitializationRanges

@[expose] public section

namespace Silver.Packages
open Predicate

/-- The original bodyEnvironment stage widens mutable invocation-local rows.
Immutable rows keep their inferred snapshot. The selected targets and the
phase boundary are recovered from source declaration/output histories. -/
def SharedRanges.widenLocals (current declared : SharedRanges) (mutable : List Cell) : SharedRanges :=
  {current with locals := fun slot =>
    if ScalarProcedures.Cell.integer slot ∈ mutable then declared.locals slot else current.locals slot}

theorem SharedRanges.widenLocals_selected (current declared : SharedRanges) (mutable : List Cell)
    {slot : Nat} (selected : ScalarProcedures.Cell.integer slot ∈ mutable) :
    (current.widenLocals declared mutable).locals slot = declared.locals slot := by
  simp only [widenLocals, selected, ite_true]

theorem SharedRanges.widenLocals_unselected (current declared : SharedRanges) (mutable : List Cell)
    {slot : Nat} (unchanged : ScalarProcedures.Cell.integer slot ∉ mutable) :
    (current.widenLocals declared mutable).locals slot = current.locals slot := by
  simp only [widenLocals, unchanged, ite_false]

theorem SharedRanges.Refines.widenLocals {current declared : SharedRanges}
    (refined : current.Refines declared) (mutable : List Cell) :
    (current.widenLocals declared mutable).Refines declared := by
  refine ⟨refined.1, ?_⟩
  intro slot bounds found
  by_cases selected : ScalarProcedures.Cell.integer slot ∈ mutable
  · exact ⟨bounds, by simpa only [SharedRanges.widenLocals, selected, ite_true] using found, fun _ h => h⟩
  · obtain ⟨actual, present, within⟩ := refined.2 slot bounds found
    exact ⟨actual, by simpa only [SharedRanges.widenLocals, selected, ite_false] using present, within⟩

theorem SharedRanges.Refines.widenLocals_fits {current declared : SharedRanges} {state : SharedState}
    (refined : current.Refines declared) (fitting : current.Fits state) (mutable : List Cell) :
    (current.widenLocals declared mutable).Fits state := by
  refine ⟨fitting.1, ?_⟩
  intro slot bounds found
  by_cases selected : ScalarProcedures.Cell.integer slot ∈ mutable
  · exact refined.2.fits fitting.2 slot bounds
      (by simpa only [SharedRanges.widenLocals, selected, ite_true] using found)
  · exact fitting.2 slot bounds
      (by simpa only [SharedRanges.widenLocals, selected, ite_false] using found)

structure InitializerPhases where
  locals : List LocalInitializer
  outputs : List LocalInitializer
  mutableLocals : List Cell

structure InitializedRanges where
  initialized : SharedRanges
  body : SharedRanges

def InitializerPhases.items (phases : InitializerPhases) : List LocalInitializer :=
  phases.locals ++ phases.outputs

def InitializerPhases.localDomains (phases : InitializerPhases) (entry : SharedRanges) : SharedRanges :=
  initializerDomains entry phases.locals

def InitializerPhases.declared (phases : InitializerPhases) (entry : SharedRanges) : SharedRanges :=
  initializerDomains (phases.localDomains entry) phases.outputs

def InitializerPhases.outputEntry (phases : InitializerPhases) (entry locals : SharedRanges) : SharedRanges :=
  locals.widenLocals (phases.localDomains entry) phases.mutableLocals

def InitializerPhases.bodyEntry (phases : InitializerPhases) (entry outputs : SharedRanges) : SharedRanges :=
  outputs.widenLocals (phases.declared entry) (phases.mutableLocals ++ phases.outputs.map LocalInitializer.target)

/-- All output RHSs retain their original pre-output layouts. They are read
before their rows become visible; changing the abstract ranges never changes
those layouts or the executable initialization order. -/
def InitializerPhases.check (phases : InitializerPhases) (entry : SharedRanges) : Option InitializedRanges :=
  (checkInitializers entry phases.locals).bind fun locals =>
    (checkInitializers (phases.outputEntry entry locals) phases.outputs).map fun outputs =>
      ⟨outputs, phases.bodyEntry entry outputs⟩

theorem InitializerPhases.check_success {phases : InitializerPhases} {entry : SharedRanges}
    {result : InitializedRanges} (checked : phases.check entry = some result) :
    ∃ locals, checkInitializers entry phases.locals = some locals ∧
      checkInitializers (phases.outputEntry entry locals) phases.outputs = some result.initialized ∧
      result.body = phases.bodyEntry entry result.initialized := by
  simp only [check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
  obtain ⟨locals, first, outputs, last, rfl⟩ := checked
  exact ⟨locals, first, last, rfl⟩

theorem initializerDomains_append (entry : SharedRanges) (first rest : List LocalInitializer) :
    initializerDomains entry (first ++ rest) = initializerDomains (initializerDomains entry first) rest := by
  induction first generalizing entry with
  | nil => rfl
  | cons head tail ih => exact ih _

theorem InitializerPhases.declared_items (phases : InitializerPhases) (entry : SharedRanges) :
    phases.declared entry = initializerDomains entry phases.items :=
  (initializerDomains_append entry phases.locals phases.outputs).symm

theorem InitializerPhases.check_refines {phases : InitializerPhases} {entry : SharedRanges}
    {result : InitializedRanges} (checked : phases.check entry = some result) :
    result.initialized.Refines (phases.declared entry) ∧ result.body.Refines (phases.declared entry) := by
  obtain ⟨locals, first, last, body⟩ := phases.check_success checked
  have localRefines := checkInitializers_refines first (SharedRanges.refines_refl entry)
  have outputRefines := checkInitializers_refines last (localRefines.widenLocals phases.mutableLocals)
  refine ⟨outputRefines, ?_⟩
  rw [body]
  exact outputRefines.widenLocals _

theorem initializeLocals_append (state : SharedState) (first rest : List LocalInitializer) :
    initializeLocals state (first ++ rest) = initializeLocals (initializeLocals state first) rest := by
  induction first generalizing state with
  | nil => rfl
  | cons head tail ih => exact ih _

theorem checkedInitializeLocals_append (state : SharedState) (first rest : List LocalInitializer) :
    checkedInitializeLocals state (first ++ rest) =
      (checkedInitializeLocals state first).bind fun middle => checkedInitializeLocals middle rest := by
  induction first generalizing state with
  | nil => rfl
  | cons head tail ih =>
    simp only [List.cons_append, checkedInitializeLocals, Option.bind_assoc]
    congr 1
    funext value
    split
    · exact ih _
    · rfl

theorem InitializersSafe.append {state : SharedState} {first rest : List LocalInitializer}
    (left : InitializersSafe state first) (right : InitializersSafe (initializeLocals state first) rest) :
    InitializersSafe state (first ++ rest) := by
  induction first generalizing state with
  | nil => exact right
  | cons head tail ih => exact ⟨left.1, left.2.1, ih left.2.2 right⟩

theorem InitializerPhases.check_sound {phases : InitializerPhases} {entry : SharedRanges}
    {result : InitializedRanges} {state : SharedState}
    (checked : phases.check entry = some result)
    (readable : ∀ item ∈ phases.items, item.Readable) (fitting : entry.Fits state) :
    InitializersSafe state phases.items ∧
      result.initialized.Fits (initializeLocals state phases.items) ∧
      result.body.Fits (initializeLocals state phases.items) ∧
      checkedInitializeLocals state phases.items = some (initializeLocals state phases.items) := by
  obtain ⟨locals, first, last, body⟩ := phases.check_success checked
  have localSound := checkInitializers_sound first
    (fun item member => readable item (List.mem_append_left phases.outputs member)) fitting
  have localRefines := checkInitializers_refines first (SharedRanges.refines_refl entry)
  have outputSound := checkInitializers_sound last
    (fun item member => readable item (List.mem_append_right phases.locals member))
    (localRefines.widenLocals_fits localSound.2.1 phases.mutableLocals)
  have refines := (phases.check_refines checked).1
  have bodyFit : result.body.Fits (initializeLocals (initializeLocals state phases.locals) phases.outputs) := by
    rw [body]
    exact refines.widenLocals_fits outputSound.2.1 _
  refine ⟨localSound.1.append outputSound.1, ?_, ?_, ?_⟩
  · simpa only [InitializerPhases.items, initializeLocals_append] using outputSound.2.1
  · simpa only [InitializerPhases.items, initializeLocals_append] using bodyFit
  · simp only [InitializerPhases.items, checkedInitializeLocals_append,
      localSound.2.2, Option.bind_some, outputSound.2.2, initializeLocals_append]

def InitializerPhases.obligations (phases : InitializerPhases) (entry : SharedRanges) : List Obligation :=
  initializersObligations entry phases.locals ++
    match checkInitializers entry phases.locals with
    | none => [.impossible]
    | some locals => initializersObligations (phases.outputEntry entry locals) phases.outputs

theorem InitializerPhases.obligations_discharge {phases : InitializerPhases} {entry : SharedRanges}
    {result : InitializedRanges} (checked : phases.check entry = some result) :
    discharged (phases.obligations entry) = true := by
  obtain ⟨locals, first, last, _⟩ := phases.check_success checked
  simp only [obligations, first, discharged_append,
    initializers_obligations_discharge first, initializers_obligations_discharge last, Bool.and_self]

end Silver.Packages
