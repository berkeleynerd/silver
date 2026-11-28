# Original local initializer effect coverage

Focused Linux x86-64 validation for issue #416. The managed target is
`Silver.ApplicationPackageLocalInitializerEffects`; its complete imported
declaration audit passed with 84,584 declarations and only the documented Lean
foundations (`propext`, `Classical.choice`, `Quot.sound`). The runner used the
CPU 0–1 affinity, two automatic Lake workers, two automatic Lean threads and
8,192 MiB per Lean process. Every captured source input was checked against the
retained run before this packet was created.

`object_visible` derives that every package global visible in an original local
initializer remains visible in the native post-declaration effect scan. It uses
the original successful `Object_At` storage and hiding behavior, including bare
Integer/Boolean lookup, cross-kind hiding, original declaration spans and the
body environment's preserved name fields. `object_read_masks` transports the
complete read mask across that scope change. `local_value_reads` connects each
original Integer or Boolean initializer tree to the resulting native mask while
retaining its original preappend layout. `local_history_masks` and
`local_values_reads` preserve the incoming mask and every initializer read across
the original declaration-order history.

This is focused helper validation, not complete package or language assurance.
Routine-level initializer/body/result aggregation, the original application
endpoint and complete applicable native/Lean/source validation remain required.
No native source, domain, proof budget or assurance premise was weakened.
