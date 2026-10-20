# Retained save-entry input extraction

2026-10-20, #119 / #153. [Research result](../../research/retained-why-save-entry-inputs.md).
This is an offline projection of five existing process captures. Four are at
`camlGnat_checks__iter_2373`, before scheduling/driver preparation; PID 97103 is
the prior first Input_Is_Valid/cvc5 inline capture. Those phases remain separate.

[entry-inputs.json](entry-inputs.json) indexes five case files by hash. Each file
contains the captured controller/session linkage, selected argv and config
identities, table/forest/proof-attempt dimensions, per-object fields and explicit
unknowns. Every hash-bound consumed archive member is named in its case record.
The shared plan/config members are named by the configuration join. Original
archives and historical scratch paths are never modified or required as live
installations.

[check.py](check.py) regenerates only these new derived fields. It checks archive
and member identities, decodes the already accepted raw session projection,
joins its ordered APn domain to the saved occurrence certificate, and scans the
entire retained raw logs for missing-object byte coverage. It does not replay
the session/counter/auxiliary observer or rerun opening, binder, alpha, native,
solver or proof work. [inputs.json](inputs.json) pins the reused evidence and
the local checker/layout excerpts. [source-layout.json](source-layout.json)
copies exact ranges of the existing retained source certificate and is checked
against that archived source; no new source was fetched.

Run a check with a new result path:

```sh
python3 -B docs/evidence/retained-why-save-entry-inputs-20261020/check.py \
  --output /path/to/new/result.json
```

Repeated `--case` flags select a bounded subset. `--write` is the authoring mode
that replaces the selected case projections and rebuilds the index; ordinary
checks only read retained packet files and write the requested result. Cases
execute serially. Per-case authoring checkpoints preserve successful projections
if a later case exposes another layout or coverage boundary.

The table decoder preserves all Hashtbl bindings and lookup order. `A_stats`
counts proof-attempt-table traversal bindings; `A_xml` counts goal-attempt
membership occurrences over the forest. Persistent shape-map cardinalities are
not confused with either count. D/J use saved all-chain proposition occurrences
plus explanation slots as an upper envelope; they do not recompute opened
formulas or claim exact local-declaration traversal counts. The forest depth
convention is file=1, theory=2, root goal=3, transformation=4, subgoal=5.

For each missing block, coverage records distinguish the header and first
payload word. The five missing state roots additionally query their **whole**
known-layout payload ranges (three words for Gshape; four for each Hashtbl
record). All those ranges have zero retained bytes in all five captures. This
is an absence result, not evidence of empty records. Queries for serializer
strings extend to a complete string payload once its header appears; incomplete
payloads remain unknown. Input_Is_Valid's transformation-name header is retained,
but only 19/24 payload bytes are covered. The packet preserves that distinction.

The checker requires a focused extension for a newly covered non-string record
or list root; it cannot silently classify a decodable record as absent. It does
not identify global state from pointer proximity, allocation order, source
initializers or bytes from a different process. Shape Buffer state and restored
identifier paths remain unknown because their roots were not identified by the
accepted observer. Selected argv prover names do not substitute for absent
proof-attempt prover records.

[result.json](result.json) records the full new-field recomputation check and
its actual elapsed time. [round.json](round.json) records authoring, diagnostic
rework and selected settings. This author selected GPT-6.1 Sol, Extra High;
runtime confirmation, total agent elapsed time and token/monetary measurements
are unavailable. The combined independent review is a separate lead-owned step.
No later-entry equivalence, numerical save-capacity closure, issue completion,
current-admission change or source-semantic machine proof is claimed.
