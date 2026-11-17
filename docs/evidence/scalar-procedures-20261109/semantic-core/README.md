# Scalar procedure semantic core checkpoint

Focused Linux run `20261110T004159-c31395be0a84` passed the procedure semantic core through `PredicateChecks`, the static parameter/output layout, and safe expression noninterference. Its fresh axiom audit checked 15,228 declarations with only `propext`, `Classical.choice` and `Quot.sound`. The code is commit `a71e3ccfbf`, following the call/input/copy-back core at `8d76e3528c`.

The model constructs meanings from checked bodies and earlier callable prefixes. It covers mandatory output initialization, full-domain body safety including unused definitions, complete obligations, copy-back permutation independence, and static output-read readiness. The noninterference theorem preserves both safety and value across writes; incoming safety is necessary for array accesses. Actual-source sequential-prefix correspondence remains a separate required bridge.

The managed archive retains the successful audit, exact input inventories and tool hashes, the prior core success, and the failed attempts with their original diagnostics. The eight-worker/eight-thread allocation left the coordinated native proof and root fixtures their reserved shares. No complete native or integrated source assurance is claimed. The String bounds consumer drafts were outside this focused target closure.
