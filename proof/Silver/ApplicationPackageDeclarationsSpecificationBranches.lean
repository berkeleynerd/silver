module

public import Silver.ApplicationPackageDeclarationsSpecificationEquations

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SpecificationNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def observeStep (source : Source) (next : Source → SpecificationState → α)
    (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) : SpecificationStep → α
  | .next state => next source state
  | .ready state => exited source state
  | .returned result => returned result

def continueWith (calls : SpecificationCalls) (next : Source → SpecificationState → α)
    (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) (locals : Locals) : α :=
  let source := locals .source "text"
  observeStep source next returned exited (continueSpecification calls source (locals .number "before") (projectState locals))

def appendFrom (calls : SpecificationCalls) (next : Source → SpecificationState → α)
    (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) (locals : Locals) : α :=
  let following : SpecificationState := {projectState locals with
    info := {locals .metadata "info" with exports := (locals .metadata "info").exports ++ [locals .exportItem "export"]}
    exports := locals .state "next"}
  let source := locals .source "text"
  observeStep source next returned exited (continueSpecification calls source (locals .number "before") following)

theorem signatureBranch_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (saved : locals .number "before" = (locals .state "exports").position)
    (next : Source → SpecificationState → α) (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) :
    signatureBranch.eval (functions calls) procedures backing locals (continueWith calls next returned exited)
      (fun store => returned (projectResult store)) (fun store => exited (store .source "text") (projectState store)) =
    observeStep (locals .source "text") next returned exited
      (specificationRoutine (rawCalls calls procedures) (locals .source "text") (projectState locals)) := by
  unfold signatureBranch specificationRoutine continueWith rawCalls
  spec_values
  spec_lookups
  simp only [saved, Bool.or_eq_true, decide_eq_true_eq]
  split <;> rfl

theorem subtypeBranch_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (saved : locals .number "before" = (locals .state "exports").position)
    (next : Source → SpecificationState → α) (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) :
    subtypeBranch.eval (functions calls) procedures backing locals (appendFrom calls next returned exited)
      (fun store => returned (projectResult store)) (fun store => exited (store .source "text") (projectState store)) =
    observeStep (locals .source "text") next returned exited
      (specificationSubtype calls (locals .source "text") (projectState locals)) := by
  unfold subtypeBranch specificationSubtype appendFrom appendExport
  spec_values
  dsimp +instances only [Function.comp, Declarations.restore, Declaration.names, List.flatMap, List.foldl]
  simp [Locals.set, saved, Declaration.names]
  split <;> first | rfl | (split <;> rfl)

theorem objectBranch_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (saved : locals .number "before" = (locals .state "exports").position)
    (next : Source → SpecificationState → α) (returned : SpecificationResult → α) (exited : Source → SpecificationState → α) :
    objectBranch.eval (functions calls) procedures backing locals (appendFrom calls next returned exited)
      (fun store => returned (projectResult store)) (fun store => exited (store .source "text") (projectState store)) =
    observeStep (locals .source "text") next returned exited
      (specificationObject calls (locals .source "text") (projectState locals)) := by
  unfold objectBranch specificationObject appendFrom appendExport
  spec_values
  spec_lookups
  simp only [saved, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq]
  split <;> first | rfl | (split <;> rfl)

end Silver.ApplicationPackageDeclarations.SpecificationNative
