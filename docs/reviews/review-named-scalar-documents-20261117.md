# #392 final documentation consistency inventory — 2026-11-17

Reviewed integration worktree `tmp/named-arguments-392` at HEAD `56451e3ed`.
Selected setting: **GPT-6.1 Sol / Extra High**; live runtime identity is not
independently exposed. Scope was the current normative descriptions in the
eleven files named by the lead. No source/product/doc edits, tests, proofs,
rendering, GitHub writes or CLI-memory updates were performed. This report is
the thread's only new file. Complete native run `034048` and Lean run `040626`
were running according to the lead; this inventory does not attest their result.

## Correctness findings

**None found in the reviewed documentation.** No current scalar-call rule says
“positional only” or excludes named actuals. The remaining positional-only
operation/aggregate descriptions concern other existing constructs, such as
Integer Image and array initialization, and should retain their separate rules.
Historical dated pending/probe statements were not classified as current defects.

The following current descriptions agree:

| Rule | Exact locations |
| --- | --- |
| Fully positional, arbitrary fully named order, positional prefix/named suffix, every formal exactly once | `language.md:674`; `catalogue/silver.json:1438`; `catalogue/silver.json:1502`; `docs/scalar-functions.md:74`; `docs/scalar-procedures.md:178`; `docs/named-scalar-arguments.md:15` |
| Case-insensitive callee-formal labels, payload-only reads, selector/value-name collisions, no defaults/omissions | `language.md:681`; `catalogue/silver.json:1439`; `catalogue/silver.json:1503`; `docs/scalar-procedures.md:179`; `docs/named-scalar-arguments.md:18` |
| Same incoming state; no inter-actual refinement; pairwise distinct writable targets; no cross-actual target reads; range-checked copy-back independent of order | `language.md:655`; `language.md:663`; `language.md:689`; `catalogue/silver.json:1440`; `catalogue/silver.json:1505`; `docs/scalar-procedures.md:193`; `docs/assurance.md:175`; `docs/trusted-boundary.md:354` |
| Original source spelling/order preserved; formal-order semantics connected to written-order native updates by paired permutation and commuting writes | `language.md:694`; `docs/assurance.md:164`; `docs/assurance.md:179`; `docs/trusted-boundary.md:350`; `docs/named-scalar-arguments.md:114` |
| Unchanged source/expression budgets and source-derived storage | `language.md:708`; `catalogue/silver.json:1416`; `catalogue/silver.json:1691`; `docs/scalar-functions.md:107`; `docs/scalar-procedures.md:218`; `docs/named-scalar-arguments.md:114` |

The catalogue still has **4,096 source bytes, 64 expression operands and 63
source-wide operators**. The 585-slot formal/visited storage is source-derived;
the capability record explicitly rejects an additional author-visible count
limit and limits the stack inspection to local frame measurements
(`docs/named-scalar-arguments.md:167`).

The report figures agree across `docs/assurance.md:157`,
`docs/trusted-boundary.md:336`, `docs/scalar-procedures.md:235`,
`docs/named-scalar-arguments.md:148`, `docs/report-capacity.md:422` and
`docs/scalar-procedures-report-capacity.md:245`: **49,279,744 retained bytes** in
**67,108,864 bytes / 64 MiB**, leaving **17,829,120 bytes**. Runtime/null domains
remain 262,144 bytes. The named-association capacity extension explains why
selector bytes preserve each actual's delimiter/payload reservation and add no
report class/multiplicity (`docs/scalar-procedures-report-capacity.md:231`).
No report-envelope or diagnostic-policy increase is claimed. The withdrawn
`Hide_Info` experiment is accurately historical (`docs/named-scalar-arguments.md:151`);
`docs/trusted-boundary.md:363` states that diagnostic policy is unchanged.
These are consistency checks, not an independent source-policy/producer audit.

## Low-priority delivery completeness items

These are closing updates, **not pre-checkpoint correctness defects**:

- **`README.md:224`** describes the original scalar-procedure delivery as
  “positional nonaliasing calls” and has no separate #392 overview. It does not
  say “only.” At closeout, add the named/mixed function-and-procedure capability,
  link its delivery record and Named parameters sample, and retain unchanged
  alias/domain/copy-back qualifications. Do not attribute #392 evidence to #370.
- **`roadmap.md:1278`** likewise summarizes the supported scalar-procedure
  fragment with positional calls, and the current support table has no named
  scalar arguments row. At closeout add a precise named-arguments row with the
  driver and completed evidence, and reconcile that procedure summary. Keep
  broad functions/procedures and #11/#12 separate and unsupported.

The narrow stage-issue gap identified in the prior review is resolved by #393
according to the lead and the new links at `roadmap.md:48` and
`docs/named-scalar-arguments.md:10`; this thread did not re-query its live fields.

## Pending final-validation wording — preserve until evidence exists

| Location | Closing reconciliation |
| --- | --- |
| `language.md:3` | Replace implementing/validating wording only with the actual checkpoint/suite/review state and link final capability evidence. |
| `docs/assurance.md:187` | Replace pending complete native/actual-source checkpoints after their real successful audits, retaining the distinction from focused semantic checks. |
| `docs/trusted-boundary.md:363` | Update complete source/native validation state; preserve all frontend, source-preservation and environmental premises. |
| `docs/named-scalar-arguments.md:12` | Reconcile authorized-versus-delivered support at actual delivery. Preserve the dated owner selection and recovery boundaries. |
| `docs/named-scalar-arguments.md:137` | Add integrated source/Lean outcome when known; retain focused and failed-run history. |
| `docs/named-scalar-arguments.md:178` | Record exact complete native/Lean/build, whole-suite and final-review results separately. Native/Lean success alone must not imply the suite/review passed. |
| `docs/scalar-procedures-report-capacity.md:247` | Replace “when it finishes” with the actual completed capability evidence at closeout; keep numerical premises unchanged. |
| `roadmap.md:42` and `roadmap.md:51` | Reconcile current-work/not-yet-supported wording at delivery; retain #373 recovery and PR #385 hold. |

`docs/scalar-functions.md:3` and `docs/scalar-procedures.md:3` already distinguish
#392 validation from their original deliveries. `docs/report-capacity.md:422`
already carries the correct current envelope; no numerical or policy edit is
needed there. The existing source/catalogue grammar does not need another
association-rule edit from this inventory.

Follow the lead's selected sequence: use the real native/Lean outcomes, finalize
and freeze Rosetta promotion/render inputs, then run the one full suite. Keep
suite/final-review wording pending until those outcomes actually exist. Preserve
historical records rather than replacing their dated evidence claims.
