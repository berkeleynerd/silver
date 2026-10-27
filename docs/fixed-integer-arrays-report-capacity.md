# Fixed-size Integer arrays: producer and report capacity

Feature-local source review for [#260](https://github.com/berkeleynerd/silver/issues/260),
2026-10-27. This extends the [division envelope](integer-division-report-capacity.md)
for the selected [array increment](fixed-integer-arrays.md). It does not resume
deferred #119 research or establish the separate capability assurance checkpoint.

The reviewed fragment has one-dimensional anonymous arrays of predefined
`Integer`, nonempty Ada-static Integer bounds, exact positional initialization,
and a static sole-index association for singleton initialization. It excludes
component constraints, `others`, multidimensional/iterated/delta aggregates,
whole-array expressions, attributes, named types and nested array subscripts.
Each read/write index has a nonempty interval contained in the array bounds,
including unreachable source. Existing source and lexical-work limits remain.

## Inputs and source routes

Retain the existing producer/frontend/tool trust boundary: SPARK fsf-16
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, GNAT-FSF recipe
`0334dd54a2c479faa3dfad47a911373581b11739`, and GCC frontend
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. This is retained source inspection,
not installed-binary attestation. Producer files are retained beneath
`tmp/review-capacity-343c2f8/tmp/producer-source/`; frontend files beneath
`tmp/frontend-capacity-20261016/` in the original checkout.

| Input | SHA-256 |
| --- | --- |
| `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `src/why/why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `src/why/gnat2why-types.adb` | `3b4b21d00eb4d14a4f7966c097f215217ea54183be4048a5d9bbd98ccdb3663d` |
| `src/spark/spark_util-types.adb` | `61c39d0e43f4b2d8f36a723d87b9061d2e14611296c2378473b509df42979cc9` |
| `src/spark/spark_definition.adb` | `d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e` |
| frontend `sem_ch3.adb` | `198190171bcd99d293c3ec86a2ffe4ffb4a29276bfd205ebc4b9f0aea87d263f` |
| frontend `exp_spark.adb` | `509e27a893828c31e7148f29470ab1fcbacd879242a1066dd22bdc3a6cf0fbfb` |
| frontend `expander.adb` | `5cbfe2783201ea57d9d93290187daa0a24d71757b82b2a49c9280704b148b461` |

`gnat2why-expr.adb:14042–14089,14287–14349` translates each read/write
index to mathematical Integer and inserts at most one index check. The final
component store uses a simple unchecked conversion; the RHS retains its ordinary
assignment-root conversion. `why-gen-expr.adb:2444–2464` gives mathematical
Integer no additional bounded range type.

The aggregate collector at `gnat2why-expr.adb:16273–16600` records each explicit
component once. The selected function translation at `15743–15843` translates
each once in executable mode; `17463–17522` uses the ordinary scalar checked
conversion, with at most one final range check. Constant defining axioms use
the term domain and add no executable checks. Arithmetic and division within
component/index expressions remain charged to the shared lexical budget.

The positional-choice route at `16765–16819` adds no check for signed indices
without `others`. The matching-bound route at `17141–17204` requires an inner
dimension and is absent for these one-dimensional aggregates. A singleton's
sole choice is Ada-static and equal to its bound; `23462–23566` therefore does
not enter the nonstatic-choice check. Exact singleton value alone would not
establish this staticness premise. Aggregate root conversion at
`why-gen-expr.adb:982–1508` returns immediately for identical types or introduces
at most one length check for a constrained target. Predicate, initialization
wrapper, qualification and unconstrained sliding-range routes are excluded.
Valid static bounds take the no-check branch at
`gnat2why-expr.adb:3707–3731`; the array-type route at `22890–23008` adds no
independent constraint-root check for this syntax.

The frontend uses light SPARK expansion (`expander.adb:105–125`). Its aggregate
expansion at `exp_spark.adb:549–595` changes container aggregates only; its
object-declaration expansion at `919–946` concerns absent initialization with
Default_Initial_Condition. Neither duplicates the selected array initializers.

`sem_ch3.adb:19097–19104,6724–6750` creates anonymous array types/subtypes.
They have none of the type-VC triggers in `gnat2why-types.adb:1108–1141`, nor
the corresponding coverage triggers in `spark_definition.adb:2313–2389`.
The array has no private view/default checks, access-subprogram, iterable,
nonstandard equality, aggregate annotation or ownership annotation.
Aggregate helpers (`gnat2why-expr.adb:15950–16271`) are Why modules rather than
Ada callees. `gnat2why-driver.adb:1086–1116` registers dependencies from Ada
calls; the existing type/timing gates described in the
[mutable review](bounded-mutable-report-capacity.md) remain applicable.
Generated names therefore do not enlarge retained entities, coverage, claims,
dependencies or timing maps.

Existing mutable-array initializer/assignment advisories use the same branches
in `flow-analysis.adb:1989–2055`. Positive initialization messages skip explicit
initializers and internal objects at `2763–2794`. Position/message/severity
deduplication and the source-bounded initializer-name allowance remain applicable.
There is no new accepted diagnostic. Array component/bound syntax contains no
Image expression; placing indexed reads in existing Image arguments does not
change its predefined Integer prefix or inherited maximum traversal count.

## Joint source charge

Simply adding `floor(S/4)` index records to all old independent maxima exceeds
the current allocation. Those maxima overlap source bytes. Replace the old
`floor(S/5) + floor(S/3)` root/comparison buckets with one `floor(S/2)` bucket
covering their union, aggregate component conversions and indexed reads/writes.

| Check site | Two distinct source bytes reserved for it |
| --- | --- |
| Assignment or declaration aggregate root | Its `:=` |
| Indexed occurrence | Its opening and closing parentheses |
| Aggregate component conversion | One non-parenthesis value-token byte and its following comma; the final component uses the aggregate's closing parenthesis |
| Comparison | Two operator bytes, or one operator byte and one operand-token byte |

These reservations are disjoint. Component expressions contain no comparisons;
comparison operands occupy their own expression spans. Indexed parentheses are
distinct from operand/value token bytes and the aggregate's closing parenthesis.
Other grouping, spelling, arithmetic, whitespace and comments only consume more
source capacity. The singleton association supplies additional unused syntax.
Thus the combined count is at most `floor(S/2)`. This also covers every component
of the source-derived maximum of 2,048 initialized cells.

Conservatively keep all other inherited independent charges, including the
scalar-declaration allowance even where it overlaps the root count:

```text
checks = floor(S/2) + 3*63 + floor(S/13) + 2*floor(S/18)
Main = checks*2048 + (2*S + 2*floor(S/16))*1024 + 2*S + 65536

S = 4096: checks = 3006
Main = 15,142,912 bytes
16,777,216 - Main = 1,634,304 bytes of headroom
```

The smaller total reflects removal of overlapping old maxima, despite adding
new sites. No report-storage change is needed. Runtime envelopes remain
unchanged. The sole new accepted Main proof rule is `VC_INDEX_CHECK`, whose
fixed success text is `index check proved`; both fit the existing 2,048-byte
record allowance. Existing info/prover/Main provenance and all suppression and
justification exclusions remain. No `VC_RAISE`, new entity or diagnostic is
admitted by this derivation.

## Corroboration and scope

Existing managed native probes under
`tmp/fixed-arrays-native/.silver/linux-x86_64/` corroborate these producer routes:

- `array-producer-probe`, run `20261027T073406-f0f1fb5fa601`, passed anonymous
  positional arrays, a negative singleton, mutable snapshots and rotation loops;
  reports introduced no new entity class.
- `array-index-probe`, run `20261027T073548-78870277e394`, emitted three proved
  `VC_INDEX_CHECK` records with Main entity, and no flow diagnostics.

These probes do not establish universal assurance. This review performed no
new native/proof run. Selected reviewer: GPT-6 Astra / Extra High; runtime
confirmation and elapsed/token/cost measurements were unavailable. Independent
integration review, executable capacity guards and the capability's complete
native/Lean/source checkpoint remain separate delivery obligations.
