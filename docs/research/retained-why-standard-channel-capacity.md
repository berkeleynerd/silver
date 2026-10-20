# Conditional standard-channel buffer and offset capacity

2026-10-20 UTC, #119 / #153, Linux x86_64. Author base
`c947f496ad682abfbbc024523c55d2c11735f411`; selected GPT-6 Astra / Extra High.
Runtime setting confirmation and token/cost telemetry are unavailable.

The accepted standard formatter and diagnostic occurrence bounds compose into
a **conditional** stdout/stderr request-safety interface. It requires the
actual entry buffer debt and cached offset, valid channel/source ownership and
a positive-success write contract for the inherited descriptors. The retained
evidence does not supply those entry values or extend the private save-file
contract to these destinations. Actual case guards and usable bounds therefore
remain null. No syscall testing, new capture or service implementation proof
is used. The [packet](../evidence/retained-why-standard-channel-capacity-20261020/README.md)
retains source witnesses, reused identities and the arithmetic interface.

## Output budgets without overlapping owners

Let B/E be the prospective whole-suffix standard-core text/event inputs of the
accepted [interrupted formatter transfer](retained-why-standard-formatter-core.md),
with its arithmetic guards and newly accepted
[constructor-state attachment](retained-why-standard-initial-state.md).
They count every attempted prefix across both roots, including subsequent calls
after exceptions and the one gated standard Format exit hook. Their actual
values are still absent. The core supplies

```text
Y_stdout + Y_stderr <= X_format = B + 70(E+2).
```

Y denotes bytes prospectively offered by channel-output leaves, not bytes
successfully copied, committed to an OS description or requested cumulatively
by repeated syscalls. Flushes offer no new bytes. Every nested callback's
standard output spends the same B/E budget; no reset is permitted.

The accepted [diagnostic occurrence result](retained-why-diagnostic-occurrences.md)
supplies the following direct stderr owners outside the Format cores.

| Direct owner | Prospective offered bytes |
| --- | ---: |
| First Printexc fallback header, `Fatal error: exception %s\n` | `24 + H_original` |
| Secondary fallback header, `Fatal error in uncaught exception handler: exception %s\n` | `54 + H_secondary` |
| Optional outer `prerr_endline` out-of-memory message, including newline | `57` |
| At most four raw-backtrace print calls, each at most 59 bytes | `236` |
| **Total** | **`X_direct <= H_original + H_secondary + 371`** |

H bounds the returned strings supplied to those two `%s` operations, including
any recursive/adapter rendering. The original and secondary conversions occur
at most once each; an absent/failed conversion can only reduce output. Their
lengths remain symbolic. Printf's fixed `%s` headers add no quoting, escaping
or padding. Its output accumulator emits their literal and string/character
leaves once per call; failed prefixes do not locally retry.

There is no additional direct stdout writer in the accepted selected writer
partition. `Printer.int_of_string` uses Format.err_formatter and belongs in
B/E. The one GNAT raw-backtrace **string** conversion flows into abort text
and JSON; its up-to-59 bytes belong in that JSON/core input, not again in the
236-byte direct-print subtotal. Private exception/warning formatters produce
strings for their later consumers; their allocations are different owners.
The fallback's explicit stderr flush, `prerr_endline`'s flush and each
`flush_all` visit add no source bytes.

C stdio or raw-descriptor runtime diagnostics do not traverse these OCaml
buffers and retain their separate service owners. They may affect an underlying
description's position; they do not increment these channel cached offsets.

Choose per-channel bounds

```text
X_stdout = Y_stdout
X_stderr = Y_stderr + H_original + H_secondary + 371
X_stdout + X_stderr <= B + 70(E+2) + H_original + H_secondary + 371.
```

When the Y partition is unavailable, using X_format for each individual guard
is conservative. It does not double the aggregate output allowance.
The [exit/list result](retained-why-channel-exit-bound.md) still supplies at most
six global `flush_all` entries, with its list/refcount ownership. Six flushes
do not multiply these source-byte totals or bound internal write retries.

## Actual constructor and selected control

Stdlib constructs stdin from descriptor 0 and creates **separate** stdout and
stderr channel records from descriptors 1 and 2 (`stdlib.ml:310–316`). These
are inherited descriptor numbers, not `open_out` calls. The constructor neither
opens/truncates files nor establishes blocking, nonappend, seekability, file
kind, initial position or distinct underlying open-file descriptions. In
particular, descriptors 1 and 2 may alias one description.

`caml_open_descriptor_out` uses `caml_open_descriptor_in` then sets max=NULL.
The common constructor directly stores `lseek(fd,0,SEEK_CUR)`, sets curr=buff
and end=buff+65536, initializes the remaining record fields and links it into
the runtime list. Linux selects no text translation. The OCaml wrapper sets
the managed flag and allocates the rooted channel wrapper. The reused installed
layout evidence supplies a 65,616-byte native record, including a 65,536-byte
buffer and signed 64-bit cached offset. These two existing records are initial
storage owners, not fresh suffix allocations or a new global-list charge.
Mutexes, service internals and error construction are not included in that size.

Format's source constructors capture those Stdlib channels in
`output_substring oc` and `flush oc` closures. The accepted standard-control
argument preserves these fields, with the single stderr Debug newline/flush
wrapper. The selected channel-client partition is:

| Reached source family | Channel effect |
| --- | --- |
| Standard Format output and Debug stderr newline wrapper | Checked output_substring and flush on the captured root. |
| Printexc fallback Printf headers | output_string/output_char accumulator leaves on Stdlib.stderr. |
| Raw-backtrace print and out-of-memory prerr_endline | Existing stderr output leaves; prerr_endline adds one character and flush. |
| Terminal flush_all | Temporary wrappers alias existing records only for flush. Its six-root/list/refcount proof is reused. |
| Save and driver file outputs | Fresh privately owned output records; their selected cleanup closes those records, not the standard roots. |
| Fixed-library/prover-output reads | Input records owned by those clients, not the typed stdout/stderr out_channel roots. |
| External prover client/server | The selected client uses its raw socket descriptor. Server child dup2 calls redirect that separate child; they do not mutate this Why process's standard channel records. |

Under that selected source/typed ownership relation, no reached client seeks,
queries size/position, reads, closes, changes buffering or replaces the two
standard channel records. Generic Stdlib APIs exist; they are not additional
selected callers. The focused source inspection identifies the server's dup2
route and the actual standard leaves; it does not claim a lexical search proves
all indirect alias exclusions. Existing no-reflection/fixed-loader and native
owner premises remain necessary. A later external descriptor rebinding or
unclassified native/returning channel mutator requires a new attachment; it
cannot inherit this client partition merely by retaining descriptor number 1/2.

The source separation of C records also does not prove that inherited descriptor
1/2 was open and reserved at the cut, or that another owner has no same-number
descriptor alias. Without that input, a later private open/close could reuse
an initially invalid standard descriptor number. Actual descriptor liveness,
same-number aliases and the selected owners of any close/rebinding must therefore
be classified before asserting a stable destination. Distinct descriptor numbers
sharing one open-file description are a different case and need not be excluded
for the cached-arithmetic theorem below.

The **formatter** constructor-state result is not a channel entry-state result.
It does not observe channel pointers, buffer curr/end, offset, descriptor flags
or all possible earlier direct/native descriptor effects. The source channel
constructor gives P=0 at construction, not P0=0 at the retained cut. Likewise
the stored lseek result is not evidence that O0 is zero or -1 at that cut.
This packet leaves both P0 and O0 unknown for both channels in every case.

## Required inherited-descriptor service interface

For each live standard channel, a reached write has a readable buffer of
`1 <= n <= 65536` bytes. Require its actual descriptor service to:

1. return `1 <= w <= n`, committing exactly that prefix; or
2. return an ordinary error/interruption result handled by the retained runtime,
   or raise through the existing boundary before a success commit; or
3. not return, in which case there is no later caller store to justify.

This is a **required additional interface**, not an assertion that the current
stdout/stderr environment satisfies it. The accepted
[private-file service contract](retained-why-save-service-contract.md) applies
only to its named regular-file descriptions. Neither that premise nor the
words “functioning services” establish the above behavior for inherited pipes,
terminals, sockets, append files or redirected standard outputs. No new trust
amendment or measured OS property is claimed here. Blocking, short writes,
errors and nonreturn remain possible; delivery, durability and termination
require their separate contracts.

The positive lower bound is essential: a full-buffer Putch calls
caml_flush_partial once, then stores the next character. A zero successful
return leaves curr=end and allows that next store past the buffer. The installed
release has no active zero rejection. Eventual positive progress does not
repair this single-zero countermodel. The checker preserves it explicitly.

EINTR returns Io_interrupted; flush retries from its pending-action check.
EAGAIN/EWOULDBLOCK at n>1 can retry once with n=1. Other errors raise before
the offset/shift/curr success updates. These outcomes preserve the local
buffer/offset invariant when the existing error/callback owners are valid;
they do not bound their own allocation or eventual work. Kernel/service
internal resource sufficiency remains in the existing trusted boundary.

## Buffer, source-range and interruption argument

For each live record require an entry certificate:

```text
max = NULL; end = buff + K; K = 65536
0 <= P0 = curr-buff <= K
O0 is represented in signed 64-bit file_offset
the channel record/buffer are valid and retained by the actual rooted aliases.
```

The buffer's first P0 bytes must be initialized/readable; an arbitrary pointer
subtraction on invalid objects is not justified by the inequality. Channel
mutex/lifetime/GC behavior, valid typed source strings and the selected
one-worker/native relation remain required. Per-call source ranges are checked
by output_substring or are whole valid strings/characters; cumulative X alone
does not certify an individual source allocation. The C output primitive roots
the source string and recomputes its byte pointer after a possible GC. Its
pos/len remain within the original represented string extent. `caml_putblock`
clamps at INT_MAX and copies at most K-P bytes, so the actual native copy count
and every positive write request fit C int and ssize_t.

Let A count prospective new source bytes offered in this suffix, F sum the
positive returned counts committed through this channel since the cut, and P
be its buffer debt. These are mathematical totals, not extra stored machine
counters. At operation/flush-iteration boundaries and pending-action frontiers,
outside the noninterleavable success-commit fragment, maintain:

```text
0 <= P <= K
0 <= F; F + P <= P0 + A <= P0 + X
O = O0 + F.
```

A copy accepts at most the offered prefix and available space. A successful
flush with 1<=w<=P increases F and O by w, shifts P-w valid bytes and reduces
P by w, preserving debt. A full-buffer flush leaves room for Putch's next
character. A block call may return zero *new source bytes copied* after flushing
an already full buffer; that is distinct from a zero successful syscall result.
Abandonment after copying leaves debt in the global record; later output is
charged again to its own attempted source invocation, never to a fresh channel.
The three success stores need not satisfy the combined invariant between each
instruction: the offset update precedes the buffer shift and curr subtraction.
Their intermediate arguments are bounded by the pre-commit P/w, and the
no-callback fragment below restores the combined invariant before another client
can observe it. No delivery upper bound is inferred for failing/nonreturning
service executions.

Before reading P, flush unlocks and processes pending actions. Returning selected
clients do not mutate these roots. A save/exit callback may flush or output
through them, but cannot return normally after that mutation: it exits or raises
out of the suspended caller. The accepted no-recovery argument discards that
stale outer frame. A normally resuming flush therefore rereads a valid current
P. After that read, the no-pending blocking entry and selected Thread hook do
not dispatch an OCaml mutator between successful write and the offset/buffer
commit. These are the same native service/ownership premises used by the save
argument, with the standard clients now explicitly attached. No extra signal
credits are introduced: at most two save-entering callbacks, three saves and
global e<=2 remain shared by the entire suffix.

## Offset guard and what it does not imply

Require, in mathematical arithmetic, separately for each channel:

```text
O0 + P0 + X <= 2^63-1.
```

With represented O0 and nonnegative F, every cached offset lies in
`[O0, O0+P0+X]`. Before a hypothetical first unsafe native addition, the debt
invariant bounds its completed and next committed bytes by P0+X, excluding that
addition. No multiplication or pointer selection uses this cached offset in
the selected output leaves. The guard need not itself be evaluated by an
overflowing signed machine addition; the checker uses mathematical integers.

This generalizes the [save offset-bias lemma](retained-why-save-io-services.md)
without transferring its zero-position premise. At construction, a successful
lseek supplies some actual position q; failure supplies -1. If an independently
attached pre-cut transfer bounded committed bytes F_pre and excluded offset
resets, then O0=q+F_pre would provide a source route to the needed guard. No such
standard-channel q/F_pre bound is supplied here. An alternative is a valid
actual entry O0 certificate, or an environment-supplied upper bound on O0.

For a pipe or other unseekable destination, O is just the runtime's accumulated
cached integer. The proof does not need a meaningful kernel file position.
Nor does it claim O equals a shared description's position if another descriptor
writes/seeks, or if append mode changes positioning. Separate stdout/stderr
buffers and counters remain separate even when the descriptions alias. Any
desired actual file-position/extent theorem needs those additional environmental
and ownership premises; they are not hidden in this cached-arithmetic result.

The number of successful write returns is at most P0+X because each commits at
least one byte. Each individual requested count is at most K. **All syscall
attempts and their cumulative requested bytes remain unbounded by this
interface**: repeated
EINTR may revisit the same readable bytes. Flush count, offered bytes, successful
committed bytes, storage allocation and native stack are distinct quantities.
Existing channel buffers are not reallocated by these output/flush loops, but
that fact is not a bound on mutex, error, GC, callback or service-internal costs.

The exact remaining attachment consists of per-case/per-channel valid entry
P0/O0 and root/alias state, the inherited-descriptor service outcome contract,
actual B/E and H inputs, and the existing native/ownership premises. Without
them usable case guards stay null. Other global channels remain separate owners.
No complete channel, failure/exit, R, stack or physical-capacity result follows.
Oracle/tools/pins/admission are unchanged; #119/#153 remain incomplete,
production #88–#94 unstarted and PR #121 draft/unmerged. Parent-owned independent
review is pending; the round record distinguishes selected settings and observed
time from unavailable runtime/token/cost telemetry.
