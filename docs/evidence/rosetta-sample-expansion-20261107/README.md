# Rosetta sample expansion evidence — 2026-11-07

This packet supports [#300](https://github.com/berkeleynerd/silver/issues/300)
and the [delivery record](../../rosetta-sample-expansion.md). All fresh runs
were on Linux x86_64. The ten added samples and manifest are fixed at
`ff4fdb9c8ba209a291b1274b6fb947894625c815`; the committed harness is
`c5946b2abb591d760631d16176c3f23137a188d9`. Compiler/runtime implementation
remains `ce97ede446aad55520e59854ea8298e2a63d56eb`. This is a sample-only
increment: no language, compiler, runtime, proof, script, test-source or
catalogue change is part of the delivery.

## Fresh native and application validation

| Managed run | Result and scope | Retained evidence |
| --- | --- | --- |
| `20261107T163953-c60342654933` | Failed retained-report audit: the migrated host's Python 3.14.8 differed from the recorded 3.14.4. The gate rejected the old tool identity before a current success claim. | [Log](native-audit-python-change/native.log), [events](native-audit-python-change/events.jsonl) |
| `20261107T164210-abaf005c4a13` | Passed ordinary forced full native analysis/audit with retained sessions/cache: 17,681 checks = 1,513 flow + 16,168 proof, 76 units, 1,112 owned entities. 22 workers, 98.863 seconds. All 2,586 inputs and the other eleven tool identities were unchanged. This is not a cold proof. | [Result](native-refresh/result.json), [events](native-refresh/events.jsonl), [log](native-refresh/native.log.gz), [summary](native-refresh/gnatprove.out), [provenance](native-refresh/proof-provenance.json), [78 report archive](native-refresh/reports.tar.gz) |
| `20261107T164532-6f3da3076d4d` | Passed ordinary up-to-date build check, 3.667 seconds. Compiler and Image-adapter hashes match the retained build. | [Result](build/result.json), [events](build/events.jsonl), [log](build/native.log) |
| `20261107T164659-9f6192441d21` | Passed the complete manifest: 71 source programs, 134 execution cases. The unchanged manifest method checks admission, identical source snapshots, complete required application/library proofs and audits, build, exact stdout/stderr and exit status. 720.619 seconds unittest; 721.954 seconds including harness bookkeeping; 729.716 seconds managed total. | [Result and all 142 admission/compile outputs](manifest-result.json), [log](manifest/native.log), [events](manifest/events.jsonl), [terminal](manifest/terminal.json), [harness](run-manifest.py) |

The native installation stays at `tmp/empty-loop-repair`, while delivery
fixtures live at `tmp/rosetta-expansion-300`. The harness imports the unchanged
native `tests.test_samples` and `tests.test_silver`, redirects only the sample
fixture root to the delivery tree, and preserves the compiler, invocation cwd,
source checks, proof policy and audit. It checks all 2,586 native inputs and
twelve tool identities against the refreshed complete provenance before and
after execution. The managed record captures 340 paths, including exact delivery
fixtures, harness, binaries and native configuration. The independent review
checks that relationship; no installation was moved and no audit exception was
introduced.

The failed interpreter-identity check remains failed. The ordinary native
refresh resolved a host provenance change; it is not a repository defect or an
excuse to relabel earlier evidence. The existing cache was reused without a
clean rebuild or cold discharge claim. Logs and events retain original producer
paths; relative `tmp/` paths above are relative to the repository root.

## Retained Lean and regression applicability

The [input comparison](assurance-applicability.json) records identity of all
131 source files, 659 proof files, nine scripts, 57 test files and the catalogue
with the native installation. The complete retained
[Lean checkpoint](../boolean-arrays-20261106/final-lean-after-cuts/README.md)
`20261107T064815-9c9da56edf3d` covers 655 modules and 132,101 declarations with
only `propext`, `Classical.choice` and `Quot.sound`. All 762 captured inputs match
the delivery, and Lean/Lake bytes are unchanged. Generated certificates retain
their separately checked scope; the focused parity run below checks them again
under the migrated Python. No fresh Lean build or independent kernel replay is
claimed for this sample-only change.

The unchanged regression inventory contains 603 distinct methods. The
[previous reviewed partition](../boolean-arrays-20261106/README.md#current-delivery-closeout--2026-11-07)
is the source of retained results. This delivery refreshes six methods: the
manifest, three Rosetta methods, the Boolean sample-oracle method and certificate
parity. The remaining 597 results require the closing independent applicability
review, including the interpreter patch change. The original 612-execution full
suite remains failed; nine duplicate method executions explain the difference
from 603. This is a composed regression result, not a fresh full-suite pass.

## Focused closing checks

All five focused methods passed on the final input bytes, with one worker each:

| Managed run | Check | Unittest / managed seconds | Evidence |
| --- | --- | --- | --- |
| `20261107T170341-9023673f85a1` | `test_boolean_objects.py -k test_rosetta_expected_outputs_use_independent_task_oracles`, one method | 0.002 / 1.217 | [Result](oracle/result.json), [log](oracle/native.log), [events](oracle/events.jsonl) |
| `20261107T170401-c48c00b525c9` | `test_rosetta.py`, three methods | 3.476 / 4.685 | [Result](rosetta/result.json), [log](rosetta/native.log), [events](rosetta/events.jsonl) |
| `20261107T170413-c05aa172905f` | `test_lean_source.py -k test_checked_in_certificates_equal_regeneration`, one method | 10.264 / 11.713 | [Result](certificate-parity/result.json), [log](certificate-parity/native.log), [events](certificate-parity/events.jsonl) |

Commands use `python3 scripts/dev.py test --task <label> --jobs 1 --` followed
by the selection above. Full invocation arrays and captured input hashes remain
in each event stream. The one-worker reservation is sufficient for these serial
Python tests; it does not restrict a future Lean run.

One final `python3 rosetta/refresh.py --render` produced **70 Stage-1
assessments**, up from 61, with the same 1,576 candidates and 44 stages. Exactly
eleven source assessment records changed; all original attribution and supported
identifiers remain unchanged. The generated diff includes 880 task pages: eleven
assessment changes and 869 position-only changes, plus the index and progression.
The [stage reconciliation](stage-reconciliation.json) verifies all six tracked
open/closed stage fields against the final render; no board-field change was
needed. Independent closing acceptance of the committed target remains pending.

## Independent expected outputs and task fidelity

The [simple oracle](expected-simple.py) derives divisibility/parity, factors
through paired divisors, calendar rules and argument-boundary outcomes. The
[algorithm oracle](expected-algorithms.py) uses concatenation, Python sorting,
`math.gcd`, fixed-width formatting and coin dynamic programming. These outputs
were derived independently of Silver execution and checked against all 17 new
manifest cases. The [assessment](../../../rosetta/assessment-sample-expansion-20261107.md)
links the eleven captured tasks, actual algorithms, sufficient iteration bounds,
prior review provenance and the narrow current-language dependencies.

No native macOS run, remote CI run or general language extension is claimed.
The compiler's universal guarantee rests on the applicable native and Lean
assurance above; sample execution exercises those rules rather than proving them.
