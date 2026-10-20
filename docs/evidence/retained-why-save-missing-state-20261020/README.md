# Missing save-state capture preparation

2026-10-20, Linux x86_64; directly authorized #119 / #153 research lane.
Base `22c5d9274a`. Runnable collector, installer and layout inputs are frozen at
`f3baf9cdfa068496a4034c16f77e9fbcd756420a`. **This preparation lane runs no
native target, capture, compiler, solver, proof or predecessor interpreter.**
The lead owns plans, resource reservations, actual captures and their package.

The accepted [entry-input packet](../retained-why-save-entry-inputs-20261020/README.md)
proved that the old raw logs cover none of five required backing records.
This is a missing-input capture, not a rerun of a successful capacity check.
The extension keeps the old endpoints and capture procedure, reads through the
accepted durable reader, and appends complete blocks to `session-blocks.jsonl`.
It additionally flushes direct extension reads to `save-state-memory-reads.jsonl`.
It neither continues the inferior nor invokes any inferior function.

The four registration cases retain `camlGnat_checks__iter_2373` as the stop;
Input_Is_Valid retains its first cvc5 inline-entry stop. Their phases remain
separate. The lead's fresh roots are `tmp/wse-20261020` and
`tmp/why-session-save-capture-ready-20261020`; these have the same path lengths
as their historical roots. Equal path lengths do not establish input or graph
correspondence. Historical roots and artifacts are preserved.

## Installation and lead-owned execution

After preparing each fresh, unrun relocated harness, the lead runs:

```sh
python3 -B docs/evidence/retained-why-save-missing-state-20261020/install.py \
  --root /home/canto/src/github.com/berkeleynerd/silver/tmp/wse-20261020
python3 -B docs/evidence/retained-why-save-missing-state-20261020/install.py \
  --root /home/canto/src/github.com/berkeleynerd/silver/tmp/why-session-save-capture-ready-20261020
```

The installer changes only the appropriate observer integration file in that
fresh root and copies `missing_state.py`. Four-case `probe.py` injects after
`session.capture_helpers()` and before its close; Input_Is_Valid injects into
`gdb_adapter.py` after `_session_capture.capture_helpers()`. It writes
`plan-additions.json` and deliberately leaves `plan.json` to the lead. Merge its
symbols into `session_observer.symbols` and its two identities into
`file_identities`, retaining all existing input/driver/runtime/frame/guard pins.
The copied collector's identity must match the frozen version before execution.

The underlying native commands remain `python3 <fresh-root>/run.py`; the lead
wraps them with the existing managed runner and reserves one worker. No new
scheduling, driver, GC, printer or save-stop policy is introduced here. Source
identities, process argv/environment and exact stop identities must be retained
with the actual results. A prepared script or saved plan is not a native result.

## Output schema and roots

`save-missing-state.json` has `schema=1`, the explicit `phase`, `session`,
`shape_version`, `has_shapes`, `layout_checks`, and named `sections`. Each section
has `known` and `value`; a failure keeps `value=null` plus a diagnostic. `complete`
means that these selected decoders returned. `capacity_established` is always
false. No missing input becomes an empty object, zero count or guessed capacity.

| Section | Retained fields |
| --- | --- |
| `prover_ids` | Full table header, scalar size/seed/initial size, bucket backing and heads, cells in bucket order, duplicate binding visits, complete prover strings and signed IDs |
| `gshape` | Full three-field record, signed n, both complete persistent maps, keys/values, stored heights, exact strings, cardinalities and finite ordered balanced-tree checks |
| `bound_shapes` | Full mutable table and each signed index list, list length and absolute index maximum |
| `old_shapes`, `checksums` | Full mutable tables and complete string bytes |
| `shape_buffer` | Termcode module root at `+0x1c0`, Buffer record, position/capacity, complete current and initial backing bytes |
| `proof_attempts` | Full attempt-table header/backing/cells and actual binding visits |
| `file_state`, `theory_state`, `transformation_state`, `proof_node_state` | Session fields 13–16, full table dimensions and chains; theory keys retain identifier fields |
| `serializer` | Session directory, file paths/formats, all theory/goal identifier names, explanations, per-goal attempt tables, transformation names/arguments/subtasks, attempt prover/script/limit/status payloads |
| `restore_paths` | Theory export at `+0x100`, checked closure/code/captured table, complete ephemeron table headers/cells/key/data slots, demanded path triples and fallback strings |

Tables preserve bucket order and duplicate bindings. They reject cycles and
cells shared between buckets, retain header size separately from actual binding
visits, and expose `size_equals_binding_visits`. Size disagreement is retained;
it is not repaired or declared a valid entry invariant. Integer-key placement
uses the already accepted identity-hash contract. Prover/identifier buckets do
not borrow that integer rule. Persistent map decoding checks ordering, heights
and balance but proves no inverse relation between the two maps.

All strings retain byte length, hex and SHA-256 without requiring UTF-8.
Attempt scalar/status payloads are retained as raw ordinary graphs; no guessed
prover-result record is used. The private capture limits are diagnostic abort
limits, not admission or tool capacity bounds. The extension retains no prefix
proof merely because a representation was readable at this one stop.

[source-layout.json](source-layout.json) binds the selected pinned ELF identity,
six symbols, exact source-archive member identities/excerpts and the Theory
initialization witness. The live inherited symbol loop checks load bias and code
prefixes. The collector additionally checks the Theory entry sequence that
creates `restore_path_4035`, captures `id_to_path` in closure field 2 and stores
the closure in export `+0x100`. The Termcode `check_2028` bytes load the Buffer
root at `+0x1c0` and its position at `+8`. No installed-source identity is added
to the accepted source-family/runtime/layout premises.

The raw stopped ephemeron lookup is a source/layout projection. Both fallback
identifier strings and candidate qualified-path strings remain available. A
continuation bound must take their maximum or establish the applicable
liveness, lookup and preservation premises; `serializer_name_bytes` alone is
not a future-entry guarantee. No captured mutable backing is relabeled as the
backing of an old PID.

## Smallest new-input join and offline decode

First decode the fresh extension using accumulated complete blocks and its
small direct-read log. This reproduces its typed output and attempt graph files
without rerunning the old observer, binder or alpha opener:

```sh
python3 -B docs/evidence/retained-why-save-missing-state-20261020/replay_missing.py \
  --capture /path/to/new/case/capture --output /path/to/replay.json
```

Then compare a fresh captured logical input to the accepted old case, preserving
both sets of input identities and the phase difference:

```sh
python3 -B docs/evidence/retained-why-save-missing-state-20261020/correspondence.py \
  --old /path/to/accepted/case/capture --new /path/to/new/case/capture \
  --case is_message --output /path/to/correspondence.json
```

The checker binds old consumed files and the saved certificate to the accepted
archive manifest and analysis identity; it validates the new result/guard facts
and normalized argv/environment/input/configuration. It compares the complete
forest event topology with multiplicity. Each attached visit joins an ordered
task-chain kind sequence and its logical declarations. A bijection then compares
all reachable declaration block tags, sizes, fields, sharing, signed immediates
and opaque data bytes. Heap addresses are renamed. The first payload word of
a recognized Zarith custom block may also relocate, under the precise native
witness below; every following byte remains exact. Unknown custom operations,
other differing opaque bytes and runtime blocks fail closed. This strict test may reject semantically equal
inputs. Such rejection leaves the old count unjoined; it does not authorize an
invented weaker normalization or an assertion of nondeterminism.

The output records old/new PIDs, old/new phases, task/formula pointer joins,
input identities and unchanged saved occurrence charges. It transfers the
accepted conditional forest charge only if every check succeeds. It opens no
terms and computes no new binder/alpha count. The old certificate's extra tasks
outside the traversed forest are not silently relabeled. Fresh mutable tables
are independent new inputs, and no equality of their old/new pointers is used.
Later-attempt growth, the once-per-continuation save count, mutable prefix
contracts and formatter/native capacities remain with their source owners.

## Recognized native custom operations relocation

The first actual Put_Line correspondence attempt rejected a tag-255 block
whose first word differed; [initial-custom-mismatch.json](initial-custom-mismatch.json)
preserves both inspected raw records and their load biases. The post-operations
bytes were equal. Both operations pointers identify the pinned ELF symbol
`ml_z_custom_ops` at `0xfa9e20` after subtracting the independently checked
process load bias. This was an input-correspondence gap, not evidence of changed
integer data.

`custom_ops.py` admits precisely that operations relocation. It rechecks the
pinned binary identity against both plans, the symbol's 64-byte operations table,
its `_z` identifier and callback symbol addresses, and the exact `ml_z_init`
instructions that take the table address and call
`caml_register_custom_operations`. It binds retained Zarith 1.14 `caml_z.c`
identity and the accepted runtime `Custom_tag`/`Data_custom_val` layout excerpt.
The sign/used-limb header is checked; sign, used limbs, all limb bytes and unused
payload bytes remain exact. Unknown custom operation words fail even when equal.
This retains the accepted source-family/native relation and adds no historical
installed-source claim. The lead owns the successful actual correspondence
record; this lane does not rerun it to populate another file.

## Validation and round record

Twelve offline fixtures passed before the replay source-pin tightening; the
focused standalone replay fixture passed after that change. The final targeted
graph suite passed six fixtures after the recognized custom-operations join. They cover full
selected decode, duplicate bindings and signed indices, malformed Buffer state,
unreadable/partial objects, bad map heights, scalar-size disagreement, cycles
and cross-bucket cell sharing, pointer renaming, changed scalars/sharing/opaque
bytes, runtime-block rejection and standalone extension replay.

[retained-check.json](retained-check.json) additionally records the new decoder
on archived-hash-checked Is_Message bytes: the directory and attempt-table
dimensions agree with the accepted projection, absent prover backing remains
unknown, and a synthetic pointer renaming of the real 14,087-block logical
graph passes. This is a decoder fixture, not a second native process or a fresh
process-correspondence result. No expensive successful analysis is repeated.

Selected worker: GPT-6.1 Sol / Extra High (lead-assigned); independent runtime
confirmation and token/cost measurements are unavailable. Native execution
count for this lane is zero. [round.json](round.json) distinguishes preparation
from later root-owned execution. The lead owns integration, issue status,
durable session memory and the single later combined review. #119/#153 remain
incomplete; Oracle, admission, source/tool pins and compiler code are unchanged.
