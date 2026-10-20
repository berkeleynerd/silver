# Standard-output failure routes in the retained controlled prefixes

2026-10-20 UTC, owner-authorized research #119 / #153, Linux x86_64. This is
a separate attachment to the frozen
[standard-formatter profile](retained-why-standard-formatter-control.md)
(`adb3f7e7b06f78aea5598e5f318f93a87362660e`); it does not amend that packet.

The five retained debugger-controlled prefixes exclude the particular
**SIGINT save failure → abort output → later save `Not_found` → registration
recovery** route left open there. The signal exclusion was already accepted in
the [initial-registration review](../reviews/review-initial-registration-bound-20261020.md)
of `66ba7f63647e72f0b1e683c39f4017803fc78149`; this attachment reuses it.
Ordinary failures of the selected abort JSON writer cannot supply the
`Not_found` needed by `Gnat_checks.iter_leafs` either, under the documented
source/runtime/client relation. The separate `Printer.int_of_string` stderr
diagnostic during controller driver loading cannot return from controller
initialization to registration after it has begun writing.

These are control and exception-family results for named routes. The
[packet](../evidence/retained-why-standard-prefix-observer-20261020/README.md)
continues to export **null** for both initial global dynamic formatter states.
It supplies neither their raw graphs nor a complete new census excluding every
pre-cut writer. In particular it does not turn a collection log or true exit
gate into a queue-freshness theorem. Parent integration must compose all
selected-prefix writer exclusions before replacing those nulls.

## What is established by the retained observer relation

The cases are Put_Line/17310, Put/17514, First_Or_Default/17631,
Is_Message/17704 and Input_Is_Valid/17869. The first four cuts are
`Gnat_checks.iter` entry. The last is the first cvc5 `inline_trivial` entry,
after the first `counterexamples_dependent_intros` application returned;
inherited registration endpoint metadata is not substituted for that cut.

The retained scripts launch the pinned GDB with `-nx -q -batch`, turn
auto-loading off, install the fixed observers after `starti`, and issue one
`continue`. On its return they finalize the capture, kill the inferior and
quit. The fixed breakpoint callbacks automatically pass their intended normal
events; they contain no signal-stop resume hook or policy override. An
unexpected signal stop makes finalization fail to reach the endpoint. The
launchers' timeout path sends SIGTERM to the debugger process group; all five
actual records have `timed_out=false`, return code zero, completion true and
no capture failures. Each log ends with its own inferior killed.

The reused target-free query of the same debugger bytes and environment says
Stop=Yes for SIGINT, SIGSEGV and SIGBUS (SIGINT also has Pass=No). It is a
**verified default-policy query**, not a per-inferior `info signals` snapshot.
Attaching that default to these processes uses the accepted fixed-launcher,
observer and ordinary debugger stop/delivery semantics. The attachment does
not silently replace this premise with an assertion that the actual policy
was separately measured. No new debugger query or process execution was run.

Input_Is_Valid has a stronger, independent source-entry attachment: its actual
plan installs unconditional forbidden-call breakpoints at
`camlGnat_main__save_session_and_exit_3133` (ELF `0x52e680`) and
`camlWhy3__Session_itp__save_session_4339` (`0x7fc850`). Both have zero hits.
Unlike the GC guards, these forbidden guards have no pre-protection bypass.
Their retained first 32 bytes agree with the accepted native binary, and their
process addresses have the same load bias as the other forbidden entries.
This excludes entry to either save root before that cut under the ordinary
breakpoint/source-entry relation, without relying only on default SIGINT policy.
The registration plan has no equivalent save-entry guard; it uses the accepted
signal-policy argument.

This does **not** prove that all pending actions or all signals were absent.
Linux systhreads' tick thread directly records SIGVTALRM in the runtime pending
array, which need not involve an OS signal stop. Its selected one-worker
`Thread.preempt`/native yield client returns without calling application code.
The accepted [initial source/client relation](retained-why-path-initial-state.md)
also excludes application finalizers, alarms, Memprof start, reflection and
additional OCaml workers. These premises are needed at pending-action checks
in allocation, channel operations, blocking sections and `caml_raise` itself.
The Linux signal dispatcher does not turn a SIGVTALRM bit into SIGINT; the
pending array starts zero, and installing a signal handler does not synthesize
its signal. Protected GC guard hits are empty; the four retained startup GC
hits remain present in every case and are not erased from the record.

## Why ordinary abort failure does not restore registration

The receiving catch is `Gnat_checks.iter_leafs` (`gnat_checks.ml:490–499`):
its protected `List.iter` invokes `register_goal`, and its only handler is
`Not_found -> ()`. `register_goal` may call abort for a missing nontrivial
trace label. `read_label`, `parse_check_string` and `Gnat_loc.parse_loc` can
also call abort from their ordinary error arms. It is unnecessary to assume
all labels are valid to analyze what happens after such a call.

`Gnat_util.abort_with_message` (`gnat_util.ml:4–9`) first prints exactly:

```
Record ["error", String s; "internal", Bool internal; "results", List []]
```

It then calls `exit 1`. The error string has already been evaluated. The
JSON getters that raise `Not_found` are not used by this printer. Its reached
calls are closed as follows:

| Owner | Selected operation and exception relevance |
| --- | --- |
| JSON recursion | Three constant keys sorted by `List.sort` and `String.compare`; a string, bool and empty list as values. No JSON field lookup, integer/float value branch or externally supplied printer. The exact three-element sort uses only its comparison callback and list allocation. |
| String escaping | `String.iter` calls only `Json_base.char`. The accepted [all-byte extension](retained-why-json-byte-escape.md) covers every byte, including fixed `Int_x`, zero padding 4, no precision for `\\u%04x`. Bytes are data; they do not become format directives. |
| Typed formats | The `%a` callbacks are the fixed JSON/string/list functions. `make_printf` receives compiled format values, with no dynamic format substitution or custom callback. `Format.output_acc` does still construct a private Buffer formatter and parse the fixed box description `hv 1`; `open_box_of_string` uses string slicing, integer conversion and a closed string match, not a lookup raising `Not_found`. Invalid box descriptions use `Failure`. |
| Format core | Selected text/box/break operations, queue/scan/format-stack changes and the fixed callbacks from the predecessor profile. Queue and Stack expose their own distinct `Empty` constructors; their option operations do not raise `Not_found`. No selected tag/tab producer supplies another callback. Incomplete queue mutations do not create a new exception constructor. |
| String/Buffer/padding leaves | Allocation and bounds checks, fixed bool text and byte-to-hex conversion. Relevant explicit errors are `Invalid_argument` or `Failure`, with allocation errors owned by the runtime. Private box formatting has Buffer callbacks, not an arbitrary stdout callback. |
| Standard output callbacks | The predecessor's channel-bound output and flush, default newline and blanks. `output_substring` bounds failure is `Invalid_argument`. Native channel write errors use `caml_sys_io_error`, selecting `Sys_blocked_io` or `Sys_error`; channel-mutex creation uses `Out_of_memory` or `Sys_error`. These are distinct from the native `Not_found` constructor. |
| Runtime exception propagation | Allocation can fail or native services can raise; `caml_raise` can replace its original exception with a pending-action exception. The last possibility is why the accepted pre-cut signal exclusion and returning-client closure above are required. It is not justified by merely searching the print code for `Not_found`. |

The native witnesses retain the receiving catch, label error handlers, fixed
box parser, Format accumulator, channel/locking error routes and exception
constructors. Previously retained JSON/native formatter witnesses are imported
by identity. As elsewhere in this research, correspondence to the selected
typed source, valid runtime values and represented native service behavior
remains the external source/runtime premise. This is not a theorem about
arbitrary memory corruption or a new proof of numeric/channel service success.
It allows ordinary failures in their documented families; it does not assume
every channel write or allocation succeeds.

Consequently, after abort starts enqueuing stdout data, an ordinary output
failure cannot produce `Not_found` for `iter_leafs`. The nested receiving
`Failure` handler in `parse_check_string` does not defeat this: it only builds
a fixed `%s` message privately and calls abort again. `Gnat_loc`'s error
message similarly uses string concatenation. These handlers neither look up
application data after the first write nor convert failure into `Not_found`.
Their further failures either reach another such abort or escape registration.
The outer GNAT handler may run a registered exception printer while constructing
its private error text, but an exception from that handler cannot re-enter the
unwound registration continuation. The uncaught handler likewise does not
restart it.

If abort returns from its JSON writer, it enters `exit`, which cannot precede
the actual cuts under the accepted exact hook-chain and
[persistent initial exit-gate relation](retained-why-exit-initial-values.md).
If output or private error construction never returns, the cut is not reached
either. Thus this route cannot leave abandoned stdout enqueues **and then
reach these cuts** through the named receiving catch. A `Not_found` while
constructing the very first error argument may still be consumed before abort
is invoked; it creates no abort output. No initial formatter graph, bound on
the number of label visits, or reset of the post-cut r/e budgets is used here.

## Stderr needs its own receiving path

`Printer.int_of_string` (`printer.ml:224–228`) catches every exception of its
integer conversion, prints `bad argument for int_of_string: %s@.` to stderr,
then asserts false. A successful diagnostic therefore raises `Assert_failure`;
an interrupted diagnostic may raise its own output failure. Either case must
be followed through its caller; valid intended decimal syntax alone would not
exclude an allocation or service failure in the conversion.

During initial driver loading, the calls from `Driver.add_local` go through
`Printer.syntax_type/syntax_logic` and the syntax-parameter conversion. The
surrounding `Loc.try2` only wraps an exception as `Located` or reraises it.
`Driver.load_driver_raw`, `Controller_itp.load_drivers` and
`create_controller` do not catch it and return a usable controller.
`Gnat_checks.init_cont` calls `create_controller` outside its session-load,
add-file and reload handlers. Hence that diagnostic cannot be followed by
successful controller initialization and registration. The outer GNAT abort
handler is outside the unwound initialization; even a failure while reporting
does not resume it. This establishes the named stderr no-recovery result
without asserting every driver syntax string is valid.

Later syntax substitution during task printing is distinct. The first four
captures forbid driver preparation as well as printing and prover requests.
Input_Is_Valid records one preparation and stops before `inline_trivial` runs;
its print/prover-call/request forbidden guards also have zero hits. Under the
selected driver envelope these facts exclude the task-printing and prover
result/model-parser stderr routes before these particular cuts. They do not
exclude those routes after the cut, and CE-off alone is not treated as a proof
that `get_model` is absent from later task metadata.

The predecessor's earlier config-warning selection, Debug escape destination,
warning-hook timing, builtin plugin loading and exclusion of interactive,
cleaning and archive writers must still be imported separately. This attachment
does not replace their source reasoning with the no-recovery lemmas above.
It leaves full prefix-writer composition and the resulting dynamic graph to
integration. Later signal re-entry, nontransactional enqueue/flush arithmetic,
output payload bounds, channel capacity, physical sufficiency and complete
writer/save capacity remain outside this result.

## Evidence and handoff

One focused attachment checker reads retained metadata/scripts and source
archives, checks selected complete native bodies against the accepted ELF,
and retains the case/guard projection. It executes no archived script, target,
debugger query, capture, disassembler, source fetch, predecessor checker or
proof suite. The retained result is a witness attachment; the source/control
argument requires parent review. Selected GPT-6 Astra / Extra High;
runtime-confirmed settings and token/cost telemetry are unavailable. Actual
check time and host are in the packet's round record. The live harness goal
was null. Parent owns review, integration and shared issue/memory updates.
