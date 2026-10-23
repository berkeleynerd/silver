# Current registration to fixed protocol storage

2026-10-23 UTC; #119 / #153, author base `2b9e9f780f`.
This attaches the accepted fixed protocol-count envelope to the current
combined quiet/timeless/J12/logging registration. It introduces no new cap,
runtime invocation, implementation or whole-process capacity claim.
The [packet](../evidence/retained-current-protocol-join-20261023/README.md)
records exact providers and one new arithmetic/identity check.

## Three different counts

The accepted [combined startup](retained-combined-parallel-startup.md) preserves
the [J12 registration map](retained-parallel-logging-prefix.md) and its actual
goal IDs. The raw child forest includes goals discharged as Trivial, omitted
registration keys and registered roots; counting all children is conservative
but is not the same operation as counting registered scheduling roots.

| Domain | Raw children | Registered roots g | Parallel run entries <=3g | Broader preparation Q=3g+2 | Retained protocol N |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 64 | 51 | 153 | 155 | 192 |
| Put | 53 | 42 | 126 | 128 | 159 |
| First_Or_Default | 32 | 22 | 66 | 68 | 96 |
| Is_Message | 3 | 2 | 6 | 8 | 9 |
| Input_Is_Valid | 4 | 1 | 3 | 5 | 3 |

Registered roots are the complete map, including any mapped Trivial root;
subtracting such roots is unnecessary. In particular, Input has four raw
children but only the single registered root with goal ID 3. This is read
from its own current J12 registration, not borrowed from an old serial or
post-CE forest. The [six-owner projection](retained-why-shared-demand.md) uses
the same five maps and the deliberately larger Q for preparation work. The
current [canonical-response interface](retained-why-canonical-json-input.md)
and logger retain that conservative Q. Their Q=5 for Input does not contradict
the stronger three-entry wire result below.

## Transporting the source ownership theorem

Apply the accepted [fresh parallel launch theorem](retained-solver-launch-profile.md#fresh-parallel-scheduling-owners)
to these current registered roots. Its premises remain explicit: fresh
fully split Per_Check registration, the three immutable prover keys, CE off,
no replay/editor/external scheduling, represented valid containers/keys and
their ownership preserved under the selected callbacks. The
[callback closure](retained-why-callback-demand.md) supplies no new goal,
queue-retry or call-producing callback; later preparation failure may abandon
an owner but cannot add a fourth prover iteration for that goal.

`Gnat_checks.next` removes a goal before scheduling. The parallel path does
not reinsert failures. Each prover-list entry is scheduled once; idle pops
before building, and its receiving failure handlers do not requeue. A call
entry increments the fresh request ID once and offers at most one run line.
An escaping exception abandons the current continuation rather than replaying
its list element. Save callbacks create no run owner. Therefore total run
entries and request-ID increments are at most 3g. The inherited cancellation
argument bounds interrupt entries by 3g separately, using unique live-call
ownership and removal-before-Done; it does not assume kill delivery.

These are the inherited theorem's source/ownership premises, not conclusions
obtained by counting keys. This join does not independently prove general
interrupted controller-table preservation or intact native stream service.
It does not infer wire ownership from the broader Q preparation allowance.
The process-wide e<=2/two-callback/three-save budget is unchanged and is not
renewed here. Keeping Q for other owners remains sound and costs little.

Each current 3g is below its retained N, component by component. Consequently
the [R55 protocol result](retained-adapter-protocol-storage.md) retains its
459 request/history/control slots, 918 response records, 34,884 canonical
payload bytes and 41,536 bytes of J12 old/new ring backing. Positive original
ID widths remain 3/3/2/1/1; malformed concatenated stream bytes still do not
inherit a valid original ID. No total was recomputed with an incompatible
mixture of serial and J12 domains. The shared-server successful connection
boundary, intact native queue/stream and future proxy/adapter refinement
requirements remain separate from this count transport.

## The remaining output boundary

The prospective [adapter protocol](retained-adapter-outcome-interface.md#request-wrapping-process-lifecycle-and-channel)
drains the solver's merged stdout/stderr through a pipe into the finite
recognizer. Its complete decision and the stock adapter completion gate a
separate immutable canonical file. Why3 reads that canonical file, never the
stock backend file. A finite-state byte consumer need not store an entire
solver stream or maintain an unbounded byte-position counter.

This design alone does not bound the stock backend file. The unchanged server
redirects its child stdout/stderr before executing the adapter. Failed exec,
adapter startup/runtime/error output, inherited buffered output and any
optional raw logging still need a complete writer/routing argument. The
[direct launch result](retained-adapter-launch-output.md) supplies only its
explicit server diagnostic branches. In the intended pipe route the solver
does not write directly to the backend file, provided the future adapter's
descriptor replacement/closure is established before solver exec. That
refinement and the remaining backend writers cannot be inferred merely from
the 76-byte canonical row or 64-byte control frame.

Thus neither the 459 count nor the current count transport supplies a numeric
raw-backend-file q. That residual concerns the actual selected writer route;
the old stock-solver full-file pipeline and the prospective pipe/canonical
pipeline must not be treated as identical. No output is silently discarded,
no defect is reclassified and no additional trusted capacity premise is added.
Complete FileTags/parser/startup/current-grammar and whole-rule obligations
remain in #119; production #88–#94 remains unstarted.
