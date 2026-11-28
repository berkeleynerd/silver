module

public import Silver.ApplicationPackageDeclarationsSpecificationBranches
public import Silver.ApplicationPackageDeclarationsTransfers

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SpecificationNative
open Compose ApplicationNative Control ApplicationPackageProcedure

theorem progress_observation (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next : Source → SpecificationState → α) (returned : SpecificationResult → α)
    (exited : Source → SpecificationState → α) :
    progressCheck.eval (functions calls) procedures backing locals
      (fun store => next (store .source "text") (projectState store))
      (fun store => returned (projectResult store))
      (fun store => exited (store .source "text") (projectState store)) =
    continueWith calls next returned exited locals := by
  rw [progressCheck_meaning]
  simp only [continueWith, continueSpecification]
  cases (decide ((projectState locals).exports.position ≤ locals .number "before") ||
    !calls.stateValid (locals .source "text") (projectState locals).exports) <;> rfl

theorem storeExport_observation (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next : Source → SpecificationState → α) (returned : SpecificationResult → α)
    (exited : Source → SpecificationState → α) :
    storeExport.eval (functions calls) procedures backing locals
      (continueWith calls next returned exited) (fun store => returned (projectResult store))
      (fun store => exited (store .source "text") (projectState store)) =
    appendFrom calls next returned exited locals :=
  storeExport_meaning calls procedures backing locals
    (fun source before state => observeStep source next returned exited (continueSpecification calls source before state))
    (fun store => returned (projectResult store))
    (fun store => exited (store .source "text") (projectState store))

def savedBefore (locals : Locals) : Locals :=
  locals.set .number "before" (locals .state "exports").position

/-- Isolate the native control transfers without evaluating a branch twice.
The exit continues with the stored loop cursor and every ordinary branch
passes through the executable progress and state-validity check. -/
theorem iteration_control (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next returned exited : Locals → α) :
    iteration.eval (functions calls) procedures backing locals next returned exited =
    let source := locals .source "text"
    let cursor := (locals .state "exports").position
    let store := savedBefore locals
    let after := fun current => progressCheck.eval (functions calls) procedures backing current next returned exited
    if calls.take source cursor (.word "end") ≠ 0 then exited store
    else if calls.take source cursor (.word "function") ≠ 0 ∨ calls.take source cursor (.word "procedure") ≠ 0 then
      signatureBranch.eval (functions calls) procedures backing store after returned exited
    else exportBranch.eval (functions calls) procedures backing store after returned exited := by
  unfold iteration
  generalize signatureBranch = routine
  generalize exportBranch = otherBranch
  generalize progressCheck = guard
  dsimp only [savedBefore]
  spec_values
  spec_lookups
  simp only [Bool.or_eq_true, decide_eq_true_eq]

theorem export_control (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next returned exited : Locals → α) :
    exportBranch.eval (functions calls) procedures backing locals next returned exited =
    let source := locals .source "text"
    let cursor := (locals .state "exports").position
    let after := fun current => storeExport.eval (functions calls) procedures backing current next returned exited
    if (locals .metadata "info").exports.length = PackageBindings.maxExports then
      returned (locals.set .state "exports" invalidState)
    else if calls.take source cursor (.word "subtype") ≠ 0 then
      subtypeBranch.eval (functions calls) procedures backing locals after returned exited
    else objectBranch.eval (functions calls) procedures backing locals after returned exited := by
  unfold exportBranch
  generalize subtypeBranch = subtype
  generalize objectBranch = objectRead
  generalize storeExport = storeItem
  spec_values
  simp only [decide_eq_true_eq]

private def exportReading (calls : SpecificationCalls) (source : Source) (state : SpecificationState) : SpecificationStep :=
  if state.info.exports.length = PackageBindings.maxExports then .returned (rejectedSpecification state.info)
  else if calls.take source state.exports.position (.word "subtype") ≠ 0 then specificationSubtype calls source state
  else specificationObject calls source state

private theorem export_observation (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (saved : locals .number "before" = (locals .state "exports").position)
    (next : Source → SpecificationState → α) (returned : SpecificationResult → α)
    (exited : Source → SpecificationState → α) :
    exportBranch.eval (functions calls) procedures backing locals (continueWith calls next returned exited)
      (fun store => returned (projectResult store)) (fun store => exited (store .source "text") (projectState store)) =
    observeStep (locals .source "text") next returned exited
      (exportReading calls (locals .source "text") (projectState locals)) := by
  have sizeEq : (projectState locals).info.exports.length = (locals .metadata "info").exports.length := rfl
  have positionEq : (projectState locals).exports.position = (locals .state "exports").position := rfl
  simp only [export_control, storeExport_observation, exportReading, sizeEq, positionEq]
  split
  · rfl
  · split
    · exact subtypeBranch_meaning calls procedures backing locals saved next returned exited
    · exact objectBranch_meaning calls procedures backing locals saved next returned exited

theorem iteration_observation (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next : Source → SpecificationState → α) (returned : SpecificationResult → α)
    (exited : Source → SpecificationState → α) :
    iteration.eval (functions calls) procedures backing locals
      (fun store => next (store .source "text") (projectState store))
      (fun store => returned (projectResult store))
      (fun store => exited (store .source "text") (projectState store)) =
    observeStep (locals .source "text") next returned exited
      (specificationStep (rawCalls calls procedures) (locals .source "text") (projectState locals)) := by
  have saved : (savedBefore locals) .number "before" = ((savedBefore locals) .state "exports").position := by
    simp [savedBefore, Locals.set]
  have savedSource : (savedBefore locals) .source "text" = locals .source "text" := by simp [savedBefore, Locals.set]
  have savedState : projectState (savedBefore locals) = projectState locals := by simp [savedBefore, projectState, Locals.set]
  have routine := signatureBranch_meaning calls procedures backing (savedBefore locals) saved next returned exited
  have other := export_observation calls procedures backing (savedBefore locals) saved next returned exited
  rw [savedSource, savedState] at routine other
  have expand (source : Source) (state : SpecificationState) :
      specificationStep (rawCalls calls procedures) source state =
      if calls.take source state.exports.position (.word "end") ≠ 0 then .ready state
      else if calls.take source state.exports.position (.word "function") ≠ 0 ∨
          calls.take source state.exports.position (.word "procedure") ≠ 0 then
        specificationRoutine (rawCalls calls procedures) source state
      else exportReading calls source state := rfl
  have positionEq : (projectState locals).exports.position = (locals .state "exports").position := rfl
  simp only [iteration_control, progress_observation, expand, positionEq, savedSource, savedState]
  split
  · rfl
  · split
    · exact routine
    · exact other

end Silver.ApplicationPackageDeclarations.SpecificationNative
