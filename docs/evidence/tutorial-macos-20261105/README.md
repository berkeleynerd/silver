# Tutorial verification on macOS

The owner-authorized tutorial was developed on `codex/step-by-step-tutorial`,
based on `e587e7bef570e71553f846cdac0ee9e272122ade`. This record covers the
[tutorial](../../tutorial.md) and its host commands on 2026-11-05. Compiler,
runtime, language, catalogue and proof sources were unchanged by this task.
The String/Character feature's outstanding complete validation remains pending.

## Host and setup

- Native macOS 27.2, Darwin 27.2.0 arm64; Silver key `macos-aarch64`.
- zsh; Python 3.15.2 at `/opt/homebrew/bin/python3`.
- Xcode developer directory `/Applications/Xcode.app/Contents/Developer`.
- Checkout `/Users/rebecca/src/github.com/berkeleynerd/silver`.
- Initial native Silver tool/compiler directories absent; no global `silver`
  command found. The managed ledger reported no runs or reserved workers.

`python3 scripts/bootstrap.py` installed and checked Alire 2.1.1, GNAT 16.1.0,
GNATprove 16.1.0 and GPRbuild package 26.0.1 (executable 26.0.0).
`python3 scripts/dev.py build --jobs 2 --task tutorial-macos` passed as managed
run `20261105T102827-7b8347ffb9ae`, under the native machine ledger
`.git/silver-runs/macos-aarch64/8c1ba4c2782af863/`.

Build workers were explicitly reserved. Application compile/run commands below
were serialized; their existing internal GNATprove command uses `-j0`. The
build's two-worker selection does not limit application proof workers.
No other validation stream ran in parallel.

## Native examples

`silver check samples/hello_world.adb` accepted. `silver run` then completed
application/library proof (66 checks), build and execution, printing
`Hello, world!`. Its workspace is `.silver/macos-aarch64/program-gpBXWo/`.

The six other core sample programs and the original counter exercise each
passed `silver compile`, which includes application/library proof and report
audit. Their resulting executables were run from `/private/tmp`; assertions
compared stdout, stderr and status against the tutorial/manifest expectations.
[results.json](results.json) retains source SHA256 values, compile statuses,
elapsed compile times, executable paths and eleven input/output comparisons.
The greeting cases include default, `Ada`, an empty argument, two invalid
arguments and one argument containing a space.

The original Character/slice preview passed `silver run`, and direct execution
confirmed `Hello\nello\n`, empty stderr and status 0; see
[preview-result.json](preview-result.json). This checks the example only and
does not establish completion of PR #307's repaired assurance.

The counter with its direct range guard removed was rejected by `silver check`
with status 2 and the expected catalogue-rejection message. The exercise source
is extracted from the tutorial's heredoc; it does not extend the supported-sample
manifest or introduce a language capability.

Native compile logs, exercise sources and the shell test log are retained locally
under `.silver/macos-aarch64/tutorial-20261105/`. Program workspaces retain their
actual source snapshots and proof/build outputs. Setup, build and example checks
are fresh native macOS observations, not a compiler-wide SPARK or Lean audit,
Linux validation, a clean-cache performance benchmark or evidence of universal
assurance. No unrelated full verification suite was rerun for these doc changes.

## Shell and document checks

The exact tutorial function was extracted into a scratch zsh file. `zsh -n`
passed. A fresh `zsh -f` session accepted Hello World from the checkout and
from `/private/tmp` using an absolute path. The function's `run` invocation with
one quoted empty argument passed from outside the checkout, producing
`Hello, !`. Shell stack setup used the documented `ulimit -s 8192`.

An initial sandboxed setup invocation could not reach the download server;
setup succeeded with network access. The first scratch Python validator stopped
before running any examples because its own `setrlimit` call could not raise
the stack. Using the documented zsh setting before launching the validator
resolved that harness issue without changing any Silver source.

Local tutorial links and anchors, paired code fences and whitespace were checked.
Inline checked-in program listings were compared with their actual sample files.
Personal shell startup files were not edited; the guide supplies optional
persistent configuration instructions.

## Review and settings

| Work | Selected or available settings | Result |
| --- | --- | --- |
| Lead host verification and integration | Live lead model/effort not exposed by the runtime | Installed native tools, built, exercised commands and integrated the guide. |
| Bounded lesson drafting | GPT-6.1 Sol, High requested; live settings not independently exposed | Read-only sample/spec extraction, draft outside checkout; integrated by lead. |
| Independent document review | GPT-6.1 Sol, Extra High requested; live settings not independently exposed | No material correctness finding. Added explicit input-contract explanation and the promised development preview; follow-up review accepted both and troubleshooting. |

Review target: the working document based on `e587e7be`, including sections
1–12, README entry and dated authorization entry. This was a documentation and
source/spec comparison review, with no native execution by the reviewer. Native
results are the lead's observations above. Agent elapsed/token/cost measurements
were unavailable; per-example native command timings are retained separately in
the JSON record. No Oracle change or standing maintenance requirement was made.
