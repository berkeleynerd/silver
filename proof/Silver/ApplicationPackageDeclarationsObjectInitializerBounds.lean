module

public import Silver.ApplicationPackageObjectCursors

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames

set_option backward.dsimp.instances true

namespace ObjectInitializerBounds

private def Bounded (text : Source) (result : ObjectResult) : Prop :=
  result.frame.position ≠ 0 → ValidCursor text result.initFirst ∧ ValidCursor text result.initAfter

private theorem invalid (text : Source) : Bounded text invalidObject := fun present => (present rfl).elim

private theorem finish (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (result : ObjectResult) (first : ValidCursor text result.initFirst) :
    Bounded text (finishObject (modelObjectCalls reader) text original result) := by
  dsimp only [finishObject]
  split
  · exact invalid text
  · intro present
    change fixedAfter text result.initAfter ";" false ≠ 0 at present
    have window := ApplicationPackageObjectRows.fixed_window (by decide) present
    exact ⟨first, Nat.le_trans (Nat.le_of_lt window.1) window.2⟩

private theorem boolean_finish (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant after : Nat) (localObject : Bool) (result : ObjectResult)
    (cursor : ValidCursor text result.initFirst) :
    Bounded text (objectBooleanFinish (modelObjectCalls reader) text original first last constant after localObject result) := by
  dsimp only [objectBooleanFinish]
  exact finish reader text original _ cursor

private theorem boolean (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult)
    (cursor : ValidCursor text result.initFirst) :
    Bounded text (objectBoolean (modelObjectCalls reader) text original first last constant localObject result) := by
  dsimp only [objectBoolean]
  split
  · exact invalid text
  · split
    · split
      · exact invalid text
      · exact boolean_finish reader text original first last constant _ localObject _ cursor
    · exact boolean_finish reader text original first last constant _ localObject _ cursor

private theorem scalar (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult)
    (cursor : ValidCursor text result.initFirst) :
    Bounded text (objectScalar (modelObjectCalls reader) text original first last constant localObject result range) := by
  dsimp only [objectScalar]
  split
  · exact invalid text
  · exact finish reader text original _ cursor

private theorem initialized (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult) :
    Bounded text (objectInitialized (modelObjectCalls reader) text original first last constant localObject result range) := by
  let typedSeed := {result with mark := {result.mark with bounds := range.bounds}}
  let seed := {typedSeed with initFirst := skipAt text (tokenAfter text range.after (.symbol ":="))}
  have cursor : ValidCursor text seed.initFirst :=
    model_skip_valid text _ (fixedAfter_result_bound text _ ":=" false (by decide))
  change Bounded text (if decide (seed.initFirst = 0) then invalidObject else
    if decide (seed.mark.kind = .integer) then
      objectScalar (modelObjectCalls reader) text original first last constant localObject seed range
    else objectBoolean (modelObjectCalls reader) text original first last constant localObject seed)
  split
  · exact invalid text
  · split
    · exact scalar reader text original first last constant localObject seed range cursor
    · exact boolean reader text original first last constant localObject seed cursor

attribute [local irreducible] objectInitialized

private theorem typed (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (info : PackageBindings.Metadata) (first last colon constant : Nat) (localObject : Bool) (result : ObjectResult) :
    Bounded text (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject result) := by
  unfold objectTyped
  by_cases zero : result.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
    exact invalid text
  · let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text result.frame info position
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    change Bounded text (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact invalid text
    · simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let seed := {result with constantObject := decide (constant ≠ 0), mark := mark}
      change Bounded text (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          (scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          ⟨mark.after, mark.bounds⟩)
      split
      · exact initialized reader text original first last constant localObject seed _
      · exact initialized reader text original first last constant localObject seed _

private theorem complete (reader : BooleanElaboration.Native.Reader) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) :
    Bounded text (objectStep (modelObjectCalls reader) text frame info localObject) := by
  dsimp only [objectStep, objectNameStep, modelObjectCalls]
  split
  · exact invalid text
  · cases localObject with
    | true =>
      simp only [↓reduceIte]
      exact typed reader text frame info _ _ _ _ true _
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      split
      · exact typed reader text frame info _ _ _ _ false _
      · exact invalid text

end ObjectInitializerBounds

/-- The original initializer token construction and final semicolon bound both
RHS cursors consumed by Completion's State_Reads, for every successful Object
result. No whole-state, metadata or initializer-acceptance premise is added. -/
theorem objectStep_initializer_bounds (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (info : PackageBindings.Metadata) (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    let result := objectStep (modelObjectCalls reader) text frame info localObject
    ValidCursor text result.initFirst ∧ ValidCursor text result.initAfter :=
  ObjectInitializerBounds.complete reader text frame info localObject present

end Silver.ApplicationPackageDeclarations
