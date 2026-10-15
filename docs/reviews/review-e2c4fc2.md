# Review of e2c4fc2, "Narrow Lean source-check dependencies"

Reviewed 2026-10-14 on the Linux x86-64 development sandbox (12 CPUs, 31 GiB,
no swap), the project's primary platform, read-only on tracked files, from the
checkout at `e2c4fc2` (`main`, equal to `origin/main` on GitHub). Scope is
everything after the last review (`4503d17`): three commits, 103 files,
+17,482/−9,862 lines:

- `04171a6`, "Reject unreachable static length mismatches": the repair of
  the previous review, [review-4503d17](review-4503d17.md), which it also
  checks in. It is reviewed here as carry-over (§5);
- `8e5ffeb`, "Support context visibility and named calls" (Names and Calls,
  roadmap items 2, 6 and 7): reordered, grouped and repeated context clauses;
  context `use` clauses with local-name hiding; and `Item =>` and
  `Default =>` named actuals;
- `e2c4fc2`, "Narrow Lean source-check dependencies" (Focused Source
  Checks): six import-only Lean edits.

Hand-written Lean changed by +1,779/−169 lines (11 new modules, 61
modified; 241 → 252 modules), generated certificates by +13,367/−9,510 (two
new, three regenerated), SPARK by +328/−36 (one new unit, `Silver_Names`),
tests by +264/−13, documentation by +996/−117 plus the 624-line previous
review, and catalogue, samples and scripts by +124/−17. Scratch, probes and
agent notes are in the session scratchpad; nothing was written under `tmp/`
(§6).

## 0. Verdict

There are **two blockers**. Both are admitted programs that fail
fail-safe: `silver compile` stops with exit 3 and no binary is produced.
Neither is specific to Names and Calls. Nothing else rises above low.

1. **B1: the B1 repair is incomplete.** `04171a6` requires equal lengths
   on unreachable paths only when both sides are static.
   - **Failing case:** the target's length is static and the value has a
     dynamic part whose static part is already longer. For example:

     ```ada
     elsif Input'Length > 4096 then Fixed := "abcd" & Input;
     ```

     GNAT then rejects the build whenever it cannot simplify the arm away.
   - **Origin:** `4503d17`. The repair implemented exactly what the
     previous review recommended, and that recommendation rested on a wrong
     claim in its own B1 analysis: that mismatches involving a dynamic length
     build.
2. **B2: GNAT's brackets notation rejects `"["then`.** An admitted
   String relation can end in a literal whose last character is `[`,
   followed directly by `then`, `and then` or `or else`. GNAT always reads
   `[` + `"` + a letter, digit or `_` inside a string literal as the start of
   a wide-character encoding, and rejects the source.
   - **Origin:** admitted since `1ed039e` (2026-10-10). It escaped every
     review since then, including the previous one.

Names and Calls itself is sound. Its context grammar, use-visibility and
hiding match Ada at every position where an operation name can occur. On
44,018 new programs, the compiler, Lean and an independent reference
recognizer agree on every one. All admitted programs compile with GNAT except
for the two blocker classes, and they keep their meaning when re-spelled.
Focused Source Checks changes imports only and keeps the whole module set.

**What works:**

- **Names and Calls fidelity.** The admitted spellings and Ada agree:
  - the context grammar matches RM 10.1.2/10.1.6;
  - hiding matches RM 8.2, 8.3 and 8.4, including the subtle position rule
    that a later object named `First_Or_Default` does not hide an earlier
    initializer;
  - named actuals match RM 6.4.1.

  Evidence: 139 hand-written GNAT probes with full code generation, plus
  4,500 random programs.
  - Every admitted spelling builds.
  - Every rejected one is either illegal Ada or a documented exclusion.
  - 22 compiles all proved, built and ran correctly, including
    `samples/names_calls.adb`, a 4,087-byte program with 267 redundant
    `with` clauses, and hidden-operation shapes.
  - Re-spelling four programs with `use` clauses, unqualified calls and named
    actuals left their output and exit status identical on all 11 inputs.
- **Three-way agreement.**
  - **New programs:** on 44,018 generated sources (Names re-spellings of
    every earlier admitted program, fresh 5a–5c programs, exhaustive context
    forms, hiding combinations, mutations), native `silver check`, Lean
    `Silver.Current.accepts` and a spec-derived reference agree on all of
    them.
  - **Earlier programs:** on the previous review's 29,739 sources the
    reference also agrees with HEAD.
  - **Full GNAT code generation:** of the 19,041 admitted programs, 19,037
    passed. The 4 failures are 3 of B1 and 1 of B2.
- **Lean.** Correspondence and trust hold:
  - **Coverage:** all ten `Silver_Names` subprograms and every changed
    branch of the output profile have source checks.
  - **Theorems:** top-level statements are unchanged since `4503d17`, and
    their premises are jointly inhabited by premise-free witnesses.
  - **Re-check:** a probe re-elaborated `NamesSourceChecks` from its
    checked-in text against the current bytes.
  - **Certificates:** all 17 regenerate byte-identically from HEAD Ada.
  - **Axioms:** standard only. There is no `sorry`, `native_decide`,
    `implemented_by` or other escape anywhere in `proof/`.
- **Focused Source Checks.**
  - The diff contains only `public import` lines.
  - `Silver` and `Silver.Audit` reach the same module sets before and after.
  - `ComposeSourceChecks` drops from 92 to 28 modules (17 to 2
    certificates), as documented.
  - The control timings match the logs.
- **Evidence.** Every handoff number checks out against its evidence files
  (§2):
  - native: 3,163 checks, 0 unproved;
  - Lean: 252 modules and 56,748 audited declarations;
  - tests: 301, 294 and 62 methods.

  The GNATprove and Lean evidence binds to HEAD. The one exception is the
  host Python identity after this sandbox was re-imaged (I2).
- **Repair.** `04171a6` fixes the static/static class exactly. It also
  closes L2–L8 and L10, and defers the rest with recorded reasons (§5).

**What needs attention:**

1. **Fix B1 by bounding static contributions.**
   - **Rule:** when the target's length T is static, the value's static
     contribution S must satisfy S ≤ T, with S = T when the value has no
     dynamic part, even on unreachable paths.
   - **Coverage:** it covers all 623 GNAT failures found and rejects 17 of
     29,956 admitted organic sources. Three of those 17 fail GNAT today.
   - **Implementation:** mirror the rule in Lean and in the
     docs/catalogue. Add regressions for each operand order, the static shell
     and a shorter right-hand side.
   - **Corpus check:** run a full-codegen pass over the differential
     corpora. This is the previous review's recommendation, which the repair
     narrowed out.
2. **Fix B2 with a lexical restriction.**
   - **Rule:** if a string literal's last string element is `[`, the byte
     after its closing quote must not be an ASCII letter, digit or `_`.
   - **Implementation:** mirror it natively, in the Lean lexer and in the
     catalogue, and record GNAT's brackets notation as a frontend premise.
3. **Lows.**
   - Reword the catalogue's `First_Or_Default` hiding condition (L1).
   - Give the exact package sets and the declarative `use` exclusion a
     purpose (L2).
   - Close the test gaps (L3).
   - Link the Names lexical meanings to the checked `Token_At` (L4).
4. **Records.** Record the 785-assignment result (I1). Point
   `assurance.md` at the current Lean record (I9).

## 1. Method

- **Isolation.** This review modified no tracked file, nothing in `.tools/`,
  `.silver/linux-x86_64/proof`, the evidence directories or `tmp/`. §6 lists
  the side effects.
- **What I ran myself:**
  - `git ls-remote` against GitHub;
  - a `silver catalogue` JSON comparison;
  - checked the compiler's build time against the source modification times;
  - re-ran the 34 previous-review B1 build failures and both B1
    reproductions with `silver check`;
  - re-ran the previous review's 29,739-source corpus at HEAD, and compared
    it with that review's independent reference recognizer, patched with the
    static/static rule;
  - full GNAT code generation of the six newly admitted sources;
  - reproduced both blockers (`silver check` plus GNAT `gcc -c`);
  - read the repair dispositions for the carry-over table.
- **Multi-agent review.** Five read-only reviewers, all on Opus 5.5, each with
  one lens:
  - Ada/GNAT legality of Names and Calls;
  - differential testing of the compiler, Lean and a spec-derived reference;
  - the Lean model, source correspondence and the import narrowing;
  - evidence binding, handoff claims and tests;
  - documentation, specification, catalogue and carry-over.

  They raised 25 findings (2 blockers, 15 low, 8 info), with heavy
  duplication: one wording issue was found by four lenses. Three independent
  verifiers re-derived all 25: one per blocker and one for the merged lows and
  info items. Each verifier was told to refute and to reproduce rather than
  trust the finder's evidence. Result: 18 upheld, 7 narrowed, none refuted.
  Narrowing merged duplicates and moved several items to info or to
  carry-over status.
- **Owner's no-routine-rerun rule.** Every agent was bound by it: no Lean
  build, `check_lean.py`, `dev.py prove`, full suite or replay. Agents ran
  only targeted probes:
  - `silver check`/`compile`/`run`;
  - GNAT `gcc -c` with code generation;
  - read-only Lean probe files: directory evaluation of the 44,018 sources,
    a re-elaboration of the Names source checks, and axiom and witness checks;
  - test modules: `test_lean_source` (11), `test_names_calls` (7), the B1
    regression method, and `test_proof_provenance` plus `test_evidence` (62).

  Compiles and Lean probes went through a shared three-slot memory-aware
  runner. One probe compile, the 785-assignment shape (I1), ran for 32
  minutes.
- **Cost.** About 0.77M output tokens: reviewers 0.46M, verifiers 0.17M, lead
  0.14M. About 122M cache reads. The reviewers took 39 minutes of wall-clock
  time and the verifiers 15.

## 2. Native validation (Linux x86-64)

| Check | Result |
| --- | --- |
| Remote and tree | `origin/main` on GitHub is `e2c4fc2`. Only `tmp/` is untracked. `oracle.md` and `AGENTS.md` are unchanged since `4503d17`. |
| Installed compiler | Built at 15:49:19 UTC, after the last `src/` edit (15:48:10). `e2c4fc2` changes no SPARK. No binary hash is recorded anywhere. All 28 compiler units' ALI timestamps equal the HEAD source times. |
| Catalogue | `silver catalogue` equals `catalogue/silver.json` as JSON (27 constructs, 3 compositions). |
| GNATprove evidence (Names) | `gnatprove.out` is identical in the compiler object directory and `names-calls-…/native-reports/`. It records 3,163 checks (572 flow, 2,591 proof), 0 unproved, 20 units and 313 entities. All 2,408 input hashes and 22 report hashes match HEAD. 11 of 12 tool hashes match; the exception is the host Python after this sandbox was re-imaged (I2). |
| Repair evidence (`04171a6`) | Native: 3,049 checks over inputs equal to `04171a6`. Tests: 294 OK in 1,011 s, on exact final inputs. Lean: digest `1bf91494…` recomputes at `04171a6`; 242 modules; 53,490 audited declarations. |
| Lean evidence (HEAD) | `lean-evidence.json` digest `1ceb3d1d…` recomputes at HEAD and matches the Focused Source Checks record. 252 modules. 56,748 declarations, an axiom-audit count with standard axioms only. The canonical workspace is byte-identical to `proof/`. All 252 Lake-trace source hashes equal HEAD, and all 1,012 artifact hashes match. The final run rebuilt 13 modules, including `ComposeSourceChecks` (904 s), in 920 s. 79 traces were built in the canonical workspace and 173 promoted from lanes (I8). |
| Names Lean evidence (`8e5ffeb`) | Digest `52236c3b…` recomputes at `8e5ffeb`. 252 modules. A 14.1 s cached run that rebuilt four modules. |
| Certificates | All 17 candidates regenerate byte-identically from HEAD Ada. |
| Test record | **Names:** the full run (301 methods, 1,132 s) failed one method: the certificate-parity check found four stale generated copies. These were refreshed. The 10 source tests then passed three times, the last on inputs equal to `8e5ffeb`. The 61 Lean tests failed only on the same parity method; the 16 platform tests passed. **Focused:** 62 Lean tests OK, then a graph-only recheck. Every method has a passing run on its relevant final inputs. Reruns at HEAD: `test_lean_source` 11 OK; `test_names_calls` 7 OK; the B1 regression OK; `test_proof_provenance` and `test_evidence` 62 OK. |
| B1 repair, previous failures | All 34 full-codegen failures from the previous review's corpus, and both B1 reproductions, are now rejected. |
| B1 repair, precision | On the previous review's 29,739 sources, HEAD admission equals that review's reference recognizer patched with the static/static rule, except for six new Names admissions. Those six are repeated, reordered or grouped `with` clauses, and all build. 201 sources became rejected, every one explained by the rule. |
| Top-level theorems | `PredicateCorrespondence.lean`, `Current.lean` and `PredicateSourceBridge.lean` are unchanged since `4503d17`. The probe instantiations `executable_main_correct Implementation.modelCalls model_interpreted …` and `executable_pipeline Current.model_tool_contract …` elaborate. `#print axioms` gives only `propext`, `Classical.choice` and `Quot.sound` for the top-level theorems, witnesses, Names source checks and the repaired selector proofs. |

## 3. Findings

### 3.1 Blockers

1. **B1: a static target can still be assigned an impossible dynamic value
   in an unreachable arm, which GNAT rejects.** (Verifier: upheld, blocker.)

   - **Mechanism.** `Same_Length` (`src/silver_path_facts.ads:119-125`)
     enforces a reachability-independent check only when both summaries
     have `Dynamic_Count = 0`. Its Lean mirrors are `equalSummary`,
     `PathFacts.Native.sameLength` and `sameLengthBody`. On an unreachable
     path the dynamic part of the check is vacuous, so a value of length
     S + K·d with K ≥ 1 and S > T is admitted for a target of static length
     T. No input length can make the two equal, and GNAT knows the value's
     minimum length is S.
   - **Reproduction.** `silver check` accepts the program below (Names
     spelling; the qualified spelling behaves the same). GNAT reports
     "wrong length for array of subtype of "Standard.String" defined at
     line 6". A verifier's defensive `Status := "Error: " & Input` variant
     printed `Success: all checks proved (46 checks)`, then
     "Compilation failure for admitted Silver: toolchain or implementation
     defect.", exit 3.

     ```ada
     Input : constant String := First_Or_Default (Default => "old");
     Fixed : String := "abc";
     begin
        if not Input_Is_Valid then
           Reject;
        elsif Input'Length > 4096 then
           Fixed := "abcd" & Input;
        else
           Put_Line (Item => Fixed);
        end if;
     ```
   - **Exact GNAT behaviour.** The verifier generated a 2,538-source matrix
     and 60 extra probes. Eleven unreachable-arm shells were used:
     - interval contradictions;
     - invalid-input exclusion;
     - impossible String equalities;
     - `and then`/`or else`/`not`/`elsif` combinations.

     They were combined with static and snapshot targets, values with K = 1
     or 2, S <, = or > T, and every operand order. GNAT 16.1 rejects exactly
     when all of the following hold:
     - its frontend does not fold the arm;
     - T is static;
     - the value's first non-null operand is static;
     - S > T.

     So `"abcd" & Input`, `("ab" & Input) & "cd"`, `Four & Copy` and
     `Fixed & "x" & Input` fail. `Input & "abcd"`, dynamic targets
     (`Work : String := Input`), folded arms and reachable refined arms build.
     There were 620 failures in the matrix and probes. The reviewers'
     full-codegen pass found 3 organically, among 19,041 admitted programs.
   - **Origin.** Introduced by `4503d17`. At `dc5295e`, `Assignment_At`
     rejected any static or dynamic-count mismatch unconditionally. The
     repair did not introduce the residual: it restored only the static/static
     part, as the previous review recommended. That review's §3.1 said
     "Arms that build: … any mismatch involving a dynamic length". The
     verifier traced that over-generalization to its matrix: every dynamic
     case there was dynamic-first (`Input & "abcd"`) or had a dynamic
     target.
   - **Overclaim.** `language.md:264-267` says the static rule "prevents
     GNAT's SPARK code generation from rejecting a statically mismatched
     assignment in a dead arm". `docs/branches.md:24-27` says the rule
     "avoids depending on which dead arms GNAT folds away". Both are true
     only for static/static pairs.
   - **Recommendation.** Adopt the verifier's rule N1:

     > When the target's length T is static, the value's static contribution
     > S must satisfy S ≤ T, and S = T when the value has no dynamic
     > occurrence, regardless of reachability.

     - **Coverage:** N1 covers all 620 probe failures and the 3 organic
       ones.
     - **Cost:** it newly rejects 17 of 29,956 admitted organic sources, all
       in unreachable arms. Three of them fail GNAT today; the other 14 build
       only because GNAT folds their arms.
     - **Independence:** it depends neither on operand order nor on folding,
       so it does not model GNAT.

     The principled alternative is "some input length 0..4096 equalizes both
     sides". It is also complete, because GNAT cannot prove a mismatch that
     some d equalizes. It newly rejects 80 sources, though, and its extra 63
     are shapes GNAT 16.1 never rejects. To land either rule:
     - mirror it in `Same_Length`, `PathFacts.Native.sameLength`,
       `Predicate.equalSummary`, `sameLengthBody` and the source checks;
     - optionally state it as a short Lean lemma (I10);
     - update `language.md:211-216` and `:262-267`, the catalogue's
       `decoded_length` (`src/silver_catalogue.adb:321`) and
       `docs/branches.md`;
     - add rejected regressions for `"abcd" & Input`,
       `("ab" & Input) & "cd"`, `Four & Copy` and a static-shell case, and an
       admitted `Input & "abcd"` to pin order independence;
     - run one full-codegen (`gcc -c`) pass over the admitted differential
       corpora.

     The previous review recommended that pass. The repair excluded it
     ("no blanket differential-corpus compilation"), and it is the check
     that found this residual.

2. **B2: GNAT's brackets notation rejects an admitted literal ending in `[`
   before a keyword.** (Verifier: upheld, blocker.)

   - **Reproduction.** `silver check` accepts the program below. GNAT reports
     "main.adb:6:12: error: illegal wide character". `silver compile` fails
     in GNATprove phase 2 with "Verification failure for admitted Silver",
     exit 3.

     ```ada
     with Silver_IO;
     procedure Main is
        pragma SPARK_Mode (On);
        X : String := "[";
     begin
        if X = "["then Silver_IO.Put_Line (X); end if;
     end Main;
     ```
   - **Ada and GNAT.**
     - **Ada:** the source is legal. RM 2.2(7) requires no separator between
       a string literal and a reserved word, and RM 2.6 makes `"["` a
       literal.
     - **GNAT:** RM 2.1 leaves the coded representation
       implementation-defined. The GNAT 16.1 User's Guide in the toolchain
       (`share/info/gnat_ugn.info:10506-10523`) says brackets coding "is
       always accepted, even if one of the other options is specified".
       Inside a string literal, `[` + `"` + an identifier character starts a
       `["hh"]` encoding, so the closing quote is consumed and decoding
       fails.
     - **Workarounds:** no `-gnatW*`, `-gnati*`, `-gnatX` or language-version
       switch, and no `pragma Wide_Character_Encoding` (configuration file
       or inline), avoids it.
   - **Exact class.** Of the 98 admitted bytes after `"["`, exactly
     `[0-9A-Za-z_]` trigger it. In admitted programs, only `then`, the `and`
     of `and then` and the `or` of `or else` can follow a literal directly,
     in any letter case. The trigger applies in `if` and `elsif`, inside
     parentheses and `not (…)`, and after `&`.

     The literal's last string element must be `[`: `"x[""["then` fails and
     `"["""then` builds. These build: whitespace, CR, a comment or
     parentheses before the keyword, and literals ending in `]`.
   - **No silent miscompile.** GNAT decodes only `["` + 2, 4, 6 or 8 hex
     digits + `"]`, and no admitted continuation supplies that. Silver and
     Lean both reject `"["41"]"`, which GNAT would decode to `A`. A
     `silver run` of 12 bracket and doubled-quote literals proved 44 checks
     and printed every byte unchanged.
   - **Origin and scope.** `1ed039e` ("Add validated input-dependent
     branching", 2026-10-10) first placed `String_Literal` directly before
     `Then_Keyword`. Its token matcher checked only the byte after a word, so
     `if Mode = "["then` was admissible from then on.
     - **Agreement:** native, Lean and the spec agree in admitting it, so
       this is not a correspondence gap.
     - **Organic cases:** the reviewers' corpora contain two. One of them
       (`big/others_008543_…`) was already admitted by the previous review's
       larger corpus.
     - **Why reviews missed it:** that review's full-codegen pass covered
       only 7,096 sources, none with the pattern. Its statement that GNAT
       accepts "all 7,096 admitted sources" was accurate only for that
       subset.
     - **Premise:** `language.md:42-45` and `docs/trusted-boundary.md:53-59`
       state the frontend premise that every admitted lexical element is
       accepted, with no exception for this case.
   - **Recommendation.** Add an explicit pre-1.0 lexical restriction:

     > If the last string element of a string literal is `[`, the byte
     > immediately after its closing quotation mark must not be an ASCII
     > letter, decimal digit or underscore.

     Its purpose is that GNAT always reads that sequence as a
     brackets-encoded wide character. Authors add a space, a comment or
     parentheses.
     - **Why not ban `["` everywhere:** a whole-source rule (`["` +
       identifier character never outside comments) is equivalent today, but
       would over-restrict Ada 2022 bracket aggregates.
     - **Where to mirror it:** in the native lexer, the Lean lexer behind
       `Silver.Current.accepts`, and a catalogue field.
     - **Frontend premise:** record GNAT's brackets notation in
       `docs/trusted-boundary.md`, and qualify `language.md:42-45`.
     - **Rejected regressions:** `"["then`, `"["THEN`, `"["and then`,
       `"["or else`, an `elsif` form, `"x[""["then` and `X & "["then`.
     - **Admitted regressions:** `"[" then`, `"["--c`, `(X = "[")then`,
       `"["""then` and `"[""41""]"then`.
     - **Keep rejected:** `"["41"]"`, with a note that GNAT would decode it.

### 3.2 Low

1. **L1: the catalogue's `First_Or_Default` hiding condition contradicts the
   compiler, and the case is untested.** Four lenses found this; all four
   verdicts were upheld or narrowed to this wording.
   - **Text:** `argument_initialization` says an unqualified call needs "use
     clause for operation package and no local same-name binding"
     (`catalogue/silver.json:149`, `src/silver_catalogue.adb:153`).
   - **Compiler:** `Argument_At` hides the initializer only for the input's
     own name (`src/silver_output_profile.adb:661-662`). That is Ada's rule:
     a later object's immediate scope starts at its own declaration
     (RM 8.2(2)).
   - **Result:** an unqualified initializer followed by a later object named
     `First_Or_Default` is correctly admitted, and GNAT builds it. It
     compiled, proved and ran correctly. The catalogue text excludes it.
   - **Scope:** the other six constructs with the same text are exact,
     because body calls follow all declarations. `language.md:97-99` is
     accurate.
   - **Fix:** reword `argument_initialization` (e.g. "the declared input is
     not itself named `First_Or_Default`; later declarations do not hide
     it"). Add the admitted case next to the self-named rejection in
     `tests/test_names_calls.py`.
2. **L2: two Names restrictions on legal Ada have no stated purpose.** Three
   lenses found this, and it was upheld.
   - **Exact package sets** (`language.md:66-70`). A static program whose
     context names `Silver_Arguments`, and an argument program without
     `with Silver_IO`, are legal Ada and rejected. In 4,500 random programs,
     static shells naming `Silver_Arguments` were the only GNAT-accepted,
     Silver-rejected class. The rule is stated, but its only justification is
     proof-internal (shell uniqueness).
   - **`use` inside `Main`.** `language.md:92` says "Context clauses cannot
     occur inside Main", which is true of Ada by definition. A
     `use Silver_IO;` in Main's declarative part (or a block) is legal Ada
     that GNAT builds, and Silver rejects it without saying so. This is the
     L3 pattern the previous review asked to avoid (`oracle.md:19`).
   - **Fix:** state each exclusion and its purpose (e.g. "the imported
     package set selects the shell, its runtime evidence and its report
     policy"), add catalogue fields, and list local `use` clauses among the
     remaining roadmap work.
3. **L3: regression gaps.**
   - **B1 (`tests/test_path_refinement.py:75-87`).** There is one rejected
     shape: the argument shell, a longer static RHS, and an `Input'Length >
     4096` arm. Removing the conjunct entirely would be caught. Weakening it
     to one direction (value ≤ target), or confining it to argument programs,
     would pass the suite. Missing shapes, all currently rejected and all
     GNAT failures if admitted:
     - the static-shell `t2` shape;
     - a shorter static RHS (`Fixed := "ab"`).
   - **Names (`tests/test_names_calls.py`).** No test names the input binding
     itself `Put_Line`, `Reject` or `Input_Is_Valid`. Current behaviour
     matches GNAT: the unqualified call is rejected and the qualified one
     admitted. Ada legality of name resolution is outside the proofs
     (I6), so tests are its only regression guard.
   - **Fix:** add check-only pairs (milliseconds each).
4. **L4: the Names Lean bridge assumes its lexical callees' meanings.**
   - **The assumption:** `Names.InterpretedSource` states
     `calls.token … = fixedAt …` and
     `calls.trivia … = Cursor.triviaPosition …` directly
     (`proof/Silver/NamesEquations.lean:21-26`).
   - **The established route:** the Compose bridge instead derives
     `Token_At`'s meaning from its source-checked body tree
     (`token_denotation`).
   - **Duplicated definitions:** `Names.fixedAt` and `Names.take`
     (`Names.lean:41`, `:49`) are hand copies of `Compose.fixedAt` and
     `Compose.fixedAfter` (`ComposeAdmission.lean:86`, `:100`). They exist
     because of the import direction. They are definitionally equal today
     (probe `rfl`), and `trusted-boundary.md:649-650` discloses the premise.
   - **Risk:** no theorem keeps the two copies equal, so a later edit to one
     copy would make the public premise false of the implementation without
     any check failing.
   - **Fix:** derive the Names fields from `InterpretedSource.lexical`, or at
     least conjoin a checked
     `Names.fixedAt = Compose.fixedAt ∧ Names.take = Compose.fixedAfter`
     into `CheckedSource`.

### 3.3 Info

1. **I1: the densest assignment shape grew to 785 and still fits.**
   - **Shape:** grouped `with`, `use Silver_Arguments` and unqualified calls
     shorten the densest argument-input shape. 785 `X:=D;` assignments now
     fit in 4,092 bytes; 786 are rejected.
   - **Result:** this review compiled it in 32 min. It proved 829 checks.
     The report is 2,020,723 bytes, 96.36% of the 2 MiB buffer, leaving a
     76,429-byte margin (the 782 shape left 83,899).
   - **Disclosure:** `docs/names-and-calls.md:181-183` disclosed that no
     dense proof was repeated.
   - **Next step:** record the result there or in the roadmap's capacity
     row.
2. **I2: native provenance binds the host Python byte-for-byte.**
   - **The failure:** after this sandbox was re-imaged (PID 1 started 18:53
     UTC, after the implementer's 18:13 final check),
     `scripts/check_evidence.py` rejects otherwise-intact evidence with
     "proof tool changed: python". `/usr/bin/python3.14` is now the Aug 20
     build, while the manifest records the Jun 18 build.
   - **Not affected:** `dev.py prove --full` reruns anyway, and the tests
     use fixtures.
   - **Fix:** document that revalidation is bound to the host interpreter,
     or bind Python by version.
3. **I3: catalogue call templates remain qualified and positional.**
   `language.md:462-464` (new in `8e5ffeb`) declares token arrays informative
   skeletons, and the construct conditions are normative, so they do not
   contradict the compiler. The JSON itself carries no such marker. This is
   deferred L12.
4. **I4: the implementer's GNAT visibility probes used `-gnatc` only**
   (`tmp/names-visibility-…/results.json`). This review repeated them with
   code generation and agrees.
5. **I5: `Take` and `Read_Context` are contract-only in Lean.** Lean
   receives them through token pins and GNATprove-proved `Static`
   postconditions, which is the established pattern for statement-bodied
   helpers. The other eight `Silver_Names` bodies are checked as full
   expression trees.
6. **I6: Lean has no Ada name-resolution semantics.** Unqualified and named
   calls get the qualified positional meaning by construction (decoded
   payloads record positions, not spellings). Hiding exists only as a
   recognizer flag. `trusted-boundary.md:652-654` discloses this. The kernel
   examples cover only `Put_Line`.
7. **I7: the new import-closure test guards only `ComposeSourceChecks`.**
   Reintroducing `Silver.Source` into the other four narrowed bridges would
   pass. The risk is performance only; `audit_import_closure` still enforces
   the full module set.
8. **I8: most Lean artifacts were built in lanes.** 173 of 252 traces were
   built in isolated lanes and promoted. The "complete" check is
   trace-validated cache acceptance plus a fresh audit, as disclosed. Orphan
   probe traces and two `*.review-candidate` files remain in the canonical
   workspace.
9. **I9: `assurance.md:380-382` points to the wrong Lean record.** It still
   names the Names checkpoint as the current complete Lean record. The check
   matching HEAD's proof tree is in `docs/focused-source-checks.md`, which
   `assurance.md` does not link.
10. **I10: the B1 invariant is not a Lean theorem.**
    `equalSummary`/`sameLength` carry the static/static conjunct, but no
    lemma states the admission property. A probe proved one with `propext`
    only. Add the fixed rule as a lemma.

## 4. Probes and experiments

| Probe | Result |
| --- | --- |
| Previous B1 failures at HEAD | 34/34 corpus failures and both reproductions are rejected. |
| Old corpus vs reference + static rule | 29,739 sources: agreement except 6 new Names admissions. 201 newly rejected, all by the rule. |
| Names context forms (36), hiding (50), associations (47) | Admitted spellings are exactly the GNAT-legal ones. Rejections are illegal Ada or documented exclusions. GNAT-legal exclusions: static `Silver_Arguments`, `private with`, a pragma between clauses, the `Standard.` prefix, and `use` inside `Main` (L2). |
| Random Names programs (4,500, two seeds) | Zero mismatches with the documented rules. All 405 admitted build. Every GNAT-accepted rejection is a static shell naming `Silver_Arguments`. |
| Redundant `with`/`use` clauses | GNAT warns only. `silver compile` proves and the report policy accepts. |
| Names compiles (8 + 6) and re-spelled pairs (4 × 11 inputs) | All prove and build, including 267 redundant `with` clauses. Invalid inputs give status 1 and no output. Re-spelling preserves stdout and status. |
| Differential corpus, 44,018 sources | Native = reference = Lean on all. Lean evaluation took 46 s + 980 s + 9 s in three probes. |
| Full codegen of 19,041 admitted programs | 4 failures: 3 in B1, 1 in B2. |
| B1 class map | 2,538 matrix sources and 60 extras; 620 failures. Exact rule given in §3.1. Candidate rules: N1 newly rejects 17 sources, EXISTS 80, N2 65. |
| Brackets byte map, switches, run | 63 trigger bytes. No switch or pragma helps. No byte changes at run time. Origin `1ed039e`. |
| Lean probes | Recognizer equals native on 24 targeted sources. Top-level instantiations elaborate. Names source checks re-elaborate in 57 s. `Names.fixedAt = Compose.fixedAt` by `rfl`. |
| Evidence | All digests recompute. 252 trace hashes and 1,012 artifact hashes match. Certificates regenerate 17/17. The provenance validator fails only on Python (I2). |
| Dense 785 shape | 829 checks proved, 96.36% of the report buffer, 32 min. |
| L9 reproduction | `silver run` of a program that rejects its default reports an external failure with exit 3. The binary itself exits 1 with no output, as specified. |

## 5. Carry-over from the previous review (`4503d17`)

| Item | Status at `e2c4fc2` |
| --- | --- |
| B1 dead-arm static assignments | **Static/static fixed** in `04171a6` (`Same_Length` conjunct; spec, catalogue, test). A **residual remains** for static targets with impossible dynamic values: B1 here. |
| L1 test gaps | Deferred (`docs/branches.md:41-43`). |
| L2 "vacuous" | Fixed (`language.md:211-216`). |
| L3 restriction purposes | Fixed for the 5b/5c exclusions, with catalogue `scope_purpose` and `value_bound_purpose` fields. Names adds two exclusions without purposes (L2 here). |
| L4 stack premise | Fixed (`README.md:162-170`, `docs/trusted-boundary.md:61-73`). Names adds no recursion: 4,096 bytes of clauses are admitted at a 256 KiB stack. |
| L5 links into ignored evidence | Fixed. No Markdown link points into `.silver/` or `tmp/`. |
| L6 full-suite scope | Fixed (`docs/branches.md:506-512`, `:599-604`). |
| L7 stale counts | Fixed, now "seventeen" (`assurance.md:305-308`, `trusted-boundary.md:760`, `:794`, `:808`). |
| L8 other stale text | Fixed. Two stale source comments are deliberately retained to avoid certificate rebuilds (`docs/branches.md:47-49`). |
| L9 `silver run` and `Reject` | Deferred, and still reproduces. `README.md:271-278` still does not document the mapping, which the previous review offered as an alternative fix. |
| L10 Lean regression guards | Fixed: token-list agreement in `CheckedSource`, integer-literal lexing facts, PathFacts precedence, and Predicate precedence and scopes. |
| L11 retention and sample witnesses | Deferred. |
| L12 catalogue token fields | Deferred. Partly answered by `language.md:462-464` (I3). |
| L13 manifest tags | Deferred. The new `names_calls.adb` entry omits `string_literal`, `string_concatenation`, `capacity_guard`, `length_predicate`, `boolean_predicate` and `integer_literal`. |
| I1 retired `Sequence*` modules | Deferred (legacy cleanup). There are 32 `Sequence*.lean`. |
| I2, I3 theorem shape and semantic fragment | Unchanged. |
| I5 cached Lean runs | Recurs (I8 here). |
| I6 contracts | No new `pragma Assume`, `Annotate`, `SPARK_Mode (Off)` or assertion-policy change in `src/` since `4503d17`. |
| I7 dead legacy scanner code | Deferred. `Comparison_At` and related code are still present. |
| I4, I8 callee routing and performance | Not re-examined. |
| I9 density | Superseded by I1 here (785 assignments). |
| I10 broken anchor | **Retracted.** `RESUME.md` has the anchor (`:436` at `4503d17`, `:526` now); the repair's rebuttal is correct. |
| §3.4 `others_008960` | Rejected at HEAD. |

Other corrections to the previous review:
- **B1 scope.** Its B1 scope statement about dynamic lengths was wrong; see
  B1 here.
- **"Warm replay."** Its "warm replay" was an incremental build with a
  fresh audit, not a replay, as `docs/branches.md:52-54` notes.
- **GNAT acceptance.** Its "all 7,096 admitted sources" GNAT acceptance
  did not cover its larger corpus (B2).
- **`tmp/greeting-example-9rp5sciv/`.** That review called this directory
  foreign. The implementer identifies it as their preserved scratch from the
  owner's example request.

## 6. Side effects and state

- **New.** 30 `.silver/linux-x86_64/program-*` directories from this review's
  probe compiles, including `program-4Mit03` (25 MB, the 785-assignment
  shape) and `program-CNW3xL` (the L9 run). Scratch is in the session
  scratchpad only.
- **Unchanged:**
  - tracked files;
  - `.tools/`;
  - `.silver/linux-x86_64/proof`;
  - the evidence directories;
  - `lean-evidence.json`;
  - `tmp/` (no file newer than the review start);
  - the Git refs and index.
- **Harness note.** One reviewer received a background-task notification
  naming a program directory that never existed. It discarded the
  notification and waited for the real result, so the findings are
  unaffected.
- This report is untracked and uncommitted.

## Appendix: commands

```sh
# Remote, catalogue, compiler freshness
git ls-remote https://github.com/berkeleynerd/silver.git refs/heads/main
.silver/linux-x86_64/compiler/bin/silver catalogue | jq -S .   # vs jq -S . catalogue/silver.json
ls -la --time-style=full-iso .silver/linux-x86_64/compiler/bin/silver src/*.ad[sb]
# B1 repair at HEAD
silver check <34 previous gcc failures> r2_arg_dead.adb t2.adb
python3 -I regress/run.py              # 29,739 earlier sources, verdict changes
python3 -I oracle/cmp.py               # vs previous reference + static/static rule
gcc -c -gnat2022 -gnata -gnato -I src main.adb   # full code generation, six new admissions
# Blockers
silver check f1_static_target_dyn_dead.adb w1.adb; gcc -c -gnat2022 -gnata -gnato … main.adb
silver compile c1_defensive_error_prefix.adb      # exit 3 after 46 proved checks (verifier)
silver compile f2_bracket_then.adb                # exit 3 in GNATprove phase 2 (reviewer)
# Evidence (reviewers): digests, trace and artifact hashes, provenance, certificates
python3 leandigest_commit.py <commit> <evidence>; lean --run hash.lean …; lean --run binhash.lean …
python3 -c '…proof_provenance.validate_provenance(native_layout(), …)'   # fails only on python
python3 proof/generate_source_certificate.py --output <scratch>/… --source <file>   # 17/17 identical
python3 -m unittest tests.test_lean_source tests.test_names_calls tests.test_proof_provenance tests.test_evidence
```
