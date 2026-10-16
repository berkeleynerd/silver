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
Implementation and assurance are in progress; no new construct is supported yet.

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

Scalar expressions use literals, visible scalar names, parentheses, unary signs
and fully parenthesized binary `+`, `-` and `*`. Each intermediate result must
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

The earlier selected resource design uses 64 scalar leaves per expression and
one shared 63-operator source budget for concatenation and scalar arithmetic,
with the existing 4096-byte source/value bounds. Nonnegative literal exponents
are capped at 4096; exponent signs do not consume arithmetic operators. These
choices must be checked again with Image's generated checks and compositions
under #13/#17. They are not supported language limits until delivery.

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
Image envelope still needs complete check-site and warning-multiplicity
accounting before admission. L1/L3's explicit proof-resource policy and L2/L4's
capacity and placement repairs are complete prerequisites.

The [Image diagnostic](for-loops-integers-image.md) identifies a distinct native
automatic-discharge gap: the producer's abstract Image model supplies a maximum
length but cannot establish the exact length required by valid assignments.
More solver effort cannot derive the missing semantic relation. The Image scope
remains selected while its sound proof-model refinement is implemented.

## Resumed integration evidence, 2026-10-16

The preserved feature edits were backed up and committed, then integrated with
the repaired/tooling `main` and resumption PR #46. Scalar declarations and
expressions, scoped comparisons and loop semantics have been recovered into
the feature branch. Native predicate/body and Compose source correspondence
remain in progress. These are focused Linux x86_64 results, not the stable
complete capability checkpoint:

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

The report-policy correction is `f2b71f3c5f`; it aligns the raw ghost policy and
projection congruence with the executable overflow rule. Its earlier targeted
generation was interrupted after inspection found the missing congruence call;
that incomplete run remains retained. The successful focused proof does not
replace the pending complete compiler audit. The Image proofs establish decimal
length/interval facts and consistency with the weak model at size 12; they do
not yet connect a native adapter to authoritative source and emitted checks.
The managed ledger retains attempts, timings, diagnostics and exact input scope.

## Completion and preserved work

Deliver decidable admission, execution and termination, universal safety and
automatic obligation discharge, and correspondence to the authoritative source
and actual native compiler. Update the language, catalogue, implementation,
proofs, samples, Rosetta supported identifiers and capability status together.
Run the stable native Linux proof/build/full-test checkpoint and complete
cached Lean check with a fresh audit, then independent review. macOS validation
remains independent and nonblocking. A pin update or passing sample does not
establish source correspondence or the universal guarantee.

Implementation and partial proofs remain on `feat/for-loops-integers` and its
focused worktrees. Its historical baseline was `343c2f8f5a`; repaired `main` is
now integrated. Preserve `tmp/for-loops-probes/`,
`tmp/for-loops-integers-active.json` and proof caches. Their earlier results
predate the Image scope change and are not evidence of complete delivery. The
refreshed active checkpoint retains a link to its historical paused record;
recheck exact inputs, the live harness and issue handoffs when continuing work.

## Historical pre-Image evidence and recovery

The following retained implementation results predate the settled Image scope,
the selected review repairs and proof-iteration controls. They establish only
their stated inputs; current scope and authorization are recorded above and in
[session memory](session-memory.md).

Baseline/review start: `343c2f8f5a`. Implementation branch:
`feat/for-loops-integers`. Host: Linux x86_64, established with
`python3 scripts/dev.py paths`. No complete capability validation has run yet.
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
