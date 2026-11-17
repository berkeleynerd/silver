# Named scalar argument source correspondence

Issue [#392](https://github.com/berkeleynerd/silver/issues/392), source stream,
2026-11-17. Worktree `tmp/named-source-392`, branch
`feat/named-arguments-source-392-20261117`, base `bf285bc57`.

This is an implementation work record, not completed assurance. The source
stream owns the handwritten typed call/source correspondence and its candidate
extraction checks. Native bodies and semantic call readings are separate owned
streams. Exact source bytes remain the compiler's authoring representation;
the semantic ordering operation never rewrites author source.

The shared resolver retains the called signature's fixed formal slice, a
source-order ordinal, the named-suffix flag and a visited-formal set. Its typed
tree has only formal metadata and lexical lookup imports; it cannot look up a
selector as a caller variable. Lookup is deterministic first-match even for
metadata with repeated spellings, retaining the complete native precondition.
Zero cursors and invalid query spans are included. Unknown selectors can return
a zero formal with a nonzero payload, matching the actual native record.

Function and procedure tail trees retain the same incoming flow at every
actual. Procedure payload replay resolves the same associations and checks
only payload spans; the sole lexical exemption is the exact writable actual's
own payload span. The update tail selects the declared formal's bounds, moves
the scan cursor to that payload, and accumulates updates in source order. The
semantic stream separately establishes canonical formal-order call meaning.

`PredicateAssociationSyntax` checks binder types, expression precedence and
the explicit `=>`/`Arrow` token pairing. `PredicateAssociationEquations` also
defines a storage interpretation retaining every cell of the native
`Formal_Set` array and relates its empty value and update to the semantic set.
The native source-derived maximum is reused; no extra association limit is
introduced.

At the initial 02:28 UTC checkpoint, the typed trees, exact-domain equations,
library links and candidate extraction statements were drafted. A read-only
import-graph check found all nineteen new source-owned modules reachable from
the intended function/procedure candidate and library roots. `git diff --check`
passed. No Lean result is claimed for this draft. The complete reviewed source
pin was deliberately still unchanged while native focused checks and semantic
helper checks were in progress. The source worktree temporarily contains copied
semantic dependency drafts for checking; those are excluded from this stream's
commits and remain owned by the semantic author.

| Round | Selected setting | Intended result | Actual result and next check |
| --- | --- | --- | --- |
| Initial design and implementation | Project source-correspondence category: Astra Max; runtime model/effort not independently exposed | Match all new native helper bodies with typed trees and retain full domains | Draft complete through source candidates; focused helper/library checks pending semantic pilot and shared worker release. No native execution, token or cost measurement attributed to this stream. |

Focused attempts (Linux ARM64, native overlay proof workspace, pinned Lean
4.34.1, retained earlier objects):

| Managed run | Resources and elapsed time | Result and focused follow-up |
| --- | --- | --- |
| `20261117T023029-4009d81b61b9` | 12 workers, 12 threads per process; 25.46 s | Failed before audit. Shared admission modules and procedure syntax/native trees compiled. Own errors were the initial local-environment type, fixed-frame pattern names colliding with constructors, and natural Boolean equality notation. [Original output](focused-r1.log). |
| `20261117T023503-ad29eff2a69e` | 8 workers, 12 threads; 8.87 s; four workers left for concurrent native helper work | Function and procedure equation modules compiled, including structural controls. Remaining failure was field notation on a function-valued local environment; changed it to explicit `Locals.set`. The batch audit did not run. [Original output](focused-r2.log). |
| `20261117T024152-355ce247a59d` | 12 workers, 12 threads; 110.055 s managed, 107.552 s build | Association native tree compiled. Remaining local failures were nested application unfolding, a dependent Boolean conjunction simplification, and ghost cursor/index constructor collisions. Two semantic consumer copies were stale; replaced with exact committed `78e61f3e2` dependencies. The audit did not run. [Original output](focused-r3.log). |
| `20261117T024622-f4c0a17df1fb` | 12 workers, 12 threads; 16.557 s managed, 14.028 s build | Association and function equations compiled. Remaining failure is confined to association helper normalization: unfold the model-call dispatch before synchronizing equal-name branches and formal-at wrappers. The audit did not run. [Original output](focused-r4.log). |
| `20261117T025013-57bee7adf2f0` | 8 workers, 12 threads; 18.372 s managed, 15.739 s build; four workers retained for native proof | Association full-domain helper normalization compiled. Function tail helper unfolding left old dependent `Decidable` instances, so a following rewrite could not construct its motive. The focused repair explicitly unfolds instances and uses simplifier congruence; all helper domains remain unchanged. [Original output](focused-r5.log). |

The lead approved a separate `PredicateFunctionCallGhostSource` module for the
proposed native `Lemma_Function_Actuals_Advance`. Its draft models the complete
typed argument list, one-step semantic identity and runtime erasure. The native
null-body helper has not yet passed its whole contract and is not consumed by
the loop; this source draft does not establish native proof success. Exact candidate
binding is drafted with both reviewed caller-local definition annotations, in
order `Function_Association` then `Actual_Model`, retained in the complete
ghost body. The reviewed source pin remains unchanged pending native success
and final loop source. Runtime loop-call binding will follow that disposition.

Focused and complete evidence, exact input identity, failed attempts and final
review disposition will be recorded here as those checks finish. The complete
integrated checkpoint remains lead-owned. CLI memory was not updated.

The remaining short focused rounds are recorded exactly in [managed-runs.json](managed-runs.json):
`r6` removed two now-unused simplifier arguments after the function-tail proof
elaborated; `r7` compiled the function/procedure helper layers but diagnosed the
ghost identity's last tactic; `r8` compiled that ghost identity and found a
missing direct library-witness import plus one stale semantic consumer. Their
original outputs are [r6](focused-r6.log), [r7](focused-r7.log), and [r8](focused-r8.log).
Committed semantic consumers `3983a1c93` replaced the temporary stale copies.

The helper/library checkpoint `20261117T025347-51f686bdde03` passed on Linux ARM64
with 8 workers and 12 threads (four workers retained for native proof). Build
7.117 s; fresh audit 1.109 s; managed duration 14.194 s. All 338 imported modules
and 49,840 declarations passed the standard-foundations-only audit. This is
focused validation, not a complete project or actual-source certificate check.
The [log](helpers-libraries.log), [full provenance](helpers-libraries-evidence.json),
[input snapshot](helpers-libraries-inputs.tar.gz), and
[verification](helpers-libraries-verification.json) retain the exact inputs.
All 1,140 repository inputs, 1,035 workspace inputs, both tools and the saved log
were independently rehashed against that provenance. This snapshot includes
borrowed semantic inputs and unvalidated candidate drafts; it does not make
those candidates part of the passed targets.

A subsequent first check of the three Source.Checked definition modules passed:
exact headers, typed source expressions, association controls and procedure
ghost-call rendering compile with a fresh 18,823-declaration audit. See
[source definitions](source-definitions.log) and [provenance](source-definitions-evidence.json).
It did not import complete reviewed-pin candidates. The native checker then
reported the two Hide_Info annotations must precede `begin`, so the source ghost
body placement is being brought into agreement with that correction. The helper
semantics and contract remain unchanged; final candidate checks remain pending.
