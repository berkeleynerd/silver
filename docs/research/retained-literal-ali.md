# Literal Main ALI writer and reader interface

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [callable packet](../evidence/retained-literal-ali-20261018/README.md)
connects actual direct-literal-output source bytes to the existing native ALI
writer bound. It exports a complete Main-file buffer bound and invocation
record counts for later binder/GPR composition. It does not close those
consumers' table, graph or driver lifetimes, or the output launch descriptor.
No native execution or production change is involved.

## Source and configuration transfer

The complete literal recognizer supplies the same C/N/W interface used by the
[literal aggregate](retained-literal-pipeline.md). This wrapper additionally
requires the current ASCII alphabet, signed source/line extents and physical
columns at most 32766. No declaration, concat, Image, loop, generic or new
callee enters this family. The current source-byte/String limits are not
enforced here: this is a capacity component, not language membership or a
proof that larger literal values meet the unchanged library contracts.

The reviewed [native invocation argument](retained-native-expansion.md#native-invocation-and-elaboration-metadata)
already bounds the broader selected language by 19 target entities and 361
entity pairs. `sem_elab.adb:12165–12193,13190–13241` deduplicates constructs
and `(invoker,target)` relations before appending ALI records. The direct
literal family is a subset of that frontier. Repeated Put/Put_Line calls
therefore do not multiply the serialized relation count. The existing
97-character signature bound covers names/scopes and ten-digit Nat source
coordinates. The callable retains 19 constructs/signatures and 361 relations;
it does not claim these loose maxima are the actual counts.

Only those four source-independent ALI fields are extracted from the existing
helper. Its unused scenario/marker estimates are discarded; zero arguments
for those unrelated fields are not a zero native-lifetime assertion. Main's
variable marker/scenario allocation remains part of the separate frontend
argument. `lib-writ.adb:1637–1807` emits a bounded record for each retained
construct/relation, rather than one record per source occurrence.

The selected native configuration retains the eight A switches observed in
the literal-options packet, plus indexed `-gnateI1` and the reviewed native
`-fsplit-wide-types` addition. The resulting ten payloads contain 110 bytes
and their A records contain 140 bytes including LF. Their spelling and count
are checked, with the [split-option result](retained-split-options.md).
Source length, literal bytes and statement coordinates do not alter them.
The selected naming/map/include paths are excluded from A recording by the
existing invocation/filter argument; adding other stored options would
require repricing this interface. This is a selected-configuration premise,
not a claim that the current partial launch record materializes the complete
native command.

The [ALI serializer argument](retained-native-expansion.md#native-main-ali-serialization-and-local-objects)
prices all remaining records and writer-local objects. Its fixed selected
specification closure, 41 unit slots, restriction enumeration, empty auxiliary
tables and source-name bounds conservatively cover this narrower literal
family. The no-Xref configuration suppresses X records while retaining the
required ordinary records and the fixed initial compiler tables. All ten
serializer sources and 38 selected specifications are rechecked against the
existing inventory. The old 399-byte null ALI bound is not reused.

## Exported bound and limits

At pathname-spelling bound P=512, the existing serializer gives:

- Complete Main ALI: at most 2,152,396 bytes.
- Largest record including LF: at most 1,184 bytes.
- EOF-terminated reader object: at most 2,152,397 bytes.

The complete-file envelope deliberately overcounts unit and with records. It
is an individual ALI reader allocation, not cumulative process memory. The
native writer streams records and uses its independently checked 2,112-byte
record reservation / 2,112,000-byte buffer alternative. Consequently this
file envelope may exceed the writer buffer while every record still fits.
The EOF object fits signed Integer and LP64 pointer-difference arithmetic.
GPR/gnatbind readers still need their actual row-policy/table joins; this
packet exports their input size, not their whole-process capacity.

Eleven offline checks cover Hello, both output operations, empty/escaped
literals, an 8,192-byte literal, 5,000 calls, CR-ended comments and case,
path and physical-column boundaries, and rejected source shapes. The selected
P=976 record envelope is exactly 2,112 bytes; P=977 fails that sufficient
writer condition. This is a conservative envelope boundary, not a claim
that the tool cannot handle a 977-byte path. The initial test expectation
was corrected by one byte before freezing; no implementation formula changed.

Next, join these exported Main fields with the fixed output ALIs and actual
native GPR/binder row policies. The frontend, whole binder, other producer
phases, and complete output-launch obligations remain separate. #119 and
the whole literal pipeline remain incomplete.
