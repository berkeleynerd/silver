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

The compiler is implemented in SPARK. Its authors may use full SPARK contracts
and proof annotations; Silver program authors do not supply them. Python scripts
are development setup, evidence auditing, and tests. GNAT, GNATprove, Alire, and
OS/runtime services are trusted external dependencies. GNATprove verifies the
compiler implementation; Lean connects its actual recognition rules to the
independent language and proves universal source safety. Completion and semantic
preservation through the external tools have explicit supported-environment
premises; see [the assurance argument](docs/assurance.md).

## Set up, verify, and build

Run commands from the repository root. Development requires Python 3.11+ and
native development libraries: libc development files on Linux, or Xcode Command
Line Tools on macOS. On Debian/Ubuntu, the required native package is `libc6-dev`.

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

`dev.py prove` runs the proof audit before succeeding. The audit checks
unit/entity coverage, proof completion, individual obligations, skipped checks,
assumptions, and diagnostics. A successful GNATprove process exit alone is
insufficient. Reports remain in `.silver/<host>/compiler/obj/gnatprove/`.

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

Exit status is 0 for success, 2 for excluded source or incorrect CLI usage, and 3
for an infrastructure, verification, compilation, or execution failure. Failure
on an admitted program is reported as a toolchain or implementation defect;
prover results never redefine membership.

The [machine-readable catalogue](catalogue/silver-null-0.json) is generated from
the actual compiler. Recognition and JSON export share SPARK token and character
rules, and tests compare the exported JSON with the checked-in file. Regenerate
it after an intentional profile change:

```sh
silver_executable=$(python3 scripts/dev.py paths --field executable)
"$silver_executable" catalogue > catalogue/silver-null-0.json
```

## Proofs and platform evidence

The host-isolated Linux ARM64 build discharged all 655 compiler checks
(124 by flow analysis, 531 by proof). Eight units are audited, with 73 reported
entities including 11 explicitly trusted imported OS/runtime declarations.
The reports also contain twelve documented optional recursive-proof limitation
notes; these withhold proof information and do not waive obligations. The audit
counts them and rejects other warnings, failed checks, and source suppressions.
All 32 regression tests passed with the rebuilt compiler. They cover real
proof/build/run cases, simulated tool failures, source changes, and cross-platform
artifact isolation. The original, unchanged `null.adb` also proved, built, and
ran successfully with the rebuilt compiler.

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

The source bridge embeds the authoritative SPARK files, checks their lexical
certificates, and matches typed expressions with checked Ada precedence. The
clean replay checks every proof module and audits every declaration's transitive
axioms. Only Lean's standard logical foundations are allowed. The separate
external-tool theorem proves completion and preservation under its documented
tool and operational contracts.

The isolated Linux ARM64 clean replay passed, checking all 14 proof modules
and auditing 3,616 declarations. An isolated change to an authoritative
source constant was rejected by the source-reconstruction proof.

See [the assurance argument](docs/assurance.md) for the exact proved claims, and
[the trusted boundary](docs/trusted-boundary.md) for external symbols, ABI
assumptions, report-format assumptions, and supported execution conditions.

[CI](.github/workflows/verify.yml) is configured for Linux x86-64/ARM64 and macOS
x86-64/ARM64, plus Lean checks. Only Linux ARM64 has been executed in this
workspace. Linux is the primary validation platform; native macOS validation is
a separate secondary task and does not block the Linux milestone, as the Oracle
requires. Native macOS and Linux x86-64 results remain unverified. The repository
currently has no Git remote through which to run the prepared workflow.
