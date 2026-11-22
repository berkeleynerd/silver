module

public import Silver.ApplicationPackageUnitNative
public import Silver.ApplicationPackageProcedureLoops

@[expose] public section

namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def objectStep (calls : UnitCalls) (locals : Locals) : Outcome :=
  let info := locals .metadata "info"
  let globals := locals .state "globals"
  if info.states.length = PackageBindings.maxStates then ⟨locals, true⟩
  else
    let object := calls.objectAt (locals .source "text") globals info false
    let updated := (locals.set .number "before" globals.position).set .objectResult "object" object
    if object.frame.position ≤ globals.position ∨ object.constantObject = true then ⟨updated, true⟩
    else
      let updated := updated.set .metadata "info" (grownMetadata info (stateDeclaration object))
      ⟨updated.set .state "globals" object.frame, false⟩

def routineStep (calls : UnitCalls) (locals : Locals) : Outcome :=
  let globals := locals .state "globals"
  let result := calls.completionAt (locals .source "text") globals (locals .metadata "info")
  let updated := ((locals.set .number "before" globals.position).set .state "globals" result.globals).set
    .metadata "info" result.info
  ⟨updated, decide (result.globals.position ≤ globals.position)⟩

local macro "reduce_unit_object" : tactic => `(tactic|
  (dsimp only [objectLoopBody, objectStep, ApplicationPackageProcedure.Command.list, List.foldr,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Primitive.eval, grownMetadata,
    declarationValue, stateDeclaration, modelFunctions, modelProcedures, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, Locals.set, text, globals, info, object, position]
   simp_all))

theorem objectLoopBody_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    objectLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some (objectStep calls locals) := by
  by_cases full : (locals .metadata "info").states.length = PackageBindings.maxStates
  · reduce_unit_object
  · by_cases rejected :
      (calls.objectAt (locals .source "text") (locals .state "globals") (locals .metadata "info") false).frame.position ≤
          (locals .state "globals").position ∨
      (calls.objectAt (locals .source "text") (locals .state "globals") (locals .metadata "info") false).constantObject = true
    · reduce_unit_object
    · reduce_unit_object
      have advances : ¬ (calls.objectAt (locals .source "text") (locals .state "globals")
          (locals .metadata "info") false).frame.position ≤ (locals .state "globals").position := by omega
      simp [advances]

theorem routineLoopBody_meaning (calls : UnitCalls) (fuel : Nat) (locals : Locals) :
    routineLoopBody.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some (routineStep calls locals) := by
  by_cases stalled :
    (calls.completionAt (locals .source "text") (locals .state "globals") (locals .metadata "info")).globals.position ≤
      (locals .state "globals").position
  all_goals
    dsimp only [routineLoopBody, routineStep, ApplicationPackageProcedure.Command.list, List.foldr,
      ApplicationPackageProcedure.Command.eval, Outcome.bind, Primitive.eval,
      modelFunctions, modelProcedures, Place.set, Place.expression,
      Expr.eval, Field.get, Field.set, Locals.set, text, globals, info, object, position]
    simp_all
  all_goals
    have advances : ¬ (calls.completionAt (locals .source "text") (locals .state "globals")
        (locals .metadata "info")).globals.position ≤ (locals .state "globals").position := by omega
    simp [advances]

end Silver.ApplicationPackageUnit.Native
