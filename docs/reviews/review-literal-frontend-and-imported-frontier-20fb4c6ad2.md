# Independent review: frontend attachment and imported gigi frontier

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and claim correction [#131](https://github.com/berkeleynerd/silver/issues/131).

**Disposition: scoped acceptance; no new material finding.** The frontend
attachment preserves the accepted Main-only interface. The #131 repair
correctly retracts source-family closure for imported-helper-dependent pool,
graph and emitted-stream consumers while preserving their conditional
arithmetic. This accepts the correction, not an imported-helper bound or an
absence proof. R and whole-pipeline capacity remain unresolved.

## Exact reviewed inputs

The integration target was `20fb4c6ad2048230892d0455e6a572268734e920`, checked
out clean on `review/literal-frontend-imported-frontier-20fb4c6ad2` in an
isolated worktree. The batch covers:

- Frontend attachment `604b66778aacc2c501e1ee535f6037573010c183`, integrating
  worker `c0beef3fc2f35c96308af53ceef060fc4ea2b93c`: aggregate formula,
  checker, pins, results and research document.
- The six-file #131 repair at the integration target: aggregate formula,
  checker, README, retained results and research document.
- The separately frozen finding packet
  `696e470685cf153b4d57abc6bed5ca37295c8d97`, inspected through Git objects:
  `docs/research/retained-literal-gigi-warning-residual.md` and its five-file
  evidence packet. This is a pure addition after the repair target, not a
  different repair implementation.

The finding packet explicitly describes historical Silver revision
`6803ee54ca8d0a20bde4d2ce14562b84a9e46fd4`. Its historical absence/closure
quotes are not attributed to the repaired text. I verified all 14 historical
input identities against that revision and all 14 complete source identities,
including Git blob hashes, at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

Applicable AGENTS, Oracle authorization and review bookkeeping were reused
from the preceding bounded review. The frontend component's eight files are
unchanged from `de30957c9e242dd783cda187c71122a2b757f0a1`; its
[accepted source review](review-literal-native-frontend-de30957c9e.md) and
successful focused replay remain applicable. This batch did not reopen those
constructor proofs or attempt the missing imported extent-fold analysis.

## Frontend attachment

The aggregate pins the frontend formula, checker, manifest, retained result,
check result, round record and argument before loading the component. Direct
verification matched all seven new pins and their bytes at the reviewed leaf
revision. The checked loader validates its 21 predecessor inputs and selected
native sources. Nested source-validation totals are reported separately,
explicitly acknowledging overlap rather than adding them to the direct
unique-file count.

`native_main_frontend_attachment` passes the actual shared source bytes to
the leaf and recomputes its projection, constructor result and named gigi
interface using the checked unchanged model. It requires exact source-count
equality, including source hash/size, word equality with the Why projection,
and equality of the full Main counts, scanner pools, lexemes, constructor
result and gigi result. It does not substitute the smaller ordinary subtotal
for either constructor identities or source visits.

The fixed frontend node/entity allowances are explicitly None in the
recomputed gigi input. Complete frontend, gigi allocation and native capacity
flags must remain false. The local literal-length condition is attached as
its own condition; logical Main counts are not interpreted as physical
storage, imported helper events or warning R. The retained default interface
matches the reviewed frontend leaf exactly, excluding only the leaf CLI's
separate identity metadata.

The ten new negative cases cover either fixed field silently becoming zero,
the two smaller-subtotal substitutions, constructor/gigi/frontend/allocation/
capacity completeness promotion, and a source-count mismatch. Their retained
results show the expected interface-join rejection. These checks support the
attachment; they do not extend the leaf's Main-only source guarantee.

## Imported layout and the missing premise

The source chain establishes an unresolved decision that the old argument
had skipped:

- Imported unconstrained String construction builds its bounds template,
  nonshared XUA array and template-plus-array object record
  (`decl.cc:2433–2545`). `build_template_type` obtains lower/upper fields
  through the template reference and constructs its guarded upper bound
  (`decl.cc:7265–7390`). These are separate from actual literal extents.
- Array layout derives bit and byte sizes from the bound expression;
  finalization calls `variable_size` separately for nonconstant sizes
  (`stor-layout.cc:1962–2020,2660–2767,2803–2808`). The object-record path
  independently finishes a BOUNDS-plus-ARRAY record
  (`utils.cc:4562–4583`). Constant-size bounds/fat-pointer records do not
  establish that object's size shape.
- `variable_size` dispatches placeholder-bearing expressions to
  `self_referential_size` **before** testing global binding scope
  (`stor-layout.cc:67–85`). Global placement therefore does not exclude
  helper construction. The simple-expression and SAVE_EXPR-abort guards
  remain real alternatives; the actual folded shape has not been resolved.
- `skip_simple_constant_arithmetic` follows unary and constant-sided binary
  expressions, not arbitrary conditionals or two-variable binary expressions
  (`tree.cc:4220–4243`). If the helper-construction branch is reached, it
  creates a function and return body, records it, and returns a call
  (`stor-layout.cc:155–265`). `finalize_size_functions` gimplifies/finalizes
  retained helpers before ordinary function analysis
  (`stor-layout.cc:275–292`; `cgraphunit.cc:2562–2594`).

This corroborates the need for an imported-layout premise. It proves neither
that a helper is actually created nor that one survives to emission. A
successful ordinary-entity cache lookup also cannot retrospectively count
the first conversion's synthetic layout work. The finding packet correctly
keeps actual folded XUA bit/byte shapes, canonical/repeated layout, object
record continuation and eventual emission as unresolved questions.

The warning residual remains null. Candidate generated nonvoid-return or
location-copy warning routes are not equated with actual puts; neither
reserved Standard locations nor final declaration locations are promoted
into a complete transitive zero-warning invariant. The packet's restricted
declaration-site table is not exported as R or treated as an exhaustive
original-gigi count.

## Repair propagation and three-state results

The repair preserves numerical pool/graph transfers under explicit premises
and exposes their arithmetic as `conditional_arithmetic_fits`. Their source
closure flags now remain false, and their additional imported-constructor
frontier flags are false. Exposed aggregate pool/graph event and scan fields
are labeled conditional. C+4/C+5 symbol arithmetic and the one-body graph
formulas are not presented as established whole-source bounds.

Exactly these aggregate conditions become None:

| Conditions | Missing source-family justification |
| --- | --- |
| `native_varpool_and_shared_tree_pool`, `native_graph_and_summary_lifetime` | Exclude or bound extra post-prefix pool/symbol/body contributions. |
| `Main_assembler_object_interface`, `Main_GAS_BFD_storage`, `literal_output_linker_representation` | Establish completeness of the emitted stream, or compose additional emitted bodies. |

The downstream propagation is necessary: preserving Main's instruction
shape does not prove that Main is the only emitted function. A retained
helper could affect text, frame/CFI, symbols, relocations and storage outside
the existing stream model. Conversely helper creation alone does not prove
emission. The repaired assembly open join and the explicit
`Main_is_only_defined_body_established` and
`Main_is_only_emitted_body_established` flags preserve that distinction.
Nested assembler/GAS/link arithmetic remains usable only under the newly
explicit complete-stream premise; its local fit fields are not independent
source-family assurance.

`conditional_conditions` copies the original Boolean arithmetic results
before the affected source-family conditions become None. The final verdict
requires every actual condition to be literally True. Failed predicates use
`is False`; unresolved predicates use `is None`. Hence Hello has passing
conditional arithmetic, five unresolved conditions, no failed predicates,
and a false evaluated-predicates verdict. The 5,000-call case separately
retains its failed linker sufficient check in `failed_conditional_predicates`
alongside those same five unknown conditions. Neither state is represented
as an observed native failure or an adopted source cap.

Main frontend, ingress, warning demand and per-function CF/CFG/SSA/RTL
interfaces remain within their existing preservation premises. They are
not silently summed over possible helpers. Full frontend/gigi, global
counters, collector and whole-pipeline closure remain open.

## Evidence and round record

I reused the successful frozen 83-case aggregate checks and default generation.
The implementation records are `/tmp/silver-131-repair-validation.json`
(4.002640986 and 3.106937277 seconds) and the earlier attachment record
`/tmp/literal-native-frontend-attachment-run-c0beef3fc2.json`
(4.417314490 and 3.682163841 seconds). Those are implementation runs, not
reviewer reruns. The finding packet retains 23 source/scope checks over its
14 full sources and 14 historical inputs, with 0.0984-second check time.

A small reviewer identity/result audit verified those source and historical
identities, the seven new attachment pins, unchanged leaf bytes, exact default
Main-interface equality, all ten frontend rejection rows, and the five
unknown conditions and separate 5,000-call failure in the retained 83-case
result. Its output is retained at
`/tmp/silver-review-20fb4c6ad2-u0iqn401/identity-and-result-audit.json`.
No missing question required another aggregate or leaf replay. No compiler,
prover, solver, debugger, native worker or full-suite execution occurred.

Selected reviewer settings were **GPT-6 Astra / Extra High**, assigned by
the parent. Runtime model/effort confirmation and token/cost measurements
were unavailable. Review began at 2026-10-18 20:00:47 UTC; source review,
identity/result audit and report completed at 20:04:55 UTC, elapsed 248
seconds. This is the review round's elapsed time, not whole-team runtime.
The intended outcome was to check attachment correspondence and propagation of
the imported-frontier correction; both are supported within the stated
scope, with no new material finding or implementation rework.

The live harness returned no goal; none was created or changed. No GitHub
write or delegation occurred. CLI memory was not updated. The parent owns
integration, publication and the next imported-layout investigation.
