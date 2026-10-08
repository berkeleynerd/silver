# Silver

Silver is a subtractive profile of Ada/SPARK intended to make automatic Bronze
and Silver assurance a property of language membership. Developers write
ordinary Ada/SPARK source without contracts or proof annotations. The governing
requirements are in [oracle.md](oracle.md).

The initial compiler admits, proves, builds, and runs this program shape:

```ada
procedure Main is
   pragma SPARK_Mode (On);
begin
   null;
end Main;
```

ASCII letter case, permitted whitespace, and comments may vary. Source is limited
to 4096 bytes, including comments. Whitespace is space, horizontal tab, carriage
return, or line feed. Comments begin with `--`, end at carriage return, line feed,
or EOF, and contain printable ASCII or horizontal tabs. Word tokens retain their
Ada lexical boundaries. All other constructs and compositions are excluded.

This first profile, `silver-null-0`, specializes the guarantee to one procedure
with no parameters or calls and one null statement. Every admitted program has
zero user-program proof obligations. Extending it to constructs that generate
checks requires new admission, composition, and automatic-discharge proofs.

The compiler is implemented in SPARK. Its authors may use full SPARK contracts
and proof annotations; Silver program authors do not supply them. Python scripts
are development setup, evidence auditing, and tests. GNATprove verifies the
compiler implementation. Lean connects the restricted recognizer source to its
language model and proves safety for every member of this null-only profile.
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

`dev.py prove` fixes the solver and proof configuration, forces analysis, and
runs the proof audit before succeeding. The audit checks
unit/entity coverage, proof completion, individual obligations, skipped checks,
assumptions, diagnostics, and matching report formats. A completed provenance
record binds the selected host, source/configuration/script bytes, tool binaries,
and reports. A successful GNATprove process exit alone is insufficient. Reports
remain in `.silver/<host>/compiler/obj/gnatprove/`.

Bootstrap installs Alire 2.1.1 with pinned upstream SHA256 hashes. Alire manages
GNAT 16.1, GNATprove 16.1, and GPRbuild 26.0; patch updates are permitted within
these common version families. The validated package releases are GNAT 16.1.0,
GNATprove 16.1.0, and GPRbuild 26.0.1. That GPRbuild package identifies its executable
as version 26.0.0. Downloads and generated files are ignored by Git.

## Use the compiler

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue
"$silver_executable" check null.adb
"$silver_executable" compile null.adb
"$silver_executable" run null.adb
```

`check` decides membership without invoking a prover. `compile` first admits the
source, then creates a fresh private `.silver/<host>/program-XXXXXX/` workspace, proves
its byte-identical `main.adb` snapshot, checks the proof report, and builds that
same snapshot. It prints the snapshot, proof-report, and executable paths.
`run` additionally executes the resulting program. No annotations are inserted.

The executable can be invoked from another working directory. Relative input
paths refer to that directory; tools and output workspaces stay anchored to the
installation recorded during bootstrap. Installation paths are shell-quoted,
and inherited GPR configuration/search-path overrides are removed before Alire
runs. Moving the installation requires bootstrap and rebuild. These controls do
not make the entire operating-system environment hermetic.

Exit status is 0 for success, 2 for excluded source or incorrect CLI usage, and 3
for an infrastructure, verification, compilation, or execution failure. Failure
on an admitted program is reported as a toolchain or implementation defect;
prover results never redefine membership.

The [machine-readable catalogue](catalogue/silver-null-0.json) is generated from
the actual compiler. Recognition and JSON export share SPARK token and character
rules. It also lists the admitted procedure, required pragma, null statement,
their conditions and token spans, and their sole permitted composition. Tests
compare the exported JSON with the checked-in file. Regenerate it after an
intentional profile change:

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue > catalogue/silver-null-0.json
```

## Proofs and platform evidence

Current validation results and exact counts are recorded in
[the review repair record](docs/review-repairs.md). Regression coverage includes
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

The source bridge embeds the authoritative `silver_profile.ads` and `.adb`,
checks restricted source bytes and declaration shapes, and matches typed
expressions with checked Ada precedence. Its semantic scope is described in the trusted boundary. Clean
replay audits actual imported modules and every declaration's transitive axioms,
then runs a fresh `leanchecker` kernel check. Only Lean's standard logical
foundations are allowed. The separate external-tool theorem proves completion
and preservation under its documented tool and operational contracts.

See [the assurance argument](docs/assurance.md) for the exact proved claims, and
[the trusted boundary](docs/trusted-boundary.md) for external symbols, ABI
assumptions, report-format assumptions, and supported execution conditions.

[CI](.github/workflows/verify.yml) is configured for Linux x86-64/ARM64 and macOS
x86-64/ARM64, plus Lean checks. Repairs are validated locally on Linux ARM64.
Retained pre-repair macOS ARM64 reports passed a re-audit under the baseline
rules; they do not validate these repairs or the new provenance requirements.
Native macOS repair validation and x86-64 validation remain pending. Linux is
primary and macOS validation is independent under the Oracle. This work remains
local as requested: the repository has no Git remote, and the configured CI
workflow has not been executed.
