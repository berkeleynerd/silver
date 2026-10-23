# Right-only splitting: whole-family and temporary bounds

Research #119 / #153, Linux x86_64, 2026-10-23. This supplies the missing
family interface for Alt-Ergo `split_premise_right` and the Z3 Introduction
call to `split_intro_right`. It is a source argument, with a focused arithmetic
and source-identity check, not an execution of the selected transformations.
Independent review is recorded separately by the lead. No whole-pipeline
capacity, current-language change or implementation readiness follows.

## Input and exported quantities

Use Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, as retained in the
[source archive](../evidence/retained-why-session-helper-source-20261019/README.md).
The [packet](../evidence/retained-why-right-split-20261023/README.md) binds the
exact source members and the pure bound function.

The input is a valid formula whose fully opened semantic tree is finite and
case-free, including let values, application arguments, triggers and saved
images actually exposed by opening. Let M>=1 count occurrences of all term
nodes in that tree, with multiplicity, and P count all its bound-variable
slots. These are semantic input bounds established by the producer, not the
number of physical nodes, the length of a printed term, or the size of a
stored-variable cache. Existing correct opening/substitution and finite valid
representation premises apply. Dead saved-map entries are not silently
bounded by M or P.

Select `right_only=true`, `byso_split=false`, `asym_split=false`; `stop_split`
may be true, and `intro_mode` may be either value. The source `split_axiom`
overrides the by/so and asymmetric flags of `right_proof` before splitting.
`right_intro` already selects the required flags. Case-split/stop attributes
remain allowed. No Tcase branch or pattern compilation is reached.

| Quantity for one invocation | Upper bound |
| --- | ---: |
| `split_core` entries | M |
| Each of the positive and negative family cardinalities | M |
| Either family converted by `to_list` | M |
| Visible mass of each returned or temporarily reconstructed term | 3M |
| Visible bound slots of each returned or temporary term | P |
| Sum of visible masses in the positive family | 3M^2 |
| Sum over positive and negative families | 6M^2 |
| Sum of visible slots in either family | MP |
| Each `bwd` or `fwd` visible mass | M |
| Top-level calls from `split_core` to `drop_byso` | M |
| Total `drop_byso` recursive term entries | M^2 |
| Term-reconstruction kernel entries, as scoped below | 64M^2 |
| Fresh variable registrations made by opening | (M+1)P |

The side family is always `Unit`. For splitting one axiom with D distinct
dependency heads, at most M declaration constructions, M prsymbol clones,
M ordinary tdecl constructions and MD metadata constructions follow. The
singleton case preserves its old prsymbol and emits no copied dependency
metadata, so these are upper bounds, not equalities. The task wrapper and its
validation are additional caller work. Introduction's own later recursion,
private-cache operations and fresh symbols are also separate.

## Family induction and the right-only guard

Write c(Unit)=0, c(Zero)=1, c(Comb(Base))=1 and add counts at an Op. The
source degree is min(2,c). `++` has count at most the sum; `map` preserves or
reduces count. A nonempty `bimap` has at most the product of its input counts.
Its Unit cases produce Unit, including when the other operand is Zero.

In `pcaset`/`ncaset`, right-only splitting uses a full family only when its
flag is set and the sum of the other supplied degrees is at most one.
Otherwise it selects one `bwd`/`fwd` term. Thus each potentially multiplying
bimap has an operand of cardinality at most one. The guard is about the
other family, not merely about whether the selected formula was tagged.
For disjunction the guard uses the original `sf2.pos`; if its selected pf2
can be large, that original family is also large, so the guard still works.

Under `no_csp`, both flags stay false by induction: the ordinary recursive
updates only clear/swap/propagate false flags, while a case attribute writes
the two false configuration flags. This matters at iff and if, where the
condition/left operands are therefore collapsed independently of their
possibly large unselected positive/negative families.

The branch proof, allowing constants and early stops, is:

| Source branch | Positive count | Negative count |
| --- | --- | --- |
| atom/stop/intro boundary | <=1 | <=1 |
| conjunction | <=p1+p2 | <=max(1,n1,n2) |
| disjunction | <=max(1,p1,p2) | <=n1+n2 |
| implication | <=max(1,n1,p2) | <=p1+n2 |
| iff, children under no_csp | <=p1+p2 | <=2 |
| if, children under no_csp | <=p_then+p_else | <=n_then+n_else |
| not | <=n_child | <=p_child |
| let | <=p_body | <=n_body |
| forall | <=p_body | <=1 |
| exists | <=1 | <=n_body |

The no-byso special spellings recurse only into their retained f1. Each
recursive input is a disjoint semantic child occurrence; no branch recurses
twice into the same occurrence. Hence at most M core entries. Applying the
table inductively gives p,n<=M. All side fields stay Unit, including the
otherwise eager construction of arguments passed to a side bimap. The final
`side=Zero` repair branch is consequently unreachable.

## Shapes, discarded work and opening

`bwd` and `fwd` keep or remove input structure; `drop_byso` removes its special
spelling and otherwise reconstructs the same node kinds. They have mass at
most M and at most P slots. A selected output contains each contributing input
subtree at most once. An iff negative branch can add two negations; an if
branch can add a negation and replace the outer if with one connective.
The other branches preserve their one connective/binder. Induction therefore
bounds every produced term by 3M nodes and P slots. This includes unselected
positive/negative families and terms made before a subsequent `++` absorbs
them. It does not assume only the ultimately returned positive list was built.

For an explicit operation interface, count a kernel entry when the splitter
invokes a logical constructor/closing wrapper or attribute-copy wrapper, or
when `drop_byso` invokes its binding-safe mapper and that mapper reconstructs
the visited term. This excludes the internal recursion of substitution,
free-variable-map construction, attribute-set union and declaration validation.
Those require the caller's stored-map/type/metadata interfaces; 64M^2 is not
an allocation or complete helper-visit count.

At any core node, the selected monoid maps/bimaps each handle at most M bases.
The iff/if branches contain the most maps and reconstructions; sixteen times
(M+1) covers their source-level constructor/copy callbacks, including the
arguments evaluated for empty side families. It also covers the other branches.
Summed over at most M nodes this is <=32M^2. At most M calls to `drop_byso`
each visit at most M nodes, adding at most four scoped mapper/reconstruction
entries per node: the mapper, a logical constructor or closing wrapper, and
attribute copying, with one spare entry. The internals of a closing wrapper
remain outside this entry count. Thus 64M^2 safely covers both accounts without counting
only surviving results. Fixed-shape monoid/record/list allocations have their
ordinary valid-request interface; their total is not a new RAM gate.

Opening a let or quantifier clones its bound variables; closing uses existing
variables and starts a fresh empty substitution map. Direct core opening
therefore registers at most P variables. Each full `drop_byso` traversal can
register at most P more through `t_map`, `t_open_bound` and `t_open_quant`
(including epsilon inside a term). With at most M such traversals the bound is
(M+1)P. `t_subst_unsafe` and the closing/free-variable helpers do not register
variables. This remains an attributable charge on an exceptional prefix; any
asynchronous save keeps the existing separate global budget.

No conclusion K'=K+P or V'=V is drawn for stored maps. An opening imports the
old saved substitution as well as the renaming; its dead values can be nonleaf.
The companion generated-field proof must bound those fields and the internal
helper work before using this semantic interface for complete capacity.

There is a useful conditional lineage bound. Suppose saved images are
binder-free, and every reached binding's live free-variable cache has at most
L keys. Include free/formal variables exposed by dequantification when deriving
L; the remaining bound-slot count alone need not bound it. A surviving binding
then originates at a visible input binding. Its core-recursion path opens at
most P enclosing slots. A retained `drop_byso` result adds at most one further
opening walk: each such call takes the original current f (or original fif),
not a returned sf field. A later outer drop discards the earlier transformed
result rather than traversing it again. Monoid maps subsequently reclose
bindings without opening their payload. There is no case compilation followed
by recursive splitting of its output. A selected returned lineage therefore
has at most two such walks; four is a conservative allowance, including the
selected reconstruction boundary. Each restricted substitution adds at most
L saved keys (`Mvs.set_inter m b.bv_vars`). Thus **K+4PL** bounds keys on a
retained binder for this call, under these additional producer premises. When
the producer proves L<=P the familiar K+4P^2 allowance applies. This does not
bound V, add a fresh preparation episode or cover a later old hashcons return.

## Representation and composition boundary

The arithmetic M, P, 3M^2 and 64M^2 is mathematical accounting, not an OCaml
counter. It is not required to fit an OCaml integer merely because the proof
counts it. The local `trivial` accumulator starts at zero, adds a degree <=2,
and recurses only while its value <=1, so every reached sum is <=3. No
aggregate output-cardinality counter is maintained by the monoid traversal.
Caller identifier/tag counters and real native array/map/index/request operands
retain their separate representation guards. Physical resources and normal
allocator/OS behavior retain the existing trusted boundary.

The caller sums these bounds over actual source-derived inputs and episodes,
without resetting the process-wide two save-entering callbacks, three saves
or e<=2. This result covers both successful and abandoned prefixes under the
existing control/behavior relation. It neither closes later printer work nor
provides all stored-field, metadata, hashcons or caller-table bounds.

The focused check includes adversarial large-family products and a deliberately
unguarded cross product: the latter must fail the linear family bound. It also
checks exact source identities and local arithmetic boundaries. These probes
check the interface and guard sensitivity; the source induction above supplies
the universal argument. The author check was repeated for the added lineage
export and then the review's mapper-entry clarification; no predecessor
checker or native/prover execution was repeated. Root live model/effort and isolated cost telemetry are unavailable;
the project baseline for this reasoning is Astra / Extra High, with no claim
of a live model switch. Actual check time is retained in the packet.
