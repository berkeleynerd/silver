module

public import Silver.ApplicationPackageCallsActualProjection

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

def declared (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Locals :=
  callBody.declarations.foldl (Declaration.eval (imported calls)) locals

/-- Only initializers present in the source supply values here. The raw
actual and seen arrays have the full physical extent even when no formals
are active. Callee, failure and reference are read before any branch. -/
theorem declared_values (calls : ApplicationPackageCalls.Calls) (locals : Locals) :
    let start := declared calls locals
    start .number "callee" = packageCallee calls (locals .source "text") (locals .parseContext "context")
       (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") ∧
    start .appCall "failure" = ApplicationPackageCalls.failure (locals .appScan "input") ∧
    start .reference "reference" = calls.reference (locals .source "text") (locals .number "position") ∧
    start .appCall "result" = {result := locals .appScan "input"} ∧
    start .packageActuals "actuals" = List.replicate PackageBindings.maxFormals {} ∧
    start .packageSeen "seen" = List.replicate PackageBindings.maxFormals false ∧
    start .truth "named" = false := by
  dsimp only [declared, callBody, List.foldl_cons, List.foldl_nil, Declaration.eval, Declaration.names,
    Expr.eval, Property.get, imported, call1, call2, call3, call4, call5, text, context, input,
    info, position, kind, ApplicationPackageCalls.failure]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, and_self]

theorem declared_inputs (calls : ApplicationPackageCalls.Calls) (locals : Locals) :
    let start := declared calls locals
    start .source "text" = locals .source "text" ∧ start .parseContext "context" = locals .parseContext "context" ∧
    start .appScan "input" = locals .appScan "input" ∧ start .metadata "info" = locals .metadata "info" ∧
    start .number "position" = locals .number "position" ∧ start .routineKind "kind" = locals .routineKind "kind" := by
  dsimp only [declared, callBody, List.foldl_cons, List.foldl_nil, Declaration.eval, Declaration.names]
  simp (disch := decide) only [Locals.set_get_other, and_self]

end Silver.ApplicationPackageCalls.Native.Call
