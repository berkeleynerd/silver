# Independent Claude review of Silver PR #412

| | |
| --- | --- |
| PR | https://github.com/berkeleynerd/silver/pull/412 — "Add constrained Integer-array inputs and bounds queries" (open, not draft, mergeable) |
| Base | `5f97477d5be1c9da974e6df95300bb8f2bb8fcfb` |
| Target | `5a4b0ad8ac05ed431d2f0c8baee2c2cc75686267` (detached worktree HEAD verified; equals the PR head on GitHub) |
| Review date | 2026-11-22 (UTC), single reviewer pass, about 01:09–02:05 |
| Selected model / effort | `claude-fable-5-2` / `max` (from `launch.json`) |
| Observed model / effort | The session identifies itself as Claude Fable 5.2 (`claude-fable-5-2`). The server-side effort setting is not observable from inside the session and is not claimed. |
| Environment | Managed run `20261122T010909-5521bb0d015c`, two workers, inherited affinity CPUs 0–1 (observed mask `0x3`), Linux x86_64 |

## Verdict

**No blocker found. One medium finding, three low (record) findings, six informational notes.**

The feature increment looks sound at the level I could examine: the native admission rules match Ada/SPARK semantics in every case I derived and probed, the #414 repair derives the new imported meanings from linked native interpretations on Main and both callable-local paths, and the delivery evidence reproduces from the retained originals and applies byte-for-byte to this target.

The medium finding is a coverage gap in the #413 stack remedy, not a failure under the documented prerequisite: the hardest admitted shape I could construct needs about 13.2 MiB, which the retained fixtures and regression test do not exercise, and it still passes at the documented 16 MiB.

| Severity | Count | IDs |
| --- | ---: | --- |
| Blocker | 0 | — |
| Medium | 1 | C412-M1 |
| Low | 3 | C412-L1, C412-L2, C412-L3 |
| Info | 6 | C412-I1 … C412-I6 |

**Recommendation for the merge decision.** Nothing here requires holding the merge on soundness grounds. I would resolve C412-M1 (two extra fixtures plus recorded numbers, or a filed issue) and the two in-repository record corrections before or immediately after merge, and make a conscious owner decision on C412-I1 (application proofs are now serial for every user).

## Findings

### C412-M1 (Medium) — The #413 stack evidence and regression guard omit the hardest admitted shape

**Where.** `tests/test_array_parameters.py:27` (`test_source_limit_loop_shapes_complete_the_native_route`), `tests/test_counted_bound_review.py:58–81`, `docs/evidence/named-array-parameters-410-20261121/stack/README.md`, `README.md:341–349`, `docs/trusted-boundary.md:153–160`. Root cause of the growth: `src/silver_array_bindings.ads:13` (table 170 → 585 entries) copied per nested loop at `src/silver_output_profile.adb:6556`.

**What.** All three retained fixtures nest loops in the Main body. A loop nest inside a function or procedure body starts from a much deeper frame (about 4.2 MiB of declaration-reader frames instead of about 0.9 MiB) and is the worst shape I found. Each nested level costs about 65.6 KiB on this binary, which matches the 64,264-byte `Body_Context` copy.

Admission-only measurements with the retained target binary, bisecting `RLIMIT_STACK` at 64 KiB resolution:

| Source (≤ 4,096 bytes) | Levels | Minimum accepted stack |
| --- | ---: | ---: |
| Retained `stack/named_range.adb` (Main `A'Range`) | 128 | 9,213 KiB |
| Retained `stack/old_counted.adb` (Main counted) | 142 | 10,237 KiB |
| Retained `stack/old_foreach.adb` (Main for-of) | 159 | 11,261 KiB |
| Function body `for I in X'Range` nest | 126 | 12,349 KiB |
| Function body counted nest | 141 | 13,436 KiB |
| Procedure body counted nest | 141 | 13,564 KiB |

The two 4,096-byte callable fixtures raise `STORAGE_ERROR` (exit 1) at 8 MiB **and at 12 MiB**, and are accepted at 14 and 16 MiB; their 4,097-byte siblings are rejected normally (exit 2). All three retained fixtures pass at 12 MiB.

**Reproducer.** In this review directory, `scratch/probe/src/st_fn_counted_max_4096.adb` (SHA-256 `a92ba270…52e5fb`) and `st_proc_counted_max_4096.adb` (`14a442c6…7b284b`); shape: `procedure P(X:out Integer)is begin X:=0;` + `for I in 1..1 loop ` × 141 + `null;` + `end loop;` × 141 + `end P;`, padded to 4,096 bytes. Run `silver check` under `ulimit -S -s 12288` and `16384`.

**Consequence.** The documented 16 MiB still holds for every shape I measured, with 2,820 KiB of margin. But the control that exists to detect when admitted source-limit programs stop fitting is blind to the shape with the least margin: a further growth of about 20 KiB per copied context (roughly 32 %) would break admitted programs at the documented setting without any test failing. The new feature's own construct in its primary context (a `'Range` loop over an array formal) is also outside the retained fixtures. The failure mode is an unhandled `STORAGE_ERROR`, not a clean diagnostic.

**Origin.** The per-level growth is new in this PR. The Main-only fixture pattern is inherited: with the main-checkout binary (hash equal to the one retained as "main" in `stack/record-sizes.json`; its build provenance is not established by me) the same callable nests already needed 8,701 / 8,765 KiB, above the 8 MiB the base-era test asserted for Main shapes. The #413 remedy carries that gap forward.

**Uncertainty.** I could not measure Linux ARM64. `README.md:341` and `development.md:331` now give 16 MiB for "the current Linux compiler (x86_64 and ARM64)", but the only ARM64 measurements predate this growth. `docs/trusted-boundary.md` records 6,416 bytes per nested condition parenthesis on ARM64 (about three times what I measure on x86_64), so a deeply parenthesised condition placed inside a callable body may exceed 16 MiB there. That is an extrapolation, not an observation.

**Smallest repair.** Add the function-body and procedure-body nests (and ideally the `X'Range` variant) to the existing source-limit test with an explicit 16 MiB `RLIMIT_STACK`, and record their measured minima in `stack/README.md`. Either re-measure on ARM64 or qualify the ARM64 half of the README sentence. If not done before merge, file an issue rather than closing #413 unqualified.

### C412-L1 (Low) — Sample manifest tags Horner with a capability it does not use

`samples/manifest.json:3058` lists `integer_array_bound_query` for `rosetta_horner_polynomial.adb`. That source contains no `'First`, `'Last` or `'Length`; its only query is `Coefficients'Range` at line 21, which the entry already tags as `integer_array_range`. The manifest test only checks that tags are a subset of catalogue identifiers, so nothing detects this.

Consequence: inaccurate coverage metadata only. New in this PR. Repair: drop the tag. The manifest is a captured input of `test_samples`, so the change needs that one test's rerun or an explicit applicability note.

### C412-L2 (Low) — The feature's report-capacity account still describes itself as pre-delivery

`docs/named-array-parameters-report-capacity.md:5–9` says the capability "remains in development in draft PR #412" and that complete assurance, final regression and delivery review "remain pending". `README.md:255` and `docs/assurance.md:193` cite this document as the current producer account for the delivered capability. New in this PR. Repair: update the status paragraph (documentation only).

Related, lower still: two sentences in the retained history of `docs/named-array-parameters.md` read as current ("Complete Lean integration is still pending" at lines 215–216, and the out-of-order last table row at line 248). The document does declare those sections historical.

### C412-L3 (Low) — The PR description omits the runner and application-driver changes

The description covers the language feature, #413 and #414. It does not mention that the PR also changes shared CPU allocation and affinity (`scripts/platforms.py`, `run_history.py`, `check_lean.py`, `dev.py`), switches every application proof and build to one worker (`src/silver.adb:134,142`), relaxes a sample-policy assertion and raises one test deadline from 300 s to three hours (`tests/test_samples.py:161–166`). The capability record does describe them. Repair: two sentences in the PR body.

### C412-I1 (Info, owner decision) — Application proofs are now serial for every user

`-j0` → `-j1` in `src/silver.adb` is a product change made to satisfy this host's allocation policy. I confirmed the solver portfolio, step, timeout and memory limits and all discharge requirements are unchanged, and that the test still asserts them. The cost is elapsed time: the retained maximal 64-operand case took 6,972.6 s under the serial schedule, where the previous harness deadline was 300 s. The internal CPU review notes the serialisation "on every platform". User-facing documentation states the one-worker setting but not its effect on proof duration. A bounded, explicit worker parameter would be a reasonable follow-up; it is not required for correctness.

### C412-I2 (Info) — The eight-CPU ceiling is a constant for every host

`scripts/platforms.py:18` hard-codes `CPU_LIMIT = 8` in a tracked, provenance-hashed script. It behaves correctly here and smaller counts still win, but it also caps unrelated hosts, and changing it changes proof-provenance inputs.

### C412-I3 (Info) — The stack prerequisite is not captured or applied by the runner

Only `test_counted_bound_review` sets `RLIMIT_STACK` itself. The other source-limit routes depend on the invoking shell, and the managed run record has no stack field. The final suite's wrapper log does record `Invoking stack bytes: 16777216`. Applying the limit inside the tests, or recording `getrlimit` in the run's start event, would make the evidence self-describing.

### C412-I4 (Info) — Admitted shapes covered only by admission checks

These are admitted and, by my reading, behave like already-tested forms, but no retained full route (compile, prove, audit, run) exercises them: a type-prefixed `T'Range` loop inside a callable; a singleton choice written as `(T'First => v)`; object and subtype constraints built from queries; an array formal never referenced at all; a function whose result depends only on bounds of two formals. Optional additions.

### C412-I5 (Info) — Affinity restoration covers only threads present at entry

`scripts/run_history.py:58–92` restores the saved mask for threads that existed when the run started. Threads created during the run keep the narrowed mask after it ends. Harmless for the one-run-per-process launchers; visible only in long-lived processes that start several managed runs.

### C412-I6 (Info, inherited) — A timed-out compile test leaves its provers running

`subprocess.run(..., timeout=…)` kills only `silver`; the evidence itself records this ("its original prover continued after the parent exited", run `20261121T191653-cdd01ba978f7`). With the three-hour deadline this is unlikely, but when it happens the orphaned provers outlive the managed reservation.

## What I examined and found sound

**Native admission versus Ada/SPARK.** I read the complete diffs of the ten Ada files and the surrounding parser for declarations, callable frames, calls and associations, loops, conditions and the lexical scanners. I derived expectations from Ada rules first and then ran 200 admission-only cases; all agree. Three were flagged by my own harness, and in each the compiler was right and my expectation wrong (an unconstrained subscript, full-range arithmetic on a mutable local, and a user type named `Boolean` legitimately used as an array formal type). Points checked:

- Nominal identity is a positive, append-only type index, stable across Main and callable frames; equal shape, anonymous arrays, Boolean arrays, aggregates, parenthesised names and component names are all refused as array actuals.
- The three capacities (`/7` bindings, `/24` types, per-type 1..2048) are unreachable for any source that fits 4,096 bytes, so no admitted program is refused for capacity. Densest sources I could fit were accepted: 147 types, 492 array formals in one function or procedure, and 332 named objects.
- Hiding: loop binders hide types, objects and formals; a binder is masked in its own specification; formals and locals cannot collide with earlier types; types named `Boolean`, `Character`, `True`, `False`, `Put_Line` and `Put` hide the predefined entities in Main and inside callables.
- Staticness: queries are static on types, objects and formals; component reads are not; I found no context where over- or under-claiming staticness could make GNAT reject an admitted program, because no admitted context requires a static expression that Silver would treat differently.
- Full declared component intervals, unused callables, empty and unreachable arms, read-only formals, local initialisers before formal installation, positional, named and mixed association, forwarding, repeated actuals and the scalar alias scan behave as specified.
- The pre-existing lexical scanners (`Work_Tail`, `Xor_Free`, `Guarded_At`, `Actual_Name_Step`) remain correct with attribute apostrophes: no admitted text forms a three-character `'x'` pattern that is not a character literal.

**Lean model and source linkage (sampled, statement level).**

- All 1,083 Lean files at the target are reachable from `Silver.Audit`.
- Endpoint statements are unchanged: `Current.lean`, `PredicateCorrespondence.lean` and `PredicateSourceBridge.lean` have no diff, and `source_actual_string_bounds_assured` keeps `SourceMeaning` as its only hypothesis.
- #414: `Compose.SourceBridge.InterpretedSource` now carries `ArrayImportSource` (direct identities to one interpreted array library and one interpreted scalar reader, with Ada's defaults for masks, sign and read mode) and derives the three laws on their original native domains, with no history or stored-array premise. Both Boolean wrappers take `PredicateImportSource` instead of an assumed helper meaning. The root installs the derived laws into the function source and into the procedure's `helpers.ordinarySource`, which is the only embedded inherited record in `InterpretedHelpers`.
- Typed trees compared with the Ada text by hand for `Read_Array_Attribute`, the `Read_Atom` dispatch, the subscript reader, `Array_Type_At`, `Array_Type_Declaration_At` and the `Loop_Body` Range branch, including grouping, default arguments (`[]`/`false` for omitted `Initials`/`Elaborating`, `false` for `Range_Query`) and the new precedence and prefix guards. No mismatch.
- `ProcedureMetadataMeaning.selectTypes` takes the type table from the same accepted scan that selects the catalogue.
- Model semantics sampled: a query denotes a literal; a Range loop denotes fixed endpoints with definite execution; array arguments are captured in index order and bound to disjoint per-formal segments; formal views contribute the whole component range and are neither mutable, static nor refinable.

**Runner.** I read the allocation, affinity and Lean thread logic and its tests. Reservations use effective workers, CPU IDs come from the inherited mask with unclaimed CPUs preferred, every existing thread is constrained with rescans, error paths restore, and Lean threads are capped by the worker grant with the fingerprint recomputed after the grant. No ordinary correctness defect found beyond I5.

## Claim and evidence reconciliation

| Claim | My independent check | Result |
| --- | --- | --- |
| Probe binary matches the target | Build run `20261121T190603` captured 148 tracked inputs; I rehashed each against the target tree. Binary SHA-256 `74939085…42bf9b` equals the hash the full suite captured. | Match, 0 mismatches |
| Native audit: 78 units, 1,265 entities, 1,775 flow + 18,219 proof = 19,994 | Recounted from the 78 retained `.spark` reports of run `20261121T191055`; all records severity `info`. Its 145 source-comparison hashes equal the target tree. | Match |
| Lean: 1,083 modules, 173,026 declarations, three foundations, endpoint `7f449246ce` | Read the retained log and evidence JSON. All 1,191 captured inputs and all 1,085 workspace inputs (including the 39 generated certificates) are byte-identical to the target's tracked files. No `src`, `proof`, `tests`, `scripts`, `samples` or `catalogue` change after `7f449246ce`. | Match |
| Full suite: 785 identities, all passed, 7,832.123 s | Original log: 785 headers, 785 distinct, 773 inline + 12 wrapped pass dispositions, no failures, errors or skips. | Match |
| 758 + 15 + 12 = 785 | Suite inputs differ from the target only in the six proof files and `rosetta/coverage.json`. I recomputed the import closures of the three closure-based source-policy tests at both commits (none reaches a changed module) and searched every test for real proof-tree reads: two whole-tree scans plus the 13 platform-fixture identities. Rerun inputs match the target except `coverage.json`; the Rosetta rerun's inputs all match. | Match; the selection is complete |
| Inventory: 10 Ada, 347 Lean (48 new, 299 modified), 4 scripts, 17 tests, 3 samples | `git diff --name-only --diff-filter` per area. | Match |
| Three stack fixtures fail at 8 MiB, pass at 16 MiB | Re-measured the retained inputs: minima 10,237 / 11,261 / 9,213 KiB. | Match; see C412-M1 for what they omit |
| Driver results: Dot product 3; Horner 128 at x=3, refusal at x=10 before the fourth update | Recomputed by hand from the sample sources. | Match |

Not rechecked: the advisory classification counts in the native packet's README, the 49,279,744-byte report envelope arithmetic, and the focused-run packets.

## Commands and probes actually run

- Read-only Git and file inspection in the detached worktree; `gh pr view 412` for PR metadata and description (read only).
- Small Python computations over retained evidence (hash comparisons, report and log recounts, import-closure and reachability scans).
- `silver check` only, with the retained binary, on sources in `scratch/probe/src/`: 200 admission cases (`batch1.py`–`batch7.py`, results in `results-admission.txt`) and stack bisection runs (`stack1.py`–`stack9.py`, summary in `results-stack.txt`), serial, under an explicit `RLIMIT_STACK`.
- A handful of `silver check` runs with the main-checkout binary for the baseline comparison in C412-M1. This was not among the binaries named for probing and its build provenance is not established; I report those numbers as indicative only.

No compile, prove, run, Lean build, test suite, bootstrap, install or cache mutation was performed. No repository file, branch, issue or PR was modified. No `questions.md` was needed.

## Limits

- No compiled or proved program, so nothing here shows that GNATprove discharges, or the report policy accepts, any shape beyond the retained full routes. My statements about producer behaviour are reasoning from the sources and the unchanged policy code.
- The Lean review is a sample of roots, changed tree languages and statement shapes, not a reading of all 347 changed files, and not a kernel replay.
- The treatment of formal-array queries as static rests on RM 4.9(8) and (32); I did not compile a test of GNAT's classification, and I argue above that admission does not depend on it.
- Leaf "primitive" meanings in the array, function and procedure binding bridges (for example `validNameState`) remain assumed fields of their interpreted sources. That is the inherited convention, extended but not introduced here, and I did not review it afresh.
- Linux x86_64 only. No ARM64, no macOS.
- This is a review of base..target and its affected compositions, not a fresh comprehensive review of unrelated inherited code.
