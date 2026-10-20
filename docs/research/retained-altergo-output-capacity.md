# Alt-Ergo output: selected status payload and remaining file bound

2026-10-20 UTC, #119 / #153, author base `3042c7431f`.

**The selected Alt-Ergo command emits more than an SMT result word.** Its
ordinary status includes a diagnostic comment with source location, elapsed
time, steps and goal name, as well as the regular `unsat`/`sat`/`unknown` result.
Both streams enter the same server output file. This note bounds the explicit
data payload of one status call and identifies additional output families; it
does not supply a complete file bound q or the weighted JSON input O.

The [packet](../evidence/retained-altergo-output-capacity-20261020/README.md)
retains exact candidate-source files, line-numbered excerpts, driver inputs and
checkable arithmetic. Candidate revision
`80cf48b3b878b416dea7500a060132c024bf69c4` belongs to OCamlPro/alt-ergo.
The installed executable's embedded 2.6.1 version alone does not establish that
revision, a clean build or native/source correspondence. No solver was run.

## Command and output selection

The retained command is `alt-ergo --max-split 5 --disable-weaks %f`; neither
argument is a whole-output byte cap. The private driver selects `.psmt2` and
`smtv2.6par`. Its active success recognizer matches the diagnostic location and
`Valid`, while the `^unsat` recognizer is commented out. Suppressing diagnostics
or changing solver switches is therefore not an established compatible repair.

`parse_command.ml:377–475,943–987,1147–1168` and `options.ml:280–336,369–436`
give ordinary defaults: Dolmen frontend, locations on, colors off, formatting
and forced flush on, models/unsat cores/profiling off, output initially Native
with inference enabled. `solving_loop.ml:403–411,468–490` infers polymorphic
SMT output for the task extension. These are defaults, not an exclusion theorem
for option-changing task statements or every initialization/error path.

Initialization order matters: `main_text.ml:40–47` calls
`Printer.init_output_format` before entering the solving loop. That initializer
installs the diagnostic newline callback only when output is already SMT2;
later output inference just assigns the option. Consequently the current
selected path must not be priced as though that callback necessarily ran
after extension inference. The local `pp_smt` comment prefix still consults
the current option. The formula below deliberately excludes formatter/layout
bytes and remains separate from either callback configuration.

## A per-call payload bound

`frontend.ml:50–122` passes location, time, steps and optional query name to
`Printer.print_status`. The ordinary solve hook prints a status and raises
`StopProcessDecl` (`solving_loop.ml:149–166`), ending that declaration iteration.
This local control result is not a whole-file bound on status invocations:
other solve statements, timeout/error paths and signal handlers need accounting.

For one returning, valid-argument call, let:

- F bound the bytes of `Options.get_file()`.
- G bound the optional goal-name bytes.
- D bound each rendered signed integer, including any minus sign.
- T bound the rendered `%2.4f` time field, excluding surrounding ` ()`.

Then the explicit location/status/time/step/goal and regular-result **data
payload** is at most:

```text
P_status <= F + G + 4D + T + 80.
80 = 29 location punctuation + 1 following space + 23 validity status
     + 3 time wrapper + 9 step wrapper + 8 goal wrapper + 7 SMT result.
```

The three location integers are the line and two character offsets
(`loc.ml:32–37`); steps contributes the fourth. Taking independent maxima
covers optional fields and the status variants conservatively: the longest
validity string is `Inconsistent assumption`, which has no regular result.
The file and goal strings are passed with `%s`, not escaped by these functions.
Their complete paths and source-to-generated-name bounds remain inputs.

On a represented signed-63-bit OCaml integer interface, D=20 suffices.
The Dolmen SMT solve branch generates `g_` plus `string_of_int goal_cnt`, so
G<=22 for that branch (`solving_loop.ml:830–857`). This is a rendering bound;
it does not justify overflow of `goal_cnt`, location arithmetic or step counters.
Leaving the float-service input T explicit gives `P_status <= F + T + 182`.
No timer magnitude, locale or formatted-float bound is silently substituted.

`printer.ml:298–385` emits the diagnostic and regular status through Format.
The subtotal excludes `pp_smt`, pending formatter state, breaks/newlines,
indentation, callback expansion, interrupted/failed printing and other writes.
If H bounds all those effects for the call, its byte contribution is at most
P_status+H. This packet supplies neither H nor a whole-call occurrence bound.
There is intentionally no numeric exported q.

## Other output families that remain to be attached or excluded

| Family | Selected source and remaining obligation |
| --- | --- |
| Warnings and parser/type diagnostics | `solving_loop.ml:62–86,386–396,443–458`; Dolmen warnings are enabled except four named classes. Bound occurrences and fully rendered diagnostics or establish their exclusion on generated tasks. Default exit-on-error limits continuation after an error; it does not bound warnings or the first message. |
| Input-selected commands and option changes | `solving_loop.ml:532–578,737–777,905–975`; get-info may print statistics/reasons, echo doubles quotes, and model/assignment/core controls can change. Attach the actual driver/printer task language before excluding these branches. CLI defaults alone are insufficient. |
| Optional dumps and profiling | `solving_loop.ml:169–200`, `frontend.ml:86–94`, `signals_profiling.ml:45–83`; gated on options which need a complete command/task/state relation. No unconditional absence is exported. |
| Cancellation | `signals_profiling.ml:30–44` prints `User wants me to stop.` and `unknown` on SIGINT when profiling is off, then exits. Attach server cancellation and ambient signal policy, including interruption during output. |
| Runtime and library errors | `main_text.ml:40–47`, `solving_loop.ml:386–396`; uncaught exceptions and library/runtime reporting are not bounded by the status constructor. Retain separate source/service and byte premises. |

The source inventory is bounded to these entry/status/dispatch paths, not an
exhaustive solver call-graph theorem. A later complete q must compose all
reachable output families and their occurrences under the chosen task grammar,
configuration and signal/runtime assumptions. It must then join actual packaged
executable resolution and the server's merged stdout/stderr capture. The
[server interface](retained-why-server-record-capacity.md) and its existing
weighted multiplicities remain unchanged. The global suffix callback/save
budget is not restarted for this solver or any output stream.

## Evidence and scope

The offline checker verifies retained byte identities and recomputes the 80,
20, 22 and 182 arithmetic, including signed integer endpoints. It does not
execute Alt-Ergo, OCaml, GNATprove or Why3, and does not prove source control,
native refinement, formatting services or whole-output capacity. The actual
q and O exports remain null. #119/#153 stay incomplete; tools, admission and
Oracle are unchanged. Lead runtime model/effort and isolated author elapsed,
token and monetary measurements are unavailable; the check records its own
elapsed time.
