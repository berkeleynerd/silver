# Retained inline callback closure: exception or charging proof remains open

Research [#119](https://github.com/berkeleynerd/silver/issues/119), 2026-10-18,
Linux x86_64. **Complete continuing-call identifier capacity remains
unestablished.** The SIGINT handler can create identifiers while saving the
session. If a relevant exception then escapes into an interrupted catch that
continues the transform, that work must be accounted for. The packet establishes
this conditional implication, **not an actual post-registration exception route**.
The originally proposed stable missing-task witness is withdrawn: the detachment
guard performs the same lookup and skips a node when its task is absent.

Independent review `64c4bb749bf4f6347853ebe7a8ddf13c024fe127`, finding R1,
identified the omitted guard in author commit
`20e801be186ce6e41cb7c53d44d6cd072fa06dda`. This correction preserves that commit
and its checks as history. It establishes neither a replacement counterexample
nor complete callback closure; no signal, escaping callback exception or overflow
was observed.

The accepted [private-counter result](retained-why-inline-identifier-state.md)
is unchanged: starting ref **60,496** (raw tagged **120,993**), at most **1,145
accounted source registrations**, endpoint **61,641**, below `2^62−1`. Its
same-process attachment covers 244 input roots, 14,477 corresponding input
blocks and all 6,704 old Hsdecl objects in 5,003 buckets, under the retained
`E=8, V=6, T=3, A=80` envelope. This packet neither reruns that successful replay
nor adds signal-save registrations to its bound.

## Exact inputs and evidence level

The [packet](../evidence/retained-why-inline-callback-closure-20261018/README.md)
pins the predecessor author `c8bc383e111b5b5d5460d5bb568bf37417cbe6eb`, BSS
metadata repair `554839c115df02bb18208e92871651f72ac5472a`, and accepted review
`83f3d905a69e3bffbe73fc4e85743fc7a36bf4be`. `binding.json` joins the predecessor's
`capture/summary.json` mapped-image identities and `plan.json` executable
identity to the files read here. The executable is 24,561,432 bytes, SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The retained map contains exactly two OCaml plugins, `ada_terms.cmxs` and
`gnat_json.cmxs`; its other images are libc, libm, libgmp and the ELF loader.

Why3 source is revision `9390baf120ef260547dfa14f08e11c890b203d9c`;
OCaml source is revision `8eb41f72ded84df884c3671734c947f612091f84`.
`sources.tar.gz` contains the exact selected files and a source identity index.
`native.tar.gz` contains numeric reference extraction and retained owner/witness
bodies from the pinned executable. No target, debugger, compiler, solver or
native capture was started in this round. Objdump reads ELF files as data.

These are reviewed source/interface arguments supported by native witnesses,
not a machine-checked arbitrary native control-flow or alias theorem. The
extractor enumerates numeric instruction operands, RIP-relative targets,
aligned allocated non-executable PROGBITS words, dynamic relocations and dynamic
symbols. Nearest-symbol labels are location aids, not object ownership proofs.
External library package source pins were not established by the Why3 build
scripts; no arbitrary current package was substituted for installed code.

## Surviving signal facts and withdrawn missing-task witness

All source paths below are archived under `why3/` or `ocaml/`.

1. `src/gnat/gnat_main.ml:298–309` defines `save_session_and_exit` and line 335
   installs it for SIGINT after controller initialization. Its small
   `Invalid_argument` catch covers setting SIGINT/SIGHUP/SIGTERM to ignore.
   **`C.save_session c` is outside that catch and precedes `exit signum`.**
   `src/gnat/gnat_checks.ml:752–753` calls `Session_itp.save_session`.
2. `src/session/session_itp.ml:2212–2245` clears and recomputes session shapes.
   For each `APn g`, it first tests `not (is_detached s any)` and only then
   calls `get_task s g` and computes its explanation and shape. `get_task`
   (310–311) uses `Hpn.find s.session_raw_tasks id`, but `goal_is_detached`
   (369–371) performs that same lookup and catches `Not_found` as `true`.
   `is_detached` delegates its APn case to that predicate (385). A stable absent
   raw task therefore fails the guard and is skipped; it is not an escaping
   `Not_found` witness.
3. Current shape version SV6 (`src/session/termcode.ml:240`) selects
   `Gshape.t_bound_shape_task` through `Sshape.compute_and_add_shape`
   (`session_itp.ml:174–183`). Gshape calls `Shape.t_shape` on proposition
   formulas (`termcode.ml:599–627`). This calls `t_open_branch`, `t_open_bound`
   and `t_open_quant` (443, 466–470, 490); it does not avoid binder opening
   merely because the selected version uses Gshape.
4. `src/core/term.ml:799–832` opens binders by cloning variable symbols.
   `create_vsymbol` at 36–39 calls `Ident.id_register`; the latter increments
   the private ref (`src/core/ident.ml:187–192`). Applicable visited tasks can
   therefore cause handler-side registrations. This fact does not establish
   that any exception subsequently escapes the handler.
5. `src/core/trans.ml:75–103` implements `current task` as
   `try Some (Wtask.find h task) with Not_found -> None`; `accum` treats `None`
   as a cache miss and continues. **If** a signal callback's `Not_found`
   escapes after registrations at this interruption point, the fold can catch
   it and continue. No such antecedent is established here.
   `runtime/signals.c:201–227` returns
   the `caml_callback_exn` result; 260–292 propagates asynchronous exceptions
   through pending-action processing, rather than swallowing them.

The installed native code makes the dynamic catch/poll relation concrete:

| Body | Relevant instruction addresses |
| --- | --- |
| `camlWhy3__Trans__accum_1889` | Trap setup `0x5aea71–0x5aea7e`; call to Ephemeron.find `0x5aea98`; handler `0x5aeac4` loads Stdlib.Not_found at module offset `0x38`, returns None at `0x5aead4` and continues. The Some-allocation slow path at `0x5aeb3d` is also inside the trap. |
| `camlStdlib__Ephemeron__find_730` / `find_rec_721` | find tail-calls find_rec. Poll `0x99ff17–0x99ff1a` precedes the empty-bucket test `0x99ff20`; slow path `0x99ffe8` calls `caml_call_gc`. A cache hit is not required. |
| `camlGnat_main__save_session_and_exit_3133` | Small signal-setting trap removed at `0x52e6d1`; save_session called at `0x52e6fb`; only then does `0x52e709` jump to Stdlib.exit. |

The archived `session_itp.ml` has exactly four `session_raw_tasks` occurrences:
its non-mutable field declaration at 136, lookup at 311, initialization at 631,
and `Hpn.add` at 687. There is no explicit table write between the successful
guard lookup and the following lookup, and no removal or clear through that
field in this module. Under ordinary sequential table semantics and no
interfering mutation, the second lookup has the membership established by the
first. A stronger whole-program alias/mutation theorem is not proved here, but
no reachable intervening mutator is identified either. The scoped thread and
custom-destructor inventory below supplies no such mutator. An independently
arising asynchronous exception would need its own source route; it cannot be
presented as a missing-task exception. The original membership-witness argument
is withdrawn, without substituting hypothetical removal between lookups.

The exact unresolved obligation is either to exclude all relevant escaping
exceptions after handler-side registrations that can be caught by continuing
transform code, or to establish finite callback multiplicity and charge a
source-supported bound for the handler work. The catch/poll/binder facts above
identify where an exception-ordering or charging argument must apply; they do
not alone demonstrate an escaping handler exception. Stable raw-task membership
is already checked by this guard and is not a separate missing session invariant.

Nor is reaching Stdlib.exit alone sufficient to skip checking exceptions:
`stdlib/stdlib.ml:552–570` executes the `at_exit` closure chain before
`caml_sys_exit`, with no catch around each hook; the pinned native exit body
agrees. This is a further interface to check if the earlier save path is closed,
not a claim that an installed exit hook actually raises `Not_found`.

## Reusable registration and ownership findings

The following findings narrow the remaining work. Their positive scope is the
inspected source interfaces and installed references under the existing relevant
runtime correspondence and well-formedness premises.

**Gc capabilities.** The numeric audit finds only `caml_program` calling Gc entry
from outside Gc code, and no external code reference to Gc module data. Entry
initializes records/closures; it does not register a finalizer or alarm.
`stdlib/gc.ml` makes finalise/finalise_last primitives and create_alarm an
explicit registration of its supplied closure; call_alarm re-registers itself.
Native users of final-registration primitives are these Gc wrapper/alarm bodies;
`generic_final_register` has only the two C registration-wrapper consumers.

Non-Gc data references are root/segment/frame metadata or the primitive-address
retention table at `0xf83818–0xf838c0`. `asmcomp/asmgen.ml:246–256` emits the
latter to prevent linker discarding; `asmcomp/cmm_helpers.ml:2622` emits data
symbol addresses, not a dispatch loop. `runtime/roots_nat.c` scans/moves/marks
roots, not calls arbitrary closure fields. Higher-order library parsers or
formatters may retain Why3 closures, but that fact alone gives them no isolated
Gc registration capability. The live finalizer registry remains **unobserved**.
Zero-fill/BSS file contents never stand in for its runtime contents.

**Reflection and native loading.** `Dynlink.Native.unsafe_get_global_value` is a
real module-value export route through `caml_natdynlink_loadsym`. Inspected
external Dynlink consumers (Why3 Plugin/Driver/Whyconf) select the native flag,
private loader and error metadata, not that accessor. The two plugin import
sets do not import Gc, Thread, Sys, Dynlink, custom registration or dlsym APIs;
`__cxa_finalize` is ELF teardown, not OCaml Gc finalization. The selected native
loader retains opened handles even on errors (`runtime/dynlink_nat.c`, explicit
TODO to dlclose); successfully initialized then unmapped hidden plugins are not
its behavior. `getmap` exports decoded names/checksums, not module values.

The bytecode compiler-library Dll/Symtable path is also retained: Dll.dll_sym
uses `caml_dynlink_lookup_symbol`, but its code consumers are Symtable APIs.
External Symtable/Meta references are startup and wrapper aliases. The
compilerlibs wrapper's nonstartup consumer, Dynlink_common entry, selects
`Misc` at offset `0x18`, not Dll/Meta/Symtable. Their entries initialize data and
an exception formatter, without dynamic symbol lookup. Native
`caml_get_global_data` and `caml_reify_bytecode` reject with Invalid_argument;
`caml_natdynlink_run_toplevel` has no external code or allocated-data consumer.
The extra dlsym/globalsym/dlopen references are the corresponding loader bodies,
not unexplained module-value consumers. These distinctions avoid treating the
mere presence of a reflection symbol as an exercised capability.

**Threads and signals.** Thread entry installs the SIGVTALRM preemption handler
`preempt _ = yield ()`, and a shutdown callback. It supplies no Why3 identifier
callback. External Thread code references are startup and ThreadUnix timed
read/write wait functions; external module-data access is absent. Thread.create
is the sole caller of `caml_thread_new`, and its creator API has no inspected
external consumer; `caml_c_thread_register` likewise has no external code or
allocated-data consumer. Sys module consumers select executable_name,
interactive, os_type and Break. Direct set_signal consumers are GNAT entry/save,
Thread entry/shutdown and the unconsumed Sys.catch_break. The GNAT exception
route above is deliberately not classified as terminal.

**Custom operations and channel hook.** The ten selected operation records are
`caml_ba_mapped_ops`, `caml_ba_ops`, `caml_condition_ops`, `caml_int32_ops`,
`caml_int64_ops`, `caml_mutex_ops`, `caml_nativeint_ops`,
`caml_threadstatus_ops`, `channel_operations`, and `ml_z_custom_ops`. Reused
selected destructor sources/bodies release memory, mappings, pthread objects
or channels. The channel hook is initialized null (`runtime/io.c:58`). Its sole
inspected native address-taking writer, `caml_thread_initialize`, takes its
address at `0x9b8ec7` and stores the fixed `caml_io_mutex_free` target at
`0x9b8ed5`; other references read its value. No allocated data pointer to the
hook address is found. That target destroys/frees a mutex without entering
Why3. This closes the previously unidentified hook owner at the inspected
interface level; it is not a runtime value observation or arbitrary alias proof.

The extractor retains 128 direct call/tail-call sites to the public custom allocators in 96 functions. At 127,
the last textual `%rdi` definition names one of these ten records; the remaining
site is legacy `caml_alloc_final`, whose dynamic-operation record route has no
external code or allocated-data consumer. **Last textual definition is supporting
evidence, not a dominance analysis.** `caml_final_custom_operations` is consumed
only there. Registry initialization adds the fixed integer/bigarray records;
the sole other registration caller is `ml_z_init`, passing Zarith's null-finalizer
record. `runtime/intern.c:534–580` resolves unmarshalled custom blocks through
that registry, and `runtime/obj.c:121` rejects Obj.new_block Custom_tag. No claim
is made for forged pointers, memory corruption, or unproved general native
non-aliasing.

## Discriminating next source checks

Prioritize a bounded-charge argument using the handler's existing ignore
settings, if the source supports a finite invocation count. SIGINT is set to
ignore before any session save; SIGHUP and SIGTERM are also ignored. Check
successful setting for the selected Linux signals, preservation until the
bounded endpoint, and absence of later reinstallation. Also trace OS and OCaml
pending-signal state: the archived `runtime/signals.c:447–490` calls
`caml_set_signal_action`, may allocate the old Signal_handle result, and calls
`caml_process_pending_signals_exn` before returning. Valid signal numbers alone
do not settle all those paths. If that argument proves one handler invocation
can create identifiers, charge one source-derived save/shape/at_exit bound even
when an exception resumes the fold; if a different finite multiplicity is
proved, charge that multiplicity instead. No one-shot or finite-handler bound
is established by this packet.

Alternatively, inspect the remaining save/shape/exit paths and the continuing
transform's catches to exclude all relevant post-registration escaping
exceptions and continuation. That requires actual exception sources and ordering,
not the withdrawn missing-task story. Neither route requires a fresh runtime
queue snapshot; neither is completed here.

A selected subprocess SIGINT mask is another **unimplemented configuration
candidate**, not a discharged premise. The precise checks would be: (1) choose
an OS launch API that establishes a blocked SIGINT before exec without a launch
race, and verify POSIX fork/exec/thread inheritance against the actual launcher;
(2) inspect the selected OCaml/runtime/Why3 signal-mask writers, including
`caml_sigmask_hook`, Thread.sigmask and native libraries, to show SIGINT remains
blocked throughout the bounded call; (3) show the blocked signal is not serviced
by a sigwait or equivalent callback route, including OCaml pending-signal
handling; and (4) preserve the launcher's required cancellation, timeout,
process-group cleanup and solver-child behavior, explicitly selecting which
children inherit or restore the mask. `runtime/signals.c:72–104` itself checks
the thread mask before processing pending signals, which is useful evidence but
not that full invariant. Blocking SIGINT can change graceful session-save and
cancellation behavior; no acceptability claim or configuration change is made.
The existing external-resource boundary alone does not establish callback
absence. Forcing unconditional exit in vendor source is also outside this task.

All complete endpoint, runtime callback closure, prior-history/freshness,
family invariance, later-call, auxiliary-state, full-transform and whole-pipeline
claims remain false. Independent review and integration belong to the parent;
this packet changes no production source, Oracle, configuration or publication
state.
