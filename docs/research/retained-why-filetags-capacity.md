# FileTags counter and strong-table capacity

2026-10-23 UTC, #119 / #153, R71; author base
`2b9e9f780f9e747d0610663ead3f1e90a4a60c08`. The
[packet](../evidence/retained-why-filetags-capacity-20261023/README.md)
supplies a source/cut attachment and representation bounds for the two private
`Loc.FileTags` tables in each retained Linux x86_64 client. It reuses the
accepted source/native relation and retained inputs without executing the
target or a predecessor checker. Whole-process capacity and admission are
not conclusions of this component.

## The result and its exact resource premise

Let D0 be the **exact completed initial filename domain**, N0 its cardinality,
and B0 the common backing extent of the two tables at the accepted combined
registration cut. These are mathematical state variables, not newly measured
fields. The accepted startup bound and the argument below give

```
1 <= N0 <= 945214
16 <= B0 <= 524288, B0 a power of two, N0 <= 2*B0.
```

All later offered filenames belong to D0. This does **not** imply zero later
insertions: an escaping save-origin `Not_found` can cause a false miss, and a
subsequent interrupted resize can lose reachable associations. With the one
global e<=2 budget, the following bounds hold at every continuing prefix:

| Quantity, per process | Symbolic bound | Common bound for all five cases |
| --- | ---: | ---: |
| Suffix entries to the insertion handler / Hstr.add | N0+2 | 945,216 |
| Suffix Hint.add entries and counter increments | N0+2 | 945,216 |
| Counter, either size, or physical bucket cells allocated since table creation, per table | 2*N0+2 | 1,890,430 |
| Either current/allocated backing or rehash-tail extent | 4*B0 | 2,097,152 |
| Threshold shift or attempted doubling operand/result | 8*B0 | 4,194,304 |
| One reachable lookup chain, in distinct physical cells | 2*N0+2 | 1,890,430 |

The counter/size bounds concern nonnegative machine scalars; the cell bound
does not identify size with reachable occupancy. Nor does it identify physical
cells with summed occurrences across array roots. Backing allocation is
`8*(extent+1)` bytes including its header, at most 16,777,224 bytes for one
array. All arithmetic guards fit max_int=2^62-1 and array extent <2^54-1.

This is a positive capacity theorem under the inherited **sufficient physical
memory/stack and faithful native-service premise**, as stated in
[trusted-boundary.md](../trusted-boundary.md) and the guarded-operation
discussion in [state attachment](retained-why-parallel-state-attachment.md).
Valid string/int hash/equality, valid array accesses and these bounded
allocations have no other ordinary semantic failure in the FileTags mutation
body. The proof derives their representation guards; it does not derive
physical resource availability. Ordinary resource failures retain their
existing failure/termination outcomes and are **not charged to e**. Arbitrary
resumed allocation/stack failures inside published mutations are outside this
positive theorem. This is the inherited resource condition, not a new RAM
quota, allocator audit, launch policy or restriction on Silver membership.

## Private representation and initial-state attachment

`loc.ml:42–65` owns a counter ref, `Hstr.create 7` and `Hint.create 7`.
`wstdlib.ml:13–32` and `exthtbl.ml:40–43` specialize ordinary strong
`Hashtbl.Make`; neither table is an ephemeron. `Hashtbl.Make` disables random
seeding and creates backing 16 (`hashtbl.ml:64–71,477–488`). A table has four
fields; a bucket Cons has three. The only table operations are forward find,
forward add, reverse add and reverse find. `loc.mli` exports neither the
FileTags module nor a table/ref alias. There is no clear, remove, replacement,
iterator, fold, copy or traversal-flag change on these private owners. Keys
are immutable strings or integers; their hash/equality leaves do not mutate
FileTags. One worker and the accepted callback closure exclude a concurrent
FileTags mutator.

The protected initialization/cut relation is imported from
[initial registration](retained-why-initial-registration-bound.md),
[logging startup](retained-parallel-logging-prefix.md) and
[combined startup](retained-combined-parallel-startup.md). FileTags initializes
after the protected boundary. The completed initial prefix admits no escaping
save, collection/reclamation, foreign mutation or failed native operation;
the selected cut cannot be entered from a suspended FileTags helper. The
helpers call only the displayed table operations, with no route to logical
registration; the accepted pending-client cut argument excludes reaching the
cut through a callback while a mutation is suspended.

First rule out a wrapped counter or table size, without treating a residue as
a count. Each successful new filename allocates a fresh four-word Hstr cell
before the counter increment. The accepted protected minor usage is <2^28
words with no reclamation; the retained native add body uses small allocation.
A hypothetical first wrap would require at least 2^62 such steps and is
impossible. The same first-violation argument bounds initial table growth well
below the array limit. With no interruptions and no removal, ordinary find/add
induction now gives exact counter N0, size N0 in both tables, one disjoint
correctly routed cell per filename/tag, and complete inverse maps. Growth
starts at16 and occurs only at size=2*old_backing+1. Therefore B0 is a power of
two, N0<=2*B0 and B0<=max(16,N0); both tables share that extent because their
completed insertion counts agree. The initialized dummy filename proves N0>=1.

The accepted combined startup result supplies N0<=945214 from the original
current-major backing bound945213 plus at most one timeless-driver name. This
is reused as its source-attached theorem, not recomputed by subtracting an
upper allocation credit from an actual heap. The largest permitted power of
two under max(16,945214) is524288. No new FileTags capture is needed.

## Every suffix key is already in D0

The packet records the complete direct-call census over the retained Why3
`src/` and `plugins/` ML/lexer/grammar/interface sources. The only local calls
of `FileTags.get_file_tag` are module-initial `dummy_position` and
`user_position`; `extract` delegates to the latter. The selected-source
closure, rather than a textual census alone, classifies its callers:

| Producer | Filename-domain argument |
| --- | --- |
| Incremental WhyML parser and Lexlib diagnostics | The only later parsed files are the unchanged installed int, real, algebra and relations libraries. Each was successfully parsed in the initial 21-file family. The packet joins their exact paths/identities to every case's ordered initial inputs. Each is nonempty with a theory/module: the parser constructs its identifier/end location through `floc`/`mk_id`, so the filename was actually registered, not merely opened. `Loc.set_file` preserves that exact file argument. |
| Explicit `[# ...]` positions | The accepted complete-library inventory has no such token. No virtual filename bypasses the ordinary lexbuf filename. |
| Typing `loc_cutoff` and copies/joins | Cutoff passes the filename returned by `Loc.get`; joins/copies retain tag fields. Any successfully returned reverse-table value is an initial-domain string or a later insertion value already in D0. A missing reverse binding raises; it does not create a string. |
| Location attributes | `create_loc_attr` stores the `Loc.get` filename as its suffix; decoding preserves that suffix. Complete library and decoded-JSON inventories exclude raw `vc:written:`/`call_result:` alternatives. The selected attribute producers therefore preserve D0, even if a numeric tag later selects a different stored filename. |
| Native GNAT JSON conversion | Conversion and its `<dummy>`/raw/marker filenames occur before the registration cut. Successful initial occurrences are in D0. The selected suffix does not rerun that converter; stale Curr state alone is not a producer. |
| Empty synthetic locations | The empty key was registered by Loc initialization. Argument-wrapper errors and even the empty-name Mlw_printer helpers add no new key. The selected printer is SMTv2; the latter helpers are not otherwise used. |
| Other frontend/session routes | S-expression deserialization, model/CE parsing, IDE/ITP JSON messages, old-session reads, Why3doc, Jessie and unrelated plugin frontends are excluded by the accepted selected-client closure. Registering a parser does not execute it. |
| Saves, result/report callbacks and diagnostics | The accepted callback and native-effect closures perform no parser/preparation or new-position producer. Location printing uses `Loc.get`, not `user_position`. Path construction alone does not insert a FileTags key. |

The library/clone origin closure is the accepted
[library-origin argument](retained-why-path-library-origins.md), with the
[constructor scope](retained-why-library-constructors.md),
[printer scope](retained-why-printer-demand.md), and
[callback scope](retained-why-callback-demand.md). The
[R69 filename argument](retained-why-report-path-inputs.md) supplies the
all-origin 180-byte bound and raw-attribute inventories. D0 membership is a
stronger new suffix theorem with the initial-completion attachment above;
length180 alone would not prove it. It preserves R69's warning entry436 and
all previously exported request/diagnostic path bounds.

## Escaping saves, partial rehash and finite recovery

Use e<=2 **once for the entire process**. Ordinary genuine missing-key results
do not consume e. A false `Not_found` delivered out of forward lookup does.
The `try ... with` protects only Hstr.find; an exception raised from an add in
its handler escapes that invocation rather than being caught by the same try.
The native insertion contract in
[save Hashtbl prefix](retained-why-save-hashtbl-prefix.md) applies to these same
Make specializations: the cell-allocation/pending check precedes head
publication, and publication/size increment/threshold test have no intervening
pending dispatch. Hence a continuing observer cannot see head publication
without its size increment. The native resize does publish its new empty array
before relocation and has later polls. We import those cut points, **not** the
other packet's no-resize guard or a general atomic-resize conclusion.

Start with complete D0. No insertion is possible until a false miss consumes
one escaping-save event. If the two available events both cause false misses,
there is no remaining event to interrupt either mutation; at most two
insertions occur and ordinary complete rehash preserves the domain. If the
second event instead abandons the first insertion handler, classify its phase:

1. Before forward publication, or after forward publication but before any
   new backing is published: the old disjoint forward table still contains
   all D0 keys. An allocated but unpublished cell is charged once. The native
   commit contract excludes a separately resumed head/size split. No later
   ordinary forward miss follows.
2. During forward resize after publishing backing2*B0: a prefix of the old
   cells may be rooted, and some old keys may be missing. The size is N0+1.
   The first resize can only have been triggered by N0=2*B0. An exception
   before/within tail-array initialization is included in the empty case.
3. After forward add returns, including before/during reverse add/resize,
   between the two adds, or before/after the counter increment: the forward
   map contains every D0 key. Reverse damage, missing reverse values and
   duplicate tags cannot induce a new forward key. Future `Loc.get` may fail
   or return another D0 filename. With e spent, no further add follows.

Only phase2 requires recovery. The first resize starts from disjoint chains.
Order cells by their original bucket and position in that bucket. Relocation
saves the original successor before changing a link; doubling only splits an
old bucket into its two new indices. Every changed link goes forward in that
old-chain order. Every intermediate reachable chain is therefore acyclic,
although different roots can share tails. Completion cuts the tails and
restores disjoint correctly routed buckets. A partial layout is **not**
treated as a completed hashtable invariant.

If the published new array is nonempty, at least one new root is its own
correctly routed key in D0; that root cannot disappear under later prepends.
With no remaining escaping event and with the stated resource premise, a
genuine miss is repaired by one ordinary prepend and thereafter stays found.
There are at most N0-1 such repairs. The size is then at most
`N0+1+(N0-1)=2*N0=4*B0`, so the strict `size > 2*backing` growth test never
starts a second resize of this possibly shared-tail graph. Fresh prepends
preserve acyclicity and the already restored correctly routed keys.

If the published array is empty, at most N0 repairs occur. Fresh cells build
disjoint chains; the old partially processed graph has no root in the table.
If a second resize is triggered, it consequently starts from this **disjoint**
fresh graph, completes with no further escaping event and preserves all
restored keys. Its backing is4*B0. Thus no resize is ever started from a
shared-tail graph. The first incomplete handler plus recovery uses at most
N0+1 add attempts; the uniform N0+2 envelope also includes the two-false-miss
case. Each reverse add/increment is dominated by a forward-handler entry.

This phase proof also covers termination at any earlier prefix. It does not
assume tag association persistence, successful printing, or a bijection after
the cut. A returned numeric tag may alias; those effects remain permitted.

## Actual consumers, allocation objects and limits

The total physical cells allocated in either table are at most
`N0+(N0+2)`. Acyclicity bounds an individual find chain by that number, including
wrong-bucket tails. The sum over all roots can be larger; a conservative
separate upper is `backing*(2*N0+2)` (3,964,519,055,360 at the common bounds).
No FileTags consumer actually iterates that root sum. Successful rehash starts
only from disjoint chains and visits each old physical cell once. Counter and
size additions are each +1 and bounded by the same cell-attempt envelope;
zero<=size<=2*N0+2 suffices even when some allocated cells are unreachable.

`key_index` masks an integer hash with `backing-1`, producing an index in
`[0,backing-1]`. The nonzero power-of-two extent is retained by every array
publication. Allocation and traversal use backing, never a possibly stale
size. At most two suffix resizes per table are possible, with extents2*B0 and
4*B0; a third would require size>8*B0, contradicting
`size<=2*N0+2<=4*B0+2<=8*B0` for B0>=16. Each resize requests one new backing
and one equal-sized tail array. This bounds all array-loop endpoints, threshold
shifts and attempted doubling before the first invalid-representation cut,
closing that cut by contradiction.

For ownership joins, the **explicit bucket/array requests only** are bounded
as follows; these are not whole-routine or process-RAM totals:

* Both tables' suffix bucket requests: at most `8*(N0+2)` words =7,561,728.
* Both tables' suffix backing/tail requests, including headers: at most
  `2*(2*(2*B0+1)+2*(4*B0+1))` =12,582,920 words.
* Their sum:20,144,648 words. Old pre-cut arrays and cells stay in the accepted
  startup envelope; current cells/backings have the separate bounds above.

These allocations do not copy filename payloads: the buckets retain existing
string values. The fixed table records/counter are initial objects. Rehash
closures, caller location records, returned tuples, GC/native-service storage
and independently owned callback demand are not hidden in the bucket/array
sum. A `position` record has three fields/four words, and a returned `Loc.get`
tuple has five fields/six words; their repetition belongs to the accepted
producer/consumer owners, not to the number of new tags.

`user_position` validates line bounds and nonnegative columns before FileTags
lookup. On this 64-bit source, bits_col=16 and max_line=2^47-1; packing uses
machine bitwise shift/or and unpacking uses logical right shift/mask. Packed
positions need not be nonnegative mathematical integers. No new no-overflow
claim for unrelated lexbuf coordinate producers or total location allocation
is inferred from the table theorem.

The five numerical applications in the packet pass the same common bounds.
They retain one e<=2, two save-entering callbacks and three saves. No budget is
renewed per table, filename, parser attempt or save. Selected author model is
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. Independent acceptance, shared records and final integration
belong to the lead/reviewer; no such writes are made by this packet.
