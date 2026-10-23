# Selected J12 logging formatter and channel capacity

2026-10-23 UTC; owner-authorized #119 / #153, author base `f795674a1c`.
Pending independent review. This supplies a composable bound for the
post-registration **`--logging`** owner under the accepted quiet/timeless,
fresh automatic J12, CE-off, one-OCaml-worker relation. It covers failed
entry prefixes, private formatting and the persistent log channel. It does
not implement logging, a proxy, a launcher or any production increment.
The [packet](../evidence/retained-why-logging-capacity-20261023/README.md)
contains retained source/identity/name-origin checks and new arithmetic only.

For the accepted scheduling-owner bound Q, use

```
H = Q*Q + 4Q                      # attempted Logging.log invocations
B_log <= 1280H; E_log <= 256H      # sums over distinct private formatters
X_direct <= H                    # direct newline, outside Format
X_channel <= 1281H                # bytes offered to this channel
```

| Case | Q | H | X_channel |
| --- | ---: | ---: | ---: |
| Put_Line | 155 | 24,645 | 31,570,245 |
| Put | 128 | 16,896 | 21,643,776 |
| First_Or_Default | 68 | 4,896 | 6,271,776 |
| Is_Message | 8 | 96 | 122,976 |
| Input_Is_Valid | 5 | 45 | 57,645 |

The formatter bound is per invocation, not a shared-core budget reset.
The channel bound is over the **whole selected suffix** and never resets at
flush, callback or error. One global `e<=2`, two save-entering callbacks and
three saves are retained. These are representation/finite-source-work bounds
under ordinary physical memory/stack/I/O sufficiency and existing source/native
correspondence; no aggregate RAM/stack gate or allocator/kernel proof is added.

## Actual writers and entry state

The complete retained source census has exactly two `Logging` call sites:
`gnat_checks.ml:415` initializes, and the parallel callback at1064 logs.
The module exposes init/log only; its outc ref is private. There is no selected
alias, seek, position query, close, flag change or second init on this owner.
`GNATWHY3LOG` is a different facility, absent from the exact argv/environment.
Debug, Loc warnings, reports and terminal diagnostics do not write through the
private outc ref. Generic runtime global flushes can flush its same channel;
they add no source bytes.

The accepted [R55 prefix](retained-parallel-logging-prefix.md) and
[combined-prefix transfer](retained-combined-parallel-startup.md) place
`outc := open_out (unit_name ^ ".why3log")` before registration and before
SIGINT handler installation. All five current cuts precede scheduling.
Registration emits no Logging entry. The sole successful init returns a
fresh output channel and replaces the initial stdout reference. At these
controlled cuts, this channel has `P0=curr-buff=0`, `O0=0`, a65536-byte buffer,
max=NULL, one rooted wrapper and refcount1. The retained constructor stores
the ordinary fresh-file lseek result0; the initial record size65616 and path
copies are already R55 startup owners, not new suffix allocation charges.
Configured relative log path lengths are27/22/42/36/40, preserved by the
[path-input attachment](retained-why-report-path-inputs.md).

This is a constructor/control transfer under R55's successful fresh-private
regular-file and controlled-prefix service/ownership conditions, not a new
fd observation or a capacity theorem for failed startup. The logger's channel
record is distinct from stdout/stderr and from later save/driver records.
The source root remains live; generic temporary flush wrappers do not replace
it. Actual descriptor lifetime and service conditions are stated below.

`Logging.log` does precisely (`gnat_checks.ml:101–111`):

1. Build a small JSON record and a **fresh default-margin formatter** whose
   output/flush closures capture the existing channel.
2. Call `print_json_single_line` on that formatter.
3. Call direct `output_string !outc "\n"`, then `flush !outc`.

There is **no `pp_print_flush`** and no Buffer.t. The channel flush cannot drain
the private formatter's queue. An entry below the formatter's initial lookahead
threshold can therefore leave queued tokens when that formatter is discarded.
This capacity result makes no claim that every attempted entry produces a
complete or valid JSON line. It changes no logger behavior.

## Callback multiplicity, including failed prefixes

Q is the accepted total scheduling-owner bound from the
[canonical/current-domain attachment](retained-why-canonical-json-input.md),
not an observed number of successful solver results. It counts the entire
graft/queue/Scheduled/preparation owner, including abandoned prefixes and the
global exceptional allowance. Reuse its session/result ownership and selected
counter/table contracts. This lane does not establish arbitrary controller
table semantics or renew e to repair a lost key.

| Callback source | Bound | Reason |
| --- | ---: | --- |
| Scheduled | Q | Each schedule_proof_attempt enqueues once and calls Scheduled once (controller_itp.ml:641–652). |
| Build/idle failures | 2Q | Each queue owner is popped/builds once. Build's Sys_error handler can call InternalFailure, and an exception from that callback can reach the outer idle handler's InternalFailure once. Its body is outside its own trap. |
| Finished/interrupted/failure result update | Q | The accepted canonical N<=Q response/parser ownership bounds result publications; the selected result-buffer transfer consumes each once before dispatch (448–491). Counting every possible terminal branch is conservative. |
| Interrupting queued attempts after a valid Done | Q² | At most Q Done dispatches enter the valid-answer branch. Each calls interrupt_proof_attempts_for_goal once, traversing at most Q physical queue cells; each matching cell calls Interrupted once. |

Running is filtered by `get_new_results ~blocking:true`
(`call_provers.ml:551–560`, `gnat_scheduler.ml:3`). Editors/replay/upgrade
are excluded by the selected fresh automatic route. The general
Controller.interrupt routine's extra callbacks have only the unselected
ITP-server clients in the census. SIGINT saves then exits; it does not call
that routine or log statuses. The source wrapper can reject a detached result
before reaching Logging; allowing failure callbacks above only overcounts it.

In detail, get_new_results adds each delivered result once, folds its buffer
to a fresh list and clears it before the controller starts dispatching.
An exception escaping that addition/fold/clear abandons timeout's call: the
main loop only catches Exit to enter ending, otherwise it leaves for the
terminal handler. There is no receiving catch that resumes a partial traversal
on a later poll. Selected returning clients do not mutate this buffer. Thus
the accepted N<=Q publication allowance bounds list occurrences across polls,
including abandoned prefixes. Controller removal-before-callback also prevents
a second ordinarily delivered update for a removed call, but the numerical
argument does not infer uniqueness of every physical controller binding from
a distinct-key count or an interrupted rehash.

The Q² term does not assume that an Interrupted publication removes its queue
cell immediately. `Queue.fold` snapshots first and follows the already-read
next links. Its callback for Interrupted logs, then falls through the parallel
wrapper's `_ -> ()`; it does not schedule another goal or recursively cancel
the queue. Save callbacks do not mutate this queue. The fold's completed result
list contains only nonmatching snapshot entries, once each. After clear, the
rebuild appends each survivor once. Thus a completed rebuild cannot increase
the physical population beyond the Q originally enqueued owners, even though
it allocates fresh cells.

Failure before clear may retain old cells; failure during rebuild can retain
a survivor prefix. In either case an already attempted interrupt is still
charged. These failures occur in timeout's Done callback, outside the build/
idle catches: the main loop has only `Exit -> ending`, and other exceptions
leave it for the outer terminal handler. Neither path resumes the discarded
fold/rebuild or restarts scheduling. Returning classified Thread/native clients
do not mutate the queue. Source Queue.add allocates a fresh Nil-ended cell
before publication; clear drops the old chain before rebuild. The accepted
native/callback relation and the absence of a resuming failed mutation preserve
the finite proper-chain population used by a later fold. Counting Q visits
for **every** possible cancellation traversal remains valid even if earlier
Interrupted notifications were published before abandonment. No distinct-key
count is substituted for a physical-cell count.

Failures inside Logging itself may lead to a second log attempt only through
the already counted build/idle failure chain. Logging has no local catch or
retry, and the parallel callback logs before checking remaining. Consequently
already exhausted callbacks are included; the `remaining=0` test is not used
to suppress their log charge. The [R63 closure](retained-why-callback-demand.md)
also proves InternalFailure's exception payload is dropped, not passed to the
serial logical exception printer.

## Payload origins and the per-entry source bound

The largest JSON shape has two records, seven fields, five commas, four String
values and two StandardFloat values. Its seven fixed keys total39 bytes.
The extra Done fields are omitted for other statuses, reducing this envelope.

* `proofNodeID_tostring` is string_of_int: at most20 bytes for any represented
  signed native ID. No persistent-name printer or tag-table lookup is used.
* The prover string comes from the returned session attempt record, so merely
  bounding the intended scheduling key would be insufficient under aliases.
  The packet inventories all nine configured names (maximum8) in each exact
  retained configuration, plus initial synthetic Trivial (7). Fresh records
  arise only from those input provers/Trivial. `graft_proof_attempt` copies an
  existing record without changing prover; result/limit updates likewise
  preserve it. The sole `.prover <-` writer is change_prover, on the excluded
  replay/upgrade route (`session_itp.ml:887–899` and the accepted
  [attempt-preservation argument](retained-why-save-attempt-growth.md)). A
  successfully returned typed record after Hpan alias/loss therefore still
  carries a name in this bounded origin family. No persistence/no-wrap theorem
  is inferred from the size bound; failed lookup may prevent a log entry.
* Status kind is one of ten literals of maximum15 bytes; answer is one of
  eight literals of maximum17. Unknown/Failure/HighFailure payload strings,
  raw canonical output and terminal exception text are ignored. The accepted
  canonical76 and symbolic terminal P/M/X interfaces are not additional bytes
  in this logger. Configured filesystem paths are channel metadata, absent
  from the JSON payload.
* Timestamp and Done time are represented doubles printed with `%f`. The
  accepted scalar-format owner bounds each result by317 bytes, including
  special spellings. Unix.gettimeofday's existing Linux service must initialize
  its valid timeval output on return: the source ignores its return code
  (`gettimeofday.c:23–32`). This is a precise service condition, not a new
  clock implementation proof. Valid finite timestamps/JSON numbers are a
  separate semantic condition from the formatter representation bound.

Hence keys plus string values total at most `39+20+8+15+17=99` bytes.
Using the accepted general byte escape allowance (no ASCII optimization needed):

```
B_entry <= 2*2 + 5 + 3*7 + 2*4 + 6*99 + 317*2 = 1266 <= 1280
E_entry <= 2*2 + 5 + 3*7 + 2*4 + 2*99 + 2     =  238 <=  256.
```

The direct newline is an additional byte, outside those core counts. Prospective
charges are made on entering a log invocation; missing fields, dropped queued
text and failed construction/output can reduce actual offers. Syscall retries
do not reenter the JSON serializer and are not new source offers.

## Fresh formatting and construction representation

The single-line serializer opens no user box and emits no break, tag, magic
width or formatter flush. Every reached core token after the initial system
box is known-size text. Initially the system box may hold the queue until its
lookahead reaches78; once drained, all following text tokens can drain directly.
No indentation/newline callback is triggered by this stream, even when string
data contains bytes spelled as JSON escapes. Thus bytes actually offered by
Format are at most B_entry, with **no extra `70E` layout allowance**. The source
direct newline remains separate.

All totals satisfy `1<=left_total,right_total<=1281`, space_left lies in
`[78-1280,78]`, core depth is1, format stack has at most one entry and scan
stack at most its sentinel/system entries. At most257 queue cells suffice.
The ordinary sufficient local guard `1280+256+79=1615<1000000010` also passes.
There is no formatter reset that could erase channel debt. Each fresh formatter
is abandoned if conversion/output fails; no receiving handler can recover its
private reference. A new callback makes a different formatter. None is one of
Format's globally registered standard exit roots.

The accepted [R69 construction](retained-why-report-construction.md),
[R67 accumulator](retained-why-format-accumulator.md) and
[JSON scalar/escape](retained-why-json-byte-escape.md) arguments cover these
same fixed serializer templates, immutable predecessor accumulators, integer/
float/character temporaries and string rounding. Their literal census includes
the complete gnat_checks source and JSON templates. This caller adds only
fixed JSON variants, at most four-element field lists and pairs, two boxed
floats, the20-byte goal string and closures capturing the channel/record by
reference. Each fixed non-string object fits the conservative128-word payload
bound; varying source strings fit the317-byte scalar ceiling. There is no
data-sized array, annotation helper, string concatenation of the whole line,
Buffer.t or channel creation per entry. Callback/format descent is finite;
ordinary physical stack sufficiency is retained rather than replaced by a
native stack quota.

## Persistent channel, offsets and required service attachment

Instantiate the accepted [channel debt/offset rule](retained-why-standard-channel-capacity.md)
for this specific channel record, using its constructed `P0=O0=0`, source
ranges and `X=1281H`. The rule is generic in P0/O0/X; its stdout/stderr entry
observations and destination assumptions are not imported as facts about this
different channel. With A prospective offered bytes, F successful committed
bytes through this record and P current buffered debt, maintain

```
0 <= P <= 65536
F + P <= A <= X
cached_offset O = F; hence 0 <= O <= X < 2^63-1.
```

The record persists across all log calls and caught failures. Direct newline,
partial copies and any abandoned prefix spend the same X. A successful flush
reduces P and increases O; it does not reset O or create a new allowance.
The at most six global flush_all entries can finish this debt and contribute
no new bytes. The accepted [exit/list transfer](retained-why-channel-exit-bound.md)
gives at most six wrapper-increment attempts for this existing record, even
when allocation fails after increment. Initial refcount1 therefore gives
headroom bound7, below signed C INT_MAX. Capturing the existing wrapper in a
formatter closure does not increment the native channel refcount. The root
prevents finalization/free while logging remains reachable.

The following **log-specific** service/lifetime interface is required:

1. For this selected fresh blocking regular-file descriptor, a valid readable
   write request `1<=n<=65536` either returns `1<=w<=n` committing exactly that
   prefix, errors/raises before success commit, or does not return. The accepted
   [save-file contract](retained-why-save-service-contract.md) is explicitly
   restricted to XML/shape descriptions; this is its stated behavioral form
   instantiated as a required interface for the logger, not a silent transfer
   or a proof from the phrase “regular file.” Zero-success is excluded for the
   same full-buffer put/copy reason as the generic channel theorem.
2. The selected rooted channel, valid source strings, native mutex/lifetime
   and no-reflection relation is preserved. No selected owner closes/rebinds
   the live log descriptor or changes its service profile. The private ref's
   only post-cut direct clients are log output/flush; global wrappers only
   flush. Same-number descriptor aliases, if supplied by a changed launcher,
   must preserve this lifetime condition rather than inheriting it from a
   private pathname. Sharing an underlying file description does not affect
   this record's cached-offset arithmetic; actual file extent/exclusive delivery
   is not inferred from that arithmetic.
3. Reuse the existing pending-action/no-resuming-mutator contract: pending
   processing precedes reading P; classified returning Thread/native clients
   do not mutate this record. SIGINT save/exit can flush it, but exits or raises
   out of the suspended caller and cannot resume a stale state. The native
   successful-write/offset/shift/debt commit has no selected OCaml mutator.

Under that interface all per-case cached-offset guards pass. Copies and source
pos/len remain within their valid string/buffer objects; each native write
request fits C int and ssize_t. A positive partial write decreases remaining
debt. A block call can return zero newly copied bytes after flushing an already
full buffer; the next copy has room. This differs from forbidden zero-success
syscalls. Errors and blocking/nonreturn preserve the conditional safety claim
without proving eventual delivery.

The accepted Linux runtime retries EINTR and may narrow EAGAIN to a one-byte
request. Successful commits are at most X; **syscall attempts and cumulative
requested bytes are not bounded**, since errors may repeat. Source loops and
all normally completing flush/copy steps have finite progress under the named
ordinary service-progress conditions. Runtime/clock/I/O internals and their
physical sufficiency remain trusted; no extra bound on kernel or error-object
allocation is claimed. Logger failures flow into the already owned scalar
terminal/error routes, not into an unbounded log-message printer.

## Scope of closure

This closes the selected logger's source cardinality, fresh formatter/local
construction representation and numeric buffer/offset/refcount guards,
conditional on the explicitly attached source/native, result-table/protocol,
clock and logging-descriptor service/lifetime interfaces. It does not assert
those external implementations were verified by the focused checker. Raw
solver storage q, library-probe paths, whole FileTags counters, startup failure
capacity and full #119/#153 completion remain outside this packet. Existing
successful provider evidence is reused without replay. Oracle, tool pins,
admission and production are unchanged.
