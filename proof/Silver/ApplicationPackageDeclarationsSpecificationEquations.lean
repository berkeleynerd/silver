module

public import Silver.ApplicationPackageDeclarationsSpecificationNative

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SpecificationNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def projectResult (locals : Locals) : SpecificationResult := ⟨locals .metadata "info", locals .state "exports"⟩

def projectState (locals : Locals) : SpecificationState :=
  ⟨locals .metadata "info", locals .state "exports", ⟨locals .number "first",locals .number "last"⟩⟩

/-- Both primitive dictionaries enter the raw model through their native
specializations. Only the actual Package_Signature_At in-out procedure is used. -/
def rawCalls (calls : SpecificationCalls) (procedures : ProcedureCalls) : SpecificationCalls :=
  {calls with signature := procedures.signature}

def inputLocals (locals : Locals) (source : Source) (metadata : PackageBindings.Metadata) : Locals :=
  (locals.set .source "text" source).set .metadata "info" metadata

macro "spec_values" : tactic => `(tactic|
  dsimp +instances only [Control.Statement.eval, Control.Statement.list, Control.TableKind.resize,
    ApplicationPackageProcedure.Primitive.eval, Place.expression, Place.set, Expr.eval, Updates.eval,
    Field.get, Field.set, Index.get, Index.set, PackageRecord.defaults, Declaration.eval, Declaration.names,
    Initialization.value, List.foldr, List.foldl, Control.constant, Control.localDeclaration, functions,
    Control.call2, Control.call3, Control.call4, take,
    SpecificationNative.text, info, exports, nextFrame, object, exportItem, first, last, name,
    position, nextPosition, exportCount, routineCount, lastRoutine, before, endFirst, endLast, following,
    item, itemName, mark, rejected, rejectIf, projectResult, projectState])

macro "spec_lookups" : tactic => `(tactic|
  simp only [Locals.set, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte])

theorem finish_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (done : SpecificationResult → α) (returned exited : Locals → α) :
    finish.eval (functions calls) procedures backing locals (fun store => done (projectResult store)) returned exited =
    done (finishSpecification calls (locals .source "text") (projectState locals)) := by
  unfold finish finishSpecification
  spec_values
  spec_lookups
  split <;> rfl

/-- The entry observes the original package name independently of later
metadata changes. A zero pragma endpoint returns the updated metadata and
the actual partially initialized export frame. -/
theorem entry_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (prior : Locals) (source : Source) (metadata : PackageBindings.Metadata)
    (bodyNext : Source → SpecificationState → α) (done : SpecificationResult → α) (exited : Locals → α) :
    entry.eval (functions calls) procedures backing
      (body.declarations.foldl (Declaration.eval (functions calls)) (inputLocals prior source metadata))
      (fun store => bodyNext (store .source "text") (projectState store))
      (fun store => done (projectResult store)) exited =
    match specificationStart calls source metadata with
    | .loop state => bodyNext source state
    | .returned result => done result := by
  unfold body entry specificationStart inputLocals
  spec_values
  spec_lookups
  simp only [Bool.not_eq_true', decide_eq_true_eq]
  split <;> first | rfl | (split <;> rfl)

theorem storeExport_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next : Source → Nat → SpecificationState → α) (returned exited : Locals → α) :
    storeExport.eval (functions calls) procedures backing locals
      (fun store => next (store .source "text") (store .number "before") (projectState store)) returned exited =
    next (locals .source "text") (locals .number "before")
      {projectState locals with
        info := {locals .metadata "info" with exports :=
          (locals .metadata "info").exports ++ [locals .exportItem "export"]}
        exports := locals .state "next"} := by
  unfold storeExport
  spec_values
  spec_lookups
  simp only [Storage.resize_length, Nat.add_sub_cancel, Storage.write_after_resize]

theorem progressCheck_meaning (calls : SpecificationCalls) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next : Source → SpecificationState → α) (returned : SpecificationResult → α)
    (exited : Locals → α) :
    progressCheck.eval (functions calls) procedures backing locals
      (fun store => next (store .source "text") (projectState store)) (fun store => returned (projectResult store)) exited =
    match continueSpecification calls (locals .source "text") (locals .number "before") (projectState locals) with
    | .next state | .ready state => next (locals .source "text") state
    | .returned result => returned result := by
  unfold progressCheck continueSpecification
  spec_values
  spec_lookups
  split <;> rfl

end Silver.ApplicationPackageDeclarations.SpecificationNative
