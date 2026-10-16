# Frontend and retained-warning capacity review — 2026-10-16

This source review covers immutable signed Integer arithmetic, finite counted
loops and Integer'Image. The review itself was read-only and launched no
validation workload. It supports
[the extended retained-data envelope](report-capacity.md#for-loops-and-integers-extension)
for work package [#13](https://github.com/berkeleynerd/silver/issues/13).
Native inspection host: Linux x86_64. Source fetch URLs and SHA256 values are
retained in `tmp/frontend-capacity-20261016/fetch-manifest.json`; the pinned
revisions below make the reviewed sources reproducible.

## Provenance

- Producer: AdaCore/spark2014, fsf-16, commit
  `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`; retained checkout at
  `tmp/review-capacity-343c2f8/tmp/producer-source/`. Its Why3 submodule is
  `9390baf120ef260547dfa14f08e11c890b203d9c`.
- Recipe: alire-project/GNAT-FSF-builds release tag `gnatprove-16.1.0-1`,
  commit `0334dd54a2c479faa3dfad47a911373581b11739`.
  `gcc.anod:13–28` selects GCC 16.1.0; `spark2014.anod:172–174` copies
  `gcc/gcc/ada` into `gnat2why/gnat_src`.
- Frontend: gcc-mirror/gcc tag `releases/gcc-16.1.0`, annotated tag object
  `fe7c47a8e79e165fc686592d895402744e6b54c1`, commit
  `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
- The retained `fetch-manifest.json` gives every fetched URL, local path and SHA256.
  These are release-recipe/source inspection inputs, not an attestation that an
  installed binary was built from these exact bytes.

Below, **P** means producer `src/`; **F** means a fetched GCC file in `tmp/frontend-capacity-20261016/`; **S** means current Silver repository `src/`.

## Image warning emission and multiplicity

`P/why/gnat2why-expr.adb:20256–20296` emits one `Warn_Imprecise_Image`
warning each time the Image expression is transformed, in every translation
domain. `P/utils/errout_wrapper.adb:874–918` always appends its JSON record even
when display is suppressed. `Add_Json_Msg` appends without deduplication at 189.
The driver puts it in top-level `warn_error` (`P/why/gnat2why-driver.adb:367`).
Thus one warning per textual occurrence is insufficient.

The reviewed admitted-language routes bound each source Image occurrence by
**two warning emissions**:

| Source context | Producer route |
| --- | --- |
| Declaration initializer | Executable initializer at `gnat2why-expr.adb:1450`; an immutable defining axiom can translate it once more at `gnat2why-decls.adb:238`, called at `gnat2why-driver.adb:1548–1549` |
| Assignment | RHS transformed once at `gnat2why-expr.adb:19105` |
| Output argument | Actual transformed at `gnat2why-expr.adb:4581`; later call processing reuses that result |
| String equality | Operands transformed once each at `gnat2why-expr.adb:21854,21859` |
| Concatenation | Children transformed once at `gnat2why-expr.adb:24718,24720` |
| Short circuit | Operands transformed once at `gnat2why-expr.adb:24658,24687` |
| Identifier use | Stored item reconstructed, initializer not retransformed, at `gnat2why-expr.adb:26876–26925` |
| Generated actions | Preparation only registers a symbol at `gnat2why-expr.adb:15543–15552`; action initializer transformed once per enclosing traversal at 15460 |
| Main and loops | Declarations/body translated once at `gnat2why-subprograms.adb:5853–5864`; without invariant pragmas loop statements occupy one final list (`gnat2why-expr-loops.adb:510–517,802`). Unrolling repeats already translated `W_Prog_Id` at 2101; Silver additionally passes `--no-loop-unrolling` |

The frontend does not introduce further Image-bearing copies on these paths:

1. `P/why/back_end.adb:126–130` enables GNATprove mode. `F/expander.adb:110–127`
   dispatches to light SPARK expansion and bypasses regular transient-scope
   expansion. `F/expander.ads:149–158` states that `Expander_Active` is false
   in this mode; save/restore cannot enable it (`expander.adb:572–574,599–601`).
2. `F/exp_spark.adb:119–202` has no expansion for ordinary assignment,
   procedure call, concatenation or equality; Integer Image falls through
   attribute expansion unchanged (`772–880`). String `/=` is the exception:
   `exp_spark.adb:1008–1021` delegates to `exp_ch4.adb:10230–10248`, which
   rewrites to `not (Left = Right)` using each operand exactly once. Operand
   validity insertion is disabled (`gnat1drv.adb:511–516`,
   `exp_ch4.adb:298–304`), and length optimization is bypassed at 10252–10256.
3. Semantic concatenation walks/resolves the existing children
   (`F/sem_ch4.adb:1916–2063`, `sem_res.adb:10570–10832`). Its result is the
   base String type (10792); String literal subtype creation applies only to
   literal/external initializer nodes (`sem_res.adb:13219–13222`). Integer
   Image is nonstatic (`sem_attr.adb:9719–9745`), so concatenation folding
   does not create an Image-bearing static literal (`sem_eval.adb:2368–2372`).
4. Ordinary assignment resolves the existing RHS (`F/sem_ch5.adb:787–791`);
   subtype reconstruction is restricted to out/in-out parameters, component
   references/dereferences and slices (`289–364`), none of which can contain
   an admitted Image RHS in that role. Output actuals likewise resolve once
   (`sem_res.adb:4650–4652`). Assignment and parameter length-check insertion
   converges on `checks.adb:3509–3534`, which returns when expansion is off.
   Equality resolves each existing operand (`sem_res.adb:9143–9144`).
5. Potential dynamic implicit String subtype bounds were checked explicitly:
   String object declarations call `Expand_Subtype_From_Expr`
   (`F/sem_ch3.adb:5138–5143`), but it returns immediately in GNATprove mode
   for nonstatic initializers (`exp_util.adb:5884–5892`). Integer Image is
   nonstatic and has Standard_String type (`sem_attr.adb:1587–1602,9719–9745`).
   Therefore the producer's dynamic-IType bound translation
   (`P/why/why-gen-expr.adb:3614–3634`) cannot retranslate copied Image
   initializers through this path.
6. Even the generic GNATprove temporary path relocates the expression into
   one declaration (`F/exp_util.adb:12993–13031,13091–13096`) and uses its
   identifier thereafter; the producer action routes above do not separately
   evaluate the initializer during preparation.

**Remaining multiplicity gap:** none found for the admitted grammar under the
pinned frontend/producer and fixed invocation. This is a source-review sizing
argument, not a new formal source-correspondence proof or evidence from samples.
It must be revisited if new expression contexts, pragmas, types, frontend modes,
or producer versions are admitted.

## Warning size charge

The Image warning text is fixed (`P/common/vc_kinds.ads:810–813`);
`Create_N` substitutes only the fixed Image attribute name
(`P/utils/errout_wrapper.adb:346–393`). No unresolved message placeholders
remain (`651–668`). The warning leaves entity, proof tree, statistics, trace,
counterexample, VC location and continuations at empty defaults
(`errout_wrapper.ads:101–123`, `errout_wrapper.adb:903–916`). File is `main.adb`,
positions have the retained native scalar widths, and there is no user-identifier
payload. Its fixed schema fits the conservative 1024-byte record allowance;
a prior serialization of this schema with 32-bit positions and pretty-print
separators occupied 535 bytes, an illustration rather than a universal sample
argument.

The shortest occurrence `Integer'Image(0)` is 16 bytes. Therefore the extra
retained Image-warning allowance is
`2 * floor(S/16) * 1024`, at most **524,288 bytes** for `S=4096`.

## Signed literals and the independent operator budget

`F/sem_res.adb:12798–12808` calls `Eval_Unary_Op` before enabling overflow,
and only enables it if the result is still an operator node.
`sem_eval.adb:7166–7222` permits folding a static well-typed non-raising
operand; `4351–4403` calculates integer unary plus/minus and invokes
`Fold_Uint`; `5185–5187` rewrites the node to `N_Integer_Literal`.
`P/why/spark_atree.ads:275` aliases actual frontend Nkind, while the overflow
wrapper at `gnat2why-expr.adb:25522–25526` excludes Integer literals.
Unary plus is also exempt in `F/checks.adb:445–446`.

The disable-folding flag is **lowercase `-gnatd.f`**, `Debug_Flag_Dot_F`
(`F/sem_eval.adb:7242–7244`), not uppercase `-gnatd.F`.
Silver's generated project and proof arguments (`S/silver.adb:103–123`)
do not supply this flag. The producer has no reference to `Debug_Flag_Dot_F`;
its pretty-print flag `Debug_Flag_FF` and M/_F flags are distinct
(`P/why/back_end.adb:144–149,187–191`). Uppercase `-gnatd.F`
means `Debug_Flag_Dot_FF`, enabling GNATprove mode (`F/gnat1drv.adb:416–419`).

The overflow-count budget does not need to rely on signed-literal folding:

- The admitted scalar grammar accepts only unary `+`, `-`
  (`S/silver_scalar_expressions.adb:160–163,174–195,239–240`) and binary
  `+`, `-`, `*` (`219–221`). It does not admit `/`, `abs`, `mod`, `rem` or `**`.
- `Read_Integer` starts `Read_Mantissa` at the supplied position and consumes
  no leading sign (`S/silver_scalar_literals.adb:231–237`). A sign in a numeric
  exponent is literal syntax, not an Ada operator node.
- `Within_Work_Budget` skips comments/literal bytes and counts every source
  `&`, `+`, `-`, `*` (`S/silver_output_profile.adb:424–439`), including unary
  signs, against 63 (`silver_output_profile.ads:8–10`). The ghost specification
  agrees at `silver_output_profile.adb:393–408`.

## Loop and Integer flow-diagnostic sanity check

The accepted Main flow record policy remains precisely warning INEFFECTIVE
(initializer, fixed output advisory, unused assignment, or statement-no-effect)
and DEAD_CODE (statement unreachable):
`S/silver_library_reports.adb:1217–1239,1291–1314`.
No new accepted flow category is introduced by Integer declarations or loops.

- A counted loop adds one source-linked basic vertex and links the existing
  body graph (`P/flow/flow-control_flow_graph.adb:3441–3452,3472–3517`). An empty
  range disconnects the body (`3462–3468`); it does not copy it. Loop no-effect
  or unreachable advisories remain in the old source-position charges.
- The Ineffective branches are mutually exclusive; local constant
  declaration initialization advisories are explicitly skipped
  (`P/flow/flow-analysis.adb:1990–2055`, especially 1999–2003).
- Unreachable messages exclude path-copy vertices (`2080–2093`). Flow messages
  deduplicate by expanded message, source location and severity
  (`P/flow/flow_error_messages.adb:345–353,383–389`), unlike Image warnings.
- `Termination_Proved` returns True for counted range loops without emitting
  a diagnostic (`P/flow/flow_utility.adb:6833–6836`). Positive termination is
  at most one message per subprogram, conditional on an Always_Terminates
  aspect (`flow-analysis.adb:6461,6712–6722`). Plain Main procedure has no
  implicit aspect (`P/spark/spark_util-subprograms.adb:938–941`), and its
  default termination condition is Unspecified (`855–856`). There is no
  per-loop termination-success report charge.
- Constants and loop parameters start with Is_Initialized=True
  (`P/flow/flow-control_flow_graph-utility.adb:923–925`), so they do not enter
  initialization-info analysis (`flow-analysis.adb:3263–3267`). Generic unused
  objects can instead use `UNUSED_VARIABLE` (`1350–1359`); that is not an
  accepted Main advisory and must not be silently treated as one.
- Frontend null-range messages are ordinary compiler `Error_Msg_N` warnings
  (`F/sem_ch5.adb:3483–3527`), not producer flow diagnostics. GNATprove resets
  ordinary compiler warning options (`F/gnat1drv.adb:518–528`).

Thus the existing loose `2*S` **accepted Main flow-record** charge continues to
cover the added source constructs: at most the existing ineffective/dead-code
charges per ordinary source site, and the existing four output-ghost advisories
per output call. The existing user-identifier allowance need not expand:
accepted initialization advisory names are still bounded by unique declaration
text; constant Integer declarations do not add that advisory. This does not
claim that an arbitrary additional diagnostic would be accepted by current
policy.

## Other retained metadata

For unchanged runtime and prover drivers, these constructs add no entity,
coverage, dependency or timing cardinality beyond the existing allowance:
operators are intrinsic (`P/flow/flow_utility.adb:434–445`), Image adds no
attribute callee (`550–553`), dependencies/claims use sets/maps
(`P/why/gnat2why-assumptions.adb:48–69,88–103,136`), ordinary objects and loop
indices do not become coverage entities (`P/spark/spark_definition.adb:2329–2336`),
plain Integer/String types lack special type VCs
(`P/why/gnat2why-types.adb:1108–1141`), and default-type checks require a private
view (`P/spark/spark_util-types.adb:835–853`). Timing-owned entities exclude
objects (`P/why/gnat2why-driver.adb:1343–1350`) and keys aggregate
(`P/utils/debug-timing.adb:78–86,130–133`); entity identities are interned
(`P/common/assumption_types.adb:266–275`). The existing 65,536-byte metadata
allowance therefore remains applicable within those fixed-input premises.


## Scalar and loop proof-record sites

- Shared lexical work budget is 63 total `&`, unary/binary `+`/`-`, and `*` tokens. `silver_output_profile.adb` 386–445 calls `Read_Integer` before operator dispatch. `silver_scalar_literals.adb` 104–144 starts at the mantissa, with no leading sign; only exponent `+` is consumed as numeric syntax (179–218). Therefore all arithmetic AST operators are charged, including signs on literals.
- `gnat2why-expr.adb` 24127–24203 translates arithmetic operands once each to `Base_Why_Type`. Its common overflow wrapper at 25499–25575 inserts at most one overflow check in `EW_Prog`; `Insert_Overflow_Check` 12035–12057 contains one `New_VC_Call`. Term-domain constant axioms do not add those proof checks. Signed32 has no modular wrap, division, floating point or predicate paths.
- The final checked conversion is at 25641–25664. `why-gen-expr.adb` 1618–1645 checks only executable expressions with the frontend check flag; 2430–2467 leaves Range_Type empty for mathematical `EW_Int_Type`; 2759–2829 applies at most one scalar range check to a conversion. Thus arithmetic child conversions cannot multiply proof records.
- Scalar comparisons translate each operand once to shared base type (`gnat2why-expr.adb` 21945–21967). Integer Image similarly translates its argument once to `Base_Why_Type` (20256–20276), so neither creates an additional scalar root range check in this selected type.
- Scalar declaration initializer: `Assignment_Of_Obj_Decl`, 1385–1450, one executable transform to `Why_Type_Of_Entity`, hence at most one final scalar range check per declaration. `A:constant Integer:=0;` is 22 bytes. An extra `floor(S/22)` charge deliberately overcounts the existing generic assignment/declaration allowance.
- Plain for-loop index type is `Base_Why_Type` (`gnat2why-expr-loops.adb` 747), lower and upper bounds each transform once (1934–1958), and initialization/update use unlabelled `New_Assignment`/`New_Call` constructors (1353–1371,1458–1502). The `Check_Subtype_Indication` branch 1967 is excluded by the admitted raw `L .. U` syntax.
- `Wrap_Loop` 2236 assumes the implicit index/frame invariant; `New_Loop` 2268 receives only explicit User_Invariants (empty in admitted syntax). Explicit invariants/variants, iterable filters and generalized iterators are excluded. Dynamic termination VC in `gnat2why-expr.adb` 29872–29902 requires a dynamic subprogram termination condition plus a loop not known terminating; neither applies to ordinary finite for-ranges.
- `Unroll_Loop` (2050–2145, especially 2101) repeats an existing Why program rather than retranslating Ada; selected application policy already uses `--no-loop-unrolling`.
- Reserve two proof records per loop bound pair anyway, using disjoint minimum prefix `for I in 0..0 loop` = 18 bytes. This is an overcount: selected base-type root conversions do not register range records. Body/arithmetic records are counted at source occurrence, never multiplied by iteration count.

