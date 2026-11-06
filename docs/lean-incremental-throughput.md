# Incremental Lean throughput

## Authorization and order — 2026-11-06

The owner instructed **“Proceed”** with two ordered packages under
[#8](https://github.com/berkeleynerd/silver/issues/8) and
[milestone 17](https://github.com/berkeleynerd/silver/milestone/17):
[#327](https://github.com/berkeleynerd/silver/issues/327), matched four/eight
output line chunks with adoption if useful, followed by
[#328](https://github.com/berkeleynerd/silver/issues/328), bounded stable chunk
identities/cache reuse for ordinary edits. The
[dated memory](session-memory.md#2026-11-06--incremental-lean-throughput-work-authorized)
records authority; [roadmap](../roadmap.md#lean-source-parallelism) records order.
At the planning boundary both issues remained Backlog until authorization
reached main. PR #329 merged as `53ef5685a2`. The matched comparison now supports
eight chunks: #327 is In review pending the shared final checkpoint, and #328
is In progress with the bounded cache-reuse pilot below.

The implementation base is the open, reviewed
[PR #326](https://github.com/berkeleynerd/silver/pull/326), published completion
head `c062d5253e` and governed source `3f5d575635`. Its
[completed evidence](https://github.com/berkeleynerd/silver/blob/c062d5253e73ad066bf0309eeee505f51f8b0860/docs/lean-line-chunks.md#completed-production-validation--2026-11-06)
includes complete Lean/source validation and a critical review. Its descriptive
historical timing comparison is context, not a matched four/eight measurement.
New work stacks on that delivery and leaves its frozen inputs untouched.
Neither its merge nor a later implementation merge is authorized here.

## Full four-versus-eight comparison

Keep the existing certificate representation. Generate deterministic,
proportionally sized partitions of the same complete 4,915 line certificates
into four and eight independent modules. Preserve ordered line declarations,
literal text, tokens, newline presence, individual proof boundaries and the
whole-output source/token/lexer statements and actual-Ada transport. Keep the
existing reconstruction tree and predicate split; only required chunk imports
and references may vary with the partition.

Compare four Lake workers for four chunks against eight for eight chunks, with
identical automatic per-process thread settings. This explicit worker choice
is a measurement control under the existing automatic-CPU policy. Hold source,
tools, proof workload, common-import cache preparation and memory allowance
comparable; force the complete candidate line closure in each timed trial so
one side does not gain previously checked line objects. Separate line-check
cost from aggregator/reconstruction and whole-project cost. If a current host
constraint prevents the intended comparison, record it and resolve the resource
plan before treating results as matched.

Use isolated workspaces with normal managed leases/reservations, no live-cache
copy and no mutation of an active run's inputs. Size concurrent processes from
actual host headroom; a Lean memory threshold is per process and is not an
aggregate hard cap. Retain source/tool identities, generated-module inventory,
commands, cache state, managed run IDs, terminal outcomes, wall/CPU time, sampled
memory and competing workloads. Reuse prior successful evidence outside the
measured closure when applicable. This deliberate matched measurement justifies
the repeated full line workload; it does not justify unrelated expensive reruns.

Record whether eight chunks help enough to retain them, considering elapsed
work, memory, integration cost and comparability. If useful, integrate production
generation, module/runner registration and focused invalidation/coverage tests;
otherwise retain four and record why. The next package starts after this
partition/adoption disposition, without waiting for a new owner design choice
inside the authorized scope.

## Bounded stable-identity/cache pilot

Select the smallest useful design through a bounded pilot using the chosen
partition and existing generator, module graph, Lake artifacts and runner
protections. The pilot may evaluate content-based line names and eight fixed buckets,
including reuse of one identical line certificate for repeated source
occurrences; this is a bounded option, not a selected final design. Every source
occurrence still appears in the ordered complete reconstruction. Do not preselect
a general cache architecture. Inspect which identities and dependencies currently cause unrelated chunks to change or
rebuild, including positional names, boundaries and authoritative-source imports.
Measure actual retained bytes and proof objects rather than infer reuse from
unchanged names.

Exercise no-op generation, a local token edit, line insertion/deletion,
newline/CRLF changes and edits at a chunk boundary. Include restored timestamps
where existing source invalidation could otherwise be hidden. Record generated
bytes/module identities and changed/reused objects, dependency invalidation,
exact inputs, commands and terminal outcomes. Unchanged chunks may retain objects
only while the final assembly still accounts for every authoritative line/token
exactly once and in order. Preserve all individual checks, source/token/lexer
statements, reconstruction and actual-source transport for edited bytes.

Integrate a useful small design with focused regressions, or record the pilot's
limits and retain current behavior. Keep stale-candidate rejection, complete
pending-file publication, source/workspace stability checks and fresh imported
module/axiom auditing. Existing trusted-cache use remains explicit; no new
artifact-attestation or independent replay claim follows from a cache hit.

## Delivery and boundaries

Before delivery, pass one complete final Lean/source/module/axiom checkpoint on
stable integrated inputs. Establish complete native proof/build applicability or
refresh affected evidence, run applicable focused regressions and obtain an
independent critical review. This checkpoint may cover both packages when exact
final input applicability holds. Small edit fixtures and focused line builds do
not establish complete source correspondence. Retain failures as failed and
reuse still-applicable successful work under the existing
[proof-iteration workflow](proof-iteration.md).

Keep automatic CPU/thread settings for ordinary runs. Any smaller worker/thread
allocation must reflect the current workload or observed memory pressure and
be recorded for that run. Preserve other host/workspace artifacts. Record any
cache transfer between idle workspaces with matching source/tool identities;
normal dependency and fresh final-audit checks remain required.

No reconstruction representation changes, subtree split, reflection, broader
tactic/proof framework, general cache framework or persistent telemetry is
selected. #314 remains deferred and unchanged. Language, Oracle and required
assurance remain unchanged. Keep #8 and milestone 17 open for these packages;
At a later owner-authorized PR #326 merge, keep or reopen #8 through ordinary
issue bookkeeping despite its earlier `Fixes #8` trailer; do not rewrite the
reviewed implementation history. Routine planning/publication and planning-PR merge are authorized;
implementation merge remains a later owner decision.

## Planning round

Routine planning selected GPT-6.1 Sol / High; runtime settings were not
independently confirmed. The intended result is two scoped Backlog issues,
ordered requirements and a main-branch authorization record before claims.
This round prepared that reviewable documentation; it ran no proof, build,
test or benchmark and changed no governed implementation input. Token/cost
measurements are unavailable. No CLI recall was updated.

## Eight-chunk preparation and comparison — 2026-11-06

Candidate `ec2c6f474b` is integrated as `0f3076d3da`, stacked on PR #326.
The [independent static review](reviews/review-lean-incremental-throughput-20261106.md)
confirms all 4,915 ordered line declarations and the complete reconstruction
suffix are byte-identical to the four-chunk base; only the partition and four
required imports differ. Eight chunk sizes are 614, 614, 615, 614, 614, 615,
614 and 615. Runtime acceptance and adoption were pending at this preparation
boundary; the terminal disposition follows below.

Matched control `20261106T134724-a836b1157415` started at 13:47 UTC in the
isolated `tmp/lean-four-control` workspace. The eight-case integration workspace
starts from an independent copy of the same idle cache: all 630 common `.olean`
hashes match, and both cases force the line objects to rebuild. The old unmatched
measurement is not substituted for this control. Timed cases run sequentially
with no competing proof/native/test jobs; ordinary code editing and static review
can overlap. Both select automatic twelve-thread processes, a 6 GiB per-process
allowance and respectively four/eight Lake workers as the comparison control.

Implementation selected GPT-6.1 Sol / Extra High; critical static review selected
GPT-6 Astra / Extra High. Lead runtime settings and token/cost measurements are
unavailable. Static generation, Python syntax and whitespace checks passed;
tests and production Lean acceptance are not claimed by this preparation round.

## Matched result and cache design — 2026-11-06

Retain eight output line modules. Both full line-workload trials passed, and
the [independent assessment](reviews/review-lean-incremental-throughput-20261106.md#matched-measurement-and-adoption-assessment--1447-utc)
supports adoption. The [retained comparison](evidence/lean-incremental-throughput-20261106/README.md)
records 2,001.803 versus 1,341.952 seconds of wrapper elapsed time: **32.96% less**,
with **21.88% more CPU time** and sampled summed RSS rising from 5.20 to
7.57 GiB. This is one sequential pair on the same host, with identical common
objects and tools; it is not a whole-project speedup or repeatability estimate.
No concrete comparability gap warrants repeating the expensive measurement.

The #328 pilot uses eight fixed buckets and names derived from exact physical
line text. Identical text shares a checked line certificate; the existing
balanced reconstruction still names every occurrence in source order. A SHA-256
digest chooses a generated name and bucket only, never a proof fact. Ordinary
token edits can change at most two buckets, while inserting an already-present
line can leave all bucket source files unchanged. The authoritative binding,
reconstruction and dependent checks must still invalidate when source bytes
change. Actual proof-object reuse is being checked in the bounded edit fixture;
no full-workload reuse or final integrated acceptance is claimed yet.

Implementation and evidence retention select GPT-6.1 Sol / Extra High; the
critical comparison and generator review select GPT-6 Astra / Extra High.
Runtime-confirmed lead settings and token/cost measurements are unavailable.
The final source/module/axiom checkpoint and closing review remain outstanding.
