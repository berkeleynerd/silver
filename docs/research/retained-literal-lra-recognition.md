# Selected literal LRA recognition lifetime and counters

2026-10-19, owner-authorized research [#119](https://github.com/berkeleynerd/silver/issues/119).
This closes the named recognition lifetime/container-counter residual of the
accepted IRA/LRA helper attachment, conditionally on its source/configuration
and arithmetic premises. It extends the **existing** recognition backing
owner through creation, reuse, invalidation, recreation and teardown. No
allocation owner, GGC event, bitmap element, pool block or finalizer is added.
Independent review of this successor is pending.

The [packet](../evidence/retained-literal-lra-recognition-20261019/README.md)
contains a pure arithmetic implication and narrow source/API/boundary checks.
It is not an actual-source adapter. The accepted 367-guard attachment remains
unchanged; no false or unknown input is made true. All-LRA, all-native and
whole-pipeline capacity remain false; ordinary lifetime request counts and
aggregate RAM remain uncomputed. Oracle, admission, pins and production
#88–#94 are unchanged, and #119 remains unfinished.

## Accepted premises and exact ownership

The accepted actual-source attachment is
`71624df23244a680b3da379c655691df1d77312c`, with
[review](../reviews/review-literal-ira-lra-helper-attachment-71624df232.md)
at `ac4694d0f7e4d53f98d304ce59db2c18ebf40004`. Its source helper is
`b795c8f7459d648d7e595aca414629c1eec232bd`, accepted by
[review](../reviews/review-literal-ira-lra-helpers-b795c8f745.md) at
`4d7100e7fbb2e39e6fdae2cf63b6d7b657cacb71`. The accepted numeric335
source/attachment and all earlier correspondence premises remain inherited.
The integration base here is `36af6a0fa2`.

The direct-layout argument at
[native expansion](retained-native-expansion.md), literal LF12121–12264,
and its [review](../evidence/unbounded-programs/retained-native-expansion-20261017/literal-rtl-backing-review.md)
already establish the four codes, record layouts, arrays, pool peaks and
pointer-growth arithmetic. The [shared pool argument](retained-literal-shared-bitmap-pools.md),
LF246–290, supplies the generic retained-slot lemma. These results are reused,
not re-proved by finite tests or charged again. All GCC coordinates below
are **literal LF positions**, including form feeds, at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

The source domain is the selected Linux x86-64 LP64, SysV, generic O0 route
with wide splitting, C>=1 output calls and N>=0 null statements. Each
seven-instruction group has four distinct whole-DI pseudos, each defined and
used once, no cross-group/block/call pseudo lifetime and no live-out pseudo.
The schedule has two constraint iterations, one assignment/live scan,
optional inheritance/undo at most once, no new instructions or pseudos after
the initial unused Pmode pseudo, and no reload, spill, scratch, asm, debug,
coalescing/copy or optimizing-equivalence transformation. This does not exclude
ordinary register-copy instructions in each group. Their accepted occurrences
are included in 10C. Target/configuration, CFG frequencies and instruction
block membership are stable during the selected LRA interval. The selected
no-checking/no-statistics configuration and documented external allocation
assumptions remain necessary. Equal counts or an O0 flag alone do not supply
these source facts.

Write K=99+5C, B=2N+10, M=7C+5N+20, U=M+2 and
R=floor(3K/2)+1. The exact accepted owner is
`core_result.selected_native_backing.LRA_register_and_recognition_backing`.
The new result preserves its complete frozen Hello record and links these
specific general relations:

| Existing owner field | Unchanged ceiling |
| --- | --- |
| `recognition_pointer_entries_upper` | H=max(floor(3(U-1)/2),U) |
| `recognition_pointer_request_bytes_upper` | 8H |
| `live_recognition_records_upper`, `recognition_pool_blocks_upper` | M; ceil(M/819) |
| `static_recognition_records_upper`, each request | 4; at most 88 bytes |
| `live_operand_location_arrays_upper`, each array | 7C; 16 bytes |
| `duplication_arrays` | 0 |
| `live_call_hard_argument_arrays_upper`, each array | C; 12 bytes |
| `static_operand_alternative_arrays_upper`, each array | 2; at most 1680 bytes |
| `live_instruction_register_records_upper`, pool blocks | 10C; ceil(10C/2730) |
| `static_nonoperand_register_records` | 0 |
| `referenced_pseudo_nrefs_upper` | 2 |

Register-info, per-register bitmaps, constraint stack, other shared pools and
all unrelated fields keep their accepted owners. The fixed fixture check
requires the complete accepted source/count/configuration/owner record and
both successful 367-key maps; it is not a general source-join algorithm.

## Inductive recognition state

Use three phases: active, draining, finished. In the active phase, each
allocated map cell is null or uniquely owns one recognition record for its
UID. Each record uniquely owns its operand-location and call-argument arrays
and its current instruction-register list. Shared static/alternative records
are referenced, never owned by individual dynamic records. Every recorded
pseudo reference is keyed by the **stored** register number in that list.
At completed API boundaries, its bitmap has exactly those UIDs, `nrefs` is
their count and `freq` is their summed stable instruction frequency. Within
the removal/setup loops the counters describe the processed subset; the same
nonnegative ceilings hold for every intermediate operation.

`init_insn_recog_data` sets length zero and pointer null (`lra.cc:765–771`).
Register elements start with empty bitmaps and zero nrefs/freq
(`:1354–1388`). The two typed pools start empty, or have been released by
the preceding LRA finish. Map expansion initializes every added cell to null
and preserves existing cells (`:773–790`). Existing UID/size guards cover
the index cast, unsigned tripling, signed capacity store, `index+1`, pointer
byte product and signed loop successor. For UID<U, every capacity is at most
H; larger previous capacities are not silently imported because this map is
function-local and starts at zero.

The only call to `lra_set_insn_recog_data` is the miss branch of inline
`lra_get_insn_recog_data` (`lra-int.h:507–525`); the other occurrences are
its declaration and definition. The full GCC cc/h inventory is retained.
Thus setting cannot overwrite a live map owner. Get on a hit allocates
nothing; get on a miss allocates one record, immediately installs it in the
map and sets `regs=NULL` (`lra.cc:988–1012`). Recognition of an initially
negative `INSN_CODE` is allowed: `recog_memoized` obtains one of the four
accepted nonnegative codes before the special/asm branch. The theorem
excludes negative **recognized** codes, not this ordinary cache sentinel.

`lra_update_insn_recog_data` has three relevant cases (`:1232–1303`). A miss
uses get. A changed code first invalidates the old register list and counters,
then frees the old arrays/record and nulls the cell, and only then recreates
it. An unchanged code retains its arrays and copies the code-fixed operand
locations into their original lengths. This includes a temporary -1 code
sentinel followed by recognition of the same selected code; a replacement
does not overlap the old record. Alternative-number setters only change a
scalar (`:1306–1328`); -2/-1 or a valid alternative number fit signed int.

`lra_update_insn_regno_info` gets the record, invalidates its entire old list,
rebuilds from current operands, then calls the sole `setup_insn_reg_info`
caller (`:1654–1695`). Invalidation returns each slot, clears its bitmap bit,
subtracts exactly one reference/frequency contribution and finally nulls the
list (`:1600–1652`). A second invalidation sees an empty list. Whole-DI,
non-subreg operands make `(UID,regno)` unique: `bitmap_set_bit` creates the
first list element, while a repeated compatible occurrence merges type/mask
instead of allocating another (`:1484–1538`). The incompatible mode/subreg
branch is excluded by the accepted source shape. Call function-usage entries
are two hard-register USEs; the extra MEM-reference traversal at `:1678–1691`
is absent. Static nonoperand lists are empty by the accepted four patterns.
The 10C live-record ceiling therefore holds during rebuild as well as at
entry/exit: an old list is gone before any replacement list grows.

For each pseudo, the recorded UID set is a subset of its two accepted
occurrences. Rebuild never adds a third instruction or carries an old list
alongside its replacement. Hence `0<=nrefs<=2`. `REG_FREQ_FROM_BB` is in
1..1000 (`regs.h:125–138`, `profile-count.cc:296–307`, accepted numeric
frequency theorem), with intermediate product at most 10,000,000. The
selected interval does not change block counts, size mode or move these
instructions between blocks. The LRA sources do not assign profile counts;
the constant-reorder branch requires a new reload register and nonempty
`before` sequence (`lra-constraints.cc:5113–5153`), while inserted sequences
and edge moves require the excluded reload/spill routes. The included
elimination and final deletion paths retain the block of each surviving
instruction. Therefore removal uses the same frequency as
insertion, giving `0<=freq<=2000`, including each partial subtraction/addition.
This is distinct from the accepted global hard-register-usage guard
`10000C<=INT_MAX`. No repeated-update count is accumulated by nrefs/freq.

## Caller coverage and the final phase

The retained API inventory covers all GCC cc/h occurrences of the setter,
recognition update, register update/invalidation, full invalidation, deletion
and forced-push entry points. Apart from declarations, all occur in the LRA
files below. The source pins and operative excerpts cover their implementations
and the selected/excluded branches. Read-only get callers do not bypass the
miss check; direct map stores, list creators and nrefs/freq writers are also
inventoried. This is a source argument, not a claim that a lexical search
mechanically constructs a complete C++ call graph.

| Caller family | Effect under the accepted route |
| --- | --- |
| `lra.cc:1816–1850,2480–2486` initial/forced pushes | Every update uses the invalidate-before-rebuild API. Stack deduplication may suppress an update; forced updates are still safe. No exact rebuild count is needed. |
| `lra-eliminations.cc:1033,1125,1404–1431` | Both internal recognition refreshes use the same API. Nonfinal processing refreshes changed codes, rebuilds registers, then pushes; a second push-triggered rebuild is safe. Selected operand elimination introduces no new pattern/reference outside the accepted four-code shape. Final processing performs elimination without the nonfinal rebuild sequence. Offset arithmetic remains separately open. |
| `lra-constraints.cc:1495–1529,4519–4539,4580–4642,5075–5089` | Secondary/reload generation and asm-error mutation are excluded by the accepted no-reload/no-asm route. The ordinary changed-insn path uses register rebuild; asm_reloads_num starts zero and its only increment is behind `asm_noperands>=0`, so it stays zero here. |
| `lra-constraints.cc:5460–5550,5705–5805` | Reload-combination and debug-equivalence paths are excluded. Ordinary equivalence substitution/deletion requires the excluded nonempty equivalence route. Any accepted unchanged/reprocessed instruction retains its fixed code/operand envelope. |
| `lra-constraints.cc:6210,6243,6587,6841,6974,7816,7855,7862,7979` | Optional inheritance scanning is included. New inheritance/split/reload pseudos, debug usage lists and restore substitutions are excluded by the accepted empty sets/no-transform route. Dead-instruction deletion, if offered by the scan, only removes an existing list via full invalidation; it cannot increase a bound. No claim that O0 alone skips inheritance is used. |
| `lra-lives.cc:753–775`, `lra.cc:249–285` | Dead-instruction removal invalidates counters before deleting; its follow-up substitution route is debug-only here and excluded. Recursive dead predecessor deletion, if reached, monotonically removes existing records. |
| `lra-coalesce.cc:312,320`, `lra-remat.cc:1180,1194,1258`, `lra-spills.cc:480,596,614` | Coalescing, rematerialization and spilling are excluded by the accepted schedule. They are not guessed safe merely because their arrays fit. |
| `lra-spills.cc:767–879` final code change | Included, even with no spill. The initial `SET_REGNO` loop changes shared RTL pseudos to hard registers. Stored `lra_insn_reg.regno` values remain unchanged. Get reuses the record; surviving lists are snapshots, and deletions subtract their stored pseudo contributions through full invalidation. Marker/temp-clobber/debug/subreg cases are absent; removal of a now-self move is permitted and reduces the set. |

Full invalidation first obtains/removes the register list, then frees and
nulls the map record (`lra.cc:249–256,1217–1227`). If it starts on a miss,
get constructs an empty record before freeing it: this is still bounded by
the live instruction envelope, and contributes no references.

At teardown the phase changes to draining. `finish_reg_info` occurs before
`finish_insn_recog_data` (`:2653–2665`), so the active counter/bitmap invariant
is no longer used. The latter walks each nonnull cell once; free releases
operand, duplicate and argument arrays and the stored list **without reading
register info** (`:792–833`). It then releases both typed pools and the map.
`finish_insn_regs` and the following explicit pool release both call release;
the second sees empty block state and is harmless. Map cells/pointer are not
reset at finish, so the finished phase permits dead pointer values and forbids
further access; the next LRA init resets them. This distinction avoids a
false claim of null cells after teardown. No slot is returned twice.

## Shared static data, small arrays and retained counters

`insn_code_data` is zeroed once, memoizes by nonnegative code, and is freed
once per compiler work (`lra.cc:629–631,681–752,2696–2709`). A dynamic record
with a nonnegative code never frees its static record. The four selected
codes therefore reuse at most four static entries, including across dynamic
recreation. Existing incoming entries/other-code ownership are not replaced
by this selected request bound. Each selected code has nop<=2, ndup=0 and
nalt<=35; the char fields and size_t expression for at most 88 bytes fit.
The static hard-register collector stops at operand locations; the accepted
symbol/constant call pattern has no residual hard register. Assigning its
result therefore stores NULL and never loses a live static list.

`preprocess_insn_constraints` memoizes alternatives per target/code, returns
before allocation for zero operands and otherwise allocates at most
`2*max(35,1)=70` entries, with a two-pointer automatic constraint array
(`recog.cc:3052–3080`). The accepted layout bounds one request by 1680 bytes.
The two selected nonzero-operand codes reuse these tables. `recog_init`
frees cached alternatives before nulling them (`:4748–4765`); its callers are
target/register reinitialization, not an LRA recreation path
(`toplev.cc:1790–1805`, `reginfo.cc:515–526`). The selected fixed target
interval has no intervening reset. An incoming table is still its original
owner; neither dynamic free nor same-code refresh frees it.

`setup_operand_alternative` shifts only for 0<=j<nalt<=35
(`lra.cc:835–870`); `alternative_mask` is uint64_t (`recog.h:24–36`). The
maximum shift is 34, all 70 iterator positions are inside the table or its
one-past end, and nop<=2 fits the retained MAX_RECOG_OPERANDS=30 arrays.
The two DI argument USEs each contribute one register, followed by sentinel
-1: indices 0,1,2 fit the fixed 92-int buffer, and the retained three-int
heap array (`lra.cc:1130–1162`). No clobber-register offset is needed on this
route. These close the named recognition fixed-array/mask operations; they
do not claim every constraint/helper recursion frame or automatic array.

For a pool of slot capacity q and maximum simultaneous live objects T, a new
block is obtained only when both returned and virgin slots are exhausted.
Just before such a block, every previously retained slot is live; the next
object gives q*b<T+q and hence b<=ceil(T/q). Returning an object increments
free and cannot increase retained blocks. This induction applies to arbitrarily
many finite update/invalidation operations, without bounding their total.
`alloc-pool.h:208–226,239–297,302–327,348–457` stores size_t counters:

```
recognition: allocated = 819 * blocks <= 819 * ceil(M/819)
insn-reg:    allocated = 2730 * blocks <= 2730 * ceil(10C/2730)
0 <= free <= allocated; allocated - free = live
0 <= virgin_remaining <= q; returned_free + virgin_remaining = free
```

Every allocate decrements an available free count, every remove increments
below/equal allocated, and release sets all counters and lists to zero.
The 65,536-byte block, eight-byte header and 80/24-byte slot layouts are the
accepted ones. Padding in the last block belongs in the counter ceiling;
using only M or 10C for `m_elts_allocated` would be wrong.

No new source limit is needed. Inherited `U<=INT_MAX` implies
M<=INT_MAX-2, so recognition retained slots <=M+818<=INT_MAX+816.
Inherited `3K<=INT_MAX`, with K=99+5C, implies 15C+297<=INT_MAX,
so instruction-register retained slots <=10C+2729<2^32. Both bounds,
their block counts and all counter intermediates fit selected size_t64.
The existing unsigned map tripling, signed stored H and 8H byte guards
continue to apply separately; this implication does not replace them.
Block-internal pointer advances never exceed the 65,536-byte allocation.
The fixed 80/24-byte `remove` temporary fits int. Pool ID increments are
unsigned and checking-disabled ID comparisons/fields are absent, as in the
accepted generic lemma. Statistics accumulation is also excluded by the
selected configuration. Ordinary allocate-call counts are not counter or
RAM requirements.

## Evidence limits and handoff

The executable arithmetic returns an uncomputed conclusion if any consumed
arithmetic premise is false; it never treats false as success. The finite
state checks exercise repeated get/rebuild, code invalidation/recreation,
deletion, final renumber and draining, including pool block boundaries and
deliberate order/ownership/frequency mutations. Source hashes, exact LF
excerpts and an API occurrence inventory make the handwritten argument
reviewable. They do not mechanize its universal C++ source proof.

The packet records exact local check counts/time and the separate task
interval. Selected implementation setting: **GPT-6 Astra / Extra High**.
Runtime confirmation, token usage and monetary cost are unavailable. No
native compiler/tool, target execution, build/capture, prover/solver/Lean,
predecessor evaluator/suite, aggregate or corpus replay was run. The accepted
successful helper/numeric/367-attachment evidence is retained without replay.

Other outer IRA indirect-jump/alias/root-loop/DF/target/sort interfaces,
other LRA arithmetic/elimination offsets and automatic storage, complete
native/producer/proof/parent capacity, production materialization and binary
correspondence remain open. A future actual-source attachment must preserve
the complete 367-guard source/configuration/owner joins and null/false paths;
this source theorem alone does not attach itself. The parent owns independent
review, integration, root indexes, issue/memory updates and publication.
