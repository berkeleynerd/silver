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

### Main physical lines and column arithmetic

For the ASCII/HT/CR/LF author alphabet, count CRLF as one separator and a lone
CR or LF as one. If `t` is this separator count, `1+t` bounds the physical
line-table entries for Main. The scanner starts with line 1, adds an entry when
advancing to a non-EOF physical line, and adds it only when the new source
position exceeds the last recorded position (`sinput-l.adb:518–540`;
`sinput.adb:870–919`). Thus parser lookahead does not multiply line-table entries.
Main cannot supply `Source_Reference` pragmas, so it adds no logical line table.
Dependency/configuration files and virtual sharing remain separate contributions.

With the selected factor 1, the allocated line capacity is the least member of
`500 * 2^k` covering the entry demand. Checking that capacity times 32 fits signed
Int covers the local allocation intermediate above. The capacity sequence has
last locally valid member 65,536,000; this is a sufficient bound for this
allocator only, not a source-size or language threshold.

Columns require a separate per-line rule. `Column_Number` ends at 32767
(`types.ads:181–187`), and `Hostparm.Max_Line_Length` is its predecessor
(`hostparm.ads:42–50`). On each physical line, excluding its terminator, start
`c=1` and process source bytes in order:

```text
HT:    c := 8 * floor((c - 1 + 8) / 8) + 1
other: c := c + 1
```

Require the final `c <= 32766`. This ensures every earlier column fits, including
the scanner's zero-based indentation accumulator (`scng.adb:2892–2936`). It
also implies the physical byte-length check. EOF receives the same line check
(`:1401–1404`); a final unterminated line is not exempt.

The check is tighter than simply allowing 32766 printed characters. For lines
of at least 4096 bytes, `Check_End_Of_Line` starts at column 1, increments after
each character and rejects as soon as `c > 32766` (`scng.adb:129–195`). Consequently
32765 ASCII characters end at 32766 and pass this local check; 32766 characters
end at 32767 and fail. Likewise 4095 tabs end at 32761; five subsequent ordinary
characters are allowed by the column check and a sixth is not. Lines shorter
than 4096 bytes skip the expanded-column loop, but even all tabs then yield
`c <= 32761`, so the sufficient rule excludes none on that account.

The evidence reproduces these arithmetic discriminators without a compiler
probe. They establish the local selected-source check, not legality of those
byte sequences as complete programs. Every physical source buffer, generated
source and other name/diagnostic buffer still needs its own capacity coverage.

## Names and serial-number components

For one `Name_Find` call with an `l`-character buffer, a hash miss appends one
name entry and `l+1` characters, including the C NUL terminator. A hit appends
nothing; one-character names are already initialized (`namet.adb:1185–1275`).
`Name_Enter` deliberately bypasses deduplication and always appends that same
charge (`:1138–1162`). Initialization creates **256 entries and 512 characters**
by iterating over Character (`:1309–1338`); the old specification comment about
26 letters is not the current implementation. Reserved names and dependencies
are additional fixed contributions.

Name entries occupy 16 bytes each (`namet.ads:570–624`). Usable nominal IDs run
from -399,999,997 through -300,000,000, or **99,999,998 entries** including
initialization (`types.ads:344–346`; `namet.ads:183–200`). The two generic
tables still need the backing-growth obligations above; the name lock adds its
100-entry/5000-character reserves before release. A valid nominal entry count
alone does not cover the reserve or backing sentinel.

For Main's ASCII word tokens, let `W` be their number and `B_w` the sum of their
source byte lengths, including keywords. Scanning folds uppercase letters in
place and retains underscores, without encoding expansion
(`scng.adb:2545–2606,2766–2771`). Therefore the source-word contribution is:

```text
name entries    <= W
name characters <= B_w + W
```

Parser lookahead does not multiply this charge: a repeated spelling returns the
same hashed entry, and restoring the scan position does not release the name
tables. Repeated source tokens can also share entries; counting every source
occurrence merely overapproximates that sharing. This covers source-word
interning, not generated/internal names, filenames or diagnostics.

Every newly entered name must have `l <= 32767`, because its length is converted
to signed Short. The scanner's global buffer has 131064 characters
(`4*Hostparm.Max_Line_Length`), so the earlier Main line rule already suffices
for this scanner buffer and the Short conversion. It does **not** establish
capacity for downstream consumers: ordinary `Bounded_String` defaults to 4096,
and `Append_Decoded` first copies even an unencoded name into such a temporary
(`namet.ads:144–163`; `namet.adb:169–202`). Thus the retained 4096 identifier
boundary has a separate consumer basis; generated/qualified names and their
actual decoding paths still require coverage.

One `New_Internal_Name` event adds a prefix letter, a unit serial in decimal,
and a body/spec character, then calls `Name_Enter`
(`tbuild.adb:61–99,719–726`). For serial `s` in `1..Int'Last`, its unqualified
length is `digits10(s)+2 <= 12`, and its character charge including NUL is at
most 13. Configuration names omit the final body/spec character. The serial
increment itself requires that the cumulative count fit Nat
(`lib.adb:1062–1067`); this is an independent event-count obligation.

The character-suffix `New_External_Name` overload has the local length transfer
`l + prefix_present + suffix_present + serial_length`, with serial length zero,
`digits10(i)` for a positive explicit index, or `digits10(s)+1` for a negative
index requesting a fresh unit serial (`tbuild.adb:632–665`). The String-suffix
overload substitutes the actual suffix length (`:668–701`). These transfers do
not bound how often helpers construct names or how names grow through repeated
qualification. In particular, `exp_dbug.adb` has a separate 256-character
homonym buffer and scope-qualification paths. They cannot be discharged merely
by bounding the author's longest identifier.

### Qualification transfer

For an ordinary scope path without a debug-renaming link or body-nested package
suffix, let `l_1 .. l_d` be its unqualified component lengths, and let
`h_1 .. h_k` be the positive homonym numbers actually appended for those
components. Include the original components of an already qualified prefix,
rather than counting that prefix and its ancestors twice. Define

```text
H = sum(digits10(h_i)) + max(k-1, 0)
Q = sum(l_i) + 2*max(d-1, 0) + (if k=0 then 0 else 2+H)
```

`Append_Homonym_Number` adds one decimal spelling, with one separator after
the first (`exp_dbug.adb:196–227`). `Strip_Suffixes` recovers an existing suffix,
using a one-byte separator between recovered groups (`:1581–1628`); grouping
does not change this bound. `Output_Homonym_Numbers_Suffix` adds two underscores
and the accumulated suffix, or omits it when all numbers are one
(`:1101–1130`). **Omission does not avoid the earlier temporary allocation.**
Thus `H <= 256` is needed even for an omitted suffix. With only the Nat range
known, each decimal spelling is at most ten bytes, so `H <= 11k-1` for `k>0`.
This is a transfer for actual homonym entries, not a proposed loop-depth cap.

The recursive concatenations in `Fully_Qualify_Name` append each component
once, with two underscores between components (`:1240–1312`). Already
qualified prefixes are stripped/recovered once. For the stated path domain,
every intermediate base-name length is at most `Q`. The partial-qualification
path selects a suffix of the same chain and is no larger. `Q+1` must fit the
global buffer where a NUL is written, and any stored result still needs
`Q <= 32767`. A downstream call through a default `Bounded_String` also needs
its separate 4096-byte bound.

The distinction between paths matters: `Qualify_Needed` excludes blocks and
loops for ordinary objects, but **types and subprograms take full qualification**
(`:1334–1352,1496–1508`). Their scope names cannot be dropped merely because
author-defined nested subprograms/types are excluded. Native expansion creates
types inside generated scopes. `Has_Qualified_Name` makes later ordinary
qualification visits return without new storage (`:1427–1428,1535–1536`). A
successful ordinary qualification therefore charges at most one `Name_Enter`
per entity, with one entry and `Q+1` characters; debug-renaming paths are
excluded from that one-entry statement.

For ordinary non-Ghost, non-interface-name paths, `Get_External_Name` adds at
most five characters for `_ada_` or `3 + suffix_length` when an explicit suffix
is requested (`:805–876`). The full scope path must include any local scopes
visited by this separate recursion (`:776–797`); the raw or stored qualified
component bound above applies. For discrete scalar encodings with both bounds
inside Standard.Integer, `Get_Encoded_Name` adds at most **32** characters:
`___XD` (5), `LU_` (3), two signed decimal encodings of at most 11 each, and
the two-byte bound separator (`:677–739`). The biased variant is smaller.
This covers the Ada encoder, not additional GCC identifier suffixes.

The native component already identifies `Make_Temporary`/internal-name routes,
and `Find_Type_Of_Object` can use the external-name transfer with prefix `T`,
suffix `S` and zero index (`sem_ch3.adb:19120–19125`), adding two characters
to an object's name. Complete source-to-scope-path and generated-name coverage
remains required. Fixed dependency packages, Ghost entities, backend suffixes,
and any reachable debug-renaming or body-nested package route are separate
families; this local transfer does not assume they are absent globally.

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

## Auxiliary parenthesis counts

Parenthesized expressions do not allocate a distinct syntax node for each
pair. On the ordinary expression path, the parser increments the existing
expression's count (`par-ch4.adb:1663–1682`). Its two-bit field is **not a
two-level nesting limit**. Counts zero through two stay in that field; three
marks an entry in `Atree.Paren_Counts`, whose actual count has subtype Nat
(`atree.adb:114–137,2037–2055,2331–2359`).

`Set_Paren_Count` searches by node identity before appending. Updating an
existing large count adds no entry; resetting to a small count does not remove
the old entry. `Set_Paren_Count_Of_Copy` repeats that same lookup/update for
the target identity (`:2365–2377`). Thus the auxiliary table has at most one
entry per distinct node identity in its lifetime. Charging **one entry per
ordinary node allocation/copy event** is sufficient, including discarded and
later rewritten nodes. Reusing an identity after initialization does not
defeat the cumulative-event bound. An entry holds one Node_Id and one Nat:
eight bytes under the pinned 32-bit representations. Its index starts at zero,
initial allocation is ten entries, and growth increment is 200 percent; apply
the generic demand envelope and sentinel/byte checks separately.

The retained complete top-level source inventory finds twenty setter calls
and its declaration/body headers. Only the four parser
parenthesization paths increment a count. Other calls copy/preserve a count,
set zero or one, or remove one pair. Consequently a sufficient value bound
is the largest parser nesting count in the selected source files, enlarged
to at least one. For a file of B bytes the nesting count is at most `floor(B/2)`;
the byte bound also covers the parser's next increment. Repeated copying
can enlarge auxiliary **entry count** but does not increase this value bound.
The lexical site inventory in the evidence corroborates this manual caller
classification; it is not an automated reachability proof.

The initial inventory missed `atree.adb:2273` because its spelling has extra
spaces before the opening parenthesis. The corrected case-insensitive scan
accepts arbitrary whitespace, including line breaks. This `Rewrite` call
restores `Old_Paren_Count`; including it changes the inventory, not the entry
or value bounds above.

This closes this auxiliary table's local source/value connection once the
whole-phase node event count and selected source inventory are supplied. It
does not establish parser recursion-stack capacity or the other auxiliary
tables.

## Main parser auxiliary transfers

For one successful parse of the current Main grammar, let `F` be its number
of `for` statements and `d` the maximum number of simultaneously enclosing
`if`/`for` statements. An `elsif` arm does not add a scope. Relaxing the
source/operator/value limits does not change this grammar argument. The
selected semantic-checking/compilation modes execute `Par.Labl` after the
parse; syntax-check-only mode is not the production premise.

### Scope stack and suspicious labels

The parser initializes `Scope` with one dummy entry, then pushes once for
Main's subprogram body (`par.adb:1683–1685`, `par-ch6.adb:286`). Each nested
`if` or `for` pushes once and its successful end matching pops once
(`par-ch5.adb:1269–1349,1636–1685`, `par-util.adb:739–773`). The other push
sites belong to constructs outside the Main grammar. Thus **`2+d` entries**
bound this table's peak demand, rather than the total number of statements.
The main-body parser reads the just-popped entry at `Scope.Last+1`
(`par-ch5.adb:2329`); that entry was already allocated at the prior peak.
Use the generic table envelope with low bound zero, initial length 50 and
100-percent growth. The target layout of `Scope_Table_Entry` remains the
component-byte input to that checker. This table bound is not a bound on the
native call stack used by recursive parsing.

`Suspicious_Labels` can grow on **valid source**. The fast bare procedure-call
path appends an entry when its following token is `for`, among other tokens
outside Silver's statement grammar (`par-ch5.adb:529–549`). For example,
an admitted unqualified `Reject;` immediately followed by a `for` statement
takes this path even though neither construct has a syntax error. The later
end-name recovery scan does not undo the append.

Let `Q` count these source-token adjacencies. Main contributes exactly `Q`
appends, with `Q <= F`; no other admitted bare procedure call can take this
path. In particular, Put/Put_Line have arguments, and qualified Reject uses
the general name path. Statement parsing is not repeated by the expression
and scanner lookahead paths documented in the
[value component](retained-value-capacity.md#main-parser-multiplicity).
This is the only append site in the complete parser inventory. The table is
not reset at Main's entry: its incoming demand from earlier selected units
must be added. Each entry has three signed 32-bit fields (12 bytes), low
bound one, initial length 50 and 100-percent growth (`par.adb:587–602`).
Ignoring this table because its purpose is error recovery is unsound.

### Generated loop names, implicit declarations and element lists

Each unlabelled source loop invokes `Set_Loop_Block_Name` once. It increments
the package-level Nat `Loop_Block_Count`, and interns `L_` followed by that
counter's decimal spelling (`par-ch5.adb:1667–1676,2344–2352`). Other helper
callers are bare/while loops and blocks outside the Main grammar. There is
no per-unit reset. With incoming counter `c`, require `c+F <= Int'Last`;
the initial package value is zero. Each invocation contributes at most one
name entry and **13 name characters including NUL**, since the largest
spelling has two prefix characters and ten digits. Interning can only reduce
that demand. Name qualification and later transformations remain separate.

The loop parser also allocates one ordinary identifier node and appends its
loop node once to `Label_List` (`par-ch5.adb:1671–1685`). After parsing,
`Par.Labl` walks each source loop once and allocates one ordinary
`N_Implicit_Label_Declaration` and one defining-identifier entity, appending
the declaration to Main's existing declaration list
(`par-labl.adb:483–540`). That list already contains the mandatory SPARK_Mode
pragma, so this route does not allocate another ordinary list. The entity
becomes the loop scope already counted in the
[frontend entity component](retained-frontend-entities.md#loops-three-entities-plus-at-most-two-captures);
do not add a second semantic scope entity for it. These helper routes therefore
contribute **`2F` ordinary nodes, `F` entities and `F` ordinary-list links**, in
addition to the grammar's loop/iteration/bound/index nodes and scanner nodes.

`Goto_List` and `Label_List` allocate two element-list headers at parse entry.
The former stays empty; the latter receives `F` elements. Despite the absence
of source goto/label syntax, `Find_Natural_Loops` is called and allocates a
third header. Its merge's remainder loop copies all `F` loop entries to that
list; the subsequent dispatch recognizes neither labels nor gotos and does
no rewriting (`par-labl.adb:158,242–276,426–476,538`). Thus the complete Main
parser/label-helper contribution is **three element-list headers and `2F`
elements**. These are `Elists`/`Elmts`, distinct from ordinary syntax lists.
Their append/header constructors allocate one entry each; each entry has two
32-bit fields (eight bytes). The nominal usable identity ranges each contain
99,999,999 IDs; initialization, semantic helpers and dependencies consume
their own shares (`elists.adb:88–137,354–371`, `types.ads:330–342,474–494`).
Apply the separate backing-table/sentinel bounds with initial lengths 200
and 1,200 respectively and 100-percent growth (`alloc.ads:52–56`).

These transfers close the named auxiliary caller routes for Main. Ordinary
parser/scanner node multiplicities, semantic/generated allocations, selected
dependency parsing and other auxiliary representations still need their own
bounds. No compiler, GNATprove or Lean run was used for this derivation.

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
