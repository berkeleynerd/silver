# Retained fixed-goal attribution, 2026-10-20

R54 closes a finite source-derived map from the five captured domains' goal IDs
to their `check_tree` roots. It also supplies a **conditional unchanged-stock
completion/log association**: a proxy can associate an original request with a
logged goal by delivering at most one unacknowledged `F` per client domain.
This gates completion delivery only. Solver requests, native solver execution
and cancellation remain concurrent under the selected worker policy.

Neither component is an adopted attribution route or a completed #119 capacity
rule. In particular, the captured serial forests do not establish the same
prefix/IDs for a future `-j>1 --logging` process. This is #119/#153 research;
#88–#94 implementation remains unstarted. Oracle, installed tools, pins,
admission and solver limits are unchanged. Variable Main is outside this finite
result.

The [evidence packet](../evidence/retained-fixed-goal-attribution-20261020/README.md)
pins the five raw capture archives, the accepted goal certificate, 48 exact
Why3/OCaml source slices and the finite projection outputs. The source revisions
are Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. Hashes identify these inputs; no
hash is assumed injective over possible goals or prepared solver tasks.

## Actual finite map and collision

| Captured domain | PID | Raw forest nodes | Registered roots | Nontrivial registered | Checks | Checked binder records |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 17310 | 65 | 51 | 50 | 20 | 3,220 |
| Put | 17514 | 54 | 42 | 41 | 16 | 2,896 |
| First_Or_Default | 17631 | 33 | 22 | 22 | 9 | 560 |
| Is_Message | 17704 | 4 | 2 | 2 | 1 | 34 |
| Input_Is_Valid | 17869 | 5 | 1 | 1 | 1 | 37 |
| Total | — | 161 | 118 | 116 | 47 | 6,747 |

These are registration counts, not an assertion that all 116 nontrivial roots
will be attempted: lazy scheduling, existing results and check status can skip
work. They are distinct from earlier scheduler upper bounds.

Within each captured domain **all raw goals share the very same proposition
object**, with name `def'vc`. The negative result is concrete. `Is_Message`
goals 1 and 2 are distinct, nontrivial registered roots sharing proposition
pointer `140229393157064`, identifier pointer `140229393157080`, name `def'vc`,
and encoded location `[101, 655361, 655361]`. Both carry
`GP_Check:10:VC_RANGE_CHECK:silver_arguments.adb:6:11`. Their report positions
are nevertheless different: goal 2 is root 0 and goal 1 is root 1. Goal 3 is
trivial and has no check label, so it is not registered. `Input_Is_Valid` has
only goal 3 registered, at check 0 / `VC_PRECONDITION`; goals 1, 2 and 4 are
trivial without labels.

Names, locations and default filename suffixes therefore cannot supply an
injective map on even these fixed domains. Why3 itself documents `id_string`
as non-unique (`ident.ml:158–163`). The selected SMT printer's Goal/File
comments use that name/location (`smtv2.ml:810–827`), not a serialized goal ID.
This does **not** prove equality of full prepared solver payloads: formulas and
model attributes can differ. Payload injectivity remains unproved; neither
content digests nor accidental filename order replace the map below.

## Source correspondence for the projection

`project.py` reads retained native blocks, not a regenerated observer summary.
For every forest node it checks the proof-node table entry and task-chain
head/Dprop/formula pointers against the accepted goal certificate. It checks
the native block headers, tags and lengths it decodes. Each domain has one
root (goal 0), one `split_goal_wp_conj` transformation with the exact captured
children, matching child parent links, no detached nodes and no transformations
below those children. The recorded argv is `per_check`, three selected solvers,
CE off, time/steps zero, with no line/region filter, replay, `-j`, or logging.

The traversal mirrors `gnat_expl.ml:548–561`: skip typed terms and `stop_split`;
visit each formula's attributes first; follow only an implication's right side;
for a let, visit the bound expression then opened body; for a universal
quantifier, visit opened body then triggers. This ordering follows
`term.ml:1284–1294`. No visited case expression occurs; encountering one fails
the projection. Triviality follows `gnat_main.ml:29–46`: true, quantifier body,
let body, or implication right side. No case expression occurs there either.

The raw traversal does not rerun native alpha opening. The required restricted
lemma is explicit. Every saved substitution image in every binder opened on
these traversals is checked to be a typed `Tvar`. Source alpha opening adds only
fresh typed variables (`term.ml:635,799–831`). Composition of these substitutions
remains variable-to-variable. Thus substitution cannot replace a formula root
with a differently shaped formula: variables are typed, whereas visited
formula roots have no type. Nonvariable reconstruction preserves its constructor
and copies its attributes; its constructors begin with empty attributes
(`term.ml:628–675,739–778`). Applying the argument inductively through the
visited binders preserves the formula traversal, its ordered attribute sets,
`stop_split`, and triviality. The checked records support this restricted lemma;
they are not a general replacement for Why3's binder implementation.

Attributes are traversed in their retained set order. The projection implements
`read_vc_labels`, including its **per-attribute-set** loop-invariant adjustment:
`expl:loop invariant init` changes an outstanding `VC_LOOP_INVARIANT` to INIT;
another `expl:` changes it to PRESERV (`gnat_expl.ml:495–543`). This adjustment
matters to check identity. `GP_Already_Proved` excludes registration. A
nontrivial child without a check label is rejected, matching
`gnat_main.ml:48–73`; trivial children with labels are registered, including the
two synthetic trivial proofs in Put/Put_Line. The absent filters make
`add_to_check`'s filter conditions true (`gnat_checks.ml:201–227`).

Check identity is `(numeric check ID, kind)`, explicitly excluding location
(`gnat_expl.ml:178–186`). External registration sets `toplevel=true`
(`gnat_checks.ml:264–266`). GoalSet uses integer comparison and ordered
`Set.Make`; OCaml `set.ml:376–378` iterates left/value/right. Report construction
prepends each ascending goal to a list (`gnat_checks.ml:940–944`), so root
indices are **descending goal ID within each check**. The retained
`fixed-root-map.json` is an injective map

```
(domain, goal ID) → (domain, check ID, check kind, root index)
```

on all 118 registered roots. Neither outer check iteration order nor per-prover
hash-table order is used. XML's ordering is different and is not substituted
for the JSON schema.

In the fresh, nonmanual, CE-off Per_Check route, these roots are fully split:
the strategy has the single transform `split_goal_wp_conj`, and each root is
its child with no further transform (`gnat_checks.ml:284–354`). Result handling
therefore uses `unproved_vc_continue` instead of `further_split`
(`gnat_checks.ml:596–663`). Ordinary scheduling/result callbacks update attempts
and check work sets, not this `toplevel` root set. CE transformations, manual
edits, replay/reload and arbitrary historic session mutation are excluded.
This gives root stability for that source route **once the startup forest and
registration map are established**; it does not establish the changed startup
prefix for the prospective process.

## Why S→Running fails

`gnat_main.ml:22–25` instantiates the blocking GNAT scheduler.
`gnat_scheduler.ml:1–28` fixes `blocking=true`. Although a stock `S` becomes
`ProverStarted`, `call_provers.ml:543–560` discards that update when blocking.
The ordinary controller `Running` callback consequently never occurs for it.
Holding `F` until a `Running` log is seen can deadlock on an ordinary request.
The editor Running/Done paths do not repair the noninteractive blocking route.

## Conditional F→Done association

The source association uses the stock `--logging` option together with `-j>1`.
The sole `Logging.log` invocation is inside the parallel branch
(`gnat_checks.ml:1049–1084`); enabling logging alone in the captured serial
configuration would not produce these callback lines. Logging writes a
private `<unit>.why3log`, initialized after connection and controller startup
(`gnat_checks.ml:370–415`). No tool modification is proposed.

The candidate proxy retains R53's original request identity `(D,I,P)`, canonical
file publication and queued-cancellation distinction. It establishes a fresh
private log file identity, with no previous content and only this GNATwhy3
writer, and begins reading from byte zero before releasing the first `F`.
Timestamps are ignored as identities. For each fixed client domain:

1. Preserve backend response FIFO. Forward eligible responses until one `F`
   has been delivered; retain its original `(D,I,P)` as pending. An eligible
   launched completion satisfies R53's canonical-output/adapter conditions;
   an identified backend queued cancellation retains its empty filename path.
2. Continue forwarding requests and interrupts to the backend promptly. Read
   backend responses and log data without waiting synchronously on the log.
   Hold subsequent `F` responses, and any responses behind them, in FIFO order.
   Native solver launching and execution are never gated on this log ack.
3. Acknowledge the pending request only upon reading and retaining the next
   complete `Done` log line for this client. Check its goal against the
   established finite map and its prover against P. Then release the next
   eligible response. Other statuses, and empty lines, are not acknowledgments.

The source proof of the association is narrower than arbitrary log matching:

- `call_provers.ml:478–493` uses the original request ID to retrieve/remove
  `saved_data` and parse its result. `543–560` turns exactly that F result into
  `ProverFinished` for `ServerCall I`. No `ProverInterrupted`/`InternalFailure`
  result is synthesized by this external fetch route.
- `controller_itp.ml:429–438` stored the callback closure under that call.
  The timeout handler may sort a received batch by call ID, so backend arrival
  order alone is insufficient. With one unacknowledged F, a returned batch has
  at most one finished result. The exact call is removed and its closure gets
  `Done res` (`449–491`). For ordinary outstanding calls there was no earlier
  removal: the external route produces only Started/Finished, Started is
  dropped, and interrupts send cancellation without clearing the map
  (`538–576`). Unique original request IDs/no wrap and exactly-once F delivery
  remain required. A missing call, duplicate F or parsing/I/O exception is a
  failure, not an identity recovered from guessed ordering.
- The closure first updates the associated goal/prover attempt, then invokes
  its caller (`controller_itp.ml:592–617`). The GNAT closure logs its captured
  goal and actual attempt prover **before** checking `remaining=0`
  (`gnat_checks.ml:1060–1077`). Losing completions thus still log after a Valid
  winner. Queued requests canceled by the backend still receive F/Done;
  locally canceled attempts never sent to the backend receive Interrupted
  and cannot masquerade as a pending request's Done.
- In this fresh noninteractive, nonreplay, CE-off scope there is no other
  producer of logger Done: editor completions are disabled by blocking;
  synthetic trivial proofs update the session directly; already-proved and
  all-provers-tried shortcuts call the check handler directly. Prelaunch
  failures report InternalFailure. These are not extra Done acknowledgments.

Induction now binds the next Done to the only delivered F whose Done has not
yet been consumed. The source callback supplies its exact goal/prover. Fresh
file identity and exclusive writer are essential: arbitrary forged or duplicated
log lines could violate this relation. This is not a self-authenticating log
format, and a wrong goal from an untrusted writer can be syntactically in range.

After a Done line is consumed, the current callback may still be finishing its
check processing. Releasing the next F is safe for identity: the next external
Done still needs its next fetch/callback. A subsequent callback exception is a
frontend failure and prevents normal terminal confirmation, even when a partial
association was already recorded.

## Why each Done line becomes visible

`Logging.log` constructs a new `Format.formatter_of_out_channel`, prints JSON,
writes raw LF to the channel, then calls channel `flush`
(`gnat_checks.ml:101–111`). Channel flush alone does **not** flush an arbitrary
Format queue. The missing `pp_print_flush` needs a concrete argument here.

`Json_base.print_json_single_line` emits known-size text tokens, with no boxes
or break directives (`json_base.ml:13–32,74–103`). The new formatter has one
unknown-size, zero-length system box and margin/space-left 78
(`format.ml:937–977`). `advance_left` processes that box once queued text length
reaches 78, then drains every known-size token; subsequent text tokens drain
immediately (`427–454`). No unknown inner box remains.

Even artificially shortening both numbers to one character, goal ID to `0`,
prover to the shortest selected name `z3`, and answer to `valid`, a Done JSON is
91 bytes:

```
{"timestamp":0,"goal_id":"0","prover":"z3","pas":{"kind":"done","answer":"valid","time":0}}
```

Therefore every successfully printed Done crosses 78 and drains its JSON before
raw LF and channel flush. `formatter_of_out_channel` uses the channel's
`output_substring` (`format.ml:1000–1002`). Under successful channel/file I/O,
the watcher can read the complete line without formatter destruction or another
event. Valid finite numeric formatting and complete JSON parsing are required
for acknowledgment; malformed numeric output is a log failure, not an ack.

No corresponding assertion is made for every short non-Done status. A short
Scheduled record can leave only the separately written LF visible. Empty lines
are ignored, not interpreted as a complete scheduling history. No capacity bound
for arbitrary timestamp/time strings follows from this **lower** byte bound.

## Report relevance, failure paths and remaining joins

The resulting conditional composition is

```
original request (D,I,P)
  → captured callback goal/prover from its Done line
  → fixed (check ID, kind, root index, prover) report position.
```

Keep the complete mapped attempt history. A later resource result must not erase
an earlier Unknown/Invalid/unexplained failure on an unproved root. A Valid at
the same root (or a proved ancestor in an extended tree) can make competing
attempts irrelevant under #88, but does not erase an independent identity,
protocol or representation defect. The current map has no descendant report
transforms; extending it to other trees needs a separate source relation.

Final `check_tree.proof_attempts` exposes only current nonobsolete results.
Scheduling a new same-prover attempt resets proof_state, and Done updates it
(`session_itp.ml:662–675`, `controller_itp.ml:592–652`). Thus a generic retry
history cannot be recovered from the final row, and this packet does not infer
it from short Scheduled logs. Under the stated fresh ordinary route every sent
completion can be retained with its mapped goal; any broader retry/removal/
interrupted scheduling policy must preserve all history and establish final
coverage independently. A missing row after a reset is not automatically a
resource-only result. R53's unsuccessful-report and defect-precedence policy
continues to apply.

The normal terminal barrier extends R53's audit seal: reconcile every sent
request and backend cancellation, no pending F acknowledgment, all canonical
writers gone, and complete control-stream draining. Also establish the log
writer has ended normally, read all remaining log bytes to its final EOF under
the same file identity, and reconcile extra Done/partial records. EOF on a live
regular file merely means “no bytes presently available”; it is not writer
closure. Only the final seal and normal supervisor/proxy completion permit
confirmation after the strict report/identity audit.

The event loop must monitor frontend termination and interruption while waiting
for an ack. A known frontend exit with pending F cannot leave an infinite log
wait. Missing/malformed output, file I/O failure, callback exception, signal or
abort may leave partial associations and reports. Preserve that evidence and
classify using direct failure observations and #88 precedence; neither absence
of an ack nor an exit code establishes resource cause. Explicit interruption
and independently attributable resource failure can explain incompleteness;
an independently established defect still wins. No time limit is introduced.

Open obligations remain concrete:

- Establish the exact prospective startup/registration forest and goal IDs with
  `-j>1 --logging`, including controller/log initialization and parallel callback
  allocations. The captured serial prefix and its address identities cannot be
  transferred by assumption. R54 adds no native run to establish that transfer.
- Account for log records/paths, formatter allocations, stream buffers, pending
  associations, retained history, canonical files and all backend queues in the
  whole-rule capacity argument. Let K/A/C denote the required aggregate
  response/attempt/control storage until a concrete bound is justified. One
  unacknowledged F bounds only that slot; the completed-F backlog can exceed J.
- Establish original request-ID no wrap, exclusive stable log identity,
  successful byte-preserving I/O, complete response parsing, exact native
  outcomes and continued event-loop/cancellation progress. R53's
  `native_fact_ok` and sealed publication premises are unchanged. The stock
  F-message byte bound `B_F` is a separate source/native-formatting component;
  this note does not assume it has been closed.
- Discharge whole-rule production/proof correspondence and coverage, including
  launch/startup, signals/aborts and failure paths. An observation-only exception
  requires #88's dependency test; adding logging has not itself passed it.

The global per-process budget remains two save-entering callbacks, three saves,
and e≤2; it is never reset per request or attempt. No time/steps
identity tag, solver serialization, finite output truncation or tool patch is
selected. This finite map and conditional source protocol reduce the attribution
gap without claiming universal completion, production readiness or full q.
