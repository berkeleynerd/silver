# Independent review: retained inlining comparand capacity

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The complete retained
table and inspected source argument close the unsuccessful `Hsdecl` comparand
source-work and representation gap for the first Input_Is_Valid/cvc5
`inline_trivial` entry, under the stated source/runtime, well-formedness,
valid-cache and noncolliding-freshness premises. The result includes successful
table comparison, definition closing, candidate strict hashing and shallow
similarity. It does not establish runtime primitive, allocation/collector,
complete transformation or whole-pipeline capacity.

## Frozen inputs and method

Reviewed commit: `3976f5eec984914ac3e04594fd4d1de3d522a8b1`. The initially clean
review worktree is `/tmp/silver-review-why-inline-comparand-3976f5eec9`, branch
`review/why-inline-comparand-3976f5eec9`, created from that exact commit. The
target worktree and all predecessor packets remained unchanged. Review-owned
files are this report and the [independent audit](../evidence/review-why-inline-comparand-3976f5eec9/check.py)
with its [retained result](../evidence/review-why-inline-comparand-3976f5eec9/result.json).

The exact inputs are the [research note](../research/retained-why-inline-comparand-capacity.md)
and the [packet](../evidence/retained-why-inline-comparand-capacity-20261018/README.md):
`README.md`, `profile.py`, `capacity.py`, `compose.py`, `check.py`, `inputs.json`,
`details.json`, `result.json`, `round.json` and `sources.tar.gz`. The audit checks
all ten identities in the packet's `round.json`. The source archive is 123,993
bytes, SHA-256 `713d4dc872959ec056de0799b56c41690aded2cebe2ff838e0278ef63d7fbb0a`.
The reused full capture is 3,791,265 bytes, SHA-256
`5d374cc6d233a717bfc3770839c3322d65d9aaa6feec621b2cfee681d70d1b89`.

I read the applicable AGENTS/Oracle and review-bookkeeping guidance, the focused
#119 authorization and capacity boundary, the relevant assurance/trusted-boundary
sections, the representative and conditional-operation notes, and the
[accepted state review at its exact commit](https://github.com/berkeleynerd/silver/blob/25db3691734130818bbb613a5b059e8e07e42e96/docs/reviews/review-why-inline-representative-state-25f6e96a12.md).
The child harness goal was null. Existing accepted semantic and capture evidence
is reused; this review neither reopens its native capture nor upgrades that
evidence to a universal state-membership theorem.

Source inspection used Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. All 26 source/license members shared
with the accepted representative packet are byte-identical. All 28 Why3 members,
including the seven newly retained utility files, match the complete pinned
Why3 extraction already checked by the representative review. The local source
extraction used for inspection is `/tmp/silver-comparand-review-sources-3976f5eec9`.
These are complete cited files; the packet is not the entire upstream tree.

## Comparand coverage and representations

`Hsdecl.equal` performs the declaration-constructor test before payload
comparison. `Dprop` additionally requires equal kind and physical proposition
symbol. `Dlogic` uses `Lists.equal eq_ld`, whose `List.for_all2` can compare the
first formula before discovering unequal list lengths (`decl.ml:350–366`;
`lists.ml:38–46`). The new prefix-sensitive extraction addresses this cost
distinction explicitly. All 1,203 retained logic lists are singleton; all 6,704
distinct initial objects are classified. The result is 145 possible formula
comparands and 6,559 early rejections.

The 145 include the three unsuccessful old propositions at indexes 143, 152
and 242. Their earlier coordinate exclusions concern successful returns, and
do not remove their possible comparison work here. The independent raw audit
reproduces every selected address and opened profile without importing the
packet's Python modules. The packet's mutation check rejects a newly matching
logic prefix behind a later length mismatch.

Each mapped key is distinct. A local insertion therefore fails a later key
test. `find_or` advances its index after failure and after a successful equality
whose following `get` loses the key (`weak.ml:272–293`). Thus an old object's
formula is compared at most once at its own key. A shallow weak copy retains
the declaration-node pointer and cannot supply a new formula graph. The
accepted physical theory/task wrapper argument remains applicable and does
not turn this into a bound on those other tables.

Both raw walkers include unused saved values; the opened walker follows
remaining frames and counts repeated term edges, all trigger groups and branch
bodies. The audit reproduces 2,034 stored term objects and 38 constant objects.
Every compared constant is `ConstInt` with immediate kind and integer value,
between −2,147,483,648 and 2,147,483,647. The full formula closure has only string
opaque blocks, while the full table graph does contain custom blocks. This
distinction excludes custom-number work from this comparator input without
assuming the entire retained process has only immediate integers.

Relocation, substitution and type mapping preserve the constant payload
(`inlining.ml:21–40`; `term.ml:738–778,1107–1174`). The accepted builtin-integer
body contract excludes range/float conversion on this route. Structural constant
comparison reaches the immediate `BigInt.compare` case (`constant.ml:22–32`);
native implementation of that primitive remains outside the new result.
Type comparisons read tags, variable/symbol comparisons use tags or identity,
and attribute comparison enumerates tag-keyed sets without traversing strings.
Location comparison reaches three immediate fields, not a filename lookup.
Following field zero of a present option is source-faithful even where a
retained option-shaped block contains extra payload words; no one-word
allocation claim is made.

## Transfer and weak-table arithmetic

For logic declarations, `make_ls_defn` adds a head application, one variable
per formal, equality/iff and at most one quantifier (`decl.ml:41–75`). Taking
the maximum of the original complete axiom and `body_nodes + arity + 3` covers
both optimized unchanged closing and reconstruction. The binder ceiling adds
the formals. Eligible inserted bodies are binder-free and pattern-free, with
formal coefficients at most one; substitution cannot duplicate existing
trigger-bearing structure. Rebuilding uses an empty outer trigger list.
Consequently the original full-formula trigger-group count bounds each
candidate, including optional metadata misses. The maximum full-formula bound
is 91, rather than an unadjusted body-only bound.

Strict comparison visits matching constructor prefixes, so its term-pair
count is at most `min(N_left,N_right)`. The physical shortcut and mismatches
only reduce traversal. `descend` consumes a frame before following a saved
replacement (`term.ml:266–281`), so there are at most
`Q*(D_left+D_right)` frame probes. Each probe has at most two ordered-map
lookups. A map with at most `max(B,K)` entries has at most `max(B,K)+1`
lookup entries including the empty endpoint. This justifies the exported
map-entry arithmetic even when saved values are unused.

Binder-map additions are bounded by the opened binder slots. `Extmap.add`
visits one path; each balancing return creates at most three nodes, within
the four-times allowance (`extmap.ml:105–161`). Nullary patterns introduce no
binders. Attribute enumeration visits each operand node at most once; its
helper allowance covers empty endpoints and comparison steps
(`extmap.ml:359–378,492`). The list allowance separately includes binder,
pattern and both trigger-list levels. The corresponding strict-hash transfer
uses the same frame/binder argument and charges attribute folds, discriminants,
constant hash inputs and modular mixing (`term.ml:420–505,536–539`). Hash mixing
is intentionally modular; natural binder/map arithmetic is separately bounded.

Independent sums reproduce 2,032 table term-pair entries, 418 definition-close
entries and 1,911 candidate hash entries. The table map totals are 130,454
lookups and 4,641,324 tree entries. The existing 1,145 fresh-identifier increment
is unchanged: these strict operations allocate no identifiers. `t_similar`
uses shallow identities and at most seven application children or two case
branch pointers (`term.ml:404–418,654–659`). The 88,985,261-call allowance is
the sum of the already attached substitution and kernel entry bounds; its
large size is conservative arithmetic, not observed execution.

Exactly 142 requests can merge; the goal takes `unique`. Before any first
resize, each insertion raises `oversize` at most once and shrinking only lowers
it. Therefore `oversize <= 142 < 5003/2`, whereas resizing requires the strict
opposite inequality (`weak.ml:117–121,185–263`). This inductively rules out the
first resize, leaving 5,003 buckets.

Each bucket then contains at most seven initial objects plus 142 local
insertions. Growth requires a fully occupied old bucket, so its new length is
at most `floor(3*149/2)+3 = 226`. A comparison scan finishes before its subsequent
insertion/shrinking. Shrinking can temporarily duplicate a moved pointer in the
discarded tail, but installs a prefix without duplicate retained objects;
weak clearing can only remove keys. Hence request `j` has at most `7+j`
callbacks, totaling `142*7 + 142*141/2 = 11,005`. The 32,092 weak-copy-attempt
allowance and three-word declaration copies follow. Array/ephemeron runtime
conditions and aggregate allocation remain explicit external obligations.

## Validation, next obligation and round record

The packet's focused checker passed in **1.414992 seconds**, including source
identities, complete table/graph validation, profile/result replay and all seven
regression/boundary checks. The independent audit initially passed in
**0.696211 seconds**; after adding exact review-input and predecessor-source
identity checks, the retained final run passed in **0.646525 seconds**:

```sh
python3 -B docs/evidence/review-why-inline-comparand-3976f5eec9/check.py
```

No native target, debugger, server, compiler, build, prover, solver, proof or
full-suite run occurred. These offline checks corroborate the inspected source
argument; they do not constitute a machine-checked operational semantics proof.
Local links, Python syntax and whitespace were checked before commit.

The next bounded shared-state obligation is to establish the starting value
and continuing-call scope of the private `Ident.id_register` counter
(`ident.ml:187–192`), then join the accepted increment of 1,145. A maximum tag
among reachable objects alone does not bound a counter that also registered
now-dead objects. Inventory retained artifacts first; request a new projection
only if that precise counter input cannot otherwise be established. This is a
recommendation, not a new derivation or capture performed by this review.

Other shared tables/counters and lifetime callers, runtime primitive lowering,
closure/native-stack/allocation/collector composition, other fixed entries and
downstream transforms/printing remain open. The complete-transformation and
whole-pipeline flags correctly stay false. The Oracle, admission rules,
production sources, tool pins and configuration are unchanged.

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the parent.
Runtime model/effort confirmation and token/monetary measurements are unavailable.
Host: Linux 7.0.14, x86_64. No GitHub write, further delegation, CLI-memory update
or harness write occurred; the parent owns integration and publication.
Intended outcome: challenge coverage, traversal/representation transfer and
no-resize arithmetic. Achieved: scoped acceptance without material rework,
with independent raw-state and arithmetic evidence. The measured interval is
recorded below; it excludes initial worktree setup/reading and later commit or
parent integration. Full task elapsed time was not separately instrumented.

Measured review interval: `2026-10-18 22:12:32 UTC` to
`2026-10-18 22:17:16 UTC`, **284 seconds** through report preparation and initial
local link/syntax/whitespace checks. Small final report corrections and staging
are outside that measured interval.
