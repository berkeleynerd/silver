# Boolean validation evidence

This packet accompanies [#291](https://github.com/berkeleynerd/silver/issues/291)
and the [capability delivery record](../../boolean-objects.md#delivery-assurance-and-validation).
Status: implemented and validated on Linux, 2026-10-31, on
`8f676fc40975781cdcaa50772d4d95f7e40054a1`.

On 2026-10-31, the owner authorized continued validation and merging PR #289
followed by PR #295 after their required checks pass. [authorization on main](https://github.com/berkeleynerd/silver/blob/d71fff53702b7ed1a66b46c3090a6aaf326621ab/docs/session-memory.md#2026-10-31--named-subtype-and-boolean-validation-and-merge-authorized), recorded through [PR #301](https://github.com/berkeleynerd/silver/pull/301) (documentation commit `9f649adb2022177c097380a4f10c09ca71d10bab`).
Merge execution/results: Pending ordered execution at the validated publication
checkpoint: PR #289 first, then PR #295, under the owner authorization recorded by PR
#301. Neither feature merge is claimed by this checkpoint; the subsequent main-side
handoff records actual merge hashes and closeout.

## Final checkpoint

- Final source/pin/certificate integration: reviewed Body_Tail source plus
  body-call/lint repairs integrated in `91de078e`; the output pin contains 45,259
  tokens; regeneration of all 28 certificates changed only
  `OutputBodyCertificate.lean`, with the other 27 byte-identical; all 143 native
  inputs match the successful capture and archive. Complete final-source kernel/audit
  results remain recorded separately below.
- Matching compiler build: `20261031T022612-eb8a9047980e` passed in 8.566 s on the
  reviewed native source; all 2,561 terminal inputs matched. Compiler SHA-256
  `69006d784a7fa256c3a7bd78db22a9003e9053b199c97b8c6a82e3bbe31cb506` was verified and
  reused for regressions.
- Complete native proof/coverage/provenance audit: `20261031T022711-e4258c225793`
  passed at 2026-10-31 06:20:19 UTC: all 17,234 checks (1,468 flow and 15,766 proof),
  76 units and 1,091 entities, with strict coverage/provenance audits and all 2,561
  terminal inputs matching; 13,985.692 s managed time, using the unchanged populated
  sessions/cache and production limits.
- Complete Lean/source/module/approved-axiom audit: complete cached Linux run
  `20261031T104817-379c11d51394` passed on `8f676fc40975781cdcaa50772d4d95f7e40054a1`:
  572 project modules / 122,964 declarations, only `propext`, `Classical.choice` and
  `Quot.sound`, no missing or unexpected module; build 12.052 s, fresh
  source/module/axiom audit 6.719 s, managed 25.155 s. All 687 source and two tool
  hashes matched, all 28 certificates equal their generated counterparts, and the
  authoritative-source link resolves to actual `src/`. The [final
  packet](final-lean/README.md) preserves exact inputs and reuse.
- Final regression snapshot, run IDs and terminal verification: all 46 tests passed
  with no skips, including the kernel fixture: source 12 in
  `20261031T062630-15922d8efdb5`, platform 16 in `20261031T062757-d817703939c6`,
  output-integrity 17 in `20261031T063136-92db46acc552`, and tool/source-change 1 in
  `20261031T063241-6a51163735a4`. All four 838-input maps and 830 snapshot files
  matched before exact restoration of 864 original nodes; nine dirty-file
  hashes/modes, both binaries and all 80 native report hashes were preserved. The
  [packet](annotation-repair-regressions-91de078e/README.md) identifies every input
  and outcome.
- Final coverage and retained-result applicability: mechanical reconciliation maps all
  568 literal IDs / 559 methods without gaps or overlapping groups: 46 refreshed plus
  522 retained; equivalently 516 original-suite passes plus 52 later passes, including
  six earlier branching/maximum/Rosetta refreshes. Retained applicability uses the
  existing independent repair reviews; terminal independent confirmation remains a
  separate result below. Failed whole runs retain their outcomes.
- Independent final review: the [scoped independent terminal integration/evidence
  review](../../reviews/review-boolean-closing-7560531370.md) passed with no blocker
  on `7560531370904bb677e6a5e7de7aaa441c9faf50`, 2026-10-31 10:48:05–10:52:33 UTC
  (4m28s), selected GPT-6 Astra / Extra High. It checked the actual 572-module /
  122,964-declaration audit, 687 source + two tool hashes/digest, 28 certificates/src
  link, native 143-input/80-artifact/78-binding and build correspondence, all 46
  refreshed IDs without skips, retained 568-ID / 559-method applicability and complete
  #293/#294 consumption. This was read-only terminal confirmation, with no tests,
  proofs or writes; runtime confirmation and token/cost measurements are unavailable.
  It is not a whole external review or external approval.

Evidence is native Linux x86-64: complete strict native proof/coverage/provenance,
complete cached Lean build with fresh actual-source/module/approved-axiom audits,
applicable regressions and scoped internal terminal review. It contains no clean Lean
build, separate `leanchecker --fresh` replay, native macOS validation, hosted CI
result or external approval. The timings describe their named phases and reuse; they
establish no causal model-performance comparison.

## Complete Lean coverage repair and final audit — 2026-10-31

Run `20261031T062232-72f05d92e6aa` on source/regression snapshot
`91de078ed81d102485c7dd286758e127630b01d6` [finished failed](source-integration/missing-audit-module/README.md) at
10:44:59 UTC. Its final-source build passed in 15,723.397 s and its fresh audit
checked 122,961 declarations with only `propext`, `Classical.choice` and
`Quot.sound` in 10.624 s. The strict whole-project coverage comparison then
reported exactly one missing standalone module,
`Silver.ComposeBooleanDeclarationCandidate`, and no unexpected module. Its
managed interval was 15,744.021 s. All 687 source and two tool hashes matched.
The successful phases did not make this a successful complete checkpoint;
the original failed result and completed objects are retained.

The only governed change from that snapshot to final implementation/proof target
`8f676fc40975781cdcaa50772d4d95f7e40054a1` is the explicit import of
`Silver.ComposeBooleanDeclarationCandidate` in `proof/Silver/Audit.lean`.
This includes its separately checked declaration-body rendering theorem while
preserving semantic/source proofs, coverage comparison, warning and axiom
policies. Native inputs, executable behavior, source pins/certificates, scripts,
tests, samples and catalogue are unchanged.

Corrected complete cached run `20261031T104817-379c11d51394`
[passed](final-lean/README.md) on the final target: **572 project modules and 122,964
declarations**, with only `propext`, `Classical.choice` and `Quot.sound`, and no
missing or unexpected module. Its build took 12.052 s, fresh module/axiom audit
6.719 s and managed interval 25.155 s, using one worker/thread and a 24 GiB
per-process threshold. All 687 source and two tool hashes matched; all 28
checked-in certificates equal the generated workspace counterparts, and the
authoritative-source link resolves to the actual repository `src/`. The final
input digest is `a8ddafbfc7071b0b7f0a878e10f9f84def62aaa4303b2eaa3934026f0bd3cdf8`.

The [independent terminal review](../../reviews/review-boolean-closing-7560531370.md) passed with no blocker on
`7560531370904bb677e6a5e7de7aaa441c9faf50`. It confirmed the actual 572-module audit set,
native/source correspondence, all 46 refreshed results and the 568-ID / 559-method
census, and complete consumption of the #293/#294 repairs. The Audit-only import
preserves regression applicability: the kernel fixture uses `AxiomAudit`, and
the platform fixtures use mocked Lean with dynamic module inventory. The exact
native/regression snapshot and retained archive remain `91de078ed8`; these
results required no additional test run for the aggregate import.

## Native-validated integration and regression checkpoint — 2026-10-31

The native/source/regression snapshot at this checkpoint was
`91de078ed81d102485c7dd286758e127630b01d6`. Complete
[native verification](full-native/README.md) passed all 17,234 checks and the
strict coverage/provenance audit on its exact 143 native inputs. The matching
[build](full-native-build-bb3bd71e/README.md) passed. The reviewed Body_Tail
source is integrated with its 45,259-token pin; regeneration of all 28
certificates changed only the output body. The
[source-refresh record](source-integration/body-tail-source-refresh.json) and
[native-input comparison](source-integration/final-native-input-parity.json)
retain exact correspondence checks. Complete Lean run
`20261031T062232-72f05d92e6aa` was launched on these frozen inputs. All 46
[affected regressions](annotation-repair-regressions-91de078e/README.md) passed
with no skips, including the kernel fixture, and the installed workspace was
restored exactly. Complete source/module/axiom assurance and terminal
applicability confirmation remained pending at this checkpoint; final results
are identified above.

## Native reader-repair checkpoint

The native reader-repair implementation/proof target was `87dd912436e35569f12cf95be639e4a534dea978`.
The [native equality repair packet](terminal-native-repair/README.md) now
includes successful complete-reader checks: 56 relation checks and 204 chain
checks, after the retained failed first candidate. Its
[independent source review](../../reviews/review-boolean-equality-transports-88b54a1df3.md)
confirms unchanged contracts and executable behavior. The matching output
pin and regenerated certificate are integrated; 27 other certificates remain
byte-identical. Native build `20261030T214749-120a2c44c6f6` passed.
Complete native `20261030T214853-f14ff090b11a`
[failed](full-native-failed-214853/README.md) with one Body_Tail postcondition
unproved; both repaired condition readers passed. The
[Body_Tail diagnosis/review](../../reviews/review-boolean-body-tail-20261031.md)
and successful 74-check focused repair are recorded in the capability update.
The candidate's complete native run `20261031T022711-e4258c225793` subsequently
passed as recorded above. Complete Lean `20261030T214845-59a80335a9ac`
[finished failed](source-integration/failed-transports/README.md) on four
source-candidate lint errors and missing condition-reader initializer arguments.
Its completed output certificate and source modules remain cached. The
[reviewed proof-only repair](../../reviews/review-boolean-body-condition-wiring-20261031.md)
passed a focused [equations audit](source-integration/body-condition-wiring/README.md);
the repaired source candidate and complete source/module/axiom checkpoint remain
pending final native-validated bytes at that stage. The 46 affected regression
reruns and terminal applicability confirmation were still pending then.
The earlier coverage below applies to its identified inputs, not automatically
to this repaired target.

## Earlier checkpoints

The first complete Lean run [finished failed](source-integration/failed-complete/README.md).
The three source-proof repairs at `b6aeb9f978` passed focused checks and
[independent review](../../reviews/review-boolean-proof-repairs-b6aeb9f978.md).
The host restart at 19:37 UTC interrupted repaired complete Lean run
`20261030T190042-c50bf05fd9bc` and native run
`20261030T185133-160271e45fa1` before their terminal audits. The
[Lean interruption record](source-integration/interrupted-complete/README.md)
retains the logs and verifies all 687 source and two tool hashes. Replacement
Lean run `20261030T194116-3d6d1353e52b` reused the existing Lake workspace with
one worker, one thread and the same 24 GiB threshold. Replacement native run
`20261030T194142-1f663fdf10c2` retains four workers and the same strict options,
cache and 2,561 preflight input hashes. Native run
`20261030T142912-eb0b24fc2191` was also interrupted earlier, without a terminal
audit. All interrupted records retain that outcome; neither complete checkpoint
had passed at that stage.

Native run `20261030T194142-1f663fdf10c2` subsequently
[finished failed](full-native-failed-194142/README.md) on two ghost equality
checks. Focused annotation repair followed. The lead
[stopped Lean run `194116`](source-integration/native-repair-stop/README.md)
at 19:57:36 UTC because the selected Ada annotation changes invalidated its
captured source. Completed objects were retained for stable repaired inputs.
The regression review below applies to `cff54ae34d`; final repair applicability
and actual reruns are identified in the final checkpoint above.
The first annotation candidate's
[focused relation check](terminal-native-repair/README.md) also failed, on all
four added equality assertions. It remains a retained experiment, not the
integration source or a validation success. Generated-obligation diagnosis
preceded the successful focused checks recorded above.

- [Producer review](producer-review.md): observed Boolean obligation routes and
  the explicit restriction on nested xor operands.
- [Native validation](native-validation.md) and [repairs](native-repair.md):
  builds, focused regressions, stack observations and native proof experiments,
  with failed attempts retained as failed.
- [Final focused tests](final-focused/README.md) and
  [final loop-stack observations](loop-stack/README.md): matched final native
  build, catalogue parity, corrected hiding fixture and both retained deepest
  loop programs under an actual 8 MiB process stack.
- [Complete regression coverage](full-suite/README.md) and
  [terminal reruns](terminal-reruns/README.md): 565 independently reviewed retained
  passes plus three fresh passes cover all 568 unittest identities (559 distinct
  methods). The manifest test passed all 55 sources and 111 executions. Both
  failed runs remain failed; the maximum-expression test passed with eight CPUs
  and unchanged source, deadline and production proof options. The
  [applicability review](../../reviews/review-boolean-regression-37c0babc64.md)
  covers target `37c0babc64`; the later source/platform/Rosetta refreshes below
  established applicability to `cff54ae34d`.
- [Certificate repair tests](source-integration/certificate-repair-tests/README.md)
  and [platform refresh](source-integration/platform-refresh/README.md): 12 and
  16 fresh passes after the proof-only repairs.
- [Rosetta metadata refresh](rosetta-refresh/README.md): all three tests passed
  on the integrated metadata. The
  [final applicability review](../../reviews/review-boolean-final-regression-cff54ae34d.md)
  confirmed 534 retained plus 34 refreshed results covered all 568 identities
  at that input, before the later native annotation repairs.
- [Declaration interpretation](declaration-body/README.md) and
  [header integration](header-program/README.md): typed declaration meaning,
  actual native domains and ordered declaration composition.
- `helper-libraries/`: run `20261030T125139-6833062de0b7`, six focused native/helper
  targets, fresh audit of 37,361 declarations. Build 14.195 s, audit 6.992 s.
- `model-integration/`: run `20261030T131059-c3d92e95ade0`, Compose model equations,
  legality and the retained Sequence model, fresh audit of 22,718 declarations.
  Final incremental build 27.025 s, audit 6.231 s. Successful Compose modules
  from the preceding failed integration runs were reused; those whole runs
  remain failures.
- `source-integration/array-wrapper/`: run `20261030T132019-92cbf1c7896b`, the
  typed constant/return wrapper for `Array_Declaration_At`, fresh audit of
  11,182 declarations. Build 75.964 s, audit 5.198 s. Its evaluation preserves
  the original expression value for arbitrary callees and local environments.
- `source-integration/reviewed-pin-refresh.json` and
  `certificate-regeneration.json`: source identities, semantic review basis
  and regeneration of all 28 certificates. Only the output specification/body
  certificates changed. Regeneration and token equality are preflight checks;
  their proofs still required a complete Lean checkpoint at that stage.

## Incremental cache reuse

The integration worktree retained the previously validated subtype workspace
on parent `fa6b5e982c`. During Boolean integration, matching complete object
families were copied from the source and declaration worktrees. The compressed
inventories in `cache-transfers/` record source hashes, donor runs, excluded
source mismatches and the copied or retained files. The three main transfers
were:

| Donor checkpoint | Transfer run | Matching module sources | Copied files |
| --- | --- | --- | --- |
| `20261030T124434-509822bae49c` | `20261030T124616-799919fd04df` | 528 | 630 |
| `20261030T125139-6833062de0b7` | `20261030T125504-25b6947cc0f6` | 535 | 125 |
| `20261030T125012-f7b21b9c556b` | `20261030T125550-5992851fb157` | 541 | 437 |

These counts overlap; they are not additional validated modules. Donor caches
include modules that finished successfully inside earlier failed focused runs.
Complete `.olean`, `.olean.server`, `.olean.private` and Lake metadata families
were preserved. Transfers are cache reuse, not separate audits. Managed checks
rehash their inputs and freshly audit imported declarations. No clean rebuild
or independent kernel replay is claimed.

The first complete checkpoint started on implementation/proof snapshot `5198f2b7b5`
with one Lake worker, one thread and a 24 GiB per-process Lean threshold. The
host has 31 GiB RAM and no swap; expensive source candidates are serialized.
Subsequent Rosetta/sample metadata at `927cc5e178` prepares the final regression
inputs without changing that source/proof snapshot. That run failed as retained
above; independently completed objects remain available to the repaired
checkpoint. Terminal successful evidence was still required at that stage.
