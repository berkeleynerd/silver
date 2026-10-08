# Hello World runtime experiment

## Scope and selected implementation

On 2026-10-08 the isolated experiment in
`.silver/linux-aarch64/hello-experiment/` selected the owned SPARK library
[`Silver_IO`](../src/silver_io.ads), its
[body](../src/silver_io.adb), and the direct existing-libc declarations in
[`Silver_Output_Libc`](../src/silver_output_libc.ads). There is no owned C body.
Only `Silver_IO.Put_Line` is proposed for application admission; these internal
bindings, ghost observations, constants and other imported packages are not
application capabilities. The library accepts `String` without a precondition.
An executable length guard exits with status 1 when its length exceeds 4096.
The separately specified admitted literal domain is within that bound.

The executable body calls `putchar` once per input character in source order,
checks that each result equals the supplied character code, calls and checks
`putchar(10)`, then calls `fflush(NULL)` and requires result zero. Each detected
failure calls existing libc `exit(1)` and cannot return normally. A normal return
therefore follows successful input-byte and LF calls and a successful flush.
There are no additional Ada output calls or hidden annotated application bodies.
`Ada.Text_IO` supplies the initialized external `File_System` abstract state;
its output API is not used. `Interfaces.C` supplies the existing C integer ABI,
and `System.Null_Address` supplies the null pointer value.

Static ghost state records each byte only after a successful call. Its proved
normal-return contract says that the observed bytes equal the entire input
followed by LF, and that flushing succeeded. Ghost state, postcondition and loop
invariants use the `Static` assertion level, so GNAT erases their computations
from execution. This proof establishes the wrapper's sequencing and complete
normal-return observation, conditional on the documented libc meanings. It does
not prove an imported libc body or environmental progress.

## Observable effect and external assumptions

On the supported Linux and macOS libc interfaces, `putchar` writes the supplied
unsigned-character byte to the initial stdout stream and returns that value on
success; a failure returns EOF. `fflush(NULL)` flushes **all open C output
streams**, returns zero on success and nonzero on failure. Admitted applications
have no stream-opening, reassignment or other output operations. Successful
completion means that libc has successfully flushed the requested bytes to the
host stdout stream. It does not mean that a downstream reader has consumed them
or that storage is durable. There is no newline conversion: LF is byte 10.

Exact output requires no concurrent stdout writer or stream rebinding and a
correct initial stdout stream and libc ABI. External services may block; the
imports and wrapper declare `Always_Terminates => False`. Finite completion is
conditional on the corresponding output/flush/exit progress assumption. Libc
`exit(1)` flushes streams itself and can also block. The wrapper does not retry a
failed operation or represent a partial write as successful completion.

Ordinary detected output failures terminate with status 1. An external signal,
such as default SIGPIPE from a broken pipe, can terminate the process before a
libc call returns; this is also an unsuccessful process outcome. Startup,
elaboration, resource failures and external runtime exceptions remain in the
existing trusted runtime boundary and must not be interpreted as successful
output. Failed flushing may leave some, all or none of the requested bytes
visible; the normal-return guarantee applies only after successful flushing.
These premises must be retained in the authoritative
[trusted boundary](trusted-boundary.md) and [assurance](assurance.md) when the
capability is admitted.

## Native experiment evidence

The actual host was Linux ARM64 (`linux-aarch64`), established with `uname` and
`python3 scripts/dev.py paths`; the checkout's macOS-style path did not determine
the platform. The prototype project, source, reports, executable and JSON
observations remain below `.silver/linux-aarch64/hello-experiment/`. They are
exploratory evidence and do not constitute a completed compiler-wide audit.

The proof command was:

```sh
python3 scripts/dev.py tool -- gnatprove \
  -P ../hello-experiment/hello.gpr --subdirs=explore/runtime \
  --mode=all --report=all --warnings=error --checks-as-errors=on \
  --level=2 --prover=cvc5,z3,altergo --timeout=30 -j2
```

The final prototype invocation completed successfully with **25 checks**:
5 flow checks (one data-dependency and four initialization checks), and 20 proof
checks (15 runtime checks, four loop-invariant checks and one functional
postcondition). Every owned entity had `all` coverage; the three imported
subprograms had `spec` coverage. No warnings, unproved checks, skipped required
checks or `pragma Assume` entries occurred.

The calling `main.spark` had zero flow/proof diagnostics, complete proof progress,
no stop reason and `Main` with `all` coverage. Its entity dictionary also names
`Silver_IO.Put_Line`, and its assumption edges refer to that library contract.
The application report alone therefore does not establish complete-call-chain
assurance; the selected library reports and source correspondence must also be
checked. The owned `silver_io.spark` contained all five flow and 20 proof checks.
The import package had zero checks and its package declaration had `all`
coverage. An earlier prototype with a public length precondition generated a
user-program precondition check; replacing it with the executable guard removed
that user obligation while preserving the complete String input domain.

Native build used `scripts/dev.py tool -- gprbuild` on the same experiment
project, with Ada 2022, assertions and overflow checking enabled. Execution
observations were:

| Input or environment | Observable result |
| --- | --- |
| `"Hello, world!"` and ordinary captured stdout | Exact `Hello, world!` plus LF, exit 0, empty stderr |
| stdout redirected to `/dev/full` | Exit 1, empty stderr; buffered-flush failure exercised |
| stdout file descriptor closed before execution | Exit 1, empty stderr |
| `stdbuf -o0` and stdout redirected to `/dev/full` | Exit 1, empty stderr; immediate byte-write failure exercised |
| Empty String | Exactly one LF, exit 0 |
| 4096 `~` characters | Exactly 4096 `~` bytes plus LF, exit 0 |
| 4097 `~` characters | No output, exit 1; length guard exercised |
| String range `100 .. 102` containing `abc` | Exactly `abc` plus LF, exit 0 |

The last four are direct library-domain checks, not claims that their test
source belongs to the application profile. They are retained in the experiment's
`checks/` tree. These observations exercise paths and boundaries; the universal
assurance argument must cover the entire admitted domain and composition rules.

The copied implementation adds explanatory comments only. A separate
`integration.gpr` in the experiment names the current shared runtime source
files explicitly, retains the unchanged application source, and uses
`integrated-obj/explore/runtime/` for proof results. The integration proof repeated the same logical flags and completed all 25
checks. Building and executing that project again produced exact
`Hello, world!` plus LF and exit 0 with empty stderr. Current source hashes and
commands are retained in the experiment's `evidence.json`. No canonical audit
state or other host artifacts were overwritten by the experiment.
