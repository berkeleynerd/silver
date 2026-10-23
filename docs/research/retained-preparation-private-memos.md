# Private preparation memos and container representation

2026-10-23 UTC; #119 / #153. Candidate, pending independent review.
This supplies the private-container interface explicitly left outside the
[shared-demand result](retained-why-shared-demand.md). It covers the selected
Trans task/declaration/history caches, hit-local type memos, Driver's update
registry, Introduction's content table and queues, and R58's tagged dependency
maps. It does not claim complete fixed-domain or whole-program capacity.
The [packet](../evidence/retained-preparation-private-memos-20261023/README.md)
uses retained source and existing whole-lifetime counter bounds; no new capture
or successful predecessor check is required.

## Route, keys and initialization

Retain R55's selected Why-only SIGINT mask, one OCaml worker, valid immutable
tags and complete source/native/runtime relation. A published table mutation
must complete with adequate resources, or its escaping failure must not resume
that state. Ordinary preparation failures outside mutations remain permitted.
The mask does not itself establish resource success. There is no application
callback or recursive same-table mutation inside the scalar key/hash operations.
This is the existing mutation guard, not an arbitrary interrupted-table claim.

[R65](../evidence/retained-name-attribute-round65-20261023/checkpoint.md)
supplies a no-wrap counter endpoint F for each shared key owner, including its
initial state and the full charged suffix. Take M=F+1 possible key tags,
conservatively including zero/empty sentinels. Do not add the initial state or
global escape allowance again. A chronological first-invalid-state argument
uses these bounds together with the already reviewed key/constructor relation.

| Private family | Actual key and complete source domain | Initial backing and writer |
| --- | --- | --- |
| Trans.store/bind/fold Wtask, including Driver update and CE/inline/R58 closures | task_tag, Task.Hstask | create63 rounds to64; only Weakhtbl.set/replace |
| Trans.store_decl Wdecl | d_tag, Decl.Hsdecl | memoize63 rounds to64; only replace |
| Trans.on_meta_tds/on_theory_tds Wtds | Stdecl.id, Task.Stdecl.Hcpt (including empty0) | memoize17 rounds to32; only replace |
| Term.t_gen_map hit-local Wty | ty_tag, Ty.Hsty | fresh memoize17 rounds to32; only replace |
| Introduction.ls_of_vs Wid | Ident tag | create7 rounds to16; only replace, values are queues |
| Introduction.find_fresh_axiom Wdecl | ordinary Decl d_tag | create7 rounds to16; its private content hashcons uses `tag _ d=d`, retaining the ordinary tag |

`Weakhtbl.Make` selects Ephemeron.K1.Make, compares and hashes S.tag, and
defines set=replace. Memoize calls its producer before set. Recursive producer
calls therefore finish before the outer replacement search; they are not
callbacks during table mutation. Trans.fold writes at most once at each rewind
node and bypasses goal storage; stores expose functions, not their table.
Trans's metadata wrappers select the Hcpt history id, not a tdecl tag.
Wty is introduced around the type mapper, and receives already tagged types.
Source identities and exact spans retain each of these connections.

These closed tables start empty at creation, even when a closure was used
before registration. Their lifetime M bound covers that initial work. No
unobserved registration-table size is assumed. The table is not exposed to
add, arbitrary reset/copy, iteration callbacks or external insertion. A cache
miss can cause more producer work; this result does not require that a prior
memo lookup hits. Complete producer demand remains with its accepted providers.

## Ephemeron bound, including the native growth stop

Let L0<=64 be the actual initial power-of-two backing, Amax=2^54−1 the
accepted installed ordinary-array limit, and Pcap=2^53 its largest power of
two. For a key universe of size M, define the mathematical bounds

```
B = min(Pcap, max(L0, 4M))
S_completed = max(2B, M)
S_transient = max(2B+1, M+1).
```

All selected applications additionally check B<=Amax, 2B<=2^62−1,
S_transient<=2^62−1 and 8(B+1)<=2^62−1. These are source-derived sufficient
representation conditions, not an adopted language or physical-memory cap.

The simultaneous invariant is proper bucket chains, a size equal to physical
stored cells at completed boundaries, and at most one live binding per tag.
GC can make keys dead without reducing the stored size. Replacement refreshes
an equal live key without incrementing size. If its search reaches Empty it
adds one cell and increments once. The incoming key is retained through the
search and publication. Pure scalar equality cannot raise Not_found or invoke
another writer. An old dead binding may coexist with a later insertion; it
need not be counted as a live binding or dismissed from physical size.

Resize first cleans. No application insertion runs during clean, so every
retained cell was live at entry; later GC deaths cannot increase that set.
At most M cells survive. Clean's decrements cannot underflow: each removed
cell belonged to the proper old table and is visited once. Partially built
list copies are not counted again in h.size. The resulting key/index relation
is preserved by rehash. Intermediate publication is covered by the mutation
guard, not assumed to be an independently reusable table.

Actual growth from L to2L requires both cleaned size>=L/2 and
`2L < Sys.max_array_length` (ephemeron.ml:195–211). Thus a new backing is
at most4M and at mostPcap. The attempted multiplication2L is at most2^54,
which fits the signed OCaml integer even when the allocation test rejects it.
There is no request for a too-large array at the growth stop. Hash masking
by L−1 remains an in-range index because actual backings are powers of two.

Before an insertion, either size<=2L, or the preceding cleanup left size<=M.
One increment therefore gives the stated transient bound. If size exceeds2L,
cleanup occurs even when growth is disallowed; completed size is again<=M.
This closes the size/threshold/doubling induction without bounding cumulative
cache-miss visits by a native integer. Arbitrary weak clearing is allowed.
Searches traverse at most S_completed cells; cleanup/rehash traverses existing
bucket arrays and chains. Their cumulative work is not an array length.

The growth stop matters. Put_Line's Hsty endpoint is4,557,710,563,543,331;
the loose 4M expression exceeds Amax. Applying the source's guarded allocation
instead gives B=2^53, transient size<=2^54+1, and represented scalar operands.
This repairs no installed tool and invents no smaller caller cap. Old and new
arrays can coexist during rehash; 2B bounds those working slots. Old list copies
and garbage awaiting collection are not a cumulative-allocation claim here.
Individual K1 containers have one key and fixed indices. Physical memory,
stack, GC and allocation services retain the established trust boundary.

## Driver, Introduction and dependency containers

Driver.update_task's Hint.create5 rounds to16. The retained configuration has
three immutable driver identities. Its missing-key branch constructs a store
closure then adds once; no selected callback enters the same table before that
add. A failed closure creation adds nothing. At most three cells are retained,
so no growth occurs. This table is distinct from the per-driver Wtask memos.

R61 proves Introduction's private content table and queues empty at the cut,
and bounds one episode by8m axiom/content requests and8m+p variable/queue
requests. Here m is R61's original goal mass, not the key universe M above.
Its E=155/128/68/8/5 episodes already include the one process-global allowance.
Multiply once. The largest content request count is1,416,080; the largest
queue/variable request count is1,452,660. A failed prefix after an append still
consumes its request; no callback in Queue.iter appends, and Found exits without
mutation. Each queue length and increment is bounded by its whole-process
request count. No new count of successful outputs is substituted.

The private content Hsdecl starts with Weak.create5003 and zero allocated bucket
slots. Apply the accepted weak_transfer(5003,0,0,E*8m). Its maximum outer and
bucket envelopes are4,248,243 and2,124,123, with represented growth/shrink
operands. Its tag callback discards the private counter as already established;
ordinary Decl tags are counted separately. Introduction's fresh local Hvs
tables use the accepted variable-write request bound, even if a caller repeats
a key: cells<=E(8m+p), backing<=the next power of two above max(16,E(8m+p)).
The largest such backing is2,097,152. The packet checks the exact five rows.

R58's depends/closure/used/keep maps and tagged metadata sets use immutable
registered identifiers (or symbol records keyed by those identifiers). Each
completed map/set has at most Ident_F+1 keys. A two-input structural envelope
has twice that many nodes. Reuse R67's accepted balanced-tree argument:
`3*bit_length(2*(Ident_F+1)+1)+4` bounds height and rotation operands. Node
allocations are fixed-size. Cardinal/list-length evaluations, including those
evaluated as arguments to disabled debug printing, stay within Ident_F+1;
that value fits signed63 in all five domains. Map values, multiplicities,
term/type traversals and recursive algorithms retain their separate R57/R58/
R61 bounds; key cardinality is not a bound on arbitrary payload computation.

## Scope of the join

The packet exports five applications of each memo family and the additional
Driver, Introduction and R58 container rows. It is conditional on the same
selected source/native/constructor/mutation premises as R65, not a new trusted
capacity assertion. No allowance is renewed and no target execution decides
membership. The new ephemeron transfer is a manual source argument supported
by checked arithmetic; it is not advertised as a Lean theorem.

Epsilon canonical-cache attachment, declaration-validator call-set payloads,
pre-registration failure prefixes and the complete fixed-domain conjunction
remain separate interfaces under #153. General Main and native/current-grammar
coverage, checked whole-rule accounting/correspondence, useful-domain comparison
and final independent review remain #119 work. Nothing changes the Oracle,
toolchain, current admission, production invocation or future #88 obligations.
