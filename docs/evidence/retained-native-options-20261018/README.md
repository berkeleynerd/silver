# Combined native-option experiment

Native Linux x86_64 managed run `20261018T061951-20d08eb6ee31`, 2026-10-18,
**5.800 seconds**. All six isolated GPRbuild build/bind/link operations and
all six resulting executions passed. No GNATprove, solver, Lean, complete
native audit or full test suite ran.

Each source was built once with the existing compiler switches
`-gnat2022 -gnata -gnato` and once with Main-only additions
`-gnatx -Wno-free-nonheap-object`. The six selected library source files were
copied unchanged for the two output-capable forms; their native compiler
switches stayed at baseline. Each build used separate source/object/bin
directories and one worker, without borrowing a prior build cache.

| Source | Source bytes | Baseline / proposed X headers | Baseline / proposed longest ALI record, including LF | Observed program output |
| --- | ---: | ---: | ---: | --- |
| Null | 70 | 1 / 0 | 47 / 47 | empty |
| Literal `Silver_IO.Put ("a")` | 101 | 2 / 0 | 68 / 68 | `a` |
| Static shell, unused 2,500-character local identifier | 2,607 | 2 / 0 | 2,513 / 68 | empty |

Every program exited zero with empty stderr. Proposed Main ALIs contain both
additional A switch records and no X section. Verbose logs show that gprbind
replays `-Wno-free-nonheap-object` when compiling its generated binder source,
and omits `-gnatx`. This corroborates the
[combined descriptor's propagation argument](../../research/retained-native-expansion.md#combined-native-option-descriptor).
The long-name baseline also builds: the earlier 1,995-character boundary was
loss in a sufficient analysis, not a demonstrated compiler limit.

The selected executables are the existing Alire installations of GNAT 16.1.0
and GPRbuild 26.0.1; exact invoked paths appear in the retained logs. This is
a narrow option/consumer and observable-behavior experiment, not proof that
all admitted programs compile or that every GCC pass allocation is bounded.
It does not measure warning-pass execution or replace the source-derived
pass-gate argument. Production flags, tool pins, language membership and proof
configuration remain unchanged.

`artifacts.tar.gz` preserves the exact executed runner, generated projects,
source copies, full verbose build/run outputs, Main/library/binder ALIs,
binder-generated Ada, and managed events/log. It contains no executable or
object binaries. `identity.json` records every retained file's length and
SHA-256 plus the archive digest; `result.json` is the runner's original summary.
The original directories remain at `/tmp/silver-native-option-probe-20261018`.
The runner intentionally refuses to overwrite existing case directories.

Verify the retained results offline, without rebuilding:

```sh
python3 docs/evidence/retained-native-options-20261018/check.py
```

The checker reconciles inputs, native outcomes, ALI rows and binder command
propagation. It makes no new native execution or assurance claim.
