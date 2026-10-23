# Selected Main contracts and conditional key-accounting review

2026-10-23 UTC, #178 under #119. **Accepted scoped tranche** at author freeze
`3040c6736d3a004239256b2ba50f25144e68bec8`: five selected API typed-contract
profiles, their query definition/residual splits, effect-key families and the
conditional program-variable/outcome accounting transfer. **#178 remains
unfinished.** This review establishes no numeric U or H for arbitrary Main
source and does not complete the general source-to-typed-body interface.

The [independent evidence](../evidence/retained-main-typed-profile-review-20261023/README.md)
records a first-attempt audit passing **4,342 checks in 1.080748 seconds**
(wrapper wall time 1.202175 seconds). Selected reviewer: GPT-6 Astra / Extra
High, Linux x86_64. Runtime model/effort confirmation, token usage and cost are
unavailable. The [round record](../evidence/retained-main-typed-profile-review-20261023/round.json)
records the observation interval separately from audit time. No additional
agent was spawned.

## Accepted contract interface

For positive lexical weights r=result, a=argument, b=Written_Bytes,
c=Written_Count, f=Flushed and s=Succeeded, the opened typed postconditions
have these upper profiles:

| Contract | Opened lexical profile | Unit-weight cost |
| --- | --- | ---: |
| Input_Is_Valid | `3+r` | 4 |
| First_Or_Default | `60+2a+12r` | 74 |
| Reject | `1` | 1 |
| Put_Line | `98+17a+6b+3c+f+2s` | 127 |
| Put | `89+17a+5b+2c+f+2s` | 116 |

Each let definition is charged at its own position and again at every use.
The closed-postcondition epsilon costs one additional term node. Formal-to-
actual instantiation substitutes variables; coefficients add when several
formal roles map to one actual key. Argument-proxy definitions remain separate
and retain their own repeated-use charge in subsequent lexical accounting.

For ordinary `term_of_post ~prop:false`, Input_Is_Valid supplies definition
cost 2 and residual True cost 1. First_Or_Default supplies definition `1+a`
and conservative unsimplified residual `59+a+11r`. The procedure posts have
unit result and no extractable result equality, so they remain on Kval. The
separate definition/residual trees are retained; replacing them by one maximum
would lose the useful structure for the later let transfer.

For these five ordinary Eexec contracts, h=0 and o=0. Queries have v=0;
procedures have v<=1. Use p<=1 because the emitted True precondition can remain
a singleton list. The accepted kode recurrence consequently gives local bounds
5 for each query and 7 for each procedure, before an optional WP/SP tag and
excluding already evaluated argument definitions. These are local contract
rows, not a Main-body count.

## Material findings and their disposition

**TP1 — native domain annotations do not establish typed formula shape.**
The author and reviewer independently identified Why3's partial-application
closure path and Boolean/proposition coercion paths. The final source argument
and independent audit attach all 29 used callable/projection symbols to their
actual declarations, clone/export routes and logical result sorts. All
applications are saturated. Boolean values occur in value contexts and
predicates in formula contexts, including let definitions, conditional tests
and quantifier bodies. The guard's native bool annotation is correctly
distinguished from its logical proposition result. Named reference projections
remain explicit unary applications. No selected trigger, higher-order call,
record update, embedded application spelling or complex result pattern is
silently dropped. Comparison/connection conversion avoids the chained-infix
duplication route. This resolves the typed nonenlargement question for the
complete five-contract slice.

**TP2 — File_System is seven keys and the body refinement must be excluded by
control flow.** The six Part_Of objects plus residual File_System produce seven
external keys. Put/Put_Line add four Silver globals, giving eleven write keys.
The runtime body actually declares a ten-object Refined_State annotation.
The author flagged this complication; the reviewer traced the sole registration
caller through `flow_generated_globals-partial.adb:522–534`, the phase-one
serialization and the sole phase-two State_Comp_Map insertion. Explicit
`SPARK_Mode => Off` excludes that complete body refinement from registration.
The Part_Of-plus-residual route is therefore source-derived, rather than an
inference that the observed seven-key shape is universal by itself.

**TP3 — implicit clauses and reference types matter.** The final profiles
include generated result equalities/guards, result invariants, output dynamic
properties and saved slice uses, not merely the public Ada Post text. Global
declaration conversion adds `__ref` to the native snapshot annotations. Why3
also adds free postcondition program variables to the read effect, so the
native seven-read list is not a typed-read ceiling for Put/Put_Line; the
eleven-key union is the correct fixed family. The author corrected these
details and the emitted-True precondition issue before freeze. No defect in a
previously accepted typed-contract result is implied.

**TP4 — U/H remains conditional on the missing Main structure.** The accepted
kode creation families give
`U <= U0+nv+nf+xf+tr+lost+unit_h+lemma+rlpv`. With
`Delta=nh+lost+xf`, the outcome counter is at most `C0+Delta` and the reachable
outcome cardinality at most `1+H0+Delta`. These formulas count reached
occurrences, include nested Cfun bodies and the enclosing Main k_fun, and
retain the incoming counter/key set. SP/WP's fresh logical map values do not
become new program-variable keys. The five fixed contracts now supply their
actual external keys and local h/o/v/p. U0 and the traversal counts still
require the ordinary Main emitter; this tranche does not derive them from
arbitrary source. The distinction is explicit in both author and review data.

No new finding remains within this scoped tranche. Its pre-freeze corrections
are incorporated into the exact reviewed input.

## Source correspondence, evidence and limits

The audit binds all ten author files and 23 provider files, including all nine
declared research providers. It reattaches nine complete native/source/project
members to the existing Q0NIav artifact, confirms all six selected Silver
library files equal current repository sources, and reattaches eleven complete
producer/flow/typing/runtime sources to their original providers. Sixteen strict
source spans retain the reviewed control branches. The signature check also
uses the unchanged complete Main-type/theory source archive.

The audit checks 226 native context nodes and 289 projected nodes, including
query definition/residual trees. It verifies every projected child, binding
identity and selected type, and recovers affine coefficients by direct numeric
evaluation of the native tree with unit-coordinate perturbations and mixed
weights. It imports no author implementation. The universal affine envelope
comes from the reviewed constructor/lexical-substitution argument; these
finite checks are supporting evidence, not universal verification by samples.

The fixed-template transfer uses Generate_Subprogram_Program_Fun's formal
scope, fixed specification/effect generation and implicit-clause branches.
Main actual expressions enter later through proxy/variable instantiation;
fresh serial names can alpha-rename the templates without changing their
binding structure. The native artifact supplies an inspectable exact template,
not a test of candidate membership. Existing tool/source and faithful native
runtime assumptions remain in force; this adds no binary-attestation premise.

The author's final focused check passed 146 affine cases in 0.875547 seconds.
Its round record discloses an earlier tuple/list representation mismatch and
a subsequent focused rerun after source/refinement and extraction additions;
earlier timings/logs are not supplied. The reviewer ran one final audit, with
no failure or successful rerun, and replayed no author/predecessor checker.
Reviewer base is `cc5deefecb2575ea1f51365f9863b75079b7550c`; the author freeze
was imported as `4864a4bf7f66df7fdcc20c4cca9d8e4d010eb6e5`.

The ordinary Main emitter, additional primitive and implicit contracts,
constructor-preserving array conversions, assignments/declarations, generated
branch observations, warning functions, loop frame/index assumptions and
enclosing Main contract remain open under #178. Source/operator/leaf counts
stay symbolic; the old 4096/63/64 admission caps are not assumed as analysis
ceilings. Existing API constants retain their meaning in the pinned dependency
bytes. This partial result establishes no useful whole-rule domain or cap
relaxation by itself, and does not substitute scalar K_fixed for structure.

Main import/alias lifetimes, downstream terminal-goal counts, native GCC and
whole-#119 composition remain separate. The caller-resource/runtime boundary
and single global Why e<=2, two save-entering callbacks and three saves are
unchanged. No target, compiler, solver, proof, capture or predecessor checker
was run; no GitHub, shared-record, harness-state or CLI-memory writes were made.
Later Main rows should reuse this accepted tranche by identity and review only
their new structure and integration.
