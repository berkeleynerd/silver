# Independent initial CF/CFG and aggregate-attachment review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted within the stated conditional initial-CF/EH/CFG/root-loop constructor
scope and the linker/Main-ALI aggregate-attachment scope, with no material
finding. This accepts neither complete gimplifier/native lifetime nor whole
literal-pipeline capacity. Production admission and the Oracle are unchanged.

The exact review checkout was integration
`1a8da404ae77a47abbd1b0406135f034416a4e9e`, in the isolated
`review/retained-cf-cfg` worktree. The reviewed changes were CF/CFG attachment
`b1fce355e1b2f085016b4d0cece8495cdf4c8f5c` (worker `0ba83cc59d`) and
linker/ALI attachment `bc4dabb6ad86b988a9943afbc9ece7f665d01043`
(worker `5375898660`). The earlier accepted initial-SSA packet and its
`review-initial-ssa.md` report, integrated at `15f59e8a7d`, supply the dominance
and vector transfers; this is not a fresh review of every earlier packet.
Only this new report was edited.

Reviewer selection: GPT-6 Astra, Extra High, explicitly selected by the parent.
Independent serving-runtime confirmation is unavailable. The measured source
review/replay interval was 18:45:23–18:47:54 UTC (151 seconds), excluding
worktree creation and final report authoring/commit. The replay's separate
wall time was not measured. Token and monetary cost measurements are
unavailable. Review ran on Linux x86_64; no native compiler, assembler,
linker, prover, build, broad audit, new prefix capture, GitHub write or
subreviewer ran.

Exact inputs were the target's `docs/research/retained-literal-pipeline.md`,
especially “Initial CF, EH, CFG and root-loop lifetime” and “Accepted linker
and Main ALI interfaces”; this packet's `compose.py`, `check.py`,
`check-results.json`, `result.json`, `fixture.json`, `inputs.json`,
`source-join-inputs.json` and README; the established literal-lowering and
null-layout transfers in `retained-native-expansion.md` and its evidence;
and the attached accepted linker and ALI callable interfaces. Governing
context was `AGENTS.md`, the unchanged Oracle and the applicable review
bookkeeping requirements. The parent's bounded #119 authorization required
source/configuration-decidable capacity, source correspondence and explicit
lifetime/counter boundaries, with physical resources retained as assumptions.

Source inspection used retained GCC revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` at
`/tmp/silver-backend-compose-20261018/full-source`, Ada sources at
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and plugin
headers at
`/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include`.
The loader verified 75 aggregate inputs and 265 distinct source attachments;
the join manifest contains 197 entries. The selected O0/no-debug/no-checking,
LP64, no-local-EH, whole-unit Main-preservation and relevant installed/source
behavior premises remain conditional. Hash matching and arithmetic replay
do not prove C++ semantics or those premises.

The reviewed argument is sufficient for the following bounded claims:

- With `b=N+2`, `B=N+4`, `E=N+3`, `H=N+1` and `S=3C+N+2`, the callable's
  complete shape record must equal the established literal-lowering result.
  The single final return is reused by CF lowering; one LABEL_DECL and two
  tuples are added, while the eight-record return vector needs no growth.
  The C descriptor declarations reach `record_vars_into` once, giving at most
  C local-vector pushes/backing requests. No null-program lifetime subtotal
  substitutes for these variable requests (`gimple-low.cc:122–214,
  908–982,1178–1223,1438–1468`; `gimplify.cc:404–415`).
- EH lowering has no local region, TRY or call LHS on this route. The
  descriptor stores cannot trap under the established shape. Its eager
  finally table nevertheless records up to H labels, with H 16-byte records,
  at most `1+H` backings and an eight-byte-entry prime envelope
  `prime(max(31,2H))`. The empty EH bitmap contributes a shared header;
  zero regions do not erase the label-table demand (`tree-eh.cc:200–259,
  2064–2141,2245–2275`). The absent regions also bypass the language
  personality callback (`except.cc:3290–3318`).
- Each CFG edge introduces at most one predecessor and one successor backing.
  Block/label maps start at logical length 20; the request ceilings
  `1+max(0,B-20)` and `1+max(0,H-20)` conservatively include every possible
  growth operation. `V(x,a)=next_power_of_two(8+8*max(a,2x))` bounds allocator
  normalization, with separate unsigned growth, normalized 31-bit capacity
  and byte-product checks. Existing capacity is below the required extent
  when growth occurs, which justifies the `2x` request and `3x` arithmetic
  bounds (`vec.h:253–260,394–423`; `vec.cc:150–169`). `ggc_realloc` adds at
  most one allocation event per backing operation. The request list and
  event sum retain these events separately from direct gimplifier sites.
- In `tree-cfg.cc:1085–1187`, each visited statement can make at most one
  insertion-capable discriminator call, and each edge adds at most one;
  there are no PHI operand visits. Thus `K=S+E=3C+2N+5` is sufficient even
  without location deduplication. The unsigned block ID advances after each
  call, after each sole successor, and after each ordinary block, giving
  endpoint `C+2b`, not merely a block-count bound. A line's discriminator
  increments at most once per visited segment. The map's `1+K` backing
  requests and `12*prime(max(13,2K))` bytes cover insertion-before-growth
  behavior. Prime-table and `2p-3<=UINT_MAX` checks cover the probe sum;
  search/collision statistics wrap only with defined unsigned behavior and
  do not select allocation or compilation behavior on this route.
- Both dead-label scans are included. Forwarder removal stops on the linear
  predecessor/successor guard, and merges transfer the existing successor
  vector while removing blocks/edges (`tree-cfgcleanup.cc:476–519,871–896`;
  `cfghooks.cc:842–921`). Initial cleanup's dense visited map and preorder
  stack are explicit. The altered sparse bitmap needs at most
  `ceil(B/128)` live elements. `bitmap_clear_first_set_bit` returns an empty
  element to the default freelist before processing that block, and
  `bitmap_element_allocate` consumes that freelist first. Other selected
  sparse maps remain empty, so the same ceiling bounds fresh elements
  (`bitmap.cc:78–139,1240–1309`; `tree-cfgcleanup.cc:1185–1247`). Shared
  obstack/chunk composition remains open.
- Initial cleanup constructs one forward dominance forest; loop discovery
  reuses it and adds fast-query numbering, rather than rebuilding its
  arrays or ET forest (`dominance.cc:667–758`). The cold transfer retains
  the same B and the `4B<=INT_MAX` guard. The root-loop route has no backedge
  and requests only the loops control, root, exit sentinel and one-pointer
  GGC vector, plus the reverse-order/preorder/candidate ordinary backing.
  `AVOID_CFG_MODIFICATIONS` does not request exit recording or CFG changes
  (`cfgloop.cc:340–450`; `loop-init.cc:43–133`). Fixed inline loop integers
  add no dynamic limbs; these constructor types add no singleton finalizer.
- The separate `9C+2N+2` direct gimplifier event subtotal counts the named
  call/store/goto/label/return/bind, descriptor and expression sites only.
  The original return is charged there and reused by CF. Whole-body deep
  unsharing, materialization copies/folding and shared helpers remain
  explicitly unclosed. Metadata exports retain `3C+2N+2` CF block-location
  requests and at most K discriminator-location requests; they do not
  silently price the underlying shared location-map lifetime.
- Linker and ALI attachments use the identical raw source bytes and check
  complete source/count equality. Reapplying the accepted link callable to
  the already joined assembler result must reproduce the entire link
  result, and its storage verdict must match the separately attached
  GAS/BFD result. Linker paths receive spelling bound `P+1`, including NUL;
  ALI receives P, excluding NUL, and checks physical-source equality.
  The fixed 4096-byte host-page premise is retained. The 5000-call fixture
  fails only `literal_output_linker_representation`, through the conservative
  `fixed_signed_relocation_reach` sufficient inequality. This is neither an
  observed native failure nor an adopted language limit.

The one authorized offline replay used:

```sh
python3 docs/evidence/retained-literal-pipeline-20261018/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --output /tmp/silver-cf-cfg-review-checks.json
```

All 64 cases passed. Output exactly matches retained `check-results.json`,
SHA-256 `9e2ab8546f6e51ed4b5f41726d736c64f19a3148bbecdf9f19927c1a32f6170a`.
Relevant cases cover map growth, EH/discriminator prime envelopes, normalized
vector boundaries, bitmap extents, ALI P=976/977 and the 5000-call sufficient
linker-bound failure. These cases check the implementation of the arithmetic
and joins; the source argument supplies the conditional general claim.

The result correctly keeps complete gimplifier/frontend/gigi lifetime,
shared metadata/bitmap/ET pools, global event/UID counters and collector
composition open. Later passes, complete production materialization,
producer consumers and binder/parser/driver joins also remain open.
`whole_literal_pipeline_capacity_established=false` and
`native_tool_executions=0` are preserved. No unresolved finding remains
within this review's two bounded attachment scopes; #119 remains incomplete.
