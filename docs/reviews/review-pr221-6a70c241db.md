# Review: Rosetta regression samples for today's Silver (PR #221, 6a70c241db)

2026-10-25 UTC. Planning-agent review of the delivery handoff for stage issue
[#9](https://github.com/berkeleynerd/silver/issues/9), requested by the owner.

**Review target:** [PR #221](https://github.com/berkeleynerd/silver/pull/221), head
`6a70c241db6b92ebb7431cf41ce1780bf7d9993c` (`feat/rosetta-supported-samples-9`);
implementation commit `247cc5c205acf1e5a9e93a76b5d4ba5420838e6e` (samples and manifest);
base `main` at `7a2fb0b70a445ea220ccd422fc62769a45e57904`. Mergeable, merge state CLEAN,
no reviews, no CI (Actions disabled repo-wide). Read-only review from a detached scratch
worktree; the shared checkout, the three tmp/ worktrees and GitHub were not modified.

**Reviewer:** Claude Fable 5.1 (Claude Code), one lead plus 119 subagents: 31 per-task
disposition checks (effort high), six lenses (samples/manifest semantics at xhigh,
evidence integrity, process compliance, documentation consistency and Rosetta progression
at high, next-step research at xhigh), one consolidation agent, two independent refuters
per consolidated finding (an evidence lens and a requirements lens; xhigh for medium,
high for low, medium for info) and a completeness critic. Measured from the agent
transcripts: 958k output tokens, 5.47M cache-creation and 42.8M cache-read input tokens,
1,083 tool calls, 53 min wall-clock (09:30 to 10:24 UTC). The lead's own inline checks
are not included in those counts. No Lean, GNATprove, build, test-suite, `silver compile`
or `silver run` was executed; `silver check` (admission only) and read-only inspection of
the recorded evidence were the only tool uses, per the owner's standing rule.

## Verdict

**No blocker. The delivery is correct and complete for #9. Merge after three small
record fixes (M1, L1, L2), or merge now and carry them as a filed follow-up.** The
planning follow-up M2 is the planning agent's own work and does not change the PR.

- All 14 regressions are right. Each program's stdout, stderr and exit status were
  derived by hand from the source and the runtime rules and match the manifest byte for
  byte for all 19 execution cases (13 default runs plus the six argument cases of
  `rosetta_useless_instructions.adb`). All 13 sources are admitted by the current
  compiler, ASCII, 111 to 1,805 bytes, and within today's language.
- All 31 dispositions are defensible against the task texts: 14 agree outright, 17
  carry a recorded caveat, none is wrong. The three exclusions are justified by the
  tasks' own words ("inbuilt string interpolation abilities", "here documents",
  "Simulation"); Rubik's cube ("Draw ... Rubik's cube") is correctly treated differently
  from Rubik's Magic Simulation.
- Every number and identifier in the handoff checks out against the recorded evidence
  (table below). The one evidence defect is a precision error in the machine-readable
  index, not in the validation itself.
- The proposed next increment is correctly attributed to #11 but has a one-task yield;
  research below shows seven of the ten stage-2 tasks are already admissible today.
  See "Next step".

## Handoff claims checked

| Claim | Result |
| --- | --- |
| 13 new programs plus existing `null.adb` cover 14 tasks | Verified: rows 1, 2, 3, 4, 6, 10, 15, 16, 18, 19, 20, 23, 27, 31 of the record |
| All 31 dispositions documented; 14 skips, 3 exclusions | Verified: 31 rows, 14 + 14 + 3; row 20 lacks its sample link (L1) |
| 473 tests passed, all 35 manifest samples, symlinked-TMPDIR check | Verified: log hashes match, `Ran 473 tests ... OK`, 462 `ok` lines, 0 failures/skips; 22 + 13 = 35 entries; test-function count 464 on both main and PR (suite trend 469, 471, 473) |
| Complete native proof/provenance audit and build | Verified: ledger runs exist; 75 units, 1,000 entities, 1,295 flow + 13,860 proof = 15,155 checks; command equals `scripts/check_evidence.py` PROOF_OPTIONS with `-j 6`, cache file and `-f`; cache reuse labelled honestly; 141 tracked inputs match 247cc5c205 |
| Complete cached Lean/source validation, 466 modules, 89,369 declarations | Verified: `lean-evidence.json` lists 581 inputs; every one hash-matches 247cc5c205 (recomputed); foundations `propext`, `Classical.choice`, `Quot.sound`; toolchain `v4.34.1` and tool hashes match; the ledger row copied into validation.json is defective (M1) |
| Independent review (GPT-6.1 Sol xhigh) found no material issue | Recorded as a table row and a validation.json block (77 s, tokens unavailable, runtime setting not confirmed); compliant with development.md; no reviewer artifact retained (info) |
| Completing commit 6a70c241db carries `Fixes #9` | Verified; 247cc5c205 carries `Refs #9` |
| #9 is In review | Verified on the board: Status In review, Stage 1, Constructs unset |
| Worktree clean and pushed | Verified: `tmp/rosetta-supported-samples-9` at 6a70c241db, in sync with origin; `tmp/bounded-mutable-integers-native` at 247cc5c205 and `tmp/review-b79-b1-lean` at 7a2fb0b70a, both clean |
| Shell one-liner reproduces the sample | Verified: the `printf` line yields the 111 sample bytes exactly; `silver check` accepts; `silver run` is a real subcommand (compile then execute) |
| Links, anchors, whitespace | Verified: all relative links and anchors in the changed Markdown resolve; `git diff --check` clean; manifest canonical JSON, no orphans |

## Findings

Severity: blocker = must not merge; medium = needs a fix or a filed issue; low = record
defect; info = judgment note or planning follow-up. Statuses are post-verification: each
consolidated finding was challenged by two refuters with different lenses; CONFIRMED means
neither refuted it, PLAUSIBLE means one did. Two candidates were refuted by both refuters
and are listed at the end.

### M1 — validation.json's Lean managed-run row records no command and a zero-match comparison, contradicting the record's description of the index (medium, CONFIRMED)

- **Location.** `docs/evidence/rosetta-supported-samples/validation.json` lines 184-199:
  `"command": []`, `"matched": 0`, `"sha256": "44136fa3..."` (the SHA-256 of `{}`);
  `docs/rosetta-supported-samples.md` lines 104-107: the index "records actual commands,
  run IDs, host/workspace identities, measured elapsed time, sample hashes and comparisons
  of captured inputs with the implementation commit".
- **Facts.** The ledger run `20261025T071150-d336b7715e90` does record both: its
  `started` event carries the full command (`check_lean.py --workers 4 --threads 2 --task
  #9 --provenance --reason ...`) and 581 input sources. The extraction looked for the
  native runner's `prepared` and `command` events, which the Lean runner does not emit.
  The 581-input claim is true and separately supported by `lean-evidence.json`.
- **Fix.** Populate `lean.managed_run.command` and the comparison from the `started`
  event, or add one sentence to the record saying the Lean ledger row carries no tracked
  input comparison and the runner's evidence file supplies it. Five lines either way.

### M2 — The three excluded tasks remain "likely, stage 1" candidates in the generated progression, with no follow-up filed (medium, CONFIRMED; planning agent's work)

- **Location.** `rosetta/progression.md` Stage 1 positions 12, 16 and 34;
  `rosetta/s/string-interpolation-included/silver.md`, `rosetta/h/here-document/silver.md`,
  `rosetta/r/rubiks-magic-simulation/silver.md` (all "Candidate: proofs likely to
  discharge automatically"); record lines 25-29 ("qualify the earlier assessments without
  rewriting the generated progression by hand").
- **Facts.** Rosetta assessments are the planning agent's; the implementer correctly left
  `rosetta/` untouched. Ada 2022 has no built-in interpolation and no heredoc or
  multi-line string literal, and Silver adds no syntax, so these two are permanent Oracle
  conflicts (assess.js kind `outside-spark` or `other`), not missing surface; the record's
  wording "absent", "current literals cannot" reads as current state (PLAUSIBLE F9). Rubik's
  Magic needs a real state simulation whose surface (arrays and more) belongs to a later
  stage.
- **Fix.** Planning agent: record the conflicts and re-assess the surface, re-render, and
  write the mapping record as the two precedents did. Optionally one sentence in the PR
  record naming this follow-up. Bundled with L5 below into one planning PR.

### L1 — Row 20 omits its sample file link (low, CONFIRMED)

`docs/rosetta-supported-samples.md` row 20 (Write language name in 3D ASCII) is the only
regression row that does not name `rosetta_language_name_3d.adb`; the file name appears
nowhere in the record. One-line fix.

### L2 — Partial "strict/loose" to "strict/extended" rename, with the naming decision not recorded on main (low, CONFIRMED; merges two findings)

The completing commit renames one occurrence in `roadmap.md` (line 21) and asserts in the
new session-memory entry that "The current assurance-mode names are strict and extended"
without a date or link. On main, `roadmap.md` line 53 still says "loose mode", the
2026-10-24 session-memory entry says "strict/loose" and "loose-mode envelope", and
"extended" appears nowhere in the mode sense; the owner's 2026-10-24 renaming lives only
in draft PR #147, whose title still reads "strict and loose". The rename is outside #9's
declared scope. Fix: complete the rename at `roadmap.md` line 53 and cite the 2026-10-24
decision (PR #147) in the session-memory sentence, or revert the one-word rename and the
sentence so #221 stays within scope. The review recommends completing it with the citation.

### L3 — The record does not state that the Lean workspace was at main 7a2fb0b70a while the native workspace was at 247cc5c205 (low, PLAUSIBLE)

Harmless, because `src/`, `proof/`, `scripts/`, `tests/`, `silver.gpr`, `alire.toml` and the
catalogue are byte-identical between the two commits and the 581 inputs hash-match
247cc5c205. One sentence would remove the ambiguity.

### L4 — Documentation-only capability tags deviate from sibling conventions (low, PLAUSIBLE)

`rosetta_identifier_case.adb` lists no `string_copy` and no `statement_sequence` although
`dog := DOG;` is a self-copy and the body has two statements; `rosetta_print_debugging.adb`
pairs `string_concatenation` with `expression_output` where siblings use
`concatenated_output`; `rosetta_string_concatenation.adb` lists `statement_sequence` for
two statements while `rosetta_identifier_case.adb` does not. The policy-relevant tags
(`string_assignment`, `integer_assignment`, `runtime_context`, `argument_context`) are
correct for all 13 entries and the suite enforces them. Tidy at leisure.

### L5 — Two stage-2 Rosetta assessments are defective (low; planning agent's work)

- *Unicode variable names* is assessed "likely" with surface `integers, scalar-image`, but
  Silver's source rule excludes every non-ASCII byte, so the required `Δ` identifier is
  impossible in any Silver (an Oracle-level exclusion under the current source rule), and
  the required increment `X := (X + 1)` is inexpressible today (probes rejected for ranged,
  unconstrained and guarded objects). (PLAUSIBLE)
- *Variable size/Set* omits the `'Size` attribute and the Size representation clause its
  own approach depends on; a named subtype cannot carry a Size clause, so neither today's
  language nor the proposed increment can complete it. (CONFIRMED)

### Info — judgment notes, no change required

- The output-substitute standard is applied unevenly: a hand-written `TRACE file:8:4`
  literal is accepted for Print debugging while concatenation and Put_Line sequences are
  excluded for interpolation and heredoc. The record states both positions honestly; the
  TRACE location is correct today and would silently go stale under an edit.
- The Rubik's Magic exclusion is a "design not selected" case rather than absent
  semantics; the record's hedge ("does not select a future simulation design") is right.
- Skips forgo cheap admitted regressions for Comments, Documentation, Sealed classes and a
  Put_Line-sequence Here document; #9's own wording permits skipping prose tasks, and the
  task texts permit omission for Start from a main routine and Random number generator.
  Rows 7 and 9 say "excluded by #9" where the record otherwise reserves "Exclude" for the
  absent-semantics category.
- The documented one-liner leaves an untracked `main.adb` at the repository root;
  `.gitignore` has no rule for it. The captured Rosetta Ada answer cleans up after itself.
- The Special characters inventory omits `#`, which Silver admits in based numerals, and
  shows the comment marker only inside a literal. Everything it lists is admitted.
- `samples/null.adb` has no final newline (pre-existing, unchanged, admitted).
- Owner statements recorded in the new session-memory entry are not evidenced on GitHub:
  that the owner "directly selected" #9 on 2026-10-24, "reaffirmed" the #119 and #88-#94
  deferrals, and that delivery "is through a pull request". The authorization of #9 itself
  is on main (2026-10-24 entry). The owner can confirm these when reading the entry.
- "Sole writer" and "no other native/proof writer ran alongside" are supported only
  negatively: four non-overlapping ledger runs on 2026-10-25 and zero-byte lease files.
- The build and test managed runs were started with an empty `--reason`; prove and Lean
  carry reasons. "19 execution cases" is derived from the manifest, not visible in the log.
- The Lean runner's 42.679 s exceeds the ledger's 41.156 s; both are recorded and labelled.
- The README summary mentions regressions and skips but not the exclusion category; the
  record uses "35" for two different sets (Stage 1 tasks, manifest samples) and never names
  the four earlier-delivered drivers (Loops/Downward for, Loops/For, Loops/For with a
  specified step, Find square difference).
- Board: no Stage field change or re-render is due; #9 closes on merge and the board
  workflow sets Done. No GitHub milestone, consistent with #11 and #12.

### Refuted or dropped

- "The interpolation exclusion rejects the concatenation approach the Rosetta Ada entry
  accepts": refuted by both refuters. The task says "inbuilt string interpolation
  abilities ... not to create a string interpolation routine"; the Ada entry's
  concatenation is an acknowledged non-answer.
- "The capability record lacks the precedents' bold status/date line": refuted; no rule
  requires it, and the date is in roadmap.md and the session memory.
- Four consolidation drops were pure agreements (native prove configuration matches the
  established compiler-audit command; the claim comment's extra "direct instruction"
  citation is surplus; no milestone or labels are required; no `rosetta/` mapping record
  is required for a sample-only delivery).

## Per-task dispositions

| # | Task | Verdict | Note |
| --- | --- | --- | --- |
| 1 | Shell one-liner | qualified | Program half regression-tested; the shell half is documentation (verified by hand); untracked `main.adb` |
| 2 | Empty program | qualified | Correct; `null.adb` lacks a final newline (pre-existing) |
| 3 | Hello world/Newline omission | agree | "Goodbye, World!" without LF, byte-exact |
| 4 | Hello world/Text | agree | "Hello world!" exact task text |
| 5 | Start from a main routine | qualified | Skip justified by the task's omission clause, not by "prose alone" |
| 6 | Case-sensitivity of identifiers | qualified | Output matches the task's case-insensitive sentence; tag nits (L4) |
| 7 | Comments | qualified | Skip mandated by #9; a runnable comment sample would be cheap |
| 8 | Show the epoch | qualified | Skip correct; rationale straddles skip and exclude |
| 9 | Sort stability | qualified | Skip mandated by #9; row says "excluded by #9" |
| 10 | String concatenation | agree | Variable, concatenated variable, both shown |
| 11 | String interpolation (included) | qualified | Exclusion correct and permanent (Oracle conflict); assessment to fix (M2) |
| 12 | Random number generator (included) | agree | Task says skip without a built-in RNG |
| 13 | Here document | qualified | Exclusion correct and permanent; a Put_Line sequence was the assessed substitute (M2) |
| 14 | Sealed classes and methods | qualified | Skip correct; a prose-printing program existed in the assessment |
| 15 | Copy a string | qualified | Correct; near-duplicate of language.md's worked example and `shared_bindings.adb` |
| 16 | Print debugging statement | qualified | Correct; hand-maintained location literal; tag pairing (L4) |
| 17 | Special variables | agree | Prose inventory |
| 18 | Draw a diamond | agree | Faceted diamond over an inverted pyramid matches "three-dimensional diamond" |
| 19 | Special characters | qualified | Inventory is Silver's lexicon; `#` omitted |
| 20 | Write language name in 3D ASCII | qualified | Letters spell SILVER with shading; row lacks the sample link (L1) |
| 21 | Safe mode | agree | Descriptive task |
| 22 | Documentation | qualified | Skip defensible; a comment-bearing program was the assessed answer |
| 23 | Rubik's cube | agree | Task says "Draw"; three faces of nine stickers each |
| 24 | Hello world/Newbie | agree | Installation instructions |
| 25 | Interactive help | qualified | Skip correct; the record could note the implementation's usage line (`silver` with no arguments, status 2) |
| 26 | Operator precedence | agree | Precedence table task |
| 27 | Useless instructions | agree | `elsif` versus nested `if`; all six argument cases derived and matched |
| 28 | Cross compilation | agree | Toolchain documentation |
| 29 | Naming conventions | agree | Style documentation |
| 30 | Rubik's Magic Simulation | qualified | Exclusion defensible as a fidelity judgment of the assessed design; assessment to fix (M2) |
| 31 | Draw the Empire State Building | agree | Silhouette; optional rotation omitted |

## Next step: research result and recommendation

The handoff proposes "static named Integer subtypes and object declarations using them"
under #11, motivated by Define a primitive data type. The next-step lens wrote the smallest
faithful program for each of the ten stage-2 tasks in today's language and ran admission on
it; the lead re-ran every check. Programs and probes are retained in
`tmp/review-pr221-20261025/next-step-candidates/`.

| Stage-2 task | Class | `silver check` | Note |
| --- | --- | --- | --- |
| Topic variable | A: admissible today | Accepted | Object-local range `0 .. 1000` suffices; loop floor square root; inner `for It` hides the outer object |
| Compile-time calculation | A | Accepted | 10! as nested grouped products; exact value computed at admission |
| Integer sequence | A for admission only | Accepted | `1 .. 2147483647` admitted (`Integer'Last` is not); 2^31 lines cannot run in the 10 s harness; needs a disposition |
| Loops/N plus one half | A | Accepted | `if I < 10 then Put (",")` replaces `exit when`; Image leading space |
| Unicode variable names | D: impossible in any Silver | faithful version Rejected | Non-ASCII excluded; `X := (X + 1)` inexpressible |
| Enforced immutability | A | Accepted | Assignment to a constant is rejected at admission, before GNAT |
| Literals/Integer | A | Accepted | `2#10_1101_0111#`, `16#2D7#`, `16:2d7:`, `7_27`, `727E0`, `7#1#E3` all admitted |
| Variable size/Set | C: needs more | faithful version Rejected | Needs a type declaration, a Size clause and `'Size` |
| Minimum number of cells ... NxN | A | Accepted | Nested `1 .. 10` loops; minimum via `if` into a `0 .. 9` object |
| Define a primitive data type | B: needs named subtypes | `subtype` Rejected; object-local approximation Accepted | Conversions are not needed: admission rejects `A := 11` and `A := (B + 1)` statically |

Further probes: `X := (X + 1)` is rejected for ranged, unconstrained and guarded objects,
because scalar guards do not narrow intervals; `for V in Integer range 1 .. 10` and
`My_Type (C)` are rejected. No stage 3-6 candidate becomes deliverable through stage-2
constructs (refresh.py already pulls such tasks forward). Over all 1,578 candidates the
single construct unlocking the most additional tasks is integer division (10, all in
stage 7), then arrays (7), string building (5), characters (5), Booleans (4), procedures
(3); `ranged-subtypes` appears in 1,442 candidate surfaces, so the subtype increment has
broad downstream value despite a one-task immediate yield.

**Decided recommendation.**

1. *Planning agent, now, no language change:* a Rosetta assessment-correction PR. Record
   Oracle conflicts for String interpolation, Here document and Unicode variable names;
   re-assess the surface of Rubik's Magic Simulation and Variable size/Set; narrow the
   identifiers of the seven admissible stage-2 tasks after per-program verification (as the
   two precedent mapping records did); re-render. Stage 1 gains seven tasks; stage 2
   shrinks to Define a primitive data type.
2. *Coding agent, on the owner's "proceed":* a second current-language sample batch under
   a new stage issue: six runnable programs (the admitted candidates above, with expected
   outputs derived at delivery) plus a recorded disposition for Integer sequence (admitted
   and compiled, execution not harness-checkable, or a documented cap).
3. *Coding agent, on the owner's "proceed", scoped by the planning agent under #11:* static
   named Integer subtypes, widened from the proposal: `subtype Name is Integer range S .. T;`
   with the existing static-endpoint rule; object declarations `X : [constant] Name := E;`
   taking the subtype range as their declared range (the same elaboration and interval
   semantics as today's object-local ranges, so the Lean per-object range model is reused);
   and the subtype mark as a for-loop range, `for V in Name loop`. Excluded: conversions,
   re-constraining a named subtype, `Name'First`, `Name'Last`, `Name'Image`. Driver: Define
   a primitive data type. Record the partial `ranged-subtypes` split and a narrow identifier
   per planning.md.
4. *After that:* integer division with a divisor interval excluding zero and the
   `-2**31 / -1` case (ten stage-7 tasks), then scalar guard refinement bundled with
   conversions, which only become expressive together.

The owner's "proceed" is the procedural step for items 2 and 3; item 1 is within the
planning agent's remit.

## Follow-ups for the planning agent

- M2 and L5: the assessment-correction PR above (one PR, one `type: follow-up` issue).
- The 14 prose/tooling tasks have no renderer category, so Stage 1 overstates runnable
  samples by 17; consider a `prose` disposition in `refresh.py` and the coverage policy.
- Draft PR #147's title still says "strict and loose"; rename to match the owner's
  2026-10-24 decision when the PR is next touched.

## Validation performed and evidence of this review

Inline by the lead: hash and byte-count verification of every sample, the manifest and
both suite-log digests against `pr/221` blobs; ASCII, trailing-whitespace and final-newline
checks on the 13 sources; link and anchor resolution across the changed Markdown; 581 Lean
input hashes recomputed against 247cc5c205; ledger directories, worktrees and board state
read; `silver check` on the reproduced one-liner, on all 13 samples (by the samples lens)
and on the ten stage-2 candidates plus twelve probes; `git diff --check` and manifest
canonical-form checks by the critic. Not performed, by owner rule: proof, build, suite or
kernel reruns; the recorded evidence was audited instead. No macOS or CI claim is reviewed
because none is made.

Review inputs are retained under `tmp/review-pr221-20261025/` (host-visible, untracked):
`workflow-result.json` and `workflow-result-inner.json` (raw agent returns, 119 agents),
`verify_hashes.py`, `check_links.py`, `usage.py`, `next-step-candidates/` and this report.
