# Focused Source Checks

Authorized on 2026-10-14 from baseline `8e5ffeb91a`, on Linux x86-64.
Status: complete.

The bounded goal is to remove accidental source-import dependencies that rebuild
expensive checks after unrelated Ada source changes. In particular, path-facts
source changes previously reached `ComposeSourceChecks` through umbrella source
imports. The previous 1,159-second composed-check build is motivating evidence,
not a prediction of savings in this experiment.

Keep every theorem statement, accepted axiom, exact-byte source check and complete
audit requirement. Retain normal Lake invalidation and the existing toolchain,
runner, cache and module interfaces. No language or Oracle change is authorized.

Acceptance: compare a representative unrelated source edit before and after;
verify that a relevant source edit still invalidates its checks; run focused
regressions and one stable complete Lean build with fresh axiom/module auditing.
Retain original caches and distinguish cached checks from independent replay.
Native proofs are reusable if their captured inputs remain unchanged. Broader
interface redesign and new caching infrastructure are outside this milestone.

## Implementation

At the October 14 checkpoint, only import headers changed in six Lean files.
`ComposeSourceChecks` imported the generic declaration readers, output spec/body
certificates and composition equations directly. `ComposeSourceBridge` explicitly
retained the lexical bridge that it previously received transitively. The null,
output and argument bridges named their required certificates; `Silver.lean`
explicitly retained the complete `Source` facade. No declaration, proof body,
source binding, generated certificate, Lake rule, runner or native implementation
changed at that checkpoint.

That checkpoint's project-only import closure of `ComposeSourceChecks` shrank
from 92 modules to 28, and from seventeen source certificates to two. The complete
root and audit retained exactly the same project-module sets. The focused graph
regression required the output certificates/bindings and excluded unrelated
path-facts certificates/bindings without pinning the spelling of the direct
imports. An independent read-only review confirmed unchanged non-import bytes
and retained source links.

## Measurement method

The isolated baseline uses tracked baseline sources and a complete copy of the
warm canonical cache, including private/server sidecars and Lake metadata. The
candidate experiment similarly copies the successfully rebuilt cache. Tools are
the same pinned Lean 4.34.1 binaries; settings are twelve Lake workers, twelve
threads per process and a 16,384 MiB per-process memory threshold. This Linux
environment exposes twelve CPUs and approximately 31 GiB RAM.

Append the same comment to `silver_path_facts.ads`, restoring its original
timestamp. Baseline Lake `--rehash --reconfigure --no-build` rejects the focused
composed-check target because `PathFactsSpecSource` is stale (2.303 seconds).
This is an invalidation observation, not a timed complete baseline rebuild.
Do not repeat the previously observed long rebuild merely to time wasted work;
the earlier 1,159-second result does not establish a matched speedup ratio.

The candidate controls passed:

| Check | Result |
| --- | --- |
| Same path-source edit, composed target with `--no-build` | Cached; 2.098 s. Baseline rejected it as stale. |
| Changed path-facts certificate with `--no-build` | Correctly stale; 2.046 s. |
| Warm composed + path checks, ordinary focused runner | Passed in 7.528 s. |
| Path-source edit, ordinary composed + path checks | Passed in 129.990 s; rebuilt only the path binding, certificate and source checks. |
| Output-body edit, composed target with `--no-build` | Correctly stale at `OutputProfileBodySource`; 2.242 s. |
| Another unrelated path edit, ordinary composed-only check | Passed in 7.326 s, including its fresh focused axiom audit. |

The composed-check and output-certificate `.olean`, `.olean.server` and
`.olean.private` files retain identical hashes and timestamps after the combined
path run. The separate composed-only run also preserves all three composed-check
objects. The initial measurement script accidentally included `.hash` metadata,
whose timestamps Lake refreshes under `--rehash`; correcting that comparison
confirmed actual-object reuse without repeating the long proof run. The original
objects remain in the canonical cache copied into the experiment. All mutation
bytes were confined to the isolated root and restored afterward.

The 904-second composed proof rebuilt during installation is now avoided for
this unrelated edit. The path certificate and semantic source checks still cost
99 and 22 seconds respectively. Genuine changes to the output source or shared
Lean definitions can still require the expensive composed check.

## Validation

The previous native proof evidence remains current: validation of its input,
report and tool identities passed for all 2,408 captured inputs and 22 reports.
This is reuse of the previous full native audit, not a fresh GNATprove run.
The language and runtime are unchanged, so unrelated application tests and dense
capacity compilations are not repeated.

`python3 scripts/dev.py test -- -p 'test_lean*.py'` passed all 62 tests in
158.905 seconds, with no skips. The new graph regression was then taught to
include `public meta import` edges and passed its final focused recheck in
0.062 seconds. Existing native tests cover byte changes with restored timestamps,
stale-source witness rejection, private-axiom detection and kernel-bypass policy.
The broader application suite was not rerun for these import-only changes.

`python3 scripts/check_lean.py --memory-mb 16384` passed the complete Linux
checkpoint in 920.145 seconds: 914.535 seconds building and 3.324 seconds in the
fresh audit. Thirteen modules rebuilt, including the 904-second composed check;
unaffected artifacts, including all seventeen source certificates, stayed cached.
All 252 project modules are covered. The audit inventories 56,748 declarations
with only `propext`, `Classical.choice` and `Quot.sound`; that count is an axiom
audit, not an independent kernel replay. The final input digest was rechecked
against the current proof, source and tooling files after the experiments.

No blocking issue was found in independent review. Independent kernel replay,
macOS validation and hosted CI were not run. Native proof inputs remain unchanged.
Evidence is retained under
`.silver/linux-x86_64/focused-source-checks-20261014T175003Z/`, including complete
and focused runner records, the import graph, actual-object comparisons, the
native-provenance check and control outcomes. `tmp/focused-source-checks-active.json`
locates both the evidence and isolated experiment roots. Preserve those caches,
the corrected probe scripts and the prior records.

## Reviewed-shape composition checks — October 26, 2026

[Development velocity #246](https://github.com/berkeleynerd/silver/issues/246)
separates the 98 composition decisions into `ComposeSourceCandidate`. It depends
on the complete `ReviewedOutputShape` and shared models/readers, with no
transitive authoritative source bindings, certificates or source umbrella.
The five source-dependent predicates accept explicit token lists; their
authoritative names and `actual_*` statements remain in `ComposeSourceChecks`.
A single adapter transports their conjunction through
`Output.SourceBridge.actual_complete_shape`. `TokenMapping` is source-independent,
and its existing `finite_mapping` wrapper remains available.

The authoritative adapter now imports `OutputSourceBridge`, retaining its full
profile, output, lexical and runtime certificate closure. The graph regression
checks candidate isolation and that complete authoritative closure separately;
both closures still exclude unrelated path-facts source bindings/certificates.
`ComposeSourceBridge.CheckedSource` and `checked_source`, the Ada source, reviewed
pins, generator and runner are unchanged. Actual-byte reconstruction, semantic
interpretation and legal call domains remain required, as do the complete
native and Lean module/private/transitive axiom audits.

This implementation does not extend the historical validation or timing evidence
above. Focused and complete Lean validation and matched measurements for #246
remain pending. The development-velocity estimates are forecasts, not measured
savings.
