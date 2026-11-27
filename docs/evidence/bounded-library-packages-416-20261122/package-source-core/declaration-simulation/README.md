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

## Function input modes in the declared formal table

`readSpecification_formal_modes` propagates the original Signature guard
through every Specification iteration. New signatures append a contiguous
formal segment. A completion writes the new body spans back to existing
cells while preserving their modes. The proof follows every return,
including failure after a partial write, and covers zero-formal functions.
Starting from the empty metadata table gives the property for every source
routine. Updating a routine's body location and effects preserves it when
kind, first formal and count agree.

`DeclaredFormalModes.function_inputs` yields input mode for each member
of a function's semantic formal list, with the underlying one-based slot
bounded by the physical table. The argument comes from the declarations
and their ordered writes. Native metadata validation alone permits tables
outside this source-derived invariant.

`Silver.ApplicationPackageDeclarationsFormalModes` passed Linux x86-64
focus `20261127T143040-5e2cc019aafb` with two workers and two threads,
8192 MiB per process. The build took 7.171 seconds and the fresh audit
checked 24,930 declarations in 3.005 seconds. The `formal-modes-` records
retain the exact inputs and imported modules.

## Native domains for declaration callees

`ReaderFrame` supplies the machine component bounds and the executable
`Valid_State` for a declaration frame. These yield the imported state
domain used by the name and header readers. Changing the cursor within
the source or changing the parser flags preserves the frame domain.
Successful `Hide_Outer` compaction retains the component bounds through
all three filtered tables and checks the resulting state.

A successful `Package_Type_At` returns a valid source name, moves the
cursor forward within the text, and produces an ordered, machine-bounded
interval. The theorem covers Boolean, predefined Integer and exported
subtype results as well as the rejected read. Applying these properties
to every call in each declaration reader is still pending.

Linux x86-64 run `20261127T144321-b6782fe899aa` built
`Silver.ApplicationPackageDeclarationDomains` in 4.825 seconds and
freshly audited 46,308 declarations in 3.411 seconds. It used two Lake
workers, two threads per process and 8192 MiB per process. The
`reader-domains-` log and evidence retain the inputs and results.
Earlier runs `20261127T143644-e58598fa9482` and
`20261127T144235-60c6cbd97b76` retained the rejected proof terms and
the deprecated rewrite names, respectively.

## Source order of completed body formals

`readSignature_completed_order` follows the canonical completion reader
from its routine keyword through the closing `is`. It identifies the routine
written at the incoming completion index plus one. Every body-formal name
in that routine's physical parameter segment is positive, starts at or
after the input cursor and ends strictly before the returned cursor. Each
earlier name ends before the next name starts, including nonadjacent slots.
The return cursor advances within the source even for a zero-formal routine.
The proof uses the actual completed table writes, mode and type reads,
and the loop exit and continuation guards.

`SignatureExec.retains_states` separately follows every raw Signature
return, including failure after a partial formal write, and proves that
the state declaration table equals its input. `readSignature_states`
specializes this to both canonical reader modes.

Linux x86-64 run `20261127T150057-02d7fe0f67a8` checked both the complete
formal-span result and the state-table theorem. It built in 4.314 seconds
and freshly audited 27,572 declarations in 3.191 seconds, with two workers,
two threads and 8192 MiB per process. The `completion-spans-` log and
evidence retain the targets and input digest. The earlier table and loop
checks were `20261127T144941-41ed9c4ca023` and
`20261127T145208-64b2849150b2`. The managed diagnosis for
`20261127T145827-e0ee80b1808d` records the final return normalization.
