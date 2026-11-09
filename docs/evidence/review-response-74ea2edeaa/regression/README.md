# Review-response regression workspace — 2026-11-09

Status: the complete unfiltered Linux regression suite passed: **648 unittest
executions covering 634 distinct method definitions**, with no failures, errors
or skips. The actual driver and test phase both exited 0. No native compiler
proof was run in this separate test workspace; canonical compiler assurance
belongs to the integration workspace.

Managed run `20261109T144553-8abe96c6e3ad` ran from 14:45:53 to 16:00:52 UTC on
2026-11-09. Unittest reported `Ran 648 tests in 4495.139s` / `OK`; the managed
run took 4,498.508 seconds. It reserved 21 of the host's 22 workers while the
canonical complete Lean checkpoint reserved one worker. Full discovery used
the unchanged default deadlines and options, with no filters, exclusions,
retries, input edits or repair reruns. The [actual result](full-suite-result.json),
[runner events](full-suite-events.jsonl.gz), [native log](full-suite-native.log.gz)
and [driver log](full-suite-driver.log.gz) retain the commands and outcome.
The managed `finished.returncode` remains null by runner design; the retained
test `phase-end.returncode` and independently observed driver exit are both 0.

The [test census](test-census.json.gz) maps all 648 execution identities to the
634 distinct definitions without another test run. Five inherited image/array
report methods and nine shared-binding methods loaded under both `test_...`
and `tests.test_...` module names account for the additional 14 executions.
These executions are retained as the suite actually ran.

All nine review-response methods passed; their exact identities and driver-log
line numbers are recorded in the result. Eight belong to
`test_scalar_functions.ScalarFunctionTests`:

- `test_local_hiding_is_independent_of_return_arithmetic`
- `test_native_unused_function_without_main_output`
- `test_native_hiding_and_argument_shell`
- `test_formal_syntax_and_closing_names`
- `test_return_must_be_single_terminal_and_typed`
- `test_actual_arity_kinds_and_positional_association`
- `test_native_ordered_calls_snapshot_and_full_unused_coverage`
- `test_native_boolean_and_integer_self_actuals`

The ninth is
`test_string_review_blockers.StringReviewBlockerTests.test_admission_guarded_nonstatic_slice_endpoints`.
`test_samples.SupportedSampleTests.test_manifest_samples` also passed all 84
manifest samples through admission, native application proof, build, report
audit and expected execution streams/status checks. Samples exercise language
rules; they do not establish universal compiler assurance.

The [final input comparison](final-input-parity.json) confirms that all 12,170
tracked source/proof/script/test/catalogue/sample/Rosetta/reference and project
files still match the retained baseline and integration bytes. All 1,123
prepared managed inputs and both compiler executables also remain unchanged.
The final census and parity checks read retained logs and unchanged inputs;
they did not execute additional tests. Runtime model/effort confirmation and
token/cost measurements were unavailable to this evidence stream.

The checkout is `tmp/review-response-regression`, branch
`validation/review-response-regression-20261109`, initially clean at
`6365003968a3631493e60380d71417fdc42233c3`. Source, proof and test inputs remain
unchanged. The sparse checkout includes all root content, Rosetta pages and
references, excluding historical `docs/evidence` except this regression subtree.
The [setup record](setup-state.json) retains actual host and checkout details:
Linux x86_64, 22 allowed CPUs and 65,928,044 KiB total RAM.

Only the integration worktree's idle `.tools` installation was copied with
`cp -a --reflink=auto`. The [copy record](tool-seed.json.gz) compares its 32,390
entries before bootstrap, including 32,310 regular files; source and copy bytes
match, no regular-file inodes are shared, and tool symlinks remain inside the
independent copied tree. No compiler objects, solver cache or proof workspace
was copied. Native and Lean bootstrap both exited 0 using the existing archives;
their [outcomes](bootstrap-outcomes.json), [native log](bootstrap.log.gz) and
[Lean log](bootstrap_lean.log.gz) retain the actual commands and versions.

Managed build `20261109T142937-cd04c79c8452` used two workers while canonical
validation occupied the integration workspace. It passed in 15.166 seconds;
the native-tool phase and actual driver exited 0. The
[events](build-events.jsonl.gz), [native log](build-native.log.gz),
[driver log](build-driver.log.gz) and [pre-suite readiness record](build-readiness.json)
retain exact inputs, effective command and tool identities. The resulting
`silver` executable SHA-256 is
`eb8bf88fc550d706da7a9baeca8cd641bc2c81f36e8e277747372c58e223d3ba`;
`silver_image_adapter` is
`299ae169e22e36b3ac6cee8cf0e5949d6b27658ea5f066482b53c9ae877eb524`.

The [source comparison](source-input-parity.json.gz) covers all 12,170 tracked
files in `src`, `proof`, `scripts`, `tests`, `catalogue`, `samples`, `rosetta`
and `references`, plus the two root project manifests. Every file matches the
integration input bytes. The generated `silver_build.ads` and
`silver_image_config.ads` differ only in the installation prefix;
`silver_library_sources.ads` is byte-identical. These generated path differences
and the fresh executable identities are recorded separately from source parity.
