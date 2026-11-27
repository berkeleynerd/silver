# Routine_Frame imported closure

Authorized #416 source/contract closure, 2026-11-27. Selected proof role: Astra
Max; live model/effort is not independently exposed. This increment adds five
proof modules and evidence. No native source, guard, metadata-validity premise,
input restriction or proof budget was changed.

`Library.body_imports` interprets the complete typed native Routine_Frame body
with arbitrary incoming local storage on its full original ValidText,
ReaderFrame and cursor preconditions. Metadata remains arbitrary. The original
inactive routine and formal-range rejection paths, both complete formal passes,
and final validity rejection are retained exactly.

The first pass proves every later Append name precondition, including names of
output formals. It preserves ReaderFrame through actual imported Hide_Outer.
The second pass preserves the native component and capacity domains of the
final Valid_State call even when formal ranges are empty or malformed.

The Body_Environment import is derived from its existing checked full-array
Count/Items native contract. Append is derived from its exact whole-frame
native postcondition under its original positive/ordered-name precondition.
The projections quantify arbitrary inactive scalar and Boolean storage; no
scratch or inactive cell is assumed initialized. Actual name, hiding and
validity calls come from the existing imported source libraries. The library
retains explicit raw native contract interpretations; it does not assume a
Routine_Frame result equation or postcondition.

`routine_frame_valid` proves the native Valid_State postcondition on every
result, including rejection, without any metadata premise. The stronger
`routine_frame_reader` also preserves native StateType; it needs only
ParameterBounds, the native Interval component bounds of the parameter table.
This allows empty and unordered intervals. `parameterBounds_of_typed` derives
that fact from the existing native Metadata.Typed predicate, without requiring
Valid_Metadata or Complete_Metadata.

`SourceLibrary.complete_contract` joins exact Routine source/header extraction,
the whole Append interface and scalar environment source contract with the
imported body equation and full postcondition. `SourceLibrary.reader_frame`
exports the complete caller frame under the component subtype facts. Root owns
instantiation with authoritative source extraction and the remaining Completion
integration; this private focus does not claim the final repository checkpoint.

| Scope | Managed run | Fresh audit |
| --- | --- | --- |
| Entry/pass domains and arbitrary-storage import projections, with current Object frame refresh | `20261127T214729-64239ee3783e` | 71,073 declarations |
| Complete imported body, full postcondition and source-contract binding | `20261127T215425-45f65b025e62` | 50,538 declarations |

Both checks used Linux x86-64 / Lean 4.34.1, explicit affinity 4–5, two managed
workers, two threads per process and 8192 MiB/process, with cached prerequisites.
The complete run's captured inputs were rehashed locally and against every
shared primary input; details and private new files are retained in
`complete-input-recheck.json`. No complete repository or native run is claimed.

Draft diagnostics were local Lean normalization issues: dependent decision
instances, an unreduced initial let, Boolean guard reduction and unused simp
arguments. The managed ledger retains them and their focused next checks.
There was no semantic counterexample, native edit or domain narrowing.
