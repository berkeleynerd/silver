# Selected save write-service contract

2026-10-20 UTC, Round 36, #119 / #153; base `aeafcd1797`.
This attaches an **explicit external-service premise** to the actual save
write route. It closes the conditional interface join left by
[Round 34](retained-why-save-io-services.md). It does not prove a stronger
POSIX guarantee or establish a universal property of the installed filesystem.
The [packet](../evidence/retained-why-save-service-contract-20261020/README.md)
retains the caller correspondence and exact inherited evidence.

## Premise and authority

For the selected private, blocking, regular-file output descriptions, a reached
`write(fd, p, n)` with a valid readable buffer and `1 <= n <= 65536` has one of
these outcomes:

1. It returns a count `1 <= w <= n` and commits exactly that prefix, advancing
   the description's offset by w under the existing ordinary-write semantics.
2. It returns the ordinary error/interruption result, handled by the retained
   runtime route below, or raises through the existing runtime service boundary.
3. It does not return. No subsequent caller store is inferred in that case.

This **strengthens the weaker `0 <= w <= n` interface** used by the earlier
countermodel. It is a newly explicit behavioral premise within the already
approved OS/libc/runtime boundary, not a deduction from the words “functioning
services.” The Oracle permits documented interface assumptions for those
trusted dependencies. The existing
[interface boundary](../trusted-boundary.md#compiler-implementation-and-runtime-imports)
and [source-behavior interpretation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
distinguish caller obligations from the assumed external implementation.
This premise is independent of source-program size, solver success or whether
an accepted program fits. It requires no new import, tool pin, toolchain change
or Oracle amendment.

Neither the retained POSIX return-value excerpt, the disabled runtime assertion
nor successful sample writes proves this premise for all host executions.
No such proof is claimed. The zero-return countermodel remains valid under
the weaker interface: one zero return for a full buffer permits Putch to store
past its end. A zero successful return violates the stated premise; it is
not silently reclassified as an error that the installed runtime handles.

The premise permits short writes, exceptions and blocking. It promises neither
complete output delivery nor durability, an EINTR retry limit, or eventual
termination without the separately applicable external-progress conditions.
It applies only to the selected XML/shape file descriptions, including an
ordinary flush of those same descriptions. It does not establish contracts for
stdout/stderr, prover pipes, sockets or arbitrary members of the global channel
list. Their caller/service composition remains with the corresponding owners.

## Caller preconditions come from actual source

The selected sources remain Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`
and OCaml `8eb41f72ded84df884c3671734c947f612091f84`, with the installed binary
and source/native relation of the accepted file packet.

- `Session_itp.save` opens XML using `open_out` and shapes using
  `Compress.Compress_z.open_out`. The selected `Compress_none` module aliases
  Stdlib for both exported modules. There is no new compression client.
- Stdlib's `open_out` passes precisely write/create/truncate/text flags;
  `caml_sys_open` maps those to the selected Unix flags. No Open_nonblock or
  Open_append is present; text mode has no translation on this Linux route.
  CLOEXEC, when supplied by the runtime, does not alter blocking or append mode.
- The prior fresh regular-file/workspace and stable-description relation
  supplies file kind, initial offset and absence of hostile replacement. File
  kind is an environmental input, not something `open_out` proves. The selected
  private clients do not change flags, seek, append through another description,
  or close a description still used by another live save. Nested saves open
  their own descriptions. These inherited ownership premises remain explicit.
- The installed channel layout has a 65,536-byte buffer. At each live output
  operation, the established invariant gives
  `0 <= P = curr-buff <= 65536`. `caml_flush_partial` invokes `caml_write_fd`
  only if P>0, with `n=P` and pointer `buff`. Thus the actual syscall request
  lies in 1..65536 and its bytes are within the allocated buffer. This range
  fits both the retained C int and ssize_t representations.
- The inherited caller/pending-action argument rereads P after processing
  pending callbacks. The no-pending blocking-section entry prevents an
  unclassified save between the resulting successful write and its state
  commit. The faithful roots/lifetime and one-worker relations still apply.

The valid-request assertion is inductive, rather than an assumed final safety
result. Initial curr=buff gives P=0. A valid source copy can fill at most the
remaining buffer extent; the write premise then supplies the successful
flush step that preserves the invariant. Its positive lower bound makes room
for Putch's next character. Errors and nonreturn do not execute that store.

## Success, interruption and errors

`caml_write_fd` calls the existing libc write. On EINTR it returns the special
`Io_interrupted`; `caml_flush_partial` branches back to its pending-action
check before any offset, buffer shift or curr commit. Thus EINTR is not added
as a negative byte count. The retry reuses the existing channel/buffer and
local C frame. No finite retry count is required for these local representation
invariants; callback or error work retains its separate owners.

The runtime also contains an EAGAIN/EWOULDBLOCK fallback: when n>1 it retries
with n=1, at most once per call. The narrowed request remains within the same
contract and buffer. It cannot enlarge the original P or count. An error at
n=1, or any other ordinary error, calls `caml_sys_io_error` and raises before
the successful-return state update. This packet does not declare all error
message construction or higher catches safe; those demands remain in the
error/exit composition.

For a returned `1 <= w <= P`, the retained flush body changes P to P-w and
cached offset O to O+w, moving only the still-pending P-w bytes. If the buffer
was full, its resulting P is at most 65535, so Putch's store is in range.
The accepted [offset-bias lemma](retained-why-save-io-services.md) maintains
O=F+delta, delta in {-1,0}, and F+P<=A<=X. No successful initial lseek is
required. Each reached successful write keeps O within [-1,X], independently
for each description; the five XML and five shape X values already fit signed
64-bit offsets. In the block-output path a full buffer may make one call
return zero newly copied source bytes, while the underlying write makes
positive progress. That is distinct from a zero syscall return and leaves
room for the next copy; it does not invalidate the contract.

## Result and remaining obligations

The focused checker binds the prior file/offset/native evidence and exact
source slices for the selected route. It joins all five process identities,
both descriptions and both initial cached-offset cases, verifies the request
and offset guards, and retains the weaker-interface countermodel. It does not
execute a syscall or prove the external service premise by testing.

Conditional buffer/offset capacity is now attached to a precise selected
service interface. Outputs label that premise as required and **not proved
for the installed OS**; unconditional file bounds remain null. Complete file,
save and pipeline flags remain false. Global channel traversal/refcounts,
other output destinations, caller allocation/stack, failure diagnostics and
complete error/exit effects still need their own arguments.

The combined Round 36 reviewer first assessed the proposed trust interpretation
read-only, then reviews the frozen caller attachment. That advisory is not a
new standard guarantee or measured host behavior. No Oracle, installed tool,
pin, admission or production implementation changes are made.
