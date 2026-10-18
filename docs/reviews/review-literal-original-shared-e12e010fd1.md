# Original literal shared-storage review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accepted at `e12e010fd1da984a45a6955928f3fc979aec4306` for the stated
conditional interval and individual-request/counter interfaces.** No material
defect was found in that freeze. Integrating the concurrent emission attachment
requires the explicit compatibility step below; this review does not accept a
combined checkout merely because both component reviews pass.

Selected reviewer: **GPT-6 Astra / Extra High**, selected by the lead.
Independent serving-runtime confirmation and token/cost measurements are
unavailable. The recorded review checkpoint began at 22:39:42 UTC; source
inspection and targeted checks finished at 22:42:27 UTC, 165 seconds excluding
final report authoring. The independent offline check took 3.227388 seconds.
Actual host is Linux x86_64. Compiler, prover, solver, debugger, capture, build
and full-suite executions are zero. No GitHub write or further delegation was
made. Only this report is owned by the review branch.

## Exact inputs and scope

The primary inputs are the [source argument](../research/retained-literal-original-shared-storage.md)
and all eight files in its [evidence packet](../evidence/retained-literal-original-shared-storage-20261018/README.md)
at the reviewed commit. The source roots are:

- GCC: `/tmp/silver-backend-compose-20261018/full-source`, retained revision
  `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
- Ada: `/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`.
- Installed target headers:
  `/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include`.
- Matcher: `/tmp/silver-backend-compose-20261018/folding-sources/match.pd`.

The fresh `Context` checked the packet's 38 repository identities and 60
complete source/header identities, then executed the inherited aggregate's
source validation and actual-source recognizer. Relevant predecessor evidence
includes the accepted original-storage and attachment reviews, fixed-prefix
constructor witness/read projection, physical/virtual source closure,
collector callback interface, and original Main/String216/helper94/synthetic173
interfaces. Those accepted leaf results are reused, not presented as new
complete reviews. The Oracle, applicable project workflow, assurance and
trusted-boundary distinctions govern this review.

The lead additionally requested an integration check against emission
attachment `1f7dc841159b9e00d3c4661b35c145daa03f0003`. That bounded comparison
does not constitute review of the complete emission argument.

## Source and ownership conclusions

The endpoint is immediately after `finalize_size_functions` returns at
`cgraphunit.cc:2575`. Main finalization registers/enqueues its node and may
collect, but does not invoke ordinary Main gimplification. The empty
elaboration guard does not lower its empty body. `gnat_write_global_declarations`
runs before the endpoint and can create the forced dummy; the two size helpers
receive their function structures and initial gimplification inside
`finalize_size_functions`. Ordinary `analyze_functions` is later. The selected
no-debug configuration and previously reviewed global-declaration frontier
remain premises; this cut is not permission to erase later consumers.

The filename bound distinguishes physical files from virtual copies. The
1,575-name runtime union, two Silver specifications, Main and configuration
give 1,579 physical entries. Eight fixed specification instances and one
possible Image_I body copy give 1,588. The physical Image_I body is already in
the runtime union. `Load_File` reuses an existing request name under the
one-unit-per-file premise and removes failed reads; `Create_Instantiation_Source`
appends a copied record. Its body contains no additional with or nested
instance. The inherited inline/body/contract exclusions are essential to this
fixed copy count. The gigi loop sees the entire source-file table, and the
translation-unit filename adds one lookup, giving 1,589. It does not add
another translation-unit DECL_UID: that fixed declaration belongs to the
incoming constructor prefix.

The incoming 39,257 GGC events and 3,318,816 rounded bytes are cumulative
constructor evidence under the fixed read projection. Discarded candidates
remain in those totals. The type-UID seed correctly uses 1+2,277 positive
increments, not the sampled final value 1,937. Filename nodes are charged
separately and conservatively despite overlap with sampled filenames. B is
used only for the named source-independent GGC vector seeds, not for variable
filename objects or ordinary heap backing.

The demand join consumes the reviewed actual-source interfaces, including
I<=114. String216, helper94 and synthetic173 each appear once; historical null
replacement packets do not appear. The forced dummy contributes only its
shared identifier insertion and one declaration increment here. Its direct
objects remain with the graph owner. Main's small-cache vectors remain owned
by Main; the shared packet adds zero duplicate cache-vector requests.
The five scalar finalizers are Main's namespace map, two synthetic controls,
one warning map and one assembler-name map. Their control allocations are
separate from the ordinary finalizer-vector backing. No vector finalizer is
added. Selected helper bodies add no statement-list-cache traffic.

## Capacity and counter arguments

Identifier expansion happens after insertion, including tombstone reuse;
purging does not reduce `nelements`. Thus lifetime insertions, with the strict
`3*S > 4*J` endpoint condition, bound capacity. Equality requires another tier.
Every identifier miss allocates an identifier node, so the incoming lifetime
bound E+1,589 also bounds the selected identifier history. It is not a bound
inferred from the table's present occupancy.

Type-hash records and integer-hash entries have their own positive allocation
events. Their historical population can seed a capacity bound even after
deletion. `expand` selects `prime(2*live)` or retains the old size; low live
occupancy does not justify discarding retained capacity. `find_slot_with_hash`
can expand before a hit, so a replacement allowance per insertion-capable
lookup is appropriate. GC cache walkers clear/mark slots without calling the
resizing traversal. The packet checks the separate unsigned32 `8*elts`
operation in `too_empty_p`; size_t load checks would not suffice. Prime-tier,
probe-addition and individual request guards remain explicit.

The vector formula is a high-water bound, not repeated multiplicative growth
per lookup. Immediately before a growing push, old capacity is below the
desired live length. Bounding that length by incoming capacity plus cumulative
pushes therefore bounds both doubling and three-halves growth. GC capacity
normalization is included after rounding, and incoming retained capacity is
preserved separately. Pops or a deletable cache clear can create more cold
requests but cannot create more requests than pushes. Scalar-finalizer
registration is at most once per positive allocation; removal retains no
larger capacity than the historical push bound. Selected no-PCH context depth
zero is required for the stated inner-vector calculation.

The temporary-name argument withstands earlier identifier hits and deletion.
The retained GCC source has only the static unsigned `tmp_var_id_num`
definition and its increment in `create_tmp_var_name`. The selected installed
target headers use the default `%s.%lu` format. The last dot separates the
decimal serial even when the stripped prefix contains dots. Before a first
wrap, distinct serial values therefore produce distinct complete spellings.
A hit on a name previously created elsewhere still requires that spelling's
historical identifier allocation; a deleted node is not subtracted. A first
wrap would require 2^32 distinct historical identifier nodes, contradicting
the checked J<=UINT32_MAX bound. Current occupancy alone would not support
this proof. The names are already counted, so this proof adds no allocation
charge and establishes no later-consumer serial bound.

For retained Hello, the independent arithmetic agrees: 768 additional shared
GGC backing requests, identifier history <=40,882 with 65,536 slots, next
DECL_UID <=5,872 and next type UID <=2,306. The per-request ceilings agree
with the retained result. These are neither complete imported-event/byte
totals nor an aggregate RAM limit.

## Targeted checks and integration disposition

Fifteen independent grouped checks passed. One fresh Hello composition equals
the retained result apart from timing. Checks independently recomputed the
Hello arithmetic and file union; rejected mutations of the collector's zero
demand, function frontier and helper multiplicity; exercised a retained
131,071-slot hash with hit-only traffic; tested the exact unsigned `8*elts`
boundary and four identifier equality thresholds; and enumerated 75,876
heap/GC vector push/pop/clear transitions across incoming capacities
0,4,7,15,16,31 and up to 32 pushes. Small serial-width models retained earlier
hits and deleted nodes to challenge the historical-allocation interpretation.
These checks corroborate the source arguments; they do not prove them by
sampling. The worker's retained 208-check/3.690377-second run was inspected,
not broadly repeated.

The concurrent emission attachment changes exactly three of the shared
packet's pinned repository inputs: aggregate `compose.py`, `inputs.json` and
`result.json`. Running shared `Context` against that checkout is correctly
rejected with:

```text
changed shared-storage input: docs/evidence/retained-literal-pipeline-20261018/compose.py
```

All 15 consumed top-level projections in the old and emission retained
aggregate results compare equal: source, source_counts, complete_path_bound,
original Main/String/helper storage, synthetic storage, warning-map demand,
pool lifetime, collector callbacks, counter-emission interface, unresolved
predicates, failed conditional predicates and the false whole-pipeline flag.
AST comparison shows `evaluate` is the only changed pre-existing aggregate
function; the original consumer builders and recognizer remain unchanged.
Diff inspection confirms the added emission join does not change those
original intervals. Running the unchanged shared `derive` on that exact
emission retained result produces the same shared result. This last check is
an isolated compatibility test, not a bypass of `Context` for integration.

**Required integration follow-up:** after the emission attachment is accepted,
adapt the new shared packet to the exact integrated aggregate. Preserve the
historical predecessor checks; validate the current source recognizer and all
consumed interfaces/ownership fields above; bind the new aggregate identities;
and run focused same-source compatibility and affected mutation checks on the
integrated inputs; the successful 208-case run need not be repeated solely
for this identity adaptation.
Retain any aggregate failed or unresolved predicates. Updating hashes alone
does not establish compatibility. This is an expected integration obligation,
not an unresolved defect in the reviewed standalone freeze.

Ada Uint/Udigits/UI_Ints incoming and allocated state, other original gigi
direct/metadata families, later shared consumers, full global-counter and
collector lifetime, complete imported totals, production invocation and
whole-pipeline capacity remain open. The accepted result changes no Oracle,
admission rule, native tool, proof pin or production behavior.
