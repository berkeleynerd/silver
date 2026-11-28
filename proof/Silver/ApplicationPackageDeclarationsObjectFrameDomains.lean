module

public import Silver.ApplicationPackageDeclarationsObjectFrameValidity

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace ObjectFrame

private def SuccessValid (text : Source) (result : ObjectResult) : Prop :=
  result.frame.position ≠ 0 → stateValid text result.frame = true

private theorem invalid (text : Source) : SuccessValid text invalidObject := fun present => (present rfl).elim

private theorem finish (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (result : ObjectResult) (valid : stateValid text result.frame = true) :
    SuccessValid text (finishObject (modelObjectCalls reader) text original result) := by
  dsimp only [finishObject]
  split
  · exact invalid text
  · exact fun _ => object_state_position valid _ (fixedAfter_result_bound text _ ";" false (by decide))

private theorem boolean_finish (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant after : Nat) (localObject : Bool) (result : ObjectResult)
    (valid : stateValid text result.frame = true) (span : ValidName text first last) :
    SuccessValid text (objectBooleanFinish (modelObjectCalls reader) text original first last constant after localObject result) := by
  dsimp only [objectBooleanFinish]
  apply finish
  exact object_state_boolean valid first last span _ _ _

private theorem boolean (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult)
    (valid : stateValid text result.frame = true) (span : ValidName text first last) :
    SuccessValid text (objectBoolean (modelObjectCalls reader) text original first last constant localObject result) := by
  dsimp only [objectBoolean]
  split
  · exact invalid text
  · split
    · split
      · exact invalid text
      · exact boolean_finish reader text original first last constant _ localObject _ valid span
    · exact boolean_finish reader text original first last constant _ localObject _ valid span

private theorem scalar (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult)
    (valid : stateValid text result.frame = true) (span : ValidName text first last) :
    SuccessValid text (objectScalar (modelObjectCalls reader) text original first last constant localObject result range) := by
  let value := ScalarExpression.read text result.initFirst result.frame.scalarNames first last (elaborating := true)
  dsimp only [objectScalar, modelObjectCalls]
  split
  · exact invalid text
  · rename_i accepted
    have nonempty : value.bounds.isEmpty = false := by
      cases empty : value.bounds.isEmpty
      · rfl
      · exact False.elim (accepted (by simp only [show (ScalarExpression.read text result.initFirst result.frame.scalarNames
          first last (elaborating := true)).bounds.isEmpty = true from empty, Bool.or_true, Bool.true_or]))
    have included : (!range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
        decide (value.bounds.upper ≤ range.bounds.upper)) = true := by
      cases inside : !range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
          decide (value.bounds.upper ≤ range.bounds.upper)
      · exact False.elim (accepted (by
          change ((((decide (value.after = 0) || value.bounds.isEmpty) ||
            !(value.bounds.isEmpty || (!range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
              decide (value.bounds.upper ≤ range.bounds.upper)))) ||
              (!localObject && decide (value.bounds.lower ≠ value.bounds.upper))) ||
                decide (result.frame.scalarNames.length = ScalarExpression.maxBindings)) = true
          simp only [nonempty, inside, Bool.false_or, Bool.not_false, Bool.or_true, Bool.true_or]))
      · rfl
    have bounds := Bool.and_eq_true_iff.mp included
    have lower := of_decide_eq_true (Bool.and_eq_true_iff.mp bounds.1).2
    have upper := of_decide_eq_true bounds.2
    apply finish
    exact object_state_scalar valid first last span value.bounds range.bounds nonempty lower upper _ _

private theorem initialized (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult)
    (valid : stateValid text result.frame = true) (span : ValidName text first last) :
    SuccessValid text (objectInitialized (modelObjectCalls reader) text original first last constant localObject result range) := by
  let typedSeed := {result with mark := {result.mark with bounds := range.bounds}}
  let seed := {typedSeed with initFirst := skipAt text (tokenAfter text range.after (.symbol ":="))}
  change SuccessValid text (if decide (seed.initFirst = 0) then invalidObject else
    if decide (seed.mark.kind = .integer) then
      objectScalar (modelObjectCalls reader) text original first last constant localObject seed range
    else objectBoolean (modelObjectCalls reader) text original first last constant localObject seed)
  split
  · exact invalid text
  · split
    · exact scalar reader text original first last constant localObject seed range valid span
    · exact boolean reader text original first last constant localObject seed valid span

attribute [local irreducible] objectInitialized

private theorem typed (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (info : PackageBindings.Metadata) (first last colon constant : Nat) (localObject : Bool) (result : ObjectResult)
    (valid : result.frame.position ≠ 0 → stateValid text result.frame = true) (span : ValidName text first last) :
    SuccessValid text (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject result) := by
  unfold objectTyped
  by_cases zero : result.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
    exact invalid text
  · let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text result.frame info position
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    change SuccessValid text (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact invalid text
    · simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let seed := {result with constantObject := decide (constant ≠ 0), mark := mark}
      change SuccessValid text (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          (scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          ⟨mark.after, mark.bounds⟩)
      split
      · exact initialized reader text original first last constant localObject seed _ (valid zero) span
      · exact initialized reader text original first last constant localObject seed _ (valid zero) span

private theorem valid_state (reader : BooleanElaboration.Native.Reader) (text : Source) (frame : ParserState)
    (framed : ReaderFrame text frame) (info : PackageBindings.Metadata) (localObject : Bool) :
    SuccessValid text (objectStep (modelObjectCalls reader) text frame info localObject) := by
  dsimp only [objectStep, objectNameStep, modelObjectCalls]
  split
  · exact invalid text
  · rename_i accepted
    have named : PackageBindings.validName (metadataText text)
        ⟨skipAt text frame.position, nameAfter text (skipAt text frame.position)⟩ = true := by
      cases value : PackageBindings.validName (metadataText text)
          ⟨skipAt text frame.position, nameAfter text (skipAt text frame.position)⟩
      · exact False.elim (accepted (by simp only [value, Bool.not_false, Bool.true_or]))
      · rfl
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    cases localObject with
    | true =>
      simp only [↓reduceIte]
      apply typed reader text frame info _ _ _ _ true _ _ span
      exact fun present => (framed.hide_outer info _ present).valid
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      split
      · apply typed reader text frame info _ _ _ _ false _ _ span
        exact fun _ => (framed.hidden_name _).valid
      · exact invalid text

end ObjectFrame

/-- The original Object postcondition follows from its reads and guards. Unit
and Completion can carry this frame through their loops without a new validity
check, for either local mode and arbitrary metadata. -/
theorem objectStep_reader_frame (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    ReaderFrame text (objectStep (modelObjectCalls reader) text frame info localObject).frame :=
  ⟨(objectStep_specification_base reader valid frame framed info localObject present).typed,
    ObjectFrame.valid_state reader text frame framed info localObject present⟩

end Silver.ApplicationPackageDeclarations
