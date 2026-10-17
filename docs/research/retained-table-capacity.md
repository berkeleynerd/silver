# Retained frontend allocator and node accounting

2026-10-17, #119. This component supplies explicit arithmetic obligations and
allocator-event transfers for the [capacity design](retained-tool-capacity.md).
It does not establish how many events every program causes. No replacement
membership rule or safe whole-program threshold follows from it.

The inspected GCC tree is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
[Reproducible arithmetic and lexical inventory](../evidence/unbounded-programs/retained-table-capacity-20261017/arithmetic-and-inventory.json)
records source hashes. Its adjacent `derive.py` reads that Ada source directory,
verifies every inspected/inventoried file against the retained pinned-tree
manifest and writes a selected output JSON. The inventory finds 161 lexical `Table.Table`
instantiations in top-level Ada files; it is not an exhaustive inventory of
reachable allocations. It includes utilities outside the selected pipeline,
excludes other allocator families/generated files and proves no caller coverage.
The allocator derivation required no compiler or proof run. A subsequent
standalone source-generator run below recovers exact node sizes; it does not
build or replace GNAT or Silver, and does not run GNATprove or Lean.

## Generic table state and arithmetic

`table.adb:40–47,127–153,167–220` uses signed 32-bit `Int` for low bound `m`,
allocated length `l`, maximum index `x` and logical last `h`. `types.ads:53`
defines its range. The initial length is `Table_Initial * Table_Factor`; the
initial maximum is `m + l - 1`. The empty logical last is `m - 1`.
For a request beyond `x`, the growth loop computes:

```text
q = floor(l * (100 + Table_Increment) / 100)   -- signed 64-bit work
l' = max(Int(q), l + 10)
x' = m + l' - 1
```

Repeat until the request is covered. A sufficient transition check requires
**every expression in evaluation order** to fit its actual type: the initial
product, `m - 1`, the 64-bit product, `Int(q)`, `l + 10`, `m + l'`, its subtraction,
and the requested logical last. Merely checking final `x'` is insufficient when
`m + l'` overflows before subtracting one. Nominal ID ranges are additional to
backing-table arithmetic; several instances deliberately use the ID base type.

Reallocation converts `x - m + 1` to `Memory.size_t` before multiplying by
component bytes. Bound the signed subtractions/addition and the target-size
product separately. `Set_Item` additionally constructs an imported array ending
at `Max + 1` (`table.adb:313–317,347–350`); account for that sentinel and the
one-past address calculation even when the logical last fits. Under the stated
external allocator/address assumptions, these arithmetic checks exclude the
identified representation overflows; they do not guarantee physical allocation.

This yields a decidable arithmetic checker **given a complete event trace**.
The missing source analysis must overapproximate all such traces, including
caller-side index arithmetic, without running an opaque compiler as membership.
No global growth threshold is selected here.

### A sufficient bound without retaining the growth history

For a fixed instance, a source analysis can instead supply an upper bound `D`
on **every logical demand** `Last_Val - m + 1`, including temporary reserves.
Assume nonnegative `D`, initial length, growth increment, release threshold and
`Table_Factor` (the low bound `m` may be negative), a fixed factor, well-formed
operations (`Last_Val >= m-1`), and saved states from this same instance/invariant.
`Free` must be followed by initialization/restoration before table use. Define,
using mathematical integers,

```text
P = max(D, Table_Initial)
C = max(Table_Initial * Table_Factor,
        D + floor(D / 1000),
        floor(P * (100 + Table_Increment) / 100),
        P + 10)
```

Then `C` bounds every backing length, across growth, `Release`, `Init`,
`Save` and `Restore`. The argument is by induction over the operations:

- Initialization selects the first term. An ordinary append/`Set_Last` changes
  only the logical last unless it exceeds capacity.
- On entry to a growth loop, the old capacity is below the requested demand,
  hence below `D`. The initial `max(Length, Table_Initial)` can make it larger
  without yet updating `Max`; `P` covers that first iteration as well. On later
  iterations the loop guard again gives `Length < D`. Monotonicity of the two
  growth expressions bounds their result by the last two terms of `C`.
- Release selects a logical length at most `D`, optionally adding at most
  `floor(D/1000)`. Save reinitializes; Restore recovers a previously bounded
  capacity. No assumption that a release preserves the initial growth sequence
  is needed (`table.adb:276–300`).

Check the initial product and `P*(100+Table_Increment)` in their actual types
(the latter is signed 64-bit); check `C+1 <= Int'Last`, `m-1 >= Int'First`,
and `m+C <= Int'Last`. These conservative conditions cover the signed
capacity/one-past arithmetic described above, including a zero-length release.
Also bound `(C+1)*component_bytes` in the target allocation/address model,
and check actual logical indexes against the instance's nominal ID subtype.
The backing sentinel `Max+1` must also fit the actual `Table_Index_Type`
conversion in `Set_Item`, even if that subtype is narrower than signed Int;
checking only the logical last does not cover this conversion.
Caller-side indexes, decrements below the empty state, lock validity and
auxiliary arithmetic remain explicit obligations. Debug-only diagnostic
conversions are outside the production options assumed here.

For String characters (`m=0`, initial 2500, factor 1, increment 150),
`D=858,993,458` gives `C=2,147,483,645`; `C+1` fits signed Int.
The next demand gives `C=2,147,483,647`, whose `C+1` does not fit this
sufficient envelope. This is **not a selected language limit or an exact tool
cutoff**. It is a derived, conservative local arithmetic condition applicable
only after a complete source-to-demand bound and the other component checks.
The exact-transition checker may accept a wider range when its history is known.

For example, with low bound zero, initial length 2500, increment 150% and no
reset/release, the String-character length sequence reaches 931,307,812 and next
computes 2,328,269,530, exceeding `Int'Last`. The evidence recomputes the sequence
using integers without allocating its arrays. It is a source arithmetic fact,
not an observed native exception or a safe admitted-character count. Compiler
checks may be suppressed, and other constraints can bind earlier.

## Release and other allocator families

A single initial-growth sequence is not a general table invariant.
`Table.Release` (`table.adb:232–270`) sets length to `h - m + 1`, then may add
`length / 1000` above its instance's release threshold. `Save`/`Restore`
(`table.adb:276–306`) replace table state. Each operation needs its own checked
transfer; phase analysis must establish which are reachable before subsequent
growth. `Set_Last` reducing the logical last alone does not shrink capacity.

Stringt's lock calls generic `Release` with default threshold zero and then
locks both tables (`stringt.adb:123–129`). Its separate semantic mark/release
only resets logical lasts. Uintp's release likewise resets logical lasts with
protected minima (`uintp.adb:685–686`). Do not confuse those operations with
allocation-capacity release. Name locking first reserves 5000 characters and
100 entries, then releases and locks (`namet.adb:39–40,1124–1132`); name unlocking
has its own reserve removal/release (`1527–1531`). Charge these ordered actions.

Line tables use a different allocator. `sinput.adb:109–112` doubles capacity
because `(100 + 150) / 100` truncates to two. Its allocation expression
(`151–155`) multiplies by the 32-bit component size **before** conversion to
`size_t`. Starting at 500, 65,536,000 is the last doubling capacity whose bit-size
intermediate fits signed Int; the next multiplication is 4,194,304,000. This
reproduces the earlier arithmetic hazard, not a measured line-count cutoff.
Source lines, logical lines and every actual growth request still need coverage.

## Nodes, slots and lists must compose

`Atree.Allocate_New_Node` (`atree.adb:1157–1176`) allocates one node identity,
its dynamic slots, one Orig_Nodes entry and corresponding Next_Node/Prev_Node
entries. `New_Copy` (`1828–1860`) has the same allocation pattern except for
Empty/Error nodes, which it returns directly. `nlists.adb:125–132` extends both
node-link arrays to the node ID even for nodes not placed in a source list.
List headers have a separate allocation count. Thus source list-member counts
alone undercount the link tables.

Let `size(k)` be the actual generated slot size for kind `k`, after subtracting
`N_Head`, as defined by `Size_In_Slots_To_Alloc` (`atree.adb:2414–2421`). Entity
nodes use `Einfo.Entities.Max_Entity_Size`; ordinary nodes use `Sinfo.Nodes.Size`.
The generated size tables must be tied to the selected compiler source/build,
or a source-derived upper bound must replace their exact sizes.

### Exact slot sizes from the pinned generator

The standalone `Gen_IL.Main` program has no compiler-input dependency; its
source defines the layout and emits the GNAT tables (`gen_il.ads:45–54`;
`gen_il-main.adb:26–34`). Running the eleven hash-verified `gen_il*` sources from
the pinned tree gives:

| Family | Minimum total slots | Maximum total slots | Maximum dynamic slots |
| --- | ---: | ---: | ---: |
| Ordinary node | 5 | 12 | 9 |
| Entity | 21 | 64 | 61 |

The generated header size is `N_Head=3`; each slot is 32 bits. `Atree` allocates
the **maximum** entity size even for a smaller entity kind, because it does not
know `Ekind` at allocation (`atree.adb:2414–2446`). The separate `Node_Header`
contains the three header slots and an offset, hence 16 bytes
(`atree.ads:705–731`). `Node_Offsets`, `Orig_Nodes`, `Next_Node` and `Prev_Node`
still have separate backing capacities; these sizes do not replace their
growth, ID-domain or sentinel checks.

For counts of allocation **events**, let `N_o,N_e` count new/copy allocations
by ordinary/entity kind, and `G_o,G_e` count slot-growing mutation/copy events
by their new kind. A source-relative upper charge for dynamic slot demand is

```text
9 * (N_o + G_o) + 61 * (N_e + G_e).
```

Charge the full new size even for tail growth. This is a local event transfer,
not a source-to-event bound. In particular, `Rewrite` may save an original with
`New_Copy` and then call `Copy_Node` (`atree.adb:2255–2276`); both charges are
needed. `Relocate_Node` makes one shallow `New_Copy`, not a recursive child copy
(`:2109–2149`), whereas `Copy_Separate_Tree` must charge every copied descendant.

The [retained layout result](../evidence/unbounded-programs/retained-table-capacity-20261017/node-layout.json)
contains every generated size entry, hashes of all generator inputs and outputs,
the native compiler version and exact command. Managed Linux run
`20261017T231847-6bca937e079b` built and executed only this generator in
`/tmp/silver-retained-node-layout-20261017`, with one worker, in 7.127 seconds.
Assertions and overflow checks were enabled. The generated compiler source was
not compiled or installed. This ties the layout to the inspected source; the
existing source-to-installed-tool correspondence premise remains necessary.

Without executing the generator, its bounded offset representation supplies
a weaker source-relative envelope: `Bit_Offset` is `0 .. 31999`
(`gen_il-internals.ads:78–83`), and `Compute_Type_Sizes` rounds a value in that
range to 32-bit slots (`gen_il-gen.adb:1040–1048,1230–1272`). Successful layout
generation therefore gives at most 1000 total slots, or 997 dynamic slots.
The exact generated maxima above are substantially tighter, with no unexplained
safety multiplier. Neither envelope establishes the number of allocation events.

### Slot-event lifetime accounting

An event-level upper charge for slots is the sum of `size(k)` over all
Allocate_New_Node/New_Copy events **plus** the new-size charge for each growing
Mutate_Nkind, Change_Node or Copy_Node event. Their allocation sites are
`atree.adb:1098,1162,1224,1324,1843`; the tail-growth alternative is at 1092.
Charging the whole new size is conservative for tail extension and no-growth
paths. Node mutation/copy can allocate slots without allocating a new node ID.
A count of final nodes multiplied by a maximum node size therefore does not
bound cumulative slot demand. Copying a separate tree/list recursively creates
further events (`1337–1420`); rewrite multiplicity cannot be omitted.
Even a zero-slot request evaluates `Slots.Last + 1` in `Alloc_Slots`
(`atree.adb:511–515`); the caller-side arithmetic must cover this one-past value.

These are closed local allocator transfers under caller/type invariants.
The unresolved upper-bound problem is the number and kinds of events produced
by parsing, semantic rewriting, checks, support expansion and every selected
producer phase. No measured nodes-per-source-byte coefficient fills that gap.

## Individual generated names are another representation

Aggregate name entries/characters do not cover every name representation.
`Name_Enter` and `Name_Find` store `Short(Buf.Length)` (`namet.adb:1144,1252`),
while `Short` ends at 32,767 (`types.ads:74`). The global name buffer can hold
`4 * Max_Line_Length` characters (`namet.ads:161`), so buffer capacity alone
does not establish that this narrowing fits. User identifier length and generated
qualification/suffix length are different quantities. A generated-name maximum
must accompany aggregate name charges and each selected local buffer's capacity.

`Name_Enter` appends every character and a NUL (`namet.adb:1154–1161`), and
intentionally bypasses normal interning. Generated names cannot all be charged
as deduplicated source identifiers. `exp_dbug.adb` supplies qualification and
suffix construction; bound the reachable scope/name transformations for Main,
fixed dependencies and generated entities. No native oversized-name failure or
new current-language defect is asserted by this field-width inspection.

## Remaining integration obligation

Combine the [value transfers](retained-value-capacity.md), phase/source closure
and producer accounting with a complete construct-to-event bound. The generic
state transitions here can check resulting demand; they cannot supply that
missing demand analysis. Retain source/tool correspondence and distinguish
lexical inventory, local source derivation, arithmetic reproduction and native
observations. #119 stays unfinished until those pieces compose into a justified
whole-program predicate and its required comparison.
