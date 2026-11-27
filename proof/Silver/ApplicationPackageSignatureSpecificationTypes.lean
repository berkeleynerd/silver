module

public import Silver.ApplicationPackageDeclarationsSignatureMetadataTypes
public import Silver.ApplicationPackageUnitObjectTypes

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.SignatureSpecificationTypes
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames PackageBindings

set_option backward.dsimp.instances true

theorem append_parameter {info : Metadata} (typed : info.Typed)
    (room : info.parameters.length < maxFormals) (item : Formal) (itemTyped : item.Typed) :
    ({info with parameters := info.parameters ++ [item]} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, exports, states, routines, completed, ?_, exportTypes, stateTypes, routineTypes, ?_⟩
  · simp only [List.length_append, List.length_singleton]
    omega
  · intro value member
    rcases List.mem_append.mp member with prior | added
    · exact parameterTypes value prior
    · cases List.mem_singleton.mp added
      exact itemTyped

theorem append_routine {info : Metadata} (typed : info.Typed)
    (room : info.routines.length < maxRoutines) (item : Routine) (itemTyped : item.Typed) :
    ({info with routines := info.routines ++ [item]} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, exports, states, ?_, completed, parameters, exportTypes, stateTypes, ?_, parameterTypes⟩
  · simp only [List.length_append, List.length_singleton]
    omega
  · intro value member
    rcases List.mem_append.mp member with prior | added
    · exact routineTypes value prior
    · cases List.mem_singleton.mp added
      exact itemTyped

structure StateTyped (state : SignatureState) : Prop where
  info : state.info.Typed
  item : state.item.Typed
  routines : state.info.routines.length < maxRoutines
  count : state.formalCount ≤ state.info.parameters.length
  first : state.formalStart ≤ maxFormals

theorem StateTyped.header {state : SignatureState} (typed : StateTyped state) (header : ParserState) :
    StateTyped {state with header} := ⟨typed.info, typed.item, typed.routines, typed.count, typed.first⟩

def StartTyped : SignatureStart → Prop
  | .returned result => result.info.Typed
  | .ready state | .loop state => StateTyped state

def StepTyped : SignatureStep → Prop
  | .returned result => result.info.Typed
  | .ready state | .next state => StateTyped state

def ExitTyped : SignatureExit → Prop
  | .returned result => result.info.Typed
  | .ready state => StateTyped state

theorem enter_body (text : Source) (outer : ParserState) (info : Metadata) (typed : info.Typed)
    (first last identity : Nat) (item : Routine) (itemTyped : item.Typed)
    (room : info.routines.length < maxRoutines) :
    StartTyped (startSignatureBody modelSignatureCalls text outer info first last identity item 0) := by
  dsimp only [startSignatureBody]
  split <;> exact ⟨typed, itemTyped, room, Nat.zero_le _, Nat.zero_le _⟩

theorem start {text : Source} (valid : ValidText text) (outer : ParserState)
    (framed : ReaderFrame text outer) (info : Metadata) (typed : info.Typed) :
    StartTyped (signatureStart modelSignatureCalls text outer info false) := by
  let original := skipAt text outer.position
  let functionEnd := tokenAfter text outer.position (.word "function")
  let procedureEnd := tokenAfter text outer.position (.word "procedure")
  let first := skipAt text (if functionEnd ≠ 0 then functionEnd else procedureEnd)
  let last := nameAfter text first
  have originalBound : original ≤ maxSourceLength + 1 :=
    Nat.le_trans (model_skip_valid text outer.position framed.cursor) (Nat.add_le_add_right valid.2 1)
  change StartTyped (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _)
  split
  · exact typed
  · rename_i accepted
    have span : ValidName text first last := by
      simp only [not_or] at accepted
      exact ⟨Nat.pos_of_ne_zero accepted.2.2.1, Nat.lt_of_not_ge accepted.2.2.2, model_name_valid text first⟩
    have named := MetadataTypes.span valid (⟨first,last⟩ : NameSpan) span
    change StartTyped (if decide (info.routines.length = maxRoutines) ||
        !modelSignatureCalls.fresh text info ⟨first,last⟩ then .returned (rejectedSignature info)
      else startSignatureBody modelSignatureCalls text outer info first last (info.routines.length + 1)
        {kind := if functionEnd ≠ 0 then .function else .procedure, specName := ⟨first,last⟩, specFirst := original} 0)
    by_cases allowed : (decide (info.routines.length = maxRoutines) ||
        !modelSignatureCalls.fresh text info ⟨first,last⟩) = true
    · rw [ite_eq_left allowed]
      exact typed
    · rw [ite_eq_right allowed]
      have room : info.routines.length < maxRoutines := by
        have capacity := typed.2.2.2.2.2.1
        have distinct : info.routines.length ≠ maxRoutines :=
          fun same => allowed (by simp only [same, decide_true, Bool.true_or])
        omega
      have itemTyped : Routine.Typed
          {kind := if functionEnd ≠ 0 then .function else .procedure, specName := ⟨first,last⟩,
            specFirst := original} := by
        simp [Routine.Typed, NameSpan.Typed, named.1, named.2, originalBound,
          Integer.Interval.empty_bounded, emptyStateSet]
      exact enter_body text outer info typed first last _ _ itemTyped room

theorem finish_formal (text : Source) (before : Nat) (state : SignatureState) (typed : StateTyped state) :
    StepTyped (finishFormal modelSignatureCalls text before state) := by
  dsimp only [finishFormal]
  split
  · exact typed.header _
  · split
    · exact typed.info
    · exact typed.header _

theorem store (text : Source) (before : Nat) (state : SignatureState) (typed : StateTyped state)
    (room : state.info.parameters.length < maxFormals) (first last slot : Nat)
    (named : NameSpan.Typed ⟨first,last⟩) (mode : ProcedureBindings.Mode) (mark : PackageTypeResult)
    (typeNamed : mark.name.Typed) (bounded : mark.bounds.Bounded) (identity : mark.identity ≤ maxExports + 1) :
    StepTyped (storeFormal modelSignatureCalls text false before state first last slot mode mark) := by
  let parameter : Formal := {
    specName := ⟨first,last⟩, specTypeName := mark.name
    kind := mark.kind, bounds := mark.bounds, typeIdentity := mark.identity, mode}
  have parameterTyped : parameter.Typed :=
    ⟨named, ⟨Nat.zero_le _, Nat.zero_le _⟩, typeNamed, ⟨Nat.zero_le _, Nat.zero_le _⟩, bounded, identity⟩
  have appended := append_parameter typed.info room parameter parameterTyped
  dsimp only [storeFormal]
  simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
  split
  · exact appended
  · apply finish_formal
    refine ⟨appended, typed.item, typed.routines, ?_, typed.first⟩
    change state.formalCount + 1 ≤ (state.info.parameters ++ [parameter]).length
    simp only [List.length_append, List.length_singleton]
    exact Nat.add_le_add_right typed.count 1

theorem read_type {text : Source} (valid : ValidText text) (before : Nat) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header)
    (room : state.info.parameters.length < maxFormals) (first last slot : Nat)
    (span : ValidName text first last) :
    StepTyped (readFormalType modelSignatureCalls text false before state first last slot) := by
  let colon := tokenAfter text last (.symbol ":")
  let inputEnd := tokenAfter text colon (.word "in")
  let outputEnd := tokenAfter text inputEnd (.word "out")
  let outputOnly := tokenAfter text colon (.word "out")
  let modeResult : Nat × ProcedureBindings.Mode := if inputEnd ≠ 0 then
      ⟨if outputEnd ≠ 0 then outputEnd else inputEnd, if outputEnd ≠ 0 then .inputOutput else .input⟩
    else ⟨outputOnly,.output⟩
  have modeBound : ValidCursor text modeResult.1 := by
    dsimp only [modeResult]
    split
    · dsimp only
      split
      · exact fixedAfter_result_bound text _ "out" true (by decide)
      · exact fixedAfter_result_bound text _ "in" true (by decide)
    · exact fixedAfter_result_bound text _ "out" true (by decide)
  let mark := packageTypeAt text state.header state.info modeResult.1
  change StepTyped (if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then _ else _)
  split
  · exact typed.info
  · change StepTyped (if mark.after = 0 then _ else _)
    split
    · exact typed.info
    · rename_i present
      have fields := (package_type_domain text state.header state.info modeResult.1 framed modeBound).resolve_left present
      exact store text before state typed room first last slot (MetadataTypes.span valid _ span) modeResult.2 mark
        (MetadataTypes.type_name valid _ _ _) fields.bounded
        (ApplicationPackageBodies.package_type_identity text state.header state.info typed.info.2.2.2.1 modeResult.1)

theorem read_name {text : Source} (valid : ValidText text) (before : Nat) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header)
    (room : state.info.parameters.length < maxFormals) (first last slot : Nat)
    (span : ValidName text first last) :
    StepTyped (readFormalName modelSignatureCalls text false before state first last slot) := by
  dsimp +instances only [readFormalName, modelSignatureCalls]
  split
  · exact typed.info
  · split
    · exact typed.info
    · rename_i present
      exact read_type valid before {state with header := hideOuter text state.header state.info ⟨first,last⟩}
        (typed.header _) (framed.hide_outer state.info ⟨first,last⟩ present) room first last slot span

theorem step {text : Source} (valid : ValidText text) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) :
    StepTyped (signatureStep modelSignatureCalls text false state) := by
  dsimp +instances only [signatureStep, modelSignatureCalls]
  simp only [Bool.false_and, Bool.not_false, Bool.true_and, Bool.false_or, Bool.false_eq_true,
    decide_eq_true_eq, ↓reduceIte]
  split
  · exact typed.info
  · rename_i accepted
    have named : PackageBindings.validName (metadataText text)
        ⟨skipAt text state.header.position, nameAfter text (skipAt text state.header.position)⟩ = true :=
      Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false]))
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    split
    · exact typed.info
    · rename_i spare
      have room : state.info.parameters.length < maxFormals := by
        have capacity := typed.info.2.2.2.2.2.2.2.1
        omega
      let selected := {state with formalStart :=
        if state.formalCount = 0 then state.info.parameters.length + 1 else state.formalStart}
      have selectedTyped : StateTyped selected := by
        refine ⟨typed.info, typed.item, typed.routines, typed.count, ?_⟩
        dsimp only [selected]
        split
        · omega
        · exact typed.first
      exact read_name valid state.header.position selected selectedTyped framed room _ _ _ span

theorem routine_formals {item : Routine} (typed : item.Typed) (first count : Nat)
    (firstBound : first ≤ maxFormals) (countBound : count ≤ maxFormals) :
    ({item with formalFirst := first, count} : Routine).Typed := by
  rcases typed with ⟨specName, bodyName, specResult, bodyResult, specFirst, specAfter,
    bodyFirst, bodyAfter, _, _, rest⟩
  exact ⟨specName, bodyName, specResult, bodyResult, specFirst, specAfter, bodyFirst, bodyAfter,
    firstBound, countBound, rest⟩

theorem routine_result {item : Routine} (typed : item.Typed) (mark : PackageTypeResult)
    (named : mark.name.Typed) (bounded : mark.bounds.Bounded) (identity : mark.identity ≤ maxExports + 1) :
    ({item with
      resultKind := mark.kind, resultBounds := mark.bounds
      resultTypeIdentity := mark.identity, specResultName := mark.name} : Routine).Typed := by
  rcases typed with ⟨specName, bodyName, _, bodyResult, specFirst, specAfter,
    bodyFirst, bodyAfter, first, count, _, _, reads, writes⟩
  exact ⟨specName, bodyName, named, bodyResult, specFirst, specAfter, bodyFirst, bodyAfter,
    first, count, bounded, identity, reads, writes⟩

theorem routine_after {item : Routine} (typed : item.Typed) (after : Nat)
    (bounded : after ≤ maxSourceLength + 1) : ({item with specAfter := after} : Routine).Typed := by
  rcases typed with ⟨specName, bodyName, specResult, bodyResult, specFirst, _, rest⟩
  exact ⟨specName, bodyName, specResult, bodyResult, specFirst, bounded, rest⟩

theorem after_type {text : Source} (valid : ValidText text) (outer : ParserState)
    (state : SignatureState) (typed : StateTyped state) (item : Routine) (itemTyped : item.Typed)
    (mark : PackageTypeResult)
    (marked : item.kind = .function → mark.after ≠ 0 →
      mark.name.Typed ∧ mark.bounds.Bounded ∧ mark.identity ≤ maxExports + 1) :
    (signatureAfterType modelSignatureCalls text outer false state item mark).info.Typed := by
  dsimp only [signatureAfterType]
  simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
  split
  · exact typed.info
  · rename_i present
    let result := if item.kind = .function then
        {item with
          resultKind := mark.kind, resultBounds := mark.bounds
          resultTypeIdentity := mark.identity, specResultName := mark.name} else item
    have resultTyped : result.Typed := by
      dsimp only [result]
      split
      · rename_i selected
        obtain ⟨name, bound, identity⟩ := marked selected (fun absent => present ⟨selected, absent⟩)
        exact routine_result itemTyped mark name bound identity
      · exact itemTyped
    let position := if result.kind = .function then mark.after else state.header.position
    let following := tokenAfter text position (.symbol ";")
    change (if decide (following ≤ outer.position) || !modelSignatureCalls.stateValid text
      {state.header with position := following} then rejectedSignature state.info else
      (⟨{state.info with routines := state.info.routines ++ [{result with specAfter := following}]},
        {state.header with position := following}⟩ : SignatureResult)).info.Typed
    split
    · exact typed.info
    · apply append_routine typed.info typed.routines
      exact routine_after resultTyped following
        (Nat.le_trans (fixedAfter_result_bound text position ";" false (by decide))
          (Nat.add_le_add_right valid.2 1))

theorem finish {text : Source} (valid : ValidText text) (outer : ParserState)
    (state : SignatureState) (typed : StateTyped state) (framed : ReaderFrame text state.header) :
    (finishSignature modelSignatureCalls text outer false state).info.Typed := by
  rw [finishSignature_afterType]
  simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
  let item := {state.item with count := state.formalCount, formalFirst := state.formalStart}
  have itemTyped : item.Typed := routine_formals typed.item _ _ typed.first
    (Nat.le_trans typed.count typed.info.2.2.2.2.2.2.2.1)
  let position := tokenAfter text state.header.position (.word "return")
  let mark : PackageTypeResult := if item.kind = .function then packageTypeAt text state.header state.info position else {}
  apply after_type valid outer state typed item itemTyped mark
  intro selected present
  have chosen : mark = packageTypeAt text state.header state.info position := by simp only [mark, selected, ↓reduceIte]
  rw [chosen] at present ⊢
  have fields := (package_type_domain text state.header state.info position framed
    (fixedAfter_result_bound text _ "return" true (by decide))).resolve_left present
  exact ⟨MetadataTypes.type_name valid _ _ _, fields.bounded,
    ApplicationPackageBodies.package_type_identity text state.header state.info typed.info.2.2.2.1 position⟩

theorem loop {text : Source} (valid : ValidText text) {state : SignatureState} {result : SignatureExit}
    (run : SignatureLoop modelSignatureCalls text false state result)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) :
    ExitTyped result ∧ SignatureExitFramed text result := by
  induction run with
  | returned parsed =>
    have fields := step valid _ typed framed
    rw [parsed] at fields
    exact ⟨fields, True.intro⟩
  | ready parsed =>
    have fields := step valid _ typed framed
    have frame := signature_step_framed false _ framed
    rw [parsed] at fields frame
    exact ⟨fields, frame⟩
  | next parsed _ ih =>
    have fields := step valid _ typed framed
    have frame := signature_step_framed false _ framed
    rw [parsed] at fields frame
    exact ih fields frame

end Silver.ApplicationPackageDeclarations.SignatureSpecificationTypes

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions PackageBindings

/-- New signature declarations preserve native metadata component subtypes on
every return, including rejected signatures after appending formal rows. -/
theorem readSignature_specification_typed {text : Source} (valid : ValidText text)
    (outer : ParserState) (framed : ReaderFrame text outer) (info : Metadata) (typed : info.Typed) :
    (readSignature text outer info false).info.Typed := by
  have started := SignatureSpecificationTypes.start valid outer framed info typed
  have startFrame := signature_start_framed outer framed info false
  unfold readSignature
  cases chosen : signatureStart modelSignatureCalls text outer info false with
  | returned result =>
    rw [chosen] at started
    exact started
  | ready state =>
    rw [chosen] at started startFrame
    exact SignatureSpecificationTypes.finish valid outer state started startFrame
  | loop state =>
    dsimp only
    rw [chosen] at started startFrame
    have ended := SignatureSpecificationTypes.loop valid (runSignatureLoop_exec text false state) started startFrame
    cases returned : runSignatureLoop text false state with
    | returned result =>
      rw [returned] at ended
      exact ended.1
    | ready finalState =>
      rw [returned] at ended
      exact SignatureSpecificationTypes.finish valid outer finalState ended.1 ended.2

end Silver.ApplicationPackageDeclarations
