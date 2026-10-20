# Retained save-stack helper closures

Round 37, 2026-10-20, research #119 / #153. This packet closes five actual
helper roots to the existing trusted runtime-service boundary: task selection's
`used_theories`, `used_symbols`, and `local_decls`, and explanation collection's
`collect_expls` and `concat_expls`. It also supplies an **816-byte signal
dispatch shell while save is active**, and exposes the native C/GC bridge's
**4,104-byte transient stack high-water allowance**. Complete save stack remains
unknown: the remaining tool-owned call instances are listed below.

The [packet](../evidence/retained-why-save-stack-helper-closure-20261020/README.md)
checks 74 retained native bodies, 11,350 instruction bytes, against the installed
Linux x86-64 ELF. It retains the complete selected direct/indirect call closure
for each of the five roots, exact body-frame facts, source witnesses, imported
input identities, and per-body multiplicities. There is no target execution,
capture, new disassembly, solver run, or predecessor-checker replay. Source/native
correspondence and ordinary runtime behavior remain the established named
premises; byte equality is not a compiler-refinement proof.

## Task selection: the missing input and complete calls

Let I be the initial identifier-registration count from the accepted
[initial registration bound](retained-why-initial-registration-bound.md), and C
the largest fixed-task chain length from the
[Round 36 stack composition](retained-why-save-stack-composition.md). The logical
task forests correspond to the five fresh entry PIDs. Their clone-map keys,
theory-local symbol keys, and declaration `d_news` keys are initial identifiers.
`ident` is private and immutable; `id_register` is its constructor. Selected
save work creates fresh variable identifiers in local opened terms but does not
insert them into these fixed task/theory/declaration containers. Thus each
initial `Mid`/`Sid` domain contains at most I keys. Filtering, mapping and union
in task selection introduce no new keys, so the same bound holds for their
results, including the `used_symbols` accumulator. This uses the accepted
fixed-task preservation/source-construction premise, not the false inference
that all containers have at most C entries.

`Task.Stdecl` is `Hcpt.MakeSet`, not `Extmap`. The construction invariant of this
immutable Patricia tree gives at most 63 branch levels on a 63-bit OCaml key:
`branching_bit` selects the lowest differing bit, and each descendant branch
tests a strictly higher bit position. `add` either follows that prefix or joins
above the first disagreement; it preserves the invariant. Task clone history
uses these constructors. Save only reads these trees. `exists` therefore has
at most 64 active native frames, including the leaf/empty test; `min_binding`
is a native loop. This argument depends on the ordinarily constructed initial
Hcpt representation, not merely on the OCaml static type or a cardinality
guess about the declaration set.

The selected higher-order routes are explicit in `call-closures.json`:

| Root / operation | Selected callback or descendant |
| --- | --- |
| `used_theories -> task_clone` | Task's fixed clone-field projection |
| `used_theories -> Mid.map_filter` | `used`, then Hcpt choose/min-binding and exists |
| `Hcpt.exists` | its set adapter, then `check_use` |
| `used_symbols -> Mid.map` | `dict`, then an inner `Mid.map` with the captured theory constant |
| `used_symbols -> Mid.fold` | `join`, its returned union closure, and the collision assertion callback |
| `local_decls -> task_fold` | the declaration-list cons callback |
| `local_decls.filter` | Sid choose/min-binding, Mid find, skip, and list reversal |
| Mid key comparison | `OrderedHashed.compare -> MakeTagged.tag -> Ident.tag -> Weakhtbl.tag_hash` |
| Generic application | the selected `apply2`/`apply3` and curry2 adapters for those closures |

Every direct outgoing call/transfer from the 45 selected task bodies is in this
component or the explicit service frontier. Every indirect site has a selected
target set. Closure-factory references are retained and checked. The callback
sets are source-selected under the existing correspondence premise, not inferred
solely from native symbol names. The generic apply functions' larger possible
domains are not silently admitted. Assert/invalid-argument construction and
raising prefixes are included even though valid task inputs exclude their
ordinary structural-failure branches. Runtime raising/GC interiors stay in R.

The native task-selection bound uses these simultaneous per-body counts:

| Body | Own bytes including return/trap | Maximum active instances charged |
| --- | ---: | ---: |
| `Task.filter` | 64 | C+1 |
| `Extmap.map` | 48 | 2(I+1) |
| `Extmap.map_filter` | 48 | I+1 |
| `Extmap.fold` | 32 | I+1 |
| `Extmap.union` | 80 | 2I+1 |
| `Extmap.split` | 64 | 2I+1 |
| `Extmap.join` | 32 | 2I+1 |
| `Extmap.add_min_binding` | 32 | 2I+1 |
| `Extmap.add_max_binding` | 16 | 2I+1 |
| `Extmap.remove_min_binding` | 32 | 2I+1 |
| `Hcpt.exists` recursive body | 32 | 64 |

The second `map` factor is essential: the outer theory-map traversal remains
suspended while `dict` maps a theory-local domain. Likewise `fold` can remain
suspended while its callback executes `union`. Union removes a pivot from one
of the two finite key partitions at each recursive descent. Split/join/minimum
helpers descend strict subtrees; output domains remain within the input union.
Counting each named helper family separately at `2I+1` overcharges their
interleaving without assuming balance or a logarithmic height. No comparator
or callback contribution is hidden in those frame sizes.

The remaining named bodies are each charged once, except that every selected
apply/curry adapter is charged four times. Source call nesting has at most the
outer traversal, an inner traversal/union, and their scalar callback; the
four-copy adapter allowance also covers the partial-application stages. The
exact body list and sizes are in `native-frames.json` and `multiplicities.json`.
This is a sum of measured own frames with justified context multiplicities,
not an invented uniform frame size for unexamined callees.

The `Task.filter` catch may retry a strict suffix after an asynchronous
`Not_found`; it need not perform a single pass. Each simultaneously active
recursive call nevertheless consumes a strict input-list suffix, including
the recursive call inside the 16-byte trap. Retrying can increase work without
increasing this C-depth bound. Pure map exceptions unwind their incomplete
return paths; they do not publish a partially built map and resume inside it.
Signal saves are counted separately with the global r/e budgets.

Summing this complete three-root component gives

```text
T(I,C) = 688*I + 64*C + 3440 bytes,
```

excluding the direct bridge and trusted-service terms below. The three roots
and repeated task selections execute sequentially within one selected save;
their callbacks do not recursively start another selection. T can therefore
be charged once per active save, rather than once per task or declaration.

## Explanation collection and concatenation

Let A be the accepted explanation attribute-union cardinality. It includes
both term attributes and **all proposition identifier attributes**, hence the
goal identifier's attributes. Round 36's term-only A would be insufficient.
The accepted immutable opening transfer adds no attribute outside that union,
so the same A applies when collecting from an opened term.

`collect_expls -> List.fold_left -> match_prefix -> Extset.fold -> Extmap.fold`
is followed by the set adapter, attribute callback, `Strings.remove_prefix`,
and substring construction. The callback's `Not_found` trap is included.
The prefix-list fold and reversal use native loops, so prefix count and label
count do not create stack-depth factors. `concat_expls` selects the fixed
string concatenations and `String.concat`; both `sum_lengths` and
`unsafe_blits` use backedges after their prologues. Prefix character scanning
also loops. The scalar allocation/copy/raise operations reach the explicit
existing service frontier.

The 21-body closure retains every selected adapter and descendant. Only
`Extmap.fold` needs A+1 recursive instances; every other body is charged once,
with four copies of each apply/curry adapter for the list-fold, set adapter,
map-fold and attribute-callback application contexts. The result is

```text
X(A) = 32*A + 768 bytes.
```

`collect_expls` finishes before search descends further, and `concat_expls`
runs after search returns. Their component can therefore be charged once per
active save. This closes those **two roots**, including substring/copy wrappers.
It does not claim to close `goal_expl_task`, `search_attrs`, `t_fold`, or the
binder-construction operations invoked by the enclosing search.

| Case | I | C | A | T bytes | X bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 136,844 | 1,044 | 195 | 94,218,928 | 7,008 |
| Put | 121,505 | 1,044 | 171 | 83,665,696 | 6,240 |
| First_Or_Default | 77,806 | 536 | 193 | 53,568,272 | 6,944 |
| Is_Message | 59,035 | 368 | 42 | 40,643,072 | 2,112 |
| Input_Is_Valid | 60,496 | 434 | 44 | 41,652,464 | 2,176 |

These conservative bounds are not measured high-water values or evidence of
physical stack sufficiency. No raw type-graph extraction, suffix-length stack
factor, or resumed private-hash-table invariant is needed for these five roots.

## Signal dispatch and transient bridge demand

The selected dispatch path adds the following own frames while the nested
save is active; every size includes its incoming return slot:

| Stage | Bytes |
| --- | ---: |
| One pending-action wrapper, with/without root, exn/non-exn | 112 |
| `caml_do_pending_actions_exn` | 16 |
| `caml_process_pending_signals_exn` | 192 |
| `caml_execute_signal_exn` | 320 |
| `caml_callback_exn` | 32 |
| `caml_callback_asm` and shared `caml_start_program+0x18` continuation | 112 |
| `Gnat_main.save_session_and_exit` while save is active | 32 |
| **Dispatch-to-save shell Qs** | **816** |

Exn/non-exn pending wrappers are alternatives; the installed non-exn wrappers
call `do_pending` inline, restore their frames and tail-transfer to the
exception-result handling path. They are not two simultaneously stacked
112-byte wrappers. The installed signal thunk is `Gnat_main.fun_14206`, which
tail-jumps to the handler with no extra reservation; it is not `caml_curry2_1`.
The handler's two-word trap protects only signal setters and is popped before
the save call at `0x52e6fb`.

The callback assembly's 112 bytes are its incoming return (8), six saved
registers (48), local slot (8), shared-continuation slot (8), three runtime
fields (24), and two trap words (16). The shared entry jumps past the
`start_program` register-saving prologue, so that prologue is not charged twice.
Signal-mask/syscall/runtime-service interiors, the service caller below pending
dispatch, and its return-address demand retain R. Setter-before-save and
exit-after-save are separate phases whose tool-owned wrappers still need their
own closure. Qs is not a whole-handler or all-pending-callback bound.

Both `caml_call_gc` and `caml_c_call` briefly subtract `0x1000`, touch memory
at the new stack pointer, and restore those 4 KiB before continuing. A
reserved-frame-only sum would miss this address high-water mark. Including the
incoming return context gives a conservative 4,104-byte allowance. The GC
bridge's later live save area is only 240 bytes (return, thirteen registers,
128 SSE bytes), already dominated by that allowance. The C bridge pops the
incoming return into runtime state and replaces its slot before the probe.

For the projection of bridges **directly called by selected save-owned OCaml
bodies**, charge 4,104 once per active save: a direct crossing suspends that
save until return/unwind; a save-entering callback has a separate r entry.
Service-owned nested crossings stay in R. This does not assign zero demand to
other callback owners or to the handler's setter/exit bridges; those phases
remain separately unjoined. No proof of collector, libc or kernel internals
is attempted.

## Composition and the exact remaining obligation

Replace Round 36's `task_filter` projection with the complete T component and
add X. Let the resulting per-save covered projection be P37. Every generic
body is charged for its stated call instances; seeing its name in one closed
component never covers a different occurrence under a formatter or serializer.
The new covered expression is

```text
P37 = P36 - old_task_filter_projection + T + X
covered stack projection <= r*P37 + e*816 + r*4104
complete save-added stack <= r*P37 + e*816 + r*4104 + U37 + R
process stack            <= A_pre + r*P37 + e*816 + r*4104 + U37 + R
r <= 3, e <= 2 globally.
```

| Case | P37 bytes | Covered expression at r=3, e=2 |
| --- | ---: | ---: |
| Put_Line | 105,410,928 | 316,246,728 |
| Put | 93,144,976 | 279,448,872 |
| First_Or_Default | 56,077,536 | 168,246,552 |
| Is_Message | 41,334,160 | 124,016,424 |
| Input_Is_Valid | 42,411,168 | 127,247,448 |

The global budgets are inherited from the accepted ordinary-ending/signal
protocol and never reset inside a callback. These sums intentionally overcharge
sequential phases and tail transfers. They are upper bounds on the specified
covered projection, not total stack bounds or lower bounds.

U37 is the simultaneous tool-owned demand outside those charged instances.
The remaining source/call joins are:

* Enclosing explanation search (`goal_expl_task`, `search_attrs`, `t_fold`) and
  the fresh-variable, attribute-copy/comparison and mapper callbacks around the
  Round 36 binder recursion. T and X do not close those callers.
* Shape identifier-printer initialization and table/string/name-decoding
  descendants, plus constant conversion. These include the fresh buffer
  formatter in `const_shape` and the `asprintf`/`print_sn` path in `sn_decode`.
* Serializer statistics/prover-table construction, sorting, proof-state
  predicates and printer callbacks, filename/backup operations and remaining
  path-lookup wrapper/getter bridges.
* The full selected formatter core and its scalar/output/application callbacks,
  with separate XML, shape-constant, decoded-name and box-annotation instances.
  An XML accumulator allowance does not cover those other formatter instances.
* Handler setter/exit phases and other selected error/reporting/callback owners
  outside the precisely bounded dispatch-to-save shell.

R remains the existing trusted-service demand for valid requests; it does not
absorb these missing tool-owned functions. A_pre remains preexisting suspended
preparation/scheduler stack, including the separately established preparation
writer demand. Neither R nor A_pre is evaluated here. Consequently the complete
save-added upper bound remains **null**. #155 is not reopened and no physical
capacity, successful-service, faithful-artifact, #153-completion or whole-pipeline
claim is made. Oracle, pins, production and prior evidence are unchanged.

Selected author setting: GPT-6 Astra / Extra High, inherited task selection;
runtime model/effort telemetry is unavailable. Round timing and validation are
recorded in `round.json`; token/cost telemetry is unavailable. Independent
acceptance belongs to the parent's integrated review, not this author check.
