# Named Integer-array inputs: producer and report capacity

Feature-local account for [#410](https://github.com/berkeleynerd/silver/issues/410),
prepared 2026-11-21 from the retained
[independent native review](reviews/review-named-array-native-20261121.md#producer-and-retained-report-capacity).
The capability's complete Linux native/Lean/source assurance, final regression
coverage and internal delivery confirmation are recorded in the
[delivery account](named-array-parameters.md#delivery-assurance-and-validation).
[PR #412](https://github.com/berkeleynerd/silver/pull/412) is open for owner review.
The November 22 focused review identified two producer routes for which it had
only example reports. The I4 follow-up below traces both in the pinned source.
[Focused review](reviews/review-pr412-claude-proof-20261122.md)

The [scalar-procedure account](scalar-procedures-report-capacity.md#conservative-retained-storage),
including formal-dependence advisories and the later named scalar associations,
derives a **49,279,744-byte** retained Main report envelope in the existing
**67,108,864-byte (64 MiB)** allocation. The reviewed routes below preserve that
envelope and its **17,829,120 bytes** of headroom; no allocation change or new
report class is selected. The shared [report-capacity record](report-capacity.md)
sets the producer, JSON schema and streaming-projection premises. Original
reports remain unchanged, and all required obligations remain subject to audit.
This is a retained-storage argument, not a bound on original report-file size,
solver time, stack usage or peak memory.

## Selected source forms

The [capability plan](named-array-parameters.md) selects static, constrained,
one-dimensional nonempty Integer-array types with 1..2048 components, initialized
objects, read-only same-nominal-type inputs in existing functions and procedures,
and static First/Last/Length/Range queries. Bounds queries also cover existing
anonymous Integer-array objects. Scalar inputs, returns and writable outputs
retain their existing rules. Symbolic array inputs denote their complete declared
component domains; they consume neither physical object cells nor source-written
component initializers. The count of components in a formal does not multiply
source read sites or copy-back sites.

An array actual is a bare object or enclosing input formal with the same positive
named-type identity. There is no array output, copy-back, return, slice,
qualification, sliding, predicate or relaxed-initialization wrapper. Boolean
named arrays and queries and a separate expansion of local array declarations
remain excluded. Full body analysis and the existing `--no-inlining` recipe still
apply, including to unused declarations.

## Pinned producer routes

The SPARK source revision is
[`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0).
The native reviewer inspected the following routes; this account checked the
retained source excerpts and all six hashes. The upstream links identify the
actual source at that revision. As in the shared record, this is source
inspection under the documented producer premises, not binary-source attestation.

| Selected form | Actual producer route and retained allowance |
| --- | --- |
| Read-only array actual | [`gnat2why-expr.adb:4393–4592`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-expr.adb#L4393) transforms each actual once; 4579–4585 uses its formal type. [`why-gen-expr.adb:1155–1164`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/why-gen-expr.adb#L1155) returns immediately when entity/type/wrapper status matches. Even the conservative distinct constrained-target route at 1448–1464 inserts at most one Length check, within the existing two-source-byte per-actual reservation. Array output reconstruction and copy-back are absent. |
| First/Last/Length | [`gnat2why-expr.adb:19903–20095`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-expr.adb#L19903) selects `Get_Array_Attr` in the term domain for a type prefix; an object prefix transforms a simple identifier, without visiting its components. Length uses mathematical Integer. The extra modular range-check branch does not apply to the signed Integer index domain. Existing outer scalar-conversion allowances cover applicable checks. |
| Range loop | Fixed First/Last metadata feeds the existing counted-loop route. Existing loop-bound root allowances remain sufficient; no element iteration or array write is introduced by a Range query. |
| Named static type declaration | [`gnat2why-expr.adb:22890–23008`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-expr.adb#L22890), [`gnat2why-types.adb:1108–1141`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-types.adb#L1108) and [`spark_definition.adb:2313–2389`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/spark/spark_definition.adb#L2313) add no independent type-root obligation or owned type entity for the selected syntax. Its index/component indications are static; it supplies no private/default, access-subprogram, iterable-aspect, nonstandard-equality, aggregate-annotation or ownership-annotation trigger. |
| Input/object dependence advisories | [`flow-analysis.adb:1210–1268`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis.adb#L1210) uses `Entire_Var` sets; 1372–1445 emits at most one ineffective-import warning per set member. Bounds do not multiply names or warnings. The existing per-formal/name reservations therefore apply. |
| Array-loop initialization advisory | [`flow-control_flow_graph.adb:4015–4032`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-control_flow_graph.adb#L4015) is the existing indexed-write warning route. Closed callable bodies add no writable-array route, and immutable actuals add no write. The inherited source-derived loop/write bound remains applicable. |

### Aliasing and named-type records (I4)

**Call pairs.** The producer compares each actual with every later actual.
Two immutable inputs immediately yield `Impossible`, including repeated array
inputs. A bare array name and a writable Integer or Boolean actual resolve to
distinct root entities because the writable actual must be a bare mutable
scalar name. This also holds for forwarded formals. Array components cannot
be writable actuals. The producer returns
`Impossible` for distinct roots and exits before emitting an `ALIASING` record.
Closed callees have no captured mutable globals, and the producer skips read-only
globals for immutable inputs.
[Admitted calls](../language.md#small-nonrecursive-scalar-procedures) ·
[Pair and global checks](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis-antialiasing.adb#L1000-L1079) ·
[Immutable formals](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis-antialiasing.adb#L823-L834) ·
[Two immutable inputs](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis-antialiasing.adb#L539-L550) ·
[Distinct roots](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis-antialiasing.adb#L624-L633) ·
[Emission guard](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-analysis-antialiasing.adb#L867-L880)

**Type declarations.** The constrained array has no private view, so
`Find_View_For_Default_Checks` returns `Empty`. The obligation-theory path tests
for the presence of that view, as does `Needs_Default_Checks_At_Decl` on the
SPARK-status path. `Use_Predefined_Equality_For_Type` returns true for this
nonlimited array of Integer or a named Integer subtype. Both paths test its
negation. With the other four triggers excluded by the selected type syntax,
`Generate_VCs_For_Type` returns before opening a theory and `Get_SPARK_JSON`
skips the type entry.
[Default-check predicate](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/spark/spark_util-types.ads#L302-L314) ·
[Private view lookup](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/spark/spark_util-types.adb#L835-L869) ·
[Predefined equality](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/spark/spark_util-types.adb#L3050-L3063) ·
[Obligation theory](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-types.adb#L1108-L1141) ·
[SPARK status](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/spark/spark_definition.adb#L2359-L2372)

## Source counts and unchanged envelope

Let `S = 4096`, the unchanged complete-source byte limit. Each explicit-mode
formal consumes at least seven disjoint bytes including its preceding delimiter
(`(X:in T`), a complete local function/procedure consumes more than 32 bytes,
and a call consumes at least five bytes. Thus the existing joint allowances
of `floor(S/7) = 585` formals, `floor(S/32) = 128` callable entities and
`floor(S/5) = 819` call sites remain conservative. Bodies are not inlined.
Named associations add bytes without removing the distinct delimiter and payload
byte reserved for each actual. Constrained array formals do not add writable
actuals, initialization-output records or copy-back records.

New named-object syntax can use an 11-byte declaration, but that does not alter
the inherited array-loop warning term
`floor(S*S/(4*24*8))`. Its source inequality is `24*L + 8*W <= S`, where `L`
counts enclosing foreach loops and `W` counts indexed writes. The 24 bytes
are a complete foreach loop's 15-byte prefix and nine-byte `end loop;`, not an
array declaration. New Range loops are longer. Therefore a shorter named
object declaration does not invalidate that denominator or multiply warnings.
The [constant-iteration account](constant-array-iteration-report-capacity.md)
retains the underlying source reservation.

Named-array forms do not reduce existing scalar-site or loop minima.
Initializer/index sites retain the joint `floor(S/2)` reservations. Each read
is charged by source site, and selected formal components introduce neither
array copy-back nor a default-initialization wrapper. Existing scalar outputs,
source-name payloads, function termination witnesses, procedure initialization
witnesses, call dependencies and formal advisories retain the separate charges
in the procedure account. No new term is required:

| Retained total | Bytes |
| --- | ---: |
| Existing combined envelope, including #391 formal advisories | 49,279,744 |
| Additional named-array-input/bounds-query term | 0 |
| Existing selected allocation | 67,108,864 |
| Remaining headroom | 17,829,120 |

## Retained source identity and corroboration

The November 21 account rechecked the first six hashes. The first four files
are under `tmp/scalar-procedures-native-370/tmp/procedure-probes/producer/` and
the next two are under `tmp/empty-loop-repair/tmp/boolean-array-producer/upstream/`,
relative to the main checkout. The final three links download the sources
inspected for I4 as deterministic gzip archives. All hashes cover uncompressed
source bytes. [I4 source packet](evidence/named-array-parameters-410-20261121/review-response/focused-proof/capacity-producer/README.md) ·
[I4 SHA-256 listing](evidence/named-array-parameters-410-20261121/review-response/focused-proof/capacity-producer/SHA256SUMS)

| Producer file | SHA256 |
| --- | --- |
| `gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| `flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| `gnat2why-types.adb` | `3b4b21d00eb4d14a4f7966c097f215217ea54183be4048a5d9bbd98ccdb3663d` |
| `spark_definition.adb` | `d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e` |
| [flow-analysis-antialiasing.adb](evidence/named-array-parameters-410-20261121/review-response/focused-proof/capacity-producer/flow-analysis-antialiasing.adb.gz) | `e0bbc64f956766827515f309e6b83997d5b9203d361de6d5e614b493a4fd00a1` |
| [spark_util-types.adb](evidence/named-array-parameters-410-20261121/review-response/focused-proof/capacity-producer/spark_util-types.adb.gz) | `61c39d0e43f4b2d8f36a723d87b9061d2e14611296c2378473b509df42979cc9` |
| [spark_util-types.ads](evidence/named-array-parameters-410-20261121/review-response/focused-proof/capacity-producer/spark_util-types.ads.gz) | `527f96c5888798d023959b5a57254edd520b028017c9835a973a0ef44f5eb240` |

The bounded reviewer selected GPT-6 Astra / Max; live runtime model and effort
were not independently exposed. The review found no numerical capacity defect.
The fifteen feature tests (including five full routes) passed in managed run
`20261121T125607-826b7d51ebf2`. Three source-limit check/compile/prove/report-audit/run
routes and their over-limit controls passed in `20261121T130801-77ed9650af68`
at the lead-recorded 16 MiB invoking-shell stack setting. These native Linux
x86_64 observations corroborate the producer routes; they do not prove a
universal producer bound or replace final complete feature assurance. The
[stack evidence](evidence/named-array-parameters-410-20261121/stack/README.md)
records its environmental prerequisite and preserves the earlier failed harness
attempt. This documentation preparation reran no native compiler or prover and
changed no issue state, live goal or CLI memory.
