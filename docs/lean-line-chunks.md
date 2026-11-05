# Parallel line-certificate experiment

Authorized on 2026-11-05 under [#8](https://github.com/berkeleynerd/silver/issues/8)
and [milestone 17](https://github.com/berkeleynerd/silver/milestone/17).
Status: preparation reviewed; matched sample measurements queued behind delivery
verification. No benchmark result or production adoption is claimed.

The automatic-CPU restart of PR #307 exposed useful parallel work followed by
a long single-module tail in `OutputBodyCertificate`. At the selected prototype
baseline `617547bd0d`, it contains 4,915 line certificates and 9,829 reconstruction
nodes in one module. The earlier [#246 profile](development-velocity.md#first-package-implementation-and-validation)
attributed 74.79% of named trace time to line certificates and 24.62% to joins.
These historical trace shares are not current CPU costs or a speedup forecast.

## Selected scope

Keep the existing certificate representation. Move unchanged line-certificate
declarations into four independent modules, preserving their names, literal
text, candidate tokens and checked proofs. The aggregator retains the existing
reconstruction tree and final source, token and lexer theorems. Candidate chunks
remain untrusted; the final connection to actual Ada bytes remains required.

Prepare this complete candidate without adopting it. First measure a fixed
sample of 512 existing line declarations, selected deterministically across the
source and divided into four modules. This sample tests line-check parallelism
and module overhead; it does not check the complete source reconstruction or
establish the whole-feature assurance guarantee.

Use an isolated worktree and proof workspace. Experimental tooling belongs
outside the production `scripts/` and `proof/` trees. Existing verification
inputs and caches remain unchanged; no live cache is copied. Use pinned tools
and the normal kernel checks, without new axioms or bypasses.

## Comparison and completion

The sample uses the same four-module graph at one and four Lake workers, with
one thread per Lean process in both trials to isolate module-level parallelism.
That explicit setting is a measurement control, not a replacement for the
owner's automatic-CPU policy on ordinary runs. Build common imports before the
timed comparison; force the same selected module closure for each trial so the
second trial cannot become a warm-cache comparison.

Wait for capacity without holding idle reservations. Existing managed workspace
leases and worker accounting govern the trials. Retain actual commands, source
and tool identities, cache preparation, elapsed and CPU time, sampled memory,
concurrent workloads and terminal outcomes. Changes in competing load limit
causal timing claims. Lean's memory threshold applies per process, not to the
aggregate. Preparation and static equality checks are distinct from Lean
acceptance and benchmark success.

This bounded experiment is complete when the prototype and comparison are
reviewed, the two comparable trial outcomes are retained, and the next step is
explicitly accepted or rejected based on those results. A useful sample result
may justify a complete-certificate trial; it does not authorize production
adoption. Any adoption still needs generator/runner module integration, exact
source/newline/token invalidation controls and the complete source/module/axiom
checkpoint. Reconstruction-subtree splitting, stable chunk identities, broad
tactic changes and persistent telemetry remain outside this experiment.

## Work record

Preparation selected GPT-6.1 Sol / Extra High; the prior read-only structural
assessment selected GPT-6 Astra / Extra High. Lead runtime settings and token/cost
measurements are unavailable. The initial result is the bounded plan above;
no Lean benchmark was run for authorization.

### 2026-11-05 — Prepared candidate and queued comparison

The isolated branch `perf/lean-line-chunks-20261105` starts from
`617547bd0dd62bb5aa58b2b4833959e7a068dc19`. The
[harness](../experiments/lean_line_chunks.py) extracts all 4,915 existing line
declarations into four chunks of 1,228/1,229/1,229/1,229 declarations and preserves
the reconstruction and final-theorem suffix byte-for-byte. Its separate sample
selects 512 evenly spaced declarations, including both endpoints, into four
128-declaration modules. Python equality checks also reconstruct the actual Ada
source bytes. These are preparation checks, not Lean acceptance.

The reviewed output is `.silver/linux-x86_64/line-chunks/pilot-ready` in
`tmp/lean-line-chunks`. Preparation run `20261105T154415-28db5daa2084` passed in
0.792 seconds with zero workers and no Lean execution. Eight focused Python
tests passed in 0.973 seconds, including unchanged declarations/suffix, forced
candidate rebuilds, shared-object preservation, queue reservations, CPU
accounting and interruption cleanup. Python compilation, CLI help/dry-run and
whitespace checks also passed.

| Reviewed input | SHA-256 |
| --- | --- |
| `experiments/lean_line_chunks.py` | `a9b7815747114ac90a40308bdf9e4e706cc7597508a6b9bb55e137454d277c41` |
| `experiments/test_lean_line_chunks.py` | `7ccc864002e57595516aca1b7a4b96b0f03c13688624c7a892302e411c779d5d` |
| `pilot-ready/manifest.json` | `0f208309224c987c947da9f39a0c69c596c67388c2fe9e3c356561a254d8cf5f` |

Implementation selected GPT-6.1 Sol / Extra High. An independent GPT-6 Astra /
Extra High review covered static source preservation, sample/cache controls,
isolation and reservations. Its cleanup finding was repaired. A final bounded
review of CPU accounting and cleanup ran at 15:47:04–15:49:27 UTC (143 seconds)
against the hashes above and found no blocking issue; it inspected the tests
without rerunning them. Runtime-confirmed model settings and token/cost data
are unavailable. `/usr/bin/time` is absent on this host, so CPU measurements use
Python `RUSAGE_CHILDREN` user/system deltas immediately around Lake launch/reap;
wall time is monotonic and aggregate RSS is sampled, not an exact peak.

Run from the experiment worktree:

```sh
python3 experiments/lean_line_chunks.py --prepare
python3 -m unittest discover -s experiments -p test_lean_line_chunks.py -v
python3 experiments/lean_line_chunks.py --dry-run
python3 experiments/lean_line_chunks.py --run-pair
```

The queue waits without a reservation for four free managed workers and at
least 20 GiB available RAM. Each Lean process has one thread and a 4,096 MiB
internal allowance; common imports build once outside the timed trials.
Available RAM below 8 GiB interrupts only the experiment's process group.
Deliberate cancellation uses SIGINT; the harness is not a general SIGTERM or
orphan-recovery supervisor. Active delivery inputs, caches and reservations
remain unchanged.

Trial evidence stays in each managed run's `line-chunks/` directory, and
`pilot-ready/pair.json` is written only after both trials succeed. It records
commands, source/tool identities, common objects, elapsed/CPU time, sampled
memory and competing runs. This is one ordered pair: differing host load and
sample distribution limit extrapolation to the full certificate. The prepared
full candidate remains unvalidated until a separate complete trial is selected.
