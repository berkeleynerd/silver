# Retained literal original-construction shared storage

Issue: #119. Research only. This composes the reviewed original Main,
String216, helper94 and synthetic173 demand interfaces with incoming shared
container state. It establishes conditional, individual backing-request and
selected counter bounds through `finalize_size_functions` return. It does not
establish whole native storage, the whole pipeline, production admission or a
RAM gate. The [packet](../evidence/retained-literal-original-shared-storage-20261018/README.md)
contains the source identities, executable arithmetic and focused checks.

## Inputs, source relation and interval

The attachment at `7f7600ec25f992e392c6b3fe58db744630457ecf` was accepted in
[independent review](../reviews/review-original-native-attachment-7f7600ec25.md).
This packet starts from integrated base
`21b819a763293f8e20c613eb76db0bb5e7d160fd`, pins its aggregate and the
[original-storage review](../reviews/review-original-native-storage-round9.md),
and executes that aggregate's actual-source recognizer and source checks.
It consumes the exact reviewed interfaces, including source-derived `I<=114`;
it does not accept independently supplied call counts. The aggregate still
reads the one historical Main manifest input at its recorded Git revision.
No predecessor packet or accepted attachment is changed here.

The selected retained GCC revision is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The new manifest checks complete
GCC/Ada files and installed target headers; the aggregate checks the broader
predecessor source set separately. These are retained source/installed-behavior
premises, not a fresh native build or a new installed-binary correspondence
claim. Actual production invocation materialization remains open.

The interval begins immediately before `Compilation_Unit_to_gnu`
(`gcc-interface/trans.cc:685`) and ends immediately after
`finalize_size_functions` (`stor-layout.cc:275–293`) returns. The incoming
state includes GCC initialization and the source-sensitive filename ingress.
The original Main is registered by `rest_of_subprog_body_compilation`
(`utils.cc:3874–3892`); `cgraph_node::finalize_function`
(`cgraphunit.cc:452–516`) registers, may collect, and enqueues it. It does not
gimplify Main at that point. Empty elaboration has no lowering
(`trans.cc:698–723`). `gnat_parse_file` calls `gnat_write_global_declarations`
after frontend translation (`misc.cc:100–124`). Its unconditional forced dummy
when `first_global_object_name` is present is therefore inside this interval
(`utils.cc:6460–6488`). After parsing, `finalize_compilation_unit` calls
`finalize_size_functions` before ordinary analysis (`toplev.cc:448–483`,
`cgraphunit.cc:2562–2595`). Both String helpers get function structures and
initial gimplification in that call.

Ordinary Main analysis/gimplification, subsequent CFG/SSA/IPA/RTL work and
emission are outside this interval. Their existing demands cannot be treated
as zero or merged into an incoming state here. The warning-map and assembler-
name-map controls can be created during this interval; their finalizer-vector
contributions are included below while their direct storage remains with its
existing owner.

## Incoming state and filename ingress

The retained [fixed-prefix record](retained-native-expansion.md) supplies
`E=39257` positive GGC allocation events and `B=3318816` cumulative rounded
bytes, with `5832` declaration increments and `2277` fresh type increments
from initial next-type value `1`. The recorded prefix has no wrap/reset or
collection. Its fixed-root read projection, rather than the success of a
sample, licenses transfer of that fixed setup allowance. Retaining all of E
and B is conservative; sampled metadata is not subtracted. Variable filename,
line-map and GNAT association storage is not bounded by B.

The number of semantic units is not the number of physical or virtual
source-file entries. For the selected native source-search and naming route,
use this deliberately broad count:

| Contribution to Source_File | Entry upper bound |
| --- | ---: |
| Entire installed runtime request-name union | 1575 |
| Silver specifications | 2 |
| Main | 1 |
| Selected configuration | 1 |
| Explicit fixed spec-instance virtual copies | 8 |
| Possible Image_I body virtual copy | 1 |
| Total | 1588 |

The physical Image_I body, `libgnat/s-imagei.adb`, is already in the runtime
union. Its virtual copy is the final additional entry. This is neither a
claim that every runtime file loads nor an exact selected-file count. The
selected semantic population remains the recorded 38 specifications plus
Main; the broader 42-spec investigation is not substituted for it.

The [source closure](retained-source-closure.md#physical-runtime-contribution)
and [fixed support](retained-fixed-support.md#virtual-ranges-inside-this-closure)
supply the request-name and copy-route premises: one unit per file, no source
name override or preprocessing, selected configuration, fixed search universe,
and eight fixed spec instances. `sinput-l.adb:356–425` reuses an existing
request name when `Multiple_Unit_Index=0`; unsuccessful reads remove the new
entry. `Create_Instantiation_Source` at `:127–146` is the virtual append route.
The seven Unchecked_Conversion instances have no ordinary body. The Image_I
body may be instantiated under `sem_ch12.adb:4881–4944` even without an Inline
annotation; it is conservatively charged once. It has no nested instance or
additional with-clause source demand. The reviewed body/inline/inherited-
contract exclusions close other virtual-copy routes for this shape. Reference
counts and literal lengths do not multiply these fixed copies. Changed search,
mapping, configuration or language premises require a new count.

`Num_Source_Files` uses the entire table (`sinput.adb:736–739`);
`back_end.adb:80–130,172` passes every entry, including virtual copies, to gigi.
The filename loop (`trans.cc:282–363`) interns one `Full_Debug_Name` per entry
on this selected successful route. Add the translation-unit filename lookup
(`utils.cc:877–885`): at most **1589 insertion-capable filename lookups**.
Each miss has an identifier node of 40 caller bytes and a separate NUL string
of at most `P+1` bytes, where P is the aggregate's complete path-spelling
bound. Require `P<=32767` and the unsigned identifier-length and individual
request arithmetic to fit. The descriptor does not prove that an eventual
production invocation uses those paths. These direct filename requests are
reported separately, not added to the new shared-backing event sum.

Every identifier miss has a positive GGC node allocation (`stringpool.cc:40–75`,
`libcpp/symtab.cc:148–180`). Thus incoming lifetime insertions and current
occupancy are each at most `E+1589=40846`. The filename addition is conservative
even though the retained E also included sampled filename nodes. B is not
used for the ordinary identifier backing or variable filename bytes.

## Demand composition and ownership

Let C be output calls, N be explicit null statements, and D be the number of
distinct called output operations, all from the actual source. Define:

```text
K = C + 4D + 5
R = 164C + 16D + 8
H = 151 + 167C + 12N + 114
```

| Consumer | Identifier lookups / new entries | Type hash lookups / entries | Integer hash lookups / entries | global_decls pushes | stmt_list_cache pushes | alias_sets pushes | Scalar finalizer registrations |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Reviewed original Main, I<=114 | K / K | 2(D+1) / 2(D+1) | R / R | D+3 | H | 2 | 1 |
| Original String216 | 11 / 11 | 0 / 0 | 129 / 129 | 5 | 0 | 2 | 0 |
| Original helpers94 | 6 / 4 | 2 / 2 | 0 / 0 | 0 | 0 | 0 | 0 |
| Synthetic173 | 10 / 10 | 0 / 0 | 0 / 0 | 0 | 0 | 0 | 2 |
| Forced dummy | 1 / 1 | 0 / 0 | 0 / 0 | 0 | 0 | 0 | 0 |
| Conditional warning-map control | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 | 0 | 1 |
| Conditional assembler-name-map control | 0 / 0 | 0 / 0 | 0 / 0 | 0 | 0 | 0 | 1 |

All counts are upper bounds. String216 and helper94 are each added once;
synthetic173 is separate. No historical null helper11 or null structural/name
packet is added. The dummy's direct identifier, character, declaration and
graph storage already belongs to the graph ledger. Only its shared insertion
and one DECL_UID contribution enter this new composition. Likewise the warning
and symbol controls are already owned; only their scalar-finalizer-vector
pushes enter the new backing calculation. No consumer in this interval adds a
vector-finalizer registration.

The small integer cache has at most 252 slots and 2040 caller bytes per vector.
Main already owns its R possible vector requests. String's 129 candidate
scalar results use existing small-cache backing or the separately counted
large-integer hash; helper scalar constants add at most three existing-cache
writes and no vector. Charging both possible cache destinations is safe, but
charging Main's vectors again is not: **new small-cache vector requests in
this packet are zero**. The combined write envelope is `R+129+3`.

Only original Main contributes statement-list-cache traffic here. String and
helper expression bodies have no STATEMENT_LIST. The two synthetic initial
gimplifications consume reviewed RETURN/MODIFY/COND bodies without BIND or a
statement list; `gimplify.cc` has no `alloc_stmt_list`/`free_stmt_list` call.
Ordinary Main lowering is after the boundary. A collector can clear the
deletable cache, which cannot raise the lifetime envelope.

## Allocated bounds and individual requests

For positive x write `rho(x)=2^ceil(log2(x))`. It is a conservative GGC
rounded-size ceiling in the inherited allocator region, not an assertion that
all native size classes are powers of two. No sum of these independent requests
is used as a process-memory limit.

**Identifier table.** `ht_create(14)` begins with 16384 pointer slots. An
insertion increments `nelements` even when it reuses a deleted slot; purge
does not decrement it. Expansion is after insertion and fires when
`4*nelements >= 3*nslots` (`libcpp/symtab.cc:100–268`). With lifetime insertion
bound J, the capacity ceiling is the least power of two S, at least 16384,
satisfying **`3S > 4J`**. Equality therefore requires the next tier. The
incoming allocated bound is 65536 slots; after this interval use
`J=40846+K+26`. Each new ordinary backing request is at most `8S` bytes.
There is at most one expansion per inserted identifier: at most 1589 in
variable ingress and `K+26` afterwards. Check unsigned32 `4J`, `3S`, doubling
and the independent pointer-array request. Intentional hash scrambling wrap
and statistical counters are not capacity indices.

**Type and integer hashes.** Initial table requests 1000 and 1024 choose
1021 and 2039 primes (`tree.cc:156,772–784`). Each successful new type record
has a GGC allocation (`:6433–6492`); a new integer record consumes a distinct
allocated integer node (`:1888–1955`). Keeping discarded candidates in E is
conservative. Occupied history is therefore at most E initially, independent
of the allocated array. Expansion chooses `prime(2*live)` or keeps the old
size; deletion cleanup/shrink cannot increase the lifetime maximum
(`hash-table.h:646–680,818–901`). Both initial allocated arrays are bounded by
`max(2039,prime(2E))=131071` slots, and `8*131071<=B` is consistent with the
fixed GGC seed. This does not infer capacity from present live occupancy.

After Q new entries, allocated slots are at most
`max(131071,prime(2*(E+Q)))`. Use Q=`2D+4` and Q=`R+129` respectively.
Expansion occurs **before even a successful lookup**
(`hash-table.h:1028–1100`), so charge one possible backing replacement per
insertion-capable lookup, not merely per miss. Requests are at most eight
times that slot bound, with independent `rho` ceilings. Required guards cover
the supported prime tier, size_t64 load products, hashval32 probe addition
`2*(slots-1)`, signed pointer span and the inherited GGC order region.
There is also a separate unsigned32 check **`8*(E+Q)<=2^32-1`**:
`too_empty_p(unsigned int elts)` multiplies its argument by eight before the
size comparison. A size_t load-factor guard alone misses that operation.
The GC cache walkers mark or clear existing slots without resizing
(`hash-table.h:1240–1258,1303–1322`); they do not call the separately defined
resizing `traverse`. The checked
[collector callback interface](retained-literal-collector-callbacks.md)
contributes zero GGC requests, so collections do not add uncounted hash
backings between the charged lookups.

**GC pointer vectors.** `global_decls` and `alias_sets` have 8-byte elements
and 8-byte embedded headers (`utils.cc:316,983`, `alias.cc:267,1173–1176`).
Each source-independent incoming backing is bounded by B, hence both incoming
occupied length and allocated slots are at most
`A0=floor((B-8)/8)=414851`. This loose seed is a bound, not a measured capacity.
The statement cache starts empty at the retained cut (`tree-iterator.cc:31–58`
and the prior prefix transfer), so it uses A0=0.

For L>=1 define

```text
F(L) = max(4, L, 2*min(15,L-1), floor(3*(L-1)/2)); F(0)=0.
```

Before a push reallocates, old allocated slots are smaller than the desired
new live length. The source doubles an old allocation below 16 or takes 3/2
of it otherwise; thus a desired live-length bound L bounds any such growth by
F(L), even after pops. For t further pushes, live length is at most A0+t.
Account separately for retained incoming allocation by

```text
desired_slots <= max(A0,F(A0+t))
rounded_request <= rho(8+8*desired_slots)
normalized_slots <= (rounded_request-8)/8.
```

`va_gc::reserve` normalizes capacity to the allocated size
(`vec.h:245–260,388–425`, `vec.cc:150–167`). This formula covers each
allocation over the interval; it does not apply a growth factor independently
to every lookup. A pop or collector clear may cause more cold allocations,
but at most one per push. Use t=`D+8`, H and 4. Check unsigned length and
`3*(L-1)`, the 31-bit capacity field, pointer span and GGC order region. For
zero desired slots the request is zero.

**Scalar finalizers.** `add_finalizer` registers at most once per positive GGC
event (`ggc-page.cc:1330–1344`). Source-sensitive filename, line-map and GNAT
association raw allocations have no typed finalizer. The fixed-prefix incoming
occupied upper bound is E and its allocated high water is `F(E)=58884`,
without using B for this ordinary heap vector. Selected no-PCH context depth
remains zero under the inherited transfer. Each inner record is 16 bytes;
the header is eight. Collection removes entries without increasing capacity
(`:341–379,1932–1935,2021–2060`). The five new scalar registrations give
`F(E+5)=58891` and each possible new ordinary request at most
`8+16*58891=942264` bytes. There are at most five such requests. Check unsigned
growth and length, the 31-bit capacity field and pointer span. Outer finalizer
vectors and the unchanged vector-finalizer population stay with the existing
collector transfer; this is not a collector-lifetime total.

The only new shared GGC backing-event sum is

```text
(2D+4) + (R+129) + (D+8) + H + 4.
```

Ordinary identifier/finalizer backings and separately owned direct objects are
not part of that sum. There is no complete imported-event or imported-byte
total in this packet.

## Selected finite counters

The no-wrap guard for DECL_UID uses the next-value upper bound
`5832 + Main_DECL + 13 + 8 + 8 + 1 <= INT32_MAX`. The additions are original
String, original helpers, synthetic declarations and the forced dummy. For
types, ignoring all rollbacks gives
`2278 + Main_type + 10 + 4 <= UINT32_MAX`. These are lifetime upper bounds,
not the sampled final next-type value 1937. Alias IDs are vector length minus
one, hence at most `414851+4-1=414854`; the signed check is explicit.

The temporary serial has a source bound without assuming its incoming value
is zero. `gimple-expr.cc:419–435` contains the sole `tmp_var_id_num` definition
and increment: every increment formats and interns a name. The selected
installed target uses the default `%s.%lu` private-name form with no override
(`defaults.h:38–56`, complete installed `tm.h`/target-header set in the new
manifest). The decimal serial follows the **last delimiter**. Consequently
distinct serials before a first wrap give distinct full spellings, even when
prefixes contain delimiters. A lookup may hit an identifier created by some
other consumer; that still requires a distinct identifier node to have been
allocated at some earlier point. Deleted nodes count too: this argument uses
**lifetime allocations, not current table occupancy**.

Every such node is covered by fixed E, variable filenames or the exact
post-prefix identifier interfaces above. If the serial wrapped for the first
time, its 2^32 distinct outputs would require at least 2^32 distinct historical
identifier-node allocations. Requiring `J<=UINT32_MAX` contradicts that.
The incoming serial is therefore at most 40846 and the endpoint at most J.
This proof adds no node requests: adding a second charge for the serial would
double-count its already owned names. It establishes only this interval's
no-wrap property; later name consumers remain separate.

The exact accepted function-definition interface remains elaboration0, Main1,
bit-size-helper2 and byte-size-helper3, next4; helper private-name `fnno`
starts0 and ends2. Those constants and the helper94/synthetic173 ownership
are checked against the reviewed aggregate. These selected guards do not
assert complete lifetime closure of all compiler counters.

## Concrete result, evidence and residuals

For the retained Hello source, C=1, N=0, D=1: K=10, R=188, H=432.
The selected guards fit. Incoming identifiers are at most 40846; after 36
possible new entries their history is at most 40882, still 65536 slots.
The next declaration UID is at most 5872 and the next type UID at most 2306.

| Backing | Additional requests, at most | Individual caller-byte ceiling |
| --- | ---: | ---: |
| Type hash, GGC | 6 | 1048568 |
| Integer hash, GGC | 317 | 1048568 |
| global_decls, GGC | 9 | 8388608 |
| stmt_list_cache, GGC | 432 | 8192 |
| alias_sets, GGC | 4 | 8388608 |
| Identifier table, ordinary, post-prefix | 36 | 524288 |
| Scalar-finalizer vector, ordinary | 5 | 942264 |

The GGC backing-event upper sum is **768**. The first two GGC ceilings round
to at most 1048576 each; the listed vector ceilings already use a conservative
rounded size. The separate variable filename ingress allows up to 1589
ordinary identifier-table expansions with the same 524288 ceiling.

The focused checker covers actual Hello, mixed operations/nulls, empty and
8192-byte literals, case/line-ending changes, and 5000 calls; exact-interface,
ownership, incoming-seed, source-identity and descriptor mutations; independent
growth simulations with hits, deletions, retained backing and threshold
equality; and finite arithmetic boundaries without enormous source files.
Those checks support the transcription and joins. The source arguments above
establish the bounds; source samples alone do not establish universal claims.
The 5000-call source retains the aggregate's conservative relocation failure.

`Uint_entries=2C`, `Udigits_words=10C` and `UI_Ints_wrapper_calls=2C` remain a
separate Ada interface. Their incoming occupied and allocated states are
unknown here, so this packet supplies no Ada backing closure. It also leaves
original gigi's other direct/metadata families, later shared consumers,
collector page/heuristic lifetime, complete imported totals, complete global
counter lifetime, assembler/object, GAS/BFD and linker representation open.
All broad completion flags remain false. There is no compiler, prover, solver,
debugger, capture, build or full-suite execution in this round.
