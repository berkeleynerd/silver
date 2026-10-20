# Independent review: conditional standard-channel capacity

2026-10-20 UTC, #119 / #153. **Accepted at the stated conditional scope.**
The source argument supplies a useful per-channel buffer/request/offset rule.
It does not attach that rule to actual retained stdout/stderr state or service
behavior, and it does not establish complete channel, save or exit capacity.
No blocking finding or required author rework was identified.

## Target, independence and evidence

Exact author freeze: `5acc09acb016d6f5f32cc413e813cb9e4d65e8d1`, based on
`c947f496ad682abfbbc024523c55d2c11735f411`. Review inputs are the
[research note](../research/retained-why-standard-channel-capacity.md) and all
ten files in its
[evidence packet](../evidence/retained-why-standard-channel-capacity-20261020/README.md):
README, checker, inputs, source witnesses, interface, arithmetic, result,
generation, comparison record and round record. The review also read the
accepted private-file service/offset and standard formatter/occurrence
interfaces and the retained native flush/write/blocking bodies that they use.
The checked 28-input manifest identifies the exact reused providers.

Reviewer `/root/standard_initial_state_review` was selected as GPT-6 Astra /
Extra High. Runtime model/effort confirmation and token/cost telemetry were not
available. The reviewer did not author this standard-channel result. Earlier
sibling coordination confirmed that the recursive exception-wrapper branches
use supplied/private formatters or return strings; that contribution is not
represented as independent rediscovery of the imported diagnostic partition.
The review independently checks this freeze's byte composition, state
induction, service assumptions and exported limitations. It owns only this
report in a separate worktree at the exact freeze; integration and publication
remain with the lead.

The governing criteria retain Oracle/trusted-boundary separation of caller
obligations from external behavior, the selected Linux x86_64 source/native
relation, valid roots/lifetimes and one-worker callbacks. This is not a new
proof of libc, kernel or descriptor-service implementations.

## Byte ownership and actual destinations

The composition correctly imports `X_format = B + 70(E+2)` as **prospective
offered channel bytes** under the existing standard-core guards. B/E are still
whole-interval inputs and count every attempted prefix; a later catch, hook or
nested save does not replenish them. Flushes do not offer new source bytes.

The retained `Printexc` source and Printf accumulator confirm the direct stderr
constant: first header 24 bytes, secondary header 54, out-of-memory message
plus newline 57, and four raw-backtrace prints at 59 each. Thus
`X_direct <= H_original + H_secondary + 371` is supported. The raw-backtrace
**string** result already flows through abort JSON and is correctly excluded
from the direct-print subtotal. `%s` supplies its returned bytes without new
quoting or padding; fixed accumulator leaves are emitted once per invocation,
with failed prefixes covered. Unknown H values include private diagnostic
rendering and remain null, not replaced by exception-call counts.

The per-root Y partition and the conservative use of the aggregate X_format
for each individual guard are compatible: the latter does not double the
claimed aggregate output allowance. Direct C/raw-descriptor diagnostics stay
outside these OCaml buffers. The accepted six `flush_all` entries bound those
outer calls, not the number of writes or repeated requested bytes.

Stdlib wraps inherited descriptor numbers 1 and 2 in distinct C records. The
constructor is not `open_out`: neither regular-file kind, truncation, blocking,
nonappend mode nor zero position follows. Its `lseek` result and initial
curr=buff describe construction, not the retained-cut P0/O0. The formatter
constructor-state proof likewise does not certify channel buffer contents or
cached offsets. The freeze correctly leaves these actual entry fields unset.

The two different alias questions are handled explicitly. Distinct descriptor
numbers may share an open-file description without invalidating each C
record's cached arithmetic; their cached offsets need not equal the shared
kernel position. Conversely, C-record separation does not prove descriptor
liveness or exclude a private open/close reusing an initially invalid standard
descriptor number. Same-number aliases and close/rebinding ownership remain
unattached. The retained server `dup2` fragment follows fork in the child; it
does not establish a same-process standard-record mutation or discharge the
remaining descriptor attachment.

## Buffer debt, interruption and machine representation

For a valid retained live record with initialized readable prefix P0, the
boundary invariant

```text
0 <= P <= K = 65536
0 <= F; F + P <= P0 + A <= P0 + X
O = O0 + F
```

is sufficient. A copy accepts only the offered prefix that fits the buffer.
A positive flush result `1<=w<=P` preserves debt while replacing P by P-w
and O by O+w. P0 accounts for previously buffered bytes even when X is zero.
The counters F/A/X are mathematical bookkeeping, not assumed additional native
integer fields. Offered bytes, successful returned write counts, pending bytes
and cumulative syscall request bytes are kept distinct.

The source and retained native bodies corroborate the order that matters:
pending actions run before the current P is read; a successful write is
followed by the cached-offset addition, optional memmove and curr subtraction.
At native `0x9ce963` the offset is updated before the buffer-shift/curr
fragment completes. Accordingly the combined invariant is asserted at
operation/iteration/pending frontiers, not between those individual stores.
The pre-commit P/w bounds justify each intervening pointer/count calculation.
Under the inherited selected Thread hook and normal native-service relation,
no returning OCaml mutator splits this fragment; leave-blocking marks pending
signals rather than invoking their OCaml handlers there.

At a pending-action frontier, returning selected clients preserve the roots.
A save/exit callback that changes them terminates or raises, discarding the
suspended C frame. A higher `flush_all` Sys_error catch can start subsequent
work but does not resume that discarded frame. Thus there is no stale local
P/w commit after a mutating callback returns. The global bounds remain two
save-entering callbacks, three saves and e<=2, without per-channel resets.

The retained source range checks and rooted-string loop justify each source
copy; aggregate X alone would not do so. Buffer differences lie within K,
copies are clamped to free space, and each positive write request is at most
65536, fitting C int and ssize_t. The rooted OCaml source pointer is recomputed
after a possible GC. A block call returning zero newly copied bytes after
flushing a full buffer is correctly distinguished from a zero syscall return.

For represented signed-64-bit O0 and nonnegative F, the guard
`O0 + P0 + X <= 2^63-1` keeps each cached addition in the represented interval
`[O0, O0+P0+X]`. A first-unsafe-add argument uses the preceding debt invariant,
so it does not assume the native addition being justified. Negative entry
offsets are permitted; no cached-to-kernel-position equality is required.
The guard is evaluated mathematically, not by potentially overflowing C code.

## Service boundary and retained null claims

The private blocking regular-file positive-write premise is **not** widened
to inherited stdout/stderr. The new interface separately requires each reached
valid positive-count request to return a positive bounded count, follow the
ordinary error/interruption/raising path, or not return. Its attachment to the
actual standard destinations remains false. The disabled installed assertion,
ordinary POSIX wording and sample success are not used as proof of that premise.

The single-zero Putch countermodel is valid: a full buffer remains full after
a zero successful write and the subsequent character store is out of range.
Eventual positive progress does not fix it. EINTR instead returns to the
pending-action check before a success commit, and the EAGAIN fallback can narrow
one request to one byte. Other errors raise before the success updates.
Arbitrary repeated EINTR can repeat a readable request without a bound on all
attempts or their cumulative requested bytes. No delivery, progress, error
allocation, native-stack or physical-sufficiency result is inferred.

All five cases retain null P0/O0, alias/descriptor attachment, B/E, H, offered
byte totals, actual guards and usable standard-channel bounds. This is the
correct disposition. A later attachment must supply those inputs and the
applicable inherited control/lifetime premises; this review does not supply
them. Other global channels retain their separate owners. Oracle, tools, pins,
admission and production #88–#94 are unchanged; #119/#153 remain incomplete and
PR #121 remains draft/unmerged. This report does not itself integrate the
result into Round 43 or any later publication.

## Validation and time

One focused comparison ran at the exact freeze and passed: 28 input identities,
19 source slices, five cases, 77 offset-boundary checks and 36 positive-flush
boundary checks, reporting 0.463161145 seconds. The reviewer inspected its
code and the supporting source/native bodies separately. These finite checks
corroborate the argument and byte correspondence; they do not prove its semantic
induction or external service premise. The checker left the author tree clean.
No predecessor checker, target, OS test, capture, debugger, disassembler,
network/source fetch, solver or proof runner was invoked.

Observed review interval: 17:09:47–17:12:26 UTC, 159 seconds through the
substantive conclusion and comparison, including worktree setup; final report
writing and commit follow. This is elapsed task evidence, not a controlled
model-performance comparison. No goal, GitHub, shared-memory or CLI-memory
update was made. Token/cost measurements remain unavailable.
