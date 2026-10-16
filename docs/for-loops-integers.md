# For loops and integers

The owner selected this milestone on 2026-10-15 and resumed it with standard
Integer `'Image` in [decision #34](https://github.com/berkeleynerd/silver/issues/34),
recorded on main in
[`39d0ad38e6`](https://github.com/berkeleynerd/silver/commit/39d0ad38e6).
The subsequent instruction to fix the selected review findings before further
feature work is recorded in
[`618c28a77c`](https://github.com/berkeleynerd/silver/commit/618c28a77cdf011f338a31fcb0e9022743a338de).
The [repair record](review-343c2f8-repairs.md) records the completed prerequisite
work. On 2026-10-16 the owner explicitly resumed the same unfinished feature
goal after those repairs and the [iteration controls](proof-iteration.md).
[Session memory](session-memory.md) records the current authorization.
**Delivered on Linux x86_64, 2026-10-16.** The complete input-specific validation
and independent review below accompany the coordinated language, catalogue,
samples, Rosetta progression and roadmap update. The external tool and
infrastructure premises remain explicit; samples do not establish universal
assurance.

[Milestone 1](https://github.com/berkeleynerd/silver/milestone/1) and
[stage #10](https://github.com/berkeleynerd/silver/issues/10) track delivery.
The [roadmap](../roadmap.md#for-loops-and-integers) records the order: report
capacity repair #17 first, scope/automatic-proof boundary #13, native admission
#14, universal and actual-source assurance #15, then validation/review/delivery
#16. Scope work can inform the repair; no new construct precedes its completion.

## Motivating programs

- [Loops/For](../rosetta/l/loops/for/silver.md): nested loops whose inner upper
  bound reads the outer index, printing the specified triangle of asterisks.
- [Loops/For with a specified step](../rosetta/l/loops/for-with-a-specified-step/silver.md):
  declare `Step : constant Integer := 2`, loop `I` over `1 .. 5`, and print
  `Integer'Image ((I * Step))` with `Put_Line`. Expected lines are ` 2`, ` 4`,
  ` 6`, ` 8` and ` 10`, including the leading spaces. This exercises immutable
  declarations, grouped arithmetic, loops and formatting together.
- [Loops/Downward for](../rosetta/l/loops/downward-for/silver.md): a reverse loop
  prints the countdown from ` 10` through ` 0`, preserving standard image format.

Colour bars/Display is no longer a milestone driver: its corrected assessment
requires actual coloured pixels in a PPM image and future file output. The
[Rosetta review](../rosetta/review-343c2f8.md) records the correction. Generated
stages are planning candidates: this owner-selected milestone covers for loops
and a bounded immutable Integer/Image fragment, not every integer form or every
sample in the later ranged-subtype stage. No construct identifier becomes
supported merely because its first fragment has an implementation.

## Selected fragment

Immutable scalar values are initialized `constant Integer` declarations and
scoped `for` indexes. The pinned GNAT `Integer` range is -2147483648 through
2147483647. Constants may read earlier Integer constants. Scalar and String
declarations share names, with separate typed values; existing String rules and
the first immutable argument declaration retain their meaning.

Scalar expressions use literals, visible scalar names, grouping and fully
parenthesized binary `+`, `-` and `*`. Ungrouped signs prefix numerals only;
nonliteral unary signs require a group. Signed binary operands need their own
group, for example `((-1) + 2)` and `(1 + (-2))`. Each intermediate result must
fit Integer throughout the inferred operand interval, including negation of the
minimum value. Grouping preserves the selected evaluation order. Comparisons
compose with existing conditions; they do not yet narrow scalar intervals.
Admission therefore requires no facts about mutable scalar values carried
between iterations and no author annotations.

Forward and `reverse` loops evaluate scalar lower and upper bounds once on
entry. Nested bounds may read differently named enclosing indexes. An index is
immutable, local to its loop and hides outer homonyms, including use-visible
operation names; its own name is also hidden in its bounds, so an inner
`for I in 1 .. I` cannot read the outer `I`. Scalar declarations must respect
visibility of the `Integer` type mark. Existing String objects named `Integer`
remain legal, and package-name restrictions remain shell-dependent.

Bodies compose with nested loops, conditionals, `null`, String assignments,
output and returning `Reject`. Fixed String bounds and selected-input facts
remain central to the composition argument. Empty loops preserve entry facts;
definitely nonempty loops retain body exit facts; uncertain loops join entry
and body exit facts. Membership and proofs must not enumerate iterations.
Finite Ada ranges establish termination, and application proof uses
`--no-loop-unrolling` so expansion is not the admission or discharge argument.

`Integer'Image (E)` uses Ada's standard decimal representation of an admitted
scalar expression: one leading space for a non-negative value, or a minus sign
for a negative value. No trimming, replacement formatting or hidden source is
permitted. Its result is an ordinary String expression for output and the
existing String-expression positions. Signed 32-bit images have at most eleven
characters; admission must derive the actual possible length or length interval
from `E` and prove intermediate concatenation capacity and equal-length
assignment in every admitted composition. A maximum length alone does not
establish assignment length equality. Image evaluation, its predefined source
semantics and native emitted obligations belong in the universal discharge and
source-correspondence arguments.

Mutable Integer objects, custom scalar types/subtypes, conversions, division,
other scalar images and additional loop forms remain excluded. Mutable scalar
values require separate value-flow and loop-carried assurance; subtypes and
conversions require their own range-check rules. These are Silver scope choices,
not claims that Ada/SPARK forbids the features.

The selected resource rules use 64 scalar leaves per expression and one shared
63-operator source budget for concatenation and unary/binary scalar arithmetic,
with the existing 4096-byte source/value bounds. Nonnegative literal exponents
are capped at 4096; exponent signs do not consume arithmetic operators. The
catalogue intentionally names this shared rule `max_program_operators` /
`program_operator_budget`, replacing the earlier concatenation-only names.
There is no compatibility alias or historical language profile. These rules
are part of the delivered fragment validated at the checkpoint below.

## Report capacity and automatic proof

[B1/#17](https://github.com/berkeleynerd/silver/issues/17) was repaired for the
currently admitted language. The reviewed dense static construction left only
5,772–6,141 bytes in the 2 MiB report buffer, and additional prover credits can
exceed that margin. The review observed the near-limit reports and credit-growth
mechanism, not an overflowing dense run. Its approximately 2.37 MB bound covers
that construction; it is not a bound for every admitted program. A suggested
4 MiB allocation is a candidate size, not a derivation.

The [completed repair](report-capacity.md) derives retained-report capacity,
projects the producer's larger reports, moves storage out of `Compile`'s stack,
and proves the reader/projection/policy connection. Its 16 MiB allocation and
current-language derivation are the integration baseline. The scalar, loop and
Image envelope is now derived from the pinned producer/frontend routes:
[15,028,224 retained Main bytes](report-capacity.md#for-loops-and-integers-extension),
including scalar checks, loop-bound overcounts and non-deduplicated Image
warnings, fit the existing 16,777,216-byte limit. The focused capacity tests
passed; this sizing result does not complete automatic-discharge assurance. L1/L3's explicit proof-resource policy and L2/L4's
capacity and placement repairs are complete prerequisites.

The [Image diagnostic](for-loops-integers-image.md) identifies a distinct native
automatic-discharge gap: the producer's abstract Image model supplies a maximum
length but cannot establish the exact length required by valid assignments.
More solver effort cannot derive the missing semantic relation. The selected
refinement supplies that relation through the independently
proved Integer Image theorem. Its complete scanner/schema, insertion and
source-composition obligations are set out below; a consistent mathematical
model alone is insufficient.

## Delivery assurance chain

The delivery chain joins the following arguments for the same implementation
inputs. `ImageProducerEndpoint.producer_finishes` derives successful scanning
from the reviewed producer schemas, and `FilesSource.native_producer_finishes`
connects that result to the initialized native file loop. The
`ImageModelRefinement` and `ImageRefinementEndpoint` modules derive complete
selected schemas, document insertion and original-byte recovery;
`FilesSource.native_refined_document` is the native refinement endpoint.
`ImageConsumerEndpoint.RefinedDocument.consumer_instance` connects the actual
inserted occurrence and scope to `ImageModelConsumerBoundary`'s finite external
consumer interpretation. The final whole-project audit and independent review
below cover this complete imported chain; byte recovery remains a separate
native-refinement conclusion.

| Layer | Required connection |
| --- | --- |
| Scalar admission and meaning | Literal/expression intervals, ordered immutable declarations, scoped indexes, comparisons and Integer Image agree with the independent source grammar and checked native definitions. Every intermediate arithmetic result fits signed 32-bit Integer. |
| Loop composition | Bounds are evaluated once; finite forward/reverse ranges terminate without enumeration. Empty, nonempty and uncertain iteration ranges compose existing String/path facts with the specified exit behavior. |
| Image length | The predefined decimal representation gives the exact possible length interval, including its leading space or sign. Concatenation and equal-length assignment use that interval; even empty-loop bodies retain other String contributions and static overflow rules. |
| Every generated model is handled | An independently reviewed pinned-producer contract supplies the exact selected templates whenever emitted, unique selected theory names, Image's Integer/String dependencies and the document syntax. Silver proves that those facts imply successful initialized scanning and `Finish`: unchanged without Image, refinement with Image. Scanner acceptance cannot be assumed or used to define language membership. |
| Actual scanner and complete schema | Source-interpreted native transitions derive normalization, complete selected-template byte equality and original declaration/include closing offsets. Broad input syntax permits the producer's string spellings; accepted template liveness establishes the ASCII domain needed for its canonical representation. |
| Semantic JSON interpretation | Independently established valid spellings and equal normalized bytes yield equal semantic JSON projections using explicit external parser soundness and successful parsing of the finite selected templates. Raw-number serialization is not assumed injective; integer representability and numeric meaning remain explicit. |
| Clone and theorem | Exact complete templates and the five substitutions fix two type roles, three primitive function roles and import/alias scope. Reviewed finite consumer-constructor and primitive-meaning contracts connect the actual returned signature to the predefined one. `IntegerImageTheory.assertion_valid` establishes the size-12 Image assertion; assertion validity is a conclusion, never a matching or consumer premise. |
| File transformation | Actual initialized scanning derives consumed length and insertion positions. The interpreted `Spliced_Prefix` contract fixes the output bytes; syntax composition appends exactly the clone and include to nonempty selected arrays. Erasing just those additions recovers every original byte, and all 23 inserted IDs are unique and fresh. |
| Native integration and reports | Complete owned SPARK checks, exact theorem installation, original-vendor argument forwarding and report classification compose with the driver. Every required safety obligation remains present and proved; warnings never waive checks. |

The [producer/schema review](for-loops-image-schema.md) records the full
serialized counter domain and corrected insertion band. The
[complete producer/consumer review](for-loops-image-producer-review.md) records
constructor-directed parity for all three templates, universal producer routes,
array-head syntax, precise capacity premises and finite consumer interpretation. The [output source review](for-loops-output-source-review.md)
records the scalar/loop/Image Compose connection. The
[assurance argument](assurance.md) separates these source and semantic results
from bounded external solver completion, and the
[trusted boundary](trusted-boundary.md#image-proof-adapter-boundary) records
physical tool selection, JSON interpretation and stable-file assumptions.

## Coordinated samples and progression

The delivery bundle adds [the nested triangle](../samples/for_loop_triangle.adb),
[the computed step sequence](../samples/for_loop_step.adb) and
[the reverse countdown](../samples/for_loop_countdown.adb), with exact expected
bytes in the sample manifest. The step example computes a value from an index
that advances by one; it adds no stride clause or mutable loop index.

The coordinated Rosetta split uses `integer-for-loops`, `immutable-integers`
and `integer-image`. Only the three reviewed driver assessments change scope;
the broader `for-loops`, `integers` and `scalar-image` identifiers remain
unsupported. After the delivery render, the three drivers are baseline stage 1,
remaining broad scalar/loop/subtype forms are stage 2 (#11), procedures stage 3,
and arrays stage 4 (#12). The matching stage issue bodies and fields follow
this delivery mapping. No later stage is authorized by this render or delivery.

## Stable delivery evidence

The [durable validation record](evidence/for-loops-integers/delivery-validation.json)
binds the final managed runs to their actual tools, inputs and native workspaces.
Focused successes retain their original scope and do not substitute for this
complete checkpoint. Cached validation, fresh audits, clean rebuilds and native
platform results are separate claims.

| Required evidence | Final input-specific record |
| --- | --- |
| Implementation and review target | `62f472c35d` plus coordinated delivery inputs; native/Lean executed snapshot `4cd2fe8aae`, followed only by the four generated certificate snapshots in #50; initial review `410ed2c83e`, five-proof-file repair at `b5cd3f0231`, and subsequent #48/#49 audit repairs remain distinct in the [review record](reviews/review-410ed2c.md) |
| Native platform and selected tools | Linux x86_64 (`codex-silver`); Alire 2.1.1; GNAT/GNATprove 16.1.0; selected GPRbuild crate 26.0.1 (binary reports 26.0.0); CVC5 1.3.2, Z3 4.15.4, Alt-Ergo 2.6.1. Exact executable hashes and version-output hashes are in the validation manifest. |
| Complete native SPARK audit | `20261016T200519-b3b644edcb13`: 15,083 checks proved; complete audit of 74 units/991 entities passed (1,283 flow and 13,800 proof checks, 290 limitation notes, 17 imports, 6,236 mathematical notes and 62 exact vendor specs); cached run, 40.299 seconds total |
| Compiler/adapter build | `20261016T200635-f7611c4d608c` passed; managed elapsed 3.899 seconds in the native validation worktree |
| Full regression and sample suite with focused snapshot repair | Full run `20261016T200650-91510d356211`: 450 tests in 1,355.313 seconds (1,355.967 seconds managed), retained as failure with four #50 regeneration subcases in one method and no other failures/errors. Focused repair `20261016T202127-4facdb2ce8b3` passed that method/all 26 certificate pairs. All 21 manifest samples passed, including the three loop drivers with exact expected output. Native snapshot sync passed: all 26 certificate snapshots and 204 native inputs match root; exact hashes are recorded in the validation manifest |
| Whole-project Lean build and fresh module/axiom audit | `20261016T200453-9fe1b554e036` at repaired implementation `4cd2fe8aae`: all 458 modules and a fresh 87,185-declaration audit passed; cached build, Lean 4.34.1, four workers/one thread, no independent replay. The earlier complete run remains separately recorded. |
| Scanner/schema/clone/Files endpoint closure | `ImageModelRefinement`, `ImageRefinementEndpoint`, `ImageProducerEndpoint`, `ImageModelConsumerBoundary`, `ImageConsumerEndpoint`; final audit/review evidence in the rows above and below |
| Universal producer applicability and forward scanner acceptance | [Complete producer review](for-loops-image-producer-review.md); `ProducerSchemas.envelope`, `producer_finishes`, `producer_refined_document`, `FilesSource.native_producer_finishes` |
| Independent review and findings disposition | [Independent delivery review](reviews/review-410ed2c.md), including exact core scalar/loop/native/report scopes, final producer/consumer chain and validated Sequence repair; subsequent #48/#49 repairs at `19b2f6c6b6` / `4cd2fe8aae` passed the complete repaired native and Lean checkpoints; later #50 snapshot repair and focused 26-pair recheck also passed; the original full-suite failure and successful focused repair remain separately recorded; native-lane snapshot synchronization/hash verification also passed |
| Final coordinated metadata and Rosetta render | Applied output byte-matches the reviewed draft; only the three narrow identifiers and driver assessments change. Renderer/determinism run `20261016T165337-cf4205a5867d`; delivery stage mapping #10 = 1, #11 = 2, #12 = 4 |

The original full native run `20261016T174150-cf80d84be8db` remains a failed
managed checkpoint, taking 7,957.651 seconds overall. GNATprove proved 15,083
checks with 74 unit reports; the following audit rejected two unclassified
exact vendor conversion entities. Retained-report inspection also identified one arithmetic
reassociation advisory. [Findings #48 and #49](reviews/review-410ed2c.md#native-audit-findings-and-repaired-validation)
record the classification/source-grouping repairs and successful repaired
native audit `20261016T200519-b3b644edcb13`. This full cached run followed the
batched Ada/checker repairs;
the matching Lean correspondence and complete root proof run
`20261016T200453-9fe1b554e036` now cover the repaired inputs. No completion is established by the original native
prover exit or the earlier complete Lean result alone.

Full suite `20261016T200650-91510d356211` completed 450 tests and failed only on
four stale generated
certificate snapshots in one regeneration test method. The initial isolated-lane
explanation was corrected: the failing snapshots matched root at `4cd2fe8aae`.
[#50](https://github.com/berkeleynerd/silver/issues/50) refreshes only those four
snapshots at `62f472c35d` to the exact bytes already regenerated and validated by
the successful complete Lean run. Shared authoritative inputs and validated
workspace bytes remained unchanged. Root focused run
`20261016T202127-4facdb2ce8b3` passed all 26 certificate/source pairs in the
failed method. The full suite and subsequent focused recheck are distinct
evidence; this record does not claim one clean passing full-suite run.

Linux x86_64 is the current native checkpoint platform. Retained macOS evidence
is independent and nonblocking; this delivery claims no fresh macOS run, hosted
CI run or optional independent kernel replay. Publication and issue closure
follow the completion commit under the existing authorization.

## Resumed integration evidence, 2026-10-16

The preserved feature edits were backed up and committed, then integrated with
the repaired/tooling `main` and resumption PR #46. Scalar declarations and
expressions, scoped comparisons and loop semantics have been recovered into
the feature branch. At the early checkpoints below, native predicate/body and
Compose source correspondence were still in progress. Subsequent focused
source and endpoint checks supply the chain named above; final combined
validation remains recorded separately in the delivery evidence table.
These are focused Linux x86_64 results, not the stable complete capability
checkpoint:

| Work | Managed run | Result |
| --- | --- | --- |
| Integrated compiler build | `20261016T134941-c356c3687463` | Build passed |
| Executable report policy | `20261016T135126-e3772e557073` | 36 tests passed |
| Scalar expression actual-source bridge | `20261016T140242-b1fc5652e763` | Focused build and fresh audit, 5,993 declarations |
| Scalar native predicates and basic statements | `20261016T141025-50886957b0e0` | Focused build and fresh audit, 13,721 declarations |
| Raw/retained overflow-policy congruence | `20261016T141258-fe22f824887c` | All 59 targeted native checks proved |
| Pure loop grammar, meaning and routing | `20261016T141638-0e61df079141` | Focused build and fresh audit, 12,749 declarations |
| Decimal Image arithmetic length theorem | `20261016T141909-c41772e4f101` | Focused build and fresh audit, 240 declarations |
| Consistent fixed-size Image refinement model | `20261016T142321-febc0b2f68ae` | Focused build and fresh audit, 279 declarations |
| Extended report-capacity guard | `20261016T163411-7b14b45862de` | Both focused tests passed; producer/frontend sizing record linked above |

The report-policy correction is `f2b71f3c5f`; it aligns the raw ghost policy and
projection congruence with the executable overflow rule. Its earlier targeted
generation was interrupted after inspection found the missing congruence call;
that incomplete run remains retained. The successful focused proof does not
replace the complete compiler audit required above. The earlier Image runs in
this table establish decimal length/interval facts and consistency with the
weak model at size 12. Subsequent source, template and endpoint results must be
recorded at the final checkpoint; the earlier pure model checks alone do not
establish the native adapter's complete assurance.
The managed ledger retains attempts, timings, diagnostics and exact input scope.

## Completion and preserved work

Delivery joins decidable admission, execution and termination, universal safety
and automatic obligation discharge with correspondence to the authoritative
source and actual native compiler. The coordinated language, catalogue,
implementation, proofs, samples, Rosetta identifiers and capability status use
the complete Linux checkpoint and independent review recorded above. macOS
validation remains independent and nonblocking. A pin update or passing sample
does not establish source correspondence or the universal guarantee.

The scalar/loop implementation and the source, producer, refinement and
consumer proof chain are integrated at the review target recorded in the
[independent delivery review](reviews/review-410ed2c.md). Its exact commit and
prospective delivery diffs are distinct from the final validation inputs and
completion commit. Complete native proof/build/tests and the whole-project
Lean audit are recorded above; a focused endpoint audit does not discharge
that work.

Preserve the historical `feat/for-loops-integers` worktrees,
`tmp/for-loops-probes/`, `tmp/for-loops-integers-active.json` and proof caches.
Their pre-Image results retain their original scope and are not evidence of
complete delivery. The active checkpoint links the historical paused record;
recheck exact inputs, the live harness and issue handoffs when continuing work.

## Historical pre-Image evidence and recovery

The following retained implementation results predate the settled Image scope,
the selected review repairs and proof-iteration controls. They establish only
their stated inputs; current scope and authorization are recorded above and in
[session memory](session-memory.md). Pending-work statements in this historical
section describe those checkpoints, not the completed delivery.

Baseline/review start: `343c2f8f5a`. Implementation branch:
`feat/for-loops-integers`. Host: Linux x86_64, established with
`python3 scripts/dev.py paths`. At this historical checkpoint no complete
capability validation had run.
Exploratory evidence is under `tmp/for-loops-probes/`; the running checkpoint is
`tmp/for-loops-integers-active.json`. Existing caches and unrelated scratch remain
intact. macOS validation, hosted CI and independent kernel replay are not claimed.

The initial isolated probe set is recorded in `tmp/for-loops-probes/README.md`,
with exact source, argv, logs and JSON reports per case. With loop unrolling
disabled, both motivating programs prove, build and execute with exact bytes;
both return failure status on `/dev/full`. Nested loops, signed bounds, scoped
names, fixed String assignments and guarded input compositions were exercised.
Expected carried-counter proof failures and name/type frontend failures remain
in the evidence. Source-bound dense cases and existing 64-leaf/release-report
programs passed the same isolated mode. These are concrete probes, not universal
assurance or final compiler admission tests.

The scalar native foundation is integrated in `6d7328e4dd`: interval arithmetic
uses bounded wide intermediates and the literal scanner accepts magnitudes up to
2^31. Its zero-mantissa/exponent shortcut avoids iterating billions of times.
The implementation lane's isolated GNATprove audit passed all helper checks;
see `tmp/scalar-native-validation/`. Complete compiler,
source-correspondence and capability validation remain pending.

The actual-scope capacity replacements use only static Integer declarations and
outer indexes for numeric values; the earlier exploratory `D'Length` Integer
initializer is outside the selected grammar. Four replacements passed with loop
unrolling disabled, including 64 scalar leaves, 63 mixed operators and a dense
4083-byte composition. Exact counts, elapsed time, report bytes and input hashes
remain in `tmp/for-loops-probes/index-capacity-summary.json` and the probe README.
Those examples do not establish a universal report-size or proof-time bound.

Frontend differential testing found that the initial scalar scanner admitted
`0E2147483648`, which GNAT rejects as an oversized exponent. The selected fix
caps literal exponents at 4096 and updates the model, grammar and actual-source
proof together; the initial audit predates that repair. Native stress probes
also exercised 140 nested loops and 1950 scalar parentheses within the source
limit. These are isolated implementation checks, not the final full checkpoint.

The initial scalar literal source bridge passed its focused Linux check and fresh
axiom audit after correcting a stale return-type assertion in the source
interface. That 17:15 UTC result covers the pre-exponent-cap literal implementation; later
focused runs have superseded the root log. The first attempt retained its
successful source certificate and reported the interface mismatch; the corrected
run reused it. The cap model and typed equations subsequently passed a focused
check and fresh audit in `d22c959d9d`; its retained log is
`tmp/for-loops-planning/literal-cap-model.log`. The matching capped source check and fresh axiom audit passed at 17:53 UTC;
its retained log is `tmp/for-loops-planning/literal-cap-source.log`. These are partial assurance results, not the completed milestone
checkpoint.

The interval helper's exact-source bridge passed its focused Linux check and
fresh axiom audit at 17:40 UTC, for `6292d116c7` in
`tmp/for-loops-scalar-proof`. It checks the complete source, numeric declarations,
function headers and all typed expression renderings, and derives operation
correctness from arbitrary callees satisfying those source equations. The report
policy's independent focused SPARK audit also completed with all 972 checks
proved; its exact inputs and retained reports are in the probe README. The
broader native parser audit and integrated source/semantic checkpoint remain
pending.

The proof implementation separates arithmetic intervals and expression safety,
ordered immutable constants, universal finite-loop execution and path-fact
composition, independent source grammar, and the native source equations. Mixed
header readings retain separate ordered String and Integer declaration traces;
their stores share source names without changing existing String indexes.
The native scanner must agree with those readings, and the checked obligation
schemas must cover their full composition with input, branches, assignment,
output and returning Reject. Exact source tokens, declarations, typed bodies,
recursive equations and native refinement contracts jointly establish source
correspondence. No pin or successful sample substitutes for those arguments.
