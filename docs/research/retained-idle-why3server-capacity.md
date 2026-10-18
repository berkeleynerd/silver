# Idle Why3 server startup representation

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This closes the explicit C container sizes and integer operations for an idle
`why3server` started by the null-program producer. It is conditional on the
producer's zero-client result and selected launch configuration. It does not
establish whole producer capacity. Libc/kernel allocation and functioning
services use the existing [trusted boundary](../trusted-boundary.md#trusted-computing-base).

The [source bundle](../evidence/retained-idle-why3server-capacity-20261018/README.md)
retains Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c` and the selected
Linux C interface declarations. The existing relevant-behavior premise for
that Why3 source still applies; these are not historical binary build inputs.
The server is a C executable (`Makefile.in:838–852`), so merely starting it
does not start the Why3 OCaml runtime or a solver.

## Entry conditions and integer operations

Let `J` be the positive worker count, `S` the full socket-path byte length,
`B` its basename byte length, and `C` the current-directory byte length.
The selected ABI has signed 32-bit `int`, unsigned 32-bit `unsigned int`,
64-bit `long`/`size_t`/pointers, 16-bit `short`, and ordinary System V record
layout. Successful allocation, filesystem operations and system calls remain
the ordinary execution assumptions. Caller-side socket selection, environment,
CPU-count acquisition and GNATprove storage are separate transfers.

The caller supplies a positive decimal `-j` argument, a socket name, and no
`--logging`; no client connects, including for readiness checking. On the
selected null path there is no gnatwhy3 client and no solver child. The worker
count is a tool-configuration input, not a property of source length.

`parse_options` assigns `strtol`'s result to `int` and tests positivity
(`src/server/options.c:23–86`). It does not comprehensively reject `ERANGE`
or out-of-range narrowing itself, so require

```text
1 <= J <= floor(INT_MAX / 2) = 1,073,741,823.
```

This guarantees exact `long`-to-`int` conversion, representable `J+2`, and
representable signed `2*J` in the `listen` backlog argument. Multiplication
by `sizeof` for backing arrays is in 64-bit `size_t`; the largest request
`8*(J+2)` is then at most 8,589,934,600, below `PTRDIFF_MAX`. This is an
individual representation condition, not a total-memory allowance or a
recommendation to configure that many workers.

`sockaddr_un` has a two-byte family and 108 path bytes. Its size is 110;
`unix_path_max()` therefore returns 108. Require `B+1 <=108`, `S+1` and
`C+1` representable in `size_t`/individual-object space, with no embedded
NUL. The server temporarily changes to the socket's directory, so the full
socket name is not copied into `sun_path`
(`src/server/server-unix.c:224–300`). The producer supplies the narrower
basename bound; this component preserves the actual platform limit.

## Explicit allocations and layouts

`main` parses options and calls `server_init_listening`
(`server-unix.c:638–646`). Initialization creates the following objects.
The sizes follow field order and the selected ABI, with complete declarations
retained; they are not results of compiling a layout probe.

| Object | Initial state and request bytes |
| --- | --- |
| Request queue header | One pointer and three unsigned ints: 24 |
| Request queue backing | Capacity 100 pointers: 800 |
| Client-list header | Two pointers and two ints: 24 |
| Client keys / data | `4*J` / `8*J` |
| Process-list header | Same declaration: 24 |
| Process keys / data | `4*J` / `8*J` |
| Poll array | `J+2` records, each one int and two shorts: `8*(J+2)` |

`init_request_queue` selects 100 (`request.c:170–172`); `init_queue` sets
pointer/length zero (`queue.c:19–27`, `queue.h:18–25`). `init_list` sets
length zero and capacity `J` (`arraylist.c:20–28`, `arraylist.h:19–24`),
once for clients and once through `init_process_list` (`proc.c:32–34`).
There are exactly **nine direct malloc calls** in this selected startup:
two for the queue, three per list, and one for polling. Their raw requested
byte sum is `888+32*J`; this sum is accounting, not an admission gate. The
largest of these individual requests is `max(800, 8*(J+2))`.

The two `strdup(socketname)` calls each require `S+1` result bytes; both
copies are freed after binding. `current_dir = getcwd(NULL,0)` retains one
directory string of `C+1` result bytes for the process lifetime. The libc
allocator's rounding, `getcwd`'s internal buffers and pathname helpers remain
within that existing external-interface/resource premise. This packet bounds
the server's arguments and owned representations; it adds no libc audit
requirement. Logging is false,
so `init_logging` performs no `fopen` and normal startup emits no log messages
(`logging.c:20–24`).

The fixed local structures include the 110-byte socket address and 152-byte
`sigaction` records (handler pointer, 128-byte mask, int flags and restorer
pointer). These procedures have no recursive call chain. Compiler-generated
frame layout and C-library call frames use the existing sufficient-stack
premise; summing declared locals would not establish a whole-stack byte bound.
Startup temporarily holds one
directory descriptor and retains one socket plus the two self-pipe ends;
signal setup requests no server-owned dynamic buffer.

## Persistence without clients

The listening socket and child pipe each call `add_to_poll_list` once
(`server-unix.c:199–221,295–299`). Starting from zero, `poll_num` reaches
two while `poll_len=J+2>=3`; the doubling/realloc branch at `:92–100` is
never taken. No client is accepted, so client/read/write-buffer constructors
and `list_append` are unreachable. The request queue and process list remain
empty; `schedule_new_jobs` immediately stops (`:630–636`), with no process
construction or temporary output file. Queue/list growth is unreachable.

The idle main loop cleans at most two poll entries, and calls `poll` with
count two (`:647–665`). Conversion to unsigned-long `nfds_t` is exact, and
`poll` returns either an error or a count at most two. The self-pipe read,
if reached, requests one byte; its `ssize_t` result is in `[-1,1]` and fits
the local int. Retry loops for interruption do not add server-owned objects.
Without external client/child activity there are no accumulating events or
growing counters. Ordinary shutdown traverses empty client/process lists,
closes/unlinks fixed resources and exits; memory is reclaimed with the
process (`:72–84,167–183`, `proc.c:58–62`, `logging.c:39–45`).

This specialization excludes unexpected external connections, explicit debug
logging and an actual solver workload. Those would require the existing
request, buffer-growth and process paths to be bounded. No compiler, server,
solver or proof command was run for this source derivation.
