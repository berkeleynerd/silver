# Round 35 integration reconciliation

This packet checks exact author-freeze bytes for the tuple, initial-registration,
library-publication and numerical composition components, together with all 94
existing native input pins. It parses new Python sources and resolves local
Markdown links at semantic aggregate `1a217c1412`.

```sh
python3 -B docs/evidence/retained-why-save-round35-20261020/check.py
```

`inputs.json` identifies every author freeze and the review target;
`integration-result.json` records each checked path and identity. The check does
not replay component checkers, captures, disassembly, compiler/proof/solver work,
or older native validation. Reconciliation establishes identity, not semantic
correctness. The combined Round 35 review and separate initial-registration
review record their exact acceptance scopes.
