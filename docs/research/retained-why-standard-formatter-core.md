# Interrupted standard formatters: cumulative core transfer

2026-10-20 UTC, #119 / #153, Linux x86_64, author base
`ed4061e10245939a893507d10153562077996e67`.

The two standard formatter cores admit a conditional cumulative arithmetic,
queue, object-request and offered-output envelope despite abandoned operations
and later reuse. The fresh private formatter's size invariant is replaced;
its allocation and output coefficients survive with a new interruption argument.
Initial standard dynamic state and whole-interval input budgets remain explicit
premises, not results of this packet. No physical sufficiency or complete exit
theorem follows. The [packet](../evidence/retained-why-standard-formatter-core-20261020/README.md)
retains source/native witnesses and the arithmetic interface.

## Interface and ownership

Import the accepted [standard profile](retained-why-standard-formatter-control.md):
distinct stdout/stderr formatters, margin 78, maximum indent 68, default spaces,
channel output/flush, stdout default newline and exactly one stderr Debug
newline-then-flush wrapper. Tags/tabs/settings changes, Magic_size and
if-newline tokens are excluded. Selected text is length-counted data; boxes
have indentation 0 or 1, breaks width 0 or 1 and offset zero, and other events
are closes, forced newlines and flushes (with or without a final newline).
Allowing width zero and all ordinary box types only enlarges this core domain.
String contents, including JSON escapes, do not become format programs.

The entry premise for **each** root is its default constructor dynamic state:
totals 1, depth 1, space 78, indent 0, one system-begin queue element, its scan
entry plus sentinel, and empty formatting/tag/tab stacks. This is a premise
awaiting the independent initial-state lane; there is no fresh reset at a later
catch, report, save, hook, or formatter operation. Valid typed representations,
immutable token strings and the selected source/native/runtime behavior relation
are required. This packet does not cover an arbitrary unknown initial queue.

Let B bound the **sum of prospective text byte lengths**, and E the number of
prospective direct core operations, across both roots and the entire selected
interval. Charge attempts before their first allocation/mutation; charge every
new caller invocation after a catch, including abandoned output/JSON prefixes.
Text, user open, direct close, break, forced newline and each flush are disjoint
event classes. Internal automatic closes, system boxes and reset sentinels are
charged below. Annotation helper formatters are private, separate owners.

Any same-root work in a signal callback's exit hook spends this same B/E budget.
The selected global bounds of at most two save-entering callbacks, three saves
and `e<=2` are never renewed here. The single Format exit-hook gate is cleared
before invocation: its stdout flush precedes stderr; a failing stdout flush
skips stderr. Thus this hook contributes at most two prospective flush events
in the whole interval, not two per exit. Other direct flushes still need their
own E charge. The present packet does not supply diagnostic multiplicities,
JSON tree/byte budgets, scalar-service bounds or B/E for any retained case.

## Why a stale core frame cannot resume

The [ordinary-ending argument](retained-why-ordinary-ending-control.md) supplies
the selected runtime clients: one OCaml worker, no application finalizer,
alarm, Memprof or reflection callback, classified returning clients that do not
mutate these roots, and GNAT's save-and-exit SIGINT callback. Its setter catch
does not protect save or exit. After saving it calls exit; a successful exit is
terminal and a failed save/hook raises. There is no normal return after it has
mutated either standard formatter. Runtime `signals.c:201–227,260–335` transports
the exception result and raises at the suspended client; `fail_nat.c:63–87`
unwinds roots and the OCaml trap chain.

Format's selected core, Queue/Stack operations, output continuations and
JSON byte helpers have no local recovering catch. `%a` callbacks execute
synchronously outside a core operation; functions are not placed in its queue.
Default channel leaves and the Debug newline wrapper do not catch a failure
and return to the suspended core. `io.c` unlocks before processing pending
actions; an exception leaves this service rather than taking its ordinary
relock/return continuation. Its write/retry loops are runtime service work,
not a catch that returns a signal failure to Format.

The annotation parser requires explicit scrutiny. `compute_tag` completes
its private formatter before `open_box_of_string` is called; the standard
`pp_open_box_gen` follows the parser. The parser's `Failure` trap protects
only `String.sub`/`int_of_string`; its handler invokes `invalid_box` outside
that trap, whose `failwith_message` raises Failure instead of recovering.
Fixed h/hv/hov/v descriptions with 0/1 indentation
take only bounded parsing branches. Even a signal-origin Failure is not a
successful malformed-annotation parse. This trap cannot enclose, much less
resume, a partially executed standard core operation. A catch in a higher
printer or GNAT caller can start further events on dirty globals; it cannot
recover the discarded local queue/stack/token frame.

This justifies linearizing mutations as sequential operation prefixes,
possibly followed by nested callback work and abandonment of the outer prefix.
It does **not** forbid signals, dirty globals, later catches, duplicate caller
prefixes or reuse. If a newly admitted callback mutates a root and returns
normally to its suspended core frame, this transfer is unavailable until that
case is joined. The faithful native service/unwinding relation remains explicit.

## Partial-state and native checkpoints

The retained native bodies corroborate actual points at which the prefix can
stop. They are compared against the installed ELF, not newly disassembled.

| Operation | Mutation and subsequent frontier |
| --- | --- |
| `pp_enqueue` | Stores increased right total at `0x986e1d`, then transfers to Queue.add at `0x986e2e`; its cell allocation can fail before linking. |
| `Queue.add` | Allocates its 24-byte cell before loading last; length and first/last/next publication use ordered stores and `caml_modify`. |
| `Queue.take` | Removes first (or clears the queue) before returning a token; no successful-path OCaml allocation. |
| `Queue.peek_opt`, `Stack.top_opt` | Allocate a 16-byte Some around a locally read cell; a mutating signal cannot return to those stale locals. |
| `Stack.push`, `Stack.pop_opt` | Push allocates before publication; pop publishes the tail and decrements length before its 16-byte Some allocation (`0x9641c5`). |
| `set_size` | Writes the new size before popping; the bound below even permits an abandoned write to leave the same scan entry for another addition. |
| `pp_close_box` | Enqueues an end, performs two set_size calls, then decrements depth at `0x987d87`; failure before that decrement can leave a duplicate closing obligation. |
| `pp_flush_queue` | Polls its close loop, writes P at `0x988242`, drains, optionally outputs newline, then resets. |
| `pp_rinit` | Resets totals/queue, clears/rebuilds scan stack (allocations), clears other stacks, resets indent/depth/space, then opens a new system box (allocations). |
| `advance_left` / output | Removes a token before formatting; updates left total only after formatting returns. Newline/indent and text/space stores may precede a failing output callback. |

`caml_modify` stores the field before barrier bookkeeping and never calls GC
(`memory.c:608–663`); barrier internals remain R. The argument conservatively
allows abandonment between source stores, including incomplete queue/stack
length updates. It does not claim every such source cut is a native signal
safepoint. A failed reset may leave no scan sentinel or a queue with lost cells;
the source handles an empty scan stack. Depth need not equal the number of
queued or formatted boxes. Totals need not equal the lengths still linked.

For example, a flush can assign P then fail at the first peek allocation,
leaving right_total=P. A later text event adds to P rather than to 1. This is
a permitted abstract prefix under the service-failure premise, **not a claimed
reproduced execution**. It disproves reuse of the old `[1,1+L]` right-total
induction. Likewise no `[0,L]` scan-size assertion survives every dirty reset.

## Linked structure and attempted work

Give each allocated queue cell a strictly increasing birth index. Every next
write points from an older cell to the newly allocated cell. First is assigned
only nil, a new cell, or the current first's next. Therefore linked chains are
acyclic and first never returns to an already removed cell, even if a partial
clear/add leaves last detached or drops an unprocessed suffix. A returned take
has removed its token before formatting; failed takes cannot format it.
No resumed stale local frame can restore an older first or publish an old tail.
Thus each queue insertion is formatted at most once. Immutable stack tails
similarly preserve finite lists despite partial count updates. Traversal tests
links, not Queue.length or Stack.len. No semantic rollback is asserted.

Let O, D and F be attempted user opens, direct closes and flushes; they are
disjoint parts of E. Each completed effective close consumes a user-depth
increment. Resets only decrease depth, then their system open takes 0 to 1;
they do not create a user-depth credit. An abandoned open may create a credit
without a queue token, but it is already one of O. Hence completed closes are
at most O. Each incomplete effective close belongs to one abandoned direct
close or one abandoned flush; there is at most one such close in that event,
because no local recovery continues its loop. These counts are disjoint from
completed closes. Thus all effective close attempts satisfy

```text
C <= O + D + F <= E.
```

This accounts for repeated end tokens when depth was not decremented. Direct
non-close tokens use at most E insertion attempts; all closes use at most E;
each attempted reset adds at most one system insertion, charged to F<=E.
Include the two entry system tokens and set `I=3E+2`. This also pays for
allocated token/scan objects whose enqueue/publication never happened. Reset
constructor failure does not earn a free retry; the next flush is a new event.
There are at most `3E` set_size calls and `4E+2` sentinel initialization attempts
(entry, reset, or obsolete scan). Each linked queue/stack length is at most
`I+1`; allowing partial resets, every integer count has absolute value at most
`4I+2`. In particular, count fields are not assumed equal to linked lengths.
Depth lies in `[0,E+1]` even when its box representation is incomplete.

## Arithmetic guard

Put `L=B+E`, `P=1000000010`, `T=P+L+1`, `S=(3E+1)T`. Require

```text
L + 79 <= P
S + L + 79 <= 2^62 - 1
4I + 2 <= 2^62 - 1
```

Each text/break length is nonnegative and all such attempted lengths sum to
at most L. Right total starts at 1, is reset to 1 or assigned P, and receives
at most L additions, even if cell allocation then fails: it lies in `[1,P+L]`.
Left total starts/resets at 1 and receives only lengths of removed tokens
whose formatting returned, totaling at most L: it lies in `[1,1+L]`.
Pending subtraction lies in `[-L,P+L-1]`. A reset need not synchronize these
fields with retained scan entries for these bounds to hold.

An opening/break unknown size starts as minus a right total, in `[-T,0]`.
Only begin/break entries can receive set_size additions; text sizes do not.
Even allowing the same entry to survive a write before pop and be modified
again, there are at most 3E additions, each at most T. Therefore scan sizes
lie in `[-T,S]`. Cross-reset sizes may stay negative; advance_left uses P
for every unknown size. It does not reinterpret a negative size as a huge
text length. Known begin/break sizes affect comparisons, not text-space
subtraction. This larger guard deliberately tolerates more partial states than
the native pop safepoints actually expose.

Text and same-line breaks subtract at most L in total. Space is in `[-L,78]`;
box width (space minus 0/1) is in `[-L-1,78]`. Newline computes `78-width`,
in `[0,L+79]`, clamps to 68, and sets space to 78 minus that indent. Partial
stores preserve these separate intervals; current indent is in `[0,68]`.
Before/after break strings are empty. The guards cover every selected core
addition, subtraction, negation, depth/count update and size comparison.
On a flush that completes without abandonment, `P-left>=78` allows every
unknown queued token to drain; each iteration removes a cell. This proves
bounded source work, not that interrupted output is rolled back or delivered.

## Requests and offered output

The [earlier allocation partition](retained-why-save-format-allocation.md)
uses only attempted insertions/scan operations once these counts are repaired:

| Core-owned objects | Cumulative allowance |
| --- | ---: |
| Token/queue records, break triples and queue cells | `144I` |
| Scan records and cons cells | `48I` |
| Formatting records and cons cells | `48I` |
| Stack Some results | `144I` |
| Queue peek Some results | `32I` |
| Sentinel replacement groups | `160I` |
| Empty-tag flush iterator closures | `64I` |
| **New requested OCaml object bytes** | **`640I`** |

At most 3E set_size calls plus token processing fit the 5I top/4I pop
allowances. Each advance run has at most one final non-removing or interrupted
peek, with at most E direct runs and I removing iterations; `I+E<=2I`.
`4E+2<=2I` pays 80 bytes per sentinel group. Prefixes are charged even before
publication, and no reclamation credit is taken. The two entry-token allowances
make this a loose bound on **new** requests; they do not reclassify initial
objects as newly allocated. Formatter records, output closures/channels and
other preexisting storage remain separately owned by `A_pre`.

Each text insertion offers its length at most once. Every processed begin,
break or forced-newline token offers at most 69 bytes (newline plus at most
68 blanks). Dirty reset system boxes are included: they can now force a line
break, so they are not silently treated as free. Their number plus user opens,
breaks and forced newlines is at most `E+2`. Each flush adds at most one final
newline. Consequently, summed over both standard channels,

```text
offered bytes <= B + 70(E+2)
core output-field invocations <= 4(E+2)
channel output/flush leaf invocations <= 6(E+2).
```

The last bound includes the stderr wrapper's extra flush per newline; the
wrapper emits no extra byte. Since indent<=68 and ordinary blanks<=1, default
display_blanks makes at most one output-string call per invocation. A flush
event can pay both its new system box's later two field calls and its own
newline/flush calls. No channel-internal write/retry count is claimed. A failed
service may have physically delivered a prefix, but later caller repetitions
must be in B/E; the core does not replay a removed token.

Add JSON's [byte escape](retained-why-json-byte-escape.md) non-core allocation
charge separately, using its prospective B/E and normal numeric-service premise.
Account separately for fixed annotation Buffer/formatter/parser objects,
accumulators, all scalar conversions, callers, exceptions and channel/runtime
services. A cumulative owned live-object subset is bounded by `A_pre+640I`
only after A_pre is supplied, with additional owners added once. This is not
heap reservation, fragmentation, GC work, resident memory, R, native stack or
physical availability. Actual joined exports remain null.

Oracle 7–9, 13, 21 and 25 remain unchanged. This scoped source argument is
corroborated by installed bytes under the existing external behavior relation,
not a full binary refinement or universal Silver assurance proof. #119 remains
incomplete; production is unstarted. Author selected setting: GPT-6 Astra /
Extra High; runtime confirmation and token/cost telemetry unavailable. The
packet's round record contains measured wall time and validation scope.
