# Independent review of frontend feasibility research

Review date: 2026-10-17. Frozen integration target: `2b47dd8e27`.
Reviewer: backend research agent, reviewing the separately authored frontend
lifetime/capacity work and root synthesis. My own new static-data continuation
and its probe bundle are excluded from this independent verdict.

**Verdict: no material finding. Publishable as a scoped research full stop,
not as a derived source-capacity rule or a universal compiler impossibility.**

I challenged the decisive two-chain argument against the complete pinned
`gcc/ada` source, rather than relying on the research prose or a C/backend proxy.
The pool and descriptor tables are private to Stringt. Ordinary semantic
concatenation appends character storage and records String IDs; its only sharing
is an existing left-operand tail. I inspected the entire Stringt implementation,
all qualified reset/release and unstore call sites, exported addresses and the
C accessors; the only external Mark/Release pair surrounds checksum scanning.
Generic Table.Release trims unused capacity and preserves logical values.
Stringt.Lock occurs after frontend processing and before Gigi. The C interface
provides reads and cannot supply an earlier collection path. No alternate
ordinary-compilation release/compaction route was found.

Independently parsing the witness confirms 2,481 bytes, 62 constants and 60
concatenations, with A30 = x^(2^30) and B30 = y^(2^30). Both are referenced and
have lengths below Integer'Last; the distinct contents cannot occupy overlapping
ranges in the contiguous Char_Code representation. Tail sharing within either
chain does not refute the lower bound. The final two values alone require 2^31
characters (8,589,934,592 payload bytes). Even the zero-based-index objection
fails because generic Table.Length is signed Int; extra original lexical/runtime
characters only strengthen the conflict. I checked the resolution, folding and
Constant_Value paths, with no optimization-level gate. This specimen is correctly
labeled hypothetical enlarged-fragment source, not current Silver admission.

I also traced Scng's `0E799999` path through exponentiation, its Mark and
Release_And_Save, multiplication by zero and direct-zero result. The large power
remains allocated; no scanner/parser mark reclaims it after a token. The exact
saved-digit arithmetic agrees with the record. These are retained-payload lower
bounds, not measured peak RSS or observed repeated-literal thresholds.

The source/recipe-to-installed-binary premise is explicit. In particular, the
931,307,812-to-2,328,269,530 growth expression is correctly separated from a native
failure claim: `-gnatpg` in the compiler build can suppress the checked conversion.
The structural pool obstacle does not require an exact unchecked-growth outcome.
The source-capacity record explicitly retains the missing closed all-construct
allocation model and does not disguise a conservative bound as the best tractable
rule. Wider/lazy frontend work and source-sensitive accounting are described as
unadopted alternatives, with Ada static semantics, source identity and producer
obligations preserved. The proposed research stop is conditional on the unchanged
pin and admitting the intended compositions, not all imaginable compiler designs.

Validation performed:

- `rg`/`sed` source inspection of Stringt, Table, types, driver, ALI checksum,
  scanner, Uintp, semantic resolution/folding, C header/bridge and source positions.
- Re-ran `frontend-lifetimes/audit.py` on the complete pinned extracted tree into
  separate scratch: all 2,490 Git blobs matched, 217 lifetime-token and 52
  mutation-token matches. All five regenerated inventory/arithmetic JSON outputs
  equal the published artifacts. This rechecks the lexical evidence; it does not
  turn manual name resolution into a mechanically verified call graph.
- Rehashed all 15 entries in the frontend evidence manifest; zero mismatches.
- Independent symbolic parsing/counting of the witness and final disjoint-pool
  arithmetic, retained in `backend-independent-frontend-audit/independent-checks.json`.
- Re-ran the read-only source-position reconciliation: all seven retained traces
  satisfy the inspected alignment recurrence; regenerated JSON equals the record.

No new compiler, application, GNATprove, Lean, full-suite or giant-object execution
was run for this review. No integration file, tool installation, GitHub record or
current language artifact was changed. Scratch evidence is retained at
`/tmp/silver-unbounded-continuation-20261017/backend-independent-frontend-audit/`.
