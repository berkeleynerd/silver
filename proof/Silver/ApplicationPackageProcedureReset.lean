module

public import Silver.ApplicationPackageProcedureOutputs
public import Silver.PackageChecking

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true

/-- The exact scalar slots selected by the native visible-state reset. This
projection retains its order and does not require a globally valid metadata
table or a correspondence to a semantic frame layout. -/
def resetSlots (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (indices : List Nat) : List Nat :=
  indices.filterMap fun index =>
    let state := info.stateAt index
    if PackageBindings.StateSet.get writes index = true ∧
        calls.visibleState text context info index = true ∧ state.kind = .integer then
      some (calls.scalarLookup text context.scalarNames state.name.first state.name.after)
    else none

def resetSlotFlow (names : ScalarExpression.Environment) (flow : Flow) (slot : Nat) : Flow :=
  {flow with scalars := Integer.put flow.scalars slot (some (ScalarExpression.binding names slot).declaredBounds)}

def resetSlotsFlow (names : ScalarExpression.Environment) (slots : List Nat) (flow : Flow) : Flow :=
  slots.foldl (resetSlotFlow names) flow

theorem resetSlotsFlow_path (names : ScalarExpression.Environment) (slots : List Nat) (flow : Flow) :
    (resetSlotsFlow names slots flow).path = flow.path := by
  induction slots generalizing flow with
  | nil => rfl
  | cons slot slots ih => exact ih (resetSlotFlow names flow slot)

/-- Repeated selection is harmless: every selected slot is reset to the same
declaration range, independently of the incoming flow or reset order. -/
theorem resetSlotsFlow_scalars (names : ScalarExpression.Environment) (slots : List Nat)
    (flow : Flow) (slot : Nat) :
    (resetSlotsFlow names slots flow).scalars slot =
      if slot ∈ slots then some (ScalarExpression.binding names slot).declaredBounds else flow.scalars slot := by
  induction slots generalizing flow with
  | nil => simp only [resetSlotsFlow, List.foldl_nil, List.not_mem_nil, ↓reduceIte]
  | cons first rest ih =>
    rw [resetSlotsFlow, List.foldl_cons]
    change (resetSlotsFlow names rest (resetSlotFlow names flow first)).scalars slot = _
    rw [ih]
    by_cases later : slot ∈ rest <;> by_cases same : slot = first <;>
      simp only [later, same, List.mem_cons, resetSlotFlow, Integer.put, ↓reduceIte,
        true_or, or_true, false_or, ite_self]

private theorem visible_integer_slot {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {index : Nat}
    (visible : modelCalls.visibleState text context info index = true)
    (integer : (info.stateAt index).kind = .integer) :
    let slot := modelCalls.scalarLookup text context.scalarNames
      (info.stateAt index).name.first (info.stateAt index).name.after
    0 < slot ∧ slot ≤ context.scalarNames.length := by
  have bounded := ScalarExpression.lookup_bound text context.scalarNames
    (info.stateAt index).name.first (info.stateAt index).name.after
  dsimp only [modelCalls, ApplicationPackageEffects.visibleState, ApplicationPackageEffects.modelCalls] at visible
  split at visible
  · contradiction
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at visible
    exact ⟨Nat.pos_of_ne_zero visible.1.1, bounded⟩

theorem resetState_count (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (result : ApplicationCall) (index : Nat) :
    (resetState calls text context info writes result index).result.scan.count = result.result.scan.count := by
  unfold resetState
  dsimp only
  split <;> simp only [replaceScalar, BodyScan.count, ActiveFlow.replace_count]

private theorem resetState_flow {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet}
    {result : ApplicationCall} {index : Nat}
    (body : context.elaborating = false)
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (count : result.result.scan.count = context.scalarNames.length) :
    context.flow (resetState modelCalls text context info writes result index).result.scan.facts =
      resetSlotsFlow context.scalarNames (resetSlots modelCalls text context info writes [index])
        (context.flow result.result.scan.facts) := by
  unfold resetState resetSlots
  simp only [List.filterMap_cons, List.filterMap_nil]
  split
  · rename_i selected
    simp only [resetSlotsFlow, List.foldl_cons, List.foldl_nil, resetSlotFlow]
    have slot := visible_integer_slot selected.2.1 selected.2.2
    have changed := ArrayFlow.flow_replace (ArrayBindings.viewNames context.arrayNames) result.result.scan.facts
      (modelCalls.scalarLookup text context.scalarNames (info.stateAt index).name.first
        (info.stateAt index).name.after)
      (ScalarExpression.binding context.scalarNames
        (modelCalls.scalarLookup text context.scalarNames (info.stateAt index).name.first
          (info.stateAt index).name.after)).declaredBounds
      slot.1 (by change _ ≤ result.result.scan.count; rw [count]; exact slot.2)
      (Nat.le_trans slot.2 capacity)
    simpa only [replaceScalar, ArrayFlow.flow, ParseContext.flow, ArrayBindings.viewRanges,
      ArrayBindings.viewElaborating, body, Bool.false_and] using changed
  · simp only [resetSlotsFlow, List.foldl_nil]

/-- The complete native visible-global pass has this exact flow for arbitrary
metadata and write bits. Its ordinary scalar storage/capacity hypotheses suffice;
original-source layout correspondence is a later, separate composition. -/
theorem reset_fold_flow {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet}
    (indices : List Nat) (result : ApplicationCall)
    (body : context.elaborating = false)
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (count : result.result.scan.count = context.scalarNames.length) :
    let after := indices.foldl (resetState modelCalls text context info writes) result
    after.result.scan.count = result.result.scan.count ∧
      context.flow after.result.scan.facts =
        resetSlotsFlow context.scalarNames (resetSlots modelCalls text context info writes indices)
          (context.flow result.result.scan.facts) := by
  induction indices generalizing result with
  | nil => exact ⟨rfl, rfl⟩
  | cons index rest ih =>
    dsimp only [List.foldl_cons]
    have countSame := resetState_count modelCalls text context info writes result index
    obtain ⟨finalCount, finalFlow⟩ := ih _ (countSame.trans count)
    refine ⟨finalCount.trans countSame, ?_⟩
    rw [finalFlow, resetState_flow body capacity count]
    simp only [resetSlots, List.filterMap_cons]
    split <;> rfl

/-- A representation bridge for the later source layout proof. Its premises
state only which native slots denote the written global cells and their declared
ranges; no successful checker or semantic safety premise is introduced. -/
theorem resetSlotsFlow_global {names : ScalarExpression.Environment} {slots : List Nat}
    {declared : Integer.Ranges} {layout : Packages.FrameLayout} {writes : List ScalarProcedures.Cell}
    (selected : ∀ slot, slot ∈ slots ↔ ∃ identity,
      layout.integers slot = .global identity ∧ .integer identity ∈ writes)
    (ranges : ∀ slot ∈ slots, declared slot = some (ScalarExpression.binding names slot).declaredBounds)
    (flow : Flow) :
    resetSlotsFlow names slots flow = Packages.resetGlobalFlow declared layout writes flow := by
  have ext {left right : Flow} (path : left.path = right.path) (scalars : left.scalars = right.scalars) :
      left = right := by cases left; cases right; cases path; cases scalars; rfl
  apply ext
  · exact resetSlotsFlow_path names slots flow
  · funext slot
    rw [resetSlotsFlow_scalars]
    cases address : layout.integers slot with
    | «local» identity =>
      have absent : slot ∉ slots := by
        intro member
        obtain ⟨other, same, _⟩ := (selected slot).mp member
        rw [address] at same
        contradiction
      simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address, absent, ↓reduceIte]
    | global identity =>
      have member : slot ∈ slots ↔ ScalarProcedures.Cell.integer identity ∈ writes := by
        constructor
        · intro present
          obtain ⟨other, same, written⟩ := (selected slot).mp present
          have equal := Packages.Address.global.inj (address.symm.trans same)
          cases equal
          exact written
        · intro written
          exact (selected slot).mpr ⟨identity, address, written⟩
      by_cases written : ScalarProcedures.Cell.integer identity ∈ writes
      · have present := member.mpr written
        simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address, written,
          present, ↓reduceIte, ranges slot present]
      · have absent := mt member.mp written
        simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address, written, absent, ↓reduceIte]

end Silver.ApplicationPackageCalls
