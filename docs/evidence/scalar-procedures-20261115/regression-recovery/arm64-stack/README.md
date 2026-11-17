# ARM64 scalar-guard regression stack diagnosis — 2026-11-15

The unchanged accepted compiler passes all three original exact-4096-byte
scalar-guard admission cases with a **16 MiB child process stack**. Their failure
at the inherited 8 MiB limit is primary-stack exhaustion in the recursive
condition parser. This is an environment correction under the existing
[sufficient-stack premise](../../../../trusted-boundary.md), with no language,
source, contract, obligation, compiler-option or test-case change.

## Inputs and controlled comparison

The failed complete regression run is `20261115T220916-99f1eaeea331`. This
diagnosis uses its delivered native binary, SHA-256
`683925c9b33cda887a58ecc2ad1d0e8feedf51590653e7aee3dd2889b06267d9`, in the
integration worktree. Native production source is `1dde32cce`; the diagnostic
worktree branched from integration `defb4589b6a5d33dd61e9a5c415c6eb332d97ae3`.
Later integration documentation/fixture changes advanced its HEAD; exact file,
binary, object and tool identities are retained in [provenance.json](provenance.json).
No build, native proof or Lean proof was run for this diagnosis.

The host is Linux aarch64, GNAT 16.1.0, with 12 available CPUs. The object retains
`-gnat2022 -gnata -gnato -g`, plus the driver's `-gnatA` and target switches;
there is no optimization switch in its ALI arguments. Assertions and overflow
checks remain enabled. The parent's stack is 8,388,608 bytes soft and unlimited
hard before and after the probe.

[probe.py](probe.py) recreates the exact source generator in
`ScalarGuardTests.test_admission_exact_source_limit_with_active_scalar_counts`.
It changes only each child's `RLIMIT_STACK` soft limit before executing the
same binary's `check` command. Each source is retained and checked for byte
identity after invocation. [results.json](limits-initial/results.json) records
all 27 results, source hashes, stdout/stderr and measured elapsed times.
An independent capture-only invocation of the original test method confirmed
all six original `check` inputs and expected statuses exactly match these
retained exact/over sources; see [source-identity.json](source-identity.json).
The source fixtures intentionally retain terminal spaces for the exact byte
boundary. Whitespace validation excludes those byte-exact `.adb` fixtures;
trimming their spaces would invalidate the experiment.

| Active scalars | Condition depth | Source bytes | 8 MiB | 12 MiB | 16 MiB |
| --- | ---: | ---: | --- | --- | --- |
| 0 | 2001 | 4096 | `Storage_Error`, exit 1 | `Storage_Error`, exit 1 | Accepted, exit 0 |
| 1 | 1993 | 4096 | `Storage_Error`, exit 1 | `Storage_Error`, exit 1 | Accepted, exit 0 |
| 32 | 1765 | 4096 | `Storage_Error`, exit 1 | Accepted, exit 0 | Accepted, exit 0 |

All nine 4097-byte companion invocations reject with exit 2. All nine shallow
controls accept with exit 0. An initial progress message overgeneralized the
12 MiB success from count 32 to all counts; the complete raw results immediately
corrected that statement. This table and the retained JSON are the measured result.

Reproduce from a checkout with the delivered binary, substituting its actual
path and a fresh output directory:

```sh
python3 docs/evidence/scalar-procedures-20261115/regression-recovery/arm64-stack/probe.py \
  /absolute/path/to/silver --output /absolute/path/to/probe-results
```

## Measured call route and frames

The exact delivered parser object has the following ARM64 prologue allocations.
Each compiler-generated contract wrapper and its body remain live on the
recursive grouping path:

| Routine | Wrapper bytes | Body bytes | Combined bytes |
| --- | ---: | ---: | ---: |
| `Read_Condition_Into` | 400 | 48 | 448 |
| `Read_Relation_Into` | 400 | 2368 | 2768 |
| `Read_Boolean_Relation_Into` | 400 | 256 | 656 |
| `Read_Boolean_Factor_Into` | 400 | 864 | 1264 |
| `Read_Primary_Into` | 400 | 880 | 1280 |
| **One grouping level** | **2000** | **4416** | **6416** |

The call sequence is Condition → Relation → Boolean_Relation → Boolean_Factor
→ Primary → the next Condition. `Read_Primary_Into` forwards the result buffer
at source line 3867; the extra frames are not a per-level maximum-sized scalar
flow vector. [frame-instructions.json](frame-instructions.json) retains prologue,
stack and call instructions; the [complete selected disassembly](recursive-frames.disassembly.txt.gz)
retains all ten functions. This analysis does not sum unrelated branches or
transient callees as if they remained live.

Independent observation of the executing binary with GDB 17.2 measured exactly
64,160 bytes of stack-pointer descent between the first and eleventh
`Read_Condition_Into` entries, for **each** active scalar count. The backtraces
show the same ten-frame sequence. The unchanged sources subsequently accepted
normally at 16 MiB. Retained evidence:
[zero scalars](gdb-count-0.txt), [one scalar](gdb-count-1.txt),
[32 scalars](gdb-count-32.txt), and [debugger commands](frames.gdb).
The debugger was launched in its own 16 MiB child environment against the same
binary; no parent stack limit was changed.

The grouping frames alone therefore require 12,838,416 bytes at depth 2001,
12,787,088 bytes at depth 1993, and 11,324,240 bytes at depth 1765. These values
exclude driver, transient leaf, process startup and external-runtime usage.
They explain the observed 8/12 MiB failures; they are not total-stack upper
bounds, an exact minimum, or a universal proof of 16 MiB sufficiency. The
independent source/runtime proofs remain accepted on their existing inputs and
premises. Historical 8 MiB observations retain their own source/build scope.

## Minimal remedy and remaining validation

Use an explicit 16 MiB soft process stack for the ARM64 validation invocation
and document that environment for direct compiler/developer invocation. For
example, a subshell confines the setting to the managed test process and its
children:

```sh
(
  set -e
  ulimit -S -s 16384
  python3 scripts/dev.py test --task scalar-procedures-370 \
    --reason 'ARM64 regression under measured 16 MiB stack environment' \
    -- -p test_scalar_guards.py
)
```

The existing general Linux setup wording in `README.md` recommended 8 MiB;
that recommendation needs an explicit current ARM64 environment correction.
It must not be justified by reinterpreting the older input-specific results as
a universal bound. The lead owns the README, development and trusted-boundary
updates. This bounded investigation owns only this evidence directory.

No test skip, reduced depth, changed expected status, permanent/global shell
change, optimization or compiler repair is needed for the observed failure.
Required next checks are the unchanged complete `test_scalar_guards.py` suite
in this explicit environment, then independent reconciliation of the completed
full-suite inventory with successful reruns of every affected repair surface,
including the separately diagnosed Lean fixture and the final Rosetta
publication state. That review must establish final input applicability and
complete coverage; a new complete regression run is needed if it cannot. The
lead coordinates those managed runs and independent acceptance. This record
itself establishes only the 27 controlled admission checks and three debugger
observations.

## Round and handoff

Requested diagnosis setting: GPT-6 Astra, Max; runtime model/effort telemetry is
not independently exposed to this worker. Results: controlled resource
discrimination, exact assembly and executing-stack agreement, and a minimal
environment remedy without changing production/proof inputs. Native diagnostic
durations are in the raw results; separate agent elapsed/token/cost measurements
are unavailable. No claim of capability completion or full regression success
is made by this bounded subthread. Deferred #119 capacity redesign and #373
resource-exception behavior remain outside this work.
