# Retained inlining identifier counter

2026-10-18, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), based on
`e6005221312ad953471ab22290d7dff576495162`.

The private `Ident.id_register` counter is **60,496** at the newly retained
first Input_Is_Valid/cvc5 `inline_trivial` entry. The same process supplies a
complete input graph and `Hsdecl` table. Replaying the accepted representative
selection and input-isomorphism checks attaches the **1,145 accounted source
registrations** to this entry. Their counter endpoint is **61,641**, below
`2^62−1`.

This closes the missing **starting-ref input and its arithmetic composition
with the accounted source operations**. The endpoint for every possible
continuing runtime callback remains open: this packet does not yet establish
complete registration/reachability closure for OCaml/library finalizers and
other indirect callbacks. No new absence-of-reentrancy assumption is treated
as a discharged capacity obligation. Complete continuing-call, transformation
and whole-pipeline capacity flags remain false.

The [offline packet](../evidence/retained-why-inline-identifier-state-20261018/README.md)
retains the successful capture, both failed attempts, raw memory reads,
source/disassembly inputs, callable composition and focused checks. Earlier
accepted packets remain unchanged. No production source, admission rule,
Oracle, tool pin or configuration changed.

## Exact private ref and entry binding

The earlier graph/table archives retain `Hsdecl.next_tag` and OCaml runtime
counters, but omit the lexical ref inside `Ident.id_register`. A maximum tag
among reachable identifiers is only a lower bound on past registrations:
dead identifiers are absent. It cannot supply an upper bound for this ref.

Pinned Why3 `ident.ml:187–192` initializes one private ref to zero and performs
`incr r` before installing `Weakhtbl.create_tag !r` in the new identifier.
`Weakhtbl.create_tag` is identity (`weakhtbl.ml:50–54`). `id_fresh`, `id_clone`
and `id_derive` produce pre-identifiers; registration happens separately.
The ref persists across all callers in the process and is not reset when a
new transform starts.

In the exact retained executable, `Ident` module offset `0xe8` contains the
three-word registration closure. Its field 2 is the one-word counter ref;
field 0 is `camlWhy3__Ident__fun_6183`. Initialization constructs that ref and
closure and stores the closure at the stated module offset. The function
loads the ref from closure offset `0x10`, increments its tagged word by two,
then allocates the four-word identifier and stores the incremented tag. The
packet retains complete function/initialization disassembly and checks the
installed binary identity and selected instruction bytes.

The captured raw ref word is **120,993**, decoding to **60,496**. Every
successful memory read is appended and flushed before its caller interprets
it. The identifier packet is saved before table/graph processing; the complete
input graph and `Hsdecl` table are saved before optional auxiliary traversal.
All read bytes are retained losslessly in the compressed archive. Offline
replay reproduces both the private-ref packet and auxiliary snapshot exactly.

The inferior stops before executing the selected `inline_trivial` application.
The original entry and runtime guards are preserved byte-for-byte apart from
the documented path relocation and observer insertions; the checker compares
the entire resulting probe and launcher. Initial thread count is one, no new
thread or forbidden guard fires, and the original final resource invariants
pass. The separate server remains idle. Inlining, printing and solver
submission never execute in any of these captures.

This new process's 244 logical input roots are exactly sharing-isomorphic to
the accepted input graph, including immediate values and opaque payload bytes.
Its complete declaration-table projection again contains 6,704 distinct old
objects in all 5,003 buckets. Replaying the selection check establishes 143
distinct mapped keys; 142 old selectable objects are exact input roots, and
the same three extra propositions fail the opened-coordinate test. The
accepted insertion argument and envelope **E=8, V=6, T=3, A=80** therefore
attach to this same stopped process. The counter is never joined to another
process's graph merely because its input filename matches.

## Accounted source calls and the remaining callback boundary

The accepted local vector counts **235 + 6×123 + 4 + 168 = 1,145** fresh
registrations. It includes the selected fold's mapping, opening, substitution,
type-instantiation and task-validation callbacks. The
[comparand packet](retained-why-inline-comparand-capacity.md) establishes that
strict/shallow comparison and hashing register zero identifiers. The
[representative packet](retained-why-inline-representative-state.md#local-insertion-closure-and-actual-opened-attributes)
provides the selected synchronous fold and insertion argument. Its absence of
foreign **declaration insertion** alone would not imply absence of foreign
identifier registration.

For the identifier-specific extension, the actual fold callbacks are the
source routines already charged above; it does not invoke the external event
scheduler or create a thread. The complete pinned Why3 source inspection finds
no finalizer registration, `Callback.register`, or thread/domain creation.
The captured process is single threaded. The selected GNAT SIGINT handler
ignores further termination signals, saves the session and exits; it never
returns to the fold (`gnat_main.ml:298–309,335`). The apparent debugging signal handler is disabled inside a comment
(`debug.ml:190–196`). Work performed while abandoning the invocation
through interrupt/save/exit is outside this continuing-fold bound. A textual
scan is retained as an inventory, not as a proof about all linked code.

A bounded additional source check inspects selected runtime destructors at the
existing OCaml pin `8eb41f72ded84df884c3671734c947f612091f84`, together with their
installed native bodies:

- `caml_ba_finalize` decrements its proxy count and frees storage
  (`runtime/bigarray.c:146–171`). The mapped variant frees/unmaps, with no OCaml
  callback (`otherlibs/unix/mmap_ba.c:28–42`, `mmap.c:193–205`).
- Mutex, condition and thread-status destructors destroy pthread resources and
  free storage (`st_stubs.c:755–758,835–838,907–910`;
  `st_posix.h:235–241,280–286,326–333`). These destructor paths do not enter the
  thread-start closure dispatcher elsewhere in the same source file.
- Channel finalization unlinks/frees or preserves an unflushed channel for
  eventual exit; diagnostics use C I/O. Its indirect mutex-free hook is
  initialized to null and the selected systhreads initializer sets it to
  `caml_io_mutex_free`, which destroys/frees the mutex
  (`runtime/io.c:58,445–482`; `st_stubs.c:257–263,466`). This identifies the
  ordinary selected hook behavior; complete hook ownership across all linked
  initialization is not proved by inspecting these two assignments alone.

These selected destructor bodies do not call `Ident` or an OCaml callback
under the relevant installed runtime/OS behavior. Counting their pending
instances is unnecessary for that local non-registration fact. This is not
an inventory proof that every possible installed custom operation is one of
them. Static custom-operation records for the builtin integer types and
Zarith also have null finalizer entries; their selected record bytes are
retained in the callback inventory.

The executable's direct symbol-annotated references to the two OCaml
finalizer-registration primitives occur only in the `Stdlib.Gc` wrappers and
alarm helpers. That scan does **not** exclude indirect higher-order use of
those wrappers or registrations in all loaded libraries. The actual runtime
finalizer dispatcher invokes retained `f.fun` with `caml_callback_exn`
(`runtime/finalise.c:164–193`, especially line 186). The private identifier
ref is not lexically accessible to those generic routines, but a registered
closure could call a Why3 function if such a closure were passed to them.
Absence of that route still needs an initialization/call-interface argument.

The exact residual is therefore **complete registration and callback
reachability closure**, including any library-held OCaml closure that can
reach identifier construction, returning signal handlers and mutable callback
hook ownership. The present packet neither proves such a closure is reachable
nor proves it impossible. It does not replace this obligation with an assumed
zero callback count, and does not recommend another queue snapshot as the
first step. Selected linked-source/import interfaces can resolve the remaining
question without a native run if they establish that no identifier-producing
closure is registered or passed.

## Counter arithmetic and scope

For starting counter `C` and at most `R` total registrations, induction over
calls to the single private ref gives tags `C+1` through at most `C+R`. The
pure callable checks nonnegative mathematical integers and
`C+R ≤ 2^62−1` before claiming no overflow. For the attached **accounted source
operations**, `C=60,496`, `R=1,145`, and `C+R=61,641`; all intermediate
preincrements fit. The callable propagates any larger registration allowance
instead of silently ignoring it.

Extending that endpoint to **all** runtime behavior of the continuing
invocation requires the callback closure above. The source-operation bound
also retains its existing relevant-source/runtime, well-formedness,
valid-cache and noncolliding-freshness premises. The observed positive
counter does not establish that its earlier history never wrapped, nor prove
that all old identifiers are globally collision-free. The initial snapshot
includes the effects of earlier callers but supplies no bound on them or on
future calls. No invariance over the literal source/configuration family,
other first-entry runs, other input/driver pairs or later transformations is
claimed from the observed number.

## Auxiliary observations and evidence rounds

The same stop also retains immediate backing arrays, slots/list nodes and
shallow key/data objects for the other selected shared states. Offline decoding
gives:

| State | Counter | Outer length | Allocated slots / list nodes |
| --- | ---: | ---: | ---: |
| `Ty.Hsty` | 570 | 5,003 | 1,647 |
| `Theory.Hstdecl` | 10,815 | 5,003 | 17,099 |
| `Task.Hstask` | 799 | 5,003 | 2,277 |
| `Task.Stdecl` | 772 | 8,192 | 771 |

These are observations only. Their continuing counter/backing/callback
capacity flags remain false; key/data payloads are shallow, not complete
recursive comparand graphs. `Hsdecl.next_tag=6,836` is retained separately in
the complete declaration-table packet for the same process.

Three separately managed one-worker attempts used the same 6 GiB address-space
and 120-second diagnostic guards. These limits are not capacity conclusions:

| Managed run | Result | Debugger seconds | Managed seconds |
| --- | --- | ---: | ---: |
| `20261018T222321-73a9532920c5` | Failed auxiliary module-shape check | 5.284053192 | 7.114868897 |
| `20261018T222428-4462a2d77b63` | Failed auxiliary constructor-tag check | 4.930910454 | 6.772644730 |
| `20261018T222813-b996544ccae9` | Complete core and raw auxiliary capture | 11.077953020 | 13.306743622 |

The first decoder mistook an internal 32-field `MakeSet` module for its
exported 31-field signature projection. The corrected path uses exported
singleton closure field 2 to reach the inner `MakeMap` module. The second
incorrectly required a shallow Hcpt payload to have tag zero; `Branch` has tag
one and five words. Both failed attempts remain unchanged. Before the third
attempt, source-case inventory and fixtures covered signatures, both
constructors, empty arrays, sharing/cycles, exact persisted-byte replay and
partial auxiliary failure preserving the core. The lead coordinated each
attempt after its diagnostic checkpoint. No successful capture was rerun.

The [round record](../evidence/retained-why-inline-identifier-state-20261018/round.json)
records focused validation and review inputs. Selected worker: **GPT-6 Astra /
Extra High**, assigned by the parent. Runtime setting confirmation and token/
monetary measurements are unavailable. Parent owns independent review,
integration, publication and issue/memory updates. No GitHub, CLI-memory or
harness write occurred in this subthread.
