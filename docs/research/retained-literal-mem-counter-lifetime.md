# Literal MEM attributes and chronological native state

2026-10-19, Linux x86-64/LP64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This candidate closes the selected `mem_attrs` setter lifetime, the incoming
RTL alias-vector state, and the reset/reuse joins for the selected RTL, DF,
LRA and emission counters. It prices the remaining DF reference/instruction
pools and collection-vector backing. It does not close all SSA allocations,
shared bitmap obstacks, collector state or the whole native pipeline.

The [offline packet](../evidence/retained-literal-mem-counter-lifetime-20261019/README.md)
uses the frozen shared-query result at `054b25caec5c46974f484a21ecd7ab7b0fa52bd3`
and the accepted pipeline/RTL inputs. No accepted file is changed. No native
execution, capture, build, solver, accepted-suite, aggregate or corpus replay
was performed. Source reachability remains a handwritten argument requiring
independent review; hashes and arithmetic checks do not replace that review.

## Boundary and notation

Retain GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the one-with,
declaration-free Main/SPARK family with C>=1 qualified literal output calls,
N>=0 nulls, D distinct output callees, and each decoded length<=INT_MAX.
The retained Linux SysV generic O0, no-debug/no-LTO/no-offload route and
reviewed `-fsplit-wide-types` design remain premises. There are no additional
bodies, plugins, target reinitializations, checking overrides, sanitizer,
profiling, stack probing, stack realignment or nondefault function options.
The installed relevant-behavior correspondence remains an external premise.

The source recognizer, source identity and consumed pipeline fields must
agree. This packet uses the accepted shape, not observations from one
execution:

```text
K0 = 98+3C               pre-split first unused pseudo
K  = 99+5C               final first unused pseudo
I0 = 7C+3N+12            expansion chain
M  = 7C+5N+20            IRA-entry chain / LRA record ceiling
U  = 7C+5N+22            LRA first unused UID ceiling
If = 7C+7N+45            final chain
Uf = If+1                final first unused UID ceiling
B  = 2N+10               block-index slots
F  = 17690C+32           lifetime instruction-reference creations
A  = 368N+19044          lifetime artificial-reference creations
```

The original String helpers contribute at most ten fresh scalar SSA names
and are removed before RTL. Main is the only ordinary lowered/emitted
function. Function numbers remain empty elaboration 0, Main 1, helpers 2/3,
next 4; the backend dummy has no declaration and consumes no function number.

## Complete selected MEM attribute partition

`set_mem_attrs` compares the requested record with the mode default and the
current record. It either clears/reuses the pointer or allocates one
40-byte record (`emit-rtl.cc:354–395`). It has no hash or backing table.
The public alias/address-space/alignment/expression/offset/size setters
all funnel through it (`:2203–2281`). A setter does not recursively copy
its referenced tree.

| Selected root | Maximum new records and reason |
| --- | --- |
| Literal and bounds tree pools | At most2C MEMs, each with alias-set and alignment setters:4C. `gen_const_mem` itself only sets flags (`emit-rtl.cc:872–879`; `varasm.cc:3781–3786`). |
| Direct output calls | C raw call MEMs, each with `set_mem_expr`:C (`calls.cc:407–429`). The retained x86 direct call keeps that MEM (`i386-expand.cc:11232–11238,11346–11358`), so the missing-MEM_EXPR fallback at `calls.cc:477–486` is false. |
| FUNCTION_DECL RTL | `make_decl_rtl` skips `set_mem_attributes` for FUNCTION_DECL (`varasm.cc:1675–1678`). |
| Bounds-address copying and final unsharing | `copy_rtx` shallow-copies the MEM, preserves its non-RTL attribute pointer and shares the SYMBOL_REF (`rtl.cc:285–369`; `emit-rtl.cc:3250–3355`). No attribute record copy. |
| Descriptor/component stores and split | The descriptor is TI REG, components are SUBREGs, and splitting produces whole DI REGs. The MEM branch of `cfgexpand::set_rtl`, stack-variable alignment and component-MEM setters do not apply (`cfgexpand.cc:254–264,1338–1373`; `expr.cc:6307`). |
| Ordinary frame | `gen_push` and `gen_pop` construct raw MEMs with PRE_DEC/POST_INC (`i386.cc:6629–6643,6667–6676`). `gen_rtx_MEM` clears the attrs pointer (`emit-rtl.cc:858–866`). The frame move is a register SET. The accepted constructor field `frame_MEM_attribute_objects=0` therefore transfers unchanged. |
| CFI and final output | The initial return-address MEM is raw. Selected CFI processes the accepted push/move/pop shape. The two `adjust_address` sites in `dwarf2cfi.cc:263,316` initialize the table for `__builtin_init_dwarf_reg_size`, absent here. Final `alter_subreg` only calls the address adjuster for SUBREG-of-MEM (`final.cc:3108–3128`); no such operand survives the selected register split. |

The other direct `set_mem_attrs` clients adjust/change/offset/widen an
existing memory address or create spill attributes
(`emit-rtl.cc:2362,2505,2568,2809,2837,2866`). The selected constant-address
roots are SYMBOL_REFs, calls keep their FUNCTION_MODE MEM, and there is no
stack operand, spill, register-valued MEM address, block copy, incoming
argument, invisible result or volatile/unaligned memory adjustment.
`change_address_1` itself copies the attribute pointer and returns unchanged
for identical mode/address (`:2294–2340`); this is not an uncharged setter.

The real x86 `gen_frame_mem` alternatives require paired register save
annotations, mov-based saved registers, DRAP/realignment, stack probes,
EH-return, static-chain or separate shrink-wrap components
(`i386.cc:7644,7692,9188,9432,9771–9782,10093,10500,18913,29027`). The
accepted frame has zero additional saved GPR/SSE registers, no special ABI
and ordinary RBP push/pop; those alternatives are absent. Generic
`gen_frame_mem` and `gen_tmp_stack_mem` do set an alias attribute, so they
must not be substituted for the selected raw push/pop constructors.

Thus variable demand remains **5C records**, already owned by the operation
constructor packet. Later additional mem_attrs demand is zero. The fixed
first-RTL setup's records remain within its 437-event envelope. This does
not subtract the separate conservative frame-alias ID in the String graph.

## Reset and reuse chronology

| State | Initialization, reuse and endpoint |
| --- | --- |
| SSA versions | `init_ssanames` creates a fresh per-function vector and reserves slot 0 (`tree-ssanames.cc:143–165`). Helpers have lengths <=5/7; Main's accepted initial phase has 3C+2 slots and<=3C+1 fresh names. Free lists are per-function; helper vectors are not Main's incoming vector. |
| Global SSA statistics | `ssa_name_nodes_created/reused` are unsigned globals, never reset. The complete name-reference search finds only their declarations, increments in `make_ssa_name_fn`, and printing in `ssanames_print_statistics` (`:70–71,189–194,351–387`). They do not choose versions, indices, sizes or control flow. Defined unsigned wrapping is not a selected capacity failure; statistics are disabled. This discharges the counters' capacity relevance, **not** the all-phase number of SSA allocation events. |
| RTL dummy then Main | `initialize_rtl` enters one dummy; `prepare_function_start` calls `init_emit` in both contexts (`function.cc:4944–5032`). `init_emit` resets UID to 1, pseudo number to 98 and allocates fresh 198-entry arrays (`emit-rtl.cc:5979–6010`). Dummy cleanup frees its ordinary alignment array, clears RTL data and the global register pointer, then pops (`function.cc:208–224,5315–5327`). Main is not charged the dummy's UID/pseudo count and does not reuse its arrays. |
| Main UID/pseudo growth | Expansion, split, LRA, frame and CFI are one monotone function lifetime. Split adds 2C pseudos but no chain object; LRA adds one unused pseudo and one deleted note. Endpoints are K and Uf above. No post-split counter reset is assumed. |
| Global RTL labels | `init_emit` snapshots `first_label_num=label_num`; it does not reset the global label allocator. Preserve the accepted emission prefix and final endpoints below. |
| Alias vectors | Static `reg_known_value`, `reg_base_value` and deletable `old_reg_base_value` begin null (`alias.cc:213–245`). No pre-Main function reaches RTL alias analysis. The fixed dummy setup does not run RTL passes. At O0 the only selected caller is IRA (`ira.cc:5826,5846`); the CSE/GCSE/postreload/DSE/store-motion/scheduler alternatives require unselected optimizing passes. Therefore the first Main alias call is cold, not an arbitrary-capacity reuse. |
| Alias internal ID | Each scan iteration resets `unique_id=1` (`alias.cc:3420`). Only REG_NOALIAS's route increments it; selected symbol/register assignments have none. It stays 1. Ten iterations reuse the two vectors, not ten allocations. |
| DF | `rest_of_handle_df_initialize` uses `XCNEW(df_d)` once (`df-core.cc:687`), so `df->ref_order` begins 0. Rebuilding SCAN frees its arrays/pools but does not write this field (`df-scan.cc:146–195,229–257`). Both generations and transient rescan refs contribute to the same F+A bound. The `df_ref_info.ref_order` enum is a different field describing optional tables. |
| DF LR solver | The accepted bound B+K*(2N+9) applies to each solver invocation; no four-call accumulation is substituted for its local age/dcount state. Per-block LUID starts 0 during each block scan and is<=Uf (`df-scan.cc:3246–3269,3332–3357`). |
| LRA | `init_insn_recog_data` resets the UID pointer array to null/zero; `init_reg_info` resets `last_reg_value=0` (`lra.cc:767–771,1384–1388`). No new pseudo after the initial unused one, no output-reload repair and no coalescing: last_reg_value<=floor(3K/2)+1. Finish releases the ordinary pools/arrays (`:820–832,1395–1403`). |

For alias vectors, exact-growth requested lengths are at most K-92 and K;
the already-owned two requests have raw ceilings8+8(K-92),8+8K and
power-of-two rounded ceilings. `end_alias_analysis` keeps the base vector
as the old cache and frees the known vector (`alias.cc:3562–3566`). There
is no later selected caller. Clearing the deletable old pointer at GC
cannot create a larger incoming capacity. This closes that former input;
it adds no allocation owner.

Let q(X) be the least nonnegative q with198*2^q>=X. Main's complete
register-array growth is q(K); the operation packet already owns q(K0).
The newly exposed later growth budget is **q(K)-q(K0)**, one GGC pointer
array and one ordinary alignment array per growth. It is zero for Hello,
but one for C=20 (K0=158, K=199). Each final array request is bounded by
8*198*2^q(K) and 198*2^q(K), respectively. Dummy initial backing and Main
initial backing keep their existing owners. Protect actual signed doubling
with q(K)<=23, not merely K<=INT_MAX (`emit-rtl.cc:1239–1259`).

The shared cfun stack is ordinary storage. The helper packet already owns
its first four-pointer capacity (40 bytes). Gimplification's push is popped;
cgraph analysis, per-function pass dispatch and Main expansion each surround
their work with a balanced push/pop. A TODO callback or initial gimplification
can nest one push, as can the first RTL dummy; they do not recursively compile
another body (`gimplify.cc:21974–21977,22111`; `cgraphunit.cc:682–707,1858–1938`;
`passes.cc:1750–1786,2065–2129`; `function.cc:4934,5006,5307`). A conservative
peak 3 fits the existing four slots, including the dummy. No later backing
request is needed. The distinct nested-language `function_context_stack`
has no selected push. This does not close other GIMPLE pass-manager storage.

The sequence cache is GGC and **deletable** (`emit-rtl.cc:5651`). `end_sequence`
returns its node to that cache; collection can discard it before a later
scope. Preserve the existing cold event budgets 10 fixed setup +8C operation
+5 frame, each 24 bytes, rather than replacing them with peak nesting 3.
The active stack's peak is still useful for traversal depth. Call argument
arrays remain C sequential 184-byte ordinary requests. The temporary-slot
level oscillates 0..1; its two-slot list vector is already owned, and lists
remain empty. No bound in this paragraph is a global native stack proof.

## Remaining DF pools and collection vectors

`df_collection_rec` has inline vectors for 128 definitions, 32 uses, 32 note
uses and 32 multiword descriptors (`df-scan.cc:47–54`). A call has at most 92
defs and 94 uses (92 canonical hard regs plus two argument USEs); ordinary
symbol/register/frame patterns have fewer. Artificial collections have at
most 92 refs. REG_EQUAL/REG_EQUIV payloads, if present for the selected symbol
constants, contain no register; there are no nonlocal-goto notes. Hence the
definition vector stays inline, the use vector needs at most 94 entries,
and note/multiword vectors stay empty. Records truncate their vectors between
instructions/blocks; they do not accumulate C calls (`:3180–3184,3277–3280`).

Auto storage is hidden on its first heap reserve, so the actual use-vector
capacity sequence is **33,49,73,109**, not48,72,108
(`vec.h:1966–1994`; `vec.cc:150–170`). Individual requests are 272,400,592,880
bytes. At most one collection record is active on the selected nonchecking
path; each record releases its backing. Up to four reallocations per such
record is a work/allocation-history bound, not a cumulative live capacity.
The checker explicitly simulates this transition, including its32/33 and
73/74 boundaries.

The object allocator grows a pool only after its returned and virgin free
lists are empty. Returned objects are reused; `release` frees every block
and resets allocated/free/block counts (`alloc-pool.h:302–328,348–416,430–457`).
On the retained nonchecking layout the header is 8 bytes, each block 65536,
and object size is rounded to 8 bytes. For a bound L on outstanding objects,
slots retained are at most `ceil(L/t)*t`, where t=floor(65528/object_size).
A lifetime creation ceiling is also a conservative outstanding-object bound;
it includes temporary rescan refs that coexist with installed refs.

| DF pool | Per-generation object ceiling | Bytes/object | Slots/block |
| --- | ---: | ---: | ---: |
| base refs | F |64|1023|
| regular refs | F |72|910|
| artificial refs | A |72|910|
| instruction records | Uf |48|1365|
| register records, already priced |3K|16|4095|
| multiword descriptors |0|32|2047|

Using all-lifetime F/A for each of the two generations is conservative; it
does not claim each generation creates the whole allowance. The base and
regular rows may each consume the same instruction bound as separate safe
upper bounds, not as disjoint actual reference counts. Instruction records
are unique by UID and freed on deletion; creating records for labels/notes
is included in Uf (`df-scan.cc:807–835,899–918,3332–3357`). Each generation
owns six ordinary allocator wrappers, already priced by the DF constructor
packet; they are not scalar GGC controls. Old pools are deleted before new
ones are created. The packet exports both per-generation retained blocks and
the twice-that lifetime block-request ceiling, without summing those as
simultaneous storage. The four newly priced reference/instruction rows do
not recharge the existing register pool.

LRA's already-priced recognition and instruction-register pools retain
ceil(M/819) and ceil(10C/2730) blocks. The same source allocator argument
now explicitly bounds `m_elts_allocated`, `m_elts_free` and
`m_blocks_allocated`, all size_t, by rounded retained slots/blocks.
Replacement returns old records before rebuilding; the selected one LRA
invocation ends by releasing both pools. Unsigned pool ID wrapping is
defined and its object-ID checks are compiled out on this route; statistics
are disabled. No cumulative increment-per-allocation counter was inferred
from a peak bound. These ordinary pools add no GGC events or finalizers.

The combined `reg_obstack`, default bitmap obstack, DF bitmap obstacks,
IRA/LRA live-range/copy/invariant pools and shared ET dominance pools remain
distinct joins. This packet closes the rows above, not every ordinary native
heap. In particular a reference bound is not a bound for all live bitmap
headers and elements used by different clients.

## Emission and precise outstanding joins

Reuse the accepted same-source emission interface without replaying it:
ordinary labels start1, prefix next <=39258, final next <=39258+If; constant
labels start0, prefix <=39257, final<=39257+2C. No later RTL-pool/static-space/
partition increment is selected. Final scan starts 0 and ends <=If; CFI label
counter starts 0, ends <=5, with signed temporary <=4. Main uses `.LFB1/.LFE1`,
one emitted body, and no non-Main emitted lines. The checker compares the
actual accepted endpoints, text bound31C+4N+22 and their guards, rather than
resetting global labels at Main entry.

The packet requires the accepted signed DF comparator guard F+A<=INT_MAX,
signed LR bound B+K*(2N+9)<=INT_MAX, signed3K LRA intermediate, unsigned
3(U-1) recognition intermediate, signed stored recognition capacity, DF
quarter-growth/128-byte block-product guards, register doubling guard and
individual LP64 request spans. It preserves the predecessor shared-query
UID/cache endpoints as separately sourced state.

The following remain required before a complete global capacity claim:

1. Join any later SSA update/rename allocations and vector/free-list growth
   with the initial SSA and two helper events. `update_ssa` has an early
   no-work exit, but this packet does not prove that every later invocation
   takes it (`tree-into-ssa.cc:3369–3433`). Global statistics irrelevance is
   not permission to erase those possible allocation sites.
2. Join all direct-object event owners, including the additional
   q(K)-q(K0) register backings, with shared hash/vector replacement events.
   Preserve fixed setup 437, operation mem_attrs 5C, cache 4C, graph 14 and all
   other predecessor owners once. No all-GGC subtotal is exported here.
3. Complete remaining gimplifier/pass-manager/ordinary shared-pool and bitmap
   lifetimes. Reuse released-phase evidence where its inputs match; do not
   turn repeated ordinary allocation work into an aggregate RAM gate.
4. Compose the complete positive-GGC event/request ledger with collection
   epochs, pages, free-page reuse, page-table/by-depth/order metadata and
   collector counters. Include typed-array finalizer registrations and their
   backing separately from the already-closed scalar registrations. Cache
   deletability and stale allocated backing must remain explicit.
5. Supply production invocation/materialization and installed/source
   correspondence premises. This research packet changes neither admission
   nor the Oracle and is not whole-pipeline assurance.

The round retains selected GPT-6 Astra / Extra High; runtime confirmation,
token and cost data are unavailable. The exact frozen review target, focused
check result and elapsed checker time are recorded in the packet. CLI memory
and GitHub were not updated by this bounded subthread.
