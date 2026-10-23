# Independent backend-output route review

See the [accepted review](../../reviews/review-backend-output-route-20261023.md).
Author freeze: `bbec320d0a56ea843ccef0ece6ed43b4548d94b5`.

The first and only independent audit passed **1,934 checks in 0.328771 seconds**
(wrapper wall time 0.458971 seconds), on Linux x86_64. It binds all 16 author
files and 18 declared providers, 23 complete source members, 31 strict source
spans and their rendered excerpts, and 14 live installed GNAT source members.
The nine selected Unix server C units are checked against the complete
12-unit server archive; excluded units belong to other executables/platforms.

The accepted conditional design interface is
`q_backend(A,E)=max(2*A+72,A+E+1296)`, with A,E>=1 and the conservative
configuration guard q_backend<=2^31-1. A is the actual executable argument
byte length; E is the selected exception-name payload maximum. E=16 requires
the separate standard-only exceptional-origin closure. No concrete A/E is
invented and the stock solver-to-file route remains outside the formula.

The independent audit derives literal/helper bounds, checks sufficient
arithmetic implications and 816 extremal terminal combinations, and transports
the accepted 354/459 attempt counts. The finite cases support the reviewed
source argument; they are not a universal implementation proof. Accepted
launch/error-string and count providers were reused by identity without
replaying their checkers. The audit imports no author or predecessor code.

`inputs.json` binds the freeze and providers. `audit-result.json` records
those identities, complete source/live-runtime identities, audit-code identity,
writer candidates and counters. `audit-attempts.json` and
`audit-attempt-1.log` retain the sole passing run. `round.json` records
selected settings, available timing and scope. `checkpoint.json` remains the
historical pre-freeze preparation snapshot, not the current disposition.

The review resolved the original raw-file descriptor alias, possible second
pre-redirect child report, finalizer/hook boundary and draft literal/guard
wording in the design. Future #88 `Adapter_Backend_Emission` refinement must
implement and prove those conditions. This packet certifies no production
adapter, whole-rule completion or old stock raw-file bound, and adds no
loader/provenance requirement or aggregate RAM/stack gate. The single global
Why e<=2, two save-entering callbacks and three saves remain unchanged.

No target, compiler, solver, proof, capture, disassembler or author/predecessor
checker was run by the reviewer. No GitHub, publication, shared-record,
harness-state or CLI-memory writes were made. No additional agent was spawned.
