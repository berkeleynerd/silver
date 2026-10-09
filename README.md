# Silver

Silver is a subtractive profile of Ada/SPARK intended to make automatic Bronze
and Silver assurance a property of language membership. Developers write
ordinary Ada/SPARK source without contracts or proof annotations. The governing
requirements are in [oracle.md](oracle.md).

Before 1.0, Silver is one evolving language. We prioritize foundational
correctness, useful capabilities and a fast proof loop. Intentional language
changes are documented together with their proofs and examples; historical
language editions are not maintained. Independently addable release hardening
is deferred until needed. See [the development policy](development.md).

The root documents provide the main review entry points:

- [oracle.md](oracle.md): governing requirements and assurance guarantees.
- [language.md](language.md): the currently admitted language.
- [roadmap.md](roadmap.md): proposed capabilities and their dependencies.
- [development.md](development.md): the workflow for admitting a capability.
- [AGENTS.md](AGENTS.md): context and working rules for agent sessions.

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
The original [null program](samples/null.adb) is also supported.

These are the two complete forms: one null statement without a context clause,
or one qualified literal-output call with `with Silver_IO;`. Variables, repeated
calls, concatenation and other APIs remain excluded. See [language.md](language.md)
for the exact rules. On detected failure the wrapper sets status 1 and returns;
the sole-call `Main` returns with that status. Normal output is the literal bytes followed by LF, with a
successful flush. Detected output failure exits unsuccessfully and may leave
partial output; blocking and host failures have documented environmental limits.

The compiler is implemented in SPARK. Its authors may use full SPARK contracts
and proof annotations; Silver program authors do not supply them. Python scripts
are development setup, evidence auditing, and tests. GNATprove verifies the
compiler implementation. Lean connects the restricted recognizer source to its
language model and the output wrapper to its effect model. Both application
forms have no caller obligations; the output library's nonempty obligations
must also be proved and checked before compilation.
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

```sh
python3 scripts/bootstrap.py
python3 scripts/dev.py prove
python3 scripts/dev.py build
python3 scripts/dev.py test
```

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
```

`check` decides membership without invoking a prover. `compile` first admits the
source, then creates a fresh private `.silver/<host>/program-XXXXXX/` workspace, proves
its byte-identical `main.adb` snapshot and selected library sources, checks their
proof reports, and builds those same snapshots. It prints the snapshot,
proof-report, and executable paths.
`run` additionally executes the resulting program. No annotations are inserted.

The executable can be invoked from another working directory. Relative input
paths refer to that directory; tools and output workspaces stay anchored to the
installation recorded during bootstrap. Installation paths are shell-quoted,
and inherited GPR configuration/search-path overrides are removed before Alire
runs. Moving the installation requires bootstrap and rebuild. These controls do
not make the entire operating-system environment hermetic.

Exit status is 0 for success, 2 for excluded source or incorrect CLI usage, and 3
for an infrastructure, verification, compilation, or execution failure. Verification or compilation failure on an admitted program is a toolchain or
implementation defect; prover results never redefine membership. Specified
application output failures are reported separately. The executable's own exit
status is distinct from the compiler CLI's status.

The [machine-readable catalogue](catalogue/silver.json) matches the parsed
JSON exported by the compiler; formatting and key order may differ. Recognition
and export share the null token and character rules. Output word selection and
construct metadata are explicit fields checked against the specification. It also lists admitted constructs, the output operation, literal domain,
and both permitted compositions. Structural metadata is written explicitly in
SPARK and reviewed with the specification. Tests
compare the exported JSON with the checked-in file. Regenerate it after an
intentional language change:

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue > catalogue/silver.json
```

## Proofs and platform evidence

Hello World baseline validation is recorded in
[the capability record](docs/hello-world.md); current follow-up evidence is in
[the review repairs](docs/hello-review-repairs.md).
Its compiler audit passed with fresh cold state. An intermittent GNATprove
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

Lean installs in `.tools/<host>/lean`. Its replay workspace is
`.silver/<host>/proof`, with independent Lake objects, manifest, and generated
source certificates. Builds read the shared `proof/` files without changing them.
A per-host source link points directly to the authoritative `src/` directory.
Lean subprocesses use explicit native tool paths and isolated config/cache paths;
inherited Lean, Lake, and Elan overrides cannot select another installation.

The default Lean check retains Lake's native build cache and freshly runs the
module/axiom audit even on a cache hit. `--full` adds the independent kernel
recheck; `--clean` also discards this host's proof workspace. The embedded
recognizer and output-library Ada files are dependencies
of the whole Silver Lean library: editing any of them invalidates that entire
library's cached build. After runtime source edits, refresh bootstrap and rebuild so embedded library
bytes agree with the source; full audits reject stale bindings. For a
capability-validation checkpoint, run:

```sh
python3 scripts/bootstrap.py
python3 scripts/dev.py prove --full
python3 scripts/dev.py build
python3 scripts/dev.py test
python3 scripts/check_lean.py --full
```

Lake schedules independent modules. Lean declaration checking defaults to one
thread per process as a conservative memory setting for large certificates;
`--threads N` lets developers tune it. This default has not been benchmarked
against higher thread counts. Caching and worker counts do not change the
required proof obligations.

The source bridge embeds the authoritative null/output recognizers and output
library, checks restricted source bytes and declaration shapes, and interprets
typed expression and statement models. Its semantic scope is described in the
trusted boundary. Every mode audits actual imported modules and every
declaration's transitive axioms; full validation also runs a fresh `leanchecker`
kernel check. Only Lean's standard logical
foundations are allowed. The separate external-tool theorem proves completion
and preservation under its documented tool and operational contracts.

See [the assurance argument](docs/assurance.md) for the exact proved claims, and
[the trusted boundary](docs/trusted-boundary.md) for external symbols, ABI
assumptions, report-format assumptions, and supported execution conditions.

[CI](.github/workflows/verify.yml) is configured for Linux x86-64/ARM64 and macOS
x86-64/ARM64, plus Lean checks. The independent macOS ARM64 review validated
`3fdda42`: warm/cold compiler audits, the suite, and full Lean/kernel checking
passed. Retained evidence was corroborated read-only from Linux; qualifications
are in the [capability record](docs/hello-world.md). The subsequent
[review repairs](docs/hello-review-repairs.md) have separate input/platform scope
and await independent native macOS validation. Linux is primary and macOS
validation is nonblocking under the Oracle. Work remains local; configured CI
has not run, and no x86-64 execution is claimed.
