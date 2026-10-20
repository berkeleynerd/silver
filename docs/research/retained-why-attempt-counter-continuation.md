# Interrupted attempt-counter continuation

2026-10-20 UTC, Linux x86_64. Owner-resumed research #119 / #153, Round 29,
base `466c44c54b6ec777829400108c2f53920827bcc0`. This is a source argument
and a new narrow offline projection of retained Round 28 captures. No native,
compiler, solver, proof or capture run was performed.

The missing attempt-counter arithmetic can be closed conditionally without
first bounding all interrupted scheduler entries. At every post-cut prefix,

```
counter increments <= published per-goal memberships + 1 <= K + e + 1
next_proofAttemptID <= initial counter + K + e + 1.
```

The extra one covers an unfinished or abandoned increment before membership
publication. Such an abandoned constructor cannot be followed by another
constructor in the selected continuation. This is the additional fact absent
from the accepted [binding-growth result](retained-why-save-attempt-growth.md).

| Fresh process / PID | Captured counter | K pair-key domain upper | e upper | Increment upper | Later counter upper |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line / 17310 | 14 | 192 | 2 | 195 | 209 |
| Put / 17514 | 12 | 159 | 2 | 162 | 174 |
| First_Or_Default / 17631 | 10 | 96 | 2 | 99 | 109 |
| Is_Message / 17704 | 1 | 9 | 2 | 12 | 13 |
| Input_Is_Valid / 17869 | 4 | 3 | 2 | 6 | 10 |

All five guards are far below the retained OCaml native integer maximum
`2^62-1`. The first four cuts follow registration and precede scheduling. The
Input_Is_Valid cut is in first cvc5 preparation, after its graft and Scheduled
callback returned; the whole K allowance intentionally overcounts that pair.
The other three session ID counters do not advance on the selected route, as
established in the prior growth result.

## Scope and imported conditions

The route is the accepted fresh automatic, serial, Per_Check, CE-off,
non-replay continuation with the three selected provers, no debug VC saving,
no editor/reload/merge work and the preserved initial split forest. The
[driver-envelope result](retained-producer-driver-envelope.md) supplies the
finite pair-key domain; its normal entry count is not reused for interrupted
scheduling. `has_been_tried_by` can catch a signal-origin `Not_found` and make
a completed pair look untried.

The accepted [whole-post-cut signal extension](retained-why-save-attempt-growth.md)
is a premise: single worker/native frames, successful mask/ignore operations,
no unmask/reinstallation or unmodeled callback mutators throughout preparation,
result handling and saving. It gives at most two escaping save-callback
exceptions, one budget from the selected cut through the ordinary-save interval.
The budget is not reset at ordinary entry. Captured closure presence does not
establish absence of earlier signal saves.

The accepted membership-growth theorem supplies `M <= K+e` under valid entry
tables, key/hash/equality behavior, atomic publication and key preservation
through interrupted mutations. The [Hashtbl prefix result](retained-why-save-hashtbl-prefix.md)
and fresh table joins provide its conditional attachment; this packet does not
turn an undisclosed native premise into established evidence. In particular,
publication means the reachable bucket-chain membership commit, not successful
return from `Hprover.add`, scalar size increment or global-record installation.

The counter theorem additionally uses normal OCaml exception-handler scope,
correct native counter load/successor/store behavior up to the first possible
overflow, no corruption of the counter or live frames, and no unmodeled path
that resumes a discarded constructor frame or mutates the counter. It allows
allocation/representation operations to raise, fail or stop making progress.
It does not assume they succeed, and does not supply their resource bounds.

## The abandoned-prefix argument

`session_itp.ml:286–290` reads the counter, stores its successor, then returns
the old ID. Its selected caller is `add_proof_attempt:645–660`. The generated
ID precedes allocation of the attempt record, the per-goal `Hprover.add` and
the global `Hint.replace`, in that order. Saving never calls this constructor
or changes the counter. No covered constructor is suspended at a selected cut.

The whole constructor tail beginning with `gen_proofAttemptID` is the
**handler** of `add_proof_attempt`'s `try … with Not_found`. An exception
raised in that handler cannot be caught by that same `try`. Likewise,
`graft_proof_attempt:662–675` invokes `add_proof_attempt` from its own
`Not_found` handler. Its fallback cannot catch a failure in the constructor.
The controller's metadata/adaptive-limit catch at `controller_itp.ml:620–639`
has already ended when the graft is called at line 641.

The dynamic receiving-catch audit is decisive:

| Receiving path | Scope and consequence for a constructor exception |
| --- | --- |
| Automatic GNAT scheduling | `gnat_checks.ml:983–1084` passes through `run_goal`, `schedule_goal_with_prover` and the serial `schedule_goal` branch without a receiving catch. `gnat_main.ml:118–160` likewise has none. |
| Initial scheduling | `Gnat_checks.iter` first builds its key list and then uses `List.iter` (`:506–510`); it does not catch an exception from `handle_obj`. `Debug.Stats.record_timing` uses `Fun.protect` (`debug.ml:168–173`); its finally callback cannot schedule, and protect rethrows or raises `Finally_raised`. The outer main handler (`gnat_main.ml:357–363`) rethrows or aborts, without entering the scheduler again. |
| Done-result scheduling | `controller_itp.ml:448–490` invokes `tp_callback (Done res)` from the successful match branch. Its `exception Not_found` branch protects only the lookup scrutinee, not the Done callback. `gnat_main.ml:75–116` calls `handle_vc_result` and schedules only after `register_result` has returned, outside that function's `Exit` catch (`gnat_checks.ml:598–662`). `Gnat_scheduler.main_loop` catches `Exit` by calling `ending` once; other exceptions reach outer main. Neither path restarts scheduling. |
| Build/idle catches, excluded as constructor ancestors | `build_prover_call`'s `Sys_error` handler and `idle_handler`'s broad handler can invoke `InternalFailure` (`controller_itp.ml:413–440,517–536`). Their GNAT interpreter formats/adds a warning, with no `handle_vc_result`, `next` or scheduling call (`gnat_main.ml:107–116`). Detached/Running/Interrupted notifications likewise schedule nothing. The installed observer only raises `Exit` (`gnat_checks.ml:1327–1332`). Thus a constructor cannot be dynamically beneath these receiving catches. |

The last row does **not** assert that InternalFailure happens once or that it
cannot update status caches. A `Sys_error` during preparation may call
InternalFailure inside build's handler; an exception from that callback can
be caught by idle and cause the same InternalFailure callback again. The
controller wrapper updates the goal before calling the GNAT interpreter.
Those cache updates and later pending work belong to the separate theory-cache
analysis. They do not call `gen_proofAttemptID`.

In particular, `schedule_proof_attempt` calls `run_idle_handler` only after
the graft, queue insertion and Scheduled callback have returned (lines
641–652). Its later inner build/idle catches cannot receive an exception from
that earlier constructor. Conversely, build passes no scheduling callback to
`Driver.prove_task`; the selected callback invocations inside build are the
non-scheduling notifications just listed. This dynamic nesting fact, rather
than a claim that all work stops after InternalFailure, is the needed premise.

By the audit, after an increment, either membership publication occurs or
execution remains in that prefix, terminates, or unwinds to a path with no
further constructor. There is no concurrent/reentrant constructor in saving.
Thus all increments except at most one at the current end of the trace have
distinct subsequent publication events. This is an injection into **events**,
not distinct keys, IDs, or successful global stores. It still holds when a
failure occurs after membership publication but before global installation.
Combining `I <= M+1` with the accepted `M <= K+e` gives the stated bound at
every finite prefix, even if a preparation, save or solver never completes.

This proof does not use ID uniqueness to count per-goal keys. Consequently its
successor guard can be discharged by a first-overflow argument without circular
reliance on counter arithmetic: the source event count bounds the number of
increments, and `counter0 + K+e+1 <= MAX_INT` prevents the first overflow.

## Fresh counter join and verification

The [packet](../evidence/retained-why-attempt-counter-continuation-20261020/README.md)
hashes each retained capture archive and every consumed member against its
manifest. It joins the members to the accepted fresh correspondence and decode
identities, root/session pointer and actual PID. It reads only the session
record from `session-blocks.jsonl`, checks tag zero/17 fields, decodes field 1
as a signed tagged integer, and joins field 0 to the projected attempt table.
The layout is pinned to `session_itp.ml:123–145`. Existing global IDs and all
per-goal membership IDs are nonnegative and below the fresh counter; every
membership ID has a captured global record. Historical process counters are
not transplanted into the fresh processes.

The focused checker verifies exact full-member and excerpt identities, the
counter-reference census, all five projections, missing-premise handling,
unknown/invalid inputs and the exact native maximum/first-overflow boundary.
A small finite prefix abstraction checks increment/publication/abandonment
states and exposes why publication-only arithmetic and restartable abandoned
prefixes are insufficient. These checks exercise the transfer; the caller
audit and native premises are the argument, not conclusions of the test script.

The recorded numeric guards pass. The transfer deliberately leaves the usable
native bound unknown until the continued-signal, membership-publication/key-
preservation and native-counter/no-unmodeled-mutator contracts are attached.
No new scheduler-entry/preparation bound, successful serialization guarantee,
whole-save capacity or whole-pipeline capacity is asserted. Oracle, admission,
source pins and production tooling are unchanged. Independent combined review
is lead-owned; this packet is not that review.
