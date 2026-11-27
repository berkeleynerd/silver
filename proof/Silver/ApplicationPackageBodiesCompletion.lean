module

public import Silver.ApplicationPackageBodiesModel
public import Silver.ApplicationPackageDeclarationsTypes

@[expose] public section

/-! Routine-completion equations keep signature writes on every failure, read
all output-prefix RHSs before exposing any output formal, and commit completed
routine effects only after the exact original footer. Local-declaration loop
execution is explicit; its finite execution bound is not a language limit. -/
namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackages
open ApplicationPackageDeclarations (ObjectResult SignatureResult)

structure CompletionCalls where
  takeToken : Source → Nat → ShellToken → Nat
  skipAt : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  validName : Source → PackageBindings.NameSpan → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  signatureAt : Source → ParserState → PackageBindings.Metadata → Bool → SignatureResult
  routineFrame : Source → ParserState → PackageBindings.Metadata → Nat → Nat → ParserState
  objectAt : Source → ParserState → PackageBindings.Metadata → Bool → ObjectResult
  contextOf : ScanResult → ParseContext
  bodyOf : ScanResult → BodyScan
  initialFlow : ParseContext → ActiveFlow
  stateReads : Source → ParseContext → PackageBindings.Metadata → Nat → Nat → PackageBindings.StateSet
  actualAfter : Source → ParseContext → Nat → ActiveFlow → FunctionBindings.Formal → Nat
  appendFormal : ParserState → PackageBindings.NameSpan → ApplicationPackageNames.PackageTypeResult →
    ProcedureBindings.Mode → ParserState
  applicationTail : Source → ParseContext → ApplicationScan → PackageBindings.Metadata →
    BodyStop → Bool → FunctionBindings.Metadata → ProcedureBindings.Metadata → ApplicationScan
  functionReturnAfter : Source → ParseContext → BodyScan → FunctionTypeResult → Nat

structure CompletionResult where
  globals : ParserState
  info : PackageBindings.Metadata

def completionFailed (info : PackageBindings.Metadata) : CompletionResult := ⟨invalidState, info⟩

structure InitializationFrame where
  frame : ParserState
  reads : PackageBindings.StateSet := PackageBindings.emptyStateSet
  initialized : Bool := false

def formalIndices (item : PackageBindings.Routine) : List Nat :=
  (List.range item.count).map (item.formalFirst + ·)

def formalRangeRejected (info : PackageBindings.Metadata) (item : PackageBindings.Routine) : Bool :=
  decide (item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
    item.count > info.parameters.length - item.formalFirst + 1))

inductive LocalStep
  | failed
  | finished (state : InitializationFrame)
  | continued (state : InitializationFrame)

def localStep (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state : InitializationFrame) : LocalStep :=
  if calls.takeToken text state.frame.position (.word "begin") ≠ 0 then .finished state
  else
    let first := calls.skipAt text state.frame.position
    let last := calls.nameAfter text first
    if (formalIndices item).any (fun index =>
        calls.sameName text ⟨first, last⟩ (info.parameterAt index).bodyName) then .failed
    else
      let object := calls.objectAt text state.frame info true
      if object.frame.position ≤ state.frame.position then .failed
      else .continued {state with frame := object.frame, reads := (PackageBindings.stateUnion state.reads
        (calls.stateReads text (calls.contextOf ⟨object.frame, false, false⟩) info object.initFirst object.initAfter))}

def localsFuel (step : InitializationFrame → LocalStep) : Nat → InitializationFrame → Option (Option InitializationFrame)
  | 0, _ => none
  | fuel + 1, state => match step state with
    | .failed => some none
    | .finished result => some (some result)
    | .continued next => localsFuel step fuel next

def outputInitializer (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (formal : PackageBindings.Formal) (state : InitializationFrame) : Option InitializationFrame :=
  if formal.mode ≠ .output then some state
  else if !calls.validName text formal.bodyName then none
  else
    let first := calls.skipAt text state.frame.position
    let last := calls.nameAfter text first
    if !calls.sameName text ⟨first, last⟩ formal.bodyName then none
    else
      let valueFirst := calls.takeToken text last (.symbol ":=")
      let context := {calls.contextOf ⟨state.frame, false, false⟩ with declarationCount := 0}
      let valueAfter := calls.actualAfter text context valueFirst (calls.initialFlow context)
        ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩
      let reads := PackageBindings.stateUnion state.reads (calls.stateReads text context info valueFirst valueAfter)
      let following := calls.takeToken text valueAfter (.symbol ";")
      if following ≤ state.frame.position then none
      else some {frame := {state.frame with position := following}, reads, initialized := true}

def outputInitializers (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata) :
    List Nat → InitializationFrame → Option InitializationFrame
  | [], state => some state
  | index :: rest, state =>
      (outputInitializer calls text info (info.parameterAt index) state).bind
        (outputInitializers calls text info rest)

def appendOutput (calls : CompletionCalls) (text : Source)
    (formal : PackageBindings.Formal) (frame : ParserState) : Option ParserState :=
  if formal.mode ≠ .output then some frame
  else if !calls.validName text formal.bodyName then none
  else
    let result := calls.appendFormal frame formal.bodyName
      ⟨formal.bodyTypeName, formal.bodyTypeName.after, formal.kind, formal.bounds, formal.typeIdentity⟩ formal.mode
    if result.position = 0 then none else some result

def appendOutputs (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata) :
    List Nat → ParserState → Option ParserState
  | [], frame => some frame
  | index :: rest, frame => (appendOutput calls text (info.parameterAt index) frame).bind
      (appendOutputs calls text info rest)

def completionContextOf (calls : CompletionCalls) (state : InitializationFrame) : ParseContext :=
  {calls.contextOf ⟨state.frame, state.initialized, false⟩ with declarationCount := 0}

def completionInput (calls : CompletionCalls) (item : PackageBindings.Routine)
    (state : InitializationFrame) : ApplicationScan :=
  {scan := calls.bodyOf ⟨state.frame, state.initialized, false⟩
   allowProcedureCalls := decide (item.kind = .procedure)
   reads := state.reads}

def completionDispatch (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state : InitializationFrame) : ApplicationScan :=
  calls.applicationTail text (completionContextOf calls state) (completionInput calls item state) info
    (if item.kind = .function then .returnOnly else .endOnly)
    (decide (item.kind = .procedure) && !state.initialized) {} {}

def completionReturn (calls : CompletionCalls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (result : ApplicationScan) :
    Option ApplicationScan :=
  if item.kind = .function then
    let first := calls.takeToken text result.scan.position (.word "return")
    let after := calls.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩
    let result := {result with
      reads := PackageBindings.stateUnion result.reads (calls.stateReads text context info first after)
      scan := {result.scan with position := calls.takeToken text after (.symbol ";")}}
    if result.scan.position = 0 ∨ result.writes ≠ PackageBindings.emptyStateSet then none else some result
  else some result

def completionFooter (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine)
    (result : ApplicationScan) : CompletionResult :=
  let first := calls.skipAt text (calls.takeToken text result.scan.position (.word "end"))
  let last := calls.nameAfter text first
  let following := calls.takeToken text last (.symbol ";")
  if following ≤ globals.position ∨ calls.sameName text ⟨first, last⟩ item.bodyName ≠ true then
    completionFailed info
  else
    let item := {item with
      bodyAfter := following
      mayRead := result.reads
      mayWrite := result.writes
      assigned := result.scan.assigned}
    ⟨{globals with position := following},
      {info with
        routines := info.routines.set (index - 1) item
        completed := index
        assigned := info.assigned || item.assigned}⟩

def completionBody (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine)
    (state : InitializationFrame) : CompletionResult :=
  let result := completionDispatch calls text info item state
  if result.scan.position = 0 then completionFailed info
  else
    match completionReturn calls text (completionContextOf calls state) info item result with
    | none => completionFailed info
    | some returned => completionFooter calls text globals info index item returned

def completionOutputs (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine)
    (localFrame : InitializationFrame) : CompletionResult :=
  let state := {localFrame with frame :=
    {localFrame.frame with position := calls.takeToken text localFrame.frame.position (.word "begin")}}
  match outputInitializers calls text info (formalIndices item) state with
  | none => completionFailed info
  | some initialized =>
    match appendOutputs calls text info (formalIndices item) initialized.frame with
    | none => completionFailed info
    | some completedFrame =>
      completionBody calls text globals info index item {initialized with frame := completedFrame}

def completionLocals (calls : CompletionCalls) (fuel : Nat) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine)
    (state : InitializationFrame) : Option CompletionResult :=
  (localsFuel (localStep calls text info item) fuel state).map fun result =>
    match result with
    | none => completionFailed info
    | some localFrame => completionOutputs calls text globals info index item localFrame

def packageCompletionFuel (calls : CompletionCalls) (fuel : Nat) (text : Source)
    (globals : ParserState) (info : PackageBindings.Metadata) : Option CompletionResult :=
  if info.completed ≥ info.routines.length then some (completionFailed info)
  else
    let index := info.completed + 1
    let signature := calls.signatureAt text globals info true
    let info := signature.info
    if signature.header.position = 0 then some (completionFailed info)
    else
      let item := info.routineAt index
      if formalRangeRejected info item then some (completionFailed info)
      else
        let frame := calls.routineFrame text globals info index signature.header.position
        if frame.position = 0 then some (completionFailed info)
        else completionLocals calls fuel text globals info index item {frame}

def SameDeclarations (before after : ParserState) : Prop :=
  ∃ position, after = {before with position}

theorem SameDeclarations.refl (frame : ParserState) : SameDeclarations frame frame :=
  ⟨frame.position, rfl⟩

theorem SameDeclarations.trans {first second third : ParserState}
    (left : SameDeclarations first second) (right : SameDeclarations second third) : SameDeclarations first third := by
  obtain ⟨middle, rfl⟩ := left
  obtain ⟨last, rfl⟩ := right
  exact ⟨last, rfl⟩

theorem outputInitializer_sameDeclarations {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {formal : PackageBindings.Formal} {before after : InitializationFrame}
    (accepted : outputInitializer calls text info formal before = some after) :
    SameDeclarations before.frame after.frame := by
  unfold outputInitializer at accepted
  split at accepted
  · cases accepted; exact .refl _
  · split at accepted
    · contradiction
    · dsimp only at accepted
      split at accepted
      · contradiction
      · split at accepted
        · contradiction
        · cases accepted
          exact ⟨_, rfl⟩

theorem outputInitializers_sameDeclarations {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {indices : List Nat} {before after : InitializationFrame}
    (accepted : outputInitializers calls text info indices before = some after) :
    SameDeclarations before.frame after.frame := by
  induction indices generalizing before with
  | nil => cases accepted; exact .refl _
  | cons index rest induction =>
      simp only [outputInitializers, Option.bind_eq_some_iff] at accepted
      obtain ⟨middle, first, rest⟩ := accepted
      exact (outputInitializer_sameDeclarations first).trans (induction rest)

end Silver.ApplicationPackageBodies
