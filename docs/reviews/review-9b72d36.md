# Review of 9b72d36, "Generalize String expressions across existing program forms"

Reviewed 2026-10-13 on the Linux x86-64 development sandbox (12 CPUs, ~31 GiB),
the project's primary platform, read-only on tracked files, from the checkout
at `9b72d36` (`main`). Scope is everything after the last review (`d375aec`):
17 commits, 183 files, +29,673/−15,515 lines:

- `26737d9`, `767a33c`: the three final external reports, their dispositions
  and the kernel-bypass guard (previous M1);
- `96b98e1`, `e9d18f1`: composed String outputs, branch-selected results and
  literal-backed copies;
- `ec19c4a` … `a68d0b7`: the Lean performance sequence (baseline, checked join
  witnesses in `CertificateWitness`, module boundaries, memory split) and its
  records;
- `ea44303`, `0abdb55`, `004a9b8`, `640d5cc`: the restriction/capacity audit,
  the remote plan assessment and the Oracle/roadmap integration;
- `7547b3d`, `9b72d36`: shared bindings/copies and common String expressions:
  the `Compose*` Lean model, the rewritten recognizer and the report policies.

Hand-written Lean changed by ≈11,000 diff lines, generated certificates by
≈35,600, SPARK by ≈3,300, tests by ≈2,700 and documentation by ≈8,200.
Scratch, probes and agent notes are in the session scratchpad; nothing was
written under `tmp/`.

## 0. Verdict

**No blocker or high finding. Two medium findings, both evidence gaps rather
than defects in admitted behaviour. Nothing blocks statement sequencing.**

**What works.** The two language increments do what they claim, and the
evidence is bound to the tree under review:

- **Three recognizers agree.** On a reviewer corpus of **13,730 sources**
  (277 targeted, 18 micro, 13,435 sampled; 4,477 admitted, 9,253 rejected) the
  compiled SPARK recognizer and Lean `Silver.Current.accepts` disagree on
  **none**. GNAT `-gnatc -gnat2022` accepts **466/466** admitted programs it was
  given. Against a build of the `d375aec` compiler, **558/558** previously
  admitted programs are still admitted, and all 3,908 newly admitted ones fall
  under `language.md` forms; none of 20 random mutations is admitted. Thirty
  targeted `silver compile` runs (snapshots, self-copy, a 289-declaration
  dense source) all proved and executed as specified.
- **Ada fidelity.** 100 reference-manual-driven probes: every admission
  coincided with GNAT acceptance, and every Ada-illegal shape tried
  (self-initializer, literal-only equality, assignment to a constant,
  case-variant duplicates, bad underscores, tab in a literal, misplaced pragma,
  `4088then`) is rejected. Equality is bounds-free byte equality, `&` is
  operand-ordered, assignment lengths are established statically through the
  affine summaries, and copies snapshot.
- **Evidence is content-bound to HEAD.** The complete Lean record's inputs
  digest recomputes to the same `5d0901c2…` over the 139 tracked inputs; the
  workspace is byte-identical to `proof/`; 114 modules, 33,994 declarations,
  standard axioms only; nothing changed after the build started. Every
  GNATprove input and report hash matches HEAD (17 units, 234 entities, 2,602
  checks). All twelve certificates regenerate byte-for-byte from the tracked
  generator; `include_str` is confined to the twelve bindings.
- **The previous M1 is genuinely fixed.** The source/trace guard runs before
  the workspace is touched and after every phase, catches every direct
  spelling tried (`set_option … in`, guillemets, macros, `withOptions`,
  lakefile `-D` arguments, `addDeclWithoutChecking`, both `addDeclCore` forms,
  reverted-but-cached traces), and its residual (metaprograms, no routine
  replay) is stated accurately in five places.
- **The suite is clean at HEAD.** My own `dev.py test` run passed
  **256/256 with no skips** (825.7 s). The implementer's run was not clean
  only because two certificate-parity subtests ran against stale tracked
  certificates promoted nine minutes later; §3 L30 records the chronology.

**M1 (medium).** The new composed source bridge delivers every actual-source
correspondence theorem as an implication from
`Compose.SourceBridge.InterpretedSource calls` (34 definition equations plus
range contracts and legal-body domains), and unlike every earlier bridge
nothing inhabits that premise: there is no `Compose.Expressions.modelCalls`
and no `model_interpreted`. If the equation set were jointly unsatisfiable,
the headline theorems would be vacuously true and the complete check and audit
would still pass. The reviewer differential is strong empirical mitigation; it
is not what the Oracle asks Lean to establish.

**M2 (medium).** `silver check` prints one identical message for every
rejection, and all 139 rejected fixtures in the four new test modules assert
only the exit status. A fixture rejected for an unintended reason (a typo, an
undeclared name) is indistinguishable from the rule under test, and 72 of the
139 are valid Ada, so GNAT cannot tell either. The implementer's own record
shows fixture-construction mistakes happen. This is pre-existing in design but
is now the suite's main guard for the new rules.

**On further expansion:** yes. Do M1 (or record its deferral explicitly) and
M2 before statement sequencing, because that increment rewrites both the
recognizer and the bridge again.

**Smallest justified work, in order:**

1. **M1:** define `Compose.Expressions.modelCalls` and prove
   `model_interpreted : InterpretedSource modelCalls` (the existing
   `interpreted_*` equations in reverse plus `ValidState`/`ValidScan`
   preservation for the model functions). If deferred for cost, say so in
   `assurance.md` and scope `trusted-boundary.md:597-600` to the null bridge.
2. **M2:** a diagnostic channel that does not affect membership
   (`silver check --explain`, or an environment variable) printing the first
   failed condition, asserted by negative tests; at minimum pair every
   negative fixture with its nearest admitted sibling, as the capacity tests
   already do.
3. **Bridge statement strength** (L2–L7): restore the null-profile conjunct
   in the facade (two lines); give the guarded shape a `Current` witness;
   tie `Form.hasArguments`/`hasAssignment` to the pinned ranges; name the
   newly interpreted Ada constructs in the interpretation premise; track or
   describe the pin-refresh script (L1).
4. **"What is supported" text and catalogue** (L10–L19): catalogue `count`
   fields, manifest guard tags, the four stale roadmap/README/assessment
   passages, guard-restriction purposes in `language.md`.
5. **Test hygiene** (L21–L28): skip accounting for the five new Lean-native
   tests, the construct-set pin, 17-leaf negatives in every position, the
   alias-capacity and second-`First_Or_Default` negatives, de-duplicated
   compile helpers, a positive assertion in the trace scan.
6. **Evidence tooling** (L29–L31): validate the OS interpreter by version
   rather than binary hash; capture `proof/` in the full-test input snapshot;
   remove the machine path and the dependence on untracked `tmp/` pointers.
7. **Bookkeeping** (L32–L34): the three carry-over items whose dispositions
   no longer match the tree.

## 1. Method

- **Isolation.** No tracked file, `.tools/`, `.silver/linux-x86_64/proof` or
  `tmp/` was modified. The only repository side effects are the usual
  `.silver/program-*` directories created by probe compiles and the full test
  run (§6).
- **Multi-agent review (67 agents).** Fourteen read-only reviewers, one lens
  each: the SPARK recognizer; report policy and catalogue; the Lean
  grammar/admission model; Lean semantics and obligations; actual-source
  correspondence and the new meta code; the Lean trust boundary and runner;
  evidence tooling; tests; spec/catalogue consistency; documentation claims;
  a differential recognizer probe; carry-over dispositions; Ada/SPARK
  fidelity against the vendored reference manuals; and mechanical process
  hygiene. They raised 79 findings. After merging duplicates, the three
  mediums and seven low/info findings with upgrade potential were each judged
  by two independent skeptics (code-truth/policy, and reproduction) and
  survived only if both upheld them: 7 of 10 did, and one more survived in a
  narrowed form. The remaining 33 lows/infos were judged by one skeptic: 30
  survived. Twenty-three info items were not independently verified; eight of
  them I spot-checked myself (§3.4). Verification was deliberately leaner
  than the three-lens majority vote of the previous reviews, at the owner's
  request, to bound model usage (≈2.0M output tokens over 105 minutes).
- **What I ran myself.** The complete suite at HEAD, the Oracle diff, the
  implementer's full-test/certificate-promotion chronology, and the
  spot-checks in §3.4.

## 2. Native validation (Linux x86-64)

| Check | Result |
| --- | --- |
| `python3 scripts/dev.py test` at `9b72d36` (17:12–17:26 UTC, overlapping the reviewers) | **Passed: 256 tests, 0 failures, 0 skips**, 825.7 s. First clean full invocation of the final tree (see L30). |
| Lean evidence binding (`lean-evidence.json`; digest recomputed without building) | **Matches HEAD**: `5d0901c2…` over 139 tracked inputs; workspace `.lean`/lakefile/toolchain byte-identical to `proof/`; 114 modules and 114 `.olean`, no stale objects; last proof edit 16:13:03, build 16:19:42–16:38:40, audit 16:38:40–16:38:43; "Silver axiom audit passed: 33994 declarations; foundations: [propext, Classical.choice, Quot.sound]". No replay (`kernel_recheck: null`), as recorded. |
| GNATprove evidence binding (`proof-provenance.json`) | Every src/scripts/generated/alire input hash and every report hash matches HEAD; `audit_sources` returns 17 units, 234 entities, 443 flow + 2,159 proof checks, 54 limitation notes, 14 imports; all ten pinned Alire tools hash-match. `check_evidence.py` itself exits 1 here only because of the OS `python3` pin (L29). The 3,029 → 2,602 change is the replacement of slot-specific recognition by shared rules, as `shared-bindings.md` says; the policy, catalogue and driver units are fully proved (62/62, 8/8, 9/9 entities). |
| Generated certificates | All twelve `*Certificate.lean` byte-identical to `proof/generate_source_certificate.py` output over HEAD `src/`; the script generates exactly those twelve and refuses to write inside `proof/`. |
| Catalogue | `silver catalogue` equals `catalogue/silver.json` as JSON (23 constructs, 8 compositions + null); the bytes differ in formatting. |
| Differential recognizer (reviewer corpus) | **0 disagreements on 13,730 sources** between `silver check` and Lean `Silver.Current.accepts`; GNAT accepted **466/466** admitted programs; monotonicity against a `d375aec` build 558/558; 30 targeted proofs passed (44–59 checks each; 288 classified `INEFFECTIVE` advisories for the 289-declaration program). |
| Ada fidelity probes | 100 probes, all consistent (see §0). `4088` admitted; `4_088`, `16#FF8#`, `4E3`, `04088`, `4097` rejected (L18). |
| Report policy | Policy unit fully proved; `tests.test_library_reports` 32/32 against a probe rebuilt from HEAD; 79/82 report mutations behaved as the reconstructed predicate predicts (three were reviewer expectation errors). |
| `how_proved` probes | Four programs designed to invite trivial discharge (literal-only initializer `"ab" & "cd"`, `("" & D) & (D & "")` under a guard, `S := "ab" & "c"`, `S := S`) all admitted and compiled; the only Main proof records are `VC_RANGE_CHECK`/prover/info; 0 non-prover Main records in 439 retained reports. |
| Frontend warnings | With `-gnatwa`, GNAT 16.1 warns on static equality, self-copy and unreferenced constants; with the project's switches it does not, and gnatprove 16.1 forwards no frontend warning into `main.spark` or its exit status even when `-gnatwa` is forced (R2). |
| Pure-Python suites | 136 tests pass in seconds. |

## 3. Findings

### 3.1 Medium

**M1. The composed source bridge has no consistency witness; its correspondence theorems could be vacuous.** (new; two Lean reviewers independently; both skeptics upheld)

- `proof/Silver/ComposeSourceBridge.lean:61-67` defines
  `structure InterpretedSource (calls) : Prop` with fields `lexical`,
  `definitions : Expressions.DefinitionEquations calls calls` and
  `legal : Expressions.LegalBodies calls`. All four headline theorems take
  `(sourceEquations : InterpretedSource calls)`:
  `authoritative_source_member_iff` (:83), `authoritative_selectors` (:95),
  `authoritative_current_member_iff` (:111) and
  `checked_membership_supported_pipeline` (:125). A Lean probe against the
  built workspace prints the hypothesis verbatim.
- Nothing produces it. The only `Compose`-side witness is
  `ComposeLexical.model_interpreted` (:243), which covers the lexical field
  only; `Compose.Expressions` defines `modelPrimitives`
  (`ComposeExpressions.lean:851`) but no `modelCalls`. The `.ilean` files
  mentioning `InterpretedSource` are the retired per-form modules plus the two
  Compose files. Every retained earlier interface carries a witness
  (`ArgumentsEquations.lean:132`, `AssignmentEquations.lean:134`,
  `ConcatEquations.lean:125`, `NamedEquations.lean:201`,
  `RecursiveBridge.lean:219`, the per-form `model_interpreted` theorems), and
  the facade that `96b98e1` deleted had one
  (`d375aec:proof/Silver/BranchingExpressions.lean:246`).
- **Why it matters.** The Oracle requires Lean to establish correspondence
  with the actual compiler. Inconsistency is plausible only through the
  `RangeContracts` or `LegalBodies` side conditions (the body equations are
  structurally recursive), but if it occurred every correspondence theorem
  would hold vacuously and nothing would detect it. `trusted-boundary.md:
  597-600` ("an explicit model satisfies those equations") predates this
  change and now reads as if the witness exists for the composed bridge;
  `assurance.md` never states that it is deferred.
- **Fix.** See §0 item 1.

**M2. Negative admission tests cannot tell why a fixture was rejected.** (pre-existing design; both skeptics upheld the facts; the reproduction skeptic rates the consequence low)

- `src/silver.adb:375` and `:381` are the only rejection emitters, both
  printing `Rejected: source is outside the Silver catalogue.` with status 2,
  for over-length sources, lexical slips, name errors, leaf counts and
  capacity alike. Reproduced for a `Put_Lin` typo, a 17-leaf concatenation,
  a duplicate name and an empty file.
- `tests/test_common_expressions.py:27`, `test_shared_bindings.py:46`,
  `test_copy_values.py:63` and `test_composed_results.py:69` assert only
  `returncode == expected`; no file under `tests/` mentions `Rejected`.
  Of the 139 distinct rejected fixtures these modules produce, 72 are valid
  Ada (rejected purely by Silver policy, reason unverifiable) and 67 are
  invalid Ada (GNAT fails each for exactly the reason the fixture is named
  for). All 168 admitted fixtures compile under `-gnatc`.
- The capacity/boundary methods pin their reason through an adjacent admitted
  sibling (e.g. `test_shared_bindings.py:127-137`); the name, initialization
  and mutability methods (`:104-125`) do not. The implementer's
  `validation-summary.md:32` records one stale rejection fixture and one
  incorrectly constructed positive fixture in this very increment — and note
  the asymmetry: a stale negative that becomes admitted is caught, a negative
  rejected for the wrong reason is silently green, which is the direction
  that hides a rule relaxation.
- **Fix.** See §0 item 2.

### 3.2 Low

**Proof statement strength and correspondence**

- **L1. The source-shape pins in `ComposeSourceChecks.lean` were refreshed by an untracked one-shot script, and no tracked record says so.** The medium
  framing (a contradiction of the trusted boundary) was refuted; the narrowed
  claim survived both skeptics. `tmp/update_common_source_checks.py` is
  untracked, lexes HEAD `src/silver_output_profile.ad?` with the tracked
  Python candidate lexer, regex-fills every `expectedTokens "…"` pin in the
  `7547b3d` file and reproduces HEAD byte for byte; re-running it on the
  committed file is not idempotent (+78/−4). It is named only in the untracked
  checkpoint files; the module header (`:1-12`) has no generation note. The
  kernel checks every pin and the pin diff was committed with the source diff,
  so this is provenance, not soundness. Track the script or record the
  derivation in the module header and the capability record.
- **L2. The facade theorems no longer carry the null-profile source check.**
  `ComposeSourceBridge.lean:21-33` `CheckedSource` inherits only the
  Lexical → Arguments → Named → Output chain, which has no
  `Silver.SourceBridge.CheckedSource` field; `:111-120` and `:125-133`
  conclude only the composed `CheckedSource`, discharging the null half via
  `Silver.Expressions.member_implementation_iff nullCalls nullEquations`.
  `d375aec:GuardedSourceBridge.lean` conjoined
  `Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧ …` (lines 184, 231,
  244, 260). `SourceBridge.checked_source` is still proved and audited, but no
  facade statement, build or audit would change if it were weakened. Two lines
  restore the `d375aec` strength.
- **L3. The guarded shape lost its current-language witness; no theorem says the old forms are instances.** Five example modules migrated to
  `example_current : Current.Member exampleSource`, but
  `proof/Silver/GuardedExamples.lean:14` still pins only `Guarded.accepts`,
  which is no longer a disjunct of `Current.Member` (`Current.lean:17`). No
  file relates `Output/Named/…/Branching.Member` to `Compose.Member`;
  monotonicity is reviewer evidence only (§2).
- **L4. No committed Lean program-level boundary witnesses.**
  `ComposeExamples.lean` (118 lines) pins only expression-level limits
  (`:39-42` sixteen/seventeen leaves, `:47-51` 2048/2049 capacity). Nothing
  evaluates `withinWorkBudget` at 30/31, a 4096/4097-byte source,
  `maxBindings`, or CR/LF/tab/comment-at-EOF variants through the recognizer.
  The constants themselves are pinned by `decide +kernel`
  (`ComposeSourceChecks.lean:147`, `:366`, `:372`; `ComposeEquations.lean:377`).
- **L5. Membership is defined through the Boolean scanner.**
  `ComposeGrammar.lean:152` (`scanned`), `:570-572` (`FormMember` with
  `withinWorkBudget`), `ComposeSemantics.lean:152-168` (`ExpressionTailAt`
  over `expressionStep`): shell-token stepping, expression structure,
  declaration layout and the operator budget have no scanner-independent
  statement of the grammar in `language.md`. The payload layer (`ValueAt`,
  `IdentifierAt`, `Output.LiteralAt`) is relational.
- **L6. `Is_Argument_Form`/`Is_Assignment_Form` are tied to the Lean flag tables only by reading.** `ComposeSourceChecks.lean:220-223` pin the Ada
  bodies as token text; `finite_mapping` (`:260-267`) never mentions
  `Form.hasArguments`/`hasAssignment`; `ComposeExpressions.lean:516`,
  `:546-548` render them. An Ada-side edit fails the text pin; a Lean-side
  edit of the tables can diverge silently.
- **L7. The Ada-to-Lean interpretation premise does not name the constructs the typed trees now interpret:** Ada 2022 delta aggregates
  (`ComposeExpressions.lean:454-456`, used by every `state*` constructor at
  `:536-543`), record aggregates (`:451-453`), field selection, quantified
  expressions over `Form_Kind` and `in` range membership — none occur at
  `d375aec`.

**Report policy and catalogue**

- **L8. Assigned/Selected policies accept a bare Main report with no advisory, no check and no dependency; Static/Argument reject it.**
  `src/silver_library_reports.adb:1311-1312` (ghost) and `:1386-1387`
  (executable) require a nonempty flow list only for
  `Binding_Main | Argument_Binding_Main`; `:1318-1324`/`:1393-1399` require
  empty proof and assumptions for all four bare kinds;
  `Application_Report_Policy` (`:1353-1356`) routes Assigned/Selected through
  the bare kinds first. Reproduced with the probe binary: the genuine
  anchored-static-equality report with `flow` set to `[]` is rejected for
  static and main and **accepted for assignment and selected**.
  `scripts/check_evidence.py:211` mirrors the asymmetry and
  `tests/test_library_reports.py:198-199`, `:328` pin it. None of the 282
  retained `main.spark` files has the shape (every bare report carries a
  warning, because GNATprove emits the Main `CLAIM_EFFECTS` dependency
  whenever flow emits none). `assurance.md:468-473` documents the allowance,
  so this is a documented permissiveness and a tightening opportunity, not a
  misstatement; pre-existing for `Assignment_Main`, inherited by the new
  `Selected_Binding_Main`.
- **L9. Catalogue `count` fields are stale for branching shells.**
  `src/silver_catalogue.adb:146` (`named_output`) and `:231`
  (`concatenated_output`) emit `"count": 1` (`catalogue/silver.json:108`,
  `:193`), but since `96b98e1` both branches admit `expression_output`, so a
  program legitimately contains two such outputs. Introduced in this range.
- **L10. `samples/manifest.json` tags the two capacity-guarded samples
  (`composed_result.adb:8`, `common_expressions.adb:10`) as `input_guard`,
  and tags `string_concatenation` inconsistently across samples using `&`.**
  No script keys off these tags; it is a spec/catalogue/sample agreement
  defect only.

**Specification and documentation of what is supported**

- **L11. `roadmap.md:425-427`** (under a present-tense "Supported" heading,
  `:402-404`) says the capacity must equal 4096 minus the prefix and suffix
  lengths; `language.md:278-279` and the compiler (`Fits`) admit any smaller
  capacity. Specification, catalogue and compiler agree; the roadmap violates
  its own update rule (`roadmap.md:611`, `AGENTS.md:28`).
- **L12. `roadmap.md:569-570`** says repeated references, literal-only
  concatenation, additional declarations and assignment "remain excluded";
  all four are admitted at HEAD (only "arbitrary" concatenation remains
  excluded).
- **L13. The `## Milestones` table (`roadmap.md:244-261`)** has no row for
  the common-expression increment or `samples/common_expressions.adb`,
  the only one of the twelve manifest samples without one; the capability is
  recorded complete elsewhere in the file.
- **L14. `README.md:253-254`** still names `shared-bindings.md` as "the
  current shared-binding capability"; the evidence section never cites
  `docs/common-expressions.md`, which `language.md:4-5` and `RESUME.md:12`
  name as the current checkpoint.
- **L15. `docs/language-generalization.md:12-13`, `:20-23` (and `:35`)**
  still say shared bindings and common expressions are "next proposed" and
  "unimplemented"; `RESUME.md:155-158` says "Implement the shared
  binding/expression foundations next", contradicted by `RESUME.md:17`.
- **L16. Guard-clause restrictions without a stated purpose in the
  specification.** `language.md:272-276` states the canonical-decimal rule,
  the original-`D`-only capacity reference (new in `7547b3d`) and the
  no-reorder/negate/extend rule with no purpose and no cross-reference. The
  Oracle bullet added in `640d5cc` (`oracle.md:19`) requires one. The
  canonical-decimal and no-reorder rules are classified as staging
  restrictions in `docs/restrictions-capacity.md:71-82`; the original-name
  rule has no documented purpose anywhere. `silver check` rejects `4_088`,
  `16#FF8#`, `4E3` and `04088` (`src/silver_output_lexical.adb:90-128`),
  all legal Ada spellings.
- **L17. Parenthesis depth: the admitted maximum is not exercised.**
  `language.md:142-143` and the catalogue (`silver_catalogue.adb:347`) bound
  depth only by source size; with the test skeleton that is depth 2001
  (admitted; 2002 rejected at 4,098 bytes). The permanent test is
  admission-only and the preserved native evidence stops at 1900
  (`common-expressions.md:54`, accurate as stated). The frontend premise at
  `trusted-boundary.md:49-55` should name parser nesting.

**Tests**

- **L18. Five new trust-relevant native Lean tests skip with exit status 0 when the pinned Lean is absent**, while the SPARK-side tests raise
  (`tests/test_silver.py:33-34`): `test_lean_modules.py:20-21`,
  `test_lean_source.py:181-182` (the only behavioural pin that a false
  `kernel_exact` witness is rejected), `test_lean_evidence.py:820-821`,
  `:876`, `:930`, `:980`. `dev.py test` (`scripts/dev.py:198`) does not
  account for skips and the capability records report "methods covered"
  without a skip count. The dormant `verify.yml:39` native job installs no
  Lean and `:79` runs only `test_lean_evidence.py`, so neither job would ever
  execute them — pre-existing (the workflow is unchanged since `56688060ab`)
  and accurately documented as disabled.
- **L19. `verify.yml:69`, `:80`** still describe a replay and fresh kernel
  recheck that `:83` (`check_lean.py --clean`, "does not imply replay",
  `check_lean.py:341-342`) does not perform — previous L5, deferred with a
  stated reason at `platform-coexistence.md:109-110`.
- **L20. `tests/test_silver.py:77`** has been a one-directional subset check
  (`{"string_expression","expression_output","result_branch"} <= …`) since
  `96b98e1`; at `d375aec` it pinned the full inventory. Nothing else pins the
  23 construct ids or compares them with `language.md`'s capability table.
- **L21. Uncovered rule positions.** The seventeen-leaf negative exists only
  in output position (`test_common_expressions.py:126`,
  `test_shared_bindings.py:133`, `test_composed_results.py:111-112`); no test
  rejects a capacity clause bound to an alias of `D` (`language.md:275`) or a
  second `First_Or_Default` declaration (`language.md:113-115`); `D` as an
  assignment target is rejected only in a confounded case
  (`test_branching.py:111`). All probed correct at HEAD.
- **L22. `96b98e1` removed the `absent`/`duplicate`/`extra_reference`/`advisory` dependency-reference cases from the native dependency-shape test** without a recorded rationale. (The flipped
  duplicated-advisory assertions at `test_library_reports.py:242-243`,
  `:349-350` follow the documented "finite lists" generalization,
  `assurance.md:457-466`, `language.md:456`, and are not a defect.)
- **L23. Seven near-verbatim `compile` helpers** (`test_common_expressions.py:
  30-47`, `test_shared_bindings.py:49-66`, `test_copy_values.py:169-187`,
  `test_composed_results.py:147-165`, plus three older modules) and the
  program workspace leaks when a compile fails before `addCleanup` runs.
- **L24. The retained-trace bypass check has no positive assertion.**
  `check_lean.py:64-72` only runs the negative regex over `*.trace`; a trace
  with no `log` passes silently. Its only test
  (`test_lean_evidence.py:386-401`) hand-writes the fixture, so Lake's
  persistence of `weakLeanArgs` is unpinned. (113 of 114 live traces carry
  `-j12 -M16384`; `AxiomAudit.trace` carries `-j12 -M12288`.)
- **L25. No repeatable test evaluates Lean `Current.accepts` and the built `silver check` on a shared corpus**; model-versus-binary agreement is
  one-off reviewer evidence, and the Lean example witnesses and native sample
  tests use disjoint inputs.

**Evidence and process**

- **L26. `check_evidence.py` rejects the retained HEAD evidence on this host solely because it hash-pins the OS interpreter.**
  `scripts/proof_provenance.py:169-172` exempts `python` from the
  `host.tools` location rule but still requires its binary sha256;
  `python3 scripts/check_evidence.py` prints `proof evidence rejected: proof
  tool changed: python` (exit 1) although every input, report and Alire-tool
  hash matches. The record was made with the Jun-18 build of 3.14.4; this host
  has the Aug-20 build, and the retained manifests alternate between the two
  (Oct 11 13:57, Oct 11 18:09, Oct 12 18:40, Oct 13 16:09). The test fixture
  (`test_proof_provenance.py:44-51`) places `python` under `host.tools`, so
  the real layout is untested. Pre-existing (`8b8619f`). Validate by version,
  or state the designated environment in the record.
- **L27. The full test run overlapped the final proof edits, and its input capture excluded `proof/` and docs.** The suite ran 16:10:29–16:24:53Z;
  `ComposeSourceChecks.lean` was rewritten at 16:13:03, `language.md` changed
  at the same second, and both `Output*Certificate.lean` were replaced at
  16:19:12 (mtimes preserved at 15:59:21). The wrapper (`full-tests.py:8`)
  hashed only `src/scripts/tests/samples/catalogue`, so
  `common-expressions.md:152` ("inputs stayed unchanged") is accurate as
  scoped but omits that a handwritten proof module changed mid-run. My clean
  run at HEAD (§2) settles the evidence question; the record should say what
  was and was not captured.
- **L28. Machine-specific paths and dependence on untracked `tmp/`.**
  `docs/copy-values.md:33` and `docs/session-memory.md:487` (`e9d18f1`) embed
  `/home/canto/.local/state/silver/host-handover-2026-10-11-s_qucqpv/handover.json`,
  unreachable from any checkout, against the project's own rule
  (`session-memory.md:1906-1907`, `AGENTS.md:53`); `host-readiness.md:33` is
  pre-existing. `common-expressions.md` designates
  `tmp/common-expressions-active.json` as the evidence pointer; `tmp/` is
  untracked, un-ignored and ~26 GB.

**Bookkeeping of earlier dispositions**

- **L29. `src/silver_reports.ads:10-12`** still says "Both admitted
  application units have this empty-check report shape", and the deferral
  reason recorded at `input-branching.md:175` was already wrong when written:
  `Complete_Null_Proof` has served only the null program since before
  `767a33c` (`silver.adb:284-287`, `:378-386`).
- **L30. A deferral trigger fired without a revisit.** `lean-iteration.md:115`
  deferred the I4 header conjuncts "until that source/bridge is next
  changed"; `OutputSourceBridge.lean` was rewritten in `96b98e1` and
  re-headed in `15ca622` with no new disposition. (The headers are in any
  case covered by the whole-file shape pin, `ReviewedOutputShape.lean:36`, so
  the explicit conjuncts would be redundant locality pins.)
- **L31. The "fixed and validated" `is_assignment_member` header conjuncts
  (`767a33c`) were deleted with `AssignmentSourceBridge.lean` in `96b98e1`.**
  The successors `Is_Member`/`Has_Arguments`/`Has_Assignment`
  (`silver_output_profile.ads:53-61`) have their spec `;` headers and
  `Post` links pinned explicitly (`ComposeSourceChecks.lean:414-416`) but
  their ghost declarations only through the whole-file shape; no disposition
  records the change.

### 3.3 Info

Verified by both or one skeptic:

- **I1. The Lean obligation stream is run-time-safety only.** Only
  `.runTimeSafety` is ever constructed (`ComposeObligations.lean:272`,
  `GuardedObligations.lean:108`); `.initialization`/`.dataFlow`
  (`Semantics.lean:168`) are dead constructors, and the modeled tool interface
  (`Current.lean:245-284`) refines range/length schemas only. Bronze flow
  freedom rests on `Readable`/`DeclarationsValid` (`Bindings.lean:201`,
  `:409-413`) plus the native warning-only flow policy. No document
  overclaims (`assurance.md:348-368`, `trusted-boundary.md:39`); one
  sentence saying so would help.
- **I2. `automaticDischarge` is program-independent** (`Current.lean:80-94`:
  a closed uniform obligation list); the substantive claim is
  `all_obligations_discharge` (`:110-123`), which `admitted_assurance`
  (`:221-231`) conjoins with it and `every_meaning_assured` (`:233-243`) uses
  alone. The doc comment at `:86-88` already says this.
- **I3. Acceptance never requires a safety-check or dependency record**
  (`List_Policy :969-977`, `Dependencies_Spec :1050-1053` are vacuous on empty
  lists). This is the documented faithful-generation premise;
  `assurance.md:470-473` is accurate; only `silver_library_reports.ads:38-39`
  ("All other shapes retain approved call dependencies") overstates.
- **I4. The fourteen `src/` units outside the Lean chain** (`silver.adb`,
  `silver_libc.ads`, and the `silver_catalogue`, `silver_libraries`,
  `silver_library_reports`, `silver_numbers`, `silver_platform`,
  `silver_reports` pairs) are not listed as such in the trusted boundary;
  `assurance.md:407-408`, `:436-437` cover the driver at theorem level.

Refuted as stated; what remains is awareness:

- **R1. `how_proved = "prover"` for Main checks.** The gate
  (`silver_library_reports.adb:836`, `:904`; `check_evidence.py:286-288`) is
  pre-existing (`96b4e3a`) and documented as "prover completion"
  (`trusted-boundary.md:493-496`, `assurance.md:450-452`, empty lists
  permitted); no admitted program produces a non-prover Main record (§2).
- **R2. Frontend warnings.** Acceptance does not rest on the default `-gnatw`
  set: gnatprove 16.1 forwards no frontend warning into `main.spark` or its
  exit status even with `-gnatwa` forced, gprbuild warnings do not fail the
  build, and `trusted-boundary.md:538-539`, `assurance.md:513-515` already
  disclaim frontend warnings.
- **R3. The kernel-bypass scan's metaprogram residual.** A fragment-built
  `debug.skipKernelTC` inside `run_cmd` (also in `module` form with
  `public meta import Lean`) passes the scan and the real `#silver_audit` and
  is rejected only by `leanchecker --fresh` — confirmed natively — but this is
  exactly the residual stated at `check_lean.py:54`,
  `trusted-boundary.md:704-705`, `development.md:211`, `assurance.md:582-583`
  and `lean-modules.md:127-128`, and the increment did not widen it.
- **R4. Thirteen of seventeen commits have subject-only messages**, including
  the three largest proof-carrying commits, and `767a33c`'s subject omits the
  review dispositions it contains. There is no commit-message policy.
- **R5. The Oracle edit (`640d5cc`).** "Checked automatically in CI" became
  "during project validation" under a general owner instruction; enforcement
  did not change (hosted CI was already disabled; `check_lean.py` is the
  mandatory last step at `development.md:170-177`), but no sentence ties the
  new wording to that step.

### 3.4 Unverified reviewer observations

Not independently verified; ✓ marks the ones I confirmed by inspection.

- ✓ `silver catalogue` output differs from `catalogue/silver.json` in bytes
  (char 21000, line 763) though equal as JSON; the README regeneration
  instruction would produce the differently formatted file.
- ✓ `docs/lean-concurrency.md:75` cites `Silver.GuardedSourceBridge`, deleted
  in `96b98e1`, without marking it historical.
- ✓ `language.md:51-52` calls copy-values the "preceding" checkpoint (the
  preceding one is shared bindings); its sample list omits the four newest
  samples.
- ✓ `GuardedObligations.lean:8-15` docstring still describes the retired
  two-schema prefix/name/suffix grammar.
- ✓ `check_lean.py:507-510`: `--clean --target` records `mode: "clean"`; the
  focused marker survives only in `scope` and the file name.
- ✓ `Application_Report_Policy` has a default `Kind := Argument_Output`
  (`silver_library_reports.ads:13`, `:41`); the driver passes it explicitly.
- ✓ The real `#silver_audit` regression (`test_lean_evidence.py:817`) covers
  private axiom, `sorry`, native evaluation and imports, not an audit-process
  `-Ddebug.skipKernelTC` run against `AxiomAudit.lean`'s own guard.
- `docs/input-branching.md:104` says 16 units/215 entities for the 3,029
  baseline; the retained report reportedly has 17/216.
- Recognizer dead state: `Value_First` is always 0 and a `String_Literal`
  step branch is unreachable; the Lean model mirrors both.
- Declared names that hide `Standard`, `Boolean`, `True`, `Put_Line`, … are
  admitted and compile (confirmed by the differential) but no native test
  covers them, and `language.md` does not say they are legal.
- Constant-equality advisories are tolerated for every argument-bearing
  program, not only shells containing an equality.
- The Python evidence helper accepts multi-location entities that the native
  policy rejects.
- The library-reports probe harness reads one line, so GNATprove's multi-line
  layout reaches the native checker only through full compiles.
- `maxSourceLength = 4096` is tied to the Ada literal `4_096` only by
  reading, unlike `Runtime.maxLength`.
- Runner-side rejections leave no reason in the retained log.
- The unused-initializer native test asserts only a lower bound on flow
  records.
- Roadmap labels a superseded restriction inventory the "current
  assessment"; the audit record still says the language "remains six output…".
- The catalogue expresses the one-terminal-output rule with three different
  count keys and omits `outer_guard` on `result_branch`.
- The shared-bindings full test run has no start-of-run input capture, and
  its test file was edited after the run.
- The optional end designator (`end;`) is excluded with only a "deliberate
  scope" classification.
- The sample manifest checks only that a spec fragment is non-empty; two
  samples cite a generic section.

## 4. Probes and experiments

- **Vacuity (M1).** Lean probe outside the workspace (`module`,
  `import Silver.ComposeSourceBridge`, `lake env lean`) printing the statement
  of `authoritative_current_member_iff`: the `InterpretedSource calls`
  hypothesis is present; `grep -l InterpretedSource …/.lake/build/lib/lean/
  Silver/*.ilean` lists only the retired per-form modules and the two Compose
  files.
- **Rejection message (M2).** `Put_Lin` typo, 17 leaves, duplicate name,
  empty file: identical message, exit 2; 16 leaves: `Accepted: silver.`.
- **Bare report (L8).** Probe binary rebuilt from HEAD `probe.gpr`; the
  genuine `anchored-static-equality-true` report with `flow := []`:
  static rejected, main rejected, assignment accepted, selected accepted.
- **`how_proved` (R1).** Four compiles (§2); records listed from the newest
  `.silver/program-*/obj/gnatprove/main.spark`; the only three `trivial`
  records under `.silver` are error records from an old aarch64 experiment.
- **Frontend warnings (R2).** `gcc -c -gnatc -gnat2022 -gnatwa` warns
  (`-gnatwc`, `-gnatwr`, `-gnatwu`); the project switches do not; gnatprove
  16.1 with `-gnatwa` added to the project and via `-cargs`: no warning in
  output, exit 0, `warn_error: []`, flow list unchanged.
- **Metaprogram residual (R3).** Fresh `.olean` build of a module setting a
  fragment-built `debug.skipKernelTC` inside `run_cmd`: passes
  `check_proof_policy`, compiles with `-DwarningAsError=true`, passes
  `#silver_audit`, rejected by `leanchecker --fresh`.
- **Python pin (L26).** `python3 scripts/check_evidence.py` → exit 1,
  `proof tool changed: python`; independent snippet: inputs match, reports
  match, ten Alire tools match, `audit_sources` → 2,602 checks.
- **Pin reproduction (L1).** `git archive 7547b3d` of `ComposeSourceChecks.
  lean` + HEAD `src/` + the script, in scratch: `REPRODUCED-BYTE-FOR-BYTE`;
  second run on the committed file: +78/−4 lines.
- **Depth (L17).** Depth 2001 (4,096 bytes) admitted; 2002 (4,098 bytes)
  rejected.
- **Decimal spellings (L16).** `4088` admitted; `4_088`, `16#FF8#`, `4E3`,
  `04088`, `4097` rejected.
- **Skip accounting (L18).** With the Lean layout hidden,
  `tests.test_lean_modules` reports `OK (skipped=2)` and `wasSuccessful()`.

## 5. Carry-over from the three previous reviews

| Item | Status at `9b72d36` |
| --- | --- |
| d375aec M1 kernel bypass (module-level, lakefile, cached trace) | **Fixed.** Scan before workspace preparation and after each phase; trace scan; exact single-use `AxiomAudit` exemption; four policy tests pass. |
| d375aec L1 final reports and dispositions | **Done.** Reports retained unchanged (`26737d9`); dispositions in `lean-iteration.md`, `string-assignment.md`, `input-branching.md`. Three of them no longer match the tree: L29–L31 above. |
| d375aec L2 default-mode drift and no-kill mutants | **Fixed.** The two surviving mutants of the 1ed039e review now fail the suite; the kill/reap test exists. |
| d375aec L3 `Audit.lean` name pins | **Declined with a stated reason**; L2 above shows the same concern now applies to a correspondence conjunct. |
| d375aec L4 real `#silver_audit` regression | **Added** (five rejection classes; the audit-process `skipKernelTC` case is not among them). |
| d375aec L5 stale replay text | **Deferred with reason** (`platform-coexistence.md:109-110`); text still stale (L19). |
| d375aec L6 SPARK evidence binding wording | **Fixed**; the HEAD record is content-bound (§2). |
| d375aec L7 `include_str` confinement | **Fixed**, with a test. |
| d375aec I4 output-side header conjuncts | **Deferred until the bridge changes**; it changed twice without a revisit (L30). |
| 1ed039e L1 `is_assignment_member` header conjunct | **Fixed in `767a33c`, then deleted in `96b98e1`** with the per-form bridge (L31). |
| 1ed039e L3 in-place byte drift; L4 branching rows; L5 stale text | Fixed; fixed; the `silver_reports.ads` comment remains (L29). |
| 44fd8ea L1 existing-clone guidance; L2 premises in one place | Restored verbatim in `RESUME.md`; the static-elimination and observed-shape premises are stated in `trusted-boundary.md` and `language.md` no longer asserts elimination as fact. |
| 44fd8ea L4/L5 helper mutants and junk-name rows | Confirmed by the 1ed039e review (0/9 mutants survive); not re-run here. |

## 6. Side effects and state

- **New.** `.silver/program-*` directories from the full test run and ~40
  probe compiles; scratch, corpora, probe binaries and agent notes under the
  session scratchpad only (not under `tmp/`).
- **Unchanged.** All tracked files, `.tools/`, `.silver/linux-x86_64/proof`,
  `tmp/`, Git refs, index and stash. This file is the only addition to the
  working tree and is uncommitted.

## Appendix: commands

```text
git diff --stat d375aec..HEAD
python3 scripts/dev.py test                                   # 256 OK, 825.7 s
python3 -m unittest tests.test_evidence tests.test_lean_evidence tests.test_proof_provenance \
    tests.test_platforms tests.test_lean_source tests.test_argument_bounds
.silver/linux-x86_64/compiler/bin/silver check <probe.adb>    # corpus of 13,730 sources
.silver/linux-x86_64/compiler/bin/silver compile <probe.adb>  # ~40 targeted compiles
<lake> env <lean> /scratch/probe.lean                          # from .silver/linux-x86_64/proof; #eval Silver.Current.accepts, #check theorems
gcc -c -gnatc -gnat2022 [-gnatwa] main.adb                     # Alire gnat_native 16.1.0, with src/*.ads beside it
python3 proof/generate_source_certificate.py … <scratch>       # byte-compare against proof/Silver/*Certificate.lean
python3 scripts/check_evidence.py                              # exit 1: proof tool changed: python
git archive d375aec | tar -x -C <scratch>/old && gprbuild -P silver.gpr   # old recognizer for monotonicity
```
