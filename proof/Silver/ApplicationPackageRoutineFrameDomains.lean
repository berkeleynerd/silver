module

public import Silver.ApplicationPackageRoutineFrame
public import Silver.ApplicationPackageDeclarationsNameImports
public import Silver.ApplicationPackageDeclarationsAppendContract

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageDeclarations

set_option backward.dsimp.instances true

def modelCalls : Calls where
  bodyEnvironment := ScalarExpression.bodyEnvironment
  validName text := PackageBindings.validName (ApplicationPackageNames.metadataText text)
  hideOuter := ApplicationPackageFrames.hideOuter
  appendFormal := ApplicationPackageDeclarations.appendFormal
  validState := stateValid

theorem entry_frame {text : Source} {globals : ParserState}
    (framed : ReaderFrame text globals) (position : Nat) (bounded : ValidCursor text position) :
    ReaderFrame text (entryFrame modelCalls globals position) := by
  have ready := (stateValid_ready framed.valid).bodyEnvironment
  have scalarNames : scalarNamesValid text (ScalarExpression.bodyEnvironment globals.scalarNames) =
      scalarNamesValid text globals.scalarNames := by
    simp only [scalarNamesValid, ScalarExpression.bodyEnvironment, List.all_map, Function.comp_def,
      ScalarExpression.bodyBinding_first, ScalarExpression.bodyBinding_after,
      ScalarExpression.bodyBinding_qualifierFirst, ScalarExpression.bodyBinding_qualifierAfter]
    rfl
  have booleanNames : booleanNamesValid text (globals.booleanNames.map forgetMutable) =
      booleanNamesValid text globals.booleanNames := by
    simp only [booleanNamesValid, List.all_map, Function.comp_def]
    congr 1
    funext item
    unfold forgetMutable
    split <;> rfl
  have mutable : mutableBoundsValid (ScalarExpression.bodyEnvironment globals.scalarNames) = true := by
    apply List.all_eq_true.mpr
    intro item member
    split
    · rename_i writable
      have checked := ready item member
      simp only [checked.1, Bool.not_false, Bool.true_and, Bool.and_eq_true, decide_eq_true_eq]
      exact checked.2 writable
    · rfl
  have values : declarationValuesValid (ScalarExpression.bodyEnvironment globals.scalarNames)
      (ScalarExpression.bodyEnvironment globals.scalarNames).length = true := by
    simp only [declarationValuesValid, Nat.le_refl, decide_true, Bool.true_and, List.take_length,
      List.all_eq_true, Bool.not_eq_true']
    exact fun item member => (ready item member).1
  constructor
  · refine ⟨framed.typed.context, framed.typed.capacity, framed.typed.namesCount, framed.typed.names,
      ?_, ?_, framed.typed.subtypeCount, framed.typed.subtypes, ?_,
      framed.typed.firstParameter, framed.typed.firstProcedureParameter⟩
    · simpa only [entryFrame, modelCalls, ScalarExpression.bodyEnvironment_length] using framed.typed.scalarCount
    · intro item member
      obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
      have originalTyped := framed.typed.scalars original present
      refine ⟨?_, originalTyped.2⟩
      change (if original.mutable then original.declaredBounds else original.bounds).Bounded
      split
      · exact originalTyped.2
      · exact originalTyped.1
    · simpa only [entryFrame, List.length_map] using framed.typed.booleanCount
  · have prior := (framed.at_position bounded).valid
    dsimp +instances only [entryFrame, modelCalls, stateValid]
    have clauses := framed.valid
    simp only [stateValid, Bool.and_eq_true] at clauses
    have oldMutable := clauses.1.1.1.2
    have oldValues := clauses.1.1.2
    simpa only [stateValid, scalarNames, booleanNames, mutable, values,
      oldMutable, oldValues, Bool.and_true, Bool.and_eq_true, decide_eq_true_eq] using prior

theorem parameters_preserve {P : ParserState → Prop} {step : ParserState → Nat → Option ParserState}
    (preserved : ∀ frame index result, P frame → step frame index = some result → P result)
    (indices : List Nat) (frame result : ParserState) (prior : P frame)
    (read : parameters step indices frame = some result) : P result := by
  induction indices generalizing frame with
  | nil =>
    cases Option.some.inj read
    exact prior
  | cons index rest ih =>
    simp only [parameters] at read
    cases selected : step frame index with
    | none =>
      simp only [selected, Option.bind_none] at read
      cases read
    | some next =>
      simp only [selected, Option.bind_some] at read
      exact ih next (preserved frame index next prior selected) read

theorem hide_parameter_frame {text : Source} {frame result : ParserState}
    (info : PackageBindings.Metadata) (index : Nat) (framed : ReaderFrame text frame)
    (read : hideParameter modelCalls text info frame index = some result) : ReaderFrame text result := by
  dsimp only [hideParameter, modelCalls] at read
  split at read
  · contradiction
  · split at read
    · contradiction
    · rename_i present
      cases Option.some.inj read
      exact framed.hide_outer info _ present

/-- Appending a formal can make declaration values invalid when the metadata
contains an empty range. Its final validity test still has its complete native
callee domain: the unrelated function, procedure and array fields are retained. -/
theorem append_parameter_types {frame result : ParserState}
    (info : PackageBindings.Metadata) (index : Nat) (typed : ValidityNative.ImportedTypes frame)
    (read : appendParameter modelCalls info frame index = some result) : ValidityNative.ImportedTypes result := by
  dsimp only [appendParameter, modelCalls] at read
  split at read
  · cases Option.some.inj read
    exact typed
  · split at read
    · contradiction
    · cases Option.some.inj read
      unfold appendFormal
      split <;> (try split) <;> exact ⟨typed.functions, typed.procedures, typed.arrays⟩

theorem hide_parameters_frame {text : Source} {frame result : ParserState}
    (info : PackageBindings.Metadata) (indices : List Nat) (framed : ReaderFrame text frame)
    (read : parameters (hideParameter modelCalls text info) indices frame = some result) :
    ReaderFrame text result :=
  parameters_preserve (fun _ index _ prior read => hide_parameter_frame info index prior read)
    indices frame result framed read

theorem hide_parameter_name {text : Source} {frame result : ParserState}
    (info : PackageBindings.Metadata) (index : Nat)
    (read : hideParameter modelCalls text info frame index = some result) :
    PackageBindings.validName (ApplicationPackageNames.metadataText text) (info.parameterAt index).bodyName = true := by
  dsimp only [hideParameter, modelCalls] at read
  split at read
  · contradiction
  · rename_i named
    simpa only [Bool.not_eq_true', Bool.not_eq_false] using named

theorem hide_parameters_names {text : Source} {frame result : ParserState}
    (info : PackageBindings.Metadata) (indices : List Nat)
    (read : parameters (hideParameter modelCalls text info) indices frame = some result) :
    ∀ index ∈ indices, PackageBindings.validName (ApplicationPackageNames.metadataText text)
      (info.parameterAt index).bodyName = true := by
  induction indices generalizing frame with
  | nil => simp only [List.not_mem_nil, false_implies, implies_true]
  | cons first rest ih =>
    simp only [parameters] at read
    cases selected : hideParameter modelCalls text info frame first with
    | none => simp only [selected, Option.bind_none] at read; cases read
    | some next =>
      simp only [selected, Option.bind_some] at read
      intro index member
      rcases List.mem_cons.mp member with rfl | later
      · exact hide_parameter_name info index selected
      · exact ih read index later

structure AppendFrame (frame : ParserState) : Prop where
  scalarCount : frame.scalarNames.length ≤ ScalarExpression.maxBindings
  booleanCount : frame.booleanNames.length ≤ BooleanBindings.maxBindings
  imported : ValidityNative.ImportedTypes frame

theorem appendFrame_of_reader {text : Source} {frame : ParserState}
    (valid : ValidText text) (framed : ReaderFrame text frame) : AppendFrame frame :=
  ⟨framed.typed.scalarCount, framed.typed.booleanCount, framed.imported_types valid⟩

theorem append_formal_frame {frame : ParserState} (prior : AppendFrame frame)
    (name : PackageBindings.NameSpan) (mark : ApplicationPackageNames.PackageTypeResult)
    (mode : ProcedureBindings.Mode) : AppendFrame (appendFormal frame name mark mode) := by
  unfold appendFormal
  split
  · rename_i selected
    refine ⟨?_, prior.booleanCount, ⟨prior.imported.functions, prior.imported.procedures, prior.imported.arrays⟩⟩
    simp only [List.length_append, List.length_singleton]
    omega
  · split
    · rename_i selected
      refine ⟨prior.scalarCount, ?_, ⟨prior.imported.functions, prior.imported.procedures, prior.imported.arrays⟩⟩
      simp only [List.length_append, List.length_singleton]
      omega
    · exact ⟨prior.scalarCount, prior.booleanCount,
        ⟨prior.imported.functions, prior.imported.procedures, prior.imported.arrays⟩⟩

theorem append_parameter_frame {frame result : ParserState}
    (info : PackageBindings.Metadata) (index : Nat) (prior : AppendFrame frame)
    (read : appendParameter modelCalls info frame index = some result) : AppendFrame result := by
  dsimp only [appendParameter, modelCalls] at read
  split at read
  · cases Option.some.inj read
    exact prior
  · split at read
    · contradiction
    · cases Option.some.inj read
      exact append_formal_frame prior _ _ _

theorem append_parameters_frame {frame result : ParserState}
    (info : PackageBindings.Metadata) (indices : List Nat) (prior : AppendFrame frame)
    (read : parameters (appendParameter modelCalls info) indices frame = some result) : AppendFrame result :=
  parameters_preserve (fun _ index _ prior read => append_parameter_frame info index prior read)
    indices frame result prior read

theorem parameters_import {P : ParserState → Prop}
    (actual model : ParserState → Nat → Option ParserState) (indices : List Nat)
    (equations : ∀ frame index, index ∈ indices → P frame → actual frame index = model frame index)
    (preserved : ∀ frame index result, index ∈ indices → P frame → model frame index = some result → P result)
    (frame : ParserState) (prior : P frame) : parameters actual indices frame = parameters model indices frame := by
  induction indices generalizing frame with
  | nil => rfl
  | cons index rest ih =>
    simp only [parameters]
    rw [equations frame index (List.mem_cons_self ..) prior]
    cases selected : model frame index with
    | none => rfl
    | some next =>
      simp only [Option.bind_some]
      exact ih (fun frame index member => equations frame index (List.mem_cons_of_mem _ member))
        (fun frame index result member => preserved frame index result (List.mem_cons_of_mem _ member))
        next (preserved frame index next (List.mem_cons_self ..) prior selected)

theorem append_parameters_types {frame result : ParserState}
    (info : PackageBindings.Metadata) (indices : List Nat) (typed : ValidityNative.ImportedTypes frame)
    (read : parameters (appendParameter modelCalls info) indices frame = some result) :
    ValidityNative.ImportedTypes result :=
  parameters_preserve (fun _ index _ prior read => append_parameter_types info index prior read)
    indices frame result typed read

end Silver.ApplicationPackageRoutineFrame
