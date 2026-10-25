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
and adds precisely classified constant-equality advisories. The completed
[sequencing revision](statement-sequencing.md) adds finite statement composition,
precise repeated-output advisories and the larger application report buffer.
The policies below include the completed predicate/path integration. The
[conditional delivery record](branches.md) distinguishes the earlier 5a evidence
from the combined 5a–5c Linux checkpoint and records the native/Lean cache and
test scope. Earlier evidence retains its original input scope.

## Trusted computing base

This table is the consolidated dependency boundary. Verification of calls and
data inside Silver does not verify an external tool's implementation or prove
that a configured pathname selects the intended executable.

| Component | What the assurance argument relies on | Controls and remaining scope |
| --- | --- | --- |
| GNAT 16.1 and its Ada runtime | Ada/SPARK frontend meaning, code generation, ABI, binder/startup behavior, runtime checks, and static-ghost erasure | Alire release origins and recorded binary identities; compiler builds retain `-gnata` and `-gnato`. GNAT and runtime bodies are external. |
| GNATprove 16.1, its translation/Why3 tools, and bundled CVC5, Z3, and Alt-Ergo | Sound flow analysis and solver results, faithful and complete obligation generation, accurate reported evidence, and pinned solver completion for every source schema accepted by Lean's endpoint-discharge checker | Fixed proof options, complete coverage audit, and tool/version hashes. Solver soundness and [bounded-fragment completion](assurance.md#automatic-completion-and-the-external-boundary) are explicit premises; Lean does not prove completion within 100,000 normalized steps and 1,000 MiB per prover process with sufficient environmental resources, and no completeness claim for arbitrary SPARK is made. |
| GPRbuild 26.0 and native build tools | Project interpretation, compilation/link commands, and successful artifacts | Native Alire selection and recorded identities. Assembler, linker, sysroot, and platform development tools remain external. |
| SPARKlib shipped with the selected GNATprove release | Sound ghost-container contracts and GNATprove's mathematical interpretation of unbounded integers and sequences | The report-projection model uses these only as Static ghost observations. The reviewed source-only project selects the pinned installation and keeps build objects under the native host's artifact directory. This is part of the GNATprove trust boundary, not new Silver-owned runtime code or a claim that Silver re-proves the vendor library. |
| Alire 2.1.1 and its release index | Dependency resolution, deployment, environment setup, and integrity of published packages | Pinned Alire archive SHA256 values, checked tool version families and origin hashes, host-specific settings/cache/toolchains. |
| OS, libc, and runtime services | Filesystem and process semantics, private workspace creation, resource allocation, command-line ABI, and exception behavior | Explicit imports and observed I/O contracts below. Stable files, sufficient resources, and functioning services are premises. Ordinary Ada I/O exceptions are not proved impossible. |
| Shell and inherited environment | `/bin/sh` interpretation behind `system` for proof/build tools, native utility discovery, dynamic loading, and SDK selection | Setup quotes fixed paths; the driver appends only a checked workspace suffix. Application arguments use direct runtime spawning. Alire/GPR overrides listed below are removed. Other state, including `PATH`, loader settings and macOS developer/SDK settings, remains trusted. |
| Python setup and generated `Silver_Build`/`Silver_Image_Config` | Correct installation anchoring, byte encoding, shell quoting, external command prefix and original Image support-tool selection | Generated declarations are included in SPARK verification and evidence hashes. Bootstrap and provenance check the private Image overlay and original vendor binding. External-tool selection is reviewed configuration, not a proved property of those tools. Python is not a runtime Silver dispatcher. |
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

The generated project explicitly names the first and only admitted Main with
`for Body ("Main") use "main.adb" at 1;`. This bypasses GPR2's heuristic source
discovery, whose LF-only comment reader mishandles Silver's admitted CR comment
terminator. Native compilation still reads the byte-identical author source.
The [indexed Main repair](indexed-main-discovery.md) records the relevant source
route, installed observations and exact artifact mapping. No external tool was
modified and no comment form was removed from the language.

GNAT always recognizes bracket wide-character encodings, including under other
character-encoding switches. A literal ending in `[` immediately before a
closing quote and an ASCII identifier character can therefore fail code generation.
Silver explicitly excludes that adjacency in its shared literal rule; whitespace,
comments and punctuation preserve the ordinary ASCII literal. This restriction
keeps the pinned frontend premise consistent with the admitted bytes.

The recorded Linux report-capacity checks used an 8 MiB process stack. `compile`
and `run` now use a 16 MiB library-level buffer for retained audit data. Their
one-based report slices take the auditor's direct path without a report-sized stack copy. The
generic non-one-based path retains a rebasing copy in a separate frame; the
driver does not use it. See the [capacity repair](report-capacity.md). The
recursive statement/predicate recognizer consumes stack even for `check`.
The review of `4503d17` measured 3,688 KiB for a 4096-byte source with 1,994
condition parentheses; its deepest compile failed at 5,632 KiB and passed at
6,144 KiB. These measurements include the existing assertions-enabled build;
they do not establish a universal exact minimum. The later
[mutable Integer review](reviews/review-b79b986403.md#optional-improvements)
measured a 143-loop source with the delivered environment records: recognition
failed with `Storage_Error` and exit 1 at a 4,200 KiB stack limit and passed at
4,600 KiB; an independent reviewer measured 4,411 KiB versus 3,196 KiB for a
pre-PR-shaped binary. This exceeds the earlier recognizer observation but
remains below 8 MiB. These are input/build-specific observations, not a proved
worst-case bound. Per-level environment-copy redesign and a new stack regression
remain deferred. The external
[sequencing review](reviews/review-9b99d52.md) observed `Storage_Error` and exit
status 1 with a 2 MiB stack before the report-storage repair. Such resource exceptions are
not currently mapped to the driver's normal infrastructure-error status 3.
Sufficient stack and memory are environmental premises; these observations do
not change language membership or establish automatic proof completion.

## Interval-checked Integer division boundary

The [division extension](integer-division.md) retains the existing tool pins,
source and operator budgets, runtime libraries and external solver premises.
Its [semantic/discharge chain](assurance.md#interval-checked-integer-division)
uses truncation toward zero for `/`, divisor-sign `mod` and dividend-sign `rem`.
The restricted Ada interpretation must assign those meanings to the actual
native helper expressions and frontend-generated application operations.
Minimum/-1 quotient overflow remains excluded; remainder by -1 is defined even
at minimum Integer. Zero-before-empty rejection is an explicit conservative
membership restriction, corroborated by successful vacuous frontend probes.

Faithful and complete pinned-tool obligation generation includes
`VC_DIVISION_CHECK` with the nonzero-divisor meaning, applicable static
elimination and the existing overflow channel. Every emitted record must still
be proved with complete selected-unit coverage and the checked provenance.
Accepting that spelling does not establish semantic validity or external solver
completion. The [feature-local envelope review](integer-division-report-capacity.md)
extends the retained Main bound to 15,421,440 bytes under the inherited producer
and frontend correspondence assumptions; report storage stays at 16,777,216.
This source-derived calculation introduces no binary-attestation claim and does
not resume deferred whole-language capacity work. The capability record marks
the complete native, source/Lean, sample and review checkpoint pending until
its actual evidence is recorded.

## Compiler implementation and runtime imports

All Silver-owned executable implementation is in the SPARK bodies under `src/`:
`silver`, both profile recognizers, lexical helpers, catalogue export, platform and library
snapshot helpers, both report checkers, decimal rendering, the Image model,
streaming files, theorem installer and adapter, `silver_io`, and `silver_arguments`.
GNATprove checks all bodies, their specifications, and the
host-local generated `Silver_Build`, `Silver_Image_Config` and `Silver_Library_Sources` SPARK
specifications. `Silver_Build`
contains absolute installation paths, shell-quoted paths, and the command prefix
used to invoke Alire. Verification checks their use as SPARK values; bootstrap's
choice of the installation and intended external tools remains reviewed
configuration. `Silver_Library_Sources` contains the exact selected runtime
source bytes, checked against the current installation by the audit.
The import-only SPARK specifications declare existing external
entry points; none has a Silver-owned implementation body.

| Binding in `silver_libc.ads` | Existing libc symbol | Purpose |
| --- | --- | --- |
| `C_Open` | `fopen` | Open a source, snapshot, project, or report in binary mode |
| `C_Get` | `fgetc` | Read a byte or EOF |
| `C_Put` | `fputc` | Write a byte |
| `C_Error` | `ferror` | Distinguish EOF from a read error |
| `C_Close` | `fclose` | Close a stream and detect close/write errors |
| `C_System` | `system` | Invoke the configured proof/build tools |
| `C_Mkdir` | `mkdir` | Create the `.silver` and native host parent directories |
| `C_Mkdtemp` | `mkdtemp` | Atomically create a unique private workspace |

| Binding in `silver_runtime.ads` | Existing GNAT runtime symbol | Contract relied upon |
| --- | --- | --- |
| `Argument_Count` | `ada__command_line__argument_count` | A nonnegative, stable argument count |
| `Argument` | `ada__command_line__argument` | Return the requested argument when its index is in range |
| `Set_Exit_Status` | `__gnat_set_exit_status` | Set the process exit status |

| Binding in `silver_process_runtime.ads` | Existing GNAT runtime symbol | Behavior relied upon |
| --- | --- | --- |
| `Spawn` | `system__os_lib__spawn__2` | Copy the argument values, spawn the named executable, wait and return the runtime's process result |
| `Free_List` | `system__strings__free__2` | Free each owned string and the argument list, then clear the caller's pointer |

| Binding in `silver_image_libc.ads` | Existing libc symbol | Behavior relied upon |
| --- | --- | --- |
| `C_Link` | `link` | Atomically create a hard link to the staged theorem on the same filesystem, without replacing an existing destination; zero reports success and -1 reports failure |

The two argument imports use the GNAT Ada calling convention, including its ABI
for an unconstrained `String` result. Exit-status and libc imports use the C
calling convention. The linked GNAT runtime must match the pinned compiler
family. The program imports the original runtime implementations; there are no
private C wrappers or invented implementations behind these declarations.
With assertion checking enabled, GNAT may generate a precondition-checking
wrapper for `Argument` from its imported declaration. A bodyless Silver interface
does not imply that its compiled object contains no code; this wrapper belongs
to the trusted compiler's contract expansion.

### Application process boundary

The process imports also use the GNAT Ada convention. Silver's pool-specific
access types must be ABI-compatible with `System.Strings`' access-all types for
unconstrained Strings and positive-indexed String-access arrays. Their default
heap allocation and runtime deallocation must also be compatible.
`Run_Application` allocates the list and each copied argument under SPARK
ownership rules and releases them through the existing
runtime operation; it introduces no Silver-owned unchecked-deallocation body.
The runtime copies values before its platform normalization. On the supported
Unix platforms, that operation must preserve every supplied argument byte and
boundary, including empty strings, whitespace, quotes and control bytes, without
shell interpretation. Native validation retains its actual host scope.

Immediately before `Spawn`, a Static assertion establishes exact equality
between each copied argument and the corresponding original runtime argument.
That assertion is a native SPARK obligation over the owned copy loop, not an
imported semantic assumption. The executable path is the previously checked
published path. OS argument strings cannot contain NUL; the copy loop also
checks for NUL and returns without spawning if it finds one. There is no
additional Silver command-buffer limit on this forwarding path.
Successful allocation, representable runtime
argument storage, and the OS argument/environment size and process limits remain
resource premises. Allocation exceptions may still escape the normal diagnostic
path, as with the existing compiler buffers.

The driver preserves returned statuses `0 .. 255`; other returned results map
to its infrastructure status 3. The runtime can report status 1 both for an
application exiting with 1 and for failure to execute the requested image.
Consequently the nonzero diagnostic reports the status without identifying
specified `Reject`, output failure or launch failure. Signals and other abnormal
process outcomes retain the runtime's result semantics; this is not a promise to
reproduce a child's terminating signal in the compiler process.

### Argument and I/O observations

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
Detected compiler infrastructure failures use the driver's failure status;
application process results follow the boundary above. Resource exhaustion
or external runtime exceptions can still terminate the process outside that
ordinary diagnostic path.

### Image proof adapter boundary

Applications invoke a private GNATprove overlay. Its copied vendor GNATprove
finds the compiled `Silver_Image_Adapter` at its normal `gnatwhy3` location;
other support entries retain the selected vendor paths. Compiler verification
uses the original vendor GNATprove directly. Bootstrap resolves both original
executables inside the native tools directory, rejects delegation back to the
adapter, and embeds the original `gnatwhy3` path and digest in
`Silver_Image_Config`. The provenance check recomputes the overlay and binding.
Genuine matching executables, stable installations, Alire's environment and
GNATprove's relative support-tool lookup remain external premises. The generated
digest is evidence of selected configuration, not a runtime binary attestation.

The adapter uses a distinct `.silver/<host>/imagews-XXXXXX/` namespace.
After the synchronous vendor call returns status 0, it removes only the
workspace created by that invocation, unless the exact inherited environment
value `SILVER_KEEP_IMAGE_WORKSPACES=1` requests retention. Both Unchanged and
Refine paths follow this rule. Status 0 means that the vendor process completed;
its result JSON may still report failed proof obligations. Set the retention
flag to keep scratch for diagnosing those results. Adapter errors and nonzero
vendor statuses retain their workspaces. The original application model and
proof report remain in the compile workspace. A caller-supplied proof directory and its theory, session
and publication files are never cleanup targets; when the adapter creates
its own proof directory inside the new workspace, those temporary files live
through the vendor call and may be removed with it afterward. Existing
historical workspaces are never selected for cleanup.

`Silver_Image_Runtime.Environment_Value` imports the existing GNAT
`Ada.Environment_Variables.Value (Name, Default)` through the Ada ABI symbol
`ada__environment_variables__value__2`. Its contract relies on the stable
inherited environment, the vendor's unconstrained-String return ABI and
ordinary allocation/runtime behavior. The adapter does not mutate the
environment; the reviewed pinned implementation is `a-envvar.adb:223–226`,
and the selected runtime exports that symbol. This is a runtime boundary,
not a new Silver-owned implementation body exempted from verification.

Before cleanup, the adapter rechecks the full fixed Image-workspace prefix,
NUL-free path and six alphanumeric suffix characters. Without a supplied proof
directory it invokes `/bin/rm` with the direct argument vector `-rf`, `--`,
and that exact new directory. With a supplied `--proof-dir`, it instead uses
nonrecursive `-fd`, `--`, the two exact adapter snapshot paths
(`original.gnat-json` and `refined.gnat-json`), and the new directory. The
last removal succeeds only if the directory is empty. This preserves supplied
proof artifacts even if the caller's path resolves inside, or to, the new
adapter workspace; a nonempty directory remains. No shell or wildcard
interprets a path. Normal filesystem semantics and absence of hostile
concurrent replacement remain external premises. Cleanup failure retains
remaining files and diagnostics on stderr without changing the completed
native result or its JSON stream.

Adapter failures emit a fixed step-specific JSON error with `internal: false`
and exit status 3. These diagnostics identify argument, workspace, snapshot,
proof-directory, theorem-installation, refinement or native-launch failures
without asking the vendor to classify them as internal compiler bugs. All
failure gates remain fail-closed; resource exceptions retain the general
runtime boundary above. The [remediation record](review-b8f1d0b9a8-repairs.md)
tracks the implementation and its separate validation.

The adapter relies on the following invocation contract of pinned
[spark2014 `42554fc241fc`](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0)
and [Why3 `9390baf120ef`](https://github.com/AdaCore/why3/tree/9390baf120ef260547dfa14f08e11c890b203d9c):

| Premise | Reviewed vendor source |
| --- | --- |
| The model filename ends in `.gnat-json` and is the last argument; the adapter's selected invocation path depends on that shape. | [`gnat2why-driver.adb:601`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-driver.adb#L601) chooses the suffix; [`1247`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-driver.adb#L1247) appends entity arguments and then the filename. |
| A GNATprove-supplied `--proof-dir` occurs before the final model argument and names the proof directory whose theories/sessions remain available for the vendor invocation. | [`configuration.adb:3236`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/gnatprove/configuration.adb#L3236) adds the directory; [`gnat_config.ml:729`](https://github.com/AdaCore/why3/blob/9390baf120ef260547dfa14f08e11c890b203d9c/src/gnat/gnat_config.ml#L729) derives session paths. The adapter supplies a private directory when none is given. |
| GNATprove resolves `gnatwhy3` from its installation support path, allowing the selected overlay to choose the adapter. | [`configuration.adb:3177`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/gnatprove/configuration.adb#L3177) names `gnatwhy3`; [`gnatprove.adb:908`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/gnatprove/gnatprove.adb#L908) prepends support paths; [`configuration.ads:261`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/gnatprove/configuration.ads#L261) derives them from the executable location; [`gnat2why-driver.adb:1224`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-driver.adb#L1224) resolves the command on PATH. |
| GNAT2Why consumes the captured structured result, rather than treating the child exit status alone as the result. | [`gnat2why-driver.adb:243`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-driver.adb#L243) ignores `Wait_Process`'s success flag and parses the result file. Adapter failures must therefore preserve the expected JSON error protocol. |

These are source-reviewed interface premises, not a binary-source attestation.
Recheck them when the vendor pin or invocation path changes.

The [producer/schema record](for-loops-image-schema.md) identifies the pinned
serialization and consumer field order. The selected-schema argument now
proves canonical determinism internally:
`JSON.Valid.encode_injective` establishes equal values from equal encodings
and independent validity witnesses for ASCII integral JSON.
`Valid.canonical_meaning_eq` then establishes equal semantic projections,
preserving decoded strings, ordered arrays and integer meaning. The proof
uses a terminating mathematical decoder, covers arrays and objects, and
retains valid signed integer token spelling, including negative zero. It
does not assert injectivity for arbitrary raw-number `Value` constructors.

The selected-schema and refinement endpoints require neither `JSON.ParserSound`
nor finite-template parsing success. This proof machinery is not a runtime
parser and establishes no native or external parser-correctness or
parsing-success result. The external consumer boundary is unchanged:
`ConsumerBoundary.InterpretedConsumer`, validity of the original typed context
and identity of the installed theory source remain required. Numeric fields
consumed as OCaml integers must still be representable, while arbitrary-precision
producer numbers retain their quoted-string representation. Matcher success,
selected template identity, insertion positions and the desired Image theorem
remain independently established premises or conclusions of the composition.
The [remediation record](review-b8f1d0b9a8-repairs.md#focused-proof-evidence)
identifies the implementation and focused checks separately from the original
delivery's external parser premise.

Completeness additionally requires a precise pinned-producer contract for all
admitted source forms: each selected Integer, String or Image theory has its
fixed normalized content whenever emitted; selected names occur at most once;
Image's Integer and String dependencies are present; and every admitted
Integer Image occurrence uses the reviewed size-12 translation. The contract
describes producer output without assuming scanner success, matcher state or
refinement.

Every admitted `Integer'Image (E)` in Main must also translate to
`Standard_String__Img.to_string (Standard__integer.attr__ATTRIBUTE_IMAGE E) 12`.
The pinned [Image translation](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-expr.adb#L20256)
passes `Max_Size_Of_Img_Attr`; its [integer size calculation](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/spark_atree-entities.adb#L593)
gives 12 for the pinned signed-32-bit Integer type. The scanner validates
selected theory templates, not every Main occurrence. This is a per-program
producer applicability premise for complete automatic discharge; recheck it
when the producer pin or admitted Image form changes. It does not assume
scanner success or the validity of the inserted theorem.

For bounded mutable integers, Image applicability closes under that same
producer contract through three evidence classes. The
[mutable source-route review](bounded-mutable-report-capacity.md#changed-routes)
shows that the explicit `Integer` prefix still selects the signed-32-bit,
size-12 translation; mutable values and anonymous constrained-object subtypes
change Main's context without changing the fixed selected library theories.
The [fixed-template and consumer review](for-loops-image-producer-review.md)
and Lean schema/refinement proofs establish the selected theory meanings.
Retained native models, focused compiles and all 22 delivery samples corroborate
the producer premises for their actual inputs. Native success is not universal
schema applicability, and fail-closed rejection alone does not establish
completeness. The per-program Main translation and original typed-context
premises above remain required. The restricted source interpretation gives the
adapter's `bodyEnvironment` evaluator its fixed model denotation. The native
full-array mapping contract and active-prefix projection are checked separately;
composing that projection directly into the adapter correspondence theorem is
the optional O5 follow-up, not a completed additional theorem. Equality of a
source pin alone is insufficient.
The [capability record](bounded-mutable-integers.md#assurance-boundaries)
separates this closure from the later B1/M1 repair checkpoint.

The complete source-route review below supplies these external properties;
generic well-typed JSON and faithful parsing do not imply them.
`ProducerSchemas.envelope`, `producer_finishes` and
`FilesSource.native_producer_finishes` derive successful initialized traversal
of the entire document and the appropriate `Finish` result. Absence of Image
alone does not establish acceptance: the scanner still checks any selected
Integer or String theory. Final combined validation is recorded in the
[capability checkpoint](for-loops-integers.md#stable-delivery-evidence).

The [complete producer review](for-loops-image-producer-review.md) records exact
constructor/template parity and the array-head argument across fixed vendor
sources as well as Main. Faithful serialization includes the intended Natural
occurrence-counter domain without wrap for the configured inputs. This is an
explicit frontend format/capacity premise: binary inspection found an unchecked
increment, so the source subtype is not a runtime enforcement proof. Stable
regular model-file length within the signed-64-bit filesystem representation
separately supplies the scanner's byte/depth room. No invented per-node sizing
theorem or additional membership limit is used.

`ImageModelRefinement` and `ImageRefinementEndpoint` derive scanner
normalization, complete selected schemas, original insertion offsets, exact
payloads, fresh node identities and recovery of every original byte.
`ImageModelTemplateValidity` provides finite valid-spelling evidence for all
three theories and both clone values. Numeric schema meanings use semantic
integer projection; the inserted clone has separately fixed exact lexemes.
`ImageModelConsumerBoundary`'s finite external interpretation applies to the
actual checked `Clone.substitutions` and the reviewed qualified primitives;
`ImageConsumerEndpoint.RefinedDocument.consumer_instance` joins the resulting
signature and Image assertion to the actual inserted occurrence. Neither
arbitrary raw numeric strings nor arbitrary trees with the same decoded role
rows are assumed to be accepted by the consumer. The
[delivery checkpoint](for-loops-integers.md#stable-delivery-evidence) records the
final input-specific audits and independent source/semantic review.

The reviewed producer serializes a `Natural` occurrence counter, whose maximum
on the selected hosts is 2147483647, rather than internal `Why_Node_Id` values.
The adapter checks that full input range and reserves 2147483648 through
2147483670 for its 23 nodes. The 64-bit OCaml consumer retains signed 63-bit
integers; all inserted values fit its 4611686018427387903 maximum. Complete
schema matching also fixes clone alias/import scope; ID freshness alone does
not establish name resolution or semantic validity. Faithful external typed
conversion, qualified-name resolution and predefined primitive meanings remain
part of the existing frontend/tool boundary, without exempting Silver-owned
source or transformations from verification.

The finite consumer composition must also interpret the actual clone/include
constructors, five substitutions, alias scopes and qualified names under the
[reviewed consumer routes](for-loops-image-producer-review.md#finite-consumer-constructor-and-name-interpretation).
Its primitive-meaning contract refers to those exact predefined symbols and
contains no Image assertion, matcher/adapter acceptance or proof-success fact.
Silver derives the returned signature's equality with the predefined signature
and then applies the independent size-12 theorem. A role decoder over fixed
syntax is only one input to that composition.

The adapter uses the same direct-spawn ABI and immutable argument vector as
`Run_Application`. Native Static loop invariants and the assertion immediately
before `Spawn` establish the exact forwarded vector: every original argument is
preserved except the final model pathname when refinement is selected. A
`--proof-dir` pair is appended only when the caller supplied no proof directory.
The selected original executable receives those arguments without a shell;
statuses 0 through 255 are propagated and other results become infrastructure
failure. Source review checks the option selection and call ordering separately
from those proved copy properties.

`Ensure_Theory`'s successful postcondition establishes a complete, closed read
of exactly `Silver_Image_Theory.Theory_Text`. Both successful source paths read
`Directory & "/_theories/silver_image.mlw"`. If installation is needed, the body
writes the complete constant into a private directory on that filesystem,
publishes with non-replacing `link`, and rereads the selected destination even
if another invocation published first. A conflicting theorem remains unchanged
and fails the byte comparison. The driver calls the native prover only after
successful installation and model refinement. The exact theory constant,
scanner and byte-splice have their own semantic/source correspondence; this
installer postcondition and driver ordering do not claim a general filesystem
or CLI theorem.

Reading those observations as the bytes subsequently consumed by GNATprove
requires faithful libc reads/writes/close/link, stable model and theorem files
after their successful checks, and sufficient resources. The unchanged-model
route preserves the original model argument under the same stable-file premise.
These are the existing physical filesystem and tool boundary, now applied to
the added proof artifact. They do not authorize modifying the author's source
or removing native obligations. The [Image record](for-loops-integers-image.md)
separates native probes and proof evidence from the milestone's complete audit.

## Literal-output boundary

The admitted `Silver_IO.Put` and `Silver_IO.Put_Line` wrappers are Silver-owned
SPARK. Their public `String` parameters have no precondition. An executable length guard handles
arguments exceeding 4096; membership bounds each admitted expression by counting
every literal and static-name occurrence, plus the current path's maximum length
for its dynamic occurrences. Every repeated reference contributes its length
independently. Assignments preserve the initialized object's fixed bounds on
every path that reaches them, including after earlier branch updates. GNATprove verifies the same runtime input bound for values selected by
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

Each byte write and `fflush(NULL)` result is checked. Put_Line also checks its
appended LF write; Put omits LF. Both flush even an empty Item. Success means
all reported success; completion means host-stream acceptance, not reader
consumption or durable storage. On any detected failure the wrapper calls the
ordinary status setter with 1 and returns immediately. It makes no further
output request within that call. Main continues with following statements and
calls, which do not reset an earlier failure status. Success leaves the current
status unchanged; GNAT initializes it to success. Standard GNAT startup,
finalization and status propagation are external assumptions; finalization may
flush buffered output. Partial output is possible, and the accepted-byte trace
need not equal physically visible output.

This replaces the earlier libc `exit` import, whose absent `Program_Exit`
contract incorrectly described process exit as noncompletion. The new import
performs a terminating status assignment (`Always_Terminates => True`). No
abrupt program exit is modeled or hidden, and application authors need no
program-exit annotation. Wrapper return alone does not imply output success.
Output calls can be followed by further statements and calls. The sequence
effect proof concatenates accepted bytes in call order and preserves failure
status across successful later calls. Reject may occur within argument-shell
sequences and branches; it sets failed status and returns, without ending the
path or justifying later unsafe operations. No failure is treated as successful
completion of the requested effect.

Physical effects rely on faithful statuses, initialized standard output, no
concurrent writers or stream rebinding, and ordinary GNAT finalization. Healthy
execution requires output capacity and external progress. The blocking `putchar`/`fflush` imports
and wrapper use `Always_Terminates => False`; a blocked device need not progress.
SIGPIPE or another environmental failure may terminate the process before a
call returns, so only detected failures have the specified status 1. Storage
exhaustion and external interruption remain outside verified source behavior.

The Lean model interprets completed external replies, ordered wrapper actions,
and ordinary `Main` completion. Each successful call contributes its bytes plus
LF; each failed call contributes a prefix and status 1. The whole sequence trace
need not be a prefix under failures. Physical delivery,
blocking and signals retain the premises above. See the
[Hello World repair record](hello-review-repairs.md), historical
[runtime experiment](hello-runtime-experiment.md) and
[assurance argument](assurance.md).

Common String expressions use the same wrapper and external imports. Every
initializer, assignment RHS, comparison operand and output has one through
sixty-four literal/name leaves, with parentheses and repeated dynamic references
allowed under its affine length bound.
Ada's predefined String `&` preserves operand byte order and associates to the
left unless parentheses specify another grouping; this does not prescribe operand
evaluation order. Each intermediate length
is bounded by the checked total. Literal/constant evaluation and ordinary
mutable/dynamic concatenation use the approved Ada/GNAT semantics, including
index bounds. The verified argument wrapper normalizes its returned lower bound
to one. Initialized objects and their copies retain fixed one-based bounds under
assignments whose exact lengths agree throughout their reachable path, including
length equality established by a predicate. Storage for intermediate values and
the trusted runtime
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
this normalization in owned SPARK; it is not an assumed bound on imported Strings.
The postcondition also establishes an empty result for invalid input. An invalid
default with no arguments likewise produces an internal empty String; source
membership ensures admitted defaults satisfy the library domain.

The path checker tracks invalid input separately, using its empty initializer
value. Every admitted invalid-input execution must call Reject and must make no
output call. A validity query or a positive selected-input length can exclude
that case from a path. Reject returns after setting status 1; following statements
remain subject to the same safety and no-output requirements. An explicitly
empty valid argument is still distinct and may produce one LF in an undecorated
output program under healthy conditions.

Length comparisons and short-circuit predicates establish each body expression's
reachable length interval. Decimal/based literals in 0..4096 and name Length
operands are admitted as specified in [language.md](../language.md); a numeric
exponent has a separate 4096 bound to limit frontend work. Every initializer
executes before these facts and must fit the full 4096-byte input domain. A body
expression's static length plus each dynamic occurrence's selected length must
fit 4096 on every path reaching it. Valid input may be rejected by the written
program, including a smaller capacity rule; this never truncates or silently
changes the library input domain. Runtime concatenation uses owned lower-bound
normalization and predefined String semantics, rather than assuming all operands
are compile-time constants.

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
ordinary status assignment, not libc process exit. The successful argument
branch may contain multiple output calls; their returning failures and progress
assumptions remain as specified above.

A launch with no executable-name slot (`argc = 0` and a non-null argv vector)
falls outside the startup premise: GNAT's runtime computes `argc - 1`, violating
the imported `Natural` result contract. The independent macOS review observed
status 1 and no output for that launch. This is a recorded observation outside
the contract, not a portable fail-closed guarantee or another admitted input
case. See the [review record](command-line-review-repairs.md).

The typed Lean wrapper model's whole-body rendering is checked against the
authoritative `Silver_Arguments` body, and the bridge checks the query,
postcondition and import declarations. The composed Main argument must connect
initialization, path predicates and selected output/assignment/rejection effects to this same
immutable-vector model. Interpreting the fixed library and Main nodes as Ada
still uses the reviewed frontend and GNAT premises. See the
[assurance argument](assurance.md#command-line-initialization-and-path-validity) and
[capability record](command-line.md).

## Audit of the boundary

`scripts/check_evidence.py` enumerates all Ada source units under `src/` and
`.silver/<host>/generated/`, requires fresh `.spark` reports, and checks each
owned entity. Full implementation entities must have `all` SPARK coverage.
The approved OS/runtime import declarations above may have `spec` coverage.
Their enclosing package declarations and any
flow/proof diagnostics are still audited; a package initialization error is not
waived because the package contains imports.

The auditor pins the complete imported declarations and contracts using SHA256
of their tokens, preserving quoted external names and excluding only comments
and whitespace outside strings. It also rejects a corresponding `.adb` body.
Changing a binding, contract, or external symbol therefore requires deliberate
review of this boundary and an updated pin. These pins protect the reviewed
interface; they are not proofs of the runtime implementations.

The report model and Image file observations instantiate the vendor's functional
infinite sequence for `Character`, with logical equality. The report instance
is inside a `Ghost => Static` package; `Silver_Image_Files.Bytes` is used by
Static observations and byte-splice contracts.
The auditor separately identifies the reviewed vendor entities and source
locations generated by that exact instance. Their `spec` coverage relies on
SPARKlib's contracts; every Silver-owned model, observation and proof helper
still requires `all` coverage. The instance shape is checked so this treatment
cannot silently extend to a different element type, equality or executable use.

GNATprove interprets the selected `SPARK.Big_Integers` operations as mathematical
integers, as documented in the
[pinned Big Numbers Library description](../references/spark/16.1/docs/ug/en/source/spark_libraries.rst).
The installed alias uses `Ada.Numerics.Big_Numbers.Big_Integers`. Its exact
`function Is_Valid is assumed to return True` diagnostic at the reviewed vendor
declarations records this tool premise. The evidence checker counts it separately
from proved checks, matches its JSON and SARIF representations, and restricts
dependency references to reviewed vendor operations. This is neither a proof of
the vendor implementation nor permission to assume a Silver-owned obligation.
Other validity messages, source suppressions and unproved checks remain rejected.

`Silver_Image_Files.Counts` instantiates the same vendor
`SPARK.Big_Integers.Signed_Conversions (Model.Byte_Count)` for Static byte-splice
observations and contracts. Its `To_Big_Integer` and `From_Big_Integer`
operations inherit the pinned vendor mathematical-integer interpretation; Silver
does not claim to prove their runtime bodies. The evidence classifier must check
the actual `Counts` source instance and type argument, then match the exact
qualified entity names and both declaration origins: `a-nbnbin.ads:82:16` and
`a-nbnbin.ads:85:16`, each instantiated at `silver_image_files.ads:16:4`.
Only these exact vendor operations receive the existing `spec` treatment;
`Counts` itself and all Silver-owned observations, helpers and bodies retain
`all` coverage and complete obligation/diagnostic checks. This documents
completeness of the existing SPARKlib classifier, not a new trust exception or
Oracle amendment. The missing classification found by the original native audit
is tracked in [#48](https://github.com/berkeleynerd/silver/issues/48), with its
repair and validation disposition in the
[delivery review](reviews/review-410ed2c.md#native-audit-findings-and-repaired-validation).

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

The working catalogue has null and two statement shells: static and argument
input. They share ordered declarations, bounded String expressions and nonempty
statement sequences. Identifier parsing excludes reserved/shadowing names and
binds complete names ignoring ASCII case. Argument-bearing shapes protect
`Silver_Arguments` for every declaration. Expression initializers evaluate
literals and earlier initialized bindings before body predicates. Constants and
mutable objects retain their own snapshots and fixed bounds. The native array's
341 entries follow from the source bound and twelve-byte minimum declaration,
without another language count limit. This is not a general verified Ada name
resolver.

Assignment requires exact length agreement with the target on every reachable
input under Ada RM 3.3.1/5.2. Equal static lengths, the same symbolic input length
or path-established equality can justify it. Constants cannot be targets.
Self-copy is legal, and the target need not occur in output. Current reads observe
the selected branch's store; earlier declaration copies remain unchanged by
later writes to their source. Dynamic aliases keep their initial length even
when their bytes change. Predefined String equality/inequality compares complete
initialized values and preserves case; unequal lengths compare unequal.

The original immutable argument initializer stays first and unique. Nested
conditionals, `elsif`, optional `else`, String/length predicates and short-circuit
logic feed a conservative path analysis. Valid lengths use an interval, invalid
input is tracked separately, and joins preserve facts true on all incoming paths.
Assignment preserves length facts; the analysis does not retain arbitrary mutable
byte equalities or disjoint length sets. Every invalid-input execution must
reject without output, including paths without an explicit validity query.
Reject is a returning status effect, so rejecting one arm cannot justify an
unsafe expression after a join. No new runtime operation or external dependency
is introduced. Context alternatives and extra initializer-call placements remain
later work. [branches.md](branches.md) tracks the final integrated checkpoint.

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
Null retains the original raw-file reader and its 262,144-byte recognizer limit;
its separate text policy is not applied to projected report bytes.

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
including its refinement contract. The executable checks and global
`-gnata`/`-gnato` switches are retained. Retained application audit data has a
16,777,216-byte capacity after the streaming projection; runtime reports retain
their separate 262,144-byte bound. The projection uses the producer's byte-oriented
JSON token grammar and trusts its encoding of raw non-ASCII string bytes;
it does not add a UTF-8 validator. A native
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
`Put` and `Put_Line` coverage, nonempty checks and a proved postcondition for
each operation, including when the application calls just one of them. The
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
emitted safety record must be proved/info `VC_RANGE_CHECK`, `VC_LENGTH_CHECK`,
`VC_OVERFLOW_CHECK` or `VC_DIVISION_CHECK`,
with prover completion, Main filename/entity and a positive location. Static
folding may leave no safety checks. Static/assigned report shapes contain Main
with neither, either or both of Put and Put_Line. Argument/selected shapes additionally
permit Main with First_Or_Default and Reject, independently including or omitting
Input_Is_Valid and each output operation, or Main
alone after producer elimination. A path can establish validity without a query;
a shell need not output. Each permitted entity set is checked exactly. Every dependency must name an approved entity and effects,
postcondition or absence-of-runtime-error claim.

All output kinds permit finite lists of exact `INEFFECTIVE` initializer advisories:
`initialization of "NAME" has no effect`, with the checked identifier grammar.
Only assigned/selected kinds additionally permit the exact `unused assignment`
message. All four kinds also permit the exact `INEFFECTIVE` message
`statement has no effect` and `DEAD_CODE` message `this statement is never reached`,
observed for statically known comparisons. Every allowed record requires warning severity, flow provenance, Main
filename/entity, positive locations and no suppression or justification. There
is no separate advisory-count cap. Initializers still establish bounds when
their bytes are unused; these messages do not waive safety checks. Legal names
such as `Dummy` or `Unused_Result` may make GNATprove omit a diagnostic.
Repeated-output advisories are restricted to the exact `INEFFECTIVE` message
`"NAME" is set by "OPERATION" but not used after the call`, where OPERATION is
`Put` or `Put_Line` and NAME is one of
`Written_Count`, `Flushed`, `Succeeded` or `Written_Bytes`. Other messages remain
rejected; all provenance and suppression checks also apply to these eight messages.

No-output sequences and static elimination can produce Main alone with or
without length/range/overflow/division checks or advisories. The checker retains
complete Main coverage, all emitted check requirements and approved dependency references.
The external producer premise, rather than accepting arbitrary entity omissions,
justifies this finite set of report shapes. The Python evidence helper applies
the same policies and cross-checks SARIF records and totals.

Automatic completion relies on faithful and complete range, length, overflow
and nonzero-divisor obligation generation and the accepted entity/advisory/check shapes. Applicable static
elimination remains a frontend premise, but elimination of every satisfied
assignment length check is no longer required: emitted length checks need their
own semantic/discharge argument and successful solver records. Matching fields
alone cannot establish that no obligation was omitted. An unexpected genuine
shape or unproved check for admitted source is an implementation/toolchain
defect, not permission to weaken membership or suppress obligations. Native
binding discovery corroborates these classes. The [branch record](branches.md)
retains the earlier String/path evidence; the
[scalar/loop/Image delivery record](for-loops-integers.md) tracks the extended
schemas, implementation and source-correspondence validation.

Application proof uses `-U --mode=all --report=all --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000 -j0
--no-loop-unrolling`. All output
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
composition argument must establish the generated range, exact-length and
overflow schemas for every permitted declaration, expression, assignment and
control-flow path, including scalar intermediate intervals, Integer Image length
and loop bounds, indexes and body composition. It does not prove that the bundled proof portfolio automatically
discharges every source schema accepted by Lean's endpoint-discharge checker.
Completion within the 100,000
normalized steps and 1,000 MiB per-prover-process memory cap, with sufficient
environmental resources, remains an explicit tool-contract premise. GNATprove
16.1 had already selected that cap for `--level=2 --memlimit=0`; the explicit
nonzero option preserves the effective policy and makes it testable. The pinned
Why3 runner enforces 1,048,576,000 bytes of address space per external prover on
Linux, not a bound on all concurrent proof processes or frontend/flow work.
GNATprove converts normalized steps to Why3 limits of 100,000 for Alt-Ergo,
3,515,000 for CVC5 and 80,450,000 for Z3. The
[policy repair record](proof-policy-repairs.md) records actual limits and the
64-leaf regression. The review found Alt-Ergo out of memory on an admitted goal;
Z3 proved every measured hard goal within the cap. No universal memory headroom
or success of every selected solver is established. The bound of
sixty-four leaves limits each expression to sixty-three concatenations. A separate
sixty-three-operator source budget includes initializers, predicate operands and all
body arms, allowing one maximal expression or that total spread across positions.
The [larger-expression record](larger-expressions.md) gives the composition and
capacity evidence and its limits. Proof cost can differ
by expression position. [Sequencing probes](statement-sequencing.md) produced
314,746-byte and 469,246-byte Main reports within the source/operator limits,
exceeding the previous application buffer. Retained application audit data now
has a 16 MiB domain; retained runtime data stays within 262,144 bytes. The
[capacity repair](report-capacity.md) derives their envelopes from current
source and producer fields. A streaming reader validates the complete JSON
and replaces only immediate `check_tree` values in flow/proof records, removing
the dependency on unbounded unsuccessful-solver reason text. Original evidence
stays unchanged. Faithful complete producer structure remains a tool premise;
the derivation is neither a solver-time bound nor a Lean JSON-size theorem.
The following measurements used the historical 2 MiB raw-report capacity.
The initial dense 800-assignment run was externally stopped
before report generation; the external review subsequently completed that static
case within the application report buffer. The subsequent 769-assignment
argument-input case also completed, using 94.6% of that buffer with 5.4% headroom.
Their measured translation cost and memory use, and an admitted but uncompiled
771-assignment variant, are recorded in the [sequencing record](statement-sequencing.md).
The later review of `4503d17` proved and built the 782-assignment specimen:
826 checks, a 2,013,253-byte Main report (96.0% of the buffer), and 83,899 bytes
(4.0%) remaining. The reviewer reported 33.6 minutes and 6.1 GiB while other
probes ran; the [branch record](branches.md#bounded-5bc-capacity-assessment--2026-10-14)
distinguishes the corroborated source/report from those reported measurements.
The [Names and Calls review specimen](names-and-calls.md#dense-assignment-review-evidence)
fits 785 assignments in 4092 bytes and proved 829 checks, with a 2,020,723-byte
Main report (96.4%) leaving 76,429 bytes. Its 32-minute timing is reviewer-reported.
The [Larger Expressions dense probe](larger-expressions.md#dense-composition-and-report-capacity)
combines 758 assignments and 63 concatenations in 4096 bytes. All 865 checks
proved in 53.6 minutes, with 8.71 GiB sampled aggregate RSS. Its 2,065,005-byte
Main report left 32,147 bytes (1.5%) of the historical 2 MiB buffer. A separate
runner applied the production report policies; full code generation and expected
Reject executions passed. Review B1 found a denser static-shell construction
leaving only 0.28–0.29%, with timing-dependent credits able to exceed that margin.
The [capacity correction](review-343c2f8-repairs.md#report-capacity-correction)
records the deterministic floor and measured contribution; the specimen does not
justify whole-language report capacity.
None of these cases establishes a universal worst-case bound. An interrupted
experiment establishes neither solver failure nor measured capacity. No statement/output-count
restriction is inferred from those interruptions.
Native boundary experiments
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

Handwritten modules fix the source bindings for the actual recognizer
specifications/bodies, lexical and context/name helpers, bounded and scalar
integer literals, scalar expressions, length intervals, path facts, Image theory,
scanner, templates and file transformation, and the six selected runtime library
files. The `Silver.AuthoritativeSource` facade imports
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
bound and comment introducer with the output profile. Composed expressions, predicate/body scanners and shell recognition remain in
the output recognizer; bounded numeral and path arithmetic live in their checked
helper units. `Silver_Names` reads context clauses and resolves only the existing
packages and operations. Its unchanged lexical callees retain their established
meanings; checked expression trees and recursive uniqueness establish the new
helpers, while native proof connects executable loops to their contracts.
The composed checked-source record also proves `Names.fixedAt = Compose.fixedAt`
and `Names.take = Compose.fixedAfter`. These checked identities detect divergence
between duplicated helpers; they do not remove the lexical-callee interpretation
premise or derive arbitrary Names call records from source.
Named associations select the actual library formal (`Item` or `Default`); no
author-source rewriting is involved. Resolving these reviewed package
imports and declarations retains the existing Ada/GNAT interpretation premise;
the helper remains Silver-owned SPARK subject to complete native verification.

`SourceBridge.CheckedSource` combines the byte, token, declaration, expression,
catalogue and refinement checks. The recursive expression interpretation is
parameterized by its callees. Applying the recursive uniqueness lemmas connects
every interpretation satisfying the checked definition equations to membership.
The [review repair](common-expressions.md#external-review-of-9b72d36) supplied
the composed witness missing at `9b72d36`. Its helper equations remain reusable;
the obsolete fixed-shell equations are separate from the new scanner. The current
predicate interpretation combines independent concrete models for the integer,
path, condition, basic statement, recursive body and outer-shell equations.
`PredicateSourceChecks`, `PredicateSourceBridge` and `PredicateCorrespondence`
join their checked source definitions and executable refinements to recognition
and report-selector conclusions. The native models inhabit their range/progress
contracts as well as the raw equations. This establishes interface consistency;
arbitrary-callee correspondence still has the Ada/frontend interpretation premise
below. These equations are semantic interfaces, not project axioms or an
assumption that membership implies proof success.

For bounded mutable Integer objects, the native `Body_Environment` contract
preserves the active count and maps each fixed-array slot through `Body_Binding`.
GNATprove discharges that owned contract for the iterated array aggregate. The
typed binding update and full-array contract derive the active-prefix mapping used by the predicate
adapter: mutable bindings use declared ranges, while immutable snapshots and
name/staticness metadata are preserved. Interpreting the checked native
postcondition and record fields uses the existing Ada/frontend premise. The
mapping and its evaluator connection are proved, rather than assuming that an
arbitrary environment transform equals the model. The
[capability record](bounded-mutable-integers.md) tracks the extension's complete
source and native validation separately from its focused model checks.

In the `Form_Result` evaluator, normalization is interpreted as identity and
source-length/allowed-character checks use their specified meanings directly.
The renderer checks the native calls, but their denotations at this site remain
part of the frontend interpretation premise rather than being routed through
arbitrary lexical-callee projections. Concrete witnesses establish consistency
of those meanings; they do not verify the physical Ada frontend.

Lean functions are total even outside the checked native domains. Their
out-of-domain totalizations are modeling artifacts, not equivalence claims for
arbitrary Ada executions. The interpretation preserves actual values inside the
native domains. Source contracts, machine types and GNATprove establish that
every executed helper call stays inside them. Neither a concrete witness nor a
totalized value replaces those domain obligations.

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
signatures. The predicate language proof connects shared expressions and declarations
to ordered statements, short-circuit conditions, recursive choices, path-sensitive
fixed-bound preservation and cumulative returning-call effects. Its source bridge
checks actual helper and scanner bodies, token sequences, identifier roles and
acceptance/report selectors against those models. The retained `OutputSourceBridge`, `NamedSourceBridge`,
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
path-justified fixed-length assignment and conservative branch joins preserve
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
through a checked link. The generated source-certificate modules, Lake artifacts
and manifests are written there; the final audit records the actual imported
scope for its exact inputs. Shared proof inputs are fingerprinted
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
additional standalone recheck. Each embedded Ada source file is a binary input
dependency of its own handwritten binding
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
candidate modules enumerated in [the Lean runner](../scripts/check_lean.py) may
be regenerated. After generation and
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
