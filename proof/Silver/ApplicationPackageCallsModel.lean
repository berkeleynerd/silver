module

public import Silver.ApplicationPackageTypes
public import Silver.QualifiedNames

@[expose] public section

/-! Executable package-call equations retain source association order, the
completion-prefix lookup and all explicit/implicit alias checks. Imported
readers remain parameters. None of the raw equations assumes that accepted
metadata already has a semantic routine signature or safety certificate. -/
namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

structure Calls where
  reference : Source → Nat → QualifiedNames.Reference
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  booleanLookup : Source → BooleanBindings.Environment → Nat → Nat → Nat
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  lookupRoutine : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Bool → Nat
  take : Source → Nat → ShellToken → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  actualAfter : Source → ParseContext → Nat → ActiveFlow → FunctionBindings.Formal → Nat
  targetActual : Source → ParseContext → Nat → ActiveFlow → ProcedureBindings.Formal → ProcedureActualResult
  stateTarget : Source → ParseContext → PackageBindings.Metadata → Nat → Nat
  stateReads : Source → ParseContext → PackageBindings.Metadata → Nat → Nat → PackageBindings.StateSet
  actualNameFree : Source → Nat → Nat → Nat → Nat → Bool
  visibleState : Source → ParseContext → PackageBindings.Metadata → Nat → Bool
  validBody : Source → ParseContext → BodyScan → Bool

def packageCallee (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (position : Nat) (kind : PackageBindings.RoutineKind) : Nat :=
  let reference := calls.reference text position
  if info.completed > info.routines.length ∨ reference.after = 0 then 0
  else if context.pure = true ∧ (reference.qualifierFirst ≠ 0 ∨
      calls.scalarLookup text context.scalarNames reference.first reference.after ≠ 0 ∨
      calls.booleanLookup text context.booleanNames reference.first reference.after ≠ 0) then 0
  else if context.pure = false ∧ calls.sameName text
      ⟨reference.qualifierFirst, reference.qualifierAfter⟩ ⟨info.nameFirst, info.nameAfter⟩ = false then 0
  else
    let callee := calls.lookupRoutine text info ⟨reference.first, reference.after⟩ true
    if callee ≠ 0 ∧ (info.routineAt callee).kind = kind then callee else 0

def failure (input : ApplicationScan) : ApplicationCall :=
  {result := invalidApplication input}

structure ActualFrame where
  cursor : Nat
  named : Bool := false
  actuals : List PackageActual := List.replicate PackageBindings.maxFormals {}
  seen : List Bool := List.replicate PackageBindings.maxFormals false
  result : ApplicationCall
  callWrites : PackageBindings.StateSet

def ActualFrame.actual (frame : ActualFrame) (slot : Nat) : PackageActual :=
  frame.actuals.getD (slot - 1) {}

def formalSlots (item : PackageBindings.Routine) : List Nat :=
  (List.range item.count).map (item.formalFirst + ·)

/-- Native named association scanning keeps the last equal formal spelling.
Its later Seen test remains separate; no uniqueness premise is inserted. -/
def namedSlot (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (first after : Nat) : Nat :=
  (formalSlots item).foldl (fun slot index =>
    if calls.sameName text ⟨first, after⟩ (info.parameterAt index).specName then index else slot) 0

def inputFormal (parameter : PackageBindings.Formal) : FunctionBindings.Formal :=
  {first := parameter.specName.first, after := parameter.specName.after,
   kind := parameter.kind, bounds := parameter.bounds, typeId := 0}

def outputFormal (parameter : PackageBindings.Formal) : ProcedureBindings.Formal :=
  {first := parameter.specName.first, after := parameter.specName.after,
   kind := parameter.kind, bounds := parameter.bounds, typeId := 0, mode := parameter.mode}

def markState (set : PackageBindings.StateSet) (identity : Nat) : PackageBindings.StateSet :=
  if identity = 0 then set else set.set (identity - 1) true

def actualStep (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (ordinal : Nat) (frame : ActualFrame) : Option ActualFrame := do
  let first := calls.skip text frame.cursor
  let after := calls.nameAfter text first
  let arrow := calls.take text after (.symbol "=>")
  let (slot, named, cursor) ←
    if arrow ≠ 0 then some (namedSlot calls text info item first after, true, arrow)
    else if frame.named then none
    else some (item.formalFirst + ordinal - 1, frame.named, frame.cursor)
  if slot = 0 ∨ frame.seen.getD (slot - 1) false = true then none else do
    let parameter := info.parameterAt slot
    let original := {frame.actual slot with first := cursor}
    let (following, actual) :=
      if parameter.mode = .input then
        (calls.actualAfter text context cursor input.scan.facts (inputFormal parameter), original)
      else
        let target := calls.targetActual text context cursor input.scan.facts (outputFormal parameter)
        (target.after, {original with target := target, writtenState := calls.stateTarget text context info cursor})
    if following ≤ cursor then none else do
      let actual := {actual with after := following}
      let actual := if parameter.mode ≠ .output then
        {actual with reads := calls.stateReads text context info cursor following} else actual
      let result := {frame.result with result := {frame.result.result with
        reads := PackageBindings.stateUnion frame.result.result.reads actual.reads}}
      let finish := calls.take text following (if ordinal = item.count then .symbol ")" else .symbol ",")
      if finish = 0 then none else some {frame with cursor := finish, named := named, actuals := frame.actuals.set (slot - 1) actual, seen := frame.seen.set (slot - 1) true, result := result, callWrites := markState frame.callWrites actual.writtenState}

def readActuals (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (afterName : Nat) : Option ActualFrame :=
  let initial : ActualFrame :=
    {cursor := afterName, result := {result := input}, callWrites := item.mayWrite}
  if item.count = 0 then some initial else
    let opened := calls.take text afterName (.symbol "(")
    if opened = 0 then none else
      (List.range item.count).foldlM
        (fun frame index => actualStep calls text context input info item (index + 1) frame)
        {initial with cursor := opened}

def replaceScalar (result : ApplicationCall) (scalar : Nat) (bounds : Integer.Interval) : ApplicationCall :=
  {result with result := {result.result with scan :=
    {result.result.scan with facts := result.result.scan.facts.replace scalar bounds}}}

def aliasStep (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (actuals : List PackageActual)
    (result : ApplicationCall) (index : Nat) : Option ApplicationCall :=
  let actual := actuals.getD (index - 1) {}
  if (List.range info.states.length).any (fun state =>
      PackageBindings.StateSet.get item.mayWrite (state + 1) &&
        PackageBindings.StateSet.get actual.reads (state + 1)) then none
  else if (info.parameterAt index).mode = .input then some result
  else if actual.writtenState ≠ 0 ∧
      (PackageBindings.StateSet.get item.mayRead actual.writtenState = true ∨
       PackageBindings.StateSet.get item.mayWrite actual.writtenState = true) then none
  else if (formalSlots item).any (fun other => decide (index ≠ other) &&
      !calls.actualNameFree text (actuals.getD (other - 1) {}).first
        (actuals.getD (other - 1) {}).after actual.target.first actual.target.after) then none
  else
    let result := replaceScalar result actual.target.scalar (info.parameterAt index).bounds
    some {result with result := {result.result with scan := {result.result.scan with assigned := true}}}

def checkAliases (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (frame : ActualFrame) : Option ApplicationCall :=
  (formalSlots item).foldlM (aliasStep calls text info item frame.actuals) frame.result

def resetState (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (result : ApplicationCall) (index : Nat) : ApplicationCall :=
  let state := info.stateAt index
  if PackageBindings.StateSet.get writes index = true ∧
      calls.visibleState text context info index = true ∧ state.kind = .integer then
    let scalar := calls.scalarLookup text context.scalarNames state.name.first state.name.after
    replaceScalar result scalar (ScalarExpression.binding context.scalarNames scalar).declaredBounds
  else result

def finishCall (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (kind : PackageBindings.RoutineKind)
    (item : PackageBindings.Routine) (frame : ActualFrame) (checked : ApplicationCall) : ApplicationCall :=
  let result := {checked with result := {checked.result with
    reads := PackageBindings.stateUnion checked.result.reads item.mayRead,
    writes := PackageBindings.stateUnion checked.result.writes frame.callWrites}}
  let result := (List.range info.states.length).foldl
    (fun result state => resetState calls text context info frame.callWrites result (state + 1)) result
  let scan := {result.result.scan with position := frame.cursor}
  let scan := if kind = .procedure then {scan with assigned := true} else scan
  {result with value := ⟨frame.cursor, item.resultKind, item.resultBounds⟩, result := {result.result with scan := scan}}

/-- Raw call stages expose the exact native environment at this call. In
particular, the supplied Info.Completed prefix is never replaced by a final
whole-package routine table. -/
def callStages (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (position : Nat)
    (kind : PackageBindings.RoutineKind) : Option (Nat × PackageBindings.Routine × ActualFrame × ApplicationCall) := do
  let callee := packageCallee calls text context info position kind
  if callee = 0 then none else do
    let item := info.routineAt callee
    if item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
        item.count > info.parameters.length - item.formalFirst + 1) then none else do
      let frame ← readActuals calls text context input info item (calls.reference text position).after
      let aliased ← checkAliases calls text info item frame
      let result := finishCall calls text context info kind item frame aliased
      if frame.cursor ≤ position ∨ calls.validBody text context result.result.scan = false then none
      else some (callee, item, frame, result)

def packageCallAt (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (position : Nat)
    (kind : PackageBindings.RoutineKind) : ApplicationCall :=
  match callStages calls text context input info position kind with
  | none => failure input | some (_, _, _, result) => result

theorem accepted_stages {calls text context input info position kind}
    (accepted : (packageCallAt calls text context input info position kind).value.after ≠ 0) :
    ∃ callee item frame result,
      callStages calls text context input info position kind = some (callee, item, frame, result) ∧
      packageCallAt calls text context input info position kind = result := by
  cases found : callStages calls text context input info position kind with
  | none => simp only [packageCallAt, found, failure, Predicate.invalidCall, ne_eq, not_true_eq_false] at accepted
  | some stages =>
      rcases stages with ⟨callee, item, frame, result⟩
      exact ⟨callee, item, frame, result, rfl, by simp only [packageCallAt, found]⟩

end Silver.ApplicationPackageCalls
