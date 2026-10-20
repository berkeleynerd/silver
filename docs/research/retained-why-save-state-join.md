# Fresh save-entry state and conditional continuation bounds

2026-10-20 UTC, Linux x86_64, resumed research #119 / #153.

Five targeted captures fill the backing-state fields absent from the previous
logs. Their logical task/forest graphs match the corresponding retained graphs,
so the accepted conditional B/J/L bounds transfer without repeating binder or
alpha analysis. The new measurements instantiate the operational save bounds
and the arithmetic guards for 206 table applications: **203 pass; three theory
status-cache guards fail**. This is useful partial closure, not complete save
capacity, a demonstrated native overflow, or a change to admission.

The [capture packet](../evidence/retained-why-save-state-capture-20261020/README.md)
retains exact executed inputs and raw evidence. The
[numeric join](../evidence/retained-why-save-state-join-20261020/README.md) retains
each correspondence result, extension-only replay and conditional application.
It combines the [native table-prefix theorem](retained-why-save-hashtbl-prefix.md),
[later growth argument](retained-why-save-attempt-growth.md) and previously
reviewed [operational transfer](retained-why-save-operational-bounds.md).
The [combined independent review](../reviews/review-save-state-continuation-20261020.md)
accepts aggregate `057a18abff` after the fresh-state/raw-evidence join repair
`af092f2618`. Its medium finding M1 [#154](https://github.com/berkeleynerd/silver/issues/154)
is fixed with unchanged numerical bounds; no material findings remain in scope.

## What was observed and what transfers

| Process | New PID | G | Captured gshape n / each map cardinality | Captured attempts | Conditional later attempt bound |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 17310 | 65 | 66 | 14 | 208 |
| Put | 17514 | 54 | 55 | 12 | 173 |
| First_Or_Default | 17631 | 33 | 34 | 10 | 108 |
| Is_Message | 17704 | 4 | 5 | 1 | 12 |
| Input_Is_Valid | 17869 | 5 | 6 | 4 | 9 |

The first four stop before scheduling at the accepted registration endpoint;
Input_Is_Valid stops at its prior first-cvc5-inline endpoint. Each has Buffer
position zero and capacity **1,088 bytes**, an empty prover-ID table with
16 buckets, and empty old-shape storage. Bound-shape and checksum tables have
G bindings and 128 buckets. These are observed starting states, not deductions
from source initializers. The nonempty dictionary is preserved explicitly.
Map validity is checked individually; their inverse relationship is unnecessary
for this operational bound.

The collector reads full strings, finite table chains, duplicate bindings,
separate scalar sizes, bucket capacities, persistent maps and restored-path
ephemerons. Six initial offline fixtures, subsequent comparator/replay fixtures
and five byte-identical extension replays support the decoder. A failed field
would remain unknown; all five named projections completed.

The graph comparison preserves sharing, immediate values, tags, sizes and
payloads under a checked pointer bijection. The first Put_Line comparison
rejected a Zarith custom-operations address changed by relocation. The repair
recognizes only the pinned `ml_z_custom_ops` table, validates its ELF/source and
load-bias witnesses, and compares every remaining custom-payload byte exactly.
Unknown custom blocks remain rejected. This is a correspondence repair, not a
new binder calculation. The five successful comparisons cover respectively
115,020 / 95,672 / 42,481 / 14,087 / 16,106 logical blocks and retain B values
41,946 / 33,252 / 10,195 / 744 / 966.

The comparison transfers only the named immutable logical projection and its
conditional occurrence bounds. It does not transplant mutable state between
processes or prove that every future execution has this graph. New backing
state is evidence from each new process. Root and graph observations still use
the existing faithful-runtime and relevant-source/native premises.

## Continuation arithmetic and the exact remaining table obstruction

The growth argument applies **one** post-cut budget of at most two signal saves
plus one ordinary save, subject to the continued signal/native contract. It
does not reset that budget at each save entry. It also corrects an unjustified
extension of the normal scheduler-entry count: a caught `Not_found` from a
signal save can make an already tried pair appear untried. The retained finite
pair-key domain K remains usable; total binding growth is bounded by K+2.
The later attempt bounds above replace the provisional A0+K figures.

The shared prover-ID allowance is P+2 over the entire continuation: 6 / 6 / 6 /
6 / 7 insertions, against an observed capacity of 16 buckets. This passes its
no-resize arithmetic where the older coarse `3*A` allowance did not. The old
operational output is retained separately; no old result is rewritten to hide
that distinction. Per-goal attempt tables use at most five new bindings; the
two exceptional additions are global, not independently spendable per goal.

Every scalar size and binding count is measured separately. The native theorem
excludes resize with `size0 + additions <= 2*capacity`, or the justified
clear-before-add variant for bound shapes. Its control argument uses actual
poll locations and nonreturning nested saves; source-level stores alone do not
establish atomicity.

For the theory status cache, all five initial sizes are zero and capacities
are 16. Whole-continuation additions are bounded by Th+2, giving
**48 / 48 / 43 / 14 / 23**. The first three exceed 32. Restricting Th to the one
nonempty theory would be unsound: `update_file_node` can call `th_proved` on
empty theories as well. The relevant source route is retained in the growth
packet. A failing sufficient guard does not show that the actual tool fails;
it leaves this no-resize proof unavailable. The next table obligation is a
bounded argument for this selected theory-cache resize and its interruption
prefixes, or another sound guard derived from the actual route.

Passing arithmetic is not the whole table theorem. The numeric interface
marks the decoded entry-layout premise true and retains the other continuation
key/payload, native/signal, operation and traversal-client premises separately.
It does not set a full prefix or save-capacity flag merely because a numeric
inequality passes. The selected source cuts exclude a suspended earlier
metadata-table mutator, as established in the companion growth argument.

## Remaining joins

- Bound interrupted scheduler/constructor entries for `next_proofAttemptID`.
  A binding bound does not count prefixes abandoned after incrementing that
  counter but before publishing membership. The normal 459-entry envelope is
  not promoted to the interrupted route.
- Complete the theory-cache resize obligation above and the continued
  native/signal, key/payload and traversal contracts. Ordinary successful lookup
  coverage is also distinct: a signal save can observe per-goal membership
  before the global proof-attempt record has been installed.
- Join complete serializer input lengths, new selected prover strings,
  restored-path liveness/preservation, scalar formatting and Format storage.
  The new packet records restored-path and fallback lengths, but a stopped weak
  lookup is not automatically preserved throughout continuation.
- Finish native allocation/hash/string, channel/file-offset, error/exit and
  whole-process counter composition. Then the wider driver/solver/report,
  fixed-library and current-grammar obligations of #119 remain.

New execution consists of five stopped prefixes in two serialized managed runs,
not a solver, native proof audit, Lean build or full test suite. Re-executing
these prefixes was necessary because the prior raw logs did not contain the
backing fields. Accepted observer/binder/alpha offline analyses were not
replayed; only the new extension was decoded again from its retained bytes.
The four-case runner's historical “five” message and the inline plan's stale
endpoint label remain preserved and explained in the capture packet.

Oracle, installed tools/pins, current admission and production #88–#94 are
unchanged. Draft PR #121 remains unmerged. Round 28 records selected model
settings, review disposition and available aggregate cost; a completed
component does not complete #119 or #153.
