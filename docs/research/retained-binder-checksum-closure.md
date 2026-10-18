# Reviewed output-binder checksum lifetime closure

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The derivation below was accepted without material findings by the
[independent Astra Extra High review](../evidence/retained-binder-checksum-closure-20261018/review.md).
Its complete frozen inputs and offline replay are retained in the
[closure packet](../evidence/retained-binder-checksum-closure-20261018/README.md).
This closes the specific varying-checksum lifetime gap in the historical
[ingress checkpoint](retained-binder-checksum.md) and
[split-option reconciliation](retained-binder-options.md).

The accepted family bounds are **5,167,732 cumulative rounded GGC bytes**,
**56,378 positive allocation events**, and a **262,144-byte largest rounded
request**, for every uint32 Main checksum in the selected output binder. The
rounded total is **75,148 bytes below 5 MiB**. Separately, the baseline's two
Uint rows and six digits dominate the variable literal; at most one additional
ordinary 16-byte UI_Ints wrapper is needed. Use these family GGC bounds in the
predecessor's page/finalizer formulas instead of its fixed-checksum witness
numbers.

The scope remains conditional on the inherited fixed source/options/dependency/
path projection and documented relevant-source-to-installed-behavior, ABI,
allocator and physical-resource assumptions. Production options and admission
are unchanged. This is not whole-tool capacity or discharge of the remaining
Main/link/producer conjunction, and it adds no macOS validation or historical
compiler-build identification.

Packaging used the assigned GPT-6.1 Sol Extra High baseline after the separate
named Max argument and its independent review. It took approximately two minutes
through the successful fidelity check and replay, with no arithmetic rework.
This round adds no proof argument:
it retains the reviewed derivation, review and identities, checks archive/source
fidelity, and replays the unchanged arithmetic in an isolated temporary tree.
There was no native rerun. Token and monetary measurements were unavailable.
The candidate's original pending-review status strings below and in the frozen
result are preserved as history; the linked review supplies the accepted verdict.

<!-- Begin unchanged reviewed derivation. -->

# Checksum lifetime transfer: bounded derivation for review

2026-10-18, #119. GPT-6 Astra Max, the named escalation for the global integer
cache argument. Started at approximately 14:40 UTC. Source analysis, retained
counter replay, arithmetic checks and read-only installed-ELF inspection; no compiler, prover, Lean or native
validation execution. This directory is the complete deliverable; no repository
file was edited. No option change is needed for the bound below. Integration and
independent review remain with the lead.

The candidate bound is **5,167,732 cumulative rounded GGC bytes**, below the
already justified 5 MiB first-collection threshold by **75,148 bytes**, for
all 2^32 Main checksums in the selected output binder. At most 56,378 positive
allocation events and a 262,144-byte largest rounded request suffice. These
replace the fixed witness's corresponding 4,481,000 / 50,974 / 131,072 numbers
when applying the preceding GGC page/finalizer formulas. This closes this
checksum transfer under the predecessor's fixed-source/options/path projection
and relevant-source-to-installed-behavior premise; it is not a new proof of
those premises, a whole-tool capacity result, or an independent review verdict.

`check.py` verifies the retained file identities, replays the complete counter
stream, derives the cutoff counts, checks the finite prime-table inequalities
and evaluates all formulas below. It does not establish the source reasoning
merely by passing. `manifest.json` retains source identity and all input hashes.
The complete sources are in `sources/`; complete predecessor counter events,
summary, binder sources, invocation and predecessor manifest/result are in
`inputs/`. Source commit: `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

## Read projection and multiplicity

The binder spec contains one changing declaration, `u00001`, an eight-digit
based literal of the fixed Version_32 modular type, exported as `mainB`. Its
only other occurrence is the export association; there is no expression
reference to it. The body contains no reference. The
other 139 version declarations and all bodies/dependencies/options are fixed.

1. Parsing constructs one integer literal. `sem_ch2.adb:111–132` marks it static;
   `sem_res.adb:9825–9829` assigns its fixed expected type and invokes
   `Eval_Integer_Literal`. The latter (`sem_eval.adb:2772–2834`) and
   `Check_Non_Static_Context` (`:478–654`) test membership in the fixed
   [0, 2^32−1] range. `Test_In_Range` (`:7354–7500`) obtains `Expr_Value` and
   compares it with the bounds. The integer-literal arm of `Expr_Value`
   (`:4589–4686`) returns the existing Uint and updates a fixed-size scalar
   cache. Uint comparisons (`uintp.adb:1665–1852`) use local digit vectors and
   do not append Uint rows or allocate hash nodes.
2. The explicit scalar object initialization in `sem_ch3.adb:4700–4852` resolves
   that literal once and applies the scalar range check. The static path in
   `checks.adb:3155–3430`, `Determine_Range_To_Discrete` at 6112, and
   `Determine_Range` at 5071–5197 returns the same value as both endpoints and
   finds it in range. The object expander's corresponding check at
   `exp_ch3.adb:8420–8470` is the same operation; it creates no range-check
   node for any checksum. Integer literals have no specialized expansion
   (`expander.adb:518–523`); static validity is immediate
   (`checks.adb:6921–6972`). The scalar, noncontrolled, nonaliased, nonaccess,
   nonaggregate declaration takes no value-dependent subtype/finalization/
   renaming path. Its size and alignment come from Version_32, not the value.
3. `trans.cc:6775–6880` translates the initializer once. Its integer-literal
   case (`:6610–6637`) invokes `UI_To_gnu` once with the fixed unsigned32 type.
   A deferred freeze reuses the saved GCC initializer rather than retranslating
   it (`:9847–9857`); ordinary entity references reuse the saved entity
   (`decl.cc:395–416`). Export does not read its value as executable code.
   The type is obtained before conversion from the existing fixed type
   (`decl.cc:5150–5177`), whose declaration creates unsigned32 from the fixed
   `esize` (`:1869–1900`).
4. `cuintp.cc:76–164` requires at most eight constant-constructor requests in
   one unsigned32 type. No intermediate overflows, widening retry or new type
   occurs. Constant/constant folding returns an integer constant, as already
   established in the predecessor. At the end of `gnat_to_gnu`, the result
   type already agrees (`trans.cc:8953–8965`). The object path can call
   `convert` twice (`decl.cc:1263,1607`); for this ordinary type both are
   identities (`utils.cc:4999–5007`). Even allowing a distinct already-existing
   main variant used by `simple_constant_p` (`decl.cc:798–800,10225–10233`)
   gives at most two additional constant requests, hence at most ten per run
   in at most two persistent types. The bound below reserves 32 extra misses,
   exceeding the union of these old/new key sets (at most twenty).
5. Static readonly initialization stays constant and public
   (`decl.cc:1610–1640`, `utils.cc:3018–3112`). `initializer_constant_valid_p`
   accepts an INTEGER_CST independently of its value. Global `add_decl_expr`
   marks the initializer without building executable assignment code
   (`trans.cc:9104–9190`). Its walk mutates visited bits, not numeric values.
   The predecessor's selected O0/no-debug/no-constant-merging read projection
   therefore continues to cover all executable functions, declarations,
   types and other allocation requests.
6. Zero does not move this readonly non-COMMON object to BSS
   (`varasm.cc:1107–1122,7383–7424`). `assemble_variable_contents`
   (`:2452–2480`) emits four zeros for value zero. Every nonzero value makes
   one `output_constant` call whose integer arm (`:5534–5548`) calls
   `expand_expr` once. Its INTEGER_CST case (`expr.cc:11757–11784`) reaches
   `immed_wide_int_const_1` (`emit-rtl.cc:655–669`), `gen_int_mode` and
   `gen_rtx_CONST_INT` (`:525–553`). There is at most one varying RTL integer
   key and one direct RTL integer node. The following assembler output reads
   that integer; no integer-derived instruction graph is compiled. This is
   why fixed ELF width alone was insufficient, and why the RTL cache is
   included explicitly here.

The possible varying GGC allocation requests are consequently the GCC tree
integer nodes, at most two lazy small-integer vectors, global tree-integer cache
backing arrays, and the single final-emission RTL integer/cache. All remaining
requests use the inherited unchanged semantic graph projection. A layout proof
is not being substituted for this allocation projection.

## Coupling requests and misses despite deletions

The relevant source defines the tree global table privately in `tree.cc`.
Outside GC, the only insertions are `wide_int_to_tree_1` at 1921/1940 and
`cache_integer_cst` at 2129. The latter is called only by LTO reading and C++
modules, absent from this command (`tree.h:5744` declaration; actual callers
in `lto/lto-common.cc` and `cp/module.cc`). The only explicit removals are
`type_hash_canon:6467,6473`. Both remove a min/max constant **whose TREE_TYPE
is the newly rejected candidate type**; the accepted existing canonical type
is retained. Neither can remove a key in the persistent Version_32 type (or
its existing main variant) used for the checksum. No collection occurs before
a hypothetical first collection, so the weak-cache sweep is absent in that
prefix. This last statement is part of the first-collection contradiction,
not an assumption based only on the baseline's zero marker count.

All unchanged-key operations, including temporary-type deletions and subsequent
reinsertions, are the same in both runs. Their hit/miss behavior is independent
of probing once the key's presence is fixed. The changed old/new key sets are
never deleted. A missing old key can cause one additional later fixed-key miss;
a new variant key can itself cause one miss. It cannot cause an unbounded chain
of additional misses after deletions. Reserving 32 total extra tree misses and
32 direct 24-byte nodes therefore dominates the at-most-twenty key union,
including displaced later misses. This does **not** assert that lookup count
equals observed allocation count.

A baseline miss in the one-limb path immediately allocates its next 24-byte
scratch INTEGER_CST (`tree.cc:1929,2926–2942`). A multiple-limb path allocates a
node of at least 24 bytes before lookup (`:1939`). Thus the number of baseline
misses after the retained pre-binder cutoff is at most the number of *all*
positive GGC requests of at least 24 bytes in that suffix: **10,700**. Tree
layout is 8-byte tree_base + one pointer + one HWI = 24 for the one-limb node
(`tree-core.h:1138–1245,1565–1580`), with 8-byte pointer/HWI in the selected
native ABI; the 24-byte GGC class exists (`ggc-page.cc:145–184`). Multiple limbs
only increase the request. The enlarged miss budget is

```
I = 10,700 + 32 = 10,732.
```

This is an upper bound for **all** variant tree-cache misses in the suffix,
not just checksum-local calls.

## Hash-table backing-array lemma

Let S be prime capacity, N occupied-or-deleted count, D deleted count, and L=N−D
live entries. INSERT lookup expands when 3S <= 4N, including lookup hits.
An empty-slot insertion increments N; tombstone reuse does not. Removal
increases D and leaves N unchanged. Expansion sets N=L and D=0.

`hash-table.h:830–902` chooses either the same S with 2L<=S, or the first prime
at least 2L; hence after **every** expansion, including compaction and shrink,
N<=floor(S/2). Before the next expansion, at least

```
g(S) = ceil(3S/4) − floor(S/2)
```

new-empty-slot insertions must occur. These are a subset of misses. On the
selected pointer ABI, the requested array is 8S bytes. The rounded allocation
is at most next_power_of_two(8S); the presence of smaller extra GGC classes
cannot increase that upper bound. For every actual prime through 32,749,

```
next_power_of_two(8S) <= 33*g(S).
```

`check.py` verifies that finite inequality from the retained `hash-table.cc`
prime table. Therefore charge every allocated array **except the last** to
new empty insertions occurring after it and before the next expansion. The
intervals are disjoint. Their sum is at most 33I. This charges repeated
same-size tombstone compactions too; no no-deletion or exact-probe hypothesis
is used. The final array is charged separately at its maximal size.

To bound that maximal size, the shared prefix has no rounded allocation larger
than 131,072 bytes. Since every array request includes 8S bytes, the tree-cache
capacity at the cutoff is at most 16,381. The lookup invariant gives
N<=ceil(3S/4)<=12,286. At any later time,

```
N <= 12,286 + I = 23,018 < ceil(3*32,749/4) = 24,562.
```

Expansion from a smaller prime cannot skip past 32,749: at an expansion
N=ceil(3S/4), L<=N, and the next-prime choice is at most the next larger prime
(checker covers every possible live count). Once capacity 32,749 is reached,
its expansion guard cannot hold. Shrinks are already covered. Thus every suffix
array has capacity <=32,749 and rounded size <=262,144. The complete bound is

```
all variant tree-cache suffix arrays <= 33*10,732 + 262,144 = 616,300 bytes.
```

Adding this full variant amount to the baseline total deliberately double
counts any baseline suffix arrays. No attribution of the baseline's array
allocation sites is needed. At least two misses separate expansions for every
allowed prime, so at most floor(I/2)+1 = 5,367 suffix array events suffice.

## Other GGC corrections and first collection

A lazy unsigned small-integer vector has 251 slots. `make_tree_vec` uses
24+8*251=2,032 requested bytes, rounded to at most 2,048. Reserve two such
vectors, although Version_32's fixed zero bound ordinarily initializes its
small cache already. The vector allocation is not omitted for the zero/small
checksum cases.

The RTL `const_int_htab` is separate. `emit-rtl.cc` has only its initialization
at 6355 and INSERT lookup at 536; there is no non-GC deletion. Each miss
allocates a raw CONST_INT whose selected layout is 8-byte header plus one
8-byte HWI (`rtl.h:314–455,703`, `rtl.def:346`, `rtl.cc:112–132,221–245`),
rounded to 16 bytes. The entire baseline has only **3,556** 16-byte allocation
events. One changed output key adds at most one distinct global key, so 3,557
is a conservative total. Its capacity cannot grow past 8,191 (threshold 6,144).
As a monotone table with one extra possible key, its capacity sequence differs
by at most one final prime step; earlier growth is the same sequence moved in
time. Reserve one additional 65,536-byte backing array. Reserve two 16-byte
nodes to include both changed-key and possible later displaced miss effects.

```
Tree-cache suffix backing arrays       616,300
RTL additional backing array            65,536
32 additional tree nodes, 24 bytes          768
2 lazy small caches, 2,048 bytes          4,096
2 RTL nodes, 16 bytes                       32
                                      -------
Total correction                       686,732
Baseline                             4,481,000
                                      -------
Universal cumulative rounded bound   5,167,732 < 5,242,880
```

The fixed semantic graph supplies no extra declaration/type UID increments.
At any hypothetical first heuristic collection, allocated bytes cannot exceed
cumulative rounded allocation and this bound is below the inherited threshold;
therefore that first collection returns before marking. This discharges the
no-GC premise used above. The predecessor's exclusions of forced collection,
statistics/self-tests/reader paths remain necessary and unchanged.

## Ada Uint and ordinary allocations

The previous scanner bound of 16 arithmetic calls can be sharpened. All first
seven prefixes are <=16^7−1 < Max_Direct=(32768−1)^2. Their products/sums return
direct values even when the general arithmetic path is taken. Only the eighth
multiply/add can store rows: at most **two rows, six digits**, already attained
by the baseline d02a2ed5 (its final product exceeds Max_Direct and digit 5 is
nonzero). Stack digit vectors have at most four Int entries in the addition
scratch result, while a stored value needs at most three.

`UI_Mul`'s UI_From_Int branch requires both operands <=32,768, so its product
with 16 is below Max_Direct; it cannot introduce an indirect cache key here.
`UI_Add` can introduce such a key only when its product operand is still direct
and adding the final digit crosses Max_Direct. These are precisely the fourteen
values **1,073,676,290 through 1,073,676,303**. The baseline introduces no such
key. Thus there is at most one additional UI_Ints cache element. This is a
fixed 1,023-header chained `Simple_HTable`, with no resize; its element request
is Key:Int(4)+Element:Uint(4)+Next:pointer(8)=**16 bytes**
(`uintp.adb:89–107,1466–1506`; `libgnat/s-htable.adb:226–235,375–384`). It is
ordinary Ada heap allocation, not GGC.

The variable literal is only read thereafter as described above. The added
cache key can turn later fixed UI_From_Int misses into hits, never the reverse,
because the baseline contributed no variable key. The parser/scanner does not
save/release Uint marks around this token; the arithmetic multiply/add paths
also do not. Later marks are after the parsed literal. Its possible Uints_Min
update is therefore below those marks, and does not pin additional later
scratch rows. Later changed cache hits suppress the baseline's later allocation
and later minimum advance, so they cannot increase retained-row/digit maxima.
The baseline's two rows/six digits dominate this literal's contribution; the
extra ordinary allocation correction is one 16-byte wrapper. There is no
value printing under selected no-debug/default-dump options; `lib-writ.adb:809`
prints integer expressions only in selected annotation pragmas, not object
initializers, and `lib-xref.adb` does not read Intval/Expr_Value.

This is a correction to the inherited binder frontend table/storage argument,
not a standalone new numeric bound for all its Ada tables. The first-collection
result and all GGC backing formulas are numerically explicit above. Physical
resource availability and ordinary allocator semantics remain trusted as in the
parent investigation; no aggregate RAM limit is introduced.

## Installed layout check and handoff

Read-only ELF inspection of the same pinned `gnat1` SHA-256
`5bf9b821ec0388ca6a6962dbc4bcb5773799926445fede6356069357c48dd58e`
confirms the ABI-sensitive allocation sizes. At 0x1694ac0, make_int_cst
computes 16+8*ext_len before the cleared allocator call; ext_len1 is24. At
0x1694b0b, make_tree_vec computes24+8*len. The emission function passes
rtx code0x21 to rtx_alloc at0xedceb5; rtx_code_size[0x21] at0x2cdf201 is16.
Exact instruction bytes, code-size byte and readable disassemblies are retained
and checked by the replay. These local checks supplement the inherited
relevant-behavior correspondence premise; no historical compiler build inputs
are newly identified. No frontend was executed.

Elapsed approximately16 minutes including documentation and static ABI checks.
No token/cost measurement was available. The named Max reasoning obligation
now has a bounded derivation; subsequent integration should return to the
appropriate baseline and receive independent review. The critical review points
are the persistent-type key coupling, preservation of the predecessor's other
request-graph projection, and the Uint mark/cache dominance argument.
