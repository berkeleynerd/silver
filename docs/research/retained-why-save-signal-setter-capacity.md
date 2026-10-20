# Selected signal-save setter requests and caller stack

2026-10-20 UTC, #119 / #153, follow-on to Round 37. The three ignore setters
before a signal save have at most **six entries and 96 direct result-wrapper
bytes** across the existing global two-callback budget. Their own native caller
frames plus direct bridge high-water and normal pending-signal scanner fit
**4,936 bytes** per active setter phase. Including the already reviewed incoming
dispatch, excluding its separately counted handler, gives **5,720 bytes**.
Nested callbacks, runtime/service interiors, failure diagnostics and the later
save/exit phases remain separate terms. No complete handler/save-stack or
physical-sufficiency result follows from this component alone.

The [packet](../evidence/retained-why-save-signal-setter-capacity-20261020/README.md)
reads existing source archives and executable bytes. It imports the
[Round 37 dispatch/bridge result](retained-why-save-stack-helper-closure.md) and
[whole-post-cut callback budget](retained-why-save-attempt-growth.md), without
rerunning either. No target, capture, new disassembler or source fetch is needed.

## Actual arguments and entry count

`save_session_and_exit` calls `Sys.set_signal` on SIGINT, SIGHUP and SIGTERM
with `Signal_ignore`, inside one `Invalid_argument` catch. There is no retry
of an earlier setter. The exception handler is outside the protected expression
and proceeds to save; other exceptions escape. A suspended setter abandoned by
a nested exception is not silently restarted. Each of at most two selected
signal callbacks therefore enters at most three setters. Ordinary ending calls
save directly and adds no setter. This applies the one global callback allowance;
it is not a newly reset allowance at each save or exception.

The inherited allowance requires the established mask/ignore, no-reinstallation,
no-unmask and native-callback relation. This packet does not establish at most
two callbacks if that protocol fails, or use its own six-call result to prove
the protocol. Service failure can shorten a call sequence; broad failed-service
behavior remains outside the complete result.

The installed handler passes tagged integers -11, -7 and -21, representing
portable signals **-6, -4 and -11**, with immediate action **3** (Signal_ignore).
The executable's 28-entry POSIX signal table at relative address `0x9f2bc0`
maps their indices 5, 3 and 10 to native signals **2, 1 and 15**. All lie within
the installed NSIG=65 check. Thus conversion to C int, negation/indexing and
native handler-array indexing are represented; these particular arguments do
not take the unavailable-signal branch.

`Sys.set_signal`'s public interface declares the primitive as signal and
specifies discarding its result. Its installed wrapper directly selects
`caml_install_signal_handler`, then returns unit. The packet uses that actual
native wrapper and the retained sys.mli declaration; it does not claim to
retain a generated sys.ml implementation that is absent from the archive.

## Direct requests and caller-owned state

The C installer obtains the old OS action. An old default/ignore is an immediate
result; an old OCaml handler returns one single-field block, **16 bytes including
its header**. Charge that block at every entry, including an abandoned attempt:
`2*3*16=96`. Existing saved handler closures are referenced, not copied. The
accepted installed-handler-array relation supplies a valid slot when oldact=2.

Action 3 is immediate. Consequently the installer never enters its block-action
branch: no new NSIG-sized handler array, global root registration or handler
closure publication is selected by these ignores. POSIX sigaction's two fixed
local records reside inside the measured C frame; their interior is passed to
the existing libc/OS interface. No source-sized C buffer or growing container
is created by this caller. Pending signal processing occurs after setting the
action and can invoke the already budgeted callback; it is not assumed absent.

Allocation and ordinary error services can themselves raise/process pending
actions. The existing [raise-path qualification](retained-why-channel-exit-bound.md)
applies: an escaping raise abandons its caller, even if a pending callback ran
first. This component does not erase that callback, prove safe recovery from
physical allocator failure, or charge error strings as normal result wrappers.
Their allocation/stack owners remain explicit. The 96-byte result is therefore
normal caller-request accounting, not complete failure allocation.

## Measured caller frames and composition

All own frame sizes include their incoming return slot:

| Caller instance or imported component | Bytes |
| --- | ---: |
| Gnat_main handler while its setter trap is active | 48 |
| Sys.set_signal wrapper | 16 |
| caml_install_signal_handler | 208 |
| caml_set_signal_action | 352 |
| Normal pending-signal scanner, imported | 192 |
| caml_raise_if_exception prefix | 16 |
| Direct C bridge transient high-water, imported | 4,104 |
| Conservative sum | 4,936 |

The handler has 24 local bytes, an incoming return and a two-word trap. The
Sys wrapper has eight local bytes and its return. The C installer has 184 local
bytes, two pushed registers and its return; set_signal_action has 328 local
bytes, two pushed registers and its return. The exception-result wrapper has
one extra pushed word only on its raising branch; charging 16 covers both.
The bridge's 4 KiB probe is charged even though its later live area is smaller.
The three setters execute sequentially, so their counts multiply cumulative
requests, not this simultaneous stack sum. Summing mutually exclusive C action
and scanner phases is conservative.

The native installer inlines signal-number conversion. Its selected outgoing
calls are set_signal_action, the small result allocator, pending-signal scanning
and raise-if-exception. The fixed-argument unavailable-signal branch is excluded;
OS-error construction retains its explicit failure/service owner. The action
setter calls only sigemptyset/sigaction on this route. Failure/canary services
and deeper allocation/runtime frames are not hidden in the measured frame sum.
`selected-closure.json` lists edges and imports, and retained instruction bytes
bind the actual bodies and constants. These facts do not mechanically prove
source/native refinement or libc correctness.

Let D=784 be Round 37's incoming dispatch excluding its 32-byte active-save
handler. A setter-phase root consumes at most **D+4936=5720** caller bytes,
plus service interiors and any nested callback demand. The 48-byte handler in
this new sum replaces, rather than adds to, the 32-byte handler in Qs=816.
The setter trap is popped before save; the save still uses the reviewed Qs.
After save the native handler tail-transfers to exit; no setter frame survives
that phase. An aggregate may charge these alternatives separately or use a
safe maximum, but must retain suspended outer work and global callback counts.
It cannot substitute 5720 for the whole-handler result: save, exit, diagnostics
and nested callbacks have other owners.

Without the named fixed-argument/source/runtime/protocol relation, usable
bounds remain null. The focused author check passed five source excerpts,
six native bodies / 1,020 instruction bytes and the actual signal-table data in
0.359238 seconds. The checker does not replay previous evidence or run a target.
Independent review is pending. Live lead model/effort and individual telemetry
are unavailable; no setting, Oracle/tool/admission or CLI-memory change is claimed.
