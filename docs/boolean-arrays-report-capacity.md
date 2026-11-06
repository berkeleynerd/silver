# Boolean arrays: producer and report capacity

Draft feature-local account for [#297](https://github.com/berkeleynerd/silver/issues/297),
2026-11-06. The native subthread inspected the pinned producer routes below.
The [independent capacity review](reviews/review-boolean-arrays-capacity-20261106.md)
found no blocking finding; discovery probes and complete feature assurance
remain pending. This account extends the
[String/Character envelope](bounded-string-characters-report-capacity.md) and
[Boolean scalar account](evidence/boolean-objects-20261030/producer-review.md).
It does not change report policy, allocation or the existing producer assumptions.

## Selected routes

The SPARK source revision remains
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`; the Why3 source revision is
`9390baf120ef260547dfa14f08e11c890b203d9c`. The selected upstream files were
retrieved at these exact revisions and their nine hashes match the retained
source records. This is source inspection under the existing toolchain
assumptions, with no new binary-attestation claim.

`gnat2why-expr.adb:14042–14089` translates a one-dimensional indexed read and
inserts its index check. The indexed assignment route at `14287–14349` similarly
checks the subscript and stores its Boolean RHS. Both prefixes name initialized
arrays with static bounds; there is no whole-array logical operation or nested
array-valued prefix. Aggregate routes at `15743–15843` and `17463–17522`
translate each explicitly supplied component once.

A Boolean array *component* has the predefined scalar Boolean type. Its `not`,
eager and xor operations therefore take the scalar branches at
`gnat2why-expr.adb:24501–24626`, like scalar Boolean objects. Whole-array logical
branches remain outside this fragment. The existing restriction excluding xor
inside either xor operand still applies. `why-gen-expr.adb:5391–5424` can copy an
operand AST, including its component index-check task. The existing check-identity
grouping at `gnat_checks.ml:175–224` and report emission at
`gnat_report.ml:33,59–85` emit one retained record per registered check; these
copies do not create a new retained-record multiplier. Their proof tasks must
still all succeed.

The anonymous Boolean arrays meet none of the additional type-VC or entity
coverage triggers in `gnat2why-types.adb:1108–1141` and
`spark_definition.adb:2313–2389`. They introduce no additional library call.
Their indexed loop writes follow the existing potentially-defined-cell and
recursive loop-analysis routes at `flow-control_flow_graph.adb:4015–4032` and
`4040–4117`. The existing exact initialization advisory withholds a fact; it
does not discharge or replace an obligation.

## Combined reservation

The Integer-array account's statement that component expressions contain no
comparisons must be qualified for this feature: Boolean component initializers
can contain comparisons. Their reservation is nevertheless disjoint.
`why-gen-expr.adb:2425–2439` returns a same-base Standard.Boolean conversion
unchanged, even when a range-check flag is present. There is consequently no
Boolean component-conversion safety check needing the Integer component's byte
reservation. Embedded comparisons reserve their own source bytes under the
existing comparison rule. For nested Boolean equality, reserve the two operator
bytes when available, or the single operator byte plus one token byte from the
leftmost leaf of its right operand subtree. Distinct comparison nodes use
distinct such leaf positions. Integer components still contain no comparisons
and retain their existing component-conversion allowance.

Indexed reads have their own paired parentheses for their index check; slices,
declaration/assignment roots and arithmetic operators retain their respective
disjoint reservations. A Boolean component declaration or indexed write is no
shorter than the existing descriptor and eight-byte indexed-write allowances.
All arrays share the same finite tables, and Boolean arrays add no element-loop
syntax. The inherited bound on nested-loop initialization notes is unchanged.

With the unchanged complete-source and expression budgets, the combined
envelope remains:

```text
S = 4096
checks = floor(S/2) + 3*63 + floor(S/7) + 3*floor(S/15) + floor(S/2)
       = 5689
Main = checks*2048 + (2*S + 2*floor(S/16))*1024 + 2*S + 65536
       + floor(S*S / (4*24*8))*512
     = 31,822,336 bytes < 33,554,432 bytes
```

This bound concerns retained report storage. It does not assert a maximum solver
time or a measured peak memory consumption. Report acceptance still requires
every emitted obligation to be proved with the existing provenance requirements.
Discovery reports will corroborate the selected routes; examples do not replace
the feature's universal and actual-source assurance.

## Inputs

| Source | SHA-256 |
| --- | --- |
| SPARK `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| SPARK `src/why/why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| SPARK `src/flow/flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| SPARK `src/flow/flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| SPARK `src/why/gnat2why-types.adb` | `3b4b21d00eb4d14a4f7966c097f215217ea54183be4048a5d9bbd98ccdb3663d` |
| SPARK `src/spark/spark_definition.adb` | `d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e` |
| SPARK `src/why/gnat2why-driver.adb` | `b3a37440a935dd9e4c8840c41807b0894a4ad710c63ceb9d344a3db804ebe304` |
| Why3 `src/gnat/gnat_checks.ml` | `c1953284dba6e8514fdcd87b04cefffa9f61882950356c6e28db155dd13adfb1` |
| Why3 `src/gnat/gnat_report.ml` | `05f1b53ec047dfb80b80419d3f29ac88669a16bbeefe0e8ddd49ae7a1369ed01` |

Selected native source-investigation setting: GPT-6.1 Sol / Extra High. The
integration lead prepared this account from that bounded investigation.
Independent review selected GPT-6 Astra / Extra High and took 293 seconds,
including its report. Runtime setting confirmation and token/cost measurements
are unavailable. Its exact input inventory and independent arithmetic are
retained with the linked review; native producer corroboration remains pending.
