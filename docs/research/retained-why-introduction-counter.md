# Introduction hashcons counter: value irrelevance

2026-10-18, Linux x86_64, bounded source analysis for
[#119](https://github.com/berkeleynerd/silver/issues/119), based on integration
`6180f77708e9443f14f7bf78fca19a34be973531`.

**Under the retained relevant-source/runtime premise, the private
`Introduction.Hsdecl` counter needs no natural-number no-wrap bound for
correctness.** Its only value consumer discards the integer; OCaml
defines its increment modulo the machine integer range without failure.
Wrapping this particular private value cannot alter a declaration, hash,
equality result, weak-table operation, exported statistic, branch or output.
This resolves the counter-value gap identified by the
[accepted selected-driver envelope](retained-producer-driver-envelope.md)
and its [review](../evidence/retained-producer-driver-envelope-20261018/review.md).
It does not establish an event count, structural traversal bound, weak-table
capacity or completed transformation/printer capacity.

The [offline packet](../evidence/retained-why-introduction-counter-20261018/README.md)
pins the retained sources, adds complete interfaces and the exact OCaml
integer contract, and reproduces the consumer inventory and boundary
arithmetic. Source semantics and consumer exhaustiveness are inspected
arguments, not machine-checked consequences of the textual checks.
The unchanged relevant-behavior premise joins Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml 4.14.2 revision
`8eb41f72ded84df884c3671734c947f612091f84` to the selected installed tools.
This does not recover the unavailable historical SPARK source archive or
change an external-tool pin.

## Complete counter consumer trace

`src/util/hashcons.ml:31–55` seals each `Make` result with signature `S`.
That signature exposes only `hashcons`, `unique`, `iter` and `stats`.
The instance's `next_tag = ref 0` is local to its functor application; neither
the reference nor a counter accessor is exported. Its complete occurrences
are the initializer at line 37, reads passed to `H.tag` at lines 42 and 48,
and increments at lines 44 and 49. `Hashcons` opens no alternative module
that shadows `Stdlib.incr`.

| Operation | Counter effect | Other behavior |
| --- | --- | --- |
| `hashcons d` | Read for `H.tag`; increment iff `o == d` after `WH.merge` | Return the merged declaration |
| `unique d` | Read for `H.tag`; always increment | Return the tagged declaration; no table insertion |
| `iter f` | No read or write | Delegate to `WH.iter f htable` |
| `stats ()` | No read or write | Delegate to `WH.stats htable` |

For this instance `introduction.ml:33–52` sets `H.tag _ d = d`.
The integer is neither stored in the declaration nor captured by another
closure. The `H.equal` and `H.hash` closures at lines 36–49 use declaration
nodes, proposition kind/name/attributes/location, strict term comparison and
strict term hashing; they do not capture or read `next_tag`.
`Weak.Make` takes a `Hashtbl.HashedType` argument (`weak.ml:98`), whose
available operations are equality and hashing, so `H.tag` does not enter the
weak-table algorithm. `find_or` hashes its declaration argument, checks saved
hashes, and compares candidate declarations (`:272–290`); `merge` returns an
existing object or inserts and returns the supplied declaration (`:293–294`).

The same-object-hit concern is real: the existing object can be physically
identical to the supplied `d`, making `o == d` true without a new declaration
or table entry. The conclusion here does not change that increment rule or
replace it with a miss count.

The only local use of the result module is `Hsdecl.hashcons d` in
`find_fresh_axiom` (`introduction.ml:175–186`). Its callers occur at lines 219
and 328, after proposition construction. The merged declaration then feeds
known-map membership, a separate `Wdecl` table and declaration queues; none
receives the discarded integer. No call to this instance's `unique`, `iter`
or `stats` exists in the complete introduction implementation.

`introduction.mli` exports introduction functions and transformations, but no
`Hsdecl` module, raw functor result, tag function, counter or accessor. Thus
external aliases and `open Introduction` cannot expose the instance through
the typed interface. The retained 293 implementation/parser-file scan finds
no `Introduction.Hsdecl` consumer. The additional complete-source interface
join uses the already recorded Why3 archive identity. The argument concerns
the selected ordinary source/runtime behavior; arbitrary unsafe heap
inspection is not part of that launch.

`WH.stats` reports table length, live-entry count and bucket-length statistics
(`weak.ml:364–369`); it never reports `next_tag`. `WH.iter` visits table values
(`:149–156`). Neither operation obtains a counter indirectly through `d_tag`,
because introduction's identity `tag` leaves that field unchanged. There is
no introduction debug printer or statistic callback exposing the counter.
Transformation debugging prints tasks/terms (`trans.ml:63–84,338–351`), which
carry the original declaration tags, and selected debug/save routes are off.

## Separation from the real declaration identities

`open Decl` precedes the local `module Hsdecl` in introduction. The latter
shadows the same-named `Decl.Hsdecl`; it does not replace or share that
instance. Every evaluation of `Hashcons.Make` creates its own reference and
weak table. The seven applications in the retained implementation inventory
are attributes, types, program types, core declarations, theory declarations,
tasks and introduction declarations. Sharing the input type `decl` does not
share their mutable counter cells.

In particular, `decl.ml:340–419` still tags a fresh record with
`Weakhtbl.create_tag n`; `d_hash` and the declaration maps/weak tables consume
that real `d_tag`. `Weakhtbl.tag_hash` even asserts that it is not the dummy
tag (`weakhtbl.ml:56–58`). Those identity ranges remain required. Introduction
returns existing declarations from that construction path; it does not
overwrite their tags with its own private counter. This result exempts no
other Hashcons instance, identifier, semantic occurrence count, table index,
buffer length or printer counter.

## Defined increment and the irrelevance argument

The exact OCaml `stdlib.mli:323–327` specifies that integer operations are
modulo `2^Sys.int_size` and do not fail on overflow. `succ x` means `x + 1`
(`:341–342`); `incr` is equivalent to `fun r -> r := succ !r`
(`:1242–1244`). `stdlib.ml:243` binds it to primitive `%incr`.
These are defined OCaml integer operations, not C signed-overflow reasoning.
The runtime representation (`runtime/caml/mlvalues.h:69–80`) keeps every
integer an immediate value, with range `-2^62 .. 2^62-1` on the retained
64-bit host. The reference remains one fixed cell; no arbitrary-precision
counter or growing numeral is introduced.

Let `c` be any valid machine integer and `T` the instance's weak-table state.
For a fixed declaration argument `d`, `H.tag c d = d` for every `c`.
Consequently the hash, equality calls, merge result `o`, table updates and
test `o == d` depend on `T` and `d`, never on `c`. If the test is true the
next state is `(succ_mod c, T')`; otherwise it is `(c, T')`. The returned
declaration is the same in both cases for any starting `c`.
`unique` similarly returns `d` for every `c`; `iter` and `stats` depend only
on `T`. Projecting away `c` therefore preserves each operation's outputs and
table effects, and induction preserves that relation over every sequence of
these operations. A collection can alter the weak table, but the counter
does not alter the object graph or immediate-value classification; the same
argument applies to the same permitted collection schedule. No earlier
no-collection interval needs extending for this conclusion.

For `m = 2^62`, the signed successor maps `m-1` to `-m`, preserves the odd
immediate encoding, and returns to zero after `2m = 2^63` increments from
zero. Every state is representable; no trap, invalid tag, negative length or
index is created by this value. Because it represents no observable identity
or cardinality, this defined wrap loses no required semantic information.
This is not permission for a relevant identity/count to wrap, and physical
resource trust is not used to waive a representation condition.

## Selected launch and the remaining event interface

The accepted launch remains fresh `--proof per_check`,
`--steps 0 --timeout 0 --counterexample off`, automatic `cvc5,z3,altergo`,
serial scheduling, replay/manual/debug-save routes off, private drivers,
fixed input/import bytes and
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. The added socket/server and exact
pathname/environment constraints remain those of the accepted
[registration record](retained-producer-fixed-tail.md#exact-launch-and-endpoint).
The dispatch upper bounds remain 153 registered tasks, 459 task/driver pairs
and 6,120 outer directives over five separate processes.

Z3 directly selects `introduce_premises`, whose recursive introduction path
can reach `find_fresh_axiom`. Cvc5/Alt-Ergo select
`counterexamples_dependent_intros`; with counterexamples off its branch is
`remove_unused_from_context`, not `dequantification`
(`prepare_for_counterexmp.ml:15–31`). The separate `spark_simpl` composition
also references `Introduction.simplify_intros` (`gnat_trivial.ml:16–21`), and
the introduction module registers additional transforms. The irrelevance
argument holds whenever these functions reach the same instance; it does not
claim that the finite outer-directive count bounds their recursive work or
that Z3 is the only possible indirect caller throughout the process.

The exact next interface is about operations, storage and traversal:

- Let `A` count all `find_fresh_axiom`/`Hsdecl.hashcons` entries over a complete
  selected process lifetime, including repeated arguments and same-object
  hits. Each such entry causes one `WH.merge` and one top-level `H.hash`.
  There is no requirement to prove `A < 2^62` for this discarded counter.
- At entry `j`, let `b_j` be the captured weak-bucket length in `find_or`.
  Its increasing loop visits each index at most once, so its number of
  `H.equal` calls is at most `b_j`, and the total is at most `sum_j b_j`.
  These are allocated bucket lengths, including cleared slots, not merely
  live-entry counts or distinct declarations.
- Bound strict-term hash work for each supplied formula and strict-term
  comparison work for each candidate pair. `t_hash_strict` and
  `t_equal_strict` call structural traversal (`term.ml:536–539`); shared DAG
  size, number of outer transforms and the retired counter value do not
  bound unfolded visits. The reached hash combination arithmetic remains
  modular bucket hashing with equality checked separately.
- Bound the `WH` backing arrays/buckets and growth arithmetic, `find_fresh_axiom`'s
  separate `Wdecl`/queue lifetime, other introduction caches, declaration
  construction and all retained real tag/count operands across the same
  calls. The initial table capacity 5003 is not a maximum.

To discharge those obligations, a later pre-admission composition needs a
computable source-linked majorant of the generated premise events, bucket
backing lengths and structural visits for every allowed preparation sequence.
The accepted call envelope supplies only its finite outer domain. No such
majorant, post-registration allocation bound or traversal closure is claimed
here. Every transformation branch, numeric origin, printer/buffer/filename
limit and subsequent server/solver/result/timing/session join remains open.
Solver success is neither an admission test nor automatic discharge evidence
for these missing conditions.

Selected worker model/effort: GPT-6.1 Sol, Extra High; independent runtime
confirmation and token/cost measurements are unavailable. The packet records
the actual inspection/replay interval. Work used source reads, bounded
read-only source downloads, static symbol enumeration and offline checks;
no producer/prover target,
native build, proof, audit or full suite ran. Frozen predecessors, production
configuration, admission and Oracle are unchanged. Parent review and
integration remain the next boundary.
