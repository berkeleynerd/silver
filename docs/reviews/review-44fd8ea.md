# Review of 44fd8ea, "Admit fixed-length string assignment"

Reviewed on 2026-10-10 on the owner's Mac (macOS ARM64), from a detached worktree
of `44fd8ea`. Scope is everything after the last review (`b8b263d`): the history
rewrite, `f382b11`, `6403b5c` and `44fd8ea`. Read-only on tracked files. Logs,
probes and experiments are in `tmp/review-44fd8ea-logs/`.

## 0. Verdict

**No blocker, high or medium finding survived verification. Further language
expansion may proceed.**

The seventh form is sound as specified. Under fully native conditions:

- the SPARK proof passed with the commit's exact totals;
- every admitted variant I tried compiled and printed the right bytes;
- every excluded variant was rejected;
- the new report checker rejected every report mutation it should, and
  accepted exactly the real report shapes;
- the full Lean verification passed from an empty workspace, with standard
  axioms only and a fresh kernel replay;
- the compiled Ada recognizer and the Lean recognizer agreed on all 423
  sources tried;
- all 156 tests passed.

What remains is low-severity precision and test hygiene. The smallest justified
work, in order:

1. **Restore the existing-clone guidance** that 44fd8ea cut from `RESUME.md`
   (L1). This checkout is such a clone: `main` is still on the pre-rewrite
   history. Decide what to do with it before the next `git pull`.
2. **State the seventh form's premises in one place** (L2). Say three things:
   static elimination of the length check is a trusted frontend premise; the
   "two report shapes" are an observed completeness premise that fails closed;
   and the scope of "other warnings still prevent publication".
3. **Add the missing `Is_Assignment_Member` header check** to the Lean source
   bridge (L3). It is one conjunct with no certificate change.
4. **Tighten the tests** (L4, L5): make the Python helper's mutation tests
   isolate each predicate, and add native rows for the other GNAT "junk" names
   that assert the report shape.

None of these blocks the next increment.

## 1. Scope and method

- **Commits.** The remote history was rewritten (owner-authorized) to drop the
  `silver/` and `tools/` transfer archives. Tree comparison shows each rewritten
  commit differs from its original only by those 151 archive files
  (`b8b263d` ≡ `b3f7e00` minus archives). New content is `f382b11` (remove
  archives from the tree; docs), `6403b5c` (disposition of the previous review;
  docs) and `44fd8ea` (the seventh form: 43 files, +16,256/−11,188, mostly the
  regenerated output-body certificate).
- **Isolation.** Local `main` is at the pre-rewrite `b8b263d`. To stay read-only,
  I created a detached worktree at `tmp/review-44fd8ea-worktree`. I APFS-cloned
  `.tools/macos-aarch64` into it (16 Alire-index `.git` files copied outside the
  sandbox) and bootstrapped offline. Nothing in the main checkout's tracked files,
  `.tools/` or `.silver/` was changed.
- **Parallel review.** Four read-only reviewers covered the Lean proofs, the Ada
  recognizer and report policy, docs and claims, and tests and tooling. I
  verified each of their findings against the code or by experiment before
  including it. Two of their claims were wrong and are corrected in §6.
- **Native checks.** I ran these myself: full SPARK proof, compiler build, full
  test suite, full Lean check, 54 compile-and-run probes, a 423-source
  Ada-vs-Lean recognizer comparison (with 55 further compile-and-runs), 49 mutations through the native report
  checker, a GNATprove warnings experiment and a mutation test of the Python
  evidence helper.

## 2. Native validation (macOS ARM64)

Host: Apple M4 Pro, 12 cores, 24 GiB; macOS 27.0.1; Python 3.14.8; FSF GNAT and
GNATprove 16.1.0, GPRbuild 26.0.0 (Alire); Lean 4.34.1. This is FSF GNAT, not
GNAT Pro.

| Check | Result |
| --- | --- |
| `python3 scripts/bootstrap.py`, `scripts/bootstrap_lean.py` | Passed offline (6 s, 3 s). |
| `python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=review-44fd8ea` | **Passed: 2,907 checks** (407 flow, 2,500 proof), 16 units, 213 entities, 40 limitation notes, 14 imported entities. Identical to the commit's Linux x86-64 totals. Effectively cold: fresh worktree, solver cache created empty at the start, fresh sessions. 13 min 7 s. |
| `python3 scripts/dev.py build` | Passed (6 s). |
| `python3 scripts/dev.py test` | **Passed: 156 tests**, including all seven samples proved, built and executed, and the new assignment module. 371 s, overlapping the Lean build. |
| `silver catalogue` vs `catalogue/silver.json` | Equal as JSON. |
| `python3 scripts/check_lean.py --full` (all-core defaults: 12 workers × 12 threads, no memory threshold) | **Passed:** 75 modules, 86 Lake jobs, **21,443 declarations**, only `propext`, `Classical.choice` and `Quot.sound`, and `leanchecker --fresh` succeeded. Evidence hashes 100 shared inputs, 77 workspace inputs and 150 artifacts, the same counts as the commit's Linux corroboration. Every module was built from source, because the worktree's proof workspace was new and empty. (`clean_replay: false` only records that `--clean` was not passed.) 9,395 s in total; `OutputBodyCertificate` alone took 8,074 s (Linux: 8,284 s). Overlapped the SPARK proof, probes and test suite. |
| 54 native assignment probes (`probes/assign_probe.py`) | **54/54 as expected.** Details in §5.1. |
| Ada vs Lean recognizer comparison (`differential/`) | **0 disagreements on 423 sources**: the 54 probes plus 369 hand-written and randomly mutated assignment and earlier-form programs. The compiled `silver check` and Lean's `Current.accepts` (interpreter `#eval` on the built modules) agree on all of them. 106 admitted by both (94 classified by Lean as the assignment form); 317 rejected by both. The 55 assignment-form corpus programs not already probed were then compiled and run: **55/55 printed exactly their decoded replacement literal plus LF** (`differential/run_admitted.log`). |
| Report-checker mutations (`reports/mutate_assignment.py`) | **44/44 targeted mutations as expected**, plus five earlier-form reports. Details in §5.2. |
| GNATprove warnings experiment (`warnings-exp/`) | See §5.3. |
| Python evidence-helper mutants (`mutation/`) | 6 of 9 deleted predicates survive the helper's tests. See L4. |

## 3. What the seventh form rests on

| Class | What it covers |
| --- | --- |
| (a) Lean, machine-checked | The 33-token grammar, equal to the Ada token array. Decoded-length equality (`assignment_length`). Name binding of target and output (`meaning_binds`). Unique meaning. The fixed-length mutation model (`assign`, `assignment_preserves_constraint`). Output = replacement (`evaluation_refines`, `execution_refines`). Disjointness from all six earlier forms, both directions. `Current` membership, meaning, output-domain and obligation integration. Source correspondence for `Assignment_Suffix_Matches`, `Literal_Length`, `Is_Assignment_Member` and `Is_Member` bodies, the suffix and `Accepts_Assignment` contracts, the token constant and index subtype, and the report-route selector (`authoritative_assignment_member_iff`). |
| (b) GNATprove | `Accepts_Assignment` = `Is_Assignment_Member` (imperative loop vs ghost). `Complete_Assignment_Proof` = `Assignment_Report_Policy` (executable vs static ghost policy). Driver report-route contracts. The fixed library bodies' obligations on every application compile. |
| (c) Reviewed Ada interpretation | RM 3.3.1 (the literal initializer fixes the bounds) and RM 5.2 (assignment checks length and preserves bounds). The model stores length only; bounds and lower bound 1 are reviewed. The mapping from the `Assignment_Mode` flag to the exact command text. |
| (d) Trusted premises | The frontend faithfully parses Main and statically eliminates the satisfied length check (`generationFaithful`). GNATprove reports faithfully. Compilation preserves behaviour. **Every admitted assignment program yields one of the two accepted report shapes** (a liveness premise: a third shape fails closed). Existing I/O, libc and runtime premises are unchanged. |

The empty obligation set for this form is definitional in Lean: an assignment
program is folded into `.outputMain`, which has no checks. Discharge is still
complete. Lean proves the check would hold, the report policy requires an empty
proof list, and the elimination is a stated premise. The docs say so in
`assurance.md`; L2 is about saying it everywhere.

## 4. Findings

Ordered by severity. "Verified" means I confirmed it in the code or by experiment.

### Low

**L1. Existing-clone guidance after the history rewrite was cut.** Verified.

- At `6403b5c`, `RESUME.md:100-102` said: preserve local work and ignored
  artifacts, use a fresh clone of the rewritten remote, and do not merge *or
  push* the old history. `44fd8ea` (`RESUME.md:84-93`) keeps only "Do not merge
  the old archive-bearing history".
- `README.md:31-32` and `docs/host-readiness.md:228-229` still send readers to
  `RESUME.md` for "existing-clone guidance". `README.md:23` still calls
  `RESUME.md` a "VM replacement checklist".
- **This matters here.** This Mac's `main` is `b8b263d` on the old history, and
  `origin/main` is `44fd8ea`; they share only `69d294c`. A plain `git pull`
  would merge the archive-bearing history back.
- **Fix:** restore the 6403b5c paragraph, or a two-line equivalent, in `RESUME.md`.
- **For this checkout (owner's decision):** after preserving `.silver/`,
  `.tools/`, `tmp/` and `.vscode/`, either reclone or reset `main` to
  `origin/main` (the old commits stay in the reflog until it expires).

**L2. The seventh form's premises are stated precisely only in `assurance.md`.** Verified.

- **Stated as fact.** `language.md:432-433` says "The pinned tools eliminate the
  statically satisfied length check". `assurance.md:488-490` and
  `string-assignment.md:83-84` correctly call that a trusted premise that native
  runs corroborate.
- **Not named in the trusted boundary.** `trusted-boundary.md:368-371` mentions
  RM 3.3.1/5.2 and "a statically satisfied length check", but does not name:
  - the frontend's static elimination as a premise; or
  - the observed-shape premise that every admitted program yields one of the two
    accepted Main-report shapes.
  The second premise fails closed: a third shape would be rejected, which the
  docs themselves call an implementation defect for admitted source.
- **Lean docstring.** `Current.lean:449-457` (`ToolContract`) says checks "may
  be … omitted by optimization". For this form, omission is required by
  `generationFaithful`.
- **Warnings scope.** `trusted-boundary.md:461-464`, `language.md:435-436` and
  `assurance.md:497` say other warnings still prevent publication on the
  assignment route. The §5.3 experiment shows what that means:
  - GNATprove never gated on frontend warnings: a `Compile_Time_Warning` passes
    even with `--warnings=error`.
  - GNATprove's own warnings, such as INEFFECTIVE on another variable, do fail
    `--warnings=error`. They are also recorded in the `.spark` flow list, which
    the assignment policy rejects unless the record is the one exact advisory.
  - So the relaxation is narrow. The residual premise is that every relevant
    GNATprove warning on Main is recorded in `main.spark`.
- **Fix:** one short consolidated paragraph in `trusted-boundary.md` with a
  pointer from `language.md`, and one sentence in the `ToolContract` docstring.

**L3. `Is_Assignment_Member`'s header is fixed only by the shape pin.** Verified.

- `GuardedSourceBridge.lean:96-97` checks
  `functionHeader "is_guarded_member" "is" … "(Source : String) return Boolean"`.
- There is no corresponding conjunct for `is_assignment_member`. The body check
  (`:27`) skips the parameter list and result type.
- `authoritative_assignment_member_iff` reads that body as a function of its
  sole `Source : String` parameter.
- Risk is low: Ada spec conformance would catch most edits. It is still a parity
  gap in source correspondence, which is mandatory.
- **Fix:** one `functionHeader … = some (expectedTokens "(Source : String)
  return Boolean")` conjunct, closed by the existing `decide +kernel`. No Ada or
  certificate change.

**L4. The Python evidence helper's assignment tests do not isolate its predicates.** Verified by mutation.

- I deleted one condition at a time from a scratch copy of
  `scripts/check_evidence.py` and reran its assignment tests
  (`mutation/mutants.log`).
- The tests **still passed** with the `rule`, `file`, `line`, `col`, `entity`
  or message-pattern check removed. Only removing `severity`, `how_proved` or
  the suppression check failed them.
- Cause: the mutated `main.spark` disagrees with the unchanged SARIF, so some
  other check raises first (`tests/test_evidence.py:115-136` only expects *an*
  `EvidenceError`).
- The admission-path checker is the SPARK `Complete_Assignment_Proof`, which
  rejected every one of these mutations natively (§5.2). This is a test-quality
  gap in development evidence tooling, not an admission gap.
- **Fix:** `assertRaisesRegex(EvidenceError, "^assignment: unexpected flow
  diagnostic")`, or rewrite the SARIF consistently for each mutation.

**L5. Native report-shape coverage has one witness for the dependency shape.**

- `tests/test_string_assignment.py` compiles nine programs; only
  `Unused_Message` produces the shape without the advisory. No test asserts
  which shape a program produced.
- This review compiled 13 more junk and near-miss names (§5.1). GNAT suppresses
  the advisory for names containing `unused`, `dummy`, `junk`, `discard`,
  `ignore`, and also `tmp`/`temp`. `Not_Used` keeps it. All compiled correctly.
- The reviewer rated this medium. I rate it low: behaviour is now natively
  verified, and an unexpected shape fails closed.
- **Fix:** add a few of these names to the native table and assert the shape.
  Add to the Ada checker tests the two conditions I exercised only in §5.2: the
  identifier pattern in the message, and the 4,096-character name bound.

**L6. `assurance.md:840-841` calls model theorems source-bridge "checks".** Verified.

- It says `AssignmentSourceBridge` adds "fixed-length mutation … checks".
  `CheckedSource` has no fact about mutation. The mutation semantics is the
  Lean model, tied to Ada by reviewed interpretation.
- **Fix:** "plus the fixed-length mutation model theorems".

**L7. Stale current-tense count.** Verified.

- `docs/command-line-greeting.md:3-4` says "The current language has six
  productions", and `:271` says "No next feature is selected."
- **Fix:** past tense.

### Info

- **I1. Which report shape is "normal".** The effects-dependency shape
  (`CLAIM_EFFECTS(Main)` on `CLAIM_EFFECTS(Put_Line)`) is GNATprove's ordinary
  output: every earlier-form Main report I inspected has it. The INEFFECTIVE
  shape is the variant, in which GNATprove also withholds its effects claim for
  Main. The docs present it the other way round ("the warning-free dependency
  shape occurs for legal names such as `Unused_Message`"). The earlier null
  policy ignores `assumptions` entirely, so the new two-shape policy is stricter
  than its predecessors. Nothing in the Oracle depends on the effects claim.
- **I2. Shape-based policy.** The assignment policy accepts the literal-backed
  greeting's Main report, because it has the same shape (§5.2). Correct
  behaviour rests on route selection. That rests on the GNATprove-proved
  `Accepts_Assignment` contract and the Lean `authoritative_assignment_member_iff`.
  The guarded route rejects the assignment report, and vice versa.
- **I3. Independent mode flags.** `Dynamic_Mode` and `Assignment_Mode`
  (`silver.adb:79-80`) are computed independently. Their exclusivity is proved
  only in Lean (`AssignmentDisjoint`). Both policies fail closed if both flags
  were ever true. Optional: compute `Assignment_Mode` as `not Dynamic_Mode and
  then …`.
- **I4. `Initializer_Message` accepts any identifier**, not specifically the
  declared one. This is sufficient: the record must be in `main.adb`, on entity
  Main, with rule `INEFFECTIVE`, and the grammar has one initialized object.
  "Precisely identified" in the docs could read "exact message shape".
- **I5. `assurance.md:469-471` "same nodes".** The composition shares typed
  nodes only in its three expression slots; the statement skeleton is fixed
  text. `rendered_tokens` and `evaluation_refines` pin both. This follows the
  concatenation precedent.
- **I6. Partial `#print axioms` list.** `Audit.lean` omits the six disjointness
  theorems and `checked_source`. The `run_cmd` audit covers every declaration,
  so there is no gap.
- **I7. Small doc inconsistencies.**
  - `lean-concurrency.md:118-122` still recommends `--memory-mb 6144`;
    `RESUME.md` uses 12288.
  - The disposition of the previous review (`command-line-greeting.md:228-271`)
    does not say what happened to D5 or D8–D11. Item 4 still calls runtime
    concatenation a "frontend premise" without naming code generation or the
    runtime routine.
  - `architecture-review.md:22-23` counts 18 Python test modules; 17 are tracked.
- **I8. The architecture review's recommendation 1 is open.** `check_lean.py`'s
  end-of-run inventory can miss newly added files. It is self-reported, and
  the right next tooling repair before relying on future Lean evidence runs.
- **I9. Sample-meaning theorem.** No exact theorem ties `samples/string_assignment.adb`
  to its program. This is consistent with the owner's recorded deferral for the
  guarded sample; noted, not re-raised.

## 5. Experiments

### 5.1 Native compile-and-run probes (54)

Each case was checked, compiled, executed and compared byte-for-byte with the
expected output (`probes/results.jsonl`, `probes/batch1.log`). Compile time was
about 4.4 s each.

- **Names (28 admitted).**
  - Baseline `Message`.
  - Junk names `Unused`, `Unused_Message`, `Dummy`, `Dummy_Message`, `Junk`,
    `Discard`, `Ignore`, `Ignored_X`, `Myjunk`, `X_UNUSED_Y`, `Tmp`, `Temp`.
    All took the dependency shape.
  - Every other admitted name took the INEFFECTIVE shape: `Not_Used`, `Main`,
    `Silver_Arguments`, `Put_Line`, `Standard`, `Ada`, `Integer`, `Character`,
    `Boolean`, `Silver_Runtime`, `Silver_Output_Libc`, `Max_Length`, `M`, mixed
    case, and a 901-character name.
- **Literals and layout (11).**
  - Empty/empty.
  - Identical values.
  - `""""`/`"B"` and its reverse.
  - `"ab"`/`""""""` (decoded lengths equal, raw spans differ).
  - Dashes and `:=` inside literals.
  - 4,095- and 4,096-byte sources.
  - Compact layout.
  - Comments, CR/LF and tabs, including between `:=` and the literal.
- **Rejections (15).** Unequal lengths. Raw-equal but decoded-unequal
  (`"abcd"`/`""""""`). Index constraint. `constant`. Two assignments. Wrong
  target. Wrong output name. Name-to-name. Split `: =`. `String`, `Silver_IO`,
  `Some`, `Parallel` and `Interface` as names. A 4,097-byte source.
- **Console warnings.** The only warning in any compile transcript was the
  expected `initialization of "<name>" has no effect`.

### 5.2 Native report-checker mutations (49)

I built `tests/library_reports_probe.adb` against the reviewed sources and fed
it real reports from §5.1 plus mutations (`reports/mutate-assignment.log`).

- **Accepted, as expected:**
  - both real shapes, compact and pretty-printed;
  - the empty shape;
  - a 4,096-character name in the message.
- **Rejected, as expected:**
  - **Message text:** a two-name message, a 4,097-character name, `A__B`,
    `A_`, `1A`, an empty name, other text, a `a` escape.
  - **Record fields:** severity error/medium/info, other rule, `prover`, other
    file, line 0, string column, unknown entity, `justification`, `suppressed`.
  - **Records and shapes:**
    - two advisories;
    - advisory plus dependency;
    - an extra or self dependency, two claims or a `CLAIM_AORTE` claim;
    - an extra entity;
    - a nonempty proof list in either shape;
    - `spec` coverage;
    - nonempty or missing `skip_proof`, `skip_flow_proof`, `pragma_assume` or
      `warn_error`;
    - missing `assumptions`;
    - other `progress` or `stop_reason`.
  - **Cross-route:** the assignment report under the guarded route.
- **Earlier-form reports under the assignment policy:** the literal-backed
  greeting report was accepted, since it has the identical shape (I2). The null,
  command-line and guarded reports were rejected.

### 5.3 What `--warnings=continue` relaxes

I ran GNATprove directly (`dev.py tool -- gnatprove … --subdirs=explore/…`) with
the route's exact options on scratch workspaces in `warnings-exp/`.

| Source | `--warnings=error` | `--warnings=continue` | In `main.spark`? |
| --- | --- | --- | --- |
| Assignment form plus `pragma Compile_Time_Warning (True, …)` | exit 0 (named-constant variant) | exit 0 | No; no console warning either |
| Assignment form plus a duplicate `with` | — | exit 0 | No |
| Named constant plus an unused initialized variable | **exit 1** | exit 0 | Yes: flow `INEFFECTIVE` warning |
| Unknown pragma | exit 1 (SPARK error) | exit 1 | — |

`warn_error` stayed `[]` in every case, including the `--warnings=error`
failure.

Conclusions:

- Frontend warnings never gated publication in either mode.
- GNATprove's own warnings did gate under `error`. They also appear in the
  flow list, where the assignment policy rejects everything except the one
  exact advisory.

## 6. Corrections to delegated reviews

- **"Not a cold proof run" — wrong.** The Ada reviewer said my proof run reused
  the native solver cache. The cache directory was created at the run's start
  (15:22:15) in a fresh worktree.
- **"Warnings are recorded in `warn_error`" — wrong.** The docs reviewer
  supported "other warnings still prevent publication" this way. §5.3 shows
  `warn_error` stays empty even when `--warnings=error` fails. The claim holds
  for a different reason: GNATprove warnings are in the flow list.
- **TEST-01 rated medium — downgraded to low (L5).** Behaviour is natively
  verified here and an unexpected shape fails closed.
- **TEST-02 rated medium — confirmed by mutation, rated low (L4).** It concerns
  the development helper, not the admission checker.

## 7. The other commits and the history rewrite

- **History rewrite.** Accurately described in `docs/host-readiness.md`. Every
  rewritten commit's tree equals its original minus the archive paths. The
  Oracle is unchanged across `b3f7e00..44fd8ea`.
- **`f382b11`.** Accurate. It removes the archives from the tree and updates
  the handoff docs.
- **`6403b5c`.** It records the previous review's disposition. The cited fixes
  are present:
  - D1: Lean defaults, `assurance.md:654ff`;
  - D3: the TCB GNATprove row, `trusted-boundary.md:18`;
  - D6: `-M` wording;
  - D7: direct-Lake wording;
  - D2: the runtime-concatenation note (in narrower form, I7).
- **Owner decisions in the record.** macOS records are now "entirely optional",
  and the exact-sample meaning theorem is deferred. This review respects both;
  the native results here are optional corroboration.

## 8. Side effects and state

- **New, all under `tmp/`.**
  - The worktree `tmp/review-44fd8ea-worktree` (detached at `44fd8ea`; adds
    `.git/worktrees/review-44fd8ea-worktree`).
  - Its own `.tools/macos-aarch64` (APFS clone, 4.9 GB logical, mostly shared
    blocks) and `.silver/macos-aarch64` (551 MB: compiler, proof workspace
    and native Lean evidence for `44fd8ea`, solver cache).
  - Logs and experiments under `tmp/review-44fd8ea-logs/` (19 MB), including
    GNATprove scratch workspaces in `warnings-exp/` and the report-checker
    probe build in `reports/probe-build/`.
  - Probe compile workspaces were deleted after their reports were copied.
- **Unchanged.** The main checkout's branch, index, tracked files, `.tools/`,
  `.silver/`, earlier `tmp/` reports, `.vscode/` and stash.
- **Remote.** `git fetch` failed (SSH is not available in the sandbox); nothing
  was fetched or pushed. The remote-tracking refs already showed `44fd8ea`.
- **Removing the worktree** (when wanted):

```bash
git worktree remove --force tmp/review-44fd8ea-worktree
```

## 9. Ordered actions

1. L1: restore existing-clone guidance; decide how this checkout adopts the
   rewritten history.
2. L2: one consolidated premise paragraph, the `language.md` wording, and the
   `ToolContract` sentence.
3. L3: the `is_assignment_member` header conjunct.
4. L4 and L5: isolate the Python helper's mutation tests; add native shape rows
   and the two Ada-checker message cases.
5. L6, L7 and I7: wording fixes, when those files are next touched.
6. Before relying on future Lean evidence, the architecture review's
   inventory repair (I8).

## Appendix: commands

```text
git worktree add --detach tmp/review-44fd8ea-worktree 44fd8ea
cp -c -R .tools/macos-aarch64 tmp/review-44fd8ea-worktree/.tools/
cd tmp/review-44fd8ea-worktree
python3 scripts/bootstrap.py && python3 scripts/bootstrap_lean.py
python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=review-44fd8ea   # outside sandbox
python3 scripts/dev.py build
python3 scripts/dev.py test                                                # outside sandbox
python3 scripts/check_lean.py --full
python3 -I ../review-44fd8ea-logs/probes/assign_probe.py ../review-44fd8ea-logs/probes/assign_cases.py
python3 -I ../review-44fd8ea-logs/reports/build_probe.py . ../review-44fd8ea-logs/reports/probe-build
python3 -I ../review-44fd8ea-logs/reports/mutate_assignment.py <probe> ../review-44fd8ea-logs/probes/kept <reports…>
python3 -I ../review-44fd8ea-logs/mutation/run_mutants.py . ../review-44fd8ea-logs/mutation
python3 -I ../review-44fd8ea-logs/differential/gen_corpus.py
lake env lean ../review-44fd8ea-logs/differential/AssignmentDifferential.lean   # from .silver/macos-aarch64/proof
```
