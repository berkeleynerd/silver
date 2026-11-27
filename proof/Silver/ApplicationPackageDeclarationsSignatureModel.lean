module

public import Silver.ApplicationPackageDeclarationsModel

@[expose] public section

/-! Exact procedure state for package specification/completion signatures.
In-out metadata is retained on every early return, including failures after a
formal has already been appended. The loop relation has no artificial fuel. -/
namespace Silver.ApplicationPackageDeclarations
open Compose ApplicationPackageNames

structure SignatureCalls where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  take : Source → Nat → ShellToken → Nat
  validName : Source → PackageBindings.NameSpan → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  fresh : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Bool
  hide : Source → HiddenMarks → Nat → Nat → HiddenMarks
  hideOuter : Source → ParserState → PackageBindings.Metadata → PackageBindings.NameSpan → ParserState
  typeAt : Source → ParserState → PackageBindings.Metadata → Nat → PackageTypeResult
  append : ParserState → PackageBindings.NameSpan → PackageTypeResult → ProcedureBindings.Mode → ParserState
  stateValid : Source → ParserState → Bool

structure SignatureState where
  info : PackageBindings.Metadata
  header : ParserState
  item : PackageBindings.Routine
  routineId : Nat
  formalCount : Nat := 0
  formalStart : Nat := 0

inductive SignatureStart
  | returned (result : SignatureResult)
  | ready (state : SignatureState)
  | loop (state : SignatureState)

inductive SignatureStep
  | returned (result : SignatureResult)
  | ready (state : SignatureState)
  | next (state : SignatureState)

def rejectedSignature (info : PackageBindings.Metadata) : SignatureResult := ⟨info,invalidState⟩

def startSignatureBody (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (nameFirst nameAfter routineId : Nat)
    (item : PackageBindings.Routine) (formalStart : Nat) : SignatureStart :=
  let header := {outer with position := nameAfter, pure := true, «hiding» := calls.hide text outer.hiding nameFirst nameAfter}
  let state : SignatureState := ⟨info,header,item,routineId,0,formalStart⟩
  let opened := calls.take text header.position (.symbol "(")
  if opened = 0 then .ready state else .loop {state with header := {header with position := opened}}

def signatureStart (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (completing : Bool) : SignatureStart :=
  let original := calls.skip text outer.position
  let functionEnd := calls.take text outer.position (.word "function")
  let procedureEnd := calls.take text outer.position (.word "procedure")
  let first := calls.skip text (if functionEnd ≠ 0 then functionEnd else procedureEnd)
  let last := calls.nameAfter text first
  if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then
    .returned (rejectedSignature info)
  else if completing then
    if info.completed ≥ info.routines.length then .returned (rejectedSignature info) else
    let identity := info.completed + 1
    let item := info.routineAt identity
    if item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
      item.count > info.parameters.length - item.formalFirst + 1) then .returned (rejectedSignature info) else
    if !calls.sameName text item.specName ⟨first,last⟩ ||
        (decide (item.kind = .function) != decide (functionEnd ≠ 0)) then .returned (rejectedSignature info) else
    let updated := {item with bodyName := ⟨first,last⟩, bodyFirst := original}
    startSignatureBody calls text outer info first last identity updated item.formalFirst
  else
    if decide (info.routines.length = PackageBindings.maxRoutines) || !calls.fresh text info ⟨first,last⟩ then
      .returned (rejectedSignature info)
    else
      let item : PackageBindings.Routine := {
        kind := if functionEnd ≠ 0 then .function else .procedure
        specName := ⟨first,last⟩
        specFirst := original}
      startSignatureBody calls text outer info first last (info.routines.length + 1) item 0

def duplicateFormal (calls : SignatureCalls) (text : Source) (completing : Bool)
    (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) (first count : Nat) : Bool :=
  (List.range count).any fun offset => calls.sameName text name
    (if completing then (info.parameterAt (first + offset)).bodyName else (info.parameterAt (first + offset)).specName)

/-- The loop back edge follows the actual semicolon read and strict progress
guard. Closing the parameter list instead exits with the updated header. -/
def finishFormal (calls : SignatureCalls) (text : Source) (before : Nat)
    (updated : SignatureState) : SignatureStep :=
  let closed := calls.take text updated.header.position (.symbol ")")
  if closed ≠ 0 then .ready {updated with header := {updated.header with position := closed}} else
  let following := calls.take text updated.header.position (.symbol ";")
  if following ≤ before then .returned (rejectedSignature updated.info)
  else .next {updated with header := {updated.header with position := following}}

def storeFormal (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) (mode : ProcedureBindings.Mode)
    (mark : PackageTypeResult) : SignatureStep :=
  let parameter := state.info.parameterAt slot
  if completing && (!calls.sameName text parameter.specName ⟨first,last⟩ ||
      decide (parameter.mode ≠ mode ∨ parameter.kind ≠ mark.kind ∨
        parameter.typeIdentity ≠ mark.identity ∨ parameter.bounds ≠ mark.bounds)) then
    .returned (rejectedSignature state.info)
  else
  let parameter : PackageBindings.Formal := if completing then
      {parameter with bodyName := ⟨first,last⟩, bodyTypeName := mark.name}
    else {specName := ⟨first,last⟩, specTypeName := mark.name, kind := mark.kind, bounds := mark.bounds, typeIdentity := mark.identity, mode := mode}
  let info := if completing then {state.info with parameters := state.info.parameters.set (slot - 1) parameter}
    else {state.info with parameters := state.info.parameters ++ [parameter]}
  let header := calls.append {state.header with position := mark.after} ⟨first,last⟩ mark mode
  if header.position = 0 then .returned ⟨info,header⟩ else
  let updated := {state with info, header, formalCount := state.formalCount + 1}
  finishFormal calls text before updated

def readFormalType (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) : SignatureStep :=
  let colon := calls.take text last (.symbol ":")
  let inputEnd := calls.take text colon (.word "in")
  let modeResult : Nat × ProcedureBindings.Mode := if inputEnd ≠ 0 then
    let outputEnd := calls.take text inputEnd (.word "out")
    ⟨if outputEnd ≠ 0 then outputEnd else inputEnd, if outputEnd ≠ 0 then .inputOutput else .input⟩
    else ⟨calls.take text colon (.word "out"), .output⟩
  if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then
    .returned (rejectedSignature state.info)
  else
  let mark := calls.typeAt text state.header state.info modeResult.1
  if mark.after = 0 then .returned (rejectedSignature state.info) else
  storeFormal calls text completing before state first last slot modeResult.2 mark

def readFormalName (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) : SignatureStep :=
  if decide (state.formalCount > 0) && duplicateFormal calls text completing state.info ⟨first,last⟩ state.formalStart state.formalCount then
    .returned (rejectedSignature state.info)
  else
  let hidden := calls.hideOuter text state.header state.info ⟨first,last⟩
  if hidden.position = 0 then .returned ⟨state.info,hidden⟩ else
  readFormalType calls text completing before {state with header := hidden} first last slot

def signatureStep (calls : SignatureCalls) (text : Source) (completing : Bool)
    (state : SignatureState) : SignatureStep :=
  let before := state.header.position
  let first := calls.skip text before
  let last := calls.nameAfter text first
  if !calls.validName text ⟨first,last⟩ then .returned (rejectedSignature state.info) else
  if (completing && decide (state.formalCount ≥ state.item.count)) ||
      (!completing && decide (state.info.parameters.length = PackageBindings.maxFormals)) then
    .returned (rejectedSignature state.info)
  else
  let slot := if completing then state.formalStart + state.formalCount else state.info.parameters.length + 1
  let formalStart := if !completing && decide (state.formalCount = 0) then slot else state.formalStart
  readFormalName calls text completing before {state with formalStart} first last slot

def finishSignature (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (completing : Bool) (state : SignatureState) : SignatureResult :=
  if completing && decide (state.formalCount ≠ state.item.count) then rejectedSignature state.info else
  let item := if completing then state.item else {state.item with count := state.formalCount, formalFirst := state.formalStart}
  let mark := if item.kind = .function then
      calls.typeAt text state.header state.info (calls.take text state.header.position (.word "return"))
    else ({} : PackageTypeResult)
  if item.kind = .function ∧ mark.after = 0 then rejectedSignature state.info else
  if completing && decide (item.kind = .function) &&
      decide (item.resultKind ≠ mark.kind ∨ item.resultTypeIdentity ≠ mark.identity ∨ item.resultBounds ≠ mark.bounds) then
    rejectedSignature state.info
  else
  let item := if item.kind = .function then
      if completing then {item with bodyResultName := mark.name}
      else {item with resultKind := mark.kind, resultBounds := mark.bounds, resultTypeIdentity := mark.identity, specResultName := mark.name}
    else item
  let position := if item.kind = .function then mark.after else state.header.position
  let following := calls.take text position (if completing then .word "is" else .symbol ";")
  let header := {state.header with position := following}
  if decide (following ≤ outer.position) || !calls.stateValid text header then rejectedSignature state.info else
  let item := if completing then item else {item with specAfter := following}
  let info := if completing then {state.info with routines := state.info.routines.set (state.routineId - 1) item}
    else {state.info with routines := state.info.routines ++ [item]}
  ⟨info,header⟩

inductive SignatureExit
  | returned (result : SignatureResult)
  | ready (state : SignatureState)

inductive SignatureLoop (calls : SignatureCalls) (text : Source) (completing : Bool) :
    SignatureState → SignatureExit → Prop
  | returned {state result} (step : signatureStep calls text completing state = .returned result) :
      SignatureLoop calls text completing state (.returned result)
  | ready {state result} (step : signatureStep calls text completing state = .ready result) :
      SignatureLoop calls text completing state (.ready result)
  | next {state following result} (step : signatureStep calls text completing state = .next following)
      (tail : SignatureLoop calls text completing following result) :
      SignatureLoop calls text completing state result

theorem SignatureLoop.unique {calls text completing state left right}
    (a : SignatureLoop calls text completing state left)
    (b : SignatureLoop calls text completing state right) : left = right := by
  induction a with
  | returned step =>
      cases b with
      | returned other => exact congrArg SignatureExit.returned (SignatureStep.returned.inj (step.symm.trans other))
      | ready other => cases step.symm.trans other
      | next other _ => cases step.symm.trans other
  | ready step =>
      cases b with
      | returned other => cases step.symm.trans other
      | ready other => exact congrArg SignatureExit.ready (SignatureStep.ready.inj (step.symm.trans other))
      | next other _ => cases step.symm.trans other
  | next step _ ih =>
      cases b with
      | returned other => cases step.symm.trans other
      | ready other => cases step.symm.trans other
      | next other rest =>
          have same := SignatureStep.next.inj (step.symm.trans other)
          cases same
          exact ih rest

/-- Full raw procedure relation, including the unchanged metadata of entry
failure and partially updated metadata of a failure inside its formal loop. -/
def SignatureExec (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (completing : Bool) (result : SignatureResult) : Prop :=
  match signatureStart calls text outer info completing with
  | .returned failed => result = failed
  | .ready state => result = finishSignature calls text outer completing state
  | .loop state => ∃ exit, SignatureLoop calls text completing state exit ∧
      result = match exit with
        | .returned failed => failed
        | .ready finalState => finishSignature calls text outer completing finalState

theorem SignatureExec.unique {calls text outer info completing left right}
    (a : SignatureExec calls text outer info completing left)
    (b : SignatureExec calls text outer info completing right) : left = right := by
  unfold SignatureExec at a b
  cases start : signatureStart calls text outer info completing with
  | returned failed =>
      simp only [start] at a b
      exact a.trans b.symm
  | ready state =>
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
