# Larger Expressions

Status: complete, authorized and validated 2026-10-15 against `fa0048d90b` on Linux x86-64.
The [roadmap](../roadmap.md#larger-expressions) retains the scope and completion
criteria. The 100,000-step application allowance is already implemented; this
milestone expands admission from sixteen leaves/thirty concatenations
to **64 leaves per expression and 63 concatenations per source**.
The latter is the smallest budget permitting one maximal expression,
with the same total work distributable across expression positions.

## Work and completion criteria

| Order | Work package | Status and required result |
| --- | --- | --- |
| 1 | Composition and capacity | Complete: eight compact current-runtime probes and one dense mixed workload passed proof, report policy, code generation and execution. The measured specimens fit the then-current report capacity; review B1 later disproved using those specimens as capacity assurance. Prior flat successes remain supporting evidence. |
| 2 | Implementation and assurance | Complete: matching SPARK constants/arithmetic storage, Lean membership/source guards, catalogue/specification, sample and boundary/sibling tests. Universal model and complete source checks passed; 4096-byte source/value bounds and the assignment/literal repairs are preserved. |
| 3 | Stable checkpoint and delivery | Complete: stable-input native proof/build and complete cached Lean/source checking; full suite plus test-only fixture correction/recheck; focused differential/code-generation pass; independent review and final content checks. This record accompanies the authorized implementation commit and publication. |

No new API, Oracle amendment, alternate proof engine, mandatory replay or
unrelated deferred cleanup is included. Existing report acceptance and trusted
external-tool premises remain. Failed or interrupted experiments do not authorize
weakening current guarantees; a candidate that cannot be justified stays excluded.

## Implementation and assurance scope

The implementation changes two admission constants, the matching catalogue fields,
and the path-summary storage ranges. A path summary can contain 4096 static bytes
and 64 dynamic occurrences, each at most 4096 bytes, so its arithmetic subtype
must cover `65 * 4096`; this is intermediate recognizer arithmetic, not an enlarged
application String allowance. Literal adjacency, unreachable static assignment
compatibility, initialization rules, path facts and output behavior are unchanged.

The existing Lean arithmetic and grouping arguments are generic in occurrence
counts. They establish affine lengths, bounded intermediate values, fixed-bound
assignments and valid obligation schemas at the expanded constants without adding
assumptions. Source guards and regenerated certificates must still connect those
models to the actual SPARK bytes. Physical GNATprove/solver completion and faithful
complete reports remain the documented external-tool premises; no theorem asserts
that 100,000 SMT steps suffice for arbitrary SPARK or every concrete solver run.

The new `release_report.adb` sample formats nine fields using eighteen leaves.
Its fixed contribution is 145 bytes, so the 3951-byte argument guard preserves
the 4096-byte result bound. The manifest covers default, explicit, empty and extra
arguments. Native boundary siblings cover every expression position, grouping,
aliases, byte capacity and the shared operator budget. At a 63-operator source
budget, a 65-leaf program crosses both budgets; the low-level Lean expression
example separately checks the expression limit.

## Composition measurements

Eight compact current-runtime probes passed with fresh proof sessions and caches,
the production 100,000-step configuration, complete code generation and expected
executions. The native production report-policy harness accepted their Main and
selected-runtime reports. Timings may overlap other work and are supporting
measurements, not a controlled performance comparison. Sampled memory sums process
RSS and can count shared pages more than once.

| Case | Proof seconds | Sampled process-session peak, GiB | Main checks, all proved | Main report bytes |
| --- | ---: | ---: | ---: | ---: |
| Static 64-leaf initializer | 39.909 | 1.126 | 63 | 110,318 |
| Dynamic copy plus empty leaves in a 64-leaf initializer | 65.619 | 4.046 | 63 | 111,901 |
| Guarded 64-leaf assignment | 56.726 | 1.234 | 64 | 113,947 |
| Equality between 32- and 33-leaf expressions | 66.871 | 1.135 | 63 | 111,633 |
| Right-grouped 64-leaf dynamic output | 50.956 | 4.172 | 63 | 110,356 |
| Balanced 64-leaf dynamic output | 40.832 | 1.025 | 63 | 109,528 |
| 63 operators distributed across expression positions | 58.253 | 1.129 | 64 | 112,157 |
| 32 dynamic/alias leaves plus 32 static leaves | 78.304 | 1.355 | 63 | 112,209 |

The eight compact probes have 24 combined execution checks, including exact
4096-byte results and the rejected next input length.

### Dense composition and report capacity

The 4096-byte dense specimen has 758 assignments and 63 concatenations. The first
63 assignments append a bound empty String to the input; the remaining assignments
copy it directly, followed by `Reject`. It passed with fresh isolated proof
sessions and a fresh solver cache, using the production 100,000-step options through a separate probe runner,
not the production `silver compile` command:

| Measurement | Result |
| --- | --- |
| GNATprove elapsed time | 3,218.730 seconds (53.6 minutes) |
| Checks | 821 Main + 31 runtime proof records, plus 13 flow checks: 865 total, all proved |
| Sampled process-session aggregate RSS peak | 9,351,200,768 bytes (8.709 GiB) |
| Largest process peak from `wait4` | 8,885,872 KiB (8.474 GiB) |
| Main report | 2,065,005 bytes, 98.467% of the 2 MiB buffer |
| Remaining report capacity | 32,147 bytes (1.533%) |
| Production report policies and full code generation | Passed |
| Executions | No argument, one `abc` argument and two arguments all correctly return Reject/status 1 with no output |

The external two-hour experiment limit was not reached. Memory was sampled every
0.2 seconds; aggregate RSS can count shared pages repeatedly. Other validation
overlapped part of the run, so this is a specimen measurement, not an isolated
benchmark. Exact source, project and runtime bytes remained unchanged. Across
all nine probes, all nine admission checks, 45 native report-policy checks,
nine builds and 27 executions passed.

**Correction, 2026-10-15 (review B1/L2):** this specimen does not justify the
report buffer for the whole admitted language. Its 2,065,005 bytes comprise a
2,060,006-byte deterministic floor and 4,999 bytes of timing-dependent prover
credits. The static-shell single-output construction in
[review-343c2f8](reviews/review-343c2f8.md#31-blocker) measured 2,091,011–2,091,380
bytes, leaving only 5,772–6,141 bytes (0.28–0.29%) of the historical 2 MiB buffer.
Additional prover credits can exceed that margin. The reviewed construction's
format-derived maximum is 2,370,822 bytes; that is not a bound for every admitted
program. The [repair record](review-343c2f8-repairs.md#report-capacity-correction)
tracks the format-based capacity repair. Preserve these measurements as history;
new language or producer/report-format changes require a fresh capacity argument.
No report truncation, relaxed policy or statement-count restriction was introduced
by the original expansion.

A separate 306-source corpus compares native admission, the compiled Lean
`Current.accepts`, and independently calculated expected verdicts. All agree;
all 226 admitted sources pass full GNAT object code generation. Cases cover
16/17 and 63/64/65 leaves, three grouping shapes, all expression positions,
shared budgets, 4096/4097-byte sources, byte overflow, the earlier assignment/
literal repairs and every supported sample. This is scoped regression evidence,
not corpus-wide GNATprove or a substitute for universal composition proofs.
The corpus digest is
`b16bb1d1bb33ecc6a912fb8dbfe6e240d68bc72ff7820be432e02e4204412a72`;
the compiler executable digest is
`e75e5751b9640fd38b7f3a0d9bee6b08ce690964c98c31aad2dcd7de0debdf07`.

## Validation checkpoint

The focused `ComposeExamples` and `PredicateExamples` check passed 74 imported
modules with a fresh audit of 11,437 declarations and only the standard axioms
`propext`, `Classical.choice`, and `Quot.sound`. It took 604.970 seconds overall,
including a 593.055-second build and 4.238-second audit. Existing generic model
proofs rebuilt at the expanded constants. This is partial validation; it does
not establish complete actual-source correspondence.

Independent read-only review found no actionable defect in the native rules,
catalogue, source guards, generic proofs, boundary regressions or sample. The
complete native audit passed **3,172 checks** (572 flow and 2,600 proof), covering
20 units and 313 entities. It took 376.431 seconds with four workers and retained
sessions/cache available, not a cold measurement. The subsequent build passed
and exported catalogue matches the checked-in JSON byte for byte. All 344
captured implementation/proof/test/sample inputs remained unchanged, and the
native evidence validator confirms current input/report/tool identities.
That provenance binds 2,408 inputs and 22 reports. The audit retains 80 classified
tool limitation notes and 14 approved imported entities; none is an unproved
required check. The host exposes 12 CPUs and about 31.4 GiB RAM to this environment.

The complete Lean 4.34.1 build and fresh module/axiom audit passed **252 modules**
and **56,885 declarations**, using only the three standard axioms above. The
incremental build took 1,621.540 seconds, the audit 4.625 seconds, and the full
runner 1,629.419 seconds. Four Lake workers and four threads per Lean process
used a 16,384 MiB per-process threshold. Unaffected artifacts and the completed
focused results were reused; this was not a cold build or independent kernel
replay. The declaration total is an axiom inventory, not a count of declarations
independently rechecked. All 344 captured inputs remained unchanged.
The slowest rebuilt module was `ComposeSourceChecks` at 1,513 seconds;
the two changed source certificates took 90 and 191 seconds.
The complete Lean input digest is
`1e4cf8f871b61216cf134ee29d0a01ec71b35fa35ce9ad034dbdb92979d6a3ef`.

The initial full suite completed 308 tests in 1,406.508 seconds: 307 passed and
one stale expectation failed, with no skips. All 344 captured inputs remained
unchanged throughout. The failure is a copy-test rejection: adding an empty
seventeenth operand to a 4096-byte expression is now legal. The compiler and
model agree on this intended expansion. After both frozen captures finished,
the fixture moved to the admitted set and its rejected sibling now adds `"!"`,
producing 4097 bytes. All eight methods in `test_copy_values.py` then passed in
41.231 seconds, with all 344 inputs stable again. Independent review confirmed
that these siblings isolate byte capacity. This is a full-suite result followed
by a test-only repair and focused recheck, not a second full-suite run against
the final test bytes. No production or proof input changed, so the completed
native and Lean checks remain applicable.

## Evidence and recovery

`tmp/larger-expressions-active.json` identifies this milestone's isolated record
and prior evidence copies. Preserve canonical and isolated caches and all earlier
experiments. The [step-budget adoption](expression-headroom.md#production-adoption)
supplies the current-runtime flat-expression controls. Local evidence is retained
under `.silver/linux-x86_64/`:

- `larger-expressions-20261015T120629Z/`: focused Lean results, the differential
  corpus/results, and `checkpoint/` logs, input snapshots and native reports.
- `larger-expressions-20261015T120644Z/`: seven compact cases, the dense case,
  isolated proof sessions/caches, policy harness and execution results.
- `larger-expressions-20261015T121348Z/`: the mixed static/dynamic 64-leaf case.

The final Lean digest and native provenance match the implementation, and all
seventeen tracked source certificates match the regenerated, checked workspace
copies byte for byte. Only `tests/test_copy_values.py` changed after the complete
checkpoint; its focused recheck is recorded above. Documentation updates do not
invalidate those proof inputs. macOS proof
work, hosted CI and independent kernel replay remain outside this milestone.
