# Review of 1ed039e, "Add validated input-dependent branching"

Reviewed 2026-10-10/11 on the owner's Mac (macOS ARM64), from a detached
worktree of `1ed039e`. Scope is everything after the last review (`44fd8ea`):

- `8d5f626`: advisory tests and Lean runner phases;
- `d630229`: erasure of proof-only native I/O bookkeeping;
- `4422316`: branching and generalization plan;
- `1ed039e`: the eighth production.

Work was read-only on tracked files. Logs, probes and agent notes are in
`tmp/review-1ed039e-logs/`. The owner has made macOS proofs a non-goal; the
native runs here are optional reviewer evidence, not a pending requirement.

## 0. Verdict

**No blocker, high or medium finding survived verification.** The eighth
production is sound as specified, and the three supporting commits do what
they claim:

- The branching recognizer, Lean grammar and catalogue agree token for token.
  The compiled recognizer matched the reviewers' independent expectations on
  674 targeted sources, with 0 mismatches. It also agreed with Lean's
  recognizer on 698 sources across all eight forms (§5.4).
- Every admitted variant I or the reviewers compiled behaves exactly as the
  argv table says: 59 programs and about 950 executions. This includes output
  failure on both branches and on `Reject`, 4,096/4,097-byte bounds, and names
  such as `True`, `Boolean` and `Standard`.
- The strict null report route rejects every report shape that would indicate
  a check, warning or incomplete analysis, both in isolation and through the
  real driver.
- `d630229` erases only proof bookkeeping. Executable statements are
  unchanged, obligations are preserved (+3 proved checks), false Static
  contracts are still rejected by GNATprove, and native checking of a
  4,096-byte source is about 6× faster here.
- `8d5f626` fixes the previous review's L4. All nine helper deletion mutants
  are now caught, and the runner re-enumerates inputs at phase boundaries.
- The full Lean verification passed from an empty workspace. 83 modules and
  23,205 declarations, standard axioms only, and a fresh kernel replay.
  The output-body certificate took 2 h 53 min here (Linux: 2 h 55 min).

**On further expansion:** the owner has already ordered a bounded
source/dependency compartmentalization experiment before more language work.
I agree with that order: the serial certificate grows with every production
(2 h 55 min on Linux). Nothing found here needs to come before that
experiment except bookkeeping.

**Smallest justified work, in order:**

1. **Close or explicitly defer the previous review's remaining items** (L2
   here). That means the `is_assignment_member` header conjunct (L1 here), the
   rest of the old L2, the old L5 and the old L6. The project's own rule
   (development.md) requires recording a disposition for material findings.
2. **Add the in-place byte-drift tests** for the Lean runner (L3). The
   production code is correct, but two weakening mutants pass the suite.
3. **Add branching regression rows** (L4). All the behaviour they would pin is
   now natively verified.
4. **Fix the stale text** (L5).

## 1. Method

- **Isolation.** I created a detached worktree `tmp/review-1ed039e-worktree`
  with an APFS-cloned `.tools/macos-aarch64` and bootstrapped it offline. The
  main checkout, its `.tools/` and `.silver/` were not modified. `git fetch`
  updated only remote-tracking refs.
- **Multi-agent review (121 agents).** Seven read-only reviewers covered Lean,
  the Ada recognizer and routing, runtime semantics, native I/O erasure, the
  Lean runner, docs and tests. Three independent skeptics then tried to refute
  each finding, from the angles of code truth, reproduction and
  severity/policy. A completeness critic added two gap reviews. 37 findings
  were raised and 35 survived (≥2 of 3 upheld), all low or info.
- **Native probes.** The reviewers' native probe requests were then run here;
  all results are in §5.

## 2. Native validation (macOS ARM64, optional)

Host: Apple M4 Pro, 12 cores, 24 GiB; macOS 27.0.1; FSF GNAT and GNATprove
16.1.0; GPRbuild 26.0.0; Lean 4.34.1. This is FSF GNAT, not GNAT Pro.

| Check | Result |
| --- | --- |
| bootstrap, bootstrap_lean | Passed offline. |
| `dev.py prove --full --jobs 4 -- --subdirs=review-1ed039e` | **Passed: 3,029 checks** (412 flow, 2,617 proof), 16 units, 215 entities, 41 limitation notes, 14 imports. Matches the Linux total. Effectively cold: the solver cache was created at run start. 20 min, overlapping Lean and the workflow. |
| `dev.py build` | Passed. |
| `dev.py test` | **Passed: 174 tests** in 1,084 s (overlapping Lean). |
| `check_lean.py --full` (all-core defaults) | **Passed:** 83 modules, 94 Lake jobs, **23,205 declarations**, only `propext`, `Classical.choice` and `Quot.sound`. The fresh audit (6 s) ran before `leanchecker --fresh` (1,626 s), as `8d5f626` intends, and phase logs streamed with timings. Evidence: 108 shared inputs, 85 workspace inputs, 166 artifacts. Full build from an empty workspace: 10,961 s, of which `OutputBodyCertificate` took 10,384 s. Total 12,595 s (3.5 h), overlapping the proof, tests and workflow. |
| Branching probes (`probes/branch_probe.py`) | 16 programs × 17 argv/environment cases: **272/272 match** the model of the documented behaviour. |
| Reviewer probes (`probe-runs/`) | All passed; see §5. |
| Ada vs Lean recognizer comparison (`differential/`, `agents/differential/`) | **0 disagreements.** My corpus: 629 sources (613 sources seeded from six forms and randomly mutated, plus 16 probes); 164 admitted by both (117 branching, 27 assignment, 20 other forms) and 465 rejected by both. The reviewer's per-production cross-form probe: 698 rows (adds 69 hand-made files covering all eight forms), `PROBLEMS 0`. |
| Native-I/O timing (`native-io-timing.txt`) | `silver check` on a 4,096-byte source: median 78.9 ms at `44fd8ea` vs **13.1 ms** at `1ed039e` (60 runs each, under load). A small source: 15.2 vs 12.8 ms. |

## 3. What the eighth form rests on

| Class | Content |
| --- | --- |
| (a) Lean | The 67-token grammar, equal to Ada `Branching_Required_Tokens` and the catalogue. Case-insensitive binding; forbidden names as for the command-line forms. A typed Main composition whose statement nodes (output, reject, conditional) drive rendering, ordered event consumption and execution. Exact decoded-byte equality (`unequal_lengths_choose_no`). Universal theorems for default, single, explicit-empty, invalid and extra-argument input, and for output success and failure. Disjointness from all seven earlier forms, used in both orders in `meaning_unique`. `Current` integration. Source correspondence for the suffix body, precondition, variant, index subtype, `Accepts_Branching` header and postcondition, token declaration, spellings and the `Is_Member` union. |
| (b) GNATprove | `Accepts_Branching` = `Branching_Suffix_Matches` (inline postcondition). The driver's route contracts. The fixed library obligations. |
| (c) Reviewed Ada | Predefined String `=` (unequal lengths give False, no check), the nested `if` statement semantics, and identifiers that hide `Standard` names. |
| (d) Premises | Frontend parse and generation faithfulness: GNATprove emits no Main checks for this form, matching the empty modelled list. The existing argv/runtime/output premises. The null route's documented report-format premise, which does not constrain entities or dependency entries (§5.3). |

The empty obligation set is definitional (`rangeObligations (.branchingMain _) = []`)
under the explicit `generationFaithful` premise. Eight native GNATprove cases
on Linux, plus 76 programs here, all produced empty Main flow and proof lists.

## 4. Findings

### Low

**L1. `Is_Assignment_Member`'s header is still only shape-pinned** (previous L3; unchanged).

- `GuardedSourceBridge.Refinement` checks the `"is"` headers of `is_member`
  and `is_guarded_member`, but not `is_assignment_member`
  (`GuardedSourceBridge.lean:88-105`). Only its body is checked (`:28`).
- `1ed039e` gives branching full header parity (`BranchingSourceBridge.lean:54-61`)
  and edits this very file, but does not add the missing conjunct.
- The disposition (`docs/string-assignment.md:65-89`) does not mention it.
- **Fix:** one `functionHeader "is_assignment_member" "is" … "(Source : String)
  return Boolean"` conjunct, closed by the existing `decide +kernel`. Or record
  it as deferred. (Feasibility probe: §5.4.)

**L2. The previous review's disposition is incomplete.**

- 8d5f626 accepted:
  - L1 (clone guidance; verified restored);
  - the warnings-scope part of L2;
  - L4 (verified by mutation, §5.2);
  - two slips (L7 and the 18/17 count).
- It records nothing for:
  - **L3** (L1 above);
  - **L5** (native shape rows; Ada-checker message cases);
  - **L6**: `assurance.md:905-906` still says `AssignmentSourceBridge` adds
    "fixed-length mutation … checks";
  - **the rest of L2**: `language.md:504-505` still states "The pinned tools
    eliminate the statically satisfied length check" as fact.
    `trusted-boundary.md` still does not name that elimination or the
    observed-shape premise, yet `RESUME.md:131-135` says these premises "remain
    explicit in assurance and the trusted boundary".
- Its blanket sentence, "No compiler, runtime, language or Lean theorem change
  is warranted", reads as an implicit rejection without reasons.
  `development.md:250-256` asks for a short disposition of material findings.
- **Fix:** one sentence per item: accepted, deferred or declined with a
  reason. The `RESUME.md` sentence needs correcting, or the trusted-boundary
  sentence adding.

**L3. Runner byte-drift checks are correct but untested.**

- `check_lean.py:237` and `:241` compare paths *and* bytes (shared inputs) or
  hashes (workspace candidates) at phase boundaries.
- Every phase test adds or deletes a file; none edits an existing input in
  place.
- Two mutants survive the whole runner suite (`probe-runs/runner-P2-extended.log`):
  - `shared_bytes_to_inventory`, which compares only path sets;
  - `workspace_bytes_removed`.
- A reviewer probe that edits existing files in place shows the real code
  catches all four cases (`tests-P5-bytedrift.log`).
- **Fix:** add those in-place-edit subtests to `test_lean_evidence.py`.

**L4. Branching regression rows are missing for behaviour now verified natively.**

- **`Mode="verbose"then`.** This is the only string-literal-then-word adjacency
  in any production. It is admitted by both recognizers but is in no test.
  *Natively it compiles and runs correctly (§5.1).*
- **Structural exclusions without a branching row:**
  - swapped outer branches;
  - the legal-Ada merged guard `if … and then Mode = … then`;
  - `<`, `<=`, `>`, `>=`;
  - mutations in the matched branch, where only the else branch is mutated
    today;
  - `end Mode;`;
  - a same-length but different reference name (`Node`/`Modf`).
  The fixed token sequence already excludes all of them (class a). *The
  reviewer's 157-case check corpus confirms rejection (§5.1).*
- **No real-driver negative test of the Main-report route** for any
  output-mode program; only null-mode fake reports are exercised. *A fixture
  subclass of `test_output_integrity` (`probe_branching_route.py`) shows all
  nine faults stop with status 3 before build (§5.3).*
- **`test_static_proof` pins only a Static postcondition**, while `d630229`
  moved driver preconditions and platform loop invariants to Static. *Real
  GNATprove rejects false Static preconditions, loop invariants and
  postconditions (§5.2).*
- **Fix:** promote these probes to tests. They are written and pass.

**L5. Stale text.**

- `src/silver_reports.ads:10-12` still says "Both admitted application units
  … the sole entity". The route now serves six forms, and a branching report
  has five entities (one SPARK-map entry).
- `docs/lean-concurrency.md:229-230` still calls the native I/O change an
  "unmeasured proposal" after `d630229` measured it.
- `docs/lean-concurrency.md:118-120` still calls `--memory-mb 6144` "the
  usual" command, while `RESUME.md` uses 12288 (the previous review's I7,
  unchanged).
- `README.md` still calls `RESUME.md` a "VM replacement checklist".
- `tests/…` has a timeout comment about runtime ghost observations that
  `d630229` erased (T9).

### Info

- **I1. The null route constrains no entities or dependency entries.**
  - Natively, a branching Main report with its `assumptions` dropped, an extra
    `CLAIM_AORTE` claim, or an extra entity is accepted (`reports/mutate-null.log`).
  - This is the documented report-format premise (`trusted-boundary.md:402-406`,
    `426-432`) and the long-deferred substring-check item from the `3fdda42`
    review.
  - The grammar fixes the callee set, so it cannot admit a different program.
    The guarded route, by contrast, checks exact entities and dependencies.
- **I2. `Audit.lean` prints no branching theorem.** The `run_cmd` sweep covers
  every declaration. (Direct axiom listing: §5.4.)
- **I3. Route exclusivity is not one theorem.** It is derivable for branching
  from `BranchingDisjoint` plus the driver contracts. The gap reviewer also
  checked all 613 corpus files with independent classifiers: every
  branching-admitted file fails the assignment grammar at token 4 and the
  guarded grammar at token 33.
- **I4. The +3 proved checks** in `Silver_Platform.Read_File` (2→3 loop
  invariant init and preserve, 7→8 range) are explained by the invariant
  split. They are harmless (`native-io-P2-spark.log`).
- **I5. Evidence-helper typing and fields.** Strict-int typing of
  line/col/entity and the `annot_kind`/`justif_msg` suppression fields are not
  isolated by a test; five extended mutants survive. This is the development
  helper only; the SPARK checker is the admission path.
- **I6. Runner command and exception path.** `development.md`'s daytime
  "targeted Lean model/module checks" has no sanctioned runner command, and
  `run_logged`'s kill-on-exception path is untested (one surviving mutant).
- **I7. Dropped by verification:** a Linux `argc=0` note and an RM citation for
  String `=` (each upheld by only 1 of 3 verifiers).

## 5. Probes and experiments

### 5.1 Recognition and native execution

- **My branching set** (`probes/`): 16 programs, including:
  - the sample byte for byte;
  - empty comparison or default, default equal to the comparison;
  - doubled quotes, mixed case, empty and identical outputs;
  - names `Main`, `Input_Is_Valid`, `First_Or_Default`, `Dummy`, `Unused_Mode`;
  - compact and comment-laden layouts;
  - an exactly 4,096-byte source.

  Each was run with 17 cases: none, match, upper case, trailing space, prefix,
  empty, two arguments, 4,096 and 4,097 bytes, control, DEL, non-ASCII, tab,
  closed stdout on each branch and on `Reject`, and SIGPIPE. Result: 272/272
  match. All Main reports have empty flow and proof lists, and no compile
  printed a warning.
- **Reviewer probes** (`probe-runs/`):
  - **semantics:** 17 programs × 31-32 cases, including near-4,096
    comparison/default literals, a comment-like comparison literal, names
    `True`/`Boolean`/`Character`, all-upper source and environment modes. All
    ok; the 4,097-byte variant is rejected.
  - **ada P2:** 16 programs, including `literal_then_adjacent` and names
    `Integer`, `Standard`, `Reject`, `Put_Line`. All ok.
  - **tests P2:** 10 programs, including `literal_then_adjacent` and
    `max_binding_distinct`. All ok.
  - **check-level corpora:** ada P1 (448 sources, 0 mismatches), tests P1 (157
    cases, 0 mismatches), extra cross-form (69 files, 0 mismatches against
    expectations).

### 5.2 Tooling and proof-level checks

- **Evidence-helper deletion mutants** (`mutation/`): previously 6/9 survived;
  now 0/9.
- **Extended runner/helper mutants:**
  - killed: `length_bound`, `loop_verify_removed`, `audit_marker_removed`,
    `loop_artifact_check_removed`, `buffer_until_exit`,
    `evidence_unlink_removed`;
  - survived: `shared_bytes_to_inventory`, `workspace_bytes_removed` (L3), the
    three strict-int checks and two suppression-field checks (I5), and
    `no_kill_on_exception` (I6).
- **Static-level contracts:** a two-file GNATprove probe with false Static
  `Pre`, `Loop_Invariant` and `Post` fails with `VC_PRECONDITION`,
  `VC_LOOP_INVARIANT_INIT` and `VC_POSTCONDITION`, and empty
  `skip_proof`/`pragma_assume`.
- **Obligation diff for `d630229`:** exactly three proof-count changes, all in
  `Read_File`; flow totals 33→33.

### 5.3 Report route

- **Null checker built natively** (`reports/null-probe-build`):
  - all 32 real branching reports (16 compact plus 16 pretty) are accepted;
  - every added check, warning, skip, assume, `warn_error`, spec or extra
    coverage, `PROGRESS_FLOW` or stop-reason mutation is rejected;
  - the assignment checker rejects the branching report;
  - the guarded checker accepts it, since it has no checks;
  - the reviewer's 17-case null mutation set: all ok.
- **Real driver** (`probe_branching_route.py`): with the branching sample as
  source, the control publishes. Each of nine faulty Main reports gives status
  3 ("missing or incomplete proof evidence") with no build. The faults are an
  info range check, an INEFFECTIVE advisory, an unproved check, `warn_error`,
  `PROGRESS_FLOW`, a second entity, spec coverage, `skip_proof` and
  `pragma_assume`.

### 5.4 Lean-side probes

- **Axiom listing** (`agents/lean/probe_axioms.out`): 23 branching and
  integration theorems each depend only on `propext`, `Classical.choice` and
  `Quot.sound`. No `sorry` or `ofReduceBool`.
- **L1 feasibility** (`agents/lean/probe_l3_header.lean`): `functionHeader
  "is_assignment_member" "is" Source.outputBodyTokens = some (expectedTokens
  "(Source : String) return Boolean")` elaborates by `decide +kernel` with no
  error in 1.7 s. The missing conjunct really is a one-line addition.
- **Recognizer differentials:** see §2. Interpreter `#eval` on the built
  modules agrees with the compiled `silver check` on every source.

## 6. Corrections and calibration

- **Critic's "pending probes" gaps (PC1-PC6).** These were correct as process
  observations at the time. Every listed probe has since run and passed, so
  none becomes a defect.
- **"A GNAT rejection would be a blocker."** The gap reviewer was right that
  under the Oracle this is not harmless fail-closed behaviour. The native
  compiles settle it: `"verbose"then` and every listed name compile and run
  correctly.
- **L2 severity.** One verifier refuted the "rest of old L2" part as already
  assessed by the owner. I keep it as low because `RESUME.md` asserts the
  trusted boundary states these premises, and it does not.

## 7. Side effects and state

- **New, under `tmp/`.**
  - `tmp/review-1ed039e-worktree` (detached; `.git/worktrees/` entry), with
    its own `.tools/macos-aarch64` (APFS clone) and `.silver/macos-aarch64`
    (compiler, proof workspace, Lean evidence, solver cache).
  - Logs, probes, agent notes and scratch under `tmp/review-1ed039e-logs/`
    (859 MB). 845 MB of that is per-mutant copies of the tracked tree in
    `agents/runner/mutation-extended/`, which can be deleted once read.
  - The worktree's `.silver/` is 619 MB.
  - The earlier `tmp/review-44fd8ea-worktree` remains.
- **Remote refs.** `git fetch origin` (run outside the sandbox) updated
  `origin/main` to `1ed039e`.
- **Unchanged.** The main checkout's `main` branch (still the pre-rewrite
  `b8b263d`), tracked files, `.tools/`, `.silver/`, stash and other scratch.
- **Temporary files.** Probe compile workspaces were deleted after copying
  reports. GNATprove probe scratch went to temporary directories or
  `tmp/review-1ed039e-logs/`.

## 8. Ordered actions

1. Disposition of the remaining previous-review items (L2), including the
   L1 conjunct or its explicit deferral.
2. Runner in-place byte-drift tests (L3).
3. Promote the passing branching probes to regression tests (L4).
4. Text fixes (L5).
5. Proceed with the owner's ordered compartmentalization experiment.

## Appendix: commands

```text
git fetch origin
git worktree add --detach tmp/review-1ed039e-worktree 1ed039e
cp -c -R .tools/macos-aarch64 tmp/review-1ed039e-worktree/.tools/
cd tmp/review-1ed039e-worktree
python3 scripts/bootstrap.py && python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py --full
python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=review-1ed039e   # outside sandbox
python3 scripts/dev.py build && python3 scripts/dev.py test               # outside sandbox
python3 -I ../review-1ed039e-logs/probes/branch_probe.py                  # outside sandbox
../review-1ed039e-logs/probe-runs/run_all.sh                              # outside sandbox
python3 -I ../review-1ed039e-logs/reports/mutate_null.py <null probe> <lib probe> ../review-1ed039e-logs/probes/kept
```
