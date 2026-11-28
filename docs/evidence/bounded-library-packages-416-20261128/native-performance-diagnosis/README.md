# Native performance diagnosis — 2026-11-28

This is a bounded, read-only diagnosis for #416, requested while canonical
unit run `20261127T195636-5b2a2f886237` remained active on native Linux x86-64.
It is neither a final proof result nor a performance benchmark. No source,
proof policy, running job or cache was changed for this diagnosis. The separately
authorized clean 60-second helper probe continues on CPUs 6–7; the original
30-second unit run retains CPUs 2–3 and its captured inputs.

## Prioritized findings

1. **The broad proof workload and Why3 transformations are material costs, even
   when every obligation succeeds.** At the retained snapshot, 267 helper XML
   sessions had been completed or rewritten since this invocation started;
   263 had proved roots. They contain 29,272 nested goals and **80,613 recorded
   prover attempts**. These are not 80,613 established fresh solver executions:
   cached results can be replayed. The corresponding generated JSON inputs total
   1,714,569,045 bytes, with much repeated context. Actual retained helper reports
   expose large `inline_trivial` and `remove_unused` counters. Those counters
   must not be summed or divided into elapsed time as if their timing scopes
   and concurrency were disjoint.

2. **The eight unresolved roots do not account for all slow work or all timeouts.**
   Latest current-run sessions record 64 timeout attempts: 56 main-prover attempts
   configured for 30 seconds (21 CVC5, 16 Z3, 19 Alt-Ergo), plus eight 10-second
   counterexample attempts. Thirty-two occur in ultimately proved helpers;
   `Within_Work_Budget` alone records 16. The nominal arithmetic
   `56 × 30 + 8 × 10 = 1,760` seconds is a configuration total, **not measured
   runtime or a runtime upper bound**. No XML result has a measured time field.
   The other recorded statuses are 72,516 valid, 7,766 highfailure, 260 failure,
   one unknown and six outofmemory. Alternative unsuccessful/cancelled attempts
   in a proved root are not unresolved proof obligations; these labels do not
   establish a machine-wide memory problem.

3. **Configured solver limits differ from observed process limits/costs.**
   A clean 60-second probe CVC5 child was observed at 144.1 CPU seconds with
   inherited soft/hard `RLIMIT_CPU` of 241 seconds. Original 30-second solver
   children show 121 seconds. The retained successful Signature report records
   a CVC5 attempt of 106.419 seconds under the configured 30-second policy.
   The subsequent [installed-toolchain trace](timeout-semantics.md) establishes
   the cause: the cache salt triggers Why3's internal-timeout allowance, producing
   an outer per-process CPU guard of `4t + 1`, while the main solver commands
   have no internal timeout argument. Timeout report values can also be normalized
   back to `t`. Do not compute actual elapsed cost from those settings/reports.

4. **Scope and cache boundaries repeat useful work.** The current unit gate
   covers the remaining helper/caller inventory and repeats previously focused
   helpers such as Signature, Spec and Analyze. The final compiler audit has a
   separate cache from focused checks. Changing the canonical policy from 30 to
   60 seconds selects a different focused namespace. Thus a warm full-compiler
   success is not evidence of a warm focused-policy run, and the current clean
   60-second probe has no imported 30-second proof cache. This is the existing
   evidence isolation policy; it was preserved.

5. **Managed preflight/audit is not the dominant measured cost in the retained
   focused examples.** Preflight took 2.7–3.2 seconds. Successful Main spent
   807.46 of its 810.94 elapsed seconds inside the native-tool phase. This phase
   contains translation, flow, Why3 transformations, scheduling and solver work;
   the ordinary log's three phase headings have no timestamps, so they cannot
   provide a precise internal elapsed partition. The live unit has not reached
   its final report/audit boundary.

## Retained measured examples

All are canonical 30-second focused checks in the primary worktree, with two
workers. Report counters and solver-reported times can overlap or reflect cached
results; they are not additive wall-time components. The failed/successful Main
pair also changed the metadata contract, so it is not a controlled speed test.

| Helper/run | Outcome | Managed elapsed s | Why3 inline_trivial counter s | Why3 remove_unused counter s | Recorded attempts |
| --- | --- | ---: | ---: | ---: | ---: |
| Main / `190610-5f1996739339` | Two unresolved checks | 1,471.70 | 300.43 | 191.55 | 757 |
| Main / `193939-4dba03f7ee42` | All 52 checks proved | 810.94 | 298.88 | 185.21 | 764 |
| Analyze / `195352-f016f03f782d` | All 30 checks proved | 124.79 | 40.58 | 19.36 | 543 |
| Signature / `184159-a0acf00fba2f` | All 79 checks proved | 1,020.79 | 124.52 | 73.35 | 945 |
| Spec / `185933-2055189d72e9` | All 45 checks proved | 362.11 | 112.99 | 66.84 | 606 |

All run IDs above have prefix `20261127T`.
[Measured-cost extraction](focused-helper-measured-costs.json) retains report
and event hashes, complete status/time aggregates and selected timing counters.
Original reports and logs are already retained in the
[continuation packet](../../bounded-library-packages-416-20261127/native-continuation/).

The largest gaps between current helper session completion timestamps include
successful Read_Chain_Into (45.97 minutes), Read_Relation_Into (25.79),
Boolean_Array_Values_At (20.48) and Basic_Body (20.15), as well as unresolved
Array_Declaration_At (33.46) and Model (24.14). These are **completion timestamp
intervals**, which can include queued/overlapping work and translation; they are
not measured exclusive helper costs. In particular, generated-input-to-session
age includes queue delay and must not be called solver runtime.

## Policy, progress and evidence

The original command selects `--unit silver_output_profile.adb`, `--mode=all`,
`--level=2`, three provers, `--timeout=30`, `-j 2`, forced fresh selected analysis
and the file-backed cache below `compiler/obj/focused/4a9057104dad17e3/`.
Observed Why3 commands use `--proof per_check`, `--force`, counterexamples on,
10-second CE limit and 1,000 MiB prover memory limit. The runner's normal complete
cache is `proof-cache/gnatprove/<lock digest>/`; focused cache is below its
policy-specific object workspace (`scripts/dev.py`, `focused_proof.py`, and
`proof_provenance.py`). A one-pass live cache inventory saw 125,058 files,
71,293 modified since this run began. That is not a cache-hit count or avoided
CPU estimate; temporary files and live writes are included.

The clean canonical Model selector (`silver_output_profile.adb:2193`) runs as
`20261128T051819-97c12be5e24a`, with `--timeout=60` in namespace
`97769bfda44bef44`, two automatically available workers and affinity 6–7.
Only that helper's proof input has been generated; final `.spark` entity coverage
and obligation status are pending. All 11 tool executable hashes match the
primary, and Ada/GPR sources are unchanged. Private bootstrap regenerated
installation paths and refreshed its private package index. Its 2,671 captured
inputs therefore are not claimed identical to the primary's 2,641 inputs.
All 2,641 primary hashes matched at 05:17 UTC.

Application_Statement completed root-proved at 05:25:10 UTC and Application_Tail
at 05:26:13; Routine_Frame was actively proving at 05:27:41. This is useful
progress, not a final unit success. The additional Parameter_Step and
Procedure_Parameter_Step timeout roots remain in the reconciliation scope.

Exact supporting extractions:

- [Per-helper session inventory and completion bounds](current-helper-performance-raw.json).
- [Every current-session timeout attempt](current-all-timeout-attempts.json).
- [Measured focused report costs](focused-helper-measured-costs.json).
- [Observed timeout/process-limit distinction](live-timeout-observation.json).
- [One-pass cache inventory](cache-inventory-observation.json).
- [Primary frozen-input recheck](primary-input-recheck.json) and
  [private installation/input differences](isolated-input-comparison.json).
- [Generated helpers awaiting current sessions](pending-generated-helpers.json)
  at its explicit snapshot time; this is not a remaining-duration estimate.

## Host allocation and comparison limits

The lead's [30-second host sample](host-summary.json), from 05:24:37 to 05:25:07
UTC, found about 51 GiB available RAM at the end, no swap, negligible guest
I/O wait and CPU steal. The subsequent [constraint snapshot](host-constraints.json)
records no cgroup CPU throttling, effective cpuset 0–7 and about 82 GiB free disk.
Pressure-stall interfaces were unavailable, so no PSI measurement is claimed.
This bounded observation does not establish the resource history of the whole run.

The original run has two workers on CPUs 2–3, deliberately sharing the eight-CPU
host with concurrent proof work. The clean 60-second probe has two workers on
6–7; the source/Lean batch subsequently took 0,1,4,5. All sampled native child
threads remained within their respective two-CPU masks. The original process
tree accumulated about 43.67 CPU seconds during the 30-second interval; the
probe accumulated 59.96. Raw [start](host-start.json) and [end](host-end.json)
snapshots retain the process accounting. Process exits, waited-child accounting
and sampling races limit those estimates. Summed RSS was about 6.1 and 2.5 GB,
respectively; those sums are neither private memory nor peak memory.

The original run is therefore not an eight-core speed test. A future native
checkpoint can use the automatic larger allocation when other managed jobs
release their shares, without stopping the present work. More workers may
accelerate independent solver tasks; the observed transformation costs mean
linear scaling is not established.

Historical short complete audits used retained work. The
[#410 checkpoint](../../named-array-parameters-410-20261121/final-native/README.md)
took 492.560 seconds with two workers, forced full analysis and retained
sessions/cache. The [#373 preparation](../../proof-iteration-efficiency-373-20261120/preparation/README.md)
took 10,713.478 seconds at the outer wrapper, with twelve workers on the earlier
22-CPU host and an existing cache; its later
[warm final audit](../../proof-iteration-efficiency-373-20261120/final/README.md)
took 48.245 seconds. Different source, cache, scope and host allocation preclude
a measured regression or speedup ratio from these numbers. They do show why the
last successful warm audit is an unsuitable estimate for new broad proof work.

## Smallest next checks

Finish the already-running clean 60-second complete Model probe, inspect every
selected flow/proof row and independent entity coverage, then complete At and
applicable Parameter_Step/Procedure_Parameter_Step checks. Compare actual final
results before claiming a timeout improvement. If the same preconditions remain
unresolved, diagnose their exact final source locations and missing exported
span facts before any further expensive rerun or native source change.

The [pinned limit-handling trace](timeout-semantics.md) now explains the observed
121/241-second guard. Next review one heavy successful helper's full-domain
contract/context and existing timing
counters for a bounded transformation-reduction experiment. A future cache-reuse
review can ask whether proven-identical inputs permit safe reuse across the
focused/complete boundary; this record neither changes that boundary nor
promotes cached attempts into new-policy evidence. The existing deferred
[#381](https://github.com/berkeleynerd/silver/issues/381) is the tracking home
for a later selected hotspot comparison; this diagnosis does not reactivate its
whole strategy experiment or introduce a scheduler. Complete obligation discharge,
source correspondence and final validation remain required.
