# Installed Re representation for canonical answer parsing

2026-10-23 UTC, #119 / #153. This attaches the selected compile/search owners
of the installed `gnatwhy3` to the canonical parser bounds from
[R71](retained-why-canonical-parser-capacity.md). The installed implementation
differs from the retained Re reference: it has a packed mutable Hash_set,
three-field working area, two-field positions owner, eleven-field compiled
regexp and a narrower Str Not_found trap. The argument below handles those
differences directly. Matching semantics, ordinary physical-memory/stack
sufficiency, and the established callback/runtime boundary remain premises.
There is no aggregate resource admission gate and no claim about raw backend
files, startup, the canonical directory guard or whole-process capacity.

The [packet](../evidence/retained-re-native-correspondence-20261023/README.md)
retains exact named-function bodies and data from the installed Linux x86-64
ELF: 24,561,432 bytes, SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
This is an operation/operand correspondence, not identification of an upstream
Re version. No target, compiler, solver, Re engine, native capture or predecessor
checker/model was executed. R71's successful fixed-input/span evidence is reused.
The one global `e<=2`, two save-entering callbacks and three saves are unchanged.

## Selected route and representation changes

Addresses refer to the full bodies in `native.json` and the corresponding
named `.txt` files. The packet's new checker verifies code/data/input identities,
selected instructions/calls and the numerical inequalities. The structural and
exception arguments are review obligations; byte identity alone does not prove
them.

| Owner / selected operation | Installed witness and consequence |
| --- | --- |
| Str compilation | `compile_regexp_445` at `9274e0` calls `Emacs.re_no_emacs_605`; its regexp has two lazy fields. Only search field1 is forced by this parser. |
| Search route | `search_forward_689` → `Core.exec_594` → `exec_internal_inner_1338` → `Compile.match_str_1830`; the separate Search module is unselected. |
| Compiled regexp | `mk_re_1838` at `9221a0` calls Hashtbl.create with97, creates a working area and allocates eleven fields. The extra field at offset`50` starts as tagged1; no additional growing owner is inferred from it. |
| Working area | `Automata.create_1983` at `919090`: a bitvector of length1, a ref to an optional Hash_set initiallyNone, and a ref to an index-capacity hint initially0. |
| Positions | `make_1214` at `920990`: `{array; length}`, with initial length `hint+1`; created afresh by `match_str_no_bounds_1793` at `921f64`. |
| State transitions | `make_733` at `920770` allocates `ncolor+1`, puts the state-info record in slot0, and initializes transition slots to the unknown sentinel. |
| Group | Five fields, published only after `make_match_str_1508` returns a match; the positions array is extracted from the private positions owner. |
| State info | Three fields: encoded index, final-boundary cache list, immutable automaton state. Hash_set keys are expression IDs, not these encoded indices. |

## Compiler IDs and finite descriptors

Reuse R71's fixed syntax census: union length `L<=401`, no counted repetition,
backreference, case folding, named group, Pmark or Last_end_of_line; each
repetition operand is a single character/class. The following native operation
mapping preserves the source counting argument, including discarded intermediate
expressions. It does not assume equal record sizes or equal source versions.

* Emacs `parse_319`, `regexp$27_357`, `branch$27_359`, `piece_360`,
  `atom_361` and `bracket_362` consume that byte syntax. `piece` selects
  `*`, `+` and `?`, with lower/upper operands0/1. Native `Ast.repn_1326`
  retains those operands, and `Ast.seq_1210` simplifies empty/singleton lists
  or wraps the list, without copying its expression children.
* Literal character ASTs come from an eagerly initialized array of256
  entries (`Ast.entry` at `91e462`, `Dense_map.make_298`). The retained
  initializer closure at `f29c08` selects `Ast.fun_2317`, which obtains the
  character set then calls `Ast.cset_1172`. `Dense_map.fun_353` only reads
  the captured array. It is not a mutable warmup cache. `handle_case_1186`
  maps the existing finite child lists once and preserves the selected tree
  shape; the no-case-folding set helper returns the existing set.
* `Ast.merge_sequences_1524` at `91ddb0` flattens nested alternatives, or
  recursively processes the tail then factors equal first sequence heads.
  At `91dea7–91df93` it retains one common head and wraps the two suffixes;
  it does not duplicate the removed head occurrences. This is the source
  head/branch-pair accounting used by R71.
* `Compile.translate_1981` uses the retained ten-entry block dispatch at
  `9ee468`: Set`922a54`, Alt`922aa0`, Seq`922ba4`, Repeat`922be4`,
  Group`922d18`, then the five other reference constructors. The selected
  immediate dispatch is separately retained at `9ee440`. Set calls
  `trans_set_1965` then one `Automata.cst_1148`. Alt merges/maps its children
  then calls one `Automata.alt_1182`; Seq delegates to `trans_seq_1982`.
  Group increments the mark ref by2 at `922da3` and makes two marks and
  two sequences. Repeat translates its child once; the lower/upper0/1
  iteration and `make_repeater_1973` clone only that Set child. The helper
  closures `fun_2489`, `fun_2500`, `fun_2528`, `fun_2535` are retained.
* `Automata.seq_1187` returns an existing empty/epsilon child when it can,
  otherwise allocates one Seq expression; it performs no hidden expansion.
  The rename dispatch at `9ee1f0` maps Cst tag0 to `9172c4`, the one-leaf
  copy path. Constructor ID increments are tagged `+2`, once per new node.
  `compile_1_2084` initializes the private ID ref to0 at `9234ee` before
  translation. `compile_2099` adds the enclosing Group and, if unanchored,
  the single-Set repetition prefix already covered by R71's eight-byte slack.

Thus R71's conservative cumulative allocation count
`N=64*(L+8)^2<=10,705,984` applies to the actual selected constructors:
the parser/tree and factoring accounting is unchanged, and each selected
translation step is within its eight-expression allowance. Case/alternative
wrapper representation changes do not add automaton IDs. Source and native
span identities used for this mapping are recorded in `inputs.json`.

The native epsilon constant at `f25a78` has tagged ID1, meaning ID0, and
immediate Eps definition1. Newly allocated expression IDs lie in`1..N`.
Consequently the key domain has at most `M=N+1=10,705,985` members,
all nonnegative and different from Hash_set's unboxed sentinel`-1`.

`Automata.loop_1628` reads either the TExp's expression ID (`918cf9`,
`918d24`) or, for an epsilon TExp, its continuation's ID (`918c71`,
`918c9d`). The outer continuation is that ID0 epsilon constant; TSeq recursion
passes the retained compiled expression. Both branches test membership before
adding. `delta_expr`, `delta_rep`, `delta_alt`, `delta_seq`, `delta_e`,
`delta_desc`, `tseq`, `add_eps`, `initial` and `set_idx` construct finite
descriptor lists from these expressions, without generating new expression IDs.
Each recursion consumes a finite expression child or descriptor/list tail.
Rep processes its child and retains the repetition pointer; it does not recurse
into itself at the same step. This proves finite traversal even before duplicate
removal; it does not replace the ordinary stack/memory premise with a RAM bound.

## Packed Hash_set: count, space and termination

The actual scratch owner is an optional ref to `{bytes; size}`. Each key uses
eight bytes; clear fills them with255, representing signed64 sentinel`-1`.
Capacity `C=Bytes.length/8` is0 or a power of two. Initial allocation is lazy.
The wrapper `add_590` at `914680` performs at most one resize, when `C=0`
or when `c=size>0` and `floor(C/c)<2`. Resize maps0→1 or doubles capacity,
allocates the new sentinel-filled bytes, publishes them at `9145ba`, then
scans the oldC slots and reinserts occupied keys with internal `add_530`.
**Resize does not reset size.** Each reinsert increments it again. We therefore
use historical insertion accounting, not `size=occupancy`.

Define an epoch as the execution after one completed scratch clear and before
the next clear or an escaping exception. At completed insertion boundaries,
the table holds distinct keys, actual occupancy `n<=M`, and historical count
`c>=n`. There are at mostM outer additions: membership succeeds for every key
already inserted, resize preserves all existing keys when it completes, and
this epoch never deletes a key. There are at mostM resizes, because each outer
addition invokes at most one and internal reinsertion never resizes. Each
resize performs at mostM internal insertions. At every prefix, including an
interrupted insertion, therefore `0<=c<=M(M+1)`.

For a nonzero resize its precondition gives `C<2c`, so the new capacity
`2C<4M(M+1)`. The initial0→1 case also satisfies this bound. Clearing preserves
capacity; induction from an initially absent table proves the bound across
all epochs, including published partial resizes. Failed allocation leaves the
old capacity. No new exception budget is spent on each epoch.

The resulting conservative ceilings are:

| Quantity | Bound |
| --- | ---: |
| Distinct keys / outer additions per clear epoch | 10,705,985 |
| Historical size at any prefix | `M(M+1)` |
| Capacity at any prefix | `4M(M+1)` slots |
| One packed backing allocation | `32M(M+1)` bytes |

The focused checker instantiates these products and verifies the backing bound
is below the selected64-bit OCaml `max_string_length=2^57-9`; slot counters,
size increments, tagged intermediates, doubling and byte offsets fit the
selected integer/pointer bounds. This deliberately loose ceiling is an integer
representation proof, not a claim that the host has that much physical memory.

Insertion progress also needs an empty slot. With no growth and `c>0`, the
wrapper gives `n<=c<=C/2`; if `c=0`, then `n=0` at this boundary. On growth,
the new2C slots receive at mostC old occupied entries and then the one new key,
so each insertion starts with an empty slot (including C1→2). The zero case
starts with one empty slot. Internal `add_530` probes successive slots with
wraparound until a sentinel, hence terminates withinC probes. Its offset
arithmetic remains within the backing allocation. Independently, `mem_599`
explicitly stops afterC probes (`91487f–914885`), so a full one-slot table
does not cause an infinite membership search. Hashing receives a single tagged
integer and its hash is masked by `C-1`; hash arithmetic is not a capacity
counter.

## Interrupted scratch epochs and positions

The count/occupancy relation above is deliberately a **completed-boundary**
invariant. `add_530` stores the packed key at `9144f1`, can dispatch pending
work at `914500/91451f`, and only then increments size at `914507–914510`.
Thus an escaping callback can leave `n=c+1`. A partial rehash can also leave
missing entries and an overcount. Neither state is admitted to another
membership/insertion within that epoch after an escape.

There is no local catch in Hash_set add/resize/mem, duplicate removal or delta.
`Compile.validate_1261` invokes delta before its state lookup. The final-boundary
cache's two assq catches end before delta at `920fc5`. `find_state_1246` catches
only Hashtbl.find (`920a94–920abd`); state construction/add lies outside that
trap. The selected scan/positions chain has no catch which resumes an escaped
delta or positions update. Str or its parser caller can catch Not_found, but
the current search and its private positions object have already unwound.

On a later search using the same compiled regexp, `delta_2076` first computes
`delta_desc`, which does not access Hash_set, then calls scratch clear at
`9199cb`, before duplicate removal at `9199e0`. Clear sets size0 at `9143c3`
and fills exactly the valid backing length. The retained chain
`clear_526 → Bytes.fill_357 → caml_fill_bytes → memset` has no allocation,
GC poll or pending-callback dispatch between count reset and valid fill return.
Bounds failure is excluded by offset0 and length=actual bytes length. OS signal
delivery alone does not execute an OCaml callback under the accepted runtime
contract. Thus completed clear restores both fields before any scratch use.
An interrupted earlier phase has not begun this reset; an escaping later phase
is handled by the next reset. The classified callbacks do not alias/mutate this
private workspace. R71's save/exit closure and returning-client premises supply
that exclusion; they are not enlarged here.

`free_index_1999` separately resets the bitvector before marking descriptor
indices. It publishes a newly doubled bitvector at `919336` and then updates
the index-capacity hint at `919349`. Even allowing an escape between these
writes, the old hint is nonnegative and no larger than current bit capacity.
The next free-index operation resets/marks the actual bitvector. The hint may
remain stale, so initial positions capacity need not equal that bit capacity.
Dynamic positions growth handles this case.

Native `resize_1199` writes the doubled length **before** allocating the new
array (`920882` versus `9208ac`), then publishes the array and blits the old
contents. A failed prefix can leave length ahead of the old array. This would
be unsafe if reused: `set_1203` trusts that length before an unsafe store.
However `match_str_no_bounds_1793` constructs positions afresh at `921f64`,
with `Core.exec_594` explicitly selecting groups=true at `924c1f`,
does not publish the owner in the regexp, and only extracts its array into a
Group after the search succeeds (`921ffc–922051`). No local catch resumes a
failed update. The next search gets a fresh owner, and a retained old Group
refers to a prior completed array, never this failed growth prefix.

## Dynamic indices, tables and published Groups

The actual scan loop validates at most once per consumed input position:
`loop_1358` calls validate at `920df3`; successful validate publishes the
transition at `920ca7` before looping at the same position. Its next step
advances or returns on a break state. An escaping failure ends that search.
There is at most one initial-state construction and one final delta per search.
Initial/final caches each make two assq probes, but only the second miss path
constructs/publishes, once. The extra probe does not multiply those construction
counts. The no-Last_end_of_line syntax makes `scan_str_1486`'s special trailing
newline route unselected. R71's at-most5 union searches and4 individual searches,
and the same global exceptional allowance, therefore retain the generous
402/86 attempted-state-add bounds.

Each delta chooses the first unused index from a reset bitvector and can
introduce at most one new largest index. Earlier generated indices are the only
ones in descriptor marks. The real index stays below402 and bit capacity at
most512; `Bit_vector.create_zero_449` requests `ceil(bits/8)<=64` bytes.
The hint stays in0..512. Initial positions length is1..513; resize doubles only
while the requested index does not fit. The final doubling is less than twice
the needed positive index bound. The existing2048-word envelope consequently
covers every initial/growth request, including stale-hint cases, and all stored
positions are in0..76.

The state-info index encoding is separate from those position indices.
`find_state_1246` stores a normal tagged index `t=2i+1`, or the break encoding
`-8-t = 2*(-i-5)+1` (`920b0e–920b18`). For `0<=i<402` these are tagged
values1..803 or -811..-9. `loop_1358` tests against tagged0, then tagged-3
(`-5`): encoded break values take `920daa–920db1`, applying `-8-x` again
and recovering exactlyt before the positions store. The unknown transition
sentinel is tagged-2 (`-3`), initialized at `923854` and compared at `920c3e`;
it goes to validate, not decode. Neither subtraction overflows or collides
with the sentinel. This also establishes that the scan's unchecked position
stores receive a represented nonnegative real index.

With the retained standard-Hashtbl/runtime relation, create97 gives128 buckets;
402 attempted adds permit only the128→256 growth, and86 do not grow. The
actual find/add call sites and catch boundary are now attached. Interrupted
individual additions can undercount size but retain a proper bounded chain;
the union-resize escape abandons subsequent union searches, as in R71. The
color map still uses257 initial bytes, two256-byte temporaries, and at most256
colors (`compile_1_2084`, `Color_map.flatten_622`); transition arrays are at
most257 words. The native Group translation creates at most8 mark indices,
and `Mark_infos.make_310` folds their maximum using the retained `fun_486`
closure, adds1, and allocates at most8 words. Checked mark/Group accesses retain
their guards.

Finally, the actual `Str.search_forward_689` catch is narrower than the source
reference. Its trap is popped at `92788b–92788f`, before Some Group publication
at `92790a` and `Group.offset_531` at `927917`. Not_found from the protected
lazy/Core.exec portion clears Str.state; an exception during later publication
or offset access is outside that trap. The shared ref can therefore retain the
incoming Group or the newly completed Group after such a failed search. Each
canonical Group still contains only one at-most76-byte input, at-most8 marks
and a completed at-most2048-word positions array. Its consumers do checked
accesses/replacement work as in R71; no failed positions owner is retained and
no compile scratch cache is reachable through Group. A pre-existing startup
Group remains its earlier owner's input until overwritten/cleared. This note
does not assign canonical bounds retroactively to that earlier owner.
The retained caller control flow consumes `matched_group`/replacement only
after its own search has returned successfully. Not_found during late Some
publication or offset access reaches the existing full_split/grep handler and
skips that search's consumer; a different escaping exception unwinds the parser
entry. Thus such a failure does not make a replacement consume an incoming
pre-canonical Group. This is an ownership/control-flow argument, not a claim
that every failed search clears Str.state.

These native witnesses replace R71's open numerical relation for the selected
Re owners with the bounds above, including the additional packed Hash_set.
They do not strengthen the matching-semantics premise, infer an upstream version,
or close the separate canonical-path, startup and whole-#119 obligations.
