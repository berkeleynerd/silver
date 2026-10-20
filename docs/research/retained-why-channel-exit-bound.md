# Selected exit roots and post-cut channel reference bounds

2026-10-20 UTC, #119 / #153, Linux x86_64. This closes the selected exit-root
count, managed-output list allocation and channel-reference headroom left by
[Round 36's initial bound](retained-why-channel-initial-bound.md). Under the
existing selected continuation/runtime relation, there are at most **six**
post-cut `flush_all` entries. Each existing channel receives at most six extra
wrapper increments. No positive-write premise is added for stdout, stderr or
arbitrary global channels. This is not complete channel, failure/exit or save
capacity: global output extents, offsets, diagnostic storage and stack remain
separate owners.

The [packet](../evidence/retained-why-channel-exit-bound-20261020/README.md)
binds the actual five prefixes, retained source, selected exit-chain pointers
and installed native bodies. It reuses the accepted global two-callback/three-save
protocol and [interrupted preparation episode bound](retained-why-path-writer-capacity.md).
No signal budget is reset per root, preparation episode or flush. A source/native
correspondence argument is required as before; byte identity checks are not a
machine proof of that relation.

## Count reached call sites, including failed exits

The existing selected chain is Debug → Format → `flush_all`. The first two
hooks have gates cleared before calling their hook. Their selected bodies do
not invoke `exit`, `do_at_exit`, register another hook or restart the chain.
The terminal `flush_all` has no once gate. Each invocation of `do_at_exit`
can reach that terminal at most once; an exception may prevent reaching it.
A nested signal invocation belongs to its own globally counted callback.
Unwinding does not resume a discarded frame.

| Post-cut source root | Entries reaching its do_at_exit/exit call, at most |
| --- | ---: |
| `save_session_and_exit`, gnat_main.ml:298–309 | 2, shared signal-callback budget |
| Main's outer error handler, gnat_main.ml:357–363 | 1 |
| Native-program `Std_exit` initialization | 1 |
| Printexc's protected preliminary `do_at_exit`, printexc.ml:337 | 1 |
| Installed GNAT uncaught handler → `abort_with_message` → `exit` | 1 |
| Total | 6 |

The main handler body is outside its protected try; a failure there cannot
reenter the same handler. `Std_exit` initialization occurs once after main's
module entry, with no retry. Printexc calls its preliminary hook chain once
inside `try ... with _`, then invokes the configured exception handler once.
Its fallback prints to stderr and flushes that single channel; it does not
call `flush_all`. The outer OCaml wrapper suppresses any escaping exception.
The C fatal handler selects either this registered OCaml path or its default
C path, and finally terminates; it does not run both paths or retry the former.

The apparent additional GNAT direct-abort route is not selected. The accepted
Per_Check forest has first=last=`split_goal_wp_conj`, and all registered leaves
are fully split. `is_full_split_goal` returns true for them or raises; it has
no handler converting an exception into false. Thus `register_result` cannot
enter `further_split`/`find_next_transformation`'s abort. This uses the
[preserved forest argument](retained-why-save-attempt-growth.md), not a generic
claim that an abort cannot resume: that claim would be false under the
surrounding `Exit` handler.

The other candidate, `Reduction_engine.normalize`'s exit, is likewise excluded
by the selected call graph. Its callers are Compute; non-Compute entries are
Gappa's `simplify_computations` and Reflection's goal building. The retained
driver dispatch selects neither these transformations nor compute/step(s), and
all three printers are Smtv2. Selected eliminate_definition/discriminate
references to Compute are metadata, while matching helpers use
`first_order_matching`, not normalize. The GNAT runtime-checking route requires
`session_find_ce_pa=Some`: fresh `counter_example` fields start None and their
only assignment to Some is in the disabled CE branch. Neither an interrupted
lookup nor a caught Exit enables that branch. Initialization, merge, replay,
interactive and separate Why3 executable roots are outside this post-cut route.

The actual retained `OCAMLRUNPARAM` is `s=256M,h=16M,M=1000`. Startup initializes
`caml_cleanup_on_exit=0`, and only option `c` sets it; the selected continuation
has no writer or explicit `caml_shutdown` caller. Consequently native exit
does not invoke shutdown's extra registered at-exit call. This attaches the
existing fixed runtime configuration, not an assumption that all OCaml
configurations disable cleanup. Changes to that configuration invalidate this
six-root application.

A proposed bound `e+2` was rejected during this work. With **zero signals**,
normal Std_exit can flush and receive `Sys_blocked_io`; Printexc's preliminary
flush can fail the same way; the custom GNAT handler can print its diagnostic
and then enter a third flush. `caml_sys_io_error` produces Sys_blocked_io for
EAGAIN/EWOULDBLOCK, while `flush_all` catches only Sys_error. Printexc suppresses
the later failure. This is a source countertrace, not a native execution, and
needs no physical exhaustion. Six counts the roots regardless of those errors,
zero writes, short writes, EINTR or nonreturn. It proves neither flush success
nor termination and does not extend the private-file positive-write premise.

## Which later channel records can join the output list

Let E be the accepted interrupted preparation-episode upper bound,
**194 / 161 / 98 / 11 / 5**. Each episode reaches `prove_task_prepared` and then
`call_on_buffer` at most once. Their own bodies do not retry that call. The
selected fresh automatic route supplies no old script and selects a new file.
`Filename.open_temp_file` tries counters 0 through 1000: at most **1001**
`open_out_gen` attempts, even if a Sys_error after channel creation selects its
retry. The direct open_out alternative is smaller. The constructor is charged
whether its output is published, subsequently closed or abandoned.

The already accounted three saves open at most six output channels. Therefore

```
C_driver <= 1001 E
C_new    <= 1001 E + 6
C_output <= Q0 + C_new.
```

Here Q0 is the initial managed-output upper bound, not a measured list census.
Distinct descriptor constructors produce distinct C channel records, even if
operating-system descriptor numbers are reused. A channel is never converted
from an input record to an output record after its constructor.

The selected creator closure is specific. GNAT debug log creation is before
the cuts; debug-save VCs and manual/editor paths are disabled. The two session
outputs use the installed Compress_none aliases. The automatic prover route
uses the call_on_buffer creator above. Prover output reading and fixed-library
loading create input channels. The external proof client uses raw Unix socket
file descriptors and Unix.write_substring, not OCaml output channels; it does
not disconnect/reconnect through the internal-server startup hook. Sysutil's
write/copy and Pp's file helpers have no additional selected caller: their
GNAT caller is debug-save, the other command/IDE helpers are outside the
selected executable continuation, and printer callbacks target the supplied
Buffer formatter. Inference output belongs to source-initialization routes,
not the selected later fixed-theory reads. Runtime diagnostics use existing
stdout/stderr or C stdio. This is the existing source-selected callback/config
relation; a lexical reference search alone would not establish the exclusion.

## List lifetime, failed prefixes and no overflow

`caml_ml_out_channels_list` walks `caml_all_opened_channels`, selects managed
records with `max=NULL`, increments refcount, allocates a 24-byte wrapper and
then a 24-byte list cell. It allocates neither one giant array nor a list-sized
native stack. Its C-local roots retain the partial list and current wrapper.
The increment protects the current record before the allocation can collect.
Already completed wrappers remain rooted by the partial list. C allocations
use `CAML_FROM_C`, so they do not dispatch asynchronous OCaml callbacks; Memprof
and unmodeled callback mutators remain excluded by the accepted runtime relation.
The selected C finalizer may unlink other dead records, updating its neighbor
links, but cannot free the protected current record. Unselected records cause
no allocation before the next pointer is read. There is no creation/reinsertion
inside this C walk. Its next steps therefore traverse a subsequence of the
original finite list, visiting a selected record at most once.

The constructor and finalizer preserve the doubly linked list: new records are
prepended once; unlink removes one record and reconnects its neighbors. Closing
an OCaml channel marks it closed without turning it into another live output
or adding an extra wrapper. Custom finalization decrements at most once per
successfully initialized wrapper under the faithful runtime/lifetime service.
A zero-reference unclosed output with buffered data is deliberately retained,
and may acquire a wrapper in a later flush. This does not permit a negative
count: each finalized wrapper has its earlier increment. A failed construction
prefix may leak an increment; it is counted as an attempt, never canceled
merely because allocation failed. Existing allocator/GC validity and sufficient
physical resources are still required; this does not prove safe recovery from
an uninitialized custom block after allocator failure.

Other runtime wrapper sites are descriptor constructors, each starting a fresh
record. The selected Linux clients do not expose a primitive that repeatedly
wraps an existing record, apart from out_channels_list. Thus an initial record
has refcount at most `Q0+6`, and a later record at most `1+6`. To avoid assuming
safe mathematical arithmetic for an already overflowing C int, consider the
first unsafe increment: the preceding initial count is bounded by Round 36,
and its completed post-cut increments plus the attempted next increment number
at most six (or one constructor plus six for a new record). Each five-case
upper bound is below INT_MAX, excluding that first unsafe operation. Finalizers
only decrease these upper bounds.

| Case | C_new | C_output | Each refcount upper | All list wrapper/cons request bytes |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 194,200 | 42,840,777 | 42,646,583 | 12,338,143,776 |
| Put | 161,167 | 39,048,194 | 38,887,033 | 11,245,879,872 |
| First_Or_Default | 98,104 | 29,410,759 | 29,312,661 | 8,470,298,592 |
| Is_Message | 11,017 | 25,936,410 | 25,925,399 | 7,469,686,080 |
| Input_Is_Valid | 5,011 | 26,402,085 | 26,397,080 | 7,603,800,480 |

The last column is `48*6*C_output`, a cumulative request bound including every
abandoned prefix. Each individual request is 24 bytes. Driver constructors
also request at most `24*C_driver` wrapper bytes and `65616*C_driver` native
channel-record bytes. Save-constructor wrappers/records belong to the existing
[formatter allocation packet](retained-why-save-format-allocation.md), so the
new additive subtotal excludes them. Driver pathname, mutex, diagnostic and
other preparation storage are not claimed by this channel-record subtotal.
No total is a live-memory measurement or physical sufficiency assertion.

## Native attachment and remaining composition

The retained native witnesses include program/module exit entries, GNAT handler
registration and both error bodies, Stdlib gate/exit/flush, Printexc's protected
calls, the temporary-file retry counter, driver/open callers, C list/constructor/
finalizer, custom allocation and native fatal/exit/shutdown dispatch. The
module initializer installs Gnat_util__104; its actual three-word closure is
`curry2 / arity-two descriptor / fun_12123`, checked from the ELF's data segment.
The indirect callback is not guessed from a function name. The prefix packet
observes the actual Debug/Format/flush chain; its existing ownership proof
supplies hook non-reentry. `exit` directly calls native sys_exit after its chain,
and the selected native shutdown flag remains disabled. The retained body set
includes unused branches; source selection determines the claim.

Only the above root/refcount/list-request interface is enabled under named
premises; without them the usable result is null. Global output byte/offset
bounds, diagnostic formatting/catches, native stack, mutex failure and
service-internal resource demand still need their owners before complete
failure/exit/channel/save capacity can be claimed. No full-capacity flag is set.
The focused check reads retained archives/ELF and checks identities, concrete
edges and arithmetic; it does not execute the target or mechanically prove
source control, allocator correctness or OS behavior.

The reviewer supplied the e+2 countertrace and advised on the selected root
count. That contribution must be disclosed when reviewing this packet's caller
attachment. Live lead model/effort and individual token/cost telemetry are
unavailable. Oracle, installed tools/pins, admission and production scope are
unchanged; no CLI-memory update is claimed.
