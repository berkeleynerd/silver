# Independent review: original-gigi warning residual and attachment

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and imported-frontier finding [#131](https://github.com/berkeleynerd/silver/issues/131).

**Disposition: scoped acceptance of both frozen targets; no material finding.**
The selected constructor and location argument supports R <= 5 actual
warning-map puts, including replacement puts. The empty elaboration function
has one allocated function structure and one persistent definition-number
increment, despite never reaching finalization or gimplification. Together
with the two reviewed String helpers, the non-Main definition-number increment
is three. The aggregate attachment uses these results without closing its
five broader unresolved conditions or replacing unknown allocation costs.

## Exact inputs and authorization

The source target is `6f3a5af341113c60df6d539fdb5283ceef0a7314`, compared
against `bd15740afc3453be73f176887724bfbe78da60df`, reviewed in the initially
clean branch `review/literal-warning-residual-6f3a5af341`. Inputs are the
[source argument](../research/retained-literal-warning-residual-bound.md)
and [evidence packet](../evidence/retained-literal-warning-residual-bound-20261018/README.md):
`README.md`, `source-manifest.json`, `interface.json`, `derive.py`,
`check.py`, `result.json` and `check-results.json`.

After this source assessment, the parent separately supplied aggregate target
`2f595d4300eb975b833cd27d8ac11b4ae0e2d8c2`, compared against
`a409ff9db1e7a290bc12dd415d0d9518c93e4652`. I reviewed its seven-file diff
in the separate clean branch `review/warning-residual-attachment-2f595d4300`:
the aggregate `compose.py`, `check.py`, `inputs.json`, `result.json`,
`check-results.json`, `README.md` and
[pipeline source argument](../research/retained-literal-pipeline.md).
Only this report is edited, in the source-review worktree.

This is a bounded independent review within owner-authorized #119 research,
under the applicable AGENTS, Oracle and review bookkeeping. The selected
family is the existing one-with Main/SPARK shell, C >= 1 direct qualified
literal Put/Put_Line calls, N >= 0 nulls, no declarations/use clauses and
literal lengths at most INT_MAX. The retained source/configuration and
relevant installed-behavior correspondence remain premises, not newly
observed compiler facts. No admission or language change is assessed here.

I reused the accepted Main-local construction/projection and exact two-helper
results. The historical cold-layout note at the base still contains the XVE
description corrected and independently confirmed in the earlier review.
That correction changes neither the helper count nor this location argument:
the new pointer field has constant size and introduces no additional helper.

## Constructor frontier and counted interval

R starts at the retained stop immediately before `Compilation_Unit_to_gnu`
and ends at entry to Main's `gimplify_body`. Its excluded local term remains
the already reviewed at most 2C+N index/array TYPE_DECL and null LABEL_DECL
suppression calls. Main's initial-gimplifier term J=2C+1 is separate. Both
size-helper initial gimplifications occur inside R's interval.

The source unit constructs one potential elaboration procedure and then
processes context and Main (`trans.cc:5967–6097`). Main acts as its own
spec; the separate-spec traversal is not taken. The explicit with selects
namespace construction, not a traversal of Silver_IO's body or Ada.Text_IO;
implicit withs return an empty list (`trans.cc:8333–8339`). The fixed library
has precisely the two ordinary IN String/void procedures. Its Static ghost
state and postconditions are absent from the accepted native Main expansion.
The selected declaration/action/inline/check/cleanup exclusions therefore
remain applicable; no source object, contract body or nested subprogram
appears through this context route.

Each of the two possible external procedure entities reaches the ordinary
function constructor once. The entity cache returns before reconstruction
(`decl.cc:400–445,4170–4340`). The profile conversion processes String;
void return excludes return-padding construction, and IN parameters exclude
CICO records. `gnat_to_gnu_param` uses the ordinary parameter builder without
a push; its location restoration does not rerun the completed type graph
(`decl.cc:5740–5918,6058–6122,6198–6201,6320–6500`). The completed String
fat-pointer links exclude later dummy-pointer construction. The source's
incomplete/private/cloned-record cache exceptions do not apply to String.

I checked the namespace creation guard and one-component encoded Silver_IO
name (`trans.cc:6427–6505`). I also inspected the seven Ada gcc-interface
C++ files' direct warning-site inventory: `gnat_pushdecl` suppression and
the scalar NULL_EXPR gimplifier hook are the only direct sites. The latter
is absent from the selected expressions. Generic continuation sites require
the separate location argument below; the direct-site inventory alone would
not establish R.

The potentially nonreserved pushes are one Main function, one empty
elaboration function, at most two imported procedure functions and one
namespace. Each reaches `suppress_warning` at most once. That API executes
at most one put and updates an already-present disposition in place
(`gcc-diagnostic-spec.cc:150–181`). Thus these routes contribute at most
1+1+2+1=5 puts without assuming their guards succeed or their locations differ.
Parameters, results, size-function declarations, fields and the translation
unit do not add a `gnat_pushdecl`; the forced hard-register dummy is built
directly at BUILTINS_LOCATION. The local 2C+N declaration allowance remains
separate, and constant literal/template construction adds no new warning site.

## Reserved-location argument

The key invariant is the full location value being plain UNKNOWN or BUILTINS,
not merely its extracted pure locus. Standard's entities and bounds originate
at `Standard_Location` (`cstand.adb:54,895–939,1040–1053,1819–1861`). An
uncached entity conversion sets input_location before constructing declarations
(`decl.cc:500–505`). Standard maps to BUILTINS; No_Location leaves the existing
value unchanged (`trans.cc:11006–11018`). The recursive selected String graph
visits only Standard dependencies or already cached scalar/builtin objects,
so neither case restores a Main/library source location inside that graph.

This covers type stubs as well as fresh declarations. `create_type_decl`
may reuse a stub, but the selected graph constructed that stub under the same
reserved invariant (`utils.cc:2917–2963`). The profile does not first build a
limited/private String dummy at a library location. `gnat_pushdecl` chooses
contexts without changing the location and suppresses before its final
GNAT-location setter (`utils.cc:894–965`). Therefore its Standard-derived
type/bound/debug pushes perform zero map puts, including the optional XVE
stub. Counting all such declarations is unnecessary for this warning projection.

The selected layout expressions are constants, bound references, integer
conversions/arithmetic/comparisons/conditionals and later arithmetic around
the two size calls. Generic builders give them plain reserved locations;
`set_expr_location_from_node` does not install a Standard source location
(`trans.cc:11065–11085`). The relevant comparison-inversion copy therefore
has a reserved destination. The folded conversion of a MODIFY_EXPR with
constant RHS is absent from these original expressions
(`fold-const.cc:4650,9368–9380`). Copying the size trees uses `copy_tree_r`,
not the inline remapper, and constant literal extents do not instantiate the
imported placeholder expressions into Main. No selected builtin-call warning
handler or size-function inlining route is introduced.

Each helper has two fixed signed-32-bit scalar parameters and a scalar
u64/u128 conditional return. Its declarations use the reserved input location;
its body uses unlocated generic builders (`stor-layout.cc:181–265`).
Unsharing before location reset copies nodes without warning mutations
(`gimplify.cc:944–973`; `tree-inline.cc:5735–5795`). `gimplify_body` then resets
input_location from the helper declaration. Scalar parameter/result sizes
are constant; parameter processing does not synthesize variable-size or
callee-copy code. Recursive expression lowering changes the input only for
an explicitly located expression (`gimplify.cc:20360–20364,21600–21778`).

Temporary declarations inherit that reserved input, labels use UNKNOWN, and
conditional-arm assignments use ordinary unlocated builders. The nonvoid
return suppression, return/conditional copies and possible comparison copies
therefore have reserved destinations. Complex/empty/cleanup/exception-filter
and NULL_EXPR warning sites are excluded by these scalar bodies. The result
does not depend on initially clear no-warning flags or an empty global map.

I checked the ad-hoc-location hazard explicitly. `gimple_set_location` copies
dispositions whenever its previous stored value is nonzero
(`gimple.h:1934–1964`). Fresh tuples are cleared; scalar assignment, label,
condition and return builders do not call `gimple_set_block`. GIMPLE_BIND
stores its lexical block separately. The relevant call/debug block setters
are absent, including `finish_update_gimple_call` in gimple-fold. Scalar folds
preserve the prior location or use ordinary cleared builders; annotation
only fills missing locations from the current reserved input
(`gimple.cc:168–183,471–520,635–644,1485–1525`). The full stored value thus
stays plain UNKNOWN or BUILTINS. Both warning-copy overload families guard
reserved destinations, so all helper copies and suppressions contribute zero
actual puts, even if their flags change.

The remaining global-declaration and pre-analysis routes do not add warning
mutations under the selected no-debug/no-instrumentation configuration.
Size functions are finalized before initial graph analysis; the accepted
discard argument keeps them out of ordinary analysis. Alias/asm queues are
empty, and dummy/constant initializer processing introduces no warning-bearing
expression. `check_global_declaration` runs after the reachable queue has
processed Main, beyond R's endpoint (`cgraphunit.cc:1176–1454,2562–2594`).

## Empty elaboration and body/counter projection

The compilation-unit constructor always makes the potential elaboration
FUNCTION_DECL and calls `allocate_struct_function` once. The nonnull
declaration consumes one function-definition number
(`trans.cc:5980–5994`; `function.cc:4812–4815,4848–4867`). Main's body
translation returns an empty outer statement list; global/external declaration
expressions are not added to the elaboration body, and the namespace is
side-effect free (`trans.cc:8217–8220,9066–9140`; `utils.cc:674–677`). With
the selected auxiliary/action exclusions, the saved elaboration BIND has an
empty statement list. The empty guard skips body compilation and finalization
(`trans.cc:698–723`).

Consequently this function is never gimplified, ordinarily lowered, processed
as an IPA body, expanded to RTL or emitted. Its structure and persistent +1
number remain real costs. The two helpers add +2 function structures/definition
numbers and their separately reviewed +2 symbol UID/order increments. This
supports the exported +3 non-Main definition-number contribution and zero
other generated FUNCTION_DECL bodies for this selected frontier. It does
not establish empty-elaboration symbol registration, allocation totals or
counter-to-label widths. All those fields/joins remain open.

## Callable and aggregate attachment

The source wrapper checks the frozen warning-transfer identity and calls it
with R=5. I independently reproduced its entire stored C=1,N=0 result and
checked six arithmetic/endpoint cases. The composition is
I=2C+N+5, J=2C+1, incoming occupancy at most 4098+2C+N, outgoing at most
4099+4C+N, and at most 4C+N+7 post-prefix warning-map GGC requests. For
C=1,N=0 this is I=7, J=3, occupancies 4100/4103, eleven requests and
capacity ceilings 16381/16381. These are sufficient bounds, not native
observations or adopted language limits. The inherited probe/prime/request
checks and at-most-one control/finalizer contribution remain in place.

For aggregate target `2f595d4300`, I verified all 113 repository pins and
byte identity of the entire attached R packet against the source target.
The context adds checks for all 35 source files before loading the wrapper
and generated-function interface. The runtime join checks C/N, the Main
copy terms, R=5, the source-closure/replacement premises and equality of the
complete transfer result with the frozen callable at R=5. The stored aggregate
warning result exactly equals the wrapper result; its generated-function
interface exactly equals the reviewed interface.

The new `native_initial_warning_map_lifetime` predicate reflects only the
accepted interval's arithmetic. The six new negative cases protect replacement
coverage, source closure, the empty function structure/+1 counter, and its
still-null symbol-registration/allocation fields. The adapted zero-residual
case rejects erasing the established bound. I inspected these changes and
their retained results without repeating the successful full suites.

Setting `Main_is_only_emitted_body_established` true is justified by the
complete selected generated-body frontier plus the accepted helper-discard
and unchanged selected later-schedule premises. It does not assert that
existing assembler bytes/label numbers are unchanged. All five pool, graph,
complete assembly, GAS/BFD storage and link conditions remain null; the
additional emitted-stream interface and allocator totals remain null.
Complete imported capacity, gimplifier/collector lifetime and whole-pipeline
capacity remain false. The attachment carries +3 definition increments as
an interface, rather than silently treating them as zero or closing their
consumer joins. No production admission changes.

## Evidence and round record

I independently checked all 35 complete source lengths/SHA-256/Git-blob
identities and all thirteen historical Silver inputs at the frozen base.
Each source identity also matched its exact path/length/hash entry in the
origin manifest. This focused identity audit took 0.086333849 seconds; the
focused wrapper/result/algebra audit took 0.016792331 seconds, and aggregate
pin/result/interface verification took 0.051523 seconds. These are offline
Python checks on Linux 7.0.14 x86-64, glibc 2.43; they do not execute GCC or
mechanically prove C++ semantics.

Reused source evidence: 32 passing checks, 35 source pins and thirteen
historical inputs; retained checker runtime 0.166852 seconds and implementation
round 624 seconds. Reused aggregate evidence: 95 passing offline cases in
3.953564226 seconds and default generation in 3.267231906 seconds. No full
successful suite or prior native capture was rerun. New native/compiler/
prover/debugger/server/solver executions: zero.

Selected reviewer settings: GPT-6 Astra / Extra High, assigned by parent;
runtime confirmation and token/cost measurements are unavailable. Review
ran from 20:33:23 to 20:38:14 UTC, 291 seconds including both assessments
and reporting.
Intended outcome: challenge the complete warning/source frontier, reserved
locations, empty-elaboration counters and subsequent scoped attachment.
Achieved: both frozen targets accepted without material findings or rework.
Parent owns integration, issue status and durable memory; CLI memory was not
updated. The child harness goal query returned null; no goal state changed.
