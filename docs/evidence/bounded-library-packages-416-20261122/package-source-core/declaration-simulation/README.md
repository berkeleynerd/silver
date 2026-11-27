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
