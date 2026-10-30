# Boolean validation evidence

This packet accompanies [#291](https://github.com/berkeleynerd/silver/issues/291)
and the [capability record](../../boolean-objects.md). Complete assurance and
delivery remain pending. Focused successes below do not establish complete
source correspondence or feature support.

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
  covers target `37c0babc64`. Final Rosetta metadata will receive its three
  affected test reruns before delivery.
- [Certificate repair tests](source-integration/certificate-repair-tests/README.md)
  and [platform refresh](source-integration/platform-refresh/README.md): 12 and
  16 fresh passes after the proof-only repairs. Current coverage is 537 retained
  plus 31 refreshed results; final Rosetta metadata still needs its three tests.
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
