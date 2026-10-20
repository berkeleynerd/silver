# Direct server launch diagnostics

2026-10-20 UTC, Linux x86_64; bounded #119 / #153 research component.

The selected stock Why3 server child emits at most `A+87` bytes on its direct
process-group failure branch or `2*A+72` bytes on its direct exec-return failure
branch, where `A` is the byte length of the command path. These branches are
mutually exclusive. The first precedes output redirection; the second follows
it. Successful execution emits no direct child diagnostic from these branches.
This closes the direct diagnostic term under the exact libc and service
premises below. It does not bound the loader, adapter startup, arbitrary runtime
fatal diagnostics, or complete raw output `q`.

The [packet](../evidence/retained-adapter-launch-output-20261020/README.md)
retains source excerpts, exact native bytes, all error strings and a focused
checker. It reads the already selected libc and source archive; it does not
execute the target, compile a program, launch a solver or replay a proof.

## Exact inputs and premises

The source is `why3/src/server/server-unix.c` in the retained helper archive,
SHA-256 `2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749`.
The libc is `/usr/lib/x86_64-linux-gnu/libc.so.6`, 2,190,608 bytes, SHA-256
`85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7`.
The existing source/native correspondence premise remains necessary for the
selected server; reading its C source is not a new proof of binary identity.

The argument assumes ordinary noninterposed symbol binding, the selected
C-locale behavior in which gettext preserves these messages, and ordinary
library formatting/allocation service. It does not apply to arbitrary translated
error catalogues. The caller selects a valid fixed ELF command and the non-stdin
route, without server logging or malformed server arguments. Executing an
arbitrary text file could enter `execvp`'s shell fallback and is outside this
selection. These are invocation/service premises, not newly adopted production
behavior or a waiver of required proofs.

## Finite native error-string argument

`strerror` at `0xbb990` reads the thread locale and jumps to `strerror_l` at
`0xbb9b0`. Its call at `0xbb9d5` enters the lookup helper at `0x89ad0`.
That helper first initializes the result to null, rejects negative signed
`int` arguments, compares the nonnegative argument against the 64-bit count
at `0x1e4160`, and loads the corresponding pointer from `0x20fbe0` only below
that count. The checker independently decodes the RIP-relative targets and
finds exactly 134 slots. It decodes both ordinary RELA and packed RELR relative
relocations and reads every nonnull pointed string. Their longest payload is
49 bytes. Null table entries follow the same fallback as out-of-range errors.

In `strerror_l`, a nonnull result passes through gettext at `0xbb9fc` and is
returned. With the C-locale identity premise its length is unchanged. The null
path either reaches the fallback directly or calls `__asprintf_chk` at
`0xbba9d` with the fixed `%s%d` format: `Unknown error ` plus a signed 32-bit
integer. That is at most `14+11=25` bytes. If formatting does not return a
positive length, the code clears the stored pointer and falls through to
`Unknown error`, 13 bytes, via the same gettext branch. All normal returns
therefore have payload length at most `max(49,25,13)=49`. The terminating NUL
is not printed by `%s`.

The exact instruction bytes and disassembly support this manual control-flow
argument. The checker verifies the lookup instructions, relocations, strings,
input identities and arithmetic. It is not an x86 semantics proof of libc,
gettext, formatted I/O or allocation-failure machinery.

## Source branches and output routing

The source `create_process` at lines 313–399 constructs argv and forks. Under
ordinary allocation service, the parent frees its copied argv and returns.
The child has three explicit diagnostic sites, each immediately followed by
`exit(1)`:

| Branch | Fixed text bytes | Variable payload | Bound | Routing |
| --- | ---: | --- | ---: | --- |
| `setpgid` failure, lines 350–354 | 38 | command once, error once | `A+87` | inherited stdout, before redirection |
| stdin open failure, lines 381–384 | 29 | error once | 78 | inherited stderr; excluded by non-stdin selection |
| `execvp` returns, lines 391–397 | 23 | command twice, error once | `2*A+72` | redirected stderr if redirection succeeded |

The checker compares the literal formats to the source and checks the order
of all sites and redirects. The mutually exclusive exits mean the first and
last rows are not added for one child. A combined bound on these two explicit
messages, irrespective of destination, is `max(A+87,2*A+72)` per launch. A
successful `execvp` never returns to its diagnostic. With server logging off,
`logging_shutdown` exits without adding log text. Valid fixed server arguments
also exclude its argument-error prints; this is not an unrestricted server
diagnostic inventory.

`run_request` at lines 505–534 opens the temporary output file before this
call. The source does not check all `mkstemp`/`dup2` results. Consequently an
assertion that exec-return text reaches that file requires successful normal
service for the open/redirect operations. Their failures cannot silently be
treated as successful publication. In particular the process-group text is
never justified as part of the redirected file by this source order.

These counts describe bytes from the explicit formatting calls. They do not
count inherited buffered output flushed by `exit`, exit hooks, libc fatal
messages, dynamic-loader diagnostics or adapter runtime startup; those are
separate origins that a complete startup/output result must cover or exclude.

## Composition boundary

A prospective proxy must retain bounded storage for the backend's raw file
even when it publishes a separate canonical answer. Discarding that file as a
semantic response does not bound its size. The bound above supplies only the
direct exec-return contribution to such accounting; the loader/adapter and
other runtime origins remain open. It cannot justify a successful adapter
completion record, resource attribution, or request-to-leaf association.

No adapter, new server invocation, expanded membership or tool modification is
adopted here. The global allowance remains two save-entering callbacks, three
saves and `e<=2` per process, without a new per-component budget. The existing
parallel attachment, remaining preparation/counter/output bounds, complete
grammar, whole-rule accounting/composition and final review are still required.
