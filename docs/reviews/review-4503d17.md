# Review of 4503d17, "Add predicates and path-sensitive composition"

Reviewed 2026-10-14 on the Linux x86-64 development sandbox (12 CPUs, 31 GiB,
no swap), the project's primary platform, read-only on tracked files, from the
checkout at `4503d17` (`main`, equal to `origin/main` on GitHub). Scope is
everything after the last review (`9b99d52`): five commits, 184 files,
+43,959/−12,056 lines:

- `138c751`, "Document sequencing costs and close focused review gaps", and
  `6ec8628`, "Close sequencing capacity follow-up": documentation and tests
  answering the previous review, including that review's report;
- `7fb1514`, "Track task decomposition in the roadmap";
- `dc5295e`, "Compose nested conditional statements" (roadmap 5a);
- `4503d17`, "Add predicates and path-sensitive composition" (roadmap 5b and
  5c): predicates, integer literals, path-sensitive assignment and output
  checks, and relaxed input-guard and `Reject` placement.

Hand-written Lean changed by +17,827/−1,110 lines (99 new modules, 38
modified, 2 retired, 1 renamed; 144 → 241 modules), generated certificates by
+21,748/−10,163, SPARK by +1,086/−244 (two new units), tests by +666/−49,
documentation by +1,466/−396 plus the 691-line previous review, and
catalogue, samples, scripts and the Lean build files by +475/−94. Scratch,
probes and agent notes are in the session scratchpad; nothing was written
under `tmp/` (§6).

## 0. Verdict

**One blocker. Since `4503d17`, Silver admits programs that it then cannot
build (B1).** An assignment whose static lengths differ is admitted when path
facts make its arm unreachable, as the specification says
(`language.md:157-158`, `:201`). GNATprove proves the program. Then GNAT,
because of the mandatory `pragma SPARK_Mode (On)`, turns its compile-time
length warning into an error whenever it cannot fold the arm's condition to
False, and `silver compile` exits 3 with "Compilation failure for admitted
Silver". A defensive arm such as
`elsif Input'Length > 4096 then Fixed := "toolong";` is enough. The failure
is safe (no binary is produced), but it breaks the Oracle's first guarantee
for a reproducible family of valid programs. The verifier recommends a
narrow, Oracle-permitted fix.

Nothing else rises above low. The reviewers raised one medium, on
missing sibling tests for two Ada-legality rules. Verification narrowed it
to low: every predicate position shares one checked code path, and the Lean
source checks bind it. The dense-capacity caveat that the delivery left open
is now closed. The 782-assignment specimen proves in this review, and its
report uses 96.0% of the 2 MiB buffer.

**What works.**

- **The handoff's validation claims are confirmed and bound to HEAD**, with
  two qualifications (§2):
  - the 293-method suite ran before 12 files reached their final contents;
  - "53,422 declarations checked" is the axiom audit's count from a warm
    replay, not a kernel re-check.

  The proof-reading part of the test gap is closed: the 140 tests that read
  proof or evidence files pass at HEAD.
- **Safety of path-sensitive checking holds.** `refine_sound`, the join rules
  and the invalid-input rules are proved universally, with standard axioms
  only.
  - About 6,100 admitted fuzz programs were executed by two independent
    execution oracles across lengths 0–4096 and invalid argument vectors.
    They were 2,723 of 21,000 generated in one fuzzer and about 3,400 in
    another. There was no output on invalid input, no unrejected invalid path,
    and no bound or length violation.
  - Compiled samples and custom programs behave as specified: `Reject`
    returns, failure status is sticky, and output failure gives status 1.
- **No language was lost.** All 19,642 sources from the previous reviews'
  corpora are still admitted.
  - The 662 newly admitted ones all satisfy an independent reference
    recognizer written from `language.md`.
  - Lean `Current.accepts` agrees with the compiler on every one of them, and
    on a new 16,009-source predicate, literal and path corpus (6,434
    admitted).
  - GNAT's frontend accepts all 7,096 admitted sources.
- **Integer literals match Ada.**
  - 11,888 spelling programs produced no admitted spelling that GNAT rejects.
  - The values of 822 spellings are pinned exactly by admission boundaries.
    GNAT `Compile_Time_Error` checks confirm the values of 1,489 admitted
    spellings, and six were confirmed at run time.
  - The Lean reader agrees on 3,002 spellings.
- **The previous reviews' M1 class does not recur.** Every premise of
  `Predicate.SourceBridge.executable_main_correct`, `executable_pipeline`,
  `current_executable_membership` and `actual_source_correspondence` is
  inhabited by a premise-free witness of the same definition.
  - The totalizations are confined to out-of-domain values, and probes show
    the interpretation pins every in-domain call to the model.
  - More than 40 top-level, witness and source-check theorems use only
    `propext`, `Classical.choice` and `Quot.sound`.
  - There are no escape hatches (`sorry`, `native_decide`, `implemented_by`
    and the like).
  - Every new SPARK subprogram has a source check binding the certificate
    text to its Lean model; three weaker bindings are listed in L10.
- **Report policy was widened only in its entity sets.** It still requires
  every check to be proved, with exact coverage and no justified or
  unproved check. The implementer's 76 recorded mutation checks cover each
  requirement, and real query-free reports compiled in this review are
  accepted.

**What needs attention**, in order:

1. **Fix B1** before treating 5c as complete. The recommended fix restores
   the 5a rule for static/static assignments regardless of reachability,
   keeping path refinement wherever a dynamic length is involved. Add native
   regression compiles, and add a full-code-generation pass (`gcc -c`, not
   `-gnatc`) to the differential and sample tooling.
2. **Record the 782-assignment result:**
   - 33.6 min and 6.1 GiB;
   - 826 checks proved;
   - a 2,013,253-byte report, 96.0% of the buffer.

   Replace "uncompiled" and the estimate in `language.md:236-238`,
   `README.md:107`, `docs/branches.md:311`, `:336` and `:466`,
   `docs/trusted-boundary.md:602`, and `roadmap.md:43` and `:221`. The dated
   entries in `docs/session-memory.md` can stay as history.
3. **Disclosure and accuracy fixes:**
   - the stack premise (L4);
   - restriction purposes (L3);
   - the "vacuous" wording (L2);
   - full-suite scope (L6);
   - stale counts and comments (L7, L8);
   - evidence links (L5);
   - `silver run`'s message for a specified `Reject` (L9).
4. **Tests and regression guards (L1, L10–L13).**

## 1. Method

- **Isolation.** No tracked file, nothing in `.tools/`,
  `.silver/linux-x86_64/proof`, the evidence directories or `tmp/` was
  modified by this review. §6 lists the side effects.
- **What I ran myself:**
  - recomputed the Lean inputs digest and compared the workspace with
    `proof/`;
  - hashed every Lake trace's source input and every artifact with Lake's own
    hash functions;
  - checked the GNATprove input hashes and the retained summary;
  - ran `git ls-remote` against GitHub and compared `silver catalogue` with
    the tracked catalogue;
  - ran the 140 tests that read proof or evidence files at HEAD;
  - reconstructed which inputs each test run used;
  - compiled the 782-assignment specimen to completion (owner-approved,
    2-hour cap);
  - reproduced B1 twice;
  - checked every documentation low against the tree.
- **Multi-agent review.** Nine read-only reviewers, all on Opus 5.5, each with
  one lens:
  - Lean trust and top-level theorems;
  - Lean predicate and path semantics;
  - actual-source correspondence;
  - integer literals;
  - the SPARK recognizer;
  - a differential recognizer probe;
  - runtime and capacity probes;
  - reports and tests;
  - documentation, claims and dispositions.

  They raised 44 findings (1 blocker, 1 medium, 24 low, 18 info), with many
  duplicates across lenses. Three independent verifiers re-derived 17 of them
  in three groups: the blocker, Lean correspondence and tests. Each verifier
  was told to refute and to reproduce rather than trust the finder's evidence.
  Result: 11 upheld, 6 narrowed (including the medium, now low), none
  refuted. I checked the documentation, runtime and info items myself.
- **Owner's no-routine-rerun rule.** Every agent was bound by it: no Lean
  build, `check_lean.py`, `dev.py prove`, full suite or replay. Agents ran
  only targeted probes:
  - `silver check`/`compile`/`run`;
  - GNAT `-gnatc` and `gcc -c`;
  - read-only Lean probe files;
  - single test methods.

  Compiles and Lean probes went through a shared three-slot runner, so they
  could not exhaust memory alongside the background compile.
- **Cost.** About 1.23M output tokens: reviewers 0.87M, verifiers 0.19M, lead
  0.18M. About 237M cache reads. About 75 minutes of agent wall-clock
  time, plus the 34-minute background compile.

## 2. Native validation (Linux x86-64)

| Check | Result |
| --- | --- |
| Implementer's handoff claims | **"Pushed as 4503d17a93; remote main matches":** `origin/main` on GitHub is `4503d17` (`git ls-remote` over HTTPS). **"3,049 SPARK checks proved":** confirmed from the retained `gnatprove.out` (549 flow + 2,500 prover, 0 justified, 0 unproved; 19 units). **"241 Lean modules, 53,422 declarations checked":** confirmed and bound to HEAD (below); 53,422 is the axiom audit's declaration count, not a kernel replay. **"293-test run completed; three stale assertions repaired, then 52/52 affected tests passed":** accurate, with the qualification below. **"Oracle unchanged":** `oracle.md` is byte-identical to `9b99d52`. **"Tracked tree clean":** only `tmp/` is untracked. **"Checked-in memory updated":** yes (`docs/session-memory.md`). |
| GNATprove evidence binding | All **2,406** recorded input hashes in `proof-provenance.json` match HEAD, both in the compiler object directory and in the retained copy in `native-variant-final/`. The two `gnatprove.out` files are byte-identical. The installed compiler (`602133…`) is the binary that audit recorded. |
| Lean evidence binding | `lean-evidence.json`'s inputs digest `2d5ebc00…` **recomputes over the 266 inputs at HEAD**. The canonical workspace is byte-identical to `proof/`, including the 15 regenerated certificates, and its 241 modules are exactly the 241 source modules. I hashed every canonical Lake trace: all **241** source-input hashes equal the HEAD sources, and all **968** output hashes equal the artifact bytes. The final run was incremental (build 8.5 s, audit 3.3 s) and elaborated only four modules (I5). Of the 241 artifacts, 86 were built in the canonical workspace and 155 were promoted from other workspaces: 74 from the certificates lane, 56 from a module-migration workspace built on 2026-10-12 whose sources are unchanged since, 15 from the grammar lane, 9 from the bridge lane and 1 from an earlier sequencing workspace. Two orphan traces (`PredicateProbe`, `SequenceProbe`) remain for modules not in the tree. |
| Full test record | The only full-suite run (293 methods, 02:33–02:51 UTC, exit status 1) used inputs that differ from HEAD in 12 files: two SPARK units (later edits only add parentheses inside variant, invariant and termination expressions), eight proof files and the two repaired test files. The 52-method focused rerun preceded two later proof edits: `ComposeSourceChecks.lean`, and `PredicateSourceBridge.lean`, which gained an import. I re-ran the 140 tests that read proof or evidence files (`test_lean_source`, `test_lean_modules`, `test_lean_evidence`, `test_evidence`, `test_proof_provenance`, `test_platforms`, `test_argument_bounds`) at HEAD: **140/140 OK** in 2m53s. A reviewer also ran 26 check-only admission methods and 5 native methods at HEAD; all passed. |
| Dense assignment (782 specimen) | The implementer's uncompiled `argument_single_reject.adb` (782 × `X:=D;` then `Reject`, 4,095 B), run by the lead with a 2-hour cap: **exit 0 after 2,014.5 s; peak 6.1 GiB; 826 checks proved**, including 782 length checks, plus 783 unused-assignment advisories. The report is **2,013,253 B (96.0%)**, a margin of 83,899 B (4.0%); the projection was 0.2% high. The executable exits 1 with no output for no argument, `hello`, `""` and two arguments. The run overlapped the reviewers' probes, so its time is not a clean measurement. |
| Catalogue | `silver catalogue` equals `catalogue/silver.json` as JSON: 27 constructs, 3 compositions. |
| Oracle | `oracle.md` unchanged since `9b99d52`; `AGENTS.md` gained four lines in `7fb1514`. |

## 3. Findings

### 3.1 Blocker

1. **B1: admitted programs with a wrong-length static assignment in a
   path-unreachable arm fail the GNAT build.** (Verifier: upheld, blocker.)

   - **Mechanism.** When a condition cannot hold, `Keep_If` and `Intersect`
     return `Empty_Context` (`src/silver_path_facts.ads:36`, `:49-50`). In
     that context `Same_Length` is vacuously true (`:119-123`), and it is the
     only assignment length gate (`src/silver_output_profile.adb:1147-1151`).
     The specification says the same:
     - "If no path reaches an expression, its evaluation bound is vacuous"
       (`language.md:157-158`);
     - assignment "requires equal lengths on every reachable input" (`:201`).

     The catalogue's `string_assignment` text agrees. GNAT, however, knows both
     static lengths at compile time. With `pragma SPARK_Mode (On)` it reports
     the mismatch as "error: wrong length for array …" and "error:
     Constraint_Error would have been raised at run time" whenever it expands
     the arm, that is, whenever its frontend does not fold the condition to
     False.
   - **Reproduction (lead).** Both programs print `Accepted: silver.` and
     `Success: all checks proved` (45 and 47 checks). The build then fails, and
     `silver compile` exits 3 with "Compilation failure for admitted Silver:
     toolchain or implementation defect."

     ```ada
     --  argument shell (r2_arg_dead)
     Input : constant String := Silver_Arguments.First_Or_Default ("old");
     Fixed : String := "abc";
     begin
        if not Silver_Arguments.Input_Is_Valid then
           Silver_Arguments.Reject;
        elsif Input'Length > 4096 then
           Fixed := "toolong";
        end if;

     --  static shell (t2)
     D : String := "abc";
     B : String := "12" & D;
     begin
        if B = B & D and then B'Length > 3 then
           D := "x";
        end if;
        Silver_IO.Put_Line (B);
     ```
   - **Not an invocation artifact.** Plain `gcc -c` fails with any switches.
     `-gnatp`, `pragma Suppress (All_Checks)` and `-gnatws` do not help.
     Without the pragma the same diagnostic is only a warning ("will be raised
     at run time", exit status 0). It is not a SPARK legality rule: GNATprove
     proves the length check at the failing line. The GNAT 16.1 manuals
     document only the warning form.
   - **Scope.** The verifier's matrix has 70 sources, and native and Lean
     agree on all of them. Of the 62 admitted, 32 fail the build and 30 build.
     Every failure has the same shape: a target whose length GNAT knows,
     assigned a static right-hand side of a different length. That right-hand
     side can be a literal, a static concatenation, a static or snapshot name,
     or an empty String.
     - **Unreachable arms that fail:** length-interval contradictions,
       invalid-input exclusion, String equalities between operands of
       impossible lengths, and `and then`/`or else`/`not`/`elsif`
       combinations of these.
     - **Arms that build:** those whose condition GNAT folds (static-object
       `'Length` comparisons, `Input'Length < 0`, simple equalities between
       operands of different static lengths), and any mismatch involving a
       dynamic length.
     - **Corpus:** the differential's full-codegen pass found 34 failures in
       7,096 admitted corpus sources, all of this class. `-gnatc` sampling
       cannot detect it, because the check happens during expansion.
     - **In the tree:** no tracked sample, test or documentation example
       contains the shape.
     - **Naturalness:** it is plausible in defensive capacity arms
       (`elsif Input'Length > 4096 then Status := "too long"; Reject;`) and in
       equality cascades.
   - **Introduced by `4503d17`.** At `dc5295e`, `Assignment_At` rejected any
     static-length or dynamic-count mismatch unconditionally, and
     `language.md` said branch-refined equality was not used for admission.
   - **Lean.** `ToolContract.buildCompletes` (`proof/Silver/Current.lean:219`)
     is an explicit premise, so `automatic_pipeline` is not fake. The pinned
     toolchain falsifies that premise for these sources, so no theorem covers
     their real build. Safety (`admitted_assurance`) is unaffected: the arm
     never executes.
   - **Governing rule.** The Oracle says valid Silver can never be rejected,
     and a build failure of admitted source is an implementation defect
     (`language.md:244`, `:469-471`). The failure is fail-safe (no binary,
     explicit defect message), which limits the harm but not the class.
   - **Recommendation.** Restore the 5a rule for static/static pairs: a
     target with a static length and a right-hand side with no dynamic
     occurrence must have equal lengths regardless of reachability. Keep path
     refinement whenever either side is dynamic.
     - **Consistency:** this matches how static lengths are already bounded.
       A 4,800-byte static output in an unreachable arm is rejected (L2).
     - **Oracle:** before 1.0, `oracle.md:18` permits such an explicit change
       if specification, catalogue, compiler, Lean and samples change
       together.
     - **Cost:** some admitted programs that build today become rejected. An
       example is `if Mode = "verbose" then Mode := "verbose";` with a
       five-byte `Mode`.
     - **Rejected alternatives:**
       - A build-only `pragma Ignore_Pragma (SPARK_Mode)` through `-gnatec`
         works in scratch. It splits the build and proof configurations and
         adds a trusted GNAT behaviour.
       - Rejecting statically unreachable arms is far broader.
     - **With either fix:** add native regression compiles (`r2_arg_dead`,
       `t2`, the defensive-cap and `too many elements` variants). Add a
       full-codegen pass to the differential and sample tooling. Until it is
       fixed, record the family in `docs/branches.md`.

### 3.2 Low

1. **L1: test gaps for the new admission rules and runtime paths.** Each
   gap was confirmed; the compiler behaves correctly in every case.
   1. **Literal-only String relations.** There are no rejected siblings for
      `/=`, `elsif`, `and then`, `or else`, `not (…)` or nested positions; the
      only cases are `=` in an `if` (`tests/test_common_expressions.py:111-114`).
      This was the reviewers' medium. It is narrowed because all positions
      share one check (`src/silver_output_profile.adb:1030`), which the Lean
      source checks bind.
   2. **`Reject` in the static shell.** No case shows it rejected there.
   3. **Missing minimal pairs:**
      - no admitted exponent-separator case (`A'Length<=1E0_0`);
      - no validity pair through `or else`;
      - no rejected case for the zero-length-on-invalid-input assignment rule.
   4. **Statements after `Reject`.** No compiled test continues an invalid
      path after `Reject`. "Reject returns" is exercised only on valid input,
      although an independent compile showed correct behaviour.
   5. **Query-free policy alternatives.** Three of them have no native
      compile test: `Argument_Effects_Without_Query`,
      `Selected_Without_Query` and `Selected_Effects_Without_Query`. They are
      covered on synthetic reports (`tests/test_library_reports.py:688-711`),
      not against GNATprove's real report shape.
   6. **Glued literals.** No based, colon or exponent literal glued to a
      following word is tested (`16#F#then`, `1E3then`). The decimal cases do
      exercise the same single check.
2. **L2: "vacuous" overstates.** `language.md:157-158` says an unreachable
   expression's evaluation bound is vacuous. In fact a static expression
   longer than 4,096 bytes is rejected even in an unreachable arm: a
   `Put_Line` of sixteen 300-byte constants under `elsif Input'Length > 4096`
   is rejected, and with 250-byte constants it is admitted. Native and Lean
   agree. State that static lengths must always fit and that only the
   reachability-dependent bound is vacuous. The B1 fix belongs next to this
   sentence.
3. **L3: new exclusions have no stated purpose.** This recurs the previous
   review's L8. The Oracle requires one for each of:
   - literal values above 4096 (`language.md:298`);
   - a literal on the left of a `'Length` comparison, arithmetic, and other
     attributes, described only as "excluded from this bounded predicate
     fragment" (`:266-268`);
   - Boolean literals (`:270`);
   - unary signs (`:310`).

   The exponent bound, eager operators, disjoint length sets and byte-equality
   tracking do have purposes. Add one reason per exclusion, with matching
   catalogue fields.
4. **L4: the stack premise omits the recursive recognizer.** `README.md:155-160`
   and `docs/trusted-boundary.md:61-69` justify the 8 MiB stack only by the
   report buffer used by `compile`/`run`. Since 5a, however, admission itself
   recurses, with one frame chain per statement and per condition parenthesis,
   built at `-O0` with assertions.
   - **`silver check`:** the deepest admitted 4,096-byte shapes need about
     3.6 MiB (1,994 condition parentheses: 3,688 KiB; 797 `not` levels:
     1,520 KiB).
   - **`silver compile`:** the deepest parse raises `Storage_Error` at 5,632
     KiB and passes at 6,144 KiB, so 8 MiB leaves about 2 MiB of margin.
   - **Below the threshold** the exit status is 1 with `STORAGE_ERROR`, never
     a false "Rejected". No admitted shape exceeded 8 MiB.
   - **Fix:** record these figures and the recursion next to the premise.
     Optionally compute the argument/assignment modes before the 2 MiB buffer
     is allocated, to restore margin.
5. **L5: tracked documents link to ignored evidence.** `docs/branches.md` has
   nine Markdown links into `.silver/linux-x86_64/branches-20261013T234331Z/`
   (`:308-333`, `:393-394`). `.gitignore` excludes `.silver/`, so all nine
   are broken in a clean clone and on GitHub. Use code-formatted host paths
   that are labelled local-only, as `docs/statement-sequencing.md` does, or
   commit the small specimens and JSON summaries. The previous review's L10
   (machine paths) was the same class.
6. **L6: full-suite scope is understated.** `docs/branches.md:367-368` says
   the 293-method suite ran "against stable source/script/test/proof inputs".
   The completed checkpoint (`:445-452`), `RESUME.md:14-17` and the handoff
   say every other case passed. None of them says the run exited 1, or that
   the run preceded the final grouping of two SPARK units and eight proof
   files. Apart from the 52 rerun methods, the suite never ran against the
   published sources, including every predicate, path and sample test. The
   risk is low, since the later source edits only add parentheses, and the
   proof-reading tests now pass at HEAD (§2). Add one sentence listing the 12
   files.
7. **L7: stale counts.** `docs/assurance.md:299-300` still says "Twelve
   handwritten source-binding modules", and `docs/trusted-boundary.md:745`
   says "Twelve generated source-certificate modules". There are fifteen of
   each, and the same document says "fifteen" at `:779` and `:793`. Name the
   integer-literal and path-fact bindings.
8. **L8: other stale or imprecise text.**
   - **Interim wording:** the "Coupled 5b/c integration" section of
     `docs/branches.md` still says "The final native audit and
     source-certificate run are in progress … remain pending" (`:293-295`).
   - **`docs/statement-sequencing.md:3-16`** still presents its one-level,
     fixed-guard scope as "complete and supported", with no pointer to the
     superseding record. It also names the retired `SequenceSourceBridge` and
     `SequenceCorrespondence` modules.
   - **Stale guard wording:** `src/silver_arguments.ads:7-8` ("the caller's
     required validity guard and Reject branch") and `README.md:53-55`
     ("required validity guard") predate 5c. Changing the `.ads` comment
     regenerates a runtime certificate.
   - **`src/silver_library_reports.ads:35-44`** says "Source membership
     selects the exact Main/callee entity set". In fact the policy accepts any
     of five entity sets for the argument and selected kinds
     (`silver_library_reports.adb:1388-1400`). `docs/trusted-boundary.md`
     and `docs/assurance.md` describe this correctly.
   - **Solver-completion fragment:** `docs/trusted-boundary.md:43` and
     `docs/assurance.md:406` still describe it as "the concrete bounded
     range/length fragment". For path schemas it is now every schema that
     Lean's endpoint discharge accepts (I3).
   - **`docs/branches.md:295-297`** says source-independent sequence
     mathematics "remains audited and reused". Seventeen of those modules are
     audited but reused by nothing (I1).
9. **L9: `silver run` misreports a specified `Reject`.** It executes the
   program without arguments and maps any nonzero status to "Execution
   failed: output failure or an external runtime/process failure." with
   driver status 3 (`src/silver.adb:216-220`). 5c admits programs that reject
   their default input by their own logic, so a specified, proved outcome is
   reported as an external failure. Report the status neutrally, or document
   the mapping.
10. **L10: Lean regression guards.** Every link below holds at HEAD; each is
    simply not stated as a checked binding, so a future change could drift
    unnoticed.
    1. **Word-token lists.** Ada `Is_Word_Token` is pinned only to a
       hand-written token string (`catalogue_fact_05`). Lean `isWord` is
       pinned only to a separate hand-written list in `finite_mapping`, which
       no `CheckedSource` includes. No theorem relates the two, although they
       are equal today. The same holds for `Compose.Expressions.allTokens`
       versus `Compose.SourceBridge.allTokens`.
    2. **Integer-literal bytes.** The certificates prove
       `Source.lex Source.integerLiteral{Spec,Body} = some …`, but neither
       `IntegerLiteral.SourceBridge.CheckedSource` nor the composed predicate
       bridge conjoins it. These are the only authoritative files whose byte
       binding no composed statement includes.
    3. **Precedence.** `PathFacts.Native` trees have no precedence check, so
       the token pins alone do not exclude a mis-nested tree that renders
       identically. A reviewer's Ada-precedence check passes on all 22 bodies.
       The predicate-native `checked_precedence` and `checked_scopes` are
       proved but not conjoined.

    Make each one a field of the corresponding `CheckedSource`.
11. **L11: retention is tested, not proved; the samples have no Lean
    witnesses.** No theorem relates `Sequence.Member` (the `9b99d52`
    language) to `Predicate.Member`; the corpus evidence above is what
    supports retention. The kernel witnesses cover `not`, `and then` and
    nesting, but not `elsif`, `or else`, based literals or the two new
    samples. Both samples are kernel-provable `Current` members, at about 5.3
    minutes of kernel time. This recurs the previous review's L14. Either
    commit the witnesses or state that retention is a tested property, and
    keep a 5a-grammar differential in the suite.
12. **L12: the catalogue's new structural token fields are unchecked.**
    `choice_statement_tokens`, `and_then_tokens` and the eight others are
    hand-written strings (`src/silver_catalogue.adb:757-767`). Only their
    word set is tested. They show two-operand chains where chains of any
    length are admitted, and they use undefined placeholders such as
    `<relation>`, `<primary>` and `<elsif_arms>`. This convention predates
    5b. Either define the placeholders and test the fields against the
    grammar, or declare them informative only.
13. **L13: manifest capability tags are still inconsistent and unvalidated.**
    This is carried over from the `9b72d36` review's L10, with no recorded
    disposition.
    - `input_branching`, `command_line_greeting` and `statement_sequence` use
      `Input_Is_Valid` but lack `input_guard`.
    - Four samples use `'Length <= N` in `and then` chains without the
      `length_predicate`, `boolean_predicate` and `integer_literal` tags.
    - Every conditional sample except `path_guards` lacks
      `boolean_predicate`.

    `test_samples.py` checks only that tags are catalogue ids. Derive or
    verify the predicate tags from source features.

### 3.3 Info

1. **I1: seventeen retired `Sequence*` modules are still audited.**
   `SequenceNative*`, `SequenceModel`, `SequenceMain`, `SequenceSelectors`
   and others are imported only through `proof/Silver.lean`. They feed no
   current theorem, and several model the deleted 5a scanner. They count
   toward the 241 modules and 53,422 declarations, but assert nothing about
   current Ada. Twenty-one older non-Sequence modules follow the same
   pattern. Mark them historical or move them out of the audited root.
2. **I2: the top-level theorem changed shape.** Compared with `9b99d52`,
   `executable_main_correct` no longer states `MainReading` or the
   all-environment `SpecifiedOutcome`. It gains meaning uniqueness and
   `invalid_run`. `SpecifiedOutcome` remains available through
   `Current.every_meaning_assured`. No guarantee relevant to the current
   compiler is lost.
3. **I3: the path-schema fragment is now semantic.**
   `Predicate.Check.InFragment (.path c)` is `c.discharge = true`, so
   `ToolContract.boundedProofCompletes` assumes solver completion on every
   path schema that Lean discharges, rather than on a fixed structural family.
   `automaticDischarge` still evaluates only the uniform obligations;
   `assurance.md:394-398` discloses this. The wording point is L8.
4. **I4: callee routing is not uniform.** Calls to `Paths.Join`,
   `Expand_Body (…).State`, `Take_Token`, `Paths.Initial` and
   `Paths.Completed` are interpreted by fixed Lean functions rather than
   `Links` premises. Each callee's Ada body is source-checked, and separate
   theorems equate it to that function. No correspondence is missing.
5. **I5: the final Lean run elaborated four modules.** They were
   `PredicateSourceBridge`, `PredicateCorrespondence`, `Silver` and
   `Silver.Audit`. The other 237 were reused, 155 of them from other
   workspaces, consistently with Lake's rules (§2). The trust model is stated
   (`README.md:394-395`, `trusted-boundary.md:765-773`,
   `assurance.md:626-628`). `docs/branches.md` could name the per-workspace
   counts, and handoffs should say "audited" rather than "checked" for the
   declaration count.
6. **I6: the SPARK statement reader lost its ghost refinement.**
   `Read_Statements` was a loop with a `Static` postcondition equating it to
   an independent ghost model. It is now executable recursion with
   `Post => Valid_State`. The Lean source equations now carry that
   correspondence. No other contract was weakened, and there is no new
   `Assume`, `Annotate`, `SPARK_Mode (Off)` or assertion-policy change.
7. **I7: dead legacy scanner code.** `Capacity_Literal`, `Capacity_At`,
   `Read_Capacity`, `Comparison_At` and the canonical-decimal `Decimal_At`
   are unreachable from the active token forms
   (`src/silver_output_profile.adb:69-81`, `:749-804`). They are still proved
   and modelled, and `Decimal_At`'s grammar differs from `integer_literal`.
8. **I8: performance.**
   - Recognition time is quadratic in nested condition parentheses, about
     1–2 s at the source bound.
   - Interpreting Lean `Current.accepts` takes 113 s on 1,994 nested
     parentheses (about n^2.4); the compiler takes 1.5 s for all 88 deep
     cases.
   - Neither affects a guarantee.
9. **I9: density.**
   - Plain 5-byte assignments remain the densest shape, at about 512 report
     bytes per source byte.
   - Assignments in refined arms are equal.
   - Equality conditionals reach about 23% of the buffer at their maximum,
     length conditionals about 18%, and `Put_Line (D)` about 12.5%.
   - The 782 result (§2) closes the delivery's capacity caveat.
10. **I10:** the pre-existing broken anchor
    `RESUME.md#recover-and-preserve-the-old-vm-evidence` (three references)
    is still unaddressed.

### 3.4 Unverified observations (lead-assessed)

- The differential reviewer reported that one of the 662 newly admitted
  baseline sources (`others_008960_…`) also fails full code generation. It
  fits the B1 class; I did not re-run it.
- The verifier observed that GNAT's folding is irregular even in static
  shells. `B = B & D` alone builds, but `B = B & D and then D'Length > 0`
  fails. That is why the recommended fix does not try to model GNAT's
  folding.

## 4. Probes and experiments

| Probe | Result |
| --- | --- |
| Lean evidence binding (lead) | Inputs digest recomputed; workspace byte-identical to `proof/`; 241/241 trace source hashes and 968/968 output hashes match (Lake's hash functions, no build). |
| Proof-reading tests at HEAD (lead) | 140/140 OK in 2m53s. |
| Dense assignment, 782 specimen (lead) | Proved and built: 2,014.5 s, 6.1 GiB peak, 826 checks, report 2,013,253 B (96.0%). Executable rejects every input with no output (§2). |
| B1 reproduction (lead) | `r2_arg_dead` and `t2`: admitted, all checks proved (45/47), build error, exit status 3, about 6 s each. |
| B1 scope (verifier) | 70 sources; native and Lean agree on all. 62 admitted: 32 fail the build, 30 build. Switch probes: `-gnatp`, `Suppress`, `-gnatws` do not help; a build-only `Ignore_Pragma (SPARK_Mode)` builds and runs correctly in scratch. Defensive-cap shape `n1b`: exit status 3. |
| Differential, baseline (19,642 sources) | 0 previously admitted sources rejected. 662 newly admitted, all accepted by an independent `language.md` reference recognizer. Lean = native on all (big 129 s, seq 357 s). |
| Differential, new corpus (16,009 sources) | Random, path-bound, mutant (32 operators), exact-value literal, grouping, edge and source-bound-depth programs. Native, Lean and the reference agree on every source (6,434 admitted). |
| GNAT legality | `-gnatc`: 7,096/7,096 admitted sources accepted, plus 1,200 and 437 fuzz-admitted programs and about 110 targeted probes. Full `gcc -c` with Silver's switches: 7,062/7,096 (the 34 failures are B1). |
| Integer literals | 2,972 spellings × 4 contexts: 0 admitted-but-illegal. 822/822 values pinned by admission boundaries. Runtime values for 6 spellings at boundary lengths. Lean reader 3,002/3,002. Source-limit numerals (3,780 digits) and `0E4096` proved and built. GNAT accepts exponents that Silver rejects (`0E4097`) and times out at `0E549999`. |
| Path semantics fuzz | 21,000 random programs (2,723 admitted); each admitted program run by an independent Python Ada-semantics interpreter on 27 argument vectors: 0 violations. A second fuzzer checked about 3,400 admitted programs against a length-only execution oracle with dense length sampling: 0 unsound. |
| Runtime | `path_guards` (11 manifest cases plus 2047/2048/4096/4097 bytes, `\x7f`, tab, non-ASCII, 3 arguments, `/dev/full`, closed stdout) and `conditional_statements` (7 cases plus 4096/4097 bytes): all as specified. Custom programs with dead predicates, `Reject` followed by statements, `or else` with based literals, and a query-free selected program: proved and correct. |
| Invalid-input admission | Admitted: guards `> 0`, `/= 0`, `< 1` with else, String equality with a nonempty literal, `not (not V or else …)`. Rejected: `>= 0`, `= 0`, `= ""`, output after a single-arm `Reject` join, output in an invalid-only arm, output after `Reject`, missing `Reject`. |
| Stack (L4) | Minimum `check` stack for the deepest 4,096-byte shapes: condition parentheses 3,688 KiB, argument parentheses 3,597 KiB, `not` 1,520 KiB, nested `if` 294 KiB, `elsif` 168 KiB, expression parentheses 124 KiB (a loop). `compile` on the deepest parse: `Storage_Error` at 5,632 KiB, passes at 6,144 KiB. |
| Lean probes | Premise-free `executable_pipeline`, `executable_main_correct` and `actual_source_correspondence` instantiations; `#print axioms` on more than 40 theorems (standard three only); `basic_pinned`/`read_pinned` totalization probes; `refine_sound` boundary evaluations; kernel `Current` witnesses for both new samples (319 s); an Ada-precedence check of 22 path bodies; `Is_Word_Token` list equality at HEAD. |
| Report policy | Reconstructed `Report_Policy`; 76 retained mutations rejected; real query-free reports (`Reject` only, selected without query) accepted under the matching kinds. |

## 5. Carry-over from the previous review (`9b99d52`)

The recorded dispositions are in `docs/statement-sequencing.md` ("External
review and capacity follow-up"), `roadmap.md` and `docs/session-memory.md`.
Commit `138c751` carries the reviewer's draft, and `6ec8628` the final text.
A reviewer confirmed both are byte-identical to the reviewer's copies, so the
committed review is unaltered.

| Item | Status at `4503d17` |
| --- | --- |
| M1 (dense-assignment disclosure) | **Fixed** (`README.md:102-110`, `language.md:228-245`). It was superseded by the 782-specimen caveat, which this review's compile closes (§2). |
| L1 (report policy / `Uses_Output`) | Sentences fixed. `Uses_Output` is still unused (deferred, recorded). |
| L2 (2 MiB stack) | Documented. `Storage_Error` → status 3 is deferred (recorded). The recursive recognizer is a new dependence (L4). |
| L3 (M2 siblings) | Siblings (a)–(f) were added and adapted at HEAD. Negatives are still reason-blind (deferred). New gaps: L1. |
| L4 (sample/failure coverage) | **Fixed.** |
| L5 (anchors) | Six fixed. The pre-existing `RESUME.md` anchor remains (I10). |
| L6 (roadmap status) | **Fixed.** |
| L7 (stale text) | **Fixed.** New stale text: L8. |
| L8 (restriction purposes) | Moot for the removed fixed guard and mandatory `else`; recurs for the new exclusions (L3). |
| L9 (operator-budget comment) | **Fixed** (`silver_output_profile.ads:8-9`). `docs/statement-sequencing.md`'s dated note still says "deferred". |
| L10 (absolute path) | Fixed in `docs/statement-sequencing.md`. The same class recurs as evidence links (L5). |
| L11 (validation-record extent) | Qualified for sequencing; recurs for 5b/5c (L6). |
| L12 (`Form_Result` inlining) | Documented (`assurance.md:327-330`). |
| L13 ("independent typed grammar") | Documented (`assurance.md:61-66`). |
| L14 (example-only witnesses) | Deferred with a record; recurs (L11). |
| I1 (`Tokens` pin) | **Fixed** (`PredicateSourceRequirements.lean:50`). |
| I2–I6 | Not re-assessed. |
| Older carry-overs (§5 of that review) | Unchanged under the generic deferral (`roadmap.md:55-58`). The manifest tags are still inconsistent (L13). |

## 6. Side effects and state

- **New.** About 60 `.silver/linux-x86_64/program-*` directories appeared
  during the review. Nearly all are from this review's probe compiles,
  including `program-a90pEV` (the 782 specimen) and two from the lead's B1
  reproduction. `program-qOXk6l` belongs to the greeting example below.
  Scratch is in the session scratchpad only.
- **Not this review's.** `tmp/greeting-example-9rp5sciv/` appeared at 11:34
  UTC. No command or agent of this review references it, and the reviewers
  started at 11:41, so it most likely came from another session on this host.
- **Unchanged:**
  - tracked files;
  - `.tools/`;
  - `.silver/linux-x86_64/proof` (no file newer than the review start);
  - the evidence directories;
  - `lean-evidence.json`;
  - the Git refs and index.
- This report is untracked and uncommitted.

## Appendix: commands

```sh
# Lean evidence binding (no build)
python3 -c 'from scripts import check_lean as cl; ...capture_shared_inputs()...'   # digest 2d5ebc00…
lean --run hash.lean    $(git ls-files 'proof/*.lean' | grep -v lakefile)          # Lake.computeTextFileHash
lean --run binhash.lean $(find .silver/linux-x86_64/proof/.lake/build/lib/lean -name '*.olean*' -o -name '*.ilean')
# GNATprove provenance and summary
python3 - < compare inputs_sha256 of proof-provenance.json with HEAD files
sed -n '/Summary of SPARK analysis/,/^Total/p' .silver/linux-x86_64/compiler/obj/gnatprove/gnatprove.out
# Remote and catalogue
git ls-remote https://github.com/berkeleynerd/silver.git refs/heads/main
.silver/linux-x86_64/compiler/bin/silver catalogue   # compared as JSON
# Proof/evidence-reading tests at HEAD
python3 -m unittest tests.test_lean_source tests.test_lean_modules tests.test_lean_evidence \
  tests.test_evidence tests.test_proof_provenance tests.test_platforms tests.test_argument_bounds
# Dense assignment (2 h and 20 GiB caps, process-group RSS sampled each second)
silver compile capacity-bounded-review/argument_single_reject.adb   # 782 assignments
# B1
silver check r2_arg_dead.adb t2.adb; silver compile r2_arg_dead.adb; silver compile t2.adb
```
