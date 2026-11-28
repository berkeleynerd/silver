# Original routine entry scope — 2026-11-27

Focused ApplicationPackageRoutineEntryScope passed and freshly audited 38,983
imported declarations on Linux x86-64. Exact captured inputs and run evidence
are retained here. Two workers, two threads and 8192 MiB per process used guest
CPUs 0–1 under the shared eight-CPU ceiling. Selected proof role: GPT-6 Astra
Max. Live model/effort and whole-agent token/cost measurements are unavailable.

CompletionFrames.bodySource is the original completion's context, Body_Of
input, metadata and empty standalone-call tables. body_closed derives the
scalar-only, argument-free pure scope through Routine_Frame, every local
declaration and both output passes. states_before_body derives the original
state declaration cursor bound through the same history. body_initial_ranges
and body_hidden derive exact native initial scalar ranges and hidden-global
ranges directly from Body_Of/Context_Of; they require no successful checker.
body_scope combines those facts with the source-derived formal modes, earlier
function effects, state declarations and scalar fields already established.

The recursive PackageScope induction invariant now retains precisely nonempty
declared state bounds, replacing a full intermediate metadata-validity field
whose only consumer required those bounds. state_bounds_from_final derives
them from final complete metadata and the unchanged original state table.
The language, native domains and safety/discharge obligations are unchanged.

The first draft failed on a reserved local variable name and two missing
imports. After those repairs, the complete focused contract and all recursive
consumers passed. Native metadata subtype closure is a separately checked
concurrent increment; this packet predates its integration. Source constant/
input seeds, full phased routine construction, source effect correspondence,
final source/application endpoint and complete assurance remain outstanding.
