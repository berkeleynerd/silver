# Image producer schema and node identity

This source review supports [assurance #15](https://github.com/berkeleynerd/silver/issues/15)
for [For loops and integers](for-loops-integers.md). It identifies the external
typed-JSON boundary used by the adapter proofs. The complete scanner/schema
composition and stable milestone validation remain outstanding; this review
does not replace them.

The reviewed producer is `spark2014` fsf-16 at
[`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`](https://github.com/AdaCore/spark2014/tree/42554fc241fcd1fdf08d3a2feccb3f86912acbc0),
with Why3 at
[`9390baf120ef260547dfa14f08e11c890b203d9c`](https://github.com/AdaCore/why3/tree/9390baf120ef260547dfa14f08e11c890b203d9c).
These are the reviewed release sources identified by the
[capacity record](report-capacity.md). This is source inspection, not an
attestation that an installed binary was built from those sources.

## Typed serialization

The existing GNATprove boundary supplies faithfully generated, well-typed Why
syntax and its JSON serialization. The adapter's proof may use that structure;
it must derive which selected theories match its templates, their normalized
content and their original byte offsets from the actual scanner.

| Reviewed source | Relevant behavior |
| --- | --- |
| [`gnat2why-driver.adb:1205`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-driver.adb#L1205) | `Print_GNAT_Json_File` emits exactly one root member, `theory_declarations`, containing the printing plan's theory list. |
| [`xtree_why_ast.adb:171`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/xgen/xtree_why_ast.adb#L171) | Generated node serialization emits an array whose first fields are the `W_` kind tag, a fresh decimal serialization counter and the common fields. It then emits kind-specific fields in their declared order. |
| [`xtree_sinfo.adb:724`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/xgen/xtree_sinfo.adb#L724) | A theory's kind-specific fields are declarations, name, kind, includes and comment. |
| [`why-atree-to_json.adb-tmpl:120`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/xgen/why-atree-to_json.adb-tmpl#L120) | Node references expand into full node values. Optional absent nodes/lists become `null`; present lists become arrays of expanded nodes. Internal list-storage IDs are not emitted as JSON node IDs. |
| [`gnat_ast.ml:2089`](https://github.com/AdaCore/why3/blob/9390baf120ef260547dfa14f08e11c890b203d9c/plugins/gnat_json/gnat_ast.ml#L2089) | The consumer requires exactly `[W_THEORY_DECLARATION, id, domain, declarations, name, kind, includes, comment]` and applies the corresponding typed conversions. |
| [`gnat_ast.ml:2504`](https://github.com/AdaCore/why3/blob/9390baf120ef260547dfa14f08e11c890b203d9c/plugins/gnat_json/gnat_ast.ml#L2504) | The consumer also requires the sole root field. |

Thus a generic theory permits `null` for an empty optional declarations or
includes list. The selected Image template has nonempty arrays in both
positions; their existence is a template-recognition conclusion, not a global
producer assumption. Whitespace and string escape spellings may differ without
changing the decoded structure. No global ASCII restriction is added to the
producer boundary: the scanner's live template-match argument establishes the
ASCII domain of an accepted selected template.

The scanner's `W_` array-head convention applies to this producer and Silver's
controlled source inputs. It is not a parser for arbitrary well-typed Why ASTs.
The primitive field inventory in `xtree_sinfo.adb` and the serializers in
`why-atree-to_json.adb-tmpl:32–102` identify the non-node arrays that can begin
with strings:

| Non-node array | Why its first string does not begin with `W_` |
| --- | --- |
| `Ureal` | Its first field is a quoted decimal numerator. |
| `Source_Ptr` | The selected application and library filenames are `main.adb` and fixed lowercase `silver_*` names. Silver excludes source-location override pragmas. |
| Symbol and string sets | Source names receive `name:` or `model_trace:` prefixes. Other generated labels use fixed prefixes/constants, including `GP_`, `model_`, `vc:annotation`, `branch_id=`, `RAC:assume`, `mlw:proxy_symbol`, and `introduced`. |

The relevant label construction is in
[`gnat2why-util.adb:932`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/gnat2why-util.adb#L932),
[`vc_kinds.ads:1246`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/common/vc_kinds.ads#L1246),
[`why-gen-expr.adb:4272`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/why-gen-expr.adb#L4272)
(also its shape, pretty-printing and VC-label routines), and
[`why-gen-names.adb:854`](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/why/why-gen-names.adb#L854).
The native driver selects the [canonical source filenames](../src/silver.adb).
Node lists begin with expanded node arrays rather than bare strings. Thus the
reviewed producer routes supply the normalization grammar's array-head premise;
an arbitrary external label set such as `["W_tag"]` would not satisfy it.

## Serialized IDs and the reserved insertion band

Review found that the earlier half-range justification used the wrong type.
`why-types.ads` defines internal `Why_Node_Id` in the lower half of a signed
32-bit domain, but the generated writer does **not** serialize that value.
`Print_Ada_Why_Node_To_Json` declares `Why_Node_Counter : Natural := 0`, increments
it once per serialized occurrence, and writes `Integer'Image (Why_Node_Counter)`.
The relevant producer bound on the pinned platforms is therefore **2147483647**.

The correction admits that complete producer counter domain and reserves
**2147483648 through 2147483670** for the adapter's 23 inserted nodes. The
consumer's [`int_from_json`](https://github.com/AdaCore/why3/blob/9390baf120ef260547dfa14f08e11c890b203d9c/plugins/gnat_json/gnat_ast.ml#L1332)
retains an OCaml `int`, with no signed-32-bit conversion. On Silver's supported
64-bit hosts this is a signed 63-bit integer with maximum **4611686018427387903**.
The inserted
IDs are serialized constant digits, not values stored in the SPARK scanner's
`Original_Node_Id` subtype. Both the old and corrected inserted IDs have ten decimal digits,
so the two fragment lengths and their chunk boundaries are unchanged.

The scanner validates every recognized incoming node-ID field against the full
producer bound; its decimal overflow guard still rejects values above that
bound. Freshness follows from that checked numeric domain and the unique
inserted band. It does not require a guessed bound on the number of serialized
nodes in a Silver program. The corrected mathematical constants, native range,
source shape and concrete fragment payloads must be reviewed and checked
together.

The correction is implemented by `b8a65356e5` (template digits) and `fb7837abab`
(native and mathematical bounds plus the two corresponding source-shape
literals). `ca6bd9f102` adds the native scanner probe and boundary tests. Focused
Linux x86-64 validation in the isolated native worktree passed:

| Managed run | Evidence scope |
| --- | --- |
| `20261016T171716-d6f25592e8e9` | Three tests: upper-half and maximum producer IDs at top level and in typed nested namespace declarations; negative/out-of-range rejection; all 23 actual inserted IDs unique, fresh and consumer-representable. |
| `20261016T171734-718c72a90318` | Compiler and adapter build. |
| `20261016T171752-35f93cacc45b` | Twelve flow checks and seven selected runtime checks covering changed ID initialization, maximum tracking and decimal arithmetic. |

These results validate the changed native boundary. Integrated Lean source
checks, complete scanner/schema composition and the milestone's stable full
validation remain required.

## Clone interpretation

The consumer converts a clone's substitutions by their explicit kind:
type substitutions become `CStsym`, and function substitutions become `CSfsym`.
[`gnat_ast_to_ptree.ml:1240`](https://github.com/AdaCore/why3/blob/9390baf120ef260547dfa14f08e11c890b203d9c/plugins/gnat_json/gnat_ast_to_ptree.ml#L1240)
resolves their qualified names and constructs the clone import with `axiom .`.
The latter is the external representation of the independently proved
Integer Image length theorem. The adapter must establish its exact five
substitutions and the selected native symbol/type identities; merely providing
a compatible theorem name is insufficient.

Original declarations, source labels and required checks remain in their
original byte order. The Files splice argument establishes byte preservation;
the typed schema/clone argument establishes what the two additions mean.
Faithful external JSON parsing, name resolution and Why3 translation remain
part of the documented [tool boundary](trusted-boundary.md), while the
Silver-owned matching, offsets, payloads and semantic refinement require their
own checked correspondence.
