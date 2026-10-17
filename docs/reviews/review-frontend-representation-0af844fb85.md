# Review of frontend representation research

**2026-10-17 — independent review for #113.** Technical target:
`0af844fb85b48155b38f237a5437bc27f71e8563`. Supplemental planning/handoff diff:
`d92ec26a5969c74a9aa39c6a267c9422628a1d61`. The reviewer did not author the
research records. Review ran in the separate
`tmp/frontend-representation-review` worktree on Linux x86_64.

## Verdict

No blocker or medium finding. The comparison provides concrete component
representations and interfaces, a justified implementation stop and an actionable
owner disposition within #113's research-only scope. It does not establish a
larger supported language or authorize implementation. One low documentation and
evidence-location defect, L1 below, should be repaired before publishing the
reviewed research result.

The preferred widening candidate is supported as the smaller frontend change,
not an end-to-end tractability result. Both candidates leave the inspected
GNATprove producer expansion and incomplete whole-program capacity accounting.
The full stop is a lack of a demonstrated permissible complete route, not a
proof that SPARK implementation is impossible or that every fork requires an
Oracle amendment. The result explicitly preserves these distinctions.

## Finding L1 — wrong emission-path citation and excerpt (low)

At the review target,
[the deferred record](../research/frontend-deferred-storage-feasibility.md)
line 192 cites `varasm.cc:5628–5635` for the optional String terminator increment.
The retained `selected-source-ranges.json` lines 288–290 select `5620–5642`, and
`selected-source-excerpts.txt` faithfully reproduces that range. In exact GCC
commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, those are integer/vector
emission lines, not the claimed String path.

The technical concern is real in the retained complete file: `varasm.cc:5652–5659`
sets `thissize` from `TREE_STRING_LENGTH`, conditionally increments it for
`merge_strings`, then passes it to `assemble_string`. The latter's parameter
is `int` at line 2313. At length `2^31 - 1`, the incremented wide size does not
fit that parameter. This confirms the conditional source arithmetic concern;
it does not establish reachability under the selected Ada flags or a native
failure, and the research correctly makes neither claim.

Repair the document reference, select an excerpt containing `5646–5663`, and
regenerate the dependent excerpts/manifests and their hashes. State that the
incremented size does not fit the `int` parameter, rather than implying that
the wide `thissize` addition itself overflows. No compiler or large-value probe
is needed for this correction.

**Original disposition:** open when this report was first committed. Any repair
and verification are recorded separately below; the original finding and target
remain unchanged.

## Claims independently checked

| Claim | Assessment and limits |
| --- | --- |
| Local widening is concrete | The pinned `Stringt` package uses `Int` character offsets/counts and the compiler `Table` body hardcodes `Int` arithmetic. The record identifies both, the descriptor/C ABI, aliasing and allocator conversions. Changing only the generic actual would be insufficient. |
| Derived 64-bit pool bound | `99,999,999 * 2,147,483,647 = 214,748,362,552,516,353`; payload bytes, bit size and the stated one-past view fit the proposed scalar arithmetic. `String_Id'Base` does not enforce the nominal descriptor domain. The text explicitly requires checked descriptor allocation, in-flight reservation, source accounting and array/host support rather than treating the multiplication as an existing capacity guarantee. |
| Growth invariants | For `0 <= old < requested <= P`, the proposed max/min rule advances, covers the request and stays at most P. `5P` and `old + 10` fit signed 64 bits. The warning about multiplying by 250 before division is valid. Logical storage, transient physical memory and cumulative work remain distinct. |
| Zero-mantissa optimization | The pinned scanner constructs the power before multiplication. A zero fast path inside the existing semantic-computation branch, after the exponent diagnostic, avoids that construction while preserving syntax-only and real-literal paths. No implementation or semantic proof is claimed. |
| Deferred builder semantics | Roots reference immutable roots rather than mutable String IDs. The current descriptor remains writable; flushing a chunk is separate from sealing a descriptor. This correctly accounts for `End_String` merely returning `Strings.Last`, captures self-aliasing before mutation and states rollback/lifetime obligations. The existing `Unstore_String_Char` callers are scanner error repair. |
| Deferred size and complexity | The two-chain representation can share two leaves and 60 equal-height concatenation roots. The counts are explicitly symbolic and exclude unrelated descriptors, tokens, spare capacity and downstream materialization. Balanced joins, cached lengths and cursors support the stated asymptotics; exact equality still may traverse all characters. |
| Raw ABI and backend boundary | Current C readers directly index the exported pools. An opaque accessor/cursor interface requires coherent Ada/C changes; it cannot be installed as an old-layout object replacement. The retained GCC constructor takes unsigned length and stores signed length, so the appended NUL alone is not an overflow at the stated Character endpoint. The separate emission caveat is valid, subject to L1's citation repair. |
| Separate GNATprove frontend | The retained release recipe selects floating `fsf-16` sources and copies GCC Ada sources into `gnat2why/gnat_src`. Changing `gnat_native` alone does not update that frontend. The inspected branch snapshot is expressly not asserted to be the installed archive's exact source. |
| Producer identity obstruction | The exact inspected `Transform_String_Literal` path constructs one fresh comparison call per Character. The builder appends to a vector indexed by `Why_Node_Id`, whose nonzero identity space has `2^30 - 1` entries. A fresh length-`2^30` literal reaching this path requires more comparison identities than available, before its other nodes. The cache and wide-character branches do not refute the conditional claim. No near-limit tool failure is asserted. |
| Available alternatives | The negative conclusion is confined to the inspected pinned GCC components, bounded history, Alire index, GNAT LLVM source route and SPARK snapshots. It is not a claim about all vendors, all patches or every external solution. The GNAT LLVM route does not replace the earlier Ada frontend phase. |
| Ownership and next action | Oracle lines 24–28 and the trusted-boundary opening require verification of Silver-owned implementation bodies and separately trust existing external tools. The result does not grant a fork exemption, infer an inevitable amendment, authorize maintainer contact or silently select a lower domain. Actual maintenance responsibility remains a stated question. |

The synthesis's producer and ownership stops therefore survive independent
inspection. Seeking an actually externally maintained paired frontend/producer
route under the unchanged Oracle is a permissible recommendation. This does not
claim that such support exists or guarantee acceptance by an upstream project.
The all-SPARK alternative remains allowed in principle but unestablished here.

## Evidence and scope verification

The review inspected the four technical records, their evidence instructions and
selected pinned source paths, the Oracle and trusted boundary, authorized scope,
current development/roadmap/session records, and live #113/current milestone and
open decision issues. The supplemental planning commit consistently leaves
review/publication pending and implementation #88–#94 unauthorized. Updating that
pending wording after actual review/publication remains normal delivery work.

Checks performed:

- The packaged toolchain verifier passed: 420 archive members, 320 SPARK Git
  blobs, 16 contents-source Git blobs and 37 API retrieval records.
- The wider-storage audit rechecked its 20 selected source files and reproduced
  `source-recheck.json`, `derived-arithmetic.json` and
  `uintp-offset-inventory.json` byte-for-byte.
- An independent short checker verified the 9 wide and 14 deferred manifest
  members, all four complete GCC emission-source payloads, and exact reproduction
  of all selected deferred excerpts from the retained sources. The excerpt
  check confirms byte integrity; L1 demonstrates why that alone is not enough
  to validate source relevance.
- All 23 local file links in the four technical records and two evidence READMEs
  resolved. `git diff --check` passed for the technical delivery against its
  authorization base.
- The technical diff has 34 added files, all under `docs/research/` or
  `docs/evidence/`. The supplemental diff changes only four planning/handoff
  documents. No production compiler, runtime, proof, catalogue, sample, pin or
  Oracle change was introduced.

The complete 2,490-file Ada-tree audit was not repeated; its retained inventory
was reused, with relevant source and evidence bytes checked directly. No compiler
build, application execution, GNATprove/Lean run, test suite, native capacity
probe, macOS validation or CI run was performed. The review did not change
GitHub issues, board entries, tool installations or a harness goal. Scratch
checker/output files remain at
`/tmp/silver-frontend-representation-review-20261017/`.

## Delivery recommendation

Correct and verify L1, then publish this research and review as #113's completed
research result. Leave implementation #88–#94 and milestone 5 incomplete, and
report the concrete ownership/producer disposition to the owner. Preserve the
unresolved source-capacity and backend obligations in that handoff; no new
implementation or open-ended follow-up is implied by research completion.
