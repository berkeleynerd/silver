# Independent review: selected literal-output native-build capacity (a3af180047)

2026-10-19 UTC. Bounded cross-vendor second opinion, requested by the owner during the
#119 assessment pause, on the "complete selected literal-output native-build capacity
research rule" published for [#145](https://github.com/berkeleynerd/silver/issues/145)
inside [#119](https://github.com/berkeleynerd/silver/issues/119).

**Review target:** `a3af18004743d36328a499760699305357389fb8`, head of draft
[PR #121](https://github.com/berkeleynerd/silver/pull/121) (`research/retained-tool-capacity`).
Implementation freeze `4f29a3bf85`; aggregate review `5e95cf8810`; component targets
`7b84ac0176`/`779acede4c`, `6dd2732dd0`/`3956aa7fb7`, `71624df232`/`ac4694d0f7`,
`b341b7f33a`/`df9ada3f10`. `main` at review time: `44936e7216`; merge-base with the
branch: `2c9018a31a`. Reviewed in a detached worktree (`tmp/review-a3af180047`), read-only.

**Reviewer:** Claude Fable 5.1 (Claude Code), one lead plus 70 subagents in six lenses,
consolidation, three-refuter adversarial verification of every material finding, and a
completeness critic. Models and effort are recorded under [Validation](#validation-performed).

## Verdict

**No blocker. The technical claim stands under its stated premises; one medium finding
and the record's bookkeeping need correction before the owner relies on this checkpoint.**

- *Question 1, composition.* The 475-condition conjunction composes as stated. Any false or
  uncomputed value in either 408-guard map stops every later join; success needs every
  value in both maps to be exactly `True`; no component accepts a caller-supplied premise;
  the predecessor chain is fresh at every level. All 172 nested `open_joins`, residual
  texts and false whole-native flags trace to a current guard, an accepted review, a
  stated premise or work explicitly outside #145.
- *Question 2, cuts and premises.* No gap was found in the cut invariants for the
  selected graph. Several premises are visible only in code and JSON, not in the boundary
  prose (host geometry, per-job environments, host glibc pins).
- *Question 3, the "does not prove" list.* Incomplete in one decision-relevant way: the
  rule evaluates a proposed direct four-job invocation with three added compiler options
  that the production compiler does not issue (M1). It also omits the admitted region.
- *Question 4, remaining work.* The three-item remaining list is generic rather than the
  precise residual scope #145's criteria require (L2), and omits production invocation
  adoption and #131.
- Every number checked re-derives or is conservative; every retained pin verifies; every
  cited tool-source line range contains what the record says at the pinned revisions
  (GCC `6afcc4f6da93`, binutils `5e56594815` = 2.46.1).

**Repair before relying on the checkpoint:** M1 and L1. Recommended with the same edit:
L2 and the admitted-region statement in L5. Everything else is record quality for the
next #119 round.

## Findings

Severity: blocker = acceptance claim unsound or a required native obligation undischarged;
medium = must be closed before #119 can rely on the result; low = record or consistency
defect; info = observation. Severities are the post-verification values: each material
finding was challenged by three independent refuters (correctness, materiality,
reproduction) and survived only if at least two did not refute it. Two findings that
survived formally (L1, L2) were corrected from medium to low by their sustaining refuters.

### M1 — The rule evaluates a changed production invocation that no owner-facing record lists as a remaining obligation (medium)

- **Location.** `docs/research/retained-literal-native-completion.md:184-200`
  (assurance boundary); `result.json` `register_result.predecessor_result.selected_native_invocation.processes[0].argv`
  and `selected_native_GGC_ledger.launch.native_options`; `docs/research/retained-tool-capacity.md:1385-1391`;
  `docs/research/retained-split-options.md:7-8`; `src/silver.adb:120-131`; live bodies of #88, #89, #91, #119.
- **Claim violated.** The contract's required conclusion (`retained-tool-capacity.md:1206-1213`):
  every source passing the rule avoids representation overflow "throughout the selected
  build and all assurance-essential production paths"; and the record's own exclusion list,
  which names only the proof pipeline, current grammar, production launcher implementation,
  SPARK/Lean correspondence and admission.
- **Reproduction.** The evaluated Main job is a direct `gnat1` invocation with
  `-gnat2022 -gnata -gnato -gnatx -Wno-free-nonheap-object -fsplit-wide-types` plus
  parent-generated `-gnatec`/`-gnatem` files; the binder is a direct `gnatbind -x` over a
  fixed two-unit bundle; there is no gprbuild job. Production today runs
  `gprbuild -P program.gpr` over a seven-unit project with `Default_Switches`
  `-gnat2022 -gnata -gnato` only. The capacity contract says "Production flags and
  GNATprove remain unchanged" (:1389-1390) and split-options calls the change "a proposed
  native invocation change; no production command or membership rule changes here".
  `grep` of `docs/session-memory.md`, `roadmap.md`, `docs/unbounded-programs.md` and the
  live #88/#89/#91/#119 bodies finds no mention of `-gnatx`, `-fsplit-wide-types`,
  replacing gprbuild or the four-job graph; #89's body never mentions the launcher or
  option changes.
- **Impact.** Not unsound for the selected graph. But the owner reads the acceptance as a
  capacity rule for "unchanged tools": adopting it requires a production invocation change
  (three added options, direct binder, prebuilt fixed bundle instead of the seven-unit
  project) that is recorded only inside research documents and absent from the authorized
  production package bodies. `-gnatx` changes the ALI class the binder stage prices (no
  cross-reference lines), and `-fsplit-wide-types` changes the RTL route, so the current
  production option set is outside the rule and would need re-derivation.
- **Counterevidence considered.** `result.json` sets `production_launcher_adopted=False`;
  the #145 body says the graph "has fixed Silver object/ALI inputs and no GPRbuild/Gprbind";
  the materialization and invocation-join records assign the launcher to #89. One refuter
  argued the contract takes the options configuration as an input, so no claim is violated.
  Two lenses reached the finding independently and two refuters sustained it at medium.
- **Repair.** State in the completion record's boundary section, in `remaining_parent_119`
  (`compose.py:198-200`), in Round 24 and session memory that the rule evaluates the direct
  four-job graph with the three added options and parent-generated inputs against a fixed
  two-unit bundle, while production runs gprbuild with `-gnat2022 -gnata -gnato` over seven
  units; add production adoption of this exact graph, with its SPARK/Lean correspondence,
  to #89's body as a mandatory obligation (or require re-derivation for the production
  option set).
- **Verification.** Read the four edited records; `grep -n gnatx docs/session-memory.md roadmap.md`
  and the #89 body return the statement.

### L1 — Owner-decision record forked; PR #121 cannot merge as published (low; precondition for merge)

- **Location.** `docs/session-memory.md` and `roadmap.md` on the branch versus `main`;
  PR #121 (`mergeable=CONFLICTING`, `mergeStateStatus=DIRTY`); branch-only commit `186e80e797`.
- **Rule.** `docs/planning.md`: an owner decision "counts as recorded only when a dated
  entry in the session memory on main states it"; the record states "#145 technically
  complete and In review pending merge".
- **Reproduction.** `git merge-tree --write-tree origin/main a3af180047` conflicts in
  exactly `docs/session-memory.md` (two hunks) and `roadmap.md` (one hunk). All four
  2026-10-19 owner decisions used for the work (`36a5b7f729`, `620807834c`, `ed9101c984`,
  `44936e7216`) are on `main`; the branch re-records them as separate commits and
  additionally carries three 2026-10-18 owner entries and the post-#145 assessment pause
  (`186e80e797`, 15:29Z) that exist only on the branch.
- **Impact.** No effect on the rule. The closing commit carries `Fixes #145`, so #145 and
  #146 cannot close until the conflicts are resolved; two divergent histories of the same
  decisions exist; the final pause that justified Backlog status is not on `main`.
- **Counterevidence.** No work was done without a `main`-recorded authorization; the
  conflicts are prose-only and resolvable; `docs/session-memory.md` and `roadmap.md` are
  not among the evaluator's 94 pinned inputs, so resolving them cannot invalidate the
  retained result.
- **Repair.** Carry the still-relevant branch-only entries to `main` in a small docs PR;
  merge or rebase `main` into the branch, keeping `main`'s copies of the duplicated
  entries; stop re-recording `main` decisions as branch commits; note the merge state in
  the #145 In-review comment.
- **Verification.** `gh pr view 121 --json mergeable` reports `MERGEABLE`.

### L2 — The published "residual parent scope" is three generic phrases, not the precise list #145 requires (low)

- **Location.** `compose.py:198-200` (`remaining_parent_119`); completion record :189-199;
  Round 24; #145 completion criterion 5 ("Publish the closed result and precise residual
  parent scope").
- **Reproduction.** The residual is exactly: producer/Why3 consumers and fixed-library
  proofs; current grammar generalization and whole-rule composition/correspondence;
  envelope comparison and final review. Round 23 named the producer residuals; the
  capacity contract's step 3 names decidability and the losses check; #91 names the
  report-only classification under #88 and the #93 re-derivation trigger; #131 is open.
  None appear in the published list.
- **Impact.** The owner is assessing #119 on this checkpoint; the 80% judgment cannot be
  checked against an enumerated remainder, and named open items are easy to lose across
  the pause.
- **Counterevidence.** The items exist elsewhere on the branch; the three headings match
  the owner's own resumption wording. One refuter rated it informational for that reason.
- **Repair.** Replace or supplement the three strings with an enumerated list: the Round 23
  producer residuals, #131, the #88 dependency-test classification of Image and
  report-writer limits, decidability and checked accounting, the losses check against
  current admitted shapes, the #93 and toolchain re-derivation triggers, and M1's
  production invocation adoption.

### L3 — Two stage flags and several guards are literal constants; "twelve explicit stage entries" overstates what is computed (low)

- **Location.** `compose.py:168` (stage 5 `Main_gigi_GIMPLE_CFG_SSA_shared_storage = True`);
  `retained-literal-driver-completion-20261019/compose.py:303` (stage 2 literal, consumed at
  `compose.py:162-165`); `retained-literal-invocation-join-20261018/compose.py:314-316`
  (three literal `True` register guards `native_invocation_*` and half of stages 7, 9, 12);
  `shells.py:62, 73, 101, 108-109`; binder `compose.py:252-254`.
- **Claim.** Completion record :59-61: "Twelve explicit stage entries prevent an uncomputed
  component from becoming a successful whole-native result."
- **Reproduction.** Stage 5 is reached only when all 408 register guards are `True`
  (`compose.py:103-115`), and those guards do contain fresh entries for the gigi, GIMPLE,
  CFG, SSA and shared-storage owners, so the stage is semantically "all 408 passed", not an
  independent closure. The driver component has no conditions map; its checks are
  `require()` calls, so its stage can never be `False`, only an exception. Stages 10-11 are
  arithmetic over retained constants no source can falsify.
- **Impact.** Presentation only. The 1,632-case mutation claim includes three guards no
  evaluation can make `False`.
- **Counterevidence.** Nothing is unsound: every literal sits behind `require()` gates; a
  false owner guard stops the join with the guard named in `native_residuals`.
- **Repair.** Compute stage 5 as an explicit conjunction over the named guard subset; return
  a conditions map from the driver component; label literal and constant guards in the
  record's coverage table.

### L4 — The "actual binder family" check compares a retained constant with a copy of itself; the invariance argument is unwritten (low)

- **Location.** `compose.py:147-150`; `retained-literal-invocation-join-20261018/compose.py:289-292, 307-312`;
  completion record :145-148, :176-178; aggregate review :183-185;
  `docs/research/retained-literal-invocation-join.md:176-199`.
- **Claim.** "The join requires the actual binder family to have 16 sections, 243 symbols,
  134 relocations ... before passing that interface to the current source-bound linker."
- **Reproduction.** `build()` takes the binder object interface from the retained Hello
  capture regardless of the source; `compose.py:147-150` then requires that constant to
  equal a literal dict of the same numbers. The source-sensitive witness
  `binder_source_from_ali` (:330-351) is never called. The written invariance argument
  covers the U-line version, W/Z closure and D timestamps but not the P parameters, R/RV
  restriction lines, SS line and U flags that `bindgen.adb` also serializes.
- **Impact.** The all-checksum binder-compiler transfer (E=56,378; B=5,167,732; M=262,144),
  the assembler family and the 16-section link input are premises transferred from one
  capture under a fixed-closure argument, not checks on the evaluated source, while both
  accepted records describe them as checks on the actual binder.
- **Counterevidence.** A `bindgen.adb` inventory at the pinned revision (lens 2) shows those
  consumers are fixed for the admitted family by configuration, switches and unit kind, and
  the scanner's bracket-encoding path cannot fire inside an admitted literal, so the
  invariance holds; all four retained captures differ only in four object bytes.
- **Repair.** Reword both records; copy the `bindgen.adb` consumer inventory into the
  invocation-join record; optionally derive the interface from the retained binder-options
  result instead of a literal, or call `binder_source_from_ali` when an ALI is available.

### L5 — No retained test forces a component guard false through `attach`, no family member is shown rejected, and the admitted region is unstated (low)

- **Location.** `check.py:40-97`; packet README :17-21; aggregate review :194-201; the
  binding guards at `retained-literal-relocation-refinement-20261018/{derive.py:23-36,result.json}`
  and `retained-literal-assembler-20261018/compose.py:91`.
- **Reproduction.** `check.py` injects `False`/`None` only into the 408 register guards and
  five summary flags; the late path (`compose.py:158-188`) that turns a component guard into
  a named residual is exercised only by the aggregate reviewer's untracked `probe.py`, and
  that probe covers stages 1-4, 10 and 11, not 7, 8, 9 and 12. No real family member is
  shown rejected anywhere in the retained evidence. The record never states the admitted
  region. The relocation-refinement packet itself retains the boundary for one-byte-literal
  programs: 30,653 calls pass and 30,654 fail the refined signed-reach check
  (`adjacent_unit_literal_call_boundary`); the GAS 16-bit region rule
  `max(10, 2C+1) <= 65535` rejects at 32,768 calls; the GGC page-index guard binds far
  later (near 880,000 calls). Lens 1's first estimate (the GGC guard) was therefore wrong
  about which guard binds first; the three figures are shape-dependent and none is in the
  record.
- **Impact.** The rejecting direction of the aggregate's own logic rests on unretained
  scratch for four stages, and the owner has not been shown that the "complete" rule's
  useful domain for this family is roughly 30,000 output calls, set by a guard the
  assembler record itself calls a conservative sufficient rule needing a consumer argument.
- **Counterevidence.** The guards are sound in the rejecting direction; the rule is
  deliberately not a cap; the capacity contract defers the useful-domain comparison to its
  step 3.
- **Repair.** Add retained `check.py` cases forcing one component guard and one late stage
  false through `attach`, with a key-collision assertion; add an "Admitted region" paragraph
  listing the binding guards and the retained 30,653/30,654 boundary; retain the reviewer's
  probe files in the review packet.

### L6 — #131 is open with a stale "unfinished" status while the record calls the matching flags historical (low)

- **Location.** `result.json` `register_result.predecessor_result.core_result.open_joins.native_post_prefix_imported_frontier`;
  `retained-literal-pipeline-20261018/compose.py:1893-1894`; completion record :73, :194-196;
  GitHub #131.
- **Reproduction.** `imported_constructor_frontier_established` and
  `Main_is_only_defined_body_established` are hard-coded `False` in the pipeline evaluator
  and never updated. The frontier's numbers are supplied by later packets (warning-residual
  bound R <= 5, counter-emission, synthetic-function and String ledger rows) and accepted
  reviews, but the completion record does not name them, and #131's last comment says the
  derivation "remains unfinished under #119".
- **Repair.** Add a discharge table (nested flag or open join -> discharging packet, review
  and current guard keys) to the completion record; update or close #131 and #146 on merge.

### L7 — Capture-host pins are premises visible only in code and JSON (low)

- **Location.** `retained-literal-invocation-join-20261018/compose.py:171` (cwd exactly
  109 bytes, TMPDIR exactly 48); `shells.py:55` (`LC_ALL=C`, no `GLIBCXX_TUNABLES`);
  `result.json` `fixed_link_inputs` (host `/usr/lib/x86_64-linux-gnu` glibc and crt files by
  sha256); per-job environment key sets (Main has `LANG=C`, the binder job has no `LANG`).
- **Impact.** A consumer of the four stated premises cannot tell that the verdict transfers
  to another host only if it reproduces this exact geometry, glibc build and environment, or
  re-derives the route. The 15 host-pinned link inputs currently match on the reviewing host.
- **Repair.** Enumerate them in the boundary section and as a `host_pins` object in
  `result.json`, each marked as a #89 construction obligation or a re-derivation trigger.

### L8 — Parent arenas are chosen design constants that can reject a plausible host (low)

- **Location.** `retained-literal-native-materialization-20261019/compose.py:20-26`
  (`ARG_BYTES=2048`, `ENV_BYTES=1024`, `PATH_BYTES=512`, 17/7 slots);
  `docs/research/retained-literal-native-materialization.md:250-265`.
- **Reproduction.** From `result.json`: the link argv is 1,493 bytes with five occurrences
  of the 46-byte checkout root, so `exact_parent_vectors_fit` becomes `False` once the
  checkout path is about 111 bytes longer; the environment has about 153 bytes of headroom.
- **Impact.** No effect on the rule; a classification note for the owner's forced-versus-
  chosen criterion. These are host-configuration caps, reported as configuration failures.
- **Repair.** Size the arenas from the actual path lengths at launch within `PATH_MAX` and
  `ARG_MAX`, or document them as parent-design parameters with the computed headroom.

### L9 — Recursion depth is classed as physical with no statement that traversal depth is independent of C beyond the Ada frontend (low)

- **Location.** `retained-literal-lra-arithmetic-completion-20261019/derive.py:119`
  (`physical_stack_capacity_established=False`); `retained-literal-ada-residual-completion-20261019/completion.py:95-99`
  (frontend depth recurrence); completion record :186-189.
- **Impact.** A source-sensitive stack depth would be admitted silently as "physical".
  The family is flat, so the risk is low.
- **Repair.** One aggregate sentence that traversal depth is bounded independently of C and
  N for gigi, GIMPLE, RTL, GAS and ld, citing the flat-list arguments, or list tool recursion
  depth among the unproved classes.

### L10 — Invalidation triggers are not consolidated (low)

- **Location.** `inputs.json` (94 rows, seven of them `docs/research/*.md`); `compose.py:52-56`;
  `result.json` `fixed_link_inputs` and the Silver_IO/silver_output_libc pins with D-line
  timestamps.
- **Impact.** During the pause, a host OS update, a bootstrap regeneration of the runtime
  library, or a typo fix in a pinned research document makes `compose.py` raise
  "changed aggregate input"; the record does not say so in one place. This also answers the
  owner's pause question: changes to runtime library bytes or timestamps, toolchain
  contents, compiler or binder options and environments, the GCC/Ada/GAS corpus pins and
  the seven pinned documents invalidate the result; driver, tooling and documentation
  changes elsewhere do not.
- **Repair.** A "Re-derivation triggers" paragraph in the completion record and Round 24.

### L11 — 5,242,880 is labelled the first-collection threshold but is a conservative constant (low)

- **Location.** Completion record :151-152; `shells.py:93, 104`.
- **Reproduction.** At the pinned commit, `ggc-page.cc:2292-2306` and
  `ggc-common.cc:1069-1123` give a host-independent minimum heuristic threshold of
  4 MiB x 1.30 = 5,452,595; the selected argv passes no `--param`; no forced or
  unconditional `ggc_collect` lies on the gnat1 path. `retained-binder-options.md:146-149`
  already derives this and adopts 5 MiB as a lower bound.
- **Impact.** None on soundness (the true margin is at least 284,863 bytes); the
  completion record presents a chosen lower bound as the tool's threshold.
- **Repair.** Rename the field to a lower bound and cite the source minimum.

### L12 — "Allow 50 optimization-vector entries" is not the capacity a 50-push vector reaches (low)

- **Location.** Completion record :107-109, :115; `shells.py:37`.
- **Reproduction.** `toplev.cc:2333-2340` pushes at most argc-1 = 24 options; the `vec.h`
  growth rule gives capacity 24 (2,312 bytes). A 50-push vector would reach capacity 54
  (5,192 bytes), above the stated 4,808. The bound holds because pushes are at most 24.
- **Repair.** State the push bound and compute the request from the growth rule.

### L13 — "Independent review" means a same-vendor subthread assigned by the lead (low)

- **Location.** Round 24; aggregate review :12-20; driver review :151-158.
- **Reproduction.** All 18 implementation, review and integration commits carry one Git
  identity; every report says "assigned by the lead"; the lead authored the parent, register
  adapter, binder-assembler integration and the aggregate; driver and Ada lane authorship is
  undisclosed; the aggregate reviewer authored the binder component and excludes it.
- **Impact.** Independence is a statement of process rather than something a later reader
  can verify. This review is the first cross-vendor check of the result.
- **Repair.** A lane table in the round record naming who authored and who reviewed each
  component, and an explicit definition of "independent".

### L14 — Independent reviewers' fresh checks are not retained in the repository (low)

- **Location.** Aggregate review :176-201 (92 checks), driver review :134-146 (593),
  binder-assembler review :133-138 (663), frontend/binder review :42-45 (1,031); Round 24's
  `tmp/native-freeze-check-4f29a3bf85.json`.
- **Reproduction.** Only author-side numbers are retained and they match their files
  (7,451; 34; 232,430; 773; 3,301). The reviewer counts exist in prose and in untracked
  scratch (`tmp/literal-native-completion-review-20261019/tmp/native-review/` on this host).
- **Repair.** Commit the probe scripts and outputs under the review packets before PR #121
  merges, or state that they are prose-only.

### L15 — The aggregate packet identifies the tool corpora only transitively and by worker-host `/tmp` paths (low)

- **Location.** Packet README :53-62; `inputs.json` (no `gcc_revision` or binutils key).
- **Repair.** Add `gcc_revision` (6afcc4f6da93), the Ada tree provenance and the binutils
  tag (2.46.1, `5e56594815`) to the packet, and replace the `/tmp` example roots with the
  retained tarball locations.

### L16 — Stale `pending` review-status literals inside accepted evaluators (low)

- **Location.** `retained-literal-ada-residual-completion-20261019/completion.py:159`;
  `result.json` attachment `independent_attachment_review_status` fields (eight).
- **Repair.** Replace with the accepted review identifiers or drop the fields; they are not
  consumed by any guard.

### L17 — Two cited GCC files are not in any retained tarball (low)

- **Location.** Aggregate review :138-139 (`value-query.cc:193-294`, `gimple-range-edge.cc:69-85`).
- **Reproduction.** Pinned by hash only; the mirror copies match and contain the named
  constructors and destructors. Partial excerpts exist in `retained-backend-gigi-20261018/source-excerpts.md`.
- **Repair.** Retain the two files in a sources tarball.

### L18 — Finding issue titles deviate from the planning convention (low)

- #131, #144 and #146 are not titled `review-<commit> <id>: <summary>`; #143 is.

### L19 — Whitespace (low)

- `docs/research/retained-literal-binder-assembler.md:130` ends with a new blank line;
  the other 1,021 `git diff --check` hits in `2c9018a31a..a3af180047` are inside captured
  tool outputs.

### Informational

- **I1.** Main compile makes no collection-count claim; its collector guards are monotone
  under marking collections, so the omission is consistent with the rule's scope.
- **I2.** Several individual request bounds are envelopes above the source-derived request
  (1,928 vs 4,104; about 344 vs 512; 4,064 vs 4,096; W+115 vs W+116; 78,895 vs 84,565;
  2,312 vs 4,808), all conservative.
- **I3.** The executable census constants (394 pass instances; 57/94 and 8/4 and 30/3 roots
  and registrations) are consistent with retained records but not re-derivable offline.
- **I4.** The family alphabet is printable ASCII plus HT/LF/VT/FF/CR; VT and FF are trivia
  here but excluded by current admission; counts are bytes and characters at once. Neither
  is stated in the completion record.
- **I5.** The 80% figure is labelled a planning judgment everywhere, but Round 24 drops the
  65-80% interval and the whole-rule-integration caveat Round 23 carried.
- **I6.** The managed-run ledger is keyed by hostname hash: this sandbox's readout is empty,
  while the worker host's registry (`d140f139bb2e1ef1`, `codex-silver`) in the shared `.git`
  shows exactly the two #145 native runs the record claims and none for the aggregate.
- **I7.** The lead's model and effort are never runtime-confirmed; the recorded selections
  match the 2026-10-18 policy on `main`.
- **I8.** Round 24 cites the reviewer's replay timing (0.011062663 s) for the
  binder-assembler author checks; the retained author value is 0.011399536 s.
- **I9.** GGC events are not affine in C and N (47,058; 49,735; 69,931; 12,214,678 for
  C/N = 1/0, 2/2, 10/10, 5000/0); the register packet should publish its closed form.

## Refuted candidates

Fifty-four candidates were refuted inside the lenses, and one consolidated finding was
refuted in verification. The ones a later reader is most likely to raise:

- *Stage 5's literal `True` makes the gigi/GIMPLE/CFG/SSA stage unsound.* Refuted: it is
  reached only when all 408 guards, which include fresh guards for those owners, are `True`.
- *A component accepts a caller-settable premise or remainder flag.* Refuted: none does;
  `caller_settable_residual_safe_premise=False` is a constant declaration.
- *The residual texts under `source_family_condition_assessments` are undischarged.*
  Refuted: they are core-level historical copies promoted only after `require()`d equality
  joins over freshly built interfaces.
- *The binding admitted-region guard is the GAS region rule at C <= 32,767.* Refuted as
  stated: the refined linker signed-reach guard binds first, at 30,654 calls for one-byte
  literals, as the relocation-refinement packet retains. The residue (no stated region) is
  in L5.
- *A Main first-collection guard is missing.* Refuted: the ledger makes no such claim and
  its guards do not depend on collection count (I1).
- *The register schema read from a retained `result.json` could mask guard-set drift.*
  Refuted: that file is pinned and `attach` requires exactly the 408 keys with typed values.
- *The binder runtime pass-through weakens the invocation equality check.* Refuted: the full
  supplied-graph equality remains.
- *Independent review was absent.* Refuted as a defect: the record never claims
  cross-vendor review; the residue is L13.

## Coverage gaps and confidence limits

High confidence in composition logic, open-join tracing, pin and hash integrity, numeric
reconciliation, cited-line existence, the GCC and GAS source projections sampled, the
first-collection derivation, the process timeline and the merge state. Medium confidence
in the completeness of the "does not prove" list beyond M1 and L7-L9.

Not done: no evaluator was executed (its source roots exist only on the worker host); the
120-owner Ada table census completeness was not re-derived; the binder component's internal
source argument rests on one same-vendor review; the #146 four-event correction was not
re-derived from IRA source; the 408 register guards and the 41 added predicates were treated
as accepted history (reviews `9967a422b6`, `f71b1937bc`) and not reopened; the 512-byte
diagnostic-control bound was summed for three of its objects only; the production
recognizer (`src/silver_profile*.adb`) was not compared with the research recognizer; the
integration-check artifact cited in Round 24 is absent on this host. Lens 1's original
citations for `shells.py` (:175, :206) were wrong (the literals are at :62, :73, :101,
:108-109) and are corrected above. My orchestration prompt described `main` as
`0a98153803`; `main` had moved to `44936e7216` and the merge-base is `2c9018a31a`, as lens 5
found.

## Validation performed

- Read-only static review in the detached worktree: the completion record, aggregate and
  component reviews, Round 23-24, the capacity contract's required-conclusion and
  next-derivation sections, the evaluator and test scripts, the component evaluators, the
  2026-10-19 session-memory entries, roadmap, scope, and the live #88, #89, #91, #93,
  #119, #131, #145 and #146 bodies and comments.
- Python over `result.json` and `check-results.json`: 475 = 408 + 11 + 15 + 4 + 6 + 10 +
  8 + 1 + 12; both maps identical and all `True`; 172 open-join and residual groups traced;
  all 94 `inputs.json` pins and 16 `prior_results` rows verified by sha256; three fresh
  source cases and the 1,632 fault cases recounted; E/B/M, object interface and argv counts
  reconciled with their source packets.
- Source projections checked against retained tarballs and the pinned revisions fetched
  read-only from GitHub mirrors: `sizeof(cl_decoded_option)=96`, decoded-option sizing,
  the saved optimization vector, `vec.h` growth, finalizer registration and sizes,
  page-pointer capacity, `N_OPTS=2556` from the installed plugin `options.h`, the
  first-collection heuristic, `GGC_COLLECT_FORCE` sites, GAS decimal accumulation,
  negation, `O_constant`, `rs_fill` and input-scrub growth, and the `bindgen.adb` consumers.
- Process: dry merge with `git merge-tree`; byte identity of the four integrated review
  files against their original commits; commit timeline; `scripts/dev.py runs status`
  readout; board statuses (#119 Backlog, #145 and #146 In review); relative-link and
  `git diff --check` checks.
- No GNATprove, Lean, gcc, gprbuild, assembler, linker, capture, evaluator, test-suite or
  proof run; no tracked file, issue, board field, PR or session-memory change; no commit.

## Elapsed time and token usage

| Activity | Elapsed |
| --- | --- |
| Scouting: target verification, worktree, record mapping, evaluator reading | about 38 min (15:47-16:25Z) |
| Lens 1 (composition and open joins), run first as a cost sample | 23.8 min |
| Five lenses in parallel, consolidation, 63 refuter runs, critic | 49.6 min (ended 17:40Z) |
| Fact confirmation of M1 and L1, side-effect audit, report | about 25 min |

Models and effort: Claude Fable 5.1 throughout; lenses 1-3 at max effort, lenses 4-6 at
high; consolidation at medium; refuters at max for medium findings and high for low;
critic at high. Harness-reported subagent tokens: 311,644 (lens 1) + 6,513,968 (the
remainder) = **6,825,612**, plus about 0.2M in the orchestrating session; 71 agents;
1,240 tool uses. The owner reported the week's plan usage at 6% after the cost sample.

## Artifacts and side effects

- This report, untracked, at `docs/reviews/review-a3af180047.md` in the shared checkout.
- Detached review worktree `tmp/review-a3af180047` at `a3af180047`, clean; an ignored
  `scripts/__pycache__/` was created there by the `dev.py` readout and is preserved.
- Review scratch (lens notes, extracted tarball copies, refuter notes, `full-result.json`),
  44 MB, under the session scratchpad
  `/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/`
  (`lens1-composition/`, `lens2-source-projections/`, `lens3-boundary-gaps/`,
  `lens4-remaining-work/`, `lens5-process-records/`, `lens6-evidence-integrity/`,
  `verify-*/`, `critic/`). This directory is sandbox-local and will be lost with the sandbox.
- Fetched `origin/main` and `origin/research/retained-tool-capacity` refs into the shared
  `.git`; read-only HTTPS fetches of pinned GCC and binutils files from GitHub mirrors;
  read-only `gh` queries.
- No tracked file, issue, milestone, board field, PR, session memory, CLI memory, proof
  cache, workspace or other-host artifact was modified. Existing worktrees, scratch and
  the Codex reviewer's untracked probe directory were preserved.
