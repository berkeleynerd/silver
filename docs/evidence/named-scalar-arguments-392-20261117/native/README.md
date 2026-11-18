# Named scalar arguments: native work record

Work for [#392](https://github.com/berkeleynerd/silver/issues/392), Linux ARM64,
2026-11-17. This records the native implementation and successful focused
contracts, not a complete compiler or feature-assurance checkpoint.

The isolated source worktree is `tmp/named-native-392`, branch
`feat/named-arguments-native-392-20261117`. Its independently bootstrapped pinned
tool tree resides on the host mount. `.silver/linux-aarch64` is a real bind
mount backed by the native filesystem at
`/home/agent/silver-workspaces/recovery-volume/named-392-native-artifacts`.
No previous compiler object tree was seeded. Other workspaces remain intact.

The implementation changes only `src/silver_output_profile.adb`. Existing
function/procedure binding packages and their metadata domains are unchanged.
`Formal_Set` has the existing source-derived 585 slots. The native walkers
select formals while traversing source order, keep incoming facts fixed, and
check every association once using a seen set. Procedure alias checks replay
the actuals and call the established name scanner only on payload spans.

All native invocations use a 16 MiB process stack. Focused proofs use complete
subprogram selectors, all flow/proof checks and reports, warnings/checks as
errors, level 2, CVC5/Z3/Alt-Ergo and the unchanged 30-second compiler timeout.
They share the isolated `explore/named-392` workspace and preserve matching
sessions. They do not create complete audited proof evidence.

## Initial build and focused checks

The fresh compiler build `20261117T020957-0e2c32374126` passed with original
exit zero and 12 available workers. The first complete
`Function_Formal_Model` check, `20261117T021119-5307e68878d2`, passed all 14
checks, also with original exit zero and 12 workers. The initial managed
summary showed 81 recorded runs and no active reservations before these checks.

`run-focused.py` then drove separate whole-helper checks sequentially, recording
the exact source hash, selector, command, original subprocess result and a
two-second process-tree RSS/host-memory sample stream. The successful initial
helpers were:

| Helper | Managed run | Checks |
| --- | --- | ---: |
| `Function_Formal_At` | `20261117T021342-9d35fac45c93` | 20 |
| `Procedure_Formal_Model` | `20261117T021350-b364c77ef924` | 14 |
| `Procedure_Formal_At` | `20261117T021356-f68f47651449` | 20 |
| `Function_Association` | `20261117T021404-4e72822ba3f4` | 10 |
| `Procedure_Association` | `20261117T021412-f90fd119f518` | 10 |
| `Function_Actuals_Tail_Model` | `20261117T021420-2bcab3ce5d28` | 19 |
| `Actuals_Model` | `20261117T021506-9c28ebcaf877` | 8 |

Together with the initial lookup model, these are eight complete helper checks,
115 checks on that draft. Their reports do not establish the unproved caller
or any subsequent changed input. The final complete checkpoint remains required.

## Failed function-walker invariant and diagnosis

The first whole `Actuals_After` check, `20261117T021524-7cd50f30e0ae`, exited
one. Only preservation of the recursive-model equality loop invariant at the
then-current line 5178 remained unproved. Runtime checks, invariant
initialization, the postcondition and termination passed. The Why3 session's
VC 199 recorded CVC5/Z3 timeouts and an Alt-Ergo memory result; there was no
reported semantic counterexample. Observed peak process-tree RSS was
2,519,184 KiB and minimum host available memory was 13,317,856 KiB.

The first repair bound the initial `Actuals_Model` result once in a `Static`
ghost constant `Expected`. It did not change runtime statements, contracts,
domains, model equations or proof policy. The second whole-helper check,
`20261117T022532-ff4258486bca`, also exited one on the same preservation
obligation, now line 5180. Its new ghost initializer and all remaining checks
passed. Observed peak RSS was 2,854,032 KiB and minimum host available memory
was 12,887,664 KiB. This run used four workers to reserve actual capacity for
concurrent focused Lean work on the 16 GiB host.

Both exact sources, managed records, native reports, generated proof input and
Why3 sessions are retained:

- `failures/actuals-after-r1.tar.gz`, SHA-256
  `bcf064107f5b3617db862fee613d2bccd526954b7437b29761e6c4dae82ce62b`.
- `failures/actuals-after-r2.tar.gz`, SHA-256
  `1b3b5072732a53c4fa277ff993c09f87efe2f164b090c325f07d2f8f50a85751`.

The managed ledger contains diagnostic notes for both failures. The batch
stopped rather than retrying the same invariant again. A precreated next-scope
directory records a requested coordination pause, but the actual stop was the
failed proof, before that gate was reached.

The next discriminating check isolates the exact successful nonfinal recursive
branch in `Lemma_Function_Actuals_Advance`. Its complete precondition retains
arbitrary valid metadata and seen/named state, and states the actual branch
guards: nonzero in-slice resolver, unseen formal, successful typed payload and
comma. The postcondition is the exact tail equation with the same incoming
facts, `Association.Named` and the single seen-slot update. Its null `Static`
ghost body must establish that equation; it does not introduce an assumption.
Lead and semantic-model review accepted the contract before any loop use.
The standalone lemma must pass its entire native contract before consumption
and another whole-walker check. The source-proof owner is accounting for the
exact ghost declaration and eventual full argument-list call.

The first standalone lemma run, `20261117T023511-79803c3004b6`, exited one:
all well-definedness/pre/range/index checks passed, but its exact recurrence
postcondition timed out. This isolates the failed equation from imperative
loop state and mutable seen-slot assignment. The lemma has not been consumed.
The source/session packet is `failures/advance-lemma-r1.tar.gz`, SHA-256
`61910f6bb73ef0e3fc315ead80666dbf696a37c1a164bca18b10252c7cd9a9f0`.

`diagnosis/advance-model-definition.json.gz` retains the extracted exact model
definition axiom; `advance-model-inventory.json` records its generated-input
hash, 14,413,418-byte input size, 1,214 theory declarations and guard/body symbol
inventory. The axiom is present, and its guard contains the ordinary dynamic
type invariants and original model precondition. Its body still expands the
association and actual readers even though the lemma precondition fixes their
results and all bounds needed for this equation. `before-local-hiding.patch.gz`
retains the source before the next proposed change.

Independent lead inspection agreed to test two caller-local `Hide_Info`
annotations inside the ghost lemma, for exactly `Function_Association` and
`Actual_Model`. These remove callee bodies from that proof context while
retaining their proved contracts and every original obligation. The root owns
the exact source-policy whitelist extension and negative controls. This is
proof-context control within #392, not a proof-budget or language change.
The annotated lemma still requires complete focused success before use.

The first annotation retry, `20261117T025010-0841790d63ef`, exited one during
flow analysis after six seconds: both annotations were incorrectly placed in
the executable statement sequence. GNATprove requires their placement at the
beginning of the declarative part. No recurrence VC was proved or disproved by
this setup failure. Exact source, original logs and managed records are retained
in `failures/advance-lemma-r2-placement.tar.gz`, SHA-256
`69339355dae27bb76252ff2fd92cf4af2537b1f727e0f008cadeb632f30a2efd`.
The next check moves those same two annotations immediately after `is`, before
`begin`, matching the pinned annotation guide and established report-auditor
pattern. Lead review confirmed this correction; the whole standalone lemma is
checked again with the same contract and unchanged canonical policy, before use.

The correctly placed retry, `20261117T025551-c79f975d17c7`, also exited one:
17 of 18 total checks passed, with only the recurrence postcondition unresolved
at the prover time limit. Sampled peak process-tree RSS was 2,049,072 KiB and
minimum host available memory was 13,709,056 KiB. Exact source, generated input,
Why3 session, native reports and managed records are retained in
`failures/advance-lemma-r3.tar.gz`, SHA-256
`0ea5e2213a23f007297d80f4c46ebd2f82fe654b3f353e33c2cfe468602066ac`.
The runtime source remained frozen for the lead's behavior-suite validation.

The follow-up read-only diagnosis found that identical textual seen-array delta
aggregates receive distinct generated functions: the recursive model uses
`temp_____aggregate_def_20197`, while the lemma postcondition uses
`temp_____aggregate_def_20357`. Both definitions provide the same in-range
component equations and fixed bounds. The pinned array theory makes logical
array extensionality available through an `eq_ext` trigger; the current lemma
does not explicitly introduce that logical-equality bridge. Thus ordinary
finite component equality does not give the recursive function a syntactically
identical map argument. This is a proof-context diagnosis, not a counterexample
or a missing semantic condition. The exact four-theory extract is
`diagnosis/advance-lemma-r3-map-theories.json.gz`, SHA-256
`9e5c8f4ecb32668fe2c1b2a875530ba8a6054425390932681591892290161f1c`.
The current generated input contains 1,212 theories and 14,393,064 bytes.
The next bounded design under independent review is a shared pure mark helper,
used by both the models and executable loops, versus the existing checked
`Logical_Equal` fixed-array pattern. No budget increase, domain restriction or
unproved lemma consumption is proposed.

The current-source incremental build `20261117T024053-f027e2fd5fd4` passed
with original exit zero and four workers for the root's early behavior probes.
This build includes only additional `Static` ghost proof work since the first
build; runtime association behavior is unchanged. It does not imply complete
compiler proof success.

## Shared mark repair and focused coverage

Independent review agreed to introduce `Mark_Formal`, a pure executable
expression function over every `Formal_Set` and every `Formal_Index`, including
already-true selected slots. Its full pointwise postcondition states exactly
the selected true bit and every retained bit; it adds no freshness, metadata or
name premise. The sole delta aggregate is in its body. Function/procedure tail
models, the standalone lemma and all three executable seen updates now call
that same helper. The two ineffective `Hide_Info` annotations and their exact
source-policy exception were removed before this check.

The resulting complete helper checks passed under the unchanged canonical
policy, with original exit zero:

| Helper | Managed run | Total checks |
| --- | --- | ---: |
| `Mark_Formal` | `20261117T030407-b3240d065003` | 4 |
| `Function_Actuals_Tail_Model` | `20261117T030415-51aceca89628` | 18 |
| `Actuals_Model` | `20261117T030503-fcaffafcf0c0` | 8 |
| `Lemma_Function_Actuals_Advance` | `20261117T030521-b3de4cb2f740` | 17 |
| `Actuals_After` | `20261117T030726-c84f7e1c4a36` | 31 |

The first four used all 12 available workers while the source author was
implementing the corresponding helper binding. Only after the standalone
lemma passed was its exact transition consumed in `Actuals_After`, before
changing the original cursor, named flag or seen set. Typed payload and comma
cursors remain local until all success guards hold. The whole walker then
passed with four workers alongside the source work's eight-worker allocation.
The procedure tail, wrapper and walker also passed without a second ghost
advance lemma. No complete integrated proof has yet been run.

All 26 planned output-profile helper/model/walker/caller scopes passed, totaling
506 checks across their covering runs. The final `Basic_Body` check,
`20261117T032207-69c04762d371`, passed with peak sampled process-tree RSS
4,727,840 KiB and minimum host available memory 11,036,304 KiB. The already
captured four-worker batch continued when source validation released its eight
workers; no productive proof was interrupted merely to resize it. See the
complete [helper/run table](coverage.md) and [machine-readable record](coverage.json).

`shared-mark-r1/source.adb.gz` and `walkers-r3/source.adb.gz` preserve the exact
source bytes for these batches. Their decompressed SHA-256 identities match the
invocation records. `summarize-coverage.py` reads retained native reports and
captured sources to write `coverage.json`: each required helper's successful
whole-subprogram run, original exit, source/report hashes, check total, local
declaration/body match, and the outstanding helper list. Local text comparison
does not replace dependency review or complete final native/source assurance.

The lead's separate catalogue-export correction, commit `eabd7127f`
(native-branch cherry-pick `b4a73e4fa`), was integrated after the scalar batch.
The whole `Export_Constructs` helper passed in
`20261117T032921-f38b729850b7`, and public `Export` passed in
`20261117T032925-b5754f351131`. These checks used all 12 available workers,
the same canonical policy and the isolated exploratory workspace. Their
source, invocation and report hashes are in `catalogue/coverage.json`.
The exporter generated one successful data-dependency check and no proof VCs;
the public caller generated no checks. Both were flow-analyzed and reported
`all` in SPARK over the complete selected subprogram. This is not a claim of
additional numerical proof obligations or runtime catalogue parity.

## Round record

| Round | Selected settings | Result and cost evidence |
| --- | --- | --- |
| Native implementation and recurrence diagnosis | GPT-6 Astra, Max, confirmed from the lead's spawn record; independent live model/effort telemetry unavailable | Initial recurrence isolation and the ineffective annotation experiment were retained. Independent array-theory review identified the shared-update correction, whose helper and recurrence checks passed before walker consumption. Exact native elapsed times and two-second resource samples are in per-run JSON/logs; full agent elapsed time, token and monetary measurements are unavailable. |

## Integration handoff

All scoped native helper contracts and affected caller contracts are now
covered. The final output-profile source SHA-256 is
`de017ca035a5ffd358d5fa98646d017dfe4ef54bd822fafc40743a9a8ae66f53`.
No metadata package, public output-profile specification, input domain,
language budget or proof policy was changed. The full input/source guarantee
still depends on the root's complete native audit, complete Lean/source audit,
regression and catalogue checks on the integrated inputs. The root owns those
checks and the capability documentation/publication; this scoped handoff does
not close #392 or claim complete feature assurance.
