# Package semantic safety evidence — 2026-11-22

These retained focused Linux x86-64 runs check the complete declared domains of
package call/checker, scalar body, routine initialization/result and library-fold
helpers. Each build passed and its imported declarations received a fresh axiom
audit using only `propext`, `Classical.choice` and `Quot.sound`. Every run used two
Lake workers and two Lean threads per process while sharing the eight-CPU host;
the managed events retain allocation, task and source-input fingerprints.

The [index](index.json) ties each run to its implementation commit, targets,
input digest and original artifact hashes. Each phase contains original evidence
JSON, losslessly compressed build/audit output and managed events. This packet
changes no compiler or proof input and did not rerun successful targets.

The body result covers every scalar branch and counted loop. Routine safety
composes full-domain global/input entry, per-phase local/output initialization,
body safety and declared result checking. `entry_refines` proves initialization
ranges refine declaration domains; the native frame/source bridge must identify
the deterministic declared-domain view with its actual metadata. The library
fold checks every completion-order routine, including unused definitions, derives
all callee typing and effect locality, and discharges all routine obligations.

These are partial semantic checks. Original-unit parser correspondence, native-to-Main adapter construction,
integrated native/Lean assurance and independent review
remain required before a package capability claim. The formal models' structural
representation premises are not extra application-author assurance facts; the
source integration must derive them. Prior failed elaboration attempts remain in
the managed ledger and preserved task scratch; these successful runs supersede
them only for their actual checked inputs.

Selected proof work setting was Astra Max under the task briefing. Live model and
effort telemetry were not exposed. No CLI memory update is claimed.

## Full Main semantic composition — 16:36 UTC

Three later focused runs add combined Main-local/package callable interfaces,
exact original/projected identity round trips (including repeated signatures),
and persistent-state execution of the full existing Predicate statement tree.
The existing checker and obligation schemas are retained for all strings,
arrays, input, local calls, branches and counted/array loops. Checked recursive
execution preserves the complete global schema through every package procedure.
`checked_application_sound` derives package callee typing from the checked
completion-order library, initializes the declared global values and combines
all routine and Main obligations. Invalid input still requires rejection and
forbids output when the original completion check accepts it.

The final semantic target is `Silver.ApplicationAssurance` at `b7a8dc66c8`.
It is not an original-Bundle endpoint: actual-source readers must construct the
resolved tree and derive all structural metadata, readability, alias/layout,
local-library and checker facts. No parser-model correspondence is assumed or
claimed by these focused runs. Source and native checks remain open.
