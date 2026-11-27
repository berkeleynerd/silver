# Package specification execution and type import

Linux x86-64 focused run `20261127T134318-bf16970a6508` checked
`Silver.ApplicationPackageDeclarationsSpecificationSimulation` and
`Silver.ApplicationPackageNamesTypeImports` with Lean 4.34.1, two Lake workers,
two threads per process and a 12,288 MiB per-process limit. The incremental
build took 5.316 seconds. The fresh axiom audit checked 45,555 declarations
in 3.265 seconds. The compressed log and runner evidence identify the inputs
and complete import closure.

`SpecificationNative.exec_iff` equates the complete typed body with the raw
procedure relation in both directions. It quantifies over call dictionaries,
incoming local storage, backing arrays, source text, metadata and result. It
distinguishes procedure return from loop exit, retains the updated metadata
on rejection, and proves the same cursor progression and export writes for
routine, subtype and object branches. The finite-run lifting proof reconstructs
a concrete native execution from every raw execution and incoming store.

`ApplicationPackageNames.Native.imported_type` derives the package type reader
from the existing checked function header, inherited lexical and package
routines, and visibility and metadata libraries over their native input
domains. `Function_Type_At` uses the default zero qualifier for its Boolean
shadow lookup. Qualified scalar result spans retain the original source origin.
The native `Valid_State` decomposition separates the positive `Cursor` type
bound from the source checks on the context origin and package name span.

Run `20261127T132659-ef880470572f` recorded the original branch failures.
The typed and raw conditionals had already reduced together. The revised
branch proofs split the remaining freshness and type choices directly.
Complete Signature simulation, authoritative source binding and integration
with admission are separate obligations.

## Signature execution

`SignatureNative.exec_iff` relates the whole typed Signature to its raw
procedure relation for arbitrary native callee dictionaries, incoming stores,
backing arrays and completion flags. The entry distinguishes new routines from
completions and guarded loops from zero-formal signatures. The proof covers
the original duplicate-name range, shadowing, all formal modes, typed formal
and result comparisons, partial updates on return, and the closing token. New
formals and routines overwrite exactly the cells exposed by count growth.
The saved routine slot invariant follows from entry and each loop step.

The native command lists and raw formal steps are grouped at the name, type
and storage boundaries. The first run below compares the former raw step
definition with the grouped one for all call dictionaries and inputs. The
comparison source is retained in this packet. The complete original
1,536-token Signature source proposal still checks after grouping. The
Specification and Signature read-execution corollaries specialize the typed
bodies to their canonical callees and total recursive readers. Linking the
remaining actual callee dictionaries to those canonical meanings on their
native preconditions belongs to the next source interpretation work.

| Linux x86-64 focused run | Targets and result |
| --- | --- |
| `20261127T134956-373c20132b82` | Preserved raw step, complete formal storage, and both terminating readers. Build 5.210 seconds, audit 22,193 declarations in 3.288 seconds. |
| `20261127T140321-0edf891e635b` | Full typed Signature execution and original Signature/Append source proposal. Build 74.252 seconds, audit 23,241 declarations in 3.235 seconds. |
| `20261127T140507-377f328e9481` | Both canonical typed readers, full Signature and Specification simulations, and the cached Signature source proposal. Build 9.968 seconds, audit 23,367 declarations in 4.387 seconds. |

All three used Lean 4.34.1, two Lake workers, two threads per process, and an
8192 MiB per-process limit. Each compressed log and evidence record lists its
actual targets and run inputs.

## Names callees used by the declaration readers

`ApplicationPackageNames.Native.imported_readers` interprets the six typed
readers for package words, the SPARK pragma, allowed names, fresh names,
outer declarations and types. It uses the shared primitive imports and the
linked function header, metadata and visibility libraries. The type reader
derives the full header input from the parser frame's machine types and
executable `Valid_State`. The inherited state-record projection now reads
the scalar, Boolean and context bounds from the expanded native clauses.

Linux x86-64 focus `20261127T142147-dc3bf2531e69` built
`Silver.ApplicationPackageNameReaders` in 18.458 seconds and freshly audited
44,552 declarations in 3.379 seconds. It used two workers, two threads and
an 8192 MiB per-process limit. The `name-readers-` log and evidence record
identify the imported modules and inputs. Per-call obligations in Signature,
Specification and Object still require their native cursor and frame domains.
