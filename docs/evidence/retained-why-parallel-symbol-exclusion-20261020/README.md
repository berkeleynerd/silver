# R54: actual metadata and residual symbol exclusion

The [source argument](../../research/retained-why-parallel-symbol-exclusion.md)
uses the immutable R53 acquisition freeze
`43bbaf6805d7dc10269f9efe1b2394663bf0feee`. `inputs.json` pins every reused graph,
certificate, capture, address map and source archive. No native target, solver,
old capture reader, old model checker or broad proof suite is rerun.

`derive-metadata.py` reconstructs actual driver-updated metadata from captured
ordered maps/sets, typed arguments, theory local sets and clone maps. It also
censuses raw polymorphic declaration signatures and Dind head/clause keys.
The five `*-metadata.json` files preserve every applied/dropped meta and physical
argument. `derive-exclusions.py` demand-evaluates each marker's actual inlining
eligibility and the preceding definition dependencies, checks visible CE marker
occurrences through delayed frames, and records the Put-family removal cluster.
It does not simulate the entire Z3 pipeline or claim a machine-checked theorem.

Each of the five `*-exclusions.json` files records exact physical pointers for
its two, two, four, two or three residual keys. Actual `>` memberships in
`syntax_logic` and `remove_unused:keep` are retained as positive facts, not
erased to make a symbol-absence argument easier. The note explains why those
metadata consumers do not reintroduce a term application. It separately checks
literal range/float metadata and library lookup, fresh/cached closure symbols,
Introduction's name/content table and Wdecl queues, failed insertion prefixes,
and epsilon-bearing earlier stages.

```sh
python3 -B docs/evidence/retained-why-parallel-symbol-exclusion-20261020/check.py
```

The check reads the three necessary files directly from each frozen archive,
reconstructs the ten metadata/exclusion JSON outputs in worktree-local temporary
directories, compares them exactly, and checks all source excerpts/identities.
It does not repeat R53's memory-reader replay. `--refresh` is an explicit author
artifact-generation mode. `source-witnesses.json` contains the exact pinned
source excerpts; `result.json` separates the source-level fixed-input family
claim from still-unattached arbitrary intended-parallel mutable native state.

The Input table projection is from its old post-first-CE stop and contains three
compatible CE objects, unlike the four registration projections. Its immutable
raw graph was nevertheless exactly joined to R53's new registration graph.
The certificate preserves this stop distinction. R54 leaves all R53 acquisition
artifacts unchanged.
