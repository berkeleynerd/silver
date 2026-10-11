# Lean source compartmentalization

## Scope and decision

The owner authorized a bounded compartmentalization experiment on 2026-10-11,
based on the completed eight-production implementation `1ed039e`. The experiment
isolates authoritative source dependencies and extracts stable lexical/name
helpers from the output recognizer. The language, runtime API, report policies,
Oracle and certificate representation are unchanged. Adopt the bounded partition:
complete native and Lean validation, fresh kernel replay and independent evidence
corroboration passed. The measured cache isolation and reduced dominant
certificate cost justify this change; they do not justify further infrastructure.

The earlier [reconstruction-representation trials](certificate-performance.md)
remain closed. This task changes which complete Ada files are certified, not the
kernel-checked line/reconstruction argument. The existing
[end-of-session validation cadence](../development.md#proof-loop-and-validation)
remains appropriate for substantive source changes.

The owner's concern about over-engineering is warranted: actual-source
correspondence is required, but this costly certificate representation is an
implementation choice. Keep speculative native/model experiments cheap and
perform complete assurance once the selected capability is stable. This bounded
task is not a reason to add further partitioning, benchmark infrastructure or a
new certificate framework. The measurement scripts remain local experiment
artifacts, not additional supported development tooling.

The owner also questioned routine replay and evidence bookkeeping. A proposed
follow-up is a smaller routine runner: pinned Lean, complete source-correspondence
proofs, correct source dependencies, the cheap fresh axiom/coverage audit, stable
inputs and a concise result/log. Separate `leanchecker --fresh` could be reserved
for toolchain changes, cache investigations or explicit audits. It is an
additional workflow check, not an explicit Oracle requirement. Ordinary Lean
imports trust locally built compiled objects; the existing local tool/cache
assumption would remain explicit. This recommendation does not remove a check
in this task. The current checkpoint retains full replay.

## Implementation

Each handwritten source binding has its own Lean module and binary Lake input.
The `AuthoritativeSource` facade still imports every binding. Each generated
certificate imports only its own binding; downstream source bridges retain their
normal imports. The twelve exact binding libraries follow the umbrella library
because Lake resolves overlapping module owners in reverse declaration order.
Native tests exercise this ownership with source-byte changes, preserved
modification times and unrelated object checks.

`Silver_Output_Lexical` holds lexical, identifier and bounded literal/decimal
helpers. Ghost expression functions remain visible in its specification so the
SPARK recognizer's refinement proofs can use their equations. Ordinary helper
bodies retain their contracts and algorithms. Token categories, spellings,
production arrays, suffix recognizers and acceptance loops stay in
`Silver_Output_Profile`. The helper imports the existing `Silver_Profile`
lexical primitives; its source bound and comment introducer equal the output
profile's values. Lean explicitly checks that equality, redirects expression and
header checks to their actual units, and retains complete shapes and byte
certificates for the helper specification and body.

Independent comparison accounts for every original declaration family. An
initial isolated extraction accidentally moved `Token_Index`, changing the
binding of `Required_Tokens`; review caught it before integration. The exploratory
proof was stopped and retained, the declaration returned to the output package,
and the corrected candidate rebuilt. This was an implementation correction,
not a proof retry on unchanged inputs. Subsequent differential admission testing
agreed with the baseline on 640 sources, and catalogue bytes were unchanged.
The complete exploratory native audit passed all 3,029 checks across 17 units
and 216 entities. Its twelve additional limitation notes repeat imported
recursive-helper notes; no new limitation class or omitted obligation appeared.
Neither a pin update nor these tests substitutes for complete Lean checking.

## Measurement method

The actual host is Linux x86-64 with 12 CPUs and about 31 GiB RAM. Lean uses the
same pinned tools and 12 Lake workers, 12 threads per process and 12,288 MiB
per-process threshold as the preceding checkpoint. Existing canonical caches
are retained. The initial seed overlaps native exploratory proof and focused
regression tests; this contention is part of its measured setup cost. An independent copy of the baseline proof workspace, authoritative
inputs and previous evidence was verified before integration; no mutable output
is shared through hardlinks. macOS proof work is outside this task and GitHub
Actions stays disabled.

The historical branching checkpoint measured 10,491 seconds for its dominant
69,515-byte output-body certificate. Its subsequent 1,619-second full wrapper
reused that object and therefore is not the total rebuild cost. This is a
retained earlier measurement, not a newly repeated cold baseline.

The candidate initially has a 43,931-byte recognizer body, a 15,834-byte helper
specification and a 10,645-byte helper body. Smaller source alone is not a timing
result. The measurement sequence is:

1. Build the integrated candidate once, recording migration and certificate cost.
2. Repeat with unchanged inputs to measure the cached build and fresh axiom audit.
3. Check that an output-body byte edit makes Lake refuse stale cached objects,
   then restore the exact source bytes and timestamp.
4. Add a useful retained comment to the production specification and measure its
   actual byte-certificate rebuild and the objects left untouched, together with
   a fresh audit and independent complete kernel replay using `--full`.

The comment probes preserve token meaning while exercising exact-byte
invalidation. The initial run already measures the changed output-body
certificate; an additional comment-only rebuild of that large file is omitted.
There is no separately timed isolated output-body or shared-helper edit. The
owner questioned the infrastructure cost during the seed run; the optional
helper-edit benchmark was dropped before it started. The twelve-source
dependency regression already exercises helper invalidation. One representative
real certificate rebuild plus complete validation bounds this experiment without
adding another performance project. The setup run includes
changed imports and cache migration, so its whole-run time is not a controlled
incremental-body speedup. The probes measure this partition's dependency
behavior and certificate cost, not all possible semantic edits. Changes to a shared Lean theory or an Ada
specification can still invalidate its genuine consumers. Fresh whole-environment
kernel replay remains separate work. Process-tree RSS is sampled once per second;
summed RSS includes shared pages and may miss short-lived peaks.

## Results

| Scenario | Build | Fresh axiom audit | Fresh kernel replay | Whole invocation |
| --- | --- | --- | --- | --- |
| Initial integrated build | 4,123.670 s | 2.754 s | Not requested | 4,131.318 s |
| Unchanged inputs | 1.856 s | 2.693 s | Not requested | 6.476 s |
| Production-specification comment edit | 657.219 s | 3.474 s | 1,334.103 s | 1,997.604 s |

The output-body certificate passed in 3,855 seconds (64.25 minutes), compared
with the retained earlier 10,491 seconds (174.85 minutes): about 63% less elapsed
time for that module. This is an observed historical comparison with different
workload contention, not a paired experiment or a universal speedup. The seed
includes migration and rebuilds all project modules. Its helper-specification
and helper-body certificates took 1,079 and 849 seconds; module times overlap
and must not be added to the whole invocation.

The unchanged run rebuilt no project modules and preserved all twelve
certificate object hashes, sizes and modification times. Lake configuration was
re-elaborated as intended. The actual output-body mutation, with its timestamp
preserved, made `lake --no-build` refuse stale objects. Exact source restoration
made the target current again, with the complete compiled-object inventory,
hashes and object timestamps unchanged. The specification edit's own certificate
took 342 seconds; dependent bridges account for the rest of its build time.
Independent comparison confirmed that the other eleven certificates retained
their exact hashes, sizes and timestamps, including the output-body certificate.
All twelve binding traces name exactly their own binary source dependency.

The fresh whole-project replay still took 22.24 minutes, compared with 21.53
minutes in the retained branching checkpoint. No replay speedup is established.
The final invocation took 33.29 minutes including the representative edit's
build; it is neither a cold rebuild nor an unchanged full-check measurement.

The seed's sampled peak summed process-tree RSS was about 13.2 GiB and its
largest sampled process about 4.82 GiB. Summed RSS double-counts shared pages;
these samples do not establish a controlled memory reduction from the earlier
point observation. The final run's corresponding peaks were about 8.70 GiB
summed RSS and 5.51 GiB for one process. The host retained headroom with the
existing resource settings.

Final native validation passed all 3,029 checks (412 flow and 2,617 proof),
covering 17 units, 216 entities and 14 imported entities, with 53 permitted
limitation notes. The full audit took 259.802 seconds with existing caches;
it was not a cold proof run. All 174 tests passed in 575.004 seconds, including
the twelve-source invalidation regressions. The final Lean build and fresh
audit cover 97 modules and 23,512 declarations, using only `propext`,
`Classical.choice` and `Quot.sound`. Native work overlapped the final Lean run,
so its wall time is not an idle-host benchmark.

## Evidence and remaining limits

Experiment records are retained locally under
`.silver/linux-x86_64/compartmentalization-2026-10-11/`, including the independent
baseline copy, native feasibility/differential records, source movement and
bridge review, dependency regression evidence and per-run measurements. They
are ignored artifacts; this checked-in record carries the measured outcome.

Independent source movement/bridge review and dependency integration review
passed. Native evidence was recalculated against current inputs, tools and
retained reports without rerunning proof or tests; that recalculation was by the
extraction author, distinct from the independent source review. Independent
corroboration of all three runs and restoration records also passed. The final
review rehashed current source, workspace, tools and complete compiled-object
inventories; checked fresh audit coverage, actual cache retention, dependency
traces, logs and native provenance; and found no discrepancies. Principal records
are `runs/*/result.json`, `body-invalidation/result.json`,
`native-final-review-final.json` and
`independent-evidence-20261011T015420.229698Z.json` in that local directory.

The changed-body certificate remains expensive. This work does not make full
source checking suitable for every experiment, measure every edit class, or
resolve the historical GNATprove `DOC_END` issue. GNAT Pro is untested. Keep
focused iteration and batched checkpoints; no further language capability,
certificate framework or hosted CI was introduced.
