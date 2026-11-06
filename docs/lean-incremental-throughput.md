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
Both issues remain Backlog until authorization is on main, before a claim or
implementation. This record reports no new benchmark or implementation result.

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
