# Selected literal finalizer vectors and context depth

2026-10-19, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This source join closes the selected literal native invocation's typed-array
finalizer and outer-vector/depth bookkeeping. It reuses the accepted
[scalar history](retained-literal-shared-query-lifetime.md) and
[collector callback effects](retained-literal-collector-callbacks.md).
Independent review is pending. It does not supply the complete GGC event,
active-page or collector accounting and changes no production source.

## Registration routes and array element types

At the pinned GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`,
`ggc-page.cc:1331–1344,1500–1501` registers only a nonnull callback. Its
`n == 1` branch appends one scalar record; every other n appends one array
record. In `ggc.h:174–254`, typed scalar allocation supplies n=1; typed
array allocation supplies its actual count but a callback only for a
nontrivial destructor. Explicit no-dtor/raw allocations supply null.
Cleared allocation forwards the callback; resizing through `GGC_RESIZEVEC`
uses raw reallocation and does not introduce a new typed finalizer.
The already accepted complete raw-call inventory has no additional selected
custom callback: JIT's custom finalizer belongs to an unselected frontend.

The retained 4,929-source census is reused, not regenerated. Its array-site
projection is retained in this packet and is an audit aid, not a proof of
reachability or C++ triviality. The following source/type join covers those
sites and their selected template instantiations:

| Array element family | Source reason |
| --- | --- |
| `char`, `unsigned char`, `location_t` | Scalar arithmetic types; the selected location typedef is uint64_t (`libcpp/include/line-map.h:297`). |
| `tree`, `rtx`, `ht_identifier_ptr`, `void **` | Pointer typedefs/indirections (`gcc/coretypes.h:57,97`, `libcpp/include/symtab.h:30`). |
| `initial_value_pair` | Two rtx pointers and no destructor (`gcc/function.cc:1260–1263`). This remains trivial even if the hard-register-initial-value path is selected. |
| CTF/BTF entry references; `gimple_omp_for_iter`; `lambda_int` | CTF/BTF debug output, OpenMP construction and dependence/loop transformation routes are absent under the accepted no-debug/O0 and source-shape gates. They supply no selected constructor. |
| Generic hash-table `value_type` | The selected table descriptors have pointer/scalar values. Map backings use `hash_entry`, containing only the selected key and value, with no destructor (`hash-map.h:41–47`). Pointer/Integer/alias entries are trivial; the warning value `nowarn_spec_t` contains one unsigned field and no destructor (`gcc-diagnostic-spec.h:29–110`). The accepted selected descriptor/control census covers the remaining fixed scalar records and exclusions. |

A user-defined value constructor does not make its implicit destructor
nontrivial. A hash-table *control* has a destructor, but its backing's element
type is `value_type`, not the control itself (`hash-table.h:755–767`). The
control's scalar finalizer may explicitly remove entries; that does not
register another finalizer for each element. The accepted callback proof
already covers the removal effects.

All selected array element types therefore have trivial destructors. There
are **zero array-finalizer registrations throughout this selected invocation**,
including the fixed startup and source-varying association/name/location
backings. Their array count/product/request guards still belong to their
original owners: trivial destruction does not waive allocation arithmetic.
The inner array-finalizer vector starts null and never receives a push, so
its capacity and backing requests remain zero. `vec_finalizer::call`'s
`i * m_object_size` loop (`ggc-page.cc:348–355`) is never entered on this
route. This is a source exclusion, not a bound inferred from the small
scalar history or a sample with no observed finalizers.

## Depth and outer vectors

GGC's static state starts zero. The only subsequent `G.context_depth`
assignment is the PCH read's change to one (`ggc-page.cc:2724–2728`). The
accepted selected Ada/no-PCH/no-plugin route excludes that reader, independently
of how many selected calls/null statements occur. Thus context depth remains
zero, and no second outer-finalizer slot is requested.

`init_ggc` (`ggc-page.cc:1923–1935`) allocates ten unsigned depth entries and
pushes one null inner vector onto each outer vector. `push_depth` stores the
first depth boundary when a page is created; with every page at depth zero,
`depth_in_use` never exceeds one. Removing a last page can shorten that count,
not make a new context. The depth allocation remains **40 bytes**.

Each plain inner `vec` occupies one pointer on this LP64 layout. The two outer
heap vectors each start at four slots, so each independently requests
`8+4*8 = 40` bytes. There is no later outer growth. Both outer iteration lengths
are one. The context allocation mask shifts by zero; the collection mask
uses `(1UL << 1)-1`, with no width-dependent overflow. Since every page has
context zero, `clear_marks`'s `p->context_depth < G.context_depth` branch is
false (`ggc-page.cc:1996–2000`): no old-context bitmap backup is allocated.
These facts do not bound the distinct `by_depth`/`save_in_use` page-pointer
arrays; their lengths depend on the still-open complete positive-event ledger.

## Scalar vector and ownership

The accepted scalar history is at most **39,275**, including the conservative
39,257-event prefix and the 18 later controls. Its established growth envelope
gives capacity **58,911** and independent backing size
`8+16*58911 = 942,584` bytes. This packet reuses that owner; it adds no scalar
registration. Finalizer dispatch removes entries and decreases its local length
or increments an index bounded by the original length
(`ggc-page.cc:2021–2062`). It cannot grow either vector. The accepted destructor
and marker argument excludes allocating callbacks, so collection cannot create
new registrations behind this lifetime census.

| Component | Selected complete lifetime result |
| --- | ---: |
| Scalar registration history / capacity | 39,275 / 58,911, already owned |
| Scalar backing individual request | <=942,584 bytes, already owned |
| Array registrations / inner backing | 0 / 0 |
| Context depth / depth entries used | 0 / <=1 |
| Depth backing | 40 bytes, existing initialization |
| Each of two outer finalizer backings | 40 bytes, existing initialization |
| Old-context bitmap backups | 0 |
| New GGC events contributed by this join | 0 |

Do not add these ordinary bookkeeping objects to a GGC request count or charge
the existing initialization/scalar owners a second time. No aggregate RAM gate
is introduced. Complete GGC direct/shared ownership, active-page/free-page
reuse, allocation/collection arithmetic, remaining ordinary heaps and other
required phases/current-grammar composition remain open.

## Evidence and limits

The [packet](../evidence/retained-literal-finalizer-lifetime-20261019/README.md)
pins the exact source/type and accepted argument inputs, retains the array-site
projection and focused consistency checks. The checker verifies identities,
source excerpts and the recorded scalar-owner/depth/vector arithmetic. It does
not automatically prove C++ type properties or selected-route reachability;
those are the handwritten joins above, subject to independent review.

The lead authored this bounded join; live model/effort and token/monetary usage
are unavailable, and no model switch is claimed. Work began at the 01:25:50 UTC
checkpoint. Source inspection was read-only; no native compiler/prover, capture,
new disassembly, accepted Context, corpus scan or predecessor suite was run.

The final focused check passed **67 grouped checks** over 24 GCC and eight
repository inputs, 27 exact LF-coordinate excerpts and the retained 15-type /
28-site array projection in **0.028112547 seconds**. Existing successful
census/component evidence was reused. These counts establish the check's scope,
not an independent proof of the source argument. `git diff --check` passed.
