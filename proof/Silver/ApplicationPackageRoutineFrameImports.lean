module

public import Silver.ApplicationPackageRoutineFrameLibraries
public import Silver.ApplicationPackageRoutineFrameMeaning

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageDeclarations ApplicationPackageNames

set_option backward.dsimp.instances true

namespace Library

theorem hide_parameter (library : Library) {text : Source} (valid : ValidText text)
    (info : PackageBindings.Metadata) (frame : ParserState) (framed : ReaderFrame text frame) (index : Nat) :
    hideParameter library.calls text info frame index = hideParameter modelCalls text info frame index := by
  have named := PackageBindings.Native.interpreted_validName library.names.shared.packages
    library.names.shared.packagePrimitives library.names.shared.packageEquations
    (metadataText text) (info.parameterAt index).bodyName
  dsimp only [hideParameter, calls, modelCalls]
  rw [named]
  by_cases accepted : PackageBindings.validName (metadataText text) (info.parameterAt index).bodyName = true
  · simp only [accepted, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    rw [library.names.hide_outer valid framed info _ (ApplicationPackageNames.Native.validName_domain accepted).2]
  · have rejected : PackageBindings.validName (metadataText text) (info.parameterAt index).bodyName = false :=
      Bool.eq_false_iff.mpr accepted
    simp only [rejected, Bool.not_false, ↓reduceIte]

theorem hide_parameters (library : Library) {text : Source} (valid : ValidText text)
    (info : PackageBindings.Metadata) (frame : ParserState) (framed : ReaderFrame text frame) (indices : List Nat) :
    parameters (hideParameter library.calls text info) indices frame =
      parameters (hideParameter modelCalls text info) indices frame :=
  parameters_import _ _ indices
    (fun state index _ prior => library.hide_parameter valid info state prior index)
    (fun _ index _ _ prior read => hide_parameter_frame info index prior read) frame framed

theorem append_parameter (library : Library) {text : Source}
    (info : PackageBindings.Metadata) (frame : ParserState) (prior : AppendFrame frame) (index : Nat)
    (named : PackageBindings.validName (metadataText text) (info.parameterAt index).bodyName = true) :
    appendParameter library.calls info frame index = appendParameter modelCalls info frame index := by
  have span := (ApplicationPackageNames.Native.validName_domain named).2
  dsimp only [appendParameter, calls, modelCalls]
  split
  · rfl
  · rw [library.append_meaning frame prior _ _ _ span.1 span.2.1]

theorem append_parameters (library : Library) {text : Source}
    (info : PackageBindings.Metadata) (frame : ParserState) (prior : AppendFrame frame) (indices : List Nat)
    (named : ∀ index ∈ indices, PackageBindings.validName (metadataText text) (info.parameterAt index).bodyName = true) :
    parameters (appendParameter library.calls info) indices frame =
      parameters (appendParameter modelCalls info) indices frame :=
  parameters_import _ _ indices
    (fun state index member prior => library.append_parameter info state prior index (named index member))
    (fun _ index _ _ prior read => append_parameter_frame info index prior read) frame prior

/-- Every imported call in both native passes is interpreted on its original
domain. Successful first-pass name checks justify all second-pass Append calls;
the final Valid_State checks even malformed and empty formal intervals. -/
theorem routine_frame (library : Library) {text : Source} (valid : ValidText text)
    (globals : ParserState) (framed : ReaderFrame text globals) (info : PackageBindings.Metadata)
    (routine position : Nat) (bounded : ValidCursor text position) :
    routineFrame library.calls text globals info routine position =
      routineFrame modelCalls text globals info routine position := by
  unfold routineFrame withItem
  by_cases inactive : routine > info.routines.length
  · simp only [inactive, ↓reduceIte]
  · simp only [inactive, ↓reduceIte]
    rw [library.entry globals framed position]
    by_cases rejected : ApplicationPackageBodies.formalRangeRejected info (info.routineAt routine) = true
    · simp only [rejected, ↓reduceIte]
    · simp only [rejected, Bool.false_eq_true, ↓reduceIte]
      rw [library.hide_parameters valid info _ (entry_frame framed position bounded)]
      cases hidden : parameters (hideParameter modelCalls text info)
        (ApplicationPackageBodies.formalIndices (info.routineAt routine)) (entryFrame modelCalls globals position) with
      | none => rfl
      | some frame =>
        dsimp only
        have frameValid := hide_parameters_frame info _ (entry_frame framed position bounded) hidden
        have names := hide_parameters_names info _ hidden
        have domain := appendFrame_of_reader valid frameValid
        rw [library.append_parameters info frame domain _ names]
        cases appended : parameters (appendParameter modelCalls info)
          (ApplicationPackageBodies.formalIndices (info.routineAt routine)) frame with
        | none => rfl
        | some result =>
          dsimp only
          rw [library.valid_state valid result (append_parameters_frame info _ domain appended).imported]
          rfl

/-- Complete typed Routine_Frame result, including all rejection paths and
arbitrary incoming local storage. No metadata-validity or success premise. -/
theorem body_imports (library : Library) (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (bounded : ValidCursor (locals .source "text") (locals .number "position")) :
    Native.body.eval (Native.modelFunctions library.calls) (Native.modelProcedures library.calls) locals =
      routineFrame modelCalls (locals .source "text") (locals .state "globals")
        (locals .metadata "info") (locals .number "routine") (locals .number "position") := by
  rw [Native.body_meaning]
  exact library.routine_frame valid _ framed _ _ _ bounded

end Library
end Silver.ApplicationPackageRoutineFrame
