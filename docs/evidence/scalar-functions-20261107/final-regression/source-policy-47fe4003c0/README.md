# Source policy regressions after proof packaging

Managed run `20261108T072619-eca79cdaf440` passed four unchanged source-policy
methods against the final recursive proof inventory and import graph at
`47fe4003c0`. These methods are affected by the 80 new source components and
facade; their earlier full-suite results alone did not exercise that final graph.

- `test_include_str_is_confined_to_the_source_bindings`
- `test_only_audit_roots_use_legacy_full_imports`
- `test_compose_candidate_has_no_authoritative_source_dependencies`
- `test_compose_source_checks_retain_authoritative_dependencies`

Unittest reported four passes in 10.988 seconds, with zero skips. The owning
tool exited 0 and the managed run recorded success after 30.901 seconds. These
are source-policy tests, not Lean proof execution or complete project assurance.

The normal `dev.py test` entrypoint first refused its broad writable-workspace
lease because the productive Lean closure owned the proof workspace. No test
started. A narrower managed tool attempt in the integration checkout then
failed setup in 0.110 seconds (`072303-5e0f2237aed4`): that Lean-only checkout
has no configured native tool context. Again, no test started.

The successful invocation used the original regression checkout's already
configured managed tool context, reserving one worker. It declared the exact
integration proof directory, helpers, test file and launcher as inputs and
only its separate scratch root as an additional writable workspace. The short
retained launcher selects exactly the four existing unittest methods with
normal source-root imports and Python `-B`; it changes no assertion or test
method. These methods only read source files. No proof workspace, tool lock,
native installation or active input was modified, and no bootstrap or proof
build was needed. The active native/source validations continued separately.

The [index](index.json) retains both managed outcomes, the successful test log,
the exact launcher and its scope note. Every compressed artifact was
independently decompressed and verified by size and SHA-256. The source inputs
remain the current reviewed proof/source/script bytes; the separate test-only
watchdog repair does not alter these methods. Runtime model/effort telemetry
and token/cost measurements are unavailable.
