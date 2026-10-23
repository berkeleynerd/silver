# Backend-output route review

2026-10-23 UTC, #119 / #153. **Accepted conditional symbolic design interface**
at author freeze `bbec320d0a56ea843ccef0ece6ed43b4548d94b5`. The independent
audit passed on its first and only run. No new finding remains within this
review's scope; the concrete implementation obligations below remain for #88.

The accepted symbolic interface is
`q_backend(A,E)=max(2*A+72,A+E+1296)`, where A is the actual adapter argv0
byte length and E bounds the selected exception-name payloads. It applies to
the prospective pipe/control/canonical route, with the stated configuration,
runtime and source/refinement conditions. It does not bound the old stock
solver-to-file route or certify an implemented adapter.

## Review findings and required refinements

**BO1 — the original raw-file descriptor survives stock child exec.**
The stock source duplicates outfile onto fd1/fd2 without closing its original
file descriptor. The parent's later close does not close the child's copy.
The future solver launch must close every raw-file alias and route both output
streams to its pipe before exec. Otherwise merely replacing fd1/fd2 would not
establish the claimed destination closure. The frozen note states this actual
source fact and requires a complete descriptor implementation.

**BO2 — a pre-redirect solver child cannot add a second Ada report.**
After adapter fork, the child initially inherits the raw destination. The
single-report maximum needs a proved pre-exec path with checked descriptor
operations, a bounded launch-error pipe and immediate native `_exit` on
failure. That path must not raise Ada exceptions, run finalization, print
stdio diagnostics or dispatch custom callbacks before routing completes.
This is a future implementation obligation, not already observed behavior.

**BO3 — finalization and exceptional origins remain explicit.**
GNAT's default last-chance handler invokes Adafinal before its own output.
Standard_Library sets the once-only flag first; the Soft_Links procedure
invokes the task and library-finalization hooks. Arbitrary hook output cannot
be absorbed into the fixed handler constant. The source/import/binder closure
must retain the selected no-task/no-custom-hook/no-output-finalizer policy.
The existing faithful native service contract covers ordinary character output
and termination; it is not a capacity assumption for unidentified application
writers.

E remains a source-derived symbolic operand. The six standard exception names
have maximum payload 16, but selecting E=16 requires an exceptional-origin
closure, including chosen libraries and imports. No user-declared exceptions
alone does not exclude Assertion_Error or other library exceptions. The freeze
makes the distinction explicit. Missing future A/E values do not invalidate
the completed symbolic formula.

**BO4 — count the literals and export computable arithmetic guards.**
Author preparation corrected the abort branch from 50 to 51 bytes and the
traceback heading from A+48 to A+49 before freeze. Combined with E+231 basic
information and 1016 traceback bytes, the terminal constant is 1296. This was
an unaccepted draft refinement, not a defect in earlier accepted evidence.

A conservative configuration guard is A,E>=1 and q_backend(A,E)<=2^31-1 on
the selected Linux integer model, subordinate to existing request/path guards.
It bounds the argv copy, E+1 name metadata, helper temporaries and printf
length, and implies the signed off_t extent bound. It is not a new Silver
source or physical-resource cap. A future executable checker must evaluate
its arithmetic without overflow. The handler streams through Nobuf of length
zero; no q-sized diagnostic buffer is claimed. Adafinal may replace an
exception before output begins, so the theorem counts at most one
diagnostic-emitting terminal sequence rather than asserting one handler entry.
Failed character writes may omit interior bytes, so the valid bound is
cumulative attempted/output charge,
not necessarily a prefix of the ideal diagnostic string.

## Evidence and disposition

The [independent packet](../evidence/retained-backend-output-route-review-20261023/README.md)
binds all 16 frozen author files and 18 declared provider identities. Its audit
checks 23 complete source members, 31 strict spans and their exact rendered
excerpts, independently reattaches 14 runtime members to installed GNAT
sources, and inventories nine selected C units against the complete 12-unit
server archive. The writer review reads the selected complete sources; the
candidate-site inventory is an aid, not an exhaustive call-graph proof by regex.

The first and only audit passed **1,934 checks in 0.328771 seconds**, with
0.458971 seconds wrapper wall time. It independently derives the source
literals/helper constants and sufficient arithmetic implications, and checks
816 extremal terminal combinations. These finite checks support the explicit
source argument and are not themselves universal verification. Accepted
launch/error-string and 354/459 count results were reused by identity; no
author or predecessor checker was replayed.

The author retained one failed strict-anchor preparation before its successful
preparation and first focused check (1,017 assertions, 0.187648 seconds). That
failure emitted no source-range manifest and started no checker; the repair
selected the actual complete source tail without clipping. The earlier
unaccepted literal correction in BO4 is also retained in the author history.
No independent audit failure or successful rerun occurred.

Reviewer base is `4137b0dbd50d193f58e654f715eb785605a77ff1`; the exact author
freeze was imported as `f7acdb0d2c301b3971bee1d2a83c46a516a364a5`. Selected
reviewer is GPT-6 Astra / Extra High on Linux x86_64. Runtime model/effort,
token usage and cost are not independently available. The
[round record](../evidence/retained-backend-output-route-review-20261023/round.json)
separates elapsed observation time from the audit timing. No additional agents.

The direct exec-return term reuses the accepted libc/C-locale launch proof.
The server's valid logging-disabled parent prefix has no stdout/stderr writer;
request/reply and self-pipe writes have different destinations. Its child
failure messages cannot populate the parent's streams before a subsequent
fork. Thus no source-inherited stdio buffer is copied into later children.
The process-group failure remains a separate inherited-stream term A+87,
with zero contribution to the new raw file.

The prospective policy routes ordinary adapter diagnostics to finite control
records, solver/descendant output to the recognizer pipe, and canonical bytes
to a separate file owned by the proxy. It selects no raw tee. A fresh sequential
raw file therefore receives one alternative direct-exec or terminal-handler
charge under those conditions. Existing attempt counts transport it to
354*q currently, or the retained conservative 459*q, without creating a machine
counter or aggregate RAM condition. The inherited-stream process-group charge
transports separately as 354*(A+87), or conservatively 459*(A+87); it is not
added to this raw-file bound. The canonical-file 76-byte and control-decision
64-byte limits are unchanged.

The future `Adapter_Backend_Emission` certificate must establish the actual
descriptor inventory and transitions, allocation-free child failure path,
output-free adapter source/import/binder closure, selected default runtime
modes, finite exceptional-name family and overflow-safe configuration guard.
These are concrete #88 refinement obligations. Their absence today does not
invalidate the conditional design theorem and does not authorize treating an
unimplemented route as a production guarantee.

No production adapter/binder certificate, whole-rule completion, arbitrary
loader-failure theorem, new provenance requirement or silent runtime-output
assumption is supplied. The one global Why e<=2, two save-entering callbacks
and three saves stay unchanged. The reviewer does not write GitHub, shared
records, CLI memory or harness state, and runs no target, solver, compiler,
proof, capture, disassembler or predecessor checker.
