# Guarded native Hashtbl prefixes for the selected save

2026-10-20 UTC, Linux x86_64, research #119 / #153; exact base
`22c5d9274ac7fe6ab7797aef378a3bcb4b4afafe`.

The selected OCaml implementation supports a **closed conditional traversal
contract when the shared tables do not resize**. A table's entry binding
visits plus its insertion opportunities bound every reached lookup chain and
iteration, including prefixes interrupted by a nested save. Scalar `size`
is bounded separately. The retained native code excludes a signal save between
the relevant clear stores and between an insertion's publication and size
increment. This supplies the missing native part of the arithmetic no-resize
option in [operational save bounds](retained-why-save-operational-bounds.md).
Actual entry layouts and numeric guards still require the lead's capture join;
this packet does not certify any unobserved table state or complete save capacity.

The [packet](../evidence/retained-why-save-hashtbl-prefix-20261020/README.md)
retains source excerpts, **20 native bodies**, executable byte correspondence,
the arithmetic consumer and its negative boundary checks. These are projections
of retained evidence, with no new native execution or disassembly. Independent
review is pending. No production 88–94 work, Oracle, tools, pins, admission or
PR #121 merge is included.

## Scope and explicit premises

The relevant implementation is OCaml 4.14.2 at
`8eb41f72ded84df884c3671734c947f612091f84`, Why3 at
`9390baf120ef260547dfa14f08e11c890b203d9c`, and the retained Linux `gnatwhy3`
image SHA-256 `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
`Hpn`, `Htn`, `Hpan` and `Hfile` alias `Wstdlib.Hint`; `Hid` and `Hprover`
also use `Exthtbl.Make`, which includes `Hashtbl.Make`. That functor includes
`MakeSeeded` and ignores its seed parameter. Its shared add/replace/find bodies
are the retained native bodies below. This source-to-selected-code join uses
the existing [external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary),
with concrete corroboration of the relevant stores/polls. It is not a universal
binary refinement proof.

The accepted [ordinary-ending control](retained-why-ordinary-ending-control.md)
and [native effect closure](retained-why-native-effect-completeness.md), with
their accepted reviews, supply the one OCaml worker, faithful runtime, fixed
code, classified callback/exception owners and nonreturning SIGINT-save
protocol. They must apply throughout the caller's stated interval. This packet
does not renew a spent callback budget or infer that a captured first-fold
configuration persists automatically to ordinary ending.

For each table the caller supplies:

- The actual four-field Hashtbl layout; a live ordinary bucket array of positive
  power-of-two capacity `C <= 2^54-1`; represented seed and traversal bookkeeping,
  with `1 <= abs(initial_size) <= C`; no forged aliases or unclassified mutator.
- Valid `Empty`/three-field `Cons` cells and key/payload representations. Every
  bucket chain is finite and acyclic. `V0` bounds **the sum of chain lengths over
  all entry buckets**, counting duplicate bindings and shared-tail occurrences.
  Neither distinct keys nor `size` supplies `V0`. Shared entry tails are allowed
  by this guarded theorem; disjointness is unnecessary.
- An independently bounded nonnegative scalar `s0 <= max_int`, and `A` covering
  all possible insertion opportunities in this interval, including failed calls,
  nested saves and additions following caught exceptions. Count replace calls
  as potential insertions unless a separate key-presence argument excludes
  their empty-bucket result. Every newly supplied key/payload satisfies its
  representation contract.
- Only `add`, `replace`, `clear`, lookup, `iter` and `fold` act on the table.
  No `reset`, `remove`, `filter_map_inplace`, `rebuild`, direct `next` write,
  arbitrary callback mutation or unaccounted resumption is admitted by this
  packet. Selected clients and their callback work must be joined, including
  termination/finite cost of key hashing, equality and traversal callbacks.
  The source entry cut must also exclude a suspended earlier rehash or other
  link-mutating operation that could resume inside the interval. A valid
  snapshot by itself does not establish that control property; any already
  started covered insertion must be included in `A`.

Hash/equality domains are integers, identifier tags, or the three immutable
prover strings (`wstdlib.ml:11–22,60–100`, `ident.ml:159–172`,
`whyconf.ml:80–105`). Their source bodies contain no local catch returning from
an interrupted mutation and no table mutator. Scalar/string/custom-operation
and native service contracts retain the accepted actual representation domains.
This is not a claim of arbitrary user-supplied `Hashtbl.Make` safety.

## Native cut points

All addresses are ELF-relative. The packet checks every retained instruction
byte against the identified executable, including its C-call bridge and the
actual write-barrier body. The source excerpts independently bind the stated
operations and specializations.

| Operation | Native fact and consequence |
| --- | --- |
| `clear` | `0x981259` writes tagged zero to size; `0x98127a` tail-calls `Array.fill`. Neither this body nor the valid-argument Array wrapper at `0x953830` polls or allocates. |
| `Array.fill ... Empty` | The C primitive at `0x9ce310` writes the buckets. `Empty` is immediate `1`, so `0x9ce378–0x9ce382` makes the young-block flag zero. Both reference-table growth and the urgent-GC call at `0x9ce407` require that flag; neither is reached. Old values may be darkened under the faithful collector contract, without a pending dispatch. The bridge at `0x9e3fa8` saves runtime registers and jumps to the primitive; it does not process signals. |
| Functor `add` | Hashing precedes allocation; the allocation/pending check is `0x9827e0–0x9827e7`, with GC at `0x982872`. Cell initialization and head publication follow. `caml_modify` at `0x98282d` publishes the head; `0x982832` increments size; `0x982851` tests the resize threshold. No intervening poll exists. |
| Functor `replace`, found | Comparison can poll before modification. The two `caml_modify` calls at `0x982fe1,0x982ff2` update key/data, without changing `next`, allocation or pending dispatch between them. |
| Functor `replace`, absent | The saved old head precedes the allocation poll at `0x98309a–0x9830a1`; GC is at `0x98313a`. Publication at `0x9830ec`, size increment at `0x9830f1` and threshold test at `0x983110` have no intervening poll. |
| Lookup / traversal | `find_rec` polls at `0x9829e4`; `do_bucket` polls at `0x9819e4` and saves `next` before calling the client. These polls can dispatch save; they are not assumed absent. Source `iter`/`fold` cleanup changes the traversal flag and reraises, without replaying a bucket callback. |

`caml_modify` does not call GC (`memory.c:606–667`), but can request collection
through reference-table growth. `minor_gc.c:581–625` distinguishes requesting
minor GC from running it: reserve extension sets the request, and native table
growth uses ordinary allocation. Its failed-allocation route is fatal under
the accepted native owner/configuration contract; it does not return a partial
mutation through a catch. Runtime storage representation and sufficient physical
resources remain external capacity obligations. This argument does not treat
allocation failure as successful saving, nor introduce a no-throw assumption
for allocation or hash calls before the commit.

Thus no caught nested-save exception exposes a half clear or a half insertion
commit on these paths. A signal arriving at an arbitrary OS instruction records
pending work; the application save runs at an admitted runtime dispatch. A
pending save before publication either exits or raises. The mutation bodies
and selected hash/equality leaves have no receiving catch, so their saved
index/head is not used after nested saving has changed the table. The stronger
control result is needed particularly for absent `replace`, which saved its
old head before the allocation poll. Higher application catches remain allowed;
they observe the nested save's committed table state and start a new operation.

## Guard and traversal argument

Let `MAX = 2^62-1`. For a persistent table require

```
s0 + A <= MAX
s0 + A <= 2*C                 if A > 0.
```

The threshold expression `Array.length h.data lsl 1` is represented because
`C <= 2^54-1`. For the bound-shape table, every selected save insertion follows
`clear_only_shape`; the caller may instead use

```
A <= 2*C                     if A > 0
max(s0,A) <= MAX.
```

Here `A` covers **all** save insertions in the joined interval, rather than
just the last complete save. Clear atomically leaves scalar zero: if entry
size is already zero it does nothing, so existing bindings can remain when
size and visits disagree. The theorem therefore still retains `V0`.
For old shapes and checksum tables with no insertion, the resize threshold
guard is vacuous; their actual operation inventory and entry validity are
still required.

Induct over completed commits and failed operation prefixes. Before the first
possible resize, clear only removes array roots. A found replacement modifies
key/data and leaves every link unchanged. An insertion publishes one fresh
cell pointing to that bucket's existing head, so cannot create a cycle; it adds
one binding occurrence and increments scalar size once. No original `next`
link changes. Consequently visits are at most `V0+A`, while scalar size is at
most `s0+A`, or `max(s0,A)` for the clear-before-add mode. These size bounds make
the first supposed resize test false. This proves exclusion by induction; it
does not assume the desired absence of resizing as an unexplained premise.

Every lookup follows a finite suffix of one such chain. `iter` and `fold` visit
at most `C` buckets and `V0+A` binding occurrences per invocation, or a prefix
on exception. Even if a traversal client catches a nested-save exception and
continues, bucket heads can only be cleared or acquire new cells; the old
saved `next` links are unchanged. Each fixed bucket's traversal can therefore
visit only its entry chain plus cells charged to that bucket's insertions.
No scalar `Hashtbl.length` bound is substituted for these visits. Callback
work, repeated traversal **invocations**, string/key comparisons and stack/heap
resources retain their own charges. At most `A` new three-field bucket cells
are needed for these insertion calls, without any new bucket array or rehash
tail array; allocator internals remain separately bounded.

The same simultaneous induction can consume tighter insertion opportunities
from a selected key-presence argument: after a completed insert, a compatible
immutable key remains findable while this operation inventory has no removal
or clear for that table. Before the first hypothesized rehash, key presence
is established by the very native commits above. The argument must count
spurious misses caused by caught signal exceptions. It cannot assume that
every `Not_found` proves a genuinely absent key.

## Selected table interface and residual

The packet's `table-interface.json` keeps every absent numeric input null.
The lead can join the companion attempt-growth inventory without changing
this native theorem:

| Table | Selected operation family and sufficient insertion bound |
| --- | --- |
| Bound shapes | Clear before additions; at most `r*G` add calls, where `r` is the one joined save budget for the covered interval. |
| Old shapes | Clear/read under the selected SV6 route; no old-shape insertion. |
| Checksums | Reads only during save; any earlier checksum-producing phase needs a separate insertion count. |
| Prover IDs | Reads, iteration and persistent add; coarse `r*Astats` or the separately proved structural-prover-domain bound plus spurious/stale miss additions. |
| File/theory status | Reads and persistent add/replace; use the companion initial-missing-key and caught-miss count, or count every mutation call. |
| Goal/transformation status | Reads and persistent replace; use the companion key-domain bound or count all replacement calls. |
| Proof-attempt index / per-goal attempt maps | Save reads/iterates; graft additions before later saves need the companion selected-pair bound. |

This packet does not prove the companion's mutation counts merely by accepting
them. The smallest remaining join is the actual per-table layout/acyclic-chain
and payload certificate, `s0,V0,C`, the complete interval mutation/count ledger
(including the entry control cut), and application of the continuing
native/signal contract. If these numerical guards pass, no new investigation
of interrupted rehashing is needed. A failed
guard leaves that table's prefix result unknown; it does not enlarge its
capacity or silently establish a weaker rehash invariant.

There is concrete reason to preserve that boundary. `resize` publishes `data`
at `0x981826` before relocation. `insert_bucket` returns to its poll at
`0x981684` after each cell, and tail finalization has another loop poll. For an
old chain `x -> y -> z` split into new buckets by hashes `0,16,0` when capacity
grows from 16 to 32, after publishing `x` and `y` but before final tail cuts,
the new roots can traverse `x -> y -> z` and `y -> z`: five visits to three
cells. Other buckets can supply the insertion threshold. This is a source/native
intermediate-state example, not a claimed observation of that schedule in the
five captured processes. It disproves an unrestricted old-binding-count bound;
this packet alleges no observed cycle or actual tool failure and proves no
general interrupted-resize contract.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements unavailable. Timing and validation are in the packet.
No source fetch, native/proof/solver/capture run, GitHub write or CLI-memory
update occurred. The lead owns numeric instantiation, combined review,
integration, issue and durable-memory bookkeeping.
