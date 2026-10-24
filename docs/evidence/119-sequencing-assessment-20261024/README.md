# Independent assessment of % completion toward #119 (2026-10-24, after R92)

_Record note (2026-10-24): produced by the planning agent (Claude Fable 5.1, Anthropic) in a sandbox session; copied here from the session's `tmp/119-completion-assessment-20261024/`. `MATERIALS.md` indexes the session's local copies of GitHub issues, PR #121 files at f1920759b1 and repository documents; its absolute `/tmp/...` paths are the session scratch directory and do not resolve outside it. `workflow-result.json` holds the twelve assessment agents' structured outputs; `redteam-sequencing-result.json` the three sequencing red-team outputs; `restart-inventory-20261024.md` is a verbatim copy of the harness's pause inventory from the integration worktree. Assessment agents ran on Anthropic models (2,342,630 + 555,452 subagent tokens reported by the workflow runner), separate from the OpenAI plan the counters below measure._

Question from the owner: "Please determine the approximate % completion toward 119."

## Verdict

**Approximately 50% complete toward #119's stated completion criteria (plausible range 40–65%).**
The repository's own figure is "approximately 85%, low confidence" (constant since R69, 2026-10-23 19:27 UTC).
The two numbers measure different things: the self-estimate counts closed component obligations; this
assessment measures distance to the issue's completion criteria (a concrete computable rule with complete
phase/construct coverage for the intended current Silver grammar, stated assumptions, soundness argument,
structure-sensitive vs conservative-envelope comparison, independently reviewed). Production adoption under
#88–#94 is not part of #119 and is not counted.

## Method

Twelve agents over saved evidence (issue #119 body and 105 comments, 12 child issues and their threads, 73 open
findings, PR #121 head f1920759b1 = R92: capacity contract, Round 47 stop report with its 11-row whole-goal audit,
round ledger R1–R76, round records R29–R92, in-progress children's research notes, roadmap/RESUME diffs, the
owner-pause restart inventory tmp/retained-tool-capacity/tmp/active-119-checkpoint.md).

| Stage | Agents | Output |
| --- | --- | --- |
| Map | 5 readers | requirement matrix (21 rows), child inventory, estimate trajectory, finding churn, blockers |
| Estimate | 4 lenses | coverage 43% [33–55]; effort-weighted 57% [46–66]; risk-adjusted 51% [40–63]; steelman of 85% → 60% [45–75] |
| Verify | 3 adversarial checkers | 135 claims: 0 refuted, 102 confirmed, 33 partly (minor corrections listed below) |

Full agent outputs: `workflow-result.json` (maps, estimates, verifications). `MATERIALS.md` lists the evidence set.

## Why the self-reported 85% is not supported

1. Nine of twelve children are technically complete, but they are the narrow or fixed-input pieces (#145
   declaration-free literal-output native graph ≈ R1–R24; #153 five captured Why processes ≈ R25–R78; short Main
   interfaces #178/#185/#186/#193/#194/#206). The three open children are their source-parameterized
   generalizations: #201 (native capacity for the whole current grammar), #202 (arbitrary-Main Why storage and
   failure lifetimes), #212 (fixed-report configuration incl. a GPR/Gprconfig/GPR2/KB family first named at R91).
   Each is ~30–35% done by its own recorded residual list after 7–10 rounds.
2. Every parent-only completion step is unstarted or barely started: whole-rule computable predicate and checked
   composition/correspondence ("No complete conjunction for the intended domain exists"), useful-domain comparison
   (#212 records the generic envelope gives flow ≥ 56·E³, i.e. unusable as-is), final independent whole-rule review
   (≈220 component review reports, zero whole-rule reviews).
3. Two obligations are closed only by premise or by a not-yet-adopted design: complete solver output q/O for the
   stock CVC5 route is recorded as unproved and was redirected (R48–R73) into a prospective quiet/pipe adapter route
   that unstarted #88 must realize; no record after R73 mentions it. Source/installed-tool correspondence
   (SPARK snapshot vs installed archive) is "not established" and kept as a reviewed premise.
4. The 85% behaves as a ratchet: four upward steps (70→75 R23, →80 R24, →~82 R28, →85 R69), never down, then flat
   for 24 rounds while nine child packages and 50 of the 73 open findings were created (10-23/24). The harness
   itself labels it "low confidence", "not an ETA", "not inferred from packet/check counts".
5. Review churn is steady, not converging: in R83–R92, 8 of 10 rounds surfaced a material defect in author packets,
   and at least four defects (#207, #209, #216, #217) were in claims that had already been independently accepted.
6. Four author packets left at the 10:08 UTC pause are unreviewed (one failed its first focused check) and are not
   counted; R93 integration of whatever passes review is the first step on resume.

## Corrections the fact-checkers made to the readers (none change the conclusion)

- The Round 47 whole-goal audit has 11 requirement rows, not 10.
- Round-to-child attributions (e.g. "#145 ≈ R1–R24", "#153 ≈ R25–R78") are approximate; those rounds interleaved
  Why3/solver/#178 work.
- Elapsed hours for #201/#202/#212 are ≈7.0/7.0/4.8 h, not 7.5/7.5/5.3 h.
- Records listing the useful-domain comparison / final review as remaining: 37–38 of 45 (R48–R92), not 31.
- Defects in previously accepted claims during R83–R92: ≥4, not 2 (strengthens point 5).

## What a percent can and cannot mean here

A percent of the stated scope presupposes the owner accepts premise-based tool correspondence and a conditional
(symbolic) configuration attachment, and adopts or rejects the prospective quiet/pipe solver route. Without those
decisions, two requirements are not closable with the inputs available, and the figure is a percent of a closable
scope rather than of the literal scope.

## Second question (2026-10-24): is finishing #119 worth it before resuming language development?

Recommendation: **No.** Resume language development now at the current 4,096-byte strict language; run the
owner's adopted strict/loose design as its own budgeted milestone when the cap starts binding; freeze #119 after a
short R93 cleanup as the deferred strict-mode rule. Details and the red-team record are in
`redteam-sequencing-result.json` (red team: "sound with amendments"; envelope feasibility: 8–30 rounds only under
adopted premises, "smaller in degree, not in kind"; cost audit below).

Cost audit (harness `tokensUsed` counters quoted in the round ledger; totals are consumption incl. subthreads):

| Period | Tokens | Basis |
| --- | --- | --- |
| Measured floor (R7–R16, R25–R47, R48–R58) | 72.2M | counters, ≈21 of ≈69 active hours |
| Estimated all-in through R92 | 196–277M (central ≈237M) | 2.96–4.36M per active hour on unmeasured periods |
| One fully measured working day (10-20) | ≈49.5M | Goal 1 + Goal 2 counters |
| Remaining #119 if 50% done | ≈200–415M (central ≈300M) | 1.0–1.5× work to date; 4–8 full working days at 49.5M/day |
| Remaining #119 if 85% done | ≈35–50M | 0.18× work to date; but R69–R92 (est. 45–65M) moved the self-estimate 0 points |
| Production #88–#94 | no recorded cost | earlier language increments took 2–8 session-hours each by wall-clock analogy |

Opportunity cost: at least five assured language increments landed in the three days before #119 (10-15 to 10-17);
none in the seven days since.

Red-team amendments adopted: finish the four pending reviews and integrate R93 before freezing (2–3 rounds); give
PR #121 and the 73 findings an explicit disposition (frozen, tagged evidence branch); scope any envelope to the
GNAT-side silent limits under adopted premises with a token budget and dated stop, deriving it only after #88/#89 fix
the production configuration; keep #93's value/argument/output cap removal out of the first loose increment; define a
concrete #119 resume trigger; record the reversal of "pause build until #119 completes" as a dated owner decision on
main; do not run loose-mode work in parallel with feature work (single proof-workspace writer).
