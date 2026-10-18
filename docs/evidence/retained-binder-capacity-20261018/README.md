# Retained null binder evidence

Supports [the binder component](../../research/retained-binder-capacity.md) for
#119. Collected on Linux x86_64, 2026-10-18. The extension includes one
controlled binder-only run; retained installation inputs were read-only.
No compiler build, assembler/linker run, complete audit, Lean check, test suite,
macOS validation or hosted CI is claimed.

`artifacts.tar.gz` preserves three existing indexed null regression sources,
projects, Main/binder ALIs, generated binder sources and binder objects from
the [#123 validation](../../indexed-main-discovery.md). It also retains the
separate historical unindexed proposed-option witness and the complete
61-file null binder ALI closure and four installed binder-compiler dependency
specifications. Original paths are in `manifest.json`.
The installed files were read; those workspaces and artifacts were unchanged.
The controlled capture writes only its fresh scratch directory and records its
complete child environment, exact arguments, temporary inputs, input identities,
generated sources, empty stdout/stderr and managed-run log/events. Its input
manifest is preserved separately from the extended packet's later manifest.

`sources.tar.gz` contains one hundred and seven complete inspected source files:
sixty-eight GCC Ada files, twenty-nine GCC backend files, one libcpp file, seven
GPR files and two Silver workspace-construction files. The GCC/libcpp files were reconciled against
the earlier complete-source manifests for
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; GPR retains its previously used
source identity, and all inputs have exact hashes and original paths.
These records identify source text, not historical binary build inputs.

`result.json` records source sizes, explicit/default external names, unit and
dependency inventories, export-version value reconciliation, ALI record/table,
signature-map and composed binder name-table bounds, and each
ELF section/symbol and relocation counts. All
three indexed objects hash-equal. Only workspace-path comments differ in their
generated bodies, and their exact noncomment byte projection and code-token
line/column maps match. The per-installation path lengths and mapping/template
contributions are also recorded. The checker
additionally checks builtin/optab naming alphabets and reconciles the observed
extra object names with generated elaboration/init names. It also checks the
no-IFUNC source premises and the observed absence of `STT_GNU_IFUNC`. It does not infer
a universal object bound from those comparisons; the source
argument and its remaining joins are stated in the component.

Generation-buffer results combine that source projection with the append/reset
invariant: 139 characters suffice for `Statement_Buffer`'s intermediate
occupancy; direct path comments and the separate object-list buffer are charged
independently. The six-argument indexed invocation template has at most 233
bytes at the retained installation with `/tmp`, below the Linux driver's
8,192-byte response threshold. The retained unindexed `build.stdout` confirms
the historical command's shape without becoming an indexed command capture.
The 1,000-character Gprbind exchange-row interface and its still-open fixed
configuration/producer join are stated explicitly; final `.bexch` output is
not represented as an original input capture.

The selected search-directory extension retains the installed `gnat.xml` and
records the absence of the two optional default-search files at collection.
It derives the one-row project object-path file and the two/three-slot search
table demands from the stated environment/configuration descriptor. It does
not claim to have captured the historical GPR child environment. The fixed
default-relocation source projection keeps its allocations separate from the
variable directory-copy subtotals.

Managed run `20261018T104855-09a597637815` invoked the indexed binder once with
the controlled descriptor. It exited zero in 0.0122 seconds (2.0036 seconds for
the managed run), with empty stdout/stderr. Both generated sources hash-equal
the retained indexed source, and all 68 retained inputs stayed hash-equal.
Its temporary-root length is 43 bytes: the six argument strings occupy
303 bytes including terminators, within the source-derived 311-byte bound for
that root. The 233-byte value above is the separate `/tmp` bound.
This establishes the selected environment/path descriptor, without recovering
the historical GPR child environment or original exchange input. Offline replay
reconciles the capture against the preserved input manifest and managed pins;
it does not rerun the binder. The archived `run.py` is the historical capture
script, with its original paths, rather than a portable replay entry point.

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
  --binder-capture /tmp/silver-binder-fixed-20261018 \
  --binder-managed-run /home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261018T104855-09a597637815 \
  --gcc-ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gcc-backend /tmp/silver-backend-compose-20261018/full-source/gcc \
  --gpr-source /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  --output /tmp/retained-binder-recollection
```

Neither collection nor replay invokes a subprocess or performs a native build.
