# Shared-server connection boundary for the fixed Why prefixes

2026-10-20 UTC, Linux x86_64; #119 / #153 research. The
[R56 combined startup](retained-combined-parallel-startup.md) can use the
[prospective proxy](retained-adapter-outcome-interface.md) with one shared J12
backend server while preserving its registration result. The interface is to
keep each **client-facing socket pathname, cwd and input role unchanged** and
replace only the successful peer behind that socket. This is a conditional
source/native argument, not a run of the candidate or a proxy implementation.
The [packet](../evidence/retained-shared-server-prefix-20261020/README.md)
retains the exact five endpoints, source slices and installed-code witnesses.

## Topology and configuration attachment

The historical R53 captures used five separate single-client servers. They
are not measurements of a shared server. The prospective arrangement is:

```
Why domain d -- original socket pathname d --> proxy listener d
             proxy backend connection d --> one shared why3server, J=12
```

There are five frontend listeners and five distinct backend connections, one
per fixed domain. One proxy may own the listeners; no new Why process or
Why-side connection is introduced. The backend uses the existing original
request IDs, keyed by domain/connection, under the previously reviewed
no-reconnect/no-retry-owner interface. The shared server is not launched with
`--single-client`. J=12 is server-global, not twelve slots per connection.
Its socket pathname, actual cwd and service/storage costs are separate
configuration operands; they are not substituted into Why's argv or environment.

The finite projection takes the R55 `cut-projection.json` and the parallel
entries of `input-role-projection.json`, already accepted by R56. In domain
order Put_Line / Put / First / Is_Message / Input, the client-facing pathname
lengths are 50/89/56/96/56 bytes, recorded in `endpoints.json`. All five basenames are exactly
`server.sock` (11 bytes). The argument vectors remain precisely the recorded
J12 vectors plus the one logging flag; the quiet/timeless edits remain the
R56 files at the same spellings. TMPDIR, relative JSON, private directories,
session freshness, input bytes, native mappings and environment retain R56's
relations. Do not replace the five socket arguments with a common backend
pathname, even one with an equal length: this result does not prove arbitrary
relocation or changed pathname equality relations.

The prospective launcher creates the isolated directory layout and listeners
before starting clients, with no conflicting process or prior socket at those
names. This packet creates no listener, reuses no live capture server, removes
no historical path and modifies no installation. Literal historical path
spellings are a scoped design witness; attachment to a production workspace
or an allocation-equivalent relocation is still required.

## Successful connection and registration

At retained Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c`:

1. `gnat_checks.ml:380–417` creates/loads the fresh session, controller,
   drivers and source before `init`; `init` at 371–376 selects
   `connect_external` because stand-alone mode is false. Logging follows the
   connection. The fresh-session branch then returns the controller.
2. `prove_client.ml:110–113` checks disconnected state, clears the existing
   receive buffer, and calls `client_connect ~fail:true`. It sends no handshake,
   parallel-setting command or request, and does not read a reply. Buffer
   clear changes its position, not its backing allocation.
3. The Linux path of `client_connect` (20–54) obtains the current cwd, derives
   dirname/basename, creates one PF_UNIX/SOCK_STREAM socket, changes into the
   dirname, connects to the basename, restores cwd and stores `Some sock`.
   For identical path inputs and successful services it executes the same
   operations regardless of the peer's implementation. It never queries peer
   identity, credentials or address, and no received payload selects a branch.
4. OCaml `unix_socket` returns the fd as an immediate integer. `unix_connect`
   constructs the same native address, enters the blocking section, calls
   connect, leaves the section and returns unit on success. The retained
   installed functions confirm the relevant control sequence, including the
   compiled `connect_external` tail call and the successful Unix connection
   return. A different valid fd changes neither allocation shape nor logical
   constructors. The address payload is the unchanged 11-byte basename.
5. `gnat_main.ml:332–354` installs the signal handler and completes VC
   registration before the scheduling branch and main loop. R55's accepted
   registration/splitting argument is reused. Registration's trivial proofs
   are session entries, not solver launches. Controller creation loads drivers;
   it does not set a server parallel limit. The retained source census locates
   `set_session_max_tasks` callers in other tools/ITP service, not this GNAT
   entry. `connect_external` itself never sends the saved max-running value.

The stock server's accept routine (server-unix.c:144–161) allocates its client,
read/write buffers and poll entry; it sends no greeting. The proxy frontend
likewise sends no unsolicited bytes and keeps the connection open through
registration. Backend setup happens in proxy/server processes. These conditions
avoid introducing new protocol data or a failure into the preserved prefix.

The native witness is deliberately local: five installed function ranges are
byte-checked against the unchanged Why ELF. It is not a new whole-program
correspondence proof. Retain R56's relevant source/runtime/library relation,
successful native services, fixed inputs, no asynchronous handler/profiling or
external heap mutation and non-unwinding prefix. In particular the connect
blocking-section boundaries can service pending actions; peer replacement
does not remove that inherited premise or prove signal-mask enforcement.

## Capacity consequence and limits

Up to registration, peer replacement adds **zero Why-side managed allocation
requests, logical registrations or application protocol bytes**, relative to
the already charged R56 candidate. The existing socket construction, pathname
work and `Some sock` allocation remain charged there. This is a zero **delta**,
not zero connection cost. Induct over the unchanged Why operations, relating
the fd as an opaque immediate and preserving the controlled successful-service
conditions. R56's allocation/first-collection argument and root-map relation
then apply unchanged. Neither identical fd values, kernel states, elapsed
times, complete heaps nor future scheduling order is asserted.

Thus the per-process registration cut and 118-root/47-check map are compatible
with the shared-server design. The existing global two save-entering callbacks,
three saves and e<=2 per process are not renewed at the connection boundary.
After registration, backend contention may reorder starts/completions; the
accepted arbitrary-order state/first-fill argument must supply that part of
the composition. This transfer alone gives no later task, output or counter
bound and does not permit changes to losing-attempt/report semantics.

The proxy's five listeners, ten stream endpoints, backend socket pathname,
startup/control storage, native descriptor/kernel resources and shared server
owners are outside the Why prefix delta. Accounting for them belongs to their
own processes. The established trusted boundary supplies ordinary allocator/OS
behavior and sufficient physical stack/memory/disk; this exclusion adds no
aggregate RAM gate or allocator/kernel-internals proof requirement. Finite
representation, request-size, counter and caller conditions remain required.
The backend server's actual cwd and child environment also
require the selected launch/configuration relation for later solver execution;
preserved frontend pathnames do not establish that relation. Failed connection,
partial startup, termination, proxy refinement, cleanup/reaping, raw output
and the full capacity rule remain obligations. #88 owns eventual SPARK/Lean
implementation attachment once #119's prerequisite is justified. Oracle,
installed tools/pins and current admission remain unchanged; PR #121 stays
draft/unmerged and #119/#153 remain unfinished.
