# Declaration-order preservation

Focused Linux run `20261127T135419-adde86061026` passed
`Silver.ApplicationPackageFrameHistory` and a fresh 23,784-declaration axiom
audit, two workers/two threads, 8,192 MiB per-process threshold, normal Lake
reuse under the eight-CPU host allocation. It derives the layout row-validity
requirements from bounded strictly ordered source positions, preserves that
order under compaction, and preserves it when appending a later declaration.
The source decoder still needs to connect each actual declaration step to these
construction facts; no arbitrary-frame ordering assumption is added to native
helpers or the final language claim. This check is partial development evidence.
