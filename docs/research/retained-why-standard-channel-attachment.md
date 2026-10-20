# Standard-channel entry state and launcher attachment

2026-10-20 UTC, authorized research #119 / #153, Linux x86_64. Base
`eb4e10cc32caaae49994f3166f78fbd993307ddf`; selected GPT-6 Astra / Extra High,
not runtime-confirmed. This adds to the accepted
[conditional channel rule](retained-why-standard-channel-capacity.md) and its
[review](../reviews/review-standard-channel-capacity-20261020.md).

**At the five retained debugger-controlled cuts, both channels have P0=0 and
O0=q, their constructor's cached lseek result, under the named selected
source/native and ownership relation.** This follows from a separate channel
writer partition below, not from formatter queue freshness. The two channel
records remain rooted, distinct output records with their original buffers.
The actual q values and inherited descriptor service/ownership attachment remain
unknown. Thus actual offset guards and usable channel bounds remain null.

A controlled direct launcher can remove the unknown q prospectively by creating
live pipes before the OCaml constructors: q=-1. A source bound for all offered
bytes from construction then gives the decidable arithmetic guard
`X_pre + X_suffix <= 2^63`, separately for stdout and stderr. This is a proposed
environment/source interface, not an implemented launcher or completed
pre-admission rule. In particular, the current debugger's pre-cut signal
exclusion does not automatically hold for a future uncontrolled prefix.

The [packet](../evidence/retained-why-standard-channel-attachment-20261020/README.md)
binds retained inputs, new source slices, launcher bytes and five case joins.
No target, debugger, solver, proof runner or source fetch was executed.

## Separate channel prefix argument

The exact cases remain Put_Line/PID 17310, Put/17514, First_Or_Default/17631,
Is_Message/17704 and Input_Is_Valid/17869. The first four stop at the first
scheduling `Gnat_checks.iter`; the fifth stops inside the first preparation,
before the `inline_trivial` body. The imported
[path attachment](retained-why-path-initial-state.md) supplies fixed loaders,
typed aliases, native owners and the one-worker relation. The
[prefix recovery argument](retained-why-standard-prefix-observer.md) and
[standard writer partition](retained-why-standard-initial-state.md) supply
actual argv/configuration selection, persistent exit gates and absence of
pre-cut save-signal injection for these controlled observations.

We import their exclusions of *operations*, not the implication “fresh Format
queue, therefore empty channel.” Direct channel output can bypass Format.
The additional direct-channel owners are accounted for as follows.

| Channel owner | Selected pre-cut disposition |
| --- | --- |
| Standard Format output and Debug stderr wrapper | The accepted complete writer/control partition excludes any pre-cut dynamic standard operation, including failed prefixes and explicit standard Format flushes. Debug installs callbacks without invoking them. Private formatters retain different output owners. |
| `Gnat_checks.Logging.outc` | This is a real extra alias to Stdlib.stdout at initialization. `opt_logging` starts false, only `--logging` sets it, and that option is absent in all five argv records. Both `Logging.init` and the `Logging.log` caller test the resulting immutable `Gnat_config.logging`. Its private formatter, direct newline and flush therefore do not run. This flag is separate from `GNATWHY3LOG`, whose absent environment branch also has a private file destination. |
| OCaml `Arg.parse` printing | GNAT initializes with `Arg.parse`. Its Bad and Help arms use Printf stderr/stdout then exit. Successful printing exits; a failing print propagates out of this module initialization. Neither resumes initialization to reach a cut. Actual argv also selects no help/display route. Why's separate Getopt error printer is outside this parser route; its body likewise exits after printing. |
| Printexc fallback headers, raw prints and outer out-of-memory line | These are uncaught/fatal reporting owners. The imported control relation excludes restarting module initialization/registration after fatal reporting. Returning from the registered OCaml wrapper returns to the terminating native fatal handler, not the cut continuation. No handled exception printer silently invokes this top-level fallback. |
| `Session_itp.update_goal_node` raw backtrace | The active print at line 859 protects `get_proof_parent`. This reads an immutable field after `get_proofNode`, which converts its table Not_found to BadID. It cannot ordinarily select the Not_found exception pattern. The diagnostic occurrence argument identifies signal-origin injection as the remaining route; the accepted controlled prefix excludes that injection. The following `assert false` alone is not used to exclude possible earlier output. |
| Old-session merge raw backtrace | The active print in `add_registered_transformation` is in old-session merging, outside the fresh non-replay prefix. The apparent sites at lines 1679 and 1784 are comments. These source distinctions are already in the diagnostic inventory. |
| `Thread.create` reporters | Their stdout/stderr flushes, Printf headers and raw-backtrace calls run in the created-thread wrapper. The selected prefix has no additional OCaml worker or Thread.create client. Thread's preemption/blocking/channel hooks are separately classified native owners; they do not invoke that wrapper. |
| Other direct channel aliases and generic output APIs | The selected source/typed client relation restricts channels passed to file serializers, Buffer.output_buffer, Rc/pretty-print helpers and cleanup to their private opens. Generic CLI/config/IDE/browser/interpreter writers are outside the selected frontend and driver callbacks. Loader initializers register functions without invoking their report callbacks. Neither an arbitrary supplied out_channel nor a reflection-created alias is admitted by that relation. |
| Global and direct channel flushes | The selected `flush_all` entries are in terminal exit; persistent gates and prefix control exclude them here. Other standard flushes belong to the writers above. Even an empty standalone flush offers no bytes and leaves curr/offset unchanged; flush count is not a byte bound. Private-channel cleanup does not close or mutate either standard C record. |
| C stdio/raw-descriptor diagnostics and external server | These do not operate on OCaml channel curr/offset. An external description may receive other bytes without modifying these cached fields. The target uses the external socket; internal-server/interactive editor process creation is unselected. Child descriptor redirection is a different process owner. |

The finite extra source slices are in `source-witnesses.json`. The existing
fixed-loader/native effect and selected caller arguments are essential to the
last rows. A lexical search alone would not exclude indirect aliases, callbacks
or native mutations. No stronger binary-refinement theorem is claimed.

Stdlib's constructors call `open_descriptor_out 1` and `open_descriptor_out 2`.
The native constructor stores fd and the lseek result q, sets curr=buff,
end=buff+65536 and max=NULL, and the managed wrapper retains the C record.
The native Stdlib initializer stores those wrappers in separate global slots
at `camlStdlib+0x130` and `+0x138`; the existing formatter constructors also
capture their corresponding wrapper. These are logical rooted aliases under
the selected behavior relation, not observed process pointer values.

Suppose a first channel byte offer or record mutation preceded one of these
cuts. Its selected owner would be one of the rows above, contradicting the
owner's exclusion or separate destination. There is no suspended writer
reentering the cut through a returning pending client. Thus the two constructors'
empty debts survive: P0=0, F_pre=0 and O0=q. The zero-length pending prefix is
vacuously initialized/readable. Valid roots/lifetimes and the 65,536-byte
in-object buffer follow the same source/native allocation and ownership
premises; mapped addresses alone would not establish them. No new suffix
allocation charge is introduced for these existing 65,616-byte native records.

This does **not** prove that fd 1/2 is live or has a stable binding. A constructor
can store -1 after lseek failure even when its fd was invalid. A later private
open could then reuse that descriptor number. The private channel's distinct
C object would not mutate stdout's C fields, but its close could change the
service destination or validity of the retained stdout fd. This is why the
logical record result and descriptor attachment are separate.

## What the retained launcher and reads establish

The capture manifest is SHA-256
`4404c4192a4bbfe373196185b6f8a9d7eb0ac16e9e51319e04a9dc0672603d0e`.
Both exact launchers run GDB using
`stdout=subprocess.PIPE, stderr=subprocess.STDOUT, start_new_session=True`.
They pass `-nx -q -batch`, disable startup through a shell and supply no
inferior-tty redirection. Under ordinary Python process semantics, this selects
a shared output pipe for **GDB**. The retained target process records contain
argv, environment and initial thread count, but no fd/fdinfo/fstat inventory.
The recipe is not a measurement of the inferior's inherited descriptors, and
this packet does not establish that bridge by proving GDB's implementation.

The retained Stdlib native initializer identifies the channel global slots.
A once-run query over 5,918,792 rows in all retained `*memory-reads.jsonl`
members found no read containing a complete eight-byte slot in any case.
`coverage.json` retains the exact per-process addresses, row counts and empty
hit lists. The query did not attempt stitching partial reads at different
times; it is not a claim that no byte touching a slot exists. No standard
wrapper or C-record graph was reconstructed. Previously exported formatter
root-read absences concerned different slots and are not substituted here.

Accordingly `result.json` distinguishes `source_derived_P0=0` from null
`observed_P0`, keeps constructor q, observed O0 and raw root pointers null,
and leaves actual descriptor kind/liveness/alias/binding fields null. The
source result has the conditions above; the historical values are not silently
rewritten to zero/-1. Missing historical fd observations cannot be recovered
by inspecting a current process with the same numeric PID.

## Prospective source/configuration condition

The proposed launcher profile creates one or two pipe write endpoints before
the target runtime starts, installs live write descriptors at 1 and 2, closes
unneeded inherited copies and directly execs the selected target. Sharing one
pipe description is allowed. The endpoint identities/access flags can be
recorded at creation and immediately before exec; a diagnostic stopped-target
check can corroborate them. Neither blocking flags nor file kind alone proves
the lifetime invariant: selected target/native owners must preserve those
descriptor numbers and not close/rebind them or change their service profile.
This removes the invalid-fd/reuse counterexample. It does not require exclusive
writers to the pipe, or equality of OCaml cached offset and kernel position.

For this profile, ordinary pipe lseek semantics give q=-1. Require the named
standard-channel service interface for every valid readable positive-count
request: a returned success commits `1<=w<=n`, or an ordinary error/interruption
or raising path occurs before success commit, or the call does not return.
This is an explicit instantiation of the existing OS/runtime service boundary
for the chosen pipe environment, not a transfer of the private save-file
contract and not a proof of Linux write internals. If that service contract is
not supplied, a pipe label does not discharge it. An arbitrary inherited
terminal/socket/device is outside this proposed pipe profile.

Retaining/draining the read endpoint is useful for progress. The local buffer
safety theorem also permits blocking, EPIPE/termination, other ordinary errors
and nonreturn. Those outcomes do not prove delivery or total completion.
Zero successful writes remain excluded: the full-buffer Putch counterexample
would otherwise survive. Pipe kernel storage, other writers and reader storage
have separate service/resource owners from the two OCaml buffers.

Let X_pre bound all prospectively offered bytes through one standard channel
between its construction and the cut, and X_suffix bound the whole remaining
suffix. These are source-derived mathematical bounds; observations of a
completed execution are insufficient for admission. With no cached-offset
reset, apply the accepted debt induction starting at construction:

```text
F_pre + P0 <= X_pre
O0 = -1 + F_pre
O0 + P0 + X_suffix <= -1 + X_pre + X_suffix.
```

Hence checking `X_pre + X_suffix <= 2^63` in mathematical arithmetic suffices
for the original per-channel guard. This also bounds every prior committed
addition by a first-unsafe-add argument from construction; it does not assume
the prefix's arithmetic safety circularly. A source prefix with X_pre=0 gives
P0=0/O0=-1, without measuring a runtime object. The two guards are independent
even if fd 1/2 share a pipe. No byte budget or save-signal budget is reset at
the cut, in callbacks, or between channels.

For the current controlled prefixes that reach their named cuts, the new
source partition supplies X_pre=0. This is not a zero-output bound on prefixes
that fail and terminate before reaching a cut.
For a **universal pre-admission rule**, the remaining inputs are precise:

1. Adopt and source-bind the direct launcher/descriptor-lifetime profile. The
   current historical GDB recipe has not implemented this proposed launcher.
2. Supply a source/configuration-decidable prefix control guarantee or a bound
   that includes any pre-cut signal/save/diagnostic output, including failed
   or terminating paths that never reach the cut. The retained
   debugger's no-pre-cut-injection argument is not a production guarantee.
   Changing launch-time signal policy would be a separate implementation and
   semantics decision; this packet does not choose or implement it.
3. Attach source-derived suffix B/E and exception-string H bounds, with their
   accepted guards, to obtain X_stdout/X_stderr. These values remain absent.
4. Attach the named pipe service contract and preserve the existing typed,
   native, source-range, mutex/GC/lifetime and callback premises. Service
   internals and sufficient resources remain in the existing trusted boundary.

Once those providers exist, the environment identity/configuration checks and
integer guard are decidable before execution. A frozen-cut channel certificate
would be a valid *diagnostic attachment* for a particular process; it would not
replace steps 1–3 or complete #119's pre-admission predicate. The remaining
launcher/prefix work is an explicit implementation/evidence obligation, not
unknown kernel science and not a reason to prove every instruction of GDB.

Whole-suffix bounds remain at most two save-entering callbacks, three saves
and e<=2, shared globally. The result supplies neither cumulative syscall
attempts, complete exit/save/R/U capacity, native stack nor physical memory
sufficiency. Oracle, installed tools, source pins and admission are unchanged;
#119/#153 remain incomplete, production #88–#94 unstarted and PR #121
draft/unmerged. Independent review of this new composition remains separate.
