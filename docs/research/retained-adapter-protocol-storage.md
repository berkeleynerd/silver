# Fixed-domain protocol ownership and storage

2026-10-20 UTC, R55 research for #119 / #153 on Linux x86_64.

The accepted fresh parallel scheduling interface supplies a finite bound for
the proposed proxy's outstanding and historical requests: **459 attempts across
the five fixed clients**, including unfinished attempts. It also bounds control
connections and completed-response backlog. This instantiates count terms left
symbolic in R53; it does not establish the parallel startup/cache premises, the
complete byte bound for wrapped requests, log records, raw startup output, or
the complete capacity rule. No adapter is implemented or adopted.

The [packet](../evidence/retained-adapter-protocol-storage-20261020/README.md)
pins the imported scheduling result, R53 protocol, R54 completion theorem and
the stock queue/response source. The source argument is conditional on the
already named ownership, selected-source/native/runtime and normal-service
interfaces. Native/SPARK/Lean refinement remains subsequent work.

## Scheduling counts and request identities

The [parallel launch argument](retained-solver-launch-profile.md) gives at most
3G preparation/run-send entries and 3G interrupt-send entries for a fresh
fully split Per_Check domain, CE off, with three prover keys and no independent
replay/editor/API scheduling. Removal-before-callback and no requeue in the
parallel branch pay for failed and canceled attempts. Save callbacks do not
create run owners. These are total entry bounds, not just simultaneous jobs.

Use its conservative G values; do not substitute R54's smaller exact registered
counts before their changed-startup transfer is established:

| Domain | G upper | Run entries N=3G | Interrupt entries upper | Positive ID digits d |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 64 | 192 | 192 | 3 |
| Put | 53 | 159 | 159 | 3 |
| First_Or_Default | 32 | 96 | 96 | 2 |
| Is_Message | 3 | 9 | 9 | 1 |
| Input_Is_Valid | 1 | 3 | 3 | 1 |
| Total | 153 | 459 | 459 | — |

`call_provers.ml:460–464` initializes the private counter to zero and increments
once per call entry. Under the fresh-route entry bound, every generated ID is
in 1..N, well below 2^62-1. A failed send can consume an ID but cannot add a
second increment for that owner. Save code does not access this private counter.
Thus the intact request IDs are positive, distinct and at most three digits.
This is a fresh-process consequence; it is not inferred from a captured suffix
or a final report. The startup/ownership relation must actually be established
before the numeric table can be applied to the proposed route.

Partial writes are a separate case. The
[failure-aware header argument](retained-solver-launch-profile.md#failure-aware-server-line-interface)
permits malformed echoed IDs after abandoned sends. The decimal bound here
applies only to intact, validated original requests. A malformed concatenation
must not be assigned a guessed original identity or called a resource failure.
No receive-buffer byte bound is inferred just from the 459-slot count.

## Backlog and control counts

For an intact admitted run, the stock server either removes it while queued or
dequeues/runs it once (`server-unix.c:547–590,630–635`). Queue removal sends one
F and consumes that queue entry (`536–544`, `request.c:174–190`). A started
request is not subsequently in that queue; `run_request:505–534` creates one
child and sends one S. Successful wait3 reaps that child once; the server removes
its process entry before sending its one F (`462–499`). Repeated interrupts
only offer signals to still-owned children; they do not synthesize additional
F records (`proc.c:36–43`). Client loss or an abort can reduce those counts.

This argument uses valid C containers, unique child ownership, ordinary wait
semantics and the selected request-stream preservation relation. It does not
prove those properties from a socket alone or conceal the separately reviewed
native overlap-safe buffer-copy premise. On this interface each run has at most
one S and one F, including queued cancellation. Therefore:

```
total requests A <= 459
outstanding or retained request slots K <= A
total S records <= A; total F records <= A
backend response records, including a current partial write, <= 2A
simultaneous/retained control connections H <= A
```

The control bound uses R53's one connection per launched adapter, no inherited
writer in its solver child, fresh private listener identity and no unrelated
clients. No hostile-connection availability claim follows. Keep duplicate/
malformed-record detection and the final audit seal: a capacity count does not
authenticate a record. The count must be derived, never imposed as an arbitrary
cap whose exhaustion is relabeled physical resource failure.

One F waiting for Done does not imply at most J completed files or responses.
Each client may finish many native jobs while that first F is held. Charging
all A attempts covers this backlog even when it includes later S records held
for FIFO order. Per-client association state still has only one pending ack.
The gate neither increases the number of original scheduling owners nor retries
one; it can change completion order and the winning prover. Preserve that scope.

## Concrete payload reservations

Let P_b be the maximum raw backend output-path byte length, P_c the maximum
canonical path length and L_d the wrapped request-line bound for domain d.
These values must be derived from selected source/configuration bytes, not an
observed successful run. R53 gives P_c=len(R)+24 and a wrapped-request increment
of `len(adapter_exec)+55+d` for its seven-byte control name and one-digit
domain/prover numbers. R54 supplies:

```
backend F wire <= P_b+d+29; allocated <= P_b+d+31
canonical F wire <= P_c+d+29
S wire <= d+3; allocated <= d+4
```

Require each `P_b+d+31 <= INT_MAX` and the separate canonical serializer guard.
The smaller ID width does not change exit/time observations. Across all five
domains, sum(N*d)=1,257, so conservative total payload/allocation allowances are:

```
backend S+F wire payload <= 459*P_b + 17,202
backend allocated S+F buffers <= 459*P_b + 18,579
canonical F wire payload <= 459*P_c + 14,568
retained 64-byte decision frames <= 29,376 bytes
65-byte control receivers for every adapter <= 29,835 bytes
canonical file payload <= 34,884 bytes
stored wrapped run lines <= sum_d N_d*L_d
```

They are sums over distinct owned records, so they also bound simultaneous live
payload. They do not include paths stored elsewhere, object headers, socket and
pipe buffers, parsed request argv, malformed-input evidence, filesystem metadata,
logging bytes, allocator overhead or raw stock-output files. In particular a
76-byte canonical file does not bound the quarantined raw file. The later
SPARK representation must charge those owners rather than advertise these
payload sums as a total-memory figure. Retain complete mapped history; the
459-slot layout can index `(domain, original ID)` by disjoint fixed slices and
keep a monotonic defect state without overwriting a prior relevant failure.

## Stock queue backing arithmetic

For initial capacity c>=1 and at most n enqueued elements, define Q(c,n) as c
doubled until it is at least n. It is a total computable function using checked
arithmetic. The stock queue doubles only when full (`queue.c:43–61`). Its pointer
and length stay within capacity, and a pop removes ownership. A moving realloc
may temporarily need both old and new backing; charge both.

The request queue starts at 100. Its removal pass creates one temporary queue
with the same capacity; it transfers at most the old entries and cannot need
growth. Repeated removals free that temporary backing; only one such pass is
active in the single-thread server. A callback can enqueue a response while
both request queues exist, so their storage must be composed, not maximized
as disjoint phases. Each client response queue starts at J and has at most 2N_d
elements including the separate current-write record; using 2N_d for the ring
alone is conservative.

At J=12, Q(100,459)=800 and the five response capacities are
384,384,192,24,12 (sum 996). With eight-byte native pointers, a conservative
old/new-backing allowance is

```
2 * 8 * (2*800 + 996) = 41,536 bytes.
```

This is ring backing storage only. It includes the temporary request ring and
permits all listed reallocations to overlap conservatively. General J uses
`2*8*(2*Q(100,A)+sum_d Q(J,2*N_d))`; J=12 is an explicit configuration example,
not a restriction on available CPUs. Each doubling, `pointer+len`, allocation
product and capacity conversion needs its native guard. Sufficient guards are
`2*Q <= UINT_MAX` and `8*Q <= SIZE_MAX`, plus the signed length guards above.
The selected values are far below those ceilings. During resize, the copied
source is `[old_p,old_cap)` and destination `[old_cap+old_p,2*old_cap)`, so the
two ranges do not overlap and lie in the new backing. This is distinct from
the receive buffer's earlier memcpy issue.

Do not assume canceled requests free all their storage: `handle_queue_remove`
frees only the request record, while client-disconnect removal with no callback
does not free the removed request. Total-created request/argv/string storage
must be charged even after their queue slots disappear. This note's ring bound
does not cover that retention or claim whole-server memory safety.

The pending parallel/cache/startup joins, L_d/P_b/P_c attachment, byte buffers,
native structures, log/history/control representation, startup output, complete
grammar and whole-rule checked accounting/source correspondence remain required.
The global two save-entering callbacks/three saves/e<=2 budget is unchanged;
no allowance is reset per channel or attempt. Oracle, tools/pins and admission
are unchanged. Selected project baseline is Astra / Extra High; live lead
settings and isolated token/cost telemetry are unavailable.
