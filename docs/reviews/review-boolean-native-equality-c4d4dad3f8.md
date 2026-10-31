# Boolean native equality-proof candidate review

Independent read-only inspection, 2026-10-30 20:01:01–20:03:23 UTC
(2m22s). Selected reviewer: GPT-6 Astra / Extra High; runtime confirmation
and token/cost measurements unavailable. No repository edits, tests, builds,
proof runs or GitHub writes were performed. The lead retained the conclusions.

Inputs: integration `c5ba1f92ba782e677982babd664af0eebaa5eb10` and the two
identical candidate copies of `src/silver_output_profile.adb` in the native
validation and native-agent worktrees. Baseline SHA-256 is
`9542d721cb1d63f936704058e6e0705b615fdce9e86d08397a2384c7714cc4a0`;
candidate SHA-256 is
`c4d4dad3f868910bf1ee86168ee099406ed0c50b74cf39e26135eb662a4a7b79`.
The failed native packet, relevant contracts/models, source checks, test
fixtures, invalidation rules and analogous annotation-repair review were
also inspected. Focused proof validation was still pending.

## Result

No static blocker. Every executable operation, branch, return and assignment
is preserved. `Expected` is explicitly `Ghost => Static`; all four added
assertions are Static. Pinned SPARK 16.1 rules erase them even with `-gnata`,
so they add no runtime recursion, storage or failure path. This establishes
unchanged executable semantics under the existing compiler assumptions,
not byte-identical binaries.

The new assertions expose the original model equality at each exit: invalid
first factor, absent comparison, disallowed comparison and completion after
the second factor. They create proof obligations, not assumptions. The exact
Static postcondition, full precondition domains, discriminants, variants and
`Same_Condition` definition remain unchanged.

In the eager-chain branch, neither short-circuit case applies, so the existing
`Right_Model` initializer selects exactly
`Relation_Model (Text, Context, After, Incoming, Initials)`. Substituting that
name into the unchanged ghost lemma preserves its `Left = Right` precondition
and `Same_Condition` result. Later exact equalities remain intact. No proof
weakening or scope expansion was found.

## Source correspondence and regression requirements

The indicated Lean changes are the complete body-token pin
`ReviewedOutputShape.outputImplementation` and the regenerated
`OutputBodyCertificate.lean`. `PredicateNativeWorkers.Checked` binds unchanged
procedure specifications and implementation headers. Models and semantic
statements remain unchanged; the existing source binding already includes the
actual Ada file. Review the resulting pin/certificate delta and complete its
actual-source checks and transitive audits; regeneration alone is insufficient.

The smallest justified regression selection is:

| Selection | IDs |
| --- | ---: |
| `test_lean_source` | 12 |
| Twelve `PlatformIsolationTests` and the symlinked-TMPDIR installation test | 13 |
| `test_output_integrity.OutputIntegrityTests` | 17 |
| `test_silver.SilverIntegrationTests.test_tool_failures_and_source_changes_do_not_report_success` | 1 |
| Total | 43 |

The platform fixture copies changed Ada and the complete Lean tree. The
additional 18 compiler-integrity identities rebuild the compiler from current
source in separate fixtures. Running all 16 platform tests is a convenient
superset: 46 refreshed plus 522 applicable retained results would cover 568
identities, conditional on successful reruns and final input verification.
These 46 distinct IDs belong to the existing inventory. The retained group
includes six earlier repair/Rosetta passes, so relative to the original full
suite this would be 516 retained plus 52 refreshed results.

Other runtime/sample results remain applicable through the reviewed erasure
argument; Rosetta dependencies are unchanged. Rebuild the final native compiler.
Successful complete native proof/audit and Lean/source/module/axiom checkpoints
remain mandatory. Neither the failed full run nor focused success substitutes
for them.

## Subsequent validation outcome

The focused relation run `20261030T200101-c56457a2df8d` subsequently failed
on all four added equality assertions. The
[retained experiment](../evidence/boolean-objects-20261030/terminal-native-repair/README.md)
records that outcome. The static review above does not establish discharge;
this candidate was not integrated. A revised proof candidate needs its own
focused validation and review of the changed reasoning.
