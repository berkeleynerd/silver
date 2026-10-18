# Retained null binder evidence

Supports [the binder component](../../research/retained-binder-capacity.md) for
#119. Collected read-only on Linux x86_64, 2026-10-18. No new native tool run,
complete audit, Lean check, test suite, macOS validation or hosted CI is claimed.

`artifacts.tar.gz` preserves three existing indexed null regression sources,
projects, Main/binder ALIs, generated binder sources and binder objects from
the [#123 validation](../../indexed-main-discovery.md). It also retains the
separate historical unindexed proposed-option witness and the complete
61-file null binder ALI closure. Original paths are in `manifest.json`.
The installed files were read; no workspace or artifact was modified.

`sources.tar.gz` contains eighteen complete inspected GCC/GPR source files.
The sixteen GCC Ada files were reconciled against the earlier complete-source
manifest for GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the backend and
GPR inputs retain their previously used source identities and exact hashes.
These records identify source text, not historical binary build inputs.

`result.json` records source sizes, explicit/default external names, unit and
dependency inventories, each ELF section/symbol and relocation counts. All
three indexed objects hash-equal. Only workspace-path comments differ in their
generated bodies, and their code-token line/column maps match. The checker
does not infer a universal object bound from those comparisons; the source
argument and its remaining joins are stated in the component.

Replay without access to the original installations:

```sh
python3 docs/evidence/retained-binder-capacity-20261018/check.py
```

`collect.py` is the executed read-only collector. Recollection is unnecessary
for replay; if needed, use a fresh output directory:

```sh
python3 docs/evidence/retained-binder-capacity-20261018/collect.py \
  --repair-installation /home/canto/src/github.com/berkeleynerd/silver/tmp/indexed-main-discovery \
  --native-option-probe /tmp/silver-native-option-probe-20261018 \
  --gcc-ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gcc-backend /tmp/silver-backend-compose-20261018/full-source/gcc \
  --gpr-source /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  --output /tmp/retained-binder-recollection
```

Neither collection nor replay invokes a subprocess or performs a native build.
