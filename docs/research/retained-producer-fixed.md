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

## Selected imported dependencies

Five isolated current-library witnesses have now been measured with the same
installed binary, raw-memory reader and phase boundaries. Their
[retained evidence](../evidence/retained-producer-dependencies-20261018/README.md)
includes all 15 graphs, current source/ALI inputs, exact options and managed
logs. The offline checker recomputes the values below and matches the six
copied library sources to the delivered tree and recorded run inputs.

| API root | Post-Standard nodes | Lists | Retained elements | All-root occurrences | Additional retained theory roots |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put | 2,601 | 544 | 866 | 3,628 | 63 |
| Put_Line | 2,634 | 549 | 875 | 3,692 | 63 |
| First_Or_Default | 1,939 | 476 | 678 | 2,980 | 41 |
| Input_Is_Valid | 762 | 229 | 268 | 1,284 | 23 |
| Reject | 932 | 219 | 328 | 1,475 | 29 |
| Sum | **8,868** | **2,017** | **3,015** | **13,059** | **219** |

Every witness's Standard state is identical to the retained baseline, and its
Standard nodes/lists remain unchanged in the final graph. These observations
corroborate the source argument; they do not replace it. Each row retains the
entire witness Main contribution. First_Or_Default also reaches Input_Is_Valid
through its contract, and all shared dependencies remain deliberately counted
more than once. No maximum over samples is being extrapolated.

Under the [isolated-root source reduction](retained-producer-capacity.md#additive-isolated-root-envelope),
use all five rows even for zero-API Main. Their sum bounds the selected imported
non-import work, including richer fixed entity/symbol fills. Adding the paid
Standard state gives the fixed starting vector

```text
(nodes, lists, elements, all-root occurrences) = (15349, 3310, 4729, 22621).
```

Add the ordinary Main transfer separately. Import allocations already present
in these measured rows are intentional overcount: the aggregate still charges
all post-Standard close-time imports using its general `C`/`M` allowance.
The fixed part of `C` can conservatively use 219. On a completed source path,
each Close_Theory inserts its unchanged name/id into Symbol_To_Theory_Map;
closing the same theory twice cannot complete the insertion
(`why-inter.adb:743–749`). Open_Theory creates a fresh retained theory node,
and the exposed theory mutators append contents without renaming it. Thus the
additional retained theory roots bound completed post-Standard closes; unused
roots and the five witness Main closures are retained as overcount. This is
a source reduction applied to measured roots, not an independent measurement
of call counts or a claim about failing/aborted producer paths.

All five probe subprocesses completed in 4.659 seconds total, plus the recorded
phase-one prerequisites and managed-run overhead. No solver ran. The isolated
Input_Is_Valid/Reject witnesses are valid Ada/SPARK probes but need not meet
Silver's full shell membership rules. They measure fixed dependencies only.

The fixed reduction covers these four allocation/occurrence components. It
does not transfer observed temporary-name counts to a universal bound, price
name bytes/container peaks, or cover separate library-body producer processes.

## Separate fixed library processes

The four selected library compilation units also have isolated producer
measurements, using the exact current sources and already retained phase-one
ALIs. They are separate processes: their tables are not added to Main's budget.
The [bundle and offline checker](../evidence/retained-producer-bodies-20261018/README.md)
retain all 12 graphs, the five emitted JSON files and four managed run records.

| Unit | Final nodes | Lists | Retained elements | All-root occurrences | Emitted files |
| --- | ---: | ---: | ---: | ---: | ---: |
| Silver_IO body | 16,547 | 3,222 | 5,108 | 26,501 | 2 |
| Silver_Arguments body | 13,070 | 2,796 | 4,111 | 20,733 | 3 |
| Silver_Output_Libc specification | 8,714 | 1,683 | 2,476 | 13,189 | 0 |
| Silver_Runtime specification | 7,376 | 1,574 | 2,120 | 11,156 | 0 |

These counts include Standard and all completed theory imports. The bodies
can generate several VC files before Free, so these probes permit asynchronous
launches of `/usr/bin/false` and stop before any result collection or a 63rd
launch. Every process reached Free first. No solver ran and no proof outcome
was accepted. The source order generates every entity's VCs before Free
(`gnat2why-driver.adb:1445–1455`), then collects results after Translate_CUnit
returns (`:1013–1015`). Result collection during translation is possible at
the subprocess limit or in serial mode (`:1235–1244`); the recorded configuration
and guards excluded both here. Backend results therefore did not influence the
measured prefix. The four probe subprocesses took 4.151 seconds in total.

Each invocation's compilation unit, dependencies, options and source bytes are
fixed, with no Main source in its inputs. Runtime argument values are symbolic
within those fixed bodies. Thus these finite cases supply their producer
node/list/occurrence capacities under the recorded invocation and source
premises; this is not extrapolation from example Main programs. Monotone Why
storage makes the final retained counts sufficient for that component.
Frontend arithmetic, transient container peaks, report handling after Free,
and actual obligation discharge are separate. The production pipeline's
existing validation remains authoritative for proof outcomes.

These measurements use today's library bytes, including today's Max_Length.
The authorized runtime-capacity changes must refresh these fixed cases and
their dependencies before delivery, as #93 already requires. They do not
establish the cost of a future changed library or an Image-tool process.

## Remaining limits

This applies to the recorded installed Linux producer and the finite fixed
Standard case and the selected imported-dependency envelope under the linked
source/cache argument, plus the four recorded library producer processes.
The complete ordinary Main source-to-allocation transfer,
producer auxiliary representations, native expansion/backend bounds and their
whole-rule composition remain independent requirements.

The [source-identity investigation](retained-tool-source-identity.md) did not
recover the historical SPARK revision of this binary. The raw measurements
identify the actual binary; the general phase-independence and monotonicity
arguments still depend on the candidate source corresponding to its relevant
behavior. These different evidence classes must remain distinct. The current
capacity derivation remains unfinished and production admission is unchanged.
