# Trusted boundary and verification evidence

The Oracle explicitly places GNAT, GNATprove, Alire, and OS/runtime libraries
outside the requirement to verify Silver-owned implementation code in SPARK.
Lean 4 is additionally approved for machine-checked metatheory. These boundaries
are assumptions about existing external tools and libraries, not permission to
introduce unverified Silver implementation bodies.

## Compiler implementation and runtime imports

All Silver-owned executable implementation is in the SPARK bodies under `src/`:
`silver`, `silver_profile`, `silver_platform`, `silver_reports`, and
`silver_numbers`. GNATprove checks those bodies, their specifications, and the
host-local generated `Silver_Build` SPARK specification. This specification
contains only constants selecting native tool and artifact paths. Two
additional SPARK specifications declare existing external entry points; neither
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
are infrastructure conditions; their failure is reported rather than treated as
a new Silver membership restriction.

## Audit of the boundary

`scripts/check_evidence.py` enumerates all Ada source units under `src/` and
`.silver/<host>/generated/`, requires fresh `.spark` reports, and checks each
owned entity. Full implementation entities
must have `all` SPARK coverage. Exactly the eleven imported functions/procedure
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
failed invocations, and source-suppressed diagnostics. It also checks the
GNATprove version family and recorded full flow/proof command.

Two optional limitation diagnostic codes are explicitly classified:
`contracts-recursive` and `numeric-variant`. The authoritative
[SPARK 16.1 proof-limitations documentation](../references/spark/16.1/docs/ug/en/source/proof_limitations.rst)
states that these constructs can be used safely. Their contracts or expression
bodies may be unavailable on recursive calls inside assertions, which removes
information available to the prover. The related obligations must still prove.
GNATprove marks these disabled-by-default notes as externally suppressed in
SARIF; the auditor permits that exact representation for these two codes and
counts them. It permits no source suppression or failed obligation through this
exception. The current compiler report contains twelve such notes.

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
default. The actual SPARK compiler uses the verified `Silver_Build` constants
and runs from the repository root. Its workspace contract requires the native
host prefix. Development Python only prepares and verifies this configuration;
the compiler's admission and compilation remain in SPARK.

Alire loads settings before processing its directory/configuration switches.
All invocations therefore start in the isolated context with
`ALIRE_SETTINGS_DIR` pinned and deprecated `ALR_CONFIG` removed. The SPARK
driver establishes that shell environment before invoking Alire; it cannot
migrate the checkout's old configuration during early startup. The calling
compiler process retains its repository-root working directory.

The Lean replay tree is private to the host and reads the authoritative `src/`
through a checked link. Generated source certificates, Lake artifacts, and
manifests are written there. Shared proof inputs are fingerprinted and must
remain unchanged throughout replay. Lean/Lake startup also receives explicit
native tool, sysroot, configuration, and cache paths; inherited Lean/Elan search
paths and tool selections cannot redirect it. Artifact restoration is disabled
for clean proof replay.

Alire 2.1.1 and Lean 4.34.1 downloads have pinned upstream SHA256 hashes for Linux
and macOS on ARM64 and x86-64. Alire checks the indexed binary origins for GNAT
16.1, GNATprove 16.1, and GPRbuild 26.0. The approved patch-level variation does
not remove the requirement to verify the implementation on each platform.

Linux ARM64 has passed the native checks locally. CI is prepared for
`ubuntu-24.04`, `ubuntu-24.04-arm`, `macos-15-intel`, and `macos-15` (ARM64).
The other platforms have not been run in this workspace, and no remote workflow
has been dispatched. Their OS/runtime ABI compatibility remains to be validated
by those native jobs. Under the Oracle, Linux is primary and native macOS
validation is independent; an unrun macOS job does not block completion of the
Linux milestone.
