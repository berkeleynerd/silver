module

public import Silver.ApplicationPackageCallsActualProjection

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

def withActualFrame (inputs : AliasInputs) (frame : ActualFrame) : AliasInputs :=
  {inputs with actuals := frame.actuals, cursor := frame.cursor, callWrites := frame.callWrites}

/-- The lexical and call inputs used after actual scanning remain those of
the entry store. Actual storage, the current cursor and the accumulated write
set travel with each successful stage. -/
def preservedInputs (before after : Locals) : Prop :=
  aliasInputs after = withActualFrame (aliasInputs before) (frameOf after) ∧
    after .number "ordinal" = before .number "ordinal"

theorem preservedInputs.trans {start middle finish : Locals}
    (first : preservedInputs start middle) (second : preservedInputs middle finish) :
    preservedInputs start finish := by
  constructor
  · rw [second.1, first.1]
    rfl
  · exact second.2.trans first.2

theorem association_preserves {calls : ApplicationPackageCalls.Calls} {locals after : Locals}
    (found : associationLocals calls locals = some after) :
    preservedInputs locals after ∧
      frameOf after = {(frameOf locals) with cursor := after .number "cursor_at", named := after .truth "named"} := by
  dsimp only [associationLocals] at found
  split at found
  · cases found
    simp [preservedInputs, withActualFrame, aliasInputs, frameOf, Locals.set]
  · split at found
    · contradiction
    · cases found
      simp [preservedInputs, withActualFrame, aliasInputs, frameOf, Locals.set]

theorem payload_preserves {calls : ApplicationPackageCalls.Calls} {locals after : Locals}
    (found : payloadLocals calls locals = some after) :
    preservedInputs locals after ∧ after .number "slot" = locals .number "slot" ∧
      (after .packageActuals "actuals").length = (locals .packageActuals "actuals").length := by
  dsimp only [payloadLocals] at found
  split at found
  · contradiction
  · split at found
    · split at found
      · contradiction
      · cases found
        simp [preservedInputs, withActualFrame, aliasInputs, frameOf, writeActual, Locals.set]
    · split at found
      · contradiction
      · cases found
        simp [preservedInputs, withActualFrame, aliasInputs, frameOf, writeActual, Locals.set]

theorem finish_preserves {calls : ApplicationPackageCalls.Calls} {locals after : Locals}
    (found : finishActualLocals calls locals = some after) :
    preservedInputs locals after ∧
      (after .packageActuals "actuals").length = (locals .packageActuals "actuals").length := by
  by_cases failed : calls.take (locals .source "text") (locals .number "following")
      (if locals .number "ordinal" = (locals .routine "item").count
       then .symbol ")" else .symbol ",") = 0
  · simp only [finishActualLocals, failed, ↓reduceIte, reduceCtorEq] at found
  · simp only [finishActualLocals, failed, ↓reduceIte, Option.some.injEq] at found
    subst after
    repeat' (split <;> try simp (disch := decide)
      [*, preservedInputs, withActualFrame, aliasInputs, frameOf, writeActual, Locals.set])

end Silver.ApplicationPackageCalls.Native.Call
