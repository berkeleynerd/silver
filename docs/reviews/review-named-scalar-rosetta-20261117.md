# Named scalar arguments #392 — bounded Rosetta review

Reviewed 2026-11-17 against worktree `tmp/named-arguments-392`, HEAD
`f4ed7cd513047df7c8a24c04b3fd107ee704db1c` and its current Rosetta draft.
Selected reviewer setting: **GPT-6.1 Sol / Extra High**, as confirmed by the lead;
live runtime identity is not independently exposed. Read-only review and
in-memory progression inventory only: no tests, proof tools, rendering writes,
GitHub writes, support promotion or CLI-memory update. This report is the only
file written by this thread.

## Findings

1. **Low — the generated Named parameters page is stale.**
   `rosetta/n/named-parameters/silver.md:3` still says sample execution is pending,
   while `coverage.json` now records the focused proof/build/audit/output success
   in run `20261117T030042-d612d38a0399`. Comparing the generator output in memory
   finds only this task page out of sync with current source records; the
   progression matches. Fix the source records as needed, then render; do not
   hand-edit the generated page. The assessment record at
   `rosetta/assessment-named-scalar-arguments-20261117.md:31` should also distinguish
   the already-passing focused sample from pending complete feature assurance.

2. **Medium — the precise construct has no stage issue.**
   `docs/planning.md:201` requires a `type: stage` issue when a stage becomes a
   near-term target, with Constructs and Stage recorded. The live type-stage
   inventory contains #9, #10, #11, #12, #229, #234 and #341 only. #392 is the
   milestone-25 work package, not a stage issue. Create/link a separate narrow
   stage issue for `named-scalar-arguments` at promotion, and record its final
   Stage 1 / completed status with the delivery evidence. Do not relabel #392 or
   close broad #11. If project fields remain unavailable, put the exact stage
   mapping and the access limitation in its body; field reconciliation remains
   unverified, rather than silently claimed complete.

No task-faithfulness or selected-scope defect was found. The cached task
revision 411871 explicitly requires a function and visible binding independent
of order; defaults/omissions are optional. The noncommutative `Subtract` sample
meets that requirement, demonstrates positional/reordered/mixed calls and makes
swapped binding observable. Integer bounds and the four manifest output lines
are consistent, including Image spacing. Procedure mode/alias behavior belongs
in the dedicated regressions and requires no second Rosetta task reassessment.

Only **Named parameters** differs between HEAD and current coverage tasks;
policy and `supported` are unchanged. The original date/revision/rubric/tier/
`claude-opus-5-5`/high attribution is preserved, with separate dated Astra/XHigh
review metadata. Keep those historic settings; this Sol review supplements them.
The assessor/refresh descriptions accurately capture both selected functions and
procedures, unique complete matching, label-only selectors and unchanged
payload/alias/copy-back rules. Their present-tense support wording is a prepared
delivery edit while complete assurance remains pending.

## Final promotion and render plan

After complete stable-input native/build/Lean/actual-source/module/axiom and
regression assurance, plus independent acceptance:

1. Add only `named-scalar-arguments` to `coverage.json` `supported`. Keep broad
   `procedures`, `functions`, `integers`, `ranged-subtypes` and `scalar-image`
   unsupported. Preserve all other task assessments and historic attribution.
2. Reconcile the current Named parameters summary, review method/status and
   assessment record with actual final evidence. Replace current prepared or
   pending claims, preserve failed/focused-run history, and link the complete
   capability record. `docs/planning.md:224` explicitly requires this check.
   Recheck `assess.js` against the delivered rules and synchronized language,
   catalogue, sample and capability records.
3. Run `python3 rosetta/refresh.py --render` once from these final source records.
   This is a cached render; no corpus download or unrelated reassessment is
   needed. Run the existing focused Rosetta regressions through the managed
   workflow after the final inputs settle; this review did not execute them.
4. Reconcile the narrow stage issue, broad-stage mapping comments, roadmap and
   all open/closed stage fields. Stage numbering is generated and does not
   authorize a successor. Link the final render/evidence and report project
   field access accurately.

## Expected inventory

The following is an in-memory application of the existing pure progression and
assessment functions, not a performed support change or test result.

| State | Stage-1 mappings | Total stages | Named parameters |
| --- | ---: | ---: | --- |
| HEAD | 84 | 44 | rank 86, stage 2 |
| Current unpromoted draft | 84 | 45 | rank 1575, stage 44 |
| Final precise promotion | 85 | 44 | rank 66, stage 1 |

All states have 1,576 candidates and 1,782 assessments. The current tracked
Rosetta draft changes 1,491 task pages plus the listing, progression and three
source files: 1,496 tracked files, plus the new assessment record. Only Named
parameters has substantive task-page content changes; the other 1,490 task
pages change rank/stage text. That large interim churn is explained by the new
identifier remaining unsupported, not by broad reassessment.

Final promotion predicts **21 task-page changes against HEAD**, plus the two
aggregate generated pages and three source files: 26 tracked Rosetta files,
plus the new assessment record. Pending/status edits affect Named parameters
only and do not change that count. The 21 task-page changes are:

| Task | HEAD rank → final rank | Final stage |
| --- | --- | ---: |
| Named parameters | 86 → 66 | 1 |
| Special pythagorean triplet | 66 → 67 | 1 |
| Sieve of Eratosthenes | 67 → 68 | 1 |
| Common list elements | 68 → 69 | 1 |
| Greatest common divisor | 69 → 70 | 1 |
| Sum multiples of 3 and 5 | 70 → 71 | 1 |
| Multiplication tables | 71 → 72 | 1 |
| Array concatenation | 72 → 73 | 1 |
| Sort an integer array | 73 → 74 | 1 |
| Sorting algorithms/Bubble sort | 74 → 75 | 1 |
| Sum digits of an integer | 75 → 76 | 1 |
| Naming conventions | 76 → 77 | 1 |
| Selectively replace multiple instances of a character within a string | 77 → 78 | 1 |
| Happy numbers | 78 → 79 | 1 |
| Draw the Empire State Building | 79 → 80 | 1 |
| Additive primes | 80 → 81 | 1 |
| Attractive numbers | 81 → 82 | 1 |
| Coprimes | 82 → 83 | 1 |
| Elementary cellular automaton | 83 → 84 | 1 |
| Least common multiple | 84 → 85 | 1 |
| Law of cosines - triples | 85 → 86 | 2 |

## Stage-issue reconciliation

| Issue | Final Stage | Status/scope |
| --- | ---: | --- |
| #9 | 1 | Closed/Done; preserve original sample-delivery scope |
| #10 | 1 | Closed/Done; precise integer/loop/Image delivery |
| #229 | 1 | Closed/Done; interval integer division |
| #234 | 1 | Closed/Done; scalar guard refinement |
| #341 | 1 | Closed/Done; scalar functions |
| #11 | 2 | Open/Backlog; broad forms remain unsupported |
| #12 | 3 | Open/Backlog; broad arrays remain unsupported |
| New narrow named-scalar-arguments stage issue | 1 | Close/Done only with completed #392 delivery |

Both #11 and #12 bodies already say stages **2** and **3** respectively and
link a fixed October 25 render; neither has a wrong final stage number. Their
copied task lists/counts are historic. October 31 comments explicitly designate
those lists as historical and the progression as authoritative. #11 also has a
November 15 reconciliation comment preserving Stage 2 after Return multiple
values moved to Stage 1. Therefore dated delivery comments linking the final
render are sufficient for the new rank/sample reconciliation; no rewriting of
historic lists is necessary. Record #11's remaining single driver, Law of
cosines - triples at rank 86; #12 remains eleven samples at ranks 87–97.

Actual project Stage/Constructs/Status fields could not be inspected:
`gh project item-list` and a direct read-only GraphQL query both refused access
because the injected token lacks `read:project`. No field or board update is
claimed. Issue state/labels/bodies/comments were readable and inspected. This
access limit does not prevent preparing the precise delivery records.

## Lead disposition

The narrow stage record is now [#393](https://github.com/berkeleynerd/silver/issues/393),
created while complete assurance remains pending. Its body records the precise
construct, promotion target and unavailable project-field access. The final
generated-status repair and promotion will follow successful native/Lean
assurance; those final Rosetta inputs must then be frozen for the complete suite.
No extra pre-promotion full suite is required or claimed.
