# Standalone scalar-header inventory review — 2026-11-28

The integration lead independently reviewed `eb16ea1cc5bf1963a6ff7925306baf1e7f175f24`
for #428/#416 before integrating it as `5d6912f5dc`. Scope: the new
`PredicateScalarHeaderInventory.lean`, changed `Current.lean` and
`PredicateCorrespondence.lean`, and their directly consumed source-history and
raw-header definitions. This reviewer did not author those changes. The project
category is critical proof review, Astra Max; live lead model/effort is not
independently exposed by the available tools. This is a scoped review, not a
closing feature review or a new proof run.

No consequential finding in this repair. The normalized program and admission
remain unchanged. The original `ScalarTokensAt` and `MixedTokensAt` histories
produce complete Main and local-callable header projections, including unused
definitions. The projections share the selected shell, initial state and final
state from `Predicate.SourceMeaning`. Their declaration steps reuse the original
incoming scalar/array scope and low/high expression order; the raw expression
obligations are not reconstructed from only normalized interval endpoints.

`Inventory.SourceAt` introduces no discharge premise. `source_inventory` proves
existence and discharge from the original parse histories, and `Classical.choose`
selects that finite mathematical witness. The corresponding source relation and
discharge are both exposed. This does not supply a new project axiom, change the
authoring language or turn external solver success into membership. The existing
executable `automaticDischarge` still computes its uniform certificate; the
source-specific list has a separate universal finite-step discharge theorem.

The combined inventory reaches `Current.admitted_fragment`, discharge and
assurance, and the changed executable correspondence conclusion. `Tools.generate`
now carries the same original source as parsing and building, and faithful
generation refines the combined list. Completion is required for admitted
`SourceMeaning` pairs. This restriction avoids demanding generation for unrelated
arbitrary source/program pairs without weakening the endpoint for admitted
programs. The consistency model remains explicitly a model of the interface;
complete external generation and solver completion remain documented premises.

Validation reviewed: final `Current` focus `20261128T052653-b8a68a5f7d5e` passed
29,297 declarations, with all 1,752 captured inputs matching in the authoring
workspace. The earlier examples check predates the final completion-contract
scope adjustment. The evidence packet retains both distinctions and the failed
and interrupted drafts. `PredicateCorrespondence` and its authoritative-source
closure are being checked by the separate integration batch; this review does
not claim their pending result or complete #416 assurance. The owned file hashes
are retained in the [repair packet](../evidence/bounded-library-packages-416-20261128/standalone-scalar-headers-428/README.md).
