# Literal combined-location and later warning-map lifetime

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), with the indexed
filename correction tracked by [#137](https://github.com/berkeleynerd/silver/issues/137).
This closes the
selected literal Main process's source demand for combined locations and the
dependent warning-map puts after initial gimplification. The
[callable packet](../evidence/retained-literal-location-lifetime-20261018/README.md)
recognizes actual source bytes and checks the retained source identities. It
does not establish complete native allocation, collector capacity or a new
production admission rule.

For C >= 1 direct literal output calls and N >= 0 null statements, the complete
combined-location request envelope is

```text
Q = C + (4C+2N+2) + (3C+2N+5) = 8C+4N+7.
fresh ad-hoc entries H <= Q.
later warning-map insertion-capable puts J_later <= 8C+3N+4.
```

These count attempted operations even if a reserved location, identical key,
existing entry or missing warning spec makes the operation allocate nothing.
They are lifetime bounds, not final live-body counts. The original warning
interface's `2C+1` initial-gimplifier demand is retained separately.

For Hello, Q=15 and J_later=12. The ad-hoc array needs at most one 5,120-byte
request (8,192 rounded bytes), and each later warning backbone at most
262,096 caller bytes (262,144 rounded). The new location/later-warning slice
therefore contributes at most **13 positive GGC requests**, with zero new
finalizer registrations. It excludes prefix, original-warning and filename
requests. No null H=12, null metadata 12-event sum or null 40,098-event
compiler lifetime is reused.

## Source family, phases and ownership

Use the existing complete recognizer: one `with Silver_IO;`, Main/SPARK shell,
direct qualified Put/Put_Line literal calls and null statements, at least one
output, no declarations/use clauses, and the current ASCII/HT/CR/LF alphabet.
Literal lengths fit signed32 Integer. Preserve the retained selected native
O0/no-debug/no-instrumentation/no-plugin/no-PCH/no-LTO descriptor, default
x86-64 SysV target, proposed native split-wide-types and recorded warning
options. This is a conditional source/configuration result. It does not
install those options or establish binary/source correspondence anew.

The [counter and registration argument](retained-literal-counter-emission.md)
establishes Main alone at ordinary CF/CFG/SSA/IPA/RTL. Empty elaboration is not
gimplified; two String helpers are initially gimplified and then discarded
without ordinary lowering. The
[synthetic storage argument](retained-literal-synthetic-function-storage.md)
and [warning residual](retained-literal-warning-residual-bound.md) cover their
actual scalar bodies and reserved locations; absence of emission alone would
not prove absence of location requests.

The existing [literal initial-lowering and continuation](retained-native-expansion.md#the-literal-call-path-through-cf-eh-cfg-and-initial-ssa),
[ingress](retained-native-ingress-bound.md), and
[final RTL](retained-output-rtl.md) arguments supply the source-selected body,
single initial CFG construction and all later no-transform cases. The current
packet adds the location/warning consequences of those shapes; it does not
replace their constructor, pass-container or scalar-width checks.

This packet owns ad-hoc-array requests and later warning replacement backbones.
It exports the separate filename direct objects with the indexed System
correction and a source-bound projection of dependent identifier state.
Original shared identifier backing, original/initial warning
backbones, line-table control, its initial ordinary hash, initial finalizers,
discriminator-table backing, CF tuples and CFG infrastructure keep their
existing owners. Ordinary source-file maps, Ada physical source tables and the
two GNAT association arrays are outside the new event delta.

## Initial state and complete location constructor boundary

`general_init` allocates `line_table`, calls `linemap_init`, then replaces its
reallocator with `realloc_for_line_map`/`ggc_realloc`
(`toplev.cc:761–767,1145–1149`). `linemap_init` value-initializes `line_maps`:
ad-hoc `curr_loc`, `allocated` and `data` are zero. It creates the ordinary
libiberty hash using request 100, which selects 127 pointer slots, or 1,016
bytes, plus its <=128-byte control (`line-map.cc:426–440`;
`line-map.h:795–805`; `hashtab.c:134–195`). These fixed initial objects and the
line-table singleton finalizer are already prefix-owned. The GGC array is
initially absent; an empty hash is not an absent hash.

The fixed prefix has no lowered GIMPLE body. GCC Standard-root/tree/type/RTL
setup does not call any of the combined-location constructors below. Ada's
own scanner/source references do not invoke libcpp tokenization; gigi later
preallocates ordinary line maps and `Sloc_to_locus` encodes ordinary locations
(`trans.cc:282–363,11006–11036`). `SET_EXPR_LOCATION` copies that scalar;
`set_block_for_group` assembles a statement-group/BIND field and is not
`tree_set_block` (`trans.cc:9244–9255`). Neither route populates the ad-hoc
table. The imported String/profile/original Main constructor inventories add
no source-range or expression-block remapping route. Therefore the initial
ad-hoc population at the first selected Main call builder is zero.

`get_or_create_combined_loc` is the ordinary fresh-entry writer
(`line-map.cc:175–261`). It strips an incoming ad-hoc tag, may return early
for an unknown/no-block or compactly representable location, performs one
INSERT lookup, and appends at most one record only on a miss. The other
writer, `rebuild_location_adhoc_htab`, rebuilds existing entries after PCH;
the selected invocation has no PCH read. There is no selected map reset,
deletion or replacement of the global `line_table`. GC marks the rooted array;
it does not recreate entries. Destruction frees the ordinary hash.

The retained C/C++ census includes the wrappers `set_block`, `tree_set_block`,
`TREE_SET_BLOCK`, `gimple_set_block`, `set_source_range`, `make_location` and
both discriminator forms. Its lexical inventory includes definitions,
selftests and other frontends; it is an aid to the following reachability
partition, not a proof from match counts.

| Writer family | Selected disposition |
| --- | --- |
| Initial Main call construction | C requests. `gimple_build_call_from_tree` calls `gimple_set_block` once, then sets the source locus (`gimple.cc:385–431`). `gimple_set_block` calls `set_block`; the latter retains pure locus/range/discriminator and calls the combined constructor (`gimple.h:1934–1936`; `tree.cc:14936–14942`). Charge the first call even when TREE_BLOCK is null. The second scalar setter adds no location record. |
| CF generic block attachment | At most 4C+2N+2 requests, the corrected existing tuple/bind interface. `lower_stmt` assigns the block before dispatch (`gimple-low.cc:695–705`), including call-local binds. Processing the outer bind directly can save one assignment; charging a possible fallthrough return at `:166–176` uses that spare slot. The selected explicit bare return actually prevents that fallthrough path. |
| CF call arguments | Zero. `:810–819` only uses TREE_SET_BLOCK for EXPR_P actuals. The one actual is the already materialized descriptor VAR_DECL, not its earlier constructor or addressed literal. |
| CFG discriminators | At most 3C+2N+5 requests: S<=3C+N+2 surviving statements and E<=N+3 edges, with no PHI. `assign_discriminators` runs once from initial `build_gimple_cfg` (`tree-cfg.cc:213,1085–1187`). Equal loci may reuse the previous replacement; every statement/edge is nevertheless charged. |
| Empty elaboration and size helpers | Zero combined requests. Empty elaboration never gimplifies. Helper bodies have scalar arithmetic/comparison/conditional, no CALL/BIND/debug statement and reserved UNKNOWN/BUILTINS loci. Conditional lowering creates branch tuples and labels, not expression-block locations. Initial annotations set reserved scalars. Helpers never enter CF, CFG or RTL. |
| EH and abnormal call rewriting | Zero. No local cleanup/handler/region exists; descriptor stores do not trap. Output calls can propagate exceptions but have no LHS, excluding the throwing-assignment temporary at `tree-eh.cc:2064–2141`. Cleanup/finally writers at `:971,1222` and abnormal-goto assignment at `tree-cfg.cc:546` require absent shapes. |
| Unused lexical-block clearing | Zero. `tree-ssa-live.cc:605–679` requires DECL_VALUE_EXPR or debug/clobber statements. The accepted value-expression-cache proof excludes the former; the selected no-debug, fixed descriptor lifetime/body has neither latter form. Merely having local descriptors does not invoke this writer. |
| Generic tree copying, inlining, parameter adjustment and region movement | Plain copy/unshare preserves scalar loci without invoking remapping. `tree-inline.cc`'s block remappers require inlining/cloning/versioning, unavailable callees or outlined bodies; selected O0/registration results exclude them. `ipa-param-manipulation`, `ipa-split` and `tree-cfg.cc:7143–7496` require signature/region transformations absent here. |
| Folding and instruction selection | The accepted initial ADDR/descriptor/direct-call projection produces no replacement GIMPLE statement. Later direct calls are nonbuiltin, stores are pointer assignments, and O0 builtin/optimization guards exclude the writers in `gimple-fold.cc`/`gimple-isel.cc`. The selected target instruction-selection hook is the default; x86 dispatcher/varargs lowering is not entered. |
| SSA/out-of-SSA and loop/hierarchical discriminators | No real SSA names, PHIs, loops, copied regions, ASAN poison, debug copies or scalar replacements. The PHI/backedge writer at `tree-outof-ssa.cc:1238`, sanitizer writer at `tree-into-ssa.cc:1867`, loop-copy writers and hierarchical discriminator pass have no selected input. |
| RTL setup, expansion, selected passes and emission | They copy encoded instruction/tree locations; none reaches a block/range constructor. Call expansion's SET_EXPR_LOCATION is a scalar copy, audited separately for warning effects below. The cost-setup dummy has no GIMPLE body. Later RTL passes, frame/CFI and unit writers neither reenter GIMPLE nor manufacture an outlined function. |
| Remaining constructor wrappers | Libcpp lexical ranges, C/C++/Fortran/other frontend ranges, LTO/PCH readers, target multiversion dispatchers, compiler generators and selftests are not the selected Ada compiler route. Generic make_location's nonfrontend users are diagnostics/string-range extraction; the selected successful no-diagnostic compiler path has none. Existing representation guards and warning-policy premises remain required; an error path is not being priced as a successful compilation. |

This gives Q=8C+4N+7, counting all constructor attempts and thus every hash
lookup and fresh entry. Old ad-hoc values copied through trees/tuples/RTL may
outlive their original block; no reclamation credit is taken.

## Ad-hoc backing and finite discriminator arithmetic

Reuse the [general ad-hoc transfer](retained-backend-capacity.md#ad-hoc-location-backing-and-hash-arithmetic).
Let A be the least power of two >=max(128,Q). Starting empty, the map makes at
most `1+log2(A/128)` GGC reallocation requests, each <=40A caller bytes and
`rho(40A)` rounded bytes. `ggc_realloc` creates at most one new GGC object per
call and may reuse allocator slack (`ggc-common.cc:163–203`). Array relocation
rebases existing hash pointers without reinsertion (`line-map.cc:93–106`).
The map records its requested capacity, not the rounded allocator slack.

The ordinary C hash has at most Q lookup-triggered backbones after
initialization. Each array relocation after its initial allocation also
invokes `htab_traverse` (`line-map.cc:248–253`), which conditionally calls
`htab_expand` when the table is sparse (`hashtab.c:785–792`). Charge at most
one additional ordinary backing per such traversal: `log2(A/128)`. The total
ordinary backing ceiling is therefore `Q+log2(A/128)`, each at most
`8*prime(max(127,2Q))` bytes. This explicit traversal charge does not require
proving that its shrink branch is unreachable. The lookup growth test precedes key equality
(`hashtab.c:633–695`); a hit can therefore cause a replacement. Early-return,
failed-source and identical-key cases are all retained in Q. An actual
allocation failure remains an external resource outcome, not a continuation
that can make unlimited retries. Hash creation uses the checked identical
prime values of the retained C and C++ implementations, but their layouts and
arithmetic remain distinct. There are no tombstones on this selected ad-hoc
map; all appended entries and both arrays remain rooted until process cleanup.

Keep Q<=2^30-1, the existing local sufficient region, and explicit prime,
32-bit probe `2p-3<=UINT_MAX`, load-product, pointer-span, request-product and
allocator-order guards. `location_t` and map capacities are uint64, while
hash/probe values are unsigned32. The ad-hoc tag is `1+MAX_LOCATION_T=2^62`;
Q is below that index/tag domain. No cumulative byte or RAM limit follows.

Discriminator state has an additional width boundary. Each ordinary CFG block
has one successor; `bb_id` advances once per call and twice per ordinary block.
Its endpoint is <=`C+2(N+2)`. Each per-line discriminator changes only when
that monotone ID changes, so the same bound covers its last increment.
`assign_discriminator` passes unsigned `e.discrim` into
`location_with_discriminator(location_t,int)` and `get_discriminator_from_loc`
also returns int (`tree-cfg.cc:1113–1119`; `input.cc:1048–1073`). Require the
endpoint <=INT_MAX as well as its actual unsigned storage bound. This avoids
an implementation-defined narrowing conversion. These conditions are explicit
even though the selected Q-region implies them.

Ordinary source mapping retains its **independent** 32-bit `linenum_type`
condition `1<=last_logical_line<=2^24`, one map per source-file entry, and
normal encoded-location-region guard. The callable checks the actual Main's
CR/LF/CRLF line count; the recognizer excludes Source_Reference. Fixed and
virtual source line predicates remain with the existing source inventory.
This packet does not relabel its combined-location closure as a complete
ordinary-map or frontend-storage result.

## Later warning puts: separate from fresh locations

`gimple_set_location` calls location-to-location `copy_warning` whenever the
old scalar is not UNKNOWN (`gimple.h:1959–1964`). The latter may put at the new
key even when old and new keys agree; key equality does not precede the hash
growth test (`gcc-diagnostic-spec.cc:207–230`). A missing source spec instead
removes a destination, and reserved destinations cannot insert. The bound
charges every potentially inserting call, without assuming a hit or absence
of dispositions.

The existing [warning interface](retained-literal-warning-map.md) owns original
gigi `I=2C+N+5`, initial-gimplifier `J_initial=2C+1`, their control and all
corresponding backbones. The reviewed residual provides 5 and zero helper
puts. Its endpoint is `4093+I+J_initial`, preserving incoming occupied and
allocated state. The 4093 prefix allowance is not an empty-map assumption.

| Later selected source | Insertion-capable puts |
| --- | ---: |
| CF gimple_set_block, including the existing conservative return allowance | <=4C+2N+2 |
| CFG statement location setter | <=3C+N+2 |
| CFG edge discriminator assignment | 0: edge fields are written directly |
| RTL call-tree reconstruction | <=C |
| Total J_later | <=8C+3N+4 |

CFG sets a statement's location even when it reuses `prev_replacement`; thus
its warning row uses the full surviving-statement ceiling, not the count of
new discriminator entries (`tree-cfg.cc:1135–1152`). Edge writes have no GIMPLE
setter; PHIs are absent. CF's new goto starts cleared, so setting its copied
locus cannot copy an old warning (`gimple-low.cc:1215–1217`). Its return-reset
setters have reserved UNKNOWN destinations and cannot put (`:191,1199`).
This also handles the conservative fallthrough branch: its fresh return gets
the scalar locus first and block second; the block call is already charged.

`expand_call_stmt` makes a CALL_EXPR, copies the current GIMPLE location with
SET_EXPR_LOCATION, then calls `copy_warning(exp,stmt)` (`cfgexpand.cc:3179–3183`).
There is one such operation per direct call. It makes no new combined location,
but can put a spec at the same existing key and cause a pre-hit replacement.
Charging C preserves this previously unjoined effect.

No other post-initial route mutates this map on the selected successful
schedule. The source census checks the selected setters and wrappers as well
as direct copy/suppress sites. CF's setjmp/assume lowering, EH reconstruction,
SSA poison/debug/scalar replacement, out-of-SSA PHIs, builtin folding,
instruction selection and target varargs branches have the exclusions above.
`gsi_replace`'s setter requires an actual replacement; the preserved selected
body has none after CF. `gimple_seq_set_location` callers are sanitizer,
coverage, switch conversion or loop insertion. `copy_var_decl`'s warning copy
is not Main's unnamed temporary-constructor route. Generic tree copies keep
their existing location and no-warning bit without another map put.

The two direct `fold-const.cc` warning sites also have explicit guards:
`:4650` copies a warning while inverting a comparison in `fold_truth_not_expr`;
`:9380` suppresses one after folding a conversion of a constant-RHS
MODIFY_EXPR into a COMPOUND_EXPR. Main's later descriptor address/store and
direct-call shape has neither comparison inversion nor conversion wrapped
around an assignment. The scalar size helpers' comparisons belong to the
already checked initial interval and retain reserved loci; they do not
reach these later phases. The complete file is pinned and included in the
selected warning inventory.

Warnings that could call suppress_warning have their selected option/shape
guards: access warnings are disabled by the retained descriptor; alloca sees
no alloca; uninitialized/format/recursion and other optimizing warnings retain
their established exclusions. Global-declaration suppression requires a
nonpublic undefined function and a successful warning; imported callees are
public and Main/helpers have definitions (`cgraphunit.cc:1098–1121`). Return
suppression requires a nonvoid or noreturn function at the ordinary warning
pass; only void Main reaches it (`tree-cfg.cc:9750–9850`). Streaming warning
specification setters require excluded LTO input. The two discarded scalar
helpers are not assigned Main's void-return premise.

Let `O=4093+I+J_initial+J_later=4103+12C+4N`. Reuse the predecessor hash
transfer with at most J_later new GGC backbones and
`p=prime(max(previous_capacity,2O))`, each <=16p caller bytes and rho(16p)
rounded bytes. Check O<=2^30-1, prime availability, 32-bit probe arithmetic,
load products, pointer span and GGC request order. Each put can replace at
most one backing; removes/tombstone reuse/rebuilds are covered by lifetime
put history. No new map control or finalizer is created by copy_warning.

The exported full-post-prefix warning event figure is diagnostic:
`(1+I+J_initial)+J_later`. Consumers add only J_later to an aggregate that
already owns the predecessor. Combining this with the ad-hoc growth count
does not absorb unrelated original-gigi objects or the complete compiler.

## Filename ingress and remaining boundary

The accepted [original shared interface](retained-literal-original-shared-storage.md#incoming-state-and-filename-ingress)
exports 1,588 Source_File entries and 1,589 insertion-capable filename lookups,
including virtual copies and the translation-unit lookup. That historical
count omitted the separately established
[indexed native System correction](retained-native-expansion.md#indexed-native-main-physical-source-load-correction).
Startup can read System before a semantic unit record exists, then semantic
loading can read it again (`gnat1drv.adb:1066`; `lib-load.adb:615–774`). The
reviewed correction allows one extra Source_File record. The nonnull literal
family cannot use the null family's zero-duplicate result.

Retain the original interface unchanged and add that explicit delta:
**1,589 Source_File entries and 1,590 filename lookups**. Each miss has one
40-byte identifier node and a separate NUL character request <=P+1; P<=32767
and existing integer/request guards apply. This is at most **3,180 direct GGC
requests**, separately rounded (<=64 and rho(P+1) bytes each). Count the extra
lookup as a possible insertion even if its spelling may hit an existing key.
No null three-file inventory or sampled-metadata subtraction is used.

The pure `corrected_shared_identifier_projection(shared,source,counts)` also
checks the caller's source identity and recognized counts against the accepted
shared result. It validates the exact old identifier state and recomputes the
dependent fields with the extra insertion. Incoming history becomes
`E+1590=40847`, with fixed prefix E=39257; outgoing history is the old endpoint
plus one. The existing `identifier_slots(h)=max(16384,rho(floor(4h/3)+1))`
recomputes both capacities, all four identifier guards and the incoming/outgoing
temporary-name serial guards (`libcpp/symtab.cc:155–188`;
`gimple-expr.cc:419–435`). Variable
ingress ordinary requests become 1,590; post-ingress additions stay unchanged.
The separate retained Hello example has history 40,883 and capacity 65,536.
It cannot be used for another source without rebinding the shared input.

Filename direct objects are excluded from the original shared GGC backing
delta, which remains 768 for Hello, and from the new location/later-warning
delta. The correction adds no shared GGC backbone; it repairs the identifier
state/ordinary request allowance. This leaf does not complete aggregate
attachment or close #137. The line-table control/initial hash is already
prefix-owned, so this packet's additional finalizer registrations are zero.
Ad-hoc array and warning backbones are raw storage, not new finalizer controls.

Ordinary line-map GGC events, two node-association arrays, all frontend physical
tables, other original/later shared consumers, complete event/UID lifetimes
and collector pages/finalizers still need their own joins. Complete Main
gimplifier and whole-native flags remain false; total GGC events stay null.
No emitted stream, original tree shape, existing component or production rule
has been changed.

## Evidence and round record

The packet pins the exact retained GCC source revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and repository inputs at base
`1d5bcbe4469b8df7b5a260e2656a1dc0ef9b161a`. Its complete retained gcc/libcpp
C/C++ census freezes 3,574 paths and their contents; 279 lexical location
matches occupy 52 files. Selected warning inventory spans 22 files. The
manifest checks 121 complete source files and 33 repository inputs, with
overlap recorded rather than summed as unique whole-project inputs. A corpus
digest supplements the individually pinned relevant files; inventory matching
does not establish reachability or replace the argument above.

Focused offline checks verify identities, wrapper ordering, source widths,
prime sequences, source recognition, ownership, hash/growth boundaries and
conservative simulations. No compiler, prover, debugger, capture, native build,
broad suite or GitHub action ran. The retained result and check record give
actual input hashes and checker elapsed time. Independent review is pending.

Selected worker model/effort: GPT-6 Astra / Extra High. Runtime confirmation,
token counts and costs are unavailable. The implementation checkpoint and
check timings are recorded separately; earlier source-investigation elapsed
time was not measured. The material integration corrections are the C RTL
warning-copy term, explicit discriminator signed-conversion guard, relocation
traversal ordinary backing charge, and indexed System filename/identifier
projection. Durable
memory, milestone reporting and aggregate attachment belong to the parent.
