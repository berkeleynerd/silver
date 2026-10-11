# Compose String Results

Authorized on 2026-10-11, starting from `767a33c`. The live harness goal and
Codex conversation title are **Compose String Results**. This combines two
roadmap items so their shared source-certificate changes could be validated at
one stable checkpoint. Implementation, complete Linux assurance and independent
review passed; the compositions are supported by [the language](../language.md).

## Bounded scope

1. Admit flat String output expressions of one through sixteen operands made from printable literals,
   existing bound names and left-associated `&`. Use them in existing output
   positions, including after assignment and in either conditional leaf. Count
   every static-name occurrence in the length bound. Permit at most one dynamic
   argv occurrence in each expression. Output following an assignment must use
   its result at least once; constant-backed output may omit its name. For an
   expression using argv, its canonical capacity plus all static operand lengths
   must fit 4096. A guard still limits the selected input when output omits argv,
   but then its capacity contributes nothing to the output-length bound.
2. Admit immutable argv input plus one distinct initialized fixed-length result.
   An equality choice assigns an equal-length literal to that result in either
   branch, then performs one common terminal output using the expression rules.
   Establish the result's initialization, fixed bounds and selected bytes at the
   join. The common output must use the assigned result. Keep the existing invalid-input rejection and output-failure semantics.

Smaller capacity guards deliberately reject over-capacity selected values,
including defaults; they do not truncate or silently replace them. General
additional declarations/copies, repeated output, repeated dynamic references,
arbitrary statements and new runtime APIs remain outside this goal. No Oracle
amendment, hosted CI or macOS proof work is included.

## Experiment and validation approach

Isolated native obligation experiments established the range/length checks,
advisory shapes and call dependencies before report policy was selected. The
implementation reuses lexical/runtime facts and a shared bounded expression
rule within finite program shells. Source admission remains decidable
independently of solver success.

The initial native experiments found that mutable String concatenations emit
proved range checks alongside the existing initializer advisory. Omitting the
assigned result creates additional dead-value diagnostics, so its required use
is retained. A 64-reference expression with empty values produced 62 range
records and a 108,299-byte report from 238 source bytes. The sixteen-operand
limit bounds this new composition without increasing report infrastructure;
empty operands count too. These observations guide admission/report design,
not universal assurance. Exact sources and results are retained in `experiment/`.

Focused native and model checks provided development feedback. The stable
combined inputs then received the complete Linux compiler audit, build/test
suite and cached Lean source-correspondence/axiom audit. Failed fixtures and
generated-certificate parity checks received affected correction reruns.
Independent review covered correspondence, report policy and evidence. Separate
kernel replay remains optional and was not run for this increment.

Local work and evidence live under `.silver/linux-x86_64/compose-results/`.
Preserve existing caches, tools, prior evidence, foreign-host artifacts and
unrelated `tmp/`. Publication remains authorized. The preceding review repair
is `767a33c`, with [its separate evidence and dispositions](lean-iteration.md#external-review-of-d375aec).

## Implementation and assurance

The implementation has one expression scanner and six output shells (nine
finite token forms with optional capacity guards), plus the separate null
shell. The same two source-derived selector bits choose static, argument,
assigned or selected-result Main report policies. Every emitted safety check
must be proved; only mutable shells admit the exact initializer advisory.
All four selected library reports remain mandatory.

`ComposeExpression`, `ComposeAdmission`, `ComposeSemantics` and `ComposeDecode`
connect independent parsing rules, ordered payload events, unique meanings and
weighted bounds. `ComposeMain` and `ComposeExecution` give the initialized
state, branch assignments and one terminal output their ordinary Ada meaning.
`ComposeObligations` bounds all concatenation prefixes, while `Current` composes
membership, automatic arithmetic discharge, runtime outcomes and the explicit
external-tool contract. The actual-source bridge checks the typed recognizer
bodies, finite form tables, machine-domain declarations and proved refinement
contracts. Retired suffix bridges are removed; retained fragment lemmas are
still covered by the whole-project audit.

This does not prove the GNAT frontend or solvers. Complete faithful obligation
generation, elimination of statically satisfied assignment checks and completion
within the selected solver policy remain documented premises. The bound of
sixteen operands and measured solver margin corroborate that policy; they are
not a universal solver-time theorem. See [assurance](assurance.md) and the
[trusted boundary](trusted-boundary.md) for exact claims.

## Completed Linux validation

Native evidence is retained under `.silver/linux-x86_64/compose-results/`.
The current host is Linux x86-64 with 12 available CPUs and about 31 GiB RAM.
Prior canonical evidence was copied to `preserved-before-integration/`; tools,
solver caches and unrelated Lake certificates are preserved.

- Complete compiler audit: **2,508 checks**, 17 units and 214 entities;
  403 flow and 2,105 proof checks, 49 classified limitation notes and 14 imports.
  All obligations passed. This is a full audit with cache reuse, not a cold
  performance measurement (`compiler-proof.log`).
- Native build and catalogue identity passed. The expression-parser proof
  separately discharged 401 checks; 282 focused admission/selector probes and
  seven new integration tests passed.
- The native obligation experiment covered empty and repeated operands,
  dynamic operand positions, both assignment branches, exact output/source
  bounds and tight/zero capacities. The two 16-operand branch leaves generated
  30 proved checks; the exact 4096-byte source used at most 764/10,000 solver
  steps. The complete local `experiment/REPORT.md`
  retains unsuccessful/out-of-scope probes with their actual disposition.
- Native and Lean admission plus both policy selectors agreed on **946 distinct
  sources**, including 240 admitted sources (`differential-results.json`).
- The full 209-test run exposed stale output-report fixtures and the two
  checked-in generated certificates. The fixtures and candidates were refreshed;
  the eight output-integrity and eight certificate/source tests then passed.
  Other full-suite tests passed. One subsequent native cache-removal regression
  brings discovery to 210 test methods and passed in the focused runner suite
  below. This is a full run plus affected reruns and the new test, not one
  clean 210-test run. Exact logs preserve the original failures; no native
  implementation change was needed for these corrections.
- The runner now removes only retired modules' compiled artifact families.
  Pinned Lake and direct Lean reject cached transitive importers after removal,
  while unrelated certificate objects retain their bytes and modification times.
  Thirty-eight targeted workspace/native/runner regressions passed. Earlier
  example witnesses now check their known form once, avoiding redundant scans
  through other shells while preserving the same whole-language theorem.
- Complete Lean 4.34.1 check: **108 modules, 25,648 declarations**, with only
  `propext`, `Classical.choice` and `Quot.sound`. The incremental build took
  2,660.266 seconds and the fresh whole-project axiom/module audit 2.811 seconds;
  total elapsed time was **2,664.425 seconds (44.4 minutes)**. The run used
  12 Lake workers, 12 threads per process and a 12,288 MiB per-process threshold.
  It rebuilt the changed output specification/body certificates; the body took
  2,436 seconds. All ten unrelated certificates retained identical SHA256 and
  modification times. This is cache-preserving complete validation, not a clean
  build or separate kernel replay.

The cache-preserving runner edit followed the successful compiler audit.
`native-input-scope.json` confirms that only `scripts/check_lean.py` differs
among that native manifest's recorded inputs. All Ada, generated configuration,
projects and tool inputs remain as audited. The original full manifest retains
its original snapshot; it is not claimed to match the entire later tree.
The runner is validated separately; no unchanged SPARK proof is repeated solely
for that script change.

The complete current-source Lean checkpoint finished at 15:02 UTC on 2026-10-11.
`lean-proof.log` and `lean-evidence.json` preserve the canonical log and manifest;
`lean-check.log` captures the outer invocation. The retained input digest is
`fa3a93224a808570b67d887156ddcf73836ec333e412f0177fb2a2e1baf045a6`.
Independent evidence review recomputed that digest, tool identities, protected
workspace copies and actual imported-module coverage against current inputs.
It also confirmed the ten unchanged certificates and the native manifest's
script-only difference. No material validation gap remained within the
authorized Linux scope. Hosted CI stays disabled; macOS proofs are outside scope.

## Independent review

Focused reviewers checked native admission and report routing, universal
expression and mutable-state semantics, actual-source correspondence, the
retired-module cache change and the evidence scope. The final semantic and
source reviews found no remaining material discrepancy.

The source review identified two concrete integration gaps during development:
lexical interpretation initially was not consumed by the new equation closure,
and the Step interpretation admitted mathematical tokens outside the native
finite tables. `ComposeEvaluation` now derives normalized equations from actual
helper interpretations and executed-call domains; `ValidToken` restricts Step
to the real tables. `ComposeSourceBridge` consumes that chain in its public
admission, selector and pipeline theorems. Isolated kernel checks and standard-
foundation audits passed after the repairs, followed by the complete canonical
checkpoint and independent evidence review.

The implementation/review target is the commit introducing
`samples/composed_result.adb`, based on `767a33c`. Broader initialized bindings
and compatible copies remain the next proposed roadmap item; no such further
expansion is authorized by this record.

The closing implementation commit is identifiable without a self-referential
hash:

```sh
git log --diff-filter=A -1 --format='%H %s' -- samples/composed_result.adb
```

The final handoff records that commit, remote synchronization and the disabled
Actions state locally in `compose-results/publication.json`. The Codex CLI title
was rechecked as **Compose String Results**. No recall entry was updated because
no CLI recall tool or conventional recall directory is available; checked-in
[session memory](session-memory.md) remains the durable record.
