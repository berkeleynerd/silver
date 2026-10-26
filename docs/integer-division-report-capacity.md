# Integer division producer and report envelope

Feature-local source review for [#230](https://github.com/berkeleynerd/silver/issues/230)
and [#232](https://github.com/berkeleynerd/silver/issues/232), 2026-10-25.
This extends the [bounded mutable Integer calculation](bounded-mutable-report-capacity.md)
for the selected `/`, `mod` and `rem` forms. It does not resume #119, increase
storage, or establish the capability's separate universal/source/proof checkpoint.

## Inputs and producer routes

Retain the baseline's pinned producer, recipe, frontend and local-tool assumptions.
The [source inventory and excerpts](evidence/integer-division/producer-review.json)
record the inspected bytes and source locations: SPARK fsf-16
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, and GCC frontend
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. This is source inspection under the
existing correspondence assumptions, not installed-binary attestation.

`gnat2why-expr.adb:24150–24238` translates each arithmetic operand once to the
base Why type. In `why-gen-expr.adb:3999–4098`, signed Integer division selects
the mathematical Integer operator and constructs one `New_Operator_Call` with
`VC_Division_Check`, conditional on executable mode and the frontend check flag.
The `mod`/`rem` branch at `4099–4137` constructs one such call in executable
mode. Neither selected operation uses fixed-point or bitvector routes.
`New_Operator_Call` at `5244–5276` introduces at most one `New_VC_Expr`.
The common overflow wrapper at `gnat2why-expr.adb:25511–25575` retains the
existing allowance of at most one overflow check per arithmetic source site.

The baseline's checked-conversion, declaration/assignment roots, loop bounds,
Image traversal and deduplication arguments remain applicable: these new
intrinsic Integer operations introduce no Ada call, object, subtype, output,
loop or report entity. The base-type operand conversions do not introduce a
new independent range-check route. Term-domain/static elimination can reduce
records; it is not assumed to eliminate every division check. The existing
no-loop-unrolling application configuration is unchanged.

The frontend `checks.adb:440–448` excludes `rem` and `mod` from overflow checks;
its signed-division check at `6385–6408` identifies minimum divided by minus one.
The semantic rules nevertheless establish every intermediate result's range.
Remainder operators retain the mathematically and Ada-defined zero result for
minimum with divisor minus one.

## Record size and count

`VC_Division_Check` means the second operand differs from zero
(`vc_kinds.adb:246`). The report spelling is `VC_DIVISION_CHECK`; its successful
message is `division check proved`. Both fit the existing overflow record's
rule/message widths. Entity/file/position fields, prover statistics and retained
payload schema are unchanged, so the existing **2,048-byte** safety-record
allowance applies. The capacity regression explicitly checks that retained
successful division-record shape against the allowance.

The lexical counter now charges each `/`, `mod` and `rem` source operator,
including case variants, exactly once in the shared **63-operator** budget.
Whole identifiers, numeric exponents, comments and String literals keep their
existing treatment; `/=` is a comparison and is not an arithmetic operator.
The native and Lean work-counter correspondence is part of #232.

Conservatively retain every existing charge and add one nonzero-divisor record
for each of the at most 63 arithmetic occurrences:

```text
15,292,416 + 63 * 2,048 = 15,421,440 bytes
16,777,216 - 15,421,440 = 1,355,776 bytes of headroom
```

The existing arithmetic allowance already covers overflow; the new charge
covers the additional division obligation. Both can be counted even where the
actual operator emits fewer records. No storage constant changes. Runtime,
flow and fixed metadata envelopes remain as before. `tests/test_capacity.py`
checks the arithmetic and retained record sizes; it does not replace the
source-derived counting argument or complete obligation discharge.

## Native corroboration and scope choices

Managed discovery run `20261025T220716-b589ceb694aa` used the pinned tools with
an isolated ordinary Ada/SPARK source and the application proof options. It
proved eight `VC_DIVISION_CHECK` records, covering both divisor signs and
minimum-Integer `mod`/`rem` cases. Static minimum/divisor-minus-one remainder
initializers also passed. This establishes observed producer behavior, not
language-wide assurance or admission of the exploratory source shell.

Separate empty-loop probes also passed: runs
`20261025T220859-607733c0fe31`, `20261025T220908-2707637afa18` and
`20261025T220916-fdf3e2d848b5` proved the vacuous division checks for `/`, `mod`
and `rem` with a zero divisor. Accordingly the selected uniform rejection of
a nonempty zero-containing divisor interval, even when the other operand is
empty, is an explicit conservative Silver rule. It is **not** claimed to be a
frontend necessity. Static invalid subexpressions remain independently rejected.
Exact sources, reports, commands and logs are retained with the design evidence.
