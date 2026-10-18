# Independent review: conditional literal warning-map transfer

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The packet supports
its conditional warning-map request, growth and finalizer interface for the
selected literal family. It does not establish the original-gigi source count
R, complete native capacity or a production admission change.

## Exact inputs and scope

The frozen target was `dcfd30d999661634b561402792fa126b9f429637`, checked out
clean on `review/literal-warning-map-dcfd30d999` in an isolated worktree. The
six-file change consists of the
[source argument](../research/retained-literal-warning-map.md) and
[evidence packet](../evidence/retained-literal-warning-map-20261018/README.md):
`README.md`, `derive.py`, `check.py`, `check-results.json` and
`source-manifest.json`.

The review followed the applicable AGENTS, Oracle, retained-tool research
authorization and review bookkeeping. It reused the accepted
[native-ingress projection](review-native-ingress-eb0471fa33.md), its BIND
repair, and the protected-set storage review of
`38671493119c88a9bbfc2429ae9987473c9fc51f..789e7ddf4cfb3112b2184433f12dd2c548ef7bfc`
(review commit `a22221177a693adbbe38935d545b0fc9b59f628f`). Those predecessor
results were not rerun. The present work challenged the new warning-map
projection and transfer, including transitive initial-gimplifier warning
calls, rather than attempting to derive R or attach the leaf to the aggregate.

The source basis is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` on the
selected Linux x86-64/LP64 configuration. The focused checker verified all
28 complete source files and four retained inputs. An additional identity
calculation matched all 28 recorded Git blob hashes. I inspected the actual
source branches, not just the checker's string assertions. Installed behavior
correspondence and the previously accepted fixed-prefix projection remain
explicit premises; this is not new binary provenance evidence.

## Source assessment

### Prefix and original-gigi boundary

The map entry has a 64-bit location key and one unsigned-int bitset, giving
16 bytes with LP64 alignment. The map contains only its hash table; the
64-byte control ceiling covers the selected layout and the optional checking
pointer. The existing statistics-disabled configuration remains required.

The prefix witness's maximum rounded positive GGC request is 65,536 bytes.
Any then-existing map backbone therefore has at most 4096 entry positions;
the largest retained table prime within that limit is 4093. This inference
uses the maximum individual request, not the number of allocation events.
It does not imply that the prefix map exists, that it is full, or that later
requests share that byte limit.

The argument correctly limits transfer of this observation to warning-map
state under the accepted fixed-prefix semantic/location projection. I
checked the variable filename, line-map and association setup and the fixed
Standard/builtin setup before `Compilation_Unit_to_gnu`
(`trans.cc:320–690`; `utils.cc:430–450`). Variable metadata allocation sizes
are not covered by the 4093 argument. Standard locations map to reserved
BUILTINS_LOCATION independently of Main's source-map offsets. The existing
prefix and installed-behavior premises must accompany any use of this bound.

The local suppression count is sound as an event ceiling. `gnat_pushdecl`
suppresses before replacing the declaration location (`utils.cc:954–965`),
and constructors can initially use the current real `input_location`.
Consequently neither artificial declarations nor their final locations
justify assuming no map insertions. The accepted local inventory supplies
at most two TYPE_DECL pushes per call and one LABEL_DECL push per null,
giving 2C+N suppression calls. Each can perform at most one put.

R deliberately covers every other post-prefix put before Main's
`gimplify_body`, including replacements and global/imported/helper paths.
Global scope does not remove their warning-map effect. The named imported
profile and folding frontier is a real remaining source obligation; this
review supplies no numerical R. `evaluate(C,N)` returns no conditional
transfer, while supplying even R=0 leaves
`original_gigi_source_count_closed=false`. The packet does not introduce an
arbitrary multiplier or treat a numerical substitution as source closure.

### Selected initial gimplifier

The selected warning demand is J=2C+1: C+1 explicit tree-to-GIMPLE copies,
plus at most C location-to-location copies. The latter term is necessary
for a safe upper bound. `gimple_build_call_from_tree` sets the block before
the source location; a nonnull block can turn stored UNKNOWN into a nonzero
ad-hoc location. The next setter can therefore call `copy_warning` before
the explicit call copy (`gimple.cc:385–431`; `gimple.h:1928–1964`;
`tree.cc:14936–14942`; `line-map.cc:175–235`). The location overload does
not use the tuple's no-warning bit. No assumption that the temporary key
has an empty disposition is needed.

I checked all direct warning sites in `gimplify.cc` and the selected helper
routes. The nine direct sites reduce to the one bare-return copy: the
nonvoid return, condition, complex-part store, empty-type store, comparison
RHS, conditional cleanup and EH-filter cases are excluded by the accepted
body/type projection. A zero-length literal does not make the fat descriptor
or its pointer fields empty types. The Ada scalar NULL_EXPR suppression
route is likewise absent from the selected body and its local metadata.

Ordinary unsharing uses `copy_tree_r`, not inline-remapping callbacks;
temporary creation uses `create_tmp_var_raw`, not `copy_var_decl`.
The accepted local null/constant metadata and address/folding results rule
out further warning-bearing recursion or replacement. This reuse is specific
to initial Main gimplification and does not discharge original global type
construction in R.

Fresh assignment, label, goto, return and bind builders start from cleared
tuples. Selected explicit setters make their first location assignment;
`gimple_build_bind` stores its lexical block in the separate bind field.
Annotation sets only missing locations. `gimplify_body` initializes
`input_location` from Main's declaration (`gimplify.cc:21778`), and selected
statement locations either carry their ordinary source locus or inherit the
enclosing one. Thus the call builder's intermediate ad-hoc UNKNOWN location
does not create an unbounded repeated-annotation path. The final calls have
their source locus and are skipped by later initial annotation. Later CF
block/location changes remain the consuming phase's responsibility.

Both warning-copy overloads can put once or remove, and neither creates
the map. Hence this selected initial gimplifier adds no map control or
singleton finalizer independently of original-gigi creation.

### Hash arithmetic, requests and finalizers

For I=2C+N+R, occupied is bounded by 4093 plus preceding puts. Removing an
entry increases deleted without increasing occupied; tombstone reuse reduces
deleted; rehash removes tombstones. The proposed A_in and A_out therefore
cover arbitrary removal/reinsertion and repeated-key histories.

Expansion precedes key equality lookup, so a put that hits can allocate.
Each put nevertheless executes at most one expansion. Its new capacity is
either the old capacity or `prime(2*live)`, both bounded by the stated
`prime(max(4093,2*A))` envelope. The unsigned multiplication in
`too_empty_p` may wrap; either resulting branch is already covered. This
differs from the predecessor protected-set argument, where the no-deletion
growth condition short-circuits that predicate.

The sufficient endpoint A_out=1,073,741,823 gives p_out=2,147,483,647.
The separate unsigned probe-addition condition, size_t load products and
16-byte entry/pointer-span condition hold there. Hash truncation changes
collisions, while equality still compares complete location keys. The
maximum backing request is 34,359,738,352 bytes and rounds within the GGC
order table to at most 2^35 bytes. These are representation/request bounds,
not claims of available memory or peak live storage; old and new backbones
coexist during rehash.

The creation path allocates an initial 61-slot backbone. That fresh empty
table cannot expand on its first put, so initial plus replacement backbones
are bounded by I, rather than I+1. There is no selected reset or independent
reserve route. With at most J later backbones and one possible original-gigi
control, the additive map GGC-event ceiling 1+I+J follows.

The map control has a nontrivial hash-table destructor and receives at most
one singleton-finalizer registration. Entries contain only the key and
inline bitset, have trivial destruction, and add no vector finalizers
(`hash-map.h:40–46`; `hash-map-traits.h:63–67`; `ggc.h:180–255`). Shared
registration-vector storage, pages, collection and global counters remain
outside this component and require the collector join.

## Evidence and round record

One focused offline replay was run on Linux x86-64
(`Linux-7.0.14-x86_64-with-glibc2.43`):

```sh
python3 -B docs/evidence/retained-literal-warning-map-20261018/check.py --output /tmp/silver-review-warning-map-dcfd30d999-z9z3o7bn/check-results.json
```

It passed: 28 sources, four retained inputs, 60,000 hash-counter states,
111 expansions before existing-key hits, missing-R behavior, the sufficient
endpoint, its successor, prime exhaustion and four invalid inputs. Output
matched the retained result exactly except elapsed time. Checker time was
0.107760 seconds; the surrounding subprocess measured 0.152758193 seconds.
The historical result was preserved. The finite states supplement the
source invariant; the ctypes layout is a mirror checked against the source,
not a compiled C++ sizeof observation.

Selected reviewer settings were **GPT-6 Astra / Extra High**, assigned by
the parent. Runtime model/effort confirmation and token/cost measurements
were unavailable. Review began at 2026-10-18 19:43:19 UTC; source review,
replay and report completed at 19:48:14 UTC, an elapsed 295 seconds. This
is the review round's elapsed time, not whole-team runtime. The intended
outcome was an independent challenge of the
new conditional transfer; the achieved result is scoped acceptance without
implementation rework or a new material finding.

R source closure, complete gigi and gimplifier lifetimes, later CF warning
mutations, collector/page/finalizer-vector joins and whole-pipeline capacity
remain open. No compiler, prover, debugger, broad suite, aggregate replay,
delegation or GitHub write occurred. The live harness returned no goal; none
was created or changed. CLI memory was not updated. The parent owns aggregate
attachment, task integration and publication.
