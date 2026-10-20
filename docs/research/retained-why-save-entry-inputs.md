# Retained save-entry inputs and missing state

2026-10-20, [#119](https://github.com/berkeleynerd/silver/issues/119) /
[#153](https://github.com/berkeleynerd/silver/issues/153), Linux x86_64.
The five retained captures supply exact controller/session joins and finite
forest/attempt dimensions. **They do not supply the prover-ID table or the
Gshape/shape/checksum backing state.** Those inputs remain unknown.

The [packet](../evidence/retained-why-save-entry-inputs-20261020/README.md)
checks these new projections against archived bytes and accepted occurrence
certificates. It reuses the accepted
[session-domain](retained-why-fixed-session-domain.md) and
[registration-state](retained-why-fixed-registration-state.md) results without
replaying the observer, binder interpreter or alpha opener. No native, capture,
solver or proof process runs.

| Captured process | Phase | APn visits G | Maximum chain slots D | Chain slots J | A_stats | A_xml | Theory visits / nonempty |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line, PID 3085 | Registration, before scheduling | 65 | 245 | 15,925 | 14 | 14 | 46 / 1 |
| Put, PID 3323 | Registration, before scheduling | 54 | 245 | 13,230 | 12 | 12 | 46 / 1 |
| First_Or_Default, PID 3470 | Registration, before scheduling | 33 | 77 | 2,541 | 10 | 10 | 41 / 1 |
| Is_Message, PID 3568 | Registration, before scheduling | 4 | 55 | 220 | 1 | 1 | 12 / 1 |
| Input_Is_Valid, PID 97103 | Prior first cvc5 inline entry | 5 | 63 | 315 | 4 | 4 | 21 / 1 |

For each attached APn occurrence, D is the accepted task-chain proposition
occurrence count plus one explanation slot; J sums D with forest visit
multiplicity. This is a conservative slot envelope for the selected shape
source, not an observed execution count of `Task.local_decls` or shape creation.
All five forests have one file, one transformation, one nonempty theory and
maximum depth five when the file has depth one. Empty theories are retained in
the fold domain; `save_theory` skips them during XML serialization.

`A_stats` counts every binding in `proofAttempt_table`. `A_xml` sums every
reachable goal occurrence's `proofn_attempts` bindings. Their equality in these
captures is a checked fact, not a source invariant. The first four processes
share one physical prover record across their attempts, establishing P=1 under
the existing valid-layout premise. Input_Is_Valid has two distinct prover
pointers; their absent records leave structural equality unknown, so P<=2.
All bindings and repeated forest visits remain represented in the JSON.

The exact SIGINT closure retains a controller whose first field is the captured
session. The packet joins their raw records, symbol address/load bias, process
argv, environment, input JSON, plan and configuration identities. Every argv
selects `cvc5,z3,altergo`; both retained overlay configurations contain
`[main]` and `magic = 14`. Retained plugin file identities are preserved as
configuration inputs without asserting which plugins executed. The session
directory strings have 19/14/34/28/32 bytes respectively. No absolute-path
property is inferred from the source comment.

For every capture, the raw logs cover **zero bytes of the header or complete
source-layout record payload** at the five roots `session_prover_ids`, global
Gshape, bound-shape table, old-shape table and checksum table. Thus H0, prover
IDs/duplicates, both dictionary cardinalities, `n`, shape list/index maxima and
checksum/string dimensions cannot be extracted. The Shape Buffer and
`Theory.restore_path` globals have no identified retained roots. Most serializer
names, explanations, prover records and file paths also remain unavailable;
the per-object records say exactly which fields are known.

One Input_Is_Valid transformation-name string has a retained header and only
19 of its 24 payload bytes. Its value remains unknown. No terminator, padding,
empty string, initial capacity, empty table or zero counter is invented from
missing bytes. Known empty argument lists come from the immediate list value.

These are stopped-state inputs at explicitly different phases. The packet
does not establish that a later save entry has the captured values, bound
continuing growth, replace missing state with defaults or complete serialization
capacity. Source meanings retain the accepted source-family/runtime/layout
premises; no historical installed-source identity is newly asserted. Oracle,
admission, executable pins and installed tools are unchanged. #119 and #153
remain incomplete.
