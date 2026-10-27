# Fixed-array closing review — regression complete; assurance pending

Date: 2026-10-27. Independent reviewer selected GPT-6 Astra / Extra High
(`gpt-6-astra`, `xhigh`); runtime settings and token/cost measurements are
unavailable. Read-only review for owner-authorized #260 / milestone 10, with
#262 remaining open until complete actual-source validation. Only this scratch
report was written. No native, Lean, build or test runs, subagents, or GitHub
writes were performed.

Target: `899a15a5a0c6318fd094620925cf9538e22f3cfc` in
`tmp/fixed-integer-arrays`; exact delta from
`726465447c11d8826164fdca343d71178dc53fdf`. The checkout was clean on entry.
The first recorded clock sample was 2026-10-27 13:10:23 UTC, after initial
reads; this preliminary report was prepared at 2026-10-27 13:13:31 UTC. These timestamps do
not measure the whole review interval.

## Current conclusion

All 530 tests in the complete inventory for
`899a15a5a0c6318fd094620925cf9538e22f3cfc` have applicable successful results:
73 fresh passes from four repair runs and 457 retained passes from the completed
full run. This satisfies the reviewed test-result reuse provision in
`development.md` for this target. The original full run remains failed, with
three failures and two errors; it is not relabelled as a successful full run.

No consequential finding in the two private proof-script repairs or the test
inventory correction. The existing semantic, native/specification and Compose
caller-domain reviews remain applicable to their unchanged subjects. Complete
native/Lean assurance and final Rosetta/metadata integration remain pending;
this report does not approve capability completion.

## Exact delta and proof review

The seven changed files comprise two Lean proof scripts,
`tests/test_lean_source.py`, the capability record and three prior-review files.
No native implementation, generator, script, project configuration, catalogue,
sample, or test method body changed between the reviewed commits.

- `ComposeModelEquations.lean:model_definition_callAfter` adds `Bool.or_assoc`
  to simplification of the existing equality. It reassociates Boolean
  disjunction without changing statement, hypotheses, definitions or semantics.
- `ComposeModelLegal.lean:model_legal_scalarConstraint` and
  `model_legal_scalarDeclaration` generalize the concrete call table and locals,
  then unfold `scalarConstraintBody` / `scalarDeclarationBody`, `Expr.Legal`
  and `Function.isLexical` directly with `dsimp`. The remaining logical
  simplification is unchanged. Generalization asks for the same legality
  conclusion at arbitrary calls/locals, rather than assuming a stronger native
  caller condition. These are proof terms for unchanged private theorems, with
  no new axiom, admitted program restriction or proof-policy change.
- The source-test constants now include both array-binding Ada files and their
  corresponding certificate modules in the matching positions. The production
  generator, CANDIDATES and authoritative-source lists already included them.
  The correction restores fixture agreement and extends the existing parity,
  source-byte and dependency checks to those files.

Focused managed run `20261027T121859-1ce124c7ffc1` has a successful terminal
record, including repaired Compose equations/legality and a fresh 34,373-
declaration audit with `propext`, `Classical.choice`, `Quot.sound` only.
`20261027T123131-cf131b4f0118` also has a successful terminal record for its
Current / PredicateNativeSourceBridge scope and fresh 23,030-declaration audit.
These focused results do not replace the complete source/module/axiom audit.

## Test-input applicability

The complete supplied inventory contains 530 distinct unittest identities:
`.silver/linux-x86_64/array-proof-stage/final-test-inventory-899a15a5a0.json`,
SHA-256 `11539742a6e231777bb36ca14e4d872ef82f2c2905ee9400bac9788f41591530`.
It includes nine `tests.test_shared_bindings.SharedBindingsTests.*` identities
imported during discovery as well as the nine
`test_shared_bindings.SharedBindingsTests.*` identities. Both sets remain in
coverage accounting; neither is silently deduplicated.

I independently compared every one of the 785 normalized captured inputs for
each repair run against current checkout bytes. Both
`20261027T124103-ca072dcceb1a` (all 12 `test_lean_source` tests; 146.415 s test
phase) and `20261027T124456-035726160aa1` (all 49 `test_lean_evidence` tests;
539.009 s test phase) match with zero differences and have successful terminal
records. These 61 tests require no repeat absent a relevant subsequent change.

The baseline full run `20261027T113223-c732210ca335` uses the immutable sibling
`tmp/fixed-arrays-regression` at `726465447c`. Its 785 captured inputs differ
from the current checkout in exactly six normalized paths: the two Lean files,
`tests/test_lean_source.py`, the compiler executable, and generated
`silver_build.ads` / `silver_image_config.ads`. Direct comparison of both
configuration files shows only worktree-prefix rebinding; the platform,
options and bound vendor GNATwhy3 SHA-256 are unchanged. The lead identifies
`20261027T113126` as the regression snapshot's successful native build. Native
results are retained results for that built source snapshot, not fresh compiler
execution from the 61 repair tests.

The dependency review covered the test imports and relevant fixture readers:

- The corrected EMBEDDED/CERTIFICATE_MODULES constants directly affect the
  12 source tests. `test_lean_evidence` imports EMBEDDED and uses it in its
  native embedded-source dependency fixtures; its complete 49-test rerun
  covers those effects and the known dependency failure.
- `test_lean_run_history` imports `test_lean_evidence`, but the reused
  `LeanRunnerPhaseTests.fixture` consumes unchanged CANDIDATES and synthetic
  source files, not EMBEDDED. Its ten test methods therefore retain their
  existing successful results, confirmed in the completed full-run log.
- `test_platforms.PlatformIsolationTests.setUp` copies all Lean files, and the
  worker captures/hashes them. Its Lean build/audit/kernel commands are mocked;
  generated certificate commands use unchanged native sources and generator.
  Assertions concern routing, host isolation, module-name inventory, preservation
  against the same run's own byte capture, resource selection, and fresh-audit
  markers. The two proof-body edits change no module path, import, policy marker,
  generator input or asserted fixed digest. The revised bodies contain no
  forbidden proof-policy token. All 16 platform methods, including the nested
  symlinked-TMPDIR suite, retain successful baseline results for these changes.
- The two native Lean-module tests use synthetic Provider/Consumer modules and
  the unchanged real Audit/AxiomAudit roots and toolchain pin. They do not use
  the changed Compose proof bodies. The other test families depend on unchanged
  native/library code, scripts, configuration policy, catalogue, samples and
  shared harnesses. Their source/test/tool applicability is preserved; each
  individual retained result is present and successful in the completed log.
- The proposed Rosetta commit `87cb365cc1746f3f9dec0f45f185b31cbedf3d14` is not
  integrated at this target. Its coverage/renderer data affect `test_rosetta`;
  run the three existing Rosetta tests after final integration. It adds no
  sample or catalogue dependency. Reassess if the final metadata delta differs.

## Completed regression census and repair evidence

I independently read the primary managed logs/events and reconciled all test
headers and statuses with the 530-identity inventory. Header extraction included
multiline Rosetta docstrings; status extraction also handled interleaved native
output followed by standalone `ok`. The completed baseline has exactly 530
unique expected identities, no missing or extra identity, 525 `ok`, three `FAIL`
and two `ERROR`. The nine imported SharedBindings identities are included.
The existing `array-delivery-evidence/test-inventory-comparison.json` agrees with
this independent census; it was supporting input rather than the source of the
coverage arithmetic.

`20261027T113223-c732210ca335` ended with managed outcome `failure`, return
code 1: 530 tests in 6818.245 s, 6820.772 s managed duration. The exact failure
tracebacks in the retained log and
`../fixed-arrays-regression/.silver/linux-x86_64/full-regression-failures.txt`
show:

- Two source-list assertions expected 32 files while the authoritative inventory
  contained 34. The embedded-source dependency fixture lacked
  `silver_array_bindings.ads` and `.adb`. These are the three inventory failures
  repaired by the already-reviewed fixture correction and covered by the 61
  successful source/evidence rerun tests.
- `test_integer_division.IntegerDivisionTests.test_native_dynamic_signs_and_minimum_integer`
  raised `subprocess.TimeoutExpired` at the unchanged shared `invoke` deadline
  of 120 seconds while compiling its application.
- `test_samples.SupportedSampleTests.test_maximum_dynamic_expression` raised
  `subprocess.TimeoutExpired` at its unchanged 300-second compilation deadline.
  This is distinct from `test_manifest_samples`, which passed in the full run.
  Neither traceback establishes a failed proof obligation or a prover timeout.

| Successful repair run | Covered identities | Test duration |
| --- | --- | --- |
| `20261027T124103-ca072dcceb1a` | All 12 `test_lean_source` tests | 146.415 s |
| `20261027T124456-035726160aa1` | All 49 `test_lean_evidence` tests | 539.009 s |
| `20261027T132720-978e7f5308f1` | All 11 `test_integer_division` tests | 82.317 s |
| `20261027T132919-e15867ceed8c` | `test_samples.SupportedSampleTests.test_maximum_dynamic_expression` | 138.741 s |

Each repair run has a successful terminal managed record and all selected tests
reported `ok`, with no skips. The last two managed durations were 84.795 s and
141.495 s respectively. Their complete 785-entry captured input maps are each
identical to the full run's map, including the regression compiler executable,
both generated configuration files and test/shared-harness bytes. Against the
current target they have exactly the same six reviewed differences as the full
run. The unchanged native/test/script dependencies therefore preserve their
applicability at `899a15a5a0`; the altered Compose proof bodies and source-test
inventory are not inputs to these application tests.

Both timeout repair runs used five managed workers; the original full run used
three. The lead reports that the original process had three-CPU affinity from
11:37:02 UTC and the repair parent affinity was unrestricted. That affinity
history is lead-reported, not independently reconstructed here. Test deadlines
and production prover flags were unchanged: the reruns used the identical test,
harness, compiler and native-source inputs. The maximum-expression test also
checks the actual application proof policy and complete reports before executing
both output cases. Existing warm caches may contribute to elapsed time; these
results do not attribute the timing difference solely to CPU allocation or
establish a cold-run bound.

The four successful rerun identity sets are disjoint and total 73 (12 + 49 + 11
+ 1). Every one of the baseline's five failed identities is in that set. Removing
those 73 identities from the baseline leaves exactly 457 identities, all `ok`.
Their union equals the final 530-identity inventory, with no overlap, missing
test, failing test or uncovered affected fixture. The retained 457 include all
16 platform tests, ten Lean-run-history tests and the three Rosetta tests under
the unchanged current metadata.

After the proposed Rosetta metadata changes, those three Rosetta tests will need
successful applicable reruns. If no other relevant input changes, the expected
final partition would then be 76 fresh and 454 retained. That future partition
is not yet claimed as completed coverage for an unreviewed delivery target.

## Remaining closing checks

1. Inspect the integrated Rosetta/final metadata delta and the three applicable
   Rosetta rerun results; reassess dependencies if other inputs change.
2. Inspect successful complete native proof/audit, native build, and complete
   Lean/source-correspondence/module/axiom evidence for the actual delivery
   source and settings. Focused successes and test-result composition cannot
   satisfy these complete-checkpoint obligations. The lead reports native run
   `f971342569f8` and Compose/certificate work remain unfinished; no success is
   inferred from those active or suspended checks.
3. Update this report with the exact final target and complete evidence outcomes.
   #262 can be closed only with its complete actual-source checkpoint; #260
   completion additionally needs the whole feature delivery checkpoint.

Inputs read: AGENTS.md; the Oracle (especially requirements 11, 12 and 27);
`development.md` reviewed test-result reuse clause; `docs/fixed-integer-arrays.md`;
semantic integration review at `726465447c`, native/specification review and
Compose domain review including #262 follow-up; the exact seven-file delta;
the complete inventory; test imports and fixtures described above; managed
logs and events for the seven runs named above, the final failure tracebacks,
and the existing inventory comparison. This closing review deliberately
does not repeat the already completed broad semantic review.

Regression follow-up: selected GPT-6 Astra / Extra High, runtime settings and
token/cost measurements unavailable. First follow-up clock sample was
2026-10-27 13:33:35 UTC after initial reads; report updated at 2026-10-27 13:34:59 UTC. The follow-up changed only this scratch report and
performed no test, build, proof or repository-write operation.
