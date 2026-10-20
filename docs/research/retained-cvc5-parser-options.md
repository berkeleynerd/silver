# CVC5 parser containment and automatic output options

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`d19f73cb3f3c2d8c32d88c1dda9b3c058090ce07`. Candidate CVC5 revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`.

**The selected file parser preserves the command envelope, and the automatic
option paths preserve the output gates needed for the smaller ordinary
statistics bound.** A malformed template can cause an error or absorb later
text; there is no error-recovery loop that executes additional commands. The
stock-main/no-external-API join therefore supplies R=0 and excludes plugins in
the accepted registry argument. With the existing object and formatting
premises, one ordinary two-registry dump is at most **1,103,886+F bytes**.
This is not a complete output-file bound: internal warnings and rendered
exception operands still need their own bounds. Actual q and O remain null.

The [offline packet](../evidence/retained-cvc5-parser-options-20261020/README.md)
reuses the complete retained CVC5 archive. It records source identities,
option declarations and all matching source occurrences, parser diagnostic
sites, exact control-path witnesses and checked arithmetic. No solver, native
target, compiler, proof suite, capture or network operation was run.

## Scope and parser behavior

The input is the fixed five-input/14-driver construction family accepted in
[Round 46](../reviews/review-solver-domains-and-parallel-launch-20261020.md),
with the [generated-task inclusion result](retained-solver-task-language.md).
The command is unchanged:

```text
cvc5 --prenex-quant=none --stats-internal %f
```

For the generated-name branch, the filename ends in `.smt2`: the selected private
`silver_cvc5_no_steps.gen` uses `filename "%f-%t-%g.smt2"`; the retained Why3
`call_on_buffer` appends this as the suffix of `Filename.open_temp_file`.
`Driver.file_name_of_task` can instead reuse an explicit old proof-script
pathname, so the launch join must establish the generated-name branch or a
corresponding `.smt2` pathname; no absence of an old script is inferred merely
from the template. This note's file-mode attachment includes that explicit
filename/substitution and one-file argv premise; no numeric F is inferred.
The file is not stdin,
and CLI option parsing is not allowed to reinterpret a task pathname as an
option. The complete-file/storage and executable/source relations remain
explicit premises, as do the fixed family's CR/LF-free location filenames.

`runCvc5` makes this a noninteractive SMT-LIB 2.6 file parser
(`driver_unified.cpp:112–163,214–247`). `use-portfolio=false` causes
`PortfolioDriver::solve` to call `solveContinuous` once, without strategy
configuration, child processes or replay (`portfolio_driver.cpp:569–577`).
The loop asks for one command, invokes it once and stops on EOF or a hard
failure (`:46–96`). It has no parser-exception handler.

The relevant parser structure is unusually helpful here:

- `Smt2Lexer::computeNextToken` handles a semicolon comment through LF/EOF,
  strings through their closing quote (doubled quotes are the SMT escape), and
  quoted symbols through their closing bar. Parentheses in these tokens are
  data. Why3's generated `\\xHH` string escapes contain no raw quote; CVC5's
  interpretation of their value cannot turn them into command delimiters.
  An unterminated/nonprintable token becomes an error, not a new input stream
  (`smt2_lexer.cpp:96–260`).
- `Smt2CmdParser::parseNextCommand` consumes `(` and then a command symbol,
  dispatches that one command, and consumes its closing `)` before returning
  (`smt2_cmd_parser.cpp:103–130,949–959`). The term, sort and symbolic-expression
  parsers consume their nested delimiters and never call the command parser.
  Their lookahead reinserts the same token; it does not synthesize another
  command or rewind to a consumed command opener. Named-term handling updates
  bindings directly; it does not enqueue commands (`smt2_state.cpp:1930–1952`).
- `Lexer::parseError` throws. `Parser::nextCommand` marks the parser done and
  rethrows `ParserException`; other `std::exception` values are converted to
  a located parser exception (`lexer.cpp:48–61`, `parser.cpp:69–89`).
  `InputParser::nextCommand` forwards this exception (`cvc5_parser.cpp:293–301`).
  File mode has none of the interactive shell's partial-input/retry behavior.

Consequently a successful parse stays inside its enclosing command. A positive
parenthesis surplus in either Float80 template cannot expose a new command at
top level. It can instead absorb a later form as a term, or cause a syntax/type
error/EOF; this note claims neither template reachability nor semantic
acceptance. An empty syntax entry likewise may cause failure without creating
another command. This argument depends on the complete fixed insertion-surface
proof; it does not cover arbitrary SMT text or a raw newline injected through
an unconstrained Why3 filename.

Let N prospectively bound submitted file bytes and T its non-EOF lexical-token
count. Each returned command consumes a distinct opening token, name token and
closing token. Thus the number C of invoked parsed commands satisfies
`C <= floor(T/3) <= floor(N/3)`. This needs no bound on Task-node count and
continues to hold for malformed input prefixes. N is to be derived from the
source/configuration construction, not measured after solving as an admission
certificate. The stronger query counts remain at most one check-sat and one
reason-unknown query, with zero explicit option, reset, find-synth or output
getter commands.

`Cmd::invokeAndPrintResult` prints one result/status per invocation. A
`CommandFailure` makes `Cmd::fail()` true and stops the file loop, so there is
at most one hard command-failure status. The only included command classes
that can return `CommandRecoverableFailure` are SetInfo and GetInfo, giving a
conservative upper count of two: one fixed version command and one reason
query (`commands.cpp:2535–2555,2570–2594`). Unsupported SetInfo is silently
successful. At most one parser exception escapes the loop. These are counts
of outer status/exception events; they do not bound warnings raised within
one command or failures of the subsequent terminal/statistics output paths.
The accepted 84-byte normal result/reason-pair bound already includes the
ordinary sat/unsat reason-query recoverable error; do not count it twice.

## Output-option preservation, including automatic setters

This is a projection of the actual option transitions, not an assumption that
every default remains unchanged. The generated CLI cases call `Solver::setOption`;
`SolverEngine::setOption` calls `options::set`; `mkoptions.py:360–416` builds
that setter from one declared handler/predicate list followed by assignment to
the addressed field. Printer setters also update the global default used by
fresh streams. The selected option declarations and generated-setter schema
were read with `OptionsHandler`, all setter/copy call sites, `SetDefaults` and
the stock driver. The packet retains the complete matching occurrence lists,
including macro arguments and string option keys; counts alone are not the
reachability argument.

| Output-related projection | Selected value and transition argument |
| --- | --- |
| `stats`, `stats-internal` | True after accepted CLI parsing. `setStatsDetail(true)` enables `statistics`; it does not enable either other detail flag. A build without statistics support instead throws before task execution. |
| `stats-all`, `stats-every-query` | False. Their only extra field assignments are the false assignments in `setStats(false)`; no automatic true assignment exists. `setStats` is not selected here. |
| `print-success`, `use-portfolio`, seven `dump-*` flags | False. The generated setters are their only value writers. The seven flags are models, proofs, instantiations, instantiations-debug, unsat-cores, unsat-cores-lemmas and difficulty. No task setter is admitted, and portfolio option application is behind the false portfolio gate. |
| `collect-pivot-stats`, `ite-simp` | False. Neither has an automatic field writer. The two portfolio strategies containing `ite-simp` cannot run. The sole stock `ite-simp` pass application is guarded by `doITESimp`; direct `simpITE` callers stay within that pass. Pivot bucket insertions remain guarded by `collectPivots`. |
| Output tags, tracing, `proof-log` | Output-tag bitset remains empty; its only setter is the unselected output-option predicate. Trace tags start empty and only the unselected trace predicate enables them. `proofLog` is false; its only extra direct write clears it for subsolver checking. Therefore raw-benchmark/options-auto and proof logging do not add output. |
| `verbosity` | Zero. The only extra writes are the unselected verbose/quiet predicates. Warnings remain enabled in an ordinary nonmuzzled build. |
| Input/output language | Initially AUTO. The `.smt2` file selects SMT2; the input-language predicate sets the output default. The fixed `set-info :smt-lib-version 2.6` also sets input language and, when not user-set, output language to SMT2.6. Its unsupported-version warning is not taken for `2.6`. |
| `interactive`, `incremental`, `wf-checking` | The driver selects false for all three in this file mode. The latter two are explicit automatic changes from their declared true defaults. No interactive banner/prompt is selected. |
| `sat-solver`, `expr-depth`, `print-arith-lit-token` | MINISAT, -1 and false. No selected automatic field writer changes these. The printer options update global defaults only through the unselected respective setters; local scoped printer settings still belong to the particular rendering route. |
| `tlimit`, `segv-spin`, `early-exit` | 0, false, true. No selected setter changes them. `install_time_limit(0)` returns before installing SIGALRM or creating a watchdog thread (`time_limit.cpp:79–85`). In nondebug builds true early-exit selects `_exit`; debug builds additionally require an explicit user setting, absent here. |

`SolverEngine::finishInit` calls `SetDefaults` once for an initialized solver
(`solver_engine.cpp:157–182`). Its option macros assign concrete named fields;
none enables the preserved output gates. `set-logic ALL` changes the logic and
can influence other algorithm options; it is not a reason to assume all options
stay at their initial values. In particular this note makes no blanket claim
that internal model/proof production is off: subsolvers can explicitly enable
such production. The output dump gates above are separate and remain false.

Options are held in separately allocated holders; `copyValues` assigns holder
values rather than sharing them (`mkoptions.py:251–275`, `options_template.cpp:50–59`).
Internal subsolver configurations therefore do not modify the main solver's
option fields. Their language setters can affect the process printer default,
but the relevant selected/subsolver assignments use SMT2.6, and none sets the
preserved output gates. Arbitrary external clients, modified constructors,
generated code inconsistent with its generator, or memory corruption are not
covered. Source/runtime/native correspondence is still required.

With no output getter flags, `CommandExecutor::doCommandSingleton` creates no
automatic getter commands. With no reset/query-statistics command and
stats-every-query false, no repeated ordinary dump comes from these paths.
The normal driver flush supplies one ordinary two-registry dump; main catches,
signals, termination, interrupted writes and destructor failures are owned by
the terminal/output composition and are not silently assigned multiplicity one
here. Excluding the tlimit watchdog does not prove that every backend/library
is single-threaded.

## Parser warning and message bytes

The parser has two remaining warning producers under this fixed envelope.
The SyGuS warnings, missing-set-logic warnings, and unsupported oracle,
sort-parameter and set-feature warnings require excluded modes/commands or
absence of the fixed first logic command. A failure while parsing/executing that
first command terminates before later commands. The two remaining producers are:

| Producer | Occurrence and complete byte allowance |
| --- | --- |
| Unsupported attribute (`parser_state.cpp:675–684`) | Once per distinct unsupported keyword, additionally charged to that physical keyword occurrence. The message has 74 fixed bytes plus raw attribute bytes. The located warning adds F+25 bytes: separators/LF and two uint32 decimal locations of at most 10 bytes each. |
| Fresh shadowed binder (`parser_state.cpp:207–275`) | At most once per parsed bound-variable entry in `bindBoundVarsCtx`, which is called once for that binder list. `fresh-binders` defaults false, so this producer cannot be discarded. It has 172 fixed bytes plus the raw name and LF; it has no filename prefix. |

Let A/B count the two event kinds and L_A/L_B bound the total corresponding raw
name bytes. The distinct token charges give `A+B<=T<=N` and `L_A+L_B<=N`, hence:

```text
Q_parser_warnings <= A(F+99) + L_A + 173B + L_B
                  <= N(max(F+99,173)+1).
```

This deliberately includes possible unsupported keywords even when a sharper
fixed-template analysis could exclude them. It is not a count of internal
solver warning events. Names are inserted raw, so these formulas count bytes,
not presumed diagnostic line counts. They use the accepted normal stream,
integer-formatting and no-extra-indentation premises.

The lexer/parser's own direct diagnostic messages have a useful separate
envelope. Let H prospectively bound one rendered CVC5 Term or Sort operand
that a direct parser error can include. Inspection of all direct producers
finds at most two raw names/tokens, at most three rendered Term/Sort operands,
and fewer than 256 bytes for the literal, valid enum, fixed-logic and bounded
integer pieces. Thus:

```text
m_direct <= 256 + 2N + 3H.
```

The three-operand cases are the type-ascription and constant-array mismatch
messages (`parser_state.cpp:579–599`, `smt2_state.cpp:1526–1532`). No diagnostic
construction loop accumulates an input-sized list into these messages. All
`checkDeclaration` calls use its empty default notes argument. Valid token
names have maximum length 29; unexpected-token errors add one raw token, not
an expanded command. The packet inventories the complete direct-site support;
the checker verifies source identity and those lexical supports, not a formal
C++ control-flow proof.

H is not automatically at most N: terms/types can be substituted or expanded,
and a serialized error operand is not necessarily its original input token.
Nor does this formula cover `Parser::nextCommand`'s caught `e.what()`: let
E_caught bound the payload produced by the external API/standard-library
exception at that catch. Using the already accepted located-parser wrapper:

```text
Q_one_parser_exception <= 68 + F + max(256+2N+3H, E_caught).
```

H and E_caught require producer/representation bounds before this becomes a
source-only numeric allowance. A parse error does not repeat indefinitely, but
its embedded terms and the underlying API's exception payload cannot be replaced
by raw token lengths. File-open and command-status/outer exception wrappers
remain the previously accepted distinct routes; terminal printing must also
allow its own failure prefixes.

## Bounded assessment of the existing quiet option

For the lead's completion assessment, a prospective command with one extra
stock `--quiet` has a precise useful effect. From verbosity zero, its
`decreaseVerbosity` predicate selects -1 and `setVerbosity` redirects the global
WarningChannel to the null stream (`options_handler.cpp:161–179`).
`Env::warning` and `EnvObj::warning` use `verbose(0)`, which also selects the null
stream when verbosity is negative (`env.cpp:184–200`, `env_obj.cpp:84–94`).
This includes the recurrent arithmetic-model warning at
`theory_arith.cpp:543–550`; it also suppresses the parser warnings above.

The required result text is preserved at this candidate-source scope:
`CheckSatCommand::printResult` writes its result plus LF unconditionally,
`GetInfoCommand::printResult` writes its nonempty result plus LF, and
`Cmd::invokeAndPrintResult` writes non-ok status text without a verbosity gate
(`commands.cpp:134–151,380–383,2600–2606`). Statistics selection is unchanged.
Thus quiet does not suppress the selected Why3 driver's normal
sat/unsat/unknown/reason-query response text.

This is an existing-option capability assessment, not an adopted configuration
change or a complete alternative q. Direct stderr writes, errors/exceptions,
their rendered operands, terminal paths and native correspondence still need
their accounts. Rendering toward a null stream can still execute formatting
code; byte suppression does not prove its termination, allocation safety or
obligation discharge. The selected command remains the original verbosity-zero
command throughout this packet.

## Exported join and remaining premises

The stock parser has no synthesized find-synth commands, and the admitted
command heads exclude find-synth/find-synth-next. Together with the stock-main
scope and no external API injection, this supplies the **R=0** premise of
[the accepted registry packet](retained-cvc5-registry-domain.md). The same
stock-main scope excludes `Solver::addPlugin`; no task command adds a plugin.
No stronger theorem for arbitrary C++ API clients is asserted.

Joining stats-all=false and inactive pivot/ITE histograms with that R=0 result,
no filename override, and [the finite enum domains](retained-cvc5-enum-output.md)
gives the ordinary `Q_stats<=1,103,886+F` component. The command component has
at most one normal result/reason pair, no success lines and no automatic
getters; exceptional status payloads retain their separate bounds. Parser
warning occurrences now have the explicit N/F interface above.

This leaves concrete obligations, rather than a universal admission claim:
derive N, F and rendered-operand/exception bounds from the intended generated
task family; bound cumulative internal warning/output work within one query;
complete terminal/signal/failed-prefix composition; and attach the fixed
source/configuration result to the intended executable and current-grammar
construction. Ordinary represented objects, valid caller arithmetic/lifetimes,
normal storage/formatting services and all inherited provenance premises still
apply. A post-run certificate or a successful sample is no substitute.

The global suffix allowance stays two save-entering callbacks, three saves and
e<=2, never renewed per solver, parser, root or output family. No retained serial
state is transferred to a parallel launch. Oracle, admission, tools, source pins
and commands are unchanged; #119/#153 remain incomplete. The lead owns joint
review, integration, GitHub state and publication.

Selected author setting: GPT-6 Astra / Extra High, per the parent's assignment;
runtime model/effort confirmation and token/cost telemetry are unavailable.
Actual elapsed/check time is recorded in the packet. No independent review is
claimed at this author freeze.
