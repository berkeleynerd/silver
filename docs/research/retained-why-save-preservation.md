# Retained save preservation: private state and pending-action clients

2026-10-19, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This successor closes
the **typed/API ownership and registered OCaml-client parts** of preservation
for the first fold and its serial SIGINT saves. It isolates the remaining native
preservation obligation to **four collection timing-hook cells**. The shared
Shape buffer, fresh shape printer and first fold's private cache/backward-work
list have no independent typed alias on this route. The classified OCaml pending
clients do not reenter them during a SIGINT save. Actual native timing-hook
setter/client ownership is not yet established; complete runtime noninterference
therefore remains conditional on that join.

These are local preservation lemmas, **not an exception/continuation closure**.
It does not cover a later ordinary save interrupted by SIGINT. Complete `R`
and exceptional identifier charge remain null. No Oracle, tool, source pin,
production admission rule or current-language capacity claim changes.

The exact accepted starting point is source
`0aa373fb93f9db980a404a9346c1eab88969b4c7` and
[review `a8e3d54795`](../reviews/review-why-session-save-outcomes-0aa373fb93.md),
integrated before base `ba82867962`. The existing same-process capture is
`20261019T000304-fcb988ec2c03`, PID 97103. Its 66 roots, 1,545 stored terms,
309 identifiers and ten integer objects, the 966-binder certificate, 1,074-byte
shape extent and 315-insertion/reset bound are reused, not replayed or enlarged.
The [new packet](../evidence/retained-why-save-preservation-20261019/README.md)
checks a narrow source projection, selected records from the accepted native
client inventory, and six new installed timing-hook load windows. These checks
do not prove OCaml semantics or arbitrary native non-aliasing.

## The mutable objects and the operations that own them

`Termcode.Shape.shape_buffer` is allocated once inside the implementation
(`termcode.ml:338–355`). The `Shape` module and buffer are absent from
`termcode.mli`. Typed clients can request a shape through `t_shape_task` or
`Gshape.t_bound_shape_task`; they cannot obtain this buffer. The former returns
`Buffer.contents`, which copies the selected bytes (`buffer.ml:35`); the latter
copies each proposition shape before clearing the buffer and ultimately returns
an integer list (`termcode.ml:599–627`). The strings stored in Gshape's maps
therefore do not alias the mutable backing bytes. The unrelated public
`buffer_checksum` consumes a caller's buffer and returns a checksum; it does
not publish Shape's buffer.

The one deliberate extra alias is local and synchronous: `const_shape` creates
`Format.formatter_of_buffer shape_buffer`, prints the constant and flushes it
(`termcode.ml:400–407`). `formatter_of_buffer` captures that buffer in
`Buffer.add_substring`; the formatter constructor returns a fresh record and
queue, without publishing them in a standard/global formatter
(`format.ml:937–977,990–1007`). For these retained roots, the already accepted
integer-only `Common.const_v2` branch supplies data, not a user callback.
Neither the formatter nor its output closure is registered as a finalizer,
signal callback, statistic or exit hook. The Debug escape buffer is a different
`Buffer.create` (`gnat_main.ml:265–268`); flushing Debug/standard formatters
does not thereby acquire Shape's buffer.

Each Gshape task's `pr`, alpha counter and alpha map are fresh locals. The
printer creates its own `Hstr`/`Hid` tables, with the identity sanitizer and
empty blacklist (`ident.ml:225–286`). The inspected shape functions use these
locals but do not publish them. The API boundary alone does not prevent a
callback from calling an exported shape operation again; the client/protocol
argument below supplies that separate fact.

`Trans.fold` allocates a fresh `Wtask` table and closes over it in `current` and
`rewind` (`trans.ml:75–103`). The local immutable `todo` list is carried only by
`accum`; task predecessor fields are immutable (`task.ml:59–100`). Wtask's
ephemeron abstraction does not publish this particular table. A client knowing
a task key cannot find a table through that key. The first backward walk invokes
only `current`, and the only insertion is in `rewind` after `fn` returns.
Neither direct save nor its classified OCaml pending-action clients invokes this fold's
returned closure or the controller's work scheduler. Thus those clients cannot
make the first backward cache nonempty or splice its `todo` chain. The native
timing-hook residual below is not discharged by this lexical argument.

Garbage collection is distinct from an application write. Under the existing
faithful-runtime premise, moving/marking roots preserves their logical values;
weak clearing can remove ephemeron entries but cannot manufacture a binding in
an empty table. The same argument preserves the retained proof-node/raw-task
projection across these classified actions. Direct inlining and direct save have
the accepted limited write effects; it is not claimed that all session state
rolls back on failure.

## What the pending-action dispatcher can actually call

The pinned `signals.c:260–292` first performs urgent collection, then signals,
then postponed Memprof callbacks, then OCaml finalizers. If a callback returns
an exception result, it sets `caml_something_to_do` again and returns that
exception. A later pending-action pass is therefore possible. The flag is not
an instruction to replay the interrupted Why operation or a successful save.

The following classification uses the accepted
[registration/capability argument](retained-why-inline-callback-closure.md),
including its native-loading/reflection restrictions, rather than repeating
its source census or treating an absent direct call as an indirect-call proof.

| Client | Concrete effect on the protected objects |
| --- | --- |
| GNAT's installed SIGINT closure | Calls the charged save and exit route. It can own Shape while the interrupted inlining path is not using Shape; the blocked-signal protocol prevents another SIGINT save inside it. |
| Thread's installed SIGVTALRM closure | `preempt _ = yield ()`. With the retained single OCaml worker and no additional worker registration, there is no waiting worker to run; `caml_thread_yield` returns unit at its first guard. No Why scheduler or shape operation is called. |
| `Gc.finalise`, `finalise_last`, alarm callbacks | No admitted client obtains/calls these registration capabilities in the fixed loaded program. Gc entry initializes data/closures, not an alarm or finalizer. The runtime has no registered OCaml closure to dispatch through this route under that source-prefix argument. |
| Memprof tracker callbacks | The only retained nonself native reference to `caml_memprof_start` is Gc's `start_inner` adapter; the same Gc capability boundary excludes its application. The disabled-state argument below excludes postponed and allocation-time tracker callbacks. |
| Custom-block destructors | Reused installed operation-record and channel-hook ownership identifies memory/mapping/pthread/channel cleanup, or null destructors. Those bodies do not enter an OCaml/Why callback or obtain Shape, the printer, fold cache or session tables. |
| Four collection timing hooks | Source initializes their cells to null; actual selected native setters/aliases and any installed callback effects remain unjoined. No zero-effect conclusion is assigned. |

The SIGVTALRM source is `thread.ml:81–102`; the runtime guard is
`st_stubs.c:723–740`. Even in the more general yield body, its explicit calls
are pending-signal processing and runtime-state save/restore around an OS
thread yield, not a call to `Controller_itp`'s event loop. The single-worker
premise is essential: this packet does not claim safety with another worker
already holding a shape capability. A tick thread's OS signal recording does
not give it an OCaml Shape alias.

For OCaml finalizers, `finalise.c:44–70` starts both registration sets empty and
the pending list null; `generic_final_register` and its two public wrappers
populate the sets (`352–404`). The accepted capability argument rules out an
application of these wrappers from initialization through this interval.
Collection cannot move a nonexistent registration into the pending list.
Consequently the `to_do_hd != NULL` guard in `caml_final_do_calls_exn`
(`164–194`) never admits an OCaml finalizer here. This is **source-prefix
reasoning**, not a measurement of the live registry, and not an inference from
BSS bytes. Sexplib0's optional `finalise` parameter is ignored, as the accepted
[converter packet](retained-why-sexplib-converter-prefix.md) already establishes.
`Fun.protect` finalizers, `at_exit` hooks and exception printers are synchronous
callers on other routes; their names do not put them on this GC queue.

Memprof has the same distinction. Its `lambda` starts at zero, global/local
entry arrays start empty, and `caml_memprof_start` is the operation that installs
a tracker and changes the sampling rate (`memprof.c:40–52,119–181,1016–1049`).
Shared/custom/interned allocation tracking returns immediately at zero rate;
the minor-sampling trigger is placed at the heap start (`766–815,975–1003`).
There is consequently no allocation-time tracker invocation and no entry for
postponed processing. The postponed dispatcher returns unit for the empty
arrays (`568–575`). This is stronger than observing `started = 0` at one point:
a stopped previous tracker could otherwise leave history to examine. Here the
retained capability argument excludes starting one in the first place.

Urgent collection also has six C timing-hook objects: major-slice, minor-GC and
finalization begin/end. Their pinned definitions initialize them to null
(`misc.c:36–42`); `caml/misc.h:193–196` exports their cells to native clients.
The new installed windows show actual reads of all six. The two finalization
hooks occur inside the nonempty-pending-finalizer guard, so the preceding
source-empty registration argument excludes them on this interval. The four
collection hooks remain a concrete native-client boundary:

| Hook | Cell | Installed load |
| --- | --- | --- |
| `caml_major_slice_begin_hook` | `0xfaaf48` | `0x9c551d` |
| `caml_major_slice_end_hook` | `0xfaaf40` | `0x9c595e` |
| `caml_minor_gc_begin_hook` | `0xfaaf38` | `0x9c6b8f` |
| `caml_minor_gc_end_hook` | `0xfaaf30` | `0x9c6e01` |

The accepted callback packet's **Reusable registration and ownership findings**
identifies the selected custom destructors and the `caml_channel_mutex_free`
setter/target. Its fixed-loaded-code and no-unmodeled-foreign-mutation premises
exclude new code injection or forged mutation; they do not establish that a
legitimate client of these four exported timing-hook cells is absent or harmless.
That packet does not supply their setter/alias closure. A new bounded search
for these four names in the pinned OCaml `runtime/` and `otherlibs/` source
finds exactly ten lines in four files: four null definitions, two declaration
lines and four guarded calls (`major_gc.c:1001,1171` and
`minor_gc.c:363,437`). It finds no installer there. This projection is not an
established complete source relation for every other native object linked into
the retained executable/plugins. The exact missing input is that selected-client
relation (or sufficient installed setter/alias ownership), rather than another
search of these same runtime files. This successor accordingly leaves their
actual ownership and callback effects **open**, rather than expanding the old
premise into a no-hook assumption.

The 42 matched instruction bytes and zero-fill storage metadata do not supply
live hook values, an address-taking census or an arbitrary native alias theorem.
The smallest remaining native check is to attach the selected initialization,
setters/exports and callable effects for these four cells through this interval,
or show that they remain null. It must cover legitimate linked clients, not
merely prohibit arbitrary foreign injection. No new runtime capture is implied
by this source/interface gap.

## Serial signal saves preserve the local buffer argument

The installed GNAT handler (`gnat_main.ml:298–309`, installed at line 335)
sets SIGINT, SIGHUP and SIGTERM to ignore before saving. The accepted
[signal protocol](retained-why-callback-launch.md) is stronger than that source
order alone: `signals.c:201–227` blocks SIGINT before calling its OCaml closure,
and nested pending processing skips blocked signals (`72–104`). Under its
successful-POSIX/no-unmask/no-reinstallation premises there can be two **serial**
save attempts, from a retained old pending bit, but no nested SIGINT save.
The first inlining path itself does not use the shape buffer.

During one active SIGINT shape traversal, none of the classified independent
OCaml pending clients mutates its buffer, formatter, printer or alpha locals.
This closes the signal/thread/OCaml-finalizer part of the Buffer comment's
interference scenario (`buffer.ml:96–127`). The accepted 1,074-byte input bound
continues to discharge its named maximum-string growth branch **conditional on
the four native collection hooks preserving this state**. The remaining alias
premise now has these exact native interfaces; it is not silently removed.
This is not a general absence-of-`Failure`/`Assert_failure` theorem. Primitive
runtime failures and the accepted incomplete exception analysis retain their
actual scopes.

If the attempt aborts, its local printer/formatter traversal does not remain
an independently scheduled resumable computation. A subsequent serial save
enters through the accepted resets: shape dictionaries/tables are reset and
each task clears the shared buffer position. Already charged identifier
increments are not refunded. Partial nontransactional shape updates, opened
channels, output and exit-gate changes remain possible, exactly as in the
accepted save-outcome note.

For the first fold's eligible retained Ephemeron poll, the relevant receiving
trap remains the one established at `0x5aea71–0x5aea7e`, around the lookup call
at `0x5aea98`; the poll is `0x99ff17`. A save-origin **bare** `Not_found`
received there reaches the `None` continuation at `0x5aead4`. The typed/client
ownership lemmas preserve the empty-cache premise against those clients; with
the native-hook preservation join it remains the already-accounted miss, not
another inlining pass. No actual escaping
`Not_found` is asserted. Other constructors or other receiving traps need their
own continuation argument; setting the pending-action flag does not settle it.

## The ordinary ending save is a distinct remaining case

`Gnat_main.ending` calls `C.save_session` at `gnat_main.ml:274`, **before**
report processing and JSON output at `275–279`. This ordinary call has no
SIGINT-ignore/block prefix of its own. If the installed SIGINT handler is still
active, it can interrupt that outer save and enter the same exported shape
operation. The signal protocol blocks another SIGINT save inside the handler,
so under the same single-dispatcher/no-unmask premises there is at most one
simultaneous SIGINT save inside this ordinary save. That finite nesting does
not establish safe resumption of the outer `Buffer` operation.

For example, `Buffer.resize` saves `old_pos`/`old_len` before allocation and
then accesses live buffer fields; `add_char` similarly retains its original
position. The source comment explicitly warns about intervening mutation.
The ordinary-save case must reconcile those saved fields and the receiving
exception continuations with the nested reset/write effects. This is a concrete
unclosed control-flow join, **not a demonstrated failure**. Its later session
forest also needs its own preserved-input or changed-state bound. Neither
the captured 66 roots nor 1,074 bytes is silently applied to that forest.

The minimal next work is the four native collection-hook ownership points,
the remaining save/exit exception effects and their actual receiving
continuations, and the ordinary ending's forest and nested-save join. The
captured `at_exit` chain still runs before
`sys_exit`; once-only gates clear before hooks, exceptions can skip older links,
and terminal `flush_all` is not itself once-only. These output/exit paths remain
required even if no signal arrives. No blanket no-signal or successful-save
assumption has been introduced.

The accepted accounted counter remains `60,496 + 1,145 = 61,641`; the composed
interface remains **`counter_end <= 63,573 + 2R` conditional on completing R**.
The new preservation lemmas supply no numeric `R` and make 63,573 no more
than the constant term of that interface. Full-current-grammar capacity,
normal-ending completion, later invocations, prior history, auxiliary capacity
and whole-pipeline assurance remain unestablished.
