# Candidate Z3 output families and prospective byte interface

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`3042c7431f3f82a4ddde9fd9df56e5729ff7258e`.

The candidate Z3 source yields a finite **statistics-render** envelope: at most
517 raw statistic names, at most 1,034 rows after its two typed maps, and at most
367,073 bytes per `statistics::display_smt2` invocation under the numeric and
stream premises below. This closes that output family independently of a solver
step limit. It does **not** bound the complete stdout+stderr file: generated
commands, parser diagnostics, warnings and direct solver diagnostics require
their own source/configuration joins. Complete per-file q and weighted O remain
null; no unboundedness of the pinned solver is inferred.

The [packet](../evidence/retained-z3-output-capacity-20261020/README.md) retains the
complete exact upstream archive, all census inputs, the non-statistics-call
dispositions and an offline checker. This is a candidate-source argument, not a
C++ compiler proof, solver-correctness proof, installed-binary refinement or
complete service-implementation proof. It uses valid represented objects and
the existing normal returning runtime/OS services with sufficient resources.
It does not add a cap, timeout, truncation policy or run-success membership rule.

## Selected invocation and source relation

The retained installed configuration selects the non-counterexample command
`z3 -smt2 -st smt.arith.solver=6 %f`. Its time-argument list is empty; the
positive-step-only `rlimit=%S` argument is absent at zero steps. The proposed
private driver deletion of `steps` directives leaves `-st` and all solver
arguments intact. Therefore omission of Why3's StepRegexp does not suppress
statistics bytes. The parent server redirects both child stdout and stderr to
the same output file; its protocol response carries the filename, not those
bytes ([server record account](retained-why-server-record-capacity.md)).

This analysis fixes Z3 4.15.4 candidate source revision
`745087e237e669d709ae35694728a0c479e572b3`. Its previously retained
`statistics.cpp/.h` bytes match this archive exactly. Configuration/driver and
Why3 printer bytes are reused from the earlier packets with their hashes; no
branch-head source is used. The installed executable and the historically
resolved bare-name `execvp` target still need the separate identity join. A
version string or matching source fragment is insufficient for that join.

`shell/main.cpp:217–220` sets both the shell statistics flag and global `stats`.
`shell/smtlib_frontend.cpp:158–192` constructs the command context, registers the
SMT-LIB command families and parses the file; after parsing it calls the shell
statistics renderer once. That renderer explicitly resets the regular stream
to stdout (`:43–53`). The `-model` shell flag is absent; the context's ordinary
`model=true` default enables model construction, not unconditional model output.

The shell timeout callback can also render statistics, but the selected command
does not install a `-T` timer. The ordinary context timeout is UINT_MAX;
`scoped_timer.cpp:88–90` treats both zero and UINT_MAX as disabled. This excludes
that configured timer, not all internal solver timers or possible exceptions.
The shell SIGINT handler resets SIGINT to its default, renders statistics, then
raises SIGINT (`smtlib_frontend.cpp:69–73`). The scoped solver handler instead
cancels and restores the prior handler (`scoped_ctrl_c.cpp:32–66`). Its signal
delivery emits no text itself. Subject to ordinary signal/stream semantics,
counting one normal shell render and one terminating shell-handler render is a
safe two-invocation allowance, including abandoned prefixes. It does not prove
signal-handler progress or make interrupted C++ operations safe. Explicit
statistics commands and progress callbacks must be counted separately.

## Statistics name and value closure

`util/statistics.h:24–39` has only unsigned and double value vectors with
`char const*` keys. The vectors are private; update appends, copy appends existing
entries, reset removes them, and ordinary object copying introduces no new name.
`statistics.cpp:26–57,97–145` builds separate content-keyed unsigned/double maps,
adds repeated values within each map, appends both maps' key lists and sorts.
The maps use string equality, not pointer identity.

Crucially, the same raw name in both maps appears **twice** in that concatenated
list. Distinct raw keys that sanitize to identical output also remain separate.
Neither collision reduces the conservative row count. Zero-valued updates can
be omitted; counter wraparound or repeated collection cannot create new names.

The packet scans all 2,019 `.cpp/.h` files in `src`, including API and test files,
and retains each file's hash plus every lexical member `update` call. After
separating tests and comments, the 664 production candidates are:

| Candidate family | Count | Disposition |
| --- | ---: | --- |
| Literal first arguments | 542 | 509 distinct names, all retained conservatively. |
| `get_uint64_stats` forwarding updates | 2 | Its only callers supply `num allocs` and `rlimit count` (`statistics.cpp:225–245`). |
| Constructed AC keys | 2 | The two suffixes below, with fixed constructor names. |
| Other receiver types | 118 | Goal/dependent-expression updates, moving averages, bitvector evaluators, sequence maps, random updater, network tree, variable counter and table indexer; exact file/line dispositions are retained. |

The 118 other candidates do not call `statistics::update`; in particular,
`model_reconstruction_trail.cpp`'s variable named `st` is a dependent-expression
state. The census is deliberately broader than the selected solver route. Its
source-reviewed receiver/constructor dispositions are not inferred from the
success of the arithmetic checker and do not claim a compiler-complete call
graph or unrestricted extension/plugin closure.

`ast/euf/euf_ac_plugin.cpp:305–310` constructs
`"ac " + name + " superpositions"` and `"ac " + name + " equations"`.
The arithmetic constructors use `add` and `mul`
(`euf_arith_plugin.cpp:24–28`). The only other production constructor caller,
`euf_specrel_plugin.cpp:29–40`, requires `sp.is_ac(f)`; the selected built-in
special-relation declaration constructor assigns `ac-op` to that declaration
kind (`special_relations_decl_plugin.cpp:23–31,65–89`). Copies of these valid
declarations preserve their names. It does not use the name of the parameter's
underlying arbitrary function. Counting both AC spellings for all three names
is safe, even though the special-relation plugin has no statistics-collection
override in this source. No task-symbol-length term is needed for these names.

The 509 literal names, two forwarded names and six constructed spellings have
517 distinct elements and maximum raw byte length M=38. With this candidate
source construction/closure premise, K<=2*517=1,034 rows. Future generated code,
extra plugins or a patched executable must re-establish the closure; this
packet does not infer their behavior from the upstream archive.

For a render with K rows and maximum raw key length M:

```text
B_stats <= 3 + K*(M + V + 4).
```

The three bytes are `(` and `)\n`. Each row has a colon, at most M bytes of key
plus alignment padding, one value separator, at most V value bytes, and at
most two separator bytes `\n `. A leading colon is stripped; other non-symbol
key characters are replaced one-for-one with `-` (`statistics.cpp:65–79`).
Using raw M also covers the padding calculation's different treatment of that
leading colon. The empty map prints exactly three bytes.

The numerical instantiation requires 32-bit unsigned, IEEE binary64 double,
normal GNU C++ numeric conversion, C/classic numeric locale, decimal unsigned
output, zero field width, no added grouping or sign decorations, and no
concurrent mutation of the stream's format state. These are explicit runtime
and selected-output-route premises. The formatter itself sets fixed notation
and precision two for doubles; it does not reset every other stream flag.
Unsigned decimal needs at most ten bytes. The largest finite binary64 value is
exactly `(2^53-1)*2^971`, with 309 integer digits, so sign + integer + decimal
point + two fractional digits needs at most **313 bytes**. Normal GNU `inf`/`nan`
spellings also fit. This is a width bound, not a finite-duration or exact-count
claim. With V=313, M=38 and K=1,034:

```text
B_stats <= 367073 bytes per render.
```

The two shell-render allowance is consequently at most 734,146 statistics
bytes, still conditional on represented objects and service behavior. This
does not count explicit `(get-info :all-statistics)`, tactic statistics or
progress output. `cmd_context.cpp:2321–2337` also collects time, memory and
rlimit values, already included in the universe. Nothing here bounds the
collector's memory, time, cardinality of its pre-dedup vectors, or successful
completion. No emitted row count is accepted as a post-run admission test.

## Commands and the source-to-task join

`cmd_context::display_sat_result` emits `sat\n`, `unsat\n` or `unknown\n`
(`cmd_context.cpp:1960–1976`), at most eight bytes per result occurrence.
Success acknowledgement is eight bytes, but defaults off because
`m_smtlib2_compliant=false` (`context_params.h:36–45`,
`cmd_context.cpp:601–618`, `cmd_context.h:399–401`). A task can change it.
An echo command emits at most 2e+3 bytes for a decoded e-byte string, including
the compliant quote-doubling branch (`basic_cmds.cpp:302–320`). These are
source-level per-occurrence bounds, not permission to assume no such command.

The retained Z3 driver prelude has comments and four `set-info` commands,
including `:status unknown`; its imported theory preludes contain declarations
and definitions. The Why3 `smtv2` printer's `add_check_sat` emits one check,
optional reason-unknown query and optional model query (`smtv2.ml:777–784`).
An incremental goal invokes it a second time (`:806–833`), so even one goal is
not unconditionally one check. The accepted
[counterexample-meta attachment](retained-why-model-meta-control.md) excludes
the selected model-query branch. Additional model dumps, query commands,
verbosity, progress, validation and stream-option settings need their selected
command/meta/syntax-map preservation join; the argv alone does not establish it.

With one correctly formed goal, no injected command syntax or additional
prelude commands, this printer skeleton supplies C<=2 ordinary check commands
even without assuming incremental=false. This conditional skeleton result is
not exported as the current five cuts' exact SMT-LIB command census. A complete
join must account for all reconstructed tasks, raw prelude/syntax templates,
identifier/string escaping and partial preparation paths, using construction
facts rather than a successful solver run or sampled SMT files.

## Errors, warnings and termination paths

The following producers are outside the statistics bound. Message lengths and
occurrence counts below are prospective inputs to discharge from source/task
construction, not measured output lengths.

| Family | Source-derived contribution or remaining join |
| --- | --- |
| Positioned parser/command error | `smt2parser.cpp:449–469`: at most `48+f+2m` bytes for f filename bytes and m message bytes. Two unsigned positions need at most 20 decimal digits in total. `escaped(msg,true)` at indent zero duplicates only quotes and may trim trailing LF (`util.cpp:124–154`). The ordinary no-filename constant is 46. |
| Parser recovery | `smt2parser.cpp:349–382,3178–3244` can recover and continue; its 100-error guard is per synchronization invocation, **not** a global file error bound. Error-message constructors include task identifiers and expression printing. These require occurrence and expanded-message bounds. |
| Ordinary warning | `warning.cpp:119–155`: `10+w` bytes for a normally formatted w-byte message (`WARNING: ` and LF). Warnings default enabled. Parser unknown attributes (`smt2parser.cpp:1169–1172`), well-sortedness and cost-evaluation diagnostics are named residual producers. |
| Pattern-inference warning | `pattern_inference.cpp:675–750` includes quantifier IDs, but these warnings are additionally guarded by `pi.warnings`, whose generated default is false (`pattern_inference_params_helper.pyg`). Do not charge them as always enabled, or exclude them without parameter preservation. |
| Arithmetic direct diagnostic | `theory_lra.cpp:754–759` emits `repeated term\n`, exactly 14 bytes, when `internalize_def` finds an already-internalized term. `IF_VERBOSE(0)` passes at the default verbosity zero (`util.h:197`). A prospective visit count or source-path exclusion is missing; no actual occurrence is claimed. |
| Other direct/debug/model output | Progress frequency defaults zero; model-on-final-check, arithmetic-validation and lemma-dump options default false. Their preservation is necessary. Level-zero sites elsewhere, debug/build-condition output and AST/model printers need selected reachability or payload bounds. The apparent `miss`/state dump in `theory_lra.cpp:2292–2315` is inside `#if 0`, so it is not an active producer. |
| File-open failure | `smtlib_frontend.cpp:177–180` prints fixed text plus the input filename, then exits; filename length has its own input bound. |
| Main uncaught Z3 exception | `main.cpp:428–435` prints `ERROR: ` + `ex.what()` + LF, so `8+m` bytes, then returns. Arbitrary `default_exception` message size is not reduced to the fixed `z3_error` enum strings. |
| Allocation/fatal/runtime failure | `memory_manager.cpp:75–90` has fixed out-of-memory and allocation-count terminal messages; parser's `z3_error` terminal branch is separate. `debug.cpp:39–48` assertion output contains compile-time file spelling, condition and generated version; debug builds may prompt. Source/build/runtime identity is needed before assigning a global terminal budget. Native runtime diagnostics are not silently included in `z3_exception`. |

Normal `sat/unsat` status-consistency diagnostics also depend on the task's
`set-info :status`; the selected prelude uses unknown. The two BUG branches in
`cmd_context.cpp:1979–2004` must not be interpreted as arbitrary repeated output
or as an observed solver defect. The candidate source has both guarded and
unguarded families; lack of a timeout does not establish infinitely many
occurrences, and sufficient resources do not by themselves exclude diagnostics.

## Prospective composition and exact remaining obligation

Let C count result emissions, P enabled success acknowledgements, J echo
commands with total decoded string bytes E, T statistics-render attempts, H
positioned parser errors with total optional filename bytes F and unescaped
message bytes L, and W warnings with total formatted message bytes Lw. Let D
cover every other command response, direct diagnostic, terminal and runtime
output, including abandoned prefixes. Under the per-family premises:

```text
q <= 8C + 8P + 2E + 3J + 367073T + 48H + F + 2L + 10W + Lw + D.
```

The equation is a producer interface, not a closed q. T includes commands and
progress in addition to the shell allowance; D cannot be dropped simply
because a normal run printed only a result and statistics. Refinement can use
the smaller `3+K*(M+317)` term for a proved reachable statistic domain instead
of the whole-source universe. The coarse 367,073 is an upper bound, **not** a
lower bound showing that smaller budgets cannot suffice.

The [standard JSON account](retained-why-standard-json-inputs.md) requires O
weighted by answer occurrences and parser invocations. A **complete** per-file
q covering every selected solver would give `O=max(A,N)*q`, with current
`A=208/173/108/12/9` and `N=194/161/98/11/5`. This statistics-only result cannot
instantiate that q, and does not close the optimistic sufficiency ceilings
`1156/1391/2229/20074/26766`. Those ceilings are not established solver bounds.

The remaining focused obligation is to attach the candidate source and exact
selected executable/configuration to the generated tasks, prove the command
and parameter preservation facts, and bound or exclude each reachable warning,
error, direct-diagnostic and terminal producer. The checker intentionally keeps
q and O null. #119 remains active/incomplete; #88–#94 production work is
unstarted. The eventual #88 parallel>=3/racing-attempt configuration is separate
from these retained `-j 1` prefixes and needs its own multiplicity join.
