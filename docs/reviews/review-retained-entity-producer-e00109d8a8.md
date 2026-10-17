# Review: retained frontend entities and producer scalar costs

2026-10-17, Linux x86_64. Focused independent source review for
[#119](https://github.com/berkeleynerd/silver/issues/119).

**No material finding within the components' stated domains.** The reviewed
entity and normalized scalar bounds are usable inputs to the ongoing capacity
derivation. They do not justify an expanded admission domain on their own.
The explicitly unfinished dependency, native expansion, helper and whole-process
terms remain unfinished; this review does not reclassify them as defects in
these local formulas or as optional assurance.

## Frozen targets and evidence

- Frontend: `e00109d8a8`,
  `docs/research/retained-frontend-entities.md` and its evidence directory.
- Producer: `fcfdc7b10381bb9fb698ea04a33d068115863a67`,
  `docs/research/retained-producer-capacity.md` and its evidence directory.
  Subsequent producer edits are outside this review.
- GCC source: `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
- SPARK source: `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.

The reproductions used files extracted from those Git objects into isolated
scratch. The frontend reproducer verified 17 complete files against the retained
pinned manifest and reproduced its manifest and excerpts byte for byte. The
producer reproducer matched 28 complete source files to the retained source
archive, checked the three existing literal modules, and reproduced all four
generated evidence files byte for byte. The exact output hashes and command
outcomes are retained in
[reproduction.json](../evidence/review-retained-entity-producer-e00109d8a8/reproduction.json).

No compiler, GNATprove, Lean, build or test-suite execution was launched.
The source snapshots' correspondence to the installed tool pair remains an
explicit premise, as in the targets; matching source archives is not a binary
attestation.

## Frontend formula review

The bounds under review are:

```text
P         <= floor(A / 1000)
K_literal <= S + 3A + 5P
E_Main    <= 1 + D + R + 2D_s + 5F + K_literal
```

The source quantities and successful-analysis/light-expansion restrictions are
those defined by the target. I checked the following potentially missing paths:

| Component | Source checks and conclusion |
| --- | --- |
| Parser flattening | `par-ch4.adb:2561–2658` requires an all-literal run of at least 1,000 concatenations, and replaces it with an operator whose two children are literals. A parenthesized flattened run therefore cannot also be a literal leaf of an enclosing qualifying run. The `S + 2P` and `A + P` lifetime syntax allowances conservatively retain the discarded original nodes. |
| Literal folding and re-entry | `sem_res.adb:10570–10832,12039–12120,13205–13337` and `sem_eval.adb:2342–2443,5118–5144` support at most one literal resolution per source/replacement literal and at most two direct setter calls per nonfolded concatenation. The literal subtype's lower bound is static in the stated String domain, excluding the two additional nonstatic-bound types. `Eval_Entity_Name` preserves static String names rather than copying their initializer (`sem_eval.adb:2454–2534`). |
| Object types | `sem_ch3.adb:19080–19214,23008–23038,23130–23132` creates the explicit range subtype from an existing defining entity; it does not mark that entity as an itype. `exp_util.adb:5873–6011` skips nonstatic String subtype expansion in GNATprove. The static literal route adds one array subtype and one index itype; the static-name route adds at most one alias. The `2D_s` allowance covers both routes. |
| Loop entities and captures | `sem_ch5.adb:3259–3438,3901–3990,4109–4115` and `sem_ch3.adb:20712–20759,22704–22719` support the loop scope, index, index subtype and two possible bound captures. `exp_util.adb:12619–12824,13102–13111` captures an entire elementary expression once and rewrites it to a constant name. Preanalysis disables the capture path and its copied scalar ranges contain no defining entities. Neither nesting nor the runtime trip count multiplies this entity allowance. |
| Hidden String replay | The Main synthetic-spec route requires a list-member body (`sem_ch6.adb:3738–3764`). Library inlining rejects package-spec operations and other-unit bodies (`inline.adb:1974–1988`). `Set_Assignment_Type`'s allocating cases require excluded operand shapes (`sem_ch5.adb:300–365`). String actual length checking returns with expansion disabled (`checks.adb:3509–3534`). |
| Other admitted expressions | Integer Image does not take the enumeration-only folding route. Length queries the existing actual subtype. String `/=` reuses its analyzed children when rewritten to `not (=)` (`exp_spark.adb:1008–1023`, `exp_ch4.adb:10217–10256`). Freeze/light expansion supplies no invariant, DIC, tagged or renaming helper for the stated Main shapes. |

The derivation correctly separates scanner pool allocations from semantic
literal occurrences. It also correctly charges folded intermediate String
lengths separately from the lexical String lengths. Neither separation permits
the producer to charge a generated literal only once regardless of its actual
translation and serialization multiplicities.

The non-itype distinction must survive integration: `R` and the static-literal
String object subtypes cannot be substituted into a producer bound proved only
for itype completion. The target explicitly records this distinction.

## Producer formula review

For ordinary signed Integer expressions with expected `EW_Int_Type`, I traced
`Transform_Expr` through `New_Binary_Op_Expr`, `Insert_Overflow_Check`,
`New_VC_Call`, identifier reconstruction and scalar conversions. The guards
exclude modular, floating, abstract, predicate, validity, initialization-wrapper
and volatile-object work from this component. In particular:

- `gnat2why-expr.adb:24012–24205` translates each arithmetic operand once at
  its builtin Integer representation. `why-gen-expr.adb:3754–3997` adds one
  arithmetic call, while the nonmodular `Apply_Modulus` path returns unchanged.
- `why-gen-expr.adb:1956–1983,5282–5323` adds a call, VC label and optional
  location label for an overflow wrapper. `xtree_sinfo.adb:280–350,371–440`
  distinguishes the two labels' child fields and shows that integer constants
  have no serialized type child.
- `why-gen-binders.adb:1457–1524` returns an existing ordinary identifier or
  adds one dereference. `why-gen-expr.adb:2399–2910,2988–3044` allows at most
  one type label while normalizing a split Integer value to the builtin type.
  A fresh expected-type node and initial binder/symbol setup remain separate.
- The nonempty static-target boundary uses one range-check wrapper and one
  final type label (`why-gen-expr.adb:2349–2391`). Dynamic and empty subtype
  boundaries are expressly outside this coefficient.

An independent reconstruction of the AST child fields confirms the numerical
serialization costs:

| Component | Occurrences, excluding expression children where applicable |
| --- | ---: |
| Builtin Integer type | 2 |
| Ordinary identifier, with optional module charged | 5 |
| Normalized mutable identifier | 11 |
| Binary arithmetic call | 8 |
| Unary minus call | 7 |
| Overflow wrapper | 12 |
| Binary call with overflow wrapper | 20 |
| Unary minus with overflow wrapper | 19 |
| Static-subtype boundary | 15 |

The reconstruction counted each child reference, including repeated references
to shared nodes. Sixty-four left-associated compositions also satisfy the stated
`11L + 20O` envelope. These arithmetic checks corroborate the manual caller
analysis; they do not establish caller coverage or execute the producer. Results
and the small reconstruction are retained with the
[review evidence](../evidence/review-retained-entity-producer-e00109d8a8/arithmetic.json).
Fresh-node/list allowances also match the builders: up to two fresh nodes per
normalized ordinary name, four per wrapped arithmetic operator, two argument
lists and three argument-list elements per wrapped binary operator.

I also checked the producer's composition boundaries:

- `Mark_Entity` checks and inserts its entity set before recursive processing
  (`spark_definition.adb:11848–11890`), then appends an ordinary successful
  entity once (`:12186–12248`). Translation, completion and VC generation each
  have one list pass. `F <= E_list` is a conservative bound on printed files;
  it does not claim that Main or the whole process has a fixed file count.
- Main's regular declaration traversal supplies one program initializer
  translation. Immutable constants can add a term translation, even when its
  result is discarded. `Assume_Value_Of_Constants` excludes constants declared
  in that same unit (`gnat2why-expr.adb:2669–2703`), preventing an uncharged third
  pass through that route. Generated capture declarations still need to be
  included by the eventual frontend-to-producer composition.
- `Translate_Type` and `Generate_Type_Completion` support the stated outer
  theory counts (`gnat2why-types.adb:895–1101,1623–1739`). The `3I + 2A + 2R`
  formula is expressly for Integer/String itypes and new ordinary String
  representation keys; it does not price non-itype completion or declarations
  emitted inside each theory.
- The array-cache hit still allocates 17 nodes before checking membership:
  one module, two names/types and six identifier/name pairs
  (`why-gen-arrays.adb:1078–1085`, `why-atree-modules.adb:918–974`,
  `why-gen-names.adb:786–808`). The rank-one miss adds twelve helper nodes and
  the comparison module/helper adds three, before theory construction.
- The 27-kind memoized module allowance follows the key-based insertion path
  (`why-atree-modules.ads:819–851`, `.adb:465–504`). Direct module construction
  and setup remain separately charged, as required by the target.

## Recommendation and limits

Integrate these components and continue the source-to-event derivation. Preserve
their phase, shape and setup qualifications when translating the report into a
capacity predicate. In particular, link the frontend entity families to the
appropriate producer completion paths, and charge generated capture initializers
and every actual translation/serialization invocation.

The complete predicate still needs the dependencies, native expansion,
frontend storage, remaining producer helpers and backend representations listed
in the research contract. This review does not select a numerical capacity cap,
remove any existing limit, establish automatic discharge for a larger language,
or complete #119. No GitHub write, production edit or goal change was made.
