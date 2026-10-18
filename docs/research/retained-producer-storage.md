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

The existing occurrence recurrence counts nodes, not emitted characters, so
it does not alone establish T_file. Extend it with serialized primitive-field
lengths, collection delimiters and repeated labels to obtain that weight from
source. The fixed probes retain actual emitted files for their finite cases;
variable Main's complete byte transfer remains required. These proof-input
output constraints cannot be dismissed as optional report formatting.

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
tampering counters, complete serialization bytes, recursion and other phases
are not proved safe merely by these local conditions. They remain in the whole-process
capacity inventory. No production admission or tool pin changes here.
