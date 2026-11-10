# Focused native parser repairs — 2026-11-10

Parser repair `8108347e75` integrates native author commit `0d3d93ac25` into
#370. The final `src/silver_output_profile.adb` SHA-256 is
`735f4bbb8cd0f9ecf816e17df3242113417f9ddeeafdf4bcb8ae2ecc25d41758`.
This packet records **687 proved checks and 43 flow checks across 22 distinct
complete entities**, aggregated from the retained focused gates below. It is
not a single whole-source success, clean rerun or complete assurance checkpoint.
The [capability record](../../../scalar-procedures.md) retains that distinction.

The native author and independent source reviewers selected Astra Max. This
evidence-recording role selected Sol High; live runtime model/effort and usage
telemetry were not independently exposed. This packet's editor ran no compiler,
prover, application, regression or managed proof job.

## Repair and focused outcomes

The repairs preserve executable behavior, raw-model contracts and full declared
domains. Parser-state equality now also exports its existing logical premise,
with proved bridges at all Boolean-array returns. `Body_Of` exports the complete
initial-flow facts instead of reconstructing them through a caller assertion.
`Join_Into` exports its component facts and `Lemma_Join_Identity` derives the
raw/logical join equality; the same checked bridge covers both short-circuit
branches. Complete metadata-append lemmas retain arbitrary inactive slots and
empty old signature lists. The last change relocates the existing static
procedure-metadata call immediately before the successful return, with identical
arguments and unchanged runtime statements, guards and helper contracts.

| Managed run | Exact parser input | Result and retained scope |
| --- | --- | --- |
| `20261110T143914-1c2a2b56bc13` | `aa1f3722bedf706e3aa7906e418d68ef5087570bd2b3522c17f5bc2d9072a453` | Passed, 751.032 s; nine complete helpers/dependencies, 227 proof and 15 flow checks. |
| `20261110T145720-331c1a61ff8d` | Same `aa1f3722` | Failed, 4,562.169 s; 397/400 proof and 20/20 flow. Four complete callers passed; the two metadata posts and the other short-circuit join remained unresolved. |
| `20261110T161846-7016360b9ba9` | `ffdc4fa654056aae2c1b4d59fd1bb2b2dfae0077895158b91a1634d34ca63137` | Passed, 264.457 s; six complete metadata helpers/dependencies, 45 proof and eight flow. |
| `20261110T162446-2d6a4b3e4d0d` | Same `ffdc4fa6` | Failed, 4,173.129 s; Function_Body_At 28/28 and Read_Chain_Into 222/222 proof passed. Procedure_Body_At retained two failures; all eight flow checks passed. |
| `20261110T173934-c9e374d30353` | Final `735f4bbb` | Passed at 17:50:04 UTC, 629.796 s; complete Procedure_Body_At, 28 proof and two flow checks, including both prior residuals. |

All five gates ran on Linux x86_64 with 22 managed workers and requested the
canonical compiler logical policy: all flow/proof, all reports, warnings/checks
as errors, level 2, CVC5/Z3/Alt-Ergo and timeout 30 seconds. Unit/line selectors
cover complete entities. Normal warm sessions were reused; these command and
report observations do not assert that every successful solver attempt was
freshly executed at that limit. Wrapper elapsed times are per-run observations,
not solver-only timings, total team cost or controlled speedup measurements.

The aggregate retains the nine first helpers, four complete successful callers
from the failed `145720` gate, six metadata helpers, successful function/chain
callers from failed `162446`, and the final complete procedure result. The
[continuity map](retained-success-continuity.json) names each entity, covering
run, exact old/current source fragments and unchanged dependency-file hashes.
The failed broader runs stay failed. Byte-identical selected fragments justify
the stated focused continuity; they do not replace final whole-input provenance.

Every selected entity is in `all` mode. The native audits retain every previous
selected check and empty skip/assume lists. The final procedure gate preserves
all 28 proof and two flow identities, including its relocated call mapping.
The 90 prior warning records remain after exact line mapping; four new spelling
advisories satisfy the existing strict operator-reassociation classifier and
source-origin checks. No warning-policy exception or safety waiver was added.

## Failed lineage, reviews and retained evidence

The earlier step-budget trial `093356-8e860ccf93b3` failed on 14 of 301 proof
checks across three helpers (all eight flow checks passed). The canonical
equality-helper `124550` passed, but its `125615` direct-caller gate and named
return trial `131635-d495beb427bd` remained failed on the Boolean raw-model
postcondition. The latter passed 58/59 proof and both flow checks. Their reports,
commands, input maps and session-limit observations remain in the archive.
Warm earlier sessions contain both retained step-budget and new 30-second
attempts; a requested canonical command is not a claim of a cold policy replay.

Three partial selector diagnostics did not select the raw leaf. The separate
custom export `143601-fa03fb3247ae` exited zero but reported a false obligation
result and an unrecognized one-step solver answer: it was not proof success.
Its full raw diagnostic packet remains in the native worktree beside the
complete-parser candidate at `../raw-model-direct-diagnostic/`. The final
placement succeeded without identifying a unique cause of earlier timeouts.

The archive retains the source owner's bounded full-domain reviews of component
exports, early-return bridges, metadata append, branch symmetry and call
relocation. Their draft and review statuses remain dated provenance; they are
neither new proof results nor final independent feature acceptance.

[evidence.tar.gz](evidence.tar.gz) contains original summaries, commands/exits,
whole-entity selectors, full `.spark`/SARIF/text reports, source/configuration
inputs, managed events, warning/identity mappings and bounded review records.
[input-map.json](input-map.json) records every archive member's original path,
size and SHA-256. Original full manifests are retained inside the archive;
large Why3 AST/session trees remain in the original packets and were not copied.
The original five packets contain 194/186/171/166/156 files respectively.

[verification.json](verification.json) records the evidence editor's read-only
check of all five original manifests, raw selected entity counts/modes and
every continuity fragment/dependency against the integrated final bytes.
It adds no proof or independent semantic-review claim. `SHA256SUMS` covers the
published packet files.

Original packets and ledger remain preserved under native worktree
`tmp/scalar-procedures-native-370/tmp/procedure-probes/parser-production-20261110/`
`parser-equality-export-canonical/complete-parser-candidate/`. Complete current
native report/provenance auditing, actual-source/parser certificate integration,
complete Lean/module/axiom assurance, final regressions and independent delivery
acceptance remain required. No capability support or issue closure is claimed.

## Subsequent focused source handoff — 18:12 UTC

[source-handoff.tar.gz](source-handoff.tar.gz) retains the bounded source-owner
handoff and focused model/header records from semantic worktree
`tmp/final-source-integration-20261110/`, without copying any proof cache.
`180634-ee26708d1474` remains failed on two exact rendering controls; importing
the established `Init.Data.Repr` definitions fixes their reduction without
changing any proposition or domain. Its exact failure inputs/logs are retained.

`20261110T180854-2aee6adef6a2` passed ProcedureDeclarationModelSource and
ComposeArrayDeclarationSource on Linux x86_64, Lean 4.34.1, with 22 workers and
22 threads per process. The fresh focused audit covered 59,461 declarations and
490 actual project modules, using only the three allowed foundations. Build and
audit took 164.793 s and 9.378 s. The source owner's post-success recheck records
1,101 matching captured input hashes. The editor verified the retained log and
evidence hashes; this does not independently rerun that input check or proof.
The 994-module static reachability inventory is a separate claim, not a complete
actual-import audit. Output shape/certificate closure is excluded from this
focused gate; final whole-source certificates and assurance remain pending.
The lead integrated the proof batch as `bfe82aeb81`; complete native run
`181302-a4553e500d15` and the eight changed certificate chunks were starting at
that handoff, without a completed result. No final regression/review claim follows.
