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

The two caller-local Hide_Info annotations were subsequently removed. They did
not resolve the native recurrence proof. The owner-authorized shared
`Mark_Formal` repair instead gives all native model and runtime updates the same
pure function identity, avoiding distinct generated array-map terms. Native
whole-helper contracts and the standalone function recurrence passed before
the loop consumed that helper; the native stream retains those exact results.

The source marker tree retains the sole delta expression and its exact native
index subtype domain, with no added precondition. Function and procedure trees
now call an explicitly linked `Mark_Formal`; their mathematical meaning remains
`markFormal`. The complete source declaration preserves the pointwise result
postcondition. `markFormal_storage` connects the typed expression to
`FormalStorage.read_mark` over every native array cell. The marker's Ada delta
aggregate shares the expression function's outer parentheses, so the source
check restores that exact shell after the standard balanced-body extraction.

Focused shared-marker checkpoint `20261117T030746-bf872a6a0f4d` passed all helper
and library targets: 338 imported modules, 49,919 declarations, standard
foundations only; 8 workers/default 12 threads alongside native 4 workers.
Build 66.759 s and fresh audit 1.716 s. The [log](mark-helpers-libraries.log),
[provenance](mark-helpers-libraries-evidence.json), and
[exact inputs](mark-helpers-libraries-inputs.tar.gz) are retained. All 1,141
archived input bytes match the recorded hashes; source files subsequently
changed for the loop binding were reconstructed from their known exact edits
and checked against those hashes before archiving, not asserted to match.

Focused source-definition checkpoint `20261117T031315-44bc724a3e70` then passed:
123 imported modules and 18,902 declarations, standard foundations only;
8 workers/default 12 threads; build 2.480 s, audit 0.831 s. This includes the
finite-storage connection and exact typed advance-call placement before the
validated function loop changes cursor, Seen or Named. It still does not check
the complete reviewed-pin candidate. [Log](mark-source-definitions.log),
[provenance](mark-source-definitions-evidence.json), and
[1,142 rehashed exact repository inputs](mark-source-definitions-inputs.tar.gz)
are retained. Both original terminals completed with exit zero and released
their reservations.

For the eventual complete source checkpoint, the lead and source author chose
one Lake worker with default 12 Lean threads and the existing 8,192 MiB per
process threshold and measured RSS/host guards. This is a current resource
choice: at the 03:08 UTC inventory, changing the complete output pin invalidates
177 transitive dependents, including 154 candidate/part modules. The two known
dense candidates are independent siblings and can overlap. Native output source
had grown from 424,781 to 450,194 bytes (+5.983%); MemAvailable was 9,497,344 kB
while native/source focused work ran, with no swap. The previous complete run
measured 7.136 GiB plus 1.697 GiB concurrent children and 1.164 GiB Lake, exceeding
the 10 GiB tree guard; its one-worker continuation passed at 8.601 GiB peak.
A later added function-loop source part increases the affected graph; the final
lead inventory must use the final source. Serialize the dense checkpoint after
other writers release, retain successful objects, and reassess if a continuation
is needed. This does not claim that the complete checkpoint has run.

The first final-pin candidate batch `20261117T033146-10e4c23dfa78` failed before
its union audit. All new association, marker, function tail/advance/loop and
procedure payload/alias/update parts compiled; the association whole candidate
compiled. Two local proof scripts failed: `CallsActualsModelSpec` still expanded
the old recursive wrapper header, including its removed subprogram variant;
the procedure whole-candidate loop membership simplifier traversed the large
embedded token payloads and exceeded the default recursion depth. This is a
failed batch, not a candidate-union success. The complete original output,
managed start/events, resource samples, original 24-file ownership inventory and
all 1,142 rehashed input files are retained in [candidate-r1-failed](candidate-r1-failed/verification.json).
Build time was 1,390.308 s (managed 1,392.892 s). Peak tree RSS was 6,639,264 KiB,
peak process RSS 5,574,192 KiB and minimum host available memory 8,911,744 KiB;
no resource interruption occurred.

The bounded diagnostic repair preserves both complete theorem statements,
all domains, source bytes, the reviewed pin, all three procedure loop parts and
existing budgets. Replace the stale function-header proof body with kernel
reduction of its current declared statement and remove its two obsolete proof
imports. Replace broad simplification of procedure loop membership with three
constructor membership cases. First check those two modules over their complete
statements; then repeat the original cached candidate union for a fresh audit.
Only those light scripts and the function aggregator are newly affected, so the
retry uses automatic available workers, default threads and the existing memory
guards. The native complete run holds four workers; the managed runner currently
has eight available. No dense source pin or native input changed, and no cache
is cleaned or replayed. A new final inventory will include the added function
header file; the failed 24-file inventory remains immutable.

The two bounded repairs passed their complete focused check in
`20261117T040126-ff9bd176a52b`: 151 modules, 19,120 declarations and standard
foundations only. Build 5.924 s; fresh audit 1.009 s; runner elapsed 13.523 s.
The original three-candidate union then passed in
`20261117T040233-3ed92ba6662c`: 243 modules and 20,793 declarations, standard
foundations only; build 1.916 s, fresh audit 0.893 s, runner elapsed 9.081 s.
Both used eight automatically allocated workers, default twelve threads and
8,192 MiB per-process threshold alongside four native workers. The guards did
not interrupt either run. Their respective peak tree RSS values were
2,344,544 KiB and 1,211,024 KiB; minimum available host memory was 12,912,864 KiB
and 13,249,904 KiB. The successful candidates reuse the preserved individual
parts from the failed first batch; no clean build or replay is claimed.

[Repair evidence](candidate-repair-check/evidence.json) and
[union evidence](candidate-union-check/evidence.json) retain the exact commands,
logs, managed events and resource samples. For each success, all 1,142
repository inputs, 1,037 workspace inputs, two tools, 6,202 artifacts and the
saved log were independently rehashed against provenance. Repository and
workspace input archives were rehashed again after capture. The
[two-file patch](candidate-two-script-repair.patch.gz),
[before/after hashes](candidate-two-script-repair-hashes.json), and
[final 25-file ownership inventory](final-owned-files.json) distinguish the
bounded repair from the retained failed 24-file snapshot. Only source-owned
files and this evidence belong in the source commit; borrowed semantic and
native dependencies remain excluded.

Independent read-only source review confirmed that the two repairs preserve
complete statements, domains, axioms and budgets. It independently rehashed all
1,142 failed-run inputs and found exactly those two changed proof files. The
native output implementation remains SHA256
`de017ca035a5ffd358d5fa98646d017dfe4ef54bd822fafc40743a9a8ae66f53`,
and the reviewed complete output pin remains
`7d034eaaa79d6f3175ebd957eda8a493b6e2290d1904e654bac8469cd1616383`.
The catalogue dependency is
`2e46a16831e048dd64299a7bb31e554e9e478e7daa1a1eb79922be2bc34ccfab`.
The lead maintains the independent review report and its final disposition.

This closes the source-owned focused candidate work. The complete integrated
Lean source/provenance and axiom/coverage check remains outstanding on the
lead's combined commit; it must use the exact integrated bytes and preserve this
cache. The native complete checkpoint is separately lead-owned. Source
correspondence/diagnosis selected the project Astra Max category; runtime
model/effort and token/cost measurements are not independently exposed. No CLI
memory update or publication is claimed.
