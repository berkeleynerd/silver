# Complete original package effect and library assurance

Refs #416. `ApplicationPackageOriginalAssurance.routine_effects` combines the
original constant/local/output initializer reads, complete recursive body
effects, incoming mask retention, result reads and exact footer storage. The
inferred effect set is included in the native summary at its original routine
identity. `entries_effects` and `package_effects` derive that result for every
original completion, including unused routines.

`package_library` derives the summary-library checker, semantic environment
typing, all-routine safety and complete library obligation discharge. Source
inventories contain no semantic checker, effect-inclusion or safety premise.
The only effect interpretation inputs are literal primitive equations on their
full native source/lookup/cursor domains. The schema validity and routine/frame
domains follow from original native histories and final metadata validation.

Focused Linux validation of `Silver.ApplicationPackageOriginalAssurance`
passed with a fresh 92,147-declaration transitive axiom audit. The managed runner
used CPUs 0–1, automatic two workers and two threads per process, and 8192 MiB
per process. All captured source inputs were rehashed with none missing or
changed. The index and evidence retain exact inputs. The first draft required
only explicit normalization of the unchanged body context for a Boolean table
bound; no domain, native source, source pin or budget changed.

This checked increment depends on the effects stream through `4a1f575243`
(with `1edec3798e` and `72f5e04e40`). Those prerequisite files are synchronized
baseline only and are not part of this commit. Original Main runtime stores,
the final original Analyze/application endpoint and complete validation remain
separate requirements. No authoritative-source or native build was launched.
