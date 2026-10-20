# Stock request parsing and receive-buffer storage

2026-10-20 UTC, R56 research for #119 / #153, Linux x86_64.

The [protocol ownership bound](retained-adapter-protocol-storage.md) supplies
459 run offers and at most 459 interrupt offers for the five fixed clients.
This note turns the remaining request-line operands into explicit allocation
and buffer guards. It covers the stock server on an **intact validated request
stream**. It does not prove that the proposed proxy implements that stream,
bound malformed front-side input, or supply the final request filenames.
The [packet](../evidence/retained-server-request-storage-20261020/README.md)
retains exact source and installed instruction witnesses.

## Line ownership and parser allocation

Let a valid run line, including its terminating LF, have L bytes and m argument
fields after the executable. Require no NUL, LF or semicolon inside a field,
exact header `run` or `runstdin`, the represented original request ID, and the
selected zero timeout/memory fields. A `runstdin` request includes its input
filename among those m fields and requires m>=1. A successful full write is not
assumed: on an abandoned backend write the proxy must close that stream without
starting another line on its incomplete prefix. It must never retry an already
delivered run as a new owner. These are required stream/ownership conditions.

`handle_msg` calls `parse_request` once per LF-terminated line and passes a
length excluding LF (`server-unix.c:547–590`). The parser counts semicolons,
sets `numargs=semic-4`, and copies the header, ID, two limits, executable and m
argument fields (`request.c:33–138`). There are m+5 fields, m+4 semicolons and
one LF. `copy_up_to_semicolon` allocates field_length+1 bytes and advances to
the next field; the last field returns position zero only after its last copy.
Consequently the sum of all copied-string allocation requests is exactly

```
sum(field_length+1) = (L-1-(m+4))+(m+5) = L.
```

This sum includes the temporary header and numeric strings even though they
are freed during parsing. It does not rely on a later request being freed.
The installed parser requests 56 bytes for each request record and eight bytes
per argument-array element, as confirmed by the packet's static ELF witness.
Thus one run adds at most `L+56+8*m` requested bytes in m+7 allocation calls.
An interrupt has two fields and line length `11+d`, where d is the ID width;
its parser requests `11+d+56` bytes in three allocation calls.

Use the domain-specific R55 N_d and d_d. Let L_d bound every run line in that
domain and m_d bound its argument count across the selected provers/wrapping.
Summing **all created** requests gives

```
parsed-request allocation bytes <= sum_d N_d*(L_d+8*m_d) + 57,714
parsed-request allocation calls <= sum_d N_d*m_d + 4,590.
```

Here `sum N_d=459`, `sum N_d*d_d=1257`, and total interrupt line bytes are
`11*459+1257=6306`. Because this charges cumulative requests, it also bounds
their live payload even when queue cancellation/disconnection leaves storage
allocated. The existing source path frees only the request record on queued
cancellation; disconnection can discard its queue slot without freeing that
record. Do not subtract those allocations. A normal run transfers the ID
pointer to its process entry; the ID must not be counted as a new copy there.

`create_process` additionally allocates `8*(count+2)` bytes for exec argv,
where count=m or m-1 for stdin. At most one run entry reaches that call, so
`8*sum N_d*(m_d+2)` bounds the cumulative parent requests. Forked address spaces,
their copy-on-write pages and eventual exec stack are separate physical-memory
owners. This note does not claim that freeing the parent's argv frees the
child's copy. Output paths, process records, response queues and libc allocation
metadata remain distinct summands.

## Receive-buffer capacity and arithmetic

The stock receive buffer starts at 1024 bytes. Each read reserves and consumes
at most 1024; complete lines are immediately parsed and removed. Let M>=1 bound
the length including LF of every valid line on one backend connection. After
removing all complete lines, the remaining prefix has at most M-1 bytes. A
read therefore presents at most M+1023 bytes to `handle_msg`, even if it contains
several short complete lines. Abandoned final prefixes obey the same bound.

Define R(M) by starting c=1024 and repeatedly replacing c by `2*(c+1024)` until
c>=M+1023. This is a finite, computable natural-number function. These are the
exact capacities selected by `prepare_read` (`readbuf.c:34–39`); induction on
growth events shows that no selected buffer exceeds R(M). A moving realloc
needs at most old+new backing, conservatively `2*R(M)`. For a maximum M_d per
client, five separate receive buffers contribute at most `sum_d 2*R(M_d)`.
An implementation using a different number of backend connections must sum
over those actual owners instead.

The following sufficient checks keep the relevant native expressions in range:

```
M+1023 <= INT_MAX
2*(R(M)+1024) <= SIZE_MAX
0 <= m <= INT_MAX-2
8*(m+2) <= SIZE_MAX
```

They include the size_t→int assignment to `handle_msg.max`, its line indexes,
semicolon counter, `i-begin+1`, `cur++`, and the exec-argv `count+2` expression.
The second guard is deliberately conservative about a next resize that need
not occur. All arithmetic in the capacity rule must itself be checked before
conversion to the native types. For the selected 32-bit int / 64-bit size_t
ABI the first guard dominates the relevant loop arithmetic. The source proof
uses nonnegative valid lengths and intact fields; it does not justify invoking
the parser on arbitrary malformed concatenations.

The earlier [receive-copy bridge](retained-why-server-buffer-copy.md) is still
required: `have_taken` calls memcpy on ranges which may overlap. A size bound
does not repair that separate native-behavior premise. Allocation and ordinary
read services, valid containers, fixed client ownership and no additional
protocol roots remain explicit. Logging, startup, loader/solver output,
allocator overhead, stack and full q are not included in these sums.

This result does not use 116,162 as a filesystem path limit: that earlier value
bounds a qualified Why3 identifier path. L_d, m_d and M_d must come from the
actual command and temporary-filename construction. The Oracle, tools/pins,
admission and the global two-callback/three-save/e<=2 budget are unchanged.
No production adapter or launch configuration is adopted. Independent review
and integration are pending. Selected project baseline is Astra / Extra High;
live lead settings and isolated token/cost telemetry are unavailable.
