module

public import Silver.ApplicationPackageInitializerInventory
public import Silver.ApplicationPackageDeclarationsMetadataTypes
public import Silver.ApplicationPackageBodiesUnit
public import Silver.ApplicationPackageObjectExtent
public import Silver.ApplicationPackageDeclarationsObjectInitializerBounds

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageObjectRows PackageBindings

set_option backward.dsimp.instances true

private theorem type_identity (text : Source) (frame : ParserState) (info : Metadata)
    (capacity : info.exports.length ≤ maxExports) (position : Nat) :
    (packageTypeAt text frame info position).identity ≤ maxExports + 1 := by
  have bound := lookupFrom_bound (metadataText text)
    ⟨skipAt text position, nameAfter text (skipAt text position)⟩
    (fun index => (info.exportAt index).name) info.exports.length
  unfold packageTypeAt
  dsimp only
  split
  · change 1 ≤ maxExports + 1; omega
  · split
    · exact Nat.zero_le _
    · split
      · change 1 ≤ maxExports + 1; omega
      · split
        · change lookupExport (metadataText text) info _ + 1 ≤ _
          change lookupExport (metadataText text) info _ ≤ info.exports.length at bound
          omega
        · change 1 ≤ maxExports + 1; omega

/-- Export identities use the actual bounded native export table. -/
theorem package_type_identity (text : Source) (frame : ParserState) (info : Metadata)
    (capacity : info.exports.length ≤ maxExports) (position : Nat) :
    (packageTypeAt text frame info position).identity ≤ maxExports + 1 :=
  type_identity text frame info capacity position

private def InitialBound (out : ObjectResult) : Prop :=
  out.frame.position ≠ 0 → out.initialBounds.Bounded

private theorem initial_invalid : InitialBound invalidObject := fun live => (live rfl).elim

private theorem initial_finish (calls : ObjectCalls) (text : Source) (frame : ParserState)
    (out : ObjectResult) (bounded : out.initialBounds.Bounded) :
    InitialBound (finishObject calls text frame out) := by
  dsimp only [finishObject]
  split
  · exact initial_invalid
  · exact fun _ => bounded

private theorem initial_boolean_finish (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (first last constant after : Nat) (localObject : Bool)
    (out : ObjectResult) :
    InitialBound (objectBooleanFinish (modelObjectCalls reader) text frame first last constant after localObject out) := by
  apply initial_finish
  change (Integer.Interval.singleton (if out.booleanValue then 1 else 0)).Bounded
  cases out.booleanValue <;> decide

private theorem initial_boolean (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (first last constant : Nat) (localObject : Bool)
    (out : ObjectResult) :
    InitialBound (objectBoolean (modelObjectCalls reader) text frame first last constant localObject out) := by
  dsimp only [objectBoolean]
  split
  · exact initial_invalid
  · split
    · split
      · exact initial_invalid
      · exact initial_boolean_finish reader text frame first last constant _ localObject _
    · exact initial_boolean_finish reader text frame first last constant _ localObject _

private theorem initial_scalar (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (first last constant : Nat) (localObject : Bool)
    (out : ObjectResult) (range : ScalarConstraintResult)
    (bounds : range.bounds.Bounded) :
    InitialBound (objectScalar (modelObjectCalls reader) text frame first last constant localObject out range) := by
  dsimp only [objectScalar]
  split
  · exact initial_invalid
  · rename_i accepted
    apply initial_finish
    simp only [modelObjectCalls, Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true',
      decide_eq_true_eq, not_or, Integer.Interval.isEmpty] at accepted
    change (ScalarExpression.read text out.initFirst out.frame.scalarNames first last (elaborating := true)).bounds.Bounded
    unfold Integer.Interval.Bounded Integer.InRange at bounds ⊢
    simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_false,
      decide_eq_true_eq] at accepted
    omega

private theorem initial_initialized (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (first last constant : Nat) (localObject : Bool)
    (out : ObjectResult) (range : ScalarConstraintResult) (bounded : range.bounds.Bounded) :
    InitialBound (objectInitialized (modelObjectCalls reader) text frame first last constant localObject out range) := by
  dsimp only [objectInitialized]
  split
  · exact initial_invalid
  · split
    · exact initial_scalar reader text frame first last constant localObject _ range bounded
    · exact initial_boolean reader text frame first last constant localObject _

private theorem initial_typed (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (info : Metadata) (first last colon constant : Nat)
    (localObject : Bool) (out : ObjectResult)
    (framed : out.frame.position ≠ 0 → ReaderFrame text out.frame)
    (colonBound : ValidCursor text colon) (constantBound : ValidCursor text constant) :
    InitialBound (objectTyped (modelObjectCalls reader) text frame info first last colon constant localObject out) := by
  dsimp only [objectTyped]
  split
  · exact initial_invalid
  · rename_i active
    have present : out.frame.position ≠ 0 := by simpa only [decide_eq_true_eq] using active
    let position := if decide (constant = 0) then colon else constant
    have cursor : ValidCursor text position := by dsimp only [position]; split <;> assumption
    let mark := packageTypeAt text out.frame info position
    let seed := {out with constantObject := decide (constant ≠ 0), mark}
    change InitialBound (if decide (mark.after = 0) then invalidObject else
      if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text frame first last constant localObject seed
          (scalarConstraintAt text mark.after out.frame.scalarNames mark.bounds)
      else objectInitialized (modelObjectCalls reader) text frame first last constant localObject seed ⟨mark.after, mark.bounds⟩)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact initial_invalid
    · simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      have domain := (package_type_domain text out.frame info position (framed present) cursor).resolve_left absent
      by_cases kind : mark.kind = .integer
      · simp only [kind, decide_true, ↓reduceIte]
        apply initial_initialized
        exact scalarConstraintAt_bounded_all text mark.after out.frame.scalarNames domain.cursor domain.bounded
      · simp only [kind, decide_false, Bool.false_eq_true, ↓reduceIte]
        exact initial_initialized reader text frame first last constant localObject seed ⟨mark.after, mark.bounds⟩ domain.bounded

private theorem object_initial_bound (reader : BooleanElaboration.Native.Reader)
    (text : Source) (frame : ParserState) (framed : ReaderFrame text frame) (info : Metadata) (localObject : Bool) :
    InitialBound (objectStep (modelObjectCalls reader) text frame info localObject) := by
  dsimp only [objectStep, objectNameStep, modelObjectCalls]
  split
  · exact initial_invalid
  · cases localObject with
    | true =>
      simp only [↓reduceIte]
      apply initial_typed
      · exact fun present => framed.hide_outer info _ present
      · exact fixedAfter_result_bound text _ ":" false (by decide)
      · exact fixedAfter_result_bound text _ "constant" true (by decide)
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      split
      · apply initial_typed
        · exact fun _ => framed.hidden_name _
        · exact fixedAfter_result_bound text _ ":" false (by decide)
        · exact fixedAfter_result_bound text _ "constant" true (by decide)
      · exact initial_invalid

/-- The native state-table entry's component types follow from the original
Object call and its reader frame, without requiring valid package metadata. -/
theorem object_state_typed (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : Metadata) (capacity : info.exports.length ≤ maxExports) (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    (stateDeclaration (objectStep (modelObjectCalls reader) text frame info localObject)).Typed := by
  let out := objectStep (modelObjectCalls reader) text frame info localObject
  let base := initializerBase text frame info (objectName text frame) localObject
  let name := objectName text frame
  let colon := tokenAfter text name.after (.symbol ":")
  let constant := tokenAfter text colon (.word "constant")
  let position := if decide (constant = 0) then colon else constant
  let mark := packageTypeAt text base info position
  let range := if mark.kind = .integer then scalarConstraintAt text mark.after base.scalarNames mark.bounds
    else ⟨mark.after, mark.bounds⟩
  have header := object_header_calls reader text frame framed info localObject present
  change ValidCursor text position ∧ mark.after ≠ 0 ∧ ValidCursor text mark.after ∧ range.after ≠ 0 ∧
    out.mark = {mark with bounds := range.bounds} ∧ _ at header
  have baseFrame := object_initializer_frame reader text frame framed info localObject present
  have domain := (package_type_domain text base info position baseFrame header.1).resolve_left header.2.1
  have bound : range.bounds.Bounded := by
    dsimp only [range]
    split
    · exact scalarConstraintAt_bounded_all text mark.after base.scalarNames domain.cursor domain.bounded
    · exact domain.bounded
  have positions := objectStep_positions reader text frame info localObject present
  have cursors := objectStep_initializer_bounds reader text frame info localObject present
  have textBound := valid.2
  refine ⟨?_, ?_, ?_, object_initial_bound reader text frame framed info localObject present, ?_, ?_, ?_⟩
  · change out.name.Typed
    unfold NameSpan.Typed
    constructor <;> dsimp only [out] <;> omega
  · change out.mark.name.Typed
    rw [header.2.2.2.2.1]
    exact MetadataTypes.type_name valid base info position
  · change out.mark.bounds.Bounded
    rw [header.2.2.2.2.1]
    exact bound
  · change out.mark.identity ≤ _
    rw [header.2.2.2.2.1]
    exact type_identity text base info capacity position
  · exact Nat.le_trans cursors.1 (Nat.add_le_add_right valid.2 1)
  · exact Nat.le_trans cursors.2 (Nat.add_le_add_right valid.2 1)

end Silver.ApplicationPackageBodies
