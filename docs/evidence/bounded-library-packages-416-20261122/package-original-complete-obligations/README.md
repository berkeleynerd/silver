# Original application obligation coverage after review

Refs #416. Independent review of `53bc4fca4a` found that its runtime result
was checked but its enumerated obligation aggregate omitted several raw
declaration families. Its earlier focused packet remains evidence for that
snapshot; its complete-obligation description is superseded by these findings
and corrections.

| Original missing family | Final source inventory and aggregate |
| --- | --- |
| Main String/Character range and length declarations, including the optional argument | `MainSyntax.headerProgram` includes the original argument prefix and every String/Character declaration; `MainSyntax.obligations` includes both `Compose.Check` families. |
| Canonical Main Boolean declaration checks | `MainSyntax.booleanDeclarationChecks` uses the actual entry Boolean/array analysis and joins the retained raw Boolean checks. |
| Package routine-local inline Integer range endpoint arithmetic | `PackageSyntax.localHeaders` retains every original completion and its local `ObjectSyntax` rows; `headerObligations` includes `routineLocalHeaderObligations`. |
| Main and Main-local function/procedure inline Integer range endpoint arithmetic | `MainSyntax.scalarHeaders` retains exact top-level and callable-local source histories; `predicateObligations` includes all raw low/high expression obligations with their actual scalar and array scopes. |

All these source inventories are syntax/native histories. Their successful
checking and discharge are separately constructed conclusions. The original
argument, mixed declaration order, shadowing scopes, named-array contexts and
unused routines remain in the proofs. No fitting-store, semantic-checker,
coverage or safety certificate was added as an admission premise.

`SourceMeaning.obligations` aggregates the full package headers, all package
routine summary-library obligations and complete Main checks as
`Semantics.Obligation`. `SourceMeaning.semantic` derives automatic discharge
from the original native acceptance and its retained source histories.
`SourceMeaning.HeaderBounds` separately derives raw initializer schema traces,
actual Ada bound-store traces, initial/final bound compatibility and final
metadata/fit for every runtime argument list and backing bound store. Its
`Predicate.Program` projection supplies header schemas only; Main execution
uses its original application environment and imported stores.

The final `interpreted_bound_assurance` conclusion retains separate native
facts, checking, semantic-library validity/safety/function preservation,
original constant/state value correspondence, header bounds and runtime
execution soundness. It still covers arbitrary caller locals, the full native
Bundle representation and every runtime argument list. Canonical reader
equations and primitive effect coverage are derived through the existing
checked imports.

Final focused Linux `Silver.ApplicationPackageOriginalAssurance` run
`20261128T025236-628e1a92c064` passed a fresh 96,110-declaration axiom audit.
All 1,761 captured input files matched when rehashed. The two owned endpoints,
both new header helpers, Main runtime helper and reader-effect adapter matched
their protected proof-workspace copies. `source-recheck.json` records those
six exact hashes. Settings were CPUs 0–1, automatic two workers and two threads
per process, and 8192 MiB per process. This final combined check passed on its
first attempt after separate focused success for all new helper contracts.

New checked prerequisites are `7ff7808ad44e9f12635c7df7f4b05630148ce525`
(`ApplicationPackageOriginalLocalHeaders`) and `a568b637c2`
(`ApplicationPackageOriginalScalarHeaders`). They were copied as unstaged
baseline dependencies and are not owned by the endpoint integration commit.
Existing prerequisites include `a76db780b2` (Main runtime initialization),
`584a446186` (canonical effect imports) and the effects closure through
`4a1f575243`. The managed packet captures the complete integrated source set.
Independent review of the final source hashes is recorded in `review.md`.

This is focused original-source semantic validation. The literal
authoritative-source companion (`SourceActual`), complete native and
whole-project/module/provenance validation, and feature/PR readiness remain
the lead's integration work. This stream made no native/source/script change,
OutputBody/SourceActual launch, merge, publication or whole-feature completion
claim.
