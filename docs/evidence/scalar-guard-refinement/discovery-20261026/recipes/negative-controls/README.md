# Six independent expected-fail guard controls

Prepared for #237 using selected GPT-6.1 Sol Extra High; runtime settings are
not independently exposed. No new native runner was invoked during preparation.
Only this new `negative-controls/` directory was written. Original batch inputs,
scripts and retained evidence remain unchanged.

The combined unsafe source in `../results/20261026T002359Z/unsafe` failed at
original lines 11 and 17. Its later four source sites reported proved after
preceding unsafe checks; those records do **not** establish four independently
exercised failures. Preserve that original evidence with this limitation.

Each new Main contains one original loop/body fragment **byte for byte**, with
only the needed original declarations and Main shell. Sources have only
`pragma SPARK_Mode (On)` and no author contracts, assertions or proof annotations.
`manifest.json` records original fragment ranges/hashes, the combined-source hash,
new source hashes and exact expected source positions. All six are **EXPECTED
FAIL** native proof controls; there is no positive probe rerun.

| Control | Exact expected check in its own Main | Counterexample |
| --- | --- | --- |
| `stale_replacement` | `main.adb:9:18`, `VC_RANGE_CHECK`, `X := (X + 1);` | The preceding assignment replaces X by 9. |
| `branch_join` | `main.adb:8:15`, `VC_RANGE_CHECK`, `X := (X + 1);` | Seed=9 takes the explicit else and joins X=9. |
| `omitted_else` | `main.adb:8:15`, `VC_RANGE_CHECK`, `X := (X + 1);` | Seed=9 bypasses the true arm and leaves X=9. |
| `loop_reentry` | `main.adb:8:42`, `VC_RANGE_CHECK`, inner `X := (X + 1);` | Seed=8 passes the outer guard; the second iteration attempts 10. |
| `minimum_negation` | `main.adb:8:36`, `VC_OVERFLOW_CHECK`, `Negated := (-Wide);` | Seed=Integer minimum makes negation exceed Integer maximum. |
| `shadowed_mutable` | `main.adb:9:12`, `VC_RANGE_CHECK`, `X := Wide;` | Seed=10 remains in the hidden mutable Wide after the inner same-spelled index ends. |

Expect exactly one **unproved safety source site per isolated project**, five
range sites and one overflow site overall. Additional proved checks/advisories
may exist. Full producer record counts are observations still pending. Expected
message substrings are `range check might fail` or `overflow check might fail`.
A nonzero exit alone is insufficient: the specified source site must actually
produce its unproved diagnostic. A frontend rejection without that proof record
is retained for manual review and is not automatically counted as this proof-site
expectation being met. Do not infer success from a proved diagnostic on an
unreachable path.

From the main checkout, inspect the plan and then run only these six projects:

```sh
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/negative-controls/run-negative-controls.py --runner-root /home/canto/src/github.com/berkeleynerd/silver
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/negative-controls/run-negative-controls.py --runner-root /home/canto/src/github.com/berkeleynerd/silver --execute --jobs 2
```

The plan command has not been run by the preparer. Execution is reserved for the
lead. The script first displays all managed task states and native paths; the
lead must check real worker/memory headroom, including the active doors run.
It uses the existing main checkout's installed pinned tools via managed
`dev.py tool`, explicit workspace/input declarations and serial execution.
There is no tool relocation, compiler implementation, admission run, binary
build, application execution, or positive/native repetition.

Proof settings exactly match the original application-style discovery:
`-U --mode=all --report=all --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000
--no-loop-unrolling --warnings=continue`. Workers are explicitly reserved with
`--jobs 2` by default.

Every invocation creates a new timestamp/UUID namespace below this directory's
`results/`; completed batch namespaces are never reused or overwritten. Each case gets
its own copied source/project, read-only submitted input files, isolated
`explore/guard-negative/<batch>` objects/sessions, full report copy, raw `.spark`
and separate SARIF inventories, exact command/start/end/elapsed/exit metadata,
and before/after source hashes. The runner writes per-case `run.json` and a
progressive batch `summary.json` while the new batch is active. It never modifies the templates or original
combined evidence. `diagnostic-summary.json` reports whether all six expected
sites were actually exposed. That means six observed expected failures, never
native proof success. Missing/extra diagnostics make the script exit 1 and need
specific review before another run. Full reports remain the evidence authority.
