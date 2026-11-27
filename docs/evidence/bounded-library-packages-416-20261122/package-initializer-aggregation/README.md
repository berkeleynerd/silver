# Package initializer inventory checkpoint — #416

This packet retains the per-Object source inventory increment. It does not
complete endpoint 2, routine/Main aggregation, or the final assurance join.

`ApplicationPackageInitializerInventory.object_inventory` derives the original
optional scalar-range endpoint syntax and Integer/Boolean initializer syntax
from successful `objectStep`, the original input frame, and its native reader
domain. The exact shadow-removed initializer frame, name masks, source spans,
inferred interval, and declared target interval remain distinct. Arithmetic
obligation discharge, Boolean path checks, nonemptiness, and target containment
are conclusions of the original successful reads. They are not fields required
in the raw `ObjectSyntax.SourceAt` representation.

The focused Linux x86_64 / Lean 4.34.1 run
`20261127T221316-300ed176f105` passed with a fresh axiom audit of 71,173
declarations. All 1,615 captured input hashes matched the retained source bytes.
The run used two workers, two Lean threads, CPUs 6–7, and an 8,192 MiB limit per
Lean process. This was an incremental managed run with a fresh audit, not an
independent replay. Earlier successful prefixes and all failed drafts are
retained separately, with honest changed-input reports for the failed drafts.
Those failures concerned local proof normalization and warnings treated as
errors; no language domain, source model, or proof budget was weakened. The
managed diagnostic for `20261127T220020-fc4848eb208c` records the repeated
Boolean-context rewrite diagnosis.

The remaining endpoint work includes public specification/subtype histories,
state/local/output source-order folds, construction of existing
`Packages.LocalInitializer` consumers with full input/global domains, and Main
declarations starting at the imported frame. The Main join must preserve
`Current.SourceBoundsRefinement` and `Current.StringBoundsSafe`; standalone
empty-import `Predicate.SourceMeaning` is not assumed.

Raw source-body correspondence, final complete validation, publication, and
issue bookkeeping remain with the lead. No native launch is represented by
this packet.
