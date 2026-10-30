# Final Boolean focused regression record

Issue #291, native Linux, 2026-10-30. Managed run
`20261030T131722-0b2bed7eeddd` executed 15 tests in 194.188 s. Fourteen passed:
the other Boolean regressions, exact native catalogue JSON parity, and the
combined counted/singleton-foreach stack observations. One test failed:
`test_native_boolean_hiding_and_loop_scope_restoration`.

The failure was a fixture error. After declaring `True : Boolean := False` and
`False : Boolean := not True`, the original `Put : Boolean := True` initializes
`Put` to false, and `Put_Line : Boolean := False` initializes `Put_Line` to true.
The loop then makes the original expected output wrong. The implementation's
`bad` output was consistent with those bindings. Integration commit `ca966cef9a`
corrected the initializers to `Put := not True` and `Put_Line := True`.

Only that corrected method was rerun. Managed run
`20261030T132822-0ad9b4ccb9c0` passed its one test in 27.952 s, on unchanged final
native source and binary. The fourteen successful identities from the initial
run were retained rather than repeated. The final full suite independently
includes all 568 standard test identities at integration snapshot `927cc5e178`.

An attempt between these runs failed before creating a managed run with
`Errno 24: Too many open files` opening an old registry lease; no test ran.
Follow-up inspection found soft and hard descriptor limits of 1,048,576 and an
isolated successful status query with four descriptors. This unexplained
orchestration failure was transient; no descriptor limits or runner code were
changed before the successful retry.

The temporary wrapper restricted the unittest child to CPUs `[0,1]`; the managed
parent retained normal host affinity and reserved two workers. Production
producer/prover settings were unchanged. Initial and corrected fixture/wrapper
bytes and terminal event/log records are retained here. The initial input-copy
manifest records the copied focused inputs. All 57 copied inputs were restored
and owned temporary harnesses/assets removed before creating the final suite
snapshot. The final source was kept in place for that separate validation.

Selected native subthread: GPT-6 Astra / Extra High; live runtime model
confirmation and token/cost measurements are unavailable. These focused results
and stack observations do not establish complete compiler assurance.
