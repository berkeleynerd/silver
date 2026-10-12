# Lean critical-path baseline

This is roadmap item 1 of [Lean Critical Path](../roadmap.md#lean-critical-path),
authorized on 2026-10-12. It measures the current implementation without
adopting an optimization or extending the language. Results below are from
Linux x86-64; macOS and hosted CI are outside this investigation.

**Completed:** all three complete checks passed. The dominant cost is elaborating
large generated reconstruction joins: 92.04% of the certificate's named trace
time. The largest join alone took about 62 minutes. This identifies the next
experiment; no optimization or speedup is claimed.

## Inputs and method

The frozen input is `3ecd0d274fdf9b94d7bfdb246df159acd982f031`, whose supported
implementation is Copy String Values (`e9d18f1996`). Later changes at that point
are planning documentation. An isolated `git archive` snapshot excludes the
unfinished `proof/Silver/ComposeAdmission.lean` edit and untracked scratch.
The canonical tools, proof workspace and retained evidence remain untouched.

The actual host has 12 CPUs in its affinity mask, about 31 GiB RAM and no swap.
All three cases use pinned Lean 4.34.1, 12 Lake workers, 12 threads per Lean
process and a 12,288 MiB per-process memory threshold. A once-per-second monitor
stops the experiment if host `MemAvailable` falls below 3 GiB. This is a sampled
safeguard, not an enforced aggregate memory limit.

The snapshot has independent copies of the pinned tools and warm proof cache.
Each case starts from that same initial cache. The runner is invoked from the
snapshot using:

```sh
python3 scripts/check_lean.py --workers 12 --threads 12 --memory-mb 12288
```

Every successful case includes the complete source-correspondence build and a
fresh whole-project axiom/coverage audit. Optional independent kernel replay and
detailed runner provenance are omitted. Artifact hashes and timestamps are
captured outside the timed command. Copied trace captions are retained;
Lake regenerates absolute import setup paths when it compiles a module.

The three cases are:

1. **No change:** test warm-cache reuse after relocation.
2. **Proof-only edit:** wrap the proof of
   `Expression.left_association` in `Eq.trans (…) rfl`, preserving its theorem
   statement and every definition. This temporary proof-construction change is
   confined to the snapshot and is restored before the third case.
3. **Profiled reconstruction of the feature-change workload:** reconstruct the
   rebuild caused by `96b98e1 → e9d18f1996` by removing artifact families for
   15 changed roots and their complete reverse import closure (33 modules).
   Retain the ten unrelated certificates. This includes the two authoritative
   source bindings and two changed certificates. No genuine pre-feature body
   certificate object was available, so this is not a replay of the historical
   cache or a cold build. The final input bytes are the committed implementation.

Only `Silver.OutputBodyCertificate` receives profiler arguments, through a
temporary exact-module Lake library using `weakLeanArgs`. A small pinned-Lake
probe confirmed that adding this library preserves warm objects and that a
subsequently rebuilt selected module inherits the package's thread/memory
settings. Both profiler setup and the synthetic probes remain in the local
evidence. No project Lake configuration change is adopted.

The profiler retains named kernel, definition-header/value and asynchronous
elaboration scopes. A high automatic trace threshold excludes giant syntax and
metaprogram labels; explicitly enabled named scopes retain their durations.
The text profiler provides an additional component breakdown. Instrumentation
overhead has not been measured. This single expensive run locates bottlenecks;
adoption comparisons need matching uninstrumented runs on the same host.

The selected module's additional arguments are:

```text
--profile -Dprofiler.threshold=100
-Dtrace.profiler=true -Dtrace.profiler.threshold=1000000000
-Dtrace.Kernel=true -Dtrace.Elab.definition.header=true
-Dtrace.Elab.definition.value=true -Dtrace.Elab.async=true
-Dtrace.profiler.output.pp=true
-Dtrace.profiler.output=<absolute isolated evidence path>/output-body-profile.json
```

## Results

| Case | Runner elapsed | Build | Fresh audit | Rebuilt modules |
| --- | ---: | ---: | ---: | ---: |
| No change | 7.478 s | 2.544 s | 3.541 s | 0 |
| Proof-only edit | 199.866 s | 195.846 s | 2.496 s | 21 |
| Profiled feature workload | 6,571.881 s | 6,567.929 s | 2.449 s | 33 |

The no-change check retained every compiled artifact's bytes; only `.hash`
sidecar timestamps refreshed. In the proof-only case, only
`ComposeExpression.olean` changed bytes. The other twenty rebuilt `.olean` files
were byte-identical, and all twelve source-certificate `.olean` files retained
both bytes and timestamps. This is a measured downstream invalidation cost,
separate from certificate checking. It supports the later module-system pilot;
it does not measure the benefit of an adopted migration.

The proof-only case's sampled summed RSS peak was 18.84 GiB, while the host
still had 13.86 GiB available. At that sample, `ComposeSourceBridge` used
11.68 GiB RSS and `ComposeExamples` used 6.33 GiB. Shared mapped pages explain
why summed process RSS is not the same as consumed physical RAM. The largest
child RSS maximum reported by the OS was 11.70 GiB. This is another reason to
measure downstream reuse independently of the source-certificate workload.

All three cases covered all 108 modules and 27,360 declarations, with only
`propext`, `Classical.choice` and `Quot.sound`. The feature case finished on
2026-10-12 at 11:43:30 UTC. Its rebuilt modules exactly match the expected
33-module closure; all final `.olean` bytes match the warm baseline. The ten
unrelated certificates retained both bytes and timestamps. Lake reports
6,296 seconds for `OutputBodyCertificate`, rounded to whole seconds.

### Where the certificate time goes

The analysis assigns each positive trace slice once to its nearest named
declaration, separating nested kernel work from enclosing elaboration work.
Independent traversal reproduced every declaration total. None of the 85,890
samples had negative weight. Named declarations account for 6,262.048 seconds,
or 98.925% of traced time; 68.071 seconds remain unassigned. Across threads the
total is 6,330.119 seconds, including 40.480 seconds of overlap. These are summed
traced elapsed scopes, not wall time or OS CPU time. Unassigned time can include
waiting. Percentages below use **named trace time** as their denominator.

| Category | Declarations | Named time | Elaboration | Kernel |
| --- | ---: | ---: | ---: | ---: |
| Reconstruction joins | 1,023 | 5,763.471 s (92.04%) | 5,739.695 s | 23.776 s |
| Line certificates | 1,024 | 494.312 s (7.89%) | 5.965 s | 488.348 s |
| Explicit token list | 1 | 1.981 s | 1.971 s | 0.010 s |
| Token-flattening equality | 1 | 1.900 s | 1.271 s | 0.628 s |
| Singleton reconstructions | 1,024 | 0.364 s | 0.312 s | 0.053 s |
| Final lexing theorem | 1 | 0.014 s | 0.014 s | 0.001 s |
| Authoritative-source equality | 1 | 0.0047 s | 0.0041 s | 0.0005 s |
| Aggregate certificate list | 1 | 0.0011 s | 0.0009 s | 0.0001 s |

The leading declarations are all reconstruction joins in `Silver.Source`:

| Declaration | Named time | Elaboration | Kernel |
| --- | ---: | ---: | ---: |
| `outputBodyTokens_block_0_1024` | 3,742.136 s | 3,738.814 s | 3.321 s |
| `outputBodyTokens_block_0_512` | 645.946 s | 644.372 s | 1.574 s |
| `outputBodyTokens_block_512_1024` | 424.846 s | 423.414 s | 1.432 s |
| `outputBodyTokens_block_0_256` | 130.138 s | 129.553 s | 0.585 s |
| `outputBodyTokens_block_512_768` | 114.504 s | 113.706 s | 0.798 s |

The root join accounts for 59.76% of named time; the top three account for
76.86%. The text profiler corroborates approximately 5,750 seconds of
elaboration and 513 seconds of type checking. Tactic execution took only
1.97 seconds. Removing search or speeding the final source equality is therefore
not the first priority for this representation.

The 60,426-byte Ada body produces a 4,344,052-byte certificate with 3,076
declarations. Joins occupy about 88% of generated bytes, repeating 603,247
literal characters and 602,224 character-list entries. They apply
`string_join_ofList` to connect concrete reconstructed Strings and child
certificates. Elaborating these terms and matching their expected equality
types is the leading mechanism hypothesis. Fine `Meta` scopes were not retained,
so the profile does not attribute a measured fraction to definitional equality,
unification or any particular String conversion operation.

### Memory and concurrency

The feature case's summed process-tree RSS peaked at 13.71 GiB. The host's
minimum sampled available memory was 19.58 GiB; the safeguard never triggered.
The largest child OS RSS maximum was 11.70 GiB, belonging to the later
`ComposeSourceBridge` workload. The profiled certificate process itself peaked
at 5.47 GiB. Process CPU-time observations retained in `progress.jsonl` showed
approximately one core in use despite its twelve-thread setting.
The slow join does not show a memory-pressure bottleneck that a higher threshold
would resolve.

Only 656 of the 3,076 declarations overlapped an RSS observation; unsampled
declarations have unknown memory use. The root join overlapped process RSS up
to 5.43 GiB, including retained earlier state. This is not its own allocation.
The bridge's higher memory use supports preserving headroom during subsequent
experiments; more Lake workers do not address this serial join elaboration.

## Ranked next work

1. **Target the largest reconstruction joins.** Compare explicit conversion
   equalities, shared reconstruction data and reusable lemmas on fixed source
   bytes. A bounded retry of the prior structural/authoritative-decoding candidate
   belongs here, with a memory budget and host-headroom cutoff. Measure its final
   composition too: earlier candidates moved the cost into final whole-source
   conversion and did not complete successfully. Adopt only successful measured
   improvements that preserve exact source correspondence and accepted axioms.
2. **Pilot module boundaries for proof-only edits.** The measured 21-module
   rebuild, with twenty byte-identical downstream objects, gives a separate
   target for faster iteration. Preserve full private/transitive axiom coverage
   and source-edit invalidation during the planned small module-system pilot.
3. **Revisit leaf kernel work after joins improve.** Line certificates dominate
   the remaining kernel time. Their `decide +kernel` already uses checked
   auxiliary lemmas; blanket replacement or auxiliary wrapping is not justified.

Broad `SymM`/`vcgen` migration, extra worker counts, cache teardown and audit
removal are not supported as remedies for this measured bottleneck. Persistent
proof-state reuse still needs a separate measurement of authoring retries.
These are recommendations for later roadmap items, not implemented changes.
There is no measured speedup yet: future adoption comparisons require matched
uninstrumented runs on the same host, separately reporting cached and
changed-source feedback time.

## Evidence and limits

Local evidence is under
`.silver/linux-x86_64/lean-baseline-20261012T094603Z/`: frozen snapshot, initial
warm cache, host/configuration record, commands, case logs and runner manifests,
artifact inventories, process samples, profiler JSON and analysis. These ignored
artifacts are preserved locally and are not recoverable from a Git clone.

The principal files are `feature-profile/output-body-ranked.json` (all
declarations), `output-body-profile.json` and `output.log` in that same directory,
and the root-level `measure.py`, `prepare-feature.py` and
`instrumentation/analyze_profile.py`. The three case directories contain
commands, results, RSS samples and copied runner evidence. An initial launcher
attempt stopped before invoking Lean because `/usr/bin/time` was unavailable;
the completed measurements use Python's OS resource accounting instead. Its
diagnostic is retained under `launcher-missing-time/`.

Independent methodology and final-result reviews are retained as
`review-method.json`, `final-evidence-review.json`, `profile-review.md`,
`profile-conservation-review.json` and `profile-rss-review.json`. They confirm
the input snapshot, reconstruction closure, complete audit, trace accounting
and preservation of all 982 canonical proof/cache files' bytes, sizes and
timestamps. Canonical evidence hashes also match their saved values; their
before timestamps were not recorded. The pre-existing uncommitted
`ComposeAdmission.lean` edit remains byte-identical and excluded from all cases.
No SPARK/compiler validation was rerun for this measurement/documentation task.

Runner elapsed time excludes the launcher's polling delay; outer wall time and
child CPU accounting are retained separately. Memory is summed process-group
RSS sampled once per second: shared pages can be counted repeatedly and short
peaks can be missed. The largest child RSS maximum is a separate OS statistic.
Memory observations aligned with a declaration are process-wide observations,
not allocations attributable exclusively to that declaration. Trace intervals
from concurrent threads must not be summed as elapsed wall time.

The earlier [physical desktop checkpoint](copy-values.md#physical-linux-checkpoint)
used a different 22-CPU, approximately 91-GiB host. Its 6,010-second certificate
timing is historical context, not a denominator for a speedup claim here.
Prior [reconstruction experiments](certificate-performance.md) remain failed or
interrupted candidates. This baseline neither changes their status nor weakens
exact-byte correspondence, complete discharge or the accepted axioms.
