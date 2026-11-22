module

public import Silver.ApplicationPackageTypes
public import Silver.ApplicationPackageNames
public import Silver.ProcedureNameScanner

@[expose] public section

/-! Exact equations for package-state visibility, assignment targets and read
sets. Original declaration spans distinguish a hidden package cell from a local
with the same spelling. The read set retains all fixed-capacity bits. Imported
operations remain explicit until their checked native meanings are composed. -/
namespace Silver.ApplicationPackageEffects
open Compose Predicate

structure Calls where
  validName : Source → PackageBindings.NameSpan → Bool
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  booleanLookup : Source → BooleanBindings.Environment → Nat → Nat → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookupState : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Nat
  actualNameFree : Source → Nat → Nat → Nat → Nat → Bool

def visibleState (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (index : Nat) : Bool :=
  let item := info.stateAt index
  let name := item.name
  if index > info.states.length ∨ calls.validName text name = false then false
  else
    let scalar := calls.scalarLookup text context.scalarNames name.first name.after
    if item.kind = .integer then
      decide (scalar ≠ 0) &&
        decide ((ScalarExpression.binding context.scalarNames scalar).first = name.first) &&
        decide ((ScalarExpression.binding context.scalarNames scalar).after = name.after)
    else if scalar ≠ 0 then false
    else
      let flag := calls.booleanLookup text context.booleanNames name.first name.after
      decide (flag ≠ 0) &&
        decide ((BooleanBindings.binding context.booleanNames flag).first = name.first) &&
        decide ((BooleanBindings.binding context.booleanNames flag).after = name.after)

def stateTarget (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (position : Nat) : Nat :=
  let first := calls.skip text position
  let last := calls.nameAfter text first
  let found := calls.lookupState text info ⟨first, last⟩
  if found ≠ 0 ∧ visibleState calls text context info found = true then found else 0

def readStep (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat)
    (result : PackageBindings.StateSet) (index : Nat) : PackageBindings.StateSet :=
  if visibleState calls text context info index then
    result.set (index - 1) (!calls.actualNameFree text first after
      (info.stateAt index).name.first (info.stateAt index).name.after)
  else result

def stateReads (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat) : PackageBindings.StateSet :=
  if first = 0 ∨ after ≤ first then PackageBindings.emptyStateSet
  else ((List.range info.states.length).map (· + 1)).foldl
    (readStep calls text context info first after) PackageBindings.emptyStateSet

theorem visibleState_guard {calls : Calls} {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {index : Nat}
    (visible : visibleState calls text context info index = true) :
    index ≤ info.states.length ∧ calls.validName text (info.stateAt index).name = true := by
  dsimp only [visibleState] at visible
  split at visible
  · contradiction
  · rename_i accepted
    have bounds := not_or.mp accepted
    exact ⟨Nat.le_of_not_gt bounds.1, by simpa only [Bool.not_eq_false] using bounds.2⟩

theorem stateTarget_bound (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (position : Nat) :
    stateTarget calls text context info position ≤ info.states.length := by
  dsimp only [stateTarget]
  split
  · rename_i accepted
    exact (visibleState_guard accepted.2).1
  · exact Nat.zero_le _

theorem readStep_length (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat)
    (result : PackageBindings.StateSet) (index : Nat) :
    (readStep calls text context info first after result index).length = result.length := by
  unfold readStep
  split <;> simp

theorem readStep_suffix (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat)
    (result : PackageBindings.StateSet) (index slot : Nat)
    (positive : 0 < index) (bounded : index ≤ info.states.length)
    (beyond : info.states.length < slot) :
    PackageBindings.StateSet.get (readStep calls text context info first after result index) slot =
      PackageBindings.StateSet.get result slot := by
  unfold readStep
  split
  · simp only [PackageBindings.StateSet.get, List.getD_eq_getElem?_getD,
      List.getElem?_set_ne (by omega : index - 1 ≠ slot - 1)]
  · rfl

theorem readsFold_length (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat)
    (indices : List Nat) (result : PackageBindings.StateSet) :
    (indices.foldl (readStep calls text context info first after) result).length = result.length := by
  induction indices generalizing result with
  | nil => rfl
  | cons index rest ih => rw [List.foldl_cons, ih, readStep_length]

theorem readsFold_suffix (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat) (indices : List Nat)
    (bounds : ∀ index ∈ indices, 0 < index ∧ index ≤ info.states.length)
    (result : PackageBindings.StateSet) (slot : Nat) (beyond : info.states.length < slot) :
    PackageBindings.StateSet.get
      (indices.foldl (readStep calls text context info first after) result) slot =
      PackageBindings.StateSet.get result slot := by
  induction indices generalizing result with
  | nil => rfl
  | cons index rest ih =>
      rw [List.foldl_cons, ih (fun i member => bounds i (by simp [member]))]
      exact readStep_suffix calls text context info first after result index slot
        (bounds index (by simp)).1 (bounds index (by simp)).2 beyond

theorem stateReads_length (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat) :
    (stateReads calls text context info first after).length = PackageBindings.maxStates := by
  unfold stateReads
  split
  · simp [PackageBindings.emptyStateSet]
  · rw [readsFold_length]
    simp [PackageBindings.emptyStateSet]

theorem stateReads_within (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat) :
    PackageBindings.within (stateReads calls text context info first after) info.states.length = true := by
  have suffix (slot : Nat) (beyond : info.states.length < slot) :
      PackageBindings.StateSet.get (stateReads calls text context info first after) slot = false := by
    unfold stateReads
    split
    · simp only [PackageBindings.emptyStateSet, PackageBindings.StateSet.get,
        List.getD_eq_getElem?_getD, List.getElem?_replicate]
      split <;> rfl
    · rw [readsFold_suffix calls text context info first after _ ?_ _ slot beyond]
      · simp only [PackageBindings.emptyStateSet, PackageBindings.StateSet.get,
          List.getD_eq_getElem?_getD, List.getElem?_replicate]
        split <;> rfl
      · intro index member
        obtain ⟨original, originalMember, same⟩ := List.mem_map.mp member
        have bound := List.mem_range.mp originalMember
        subst index
        omega
  simp only [PackageBindings.within, List.all_eq_true]
  intro index _
  split
  · rename_i beyond
    simp only [suffix (index + 1) beyond, Bool.not_false]
  · rfl

def modelCalls : Calls where
  validName text name := PackageBindings.validName (ApplicationPackageNames.metadataText text) name
  scalarLookup text names first after := ScalarExpression.lookup text names first after
  booleanLookup text names first after := BooleanBindings.lookup text names first after
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookupState text info name := PackageBindings.lookupState (ApplicationPackageNames.metadataText text) info name
  actualNameFree := actualNameFree

end Silver.ApplicationPackageEffects
