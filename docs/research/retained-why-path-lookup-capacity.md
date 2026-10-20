# Direct capacity of restored-path lookup

2026-10-20 UTC, #119 / #153, Round 33. For the five selected save
continuations, this argument closes the **local lookup traversal, cycle,
index and per-node native-frame obligations**, under the inherited scoped
source/native, valid-heap, pending-frame and selected-writer premises. It
provides a finite ceiling on executed direct lookup work even if a runtime
service fails or does not return. It does not prove lookup termination through
those services, physical-memory sufficiency or complete restore-table/save
capacity. The [packet](../evidence/retained-why-path-lookup-capacity-20261020/README.md)
retains the exact source excerpts, selected installed bytes, five initial
topology projections and a conditional arithmetic interface.

## Private state and interruption invariant

`Theory` owns `id_to_path` privately (`theory.ml:472–492`). Its exposed
closures use only `Wid.mem`, `Wid.set` and `Wid.find`; none exposes the table,
array or bucket links. `Weakhtbl.set` is `Ephemeron.K1.Make.replace`.
The selected `Ident` functor's hash is the immutable integer `id_tag` and
its equality compares two such tags. No payload comparison or recursive
user equality is invoked.

The [accepted initial-state argument](retained-why-path-initial-state.md)
excludes a resumable pre-cut Theory mutation at each actual cut. Its accepted
current-array census supplies finite disjoint initial bucket chains. The
[later-writer closure](retained-why-path-library-origins.md) restricts later
writes to the selected preparation/tuple/library origins and excludes Theory
writes from the selected pending, save, exit and printer/error roots. In
particular, a normally returning pending callback does not reenter a Theory
mutation. These are whole-selected-interval local effects, not an extension of
the older PID 97103 native resource measurements.

The actual Ephemeron implementation uses `Empty | Cons(hash, container, rest)`
with **immutable strong `rest` links**. The ephemeron key/data may disappear or
change; that cannot change the bucket's cached hash or tail. Every completed
new Cons points to an already completed finite tail. Allocation/initialization
precedes publication. Induction over the only selected table mutations gives:

- `replace` either updates an ephemeron's key/data, leaving links unchanged,
  or prepends one fresh Cons to its saved bucket tail. Its `Not_found` handler
  can run after a pending exception; the argument permits a duplicate cached
  hash and does not assume that the key was absent. A failure before publication
  exposes no incomplete cell. A failure after publication preserves a complete
  chain even if `size` has not yet been incremented.
- `clean` reconstructs a bucket from a subsequence of its old cells and
  publishes it only after that reconstruction returns. A partially completed
  clean leaves a mixture of old and reconstructed finite buckets. Dead-key
  decrements may already have changed `size` before an exception; no accurate
  size invariant is needed here.
- `resize` allocates an all-Empty array, publishes that array, then copies
  each old occurrence once into a fresh Cons in its new bucket. Any prefix of
  that copying is finite and acyclic. Its old array is retained in the active
  frame; an escaping exception may abandon it. Neither case splices a new
  tail into an old Cons. Cleaning/copying have no catch that restarts the
  abandoned traversal. Resize is outside `replace`'s guarded traversal, in
  the exception handler, so an exception from resize is not recaught there.

This is an invariant for every executed prefix, not only successful complete
updates. GC relocation preserves logical objects and their links under the
existing valid-value/root relation. The proof excludes unmodeled unchecked
mutation; type syntax or a captured finite array alone would not exclude a
forged cycle. It does not require all future updates to succeed.

Once `find` captures a bucket root, that root and each saved tail are strong
roots while needed. Collection or replacement of the table cannot lengthen
that logical captured chain. The native matching-hash branch saves `rest`
before entering equality/getter code. Each normal continuation consumes one
node; an escaping exception abandons this lookup. A nested signal save is a
separate lookup charged to the accepted global save-entry budget, rather than
a restart of the interrupted chain. Pending execution that never returns adds
no further direct visits but still has its separate unclosed resource owner.

## Representation and array extents

A bucket Cons has three payload words and one header: **32 bytes** on the
selected 64-bit build, also visible in `replace`'s `0xc00` header and 32-byte
allocation request. At the instant a root is captured, all distinct cells in
its strong chain coexist in a valid nonoverlapping address-space representation.
There are at most 2^64 byte addresses, hence

```text
L <= floor(2^64 / 32) = 2^59.
```

This deliberately loose representation ceiling is valid without counting
future table writes. It is not an assertion that the process can allocate,
map or traverse that much memory. It supplies a mathematical bound for the
finite logical chain held by this particular lookup; moving GC does not create
additional logical successors. It is not a bound on lifetime allocation,
all arrays retained by suspended frames or GC work. Crucially, the lookup
has no cumulative visit counter whose arithmetic would have to hold L.

Each captured current array initially has capacity **4096**. The private
selected interface can only retain that capacity or double it through resize.
The installed maximum-array constant is **2^54−1**, verified both in the
system primitive and inlined in resize. The strict guard `2*C < 2^54−1`
therefore keeps C a power of two in **[4096, 2^53]**. Computing `2*C`, the
resize threshold, C−1 and the array loop endpoints stays in the nonnegative
63-bit OCaml integer range. The `size` field decides whether a resize is
attempted but cannot bypass this array-length guard. No equality between
`size` and current cells is assumed after an interrupted mutation.

For any represented signed integer tag, `tag land (C−1)` lies in [0,C−1].
The native `find` loads the current array after hashing, derives its length
and index from that same array, checks the bound, then loads the bucket with
no intervening poll/callback. Its tagged index is `2*i+1`, its byte offset is
`4*(2*i+1)−4 = 8*i`, and the selected element lies inside the represented
8*C-byte payload. The lookup never reads `size`. It follows that writer-side
size drift/wrap remains a distinct arithmetic obligation and cannot invalidate
this lookup index proof. This is not an assurance claim for the writer's own
arithmetic or recursive copying stack.

## Direct native work and getter interface

The retained native route is `Theory.restore_path_4035` →
`Ephemeron.find_730` → `find_rec_721`. Restore tail-jumps to find. Find reserves
24 bytes, computes/captures the bucket, restores that frame and tail-jumps to
find_rec. Find_rec reserves **40 bytes once**; its three continuation backedges
target `0x99ff14`, after the prologue at `0x99ff10`. Its GC return jumps to
`0x99ff20`, after the current poll. There is no per-cell recursive frame,
allocation in the direct loop, table-size read or visit accumulator.

The selected tag body is `Ident.tag_2120` at `0x56d460`, a load from offset
0x18 followed by return. The packet also retains its static closure at
0xb41da8, the Ident initialization passing that closure to
`Wstdlib.fun_4401`, that constructor's original-argument call to
`Weakhtbl.Make_640`, and the final Ident.W installation used by restore.
This distinguishes the identifier callback from unrelated Ident tag functions.
These bytes corroborate the source functor connection; they are not a new
dynamic closure capture or a whole-binary refinement proof.

For a captured chain of at most L cells, let H≤L be the visited cells whose
cached hash equals the queried tag. Counts include a failing last prefix:

| Direct operation or caller request | Upper bound per lookup |
| --- | ---: |
| Cons visits | L |
| find_rec poll sites, including final Empty | L+1 |
| Ephemeron/Weakhtbl hash-wrapper poll sites | 2 |
| Key getter calls | H |
| Data getter calls | H |
| Identifier tag field reads | 1+2H |
| One-field Some block requests | 2H |
| Some block requested bytes, including headers | 32H |
| Explicit optionalize pending-action entries | 2H |

`K1.equal` calls the key getter only on a cached-hash match; a live key causes
two tag reads and a comparison. Data is fetched only after equality succeeds.
An absent key, unequal key or disappearing data continues to the saved tail.
Unrelated hashes still incur visits and loop polls even though they incur no
getter work. Small serialized-tag counts do not bound bucket length.

Each getter's `optionalize` requests at most one 16-byte Some block and then
explicitly enters pending actions, including on a None result. Allocation
failure can prevent that later entry. Key access can enter marking; data access
can enter ephemeron cleaning and marking. The count is of getter/allocator
requests and explicit pending entries, not allocator retries or the internal
work of marking, collection, memprof, callbacks or exception transfer.

All selected lookup-layer bodies have fixed own frames: restore/tag/index
reserve none; find 24; find_rec 40; each hash wrapper 8; K1 equality,
Weakhtbl equality and Obj.get_key 24 each; the data wrapper 8. Each C getter
wrapper reserves/pushes 24 and optionalize 104. These are **per-body** reserves,
excluding return addresses, bridges and their callees, not an additive bound
on the complete active native stack. Their call depth is fixed per node, and
normal returns release it before the next node. Existing caller stack, signal
nesting, apply/C/GC/exception trampolines and getter/runtime descendants remain
separate. In contrast, writer-side `clean` and `insert_bucket` recurse before
constructing each copied Cons; their capacity is not closed by find_rec's tail
loop.

## Useful growth transfer and remaining owners

The initial packet reproduces these metadata facts, reusing the accepted
current-cell/raw-block correspondence rather than replaying its observer:

| Case | PID | Initial current cells | Initial largest bucket | Identifier occurrences N |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 17310 | 6,941 | 7 | 66 |
| Put | 17514 | 6,941 | 7 | 55 |
| First_Or_Default | 17631 | 6,901 | 7 | 34 |
| Is_Message | 17704 | 6,783 | 7 | 5 |
| Input_Is_Valid | 17869 | 6,819 | 7 | 6 |

A stronger practical interface remains available. Let W bound **actual
post-cut fresh-cell publications in replace's missing/caught-Not_found
handler**, across the selected interval, including interrupted/retried work.
Cleaning and every prefix of resize copying do not increase current-cell
occurrences: a copied occurrence replaces an old occurrence in the current
array, and a doubled mask only splits each old bucket. With the no-reentrant
Theory-writer premise and the initial absence of a suspended old writer,

```text
current cells <= min(2^59, V0 + W)
captured bucket length <= min(2^59, 7 + W).
```

The source induction uses ancestor buckets under successive power-of-two masks;
no uniqueness of hashes, keys or payloads is required. Old arrays and unpublished
reconstruction cells can still consume memory beyond the current-cell count.
W is **unknown**. The accepted 459 normal preparation-attempt envelope is not
an actual interrupted-control bound. Neither a bounded key domain nor the
116,162-byte selected-path bound supplies W. W also does not count failed
allocations before publication, copying allocations, all parser work or
preparation calls that make no new publication.

For the actual global save budget r≤3 and the retained per-save N, the packet
charges at most r*N lookup attempts. It exports direct work/request ceilings
using L=2^59 unless W is supplied. These totals are arbitrary-precision
mathematical accounting, not values accumulated by the program or evidence of
available resources. The unasserted interface exports null usable bounds;
the explicitly supplied named external premises enable only the local result.

The remaining owners are actual writer/preparation counts; writer size
arithmetic and recursive clean/copy storage; all simultaneous and lifetime
allocation including getter options, retained old arrays and metadata;
allocator/GC/mark/clean/pending/exception/trampoline stack and work; existing
caller/signal stack headroom; and composition with the other save/pipeline
obligations. **Complete restore-table, save and pipeline capacity stay false.**
No source/pin/Oracle/admission change is made. Production #88–#94 is unstarted
and PR #121 remains draft/unmerged. Validation reads retained sources, capture
metadata and installed ELF bytes only; it performs no target execution, capture,
disassembly, fetch, solver/proof/full-suite run or broad predecessor replay.
Independent acceptance belongs to the combined Round 33 review.
