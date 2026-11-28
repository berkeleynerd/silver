module

public import Silver.PackageCalls
public import Silver.PackageSharedFrames

@[expose] public section

/-! The scalar package-body checker uses completion-order routine signatures
and declared write effects. Both branches and every counted-loop body are
checked even when unreachable. Calls record explicit output formal bounds and
then widen every written visible global to its own declaration domain; no
caller-specific package-state refinement becomes a callee premise.
Main's larger statement grammar is handled by its separate application adapter. -/
namespace Silver.Packages
open Predicate (Flow Statement)

def checkFunctionAssignment (earlier : EffectEnvironment) (analysis : Integer.Analysis)
    (flow : Flow) (booleans : Boolean.Analysis) (update : ScalarFunctions.Assignment) : Option Flow :=
  (checkFunction (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis flow booleans update.call).bind
    fun result => if update.target.check analysis booleans result then some (update.target.after result flow) else none

def checkProcedureCall (earlier : EffectEnvironment) (layout : FrameLayout) (analysis : Integer.Analysis)
    (flow : Flow) (booleans : Boolean.Analysis) (call : ScalarProcedures.Call) : Option Flow :=
  if checkProcedure (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis flow booleans call then
    (resolveProcedure (earlier.map RoutineEffects.signature) call).bind fun resolved =>
      (lookupRoutine earlier call.callee).map fun routine =>
        resetGlobalFlow analysis.declared layout
          (routine.effects.writes ++ globalCells layout (resolved.actuals.outputs.map ScalarProcedures.targetCell))
          (ScalarProcedures.afterTargets (ScalarProcedures.outputTypes resolved.signature.formals)
            resolved.actuals.outputs flow)
  else none

mutual
  def checkPackageStatement (earlier : EffectEnvironment) (layout : FrameLayout) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (statement : Statement) : Option Flow :=
    match statement with
    | .simple .null => some flow
    | .scalarAssign update =>
        if update.check flow.scalars analysis.mutable analysis.declared
        then some {flow with scalars := update.after flow.scalars} else none
    | .booleanAssign update =>
        if booleans.canWrite update.target && update.value.checkBounds Bindings.emptyShape analysis flow booleans
        then some flow else none
    | .callAssign update => checkFunctionAssignment earlier analysis flow booleans update
    | .procedureCall call => checkProcedureCall earlier layout analysis flow booleans call
    | .choice condition yes no =>
        if condition.checkBounds Bindings.emptyShape analysis flow booleans then
          (checkPackageStatements earlier layout analysis (condition.refine Bindings.emptyShape analysis flow true)
            booleans yes).bind fun afterYes =>
          (checkPackageStatements earlier layout analysis (condition.refine Bindings.emptyShape analysis flow false)
            booleans no).map fun afterNo => afterYes.join afterNo
        else none
    | .forLoop index _ lower upper body =>
        (lower.infer flow.scalars).bind fun a => (upper.infer flow.scalars).bind fun b =>
          let bounds := Integer.loopBounds a b
          (checkPackageStatements earlier layout (analysis.withIndex index bounds)
            (Predicate.loopEntry analysis flow index bounds) booleans body).map fun after =>
              Predicate.loopExit analysis flow after a b
    | _ => none
  termination_by sizeOf statement
  def checkPackageStatements (earlier : EffectEnvironment) (layout : FrameLayout) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (statements : List Statement) : Option Flow :=
    match statements with
    | [] => some flow
    | statement :: rest => (checkPackageStatement earlier layout analysis flow booleans statement).bind fun next =>
        checkPackageStatements earlier layout analysis next booleans rest
  termination_by sizeOf statements
end

def functionAssignmentObligations (earlier : EffectEnvironment) (analysis : Integer.Analysis)
    (flow : Flow) (booleans : Boolean.Analysis) (update : ScalarFunctions.Assignment) : List Predicate.Obligation :=
  functionObligations (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis flow booleans update.call ++
    match checkFunction (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis flow booleans update.call with
    | some result => Predicate.targetObligations result update.target
    | none => [.impossible]

theorem functionAssignment_obligations_discharge {earlier : EffectEnvironment} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {update : ScalarFunctions.Assignment}
    (checked : checkFunctionAssignment earlier analysis before booleans update = some after) :
    Predicate.discharged (functionAssignmentObligations earlier analysis before booleans update) = true := by
  simp only [checkFunctionAssignment, Option.bind_eq_some_iff] at checked
  obtain ⟨result, call, target⟩ := checked
  split at target
  · rename_i assignable
    simp only [functionAssignmentObligations, Predicate.discharged_append,
      function_obligations_discharge call, call, Predicate.target_obligations_discharge assignable, Bool.and_self]
  · contradiction

theorem checkProcedureCall_bounds {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {call : ScalarProcedures.Call}
    (checked : checkProcedureCall earlier layout analysis before booleans call = some after) :
    checkProcedure (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis before booleans call = true := by
  simp only [checkProcedureCall] at checked
  split at checked
  · assumption
  · contradiction

mutual
  def packageStatementObligations (earlier : EffectEnvironment) (layout : FrameLayout) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (statement : Statement) : List Predicate.Obligation :=
    match statement with
    | .simple .null => []
    | .scalarAssign update => (update.obligations flow.scalars).map Predicate.Obligation.scalar
    | .booleanAssign update =>
        (if booleans.canWrite update.target then [] else [.impossible]) ++
          update.value.obligations Bindings.emptyShape analysis flow booleans
    | .callAssign update => functionAssignmentObligations earlier analysis flow booleans update
    | .procedureCall call =>
        procedureObligations (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis flow booleans call
    | .choice condition yes no =>
        condition.obligations Bindings.emptyShape analysis flow booleans ++
          packageStatementsObligations earlier layout analysis
            (condition.refine Bindings.emptyShape analysis flow true) booleans yes ++
          packageStatementsObligations earlier layout analysis
            (condition.refine Bindings.emptyShape analysis flow false) booleans no
    | .forLoop index _ lower upper body =>
        (lower.obligations flow.scalars ++ upper.obligations flow.scalars).map Predicate.Obligation.scalar ++
          match lower.infer flow.scalars, upper.infer flow.scalars with
          | some a, some b =>
              packageStatementsObligations earlier layout (analysis.withIndex index (Integer.loopBounds a b))
                (Predicate.loopEntry analysis flow index (Integer.loopBounds a b)) booleans body
          | _, _ => [.impossible]
    | _ => [.impossible]
  termination_by sizeOf statement
  def packageStatementsObligations (earlier : EffectEnvironment) (layout : FrameLayout) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (statements : List Statement) : List Predicate.Obligation :=
    match statements with
    | [] => []
    | statement :: rest => packageStatementObligations earlier layout analysis flow booleans statement ++
        match checkPackageStatement earlier layout analysis flow booleans statement with
        | some next => packageStatementsObligations earlier layout analysis next booleans rest
        | none => [.impossible]
  termination_by sizeOf statements
end

mutual
  theorem package_statement_obligations_discharge {earlier : EffectEnvironment} {layout : FrameLayout}
      {analysis : Integer.Analysis} {before after : Flow} {booleans : Boolean.Analysis} {statement : Statement}
      (checked : checkPackageStatement earlier layout analysis before booleans statement = some after) :
      Predicate.discharged (packageStatementObligations earlier layout analysis before booleans statement) = true := by
    cases statement with
    | simple item =>
        cases item with
        | null => simp only [packageStatementObligations, Predicate.discharged, List.all_nil]
        | assign | output | put =>
            simp only [checkPackageStatement] at checked
            contradiction
    | scalarAssign update =>
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i good
          simpa only [packageStatementObligations, Predicate.scalar_discharged] using update.obligations_discharge good
        · contradiction
    | booleanAssign update =>
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i good
          have both := Bool.and_eq_true_iff.mp good
          simp only [packageStatementObligations, both.1, ↓reduceIte, List.nil_append,
            Predicate.Condition.obligations_exact, both.2]
        · contradiction
    | callAssign update =>
        simp only [checkPackageStatement] at checked
        simpa only [packageStatementObligations] using functionAssignment_obligations_discharge checked
    | procedureCall call =>
        simp only [checkPackageStatement] at checked
        simpa only [packageStatementObligations] using procedure_obligations_discharge (checkProcedureCall_bounds checked)
    | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
        simp only [checkPackageStatement] at checked
        contradiction
    | choice condition yes no =>
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [packageStatementObligations, Predicate.discharged_append,
            Predicate.Condition.obligations_exact, bounded,
            package_statements_obligations_discharge yesChecked,
            package_statements_obligations_discharge noChecked, Bool.and_self]
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [checkPackageStatement, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, low, b, high, bodyAfter, bodyChecked, _⟩ := checked
        simp only [packageStatementObligations, low, high, List.map_append,
          Predicate.discharged_append, Predicate.scalar_discharged,
          Integer.Expr.obligations_discharge low, Integer.Expr.obligations_discharge high,
          package_statements_obligations_discharge bodyChecked, Bool.and_self]
  termination_by sizeOf statement

  theorem package_statements_obligations_discharge {earlier : EffectEnvironment} {layout : FrameLayout}
      {analysis : Integer.Analysis} {before after : Flow} {booleans : Boolean.Analysis} {statements : List Statement}
      (checked : checkPackageStatements earlier layout analysis before booleans statements = some after) :
      Predicate.discharged (packageStatementsObligations earlier layout analysis before booleans statements) = true := by
    cases statements with
    | nil => simp only [packageStatementsObligations, Predicate.discharged, List.all_nil]
    | cons statement rest =>
        simp only [checkPackageStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨next, head, tail⟩ := checked
        simp only [packageStatementsObligations, head, Predicate.discharged_append,
          package_statement_obligations_discharge head, package_statements_obligations_discharge tail, Bool.and_self]
  termination_by sizeOf statements
end

end Silver.Packages
