# Constant Integer-array iteration: producer and report capacity

Feature-local account for [#264](https://github.com/berkeleynerd/silver/issues/264),
2026-10-28. This extends the [fixed-array account](fixed-integer-arrays-report-capacity.md)
for `for E of [reverse] A loop`, where `A` is a visible constant array. It keeps
4,096 source bytes, 63 operators, 64 expression leaves and the existing 32 MiB
Main report allocation. It does not reopen #119 or establish the capability's
complete assurance checkpoint.

## Selected producer route

The producer/frontend revisions and trust boundary are those of the fixed-array
account: SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, GCC frontend
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, and the recorded GNAT-FSF recipe.
This is source inspection under that boundary, not a new binary-attestation claim.

| Input | SHA-256 |
| --- | --- |
| frontend `exp_ch5.adb` | `99faebd687725d617d9a0c56c2a217cb8df6d23306e01b469241238caf1804b6` |
| frontend `exp_spark.adb` | `509e27a893828c31e7148f29470ab1fcbacd879242a1066dd22bdc3a6cf0fbfb` |
| producer `gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| producer `gnat2why-expr-loops.adb` | `5ff0a390fc6ec746c065d21a2438238612b2cfa3ea3a0c3b9ed2021c8a771707` |

The additional frontend file was obtained from its
[pinned upstream revision](https://github.com/gcc-mirror/gcc/blob/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea/gcc/ada/exp_ch5.adb)
and retained in the integration worktree's
`.silver/linux-x86_64/constant-array-producer/`. Other files retain the locations
in the fixed-array account.

`exp_spark.adb:897–912` selects `Expand_Iterator_Loop_Over_Array` during SPARK
expansion. `exp_ch5.adb:5056–5214` creates one cursor loop over `A'Range`, retains
`reverse`, and inserts `E : Integer renames A(Cursor)`. The array has one
dimension; no extra dimension loop is generated. Filters and container-iterator
calls are outside this fragment. `exp_spark.adb:1070–1110` replaces each use of
the renaming with its indexed component. This preserves actual-component
semantics. Silver itself admits, proves and compiles the original bytes.

The resulting loop takes the existing counted-range path in
`gnat2why-expr-loops.adb:727–750,965–986`, not the container primitive route.
The established finite-range discharge argument applies to the hidden cursor.
Its bound type and the declared array range agree. Each element read takes the
existing one-dimensional index-check route, and the loop range establishes that
index's validity. The full Integer component type needs no new predicate or
component-range assumption. Constancy preserves the component while guards on
`E` refine its value within a body. The universal model and correspondence proofs
must establish that preservation and composition separately.

`gnat2why-expr.adb:22832–22841` also evaluates the generated renaming's name
once at its declaration, even if `E` is unused. Conservatively charge one
implicit index check for it, plus one for each source element reference. Each
reference lies in the executable body, not an initializer or constant defining
axiom; the retained single executable traversal applies. Array-index reads and
ordinary arithmetic/root checks retain their existing charges. No new Main
proof rule, call dependency, entity or warning policy is required. Generated
internal objects retain the existing exclusion from positive initialization
messages; the loop is not a new source subprogram or type-VC trigger.

## Combined source charge

The shortest element-loop prefix `for E of A loop` occupies 15 bytes, followed
by nine-byte `end loop;`. Thus all admitted loops satisfy the conservative
combined charge `24*L + 8*W <= S` with indexed writes `W`; the earlier 27-byte
charge applies only to counted loops. The same nested-loop warning route can
emit at most `L*W` array-initialization notes. Neither a read-only element
renaming nor the hidden cursor adds an indexed assignment. Therefore:

```text
array notes <= floor(S*S / (4*24*8)) = 21,845 at S = 4096
```

Retain the fixed-array joint `floor(S/2)` allowance for ordinary roots,
comparisons, aggregate components and explicit index sites. For the new implicit
index reads, each element-reference identifier consumes at least one identifier
byte and one following separating byte. These pairs are distinct among
references: adjacent identifiers require separation, and punctuation ends each
reference before the next identifier. Longer names and comments only increase
the charge. Thus another independent `floor(S/2)` allowance covers all element
references. It deliberately overlaps the other conservative buckets.

Charge three checks per loop prefix: the existing two bound-root allowance and
one generated renaming index check. Counted loops need no renaming, and array
ranges are static, but charging all three to every loop avoids relying on their
elimination. Together with the retained record sizes and metadata/flow/Image
allowances:

```text
checks = floor(S/2) + 3*63 + floor(S/13) + 3*floor(S/15) + floor(S/2)
Main = checks*2048 + (2*S + 2*floor(S/16))*1024 + 2*S + 65536
       + floor(S*S / (4*24*8))*512

S = 4096: checks = 5,419
Main = 31,269,376 bytes
33,554,432 - 31,269,376 = 2,285,056 bytes of headroom
```

The 32 MiB Main allocation and 262,144-byte runtime allocation remain unchanged.
The existing capacity regression checks both the schemas and this formula; run
`20261028T101935-1999ea6cf962` passed the focused envelope check. These are
conservative cardinality bounds, not a prediction of actual report size.

The element syntax also preserves the existing 12-byte charge per scalar
binding: its 15-byte prefix exceeds that charge. No scalar-slot limit changes.

## Corroborating producer probe

Managed run `20261028T101914-67c513028724` used the production
`--no-loop-unrolling` setting on forward/reverse iteration, guarded arithmetic
and indexing through the element, nesting and writes to another mutable array.
It passed three source checks: overflow at 8:22 and index checks at 8:13 and
19:16. The report has one application entity, no flow diagnostics and three
existing array-initialization notes (the nested write appears twice). No
implicit iterator check survived to the report. The envelope nevertheless
charges those possible check sites.

Sources, GPR, log, generated Why and report are retained beneath
`tmp/constant-array-native/tmp/foreach-producer-probe/`, including
`obj/explore/no-unroll/gnatprove/iteration_probe.{mlw,spark}`. The earlier probe
with an output-containing input directory failed managed input identity; it
remains failed. A following exploratory run omitted no-loop-unrolling and is
not substituted for this production-setting observation.

These probes corroborate producer routes; they do not establish universal
assurance or replace the final native/Lean/source checkpoint. Independent
integration review of this account remains pending. Lead runtime model/effort
and token/cost measurements are not independently available.
