# Repaired-compiler regression outcome — 2026-11-08

Managed run `20261108T093645-d959cfabae08` finished **failure** at
12:21:44 UTC. All 338 selected methods ran: 335 passed, three errored, and none
failed an assertion or was skipped. Unittest took 9,885.693 seconds; the managed
run took 9,898.123 seconds. Actual unittest, launcher and managed-driver exits
were all 1. This record does not relabel that run successful.

The regression checkout was `4281f71171477c24995eae18c983ae69b1cd1747`, matching
the governed implementation inputs at `f630819154`. The repaired compiler was
built in [093134](../repaired-build-093134/README.md). The original 637-method
result and earlier accepted composition remain scoped to their earlier inputs.

| Method | Actual final exception |
| --- | --- |
| `test_samples.SupportedSampleTests.test_maximum_dynamic_expression` | Compile subprocess `TimeoutExpired` after 300 seconds |
| `test_scalar_functions.ScalarFunctionTests.test_native_boolean_and_integer_self_actuals` | Compile subprocess `TimeoutExpired` after 120 seconds |
| `test_scalar_functions.ScalarFunctionTests.test_native_ordered_calls_snapshot_and_full_unused_coverage` | Compile subprocess `TimeoutExpired` after 120 seconds |

All 72 manifest samples passed admission, automatic proof/report audits,
compilation and expected runtime results on the repaired compiler. All seven
selected source-policy methods passed. The [summary](summary.json) reconciles
every selected ID with its raw outcome. One path-refinement method uses unittest's
ordinary two-line docstring display; its following description ends in `... ok`.
It is included rather than lost by a line-start-only status parser.

## Inputs, resources and preserved diagnostics

After the nonzero invocation, the coordinator independently rehashed all 1,115
prepared files and re-resolved the complete declared selectors. File membership
and bytes matched exactly, with no added or removed inputs. All twelve recorded
native tool executables and the custom Python executable also retained their
hashes. See [file identities](postflight-inputs.json) and
[selector/tool comparison](postflight-selector-tools.json). The earlier retained
result applicability comparison is preserved separately; it confirms the expected
changed parser/compiler and proof files without unexplained tool/configuration
drift. It is not final acceptance of the proposed 286 reusable outcomes.

The reviewed launcher reserved four workers and inherited CPUs 18–21. Its 652
observations recorded no affinity violations, observer errors or wrapper
interruptions; sampled host available memory stayed above 41.898 GiB. These are
process-leader samples, not continuous all-thread coverage or a memory/process
cap. Application Why3 processes requested 22 workers inside that CPU allowance.
The maximum-expression orphan overlapped the two later scalar cases on those
same CPUs. Contention is a hypothesis, not an established explanation of the
three timeouts. The earlier successful methods used different compiler inputs
and have no comparable per-method timing/affinity record.

The three diagnostic archives preserve 515 files, including source, generated
tasks and partial reports. The maximum-expression packet includes verified
orphan ancestry, task preservation and targeted cleanup records. Its cleanup
record reports no remaining live owned process. The two scalar archives contain
later partial reports with no unproved listed checks, but omit required
`silver_io` unit coverage and any built executable. Their reported successful
GNATprove invocation does not establish complete application proof or test success.
No missing obligation is waived. The post-exit process check at 12:23:50 found
no matching regression process-group member or reparented regression-artifact
command. It is a point-in-time scoped observation, not a general process audit.

The [artifact index](index.json) records 34 copied artifacts by original and
stored length/hash, including exact managed records, raw log, observations,
launcher/selector files, failure archives, retention script and scoped postflight
observations. The raw managed finished event also lists reports copied from
existing workspace outputs; that automatic inventory is not a claim that every
listed report was produced by this run.

## Remaining validation

After the still-productive complete native and Lean audits release capacity,
check the actual host CPU allowance, resource ledger, workspace lease and absence
of leftover work. Run only the maximum-expression method first with the complete
available allowance and matching reservation, preserving its 300-second deadline
and every production option/assertion. On success and clean child completion,
run each scalar method separately with its unchanged 120-second deadline. Any
new failure needs its exact diagnostic before another experiment.

Then run the unchanged original platform wrapper with the full available
allocation, preserving its 900-second outer, 180-second worker and 15-second
barrier deadlines and all twelve nested methods. Final review must reconcile
the complete 637-ID inventory with actual successful outcomes and exact inputs.
The three Rosetta checks still require fresh execution after promotion. Complete
native obligation/coverage/provenance and Lean actual-source/module/axiom audits
remain separate mandatory conditions. No retry, support promotion or merge is
claimed here.

Validation host is Linux x86-64. Independent failure diagnosis selected GPT-6
Astra / Extra High; runtime model/effort and token/cost telemetry were unavailable.
No CLI recall entry or live harness goal was changed.
