module

public import Silver.ApplicationPackageSignatureSpecificationTypes
public import Silver.ApplicationPackageDeclarationsSpecificationLoopImports
public import Silver.ApplicationPackageRoutineFrameContract

@[expose] public section

/-! Component-type and complete output-frame preservation for the original
Package_Spec_At reader. Rejected exits retain their real partial metadata. -/
namespace Silver.ApplicationPackageDeclarations.SpecificationMetadataTypes
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames PackageBindings

set_option backward.dsimp.instances true

def ResultTyped (text : Source) (result : SpecificationResult) : Prop :=
  result.info.Typed ∧ ReaderFrame text result.exports

def StateTyped (text : Source) (state : SpecificationState) : Prop :=
  state.info.Typed ∧ ReaderFrame text state.exports

def StartTyped (text : Source) : SpecificationStart → Prop
  | .returned result => ResultTyped text result
  | .loop state => StateTyped text state

def StepTyped (text : Source) : SpecificationStep → Prop
  | .returned result => ResultTyped text result
  | .ready state | .next state => StateTyped text state

def ExitTyped (text : Source) : SpecificationExit → Prop
  | .returned result => ResultTyped text result
  | .ready state => StateTyped text state

theorem rejected (text : Source) (info : Metadata) (typed : info.Typed) :
    ResultTyped text (rejectedSpecification info) :=
  ⟨typed, ApplicationPackageRoutineFrame.invalid_reader_frame text⟩

theorem start (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (info : Metadata) (typed : info.Typed) :
    StartTyped text (specificationStart (modelSpecificationCalls reader) text info) := by
  dsimp only [specificationStart, modelSpecificationCalls]
  generalize firstRead : skipAt text (packageWord text 1 "package") = first
  generalize nameRead : nameAfter text first = last
  generalize positionRead : sparkPragmaAfter text (tokenAfter text last (.word "is")) = position
  split
  · exact rejected text info typed
  · rename_i accepted
    have allowed : packageNameAllowed text ⟨first,last⟩ = true :=
      Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false]))
    have named : PackageBindings.validName (metadataText text) ⟨first,last⟩ = true := by
      simp only [packageNameAllowed, Bool.and_eq_true, and_assoc] at allowed
      exact allowed.1
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    have infoTyped : ({info with nameFirst := first, nameAfter := last} : Metadata).Typed :=
      ⟨MetadataTypes.span valid _ span, typed.2⟩
    have cursor : ValidCursor text position := by
      rw [← positionRead]
      exact fixedAfter_result_bound text _ ";" false (by decide)
    have frame : ReaderFrame text
        {initialState with position, packageFirst := first, packageAfter := last} :=
      ((initial_reader_frame text).at_position cursor).package_name ⟨first,last⟩ span
    split <;> exact ⟨infoTyped, frame⟩

theorem continue_state (reader : BooleanElaboration.Native.Reader) (text : Source) (before : Nat)
    (state : SpecificationState) (typed : state.info.Typed) (frame : StateType state.exports) :
    StepTyped text (continueSpecification (modelSpecificationCalls reader) text before state) := by
  dsimp only [continueSpecification, modelSpecificationCalls]
  split
  · exact rejected text state.info typed
  · rename_i accepted
    exact ⟨typed, frame, Bool.of_not_eq_false
      (fun failed => accepted (by simp only [failed, Bool.not_false, Bool.or_true]))⟩

theorem append_export {info : Metadata} (typed : info.Typed)
    (room : info.exports.length < maxExports) (item : ExportDeclaration) (itemTyped : item.Typed) :
    ({info with exports := info.exports ++ [item]} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, ?_, states, routines, completed, parameters, ?_, stateTypes, routineTypes, parameterTypes⟩
  · simp only [List.length_append, List.length_singleton]
    omega
  · intro value member
    rcases List.mem_append.mp member with prior | added
    · exact exportTypes value prior
    · cases List.mem_singleton.mp added
      exact itemTyped

theorem append (reader : BooleanElaboration.Native.Reader) (text : Source) (state : SpecificationState)
    (typed : state.info.Typed) (room : state.info.exports.length < maxExports)
    (next : ParserState) (frame : StateType next) (item : ExportDeclaration) (itemTyped : item.Typed) :
    StepTyped text (appendExport (modelSpecificationCalls reader) text state next item) :=
  continue_state reader text _ _ (append_export typed room item itemTyped) frame

theorem routine (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (typed : StateTyped text state) :
    StepTyped text (specificationRoutine (modelSpecificationCalls reader) text state) := by
  have result := readSignature_specification_typed valid state.exports typed.2 state.info typed.1
  dsimp only [specificationRoutine, modelSpecificationCalls]
  split
  · exact rejected text _ result
  · apply continue_state reader text _ _ result
    exact state_type_specification_header typed.2.typed _ _

theorem subtype (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (typed : StateTyped text state) (room : state.info.exports.length < maxExports) :
    StepTyped text (specificationSubtype (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationSubtype, modelSpecificationCalls]
  split
  · exact rejected text state.info typed.1
  · rename_i present
    let next := subtypeDeclarationAt text state.exports false
    let item := next.subtypeNames.items.getD (next.subtypeNames.items.length - 1) {}
    have frame := specification_subtype_base valid state.exports typed.2 false present
    have bounded : item.bounds.Bounded := by
      dsimp only [item]
      simp only [List.getD_eq_getElem?_getD]
      cases selected : next.subtypeNames.items[next.subtypeNames.items.length - 1]? with
      | none => exact Integer.Interval.empty_bounded
      | some entry => exact frame.typed.subtypes entry (List.mem_of_getElem? selected)
    change StepTyped text (if !packageNameFresh text state.info ⟨item.first,item.after⟩ then
      .returned (rejectedSpecification state.info) else _)
    split
    · exact rejected text state.info typed.1
    · rename_i fresh
      have allowed : packageNameFresh text state.info ⟨item.first,item.after⟩ = true :=
        Bool.of_not_eq_false (fun failed => fresh (by simp only [failed, Bool.not_false]))
      have named : PackageBindings.validName (metadataText text) ⟨item.first,item.after⟩ = true := by
        simp only [packageNameFresh, Bool.and_eq_true, and_assoc] at allowed
        exact allowed.1
      apply append reader text state typed.1 room next frame.typed
      exact ⟨MetadataTypes.span valid _ (ApplicationPackageNames.Native.validName_domain named).2,
        ⟨Nat.zero_le _, Nat.zero_le _⟩, bounded,
        by change state.info.exports.length + 2 ≤ maxExports + 1; omega, Nat.zero_le _, Nat.zero_le _⟩

theorem object (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (typed : StateTyped text state) (room : state.info.exports.length < maxExports) :
    StepTyped text (specificationObject (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationObject, modelSpecificationCalls]
  split
  · exact rejected text state.info typed.1
  · rename_i accepted
    let out := objectStep (modelObjectCalls reader) text state.exports state.info false
    have present : out.frame.position ≠ 0 := by
      intro missing
      apply accepted
      change (decide (out.frame.position = 0) || !out.constantObject) = true
      simp only [missing, decide_true, Bool.true_or]
    have fields := ApplicationPackageBodies.object_state_typed reader valid state.exports typed.2
      state.info typed.1.2.2.2.1 false present
    have frame := objectStep_specification_base reader valid state.exports typed.2 state.info false present
    apply append reader text state typed.1 room out.frame frame.typed
    refine ⟨fields.1, fields.2.1, ?_, fields.2.2.2.2.1, fields.2.2.2.2.2.1, fields.2.2.2.2.2.2⟩
    change (if out.mark.kind = .integer then out.initialBounds else Integer.Interval.full).Bounded
    split
    · exact fields.2.2.2.1
    · exact Integer.Interval.full_bounded

theorem step (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (typed : StateTyped text state) :
    StepTyped text (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  split
  · exact typed
  · split
    · exact routine reader valid state typed
    · split
      · exact rejected text state.info typed.1
      · rename_i spare
        have room : state.info.exports.length < maxExports := by
          have capacity := typed.1.2.2.2.1
          omega
        split
        · exact subtype reader valid state typed room
        · exact object reader valid state typed room

theorem finish (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (typed : StateTyped text state) :
    ResultTyped text (finishSpecification (modelSpecificationCalls reader) text state) := by
  dsimp only [finishSpecification]
  split
  · exact rejected text state.info typed.1
  · exact ⟨typed.1, typed.2.at_position (fixedAfter_result_bound text _ ";" false (by decide))⟩

theorem loop (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    {state : SpecificationState} {result : SpecificationExit}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state result)
    (typed : StateTyped text state) : ExitTyped text result := by
  induction run with
  | returned parsed =>
    have fields := step reader valid _ typed
    rw [parsed] at fields
    exact fields
  | ready parsed =>
    have fields := step reader valid _ typed
    rw [parsed] at fields
    exact fields
  | next parsed _ ih =>
    have fields := step reader valid _ typed
    rw [parsed] at fields
    exact ih fields

end Silver.ApplicationPackageDeclarations.SpecificationMetadataTypes

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions PackageBindings

/-- The complete original Specification result keeps the native metadata
component subtypes and Valid_State output contract on every return path. -/
theorem readSpecification_typed (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (info : Metadata) (typed : info.Typed) :
    (readSpecification reader text info).info.Typed ∧ ReaderFrame text (readSpecification reader text info).exports := by
  have started := SpecificationMetadataTypes.start reader valid info typed
  change SpecificationMetadataTypes.ResultTyped text (readSpecification reader text info)
  dsimp only [readSpecification]
  cases chosen : specificationStart (modelSpecificationCalls reader) text info with
  | returned result =>
    rw [chosen] at started
    exact started
  | loop state =>
    dsimp only
    rw [chosen] at started
    have ended := SpecificationMetadataTypes.loop reader valid (runSpecificationLoop_exec reader text state) started
    cases returned : runSpecificationLoop reader text state with
    | returned result =>
      rw [returned] at ended
      exact ended
    | ready finalState =>
      rw [returned] at ended
      exact SpecificationMetadataTypes.finish reader text finalState ended

end Silver.ApplicationPackageDeclarations
