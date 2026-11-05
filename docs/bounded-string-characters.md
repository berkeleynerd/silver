# Bounded String indexing and character operations

Status: external-review repairs in progress, 2026-11-05; PR #307 is draft and unmerged.
The [interim response](interim-review-response-20261105.md) supersedes the earlier
completion assessment. Prior successful checks remain records of their exact inputs.
[Milestone 16](https://github.com/berkeleynerd/silver/milestone/16) contains one
work package, [#296](https://github.com/berkeleynerd/silver/issues/296).
The [authorization](session-memory.md#2026-10-31--bounded-string-indexing-and-character-operations-authorized)
covers the complete implementation, assurance, review and feature PR delivery.
The [delivery assurance and validation](#delivery-assurance-and-validation) section
records the earlier reviewed checkpoint. Earlier dated sections preserve development history.
PR #307 remains open for owner review.

## Initial scope

The motivating Rosetta candidates are Reverse a string, Palindrome detection
and character replacement. Confirm their complete task requirements and choose
faithful bounded programs during design. Record demonstrated task mappings
separately from program counts; no broad String construct is promoted merely
because one rewritten task works.

- Indexed reads and element writes on fixed-bound Strings, using bounded
  Integer index expressions.
- Character literals and initialized scalar constants or variables, including
  copies, assignment and comparisons, under the current printable-ASCII policy.
- Bounded slice expressions with decidable bounds and length rules, usable with
  existing String expressions and length-compatible assignment.
- Composition with finite loops, guards, Boolean conditions, initialization,
  snapshots and output under the existing declaration and name-hiding rules.

Preserve the current 4,096-byte source, 63-operator and 64-leaf budgets; state
the applicable counting rules for new expressions explicitly. General
dynamic-length indexing, resizing, Unicode processing, general String/Character
libraries and capacity-limit changes are excluded. Boolean arrays and functions
remain separate queued features.

## Design and assurance obligations

Settle syntax and inherited meaning before fixing the admission rules. In
particular, check Character literal spelling against existing apostrophe
attributes, predefined-name visibility, actual String lower bounds, null slices,
concatenation and assignment sliding, and evaluation before mutation. Use the
pinned frontend to distinguish genuine Ada/SPARK restrictions from Silver's
selected scope. Document the purpose of every added restriction.

Derive every index, slice and destination-length obligation from declarations
and executable control flow. Cover unreachable arms and empty loops where the
pinned frontend still rejects invalid source. Preserve fixed bounds and exact
runtime byte semantics through element writes, copies and slices. Existing
length and Boolean facts must retain only the information justified by their
current rules; mutation must not create stale byte-equality assumptions.

Extend the native implementation and Lean admission, semantics, composition,
automatic-discharge and actual-source arguments together. Review source-tree
precedence and helper domains against their Ada definitions. New source
certificates and every proof module must enter the complete source/module/axiom
checkpoint. Keep endpoint guarantees, native contracts and required obligations;
no suppression, source replacement or Oracle amendment is permitted.

Discover the native diagnostics produced by representative admitted shapes
before changing report handling. Account for any relevant report-storage or
recognizer-stack effect within current limits. Use focused managed checks during
development and one stable complete checkpoint; retain applicable successful
work and diagnose a repeated failure before another attempt. A new framework,
performance project or assurance mode is not part of this feature.

## Design checkpoint — 2026-10-31

Implementation is in progress; these decisions do not claim supported syntax.
The integration branch starts at authorization commit
`1500b902a91c25f88cbb7aed1c832bbfb90d2959`. The initial independent semantics
review used GPT-6 Astra / Extra High; the native architecture and discovery
thread selected GPT-6.1 Sol / Extra High. Runtime model confirmation and token
or cost measurements are unavailable.

Character constants and variables share the internal initialized byte store
with Strings, represented as single printable bytes. Explicit kind checks must
keep their Ada types distinct in declarations, expressions, comparisons,
assignment, output, attributes and name hiding. In particular, a one-byte String
is not a Character, and the existing String output operations do not accept a
Character directly. Character concatenation and slice assignment targets are
outside this selected increment; Character values support indexed replacement,
copies and comparisons, while slices extend the existing String expressions.

Index and slice prefixes name existing Strings whose actual bounds are known
at declaration elaboration. Input-dependent-length Strings retain their current
whole-String operations; proving an input length in a guard does not add general
dynamic-length indexing. Actual bounds are independent of length: slices and
copies preserve both bounds, including arbitrary inverted null ranges;
concatenation preserves a nonnull left operand's lower bound and returns the
right operand when the left is null. Whole-String assignment slides equal-length
values onto the target's unchanged bounds. Element assignment preserves those
bounds and reads its target index and RHS from the incoming store.

Indexed reads and writes require a nonempty inferred Integer interval contained
in the prefix's actual bounds, including unreachable arms and empty loops.
Slice endpoints retain their ordinary scalar arithmetic checks. For independent
nonempty endpoint intervals `[a,b]` and `[c,d]` and prefix bounds `B .. E`,
the selected rule accepts either `a > d` (every slice is null), or
`a >= B` and `d <= E` (every potentially nonnull slice is within the prefix).
Its length interval is `max(0,c-b+1) .. max(0,d-a+1)`, computed in wide
arithmetic. Endpoint and concatenation-bound proof integration remains pending.

Each Character literal or name is one expression leaf. An indexed read costs
one prefix leaf plus its subscript's scalar leaves; a slice costs one prefix
plus both endpoint expressions' leaves. Indexed targets and assignment RHSs
have independent 64-leaf checks. Image keeps its existing separate scalar
argument budget. All source bytes still count toward 4096, and all arithmetic
inside indexes/endpoints counts toward the shared 63 operators. Complete
Character literals, including operator characters and quotation marks, are
skipped by the operator and xor scanners; their contents add no operators.

The first pinned frontend/prover discovery run
`20261031T162539-96d0ba9159be` confirms all 95 printable Character literals,
noncanonical String bounds, null slices `0 .. -1`, `-2 .. -3` and
`2147483647 .. 2147483646`, and assignment between differently bounded null
Strings. Literal-only Character comparisons are ambiguous and therefore need
a typed Character name or indexed String operand. A declaration named
`Character` hides its own type mark. Invalid static indexes can still fail in
dead code. These focused experiments establish producer behavior for their
inputs, not universal assurance or completed feature validation. Discovery
inputs and logs are retained in the native lane's
`.silver/linux-x86_64/string-discovery/`; the final evidence packet will identify
its complete outcome and applicable inputs.

## Completion

Complete native Bronze/Silver proof and coverage/provenance audit, a matching
build, complete Lean/source/module/axiom assurance, and the required final
regression and sample coverage. Use the existing reviewed-reuse provision only
where every final test remains accounted for. Review the critical arguments and
final evidence independently, retaining exact targets and prior failed results.

Synchronize language.md, the catalogue, samples, roadmap capability status and
Rosetta records under the [planning workflow](planning.md#rosetta-progression).
Publish a completed feature PR and leave it open for owner review. No supported
status is claimed before that validation and review pass.

## Work rounds

| Date | Selected settings and intended result | Result and remaining work |
| --- | --- | --- |
| 2026-10-31 | Integration/design subthread selected GPT-6 Astra / Extra High; record scope and inspect the existing architecture. Lead runtime settings and token/cost totals are unavailable. | Authorization and initial proposal prepared; no implementation or validation result yet. Exact String/Character rules, native feasibility and the corresponding proof design are next. |
| 2026-10-31 | Lead integration selected GPT-6 Astra / Extra High; native worker GPT-6.1 Sol / Extra High; semantic worker GPT-6 Astra / Extra High. Runtime model confirmation and token/cost totals unavailable. | Native implementation, core String/Character execution and obligations, Character predicate semantics and partial source models are integrated. Focused native helpers and eight exact application stress/driver cases passed; the native compiler checkpoint is pending. Source metadata must agree with actual bounds and Character kinds; ordered declaration and source-certificate integration remain open. |
| 2026-10-31 | Continued integration with the inherited lead setting; source worker selected GPT-6.1 Sol / Extra High and independent reviewer GPT-6 Astra / Extra High. Runtime confirmation and token/cost totals remain unavailable. | The actual-bounds repair passed focused assurance and independent review. Source-wiring review identified #306; its inventory repair is checked and queued. A known header memory failure was isolated to expected-token lexing; an explicit-token candidate passed the kernel probe, with full candidate checks pending. Seven installed-Lean fixtures are covered across the retained run and repaired module-fixture check. Complete native/source validation and delivery remain open. |
| 2026-11-04 | Lead retained its inherited setting (runtime model/effort unconfirmed); bounded inherited-state repair selected GPT-6.1 Sol / Extra High; independent source review selected GPT-6 Astra / Extra High. Token/cost measurements unavailable. | Complete native assurance and complete cached Lean/source assurance passed. The source review passed in 211 seconds after wrapper/example/state-domain integration repairs and explicit scratch-audit scope corrections. Final regression and delivery accounting remain. Exact run timings and failed attempts are retained below. |

### Retained focused evidence

The native application stress run `20261031T165409-9c2dd4f813bc` used native
commit `9c4afd3c5b` and passed admission, build, complete application/runtime proof,
strict Python report audit, the native application-report policy probe, exact
execution and unchanged author-source hashes for eight cases. Inputs include a
4096-byte source with 1992 nested Character groups, 64-leaf read/target/slice
expressions, a 4096-byte comparison/write loop and the three prepared Rosetta
drivers. Its dense Main report was 51,467 bytes. Summed case execution was
42.507 seconds; this is not total agent elapsed time. The native lane retains
`string-stress/summary.json`, exact inputs, reports and logs beneath its native
`.silver/linux-x86_64/` directory. The earlier wrapper attempt stopped before
proof analysis because its explicit solver-cache directory did not exist;
that failure and original logs remain retained.

Focused integration checks established the raw Character condition/scanner
model (`89ba2351e3`, fresh audit 7504 declarations) and fixed declaration bound
metadata (`d6d6eff5b1`, fresh audit 6057 declarations). These imported-module
checks do not establish complete source correspondence. The core worker's
Character predicate/Boolean composition check passed 11666 declarations against
its exact `179f73e009` inputs. Complete native proof, full Lean source/module/
axiom audit, final regression inventory and independent review remain required.

The next source-proof integration round retains the selected Astra / Extra High
lead and semantic worker and Sol / Extra High native worker; runtime settings
and token/cost totals remain unavailable. Actual-bound metadata and grouped
concatenation safety passed focused Linux checking (72 jobs, fresh audit of
8419 declarations). The integrated typed String/Character declaration-list
proof at `d133dd2de8` passed 82 jobs and a fresh audit of 8833 declarations
(build 7.949 seconds, audit 5.884 seconds, using retained compiled dependencies).
These are focused results, not complete feature or source-correspondence
assurance. Raw initializer traces, condition/assignment source composition,
ordered bound preservation and exact native typed-source rendering remain
under integration. A requested fourth thread was unavailable because the
session's agent limit was reached; work stays with the existing team.

### Native-domain integration checkpoint — 2026-10-31

The metadata-complete source interface distinguishes mathematical state validity
from the full native domains. `NativeState`, `NativeNames`, `NativeValue`,
`NativeResult` and `NativeScan` retain actual String endpoints and Character kind
metadata; the raw Add_Binding precondition includes its exact fixed-bound check.
No source-history or concrete runtime store premise is added to a native
contract. Typed source AST constructors now represent all native record fields.
Exact ordinary helper bodies and their callee equations remain under integration.

Lead context-propagation commit `5b9d69d071` carries these bound witnesses through
body loops, the main adapter and Boolean initializer contexts. Its focused Linux
check passed a fresh 20,159-declaration audit with the three permitted foundations
(audit 7.203 seconds). A preceding broader check was intentionally interrupted
after 666.357 seconds when its still-running old helper-equation dependency was
superseded by the new native interface. Compiled dependencies were retained; that
interrupted run is not successful validation. The core worker's separate complete
native record helper `bb9445e18f` passed 76 jobs and a fresh 11,660-declaration
audit (build 122.453 seconds, audit 7.365 seconds). Full project/source assurance
remains outstanding.

The [retained development packet](evidence/bounded-string-characters-20261031/README.md)
now contains the original discovery and eight-case stress inputs, reports and
logs with verified hashes; no successful native run was repeated for packaging.
The [producer account](bounded-string-characters-report-capacity.md) extends the
existing joint source charge to indexed String operations and slices within the
unchanged report allocation. The [independent capacity review](reviews/string-character-capacity-20261031.md)
found no blocking issue under the retained assumptions and independently
recomputed the existing bound; its three additional frontend/conversion route
citations are incorporated. Complete independent feature review is still pending.
The three [Rosetta approaches](../rosetta/assessment-bounded-string-characters-20261031.md)
match the cached task wording and prepared sources. A fourth capability sample
covers slices, null bounds and assignment sliding without claiming another task.
The new Rosetta identifier is not yet promoted to supported.

This round retains the selected GPT-6 Astra / Extra High lead and semantic worker,
and GPT-6.1 Sol / Extra High native/source worker. Runtime settings and token/cost
measurements are unavailable. Progress is the checked bound/interface integration;
source-body closure, final native and Lean checks, full regressions, independent
review and publication remain open. No additional feature or Oracle amendment is
selected.

### Character source meaning checkpoint — 2026-10-31

Commit `31366d0231` adds the complete typed native Character predicate body,
its callee-independent equation, constrained-record sizing and helper-derived
meaning. Character calls retain arbitrary valid array initializers and the
elaboration flag. Relation fallback and the Character exclusion from String
Length are synchronized. The xor scanner source tree now skips a complete
Character literal through an explicit primitive call. Its recursive meaning is
derived using the separately interpreted literal primitive.

The focused Linux check passed 133 jobs and a fresh audit of 18,371 declarations
against the existing foundations (build 23.704 seconds, audit 6.482 seconds).
Earlier checks identified and repaired an invalid-flow record simplification,
Lean default-argument eta expansion and a local-let rewrite; their failed logs
are retained. Source rendering against current native tokens, the inherited
literal/Character helper links and complete source correspondence remain
separate obligations. The checked generic block normalization and Character
recursion worker commit `183c24fd02` is integrated as `2fcd2e79a6` (106 jobs,
fresh 18,949-declaration worker audit; build 57.978 seconds, audit 6.703 seconds).

Source candidate ownership now sits with the lead so exact rendering can proceed
in parallel with native helper interpretation and mathematical model equations.
The semantic worker also received a bounded independent review of the unchanged
report-capacity account while awaiting those dependencies. Selected settings
remain Astra / Extra High for lead, semantic work and that critical review, and
GPT-6.1 Sol / Extra High for the native/source worker. Live model confirmation
and token/cost measurements remain unavailable. Full feature assurance, final
regressions, independent delivery review and the open feature PR are pending.


### Independent core review — 2026-10-31

The [independent core review](reviews/string-character-core-20261031.md) examined
`a351b3191d` plus checked native/helper increments `7d0ac82cda` and `48a52e7809`.
It found no confirmed runtime defect and retained the separate capacity review.
It identified [#304](https://github.com/berkeleynerd/silver/issues/304): connect
actual concatenation endpoint/grouped-intermediate safety to the generated-check
and automatic-discharge interface, including body expressions and predicates.
That connection is required assurance work within this feature, alongside the
already pending authoritative source closure. Both remain open; the feature is
not delivered or supported yet.

The reviewer was explicitly selected GPT-6 Astra / Extra High; runtime model and
effort were not independently exposed. Its read-only review interval was 278
seconds, followed by report preparation; token/cost totals are unavailable. The
initial review required a connected proof interface and independent review of
that repair. Existing successful model/helper and capacity evidence was
retained; it did not by itself discharge #304.

### Actual endpoint repair and source checkpoint — 2026-10-31

The checked repair at `06263487c2` connects actual String bounds to exact
source-derived schemas and the two public `Current` assurance theorems.
`Predicate.source_actual_string_bounds_assured` derives the initialization
bounds store and establishes complete bounds safety for every argument vector.
It covers raw String, Character and Boolean initializers in declaration order,
all reached body expressions and iterations, and every concatenation grouping.
Valid null bounds may differ from canonical metadata; the repair preserves their
null equivalence rather than assuming that all empty objects have bounds `1 .. 0`.

Focused Linux run `20261031T211333-a8facdef72ae` passed 198 jobs and freshly
audited 21,053 declarations using only the permitted foundations (build 22.425
seconds; audit 12.985 seconds). The selected Astra / Extra High reviewer accepted
L1/#304 at that exact semantic target after a 227-second review. Its
[final report](reviews/string-character-core-20261031.md) records the actual-null
case and the retained indexing, slicing and assignment-sliding argument.
Runtime model confirmation and token/cost totals remain unavailable. The checked
commits are queued for integration after the lead's captured source run ends;
the feature's full integrated validation remains required.

The source checkpoint exposed three 8 GiB kernel-memory limits and four ordinary
body render reductions in `ComposeHelperSourceCandidate`. No source mismatch
was established by those diagnostics. A scratch repair names the independent
facts and explicitly normalizes the ordinary renderers; it remains unvalidated.
Independent source targets and the native compiler proof continue with captured
inputs unchanged. Neither active run constitutes completed evidence.

The separate [delivery-consistency review](reviews/string-character-delivery-consistency-20261031.md)
found [#305](https://github.com/berkeleynerd/silver/issues/305): the concatenation
catalogue and native exporter omit slices from their operand list. Correction
and matching native validation are queued after the captured runs. The three
Rosetta drivers' surface arrays were corrected to omit `put`, since they use
`Put_Line`. Final rendering, regressions and supported-status promotion remain
pending.

### Sequence model compatibility checkpoint — 2026-10-31

The required early compatibility check after the shared parser-state changes
passed without a repair. Linux run `20261031T230322-09370004795e` checked
`Silver.SequenceModel` using one worker, two threads and a 4 GiB process allowance:
182 build jobs in 676.743 seconds, followed by a fresh audit of 25,108 declarations
in 7.124 seconds using only the permitted foundations. All 180 transitive model
source files and the audit utility matched the frozen lead snapshot at
`5c2238abf63f01f02f4e52a448217831ba60e6b7`, including its recorded dirty inputs.
The helper dependency passed in 404 seconds; no memory retry was needed.

The worker selected GPT-6.1 Sol / Extra High; runtime settings were not
independently confirmed and token/cost measurements are unavailable. A prior
setup attempt, `20261031T230215-e718712a5663`, was interrupted during preflight
after its inspection script falsely matched a documentation mention of
`include_str`. No build or source synchronization occurred in that attempt.
The successful check's exact input comparison and evidence are retained under
the native/source lane's `tmp/SequenceModelCompatibility/`. This closes the
bounded Sequence compatibility obligation; complete source/Lean and native
feature assurance remain outstanding.

### Resumed integration — 2026-11-03

The owner requested resumption of #296. The previous native run
`20261031T204137-77628df3026f` and source run
`20261031T204547-993c226abf2b` have inactive leases and no terminal completion
records. Neither is successful validation. Their original logs, reports,
captured identities and completed proof objects remain available; no toolchain
or cache was replaced. The output-body certificate has no completed object.

The reviewed #304 chain is integrated through `fef66e3379`, the #306 inventory
repair through `6fa985f467`, and the reviewed source-token/normalization patch
through `61d8ea329b`. The four patched file hashes match the independent review's
recorded outputs. Commit `6b6238d323` adds the synchronized catalogue/exporter
correction for #305 and final prepared sample/test inputs. These are stable
implementation inputs, not completed validation. The fixture-account inventory
covers seven installed-Lean tests across the retained runs; final independent
reuse review remains required.

A focused source retry uses two workers, two threads and 8 GiB per Lean process,
retaining successful dependencies. It immediately found an obsolete scratch
module comment before imports in `ComposeHelperSourceCandidate`; that syntax
repair is being checked in the isolated existing source lane while the other
certificate jobs continue. No theorem, source expectation, domain or kernel
check is weakened. The native lane will build and run the new String/Character
regressions, including dynamic noncanonical-null bounds, before its matching
full native audit. Complete whole-project Lean/source auditing and final
regression coverage remain mandatory.

This round selected GPT-6 Astra / Extra High for integration and GPT-6.1 Sol /
Extra High for native recovery and the isolated helper repair. Runtime model
confirmation and token/cost measurements are unavailable. The feature PR is a
draft while these checks remain outstanding and must remain open for owner
review after completion. #300, #297 and #298 retain their separate scope.

### Source memory diagnosis and helper repair — 2026-11-03

The focused source run `20261103T174436-6fdd4028770c` terminated as a failure
after 4,884 seconds. Its output-body certificate reported an explicit kernel
memory-limit failure at the configured 8 GiB allowance; later metavariable
diagnostics followed that failure. The already identified helper banner syntax
error was a separate failure. All runnable contract, declaration, expression,
catalogue, Character, model-assembly and native-bridge module builds completed,
but this does not establish a successful source checkpoint or fresh whole-project
audit. The [validation packet](evidence/bounded-string-characters-20261031/README.md#resumed-validation-records)
retains the original failed record and logs.

The helper repair removes only the obsolete five-line scratch comment before
imports. It changes no expected source, theorem, proof body or admission domain.
The isolated check at `389ab08bf4` passed, and integration commit `9eea1753bb`
passed run `20261103T190906-eeb647b2db40`: one worker, one thread, 4 GiB allowance,
and a fresh audit of 12,818 declarations using only the permitted foundations.
The integrated run took 346.975 managed seconds. These are focused results.

An isolated Predicate-candidate check exposed scalar and Character certificate
memory failures at 4 GiB. Those unchanged modules passed during the 8 GiB retry;
the final candidate subsequently failed as recorded below. The complete cached
Lean/source check uses one worker, one thread and 24 GiB after that dense job
ended and host headroom was checked. Historical successful output-body and
Predicate certificate records used that allowance; they do not establish a
measured memory requirement. The native full regression suite is coordinated
separately because its peak memory is unknown.

Pre-suite inspection also corrected three legacy test expectations that rejected
now-admitted fixed-bound slices and aligned exact catalogue assertions. Positive
slice coverage and out-of-bounds rejection coverage remain; the final inventory
still contains 578 methods. These test changes do not alter captured native or
Lean proof inputs. Complete validation, independent final reuse/evidence review,
Rosetta promotion and delivery remain outstanding. The selected integration and
worker settings remain Astra / Extra High and Sol / Extra High respectively;
runtime confirmation and token/cost measurements are unavailable.

The subsequent Predicate retry `20261103T182419-61bbb1c84d64` terminated after
3,683.624 managed seconds with eight explicit 8 GiB kernel memory-limit
diagnostics in its final candidate. No source-equality mismatch was reported,
and no fresh audit ran. Its failed record is retained separately. A bounded
source/tool/artifact comparison selected ordinary incremental reuse: the
Character object already matches the integration workspace, while five cheap
Scalar dependencies differ. No objects were copied or traces rewritten.
Complete cached run `20261103T192928-ecb0a9199439` started with one worker,
one thread and 24 GiB. It was intentionally interrupted for the native-source
repair described below; no memory or source-equality failure occurred in that
attempt.

### Independent installed-Lean fixture reuse review — 2026-11-03

The [bounded independent review](reviews/string-character-fixture-reuse-20261103.md)
accepts the seven retained installed-Lean fixture results at `53e2572ab4`, with
no rerun required. It inspected the actual temporary-project dependencies and
verified 50 unique input paths, including the generator omitted from the
prepared dependency inventory. Five successful methods from the failed first
run and both repaired module methods cover the seven required fixture IDs.
The first run remains failed. The review selected GPT-6 Astra / Extra High and
took 172 seconds; runtime model confirmation and token/cost measurements were
unavailable.

All 578 test IDs are unchanged. The lead inventory was refreshed after review
to capture the four later slice/catalogue test repairs, preserving the historical
inventory. Native synchronization and a refreshed exact-byte inventory remain
required before its full suite. This closes only the bounded fixture-reuse
question; final complete-suite accounting and independent delivery review remain
outstanding.

### Character progress repair and independent review — 2026-11-03

Complete native run `20261103T174729-ccb497165e31` failed after 7,483.119 seconds
with one unresolved Character declaration progress postcondition. Its failed
reports and exact inputs are retained. A larger-timeout diagnostic was
intentionally interrupted after 598.174 seconds; it is not a successful proof.
The old-source Lean run `20261103T192928-ecb0a9199439` was intentionally stopped
after 2,292.992 seconds because the repair changes its certified source.

Native commit `d7299a81a2` changes only the local declaration guard from
`Following = 0` to `Following <= State.Position`. Contracts and admission rules
remain unchanged. Scoped canonical run `20261103T200910-01915a66a688` passed all
24 checks; the matching build and all ten affected StringCharacter regressions
also passed. The complete native audit restarted as
`20261103T201920-c39bcc381ac2`, retaining ordinary native sessions and cache.

Integration `58b0d6ce2b` includes the exact typed body/equation, an equivalence
lemma over the existing valid-state domain, and corresponding source pin and
certificate data. The unchanged model already proves that successful Character
declarations advance. Focused run `20261103T202419-5f35a847709a` checked both
helper targets and freshly audited 14,821 declarations in 121 modules; its
build took 239.022 seconds and audit 3.561 seconds. Earlier failed development
attempts remain in the [focused packet](evidence/bounded-string-characters-20261031/validation/character-progress-equivalence/index.json).

The [independent repair review](reviews/string-character-progress-guard-20261103.md)
passed at that exact integration target. It checked the complete state domain,
absence of circular reasoning, generic arbitrary-callee equation, existing
consumer premises, exact native/token/certificate changes and actual focused
proof/build/test evidence. Selected Astra / Extra High review took 182 seconds;
runtime settings and token/cost totals were unavailable. Native work selected
Sol / Extra High and semantic/integration work Astra / Extra High.

Complete repaired Lean/source run `20261103T203357-33c8b5720ddd` started with
one worker, one thread and 24 GiB on the committed integration. It passed the
previous 8 GiB memory range without a diagnostic; its later interruption is
recorded below.

At 21:58 UTC the growing source certificate and native parser proof reduced
available host memory to 3.279 GiB. The native runner was gracefully interrupted
to preserve both streams' work. Run `20261103T201920-c39bcc381ac2` records
**interrupted**, exit 130, after 5,922.615 seconds with no failure keys. All
2,582 captured inputs remain unchanged; 75 partial SPARK reports and the native
proof cache are retained. There is no completed native provenance manifest or
audit claim. Source validation continued unchanged, and available memory
recovered to about 9.5 GiB after the interruption. These are sampled observations,
not measured peak requirements.

The output-body certificate subsequently passed in 5,090 seconds, releasing
that dense phase's memory. Its successful module build is retained while the
complete source build and fresh whole-project audit continued; it is not a
complete source-assurance claim. The complete native check resumed as
`20261103T220251-899976574bd0` with identical source/tool inputs and canonical
settings. Retained native work returned it to the interrupted chain-reading
frontier in 53 seconds. The matching build was reused without repetition.

The [interrupted native packet](evidence/bounded-string-characters-20261031/validation/20261103T201920-c39bcc381ac2/archive.json)
retains the exact managed record, partial reports, input identities and sampled
resource observations; every indexed archive member was hash-verified on export.
At that checkpoint the native sync matched all 886 validation inputs, all 578 test IDs
and all 50 reviewed fixture dependency paths. No captured native input changed.

The suite remains held for the remaining dense source work: its sample compiler uses
`-j0` independently of the managed test worker reservation, so that reservation
does not bound its total prover memory. Both complete checkpoints, final suite
accounting, delivery/Rosetta synchronization and independent closing review
remain required. PR #307 remains draft and open.

### Arithmetic grouping audit diagnosis — 2026-11-03

Native continuation `20261103T220251-899976574bd0` terminated after 4,638.447
seconds with all 17,404 required checks proved: 15,916 proof checks and 1,488
flow checks. Its strict audit nevertheless **failed** on seven
`operator-reassociation` warnings in `silver_output_profile.adb`. No completed
native provenance manifest was produced. The [failed packet](evidence/bounded-string-characters-20261031/validation/20261103T220251-899976574bd0/summary.json)
retains all 76 SPARK reports, SARIF, exact source and managed records.

A scratch diagnostic traversed the unchanged auditor while recording every
failed predicate instead of stopping at the first. All 35 failed predicates
concern the same seven warning records; there are no additional current audit
blockers. The diagnostic does not change the reports or acceptance policy and
is not a successful audit. All seven warnings are byte-identical to records in
the earlier failed run `20261103T174729-ccb497165e31`: its initial diagnosis
reported the sole unproved progress obligation but missed these independent
audit failures. This corrects that incomplete diagnosis.

Complete Lean run `20261103T203357-33c8b5720ddd` was intentionally interrupted at
23:29:59 UTC after 10,560.372 managed seconds because this repair changes its
certified source and the current Predicate candidate's dependencies. There was
no memory-limit failure in that run. The later full-log diagnosis below identifies
a proof-wrapper error missed by the initial monitoring. All 738 captured inputs
were unchanged at termination. Its [retained record](evidence/bounded-string-characters-20261031/validation/20261103T203357-33c8b5720ddd/index.json)
includes the successful old-source output-certificate identities, completed
build log, sampled resources and interruption rationale.

Integration `119cfa0c73` adds seven parenthesis pairs to make the intended
left-associated arithmetic explicit in fixed-bound validation, slice length and
operand counting, and concatenation endpoints. The typed model adds exactly
seven identity group nodes. Warning policy, contracts and admission rules remain
unchanged. The [scoped native packet](evidence/bounded-string-characters-20261031/validation/parenthesis-scopes/summary.json)
records 69 canonical checks passed, a matching build and all ten affected
StringCharacter regressions passed in 23.672 seconds. The two exploratory setup
failures remain failures; their corrected scoped runs supply the proof evidence.

The [model packet](evidence/bounded-string-characters-20261031/validation/parenthesis-model/index.json)
records focused run `20261103T232749-c3db83b33386`: one worker, one thread,
4 GiB, 121 modules and a fresh 14,821-declaration audit, with 597.257 seconds
runner elapsed time and 595.741 seconds registry duration. Three additional
whole-body evaluation equalities hold by `rfl` for
arbitrary callees and locals, without added validity or admission premises.
All three rendered helper bodies match the repaired pin. An initial scratch
render-tactic failure is retained; explicit unfolding repaired only that scratch
check. Production proof bodies did not change. All 121 model-module source
identities match the lead integration; its 722 compiled artifact and 1,206
metadata identities were verified on export.

Fresh diagnostic generation matches all 28 checked-in candidates. The output
specification pin still has 588 tokens; its implementation pin grows from
49,304 to 49,318 solely by the seven parenthesis pairs. These checks do not
replace complete source correspondence. Native and bounded model work selected
GPT-6.1 Sol / Extra High; independent review selects GPT-6 Astra / Extra High.
Runtime model confirmation and token/cost measurements are unavailable.

The [independent bounded review](reviews/string-arithmetic-grouping-20261103.md)
passed at `119cfa0c73`, after 211 seconds of read-only review. It checked native
intermediate bounds, exact model equivalence and rendering, all changed
certificate data, scoped evidence and final input identities. No further source
repair was identified before complete validation. Complete Lean/source run
`20261103T234536-1d74ad60229a` started on that committed target with one worker,
one thread and 24 GiB; its captured inputs remain frozen during validation.
Complete canonical native run `20261103T234601-0e070300d2d7` started with two
workers and ordinary retained solver work. Its 2,582 native inputs match the
prepared repaired-source capture and its tool identities remain unchanged.
The [complete native packet](evidence/bounded-string-characters-20261031/validation/20261103T234601-0e070300d2d7/summary.json)
records success after 87.226 managed seconds: all 17,404 checks, complete strict
report audit and provenance passed, covering 76 units and 1,099 entities, with
no reassociation warnings. This reused the retained solver work; it is not a
clean build or proof run. Every one of its 256 indexed archive members was
hash-verified on export. The matching build and ten affected regressions remain
applicable without repetition.

The final three Lean-file sync is outside the native input set and preserves
its complete provenance. All 578 test IDs and 50 test-file hashes match the
lead; the seven retained fixtures' reviewed 50-path dependency closure is
unchanged. This establishes applicability, not execution of the pending full
suite. Complete Lean/source assurance, full regression accounting and final
delivery review remain required. The suite is coordinated separately from dense
source validation.

### Source-wrapper diagnosis — 2026-11-04

The repaired-source output certificate passed in 3,530 seconds inside run
`20261103T234536-1d74ad60229a`. All five Compose source candidates and
`OutputSourceBridge` subsequently passed. The complete build then exposed a
proof-wrapper error in `ComposeSourceChecks.actual_string_helpers`: its rewrite
could not find `Source.outputBodyTokens` behind the `StringHelperTranslation`
abbreviation. This is a failed module in the still-running complete build, not
a successful complete checkpoint.

Full-log inspection found the same error in the earlier interrupted run
`20261103T203357-33c8b5720ddd`. The initial last-line monitoring missed it.
The [historical correction](evidence/bounded-string-characters-20261031/validation/20261103T203357-33c8b5720ddd/diagnostic-correction-20261104.json)
preserves that distinction and the original records. Monitoring now scans every
new diagnostic line. The old run remains interrupted, with a failed module and
retained successful objects.

The checked repair adds only
`change StringHelperTranslationFor Source.outputBodyTokens` before the existing
rewrite. An exact scratch copy of the entire module passed run
`20261104T011006-21d49eb8b36b`, followed by a fresh audit of 61,362 imported
dependency declarations (the scratch module itself was outside the audit prefix),
in 5.864 seconds at 4 GiB. The [packet](evidence/bounded-string-characters-20261031/validation/translation-unfold-20261104/index.json)
retains the exact one-line patch, source/artifact identities and audit. Theorem
statements, native source and all other production bytes are unchanged.

The production proof edit is queued until the active build releases its captured
inputs. The remaining Predicate candidate's dependency closure excludes this
failed wrapper, so its useful expensive work continues with unchanged inputs.
After applying the checked proof-body repair, complete cached validation and a
fresh whole-project audit remain required. Native assurance remains applicable
because its captured inputs are unaffected.

### Source-consumer integration — 2026-11-04

The preceding source-wrapper subsection records the earlier active checkpoint.
Run `20261103T234536-1d74ad60229a` has now terminated as **failed** after
8,873.154 managed seconds. The final-source output certificate passed in
3,530 seconds and `PredicateSourceCandidate` in 2,291 seconds. Its only failed
modules were the wrapper and `ComposeExamples`, whose seven old positional
`BindingInfo` constructors omitted the new fields. All 738 captured sources
remained unchanged; both heavy modules' 32 artifact identities were retained.

Commit `f9a14a33cb` integrates the checked wrapper line and named example
records. The records preserve their original six field values, identify Strings,
and give the fixed two-byte snapshots bounds `1 .. 2`. The subsequent complete
run `20261104T021449-9b50164c6ab4` passed both modules, including the examples
in 186 seconds, but failed `ComposeSourceBridge` on missing existing state-domain
conversions. Commit `f4d1bf10ec` repairs only those proof applications with
`NativeState.base` and the already-proved `ValidState.nativeState`; all theorem
statements and interpretation domains remain unchanged.

The exact bridge scratch module passed its kernel check. Its 90,013-declaration
fresh audit, like the earlier 61,362-declaration scratch audit, covered imported
Silver modules only: both scratch module names lacked the `Silver` prefix used
by the auditor. This [scope correction](evidence/bounded-string-characters-20261031/validation/translation-unfold-20261104/audit-scope-correction.json)
preserves the original records. A [fresh audit of the actual built modules](evidence/bounded-string-characters-20261031/validation/actual-bridge-audit-20261104/index.json),
run `20261104T022217-ca81f59945a3`, includes both repaired modules and all their
Silver dependencies: **90,061 declarations in 300 modules**, 4.530 seconds,
with all 5,079 captured identities unchanged and only permitted foundations.
This closes the bounded audit-scope gap; it is not a whole-project result.

Complete cached run `20261104T021852-a9ce2c35192f` passed the bridge and
`PredicateSourceChecks` but failed the next consumer, `PredicateInheritedReady`,
on state-domain forwarding. The bounded repair thread selects GPT-6.1 Sol /
Extra High and owns a scratch proof only; runtime settings and token/cost data
are unavailable. It must preserve every theorem header and forward the existing
String/Character helper witnesses. The failed runs and exact packets are retained
in the [validation index](evidence/bounded-string-characters-20261031/README.md).
Native source, pins and generated certificates remain unchanged, so the native
complete proof remains applicable. Complete source/fresh audit, final regressions
and closing review remain required.

### Complete Linux source assurance — 2026-11-04

The inherited forwarding repair is integrated at
`90e9f4226835c53601050eb163b842d9aadf4444`. Its
[focused packet](evidence/bounded-string-characters-20261031/validation/inherited-state-repair-20261104/index.json)
retains the exact module, six unchanged theorem headers, 90,451-declaration
audit across 311 modules, all 6,038 captured identities and both import-setup
failures. The source-domain and String-bound witnesses are preserved, and the
eight existing String/Character helper equations are forwarded without changing
any public theorem statement or interpretation assumption.

The [complete cached source checkpoint](evidence/bounded-string-characters-20261031/validation/20261104T022554-32f68afc7380/summary.json)
**passed**: all **623 modules**, followed by a fresh audit of **128,840
declarations** using only `propext`, `Classical.choice` and `Quot.sound`.
Build time was 16.700 seconds and audit time 4.515 seconds; the managed duration
was 30.083 seconds, evidence-runner duration 31.354 seconds, and supervisor
duration 31.537 seconds. These timings cover different recorded boundaries.
This is an ordinary cached complete check, not a clean build or independent
`leanchecker` replay. The successful final-source certificates were reused.

The lead independently matched all **738 authoritative inputs, 625 workspace
inputs, two tools and 3,742 artifacts**, plus the retained 32 identities of the
heavy output and Predicate candidates. The earlier scratch static dependency
inventories omitted the meta-only `Silver.CertificateWitness` from their
identity captures; their audits did include it. This complete checkpoint
captures and verifies the full module/provenance closure, including that
module. It also covers every production proof declaration excluded by the
earlier scratch naming mistake. Original failed and partial records remain
unchanged.

Native source and scripts still match the successful native checkpoint at
`119cfa0c73`. The native lane is authorized to synchronize the four later Lean
files, refresh the exact fixture applicability and run the final 578-method
suite. Final regression coverage, Rosetta delivery promotion and independent
closing review remain outstanding; PR #307 stays open.

The [independent bounded source-integration review](reviews/string-source-integration-20261104.md)
passed at evidence checkpoint `93a14bbb15`. It confirmed the four-file delta,
preserved native domains and general assurance statements, complete audit and
provenance closure, and the honest disposition of earlier audit scopes. The
review distinguishes the three concrete example statement updates from the
unchanged general bridge/domain theorem headers. Final full-suite accounting
and synchronized delivery records still require the closing review.

## Delivery assurance and validation

Implemented, validated and reviewed on Linux on 2026-11-04, with
[PR #307](https://github.com/berkeleynerd/silver/pull/307) open for owner review.
The dated sections above preserve development history, including failed and
interrupted attempts. This section records the final delivery state.

The fragment admits printable-ASCII Character literals, initialized scalar
objects, assignment and typed comparisons; fixed-bound String indexed reads
and element writes; and bounded slices in String expressions. It preserves
actual lower bounds, noncanonical and null slices, assignment sliding,
evaluation before mutation and snapshots. The existing 4,096-byte source,
63-operator and 64-leaf limits remain. Dynamic-length indexing, Character
concatenation, slice targets, resizing, Unicode and general libraries are
outside this increment.

The governed implementation/proof target is
`90e9f4226835c53601050eb163b842d9aadf4444`. Later delivery changes update
records and Rosetta rendering. The native implementation and native proof
inputs remain identical to `119cfa0c73389d461f8e5bd6de465ed2fee7d368`.

| Evidence | Final result and scope |
| --- | --- |
| [Complete native proof/audit](evidence/bounded-string-characters-20261031/validation/20261103T234601-0e070300d2d7/summary.json) | 17,404 checks: 15,916 proof and 1,488 flow; 76 units, 1,099 entities, complete strict report audit and provenance. Retained solver work was reused. Matching build `20261103T233404-d80bccc33dbc` and ten affected StringCharacter methods in `20261103T233411-962e761487e2` passed. |
| [Complete Lean/source check](evidence/bounded-string-characters-20261031/validation/20261104T022554-32f68afc7380/summary.json) | 623 modules and a fresh audit of 128,840 declarations, only the three permitted foundations. All 738 authoritative inputs, 625 workspace inputs, two tools and 3,742 artifacts matched. This is a cached complete build and fresh audit, not a clean build or independent replay. |
| [Completed full suite](evidence/bounded-string-characters-20261031/validation/20261104T023444-fd55f0e35ffc/summary.json) | The run remains **failed**: 570 passes, seven expected installed-Lean skips and one Rosetta renderer error. All 59 manifest samples and every StringCharacter test passed. Exact final input applicability is retained. |
| [Final Rosetta check](evidence/bounded-string-characters-20261031/validation/20261104T030336-2d76f7fc2ec7/summary.json) | All three methods passed after adding the missing renderer admission-table entry and promoting/rendering only the bounded identifier. This replaces the two earlier Rosetta passes and its error. |
| [Final method accounting](evidence/bounded-string-characters-20261031/validation/final-regression-accounting-20261104/summary.json) | All **578 unique methods** are covered: 568 applicable full-suite passes, three final Rosetta passes and seven independently reviewed retained installed-Lean results. No required method is missing or unresolved. |

The seven installed-Lean results use five applicable successful methods from
failed run `20261031T214130-1e0195247bd5` and both repaired module methods from
successful run `20261031T215153-7280a74a41c2`. Their
[independent reuse review](reviews/string-character-fixture-reuse-20261103.md)
and final dependency comparison establish applicability. The failed run remains
failed. Final Rosetta tests replace the corresponding earlier suite results;
method coverage is not double-counted.

The [complete source-integration review](reviews/string-source-integration-20261104.md)
accepted the final four proof-file repairs and complete source evidence at
`93a14bbb15c40a7c27a0eeee494fc1bca911716a`. It preserves the earlier accepted
capacity, actual-bound, helper-inventory, progress and grouping reviews. The
[closing regression and delivery review](reviews/string-delivery-closing-20261104.md)
passed at `9111fbf88be337214278f185501d2f9de1761442`, confirming final method
accounting, task correspondence, rendered support and synchronized delivery
records. Follow-up changes record review completion and publication status only.
The bounded scratch-audit
scope corrections are retained; the complete project audit and provenance
include every production proof module and the meta-import closure.

Findings #304, #305 and #306 are resolved in this delivery: source-derived actual
String endpoints reach the discharge guarantee; the catalogue and native
exporter include slice operands in concatenation; and the consumed helper
inventories include all seven bodies with precedence and identifier scope.
Their original review records and failed attempts remain available.

Rosetta promotes only `bounded-string-characters` for the three faithful
reversal, palindrome and selective-replacement drivers. The bounds/sliding
sample is additional regression coverage, not another task gain. Broad
`characters`, `string-indexing`, arrays and callable routines remain separate.
Stage issues #11/#12 remain Open/Backlog at their final rendered positions;
#296 records the narrow feature mapping. Milestone 16 and the feature issues
remain open pending owner-authorized merge. No later feature or Oracle change
is selected. macOS validation remains independent of this Linux delivery.
