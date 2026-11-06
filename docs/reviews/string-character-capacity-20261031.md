# String and Character report-capacity review

Bounded independent review for #296, 2026-10-31. **No blocking finding** in the
feature-local extension of the retained report envelope. Under the existing
producer/frontend, check-identity grouping and report-projection assumptions,
the new constructs do not require a larger count or record size. This does not
complete the feature review, native/source correspondence or universal assurance.

The reviewed draft is
[bounded-string-characters-report-capacity.md](../bounded-string-characters-report-capacity.md),
Git blob `946d414a5cdc5709e185b3a29d5b3e04b8f0f617`, SHA-256
`a0d39c74aaa86476ebfa64d2f19cd2cef3dd2bd5d858c2eaabaa460a2e387018`.
The draft was unchanged between the initial and final identity checks. The
native implementation inspected was commit
`79b350912a839dc5aa46c30bea79dfb99b0e41b1`, especially
`src/silver_output_profile.adb` and `.ads`. Review was read-only apart from this
new report; no build, proof run or new specimen was launched.

## Findings and challenged cases

- **Slices and null bounds:** `Transform_Slice` transforms the two endpoints
  once and constructs one executable `VC_RANGE_CHECK` assertion. Its implication
  guards both prefix-bound tests by `Low <= High`; arbitrary inverted null bounds
  do not introduce another assertion. The extra `Check_Scalar_Range` branch
  requires a subtype indication, excluded by the admitted explicit `L .. U`
  syntax. Wide mathematical slice-length calculations do not create additional
  source operators or report sites. Source endpoint arithmetic and nested
  Integer-array reads retain their own charges.
- **Noncanonical bounds and concatenation:** `Transform_Concatenation` binds each
  operand to a temporary, inherits/selects the lower bound, and introduces one
  `Do_Range_Check` when reconstruction is necessary. Its static-null and
  dynamic-null branches reuse the right value; they do not retranscribe the
  operand's source checks. Generated bound arithmetic uses mathematical Integer.
  The new bound-safety obligations change what that existing concatenation site
  must prove, rather than creating another source site. Character concatenation
  remains excluded.
- **Conversions and frontend copying:** the array-conversion paths are mutually
  exclusive at the root: qualification/index, constrained-target length,
  unconstrained-range, or fixed-lower-bound sliding. The admitted syntax has no
  qualification, predicates, relaxed initialization or new fixed-lower-bound
  array type. Whole-String stores retain the existing root length charge;
  Character stores retain their scalar root conversion. The indexed-component
  store itself uses `Insert_Simple_Conversion`. `Range_Check_Applied` prevents
  successive scalar conversion stages from charging the same conversion twice.
  The frontend slice subtype explicitly has the original array's **base type**
  as its parent (`sem_res.adb:13165–13174`); conversion to that parent is excluded
  by `Check_Needed_On_Conversion` (`spark_util-types.adb:493–510`). For nonstatic
  declaration initializers, `Expand_Subtype_From_Expr` returns in GNATprove mode
  (`exp_util.adb:5884–5892`). Its static-slice path uses the slice index subtype
  and freezes the endpoint values, rather than copying an executable initializer.
- **Disjoint bytes and nested indices:** a slice's own `(` and `)` are distinct
  from nested indexed reads' parentheses, assignment/declaration `:=`, comparison
  operator and operand-token bytes, and aggregate component reservations.
  Subscripts/endpoints are scalar expressions and contain no comparisons that
  could collide with the comparison reservation. String-valued indexed prefixes,
  nested String arrays and slice targets are excluded. The separate implicit
  element-reference bucket is intentionally allowed to overlap other buckets.
- **Nested loops and advisories:** the reviewed flow traversal calls
  `Potentially_Defined` once per indexed assignment per enclosing loop analysis.
  String component writes enter the same one-dimensional route; slices only
  read. The warning withholds `Fully_Initialized`, while all admitted Strings
  already have explicit initializers. No new out-parameter call route exists.
  The conservative `24*L + 8*W <= S` reservation and `L*W` warning bound therefore
  continue to apply. This is not a claim of one warning per textual write.
- **Character literals and budgets:** literals become integer constants in the
  producer. Native `Character_Literal_After`, `Work_Tail`, `Within_Work_Budget`,
  `Xor_Free_Model` and `Xor_Free` consume complete three-byte Character literals,
  including apostrophe, double quote and operator payloads. Those payloads
  neither spend arithmetic budget nor hide following source operators/xor.
  The 4,096-byte, 63-operator and 64-leaf constants are unchanged. Predefined
  Character adds no user-defined type/predicate, library call or type-proof entity.

One **nonblocking documentation improvement**: add the frontend slice-subtype,
conversion-to-parent and nonstatic-subtype early-return citations above to the
lead account. Its direct producer route inventory is correct, but spelling out
these exclusions makes the single-executable-traversal/conversion premise easier
to verify without reconstructing it from the inherited Image account. This
review closed that question by reading the retained source; no numerical
adjustment follows from it.

The independent arithmetic recomputation gives 5,689 safety-record allowances,
21,845 nested-loop notes, and **31,822,336 bytes**, below 33,554,432 by
**1,732,096 bytes**. Retained finite stress observations were read as corroboration,
not treated as proof of these counts or of solver/stack guarantees.

## Exact read inputs

Producer SPARK revision: `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
Frontend revision: `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
Retained producer paths are beneath the original checkout's
`tmp/review-capacity-343c2f8/tmp/producer-source/`; frontend paths are beneath
`tmp/frontend-capacity-20261016/`. Hashes below were recomputed from those bytes.

| Source input | SHA-256 |
| --- | --- |
| `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `src/why/why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `src/flow/flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| `src/spark/spark_util-types.adb` | `61c39d0e43f4b2d8f36a723d87b9061d2e14611296c2378473b509df42979cc9` |
| frontend `exp_util.adb` | `6fcf1cceaa505992e83e8f122eadc87f54b489a4208f55af14178ef04595b6a1` |
| frontend `exp_spark.adb` | `509e27a893828c31e7148f29470ab1fcbacd879242a1066dd22bdc3a6cf0fbfb` |
| frontend `sem_ch3.adb` | `198190171bcd99d293c3ec86a2ffe4ffb4a29276bfd205ebc4b9f0aea87d263f` |
| frontend `sem_ch4.adb` | `19e5386e0a2535c501d41c1d2338760fb4b3c7acaecef614e9bdd4a0cf2fb555` |
| frontend `sem_res.adb` | `6437a0b918e71a33a6dbdcc8d2d885069acac86ab9379f1daeb08591dcafb7c8` |
| native `silver_output_profile.adb` at `79b350912a` | `bcd6d9b3ebb814d13cbf9e9651bf10f5e25102030c9d42d879b022411415ed1b` |
| native `silver_output_profile.ads` at `79b350912a` | `799959ca7d49229dbe8bd748fc11c109839b3e77d95fdf3210ea422365754d6d` |

Inspected producer routes include expression lines 1384–1450, 14042–14089,
14287–14349, 21817–22351, 22832–23008, 23890–24000, 24715–24733,
25636–25720 and 29364–29515; conversion lines 982–1508, 1518–1620,
2425–2464, 2754–2825 and 3614–3634; flow lines 3648–3665 and 3935–4117.
Frontend checks covered light expansion dispatch, declaration subtype expansion,
explicit slice resolution/subtype construction and endpoint freezing.

The inherited accounts were read from the integration checkout at these SHA-256
identities (paths are relative to `docs/`):

| Account | SHA-256 |
| --- | --- |
| `named-integer-subtypes-report-capacity.md` | `4f6136d75bf4172c0ad48a2d810d94ecabb2da100c44840cc3c6c1fbac34b0af` |
| `fixed-integer-arrays-report-capacity.md` | `029a1c14afa9a4942c787e424784b8f57e4480e7860abd7adcc3deadf29888ae` |
| `constant-array-iteration-report-capacity.md` | `4b097ebd51acc24ac777ff5226fd80f76720c7ba69c5a4abf3465dc0654beebe` |
| `bounded-mutable-report-capacity.md` | `9a2fb56e9597e0273bf0246ee2fb9b75b2b04bd70bc6c70c70dedfff661bcaae` |
| `for-loops-report-capacity.md` | `fe4f403ab06b7f4a1f6ca63384bf655f5d2c452ce2e395a77a03d20a2805f26b` |
| `integer-division-report-capacity.md` | `709f2c48045ff5137b393de9ee43ecd48798235644f485aea1cf502c956cf3de` |
| `evidence/boolean-objects-20261030/producer-review.md` | `61f95df60436dba625b8e313a5febc6c345198a54dd567755ad2412b2298b7eb` |

Selected reviewer: GPT-6 Astra / Extra High, inherited and requested by the lead;
runtime model/effort was not independently confirmed. Source reading and identity
checks ran from 18:55:21 through 18:58:47 UTC (206 seconds); report preparation
followed. Token and cost measurements are unavailable. No separate CLI memory
entry was updated. This report supplies a capacity-review result only.
