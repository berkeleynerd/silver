# Complete selected fixed Why3 prefix composition

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
The five exact fixed-library processes now have a **complete conditional
capacity argument for the selected Why3 prefix**. This joins the
[fixed context](retained-producer-fixed-context.md),
[controlled collection and dimensions](retained-producer-prefix-gc.md), and
[semantic occurrence counts](retained-producer-prefix-counts.md), and closes
the remaining prefix arithmetic/reachability questions below. It establishes
neither whole-pipeline capacity nor a new admission rule.

The interval begins at `camlWhy3__Exn_printer__entry`, the first Why3 module,
and ends on entry to `Gnat_checks.init`, **before its body executes**. It
includes module initialization, configuration/plugin/driver loading, whole-file
import typing, native JSON conversion and typing, VC construction,
`Controller_itp.add_file`, `Task.split_theory`, and initial session records,
checksums and shapes. Server connection, goal registration, scheduling,
transformations selected for provers, prover runs and final output follow it.

The [offline packet](../evidence/retained-producer-prefix-composition-20261018/README.md)
joins exact inputs and source identities, replays the four component checker
entry points, and evaluates the combined inequalities. It retains all 293
implementation/parser files from the earlier source scan, plus the two
interfaces used here and the license. The broad numeric/caller scan is a review
aid; neither that scan nor the checker proves OCaml source semantics. No native
execution was needed for this composition.

## One context and one conditional predicate

Let `C` be one of the five launch descriptors retained in the semantic-count
plan. Require all of the following, together, for `FixedWhyPrefix(C)`:

1. **Exact inputs.** Use the recorded executable, two plugins, configuration,
   driver/library bytes, native filename and complete JSON bytes for Put_Line,
   Put, First_Or_Default, Input_Is_Valid or Is_Message. The eleven-file native
   import closure is 318,006 bytes; it is a subset of the 165 configured text
   files in the allocation packet. The checker joins every one of the eleven
   files to that packet and every native input to the original fixed-context
   digest. The five cases are separate fresh processes, not additive heaps.
2. **Controlled launch.** Use `OCAMLRUNPARAM=s=256M,h=16M,M=1000`, the retained
   ordinary progressive-proof arguments, fixed relative filenames, private
   temporary directory and fresh-session branch. Use the recorded pathname
   layout or the allocation-equivalent relocation described in the GC record:
   component lengths and equality relationships must be preserved. The retained
   `gc4` to `gc5` relocation meets those conditions. Keep the selected locale,
   environment and source-search results; do not add debug/inference flags,
   plugins, signal-driven GC or profiling. A populated session is outside `C`.
3. **Relevant external behavior.** The identified installed binary follows the
   reviewed Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
   4.14.2 runtime behavior at `8eb41f72ded84df884c3671734c947f612091f84` for
   the reached dispatch, allocation, table, traversal and arithmetic operations.
   This is the existing [trusted relevant-behavior premise](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary),
   supported in part by the retained installed instructions and guards. It
   does not claim recovery of the historical SPARK source archive.
4. **Existing external operation contracts.** Allocation, input reads, dynamic
   loading, OS calls and the selected runtime/library primitives honor their
   ordinary contracts: successful conversions are exact, container/string
   operations preserve their stated structure, arbitrary-precision operations
   return exact values, and checked unrepresentable requests do not silently
   succeed. The GC component's C/library-backing and allocator/OS premises
   remain in force. The managed-word bound is not a bound on all foreign bytes
   or resident memory. Physical resource failure and external interruption
   remain operational failures, not language nonmembership.
5. **Composed numeric conditions.** Evaluate the inequalities below with the
   retained exact fixed-prefix constants. Their source joins include the
   complete reachable-operation partition in the next sections.

This predicate uses finite recorded identities, configuration and constants;
it does not run Why3 to decide a variable program's membership. Fixed successful
captures support the source argument once. They are not an acceptance oracle
for arbitrary source. Historical ordinary acceptance is compatible evidence;
the newer guarded captures themselves reached successful `add_file` under the
identified executable and controlled configuration used in this conjunction.

Write `W = 86,632,681` for the largest protected lifetime allocation, and
`B = W + 43,164 + 2,152,771 = 88,828,616` for the managed/static word overcount.
The latter terms retain the GC component's startup and loaded-image allowances.

| Domain | Sufficient upper bound | Capacity comparison |
| --- | ---: | --- |
| Positive tags, ordinal traversals and allocation-charged counters | `W+1 = 86,632,682` | below `2^62-1` |
| Synthetic location lines, column zero | `W+1` | below `2^47-1` |
| Physically represented word/cardinality dimensions | `B` | below `2^27` |
| Declaration dependency ranks, array midpoints and word-length growth | `2B+2 = 177,657,234` | below `2^62-1` |
| Unary projection height including proxy preference | `B+65,536 = 88,894,152` | below `2^62-1` |
| Byte offsets, paired lengths, growth and escaping arithmetic | magnitude at most `16B+2 = 1,421,257,858` | below `2^62-1` |
| Real imported-file line / byte column | `3,022 / 5,148` | below `2^47-1 / 2^16-1` |
| Semantic free-variable addition/product/occurrence totals | `47` | below `2^62-1` |

These are sufficient local bounds, not an aggregate capacity restriction on
Silver source. In particular, `B` cannot bound unfolded term occurrences; the
last row uses all 146,259 guarded operations in the separate count evidence.

## Reachability closes the term-size question

`Term.term_size` counts unfolded occurrences with `acc+1` and then asserts
strict increase (`term.ml:1839–1846`). The complete retained implementation
scan finds its callers only in `src/transform/reduction_engine.ml` and
`plugins/strategies/forward_propagation.ml`, besides its own branch wrapper.
The latter plugin is not one of the two loaded plugins. The reduction engine's
size helpers, continuation totals and growth multiplier execute under
normalization; its public entry computes `term_size` at `:1534–1538`.
Its separate first-order-matching interface has no route into those size
helpers. `compute.ml:69–82,123–141,175–185` installs normalization callbacks
as transformations; registering their closures does not call them.

The selected dispatch is concrete:

- `Driver.load_driver_raw` stores `Transform s` in a list
  (`driver.ml:125–153`) and reads theory/meta declarations (`:174–253`). It
  does not apply that list. `Driver.prepare_task` applies it at `:372–390`;
  that function belongs to later prover preparation.
- `Gnat_checks.init_cont` creates a fresh session/controller and calls
  `Controller_itp.add_file` before the endpoint (`gnat_checks.ml:380–412`).
  `Session_itp.make_theory_section` calls `Task.split_theory` and
  `Termcode.goal_expl_task`, then creates proof records
  (`session_itp.ml:1750–1779`). `Task.split_theory` traverses declarations and
  constructs tasks (`task.ml:201–222`); it is not a registered transformation.
- Proof-record construction computes the SV6 checksum and shape
  (`session_itp.ml:679–694`). Its ordinary `Trans.fold` is a memoized task fold,
  not reduction-engine normalization (`termcode.ml:900–931`). This fold remains
  covered by the no-collection/cache argument.
- The outer main applies goal registration and scheduling only after
  `init_cont` returns (`gnat_main.ml:332–360`). Entry to `Gnat_checks.init`
  precedes that return, including its server connection.

Therefore no `term_size` arithmetic or reduction growth arithmetic occurs in
this prefix. **Installed assertion enablement is not a required premise**:
the argument excludes the call, rather than claiming an assertion makes an
overflow safe. This says nothing about those operations in later prover
transformations, where assertion failure would still be a failure.

## Reachable arithmetic partition

The source review separates term construction/typing/VC work, initial session
population, and module registration from callbacks invoked only later. Its
coverage is the reached Why3 code and the external primitive contracts stated
above. The additional full-source scan includes numeric operators, conversions,
increments/decrements, successor/predecessor calls and shifts; comments and
type syntax are deliberately retained as false positives. Semantic reachability
and the following charging invariants are inspected source claims.

**Identity and allocation counters.** The GC record already joins every reached
Hashcons/Hcpt instance, identifier/attribute/environment/driver/type/program
declaration/expression tag, synthetic location, metadata tag, invariant pin,
VC exception ID, session ID, shape ID and checksum alpha ID to fresh allocation.
Its binder-index proof charges traversal-state map bindings, not input-DAG
size. Pretty-printer suffix search charges lifetime occupied spellings, not
just the number currently live. The nonallocating Introduction hashcons
instance is excluded until later introduction transformations. SCC stack
indices and argument/postcondition ordinals retain their existing joins.

**Physical containers and indices.** Ordered maps/sets have disjoint child key
domains; acyclic lists have a physically represented spine. Their cardinality,
height, iteration indices and sums are bounded by the charged storage even
when values share term nodes. Arrays, buffers, strings, stacks, queues,
persistent maps and hash tables retain their ordinary backing contracts.
The source arithmetic in `extmap.ml:105–143,277–278,391–393`,
`hcpt.ml:285–289`, `vector.ml:48–120`, `pqueue.ml:48–55,87,104`,
`lists.ml:92–145`, `strings.ml`, `getopt.ml`, `lexlib.mll` and `rc.mll`
uses backing lengths, positions, fixed small factors or bounded differences.
There is no claim that an arbitrary integer stored as a map value is bounded
by the map's cardinality. Word sums/doubling fit `2B+2`; byte sums/doubling and
the signed differences used by string/path/escape routines fit `16B+2`.
The JSON converter's balanced connection midpoint is
`(from+to_+1)/2`, with both endpoints bounded by the existing array
(`gnat_ast_to_ptree.ml:503–515`), hence the word bound applies before division.

**Additional typing/VC ranks and depths.** These are distinct from unfolded
occurrence totals and were not named in the earlier dimensions summary:

| Operation | Source argument |
| --- | --- |
| Type-declaration dependency rank, `pdecl.ml:476–490` | `count` memoizes zero before following dependencies. Each fresh declaration contributes at most two above the maximum dependency rank, not the sum. A dependency chain visits at most the number of entries in `hpd`; even a revisit uses its saved value. Thus every rank and intermediate `n-(n mod 2)+1/2` is at most `2B`. |
| Quantifier projection depth, `eval_match.ml:89–128` | Each recursive destructuring level constructs fresh variables/identifiers and terms before passing `succ d` to its children. Even a nullary level constructs the application; with no children it does not recurse. The depth is at most charged lifetime allocation, and the one extra successor fits `W+1`. Sharing the original type/term does not defeat this charge. |
| Region-name projection height, `vc.ml:1201–1206` | This recursion follows a single unary `Tapp` chain. The immutable term graph is acyclic; a path contains at most `B` physical nodes. Its base is zero or the constant proxy preference 65,536, giving `B+65,536`. It does not add the sizes of sibling DAG expansions. |
| Error-context application depth, `dexpr.ml:813–821` | `down` follows one `DEapp` spine and uses `succ n`; the spine is acyclic and physically bounded. It is also an error-rendering route, not a successful-prefix semantic multiplicity. |
| Tuple constructor loop, `ty.ml:280–285` | Every iteration constructs a fresh variable and list cell. The retained completed calls therefore have at most `W` iterations. Source-created tuple arities originate in list lengths or checked tuple-name conversion; no unfolded occurrence total supplies this loop bound. |

**Source positions and scalar conversions.** Real text input dimensions and
absence of `[#` location overrides are checked over all 165 configured files.
UTF-8 adjustment reduces byte columns. Native JSON uses synthetic locations;
all its machine-integer scalar fields are checked separately, with maxima at
most 13,772. Mathematical integer literals use `BigInt`, not those scalar
fields. Configuration, driver integers, tuple names and metadata use checked
`int_of_string`/`BigInt.to_int` conversions. Reaching successful `add_file`
under identical fixed requests transfers those checked requests; it does not
license ignoring unchecked arithmetic after a conversion. The latter belongs
to the bounded families here.

**Syntax and number formatting.** `Printer.check_syntax_literal` increments
once per nonoverlapping syntax group (`printer.ml:276–284`); the scanning
indices and other group counts (`:145–191,230–314`) are bounded by their
physical string. Pretty-printing precedence comes from a fixed finite
constructor precedence table (`pretty.ml:25–28,478–480`), not recursive depth.
Numeric value/exponent normalization and floating-point representability
arithmetic in `number.ml` use `BigInt`; the plain integers at parsing are
character codes, string indices/lengths, radix constants and checked
conversions (`:78–164`). Arbitrary-precision arithmetic is an exact external
primitive contract; it is not treated as unchecked OCaml integer arithmetic.

Fresh SV6 checksum/shape formatting uses `Common.const_v2`, encoding a real
as its significand and two exponent strings (`termcode.ml:221–230`); it does
not expand exponent-sized zero padding. `Common.const_v1`'s radix formatting
and the general real printer's padding arithmetic
(`number.ml:175–194,330–334,357–363`) are not selected by SV6. Other callers
belong to backend/term printing, optional debug output or exception diagnostics.
The selected successful prefix has no backend print task and its extra term
debug flags are off. Reached typing warnings print fixed text and symbol names
(`dterm.ml:586–594`, `dexpr.ml:1232,1282,1299,1400–1403,1634–1638`,
`pmodule.ml:1143–1152`, `theory.ml:537–540,892–894`), not numerical term
values. An exception renderer runs after a first failure; it cannot create
the first failure being excluded here. Thus this prefix makes no unsupported
inference from managed words to an arbitrary exponent or digit countdown.

**Semantic count arithmetic.** The count-origin/preservation argument and all
three guarded sites from the count component apply unchanged. Every seed is
zero/one; subsequent additions and products remain nonnegative and at most
47. This covers cached substitution multiplicities and `t_v_occurs`, including
their value-sensitive consumers during typing/VC construction. These values
are not physical-container counts.

**Intentional bit arithmetic.** Hash mixing in `hashcons.ml:57`,
`hcpt.ml:142–143` and `whyconf.ml:98–100` is intentionally modular and affects
hash buckets, with equality tested separately. `task_hash` adds one to a
bounded identity. Patricia bit reversal/masks in `hcpt.ml:162–211` operate on
fixed machine bit strings; they do not allocate by a wrapped cardinality.
Location packing has the independently bounded line/column operands above.
None of these operations is used to excuse semantic occurrence-count wrap.

**Unselected operations and registrations.** Transformation and prover-printer
module initialization registers closures/metas and creates fixed objects;
those allocations and tags are in `W`. Applying their term-rewriting, size,
output, solver/model-parser and step-limit arithmetic follows the endpoint.
Saved-session XML/shape parsing, merge/pairing, compression and serialization
are not selected by fresh-session creation. In particular the decimal decoder
near `termcode.ml:139` is commented-out code, not a live count source.
`Util.split_version`'s unchecked decimal accumulator has only the
autodetection caller `autodetection.ml:771`; the retained configuration loads
named provers and does not invoke autodetection. Both invariant-inference
hooks are also excluded: their selection requires `infer`/`bddinfer`
attributes or the extra inference debug flag (`infer_loop.ml:103–118`,
`bddinfer/why3infer.ml:1592–1621`). The checker finds no byte substring
`infer` in any configured text file, fixed JSON or local configuration.

`Debug.stats` **is enabled** by `gnat_main.ml:319`; it must not be excluded
by assuming debugging is universally off. Its outer `gnatwhy3.init` timer
adds its completed-call count only in the finalizer after `init_cont` returns
(`debug.ml:162–173`). That has not happened at the endpoint. Other timing
callers are later transformation/RAC/report routes; there are no selected
`Stats.incr/decr` callers. Even a completed timing update allocates a fresh
pair, but this prefix needs no such charge. Clock values themselves are not
converted into prefix allocation sizes or semantic counters.

## Composition and boundary

Use a simultaneous first-event argument. Before the first hypothetical
collection/request, identity wrap, semantic-count wrap or bad representation
request, the source projection has the same fixed control flow and requests
as the retained successful execution, modulo consistent addresses and the
specified pathname relocation. The no-randomization/weak-cache argument in
the GC record applies up to that event. A collection/request is excluded by
its trigger margins and complete entry guards. An unchecked counter operation
is either bounded by the already charged allocation/structural prefixes,
checked at the semantic operand sites, intentionally modular with its stated
consumer, or outside the interval. A checked representation request has the
same arguments as the retained successful request. This rules
out the first event without assuming counters remain correct in order to
claim an unbounded future allocation trace.

Consequently every representation operation in the selected prefix has its
capacity argument under `FixedWhyPrefix(C)` and the stated external contracts.
The earlier packets' historical `complete_prefix_capacity_established=false`
flags remain accurate for those individual component results. This new
conjunction sets it true, with its inspected-source basis explicit. No named
Why3-prefix gap remains in this conjunction; its independent review still
must assess the source partition and transfer, not just the numeric checker.

The literal-output Main family has no Main backend task, but still needs all
five fixed-library processes. Null Main's separate no-backend result does not
remove them for literal output. This conjunction supplies their **prefix**
only. It does not establish later goal registration/splitting, driver
transforms, solver representations/results, report/session serialization,
server/orchestrator capacity, producer/native phases, variable Main, complete
automatic discharge, or the final useful-domain rule required by #119. The
production launcher has not adopted the controlled runtime or fresh-session
configuration merely because this research predicate holds.

Selected worker setting: GPT-6 Astra, Extra High; runtime setting confirmation
is unavailable. This round reused successful native evidence and added source
inspection, exact-input joins and offline arithmetic checks. No toolchain,
Oracle, source-admission rule, proof pin or production file changed. Token/cost
measurements and a full-turn start timestamp were unavailable; the packet
records the measured packaging/validation interval separately.
