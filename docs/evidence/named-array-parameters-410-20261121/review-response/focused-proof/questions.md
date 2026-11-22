# Questions for the lead — focused proof review of PR #412 (target `5a4b0ad8ac`)

Updated 2026-11-22T11:41Z.

## Open questions

None. No finding depends on an owner or lead decision, and no question was left
unresolved that needs a second opinion.

## Proposed focused proof experiments

None. No candidate required a Lean, GNATprove, compiler or probe run to decide.
Every candidate was decided by reading the target sources, the retained complete
reports, or the retained pinned producer sources.

## One optional retention request (not blocking, no dependency)

Two capacity conclusions in `report.md` finding I4 rest on observed output of the
pinned producer rather than on its source. `flow-analysis-antialiasing.adb` and
the file defining `Use_Predefined_Equality_For_Type` and
`Needs_Default_Checks_At_Decl`, at SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, are not among the retained producer
files on this host. If the lead wants those conclusions to rest on source as the
other routes do, retain the two files next to the existing ones under
`tmp/scalar-procedures-native-370/tmp/procedure-probes/producer/` and record
their SHA-256 values in `docs/named-array-parameters-report-capacity.md`.
Nothing else in the review waits on this, and neither route can change the
64 MiB conclusion.
