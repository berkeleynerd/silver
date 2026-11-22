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

These are partial semantic checks. Original-unit parser correspondence, the full
Main application adapter, integrated native/Lean assurance and independent review
remain required before a package capability claim. The formal models' structural
representation premises are not extra application-author assurance facts; the
source integration must derive them. Prior failed elaboration attempts remain in
the managed ledger and preserved task scratch; these successful runs supersede
them only for their actual checked inputs.

Selected proof work setting was Astra Max under the task briefing. Live model and
effort telemetry were not exposed. No CLI memory update is claimed.
