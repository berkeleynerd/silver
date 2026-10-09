# Named string constants

The owner authorized this increment on 2026-10-09 after the review-repair
baseline, committed as `251dd85`. It adds one literal-initialized `constant
String` and one matching identifier argument to `Silver_IO.Put_Line`.
[samples/string_constant.adb](../samples/string_constant.adb) motivates the
capability. The complete rules are in [language.md](../language.md), with
`named_string_constant` and `named_output` catalogue identifiers.

## Scope and reasoning

Identifier matching is case-insensitive, with Ada ASCII identifier syntax,
reserved-word exclusions and the two visible-name exclusions `String` and
`Silver_IO`. `Main` remains a legal local constant name. There is no extra
name-length cap beyond the 4096-byte complete source limit. The existing null
and direct literal-output forms remain admitted. Reassignment, concatenation,
indexing and general declarations remain excluded.

The independent SPARK ghost grammar and executable scanner share checked
lexical helpers. The named production carries a bounded declaration span and
checks its sole reference against that span. Lean separately covers identifiers,
name binding, literal initialization, source meaning and the permitted
composition, with actual-source interpretation and source-shape checks.
The [assurance argument](assurance.md#named-constants-and-their-composition)
distinguishes modeled empty application obligations, reviewed Ada semantics and
actual GNATprove reports. Runtime implementation and external assumptions are
unchanged from the repair baseline.

The catalogue exporter is split into small procedures for constructs,
compositions, rules and token tables. The original exporter emitted a large
single proof input; the isolated split proved all its checks and exported
exactly the same bytes before extending metadata. This is a local decomposition,
not a new serializer framework. Parsed JSON parity remains the catalogue check.

## Validation

The full Linux compiler audit passed 1,577 checks (281 flow and 1,296 proof),
covering all 15 units and 145 entities. All 14 imported declarations and 22
recognized limitation notes were accounted for; there were no unproved,
justified or suppressed obligations. The run used four workers, forced unit
analysis and the native solver cache in a fresh `named-final` report directory.
It is a full audit, not an uncached performance claim. All 2,372 recorded inputs
were rehashed after completion. Its manifest is
`.silver/linux-aarch64/compiler/obj/named-final/gnatprove/proof-provenance.json`,
SHA256 `a1fe8685786b956fdedd72366322ccb59526f255601a2e10c4c8f43076796f87`.
The native build and catalogue/export JSON parity passed.

The 118-test full run completed in 88.539 seconds. All native admission,
proof/build/run and integration tests passed; the certificate-parity test found
two stale candidates because it ran before regeneration completed. After those
candidates were refreshed, all six source-policy tests passed, including the
seven-file regeneration comparison. The catalogue's reserved-word restriction was then clarified as an explicit
Boolean condition; the final full audit, native rebuild and catalogue comparison
all passed on that final source. Logs are `.silver/linux-aarch64/named-proof-full.log`,
`named-tests.log`, `named-source-tests.log`, `named-proof-isolated-final.log`,
`named-build-final.log` and `named-catalogue-final.log` under that host. A stable
copy of the completed compiler manifest is in `named-final-evidence/`.

An intervening audit in the existing `named-strings` directory hit GNATprove's
known JSON-reader failure: `DOC_END` in `silver_profile.adb` and `coma or }
expected` in `silver_library_reports.adb`. The failed log
`named-proof-final.log` and directory are retained. The successful final audit
used a separate analysis directory and retained the solver cache; it does not
establish that warm-state replay is repaired. No automatic retry or proof-policy
change was added.

Boundary cases cover empty and escaped literals, legal `Main` names,
case-insensitive references, 4,096-byte sources, long identifiers at the source boundary and nearby
rejected declarations. Native Main reports remain empty. An independent review
compared the 74 Ada 2022 reserved words with the compiler/Lean exclusions and
checked identifier scans, span bounds, binding and recursive equations. No
blocking mismatch was found. Samples and tests do not establish the universal
guarantee; the proofs and reviewed correspondence supply it.

The final canonical Lean full replay and independent fresh kernel recheck passed.
The fresh axiom audit checked all 40 project modules and 11,480 declarations,
using only `propext`, `Classical.choice` and `Quot.sound`. All 66 captured inputs,
tool hashes and log hash matched afterward. The successful full invocation took
375.348 seconds, reusing source-certificate objects from the preceding run.
That run finished certificate generation but failed on two adjacent Lean doc
comments; merging the comments fixed the syntax without changing a proof claim.
Its log is retained as `named-lean-syntax-failure.log`. The final full check still
ran the fresh axiom audit and independent kernel replay.

Stable final evidence and logs are in
`.silver/linux-aarch64/named-final-evidence/`. Its `lean-evidence.json` SHA256 is
`5db924786770faea1f5da3531ccc9179e427112b7f6c3e6fb679e360ab985d16`. Final actual-source, equation-closure and semantic reviews found no
blocking mismatch. The final named-output test module also passed all three
tests, including a 1,992-character identifier in a compact 4,096-byte source;
its log is `named-tests-final.log`. The feature is complete on Linux. macOS remains independent and nonblocking; no hosted CI or
x86-64 execution is claimed. The Oracle is unchanged.
