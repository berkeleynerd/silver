# Retained Why save-preservation review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the partial preservation claims at
`3700c2adc718dc011ec047256d9b3ceade936ab2`; no material findings.**
The typed/API ownership and classified OCaml pending-client arguments are
supported. The four native collection timing hooks remain an explicit residual,
and complete runtime preservation remains conditional on their ownership/effect
join. This is not complete save/exit exception closure or a numeric bound on R.

## Inputs and review record

The exact target is the
[source note](../research/retained-why-save-preservation.md) and its complete
[nine-file packet](../evidence/retained-why-save-preservation-20261019/README.md).
I read the source argument, checker, eleven-input manifest, 32 source excerpts,
registered-client projection, named-hook projection, installed load windows,
retained result and round record. The starting source
`0aa373fb93f9db980a404a9346c1eab88969b4c7` and accepted
[review `a8e3d54795`](review-why-session-save-outcomes-0aa373fb93.md) are reused,
together with the accepted callback capability and serial-signal arguments.
Their capture, binder, atom and continuation evidence was not replayed.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
Inspection ran from **11:34:24 to 11:37:13 UTC**, **169 seconds** at one-second
resolution, excluding report preparation and commit. Actual host: Linux 7.0.14
x86_64. The separate frozen worktree is
`tmp/review-119-why-save-preservation-3700c2adc7`; only this report is committed.
The owner-resumed #119 authorization and unchanged Oracle remain in force.
The live subthread goal was null; CLI memory was not updated. The lead owns
integration, publication and issue records.

## Protected objects and typed access

The complete `termcode.mli` does not expose `Shape`, its buffer or the local
formatter. The public shape operations return strings or integer lists rather
than that mutable buffer. `Buffer.contents` uses `Bytes.sub_string`; its `sub`
allocates and copies before conversion to string (`buffer.ml:35`,
`bytes.ml:64–73`). Thus Gshape's saved strings do not alias Shape's backing.
The public checksum operation accepts a caller's buffer; it is not an accessor
for the private Shape buffer.

The constant formatter deliberately captures Shape's buffer, but remains local
to `const_shape`. `formatter_of_buffer` installs `Buffer.add_substring` in a
fresh formatter record and queue, with no publication to a standard formatter
(`format.ml:937–977,990–1007`). The already accepted integer-only constant
route introduces no supplied user printer. GNAT's debug formatter captures its
separate `Buffer.create 42` (`gnat_main.ml:265–268`). Standard/debug flushing
does not thereby acquire Shape's buffer.

Gshape creates fresh printer tables, alpha counter and map for each task
(`termcode.ml:601–608`, `ident.ml:225–286`). The selected shape traversal does
not publish those locals. This is correctly distinguished from preventing a
callback from calling the public shape API again: lexical ownership alone
would not exclude that reentry.

`Trans.fold` creates its private Wtask table before the backward walk, and
only `rewind` inserts, after the supplied `fn` returns (`trans.ml:75–103`).
Its `todo` is an immutable local list over immutable predecessor fields
(`task.ml:65–74`). The Ephemeron key interface is not an inverse accessor for
the table that contains a key. The classified direct save/pending-client
paths neither call this fold's returned closure nor enter the controller's
work scheduler. Under the retained faithful-runtime premise, collection can
clear weak associations but cannot insert a binding into this initially empty
table. The argument makes no rollback claim for unrelated session mutations.

## Pending-action clients and the four native residuals

The dispatcher order is urgent collection, signals, postponed Memprof callbacks
and OCaml finalizers. Its exception arm reasserts pending work and returns the
exception; it does not retry the interrupted Why operation
(`signals.c:260–292`). Reexamining pending work is therefore not another
inlining execution by itself.

The accepted Gc capability proof is the necessary dependency for the new
source-prefix induction. The retained projection identifies Gc entry and its
Memprof adapter, plus root/segment metadata references; it is not presented
as a new general native reachability theorem. Gc entry initializes closures
and records without registering a finalizer or alarm. With registration
capabilities inaccessible on this selected loaded-code route, both finalizable
sets and the pending queue stay empty from their source initializers through
the interval (`finalise.c:44–70,352–404`). Consequently the `to_do_hd != NULL`
guard excludes both finalizer dispatch and the two finalization timing hooks
(`:164–194`). No live registry value is claimed. Synchronous `Fun.protect`,
exit hooks and exception printers do not become GC registrations by name.

Memprof is likewise **never started** under that accepted capability boundary.
Its zero rate and empty local/global arrays exclude shared, custom and interned
allocation tracking and postponed processing (`memprof.c:40–52,119–181,
568–575,766–815,975–1049`). Minor sampling is disabled by placing its trigger
at the heap start; the caller invokes tracking only after a successful minor
allocation lies below that trigger (`minor_gc.c:533–558`,
`memprof.c:822–835`). This is a source-prefix argument, not an observation of
the `started` flag or tracker arrays in the retained process.

Thread's SIGVTALRM callback is `preempt _ = yield ()`. With the accepted
single-worker/no-new-worker interface, the master-lock waiter count is zero
and `caml_thread_yield` returns before any switch (`thread.ml:81–102`,
`st_stubs.c:723–740`). The native tick thread's signal recording does not give
it an OCaml Shape alias. Selected custom destructors and the channel hook keep
the accepted memory/mapping/pthread/channel cleanup effects; this packet does
not replace that ownership proof with an assumption about arbitrary foreign
callbacks.

The **four collection** timing hooks remain materially different. Their
source definitions are null and their cells are exported. The ten retained
source-use lines cover four definitions, two declaration lines and four
guarded calls in the named runtime/otherlibs projection. They show no installer
in that projection; they do not supply a complete relation for every linked
native object or legitimate client. The six installed load instructions match
42 ELF bytes and decode to the stated cells, but establish neither live null
values nor all setter/address-taking ownership. Zero-fill metadata is not
substituted for runtime state.

Accordingly the major-slice begin/end cells at **0xfaaf48/0xfaaf40** and
minor-GC begin/end cells at **0xfaaf38/0xfaaf30** remain open. The absence of
new code injection or forged mutation does not exclude an existing legitimate
hook client. The report correctly calls for selected setter/alias/callback
effects, or a proof of remaining null, rather than silently adding a no-hook
premise. The classified OCaml-client conclusions do not discharge this native
join.

## Signal preservation and ordinary ending

The accepted signal protocol blocks SIGINT before invoking its OCaml closure;
nested pending dispatch skips blocked signals (`signals.c:72–104,201–227`).
The handler commits ignore settings before saving (`gnat_main.ml:298–309`).
Under the retained successful-POSIX/no-unmask/no-reinstallation premises, a
stale pending bit can allow a second **serial** save, while a nested SIGINT
save inside an active handler is excluded. The interrupted first inlining
path itself is not using Shape.

Thus the classified independent OCaml pending clients preserve the active
signal-save buffer, formatter and printer. The accepted 1,074-byte extent
continues to discharge its particular maximum-string growth branch only
**conditional on preservation by the four native collection hooks**. The
packet does not infer a blanket absence of `Failure`, `Assert_failure` or
primitive runtime failure. After an aborted attempt, its unwound local
traversal is not independently resumable; a later serial save takes the
accepted table/buffer resets. Identifier increments and other partial effects
are not refunded.

The bare `Not_found` implication remains tied to the accepted first-fold trap
and Ephemeron poll. Preserving the empty cache against the classified clients,
and eventually against the native residual, preserves the already-charged miss
continuation. It neither establishes an actual escaping `Not_found` nor closes
other constructors or receiving traps.

`Gnat_main.ending` performs its ordinary save at line **274**, before report
processing/JSON at **275–279**. That outer call has no signal-save mask prefix.
It can therefore be interrupted by a handler that reenters the same Shape
operation. At most one such handler is simultaneous under the signal protocol;
that nesting-depth statement does not exclude two serial handler attempts or
prove safe outer-buffer resumption. The saved positions/lengths around Buffer
allocation and nested reset/write effects still need reconciliation
(`buffer.ml:77–127`). The later session forest also needs its own bound. The
packet correctly treats this as an unresolved join, not a demonstrated defect,
and does not transfer the captured 66-root forest to normal ending.

## Evidence and retained limits

The author check's successful **0.6577781319938367 seconds** is reused. New
independent checks matched all **11 input identities**, **18 source members**,
**32 LF-coordinate excerpts**, the **10 named source-use lines**, **two code
and two data projection records**, and **42 installed load bytes**, including
their RIP-relative targets and zero-fill segment classification. They also
checked the four-cell residual and null R/exceptional-charge fields. This
narrow pass took **0.6139662799978396 seconds**. These checks establish record
and byte correspondence; the preservation conclusions use the inspected source
argument and accepted capability dependencies.

No old checker, Context, native process, capture, disassembler, solver or corpus
replay ran. No expensive validation was started. `git diff --cached --check`
passed for this report. The target files are unchanged.

`complete_R` and exceptional identifier charge remain **null**. The accounted
endpoint remains **61,641**, and **counter_end <= 63,573 + 2R** remains a
conditional interface, not an established 63,573 endpoint. Native collection
hook ownership, remaining save/exit exception continuations, ordinary-ending
forest/nesting, output/at_exit effects, later invocations, auxiliary capacity
and whole-pipeline assurance remain open. Oracle, tools, production source and
admission are unchanged.
