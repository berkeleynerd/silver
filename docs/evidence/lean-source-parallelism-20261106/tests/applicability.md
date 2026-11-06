# Test and native-evidence applicability at 3f5d575635

Read-only inspection confirms **87 distinct selected test methods**: 70 tooling
methods, 16 mocked-platform methods and one real Lean module fixture. The
12-method managed source-policy rerun repeats part of the 70. Subtests and child
fixture repetitions add no distinct method count. The failed tiny-fixture
predecessor and the workspace-lease refusal add no successful tests.

Static Python AST enumeration at `3f5d575635` reproduces this inventory without
executing tests:

| Test file | Selected class or method | Methods |
| --- | --- | ---: |
| `test_lean_source.py` | `CompilerSourcePolicyTests` | 12 |
| `test_lean_evidence.py` | `LeanEvidenceTests` | 15 |
| `test_lean_evidence.py` | `LeanCPUSelectionTests` | 4 |
| `test_lean_evidence.py` | `LeanKernelPolicyTests` | 2 |
| `test_lean_evidence.py` | `LeanRunnerPhaseTests` | 24 |
| `test_lean_evidence.py` | `LeanStreamingTests` | 2 |
| `test_lean_evidence.py` | `LeanTemporaryDirectoryTests` | 1 |
| `test_lean_run_history.py` | `LeanRunHistoryTests` | 8 |
| `test_lean_run_history.py` | `LeanLeaseChildTests` | 2 |
| `test_platforms.py` | `PlatformIsolationTests` | 12 |
| `test_platforms.py` | `InstallationEnvironmentTests` | 4 |
| `test_lean_modules.py` | `test_output_body_chunks_regenerate_and_track_token_and_newline_changes` | 1 |
| **Total** | | **87** |

The [test summary](summary.json) binds commands, timings and retained logs. The
70/16 direct invocations have no contemporaneous complete managed input manifest;
their reuse is supported by the source comparison below. The real fixture and
12-method rerun have retained successful managed ledgers. Platform proof tools
are mocked. The real fixture uses a tiny source, one reserved worker and explicit
`-j1/-M2048`; it establishes actual generation, binary-source invalidation,
unchanged-object reuse and fresh selected-import auditing for that fixture.

From `a179b4593d` to integration `3f5d575635`, exactly five Predicate Lean files
change: the facade and its four new leaves. All test files, `scripts/`, the
certificate generator, Lake configuration/toolchain pin, source lexer,
certificate witness and audit roots remain byte-identical. The mocked runner
tests construct their own small projects. Platform fixtures enumerate proof
modules dynamically; their routing and generation assertions introduce no
predicate-specific behavior. The tiny fixture copies only unchanged helper,
binding, generator and build inputs. These results therefore remain applicable
to their scoped behaviors on the integrated source.

The policy/parity tests inspect actual proof files and import closures, so their
12-method rerun is the direct final-input refresh: managed run
`20261106T112137-dccd83f67d55` passed at `4f7de6594b`. Its `src`, `scripts`,
`proof` and `tests` trees are byte-equal to `3f5d575635`. It covers all 32 generated
artifacts, exact ordered line/reconstruction preservation, source bindings and
ordinary-module/source-dependency policy. It does not execute Lean proofs.

The [native packet](../native/README.md) retains complete run
`20261106T104927-7539b94e8f7c`: 76 units, 1,496 flow checks and 16,000 proof
checks, with fresh coverage/report/provenance auditing. Build
`20261106T105138-972096333176` also passed, compiling six Ada units and linking
`silver`. Both used the original validation installation at `a179b4593d`.
Comparison of immutable Git objects confirms that **all 143 tracked native input
hashes match `3f5d575635`**, including every captured script, native source and
project file. The remaining host-generated/configuration inputs retain their
original installation attribution; all 2,586 hashes stayed stable through those
completed runs. This is complete native proof/audit evidence using retained
sessions/cache.
Further native refresh is required if a captured native input changes.

No additional small Python or native fixture check is indicated by this
comparison. The remaining integration obligation is the actual Lean composition:
finish NativeShape after its retained 12 GiB memory failure, then check the final
output-body reconstruction, Predicate facade/bridges and complete project with
the normal runner's dependency, source-correspondence, module-coverage and fresh
axiom audits. Focused leaf successes and the 87 tooling methods cannot discharge
that obligation. The 24 GiB retry was active when this applicability task was
assigned; this inspection claims no retry outcome.

This inventory is scoped tooling evidence. It adds no fresh full application
suite, macOS or hosted-CI result. No tests, proof runs or governed source edits
were performed during this applicability inspection. Selected worker:
GPT-6.1 Sol / Extra High; runtime confirmation and token/cost measurements are
unavailable.
