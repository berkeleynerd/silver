# For loops and integers

Authorized on 2026-10-15 by the owner's request to set this milestone as the
goal, update its label and drive it to completion. The live goal and conversation
title identify this work. Parent [stage #10](https://github.com/berkeleynerd/silver/issues/10)
and [milestone 1](https://github.com/berkeleynerd/silver/milestone/1) track delivery.
The [roadmap](../roadmap.md#for-loops-and-integers) records the ordered packages.

## Scope and completion

The motivating programs are Rosetta's
[Colour bars/Display](../rosetta/c/colour-bars/display/silver.md) and
[Loops/For](../rosetta/l/loops/for/silver.md), including nested bounds that read an
enclosing loop index. Determine explicit integer types, expressions, operators,
loop forms and permitted compositions from their semantics and automatic proof
requirements. No new form is supported until the specification, catalogue,
native implementation and complete universal/actual-source assurance agree.

Deliver executable samples and boundary/composition regressions, a stable native
Linux full proof audit/build/test checkpoint and complete cached Lean validation,
independent semantic review, synchronized Rosetta progression and evidence, and
the authorized commits and GitHub tracking. Source preservation and complete
obligation discharge remain mandatory. Existing 4096-byte source/value limits
remain unless an explicit justified change is needed within this capability.

## Selected initial fragment

This milestone admits immutable numeric values: initialized `constant Integer`
declarations and scoped `for` loop indexes. Predefined `Integer` has the pinned
GNAT signed 32-bit range, -2147483648 through 2147483647. Constants may read
earlier Integer constants; String and scalar names share one source namespace
but keep separate typed stores. The input declaration remains first in the
argument shell. Ordinary String declarations and mutable String assignments
retain their existing meaning.

Scalar expressions use literals, visible scalar names, parentheses, unary signs,
and fully parenthesized binary `+`, `-` and `*`. Every intermediate result must
fit Integer for the entire inferred operand interval, including negation of the
minimum value. Full binary grouping avoids Ada's permitted reassociation and
its native diagnostic. Scalar comparisons compose with existing predicates;
they do not yet narrow scalar intervals. Arithmetic therefore needs no facts
about values carried between iterations or author-written annotations.

Forward and `reverse` loops take scalar lower and upper expressions. Bounds are
evaluated once on entry; nested bounds may read differently named enclosing
indexes. The loop index is immutable, scoped to its loop and hides any outer
homonym, including use-visible operation names. Ada also hides the index's own
name in its bounds: an inner `for I in 1 .. I` cannot read an outer `I`. A scalar
declaration named `Integer`, or one after another object has hidden that type
mark, is invalid. Existing String objects named `Integer` remain legal.
Package names retain the existing shell restrictions.

Loop bodies compose with nested conditionals, null, String assignments, output
and returning Reject. String bounds and selected-input facts are immutable;
checking one body for every index interval establishes safety of repetition.
Exit facts account for empty ranges. Loop membership and proofs do not enumerate
iterations, and finite Ada ranges supply termination. Applications use
`--no-loop-unrolling`: automatic expansion is neither the admission rule nor
the discharge argument.

Mutable Integer objects, custom scalar types/subtypes, conversions, scalar
formatting, division and additional loop forms remain outside this initial
fragment. Mutable integers would require separate value-flow and loop-carried
assurance: the probes show that an initializer or pre-loop guard does not justify
an increment across arbitrary iterations. These are scope exclusions, not claims
that Ada/SPARK forbids the features. Later progression scopes must account for
any such forms their actual samples require.

The candidate resource rule is 64 scalar leaves per expression and one shared
63-operator source budget for String concatenation and scalar arithmetic. This
retains every existing program while bounding the expanded proof/report cost;
the complete source/value limits remain 4096 bytes. Actual-scope capacity probes pass, including a 4083-byte mixed program; these
resource choices still require the universal discharge and source bridges before
delivery. Exponent signs do not consume arithmetic operators. The selected
literal syntax caps nonnegative exponents at 4096, a conservative explicit scope
limit rather than a claim about Ada or GNAT's maximum exponent.

The existing predicate model has String bindings, length facts and finite branch
sequences. Its semantic, obligation and actual-source models must all grow with
the native recognizer. Updating source certificates alone is insufficient.

## Evidence and recovery

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
