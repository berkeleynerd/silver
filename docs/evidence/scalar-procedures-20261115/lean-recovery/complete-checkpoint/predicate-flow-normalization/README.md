# Predicate flow source recovery — 2026-11-15

## Complete-run failure and exact field diagnosis

Complete continuation `20261115T201746-8829535d867a` ran on reviewed production
`88e3d0a9f` (integration `33a7c351f`). Procedure whole-source helpers, the character
source candidate (50 s) and scalar-body source candidate (227 s) completed.
`PredicateFlowSourceCandidate` then failed in three grouped constructor proofs:
`counted_bound_checked` at line 36, `native_flow_checked` at line 39, and
`native_readers_checked` at line 42. Each reported explicit kernel memory
exhaustion at the unchanged 8,192-MiB threshold. The module elapsed 309 s.

The first-diagnostic source guard interrupted the subsequent
`PredicateNativeHelpersCandidate`. Original session `76081` returned outer
launcher exit 254; the monitored child returned -2 after source-only SIGINT.
Managed build elapsed 715.711 s; monitor elapsed 725.714 s. No complete audit
occurred. Process peak was 8,401,840 KiB RSS, tree peak 9,443,488 KiB, and minimum
host availability 6,535,664 KiB. Neither the 10-GiB tree nor 1.5-GiB headroom guard
caused the stop. Exact log SHA-256 is
`f6b4e7dc6f722ab09405de6272b3b58e1750ab31c062b36f7918ea93c4b2037c`.

All 1,112 prior captured input hashes and both tool hashes matched before the
probe. All **656** ordinary objects and 3,932 captured variant/hash files were
inventoried and preserved. The complete failure packet includes original source,
managed/outer logs, resource samples, terminal summary and managed events.

A failed constructor does not identify which field failed. The parent authorized
one temporary `PredicateFlowFieldProbe` retaining every original proposition:
four counted-bound fields, eight native-flow fields and five reader fields,
independently checked in their original namespaces against the same complete
`SourceShape.bodyTokens`. Its exact source and 17-field mapping are retained here;
the temporary source was removed from `proof/` before the production repair.

Probe `20261115T203335-d0861ad752c6` reported exactly these isolated failures:

| Field | Probe location | Outcome |
| --- | --- | --- |
| `CountedBoundNative.Checked.spec` | line 29 | Kernel-memory failure |
| `FlowSourceBridge.Checked.joined` | line 42 | Kernel-memory failure |
| The five `FlowReaders.Checked` fields | Individually retained declarations | No field diagnostic; the failed module is not an audited success |

The other counted-bound/flow fields also produced no diagnostic, without being
claimed as audited successes. Probe session `99284` naturally returned exit 1
and was **not interrupted**. Build elapsed 190.362 s; monitor elapsed 200.178 s.
Peak process/tree RSS was 8,392,816 / 9,569,776 KiB; minimum host availability was
5,725,936 KiB. Exact managed probe log SHA-256 is
`dca7f923ba8d85378a2551e1b935bbf9429590320423d9bf084237af4660931a`.
No isolated reader-field failure is inferred from the original grouped error.

## Bounded repair and complete focused gate

The parent authorized only `PredicateFlowSourceCandidate.lean` and the new
`PredicateFlowExpectedTokens.lean`. Two exact literal fragments inside the
confirmed failing fields receive the established checked character/lexer
normalization:

| Confirmed field | Normalized literal fragment | Characters / tokens |
| --- | --- | ---: |
| Counted-bound specification | Exact specification suffix after the original header | 601 / 130 |
| Joined-flow header | Exact long postcondition fragment after `joinedValue.render` | 776 / 226 |

The counted-bound header remains the original `CountedBoundNative.header`.
Joined-flow count, path and interval semantic renderings, other literal fragments,
concatenation order and closing tokens remain unchanged. Every normalized fragment
is first connected to its exact characters by checked `String.toList_ofList`,
then checked through the unchanged alphabet/fuel/lexer path. Each original full
source-selector equality remains kernel checked. No definition, native contract,
input domain, source pin, semantic tree or source extraction check changes.

The five reader propositions become private `decide +kernel` lemmas, and the
unchanged `native_readers_checked` statement assembles them. This tests proof
aggregation as the cause of its grouped resource failure; it does not normalize
an unfailed reader literal or claim a completed isolated reader audit. The full
candidate gate must establish all five fields and their original caller together.
All original candidate theorem statements and the public `checked` assembly
remain unchanged; Boolean-binding and xor proofs are byte-identical.

The required focused target is the entire `Silver.PredicateFlowSourceCandidate`,
covering both new normalization helpers, all private reader fields, the affected
constructors and every original candidate field. Use one worker, automatic twelve
Lean threads and 8,192 MiB, with existing 10-GiB tree / 1.5-GiB host / first-memory-
diagnostic guards. The 15.8-GiB host still runs the productive native two-worker
checkpoint. Full focused success and independent critical review precede another
complete cached attempt. No clean build, replay or speculative wider repair.

| Work | Model / effort | Result and remaining work | Available cost evidence |
| --- | --- | --- | --- |
| Exact field diagnosis and bounded representation repair | Selected Astra Max; live lead setting not independently exposed | Two isolated failures confirmed; reader aggregation is a focused hypothesis; complete candidate and critical review pending | Complete failure 725.714 s, field probe 200.178 s monitored elapsed; token and whole-team cost unavailable |
