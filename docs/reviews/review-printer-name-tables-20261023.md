# Fresh SMTv2 name-table review, 2026-10-23

**Accepted with the retained premises at
`6c8af79092bb7ec63b876582f10b94da95a9072b`.** The accepted result bounds the
selected fresh SMTv2 printer's private Hstr/Hid operations, historical suffix
operands, scalar sizes, lookup/rehash visits and individual backing-array
operands. Raw-name byte bound **L remains null**. This is not complete printer
capacity, successful naming semantics or completion of #119 / #153.

The initial review target was `0fb01402da7293749de0a9cc51332348177d356e`.
Source review found an incomplete name-call census. The author corrected its
reasoning and added a source witness before the single independent audit; the
exported numeric result is unchanged. Selected reviewer setting: GPT-6 Astra /
Extra High. Runtime model/effort confirmation and token/cost telemetry are
unavailable. Exact input identities, source ranges, numerical results and
timing are in the [review evidence](../evidence/retained-printer-name-tables-review-20261023/).

## Finding and disposition

The initial argument assigned at most one direct head/variable name to each
term/formula entry. An unsyntaxed nullary value application instead calls
`print_ident` once for its label-map key at `smtv2.ml:421`, and again for its
term at `:443` or `:445`. A name lookup is an opportunity even if it normally
hits Hid; a signal-origin false miss can enter `find_unique`.

The retained ground-signature family makes `unambig_fs` true: V20 returns true
directly, and V26/V26Par's structural inspection encounters no type variable
(`:344–356`). Thus this branch has two direct names and no type-rendering
callback. Since T is at least one, its charge is still at most T+1. Other
entries fit the original name/type allowance. The amended census now says this
explicitly and retains the missing source section. **Confirmed and fixed;
no numerical correction is required.** Acceptance is tied to the amended
freeze, not to the initial census.

The author also added strict range validation to the freezer and checker.
The reviewer independently checked all 22 ranges against the complete source
members, including `1 ≤ first ≤ last ≤ actual line count`. No out-of-file
witness remains in this packet; a matching silently clipped slice would not
have been accepted.

## Call count and source family

The accepted R61 complete returned-field/origin family and R62 printer cut
are reused at their established scopes. The name count depends on their
generated ground signatures and arity bounds, including literal/epsilon,
Introduction, algebraic heads and whole older returns. Initial A/T inventories
alone would not establish these bounds. No new arbitrary transformation family
is admitted by this review.

For each fresh printer, the source census supports

```
C = H[(2S+P)(T+1) + 2(A+1)(T+2) + 8]
F = H(2P+3A+2)
N = 343 + C.
```

The accepted syntax result supplies at most 2S expression entries, including
the two repeated-variable rotation templates. Binder-list printing is charged
separately to P. Ground signatures make `print_par` add no type-variable names;
the accepted affine type templates and absent active `%t`/`%v` paths preserve
the T charge. Deferred definitions contribute their initial parameter header
and later equation/formals once; the unique final goal does not replay bodies
for its second check-sat command. Singleton data groups have at most two
constructors; their sort, constructor, projection and dummy-field names fit
the header allowance. The false counterexample-meta premise excludes the
additional `print_info_model` naming fold.

The factory performs 343 blacklist reservation calls, although only 335
spellings are distinct. Each ordinary `id_unique` entry performs at most one
`find_unique`; all such entries, hits and failed prefixes are counted by C.
Each `forget_id` performs at most one remove on each table, bounded by F.
Hstr has at most N insertion opportunities and Hid at most C. H is charged for
all task nodes, including nodes that print no logical declaration.

The same process-wide E = 3N_roots+e, e≤2, two save-entering callbacks and at
most three saves are retained. They are not renewed for a name, table,
interrupted helper or failed prefix. Per-owner N is a local bound; process
call totals multiply by E once.

## Private ownership and interrupted mutations

`Driver.print_task_prepared` and `Smtv2.print_task` allocate a fresh printer.
Hstr and Hid both use ordinary `Hashtbl.Make`/`MakeSeeded`; Hid is `Id.H`, not
the ephemeron owner `Id.W`. The selected clients do not copy, clear, reset,
iterate, expose or reenter these owners. `printing_info` retains strings and
other information fields, not the name printer. The accepted synchronous
formatter and nonreturning signal-save control remain required. A nested
save's fresh printer cannot mutate the interrupted printer's tables.

The decisive receiving catch is `Ident.find_unique` at `ident.ml:250–254`.
Its covered `Hstr.replace indices base ind` follows a normally returned find
of the same base. Intervening fetch/specname work only reads the private table.
Immutable keys and owner separation therefore make the replacement a hit.
Its branch changes equal key/data fields, without links, size or capacity;
the catch cannot receive a partial resize from this site.

The final Hstr replacement at `:255` can insert, but is outside that catch.
`id_unique` calls it and the final Hid replacement inside its handler body,
outside the protected lookup at `:283–285`. The blacklist iterator adds no
receiving catch. SMTv2's remaining catches either translate Unsupported and
escape, or protect local optional-map work after naming. No selected receiving
catch resumes this owner after an insertion-capable resize failure. That owner
is abandoned, rather than treated as a reusable partially rehashed table.

Conversely, `forget_id` can catch interruptions of either remove and reuse the
owner. A decrement before unlink may leave scalar size smaller than occupancy,
including negative size. Either side of the link store retains finite,
disjoint, correctly routed chains. The proof does not need atomic deletion,
consistent paired deletion or an Hstr/Hid bijection. Every reached size lies
in [-F,W], where W is the table's insertion-opportunity bound.

The actual consumers were checked: lookup, mem and key_index ignore size;
remove uses size−1; absent replacement uses size+1 and the positive capacity
threshold. No selected length/copy/clear/reset/iteration consumer requires
nonnegative size. Capacity drives array extents and indices. Guarded insertion
publication/increment and same-key replacement are reused from the retained
native-prefix result. Its separate no-remove/no-resize theorem is not imported,
and no new native remove atomicity claim is made.

A completed inplace resize visits each old cell once, preserves forward order
within its original chain, and cuts final tails to restore disjoint routing.
A partial double-size rehash can publish two roots sharing an old tail; its
root occurrences are bounded by twice the original cells. The three-cell,
five-occurrence example correctly prevents treating that partial layout as an
ordinary completed table. No later rehash consumes the abandoned layout.

## Historical suffix bound and native operands

The monotone mathematical history G contains published Hstr keys and virtual
suffixes at completed base-cache writes. For every positive cache k at base b,
G contains b1 through bk, even after deletion. This avoids the false occupancy
bound: one remaining `x→5` binding can start its next fetch at six.

During the n-th `find_unique`, the pre-call history has at most n−1 strings.
Successive membership tests and the cached prefix cannot cross n: doing so
would require n distinct positive suffix strings already in that history.
Retreat decreases toward one. A cache write adds at most its final virtual
candidate; normal completion publishes that same string. If a caught
`Not_found` follows the cache write, the fallback publishes the original base,
which was already present. A failure before that write adds at most the base.
Removing keys or resetting cache values to zero only weakens the obligations.
Digit-ending input bases and overlapping suffix families do not invalidate the
per-base injectivity or the bound of one new history string per call.

Therefore every cached suffix, tested index and reached successor/predecessor
result is in [0,N]. Lookup and removal visits are bounded by the table's
insertion opportunities; fetch has at most N+1 membership tests. The exported
quadratic totals are mathematical counts, not native accumulating counters.

All five retained cases satisfy N, F, size arithmetic, capacity doubling,
threshold and individual array guards. Put_Line is the largest: C is
9,861,957,430,080, N is 9,861,957,430,423, and each table's capacity upper bound
is 8,796,093,022,208. These are conservative representation bounds, not observed
allocations or a physical-memory guarantee. No aggregate RAM gate is added.

## Evidence scope and remaining work

The single independent audit passed in **1.568308377 seconds** on Linux x86_64.
It read exact committed bytes for all author packet files, fourteen provider
files, two archives and eight complete source members; checked all 22 witness
ranges and blacklist counts; and independently recomputed all five C/F/N and
table rows, header inequalities, capacity boundaries and null-L behavior.
The author small model was read, not replayed. Its 1,763 transitions and 385
final states remain finite regression evidence, not proof of the induction.
No author/predecessor checker, native target, solver, proof, capture, new
disassembly or nested agent ran. No failed or aborted reviewer audit preceded
the successful pass.

The source reasoning depends explicitly on the identified Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml 4.14.2
`8eb41f72ded84df884c3671734c947f612091f84` behavior, accepted source/native
relation, scalar/string/hash/equality and runtime services, valid typed fields,
immutable keys, guarded commits, private-owner separation and first global
identifier-violation prefix. This is reviewed mathematical reasoning, not a
new machine-checked source simulation, recovered build attestation or universal
binary refinement theorem. The separate library/callback six-owner audit is
not repeated or extended here.

L still needs an origin attachment for every selected declaration/signature,
type-head, constructor/projection, binder/formal/free-variable and generated or
whole-old-returned identifier. The proposed byte formula
`max(22,5,2(L+5)) + decimal_digits(N)` is conditional on that complete attachment;
saved-proposition atom maxima and captured printed names do not provide it.
Other private printer maps, attributes, formatter/Buffer and complete output
bytes, later exception rendering, global composition and current-grammar
coverage remain separate obligations.

Caught failures can leave duplicate logical names or inconsistent name caches.
Neither this review nor the candidate assumes that name uniqueness or successful
printing semantics survives those failures. That unresolved semantic scope must
remain explicit when the component is composed; no no-signal or successful-print
premise is silently substituted. Oracle, tools, pins, production source and
admission are unchanged. #88–94 remain unstarted and PR #121 remains draft and
unmerged. Integration, issue and memory bookkeeping remain with the lead.
