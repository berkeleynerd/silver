# Output binder checksum ingress checkpoint

Research #119, 2026-10-18. This bounded source-only investigation identifies the
remaining transfer needed to extend the fixed output-binder lifetime capture to
every Main checksum. It does **not** close that transfer. Production options and
admission remain unchanged. No compiler, prover, Lean, or broad test ran.

The [preceding binder-option packet](retained-binder-options.md) establishes
4,481,000 rounded GGC bytes for the fixed output capture, below the conservative
5,242,880-byte first-collection threshold by 761,880 bytes. Its arbitrary-checksum
claim remains false. The [new packet](../evidence/retained-binder-checksum-20261018/README.md)
retains sixteen complete source files, corpus identities, and the predecessor
specification/result. The source commit is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; this checkpoint adds no new installed
binary-to-source correspondence claim.

Only the eight digits of `u00001 : constant Version_32 := 16#d02a2ed5#;`
vary in the selected binder spec, among 140 Version_32 constants. Its export is
`mainB`. The earlier output record establishes the constant-width object layout;
that does not establish frontend allocation lifetime.

## Local ingress bounds

`scng.adb:436–790` scans the fixed `16#hhhhhhhh#` spelling with eight repetitions
of `UI_Int_Value * UI_Base + Extended_Digit_Value`. Every prefix, product and sum
is between zero and 2^32−1. There is no exponent; `UI_Scale = 0` returns that
value. Checksum accumulation itself updates scalar CRC/token state.

`uintp.ads:464–475` uses base 2^15, so every such value needs at most three
stored digits. Each multiplication/addition selects a direct return,
`UI_From_Int`, or one `Vector_To_Uint` result (`uintp.adb:801–990`,
1467–1510, 2020–2087, 2361–2445). `Vector_To_Uint` strips leading zeroes and
appends at most one Uints row and three Udigits. Thus the **scanner's sixteen
arithmetic calls only** request at most sixteen Uints rows, 48 Udigits, and
sixteen UI_From_Int cache insertions. Small digit/base conversions are direct.
The Ada Uint tables and UI_From_Int cache are separate from GCC GGC accounting;
these request counts are not additional rounded GGC bytes or whole-pass bounds.

For **one invocation** of `UI_To_gnu` with the fixed nonbiased unsigned32 type,
`trans.cc:6610–6637` and `cuintp.cc:76–164` give one direct constructor or an
indirect conversion of at most three base-32768 digits. The indirect route makes
two initial constructors, then at most two rounds of a digit constructor,
multiply fold and addition fold: at most eight constant requests. In the
three-digit route the first digit is 0..3 and uses the small cache; shorter
routes have at most five requests total. Thus at most seven requests can use
the global large-integer cache.
All arithmetic fits unsigned32, and the supplied type prevents widening retries.
The final conversion is an identity when the computation/result types agree
(`gcc-interface/utils.cc:4999–5007`, retained in the predecessor packet).
Constant/constant folding returns a constant (`fold-const.cc:11025–11038`);
`force_fit_type` returns shared integers when no overflow occurs
(`tree.cc:1678–1729`). This identifies the local request path; invocation
multiplicity and all other semantic consumers have not been discharged.

## Exact missing transfer

`tree.cc:1773–1954` sends small integers to a lazily allocated per-type vector
and larger integers to the global `int_cst_hash_table`. The configured source
default share limit is 251 (`params.opt:248–250`), rather than 256. One hash miss
replaces `int_cst_node` with `make_int_cst(1,1)`. Locally bounded constructor
requests therefore bound the direct integer-node requests, but do not by
themselves bound all later backing-array allocation.

The relevant hash state is capacity, occupied-or-deleted slot count
`m_n_elements`, deleted-slot count `m_n_deleted`, and key placement. Before
**any INSERT lookup**, including a hit, `find_slot_with_hash` grows/compacts when
`3 * capacity <= 4 * m_n_elements` (`hash-table.h:1030–1098`). Reusing a tombstone
decrements `m_n_deleted` without increasing `m_n_elements`; using an empty slot
increases `m_n_elements`. Changing checksum keys can change probe paths and
tombstone reuse even with the same number of live insertions.

Deletions are not excluded by absence of GC: integer-type canonicalization can
remove min/max constants from this same global table
(`tree.cc:6440–6482`). This source path is a reason a no-deletion assumption
needs evidence; this checkpoint has not established when it executes relative
to the checksum in the retained output frontend. `expand` can allocate the same
capacity to compact tombstones, as well as choose another prime capacity;
it then frees the old array (`hash-table.h:830–902`). Freeing does not undo the
cumulative GGC-allocation counter used by the no-collection argument.

Each individual checksum lookup calls `expand` at most once. That observation
does not prove only one or two extra backing arrays over the **remaining
frontend lifetime**: subsequent shared-cache operations can see changed
occupancy/tombstone state. The retained counter stream reports allocator sites,
not this table's insertion/deletion history or state at checksum ingress. Its
131,072-byte largest observed request is not a universal bound on variant
backing-array sizes or the number of reallocations. Consequently adding eight
node sizes, or one/two 128-KiB arrays, to 4,481,000 is not justified here.

The next bounded obligation is to prove a cumulative allocation correction for
this global table under the checksum-dependent requests and the actual
surrounding insert/delete schedule, or obtain sufficient existing state
attribution to establish that schedule. Any full transfer must also discharge
the checksum's Ada semantic consumers and conversion multiplicity. Repeating
the same fixed checksum cannot establish these missing facts. This is a gap in
the transfer proof, not a demonstrated overflowing checksum or a reason to
change the established fixed-capture result.
