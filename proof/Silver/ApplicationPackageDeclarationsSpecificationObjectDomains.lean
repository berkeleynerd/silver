module

public import Silver.ApplicationPackageDeclarationsSpecificationDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

theorem SpecificationFrameBase.append_scalar {frame} (base : SpecificationFrameBase frame)
    (item : ScalarExpression.Binding) (spare : frame.scalarNames.length < ScalarExpression.maxBindings)
    (bounded : item.bounds.Bounded) (declared : item.declaredBounds.Bounded) :
    SpecificationFrameBase {frame with scalarNames := frame.scalarNames ++ [item]} := by
  refine ⟨⟨base.typed.context, base.typed.capacity, base.typed.namesCount, base.typed.names,
    ?_, ?_, base.typed.subtypeCount, base.typed.subtypes, base.typed.booleanCount,
    base.typed.firstParameter, base.typed.firstProcedureParameter⟩,
    ⟨base.imports.functions, base.imports.procedures, base.imports.arrays⟩⟩
  · simp only [List.length_append, List.length_singleton]
    omega
  · intro row member
    rcases List.mem_append.mp member with prior | added
    · exact base.typed.scalars row prior
    · cases List.mem_singleton.mp added
      exact ⟨bounded, declared⟩

theorem SpecificationFrameBase.append_boolean {frame} (base : SpecificationFrameBase frame)
    (item : BooleanBindings.Binding) (spare : frame.booleanNames.length < BooleanBindings.maxBindings) :
    SpecificationFrameBase {frame with booleanNames := frame.booleanNames ++ [item]} := by
  refine ⟨⟨base.typed.context, base.typed.capacity, base.typed.namesCount, base.typed.names,
    base.typed.scalarCount, base.typed.scalars, base.typed.subtypeCount, base.typed.subtypes,
    ?_, base.typed.firstParameter, base.typed.firstProcedureParameter⟩,
    ⟨base.imports.functions, base.imports.procedures, base.imports.arrays⟩⟩
  simp only [List.length_append, List.length_singleton]
  omega

namespace SpecificationObject

private def SuccessBase (result : ObjectResult) : Prop :=
  result.frame.position ≠ 0 → SpecificationFrameBase result.frame

private theorem invalid : SuccessBase invalidObject := fun present => False.elim (present rfl)

private theorem finish (calls : ObjectCalls) (text : Source) (original : ParserState)
    (result : ObjectResult) (base : SpecificationFrameBase result.frame) :
    SuccessBase (finishObject calls text original result) := by
  dsimp only [finishObject]
  split
  · exact invalid
  · exact fun _ => base.header _ _

private theorem boolean_finish (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constant after : Nat) (localObject : Bool) (result : ObjectResult)
    (base : SpecificationFrameBase result.frame)
    (spare : result.frame.booleanNames.length < BooleanBindings.maxBindings) :
    SuccessBase (objectBooleanFinish calls text original first last constant after localObject result) := by
  dsimp only [objectBooleanFinish]
  apply finish
  exact base.append_boolean _ spare

private theorem boolean (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (result : ObjectResult)
    (base : SpecificationFrameBase result.frame) :
    SuccessBase (objectBoolean calls text original first last constant localObject result) := by
  dsimp only [objectBoolean]
  split
  · exact invalid
  · rename_i accepted
    have spare : result.frame.booleanNames.length < BooleanBindings.maxBindings := by
      have count := base.typed.booleanCount
      have different : result.frame.booleanNames.length ≠ BooleanBindings.maxBindings :=
        fun full => accepted (by simp only [full, decide_true, Bool.or_true])
      omega
    split
    · split
      · exact invalid
      · exact boolean_finish calls text original first last constant _ localObject _ base spare
    · exact boolean_finish calls text original first last constant _ localObject _ base spare

private theorem scalar (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (original : ParserState) (first last constant : Nat) (localObject : Bool) (result : ObjectResult)
    (range : ScalarConstraintResult) (base : SpecificationFrameBase result.frame)
    (cursor : ValidCursor text result.initFirst) (bounded : range.bounds.Bounded) :
    SuccessBase (objectScalar (modelObjectCalls reader) text original first last constant localObject result range) := by
  dsimp only [objectScalar, modelObjectCalls]
  split
  · exact invalid
  · rename_i accepted
    have spare : result.frame.scalarNames.length < ScalarExpression.maxBindings := by
      have count := base.typed.scalarCount
      have different : result.frame.scalarNames.length ≠ ScalarExpression.maxBindings :=
        fun full => accepted (by simp only [full, decide_true, Bool.or_true])
      omega
    apply finish
    exact base.append_scalar _ spare (ScalarExpression.Native.read_type valid cursor).2.1 bounded

private theorem initialized (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (original : ParserState) (first last constant : Nat) (localObject : Bool) (result : ObjectResult)
    (range : ScalarConstraintResult) (base : SpecificationFrameBase result.frame)
    (cursor : ValidCursor text range.after) (bounded : range.bounds.Bounded) :
    SuccessBase (objectInitialized (modelObjectCalls reader) text original first last constant localObject result range) := by
  let typedSeed := {result with mark := {result.mark with bounds := range.bounds}}
  let seed := {typedSeed with initFirst := skipAt text (tokenAfter text range.after (.symbol ":="))}
  change SuccessBase (if decide (seed.initFirst = 0) then invalidObject else
    if decide (seed.mark.kind = .integer) then
      objectScalar (modelObjectCalls reader) text original first last constant localObject seed range
    else objectBoolean (modelObjectCalls reader) text original first last constant localObject seed)
  split
  · exact invalid
  · split
    · apply scalar reader valid original first last constant localObject seed range base
      · exact model_skip_valid text _ (model_fixed_valid text _ ":=" false cursor)
      · exact bounded
    · exact boolean _ text original first last constant localObject seed base

attribute [local irreducible] objectInitialized

private theorem typed (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (original : ParserState) (info : PackageBindings.Metadata) (first last colon constant : Nat)
    (localObject : Bool) (result : ObjectResult)
    (state : result.frame.position ≠ 0 → ReaderFrame text result.frame)
    (colonBound : ValidCursor text colon) (constantBound : ValidCursor text constant) :
    SuccessBase (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject result) := by
  unfold objectTyped
  by_cases zero : result.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
    exact invalid
  · have framed := state zero
    let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text result.frame info position
    have cursor : ValidCursor text position := by dsimp [position]; split <;> assumption
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    change SuccessBase (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact invalid
    · have found := (package_type_domain text result.frame info position framed cursor).resolve_left absent
      simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let seed := {result with constantObject := decide (constant ≠ 0), mark := mark}
      change SuccessBase (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          (scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject seed
          ⟨mark.after,mark.bounds⟩)
      split
      · exact initialized reader valid original first last constant localObject seed
          (scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds) (framed.specification_base valid)
          (scalarConstraintAt_position_valid text mark.after result.frame.scalarNames found.cursor)
          (scalarConstraintAt_bounded_all text mark.after result.frame.scalarNames found.cursor found.bounded)
      · exact initialized reader valid original first last constant localObject seed
          ⟨mark.after,mark.bounds⟩ (framed.specification_base valid)
          found.cursor found.bounded

end SpecificationObject

/-- The complete Object result retains native field domains on every nonzero
return, in both global and local modes. Valid_State is still checked by its caller. -/
theorem objectStep_specification_base (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    SpecificationFrameBase (objectStep (modelObjectCalls reader) text frame info localObject).frame := by
  have domain : SpecificationObject.SuccessBase (objectStep (modelObjectCalls reader) text frame info localObject) := by
    dsimp only [objectStep, objectNameStep, modelObjectCalls]
    split
    · exact SpecificationObject.invalid
    · cases localObject with
      | true =>
        simp only [↓reduceIte]
        apply SpecificationObject.typed reader valid
        · exact fun accepted => framed.hide_outer info _ accepted
        · exact fixedAfter_result_bound text _ ":" false (by decide)
        · exact fixedAfter_result_bound text _ "constant" true (by decide)
      | false =>
        simp only [Bool.false_eq_true, ↓reduceIte]
        split
        · apply SpecificationObject.typed reader valid
          · exact fun _ => framed.hidden_name _
          · exact fixedAfter_result_bound text _ ":" false (by decide)
          · exact fixedAfter_result_bound text _ "constant" true (by decide)
        · exact SpecificationObject.invalid
  exact domain present

end Silver.ApplicationPackageDeclarations
