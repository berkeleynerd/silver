# Intended parallel solver launch and cancellation interface

2026-10-20 UTC, Linux x86_64, #119 / #153. Author base `8d9cee6f09`.

**The intended #88 route forwards its worker count to both gnatwhy3 and
why3server. Its racing cancellation adds protocol messages that the retained
serial suffix did not have.** Under the fixed registered-goal and valid-owner
premises below, a fresh parallel client with G registered goals has at most
3G preparation/run-send entries and 3G interrupt-send entries. This is a
prospective source interface, not a rerun or a reinterpretation of the five
retained serial captures. It does not complete solver output, resource capacity,
automatic discharge or the full #119 rule.

The [packet](../evidence/retained-solver-launch-profile-20261020/README.md)
retains exact candidate-source excerpts and checks identities and arithmetic.
SPARK source remains candidate revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`; its attachment to the installed build
is still open. The Why3 source projection is the unchanged retained one.
No tool, admission or Oracle change is made.

## Stock routing and executable lookup

`configuration.adb:2057–2068` selects the explicit worker count, or the detected
CPU count when requested. `Compute_Why3_Args:3219–3220` appends `-j` and that
same `Parallel` value. `gnatprove.adb:949–957` passes it to the spawned external
why3server. The intended [confirmation configuration](../unbounded-programs.md#confirmation-prover-configuration)
selects `J=max(3, available CPUs)`, zero steps/time/memory limits and the three
provers cvc5, z3, altergo. The server's previously derived signed32 arithmetic
guard `1 <= J <= floor(INT_MAX/2)` remains necessary. No new native run confirms
this prospective route.

`Set_Environment` runs before command-line/project processing
(`gnatprove.adb:1282–1283`). It clears WHY3LIB, WHY3DATA, WHY3LOADPATH,
WHY3CONFIG and WHY3DEBUG, and constructs PATH in this order (`882–917`):

```text
SPARK_Install.GNSA_Dir_Bin
SPARK_Install.Libexec_Spark_Bin
inherited PATH
```

Thus stock GNATprove supplies an installation-relative lookup mechanism. This
does **not** attach the actual solver identities by itself: the earlier GNSA
directory must not shadow the intended solver names, the install directories
and resolved executables must be the pinned ones, and later descendants must
preserve that environment. The retained manually launched server had
`PATH=/usr/bin:/bin`; that historical observation is unchanged. The
[identity inventory](retained-solver-identity.md) remains authoritative for
the executable bytes and the missing correspondence. Extra Why3 configuration
cannot redefine built-in provers; no replacement alias/configuration is assumed.

## Fresh parallel scheduling owners

Import the [registered-goal/driver argument](retained-producer-driver-envelope.md):
fresh selected Per_Check forest, fully split registered goals, three immutable
prover keys, counterexamples off, no manual/replay/editor/strategy entry, no
additional goals or independent external API scheduling. Require represented
valid containers/keys and preservation across the selected callbacks. Those
are caller invariants, not consequences of a lexical search or this arithmetic.

1. `Gnat_checks.next:272–281` removes a selected goal from `to_be_scheduled`
   before returning it. In the parallel branch, `register_result:621` does not
   reinsert a failed goal: the requeue guard explicitly requires parallel=1.
   Fully split goals exclude later splitting; CE-off excludes new CE owners.
2. `schedule_goal:1049–1083` iterates the three prover keys once. Warning goals
   use one key and are covered by the same upper bound. An exception can
   abandon a prefix but does not retry that list element or put the goal back.
3. `schedule_proof_attempt:591–652` gives each entry one queue item.
   `idle_handler:518–540` pops it before building. Its receiving catches report
   InternalFailure; they do not requeue the owner. The synchronous GNAT idle
   loop drains the queue without polling responses. Timeout callbacks are
   processed by the later main loop, so a goal's three scheduling entries
   cannot be interleaved with an earlier Done callback for that same episode.
4. `call_on_file:507–532` generates a call ID and offers one run request per
   successful path to that point. Preparation failures only reduce offers.
   The serial relation E<=3G+e is therefore not substituted here: the parallel
   ownership argument gives E<=3G, including abandoned preparations.

`gen_id:460–465` starts at zero and increments once per call entry. For a fresh
client, `3G <= 2^62-1` gives represented, positive, distinct signed63 IDs.
For a later cut, the corresponding initial counter plus remaining entries must
fit; the fresh-client bound does not prove that relation for a captured suffix.
The fixed five G values all satisfy the fresh arithmetic guard.

The blocking GNAT scheduler also short-circuits the controller's heuristic
`S.multiplier * session_max_tasks` expression. Its multiplier 50 is not an
additional evaluated product on this route. This says nothing about other
controller configurations.

## Cancellation count and signals

`timeout_handler:470–477` removes a completed live call before invoking its
Done callback. `interrupt_proof_attempts_for_goal:560–575` sends an interrupt
for each remaining same-goal live call, then removes queued same-goal entries;
it creates no new owner. Queue-removal notifications are Interrupted, not Done.
`gnat_checks.ml:1061–1077` normally sets remaining=0 after cancelling losers,
but an exception during cancellation can prevent that assignment. We therefore
do not assume only one cancellation pass.

For a goal with k<=3 owners, successive distinct Done callbacks see at most
k-1, k-2, ..., 0 other same-goal live owners. Even allowing each callback to
enter cancellation and abandon its send prefix, interrupt offers are bounded
by `k*(k-1)/2 <= 3`. This uses unique call ownership, removal-before-callback
and no same-goal rescheduling, not successful kill/delivery. Missing or
duplicate results cannot manufacture another live owner under those premises.
An exception that escapes the timeout path leaves for main reporting; it
does not restart the receive loop. The selected save callbacks do not schedule
or cancel solver owners. The generic `Controller.interrupt` API is outside
these roots.

Consequently `N_run<=3G`, `N_interrupt<=3G` and total protocol-send entries are
at most 6G. External connection setup does not send a `parallel` message.
The selected GNAT path does not call `set_session_max_tasks`; the generic
setter and GUI/strategy roots must remain excluded when applying this bound.

On Linux, per-attempt cancellation reaches `proc.c:23–28`,
`kill(-p->id, SIGKILL)`. A delivered SIGKILL does not execute a user-space solver
SIGINT/SIGTERM handler. Kill failure can leave a solver running; no termination
or output bound follows merely from offering cancellation. Separately,
`gnatprove.adb:665–667` invokes `Kill_Process_Tree(...Hard_Kill=>False)` after
GPRbuild. Its exact signal, reachable surviving children and output effects
remain to be attached. Ambient signals also remain separate. SIGKILL racing
cannot justify globally excluding solver terminal handlers.

## Failure-aware server line interface

Reuse the [response-constructor argument](retained-why-server-record-capacity.md)
and its explicit received-byte preservation, caller and normal-service
premises. A partial send may leave a header/ID prefix before the next send;
raw IDs therefore need not be decimal. Fixed command/path operands remain
LF-free under the same selected filename construction and canonical-directory
guards. Those guards must be established for the intended launcher too.

The offered header stems are now `run`/`runstdin` (at most 8 bytes) and
`interrupt` (9). For an accepted run request, its raw ID starts with at most
one original decimal prefix of at most 20 bytes. Until its first subsequent
semicolon it can acquire only later header prefixes: each later full header's
own semicolon terminates that field. If the initial recognized command was
assembled across abandoned header fragments, the same argument starts at the
semicolon ending the last contributing header. With ordered nonduplicating
send-prefix bytes and LF-free operands, this gives:

```text
I <= 20 + 8*N_run + 9*N_interrupt
M <= C + 60 + 8*N_run + 9*N_interrupt <= C + 60 + 51G
Finished allocation <= C + 62 + 51G
pending client line prefix plus read <= M + 1024
direct InvalidAnswer text <= M + 23
```

I bounds echoed run IDs. An interrupt only removes matching queued/running
requests; it does not create a new arbitrary-ID response. Queue-removal
responses reuse those requests' IDs. `parallel` frames cannot be formed from
the allowed header alphabet. A raw malformed record is not established to be
a valid C request; server arithmetic, allocation, ownership and the conditional
native receive-buffer bridge remain obligations. This is a conditional length
interface, not a C memory-safety or successful-response theorem.

| Fixed goal domain | G | Each of run/interrupt offers | Conditional M |
| --- | ---: | ---: | ---: |
| Put_Line | 64 | 192 | 3396 |
| Put | 53 | 159 | 2830 |
| First_Or_Default | 32 | 96 | 1772 |
| Is_Message | 3 | 9 | 287 |
| Input_Is_Valid | 1 | 3 | 216 |

The M column additionally assumes C equals the retained launch-directory byte
length (72/67/80/74/105). It is a prospective conditional substitution, not an
observation of canonical cwd or a claim these parallel clients were executed.
The serial N and all historical JSON/output multiplicities remain unchanged.

## Remaining joins

The single global two-callback/three-save/e<=2 budget is unchanged. No count is
reset for a prover, report, root or channel. This packet does not transfer the
retained serial backing/formatter/diagnostic states to a parallel run. Those
states, semaphore/process routing, selected lookup, full solver outputs,
soft cleanup, service/stack/caller resources and whole-rule correspondence
still need composition. Complete per-file q and weighted O remain null. The
fixed-domain source argument is not universal coverage of the intended grammar.
