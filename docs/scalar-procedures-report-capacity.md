# Scalar procedures: producer and report capacity

Feature-local account for [#370](https://github.com/berkeleynerd/silver/issues/370),
prepared 2026-11-09. **Implementation, independent review and final validation
are pending.** The [capability record](scalar-procedures.md) distinguishes these
development arguments from delivered support. This extends the
[scalar-function account](scalar-functions-report-capacity.md) with the same
4,096-byte source limit, shared operator budget and pinned producer. It selects
a 64 MiB retained Main report allocation, without starting the deferred general
capacity work.

## Producer and initialization

The SPARK source revision remains
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Applications with local functions or
procedures use the existing `--no-inlining` route on unchanged author source.
Every declared subprogram, including an unused one, receives full analysis.
Earlier-only calls and finite loops provide the language's termination argument;
the report policy preserves exactly one implicit termination witness per
function. This producer emits no corresponding procedure termination witness.

Each admitted `out` formal instead has one successful `UNINITIALIZED` flow
record: severity `info`, `how_proved = flow`, the owning procedure entity, and
the exact source-name message `initialization of "Name" proved`. This is a
proved initialization record, not an advisory or permission to omit a safety
check. An `in out` formal does not require this output-initialization witness.

The producer basis is broader than the positive probe:

- `flow-control_flow_graph.adb:8467` iterates every analyzed formal;
  its scalar-formal route at 1506–1635 maps an out parameter to `Mode_Out`
  and constructs its initial and final vertices.
- `flow-control_flow_graph-utility.adb:905–978` marks its initial vertex
  uninitialized and supplies the exported final use. `flow_types.ads:68`
  includes `Mode_Out` among exported modes.
- `flow-analysis.adb:3240–3397` collects successful initially uninitialized
  objects in `Local_OK`, includes those exported uses in `Used`, and emits
  once per member of `Local_OK` minus `Local_NOK`. Its local-info filter at
  2760–2794 does not exclude a source out formal.

The admitted scalar fragment excludes relaxed initialization, discriminants,
tags, array-valued formals and exceptional-only execution. Its mandatory
source-written initialization prefix establishes initialization on every path.
Thus the source-derived procedure/formal inventory can require each witness
exactly once, including in unused procedures. The existing projection discards
`check_tree` in flow/proof records; initialization classification consequently
uses the preserved owner, rule, message and result fields, without examining
that discarded tree.

## Unused writable outputs

The native application run `20261110T020944-cc6817edf6a4` exposed an omitted
advisory: `"T" is set by "Sum_And_Diff" but not used after the call`. The
producer at `flow-analysis.adb:1940–1984` visits an ineffective call output,
selects its actual target and direct callee, and emits exactly that warning
with tag `INEFFECTIVE`. Access-to-subprogram calls omit the callee, but are
excluded from Silver. Writable actuals here are bare scalar names.

This message reports an unused copied-back value, not failed initialization
or an unproved safety obligation. Both auditors require its exact message
shape, a source-declared procedure callee, a valid bare target identifier,
and the existing application flow-warning provenance. The separate successful
initialization witnesses and every safety obligation remain required. The
[failed application packet](evidence/scalar-procedures-20261109/unused-output-advisory/README.md)
retains the diagnosis; the fixture is kept to exercise the repaired path.

## Input and copy-back checks

`Compute_Call_Args` in `gnat2why-expr.adb:4393–4590` translates each actual once.
The out route at 4527–4550 uses `EW_Pterm` for its scalar input conversion;
the in/in-out route at 4579–4585 transforms the input using the formal's
expected type. Integer input conversions retain the function account's
two-byte source reservation: preceding argument delimiter plus one value-token
byte. Boolean conversions remain same-base predefined Boolean conversions.

The mutable-formal route at 4733–4774 calls `Compute_Store` once per writable
actual. `Compute_Store` at 8311–8355 calls `Reconstruct_Actual_From_Item` with
`No_Checks => False`, whose Regular branch at 14944–14971 performs one checked
conversion. The selected writable actual is a bare scalar name;
it has no component reconstruction, index, slice, tag, validity or predicate
checks. The native source investigation identifies this reconstruction as the
sole checked scalar copy-back conversion. `New_Assignment` at 12368–12386
skips `Shift_Rvalue` for a bare identifier and uses an `EW_Pterm` conversion;
its Regular branch at 12432–12442 adds only the direct assignment.
`why-gen-expr.adb:1621–1657` dispatches the checked conversion once to
`Insert_Scalar_Conversion`. That helper's `Range_Check_Applied` state prevents
steps 3 (2750–2768) and 5 (2804–2823) from both emitting a range check. Its
nonmodular `Do_Range_Check` route at 2352–2389 makes one `New_VC_Call`.
Each selected writable actual therefore contributes at most one additional
range-check record; Standard.Boolean can require none.

Initialization-prefix assignments and ordinary procedure-body expressions use
the existing assignment/arithmetic reservations. The closed bodies add neither
array declarations nor array writes, so they do not increase the inherited
nested-array advisory multiplier. Safety and automatic discharge still need
their complete semantic, actual-source and native proofs.

## Conservative retained storage

Let `S = 4096`. Functions and procedures jointly consume more than 32 disjoint
source bytes per declaration, so their combined entity count is at most
`floor(S/32) = 128`. A procedure call can be as short as `P(X);`, giving at most
`floor(S/5) = 819` local calls, including the longer function-call assignments.
The earlier entity, coverage, claim-header and timing allowances therefore
remain sufficient for both kinds together. The dependency allowance grows from
512 to 819 calls. It still charges three deduplicated Effects/AoRTE tokens per
call edge, without any author postcondition.

Each writable actual consumes its own preceding `(` or `,` and at least one
identifier byte. Independently allow `floor(S/2) = 2048` copy-back records at
2048 bytes each. Each explicit-mode formal, including its preceding `(` or
`;`, consumes at least seven disjoint bytes (`(X:in T`); an `out` formal is
longer. Allow `floor(S/7) = 585` initialization records at 1024 bytes each, plus
`2*S` bytes for their source-name payloads. This deliberately overcounts
non-output formals and does not rely on fitting initialization into an older
flow-record allowance. The record schema allowances are inherited from the
[retained-data account](report-capacity.md#retained-data-envelope), and the
capacity tests serialize these record shapes.

Separately reserve one unused-output advisory per writable actual, at most
`S/2 = 2048`, each with 1024 schema bytes. Target-name payloads are bounded
by their disjoint actual spellings, totaling at most `S`. Deliberately allow
a full `S` bytes of callee name in every message, even though that spelling
also consumes the source budget. This adds `2048*1024 + S*(2048+1)` bytes;
it does not depend on fitting these diagnostics into an older flow allowance.
The producer's ordinary source-message deduplication prevents repeated runtime
loop iterations or repeated visits to the same call/output from multiplying
this source-site count.

```text
previous function envelope                       33,149,440
additional dependency tokens: (819-512)*3*256         235,776
copy-back records:             2048*2048           4,194,304
output initialization:         585*1024              599,040
output-name payload:           2*4096                  8,192
previous procedure envelope                      38,186,752
unused-output records:          2048*1024           2,097,152
unused-output name payload:     4096*(2048+1)       8,392,704
combined envelope                                48,676,608
selected allocation:           64*1024*1024       67,108,864
headroom                                         18,432,256
```

The shared file-reader bound must cover the same retained report domain.
Runtime and null reports retain their 262,144-byte domains. This is a storage
argument under the pinned producer premises, not a solver-time, stack or peak
memory promise. The complete original reports remain retained; only the
already unaudited proof-tree metadata is omitted by the streaming projection.

## Inspected sources and corroboration

| SPARK source | SHA-256 |
| --- | --- |
| `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `src/why/why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `src/flow/flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| `src/flow/flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |
| `src/flow/flow-control_flow_graph-utility.adb` | `a1a7024b4b54a05995e3be0fe4312a7a144da006ab0a07a703ceb705be158c29` |
| `src/flow/flow_types.ads` | `93e58772bb49cf2a71152a3e67b6a301a8c490600889d29b05d0eadd4b15cded` |

The selected native mechanism probe `20261109T231302-69a3623a0c2e` passed
75 checks. Its mixed functions/procedures report has six successful output
initialization records and one function termination record. Negative probes
for narrower copy-back and an unsafe unused body failed as intended. The
[producer packet](evidence/scalar-procedures-20261109/native-probes/README.md)
retains their source and reports. These mechanism probes preceded the finished
compiler and do not establish compiler admission or feature completion.

The native investigation selected GPT-6 Astra / Max. The lead prepared this
account from its source inspection and the existing capacity records. Live
runtime settings are not independently exposed. Independent capacity review,
record-size/boundary regressions and complete feature validation remain pending.
