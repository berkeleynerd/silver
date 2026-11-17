# Scalar-procedure delivery reconciliation

Owner-authorized #370/#29 delivery adds the precise `scalar-procedures`
identifier and moves Return multiple values alone into Stage 1. The original
source/task review below retains its static scope and attribution; the
[final-validation addendum](#final-validation-addendum) records later evidence
separately. The lead released this reconciliation following independent
acceptance of retained and repair regression coverage. Final Rosetta checks
below supply results on the delivered metadata bytes. The
[capability delivery record](../docs/scalar-procedures.md#delivery-assurance-and-validation)
owns the separate integrated feature-delivery review and support claim.

## Original preparation snapshot

The following review is historical. Its proposed and pending statements
describe the preparation state before the later evidence and regression
acceptance recorded in the addendum; they are not current delivery metadata.

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

### Task and unchanged source

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

### Independent expected output

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

### Proposed mapping and provenance

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

### Proposed render and focused checks

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

### Pending coordinated promotion

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

## Final-validation addendum

This addendum supplements the original static reconciliation without changing
its scope or retrospectively attributing native or Lean validation to that
review. The lead's [capability delivery record](../docs/scalar-procedures.md#delivery-assurance-and-validation)
owns the complete assurance, regression acceptance and support claim. The
[Rosetta validation packet](../docs/evidence/scalar-procedures-20261115/regression-recovery/rosetta/README.md)
identifies the exact final render/test inputs and results, output hashes,
mapping controls and the lead's release scope.

Later Linux ARM64 evidence includes the successful complete native audit
`20261115T174959-94ae5c6fdf63`: 19,444 required checks across 78 units and
1,232 entities. The original launcher's exit was not observed; the native-tool
exit, managed outcome and fresh terminal audits are retained separately in the
[native packet](../docs/evidence/scalar-procedures-20261115/native-recovery/full-native/README.md).
Compiler build `20261115T212353-b892f44c0742` succeeded. Complete cached Lean
run `20261115T215223-28e04bff3fce` freshly audited all 1,009 project modules
and 162,269 declarations, with only `propext`, `Classical.choice` and
`Quot.sound`; its [packet](../docs/evidence/scalar-procedures-20261115/lean-recovery/complete-checkpoint/final-complete-cached/README.md)
distinguishes cached validation from clean checking or independent replay.

The completed full regression `20261115T220916-99f1eaeea331` remains failed:
its exact 691-ID inventory has 687 passes, two failing IDs and two expected
Linux-x86-only skips. All 85 manifest samples passed, including the unchanged
Return multiple values driver, with admission, automatic obligation/report
checks, compilation and execution. Sample success is separate from universal
assurance and does not relabel that full suite as successful. The fixture
dependency repair's whole-module rerun `20261115T222916-4123afb6a6ad` passed
all three methods and all eleven cache mutation variants. The whole 23-method
scalar-guard rerun also passed on unchanged inputs with a documented 16 MiB
child stack, completing at 22:35:21 UTC. Its three original boundary failures
at 8 MiB remain recorded. These are separately retained repair/environment
results. Independent Astra Max review accepted complete final-inventory
applicability under [development.md](../development.md#proof-loop-and-validation):
before the final Rosetta updates, 26 fresh passes, 663 retained passes and two
expected skips cover all 691 IDs, with both original failing IDs resolved.
The 12 successful final-byte Rosetta results replace their 12 retained results,
giving **38 fresh passes, 651 retained passes and two expected skips**.
The full-suite attempt retains its failed outcome; these figures describe the
composition of successful applicable results.

On the final render/test inputs, all 12 pure-Python Rosetta methods passed at
22:39:42 UTC, with unittest reporting 3.178 s and the subprocess taking 3.425 s.
The complete rendered inventory contains 1,784 pages/indexes. Exact input,
output and command hashes, each test ID/result and the deterministic-render
checks are retained in the Rosetta packet. No successful native, Lean, build
or regression checkpoint was repeated for these metadata/document changes.

The final current-language and task summaries describe the precise scalar
fragment and actual sample result, linking the capability delivery record.
Their targeted `review` metadata still identifies static task/source comparison
and Python tooling validation, with later compiler/proof evidence attributed to
this separate addendum. The original 2026-10-15 Opus attribution and
[2026-11-09 pending review](assessment-scalar-procedures-20261109.md) are
unchanged. No unrelated task assessment, broader procedure mapping, #11 closure
or successor implementation is included.
