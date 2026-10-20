# Standard formatter control at the five retained cuts

2026-10-20 UTC, owner-authorized #119 / #153, Linux x86_64, base
`f79a5736e42c7cac9b414d929b2c64783a1e7b83`.

The selected continuation preserves the standard formatters' output owners,
tag callbacks and settings. Stdout uses the ordinary channel formatter;
stderr retains exactly one Why3 Debug newline/flush wrapper. Neither is the
Debug escape formatter. The initial queue, scan/format stacks and dynamic
line/width/depth counters of these two globals are **not established** by the
retained observations or the completed source argument. This packet must not
be consumed as a fresh-standard-formatter or complete output-capacity theorem.

The [new packet](../evidence/retained-why-standard-formatter-control-20261020/README.md)
binds source excerpts, selected complete native bodies and the actual retained
configuration inputs. The source/control reasoning below remains a review
obligation; the checker checks identities and concrete witnesses, not arbitrary
native indirect-call completeness. It runs no target, capture, disassembler,
source fetch or predecessor checker.

## Inputs and result interface

The cases are Put_Line/PID 17310, Put/17514, First_Or_Default/17631,
Is_Message/17704 and Input_Is_Valid/17869. The first four cuts precede the
scheduling `Gnat_checks.iter`; the last is entry to the first cvc5
`inline_trivial` application after counterexample introduction returned.
Use the accepted [initialization/client relation](retained-why-path-initial-state.md),
[driver envelope](retained-producer-driver-envelope.md),
[exit roots](retained-why-exit-initial-values.md) and
[ordinary-ending control](retained-why-ordinary-ending-control.md) at their
named scopes. In particular: fixed loaded code and the two selected plugins,
one OCaml worker, no application finalizers/alarms/Memprof/reflection, the
classified returning native/Thread clients, and nonreturning SIGINT save/exit.
These are premises already attached to the five processes, not consequences
of this formatter census. The external source/runtime and valid-value relation
is unchanged.

All five cwd `why3.conf` files have the same 1,946 bytes. Each contains main
magic 14, one editor with a command, and nine provers with name/driver/command;
all other required values either occur or have source defaults. Both retained
overlays are exactly `[main]\nmagic = 14\n` (18 bytes). The actual argv selects
Per_Check, cvc5/z3/altergo, counterexample off and an external socket, without
CLI display/debug/replay/manual flags. `WHY3DEBUG` and `GNATWHY3LOG` are absent.
This is evidence about these configuration bytes and their source consumers,
not execution of another configuration parser.

For **both** standard formatters the source-bound fixed profile is:

| Component | Value / owner |
| --- | --- |
| margin, minimum space, maximum indentation | 78, 10, 68 |
| maximum boxes, ellipsis | OCaml `max_int` = 2^62−1; `"."` |
| output string | `Stdlib.output_substring` partially applied to that formatter's stdout/stderr channel |
| output flush | closure calling `Stdlib.flush` on the same channel |
| spaces and indentation | Format `display_blanks state`, using the current output-string field, in chunks at most 80 |
| stdout newline | Format `display_newline state`, outputting one newline byte |
| stderr newline | exactly one Debug wrapper: saved default newline, then saved channel flush |
| tag markers | Format defaults, with no Color/ANSI wrapper |
| tag print callbacks; print/mark flags | `ignore`, `ignore`; false, false |
| tag/mark/tab stacks | empty; no selected producer installs tags or tabulation tokens |

This is an extensional/source ownership identity, not an invented runtime
closure address or channel-buffer bound. Channel descriptors, internal channel
buffers, services and failures keep their existing owners. The standard
formatters are distinct constructor allocations, also distinct from
`str_formatter`, private `asprintf` formatters and GNAT's escape formatter.

The ordinary queue, scan stack, formatting stack, `space_left`,
`current_indent`, `is_new_line`, `left_total`, `right_total` and `curr_depth`
remain unknown initially. They can change after the cut. A capacity argument
must supply their initial representation and prefix-preservation arithmetic;
the fixed margin does not bound total enqueued bytes, queue length or scan
totals. No global r/e allowance is reset: the caller's r≤3/e≤2 bounds remain
global post-cut bounds with exactly their existing scope.

## Why these callback owners are exact for the selected source prefix

`format.ml:937–1023` constructs the globals. Native `Format.entry` publishes
stdout at `camlStdlib__Format + 0x360` and stderr at `+0x368` after calling
`formatter_of_out_channel` with `Stdlib.stdout` and `Stdlib.stderr`. Their
unrelocated ELF slot addresses are `0xf8b450` and `0xf8b458`. The constructor
sets the profile above and initially creates one dummy system box; that
constructor state is not silently asserted to survive until the cuts.

`debug.ml:65–75` reads the output record, changes only newline, then records
the destination. Module initialization calls it once on stderr. Main later
calls it on its separately constructed escape formatter. The absent log branch
would instead select another newly constructed channel formatter. Neither later
call reinstalls, removes or adds a wrapper on stderr. No other selected source
client calls this setter with a standard formatter.

`Pp.wnl` is a real exported setter, so its mere definition cannot be ignored.
Its two source call sites, `string_of_wnl` and `sprintf_wnl`, first allocate
their own Buffer100 formatter. Pp's margin/max-box/ellipsis setters likewise
receive locally constructed file or Buffer formatters. `Loc.warning` constructs
its own Buffer100 formatter and sets its margin to 1,000,000,000. None aliases
a standard formatter under the typed/source ownership relation. `Format.sprintf`
and `asprintf` allocate a fresh Buffer512 formatter (`format.ml:1375–1395`);
they do not use `str_formatter`.

The linked compiler-library setters require separate treatment. `Misc.Color`
can wrap tag markers on all three globals, and Location's report wrapper can
leave a counting `out_string` installed if output fails. The earlier
[wrapper-family repair](retained-why-session-formatter-prefix-repair.md)
correctly admitted these possibilities without claiming selected reachability.
The selected paths here exclude their installation for these reasons:

- Initializing Misc constructs the Color closures, its private once ref and
  formatter list; it does not invoke setup. Its two native List.map callbacks
  construct `Cmx`/`Cmxa` data. Static callback words `0xea64c0` and `0xea64d8`
  resolve to those two constructor bodies, not Color callbacks.
- Initializing Location calls `in_file` and `register_error_of_exn`. The latter
  only prepends a closure to Location's private list. It does not call that
  closure or a reporter. Other linked initializer registrations use the same
  owner. The retained initializer-call ledger includes the linked compiler
  library entries: constant/ref/closure and container/functor construction;
  warning-option parsing; local-store registration; type/identifier/environment
  construction; and error-printer registration. Profile's indirect call builds
  a `Printf.sprintf` string. Env's indirect call finishes partial application
  of `add_extension`; `build_initial_env` receives `add_type ~check:false` and
  `add_extension ~check:false ~rebind:false`. These roots do not dispatch a
  Location report, compiler warning or Color setup. Pending/runtime successors
  use the already classified initialization clients, not arbitrary printers.
- Native Dynlink selects `Dynlink_common.Make(Native)`, not the bytecode linker
  or an OCaml compiler driver. Common's only Format path is a *private*
  `asprintf` duplicate-symbol message. The native owner reads headers/maps,
  performs consistency checks and invokes the selected module initializers;
  initializer exceptions are wrapped and reraised. Neither common/native
  loader nor `Dynlink.error_message` calls Location reporting. Merely opening
  `Dynlink_compilerlibs` does not invoke its reporters.
- GNAT's builtin-only branch directly loads `gnat_json` and `ada_terms`.
  Their initializers register language/parser/exception-printing functions;
  they do not execute an interactive compiler diagnostic. Their Why exception
  printers receive the caller's formatter. The selected driver's plugin and
  preparation envelope has no subsequent module load or compiler diagnostic
  route. Why's ANSI tag installer is in the separate `why3prove` tool, absent
  from GNAT's selected main. The source/native owner relation is essential;
  lexical absence and direct-call scans alone would not justify this exclusion.

Thus Color setup and Location counting wrappers do not execute on this selected
prefix/continuation. This is narrower than deleting them from the general
wrapper family. Extending the selected loader, compiler use or callback scope
invalidates the exact profile until the new paths are joined.

## Warning destination and standard-output writers

Native initializer order is Format, compiler libraries/native Dynlink, Why
Debug/Loc, GNAT util/config, GNAT report, GNAT checks/main. In particular,
`Gnat_report` is initialized **after** config. Its entry installs `add_warning`
in Loc's warning-hook ref; `add_warning` stores the resulting string in the
private warning list. Optional location text uses a private `Format.sprintf`.
After this point a selected `Loc.warning` does not enqueue stderr output.
The hook stays installed: the only GNAT replacement is the absent log branch.

Before this installation Loc's default hook does use stderr. The exact base
and overlay configs avoid Whyconf's MissingField/strategy-space warning arms
on their ordinary path. Debug config/plugin messages are disabled by the
actual environment/flags. A configuration failure is converted to a string
and reraised as `ConfigFailure`; GNAT then calls abort. The handler does not
resume configuration. Before controller initialization no SIGINT save callback
has been installed. These facts close the ordinary configuration-warning
source; they do not substitute for the later interrupted-registration history.

The selected post-cut standard writers are recorded in the control ledger:

| Root | Destination and failure/control behavior |
| --- | --- |
| `Gnat_report.print_messages` | stdout, single-line JSON after ordinary ending's save/report construction; no implicit final flush |
| `Gnat_util.abort_with_message` | stdout, structured JSON with hv boxes/breaks, then `exit 1`; output can raise before exit |
| outer GNAT exception handler | builds a private Pp string, then calls the abort writer; a failure in this handler escapes it |
| installed uncaught handler | privately builds exception/backtrace text, then calls abort; not a restart of scheduling/ending |
| standard Format exit hook | flushes stdout, then stderr, once at most under the persistent gate; stderr flush is skipped if stdout flush raises |
| Debug statistics hook | writes the distinct escape formatter; a later ending may copy its current Buffer contents into warnings, not change standard callbacks |
| `Printer.int_of_string` failure | catches every exception of its conversion; stderr diagnostic followed by assertion, unless printing itself raises |
| `smtv2_model_parser` malformed-expression arm | stderr diagnostic, then failwith; requires `get_model = Some printing_info` at `Call_provers.record_model` |

The last model path is retained conservatively, not declared unreachable merely
from the user-facing CE-off flag: `Driver` computes `get_model` from task meta.
Removing it requires that actual meta/guard attachment. It still installs no
formatter settings, tags or tabulation. Printer's broad catch similarly cannot
be erased merely because intended syntax parameters are small decimal strings.
The table bounds neither diagnostic frequency nor their payload sizes.

Whyconf's catch-and-eprintf plugin loop is excluded by GNAT's direct builtin
loading. Controller's `Cleaning error` writer belongs to `clean`, not ordinary
ending's APa-only `remove_all_valid_ce_attempt`/`remove_subtree` path. Session's
archive message belongs to `archive_session`, not `save_session`; interactive
strategy loading and other tool/transform printers are outside the selected
driver/registration envelope. Commented-out debug prints are not calls.
The lexical census retains these distinctions for review; it is not itself a
reachability proof. `Printf`/runtime writes directly to a channel are not Format
queue writers, although their service/storage capacity remains separately due.

Both JSON printers treat keys/string contents as data. Escaped `@`, newline,
tab or tag-looking text cannot install Format settings, tags or tab boxes.
The only `%a` callbacks used by these JSON roots are their own recursive JSON
printers. `%f` for StandardFloat remains a real conversion obligation. Exn
printers run while forming the private error string, not later from stdout's
queue. Copying `Buffer.contents escape_buffer` creates a string; adding that
string to the warning list does not copy it, and JSON traverses its bytes.
The Buffer copy and later JSON escaping/output require separate bounds.

## Why initial global queue freshness remains open

Both retained exit gates are true. Their persistence proves that neither exit
hook has started, not that no standard-output writer has started. The precise
source path preventing the stronger inference is:

1. `Gnat_checks.iter_leafs` (`:490–499`) protects the call of `f` inside
   `List.iter` with `with Not_found -> ()`.
2. `normal_handle_one_subp` supplies `register_goal`. That function calls
   `Gnat_expl.search_labels`, or calls `abort_with_message` for a nontrivial task
   without a trace label (`gnat_main.ml:48–72`).
3. `Gnat_expl.parse_check_string/read_label` (`:425–457`) also catch `Failure`
   around label conversions/location parsing and call abort. These are
   exception-class catches, not tests proving the failure came from malformed
   input. A pending save failure in their protected expression is not excluded
   merely by valid label strings.
4. Abort begins stdout JSON before calling exit. A save/pending failure during
   that output can escape to `iter_leafs`; a `Not_found` can be consumed there
   and registration can continue. A signal save that raised before its own exit
   need not consume either hook gate. The abandoned writer's global state is
   not rolled back.

This is a real receiving-catch path that requires exclusion or accounting,
**not a claim that the complete interruption/exception sequence actually
occurred in any capture**. Its eligibility on the actual initial task/label
and service domains remains unproved. No post-cut r/e bound is applied to the
earlier prefix. A finite pre-cut bound may suffice, but it must independently
account for the prefix, partial writes and signal failures. The current task
projection alone does not encode every abandoned pre-cut write.

The configuration prefix and callback-profile proof therefore do not supply
stdout queue freshness. Stderr's remaining failure-diagnostic history also
has no complete prefix bound here. The packet reports both dynamic initial
states as unknown; it does not use an empty log, a true hook gate, successful
registration, or Debug's private freshness theorem as a proxy.

## Exact missing state and subsequent preservation

For each process the packet projects retained read coverage at the two standard
global slots using its own load bias from the known Debug hook code. The
retained observer's `formatter_record` names Debug's formatter. A pointer or
28-field record for that object is not a read of either standard global.
The focused scan finds **zero covering raw reads of either standard root slot
in all five captures**. No initial standard dynamic graph is supplied by this
packet. To replace the
missing prefix theorem by observations, the minimum required input is:

- Both standard root-slot words at the actual cut, and each pointed-to
  formatter header plus all 28 fields, with raw read provenance and aliasing.
- The three-field Queue record, complete linked cells, each element's
  size/token/declared length, and every reachable token payload/string. Check
  first/last/count coherence and the absence of hidden cycle/tail alternatives.
- Scan-stack and formatting-stack two-field records, complete lists and
  elements, including scan-to-queue-element identity and dummy/sentinel state;
  and the dynamic integer/boolean fields at offsets 8–13 in source field order.
- If the source-bound profile is not imported, additionally all five output
  closures with their captured environments, saved output records, channel
  identities; four tag callbacks and any captured wrapper chains; margin,
  max-box/ellipsis values; and complete tag/mark/tab stacks including referenced
  tab lists. These words must not be guessed from constructor defaults.

The numbering above is zero-based: fields 8–13 are space_left, current_indent,
is_new_line, left_total, right_total, curr_depth; the queue is field 27;
scan/format/tab/tag/mark stacks are fields 0–4. Callback fields are 16–20 and
23–26. The source layout and native global-slot witnesses are retained.
This is a precise missing-input specification, **not a request or authorization
for another capture**. First prefer a finite source-prefix bound or an existing
raw-span attachment if one becomes available.

Even a fresh initial graph would not finish preservation. `pp_enqueue`
(`format.ml:218–220`) increments `right_total` before `Queue.add` allocates and
publishes its cell. Its native body retains the same order. A SIGINT exit path
can enter the standard flush hook while that global record reflects only a
prefix of the interrupted enqueue. The handler does not return normally to
the interrupted enqueue, but higher catches or later abort reporting can reuse
the changed global formatter. Similar stack/queue drain ordering must be
included in any arithmetic invariant. At-most-once hook entry is not successful
completion or transactional reset.

The exact callback/settings profile is preserved by those paths because they
do not invoke setters or tab/tag producers. That result deliberately stops
short of finite queue/output/request capacity, output fidelity, full R/U,
whole-pipeline capacity or #153 completion. Parent owns independent review,
integration and shared issue/memory updates. Oracle, tools, pins and admitted
production behavior are unchanged.
