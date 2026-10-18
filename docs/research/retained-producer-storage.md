# Producer node and list storage arithmetic

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
This connects the [producer allocation counts](retained-producer-capacity.md)
to their two backing vectors and retained linked lists. It closes these
containers' append/index/growth arithmetic under the pinned-source and Linux
LP64 layout premises; other producer containers remain separate.

## Distinct node and list index spaces

`why-types.ads:35–45` defines signed 32-bit `Why_Int`, node IDs
`0 .. 2^30-1`, and list IDs `2^30 .. 2^31-1`. Both tables instantiate
`Ada.Containers.Indefinite_Vectors` (`why-atree.ads-tmpl:101–116`). Node zero
is an allocated sentinel. No sentinel consumes a list ID: an optional empty
list is an allocated list with zero members. The installed producer's DWARF
and raw [fixed-phase snapshots](retained-producer-fixed.md) independently
corroborate these layouts and the empty list-vector last index `2^30-1`.

Let `N` bound usable node allocations, `L` bound list allocations, and `J`
bound all appends/prepends to retained Why lists, including close-time imports.
The local sufficient conditions are

```text
0 <= N <= 2^30 - 1
0 <= L <= 2^30
0 <= J <= 2^31 - 1.
```

These are resource-vector conditions, not a selected source/String cap.
The complete source rule must supply their arguments. The bound on total `J`
is conservative: each separate list actually needs only its own length to fit.
Useful programs lost to this aggregation must be assessed with the whole rule.

## Append-only vector arithmetic

Before `Free`, Why appends one element per node/list construction; it neither
removes vector entries nor reserves arbitrary capacities. The constructors and
`New_List` call the one-item Append path. Generated node mutators update an
existing element. The only explicit `Reserve_Capacity` calls are the zero
requests after both tables have been cleared in `Free` (`why-atree.adb:38–54`).

For a table with first index `f`, empty last index `f-1`, and final entry count
`d`, `a-coinve.adb:214–248` either allocates the next element directly or calls
Insert with Count=1. With each resulting demand at most `2^30`:

- The caller's `old_last+1`, Insert's `old_length+1`, and
  `new_last=(f-1)+new_length` all fit their signed base types. For lists,
  the largest new last index is exactly `2^31-1`.
- Insert computes `Max_Length=2^30` in both instantiations. The node case uses
  `Index_Type'Last-No_Index`; the list case uses the same nonnegative
  subtraction (`:1236–1283`). The intermediate node-case comparison computes
  `-1+(2^31-1)`, also in range.
- The first allocation has capacity one. Later growth doubles the previous
  capacity, with an explicit guard before multiplication, then clamps to
  `Max_Length` (`:1498–1525`). Thus capacity is the least power of two at least
  `d`, and never exceeds `2^30`. Its largest executed doubling is
  `2 * 2^29 = 2^30`, below `Count_Type'Last=2^31-1`.
- The backbone's last index is `(f-1)+capacity`, within the same checked
  range. Append-only copying uses `Before-1=old_last`, then allocates the
  newly demanded entry (`:1542–1591`). No middle-insertion shifting applies.
- Length evaluates `(last-f)+1`; the intermediate is between -1 and
  `2^30-1` (`:2467–2494`). Clear decrements last only as far as `f-1`,
  then Reserve_Capacity(0) frees the empty backbone.

This argument establishes the arithmetic independently of whether the external
runtime was built with container checks enabled. It does not promise successful
physical allocation. It also does not infer a lifetime allocation count from
the number of currently reachable theory roots.

The Linux layout has an eight-byte pointer per entry and an eight-byte prefix
before the pointer array, as observed in the installed DWARF. For capacity `c`,
the backbone requests `8+8c` bytes; even `c=2^30` needs only 8,589,934,600
bytes, within the target's 64-bit allocation/offset representation. Old and
new backbones coexist during growth. Bounding both by the final capacity gives
the conservative transient backbone sum `16+16c`; element payloads are
separately allocated and shared between these pointer arrays. This is a size
representation argument, not a RAM budget or the size of all producer storage.

## Retained list lengths and copies

Why's list elements are `Why_Node_Id`, stored in ordinary doubly linked lists.
`Append`/`Prepend` allocate one linked-list node and increment the list's
`Count_Type` length (`a-cdlili.adb:155–171,763–813,865–906`). Every individual
length is at most the cumulative retained `J`, so the bound above covers every
increment. There is no contiguous-array growth multiplication for these nodes.
The installed layout has 24-byte link nodes: a four-byte element, padding, and
two eight-byte links. Their aggregate retained payload is bounded by `24J`,
which fits the target's 64-bit byte representation at the count endpoint.

`Get_List` returns a by-value list. Controlled Adjust copies its elements and
increments its own length from one to the original length
(`a-cdlili.adb:114–149`); this does not allocate more Why list IDs or mutate the
stored list. The same per-list length condition covers that copy's arithmetic.
These temporary link nodes remain separate physical storage. A retained-node
counter is not a claim that the peak temporary storage equals the retained sum.

## Standard hashed-map capacity rounding

The producer also uses standard Ada hashed maps, including its symbol-to-theory
map and module-keyed dependency maps. Their element count and bucket-array
capacity are different representations. `a-chtgop.adb:125–132` returns bucket
array length as signed `Count_Type`, whereas bucket indexes and the prime
table use modular 32-bit `Hash_Type`.

`Reserve_Capacity` rounds a positive request up to the next entry of the fixed
prime table (`a-chtgop.adb:677–758`; `a-coprnu.ads:40–46`). The last table entry
that fits `Count_Type` is **1,610,612,741**. The next is 3,221,225,473 and would
not fit Capacity's return type. Therefore a local sufficient condition is
that every explicit reserve request and every map cardinality be at most
1,610,612,741. The nominal Count_Type endpoint alone is insufficient for this
implementation. This is a source-derived rounding condition, not an observed
native failure or a selected source limit.

Ordinary one-key map insertion requests capacity one on an empty map, inserts
at most one distinct key, and reserves the resulting length only when needed
(`a-cohama.adb:628–644`). The generic insertion increments Length once only
for a new key (`a-chtgke.adb:148–199`). The prime search has 28 fixed entries;
its index arithmetic is independent of program size. With the condition above,
bucket indexes, lengths and capacity conversions fit. Rehash decrements a
saved length to zero and then restores it; it does not transiently double the
map's element count (`a-chtgop.adb:766–836`). Copying a map allocates the same
bucket length and increments its own element count up to the source length
(`:49–113`). Bucket pointer storage is at most `8*1,610,612,741` bytes under
the LP64 layout premise, separately from per-key payload and transient copies.

For a map whose distinct keys are Why node IDs and whose only reservations
are zero or its length, the existing `N <= 2^30-1` node condition is already
stricter: its largest possible rounded capacity is 1,610,612,741. The same
applies to the symbol-to-theory map when each distinct key is charged to a
distinct allocated theory node. This does not automatically cover maps keyed
by source nodes, key tuples, arbitrary symbols or external state; their actual
cardinality and reserve requests still need a source-derived bound. Nor does
this claim coverage of ordered, indefinite or GNATCOLL containers merely
because they are called maps.

## JSON string construction and output position

The proof input serializer has two additional representation conditions beyond
node occurrence IDs. `Outputs.P(As_String => True)` first allocates
`String (1 .. S'Length*2+2)`, regardless of how many quotes S actually contains
(`src/utils/outputs.adb:88–119`). Its cursor starts at one, advances past the
opening quote, then once per character and again for each quote. It writes the
closing quote without advancing afterwards. Thus a sufficient condition for
every quoted actual and its multiplication/addition/cursor arithmetic is

```text
S'Length <= 1,073,741,822 = floor((Integer'Last-2)/2).
```

This applies to symbol strings, label-set members and filenames serialized
with As_String, not directly to every source String value. The latter is
represented by character predicates in the producer. The name/label length
transfer must establish the condition for the actual emitted fields. Sparse
quotes do not avoid the full temporary buffer request; physical stack/memory
availability remains a separate premise.

`Print_GNAT_Json_File` emits its header, theory list and closing brace using P,
then closes the file (`gnat2why-driver.adb:1204–1215`). The node/list serializer
also uses P and never NL. Output indentation begins at zero, and no generated
JSON call changes it. This output therefore accumulates in one Text_IO column
count; even an LF embedded in a string passed to Put does not reset that count.
`Text_AFCB.Col` starts at one and has Ada.Text_IO.Count type, whose upper bound
is Natural'Last (`libgnat/a-textio.ads:80–84,675–685`). Character Put adds one;
String Put adds its length (`a-textio.adb:1255–1327`).

Let `T_file` bound every character passed to these output calls for one JSON
file, including punctuation, kind names, decimal IDs, labels, filenames and
all repetitions of shared subtrees. A local sufficient condition is

```text
T_file <= 2,147,483,646 = Count'Last-1.
```

Then every intermediate column update is representable. Closing the file
terminates its line and resets the column (`a-textio.adb:183,1109–1138,2048–2078`); that LF
is not another ordinary P increment. This is a separate condition for each
file; the producer's emitted-node counter remains process-global. The claim
concerns arithmetic in the reviewed path, not an observed failure at that
file size or a newly selected source cap. It makes no assumption that a runtime
built with checks suppressed would diagnose an overflow safely.

The occurrence recurrence counts nodes, not emitted characters. The following
schema transfer connects those occurrences to bytes, with explicit primitive
length premises. These proof-input output constraints cannot be dismissed as
optional report formatting.

### From the schema to a serialized-byte weight

The complete schema has 63 usable node kinds and 177 variant fields
(`src/why/xgen/xtree_sinfo.adb:35–756`). Every emitted node also has its kind,
occurrence ID and Domain. The generator excludes Ada_Node and Checked from
serialization (`xtree_why_ast.adb:169–230`); `xtree_tables.adb:496–563` supplies
the common/variant-field and multiplicity mapping. All nine serialized enums
have implicit representations in 0 through 9 (`why-sinfo.ads:809–848`), so
their Integer Image occupies two characters including the leading space.

For one output file, let:

- `u` bound the byte length of every emitted symbol, label-set member and
  source filename, including fixed dependencies and generated names/comments;
- `h` bound each primitive set's cardinality; the
  [label construction argument](retained-producer-capacity.md#serialized-label-sets-have-cardinality-at-most-three)
  supplies `h=3` for the current source domain;
- `d` bound the exact signed decimal image length of every serialized valid
  Uint, including Ureal numerators and denominators; and
- `O_k` count occurrences of kind k in this file, with `O=sum(O_k)`.

`d <= 1019` ensures that Uint serialization uses the exact value.
`Uint_To_Json` calls `UI_Image(I, Decimal)`. Its Image_Char keeps at most 1019
characters in the 1024-character fixed buffer; further characters enter an
approximation/exponent path (`gcc/ada/uintp.adb:257–455`, `uintp.ads:275–299`).
Do not treat that path as a semantics-preserving way of printing arbitrary
integers. This condition concerns values actually passed to the serializer,
not huge scanner powers that never reach it. Decimal conversion's arithmetic
scratch has the bounded peak below; scanner powers and numeric construction
remain separate Uint allocation populations.

For a symbol of length `s`, output length is `s + quotes(s) + 2 <= 2s+2`.
The template's remaining primitive-field transfers are:

| Field | Upper bound on emitted characters |
| --- | ---: |
| Boolean | 5 |
| Enumerated value | 2 |
| Symbol | `2u+2` |
| Symbol_Set or String_Sets.Set | `2+h*(2u+3)` |
| Source_Ptr | `2u+16` (also covers absent `null`) |
| Uint | `d+2` |
| Ureal | `2d+25` |

The Ureal row includes two quoted Uint images, a Natural image of at most
eleven characters, a Boolean, two brackets and three commas. The Source_Ptr
row includes a quoted filename, physical line image, brackets and comma.
Set commas are charged within that set's row. These follow the complete
serializer template `why-atree-to_json.adb-tmpl:17–156`.

Define `w_k(u,h,d)` as the local cost of node kind k, excluding its children's
bytes. Start with `len(kind)+19`: brackets, quoted kind, occurrence ID image
of at most eleven characters, two commas and the Domain image. Add one comma
per variant field and its primitive weight above. For child fields add zero
for a required node, four for an optional node, two for a required list or
four for an optional list. These latter costs cover brackets or `null`;
present child occurrences are counted separately. Every comma between node
list entries can be charged to its following occurrence, at most one per
emitted node across the whole file, including the top-level theory list.

The exact schema therefore gives the compositional upper bound

```text
T_file <= 29 + O + sum(O_k * w_k(u,h,d)).
```

The 29 consists of the 26-character header, outer list brackets and final
brace. Close's terminating newline is outside T_file. Shared DAG nodes count
again each time serialized; a count of distinct node IDs cannot replace O.
The [schema checker](../evidence/retained-producer-storage-20261018/serialization.py)
retains all 63 coefficient rows, rather than selecting a multiplier from
measurements. Only three rows are undominated for nonnegative parameters:
`58+4u`, `62+2d`, and `85+2u+3h+2uh`. With `h=3`, a simpler sufficient envelope is

```text
T_file <= 29 + O * max(95+8u, 63+2d).
```

This gives a direct composition with the existing occurrence transfers. The
per-kind sum is tighter; tracking actual per-field lengths is tighter again.
The global-maximum envelope may be unnecessarily restrictive for many short
builtin names plus one long source name. Compare those alternatives when
selecting the whole capacity predicate; this research does not adopt the
coarser rule as language membership. Generated-name/comment/filename bounds,
the complete per-file occurrence count must still supply `u` and `O_k` from
the source and configuration. The
[numeric construction argument](retained-producer-numerics.md) and fixed
numeric evidence supply `d=max(11,40)=40`; they do not bound the
separate scanner powers or their temporary allocations.

Without a new producer run, the checker reconstructed all five retained fixed
library JSON files **byte for byte**, including native image whitespace,
quoting and Close's newline, then checked the weighted inequality:

| File's entity | P characters | Occurrences | Observed `(u,h,d)` | Per-kind upper bound |
| --- | ---: | ---: | --- | ---: |
| First_Or_Default | 286,339 | 6,994 | (189,3,11) | 4,078,095 |
| Input_Is_Valid | 121,827 | 3,068 | (186,3,11) | 1,758,490 |
| Is_Message | 85,808 | 2,114 | (182,3,11) | 1,193,345 |
| Put | 274,755 | 6,652 | (171,3,11) | 3,565,361 |
| Put_Line | 288,616 | 7,120 | (174,3,11) | 3,884,397 |

These measured maxima apply to those files; they are not universal Main name
or numeric bounds. The finite checks corroborate the schema traversal and
counting implementation, while the source derivation supplies the general
transfer. The complete fixed output bytes already satisfy the per-file column
condition independently of these conservative weights.

### Decimal conversion needs peak headroom, not cumulative output charges

With the established `d=40`, each serialized magnitude is less than `10^40`,
so it occupies at most nine base-32768 digits (`10^40 < 32768^9`). For one
valid Uint image, the following conservative temporary headroom suffices:

```text
Uint entries       41
Uint digit words   369 = 41 * 9
local vector words 19 = 2 * 9 + 1
Image_Uint depth   40.
```

This is a source transfer for decimal serialization, not a measured maximum.
`UI_Image(Input, Decimal)` invokes Image_Out and returns only after that call
has released its arithmetic scratch (`uintp.adb:1703–1716`). Image_Out saves
both pool Last values with Mark before any conversion (`:257–265,534–537`).
An optional negative normalization calls UI_Negate once. For an indirect value
it appends at most one Uint and nine words through Vector_To_Uint; a direct
negative value is at least `-(32768-1)`, so its negation still fits the direct
range and UI_From_Int does not allocate (`:2153–2185,1466–1507`;
`uintp.ads:464–475`).

The decimal branch never invokes Better_In_Hex or exponentiation. Each
Image_Uint call performs one UI_Div_Rem with divisor ten, then recurses only
on a positive quotient (`uintp.adb:385–415,436–455`). There are at most forty
calls, including the terminal quotient-zero call. A direct dividend uses
direct nonnegative quotient and remainder. An indirect dividend uses the
single-word divisor path: at most one quotient entry with nine words, and a
direct remainder in 0 through 9 (`:1030–1155`). The declared dividend, divisor
and quotient vectors have at most nine, one and nine words respectively.
UI_Div_Vector's largest digit intermediate is `9*32768+32767 = 327679`,
within signed Int. Vector_To_Uint normalizes leading zeros and appends at
most the supplied length (`:2359–2424`). The sign normalization's vector and
comparison vectors are smaller and are not active during a recursive child.
This local-vector count is not a bound on total compiled stack-frame bytes.

No reached path advances Uints_Min or Udigits_Min. UI_From_Int receives only
direct values here; Vector_To_Uint never changes either protected minimum;
the Uint comparisons and UI_To_Int of a remainder allocate no table entries.
The only other writers of those minima belong to initialization,
exponentiation and UI_From_Integral, none of which this path calls. Both minima
are at most their entry Last values. Therefore the final Release restores
**exactly** the two saved Last values (`:680–688`), even when earlier work
has pinned a nonzero minimum. Growth may retain backing capacity, but its
largest request is bounded by entry demand plus this headroom, using the
separate generic-table growth envelope.

The serializer completes each UI_Image before passing its returned String to
P (`why-atree-to_json.adb-tmpl:20–43`). Ureal's numerator and denominator
images are also sequential. The generated recursive traversal cannot suspend
an active numeric conversion while visiting another field. Thus add 41 entries
and 369 digit words **once to the retained numeric-pool peak at serialization**,
not once per occurrence or output file. The forty-deep image recursion is
separate from the serializer's own node-recursion depth. This closes only
decimal output scratch: diagnostic Auto/Hex images and producer numeric
construction still need their own transfers.

The storage checker retains the relevant complete-source identities and
LF-numbered excerpts, checks the radix/direct-range arithmetic and all decimal
length/radix boundaries through forty digits, and inventories every protected
minimum assignment. These finite checks corroborate the source argument; they
do not replace its caller and lifetime reasoning.

## Scope and reproduction

The [evidence checker](../evidence/retained-producer-storage-20261018/README.md)
checks source identities against the complete retained GCC manifest and
recomputes these boundary transitions without allocating large tables or
executing a compiler. The source is GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the producer template is the retained
SPARK candidate. Their relevant correspondence to the installed producer is
still the explicit [source-identity premise](retained-tool-source-identity.md).

This covers the two Why storage vectors, retained Why list lengths, standard
hashed-map arithmetic and the stated JSON output conditions. Symbol
storage, other auxiliary maps/sets/vectors, temporary container multiplicities,
tampering counters, source-derived serialization parameters, recursion and other phases
are not proved safe merely by these local conditions. They remain in the whole-process
capacity inventory. No production admission or tool pin changes here.
