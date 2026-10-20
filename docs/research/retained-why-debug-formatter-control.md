# Debug escape formatter before first Stats use

2026-10-20 UTC, Linux x86_64, research #119 / #153. Author base `323a54cc7e`;
selected GPT-6 Astra / Extra High, without runtime-setting or token/cost telemetry.

Under the existing selected source/runtime/loader behavior relation, the five
retained processes' Debug formatter is `Gnat_main.escape_formatter`. Its
constructor state, followed by one Debug newline-wrapper installation, is
preserved at the retained cuts and until the first entry to the Stats exit hook.
The Buffer position is **zero**, with capacity **42**. The formatter queue has
**one constructor dummy-box token**, not zero tokens. Its callbacks and settings
have concrete source owners; the newline wrapper has a **16-byte own native
frame**, additional to the bodies in the earlier private F component.

This is a source/control result with checked input attachment. The missing
pointer descendants in the raw observations remain unobserved. Matching scalar
defaults did not establish this result. No constructor-freshness claim applies
after a partial Stats hook, and no whole-exit/save stack or capacity claim follows.

The [packet](../evidence/retained-why-debug-formatter-control-20261020/README.md)
retains the exact source excerpts, full-projection client inventory, resolved
debug-output flag names, input attachment and selected native witnesses. Its
checker validates those concrete inputs; neither lexical search nor passing
Python proves the semantic argument below.

## Input and source boundary

The 603 Why ML/parser/C sources are the complete retained `src/` and `plugins/`
projection at revision `9390baf120ef260547dfa14f08e11c890b203d9c`. OCaml sources
remain at `8eb41f72ded84df884c3671734c947f612091f84`. Source transfer uses the
[existing behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary),
including valid representations and the selected typed/reflection boundary.

The five cases and PIDs are put_line/17310, put/17514,
first_or_default/17631, is_message/17704 and input_is_valid/17869. Their exact
`process.json` and `exit-hook-roots.json` members are matched to the frozen
capture manifest and the accepted
[prefix attachment](retained-why-path-initial-state.md#exact-input-and-initialization-attachment).
That attachment supplies the same executable/seven images, one initial OCaml
worker with no added worker, the fixed two plugins `gnat_json` and `ada_terms`,
and the source-owned native/pending capabilities. The source-prefix argument
excludes generic module reflection, finalizer/alarm registration and Memprof
tracking; disabled sampling does not exclude the classified native context hook.
These capability facts are reused, not inferred from an unchanged image map.

Every argv selects the built-in `cvc5,z3,altergo` provers, `per_check`, CE off
and an external socket. No debug, replay, standalone or prepare-shared option
is present. `WHY3DEBUG` and `GNATWHY3LOG` are absent from each recorded environment.
The exact source environment writers set `TEMP`, `TEMPDIR`, `GMON_OUT_PREFIX`
or unrelated native-process variables; no selected writer adds either missing
debug variable before its read. The source registration mechanism snapshots
`WHY3DEBUG` only once when initializing Debug.

The gates of Debug Stats and the standard Format-flush hook are both still true
(tagged 3), with no registered-statistics roots. The accepted persistent-chain
argument matters: `Stdlib.at_exit` only prepends, and each link changes its own
gate from true to false before invoking its callback. No client can reset or
remove that gate through the selected typed interface. Therefore neither hook
ran before the cut, including an invocation that raised after partially printing.

## All selected routes to Debug output

Debug's flag type is abstract in its interface; all `flag_value` field uses in
the complete source projection are inside `debug.ml`. `gen_register_flag`
returns an existing same-name flag, or creates one whose value is membership
in the initially enabled names. With absent `WHY3DEBUG`, every new flag starts
false. Same-name registration is sharing, not an independent new false flag.
The relevant writer and alias cases are:

| Source route | Selected effect or exclusion |
| --- | --- |
| `Gnat_util.set_debug_flags_gnatprove` | Enables `vc_sp`; its Vc consumers only choose the VC algorithm. |
| `Gnat_main` after setup | Enables `rac:execute_no_builtin_mach` and `stats`; the former only controls built-in interpreter registration, the latter timing/statistics state and its exit hook. |
| `Gnat_config` argument handlers | `--debug-why3` can enable an arbitrary named flag. The debug/stack-trace/save-VC options enable other flags. Every such option is absent; their refs start false and `Arg.parse` uses the recorded argv. |
| `Gnat_config` later setup | `keep_vcs` requires debug/save-VC mode; `type_only` requires No_WP. Both conditions are false here. |
| `Why3printer.print_task` | May temporarily enable `print_attributes`, including retaining it if interrupted before restoration. Its Pretty/Expr aliases only control printing attributes to a supplied formatter; it is not a debug-output flag. This argument does not require that restoration succeeds. |
| `Debug.Args` / `Whyconf.Args` | CLI option queues can enable arbitrary flags. GNAT uses its own `Arg.parse` and calls `Whyconf.read_config` directly; it never calls `Whyconf.Args.initialize/complete_initialization` or the Debug option handlers. Reading configuration does not run those handlers. |
| IDE, documentation, shell and Python-plugin clients | Their entry/client families are outside the selected executable/plugin/command route. The retained native body index lacks the named frontend prefixes; the two loaded plugin sources contain no flag setter. |
| `src/jessie/register.ml` apparent setter | Inside an OCaml comment, not executable code. |
| Glob initializer | Only unsets `track_symbol_use`. No selected client of `toggle_flag` exists. |

`flag-flow.json` resolves every lexical `Debug.dprintf` first argument in the
603-source projection, including comments and unselected sources as an
overapproximation. Each direct variable resolves to its registration/lookup
name. Imported aliases are explicit: Check_ce flags, Pinterp_core.trace_exec,
Cfg_paths.debug and Pdriver.debug. The only generic flag parameter is
`Trans.print_meta`'s `f`; all three source callers pass `Libencoding.debug`,
registered as `encoding`. None of the resulting sink names is among
`vc_sp`, `rac:execute_no_builtin_mach`, `stats`, or even the conservatively
allowed `print_attributes`. The setter cases above therefore leave every
selected debug-output flag false. This is a flag-identity/caller argument,
not an inference from a variable being named `debug`.

For a false flag, `Debug.dprintf` selects `Format.ifprintf`. The installed
branch at `0x559dfc` tail-transfers to `ifprintf_1776`. That source function
discards its formatter argument and calls `make_iprintf ignore ()`.
`make_iprintf` consumes arguments/format structure without calling supplied
`%a`/`%t` printers or interpreting formatting tokens on a formatter. It can
allocate or raise; it neither writes nor retains the discarded escape formatter.
Evaluation of caller arguments is still part of the source caller audit, rather
than being dismissed by this fact.

There are only two external source families using `get_debug_formatter`:

- `Smtv2.debug_print_term` obtains the alias, but its `Pretty.print_term` call is
  guarded by the same disabled `smtv2_printer` flag. Its surrounding dprintf
  calls also take the ignored branch.
- `Trans.print_task_goal` and the local printer of `create_debugging_trans`
  really print directly, without a flag guard. The complete source projection
  has no caller/reference to `create_debugging_trans` beyond its own definition
  and interface. `print_task_goal` is private and only reached by that helper.
  These bodies exist in the executable; symbol presence does not imply use.
  Their exclusion uses the audited typed source clients and the accepted
  no-reflection/fixed-plugin boundary, not merely absence of a direct native call.

There is no module alias/open/include of Debug hiding an unqualified external
client in this source projection. Dynamic flag registration from GNAT arguments
and exported first-class getters are handled above. These facts do not purport
to exclude arbitrary machine-code pointer fabrication outside the existing
behavior relation.

## Constructor, setup and state ownership

`gnat_main.ml:266–268` constructs `Buffer.create 42`, constructs a fresh Buffer
formatter, and calls `Debug.set_debug_formatter` on that formatter. Reaching
any captured cut requires this top-level prefix to have completed. The source
does not recover from a failed constructor by continuing at a captured cut;
the accepted pending clients cannot invoke those cuts as callbacks.

`GNATWHY3LOG` would select the second setter in `Gnat_main`, on a new channel
formatter, and install a warning hook using it. Its environment lookup raises
Not_found here, before opening the file or invoking the setter. The only other
setter is Debug's earlier initialization on **err_formatter**, a distinct value.
`escape_formatter` is otherwise only named by its definition and that one setter.
`escape_buffer` is additionally read by ordinary `ending` with `Buffer.contents`;
that operation copies the bytes without modifying the Buffer or publishing it.

The constructor state is exact (`format.ml:937–1007`):

- Buffer position 0, capacity 42, backing storage shared with its initial buffer.
- Queue length 1, containing unknown-sized `Pp_begin(0,Pp_hovbox)` of length 0.
- Scan stack length 2: the system-box entry with left_total 1 over the sentinel
  empty-text entry with left_total -1. Format/tbox/tag/mark stacks are empty.
- Margin 78, minimum remaining space 10, maximum indent 68, space left 78,
  current indent 0, new-line true, left/right totals 1, current depth 1,
  maximum boxes `2^62-1`, ellipsis `.`, and both tag switches false.

The initial out_string closure is `Buffer.add_substring escape_buffer` and
out_flush is ignore. Default newline/spaces/indent callbacks use the same
formatter's out_string field. Debug setup reads this five-function record,
copies it while replacing only out_newline, writes the five fields, then
publishes the formatter in Debug's ref. The wrapper captures the **old record**;
it calls its default newline then its old ignore flush. It does not capture
itself. Exactly one setter call on escape gives wrapper depth one.

The native wrapper is `camlWhy3__Debug__fun_2950`: indirect call at `0x559c8d`
selects captured default `Format.fun_2407`, and tail transfer at `0x559ca7`
selects captured Buffer-flush `Format.fun_2447`. Its eight-byte reservation plus
return slot gives **16 bytes** of own stack; its poll reaches `caml_call_gc`.
The target closure identities follow the constructor/setup source environment,
corroborated by the retained bodies. This extra body must be added explicitly
when composing the earlier F interface for this global use. No multiplicity,
runtime bridge or R cost is silently included in the 16 bytes.

## Earlier signals, exceptions and continuing ownership

An earlier SIGINT save can allocate, mutate session/output state, throw and be
consumed by an enclosing catch. None of that implies the escape formatter was
used. Selected saves create their own formatters; their debug calls remain
disabled. If a save reaches `exit`, the Stats once gate is consumed before
Stats printing, so the observed true gate excludes that earlier invocation.
SIGVTALRM and the classified native owners do not obtain a new typed escape
alias. No no-signal or successful-save premise is needed for this separation.

GNAT failure reporting builds a string through a fresh sprintf formatter and
prints its JSON/error output through its own reporting route. Standard/uncaught
diagnostics and the standard Format hook use their own global formatters. The
getter/setter/flag census above also covers diagnostic calls to Debug; a thrown
exception does not create a new setter or enable an output flag. Native failures
may still raise or terminate under their ordinary contracts.

From each cut through the selected Per_Check/CE-off/non-replay continuation,
no new config/plugin/interactive command route is entered. The same alias and
flag induction applies until Stats first starts, even when a signal or failure
enters that hook before ordinary ending completes. Constructor state is thus
preserved up to that entry. The registered-statistics list remains empty:
its API only prepends and has no external client in the retained projection.
The first actual escape writes are the selected Stats timing prints, if reached.

Thereafter Stats can change the queue, stacks, counters and Buffer. An exception
can leave partial state, and the once gate prevents retrying the hook rather
than rolling its work back. Output callbacks/settings remain those described
above under the same selected continuation; formatter/Buffer operations do not
replace them. Bounds and invariants for partial Stats traversal, subsequent
exception processing, standard/error formatter phases and full R remain with
their owners. Global `r<=3` and `e<=2` are unchanged; ambient A_pre stays separate.
This packet closes a named initial-state/control premise, not complete resource
sufficiency, and makes no production, Oracle, tool-pin or language change.
