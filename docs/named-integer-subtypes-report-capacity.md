# Named Integer subtypes: producer and report capacity

Feature-local source account for [#286](https://github.com/berkeleynerd/silver/issues/286),
2026-10-29. This extends the [constant-array iteration account](constant-array-iteration-report-capacity.md)
for static direct-Integer named subtypes, scalar objects with optional narrower
static constraints, and existing fixed arrays with named component subtypes.
It retains 4,096 source bytes, 63 operators, 64 expression leaves and the 32 MiB
Main report allocation. Complete native/Lean/source assurance remains separate.

## Selected producer routes

The producer/frontend revisions and assumptions remain the
[fixed-array account's](fixed-integer-arrays-report-capacity.md#inputs-and-source-routes):
SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` and GCC frontend
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The following retained inputs were
read and their hashes rechecked for this change:

| Input | SHA-256 |
| --- | --- |
| `gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `gnat2why-types.adb` | `3b4b21d00eb4d14a4f7966c097f215217ea54183be4048a5d9bbd98ccdb3663d` |
| `spark_definition.adb` | `d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e` |
| `gnat2why-driver.adb` | `b3a37440a935dd9e4c8840c41807b0894a4ad710c63ceb9d344a3db804ebe304` |
| frontend `sem_ch3.adb` | `198190171bcd99d293c3ec86a2ffe4ffb4a29276bfd205ebc4b9f0aea87d263f` |

`gnat2why-expr.adb:22843–22888` handles explicit subtype declarations and the
existing generated object subtypes together. Its scalar branch requests range
checks only when the parent or subtype range is nonstatic. Each admitted named
subtype has visible parent Integer and nonempty static bounds contained in
Integer. A local object constraint similarly has static bounds contained in its
static named parent. The earlier constant-staticness rule remains essential:
a snapshot from a mutable object or indexed component cannot be a static bound.
The fallback `Check_Scalar_Range` at 3707–3731 also returns no check for a valid
static range contained in its static parent. Naming these ranges adds no
constraint-root record and does not duplicate initializer evaluation.

The named component mark in `array (...) of S` is an identifier, not an inline
component subtype indication; the additional inline-constraint branch at
22890–22924 is not entered. Existing scalar conversions remain at initializer,
aggregate-component and assignment roots. Their narrower target ranges affect
the proof goals, not the number of conversion sites. The fixed-array account's
root/component charges already include them. Arithmetic still uses Integer's
base operations; a named subtype introduces no conversion syntax, predicate,
new arithmetic operation or author proof annotation. Body array reads and
constant-array element renamings use their declared component subtype.

The retained type-VC gates at `gnat2why-types.adb:1108–1141` have no applicable
trigger: no private/default, access-subprogram, general iterable, nonstandard
equality, aggregate annotation or ownership feature is admitted. Named scalar
subtypes add no type proof entity. The existing coverage and timing gates at
`spark_definition.adb:2313–2389` and `gnat2why-driver.adb:507–611` therefore retain
the same metadata ceilings. The [bounded-mutable account's](bounded-mutable-report-capacity.md#metadata-flow-and-image-closure)
flow/name payload and Integer Image arguments apply unchanged. Subtype
declarations initialize no object, add no call advisory and introduce no
indexed assignment or extra loop traversal.

## Combined source charge

`A:S:=0;` occupies seven bytes, so the previous independent scalar-declaration
allowance `floor(S/13)` must become `floor(S/7)`. Retain every other conservative
allowance from the constant-array account, including its joint root/component
bucket, element-reference bucket and nested indexed-write notes:

```text
checks = floor(S/2) + 3*63 + floor(S/7) + 3*floor(S/15) + floor(S/2)
Main = checks*2048 + (2*S + 2*floor(S/16))*1024 + 2*S + 65536
       + floor(S*S / (4*24*8))*512

S = 4096: checks = 5,689
Main = 31,822,336 bytes
33,554,432 - 31,822,336 = 1,732,096 bytes of headroom
```

No report buffer or accepted diagnostic class changes. A shortest two-component
array declaration `A:array(0..1)of S:=(0,0);` takes 25 bytes, preserving the
implementation's conservative `/24` array-binding bound. Each subtype declaration
needs at least 32 bytes (`subtype S is Integer range 0..0;`), so a separate
`/32` metadata table suffices. Scalar objects and scoped binders share the
expanded `/7` scalar table. Those storage counts are source-derived capacities,
not additional language limits.

## Producer corroboration

Managed Linux run `20261029T133036-8e07960e3970`, two workers, used production
`--no-loop-unrolling` on direct static subtype declarations, a constant of a
named subtype supplying a later bound, a narrower object constraint, dynamic
snapshots, named array components, indexed assignments and constant-array
iteration. The retained ordinary Ada/SPARK probe deliberately omits the Silver
library context: it isolates the frontend/producer constructs and is not a
Silver application delivery test.

It discharged two existing `VC_RANGE_CHECK` records (accumulator assignment and
assignment into a narrower scalar object), with one Main entity and no flow or
warning records. The other checks were eliminated by the producer. The
[probe sources, logs and reports](evidence/named-integer-subtypes-20261029/producer/files.json)
retain compressed and original hashes. This observation corroborates the
source-selected routes; it is not universal assurance or a new binary-attestation
claim.

Selected native worker: GPT-6 Astra / Extra High, confirmed by the lead's spawn
configuration. Runtime model confirmation and token/cost measurements are
unavailable. The first native implementation and stack measurement are separate
from this producer run; final complete verification remains outstanding.
