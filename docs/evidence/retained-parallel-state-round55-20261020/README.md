# Round 55: guarded parallel state, logging startup and protocol storage

2026-10-20 UTC, Linux x86_64. #119 and its scoped child #153 remain active
and incomplete. The [independent review](../../reviews/review-parallel-state-storage-20261020.md)
accepts the following components at their stated interfaces.

| Component | Final author/reviewer freeze | Integration commit |
| --- | --- | --- |
| Protocol counts and ring storage | `074ca7919dd3a9528b9fcd047c2e1e928585c854` | `622b29d9d4` |
| J12 logging startup/constructor transfer | `bb9bc85d36e5a8ea47c1fefe09ad4f71ae86d822` | `18d99773ab` |
| Guarded mutable state, repairs and companion pin | `99e7bbde5616bb2eaa2fab40b86ff8ad0242585c` | `c4cc50fbb2` (preceded by `ef0be3fb61`, `b80273545c`, `ae4c98fdd3`) |
| Independent review | `84772fd0bf2bee75296b62d1548e96c777182373` | `d2bab81f4e` |

The [logging argument](../../research/retained-parallel-logging-prefix.md)
transfers the exact R53 J12 invocations with **one added --logging flag**, under
the recorded path, environment, ordinary-service and callback premises. It
joins the pre-registration constructor trace, including intermediate Dprop
reconstruction, and the 118 registered roots / 47 checks / 6,747 binder records.
Input's older post-CE table is not equated to its registration table. The added
allocation is 38–41 minor words and four promoted major words, plus native
channel/path/argv/descriptor storage. Review corrected phase 0 from idle to
mark and required a same-source-point startup collection argument; endpoint
totals alone would not bound extra promotion.

This result is **not** the combined quiet/timeless/J12/logging startup theorem.
R52's quiet/timeless transfer has serial inputs and its own path/credit
interface. Their additive/relocation composition remains required before the
complete candidate configuration can use the transferred states.

The [state argument](../../research/retained-why-parallel-state-attachment.md)
pins all fourteen exact logging companion files. It transports initial
representative families, using a no-removal subset overapproximation for Input,
then derives the arbitrary-first-fill producer induction under valid counters,
keying and successful non-unwinding published mutations. The installed
hashcons/ephemeron interruption windows prevent assuming that arbitrary failed
callbacks preserve those premises. Wtask is a second root; loss of Wdecl alone
is not a demonstrated whole-family failure. No corrupt fixed-domain execution
was observed. Every full first CE walk reaches its first memo resize at entry
129; actual interruption reachability is a separate question.

The [storage argument](../../research/retained-adapter-protocol-storage.md)
derives at most 459 run/interrupt owners, 459 history/control slots and 918 S/F
records, with fresh positive request IDs at most 192. At J12, old/new pointer
ring backing is bounded by 41,536 bytes. Payload formulas remain parameterized
by actual paths and request lines. One pending F acknowledgment does not bound
backlog by the worker count; canceled allocations cannot simply be subtracted.
Native records/argv, logs, raw files, allocator overhead and full q remain open.

## Selected prospective launch interface

Continue the capacity derivation along the reviewed **Why-only SIGINT mask**
route, rather than requiring an additional combined unmasked-recovery theorem.
This is an implementation design choice within the authorized unchanged-tool
work. It is not a new owner policy, an Oracle amendment, an observation of a
current launch or adoption in production.

The concrete candidate mask is `M={SIGINT}` at gnatwhy3 exec, established with
checked `POSIX_SPAWN_SETSIGMASK`; SIGTERM has the default disposition through
checked `POSIX_SPAWN_SETSIGDEF`. Thus SIGTERM, SIGVTALRM and SIGCHLD remain
unblocked. A different mask requires an explicit relation to the same source
guard. The reviewed runtime paths preserve the SIGINT bit. The separate
external server and its solvers do not inherit this Why-only launch rule.

#88 must identify and implement the actual control point, check attribute/spawn
outcomes, keep cancellation non-successful, and guarantee Why termination/reap
using unblocked default SIGTERM and SIGKILL fallback. It must separately own
the external server and solver PIDs/groups and cover the interval before the
child's `setpgid`: stock `kill(-pid,SIGKILL)` can miss that interval and ignores
its return. One client's EOF is not proof of shared-server shutdown. The actual
ownership/fallback/reaping design and its capacity/correspondence are required;
none is supplied by merely naming a signal mask.

Under the complete guard no SIGINT save callback begins. Zero remains a subcase
of the unchanged **two save-entering callbacks / three saves / e<=2 per process**
budget. Normal ending save/exit and successful mutation allocation/stack/size/
counter premises remain. This selection does not discharge those premises or
turn representation failures into environmental resource failures.

## Reconciliation and continuation

`check.py` reconciles 47 frozen files, 75 direct retained repository identities,
94 unchanged native source pins and the unchanged installed Why executable,
with eight Python parses and eighteen frozen-record links. It passed in
0.645182739 seconds, reusing successful component evidence. No component checker,
native target, compiler, solver, proof or capture was replayed by integration.
The review's three focused checks took 12.630 seconds of subprocess time within
its retained 1,200.263-second interval. Author checks and repairs retain their
own timings. See the [round ledger](../retained-tool-rounds.md#round-55--guarded-state-logging-startup-and-protocol-storage)
for settings, rework and unavailable isolated cost data.

Next work attaches request/filename bytes, completes fixed-family inline and
later preparation/counter/printing bounds, composes the combined startup and
all storage/output owners, then completes the original producer/consumer/fixed
dependency/current-grammar coverage, checked accounting/source correspondence,
whole-rule composition, useful-domain comparison and final review. No complete
q or expanded admission is established. Oracle/tools/pins and current admission
are unchanged; #88–#94 remains unstarted and PR #121 stays draft/unmerged.
