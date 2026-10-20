# Existing CVC5 quiet/no-statistics invocation route

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`421486c4e33271c02fc59f54d71182cc98c9558c`.

**A controlled direct gnatwhy3/why3server invocation can select the existing
CVC5 binary with `--quiet` and without `--stats-internal`, preserving the
built-in prover identity and private no-step driver.** This closes a supported
configuration route and removes the selected warning/statistics byte families
at candidate-source scope. It does not close complete q, automatic discharge,
or the production GNATprove integration. No live configuration was changed.

The [offline packet](../evidence/retained-cvc5-quiet-route-20261020/README.md)
contains a concrete prospective base configuration, its exact one-field diff,
source witnesses and a checker. It reuses Round 47's
[quiet-option result](retained-cvc5-parser-options.md#bounded-assessment-of-the-existing-quiet-option);
that warning suppression/result-preservation result is not a new experiment.
No solver, native target, proof, capture, download or tool installation ran.

## Preferred route and its controlled inputs

Use the retained `put_line/why3.conf` as the base-file construction, changing
only the ordinary `command` of the record with name `CVC5`, shortcut `cvc5`
and version `0.0.7-gnatprove`. The version is its existing configuration key,
not a claim about binary version. The candidate command is:

```text
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/cvc5 --prenex-quant=none --quiet %f
```

The exact [candidate-base-why3.conf](../evidence/retained-cvc5-quiet-route-20261020/candidate-base-why3.conf)
is evidence, not an installed configuration. Its other eight prover records,
editor, limits, positive-step command and CE command retain their original
bytes. Select `cvc5,z3,altergo`, `--proof per_check --steps 0 --timeout 0
--memlimit 0 --counterexample off`, the exact entity/input produced for that
request, and an external socket with explicitly coordinated client/server
worker count J. No replay, manual/editor, debug-save, extra API scheduling,
counterexample or giant-step-RAC entry is selected. Warning scheduling uses
`cvc5` as well; its separate warning-time limit must be specified/accounted
for, since gnatwhy3 otherwise defaults `--warn-timeout` to 1. An all-zero
warning-time configuration uses the existing direct `--warn-timeout 0` option;
it is not inferred from `--timeout 0`.

The working directory contains that base `why3.conf`. Pass the existing private
overlay's separate `--why3-conf <overlay>/why3.conf`, whose contents stay
`[main]` / `magic = 14`. Its four private driver files and ten imported
installed files retain the
[accepted identities](retained-solver-identity.md#commands-and-selected-drivers).
The selected CVC5 root still imports `silver_cvc5_no_steps.gen`. Require the
same unique driver/import resolution and stable directory contents; a working
directory driver must not shadow the selected overlay file.

This is supported by the actual source interfaces:

1. `Gnat_util.gnatprove_why3conf_file` is the relative string `why3.conf`.
   `gnat_config.ml:350–379` reads that base with `Whyconf.read_config`, then
   separately reads the optional extra file. The built-in-redefinition check
   applies to the extra file, not to the already supplied base. No forbidden
   extra-config override or ignored `[prover_modifiers]` section is assumed.
2. The three selected names remain built-ins, so `builtin_provers_only=true`.
   `gnat_util.ml:110–126` loads only `gnat_json` and `ada_terms`, as before.
   The base's nine prover identities and driver strings remain unchanged;
   `Controller_itp.load_drivers:114–122` therefore has the same nine entries.
   This is a control/configuration statement, not equality of captured heaps.
3. `RC_load.load_prover` stores the changed string in `config_prover.command`
   (`whyconf.ml:347–367`). Zero steps leaves `opt_steps=None`; the unchanged
   positive-step command is not selected (`gnat_config.ml:125–126,630–641`).
   `get_complete_command` selects `command` and joins its empty extra-options
   list. `Controller_itp.build_prover_call:411–433` supplies it to the driver.
4. `Call_provers.actualcommand:404–429` tokenizes before substituting `%f`.
   The fixed candidate splits into four argv entries. Substitution replaces
   the last entry by the complete task pathname; it does not retokenize that
   pathname. `%f` sets `use_stdin=false`; no time-limit placeholder occurs.
   `send_request:166–187` encodes those entries and `request.c:90–127` reconstructs
   them. Require preserved request bytes, valid C lengths/ownership and operands
   without NUL, semicolon or LF; an unescaped protocol delimiter is not safe
   merely because command tokenization preserves it.
5. `server-unix.c:390–398` directs stdout and stderr into the attempt output
   file and calls `execvp`. The absolute executable token contains a slash,
   so CVC5 selection does not depend on PATH. Its identified installed bytes
   are the unchanged 31,321,528-byte file with SHA-256
   `eb2f46a6bc5fb8a3c81b3387fecb0e68ef5ed1a0c0c5908557254ceb8091b232`.
   Z3 and Alt-Ergo keep their separate fixed lookup/dependency premises.

The direct server launch must independently control its executable, cwd,
environment, socket, worker count and native services. The
[parallel ownership/count relation](retained-solver-launch-profile.md) remains
conditional on its existing fresh-goal/container premises. It does not transfer
historical serial state to J>1.

**Stock GNATprove does not preserve this edited base file.** Before translation,
`gnatprove.adb:629` calls `Write_Why3_Conf_File`, which regenerates it from the
installed `gnatprove.conf` (`:1022–1274`). A later #88 implementation must make
the controlled backend/server invocation concrete while preserving the exact
GNAT2Why input, entity and request ownership, all required obligations, output
response/error delivery, exit statuses and final GNATprove reporting. Directly
proving a saved JSON input does not establish that end-to-end production join.
This note changes neither the installed JSON configuration nor a tool binary.

## Generated-file branch

The `.smt2` attachment now has an explicit caller argument, rather than relying
on the filename template alone. `gnat_checks.ml:1037–1047` supplies no
`proof_script_filename` with debug/debug-save off. In a fresh session with no
retained attempt scripts, `schedule_proof_attempt:615–643` therefore supplies
`spa_pr_scr=None`. `Driver.file_name_of_task:414–454` takes its generated branch.
`silver_cvc5_no_steps.gen` has `filename "%f-%t-%g.smt2"`; `call_on_buffer:604–618`
passes that as the suffix of `Filename.open_temp_file "why_"`.

Require a controlled TMPDIR/path construction whose result is an ordinary
non-stdin, non-option pathname with the protocol exclusions above. The existing
sanitizer and CR/LF-free location assumptions still apply. Printing, flushing,
writing and close complete before submission; an escaping earlier exception
does not submit the partial file. Consequently the single argv filename ends
in `.smt2` and `driver_unified.cpp:112–163,214–247` selects the noninteractive
SMT2.6 file path, incremental=false and wf-checking=false. Reused proof scripts
would require their own pathname/contents relation and are excluded here.

## Minimal command perturbation and reusable source facts

The old ordinary command has 44 bytes; the new one has 167. The executable
token grows from 4 to 136 bytes, and `--stats-internal` (16 bytes) becomes
`--quiet` (7), giving a net **123-byte increase**. The complete base file grows
from 1,946 to 2,069 bytes, with the same 71 lines, nine prover records and 56
quoted fields. Its longest quoted value grows from 61 to 167 bytes. Neither
prover keys, driver paths, transforms nor response regexes change.

Before solver submission this is one changed `RCstring` payload, retained in
the corresponding prover record, then joined into a complete command and split
into the same four arguments. `rc.mll:291,354–388` uses a shared Buffer and one
`Buffer.add_char` per ordinary string character. The changed field adds exactly
123 such entries and no field/list/map entry. With the explicitly fresh
17-byte Rc Buffer and no other earlier reader, the old base needs capacities
17→34→68; the new one additionally reaches 136→272. These are local Buffer
transitions, not the complete OCaml allocation delta: lexer refills, temporary
objects, GC thresholds and later retained state still need their caller bounds.

`Cmdline.cmdline_split` uses one Queue entry per nonblank byte and four
`String.init` results. Their total payload grows from 41 to 164 bytes;
the largest argument grows from 19 to 136. After `%f` substitution, for a
pathname of F bytes, argv payload totals change from `39+F` to `162+F`.
The request has the same argument/separator counts and adds 123 command bytes.
These local facts give prospective length interfaces. They do not prove that
a captured minor-heap position, lexbuf backing length, formatter state,
hash-cons table, count snapshot or no-GC certificate survives new bytes.

The semantic source arguments for the unchanged selected transform lists,
command-envelope construction, response consumers and fresh scheduling owners
can be reused under their stated representation/caller premises. Changed
configuration lengths must enter the prefix/storage/resource calculation;
new filenames, worker count and task construction require their respective
joins. No identical capture rerun is prescribed or performed merely to learn
these source-level differences. The preserved global budget is two
save-entering callbacks, three saves and e≤2, never a budget per prover.

## CVC5 option and output effects

The candidate CVC5 source remains revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`. The option generator and stock parser
invoke the declared predicate once for each selected CLI option. From the
declared verbosity zero, the single quiet option decreases it to -1. There is
no repeated decrement or numeric-boundary case in this invocation.

| Projection | Effect and preservation argument |
| --- | --- |
| verbosity=-1 | `decreaseVerbosity` and `setVerbosity` select the null WarningChannel (`options_handler.cpp:161–184`). All explicit verbosity writers are these predicates and the generated addressed setter. No task option setter is admitted. |
| Warning/WarningOnce | Their macro tests see the null stream (`output.h:297–303`); these guarded insertion expressions are skipped. This reuses Round 47's byte result. |
| Env/EnvObj warning | `verbose(0)` returns `null_os`; rendered operands can still be evaluated and formatted (`env.cpp:184–200`, `env_obj.cpp:84–94`). Thus byte suppression is not termination/allocation closure. |
| MINISAT verbosity | The test is `base.verbosity>0`; both old 0 and new -1 map to backend -1 (`minisat.cpp:151`). No new SAT progress output appears. |
| stats, stats-internal, stats-all, stats-every-query | All remain false. The removed `setStatsDetail(true)` was the selected automatic writer enabling stats. Generated setters, unselected detail setters and false-clearing `setStats(false)` exhaust the writers. `SetDefaults` does not enable them. |
| Ordinary/safe stats output | `command_executor.cpp:81–114` tests stats before obtaining/traversing either registry. The branch is skipped, including the main API-exception statistics path. Per-query statistics stays disabled. |
| Other output gates | Round 47's preserved false print-success, portfolio, dump getters, tags, tracing and proof-log gates remain applicable. File mode and copied original options do not turn verbosity/stats back on. |

The complete occurrence inventory includes field names, generated setter
support, automatic setters, option string keys and stream-reassignment sites.
The selected version command sets SMT2.6 language defaults, not stats/verbosity.
Subsolver options are copied by value. Neither the retained subsolver setters
nor SetDefaults introduces a positive verbosity/statistics setting. The sole
other WarningChannel reassignment is `setErrStream`; no `--err`/task setter is
selected. Muzzled-build setup only keeps warning output disabled.

Removing `--stats-internal` is not literally just deleting output bytes.
`Env::finishInit` stores the false display flags in its registry; registrations
and most statistic updates still follow the build's compile-time statistics
setting (`statistics_registry.h:248–269`). In
`ProofFinalCallback::initializeUpdate`, the condition is
`statisticsInternal || checkProofsComplete` (`proof_final_callback.cpp:73–80`).
When both are false, finalization skips rule/trust histogram work and the
corresponding `AlfPrinter::isHandled` computation. If complete-proof checking
is requested, that branch still executes, and its incomplete-proof
`InternalError` still tests `checkProofsComplete` (`:106–205`). Pedantic checking
and subsequent checkProofSteps checks remain outside the statistics guard.
No proof-check option is disabled by this candidate command.

The candidate consequently removes output/rendering work and some statistics
work/error opportunities, including the CLI's statistics-build requirement.
It is not an equality theorem for elapsed times, allocation traces, signals or
failures caused by that removed work. Unchanged logical result/report routing
does not prove successful termination of the remaining search/formatting code.

## Required response, status and report consumers

`CheckSatCommand::printResult` still emits sat/unsat/unknown plus LF;
`GetInfoCommand::printResult` emits the nonempty reason result plus LF;
`Cmd::invokeAndPrintResult` emits non-ok statuses unconditionally
(`commands.cpp:134–151,380–383,2600–2606`). The command executor still returns
`!cmd->fail()`, and the file driver still stops on hard failure. Neither quiet
nor stats selection wraps these paths. The existing at-most-one check-sat and
one reason query envelope and its 84-byte ordinary pair bound remain a local
component, not total q.

The private driver's complete imported response directives still recognize
the same outcomes and reason text. Its six removed step directives across all
three drivers stay removed; no selected StepRegexp consumes CVC5 statistics.
The sole inherited time expression is `why3cpulimit time : %s s`, not a CVC5
statistics entry. `parse_prover_run:357–358` falls back to server time and -1
steps when no corresponding match exists. `gnat_report`/`gnat_checks` build
their statistics from attempt count, pr_time and pr_steps, rather than parsing
a solver statistics map. Existing step conversion, all outcome distinctions,
result identities, proof Booleans, check trees and unproved status remain.
The changed route keeps original prover names, so the prior maximum-name
allowance and identity cardinality do not need an alias adjustment.

The output-file reader and regexp parser still process the entire surviving
stdout/stderr capture before delivering a completed attempt. Keeping required
text does not let us ignore the resource use of errors, exceptions or terminal
text that precede delivery. A signal or nonzero exit is not converted to an
invented successful exit; Why3's existing answer precedence is unchanged
(including its existing preference for a parsed Valid answer). No stronger
new fail-closed policy is claimed. Parallel cancellation may select a different
winning attempt or time after removing diagnostic work, so exact report bytes
and timing equality are not claimed.

## Diagnostic channels, terminal paths and alternative route

The stock `--err=...` alias `--diagnostic-output-channel=...` changes the managed
error stream and Warning/Trace channels (`base_options.toml:5–13`,
`options_handler.cpp:108–112`). It does not redirect all diagnostics: main's
option-error catches write directly to `std::cerr`; terminal handlers use raw
fd 2; SMT2 API exceptions and command failures use the normal result stream.
Redirecting that managed stream is therefore not a whole-output solution.
It also introduces file-open/service errors and option-order interactions:
an err setter after quiet can reattach WarningChannel. This candidate does
not select it or discard a required response channel.

Quiet/stats removal leaves signal installation, direct terminal literals,
saved C++ terminate-handler behavior, startup/destruction, direct stderr
writes, parser/command exception payloads and interrupted output prefixes.
Stats=false avoids the terminal registry traversal and its histogram/numeric
printing obligations on this branch, but the initial option lookup still
needs a valid executor/solver/options state at that signal point. The
[terminal packet](retained-cvc5-terminal-output.md)'s count is still conditional;
single-thread/signal/runtime assumptions do not follow from quiet. Suppressed
Env warning rendering also retains its work, and parser exception operands
retain the existing N/F/H/E_caught interfaces.

An alternative stock-GNATprove route can add a distinct `CVC5Q` / `cvc5q`
prover to the extra config, using the same command/driver. It passes the actual
built-in-name/shortcut check and preserves the maximum seven-byte report-name
allowance. It is deferred here because `builtin_provers_only` becomes false:
Why3 autoloads its plugin directory and creates an extra driver object.
The current native directory contains ten .cmxs names; its enumeration,
plugin initialization, error paths and changed prefix state would need their
own attachment. Extra `[main] load_default_plugins=false` does not fix this:
gnatwhy3 merges only provers/editors/shortcuts, retaining the base main record.
Moreover stock GNATprove explicitly appends `--warn-prover cvc5`
(`configuration.adb:3280–3285`), so warning attempts would still use the original
command. The preferred direct-base route avoids both differences.

## Remaining premises and integration

The installed-file/source relation is the explicit relevant external behavior
premise described in
[retained-tool-source-identity.md](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary),
specialized to this command, parser, option, stream and status behavior. Exact
historical binary-source attestation is not introduced as an extra gate.
Stable executable/config/driver bytes, valid native objects/callers and normal
filesystem/stream/process services remain necessary.

The meaningful new joins are the concrete accepted base-command route, explicit
generated filename branch, source-derived configuration-length change, preserved
response/step/time/report consumers and elimination of ordinary/safe statistics
traversal. Complete q still needs surviving rendered errors/exceptions and
direct/terminal/native output composition; remaining work/termination still
needs its own argument. Prospective prefix resources, source/configuration task
inclusion, current-grammar coverage and the #88 producer/report orchestration
are not discharged here. No numeric q or O is exported, and no claim about a
larger useful capacity region is inferred merely from suppressed bytes.

Oracle, tools/source pins and current admission are unchanged. #119/#153 remain
unfinished; production #88–#94 is unstarted and draft PR #121 remains unmerged.
Selected author setting: GPT-6 Astra / Extra High, confirmed as the parent's
selection; runtime confirmation and token/cost telemetry are unavailable.
The packet records the measured documentation/check interval separately from
unavailable full-subthread elapsed time. Independent review is pending at freeze.
