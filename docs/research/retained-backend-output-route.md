# Backend-file output on the pipe/canonical route

2026-10-23 UTC, #119 / #153; author base
`92ce3f950eff85bf8d4dc4642ec04e0a31da5d35`. This supplies a source-attached
**design interface**, not an implemented adapter or a bound for the old
stock-solver full-file route. The
[packet](../evidence/retained-backend-output-route-20261023/README.md)
reuses accepted launch/protocol evidence and adds a focused server-writer and
default GNAT terminal-output analysis. No target or predecessor checker runs.

## Export and what must refine it

Let A be the byte length of the actual adapter executable argument, and E the
largest exception-name payload in its selected terminal exception family
(excluding the terminating NUL). For the output policy and lifecycle below,

```
q_backend(A,E) = max(2*A + 72, A + E + 1296).
```

The two terms are alternative server-exec-return and entered-adapter terminal
branches, not simultaneous writers. The **separate** pre-redirection
process-group failure contributes at most A+87 bytes to the inherited server
stdout stream; it contributes zero to the newly created backend file. On the
ordinary successful adapter path the backend file remains empty: the decision
goes over the control channel and the proxy creates the canonical file.

A is a configuration operand, like the already symbolic canonical-directory
length R. E is computable from the finite exception family of the chosen owned
source/import contract. Neither needs a fabricated numeric value before an
implementation exists. The ordinary standard GNAT exceptions have maximum
name payload16. The proposed no-user/custom-exception and direct-errno-import
policy can therefore specialize the formula to
`max(2*A+72,A+1312)` **only when the standard-only exceptional-origin closure
is established**. Absence of user exception declarations alone is insufficient:
library-defined exceptions and Assertion_Error exist in general. This packet
exports E symbolically rather than silently assuming that stronger closure.

There are two different obligations:

* The source theorem here bounds the named stock-server and default GNAT
  writers, classifies descriptor destinations, and specifies a complete
  prospective writer policy. Its finite output formula is not an assumption
  that all accepted programs fit or prove.
* The future Silver-owned SPARK adapter must refine that policy, its descriptor
  transitions, explicit failure records and source/callee closure, with all
  Bronze/Silver and source-correspondence obligations. Its generated binder
  and selected runtime binding must supply the stated default modes and
  finalizer closure. There is currently no production adapter or such proof.

The selected relevant-runtime relation remains the existing
[trusted external behavior boundary](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary):
valid fixed ELF, stable dependencies, noninterposed bindings, C locale,
sufficient physical resources, and faithful OS/runtime services on valid
requests. Successful configured load/start/ordinary termination and the named
return/errno primitives do not invent application diagnostics or callbacks.
This is a scoped lifecycle/service behavior, not a historical binary-attestation
claim or a new premise about task capacity. Application-configurable hooks and
known output routines are accounted for below. Arbitrary loader instrumentation,
replacement libraries, corrupt native state or failing physical infrastructure
are not silently covered by a claim of universal native silence. Their actual
failure outcomes still prevent confirmation where required; they are not
relabelled as success or charged to Why's escaping-save budget.

## Stock-server writer closure and inherited buffers

The selected source is Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, in the
accepted helper archive. The packet inventories all output/exit/hook sites in
the nine selected Unix server C units. `cpulimit-*` and `server-win.c` belong to
other executable/platform routes and are not counted as selected server code.
The fixed valid server argv has positive J, a socket, no extra arguments and
**server logging disabled**. This is distinct from Why3's enabled
`--logging`/`.why3log` configuration, which the result does not change.

| Source family | Destination and reason it cannot add inherited raw-file output |
| --- | --- |
| `options.c:parse_options` | Its printf/getopt diagnostics all terminate before `server_init_listening` or any fork. The selected valid argv reaches none. |
| `logging.c` | `log_msg`, fopen, flush and close are all guarded by the false server logging flag. `logging_shutdown` performs no output in this branch and exits. |
| `request.c:print_request` | Contains diagnostic printf calls, but has no call site in the selected units; only its declaration and definition occur. Request parsing does not invoke it. |
| Server request/reply traffic | Uses read/write buffers and `write(client->fd,...)` to connected sockets. `snprintf` constructs S/F bytes in those buffers; it is not stdio output. |
| Self-pipe/signal handling | The SIGCHLD handler writes one byte to its private pipe. The shutdown handlers invoke the output-free logging-disabled shutdown path. They do not register stdio-producing exit hooks. |
| Server child diagnostics | The process-group failure is before redirection; the selected non-stdin route excludes the stdin-open perror branch. Only exec-return fprintf follows redirection. These children never return to the parent loop. |

All selected initial stdio handles are open, so internal pipe/socket/file
descriptors do not alias fd0/1/2. The private files/channels retain the accepted
ordinary descriptor and stream semantics. Starting from ordinary empty C
streams at successful program entry, the source's parent prefix performs no
stdout/stderr write before **any** fork. Failed initialization terminates
before creating a solver child. Child diagnostics occur in a fork copy and
cannot populate the parent's buffers before a later fork. Therefore the child
inherits **zero pending parent stdout/stderr payload**, by induction over the
server loop; this is not an assumed empty buffer at an arbitrary fork.

No selected source registers `atexit`, `on_exit`, constructors, destructors or
custom stdio objects. Ordinary dependency startup/finalization remains within
the stated noninterposed runtime relation. In particular this argument does
not import Why's OCaml at-exit hooks into the standalone C server. `exit(1)`
can flush the child's own bounded diagnostic, but adds no inherited source
payload or application exit-hook text. Parent-side assertions/errors cannot
write into a child's separately redirected fd1/2; an aborting parent cannot
subsequently fork with its diagnostic in a buffer.

Reuse the exact libc/C-locale error-string result from
[direct launch diagnostics](retained-adapter-launch-output.md): strerror
payload<=49. The exec-return format contributes23 fixed bytes and two copies
of the command, hence2*A+72. The process-group branch contributes38 fixed
bytes, command once and error once, henceA+87. They are mutually exclusive.
The source's unchecked mkstemp/dup2 calls are not repaired by this arithmetic:
successful file creation/redirection is a routing premise. A failed native
operation retains its actual outcome/destination and cannot be treated as a
successful raw-file or canonical publication. This is the existing native
failure boundary, not a new ignored-error path.

## Exact prospective output and descriptor policy

Use the existing [outcome protocol](retained-adapter-outcome-interface.md):
one solver process, merged stdout/stderr pipe, a finite byte recognizer, one
attempt-bound control decision, the stock adapter-completion gate, and a
separate fully written/closed canonical file. **No optional raw stream logger
is selected.** This is a design choice for the optional feature, not removal
of existing solver diagnostics: all solver bytes still pass through the
recognizer and contribute their specified result/evidence facts. Enabling a
raw tee later would introduce a separate unbounded-by-this-theorem writer,
whether it targets the backend file or another disk file. A bounded pipe
buffer does not bound that logger's cumulative file payload.

The owned adapter performs no stdout/stderr output, including banners,
argument-error text, child-launch errors, cleanup notices or progress logs.
Those errors are explicit finite control/error records, with native operation,
errno/status and completion facts, as the accepted protocol requires. Failure
to establish or finish the control channel remains an unconfirmed failed
attempt; printing a replacement success, suppressing an independently observed
defect, or inferring resource attribution from a missing record is forbidden.
No canonical row is emitted on the adapter's inherited stdout/stderr. The
proxy alone owns canonical publication, so76 is not a raw-file bound.

The complete descriptor refinement must include the following otherwise
easy-to-miss source fact: `create_process` duplicates outfile onto1 and2 but
does **not close the original outfile descriptor before exec**. The adapter
therefore inherits an additional raw-file alias, and possibly unrelated
server descriptors. Replacing only fd1 and fd2 in the solver child is not
sufficient to establish that it has no backend-file writer.

The future implementation must prove this transition:

1. The adapter receives the original server stdout/stderr handles. Its own
   output-free prefix creates the control/error channels and solver pipe.
   Native descriptor errors are checked and recorded; no failure is treated
   as a completed redirect or close.
2. In the one pre-exec solver child, the prefix consists only of proved,
   allocation-free descriptor/error-record operations using the specified
   checked native services. It performs no Ada finalization, raises no Ada
   exception, calls no stdio diagnostic and dispatches no custom callback.
   On failure, report the bounded launch error over the error pipe and use
   immediate native `_exit`, which does not flush inherited stdio or invoke
   finalizers. A failed error write still exits and leaves missing evidence;
   it does not fall back to backend text.
3. Before solver exec, both fd1/fd2 designate the same solver-pipe write end.
   Every inherited descriptor that aliases the raw file, including the
   original outfile descriptor, is closed. Control/listener and other
   unneeded server descriptors are also closed/CLOEXEC as the outcome
   protocol specifies. This requires an actual descriptor-inventory/closure
   implementation; guessing the original outfile's numeric fd is insufficient.
4. Solver exec occurs only after this transition. Its ordinary output, error
   output and descendant-inherited stdout/stderr reach the pipe. The adapter
   never copies those bytes into its own fd1/2. Child exec failure follows the
   bounded error-channel/immediate-exit branch. Cancellation/wait/EOF/closure
   retain the existing protocol and process-group semantics.

This is a precise implementation/refinement obligation, not a claim that
the future code already satisfies it. In particular it prevents **two** Ada
last-chance reports, one from a pre-redirect fork child and one from its
parent, from invalidating the single-report formula. If the child is allowed
to run the Ada terminal handler while still holding the backend fd, the
displayed max is not established; an additional writer must be counted.

## Default GNAT terminal report, with finalizers exposed

The packet retains complete installed GNAT16.1 source members and strict
excerpts for `Ada.Exceptions.Last_Chance_Handler`, exception message/name/
traceback routines, trace-mode defaults and the finalization soft links. These
are source inputs to the existing GNAT/runtime behavior relation. They do not
claim the future adapter has already been linked or that its binder was read.

Select the ordinary single-environment-task runtime, default RM_Convention
exception reporting, the default last-chance handler, no trace/decorator/
raise/unhandled hooks, and no user/task-termination handlers. The owned
implementation and its chosen imports must preserve those defaults. Do not
enable Every_Raise or symbolic-trace binder instrumentation and still reuse
this bound: those routes can print caught exceptions or decorated strings.
The existing compiler project does not select those binder modes; this design
does not change linking or replace the runtime to obtain silence.

The hook boundaries are explicit:

* `a-exextr.adb:Notify_Exception` does no trace printing in RM_Convention;
  the global actions start null and the raise-hook switch starts false. The
  proposed source/import policy registers none. The unhandled notification's
  task hook is the ordinary no-op non-tasking hook.
* `a-elchha.adb` calls `System.Standard_Library.Adafinal` **before** printing.
  `s-stalib.adb` sets Runtime_Finalized before invoking its soft link, so that
  finalization entry is once-only. `s-soflin.adb:Adafinal_NT` calls the task
  hook and the binder's `Finalize_Library_Objects` hook, if any. The bound does
  not absorb arbitrary output from either hook.
* The selected owned design uses no Ada.Text_IO/stream output, controlled
  finalizers, Ada tasks, registered exit handlers or foreign callback/unwind
  entry. Its actual source/import and binder closure must establish that
  finalizers only release owned resources and emit no text. Expected cleanup
  failures are explicit control outcomes, not calls to diagnostic printers.
  This is a checkable source/callee condition, not an assumed capacity value
  for an unidentified finalizer.
* `To_Stderr` emits at most one character per input byte and skips CR. Its
  imported `put_char_stderr` has the ordinary character-output contract.
  The imported `__gnat_unhandled_terminate` terminates with its native failure
  status without an additional application diagnostic or application hook
  under the same selected runtime relation. Its failure status is not a
  solver result or resource-attribution label.

For a valid exception occurrence, Msg_Length<=200 (`s-parame.ads`,
`a-except.ads`, and the truncating `Set_Exception_Msg/Set_Exception_C_Msg`),
and Num_Tracebacks<=50. Let E bound `Name_Length-1` for every occurrence
reaching this handler. The handler deliberately uses **untailored** traceback
output after finalization. The following independent bounds count all branches:

| Component | Bytes at most |
| --- | ---: |
| Abort-of-environment-task branch, including two LF | 51 |
| No-traceback branch, including optional message | E+212 |
| Traceback heading, including argv0 or its absent-argv fallback and LF | A+49 |
| Basic exception information | E+231 |
| Untailored load-address/traceback information | 1,016 |

The last two are the source's conservative maximum formulas. Hex addresses
use at most18 bytes; each of the at most50 traceback slots is allowed19 bytes
including separation. The source's basic-info allowance covers the native
partition-ID decimal field. For the selected Linux integer/addr model these
are valid bounds, not measured diagnostics. Thus the full traceback branch
is at mostA+E+1296, which also dominates the other two branches for A,E>=0.
No complete diagnostic string is built by this handler: its zero-length
`Nobuf` makes append helpers stream to stderr. Its local name/address buffers
and caller/runtime representation guards remain required; the output bound
does not establish physical stack capacity or arbitrary internal recovery.

There is at most one diagnostic-emitting terminal sequence under this
valid-state/default-hook closure. An exception during Adafinal can replace the
original occurrence before its report begins; the once-only flag prevents
repeating its finalizers. This is not an unconditional single-entry claim
about Last_Chance_Handler. Ordinary caught errors use the
explicit control path and RM mode does not print them. The solver child
cannot add such a report because of the pre-exec policy above. The bound
therefore does not multiply by byte count, failures caught by the recognizer,
or retries inside a syscall. Output on terminal interruption or failed write
is bounded by the same attempted-character charge. It need not be a prefix:
To_Stderr ignores a character-write failure and may emit later characters.
Runtime/service failures outside the
stated valid-service relation retain their external outcomes; no successful
completion or arbitrary-failure recovery theorem is inferred.

## File extent and downstream consumers

Each accepted launched request creates a fresh raw temporary file with initial
extent zero. All classified writes are sequential stream writes through its
shared open-file description, with no seek/truncate/reopen writer in the
selected policy. Therefore file extent and cumulative payload per request are
at most q_backend. Check the actual configuration with

```
I = 2^31-1                             (selected GNAT Integer / C int maximum),
A >= 1, E >= 1,
q_backend(A,E) <= I                    (sufficient, deliberately nonminimal),
q_backend(A,E) <= 2^63-1               (selected signed off_t extent).
```

The first q guard implies A<=I, E+1<=I, E+231<=I and E+1247<=I, as well as
2*A+72<=I. Thus the imported Len_Arg result and `Arg : String(1..A)` fit;
Name_Length and its subtract-one payload fit; the local exception-name copy
and its `Name_Ptr=0` append perform at most `0+E`; and even the conservative
basic/combined-info maximum formulas fit. No aggregate diagnostic length is
actually added to Ptr on the selected streaming path: Nobuf has length zero,
so both Append_Info_String and Append_Info_Character emit without updating it.
The only nonempty append buffer here is the exact E-byte name copy, whose
computed Last is E. Message-copy lengths are at most200. Address scratch has
18 bytes and at most16 hexadecimal digits; its cursor stays in2..18 before
the `0x` stores. PID decimal recursion has at most10 levels for the selected
Natural domain, with digit arithmetic in0..9. The fixed traceback loop has at
most50 iterations. Nonnull exception identity, a nonempty valid name and
metadata within these stated domains are part of the ordinary typed-runtime
interface, not consequences of counting printed bytes.

These are explicit sufficient **configuration arithmetic guards**, stronger
than necessary for the streamed report; they are not byte quotas or Silver
membership rules. The accepted argv/native conversion and request-wrapping
guards remain required at their own source sites. The q expression and all-file
sums are mathematical accounting, not newly accumulated machine counters.
Actual small fixed A/E operands discharge these guards directly. No truncation
behavior or physical-memory gate is installed.

The [current count join](retained-current-protocol-join.md) gives current
launch-entry upper bounds153/126/66/6/3, total354, and preserves the older
conservative protocol bounds192/159/96/9/3, total459. Thus the raw-file payload
across all retained files is at most354*q under the stronger current launch
ownership theorem, and certainly459*q under the unchanged protocol envelope.
These are physical-file payload envelopes, not aggregate RAM admission gates;
metadata and filesystem allocation granularity remain separate service costs.
Queued cancellation creates no child/raw file. Cleanup can reduce retained
payload but is not required to justify the cumulative upper bound.

The stock server's S/F records carry the filename/status/time, never q bytes.
The raw filename still has backend-cwd length+11, independent of file payload.
The proxy does not expose this raw path as semantic solver output. Why's
file reader and canonical parser receive the separate at-most76-byte
canonical file. The64-byte decision frame and its audit-seal requirements
remain unchanged. Neither q nor459*q is fed into the canonical parser,
FileTags theorem, warning bound or Why's whole-file solver-input Buffer.

The inherited-stream setpgid diagnostic still needs its separate destination
owner: at most354*(A+87), or459*(A+87) conservatively, if that stream is retained
across the run. It cannot be hidden in the raw-file total. No assumption of
successful process-group creation, cancellation delivery or canonical
publication is inferred from the byte arithmetic.

## Completion boundary

The design exports q_backend(A,E), a closed default-terminal writer bound,
zero selected solver/raw-logger contribution, zero source-inherited stdio
payload, and explicit finalizer/descriptor/import conditions. The smallest
remaining production interface is an **Adapter_Backend_Emission** refinement
certificate: actual A and finite exception-family E; default runtime/binder
hook closure; output-free owned normal/error/finalization paths; the checked
pre-exec error path and complete backend-alias closure; and the reached native
representation guards. These are future #88 implementation/correspondence
obligations, not a demand for a loader-internals audit or new attestation.

No numeric A/E is selected here, and no completed production writer certificate
is claimed. The current stock full-file solver route retains its separate q
problem. There is no new circular trusted capacity premise, physical resource
gate, toolchain change, production start, admission change, failure
reclassification, or GitHub/shared-record write. One global Why e<=2, two
save-entering callbacks and three saves remain unchanged. Selected author:
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. Exact focused evidence and review freeze are recorded in the packet.
