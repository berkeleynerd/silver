# First-inline unsuccessful declaration comparison

Research [#119](https://github.com/berkeleynerd/silver/issues/119) /
[#153](https://github.com/berkeleynerd/silver/issues/153), Linux x86_64,
2026-10-20. Author base `f1268fbb66b8285713ac315fa1b9d7ca6f73ba81`.

An unsuccessful `Hsdecl.equal old candidate` comparison contributes **zero
Ident registrations, zero hashcons/unique requests and zero hash-tag counter
increments or tag writes**. This includes strict formula comparison, virtual
substitution, private maps, attributes, locations and constants. The same
effect statement holds for a successful comparison or an exceptional prefix.
It is the effect attributable to the comparator: asynchronously executed save
work keeps its existing separate process-global charge.

For an original-context candidate in the accepted
[returned-storage interface](retained-why-returned-storage.md), its right-hand
formula supplies **M ≤ 99, P ≤ 8 and actual variable-only saved images**.
That one side bounds both operands' private binder numbering and bound maps.
Their correctness-relevant arithmetic is representable. Old saved-map lookup
and old attribute enumeration need finite valid structures, but introduce no
growing length counter or allocation request calculated from their sizes.
Thus an unknown number of unsuccessful comparands does not add an unknown
term to the Ident/hash-tag ledgers or defeat this local request-arithmetic
interface. Table growth and caller counters remain separate obligations.

The [packet](../evidence/retained-why-collision-comparison-20261020/README.md)
retains exact source excerpts, a new static byte witness for the installed
big-integer comparator, and focused arithmetic checks. These support a reviewed
source/interface argument; they are not a machine-checked OCaml semantics proof.
No target, solver, capture, compiler or predecessor checker ran. Ordinary
allocator/OS behavior and sufficient physical stack/memory remain trusted.
No aggregate time, RAM, instruction-count or allocator-internals requirement is
introduced.

## Orientation and caller boundary

At selected OCaml revision `8eb41f72ded84df884c3671734c947f612091f84`,
`Weak.find_or` hashes the candidate, obtains a shallow old object with
`get_copy`, then calls **`H.equal v d`** (`weak.ml:272–294`). The candidate is
the **right** operand. `merge` inserts only after that search returns without
an old representative. There is no premise that the left operand has the
candidate's storage bound, or that OCaml evaluates the two `descend` operands
left-to-right.

`Weak.get_copy` is outside the equality callback. For a valid `decl`, it makes
only a shallow copy of the three-field declaration record
(`decl.ml:324–328`: node, news, tag); its nested term/map/metadata pointers are
shared. The runtime copy and its option result have fixed request widths.
That boundary does not give any recursive storage bound on the old payload,
or charge a table scan/growth operation to the comparator. Its runtime behavior
is the already accepted weak-copy interface, not a new target observation.

`Hashcons.hashcons` tags a newly allocated candidate before `merge`, and may
increment its private `next_tag` after `merge` returns (`hashcons.ml:33–56`).
Neither action belongs to the equality callback. `Hsdecl.unique` handles a
goal without querying the weak table (`decl.ml:411–420`). Goals keep the R56
candidate/goal construction and hash bounds; this result never gives them the
context's P = 8 or variable-only-image invariant.

`Hsdecl.equal` first matches declaration constructors. Dlogic checks physical
lsymbol identity before each strict formula comparison; Dprop checks kind and
physical prsymbol; Dind checks its kind, outer physical lsymbol and each
physical axiom prsymbol (`decl.ml:340–367`). These are prefix guards. A longer
old Dlogic/Dind list can enter a matching prefix formula before a later length
mismatch: no full-key equality premise is used. Each strict formula call
starts its own local `bnd = 0`. Dtype, Ddata and Dparam comparisons use physical
symbol tests and paired list/option traversal, with the same zero tag effect.

## Zero-effect call graph

Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c` supplies the following
complete synchronous comparator interface:

| Reached routine | Relevant behavior |
| --- | --- |
| `t_equal_strict`, `t_compare`, `pat_compare`, local `add` | All strict flags are true. Recurses over matched constructors/lists, creates local binder indices and private bound maps, raises private comparison exceptions. No opening, cloning, fresh symbol or hashcons operation. |
| `descend`, `Mvs.find_opt` / `find` | Reads bound and saved maps. On a saved hit it removes that frame before descending into the image. It does not apply a substitution by constructing a term. |
| `Mvs.add` / `singleton`, `Extmap.bal` / `create` / `height` | Constructs immutable private map nodes and computes their heights. Its ordering is integer comparison of existing identifier tags. No old saved map is updated. |
| `Sattr.compare` → `Extset` → `Extmap.set_compare` / `compare` / `cons_enum` | Enumerates immutable attribute trees with private `More` nodes and compares existing `attr_tag` integers. Attribute strings and `Hsattr` are not reached. |
| `oty_compare`, `ty_compare`, `vs_compare`, `ls_compare`, `id_compare` | Reads optional type tags and identifier tags. No type/signature expansion and no tag creation. `Weakhtbl.tag_hash` checks and returns its argument. |
| `Option.compare Loc.compare` | Compares an existing position's three immediate integer fields. Does not resolve filename tags, construct locations or invoke `FileTags.get_file_tag`. |
| `Constant.compare_const ~structural:true` | Compares literal kinds, then existing integers or structural real components; string/constructor fallback is ordinary structural comparison. |
| `Number.compare_real ~structural:true` | At most three `BigInt.compare` calls. The other branch's powers, products and normalization are unreachable. |
| `BigInt.compare` → `Big_int_Z.compare_big_int` → `Z.compare` | Selected `ml_z_compare` reads canonical existing numeric representations, returns −1/0/1, and neither allocates nor calls a callback. |
| `Lists.equal` / `compare`, `List.iter2` / `fold_left2` / `for_all2`, `Option.equal` / `compare` | Paired recursion with the stated callbacks. Length mismatch stops or raises; there is no list-length arithmetic. |

The source excerpts cover every row and the data/tag adapters. `Ident.id_register`
and `Hashcons` increments are retained alongside the comparison paths to make
the excluded mutation sites explicit. A textual absence check alone is not
the proof: the argument follows the specified higher-order callbacks and
primitive operand shapes.

The native numeric witness is **266 bytes at `0x9afba0`** in the selected
24,561,432-byte `gnatwhy3`, SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
It contains register operations, operand reads, internal branches and returns;
no calls, memory writes, allocation or dispatch. It corroborates the retained
Zarith 1.14 comparison body at `667d742948914aa1f80d5ad5abb98bc412335e51`,
including disabled performance-counter increments. The earlier Zarith version
string alone is not used as source correspondence. This is a new bounded
static read, not a new target execution or universal native-code proof.

## One-sided traversal and private arithmetic

Consider one strict formula comparison against the original-context candidate.
Its variable-only saved images mean that virtual substitution replaces a leaf
only with another variable. It cannot introduce an extra candidate constructor,
binder or pattern. Each recursive paired term call consumes a candidate
occurrence; constructor mismatch or a metadata test can only stop earlier.
The whole comparison therefore has at most M paired term entries, even if a
left-side saved image contains a large nonleaf term. It cannot traverse that
term independently of a matched right-side constructor.

Every `bnd + 1` follows a matched binder slot. Quantifier lists add only a
matched pair before checking the next pair; a longer left list cannot create
extra indices after the right list ends. Case patterns follow the same paired
rule; the context candidates have only their fixed nullary patterns and zero
pattern-bound slots. Sibling bodies reuse the incoming index, so this is a
bound on all intermediate indices, not an accumulated global numbering.

Consequently `0 ≤ bnd ≤ P = 8`, at most `2P = 16` private insertions occur
across both sides, and every private bound map has at most P entries. They
start empty or singleton; their standard immutable AVL construction preserves
valid heights. All height expressions `h + 1` and `h + 2` are at most P + 2
= **10**. A conservative `8P(P+1) = 576` bound covers the source node
constructions of these private maps. This small local count is explanatory;
it is not an aggregate allocation budget.

Each virtual frame is pushed by a matched candidate binder/case occurrence.
At most M frames are active on **either** side. `descend` consumes a frame
before following a saved image and never restores that frame during the same
descent. It therefore makes at most M probes per side per paired term entry:
at most **2M² = 19,602** frame probes and **4M² = 39,204** map-lookup calls.
This remains true for a left image that is a variable, a nonleaf term, or a
pointer encountered previously under fewer remaining frames. An old saved
map can require a deeper lookup path than the candidate map: no bound on its
tree depth, entry count or hidden values is inferred from these probe counts.

The old input's cached `bv_vars` integers are not comparator binder indices.
`descend` uses freshly constructed private bound maps together with the old
`bv_subst`; it never reads `bv_vars`. Candidate K/R bounds can still be used
for candidate storage elsewhere. They do not need to be copied onto the old
operand to establish this local arithmetic result.

## Finite old traversals and allocation requests

Attribute comparison occurs **before** virtual descent, and may build an
arbitrarily deeper old leftmost enumeration spine before discovering a
mismatch. `Extmap.find_opt` likewise may search a much larger old saved map.
Both traversals terminate on valid finite trees. They use tree pointers and
tag comparisons, not cardinality counters, old stored-height arithmetic or
allocation lengths derived from old cardinality. Saved images not selected by
a lookup are not traversed. Existing immutable map ordering and valid tags
remain caller representation conditions, rather than candidate-derived facts.

Source allocations are fixed-shape: five-field map `Node`, four-field
enumeration `More`, two-field frame pair and cons, three-field binder state,
two-field `Trm`, and one-field `Bnd`/`Some`. They do not combine old lengths
into an allocation request. Compiler-created closures likewise have fixed
layouts under the existing source/compiler correspondence premise. Request
sizes fit the selected representation; increasing the number of such requests
does not change any one request's arithmetic. Sufficient physical storage and
stack for those finite traversals are already trusted.

The primitive shapes close a possible hidden variable request:

- Integer tag/kind/index comparisons use immediate integers. Their difference
  fits the runtime's signed native word; the returned OCaml ordering is
  normalized. Comparing a frame list with `[]` only distinguishes empty from
  nonempty and does not traverse frame payloads.
- Generic location comparison has one three-integer block. Constant fallback
  either rejects differing constructor tags or compares a one-field string
  constructor. Real literal kinds contain at most one immediate field.
  These use at most **one** pending structural-comparison stack entry, below
  OCaml's eight-entry initial buffer (`runtime/compare.c:28–316`). No dynamic
  comparison-stack request or arbitrary custom comparison callback is reached.
  Strings supply existing valid lengths to `memcmp`; no new string is built.
- `ml_z_compare` handles immediate numbers directly. For canonical big-number
  blocks it compares signs and sizes before reading a descending limb prefix.
  The nonnegative size is representable and agrees with the existing block;
  its signed loop index runs from `size−1` through −1, with no underflow beyond
  −1 and no write or numeric-result allocation. This is not a bound on old
  integer bit length and requires no such bound for request arithmetic.

## Exact composition conditions

The closed interface assumes correct source/native correspondence, valid
finite operands, ordered immutable maps/attribute sets, valid canonical numeric
blocks and tag identity, and correct callers. It applies the accepted M/P/leaf
candidate facts only to original context keys at first inline. It does not
claim that every later intermediate representative has M = 99. These are the
existing representation/source conditions; this packet does not capture or
revalidate every old weak-table object across all later process states.

The conditional arithmetic interface is complete for the comparison itself.
There is no remaining old-comparand aggregate-step/metadata-size requirement
for these zero-effect and fixed-request claims. Any asynchronous save is
separate work: the existing **two save-entering callbacks / three saves /
e ≤ 2 per process** are not renewed per comparison or stage.

The surrounding `Weak.merge` still needs a valid table and representable
bucket/index/growth arithmetic, and its `Hashcons` caller still needs a safe
`next_tag` endpoint. Candidate hashing, source construction, later-stage
candidates, wrapper tables and complete pipeline capacity are outside this
result. It neither proves table population bounded nor spends that population
as Ident/tag increments inside equality. #119/#153 remain incomplete.

## Evidence and round

The focused checker checks retained input identities and new source excerpts,
the complete numeric function's instruction bytes, the candidate-right call,
structural real branch, fixed private arithmetic and rejection of an
unrepresentable binder bound. It does not execute predecessor checkers or
simulate the full OCaml transformation. A failed ambient `objdump` lookup was
resolved with the already installed toolchain's objdump; no installation or
configuration changed.

Selected author: **GPT-6 Astra / Extra High**. Runtime setting confirmation and
token/cost telemetry are unavailable. The packet's `round.json` and
`check-result.json` retain actual timing and verification outcome. Parent owns
independent review, integration, publication and issue/memory updates.
