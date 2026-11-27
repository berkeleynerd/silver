module

public import Silver.ApplicationPackageDeclarationsSignatureModel

@[expose] public section

/-! Raw package-specification reader, retaining all side effects on metadata at
failure. Original name spans are stored separately from the in-out metadata. -/
namespace Silver.ApplicationPackageDeclarations
open Compose ApplicationPackageNames

structure SpecificationCalls where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  take : Source → Nat → ShellToken → Nat
  word : Source → Nat → String → Nat
  pragmaAfter : Source → Nat → Nat
  allowed : Source → PackageBindings.NameSpan → Bool
  fresh : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  hide : Source → HiddenMarks → Nat → Nat → HiddenMarks
  signature : Source → ParserState → PackageBindings.Metadata → Bool → SignatureResult
  subtype : Source → ParserState → Bool → ParserState
  object : Source → ParserState → PackageBindings.Metadata → Bool → ObjectResult
  stateValid : Source → ParserState → Bool

structure SpecificationState where
  info : PackageBindings.Metadata
  exports : ParserState
  name : PackageBindings.NameSpan

inductive SpecificationStart
  | returned (result : SpecificationResult)
  | loop (state : SpecificationState)

inductive SpecificationStep
  | returned (result : SpecificationResult)
  | ready (state : SpecificationState)
  | next (state : SpecificationState)

def rejectedSpecification (info : PackageBindings.Metadata) : SpecificationResult := ⟨info,invalidState⟩

def specificationStart (calls : SpecificationCalls) (text : Source)
    (info : PackageBindings.Metadata) : SpecificationStart :=
  let first := calls.skip text (calls.word text 1 "package")
  let last := calls.nameAfter text first
  if !calls.allowed text ⟨first,last⟩ then .returned (rejectedSpecification info) else
  let info := {info with nameFirst := first, nameAfter := last}
  let position := calls.pragmaAfter text (calls.take text last (.word "is"))
  let exports := {initialState with position, packageFirst := first, packageAfter := last}
  if position = 0 then .returned ⟨info,exports⟩ else .loop ⟨info,exports,⟨first,last⟩⟩

def continueSpecification (calls : SpecificationCalls) (text : Source)
    (before : Nat) (state : SpecificationState) : SpecificationStep :=
  if decide (state.exports.position ≤ before) || !calls.stateValid text state.exports then
    .returned (rejectedSpecification state.info)
  else .next state

def appendExport (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (next : ParserState) (item : PackageBindings.ExportDeclaration) : SpecificationStep :=
  let info := {state.info with exports := state.info.exports ++ [item]}
  continueSpecification calls text state.exports.position {state with info, exports := next}

def specificationRoutine (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) : SpecificationStep :=
  let result := calls.signature text state.exports state.info false
  if result.header.position = 0 ∨ result.info.routines.length = 0 then
    .returned (rejectedSpecification result.info)
  else
    let name := (result.info.routineAt result.info.routines.length).specName
    let exports := {state.exports with position := result.header.position, «hiding» := calls.hide text state.exports.hiding name.first name.after}
    continueSpecification calls text state.exports.position {state with info := result.info, exports}

def specificationSubtype (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) : SpecificationStep :=
  let next := calls.subtype text state.exports false
  if next.position = 0 then .returned (rejectedSpecification state.info) else
  let item := next.subtypeNames.items.getD (next.subtypeNames.items.length - 1) {}
  if !calls.fresh text state.info ⟨item.first,item.after⟩ then .returned (rejectedSpecification state.info) else
  let exportItem : PackageBindings.ExportDeclaration := {
    name := ⟨item.first,item.after⟩
    kind := .integerSubtype
    bounds := item.bounds
    typeIdentity := state.info.exports.length + 2}
  appendExport calls text state next exportItem

def specificationObject (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) : SpecificationStep :=
  let object := calls.object text state.exports state.info false
  if decide (object.frame.position = 0) || !object.constantObject then .returned (rejectedSpecification state.info) else
  let exportItem : PackageBindings.ExportDeclaration := {
    name := object.name
    kind := if object.mark.kind = .integer then .integerConstant else .booleanConstant
    bounds := if object.mark.kind = .integer then object.initialBounds else .full
    typeName := object.mark.name
    typeIdentity := object.mark.identity
    initializerFirst := object.initFirst
    initializerAfter := object.initAfter
    booleanValue := object.booleanValue}
  appendExport calls text state object.frame exportItem

def specificationStep (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) : SpecificationStep :=
  if calls.take text state.exports.position (.word "end") ≠ 0 then .ready state else
  if calls.take text state.exports.position (.word "function") ≠ 0 ∨
      calls.take text state.exports.position (.word "procedure") ≠ 0 then
    specificationRoutine calls text state
  else if state.info.exports.length = PackageBindings.maxExports then
    .returned (rejectedSpecification state.info)
  else if calls.take text state.exports.position (.word "subtype") ≠ 0 then
    specificationSubtype calls text state
  else specificationObject calls text state

def finishSpecification (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) : SpecificationResult :=
  let first := calls.skip text (calls.take text state.exports.position (.word "end"))
  let last := calls.nameAfter text first
  let following := calls.take text last (.symbol ";")
  if decide (state.info.routines.length = 0) || !calls.sameName text state.name ⟨first,last⟩ ||
      decide (following = 0) || decide (calls.skip text following ≠ text.length + 1) then
    rejectedSpecification state.info
  else ⟨state.info,{state.exports with position := following}⟩

inductive SpecificationExit
  | returned (result : SpecificationResult)
  | ready (state : SpecificationState)

inductive SpecificationLoop (calls : SpecificationCalls) (text : Source) :
    SpecificationState → SpecificationExit → Prop
  | returned {state result} (step : specificationStep calls text state = .returned result) :
      SpecificationLoop calls text state (.returned result)
  | ready {state result} (step : specificationStep calls text state = .ready result) :
      SpecificationLoop calls text state (.ready result)
  | next {state following result} (step : specificationStep calls text state = .next following)
      (tail : SpecificationLoop calls text following result) :
      SpecificationLoop calls text state result

theorem SpecificationLoop.unique {calls text state left right}
    (a : SpecificationLoop calls text state left) (b : SpecificationLoop calls text state right) : left = right := by
  induction a with
  | returned step =>
      cases b with
      | returned other => exact congrArg SpecificationExit.returned (SpecificationStep.returned.inj (step.symm.trans other))
      | ready other => cases step.symm.trans other
      | next other _ => cases step.symm.trans other
  | ready step =>
      cases b with
      | returned other => cases step.symm.trans other
      | ready other => exact congrArg SpecificationExit.ready (SpecificationStep.ready.inj (step.symm.trans other))
      | next other _ => cases step.symm.trans other
  | next step _ ih =>
      cases b with
      | returned other => cases step.symm.trans other
      | ready other => cases step.symm.trans other
      | next other rest =>
          have same := SpecificationStep.next.inj (step.symm.trans other)
          cases same
          exact ih rest

def SpecificationExec (calls : SpecificationCalls) (text : Source)
    (info : PackageBindings.Metadata) (result : SpecificationResult) : Prop :=
  match specificationStart calls text info with
  | .returned failed => result = failed
  | .loop state => ∃ exit, SpecificationLoop calls text state exit ∧
      result = match exit with
        | .returned failed => failed
        | .ready finalState => finishSpecification calls text finalState

theorem SpecificationExec.unique {calls text info left right}
    (a : SpecificationExec calls text info left) (b : SpecificationExec calls text info right) : left = right := by
  unfold SpecificationExec at a b
  cases start : specificationStart calls text info with
  | returned failed =>
      simp only [start] at a b
      exact a.trans b.symm
  | loop state =>
      simp only [start] at a b
      obtain ⟨leftExit,leftRun,leftResult⟩ := a
      obtain ⟨rightExit,rightRun,rightResult⟩ := b
      have same := leftRun.unique rightRun
      cases same
      exact leftResult.trans rightResult.symm

end Silver.ApplicationPackageDeclarations
