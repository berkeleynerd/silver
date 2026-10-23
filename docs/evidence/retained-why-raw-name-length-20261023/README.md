# Raw identifier-name evidence, 2026-10-23

Candidate [source argument](../../research/retained-why-raw-name-length.md),
Refs #119 / #153; base `8b651049e46c8800df92e9efed4832ddfcbad8ab`.

The five L values are 70 / 70 / 67 / 52 / 54 bytes. Composing with accepted
R64 gives unique printed/candidate name bounds 163 / 163 / 157 / 126 / 130.
Separate proposition-comment values L_pr are 74 / 74 / 71 / 56 / 58, additionally
conditional on the frozen Hsattr hypothesis-name interface. Review is pending.

- `project.py`, `*-names.json`: new direct original capture-byte projection of
  all declaration/signature/type names and complete retained variable/seed names;
  R54 range-metadata pointer correspondence is explicit.
- `inputs.json`, `source-witnesses.json`: frozen providers and complete member
  hashes with strict line ranges. No old evidence is rewritten.
- `hyp-name-provider.md`, `hyp-name-provider-result.json`: exact portable copies
  from Hsattr author freeze `62f686fe73`, consumed only for hyp_name value≤13.
  Other claims in those copies are outside this packet's scope.
- `check.py`, `result.json`, `check-result.json`: current-packet correspondence
  and arithmetic checks; the accepted R64 callable API is reused without running
  its checker or model.
- `round.json`: actual evidence scope, selected settings, findings and timing.

From the repository root:

```sh
python3 docs/evidence/retained-why-raw-name-length-20261023/check.py
```

`freeze.py` prepares a new input freeze; the checker does not run it or refresh
hashes. Its finite checks do not establish the universal source-origin induction.
No native target, compiler, solver, proof, fresh capture or historical checker
runs. No Oracle/tool/pin/admission change or aggregate RAM gate. Whole printer,
formatter/output, name-uniqueness semantics and complete #119 remain separate.
