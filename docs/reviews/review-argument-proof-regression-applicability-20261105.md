# Applicability of the interpreted_argument heartbeat repair

## Decision and limits

**The exact theorem-local heartbeat edit reviewed here requires no additional
unittest reruns by itself.** Successful results from the frozen regression run
can remain applicable, subject to the completed-run census and failure repair
required by `development.md:242–253`. This is a static applicability decision,
not a statement that the full suite or the proof checkpoint passed.

The changed production theorem is elaborated by the real Lean checkpoint.
No unittest elaborates that theorem. The tests that read its source either
observe unchanged source markers or transport/hash the bytes without interpreting
the theorem. Those dependencies are accounted for below; they were not excluded
merely because the edit is in a proof file.

Every failed test still requires a successful repair rerun. An interrupted,
missing, skipped-required, or otherwise uncovered test is not covered by this
review. The lead must reconcile the completed full-suite inventory and outcomes
before claiming the regression requirement is met. If that reconciliation or
applicability fails, use the full rerun required by development policy.

A **successful complete Lean/source-correspondence checkpoint using the final
file is required**. A focused theorem experiment is not that checkpoint.
Successful complete native proof/audit evidence remains mandatory too; this
Lean-only edit does not change native proof inputs, but this review does not
replace their provenance/evidence audit.

## Reviewed inputs and status

- Selected reviewer: GPT-6 Astra / Extra High. Runtime model/effort confirmation,
  token use and cost were not exposed to this reviewer.
- Inspection started 2026-11-05 11:14:24 UTC; report finalized 2026-11-05 11:23:05 UTC.
  Elapsed review/report time: 8 minutes 41 seconds; no token/cost measurement available.
- Regression worktree: `tmp/string-admission-repairs`, frozen commit
  `fb89b3653accef6c08a49f88625144c108ad2432`.
- Regression run supplied by the lead: `20261105T111005-483650d69229`.
  Its completion, exit status and actual result census were pending and were not
  inspected as part of this assignment.
- Integration worktree: `tmp/string-review-repairs`, the same HEAD plus the
  exact source delta below. Concurrent documentation/evidence edits were present;
  this review did not modify them.
- No tests, builds or proof experiments were run by the reviewer. Inspection
  used source reads, Git diff, AST parsing, byte comparisons and import-closure
  extraction; no test module was imported or executed.

The final candidate adds exactly one line immediately before the existing
`backward.dsimp.instances` option and `interpreted_argument` declaration in
`proof/Silver/ComposeEquations.lean:34`:

```lean
set_option maxHeartbeats 3000000 in
```

The statement, tactic body, definitions, imports, module boundary, filenames,
Lake configuration and toolchain are unchanged. The option is scoped to that
declaration; the module/default 2M budget is unchanged. The earlier six-line
section plus local `irreducible` experiment was removed. The lead reported that
it also timed out at 2M. The current 3M experiment was pending when its scope was
supplied; **this review makes no claim about its success**.

SHA-256 of the changed file:

| Input | SHA-256 |
| --- | --- |
| Frozen regression file | `f2462b54b0e03b063d3e32f4ec70119b8110f000b07982c8822d3599d5fffdf1` |
| Reviewed final candidate | `1c68e535f029804fb1c616ed2819607abd895fb95b48b3ba8a73c5135200ff9f` |

Byte comparisons between both worktrees found only that file different in the
proof tree, excluding generated `.lake` and Python cache directories.
All files in `tests/`, `src/`, `scripts/`, `samples/` and `catalogue/`
were identical, excluding Python cache files. The compared Rosetta inputs
(`refresh.py`, `manifest.json`, `coverage.json`), `silver.gpr`,
`alire.toml`, proof generator, Lake file and Lean toolchain file were identical.
Native binaries/tool installations and retained run artifacts were not
independently revalidated here; the lead must use their existing provenance.

## Tests that read the changed production file

### Whole-tree source-policy scans

Two methods in `test_lean_source.CompilerSourcePolicyTests` read
`ComposeEquations.lean` directly:

| Method | Actual observation | Applicability |
| --- | --- | --- |
| `test_include_str_is_confined_to_the_source_bindings` (:108) | Counts `\binclude_str\s*"` matches in each production Lean source | Zero matches in both versions; unchanged |
| `test_only_audit_roots_use_legacy_full_imports` (:128) | Detects the line-level `module` marker | Marker unchanged |

Their complete results remain applicable: the file set and every other source
are identical, and the changed file has the same observed projection. This is
not a claim that its bytes are unchanged.

The two import-closure methods were also traced rather than assumed independent:

- `test_compose_candidate_has_no_authoritative_source_dependencies` (:157)
  traverses 85 production modules from `Silver.ComposeSourceCandidate`.
- `test_compose_source_checks_retain_authoritative_dependencies` (:168)
  traverses 115 from `Silver.ComposeSourceChecks` and 39 from
  `Silver.OutputSourceBridge`.

**None of those closures contains `Silver.ComposeEquations`.** In addition,
the edited file's parsed imports are unchanged. The other source-policy methods
read unchanged Ada bytes, source binding modules, certificates, Lake configuration,
generator metadata or synthetic inputs.

### Shared platform fixture and its transitive wrapper

`test_platforms.PlatformIsolationTests.setUp` (:336–352) copies every production
Lean file, including the changed one, into a temporary installation.
Consequently **all 12 methods have a shared-fixture byte dependency**:

- `test_platform_aliases_and_disjoint_paths`
- `test_foreign_execution_is_rejected_before_side_effects`
- `test_each_host_setup_preserves_other_hosts_and_shared_inputs`
- `test_concurrent_different_host_setups_do_not_collide`
- `test_failed_proof_invalidates_only_its_host_evidence`
- `test_lean_full_and_clean_modes_record_their_actual_checks`
- `test_cached_build_log_cannot_replace_fresh_lean_audit`
- `test_lean_auto_and_explicit_resources_are_recorded_and_isolated`
- `test_legacy_archives_are_read_only_inputs`
- `test_development_commands_keep_project_outputs_and_audit_in_native_host`
- `test_development_output_overrides_fail_before_invoking_tools`
- `test_unchanged_context_setup_preserves_generated_file_mtimes`

The seven setup-worker methods (each-host setup, concurrent setup, failed proof,
full/clean modes, cached audit rejection, resource recording, legacy archives)
execute the real Python runner against that copied tree.
`setup_worker` (:58–333) mocks Lean and Lake; their mocked module/audit output
comes from **source filenames**, via `check_lean.project_sources`, not theorem
elaboration. The real certificate generator runs only on unchanged Ada inputs.
The runner copies and hashes the proof text, and applies
`check_proof_policy` (:71–85), which rejects
`skipKernelTC|addDeclWithoutChecking|addDeclCore`. Neither file version contains
these strings. Module names, copy destinations, tool arguments and branch choices
are unchanged. Expected fingerprints are derived from the same current fixture;
no expected literal digest for this theorem is embedded.

The remaining five methods use the copied tree as unrelated fixture data and/or
a before/after filesystem snapshot while checking paths, native command routing,
rejection before side effects, or unchanged context generation. Snapshot
comparisons use the current fixture on both sides, not the earlier proof bytes.

Thus the changed payload changes concrete source hashes but not the checked
relationships. The added short ASCII option line does not change path type,
encoding, module inventory or policy classification. Successful results of these
12 methods remain applicable to this candidate.

`InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`
(:626) runs the **whole PlatformIsolationTests class** in a subprocess under a
symlinked temporary directory. It inherits exactly the dependency above; it does
not compile the production theorem. Its successful result also remains applicable.
The other InstallationEnvironment methods use unchanged runtime/configuration
inputs.

## Lean-labelled tests that do not consume this theorem

- `test_lean_source.NativeCertificateTests.test_generated_certificates_and_witnesses_remain_kernel_checked`
  compiles the actual Lexical, Admission, Cursor, SourceLexer,
  CertificateWitness and AxiomAudit modules, followed by synthetic certificates
  and audit drivers. It does not compile ComposeEquations.
- `test_lean_evidence` workspace and runner-phase fixtures create synthetic
  AuthoritativeSource/SourceBridge or Shared/Model/Audit modules.
  `test_lean_run_history` reuses that synthetic fixture.
- The kernel-policy method reading production code reads only AxiomAudit.
  Actual native axiom-audit tests copy AxiomAudit and create synthetic modules.
- Native dependency/cache/resource tests use synthetic modules, unchanged
  lakefile/toolchain inputs, or the actual unchanged source binding modules
  selected by the generator. They do not import ComposeEquations.
- `test_lean_modules` uses synthetic Provider/Consumer modules. Its legacy audit
  test copies Audit and AxiomAudit while supplying a synthetic Silver root and
  candidate stub; it does not import the production proof graph.

The heartbeat option in the production file cannot affect these independent
Lean invocations. Their passed outcomes are reusable under unchanged settings.

## Native, sample and remaining fixtures

The shared `test_silver.invoke` calls the native Silver executable. It does not
invoke Lean or read Lean evidence. Sample admission/proof/build tests use that
helper, unchanged samples/catalogue and native GNATprove report checks.
Rosetta tests use unchanged rendering code, manifest and coverage data.
The other native/functional/proof-report tests use unchanged source, probes,
configuration or synthetic report data.

`scripts/proof_provenance.input_hashes` (:59–75) selects native Ada,
project/configuration, generated Ada, toolchain settings and Python script inputs;
it does not hash Lean source files. Dev-run/provenance unit fixtures use synthetic
native inputs and the actual unchanged project files. No native proof or compiler
rerun is newly required solely by this Lean edit.

There is a separate **run-record identity change**:
`scripts/dev.py:479–490` hashes the proof directory for a managed full test run.
Accordingly the frozen test run's aggregate fingerprint cannot be relabelled as
the final fingerprint. Record reused per-test successes against their original
run, and cite this applicability review for the source delta.

Similarly, `check_lean.capture_shared_inputs`,
`capture_workspace_inputs` and `prepare_workspace` include the actual changed
source bytes. Real Lean evidence from the preceding file is not evidence for the
new elaboration. Final complete Lean/source/module/axiom validation must include
the edited file and retain its actual input identity.

## Static inventory for the later census

AST inspection found 53 test files and 581 locally defined test methods.
`NativeArrayReportTests` inherits two additional methods and
`ArrayEvidenceTests` inherits three. `test_integer_loops` imports
`SharedBindingsTests` into its module namespace, adding nine discoverable
instances. Ordinary unittest discovery therefore predicts **595 top-level test
executions**, before subtests and the nested platform-wrapper suite.
This is a static expectation, not a substitute for the completed runner log.

All locally defined methods are covered by the dependency classification above:

| Module | Local methods | Module | Local methods |
| --- | ---: | --- | ---: |
| test_argument_bounds | 1 | test_arguments | 3 |
| test_boolean_objects | 13 | test_branching | 7 |
| test_capacity | 3 | test_command_line_greeting | 3 |
| test_common_expressions | 15 | test_composed_results | 8 |
| test_conditionals | 5 | test_constant_array_iteration | 10 |
| test_copy_values | 8 | test_counted_bound_review | 4 |
| test_dev_runs | 26 | test_empty_loop_folds | 3 |
| test_evidence | 60 | test_greeting | 4 |
| test_image_adapter | 4 | test_image_model | 3 |
| test_image_reports | 6 | test_image_setup | 8 |
| test_integer_arrays | 12 | test_integer_division | 11 |
| test_integer_image | 9 | test_integer_loops | 12 |
| test_lean_evidence | 49 | test_lean_modules | 2 |
| test_lean_run_history | 10 | test_lean_source | 12 |
| test_library_reports | 36 | test_main_discovery | 2 |
| test_mutable_integers | 12 | test_named_integer_subtypes | 10 |
| test_named_output | 4 | test_names_calls | 9 |
| test_output | 4 | test_output_integrity | 17 |
| test_partial_output | 4 | test_path_refinement | 15 |
| test_platforms | 16 | test_predicates | 8 |
| test_proof_provenance | 27 | test_report_projection | 8 |
| test_rosetta | 3 | test_run_history | 19 |
| test_samples | 2 | test_scalar_guards | 23 |
| test_shared_bindings | 9 | test_silver | 9 |
| test_statement_sequencing | 9 | test_static_proof | 1 |
| test_string_assignment | 5 | test_string_characters | 11 |
| test_string_review_blockers | 7 | | |

The census must preserve per-method and subtest failures rather than infer success
from a count. In particular, a failure within the platform wrapper is not cleared
by an unrelated successful direct platform invocation.

## Minimum remaining work and scope boundary

1. Finish the frozen full regression run and reconcile its actual full inventory,
   outcomes and required coverage. Retain it unchanged as evidence, including any
   failures. Rerun every failure and any subsequently affected test.
2. No extra unittest run is required **solely for the one-line theorem-local
   heartbeat option reviewed here**. The two whole-tree scans and shared platform
   fixture are explicitly included in this reuse decision.
3. Finish the focused experiment as needed for diagnosis, then obtain the required
   complete successful Lean checkpoint on the final source. Verify the final file
   and other inputs match this review or update the review for any further delta.
4. Audit the independent complete native proof evidence using its actual
   provenance; do not treat this review or the regression suite as its substitute.

A further numeric heartbeat adjustment scoped to this same declaration would have
the same unittest dependency classification, but its final value/hash and actual
Lean success must be recorded. Changes to tactics, statements, definitions,
imports, source bindings, module inventory, global options, lakefile/toolchain,
runner limits, test fixtures or native inputs are outside this exact review and
require reassessment; no blanket reuse approval is given for them.

