# Trusted boundary and verification evidence

The Oracle explicitly places GNAT, GNATprove, Alire, and OS/runtime libraries
outside the requirement to verify Silver-owned implementation code in SPARK.
Lean 4 is additionally approved for machine-checked metatheory. These boundaries
are assumptions about existing external tools and libraries, not permission to
introduce unverified Silver implementation bodies.

The completed [composed-String increment](string-results.md) generalizes output
expressions and adds branch-selected results. Its complete Linux checkpoint
passed with cache reuse and a fresh axiom/coverage audit, without optional
independent kernel replay. The completed [Copy String Values](copy-values.md)
extension passed its full physical Linux native/Lean checkpoint with cache reuse
and a fresh axiom/coverage audit, without optional independent replay. Its
literal-backed constants and fixed-length copies use the existing boundary
described here, without a new runtime operation or trusted dependency. The previous completed
[input-dependent branching](input-branching.md) evidence remains scoped to its
recorded inputs. The [source partition](lean-compartmentalization.md) and
[focused-runner workflow](lean-iteration.md) retain the pinned local tool/cache
trust and complete default audit, with optional separate replay/provenance.

The authorized [shared-bindings revision](shared-bindings.md) uses the same
external dependencies, with explicit range/length obligation channels and
precisely expanded Main advisory handling. Its complete native/Lean checkpoint
has passed. The [common-expression revision](common-expressions.md) retains these dependencies
and adds precisely classified constant-equality advisories. Its record states
current validation status; the policies below describe its implementation.
Earlier evidence retains its original input scope.

## Trusted computing base

This table is the consolidated dependency boundary. Verification of calls and
data inside Silver does not verify an external tool's implementation or prove
that a configured pathname selects the intended executable.

| Component | What the assurance argument relies on | Controls and remaining scope |
| --- | --- | --- |
| GNAT 16.1 and its Ada runtime | Ada/SPARK frontend meaning, code generation, ABI, binder/startup behavior, runtime checks, and static-ghost erasure | Alire release origins and recorded binary identities; compiler builds retain `-gnata` and `-gnato`. GNAT and runtime bodies are external. |
| GNATprove 16.1, its translation/Why3 tools, and bundled CVC5, Z3, and Alt-Ergo | Sound flow analysis and solver results, faithful and complete obligation generation, accurate reported evidence, and pinned solver completion on the concrete bounded range/length fragment | Fixed proof options, complete coverage audit, and tool/version hashes. Solver soundness and [bounded-fragment completion](assurance.md#automatic-completion-and-the-external-boundary) are explicit premises; Lean does not prove the external solvers complete within 10,000 steps, and no completeness claim for arbitrary SPARK is made. |
| GPRbuild 26.0 and native build tools | Project interpretation, compilation/link commands, and successful artifacts | Native Alire selection and recorded identities. Assembler, linker, sysroot, and platform development tools remain external. |
| Alire 2.1.1 and its release index | Dependency resolution, deployment, environment setup, and integrity of published packages | Pinned Alire archive SHA256 values, checked tool version families and origin hashes, host-specific settings/cache/toolchains. |
| OS, libc, and runtime services | Filesystem and process semantics, private workspace creation, resource allocation, command-line ABI, and exception behavior | Explicit imports and observed I/O contracts below. Stable files, sufficient resources, and functioning services are premises. Ordinary Ada I/O exceptions are not proved impossible. |
| Shell and inherited environment | `/bin/sh` interpretation behind `system`, native utility discovery, dynamic loading, and SDK selection | Setup quotes fixed paths; the driver appends only a checked workspace suffix. Alire/GPR overrides listed below are removed. Other state, including `PATH`, loader settings and macOS developer/SDK settings, remains trusted. |
| Python setup and generated `Silver_Build` | Correct installation anchoring, byte encoding, shell quoting, and external command prefix | Generated declarations are included in SPARK verification and evidence hashes. External-tool selection is reviewed configuration, not a proved property of those tools. Python is not a runtime Silver dispatcher. |
| Python evidence and replay scripts | Honest collection, comparison, and reporting of inputs, tools, diagnostics and artifacts | Tests and content-bound results detect stale/mismatched evidence; detailed Lean provenance is optional. Scripts are trusted for evidence reporting; hashes do not authenticate against an actor who can rewrite both evidence and manifests. |
| Lean 4.34.1 kernel, local object cache and source embedding | Kernel checking, correctly built imported objects, source literals, and Lean's standard logical foundations | Handwritten authoritative bindings, candidate reconstruction checks, source dependencies and fresh actual-import/axiom audit. Separate `leanchecker` replay is optional for investigations and explicit audits. No project-specific axioms or unfinished proofs are permitted. |
| Restricted Ada-to-Lean semantic interpretation | Frontend meaning of the fixed fragment: predefined operators, indexing, evaluation, statement sequencing, branches, loops, returns and machine bounds | Whole-source byte/token/declaration checks constrain the input; GNATprove supplies executable refinement. This is not a verified general Ada parser or complete compiler-semantics theorem. |

The pinned frontend must accept every source line and lexical element fitting
Silver's 4096-byte source bound. Ada RM 2.2 requires support for only 200
characters and leaves the maximum implementation-defined; the vendored GNAT
reference's stated 255-character default does not describe the pinned tool's
observed capacity. Native boundary tests compile 4096-byte single-line programs
and their maximal admitted literals and identifiers. This is a frontend premise,
not a claim of portability to every conforming Ada compiler.

## Compiler implementation and runtime imports

All Silver-owned executable implementation is in the SPARK bodies under `src/`:
`silver`, both profile recognizers, lexical helpers, catalogue export, platform and library
snapshot helpers, both report checkers, decimal rendering, `silver_io`, and
`silver_arguments`.
GNATprove checks all bodies, their specifications, and the
host-local generated `Silver_Build` and `Silver_Library_Sources` SPARK
specifications. `Silver_Build`
contains absolute installation paths, shell-quoted paths, and the command prefix
used to invoke Alire. Verification checks their use as SPARK values; bootstrap's
choice of the installation and intended external tools remains reviewed
configuration. `Silver_Library_Sources` contains the exact selected runtime
source bytes, checked against the current installation by the audit.
Three additional SPARK specifications declare existing external
entry points; none has a Silver-owned implementation body.

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
With assertion checking enabled, GNAT may generate a precondition-checking
wrapper for `Argument` from its imported declaration. A bodyless Silver interface
does not imply that its compiled object contains no code; this wrapper belongs
to the trusted compiler's contract expansion.

The argument vector is modeled as immutable: neither the compiler nor an
admitted application calls the runtime operation that removes arguments, and
external mutation is excluded. Both pure argument queries observe that same
vector. Compiler exit status is an external abstract state, written through an
`Output` contract; the compiler's Main initializes it explicitly. Admitted
applications rely on GNAT startup's initial success status and use the returning
status setter on detected output failure or invalid input.
Normal startup supplies an executable-name slot in the argument vector
(`argc >= 1`); "no arguments" means no entries after that slot, so `argc = 1`.
This establishes the nonnegative count required by the imported contract.
The libc bindings conservatively share the existing, initialized
`Ada.Text_IO.File_System` abstract state with ordinary output. This records
external effects instead of silently assuming calls are pure. It does not prove
libc's filesystem, process, pointer, allocation, or termination behavior.

The SPARK file wrappers additionally record Static ghost observations beside their
actual libc calls. GNATprove establishes that a successful complete read returns
exactly the byte sequence observed from `fgetc`, followed by EOF and a successful
close. A successful write passes exactly the supplied bytes, in order, to
successful `fputc` calls and closes successfully. These contracts verify the
Silver-owned copy loops; interpreting those calls as file operations still uses
the documented semantics of the trusted libc functions. `Run` similarly records
the exact command passed to `system` and its returned status. Its postcondition
equates success with a zero status. The observations are verification state,
not additional imported assumptions.
Their dependent proof contracts and historical driver flags also use Static
erasure; real I/O, error handling and source/report gates remain executable.
GNATprove still checks those contracts, and global assertion/overflow checking
remains enabled. The [native I/O record](native-io-performance.md) describes the
change and its measured scope.

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

## Literal-output boundary

The admitted `Silver_IO.Put_Line` wrapper is Silver-owned SPARK. Its public
`String` parameter has no precondition. An executable length guard handles
arguments exceeding 4096; membership bounds each admitted expression by counting
every literal and static-name occurrence, plus the guarded capacity for its
dynamic occurrences. Every repeated reference contributes its length independently. Assignments preserve the initialized object's fixed bounds;
a selected result has equal-length assignments on both branches before common
output. GNATprove verifies the same runtime input bound for values selected by
`Silver_Arguments`. It verifies
initialization, arbitrary String lower bounds, byte-loop bounds and a
conditional success postcondition. Static observations record accepted bytes,
flush success and whether the entire requested effect succeeded. GNAT erases
this state and its assertions while GNATprove verifies all their obligations.

| Binding in `silver_output_libc.ads` | Existing symbol | Relied-upon behavior |
| --- | --- | --- |
| `Put_Byte` | libc `putchar` | Writes the supplied unsigned byte to C stdout and returns that byte on success; EOF reports failure. |
| `Flush` | libc `fflush` | A null pointer flushes open C output streams; zero reports success. |
| `Set_Exit_Status` | GNAT `__gnat_set_exit_status` | Stores the process status used when `Main` returns; returns normally without flushing or terminating the process. |

These C-convention imports use the conservative, initialized
`Ada.Text_IO.File_System` abstract state, conservatively grouping status
effects with output state. The compiler driver
separately models its own status through `Silver_Runtime.Exit_State`. Guarded
applications also select that interface for the argument queries, but their
reachable status-setting calls use only `Silver_Output_Libc.Set_Exit_Status`.
The two declarations therefore do not introduce two independent physical status
variables. `System.Null_Address` denotes the C null pointer on the
supported GNAT ABI. There are no new C implementations or SPARK-off wrappers.
The reviewed interface token shape is pinned by the audit and checked in Lean.

Each byte write, LF write and `fflush(NULL)` result is checked. Success means
all reported success; completion means host-stream acceptance, not reader
consumption or durable storage. On any detected failure the wrapper calls the
ordinary status setter with 1 and returns immediately. It makes no further
output request. The admitted `Main` then returns without resetting that status.
Success leaves GNAT's initial success status unchanged. Standard GNAT startup,
finalization and status propagation are external assumptions; finalization may
flush buffered output. Partial output is possible, and the accepted-byte trace
need not equal physically visible output.

This replaces the earlier libc `exit` import, whose absent `Program_Exit`
contract incorrectly described process exit as noncompletion. The new import
performs a terminating status assignment (`Always_Terminates => True`). No
abrupt program exit is modeled or hidden, and application authors need no
program-exit annotation. Wrapper return alone does not imply output success.
Every admitted output or input-rejection branch is terminal: no further
application operation follows its returning call. Any future composition with
following statements must revisit failure propagation explicitly.

Physical effects rely on faithful statuses, initialized standard output, no
concurrent writers or stream rebinding, and ordinary GNAT finalization. Healthy
execution requires output capacity and external progress. The blocking `putchar`/`fflush` imports
and wrapper use `Always_Terminates => False`; a blocked device need not progress.
SIGPIPE or another environmental failure may terminate the process before a
call returns, so only detected failures have the specified status 1. Storage
exhaustion and external interruption remain outside verified source behavior.

The Lean model interprets completed external replies, ordered wrapper actions,
and ordinary `Main` completion. Its success theorem gives the selected bytes plus LF;
its failure theorem gives status 1 and an accepted prefix. Physical delivery,
blocking and signals retain the premises above. See the
[Hello World repair record](hello-review-repairs.md), historical
[runtime experiment](hello-runtime-experiment.md) and
[assurance argument](assurance.md).

Common String expressions use the same wrapper and external imports. Every
initializer, assignment RHS, comparison operand and output has one through
sixteen literal/name leaves, with parentheses and repeated dynamic references
allowed under its affine length bound.
Ada's predefined String `&` preserves operand byte order and associates to the
left unless parentheses specify another grouping; this does not prescribe operand
evaluation order. Each intermediate length
is bounded by the checked total. Literal/constant evaluation and ordinary
mutable/dynamic concatenation use the approved Ada/GNAT semantics, including
index bounds. The verified argument wrapper normalizes its returned lower bound
to one. Initialized objects and their copies retain fixed one-based bounds under
assignments with equal static lengths or the same symbolic input length. Storage for intermediate values and the trusted runtime
remains environmental; a result-length bound is not a storage guarantee.

## Command-line boundary

`Silver_Arguments` is Silver-owned SPARK. Its pure
`Input_Is_Valid` and `First_Or_Default` functions observe the same immutable GNAT
argument vector. Zero arguments is valid and selects the literal default. One
argument is valid exactly when its length is at most 4096 bytes and every byte
is printable ASCII (32 through 126); an explicitly empty argument is valid and
remains empty. Extra arguments, unsupported bytes and oversized arguments are
invalid. There is no truncation or successful fallback for invalid input.

`First_Or_Default` has no caller precondition. Its executable guards and proved
postcondition ensure a bounded, printable result with lower bound 1 for every
default and input vector under the import contracts. Extended return objects
copy values into `String (1 .. Item'Length)`, preserving bytes. GNATprove proves
this normalization in owned SPARK; it is not an assumed bound on imported Strings. Invalid input, or an invalid default when
there are no arguments, produces an internal empty String. Admitted defaults always satisfy the required
domain by source membership, so the invalid-default case cannot occur in a
Silver application. The required validity guard ensures that an invalid input
never prints the internal empty result: its false branch calls `Reject`, which
sets status 1 through the existing returning setter, then Main returns without
application output. This is distinct from a valid empty argument, which prints
one LF in the undecorated form and succeeds under healthy output conditions.
An optional capacity clause tests the selected String before output evaluation
or the inner choice. Its canonical decimal value lies in 0 through 4096, and
each body expression's static length plus its dynamic occurrence count times
that capacity must fit 4096. Initializers execute before guards and must fit
with the full 4096-byte input domain. With no clause the assumed capacity is 4096. A tighter
safe bound is permitted, including zero. Any selected value exceeding the explicit
capacity is rejected with status 1 and no output, including an oversized default
on a launch without arguments. This is rejection at the source's executable
guard, never silent truncation or a changed input domain. The dynamic value may
occur repeatedly at any operand positions, subject to the complete affine bound. Runtime concatenation uses owned lower-bound
normalization and predefined String semantics, rather than an assumption that
all operands are compile-time constants.

The wrapper uses the existing `Silver_Runtime.Argument_Count` and `Argument`
imports above. Its count checks establish each argument-index precondition.
The immutable-vector premise makes their `Global => null` declarations
appropriate for both pure queries. Interpreting the returned String as the
exact process argument uses the existing GNAT unconstrained-String ABI and
runtime semantics. These are approved external implementations; no new import,
C implementation or SPARK-off wrapper was introduced for this capability.

GNAT retrieves the complete unconstrained String before Silver checks its
length. The 4096-byte language bound is not a bound on the runtime allocation
needed to retrieve an oversized argument. Adequate storage, normal startup and
faithful runtime calls remain environmental premises. `Reject` performs an
ordinary status assignment, not libc process exit. The command-line form adds
no output operations beyond its terminal `Put_Line` branch, whose failures and
progress assumptions remain as specified above.

A launch with no executable-name slot (`argc = 0` and a non-null argv vector)
falls outside the startup premise: GNAT's runtime computes `argc - 1`, violating
the imported `Natural` result contract. The independent macOS review observed
status 1 and no output for that launch. This is a recorded observation outside
the contract, not a portable fail-closed guarantee or another admitted input
case. See the [review record](command-line-review-repairs.md).

The typed Lean wrapper model's whole-body rendering is checked against the
authoritative `Silver_Arguments` body, and the bridge checks the query,
postcondition and import declarations. The composed Main argument must connect
initialization, the guard and the selected output/assignment path to this same
immutable-vector model. Interpreting the fixed library and Main nodes as Ada
still uses the reviewed frontend and GNAT premises. See the
[assurance argument](assurance.md#guarded-command-line-initialization) and
[capability record](command-line.md).

## Audit of the boundary

`scripts/check_evidence.py` enumerates all Ada source units under `src/` and
`.silver/<host>/generated/`, requires fresh `.spark` reports, and checks each
owned entity. Full implementation entities must have `all` SPARK coverage.
Exactly the fourteen imported functions/procedures
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
exception. The [workflow record](proof-workflow.md) preserves its baseline
counts; current capability validation is in [copy-values.md](copy-values.md).
Earlier evidence remains in [greeting.md](greeting.md), [command-line.md](command-line.md) and
[command-line-review-repairs.md](command-line-review-repairs.md).

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

The working catalogue has null and eight concrete output body/capacity shapes.
Five executable arrangements share ordered declarations and one bounded String
expression grammar; three argument arrangements have optional capacity clauses.
Identifier parsing excludes reserved/shadowing names and binds complete names
ignoring ASCII case. Argument-bearing shapes protect `Silver_Arguments` for every
declaration. Expression initializers evaluate literals and earlier initialized
bindings before any body guard. Constants and mutable objects retain their own
snapshots and fixed bounds. The
native array's 341 entries follow from the source bound and the twelve-byte
minimum declaration, without another language count limit. This is not a general
verified Ada name resolver.

Equal static lengths or the same symbolic input length establish assignment
compatibility under Ada RM 3.3.1/5.2. The selected-result shape assigns the same
mutable target on either equality branch before common output. Constants cannot
be targets. Self-copy is legal, and the target need not occur in output. Current
reads observe the selected branch's store; earlier declaration copies remain
unchanged by a later write to their source. Each static reference counts its
object's length, and every dynamic occurrence counts the original input or
its alias. Predefined String equality compares complete initialized values and
preserves case; unequal lengths compare false.

The original immutable argument initializer stays first and unique. General
sequencing, context-clause alternatives and additional
argument-call placements remain outside this milestone. Every expression
obeys its affine capacity bound. No new runtime operation or external
dependency is introduced; output/rejection calls remain terminal on their paths.

Every output composition selects the verified `Silver_IO` and
`Silver_Arguments` specifications/bodies and the `Silver_Output_Libc` and
`Silver_Runtime` interfaces. Their source
bytes are read from the explicitly configured checkout source directory,
compared with the exact expected bytes embedded in the compiler, then copied
to its private workspace and rechecked after capture, proof and build. Bootstrap
generates the bindings; compiler audits reject stale bindings and Lean checks
the authoritative files. Refresh bootstrap, rebuild and both audits after edits.
This assumes a compiler built from those audited inputs; binary attestation
remains deferred. The generated project explicitly selects only
`main.adb` and those six files, excluding caller-planted library replacements.
Null programs select no library files.

`Silver_Reports.Complete_Null_Proof` checks the GNATprove 16.1 `.spark` format for
completed proof progress, no stop reason, precisely one fully SPARK entity, and
empty flow, proof, skipped-proof, `Assume`, and warning/error lists. Zero checks
are expected for null alone on this driver route; entity coverage prevents
accepting an empty analysis merely because it has no failures. Every output
shell now uses the source-selected application policy described below.

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

For output, `Silver_Library_Reports.Complete_Runtime_Proof` additionally audits
all four library reports. It checks immediate required fields, completed analysis,
no skipped checks, `pragma Assume` or warnings; approved dependency predicates,
exact selected
entity coverage and each flow/proof record. The IO report requires package and
`Put_Line` coverage, nonempty checks and a proved `Put_Line` postcondition. The
Arguments report requires package, both queries, `Reject` and private
`Is_Message` coverage, nonempty checks and a proved `First_Or_Default`
postcondition. Both interface reports require full package coverage and
specification-only coverage for exactly their three imports each. Its bounded
scanner handles quoted/escaped strings
and nested metadata with a fixed stack, without executable recursion. It rejects
duplicate audited fields and malformed checked records. There is no fixed
historical obligation-count threshold.

GNATprove verifies scanner safety and equality of acceptance to the independent
Static ghost `Runtime_Report_Policy` and source-selected
`Application_Report_Policy`. The ghost
policies independently specify byte scanning, fields, array traversal, coverage,
assumptions and record acceptance. Their meaning as verification evidence uses
the reviewed pinned-producer format. Native tests exercise genuine reports and
mutations. This closes the owned policy-refinement gap, not the external
obligation-generation or report-provenance premise.
Unrecognized metadata is skipped within bounds. Neither checker authenticates
arbitrary JSON or replaces trusted GNATprove completeness and provenance.

`Complete_Application_Proof` takes an `Application_Kind` derived from the same
source grammar used for admission: static, argument, assigned or selected
output. Its independent ghost policy and executable traversal require completed
Main analysis, full Main coverage and no skipped/assumed/suppressed checks. Every
emitted safety record must be proved/info `VC_RANGE_CHECK` or `VC_LENGTH_CHECK`,
with prover completion, Main filename/entity and a positive location. Static
folding may leave no safety checks. Ordinary static/assigned reports contain
Main and Put_Line; argument/selected reports contain Main and the four argument/
output callees. Every dependency must name an approved entity and effects,
postcondition or absence-of-runtime-error claim.

All output kinds permit finite lists of exact `INEFFECTIVE` initializer advisories:
`initialization of "NAME" has no effect`, with the checked identifier grammar.
Only assigned/selected kinds additionally permit the exact `unused assignment`
message. Argument/selected kinds also permit the exact `INEFFECTIVE` message
`statement has no effect` and `DEAD_CODE` message `this statement is never reached`,
observed for statically known comparisons. Every allowed record requires warning severity, flow provenance, Main
filename/entity, positive locations and no suppression or justification. There
is no separate advisory-count cap. Initializers still establish bounds when
their bytes are unused; these messages do not waive safety checks. Legal names
such as `Dummy` or `Unused_Result` may make GNATprove omit a diagnostic.
Repeated-output ghost advisories and other messages remain rejected.

GNAT may emit Main alone with empty safety/dependency lists. For static/argument
kinds that fallback additionally requires a nonempty route-permitted
advisory list; assigned/selected kinds also retain the earlier zero-advisory
allowance. Outside this exact fallback the complete callee set is mandatory.
The Python evidence helper applies the same policies and cross-checks SARIF
records and totals.

Automatic completion relies on faithful and complete range/length obligation
generation and the accepted entity/advisory/check shapes. Applicable static
elimination remains a frontend premise, but elimination of every satisfied
assignment length check is no longer required: emitted length checks need their
own semantic/discharge argument and successful solver records. Matching fields
alone cannot establish that no obligation was omitted. An unexpected genuine
shape or unproved check for admitted source is an implementation/toolchain
defect, not permission to weaken membership or suppress obligations. Native
binding discovery corroborates these classes; the [capability checkpoint](common-expressions.md)
includes implementation and source-correspondence validation.

Application proof uses `-U --mode=all --report=all --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --steps=10000 --timeout=0 --memlimit=0 -j0`. All output
routes use `--warnings=continue` to classify their exact permitted advisories
from complete reports; null retains `--warnings=error`. Unexpected audited
diagnostics prevent publication, and all selected library reports remain strict.
Successful tool termination and accepted content are separate requirements: a
warning can occur in `flow` with empty `warn_error`, including when
`--warnings=error` causes failing exit status. These checks do not claim that
the frontend emitted no compiler warnings.

The fixed library obligations are discharged on
every fresh application compile; application membership remains independent of
those results. Zero wall-clock timeout is not a guarantee against environmental
failure. Compiler development proofs have their separately documented cached,
wall-clock-limited configuration. The intermittent GNATprove JSON failure
seen in compiler audits has not been proved impossible for application runs.
Such a tool failure prevents publication and is reported as a defect, never as
nonmembership or successful verification. Prover step limits do not bound
frontend/flow work, operating-system delays or total elapsed time. The bounded
composition argument must establish the generated range and exact-length
schemas for every permitted declaration, expression, assignment and control-flow
path. It does not prove that the
bundled external solvers complete within 10,000 steps; that concrete pinned
fragment's completion remains an explicit tool-contract premise. The bound of
sixteen leaves limits each expression to fifteen concatenations. A separate
thirty-operator source budget includes initializers and both body branches,
retaining the earlier two-output operator-count ceiling. Proof cost can differ
by expression position. The source bound, these
resource policies and measured dense cases support the unchanged 262,144-byte
report capacity; faithful complete producer reports fitting that capacity remain
an explicit tool premise, not a consequence of a native sample or a solver-time
theorem. Larger diagnostic probes are not successful production proofs. Native boundary experiments
corroborate the argument; they do not establish a completeness premise for
arbitrary SPARK. See the [assurance argument](assurance.md) for the checkpoint's
current proof status and exact theorem boundaries.

The driver's proved contracts require source membership, exact source/project
write observations, matching source reads, the accepted report predicate, and
successful calls of the specified proof/build commands before publishing or
running an artifact. The corresponding external file and process effects rely
on the approved runtime/tool semantics. The conditional Lean toolchain theorem
and its exact scope are described in [the assurance argument](assurance.md);
these contracts do not constitute verification of libc or GNAT itself.

## Source correspondence and semantic assumptions

Twelve handwritten modules fix the source bindings for both actual recognizer
specifications/bodies, the `Silver_Output_Lexical` specification/body and the six
selected runtime library files. The `Silver.AuthoritativeSource` facade imports
all bindings; each certificate imports only its own binding. The certificate
generator emits candidate reconstruction data and cannot select replacement bindings. Lean
checks that every source byte, including comments and literals, belongs to
HT/LF/CR or printable ASCII. A checked-in complete token shape fixes declarations,
scopes, aspects and bodies, rejecting inserted operators/helpers, renamings, and
alternate literal spellings outside that reviewed shape.

The output bridge's complete source shape includes both lexical helper units.
Moved ghost expression and header checks refer to the helper specification;
ordinary helper-body checks refer to its implementation. The helper imports
`Silver_Profile` lexical primitives, and the bridge checks equality of its source
bound and comment introducer with the output profile. Composed expression and
shell recognition remain in the output recognizer. Resolving these reviewed package
imports and declarations retains the existing Ada/GNAT interpretation premise;
the helper remains Silver-owned SPARK subject to complete native verification.

`SourceBridge.CheckedSource` combines the byte, token, declaration, expression,
catalogue and refinement checks. The recursive expression interpretation is
parameterized by its callees. Applying the recursive uniqueness lemmas connects
every interpretation satisfying the checked definition equations to membership.
The [review repair](common-expressions.md#external-review-of-9b72d36) supplies the
composed witness missing at `9b72d36`: `Compose.Expressions.modelCalls` satisfies
the original helper equations, independently proved range contracts and legal
executed-call domains. `Compose.SourceBridge.model_interpreted` has no premises
and inhabits their combined interface. This establishes consistency of that
interface; correspondence for arbitrary actual callees still has the documented
Ada/frontend interpretation premise below. These equations are a semantic
interface, not project axioms or an assumption that membership implies proof
success.

The remaining interpretation premise is that approved Ada/GNAT frontend
semantics gives this fixed fragment its modeled predefined operators, indexing,
evaluation and machine bounds. For the runtime it also supplies statement
sequencing, conditional branches, element-order String iteration, local constant
initialization, early returns, predefined C integer comparisons, and Static
ghost erasure. The IO bridge
allows only fixed ghost actions and loop annotations and checks their Static
declarations plus the numeric output bound; it does not type-check arbitrary
Ada statements. The argument bridge renders its entire owned body without
ghost-erasure slots and checks the pure query contracts and existing GNAT import
signatures. The composed language proof connects the shared expression grammar,
ordered initialization/assignment/choice semantics and per-output weighted
length bounds. Its source bridge checks actual expression functions, form token
sequences, identifier roles and acceptance/report selectors against those
models. The retained `OutputSourceBridge`, `NamedSourceBridge`,
`ArgumentsSourceBridge` and `LexicalSourceBridge` supply lexical/runtime
correspondence; obsolete fixed-production suffix claims are removed when their
Ada functions are replaced. The preceding Compose String Results Linux checkpoint
validated that composition bridge and its whole-project axiom/module coverage.
The completed Copy String Values checkpoint validates that earlier bridge and
constant-read derivations with a fresh whole-project axiom/coverage audit. The
shared-binding source replaces slot-specific reads with ordered declaration and
store relations; its source interpretation and complete checkpoint passed, as
recorded in [the capability record](shared-bindings.md).

Ada interpretation supplies predefined String equality/concatenation, assignment
and the conditionally executed control flow. Source operand order determines
concatenated byte order without asserting an Ada operand evaluation order.
Literal decoding and case-insensitive binding remain exact. The argument runtime
models byte values and its SPARK contract establishes canonical lower bounds;
fixed-length assignment and the join of both selected-result branches preserve
initialized bounds. A separate model or matching token-shape pin alone does not
establish correspondence with the actual recognizer.
GNATprove establishes normalization, bounds and
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

The Lean proof tree is private to the host and reads the authoritative `src/`
through a checked link. Twelve generated source-certificate modules, Lake
artifacts and manifests are written there. Shared proof inputs are fingerprinted
and must remain unchanged throughout a run; tools and protected workspace
copies are also checked for stability. Routine evidence contains an aggregate
input digest, scope, modules, tool version and identities, timings and replay
status alongside the log. `--provenance` adds detailed input, workspace and artifact
inventories. The imported module inventory and transitive axiom audit come from
a fresh execution after every build, including cache hits. With no target, the
audit requires every project module. `--target` checks only the selected actual
import closure and writes separate partial evidence, not a complete
source-correspondence result.

Ordinary proof files use Lean's module system with their current computational
interfaces exposed. The complete audit, reusable audit helper and generated
focused audit driver deliberately retain legacy imports, which load transitive
private declarations. This preserves checks of unused private assumptions behind
ordinary module boundaries. A top-facade `import all` in a module audit alone
does not supply that coverage. The [migration record](lean-modules.md) documents
native proof-reuse, source-invalidation and private-axiom controls.

Local cached Lean objects rely on Lake's dependency tracking and the pinned
Lean toolchain; routine runs do not independently recheck imported objects.
The runner rejects direct `skipKernelTC`, `addDeclWithoutChecking` and
`addDeclCore` references in project proof sources/configuration and generated
candidates, except the audit's exact read-only option guard. It also checks
retained Lake traces for unsafe build arguments before reuse and after every
phase. Those traces retain weak arguments even when configuration is reverted.
Missing traces require Lake's normal rebuild. Source/configuration review and
honest local cache records remain assumptions: this policy is not a sandbox
for hostile metaprograms or forged artifacts.
`--replay` (also `--full`) adds a fresh independent whole-project kernel recheck
for toolchain/cache investigations or explicit audits. It cannot be combined
with `--target`. `--clean` discards the local proof workspace without implying
replay. The Oracle requires complete proofs and correspondence, not this
additional standalone recheck. Each of the twelve
embedded Ada files is a binary input dependency of its own handwritten binding
module, rehashed on each invocation. Changing one file invalidates that binding,
its certificate and transitive importers. Unrelated certificates and models can
remain cached; changes to their shared Lean dependencies still invalidate them.
Exact one-module libraries follow the umbrella library in the handwritten Lake
configuration so the pinned Lake version selects their specific ownership.
This cache boundary retains complete default audit coverage and optional replay.
Lean/Lake startup receives explicit native tool, sysroot, configuration, and cache paths;
inherited Lean/Elan search
paths and tool selections cannot redirect it. Artifact restoration is disabled
for proof checking; this does not disable the local Lake build cache.

The handwritten import facade is protected like other proof inputs; only the
twelve enumerated candidate modules may be regenerated. After generation and
again after checking, noncandidate workspace modules and
project/toolchain files must equal the captured shared bytes. Files and their
workspace parents may not be symlinks. A candidate generator therefore cannot
replace a handwritten binding or proof module while leaving only a self-consistent
workspace hash; candidate reconstruction remains separately checked by Lean.

Alire 2.1.1 and Lean 4.34.1 downloads have pinned upstream SHA256 hashes for Linux
and macOS on ARM64 and x86-64. Alire checks the indexed binary origins for GNAT
16.1, GNATprove 16.1, and GPRbuild 26.0. The approved patch-level variation does
not remove the requirement to verify the implementation on each platform.

Earlier Linux ARM64 implementation and workflow validation is retained in
[the repair record](review-repairs.md) and [the workflow record](proof-workflow.md).
The external native macOS ARM64 review of Hello World commit `3fdda42` passed
warm and cold compiler audits, tests, Lean replay, axiom audit, fresh kernel
recheck and application execution; its actual scope is recorded in
[the Hello World record](hello-world.md). That evidence covers the reviewed
baseline, not subsequent repairs or the named-string and argument capabilities.
Their original Linux evidence is recorded in
[the follow-up repair record](hello-review-repairs.md),
[named strings](named-strings.md) and [command-line messages](command-line.md).
The subsequent independent macOS ARM64 review validates command-line commit
`e14ba1a`, including its compiler audit, full test suite, Lean replay and fresh
kernel recheck. That retained evidence does not validate later changes.
The [command-line review repairs](command-line-review-repairs.md) record this
baseline and the follow-up validation scope. The newer concatenation increment's
validation belongs in [greeting.md](greeting.md). Its independent native macOS
ARM64 review validates implementation commit `a73f85e`; the retained inputs,
reports and Lean artifacts were corroborated read-only on Linux. This is a
full audit/replay with cache reuse, not a cold GNATprove or clean Lean run.
Those historical records do not cover x86-64 execution. A later
[external review](command-line-greeting.md#external-review-disposition) reports
native macOS validation of the guarded form and all-core Lean defaults. That
attributed report is distinct from the retained historical artifacts; its raw
records are unavailable here, and obtaining or corroborating them is entirely
optional. The owner has disabled
GitHub Actions repository-wide and directed local validation. The retained
[workflow](../.github/workflows/verify.yml) for `ubuntu-24.04`, `ubuntu-24.04-arm`,
`macos-15-intel`, and `macos-15` (ARM64) is dormant. Hosted results are not a
required follow-up. See [host readiness](host-readiness.md) for current native
validation, historical hosted activity and recovery of the old hosts' evidence
and caches. Under the
Oracle, Linux is primary and native macOS validation is independent and does not
block completion of the Linux milestone. Historical checkpoint files describe
their dated baseline, not the current validation state.
