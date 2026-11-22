module

public import Silver.ApplicationPackageCompletionNative
public import Silver.ApplicationPackageProcedureLoops

@[expose] public section

/-! Complete finite command equations for the phases of routine completion.
Each equation includes all early returns and arbitrary incoming local values. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def failed (locals : Locals) : Outcome :=
  ⟨locals.set .state "globals" Compose.invalidState, true⟩

def localStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let text := locals .source "text"
  let frame := locals .state "frame"
  let info := locals .metadata "info"
  let item := locals .routine "item"
  let first := calls.skipAt text frame.position
  let last := calls.nameAfter text first
  let updated := ((locals.set .number "before" frame.position).set .number "first" first).set .number "last" last
  if (formalIndices item).any (fun index => calls.sameName text ⟨first, last⟩ (info.parameterAt index).bodyName) then
    failed updated
  else
    let object := calls.objectAt text frame info true
    let updated := updated.set .objectResult "object" object
    if object.frame.position ≤ frame.position then failed updated
    else
      let reads := PackageBindings.stateUnion (locals .stateSet "reads")
        (calls.stateReads text (calls.contextOf ⟨object.frame, false, false⟩) info object.initFirst object.initAfter)
      ⟨(updated.set .stateSet "reads" reads).set .state "frame" object.frame, false⟩

def appendStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let formal := (locals .metadata "info").parameterAt (locals .number "i")
  let updated := locals.set .formal "formal" formal
  if formal.mode = .output then
    if !calls.validName (locals .source "text") formal.bodyName then failed updated
    else
      let mark : ApplicationPackageNames.PackageTypeResult :=
        ⟨formal.bodyTypeName, formal.bodyTypeName.after, formal.kind, formal.bounds, formal.typeIdentity⟩
      let frame := calls.appendFormal (locals .state "frame") formal.bodyName mark formal.mode
      let updated := (updated.set .packageType "mark" mark).set .state "frame" frame
      if frame.position = 0 then failed updated else ⟨updated, false⟩
  else ⟨updated, false⟩

theorem formalRange (first count : Nat) (positive : 0 < count) :
    first + count - 1 + 1 - first = count := by omega

local macro "reduce_completion_local" : tactic => `(tactic|
  (dsimp only [localLoop, localStep, fail, failed, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Primitive.eval,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get,
    modelFunctions, modelProcedures, Locals.set, text, frame, info, item, object,
    formalFirst, formalCount, formalLast, position, skip, after, same, union, reads, contextOf]
   simp_all [-List.any_eq_true, -List.any_eq_false, formalIndices, Function.comp_def]))

theorem localLoop_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    localLoop.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some (localStep calls locals) := by
  by_cases positive : 0 < (locals .routine "item").count
  · have range := formalRange (locals .routine "item").formalFirst (locals .routine "item").count positive
    by_cases collision : (formalIndices (locals .routine "item")).any (fun index =>
        calls.sameName (locals .source "text")
          ⟨calls.skipAt (locals .source "text") (locals .state "frame").position,
            calls.nameAfter (locals .source "text") (calls.skipAt (locals .source "text") (locals .state "frame").position)⟩
          ((locals .metadata "info").parameterAt index).bodyName) = true
    · reduce_completion_local
    · by_cases stalled :
        (calls.objectAt (locals .source "text") (locals .state "frame") (locals .metadata "info") true).frame.position ≤
          (locals .state "frame").position
      · reduce_completion_local
      · reduce_completion_local
        have advances : ¬(calls.objectAt (locals .source "text") (locals .state "frame")
          (locals .metadata "info") true).frame.position ≤ (locals .state "frame").position := by omega
        simp [advances]
  · have count : (locals .routine "item").count = 0 := by omega
    by_cases stalled :
      (calls.objectAt (locals .source "text") (locals .state "frame") (locals .metadata "info") true).frame.position ≤
        (locals .state "frame").position
    · reduce_completion_local
    · reduce_completion_local
      have advances : ¬(calls.objectAt (locals .source "text") (locals .state "frame")
        (locals .metadata "info") true).frame.position ≤ (locals .state "frame").position := by omega
      simp [advances]

local macro "reduce_completion_append" : tactic => `(tactic|
  (dsimp only [outputAppend, appendStep, fail, failed, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Primitive.eval,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get,
    modelFunctions, modelProcedures, Locals.set, text, frame, info, formal, position, output, validFormal]
   simp_all))

theorem outputAppend_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    outputAppend.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some (appendStep calls locals) := by
  by_cases outputMode : ((locals .metadata "info").parameterAt (locals .number "i")).mode = .output
  · cases valid : calls.validName (locals .source "text")
      ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
    · reduce_completion_append
    · by_cases rejected :
        (calls.appendFormal (locals .state "frame")
          ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
          ⟨((locals .metadata "info").parameterAt (locals .number "i")).bodyTypeName,
            ((locals .metadata "info").parameterAt (locals .number "i")).bodyTypeName.after,
            ((locals .metadata "info").parameterAt (locals .number "i")).kind,
            ((locals .metadata "info").parameterAt (locals .number "i")).bounds,
            ((locals .metadata "info").parameterAt (locals .number "i")).typeIdentity⟩
          ((locals .metadata "info").parameterAt (locals .number "i")).mode).position = 0
      · reduce_completion_append
      · reduce_completion_append
  · reduce_completion_append

end Silver.ApplicationPackageCompletion.Native
