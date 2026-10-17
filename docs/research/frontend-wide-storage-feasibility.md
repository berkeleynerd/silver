# Wider frontend storage: concrete design and limits

**2026-10-17 — research for #113.** A local widening of GNAT's shared String
character pool is a credible repair for the representation obstruction found
in [the pinned lifetime audit](unbounded-frontend-lifetimes.md). It can preserve
the current static evaluator and its public String operations. It does not
require globally widening `Types.Int`, `String_Id`, or every AST field. A
zero-mantissa fast path in integer-literal scanning is preferable to widening
the numeric pool solely to accommodate retained, unused powers of ten.

These are candidate designs, not implemented or verified changes. They do not
establish full-language frontend, backend, proof-producer or solver capacity.
In particular, retaining materialized Strings leaves work proportional to their
expanded lengths, including in GNATprove. Tool ownership is a separate condition:
this document supplies no exemption from the verified-SPARK rule for a
Silver-maintained Ada/C++ compiler fork. The combined research must resolve that
route before implementation can be proposed as permissible.

## Evidence and scope

All GCC source references below are to commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Ada tree
`a3b9f0d4c999c8c127cebdc239ca8218284137aa`. The preceding audit verified every
file in that subtree against its Git blob hash. This continuation rechecks and
retains the relevant package snapshots, an interface inventory and exact
arithmetic in the
[evidence directory](../evidence/unbounded-programs/frontend-wide-storage-feasibility-20261017/README.md).
The older complete inventory remains authoritative for the lifetime search;
it was not rerun. Applying upstream-source conclusions to a particular installed
binary still requires the source-correspondence premise recorded there.

The work is source inspection and integer arithmetic on Linux x86_64. No
compiler patch, compiler build, tool adoption, native capacity probe, complete
proof run or macOS validation was performed for this evidence stream. No
membership rule or lower domain cap is selected. Implementation #88–#94 remains
unstarted. Authorization is #113 through PR #114, merge `b8e618c545`.

## Narrow String-pool design

Keep `String_Id` at 32 bits, per-value `Length : Nat` at
`0 .. 2^31 - 1`, and `Char_Code` at 32 bits. `Char_Code` is a general Ada
character representation; changing it to one byte merely because today's
Silver String contains `Character` would alter the compiler's wider contract.
Keep the existing `Start_String`, `Store_String_Char(s)`, `String_Length` and
`Get_String_Char` semantics. Static concatenation continues to evaluate in the
frontend, and the original author source remains the compiler/prover input.

Introduce a checked, wide pool-position/count type using `Types.Int_64` or an
equivalent explicit 64-bit type. Widen these fields and operations together:

| Surface | Pinned source | Required candidate change |
| --- | --- | --- |
| Character storage | `stringt.adb:36–42` | Dedicated wide pool or focused wide-table variant; do not change unrelated compiler tables. |
| Descriptor offset and saved tail | `stringt.adb:48–50,66–67` | Widen `String_Index` and `String_Chars_Last`; retain `Length` and `Strings_Last` types. |
| Scalar, copy and bulk access | `stringt.adb:98–101,157–192,198–243` | Convert within-string indices/lengths before adding to wide offsets; widen `S_First`, `Old_Last`, `New_Last`; preflight resulting lengths and capacity. |
| Restore and trim | `stringt.adb:135–149,123–129,361–375` | Preserve paired logical-tail restoration, locking, and unstore behavior with wide state. |
| Table mechanics | `table.ads:227–237`; `table.adb:40–46,168–260,299–373,397–410` | Replace internal Int counts, conversions and saved maxima for the character pool; check growth, byte size, one-past and alias arithmetic. |
| C descriptor and accessor | `stringt.h:51–55,73,86–87` | Widen offset field and pointer-index arithmetic; keep length and external String ID widths. |
| Address handoff | `back_end.adb:92–114,169–170`; `gcc-interface/gigi.h:250–270`; `gcc-interface/trans.cc:99–100,307,334–335` | Rebuild matching Ada and C/C++ users; raw addresses themselves need no new argument shape. |
| AST storage | `gen_il-gen-gen_nodes.adb:189,349`; `sinfo-utils.adb:470` | Keep 32-bit `String_Id`/`Strval`; no global AST representation change is required for this pool. |

Simply replacing `Table_Index_Type => Int` with a wider actual fails:
compiler `Table` hardcodes `Last_Val`, `Min`, `Max`, `Length` and saved state
as `Int`. Merely widening those variables also leaves allocation and access
arithmetic to repair. A separate checked pool confines the review to the actual
String storage surface rather than changing every compiler-table instantiation.

The Ada descriptor and `struct String_Entry` must agree exactly. An explicit
LP64 layout with a 64-bit offset at byte 0, 32-bit length at byte 8 and a
16-byte stride is a candidate, not a measured result. Establish the Ada
representation/alignment and C `sizeof`, `offsetof` and width assertions in the
eventual implementation. The present descriptor occupies two 32-bit fields;
the candidate therefore increases descriptor storage as well as pool capacity.
This is an internal compiler ABI change: mixed old/new producer and consumer
objects are invalid, while user-program linkage need not change for this reason.
The single-value length and within-value accessor index can remain 32-bit;
backend storage arithmetic at that maximum still needs its own review.

## A derived finite bound for this pool

The useful claim is conditional and narrower than “64 bits is enough for the
compiler.” `types.ads:348–350,504–512` assigns the nominal String ID range
`-499_999_999 .. -400_000_000`; the first value is `No_String`, leaving
**99,999,999 descriptor IDs**, including the null-string descriptor. Set:

```text
N = 99,999,999                         descriptor IDs
L = 2,147,483,647                      maximum per-descriptor length
P = N * L = 214,748,362,552,516,353    maximum charged character slots
4P = 858,993,450,210,065,412           payload bytes, below 2^60
32P = 6,871,947,601,680,523,296        payload bits, below 2^63
```

Under checked descriptor allocation, completed String operations maintain a
pool length no greater than the sum of the lengths of all retained descriptors,
and hence at most `P < 2^58`. This is a conservative bound; the null descriptor
and shared tails make equality unnecessary. It is justified by the actual
allocation/lifetime shape:

1. A fresh descriptor initially owns no characters. Starting from an old value
   either shares the current tail or copies at most that value's length into
   the new descriptor. Each store charges its appended characters to the
   current descriptor. Losing an AST reference does not remove its descriptor.
2. Tail sharing reduces allocation. `Unstore_String_Char` reduces both current
   length and pool tail; its pinned callers repair an unterminated lexical
   literal, rather than deleting a completed value while leaving its payload.
3. `Stringt.Release` restores both tails from `Mark`. The only external pair
   in the pinned tree surrounds checksum scanning; no semantic-phase collection
   removes descriptors but leaves their uncharged payload behind. The ordinary
   compilation route does not cycle through these releases.

The invariant must include **in-flight reserved characters**. The old
`Start_String(S)` increments the descriptor count and copies before setting
the new length, and stores append before updating length. Thus
`pool_length <= sum(lengths)` is a completed-operation invariant, not true at
every old instruction. Preflight the new descriptor count, completed length
and required capacity, reserve the pending charge, then commit the operation;
an allocation failure must not continue with half-committed state. Mark/release
also needs completed-string boundaries, as used by the pinned checksum caller.
This bounds peak logical storage, not cumulative work over arbitrary repeated
release cycles or the whole compiler's running time.

**The present code does not enforce all these premises.** `Strings` uses
`String_Id'Base` (`stringt.adb:55`), so nominal ID exhaustion is not automatically
checked by that instantiation. The candidate needs explicit checked descriptor
allocation and a source-sensitive accounting argument that admitted programs,
including compiler-generated/dependency Strings, stay within the existing ID
domain and per-value lengths. An exhausted ID/representation guard is a
tool-capacity diagnostic, not physical exhaustion. Adding guards alone does
not satisfy the Oracle for every admitted program. This argument derives a
pool bound from existing types; it does not adopt a new convenient lower cap or
complete the still-open source-capacity rule.

## Checked allocation and work

Use a bounded pool-position type supporting the empty-tail sentinel `-1` and
one-past positions, and a bounded designated-array range, for example `0 .. P`
for the nominal pointer view. Blindly choosing
`Big_Table_Type (0 .. Int_64'Last)` makes the array's nominal byte/bit size
unrepresentable. Even `(P + 1) * 32` fits signed 64-bit arithmetic; the retained
calculation checks the relevant one-past margin. Establish compiler support for
the chosen explicit array/index representation rather than inferring it from
the scalar width alone.

For the existing 150% increment, one possible growth rule, when more capacity
is required, is:

```text
new_capacity = max(requested, min(P, max(old + 10, (5 * old) / 2)))
```

Here integer division rounds down, `0 <= old < requested <= P`, and initial
capacity is positive and no greater than `P`. `5P < 2^60`, so this expression
and `old + 10` fit signed 64-bit arithmetic. By contrast, the old percentage
expression `old * 250 / 100` can overflow 64 bits before dividing at this
derived maximum. The cap is the representation-derived `P`, not a lower
language limit. The rule reserves a bulk request in one growth step, advances
strictly when needed, and never exceeds `P`.

Check byte multiplication before converting to the allocator's `size_t`, and
check alignment, pointer difference and one-past arithmetic on each supported
host. A 64-bit Linux process has scalar widths sufficient for these particular
derived sizes; it does not have a promise that the address space or RAM can
fulfil an allocation. Preserve a defined physical-allocation failure route.
Preserve `Table.Set_Item`'s protection against an argument aliasing storage
that is reallocated, or use a value copy for the scalar character argument.
Bulk self-copy must retain Ada slice semantics and evaluate source offsets
against the relocated pool; a naive C `memcpy` is not a substitute where ranges
overlap. Locked addresses must remain fixed during Gigi processing.

Each pool operation then has bounded loops over the requested finite String
length, and allocation either succeeds or returns a defined failure. For an
append-only phase, geometric growth gives total relocation work proportional
to final pool size; reserve jumps do not worsen that asymptotic bound. This
does not bound all semantic queries, rewrites, proof tasks or solver behavior.
The two-chain witness still requires at least **8 GiB of character payload**
before spare allocation, descriptors, transient copies and backend objects.
Widening makes that materialization representable, not compact or inexpensive.

### Existing generic tables are reuse material, not a complete fix

`GNAT.Dynamic_Tables` (`libgnat/g-dyntab.ads:100–127,282–289`) derives last,
capacity and array indices from `Table_Index_Type'Base`. Unlike compiler
`Table`, it therefore structurally accommodates wide index arithmetic.
`GNAT.Table` (`libgnat/g-table.ads:34–40,63–85`) is its singleton wrapper and
exports familiar `Table` and `Locked` views. These packages are concrete
in-tree alternatives that should be considered before inventing an unrelated
container.

They are not an already safe drop-in replacement at `P`. Dynamic_Tables.Grow
still multiplies by a percentage in `Long_Long_Integer` before dividing,
uses unsaturated `New_Length + 10`, and builds its nominal array from the
index type's base maximum (`g-dyntab.adb:145–178`, `.ads:126–127`). Constraining
only a subtype actual does not repair use of its base range. Growth allocates
a new array and copies the old before freeing it (`.adb:181–205`), increasing
transient memory. Release has additional length arithmetic and can allocate
and copy again (`.adb:298–371`). A focused adaptation with checked growth,
bounded representation and preserved locking is plausible; swapping package
names is not the result of this research.

## Numeric literals: avoid an unnecessary large value

The prior lifetime audit established that `0E799999` retains a large power
although its value is zero. The narrow candidate is in `Scng.Scan.Nlit`, in
the integer branch at `scng.adb:764–785`: **inside the existing semantic-
computation condition**, after the existing `UI_Scale >= 800_000` diagnostic,
return `Uint_0` when `UI_Num_Value = Uint_0`; otherwise retain the existing
multiplication by the base power. Patching only `UI_Mul` is too late because
its exponentiation argument has already been evaluated.

This preserves lexical scanning, checksum work, exponent spelling/diagnostics,
the zero-scale path, syntax-only `No_Uint` behavior, negative-exponent checks
and real-literal handling. In particular, `0E800000` must still receive the
existing diagnostic; this is a semantic-computation optimization, not an
extension of the accepted numeral grammar.

For the intended Silver integer-literal grammar, a nonzero admitted magnitude
is at most `2^31`, including the unary-minus endpoint. With base at least 2,
such a numeral has exponent at most 31; for decimal, at most 9. Large
nonnegative exponents in otherwise admitted integer literals are therefore
useful only with a zero mantissa. The fast path removes that specific retained
power and exponentiation work. It does not make arbitrary compiler-generated
universal integers small, bound arbitrary malformed input, or settle the
remaining aggregate numeric-pool rule.

Widening `Udigits` instead has a larger surface and leaves the unnecessary
power computation in place:

| Surface | Pinned source | Consequence |
| --- | --- | --- |
| Digit pool and descriptors | `uintp.ads:540–586` | Widen `Save_Udigit`, `Uint_Entry.Loc`, pool indices and internal table arithmetic; per-value digit `Length : Pos` can remain separate. |
| Lifetime and arithmetic helpers | `uintp.adb` (inventory in evidence) | Widen saved/local locations, protected minima, release/copy/slice calculations; preserve `Release_And_Save` behavior. |
| Foreign descriptor and access | `uintp.h:36–40,104–108`; `gcc-interface/cuintp.cc:93–95,116–120` | Change duplicated layout and C offset/index arithmetic together. |
| Temporary integer vectors | `uintp.h:78–85`; `gcc-interface/cuintp.cc:179,208–209` | The descriptor carries 32-bit vector bounds; widening pool offsets does not by itself widen vector lengths or remove their allocations. |

A checked descriptor-count times per-value-length argument could similarly
motivate a 64-bit Udigits pool, but needs its own lifetime/reservation and
source-capacity proof. It is not necessary merely to fix zero-mantissa powers.

## Recommendation and remaining obligations

Prefer the local checked String-pool widening plus zero-mantissa fast path as
the narrow frontend candidate. Its storage arithmetic and representation
invariants are concrete and finite, and it preserves the existing static
evaluator. Deferred storage may reduce materialization substantially, but needs
a different consumer-wide semantic argument; the parallel deferred-storage
study owns that comparison.

This candidate repairs one component, with these prerequisites still open:

- A permissible ownership and distribution route for compiler changes, with
  no implied waiver of Silver's verified-SPARK policy.
- Complete accounting for admitted sources, dependencies, generated descriptors,
  other compiler tables and phase peaks; guards alone are insufficient.
- Matching rebuilt Ada/C/C++ layout, allocator checks and actual-source
  correspondence for compiler and GNATprove frontends on Linux. Native macOS
  validation remains independent; shared field widths do not constitute it.
- Backend handling of values near the per-String maximum, and a producer
  design whose representation and automatic-discharge argument covers the
  intended language. The inspected GNATprove route creates per-character Why
  terms, so merely widening Stringt does not address producer expansion.
- Eventual implementation proofs of operation safety, termination and
  value preservation, followed by discriminating interface/semantic tests.
  A giant allocation experiment would not establish these universal claims.

The scoped representation repair is tractable as a design. Production
readiness and the larger-language guarantee are not established; a tool
ownership conflict or unsatisfied producer-capacity premise remains a precise
stop rather than a reason to quietly admit a narrower language.
