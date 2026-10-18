# Fixed native frontend capture

Linux x86_64, 2026-10-18, Refs #119. Managed run
`20261018T033439-c9e429f9f302` completed the isolated native witness in 27.27 s.
It uses the application's Ada 2022/assertion/strict-overflow flags and O0; the
retained driver dry run supplies the actual gnat1 argv. The direct invocation
writes assembly, reaches gigi and the compiler main-return instruction, and
stops there under GDB. The recorded exit status is GDB's; it is not a solver,
assurance audit, linked application run, test suite or proof result.

The source has one First_Or_Default input, one Integer'Image, and declaration
and output concatenations with 2 through 10 dynamic operands. This reaches all
eight Concat runtime specs, the secondary-stack roots and the integer Image
roots. The entire witness remains counted, including its ordinary Main work.
No subtraction or sample extrapolation establishes a fixed constant. Promotion
of these observations requires the native source root/order/first-freeze
reduction, separately from this capture's completeness checks. Variable Main,
backend, name spelling, source paths and scope-save terms remain separate.

| Logical lifetime growth | Before gigi | After gigi | Compiler return |
| --- | ---: | ---: | ---: |
| AST identities, including sentinels 0 and 1 | 40,888 | 40,888 | 40,888 |
| Dynamic AST slots | 438,857 | 438,857 | 438,857 |
| Syntax-list headers | 6,526 | 6,526 | 6,526 |
| Element-list headers | 977 | 977 | 977 |
| Element records | 2,096 | 2,096 | 2,096 |
| Uint entries | 23,711 | 24,324 | 24,324 |
| Uint digit words | 72,181 | 74,958 | 74,958 |
| Ureal entries | 53 | 60 | 60 |
| String descriptors | 203 | 203 | 203 |
| String characters | 7,255 | 7,255 | 7,255 |
| Name entries, including reserve | 6,169 | 6,169 | 6,222 |
| Name characters, including reserve | 115,228 | 115,228 | 117,918 |

`summary.json` retains all 120 positions at each boundary. A frontend-only
snapshot would miss the additional numeric work in gigi, plus later name work.
This is a generic Table.Last vector, not all GCC tree/GIMPLE/RTL objects,
physical heap capacities or stack bytes. The native table set matches the
light producer's set except for the light-only ALI.Util.Source table.

The complete executable scan covers 34,883,369 text bytes and 8,139,409 decoded
text instructions. All 2,160 direct stores are partitioned into 1,144 retained
decrease-capable/unknown hooks and 1,016 source-proved monotone stores, using the
[light capture's source argument](../retained-main-semantics-20261018/fixed-capture/README.md).
Unknown private-function stores remain hooked. Native Release_And_Save's inner
Release calls remain out of line, so their separately hooked releases precede
the omitted append stores. Lifetime growth is exactly final minus initial plus
every decrease, including inlined release copies.

The ELF supplement checks all five executable sections, width-overlapping
references, absolute/immediate operands, relocations and aliases: no extra
reference is found. This native executable is ET_EXEC, stripped of .symtab but
retaining all 120 Last globals in .dynsym. Its 240 4/8-byte address patterns in
.dynsym are the globals' st_value metadata, not runtime pointers. The sole other
pattern begins at offset 33,130 in .eh_frame_hdr and straddles two 4-byte table
fields. No data-held Last address or address-taking instruction exists. Generic
Last_Val is a private nonaliased scalar with no address/access export in source;
the selected invocation enables no plugin. Source-to-installed-tool identity
remains the capacity contract's explicit premise.

The debugger zeros only the chosen range-cache key in the disposable inferior.
Native Determine_Range disassembly identifies the key array at 0x3634c80 and
original-node array at 0x3633c80. Its exact RET site records the ABI return
without dynamic stack unwinding. All 26,524 discrete entries have returns;
2,374 distinct (N, Original_Node, Assume_Valid) keys have zero mathematical
result/status mismatch. There is no real-range call. The source cache-erasure
argument is separate; this record checks its trace-coherence condition.
Installed source/binaries and production caches remain unchanged.

The optional name decoder originally used Names_Low_Bound as the physical
lower bound of Name_Entries. The source explicitly uses First_Name_Id, two
positions higher (namet.ads:623–632). `decoded-names.json` corrects retained
spelling IDs by +2 and reconstructs every source-file name from raw IDs. No
compiler rerun was needed; counters, range keys and decoded Uint values are
independent of that descriptive name mapping. The fixed input generates TdS,
TTdSP1 and their main__ qualified forms, agreeing with the separately charged
4*(|D|-1) source-name correction. Variable default-literal costs remain separate.

Two unsuccessful instrumentation attempts are retained. Run
`20261018T032946-85624f838e0f` stopped after 0.32 s because GDB cannot finish the
outermost main frame; it did not enter the frontend. Run
`20261018T033045-68651321e364` was interrupted after 154.13 s to diagnose the
cost of dynamic FinishBreakpoints on the stripped binary. Its optional final
name reader then rejected a zero-length memory read; no partial vector is
promoted. The managed diagnostic checkpoint records the fix: exact RET hooks,
pre-resolved symbol addresses, periodic progress and mandatory counters written
before optional names. The 27.27 s successful capture is the only complete run.

`capture.tar.gz` contains the exact scripts, invocations, sources, assembly/ALI,
raw observations and executable scans. `archive-manifest.json` hashes every
member. `inputs.json` records the installed runtime sources, compiler/debugger
and copied Silver sources. `managed-runs.tar.gz` retains all three managed runs.
Scratch scripts refer to `/tmp/silver-native-fixed-counter-20261018`; reconstruct
an isolated workspace before re-executing them, never run them in this evidence
directory. The successful capture should be reused.

```sh
python3 docs/evidence/retained-native-fixed-capture-20261018/verify.py
```

This offline check reconciles the evidence, not the complete capacity rule.
