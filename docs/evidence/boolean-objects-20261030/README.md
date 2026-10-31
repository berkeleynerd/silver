# Boolean validation evidence

This packet accompanies [#291](https://github.com/berkeleynerd/silver/issues/291)
and the [capability record](../../boolean-objects.md). Complete assurance and
delivery remain pending. Focused successes below do not establish complete
source correspondence or feature support.

The native reader-repair implementation/proof target was
`87dd912436e35569f12cf95be639e4a534dea978`; the proof-only repair below follows it.
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
The candidate's complete native run `20261031T022711-e4258c225793` is active
in the isolated native workspace. Complete Lean `20261030T214845-59a80335a9ac`
[finished failed](source-integration/failed-transports/README.md) on four
source-candidate lint errors and missing condition-reader initializer arguments.
Its completed output certificate and source modules remain cached. The
[reviewed proof-only repair](../../reviews/review-boolean-body-condition-wiring-20261031.md)
passed a focused [equations audit](source-integration/body-condition-wiring/README.md);
the repaired source candidate and complete source/module/axiom checkpoint remain
pending final native-validated bytes. The 46 affected regression reruns and
terminal applicability confirmation are still pending.
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
Lean run `20261030T194116-3d6d1353e52b` reuses the existing Lake workspace with
one worker, one thread and the same 24 GiB threshold. Replacement native run
`20261030T194142-1f663fdf10c2` retains four workers and the same strict options,
cache and 2,561 preflight input hashes. Native run
`20261030T142912-eb0b24fc2191` was also interrupted earlier, without a terminal
audit. All interrupted records retain that outcome; neither complete checkpoint
has passed yet.

Native run `20261030T194142-1f663fdf10c2` subsequently
[finished failed](full-native-failed-194142/README.md) on two ghost equality
checks. Focused annotation repair followed. The lead
[stopped Lean run `194116`](source-integration/native-repair-stop/README.md)
at 19:57:36 UTC because the selected Ada annotation changes will invalidate its
captured source. Completed objects remain retained; complete validation will
resume on reviewed, stable repaired inputs as recorded above. The regression review below applies
to `cff54ae34d`; any integrated repair needs an input-applicability check.
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
  establish applicability to the current inputs.
- [Certificate repair tests](source-integration/certificate-repair-tests/README.md)
  and [platform refresh](source-integration/platform-refresh/README.md): 12 and
  16 fresh passes after the proof-only repairs.
- [Rosetta metadata refresh](rosetta-refresh/README.md): all three tests passed
  on the integrated metadata. The
  [final applicability review](../../reviews/review-boolean-final-regression-cff54ae34d.md)
  confirms 534 retained plus 34 refreshed results cover all 568 identities.
  Complete native and Lean/source assurance remain pending.
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
  the complete Lean checkpoint still has to check their proofs.

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
checkpoint. Terminal successful evidence is still required before delivery.
