# Review: five finite current-language Rosetta samples (PR #228, cad254039f)

2026-10-25 UTC. Planning-agent review of the #226 delivery handoff, requested by the owner.

**Review target:** [PR #228](https://github.com/berkeleynerd/silver/pull/228), head
`cad254039f5f9bc6d0a9ddf870a4cf9321c87a58` (`feat/rosetta-finite-samples-226`, completing
commit, `Fixes #226`); implementation and independent-review target
`3aae49385f2c432faf2495d4d9ec177b0e852b7e` (`Refs #226`, samples and manifest only); base
`main` at `8002d5ac5508c7603dc411f7457b32c80f160245` (PR #227 merge). Mergeable, merge state
CLEAN, no reviews, no CI. Read-only review from a detached scratch worktree; nothing in the
shared checkout, the tmp/ worktrees or GitHub was modified.

**Reviewer:** Claude Fable 5.1 (Claude Code), one lead plus 38 subagents: five per-sample
fidelity checks (effort high), three lenses (evidence integrity and process/records at high,
next-construct research at xhigh), one consolidation agent, two refuters per consolidated
finding (evidence lens and requirements lens; effort by severity) and a completeness critic.
Measured from the agent transcripts: 433k output tokens, 2.27M cache-creation and 17.4M
cache-read input tokens, 466 tool calls, 36 min wall-clock (19:12 to 19:48 UTC); the lead's
inline checks are additional and unmeasured. No Lean, GNATprove, build, test-suite,
`silver compile` or `silver run` was executed. The lead ran `silver check` (admission only)
and the read-only `scripts/check_evidence.py` audit once, as a targeted check of one claim.

## Verdict

**No blocker. The five samples are correct and faithful; the evidence supports every
number in the handoff. Merge-ready as is; two low record items can follow in the next
planning PR.**

- All five programs satisfy their Rosetta tasks as written, implement exactly the approaches
  reconciled in PR #227, and are byte-identical in executable text to the reviewed planning
  prototypes except one explicit space in the literals output, as the record states. Every
  factual claim in the samples' comments was checked against language.md and holds,
  including "12! fits, but 13! is rejected", the base range 2 to 16, the exponent rule and
  "7#1#E3 is 343".
- Expected outputs were derived independently and match the manifest byte for byte for all
  five cases (14, 31, 82, 155 and 210 bytes). Policy-selecting capability tags are correct;
  the record's "Static"/"Assigned" labels agree with the manifest-derived policy.
- The handoff's numbers check out: 474 tests, 40 samples, 96 execution cases, zero failures,
  581 Lean inputs and 141 compiler inputs hash-matching the implementation commit, and
  non-overlapping ledger windows for the two new managed runs.
- The reuse of the 07:09/07:10 compiler proof and build is legitimate: compiler, proof,
  script and build inputs are byte-identical between 247cc5c205 and 3aae49385f (only
  tests/test_rosetta.py changed in between, in PR #227), and development.md permits reusing
  successful native checks whose inputs are unchanged.

## Handoff claims checked

| Claim | Result |
| --- | --- |
| 474 tests passed, 40 manifest samples | Verified: log digests match, `Ran 474 tests ... OK`, 0 failures/skips, `test_manifest_samples` ok, both symlinked-TMPDIR tests ok; 40 entries, 96 cases; test-function count 465 on main and PR (the +1 over 473 is PR #227's renderer test) |
| Complete Lean audit passed | Verified: run `20261025T144732-3f0c19eb35cc` in the ledger with the full command and 581 sources; 466 modules, 89,369 declarations, three foundations; all 581 inputs hash-match 3aae49385f; tool hashes match the pin |
| Retained native evidence freshly audited | Reuse justified (inputs byte-identical; 141-input digest 894b59a2... equals the 07:09 run's); the fresh `check_evidence.py` pass itself is self-reported with no retained output (L1) |
| Independent review found no issues | Recorded as a compliant row (GPT-6.1 Sol xhigh, 97 s, scope `-- samples/`, tokens unavailable); no reviewer artifact retained, as for #221 |
| Completing commit cad254039f, `Fixes #226` | Verified; 3aae49385f carries `Refs #226`; PR base is main |
| Language and capacity unchanged | Verified: diff touches samples/, docs/, README.md, language.md, roadmap.md only |
| Scratch preserved, worktree clean | Verified: `tmp/rosetta-finite-samples-226` at cad254039f with only untracked `tmp/` |
| Board and issues | #226 In review with milestone 6; #9, #222-#225 Done and closed |

## Findings

Severity: blocker = must not merge; medium = needs a fix or a filed issue; low = record
defect; info = judgment note or planning follow-up. Each finding was challenged by two
refuters; CONFIRMED means neither refuted it, PLAUSIBLE means one did.

### L1 — The fresh `check_evidence.py` pass is self-reported; no artifact of the run is retained (low, PLAUSIBLE; consolidated as medium, lowered by the lead)

`docs/evidence/rosetta-finite-samples/retained-native-evidence.json` lines 17-24 record
`fresh_audit_command`, `fresh_audit_result: "passed"` and `fresh_audit_exit_status: 0`
without a timestamp, stdout or ledger entry; the script prints one line and is not
ledger-wrapped; the untracked evidence builder in the PR worktree writes the result as a
literal. Mitigation: the evidence lens reproduced the audit's hash checks read-only (2,519
inputs, 77 reports, 129 src files, compiler hash) and found them all consistent; the
reused 07:09 run contains a ledger-recorded pass over byte-identical inputs. The lead's own
run of the audit from this sandbox fails only on the Python tool identity ("proof tool
changed: python"), which is a host difference, not a defect. Fix in a later PR: retain the
audit's stdout line, exit status, UTC time and worktree beside `native-audit-summary.txt`,
or make `check_evidence.py` a ledger-recorded managed run (planning follow-up).

### L2 — Milestone 6 is named by number only, without link or roadmap name, and its sole issue is labelled `type: follow-up` (low, CONFIRMED)

`roadmap.md` line 49 says "Milestone 6's technical delivery is complete" with no link, while
every other milestone reference in the roadmap is linked; the GitHub milestone's title
"Finite current-language Rosetta samples" appears nowhere in the repository, against
planning.md's "named as in the roadmap". Fix: name and link the milestone once in the
roadmap paragraph; close milestone 6 when #226 closes; optionally relabel #226 as a work
package. Bookkeeping for the planning agent.

### Info — judgment notes, no change required

- `validation.json`'s `limits` list does not state the harness bounds that define
  "finite": 10 s execution and 120 s admission/compile per sample (tests/test_samples.py
  and tests/test_silver.py). The record's semantic definition (full-range Integer sequence
  excluded) is honest; adding the figures would help a reader. The critic corrected an
  earlier candidate that cited 300 s, which applies only to a different test.
- `supplemental_renderer_inputs_sha256` has no stated purpose and was hashed from the native
  worktree rather than the commit; the values equal the commit's blobs and support the
  record's "no re-render needed" claim.
- The independent review scope `-- samples/` excludes the documentation and evidence commit;
  this review covers it. Same precedent as #221.
- The evidence builder script is untracked worktree scratch, as for #221.
- The PR branch's upstream is `origin/main` ("ahead 2"); harmless now, but a bare `git pull`
  there would merge main into the branch.
- GitHub's milestone counters read 0/0 although #226 is assigned; a GitHub lag, no action.
- The session-memory entry is a delivery-status entry rather than an owner decision; this
  follows the #9 precedent and claims no owner statement beyond the quoted instruction.
- Capability tags: the three concatenating samples carry both `concatenated_output` and
  `expression_output`/`string_expression`, where older entries carry one set; each tag is
  individually exercised and the suite enforces the policy-relevant ones.
- Dropped at consolidation as pure agreements: the two Lean timings measure different
  windows and are attributed correctly; "sole writer" is supported negatively by the ledger;
  the candidate-to-sample diff claim is accurate; policy labels match the manifest.

## Per-sample results

| Task | Verdict | Note |
| --- | --- | --- |
| Compile-time calculation | agree | Ada-static grouped product, printed at run time, limitations discussed in comments; all comment claims true; 10 of 63 operators |
| Loops/N plus one half | agree | Separate number and comma statements; final iteration skips the comma; output byte-exact |
| Enforced immutability | agree | Constants, immutable loop index, mutable copy; commented writes marked as explanation, not tests; constant-write and index-write probes are rejected at admission |
| Literals/Integer | agree | Bases 2, 7, 8, 10, 16 with both delimiters, separators, exponent, signed endpoints; comments correct (base 2 to 16, case-insensitive digits, exponent multiplies by the base, 343); one explicit space added before the negative endpoint |
| Minimum number of cells, N = 10 | agree | Same function as the captured FreeBASIC answer; each assignment interval fits the `0 .. 9` object without guard refinement; grid derived independently |

## Next construct: research result and decided recommendation

The handoff defers the next construct to a separate owner decision. The next-construct lens
analysed `rosetta/coverage.json` after PR #227 (1,576 candidates), read the unlocked tasks'
approach texts, probed admission for candidate programs, and sized the implementation by
inspection of `src/`, `proof/Silver` and the last two scalar deliveries. Scripts, tables and
candidate programs are retained in `tmp/review-pr228-20261025/next-increment-research/`.

| Construct | Tasks unlocked by it alone (upper bound; verified) | Demand across all candidates | Cost indicators |
| --- | --- | --- | --- |
| Integer division (`/`, `mod`, `rem`) | 10 (7 verified: Sum of first n cubes, Odd and square numbers, Department numbers, Josephus problem, Largest proper divisor, Mosaic matrix, Solve equations by substitution; Loops/Do-while needs `exit when`, Variable size/Get needs `'Size`, Smallest multiple needs a wider type) | 883 | Three new `Check_Result` functions beside add/subtract/multiply, operator table and word operators, Lean `Expr`/`Obligation` constructors with truncation and sign rules, source pins; one new accepted obligation class `VC_DIVISION_CHECK` in the report policy with its discharge argument; reuses the per-object range model unchanged; comparable to PR #76 |
| Scalar guard refinement | 0 by identifier; about 382 approach texts describe a guarded increment; makes Law of cosines and Square but not cube current-language programs | implicit | No grammar or check-class change; the refinement primitives already exist unused in `Silver_Scalars` and Lean `Interval.refine`; the cost is threading per-branch intervals through conditions, joins and loop heads in the recognizer and the Predicate* modules |
| Arrays | 7 (4 to 5 need only arrays; 2 also need refinement) | 1,102 | New type family, index obligations, aggregates; highest cost |
| Characters | 5 | 615 | New scalar type and `'Val`; small expressiveness |
| String building, Booleans, procedures | 5, 4, 3 | 1,021 / 936 / 1,251 | Need slicing or length objects; Integer flags already express two Boolean tasks today; calls and per-body proof |
| Static integer types, named subtypes, `@`, object Size clause, slice replacement | 1, 0, 1, 1, 1 | 1 each | Nominal typing or representation assurance for one task each |

Side results: Special pythagorean triplet is admissible today with an Integer `0 .. 1` flag
(probe accepted), and four division-set assessments carry inaccurate surfaces (Loops/Do-while,
Variable size/Get, Even or odd, FizzBuzz); both are planning re-tag items.

**Decided recommendation.** Open one milestone, "Scalar arithmetic completion", with two
ordered increments, each as the four development.md packages (scope and automatic-proof
design; native admission and regressions; universal and actual-source assurance; validation,
review and delivery):

1. **Interval-checked integer division.** Admit fully grouped binary `/`, `mod` and `rem` in
   the existing scalar expression grammar wherever an integer expression is admitted, under
   one decidable rule: the divisor's inferred interval excludes 0, and not (the dividend
   interval contains -2147483648 and the divisor interval contains -1); result intervals from
   endpoint analysis with Ada's truncation and sign rules; no guard refinement. Admission
   question: the existing `ADMISSION["integer-division"]` text in `rosetta/refresh.py`.
   Driver: Josephus problem (305-byte candidate; loop-index divisor nonzero by range; the
   loop-carried value is bounded by `mod`). Regressions: the six other verified tasks.
   Excludes `abs`, exponentiation, guarded mutable divisors, wider types, conversions.
   Obligations beyond the usual: extend the report policy, its Lean policy model and the
   report-capacity envelope for `VC_DIVISION_CHECK` with a discharge argument.
2. **Scalar guard refinement.** Path-sensitive narrowing of Integer intervals by scalar
   comparisons, with joins at branch merges and reset to the declared range at loop heads.
   It adds no grammar or check class and unlocks the counter idiom `Count := (Count + 1)`
   under `Count < Max`, which no current rule admits.

Arrays follow as the third increment. The lower-ranked options unlock one task each or none
and need nominal typing or representation assurance; named subtypes alone unlock nothing.
Neither increment needs an Oracle amendment. The only procedural step is the owner's
"proceed": no construct implementation is authorized, no `type: decision` issue is open, and
division sits at generated stage 6, so the departure from generated order must be recorded in
the roadmap and a new `type: stage` issue (planning agent).

## Follow-ups for the planning agent

- After merge: close milestone 6; name and link it in the roadmap (L2); retain or
  ledger-record the fresh audit (L1); optionally add the harness bounds to the limits list.
- On the owner's decision: open the "Scalar arithmetic completion" milestone and the
  integer-division stage issue with the scope above, record the generated-order departure,
  and re-tag the four inaccurate division-set assessments plus Special pythagorean triplet.
- Draft PR #147's title still says "strict and loose".

## Validation performed and evidence of this review

Inline by the lead: sample, manifest and log digests against `pr/228` blobs; ASCII,
whitespace and final-newline checks; independent derivation of all five expected outputs;
link and anchor resolution; `git diff --check`; 581 Lean input hashes against 3aae49385f;
ledger runs, worktrees, board and milestone state; test-function counts; the five task texts
and the numeral rules in language.md against the sample comments; `silver check` on the
candidate programs; one read-only `check_evidence.py` run (fails here on the Python tool
identity, a host difference). By agents: everything in the sections above, with two refuters
per finding and a critic that read every file in the 18-file diff, traced the 1,000-entity
figure to the 07:09 run's log, and confirmed from the 14:48 run's prepared inputs that the
suite exercised exactly the delivered sample blobs. Not performed, by owner rule: proof,
build, suite or kernel reruns.

Review inputs are retained under `tmp/review-pr228-20261025/` (host-visible, untracked):
`workflow-result-inner.json` (38 agents), `verify.py`, `check_links.py`,
`next-increment-research/` and this report.
