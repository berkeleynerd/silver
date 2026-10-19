# Native hook-claim correction review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119),
finding [#143](https://github.com/berkeleynerd/silver/issues/143).
**Accept the reporting correction at
`8b686a52e5618a20f39b13e3fb4108fe5a84ee5f`; no material findings.**
This resolves the misleading closure claim identified by
[review `144d7013b7`](review-why-native-collection-hooks-fae1a1ebd0.md).
It does **not** discharge four-hook null preservation or its underlying #119
obligation. Closing #143 is justified only as correction of that reporting
defect, with the substantive native obligation retained.

## Exact scope and disposition

I reviewed the complete seven-file correction from original author
`fae1a1ebd0be76b247eae0ad8778483dbdc71cd0` to the frozen target: the
[source note](../research/retained-why-native-collection-hooks.md), and the
[packet](../evidence/retained-why-native-collection-hooks-20261019/README.md)
changes to `README.md`, `check.py`, `result.json`, plus new
`pre-review-result.json`, `repair.json` and `repair-check.json`.
The earlier review's accepted raw ELF, load, zero-fill, linkage, source-body
and identified-anchor findings are reused. This is a focused review of the
retraction and preservation, not another native census or source-closure review.

The source note and README now explicitly withdraw the null-preservation
induction and removal of the four-hook condition. They correctly distinguish
a legitimate source access lowered through a shared machine base from forged
source-level mutation. Neither exact-address matches, finite anchor inspection,
standalone symbol identities nor absent dynamic relocations is presented as
excluding that compiled form. The example remains a missing-case form, not an
alleged setter in the selected image.

Initial zero-fill and the four known direct loads remain supported partial
facts. The selected `scanmult`, TM-clone, `stderr`, GOT metadata and AT_SECURE
results retain their concrete scope. The inherited reflection argument is not
recast as an answer to static lowering. The timing-hook API comment remains
a client obligation rather than a proof of unknown clients' behavior.

The current checker sets both `inspected_interface_null_preservation_claim`
and `native_ownership_closed` to false, names the unjoined static-client and
base-plus-offset relation, and retains null `complete_R` and
`exceptional_identifier_charge`. The retained current result agrees.
Its `status: pass` reports successful projection checks, not hook closure;
the accompanying flags and documentation make that distinction explicit.

Shape's buffer, formatter/printer, first-fold private cache and backward list,
including the **1,074-byte** growth and cache-miss implications, again carry
the four-hook condition. The original accepted save-preservation note remains
byte-identical and already states that condition. The two finalization hooks'
existing exclusion is preserved. Exception continuations, ordinary-ending
nested saves, later forest and exit/output effects remain open. The captured
66 roots, 966 binders, 315 insertion/reset bound and accounted endpoint 61,641
are unchanged; `counter_end <= 63,573 + 2R` remains conditional.

The repair's bounded inspection did not establish a complete relevant native
client/source relation or selected lowering restriction. It accurately reports
that negative result. Its proposed source/client or effective-address routes
are future proof questions, not new premises or completed work. The existing
source-reviewed external behavior policy is neither strengthened into opaque
non-aliasing nor replaced with a requirement to recover every historical build
input. No unsupported closure remains in the current changed claims.

## Exact preservation and checks

Independent byte comparisons against the original commit verified all seven
preserved or historical artifacts: `capture-binding.json`,
`code-projection.json`, `inputs.json`, `linkage.json`, `source-excerpts.json`,
`round.json`, and `pre-review-result.json`. The last is **exactly the old
`result.json`**, including its now-withdrawn positive flag and original timing.
The unchanged original round and historical result are explicitly marked
superseded in the current source note/README. Their positive historical fields
must not be consumed as the current conclusion.

The nine bounded-context identities and original review identity also match.
An exact textual comparison of `check.py` confirms that its only code change
is the returned claim fields: extraction, source pinning, image checks and
projection logic are unchanged. Current and historical result facts agree
apart from the corrected claim, explicit residual fields, the accurately false
`instruction_census_recomputed` flag and the new focused-check timing.

These independent hash/record/diff checks took **0.07369198701053392 seconds**.
The author's successful repaired default check at **1.553306039000745 seconds**
and narrow preservation check at **0.0018323399999644607 seconds** are reused.
The earlier **1,102,177-instruction / 4,986,162-byte** census and its original
**11.11612633599725 seconds** remain historical successful evidence. No packet
checker, predecessor evaluator, native target, compiler, disassembler, capture,
solver/prover, broad source scan or census replay ran in this rereview.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime model and
effort confirmation, token usage and monetary cost are unavailable.
Inspection ran **2026-10-19 12:07:53–12:08:43 UTC**, **50 seconds**, excluding
worktree creation, report preparation and commit; this is elapsed inspection
time, not measured model compute time. Host: Linux 7.0.14 x86_64.
Worktree: `tmp/review-119-native-hooks-repair-8b686a52e5`.
Only this report is committed; the correction and its evidence are unchanged.
The live subthread goal was null. No CLI/session memory or GitHub record was
updated. The lead retains integration, issue and publication ownership.
`git diff --cached --check` passed before the report commit.
