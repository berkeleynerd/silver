# Stock server allocation owners

2026-10-20 UTC, R57 research for #119 / #153, Linux x86_64.

For the proposed **one shared external J12 server with five fixed backend
connections**, the remaining fixed stock control records, client records,
list backing and poll array require **1,016 bytes** of requested object storage.
A started run additionally requests a 24-byte process record and a C+12-byte
raw output pathname, where C is the actual backend getcwd string length.
The task ID pointer transfers from the parsed request; it is not copied.
The write path likewise queues/transfers the existing S/F buffer rather than
allocating another copy. These facts close the direct C allocation families
left outside the accepted [R56 request storage](retained-server-request-storage.md)
and [R55 protocol storage](retained-adapter-protocol-storage.md) terms.

The [packet](../evidence/retained-server-owned-storage-20261020/README.md)
pins source/caller inventories, static installed ELF operand witnesses and a
computable direct-allocation formula. Its scope is object storage under the
fixed-owner, intact-stream, valid-container and ordinary-service/source-native
interfaces. It does not bound libc's internal allocation capacities, allocator
retention, raw output contents or the complete q. No target, solver, proof run
or successful predecessor checker was replayed. No production capability,
configuration, Oracle, tool pin or admission rule changes. The global two
save-entering callbacks / three saves / e<=2 budget remains unchanged.

## Topology and entry ownership

The actual R53 evidence contains **five distinct historical server processes**,
with distinct recorded PIDs and client socket path arguments. Each recorded
server argv is `why3server --socket server.sock --single-client -j 12`.
These are per-case captures, not evidence that five servers ran simultaneously
or that a shared-server startup was captured. The projection reads the five
retained server/process JSON members directly and exports their exact values.

The prospective R53 proxy design instead uses one shared server and one backend
connection per fixed Why3 domain (`retained-adapter-outcome-interface.md:42–49,
67–81,107–111`). The R55 equation `Q(100,459)` plus five response rings already
assumes that shared request queue. The parent explicitly retains that design;
this packet does not replace it with five servers. For general composition it
exports a server-to-domain partition and evaluates the shared partition and
the five historical singleton partitions separately.

The shared-owner interface requires exactly one fresh backend connection per
domain, no reconnect/replacement under that run, no unrelated listener clients,
and no additional run/interrupt/control producers. The five per-domain N_d are
192,159,96,9,3; total A=459 and sum N_d*d_d=1,257. Reuse R55's fresh scheduling
and ID proof; this packet creates no new attempt cap. A closed or interrupted
owner does not acquire another entry allowance. The source's `--single-client`
option means *exit when the last accepted client disconnects*
(`server-unix.c:609–611`); it does not restrict the number accepted to one.
Successful shared service must maintain its connection-lifetime interface.

Changing the backend from each captured single-client endpoint to the shared
endpoint still needs the parent's **Why successful-prefix connection-boundary
transfer**. R56's startup theorem preserves the exact captured path roles plus
quiet/timeless/logging edits; this server-owner accounting does not enlarge
that theorem. Proxy interception, ownership and intact backend stream
refinement also remain separate. The server allocation formulas are conditional
on those explicit interfaces, not inferred from the five historical PIDs.

J stays 12 in this selected route. `options.c` initializes it from `-j 12`.
The retained 535-file ML/MLI inventory shows that the only `parallel;...` sender
is `Prove_client.set_max_running_provers`, called through
`Controller_itp.set_session_max_tasks`. Its actual application callers are the
interactive server, why3bench and why3replay; selected gnatwhy3 has none.
`Gnat_checks.init:370–376` uses `connect_external`, whose body sends no parallel
line (`prove_client:109–114`). Thus this selected frontend contributes zero
parallel-control offers. R53's generic promise to forward such a line is not
evidence that one is emitted here. An additional control producer would need
its own count/value and allocation terms before using these fixed J formulas.
Server logging is off in the actual server argv; Why's `--logging` does not
turn on the C server's distinct `--logging` flag or its FILE allocation.

## Direct allocation coverage and native sizes

`source-inventory.json` classifies every one of the 28 malloc/realloc/strdup/
getcwd/fopen call sites in the nine selected C translation units and records
their relevant constructor/caller sites. All those full C sources and headers
are pinned. The ELF file-symbol inventory also contains `server-win.c`, whose
body is excluded by `_WIN32` on this selected Linux binary; separate cpulimit
programs are not server allocation roots. Source semantics and caller
reachability are the reviewed argument, not claims made by a regex scan.

The installed binary is the retained 96,904-byte why3server, SHA-256
`143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80`.
Static objdump bodies are joined instruction-by-instruction to ELF load bytes;
no inferior was executed. Native malloc operands establish:

| Object | Requested bytes | Native operand address |
| --- | ---: | --- |
| t_list | 24 | 0x2996 |
| t_queue | 24 | 0x2d24 |
| t_readbuf | 24 | 0x2f04 |
| t_writebuf | 32 | 0x37b0 |
| t_client | 24 | 0x3ca0 |
| t_proc | 24 | 0x48c5 |

The list key and pointer strides are four/eight bytes at 0x29b0/0x29c1;
pollfd's eight-byte stride is at 0x4064. The output-path addition of 12 is at
0x3c04. These are the selected compiled operands, not layouts guessed using
host ctypes. The already accepted 56-byte request record and eight-byte exec
argv element remain imported from R56 and are not independently revalidated.

For a server s with c_s accepted clients, total N_s run owners and J=12,
`server_init_listening:263–299` initializes two lists with capacity J, the poll
array with J+2 entries, one request queue, and the self-pipe/listener descriptors.
`server_accept_client:144–161` allocates one client, readbuf, writebuf and
response queue per accepted connection. There are at most c_s+2 poll entries,
including tombstones before cleaning, because at most c_s clients are accepted
in total. c_s<=5<=J. Process-list occupancy is at most min(J,N_s), because both
immediate dispatch and the scheduling loop test occupancy < J before starting
one run (`568–573,630–635`). Reaping removes and frees one process owner; its
brief removed-but-not-yet-freed record cannot overlap a new dispatch in the
single-thread event loop. No list or poll-array resize is reachable. This also
keeps the poll loop's current-entry pointer stable during accept.

Each list uses a 24-byte record plus 4J+8J backing. The poll array uses 8(J+2).
One temporary request queue can exist during removal, in addition to the
persistent request queue. `remove_from_queue:174–190` does not recurse; its
callback only creates a response, and the temporary queue is freed before
return. Charge two request queue records per server. Thus:

```
server fixed controls/backing = 2*24 + 2*(4+8)*J + 8*(J+2) + 2*24
                             = 496 at J=12
client controls = 24 + 24 + 32 + 24 = 104
shared fixed new controls = 496 + 5*104 = 1,016
```

Request/response **ring backing** is not in those record sizes. Reuse the R55
old/new-reallocation allowance, replacing its shared request-capacity term by
the actual partition sum:

```
16 * (2*sum_s Q(100,N_s) + sum_d Q(12,2*N_d)).
```

The five response capacities remain 384,384,192,24,12. For one shared server the
request capacity is 800, giving 41,536 bytes. Singleton capacities are
200,200,100,100,100, giving 38,336 bytes. The latter has five sets of fixed
server controls, giving 3,000 bytes with the same five clients. These are
alternative topology instantiations, not additive allowances or a choice to
serialize solvers. The different ELF/libc/stack/kernel and child-owner terms
must also follow the topology.

## Process, pathname, response and cancellation ownership

`run_request:513–534` returns without creating a child if its client is absent;
otherwise it opens one raw output file, creates one process, allocates one
24-byte process record and transfers `r->id` and the pathname into it. The
request record/argv is then freed on normal dispatch; the transferred ID is
freed by `free_process`, not copied. The output template requests C_s+12 bytes
including NUL (`server-unix:132–142`): C_s actual getcwd bytes plus `/why3` and
six mkstemp characters. `free_process:46–53` frees the pathname, ID and process
record after reap. Direct cumulative construction requests are bounded by:

```
process records <= 24 * sum_s N_s = 11,016
raw output pathname allocations <= sum_s N_s*(C_s+12).
```

These cumulative bounds safely dominate live storage and are used in the
combined formula. With the stricter normal lifecycle, live records/pathnames
are at most min(J,N_s) per server, including the current creation/reap local.
The shared live process-record bound is 288 bytes; historical singleton bounds
sum to 1,152 bytes. The packet exports these tighter figures separately and
does not mix them into the conservative cumulative formula.

Queued cancellation frees only `r` after emitting F (`536–544`), leaving its
field/argv allocations retained. Disconnect removes queue slots with no
callback, retaining even that request record (`597–600`, `request:174–190`).
A missing-client dispatch can also leave its untransferred ID allocated.
R56's cumulative parser allocation term already charges all of these; none is
subtracted here. An interrupt's own ID/record is freed by `free_request`, but
its construction is likewise charged cumulatively. At most N_s interrupts and
c_s disconnects call `remove_from_queue`, so temporary queue construction count
is <=N_s+c_s; only one temporary queue per server is live at a time. Allocator
arena retention caused by this churn is separate from live object payload.

An intact run has at most one S and one F under the accepted R55 lifecycle.
`queue_write:303–310` passes its allocated msgbuf to `push_write_data`, which
makes it the current buffer or queues that same pointer. `have_written` frees
completed bytes and promotes a queued pointer; it never reallocates or copies
a second send-data buffer. The response queue may grow, already covered by the
ring term. Closing the client frees current/queued message buffers and all its
controls; the cumulative response bound does not rely on those frees.

S allocates d_d+4 and F allocates P_b+d_d+31. Here P_b=C_s+11, so the imported
response-buffer allocation term is
`sum_d N_d*(C_server(d)+11+2*d_d+35)`.
The two ID-width contributions matter. For one shared C this is
`459*C+23,628`. A pathname stored in its process record and copied into an F
buffer has two real owners, so both allocations are charged. No separate ID
copy or send-buffer copy is added. Partial writes keep the same owner; they
do not create another S/F entry. The existing stream-integrity and formatting
premises remain required.

## Computable direct-allocation envelope and residual terms

Using R56's L_d, m_d, M_d and receive growth majorant R(M), a conservative
shared-server envelope for the **direct C requested-object families** is:

```
B_direct = sum_d N_d*(L_d+8*m_d) + 57,714       [parsed runs/interrupts]
         + 8*sum_d N_d*(m_d+2)                [parent exec argv, once]
         + sum_d 2*R(M_d)                     [receive backing]
         + 41,536                            [ring backing]
         + 459*C + 23,628                     [S/F buffers]
         + 1,016                             [new controls/list/poll backing]
         + 459*(C+36)                         [process records/output paths].
```

For m_d=14 this simplifies to
`sum_d N_d*L_d + sum_d 2*R(M_d) + 918*C + 250,578`.
Each term is either cumulative construction or an overlapping-live majorant;
their sum bounds simultaneous requested object storage. It is not a statement
about total allocation churn or total physical memory. R56's parser and exec
argv terms appear exactly once. R55's response and ring terms are reused once;
its proxy decision/control/canonical-file terms are distinct owners outside
this stock formula.

The direct allocation-call inventory exposes two additional stock-owned
library results: one `getcwd(NULL,0)` and two `strdup(socketname)` calls per
server (`88–90,243,250–251`). Their retained string payloads are C_s+1 and
2*(S_s+1), respectively. The selected historical socket argument is
`server.sock`, S=11, giving 24 payload bytes for the two copies; their copies
are freed after binding. The historical server JSON does not observe getcwd.
Neither C+1 nor S+1 establishes the library's actual allocation request or
transient capacity. Leave explicit service allocation envelopes
`G_getcwd(C_s)` and `2*D_strdup(S_s)` to include returned capacity and call
internals, rather than adding those known payloads a second time. No selected
libc source proof of these envelopes is claimed here.

`B_direct` excludes allocator metadata, rounding, fragmentation and retained
arenas; ELF/shared-library/loader/runtime mappings; physical stack/signal-stack
space; kernel socket/listener/self-pipe/descriptor and filesystem storage; and
physical child/fork/COW/exec/solver/adapter memory. These scope exclusions,
including the physical-owner names exported by the projection, do not create
new proof gates. The [capacity design contract](retained-tool-capacity.md#comparison-and-next-derivation)
supplies ordinary allocator/OS behavior and sufficient physical stack, memory
and disk through the existing trusted resource boundary. It requires neither
an aggregate RAM admission gate nor a proof of allocator internals; ordinary
physical exhaustion remains at that boundary.

Required closure still includes the actual relevant source/configuration and
source/native correspondence, finite indices and representations, request-size
arithmetic, correctness-relevant counters, finite stack/index assumptions and
correct callers. The getcwd/strdup request-capacity and arithmetic terms above
remain useful source obligations within that scope. Meaningful raw-output,
proxy/control/canonical/log/history and Why-side behavior and representations
also remain in the accounting: one new raw pathname per run bounds file count,
not file contents. The adapter/proxy argument and shared-endpoint prefix
transfer remain separate requirements of the composed result. None of these
correctness or source-correspondence requirements is waived by the physical
resource boundary.

Sufficient native arithmetic guards for the new source uses include
`1<=J`, `2*J<=INT_MAX`, `J+2<=INT_MAX`, `c_s<=J`, `12*J<=SIZE_MAX`,
`8*(J+2)<=SIZE_MAX`, `C_s+12<=SIZE_MAX`, `S_s+1<=SIZE_MAX`, and the imported
`C_s+11+d_d+31<=INT_MAX` response guard. They bound list/poll indexes and
occupancy increments as well as object-size arithmetic. Ring guards remain
`2*Q<=UINT_MAX` and `8*Q<=SIZE_MAX`; receive/parser/exec guards remain those
of R56. New formula sums/products are computed in mathematical integers and
must be checked against the capacity-rule representation before conversion.
The unchecked malloc results in stock source, its receive memcpy overlap
bridge, ordinary wait/FD/PID semantics and source/native correspondence remain
explicit premises; byte bounds alone do not repair them or complete q.
