# Fixed producer setup measured in the installed tool

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
The installed producer's setup and Standard translation now have retained
allocation measurements. These close a fixed component under the phase and
source-correspondence premises below. They do not establish the whole-source
capacity rule or enlarge admission.

## Observations

The [evidence bundle](../evidence/retained-producer-fixed-20261018/README.md)
retains the exact invocation, input, binary identities, raw debugger log and
three complete node/list graphs. GDB read memory using symbol addresses and
DWARF offsets. It neither called inferior functions nor modified the executable
or sources. Execution stopped at `Why.Atree.Free`; the producer backend was
disabled. The global-generation prerequisite and this measurement are actual
native tool executions, not proof or test-suite runs.

| Stop | Usable nodes | Lists | Retained list elements | Temporary names | Expanded occurrences across all retained theory roots |
| --- | ---: | ---: | ---: | ---: | ---: |
| Before Standard | 1,445 | 0 | 0 | 0 | 0 |
| After Standard, before compilation-unit translation | 6,481 | 1,293 | 1,714 | 168 | 9,562 |
| Before Free, after this null Main | 7,136 | 1,482 | 1,936 | 189 | 10,639 |

The node table also contains one allocated sentinel at index zero. The first
row matches the separately source-derived 1,439 initializer nodes plus six
cached Boolean literals. Standard adds **5,036 nodes, 1,293 lists and 1,714
elements**. Its retained graph has 98 theory roots. Root count is not asserted
to be an independently measured `Close_Theory` call count.

The final row is only an observation of the null sample. It is not a bound for
other Main programs, imported libraries or other processes. The measured
producer subprocess took 0.856 seconds; the managed ledger includes its wrapper
overhead. No solver, complete native audit, Lean build, full suite, macOS check
or CI run belongs to this result.

## Why the fixed boundary is useful

The candidate source initializes names, built-in modules and Why sections
immediately before Standard, then calls `Translate_CUnit` afterwards
(`gnat2why-driver.adb:998–1013`). Standard translation visits the fixed 20
`S_Types` entries plus five explicit types (`:1644–1687`); the target's predefined
types and their SPARK membership determine the selected paths. Under the fixed
target/options and the established source-shape premises, source declarations
cannot change those predefined types. This is the basis for a finite fixed
case, rather than extrapolation from the null program's own translation.

The source tables are append-only until `Free`: `why-atree.adb` appends nodes
and lists and only appends/prepends retained list members; `Free` alone clears
them. Generated mutators update node fields, not list membership. `Get_List`
returns a by-value Ada list, so a caller's local mutation cannot delete a
retained list element. Thus the measured node/list counts and summed retained
list lengths account for lifetime retained allocations before this boundary.
Temporary Ada container copies and their growth remain separate obligations;
the measurement does not claim their peak memory use.

For the producer aggregate, one may start after Standard with the measured
fixed allowance. This already pays for Standard's close-time imports. Add
the remaining dependency/Main pre-import bounds and the import allowance for
their remaining unpaid closes. Do not add the built-in initializer again or
silently count Standard imports both as an unpaid requirement and an exact
measurement. Conservative double charging is possible, but must be stated.

The expanded-root metric recursively counts each node occurrence and list
member, including repeated references to shared nodes. Optional node zero
contributes no serialized node. `Build_Printing_Plan` maintains a per-file Seen
set and appends each selected theory once (`gnat2why-util.adb:503–540`), and
`Print_GNAT_Json_File` serializes that plan (`gnat2why-driver.adb:1205–1215`).
Consequently the sum across all fixed theory roots is a conservative per-file
contribution when those roots remain unchanged. Apply the aggregate's separate
emitted-file multiplicity; this graph reading did not run the serializer or
measure its lifetime ID counter. Imported theory references do not recursively
embed the imported theory in an include node.

## Remaining limits

This applies to the recorded installed Linux producer and the finite fixed
Standard case. Selected dependency subsets, ordering and cache effects still
need complete coverage. The ordinary Main source-to-allocation transfer,
producer auxiliary representations, native expansion/backend bounds and their
whole-rule composition remain independent requirements.

The [source-identity investigation](retained-tool-source-identity.md) did not
recover the historical SPARK revision of this binary. The raw measurements
identify the actual binary; the general phase-independence and monotonicity
arguments still depend on the candidate source corresponding to its relevant
behavior. These different evidence classes must remain distinct. The current
capacity derivation remains unfinished and production admission is unchanged.
