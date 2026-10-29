# Constant Integer-array iteration integration review — 2026-10-28

Interim verdict: no native admission or semantic integration defect found. One low-severity catalogue/specification consistency finding (R1, #267) was repaired during this review. The typed bridge's final proof and complete validation checkpoint remain pending; this report does not describe the feature as supported.

## Scope and inputs

Owner-authorized #264, stacked PR #266. Reviewed integration `7c18c6a02fbf9d222fd801be31f44ccada20edd5` against parent `0a85336c83`, principally `src/silver_output_profile.adb`, specification/catalogue changes, new tests/sample, capacity account and changed source pins. Native scanner SHA-256: `09858656aa96cdff7cc6f1ebc6683ce70885840e94df9706420b4c4e45ed6abc` (confirmed). Read `AGENTS.md`, Oracle, capability record and relevant assurance, trusted-boundary and validation requirements.

Reused the positive independent core/source-model review in `docs/reviews/review-constant-array-iteration-core-20261028.md`, covering core `73a40b56e5` and source-model `b7649bafed`; those arguments were not reviewed again. Reused the bounded producer-source review recorded in `docs/constant-array-iteration-report-capacity.md`; checked its integration premises and revised formula without rerunning its probes or duplicating producer-source inspection.

Also reviewed frozen typed-bridge definitions in `tmp/constant-array-native` over `995e71879e9669d4d719f86da3573bccb7a49a35`: `PredicateLoopNative`, `PredicateLoopImports`, `PredicateLoopHelpers`, and `PredicateLoopSizing`. The changing `eval_equation` tactic proof was intentionally excluded until its final commit. Exact interim hashes:

| Input | SHA-256 |
| --- | --- |
| `PredicateLoopNative.lean`, prefix before `theorem eval_equation` | `c8e491bf82b2d711e7d7b008ad384d2153ddf63a824d139b7caf4d5db982e6fc` |
| `PredicateLoopImports.lean` | `52971100fbbfaf6ad446722c4bcd26cca9e95eaecc05a41534bb35c095a481c8` |
| `PredicateLoopHelpers.lean` | `66d5c07ab69ab67c30ea38abc58641e9f64ceb82d454f800530266a3eec1be76` |
| `PredicateLoopSizing.lean` | `1a8837141512eec98a50bb22cea4581ff6ce2bd1a3616e29f69bf5e32fb2c4b2` |
| Updated guarded-singleton test file | `deb766a45a461cc9fcaf114193e44782cf6ad8ba0b7f44c856291fb1f1eae953` |

Selected reviewer configuration: GPT-6 Astra / Extra High. Runtime confirmation, token and cost measurements unavailable. Review started 11:02:34 UTC. Read-only inspection, including token-delta extraction; no Lean, native, build or test run, repository changes, GitHub mutations or additional agents.

## Findings

**R1 — Low, catalogue/specification consistency, repaired.** Existing `integer_expression.conditions.operand_kinds` omitted scoped elements and `scalar_guard_refinement.conditions.target` listed only mutable objects and indexes, contradicting the new iteration entry and native behavior. Related hiding, staticness and immutable-binding summaries also omitted elements. The lead recorded #267 and updated `catalogue/silver.json`, its embedded Ada emitter and `language.md` together. Reviewed repair bytes include `scoped_for_element`, bare element refinement targets, singleton-element nonstaticness and enclosing-element preservation. No scanner change was required. Byte-parity/build/audit validation remains the lead's checkpoint work.

Reviewed repair hashes: catalogue `52064c3ce8c53b9f972a520f3fceb6eaba1a1f454e2d2b6d8ac9a9540d8fa2f5`; emitter `7a6db9d3c8bebf914f79cbf2d375a1b7b0de797cf24a9038eeaf68ca140a3191`; language `79f4f6fd32729eb6c135380bea71c94f231cc6acef56da1d961a8e3a796f4cfe`.

## Critical integration checks

- Native `Loop_Body` resolves a bare existing array through `Array_Target` before extending scope; active scalar bindings hide arrays. It rejects mutable iterables and the element's own spelling in its iterator specification. Closing syntax rejects slices, expressions, filters and subtype indications. The same name restrictions and body reader retain existing nesting, operation/type hiding, assignments, output and argument-shell Reject.
- The appended binding has Full declared/current bounds, `Static = False` and `Mutable = False`. `Reading_Names` changes only current bounds; a guard refining an element to a singleton cannot turn it into an Ada-static threshold. The added negative regression `if E=1 then if N=E then B(N):=0` specifically distinguishes that property. Direct element assignment fails the existing mutability check.
- Mutable scalar facts are widened on entry and remain widened on exit. Outer immutable/index/element facts retain their entry bounds. Full is nonempty and admitted arrays are nonempty, so the body path is retained while the scoped binding disappears. Reject remains returning/sticky rather than eliminating its branch; no scalar contradiction prunes independent String/input paths. These native transfers agree with the previously reviewed universal composition argument.
- Actual-component semantics come from compiling/proving the unchanged author source and the inspected frontend's component-renaming expansion, together with the reviewed recursive component-preservation and source-derived binder-separation theorems. The implementation adds no snapshot or rewritten author program.
- The typed command/render definitions reproduce the new Ada `of` branch, local array lookup, immutable Full binding and common body/exit flow. New imports are linked to existing checked lexical equality and `ArrayBodyNative.linked_target`, rather than assuming scanner/model equality. The `of` token and Full interval are included in the import contract. The unchanged `eval_equation` conclusion has only the existing count premise; the new array case introduces no program-author assumption.
- Both changed source pins carry exactly the same semantic delta: the `of` branch and relocation of the common progress guard after the two headers. `ReviewedOutputShape.outputImplementation` grows from 36,435 to 36,617 tokens; `PredicateLoopCandidate` from 962 to 1,144. The rendered-tree/source-candidate and generated byte-certificate checks must still complete; updating these pins alone is not correspondence evidence.
- The producer account retains actual-component renaming, one-dimensional counted-range lowering, single executable body traversal and no new report class. The conservative `24*L + 8*W <= S` warning charge and separate element-reference/renaming index charges yield 31,269,376 bytes within 32 MiB. The regression formula matches the account. This reuses the recorded producer inspection, not sample-based universal inference.

## Remaining completion evidence

Final typed-bridge commit and proof result; complete Lean/module/axiom/source-correspondence checkpoint, including generated certificate; complete native audit/build/regression coverage on final inputs, including the catalogue repair; final Rosetta/capability-status reconciliation. These are assigned delivery obligations, not additional review-infrastructure requests. Final inputs and evidence can be appended to this report without repeating established core or producer reviews.

## Final typed-bridge follow-up — 2026-10-28

Verdict: no actionable defect found; the bounded typed native loop-interpretation layer is closed. This supersedes the interim exclusion of `eval_equation` above. Complete source correspondence and final capability validation remain pending.

Exact new inputs: bridge commit `3255e9ddecae4609418b27b19bebfcc8c943574a`, read in isolated validation snapshot `1e7f42f0c145b62eedbc4bc404b080ea37ed3c81`; final `PredicateLoopNative.lean` SHA-256 `bc7acdb39f8cd7697e22c2a7736c060b2bbfe1a57cbf113bfb723c544561d740`. The prefix before the new private staging definitions hashes to the previously reviewed `c8e491bf82b2d711e7d7b008ad384d2153ddf63a824d139b7caf4d5db982e6fc`. Imports, Helpers and Sizing retain their interim hashes. The separately integrated `PredicateLoopCandidate.lean` is `c6de6cf2a3692e58f89caf9e6be9237e95e16771b0b4dc841321fe2a204acb6e`; this is the reviewed new pin, not the older candidate in the bridge commit's ancestry.

- `commands_decompose` is definitional equality to the exact command tree. Private staging definitions therefore do not substitute a different interpreter or discard a branch.
- `array_eval` accounts for optional reverse, captured lookup and the explicit invalid-array guard. The rejected-array case in `eval_equation` derives zero header position and hence the source equation's early rejection. The counted branch is retained through `counted_eval`.
- `tail_eval` derives copied-flow length and the fresh binder slot from the existing count premise. It covers the same arbitrary recursive body reader, early returns and complete closing tokens. Its internal frame-facts premise is discharged by reflexivity for both concrete header frames; it adds no caller assumption.
- `header_exit` establishes the Full/nonempty array case and the existing counted empty/definite/join cases. `array_tail` and `counted_tail` connect those transfers to `loopAfterHeader`. The final public `eval_equation` statement is unchanged: it assumes only the existing flow/context count equality and concludes interpreter equality for arbitrary reader/text/context/scan. No new axiom or semantic premise appears.

Reviewed retained run `20261028T112717-49ee7b84b5ec`: `retained.json`, original compressed events, focused evidence and log under `docs/evidence/constant-array-iteration-20261028/runs/`. Verified all three retained compressed/original hashes. The five target bytes match the event's input hashes and the validation snapshot; all four bridge files also match the authoritative bridge commit. Seven other captured source files differ from that snapshot (six proof modules and the catalogue emitter); none of the six proof modules occurs in this focused run's imported/audited module inventory, so they do not invalidate this bounded evidence. Their integrated source proof remains separate.

On `linux-x86_64`, Lean 4.34.1, one worker/thread and a 4,096 MiB process limit, the incremental five-target build passed in 169.896 seconds and a newly executed audit passed in 26.155 seconds: 34,099 declarations, foundations `[propext, Classical.choice, Quot.sound]`. The evidence says `clean_build: false` and `kernel_recheck: null`; this is not a clean rebuild or independent kernel replay. The managed run completed successfully with no failure keys. No execution was repeated by this reviewer.

Selected reviewer remains GPT-6 Astra / Extra High; runtime confirmation and token/cost data remain unavailable. This follow-up ran 11:32:52–11:34:30 UTC (98 seconds of wall time through the final evidence inspection). Read-only except for appending this report; no builds, proofs, tests or GitHub mutations. No additional finding or rework. The ongoing source-candidate run's entry basis is the prior definitions/native/source review plus focused bridge build/audit; this follow-up supplies the final tactic-proof review without retroactively claiming it preceded that run.

## Provisional regression applicability — 2026-10-28

Scope: stable full-suite snapshot `8e85dd5d3b` to validation snapshot `1e7f42f0c145b62eedbc4bc404b080ea37ed3c81`, before pending Rosetta commit `c5a23c13f4`. The Git delta is exactly the four reviewed typed Lean files and this review document. Native sources, scripts, tests, samples, catalogue, project/toolchain inputs and certificate generator are byte-unchanged. The retained `test-inventory.json` identifies 540 distinct test IDs at `8e85dd5d3b`; the test inventory does not change across this delta.

The affected test modules are exactly `test_lean_source` and `test_platforms`. The planned rerun of both modules covers 28 inventory IDs and is sufficient. A smaller complete selection is these 15 IDs:

- `test_lean_source.CompilerSourcePolicyTests.test_include_str_is_confined_to_the_source_bindings`
- `test_lean_source.CompilerSourcePolicyTests.test_only_audit_roots_use_legacy_full_imports`
- All 12 `test_platforms.PlatformIsolationTests` IDs in the retained inventory.
- `test_platforms.InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`

The two source-policy tests traverse every project Lean file. `PlatformIsolationTests.setUp` copies the complete Lean tree, so the class's fixture inputs change; the TMPDIR regression invokes that same class in a subprocess. The Compose candidate/source dependency tests read narrower import closures that contain none of the four changed modules, even after the new Helpers import. Other tests in these two modules read unchanged certificate/source-binding/audit files or synthetic inputs; rerunning the entire modules is a conservative superset.

No additional affected test module was found. Inspected `test_lean_evidence`, `test_lean_modules` and `test_lean_run_history`: their project fixtures are synthetic, with real-file reads confined to unchanged audit modules, Lake/toolchain files and authoritative source-binding modules. Native/provenance/static-proof, report, application and sample tests use unchanged Ada/runtime/project/script inputs; the native provenance input list excludes these Lean files. The review-document addition has no test reader. This assessment does not substitute for the independently required whole-Lean/source checkpoint.

Full-suite run `20261028T110929-97e25e5a798e` was still running at this assessment. No pass or complete-coverage claim is made. Once its terminal log is available, unchanged successful results may apply to the final snapshot subject to matching settings and the complete 540-ID inventory. Every failed, incomplete, missing or newly affected test still needs successful coverage. With the planned 28-ID rerun, the other 512 IDs are candidates for retained-result reuse, not presently asserted successes. Later Rosetta changes and their metadata checks are outside this assessment and require their own applicability review.

Selected reviewer: GPT-6 Astra / Extra High; runtime confirmation and token/cost measurements unavailable. Read-only source/dependency/inventory inspection, 11:37:40–11:39:37 UTC (117 seconds through final input comparison); no test/build/proof execution or GitHub mutation.

## Regression coverage closure — 2026-10-28

Verdict: the regression/sample layer is complete for integration `f57c097f5d1395c979bb11233d9a4c7da7a5638d`, with the final bridge integrated as `fd9761af5c`. Governed implementation, proof, test, script, sample, catalogue and project inputs match validation snapshot `1e7f42f0c145b62eedbc4bc404b080ea37ed3c81`. This closes the provisional applicability section above. It does not close the pending complete native or whole-Lean/source assurance checkpoints, or the later Rosetta metadata delta.

Read original events, logs and `retained.json` for the following three runs in `docs/evidence/constant-array-iteration-20261028/runs/`, plus `test-inventory.json` and the updated `regression-applicability.json`. Verified every retained compressed/original event/log hash, parsed actual individual test identities and outcomes, and independently compared the recorded prepared-input hashes to final files.

| Run | Observed result | Applied evidence |
| --- | --- | --- |
| `20261028T110929-97e25e5a798e` | 540 IDs: 539 `ok`, one `ERROR`; terminal failure | Retain 512 successful IDs outside the two affected modules |
| `20261028T123939-44279f5d51d8` | Exactly all 12 `test_lean_source` IDs `ok`; terminal success | Replace that affected module's results |
| `20261028T131129-d738104f578d` | Exactly all 16 `test_platforms` IDs `ok`; terminal success | Replace that affected module's results, including the earlier error |

The full-run IDs equal the 540 distinct retained inventory IDs, including the three Rosetta tests whose descriptions span two log lines. The union of the 512 retained passes and 28 rerun passes equals that inventory exactly: no missing, extra, skipped or unresolved failing ID. The full run remains failed; the combined evidence establishes regression completion under the repository's reviewed-reuse provision, not a newly claimed single successful full-suite run.

All three runs captured the same 788-path input set. Both successful reruns' 788 hashes match final bytes. The full run differs only in the four already-reviewed typed Lean files; the exact differences agree with `regression-applicability.json`. Their affected-test closure remains the two rerun modules. Native/compiler, test, fixture, script and sample inputs are unchanged. No timeout or assertion was relaxed: the original failure is `TimeoutExpired` in the symlinked-TMPDIR subprocess at 180 seconds, and the successful final rerun used the same 180-second limit and assertions. The logs establish the timeout and subsequent success without proving a causal explanation for the timing difference.

`test_samples.SupportedSampleTests.test_manifest_samples` passed in the retained full run. Its unchanged manifest contains 50 samples and 106 execution cases; the test iterates and checks each case, original source identity and application proof-policy/report audits. Those sample results therefore remain applicable.

Selected reviewer remains GPT-6 Astra / Extra High; runtime confirmation and token/cost data unavailable. Review ran 13:25:19–13:27:21 UTC (122 seconds through final input/timeout inspection). Read-only except this report append; no tests, builds, proofs or GitHub mutations. No new finding. The interrupted earlier native run and active replacement native run are not successful whole-native evidence; their cache handling is outside this regression closure. Pending Rosetta metadata and whole assurance require their separately assigned final checks.

## Prepared Rosetta delivery mapping — 2026-10-28

Verdict: no actionable defect found in prepared commit `c5a23c13f47e5896485da7f3e09acb855b258d9e`, read in `tmp/constant-array-rosetta`. This is approval of the bounded mapping for the already-planned integration after complete assurance, not a support or whole-assurance verdict. No render, test, proof or publication was performed.

Exact inputs: that commit and parent diff; `docs/planning.md` Rosetta progression requirements; cached Loops/Foreach revision 415246; final constant-array language/catalogue scope already reviewed; current sample/manifest; `rosetta/assess.js`, `coverage.json`, `refresh.py`, assessment review record, generated task/index/progression pages. The Rosetta worktree was clean. The sample bytes agree with current integration.

- Only `constant-integer-array-iteration` is added to `supported`, and only Loops/Foreach's assessment changes. Its surface is now the accurately bounded `fixed-integer-arrays`, `constant-integer-array-iteration` and `integer-image`. Broad `arrays` remains unsupported; no mutable iterable, element write, general iterator or unrelated capability is promoted.
- The cached task expressly requests the language's foreach construct when available. The nine-line sample uses `for Value of Values loop` over the explicitly initialized constant Integer array `(-1,0,1,2,3)`, printing each component in order. The independently read source and manifest agree on `-1\n 0\n 1\n 2\n 3\n`, empty stderr and exit zero. The existing sample validation was covered by the prior regression closure; this mapping inspection supplies no new execution evidence.
- The assessor's construct description and current-language paragraph include captured identity/bounds, actual components, forward/reverse order, immutable nonstatic Full entry bounds, local guard refinement, hiding, mutable widening, outer-fact restoration and nonempty String/input transfer. The exclusions remain explicit and consistent with the authorized fragment. `refresh.py` supplies the matching surface label and admission question.
- Original assessment revision, 2026-10-15 date, `claude-sonnet-5-5` model and medium effort remain unchanged. A separate 2026-10-28 review records selected GPT-6.1 Sol / High and its measurement limits. The generated page distinguishes original assessment from targeted revision and links the record. Its static assessment does not claim native or universal assurance. The dated record accurately describes preparation for later lead integration; no current assessment summary falsely reports a successful checkpoint.
- Foreach moves from Stage 3/position 54 to Stage 1/position 13. Stage 1 has 51 samples and Stage 3 has 13. All 44 stage construct mappings after Stage 1 remain unchanged. All 42 other changed task pages modify only their position/driver-label line (41 position-only changes and the new Segmentation fault protection driver label). Broad arrays #12 therefore remains open at Stage 3; #11 stays Stage 2 and closed #9/#10 stay Stage 1. No new stage or implementation authorization follows from the reordering.

After integration, the three existing `test_rosetta` IDs must be rerun on the final mapping bytes; their prior results in the 540-ID regression closure are then superseded. Deterministic rendering reported by the preparation author was inspected as retained history, not independently replayed. Complete native, source-candidate, byte-certificate and whole-Lean outcomes remain outside this verdict and pending separate evidence review.

Selected independent reviewer: GPT-6 Astra / Extra High. Runtime confirmation and token/cost measurements unavailable. Read-only review 13:34:09–13:35:20 UTC (71 seconds through final static comparison), followed only by this report append. No new finding or requested scope expansion.

## Certificate and source-bridge evidence preparation — 2026-10-28

Bounded result before the owner's requested VM-upgrade pause: both supplied focused runs succeeded with the stated scopes. The proposed transfer has not executed. Whole-project assurance and final transfer applicability remain pending; interruption of the active source-candidate/native runs must not be reported as success.

Reviewed retained original events, focused evidence, logs and `retained.json` for `20261028T103900-407484c4629b` and `20261028T134726-e1a9c7080656`. All compressed and uncompressed file hashes matched their retained records; both terminal events report success and no failure keys. Both used Linux x86_64, Lean 4.34.1 and the same recorded Lean/Lake binary hashes (`e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` / `6f53827dab18010d6c690d14c8401cacabc1db958edb3552a877ed4cf1dd995d`). Neither was a clean build or independent kernel replay.

- Certificate run: actual build of `OutputProfileBodySource` and `OutputBodyCertificate`; build 10,706.620 seconds, fresh audit 24.945 seconds, 28,400 declarations in eight imported/audited modules, one worker/thread and 16,384 MiB process limit.
- Bridge run at core `12ae7f13bd6ffae9a30aa20964a22d4e4ca7e38c`: actual builds of `ReviewedOutputShape`, `OutputSourceBridge`, `NamedSourceBridge`, `ArgumentsSourceBridge` and `LexicalSourceBridge`; build 685.722 seconds, fresh audit 9.638 seconds, 48,060 declarations in 71 modules, one worker/thread and 24,576 MiB process limit. All four source bridges appear in the audited inventory. Both audits report only `[propext, Classical.choice, Quot.sound]`.

Read the unexecuted `/tmp/silver-264-transfer-certificate.py`. It requires both successes, successful completion of the separately active source-candidate run, and idle source/destination workspaces before copying. It derives the transitive source inventory from `LexicalSourceBridge.setup.json` (69 imported project modules plus that root), compares source/Lake/toolchain/generator and Lean/Lake binary bytes across source and destination, compares non-tool inputs with integration, and includes every explicit `include_str` dependency. These comparisons are execution-time prerequisites; this paused review does not claim to have independently completed their entire cross-worktree hash comparison.

The proposed seven-module transfer includes workspace source files and all matching files in both `lib/lean/Silver` and `ir/Silver`. Read-only inventory confirms the source has ordinary, server and private `.olean` files and their hashes, `.ilean`, `.ir`/`.ir.sig`, `.trace`, generated C/hash and `.setup.json` for each module. Thus its glob covers the complete currently present artifact families, rather than copying ordinary objects alone. It records previous/new hashes and verifies copied destination bytes. No blocking omission was found in that bounded script inspection, but the routine was not executed or tested and no transfer record exists yet.

Preservation at pause must include this scratch review and the unexecuted transfer script outside `/tmp`, complete host proof workspaces and their Lake metadata, and the actual tool/cache targets rather than dangling worktree symlinks. The script contains absolute worktree paths and a hardcoded success prerequisite for the interrupted candidate run; recheck those paths and the replacement successful run identity after resumption. This is handoff information, not authorization to weaken its success prerequisite. No new cache framework or proof rerun is requested by this review.

Selected reviewer remains GPT-6 Astra / Extra High; runtime confirmation and token/cost data unavailable. This round began 14:00:33 UTC and was stopped at the current read-only boundary on the lead's transmission of the owner's explicit pause request. No worktree mutation, transfer, build, test, proof or GitHub operation was performed; only this scratch report was appended. Cross-worktree input applicability and whole-assurance closure remain explicit resumption obligations.
