# Native expansion component delta review

2026-10-18. Refs #119. Frozen review target: `cbcd679320`.

No material finding in the reviewed delta. The new local transfers are
consistent with the pinned source under their stated premises. They do not
close native String concatenation or justify changing Silver admission.

## Scope and method

This review covers the additions to
[retained-native-expansion.md](../research/retained-native-expansion.md) and its
evidence since the earlier `0cd5b74cc7` review, specifically:

| Commit | Reviewed addition |
| --- | --- |
| `8d77a15af7` | Explicit index layout and dynamic range-check construction |
| `634b125cfa` | Scalar range analysis and complete compile-time comparison |
| `44dfcfaecc` | Resolved constrained subtype and ordinary for-range capture placement |
| `3ff3cef131` | Generated Integer addition/subtraction |
| `b708002f91` | Generated scalar conditional expressions |
| `f56921ca63` | Generated Integer equality/inequality |
| `cbcd679320` | Final null-literal subtraction in direct arithmetic count |

The work was source inspection and short Python arithmetic/hash checks. The
reviewer read the selected paths in GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, including the called numeric
primitives, folding, resolution, naming, construction and relevant dispatch
guards. The local source directory was
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`.

The submitted `derive.py` reproduced `local-envelope.json` byte-identically:
49 source files, 144 lexical call sites, direct ordinary envelope `25*n+45`.
The output SHA256 is
`9b6eee8113a74c5d0581b1810d76fb00f7a00407a723f77016bb38282779d4a5`.
That script checks the retained source manifest; it does not independently
prove the manual control-flow argument. A separate
[review checker](../evidence/review-retained-native-cbcd679320/check.py)
reconstructs the direct generated operator sites and arithmetic sums without
importing the submitted checker. Its
[output](../evidence/review-retained-native-cbcd679320/result.json) retains
the source hashes and inventory. Both checks preserve the distinction between
lexical occurrence, conditional transfer and whole-source reachability.

No compiler, native stress program, GNATprove, Lean, full suite, tool rebuild
or source-to-installed-binary comparison ran. No existing report, production
source, issue or board entry was changed by this review.

## Checked conclusions

### Explicit index layout

For the report's signed Integer subtype and selected 32-bit bound premises,
the `Minimum_Size` signed search requires at most 32 tests and powers through
`2**31`. Each test can negate its power twice. Extending the power cache takes
at most 31 multiplications. Thus 95 cumulative Uint appends, 285 retained
digit words and 95 possible cache insertions are sufficient. The largest
power-extension multiplication has operand lengths at most three and one,
and a four-word product vector, giving the eight-word local vector bound.

The source evidence is `sem_ch13.adb:16076–16303`,
`layout.adb:900–933`, `uintp.adb:1361–1405,2020–2071` and the immediate
bound/static-match helpers. Cache extension can retain a previous pool
prefix; the report correctly uses cumulative append counts rather than
assuming release of that prefix.

### Dynamic range checks and scalar comparison

Suppression is tested at insertion, after the dynamic check tree has been
built. The constructor's charge is two copies of each bound, six conversions
at up to three shallow nodes each, two attribute/prefix pairs and six logical,
relational or raise nodes: `2*b+28`. Existing-value comparisons are additional
only where they invoke the separately charged scalar comparison transfer.

The range-analysis weights cover the selected arithmetic branches in
`checks.adb:4620–4913,5071–5654,6112–6127`. Multiplication has four endpoint
products plus up to two reappended selected values from `Release_And_Save`;
the local charge is six, not four. String Length can compute two
`High-Low+1` expressions, also costing six. Internal constant initializers are
followed before the range cache is consulted, so the report correctly counts
their unfolding repeatedly and requires an acyclic graph.

For `Compile_Time_Compare`, the four `Rec => True` call sites cannot recurse
again. Across the resulting at most five calls there are ten range queries
and at most ten pair walks. A pair walk visits corresponding operand children,
not their cross product. `Compare_Fixup` may allocate one literal and one
Uint addition per input for String-literal Last. These paths yield
`20*A` ordinary nodes and `60*A + 20*A + 60 = 80*A+60` Uint appends.
The extra twelve-per-comparison constant conservatively covers decomposition,
differences and current-value condition adjustments.

The magnitude recurrence includes intermediate estimates that can lie beyond
the base subtype, the literal-Last sum and the comparison's differences and
unit adjustments. The local vector bound `5*k+3` covers addition, four-vector
multiplication and the two vectors saved across pool release. Expression
traversal stack demand remains explicitly separate.

### Resolved constrained subtype and capture placement

For one artificial local String subtype with already resolved, pure bounds
and suppressed checks, `Constrain_Array` shares the existing constraint
list/range and creates only one signed index entity. `Resolve_Range` may
perform two static folds, each adding a literal and saved original, with
one possible growing event. The array-index range-check tail does not apply
again to an index that remains `N_Range`.

Adding these folds to check construction and scalar comparison gives
`2*b+32+20*A` nodes, two growing events and `80*A+155` Uint appends after the
95-entry layout charge. `Create_Itype` with a related identifier uses a derived
external name, not the unit-serial scheme. Prefix, suffix, index 1 and NUL
add four characters to the subtype name. The separate plain-object subtype
name path consequently gives the recorded 33-character combined maximum
when its originating temporary name has at most twelve characters.

The declaration result is explicitly conditional on already analyzed bounds.
It does not price their first analysis, enabled range checks, capture or
transient placement as zero. For ordinary for-range captures,
`Insert_Actions` reaches the loop's statement-list position; its special
iteration-scheme condition does not match a for range. An enclosing if or
loop is not traversed after that stop. This placement trace is consistent
with the separately reviewed producer argument.

### Generated Integer arithmetic, conditionals and comparisons

For generated same-type Integer arithmetic with already analyzed children,
suppressed checks, fitting static results and the stated flags, the single
interpretation remains in the node. Folding charges one numeric operation,
one replacement literal and at most one saved original/growing event.
The zero-identity expansion has no larger cost. The two-node, one-growing,
two-Uint local envelope is sufficient.

The direct emitter count is now correct:

```text
1 final null-literal subtraction
+ (n-1) aggregate additions
+ 2 high-bound operators
+ 3*n slice-endpoint operators
= 4*n+2.
```

The added `Make_Op_Subtract` at `exp_ch4.adb:2884` can be constructed even
when later operand elimination avoids a normal multioperand result. It must
remain charged. The report does so; the initial local transfer is therefore
`8*n+4` ordinary nodes/Uints and `4*n+2` growing events when all premises hold.

For a generated complete scalar if expression, the already analyzed
condition/branches and equal context types avoid further operand/conversion
analysis. Static semantic folding or later known-condition expansion requires
one relocation and at most one saved original/growing event. These folds do
not accumulate: subsequent dispatch sees the replacement node. The excluded
actions, delayed expansion, hardbool, coverage and transient routes explain
why the unknown-condition path has no further allocation. The `n+2` direct
conditional count is conservative.

Generated Eq/Ne can make one semantic comparison query and one expander
query, giving `40*A` nodes and `160*A+120` Uint appends. Charging both possible
folding routes gives another five nodes and two growing events, although the
successful routes are mutually exclusive. Artificial Original_Node excludes
the warning path's additional Test_Comparison. The Length optimization only
recognizes a root attribute, possibly through artificial conversions, and
does not follow a captured name's initializer to find one.

`Expand_N_Op_Eq` eagerly allocates its `Bodies` list before dispatch even
for Integer. The report includes one list for Eq and none for Ne; the direct
emitter makes only two equalities, with lower-bound selectors and slice guards
using inequality. Hence the final direct count `2*n+2` comparisons and at
most two equality lists is supported.

## Nonfinding and remaining limits

The evidence README still says forty-one source files and that no independent
review has yet completed. The first statement is stale relative to the
49-file report/checker; both statements predate this delta. This review does
not treat that wording as a new technical finding. A future documentation
refresh can link the reviews and synchronize the inventory count.

The reviewed bounds remain local conditional transfers. They do not derive
all admitted-source shapes, initializer graph sizes and magnitudes, nor
compilation-wide copy/reanalysis counts. Enabled-check/plain-storage paths,
runtime dependencies, full backend and linker costs, and exact installed
source identity remain separate obligations. No new capacity rule or
dependent compiler/proof change is authorized by this review result alone.
