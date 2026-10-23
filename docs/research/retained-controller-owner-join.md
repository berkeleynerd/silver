# Selected controller ownership and strong-container join

2026-10-23 UTC; #119 / #153, author base `32576dd5d6`.
This closes the concrete controller-owner and representation inputs of the
[current 3g protocol join](retained-current-protocol-join.md) under the already
selected Why-only SIGINT mask and published-mutation guard. It attaches the
ordinary strong-table/queue relation to these callers; it is not an arbitrary
interrupted-Hashtbl theorem. The [packet](../evidence/retained-controller-owner-join-20261023/README.md)
retains source identities, strict source ranges and one focused offline check.

## Exact scope and inherited guards

Use the current combined quiet/timeless/J12/logging registration, immutable
fully split Per_Check forest, three immutable prover keys, CE off, one OCaml
worker, and no replay/editor/manual/reload/external-scheduling roots. Why3 is
`9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml is
`8eb41f72ded84df884c3671734c947f612091f84`, on the retained Linux x86_64 route.
The existing [source/native relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
and [external runtime boundary](../trusted-boundary.md) remain in force.

[R55 integration](../evidence/retained-parallel-state-round55-20261020/README.md#selected-prospective-launch-interface)
**selected** the Why-only inherited SIGINT mask. The older component's wording
that the alternative was not selected does not undo that integration decision.
Its [runtime closure and mutation guard](retained-why-parallel-state-attachment.md#sufficient-continuation-guard-and-the-why-only-mask-alternative)
exclude save-entry unwinding of these mutations: no selected application
finalizer, other worker, alarm, Memprof client or native hook adds a callback.
The one-worker tick returns. Allocation/stack services must succeed throughout
mutations that publish state, or a terminal failure must not resume them.
Masking alone does not establish that resource premise. Representation and
counter bounds below are derived separately, up to the first invalid-state cut.

Thus the controller's SIGINT-save contribution is zero on this selected route.
The **one process-wide e<=2 / two save-entering callbacks / three saves** budget
is retained unchanged for composition. This does not renew it or rewrite the
broader Q=3g+2 bounds already accepted for other owners. Checked mask/default
SIGTERM attachment, termination/fallback/reaping and separate server/solver
ownership remain future #88 refinements, not observed production behavior.

## Consumed roots, queue owners and unique live calls

The following are caller invariants, not inferences from distinct-key counts.
All file references below are to the pinned source ranges in the packet.

| Source owner | Initial state and preserving steps |
| --- | --- |
| Registered goal selection | The combined-prefix/root-map providers give the completed registration cut. `GoalSet` is an immutable `Set.Make` tree behind a ref (`gnat_checks.ml:115–148`); `next:272–280` publishes removal before returning its singleton goal. Failure before publication cannot also return that goal. Parallel `register_result:621` excludes failed-goal reinsertion; the accepted forest/CE closure excludes new clones. `explmap` and `goalmap` receive no suffix insertion. |
| Scheduling and queue | `schedule_goal:1049–1084` visits at most three fixed prover-list entries per consumed goal. `schedule_proof_attempt:641–652` grafts once, adds one queue item and sends Scheduled before entering idle. `Gnat_scheduler.idle:10–12` drains synchronously; timeout processing cannot interleave a Done callback with that goal's initial prover-list episode. `idle_handler:518–540` pops before build and never requeues. A failed prefix can abandon work, not replay a list element. |
| Request IDs and saved records | The private `gen_id` starts at zero (`call_provers.ml:460–465`); each reached call increments once. `call_on_file:507–532` adds one saved record under that fresh integer and offers one run request. A later send failure may retain that record. Such an orphan still consumes its original owner and ID. |
| Live calls | `build_prover_call:409–440` receives at most one `ServerCall id` from that owner, constructs its immutable call/goal/callback record, then replaces the fresh key once in `prover_tasks_in_progress`. Its keys are integers wrapped in the immutable ServerCall constructor; no selected EditorCall exists. The ordinary key relation makes this a fresh insertion, not a second physical binding for an existing call. A later observer/status failure may leave this one live entry. |
| Result consumption and cancellation | `timeout_handler:448–491` removes a live call before Done/Interrupted/InternalFailure. Blocking transfer filters Started before dispatch, so the Running replacement/counter increment is not reached. A missing live key is ignored by a catch protecting only the lookup scrutinee. The callback body is outside that catch. Cancellation iterates remaining live entries and never inserts one (`:560–575`). |

Consequently each root has at most three live-call owners over its entire
history, even when old losing calls overlap later goals of the same check.
There is no worker-count or `3*number_of_checks` bound on live entries here.
For k<=3 owners, successive distinct Done removals expose at most
(k-1)+(k-2)+...+0<=3 interrupt offers. The inherited launch theorem therefore
applies with n=3g to both run and interrupt entries. Sending, delivery, successful
kill and eventual completion are different facts; none follows from this count.

The [accepted logger argument](retained-why-logging-capacity.md#callback-multiplicity-including-failed-prefixes)
already supplies the queue-cancellation and result-transfer reasoning. Reuse it:
Queue.fold snapshots each next link, Interrupted does not schedule or recursively
cancel, and clear/rebuild appends each surviving owner once. Failure leaves a
prefix or the old queue but escapes timeout without resumed traversal. Thus
physical queue population is at most n, even though rebuild can allocate new
cells. This is not a cumulative queue-allocation bound.

## Returning errors and abandoned prefixes

| Reached outcome | Why ownership is preserved |
| --- | --- |
| Ordinary preparation/driver/command failure, including Sys_error | The popped owner is never requeued. Build's Sys_error handler and idle's broader handler can each report InternalFailure, but the selected parallel callback logs and drops that status (`gnat_checks.ml:1060–1077`). It does not call the serial failure printer or schedule another goal. The accepted callback closure supplies this routing. |
| Failure after saved-data add or after live insertion | Completed strong mutations remain valid. There can be a saved-data orphan, a live call whose Scheduled membership was removed, or an unused positive ID. None creates another owner or reuses the ID. Each is included in the n insertion allowance; no successful completion is inferred. |
| Terminal answer parsing or file-cleanup failure | `handle_answer:478–494` finds and removes saved data before cleanup/parse. A failure can lose that result; it cannot republish its saved owner. No catch around this work resumes the timeout loop. Normal parsers returning a failure/unknown result merely supply one value to the existing Done owner. |
| Malformed or absent protocol answer | `Prove_client.read_answer:230–250` raises InvalidAnswer or lets conversion errors escape. An unknown/duplicate F fails the saved-data lookup; an unknown live key at controller dispatch is ignored. These outcomes create no call/queue owner. Empty reads can leave the loop waiting with existing owners; missing messages prove neither success nor termination. |
| Result-buffer/cancellation callback failure | Transfer builds a fresh list and clears the buffer before dispatch (`call_provers.ml:543–560`). Escaping add/fold/clear, cancellation or Done failures leave timeout; `Gnat_scheduler.main_loop` catches only Exit, calling ending once. No later poll retries the abandoned result list or queue rebuild. |

The represented integer/ServerCall keys of the three protocol tables invoke
ordinary scalar hash/comparison, not an application callback that can raise a
semantic exception midway through mutation. Hpan uses `Hint`/`Exthtbl.Make` /
`Hashtbl.Make` with integer equality/hash (`session_itp.ml:106`,
`wstdlib.ml:12–23`, `exthtbl.ml:38–44`). Allocation/stack or asynchronous
unwinding inside published mutations is still governed by the explicit guard;
the preceding error cases are not a proof of arbitrary resumed resource failure.

## Actual populations, counters and backing

`scheduled_proof_attempts` starts as an empty Queue, and the request counter,
running counter and controller Hpan start at zero/empty. The fresh registration
cut has not called scheduling, call_on_file or result transfer. Initial Trivial
attempts are session records, not Scheduled/controller-live entries.
`prover_tasks_in_progress`, `saved_data`, `result_buffer` and Hpan each use
`create 17`, hence **32 buckets** under the selected strong Hashtbl constructor.
The first three use immutable call/integer keys; Hpan uses the existing bounded
session IDs. Each Scheduled callback adds at most one Hpan cell, irrespective
of whether later removal succeeds. Existing per-goal/global session-table and
counter attachments are reused; they are not new controller hash-table owners.

Let n=3g. Queue population, saved-data cells, live-call cells, Hpan cells and
fresh request ID are individually <=n. The current registration attempt
counter c0 is 14/12/10/1/3. The accepted one-graft/one-constructor control gives
at most n further increments, so c0+n remains represented; the already larger
session bounds stay usable. The running counter stays zero because Started is
filtered. A goal's remaining count stays in 0..3; no new arithmetic multiplier
is evaluated because the blocking test short-circuits it.

For the result buffer, retain the [accepted intact S/F ownership interface](retained-adapter-protocol-storage.md):
at most one S and one F per original run owner. The bound is **2n physical
occurrences**, not n distinct keys: S and F may share an ID. Selected result
transfer adds each delivered occurrence once and then clears before dispatch.
Failures do not resume its partially consumed state. This derives 2n only
under that existing response/stream premise; it does not prove OS transport,
validate malformed concatenations as original IDs, or bound arbitrary injected
messages. The owner argument for runs/cancellations does not require every
message to arrive.

| Domain | g | n: each queue/table/ID bound | 2n: result occurrences | B(n) | B(2n) | c0+n |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 51 | 153 | 306 | 128 | 256 | 167 |
| Put | 42 | 126 | 252 | 64 | 128 | 138 |
| First_Or_Default | 22 | 66 | 132 | 64 | 128 | 76 |
| Is_Message | 2 | 6 | 12 | 32 | 32 | 7 |
| Input_Is_Valid | 1 | 3 | 6 | 32 | 32 | 6 |

Here B(m) is the least power of two B>=32 with m<=2B. Strong Hashtbl doubles
only after size>2B (`hashtbl.ml:507–512`, functor `:357–362`); removals and clear
never shrink or add cells. At most m physical insertions gives capacity <=B(m)
even when earlier entries remain as orphans or later removals occur. No insertion
runs under a traversal of the same table: live iteration sends interrupts,
result iteration only builds its list, and selected saved-data/Hpan clients do
not insert from an iter callback. Thus the ordinary in-place rehash preserves
one cell per insertion without copying its cells. Collisions cannot increase
the physical population; a lookup/removal/replace probe visits at most m cells,
and an iteration visits at most B(m) bucket heads and m cells. Hash masking
uses `hash land (B-1)`, which is an in-range index for these powers of two.

Resizing allocates the new B-slot data array and a B-slot tail array while the
old B/2 array is present (`hashtbl.ml:116–151`). Peak working array slots for a
grown table are <=5B/2 (32 for a table that never grows). Across its entire
suffix, including the initial array and arrays awaiting collection, cumulative
array-slot allocation
is bounded by `32 + 2*(64+128+...+B) = 4B-96`, with
`1+2*log2(B/32)` array headers. This is a backing-array bound, not a whole-heap
or payload/stack bound. The checker retains each value per table class.

The largest size is 306, largest backing256, load-test operand2B512 and total
cumulative slots928 per table. All are below signed63 MAX=2^62-1 and the selected
ordinary array bound2^54-1; byte/header multiplication also fits. Queue length
increments, set heights/cardinality (<=g, with balancing intermediates<=g+2),
request IDs, and c0+n fit before a first hypothetical overflow. The physical
allocation/stack premise remains distinct from these represented extents.

This supplies the selected caller/population/representation join required by
the current n=3g theorem. The conservative 459-run / 918-response protocol
storage result and other owners' Q remain unchanged. Complete q, finite polling
or solver work, actual #88 attachment, current-grammar coverage and whole-rule
assurance remain outside this component. No production, tool or Oracle change
is made.
