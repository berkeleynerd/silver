# Independent backend and synthesis review

Date: 2026-10-17. Reviewer: `/root/unbounded_frontend`.
Frozen target: `2b47dd8e27` in the research integration branch.

**Verdict: no blocking finding; publishable as a research full stop after the
two low wording corrections below.** Both corrections were subsequently read
back in the integration worktree diff and are satisfactory. No new compiler,
proof, test-suite or application run was performed for this review.

## Scope and independence

Reviewed `docs/research/unbounded-static-data-continuation.md`, its associated
static-data continuation evidence, `unbounded-feasibility-result.md`, and
`unbounded-source-capacity.md`. Challenged the scope of the full stop, code-model
alternatives, narrow probe claims, the distinction between missing capacity
proof and impossibility, and the recommendation for further toolchain research.

The reviewer authored `unbounded-frontend-lifetimes.md` and its lifetime evidence.
**This note makes no independent-review claim for that record or its argument.**
The backend/synthesis review treats that argument as an explicitly identified
dependency assessed by another reviewer.

## Findings and dispositions

1. **Low — overstated compiled runtime scope.** At frozen result-record lines
   92–93, the specimen “and six current runtime source files compile, bind and
   link” implies all six compile. Both retained `stderr.txt` logs compile
   `main.adb`, `silver_io.adb`, and `silver_output_libc.ads`; six runtime files
   were copied. The backend detail already distinguished these facts correctly.
   **Fixed:** the result now says the specimen compiles/binds/links using the
   unchanged snapshot, six files were retained, and imported units compile.
   The reviewer read and accepted that exact integration diff.

2. **Low — premature proposed-membership wording.** Frozen result-record lines
   29–30 say the specimen “belongs to the proposed enlarged fragment,” although
   its source-capacity rule remains unselected. **Fixed:** the result now says
   it uses the proposed constructs and value bounds, subject to that rule, and
   is not currently admitted. The reviewer read and accepted the integration
   diff. This correction does not alter the obstruction to admitting all such
   compositions with the unchanged representation.

## Verification performed

Read-only `git show`/`git ls-tree` against the frozen target, Python SHA-256 and
tar member reads, retained diagnostics/ELF-output inspection, and pinned-source
inspection established:

- All 54 static-data continuation bundle files match their manifest.
- All 60 raw archive files match the archive manifest.
- Every recorded probe input matches its raw retained input hash.
- All 18 runtime copies (six in each probe) equal the frozen authoritative
  runtime source files.
- The medium/large link specimens equal each other and the original retained
  Ada specimen byte-for-byte.
- All eight installed-tool identities match their recorded hashes.
- All five upstream source snapshots match retrieval sizes/hashes; the available
  source excerpts match their exact lines. The retained `decl.cc` and `trans.cc`
  also match the separately retrieved, pinned Ada source tree.
- The complete mutable assembly contains `subq $3145760, %rsp`.
- Both retained linked-image `readelf` records identify DYN PIE executables and
  `.lrodata` as initialized PROGBITS of size `0x1e0018` (1,966,104 bytes).

These checks confirm retained evidence, not a fresh compilation or executable
test. Exact compiler/readelf/excerpt whitespace is raw evidence rather than
authored prose.

## Assessment

The source-capacity record leaves whole-grammar allocation transfers and the
expansiveness comparison unresolved; it does not turn a missing proof into a
claim that no sound rule exists. The backend recommendation treats the large
code model as a candidate backed by the measured paths, with runtime/archive,
very-large-section and frontend obligations still explicit. The small Ada links
do not purport to prove the enlarged runtime contracts or universal backend
acceptance. macOS evidence remains platform-specific and bounded. The proposed
next toolchain investigation is described as unstarted feasibility work, not
an authorized implementation or demonstrated tractable redesign.
