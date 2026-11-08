# Final native regression evidence for #298

The Linux x86-64 build passed, and independent review now accepts applicable
successful evidence for all 637 required regression IDs on the current inputs.
This combines retained results and passing affected checks as detailed below.
The original complete run remains **failed** history: 635 passes, two timeout
errors and zero skips. Complete native proof/auditing and Lean/source assurance
remain separate mandatory requirements.

| Managed run | Inputs | Result | Managed elapsed |
| --- | --- | --- | --- |
| `20261108T021805-6a448d871b26` | `c437a41d30`, native sources equal `560144172c` | Build passed | 36.250 s |
| `20261108T021923-5ef7f9b81de7` | Same frozen snapshot and newly built private compiler | 637 tests: 635 passed, two errors, zero skips | 8,710.076 s |

Unittest reported 8,701.275 seconds. Its 637 extracted outcomes match the
complete ordered discovery census exactly. The 72-sample manifest test passed,
including its scalar-function sample; it freshly admitted, proved, audited,
built and executed those samples. The scalar-function regression group and
maximum dynamic-expression test also passed. Native Lean tests executed with
the installed pinned tools; none was skipped. These are concrete test results;
complete native proof/auditing and Lean source correspondence remain separate,
mandatory assurance work owned by the delivery coordinator.

## Exact errors and retained records

- `LeanModuleTests.test_output_body_chunks_reuse_objects_across_content_and_occurrence_edits`
  raised `subprocess.TimeoutExpired` after 60 seconds in its **initial** Lake
  build, at `tests/test_lean_modules.py:213`, before its audit or edit variants.
  The command selected `OutputBodyCertificate`, `Independent` and `AxiomAudit`,
  with the fixture's existing one-thread/one-worker settings and 2,048 MiB
  per-process threshold.
- `InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`
  raised `subprocess.TimeoutExpired` after 180 seconds in its outer
  `tests/test_platforms.py PlatformIsolationTests -v` subprocess. Its native and
  Lean external tools are mocked; Python certificate generators run. The
  subsequent direct `PlatformIsolationTests` methods passed in the full run.

The exceptions establish exceeded subprocess deadlines. They do not establish
why those deadlines were exceeded or attribute the failures to contention.
No timeout, production proof setting, exclusion, source or active proof input
was changed during the run. The failed fixture's temporary module directory
was automatically removed by test cleanup; no surviving directory remained
when inspected.

The matching run directories retain complete compressed `events.jsonl` and
`native.log` files with uncompressed hashes. The failed-run directory also has
[exact tracebacks](20261108T021923-5ef7f9b81de7/tracebacks.txt) and a
[result inventory](20261108T021923-5ef7f9b81de7/result.json) containing every
outcome, exact timeout commands and the terminal managed event. The preparatory
and delivery inventories distinguish the old queued inputs from the actual
tested snapshot; [queue history](QUEUE.md) preserves those earlier checkpoints.

## Input and installation applicability

The worktree is `tmp/scalar-functions-298`, branch
`feat/scalar-functions-298-20261107`. It was fast-forwarded to
`c437a41d30dbdbd174773cab1f5d647dc6e7bbf3`, preserving unrelated `tmp/` and all
installation, proof-cache and output artifacts. Runtime/configuration inputs
were unchanged, so bootstrap was not repeated. The private installation was
rebuilt for the reviewed native repairs.

The compiler binary SHA-256 is
`cd6412e50ad7ea77205c5bca82ca38b4eece3b33b9b23c24cb503b15107e1de2`.
The test census retains the compiler and Image adapter identities. Lean 4.34.1,
commit `5045d0056413266e57c625dcd7c365b10e377c52`, was already installed privately
under `.tools/linux-x86_64/lean`; no toolchain copy or writable proof-output
sharing was needed.

Because a failing unittest command raises before the runner's normal
postflight, the complete prepared input map was independently compared after
completion and before any proof synchronization: all 1,031 inputs matched,
with no additions, deletions or byte drift. Compiler, adapter, Lean and Lake
hashes were also unchanged. This binds these results to the recorded native
source/build inputs and installation; it does not claim binary attestation or
replace the coordinator's proof/source-correspondence evidence.

## Resource observations and remaining work

Both commands reserved two managed workers. Application proofs retain the
existing `-j0`, resolving to a 22-worker pool; the ledger reservation is not an
OS or subprocess cap. Two timestamped nested-worker observations record actual
children, sampled CPU, summed RSS and host headroom separately. The later
observation occurred after both fixture errors and cannot explain them. The
delivery lead reviewed headroom and instructed preservation of productive
work without settings changes.

After the full outcome and exact errors were retained, the coordinator
authorized synchronization of exactly six later reviewed proof files from
`2a3badff5c`. Local validation snapshot
`eb27aef3569ac89846f52f94d845c09540974f32` copies those files byte-for-byte;
`proof-sync-input-inventory.json` records their before/after hashes and all
1,023 source/test inputs. It introduces no new proof edits. Native
sources, scripts, tests, samples and toolchains are unchanged by that update.
The first failed fixture copies an unchanged seven-module subset; the second
copies all production proof files and must be rerun on the final proof snapshot.
The two named-method reruns are queued serially with unchanged settings until
the coordinator reports complete Lean release and suitable headroom. No rerun
has started. Final applicability review and passing reruns are outstanding.
The coordinator subsequently reported an additional candidate-only proof
repair; the six-file local snapshot is retained unchanged pending the exact
next governed snapshot.

Selected orchestration settings were GPT-6.1 Sol / High, confirmed from parent
spawn settings. Runtime model identity, model token/cost and total CPU time are
unavailable. The elapsed values above are managed wall times, not model work
or CPU measurements. No harness goal was active in this subthread. No GitHub
write, publication or merge was performed; implementation merge remains held.

## First failed-fixture follow-up, 2026-11-08 05:33 UTC

The coordinator authorized only the unchanged seven-module chunk-reuse fixture
while final proof packaging remained pending. Managed run
`20261108T053156-3a0a42e9d590` **failed**: one test, one error, zero skips,
65.200 seconds in unittest and 73.566 seconds managed elapsed. It reproduced
the 60-second `TimeoutExpired` in the initial Lake build at
`tests/test_lean_modules.py:213`, before any audit or edit variants. No timeout,
thread, memory, test option or harness change was made. No subsequent rerun
was launched. Both original full-suite errors still require passing follow-ups.

The follow-up ran at local snapshot `946944856b`, preserving the six-file
proof sync. All 1,031 managed prepared inputs matched after completion.
The exact seven copied production modules, Lake/toolchain/generator inputs,
test and relevant helpers also match governed snapshot `2a3badff5c` byte-for-byte;
their hashes are in the follow-up [result](20261108T053156-3a0a42e9d590/result.json).
This scope does not cover future proof packaging or the all-production-proof
symlinked-TMPDIR fixture, which remains held for the coordinator's final inventory.

Preflight at 05:31 UTC reported 41 GiB available memory and load averages
19.57 / 20.38 / 21.05. The two-worker reservation coexisted with native twelve
and complete Lean eight-worker reservations on 22 available CPUs. The fixture
itself retained one Lean thread and its existing 2,048 MiB setting. The reservation
does not cap subprocess concurrency. Two read-only process/resource observations
and a partial prepared-workspace inventory/archive are retained beside the
compressed full managed events/log and exact traceback. At 05:33:09, Lake was
defunct and a surviving `Lexical` child had run about ten seconds; all observed
owned processes had exited at postflight. These observations do not establish
the cause of the exceeded deadline.

The workspace snapshot was taken during the initial build, not atomically at
failure. It archives source/configuration/JSON/trace files and inventories
available files; it does not preserve compiled objects or subprocess pipes.
Automatic fixture cleanup removed the workspace before final capture. Standard
unittest exception formatting does not print `TimeoutExpired`'s captured streams.
Uncertain diagnosis was returned to the coordinator without a blind repeat or
independent source/test edit. No harness goal was active; CLI memory was not
updated. Model token/cost and total CPU measurements remain unavailable.

The process samples record elapsed time, lifetime-average CPU percentage and
RSS. They do not measure configuration-only CPU time, CPU tick deltas, I/O
counters or wait states. At 05:32:40, Lake had run 32 seconds and no owned Lean
child appeared; the 05:32:52 workspace snapshot included `lakefile.olean.trace`.
The later child's rounded elapsed time suggests an approximate start, not an
exact execution timestamp. These records are insufficient to distinguish all
configuration, compilation, scheduling and I/O costs.

The smallest proposed next step is coordinator-owned Astra Extra High review
of the retained configuration trace and chronology. If more execution is
needed, separately authorize one isolated configuration-only diagnostic using
a recreated identical fixture, retaining stdout/stderr and monotonic child-start,
CPU-tick, I/O and wait samples. No such diagnostic ran here. Preserve the original
fixture limits and decide any further fixture run from the resulting evidence.

## Subsequent isolated follow-ups, 2026-11-08

The [configuration/import diagnostics](../fixture-diagnostics/README.md) led
to an authenticated local Lean installation and one unchanged full object-reuse
fixture attempt. Run `20261108T064023-1bc9e7d6f89f` still failed the original
60-second initial-build limit before its audit/edit stages. Its exact prepared
inputs, complete installed distribution and postflight input inventory matched;
the failed output and pre-cleanup workspace are retained. Local storage alone
was insufficient. Read-only watchdog assessment remains in progress.

The coordinator synchronized the final 82 proof-file changes to governed
`47fe4003c0` and ran the separate symlink-TMPDIR method once with its original
deadlines and assertions. Run `20261108T064731-9f1ab6dc731c` failed its existing
180-second outer limit, with one error and zero skips. The
[final-input packet](symlink-fixture-47fe4003c0/README.md) retains the actual
outcome and verifies all 1,100 governed files and all 821 Lean file identities
before and after execution. No fixture processes remain. Neither failure
clears the original full suite; both methods still need successful checks and
final applicability review. No further repeat or deadline change has occurred.

The subsequent reviewed test-only watchdog repair gives the larger certificate
fixture's builds 180 seconds while preserving its 60-second audits and every
correctness/proof setting. The [complete repaired run](../fixture-diagnostics/README.md)
`065724-7d260468ca14` passed all eleven edit cases, 25 builds and 12 fresh audits
with no errors/failures/skips or input drift. The object-reuse failure is now
covered by that passing affected check; the original full suite remains failed
history. Four [source-policy methods](source-policy-47fe4003c0/README.md) also
passed on the changed final recursive module graph. The separate platform
fixture remains unresolved after its unchanged local-source attempt exposed
inner errors before the outer timeout; exact diagnosis is pending.

The subsequent single-method diagnostic established a 60-second worker timeout
during real certificate generation. Its retained traceback, unchanged-input
checks and the independently reviewed test-only watchdog repair are recorded
in the [diagnostic packet](../fixture-diagnostics/README.md). Commit `9e89c80f82`
changes both worker waits to 180 seconds and the complete wrapper to 900 seconds,
preserving the barrier, every assertion and all twelve nested methods. One
complete final-input wrapper check is authorized; its actual outcome and the
complete 637-result applicability review remain outstanding.


## Accepted current-input regression composition

The [independent applicability review](../../../reviews/review-scalar-functions-delivery-20261108.md#independent-composition-of-the-final-regression-results)
accepts integration `5aa1509fc5`, with exact production proof/source/script inputs
`47fe4003c0` and native source `560144172c`. It explicitly extends that result
to documentation follow-up `d396db2aeb`. The [18-member evidence bundle](applicability-review/index.json)
retains the complete per-ID matrix, independently extracted raw outcomes,
current AST inventory, shared-helper analysis and exact input/tool comparisons.
Integration independently read and indexed all eighteen members by size and
SHA-256. No additional test execution was performed by that review.

| Applicable successful evidence | Required IDs | Managed run |
| --- | ---: | --- |
| Retained original passes | 619 | `20261108T021923-5ef7f9b81de7` |
| Final source-policy checks | 4 | `20261108T072619-eca79cdaf440` |
| Repaired chunk fixture | 1 | `20261108T065724-7d260468ca14` |
| Platform method bodies through the original wrapper | 12 | `20261108T075522-000e545aebc8` |
| Original platform wrapper | 1 | `20261108T075522-000e545aebc8` |
| Total | 637 | |

All 637 original unique IDs and outcomes match the raw log and current discovery
inventory, including inherited methods and imported aliases. The reviewer
accounts for eighty added Lean files, eight modified Lean files and both test-only
watchdog repairs. All other native sources, scripts, samples, catalogue, projects,
configuration, Lean pin/lakefile/generator and current Rosetta inputs are unchanged.
The original build's 2,588 inputs and compiler, adapter and tool identities still
match. All 72 sample entries and their dependencies retain their original success.

Shared helper defaults, complete recursive proof reads and synthetic fixture
boundaries are explicitly reviewed. Every affected platform method is covered
by the successful complete wrapper on the final 866-file input set, including
all 821 Lean files. This is a fresh symlink-environment execution of those bodies,
not a separate fresh non-symlink run. The chunk fixture exercises its original
small production-module subset and all eleven edits; it does not claim to prove
the full project. Earlier failures remain failed and no correctness assertion
or required proof obligation was waived.

No current regression ID remains uncovered; an identical full-suite repeat is
unnecessary under the repository's reviewed composition rule. The three Rosetta
tests are currently retained because those inputs are unchanged. All three must
run freshly after the later promotion patch. Complete native and Lean/source
assurance, final delivery review and the actual Rosetta reconciliation remain
outstanding.
