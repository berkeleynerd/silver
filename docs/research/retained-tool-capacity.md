# Capacity contract for the retained tools

**2026-10-18 — design checkpoint; derivation unfinished.** The owner
[selected the unchanged-toolchain direction](../session-memory.md#2026-10-17--retained-tool-capacity-direction-adopted)
in [decision #117](https://github.com/berkeleynerd/silver/issues/117).
This [#119 work package](https://github.com/berkeleynerd/silver/issues/119)
supports the unfinished #91/#93 capacity derivation.
Retain GNAT/GNATprove and account for their representation limits before
admission. No compiler fork, external adoption or replacement frontend is a
prerequisite. This contract specifies the missing derivation; it supplies no
new membership rule, numerical aggregate cap or enlarged supported language.
The [current language](../../language.md) remains authoritative. The earlier
[research result](frontend-representation-result.md) retains its technical facts;
its preferred ownership route is superseded by the owner's decision.

## Inputs and required conclusion

The proposed capacity analysis takes the authoritative source bytes, their
recognized grammar and semantic summaries, the selected dependency bytes, and a
fixed tool/target/options configuration. It must terminate without compiling or
proving the program to decide membership. It must not replace the author source,
materialize huge constants merely to measure them, or use tool success as its
acceptance predicate. Silver-owned implementation and its source-correspondence
and composition arguments remain subject to the [Oracle](../../oracle.md).

For each relevant tool phase, compute an upper bound on every reachable finite
representation and every intermediate arithmetic operation that constructs it.
The eventual rule accepts only when these bounds fit that phase's justified
capacities. Its soundness obligation is: under the explicit source/tool and
environment premises, every source passing the rule avoids representation
overflow throughout the selected build and all assurance-essential production
paths. This is separate from semantic safety, complete obligation generation
and automatic discharge; those guarantees still need their existing arguments.

The bound concerns tool representation, not available RAM, disk or elapsed time.
Physical resource exhaustion can still interrupt a permitted operation. A
representation failure on admitted source remains a defect. An analysis read
or allocation failure is an operational failure, never a membership rejection.

## Phase and cost model

Keep separate budgets for separate processes; do not sum allocations across
processes that have distinct tables. Within a process, retain phase order and
lifetime: a final live count does not bound peak allocation or growth arithmetic.
Each component records initial state, allocation/retention/release transfers,
peak demand, growth requests, intermediate arithmetic and its representation.
Deduplication or reclamation reduces a charge only with a justified invariant.
The accounting algorithm must itself avoid overflow, with proved checked or
saturating arithmetic that preserves every acceptance/rejection decision.

| Phase | Required accounting |
| --- | --- |
| Lexing/parsing | Physical source buffers and ranges, lines, names, lexical Strings, numeric spelling and retained/temporary Uint data; parser nodes and lists |
| Resolution/static evaluation | Constant folding, generated subtypes/checks, names, nodes/slots/lists, String descriptors/characters and numeric work |
| Expansion/build frontend | Selected runtime units, virtual generic/inlined source ranges, copied trees, branch and concatenation expansion, Image support and final lock headroom |
| GCC emission, binder/linker | Materialized constants and generated objects, option-specific encoding/terminators, finite object/relocation/section representations and dependency closure |
| GNATprove frontend/producer | Its own source/semantic/expansion costs, generated Why nodes/lists/identifiers and literal arrays, Image translation and all required obligations |
| Confirmation reporting/audit | Report serialization, identifiers, nesting and retained artifacts; separate essential production from reporting-only limits below |

The frontend cost vector includes aligned source extents; line-table capacity;
name entries/characters; nodes/slots/list links; String descriptors/characters;
Uint entries/digit words; and growth/lock headroom. This is an initial inventory,
not evidence of exhaustiveness. Add every reachable representation found during
closure, including auxiliary tables and counters. Nominal ID ranges, backing
table index ranges, allocation sizes and growth limits are different quantities.

Composition must carry retained state between ordered declarations/statements,
with temporary peaks inside operations. Both branch arms may consume compiler
storage regardless of runtime reachability. Runtime loop trip counts are not
automatically compiler allocation multipliers; actual transformations determine
the charge. Scope exit does not imply compiler storage release. A conservative
transfer can overcount, but its loss of useful admitted programs must be assessed.

## Reusable source-position component

The [pinned-source investigation](unbounded-source-capacity.md#physical-and-virtual-source-positions)
already establishes the following recurrence for the ordinary aligned source
ranges. Let `s_i` be a range's start and `e_i = Source_Last - Source_First`
its nonnegative extent, including the tool's actual buffer/EOF convention:

```text
align(e) = 4096 * ceil((e + 1) / 4096)
s_(i+1) = s_i + align(e_i)
final_last = s_0 + sum(i < n - 1, align(e_i)) + e_(n-1)
```

Use the actual ordered range inventory and initial cursor. Virtual copies count
even when they share physical text. Do not substitute physical byte lengths
without establishing their mapping to source extents. The
[retained reconciliation](../evidence/unbounded-programs/feasibility-20261017/continuation/planning/source-position-reconciliation.json)
checks the recurrence on seven earlier traces, not all production paths.

Conditional arithmetic component: if the inventory is complete, extents have
the stated interpretation, and `final_last <= Int'Last - 4096 = 2,147,479,551`,
the recorded alignment and source-index block increment have the required
signed-Int headroom. This reuses the source-derived sufficient condition; it is
not an observed maximum or assurance for source buffers, line tables, allocation
bytes or every source-pointer operation. Those are separate obligations. No
proof assistant was run for this checkpoint and no new theorem is claimed.

The first concrete derivation must close that inventory for actual build and
GNATprove phases: selected library/runtime bytes, generated sources, generic and
inline copies, loading order, multiplicities and the effect of each grammar
operation. The existing semantic-only and `-gnatdx` traces are discriminators,
not a complete production invocation. A runtime or invocation change invalidates
the affected closure even if the author grammar is unchanged.

## Complete grammar obligations

The current derivation has seven reusable component groups:

| Component | Established contribution | Still required for whole-source capacity |
| --- | --- | --- |
| [Source ranges](retained-source-closure.md), [fixed support](retained-fixed-support.md) | Physical-loader inventory, runtime union, grammar-to-helper seed coverage and conditional virtual-template/binder-source bounds | Effective invocation/search premises and source/tool correspondence; helper AST/value/backend costs are separate |
| [Values and parsing](retained-value-capacity.md) | Main lexical/static String totals, at most two scans per literal/identifier, scanner nodes including colon-numeral diagnostics, local Uint arithmetic and range-query costs | Fixed dependency parsing, generated value events and query multiplicities |
| [Tables and nodes](retained-table-capacity.md) | Allocator demand envelope, Main line/column/name charges, qualification/homonym transfers, exact node layout and slot/list coupling; complete ordinary parser constructor transfer and source-sensitive/uniform comparison | Complete generated-scope/name caller coverage, semantic slot/list/value demands and remaining auxiliary representations |
| [Main entities](retained-frontend-entities.md), [Main semantics](retained-main-semantics.md) | Source-sensitive entity/type/literal and conditional node-identity bounds; complete reached Main semantic numeric partition; slots/lists/scopes, elaboration auxiliaries, overload/warning and source-binding xref counts; Main diagnostics, saved-check/dimension resources; fixed unit-count and unit-boundary element-list bounds; audited fixed Main light lifetime vector and four separate fixed library node/entity domains | Variable corrections to fixed captures, later producer queries, producer/output diagnostic consumers, driver/loader auxiliaries and whole-process composition |
| [Native expansion](retained-native-expansion.md) | Composed Main constructor vector for parser/scanner nodes, scalar operations, loops, Integer/String stores, standalone literals, predicates, Image, calls and concat; source-derived query/digit bounds; complete fixed witness with runtime-freeze/first-lookup residue; native overload, qualified-name, xref and unit-boundary Elist transfers; invocation/elaboration/ALI, native diagnostics and scope/check/expander stack peaks | Fixed-input corrections and source-reduced metadata inputs, scanner pools, remaining auxiliary stacks/tables and backing arithmetic, backend backannotation and whole-process composition |
| [GNATprove producer](retained-producer-capacity.md), [composition](retained-producer-composition.md), [control](retained-producer-control.md), [objects](retained-producer-objects.md), [calls](retained-producer-calls.md), [fixed setup](retained-producer-fixed.md), [storage](retained-producer-storage.md), [numeric values](retained-producer-numerics.md), [undo peak](retained-producer-undo.md), [generated strings](retained-producer-strings.md), [output consumers](retained-producer-tail.md), [response schema](retained-producer-response.md), [final splitting](retained-producer-splitting.md), [unfolding and rewriting](retained-producer-postsplit.md) | Ordinary Main transfer and wrapper; fixed dependencies/processes; Why/Common intern-request bounds; field-aware serializer weights; numeric bound `d=40` and reusable decimal scratch; scoped undo peak and generated string-field lengths; composed Main and four separate fixed-library core/map/undo domains; structural imports, top-level-region shape and Integer-specific expression bounds; VC-registration/PID/claim cardinalities and explicit useful-region comparison; coupled reporting/statistics narrowing and proposed private driver configuration with exact import/deletion checks; conditional response schema, fixed timing names, marked-unfold/rewrite occurrence bounds and final-split list-count transfer | Source-to-terminal-goal count, diagnostic bytes and upstream Why3 representations, complete report consumers, third assumption symbol-pool lifetime calls, essential tail bounds, remaining conservative field losses and actual configuration/behavior premises; proposed driver resolution/behavior still needs native validation |
| [Gigi bridge](retained-backend-gigi.md), [native backend](retained-backend-capacity.md), [initial CFG](retained-backend-cfg.md), [ELF linker](retained-linker-capacity.md) | Whole-file line maps and backing growth, GNAT-node association arrays, ordinary Main Character String lowering events and O0 emission; scalar/check/store/call/declaration/type/conversion/allocator interfaces; constant-pool labels, deferred requests, hash growth/probes and RTL offsets within the 32-bit alignment-mask region; heap/GC vectors and pseudo-register backbones; block-operation transfers and large-copy fallback; binding/cleanup/CF/EH transfers including simple cleanup operand copies; initial CFG/vector/discriminator counts; ad-hoc location backing/hash arithmetic; bounded-precision Integer constants/caches and constant-only scalar folds; scalar/pointer type constructors/layout; initial CFG cleanup and loop containers with dominator/splay counter inequalities; ELF name offsets/lengths/refcounts and BFD hash allocation arithmetic | Weighted gigi input and type/layout joins; symbolic/complex folding and general copies; GENERIC/GIMPLE/RTL composition and later SSA/RTL stages and remaining matcher/allocator joins; all-phase ad-hoc entry count and other GCC representations; generated symbols/references, code/data/frame, assembler and relocation/layout closure |

These are source-derived components with their own premises and review scope.
They do not yet select a safe whole-program threshold or unlock production
admission changes. The independent literal-scan and generic-table envelope
reviews, and the [entity/scalar review](../reviews/review-retained-entity-producer-e00109d8a8.md),
cover their named frozen components. The
[later frontend/native review](../reviews/review-retained-capacity-components-63b0c9671f.md)
and [producer review](../reviews/review-retained-producer-4073ab0820.md)
found no material issue in their respective frozen targets. The
[2026-10-18 component review](../reviews/review-retained-components-0cd5b74cc7.md)
also found no material issue in the fixed support, control/object/call,
type-completion/array-representation and name transfers at `0cd5b74cc7`.
Its exclusions include later executable-loop and generated-declaration work.
The [producer/parenthesis review](../reviews/review-retained-producer-5d4fd26cbb.md)
checks those producer additions through `5d4fd26cbb`. Its low inventory
finding [L1/#122](https://github.com/berkeleynerd/silver/issues/122) is repaired
in `b6061a8458` and independently verified: the missed call preserves the old
parenthesis count, so the capacity formulas are unchanged. The later
[Main aggregate review](../reviews/review-producer-aggregate-febe64076e.md)
checks producer composition at `febe64076e`; the
[parser/scanner review](../reviews/review-parser-scanner-b391e324ff.md)
checks auxiliary and scanner contributions at `b391e324ff`. The ordinary parser
constructor aggregate is later and outside that review. The
[native scalar review](../reviews/review-retained-native-cbcd679320.md) and
[native action review](../reviews/review-native-delta-26b438ab5c.md) cover their
frozen local transfers through `cbcd679320` and `26b438ab5c`; later allocator
declaration work remains outside them. The
[backend review](../reviews/review-retained-backend-2324105a9b.md) checks the
line-map, Character String and O0 emission transfers at `2324105a9b`.
These reviews do not
establish complete soundness of the integrated predicate or later additions;
the review reports specify the included and excluded components.

Every grammar production and permitted composition needs a transfer with pinned
source references or a justified reduction to another transfer. A coverage table
must include the following families and their generated support, not just samples:

| Grammar family | Required discriminators and transfers |
| --- | --- |
| Trivia, context clauses and names | Bytes versus expanded columns/lines; repeated clauses; identifier spelling; generated/internal names and dependency selection |
| String literals, references and concatenation | Decoded length, static versus dynamic values, copies, left-tail sharing where justified, folded intermediates and all materialization sites |
| Integer literals and scalar expressions | Base/exponent spelling, separators, unary/binary operations, retained powers, arithmetic temporaries, static evaluation and generated numeric bounds |
| Declarations and assignment | Ordered environments, mutable/constant status, ranges, initializers, copies, checks and branch-sensitive semantic facts |
| Conditions and branches | Comparisons, path facts, Boolean combinations, both translated arms, condition actions and generated control-flow nodes |
| For loops and nesting | Bound capture, reverse/null ranges, index scope, nested expansion and generated checks under the selected unrolling options |
| Image and selected library calls | Actual support-unit/template closure, argument/output paths, producer translation and object/report effects |
| Shell and composition | Null/static/argument selection, sequencing, permitted cross-feature interactions and fixed plus source-dependent support costs |

The [String/Uint lifetime audit](unbounded-frontend-lifetimes.md) supplies useful
constraints: ordinary String folding has no semantic-phase collection; tail
sharing can reduce one chain's cost; distinct live values need distinct character
ranges; zero-valued exponent literals can retain large powers. These are not
upper bounds for all generated values. Do not charge only final String lengths
or final Integer intervals. The [expansion gaps](unbounded-source-capacity.md#candidate-comparison-and-remaining-obligations)
include concat helpers, condition actions, tree copying and generated subtypes.
For every allocation route, identify its caller coverage, bounded multiplicity,
growth arithmetic and release premise; an unexplained multiplier is unfinished.

## Producer limits and correspondence

An assurance-essential producer representation is one needed to generate the
complete obligations or perform their required discharge. A known hard limit
there cannot be waived by making per-program confirmation optional. Its capacity
must be covered for the admitted domain, or another complete automatic assurance
route must be established under the unchanged Oracle before enlarging that domain.

A reporting-only limit may interrupt corroborating confirmation without changing
membership only when it cannot prevent or alter complete obligation generation
and automatic discharge, and the assurance argument does not rely on the failed
operation. Establish that separation and a reliable diagnostic before
classifying the outcome as incomplete confirmation. Never call an incomplete
run confirmed; retain the complete strict report audit for that claim. Existing
[named confirmation limits](../unbounded-programs.md#confirmation-only-tool-limits)
are not automatically universal membership caps, and their classification does
not dispose of a newly discovered essential producer limit.

The inspected gnat2why path constructs predicates/nodes per literal character;
the [30-bit node obstruction](frontend-toolchain-feasibility.md#string-consumers-and-producer-growth)
is a lower-bound argument for a literal reaching that path. It is not a safe
String threshold, exact installed-tool cutoff or complete producer cost model.
That path allocates proof structures and is proof-essential under the recorded
source premise. Its connection to the installed producer and complete capacity
accounting remain unresolved; neither a frontend-pool bound nor a report-size
rule supplies them.

The GCC baseline is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
The inspected SPARK snapshot is `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`;
its identity as the installed archive's source is **not established**. GNATprove
builds a separate embedded frontend. Record exact relevant source/tool relations,
selected packages, host/target, options and support inputs for each path; source
inspection cannot silently transfer to a different executable. Follow existing
correspondence premises without introducing unsolicited binary attestation work.
Linux is primary; native macOS evidence is independent and nonblocking.

The [focused source-identity investigation](retained-tool-source-identity.md)
corroborates the selected archive digest, recipe and matching Linux build/upload
job, but leaves the historical floating SPARK/sparklib downloads unidentified.
The job logs have expired and no build artifacts remain in that run. Today's
branch target and its commit date cannot establish the bytes consumed then.
Historical source identity remains unestablished. As the investigation's
[scope clarification](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
explains, the existing external-tool trust boundary permits a precise reviewed
relevant-behavior premise; it does not require recovering that tarball or adding
a binary attestation. Record the relation and its actual corroboration for the
identified tool/configuration. This does not waive any capacity transfer,
Silver-owned source correspondence or complete automatic-discharge argument.

## Initial production-route derivation

The [driver](../../src/silver.adb), lines 103–125, selects Main alone for null,
or Main plus the six identity-bound runtime files for output; both use
`-gnat2022 -gnata -gnato`. Build is `gprbuild -P ... -p`, with no optimization
or code-model override. Proof uses the Image GNATprove overlay, `-U --mode=all`,
the complete report policy and current capped prover options recorded there.
`scripts/bootstrap.py:156–170,278–291` fixes the Alire context and overlay; it
replaces gnatwhy3, not the embedded Ada frontend. These are current source facts.
In the inspected SPARK snapshot, `gnatprove.adb:178–323,1315–1319` separately
dispatches native data-representation generation (`-S -gnatR2js -gnatws -gnatx`)
and ALI/translation runs (`-gnatc -gnates=...`). Their closures must be separate.
In pinned GCC, `sinput-l.adb:365–381` deduplicates physical names except in
multiple-unit mode; `127–145,231–236` allocates a whole template-file extent for
each virtual copy. Image reaches `System.Img_Int` and `Image_I(Integer)` through
`exp_imgv.adb:1113–1116` and `s-imgint.ads:36–41`; source-only generic exclusion
therefore does not close virtual counts. GNATprove inlining has a separate
dispatch (`sem_ch6.adb:4436–4448`), but `inline.adb:1970–2030` excludes the
current exported package APIs and expression-function helper from that route.
The [fixed-support derivation](retained-fixed-support.md) now bounds generic,
inline and inherited-contract source contributions for the selected helper
seeds, including the text-buffer contract path and Image generic body. It also
bounds generated binder sources from the retained ALI closure. The
[grammar-to-helper coverage](retained-fixed-support.md) now closes those seeds
conditionally for the current grammar and selected options. The remaining
source-range dependencies are the source/tool relation and establishing the
effective invocation/search premises in production #89, including inherited Ada
search variables after Alire selects the environment.
These source-range results do not bound the helpers' AST, value or backend costs.

## Comparison and next derivation

Compare a closed source-sensitive rule with a genuinely sound uniform envelope
over the same tool configuration and candidate language. Use matched sparse and
dense source shapes: comments versus statements; few long lines versus many
short ones; lexical Strings versus compact doubling; repeated large exponents
versus small decimal literals; distinct values versus justified sharing; and
branch/loop/Image compositions. Record admitted regions, explanation/diagnostic
quality and implementation/proof cost. Samples illustrate differences; soundness
requires the composition argument. No global optimality proof is required, but
an arbitrary safety margin is not a derived tool maximum or a justified choice.

The next derivation work, in dependency order, is below. Steps 1–3 are internal
phases of the single #119 deliverable, not independently completed work packages:

1. Close the phase-specific configuration, selected dependency/virtual-source
   inventory and source-position component above; preserve separate producer
   source-correspondence gaps. This is the first technical checkpoint.
2. Complete the reachable allocation inventory and grammar transfers, including
   growth intermediates, retained/temporary values and generated support. Derive
   frontend and essential-producer bounds separately; include backend/link closure.
3. Establish decidability, sound composition and correspondence for the selected
   accounting, compare the candidates, and select explicit capacity predicates.
   Existing lower-bound obstructions alone cannot supply their thresholds.
4. Only with those dependencies established, implement and verify membership,
   diagnostics and consistent language/catalogue/proof changes through #91–#94.

This checkpoint does **not** complete steps 1–3, #91, #93 or milestone 5.
Current caps remain until their replacement assurance is established. Validation
comprises source inspection and arithmetic/document checks, the isolated
standalone node-layout generator, and the explicitly scoped installed-producer
measurements in the [fixed-component record](retained-producer-fixed.md).
The latter use disabled/false solver backends and supply allocation/serialization
observations, not proof success. No Silver build, GNAT compiler rebuild,
GNATprove obligation audit, Lean build, full suite, macOS run or CI result is
claimed for this design. Independent reviews retain the frozen targets and
exclusions listed above; later additions are not silently covered by them.
