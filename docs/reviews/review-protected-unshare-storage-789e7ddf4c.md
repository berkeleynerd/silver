# Independent review: protected unshare-set storage

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The new wrapper
closes the selected ordinary set control/backing request interface, with
zero additional GGC events. It preserves the existing external allocator
boundary and does not establish complete gimplifier or pipeline capacity.

## Exact inputs and scope

Reviewed range:
`38671493119c88a9bbfc2429ae9987473c9fc51f..789e7ddf4cfb3112b2184433f12dd2c548ef7bfc`.
The target was checked out clean in an isolated worktree on
`review/protected-unshare-storage-789e7ddf4c`. The six changed files are
`README.md`, `check-results.json`, `check.py`, `compose.py` and `result.json`
in the [aggregate packet](../evidence/retained-literal-pipeline-20261018/README.md),
and its [research argument](../research/retained-literal-pipeline.md#protected-unshare-set-control-object-and-ordinary-allocator-interface).

This review reuses the accepted
[ingress source review](review-native-ingress-eb0471fa33.md) and
[aggregate attachment review](review-native-ingress-attachment-ee3ea76e28.md).
Their W/address/BIND arguments were not reopened. The bounded new question
was whether the protected set's ordinary requests, arithmetic and destruction
were exhausted without transferring external allocator implementation into
Silver's proof obligations or silently transferring these requests into GGC.
Applicable project and authorization context remains as previously read.

## Assessment

The inspected `hash_set` has only its `hash_table` member, and neither class
has a base or virtual payload (`hash-set.h:144–154`; `hash-table.h:371–375`).
With `CHECKING_P=0` and `GATHER_STATISTICS=0`, the table's instance fields are
one pointer, three `size_t`s, three unsigned integers and two booleans
(`hash-table.h:591–631`). On the retained LP64 layout these occupy 48 bytes
after padding. The wrapper's one object request of at most 64 bytes is safe.
`auto-host.h` is already fully pinned by the existing manifests, and the new
`Context` checks additionally require the two selected zero definitions.
This is conditional source/layout evidence, not a new native `sizeof` run.

The set constructor defaults to ordinary allocation and nonlazy backing.
`alloc_entries` selects `xcallocator<tree>`, which calls
`xcalloc(count,sizeof(tree))`; expansion frees the replaced ordinary array,
and destruction frees the final array (`hash-table.h:262–285,646–675,
727–777,833–900`). The existing source-join manifest also pins
`libiberty/xmalloc.c`. Its `xcalloc` wrapper makes one `calloc` call, with
no zero-size adjustment here because the count is at least 13 and each
element has eight bytes (`xmalloc.c:156–169`). Thus the selected GCC/libiberty
request path is accounted through the libc boundary, rather than being
left unexamined as an unspecified allocator helper.

The remaining C++ allocation/deallocation and libc internal storage behavior
retain the documented runtime/resource trust in
[trusted-boundary.md](../trusted-boundary.md). Successful allocation and
sufficient physical resources remain premises; failure is not recast as
successful capacity validation. The new closure does not claim peak physical
memory, allocator-internal verification, or a bound on arbitrary external
allocator metadata.

Statistics registration and update branches are disabled by the selected
configuration: the table's `m_gather_mem_stats` is a static false constant.
The checked pointer traits give an empty `ggc_remove<T*>::remove`; pointer
copy/move/destruction allocates nothing (`hash-traits.h:251–254,321,469`).
Checking-only insertion tracking and verification are absent. The local
`unshare_body` performs the established traversals and then deletes the set;
it calls neither `empty()` nor a terminal-shrink operation. Consequently
destruction adds no allocation and there is no terminal-empty backing event.

The wrapper consumes the accepted C+1 distinct-entry/no-deletion transfer.
It checks the expected object count, initial slots, pointer width, deletion
count, population and C+2 backing-request interface before using the result.
Initialization is included in those C+2 requests. Repeated hits were already
covered by the accepted eager-growth transfer and are not assumed free of
growth. The new control object and backing remain separate ordinary requests;
the reported GGC increment is correctly zero.

The predicate checks prime existence, unsigned32 probe addition `2p-3`, and
the signed-size bounds for `8p`, `3p`, `4(C+1)` and `2(C+1)`. These cover the
individual backing byte count, lookup threshold, expansion request and
selected pointer extents. I also checked the apparently narrower arithmetic
in `too_empty_p(unsigned int)`: on this no-deletion insertion path, expansion
is entered at `3*size <= 4*elements`, so `2*elements > size` is true. The
left side of `expand`'s disjunction therefore short-circuits the `too_empty_p`
call (`hash-table.h:818–820,847,1039`). Its unsigned multiplication is not an
additional reached bound here. The destructor's descending unsigned index
wrap terminates its loop before another access.

Search/collision counters are unsigned and used only for observational
statistics. The selected local set does not consume their ratio or use them
for capacity decisions; their wrap does not constrain this interface.
This matches the retained capacity policy's treatment of defined modular
arithmetic with no allocation, representation, output or success consumer.

The aggregate now uses this wrapper's predicate in the existing ingress
condition and returns its storage record separately. Removing the protected
set from the aggregate's open-obligation text is justified at that local
interface. The frozen component's historical open-bookkeeping field remains
unchanged, with the newer closure explained explicitly. Whole-body tree/vector
counts and the 8C selected helper subtotal are unchanged. Complete gimplifier,
global counter/collector, incoming nowarn-map, remaining-helper and complete
launch obligations remain open; whole-pipeline and admission-change flags
remain false.

## Verification and round record

One fresh offline aggregate replay passed **72 cases in 3.266292539 seconds**,
with exit status zero and empty stderr. Its parsed output exactly matches the
frozen `check-results.json`. The five new cases cover the last-safe-prime
transition, prime exhaustion, and mismatched entry/backing-request interfaces.
The existing source cases check the object/backing fields and zero GGC delta.
I also compared the frozen default storage payload directly with the wrapper
on its recorded ingress input; it matched. Default aggregate-result generation
and the earlier component checker were not rerun.

The replay used the retained GCC and Ada roots from the preceding attachment
review and the selected GNAT 16.1.0 Linux x86-64 plugin headers. The exact
command, fresh output and timing are retained in local scratch
`/tmp/silver-review-protected-unshare-storage-789e7ddf4c/`. No committed evidence
was overwritten. No native compiler/prover/debugger, broad suite, GitHub
mutation or recursive delegation occurred.

Selected reviewer setting: **GPT-6 Astra / Extra High**. Independent runtime
model/effort confirmation and token/cost measurements were unavailable.
Review began at 2026-10-18 19:39:03 UTC; review, replay and report were
completed at 19:41:26 UTC, an elapsed 143 seconds for this review round.
This is not whole-team runtime. Intended result: review the new ordinary-storage closure.
Achieved result: scoped acceptance without implementation rework. The live
harness query returned no goal; no goal was created or changed. CLI memory
was not updated. The parent owns integration/publication; #119 remains open.
