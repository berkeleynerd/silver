# Review of the selected controller-owner join

2026-10-23 UTC; #119 / #153. **Accept this component at author freeze
`e5ae9e7122a090900680bc327f6eea85f5b20869`.** No material defect was found.
The selected Why-only SIGINT mask, the existing ordinary runtime/source
relation, and the explicit successful-published-mutation guard suffice for
this caller/population/representation join. No additional generic theorem
about arbitrarily interrupted OCaml hash tables is required for its stated
scope. This is not acceptance of the complete capacity rule or production.

## Exact inputs and review scope

Reviewed the eight additions relative to published base
`32576dd5d6b195f7e69669a63248ac30e6e9e333`: the
[controller-owner note](../research/retained-controller-owner-join.md) and its
[author packet](../evidence/retained-controller-owner-join-20261023/README.md).
All eight working files were compared byte-for-byte with the frozen commit.
The independent [review packet](../evidence/retained-controller-owner-review-20261023/README.md)
records those identities, 21 unchanged retained provider identities, the 14
author-manifest source member identities and their 42 exact ranges, and 30
independently selected source-anchor groups. The latter also inspect the
driver's single `ServerCall` construction beyond the author's listed ranges.
No author or predecessor checker was executed or imported.

The source is the retained Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml revision
`8eb41f72ded84df884c3671734c947f612091f84`; the selected route is the combined
quiet/timeless/J12/logging registration, CE off, three immutable prover keys,
one OCaml worker and the stated excluded scheduling roots. The Oracle,
AGENTS, development review bookkeeping and agent workflow were read together
with the relevant source/native, runtime, scheduling, callback, logging,
protocol and R55 mask-selection sections. Existing accepted results are
reused with their original conditions, not promoted to new native evidence.

## Source findings

1. **Ownership is established by source transitions.** `Gnat_checks.next`
   removes its goal before returning it (272–280). The parallel branch
   excludes reinsertion; the inherited fully split/CE-off closure excludes
   clones. The selected prover list is visited once (1049–1084). Controller
   scheduling enqueues once and calls Scheduled before synchronous idle
   (641–652); idle pops before build (517–536). An exception can abandon an
   owner but supplies no replay edge. Synchronous idle does not poll timeout
   while the initial prover-list episode is being scheduled.

2. **Saved and live records have separate publication points.** The private
   request ID starts at zero and increments once before command preparation
   (`call_provers.ml:460–465,507–532`). One saved record is added before send;
   a failed send or later driver failure may leave an orphan. Driver maps its
   single returned ID to `ServerCall` (`driver.ml:456–494`), and controller
   inserts one live record under that fresh key (429–440). Orphans and unused
   IDs remain charged to their original scheduling owner. The argument does
   not equate successful insertion, delivery, completion or kill.

3. **Removal and exception scope prevent callback replay.** The controller
   removes each terminal live entry before invoking Done, Interrupted or
   InternalFailure (448–491). OCaml's `| exception Not_found` protects the
   lookup scrutinee, not exceptions raised by its successful branch. The
   cancellation traversal sends interrupts and does not insert live entries
   (560–576). With at most three owners for a goal, successive distinct Done
   removals expose at most `2+1+0` remaining owners even without assuming one
   successful cancellation pass. Losing calls from earlier goals can remain
   live; the bound is `3g`, not three times the number of checks or workers.

4. **Returning failures are covered rather than hidden in mutation success.**
   Preparation, command and send exceptions may return through build/idle's
   InternalFailure handlers. Those handlers do not requeue; the selected
   parallel callback logs and drops the status. A logger failure may escape
   or reach idle's one additional handler, without retrying the popped owner.
   F handling removes saved data before cleanup and parsing
   (`call_provers.ml:478–498`). Unknown/duplicate F lookup and malformed
   response parsing fail without adding an owner. Unknown controller live
   keys are ignored. Missing answers may leave existing owners waiting.
   These cases establish neither eventual delivery nor termination.

5. **There is no resumed receive or cancellation traversal.** Result transfer
   adds occurrences, builds a fresh list, and clears the buffer before
   controller dispatch (`call_provers.ml:541–560`). A failure before that
   return abandons the timeout call. A failure during cancellation or Done
   also leaves it. `Gnat_scheduler.main_loop` catches only Exit, entering
   ending once; the outer GNAT handler reports or rethrows and does not
   restart the loop. Interrupted queue callbacks do not schedule or cancel
   recursively. Queue.fold captures the next link before invoking its
   callback, and clear/rebuild retains each survivor at most once. The
   retained queue-cell population is bounded; cumulative queue allocation
   is deliberately not claimed.

6. **Controller Hpan and session state are distinct.** Controller Hpan is
   created empty with 17 requested buckets (`controller_itp.ml:132`), and
   only Scheduled adds its cell (592–617). The pre-existing session
   proof-attempt table has its separate `create 97` and nonzero registration
   counter (`session_itp.ml:620–675`). Thus `c0=14/12/10/1/3` does not give
   initial controller Hpan occupancy. The existing session attachment plus
   at most one constructor per graft bounds its counter by `c0+n`.

7. **The running counter really stays zero.** New live records have
   `tp_started=false`. Blocking result transfer filters ProverStarted before
   dispatch; therefore the only increment/true replacement is unreachable.
   Each terminal decrement is guarded by `ptp.tp_started`
   (`controller_itp.ml:435,463–482`). A Done for an unstarted call does not
   decrement zero. The parallel goal's remaining count is guarded at zero,
   starts at at most three, and decrements only on Done. Blocking idle also
   short-circuits the heuristic multiplication.

These steps support a simultaneous induction on represented controller state
and consumed owners, up to a first hypothetical invalid-state cut. They do
not assume the desired owner count as a generic valid-owner premise.

## Containers and arithmetic

The three protocol tables use immutable integer/ServerCall keys; Hpan uses
the bounded integer session IDs. Their selected scalar hash/equality paths
do not invoke an application callback that could raise a semantic exception
inside a mutation. Under the already explicit mutation guard, ordinary add,
replace, remove, clear and rehash preserve the proper bucket-chain relation.
There is no selected insertion during traversal of the same table. Rehash
therefore reuses each cell, and collisions affect probe length without
creating another binding. This uses the approved ordinary runtime/source
relation; it is not a new machine-checked theorem for the OCaml allocator or
arbitrary interrupted mutations.

Queue population, saved-data cells, live-call cells, controller Hpan cells and
request ID are individually bounded by `n=3g`. Result_buffer instead uses
`2n` physical occurrences: S and F may share one key and Hashtbl.add preserves
both bindings. That bound continues to require the accepted intact S/F stream
ownership interface. It does not extend to arbitrary injected or malformed
concatenated messages merely because their parser returns an integer.

| Domain | g | n | 2n | B(n) | B(2n) | c0+n |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 51 | 153 | 306 | 128 | 256 | 167 |
| Put | 42 | 126 | 252 | 64 | 128 | 138 |
| First_Or_Default | 22 | 66 | 132 | 64 | 128 | 76 |
| Is_Message | 2 | 6 | 12 | 32 | 32 | 7 |
| Input_Is_Valid | 1 | 3 | 6 | 32 | 32 | 6 |

`create 17` rounds to 32. Growth occurs only after size exceeds twice backing;
thus the least power of two `B>=32` with `m<=2B` bounds final backing even
with arbitrary intervening removals/clear. Probes visit at most m cells and
iteration visits at most B bucket heads and m cells. Bit masking by `B-1`
selects an index in `0..B-1`, including for a negative scalar hash. A grown
table's old array and new data/tail arrays require `5B/2` working slots;
all arrays allocated over its suffix require `4B-96` slots and
`1+2 log2(B/32)` headers. The initial-only case has 32 slots and one header;
the `5B/2` working formula applies only after growth. The largest cumulative
slot count is 928. The size,
load-test, growth, ID, counter and byte/header arithmetic fits signed63 and
the selected ordinary array bound. Garbage awaiting collection is covered
by the cumulative array total, not by the smaller working-array claim.
Payloads, bucket-cell bytes, complete stack/heap accounting and cumulative
queue rebuild allocation remain outside this backing-array component.

The independent audit checks the registration projection, these numeric
rows and source identities/anchors. It separately explores 98,820 finite
abstract population/capacity states through 306 insertions, allowing arbitrary
removes/clear, and checks the independent least-power formula against them.
Those finite cases audit the arithmetic abstraction; they do not prove
source semantics or a universal assurance theorem. The manual source
argument supplies the correspondence and conditional ownership reasoning.

## Boundaries and evidence

The mask selection is already recorded in R55. Under its complete guard the
controller contributes zero SIGINT save entries; the process-wide e<=2,
two save-entering callbacks and three saves remain unchanged. Other owners'
Q and the retained 459-run/918-response protocol reservation are unchanged.
The successful allocation/stack condition during published mutations is
explicit and separate from the represented arithmetic proved here. Masking
alone does not establish physical resource success. This review neither
widens that premise to exclude legitimate returning domain/send errors nor
requires a new generic allocator/kernel proof gate.

Actual checked spawn-mask/default-SIGTERM attachment, termination/reaping and
separate server/solver ownership remain future #88 refinement. Complete q,
finite polling/solver work, current-grammar coverage, complete obligation
discharge and whole-rule source correspondence remain outside this component.
Oracle, tools, pins and current admission are unchanged; production #88–#94
remains unstarted and PR #121 remains draft/unmerged.

The one independent audit passed **1,081 checks** in **1.159796 seconds**;
its subprocess wrapper measured **1.273262 seconds**. It ran on native
Linux x86_64, kernel 7.0.14, glibc 2.43. No target, compiler, solver, proof,
capture or disassembly ran; no successful author/provider audit was replayed.
The author's 3,510-check result remains author evidence, not this review.

Selected reviewer setting: **GPT-6 Astra / Extra High**, as supplied at
subagent launch. Independent runtime confirmation and isolated token/cost
telemetry are unavailable. Review began at **21:34:52 UTC**; the packet README
records the completion boundary and total elapsed interval. The result closes
the selected controller join with no author rework requested. Shared records,
GitHub state, harness goals and CLI memory were not changed by this reviewer;
integration and publication remain with the lead.
