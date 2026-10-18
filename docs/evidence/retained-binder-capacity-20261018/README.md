# Retained null binder evidence

Supports [the binder component](../../research/retained-binder-capacity.md) for
#119. Collected on Linux x86_64, 2026-10-18. The extension includes one
controlled binder-only run, one Gprconfig selection with metadata queries and
one proposed-options indexed binder compiler/assembler execution; retained
installation inputs were read-only.
No link, complete audit, Lean check, test suite,
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

`sources.tar.gz` contains one hundred and twenty-four complete inspected source files:
seventy-four GCC Ada files, thirty-five GCC backend files, two libcpp files, eleven
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
a universal object bound from those comparisons; the component supplies the
separate semantic request/object-shape transfer and identifies remaining
whole-process transient-capacity joins.

Generation-buffer results combine that source projection with the append/reset
invariant: 139 characters suffice for `Statement_Buffer`'s intermediate
occupancy; direct path comments and the separate object-list buffer are charged
independently. The six-argument indexed invocation template has at most 233
bytes at the retained installation with `/tmp`, below the Linux driver's
8,192-byte response threshold. The retained unindexed `build.stdout` confirms
the historical command's shape without becoming an indexed command capture.
The 1,000-character Gprbind exchange-row interface is joined to the selected
configuration and complete producer inventory: at most 26 rows, each bounded
by `max(146,T_root+36)`. Final `.bexch` output is not represented as an
original input capture.

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

Managed run `20261018T110052-6e9404864987` separately captures the selected
native/default GPR configuration. Gprconfig exited zero in 0.123 seconds,
producing 7,011 bytes; its 71 knowledge-base files and three selected binaries
stayed hash-equal. The packet retains those 71 files, configuration, command,
environment, metadata-query log and managed records. The 407-byte stderr
contains five missing VxWorks/PikeOS environment warnings from unrelated
compiler descriptions. No project was compiled. This is a new selected
configuration, not recovered historical configuration. The source join bounds
the binder/compiler/project vector backing at 8/16/1 slots, and records
14 baseline or 15 proposed compiler arguments separately. Whole GPR process
allocation remains open. The selected O0/no-override source routes separately
exclude COMMON variables and allocated merge sections; the object retains its
nonallocated mergeable `.comment` section.

Managed run `20261018T111407-352fea7c3696` captures the exact proposed indexed
binder compiler command, including `-Wno-free-nonheap-object`. It first queries
driver selection with `-###`, then compiles and assembles the copied fixed
source once. The same-length scratch paths preserve both full source-name
lengths at 127 bytes. Compiler/assembler duration was 0.0415 seconds (managed
run 2.3122 seconds), exit zero, empty stdout/stderr, with all 11 retained inputs
unchanged. The 13,432-byte object hash-equals the indexed baseline. Its source
projection preserves semantic requests, locations, filename equality and
emission inputs, transferring object shape to the selected null binder family.
The packet retains the exact environment, command, script, query, outputs and
managed records. GC traversal scratch and other whole compiler intermediates
remain separate capacity obligations; object size is not their bound.

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
  --gprconfig-capture /tmp/silver-gprconfig-fixed-20261018 \
  --gprconfig-managed-run /home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261018T110052-6e9404864987 \
  --compiler-capture /tmp/silver-binder-compiler-fixed-20261018 \
  --compiler-managed-run /home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261018T111407-352fea7c3696 \
  --gcc-ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gcc-backend /tmp/silver-backend-compose-20261018/full-source/gcc \
  --gpr-source /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  --output /tmp/retained-binder-recollection
```

Neither collection nor replay invokes a subprocess or performs a native build.
