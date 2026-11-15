# Proposed scalar-procedure delivery reconciliation

**Prepared source/task reconciliation, 2026-11-15; final validation and delivery
pending.** This proposed patch accompanies owner-authorized
[#370](https://github.com/berkeleynerd/silver/issues/370) and
[#29](https://github.com/berkeleynerd/silver/issues/29). It is isolated on
`recovery/procedures-rosetta-20261115`, based on
`8ccbc84210346596bc8417cbf8b6bc40f8075ed7`. Its candidate `supported` list and
generated pages are prepared for coordinated delivery, not a current support
claim. They must not be promoted before the required final validation and
independent acceptance. The [capability record](../docs/scalar-procedures.md)
owns those separate assurance and delivery claims.

Selected subthread controls are **GPT-6.1 Sol / Extra High** (`gpt-6.1-sol`,
`xhigh`). Independent live-runtime confirmation, token/cost and total elapsed
work telemetry are unavailable. This bounded review compares the cached task,
its retained Ada solution, the unchanged sample, the manifest and the selected
language rules. It performs mathematical/output checks, a proposed render and
pure-Python Rosetta regressions. It performs no installation, bootstrap,
compiler build, application execution, native proof, Lean proof or full suite.
It is separate from an independent critical review of universal assurance or
actual-source correspondence.

## Task and unchanged source

The cached **Return multiple values** task is revision **412999**, timestamp
`2026-09-20T05:28:25Z`, at
[`r/return-multiple-values/task.wiki`](r/return-multiple-values/task.wiki).
It asks to show how to return more than one value from a function, without
requiring a particular input domain or output format. The retained
[Ada explanation](r/return-multiple-values/ada.wiki) explicitly describes
procedures with `out` parameters as the usual Ada mechanism. Its
[Ada program](r/return-multiple-values/ada-1.ada) defines `SumAndDiff`, returns
the sum and difference through two `out` formals and prints the results of
5 and 3. A procedure demonstration is therefore faithful to the task's own
Ada interpretation; a record return or general function is unnecessary.

The unchanged [Silver driver](../samples/rosetta_return_multiple_values.adb)
is **912 bytes**, **27 nonblank lines**, SHA-256
`fe82cee9e09fb5911c02049998bb580defec6168af792664427231880c7b547d`.
It defines `Small` as Integer range `-100 .. 100` and the Main-local
`Sum_And_Diff` with explicit `in Small` inputs and two `out Integer` formals.
The leading assignments, in formal order, compute `(Left + Right)` and
`(Left - Right)` without reading either output. No outer object or effect is
captured. Its distinct initialized mutable Integer actuals satisfy the
declared-range and alias requirements; neither output actual occurs in another
actual's input expression. The manifest names both output formals for the
application-report audit.

For every pair of declared inputs, both arithmetic results lie in
`-200 .. 200`, inside Standard.Integer. Each output is initialized exactly once
before any later statement. The routine has no loop, nested call, guard that
could discard a required result, or authored contract. These source arguments
cover the full formal-domain product; the three Main calls demonstrate
`(5, 3)`, `(-100, 100)` and `(100, 100)`, including input endpoints.

## Independent expected output

Exact integer arithmetic independently derives the result pairs `(8, 2)`,
`(0, -200)` and `(200, 0)`. Applying standard Integer Image formatting gives
one leading space for positive and zero values, and no extra space before
negative values. Appending each source-written label and newline produces:

```text
Sum: 8
Difference: 2
Sum: 0
Difference:-200
Sum: 200
Difference: 0
```

The **67-byte** expected stdout has SHA-256
`4af8f788ee41cd6f93e9d9f7bd4c98550618eeea59c5f53f16329781b8cd138a`.
Static comparison exactly matches the existing manifest's stdout, empty stderr
and exit status 0. A separate Python exact-integer enumeration also confirmed
both result bounds for all **40,401** pairs in the declared product. Neither
this enumeration nor the expected-output match is an execution result or proof
of the compiler's universal guarantees. Native application admission, complete
obligation/report checks, compilation and execution on final delivery inputs
remain part of final validation.

## Proposed mapping and provenance

Only **Return multiple values** receives a changed assessment. Its precise
surface is:

- `scalar-procedures`: explicit modes, ordered source-written output
  initialization and standalone positional calls returning both scalar results;
- `named-integer-subtypes`: the complete `Small` input domain;
- `bounded-mutable-integers`: initialized caller output objects;
- `integer-image`: the printed results.

Only `scalar-procedures` is newly added to the proposed `supported` list.
Broad `procedures`, `integers`, `ranged-subtypes` and `scalar-image` remain
unsupported. The assessor describes the exact closed scalar fragment, full
formal-domain checks, prefix boundary, conservative writable ranges,
same-incoming-state inputs, distinct writable targets, cross-actual read/write
exclusion, caller-state preservation, earlier-only calls, finite loops,
unchanged budgets and remaining exclusions. Named-subtype descriptions now
include function and procedure signatures; the renderer has the precise
procedure label and admission question. No unrelated task is reassessed.

Original attribution remains unchanged: assessed `2026-10-15`, revision
`412999`, rubric `2`, tier `deep`, model `claude-opus-5-5`, effort `high`.
There was no existing targeted `review` object. The separately attributed
2026-11-15 review links this record and identifies its actual static scope and
selected settings. Outlook `likely` and confidence `high` are retained. The
historical design's approximate 20 lines and suggested `-1000 .. 1000` bound
are replaced in current fields by the exact 27-line source and `Small` domain;
they are not retroactively attributed to the original assessor. The earlier
[2026-11-09 prepared review](assessment-scalar-procedures-20261109.md) remains
unchanged, including its pending-validation status and original provenance.

## Proposed render and focused checks

`PYTHONDONTWRITEBYTECODE=1 python3 rosetta/refresh.py --render` completed from
the existing manifest and assessments without network access. The proposed
render contains **84 Stage 1 mappings**, up from **83**. Exactly one task enters
Stage 1: Return multiple values moves from **rank 85 / Stage 2** to **rank 59 /
Stage 1**. None leaves Stage 1 and no other task changes stage. There are still
**44 stages**. The broad procedure/ranged-subtype/Image stage remains **Stage
2**, driven by Law of cosines - triples, and is still broader than this scalar
fragment. The broader [#11](https://github.com/berkeleynerd/silver/issues/11)
stage must remain open for its remaining forms.

All **12** existing pure-Python Rosetta tests passed in **3.670 seconds** with
`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest tests.test_rosetta -v`.
They include refresh preflight preservation, offline rebuilding, design-pending
handling, deterministic complete rendering across hash seeds and risk counting.
This is focused Rosetta tooling evidence, not native, Lean or full regression
evidence. Static checks also confirm exactly one changed task assessment, the
single added supported identifier, unchanged original provenance and a clean
`git diff --check`.

## Pending coordinated promotion

Final complete native assurance, Lean/source/module/axiom auditing, final
regression/sample coverage and independent delivery acceptance remain pending
outside this reconciliation. No successful result is inferred from an active
run. Samples and static task comparisons do not establish universal assurance.
The lead must attach actual final evidence and replace current pending delivery
wording before integrating or publishing these proposed supported mappings,
while preserving this review's historical scope and attribution.

The lead also owns the coordinated capability status, language/catalogue/sample
consistency, roadmap, milestone and issue/board updates, including the precise
fragment's relationship to still-open #11. This branch changes none of those
records, does not implement #373, and authorizes no merge or broader feature.
