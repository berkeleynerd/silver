# Boolean validation evidence

This packet accompanies [#291](https://github.com/berkeleynerd/silver/issues/291)
and the [capability record](../../boolean-objects.md). Complete assurance and
delivery remain pending. Focused successes below do not establish complete
source correspondence or feature support.

- [Producer review](producer-review.md): observed Boolean obligation routes and
  the explicit restriction on nested xor operands.
- [Native validation](native-validation.md) and [repairs](native-repair.md):
  builds, focused regressions, stack observations and native proof experiments,
  with failed attempts retained as failed.
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

The complete checkpoint started on implementation/proof snapshot `5198f2b7b5`
with one Lake worker, one thread and a 24 GiB per-process Lean threshold. The
host has 31 GiB RAM and no swap; expensive source candidates are serialized.
Subsequent Rosetta/sample metadata at `927cc5e178` prepares the final regression
inputs without changing that source/proof snapshot. Terminal evidence will
replace this pending checkpoint description before delivery.
