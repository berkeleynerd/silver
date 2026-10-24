# Materials index for the #119 completion assessment (all paths absolute)

Root: /tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/648645b8-7d75-44ae-87cd-a7d3e33f1ca8/scratchpad  (referred to as $S below)

## Context facts (verified by the orchestrator)
- Repo: github.com/berkeleynerd/silver, main at 2c9018a31a (local) / 7719f7b38f (origin/main, PR #160 merge). Direct-mode sandbox.
- Issue #119 "Unbounded programs: Derive capacity rules for unchanged tools" is OPEN, milestone 5 "Unbounded programs". Created 2026-10-17T22:37Z. 105 comments; last 2026-10-24T09:34Z.
- Draft PR #121 (branch research/retained-tool-capacity) head f1920759b17dd328e1b8c71293002be9390d7d53 = "R92", 1,211 commits over origin/main, 5,446 changed files, +3.16M lines (docs/evidence 4,879 files; docs/research 341 files; docs/reviews 222 files). Merging is unauthorized.
- Local integration branch is 2 commits ahead of R92: ffa0f49dd3 (unreviewed source/string author packet) and 1c058a85f6 "Record owner pause and preserve unfinished capacity work" (2026-10-24 10:10 UTC). Owner said "Let's pause our effort." at ~10:08 UTC today.
- Self-reported estimate history (from #119 comments): 70% (60–75%) before R23; 75% (65–80%) at R23 (2026-10-19 13:39Z); 80% at R24 (10-19 15:30Z); 80–85% (~82%) from R28 (10-20 09:37Z); 80–85% at R61 (10-23); 85% from R69 (10-23 19:27Z) through R92 (10-24 09:34Z). Always labelled "low confidence", "not an ETA", "not inferred from packet/check counts".
- PR #121 commits per day: 10-17: 44; 10-18: 579; 10-19: 107; 10-20: 244; 10-21: 4; 10-23: 109; 10-24: 124. Review files per day: 10-19: 6; 10-20: 55; 10-23: 25; 10-24: 33. Round records by date: R29–R58 on 10-20 (30), R59 on 10-21, R60–R78 on 10-23 (20), R79–R92 on 10-24 (14). Rounds 1–28 are recorded only in the ledger (docs/evidence/retained-tool-rounds.md), dated 10-17 to 10-20.
- Issues referenced as "Fixes #N" in PR #121 commits (they will close only when the PR merges): 122 125 126 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 150 153 154 155 161 162 163 164 165 166 167 168 169 170 178 179 180 181 182 183 184 185 193 194 195 196 197 198 199 200 203 204 205 206 207 208 209 210 211 213 214 215 216 217 218 219.
- Milestone-5 open work packages that are children/siblings of #119: #145 (literal-output native, technically complete R24), #153 (fixed Why3 session domains, technically complete R78), #155 (preparation/Theory publications, complete R35), #178 (Main source→typed profiles, complete R77), #185 (Main profiles→terminal goals, complete R79), #186 (Why responses→GNATCOLL parser, complete R79), #193 (producer results→spark reports, complete R81), #194 (report collectors/readers, complete R82), #206 (reported-time capacity, complete R84), #201 (general current-grammar native compilation capacity, IN PROGRESS), #202 (ordinary Main Why storage/failure capacity, IN PROGRESS), #212 (fixed-report source/configuration capacity, IN PROGRESS). Production packages #88–#94 are authorized but unstarted pending #119.

## Files
- $S/gh/issue-119-body.md — current issue body (R92 status on top; historical statuses; "Authorization, scope and completion criteria" and "Scope" + "Completion now requires..." at the bottom).
- $S/gh/issue-119-comments-all.md — all 105 comments, chronological, with URLs (178 KB).
- $S/issue-119-timeline.tsv — compact per-comment timeline: idx, timestamp, rounds mentioned, % estimates mentioned, lead text.
- $S/gh/issue-{91,93,153,201,202,212,218,219}.md and $S/gh/issues/issue-{145,155,178,185,186,193,194,206}.md — child/sibling issue bodies.
- $S/gh/child-comments/issue-N-comments.md — comment threads of children (N in 153 201 202 212 145 178 185 186 193 194 206 155).
- $S/gh/findings/finding-N.md — bodies of all 73 open "type: finding" issues in milestone 5; $S/gh/findings/open-finding-numbers.txt lists them.
- $S/gh/milestone5-issues.txt — all milestone-5 issues with state/labels; $S/gh/prs-recent.txt — recent PRs.
- $S/pr121/r92-README.md — latest accepted checkpoint record (R92), including "Continuation" (remaining work) section.
- $S/active-119-checkpoint.md — restart inventory written at the owner pause (10:08 UTC today): unreviewed/uncommitted packets and resume obligations.
- $S/pr121/retained-tool-capacity-stop.md — Round 47 (2026-10-20) whole-#119 research-stop report with the "Whole-goal requirement audit" table (10 requirements, preserved evidence, exact residuals) and "Concrete solver-output gap".
- $S/pr121/retained-tool-capacity.md — the capacity contract / component index on the PR head (183 KB). Lines 1–400: current status narrative R61–R92 and R48–R61; "## Preserved resumed-research checkpoint through Round 46" at line 399; "## Inputs and required conclusion" line 1824; "## Phase and cost model" 1853; "## Complete grammar obligations" 1921 (component table lines ~1925–1935; grammar-family table ~2290–2300); "## Producer limits and correspondence" 2311; "## Comparison and next derivation" 2390 (4-step remaining derivation order).
- $S/pr121/retained-tool-rounds.md — round ledger R1–R76 (410 KB). Useful sections: "### Pause assessment and remaining work" (R23, ~line 2049), "### Reviewed native completion and assessment pause" (R24, ~2165), Round 28 (~2671), "## Round 47 — solver-output gap and reviewed research stop" (~4759) with "### Completion boundary and tracking".
- $S/pr121/rounds/RNN-<dir>-README.md — the per-round checkpoint records R29–R92 copied from the PR head (65 files). Each has accepted scope and remaining/continuation statements.
- $S/pr121/children/retained-{general-native-capacity,main-construction-demand,main-why-storage,main-entry-capacity,fixed-report-composition}.md — research notes of the three in-progress children (#201, #202, #212) with explicit "remaining" sections.
- $S/pr121/roadmap-pr.md, $S/pr121/RESUME-pr.md, $S/pr121/roadmap.diff, $S/pr121/resume-added.md — roadmap/RESUME as carried by the PR.
- $S/unbounded-programs.md — milestone scope document on main (goal, full stops, design, limits tables, "Pinned-tool and inherited language limits", "Producer and observation limits", "Trusted premises").
- $S/roadmap-main.md, $S/planning.md — roadmap and planning rules on main.
- $S/pr121-evidence-dirs.txt, $S/pr121-research-files.txt, $S/pr121-review-files.txt — file listings on the PR head.

## Ground rules for every agent
- Base every statement on these files; cite file and heading (or line) for each material claim. If something cannot be found, say so rather than guessing.
- The repository's own estimate (≈85%) is a self-report; do not anchor on it. Reason from the completion criteria and the recorded residuals.
- Keep outputs compact (target ≤ 1,200 words of prose per agent, excluding structured fields).
- Do not modify any file under the repository. Reading is fine. Writing scratch files is allowed only under $S/agent-scratch/.
