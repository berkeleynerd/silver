# Fixed Main light-mode frontend capture

Linux x86_64, 2026-10-18, Refs #119. The source argument and usable component
constants are in [retained-main-semantics.md](../../../research/retained-main-semantics.md#fixed-light-capture-result).
This directory retains an isolated installed-tool execution, not a solver,
GNATprove assurance audit, Lean run, test suite or native-expansion measurement.

`summary.json` gives all 121 logical table-growth constants. The successful
managed run took 9.71 seconds. Its tiny Main and all its work remain included;
no subtraction or sample extrapolation establishes these constants. The
report's fixed-root reset, first-freeze and cache-erasure arguments are required.

`static-all-tables.json` inventories 4,380 direct references to 121 Table.Last
positions plus the range-cache key array across 16,479,721 text bytes and
3,866,005 decoded instructions. All 2,299 stores to the Last positions are split
between 1,265 retained hooks and 1,034 source-proved monotone stores. The five
address-taking references concern the cache array only; none takes a table
position's address. The inventory includes Ureal.Release copies in comparisons
and Is_Fixed_Model_Number, which a symbol-only Release breakpoint misses.

The [ELF coverage supplement](address-coverage.json) checks all five executable
sections, memory-operand widths that overlap any byte of a Last position,
absolute/immediate address candidates, dynamic relocations and GOT references,
overlapping symbol aliases, dynamic exports, and 4/8-byte pointer patterns at
every offset in allocated file-backed data sections. It finds no additional
reference, alias, relocation, exported position, address-taking instruction or
data pointer. All 4,375 direct Last references match the earlier inventory;
the other five references address the range-cache array. The executable is
x86-64 PIE (`ET_DYN`). Generic `Last_Val` is a private, nonaliased scalar
(`table.ads:224–239`); its complete body has no address/access export of that
scalar. Together this source property and the selected ELF checks exclude an
unobserved indirect store route under the source-to-installed-tool premise.
The supplemental reader needs the same scratch Python packages; no compiler
execution was repeated for this coverage check.

The monotone exclusions use generic Table.Append/Append_All/Increment_Last/
Set_Item, Atree's node/slot/growing-kind and copy allocators, Nlists allocation,
Elists append/new/insert operations, Namet.Name_Find/Name_Enter, Uint append
paths, Ureal.Store_Ureal and Stringt append/copy paths. The latter source sites
only grow logical Last; generic table initialization, save/restore, clear and
set-last sites remain hooked. Unknown specialized stores remain hooked too.
`Namet.Unlock` decreases remain included. Exact positive growth is recovered
by final minus initial plus every decrease. See table.adb:69–125,300–373,
atree.adb:502–516,1083–1105, nlists.adb:125–132, namet.adb:1138–1275,
stringt.adb:158–369, uintp.adb:693–759 and the report's pool-reset frontier.

The debugger only writes zero to the selected Determine_Range cache key in
its disposable inferior. It does not change source, installed executables or
production cache files. The all-miss run has 179 entries and 179 returns,
152 distinct keys, no repeated-key result mismatch, zero real-range calls and
zero backend launches. Mathematical Uints are decoded from the stopped process;
handle equality is not substituted for value equality. A complete pre-Free
boundary is required. Startup initializes before Main; the final vector
includes driver, ALI reader and producer phases as well as frontend analysis.
The report separates the variable Main/ALI/path contributions from this fixed
witness allowance.

The earlier read-only baseline used 146 pool-store hooks and observed 1,812 Uint
and 42,063 digit-word appends. All-miss counts are 1,820 and 42,087. Two broad
instrumentation attempts were incomplete: one timed out after 120 seconds;
one was interrupted after 153 seconds to retain a cost diagnosis. The latter's
hot stores were monotone AST and name allocators. The successful 9.71-second
capture uses the exact decrease identity to omit their callbacks. Their raw
logs and managed identifiers are retained; neither incomplete attempt is used
as a capacity observation. An earlier cache diagnostic's source-position read
used an incorrect Slots lower-bound offset and is superseded by the final
reader checked against the installed Sloc accessor.

Reconcile retained coverage, return coherence and arithmetic without executing
a compiler:

```sh
python3 docs/evidence/retained-main-semantics-20261018/fixed-capture/verify_capture.py
```

`counter-all.py` and `run_all.py` retain the exact successful debugger setup.
They reference the isolated `/tmp/silver-frontend-fixed-counter-20261018`
workspace and its retained global-generation ALIs. They are evidence readers,
not a portable production command; reconstruct an isolated workspace before
re-executing them. Do not execute them directly in this tracked evidence
directory. The [fixed numeric producer evidence](../../retained-producer-numerics-20261018/manifest.json)
retains the selected prerequisite inputs and builds in its
`inputs-fields-and-runs.tar.gz` archive. `inputs.json`, `invocation.json`, `options.json` and `capture-record.json`
record identities, configuration, managed runs and the scratch analysis tools
(Capstone 5.0.9 and pyelftools 0.33). Source-to-installed-tool identity remains the
explicit capacity-contract premise.
