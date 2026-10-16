# Review of 343c2f8, "Record coding-agent recall and shared-work rules"

Reviewed 2026-10-15 on the Linux x86-64 development sandbox (22 CPUs, 31 GiB,
no swap), the project's primary platform, read-only on tracked files, from a
detached worktree at `343c2f8` (`main`, equal to `main` on GitHub). Scope is
everything after the last review (`e2c4fc2`): twelve commits, 7,864 files,
+583,596/−13,573 lines, nearly all of it the Rosetta Code copy:

- `c2c1585`, "Repair assignment and literal admission": the repair of
  [review-e2c4fc2](review-e2c4fc2.md), reviewed here as carry-over (§5);
- `dd26125`, "Measure larger solver budgets for retained expression
  failures", and `7d427b5`, "Raise application proof allowance to 100000
  steps" (Expression Headroom);
- `fa0048d`, "Clarify next expression milestone and deferred roadmap work";
- `4f86f08`, "Expand String expressions to 64 operands" (Larger Expressions);
- `7b5ffea`, "Forward application arguments and preserve run status" (Run
  Arguments);
- `a9e29b5`, "Add partial output with verified Put semantics" (Partial
  Output);
- `a037776`, `8b790a6`, `bd8e218` and `196f3ad`: the Rosetta Code index,
  solutions and assessments, and the move of planning to GitHub (PR #1);
- `343c2f8`, "Record coding-agent recall and shared-work rules".

SPARK changed by +312/−74 lines in 16 files (one new unit, the
`Silver_Process_Runtime` import spec). Hand-written Lean changed by +403/−131
in 45 modules and generated certificates by +13,654/−12,544 in nine; the
module count stays at 252. Tests changed by +596/−95, documentation by
+2,730/−38 in `docs/` plus the README, RESUME, roadmap, AGENTS and
development files, and catalogue, samples, scripts and `language.md` by
+249/−49. The Rosetta copy adds 7,754 files (+563,290) and `rosetta.md`
1,955 lines. The Rosetta and planning commits were made in the reviewing
session itself; an independent reviewer and verifier audited them like
everything else.

## 0. Verdict

There is **one blocker**, in report capacity. A valid program can fail to
compile, fail-safe (exit 3), depending on how loaded the host is. Nothing else
rises above low, and no candidate finding was refuted.

1. **B1: the densest valid programs can overflow the 2 MiB proof-report
   buffer.**
   - **Construction:** the static shell, one `Silver_IO.Put`, 63 `A:=B&B;`
     and 708 `A:=B;`, 4,096 bytes in all. Five proofs gave Main reports of
     2,091,011 to 2,091,380 bytes, 5,772 to 6,141 bytes below the
     2,097,152-byte limit.
   - **Mechanism:** report size depends on prover timing. For each subgoal,
     a record's `stats` credits the Valid prover that finished first. When a
     check's subgoals are won by different provers, the record grows by 120
     to 128 bytes per extra credit. About 48 to 50 extra credits overflow the
     buffer. Under CPU load a verifier measured 33 to 36 multi-credited
     records in a 150-statement analogue, against 1 idle. A dense run under
     contention in this review had 80 of 838.
   - **Effect:** the driver rejects any longer report with "Verification
     failure for admitted Silver: missing or incomplete proof evidence." and
     exit 3. That is fail-closed, not unsound, but it is a compile failure of
     valid Silver, which the Oracle forbids. No run overflowed during the
     review; the overflow is reachable under realistic contention.
   - **Origin:** `4f86f08` sized the 64/63 budgets against a specimen with
     1.5% headroom that was not the worst case (L2).

**What works:**

- **The repairs.** `c2c1585` implements the previous review's B1 rule (N1)
  and its B2 lexical rule exactly as recommended:
  - **Agreement:** the compiler and an independent reference recognizer
    agree on all 107,041 earlier-corpus sources and 46,000 new B1 programs;
    Lean `Silver.Current.accepts` agrees with the compiler on 11,528 of them.
  - **Builds:** all 52,175 admitted programs in those sets pass full GNAT
    code generation. All 596 previously admitted GNAT failures are now
    rejected.
  - **B2:** the rule equals GNAT's trigger set exactly (63 of the 98
    admitted bytes after `[`). Every `"["41"]"`-style encoding, which GNAT
    silently decodes, is rejected at every literal position.
  - **Verdict delta:** all 1,206 verdict changes since `e2c4fc2`, on 68,235
    recorded verdicts, are explained by N1, B2 or the 64/63 limits.
- **Larger Expressions.** The 64-leaf and 63-concatenation limits agree in
  the SPARK, Lean, source pins, specification, catalogue, tests and docs.
  The compiler, Lean and a reference agree on 23,609 boundary and random
  programs; all 11,787 admitted ones build. Six extra 64-leaf proofs
  succeeded.
- **Partial Output.** The compiler, Lean and a reference agree on 30,535
  `Put` programs; all 13,382 admitted ones build. Thirteen compiled programs
  produce exact bytes, flush on empty `Put`, keep the sticky failure status
  under injected write and flush failures, and make no output calls on
  invalid input. The report policy accepts real producer output, and the
  Put theorems use only the standard axioms.
- **Run Arguments.** `Run_Application` is proved with empty skip and assume
  lists, including leak freedom. The two GNAT imports match by disassembly,
  and a malloc/free trace shows every copy freed. Argument bytes 1 to 255,
  empty and 128 KiB values, and up to 181,250 arguments arrive exactly.
- **Solver allowance.** The 100,000-step allowance is set in one place and
  applies to applications only. Step counts reproduce exactly across runs
  and invocation paths. All 16 admitted 64-leaf candidates proved; the
  hardest goal needed 44,526 Z3 steps (I2).
- **Lean trust base and evidence.**
  - `proof/` has no `sorry`, `native_decide`, `implemented_by` or other
    escape.
  - The axiom audit covers the 252 HEAD modules: 57,302 declarations, with
    standard axioms only.
  - The statements of `executable_main_correct`, `executable_pipeline` and
    `current_executable_membership` are character-identical to `e2c4fc2`'s.
  - All 17 certificates regenerate byte-identically, every Lean input digest
    recomputes, and every native check total reproduces (§2).
- **Planning and Rosetta.** Nothing in `rosetta/` reaches the build, the
  proof provenance or the tests. All 7,634 relative Markdown links resolve.
  Re-rendering reproduces `rosetta.md` and all 1,782 `silver.md` files byte
  for byte, and an independent implementation of the ordering rule
  reproduces all 1,578 positions.

**What needs attention:**

1. **Fix B1 first (#17).** The owner made it the first work package of For
   loops and integers, before that milestone admits any new construct; the
   milestone adds overflow and range checks per statement.
   - **Bound:** derive the buffer size from the record format, not from
     specimens. The worst case for this construction is about 2.37 MB.
   - **Placement:** the report buffer lives on the stack in `Compile`'s
     frame. Move it off the stack rather than enlarging a stack array; that
     also fixes L4.
   - **Guard:** add a regression that computes the maximal report size of
     the densest admitted construction from the format.
2. **Make the proof configuration explicit.** Provers run under an
   undocumented 1,000 MiB memory cap (L1). No test pins the step allowance
   (L3), and the documented 1.5% headroom is wrong (L2).
3. **Driver.** Spawning with the report buffer on the stack overflows at about
   190,000 arguments (L4), and launch failures are described as abnormal
   exits (L5).
4. **Regressions and wording.** Add the missing B2 regressions (L6) and fix
   the catalogue's bracket condition (L7).
5. **Planning.** Decide the integer scope of For loops and integers and its
   motivating sample (L8; decision #34). Record authorizations and the
   current pause where agents can verify them (L9). The Rosetta tooling and
   documentation items are L10 to L15.

## 1. Method

- **Isolation.** This review modified no tracked file, nothing in `.tools/`,
  no evidence directory and no Git ref. Sources were read from a detached
  worktree, `tmp/review-343c2f8`. Compiles used the installed compiler only
  after checking its hash (`b1ef9b58…`), which never changed. Lean probes
  read build artifacts that were verified to match HEAD, and verifiers used
  a frozen copy (§6). §6 lists the side effects.
- **What I ran myself:**
  - a compiler snapshot and hash, and its build time against the source
    modification times;
  - a `silver catalogue` comparison;
  - a byte-verified copy of the HEAD Lean build, checked by re-running 20
    smoke verdicts on it;
  - monitoring of the concurrent for-loops work, the machine's memory and a
    memory guard for the longest proof;
  - triage, deduplication and grouping of the findings.
- **Multi-agent review.** Seven read-only reviewers on Opus 5.5, one lens
  each:
  - the repairs and carry-over;
  - the solver allowance;
  - Larger Expressions;
  - Run Arguments;
  - Partial Output;
  - assurance and evidence;
  - planning and Rosetta, including `343c2f8`.

  They raised 47 candidate findings: 1 blocker, 16 low and 30 info. Four
  verifiers, one per area, re-derived all 47 and were told to refute rather
  than trust the reviewer's evidence. Result: 30 upheld, 13 narrowed, 4
  merged as duplicates, none refuted. One info item rose to low (L9), two
  lows became info (I8, I18), and one item moved to §6.
- **Owner's no-routine-rerun rule.** Every agent was bound by it: no Lean
  build, `check_lean.py`, `dev.py prove`, full suite or replay. Agents ran
  only targeted probes:
  - `silver check`, `compile` and `run`;
  - GNAT `gcc -c` with code generation;
  - read-only Lean probe files: three-way corpus evaluation, hash and trace
    checks, theorem statements and axioms;
  - a few direct GNATprove runs on copies, to isolate the memory-limit and
    worker-count behaviour.

  Compiles and Lean probes went through a shared three-slot memory-aware
  runner. The dense report-capacity proofs took 43 minutes to 2 hours 7
  minutes each and about 12 GiB of memory per process.
- **Cost.** About 1.83M output tokens: reviewers 1.39M, verifiers 0.19M, lead
  0.25M. About 505M cache reads. The reviewers took 4 hours 49 minutes of
  wall-clock time, mostly waiting on the dense proofs; the verifiers took 30
  minutes.

## 2. Native validation (Linux x86-64)

| Check | Result |
| --- | --- |
| Remote and tree | `main` on GitHub is `343c2f8f5a`. `oracle.md`, `silver.gpr`, `alire.toml`, the lakefile, `lean-toolchain`, the certificate generator, `check_lean.py` and `proof_provenance.py` are unchanged in range. |
| Installed compiler | sha256 `b1ef9b58…`, built at 14:44:12 UTC after the last `src/` edit (14:44:01). Its 29 unit dependency checksums equal GNAT checksums of HEAD's sources. Unchanged throughout the review. |
| Catalogue | `silver catalogue` is byte-identical to `catalogue/silver.json` (27 constructs). |
| Native proof evidence | HEAD (Partial Output): 3,273 checks (581 flow, 2,692 proof), 21 units, 318 entities, 16 imports, 80 classified limitation notes. HEAD's `check_evidence.audit_reports` reproduces every recorded total: 3,172 (repairs, step budget, Larger Expressions), 3,235 (Run Arguments) and 3,273. Each milestone record binds its commit's inputs. The interpreter identity differs here (I16). |
| Lean evidence | The input digest recomputes from Git objects at every implementation commit: `1ceb3d1d` (`e2c4fc2`), `2dd2bc19`, `01b7c8ea`, `1e4cf8f8`, `3081edc0` and `8425c22b` (`a9e29b5` and HEAD). 252 modules; 57,302 audited declarations, standard axioms only. All 252 trace source hashes and 1,012 artifact hashes matched HEAD. |
| Certificates | All 17 regenerate byte-identically from HEAD's Ada. |
| Top-level theorems | Statements character-identical to `e2c4fc2`'s. The model-witness instantiations elaborate. `#print axioms` gives only `propext`, `Classical.choice` and `Quot.sound` for these and for the new Put and B1 theorems. |
| Test records | Method counts 307, 307, 308, 312 and 319 at the five implementation commits match the logs. All passed except Larger Expressions' disclosed `test_copy_values` failure, fixed and rechecked 8/8. All 18 new or renamed test methods ran in the final frozen 319-test suite. |
| Corpus records | Admission Repairs: 269,622 sources, 93,007 admitted, 0 GNAT failures, bound to `c2c1585`. Larger Expressions: 306 sources, 226 admitted, `b16bb1d1…`, bound to `4f86f08`. Partial Output: 115 sources, 82 admitted, `05ee251f…`, bound to `a9e29b5` and compiler `b1ef9b58`. |
| Step reproducibility | Production `silver compile` at HEAD reproduced every per-goal step count of the retained sources: 154/154, 167/167 and 345/345 goals (Z3 10,738, 11,609 and 15,794). |

## 3. Findings

### 3.1 Blocker

1. **B1: the densest valid programs can overflow the 2 MiB proof-report
   buffer.** (Verifier: upheld, blocker.)

   - **Construction.** This program is valid Silver: it uses mutable String
     declarations with static-length initializers, equal-length assignments,
     the 63-operator budget and one admitted `Put`. `language.md:306` sets
     no statement or output-count limit. The compiler and the reference both
     accept it (sha256 `40d674c9…`).

     ```ada
     with Silver_IO;procedure Main is pragma SPARK_Mode(On);A:String:="";B:String:=A;begin Silver_IO.Put(B);A:=B&B;  -- 63 times
     A:=B;  -- 708 times, then padding to 4,096 bytes
     end Main;
     ```

     The single output call matters. With it, flow analysis emits one
     unused-assignment advisory (about 397 bytes) per assignment. Without it
     (775 assignments, no `Put`), the report was 1,798,228 bytes.
   - **Measured size.** Five proofs of two variants (the `Put` first or
     last) gave 2,091,011 to 2,091,380 bytes, 99.71 to 99.73% of the
     2,097,152-byte buffer, leaving 5,772 to 6,141 bytes. Length-check
     records average 2,166 bytes, range-check records 1,632 and advisories
     397.
   - **What varies.** Between runs of identical source, only `stats`
     changes. Times are fixed-width floats, step counts are identical, and
     the report contains no paths. For each subgoal, `stats` credits the
     Valid prover with the smallest recorded time; this held for all 5,553
     records in nine reports. All three provers finish Valid on these goals,
     so the credits follow wall-clock timing. A check whose subgoals are won
     by different provers lists several provers, each extra one adding 120 to
     128 bytes.
   - **Threshold and evidence.** 48 to 50 extra credits, about 7.2 bytes
     per record, overflow the buffer. Observed rates:
     - the delivery specimen, run alongside other validation: 6.1 bytes per
       record;
     - the 775-assignment program under contention in this review: 11.7;
     - a 150-statement analogue under CPU load: 33 and 36 multi-credited
       records against 1 idle, 23 to 25 bytes per record.

     At those rates the dense report reaches about 2,100,900 to 2,110,500
     bytes. Credits alone can reach 2,290,056 bytes; with interrupted-prover
     records, seen in compact probes but not in dense ones, the theoretical
     maximum is 2,370,822.
   - **Driver.** `Read_File` (`src/silver_platform.adb:55-109`) fills the
     2,097,152-byte buffer and reads one byte more. A longer report sets
     `Too_Long`, and `src/silver.adb:287-291` stops with "Verification
     failure for admitted Silver: missing or incomplete proof evidence.",
     exit 3. Nothing truncates.
   - **Severity.** No overflowing run was observed, because the review host
     was lightly loaded when the dense proofs finished. The overflow is still
     reachable under ordinary contention. GNATprove's `-j0` follows the
     host's CPU count, so the timing noise also varies by machine.
   - **Fix.**
     - **Bound:** size the buffer, and `Max_File_Length`, from a derived worst
       case: up to three credits per three-subgoal check, six-digit steps
       and interrupted-loser records. For example, use 4 MiB, then re-prove
       the reader and policies, or parse the report incrementally.
     - **Placement:** do not enlarge the stack array in `Compile`'s frame;
       move the buffer off the stack (see L4).
     - **Guard:** add a regression that computes the densest admitted
       construction's maximal report size from the record format.
     - **Process:** re-derive the bound before any milestone that adds
       checks per source byte.

### 3.2 Low

1. **L1: provers run under an undocumented 1,000 MiB memory cap.**
   - **Mechanism:** GNATprove 16.1 treats the driver's `--memlimit=0` as
     unset when `--level=2` is given (`src/silver.adb:114-119`). gnatwhy3
     receives `--memlimit 1000`, and every CVC5, Z3 and Alt-Ergo process
     runs with `RLIMIT_AS` = 1,048,576,000 bytes. The verifier read this
     from live processes and from `why3session.xml`. Option probes isolate
     the cause: without `--level` the limit is unlimited, and with
     `--memlimit=2000` it is 2,000 MiB.
   - **Impact:** on an admitted 64-leaf verification condition, Alt-Ergo
     dies with "Fatal error: out of memory" at about 899 MB under the cap,
     so CVC5 and Alt-Ergo are lost as fallbacks on hard goals. Z3 proved
     every hardest goal measured within the cap, so no admitted program is
     shown to fail.
   - **Documents:** `docs/assurance.md:468-470` and `:603-613` and
     `docs/trusted-boundary.md:43` and `:623-647` state `--memlimit=0` and
     phrase completion in steps only. `restrictions-capacity.md:116` calls
     the memory flags zero. The GNATprove guide's claim that
     `--level=2 --timeout=0 --memlimit=0 --steps=N` disables the limits
     (`how_to_view_gnatprove_output.rst:127-132`) does not hold in 16.1.
   - **Fix:** choose the policy explicitly. Either pass `--memlimit=N` with
     a purpose and measured headroom, or drop `--level` and pass the
     equivalent options so that zero means unlimited. State the memory term
     in the completion premise, and check the `why3session.xml` limits in a
     test.
2. **L2: the documented 1.5% report headroom is overstated.**
   - **Claims:** `docs/larger-expressions.md:15` says the limits "retain the
     existing report capacity", and `:97-99` says the result supports
     "retaining the existing report buffer". The mirrors are
     `language.md:329-334`, `docs/trusted-boundary.md:673-677`,
     `roadmap.md:75`, `RESUME.md:74` and `README.md:126-127`.
   - **Reality:** the 32,147-byte (1.5%) figure holds only for the
     argument-shell specimen. The static shell fits more assignments and
     leaves 0.28 to 0.29% (B1). Even the specimen's own figure includes
     4,999 bytes of timing-dependent credits: its deterministic floor is
     2,060,006 bytes. The specimen was also measured with a separate runner,
     not the production `silver compile`.
   - **Fix:** correct the statements, distinguish the deterministic floor
     from the timing-dependent part, and record the static-shell
     single-output construction as the capacity reference until B1 is fixed.
3. **L3: nothing pins the 100,000-step allowance.**
   - **Gap:** no test or evidence script asserts `--steps=100000`,
     `--timeout=0` or the memory limit. `tests/test_samples.py:56-60`
     checks only `--warnings=` and `--checks-as-errors=on`, and
     `scripts/check_evidence.py:59-61` covers the compiler's own options.
     Every 64-leaf case in the suite is admission-only; the largest real
     compiles have 16 and 18 leaves.
   - **Risk:** the retained 64-leaf sources are admitted and need 10,738 and
     11,609 Z3 steps. A revert of `src/silver.adb:119` would very probably
     pass the suite while admitted programs fail to prove. This is inferred;
     the suite was not run.
   - **Fix:** assert the option set in `test_samples`, check the
     `why3session.xml` prover limits, and add one 64-leaf program as a real
     compile.
4. **L4: `silver run` overflows its stack at about 190,000 arguments.**
   - **Reproduction:** at the README's validated 8 MiB stack, 190,000 empty
     forwarded arguments give STORAGE_ERROR and status 1 after a complete
     proof and build, before the application starts. 150,000 arguments run
     normally. The kernel accepts both vectors.
   - **Cause:** `Publish` runs inside `Compile`'s declare block, so the
     2,097,152-byte report buffer is still on the stack (a 2,202,184-byte
     frame). GNAT `Spawn_Internal` then puts per-argument arrays and all
     argument bytes on the stack.
   - **Scope:** the crash happens before exec, whatever the program. A
     program that ignores its arguments, and would exit 0, exits 1 instead
     (inferred from the code path).
   - **Documents:** `docs/run-arguments.md:77-79` names sufficient stack as
     a premise but does not quantify the limit, and `README.md:279-280`
     implies only OS limits apply.
   - **Fix:** release the buffer before spawning or move it off the stack;
     otherwise state the effective limit.
5. **L5: launch failures are described as abnormal exits.**
   `__gnat_portable_spawn` returns -1 when fork fails, when `waitpid`
   returns another process and when the child dies by a signal.
   `Run_Application` also returns -1 from its NUL guard without spawning
   anything (`src/silver_platform.adb:160`, `:177-181`). The driver prints
   "Execution failed: application did not exit normally." for every result
   outside 0 to 255 (`src/silver.adb:221-223`), although in the first and
   third cases nothing ran. The exit status (3) is right, and exec failure
   correctly gives 1. **Fix:** use neutral wording, such as "could not be
   started or did not exit normally", or report the NUL guard separately.
6. **L6: three requested B2 regressions are missing.**
   `tests/test_predicates.py:94-114` lacks the elsif form, `"x[""["then` and
   the kept-rejected `"["41"]"` that `review-e2c4fc2.md:390-394` asked for.
   The compiler rejects all three today. GNAT compiles `"["41"]"` without
   error and decodes it to `"A"`. That makes this the one family where a
   lexer regression would cause a silent miscompile instead of a build
   failure. **Fix:** add the three rejected cases, the first in initializer,
   output and comparison positions, and the admitted sibling
   `"[""41""]"then`.
7. **L7: the catalogue's bracket condition is looser than the
   specification.** `final_bracket_boundary` (`src/silver_catalogue.adb:114`,
   `catalogue/silver.json:76`) says "a closing quote after decoded [ cannot
   immediately precede an ASCII letter, digit or underscore". It omits
   "final" and "immediately after". Read literally, it excludes `"[x"then`,
   `"[]"then` and `"[""x"then`. `language.md:144-149`, Lean and the
   compiler all admit those, and GNAT builds them. No implemented artifact
   disagrees, but `oracle.md` requires the normative catalogue to agree.
   **Fix:** "if a literal's final decoded character is [, its closing quote
   cannot immediately precede an ASCII letter, digit or underscore", in both
   places, with a test asserting the string.
8. **L8: the For loops and integers milestone has no sample that uses
   integers.**
   - **Assessment:** the Colour bars/Display assessment drops the colours
     the task requires and prints labelled text rows. Its surface lists
     `integers`, but the program uses no integer variable or arithmetic.
   - **Effect:** that one entry is what puts integers into stage 2. Without
     it, stage 2 is for loops alone (2 samples), and integers move to stage
     3 with ranged subtypes and `'Image` (13 samples). The verifier
     reproduced this with the progression code.
   - **Milestone:** the authorized milestone (#10, #13 to #16) names Colour
     bars/Display and Loops/For as its motivating samples. Neither exercises
     integer arithmetic, and the milestone excludes scalar formatting, so
     integer results cannot be printed. `development.md:39` asks for a
     motivating sample.
   - **Fix:** reassess Colour bars/Display (exclude it, or plan a faithful
     image file) and re-render. The owner decides whether the integer half
     needs a motivating sample, for example Loops/Downward for, or should
     include `'Image`.
9. **L9: the milestone's authorization and its pause cannot be verified
   from `main` or GitHub.** (Raised from info by the verifier.)
   - **Order:** issues #10 and #13 to #16 moved to In progress or Ready at
     16:34:29 to 16:34:54 UTC. Their comments cite a session-memory entry,
     committed at 16:36:00 in `29b1438` on the local branch
     `feat/for-loops-integers`.
   - **Not on GitHub:** that branch is not on GitHub, so the record is not
     reachable from `main`, and the eight links from #13 to #16 into it
     already return 404.
   - **Pause:** the owner's pause ("Remain at scoping", a comment on #10 at
     18:11) is in no committed session memory. The board still shows #14
     and #15 In progress and #16 Ready, which by `docs/planning.md` means
     startable.
   - **Rules:** `docs/planning.md:43-48` does not say where or when an
     authorization counts as recorded. Follow-up triggers, such as #7's
     evidence preservation, conflict with the rule that Backlog items need
     authorization before work.
   - **Fix:** define "recorded" as committed on `main`, or cited by SHA.
     Record the authorization and the pause there, set the board statuses
     to match, and repoint the links. State that a follow-up's trigger
     permits immediate evidence preservation.
10. **L10: the Rosetta rubric misstates SPARK 16.1.** Rule 8
    (`rosetta/assess.js:96`) and the `exception-handling` conflict
    (`:116`) say SPARK excludes exception handlers and goto. The pinned
    manual supports handlers and locally handled raise statements
    (`references/spark/16.1/docs/lrm/source/exceptions.rst:9-43`) and
    allows forward goto (`statements.rst:548-559`). Seven tasks carry the
    conflict. Exceptions and Search a list are excluded on it alone, as
    permanently impossible rather than outside Silver's current scope.
    **Fix:** treat local raise and handle as a Silver scope exclusion with a
    purpose and cross-call propagation as an annotations conflict, then
    reassess the two tasks.
11. **L11: `refresh.py --render` is nondeterministic.** The "The
    assessments flag ..." sentences (`rosetta/refresh.py:704-708`) count a
    per-item set with `Counter` and keep `most_common(4)`, so tie order and
    the four-item cut follow the string-hash seed. Three seeds gave three
    different `progression.md` files, differing at lines 1047, 1983, 1999,
    2014 and 2029. The rules require a render at every admission, so each
    will produce spurious diffs. **Fix:** use `dict.fromkeys` and a
    deterministic tie-break, and compare renders under two seeds in a test.
12. **L12: `refresh.py` deletes the generated tree before validating its
    cache.** `build()` removes the group directories and `manifest.json`
    first. A missing cached page then fails with `FileNotFoundError` at
    `rosetta/refresh.py:556` and leaves a partial tree with no manifest and
    no listing. Non-generated files inside group directories are deleted.
    Tracked content can be restored from Git. **Fix:** validate the cache
    first, or build in a sibling directory and swap it in; document that
    group directories are regenerated in full.
13. **L13: the board's views and workflows are not configured.** The board
    has one default "View 1", and only "Auto-add sub-issues to project" is
    enabled. `docs/planning.md:67-76` describes four views and the add and
    close workflows. Its Migration section is silent on step 2, and the
    agent routine never says to add issues or set Done by hand. Closed
    issues keep their last status. **Fix:** record step 2 as pending and
    give agents an interim manual rule; the owner configures the views and
    workflows in the web interface.
14. **L14: `RESUME.md` is still presented as the current handoff.**
    `README.md:23` calls it the "current handoff". Its Rosetta statements
    predate `a037776` ("absent through an external action"). The new rules
    put handoffs in issue comments, so agents see two homes. **Fix:** retire
    or rescope `RESUME.md`, for example to local tools and recovery, and
    update the README.
15. **L15: assessment agents read untrusted wiki text with full tools.**
    `rosetta/assess.js:131-140` calls `agent()` without an `agentType`, so
    assessors are default workflow subagents with Bash and Write. A prompt
    sentence is the only containment, and nothing says the wiki and
    solution files are untrusted third-party text. `AGENTS.md:11-13`
    already requires owner authorization for work. Nothing states that a
    reassessment is a costly, budgeted run (up to 1,000 agents per
    workflow). **Fix:** use a read-only agent type or inline the excerpts,
    add an untrusted-data instruction, and state the authorization and
    budget expectation in the README and `docs/planning.md`.

### 3.3 Info

1. **I1: dense proofs cost more than recorded.** The dense static-shell
   programs took 43.6 to 50.8 minutes when lightly contended, and 2 hours 7
   minutes under heavy contention, against the documented 53.6 minutes.
   About 12 GiB per gnatwhy3 process is plausible but was not sampled. The
   records already call their figures specimens; when re-recording, keep
   per-process memory for the densest construction.
2. **I2: admitted inequality guards nearly triple the hardest goal.**
   String-inequality conjuncts, admitted in any number within 4,096 bytes,
   raise the hardest goal from 15,794 to 44,526 Z3 steps (210 two-letter
   conjuncts). That leaves a 2.25-fold margin, against 6.3-fold for the
   recorded maximum, and on Z3 alone. Record these witnesses and the margin
   next to the completion premise.
3. **I3: the 64-leaf limit never decides membership alone.** Leaves equal
   operators plus one, and the 63-operator source budget already caps
   every expression at 64 leaves. It would need its own tests only if the
   limits were decoupled.
4. **I4: limits are copied as literals.** `src/silver_path_facts.ads:6-7`
   and `src/silver_catalogue.adb:248`, `:251`, `:363`, `:367` and `:371`
   repeat 64 and 63 instead of deriving them. Tests catch drift today.
5. **I5: interrupts during `silver run` are undocumented.** With GNAT's
   direct spawn and no handler, a SIGINT to the foreground group now kills
   the driver silently; before `7b5ffea` the driver survived. Proof and
   build still use `system()`, so an interrupt there is reported as a
   "toolchain or implementation defect". That behaviour is older.
6. **I6: the status line merges with unterminated output.** A program
   ending with `Put` makes `silver run` print, for example, "HelloExecution
   completed successfully." The tests use substring checks. Document it or
   send the driver's status to stderr. Do not add an unconditional newline,
   which would leave a blank line after `Put_Line`. (Found twice.)
7. **I7: no real compile pins the exact ghost-advisory texts with homonym
   locals.** The report policy accepts those advisories only as exact
   strings. Compiles with locals named after the ghost objects, `Put` or
   `Put_Line` keep the simple-name messages today. Add one such compile.
8. **I8: the adoption record says the retained sources are still
   rejected.** `docs/expression-headroom.md:137-138` has said so in the
   present tense since `4f86f08` admitted both. `larger-expressions.md:166-167`
   calls probes from before Put "current-runtime". Both are dated records;
   add a dated note. (Lowered from low.)
9. **I9: dated records still state 10,000 steps.** These are
   `command-line-greeting.md:104` and `:252`, `hello-world.md:54`,
   `architecture-review.md:91`, `remote-plan-review.md:44` and
   `restrictions-capacity.md:116` and `:213`. That last capacity table is
   also stale on operands and report limits. Add dated-scope notes.
10. **I10: the evidence index stops before Partial Output.** README's
    "Proofs and platform evidence" index has no Partial Output entry.
    `docs/assurance.md`'s checkpoint paragraph and line 641 still name
    older records as current; it links Partial Output only in its opening
    paragraph. This is the same class as the previous review's I9.
11. **I11: B2 wording.** `language.md:145-147` cites "pinned ASCII
    settings", but builds use GNAT's default encoding; ASCII-only is
    Silver's own rule. `docs/trusted-boundary.md:61-63` says the adjacency
    can fail code generation, but GNAT's frontend rejects it (`-gnatc`
    fails), so proof fails too. Confirmed: `-gnatW8`, `-gnatWh`, `-gnatWb`
    and `-gnati1` all decode `"["41"]"` to `"A"`.
12. **I12: carry-over dispositions are missing.**
    `docs/admission-repairs.md` records none for the previous review's I3 to
    I8 and I10, although I10 was implemented. Local use clauses (previous
    L2) are listed neither in the roadmap nor on the board. Issue #6 covers
    the generic legacy cleanup.
13. **I13: full code generation is not tracked tooling.** The
    recommendation was carried out as one corpus pass (269,622 sources,
    93,007 admitted, 0 failures) and per-milestone passes (226 and 82). The
    runner lives in ignored evidence. No tracked test code-generates the
    check-only admitted siblings, the class in which both earlier blockers
    were found.
14. **I14: a correction to the previous review.** Its suggested admitted
    `Input & "abcd"` sibling (`review-e2c4fc2.md:303-305`) contradicts the N1
    rule it recommended. The repair correctly rejects it, and
    `language.md:282-284` says so; the delivery record does not note the
    deviation.
15. **I15: manifest tags.** `release_report` and `names_calls` omit
    `string_concatenation` although both concatenate. Omitting
    `string_literal` is the newer samples' convention. Issue #6 covers
    manifest tags.
16. **I16: native provenance binds the interpreter binary.** Every record
    from Admission Repairs to Partial Output binds the Jun 18 `python3.14`
    build. The review container runs the Aug 20 build, so
    `validate_provenance` fails here with "proof tool changed: python".
    "Does not reproduce" in `docs/admission-repairs.md:31-32` holds only on
    the implementer's image. Bind Python by version and script hashes, or
    document the dependency. (Found twice.)
17. **I17: legacy leftovers.** `SequenceMain` maps `Put` to the `Put_Line`
    output event for exhaustiveness. It lies outside the `Current` and
    `PredicateCorrespondence` closures, so the mapping is inert. Orphan
    probe traces and two `*.review-candidate` files remain in the canonical
    workspace. 55 of the 251 HEAD traces were built in lanes and promoted,
    as disclosed.
18. **I18: Rosetta licensing needs work before any publication.**
    - **Notices:** the copy carries only a GFDL 1.3 URL. A full GFDL text is
      tracked under `references/` but not linked from `rosetta/`.
    - **Attribution:** there is no per-task contributor or history record.
    - **Labelling:** all solution code is labelled GFDL, although one copied
      file carries its own licence notice, which is retained.

    The repository is private, so this is a risk to resolve before any
    publication, with legal review. (Lowered from low.)
19. **I19: `silver.md` lists the supported `Put` as beyond today's
    Silver.** 915 files do. The rules also do not say how to record a
    construct that is only partly admitted. That matters now: the integer
    increment admits constants and parenthesized arithmetic, not the full
    `integers` surface that 1,465 entries list.
20. **I20: Unicode variable names sits in stage 3.** Silver source is
    ASCII-only, and a non-ASCII identifier is rejected. The rubric has no
    source-encoding construct.
21. **I21: dangling roadmap references.** `roadmap.md:173-177` still refers
    to "item 5" and "this consolidation", and line 93 to "this table".
    These moved to `docs/roadmap-history.md` or no longer exist.
22. **I22: Rosetta documentation inaccuracies.**
    - **Ordering:** `progression.md` says free samples follow "shortest
      first"; the code orders input users first, then likely before
      plausible, then size.
    - **Models:** the README omits the Haiku tier that produced 39 final
      verdicts. Of those escalated from Haiku, 23 went to Sonnet and 1 to
      Opus.
    - **Provenance:** `docs/planning.md` says `refresh.py` generates
      `coverage.json`, but it only reads it.
23. **I23: assessment quality.** A spot check found the assessments mostly
    credible. The exceptions:
    - ABC problem is rated likely although its approach admits that its
      algorithm is incorrect;
    - Monads/List monad has no real bind;
    - Wireworld's summary contradicts its outlook.

    Treat assessments as triage and review a milestone's driver samples by
    hand.
24. **I24: drift in `343c2f8`'s rules.**
    - **Session memory:** the new entry restates the routine and already
      omits the check that no other agent has claimed an issue.
    - **Stash:** `docs/planning.md:130` limits the stash ban to the shared
      checkout, but every worktree shares the stash.
    - **Claims:** no rule releases or expires a claim.
25. **I25: `tmp/` is not ignored.** Neither `.gitignore` nor
    `info/exclude` covers it, and no rule forbids `git add -A`. Nested
    worktrees would be staged as embedded repositories.
26. **I26: the Rosetta copies fail `git diff --check`.** The verbatim files
    produce 19,713 diagnostics in 2,929 files, and no `.gitattributes`
    exempts them. A future refresh will flood the documented docs check.

## 4. Probes and experiments

| Probe | Result |
| --- | --- |
| Repairs: compiler vs N1/B2 reference | 0 disagreements on 107,041 earlier sources (41,323 admitted), 46,000 new B1 programs (9,085 admitted), a 1,650-program B2 matrix, 200 dynamic-target, 30 comment, 20 64-leaf and 24 hex probes. |
| Repairs: Lean vs compiler | 0 disagreements on 11,528 programs, importing only the 71-module closure of `Current`, verified against HEAD before and after. |
| Repairs: full code generation | 52,175 admitted programs, 0 failures, 0 diagnostics. All 596 previously admitted GNAT failures are rejected; 412 buildable dead-arm programs are newly rejected, as documented. |
| Larger Expressions three-way | 23,609 programs (11,787 admitted): boundaries at 1 to 66 leaves, 12 groupings, every expression position, budget splits, byte capacities, 12,000 random programs. 0 disagreements; all admitted build. |
| Partial Output three-way | 30,535 programs (13,382 admitted), including hiding, visibility, invalid-input placement, limits and the delivery's 115-source corpus. 0 disagreements; all admitted build. |
| Partial Output behaviour | 13 compiles and one run: exact bytes, empty-`Put` flush, `/dev/full` and closed stdout give status 1, sticky status after injected failures, no output calls on invalid input. Six homonym-local compiles keep the exact advisory texts. |
| Solver allowance | 16 admitted 64-leaf compiles, all proved; hardest goals 246 to 44,526 Z3 steps. Step counts reproduce exactly. A deep-context run adds about 0.5 steps per preceding statement. |
| Report capacity (B1) | Dense compiles: one 775-assignment program without output (1,798,228 bytes, 2 h 7 min under contention), three runs of the 771-assignment `Put`-first program and two of its `Put`-last variant (2,091,011 to 2,091,380 bytes, 43.6 to 50.8 min). A 150-statement analogue: 1 multi-credited record idle; 33 and 36 under 22 CPU burners. At `-j2`: 2, no interruptions. |
| Prover memory (L1) | Live `/proc/<pid>/limits` for CVC5, Z3 and Alt-Ergo: `Max address space 1048576000`. Option probes: limit 1,000 MiB with `--level=2 --memlimit=0`, 2,000 MiB with `--memlimit=2000`, unlimited without `--level`. Alt-Ergo out of memory under the cap on a saved verification condition. |
| Run Arguments | Exact forwarding through the real driver for bytes 1 to 255, 65,536 apostrophes, 131,071-byte values and up to 181,250 arguments. 190,000 arguments: STORAGE_ERROR (L4). Status mapping matches the documents. A SIGINT demonstration on own process groups confirms I5. |
| Lean trust and evidence | Escape scan, axiom audit, theorem statements, 17/17 certificates and digests at six commits all as in §2. |
| Planning and Rosetta | 7,634 links and 89 issue links resolve. Re-render reproduces `rosetta.md` and 1,782 `silver.md` byte for byte; three hash seeds give three `progression.md` files (L11). Independent ordering reproduces 1,578 positions. Sensitivity run for L8. Board read by GraphQL (L13). |

## 5. Carry-over from the previous review (`e2c4fc2`)

| Item | Status at `343c2f8` |
| --- | --- |
| B1 impossible dynamic value for a static target | **Fixed** in `c2c1585` as rule N1, natively, in Lean (`equalSummary`, `sameLength`) and in the specification and catalogue. Verified by the corpora in §4. |
| B2 `"["then` | **Fixed** with the lexical rule, natively, in the Lean lexer and in the catalogue; GNAT's brackets premise is recorded in `trusted-boundary.md:61-66`. Regressions are incomplete (L6), and the catalogue (L7) and specification (I11) wording need tightening. |
| L1 `First_Or_Default` hiding wording | Fixed, with the `later_named` test. |
| L2 restriction purposes | Fixed (`language.md:71-73`, `:95-97`, catalogue `scope_purpose`). Local use clauses are not listed as remaining work (I12). |
| L3 test gaps | Fixed: static-shell, shorter-right-hand-side and both-direction B1 regressions, and input-named Names tests. |
| L4 Names lexical meanings | Fixed: `CheckedSource.namesLexical := ⟨rfl, rfl⟩`. |
| I1 785-assignment shape | Recorded in Admission Repairs. Superseded by B1: 771 assignments with one `Put` leave far less room. |
| I2 interpreter identity | Recorded as "does not reproduce"; it still reproduces in the review container (I16). |
| I3, I5, I6 | Unchanged and disclosed (`language.md:491-493`, `trusted-boundary.md:718-746`). No recorded disposition (I12). |
| I4 `-gnatc`-only probes | No action needed. |
| I7 import-closure test | Unchanged: it still guards only `ComposeSourceChecks`. |
| I8 lane-built artifacts | Recurs: 55 of 251 HEAD traces promoted from lanes (disclosed); orphan traces and candidates remain (I17). |
| I9 Lean record pointer | Fixed: `assurance.md` links Admission Repairs. The same kind of gap recurs for Partial Output (I10). |
| I10 B1 invariant lemma | Implemented as `equalSummary_static_target` (`PredicateStatements.lean:60-69`) but not recorded (I12). |

Correction to the previous review: its suggested admitted `Input & "abcd"`
sibling contradicts its own N1 rule (I14).

## 6. Side effects and state

- **New.** 52 `.silver/linux-x86_64/program-*` directories from probe
  compiles: 46 by reviewers and 6 by verifiers. Keep these until B1 is
  fixed, because they hold its evidence:
  - `program-7gXgjG`: the 775-assignment program;
  - `program-cXlW1V`, `program-L3xnV3` and `program-40oTy6`: the
    771-assignment program;
  - `program-CKSNAa` and `program-qiwOMI`: its `Put`-last variant.

  The review worktree `tmp/review-343c2f8` was created for this review. A
  reviewer's Python left an ignored `scripts/__pycache__` in it; another
  removed the `rosetta/__pycache__` it had created. Everything else,
  including a frozen 457 MB copy of the HEAD Lean build, is in the session
  scratchpad.
- **Unchanged:**
  - tracked files;
  - `.tools/`;
  - the evidence directories;
  - `lean-evidence.json` and `lean-proof.log`, which are identical to the
    preserved Partial Output copies;
  - the Git refs and index.
- **Concurrent work.** The coding agent began For loops and integers in the
  shared checkout at 16:36 UTC, during the review: 26 commits on the local
  branch `feat/for-loops-integers` and several worktrees. The owner paused
  it at 18:11.
  - **Canonical Lean workspace:** the work changed 18 HEAD sources,
    including `Current.lean`, added 27 modules, edited the lakefile and
    built 10 new modules.
  - **HEAD artifacts:** these never changed. All 526 HEAD `.olean` and
    `.trace` files and 116 hash sidecars match the frozen copy byte for
    byte, and `lake env lean` loads artifacts without rebuilding. No Lean
    result in this review was affected.
  - **Mitigation:** the frozen copy was made at 18:25 and verified by byte
    comparison and by reproducing 20 smoke verdicts; verifiers used it.
  - **Recommendation:** concurrent feature work needs its own Lean
    workspace, as the reviewers recommend.
- **Process incidents.**
  - **Mistaken kill:** a reviewer misread truncated `ps` output and killed
    another reviewer's queued compile batch before it ran. It was restarted,
    and all six of its compiles completed.
  - **Untracked compiles:** a reviewer suspended its own runner to avoid a
    timeout. That orphaned a dense compile from the slot accounting, which
    placeholder jobs then restored.

  Verifiers worked under a rule to signal only processes they had started,
  and none of these incidents recurred.
- **Host.** Earlier records state 12 CPUs; this host now exposes 22, which
  sets GNATprove's `-j0` worker count (relevant to B1).
- This report is committed together with the session-memory entry that
  records the owner's decisions on it. Its findings are tracked as GitHub
  issues #17 to #34 (see the appendix).

## Appendix: commands and identifiers

```sh
# Remote, catalogue, compiler freshness
gh api repos/berkeleynerd/silver/branches/main --jq .commit.sha
.silver/linux-x86_64/compiler/bin/silver catalogue | cmp - catalogue/silver.json
sha256sum .silver/linux-x86_64/compiler/bin/silver        # b1ef9b58…, before and after each compile
# B1: dense construction, report size, credit rule, load experiment
silver check direct771p.adb; silver compile direct771p.adb   # 2,091,011–2,091,380 bytes over five runs
python3 -I tools/{analyze,leafcmp,credit,bound,bound2}.py <program dirs>
timeout 900 python3 -I exp/burn.py 22 840 & silver compile exp/small150.adb   # 33 and 36 multi-credited
# L1: effective prover limits
grep '<prover ' obj/gnatprove/main/why3session.xml; cat /proc/<prover pid>/limits
# L4, L5, I5, I6
python3 ra1.py 190000 (RLIMIT_STACK 8 MiB); objdump -d silver | grep -A8 '<silver__compile'; sigint_demo.py
# Differential and code generation (reviewers)
silver check <corpus>; lake env lean probe.lean (closure-limited, verified traces); gcc -c -gnat2022 -gnata -gnato -I src main.adb
# Evidence
python3 proof/generate_source_certificate.py --output <scratch> …   # 17/17 identical
python3 -c '…check_evidence.audit_reports(…)'                      # 3,172 / 3,235 / 3,273
```

Report identifiers and reviewer identifiers, for the evidence in the session
scratchpad:

| Report | Reviewer | Report | Reviewer | Report | Reviewer |
| --- | --- | --- | --- | --- | --- |
| B1 | LE-1 | L11 | PR-3 | I11 | RC-I1 |
| L1 | SA-1 | L12 | PR-4 | I12 | RC-I2 |
| L2 | LE-2 | L13 | PR-5 | I13 | RC-I4 |
| L3 | AE-1, SA-5 | L14 | PR-6 | I14 | RC-I5 |
| L4 | RA-1 | L15 | PR-8 | I15 | LE-6 |
| L5 | RA-2 | I1 | LE-3 | I16 | AE-4, RC-I3 |
| L6 | RC-L1 | I2 | SA-2 | I17 | AE-5 |
| L7 | RC-L2 | I3 | LE-4 | I18 | PR-7 |
| L8 | PR-1 | I4 | LE-5 | I19 to I26 | PR-9 to PR-14, PR-16, PR-17 |
| L9 | PR-15 | I5 | RA-3 | §6 | AE-3, RC-I6 |
| L10 | PR-2 | I6 | RA-4, PO-1 | | |
| | | I7 | PO-2 | | |
| | | I8 | SA-3 | | |
| | | I9 | SA-4 | | |
| | | I10 | AE-2 | | |

GitHub issues, each labelled `type: finding` with its severity and on the
board as Backlog:

| Finding | Issue |
| --- | --- |
| B1 | #17, in the For loops and integers milestone as its first work package |
| L1 to L15 | #18 to #32, in order |
| I1 to I26 | #33, one checklist |
| L8's scope question | #34, a `type: decision` issue in the milestone |
