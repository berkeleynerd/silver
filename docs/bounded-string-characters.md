# Bounded String indexing and character operations

Status: owner-authorized on 2026-10-31; implementation and source-proof integration in progress.
[Milestone 16](https://github.com/berkeleynerd/silver/milestone/16) contains one
work package, [#296](https://github.com/berkeleynerd/silver/issues/296).
The [authorization](session-memory.md#2026-10-31--bounded-string-indexing-and-character-operations-authorized)
covers the complete implementation, assurance, review and feature PR delivery.
This feature branch does not yet claim completed support.

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
its final candidate and fresh audit remain pending. The next complete cached
Lean/source check is planned with one worker, one thread and 24 GiB after that
dense job ends and host headroom is checked. Historical successful output-body
and Predicate certificate records used that allowance; they do not establish
a measured memory requirement. The native full regression suite will be
coordinated separately because its peak memory is unknown.

Pre-suite inspection also corrected three legacy test expectations that rejected
now-admitted fixed-bound slices and aligned exact catalogue assertions. Positive
slice coverage and out-of-bounds rejection coverage remain; the final inventory
still contains 578 methods. These test changes do not alter captured native or
Lean proof inputs. Complete validation, independent final reuse/evidence review,
Rosetta promotion and delivery remain outstanding. The selected integration and
worker settings remain Astra / Extra High and Sol / Extra High respectively;
runtime confirmation and token/cost measurements are unavailable.
