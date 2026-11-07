# Scalar-function producer mechanism probes — 2026-11-07

This packet preserves the early #298 native producer probes previously kept in
`tmp/scalar-functions-plan-298/tmp/native-function-probes/`. It retains the exact
selected-grammar source and raw Main report examined by the
[capacity review](../../../reviews/review-scalar-function-capacity-20261107.md),
plus the basic comparison and its failed first managed capture. These are
producer-mechanism observations on `linux-x86_64`, separate from the
[final native behavior checkpoint](../final-native-behavior/README.md).

[index.json](index.json) inventories every compressed artifact with SHA-256 and
byte length for both stored and decompressed bytes. Its `sha256` applies to the
decompressed bytes, following the other packets' convention. It also records
original paths, run arguments, preflight input hashes, managed outcomes and
artifact links. The original [scratch hash inventory](input-report-hashes.json.gz)
is retained unchanged; all 13 entries matched when collected. No mismatching
scratch bytes were assigned to an earlier run.

Both probes retain their unchanged source and project:
[basic Main](basic/main.adb.gz), [basic project](basic/probe.gpr.gz),
[selected Main](selected/main.adb.gz), [selected project](selected/probe.gpr.gz).
Each source/project pair matches its own managed preflight hashes. The identical
project files enable SPARK checks with Ada 2022, assertions and overflow checks.

| Managed run | Observation | Managed elapsed time |
| --- | --- | ---: |
| `20261107T172711-bb53bdee4857` | Failed managed input capture: declared inputs changed during execution. GNATprove itself returned 0 and logged 8 proved checks, with contextual inlining. This remains a failed run. | 4.125603547 s |
| `20261107T172925-d1dec7c49eb6` | Successful basic modular run with `--no-inlining`; 7 proved checks. | 5.183987797 s |
| `20261107T173133-e00faebcc964` | Successful selected-grammar run with `--no-inlining`; 9 proved checks, including the unused function. | 7.268570516 s |

Each run retains its complete events and native log under `runs/<run-id>/`.
The events identify one worker, GNAT/GNATprove 16.1.0, the exact command and tool
identities. The first two runs used a 30-second solver timeout; the selected run
used `--timeout=0`. All used `-U`, full flow/proof reporting, checked errors,
level 2, the cvc5/z3/altergo prover selection, 100,000 steps, the `--memlimit=1000` prover
memory limit and disabled loop unrolling. The second and third runs also disable
inlining. The basic modular report includes an ineffective-initialization
warning; these experimental results do not claim the final compiler report policy.

Every run retains `main~1.spark`, `gnatprove.out` and `gnatprove.sarif` under its
probe and `function-*` directory. These bytes were copied from the historical
managed runner report captures and compared byte for byte with the scratch
reports. All three raw Main reports also match the original scratch hash
inventory. The retained `data_representation/main.adb.json` files match that
inventory; these are scratch report snapshots, rather than claims of an
independent managed input capture. Compiled objects, generator intermediates,
solver sessions and referenced trace files are outside this compact packet.

The [selected raw Main report](selected/function-selected/main~1.spark.gz) has
SHA-256 `5556d3921789bbd0a9e5f4cb1237dcac2011eca9c5a323eff0d7a72ce2e6b05c`;
the selected source has SHA-256
`844977832049bb3811901ae0c86117882276ad9776ee3f0075d225746081b31f`.
These are exactly the capacity review's examined bytes. All five Main/local
entities have full SPARK coverage; four successful termination records and five
safety records include the uncalled `Unused` function's division check. The
source keeps full-domain Integer formals, including `Is_Prime` and `Unused`,
and the modular run analyzes their bodies separately from their callers.

The failed first run's present source happens to match its preflight source
hash, and its retained report bytes match the original inventory. This does not
repair its managed failure or establish that every declared input remained
stable during that execution. The recorded input-change failure is preserved
without inferring which input changed.

Collection was performed from integration base `45fa4fe8c9` as evidence retention
only. No native tools, proof runs, tests or application execution were rerun.
Verification covered gzip round trips, both sets of indexed hashes and byte
lengths, historical input/report comparisons, artifact inventory and relative
links. This packet establishes neither final compiler verification nor universal
assurance and makes no macOS or CI claim. Runtime model/effort and token/cost
telemetry were unavailable to this subthread. The live harness goal was `null`;
CLI recall was not updated.
