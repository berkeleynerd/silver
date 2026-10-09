# Command-line messages

This records the `e14ba1a` capability baseline. Its subsequent independent macOS
validation and review follow-up are recorded in
[command-line-review-repairs.md](command-line-review-repairs.md).

This capability follows the named-string increment and implements the owner's
2026-10-09 authorization. Its motivating sample is
[samples/command_line.adb](../samples/command_line.adb). The complete source rules
remain in [language.md](../language.md); assurance and external assumptions belong
in [assurance.md](assurance.md) and [trusted-boundary.md](trusted-boundary.md).

## Selected design

The named constant is initialized by
`Silver_Arguments.First_Or_Default ("Hello, world!")`. A missing argument uses the
literal default. One argument preserves its exact printable ASCII bytes,
including an explicitly empty argument, up to 4096 bytes. Extra arguments,
unsupported bytes and oversized input cause status 1 with no application output.
Invalid input is neither truncated nor accepted through a fallback default.

The initializer is pure. A mandatory `if Silver_Arguments.Input_Is_Valid then`
branch prints the constant; its mandatory `else` calls `Silver_Arguments.Reject`.
The invalid initializer result is an internal empty string, never printed by an
admitted program. The queries observe the same immutable GNAT argument vector.
SPARK rejects a side-effecting function in this constant initializer, so the
explicit validity guard is part of the admitted composition.

Only this conditional is admitted. Reassignment, concatenation, arbitrary
conditions, general command-line package access, indexing and additional calls
remain excluded. The constant's name additionally cannot be `Silver_Arguments`,
which would hide the package needed for the guard and rejection call.

Successful output and detected output failure retain the verified `Silver_IO`
behavior. The program's final status is distinct from the Silver compiler CLI's
status. Run the executable printed by `silver compile` directly with arguments;
argument forwarding through `silver run` remains a separate convenience.

## Implementation and assurance

All output programs select one fixed six-file runtime: IO spec/body, Output_Libc
spec, Arguments spec/body and Runtime spec. The latter exposes the existing GNAT
argument imports, already within the trusted dependency boundary. This avoids
new selection modes throughout the source-binding pipeline. It does not admit
additional APIs to application source. Bootstrap embeds all six exact source
files; compilation verifies their unchanged snapshots and all four complete
library reports before publishing the executable. Null programs retain their
empty library selection.

The command-line production is a closed 51-token grammar using the existing
identifier/literal rules, one initializer and one mandatory guard. Lean proves
membership, binding, source meaning and the runtime outcomes over all argument
vectors under the documented ABI and environment assumptions. The actual-source
bridge checks the new recognizer expressions and the wrapper declarations/body.
GNATprove verifies the owned implementations' required flow and proof
obligations, including report-scanner safety. Report interpretation is reviewed
and tested; it has no independent parser-refinement theorem.
Application Main reports remain empty for this production; actual nonempty
library obligations remain required. Modeled empty application lists are
connected through the reviewed Ada structural argument and the faithful
GNATprove-generation premise, not an independent verified obligation generator.

GNAT retrieves an unconstrained String before Silver checks its size. The
language bound is not a promise to avoid allocations for oversized argv, and
storage exhaustion remains an environmental limit. Both queries are pure under
the immutable-vector premise; mutable external argv would violate that premise.

## Validation

The integrated Linux ARM64 compiler audit passed all 1,731 checks (297 flow and
1,434 proof), covering all 16 units and 155 entities. All 14 imported declarations
and 23 recognized limitation notes were accounted for, with no unproved,
justified or suppressed obligations. The command was:

```sh
python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=command-line
```

It used fresh unit-analysis/session output and the existing native solver cache;
this is a complete audit, not an uncached performance claim or evidence that the
earlier GNATprove JSON-reader defect is fixed. All 2,389 recorded input hashes and
18 report hashes matched after completion. The manifest is
`.silver/linux-aarch64/compiler/obj/command-line/gnatprove/proof-provenance.json`,
SHA256 `927df8578d3eb4d560c19949deea2c873c7a9df6a7f106d25bd8c5f5e9a0d02b`.
Bootstrap, native build and the catalogue/export comparison passed.

All 27 focused integration tests passed, including closed grammar, default and
argument bounds, exact empty/default/rejection outcomes, complete library
reports, unchanged snapshots and output-failure status. The initial complete
122-test run exposed two stale fixtures: the generated-binding audit fixture
omitted the new library reports, and the Lean dependency fixture omitted the
three new source inputs. The other 120 tests passed. Both fixtures now cover the
expanded set, including absent reports, all six runtime-source binding changes
and all ten embedded-file cache invalidations. Their 35 focused tests passed.
The final full suite passed all 122 tests in 115.260 seconds. The initial failure
log is retained separately from this successful rerun.

Independent source review found no blocking mismatch. The production recognizer,
runtime wrapper, snapshot handling and report checking match the verified
isolated handoffs. All four documented token sequences exactly match the
catalogue. Ten certificate candidates regenerate byte-identically. The isolated
actual-token bridges and aggregate Lean audit passed. The canonical build
completed all 61 Lake jobs, followed by a fresh axiom audit of 14,309 declarations
across all 50 project modules using only `propext`, `Classical.choice` and
`Quot.sound`. The regenerated output
recognizer certificate took 853 seconds and dominated build time. Lake retained
its native workspace; changed embedded source invalidated the library under the
existing dependency policy. This records the current cost, not an optimized
parallelism claim. The independent `leanchecker --fresh Silver.Audit` kernel
recheck passed. The complete invocation took 1,282.621 seconds while test runs
overlapped part of the replay; these are observed durations, not isolated
benchmarks. All 75 captured
inputs, 52 workspace inputs, 100 compiled artifacts, tool hashes and the proof
log hash matched after completion. The final Lean evidence SHA256 is
`1ec39ca36a72f5f822b0a9a9b8aa01a934e8b4419a6103d806ce0f7a2a86f7f6`.

Stable compiler reports, manifest and logs are retained in
`.silver/linux-aarch64/arguments-final-evidence/`, together with final Lean
evidence and logs. Native macOS validation was pending at the initial capability
commit; the subsequent `e14ba1a` review passed and is recorded in the
[follow-up record](command-line-review-repairs.md#native-macos-validation-of-the-baseline).
No hosted CI or x86-64 execution is claimed.
Earlier capability records retain their actual inputs and platform scope.
Oracle bytes remain unchanged.
