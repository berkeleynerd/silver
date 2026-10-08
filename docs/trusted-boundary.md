# Trusted boundary and verification evidence

The Oracle explicitly places GNAT, GNATprove, Alire, and OS/runtime libraries
outside the requirement to verify Silver-owned implementation code in SPARK.
Lean 4 is additionally approved for machine-checked metatheory. These boundaries
are assumptions about existing external tools and libraries, not permission to
introduce unverified Silver implementation bodies.

## Trusted computing base

This table is the consolidated dependency boundary. Verification of calls and
data inside Silver does not verify an external tool's implementation or prove
that a configured pathname selects the intended executable.

| Component | What the assurance argument relies on | Controls and remaining scope |
| --- | --- | --- |
| GNAT 16.1 and its Ada runtime | Ada/SPARK frontend meaning, code generation, ABI, binder/startup behavior, runtime checks, and static-ghost erasure | Alire release origins and recorded binary identities; compiler builds retain `-gnata` and `-gnato`. GNAT and runtime bodies are external. |
| GNATprove 16.1, its translation/Why3 tools, and bundled CVC5, Z3, and Alt-Ergo | Sound flow analysis, obligation generation, solver results, and reported evidence | Fixed proof options, complete coverage audit, and tool/version hashes. Solver soundness is trusted; no completeness claim for arbitrary SPARK is made. |
| GPRbuild 26.0 and native build tools | Project interpretation, compilation/link commands, and successful artifacts | Native Alire selection and recorded identities. Assembler, linker, sysroot, and platform development tools remain external. |
| Alire 2.1.1 and its release index | Dependency resolution, deployment, environment setup, and integrity of published packages | Pinned Alire archive SHA256 values, checked tool version families and origin hashes, host-specific settings/cache/toolchains. |
| OS, libc, and runtime services | Filesystem and process semantics, private workspace creation, resource allocation, command-line ABI, and exception behavior | Explicit imports and observed I/O contracts below. Stable files, sufficient resources, and functioning services are premises. Ordinary Ada I/O exceptions are not proved impossible. |
| Shell and inherited environment | `/bin/sh` interpretation behind `system`, native utility discovery, dynamic loading, and SDK selection | Setup quotes fixed paths; the driver appends only a checked workspace suffix. Alire/GPR overrides listed below are removed. Other state, including `PATH`, loader settings and macOS developer/SDK settings, remains trusted. |
| Python setup and generated `Silver_Build` | Correct installation anchoring, byte encoding, shell quoting, and external command prefix | Generated declarations are included in SPARK verification and evidence hashes. External-tool selection is reviewed configuration, not a proved property of those tools. Python is not a runtime Silver dispatcher. |
| Python evidence and replay scripts | Honest collection, comparison, and reporting of inputs, tools, diagnostics and artifacts | Tests and content-bound provenance detect stale/mismatched evidence. Scripts are trusted for evidence reporting; hashes do not authenticate against an actor who can rewrite both evidence and manifests. |
| Lean 4.34.1 kernel and source embedding | Kernel checking, imported source literals, and Lean's standard logical foundations | Handwritten authoritative bindings, candidate reconstruction checks, actual import/axiom audit, and fresh `leanchecker` checking. No project-specific axioms or unfinished proofs are permitted. |
| Restricted Ada-to-Lean semantic interpretation | Frontend meaning of the fixed fragment: predefined operators, indexing, evaluation and machine bounds | Whole-source byte/token/declaration checks constrain the input; GNATprove supplies executable refinement. This is not a verified general Ada parser or complete compiler-semantics theorem. |

## Compiler implementation and runtime imports

All Silver-owned executable implementation is in the SPARK bodies under `src/`:
`silver`, `silver_profile`, `silver_platform`, `silver_reports`, and
`silver_numbers`. GNATprove checks those bodies, their specifications, and the
host-local generated `Silver_Build` SPARK specification. This specification
contains absolute installation paths, shell-quoted paths, and the command prefix
used to invoke Alire. Verification checks their use as SPARK values; bootstrap's
choice of the installation and intended external tools remains reviewed
configuration. Two additional SPARK specifications declare existing external entry points; neither
has a Silver-owned implementation body.

| Binding in `silver_libc.ads` | Existing libc symbol | Purpose |
| --- | --- | --- |
| `C_Open` | `fopen` | Open a source, snapshot, project, or report in binary mode |
| `C_Get` | `fgetc` | Read a byte or EOF |
| `C_Put` | `fputc` | Write a byte |
| `C_Error` | `ferror` | Distinguish EOF from a read error |
| `C_Close` | `fclose` | Close a stream and detect close/write errors |
| `C_System` | `system` | Invoke the configured external tools or executable |
| `C_Mkdir` | `mkdir` | Create the `.silver` and native host parent directories |
| `C_Mkdtemp` | `mkdtemp` | Atomically create a unique private workspace |

| Binding in `silver_runtime.ads` | Existing GNAT runtime symbol | Contract relied upon |
| --- | --- | --- |
| `Argument_Count` | `ada__command_line__argument_count` | A nonnegative, stable argument count |
| `Argument` | `ada__command_line__argument` | Return the requested argument when its index is in range |
| `Set_Exit_Status` | `__gnat_set_exit_status` | Set the process exit status |

The two argument imports use the GNAT Ada calling convention, including its ABI
for an unconstrained `String` result. Exit-status and libc imports use the C
calling convention. The linked GNAT runtime must match the pinned compiler
family. The program imports the original runtime implementations; there are no
private C wrappers or invented implementations behind these declarations.

The argument vector is modeled as immutable because Silver never calls the
runtime operation that removes arguments. Exit status is an external abstract
state, written through an `Output` contract; main initializes it explicitly.
The libc bindings conservatively share the existing, initialized
`Ada.Text_IO.File_System` abstract state with ordinary output. This records
external effects instead of silently assuming calls are pure. It does not prove
libc's filesystem, process, pointer, allocation, or termination behavior.

The SPARK file wrappers additionally record ghost observations beside their
actual libc calls. GNATprove establishes that a successful complete read returns
exactly the byte sequence observed from `fgetc`, followed by EOF and a successful
close. A successful write passes exactly the supplied bytes, in order, to
successful `fputc` calls and closes successfully. These contracts verify the
Silver-owned copy loops; interpreting those calls as file operations still uses
the documented semantics of the trusted libc functions. `Run` similarly records
the exact command passed to `system` and its returned status. Its postcondition
equates success with a zero status. The observations are verification state,
not additional imported assumptions.

The supported libc ABI uses byte results `0 .. 255`, `EOF = -1`, and zero for
successful close/process completion. Binary `rb`/`wb` modes preserve byte values.
The file handle returned by each successful open is used for that operation's
read/write loop and close. Interpreting a complete read as a stable file snapshot
also requires the stated absence of concurrent replacement or mutation.

Existing Ada runtime services, including `Ada.Text_IO` and `Interfaces.C`, and
GNAT's generated binder, startup, linker, and runtime code remain trusted. There
is no claim that the imported C bodies or the whole operating system have been
verified in SPARK. External process completion and successful resource allocation
are infrastructure conditions rather than new Silver membership restrictions.
Explicitly detected failures use the driver's failure status. Resource exhaustion
or external runtime exceptions can still terminate the process outside that
ordinary diagnostic path.

## Audit of the boundary

`scripts/check_evidence.py` enumerates all Ada source units under `src/` and
`.silver/<host>/generated/`, requires fresh `.spark` reports, and checks each
owned entity. Full implementation entities must have `all` SPARK coverage.
Exactly the eleven imported functions/procedures
above may have `spec` coverage. Their enclosing package declarations and any
flow/proof diagnostics are still audited; a package initialization error is not
waived because the package contains imports.

The auditor pins the complete imported declarations and contracts using SHA256
of their tokens, preserving quoted external names and excluding only comments
and whitespace outside strings. It also rejects a corresponding `.adb` body.
Changing a binding, contract, or external symbol therefore requires deliberate
review of this boundary and an updated pin. These pins protect the reviewed
interface; they are not proofs of the runtime implementations.

All actual flow/proof checks must be discharged. The audit rejects skipped
analysis, `pragma Assume`, justified checks, unproved checks, missing coverage,
failed invocations, and source-suppressed diagnostics. The source-policy lexer
rejects unsupported bytes throughout compiler files, including comments, and
distinguishes qualified expressions from character literals. It pins the
reviewed GPR token shape and checks permitted assumption edges to owned or
explicitly trusted callees.

The logical proof configuration is explicit: full flow/proof, all reports,
warnings/checks as errors, level 2, bundled `cvc5,z3,altergo`, and a 30-second
timeout. Worker count is configurable and defaults to all detected cores.
GNATprove's native filesystem solver cache is host-local and keyed by the Alire
lock. Native tool caching, including correct matching of proof tasks and results,
remains part of the trusted GNATprove dependency. Managed warm sessions and
caches are intended for the fixed logical configuration; arbitrary exploratory
commands use separate output and cache paths.

`dev.py prove --full` forces unit analysis and removes old report outputs before
the run, while retaining solver/session caches. Only scheduling, the managed
cache and validated output subdirectory vary; semantic proof flags remain fixed.
The audit cross-checks `.spark` obligations and diagnostics against SARIF
and the text summary; a zero process status or empty SARIF results is insufficient.
This complete audit permits native proof-result reuse and does not demonstrate
uncached performance. Optional `dev.py prove --cold` implies full validation in
a unique fresh output/session/cache workspace. It preserves ordinary warm state
and other hosts' artifacts, rejects custom `--subdirs`, and prints the separate
evidence path.

Direct exploratory `gnatprove` invocations through `dev.py tool` require
`--subdirs=explore` or `explore/<name>` and cannot write to audit-managed solver
caches. Help and version queries are exempt. This guard prevents ordinary
command mistakes; it does not inspect arbitrary wrapper commands or authenticate
against a hostile process with filesystem access. It introduces no proof gate
for ordinary builds.

`scripts/proof_provenance.py` records the host, effective command, source and
project bytes, generated configuration, Python scripts, Alire settings/lock, and
selected tool identities before proving. After successful coverage auditing it
requires unchanged inputs/tools and binds report hashes in a completed manifest.
The command-line auditor requires this manifest. This distinguishes current
native evidence from retained reports for another tree, configuration, or host;
it is local provenance, not an authenticated build attestation. Default
incremental `dev.py prove` keeps sessions/reports and invalidates the prior
completed full-audit manifest. It supplies developer feedback without claiming
a new full audit. Build commands do not require this evidence; binary and
comprehensive per-program attestations are deferred under the
[development policy](../development.md).

Two optional limitation diagnostic codes are explicitly classified:
`contracts-recursive` and `numeric-variant`. The authoritative
[SPARK 16.1 proof-limitations documentation](../references/spark/16.1/docs/ug/en/source/proof_limitations.rst)
states that these constructs can be used safely. Their contracts or expression
bodies may be unavailable on recursive calls inside assertions, which removes
information available to the prover. The related obligations must still prove.
GNATprove marks these disabled-by-default notes as externally suppressed in
SARIF; the auditor permits that exact representation for these two codes and
counts them. It permits no source suppression or failed obligation through this
exception. Current diagnostic and check counts are recorded in
[the workflow record](proof-workflow.md).

## Source identity and program proof evidence

The compiler reads the author's source as bytes and decides membership before
calling a prover. It uses `mkdtemp` to allocate a fresh private workspace with
mode 0700, validates the returned path, and writes a byte-for-byte `main.adb`
snapshot. A generated GPR project names that source explicitly and enables Ada
2022, assertion checking, and overflow checking. It supplies no replacement Ada
source or hidden contracts.

The compiler compares the snapshot with the admitted bytes after writing it,
after verification, and after compilation. Both GNATprove and GPRbuild receive
the same generated project. Original user paths are used by file operations and
are never interpolated into shell command text. Failed I/O, missing or incomplete
reports, changed snapshots, and unsuccessful tools prevent a success result.
Regression tests exercise these failures using the actual SPARK executable.

The catalogue names the admitted procedure, required `SPARK_Mode (On)` pragma,
and single null statement, with their conditions and only allowed composition.
It specializes the language to an empty user-program obligation set. Its report
contract and safety theorem must be extended before admitting constructs that
generate checks; compiler-implementation obligations remain substantive.

`Silver_Reports.Complete_Null_Proof` checks the GNATprove 16.1 `.spark` format for
completed proof progress, no stop reason, precisely one fully SPARK entity, and
empty flow, proof, skipped-proof, `Assume`, and warning/error lists. Zero checks
are expected for the admitted null program; entity coverage prevents accepting
an empty analysis merely because it has no failures.

GNATprove establishes the checker's exact functional contract:
`Complete_Null_Proof'Result = Recognizes_Null_Report (Report)`. The independent
specification describes whitespace filtering, quantified substring occurrence,
and the first matching `spark` prefix's single numeric-key entity shape.
Recursive equal-input lemmas establish that equal string values give the same
recognition result even when their prover representations differ. This proves
the owned format recognizer; interpreting those fields as proof evidence still
depends on the genuine producer described below.

The recursive mathematical report specifications and the assertions that refer
to them use `Ghost => Static` and the `Static` assertion level. GNAT erases those
proof-only computations, preventing recursive stack growth during report
processing. GNATprove still verifies all obligations of this report unit,
including its refinement contract. The executable checks, report domain of
262,144 bytes, and global `-gnata`/`-gnato` switches are retained. A native
negative experiment with a deliberately false static contract fails verification
as expected; see the repair record for this and maximum-size runtime tests.

This checker relies on a genuine report produced by the trusted GNATprove 16.1
invocation in that fresh workspace. It is a checker for that producer's known
format, not a general JSON parser or an authenticator for adversarial report
text. It does not prove that arbitrary fabricated or duplicate-key JSON has the
same interpretation. The tool implementation, report provenance, filesystem,
and absence of hostile concurrent replacement inside the private workspace are
part of the external trust assumptions.

The driver's proved contracts require source membership, exact source/project
write observations, matching source reads, the accepted report predicate, and
successful calls of the specified proof/build commands before publishing or
running an artifact. The corresponding external file and process effects rely
on the approved runtime/tool semantics. The conditional Lean toolchain theorem
and its exact scope are described in [the assurance argument](assurance.md);
these contracts do not constitute verification of libc or GNAT itself.

## Source correspondence and semantic assumptions

The handwritten `Silver.AuthoritativeSource` module fixes the source bindings
for the actual profile specification and body. The certificate generator emits
candidate reconstruction data and cannot select replacement bindings. Lean
checks that every source byte, including comments and literals, belongs to
HT/LF/CR or printable ASCII. A checked-in complete token shape fixes declarations,
scopes, aspects and bodies, rejecting inserted operators/helpers, renamings, and
alternate literal spellings outside that reviewed shape.

`SourceBridge.CheckedSource` combines the byte, token, declaration, expression,
catalogue and refinement checks. The recursive expression interpretation is
parameterized by its callees. Applying the recursive uniqueness lemmas connects
every interpretation satisfying the checked definition equations to membership;
an explicit model satisfies those equations. These equations are a semantic
interface, not project axioms or an assumption that membership implies proof
success.

The remaining interpretation premise is that approved Ada/GNAT frontend
semantics gives this fixed fragment its modeled predefined operators, indexing,
evaluation and machine bounds. GNATprove establishes normalization, bounds and
the executable `Accepts = Is_Member` refinement. The combined argument does not
claim a verified arbitrary Ada parser, complete name-resolution semantics, or a
single theorem for the entire compiler, shell and operating system. The
[assurance argument](assurance.md) states the precise theorem boundaries.

## Versions and platform scope

Build state is isolated by native OS and architecture: `linux-aarch64`,
`linux-x86_64`, `macos-aarch64`, or `macos-x86_64`. `.tools/<host>/` owns the
Alire and Lean installations and Alire settings, cache, and toolchains.
`.silver/<host>/` owns the Alire manifest copy and lock, generated SPARK
configuration, compiler objects and executable, proof workspaces and evidence,
and unique user-program directories. No shared current-host selector is used.
Legacy unkeyed artifacts are retained but unused; authenticated release archives
may be copied from the legacy cache without modifying them.

`scripts/dev.py` selects the native host before invoking development tools.
`silver.gpr` requires an explicit supported `SILVER_HOST` and has no usable
default. The actual SPARK compiler uses installation-anchored `Silver_Build`
configuration and accepts invocation from any working directory. Relative input
paths are resolved in the caller's directory; artifacts and tools use the
configured absolute installation root. Its workspace contract checks that fixed
prefix and the six-character alphanumeric suffix returned by `mkdtemp`.
Bootstrap quotes installation paths and checks the compiler's path/command
length bounds. Moving the checkout requires bootstrap and rebuild. Admission
and compilation remain in SPARK.

Alire loads settings before processing its directory/configuration switches.
All invocations therefore start in the isolated context with
`ALIRE_SETTINGS_DIR` pinned. `ALR_CONFIG`, `GPR_CONFIG`, `GPR_PROJECT_PATH`,
`GPR_PROJECT_PATH_FILE`, and `ADA_PROJECT_PATH` are removed from both development
and runtime invocations before Alire starts. The generated shell prefix uses
absolute quoted paths for the context, settings and Alire executable; the
compiler process itself retains the caller's working directory. These controls
are not full hermeticity: native environment and toolchain integrity remain
external assumptions.

The Lean replay tree is private to the host and reads the authoritative `src/`
through a checked link. Generated source certificates, Lake artifacts, and
manifests are written there. Shared proof inputs are fingerprinted and must
remain unchanged throughout replay. Script inputs, Lean/Lake/kernel-checker
binaries, compiled artifacts and the replay log are also hashed. The imported
module inventory and transitive axiom audit come from a fresh execution of the
audit module after every build, including cache hits. Full/clean modes also
perform a fresh independent kernel recheck. Local cached Lean objects rely on
Lake's dependency tracking and the pinned Lean toolchain; both external Ada
files are binary input dependencies, rehashed on each invocation. A change to
either invalidates the whole Silver Lean library's cached build. Lean/Lake
startup receives explicit native tool, sysroot, configuration, and cache paths;
inherited Lean/Elan search
paths and tool selections cannot redirect it. Artifact restoration is disabled
for proof replay; this does not disable the local Lake build cache.

After generation and again after replay, noncandidate workspace modules and
project/toolchain files must equal the captured shared bytes. Files and their
workspace parents may not be symlinks. A candidate generator therefore cannot
replace a handwritten binding or proof module while leaving only a self-consistent
workspace hash; candidate reconstruction remains separately checked by Lean.

Alire 2.1.1 and Lean 4.34.1 downloads have pinned upstream SHA256 hashes for Linux
and macOS on ARM64 and x86-64. Alire checks the indexed binary origins for GNAT
16.1, GNATprove 16.1, and GPRbuild 26.0. The approved patch-level variation does
not remove the requirement to verify the implementation on each platform.

The earlier Linux ARM64 validation is recorded in [the repair record](review-repairs.md).
The latest external macOS ARM64 review validated the staged incremental
workflows before the cold-proof and direct-tool guard additions. It reported
passing compiler proofs, all tests under symlinked `TMPDIR`, and every Lean
mode. Retained compiler and final clean Lean artifacts were independently
corroborated on Linux. These artifacts cover that reviewed workflow, not the
subsequent cold/guard changes. Exact evidence and scope are in
[the workflow record](proof-workflow.md). Native macOS validation of those
additions and Linux/macOS x86-64 validation remain pending.
CI is prepared for
`ubuntu-24.04`, `ubuntu-24.04-arm`, `macos-15-intel`, and `macos-15` (ARM64).
The work is local-only as requested, the repository has no remote, and no CI job
has been dispatched. Configuration is not evidence of a hosted run. Under the
Oracle, Linux is primary and native macOS validation is independent and does not
block completion of the Linux milestone. Historical checkpoint files describe
their dated baseline, not the current validation state.
