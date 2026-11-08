# Native-repair semantic closure: passed

The Linux focused run on proof snapshot `f630819154` passed at 09:13:32 UTC on
2026-11-08: actual exit 0 and managed success after 98.938 s. The build took
50.621 s and its fresh audit 13.123 s, with four Lake workers and four Lean
threads per process. The native parser bytes remain
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`.

Targets `Silver.PredicateFunctionCallHelpers` and
`Silver.FunctionDeclarationImports` establish the new rejection guards'
equivalence with unchanged semantic models, including unconditional zero-input
lemmas and recursive/import interpretation. The fresh audit covered all 100
expected modules and 16,853 declarations, with only `propext`,
`Classical.choice` and `Quot.sound`. No clean build or independent replay ran.

This is partial model validation. It does not complete the actual-source
closure, whole-project audit or native obligation/provenance audit.
The preceding failed attempt remains in [090716](../20261108T090716-23e8e3641bc7/).
[index.json](index.json) identifies all four retained artifacts; each was
independently decompressed and checked against its length, hash and original
bytes. The read-only observer ended normally, with no process signal.
