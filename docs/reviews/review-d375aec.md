# Review of d375aec, "Add focused Lean checks and optional replay"

Reviewed 2026-10-11 on the owner's Mac (macOS ARM64), from a detached worktree
of `d375aec`. Scope is everything after the last review (`1ed039e`):

- `fe539a5`: per-file Lean source bindings and Lake dependencies, and
  extraction of the lexical helpers into `Silver_Output_Lexical`;
- `d375aec`: `--target`, optional `--replay` and `--provenance`, and the
  scoped axiom audit.

Work was read-only on tracked files. Logs, probes and agent notes are in
`tmp/review-d375aec-logs/`. macOS proofs are an owner non-goal; these native
runs are optional reviewer evidence.

## 0. Verdict

**One medium finding; no blocker or high finding.**

**What works.** The compartmentalization does what it claims, and the
lexical extraction is behaviour-preserving:

- **Extraction.** The moved Ada is token-identical. On 2,651 sources (plus
  1,587 in my own set), the 1ed039e and d375aec compilers produce identical
  verdicts and messages, and byte-identical catalogue output. GNATprove still
  proves 3,029 checks. The 12 new limitation notes are exactly the moved
  recursive helpers' notes repeated in the importing unit.
- **Invalidation.**
  - An edited embedded Ada file rebuilds exactly its binding and certificate,
    including comment-only and CR/LF edits with restored mtimes.
  - A non-embedded edit rebuilds nothing.
  - Token changes fail in the right bridge.
  - Even deliberately broken library ownership fails closed: the certificate's
    exact-byte reconstruction rejects the stale binding.
- **Cost.** Complete Lean with replay took 81 min here (3.5 h at `1ed039e`).
  The output-body certificate took 4,106 s (previously 10,384 s), and the
  replay 563 s (previously 1,626 s). A focused check and a cached complete
  check each take about 2.8 s.

**M1, the medium finding.** With replay optional, the routine complete check
no longer detects proofs added with kernel checking disabled. I demonstrated
this natively. A module containing

```lean
set_option debug.skipKernelTC true in
theorem Silver.bad : 2 + 2 = 5 := by decide +kernel
```

builds, passes the real `#silver_audit` ("Silver axiom audit passed"), and is
rejected only by `leanchecker --fresh`. Before `d375aec`, the mandatory `--full`
checkpoint caught this. The fix is a few lines: a source scan in the runner
plus a policy test. Replay can stay optional.

**On further expansion:** yes, once M1 is fixed or its premise is stated.
After that the routine checkpoint is the Lean evidence for new productions,
so it must not be able to pass an unchecked proof.

**Handoff problem.** My final reports for `44fd8ea` and `1ed039e` evidently
never reached the implementing session. Its dispositions cite only my
interim progress messages: `input-branching.md:163-182` says "verified
findings were still pending … Reassess a specific final finding if one is
supplied". So most carry-over items are unaddressed through no fault of the
implementer.

**Smallest justified work, in order:**

1. **M1:** reject `debug.skipKernelTC` and kernel-bypassing meta
   (`addDeclWithoutChecking`) in every workspace `.lean` file and the
   lakefile before building, with a policy test. Or state the premise in the
   trusted boundary and in `lean-iteration.md`.
2. **Supply the final reports to the implementer** (`tmp/review-44fd8ea.md`,
   `tmp/review-1ed039e.md`, this file) and record a disposition per item
   (L1).
3. **Tests for the new routine mode:**
   - default-mode drift and closure tests;
   - in-place byte drift;
   - a real-Lean `#silver_audit` regression (L2, L4).
4. **Keep a name-pin list in `Audit.lean`** (L3), and fix stale text (L5, L6).

## 1. Method

- **Isolation.** I created a detached worktree `tmp/review-d375aec-worktree`
  with an APFS-cloned toolchain and bootstrapped it offline. Your checkout's
  `main`, tracked files, `.tools/` and `.silver/` were not modified.
  `git fetch` updated only remote-tracking refs.
- **Multi-agent review (102 agents).** Six read-only reviewers covered:
  - the Ada lexical extraction;
  - the Lean source bindings;
  - Lake invalidation;
  - the runner modes;
  - docs and policy;
  - tests.

  Three skeptics then tried to refute each finding (code truth, reproduction,
  severity/policy), and a completeness critic added two gap reviews. Of 31
  findings, 28 survived.
- **Native probes.** All of the reviewers' native probe requests were run
  here; results are in §4.

## 2. Native validation (macOS ARM64, optional)

Host: Apple M4 Pro, 12 cores, 24 GiB; macOS 27.0.1; FSF GNAT and GNATprove
16.1.0; Lean 4.34.1. This is FSF GNAT, not GNAT Pro.

| Check | Result |
| --- | --- |
| `dev.py prove --full --jobs 4` | **3,029 checks** (412 flow, 2,617 proof), 17 units, 216 entities, 53 limitation notes (41 before; the +12 are documented in `lean-compartmentalization.md:70`). Cold. |
| `dev.py build`, `dev.py test` | Passed. **186 tests** in 334 s. |
| `check_lean.py --replay --provenance` | **Passed:** 98 modules, 111 Lake jobs, **23,516 declarations**, standard axioms only. `leanchecker --fresh` passed. Phases: build 4,281 s (`OutputBodyCertificate` 4,106 s; certificates now build in parallel), audit 1.1 s, kernel 563 s. Total 4,849 s from an empty workspace, overlapping the proof, tests and workflow. Evidence: 123 inputs, 100 workspace inputs, 196 artifacts. Preserved in `preserved-complete-replay/`. |
| `check_lean.py --target Silver.BranchingMain` (3 runs) | 2.75–2.82 s; 14-module closure; audit of 2,047 declarations; separate `lean-focused-evidence.json` (`scope: focused`). |
| `check_lean.py` (cached complete, 3 runs) | 2.81–2.87 s; audit of 23,516 declarations. It replaces `lean-evidence.json` with `mode: incremental`, `kernel_recheck: null`. |
| Old vs new compiler (`differential/old_vs_new.py`) | 1,587 sources from earlier reviews: identical exit codes and messages; catalogue byte-identical. |

## 3. Findings

### Medium

**M1. Routine complete checks accept kernel-unchecked project declarations.**

- **Mechanism (pinned Lean 4.34.1).**
  - `Lean/AddDecl.lean:22-27` adds a declaration without kernel checking
    when `debug.skipKernelTC` is set in the command's options.
  - `decide +kernel` relies solely on that kernel check
    (`Lean/Elab/Tactic/Decide.lean`). The certificates use it throughout.
  - `AxiomAudit.lean:16-17` inspects only the *audit process's* options.
  - `development.md` now lists plain `check_lean.py` as the checkpoint;
    replay runs only with `--replay` (`check_lean.py:421`).
- **Native demonstration** (`probe-runs/docs-P1-skipkernel.log`, and
  `tests-P3-audit.log` case `Bypass`):

  | Phase | Result |
  | --- | --- |
  | build | exit 0 |
  | audit | exit 0, "Silver axiom audit passed" |
  | `leanchecker --fresh` | exit 1, "while replaying declaration 'Silver.bad._proof_1_1'" |

- **Scope** (`gapF1-P1/P2`):
  - A package-wide lakefile `-D` setting is caught by the complete check
    ("Kernel type checking must remain enabled"), though not by a focused
    check.
  - A module-level `set_option … in` is caught by neither.
  - Library-scoped `moreLeanArgs` on a one-module library are caught by
    neither (scenario B).
  - A package-wide bypass that is later reverted leaves the cached
    unchecked object in place, because `weakLeanArgs` are untraced. The
    next routine complete check then passes and only replay fails
    (scenario C: `C4_complete_audit_exit=0`, `C5_replay_exit=1`). So
    even a transient bypass poisons the cache for routine checks.
- **Why it matters.** It is not a hostile-workspace concern. The vector is a
  tracked, reviewed proof file or the generator, and the project already
  rejects axioms and `sorry` mechanically. Disabling the kernel is the third
  way a proof body can escape checking, and the slow certificates make it a
  plausible shortcut. `lean-iteration.md:61-66` says scratch checks exercised
  "disabled kernel checking", but the guard covers only the audit process.
- **Fix.** Scan for `skipKernelTC`, `addDeclWithoutChecking` and
  `Kernel.Environment.addDeclCore … false` in protected `.lean` inputs and the
  lakefile, excluding `AxiomAudit.lean`'s own check. Add a `test_lean_source`
  policy test. Alternatively, document the premise in the trusted-boundary
  Lean row.

### Low

**L1. Final review reports have not reached the implementer; carry-over items are open.**

- Dispositions exist only for my interim summaries
  (`string-assignment.md:65-89`, `input-branching.md:163-182`).
- Still open from the final reports, each verified at `d375aec`:
  - the `is_assignment_member` header conjunct (now shown closable by
    `decide +kernel` in 4 s, together with the output-side
    `comment_end`/`trivia_end`/`token_at` headers; `agents/lean-binding/probe_headers.out`);
  - runner in-place byte-drift tests;
  - the branching regression rows (literal-then adjacency, real-driver route
    negatives, Static pre/invariant pins), all natively verified in the
    1ed039e review;
  - the `assurance.md` "fixed-length mutation … checks" wording;
  - the static-elimination premise wording, plus `RESUME.md`'s claim that the
    trusted boundary states it;
  - stale comments and text (`silver_reports.ads:10-12`, `lean-concurrency.md`
    6144 MiB and "unmeasured proposal", the README `RESUME.md` description).
- **Fix:** supply the final reports; record one disposition line per item.

**L2. The new routine mode has only happy-path runner tests.** Verified by mutation.

- The code is correct: `verify_run_inputs` runs after every phase in every
  mode (`check_lean.py:416`, `:452`, `:466`).
- But every negative phase test uses `--full` or `--target`. These mutants
  survive the runner suite:
  - `routine_complete_all_verify_skipped`, `routine_complete_loop_verify_skipped`
    and `routine_skips_closure_check`;
  - `shared_bytes_to_inventory` and `workspace_bytes_removed` (in-place byte
    drift, still untested; previous L3);
  - `no_kill_on_exception`.
- **Fix:** parametrize `check_fails`, the drift tests and the module-closure
  tests over `([], ["--full"])`, and add in-place edit subtests.

**L3. `Audit.lean` lost its 136 named `#print axioms` pins without disclosure.**

- I compiled the old list against the new build: all 136 theorems still exist
  and use only the standard axioms (`agents/runner-modes/print_axioms_1ed039e.out`).
- But nothing now fails if one is renamed or deleted. At least 23 are not
  referenced elsewhere in `proof/`.
- **Fix:** keep a `#check`/`#print axioms` list of the cited headline
  theorems (negligible cost), or record the removal as a decision.

**L4. No automated regression of the real `#silver_audit`.**

- All runner tests mock Lean.
- The probes show the real audit behaves correctly: it rejects a direct or
  transitive axiom, `sorry`, a private axiom, the `native_decide` auxiliary
  axiom and an audit-process `skipKernelTC`. It also scopes focused audits and
  reports `Silver.Audit` (`probe-runs/runner-P2-axiomaudit.log`,
  `tests-P3-audit.log`).
- **Fix:** promote those fixtures into the existing pinned-Lean-gated tests.

**L5. Stale descriptions after the mode change.**

- The dormant CI step "Replay all Lean proofs …" runs `--clean`, which no
  longer replays (`verify.yml:83`).
- `platform-coexistence.md:30-31` says compiled artifacts and logs are always
  fingerprinted; that now happens only with `--replay`/`--provenance`.
  `:105-106` says the dormant workflow includes a fresh kernel recheck.
- `assurance.md:25-27` does not say that `lean-iteration.md` holds the
  complete (cached, no-replay) Lean check of the current inputs.
- Several supporting records still describe the old workflow in the present
  tense (docs-policy F3).

**L6. The SPARK evidence binding is worded as "unchanged".**

- `d375aec` changes `scripts/check_lean.py`, which is a hashed GNATprove
  input. The retained `fe539a5` Linux manifest therefore no longer validates
  for the published tree.
- `lean-iteration.md:75-76` and `assurance.md:652-655` say the native SPARK
  implementation did not change. True of the obligations, but the evidence is
  content-bound to `fe539a5`.
- My native `d375aec` proof passes and `check_evidence.py` accepts it
  (`probe-runs/gapSP-P2-evidence.log`).
- **Fix:** one sentence, or a Linux prove at the next checkpoint.

**L7. No policy test that `include_str` appears only in the twelve binding modules.**

- An `include_str` added elsewhere would get no Lake input dependency.
- **Fix:** a `test_lean_source` assertion.

### Info

- **I1. Edit-then-revert edge.** Lake hashes the input before `include_str`
  reads it. An edit-then-revert during a build can leave a binding object
  whose trace names other bytes. This fails safe: the certificate rejects it
  on every run until the binding is rebuilt.
- **I2. Evidence fields.** `mode` changed meaning: `scope` and
  `kernel_recheck` now carry it. A routine complete run replaces a
  replay-backed record by design. Focused failures remove only focused
  evidence, so an older complete record (with its own `inputs_digest_sha256`)
  remains present.
- **I3. Input capture now precedes the stale-evidence unlink.** In a narrow
  capture-error case, the previous success record for that scope survives.
- **I4. Header pins.** The output-side `Comment_End`/`Trivia_End` headers are
  shape-pinned only. This predates the move; the conjuncts are closable
  (`probe_headers.out`).
- **I5. Visibility.** The extracted helpers are now public library-level
  declarations (dropped by verification, 1/3; noted for awareness).
- **I6. Probe correction.** One reviewer probe expected `native_decide` to
  surface as `Lean.ofReduceBool`. Lean 4.34 reports an auxiliary axiom
  `…._native.native_decide.ax_1_1`, which the audit rejects. This was a probe
  expectation error, not a defect.

## 4. Probes and experiments

- **Cache invalidation** (`agents/lake-invalidation/all-cheap.log`, a scratch
  copy of the warm build):

  | Case | Result |
  | --- | --- |
  | P0 relocated | built 0 |
  | F ownership | each of the 12 bindings owned by its one-module library with its own source; `Silver.Source`/`AuthoritativeSource` own none |
  | C non-embedded edit | built 0, input digest changed |
  | A′ comment-only, mtime restored | built 2, binding contains the new text |
  | D CRLF | built 2, binding contains `\r\n` |
  | E1/E2 umbrella moved last | binding loses its dependency; a comment edit then **fails** with a certificate type mismatch, and no focused evidence is written |
  | B token change | 9 rebuilt; fails in `ArgumentsSourceBridge` as expected |

- **Real-Lake lakefile mutants** (`probe-runs/tests-P2-lakemutants.log`): the
  native ownership/dependency test catches `umbrella_last`, `text_true`,
  `drop_profile_spec_need`, `umbrella_needs_all` and
  `later_overlapping_library`.
- **Lexical identity** (`probe-runs/ada-P1..P3`):
  - 2,651 sources with 0 old/new mismatches and identical catalogue output;
  - 1,152 lexical-corpus sources agree with the independent model;
  - per-entity obligations are unchanged, and the notes moved with the
    helpers.
- **Runner and evidence mutants:** see L2. `tests-P1-runnermutants.log` and
  `runner-P1-modesmutants.log` list the full results. All
  output/evidence-format mutants were killed.
- **Focused mode on a cold copy** (`runner-P3-focused.log`): it builds only
  the target closure, rejects an appended axiom, and does not audit modules
  outside the closure (as documented).
- **Audit coverage** (`runner-modes P4`): the complete audit printed
  `SILVER_MODULE` for all 98 modules, including `Silver.Audit` and
  `Silver.AxiomAudit`.

## 5. Side effects and state

- **New, under `tmp/`.**
  - `tmp/review-d375aec-worktree` (detached), with its own toolchain clone and
    `.silver/macos-aarch64`.
  - Logs and agent scratch under `tmp/review-d375aec-logs/` (5.3 GB).
    About 5.1 GB of that is the lake-invalidation scratch copy
    (`agents/lake-invalidation/probe/`, 3.2 GB) and runner mutation copies
    (`agents/runner-modes/mutation/`, 1.9 GB); both can be deleted.
- **Worktree evidence.** The worktree's `lean-evidence.json` now holds the
  last cached run (no replay); the replay-backed record is preserved in
  `preserved-complete-replay/`.
- **Remote refs.** `git fetch` updated `origin/main` to `d375aec`.
- **Unchanged.** Your checkout's branch (still the pre-rewrite `b8b263d`),
  tracked files, `.tools/`, `.silver/`, stash and older scratch. Earlier
  review worktrees remain.

## Appendix: commands

```text
git fetch origin
git worktree add --detach tmp/review-d375aec-worktree d375aec
cp -c -R .tools/macos-aarch64 tmp/review-d375aec-worktree/.tools/
cd tmp/review-d375aec-worktree
python3 scripts/bootstrap.py && python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py --replay --provenance
python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=review-d375aec   # outside sandbox
python3 scripts/dev.py build && python3 scripts/dev.py test               # outside sandbox
python3 scripts/check_lean.py --target Silver.BranchingMain               # x3, timed
python3 scripts/check_lean.py                                             # x3, timed
python3 -I ../review-d375aec-logs/differential/old_vs_new.py
../review-d375aec-logs/probe-runs/run_early.sh                            # outside sandbox
bash ../review-d375aec-logs/agents/lake-invalidation/probe.sh all-cheap   # outside sandbox
```
