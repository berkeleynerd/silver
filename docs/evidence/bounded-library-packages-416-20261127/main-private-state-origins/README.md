# Main scalar origins and private-state reset — 2026-11-27

Focused run `20261127T202642-b50241972628` passed with a fresh audit of
34,630 declarations. All 1,566 captured source hashes match the retained
checkpoint. It used two Lake workers, two threads per process and 8,192 MiB per
process within the host's eight-CPU allocation. Matching dependency objects were
reused; this is neither complete feature assurance nor independent kernel replay.

`ScalarsFrom` records that every unqualified scalar starts at or after a chosen
original Main cursor. Imported scalars are qualified; argument initialization
preserves them; every ordinary Main declaration preserves the invariant. Local
function/procedure bodies return their outer scalar environment. The body-context
conversion preserves defining positions. Metadata validation separately places
every private state before its recorded Main unit.

Those source-position facts imply that no private Integer state is visible from
Main, including when a Main local uses the same spelling. The native reset slot
list is therefore empty, and the original procedure statement feeds the ordinary
Main checker at its translated package identity with its exact output flow and
all statement obligations discharged. Neither an empty-reset certificate nor a
successful semantic call is assumed.

The final application composition must still connect the chosen cursor to the
original source bundle and its metadata unit table. The accepted Analyze guard
checks that unit-table equality; the standalone Main helper precondition does
not supply it. Nested loop binder origins are the parallel loop-reading work.

Three failed drafts remain labelled failed. The initial attempt rebuilt useful
dependencies before exposing local let reduction, helper-import and implicit
argument errors. Later attempts isolated a Boolean-decision instance wrapper;
explicit proposition extraction resolved it. Native sources, theorem domains
and proof budgets were unchanged. Command output is labelled separately from
runner events and the final successful runner evidence.
