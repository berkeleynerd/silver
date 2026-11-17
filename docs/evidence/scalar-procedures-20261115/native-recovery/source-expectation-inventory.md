# Remaining source-expectation inventory — 2026-11-15

**No new observed failure or required preflight repair was identified.** The
complete checkpoint can proceed. This is a map for a bounded diagnosis or repair
if an actual subsequent failure selects one of these consumers; it does not
authorize speculative production changes or #373 work.

The inventory is frozen at **`7fa2549f82e679359795e799482f0461ed6eaaf7`**:
**1,002 project modules**, plus `lakefile.lean`. Static imports from `Silver`
reach 999 modules; `Silver.Audit` reaches all 1,002. The accepted Boolean repair
`46c849d81` / integrated `7064c1863` adds the **1,003rd current project module**;
I also checked that the resulting static `Silver.Audit` closure reaches all
1,003. Neither static closure is a fresh whole-project audit result.

## Method and retained success

Exact committed blobs were read through `git cat-file --batch`. The scan masks
nested Lean comments and literal contents before associating ordinary literal
arguments with `expectedTokens`, `lexLine`, `compilerSource`, or `.toList` and
their enclosing declarations. It found **544 direct source-lexer expectations**
(492 `expectedTokens`, 52 `lexLine`) and **189 direct `.toList` occurrences**.
The [JSON inventory](source-expectation-inventory.json) retains all **733** rows,
sizes, literal hashes, source identities, statuses and detailed consumer paths.
It also records duplicate occurrences separately. Computed/aliased strings and
generated workspace certificate text are outside this committed-source scan.

The table below uses **400 characters only as a display filter**. It contains
43 occurrence rows / 38 distinct source literals in 16 definition modules after
excluding the matching audited modules. There is no proved length or memory
threshold. The 221 cached objects observed at the recorded timestamp are a
volatile cache inventory, not proof of consumer success or failure.

The retained **Function caller** run `20261115T182909-e353e1507833` covers
197 modules / 17,516 declarations. Its audited sources match both the inventory
snapshot and current files. The **output certificate** run
`20261115T183635-e890328a97c4` covers 17 modules / 51,104 declarations; its
handwritten sources match, and its nine generated modules match the current
workspace evidence. Both records' source/script inputs and actual Lean/Lake
hashes match current files. Their unchanged successful work should be reused.

The separate accepted **Boolean/helper** run
`20261115T185653-905487da1ee4` covers 104 modules / 14,576 declarations and is
reviewed in [the Boolean report](review-boolean-header-memory.md). Its two-file
repair intentionally postdates this inventory snapshot. A definition's presence
in an audited closure is insufficient to establish a later computation: the
Boolean declaration definition was already imported by the Function caller
before its separate helper consumer failed. Only the later complete helper
success establishes that consumer.

## Prospective bounded groups

All modules in this table are under `Silver`. Sizes describe individual literal
fragments, not necessarily the whole assembled expectation. No displayed group
had an observed failure or completed cached consumer at the inventory check.
Each exact consumer and its static path from `Silver.Audit` is in the JSON.

| Definition / expectation | Characters | Concrete consumer and complete follow-up |
| --- | --- | --- |
| `ComposeDeclarationSourceCandidate` facts `_11`, `_17`, `_18`, `_21`, `_22` | 650, 555, 539, 435, 922 | Same module: exact record, declaration and expression facts, then complete `candidate_declarations`. The five texts also occur in `DeclarationsFor`; those repeats are not additional failures. |
| `ProcedureNameSource.headers` and `loopBody` | 449, 420, 451, 677 | `ProcedureNameSourceParts.StepSpec.header_0`, `ModelSpec.header_2`, `LoopSpec.header_4`, `Loop.loop`; then complete `ProcedureNameSourceCandidate.checked`. |
| `ProcedureDeclarationHighSource.metadataAppendHeader` | 646 | `ProcedureDeclarationHighSourceParts.Body.metadata_append_header`, together with its existing `ordinary_0`; then complete `ProcedureDeclarationHighSourceCandidate.checked`. |
| `PredicateNativeSourceChecks` long specification headers | 571, 701, 705, 948, 709, 729, 737 | `PredicateCharacterSourceCandidate.character_spec` computes the character header; `PredicateNativeShapeCandidate` computes the other six and assembles complete `checked`. |
| `PredicateSourceRequirements`: body tail, read body, context record, valid context, body-tail model, valid flow | 633, 632, 424, 762, 712, 470 | Six exact `PredicateBodySourceCandidate.candidate_*` facts, then every field of its complete `checked`. |
| `PredicateCountedBoundSource.spec`, `PredicateFlowReaders.scalarSpec`, `PredicateFlowSourceBridge.joinedHeader` / `lemmaJoinIdentityHeader` | 601, 480, 776, 433 | `PredicateFlowSourceCandidate.counted_bound_checked`, `native_flow_checked`, `native_readers_checked`; complete contracts and candidate `checked`. |
| `PredicateNativeScalarHelpers.Checked` and `PredicateNativeWorkers.chainSpec` | 522, 544, 550 | `PredicateNativeHelpersCandidate.native_scalarHelpers_checked` and `native_workers_checked`; complete `checked`. |
| Boolean-array, Boolean and scalar `assignmentSpec` definitions | 437, 413, 409 | All relevant namespace-specific `candidate_checked` proofs in `PredicateScalarBodyCandidate`, preserving all four complete body contracts. |
| Function and Procedure bindings `Headers` | 445, 432; 450, 438 | Each `FunctionBindingsSourceChecks` / `ProcedureBindingsSourceChecks.actual_headers` and complete `checked_source`. |
| `OutputSourceBridge.RuntimeDeclarations` | 402 | Complete `actual_runtime_declarations` and `checked_source`. The current proof uses reflexivity; this is an exposure to literal decoding, not a claimed `decide +kernel` failure. |

The direct Compose declaration facts are the clearest small group if a failure
selects that module. Procedure name leaves are already separated by header/body;
the metadata helper shares a module with a complete ordinary-body obligation.
Predicate native headers, body requirements, flow contracts and scalar helpers
are separate consumers and should retain those boundaries. The JSON gives the
exact local theorem names rather than treating a broad parent import as the
place where computation occurs.

## Constraints on a later repair

The established mechanism is literal decoding through `String.toList` followed
by the unchanged compiler alphabet, fuel and lexer. If the next actual diagnostic
confirms this mechanism, preserve every original public/private statement,
complete source input, singleton selector, domain and contract field. Any new
normalization must prove the exact character list and full unchanged lexer
result in the kernel before rechecking the affected complete consumer.

Several expectations interleave token-list fragments with semantic renderings.
In particular, `joinedHeader` includes several short expectations and rendered
RHS terms before its 776-character suffix; body-tail/read-body headers concatenate
a literal prefix, a rendered semantic term and a suffix. Preserve every append
and rendered expression. A Procedure-name loop check must retain the complete
ordinary body. Long explicit token lists in existing helper candidates are
outside this string-decoding inventory and are not grounds for the same repair.

The two newly noticed long direct `.toList` samples in `ComposeExamples`
(`exampleSource`, 517 characters; `copiedBranchSource`, 505) feed Silver program
admission examples. They are recorded separately from compiler-source lexer
expectations and do not establish universal assurance or a required repair.

Keep exact failed diagnostics and matching successes. Check each new helper's
complete contract and affected full callers before another expensive integrated
checkpoint, using current managed resource reservations. Reuse matching earlier
successes rather than repeating the Function caller or output certificate for
inventory purposes. No numeric capacity guarantee, global lexer change, weaker
selector/domain/obligation or new trusted computed result follows from this map.

## Handoff

The selected review setting was GPT-6 Astra / Max; live telemetry is not
independently exposed. Only read-only extraction and evidence writing were
performed. No Lean/native proof run, production/cache mutation, GitHub write or
CLI memory update was made; the live harness goal was null. Native monitoring
remains with its designated owner. The lead and author received the concrete
consumer map while the complete checkpoint continued.
