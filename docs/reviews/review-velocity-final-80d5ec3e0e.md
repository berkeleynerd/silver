# #246 final evidence review

**Current verdict — READY for delivery, 2026-10-27.** The complete C1 source/axiom checkpoint, matched comparison, applicable native/regression evidence, invalidation controls, bounded profiling and final documentation/packet integration are complete. No blocking or actionable finding remains in this review. The selected #246 package is ready for the authorized commit/PR closeout; no further proof, test, profile or broad review is required for unchanged inputs.

The conditional checkpoint and its completion addenda below are retained as history. The final integration addendum at the end supersedes their pending-item wording.

## Historical conditional checkpoint — 02:57–03:01 UTC

**Verdict:** no blocking finding in the completed matched comparison or complete C1 Lean/source checkpoint. The observed build-wall reduction is **2,676.218 seconds (27.9718%)** for the specified workload. Complete authoritative-source/module/private-axiom validation succeeded on the unchanged reviewed implementation. Final delivery still awaits the planned invalidation controls, the separately running serialized-predicate diagnostic, and a narrow check of their integration and final documentation. This report does not mark those outstanding items complete.

## Review identity and exact inputs

Selected reviewer: GPT-6 Astra, Extra High. Runtime setting confirmation and token/cost measurements are unavailable. Read-only inspection began 2026-10-27 02:57:08 UTC; substantive checks finished 03:00:51 UTC (223 seconds). No tests, builds, native proof, Lean process, or measurement were launched by this review; only sources and retained records were read/hashed. The serialized diagnostic was independently active.

- Implementation: `80d5ec3e0e5224fe36c705f6be15e429b7fa7468`; baseline: `e94c8b4343f429c434900cc2a23e29e870f577bf`.
- Exact isolated worktrees: `tmp/velocity-246-measure/after-24g-worktree` and `before-24g-worktree`, both at their recorded commits with no tracked diff. Current implementation proof/tool inputs in `tmp/velocity-246` match AFTER; ongoing documentation edits do not alter them.
- Measurement inputs: `pair-24g-plan.json`, `resume_pair_24g.py`, `measure_pair_24g.py`, `pair-24g.jsonl`, `original-cache-before.json`, both `*-24g-invalidation.json` records, and each case's command, result, summary, artifact inventories, RSS/process samples, Lean evidence and complete log. The three script hashes retained in the plan match their present files. The plan's “PREPARED ONLY” status is historical; the sequence and managed results establish actual completion.
- Assurance inputs: the two run-specific managed `events.jsonl` records, unchanged `scripts/check_lean.py` and full audit/source bridge chain, retained `correctness/` failure, and `resource-probe-run/` evidence plus its exact two-fact source.
- Earlier independent C1/static-source, attribution and native/regression-reuse reviews remain applicable. The 92 affected tests and retained native evidence were not rerun for this checkpoint.

## Controlled workload and exact correspondence

The pair ran **AFTER then BEFORE**, once, on Linux x86_64 with pinned Lean 4.34.1, two Lake workers, two Lean threads per process and a **24,576 MiB per-process threshold**. Each case independently copied the original warm seed associated with retained complete run `20261026T131016-6b27137135dc`; neither used profiled, failed or correctness-run objects as its starting seed.

Independent record comparison establishes:

- Starting artifact inventories are exactly identical, including hashes, sizes and modification times: **7,672 survivors** in each case.
- Each survivor inventory equals the original cache inventory minus the **296 recorded artifact removals**. Every removed object's recorded identity also matches that original inventory. The new AFTER candidate had no seed artifact to remove.
- Recomputed actual Lake-built sets and changed/created `.olean` inventory sets equal the planned closures: **20 AFTER**, **19 BEFORE**. The only additional AFTER module is `Silver.ComposeSourceCandidate`.
- All **613 AFTER** and **612 BEFORE** captured shared source inputs match their respective isolated snapshots. All 613 AFTER inputs also match the current implementation checkout. Their independent digest recomputation equals the evidence digest.
- Both recorded Lean/Lake tool hashes match their current isolated executables and each other. Captured configuration is identical: no clean mode, no replay, two workers, two threads, 24,576 MiB.
- Process samples captured all 20/19 rebuilt module commands and the fresh audit commands. Every compilation/audit invocation has `-j2 -M24576`; none has profiling flags or `Elab.async=false`. BEFORE additionally sampled the ordinary `lean --short-version` query, which appropriately has no build resource options.

These are controlled **incremental reconstruction** workloads over a common warm cache, not clean builds or independent kernel replays.

## Results and complete assurance

| Observation | BEFORE | AFTER |
| --- | ---: | ---: |
| Managed run | `20261027T001557-ba6697079c60` | `20261026T221956-84d1b4b6e429` |
| Build phase | 9,567.554 s | 6,891.336 s |
| Fresh audit phase | 9.163 s | 10.304 s |
| Managed elapsed | 9,591.191 s | 6,914.489 s |
| Complete audited modules | 497 | 498 |
| Audited declarations | 104,238 | 104,251 |
| Launcher child user + system CPU | 13,218.534 s | 13,604.191 s |
| Sampled process-tree RSS peak | 17.806 GiB | 18.654 GiB |
| Minimum sampled host available memory | 13.129 GiB | 12.550 GiB |

Both build and audit phases exited successfully. Fresh actual audit output names exactly every project module, including the new candidate, and reports only `propext`, `Classical.choice` and `Quot.sound`. The unchanged full audit root retains private/generated declarations and transitive assumption inspection. The runner verifies shared/source/workspace/tool identities through the phases; the selected input hashes remain current. Together with the earlier unchanged-statement/source-chain review, AFTER closes the prior “ready for Lean validation” limitation: the candidate decisions, actual-source adapter and final authoritative composition bridge now compile and pass the complete audit.

`kernel_recheck` is null in both records. This is successful complete project checking with a fresh full private/module/axiom audit, reusing unaffected objects; it is not `leanchecker --fresh` evidence. No native or regression assurance exemption is inferred from it.

The build saving is **2,676.218 s / 9,567.554 s = 27.9718097%**. The separate managed-elapsed saving is **2,676.702 s (27.9079209%)**. Child CPU increased **2.9175%**; the result must be described as reduced elapsed time associated with the changed dependency schedule, not reduced aggregate CPU work. The logs show the expensive candidate completing before the output certificate and the final AFTER adapter taking approximately 2.2 seconds; baseline's combined composition check took approximately 3,261 seconds. Those rounded module timings explain the observed schedule, not a general scaling model.

## Retained resource failure and limitations

The 16 GiB warm correctness attempt remains failed: `ComposeSourceCandidate` reported excessive kernel memory at the two retained `refinement_fact_09` and `refinement_fact_11` decisions. No code changed in response. The resource diagnostic reproduced those exact theorem statements and proof bodies, passed at 24 GiB with a fresh focused audit, and observed a largest-child RSS of about **16.60 GiB**. That reduced-context diagnostic alone did not establish full-candidate memory behavior; the successful complete AFTER run now supplies that additional evidence.

The comparison is a single fixed-order AFTER→BEFORE pair on one host. It does not estimate variability, remove order/cache/host drift, establish an optimum worker count, or support historical contention attribution. Recorded sequencing keeps the cases separate from the earlier profiles/resource diagnostic and subsequent serialized diagnostic. The process monitor samples the experiment group, not every external host process. RSS sums may count shared pages more than once; peaks and host headroom are sampled. The 24 GiB setting is per process, not an aggregate enforced cap. Neither case hit the 3 GiB sampled-headroom cutoff.

## Pending narrow completion check

The prepared invalidation controls have not run, and the serialized-predicate attribution diagnostic is still active. Neither is needed to reinterpret the already successful complete audit or alter the matched timings, but both remain selected delivery work. Review their results and the final documentation in an addendum; do not repeat this successful pair merely to obtain those remaining observations. Preserve the original failed 16 GiB record, normal-async predicate timing/memory, and invalid predicate service-attribution archive.

## Retained principal artifact hashes

Paths below are relative to `tmp/velocity-246-measure/`.

| Input | SHA-256 |
| --- | --- |
| `after-24g/lean-evidence.json` | `53ff26dba6a0947f7c195b80a3cd0f9e40a0504b6542a4cc718015f1f3e262d6` |
| `after-24g/lean-proof.log` | `69d0ddd6eab38f3a772464f07d3de002ac256ae31173d51d05310451083a49f9` |
| `after-24g/summary.json` | `01c89840c1a91abaa341194313f6433879d0075a73a4f9e905343a11373dbb27` |
| `before-24g/lean-evidence.json` | `3501f4eef204663f82ff79605e975924981f06695f40144adce8dd236cfe6cc5` |
| `before-24g/lean-proof.log` | `e87b34ba0cece014fae0f3cef5e78c9fb7b2c4745c9f70ce3ac01bd72f0fb10a` |
| `before-24g/summary.json` | `7976b312db733ec6a71f9ca37a08a0d2c49bf435aa7c220a3a3be150df8d1e98` |
| Both `artifacts-before.json` files | `2223d17d57eabd449cd4609894ce623d6e1335c9c590533d879a75ce7fda5f1e` |

## Completion evidence addendum — October 27, approximately 03:54 UTC

The two pending runtime/evidence items above are now complete. Final documentation integration still awaits the lead's final draft and a narrow claim check. Selected reviewer/settings and measurement limits remain unchanged; this addendum used only offline reads and retained-profile analysis, with no further proof/profile/test execution.

**Serialized predicate diagnostic:** run `20261027T025633-70e1215e4e28` passed its build and fresh focused audit. Its queue stopped at a postprocessing assertion requiring exactly one trace stream. Independent diagnosis identified one declaration/checking stream plus two unnamed `Lean.Meta.realizeConst` exception-reporting streams, containing only 0.028499 ms combined positive trace weight and no Kernel/declaration frames. Actual sampled module commands contain `-DElab.async=false`, `-j2`, `-M16384`. Pinned `Lean/Meta/Basic.lean:2745–2752` explains those reporting callbacks independently of the theorem-elaboration option.

Preserved the original raw trace, ranking and verifier. The original verifier passes unchanged on a retained projection selecting only the original main thread. Its positive slices cover the 3,081.945176682-second frontend span exactly, all 356 Kernel scopes have maximum overlap one, and named 3,079.540727514 seconds plus unassigned 2.404449168 seconds conserves the span within 0.001 ms. Original named declaration entries are unchanged by this projection. A corrected ranking, explicit exclusion record, validated summary and deterministic raw archive are retained; see `profile-predicate-serialized/attribution-diagnosis.md` for exact inputs, source explanation, ranking and limits. This yields useful **serialized diagnostic traced-elapsed** attribution, not recovered normal-async CPU costs. The normal-async inconclusive-attribution finding remains preserved.

Correct time labels are 3,093.775 seconds build, 8.183 seconds fresh focused audit and 3,116.599 seconds launcher wall. The first four named checks consume 32.74% of named traced elapsed time. No production async setting or predicate optimization is adopted. Summary SHA-256: `85e7a68ded0c1308c5f1ec4cec8eb08e87fe4fab766302f8e305ade4aac0034c`.

**Invalidation controls:** reviewed `tmp/velocity-246-plan/invalidation-control.py`, all eight retained probe results/logs, and before/after object inventories in `invalidation-20261026/`. They use `Lake --no-build --rehash --reconfigure` on a separate copy of the successful AFTER snapshot. Normal candidate/authoritative freshness succeeds. A comment-only authoritative Ada byte edit, with its timestamp preserved, leaves the candidate current and returns exit 3 at `Silver.OutputProfileBodySource` for the authoritative adapter. An actual reviewed-token pin edit returns exit 3 at `Silver.ReviewedOutputShape` for the candidate. Restoring bytes returns each target to exit 0. These are stale-frontier observations, not an enumeration of every stale module, a proof build or an audit.

Independently confirmed that all 15 selected `.olean`, `.olean.server` and `.olean.private` sidecars have identical hashes **and** modification times before/after; Ada and shared/workspace pin bytes are restored to the successful snapshot. Result SHA-256: `609e039e1e4abb1340860267f15e88d7df50f8c55e475947d4894ea2730e3aee`; both object inventories: `2b0e051fb4a1ba0a654f7c04fb607c8541d50b930e0ebf5c046dff852226e3d1`. The controls substantiate the intended cache dependency boundary without changing the completed source/axiom result or matched measurements.

## Final documentation and evidence integration — October 27, approximately 03:59 UTC

**READY.** This narrow final check closes the conditional review. Selected reviewer: GPT-6 Astra, Extra High; runtime confirmation and token/cost measurements unavailable. Inspection began 03:56:31 UTC and finished in approximately three minutes. No runtime tests, proof builds or new profiles were performed. The exact implementation remains `80d5ec3e0e5224fe36c705f6be15e429b7fa7468` against baseline `e94c8b4343f429c434900cc2a23e29e870f577bf`; there is no diff from that implementation in `proof`, `scripts`, `src`, `tests`, `samples` or `catalogue`.

Reviewed the five final documentation drafts listed below, the retained review references, and `docs/evidence/development-velocity-20261026/implementation/`. All **123** indexed evidence files match `files.json` sizes and SHA-256 values, totaling **11,503,928 bytes**; only the intended `README.md` and `files.json` are outside that index. Compared **67** principal exported case records/archives directly with the reviewed scratch originals, decompressing where appropriate; every comparison matched. This includes the corrected serialized primary ranking/projection/conservation evidence and preserves its original raw/ranked inputs, as well as the original normal-async invalid attribution. All **385** local file links found in the five documents resolve. Diff whitespace checking passed.

The claims correctly distinguish the **27.97% build-wall** saving from complete managed timings (which imply **27.91%**), disclose increased child CPU, and retain the single fixed AFTER→BEFORE comparison limits. Memory figures distinguish largest-child observations, sampled host headroom and the per-process threshold; no aggregate cap or new universal default is claimed. The failed 16 GiB result remains failed, and the reduced-context resource diagnostic is separate from the later complete C1 success.

The packet and prose distinguish invalid normal-async per-declaration cost attribution from validated primary-stream serialized traced-elapsed attribution, including the excluded 0.028499 ms reporting callbacks and unchanged production settings. Authoritative statements, source reconstruction and complete native/Lean requirements remain intact. Regression wording identifies 92 current focused passes plus independently reviewed retained applicability, with no fresh full-suite or GNATprove claim. Certificate chunking, predicate optimization, persistent D/I9 metrics and new language work remain deferred/unselected. The earlier independent reuse and critical source reviews remain applicable.

No routine correction or unresolved issue was found in this final integration check. The previous pending controls, serialized diagnosis and documentation obligations are all discharged; preserve the historical records without rerunning successful work for bookkeeping.

Exact final documentation inputs (SHA-256):

| File | SHA-256 |
| --- | --- |
| `docs/development-velocity.md` | `e1d01baf3320c49f0bb62b5fd365173f14213cbff02d43f29960ebce96585359` |
| `docs/focused-source-checks.md` | `ec16771854fc0b9241a847e5e0907dc0852dc3931d2852b36c2542c79734ba82` |
| `docs/evidence/development-velocity-20261026/implementation/README.md` | `ed83e05ecaac5b02ab1d3a3c5720ae3dbb961f941058e75f273ff547a0b30477` |
| `roadmap.md` | `6bc14fb05f58f937a6e680f058b19d2c84c2a19537d6963bc73357706fb5a947` |
| `docs/session-memory.md` | `9c7691d5d9d0e93d128773b643a8ae5329e1e4e3cc56a1a30ec503aa947850f7` |

## Lead packaging note — 2026-10-27

After the final review, the two exact raw theorem extracts in `resource-probe-run/` were gzip-compressed to preserve their deliberate trailing blank lines without whitespace-check diagnostics. Their decompressed bytes match the reviewed originals exactly; `files.json` records the archive identities. The packet still has 123 indexed files. No proof, source, result, measured input or claim changed. This packaging check was performed by the lead, not a new independent runtime review.
