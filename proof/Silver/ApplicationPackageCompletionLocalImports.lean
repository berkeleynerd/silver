module

public import Silver.ApplicationPackageCompletionLibraries

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames

/-- Congruence at the exact original local-loop call sites. The effect reader
is required only after Object's strict-progress guard. -/
theorem localStep_congr (actual model : CompletionCalls) (text : Source)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (state : InitializationFrame)
    (beginEq : actual.takeToken text state.frame.position (.word "begin") =
      model.takeToken text state.frame.position (.word "begin"))
    (skipEq : actual.skipAt text state.frame.position = model.skipAt text state.frame.position)
    (nameEq : actual.nameAfter text (model.skipAt text state.frame.position) =
      model.nameAfter text (model.skipAt text state.frame.position))
    (sameEq : ∀ index, actual.sameName text
      ⟨model.skipAt text state.frame.position, model.nameAfter text (model.skipAt text state.frame.position)⟩
      (info.parameterAt index).bodyName = model.sameName text
      ⟨model.skipAt text state.frame.position, model.nameAfter text (model.skipAt text state.frame.position)⟩
      (info.parameterAt index).bodyName)
    (objectEq : actual.objectAt text state.frame info true = model.objectAt text state.frame info true)
    (readsEq : let object := model.objectAt text state.frame info true
      state.frame.position < object.frame.position →
      actual.stateReads text (actual.contextOf ⟨object.frame, false, false⟩) info object.initFirst object.initAfter =
        model.stateReads text (model.contextOf ⟨object.frame, false, false⟩) info object.initFirst object.initAfter) :
    localStep actual text info item state = localStep model text info item state := by
  dsimp only [localStep]
  rw [beginEq]
  split
  · rfl
  · rw [skipEq, nameEq]
    simp only [sameEq]
    split
    · rfl
    · rw [objectEq]
      split
      · rfl
      · rename_i advanced
        rw [readsEq (Nat.lt_of_not_ge advanced)]

theorem localsFuel_congr {P : InitializationFrame → Prop}
    (actual model : InitializationFrame → LocalStep)
    (same : ∀ state, P state → actual state = model state)
    (preserved : ∀ state next, P state → model state = .continued next → P next)
    (fuel : Nat) (state : InitializationFrame) (prior : P state) :
    localsFuel actual fuel state = localsFuel model fuel state := by
  induction fuel generalizing state with
  | zero => rfl
  | succ fuel ih =>
    simp only [localsFuel, same state prior]
    cases selected : model state with
    | failed => rfl
    | finished result => rfl
    | continued next => exact ih next (preserved state next prior selected)

namespace Library

theorem context_of (library : Library) (reader : BooleanElaboration.Native.Reader) (scan : ScanResult) :
    (library.calls reader).contextOf scan = Predicate.contextOf scan :=
  library.leaves.flow.context_meaning scan

theorem body_of (library : Library) (reader : BooleanElaboration.Native.Reader) (scan : ScanResult)
    (bounded : scan.state.scalarNames.length ≤ ScalarExpression.maxBindings) :
    (library.calls reader).bodyOf scan = Predicate.bodyOf scan :=
  library.leaves.flow.body_meaning scan bounded

theorem local_step (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    localStep (library.calls reader) text info item state =
      localStep (library.model reader) text info item state := by
  apply localStep_congr
  · exact library.take reader valid state.frame.position framed.cursor (.word "begin") (by unfold ValidToken; decide)
  · exact library.skip reader valid state.frame.position framed.cursor
  · exact library.name reader valid (Compose.skipAt text state.frame.position) (model_skip_valid text _ framed.cursor)
  · intro index; exact library.same_name reader text _ _
  · exact library.object_at reader valid state.frame framed info true
  · dsimp only
    intro advanced
    have present : (objectStep (modelObjectCalls reader) text state.frame info true).frame.position ≠ 0 := by
      change state.frame.position < (objectStep (modelObjectCalls reader) text state.frame info true).frame.position at advanced
      omega
    have objectFrame := objectStep_reader_frame reader valid state.frame framed info true present
    have cursors := objectStep_initializer_bounds reader text state.frame info true present
    let scan : ScanResult := ⟨(objectStep (modelObjectCalls reader) text state.frame info true).frame, false, false⟩
    have contextValid := Adapter.context_valid text scan
      ⟨objectFrame.native.base, objectFrame.native.ready, objectFrame.native.bounds⟩
    rw [library.context_of]
    exact library.leaves.state_reads text valid (Adapter.contextOf scan) contextValid info _ _ cursors.1 cursors.2

theorem locals_fuel (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (fuel : Nat) (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) :
    localsFuel (localStep (library.calls reader) text info item) fuel state =
      localsFuel (localStep (library.model reader) text info item) fuel state :=
  localsFuel_congr (P := fun state => ReaderFrame text state.frame) _ _
    (fun state framed => library.local_step reader valid info item state framed)
    (fun state next framed selected => local_step_frame reader (LeafLibraries.model (library.calls reader))
      valid info item state next framed selected) fuel state framed

end Library
end Silver.ApplicationPackageCompletion
