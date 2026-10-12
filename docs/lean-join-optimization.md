# Checked reconstruction witnesses

This is the bounded source-reconstruction/equality investigation authorized on
2026-10-12, item 2 of [Lean Critical Path](../roadmap.md#lean-critical-path).
The [baseline](lean-baseline.md) located the dominant cost in elaborating large
reconstruction joins. The adopted change retains the existing representation and
lets the kernel check the original equality witness without first repeating
that conversion in the elaborator. Complete builds, fresh audits, focused tests
and independent source/evidence reviews passed. The feature-workload runner
time fell from 130.5 to 14.9 minutes, an observed 8.75× ratio. The baseline
overlapped other experiments, so this is not an isolated causal speedup estimate.

## Change and assurance

The new [CertificateWitness](../proof/Silver/CertificateWitness.lean) helper
provides `kernel_exact`. It elaborates an explicitly supplied, closed witness
without an expected type, resolves synthetic metavariables, then calls Lean's
checked `mkAuxLemma` with the exact goal type and synchronous checking. Only
after that check does it close the goal with the resulting theorem. This is
the same auxiliary-lemma mechanism used by pinned Lean's `decide +kernel`.
It adds no axiom, native-evaluation dependency or kernel-check exception.

The auxiliary cache can reuse a previously checked proof of the same exact
type. The guarantee is that each returned goal type has a checked proof;
the helper need not reject an alternative incorrect witness on a cache hit.
Kernel failures propagate. The existing source/retained-trace policy and fresh
private/transitive axiom audit remain required. This helper serves generated
closed witnesses; it is not a general tactic for inference from local hypotheses.

The generator imports that helper and changes each existing join argument to:

```lean
(by kernel_exact (string_join_ofList leftCharacters rightCharacters))
```

Independent inspection and byte normalization confirm that all twelve generated
modules retain their original literals, character lists, candidate tokens,
line checks, reconstruction tree and final `_source`, `_values` and `_correct`
claims. Removing the helper import and 2,349 wrappers reproduces the committed
baseline exactly. `SourceLexer`, handwritten authoritative bindings, source-byte
policy, newline handling, compiler sources and language support are unchanged.

## Experiments

Small matched probes used pinned Lean 4.34.1 with one thread, a 4,096 MiB
per-process threshold and a 90-second timeout. Both variants used identical
source text and existing proved child blocks. Both included the same selective
profiling; times include imports, interpretation and profiler overhead.

| Joined source bytes | Existing witness | Checked witness |
| ---: | ---: | ---: |
| 2,666 | 5.820 s | 2.413 s |
| 7,384 | 25.534 s | 3.713 s |

All four probes passed with the same three standard axioms. In the 7,384-byte
case, measured elaboration dropped from 23 seconds to 0.057 seconds; kernel
time was 0.214 versus 0.247 seconds. These are single-join observations, not
complete certificate or feature-feedback measurements.

The previous structural representation was also retried on 2,666 bytes. Both
the encoded equality using `decide +kernel` and the decoded equality using `rfl`
timed out at 90 seconds, peaking at approximately 4.00 and 2.42 GiB RSS. Buffered
logs do not establish which phase caused either timeout. The generic helpers
passed, but neither concrete trial did; that alternative was stopped and is
not adopted. The [historical negative results](certificate-performance.md)
remain unchanged.

A large corrupted-witness probe also timed out at 90 seconds and is inconclusive
as a rejection test. Tiny false arithmetic and join equalities were rejected
with explicit kernel type-mismatch diagnostics. No rejection-latency bound for
malformed large generated witnesses is claimed.

## Complete measurement and validation

The frozen baseline is `76e98bdc07`, whose supported compiler implementation is
`e9d18f1996`. Both baseline and candidate use independent snapshots and copies
of the warm cache and pinned toolchain. The unfinished root
`ComposeAdmission.lean` edit is excluded. The measured Linux x86-64 sandbox
exposes 12 CPUs, approximately 31 GiB RAM and no swap; this differs from the
physical host's 96 GB reported by the owner.

The uninstrumented comparison reconstructs the same feature workload as the
baseline record: invalidate the 33-module reverse closure of the Copy String
Values change on its final source bytes, retaining ten unrelated certificates.
This is a reconstruction on current source, not a historical-cache replay or
cold build. Both comparison commands use twelve Lake workers, twelve threads
per process and the 12,288 MiB per-process threshold, with sampled host-memory
monitoring. Timed commands include complete builds and fresh axiom/coverage
audits; separate kernel replay remains optional and was not requested.

Integration uses four workers and a 5 GiB sampled host-headroom cutoff while
sharing the host with the baseline. It rebuilds all twelve changed certificates
and is separate from the twelve-worker feature-workload timing. The baseline
also overlaps those integration/probe runs; the subsequent candidate feature run
had no competing experiment. The fixed source workload and build configuration
match, but this concurrency difference limits a controlled speedup claim.

An initial candidate exposed multiline tactic syntax errors and was stopped;
parentheses around the witness corrected that defect. A subsequent candidate
with `import Lean` proved all twelve certificates, but
`ComposeSourceBridge.actual_declarations` exceeded the 12,288 MiB process
threshold. That build failed after 1,133.820 seconds and never reached the fresh
audit, despite ample host memory. Both failed runs and their caches are retained.

The helper now imports only its three required modules. An isolated comparison
reduced its transitive import closure from 2,356 to 1,036 modules and peak load
RSS from 1,552,624 to 760,864 KiB (about 0.755 GiB less). A valid proof passed
without axioms and a false proof failed kernel checking. These are helper-load
measurements. The complete narrowed-import run subsequently passed, including
the previously failing bridge, without raising the threshold.

The narrowed integration completed in 1,117.872 runner seconds: 1,113.336 for the
build and 2.943 for the fresh audit. It covered all 109 project modules and
27,511 declarations, with only `propext`, `Classical.choice` and `Quot.sound`.
`OutputBodyCertificate` took 753 seconds, rounded by Lake. The largest child
OS RSS maximum was 11.92 GiB; sampled summed process-tree RSS peaked at 12.75
GiB, with at least 15.67 GiB of host memory available. Shared pages can appear
in multiple processes' RSS. The host-headroom safeguard did not trigger.
The composed-source bridge came within about 85 MiB of the configured process
threshold. This is a setting, not the host's physical-memory ceiling:
`--memory-mb 16384` permits a higher threshold when needed. The comparison keeps
12,288 MiB fixed. The twelve compiled certificate `.olean` files total
71,752,680 bytes, down from 86,888,592 bytes (17.42% smaller).

Both twelve-worker feature-workload runs passed:

| Measurement | Baseline | Optimized |
| --- | ---: | ---: |
| Complete runner | 7,829.871 s | 894.852 s |
| Build | 7,825.987 s | 890.843 s |
| Fresh audit | 2.373 s | 2.615 s |
| Output-body certificate (Lake rounded) | 7,559 s | 608 s |
| Project modules / declarations audited | 108 / 27,360 | 109 / 27,511 |
| Largest child OS RSS maximum | 11.70 GiB | 11.92 GiB |
| Sampled summed process-tree RSS peak | 14.63 GiB | 13.38 GiB |
| Minimum sampled host memory available | 15.67 GiB | 19.50 GiB |

The runner ratio is 8.75× (88.57% less elapsed time); the body-certificate ratio
is 12.43×. The outer monitoring harness measured 7,830.080 versus 895.713 seconds
(8.74×). Child CPU time fell from 8,546.922 to 1,479.342 seconds (5.78×). These
are observations of this workload with the concurrency caveat above, not a
universal 10× result. Neither run triggered its 3 GiB host-headroom cutoff.
The optimized run completed on 2026-10-12 at 14:37:07 UTC without raising the
12,288 MiB threshold. No memory default or sandbox allocation changed.

Independent review confirmed that both runs rebuilt exactly the expected
33-module closure. The ten unrelated certificates retained their compiled bytes
and timestamps in each run. All 327 optimized `.olean`, `.ilean` and generated
C outputs were byte-identical to the accepted integration; build metadata and
traces changed as expected. Both fresh audits found only `propext`,
`Classical.choice` and `Quot.sound`. The added helper and checked auxiliary
theorems explain the changed module/declaration inventory; private and generated
declarations remain covered by the unchanged audit.

The focused checks also passed:

- Four generated exact-byte fixtures and a valid witness pass the fresh
  axiom audit. Nine negative controls reject false witness/join equalities,
  changed comments, missing final LF, normalized CRLF, altered leaf/final tokens,
  an unsupported byte and LF inside a leaf. Current helpers compile freshly in
  temporary directories, so stale canonical objects cannot satisfy the tests.
  The final narrow-import helper passed these fourteen controls in 38.143 seconds.
- All eight existing source-policy/regeneration tests pass, including the
  complete byte alphabet and parity for twelve generated modules.
- The existing real-Lake twelve-binding dependency test passes, including
  source-byte changes with restored timestamps and unrelated-cache retention.
- Independent source/mechanism, complete integration and paired measurement
  reviews passed. They confirm exact source preservation, fresh audits, input identity and
  preservation of all 982 canonical proof/cache files' bytes and timestamps.

No SPARK/compiler code or GNATprove inputs changed, so their retained evidence
keeps its original attribution without a native rebuild. Module migration,
language expansion and Oracle changes remain outside this task.

## Evidence

Local evidence is preserved under
`.silver/linux-x86_64/join-optimization-20261012T120859Z/`: frozen inputs,
independent snapshots, commands, complete-run logs/results, resource samples,
artifact inventories, generated-source preservation checks and copied probe/test
reviews. These ignored artifacts are not recoverable from a Git clone.
The previous profiled baseline and canonical tools/caches/evidence are preserved.
`tmp/join-optimization-active.json` and the evidence directory's
`task-checkpoint.md` record recovery details and the closing publication state.

The optimized warm cache is retained at `candidate-warm/proof/` within that
evidence directory; the final measurement workspace is
`candidate/.silver/linux-x86_64/proof/`. Reuse a copy of an optimized workspace
for future experiments, retaining `.lake` metadata and letting the normal runner
synchronize sources and validate dependencies. The untouched canonical workspace
still contains the earlier certificate implementation. It is preserved evidence,
not the preferred seed for another optimized experiment. Do not run multiple
writers against one proof workspace.

The implementation and review target is the commit introducing
`proof/Silver/CertificateWitness.lean`, based on `76e98bdc07`; Git identifies its
containing commit. The next proposed work is the bounded module/dependency
pilot, especially avoiding downstream rebuilds after proof-only edits while
preserving private/transitive audit coverage. It is not started by this change.
