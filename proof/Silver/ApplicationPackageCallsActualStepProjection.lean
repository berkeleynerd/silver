module

public import Silver.ApplicationPackageCallsActualStep
public import Silver.ApplicationPackageCallsActualStability

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

private theorem slot_of_payload {calls : ApplicationPackageCalls.Calls} {before after : Locals}
    (found : payloadLocals calls before = some after) : before .number "slot" ≠ 0 := by
  intro zero
  simp only [payloadLocals, zero, true_or, ↓reduceIte, reduceCtorEq] at found

/-- Compose the three projections on the actual native entry domain. A slot
comes either from the guarded named window or from this iteration's ordinal. -/
theorem actualLocals_projection (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (positive : 0 < (locals .routine "item").count)
    (window : ActualWindow (locals .routine "item") (frameOf locals).actuals.length)
    (ordinalIn : locals .number "ordinal" ≤ (locals .routine "item").count) :
    (actualLocals calls locals).map frameOf =
      actualStep calls (locals .source "text") (locals .parseContext "context")
        (locals .appScan "input") (locals .metadata "info") (locals .routine "item")
        (locals .number "ordinal") (frameOf locals) := by
  rw [← normalizedActualStep_meaning _ _ _ _ _ _ _ _ window ordinalIn]
  have chosen := association_projection calls locals positive
  cases association : associationLocals calls locals with
  | none =>
    rw [association] at chosen
    simp only [actualLocals, association, Option.bind_eq_bind, Option.bind_none, Option.map_none,
      normalizedActualStep, ← chosen]
  | some associated =>
    rw [association] at chosen
    have selected :
        selectedAssociation calls (locals .source "text") (locals .metadata "info")
          (locals .routine "item") (locals .number "ordinal") (frameOf locals) =
          some (selectedFields associated) := chosen.symm
    have selection := association_preserves association
    have bounded : associated .number "slot" ≤ (frameOf locals).actuals.length :=
      selected_slot_bound window ordinalIn selected
    have fit : associated .number "slot" ≤ (associated .packageActuals "actuals").length := by
      change associated .number "slot" ≤ (frameOf associated).actuals.length
      rw [selection.2]
      exact bounded
    have payload := payload_projection calls associated fit
    change (payloadLocals calls associated).map payloadView =
      payloadModel calls (aliasInputs associated).text (aliasInputs associated).context
        (aliasInputs associated).input (aliasInputs associated).info
        (associated .number "slot") (frameOf associated) at payload
    rw [selection.1.1, selection.2] at payload
    dsimp only [withActualFrame, aliasInputs] at payload
    simp only [actualLocals, association, Option.bind_eq_bind, Option.bind_some,
      normalizedActualStep, selected, processSelection, selectedFields]
    cases read : payloadLocals calls associated with
    | none =>
      rw [read] at payload
      simp only [Option.bind_none, Option.map_none, ← payload]
    | some loaded =>
      rw [read] at payload
      have stored := payload_preserves read
      have slotPositive := slot_of_payload read
      have inside : loaded .number "slot" - 1 < (loaded .packageActuals "actuals").length := by
        rw [stored.2.1, stored.2.2]
        exact actual_offset_lt_length slotPositive fit
      have finished := finish_projection calls loaded inside
      change (finishActualLocals calls loaded).map frameOf =
        finishModel calls (aliasInputs loaded).text (aliasInputs loaded).context (aliasInputs loaded).info
          (aliasInputs loaded).item (loaded .number "ordinal") (payloadView loaded) at finished
      have same := selection.1.trans stored.1
      rw [same.1, same.2] at finished
      dsimp only [withActualFrame, aliasInputs] at finished
      simp only [Option.bind_some, ← payload, Option.map_some]
      exact finished

end Silver.ApplicationPackageCalls.Native.Call
