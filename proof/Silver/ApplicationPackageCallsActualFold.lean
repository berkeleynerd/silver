module

public import Silver.ApplicationPackageCallsActualInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

theorem finish_failure_preserved {calls : ApplicationPackageCalls.Calls} {locals updated : Locals}
    (accepted : finishActualLocals calls locals = some updated) :
    updated .appCall "failure" = locals .appCall "failure" := by
  by_cases failed : calls.take (locals .source "text") (locals .number "following")
      (if locals .number "ordinal" = (locals .routine "item").count
       then .symbol ")" else .symbol ",") = 0
  · simp only [finishActualLocals, failed, ↓reduceIte, reduceCtorEq] at accepted
  · simp only [finishActualLocals, failed, ↓reduceIte, Option.some.injEq] at accepted
    subst updated
    repeat' (split <;> try simp (disch := decide) [*, writeActual, Locals.set])

theorem actual_failure_preserved {calls : ApplicationPackageCalls.Calls} {locals updated : Locals}
    (accepted : actualLocals calls locals = some updated) :
    updated .appCall "failure" = locals .appCall "failure" := by
  simp only [actualLocals, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
  obtain ⟨associated, association, loaded, payload, finished⟩ := accepted
  exact (finish_failure_preserved finished).trans
    ((payload_failure_preserved payload).trans (association_failure_preserved association))

/-- The native index binding is present during each iteration, including rejected
iterations. Its previous value is restored only on normal loop exit. -/
def parseOrdinal (calls : ApplicationPackageCalls.Calls) (locals : Locals) (index : Nat) : Option Locals :=
  actualLocals calls (locals.set .number "ordinal" index)

theorem actual_values (calls : ApplicationPackageCalls.Calls) (ordinals : List Nat) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    forValues (resultType := .appCall)
      (fun current continuation => actualCommands.eval (resultType := .appCall)
        (imported calls) current continuation) "ordinal" ordinals locals next =
      match ordinals.foldlM (parseOrdinal calls) locals with
      | none => locals .appCall "failure" | some parsed => next parsed := by
  induction ordinals generalizing locals with
  | nil => rfl
  | cons index rest ih =>
      rw [forValues, actual_body_denotation, List.foldlM_cons]
      cases parsed : parseOrdinal calls locals index with
      | none =>
          rw [show actualLocals calls (locals.set .number "ordinal" index) = none from parsed]
          rfl
      | some updated =>
          have step : actualLocals calls (locals.set .number "ordinal" index) = some updated := parsed
          rw [step]
          simp only [Option.bind_eq_bind, Option.bind_some]
          rw [ih]
          cases rest.foldlM (parseOrdinal calls) updated with
          | none => exact (actual_failure_preserved step).trans (by rfl)
          | some => rfl

def actualScan : C := .forRange "ordinal" (.number 1) count actualCommands

theorem actual_scan_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    actualScan.eval (resultType := .appCall) (imported calls) locals next =
      match ((List.range (locals .routine "item").count).map (1 + ·)).foldlM (parseOrdinal calls) locals with
      | none => locals .appCall "failure"
      | some parsed => next (parsed.set .number "ordinal" (locals .number "ordinal")) := by
  change forValues (resultType := .appCall)
    (fun current continuation => actualCommands.eval (resultType := .appCall) (imported calls) current continuation)
    "ordinal" ((List.range ((locals .routine "item").count + 1 - 1)).map (1 + ·)) locals _ = _
  rw [Nat.add_sub_cancel, actual_values]

end Silver.ApplicationPackageCalls.Native.Call
