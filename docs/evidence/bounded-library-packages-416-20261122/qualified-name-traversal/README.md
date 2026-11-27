# Qualified scalar name traversal

Focused Linux x86-64 run `20261127T133207-49bdbc90f339` passed ProcedureNameQualified,
ProcedureNameScalarReadings and ProcedureNameArrayReadings with a fresh audit
of 11,942 declarations. It used two workers and two threads per process,
an 8,192 MiB internal Lean threshold, and the host's shared eight-CPU allocation.
The existing matching Lake objects were reused; no kernel replay was selected.

The scanner traverses both bare and qualified references. The existing
Input_Is_Valid selector shortcut ends at the same member identifier, proved
by source identifier uniqueness. Qualified references cannot alias a bare
lookup slot. The existing full scalar and array expression traversal theorems
retain their statements, masks, arbitrary metadata and all grammar cases.

The implementation moves the terminal module's dependency from complete scalar
readings to the underlying grammar and scanner, and gives affected consumers
explicit imports. This permits the scalar reading proof to use qualified-token
traversal without an import cycle; its fixed-symbol theorem keeps its statement.

Failed focused attempts are retained: missing explicit imports, source-position
and record-projection normalization, simplification of a nested selector guard,
and deprecated rewrite names. No native source, membership rule or proof-domain
restriction changed. Boolean/condition traversal and the complete application
endpoint are separate remaining checks. Proof work follows the selected Astra
Max policy; live model/effort telemetry was not independently available.
