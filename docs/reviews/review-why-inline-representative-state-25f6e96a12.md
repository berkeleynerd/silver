# Independent review: retained inlining representative state

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The complete retained
`Decl.Hsdecl` state and the source induction supply the missing representative
contract for this first Input_Is_Valid/cvc5 entry. The attached envelope
`(E,V,T,A)=(8,6,3,80)` and **1,145 local identifier registrations** are justified
under the stated relevant-source/runtime, well-formedness, valid-cache and
noncolliding-freshness premises. This does not establish complete transformation
capacity, identifier-counter safety, other process histories or whole-pipeline
capacity.

## Frozen inputs and method

Reviewed commit: `25f6e96a12a6c611e24307db8103d29959391971`, on the initially
clean isolated branch `review/why-inline-representative-state-25f6e96a12`.
The target worktree was not edited. Owned changes are this report and the
[small independent audit](../evidence/review-why-inline-representative-state-25f6e96a12/check.py)
with its [result](../evidence/review-why-inline-representative-state-25f6e96a12/result.json).

Exact review inputs are the
[research note](../research/retained-why-inline-representative-state.md) and
[packet](../evidence/retained-why-inline-representative-state-20261018/README.md):
`README.md`, `check.py`, `project.py`, `inputs.json`, `result.json`, `round.json`,
`capture.tar.gz`, `failed-capture.tar.gz` and `sources.tar.gz`. The packet's
manifest and round record identify their exact bytes. The successful archive is
3,791,265 bytes, SHA-256
`5d374cc6d233a717bfc3770839c3322d65d9aaa6feec621b2cfee681d70d1b89`.
Its graph is 33,140,099 JSON bytes, SHA-256
`c6e8be9fc2e4243c4b6c0c78ac437fdd531ccba477f9a4b85f3f6c7d1c33f1ed`.
These serialized sizes are distinct from the 9,058,224 retained OCaml
header/payload bytes.

I read the applicable AGENTS/Oracle, assurance/trusted-boundary and review
bookkeeping requirements, focused current #119 session memory, and the
[accepted conditional correction](review-why-inline-representatives-e150a8483f.md)
and [semantic review](review-why-inline-refinement-3509848447.md). Their already
successful broad evidence is reused. The child harness goal was null.

Source inspection used the retained Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml revision
`8eb41f72ded84df884c3671734c947f612091f84`, the actual decoder/observer and
retained installed-instruction disassembly. For the absence-of-registration
claim I also inspected the full extracted Why3 tree at
`/tmp/silver-producer-response-20261018/complete/why3-9390baf120ef260547dfa14f08e11c890b203d9c`.
This is an archive extraction, not a Git checkout. Its 4,623 files matched the
previously pinned complete ZIP (9,976,591 bytes, SHA-256
`8d4a8dcdcdf965ce3cc6935bdd60c1378a5ec47b4a0bdedae6651ee50ed03f8c`);
all 21 Why3 source/license members in this packet also matched. The packet's
`sources.tar.gz` contains complete cited files, not the entire Why3 tree.

## Capture and selection argument

1. **The table root and weak-slot layout correspond.**
   The installed `mk_decl` loads `camlWhy3__Decl + 0x2c0`, then the hashcons
   closure in module field zero. The retained `Hashcons.Make` construction and
   `hashcons` use closure field three for `next_tag` and field four for the
   weak-table record. `Weak.create` writes its bucket array, hash array, limit,
   oversized count and rover in the decoder's order. The ephemeron constructor
   and getter use two additional fields and the same `caml_ephe_none` sentinel.
   The runtime capture checks these shapes, the actual hashcons code pointer
   and seven instruction prefixes; the mapped executable has the accepted
   identity. These are source/instruction correspondence checks, not a new
   binary-semantics proof.

2. **The retained roots cover every initially selectable object.**
   The observer reads all 5,003 buckets, 11,968 key slots and their aligned
   cached hashes before traversing all 6,704 distinct nonempty declaration
   roots. It applies no symbol or size selection; diagnostic limits abort.
   Graph closure includes repeated edges and stored delayed substitutions.
   The process remains stopped, with no inferior weak-get call that could
   darken a key. Nonempty keys are a conservative superset even if collection
   later clears them. Link words do not add table keys. Custom external C
   storage is intentionally opaque; none belongs to the surviving input-root
   subgraph. Costs of excluded custom comparands remain open.

   `Weak.find_or` compares a shallow copy, then returns the original successful
   weak-get value; a miss inserts and returns the candidate (`weak.ml:284–311`).
   Copying therefore does not create another selectable declaration. Rehashing,
   shrinking and collection move or remove existing objects. The exact rooted
   sharing isomorphism with all 14,477 accepted input blocks permits reuse of
   the prior inventory without name, attribute, location or string normalization.

3. **The key filter and three shape exclusions are sound.**
   `ls_equal` and `pr_equal` are physical equality. `Hsdecl.equal` compares
   kind and declared symbols before formulas (`decl.ml:350–366`), and mapping
   preserves those keys. All 6,704 objects are considered; 6,559 fail these
   necessary keys. The remaining 145 are the 142 exact non-goal input objects
   and three older propositions. Goals take `unique` and never query this
   table.

   Strict comparison follows delayed frames from variable leaves, compares
   constructors and binder-list lengths, and includes triggers
   (`term.ml:266–281,325–395,515–532`). Bound names may differ, but equality
   under valid frames entails equal opened occurrence/binder/pattern/application
   coordinates. Attribute/location checks can reject additional pairs; they
   cannot equate different constructor shapes. The physical shortcut is used
   only without pending frames. Independent raw traversal reproduced:

   | Input index | Older object `(n,b,p,a)` | Candidate upper bound | Exclusion |
   | --- | --- | --- | --- |
   | 143 | `(72,8,0,19)` | `(72,7,0,19)` | Binder slots |
   | 152 | `(53,7,0,18)` | `(52,7,0,18)` | Term occurrences |
   | 242 | `(17,2,0,8)` | `(16,2,0,8)` | Term occurrences |

   These are each declaration's own alternative ceilings, not a global mass
   bound. The argument does not assume strict comparison preserves the
   attributes produced by opening.

## Induction, wrappers and numeric attachment

The source gives one declaration constructor per mapped root. Opening,
termination checks, mapping and task validation do not insert additional
`Hsdecl` declarations. The 143 mapped keys are distinct, so an earlier locally
inserted candidate cannot satisfy a later key. At this goal entry, `store`
bypasses its outer memo and `bind` constructs a new `on_tagged_ls`/`fold_map`
closure (`trans.ml:51–55,76–108,234–236,291–300`; `inlining.ml:92–102`).
The environment and fold memo therefore start empty and follow the captured
spine in order.

Assume prior environment bodies belong to their accepted alternatives.
The current candidate then obeys its corresponding ceiling; the exhaustive
initial projection and the distinct-key argument leave only that candidate or
the exact current input object. The latter's opened body is a permitted
alternative: `project.py:172–183` recursively chooses the first miss branch and
checks equality with the interned original at every one of the 143 model roots.
The reviewed opener follows delayed substitution and attribute unions. This
preserves the actual eligibility test, including the uniform 45-body result,
without inferring attributes from strict equality. Thus the next environment
body remains covered. The use of candidate ceilings is inductive, not circular.

Theory wrapper equality requires the physical declaration. Task wrapper equality
requires the physical theory declaration and equal predecessors; the semantic
goal-predecessor case is excluded by `check_task` before normal construction
(`theory.ml:233–235,283`; `task.ml:75–92,140–161`). Under valid cached-map
invariants, wrapper reuse cannot introduce a different declaration/spine.
This does not bound wrapper tables or their cached-map storage.

The selected fold is synchronous. The captured process has one thread, its
guards report no new threads, and the complete Why3 `src`/`plugins` scan found
no finalizer/alarm/memprof registration or thread/domain spawn. The `Domain`
matches are abstract-interpretation modules. The GNAT interrupt handler saves
and exits (`gnat_main.ml:298–309,335`); it does not return to the fold. Together
with the existing relevant-runtime premise, this supports absence of foreign
insertion during a continuing invocation. It is not a proof of interrupt,
collector or allocator capacity.

All surviving old seeds consequently reuse the input inventory: eight saved
entries, six-node unary/binder-free values, nonunit-key disjointness, size-three
types, and the 80-attribute union. With insertion closure and opened-body
correspondence, the repaired representative contract is instantiated. The
unchanged local registration derivation is `235 + 6*123 + 4 + 168 = 1,145`:
kernel registrations, six conservative outer-formal opening sites, logic
termination body openings and task match-check openings. Strict declaration
comparison creates no fresh identifiers, so its still-unbounded cost does not
invalidate this local increment count.

The new table also supplies `next_tag=6836`; at most 143 increments give 6,979.
The accepted pure backing transfer gives outer length at most 36,336 and bucket
length at most 18,169 from this retained starting state. Its explicit integer,
array and ephemeron representation conditions still apply. Other counters,
tables and earlier/later callers are not covered by these numbers.

## Validation and round record

The packet's focused checker passed independently in **2.071712 seconds**,
including archive/dependency identities, full table/graph coverage, input
isomorphism, model replay, exclusions, all-miss attachment, arithmetic and all
seven rejection/regression checks. No native process was started.

The separate raw audit imports neither `Refiner` nor `project`. It follows
delayed frames directly, counts all 143 input vectors and all three older
proposition vectors with trigger/repeated-edge occurrences, independently
counts the table slots, and checks the registration sum. Its initial inline
form passed in **0.589750 seconds**. At the parent's request I retained it as
the linked standalone script, reading the pinned graph directly from the
archive; that reproducibility check passed in **0.669154 seconds**. Run it with:

```sh
python3 -B docs/evidence/review-why-inline-representative-state-25f6e96a12/check.py
```

The full ZIP/extracted-tree identity check took **0.270122 seconds**. These
checks corroborate the source argument; they do not mechanically prove native
OCaml semantics. The author's first failed empty-array capture and corrected
successful attempt remain distinct retained evidence; neither was repeated.

Complete comparator/comparand work, other shared initial states and lifetime
callers, runtime allocation/GC composition, other fixed entries, downstream
transforms/printers and the complete #119 capacity conjunction remain required
open obligations. No production source, admission rule, Oracle or tool pin
changes, and no whole-language assurance claim follows from this review.

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the parent.
Independent runtime model/effort confirmation and token/monetary measurements
are unavailable. Host: Linux 7.0.14, x86_64. New native capture, debugger,
server, compiler, prover, solver, build, proof and full-suite runs: **zero**.
No GitHub write, further delegation or CLI-memory update occurred. Parent owns
integration, publication, issue status and durable memory.

Intended result: independently challenge capture completeness, strict-coordinate
exclusion, insertion/environment induction and numeric attachment. Achieved:
scoped acceptance without material rework; local links and staged diff checked.
Review timing excludes the later commit and parent integration/publication.

Review interval: `2026-10-18 21:47:14 UTC` to `2026-10-18 21:52:03 UTC`,
**289 seconds** through report preparation and local-link/syntax checks.
