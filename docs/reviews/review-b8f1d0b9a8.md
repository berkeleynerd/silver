# Review of b8f1d0b9a8, "Deliver For loops and integers (#47)"

Reviewed 2026-10-16/17 on the Linux x86-64 development sandbox (22 CPUs, 31 GiB,
no swap), the project's primary platform, read-only on tracked files, from a
detached worktree at `b8f1d0b9a8`, the merge of PR #47 into `main`. The merge
has two parents, the baseline `7c7a3a716d` (the merge of PR #46) and the
delivery commit `65de28b64e`; its tree is byte-identical to the delivery
commit's tree. The feature side carries 196 commits, all made on 2026-10-16
between 13:49 and 20:36 UTC. The diff against the baseline is 2,118 files,
+91,565/−22,538 lines: `proof/Silver` +76,906/−17,060 in 296 files (206 new
modules, 93 modified); 26 SPARK units in `src/` (16 new); 15 test files; 24
documents and evidence files; three samples; and the Rosetta render, where
1,738 assessment pages change their progression line or a heading and three
driver assessments change in substance.

This review was requested as a comprehensive, independent review of the
completed milestone. It treats the delivery's own review
([review-410ed2c](review-410ed2c.md)), its validation record and its passing
runs as evidence to examine, not as conclusions. It authorizes no repair and
changes no tracked file, issue or board entry.

## 0. Verdict

**No blocker.** The delivered fragment does what the language, catalogue and
capability record say: immutable signed-32-bit Integer constants, grouped
`+`, `-` and `*`, comparisons, scoped forward and reverse loops and standard
`Integer'Image` with Ada's leading space, composed with the existing String,
input, path and output rules. Admission is decidable from source bytes; every
accepted probe program was legal Ada under the GNAT 16.1 frontend; the
interval, Image-length and loop rules were re-derived by hand, brute-forced in
transcription and read against the Lean theorems; and eleven targeted compile
probes of edge-case programs (extreme images, null and uncertain loops, a
4,096-byte concatenation, 64 leaves, equality refinement, a maximal
operator-budget undercount, and an argument-shell loop with `Reject`, a scalar
comparison, partial output and an assignment used after the loop) all proved,
built and ran.

**Assurance completeness.** The Image proof-model adapter is necessary (the
vendor model gives only an upper bound on `to_string`), semantically valid
(the installed axiom is true of Ada's `Integer'Image` at every threshold and
both extremes, consistent with the vendor axioms at size 12, and never a
premise anywhere in the chain), and connected to the actual sources: the
scanner, templates, Files loop and theorem text are kernel-equated to the
delivered SPARK bytes, and every endpoint depends only on `propext`,
`Classical.choice` and `Quot.sound`. The proof tree has no `axiom`, `sorry`,
`native_decide` or other escape hatch. The native audit's recorded inputs and
the complete Lean run's recorded input digest both equal the delivered tree.

**What is wrong.** Fifteen low-severity items survived adversarial
verification; none shows an admitted program failing its guarantee. One is a
code defect that needs repair before the next construct is admitted: the
shared 63-operator budget scanner does not charge a binary `+` written
directly after an identifier ending in a digit and `E` (§3.1, L1), so the
compiler admits programs the specification and catalogue exclude, which
breaks the agreement the Oracle requires and falsifies a premise of the
report-capacity derivation (the derived bound itself still holds). The rest
are record and documentation defects: the validation record names a commit
that is not the executed input set, the full regression run executed a lane
worktree whose `proof/` was not the delivered tree, the complete Lean run
reused about 255 module objects compiled in other worktrees without recording
their provenance, and several sentences overstate what the record holds.
Three low items and the info items are improvements.

**Milestone completion.** The completion claims hold as stated in the
capability record, with the corrections listed in §3. Nothing in this review
warrants reopening the delivered work; L1 is a required follow-up repair of
the recognizer, its Lean mirror and the certificate it pins, and the record
corrections are documentation follow-ups.

## 1. Target, method and coverage

### 1.1 What was reviewed and what was not

- **Reviewed result.** The tree of `b8f1d0b9a8` (= `65de28b64e`), read from
  `tmp/review-b8f1d0b9a8`. Every file reference below is relative to that
  tree unless it names a worktree.
- **Later checkout state.** The shared checkout is on `feat/for-loops-integers`
  at `65de28b64e` with a clean tracked tree; nothing tracked has moved past
  the reviewed result. Later state exists only in untracked or ignored areas:
  `.silver/` (installed toolchain, Lean workspace, program workspaces),
  `tmp/` (36 worktrees) and `.git/silver-runs/` (492 managed runs on
  2026-10-16). Those areas were read as evidence and never modified, except
  that the review's probe compiles added program workspaces under the
  validation worktree's installation (Appendix C).
- **Validation worktree.** The delivery evidence was produced in
  `tmp/for-loops-predicate-source` (HEAD `ab2f7dd5cc` plus uncommitted
  edits). Its `src/`, `scripts/`, `tests/`, `samples/`, `catalogue/`,
  `silver.gpr` and `alire.toml` are byte-identical to the delivery commit; its
  `proof/` is not (§2).

### 1.2 Method

Thirteen reviewers worked in parallel with explicit, disjoint ownership, each
reading the actual source, proof text and retained evidence rather than the
delivery's summaries:

| Lens | Owned scope |
| --- | --- |
| LC-1 | specification, catalogue, exporter and recognizer agreement; Ada legality of accepted programs |
| LC-2 | interval arithmetic, Image lengths, loop semantics; admitted-program proof behaviour |
| IA-1 | the adapter's SPARK implementation, installer, overlay, bootstrap and provenance |
| IA-2a | adapter proofs: scanner interpretation, JSON meaning, templates, document refinement, byte recovery |
| IA-2b | Integer Image theorem, consumer boundary, theorem installation, native Files endpoints; necessity and semantic validity |
| UA-1 | scalar literal, expression, interval and iteration proofs and their source bridges |
| UA-2a | Predicate layer: loop execution, obligation inventory, discharge, endpoint correspondence |
| UA-2b | Compose, Sequence and String composition; the scalar-environment repair; the audit's scope |
| UA-3 | source-correspondence machinery: bindings, certificates, generator, Lake inputs, runner reuse |
| NP | native proof evidence, report policy, projection, provenance, diagnostics, repairs #48–#50 |
| TE | tests and evidence validity; evidence-to-input correspondence |
| EQ-1 | engineering quality and proportionality |
| EQ-2 | documentation, samples, Rosetta, tracking and completion claims |

Their 57 candidate findings were merged into 35 items (duplicates across
lenses collapsed) and every item was then verified by independent verifiers
whose default stance was to refute: one reproduction verifier per item, a
second requirement-and-boundary verifier for questions and uncertain items,
and a third verifier for the two items a reviewer had rated blocker (52
verifications). A completeness critic read all thirteen reports and looked
for risks no lens had examined; its two remaining checks were run by the
orchestrator (Appendix A). Section 3 reports only what survived, with the
verifiers' verdict on each item; §3.5 lists the candidates that were refuted
and why, so that later reviews do not repeat them.

### 1.3 Tools and the rule on reruns

The owner's standing rule applies: no Lean rebuild, kernel replay, GNATprove
audit or full test run was performed. Every check was targeted and recorded
with its hypothesis before it ran (Appendix A). The review used:

- the compiler and adapter binaries built from the delivered sources at 20:06
  UTC in the validation worktree (`silver` sha256 `55012b72c4fd…`,
  `silver_image_adapter` sha256 `afd2095794b1…`; the root installation's
  binary, built at 16:25, predates the final sources), for `silver check`
  admission probes (instant, side-effect free) and eleven `silver compile`
  probes run one at a time under a lock;
- a frozen copy of the root Lean workspace whose sources equal the delivered
  `proof/` tree, for read-only `#check`, `#print axioms`, `#eval` and small
  `example` and `decide +kernel` probes against the compiled objects;
- the retained managed runs under
  `.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`: the native audit
  `20261016T200519-b3b644edcb13`, the failed native audit
  `20261016T174150-cf80d84be8db`, the complete Lean runs
  `20261016T200453-9fe1b554e036` and `20261016T183420-1c5451b2e0df`, the build
  `20261016T200635-f7611c4d608c`, the full test run
  `20261016T200650-91510d356211`, the focused recheck
  `20261016T202127-4facdb2ce8b3` and the earlier focused runs the record cites;
- the installed GNATprove 16.1.0 (vendor `gnatwhy3`, Why3 theories, drivers
  and the shipped Lake source under `.tools/linux-x86_64/lean/src`), the
  pinned producer sources retained under
  `tmp/review-capacity-343c2f8/tmp/producer-source`, and the retained
  readable models under `tmp/integer-image-native/tmp/image-probes/`;
- GitHub, read-only, for issues #10–#16, #34, #48–#50, milestone 1, PR #47
  and the board.

### 1.4 Limitations

- No clean native or Lean rebuild and no independent kernel replay exist for
  the delivered inputs, and none was run here; every proof conclusion below
  rests on the delivery's cached runs plus this review's read-only probes.
- The review worktree has no native toolchain layout. Test modules that only
  read files were run there; the modules that spawn the compiler or
  `gprbuild` (`test_report_projection`, `test_output_integrity`,
  `test_library_reports`, `test_samples`, `test_silver`) were not rerun.
- Vendor behaviour was checked in the pinned source checkout and against the
  installed binaries' observed behaviour; no binary-source attestation exists.
- macOS and hosted CI results are not claimed by the delivery and were not
  examined.

## 2. Evidence-to-input correspondence

The delivery's validation record names commits that are not the inputs the
runs executed. The review established the actual correspondence by hashing:

| Evidence | Inputs actually used | Relation to the delivered tree |
| --- | --- | --- |
| Native audit `20261016T200519` (15,083 checks, 74 units) | 2,518 recorded inputs in `proof-evidence/proof-inputs.json`; 140 of them repository files (all 128 `src/` files, nine scripts, `silver.gpr`, `alire.toml`, `proof/silver_proof_containers.gpr`) | **All 140 hash-equal the delivered blobs.** The run covers the delivered sources, including `src/silver_catalogue.adb`, which was committed only in `65de28b64e` (L3). |
| Complete Lean run `20261016T200453` (458 modules, 87,185-declaration audit) | the root workspace's proof sources; `inputs_digest_sha256 15412eec1ffa…` | **The digest recomputed over the delivered tree equals the recorded digest** (emulation of `check_lean.py` `capture_shared_inputs`: 572 files, 432 non-candidate modules, lakefile, toolchain, generator, 128 `src/` files, nine scripts). The four certificates refreshed in `62f472c35d` equal the workspace bytes that run built. A `git archive` of the named commit `4cd2fe8aae` gives a different digest (`a6be3957…`). |
| Compiler and adapter build `20261016T200635` | `src/` of the validation worktree | identical to the delivered `src/`; the built binaries are the ones the test run and this review used |
| Full test run `20261016T200650` (450 tests, 4 failed subtests) | the validation worktree: `src/`, `tests/`, `samples/`, `scripts/`, `catalogue/` plus its `proof/` tree | native inputs identical; **`proof/` differs: of 462 delivered proof files, 39 recorded ones differ (35 modules plus the four then-stale certificates) and 119 delivered modules are absent** (all `ImageModel*`, `ImageFiles*`, `Image*Endpoint`, `IntegerImageNative*`, `LengthInterval{Model,Precedence}`, `LengthIntervalsSource`); see L2. |
| Focused recheck `20261016T202127` (26 certificate pairs) | the root checkout | all 668 recorded repository inputs equal the delivered tree |
| Lean objects behind the complete run | 459 `.olean`/trace pairs in the root workspace | 202 compiled in the root workspace (plus two stale probe traces outside the 458-module build), 176 in `tmp/for-loops-header-resume`, 60 in `tmp/for-loops-image-length-intervals`, 12 in `tmp/for-loops-image-model-proofs`, 7 in `.silver/linux-x86_64/branches-20261013T234331Z`; the final run elaborated 11 modules and accepted the rest through Lake's `--rehash` trace matching (L4). |

Two consequences for how the delivery should be read: the native and Lean
evidence does apply to the delivered inputs, which is the favourable
direction, but the commit named as the executed snapshot does not reproduce
either digest; and the full regression run is evidence for the delivered
native code, tests and samples, not for the delivered proof tree.

## 3. Findings

Severity follows the project's reviews: *blocker* when the Oracle guarantee or
a completion claim fails for some admitted program or the evidence does not
cover the delivered inputs; *low* for a real defect, gap or misstatement
without a demonstrated guarantee failure; *info* for an observation. Each
item names the reviewer finding(s) it merges (Appendix B) and the verifiers'
verdict.

### 3.1 Blockers

None.

### 3.2 Low: confirmed defects

**L1. The shared 63-operator budget scanner does not charge a binary `+`
written directly after an identifier ending in `<digit>E`.** (LC-1-1, EQ-1-1;
three verifiers: narrowed from blocker to low, high confidence.)

- *Requirement:* O11 (specification, catalogue and compiler must agree; "a
  discrepancy is a defect to resolve, not an extension of the language") and
  O12 (the counting rule of a limit must be explicit): `language.md:358-361`
  ("every `&`, unary or binary `+`/`-`, and `*` … counts … a numeric
  exponent's `+` do[es] not count"); `catalogue/silver.json`
  `program_budget_counts`, `program_operator_budget` and
  `max_program_operators` (63).
- *Location:* `src/silver_output_profile.adb:396-408` (ghost `Work_Tail`) and
  `:414-445` (`Within_Work_Budget`); `src/silver_scalar_literals.adb:179-180`
  (`Exponent_Start` accepts a `+` after `E`/`e`) and `:231-245`
  (`Read_Integer` rejects a numeral only when the following byte is an
  identifier character); the Lean mirror `proof/Silver/ComposeAdmission.lean:209-235`
  (`workTail`) and its interpretation `ComposeExpressions.lean:792-814`;
  the only test, `tests/test_integer_loops.py:103-108`, covers the literal
  `1E+0`. Introduced by `360064af3f`.
- *Evidence:* the scanner calls `Read_Integer` at every non-literal byte,
  including bytes inside identifiers. At the `1` of `N1E+1)` it reads
  mantissa `1`, exponent marker `E`, the `+`, the numeral `1`; `)` is not an
  identifier character, so `1E+1` is consumed as a numeral and the binary `+`
  is never charged. With the delivered binary: 63 copies of
  `if (+N1E)=1 then null;end if;` (63 operators) are accepted; adding
  `if (N1E + 1)=2 then null;end if;` (64, spaced) is rejected; adding
  `if (N1E+1)=2 then null;end if;` (64, unspaced) is accepted. The same holds
  for `(I1e+1)`, `(X_1E+1)`, a loop bound `for I in (N1E+1)..2` and a
  declaration initializer `B:constant Integer:=(N1E+1);`; controls
  `(N1E-1)`, `(N1E*1)`, `(N1E+N1E)` and `N1X+1` are counted correctly. A
  4,074-byte program with 402 arithmetic `+` (340 hidden) is accepted. GNAT
  parses `N1E+1` as identifier, `+`, numeral, so the accepted programs are
  legal Ada. The Lean admission model mirrors the scan (`Current.accepts` is
  true for the hidden-`+` program and false for the spaced one under
  `decide +kernel`), so the recognizer-correspondence proofs could not have
  caught it. A compile of the critic's maximal program (76 hidden `+` in a
  two-iteration loop, 4,068 bytes) exited 0: 300 flow records, 76 Image
  advisories, no proof records (the frontend folded the checks), Main report
  175,779 bytes.
- *Impact:* the admitted language is larger than the published one for this
  rule, and the capacity derivation's premise "at most 63 overflow records"
  (`docs/report-capacity.md:220-229`; `docs/for-loops-report-capacity.md:145-148,
  212`, "all arithmetic AST operators are charged") is false. Its conclusion
  still holds: a hidden `+` needs at least six source bytes, so a 4,096-byte
  source carries at most about 680 of them (354 demonstrated), at most
  1,396,736 bytes of extra records against the 1,748,992-byte headroom. Only
  `+` with a digit right operand is affected; the 64-leaf limit, the interval
  checks and every native obligation are unaffected, and no proof failure is
  demonstrated or mechanistically plausible.
- *Repair (required):* recognise numerals only at token boundaries: in
  `Within_Work_Budget` and `Work_Tail`, when `Text (First)` starts an
  identifier, advance past it (`Name_After`, `silver_output_profile.adb:186`,
  or the ghost `Identifier_End`, `silver_output_lexical.ads:123-132`) before
  trying `Read_Integer`, or accept a numeral only when the previous byte is
  not an identifier character. Change the Lean `workTail`, the interpreted
  equations (`ComposeEquations.lean:115-173`,
  `ComposeModelRecursion.lean:17-27`) and the `ComposeSourceChecks` pin
  together, regenerate the Output certificates, re-prove the focused targets,
  and add tests for `N1E+1`, `I1e+1` and `X_1E+1` in predicate, loop-bound and
  declaration positions at 64 operators (reject) and 63 (accept) with the
  `(N1E+N1E)` and `(N1E-1)` controls. Correct the capacity premise wording.
  About half a day to a day. The repair restores the documented domain and
  suppresses nothing, so it preserves the Oracle; documenting the exception
  instead would tie the budget to spacing and is not recommended.

**L2. The full regression run executed in a lane worktree whose `proof/` was
not the delivered tree, and the record does not say so.** (TE-3, EQ-2-1;
three verifiers: narrowed from blocker to low.)

- *Requirement:* the record must say which inputs a run covered (O8, O14);
  `review-410ed2c.md:383-384` claims the full suite plus the focused repair
  "establishes the repaired regression coverage".
- *Location:* `docs/evidence/for-loops-integers/delivery-validation.json:44-92`
  (records the worktree, not its proof-tree state) and `:533-538`, `:742-750`
  ("204 native inputs", undefined, is exactly the non-proof set);
  `docs/for-loops-integers.md:194-195, 206`; `docs/reviews/review-410ed2c.md:377-384`;
  `roadmap.md:42-44`.
- *Evidence:* run `20261016T200650` recorded 343 `proof/*.lean` inputs
  against 462 delivered; 39 differ and 119 are absent (§2). Of the test
  modules that read the proof tree, only four checks are sensitive to the
  difference: the three proof-structure tests in `test_lean_source`
  (`include_str` confinement, legacy-import policy, the `ComposeSourceChecks`
  import closure) and `test_platforms`' mocked-Lake fixture over the full
  file set; the Lean-tool-dependent classes read only files identical in both
  trees. This review ran `test_lean_source` (10 OK, 1 skipped for missing
  native Lean), `test_lean_evidence` (45 OK, 4 skipped), `test_lean_modules`
  (2 skipped), `test_proof_provenance` (27), `test_lean_run_history` (10),
  `test_dev_runs` (24), `test_evidence` (53), `test_image_setup` (8) and
  `test_platforms` (16) on the delivered tree: all pass. The certificate
  parity test was already rechecked at root on delivered bytes.
- *Impact:* a record and disclosure defect, not a coverage failure: the
  delivered `proof/` is covered by the complete Lean run (digest equality,
  §2) and every proof-tree-sensitive test passes on it. The completion
  criterion of #16 is not shown violated.
- *Repair:* state in `delivery-validation.json`, `for-loops-integers.md:206`
  and `review-410ed2c.md:383-384` that the suite ran with `src/`, `tests/`,
  `samples/`, `scripts/` and `catalogue/` equal to the delivery but with the
  lane's older `proof/` (39 differing, 119 absent); define the "204 native
  inputs"; and record one focused managed rerun of `tests.test_lean_source`,
  `tests.test_lean_evidence` and `tests.test_platforms` in a worktree whose
  tracked content equals `b8f1d0b9a8`. A full-suite rerun (about 23 minutes)
  is more than necessary.

**L3. The record names `4cd2fe8aae` as the executed snapshot "followed only by
the four generated certificate snapshots", but the runs executed the later
`src/silver_catalogue.adb`.** (TE-2, EQ-2-2; upheld.)

- *Location:* `delivery-validation.json:18, 42, 387, 481`
  (`executed_implementation_commit`); `docs/for-loops-integers.md:202`;
  `review-410ed2c.md:28-30, 321, 342`; the closing comments of #10, #16 and
  #50.
- *Evidence:* `git diff --stat 4cd2fe8aae 65de28b64e -- proof src scripts`
  lists `src/silver_catalogue.adb` (+272/−24) besides the four certificates;
  the file was committed only in `65de28b64e`. The native audit's recorded
  hash of that file is `1a8d280e…`, the delivered blob, not `bda1a4fb…`
  (`4cd2fe8aae`). The Lean digest recomputed from a `git archive` of
  `4cd2fe8aae` is `a6be3957…`, not the recorded `15412eec…`; the same
  pattern holds for the earlier complete run `183420` against `b5cd3f0231`.
  The test run additionally used the then-uncommitted `tests/test_silver.py`,
  `catalogue/silver.json` and the three samples.
- *Impact:* the evidence covers the delivered inputs (favourable), but a
  third party replaying from the named commit would obtain different digests
  and could wrongly conclude the evidence is stale.
- *Repair:* replace `executed_implementation_commit` with a statement that
  the executed inputs equal the delivered `src/`, `scripts/` and `proof/`,
  pinned by the content hashes already in the record (the native
  `proof-inputs.json` hashes and the Lean digest), and correct the
  "followed only by" sentences. `development.md:343-345` forbids a commit
  made to insert its own hash, so this belongs in a later documentation
  commit.

**L4. The complete Lean run reused module objects compiled in other
workspaces; the provenance of that reuse is not recorded.** (UA-3-1, UA-3-5;
two verifiers: narrowed.)

- *Requirement:* O14 (proofs checked automatically during validation; trusted
  assumptions documented); the record's own distinction between cached
  builds, clean rebuilds and replay.
- *Location:* `scripts/check_lean.py:130-173, 241-247, 560-575` (workspace
  synchronisation and reuse: Lake only); `docs/trusted-boundary.md:1046-1067`
  (the "honest local cache records" premise); `review-410ed2c.md:324-326`
  and `docs/for-loops-integers.md:207` ("five exact source-matched artifact
  groups were reused … cached build with a fresh audit").
- *Evidence:* of the 459 traces in the root workspace, the compile command
  lines retained in the trace logs name four other workspaces for 255
  modules (176, 60, 12 and 7; §2); the final run elaborated 11 modules (the
  11 "Built" lines of its log). `check_lean.py` contains no copy, transplant
  or object-verification logic; acceptance rested on Lake's `--rehash` trace
  matching. The shipped Lake source (`.tools/linux-x86_64/lean/src/lean/lake`,
  `Build/Common.lean:212-257`, `Build/Module.lean` fetch path with the
  artifact cache disabled) shows that Lake recomputes and compares the input
  hash (module source, imports' artifact hashes, the `input_file` Ada source,
  toolchain, options) and checks that outputs exist; it does not compare an
  output's content with the trace's recorded output hash, so a trace paired
  with a foreign object would be accepted for that one module. The verifiers'
  post-hoc audit found no such pair: all 457 closure objects' rehashed
  content equals their traces' recorded output hashes and all 847 live import
  entries are consistent. No clean rebuild or kernel replay exists for the
  delivered inputs (documented).
- *Impact:* an evidence-record gap. The record says groups were reused but
  not which workspaces produced them, which modules, or that the merge was
  manual and unscripted; a reader cannot audit the premise the run relies on
  without redoing this review's trace analysis.
- *Repair:* add the import provenance (source workspaces, module counts or
  list, object/trace hashes, procedure) to `delivery-validation.json` and
  the review record; have `check_lean.py` record, for each reused module, the
  workspace named in its trace, and optionally report the two cheap
  consistency checks (trace outputs against on-disk content; recorded import
  hashes against on-disk objects) on routine runs. A clean rebuild with
  replay of the delivered inputs is the owner's option, not a requirement of
  this finding.

**L5. `docs/assurance.md` still says seventeen handwritten source-binding
modules; the delivered tree has 32.** (UA-3-2; upheld.) Item 1 of the
correspondence chain at `docs/assurance.md:395-399` lists only the
pre-milestone units; `proof/Silver/AuthoritativeSource.lean` imports 32
bindings and the lakefile has 32 `input_file` dependencies. The 15 added by
this milestone (Scalars, ScalarLiteral spec and body, ScalarExpression spec and
body, LengthIntervals spec and body, IntegerImage, ImageTheory, ImageModel spec
and body, ImageModelTemplates spec and body, ImageFiles spec and body) are
missing; `docs/trusted-boundary.md:891-896` was updated, so the two documents
disagree. *Repair:* update the item to 32 and list the added units, or cite
`AuthoritativeSource.lean` as the normative list.

**L6. The Image adapter boundary does not name the producer premise that the
installed theorem depends on.** (IA-2b-1; two verifiers: narrowed.)

- *Requirement:* O8 and O5 (trusted external dependencies and interface
  assumptions documented).
- *Location:* `docs/trusted-boundary.md:243-247` (the enumerated
  pinned-producer contract), mirrored at `review-410ed2c.md:163-169` and
  `docs/assurance.md:98-110`; the only statements of the premise are in the
  historical Image record (`docs/for-loops-integers-image.md:122-126,
  249-254`).
- *Evidence:* the size-12 axiom applies only if the pinned `gnat2why`
  translates every admitted `Integer'Image (E)` in Main to
  `Standard_String__Img.to_string (Standard__integer.attr__ATTRIBUTE_IMAGE E) 12`
  (`gnat2why-expr.adb:20256-20290`; `Max_Size_Of_Img_Attr`,
  `spark_atree-entities.adb:593-611`). Silver's scanner checks the three
  theory templates, not Main's occurrences, so this is a per-program producer
  premise. It is a completeness premise, not a soundness premise (a producer
  change would surface as an unproved length check, a rejected valid
  program), it holds for the pinned toolchain, and all 53 Image occurrences
  in the 33 retained delivered Main models satisfy it. The companion premise
  that GNAT's runtime `Integer'Image` implements RM 4.10(11/5) is already an
  accepted generic premise (`oracle.md`, `trusted-boundary.md:42`,
  `language.md:292-298`, `assurance.md:116`) and is not a defect.
- *Repair:* add the translation premise as a fourth item of the
  "Completeness additionally requires …" enumeration in
  `trusted-boundary.md`, mirrored in the review and `assurance.md`, stated as
  an applicability premise to recheck when the producer pin changes; an
  Image-specific sentence about the runtime premise is optional.

**L7. `docs/for-loops-integers.md:206` says exact hashes are recorded for
the 26-snapshot and 204-input identity check; the record holds four hash
pairs and booleans.** (TE-1; narrowed.) `delivery-validation.json:678-679,
745-746` stores the before/after hashes of the four refreshed snapshots plus
`all26_snapshots_match_regeneration_and_root: true` and
`all204_native_inputs_match_root: true`, and never defines the 204 files
(they are `src/` 128, `scripts/` 9, `tests/` 44, `samples/` 22,
`catalogue/` 1). The sentence at `review-410ed2c.md:379-380` is accurate
(the sync manifest's own hashes are all retained). The identity itself is
true (§2). *Repair:* reword `:206` to say what the record holds.

**L8. `RESUME.md`, presented by `README.md:23` as the current handoff, still
says the milestone is unfinished with its harness paused.** (EQ-2-3;
narrowed.) `RESUME.md:40-44, 65-69` contradict `roadmap.md:35-92`,
`docs/session-memory.md:3-29` and the closed milestone; `README.md:80-106`
does not mention the delivered constructs. Open issue #31 covers whether
`RESUME.md` should be the handoff at all; the stale status is a new
consistency defect of this delivery, not a duplicate. *Repair:* add a
delivered section or mark the paragraphs historical, add a sentence and link
to the README overview; best done while resolving #31.

**L9. `roadmap.md:43` summarises the evidence as "complete native
proof/build/tests".** (EQ-2-4; upheld.) The native audit is a complete
cached run and the full suite is a retained failure whose method passed only
in the separate focused recheck; the linked record says so, the summary does
not. *Repair:* reword as the record does, for example "the complete cached
native audit, build, the full-suite run with its one test-only snapshot
repair and recheck (not one clean pass), the complete cached Lean build and
fresh audit".

**L10. The adapter leaves a workspace holding a full model snapshot for every
`gnatwhy3` call, under the compile workspaces' `program-*` prefix, and nothing
removes them.** (IA-1-4, EQ-1-2; upheld as low.)

- *Location:* `src/silver_image_adapter.adb:121-138` (`Create_Workspace` and
  `Snapshot` before the plan is known); `src/silver_platform.ads:71`
  (shared `Workspace_Prefix`); `tests/test_image_adapter.py:53-64` relies on
  retention for the Refine case.
- *Evidence:* every `gnatwhy3` invocation (about six per program using
  `Silver_IO` and `Silver_Arguments`) creates a `mkdtemp` `program-XXXXXX`
  directory with `original.gnat-json` (8 KB to 8 MB, median about 276 KB),
  and for Refine plans also `refined.gnat-json`, the installed theory and
  the Why3 session. The delivery's own full test run left about 722 such
  directories; at verification time the validation installation held 837
  adapter directories, 252 MB. The Unchanged path (no Image theory) keeps the
  snapshot too. Retention is undocumented (the README documents only the
  compile workspace) and the project's test housekeeping cannot reach it.
- *Impact:* unbounded growth of user artifact directories and a shared
  namespace that makes diagnosis and cleanup harder; no obligation affected.
- *Repair:* a distinct prefix; no persistent snapshot on the Unchanged path
  or deletion after the synchronous `Spawn` returns; Refine artifacts kept
  only behind an explicit retention flag the tests set; document the policy.
  In real compiles the adapter workspace is also the proof directory holding
  `_theories` and `sessions`, which constrains the deletion point. About half
  a day with the adapter's SPARK re-proof.

### 3.3 Low: gaps and improvements

**L11. The JSON parser-soundness premise does only internal work and has no
in-Lean witness.** (IA-2a-1; one verifier upheld as a question, one narrowed
to an improvement; both low.) The hypotheses `parse`, `sound : JSON.ParserSound parse`
and `parsed` of `selected_schemas`, `refined_document`,
`producer_refined_document` and `native_refined_document` are used only
through `ParserSound.canonical_eq` (`ImageModelJsonMeaning.lean:51-55`, via
`Templates.selected_meaning`, `ImageModelSelectedMeaning.lean:95-106`) to turn
equal canonical bytes into equal Lean `Value.meaning`; `parse` occurs in no
conclusion, `ParserSound.spelling_eq` is unused, and the consumer boundary
never uses the contract. The pair is satisfiable exactly when Silver's own
`AsciiSpelling` grammar is meaning-deterministic on the three template
encodings, a property of Silver-owned definitions that is not proved anywhere
and, unlike every other premise of `native_refined_document`, has no in-Lean
consistency witness. It is true by inspection (disjoint constructor first
bytes, `shortEscape 117 = none`, whitespace `{32,9,10,13}` disjoint from
token bytes, plain characters exclude 34 and 92), so no endpoint is vacuous.
The documents (`trusted-boundary.md:236-243`, `assurance.md:92-96`) describe
the premise as external parser faithfulness and do not say the step is
provable internally. *Repair:* prove spelling determinism (restricted to the
three encodings suffices), derive `selected_meaning` from it and drop the
three hypotheses, strengthening every endpoint; or at least document that the
premise performs a provable internal step. Moderate Lean effort.

**L12. Every adapter failure is reported as one generic message flagged
`internal`, which `gnat2why` renders as a GNAT bug box.** (IA-1-3, EQ-1-3;
narrowed.) The 14 `Failure` sites in `src/silver_image_adapter.adb` emit
`{"error":"Silver Image adapter: invalid model or infrastructure failure","internal":true,…}`
with exit 3; `gnat2why` ignores the exit status, reads the JSON and, because
`internal` is true, calls `Compiler_Abort`, so an invalid model, an unwritable
proof directory or a spawn anomaly invites the user to file a vendor bug
report before the driver prints its generic line. The `mkdir` status tests in
`src/silver_image_install.adb:37-42` are vacuous (`mkdir` returns 0 or −1),
as in the commented idiom of `silver_platform.adb:202-207`. All paths are
fail-closed. *Repair:* emit `"internal": false` with a message naming the
adapter and the failing step; keep exit 3; comment the idiom. Adapter
re-proof only.

**L13. The adapter's invocation-shape premises are not documented with their
vendor basis.** (IA-1-1; narrowed.) The adapter refines only when the last
argument ends in `.gnat-json`, finds `--proof-dir` among the earlier
arguments, relies on `gnatprove` resolving `gnatwhy3` from its own install
prefix, and relies on `gnat2why` acting on the captured JSON rather than the
exit status. `trusted-boundary.md:231` names the lookup premise generically;
the other three are not stated, although the project's standard for this
boundary is line-cited vendor source. *Repair:* add the four premises with
citations (`gnat2why-driver.adb:601, 1224-1232, 1247-1253, 243-257`;
`configuration.adb:3177, 3236-3244`; `gnatprove.adb:908-916`;
`configuration.ads:261-268`; `gnat_config.ml:729-742`, at the pinned
revisions) and the existing caveat that source inspection is not binary
attestation; optionally fail (exit 3) instead of forwarding when the last
argument is not a model.

**L14. Runtime and interaction test coverage for Image and loop compositions
is thin.** (TE-4; upheld.) The suite executes `Integer'Image` only for the
values 3, −1, 0, 1, 2–10 and 10..0; `tests/test_integer_image.py` is
admission-only, so no test proves or executes an 11-byte image or an 11-byte
Image assignment. No test pins a reverse null range, a 64-leaf scalar
expression, loop-bound operators counting toward the budget, Image on both
comparison operands, an empty-interval Image inside a comparison, a nested
uncertain inner loop with a String assignment, or `Reject` inside a loop body.
All of these behave as specified under `silver check` (22 independent
probes), and this review's compile probes prove and run the extreme-image
program and the composite argument-shell loop. *Repair:* admission subtests
for these compositions and two native tests (the extreme-image program; the
composite loop), each one `silver compile` in a 1,355-second suite.

**L15. No kernel-checked witness in the tree instantiates the new
recognizers on a concrete program.** (UA-2a-2, UA-1-2; narrowed to low and
info.) `PredicateExamples.lean` is unchanged since `4503d17a93`, making this
the first capability milestone that added no Examples witness. Vacuity is
excluded: `executable_correspondence` plus the native tests inhabit the
fragment under the documented premises, and this review's kernel probes
decide `Current.accepts = true` on the exact bytes of all three delivered
samples and inhabit `ScalarExpression.At` on `(I * Step)`. *Repair:* add
`decide +kernel` witnesses for the three samples, a statically empty loop, an
uncertain nested loop with a post-loop assignment and the rejected own-name,
post-loop-index and homonym forms, framed as corroboration
(`docs/assurance.md:54`); about 10 s each in the audit.

### 3.4 Info

- **I1 (IA-2b-3).** The owner's confirmation to continue with the
  proof-model refinement mechanism is recorded only at
  `docs/for-loops-integers-image.md:258`, not in the dated delivery entry of
  `docs/session-memory.md:3-30`; decision #34 settled scope only. No rule
  required a separate entry: the recording rule covers authorizations, pauses
  and revocations, the mechanism is routine work inside the recorded #13/#15
  authorization, it is Silver-owned verified SPARK, and the external premises
  it uses sit on the GNAT/GNATprove boundary the Oracle already approves. A
  dated sentence linking the Image record would close it.
- **I2 (IA-1-2).** `Ensure_Theory`'s already-installed fast path
  (`src/silver_image_install.adb:31-36`) returns before creating
  `<dir>/sessions`, which `gnatwhy3` requires. Unreachable for admitted
  programs: `silver compile` never passes `--proof-dir`, so every per-unit
  call gets a fresh workspace; a `gnatprove`-supplied `--proof-dir` arrives
  with `sessions/` already created; concurrent installs are safe. Only a
  hand-prepared directory reaches the failure, which is clean. Two-line
  repair: create `sessions` before the early return.
- **I3 (NP-2).** `scripts/check_evidence.py:510` accepts `severity=info`
  `warn_error` records by severity alone; the retained audit has 52 such
  GNATprove `info-unrolling-inlining` notes (42 "unrolling loop", 5 "cannot
  unroll loop", 5 "local subprogram … only analyzed in the context of calls")
  that no published count lists. The acceptance is deliberate and tested
  (`tests/test_evidence.py:637`), structurally constrained and cross-checked
  against SARIF, and the cited "other warnings fail" sentences govern
  application reports, where info records are rejected; no obligation is
  carried. Pinning the three texts and counting the class would make the
  ledger complete; the contextual-analysis note is the one worth checking.
- **I4 (NP-3).** The repaired native audit replayed, through GNATprove's
  file-backed cache, a 61.5 s CVC5 result for
  `silver_library_reports.adb:1763:23` computed by the failed audit under
  the byte-identical `--timeout=30` command (Why3 enforces `4t+1` CPU-seconds
  and keeps late Valid answers; the cache keys include the timeout). The run
  is correctly labelled cached; no cold audit of the final sources exists,
  which is documented. A ledger field for cache reuse would help.
- **I5 (LC-1-2).** Statically null loop ranges, an admitted construct, raise
  GNAT's default frontend warning "loop range is null"; it is console-only
  and never enters `main.spark` or the SARIF, as the compiles of a forward
  (`program-9D5oqB`) and a reverse (`program-hoUpZR`) null range show. The
  suite compiles no null-range program (its null-range tests are
  check-only); add one compiled regression test. No classification or
  exclusion is warranted.
- **I6 (LC-1-4).** The scalar environment capacity
  `Silver_Scalar_Expressions.Max_Bindings = 4096/12 = 341` guards Integer
  constants plus live loop depth (`silver_output_profile.adb:744, 1478`) and
  is mirrored in Lean, but `language.md:194-197`, `assurance.md:167-169` and
  `trusted-boundary.md:639-641` derive 341 only for String bindings. It is
  unreachable within the 4,096-byte source bound (at least 22 bytes per
  binding; 174 live bindings observed at most). One sentence and a purpose
  comment at `silver_scalar_expressions.ads:8` close it.
- **I7 (UA-2a-3).** `docs/assurance.md:493-495` says loop schemas cover
  "finite iteration and the composed String/path facts"; the loop obligation
  inventory (`PredicateObligations.lean:174-180`) holds the two bound
  expressions' schemas and the body schemas under the loop context, while
  finiteness is a semantics theorem (`iterations_execution_sound`). Reword.
  The `Current.lean:75-78` docstring is pre-existing text already noted by
  earlier reviews.
- **I8 (IA-2b-2, IA-2b-4, IA-2b-5).** The correspondence between the
  installed WhyML `checked_length` text and the Lean `assertion` is a shared
  `Digits`-AST rendering plus literal duplication of the guard, size 12 and
  `1 +`, under the Why3 logic-semantics premise; no theorem relates
  `Theory.text` to `assertion` (one sentence in the documents would say so; a
  Lean decoder would add nothing over the premise). `consumer_instance` never
  applies a parser to the output bytes; the hand-off to the external typed
  conversion is already documented. The documents cite theorems by module
  prefix (`IntegerImageTheory.assertion_valid` is
  `Silver.Integer.Image.Theory.assertion_valid`;
  `FilesSource.native_producer_finishes` lives in `ImageProducerEndpoint`); all
  names resolve.
- **I9 (IA-2a-2, IA-2a-3).** The per-iteration `Typed` and byte-bound
  premises of the scanner trace are documented generically at
  `trusted-boundary.md:946-951` and specifically at
  `for-loops-integers-image.md:428-429`, but not cross-referenced from the
  Image adapter section. Hygiene of the Image modules: only classical
  totalizers, raised `maxRecDepth`/`maxHeartbeats` in 27 files and
  `backward.dsimp.instances true` in 14; endpoints use the three standard
  axioms only.
- **I10 (UA-2b-1).** `Call_After`, `Value_At`, `Expression_Step`,
  `Expression_Tail` and `Expression_At` (and their Lean mirrors) default
  `Scalar_Names` to the empty environment and `Integer_Hidden` to `False`;
  every delivered call site passes the live environment and the typed source
  bridge models the default convention, so an omission in a bridged body
  would fail the kernel check; the residual exposure is a future unbridged
  helper. Removing the defaults needs certificate regeneration and bridge
  changes.
- **I11 (UA-3-3, UA-3-4).** The ScalarExpression and ImageModel source facts
  are stated over generated token constants; their four `*Tokens_correct`
  theorems that name the `include_str` bindings have no consumer, so the
  composed `lex Source.x = some SourceShape.y` statement must be assembled by
  the reader (two additive lines per binding fix it). The five token-capture
  certificates in `ImageFilesCapture`, `LengthIntervalsCapture` and
  `IntegerImageNativeCapture` are byte-identical to the output of the
  checked-in `generate_source_certificate.generate` but are outside the CLI,
  `CANDIDATES` and the parity test, consistent with the documented
  hash-pinned policy; `ImageFilesCapture.lean` lacks the provenance docstring
  the other two carry.
- **I12 (NP-1).** No per-program application-proof provenance is recorded,
  and `proof-provenance.json` records the generated `Silver_Image_Config` and
  the vendor `gnatwhy3` digest but no overlay entry and no digest of the
  compiled adapter (which nothing digests, not even validation); managed
  test runs hash `compiler/bin/silver` but not
  `compiler/bin/silver_image_adapter`. A documented deferral
  (`trusted-boundary.md:221-232, 596-601`; `assurance.md:739`).
- **I13 (TE-5).** Six `key_reviewed_file_sha256` entries and one
  untracked-file hash in `docs/evidence/for-loops-image/delivery-review-inputs.json`
  match no commit in any ref: they are the uncommitted 18:20 delivery-document
  drafts over `410ed2c83e` (three still carrying `PENDING_*` placeholders),
  reproducible from the record's own tracked-diff hash and retained only in
  untracked scratch of `tmp/for-loops-compose-resume`. The record discloses
  the prospective state; a pointer to the bundle or a final-document hash
  section would make it self-contained.
- **I14 (LC-1-3, EQ-1-6, LC-2-3).** `src/silver_catalogue.adb` prints
  `2147483648`, `4096`, `64`, `[2, 11]` and the Integer range as literals
  while deriving other limits from constants (lines 954-956), so drift would
  escape the parity test; the values agree today. `language.md:242-246`
  states that scalar comparisons do not narrow intervals without the purpose
  (given only at `docs/for-loops-integers.md:61-63`) or the "current scope
  limit, not an Ada restriction" clause used elsewhere.
- **I15 (EQ-1-4, EQ-1-5, EQ-1-7, EQ-1-8, EQ-1-9).** Unused state
  (`Native_Gnatwhy3_SHA256`, `First_Inserted_Id`, `Inserted_Node_Count`,
  `Greatest_Id` outside the probe and Lean) and one hard-linked
  `image-XXXXXX` staging directory left per install; a 25-line clone between
  the two literal scanners, the comparison algebra in two packages and the
  Image advisory policy in three Ada forms plus Python (tie the Python copy
  by a byte-equality test; keep it independent); the adapter route costs
  about 1,250 SPARK lines and 125 Lean modules because decision #34 fixed the
  scope, and it fails closed under a changed producer (document an upgrade
  procedure); the 25,804-line `OutputBodyCertificate` churned +17,894/−14,399
  after +332/−99 source lines, and only the full suite found the stale
  snapshots (run the regeneration-equality test as a pre-audit gate); 492
  managed runs with 180 task labels and 243 failed Lean runs show heavy
  multi-lane rework, though the diagnostic-checkpoint gate was enforced for
  every obligation that failed three times.
- **I16 (EQ-2-5 to EQ-2-9).** Stage 3 (procedures) has no stage issue
  (documented deferral; planning does not require contiguity); 63 of 193
  commits cite issues as `(#n)` rather than `Refs #n`; the L1–L3 identifiers
  in the titles of #48–#50 do not appear in `review-410ed2c.md`; all cited
  Lean names resolve and `assurance.md:127`'s label is ambiguous; the
  renderer determinism run bound no `rosetta/` inputs and tested only
  seed-independence, while this review's re-render reproduces all 1,784 pages.
- **I17 (critic).** Open findings from review-343c2f8 overlap or touch this
  delivery without being dispositioned: #31 (RESUME) and #33 I4 (catalogue
  literals) are re-found above; `rosetta/refresh.py:528` and
  `rosetta/assess.js` were edited while #29 and #32 stayed open and
  unaddressed; #2's capacity reassessment rests on the premise L1 falsifies;
  #7 (`DOC_END`) did not recur in today's 492 runs.

### 3.5 Candidates refuted or answered in the negative

Recorded so that later reviews do not repeat them.

- **Two "Silver restriction presented as Ada" findings (LC-2-1, UA-1-1,
  UA-2a-1).** Three reviewers held that `Integer : constant String := Integer'Image (1);`
  and an inner `for I in 1 .. I` are legal Ada resolving to the outer
  declaration, so that `language.md:248-251, 270-272`, the catalogue's
  `integer_type_hiding` and the comment at `silver_scalar_expressions.ads:63-65`
  misattribute Silver rules to Ada. Verification refuted this: by RM 8.2(2),
  8.3(16) and 8.3(22) the new declaration hides the outer homograph from
  direct visibility within its own immediate scope while being itself hidden
  until the end of its declaration, so both forms are illegal; GNAT 16.1.0
  rejects them ("cannot be used before end of its declaration") and accepts
  the `Standard.`-qualified and `for J in 1 .. I` controls. The specification
  is correct, Silver's admission agrees with GNAT, and the proposed rewording
  would have inserted a false statement about Ada into the specification and
  a kernel-checked certificate.
- **Null-range loops (LC-1-2, UA-1-3).** Settled by compile probes: the
  frontend warning never reaches the audited reports (I5), and GNATprove
  proves the dead body's overflow check under the inconsistent loop
  hypothesis (`program-hoUpZR`, `VC_OVERFLOW_CHECK main.adb:8:45` proved).
- **Output capacity (LC-2-2).** No native obligation exists because none is
  intended: the 4,096-byte bound is an admission limit proved in Lean for
  every admitted meaning (`Current.effects_domain`) and backed by a proved
  executable guard in `Silver_IO` that yields status 1 without truncation;
  documented at `trusted-boundary.md:342-345`, `assurance.md:360-366` and
  `language.md:684-686`.
- **Runtime Image premise (part of IA-2b-1)** and **the scanner's `Typed`
  premise (IA-2a-2)**: already documented generic premises.
- **Capture certificates "cannot be regenerated" (UA-3-4)**: the checked-in
  library function reproduces all five verbatim; only the CLI and the parity
  test omit them.
- **"Result obtained under another configuration" (NP-3)**: the 61.5 s result
  came from the identical command; see I4.

## 4. Dispositions of previously reported findings

| Finding | Disposition | Evidence |
| --- | --- | --- |
| #48, review-b5cd3f0231 L1: classify the exact Image integer-conversion instance | **Fixed.** | `scripts/check_evidence.py` accepts exactly `Counts.To_Big_Integer` and `From_Big_Integer` with origins `a-nbnbin.ads:82:16` and `:85:16`, instantiated at `silver_image_files.ads:16:4` (`signed_conversion_entities`, `audit_signed_conversion_instance`); the retained `silver_image_files.spark` shows those two `spec` entities and no other non-`all` coverage; `tests/test_evidence.py` covers the positive and mutated cases (53 tests pass on the delivered tree); the original run failed with "entity outside full SPARK", the repaired run passed with 62 vendor spec entities. Closed by `Fixes #48` in `65de28b64e`. |
| #49, review-b5cd3f0231 L2: group the length-interval ceiling expression explicitly | **Fixed.** | `src/silver_length_intervals.adb:24` reads `((Numerator + Difference) - 1) / Difference`; `LengthIntervalExpressions.lean:163` renders the same grouping and `LengthIntervalsCapture.lean:665-666` certifies the line, kernel-equated to the lexed file by `LengthIntervalsSource.body_checked`; the original report had one `operator-reassociation` record at 24:50, the repaired `silver_length_intervals.spark` has none; the Lean inputs digest covers the changed modules. Closed by `Fixes #49`. |
| #50, review-4cd2fe8aae L3: refresh four stale generated certificate snapshots | **Fixed.** | The four delivered certificates equal the workspace bytes the complete Lean run built (`7dde1742…`, `451d3127…`, `098c75a7…`, `76488f26…`); `62f472c35d` touches only those four files; `test_checked_in_certificates_equal_regeneration` passes for all 26 pairs on the delivered tree (rerun here) and in the root focused run; the original full-suite failure is recorded as a failure in the capability record, the review, the PR body and `delivery-validation.json`. Closed by `Fixes #50`. The regression-coverage claim it supports is qualified by L2. |
| review-410ed2c, `SequenceNativeState` scalar-environment repair | **Fixed.** | The five proof files thread `scalarNames` through context conversion, expansion, validity and rendering, matching `Context_Of`/`Expand_Body`/`Valid_Context` in `silver_output_profile.adb:1000-1038`; no remaining conversion drops or defaults the environment; the repair changed no SPARK source. |
| review-410ed2c, consumer law narrowed to the checked substitutions | **Fixed.** | `ImageModelConsumerBoundary.lean:68-73` takes the actual `Clone.substitutions`; `consumer_instance` derives scope, signature and assertion without any assertion hypothesis. |
| review-410ed2c, node-ID band correction (`b8a65356e5`, `fb7837abab`) | **Fixed.** | Inserted IDs 2147483648..2147483670, 23 of them, unique and fresh relative to the checked `0..2147483647` incoming domain (Lean `inserted_ids_*`; native guard `silver_image_model.adb:435`; adapter probes with IDs 2147483647, 2147483648 and −1). |
| #17 / review-343c2f8 B1, report capacity, as extended for this fragment | **Fixed for the delivered fragment, with a false premise.** | The 15,028,224-byte extended Main bound re-derives from `tests/test_capacity.py`'s constants and fits the 16,777,216-byte buffer with 1,748,992 bytes of headroom; the shared 63-operator premise is falsified by L1, but the extra records it permits in a 4,096-byte source stay inside that headroom, and the maximal undercount program's report measured 175,779 bytes. |

## 5. Areas reviewed without material findings

Each statement names what was actually checked; none is inferred from a
passing run.

- **Specification, catalogue and recognizer agreement (LC-1).** Every
  `conditions` key of the six new or changed catalogue entries was mapped to
  the sentence in `language.md` that states it and to the recognizer code
  that enforces it; the only disagreement is L1. Admission depends on source
  bytes alone: the `check` path calls only the two profile recognizers, all
  `Global => null` over the source string, and `check` and `compile` share
  the identical admission calls (`silver.adb:450-461`). Of 101 differential
  probes, every program `silver check` accepted also passed the GNAT 16.1.0
  frontend in check-only mode with the driver's switches (based literals with
  `:` delimiters and exponents, `(-16#80000000#)`, `-2_147_483_648`, `0E4096`,
  the double-parenthesised Image argument, indexes named `String`, `Integer`,
  `Put`, `Image`, `Length`, nested same-name and case-variant indexes), and
  the hiding rules the specification attributes to Ada are Ada's (§3.5). The
  74 Ada 2022 reserved words plus `string` and `silver_io` are excluded; the
  exporter prints every catalogue key and `silver catalogue` equals the
  checked-in file byte for byte.
- **Arithmetic, Image lengths and loop semantics (LC-2, UA-1).** `Wide` is
  `Long_Long_Integer`, which holds every corner product and the negation of
  `Integer'First`; every literal, unary and binary node is range-checked
  (`silver_scalar_expressions.adb:169-207`). A Python transcription of
  `Add`/`Subtract`/`Negate`/`Multiply`, `Length_Of`, `Minimum_Length`,
  `Maximum_Length` and `Equal_Increasing` was brute-forced against exhaustive
  evaluation (80,000 interval pairs, 10,817 Image intervals, 3,000 refinement
  summaries) with no discrepancy; `Length_Of` matches RM 4.10(11/5) at every
  threshold and both extremes, and the Why3 theorem's thresholds agree. The
  Lean side (`Silver.Integer.Expr.infer_sound` with `Safe` requiring range at
  every node, `multiply_contains`, `IntegerIteration`,
  `loopBounds`/`loopDefinite`) states the same rules; forward and reverse
  iteration are null when the upper bound is below the lower in either
  direction; the literal model follows RM 2.4 (bases 2..16, consistent `#` or
  `:`, single underscores, `E`/`e` with optional `+`, the 4,096 exponent cap
  with its documented purpose). Eleven compile probes, every one proved,
  built and run: Images of `Integer'First`, `Integer'Last` and 10⁹ into
  11-byte Strings and ` 0`/`-9` into 2-byte Strings; a loop over −9..9
  assigning the index image to a 2-byte String; an uncertain nested loop
  whose inner bound reads the outer index from 0, with an assignment, a
  product overflow check and a use after the loop; statically null forward
  and `reverse 5 .. 1` loops, the latter with a dead would-overflow body; a
  concatenation of exactly 4,096 bytes ending in an Image; 64 leaves with 63
  `+`; String-equality refinement feeding native length checks; the maximal
  budget-undercount program; and the composite argument-shell loop with
  `Reject`, a scalar comparison, partial `Put`, Image and an assignment used
  after the loop (68 checks proved).
- **The adapter's executable behaviour (IA-1).** Traced end to end: the
  overlay's copied `gnatprove` reaches the adapter as `gnatwhy3` (the only
  regular file in the overlay is `bin/gnatprove`; 78 symlinks; `gnatwhy3`
  links to the compiled adapter); a refined model is created exclusively and
  handed to the vendor `gnatwhy3` only after the splice succeeded and was
  rescanned equal to the plan; models without an Image theory are forwarded
  unchanged. Twenty-nine direct executions on crafted models: truncated,
  non-JSON, duplicated selected theory, altered template, IDs 2147483648 and
  −1, non-ASCII structural byte, unwritable or file-typed proof directory,
  ambiguous `--proof-dir` and a conflicting pre-existing theorem all fail
  closed (exit 3, original model untouched, nothing spawned); whitespace and
  escape respellings, a 5 MB string and 100,000-deep nesting in an unselected
  theory are handled without buffer limits; removing the 1,002- and 92-byte
  fragments from a retained refined model recovers the original byte for
  byte. All nine adapter units are `SPARK_Mode On` with every check proved,
  no justified check and no `pragma Assume`; compiler verification cannot
  reach the overlay; application proof passes no `--memcached-server`, uses a
  fresh `mkdtemp` workspace per compile and per adapter call, and generates a
  `program.gpr` without `Prove'Proof_Dir`, so no session, cache or theory file
  is shared between programs; counterexamples are off; the report reader
  never reads `stats`.
- **Adapter proofs (IA-2a, IA-2b).** The endpoint theorems
  `producer_finishes`, `native_producer_finishes`, `native_refined_document`,
  `refined_document`, `selected_schemas`, `consumer_instance` and
  `assertion_valid` depend only on `propext`, `Classical.choice` and
  `Quot.sound`; every hypothesis was classified as proved elsewhere in the
  chain or as a documented premise (producer format contract, whole-file
  representability, stable files, parser soundness: L11 for the one premise
  doing internal work). The scanner's Lean transitions are kernel-equated to
  the certified SPARK body block by block, covering both early exits and
  every failure leaf; template validity has decided witnesses for the three
  theories and both clone values; the splice theorem states original bytes
  at shifted indexes, two inserted spans and erasure recovery; the inserted
  IDs are unique, fresh and 23. Necessity was confirmed from the retained
  model: the vendor supplies exactly three `to_string` axioms, an
  empty-string interpretation satisfies them, so the exact-length obligation
  is not entailed at any solver effort, and the driver and configuration
  hooks the record rejects are rejected for the reasons given
  (`driver.ml:239-241`, `gnat_checks.ml:399`). `clone … with axiom .` keeps the
  axiom an axiom (`typing.ml:1669-1671`, `theory.ml:842-850`) and
  `remove_unused` keeps it; the installed `_theories/silver_image.mlw` equals
  `Theory_Text` and the Lean `Theory.text` byte for byte;
  `consistent_refinement` and `zero_size` show the strengthened model is
  consistent with the vendor axioms at size 12; `attr__ATTRIBUTE_IMAGE` has
  no axioms of its own and is generated only for prefix type
  `Standard.Integer`; the assertion is never a hypothesis anywhere in the
  chain; the Files loop interpretation matches `silver_image_files.adb:139-171`
  token for token including both failure exits and the 29 record defaults.
- **Predicate, Compose, Sequence and String proofs (UA-2a, UA-2b).** Bounds
  are evaluated once in the entry store (`PredicateExecution.lean:66-69`);
  execution is by induction over `Integer.iterationValues`; the obligation
  inventory keeps both bound expressions, scalar initializers, Image
  initializer arithmetic after `freezeImages`, and body paths under the loop
  context; `Current.all_obligations_discharge` and
  `PredicateCorrespondence.executable_main_correct` depend only on the three
  standard axioms. A kernel probe decided the three delivered samples and ten
  further loop programs exactly as the delivered binary does and instantiated
  `member_has_meaning` and `all_obligations_discharge` on the countdown
  sample. The shared name environment, index hiding of use-visible operations
  and the `Integer` type-mark hiding agree line by line between SPARK and
  Lean; the String length summaries match the catalogue keys; the five-file
  Sequence repair leaves no conversion that drops the scalar environment. The
  complete audit imports every module: 457 files plus `Silver.lean` = 458 =
  the evidence's module list = the log's `SILVER_MODULE` lines; `#silver_audit`
  refuses `skipKernelTC` and allows only the three standard axioms.
- **Source-correspondence machinery (UA-3).** All 32 binding modules are the
  only `include_str` sites; each has an `input_file` dependency with
  `text := false` and its live Lake trace carries the source hash;
  certificates are `decide +kernel` line certificates joined by a
  kernel-checked reconstruction witness; regeneration of the 26 certificates
  from the delivered sources reproduces the checked-in bytes exactly (run
  here, 26/26); the runner always regenerates candidates into the workspace,
  so checked-in certificate bytes are never what is proved. Across the whole
  proof tree there is no `axiom`, `sorry`, `admit`, `native_decide`,
  `implemented_by`, `extern`, `unsafe`, `partial def` or `opaque`; the two
  metaprograms are `kernel_exact` and `#silver_audit`. The Names, Cursor and
  Lexical bridges the scalar premises import are unchanged since the baseline.
- **Native evidence and report policy (NP).** The recorded totals (74 units,
  991 entities, 1,283 flow and 13,800 proof checks, 290 limitation notes, 17
  imports, 6,236 mathematical notes, 62 vendor spec entities) reproduce from
  the 74 retained `.spark` files; the 290 notes are 164 `numeric-variant` and
  126 `contracts-recursive` notes in Silver-owned recursive ghost functions,
  withholding callee contracts inside recursion without altering any stated
  contract, and every check in those units is proved; the 6,236 notes are the
  vendor `Is_Valid` assumption at three `a-nbnbin.ads` locations; no
  justified, suppressed or skipped check exists. The report policy admits
  proved `VC_RANGE_CHECK`, `VC_LENGTH_CHECK` and `VC_OVERFLOW_CHECK` with Main
  provenance and classifies the exact `imprecise-image` advisory; a different
  text or rule, a present entity, a non-empty `suppressed` field or an
  advisory in a flow or proof list is rejected by the code and by tests; the
  real producer's advisory record has the pinned shape. The 15,028,224-byte
  bound re-derives from the test constants. `--no-loop-unrolling` is on the
  application command; `null` keeps `--warnings=error`; the repair commits
  touch only the files the record claims.
- **Tests and evidence (TE).** All 13 cited run directories exist; 19
  recorded artifact hashes recompute equal; the totals in the record match
  the logs; the focused recheck preceding the refresh commit is explained by
  the refreshed certificates already being in the root working tree; the
  identical `gnatprove.out` of the failed and repaired native runs is
  explained by unchanged counts with session timings replayed, while the
  `.spark` and SARIF files differ (reassociation 2→0). The three samples'
  expected bytes match Ada semantics including the leading space.
- **Rosetta render and tracking (EQ-2).** Re-rendering with the delivered
  `refresh.py`, manifest and coverage reproduces all 1,784 generated files
  byte for byte (and the baseline script reproduces the baseline); of 1,738
  changed pages, 1,735 change only the progression line and/or the heading
  and exactly three change in substance. Only `integer-for-loops`,
  `immutable-integers` and `integer-image` became supported; #11 (Stage 2)
  and #12 (Stage 4) remain Backlog; milestone 1 closed with 16 issues;
  `65de28b64e` carries the `Fixes` lines; the 2026-10-16 session-memory entry
  records the resumption and publication authorization; all 3,280 relative
  links added to the 18 changed documents resolve.

## 6. Conclusion

No finding warrants reopening the delivered work. The milestone's language,
proofs, native verification and adapter stand up to independent
re-derivation, probing and adversarial verification; the Oracle was not
amended and did not need to be. Two things should happen next, in this
order:

1. **Repair L1** (the operator-budget scanner, its Lean mirror and
   certificate, with regression tests and the corrected capacity premise)
   before the next construct is admitted, because the budget is both a
   published membership rule and an input to the report-capacity envelope.
   File it as a `type: finding` issue at severity low.
2. **Correct the record** (L2, L3, L4, L7, L9; L5, L6, L8 in the documents)
   in one documentation commit, pinning the executed inputs by the content
   hashes the record already holds and disclosing the lane proof tree and
   the artifact provenance; record one focused managed rerun of the
   proof-tree-sensitive test modules on a worktree equal to `b8f1d0b9a8`.

L10 to L15 and the info items are improvements to schedule as follow-ups.
Whether to run a clean Lean rebuild with kernel replay and a cold native
audit of the delivered inputs remains the owner's option; the delivery
documents correctly say neither exists.

## Appendix A. Targeted checks performed by this review

All checks are read-only against tracked files. Hypotheses were recorded
before each run; transcripts are retained with the review's scratch material
under the session scratchpad (`r6/agents/<lens>/`, `r6/agents/verify/`,
`r6/probes/`).

| Check | Hypothesis | Result |
| --- | --- | --- |
| Tree identity: `git diff 65de28b64e b8f1d0b9a8`; `git diff HEAD b8f1d0b9a8` in the shared checkout | the merge tree equals the delivery commit and the checkout's tracked tree | both empty |
| sha256 of all 140 repository inputs in the native audit's `proof-inputs.json` against `65de28b64e` blobs | the native audit executed the delivered sources | all equal; no `src/` file missing |
| Standalone emulation of `check_lean.py` `capture_shared_inputs` and `inputs_digest` over the delivered tree, `4cd2fe8aae` and `b5cd3f0231` | the complete Lean run's digest `15412eec…` is the delivered proof inputs | equal for the delivered tree; the two commits give other digests |
| Byte comparison of the validation worktree and of run `200650`'s and `202127`'s recorded inputs with the delivered tree | the test runs used the delivered inputs | native inputs identical; the full run's proof tree differs (39/119); the focused recheck's 668 inputs equal |
| Lake trace provenance over the 459 root-workspace traces; rehash of all 457 closure objects against their traces' output hashes and 847 import entries | the final Lean run elaborated the delivered modules; reused objects are content-consistent | 11 elaborated; 255 traces from four other workspaces; all objects and import entries consistent |
| `silver check` on the three samples and more than 300 reviewer- and verifier-written probes (LC-1 101, of which every accepted one also `gcc -c -gnatc -gnat2022 -gnata -gnato`; LC-2 66; UA-2a 32; UA-1 26; UA-2b 9; TE 8; EQ-1 4; verifiers and critic) | admission follows the specification and accepted programs are legal Ada | as reported in §3 and §5; one disagreement (L1) |
| Eleven `silver compile` probes, serialized (LC-2 eight; one forward null-range program by a verifier; the critic's maximal-undercount and composite programs by the orchestrator) | admitted edge-case programs prove, build and run | all exit 0, every Main check proved; undercount report 175,779 bytes |
| 29 direct `silver_image_adapter` executions on crafted models (IA-1) plus two installer probes (verifier) | failure paths are fail-closed; valid models are refined exactly; the fast path needs `sessions/` | as reported in §5, L10 and I2 |
| Frozen-build Lean probes: `#check`, `#print axioms`, `#eval`, `example`, `decide +kernel` (IA-2a 3 files, IA-2b 3, UA-1 2, UA-2a 2, UA-2b 2, EQ-2 1, critic 1, verifiers, orchestrator 1) | statements match the documents; endpoints use only standard axioms; models evaluate edge cases as Ada does; admission is decidable for the delivered samples | as reported in §3 and §5 |
| `python3 -m unittest` on the delivered tree: `tests.test_lean_source` (incl. certificate regeneration, 26/26), `test_lean_evidence`, `test_lean_modules`, `test_proof_provenance`, `test_lean_run_history`, `test_dev_runs`, `test_evidence`, `test_image_setup`, `test_platforms` | the proof-reading pure-Python modules pass on the delivered proof tree | all pass; skips only where native Lean tools are required |
| Scripted statistics over the 74 retained `.spark` files, `gnatprove.out`, the failed run's reports and `program-blfheE/main.spark` (NP) | recorded totals reproduce; #48/#49 repairs visible in the reports; advisory shape pinned | reproduced; reassociation 2→0; two `Counts` spec entities; one cached 61.5 s CVC5 result (I4) |
| Python transcription brute force of the interval, Image-length and refinement functions (LC-2); RM 4.10 thresholds and Lean `#eval` at every threshold (IA-2b) | the SPARK functions and the Lean models are sound and exact | no discrepancy |
| Re-render of the Rosetta pages with the delivered and baseline scripts (EQ-2); classification of all 1,738 page diffs; resolution of 3,280 links | the render is deterministic and the changes are what the delivery says | 1,784/1,784 byte-equal both ways; 3 substantive pages; 0 broken links |
| GNAT `gcc -c -gnatc` on `Integer : constant String := Integer'Image (1);`, inner `for I in 1 .. I` and controls (verifiers) | the forms are legal Ada (reviewers' claim) | rejected by GNAT; the claim was wrong (§3.5) |
| Read-only inspection of the pinned Why3 and gnat2why sources and the shipped Lake source for `clone … with axiom .`, `remove_unused`, the `gnatwhy3` invocation shape and Lake's replay checks | the record's reasons and the adapter's premises hold | as reported in §5, L4, L6 and L13 |

## Appendix B. Reviewer identifiers

Reviewer lenses are LC-1, LC-2, IA-1, IA-2a, IA-2b, UA-1, UA-2a, UA-2b, UA-3,
NP, TE, EQ-1 and EQ-2 (§1.2). Each reviewer finding id is `<lens>-<n>`; the
verification items merge duplicates.

| Item | Reviewer findings | Claimed | Verified |
| --- | --- | --- | --- |
| V01 → L1 | LC-1-1, EQ-1-1 | low / blocker | low defect (3 verifiers) |
| V02 → L2 | TE-3, EQ-2-1 | low / blocker | low defect (3 verifiers) |
| V03 → L3 | TE-2, EQ-2-2 | low | low defect |
| V04 → §3.5 | LC-2-1 | low | refuted (2 verifiers) |
| V05 → §3.5 | UA-1-1, UA-2a-1 | low | refuted |
| V06 → L4 | UA-3-1, UA-3-5 | low | low defect (2 verifiers) |
| V07 → L5 | UA-3-2 | low | low defect |
| V08 → L6 | IA-2b-1 | low | low defect, narrowed to the producer premise (2) |
| V09 → I1 | IA-2b-3 | low | info improvement (2) |
| V10 → L11 | IA-2a-1 | low | low gap (2) |
| V11 → L7 | TE-1 | low | low, one of three locations |
| V12 → L8 | EQ-2-3 | low | low defect |
| V13 → L9 | EQ-2-4 | low | low improvement |
| V14 → L10 | IA-1-4, EQ-1-2 | low | low defect |
| V15 → L12 | IA-1-3, EQ-1-3 | low | low improvement |
| V16 → L13 | IA-1-1 | low | low improvement |
| V17 → I2 | IA-1-2 | info | info, latent |
| V18 → L14 | TE-4 | low | low improvement |
| V19 → L15 | UA-2a-2, UA-1-2 | low | low / info improvement (2) |
| V20 → I3 | NP-2 | info | info (2) |
| V21 → I4 | NP-3 | info | info, origin claim refuted (2) |
| V22 → I5, §3.5 | LC-1-2 | low | answered: no impact (2) |
| V23 → I6 | LC-1-4 | info | info (2) |
| V24 → I7 | UA-2a-3 | info | info, one of two locations |
| V25 → I8 | IA-2b-2, IA-2b-4, IA-2b-5 | info | info |
| V26 → I9 | IA-2a-2, IA-2a-3 | info | info, premise already documented |
| V27 → I10 | UA-2b-1 | info | info |
| V28 → I11 | UA-3-3, UA-3-4 | info | info, regeneration claim corrected |
| V29 → I12 | NP-1 | info | info, documented deferral |
| V30 → I13 | TE-5 | info | info (2) |
| V31 → §3.5 | LC-2-2 | info | refuted / answered (2) |
| V32 → I14 | LC-1-3, EQ-1-6, LC-2-3 | info | info |
| V33 → §3.5 | UA-1-3 | info | refuted / answered (2) |
| V34 → I15 | EQ-1-4, EQ-1-5, EQ-1-7, EQ-1-8, EQ-1-9 | info | info |
| V35 → I16 | EQ-2-5, EQ-2-6, EQ-2-7, EQ-2-8, EQ-2-9 | info | info |

## Appendix C. Side effects of this review

- Added the detached worktree `tmp/review-b8f1d0b9a8` (clean) and scratch
  material under the session scratchpad (about 1 GB, including the frozen
  Lean workspace copy).
- The probe compiles and adapter executions created 105 `program-*`
  workspaces (about 122 MB) under
  `tmp/for-loops-predicate-source/.silver/linux-x86_64`, because the
  delivered binaries embed that installation (this is also L10's mechanism);
  none was removed.
- No tracked file in any worktree changed; the shared checkout's status is
  unchanged apart from this untracked report; no issue, comment, label,
  milestone or board entry was touched; nothing was committed or pushed.


## Appended disposition — 2026-10-16

This addendum records the owner's subsequent instruction, “Proceed with the
remediation you have recommended,” and the integration agent's bounded
spot-check/disposition. The original review above is preserved as evidence; its
probes, environment, counts and conclusions remain attributed to that review.
The [repair record](../review-b8f1d0b9a8-repairs.md) tracks the authorized work
and separates original review evidence from remediation validation.

Two corrections qualify the original wording:

- **L1 capacity:** the published 15,028,224-byte envelope uses the false
  63-operator premise. The review's conservative extra allowance is
  `floor(4096 / 6) * 2048 = 1,396,736` bytes, giving a revised
  16,424,960-byte allowance below the 16,777,216-byte buffer, with
  352,256 bytes of headroom. Buffer sufficiency survives this argument;
  the original smaller envelope is not established by it. No proof failure
  was demonstrated. That is the supported conclusion, rather than a claim
  that failure is mechanistically implausible. The selected repair restores
  token-boundary counting and the original premise without enlarging the
  admitted language or changing the Oracle.
- **L2 file counts:** the retained regression input map contains 343 files
  under `proof/`, of which 340 end in `.lean`; the delivery has 462 files
  under `proof/`, of which 459 end in `.lean`. The reported 119 missing
  modules and 39 differing files remain the relevant comparison. “343
  `proof/*.lean`” above should be read as 343 proof-directory files.

L2, L3, L5–L9 and L13 require factual evidence or interface-boundary
corrections. L4 requires an honest description of actual manual cache reuse
and its existing trust assumptions; generic provenance instrumentation,
hostile-cache defenses and a clean rebuild or independent kernel replay are
not part of the selected remediation. Existing review checks of the
proof-tree-sensitive tests should be retained with their input scope and
skips, without a duplicate run merely to obtain a managed record.

L1 is the prerequisite implementation repair. L10/L12 supply practical
adapter retention and diagnostics, and L14 retains useful regressions. L11
and L15 are separately tracked proof follow-ups within this authorization;
they do not become completed by a documentation correction. All require
proportionate validation and the existing assurance/source-correspondence
checks where applicable. No finding warrants reversing milestone 1's
closure, and no later language capability is authorized.

I16 warrants no historical commit rewrite or artificial Stage 3 issue. Use
the standard `Refs`/`Fixes` form prospectively; clarify finding aliases and
renderer-evidence scope in the repair record. A reported seed-independence
check is distinct from the review's delivered-tree re-render. Existing open
findings remain separate except that #31 is reused for L8.

For future reviews, consolidate candidate findings before verification, use
additional independent verification for blocker claims or disagreements, and
make a whole-team cost checkpoint before repeating expensive or broad work.
This economical discipline does not prescribe another 52-verification pass
or weaken required assurance.
