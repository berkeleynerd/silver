# Retained exit initial-value review

2026-10-20 UTC; #119 / #153 Round 38. **Accepted for the stated initial-value
and named-log availability scope.** No material finding remains open. This
does not establish complete formatter, exit, save or whole-pipeline capacity.

## Inputs and review conditions

Exact author commit: `b4c50e2da9a5492316b11711e4ee80a2a01156cf`.
The reviewer inspected the [argument](../research/retained-why-exit-initial-values.md)
and the [packet](../evidence/retained-why-exit-initial-values-20261020/README.md)'s
`check.py`, `result.json`, `README.md` and `round.json` at that commit.
The isolated review branch starts at that commit and owns only this report.
The lead owns integration, issue state, publication and broader completion.

Selected reviewer setting: **GPT-6.1 Sol / Extra High**, for directly checkable
retained-state extraction. Runtime confirmation of model/effort and individual
token/cost telemetry were not exposed. The measured verification interval was
14:57:51–14:59:09 UTC, 78 seconds; initial setup and report writing are outside
that interval. Total review wall time was not instrumented. Host inspection
and `scripts/dev.py paths` confirmed Linux x86_64. The live harness reported
no local goal; this review does not complete the parent's broader objective.

The reviewer read AGENTS.md, the Oracle, applicable assurance/trusted-boundary
distinctions and review bookkeeping, plus the inherited initialization and
private-save-formatter boundaries. Oracle-wide automatic discharge and actual
source correspondence remain required; diagnostic retained cases do not prove
them. No Oracle, tool, source pin, production source or admission change is
part of this packet.

The focused checker used the five retained archives `capture-put-line.tar.gz`,
`capture-put.tar.gz`, `capture-first-or-default.tar.gz`,
`capture-is-message.tar.gz` and `capture-input-is-valid.tar.gz`. Their original
capture manifest has SHA256
`4404c4192a4bbfe373196185b6f8a9d7eb0ac16e9e51319e04a9dc0672603d0e`.
Archive and selected-member identities are checked against that manifest;
the two complete named memory-read logs are streamed and hashed per case.
Retained source inputs are:

- `retained-why-session-helper-source-20261019/sources.tar.gz`, SHA256
  `2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749`.
- `retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz`, SHA256
  `04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7`.

## Findings and verification

The focused command
`python3 -B docs/evidence/retained-why-exit-initial-values-20261020/check.py`
ran once and passed, reproducing the saved result for all five cases in
**27.35613082299824 seconds**. This is reviewer evidence; the recorded
26.796356641003513-second initial extraction remains author evidence.
No predecessor checker, target, collector, disassembler, native proof or solver
was executed, and no new process capture was made.

The table projection correctly follows all backing buckets and cell chains,
checks block sizes/tags and recorded link identities, excludes duplicate or
cyclic cells, and reconciles visited cells with the table's entry count. It
decodes OCaml string padding, tuple layout, signed tagged integers and boxed
little-endian binary64 values. Exact float bits remain available independently
of the readable hexadecimal float representation. The first four cases contain
three keys with maximum length 43 bytes; Input_Is_Valid contains the additional
57-byte `gnatwhy3.transformations.counterexamples_dependent_intros` key.
All five tables have 64 backing
slots, seed zero, initial size 64 and counts of one. These are initial
observations, not bounds on later calls, count increments, durations or sums.

A separate source-field extraction agreed with the checker's complete 28-field
order in `stdlib/format.ml:136–189`. Independently decoding each retained
224-byte formatter span reproduced all raw fields and the twelve scalar
interpretations: margins 78/10/68, space/indent 78/0, new-line true, totals/depth
1/1/1, maximum boxes `2^62-1`, and both tag flags false. There are sixteen
distinct immediate pointer targets in every case. Inspection of the interval
scan and its successful full-log pass supports the exact claim that neither
`memory-reads.jsonl` nor `save-state-memory-reads.jsonl` covers their first
bytes. This does not search every artifact or supply stack, queue, Buffer or
closure contents. Matching constructor defaults supplies no history proof.

All six saved source excerpts were separately compared with their archive
members. `gnat_main.ml:266–268` constructs `escape_buffer` and installs its
formatter; `gnat_main.ml:324–327` conditionally replaces it for `GNATWHY3LOG`.
The variable is absent in all five captured environments. `debug.ml:65–71`
wraps the saved newline callback with the saved flush. Thus the Buffer-backed
Debug destination is supported under the inherited source-prefix/runtime
relation. Its identity does not come from Debug's earlier stderr default.
The global Debug, standard stdout/stderr and fresh private save formatters
retain distinct state obligations.

`Debug.Stats.print`'s timing template contains literal `<stats>`, a data `%s`,
`%f`, `%d`, a bare box and flush/newline. It contains no tag/tab/custom-printer
directive. Excluding the separate registered-statistics `%t` branch relies on
the accepted empty-list preservation; this packet does not reprove it or the
once-gate history. The explicit `%f` and box-extension work, future timing
updates, missing formatter graph, global interrupted-state validity, standard
Format hook and terminal `flush_all` obligations are correctly left open.
Every complete-formatter/exit/save result flag remains false.

No author rework is requested. Source/runtime representation and honest
capture provenance remain explicit premises; byte agreement does not establish
universal refinement or future bounds. CLI memory and GitHub were not updated.
