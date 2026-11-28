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
   This establishes the distinction, not its cause: the pinned wrapper/Why3
   implementation has not yet been traced. Do not treat the setting as an
   observed strict CPU cap or compute elapsed cost from it.

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

## Smallest next checks

Finish the already-running clean 60-second complete Model probe, inspect every
selected flow/proof row and independent entity coverage, then complete At and
applicable Parameter_Step/Procedure_Parameter_Step checks. Compare actual final
results before claiming a timeout improvement. If the same preconditions remain
unresolved, diagnose their exact final source locations and missing exported
span facts before any further expensive rerun or native source change.

For performance, first read the pinned wrapper/Why3 limit handling to explain
the observed 121/241-second guard, using these captured arguments. Then review
one heavy successful helper's full-domain contract/context and existing timing
counters for a bounded transformation-reduction experiment. A future cache-reuse
review can ask whether proven-identical inputs permit safe reuse across the
focused/complete boundary; this record neither changes that boundary nor
promotes cached attempts into new-policy evidence. Complete obligation discharge,
source correspondence and final validation remain required.
