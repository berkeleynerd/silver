# Named constrained Integer-array parameters

## Selection and boundaries — 2026-11-21

The owner instructed **“Proceed”** after the recommendation of this new language
feature. [The dated authorization](session-memory.md#2026-11-21--named-constrained-integer-array-parameters-selected)
selects [#410](https://github.com/berkeleynerd/silver/issues/410), in
[milestone 27](https://github.com/berkeleynerd/silver/milestone/27), as one coherent
capability with one shared final validation and review checkpoint. Implementation,
validation, independent review and the accompanying feature PR are authorized.
This plan describes selected development; it does not claim current support.

The three included forms share one constrained array identity and bounds model:

1. Named constrained fixed-size Integer-array types and initialized objects of
   those types, reusing the admitted Integer component and index machinery.
2. Read-only array `in` parameters in existing Main-local functions **and
   procedures**, alongside existing scalar parameters and scalar results/outputs.
3. Bounds queries `'First`, `'Last`, `'Length` and `'Range` from the statically
   known bounds of the named Integer arrays and existing anonymous Integer-array
   objects, using their common fixed-bound metadata.

Dot product and Horner polynomial evaluation are the task drivers. Neither is a
samples-only substitute for the selected language work. Array `out`/`in out`
parameters, array results, unconstrained/null/multidimensional arrays, slicing,
whole-array operations and a separate expansion of subprogram-local array
objects are excluded. Existing anonymous-array support remains intact.
Boolean or Character named-array types are not selected. No Oracle amendment,
new trusted boundary, source-limit increase or new proof/report infrastructure
is selected. A necessary semantic mechanism outside these boundaries calls for
a recorded scope reassessment rather than silently extending the batch.

## Selected declaration, call and bounds rules

Declare an ordered Main-level type as `type T is array (L .. H) of C;`, where
`C` is `Integer` or an earlier admitted named Integer subtype. It is one
dimensional, ascending and nonempty with static Integer bounds. Compute its
length using wide arithmetic and require `1 <= H - L + 1 <= 2048`, including
unused types. This is a new explicit per-type scope limit: its numeric ceiling
matches the existing source-derived object-cell pool
([`silver_array_bindings.ads`](../src/silver_array_bindings.ads)), while limiting
the declared type ensures materializable length and an Integer-valued Length.
It does not reuse the stored-object pool as a formal-count or capacity charge. Keep the full signed Integer endpoint domain, including negative and
non-1 lower bounds. A type declaration needs no accompanying object. Multiple
array formals do not collectively consume the object-value capacity.

A named object has `A : [constant] T := ...` with the existing complete positional
aggregate or exact static singleton named choice. Keep complete initialization
and current component update rules for mutable Main objects. A named type's source
declaration supplies its identity: another declaration with identical shape is a
distinct type. An anonymous array does not acquire nominal identity by shape: array actuals
require the same positive named-type identity, even though anonymous Integer-array
objects can supply bounds-query prefixes.
Unknown, later or wrong-kind type names are rejected. Main declarations share
one case-insensitive namespace. Formals/locals cannot collide with an earlier
named type, following the earlier Integer-subtype rule; loop binders may hide
existing type, formal or object spellings. A binder does not resolve to itself
in its own specification. Types remain visible by ordered lookup inside closed
subprogram bodies, without exposing outer Main objects.

An array formal has explicit mode `in` and that named type. Its actual is a bare
visible object or enclosing `in` formal of exactly the same declaration identity.
Repeated read-only inputs and forwarding to earlier subprograms are allowed.
Both existing function and procedure forms admit mixed scalar/array signatures,
with positional, reordered named and positional-prefix/named-suffix associations.
Existing nonrecursive earlier-only calls and placement rules continue. Procedures
still require a writable scalar formal; results, writable outputs and copy-back
remain scalar. There is no array assignment, result, writable formal or additional
whole-array expression use.

Within a subprogram, every array component read is nonstatic with the component's
full declared interval, independent of actual aggregate values or current Main
state. Check the complete index and input domains, every path and all permitted
compositions. Array formal and component writes are rejected. Keep scalar input,
result, procedure initialization, incoming-state and alias/copy-back guarantees.

`T'First`, `T'Last` and `T'Length` return `L`, `H` and wide-computed `H-L+1`.
These queries are static on the named constrained type, its constant/mutable
object or its `in` formal: their values depend on the static subtype, not the
components (Ada RM 4.9 paragraphs 8 and 32). Each scalar query counts as one
operand and zero operators; synthetic bound arithmetic consumes no user operator
budget. `for I in [reverse] A'Range` or `T'Range` uses `L .. H`, retaining finite
forward/reverse iteration and existing range-mask/hiding rules. `'Range` is a
range construct, not an Integer expression or component read.

Query prefixes are simple visible named Integer-array type, object or formal
names, or existing anonymous Integer-array object names. Anonymous-object queries
use the same fixed-bound metadata and static scalar-query rules. Only the default
first dimension is admitted, with no explicit `(N)`.
`'First`, `'Last` and `'Length` are scalar atoms wherever existing scalar/static
expressions are permitted: declarations/bounds, subscript expressions, aggregate
singleton choices, predicates and scalar actuals. `A (A'First)` is one component
read with a bounds query, rather than a nested component read. Local initializers
retain their existing ordering before incoming formals: visible `T'First` is
available there, whereas formal `A'First` becomes available at body entry.
Boolean-array types, parameters and attributes remain unselected.

## Faithful callable drivers

[Dot product](../rosetta/d/dot-product/task.wiki) requires a callable function
multiplying corresponding terms of same-length vectors and summing them.
Arbitrary length is optional. Use the required `[1, 3, -5]` and `[4, -2, -1]`
example, with result `3`, through a genuinely array-parameterized function.
A shared named constrained three-element type supplies equal bounds by type;
use declared bounded components and executable guards wherever arithmetic needs
them. The function must check over every permitted component value, rather than
specializing its proof to the two Main aggregates.

[Horner's rule for polynomial evaluation](../rosetta/h/horners-rule-for-polynomial-evaluation/task.wiki)
requires a routine taking coefficients in increasing power order and a value of
`x`, evaluating by reverse multiply-add. Use `[-19, 7, -4, 6]` at `x = 3`, with
result `128`. A procedure with a read-only coefficient array, scalar input and
existing scalar outputs exercises the second call kind. Use a bounded accumulator
and visible executable refusal when the next step cannot safely fit; do not
truncate, saturate or change the polynomial on a failure path. Derive the required
guards for the entire declared coefficient, `x` and accumulator domains.

Both samples should use the bounds queries meaningfully. Exercise callable
forwarding and named/mixed composition in focused regressions where that makes
the sample clearer. Expected output, including Image spacing and refusal paths,
must be derived independently. Samples demonstrate the rules; they do not supply
the universal assurance argument. Confirm faithful assessments against the task
text instead of copying the stored unconstrained-array approaches unchanged.

## Shared implementation and proof work

Use the existing scalar call-selection, constrained-array checking, loop ranges
and declared-interval evaluation as the foundation. Extend native metadata and
its Lean interpretation together so type identity, bounds and component ranges
are explicit across declaration lookup, formal binding, indexed reads and calls.
The retained source-derived formal pool is not permission to add a separate
arbitrary type, array-parameter or call-frame count limit.

Derive capacity for new type/object/formal metadata from accepted source bytes.
Account for bound arithmetic, storage/stack use, array reads in calls, native
obligation production and report envelopes. Inspect actual pinned-producer
obligations before adjusting report classification; do not accept broader output
messages speculatively. Preserve exact admitted source bytes through verification
and compilation. Keep report provenance and full obligation coverage mandatory.

Extend the semantic composition argument for declared-domain component reads,
range/index checks, attribute results and staticness, matching actual identity,
read-only forwarding and mixed array/scalar binding. Include functions and
procedures, Boolean/scalar contexts, loops, branches and unreachable paths.
Preserve procedure alias analysis of actual payloads and existing scalar writable
outputs; no array copy-back or array-result semantics are introduced.

Review handwritten source-shape pins with their actual native changes and
semantic/source proofs. A new pin or successful separate model does not establish
source correspondence. Source-derived capacity and complete automatic-discharge
claims remain part of assurance, rather than optional later hardening.

## Verification and single final checkpoint

Keep one implementation issue: the work is a single capability, not one increment
per agent or proof component. Commit-sized changes remain reviewable without
creating separate deliveries or declaring a partly implemented form supported.
Live state, claims and handoffs belong on #410; this record holds stable design
and links actual evidence when it exists.

Before expensive integrated validation, read the managed run summary and establish
focused complete-contract native success for every new/contract-changed helper,
including strengthened callees and affected callers. Use canonical
`dev.py prove --unit FILE` or `--subprogram FILE:LINE`; inspect policy and
whole-helper coverage, including malformed/empty states allowed by preconditions.
Check corresponding Lean targets over the full declared domains, batching targets
and reusing matching successes. No pending helper contract enters the checkpoint.

Focused positive and negative controls must distinguish nominal type identity
from equal shape; bounds and component types; initialization; declaration order,
visibility and namespace collisions; component read intervals and staticness;
read-only writes; unsupported array modes/results; all four bounds queries and
permitted contexts; positional/named/mixed calls; forwarding; procedure aliases;
and composition with existing loops, conditions and scalar modes. Exercise source
capacity endpoints and preserve existing source-policy mutation controls. Compile,
prove and run positive fixtures through the full route, checking exact outputs.

On stable captured current inputs, complete native proof/audit, compiler build,
Lean/module/axiom/actual-source audit and the full regression/sample suite under
[development.md](../development.md#proof-loop-and-validation). Reuse only matching
results under its invalidation rules, retain failures as failures and record
actual Linux host, requested/granted resources and fresh/cached scope. Use managed
reservations and all available Lean CPUs by default; record deliberate reductions.
No mandatory cold rebuild or independent kernel replay is added. macOS evidence
is independent and nonblocking.

Update `language.md`, the catalogue, samples, roadmap capability status and this
record together at admission. Add a precise delivered Rosetta identifier, revise
current-language descriptions and affected task assessments with honest review
metadata, render through `rosetta/refresh.py --render`, and update the relevant
stage issue/Stage fields. Broad `arrays`, `functions`, `procedures` or
`unconstrained-arrays` identifiers must not be claimed from this fragment alone.
Record actual mappings gained, elapsed delivery time and expensive checkpoint
attempts with existing run records, including failures, repairs and interruptions.

Independent review must assess the complete implementation, full declared-domain
contracts, source correspondence and final evidence applicability. Resolve
material findings before support/completion; prepare the feature PR within the
owner's authorization. PR #385 remains held and Worca remains stopped. Record any
later merge instruction separately rather than inferring it from feature approval.
