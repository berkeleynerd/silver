# Native I/O proof bookkeeping

The owner authorized this bounded optimization on 2026-10-10, after the
[architecture review](architecture-review.md) identified large executed
proof-only buffer copies. The baseline is `8d5f626`. This work changes no language
rule, runtime library, compiler option or Lean theorem. Linux validation and
before/after measurements passed. The representative compile/prove/link workload
took 12.9% less elapsed time; a maximum-size source check fell from 28.569 ms to
1.873 ms. These measurements do not establish a solver or Lean speedup.

## Change and assurance

`Silver_Platform` keeps read/write transcripts, EOF and close observations, and
command text/status to connect actual libc calls to proved contracts. These
observations now use the existing `Ghost => Static` convention. Their dependent
contracts and loop invariants remain proof obligations but are erased from
executable code. The driver's eight historical proof/build flags use the same
convention. The only implementation files changed are `silver_platform.ads`,
`silver_platform.adb` and `silver.adb`; their executable statement sequence is
unchanged.

Mixed contracts are split by purpose. Real input bounds, valid paths/commands,
read-result bounds, `Same_Source` byte equality, report acceptance and publication
guards retain Runtime assertions. Observation-only facts move to Static.
`Observed_Get` and `Observed_Put` remain executable procedures. The actual libc
calls, return-status tests, EOF/close handling, source and selected-library
rereads, byte comparisons, admission and proof-report checks are preserved.
Global `-gnata` and `-gnato` remain enabled.

GNATprove must still discharge every required obligation, including the erased
contracts. Existing trust in GNAT's Static ghost erasure remains explicit in
the [trusted boundary](trusted-boundary.md). No new imported assumption or
suppression is introduced. None of the changed files is one of Lean's ten
embedded certificate inputs, so these edits need no source-certificate rebuild.
The broader evidence inventory still records the changed native sources.

## Measurements

Sequential alternating before/after pairs used the preserved baseline compiler
and rebuilt compiler on the same Linux x86-64 host, with 12 visible CPUs and
approximately 31 GiB RAM. Heavy validation was held until timing completed.

| Workload | Pairs | Before median | After median | Timing scope |
| --- | ---: | ---: | ---: | --- |
| Small assignment `silver check` | 5 | 3.709 ms | 1.333 ms | Whole process |
| Admitted 4096-byte source check | 5 | 28.569 ms | 1.873 ms | Whole process |
| Rejected 4097-byte source check | 5 | 31.137 ms | 1.430 ms | Whole process |
| Platform read, 32 KiB | 5 | 172.359 ms | 0.224 ms | Call inside harness |
| Platform write, 32 KiB | 5 | 878.865 ms | 0.617 ms | Call inside harness |
| Assignment compile, proof and link | 3 | 6.676 s | 5.817 s | Whole process |

The direct platform harness calls the real procedures with production compiler
switches; byte comparisons occur outside its timed call. Its internal timings
exclude process startup. All 56 measured commands passed their status/byte
controls. All six compiled application binaries were byte-identical and printed
exactly `World` plus LF with status 0. Each compile used a fresh application
workspace; filesystem and toolchain caches were warm. These are small samples
on one VM, with ordinary scheduling/startup noise, not general runtime bounds.
Compile ranges were 6.408–6.718 s before and 5.782–5.970 s after.

Disassembly of the measured binaries confirms that per-byte `memcpy` calls of
262145 bytes in `Observed_Get` and 262144 bytes in `Observed_Put` disappeared.
The real `fgetc`/`fputc` calls and executable safety checks remain. The smaller
compile improvement reflects the remaining prover, compiler and library work.

## Validation and retained evidence

Evidence is retained under
`.silver/linux-x86_64/native-io-static-2026-10-10/`. The `before/` snapshot preserves
the baseline source, compiler binary and objects, native proof reports/sessions,
and preceding Lean evidence. Live tools, native/foreign artifacts and caches
remain in place. The detailed ignored records are not recoverable from a clone.

| Check | Result and scope |
| --- | --- |
| Native rebuild | Passed once; `build-result.json` records the retained build output and identities. Its reconstructed log is labeled; elapsed build time is unknown. |
| `python3 scripts/dev.py prove --full` | Passed in 249.798 s: all 2910 checks (407 flow and 2503 proof), 16 units, 213 entities, 40 limitation notes and 14 imported entities. Existing sessions/cache were present; this is a full audit, not a cold run. |
| Focused native regressions | All 20 tests passed in 158.994 s including runner overhead; command and input hashes are in `focused-tests.json`. |
| `python3 scripts/check_lean.py --memory-mb 12288` | Cached build and fresh axiom audit passed in 18.812 s: 75 modules, 21,443 declarations, standard axioms only. All 150 compiled `.olean`/`.ilean` objects retain their bytes and timestamps. No fresh kernel replay was repeated. |
| Final corroboration | Current source/generated-input and compiler identities match the measurements; complete native provenance and report coverage pass. Lean input, workspace, tool and log hashes match. |

The independent source review found no omitted contract term, executable gate
or altered I/O call order. Focused tests cover source/library identity and
tool/report failures, all seven supported samples, output failures and a false
Static contract rejected by genuine GNATprove. Their exact selection is:

```sh
python3 scripts/dev.py test -- \
  -k test_silver -k test_output_integrity -k test_samples -k test_static_proof \
  -k test_output_failure_cannot_report_success
```

`benchmarks/measurement.md`, `summary.json`, `samples.json`, `manifest.json`,
`tools.json` and the disassembly records preserve the method, raw timings,
controls, tool identities and object inspection. `native-audit.json`,
`focused-tests.json` and `lean-incremental.json` bind commands/results to stable
inputs and their adjacent logs. `native-corroboration.json` binds final coverage
and measurement identities; `after/native-reports/` preserves the completed
reports/manifests without duplicating the live solver cache.
`lean-corroboration.json` and copied `lean-evidence.json`/`lean-proof.log` retain
the current cached result. The preceding full kernel replay remains preserved
with its original input scope; no Lean proof or embedded source changed here.

Validation commands overlapped after measurement and their elapsed times are
not performance comparisons. The historical warm-state GNATprove `DOC_END`
failure remains unresolved; this successful audit does not establish a repair.
macOS proof work is a non-goal. Source/dependency partitioning and certificate
redesign were deferred at this checkpoint; no additional language expansion was
started. The later [source/dependency partition](lean-compartmentalization.md)
is complete; the certificate representation remains unchanged.
