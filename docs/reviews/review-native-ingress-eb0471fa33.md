# Independent review: literal native ingress

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and BIND-accounting finding
[#130](https://github.com/berkeleynerd/silver/issues/130).

**Disposition: scoped acceptance; no new material finding.** The frozen
packet supports its conditional whole-body occurrence bound, selected
materialization-copy delta and BIND correction. It does not establish complete
native capacity or authorize a production admission change.

## Exact inputs and review scope

The review target was
`eb0471fa33b7c8b23bfdf0456c32e8aa4f9a79df`, checked out clean on
`review/native-ingress-eb0471fa33` in an isolated worktree. The six-file change
is the [ingress argument](../research/retained-native-ingress-bound.md) and
the five files in
[its evidence packet](../evidence/retained-native-ingress-bound-20261018/README.md):
`README.md`, `derive.py`, `check.py`, `check-results.json` and
`source-manifest.json`.

I read the applicable `AGENTS.md`, Oracle, retained-tool authorization in
session memory, and review bookkeeping. I reused the accepted
[literal lowering](../research/retained-native-expansion.md#direct-literal-output-source-to-initial-gimple-and-data-operands)
and [general 3W transfer](../research/retained-backend-capacity.md#whole-body-copying-include-protected-children-and-declaration-metadata).
The task was to challenge their new source-to-input specialization, not
reprove those predecessor interfaces or replay the aggregate pipeline.

The source capsule contains 28 complete GCC files at recorded commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The offline check verified their
lengths and SHA-256 identities; a separate direct calculation also matched
all 28 recorded Git blob identities. I inspected the cited source branches
in those files, including the surrounding type-construction and conversion
tails. This is review of the retained source, under the existing installed
behavior and LP64 layout correspondence premises; it is not a fresh binary
attestation.

I also read the named parent repair
`e4d170e8edb871759593df77afe2151a79353c3d`, specifically its `compose.py`,
`check.py` and `retained-literal-pipeline.md` changes. The assessment below
covers the BIND/CF/stack/local-variable interfaces of that repair only.

## Source findings

### Root inventory and metadata

The inventory covers the hidden gigi declaration roots that executable
GIMPLE counts alone would miss:

- Each associated literal subtype creates one artificial index TYPE_DECL
  through `create_index_type`, and one nonshared array TYPE_DECL in the
  common type tail (`decl.cc:3142–3193,5012–5020`;
  `utils.cc:2861–2892,2935–2988`). The separate Ada/RM range constructor
  creates no declaration. Existing entity association prevents another full
  conversion of the same subtype.
- For ordinary Character and static `1..L` bounds, including `1..0`, the
  selected array layout has constant size and component alignment. The
  size/padding tail neither introduces a padding declaration nor elaborates
  a symbolic size (`decl.cc:4533–5010`; `stor-layout.cc:2662–2767`;
  `utils.cc:1522–1613,1734–1748`). The literal-specific freeze path adds no
  representation change (`freeze.adb:773–794,822–833`).
- Imported public nondefining entities are converted under `force_global`,
  including their recursive type/profile helpers. `gnat_pushdecl` and
  `add_decl_expr` keep those declarations out of Main's local statement
  forest (`decl.cc:507–517,5118–5119`; `utils.cc:674–676,982–987`;
  `trans.cc:9117–9137`). Main's own declaration precedes entry into Main.
  Mere callee or expression-type references do not open all declaration
  metadata in the walker.
- A null contributes at most its label DECL_EXPR, GOTO_EXPR and LABEL_EXPR.
  Call argument-list construction does not leave a TREE_LIST in CALL_EXPR;
  the retained call stores one actual in its physical operand array.
  Empty call markers and statement lists contribute no ordinary copy weight.

The actual walker was checked at `tree.cc:11637–12003`. BIND opens declaration
INITIAL/SIZE/SIZE_UNIT and its body; DECL_EXPR opens the selected type fields.
Those declaration fields are null for the local TYPE_DECL/LABEL_DECLs.
Main's void result sizes are null. The local type bounds and sizes are
integer constants. `DECL_ORIGINAL_TYPE` is null: the selected setter requires
a named nonartificial pointer/fat/extended-pointer type. The index's
TYPE_INDEX_TYPE and TYPE_RM_VALUES are separate fields, and its fresh range
has no RM endpoint vector. Consequently neither the Ada RM hook nor
`gimplify_type_sizes` reaches a nonconstant size expression through these
roots (`trans.cc:9375–9407`; `gimplify.cc:2124–2158,21600–21739`).

The reached ordinary type links are array-to-Character/index, so the special
three-pointer-chain duplicate-set path is absent. This supports zero
pointer-type walker-set requests for this invocation; it says nothing about
sets used in original global type construction.

The additional function-level gigi BLOCK was checked as well:
`begin_subprog_body` pushes it, while `end_subprog_body` records/pops it
without creating another BIND around the returned body
(`utils.cc:3830–3870`). The body statement group and sequential call groups
give at most C+1 protected BIND identities and nesting depth two, under the
accepted no-cleanup/no-copy-out shell.

### Retained address and occurrence accounting

The literal path produces STRING_CST. Taking its address produces
ADDR(STRING_CST). Source and target P_ARRAY types are ordinary pointers to
ordinary Character arrays in the same address space. I checked the intervening
`convert` cases, including padding, special expression cases, thin/fat
pointer adjustments and related-type conversion. The selected path can
retain one NOP around that address (`utils.cc:4794–4894,4999–5533`;
`utils2.cc:1712–1732`; `convert.cc:54–74`).

The generated-rule inventory is relevant evidence rather than a substitute
for folder inspection. I checked its alias and optional-root handling against
`genmatch`, the conversion dispatcher, and the included builtin-list
generator. The 19 conversion-root forms have no applicable shape-expanding
rule for ADDR(STRING_CST). The wildcard `cvt(@0)` rule requires exact type
identity in GENERIC and returns its operand. The handwritten unary folder's
constant, distribution, handled-component and other conversion rewrites also
do not match this address (`fold-const.cc:9204–9516`). Repeating `fold` adds
no wrapper. Thus the claimed retained subtree is justified independently of
whether the pointer-type identities happen to coincide.

Applying the accepted 3W transfer to incoming-edge occurrences, rather than
unique node identities, gives the packet's W <= 9C+3N+1. Constants,
declarations and types remain cut points; protected children and declaration
metadata have been included separately. Sharing across calls cannot reduce
the number of charged source occurrences in this upper bound. Premarked
trees are covered by the reused transfer, not assumed absent.

Each of the two constructors has two elements. `copy_tree_r` calls one
`vec_safe_copy` per copied constructor; the null-vector reservation initially
allocates four slots even though `embedded_init` subsequently reports two
(`tree-inline.cc:5770–5790`; `vec.h:731–740,999–1016`). Hence 6C vector
requests, each 72 raw/128 rounded bytes, specialize the general transfer's
element bound safely. The checked totals are:

| Selected whole-body cost | Upper bound |
| --- | ---: |
| Ordinary tree requests | 27C+9N+3 |
| Tree plus constructor-vector requests | 33C+9N+3 |
| Raw request-byte sum | 1320C+288N+96 |
| Rounded request-byte sum | 1728C+288N+96 |

The materialization unshare separately copies at most the P_ARRAY ADDR and
NOP: 2C additional 32-byte requests. It therefore raises the accepted selected
6C helper subtotal to 8C. Neither term copies literal payloads or introduces
type/declaration UID events. These are allocation-request bounds, not live
memory or peak-memory bounds.

### Hash backing and parent BIND repair

The protected set is nonlazy and starts with 13 pointer slots. Expansion
precedes lookup, so a repeated insertion may trigger growth. Nevertheless,
with no deletions, a growth leaves load at most one half and another growth
requires additional fresh entries. At most C+1 distinct protected identities
therefore give at most C+2 backing requests and the stated
`prime(max(13,2(C+1)))` slot ceiling. This argument covers repeated hits;
it does not rely only on the finite hash examples.

`selected_prime_table_condition` checks prime existence only. In particular,
the last retained prime does not by itself establish probe-arithmetic or
individual allocation-domain safety. Those joins must remain explicit in
the aggregate; the packet already leaves map/hash capacity and complete
capacity open. Ordinary backing and the set object must not be added as
GGC tree events.

The parent repair agrees with the source. A procedure call pushes a scope
before translating its actual. A TYPE_DECL-only BLOCK can survive
`gnat_poplevel`; `end_stmt_group` then emits BIND_EXPR, and
`gimplify_bind_expr` emits its GIMPLE_BIND unconditionally. The safe direct
subtotal is 10C+2N+2, with C+1 bind tuples. `reserve(8)` means eight free
slots: depth two requires capacities 8 then 16, requests 72 then 136 bytes,
208 cumulative bytes, and at most two requests. Sibling calls reuse capacity.

CF calls `gimple_set_block` on inner binds before dispatch. The outer bind
is lowered directly, so adding at most C inner-bind calls gives the repaired
4C+2N+2 interface. `record_vars_into` skips TYPE_DECL/LABEL_DECL; its vector
still receives at most C descriptor variables. Original BIND cleanup scans
also require VAR_DECL, while descriptor temporaries are attached after body
gimplification. Thus the repair does not add cleanup or executable CFG
vertices. This confirms an accounting correction, not an observed native
counterexample.

## Evidence, limits and round record

One focused replay was run:

```sh
python3 -B docs/evidence/retained-native-ingress-bound-20261018/check.py
```

It passed on Linux x86-64 (`Linux-7.0.14-x86_64-with-glibc2.43`) in
0.076890647 seconds: 28 source files, 882 simplify forms, 19 conversion-root
forms, 257 no-delete hash populations, eight arithmetic/prime boundary cases
and six invalid-counter cases. The fresh output is retained in local scratch
`/tmp/silver-review-native-ingress-eb0471fa33/check-results.json`.
The committed historical check result was not overwritten.

The selected reviewer setting was **GPT-6 Astra / Extra High**. Independent
runtime confirmation of model/effort and token/cost measurements were
unavailable. Review began at 2026-10-18 19:26:39 UTC; source review, replay
and report were completed at 19:30:26 UTC, an elapsed 227 seconds. This is
the review round's elapsed time, not whole-team runtime. The intended outcome was a critical
source projection review; the achieved result is the scoped acceptance above,
without implementation rework or a new finding.

Complete gigi, complete gimplifier lifetime, incoming nowarn-map population
and backing, collector/page accounting, global native counters, complete
launch inputs and whole-pipeline capacity remain unestablished. Production
admission is unchanged. No native compiler/prover/debugger execution, broad
suite, aggregate replay, recursive delegation or GitHub write occurred.
The live harness query returned no goal; no goal was created or changed.
CLI memory was not updated. The parent owns aggregate attachment, durable
task integration and publication.
