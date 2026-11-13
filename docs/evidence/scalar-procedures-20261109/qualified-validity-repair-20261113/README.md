# Qualified validity alias repair — focused acceptance, 2026-11-13

This packet records the repair of [#390](https://github.com/berkeleynerd/silver/issues/390)
inside the #370 / PR #371 delivery. Complete native and Lean/source validation,
final regression coverage and delivery acceptance remain required. The earlier
[finding and interrupted checkpoints](../qualified-validity-390-20261113/README.md)
retain their original outcomes.

## Implementation and review

Native author commit `7c98a02f3a` is integrated as `c1bbdc8e5f`.
Nine added lines recognize the qualified validity selector after a nonrange dot
during the actual-expression alias scan. Real variable reads, literal and
attribute handling, and both dots in a contiguous range remain checked.
Preconditions, postconditions and declared domains are unchanged. The final
parser SHA-256 is
`619f4fb8e2b0f318dac7c6278d5f644198816ce7733959ed71ca03917546b2b8`.

Proof author commit `623a3ce1d4` is integrated as `51371ef82f`.
It mirrors the branch in the scanner model and checked native tree, preserves
full-domain raw helper interpretation, proves qualified-query admission despite
the colliding local spelling, and preserves rejection of genuine bare/range
aliases. The reviewed pin changes by the same 65-token insertion as the parser.
The [independent repair review](../../../reviews/review-scalar-procedures-qualified-validity-390.md)
found no additional static blocker in this bounded repair. Its recorded handoff
preceded the successful final source-shape gate below; its pending validation
statements are historical, not rewritten reviewer conclusions.

## Successful focused checks

All runs used native Linux x86-64. Times and scopes are retained separately;
incremental checks do not claim a clean build or independent kernel replay.

| Managed run | Scope and actual result |
| --- | --- |
| `20261113T114106-f670a38c8f83` | Twenty complete native helpers/callers: 274 proof and 50 selected flow checks passed; all 494 whole-unit flow records passed. Canonical all/level-2/30-second CVC5, Z3 and Alt-Ergo configuration, 11 workers, 1,002.546 managed seconds. |
| `20261113T115847-e8f3df6741c0` | Complete scanner/model/caller focused Lean check: 156 imported modules and 16,839 declarations passed the fresh audit, using only the three approved foundations. Twenty workers, 22 threads, 76.184 recorded seconds. |
| `20261113T115822-82e3985a07a9` | Ordinary compiler build passed on the repaired parser. |
| `20261113T115938-18cbc675c0be` | Four admission methods passed: qualified collisions, real aliases including String-slice upper bounds, literal preservation and type-name hiding. |
| `20261113T120228-1c2d0b4be837` | The changed array/argument composition fixture passed actual proof, compilation and execution, including the colliding local name. |
| `20261113T120538-fed77dcce3b5` | Source-candidate and actual-alias focused check passed: 169 imported modules, 16,895 declarations, only `propext`, `Classical.choice` and `Quot.sound`. Twenty-two workers/threads, 503.752-second build, 7.360-second audit, 544.014 recorded total seconds. This excludes the complete output-source certificate. |

The source author's unsuccessful local proof attempts remain failed in the
retained logs. Their repairs changed proof reductions, not theorem domains or
native contracts. No failed/interrupted complete run is relabelled successful.
The final regression inventory contains 691 unittest identities. Nine methods
also execute under a second shared-bindings module identity; the count is not
a claim of 691 unique method implementations. No final full-suite result exists
at this checkpoint.

## Complete checkpoint and resources

Complete native run `20261113T121730-28547dbc0d87` has started on the frozen
repair inputs, using 14 of the host's 22 managed workers. It preserves native
sessions and cache. Lean uses the remaining worker allocation and the default
22 threads per process in its separate existing workspace.

The source checkpoint uses two stages: `Silver.OutputBodyCertificate`, started
as `20261113T122134-87078e539c6a`, and then one ordinary complete project
build/fresh audit. Lake builds affected chunks as
dependencies of the first stage. The separate aggregate stage avoids overlapping
its previously observed 30.56 GiB peak with broad source-candidate builds.
Already successful helper checks need no additional broad focused audit before
the complete checkpoint. No clean build, cache deletion or optional replay is
selected. The full regression/sample suite follows release of proof reservations,
because application compilation itself uses all available native workers.

## Retention and ownership

The archives retain native focused reports and selectors, the independent
review and exact reviewed snapshots, regression sources/results, and the source
author's focused evidence. `retained-files.json` identifies their bytes.
Large generated validation caches remain in their original workspaces; their
existence is not a completed assurance claim.

Repair authors and critical reviewer selected GPT-6 Astra / Max. Routine final
native/source monitoring and regression inventory selected GPT-6.1 Sol / High.
Runtime model/effort and cost telemetry are not independently exposed. Root
owns integration, publication, regression execution and final delivery records.
The separate worca/#373 streams remain outside this continuation. No CLI memory
update or unattended hourly schedule is claimed.
