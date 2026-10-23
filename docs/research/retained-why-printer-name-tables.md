# Fresh SMTv2 name tables and historical suffix bounds

2026-10-23 UTC, #119 / #153. **Candidate source argument, pending independent
review.** The selected SMTv2 printer's fresh `Ident.ident_printer.indices`
(Hstr) and `values` (Hid) have bounded table operations, finite lookup/rehash
traversals and represented suffix/table integers under the retained premises.
A complete raw-identifier byte bound is still an explicit `L` interface; this
packet does not close name bytes, the complete printer, or #119.

The [packet](../evidence/retained-why-printer-name-tables-20261023/README.md)
freezes base `7cd4282223`, the accepted [R62 printer
cut](../reviews/review-printer-demand-20261023.md), [syntax
argument](../reviews/review-printer-syntax-20261023.md), R61 entry dimensions,
and the exact Why3/OCaml source members. The source theorem below is mathematical
reasoning for review. The Python programs check identities, arithmetic and small
models; they are not a machine-checked OCaml simulation.

## Boundary and inherited premises

The interval is each selected `Driver.print_task_prepared` invocation through
return or escaping exception. `smtv2.ml:1030–1059` makes a fresh information
record with a fresh `ident_printer ()` at line 1036. The factory uses
`Hstr.create 1997`, reserves its fixed blacklist, then uses `Hid.create 1997`
(`ident.ml:262–268`). Both ordinary strong tables start with capacity 2048.
Hid here is `Id.H`, not `Id.W`: `ident.ml:165–173`, `wstdlib.ml:60–100` and
`exthtbl.ml:40–43` attach both tables to `Hashtbl.Make`/`MakeSeeded`. No
Ephemeron transfer applies to them.

Retain the accepted fixed-input/source-origin, valid typed-field, immutable-key,
first-global-identifier-violation, debug-control, false-counterexample-meta and
single-final-goal premises. Native scalar/string/hash/equality services and the
[external source/native behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
remain required. The identified implementation follows Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml 4.14.2
`8eb41f72ded84df884c3671734c947f612091f84` for the reached table, allocation,
field-store, callback and exception behavior. This is not a recovered build
attestation or a new binary refinement proof.

The accepted single-worker/nonreturning signal-save protocol is used throughout,
with one process-wide `e ≤ 2`, two save-entering callbacks, at most three saves,
and the already accepted `E = 3N_roots + e` printer opportunities. None is renewed
for a table, name, failed prefix or helper. A nested save either exits or unwinds
the interrupted continuation; it does not return normally to stale mutation
locals. Its save printers are separate owners. This SMTv2 name printer is
neither published in the session nor in `printing_info` (`smtv2.ml:841–852`);
the selected output callbacks do not invoke it reentrantly. Formatter callbacks
within this invocation are synchronous, under the accepted selected printer
control. No `duplicate_ident_printer`, `forget_all`, `string_unique`, iteration,
copy or arbitrary client table mutation occurs on these two owners.

The private-table argument below includes the actual receiving catches. It does
not assume that every interrupted operation abandons the printer. It uses the
retained guarded insertion commits from the
[Hashtbl native-prefix result](retained-why-save-hashtbl-prefix.md), specifically
the no-poll publication/size-increment region and the same-key found replacement.
It does **not** import that result's no-remove/no-resize theorem. No new native
remove-body or disassembly check is claimed. Deletion is handled conservatively
at either side of its scalar/link stores, so its atomicity is unnecessary here.

## Actual name and deletion opportunities

Use R62's S/P/H/A/T: exposed formula mass, source slots including formals,
task-chain nodes, signature arity, and type mass. They include the accepted
returned-field/origin argument rather than only observed printer trees. The
selected reachable signatures and printed type fields are ground. Original
polymorphic declarations skipped by syntax are skipped before their headers;
no new polymorphic data/signature writer is selected. This uses R61's complete
field-preservation statement at `retained-why-printer-entry.md:202–213`, not just
its initial inventory: generated signatures are ground with arity at most two;
selected epsilon/literal heads are nullary and Introduction's heads are nullary.
Algebraic constructor/projection signatures fit that two-argument allowance.
Whole-old returns retain their previously established signature origin. Thus the
retained A (seven in all rows) bounds these generated headers as well as original
ones; no arbitrary epsilon closure over P free variables is being charged to A.
Consequently `print_par`
adds no type-variable naming calls in this family. The accepted type templates
are affine, so rendering a type of mass at most T makes at most T name calls.
No active `%t` or `%v` logic template creates an additional type-rendering path.

Every `id_unique` in this module occurs in `print_ident`, `print_tv` or
`print_var` (`smtv2.ml:237–243,287–289`). There is no supplementary per-call
sanitizer. A conservative count per logical declaration is:

| Source work | `id_unique` upper bound |
| --- | ---: |
| At most `2S` term/formula entries; each costs at most T+1 names, including the nullary value-application case below | `2S(T+1)` |
| Quantified/let binder slots printed by ordinary body traversal | `P(T+1)` |
| Parameter/definition headers, including the parameter declaration plus deferred equation/formal lists in incremental mode; or one data group with at most two constructors, each of arity at most A; type declarations | `2(A+1)(T+2)+8` |

An unsyntaxed nullary **value** application prints its head once to obtain the
label-map key (`smtv2.ml:421`) and again for the actual term (`:443` or `:445`).
It therefore costs two direct name calls, including a failed prefix that reaches
only the first. Under the retained ground result-type family, `unambig_fs`
returns true: V20 does so directly; V26/V26Par's `inspect` encounters no Tyvar
and its structural `ty_all` traversal returns true (`:344–356`). The second
print consequently takes line 443, without the type annotation at lines 445–446.
Its two names fit T+1 because T is at least one. Other term/formula entries have
at most one direct variable/head name and one explicit type of mass T; binder
list names are charged in the separate P row. No claim of one direct name for
every printer entry is needed. This corrects the initial census without changing
the equation or any exported numeric bound.

For a deferred definition the initial parameter header has at most one head
name and `(A+1)T` type names. Its later equation has one head name, at most A
formal names in each of two lists, and at most `AT` formal-type names. Their
sum is `2 + 2A + (2A+1)T`, below the header allowance. An ordinary definition
has one head, A typed formals and one result type, also below it. A data header
has two sort-name uses, at most four constructor-name uses, and at most `2A`
field-name uses plus `2AT` type-name uses, bounded by `6+2A(T+1)`. Selected
data type parameters are empty. Dtype makes at most two name calls.
The body slot allowance may count formals again; this is safe overcounting.

The body count includes triggers and both Boolean branches. The two rotation
templates' extra argument visits are already in `2S`. General pattern/subject
names are excluded by the accepted Boolean-case family. `has_quantification`
and the V26Par definition guard open variables but do not print names.
`print_info_model` takes its empty-result branch because the accepted
counterexample meta is false; collection itself does not name identifiers.
Deferred bodies are printed once at the unique final goal, and no check-sat
command replays them. Unsupported or escaping failures shorten this work.

Charge every H task node, even those with no logical declaration, and define

```
C = H [(2S+P)(T+1) + 2(A+1)(T+2) + 8]
F = H (2P+3A+2)
B = 343
N = B+C.
```

C bounds all `id_unique` entries, including hits and signal-origin false misses.
F is the accepted R62 fresh-slot/field allowance and bounds all `forget_id`
entries: each actual `forget_var` is on an opened let/quantifier/definition
slot, with dummy data fields adding slack. It does not assume each forgot name
was inserted, or that name uniqueness survived a caught exception. The blacklist
has exactly B reservation calls, 335 distinct spellings and maximum length 22;
count calls, not distinct spellings. Each name miss calls `find_unique` once,
so N bounds every successful or failed `find_unique` entry on a fresh printer,
including initialization. Per process there are at most E such owners; local
suffix bounds use N, while cumulative call counts use E times the local count.

## Strong-table preservation through caught failures

`Hashtbl.Make` starts with disjoint, finite, correctly routed chains. Keys are
immutable strings or immutable identifier tags; hash/equality invoke no name-table
mutator. Prove this structural invariant inductively at every later reusable
client entry, separately from scalar `size` and separately from a consistent
bijection between Hstr and Hid.

1. Lookup has no mutation. Signal-origin `Not_found` may cause a false miss; it
   supplies no arbitrary return value. Both `id_unique` and `find_unique` may
   therefore take their fallback branches on a present key.
2. Crucially, the `Hstr.replace indices base ind` at `ident.ml:252` is reached
   only after `Hstr.find indices base` returned normally at line 251. The
   intervening `fetch`/`specname` work only reads this same private table.
   No callback owns it. Thus this replacement is a **hit**, even after earlier
   caught failures. Its OCaml branch changes equal key/data fields and no link,
   scalar size or capacity (`hashtbl.ml:431–446`). A caught exception before or
   after it leaves a structurally valid table. In particular, the broad catch
   at `ident.ml:254` cannot receive an interrupted resize from this site.
3. The insertion-capable Hstr replacement at line 255 is outside that catch.
   `id_unique` calls `find_unique` and `Hid.replace` in its `Not_found` handler
   (`:282–289`), so that handler cannot catch exceptions raised by either call.
   The blacklist iterator adds no receiving catch. The selected SMTv2 catches
   either translate Unsupported and escape, or are local optional-field catches
   after name printing; none resumes this printer after an insertion/resize
   failure. Thus every failed insertion-capable operation which reaches a
   partial resize abandons this private owner. A later printer creates new tables.
4. `forget_id` does catch failures from both removes (`ident.ml:293–298`).
   `remove_bucket` decrements scalar size and then bypasses a cell at a root or
   predecessor link (`hashtbl.ml:364–379`). Each possible prefix either leaves
   the old chain or skips a suffix's first cell. Neither creates a cycle, shares
   a previously disjoint tail with another bucket, changes a remaining key's
   route, nor changes a cached value. Allow a decrement-before-unlink prefix
   to be caught and reused. Allow Hstr removal to finish while Hid removal does
   not. Neither consistency nor atomic paired deletion is needed.

Completed resize starts from disjoint chains, makes a doubled array, and
redistributes in old-chain order (`hashtbl.ml:115–152`). There is no ongoing
traversal flag on these owners, so this is the inplace branch. During relocation,
each link points forward in its original chain; each cell's original successor
is saved before links are changed. Each old cell is visited once. Doubling
splits each old bucket into at most two new buckets. Until final tail cuts,
new roots may share an old tail, but their total occurrences are at most twice
the old number of cells. Completion cuts tails and restores disjoint correctly
routed chains. A failed prefix has finite work from that valid input and is
abandoned by item 3. There is no second rehash of an interrupted intermediate
layout. The packet includes the three-cell/five-occurrence counterexample to
incorrectly treating a partial resize as a completed table.

Only the final Hstr replacement can allocate a new bucket cell, at most once
per `find_unique`. Hid has at most one insertion-capable replacement per
`id_unique`. Hence Hstr has at most N cells and Hid at most C cells at reusable
entries; each failed resize has at most twice these published root occurrences.
Duplicate logical names, stale Hid values and spurious misses do not increase
the insertion-opportunity budget. They do preclude an unqualified name-uniqueness
or successful-printing semantics conclusion; no such conclusion is made here.

## Scalar size, capacity and each actual consumer

For a table with W insertion opportunities and at most F remove opportunities,
starting from zero, every reached scalar size lies between `-F` and W.
The upper bound uses the retained guarded publication/increment behavior; the
lower bound needs only at most one decrement per remove invocation. A caught
remove can leave size different from reachable cells and even negative. We do
not repair it by assuming nonnegative size or size equals occupancy.

The actual clients never call `length`, `clear`, `copy`, `reset`, `iter` or
`fold` on these tables. `find`, `mem` and `key_index` ignore size. Remove uses
only `size-1`; an absent replace uses only `size+1` and
`size > Array.length data lsl 1`. Negative size merely makes that positive
threshold test false. Array indices use the positive power-of-two capacity;
array extents use capacity, never size. Thus `max(W,F) ≤ 2^62-1` covers all
size arithmetic, including every one-step result; no nonnegative premise is
smuggled into a generic consumer.

Let `cap(W)` start at 2048 and double while `W > 2*cap`. An actual growth from
capacity c requires the current size greater than `2c` and therefore `W > 2c`.
Inductively every allocated capacity is at most `cap(W)`. Check also
`2*cap(W) ≤ max_int` and `cap(W) ≤ Sys.max_array_length = 2^54-1` for the
selected platform. These bound the threshold shift, the attempted doubling,
array-loop/index operands and both the bucket array and rehash-tail array.
The array object itself has `8*(cap+1)` bytes including its header.

All five isolated per-owner integer/array guards pass. The largest local case
is Put_Line: C = 9,861,957,430,080, N = 9,861,957,430,423 and capacity upper
8,796,093,022,208 for each of the two tables. These deliberately coarse upper
bounds are **representation checks**, not allocations observed in a run or a
physical-memory guarantee. Cumulative operation counts and ghost-set cardinalities
are mathematical accounting; no source machine counter accumulates their sums.
No aggregate RAM or elapsed-time admission gate is introduced.

## Linear history bound for `find_unique`

Current occupancy alone is insufficient: reserve `x` six times, then remove
`x1` through `x5`; the remaining binding is `x -> 5`. Its next search starts
from 6 despite occupancy one. A bound based only on currently live names would
miss this cached operand.

For a single printer maintain a mathematical, monotone history set G of strings.
Add every final replacement key to G when published. When a base-cache write
at line 252 is reached with positive index k, additionally reserve the **virtual**
string `base ^ decimal(k)` in G, even if a caught exception prevents that
candidate from being materialized or subsequently published. Maintain:

- every currently stored Hstr key belongs to G;
- if a binding for base b has nonzero cached value k, then every string
  `b^decimal(1), …, b^decimal(k)` belongs to G;
- after n `find_unique` opportunities, `|G| ≤ n` and every cached value is
  nonnegative.

The invariant is initially empty. Fixed blacklist spellings contain no spaces,
and sanitized names contain only ASCII letters, digits and underscores.
`sn_decode` consequently always selects `SNword` (`ident.ml:113–116`); the
quote-repetition `String.make ind` branch is unavailable. Decimal suffix
formation is injective in positive indices for each fixed base.

Consider the n-th call. A missing base, including a signal-origin false miss,
follows the fallback and may add only that base string. Otherwise its cached
value k has the complete historical prefix through k. `fetch` first tests k+1.
If present, `advance` tests increasing consecutive candidates. Every successful
membership test contributes an already-published string to G. No tested index
can exceed `|G|+1 ≤ n`: crossing that point would require distinct strings for
all indices 1 through n in a pre-call history of cardinality at most n−1.
If the first candidate is absent, `retreat` decreases toward 1; it never
underflows and never exceeds the initial candidate. When it stops at j>1,
either j≤k (whose complete prefix is already historical), or j=k+1; adding
the virtual candidate supplies the only potentially new prefix member.
The advance case likewise has the historical prefix through j−1 and adds j.
Thus a reached base-cache write preserves the prefix invariant.

Each entire call adds **at most one** new history string, not two. With no
caught exception after the base write, its virtual candidate and final key
are the same string. With such an exception, the final key is the original
base, which was already present when the guaranteed-hit base write was reached.
An exception before that write has created no virtual string, so the fallback
adds at most the base. This also covers failed prefixes before the final write,
and an abandoned final insertion/resize prefix after key publication. Resetting
a binding to zero or removing it weakens the cached-prefix obligations; it does
not erase G. The argument applies even when input bases themselves end in digits
and their suffix families overlap.

Therefore all cached suffix values, tested indices, and reached `succ`/`pred`
results are between zero and N. The first supposed integer overflow is excluded
by `N ≤ max_int`, under the retained first-violation semantics for the separate
global identifier counter. A `fetch` performs at most N+1 membership tests;
including the final `specname`, charge at most N+2 candidate constructions.
Whole-owner bounds are `N(N+1)` mem calls, `N(N+2)` specname calls, N Hstr finds,
at most 2N Hstr replacements, C Hid replacements and C+F Hid finds, plus F
removes for each table. Every reached lookup traverses at most its insertion
opportunity bound. These establish finite source work, conditional on the
named scalar/hash/string services; they are not time or aggregate allocation
limits, and do not assign the quadratic totals to native counters.

## Raw-name byte interface and remaining attachment

Define L as a byte bound for **all identifier strings at the R61 printer entry
which can reach name printing**: declaration heads, constructor/projection
heads, signature and term type heads, binder/formal/free variable identifiers,
and all selected original/generated/whole-old-returned objects. Opening clones
preserve `id_string` (`ident.ml:209–215`, `term.ml:739–833`). The only new raw
spelling inside this selected printer is `constructor.id_string ^ "_proj"`
(`smtv2.ml:884–886`), adding five bytes. The excluded general-case subject and
wildcard paths do not add a hidden name origin.

With that attachment, the sanitizer's source maps each byte to at most two
ASCII bytes and substitutes `zilch` for the empty string (`ident.ml:307–351`).
It produces no whitespace. Thus a conservative bound for every base, including
the unsanitized fixed blacklist, and for every candidate is

```
M = max(22, 5, 2(L+5))
name_bytes ≤ M + decimal_digits(N).
```

The callable transfer checks `L+5` and this final bound against the selected
`max_string_length = 2^57-9`. Decimal conversion has a represented nonnegative
integer operand, so there is no quote-sized allocation. Candidate-name lengths
bound string hash/equality operands, stored Hstr keys and Hid string values.
The whole formatted request, formatter counters, other information maps and
attribute owner remain separate components.

**L is deliberately null in every retained case.** The accepted saved-proposition
atom envelope does not supply all declaration/signature/context head spellings.
Closing L requires a complete origin attachment for those initial names, each
R61 generated spelling and whole-old-return family, followed by a maximum of
those origins. Merely enumerating printed formula atoms or using the largest
captured name would not cover the missing fields and future prefixes. This
packet exports the exact formula and guard but does not assert a numeric name
byte result until that attachment is supplied. No additional valid-state,
no-exception or successful-print premise is substituted for it.

## Verification and round record

The focused checker freezes fourteen provider files, two archives and eight
complete source members; it requires every witness range to satisfy
`1 ≤ first ≤ last ≤ actual source line count`, with negative-boundary checks.
It verifies the blacklist, all five arithmetic rows,
missing-premise/null-L behavior and string-guard negative boundaries. Its small
model explores caught `Not_found` stages and arbitrary deletion subsets through
four name opportunities, including digit-ending bases. It also exercises the
occupancy counterexample, a partial-rehash shared tail and deliberately
non-atomic deletion size drift. Those finite examples challenge the new argument;
they do not prove its universal source correspondence.

Selected author setting: GPT-6 Astra / Extra High. Runtime model/effort
confirmation and token/cost telemetry are unavailable. The packet retains
measured focused-check elapsed time and scope. No native target, solver, proof,
capture, predecessor checker, subagent, GitHub or CLI-memory action ran. Oracle,
tools, pins, admitted language and production sources are unchanged. The lead
owns independent review, integration, source-length closure and issue/memory
bookkeeping. This author commit references #119 and #153 without closing either.
