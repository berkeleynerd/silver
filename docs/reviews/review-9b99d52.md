# Review of 9b99d52, "Support statement sequencing and assignment"

Reviewed 2026-10-13 on the Linux x86-64 development sandbox (22 CPUs visible,
~31 GiB), the project's primary platform, read-only on tracked files, from the
checkout at `9b99d52` (`main`, equal to `origin/main` on GitHub). Scope is
everything after the last review (`9b72d36`): 2 commits, 84 files,
+18,551/−11,581 lines:

- `3c1522f`, "Prove composed interpretation witness": the repair of the
  previous review's M1 (six `ComposeModel*.lean` modules), with the previous
  review report committed verbatim;
- `9b99d52`, "Support statement sequencing and assignment": finite sequences of
  `null`, fixed-bound assignment, `Silver_IO.Put_Line` and one-level String
  equality choices in three shells; 24 new `Sequence*.lean` modules; the
  rewritten recognizer and report policies; a 2 MiB application report buffer;
  the sample `samples/statement_sequence.adb`.

A later commit, `138c751` ("Document sequencing costs and close focused review
gaps"), landed during this review's final completion run. It records the
800-assignment result and touches files named in several findings below. It
is not reviewed here: the findings describe `9b99d52`.

Hand-written Lean changed by +5,225/−387 lines (`Sequence*` +3,874,
`ComposeModel*` +1,105), generated certificates by +10,990/−9,115, SPARK by
+430/−461, tests by +298/−54, documentation by +1,405/−384 (631 of them the
committed previous review), and catalogue, samples and scripts by +203/−1,180.
Scratch, probes and agent notes are in the session scratchpad; nothing was
written under `tmp/`.

## 0. Verdict

**No blocker, high or medium finding remains open. The reviewers raised one
medium (M1: dense-assignment programs, now admitted without any count, with no
demonstrated proof completion). This review's two completion runs resolve it to
a low-severity disclosure gap. The densest static and argument-input programs
both prove, in 36 and 50 minutes at 8.9 and 10.0 GiB, and their reports fit the
2 MiB buffer at 82.7% and 94.6%. What remains is disclosure: users are not told
that a valid 4 KB program can need about 50 minutes and 10 GiB, one
specification sentence is wrong, and the capability record still calls the
maximal case unmeasured. The previous review's M1 is genuinely repaired, and
that class of gap does not recur in the new sequencing bridge.**

**What works.**

- **The M1 repair is real.** `Compose.SourceBridge.model_interpreted` proves
  exactly the `InterpretedSource` structure that the `9b72d36` correspondence
  theorems assumed, with no premises. `Compose.Expressions.modelCalls`
  dispatches every function tag to the existing Lean specification functions,
  and the proofs show that those satisfy the rendered-body equations, the twelve
  range contracts and the legal-call domains. The interface is therefore
  jointly satisfiable. The witness does not show, and the documents do not
  claim, that the physical Ada satisfies the equations
  (`trusted-boundary.md:610-627`, `assurance.md:293-305`, the repair record).
  `9b99d52` reshaped the predicate (`HelperEquations`/`LegalHelpers`, `step`
  restricted to the three native forms) and updated the witness in the same
  commit.
- **No recurrence in the sequencing bridge.** Every premise of the new
  top-level theorems (`executable_main_correct`, `executable_membership`,
  `executable_selectors`, `current_executable_membership`,
  `executable_pipeline`) has a premise-free inhabitant:
  `Sequence.SourceBridge.model_interpreted`, `model_executable` and
  `Current.model_tool_contract`. A reviewer probe instantiated
  `executable_pipeline` with all three and no remaining hypotheses.
  `#print axioms` on these theorems, the witnesses and the source checks shows
  only `propext`, `Classical.choice` and `Quot.sound`.
- **Actual-source coverage.** Every new or changed recognizer subprogram has a
  kernel-checked equation against the bytes of `src/silver_output_profile.adb`
  (reached through `include_str`): `Scan_Token`, `Basic_Statement_At`,
  `Basic_Tail`, `Conditional_At`, `Statement_At`, `Statements_Tail`,
  `Scan_Step`, `Scan_Suffix`, `Form_Result`, `Is_Member` and the `Has_*`
  functions, with their range/progress contracts and the `Read_*`, `Accepts`
  and `Uses_*` postconditions. The renderer repair (`simp only` with public
  equation lemmas before `decide +kernel`) leaves every declared proposition
  unchanged. `proof/` contains no `native_decide`, `sorry`, axiom,
  `implemented_by`, `extern`, `unsafe` or kernel-bypass option.
- **The recognizers agree, and nothing regressed.** On the previous review's
  13,730-source corpus the HEAD compiler rejects **none** of the previously
  admitted sources and admits 12 more, all of them sequencing forms. Lean
  `Current.accepts` likewise lost none of its 4,311 earlier admissions on the
  sampled set and gained the same 8. Compiler and Lean agree on all 13,730, on
  **5,876 new sequence-focused sources** (3,170 admitted; 2,600 random valid
  sequences across the three shells, 1,529 labelled near-misses, boundary
  controls and token mutations), on 36 targeted extras and on 46 edge probes.
  Every labelled source matches `language.md`. GNAT `-gnatc -gnat2022`
  accepts **910/910** sampled newly admitted programs, and 112/112 and 19/19
  in two further probe sets. 238 sources with bytes above 126 are covered.
- **The recognizer is faithful to Ada.** 167 hand-written probes found no
  admitted program that is illegal Ada. Every rejection is clean against an
  admitted neighbour (nested `if`, `elsif`, empty arms, else-less `if`,
  labels, statements around the guard or after `Reject`, assignment to a
  constant or to the argument binding, static and dynamic length mismatch,
  target growth `A := A & A`, and others). Boundaries are exact: 16/17 leaves
  in every position; 30/31 `&` spread over declarations, assignments, both
  comparison operands, both arms and output; 4096/4097 bytes; guarded capacity
  2048/2049.
- **Runtime behaviour matches the specification.** Fault injection (an
  `LD_PRELOAD` shim failing the first `putchar`, the twentieth, or `fflush` at
  each of four calls), closed stdout and `/dev/full` all give exit status 1,
  with later statements still running and the failed status retained. Exit
  status is 0 only when no failure is injected. Snapshot constants keep their
  initial values, choices read the current store, and later statements see
  only the selected arm's updates. About twenty `silver compile` probes proved
  and ran. They include 117 sequential choices (4,074 bytes, 307 s, 1.05 GiB),
  56 choices with output in both arms, 253 chained declarations, 30 dynamic
  concatenations spread over outputs and assignments, and 664 unused
  assignments.
- **Report acceptance is still strict where it matters.** Accepted application
  reports still contain only proved, `info`, prover-discharged
  `VC_RANGE_CHECK`/`VC_LENGTH_CHECK` records on `Main`. Advisories are exact
  and carry no justification or suppression. `Main` coverage must be `all`,
  and the skip, assume and warn arrays must be empty. An over-capacity report
  is rejected with exit status 3 and never truncated.
- **The implementer's handoff claims hold:**
  - pushed: `origin/main` on GitHub is `9b99d52`;
  - 2,729 SPARK checks, 266 tests and 144 Lean modules;
  - the sample exists and is exercised;
  - the capability record documents the dense-assignment cost and the
    report-capacity premise;
  - the next roadmap item is recorded.

  §2 and L11 give the qualifications.

**What needs attention**, in order:

1. **Dense-assignment disclosure (M1, resolved to low).**
   - Record this review's two completion runs in the capability record.
   - Disclose the cost envelope in `language.md` and `README.md`: about 50
     minutes and 10 GiB for the densest 4 KB program, and reports up to about
     95% of the buffer.
   - Correct `language.md:166-168`.
   - A purpose-documented proof-work budget remains the owner's alternative.
2. **Report-policy wording and the unused `Uses_Output` (L1).** Two sentences
   in the capability record and assurance misdescribe the policy change.
3. **The M2 follow-through is partial (L3).** Six touched rules have no
   rejected sibling, and one older negative is now confounded.
4. **Documentation consistency (L5–L10):**
   - six broken anchors;
   - an "In progress" milestone row for a supported capability;
   - stale current-tense passages;
   - no purposes for the outer-guard rules and the mandatory `else`;
   - the operator-budget comment;
   - one absolute machine path.
5. **Precision of the validation record (L11).**
6. **The compiler's stack prerequisite (L2).**
7. **The shape of the Lean evidence (L12–L14).**

## 1. Method

- **Isolation.** No tracked file, nothing in `.tools/`,
  `.silver/linux-x86_64/proof`, the evidence directories or `tmp/` was
  modified. §6 lists the side effects.
- **What I ran myself:**
  - recomputed the Lean inputs digest;
  - compared the workspace with `proof/`;
  - checked the GNATprove input hashes and the retained summary;
  - ran `git ls-remote` against GitHub and compared `silver catalogue` with
    the tracked catalogue;
  - ran the 133 tests that read proof or evidence files at HEAD;
  - analysed the chronology of the full-test record;
  - scanned every intra-repository anchor;
  - checked the deferral records;
  - ran the 800- and 769-assignment compiles in the background (§4).
- **Multi-agent review.** Nine read-only reviewers, all on Opus 5.5, each with
  one lens:
  - Lean trust and the witness;
  - the Lean sequence model;
  - actual-source correspondence;
  - the SPARK recognizer and Ada fidelity;
  - report policy, catalogue and capacity;
  - end-to-end capacity and runtime probes;
  - a differential recognizer probe;
  - tests, M2 and evidence tooling;
  - documentation, claims and dispositions.

  They raised 43 findings (3 medium, 28 low, 12 info). After merging
  duplicates, five independent verifiers re-derived 35 of them in five groups.
  Each verifier was told to refute and to reproduce rather than trust the
  finder's evidence. Result: 21 upheld, 14 narrowed, none refuted. I checked
  the remaining 8 myself (anchors, manifest tags, deferral records, process
  notes).
- **Owner's no-routine-rerun rule.** Every agent was bound by it: no Lean
  build, `check_lean.py`, `dev.py prove`, full suite or replay. Only targeted
  `silver check`/`compile`/`run` probes, GNAT `-gnatc`, read-only Lean probe
  files and single test methods were run. The two long runs, the 800- and
  769-assignment compiles, were approved by the owner as research into M1.
- **Cost.** About 0.75M output tokens: reviewers 0.51M, verifiers 0.10M, lead
  0.15M. About 105M cache reads and about 60 minutes of wall-clock time,
  plus the background compile.

## 2. Native validation (Linux x86-64)

| Check | Result |
| --- | --- |
| Implementer's handoff claims | "Pushed; remote synchronized": `origin/main` on GitHub is `9b99d52` (`git ls-remote` over HTTPS). "2,729 SPARK checks": confirmed from the retained `gnatprove.out` (467 flow + 2,262 prover, 0 justified, 0 unproved; 17 units, 246 entities). "266 tests": the recorded run is clean (266/0/0/0, no skips), with the qualification below. "All 144 Lean modules": confirmed by digest, workspace and module list; the final check rebuilt 8 of them. |
| GNATprove evidence binding | All **2,391** recorded input hashes in `proof-provenance.json` (the compiler object directory and the retained copy) match HEAD. The retained summary is byte-identical to the compiler's. |
| Lean evidence binding | The `lean-evidence.json` inputs digest `614c92e3…` **recomputes over the 169 tracked inputs at HEAD**. The canonical workspace's sources, lakefile and toolchain are byte-identical to `proof/`, and its 144 modules match the 144 source modules. A reviewer also checked every canonical Lake trace: all **144** source-input hashes equal the HEAD sources, all **572** output hashes equal the artifact bytes, and no trace carries a kernel-bypass option. |
| Full test record | `native-checkpoint/results.json`: `src/`, `tests/`, `samples/`, `catalogue/` and `scripts/` were identical to HEAD before and after the run. Tracked `proof/` files were not. At the start, 13 proof files differed from HEAD (the two `Output*Certificate.lean` files still equalled the base versions) and two did not exist yet. 7 changed during the run, as the record says. 11 still differed from HEAD at the end. I re-ran the 133 tests that read proof or evidence files at HEAD (`test_lean_source`, `test_lean_modules`, `test_lean_evidence`, `test_evidence`, `test_proof_provenance`, `test_platforms`, `test_argument_bounds`): **133/133 OK** in 2 min 19 s. No test reads Markdown. |
| Generated certificates | Byte-identical to regeneration from HEAD `src/` (`test_checked_in_certificates_equal_regeneration`, in the subset above). |
| Catalogue | `silver catalogue` equals `catalogue/silver.json` as JSON: 24 constructs and 4 compositions, matching the 24 identifiers in the `language.md` capability table. The previous review's L9 (stale `count` fields) is fixed. |
| Compiler binary | `.silver/linux-x86_64/compiler/bin/silver` (`1f71293c…`) was built at 19:58 from sources identical to HEAD, and every probe used it. The implementer's 2,083-source differential used an earlier binary (`3fb56e8a…`); the only source change after it is the report checker. |
| Maximal dense assignment (M1) | Both run by the lead under production options and both **proved**. Static (the implementer's 800-assignment, 4,096-byte source): 2,184.9 s, peak 8.89 GiB, 844 checks, report 1,734,274 B (82.7% of the 2 MiB buffer). Argument-input (769 assignments, 4,095 bytes): 2,972.1 s, peak 9.99 GiB, 813 checks, report 1,983,843 B (94.6%). Both executables behave as specified. |
| Oracle | `oracle.md` and `AGENTS.md` are unchanged since `9b72d36`. |

## 3. Findings

### 3.1 Medium (resolved to low)

**M1. Dense-assignment programs are admitted with a steep proof cost that is
not disclosed.** (Introduced by `9b99d52`. Raised independently by three
reviewers and upheld at medium. This review's two completion runs, approved by
the owner, resolved it to low: the densest admitted cases prove and fit.)

- **What is admitted.** There is no statement, assignment or proof-work
  count. `language.md:213` says "There is no separate statement or
  output-count limit", and `README.md:87` says the same. The recognizer has no
  counter (`src/silver_output_profile.adb:836-868`). At `3c1522f` each body
  shape allowed one assignment: "additional statements and repeated output
  remain excluded" (`language.md:236-237` there).
- **Measured cost.** Other compiles were running alongside the smaller probes,
  so their timings are observations, not cold bounds. The lead's two maximal
  runs overlapped other work only in the first eight minutes of the first run;
  the second ran alone.

  Static shell (`A:String:="x";B:String:=A;`, then N assignments
  `A:=B;B:=A;…`; the 800 case is the implementer's
  `native-probes/max-assignments/main.adb`):

  | Assignments | Source | Result |
  | --- | --- | --- |
  | 100 | 596 B | proved; 46.1 s; 0.45 GiB; report 218,633 B |
  | 200 | 1,096 B | proved; 179.8 s; report 434,348 B |
  | 400 | 2,096 B | proved; 633.7 s; 2.33 GiB; 400 length checks; report 867,112 B |
  | 800 | 4,096 B | **proved (lead): 2,184.9 s (36.4 min); peak 8.89 GiB; 844 checks, including 800 length checks; report 1,734,274 B (82.7%); executable exits 0.** Earlier attempts were stopped at 180.5 s (implementer, 8.16 GiB) and 905.2 s (reviewer, 8.88 GiB). |

  Argument-input shell (`D:constant String:=Silver_Arguments.First_Or_Default("w");X:String:=D;Y:String:=X;`,
  then N assignments `X:=Y;Y:=X;…` inside
  `if Silver_Arguments.Input_Is_Valid then … else Silver_Arguments.Reject;end if;`;
  each assignment carries a dynamic length check and an unused-assignment
  advisory):

  | Assignments | Source | Result |
  | --- | --- | --- |
  | 100 | 750 B | proved; 60.2 s; 0.46 GiB; report 261,230 B |
  | 769 (maximum for this shape) | 4,095 B | **proved (lead): 2,972.1 s (49.5 min); peak 9.99 GiB; 813 checks, including 769 length checks, plus 771 unused-assignment advisories; report 1,983,843 B (94.6%). The executable exits 0 with no argument, with a valid argument and with an empty argument, and exits 1 with two arguments.** |

  - **Scaling.** Time grows with an exponent of about 1.9 in both shapes
    (1.8 from 400 to 800 static assignments).
  - **Memory.** Peak memory reaches 8.9–10.0 GiB at the maxima. In both long
    runs it was reached within the first 10–15 minutes and stayed flat
    afterwards.
  - **Where the time goes.** In the 400-assignment case, `gnatwhy3`
    transformations dominate: `schedule_vcs` 205 s, `introduce_premises` 72 s,
    `inline_trivial` 65 s, `simplify_formula` 56 s. That compares with 165 s
    across 3,600 solver attempts. Neither the 10,000-step limit nor the
    solver-completion premise (`assurance.md:386`) bounds this cost.
- **Report envelope.**
  - **Static maximum.** 1,734,274 bytes, 82.7% of 2,097,152. That is within
    0.15% of the linear projection from the smaller runs.
  - **Argument-input maximum.** 1,983,843 bytes, 94.6%, leaving a margin of
    113,309 bytes (5.4%). That is 0.95% above the single-point projection.
  - **A denser single-target variant.** `X:String:=D;` followed by 771 copies
    of `X:=D;` is 4,093 bytes and is also admitted. It projects to about
    1,988,937 bytes (94.8%); this was not measured.
  - **Densest pattern.** No admitted shape the reviewers found produces more
    report bytes per source byte than dense dynamic assignment. For comparison,
    4 KB of outputs gives 314,746 B and 4 KB of choices 510,739 B.
  - **Overflow.** It would be rejected safely, with exit status 3. The thin
    margin rests on the documented pinned-producer premise: a change in
    producer or format could cross it.
- **Why it still matters.**
  - **The core guarantee now holds.** `oracle.md:1` ("valid Silver can never
    be rejected. If it compiles, it proves") and `:14` are demonstrated for the
    densest cases on the reference sandbox.
  - **Disclosure is missing.** `oracle.md:19` requires resource limits to be
    "explicit, with their purpose documented". No user-facing document states
    the time, memory or report margin. The only premise covering them is the
    generic "sufficient resources" (`assurance.md:396`;
    `trusted-boundary.md:556-557`).
  - **The gate is met but not recorded.**
    `docs/restrictions-capacity.md:262-266` makes removing statement
    restrictions conditional on "both practical proof completion and complete
    report capacity". This review's runs supply both for the densest static
    and argument-input shapes. The project has not recorded them: its
    capability record still lists the maximal case as an "incomplete
    measurement" stopped at 180 s, with its cost an "explicit limitation"
    (`statement-sequencing.md:100-103`).
  - **One spec sentence is wrong.** `language.md:166-168` still says the
    sixteen-leaf and thirty-operator limits "control native proof/translation
    and report growth". That is not true of total growth: 800 assignments use
    no operators.
- **Severity.** Low, down from medium. The evidence gap is closed. What
  remains is disclosure, one wrong specification sentence and a stale record.
  Nothing is unsound, both maxima prove, and nothing unproved is accepted.
- **Recommendation.**
  - Record both completion runs in `statement-sequencing.md`: sources,
    options, time, peak memory and report sizes. They replace the "incomplete
    measurement" row.
  - Disclose the cost envelope in `language.md` and `README.md`. For example:
    "the densest admitted 4 KB programs need about 50 minutes and 10 GiB on
    the reference sandbox, and their reports use up to about 95% of the 2 MiB
    application buffer".
  - Correct `language.md:166-168`.
  - If that cost is unacceptable, the owner's alternative is an explicit,
    purpose-documented proof-work budget. The Oracle permits explicit resource
    limits with a stated purpose; only arbitrary call caps were excluded.

### 3.2 Low

**Report policy and driver**

- **L1. Report selection is source-blind, `Uses_Output` is proved but unused,
  and the record misstates the policy change.** (Merged from four findings;
  two upheld, two narrowed.)
  - **`Uses_Output` has no consumer.** `Application_Kind` comes only from
    `Uses_Arguments` and `Uses_Assignment` (`src/silver.adb:79-86`).
    `Uses_Output`, `Has_Output` and the Lean `ExecutableRefinement.output`
    correlation (`SequenceSourceBridge.lean:70-75`) have no consumer in
    `src/`, `tests/` or `scripts/`.
  - **Both entity shapes are accepted.** Every policy accepts both the
    with-`Put_Line` and the without-`Put_Line` entity shape.
  - **The source-selection sentence is not implemented.** The genuine producer
    emits `Main`-only reports for programs that call `Put_Line` (the retained
    2-, 8- and 175-output reports). So "report dependencies must follow the
    source's actual approved calls" (`statement-sequencing.md:17-18`) is not
    implemented, and cannot be implemented in that direction. `Put_Line` has
    no precondition, so no call-site check is lost.
  - **What changed relative to `3c1522f`.** Both the native policy and
    `check_evidence.py`:
    - dropped the non-empty-flow condition for bare `Binding` and
      `Argument_Binding` reports;
    - dropped the empty proof/assumptions condition for all `Main`-only kinds;
    - widened the comparison and dead-code advisories to every kind;
    - added four exact ghost-output messages.

    `assurance.md:462-464` and the `.ads` comment document the new rule, and
    the genuine probe reports justify each relaxation.
  - **The record says otherwise.** `statement-sequencing.md:116-117` says "no
    policy condition or proof obligation was dropped".
    `assurance.md:427-429` lists `Uses_Output` beside the two selectors that
    are actually used.
  - **Untested branch.** The Python argument-without-output branch
    (`check_evidence.py:191-192`) has no unit test.
  - **Recommendation.** Fix the two sentences. Either remove `Uses_Output`, or
    use it one-directionally (reject a `Put_Line` entity when the source has
    no output). Add the missing test. The previous review's L8 is resolved by
    this uniform relaxation.
- **L2. The 2 MiB report buffer raises an undocumented stack requirement for
  every compile.** (Narrowed.)
  - **Stack use.** `src/silver.adb:123` declares the report buffer on the
    `Compile` stack, and `Audit_Report` copies it again
    (`src/silver_library_reports.adb:1396`). Every `silver compile` or `run`,
    null programs included, therefore needs more than about 2 MiB of stack. A
    maximal report needs more than about 4 MiB.
  - **Failure mode.** With `ulimit -s 2048`, `hello_world.adb` prints
    `Accepted: silver.` and then `STORAGE_ERROR`, with exit status 1. That
    status is outside the documented 0/2/3 contract (`README.md:235-237`).
    The failure is safe (nothing is published) and happens in about 0.1 s.
  - **Where it is documented.** Only in the experiment record
    (`statement-sequencing.md:106-107`, "under the ordinary 8 MiB stack"). A
    smaller requirement, about 512 KiB (inferred from the base buffer sizes,
    not measured), already existed at base.
  - **Recommendation.** Allocate the buffer statically and avoid the copy, or
    document the minimum stack in `README.md` and `trusted-boundary.md`.
    Consider mapping `Storage_Error` to exit status 3.

**Tests**

- **L3. The M2 follow-through is partial.** (Merged from three findings; two
  upheld, one narrowed.)
  - **Missing rejected siblings.** The recorded disposition is that
    admitted/rejected pairs accompany rules when they are touched
    (`roadmap.md:44-46`). `test_statement_rules_have_admitted_and_rejected_neighbours`
    adds good pairs. These touched rules still have no rejected fixture
    anywhere in `tests/`:
    - (a) an empty static body, and an empty guard success branch;
    - (b) an empty `then` arm (only the empty `else` arm is tested);
    - (c) a nested choice in the `else` arm;
    - (d) a statement before the outer guard;
    - (e) a later output that exceeds the established capacity;
    - (f) a shape-compatible assignment to the argument binding
      (`Input := Input;`).

    The only argument-binding target negative (`tests/test_branching.py:112`)
    also changes the length shape. The 17-leaf negatives still exist only in
    output position (the previous review's L21).
  - **Every gap is testable.** Each shape is rejected at HEAD and each control
    admitted, so every missing test would be meaningful.
  - **A confounded negative.** `tests/test_branching.py:113` inserts `null;`
    both inside the equality arm (now admitted) and after `Reject` (still
    rejected). It now guards only the outer-arm rule, with no single-edit
    sibling.
  - **Still reason-blind.** Negative tests still cannot tell why a fixture was
    rejected (`src/silver.adb:375`, `:381`).
  - **Recommendation.** Add single-edit siblings for (a)–(f) and 16/17-leaf
    pairs for the assignment value and each comparison operand. Split the
    `:113` case into an admitted inner-arm edit and a rejected outer-arm edit.
- **L4. Two runtime paths of the new sample and sequences are untested.**
  (Narrowed.)
  - **No capacity-clause failure.** Neither the `statement_sequence` sample
    nor `test_statement_sequencing` exercises the capacity clause failing. Its
    4,097-byte case is rejected by `Input_Is_Valid` instead. Older tests do
    cover capacity rejection, and closed-stdout failure, for argument shells
    with sequence bodies (`test_composed_results.py:205-232`).
  - **No continuation test in an argument shell.** What no test covers is a
    *recoverable* failure in an argument shell, or before a later choice, where
    later output is shown to continue. The interposed-libc test does this only
    for a static program.
  - **Recommendation.** Add a 4,089-byte argument case to the sample. Extend
    the `LD_PRELOAD` test to an argument-shell program that has a choice after
    the failing output.

**Documentation**

- **L5. This range broke six specification anchors, and the link check missed
  them.**
  - **Manifest.** Three manifest entries point to headings this commit
    removed:
    - `samples/manifest.json:189` → `#fixed-length-string-assignment`;
    - `:211` → `#input-dependent-branching`;
    - `:351` → `#branch-selected-fixed-length-result`.

    The new sample's anchor `:505` (`#statement-sequencing`) never existed;
    the heading is "Statement sequences and fixed-bound assignment".
  - **Documents.** `docs/greeting.md:18` → `language.md#static-output` and
    `docs/input-branching.md:80` → `assurance.md#input-dependent-branching`
    also broke.
  - **Why nothing caught it.** `test_samples` checks only that the fragment is
    non-empty, and the implementer's link check covered neither the manifest
    nor these two documents.
  - **Pre-existing.** One older broken anchor, `RESUME.md#recover-and-preserve-the-old-vm-evidence`
    (from `README.md`, `host-readiness.md` and `session-memory.md`), predates
    this range.
- **L6. The new milestone row says "In progress".** `roadmap.md:274` lists
  "Statement sequencing and assignment" as "In progress". By the roadmap's own
  definition, that means its forms are excluded from the supported language.
  It contradicts `roadmap.md:17`, `statement-sequencing.md:5` and the
  compiler.
- **L7. Current-tense passages contradict the new language.** (Narrowed.)
  - **Now false or stale:**
    - `roadmap.md:320-323` says "multiple outputs and arbitrary statement
      sequences remain outside the language";
    - `roadmap.md:486-487` says repeated calls "remain excluded";
    - `roadmap.md:100-101` says the dated restrictions audit "classifies all
      current constructs";
    - `assurance.md:335-336` says this revision "requires the common-expression
      checkpoint";
    - `assurance.md:390-391` points only to `common-expressions.md` for
      resource evidence;
    - `docs/language-generalization.md` is called the "current assessment" by
      `roadmap.md:99` and `RESUME.md:203`. It still says bindings are "next
      proposed", counts seven grammar families, and states a 262,144-byte
      report domain (`:108`).
  - **Not a finding.** `restrictions-capacity.md` itself is a dated history
    record, so its "today" is not one.
  - **Carried deferrals.** The previous review's L11 and L12 are carried
    deferrals.
- **L8. Several sequencing restrictions have no stated purpose.** (Narrowed.)
  - **The requirement.** `oracle.md:19` requires every restriction to be
    explicit, with its purpose documented.
  - **Rules that have one.** Staging for nested equality and branch-refined
    assignment is recorded under roadmap item 5, though `language.md` does not
    link to it.
  - **Rules that do not.** No document gives a reason for:
    - the outer guard's fixed placement, with no statements before or after it
      (`language.md:289-291`);
    - `Reject` "alone in the outer false branch" (`trusted-boundary.md:418`);
    - the mandatory `else`. An else-less `if` is valid Ada, rejected only by
      the default "Everything else is excluded".
  - **`elsif`.** It is a choice nested in the `else` arm, so it is reasonably
    covered by the nested-choice staging.
  - **Recommendation.** Mark these as staging and link roadmap items 5 and 7.
    Keep a current restriction-purpose inventory.
- **L9. The roadmap overstates the operator-budget comment repair.**
  (Narrowed.) `roadmap.md:141-142`: "The recognizer comment now distinguishes
  the retained operator budget from actual proof cost." The new comment
  (`src/silver_output_profile.ads:8`) reads "Bound total concatenation proof
  work across declarations and statements". That still presents a count as a
  bound on proof work, with nothing about cost depending on position and
  context. Reword the comment or the roadmap.
- **L10. A tracked capability record embeds an absolute machine path.**
  (Narrowed.) `docs/statement-sequencing.md:44` points to its evidence as
  `/home/canto/src/github.com/berkeleynerd/silver/.silver/…`, whereas
  neighbouring records use relative `.silver/linux-x86_64/…` paths. The
  `tmp/*-active.json` recovery pointers follow the project's long-standing
  convention; they are the deferred L28 item, not a new violation.

**Evidence records**

- **L11. The validation record discloses the right caveats but not their
  extent.** (Merged from two findings; both narrowed.)
  `statement-sequencing.md:145-148` says seven proof files changed during the
  suite and that the run was not a stable-whole-tree timing. `:197-198` says
  module groups were copied from quiescent lanes and that "Lake still
  validates content dependencies". Both statements are accurate, but they
  omit:
  - **The test run's proof tree.** 11 proof files still differed from HEAD
    when the suite ended. The proof-reading Python tests were not re-run on the
    final tree; my re-run closes that gap (133/133).
  - **Where the reused artifacts came from.** All 144 artifact groups in the
    final "complete" check were merged from lane caches. Their traces show
    original builds in earlier tasks' workspaces (73 in
    `module-migration-20261012T153858Z/candidate`, 10 in the
    common-expressions model lane) as well as the bridge (42), ranges (7) and
    model (3) lanes; 9 are canonical. The merge ran one second before the
    "before" snapshot. So "reused 136 of 144 `.olean` artifacts byte-for-byte"
    (`:155-157`) compares against freshly merged state. It rests on those
    earlier kernel checks plus the documented honest-trace trust model
    (`trusted-boundary.md:715-724`).
  - **The differential's binary and decoding.** The differential's binary is
    not named. It decoded JSON strings with `Char.toNat`, so it never
    exercised bytes above 126.

  No unsoundness was found: every trace binds to HEAD (§2). Add one sentence
  for each omission at the evidence site. Reviewers recorded the same pattern
  as L27 last time.

**Lean evidence shape**

- **L12. The sequencing `Form_Result` interpretation inlines two callee
  meanings that earlier bridges routed through the callee interface.**
  (Narrowed.)
  - **What is inlined.** The typed tree renders `allowed_source
    (normalized (source))` and `scan_suffix (normalized (source), …)`, but its
    evaluator never consults `calls.helpers.primitive.normalize` or
    `.allowed` (`SequenceExpressions.lean:110`, `:122`;
    `SequenceEquations.lean:62`, `:87`).
  - **What is newly trusted.** The identity of `Normalized` was already a
    trusted contract premise in earlier bridges (`OutputExpressions.lean:247`).
    The newly trusted fact is mainly the `Allowed_Source` body denotation,
    which Guarded, Arguments and Compose derived from its body equation.
  - **Impact.** Every inlined fact is true and pinned, and
    `model_interpreted` inhabits the premise. Lean's conclusions about the
    actual source are unchanged, but `assurance.md:297-307` and the module
    docstring overstate how much is derived.
  - **Recommendation.** Route both through the callees, as Compose does, or
    document the inlining.
- **L13. "Independent typed grammar" is overstated for the statement layer.**
  `assurance.md:58` says the Sequence modules connect token events "to the
  independent typed grammar". `BasicAt`, `TailAt`, `ConditionalAt` and
  `FormReading` all carry scanner equalities or are stated over
  scanner-computed positions (`SequenceGrammar.lean:16`, `:19`;
  `SequenceLists.lean:20`; `SequenceConditions.lean:68`;
  `SequenceBasics.lean:50`). Completeness therefore cannot detect an
  unintended scanner restriction. This is the previous review's L5 recurring.
  The source correspondence is unaffected.
- **L14. The grammar replacement has only example witnesses, and no new form
  has one.** (Merged from two findings; both upheld.)
  - **No monotonicity theorem.** `Current.Member` is now `Silver.Member ∨
    Sequence.Member`, and nothing proves `Compose.Member → Sequence.Member`.
    `language.md`'s "instances" claim rests on six one-source
    `example_current` witnesses and the native samples. `GuardedExamples`
    still has no `Current` witness. This is the previous review's L3 at a
    larger scale.
  - **No in-tree witness for a new form.** No committed theorem shows
    membership for repeated output, sequential choices, a static-shell choice
    or `samples/statement_sequence.adb`. A reviewer kernel-checked
    `Sequence.Member` for the sample in scratch, so this is a cost and coverage
    gap, not vacuity. This is the previous review's L4.
  - **Mitigation.** The empirical evidence (§0) is strong.
  - **Recommendation.** Commit a `Current` witness for the sample and a
    `Guarded` witness. Then either prove the monotonicity lemma or commit the
    differential as a regression test.

### 3.3 Info

- **I1. One machine-checked source pin was dropped.** The Tokens spec-header
  pin (`Result'First = 1`, length 1–100) went away with the Compose refinement
  facts. The `.finished` and `.scanStep` interpretations rely on it. The fact
  still holds by Ada rules and is proved by GNATprove; only its machine-checked
  pin is gone. Re-add it when `SequenceSourceChecks` is next touched.
- **I2. Theorem packaging changed.** The replacement `executable_*` theorems
  no longer conjoin `CheckedSource`; only `actual_source_correspondence` does.
  `checked_source` is a closed theorem, so this is packaging, not weakening.
- **I3. No concrete execution example of the new semantics.** No concrete
  `Sequence.execute` or `Current.execute` example exists, for instance failure
  followed by later success. The retained behaviour examples evaluate retired
  per-form models, and the universal theorems (`failure_sticky`,
  `accepted_effects_bound`, `healthy_execution`) cover the semantics.
- **I4. The `Has_*` ghost specs now rely on disjointness.** `Has_Arguments`
  and `Has_Assignment` dropped the "no earlier form accepted" clause, so the
  flags' exactness now relies on shell disjointness. That is proved in Lean
  (`SequenceFormDisjoint`). Admission is not weakened.
- **I5. Merge helper and manifest labels.** The merge helper
  (`tmp/sequence_merge_cache.py`) is untracked. Its manifest labels each group
  with the lane it was copied from, not the workspace where it was originally
  built.
- **I6. Process.** Both commits have subject-only messages; the second
  touches 78 files. `tmp/sequencing-active.json` (status
  `complete_published`) still contains the superseded note "Final source check
  not yet rerun".

### 3.4 Unverified observations (lead-assessed)

- **Obsolete Compose equations may still be proved.** `ComposeModelEquations`
  still proves the full former `DefinitionEquations`, and
  `ComposeRecognitionEquations` is retained, although the current
  `InterpretedSource` no longer contains those fixed-shell fields. If they no
  longer correspond to any Ada function, retiring them would avoid their being
  read as current correspondence.
- **The 341-slot binding capacity is never reached with distinct names.**
  Within 4,096 bytes, the reviewer corpus peaked at 285 distinct declarations.
  The documented 341 is an upper bound derived from the source limit, never
  reached and not tested at 341.
- **A report shape the policy would reject.** An argument program whose report
  has `Main` and `Put_Line` but no argument callees would be rejected. It has
  not been observed; it would be a completeness gap only.

## 4. Probes and experiments

| Probe | Result |
| --- | --- |
| Differential, baseline corpus (13,730 sources, HEAD binary) | 0 previously admitted sources rejected; 12 newly admitted, all sequencing forms, all GNAT-legal; native and Lean agree on all 13,730 (Lean: 2 min 43 s on the 13,435 sampled). |
| Differential, new sequence corpus (5,876 sources, seed 20261013) | Native and Lean agree on all (3,170 admitted); 0 mismatches against labelled expectations. 36 targeted extras and 46 edge probes also agree. |
| GNAT legality of admitted sequence programs | 910/910 sampled, 112/112 recognizer probes, 19/19 edge probes, 22/22 extras. |
| Recognizer probes | 167 (112 admitted, 55 rejected, 34 of the rejections legal Ada under documented exclusions). Recognizer cost 0.005–0.023 s, even on 4,096-byte dense sources. |
| Output failure | `LD_PRELOAD` shim failing `putchar` #1 or #20 or `fflush` at each call, closed stdout and `/dev/full`: exit status 1, later output present, non-prefix traces as specified. |
| Compile probes (about twenty) | All proved and ran as specified. Examples: sample (9.0 s); 25 choices and 100 assignments (38 s); 117 choices (307 s, 1.05 GiB, 510,739 B report); 56 output choices (11.1 s); 253 declarations (11.1 s); 30 dynamic concatenations (43.2 s); 664 unused assignments (12.1 s); Standard-name hiding with run. |
| Dense assignment (§3.1) | 100: 46 s; 200: 180 s; 400: 634 s / 2.33 GiB; 800: stopped at 180 s (implementer) and at 905 s / 8.88 GiB (reviewer). |
| Dense assignment to completion (lead), static | 800 assignments: exit status 0 after 2,184.9 s. Peak process-group RSS 8.89 GiB, reached by 10 min and flat afterwards. 844 checks proved (823 run-time checks via Z3). Report 1,734,274 B. The executable exits 0. The run overlapped other agents only in its first 8 minutes. |
| Dense assignment to completion (lead), argument-input | 769 assignments, 4,095 bytes; the generator reproduces the reviewer's 100-assignment probe byte for byte. Exit status 0 after 2,972.1 s, run alone. Peak RSS 9.99 GiB, reached by 15 min and flat afterwards. 813 checks proved (792 run-time checks via Z3); 769 `VC_LENGTH_CHECK`; 771 `INEFFECTIVE` advisories. Report 1,983,843 B, margin 113,309 B. The executable exits 0 for no argument, `hello` and `""`, and exits 1 for two arguments. A single-target variant with 771 assignments (4,093 B) is admitted, but was not compiled. |
| Stack (L2) | `ulimit -s 2048`: `hello_world.adb` and `null.adb` print `Accepted: silver.` and then `STORAGE_ERROR`, exit status 1. |
| Lean probes | Premise-free `executable_pipeline` instantiation; `#print axioms` on about 40 theorems (standard three only); kernel-checked `Sequence.Member` for `samples/statement_sequence.adb` and a static two-choice source; all 144 canonical traces checked against HEAD. |

## 5. Carry-over from the previous review (`9b72d36`)

The recorded dispositions (`common-expressions.md:219-224`,
`roadmap.md:40-47`) fix M1, attach M2 to touched rules, and defer "other low
findings" as a group.

| Item | Status at `9b99d52` |
| --- | --- |
| M1 (composed witness) | **Fixed** (`3c1522f`), and carried forward to the sequencing bridge. |
| M2 (reason-blind negatives) | **Partly followed** (L3). New pairs were added, but six touched rules lack siblings, one negative is confounded, and rejections are still reason-blind. |
| L1 (untracked pin-refresh script) | Unchanged: neither `ComposeSourceChecks` nor `SequenceSourceChecks` carries a generation note. |
| L2 (null-profile check not in facade) | Unchanged; the Sequence facade also omits it. |
| L3 (old forms as instances) | Unchanged and widened (L14). |
| L4 (no program-level witnesses) | Unchanged (L14). |
| L5 (membership through the scanner) | Recurs for the statement layer (L13). A BNF now appears in `language.md:177-186`. |
| L6 (form flags tied by reading) | Superseded by the sequence flags and their Lean disjointness proof (I4); not re-verified. |
| L7 (interpretation premise names) | Not re-assessed. |
| L8 (bare-Main asymmetry) | Resolved by uniform relaxation (L1). |
| L9 (catalogue `count`) | **Fixed.** |
| L10 (manifest tags) | Partly fixed. Capacity tags are fixed for the new sample; `input_branching` still lacks `input_guard`; `string_concatenation` tagging is inconsistent. |
| L11, L12 (stale roadmap text) | Unchanged; more stale text added (L7). |
| L13 (missing milestone row) | Row added, but with the wrong status (L6). |
| L14 (README pointer) | **Fixed.** |
| L15 (`language-generalization.md`) | Unchanged (L7). |
| L16 (guard purposes) | Unchanged; extended by the new rules (L8). |
| L17 (parenthesis depth) | Unchanged. |
| L18 (Lean tests skip with status 0) | Unchanged. This run had 0 skips. |
| L19 (`verify.yml` text) | Unchanged. |
| L20 (one-directional catalogue test) | Unchanged. A reviewer found the 24 identifiers equal in both directions. |
| L21 (uncovered rule positions) | Unchanged (L3). |
| L22, L23 (removed dependency cases; duplicated helpers) | Not re-assessed. |
| L24 (bypass check has no positive assertion) | Unchanged. |
| L25 (no repeatable differential) | Unchanged; another one-off differential (L14). |
| L26 (OS interpreter hash pin) | Reproduces. `check_evidence.py` exits 1 on this host solely for `python3`. |
| L27 (full test run overlapped proof edits) | Recurred, now partly disclosed (L11). |
| L28 (machine paths, `tmp/`) | Recurred once (L10). |
| L29–L31 | Unchanged. |
| I3 (overstated comment) | Replaced (`silver_library_reports.ads:43-45`). |

## 6. Side effects and state

- **New:** `.silver/program-*` directories from probe compiles (including two
  created by the `ulimit` stack probes, which crashed before proof). The two
  dense-assignment runs left `program-XN9AGm` (800 assignments) and
  `program-5Wsxlx` (769 assignments) under `.silver/linux-x86_64/`. Scratch is
  in the session scratchpad only.
- **Unchanged:** tracked files, `.tools/`, `.silver/linux-x86_64/proof`, the
  evidence directories, `tmp/`, and the Git refs and index.
- This report is untracked and uncommitted.

## Appendix: commands

```sh
# Lean evidence binding (no build)
python3 -c 'from scripts import check_lean as cl; ...capture_shared_inputs()...'  # digest 614c92e3…
# GNATprove provenance and summary
python3 - < compare inputs_sha256 of proof-provenance.json with HEAD files
sed -n '/Summary of SPARK analysis/,/^Total/p' .silver/linux-x86_64/sequencing-20261013T192421Z/native-full-reports/gnatprove.out
# Remote and catalogue
git ls-remote https://github.com/berkeleynerd/silver.git refs/heads/main
.silver/linux-x86_64/compiler/bin/silver catalogue   # compared as JSON
# Proof/evidence-reading tests at HEAD
python3 -m unittest tests.test_lean_source tests.test_lean_modules tests.test_lean_evidence \
  tests.test_evidence tests.test_proof_provenance tests.test_platforms tests.test_argument_bounds
# Maximal dense assignment (each capped at 2 h and 20 GiB, sampled group RSS each second)
silver compile native-probes/max-assignments/main.adb   # static, 800 assignments
silver compile dynassign769.adb                          # argument input, 769 assignments
```
