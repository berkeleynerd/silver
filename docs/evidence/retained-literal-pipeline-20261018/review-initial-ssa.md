# Independent initial SSA lifetime review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted within the stated conditional initial-SSA constructor/renamer scope,
with no material finding. Whole native and literal-pipeline capacity remain
open; this acceptance supplies no production admission rule.

The exact frozen target is
`9f8a7b4ce8fe6629424e04734364af2156e5cf6b`, with parent
`bdd040792f`. Review used a separate detached worktree at that target and
changed only this new report. The accepted graph/helper review was read from
integration `3ab343eee0`, at
`docs/evidence/retained-literal-pipeline-20261018/review-native-graph.md`;
its reviewed graph/helper repairs are already present in the frozen target.

Reviewer selection: GPT-6 Astra, Extra High, explicitly selected by the parent.
Independent serving-runtime confirmation is unavailable. The measured source
review/replay interval was 18:22:42–18:26:18 UTC (216 seconds), excluding final
report authoring and commit. Token and monetary cost measurements are
unavailable. This was offline source review and Python arithmetic on Linux
x86_64. No compiler, assembler, linker, prover, build, broad suite, native
executable, new prefix capture, GitHub write or recursive review ran.

Review inputs were the target's literal-pipeline argument, `compose.py`,
`check.py`, `check-results.json`, `result.json`, `fixture.json`, `inputs.json`
and `source-join-inputs.json`; the retained literal lowering and general
initial-SSA/CFG arguments; their fixed-layout evidence; and the accepted graph
review above. Governing context included `AGENTS.md`, the unchanged Oracle,
the current #119/#88–#94 authorization and scope, and the applicable review
bookkeeping requirements. The Oracle's universal assurance and source
correspondence requirements remain unchanged.

Source inspection used GCC revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` at
`/tmp/silver-backend-compose-20261018/full-source`, the retained Ada root at
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and plugin
headers at
`/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include`.
The effective O0/no-debug/no-checking route, LP64 layout, reviewed-source
behavior and whole-unit Main-preservation premises are retained assumptions.
Source attachment checks are not proofs of those premises or of the source
argument. In addition to the checked manifest files, review inspected
`gcc/ggc-common.cc` (40,096 bytes, SHA-256
`a5a41143b78a22376c6d830215ee856616db68bbf4432987479f4e4b8ded4627`)
and `gcc/memory-block.cc` (2,268 bytes, SHA-256
`16f4beb0f9a9354ba461e8cf519bc2055db9754193e00e43ff17ee71624963dd`)
for realloc-event and ordinary block-allocation behavior.

The source review established the following within that scope:

- The selected lowering supplies `u=3C+1` memory uses/fresh-name requests,
  `z=3C+2` name-vector slots and `B=N+4` block-index slots. Aggregate descriptor
  fields and call clobbers contribute at most `3C` virtual definitions;
  the bare return adds one use. All renamed operands use the single `.MEM`
  declaration. Address operands do not create real SSA uses. The straight-line
  CFG has no ordinary join and therefore no dominance-frontier PHI site.
  This review consumes the established lowering interface rather than
  claiming a complete frontend/gimplifier/CFG lifetime derivation.
- `init_tree_ssa`, `init_ssanames`, `create_vop_var`, `make_ssa_name_fn` and
  default-definition creation give three infrastructure requests, at most z
  name-vector backings, three `.MEM` declaration/identifier requests, u name
  objects and one detached NOP. `.MEM` declaration layout uses the existing
  void type's fields and adds no second declaration/type constructor. The
  default-def hash has one key and 31 slots. Its terminal `empty_slow` cannot
  replace backing: shrinking requires more than 32 slots. Its control has
  a nontrivial destructor and contributes one singleton finalizer; raw name,
  vector, string and slab allocations do not add another. The resulting GGC
  request delta is `6C+10+L`, separate from pool and graph deltas.
- The slab allocator's strict `index+40 >= payload` check gives 25, 102 and
  409 use entries in its 1,024-, 4,096- and 16,384-byte requests. Thus
  `L=1+[u>25]+ceil(max(0,u-127)/409)` is sufficient. Old statement-use entries
  enter the free list before replacements are allocated; the initial renamer
  then changes pointers in place. This supports the initial-scan lifetime
  ceiling, without asserting that later rescans add no demand.
- The GC-vector ceiling includes allocator normalization, not merely its
  logical length. An existing vector grows only when its capacity is below
  the desired length, so `max(50,2z)` bounds its pre-rounding request.
  The `3z` check protects ordinary growth arithmetic; the rounded byte bound
  protects the normalized 31-bit capacity and LP64 byte product.
  `ggc_realloc` requests at most one new GGC object per backing operation.
- The var-info constructor prices the local-declaration extent C separately
  from the single useful `.MEM` record. It requests the next prime at least
  `max(7,C)` and cannot grow on one key. Initial `REWRITE_ALL` does not enter
  the SSA-update name-mapping paths. Default definitions, reaching uses and
  restored definitions continue to query declaration info, so the update
  annotation vector is not implicitly populated by the fresh memory names.
  Its one record and one-element pointer vector fit the stated sizes.
- Each visited block pushes one definition-stack marker and each ordinary
  virtual definition pushes at most two saved pointers. Default-name lookup
  adds no separate stack push. Therefore `B+6C`, the capacity bound
  `max(10,2(B+6C))`, and its unsigned-growth/31-bit checks suffice.
  Three private bitmaps contain definitions, live-ins and the empty PHI set.
  Their two populated maps need at most `2*ceil(B/128)` elements. The private
  obstack request bound allows an initial chunk and a possible replacement
  per completed object. The shared kills map is sparse and uses one live
  element indexed by `.MEM`'s DECL_UID; it is not a dense UID-sized array.
  Pruning may allocate/copy its temporary bitmap but returns on empty PHIs
  before the larger pruning arrays. The eager IDF work-vector request is
  retained even though the frontier is empty.
- The two dominator walks each allocate two int arrays and a `2B` pointer
  work stack. Their preorder helpers also construct the edge-iterator vector;
  `8+16*max(20,B+1)` covers its inline or exact heap capacity. Cold forward
  dominance uses nine unsigned arrays, one pointer array, its order array
  and DFS edge stack. At most B ET nodes and 2B occurrences suffice; the
  checking-safe 910/1,170-object pool divisors conservatively cover the
  selected no-checking layouts. Existing forest/pool reuse can only reduce
  these new requests. `4B<=INT_MAX` covers the relevant signed traversal
  intermediates, while bitmap/vector arithmetic is checked separately.
- The per-phase fresh-name bound does not reset or close the global
  `ssa_name_nodes_created` counter. The explicit u-increment delta and false
  global-lifetime field are correct. The additional DECL_UID and identifier
  miss also remain translation-unit inputs. Shared bitmap/pool coexistence,
  all-phase counter totals and GGC collector/finalizer backing remain open.

These conclusions were checked against `tree-ssa.cc`, `tree-ssanames.cc`,
`tree-ssa-operands.cc`, `tree-dfa.cc`, `tree-into-ssa.cc`, `vec.h`/`vec.cc`,
`ggc-page.cc`/`ggc-common.cc`/`ggc.h`, `hash-table.h`, `bitmap.cc`/`sbitmap.cc`,
`domwalk.cc`, `cfganal.cc`, `dominance.cc`, `et-forest.cc`/`et-forest.h`,
the pool/obstack sources, and the tree/string/declaration constructors.
No sample success was substituted for these lifetime/source arguments.

The independent replay ran the packet's `check.py` with `--gcc-root`,
`--ada-root` and `--plugin-include` set to the roots above, and
`--output /tmp/silver-initial-ssa-review-check-20261018.json`. All 46 cases
passed; the output exactly matches the retained `check-results.json`, with
SHA-256 `88e73c40104d85c7374b35cc365086ccd5a1fc63e7c29f7d3595415c8081a580`.
The loader checked 63 aggregate inputs and 262 distinct source attachments;
the join manifest contains 191 entries. Cases cover the two operand-slab
transitions, normalized-vector capacity and dominance extents, shared-source
joins, and the unchanged false whole-pipeline verdict. Replay checks
attachment and arithmetic; the source review supplies the argument above.

The aggregate joins the name-slot and operand-slab interfaces to the existing
literal lowering result. The new events are not silently substituted for a
complete lifetime allowance, and no null-program 40,098-event allowance is
reused. Frontend/gigi/initial-GIMPLE and CF/CFG construction, pass-manager TODO
work, later SSA updates, remaining shared pools and collector composition
remain outside this component. The remaining native, producer, binder/linker
and complete output-launch joins still prevent whole-pipeline closure.
`native_tool_executions=0`, production admission remains unchanged, and #119
remains incomplete.
