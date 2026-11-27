module

public import Silver.ApplicationPackageRoutineFrameDomains

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageDeclarations ApplicationPackageNames

set_option backward.dsimp.instances true

/-- Only an actual Interval component subtype is needed from metadata. This
allows empty, unordered or otherwise malformed parameter declarations. -/
def ParameterBounds (info : PackageBindings.Metadata) : Prop :=
  ∀ item ∈ info.parameters, item.bounds.Bounded

theorem parameterBounds_of_typed {info : PackageBindings.Metadata} (typed : info.Typed) : ParameterBounds info := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, _, parameters⟩
  intro item member
  exact (parameters item member).2.2.2.2.1

theorem parameter_bounds {info : PackageBindings.Metadata} (typed : ParameterBounds info) (index : Nat) :
    (info.parameterAt index).bounds.Bounded := by
  unfold PackageBindings.Metadata.parameterAt
  simp only [List.getD_eq_getElem?_getD]
  cases selected : info.parameters[index - 1]? with
  | none => exact Integer.Interval.empty_bounded
  | some item => exact typed item (List.mem_of_getElem? selected)

theorem append_formal_typed {frame : ParserState} (typed : StateType frame)
    (name : PackageBindings.NameSpan) (mark : PackageTypeResult) (bounded : mark.bounds.Bounded)
    (mode : ProcedureBindings.Mode) : StateType (appendFormal frame name mark mode) := by
  unfold appendFormal
  split
  · rename_i selected
    refine ⟨typed.context, typed.capacity, typed.namesCount, typed.names, ?_, ?_,
      typed.subtypeCount, typed.subtypes, typed.booleanCount, typed.firstParameter, typed.firstProcedureParameter⟩
    · simp only [List.length_append, List.length_singleton]; omega
    · intro item member
      rcases List.mem_append.mp member with old | fresh
      · exact typed.scalars item old
      · cases List.mem_singleton.mp fresh
        exact ⟨bounded, bounded⟩
  · split
    · rename_i selected
      refine ⟨typed.context, typed.capacity, typed.namesCount, typed.names, typed.scalarCount, typed.scalars,
        typed.subtypeCount, typed.subtypes, ?_, typed.firstParameter, typed.firstProcedureParameter⟩
      simp only [List.length_append, List.length_singleton]; omega
    · exact ⟨typed.context, typed.capacity, typed.namesCount, typed.names, typed.scalarCount, typed.scalars,
        typed.subtypeCount, typed.subtypes, typed.booleanCount, typed.firstParameter, typed.firstProcedureParameter⟩

theorem append_parameter_typed {frame result : ParserState} (info : PackageBindings.Metadata)
    (bounds : ParameterBounds info) (index : Nat) (typed : StateType frame)
    (read : appendParameter modelCalls info frame index = some result) : StateType result := by
  dsimp only [appendParameter, modelCalls] at read
  split at read
  · cases Option.some.inj read
    exact typed
  · split at read
    · contradiction
    · cases Option.some.inj read
      exact append_formal_typed typed _ _ (parameter_bounds bounds index) _

theorem append_parameters_typed {frame result : ParserState} (info : PackageBindings.Metadata)
    (bounds : ParameterBounds info) (indices : List Nat) (typed : StateType frame)
    (read : parameters (appendParameter modelCalls info) indices frame = some result) : StateType result :=
  parameters_preserve (fun _ index _ prior read => append_parameter_typed info bounds index prior read)
    indices frame result typed read

theorem invalid_reader_frame (text : Source) : ReaderFrame text invalidState := by
  constructor
  · constructor <;> simp [invalidState]
  · simp [stateValid, invalidState, nameStateValid, FunctionBindings.ValidMetadata,
      ProcedureBindings.ValidMetadata, stringNamesValid, scalarNamesValid,
      ArrayBindings.ValidNativeEnvironment, ArrayBindings.ValidTable, ArrayBindings.ValidTypes,
      ArrayBindings.Env.table, ArrayBindings.ValidInitials, subtypesValid, booleanNamesValid,
      mutableBoundsValid, declarationValuesValid]

/-- Routine_Frame's exact Valid_State postcondition holds on every path. No
metadata validity or nonempty formal range is assumed. -/
theorem routine_frame_valid (text : Source) (globals : ParserState) (info : PackageBindings.Metadata)
    (routine position : Nat) : stateValid text (routineFrame modelCalls text globals info routine position) = true := by
  unfold routineFrame withItem
  dsimp only
  split
  · exact (invalid_reader_frame text).valid
  · split
    · exact (invalid_reader_frame text).valid
    · cases parameters (hideParameter modelCalls text info)
        (ApplicationPackageBodies.formalIndices (info.routineAt routine)) (entryFrame modelCalls globals position) with
      | none => exact (invalid_reader_frame text).valid
      | some hidden =>
        dsimp only
        cases parameters (appendParameter modelCalls info)
          (ApplicationPackageBodies.formalIndices (info.routineAt routine)) hidden with
        | none => exact (invalid_reader_frame text).valid
        | some result =>
          change stateValid text (if stateValid text result then result else invalidState) = true
          split
          · assumption
          · exact (invalid_reader_frame text).valid

theorem routine_frame_typed {text : Source} (globals : ParserState) (framed : ReaderFrame text globals)
    (info : PackageBindings.Metadata) (bounds : ParameterBounds info)
    (routine position : Nat) (bounded : ValidCursor text position) :
    StateType (routineFrame modelCalls text globals info routine position) := by
  unfold routineFrame withItem
  dsimp only
  split
  · exact (invalid_reader_frame text).typed
  · split
    · exact (invalid_reader_frame text).typed
    · cases hidden : parameters (hideParameter modelCalls text info)
        (ApplicationPackageBodies.formalIndices (info.routineAt routine)) (entryFrame modelCalls globals position) with
      | none => exact (invalid_reader_frame text).typed
      | some frame =>
        dsimp only
        have frameValid := hide_parameters_frame info _ (entry_frame framed position bounded) hidden
        cases appended : parameters (appendParameter modelCalls info)
          (ApplicationPackageBodies.formalIndices (info.routineAt routine)) frame with
        | none => exact (invalid_reader_frame text).typed
        | some result =>
          change StateType (if stateValid text result then result else invalidState)
          split
          · exact append_parameters_typed info bounds _ frameValid.typed appended
          · exact (invalid_reader_frame text).typed

/-- A complete ReaderFrame result, including rejection. ParameterBounds is
solely the native interval component subtype, not Valid_Metadata. -/
theorem routine_frame_reader {text : Source} (globals : ParserState) (framed : ReaderFrame text globals)
    (info : PackageBindings.Metadata) (bounds : ParameterBounds info)
    (routine position : Nat) (bounded : ValidCursor text position) :
    ReaderFrame text (routineFrame modelCalls text globals info routine position) :=
  ⟨routine_frame_typed globals framed info bounds routine position bounded,
    routine_frame_valid text globals info routine position⟩

end Silver.ApplicationPackageRoutineFrame
