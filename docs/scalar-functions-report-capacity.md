# Scalar functions: producer and report capacity

Feature-local account for [#298](https://github.com/berkeleynerd/silver/issues/298),
2026-11-07. The
[bounded capacity/policy review](reviews/review-scalar-function-capacity-20261107.md)
found no material finding at `9469d5632b`; the later
[delivery record](scalar-functions.md#delivery-assurance-and-validation) retains
complete native/Lean validation and final review status. This extends the
[Boolean-array envelope](boolean-arrays-report-capacity.md)
without changing the 4,096-byte source limit or its then-selected 32 MiB Main
report allocation. The current combined language uses the procedure account's
64 MiB allocation; the #391 update below adds the previously omitted function
advisory without narrowing admission.
It records inspected producer routes under the existing trusted-tool premises,
not a proof of the producer or a substitute for final delivery acceptance.

## Selected producer routes

The SPARK revision remains `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
Function-bearing applications add `--no-inlining` to the existing proof recipe;
other applications retain their recipe. Source is unchanged. Each function body
is analyzed over its declared formal domains, including unused functions.
No author contract, recursive call, default parameter, dynamic formal subtype,
tagged/access type or effectful function is admitted.

`gnat2why-expr.adb:4579–4585` transforms each scalar actual once with the formal's
expected type. The surrounding formal iteration at 4818/4877 adds no contextual
body expansion. `Transform_Simple_Return_Expression` at 29243–29270 transforms
the terminal result once with its return type. These use the existing scalar
conversion/range schemas. The assignment receiving a call retains its own
destination conversion. The selected scalar types and nonrecursive call shape
exclude the validity, tag, invariant and recursive-variant branches.

`flow-analysis.adb:6442–6725` checks termination from the control-flow graph and
callees. Its successful branch at 6712–6722 emits one exact
`SUBPROGRAM_TERMINATION` info record per function. Finite counted loops and
earlier-only calls supply the language's termination argument; accepting this
record never replaces that argument or any safety obligation.

`gnat2why-assumptions.adb:48–69` uses hashed sets/maps; `Include` at 110 and
`Union` at 133–136 deduplicate dependency tokens per caller claim. Lines 142–156
add at most three tokens per distinct local caller/callee edge: one Effects
dependency for the Effects claim, and Effects/AoRTE for the AoRTE claim. The
Post route requires an explicit postcondition, which this fragment excludes.
The selected runtime's existing claims remain covered by its retained account.

`assumptions.adb:93–111` serializes predicate names and numeric entity IDs;
`assumption_types.adb:266–299` interns each entity and emits its name once.
Proof records and timing-map keys also use numeric IDs. A local function's
source name appears in its entity record and termination text, not in every
safety or dependency record. The selected native probe confirms that layout
but does not replace the source inspection.

## Shared check-site accounting

Keep the existing two-byte reservation for assignment/declaration roots,
comparisons, aggregate conversions, indexed components and slices. Add:

- An Integer actual conversion reserves its preceding call `(` or `,`, plus
  one byte of its leftmost value token. Integer actuals contain no comparisons;
  indexed reads reserve their own inner parentheses, leaving that token byte
  available. Other actuals have distinct delimiters and token occurrences.
- A terminal return conversion reserves two bytes of its `return` keyword.
- A call-result assignment keeps its ordinary `:=` reservation, separate from
  every actual and return.

Boolean actual/result conversion stays within the predefined same-base Boolean
case and adds no range obligation. Embedded arithmetic and expressions retain
their existing checks and shared operator budget. Thus these new sites remain
inside the existing `floor(S/2)` union; no additional independent safety-check
maximum is added. Function bodies exclude arrays, and their counted loops
introduce no shorter syntax or new nested-array advisory multiplier.

## Additional entity metadata

Let `S = 4096`, `F <= floor(S/32) = 128` be the number of local functions,
and `C <= floor(S/8) = 512` the number of local call assignments. Complete
function syntax consumes more than 32 disjoint bytes, and even `R:=F(0);`
consumes eight; longer identifiers, types, actuals and whitespace only reduce
these counts. These independent ceilings deliberately overcount their joint
source use.

The [existing metadata account](report-capacity.md) bounds numeric spelling,
indentation and the selected timing-key closure. Its 32 timing keys at 160 bytes
per owned entity remain applicable with the same prover/counterexample drivers.
Repeated phases aggregate in maps. Allow this additional storage:

| Per-function or per-call item | Bytes reserved |
| --- | ---: |
| Termination record, excluding source-name payload | `1024 * F` |
| Entity entry and complete-coverage entry, excluding source-name payload | `512 * F` |
| Two claim headers | `2 * 256 * F` |
| Timing map | `32 * 160 * F` |
| At most three deduplicated dependency tokens per call edge | `3 * 256 * C` |
| Source-name payload and margin | `4 * S` |

The 256-byte dependency/header allowances exceed the retained maximal encodings
of 89/133 bytes; numeric ID growth remains within the existing numeric allowance.
The name payload bound is conservative: declaration-name spans are disjoint
within the complete source, while each full name is serialized in the entity
map and its termination message. Fixed `Main.` prefixes belong to the entry
allowances. The old envelope retains its existing Main/runtime metadata reserve.

```text
existing envelope = 31,822,336
additional = 128*(1024 + 512 + 2*256 + 32*160) + 3*256*512 + 4*4096
           = 1,327,104
combined   = 33,149,440 bytes
allocation = 33,554,432 bytes
headroom   =    404,992 bytes
```

This is a retained-report storage bound, not a solver-time or peak-memory
promise. Full emitted-check discharge, exact source-derived coverage and the
existing provenance requirements remain mandatory. The pinned `Warn_On_Unused_Objects` route in `flow-analysis.adb:1275–1366`
iterates an `Unused` set, obtains each object's initial vertex once, and emits
at most one exact `UNUSED_VARIABLE` advisory for that object. Its collection
uses `Considered_Objects`/`Used` sets at 1218–1267. Thus each unused formal adds
at most one fixed record and one declaration-name payload. Disjoint formal
syntax fits the inherited `2*S` flow-record and aggregate-name allowances;
this route needs no independent additional maximum. Classification remains
limited to exact local-function entities and the pinned message. The bounded
policy/capacity review above is complete. The delivery record links the later
complete native/Lean results and their exact review scope.

### Unused initial values — repair #391

The exact `UNUSED_INITIAL_VALUE` message `unused initial value of "NAME"`
also occurs for an admitted function `in` formal whose entry value reaches no
result. Both auditors now bind it to the exact declared function owner and
formal spelling, warning severity, flow provenance, `main.adb`, a positive
location and no suppression or justification. Main and nonformal names are
excluded. `INOUT_ONLY_READ` / `"NAME" is not modified, could be IN` is accepted
only for a declared procedure `in out` formal; the combined procedure policy
also accepts unused initial values for procedure `in`/`in out` formals.
No existing accepted diagnostic or required check is removed.

The [combined capacity account](scalar-procedures-report-capacity.md#formal-dependence-advisories--repair-391)
derives one additional record per formal from the pinned producer sets, at
`floor(4096/7)*1024 + 4096 = 603,136` bytes including disjoint name payloads.
It separately preserves the existing `UNUSED_VARIABLE` charge, including its
coexistence with `INOUT_ONLY_READ` on an unmentioned procedure `in out` formal.
Applying that conservative additional allowance to the historical function
envelope alone gives 33,752,576 bytes, exceeding its old 32 MiB selection; the
current 64 MiB allocation covers the complete 49,279,744-byte combined envelope.
The old function calculation above is historical, not the current storage bound.

## Inspected inputs and observations

| SPARK source | SHA-256 |
| --- | --- |
| `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `src/flow/flow-analysis.adb` | `10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94` |
| `src/why/gnat2why-assumptions.adb` | `c8ad7264625b572c6405319d599a9381c2cc1000dc51dea1e06e4301f54d01cf` |
| `src/common/assumptions.adb` | `c27cf3aefe1df294ed1e466a814eec071ea0f01d94dbad4ee932ed6bf98e59c7` |
| `src/common/assumption_types.adb` | `e30b9da4d2c164ebf69a7f9d5caa2999b6e487dd80bb28d8b8591b4f0d79bc31` |

Selected-grammar probe `20261107T173133-e00faebcc964` retained five Main/local
entities, four successful termination records and five safety records. Its
unused function retained division proof and full coverage. It used the native
toolchain directly, before the compiler implementation; it is not evidence that
the completed compiler accepted, proved or built that source.

The producer investigation selected GPT-6 Astra / Extra High. The integration
lead prepared this account from those inspected routes and rechecked input
hashes, retained report fields and arithmetic. Independent runtime settings and
token/cost measurements are unavailable. The independent capacity review above
records its own selected settings, exact target and limits. The later delivery
record separately identifies complete validation and the final review target.
