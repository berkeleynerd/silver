# Silver

Silver is a subtractive profile of Ada/SPARK intended to make automatic Bronze
and Silver assurance a property of language membership. Developers write
ordinary Ada/SPARK source without contracts or proof annotations. The governing
requirements are in [oracle.md](oracle.md).

Before 1.0, Silver is one evolving language. We prioritize foundational
correctness, useful capabilities and a fast proof loop. Intentional language
changes are documented together with their proofs and examples; historical
language editions are not maintained. Independently addable release hardening
is deferred until needed. Additional proof tools must close a concrete coverage
or automatic-discharge gap; redundant verification is deferred until practical
use justifies it. See [the development policy](development.md).

The root documents provide the main review entry points:

- [oracle.md](oracle.md): governing requirements and assurance guarantees.
- [language.md](language.md): the currently admitted language.
- [roadmap.md](roadmap.md): proposed capabilities and their dependencies.
- [development.md](development.md): the workflow for admitting a capability.
- [AGENTS.md](AGENTS.md): context and working rules for agent sessions.
- [RESUME.md](RESUME.md): local recovery guidance and historical handoff records.

Migration restored local evidence, caches and toolchains into the ignored
`.silver/` and `.tools/` directories used by development. After verified recovery,
the temporary non-dot `silver/` and `tools/` archive directories were removed
from the current tree and, at the owner's request, from Git history. Fresh clones
no longer download those migration archives. Preserve the live dot directories
or a separate backup for future recovery; Git no longer supplies them. See the
[handoff](RESUME.md#recover-and-preserve-the-old-vm-evidence) for migration and
existing-clone guidance.

The compiler admits, proves, builds, and runs this program shape:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Hello, world!");
end Main;
```

ASCII letter case, permitted whitespace, and comments may vary. Source is limited
to 4096 bytes, including comments. Whitespace is space, horizontal tab, carriage
return, or line feed. Comments begin with `--`, end at carriage return, line feed,
or EOF, and contain printable ASCII or horizontal tabs. Word tokens retain their
Ada lexical boundaries. Literal contents preserve case, may be empty, and may
contain any printable ASCII character, with quotes doubled as in Ada.
The original [null program](samples/null.adb) and a
[named string constant](samples/string_constant.adb) are also supported. The
[command-line sample](samples/command_line.adb) initializes that constant from
`Silver_Arguments.First_Or_Default` and uses a validity guard before printing it.
The current language also admits other path predicates that establish valid
input and reject every invalid input without output.
The [greeting sample](samples/greeting.adb) adds a literal prefix and suffix to a
literal-initialized constant using `"Hello, " & Name & "!"`.
The [command-line greeting](samples/command_line_greeting.adb) combines that
expression with command-line initialization and an explicit remaining-capacity
guard, `Name'Length <= 4088` for these decorations.
The [Names and Calls sample](samples/names_calls.adb) writes the same greeting
with grouped `with`/`use` clauses, `First_Or_Default (Default => "world")` and
`Put_Line (Item => ...)`. Its [completed checkpoint](docs/names-and-calls.md)
records validation of these context and call alternatives.
The [assignment sample](samples/string_assignment.adb) initializes a variable
with `"Hello"`, assigns the equal-length literal `"World"`, then prints it.

The [branching sample](samples/input_branching.adb) compares a validated argument
with `"verbose"`, choosing between two literal responses. Equality compares exact
decoded bytes and preserves case. Each valid-input execution makes one terminal
output call. Its completed assurance and Linux validation are recorded in
[input-branching.md](docs/input-branching.md).

The completed [shared-binding increment](docs/shared-bindings.md) replaces fixed declaration slots with ordered initialized String
constants and mutable objects. Initializers may copy earlier names, capturing
that value immediately. Assignment preserves the target's fixed length, including
symbolic argument-length copies, and self-copy is legal. The
[shared-bindings sample](samples/shared_bindings.adb) prints the old snapshot beside
the updated value.

The [common-expression increment](docs/common-expressions.md) shares literals,
initialized names, concatenation and parentheses across declarations, assignments,
comparisons and output. Repeated argument references are allowed when the guard
bounds every intermediate value to 4096 bytes. The [Larger Expressions milestone](docs/larger-expressions.md)
extended the then-current String-expression budget to sixty-four leaves per
expression and sixty-three concatenations per program. The current shared
budget also counts scalar operators as [language.md](language.md) specifies. The
[release-report sample](samples/release_report.adb) formats nine fields in one
18-leaf expression, with an explicit argument-length guard.

The completed [statement-sequencing increment](docs/statement-sequencing.md)
replaces fixed bodies with finite sequences of null, compatible
assignments, output and String-equality choices. The [conditional increment](docs/branches.md) adds nested statement sequences,
`elsif` arms and optional `else`, followed by bounded predicates and
path-sensitive composition. Its combined Linux checkpoint records the source,
proof, test and cache scope.
There is no separate statement/output-count cap. The
[sequencing sample](samples/statement_sequence.adb) combines a snapshot, updates,
repeated output and two choices. The new
[conditional sample](samples/conditional_statements.adb) exercises nested and
alternative arms. The [path-guard sample](samples/path_guards.adb) adds String inequality, length
comparisons, short-circuit predicates, based integer literals and an assignment
justified by an exact-length branch. Path facts bound each expression and ensure
every invalid-input execution rejects without output. Reject returns, so later
statements still need their own safety facts. These additions complete the
5a–5c milestone. See [language.md](language.md) for exact rules.

The completed [For loops and integers milestone](docs/for-loops-integers.md)
adds immutable signed-32-bit Integer constants, fully grouped arithmetic and
comparisons, scoped forward/reverse loops and standard `Integer'Image`,
including Ada's leading space. These compose with the String, input, path and
output rules above. The [completed review remediation](docs/review-b8f1d0b9a8-repairs.md)
records the implementation corrections and their separate validation.

The completed [Bounded mutable integers extension](docs/bounded-mutable-integers.md)
adds initialized mutable Integer objects, optional object-local static ranges on
constants or variables, and range-preserving assignments. Declaration snapshots
remain exact; initial body reads use each mutable object's full declared range.
Loop bounds capture their entry values, and writes persist after the loop.

The [interval-checked division increment](docs/integer-division.md) adds fully
grouped `/`, `mod` and `rem` in those scalar-expression positions. Division
truncates toward zero; `mod` follows the divisor sign and `rem` the dividend sign.
Incoming intervals must exclude zero divisors and quotient overflow, with exact
singleton initialization and interval analysis. Seven
sample approaches exercise the fragment, including the fixed Josephus (41,3)
incident. The capability record retains complete native and Lean assurance,
full-suite results and the successful focused certificate-parity repair.

The prepared [scalar guard increment](docs/scalar-guard-refinement.md) narrows
bare mutable Integer names and loop indexes against static thresholds. Assignments
replace current read intervals, branches join by hull, and loops capture entry
bounds before widening mutable facts at body entry and possible execution exits.
It adds the complete [100 doors sample](samples/rosetta_100_doors.adb), with
expected output derived independently by toggling each door on every pass.
No new grammar is added; complete assurance and validation remain pending.

The [Find square difference sample](samples/find_square_difference.adb) stores
the first matching index and prints ` 501` followed by a newline.

Small source files can still be expensive to compile. In a Linux review, a
4096-byte program with 800 assignments took **36.4 minutes and 8.89 GiB peak
process-group memory**, producing a 1,734,274-byte Main report within the historical 2 MiB
buffer. A 4095-byte argument-input program with 769 assignments took **49.5 minutes
and 9.99 GiB**, producing a **1,983,843-byte** report with **113,309 bytes (5.4%)**
of headroom. Expression limits do not cap assignment-driven proof work. These
measurements are not worst-case bounds. A later review proved all 826 checks and
built a 4095-byte, 782-assignment argument-input specimen. Its 2,013,253-byte
report uses **96.0%** of the buffer, leaving **83,899 bytes (4.0%)**. The reviewer
reported **33.6 minutes and 6.1 GiB** while other probes ran; this is not a clean
performance benchmark or a universal report bound. See the
[original capacity follow-up](docs/statement-sequencing.md#external-review-and-capacity-follow-up)
and the [branch capacity assessment](docs/branches.md#bounded-5bc-capacity-assessment--2026-10-14).
The later [Names and Calls review specimen](docs/names-and-calls.md#dense-assignment-review-evidence)
fits 785 assignments: all 829 checks proved and its 2,020,723-byte report uses
96.4% of the buffer. The reviewer reported 32 minutes; that run was not repeated.
The [Larger Expressions dense probe](docs/larger-expressions.md#dense-composition-and-report-capacity)
combines 758 assignments and 63 concatenations in 4096 bytes. It proved in
53.6 minutes with 8.71 GiB sampled aggregate RSS; its 2,065,005-byte report leaves
32,147 bytes (1.5%) in the historical 2 MiB buffer. Review B1 subsequently found
a denser static-shell construction leaving only 0.28–0.29%, with timing-dependent
credits able to exceed that margin. See the
[capacity correction](docs/review-343c2f8-repairs.md#report-capacity-correction).
These measurements do not establish a whole-language report-size bound.

The [composed-result](samples/composed_result.adb) and
[copied-result](samples/copied_result.adb) samples remain admitted instances of
these shared rules. Their previous completed checkpoints are recorded in
[string-results.md](docs/string-results.md) and [copy-values.md](docs/copy-values.md).

Names bind without ASCII case distinctions. No argument selects the literal
default; one printable ASCII argument of up to 4096 bytes is preserved,
including an explicit empty argument. Extra arguments, unsupported bytes and
oversized input produce no output and status 1. Successful `Put_Line` output is the
selected message followed by LF and a successful flush. `Silver_IO.Put` writes
the same bounded expression without LF, then flushes, even for an empty value.
The [partial-output sample](samples/partial_output.adb) assembles a line across
several calls. A detected output
failure sets status 1 and returns; later calls still execute and cannot clear
that failure status. Partial output may remain. Blocking and host
failures have documented environmental limits.

The compiler is implemented in SPARK. Its authors may use full SPARK contracts
and proof annotations; Silver program authors do not supply them. Python scripts
provide setup, evidence auditing and tests. GNATprove verifies the compiler.
Lean connects the restricted recognizer source to the language model and the
runtime wrappers to their effect models. Every output shell selects a complete
application report policy: static, argument, assigned or selected result. Emitted
Main safety checks must all be proved range, length, scalar overflow or
nonzero-divisor checks under their selected policy. All output forms
precisely classify initializer advisories; assignment-bearing forms additionally
classify the exact unused-assignment advisory. All sequence policies classify
two exact statically known predicate advisories and four exact overwritten ghost-output
messages for each of Put and Put_Line.
Selected library reports
remain mandatory. Frontend elimination, faithful obligation generation and
pinned solver completion remain explicit tool premises.
Application authors supply no contracts or proof annotations. Every emitted
check and all selected library obligations must be proved before compilation.
The external tools, runtime, generated configuration, evidence tooling, and
source-semantics assumptions are listed in the
[trusted boundary](docs/trusted-boundary.md). Completion and semantic preservation
have explicit tool and operational premises; see
[the assurance argument](docs/assurance.md).

## Set up, verify, and build

The following development examples run from the repository root. Development
requires Python 3.11+ and native development libraries: libc development files
on Linux, or Xcode Command Line Tools on macOS. On Debian/Ubuntu, the required
native package is `libc6-dev`.

Use the validated **8 MiB process stack** configuration for the compiler on Linux
(`ulimit -s 8192` in a shell where that limit is permitted). Retained application
audit data uses a 16 MiB library-level buffer, and the auditor reads that buffer
without a report-sized stack copy. A streaming reader validates and omits only
unaudited proof-tree metadata; original reports remain on disk. The earlier
2 MiB stack allocation produced
`Storage_Error` with a 2 MiB stack even for the null and Hello World samples;
that historical result predates the [capacity repair](docs/report-capacity.md).
The recursive statement/predicate recognizer still uses the stack: a review's
deepest 4096-byte check needed about 3.6 MiB, and compiling its deepest parse
passed at 6 MiB but failed at 5.5 MiB. These observations do not establish a
universal exact minimum. Adequate memory and normal runtime
startup remain [environmental requirements](docs/trusted-boundary.md#trusted-computing-base).

```sh
python3 scripts/bootstrap.py
python3 scripts/dev.py prove
python3 scripts/dev.py build
python3 scripts/dev.py test
```

During editing, select focused tests and incremental proofs for the affected
behavior. Batch changes before expensive certificate rebuilds, and reserve the
complete validation checkpoint for stable capability inputs. See the
[validation cadence](development.md#proof-loop-and-validation); these examples
are not a checklist to repeat after every edit.

The same commands select the native OS and architecture on each machine. Host
keys are `linux-aarch64`, `linux-x86_64`, `macos-aarch64`, and `macos-x86_64`.
Tools, Alire settings/caches, generated configuration, compiler objects, program
workspaces, and proof evidence live beneath `.tools/<host>/` and
`.silver/<host>/`. Linux and macOS can use the same checkout without replacing
each other's installations or outputs. Existing flat-layout artifacts are
preserved. No mutable global platform selector or cleanup of another host is
needed. `python3 scripts/dev.py paths` displays the selected paths.
The wrapper supplies `SILVER_HOST`; invoking `silver.gpr` without that setting
fails instead of selecting a default output directory.

`dev.py prove` runs incremental flow/proof checking with GNATprove's native
filesystem result cache. It uses all detected cores by default; `--jobs N`
limits workers when memory or other work requires it. This is development
feedback, not a completed full-audit record. `dev.py prove --full` forces unit
analysis and runs the complete proof audit, while retaining native sessions and
solver-cache reuse. It does not demonstrate uncached proof performance.
`dev.py prove --cold` adds an optional full audit in a unique fresh output,
session and cache workspace. It preserves warm state and other hosts' artifacts;
custom `--subdirs` cannot be combined with `--cold`. The audit checks
unit/entity coverage, proof completion, individual obligations, skipped checks,
assumptions, diagnostics, and matching report formats. A completed provenance
record binds the selected host, source/configuration/script bytes, tool binaries,
and reports. A successful GNATprove process exit alone is insufficient. Reports
normally remain in `.silver/<host>/compiler/obj/gnatprove/`; a cold run prints its
separate evidence path. An incremental invocation
invalidates that directory's previous completed full-audit manifest. Ordinary
builds remain available without a proof gate or binary attestation.

Bootstrap installs Alire 2.1.1 with pinned upstream SHA256 hashes. Alire manages
GNAT 16.1, GNATprove 16.1, and GPRbuild 26.0; patch updates are permitted within
these common version families. The validated package releases are GNAT 16.1.0,
GNATprove 16.1.0, and GPRbuild 26.0.1. That GPRbuild package identifies its executable
as version 26.0.0. Downloads and generated files are ignored by Git.

## Use the compiler

On macOS, with Python 3.11+ and Xcode Command Line Tools installed, this helper
sets up the native toolchain, builds Silver, then proves, builds and runs Hello
World:

```sh
python3 scripts/run_macos.py
```

Pass a source path to run another application, for example
`python3 scripts/run_macos.py samples/null.adb`. The helper can be invoked by its
absolute path from any directory; explicit source paths are relative to the
caller. It reuses installed tools, keeps macOS artifacts separate from Linux,
and stops on the first failure. Application and selected-library verification
run through Silver; compiler-wide GNATprove and Lean audits use the separate
development workflow. Initial setup may download tools.

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue
"$silver_executable" check samples/hello_world.adb
"$silver_executable" compile samples/hello_world.adb
"$silver_executable" run samples/hello_world.adb
"$silver_executable" run samples/release_report.adb -- production
```

`check` decides membership without invoking a prover. `compile` first admits the
source, then creates a fresh private `.silver/<host>/program-XXXXXX/` workspace, proves
its byte-identical `main.adb` snapshot and selected library sources, checks their
proof reports, and builds those same snapshots. It prints the snapshot,
proof-report, and executable paths.
`run` additionally executes the resulting program. No annotations are inserted.

The Image proof adapter creates separate `imagews-XXXXXX` scratch directories
under the same host artifact root. Calls remove their own scratch after the
vendor process returns status 0; that status means process completion and may
accompany a result reporting failed proof obligations. Set
`SILVER_KEEP_IMAGE_WORKSPACES=1` to retain that scratch for diagnosis. Adapter
errors and nonzero vendor statuses retain scratch automatically.
Caller-supplied proof directories and historical workspaces are preserved.
A cleanup failure leaves remaining files and reports on stderr without
changing the native result. The original application model, proof report,
compile workspace and executable paths printed above are preserved.
Separate application arguments from the source path with `--`:

```sh
"$silver_executable" run samples/command_line.adb -- "Hello from the command line"
"$silver_executable" run samples/command_line.adb -- ""
```

Omit `--` and its arguments to use the program's default, or use a bare trailing
`--` to forward no arguments. Arguments after the separator retain their exact
bytes and boundaries, including empty strings, spaces and quotes. Silver invokes
the application directly through GNAT's process runtime; no shell interprets
those arguments. The application's existing input rules still apply. There is
no additional Silver argument-count or aggregate-byte cap; available memory and
OS process limits remain environmental premises. The printed executable can
also be run directly, avoiding another proof/build cycle for repeated executions.

The executable can be invoked from another working directory. Relative input
paths refer to that directory; tools and output workspaces stay anchored to the
installation recorded during bootstrap. Installation paths are shell-quoted,
and inherited GPR configuration/search-path overrides are removed before Alire
runs. Moving the installation requires bootstrap and rebuild. These controls do
not make the entire operating-system environment hermetic.

On the ordinary diagnostic path, exit status is 0 for success, 2 for excluded
source or incorrect CLI usage, and 3 for an infrastructure, verification,
compilation, or abnormal process result. After launching an application, `run`
preserves ordinary exit statuses 0 through 255 and reports a nonzero result as
`Execution returned status N.` Status 1 can mean a specified Reject, output
failure or failed launch: GNAT does not distinguish those cases here. Thus an
application's status may overlap driver error codes; the diagnostic gives context.
Resource exhaustion, signals and external
runtime exceptions can terminate outside that path; the low-stack experiment
returned status 1. Verification or compilation failure on an admitted program
is a toolchain or implementation defect; prover results never redefine membership.
See the [process boundary](docs/trusted-boundary.md#application-process-boundary)
for the runtime assumptions and status interpretation.

The [machine-readable catalogue](catalogue/silver.json) matches the parsed
JSON exported by the compiler; formatting and key order may differ. Recognition
and export share the null token and character rules. Output word selection and
construct metadata are explicit fields checked against the specification. It also
lists admitted constructs and operations, literal and argument domains,
and the two statement shells plus null. Structural metadata is written explicitly in
SPARK and reviewed with the specification. Tests
compare the exported JSON with the checked-in file. Regenerate it after an
intentional language change:

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue > catalogue/silver.json
```

## Proofs and platform evidence

The [current-language Rosetta sample record](docs/rosetta-supported-samples.md)
maps issue #9's 31 tasks to runnable regressions and explicit skips, and records
their Linux validation and independent review.

The [five finite Rosetta sample record](docs/rosetta-finite-samples.md) covers
the #226 follow-on using existing Integer, loop, assignment and Image rules.

The [Bounded mutable integers record](docs/bounded-mutable-integers.md) identifies
the integrated implementation, [independent review](docs/reviews/review-bounded-mutable-integers.md),
complete Linux native and Lean validation, and full-suite execution supplemented
by the focused generated-snapshot repair. The original failed snapshot checks
and passing affected recheck retain their separate scopes. Its
[capacity extension](docs/bounded-mutable-report-capacity.md) derives the mutable
fragment's retained-report envelope under the documented producer assumptions.

The [proof iteration controls](docs/proof-iteration.md) record managed runs,
workspace ownership, repeated-check reasons and recovery across long sessions,
with native Linux validation and review dispositions.

The [Run Arguments record](docs/run-arguments.md) covers direct argument forwarding,
status propagation, the verified driver and its Linux validation.

The completed [Larger Expressions record](docs/larger-expressions.md) gives the
expanded expression budget, composition/capacity measurements and Linux validation,
including the full-suite result and test-only correction/recheck.

The [solver-allowance adoption](docs/expression-headroom.md#production-adoption)
records the current 100,000-step application setting, refreshed native/Lean
evidence and focused driver/runtime validation. That change alone left language
limits unchanged; Larger Expressions is a separate admission change.

The [Admission Repairs checkpoint](docs/admission-repairs.md) records the current
assignment/literal rules, complete Linux native and Lean validation, stable
307-test run and one-time full code-generation pass over the available corpus.

The [Focused Source Checks record](docs/focused-source-checks.md) covers narrower
Lean dependencies, cache-invalidation controls and the complete Linux proof check.

The completed [Names and Calls checkpoint](docs/names-and-calls.md) records
context visibility, call resolution and named associations, including the exact
native, test-repair and cached Lean validation scope.
The completed conditional, predicate and path-sensitive work and its Linux
validation are recorded in [branches.md](docs/branches.md). Earlier sequencing,
shared-binding, expression and copy checkpoints retain their input scope in
their capability records.

The combined expression/result work and its validation are recorded in
[string-results.md](docs/string-results.md).

The completed input-dependent branching implementation and full assurance
checkpoint are recorded in [input-branching.md](docs/input-branching.md).

The fixed-length assignment increment is recorded in
[string-assignment.md](docs/string-assignment.md), including its exact report
policy and local validation scope.

Hello World baseline validation is recorded in
[the capability record](docs/hello-world.md); its Hello World follow-up evidence is in
[the review repairs](docs/hello-review-repairs.md). Named-string validation is
recorded in [the capability record](docs/named-strings.md).
Guarded command-line validation is recorded in
[the command-line capability record](docs/command-line.md).
The command-line proof/test maintenance and independently corroborated macOS baseline
results are in [the follow-up record](docs/command-line-review-repairs.md).
The subsequent concatenation capability and its native evidence are recorded in
[greeting.md](docs/greeting.md).
The bounded [source-certificate investigation](docs/certificate-performance.md)
found no validated improvement; the existing reconstruction remains in use.
Guarded dynamic concatenation and independent report-policy refinement are recorded in
[command-line-greeting.md](docs/command-line-greeting.md).
The Hello World baseline compiler audit passed with fresh cold state. An intermittent GNATprove
temporary-result JSON failure in warm runs remains unresolved; the record
distinguishes those failures from successful evidence.
Validation of the earlier incremental workflows is recorded in
[the proof workflow record](docs/proof-workflow.md); the earlier implementation
baseline is in [the review repair record](docs/review-repairs.md). Regression coverage includes
real proof/build/run cases, simulated tool failures, source changes, report-size
stress, foreign working directories, and simulated cross-host artifact routing.

Recursive report specifications use the narrow `Ghost => Static` assertion level
so GNAT erases their runtime evaluation while GNATprove still verifies every
report-checker obligation. Compiler assertion and overflow checking remain
enabled with `-gnata` and `-gnato`; the report input bound and executable checks
are unchanged. The validation record includes a deliberately false static
contract that GNATprove rejects.

Lean 4.34.1 is pinned for the language and compiler-correspondence proofs:

```sh
python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py
```

Lean installs in `.tools/<host>/lean`. Its proof workspace is
`.silver/<host>/proof`, with independent Lake objects, manifest, and generated
source certificates. Builds read the shared `proof/` files without changing them.
A per-host source link points directly to the authoritative `src/` directory.
Lean subprocesses use explicit native tool paths and isolated config/cache paths;
inherited Lean, Lake, and Elan overrides cannot select another installation.

For focused iteration, select a module and its dependencies:

```sh
python3 scripts/check_lean.py --target Silver.PredicateGrammar
```

Repeat `--target` for additional modules. The runner synchronizes inputs and
freshly audits the selected actual import closure. Its separate focused result
does not establish complete source correspondence. With no target, it builds
the whole project and audits complete module/axiom coverage, retaining Lake's
cache. `--replay` (also spelled `--full`) adds an optional independent kernel
recheck for toolchain/cache investigations or explicit audits; it requires the
whole project. `--provenance` adds detailed inventories to the concise result
and log. `--clean` discards this host's proof workspace without implying replay.
See the [proof workflow](development.md#proof-loop-and-validation) and
[focused-runner validation](docs/lean-iteration.md).

Each embedded recognizer, lexical-helper and selected runtime Ada file has its own binary
dependency: editing it invalidates its handwritten binding, certificate and
transitive importers. Unrelated certificates and source-independent models can
remain cached. The [compartmentalization record](docs/lean-compartmentalization.md)
tracks validation and measured costs. After runtime source edits, refresh
bootstrap and rebuild so embedded library bytes agree with the source; full
audits reject stale bindings. Once a
capability's inputs are stable, run its complete validation checkpoint:

```sh
python3 scripts/dev.py prove --full
python3 scripts/dev.py build
python3 scripts/dev.py test
python3 scripts/check_lean.py
```

The runner defaults both Lake workers and Lean threads per process to the CPUs
available to this process. `--workers N`
and `--threads N` override them independently; `0` selects the automatic count.
Use lower settings on shared or memory-constrained hosts. `--memory-mb N` sets
a periodically checked memory threshold for each Lean build/audit process,
not a combined host budget. See the
[concurrency measurements](docs/lean-concurrency.md) for the observed speedup
and RAM use. Generated certificates and the separate fresh kernel recheck still
have serial work. Caching and worker counts do not change required obligations.

The source bridge embeds the authoritative null/output recognizers and selected
runtime sources, checks restricted source bytes and declaration shapes, and interprets
typed expression and statement models. Its semantic scope is described in the
trusted boundary. Every mode audits its actual imported modules and every
declaration's transitive axioms. Routine checks trust the pinned local toolchain
and imported object cache; `--replay` adds a fresh `leanchecker` kernel check.
Only Lean's standard logical
foundations are allowed. The separate external-tool theorem proves completion
and preservation under its documented tool and operational contracts.

See [the assurance argument](docs/assurance.md) for the exact proved claims, and
[the trusted boundary](docs/trusted-boundary.md) for external symbols, ABI
assumptions, report-format assumptions, and supported execution conditions.

Validation runs locally at the owner's direction. GitHub Actions is disabled
repository-wide; the retained [workflow](.github/workflows/verify.yml) for Linux
x86-64/ARM64 and macOS x86-64/ARM64, including Lean checks, is dormant. Hosted
results are not required for this local workflow.

An independent native macOS ARM64 review of greeting commit `a73f85e` passed
the compiler audit, tests and full Lean/kernel
checks. Retained evidence was corroborated read-only on Linux; the
[greeting record](docs/greeting.md#external-review-and-native-macos-validation)
records the exact input, cache and platform scope. Earlier evidence
retains its actual input/platform scope in the linked capability records.
The subsequent [sixth-form external review](docs/command-line-greeting.md#external-review-disposition)
reported successful native macOS validation with no blocking findings. Its raw
records are not present here; obtaining or retaining macOS records is entirely
optional at the owner's direction. Linux is primary. The owner
has authorized publication to [berkeleynerd/silver](https://github.com/berkeleynerd/silver).
The historical validation predates the first hosted CI run; no x86-64 or AdaCore
GNAT Pro execution is claimed by those records. See
[host readiness](docs/host-readiness.md) for replacement-host validation, recovery
of the old hosts' local evidence and caches, and the owner's decision to validate
locally. The tested Ada compiler is Alire's GNAT-FSF distribution.
