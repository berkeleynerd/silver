# Named Integer subtype stack observations

Linux observations for [#286](https://github.com/berkeleynerd/silver/issues/286),
2026-10-29. Three concrete 4,096-byte inputs completed admission, proof, native
compilation and execution with an 8,192 KiB stack limit on each phase. The source
implementation is `a0d1a69463`; the measured binary was rebuilt in the regression
workspace at `39d96fa9e5`. This is bounded experimental evidence, not a universal
stack, nesting-depth or runtime bound, and not complete feature assurance.

| Fixture | Nesting | Managed run | Managed duration |
| --- | ---: | --- | ---: |
| [Singleton constant-array foreach](foreach-singleton.adb) | 158 | `20261029T145414-d47d27d98ec3` | 40.046 s |
| [Counted loops](counted.adb) | 141 | `20261029T145147-a08224bc1901` | 50.415 s |
| [Conditionals](conditional.adb) | 208 | `20261029T145241-692b2df52550` | 39.661 s |

The foreach array uses the admitted singleton aggregate `(0 => 0)` with index
range `0 .. 0`, so each loop executes once. Counted loops also execute once;
all conditional guards are true. Each generated `main.adb` was compared byte
for byte with its retained fixture. Each complete producer report records 66
discharged checks: 19 by flow analysis and 47 proof records, with no unproved
records or warnings. The generated native ALI options retain `-gnatdM`.

The unchanged [observation harness](../../array-review-response-20261028/stack/observe.py)
sets and prints the stack limit, pins child execution to CPUs `0,1`, and records
the actual commands and exits. Each managed observation reserved two workers;
production prover options, including the driver's `-j0`, were unchanged. The
reservation and CPU affinity do not claim a measured count of internal prover
processes. [Summary](summary.json), [fixture identities](fixtures.json), per-phase
logs and [compressed report identities](retained.json) preserve the exact inputs,
binary hashes, timing, generated workspace locations and native options.

## Retained unsuccessful observations

The original [two-element foreach fixture](foreach.adb), also 158 levels and
4,096 bytes, passed admission and compilation under the same stack limit in
`20261029T144933-25b55aa85c06`. Its null-body execution requires `2^158` iterations.
The generated executable was stopped with SIGTERM after 81.356 seconds when that
probe-design problem was recognized. Its managed run remains failed, its execution
is recorded as `-15`, and no runtime completion is claimed. The successful
singleton fixture is a separate input; the original successful compile was not
repeated.

Run `20261029T144841-86003a7117b0` failed during input preflight because fixture
copying initially used the wrong working directory. No harness or compiler was
invoked in that attempt. Correct absolute paths were used thereafter.

Earlier [initial](exploratory-initial.json) and [repaired](exploratory-repaired.json)
admission logs retain the development observation that the two-element foreach
case initially raised `STORAGE_ERROR` and was accepted after replacing a full
scalar-table loop temporary with in-place context extension. Those exploratory
JSON files lack complete binary and resource metadata; they are diagnostic
history. The complete observations above establish the measured final behavior.

Selected worker: GPT-6 Astra / Extra High, inherited from the assigned native
subthread. Runtime model confirmation and token/cost measurements are unavailable.
The managed durations above include orchestration; per-phase measurements are
retained separately. No additional model-quality or cost claim is inferred.
