# Preparation through printer-entry review, 2026-10-23

Independent bounded review for #119 / #153. **Accepted with the stated
premises** at `366beba68251ece3483193f8104c39391f8c46ef`, following initial
freeze `3e9ea024335bb1e4e9ef9118fd1c0171d8d7d433`. This is a separate R61 report;
the accepted R60 split/shared-demand report and evidence remain unchanged.
Selected reviewer: GPT-6 Astra / Extra High. Runtime setting confirmation
and token/cost telemetry are unavailable. Exact inputs and elapsed observations
are retained in the
[review evidence](../evidence/retained-printer-entry-review-20261023/).

The reviewed cut begins after R58 and ends before the execution of
`Driver.print_task_prepared`. Its fixed-input, source-origin, valid stored
representation, typed ownership, freshness and guarded-mutation premises
remain explicit. The complete source members are from Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c`; the author packet pins 23 members,
51 retained inputs and five external Git inputs. No native target, solver,
capture, author checker or predecessor checker was run by this reviewer.

## Selected routes and initial state

The selected preparation lists and their order agree with the retained
driver sources. Transformation closure lookup, including library loading,
precedes the applications at this cut; this packet does not supply that
earlier missing demand. The false counterexample meta selects recursion
elimination on CVC5. Remaining definitions are nonrecursive singletons.
The physical Dind heads are precisely the two Put-family `acc` components
removed by the accepted wf dependency argument. Thus inductive elimination's
old clause-head construction arm is unavailable; it cannot be silently
treated as a fresh-head producer.

The initial-empty Introduction cache attachment was checked separately from
the earlier formatter result. Module initialization creates the private
tables; prefix registration is not execution. The selected Per_Check
`split_goal_wp_conj` chain does not call Introduction. Input's earlier
counterexample-dependent pass selects `remove_unused_from_context` under the
accepted false-meta result. These facts, together with the accepted
initialization/failure exclusions, provide the initial state for the
chronological private-cache argument.

The generated-formula route excludes the material-array, selector/indexer
and polymorphic encoding branches. Bool is kept; other data declarations
have ground singleton constructors of arity at most two. The projection
pass still creates its local variable before iterating over bool's empty
projection list, so that registration must remain charged. The epsilon
inventory supplies closed conjunctions, and their parent `infix <=`
definition is ineligible for optional trivial inline. Together these exclude
the equality-special and canonical lambda/partial-function producers.

## Stored fields and chronological composition

R57's stronger variable-only saved-image result continues to cover original
context returns. The new Q potential's context floor alone would not prove
a generic arbitrary-context let-expansion theorem. For goals, R56 provides
the complete binder-free seed images, including dead saved entries, with
mass at most six. Ordinary renaming and nullary substitution preserve that
complete property. A saved image with no binding record cannot conceal an
additional saved map.

The two exceptional binding-bearing let values are Put_Line goal 62 and
Put goal 52, each on raw and CE routes. Their targets are binder-free, and
none has a let-value ancestor. The selected later producers do not move
formula results into value children. Simplification can therefore substitute
the exceptional value only into its binder-free target; it cannot place that
binding-bearing result into a later saved image. The independent audit
decodes these four paths directly from retained syntax and substitution
frames, without importing the producer inventory or projection programs.

The potential retains both each let value and every permitted expansion.
It bounds partial simplification as well as complete substitution, including
unused values. Optional-inline bodies have the accepted mass/coefficient
bounds. Lexical predecessor dependencies then bound new nonleaf saved images
by Q, and complete initial images by `V = 6Q` after substitutions. This is
a source-origin argument; strict equality alone would not transport hidden
fields.

An old public or private declaration return selects the whole old object,
which retains its own field bounds and origin. It does not merge old saved
fields with the candidate's unrelated values. Introduction's output premise
bodies are not inputs to later premise candidates within that invocation;
its cumulative substitutions contain nullary applications, not old bodies.
Known-map updates also prevent one queued head from being reused twice in
an invocation. Failed appends remain requests, and weak clearing cannot
create extra values beyond the append producers.

These facts justify the chronological lineage bound
`K = K0 + 64 E P²`, using the accepted right-split `K + 4PL` interface with
live keys `L ≤ P`. The same process-wide `E = 3N + 2` is used throughout;
there is no fresh escape allowance at each stage. Validators start from
immutable fields and do not add a persistent producer edge. Binder-free
images allow visible mass to bound the stored skeleton, while the separate
K/V factors retain all dead entries. The R59 comparison argument extends
using exposed right-operand mass S and source slots P; its zero Ident effect
does not establish primitive collision cost.

## Type writers and review correction

The earlier provisional traversal-as-constructor equation is absent from
the reviewed interface. Introduction maps the unique goal before its private
premise returns and later simplification. Its type-map storage envelope
therefore uses `K_intro = K_goal_seed + 16P²`, without E-dependent old-premise
fields, and `R_intro = 2M(1 + 6K_intro)`.

Source `term.ml:1085–1173` requires four dimensions in the type-map count:
ordinary term visits N, unused bound slots B, all saved keys J, and the free
prepass keys F outside the weak memo. Dead values are included in N. Each
dimension is bounded by R_intro. Empty `ty_inst` makes at most T constructor
requests per callback, supporting the conservative `4T²R_intro` charge.
The finite synthetic fixture deliberately contains unused slots and dead
saved keys; dropping any of B/J/F undercounts its source-shaped traversal.
This fixture is dimension-sensitivity evidence, not an execution or proof
of the OCaml implementation.

Review challenged the statement that an empty type map preserves variable
identities. The source does retain the original variable across `fnT`, and
the weak memo retains its key across the call. That establishes local
liveness, but using it to exclude all `gen_fresh_vsymbol` registrations
would additionally require persistent canonical-table membership after
earlier exceptional mutation. The amended interface charges all
`B + J + F ≤ 3R_intro` possible registrations explicitly. Shape, type-tree
mass, slot cardinality and source origin need only provenance-preserving
renaming. This adds 8,816,475,461,814 registrations across all five processes,
already included in the 419,226,565,740,393,654 direct Ident total. It does
not add another episode multiplier or change K, V, S or the source projection.

Other type writers include algebraic/range type constructors, inferred
inversion applications, data-declaration validation, and metadata's implicit
type-symbol conversion. `is_ts_tuple` has no type-constructor request;
a cold zero-tuple theory has at most two. Ordinary explicit-type
applications, substitution, opening/closing and type folds reuse their
type arguments. Omitted record, tuple-term, beta, cloning and canonical
epsilon builders are excluded by the selected routes. These source sites
are distinct from the larger read-only type traversal envelope.

The amendment also handles a diagnostic edge: repeated polymorphic-variable
matching can reject physically different types even when their shapes agree.
Its `ty_match` diagnostic invokes `ty_inst`; at most one such diagnostic
escapes a selected preparation prefix, and its signature-sized work fits the
existing 64H allowance. The `ls_defn_of_axiom` catch is not selected here,
and the theory-cloning catch lies before this cut. `ty_equal_check` constructs
no type. The unchanged total of actual type-constructor requests is
352,934,955,742,024; it conservatively bounds possible type-tag increments.

The single new reviewer audit passed **233 checks in 1.257311 seconds**.
It checked exact frozen packet/provider/source identities and excerpts,
independently decoded all four exceptional let paths, exercised the synthetic
type-map dimensions, and checked the revised registration/type arithmetic
and six-owner mapping without a second E multiplier. It did not execute a
transformation or import any author/predecessor checker. No failed or aborted
reviewer audit preceded this pass. The source/lineage argument remains an
independently reviewed mathematical argument, not a machine-checked OCaml
semantics proof.

## Export and limits

The six-owner mapping is Ident from direct registrations, Hsdecl from
logical-declaration construction, Hsty from actual type-constructor
requests, Hstdecl from tdecl requests, Hstask from task-add requests, and
Hcpt from at most 64 Patricia constructors per task add. Overcharging unique
goal declarations as Hsdecl merge requests is conservative. The exported
totals already contain E; a caller must not multiply by E again.

The declaration, task-node, formula and validator envelopes cover retaining
passes, side declarations, at most two dependency metas per split clone,
successful old returns and failed prefixes. Actual native integer owners
are kept separate from enormous mathematical visit totals. Inspection found
no selected client of `term_size` or `term_branch_size`; those definitions
do not turn the audit totals into a native accumulator.

Acceptance is only for the stated preparation component.
Library lookup, printer execution, other callbacks/shutdown, primitive
collision/resource costs, physical capacity and whole-process headroom are
not closed by this packet. It does not close #119 or production #88–#94,
change the Oracle, or alter tools, pins, admission or launch behavior.
