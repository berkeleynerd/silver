# Final regression census — 2026-11-05

Managed run `20261105T111005-483650d69229` **passed**: unittest reported
595 tests in 3919.144 s; managed outcome `success`,
3923.181 s including preflight. It started
`2026-11-05T11:10:08.454727+00:00` and finished `2026-11-05T12:15:31.635814+00:00` on native Linux x86_64.
The exact command was `/usr/bin/python3 -m unittest discover -s tests -v`.

All required test methods are covered and their successful results apply to the frozen integration inputs under the cited independent applicability review.
Failed IDs: 0. Skipped IDs: 0. Missing IDs:
0. Unresolved IDs: 0. Unexpected IDs:
0. No failures or skips are converted into passes.

## Inventory and outcomes

The frozen tree has 53 test files and 581 locally defined methods. Discovery
adds five inherited Image-method executions and nine SharedBindings executions
imported into `test_integer_loops`, for **595 top-level executions with 595
runtime-qualified IDs**. All 581 locally defined methods are represented by
successful results. The nine imported SharedBindings IDs execute the same source
methods also discovered through `test_shared_bindings`; they are duplicate
source-method executions, not nine new definitions. The two module qualifiers
are retained in the inventory. The five inherited methods retain their subclass
IDs and parent definition identities.

`inventory.json.gz` maps every expected ID to its source definition and line,
discovery module, inheritance status, and exact start/status lines in the raw
log. `summary.json` records all counts, per-module totals and any incomplete IDs.
The census parses source ASTs without importing or executing test modules.
The earlier scratch inventory omitted
`test_original_extreme_null_slice_failures_are_rejected`; this census includes it.

Successful subtests are not enumerated by the default unittest output and are
not added to 595. The passing manifest method checks 59 sample sources through
admission/proof/build/audit and 115 application argument cases. The symlinked
TMPDIR wrapper selects the 12-method `PlatformIsolationTests` child suite and
asserts its zero exit status; its successful captured child output is not printed.
Those nested methods are not extra top-level census IDs. Required native-Lean
fixture methods have actual `ok` results, with no required skipped IDs.

## Exact inputs and applicability

The run used frozen `fb89b3653accef6c08a49f88625144c108ad2432` in
`tmp/string-admission-repairs`; the integration source is frozen at
`3c156a2e09c5bfdd6e676cd690855fb05c6d0f16` (inspection HEAD
`a14aa1f50db313ab9e7891389c1aaac36dd2d7b3`, with documentation-only follow-up).
All 900 captured inputs match the live suite bytes; all 892 captured repository
source hashes match the suite commit. Integration matches 891 of those source
files exactly. Its sole source difference is the reviewed theorem-local
`set_option maxHeartbeats 3000000 in` before `interpreted_argument` in
`proof/Silver/ComposeEquations.lean`:

- Suite SHA-256: `f2462b54b0e03b063d3e32f4ec70119b8110f000b07982c8822d3599d5fffdf1`
- Integration SHA-256: `1c68e535f029804fb1c616ed2819607abd895fb95b48b3ba8a73c5135200ff9f`

All 892 inspected integration source files match the governed integration commit.
The [independent applicability review](../../../reviews/review-argument-proof-regression-applicability-20261105.md)
accounts for the exact difference, including shared platform fixtures and source
scans. This census confirms that its input relation still holds; it does not
repeat or broaden that review. The successful per-method results remain attached
to the original suite run and aggregate fingerprint, not a new final-input run.

Compiler build `20261105T110838-67ae26dc9265` passed before this suite;
its [retained events](../runs/20261105T110838-67ae26dc9265/events.jsonl.gz)
record that outcome. All 143 common captured repository build/test inputs match,
including every native source, Python runner input and native project input.
The suite-captured compiler SHA-256 remains
`9073495eaf5c326000fc141a8783efe3764f093129844316f88909cb9591e75c`.
The original prepared event retains the complete 900-path map and exact platform
artifacts/interpreter identity; the summary records category totals and all
comparison results.

## Retention and limits

`events.jsonl.gz` and `native.log.gz` preserve the authoritative terminal managed
ledger and log bytes. `artifacts-index.json` records original/compressed sizes
and SHA-256 digests; decompression was checked against the original bytes.
Console buffering is not used as outcome evidence.

Selected extraction settings: **GPT-6.1 Sol / Extra High**, supplied by the lead;
runtime model/effort confirmation, token usage and cost are unavailable.
The first explicit clock observation was `2026-11-05T11:58:43+00:00`; initial
inspection preceded it, so exact initial start/total inspection duration are not
claimed. The final record was produced `2026-11-05T12:16:23.793795+00:00`. The observed interval
includes waiting for the pre-existing full run.

No test/proof/build rerun was launched by this subthread. This record concerns
regression coverage only; it does not establish complete native proof/audit or
Lean/source-correspondence success. Those lead-owned checkpoints remain separate.
PR #307 remains open; no merge, commit or publication was performed here.

## Final input disposition — 2026-11-05

The census and comparisons above retain their original frozen-tree scope.
The later [independent applicability review](../../../reviews/review-final-regression-applicability-20261105.md)
checks the final source at `ddb183a918`, including the CPU-default change, the
declaration-local output-pin budget and the four-entry helper proof cleanup.
The complete test inventory is still 595 runtime-qualified IDs: **594 retained
method results plus one fresh replacement** from
`20261105T132715-c4a22b58c2d9`. Its other six passing methods are supplementary,
not added to the inventory. The [focused CPU packet](../lean-cpu-defaults/summary.json)
retains the seven results. No further regression rerun is required for these
changes under the review's dependency analysis.

The suite's original 900 captures remain attached to the tested installation.
The final source/configuration applicability claim does not assert byte identity
between its compiler binary and the integration worktree's binary: generated
configuration differs by installation paths. The review records that distinction
and the exact repository-input changes. Complete final Lean assurance is retained
separately in the [final checkpoint](../lean-final/README.md); native verification
and closing delivery review remain pending.
