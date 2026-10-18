# Literal combined-location and later warning lifetime

Offline research for [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#137](https://github.com/berkeleynerd/silver/issues/137),
Linux x86-64/LP64. The [source argument](../../research/retained-literal-location-lifetime.md)
establishes `Q=8C+4N+7` combined-location attempts and `J_later=8C+3N+4`
insertion-capable warning puts after the retained initial-gimplifier boundary.

```sh
python3 docs/evidence/retained-literal-location-lifetime-20261018/derive.py \
  --shared-correction-output docs/evidence/retained-literal-location-lifetime-20261018/shared-identifier-correction.json
python3 docs/evidence/retained-literal-location-lifetime-20261018/check.py
```

Both commands accept `--gcc-root`, `--ada-root` and `--output`; the derivation
also accepts `--source` and `--path-bytes`. Defaults use the retained source
trees and actual `samples/hello_world.adb`. No aggregate evaluator is imported.
The context loads only the unchanged complete literal recognizer and the
accepted warning-map arithmetic, validating their exact repository inputs and
complete relevant compiler source files first. `derive(C,N,predecessor,primes,P)`
is the pure interface for an already recognized source and the checked leaf
warning result. `evaluate_source` performs the complete source/count binding.

For Hello, `result.json` has Q=15, at most one ad-hoc array allocation and at
most 12 later warning backbones: **13 new GGC events**, no new controls or
finalizers. The original warning interface remains embedded unchanged. Its
11-event bound is diagnostic input, not added a second time to the new delta.
The separate filename interface reports 3,180 direct node/string requests.
It preserves the historical 1,589 lookups and explicitly adds the indexed
startup-System duplicate: 1,590 lookups and 1,589 Source_File records. These
requests are excluded from the new delta and the shared GGC backing subtotal.

`corrected_shared_identifier_projection(shared,source,counts)` requires exact
per-source identity/count equality and the old identifier interface, then
recomputes the corrected histories, capacities, four identifier guards and
temporary-name serial guards. `shared-identifier-correction.json` is its
separate Hello diagnostic: incoming 40,847, endpoint 40,883, capacity 65,536;
the 768-event original shared GGC subtotal is unchanged. The optional output
flag requires the selected source to match the retained shared result. A
consumer of another source supplies its own checked shared result to the pure
projection. The historical packet is unchanged; aggregate attachment and #137
completion remain with the parent.

Ordinary ad-hoc hash requests include Q lookup-triggered backings and at most
one possible backing per post-initial array relocation traversal. Those are
ordinary allocations, separately bounded from the GGC array requests.

`inputs.json` pins 121 complete compiler sources and 33 repository inputs.
`writer-inventory.json` records a complete retained gcc/libcpp C/C++
name/content census (3,574 files), location API matches and selected warning
setter/copy matches. `inventory.py` recomputes it for the focused check. The
census includes declarations, other frontends and selftests; the handwritten
case argument establishes reachability. No source-match count is an allocation
multiplier or a proof of source semantics.

`check-results.json` records exact callable/note identities and elapsed checker
time. Checks include source mutation rejection, actual-source variations,
retained frontier/ownership equality, prime and width guards, neighboring
growth limits, and independent repeated-key/deletion/growth simulations.
This is not native execution, a new installed binary/source correspondence
claim or a full compiler/prover test. Existing accepted component suites were
not rerun. Independent review is pending.

The whole native event sum, ordinary-map and GNAT-association-array storage,
other frontend/shared/pass lifetimes and collector pages/finalizers remain
separate. `total_GGC_events` is null; whole-native, complete gimplifier,
global-counter, collector and production flags remain false. The actual Main
line guard retains the ordinary mapper's independent 32-bit line condition;
fixed/virtual source predicates are not inferred from its bytes.

Selected model/effort: GPT-6 Astra / Extra High; runtime confirmation and
token/cost data unavailable. `round-start.json` records the implementation
checkpoint, not an invented start time for the earlier source investigation.
Base: `1d5bcbe4469b8df7b5a260e2656a1dc0ef9b161a`. Work is confined to this new
packet and its note. No native tool, proof, build, GitHub or CLI-memory action
occurred; the parent owns review, integration and durable task reporting.
