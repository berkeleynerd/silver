# Review: selected save capacity, Round 29

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.

**Accept the conditional component results and the explicit theory-cache
residual. No blocker, medium or material low finding remains in this review's
scope.** Neither complete save capacity nor #119/#153 completion is established.

This independent review covers the four bounded Round 29 packets and their
integration clarification. It does not repeat the whole #119 review or promote
any conditional component to complete save capacity. The Oracle, installed
tools/pins, current admission and draft PR #121 remain unchanged.

## Exact inputs and review scope

The exact final aggregate is
`78320398608b16cff21a199e915913e583e8f8d1`. The isolated review worktree starts at
`ad11aa9773ea3de770fb44648d8a8162f5c8961d`. Packet changes are imported there
for review; only this report is reviewer-authored.

| Packet | Author freeze | Integration freeze |
| --- | --- | --- |
| Serializer inputs | `f1fb2613def431b6dd3c9637304b942a85757872` | `d4411679cf78ae8e6c4d9971487ca93fe68dcab8` |
| Scalar formatting | Lead-authored integration commit | `ad11aa9773ea3de770fb44648d8a8162f5c8961d` |
| Attempt counter | `8cc4934b9017a8bb5a289772bd1a6bfa3bb2a09d` | `8c01143a23f88856ca4bb4fa9652235e6a6036eb` |
| Theory-cache resize | `ea3df756004a01d6ba45b296d7904c6e21ec2e18` | `7d546e05b558e0b5f71a9a4af452b4bad08cd10c` |
| Current-note premise clarification and two dependency identity updates | Lead-authored integration commit | `78320398608b16cff21a199e915913e583e8f8d1` |

Reviewed paths are the research notes
`retained-why-save-serializer-inputs.md`,
`retained-why-save-scalar-format.md`, and
`retained-why-attempt-counter-continuation.md`, and
`retained-why-theory-cache-resize.md`, together with all files in
their corresponding `docs/evidence/*-20261020/` directories. Source excerpts,
retained raw inputs, manifests, native bodies and constants, published GNU
conversion contracts, extraction/checker code and exported interfaces are
included. The final growth/state-join note changes, counter/theory dependency
identities and `retained-why-save-round29-20261020/` integration evidence were
also reviewed. The imported tracked tree matches the exact aggregate.
AGENTS.md, the Oracle and applicable review/reporting rules were read.

Accepted Round 27/28 operational, actual-state, growth, signal and native-prefix
results remain dependencies at their stated premises. Their successful
collector, observer, binder, alpha and formatter analyses were not rerun. The
live goal tool returned no goal in this reviewer context; the parent supplied
the active owner-authorized scope and retains goal/issue/publication ownership.

## Serializer and scalar assessment

The serializer inventory covers the selected XML variable strings, including
file components/format, names, explanation and transformation arguments,
prover identities and result labels. Manual scripts are excluded by the
imported selected route and are absent in every capture. Result diagnostic and
model payloads are not printed by `save_result`. Fixed format/attribute text
and the selected shape-version literal belong to the existing fixed allowance;
shape-file content has its separate owner.

The forest walk preserves repeated visits and skips names of empty theories
exactly where the serializer does. The proof does not identify unique nodes
with output occurrences. Configuration bytes and invocation identities join
the actual source shortcut lookup to CVC5/Z3/altergo; the retained configuration
has no extra shortcut family overriding that mapping. The four-key structural
union costs 74 bytes. Private statistics duplicates and Mint ID collisions
cannot increase the Mprover domain's string charge.

The candidates U = 4,275 / 3,571 / 2,317 / 419 / 384 reproduce exactly.
The required restored-path premise is explicit at
[serializer note:140](../research/retained-why-save-serializer-inputs.md#exact-remaining-restored-path-premise).
Absent weak-table bindings are retained as null, and fallback lengths are not
treated as bounds on later registrations. Existing bindings also need their
continued liveness/preservation or an adequate replacement length bound.
Actual U remains null. This is a documented missing premise, not an extractor
defect or a completed whole-continuation bound.

The scalar proof selects plain typed `%d/%i/%g/%b` formats and constructs
`%.6g` explicitly. Its integer argument handles `-2^62` without an overflowing
OCaml absolute value. The binary64 magnitude/exponent and six-significant-digit
argument bounds exponential form by 13 bytes and fixed form by 12; GNU's
selected special-value contract bounds infinities/NaNs separately. Boolean
literals fit five bytes. Thus conditional d = max(20,13,5) = 20 is sound.

The installed instruction bodies and constants corroborate signed integer
extraction, the native `l` modifier, C-locale selection and the first
128-byte formatting buffer. They are not presented as full binary refinement.
The selected small normal temporaries follow under successful conversion and
allocation. A negative printf result takes the unsigned long-branch test;
it is not mistaken for a short successful result. The actual locale, libc and
service joins remain false, with actual d null. No channel-output, aggregate
Format queue, allocator or error-path capacity follows from these normal
conversion bounds.

## Attempt-counter control assessment

The new source theorem correctly counts increment and publication **events**,
not successful constructors or unique IDs. A constructor's counter increment
precedes per-goal publication; at most one increment can remain unpaired at a
trace prefix because a discarded constructor cannot restart scheduling.
Its own and the graft's `Not_found` handlers cannot catch exceptions raised
inside their fallback bodies. The adaptive-limit catch ends before the graft.
The timeout dispatcher uses an exception pattern around its lookup scrutinee,
not around its Done callback. Done-result scheduling also occurs outside the
`register_result` catch. Initial and result-driven constructor failures reach
termination/ending paths without further constructors.

The contradiction-sensitive distinction at
[counter note:85](../research/retained-why-attempt-counter-continuation.md#the-abandoned-prefix-argument)
was checked against the retained source. `run_idle_handler` is called after
the graft, queue insertion and Scheduled callback. Build/idle catches therefore
cannot receive an exception from that earlier constructor. Their InternalFailure
callbacks may update caches, repeat and return with queued work, but their
selected GNAT interpreter does not schedule or construct attempts. No claim
that all work stops after InternalFailure is needed.

Consequently `I <= M+1 <= K+e+1` is valid under the named source/native and
membership-preservation premises, with one global e <= 2 budget. The fresh
counter join reads session field 1 from each manifest-bound raw record, rather
than transplanting old process counters. Conditional next-ID bounds
209 / 174 / 109 / 13 / 10 follow. The first-overflow argument does not assume
ID uniqueness to obtain its event bound. Native usable bounds remain null
until the continuation/counter/publication contracts are attached; no bound
on all interrupted scheduler entries is claimed.

## Theory-cache assessment and integration clarification

The first-publication argument at `retained-why-theory-cache-resize.md:66–102`
is sound at its explicit premises. Before publication, disjoint correctly
indexed chains support `N <= Th+2`. Prepublication allocation failure can leave
size above 33, so the proof correctly avoids assuming every first published
resize starts at 33. Splitting an original bucket into b and b+16 keeps each
new root within that original chain. Saved-next traversal and forward-only
tail writes preserve acyclicity; two roots per original bucket give at most
2N visits even when tails are shared. A completed uninterrupted first resize
restores the indexing/key-preservation invariant.

The save-only suffix at `retained-why-theory-cache-resize.md:122–137` is a
conditional lemma. Its three additions are charged to at most three save
entries from the same global event budget, not a renewed budget. The serializer
skips empty theories, and the separate `file_proved` fallback at retained
`session_itp.ml:759–764` only adds a file-status entry; it does not traverse
the theory list. Thus the stated suffix bounds, size 51/51/46 and visits
99/99/89, follow if subsequent operations really are restricted to saves.
The packet does not claim that condition for every receiving route.

The model follows mutable cell identity and saves `next` before relinking,
matching the retained source. Its 198 first-resize states exercise three
illustrative orders; the universal argument above is not inferred from that
enumeration. Its actual-tag second-resize cycle witnesses include an explicitly
hypothetical later file-query pass. They refute the proposed generic extension
from finite interrupted chains to safe later rehash, without claiming selected
control reachability or an observed native defect. Both the model and exported
interface retain that distinction.

The unresolved receiving lane is stated precisely at
`retained-why-theory-cache-resize.md:162–184`: surviving InternalFailure control
may retain queued callbacks; a status/remaining-event invariant must exclude
later empty-theory repair traversals, or a new proof must cover them and all
later resizes. This agrees with the counter packet's narrower no-constructor
argument. The local observation that an identical callback normally sees a
committed status is not promoted to a whole-continuation invariant.

During integration the theory author identified loose inherited wording about
Th+2, independently confirmed here. At the initial target,
`retained-why-save-state-join.md:89–97` stated whole-continuation additions too
broadly; the existing numeric/native interfaces already retained their
conditional/false-contract flags. Final commit `7832039860` qualifies this at
the current note's lines 89–105 and adds the explicit dependency at
`retained-why-save-attempt-growth.md:270–278`. Lost keys may be reinserted after
partial rehash publication, so finite key cardinality cannot establish the
missing preservation contract. This premise clarification is accepted as fixed
before the final review target; it does not establish a wrong numeric certificate
or require a native defect claim. The two refreshed note identities were checked
with the semantic changes, and the affected focused checks pass. No source
excerpt, numeric result or historical native evidence was changed.

## Remaining obligations and disposition

Actual U still needs restored-path continuation bounds; actual d needs the
named locale/service joins; the attempt-counter native application still needs
its continuation/publication/counter contracts. Theory-cache continuation past
an abandoned first resize remains unresolved as described above. These are
documented missing premises, not undisclosed defects in the four packets.

Format queues/counters, aggregate allocation, hash/string/channel/file-offset
and error/exit effects, whole-process composition and the wider driver/solver/
report/fixed-library/current-grammar obligations remain separate. This review
does not turn examples into universal assurance, change source/configuration
membership, renew the signal budget per entry, or complete #119/#153.

## Focused verification

| Reviewer execution | Result | Available elapsed evidence |
| --- | --- | --- |
| Serializer extractor and four boundary tests | Exact retained result; all pass | 2.517 s shell call; tests report 0.008 s |
| Scalar checker | 18 source excerpts, 17 bodies/3,408 bytes, three constants, arithmetic and missing-premise checks pass | 0.540 s checker measurement |
| Counter checker before integration clarification | Five fresh projections, 19 source excerpts, 126 abstract prefix states and boundary checks pass | 4.848 s shell call |
| Counter checker at final aggregate | Same results; refreshed growth-note identity passes | 4.810 s shell call |
| Theory-cache checker at final aggregate | Five projections, 198 first-resize states, three hypothetical second-resize witnesses reproduce | 2.782 s shell call |

Only the counter check was repeated: its pinned dependency changed in the final
integration clarification. The unchanged serializer and scalar successes were
retained. Parent integration results are also retained in the aggregate packet;
they are separate executions from the reviewer checks above.

These are focused offline checks. Reading installed ELF bytes does not execute
the target. No target/capture/solver/GNATprove/Lean/full-suite/disassembler run,
network request, GitHub write, old successful checker replay or CLI-memory
update was performed by this reviewer.

Reviewer setting selected: GPT-6 Astra / Extra High. Runtime confirmation and
per-review token/monetary-cost attribution are unavailable. Review began at
09:57:08 UTC. All four freezes, the final integration clarification, focused
verification and report verification were complete by 10:06:20 UTC: 9 minutes
12 seconds wall time, including coordination and input waiting, not active
compute time. The report commit follows that checkpoint. The intended result was one
bounded independent assessment; the achieved result is acceptance at conditional
scope with the theory continuation and other named joins still open. No
reviewer-discovered implementation rework or additional agent fan-out occurred.
