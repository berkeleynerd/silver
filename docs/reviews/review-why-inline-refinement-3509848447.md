# Independent review: symbol-sensitive retained Why3 inlining

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The weighted transfer
supplies the stated conditional semantic and kernel-event bounds for the one
retained first Input_Is_Valid/cvc5 entry. It covers every unknown `inline:no`
exclusion set. It does not establish exact native hits, complete preparation
capacity, process-wide counter safety or whole-pipeline capacity.

## Frozen inputs and method

Reviewed commit: `35098484475dbb2da7a0e663194c2251abb8d1a1`, based on
`7c89b21e2489d984bdabcae3d5bd88a6dd38e2b8`. The initially clean isolated
review branch is `review/why-inline-refinement-3509848447`; the target branch
and worktree were not edited.

The complete review target comprises the
[research note](../research/retained-why-inline-refinement.md) and
[evidence packet](../evidence/retained-why-inline-refinement-20261018/README.md):
`README.md`, `refine.py`, `compose.py`, `check.py`, `inputs.json`,
`details.json`, `result.json` and `round.json`. I read the applicable AGENTS,
Oracle, capacity-contract and assurance/trusted-boundary requirements, and
the bounded review/reporting instructions. The child harness goal was null.

The capture acceptance at `775420106b831bee90c1f64b0b0d5872e30e810d`
(integrated by the parent at `215a1488fc`) is reused. I read that report and
the predecessor decoder/adapter; I did not repeat its capture, driver or
installed-instruction audit. The conditional kernel transfer and its
[accepted source review](review-why-preparation-5a731deb4a.md) are also reused.

Source inspection used the retained complete Why3 files at
`9390baf120ef260547dfa14f08e11c890b203d9c`, particularly `inlining.ml`,
`term.ml`, `decl.ml`, `ty.ml` and `ident.ml`. The refinement's dependency
checks and predecessor replay verified the pinned source/capture identities.
The graph remains 1,490,344 bytes with SHA-256
`d7f49ce0181875434292f228c3d599c8c8157b3d1f0ac6793f0d12c2558184be`.
The relevant-source/runtime and well-formed, noncolliding-symbol premises
remain assumptions; this review adds no binary attestation.

## Source correspondence and inclusion argument

1. **The environment follows the real declaration order.**
   `inlining.ml:36–40` maps children before considering the original
   application's symbol. It does not recurse into the returned replacement.
   At `:57–84`, `decl_map` uses the preceding environment for the entire
   declaration, and only a mapped singleton logic definition can then enter
   that environment. The refiner implements that order. The retained graph
   has 81 singleton logic definitions and 62 proposition roots; forward uses
   and a definition's own body cannot use its later environment entry.

2. **Unknown metadata is overapproximated without weakening eligibility.**
   `Trans.on_tagged_ls` reads payloads absent from the capture. Retaining an
   optional hit and miss at each candidate application includes every
   consistent exclusion set, and independent per-occurrence choices only
   enlarge that set of possibilities. The same miss alternative covers the
   additional `notls` guard. `eligible` matches the source `notdef` and
   `trivial` predicates: variables/constants/Booleans, distinct variable
   application arguments, closed non-epsilon arguments, and the
   `inline:trivial` override (`inlining.ml:119–145`). Symbol attributes are
   unioned for this eligibility test only, as in the native fold.

   The possible/certain tests handle mixed choices conservatively. A
   possible closed alternative can satisfy an argument; the remaining
   variable choices require a distinct matching. Certainty rejects every
   possible bad argument and every possible duplicate variable. All 81
   actual definitions have equal possible and certain results; 45 qualify.
   Consequently an induction over declaration batches includes every actual
   environment body despite the unknown metadata. This conclusion relies on
   the source inclusion argument, not finite exclusion enumeration.

3. **Nonrecursion includes symbols hidden from the opened tree.**
   `get_used_syms_decl` opens the definition and uses `t_gen_fold`, whose
   binder fold visits stored substitution values (`decl.ml:518–524`,
   `term.ml:1183–1205`). The model unions original stored body symbols,
   outer definition substitution values and triggers, visible output symbols,
   and stored provenance from every possible prior hit. Mapping and
   substitution can retain or copy symbols from those sources but do not
   invent a new logic symbol. This is a conservative superset even when a
   saved value disappears after opening. No definition contains its own
   symbol in that superset. The separate type-symbol namespace is covered by
   the existing unique-identifier premise.

4. **Occurrence weights cover duplication and scope.**
   For fixed formals, the nonformal coordinate vector plus each formal's
   occurrence coefficient is additive over constructors, repeated DAG edges
   and trigger occurrences. Taking coordinatewise maxima at a choice can
   combine incompatible alternatives, which preserves an upper bound.
   Simultaneous substitution replaces each formal leaf once and does not
   substitute recursively inside its replacement (`term.ml:739–778`). Thus
   `c + sum(q_i * u_i)` bounds the substituted result componentwise.

   Opened binders have distinct local identities. Substitution renames body
   binders and their scoped references while leaving argument free variables
   free; let expressions, case branches and quantifier triggers use their
   proper scopes. Type matching follows formal types and the result type,
   with the same simultaneous instantiation behavior as `ty_match`/`ty_inst`.
   It does not change the measured term, binder or pattern shape. Pattern
   summaries retain the required node counts, distinct variable slots and
   logic symbols; they are not asserted to be complete native pattern objects.

5. **The kernel event sum retains its narrow endpoint.**
   Each original opened node/application gives at most one replacement/unfold
   entry. Only the 85 possible matching input sites need hit charges. For
   each, the saved body is already transformed by the preceding environment.
   The earlier accepted relocation argument empties delayed maps before the
   hit-body type pass, supporting its node bound and the final substitution
   bound without including all hidden opening work.

   Every saved environment body has free variables among its formals, so the
   number of nonzero formal coefficients bounds the free keys considered by
   type substitution. The identifier charge is therefore
   `sum(input b) + sum_hits(2*body b + nonzero formal coefficients)`.
   In this capture the hit-body binder sum is zero, the node sum is 156 and
   the free-formal sum is 67. The resulting bound is `168 + 67 = 235`.
   The extra openings in `open_ls_defn`, validators and declaration processing
   remain outside this kernel, as the note states.

## Numerical checks and retained limits

A focused assertions-enabled Python replay called `compose.compose()` and
compared both complete outputs against the frozen JSON files. It passed in
0.155220 seconds, including the dependency/source/capture replay. The same
check confirmed that all saved formal occurrence coefficients agree with the
separate free-variable traversal. Among 137 reachable application/pattern
logic-symbol tags, no tag mapped to multiple captured symbol pointers; this
checks the concrete pointer/tag join used by the refiner.

I additionally traversed the raw frozen graph independently of `Refiner.open`
and `Refiner.replace`. That traversal resolves delayed substitution frames,
retains trigger and repeated-edge occurrences, and filters applications by
the preceding set of source-eligible symbol identities. It reproduced all
594 input applications and the exact ordered sequence of 85 `(root index,
symbol tag)` hit candidates over 143 roots. Its independent count/arithmetic
check passed in 0.041918 seconds. It uses the reviewed eligibility results;
it is an independent hit-mapping check, not another eligibility oracle.

The complete replay reproduced output coordinate sums
`(n,b,p,a) = (1613,168,12,594)`, mass 1,793, maximum root mass 99 and goal
mass 73. It also reproduced the reconstructed formula mass sum 2,263,
maximum 99, task-chain upper bound 512 and 143 mapped declaration constructor
calls. The reconstructed formula allowance follows `make_ls_defn`'s head,
equality/iff, formal occurrences and optional outer quantifier.

The author's successful 156-exclusion regression run and direct
duplication/trigger/type/capture/eligibility/negative checks are reused from
the frozen packet; their recorded elapsed time is 3.417544 seconds. I read
the tests but did not repeat that full successful suite. Neither these finite
checks nor the arithmetic replay mechanically prove OCaml semantics.

There is no claim that 45 definitions or 85 hits occur in the actual native
execution. Complete hidden substitution operations and stored representations,
type work, validators, identifier creation outside the kernel, initial and
process-wide counters, shared cache backing, other fixed input/driver pairs,
later transforms and serialization remain open. These are required remaining
composition obligations, not optional hardening. No admission rule, Oracle,
toolchain or production capacity verdict changes.

## Review round record

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the parent.
Independent runtime confirmation and token/cost measurements are unavailable.
Review host: Linux 7.0.14, x86_64. New compiler, prover, native target,
debugger, server, solver, Lean or full-suite runs: zero. No external write or
CLI-memory update occurred; the parent owns integration, issues and memory.

Intended outcome: challenge the all-exclusion weighted transfer, symbol-hit
join, binding/type semantics and kernel event counts at the frozen target.
Achieved outcome: scoped acceptance with no material repair requested.
Only this report is changed in the review worktree. Review timing is recorded
below and excludes the later commit and parent integration/publication.

Review interval: `2026-10-18 20:34:55 UTC` to `2026-10-18 20:38:35 UTC`,
220 seconds through report preparation. No material rework was needed.
