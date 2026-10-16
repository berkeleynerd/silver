# Output source-shape review for Integer, loops and Image

Review date: 2026-10-16. This record preserves the earlier `ReviewedOutputShape`
refresh and Compose native Image bridge checkpoint. The subsequent completed
Predicate, producer/schema, native file and consumer chain and final Linux
validation are recorded in the [capability delivery](for-loops-integers.md#stable-delivery-evidence)
and [independent review](reviews/review-410ed2c.md). Status statements below
retain their historical checkpoint scope. A complete token pin establishes
source identity; semantic claims also require the typed interpretations,
callee links and native contract checks below.

The prior reviewed pin was `a9e29b5099`. Each of its seven literal token lists
was independently compared with the corresponding native source at that commit.
Only `silver_output_profile.ads` and `.adb` have changed: 526 to 548 specification
tokens and 13,728 to 16,237 body tokens. The lexical, I/O and output-libc sources
and all five corresponding pins remain unchanged. The refreshed literals were
also compared with the canonical integration checkout's authoritative source;
the native profile remains the Image-admission implementation `1b341b9753`.
The native diff is 4 additions/2 deletions in the specification and 328
additions/97 deletions in the body. These counts describe review inputs only.

The review mapped every changed native group to its semantic/source work:

| Native changes | Interpretation and source checks |
| --- | --- |
| Integer/for/in/reverse/loop/range token alternatives, spelling and word classification | `ComposeSourceChecks.actual_catalogue` and `finite_mapping` check the complete enumeration, spelling and classification. `PredicateSourceRequirements` checks the public headers, enum and body dispatch. |
| Scalar environment in Parser_State, initial/invalid aggregates and validity | `ComposeExpressions`, `ComposeContracts`, `ComposeStateBounds` and the complete record/constant/header expectations in `ComposeSourceChecks`. Native callee legality remains checked by SPARK. |
| Shared arithmetic/concatenation work budget, including numeric-literal skipping | `ComposeAdmission` models the scanner and `ComposeSourceChecks` checks `work_tail` plus the executable adapter contract. Unary signs remain operator tokens; exponent syntax stays within its literal. |
| Scalar-aware call visibility, value lookup, new-name checks and assignment targets | Compose typed helper bodies and normalized equations preserve the scalar environment and check both String/scalar lookup. `ComposeEvaluation`, `ComposeModelCalls`, `ComposeModelRanges`, `ComposeModelLegal` and `ComposeModelRecursion` establish the concrete model witness and legal recursive calls. |
| Image_At, min/max lengths and empty intervals | `ComposeExpressions.imageBody` renders the complete native expression and `ComposeSourceChecks` checks it. `IntegerImageNativeSource` supplies native minimum/maximum endpoint meaning; `ComposeSourceBridge` derives those equations from its interpreted Image callees before normalizing helpers. Empty intervals map to zero endpoints and an explicit empty-value flag. |
| String value/expression min/max, nonliteral and empty-value propagation | Compose expression/state definitions and complete source record/aggregate checks match all added fields. `Expression_Step` adds both endpoints and preserves flags; tail/adapter equations return them. The dynamic argument aggregate explicitly sets nonliteral true. |
| Immutable scalar declaration; String declaration split and declaration dispatch | Compose typed declaration bodies check static nonempty scalar values, type-mark visibility, name uniqueness and capacity, and the native String singleton-length rule. Whole bodies and headers are in `ComposeSourceChecks`. Scalar expression/source/environment bridges justify the called operations. |
| Image-sensitive String assignment and output/comparison contexts | Compose assignment equations enforce nonempty singleton length where required. `LengthIntervalsSource` independently checks interval Fits, Same_Length and Refine_Equal; Predicate typed helpers, libraries and basic-statement semantics connect those operations at each call. |
| Body_Context scalar environment, context/scan conversion and validity | Predicate adapter typed renderings and `PredicateSourceRequirements` check the changed records, complete expressions and headers. |
| Scalar relation parsing, hidden String Length names and length summaries | `PredicateNativeSourceChecks`, `PredicateNativeHelpers`, `PredicateNativeLibraries` and `PredicateNativePrecedence` interpret the native expressions, exact source fields, bounded callees and precedence/scoping. |
| Statement dispatch and complete forward/reverse Loop_Body | `PredicateLoopNative` interprets name checks, hidden own-index bounds, endpoint evaluation, interval formation, scoped environment append and empty/definite/uncertain path joins. `PredicateLoopCandidate.rendered_candidate` checks the complete rendering; `PredicateSourceRequirements` extracts the actual block and headers. Body recursion/properties and scalar environment/source bridges justify its legal calls. |

The reviewed native diff contains no extra runtime source change. The five
unchanged pins keep the existing complete I/O runtime translation intact.
No pin was replaced by an alias to the current source or by a weaker subset.
The native full body still has an independent literal list, and
`OutputSourceBridge.actual_complete_shape` must prove exact equality against
the freshly checked authoritative source certificate.

The Compose source checks passed in managed Linux x86-64 run
`20261016T155217-348b030df577` with a fresh 21,096-declaration audit. The first
combined bridge/model run `20261016T162215-f8bbea123938` exposed the stale pin
in `OutputSourceBridge.actual_complete_shape`; its successful source
certificates are retained. The corrected focused run
`20261016T164123-b38ff51ed386` then passed with a fresh 47,193-declaration
audit: `ReviewedOutputShape`, `OutputSourceBridge`, `NamedSourceBridge`,
`ComposeSourceBridge` and `ComposeModel` all completed. This run reused the
successful source certificates and unchanged helper results from the first
combined run; it was not a clean rebuild. The final three changed Lean files
were compared byte for byte with the successful validation workspace. The
complete output source equality and native Image endpoint composition are
therefore checked for these inputs; capability delivery still depends on the
integrated endpoints listed at the beginning of this record.
