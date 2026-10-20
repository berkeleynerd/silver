# Selected save structural allocation and its shape-builder residual

2026-10-20 UTC, Round 36, research #119 / #153, Linux x86_64.
The five retained continuations now have explicit cumulative direct-request
charges for save's global shape maps and strings, prover maps, private
statistics/frequency/ID-search tables, saved lists, list sorts, preliminary
forest traversal, and selected table/getter objects. The six precisely bounded
shape-builder root families below remain a separate allocation residual.
**Complete non-formatter save allocation is therefore not established.**

The [packet](../evidence/retained-why-save-structural-allocation-20261020/README.md)
retains the arithmetic, source witnesses and 88 native bodies/18,744 bytes.
It reuses the accepted [operational transfer](retained-why-save-operational-bounds.md),
[five-process state join](retained-why-save-state-join.md),
[table attachment](retained-why-save-table-contract-join.md),
[formatter allocation](retained-why-save-format-allocation.md),
[publication bound](retained-why-publication-composition.md) and
[path lookup](retained-why-path-lookup-capacity.md), without replaying their
checkers. The source/native relation remains the existing selected behavior
relation; matching bytes are not a recovered build history or binary refinement
proof. Source revisions, executable identity and input hashes are in the packet.

## Global budget and object ownership

Use one whole-post-cut budget `r<=3` save entries and `e<=2` escaping signal-save
exceptions. A nested save, ordinary ending and a helper entry do not renew either
budget. Each selected source occurrence is charged before its construction, so
a prefix abandoned before publication retains its charge. No-return-to-an-
interrupted-private-mutation and the accepted shared-table prefix contracts are
essential. This does not assume normal completion of every save: a membership
lookup can still fail before the global attempt record is installed.

`A` and `Ax` are attempt binding visits in statistics and XML respectively;
`F,Th,G,T` are actual forest occurrence bounds. `P` bounds prover-map keys,
`B` private statistics-table binding visits, and `V` shared prover-ID/occurs
visits. The accepted values are `P=4/4/4/4/5`, `B=6/6/6/6/7`, and the same
values for V. The two exception allowances are global even when a per-save
maximum is multiplied by r: that multiplication relaxes a global bound and
does not assert that all saves independently incur two new exceptions.

Every OCaml byte charge includes its eight-byte header. Map nodes have five
fields (48 bytes); cons cells/pairs have two (24); mutable hash bucket cells
have three (32); hash-table records have four (40). A pointer array of n entries
occupies `8(n+1)` bytes. A string/bytes object of length n occupies
`S(n)=8*(1+floor((n+8)/8))`. No new copy is charged merely because another
field points at an existing string, tuple, term or path list.

The formatter packet owns its caller-local printer closures, argument blocks,
scalars, Format containers, annotation and asprintf buffers, pathname and channel
objects, and identifier-concat destinations. This packet owns the previously
excluded 48-byte goal-attempt and transformation pair/cons callbacks, 40-byte
prover tuple callback, the preliminary save_session's 80 bytes, and the helper
objects described below. `Sysutil.decompose_path` is identity on an existing
component list; it introduces no split/copy allocation. Existing input objects
are entry storage, not new requests in either subtotal.

## Shape dictionaries, lists and shared Buffer

Take the accepted `C=3J` insertion-call bound and `D=max(H,I)` global map
cardinality bound. The existing proof gives at most `8C(D+1)` Extmap nodes;
the native create/add/balance bodies confirm 48 bytes per node. This includes
unpublished persistent-tree construction and earlier roots retained by suspended
frames. These maps remain individually valid even when their inverse relation
or saved-index interpretation fails. There are at most C saved-shape cons
requests, hence `24C` bytes.

Let `X=3L` be the accepted shared Shape-buffer extent after its first clear.
There are at most C `Buffer.contents` calls, conservatively including the
explanation slot that normally copies nothing, so `C*S(X)` bounds destinations.
Captured backing capacity is 1088 in all cases. Clear does not shrink it. Let
`1088*2^k` be the least doubling at least X. Charge every possible larger
backing up to that capacity, even a capacity skipped by a large append, and
multiply this sum by r. Capacity publication is monotone; an abandoned resize
can repeat a requested capacity in another save, but one save's discarded frame
cannot return and repeat it. Thus r copies of every capacity cover unpublished
backings without assuming an atomic resize. Buffer position/append ranges and
no-return-to-interrupted-append remain the accepted shape-transfer premises.

`t_bound_shape_task` itself requests 120 bytes per G: current_shape's reference
16, alpha counter/map references 32, and do_d's closure 72. Its 24-byte invalid-
version assertion branch is unreachable on the selected SV6 route. The printer,
task-selection and term-shape callees remain in the residual below. do_d adds
no own blocks. `get_shape` constructs one 16-byte Bound_shape wrapper per G;
dictionary output creates one 40-byte closure per save. The dictionary strings
are shared between the two maps and do not acquire a second destination copy.

## Statistics, frequency tables and maps

The actual frequency structures are mutable Hashtbl tables, not persistent
maps. `get_used_provers_with_stats` creates one private prover table. Each
find-miss handler attempts three frequency-table creations and one 32-byte
triple. A bound on completed prover bindings alone would miss a final abandoned
constructor. We therefore use

```
U = min(A, P+e+1)
```

creation attempts per statistics helper. At most P ordinary previously absent
keys and e signal-origin misses can complete extra bindings. A constructor or
add that escapes the handler abandons this private owner; at most one additional
handler prefix can precede that abandonment. There is no catch that retries its
mutation on the same private table. The source iteration also supplies A.
Numerically U is 7/7/7/7/8. The statistics caller closure costs 40 bytes;
triples cost `32U`, and prover-table bucket requests at most `32U`.

There are at most `3A` frequency replace calls, including missing-key calls
that allocate 32-byte buckets. Start each frequency table at 16 buckets and
double only when its scalar size exceeds twice capacity. The reached capacity
sequences end at 128/128/64/16/16. For each of at most 3U tables, charge its
40-byte record, initial array, and for every possible doubled capacity c:

```
2*8(c+1) + 96 + 32A
```

This covers the new array, tail array, 40-byte partially applied index closure,
56-byte insertion closure and even A copied bucket cells. In-place private
redistribution normally requests no copied cells; keeping the copy allowance
does not rely on that optimization. A failed resize abandons the owner, so it
cannot repeatedly request the same capacity. Existing table attachment covers
finite failed first prefixes; the client-entry A bound is not misapplied to
arbitrarily reused malformed private roots.

Each of at most B `get_prover_to_save` calls may create a fresh occurs table
(40-byte record, 136-byte array) and at most V 32-byte bindings. These tables
and the private prover table do not resize. The helper's two 40-byte local
groups and even its unreachable 24-byte assertion allocation are charged.
Each of the three frequency folds can construct at most A 24-byte winning
pairs per prover binding, giving `72AB` bytes per save. Initial `(0.,0)` and
`(0,0)` pairs are static in the retained native body; limit floats already
belong to attempt records and are not reboxed by the statistics callback.

Mprover receives at most B adds, and the final Mint map at most P adds, each
on a map with at most P keys. The conservative four-nodes-per-search-level
rule gives `48*4*(B+P)*(P+1)` bytes per save. Final Mint payload tuples add
`40P`. Shared prover-ID insertion requests are charged per helper call, not
just per successfully published binding, so abandoned add allocations remain
covered. No ID uniqueness claim is required.

Optional random seeding is included without guessing the live randomized flag.
There are at most `1+3U+B` private creates per save. A conservative **16,384
bytes per create** covers the whole selected direct random-initialization route:
at most a 16-entry seed array (136), a 55-entry state array (448), state record
(24), a fallback one-entry seed (16), the lazy helper's own groups (16+32), and
110 digest rounds. Each round needs at most a 32-byte integer string, a 48-byte
concatenation of at most 36 bytes, and a 32-byte 16-byte MD5 result. Their sum
is 12,992 bytes. `Random.State.bits` allocates no result object. Paying this
allowance at every create also covers a caught lazy failure/exception-memo
closure; successful forcing is not required. Native entropy calls, error
services and collector internals retain their existing service contracts.

## Traversal, getters and sorting

The native preliminary traversal charge per save is

```
208 + 104F + 72Th + 72T + 152G + 16Ax.
```

The 208 includes save_session's two 40-byte closures, its initial 40-byte table
fold helper, fold_all_session's 48-byte closure and its 40-byte fold helper.
Each file has two extra 16-byte AFile wrappers plus its 72-byte traversal
objects; theory and transformation traversals each use 72. Each proof node
uses 112 plus its Hashtbl.fold's 40, and each attempt callback allocates a
16-byte APa wrapper. Existing immutable forest lists are traversed in place.

For serialization/statistics, each Hashtbl.iter owns one 32-byte closure and
each fold one 40-byte closure. Native fold keeps its accumulator in a register/
stack slot, not another heap reference. The complete additional table-helper
allowance is `104+152B+40G` per save: statistics iteration, private prover fold,
three frequency folds per B, shared-ID iteration per B, goal-attempt folds,
and the final file iteration. Persistent map iter/fold allocate no own blocks.

Bound-shape, prover-ID, file-status and theory-status insert requests cost at
most `32*(G+B+F+Th)` per save. These counts cover allocations before publication.
Only the three first theory-cache cases can reach their accepted resize path.
For each theory getter we conservatively allow one complete resize request:
two arrays at its accepted capacity, 96 bytes of closures, and 32 bytes per
accepted binding visit. This overcounts the accepted one-first-resize control;
it does not assume reinsertion repairs a partially rehashed table. Other save
getters either return existing values/static exceptions or allocate the
Bound_shape wrapper already charged.

Put `n=Ax+T`. Input pair/cons construction costs `48n` per save. The accepted
loose merge-list bound is `4n(n+1)` cons cells. It is not the whole sort charge:
the native stable_sort factory requests **168 bytes on each of 2G calls**, even
for length zero/one, and recursive sort/rev_sort calls return 24-byte pairs.
Their finite splitting trees have at most 2n nodes in total, so add `48n` bytes
for pairs. Each merge consumes list input; failure abandons its private sort
without retry. Comparators select represented integer IDs or immutable strings.

Finally, restored-path lookup requests at most two 16-byte Some blocks per
matching-hash cell. The accepted publication composition supplies W and the
accepted lookup induction gives bucket length `min(2^59,7+W)`. With the retained
identifier occurrence counts `N=66/55/34/5/6`, charge

```
32*r*N*min(2^59,7+W).
```

This joins the getter allocation interface to the new publication result; it
does not charge all writer clean/copy objects to save. Those writes occur in
their separate preparation owner. Lookup marking/pending/GC is a runtime
service descendant, not another application-level Some object.

## Exact remaining shape-builder interface

After pruning the accounted dictionary, saved-list, top-level local-ref/closure
and shared Buffer objects, the uncharged shape-production allocation is exactly
the dynamic application-object descendants of these six source root families:

| Root family | Calls across the whole interval, upper bound |
| --- | ---: |
| `Termcode.goal_expl_task` | `3G` |
| `Ident.create_ident_printer []` | `3G` |
| `Task.used_theories` | `3G` |
| `Task.used_symbols` | `3G` |
| `Task.local_decls` | `3G` |
| `Shape.t_shape` | `3*(J-G)` |

The first five maxima are 195/162/99/12/15 each. The last is
47,580/39,528/7,524/648/930. These calls are made from goal_expl_task's save
callback and `t_bound_shape_task:601–628`; `Task.used_theories` itself invokes
Extmap.map_filter and cannot be treated as a nonallocating selector. A pending
nested save is a separately charged save root, not a descendant counted twice.
Normal primitive/runtime internals retain the same service boundary as the
other subtotals.

This finite, source-indexed root family is **not yet a numerical byte bound**.
It includes term substitutions and binder-opening administrative maps, type
and attribute traversal/copies, fresh symbol records and registration,
printer tables and alpha/name maps, task-selection map/list construction,
explanation strings/attribute lists, and numeric/identifier shape rendering.
The existing B/J/L and fully opened formula counts do not by themselves close
these objects: `bv_subst_unsafe` maps stored substitutions and traverses
`bv_vars`, including unused administrative entries absent from an opened
formula occurrence count. An initial raw administrative census also needs a
dynamic growth/preservation transfer before it can bound later opening.
The parallel stack lane owns that shared retained-input investigation; this
packet performs no duplicate raw extraction. It exports the six root maxima
and leaves `shape_builder_residual_requested_bytes=null`.

## Results, representation guards and limits

| Case | Accounted structural direct OCaml bytes, interval upper bound |
| --- | ---: |
| Put_Line | 459,034,838,339,780,136 |
| Put | 295,292,297,128,074,168 |
| First_Or_Default | 4,021,948,642,299,912 |
| Is_Message | 11,951,316,097,896 |
| Input_Is_Valid | 27,667,599,993,312 |

These separate-process bounds are dominated by deliberately loose `C*S(3L)`
shape-copy allowances. They are neither observed allocations nor an estimate
of resident memory. Adding the accepted formatter subtotal is safe for the
disjoint objects and is recorded in result.json, but the sum still excludes
the shape-builder residual and source-owned error/exit/service descendants.

All charged individual strings/backings fit `(2^57)-9`, array/header extents
fit their 54-bit native representation, and map heights, counters, list lengths,
Buffer additions/doublings and array-size conversions stay represented. The
largest charged new backing is 18,691,697,672,192 bytes. A valid size request
does not establish that such physical memory exists or that allocation returns.
Cumulative totals are mathematical accounting values, not a machine counter
maintained by the program. Counting all requested caller objects with no
collection credit also bounds the simultaneously live *new objects of these
owners*, excluding pre-existing objects, GC copies/metadata/reservations and
other owners. No collector-internals proof is added to the trust boundary.

The unasserted interface exports null usable totals. Supplying all named existing
premises and passing the guards enables only this scoped subtotal. Whole native
stack, source-owned failed-service continuations, physical exhaustion, complete
non-formatter allocation, complete save and pipeline flags remain false.

Selected author setting: GPT-6 Astra / Extra High; runtime model/effort confirmation
and individual token/cost telemetry unavailable. Base `aeafcd179791afc238344cc305e17e8ebb91bfc8`.
The new freeze/check passed in 2.0144 seconds; independent review is parent-owned.
No predecessor checker, target, capture, disassembler, solver/proof run, source
fetch, Oracle/tool/pin/admission or production change was performed. CLI memory
was not updated. The parent owns issue state, integration and durable memory.
