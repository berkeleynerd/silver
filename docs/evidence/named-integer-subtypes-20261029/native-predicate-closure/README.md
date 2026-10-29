# Native Predicate closure for named subtypes

Issue [#286](https://github.com/berkeleynerd/silver/issues/286). Selected native
implementation worker: GPT-6 Astra / Extra High; runtime model confirmation and
token/cost measurements are unavailable.

The successful focused run `20261029T161019-1954ab856759` checked scalar-array
recursion and Predicate NativeLibraries, BasicHelpers, BasicLibraries and
LoopHelpers on native Linux x86-64, with two managed workers, one thread per
process and a 4096 MiB per-process threshold. Build elapsed 77.000 seconds and
the fresh axiom audit elapsed 12.643 seconds, checking **35,005 declarations**
against the existing foundation whitelist. Exact source identities, settings,
phases and evidence are retained here.

`arraysAtom_correspondence` already requires complete `ValidMetadata`. The
repair threads that premise through the two internal scalar-array helper
lemmas and derives per-binding validity and pairwise ordering for
`readBounds_correspondence`. The array-atom endpoint and scalar-native equation
endpoints retain their statements and preconditions. The native equation proof
also uses the correct metadata projection and derives the added component-bound
field of `BindingType` directly from `ValidBinding`. No parser source, admitted
domain or trusted foundation is changed by these proof repairs.

The preceding focused run with `PredicateInheritedReady` was interrupted after
it reached the full source bridge, whose expensive source candidate belonged to
the final integration pass. Its completed independent objects were retained;
that interrupted run is not a successful audit. Two subsequent failed attempts
are retained: the first exposed the old metadata projection in
`ScalarExpressionNativeEquations`, and the next exposed its missing explicit
component-bound proof. Both were repaired before the successful run.

This focused result does not replace the complete source/Lean checkpoint.
`PredicateInheritedReady` and final source requirements remain with integration;
the complete native obligation/report/provenance audit is a separate run.
