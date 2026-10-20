# Retained save shape-builder allocation

2026-10-20 UTC, follow-on to Round 36, research #119 / #153, Linux x86_64.
This packet supplies cumulative direct-request and maximum individual-request
bounds for the six root families left by
[Round 36](retained-why-save-structural-allocation.md). It counts temporary
objects and abandoned construction prefixes. The largest individual request
introduced by these families is bounded by **35,754,472 bytes** in Put_Line.
The cumulative bounds are deliberately very loose and do not establish physical
memory sufficiency, successful completion, or complete-save capacity.

The [new packet](../evidence/retained-why-save-shape-builder-allocation-20261020/README.md)
preserves every Round 36 byte. It imports the frozen
[variable-only binder transfer](retained-why-save-stack-composition.md) at
`a36841c24be435babc1295828c608c7a5dbd3e49`; it does not repeat its extraction.
Its source witnesses and retained native bodies are checked against the same
Why3/OCaml sources and Linux ELF used previously. Exact source/native behavior
remains the existing selected relation, not a recovered build-history or
machine-proved refinement result. Native witness ranges include unselected
constructor/branch arms; the source selection below determines the claim.

## Scope, budgets and ownership

There is one whole-post-cut budget `r<=3` reached saves and `e<=2` escaping
signal-save exceptions. Every root, helper, nested save and abandoned prefix
uses that same budget. The first five root families each have at most `3G`
entries: `goal_expl_task`, `create_ident_printer []`, `used_theories`,
`used_symbols`, and `local_decls`. There are at most `3(J-G)` top-level
`Shape.t_shape` entries. These are the unchanged Round 36 root bounds.

Round 36 owns the global shape dictionaries, saved shape cons cells,
`Buffer.contents` destinations, all shared Shape-buffer backings and the
120-byte top-level `t_bound_shape_task` locals. The serializer allocation packet
owns its Format instances. This packet owns the distinct shape-builder local
objects, including the new Format instances inside `const_shape` and
`sn_decode`. Neither of those internal formatter families was charged by the
serializer packet. Their output to the shared Shape Buffer does not introduce
another backing charge here. Existing input strings, terms, types and task
records are references to entry storage, not newly copied objects.

All byte counts include OCaml headers: persistent map nodes 48, list cells and
pairs 24, hash buckets 32, hash-table records 40, and a pointer array of n slots
`8(n+1)`. A string/bytes destination of length n requests
`S(n)=8*(1+floor((n+8)/8))`. C allocations are listed separately. Collector,
barrier, pending-action, native allocation/error and GMP service internals keep
their existing ownership boundary. No request total is treated as available
RAM, a program-maintained counter, or proof that an allocation returns.

## A cumulative Extmap request lemma

For valid persistent maps with n and m keys, define

```text
M(n,m) = 4096*(n+m+1)^3 bytes.
```

This bounds all own requests of each selected add, singleton, map, fold,
map_filter, union, inter, diff, disjoint, find/choose, and fold2_inter operation.
It includes constant option callbacks used by the set wrappers; nontrivial
client callbacks are charged separately. It is not a bound inferred from only
the size of the returned map.

Here is the event argument for the conservative coefficient. A search/add,
remove-min or join spine has at most `n+m+1` frames. At a balance step at most
three 48-byte nodes are requested. Split has at most that many search frames,
each with at most one join and one 32-byte result triple, plus its 16-byte
presence option. Its own charge is at most `176*(n+m+1)^2`. Concat adds a
24-byte min-binding pair, a remove-min spine and a join spine. In union,
inter and diff, child input domains partition the parent inputs with a pivot
removed. Across the call tree there are at most n+m nonempty pivots, not an
unbounded multiplication of recursive subproblems. Charging a full split and
concat/join allowance at every pivot is below M. Unary map/filter folds have
at most n pivots and the same allowance overbounds their reconstruction.

Disjoint needs a different argument because it constructs temporary truncated
Nodes. Charge each nonempty comparison to the pair of original keys at its
roots. In the `<` branch, the two child comparison rectangles are
`(left1 + root1) x left2` and `right1 x tree2`; they are disjoint subsets of
the parent's rectangle and omit the compared pair. The `>` and equality
branches have the analogous partition. Thus at most n*m comparisons and
48-byte temporary nodes occur. No inference from decreasing depth alone is
used. Fold2_inter's two enumerators each consume an input key once; every
More record costs 40 and its auxiliary closure 56. Simple Some results cost
16. The retained native allocation sites confirm these layouts. The 4096
coefficient also covers fixed wrappers/partial applications and is larger
than the summed constant reservation sites of each retained Why3 helper body.

Map comparisons here use immutable identifier/attribute tags. Client functions
that allocate terms, inner maps or strings are outside M and explicitly
charged below. All maps constructed by these pure operations remain valid
maps, even when an exception abandons a partially built result.

## Task metadata and catch-sensitive declaration selection

Let I be the accepted actual-cut registration count:
136,844 / 121,505 / 77,806 / 59,035 / 60,496. `Ident.ident` is private and
immutable (`ident.mli:66–71`); `id_register` is its sole record constructor
(`ident.ml:187–192`). The accepted initial-registration result bounds the
ident objects constructed before the cut. Every key already reachable through
the immutable selected tasks' `task_clone` maps and theories' `th_local` maps
belongs to that domain. `task_hd` and theory records have no mutable fields;
`close_theory` publishes `uc_local` as `th_local`. The selected save roots only
read these records. Fresh binder identifiers are inserted into separate local
maps and are never written back into task metadata.

Therefore each task-clone/theory-local map, the outer used-theory map and every
used-symbol union result has at most I keys. The result bound is I, not I²:
union does not invent identifier keys. This argument uses the accepted fixed
task/fresh-cut correspondence and valid-map premises; it is not a new raw
metadata extraction or a bound on all post-cut identifier objects.

`used_theories` performs one map_filter. Its at most I callbacks choose one
Hcpt element (one 24-byte pair), make an exists wrapper (40), and possibly
make a Some (16). Hcpt.exists/check_use has no per-visited-element normal
allocation; a selected assertion branch would allocate once and escape.
Charge `M(I,0)+256(I+1)` per root. Its leaf count is unnecessary for this
allocation result; Patricia traversal stack is owned by the stack packet.

`used_symbols` maps at most I inner `th_local` maps and performs at most I
unions. Each inner dictionary closure costs 32 and each join closure 48.
The charge is `M(I,0)+I*(M(I,0)+M(I,I)+1024)+1024`. An exceptional duplicate-key
assertion is covered before the operation escapes. No correctness assertion
about which theory wins is needed for this request bound.

Let C bound the preserved task chain: 1044 / 1044 / 536 / 368 / 434.
`local_decls` first creates at most C task-list cons cells. A filter activation
can call at most two recursive continuations: one in its try body and, if that
raises Not_found, one in its handler. Both consume strict suffixes of the
original list. This covers a Not_found from a deeper `Sid.choose`, not just
an ordinary absent symbol lookup. The full activation tree therefore has
at most `2^(C+1)-1` nodes. Skip itself makes no object. Each activation can
request one choose pair and one cons; each reached reverse has at most C cons
cells. Initial list and filter closure included, the conservative per-root
charge is `256*(C+1)*2^(C+1)` bytes. This exponential allowance avoids assuming
single-pass behavior or inventing a nonempty `d_news` input. It is a finite
request bound, not a useful estimate of normal allocation or physical demand.

## Opening and substitution, without another administrative extraction

The frozen stack packet establishes that all saved substitution images are
Tvar, all generated images remain Tvar, constructors/child-list skeletons are
preserved, there are no patterns/Tcase, and no term/binder result is written
back into a selected raw task. It supplies maximum initial administrative
mass B, list length L=7, and dynamic environment cardinality N:

| Case | B | N | P | U |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 3110 | 2773 | 5979 | 195 |
| Put | 2648 | 2379 | 5531 | 171 |
| First_Or_Default | 2178 | 631 | 3352 | 193 |
| Is_Message | 239 | 266 | 1276 | 42 |
| Input_Is_Valid | 310 | 281 | 1435 | 44 |

P is the maximum, over the accepted per-task shape certificate, of the sum of
fully opened proposition term occurrences. It also overbounds that task's
goal formula traversal. U is the accepted union of term **and proposition
identifier** attributes, not the smaller term-only union. Original strings
remain shared and new attributes are not registered by this route.

For one opening, a bound/epsilon has one body and a quantifier has one body
plus at most L² trigger terms. Their constructor walks have at most
`V=(1+L²)*B` visits: variable-only substitution preserves that original
skeleton. At each visited binder, substitution updates its administrative
record lazily instead of descending into its body. Mapping its old deferred
map invokes substitution on at most N variable leaves. These leaves cannot
open another binder or recursively substitute into the returned image.
Thus at most `R=V*(N+1)` substitution visits suffice per opening.

Put `K=N+U+L+1`. Each substitution visit needs at most one attribute union;
a binder visit additionally has disjoint, inter, diff, fold2_inter, map and
union. Each of at most N add_nt_vars callbacks has a variable singleton,
optional scalar map and a union. `16+4N` charges of M(K,K) per visit therefore
overbound all these map operations. The R count separately includes mapped
variable callbacks, so their attribute-copy operations are not omitted.
Local records, constructors, options, application closures and list cells
cost less than `4096*(1+L²)` per visit. Before these visits, at most L fresh
variables each cost at most 4096 local bytes plus two M(K,K) charges for
identifier attributes and environment insertion. The opening entry/trigger
list wrapper receives another `4096*(1+L²)`. `transfer.py` records this exact
sum and uses at most `6GP` opening entries over the whole interval: one full
shape walk and one full explanation walk, each already multiplied by r=3.
Every term is charged as if it opens a binder, which safely includes partial
openings and unused trigger reconstruction.

Fresh symbol creation retains the existing type pointer. `t_attr_copy` calls
`t_similar`; its optional-type equality calls physical `ty_equal`, not a type
walk. Tconst is returned unchanged by the selected substitution mapper and
therefore exits `t_attr_copy` at `s==t`; its numeric-comparison arm is not
entered here. List equality compares immediate child pointers. Consequently
this selected opening allocation route does not require a raw type graph.
The bounds concern map key cardinality and object storage. They do not prove
that binder multiplicity arithmetic preserves an unbounded-integer meaning.

## Private printers, candidate strings and internal formatters

Each root constructs two 2048-slot tables (requested size 1997), a printer
record and a reserve closure, even with the empty blacklist. The two local
groups total 80 bytes. Each table create also receives the previously justified
16,384-byte random-seeding allowance; successful forcing of an already shared
seed is not assumed. There are at most 2P indices-table replacements and P
values-table replacements, including calls on already known identifiers.
The scalar size increments at most once per replacement, so it is bounded by
that source-site count. Starting at 2048, the capacity doubles only when the
size exceeds twice the old capacity. The largest reached capacity follows the
short deterministic loop in `table_requests`.

For every replacement, the packet charges a 32-byte bucket, two arrays at the
largest reached capacity, and 96 bytes of resize closures, whether or not a
resize is reached. This covers repeated and abandoned resize prefixes. The
printer never iterates/folds/sequences its tables, so ongoing_traversal remains
false and redistribution uses inplace=true. That arm makes no per-cell copy
request. Consequently its allocation bound does not require successful
rehashing or a finite number of visits through a potentially retained partial
chain. It does **not** establish printer lookup/rehash termination. The first
replacement inside find_unique's catch normally updates the key just found;
whether the selected catch protocol excludes every reuse of an interrupted
mutation is a separate control claim, not silently borrowed from statistics'
different abandon-owner argument.

The accepted candidate theorem gives `Q=P(P+1)` for every attempted positive
suffix and original-name maximum M0. `advance` passes at most 2P occupied
candidates, whereas `retreat` decreases at most Q times. Fetch and final
construction add at most four calls, so all specname evaluations per printer
are bounded by `P*(Q+2P+4)`. Candidate strings are drawn from the decimal and
repeated-quote families, both covered by length
`M0+max(Q,digits(Q))`. Each evaluation gets two such string blocks plus 64
bytes for scalar conversion, even when it only tests membership. The native
find_unique closure group adds 136 per entry.

Every outer decode and positive candidate evaluation receives a full
sn_decode charge. It includes at most five substrings of length M0, 512 bytes
of local closure/variant allowance, and its possible `Format.asprintf` call.
That format is `%a%s`; print_sn has at most three string conversions and fixed
punctuation. Output is at most `2M0+16`, with at most `2M0+64` core events
including empty fragments and flush. The two formatted calls use the accepted
`128+192*27` accumulator allowance each; the fresh formatter uses fixed 640
and dynamic `640*(3E+1)`, plus 192E scalar/character allowance. Its private
Buffer512 gets its record, every possible doubling backing, and contents
destination. All this is charged even when sn_decode returns directly.

Shape's alpha/name map has at most P+A keys and receives at most P+A adds;
M(P+A,P+A) per add covers unpublished reconstruction. Each alpha string gets
64 bytes and each visited term 512 bytes for local traversal closures.
These are distinct from Round 36's top-level local objects.

All retained constants are integers. Each of at most `3GP` constant visits
gets a fresh formatter allowance, two core events (text and flush), local
overhead and a decimal destination of at most 20 bytes. The same count safely
overcharges nonconstant visits. In `ml_z_format` the fixed `%d` selection has
width zero and at most two limbs: its direct malloc buffer is at most
`1+2+64*2+1+1=133` bytes and its limb copy at most 16 bytes. These two C
requests are separate from the OCaml destination and from GMP service scratch.
Both malloc results are used without a local NULL check (`caml_z.c:351–357,
1034–1048`). This packet establishes requested sizes, and does not turn that
existing native service boundary into graceful physical-exhaustion behavior.

## Explanation traversal and numerical results

The accepted configuration join supplies two explanation prefixes. Each
attribute collection visits at most U attributes per prefix, creates at most
2U substrings and matching/reversal cons cells, and uses fixed fold closures.
The substring length is at most the accepted union's summed bytes. There are
at most P formula callbacks plus one proposition-attribute fallback per root.
The existing explanation extent E bounds each concatenation destination;
five S(E) charges cover the concat tree and final option. Formula openings
are charged in the opening owner above. These allocations are independent of
the fact that only one successful explanation list is finally returned.

To keep the very loose declaration-retry allowance readable, the exact
six-family cumulative direct-byte total can be written `a*2^b+c`:

| Case | a | b | c | Largest individual request |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 52,166,400 | 1045 | 9,654,584,559,224,158,339,592,164,629,215,685 | 35,754,472 |
| Put | 43,338,240 | 1045 | 2,953,956,086,279,357,005,642,964,527,888,254 | 30,597,544 |
| First_Or_Default | 13,609,728 | 537 | 2,193,698,896,396,554,321,926,396,239,896 | 11,239,328 |
| Is_Message | 1,133,568 | 369 | 115,004,879,192,272,638,489,604,944 | 1,629,496 |
| Input_Is_Valid | 1,670,400 | 435 | 268,139,676,787,442,678,635,123,185 | 2,060,720 |

`result.json` also gives exact decimal integers, per-owner subtotals, root and
event counts, and the disjoint sum with the frozen structural and serializer
subtotals. The huge cumulative numbers are mathematical accounting bounds;
they intentionally need not fit a 64-bit reporting or program counter.
Individual strings/arrays/headers, map heights, suffixes/successors, alpha and
registration increments, table size/doubling, decoder offsets and Format
sentinels pass their explicit guards. The registration check bounds this
owner's increment allowance plus the initial I; other post-cut owners and
global no-wrap composition remain in their existing interface. This does not
prove physical sufficiency.

Without named premises the usable export is null. Under the existing typed
input/fixed-task, initial-identity, variable-only binder, source/native scalar
service, global budget/control and private candidate/formatter contracts, the
six-family direct-request accounting export is enabled. Complete save,
failed-service capacity, physical memory, printer termination and whole-pipeline
flags remain false. Source transfer and native arm selection are reviewed
arguments; identity/arithmetic checks do not mechanically prove them.

Selected author setting: GPT-6 Astra / Extra High; runtime-confirmed model/effort
and individual token/cost telemetry unavailable. Base
`f120b8f73721b81a245e39f62fd80981d2af979f`. Validation reads retained inputs,
archives and ELF only. There is no new capture, native target, disassembler,
source fetch, solver/proof or predecessor-checker run. Parent owns independent
review, integration, issues and durable memory; CLI memory was not updated.
The final focused comparison passed five cases, 42 source excerpts and 292
native bodies / 46,760 instruction bytes in 0.556369 seconds. Its earlier
freeze/write passed in 2.131939 seconds; these are distinct lightweight checks.
