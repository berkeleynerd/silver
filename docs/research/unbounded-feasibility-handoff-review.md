# Independent review of the partial feasibility handoff

**Verdict: suitable for handoff; no unresolved blocking packaging defect found.**
This reviews the accuracy and usefulness of the unfinished research package,
not the scientific acceptance of a source-capacity rule or full-domain build
feasibility. Keep the handoff PR a draft, #107/#108 open for continuation, and
#88–#94 Backlog. Publishing this review does not authorize implementation.

## Scope and independence

Reviewed the [handoff](unbounded-feasibility-handoff.md),
[source-capacity checkpoint](unbounded-source-capacity.md),
[static-data checkpoint](unbounded-static-data.md),
[handoff index](../evidence/unbounded-programs/feasibility-20261017/handoff-index.json),
both compact evidence manifests, selected probe records and source excerpts,
the raw archive, and the associated scope/roadmap/session-memory deltas.
The reviewer previously challenged the nominal GNAT table accounting and
reported its Uint correction and secondary-storage obligations, but authored
neither research checkpoint, probe harness nor research evidence. No additional
compiler, linker, proof or application run was performed for this review.

## Findings and dispositions

The initial handoff text promised a separate raw archive without an accessible
locator or digest. That delivery gap is resolved: the
[tracked archive](../evidence/unbounded-programs/feasibility-20261017/raw-handoff.tar.gz)
and index provide the bytes, SHA-256, internal manifest and continuation entry.
The final branch documents and this review take precedence over earlier document
snapshots inside the archive. A successor can inspect the evidence without the
originating Mac's external drive. Actual execution still needs authorized host
access, and the package does not provide or imply credentials.

No further repair is required for handoff. In particular:

- **Incomplete status is explicit.** Neither checkpoint supplies a sound closed
  source bound, a justified most-expansive rule, full-domain feasibility, or a
  completed implementation checkpoint. The research issues remain unfinished.
  The scope links the partial work without adopting its candidates.
- **Authority is bounded.** The main-recorded research authorization is distinct
  from implementation approval. Continuation uses separate research issues and
  checks the live claimant. Neither parent package is completed or advanced by
  this publication, and a smaller capacity rule cannot silently be adopted.
- **Evidence classes remain separate.** C zero-fill proxies establish their
  measured relocation/linkage behavior; they are not admitted Silver examples.
  The 1 MiB Ada cases stop at assembly. Linux and Darwin observations, selected
  linker identity, source/recipe correspondence and source-to-binary attestation
  are distinguished. No executable was run according to the retained commands.
- **Counterevidence survives.** Linux medium/large-model success prevents calling
  small-model failure unavoidable. Darwin GOT/storage alternatives remain open.
  Frontend tail sharing is not confused with cumulative backend constants.
  String lifetime/release, numeric temporary lifetime, generic expansion and
  allocation growth remain named unfinished audits.
- **Continuation is actionable and proportionate.** The next work starts with
  pinned-source reasoning, complete phase/representation accounting and comparison
  of alternatives. Existing successful probes are retained. New experiments need
  a remaining hypothesis and appropriate guards; no full proof/test reruns or
  giant initialized files are required merely to accept or resume this handoff.

## Targeted challenges and remaining scientific questions

The historical Uint range was independently checked: it includes direct values,
whereas the nominal table-coded range has 100 million values. Names, String
characters, node slots, list links and Uint digit words have separate storage
and representation obligations. Generic table growth can require representable
allocation headroom beyond final logical counts. These support the need for
the proposed accounting investigation; they do not establish its complete cost
model or an exact observed failure threshold.

The reviewed scanner excerpt evaluates the positive exponent before multiplying
by the mantissa, and the exponentiation path preserves its computed result.
The mathematical digit count for `10^799999` is consistent with 177,170 radix-32768
digits. This review **does not establish retention across repeated zero-valued
literals**: enclosing marks/releases and later lifetime remain unclosed, as the
checkpoint correctly says. No repeated-literal probe was run.

Similarly, the two distinct live String chains and unsaturated growth recurrence
are source-derived challenges. The package explicitly leaves complete release
reachability and installed-binary correspondence unresolved before promoting
them to a closed derivation. A final recommendation must still address all
admitted compositions, same-source alternatives, actual build modes and external
assurance premises. Successful finite probes do not settle those questions.

## Verification performed

- Rehashed all **110** source-capacity and **136** static-data compact-manifest
  entries: every listed size and SHA-256 matched.
- Checked the raw archive: **1,902,657 bytes**, SHA-256
  `04a0788ca41d72dddc35e902b6240c3a15b462a505ae159fc9c8e128fcfe471f`.
  All **340** internally manifested files matched; the only additional regular
  file is the manifest itself. No special archive members were present.
- Reconciled nine source probes: all exited zero, none recorded a guard stop,
  total measured wall time 0.476089 seconds, range 0.041439–0.093610 seconds,
  and maximum sampled process-group RSS 17,504 KiB. These are measurements of
  the listed proxies, not current Silver admission evidence.
- Reconciled the 15 measured static-data records: eleven zero exits, four
  nonzero diagnostic outcomes and no recorded guard trigger. The invalid initial
  monitoring attempt remains separately disclosed rather than counted as a
  valid measured run. Sampled RSS and child maximum RSS are distinguished.
- Recalculated the String-pool growth sequence and its first unrepresentable
  next allocation, and independently checked the numeric digit-count arithmetic.
  Inspected the retained Linux selected-linker identity record.
- Checked local Markdown-linked paths in the three research documents and
  `git diff --check`; no missing linked path or whitespace error was found.
  No new network request or external mutation was needed for these checks.

## Limits and side effects

This is a static handoff review. It does not exhaustively audit the pinned
frontend call graph, prove allocation bounds, attest installed binaries to
source, rerun native observations, or independently re-fetch live board/PR
state. The parent must verify the actual draft publication and final issue
statuses, including that no closing keyword closes #107/#108. Recorded remote
access is historical evidence, not a promise that the successor's environment
has that access.

Only this review document was written by this reviewer during handoff review.
Other agents' documents, evidence, scratch, worktrees, caches and host artifacts
were preserved. No experiments, builds, proofs, kernel replay or full suites
were run. Review activity comprised reading, comparison and file/arithmetic
verification; no precise per-activity wall-time ledger or token-usage telemetry
was available. The handoff index and probe records retain recorded timestamps.
