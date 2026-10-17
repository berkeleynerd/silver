# Unbounded programs feasibility result

Research date: 2026-10-17. Scope: [#107](https://github.com/berkeleynerd/silver/issues/107)
and [#108](https://github.com/berkeleynerd/silver/issues/108), authorized by
[PR #106](https://github.com/berkeleynerd/silver/pull/106), continued from
[PR #109](https://github.com/berkeleynerd/silver/pull/109).

**Technical conclusion: full stop before adopting the proposed source and
String domain with the unchanged pinned frontend. Independent review pending.**
The research establishes a concrete representation obstruction and compares
alternatives; it does not establish a sound replacement source rule, a supported
capability, or universal feasibility. Implementation #88–#94 remains Backlog.

## Finding and recommendation

GNAT's inspected String table cannot represent some short programs whose
individual Strings all fit within `Integer'Last`. Two constant-doubling chains,
one containing `x` and the other `y`, can each describe a String of length
`2^30`. The frontend's ordinary semantic evaluation materializes both. Their
distinct live contents require at least `2^31` character entries in a table
whose length and indices use signed 32-bit `Int`.

The [complete pinned-source lifetime audit](unbounded-frontend-lifetimes.md)
closes the earlier handoff's principal uncertainty: ordinary compilation does
not release or compact these values before it needs them. Tail sharing within
one chain does not let the two different final contents overlap. Backend
optimization happens after this materialization. The argument is derived from
source and exact arithmetic, **not a near-limit native failure experiment**.
The concrete specimen belongs to the proposed enlarged fragment, not today's
admitted Silver language.

This defeats the inference that a per-value bound of `Integer'Last`, enough
RAM, and a larger backend code model suffice for all intended compositions.
It does not prove that every compiler implementation has the same limit. Nor
does it justify selecting an arbitrary lower String bound.

The recommendation is to keep the intended domain on hold and make the next
owner-authorized investigation concern a semantics-preserving frontend with
wider or deferred storage. That direction addresses the demonstrated obstacle
and best matches the owner's preference for expansive admission. No suitable
replacement, complete patch design, or every-case tractability proof is
established here. This is a recommendation for further feasibility work,
not authorization to develop or adopt a toolchain.

If the owner instead retains the existing tool pin, the more promising rule
is source-sensitive capacity accounting. It could admit sparse large sources
while rejecting representations that exceed actual tool budgets. It would
exclude some otherwise individually legal large-value compositions, and its
complete soundness derivation is still absent. That is an explicit disposition
of the proposed domain, not a silent implementation detail.

## What #107 establishes

The [source-capacity record](unbounded-source-capacity.md) separates source
positions, line tables, nodes and slots, names and name characters, lists,
String headers and characters, Uint IDs and digit words, growth and lock
headroom. The nominal Uint code range does not provide roughly 1.5 billion
table entries: table-coded Uints have 100 million nominal IDs and a separate
digit-word budget.

The physical/virtual source-position recurrence is explicit and reconciles
with seven retained traces. For a range of extent `e`, the next aligned range
starts after `4096 * ceil((e + 1) / 4096)` positions. Its overhead is 1–4096,
including EOF and alignment. Virtual sources may share the template's text
buffer but consume distinct position ranges. `final Source_Last <=
2,147,479,551` is sufficient arithmetic headroom for the inspected alignment
and block-index increments; it is not a complete source limit or a measured
maximum. The [reconciliation](../evidence/unbounded-programs/feasibility-20261017/continuation/planning/source-position-reconciliation.json)
retains input hashes and the calculation.

Large numeric exponents also require semantic allocation accounting. The
scanner constructs `10^799999` while reading `0E799999`; it retains that power
during parsing despite the final numeric value being zero. The exact power
occupies 177,170 base-32768 words, excluding temporary work and headers. This
is a source-derived allocation fact, not a measured whole-process footprint
or a native repeated-literal failure threshold.

The missing obligation is a closed accounting of every reachable expansion
and allocation path for the whole admitted grammar and selected tools/runtime.
In particular, physical/virtual runtime closure, generated names, node copies,
checks, subtype expansion and phase-dependent temporary storage remain to be
bounded. No empirical multiplier or assumption that memory fails first fills
that gap. A research closeout at this full stop leaves these obligations on
the parent #91; it does not declare them solved.

## What #108 establishes

The [static-data continuation](unbounded-static-data-continuation.md) builds on
the [first pass's macOS and Linux observations](unbounded-static-data.md) and
adds three bounded Linux probes:

- The unchanged 1 MiB Ada constant-chain specimen and six current runtime
  source files compile, bind and link under both medium and large code models.
- A separate 1 MiB mutable-local specimen compiles to assembly under the large
  model and exposes stack allocation/copying rather than zero-fill globals.
- No generated application was executed, and no near-Integer'Last initialized
  Ada object was built.

The copied runtime retains today's 4096-value contracts. These direct compiler
probes establish linkage and code generation only; they do not validate an
enlarged-domain runtime or proof behavior.

Retained Linux C zero-fill probes already show that medium/large code models
avoid the small model's relocation failure. They isolate addressing; they do
not reproduce Ada semantic folding, initialized-data emission or stack use.
The new Ada links narrow that evidence gap at a small size, without proving
large-domain acceptance. Ordinary backend changes cannot repair the earlier
frontend representation obstruction.

The retained macOS C proxy's ADRP failure and rejection of the large code model
remain platform-specific evidence. Possible GOT/storage alternatives prevent
calling that an unavoidable aggregate-data ceiling. No new native macOS probe
was run; Linux is primary and macOS validation remains independent.

## Alternatives considered

| Approach | Evidence and implication | Remaining work or limitation |
| --- | --- | --- |
| Uniform source-byte envelope | Simple to state, but equal-length sparse and dense sources have different costs; tiny sources can describe huge values. | Requires every-phase worst-case bounds that are not derived. Conservatism alone does not meet the expansiveness requirement. |
| Source-sensitive capacity vector | Can count lines, syntax, semantic lengths/magnitudes and different fixed/runtime costs separately. Preferable if retaining this frontend. | Complete transfers and assurance still needed. It must restrict compositions that overflow the pinned representation; the owner must disposition that changed domain. |
| Checked existing frontend | Can detect capacity requests before unsafe arithmetic and improve diagnostics. | Checks alone do not enlarge capacity, establish explicit verified membership, or convert a build representation defect into physical exhaustion. |
| Wider or deferred frontend storage | Addresses the concrete materialization limit while potentially preserving the author's source and Ada semantics. | Requires new tool feasibility, interfaces/indices/counters audit, source/producer correspondence and validation; not established or started. |
| Medium/large backend code model | Works on the retained Linux zero-fill proxies and the new small complete Ada builds. | Helps address placement after semantic analysis; cannot remove frontend folding or prove all object/runtime paths. |
| Disable folding with `-gnatd.f` | Upstream explicitly describes seriously nonconforming behavior. | Not an acceptable established semantic repair. |
| Generate different author source or silently lower value limits | Could avoid some large objects. | Does not meet the authorized same-source/domain requirements and is not adopted. |

These comparisons identify plausible alternatives, not an exhaustive optimality
proof. No Oracle amendment is proposed. The actual solver-completion and
producer assumptions remain as stated in the [scope](../unbounded-programs.md)
and [trusted boundary](../trusted-boundary.md); frontend research cannot prove
them away.

## Evidence, validation and limits

The continuation ran on Linux x86_64 host `codex-silver`, distinct from the
first pass's Linux `nix` and macOS `mini.local`. Actual executable identities
and commands accompany the [backend continuation evidence](../evidence/unbounded-programs/static-data-continuation-20261017/identity.json).
The GNAT-FSF release recipe selects upstream GCC 16.1.0 for Linux. Relevant
sources were inspected at `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the
complete Ada subtree was checked against its Git blob inventory. This is
source/recipe correspondence, not a reproducible build or binary attestation.

The handoff archive was retrieved from its published PR artifact because it
was absent on this host. SHA-256
`04a0788ca41d72dddc35e902b6240c3a15b462a505ae159fc9c8e128fcfe471f` and all
340 manifest-listed files verified; no archived program was executed.
The earlier review's verification of 2,154 original research files remains
attributed to that review and was not repeated here.

Only three new bounded compiler probes were necessary. They ran sequentially
with wall/CPU, sampled process-group RSS and output guards; all succeeded and
no guard fired. Sampling can miss brief peaks. The evidence records actual
timings and scope. No GNATprove, Lean build/replay, full test suite, bootstrap,
giant initialized-data build or application execution was performed. Existing
successful evidence, failures, caches and other-host artifacts are preserved.

Source table-growth arithmetic is not mislabeled as a native exception.
Although the default String allocation recurrence reaches 931,307,812 and
then requests 2,328,269,530 entries, the frontend build's `-gnatpg` suppresses
Ada checks. The precise machine outcome is unestablished and is not needed
for the independent structural obstruction above.

## Review and delivery

Independent substantive review of the integrated result is pending. Before
publication as completed research, record its frozen target, findings and
dispositions here, validate links/evidence manifests/whitespace and read back
GitHub tracking. No implementation or goal completion is implied by review
of these documents.

The live harness goal for For loops and integers is already complete and was
not resumed or replaced. CLI memory is unavailable and was not updated; the
dated session memory and issue handoffs are the durable records.
