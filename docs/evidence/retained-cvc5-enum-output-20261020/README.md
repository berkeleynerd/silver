# Generated CVC5 enum spelling packet

Authorized research #119 / #153, 2026-10-20 UTC. Candidate CVC5 revision:
`86cecd83b685f59e884094693b9a4c5c90a62e03`.

The [research note](../../research/retained-cvc5-enum-output.md) states exact
ordinary spelling domains and conditional histogram allowances for internal/API
Kind, TypeConstant, ProofRule and ProofRewriteRule. Whole-output `q_cvc5` and
weighted `O` remain null. Existing seven-table evidence is reused, not replayed.

- `check.py` is a standard-library-only Python 3.11+ offline inventory/checker.
  Its primary input is the full already-retained predecessor
  `../retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz`, whose exact
  SHA-256 it pins. It makes no network or native-tool call.
- `result.json` contains every sorted spelling set, enum-to-spelling map, byte
  count/maximum, allowance and complete build-list/rule-header inventory. Source
  identities identify all 55 complete used source files. The full archive also
  supplies the source census for the absence of API-Kind `toString` overloads.
- `used-sources.tar.gz` retains those complete used files in canonical paths for
  independent inspection; the checker compares every byte with the full archive.
- `generated-kind.h` / `.cpp` retain successful upstream Kind-generator outputs.
  The checker compares their enum/case maps to independently parsed TOML input.
  `generator-run.json` records commands, identities, execution/dependency results
  and available timing. The full rewrite generator was not executed because
  `pyparsing` is unavailable; the conditional domain instead follows from the
  complete input header inventory, inspected name transfer and generated-header
  identifier cross-check. No DSL typecheck or successful rewrite build is claimed.
- `round.json` records author settings, elapsed evidence and scope. `check-run.json`
  records the focused frozen-candidate offline verification.

Run from the repository root:

```text
python3 docs/evidence/retained-cvc5-enum-output-20261020/check.py
```

`--write` regenerates `result.json` and the deterministic used-source archive;
it does not execute an upstream generator. The two small generated Kind files
are separately retained execution evidence. Review this packet as a
candidate-source component, not installed-binary behavior or selected task/key
reachability. Safe printing does not collapse duplicate spellings; no numeric
safe bucket-count bound is exported. The parent owns review, integration,
issue/session-memory state and publication.
